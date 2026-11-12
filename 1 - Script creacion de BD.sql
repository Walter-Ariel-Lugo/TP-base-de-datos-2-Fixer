USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DBFixer')
BEGIN
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
    ID      SMALLINT    PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Nombre  VARCHAR(50) NOT NULL
);
GO

CREATE TABLE Usuarios (
    IDUsuario  INT          PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Rol        SMALLINT     NOT NULL FOREIGN KEY REFERENCES Rol (ID),
    Nombre     VARCHAR(50)  NOT NULL,
    Mail       VARCHAR(100) NOT NULL UNIQUE,
    Pass       VARCHAR(64)  NOT NULL,
    Telefono   VARCHAR(50)  NOT NULL
);
GO

CREATE TABLE Tecnico (
    IDUsuario   INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES Usuarios (IDUsuario),
    Activo      BIT NOT NULL DEFAULT 1,
    Disponible  BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE TipoServicio (
    IDTipoServicio  INT          PRIMARY KEY IDENTITY(1,1) NOT NULL,
    Nombre          VARCHAR(50)  NOT NULL,
    Descripcion     VARCHAR(255) NULL
);
GO

CREATE TABLE Servicio (
    IDServicio      INT           PRIMARY KEY IDENTITY(1,1) NOT NULL,
    IDTipo          INT           NOT NULL FOREIGN KEY REFERENCES TipoServicio (IDTipoServicio),
    Nombre          VARCHAR(50)   NOT NULL,
    Descripcion     VARCHAR(255)  NULL,
    Precio          DECIMAL(10,2) NOT NULL CHECK (Precio >= 0),
    TiempoPromedio  INT           NOT NULL CHECK (TiempoPromedio > 0),
    Activo          BIT           NOT NULL DEFAULT 1
);
GO

CREATE TABLE TecnicoServicio (
    IDTecnico   INT NOT NULL FOREIGN KEY REFERENCES Tecnico (IDUsuario),
    IDServicio  INT NOT NULL FOREIGN KEY REFERENCES Servicio (IDServicio),
    Activo      BIT NOT NULL DEFAULT 1,
    PRIMARY KEY (IDTecnico, IDServicio)
);
GO

CREATE TABLE OrdenTrabajo (
    IDOrdenTrabajo       INT           PRIMARY KEY IDENTITY(1,1) NOT NULL,
    IDCliente            INT           NOT NULL FOREIGN KEY REFERENCES Usuarios (IDUsuario),
    IDTecnico            INT           NOT NULL FOREIGN KEY REFERENCES Tecnico (IDUsuario),
    FechaSolicitud       SMALLDATETIME NOT NULL,
    FechaProgramada      SMALLDATETIME NULL,
    FechaFinalizacion    SMALLDATETIME NULL,
    Estado               VARCHAR(20)   NOT NULL DEFAULT 'Pendiente'
                         CHECK (Estado IN ('Pendiente', 'Iniciada', 'Finalizada', 'Cancelada')),
    Direccion            VARCHAR(255)  NULL,
    PresupuestoTotal     DECIMAL(10,2) NOT NULL CHECK (PresupuestoTotal >= 0),
    TiempoEstimadoTotal  INT           NOT NULL CHECK (TiempoEstimadoTotal >= 0),
    Observaciones        VARCHAR(255)  NULL,
    CHECK (FechaFinalizacion IS NULL OR FechaFinalizacion >= FechaSolicitud)
);
GO

CREATE TABLE DetalleOrden (
    IDOrden         INT           NOT NULL FOREIGN KEY REFERENCES OrdenTrabajo (IDOrdenTrabajo),
    IDServicio      INT           NOT NULL FOREIGN KEY REFERENCES Servicio (IDServicio),
    Cantidad        INT           NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario  DECIMAL(10,2) NOT NULL CHECK (PrecioUnitario >= 0),
    TiempoUnitario  INT           NOT NULL CHECK (TiempoUnitario > 0),
    PRIMARY KEY (IDOrden, IDServicio)
);
GO

SELECT name AS Tabla
FROM sys.tables
ORDER BY name;
GO
