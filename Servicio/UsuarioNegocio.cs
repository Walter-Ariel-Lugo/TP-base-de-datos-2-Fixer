using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dominio;
using Utils;

namespace Servicio
{
    public class UsuarioNegocio
    {
        // Devuelve el usuario si el mail y la contraseña son correctos; si no, null
        public Usuario Login(string mail, string password)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT u.IDUsuario, u.Rol, u.Nombre, u.Mail, u.Telefono
                                    FROM Usuarios u
                                    LEFT JOIN Tecnico t ON t.IDUsuario = u.IDUsuario
                                    WHERE u.Mail = @mail
                                      AND u.Pass = @pass
                                      AND (t.IDUsuario IS NULL OR t.Activo = 1)");
                datos.SetParametro("@mail", mail);
                datos.SetParametro("@pass", Seguridad.Encriptar(password));
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                {
                    Usuario usuario = new Usuario();
                    usuario.IDUsuario = (int)datos.Lector["IDUsuario"];
                    usuario.Rol = (short)datos.Lector["Rol"];
                    usuario.Nombre = (string)datos.Lector["Nombre"];
                    usuario.Mail = (string)datos.Lector["Mail"];
                    usuario.Telefono = (string)datos.Lector["Telefono"];
                    return usuario;
                }

                return null;    // mail o contraseña incorrectos
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
    }
}
