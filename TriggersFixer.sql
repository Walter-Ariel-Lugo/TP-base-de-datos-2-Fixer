

create trigger trg_eliminarTecnico 
on Tecnico
INSTEAD OF DELETE
as
begin
	update Tecnico set Activo = 0 where IDUsuario in (select IDUsuario from deleted);
end


create trigger trg_desactivarServiciosTecnico
on Tecnico
AFTER UPDATE
as 
begin
	update TecnicoServicio set Activo = 0 where IDTecnico in (select IDUsuario from deleted);
end