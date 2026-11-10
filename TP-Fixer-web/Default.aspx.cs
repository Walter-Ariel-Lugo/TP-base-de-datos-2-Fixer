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
                TipoServicioServicio tipoServicioServicio = new TipoServicioServicio();
                List<TipoServicio> categorias = tipoServicioServicio.Listar();

                rptCategorias.DataSource = categorias;
                rptCategorias.DataBind();
            }
        }

        // Al hacer clic en una categoría: carga y abre la ventana
        protected void rptCategorias_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "VerServicios")
                return;

            if (Session["Usuario"] == null)
            {
                Response.Redirect("Login.aspx", false);
                return;
            }

            int idTipo = int.Parse(e.CommandArgument.ToString());

            // Nombre de la categoría
            TipoServicioServicio tipoServicioServicio = new TipoServicioServicio();
            TipoServicio categoria = tipoServicioServicio.Listar().FirstOrDefault(c => c.IDTipoServicio == idTipo);
            lblCategoriaModal.Text = categoria != null ? categoria.Nombre : "Servicios";

            // Servicios de la categoría
            ServicioServicio servicioServicio = new ServicioServicio();
            List<Dominio.Servicio> servicios = servicioServicio.ListarPorTipo(idTipo);
            rptServicios.DataSource = servicios;
            rptServicios.DataBind();
            lblSinServicios.Visible = (servicios.Count == 0);

            // Técnicos disponibles (vista_tecnicosDisponibles)
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
            List<Usuario> tecnicos = tecnicoNegocio.ListarDisponiblesPorTipo(idTipo);
            rblTecnicos.DataSource = tecnicos;
            rblTecnicos.DataBind();
            lblSinTecnicos.Visible = (tecnicos.Count == 0);

            // Limpiar el formulario
            txtDireccion.Text = "";
            txtFecha.Text = "";
            txtObservaciones.Text = "";
            lblErrorPedido.Text = "";

            AbrirModal();
        }

        // Al apretar "Confirmar pedido"
        protected void btnConfirmar_Click(object sender, EventArgs e)
        {
            Usuario usuario = Session["Usuario"] as Usuario;
            if (usuario == null)
            {
                Response.Redirect("Login.aspx", false);
                return;
            }

            // 1. Servicios tildados y sus cantidades
            List<int> idsServicios = new List<int>();
            List<int> cantidades = new List<int>();

            foreach (RepeaterItem item in rptServicios.Items)
            {
                CheckBox chk = (CheckBox)item.FindControl("chkServicio");
                if (chk.Checked)
                {
                    HiddenField hf = (HiddenField)item.FindControl("hfIdServicio");
                    TextBox txt = (TextBox)item.FindControl("txtCantidad");

                    int cantidad;
                    if (!int.TryParse(txt.Text, out cantidad) || cantidad < 1)
                    {
                        MostrarErrorPedido("La cantidad de cada servicio tiene que ser 1 o más.");
                        return;
                    }
                    idsServicios.Add(int.Parse(hf.Value));
                    cantidades.Add(cantidad);
                }
            }

            if (idsServicios.Count == 0)
            {
                MostrarErrorPedido("Elegí al menos un servicio.");
                return;
            }

            // 2. Técnico elegido, y que haga todos los servicios
            if (rblTecnicos.SelectedValue == "")
            {
                MostrarErrorPedido("Elegí un técnico.");
                return;
            }
            int idTecnico = int.Parse(rblTecnicos.SelectedValue);

            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
            foreach (int idServicio in idsServicios)
            {
                if (!tecnicoNegocio.HaceServicio(idTecnico, idServicio))
                {
                    MostrarErrorPedido("El técnico elegido no hace todos los servicios seleccionados.");
                    return;
                }
            }

            // 3. Dirección y fecha
            string direccion = txtDireccion.Text.Trim();
            if (direccion == "")
            {
                MostrarErrorPedido("Completá la dirección.");
                return;
            }

            DateTime fecha;
            if (!DateTime.TryParse(txtFecha.Text, out fecha) || fecha.Date < DateTime.Today)
            {
                MostrarErrorPedido("Elegí una fecha de hoy en adelante.");
                return;
            }

            string observaciones = txtObservaciones.Text.Trim();

            // 4. Crear la orden y agregarle los servicios
            OrdenNegocio ordenNegocio = new OrdenNegocio();
            int idOrden = ordenNegocio.CrearOrden(usuario.IDUsuario, idTecnico, fecha, direccion,
                                                  observaciones == "" ? null : observaciones);

            for (int i = 0; i < idsServicios.Count; i++)
            {
                ordenNegocio.AgregarServicio(idOrden, idsServicios[i], cantidades[i]);  // SP + trigger
            }

            // 5. Mostrar los totales que calculó el trigger
            OrdenTrabajo orden = ordenNegocio.ObtenerTotales(idOrden);
            lblConfirmacion.Text = "¡Pedido N.º " + orden.IDOrdenTrabajo + " confirmado! "
                                 + "Presupuesto: $" + orden.PresupuestoTotal.ToString("N0")
                                 + " · Tiempo estimado: " + orden.TiempoEstimadoTotal + " min"
                                 + " · Estado: " + orden.Estado;
            pnlConfirmacion.Visible = true;
        }

        // Muestra un error dentro de la ventana y la vuelve a abrir
        private void MostrarErrorPedido(string mensaje)
        {
            lblErrorPedido.Text = mensaje;
            AbrirModal();
        }

        // Abre la ventana emergente cuando la página termina de cargar
        private void AbrirModal()
        {
            ClientScript.RegisterStartupScript(GetType(), "abrirModal",
                "document.addEventListener('DOMContentLoaded', function () {" +
                "  new bootstrap.Modal(document.getElementById('modalServicios')).show();" +
                "});", true);
        }
    }
}