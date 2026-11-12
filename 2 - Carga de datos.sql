
USE DBFixer;
GO

INSERT INTO Rol (Nombre) VALUES ('Administrador');
INSERT INTO Rol (Nombre) VALUES ('Cliente');
INSERT INTO Rol (Nombre) VALUES ('Tecnico');
GO

   ------------------------------------------------------------------------------------- */
INSERT INTO Usuarios (Rol, Nombre, Mail, Pass, Telefono)
VALUES (1, 'Admin Fixer', 'admin@fixer.com', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', '1100000001');

INSERT INTO Usuarios (Rol, Nombre, Mail, Pass, Telefono)
VALUES (2, 'Cliente Demo', 'cliente@fixer.com', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', '1100000002');

INSERT INTO Usuarios (Rol, Nombre, Mail, Pass, Telefono)
VALUES (3, 'Tecnico Demo', 'tecnico@fixer.com', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', '1100000003');

INSERT INTO Usuarios (Rol, Nombre, Mail, Pass, Telefono)
VALUES (3, 'Juan Pérez', 'juan@fixer.com', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', '1100000004');

INSERT INTO Usuarios (Rol, Nombre, Mail, Pass, Telefono)
VALUES (2, 'Laura Gómez', 'laura@fixer.com', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', '1100000005');
GO

INSERT INTO Tecnico (IDUsuario) VALUES (3);   -- Tecnico Demo
INSERT INTO Tecnico (IDUsuario) VALUES (4);   -- Juan Pérez
GO

INSERT INTO TipoServicio (Nombre, Descripcion) VALUES ('Plomería', 'Pérdidas, canillas, destapaciones');
INSERT INTO TipoServicio (Nombre, Descripcion) VALUES ('Electricidad', 'Enchufes, lámparas, artefactos');
INSERT INTO TipoServicio (Nombre, Descripcion) VALUES ('Jardinería', 'Poda, corte de césped');
INSERT INTO TipoServicio (Nombre, Descripcion) VALUES ('Limpieza', 'Limpieza profunda, vidrios, filtros');
GO

INSERT INTO Servicio (IDTipo, Nombre, Descripcion, Precio, TiempoPromedio)
VALUES (1, 'Cambiar cuerito de canilla', 'Reemplazo del cuerito para cortar la pérdida', 8000, 45);

INSERT INTO Servicio (IDTipo, Nombre, Descripcion, Precio, TiempoPromedio)
VALUES (1, 'Cambiar canilla', 'Canilla provista por el cliente', 12000, 60);

INSERT INTO Servicio (IDTipo, Nombre, Descripcion, Precio, TiempoPromedio)
VALUES (2, 'Cambiar tomacorriente', 'Reemplazo de toma existente', 7000, 30);

INSERT INTO Servicio (IDTipo, Nombre, Descripcion, Precio, TiempoPromedio)
VALUES (2, 'Instalar ventilador de techo', 'Con conexión a llave existente', 20000, 90);

INSERT INTO Servicio (IDTipo, Nombre, Descripcion, Precio, TiempoPromedio)
VALUES (3, 'Corte de césped', 'Hasta 100 m²', 15000, 120);

INSERT INTO Servicio (IDTipo, Nombre, Descripcion, Precio, TiempoPromedio)
VALUES (4, 'Limpieza de vidrios', 'Ventanas de un ambiente', 9000, 60);
GO

INSERT INTO TecnicoServicio (IDTecnico, IDServicio) VALUES (3, 1);
INSERT INTO TecnicoServicio (IDTecnico, IDServicio) VALUES (3, 2);
INSERT INTO TecnicoServicio (IDTecnico, IDServicio) VALUES (3, 3);
INSERT INTO TecnicoServicio (IDTecnico, IDServicio) VALUES (3, 4);

INSERT INTO TecnicoServicio (IDTecnico, IDServicio) VALUES (4, 1);
INSERT INTO TecnicoServicio (IDTecnico, IDServicio) VALUES (4, 2);
INSERT INTO TecnicoServicio (IDTecnico, IDServicio) VALUES (4, 5);
GO

INSERT INTO OrdenTrabajo (IDCliente, IDTecnico, FechaSolicitud, FechaProgramada, FechaFinalizacion,
                          Estado, Direccion, PresupuestoTotal, TiempoEstimadoTotal, Observaciones)
VALUES (2, 3, '20261101 10:00', '20261103 09:00', '20261103 11:00',
        'Finalizada', 'Av. Siempre Viva 742, Pilar', 20000, 105, 'Tocar timbre 2B');

INSERT INTO OrdenTrabajo (IDCliente, IDTecnico, FechaSolicitud, FechaProgramada, FechaFinalizacion,
                          Estado, Direccion, PresupuestoTotal, TiempoEstimadoTotal, Observaciones)
VALUES (5, 3, '20261110 15:00', '20261120 10:00', NULL,
        'Pendiente', 'Belgrano 1250, Pilar', 14000, 60, NULL);

INSERT INTO OrdenTrabajo (IDCliente, IDTecnico, FechaSolicitud, FechaProgramada, FechaFinalizacion,
                          Estado, Direccion, PresupuestoTotal, TiempoEstimadoTotal, Observaciones)
VALUES (2, 4, '20261109 18:00', '20261112 14:00', NULL,
        'Iniciada', 'Av. Siempre Viva 742, Pilar', 15000, 120, 'Traer bordeadora');
GO

INSERT INTO DetalleOrden (IDOrden, IDServicio, Cantidad, PrecioUnitario, TiempoUnitario) VALUES (1, 2, 1, 12000, 60);
INSERT INTO DetalleOrden (IDOrden, IDServicio, Cantidad, PrecioUnitario, TiempoUnitario) VALUES (1, 1, 1, 8000, 45);
INSERT INTO DetalleOrden (IDOrden, IDServicio, Cantidad, PrecioUnitario, TiempoUnitario) VALUES (2, 3, 2, 7000, 30);
INSERT INTO DetalleOrden (IDOrden, IDServicio, Cantidad, PrecioUnitario, TiempoUnitario) VALUES (3, 5, 1, 15000, 120);
GO

SELECT * FROM Rol;
SELECT IDUsuario, Rol, Nombre, Mail, Telefono FROM Usuarios;
SELECT * FROM Tecnico;
SELECT * FROM TipoServicio;
SELECT * FROM Servicio;
SELECT * FROM TecnicoServicio;
SELECT * FROM OrdenTrabajo;
SELECT * FROM DetalleOrden;
GO
