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
    public partial class PanelTecnico : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Solo técnicos (rol 3)
            Usuario usuario = Session["Usuario"] as Usuario;
            if (usuario == null || usuario.Rol != 3)
            {
                Response.Redirect("Default.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                CargarTrabajos();
                MostrarDisponibilidad();   // ← nueva
            }
        }

        // Al cambiar el estado en la lista desplegable
        protected void ddlEstado_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarTrabajos();
        }

        private void CargarTrabajos()
        {
            Usuario usuario = (Usuario)Session["Usuario"];
            OrdenNegocio ordenNegocio = new OrdenNegocio();
            List<OrdenTrabajo> trabajos = ordenNegocio.ListarPorTecnico(usuario.IDUsuario, ddlEstado.SelectedValue);

            rptTrabajos.DataSource = trabajos;
            rptTrabajos.DataBind();
            lblSinTrabajos.Visible = (trabajos.Count == 0);
        }

        // Muestra si el técnico está disponible y prepara el botón para cambiarlo
        private void MostrarDisponibilidad()
        {
            Usuario usuario = (Usuario)Session["Usuario"];
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
            bool disponible = tecnicoNegocio.EstaDisponible(usuario.IDUsuario);

            if (disponible)
            {
                lblDisponibilidad.Text = "Disponible";
                lblDisponibilidad.CssClass = "fs-5 fw-bold text-success";
                btnDisponibilidad.Text = "Marcarme como no disponible";
                btnDisponibilidad.CssClass = "btn btn-outline-secondary rounded-pill";
            }
            else
            {
                lblDisponibilidad.Text = "No disponible";
                lblDisponibilidad.CssClass = "fs-5 fw-bold text-secondary";
                btnDisponibilidad.Text = "Marcarme como disponible";
                btnDisponibilidad.CssClass = "btn btn-success rounded-pill";
            }
        }

        // Al apretar el botón: invierte la disponibilidad
        protected void btnDisponibilidad_Click(object sender, EventArgs e)
        {
            Usuario usuario = (Usuario)Session["Usuario"];
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();

            bool disponible = tecnicoNegocio.EstaDisponible(usuario.IDUsuario);
            tecnicoNegocio.CambiarDisponibilidad(usuario.IDUsuario, !disponible);

            MostrarDisponibilidad();
        }
    }
}