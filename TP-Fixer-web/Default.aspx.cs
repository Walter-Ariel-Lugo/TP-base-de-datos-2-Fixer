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
    }
}