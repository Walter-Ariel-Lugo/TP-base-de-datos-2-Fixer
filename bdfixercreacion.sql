
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DBFixer')
BEGIN
    --se agrega SET SINGLE_USER antes para que no falle si la base esta en uso 
    ALTER DATABASE DBFixer SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBFixer;
END
GO

CREATE DATABASE DBFixer
COLLATE Latin1_General_CI_AI;
GO

USE DBFixer;
GO

CREATE TABLE Rol (
    ID   SMALLINT  PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(50) NOT NULL
);
GO

CREATE TABLE Usuarios (
    IDUsuario INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Rol SMALLINT NOT NULL FOREIGN KEY REFERENCES Rol (ID),
    Nombre VARCHAR(50)  NOT NULL,
    -- CAMBIO: Mail de 50 a 100 caracteres y UNIQUE.
    Mail VARCHAR(100) NOT NULL UNIQUE,
    -- CAMBIO: nueva columna Pass.
    Pass  VARCHAR(64)  NOT NULL,
    Telefono VARCHAR(50)  NOT NULL
);
GO

CREATE TABLE Tecnico (
    -- CAMBIO: se quita IDENTITY.
    IDUsuario  INT NOT NULL PRIMARY KEY  FOREIGN KEY REFERENCES Usuarios (IDUsuario),
    -- Activo = el administrador lo habilita o deshabilita.
    Activo   BIT NOT NULL DEFAULT 1,
    -- CAMBIO: nueva columna Disponible. esto es para qeu el mismo tecnico se marque como disponible para la lista de fixer 
    Disponible  BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE TipoServicio (
    IDTipoServicio  INT  PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Nombre    VARCHAR(50)  NOT NULL,
    Descripcion  VARCHAR(255) NULL
);
GO

CREATE TABLE Servicio (
    IDServicio INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    IDTipo INT NOT NULL FOREIGN KEY REFERENCES TipoServicio (IDTipoServicio),
    Nombre VARCHAR(50)  NOT NULL,
    Descripcion VARCHAR(255) NULL,
    -- CAMBIO: Precio de INT NULL a DECIMAL(10,2) NOT NULL, con CHECK.para unificar todos los importes de todas la tablas y 
    --el check que pidio el profesor que eun precio no puede ser menos a 0
    Precio DECIMAL(10,2) NOT NULL CHECK (Precio >= 0),
    -- CAMBIO: TiempoPromedio de TIME NULL a INT NOT NULL (minutos), con CHECK.igual unificar tiempos y check 
    TiempoPromedio INT NOT NULL CHECK (TiempoPromedio > 0),
    Activo BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE TecnicoServicio (
    IDTecnico INT NOT NULL FOREIGN KEY REFERENCES Tecnico (IDUsuario),
    IDServicio INT NOT NULL FOREIGN KEY REFERENCES Servicio (IDServicio),
    Activo BIT NOT NULL DEFAULT 1,
    -- CAMBIO: clave primaria compuesta.
    PRIMARY KEY (IDTecnico, IDServicio)
);
GO

CREATE TABLE OrdenTrabajo (
    IDOrdenTrabajo INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    IDCliente INT NOT NULL FOREIGN KEY REFERENCES Usuarios (IDUsuario),
    IDTecnico INT NOT NULL FOREIGN KEY REFERENCES Tecnico (IDUsuario),
    FechaSolicitud SMALLDATETIME NOT NULL,
    FechaProgramada SMALLDATETIME NULL,
    -- CAMBIO: nueva columna FechaFinalizacion.
    FechaFinalizacion SMALLDATETIME NULL,

    -- CAMBIO: nueva columna Estado, con valor por defecto y CHECK.
    --   -> Lo pidió el profesor: saber si la orden está pendiente, iniciada, etc.
    Estado VARCHAR(20)   NOT NULL DEFAULT 'Pendiente' CHECK (Estado IN ('Pendiente', 'Iniciada', 'Finalizada', 'Cancelada')),
    Direccion VARCHAR(255)  NULL,
    PresupuestoTotal DECIMAL(10,2) NOT NULL CHECK (PresupuestoTotal >= 0),
    TiempoEstimadoTotal INT NOT NULL CHECK (TiempoEstimadoTotal >= 0),
    Observaciones VARCHAR(255)  NULL,
    CHECK (FechaFinalizacion IS NULL OR FechaFinalizacion >= FechaSolicitud)
);
GO

CREATE TABLE DetalleOrden (
    -- CAMBIO: se quita la columna IDDetalleOrden (IDENTITY).
    IDOrden INT NOT NULL FOREIGN KEY REFERENCES OrdenTrabajo (IDOrdenTrabajo),
    IDServicio INT NOT NULL FOREIGN KEY REFERENCES Servicio (IDServicio),
    -- CAMBIO: Cantidad de NULL a NOT NULL, con CHECK.
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    -- CAMBIO: PrecioUnitario de SMALLMONEY a DECIMAL(10,2), con CHECK.
    PrecioUnitario DECIMAL(10,2) NOT NULL CHECK (PrecioUnitario >= 0),
    TiempoUnitario INT NOT NULL CHECK (TiempoUnitario > 0),
    PRIMARY KEY (IDOrden, IDServicio)
);
GO


--  DATOS DE PRUEBA (en la versión final pasarlos a otro archivo )

INSERT INTO Rol (Nombre) VALUES ('Administrador'), ('Cliente'), ('Tecnico');
GO

-- Un usuario de cada perfil. Contraseña de todos: 1234
INSERT INTO Usuarios (Rol, Nombre, Mail, Pass, Telefono) VALUES
(1, 'Admin Fixer','admin@fixer.com', LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '1234'), 2)), '1100000001'),
(2, 'Cliente Demo', 'cliente@fixer.com', LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '1234'), 2)), '1100000002'),
(3, 'Tecnico Demo', 'tecnico@fixer.com', LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '1234'), 2)), '1100000003');
GO

