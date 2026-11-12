using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Servicio
{
    public class ServicioServicio
    {
        // Devuelve los servicios activos de una categoría
        public List<Dominio.Servicio> ListarPorTipo(int idTipo)
        {
            List<Dominio.Servicio> lista = new List<Dominio.Servicio>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT IDServicio, IDTipo, Nombre, Descripcion, Precio, TiempoPromedio, Activo  FROM Servicio
                        WHERE IDTipo = @idTipo AND Activo = 1  ORDER BY Nombre");
                datos.SetParametro("@idTipo", idTipo);
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Dominio.Servicio s = new Dominio.Servicio();
                    s.IDServicio = (int)datos.Lector["IDServicio"];
                    s.IDTipo = (int)datos.Lector["IDTipo"];
                    s.Nombre = (string)datos.Lector["Nombre"];
                    s.Descripcion = datos.Lector["Descripcion"] as string;
                    s.Precio = (decimal)datos.Lector["Precio"];
                    s.TiempoPromedio = (int)datos.Lector["TiempoPromedio"];
                    s.Activo = (bool)datos.Lector["Activo"];
                    lista.Add(s);
                }
                return lista;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
        // Ranking de servicios más contratados (usa vista_serviciosMasContratados)
        public List<Dominio.ServicioContratado> ListarMasContratados()
        {
            List<Dominio.ServicioContratado> lista = new List<Dominio.ServicioContratado>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT IDServicio, Servicio, Categoria, Precio, TiempoPromedio, VecesContratado
                            FROM vista_serviciosMasContratados
                            ORDER BY VecesContratado DESC");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Dominio.ServicioContratado s = new Dominio.ServicioContratado();
                    s.IDServicio = (int)datos.Lector["IDServicio"];
                    s.Servicio = (string)datos.Lector["Servicio"];
                    s.Categoria = (string)datos.Lector["Categoria"];
                    s.Precio = (decimal)datos.Lector["Precio"];
                    s.TiempoPromedio = (int)datos.Lector["TiempoPromedio"];
                    s.VecesContratado = (int)datos.Lector["VecesContratado"];
                    lista.Add(s);
                }
                return lista;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Todos los servicios, con cuántos técnicos activos los hacen (usa vista_serviciosConTecnicos)
        public List<Dominio.Servicio> ListarTodos()
        {
            List<Dominio.Servicio> lista = new List<Dominio.Servicio>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT IDServicio, IDTipo, Nombre, Descripcion, Precio,
                                   TiempoPromedio, Activo, CantidadTecnicos
                            FROM vista_serviciosConTecnicos
                            ORDER BY Nombre");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Dominio.Servicio s = new Dominio.Servicio();
                    s.IDServicio = (int)datos.Lector["IDServicio"];
                    s.IDTipo = (int)datos.Lector["IDTipo"];
                    s.Nombre = (string)datos.Lector["Nombre"];
                    s.Descripcion = datos.Lector["Descripcion"] as string;
                    s.Precio = (decimal)datos.Lector["Precio"];
                    s.TiempoPromedio = (int)datos.Lector["TiempoPromedio"];
                    s.Activo = (bool)datos.Lector["Activo"];
                    s.CantidadTecnicos = (int)datos.Lector["CantidadTecnicos"];
                    lista.Add(s);
                }
                return lista;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Crea un servicio nuevo (Activo toma el valor por defecto: 1)
        public void Agregar(Dominio.Servicio s)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"INSERT INTO Servicio (IDTipo, Nombre, Descripcion, Precio, TiempoPromedio)
                            VALUES (@idTipo, @nombre, @descripcion, @precio, @tiempo)");
                datos.SetParametro("@idTipo", s.IDTipo);
                datos.SetParametro("@nombre", s.Nombre);
                datos.SetParametro("@descripcion", s.Descripcion);
                datos.SetParametro("@precio", s.Precio);
                datos.SetParametro("@tiempo", s.TiempoPromedio);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Baja lógica (activo = false) o alta (activo = true) de un servicio
        public void CambiarEstado(int idServicio, bool activo)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta("UPDATE Servicio SET Activo = @activo WHERE IDServicio = @idServicio");
                datos.SetParametro("@activo", activo);
                datos.SetParametro("@idServicio", idServicio);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
    }
}