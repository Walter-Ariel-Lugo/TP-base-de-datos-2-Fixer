IF EXISTS (SELECT * FROM sys. databases WHERE name = 'DBFixer') BEGIN
    USE MASTER;
    DROP DATABASE DBFixer;
END;

CREATE DATABASE DBFixer
COLLATE Latin1_General_CI_AI;
use DBFixer;
go
create table Rol (
	ID smallint primary key identity (1,1) not null,
	Nombre varchar (50) not null,
);
go
Create table Usuarios (
	IDUsuario int Primary key identity (1,1) not null,
	Rol smallint foreign key references Rol (ID) not null,
	Nombre varchar (50) not null,
	Mail varchar (50) not null,
	Telefono varchar (50) not null
);
go
create table Tecnico (
	IDUsuario int primary key identity not null,
	foreign key (IDUsuario) references Usuarios (IDUsuario),
	Activo bit not null default 1
);
go
create table TipoServicio (
	IDTipoServicio int primary key identity (1,1) not null,
	Nombre varchar (50) not null,
	Descripcion varchar (255) null
);
GO
create table Servicio (
	IDServicio int primary key identity (1,1) not null,
	IDTipo int foreign key references TipoServicio (IDTipoServicio) not null,
	Nombre varchar (50) not null,
	Descripcion varchar (255) null,
	Precio int null,
	TiempoPromedio time null,
	Activo bit not null default 1
);
go
create table TecnicoServicio (
	IDTecnicoServicio int primary key identity (1,1) not null,
	IDTecnico int foreign key references Tecnico (IDUsuario) not null,
	IDServicio int foreign key references Servicio (IDServicio) not null,
	Activo bit not null default 1
);

go
Create table OrdenTrabajo (
	IDOrdenTrabajo int primary key identity (1,1) not null,
	IDCliente int foreign key references Usuarios (IDUsuario) not null,
	IDTecnico int foreign key references Tecnico (IDUsuario) not null,
	FechaSolicitud smalldatetime not null,
	FechaProgramada smalldatetime null,
	Direccion varchar (255) null,
	PresupuestoTotal int not null,
	TiempoEstimadoTotal time not null,
	Observaciones varchar (255) null
);
go
create table DetalleOrden (
	IDDetalleOrden int primary key identity (1,1) not null,
	IDOrden int foreign key references OrdenTrabajo (IDOrdenTrabajo) not null,
	IDServicio int foreign key references Servicio (IDServicio) not null,
	Cantidad int null,
	PrecioUnitario smallmoney not null,
	TiempoUnitario int not null,
	TiempoFinalizacion int null,
	Activo bit not null default 1
);