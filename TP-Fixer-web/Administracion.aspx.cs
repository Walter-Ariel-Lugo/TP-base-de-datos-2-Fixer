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
    public partial class Administracion : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Solo administradores (rol 1)
            Usuario usuario = Session["Usuario"] as Usuario;
            if (usuario == null || usuario.Rol != 1)
            {
                Response.Redirect("Default.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                MostrarPestana(0);
            }
        }

        // Al hacer clic en una pestaña
        protected void Pestana_Click(object sender, EventArgs e)
        {
            LinkButton pestana = (LinkButton)sender;
            lblMensaje.Text = "";
            lblMensaje.CssClass = "d-block mb-3";
            MostrarPestana(int.Parse(pestana.CommandArgument));
        }

        // Muestra la pestaña elegida, la marca como activa y carga sus datos
        private void MostrarPestana(int indice)
        {
            mvAdmin.ActiveViewIndex = indice;

            lnkTecnicos.CssClass = indice == 0 ? "nav-link active" : "nav-link";
            lnkServicios.CssClass = indice == 1 ? "nav-link active" : "nav-link";
            lnkClientes.CssClass = indice == 2 ? "nav-link active" : "nav-link";
            lnkReportes.CssClass = indice == 3 ? "nav-link active" : "nav-link";

            if (indice == 0)
                CargarTecnicos();
            // Las otras pestañas se cargan cuando las armemos
        }

        // ---------- TÉCNICOS ----------

        private void CargarTecnicos()
        {
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
            rptTecnicos.DataSource = tecnicoNegocio.ListarTodos();
            rptTecnicos.DataBind();
        }

        protected void rptTecnicos_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DarDeBaja")
            {
                int idTecnico = int.Parse(e.CommandArgument.ToString());

                TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
                tecnicoNegocio.DarDeBaja(idTecnico);   // DELETE → triggers de Mateo

                lblMensaje.Text = "El técnico fue dado de baja. Sus órdenes anteriores se conservan.";
                lblMensaje.CssClass = "alert alert-success d-block mb-3";

                CargarTecnicos();
            }
        }
    }
}