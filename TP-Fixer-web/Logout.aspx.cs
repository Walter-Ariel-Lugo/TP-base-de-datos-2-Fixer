using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TP_Fixer_web
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Session.Clear();      // borra los datos guardados en la sesión
            Session.Abandon();    // termina la sesión
            Response.Redirect("Default.aspx", false);
        }
    }
}