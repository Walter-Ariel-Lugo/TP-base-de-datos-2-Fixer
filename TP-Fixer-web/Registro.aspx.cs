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
    public partial class Registro : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Si ya inició sesión, no tiene sentido registrarse
            if (Session["Usuario"] != null)
            {
                Response.Redirect("Default.aspx", false);
                return;
            }

            // Si viene de intentar contratar, mostramos el aviso
            pnlAviso.Visible = Request.QueryString["contratar"] != null;
        }

        protected void btnRegistrar_Click(object sender, EventArgs e)
        {
            string nombre = txtNombre.Text.Trim();
            string mail = txtMail.Text.Trim();
            string telefono = txtTelefono.Text.Trim();
            string password = txtPassword.Text;

            // Que no falte ningún dato
            if (nombre == "" || mail == "" || telefono == "" || password == "")
            {
                lblError.Text = "Completá todos los campos.";
                return;
            }

            // Que las dos contraseñas sean iguales
            if (password != txtPassword2.Text)
            {
                lblError.Text = "Las contraseñas no coinciden.";
                return;
            }

            // Alta en la base (sp_registrarCliente)
            UsuarioNegocio negocio = new UsuarioNegocio();
            int id = negocio.RegistrarCliente(nombre, mail, password, telefono);

            if (id == -1)
            {
                lblError.Text = "Ya existe una cuenta con ese mail.";
                return;
            }

            // Lo logueamos con el Login de siempre y vuelve a Servicios
            Session["Usuario"] = negocio.Login(mail, password);
            Response.Redirect("Default.aspx#servicios", false);
        }
    }
}