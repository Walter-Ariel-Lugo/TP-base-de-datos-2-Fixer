using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dominio;
using Utils;

namespace Servicio
{
    public class TecnicoNegocio
    {
        // Técnicos disponibles que hacen al menos un servicio activo de esa categoría
        public List<Usuario> ListarDisponiblesPorTipo(int idTipo)
        {
            List<Usuario> lista = new List<Usuario>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT V.IDUsuario, V.Nombre, V.Mail, V.Telefono
                                    FROM vista_tecnicosDisponibles AS V
                                    WHERE V.IDUsuario IN (
                                        SELECT TS.IDTecnico
                                        FROM TecnicoServicio AS TS
                                        INNER JOIN Servicio AS S ON TS.IDServicio = S.IDServicio
                                        WHERE S.IDTipo = @idTipo
                                          AND TS.Activo = 1
                                          AND S.Activo = 1
                                    )
                                    ORDER BY V.Nombre");
                datos.SetParametro("@idTipo", idTipo);
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Usuario tecnico = new Usuario();
                    tecnico.IDUsuario = (int)datos.Lector["IDUsuario"];
                    tecnico.Nombre = (string)datos.Lector["Nombre"];
                    tecnico.Mail = (string)datos.Lector["Mail"];
                    tecnico.Telefono = (string)datos.Lector["Telefono"];
                    tecnico.Rol = 3;
                    lista.Add(tecnico);
                }
                return lista;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // true si el técnico tiene asignado ese servicio (y la asignación está activa)
        public bool HaceServicio(int idTecnico, int idServicio)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT COUNT(*) FROM TecnicoServicio
                            WHERE IDTecnico = @idTecnico
                              AND IDServicio = @idServicio
                              AND Activo = 1");
                datos.SetParametro("@idTecnico", idTecnico);
                datos.SetParametro("@idServicio", idServicio);
                int cantidad = (int)datos.EjecutarEscalar();
                return cantidad > 0;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
        // Todos los técnicos, activos e inactivos, con cuántos servicios activos tienen
        public List<Tecnico> ListarTodos()
        {
            List<Tecnico> lista = new List<Tecnico>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT U.IDUsuario, U.Nombre, U.Mail, U.Telefono, T.Activo, T.Disponible,
                                   (SELECT COUNT(*) FROM TecnicoServicio TS
                                    WHERE TS.IDTecnico = T.IDUsuario AND TS.Activo = 1) AS ServiciosActivos
                            FROM Tecnico T
                            INNER JOIN Usuarios U ON T.IDUsuario = U.IDUsuario
                            ORDER BY U.Nombre");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Tecnico t = new Tecnico();
                    t.IDUsuario = (int)datos.Lector["IDUsuario"];
                    t.Nombre = (string)datos.Lector["Nombre"];
                    t.Mail = (string)datos.Lector["Mail"];
                    t.Telefono = (string)datos.Lector["Telefono"];
                    t.Activo = (bool)datos.Lector["Activo"];
                    t.Disponible = (bool)datos.Lector["Disponible"];
                    t.ServiciosActivos = (int)datos.Lector["ServiciosActivos"];
                    t.Rol = 3;
                    lista.Add(t);
                }
                return lista;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Da de baja un técnico.
        // este DELETE NO borra. El trigger trg_eliminarTecnico lo convierte en Activo = 0,
        // y eso dispara trg_desactivarServiciosTecnico, que desactiva sus servicios.
        public void DarDeBaja(int idTecnico)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta("DELETE FROM Tecnico WHERE IDUsuario = @idTecnico");
                datos.SetParametro("@idTecnico", idTecnico);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // ¿El técnico está disponible para recibir trabajos?
        public bool EstaDisponible(int idTecnico)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta("SELECT Disponible FROM Tecnico WHERE IDUsuario = @idTecnico");
                datos.SetParametro("@idTecnico", idTecnico);
                return (bool)datos.EjecutarEscalar();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // El técnico se marca disponible (true) o no disponible (false)
        public void CambiarDisponibilidad(int idTecnico, bool disponible)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta("UPDATE Tecnico SET Disponible = @disponible WHERE IDUsuario = @idTecnico");
                datos.SetParametro("@disponible", disponible);
                datos.SetParametro("@idTecnico", idTecnico);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Crea el usuario y su fila de técnico con sp_crearTecnico.
        // Devuelve el ID nuevo, -1 si el mail ya existe o -2 si hubo un error.
        public int Crear(string nombre, string mail, string password, string telefono)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetProcedimiento("sp_crearTecnico");
                datos.SetParametro("@Nombre", nombre);
                datos.SetParametro("@Mail", mail);
                datos.SetParametro("@Pass", Seguridad.Encriptar(password));
                datos.SetParametro("@Telefono", telefono);
                return Convert.ToInt32(datos.EjecutarEscalar());
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Asigna un servicio a un técnico
        public void AsignarServicio(int idTecnico, int idServicio)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta("INSERT INTO TecnicoServicio (IDTecnico, IDServicio) VALUES (@idTecnico, @idServicio)");
                datos.SetParametro("@idTecnico", idTecnico);
                datos.SetParametro("@idServicio", idServicio);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // IDs de los servicios que el técnico tiene activos
        public List<int> ServiciosAsignados(int idTecnico)
        {
            List<int> ids = new List<int>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT IDServicio FROM TecnicoServicio
                            WHERE IDTecnico = @idTecnico AND Activo = 1");
                datos.SetParametro("@idTecnico", idTecnico);
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    ids.Add((int)datos.Lector["IDServicio"]);
                }
                return ids;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Activa (o crea) o desactiva la asignación de un servicio (usa sp_actualizarServicioTecnico)
        public void ActualizarServicio(int idTecnico, int idServicio, bool activo)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetProcedimiento("sp_actualizarServicioTecnico");
                datos.SetParametro("@IdTecnico", idTecnico);
                datos.SetParametro("@IdServicio", idServicio);
                datos.SetParametro("@Activo", activo);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
    }
}