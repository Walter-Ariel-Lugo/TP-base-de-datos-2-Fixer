# Fixer

Plataforma web para contratar técnicos que realizan pequeños arreglos del hogar, con precio y tiempo definidos desde el principio.

**Trabajo Práctico Integrador — Base de Datos II**
Tecnicatura Universitaria en Programación · UTN Facultad Regional General Pacheco · 2026

**Equipo 14**
- Walter Ariel Lugo — Legajo 30467
- Mateo Tomás Herrera — Legajo 31664

---

## Qué hace

El cliente elige una categoría y arma su pedido con uno o más servicios de un catálogo. El sistema le propone solo los técnicos activos y disponibles que pueden hacer todos los servicios elegidos. Al confirmar, la base de datos calcula automáticamente el presupuesto total y el tiempo estimado.

| Rol | Funciones |
| --- | --- |
| **Cliente** | Se registra, contrata servicios eligiendo técnico, dirección y fecha, y consulta sus órdenes y su estado. |
| **Técnico** | Consulta sus órdenes (todas o filtradas por estado), las pasa a Iniciada, Finalizada o Cancelada con una observación, y se marca como disponible o no disponible. |
| **Administrador** | Crea categorías y servicios, los activa o desactiva, da de alta y de baja técnicos, les asigna servicios, consulta clientes y reportes, y accede al panel de cualquier técnico. |

## Tecnologías

| Parte | Tecnología |
| --- | --- |
| Base de datos | SQL Server Express (T-SQL) |
| Aplicación web | C# · .NET Framework 4.8 · ASP.NET Web Forms |
| Acceso a datos | ADO.NET con consultas parametrizadas |
| Diseño | Bootstrap 5.3 (CDN) |
| Seguridad | Contraseñas encriptadas con SHA-256 |
| Herramientas | Visual Studio 2022 · SQL Server Management Studio · Git y GitHub |

## Base de datos

### Tablas (8)

`Rol` · `Usuarios` · `Tecnico` · `TipoServicio` · `Servicio` · `TecnicoServicio` · `OrdenTrabajo` · `DetalleOrden`

Decisiones de diseño:
- `TecnicoServicio` y `DetalleOrden` tienen **clave primaria compuesta**, para evitar asignaciones y servicios repetidos.
- `DetalleOrden` **copia el precio y el tiempo** del servicio al momento de contratar, así un cambio de precio no altera órdenes anteriores.
- Técnicos y servicios usan **baja lógica** (columna `Activo`) para conservar el historial.
- Restricciones `CHECK` en estados, precios, tiempos y cantidades, y `UNIQUE` en el mail.

### Vistas, procedimientos almacenados y triggers (13)

| Tipo | Objeto | Qué hace |
| --- | --- | --- |
| Vista | `vista_tecnicosDisponibles` | Técnicos activos y disponibles, para proponerlos al cliente. |
| Vista | `vista_ordenesDetalle` | Cada orden con el nombre del cliente y del técnico, estado, fechas y totales. |
| Vista | `vista_serviciosMasContratados` | Ranking de servicios activos según cuántas veces se contrataron. |
| Vista | `vista_serviciosConTecnicos` | Cada servicio con la cantidad de técnicos activos que lo realizan. |
| Procedimiento (acción) | `sp_agregarServicioAOrden` | Agrega un servicio a una orden copiando su precio y tiempo actuales; no lo repite. |
| Procedimiento (reporte) | `sp_ordenesPorTecnico` | Órdenes de un técnico, de un estado o de todos, ordenadas por fecha programada. |
| Procedimiento | `sp_crearTecnico` | Crea el usuario y el técnico dentro de una **transacción** (todo o nada). |
| Procedimiento | `sp_actualizarServicioTecnico` | Asigna o quita un servicio a un técnico (actualiza si existe, inserta si no). |
| Procedimiento | `sp_registrarCliente` | Registra un cliente nuevo validando que el mail no exista. |
| Procedimiento | `sp_cambiarEstadoOrden` | Cambia el estado de una orden validando las transiciones permitidas y guarda la fecha de finalización. |
| Trigger | `trg_recalcularPresupuesto` | `AFTER INSERT` en `DetalleOrden`: recalcula el presupuesto y el tiempo total de la orden. |
| Trigger | `trg_eliminarTecnico` | `INSTEAD OF DELETE` en `Tecnico`: en lugar de borrar, hace la baja lógica. |
| Trigger | `trg_desactivarServiciosTecnico` | `AFTER UPDATE` en `Tecnico`: si el técnico pasa a inactivo, desactiva sus servicios (se dispara en cadena con el anterior). |

## Estructura del repositorio

```
├── 1 - Script creacion de BD.sql               Crea la base DBFixer y sus 8 tablas
├── 2 - Carga de datos.sql                      Datos de prueba
├── 3 - Vistas, procedimientos y triggers.sql   Los 13 objetos de la base
├── TP base de datos 2 Fixer.sln                Solución de Visual Studio
├── Dominio/                                    Clases del modelo (Usuario, Tecnico, Servicio, OrdenTrabajo…)
├── Servicio/                                   Acceso a datos (AccesoDatos) y lógica de negocio
├── Utils/                                      Encriptación de contraseñas
└── TP-Fixer-web/                               Aplicación web (páginas .aspx)
```

## Cómo ejecutarlo

**Requisitos:** SQL Server (Express alcanza), SQL Server Management Studio y Visual Studio 2022 con la carga de trabajo "Desarrollo de ASP.NET y web".

1. **Crear la base:** abrir y ejecutar en SSMS, en este orden:
   1. `1 - Script creacion de BD.sql`
   2. `2 - Carga de datos.sql`
   3. `3 - Vistas, procedimientos y triggers.sql`

   El script 1 borra la base si ya existe, así que los tres se pueden volver a correr para dejar los datos como al principio.

2. **Configurar la conexión:** en `TP-Fixer-web/Web.config`, ajustar el servidor si no es `.\SQLEXPRESS`:

   ```xml
   <add name="FixerDB"
        connectionString="Server=.\SQLEXPRESS;Database=DBFixer;Integrated Security=True;" />
   ```

3. **Ejecutar la web:** abrir `TP base de datos 2 Fixer.sln` en Visual Studio, establecer `TP-Fixer-web` como proyecto de inicio y presionar **F5**.

## Usuarios de prueba

Todos tienen la contraseña **`1234`**.

| Rol | Mail |
| --- | --- |
| Administrador | `admin@fixer.com` |
| Cliente | `cliente@fixer.com` |
| Cliente | `laura@fixer.com` |
| Técnico | `tecnico@fixer.com` |
| Técnico | `juan@fixer.com` |

## Video de presentación

[Ver el video] https://drive.google.com/file/d/1CtXjWm1G36qe7IGuP38EM-hMZqQE8MIi/view?usp=sharing
