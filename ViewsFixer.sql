--mateo 
create view vista_serviciosMasContratados as
select
DeO.IDServicio,
TS.Nombre,
S.Precio,
S.TiempoPromedio
from DetalleOrden as DeO inner join Servicio as S on DeO.IDServicio = S.IDServicio
left join TipoServicio as TS on TS.IDTipoServicio = S.IDTipo
order by select count (DeO.IDServicio);
where S.Activo = 1;
group by DeO.IDServicio, TS.Nombre; 

go

USE DBFixer;
GO
-- mateo
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
-- modifica manualmente al usuario tecnio de prueba como no disponible para provar la vista
   UPDATE Tecnico SET Disponible = 0 WHERE IDUsuario = 3;
   UPDATE Tecnico SET Disponible = 1 WHERE IDUsuario = 3;

-- SELECT * FROM vista_tecnicosDisponibles;


--mateo 
create view vista_ordenesDetalle as
select
OT.IDOrdenTrabajo,
U.Nombre,
U.Nombre,
DeO.Activo,
OT.FechaSolicitud,
OT.FechaProgramada,
OT.PresupuestoTotal,
OT.TiempoEstimadoTotal
from OrdenTrabajo as OT inner join Usuarios as U on OT.IDCliente = IDUsuario and OT.IDTecnico = U.IDUsuario
left join DetalleOrden as DeO on OT.IDOrdenTrabajo = DeO.IDOrden
group by OT.IDOrdenTrabajo;

-- version con cambio nesesarios para el programa
USE DBFixer;
GO

IF OBJECT_ID('vista_ordenesDetalle') IS NOT NULL
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

SELECT * FROM vista_ordenesDetalle;
--walter procedimiento almacenado de reporte 

CREATE PROCEDURE sp_agregarServicioAOrden
    @IdOrden INT,
    @IdServicio INT,
    @Cantidad INT
AS
BEGIN
    -- Si el servicio ya está en la orden, no se repite
    IF EXISTS (SELECT IDServicio FROM DetalleOrden
               WHERE IDOrden = @IdOrden AND IDServicio = @IdServicio)
    BEGIN
        PRINT 'Este servicio ya está en la orden.';
        RETURN;
    END

    -- Tomar el precio y el tiempo actuales del servicio
    DECLARE @Precio DECIMAL(10,2);
    DECLARE @Tiempo INT;
    SELECT @Precio = Precio, @Tiempo = TiempoPromedio
    FROM Servicio
    WHERE IDServicio = @IdServicio AND Activo = 1;

    -- Si no se encontró, el servicio no existe o está dado de baja
    IF @Precio IS NULL
    BEGIN
        PRINT 'El servicio no existe o está dado de baja.';
        RETURN;
    END

    --  Agregar el servicio a la orden
    INSERT INTO DetalleOrden (IDOrden, IDServicio, Cantidad, PrecioUnitario, TiempoUnitario)
    VALUES (@IdOrden, @IdServicio, @Cantidad, @Precio, @Tiempo);

    PRINT 'Servicio agregado a la orden.';
END
Go
-- walter trigger  recalcula sumando los tiemo y montos de cada servicio que se agrega 

CREATE TRIGGER trg_recalcularPresupuesto
ON DetalleOrden
AFTER INSERT
AS
BEGIN
    -- usamos variables , Orden a la que se le agregó el servicio
    DECLARE @IdOrden INT;
    SELECT @IdOrden = IDOrden FROM inserted;

    UPDATE OrdenTrabajo
    SET PresupuestoTotal = (SELECT SUM(PrecioUnitario * Cantidad)
                            FROM DetalleOrden WHERE IDOrden = @IdOrden),
        TiempoEstimadoTotal = (SELECT SUM(TiempoUnitario * Cantidad)
                               FROM DetalleOrden WHERE IDOrden = @IdOrden)
    WHERE IDOrdenTrabajo = @IdOrden;
END
GO

USE DBFixer;
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

USE DBFixer;
GO

-- 1. Crear una orden vacía: cliente 2, técnico 3, totales en 0
INSERT INTO OrdenTrabajo (IDCliente, IDTecnico, FechaSolicitud, FechaProgramada,
                          Direccion, PresupuestoTotal, TiempoEstimadoTotal, Observaciones)
VALUES (2, 3, GETDATE(), DATEADD(DAY, 2, GETDATE()),
        'Av. Siempre Viva 742, Pilar', 0, 0, 'Tocar timbre 2B');
GO

-- 2. Agregarle servicios con el procedimiento de acción
EXEC sp_agregarServicioAOrden @IdOrden = 1, @IdServicio = 1, @Cantidad = 1;   -- cuerito: 8.000 / 45 min
EXEC sp_agregarServicioAOrden @IdOrden = 1, @IdServicio = 3, @Cantidad = 2;   -- 2 tomas: 14.000 / 60 min
EXEC sp_agregarServicioAOrden @IdOrden = 1, @IdServicio = 3, @Cantidad = 1;   -- repetido: no lo agrega
GO

-- 3. El trigger ya recalculó los totales
SELECT IDOrdenTrabajo, Estado, PresupuestoTotal, TiempoEstimadoTotal FROM OrdenTrabajo;
-- Esperado: PresupuestoTotal = 22000.00, TiempoEstimadoTotal = 105

-- 4. El técnico ve la orden con el procedimiento de reporte
EXEC sp_ordenesPorTecnico @IdTecnico = 3, @Estado = 'Pendiente';

-- lista que procedimientos tengo 
USE DBFixer;
SELECT name FROM sys.procedures;
 -- borramos las ordenes de prueba 
 USE DBFixer;
DELETE FROM DetalleOrden;
DELETE FROM OrdenTrabajo;
DBCC CHECKIDENT ('OrdenTrabajo', RESEED, 0);

SELECT IDOrden, IDServicio, Cantidad FROM DetalleOrden WHERE IDOrden = 2;