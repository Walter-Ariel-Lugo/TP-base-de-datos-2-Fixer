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
    }
}