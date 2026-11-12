using System.Collections.Generic;
using Dominio;

namespace Servicio
{
    public class TipoServicioServicio
    {
        public List<TipoServicio> Listar()
        {
            List<TipoServicio> lista = new List<TipoServicio>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta("SELECT IDTipoServicio, Nombre, Descripcion FROM TipoServicio ORDER BY Nombre");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    TipoServicio tipo = new TipoServicio();
                    tipo.IDTipoServicio = (int)datos.Lector["IDTipoServicio"];
                    tipo.Nombre = (string)datos.Lector["Nombre"];
                    tipo.Descripcion = datos.Lector["Descripcion"] as string;
                    lista.Add(tipo);
                }
                return lista;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Crea una categoría nueva
        public void Agregar(string nombre, string descripcion)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta("INSERT INTO TipoServicio (Nombre, Descripcion) VALUES (@nombre, @descripcion)");
                datos.SetParametro("@nombre", nombre);
                datos.SetParametro("@descripcion", descripcion);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
    }

}