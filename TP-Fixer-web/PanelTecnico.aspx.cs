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
    }
}