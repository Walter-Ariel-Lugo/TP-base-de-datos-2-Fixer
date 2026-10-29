using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Servicio;

namespace TP_Fixer_web
{
    public partial class PruebaConexion : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetConsulta("SELECT @@SERVERNAME AS Servidor, DB_NAME() AS Base");
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                {
                    lblResultado.Text = "Conectado al servidor " + datos.Lector["Servidor"]
                                      + ", base " + datos.Lector["Base"];
                    lblResultado.CssClass = "alert alert-success d-block";
                }
            }
            catch (Exception ex)
            {
                lblResultado.Text = "Error: " + ex.Message;
                lblResultado.CssClass = "alert alert-danger d-block";
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
    }
}