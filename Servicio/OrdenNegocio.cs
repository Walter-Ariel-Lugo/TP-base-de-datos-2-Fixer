using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dominio;

namespace Servicio
{
    public class OrdenNegocio
    {
        // 1. Crea la orden vacía (totales en 0) y devuelve su número
        public int CrearOrden(int idCliente, int idTecnico, DateTime fechaProgramada,
                              string direccion, string observaciones)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"INSERT INTO OrdenTrabajo
                                        (IDCliente, IDTecnico, FechaSolicitud, FechaProgramada,
                                         Direccion, PresupuestoTotal, TiempoEstimadoTotal, Observaciones)
                                    VALUES
                                        (@idCliente, @idTecnico, GETDATE(), @fechaProgramada,
                                         @direccion, 0, 0, @observaciones);
                                    SELECT SCOPE_IDENTITY();");
                datos.SetParametro("@idCliente", idCliente);
                datos.SetParametro("@idTecnico", idTecnico);
                datos.SetParametro("@fechaProgramada", fechaProgramada);
                datos.SetParametro("@direccion", direccion);
                datos.SetParametro("@observaciones", observaciones);

                return Convert.ToInt32(datos.EjecutarEscalar());
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // 2. Agrega un servicio a la orden usando el SP (que dispara el trigger)
        public void AgregarServicio(int idOrden, int idServicio, int cantidad)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetProcedimiento("sp_agregarServicioAOrden");
                datos.SetParametro("@IdOrden", idOrden);
                datos.SetParametro("@IdServicio", idServicio);
                datos.SetParametro("@Cantidad", cantidad);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // 3. Lee los totales ya calculados por el trigger
        public OrdenTrabajo ObtenerTotales(int idOrden)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT IDOrdenTrabajo, Estado, PresupuestoTotal, TiempoEstimadoTotal
                                    FROM OrdenTrabajo
                                    WHERE IDOrdenTrabajo = @idOrden");
                datos.SetParametro("@idOrden", idOrden);
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                {
                    OrdenTrabajo orden = new OrdenTrabajo();
                    orden.IDOrdenTrabajo = (int)datos.Lector["IDOrdenTrabajo"];
                    orden.Estado = (string)datos.Lector["Estado"];
                    orden.PresupuestoTotal = (decimal)datos.Lector["PresupuestoTotal"];
                    orden.TiempoEstimadoTotal = (int)datos.Lector["TiempoEstimadoTotal"];
                    return orden;
                }
                return null;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Órdenes de un cliente, más nuevas primero (usa vista_ordenesDetalle)
        public List<OrdenTrabajo> ListarPorCliente(int idCliente)
        {
            List<OrdenTrabajo> lista = new List<OrdenTrabajo>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT IDOrdenTrabajo, IDCliente, Cliente, IDTecnico, Tecnico, Estado,
                                   FechaSolicitud, FechaProgramada, FechaFinalizacion,
                                   PresupuestoTotal, TiempoEstimadoTotal
                            FROM vista_ordenesDetalle
                            WHERE IDCliente = @idCliente
                            ORDER BY FechaSolicitud DESC");
                datos.SetParametro("@idCliente", idCliente);
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    OrdenTrabajo o = new OrdenTrabajo();
                    o.IDOrdenTrabajo = (int)datos.Lector["IDOrdenTrabajo"];
                    o.IDCliente = (int)datos.Lector["IDCliente"];
                    o.Cliente = (string)datos.Lector["Cliente"];
                    o.IDTecnico = (int)datos.Lector["IDTecnico"];
                    o.Tecnico = (string)datos.Lector["Tecnico"];
                    o.Estado = (string)datos.Lector["Estado"];
                    o.FechaSolicitud = (DateTime)datos.Lector["FechaSolicitud"];
                    o.FechaProgramada = datos.Lector["FechaProgramada"] as DateTime?;
                    o.FechaFinalizacion = datos.Lector["FechaFinalizacion"] as DateTime?;
                    o.PresupuestoTotal = (decimal)datos.Lector["PresupuestoTotal"];
                    o.TiempoEstimadoTotal = (int)datos.Lector["TiempoEstimadoTotal"];
                    lista.Add(o);
                }
                return lista;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
        // Órdenes de un técnico en un estado (usa el SP de reporte sp_ordenesPorTecnico)
        public List<OrdenTrabajo> ListarPorTecnico(int idTecnico, string estado)
        {
            List<OrdenTrabajo> lista = new List<OrdenTrabajo>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetProcedimiento("sp_ordenesPorTecnico");
                datos.SetParametro("@IdTecnico", idTecnico);
                datos.SetParametro("@Estado", estado);
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    OrdenTrabajo o = new OrdenTrabajo();
                    o.IDOrdenTrabajo = (int)datos.Lector["IDOrdenTrabajo"];
                    o.Cliente = (string)datos.Lector["Cliente"];
                    o.Telefono = (string)datos.Lector["Telefono"];
                    o.Direccion = datos.Lector["Direccion"] as string;
                    o.FechaProgramada = datos.Lector["FechaProgramada"] as DateTime?;
                    o.Estado = (string)datos.Lector["Estado"];
                    o.PresupuestoTotal = (decimal)datos.Lector["PresupuestoTotal"];
                    o.TiempoEstimadoTotal = (int)datos.Lector["TiempoEstimadoTotal"];
                    o.Observaciones = datos.Lector["Observaciones"] as string;
                    lista.Add(o);
                }
                return lista;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
    }
}