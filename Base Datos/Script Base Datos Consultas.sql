CREATE DATABASE MANTENIMIENTO
GO
USE MANTENIMIENTO
GO


create table EmployeeDetails (
EmpId int identity ,
EmpName varchar(50),
DateOfBirth date,
EmailId varchar(50),
Gender nchar(10),
Address varchar(100),
PinCode varchar(100)
)

create table tipo_documento (
id int identity primary key,
nombre varchar(10),
)

go

create table estado (
id int identity primary key,
nombre varchar(10),
)
go

create table tipo_producto (
id int identity primary key,
nombre varchar(10),
)

go

Create table cliente (
documento bigint primary key,
primer_nombre varchar(50), 
segundo_nombre varchar(50),
primer_apellido varchar(50),
segundo_apellido varchar(50), 
tipo_documento_id int FOREIGN KEY REFERENCES tipo_documento (id), 
celular int, 
dirección varchar(100),
correo_electrónico varchar(100)
)

go

Create table mecanico (
documento bigint primary key,
primer_nombre varchar(50), 
segundo_nombre varchar(50),
primer_apellido varchar(50),
segundo_apellido varchar(50), 
tipo_documento_id int FOREIGN KEY REFERENCES tipo_documento (id), 
celular int, 
dirección varchar(100),
estado varchar(5),
correo_electrónico varchar(100)
)

go

create table producto(
id int identity primary key,
nombre varchar(50),
descripcion varchar(50),
tipo_producto_id int FOREIGN KEY REFERENCES tipo_producto (id),
unidades int,
valor numeric(13,2) 
)

go

create table mantenimiento (
id int identity primary key,
tienda varchar(10),
fecha date,
cliente_id bigint FOREIGN KEY REFERENCES cliente (documento),
mecanico_id bigint FOREIGN KEY REFERENCES mecanico (documento),
estado_id int FOREIGN KEY REFERENCES estado (id),
presupuesto numeric(10),
total numeric(13,2)
)

go

create table mantenimientoItem (
id int identity primary key,
mantenimiento_id int FOREIGN KEY REFERENCES mantenimiento (id),
producto_id int FOREIGN KEY REFERENCES producto (id),
unidades int,
subtotal numeric(13,2),
descuento numeric(13,2),
impuestos numeric(13,2),
total numeric(13,2))

go
--NOTA: la tabla mantenimiento es el cabezote de la factura el total que se maneja ahi deberia ser  el total de sus items versus descuentos e impuestos respectivos



-- Procedimiento 
CREATE PROCEDURE descuento_inventario 
	@producto_id int, 
	@unidades int
AS
BEGIN
 update producto set unidades = unidades -@unidades where id = @producto_id
END




----Consultas
--1
Select  cliente.documento,
        CONCAT(cliente.primer_nombre, '' ,cliente.primer_apellido) Nombre
		from mantenimiento  
		join cliente on cliente.documento = mantenimiento.cliente_id
		where fecha  > DATEADD(dd,-60,GETDATE())
group by  documento,primer_nombre,primer_apellido
Having SUM(mantenimiento.total) = 100000


--2

Select  top(100)
        producto.id,
        producto.nombre Nombre,
		SUM(mantenimientoItem.total) total
		from mantenimiento 
		join mantenimientoItem on mantenimientoItem.mantenimiento_id = mantenimiento.id 
		join producto on producto.id = mantenimientoItem.producto_id
		where fecha  > DATEADD(dd,-30,GETDATE())
group by  producto.id,
          producto.nombre
order by SUM(mantenimientoItem.total) desc


-- 3

Select  tienda,
        producto.id,
        producto.nombre Nombre,
		SUM(mantenimientoItem.unidades) unidades
		from mantenimiento 
		join mantenimientoItem on mantenimientoItem.mantenimiento_id = mantenimiento.id 
		join producto on producto.id = mantenimientoItem.producto_id
		where fecha  > DATEADD(dd,-60,GETDATE())
		and  producto_id = 100
group by  producto.id,
          producto.nombre,
		  tienda
having SUM(mantenimientoItem.unidades) > 100
