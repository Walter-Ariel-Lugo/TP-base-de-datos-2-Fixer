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

create view vista_tecnicosDisponibles as
select
T.IDUsuario,
U.Nombre,
U.Mail,
U.Telefono

from Tecnico as T inner join Usuarios as U on T.IDUsuario = U.IDUsuario
where T.Activo = 1;

go

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