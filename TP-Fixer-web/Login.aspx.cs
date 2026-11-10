using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Dominio;
using Servicio;

namespace TP_Fixer_web
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void btnIngresar_Click(object sender, EventArgs e)
        {
            string mail = txtMail.Text.Trim();
            string password = txtPassword.Text;

            //  Que no falte ningún dato
            if (mail == "" || password == "")
            {
                lblError.Text = "Completá el mail y la contraseña.";
                return;
            }

            //  Buscar el usuario en la base
            UsuarioNegocio negocio = new UsuarioNegocio();
            Usuario usuario = negocio.Login(mail, password);

            if (usuario == null)
            {
                lblError.Text = "Mail o contraseña incorrectos.";
                return;
            }

            //  Guardar el usuario en la sesión y volver a la portada
            Session["Usuario"] = usuario;

            // Redirigir según el rol del usuario
            if (usuario.Rol == 1)
                Response.Redirect("Administracion.aspx", false);
            else if (usuario.Rol == 3)
                Response.Redirect("PanelTecnico.aspx", false);
            else
                Response.Redirect("Default.aspx", false);
        }
    }
}