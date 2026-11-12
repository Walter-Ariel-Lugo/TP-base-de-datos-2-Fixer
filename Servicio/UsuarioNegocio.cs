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
        // Todos los clientes, con cuántas órdenes hicieron y cuánto contrataron
        public List<Cliente> ListarClientes()
        {
            List<Cliente> lista = new List<Cliente>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta(@"SELECT U.IDUsuario, U.Nombre, U.Mail, U.Telefono,
                                   (SELECT COUNT(*)
                                    FROM OrdenTrabajo OT
                                    WHERE OT.IDCliente = U.IDUsuario) AS CantidadOrdenes,
                                   (SELECT ISNULL(SUM(OT.PresupuestoTotal), 0)
                                    FROM OrdenTrabajo OT
                                    WHERE OT.IDCliente = U.IDUsuario
                                      AND OT.Estado <> 'Cancelada') AS TotalContratado
                            FROM Usuarios U
                            WHERE U.Rol = 2
                            ORDER BY U.Nombre");
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    Cliente c = new Cliente();
                    c.IDUsuario = (int)datos.Lector["IDUsuario"];
                    c.Nombre = (string)datos.Lector["Nombre"];
                    c.Mail = (string)datos.Lector["Mail"];
                    c.Telefono = (string)datos.Lector["Telefono"];
                    c.CantidadOrdenes = (int)datos.Lector["CantidadOrdenes"];
                    c.TotalContratado = (decimal)datos.Lector["TotalContratado"];
                    c.Rol = 2;
                    lista.Add(c);
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
