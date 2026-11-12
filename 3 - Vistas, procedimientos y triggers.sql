USE DBFixer;
GO
-- VISTA vista_tecnicosDisponibles: lista los tecnicos habilitado y disponibles para los servicios elegidos por el cliente  

IF OBJECT_ID('vista_tecnicosDisponibles', 'V') IS NOT NULL
    DROP VIEW vista_tecnicosDisponibles;
GO

CREATE VIEW vista_tecnicosDisponibles AS
SELECT
    T.IDUsuario,
    U.Nombre,
    U.Mail,
    U.Telefono
FROM Tecnico AS T
INNER JOIN Usuarios AS U ON T.IDUsuario = U.IDUsuario
WHERE T.Activo = 1
  AND T.Disponible = 1;
GO

-- PROCEDIMIENTO sp_agregarServicioAOrden:  Agrega un servicio a una orden de trabajo, copiando el precio y el tiempo del servicio al detalle

IF OBJECT_ID('sp_agregarServicioAOrden', 'P') IS NOT NULL
    DROP PROCEDURE sp_agregarServicioAOrden;
GO

CREATE PROCEDURE sp_agregarServicioAOrden
    @IdOrden INT,
    @IdServicio INT,
    @Cantidad INT
AS
BEGIN
    IF EXISTS (SELECT IDServicio FROM DetalleOrden
               WHERE IDOrden = @IdOrden AND IDServicio = @IdServicio)
    BEGIN
        PRINT 'Este servicio ya está en la orden.';
        RETURN;
    END

    DECLARE @Precio DECIMAL(10,2);
    DECLARE @Tiempo INT;
    SELECT @Precio = Precio, @Tiempo = TiempoPromedio
    FROM Servicio
    WHERE IDServicio = @IdServicio AND Activo = 1;

    IF @Precio IS NULL
    BEGIN
        PRINT 'El servicio no existe o está dado de baja.';
        RETURN;
    END

    INSERT INTO DetalleOrden (IDOrden, IDServicio, Cantidad, PrecioUnitario, TiempoUnitario)
    VALUES (@IdOrden, @IdServicio, @Cantidad, @Precio, @Tiempo);

    PRINT 'Servicio agregado a la orden.';
END
GO
-- TRIGGER trg_recalcularPresupuesto: Cada vez que se agrega un servicio a una orden (INSERT en DetalleOrden), recalcula
-- el presupuesto total (precio x cantidad) y el tiempo estimado total (tiempo x cantidad) de esa orden, sumando TODOS sus servicios

IF OBJECT_ID('trg_recalcularPresupuesto', 'TR') IS NOT NULL
    DROP TRIGGER trg_recalcularPresupuesto;
GO

CREATE TRIGGER trg_recalcularPresupuesto
ON DetalleOrden
AFTER INSERT
AS
BEGIN
    DECLARE @IdOrden INT;
    SELECT @IdOrden = IDOrden FROM inserted;

    UPDATE OrdenTrabajo
    SET PresupuestoTotal    = (SELECT SUM(PrecioUnitario * Cantidad)
                               FROM DetalleOrden WHERE IDOrden = @IdOrden),
        TiempoEstimadoTotal = (SELECT SUM(TiempoUnitario * Cantidad)
                               FROM DetalleOrden WHERE IDOrden = @IdOrden)
    WHERE IDOrdenTrabajo = @IdOrden;
END
GO

-- VISTA vista_ordenesDetalle: Muestra cada orden de trabajo con el NOMBRE del cliente y del técnico 
-- (en lugar de sus números de ID), el estado, las fechas, el presupuesto y el tiempo estimado.

IF OBJECT_ID('vista_ordenesDetalle', 'V') IS NOT NULL
    DROP VIEW vista_ordenesDetalle;
GO

