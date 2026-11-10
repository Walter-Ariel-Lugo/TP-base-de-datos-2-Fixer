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
    public partial class MisOrdenes : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Solo para usuarios que iniciaron sesión
            Usuario usuario = Session["Usuario"] as Usuario;
            if (usuario == null)
            {
                Response.Redirect("Login.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                OrdenNegocio ordenNegocio = new OrdenNegocio();
                List<OrdenTrabajo> ordenes = ordenNegocio.ListarPorCliente(usuario.IDUsuario);

                rptOrdenes.DataSource = ordenes;
                rptOrdenes.DataBind();
                lblSinOrdenes.Visible = (ordenes.Count == 0);
            }
        }
    }
}