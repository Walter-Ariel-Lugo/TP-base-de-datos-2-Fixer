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
                // TEMPORAL: después esta lista va a venir de la base de datos
                List<TipoServicio> categorias = new List<TipoServicio>
    {
        new TipoServicio { IDTipoServicio = 1, Nombre = "Plomería",     Descripcion = "Pérdidas, canillas, destapaciones" },
        new TipoServicio { IDTipoServicio = 2, Nombre = "Electricidad", Descripcion = "Enchufes, lámparas, artefactos" },
        new TipoServicio { IDTipoServicio = 3, Nombre = "Jardinería",   Descripcion = "Poda, corte de césped" },
        new TipoServicio { IDTipoServicio = 4, Nombre = "Limpieza",     Descripcion = "Limpieza profunda, vidrios, filtros" }
    };

                rptCategorias.DataSource = categorias;
                rptCategorias.DataBind();
                /* cuando este la base de datos : descomentar  y borrar la lista manual  
              TipoServicioServicio tipoServicioServicio = new TipoServicioServicio();
              rptCategorias.DataSource = tipoServicioServicio.Listar();
              rptCategorias.DataBind(); */
            }
        }
    }
}