CREATE VIEW vista_ordenesDetalle AS
SELECT
    OT.IDOrdenTrabajo,
    OT.IDCliente,
    Cli.Nombre AS Cliente,
    OT.IDTecnico,
    Tec.Nombre AS Tecnico,
    OT.Estado,
    OT.FechaSolicitud,
    OT.FechaProgramada,
    OT.FechaFinalizacion,
    OT.PresupuestoTotal,
    OT.TiempoEstimadoTotal
FROM OrdenTrabajo AS OT
INNER JOIN Usuarios AS Cli ON OT.IDCliente = Cli.IDUsuario
INNER JOIN Usuarios AS Tec ON OT.IDTecnico = Tec.IDUsuario;
GO

-- PROCEDIMIENTO sp_ordenesPorTecnico: Recibe el ID de un técnico y un estado, y devuelve las órdenes de ese técnico en
-- ese estado, ordenadas por fecha programada. Incluye teléfono y dirección del cliente, que es lo que el técnico necesita para ir a hacer el trabajo.

IF OBJECT_ID('sp_ordenesPorTecnico', 'P') IS NOT NULL
    DROP PROCEDURE sp_ordenesPorTecnico;
GO

CREATE PROCEDURE sp_ordenesPorTecnico
    @IdTecnico INT,
    @Estado VARCHAR(20)
AS
BEGIN
    SELECT
        OT.IDOrdenTrabajo,
        Cli.Nombre AS Cliente,
        Cli.Telefono,
        OT.Direccion,
        OT.FechaProgramada,
        OT.Estado,
        OT.PresupuestoTotal,
        OT.TiempoEstimadoTotal,
        OT.Observaciones
    FROM OrdenTrabajo AS OT
    INNER JOIN Usuarios AS Cli ON OT.IDCliente = Cli.IDUsuario
    WHERE OT.IDTecnico = @IdTecnico
      AND OT.Estado = @Estado
    ORDER BY OT.FechaProgramada;
END
GO

-- TRIGGER trg_eliminarTecnico: Se ejecuta EN LUGAR DE (INSTEAD OF) cualquier DELETE sobre Tecnico.
-- No borra al técnico: lo da de baja lógica (Activo = 0).

IF OBJECT_ID('trg_eliminarTecnico', 'TR') IS NOT NULL
    DROP TRIGGER trg_eliminarTecnico;
GO

CREATE TRIGGER trg_eliminarTecnico
ON Tecnico
INSTEAD OF DELETE
AS
BEGIN
    UPDATE Tecnico SET Activo = 0
    WHERE IDUsuario IN (SELECT IDUsuario FROM deleted);
END
GO

-- TRIGGER trg_desactivarServiciosTecnico: Se ejecuta DESPUÉS de cualquier UPDATE sobre Tecnico. Si un técnico pasó de
-- activo a inactivo, desactiva todos los servicios que tenía asignados en TecnicoServicio, para que el sistema no lo proponga a ningún cliente.

IF OBJECT_ID('trg_desactivarServiciosTecnico', 'TR') IS NOT NULL
    DROP TRIGGER trg_desactivarServiciosTecnico;
GO

CREATE TRIGGER trg_desactivarServiciosTecnico
ON Tecnico
AFTER UPDATE
AS
BEGIN
    UPDATE TecnicoServicio SET Activo = 0
    WHERE IDTecnico IN (
        SELECT i.IDUsuario
        FROM inserted i
        INNER JOIN deleted d ON d.IDUsuario = i.IDUsuario
        WHERE d.Activo = 1
          AND i.Activo = 0
    );
END
GO

-- VISTA vista_serviciosMasContratados: Ranking de los servicios activos según en cuántas órdenes fueron contratados,
-- con su categoría, precio y tiempo promedio.

IF OBJECT_ID('vista_serviciosMasContratados', 'V') IS NOT NULL
    DROP VIEW vista_serviciosMasContratados;
GO

CREATE VIEW vista_serviciosMasContratados AS
SELECT TOP 100
    S.IDServicio,
    S.Nombre AS Servicio,
    TS.Nombre AS Categoria,
    S.Precio,
    S.TiempoPromedio,
    COUNT(DeO.IDOrden) AS VecesContratado
