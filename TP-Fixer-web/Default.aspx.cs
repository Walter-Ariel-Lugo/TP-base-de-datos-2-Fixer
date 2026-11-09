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
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

     

            if (!IsPostBack)
            {
                // Las categorías salen de la tabla TipoServicio
                TipoServicioServicio tipoServicioServicio = new TipoServicioServicio();
                List<TipoServicio> categorias = tipoServicioServicio.Listar();

                rptCategorias.DataSource = categorias;
                rptCategorias.DataBind();
            }
        }
        protected void rptCategorias_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "VerServicios")
                return;

            // Si no inició sesión, lo mandamos al login
            if (Session["Usuario"] == null)
            {
                Response.Redirect("Login.aspx", false);
                return;
            }

            // Qué categoría eligió (el CommandArgument de la tarjeta)
            int idTipo = int.Parse(e.CommandArgument.ToString());

            // Nombre de la categoría para el título de la ventana
            TipoServicioServicio tipoServicioServicio = new TipoServicioServicio();
            TipoServicio categoria = tipoServicioServicio.Listar().FirstOrDefault(c => c.IDTipoServicio == idTipo);
            lblCategoriaModal.Text = categoria != null ? categoria.Nombre : "Servicios";

            // Servicios de esa categoría, desde la base
            ServicioServicio servicioServicio = new ServicioServicio();
            List<Dominio.Servicio> servicios = servicioServicio.ListarPorTipo(idTipo);

            rptServicios.DataSource = servicios;
            rptServicios.DataBind();
            lblSinServicios.Visible = (servicios.Count == 0);

            // Técnicos disponibles para esta categoría (usa vista_tecnicosDisponibles)
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
            List<Usuario> tecnicos = tecnicoNegocio.ListarDisponiblesPorTipo(idTipo);

            rptTecnicos.DataSource = tecnicos;
            rptTecnicos.DataBind();
            lblSinTecnicos.Visible = (tecnicos.Count == 0);

            // Abrir la ventana emergente cuando la página termine de cargar
            ClientScript.RegisterStartupScript(GetType(), "abrirModal",
                "document.addEventListener('DOMContentLoaded', function () {" +
                "  new bootstrap.Modal(document.getElementById('modalServicios')).show();" +
                "});", true);
        }
    }
}