using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dominio;

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
    }
}