INSERT INTO Tecnico (IDUsuario)
SELECT IDUsuario FROM Usuarios WHERE Mail = 'tecnico@fixer.com';
GO

-- Categorías
INSERT INTO TipoServicio (Nombre, Descripcion) VALUES
('Plomería','Pérdidas, canillas, destapaciones'),
('Electricidad','Enchufes, lámparas, artefactos'),
('Jardinería', 'Poda, corte de césped');
GO

-- Servicios (precio en pesos, tiempo en minutos)
INSERT INTO Servicio (IDTipo, Nombre, Descripcion, Precio, TiempoPromedio) VALUES
((SELECT IDTipoServicio FROM TipoServicio WHERE Nombre = 'Plomería'), 'Cambiar cuerito de canilla', 'Reemplazo del cuerito para cortar la pérdida', 8000,  45),
((SELECT IDTipoServicio FROM TipoServicio WHERE Nombre = 'Plomería'), 'Cambiar canilla', 'Canilla provista por el cliente', 12000, 60),
((SELECT IDTipoServicio FROM TipoServicio WHERE Nombre = 'Electricidad'), 'Cambiar tomacorriente', 'Reemplazo de toma existente', 7000,  30),
((SELECT IDTipoServicio FROM TipoServicio WHERE Nombre = 'Electricidad'), 'Instalar ventilador de techo', 'Con conexión a llave existente', 20000, 90),
((SELECT IDTipoServicio FROM TipoServicio WHERE Nombre = 'Jardinería'), 'Corte de césped', 'Hasta 100 m²', 15000, 120);
GO

-- El técnico de prueba puede hacer los servicios de Plomería y Electricidad.
INSERT INTO TecnicoServicio (IDTecnico, IDServicio)
SELECT t.IDUsuario, s.IDServicio
FROM Tecnico t
CROSS JOIN Servicio s
INNER JOIN TipoServicio ts ON s.IDTipo = ts.IDTipoServicio
WHERE ts.Nombre IN ('Plomería', 'Electricidad');
GO

-- ver tablas 
SELECT * FROM Rol;
SELECT IDUsuario, Rol, Nombre, Mail FROM Usuarios;
SELECT * FROM Tecnico;
SELECT * FROM TipoServicio;
SELECT * FROM Servicio;
SELECT * FROM TecnicoServicio;