FROM DetalleOrden AS DeO
INNER JOIN Servicio AS S ON DeO.IDServicio = S.IDServicio
INNER JOIN TipoServicio AS TS ON TS.IDTipoServicio = S.IDTipo
WHERE S.Activo = 1
GROUP BY S.IDServicio, S.Nombre, TS.Nombre, S.Precio, S.TiempoPromedio
ORDER BY VecesContratado DESC;
GO
-- VISTA vista_serviciosConTecnicos: Todos los servicios (activos e inactivos) con su categoría y la cantidad de
-- técnicos ACTIVOS que tienen ese servicio asignado y activo.

IF OBJECT_ID('vista_serviciosConTecnicos', 'V') IS NOT NULL
    DROP VIEW vista_serviciosConTecnicos;
GO

CREATE VIEW vista_serviciosConTecnicos AS
SELECT
    S.IDServicio,
    S.IDTipo,
    TS.Nombre AS Categoria,
    S.Nombre,
    S.Descripcion,
    S.Precio,
    S.TiempoPromedio,
    S.Activo,
    (SELECT COUNT(*)
     FROM TecnicoServicio TSv
     INNER JOIN Tecnico T ON TSv.IDTecnico = T.IDUsuario
     WHERE TSv.IDServicio = S.IDServicio
       AND TSv.Activo = 1
       AND T.Activo = 1
    ) AS CantidadTecnicos
FROM Servicio S
INNER JOIN TipoServicio TS ON S.IDTipo = TS.IDTipoServicio;
GO

-- PROCEDIMIENTO sp_crearTecnico: Crea un técnico: inserta el usuario (Rol = 3) y su fila en Tecnico. Los dos INSERT van dentro de una TRANSACCIÓN:
-- se guardan los dos o ninguno.  Si algo falla, el ROLLBACK deshace todo y no queda un usuario "a medias".

IF OBJECT_ID('sp_crearTecnico', 'P') IS NOT NULL
    DROP PROCEDURE sp_crearTecnico;
GO

CREATE PROCEDURE sp_crearTecnico
    @Nombre VARCHAR(50),
    @Mail VARCHAR(100),
    @Pass VARCHAR(64),
    @Telefono VARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Usuarios WHERE Mail = @Mail)
    BEGIN
        SELECT -1 AS IDUsuario;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Usuarios (Rol, Nombre, Mail, Pass, Telefono)
        VALUES (3, @Nombre, @Mail, @Pass, @Telefono);

        DECLARE @IdNuevo INT = SCOPE_IDENTITY();

        INSERT INTO Tecnico (IDUsuario)
        VALUES (@IdNuevo);

        COMMIT TRANSACTION;
        SELECT @IdNuevo AS IDUsuario;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT -2 AS IDUsuario;
    END CATCH
END
GO

-- PROCEDIMIENTO sp_actualizarServicioTecnico: Activa o desactiva la asignación de un servicio a un técnico.

IF OBJECT_ID('sp_actualizarServicioTecnico', 'P') IS NOT NULL
    DROP PROCEDURE sp_actualizarServicioTecnico;
GO

CREATE PROCEDURE sp_actualizarServicioTecnico
    @IdTecnico INT,
    @IdServicio INT,
    @Activo BIT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM TecnicoServicio
               WHERE IDTecnico = @IdTecnico AND IDServicio = @IdServicio)
    BEGIN
        UPDATE TecnicoServicio
        SET Activo = @Activo
        WHERE IDTecnico = @IdTecnico AND IDServicio = @IdServicio;
    END
    ELSE IF @Activo = 1
    BEGIN
        INSERT INTO TecnicoServicio (IDTecnico, IDServicio, Activo)
        VALUES (@IdTecnico, @IdServicio, 1);
    END
END
GO

-- lista de orbjetos creados 

SELECT name AS Objeto, type_desc AS Tipo
FROM sys.objects
WHERE type IN ('V', 'P', 'TR')
ORDER BY type_desc, name;
GO
