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
    }
}