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
            // Solo técnicos (rol 3) y el administrador (rol 1)
            Usuario usuario = Session["Usuario"] as Usuario;
            if (usuario == null || (usuario.Rol != 1 && usuario.Rol != 3))
            {
                Response.Redirect("Default.aspx", false);
                return;
            }

            // El admin tiene que indicar qué técnico quiere ver (?id=...)
            if (usuario.Rol == 1)
            {
                int id;
                Tecnico tecnico = null;
                if (int.TryParse(Request.QueryString["id"], out id))
                {
                    TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
                    tecnico = tecnicoNegocio.ListarTodos().FirstOrDefault(t => t.IDUsuario == id);
                }

                if (tecnico == null)
                {
                    Response.Redirect("Administracion.aspx", false);
                    return;
                }

                pnlVistaAdmin.Visible = true;
                lblTecnicoAdmin.Text = tecnico.Nombre;
            }

            if (!IsPostBack)
            {
                CargarTrabajos();
                MostrarDisponibilidad();
            }
        }

        // ID del técnico cuyo panel se está viendo:
        // el técnico ve el suyo; el admin, el que viene en la dirección
        private int IdTecnicoActual()
        {
            Usuario usuario = (Usuario)Session["Usuario"];
            if (usuario.Rol == 3)
                return usuario.IDUsuario;

            return int.Parse(Request.QueryString["id"]);
        }

        // Al cambiar el filtro de estado
        protected void ddlEstado_SelectedIndexChanged(object sender, EventArgs e)
        {
            pnlMensaje.Visible = false;
            CargarTrabajos();
        }

        // Carga la tabla según el filtro ("Todos" = null)
        private void CargarTrabajos()
        {
            string estado = ddlEstado.SelectedValue == "" ? null : ddlEstado.SelectedValue;

            OrdenNegocio ordenNegocio = new OrdenNegocio();
            List<OrdenTrabajo> trabajos = ordenNegocio.ListarPorTecnico(IdTecnicoActual(), estado);

            rptTrabajos.DataSource = trabajos;
            rptTrabajos.DataBind();
            lblSinTrabajos.Visible = (trabajos.Count == 0);
        }

        // Color de la pastilla según el estado
        protected string ClaseEstado(string estado)
        {
            switch (estado)
            {
                case "Pendiente": return "text-bg-warning";
                case "Iniciada": return "text-bg-primary";
                case "Finalizada": return "text-bg-success";
                default: return "text-bg-secondary";   // Cancelada
            }
        }

        // Solo se pueden actualizar las órdenes Pendientes o Iniciadas
        protected bool SePuedeActualizar(string estado)
        {
            return estado == "Pendiente" || estado == "Iniciada";
        }

        // Botón "Actualizar" de cada fila
        protected void rptTrabajos_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Actualizar")
                return;

            int idOrden = int.Parse(e.CommandArgument.ToString());

            OrdenNegocio ordenNegocio = new OrdenNegocio();
            OrdenTrabajo orden = ordenNegocio.ListarPorTecnico(IdTecnicoActual(), null)
                                             .FirstOrDefault(o => o.IDOrdenTrabajo == idOrden);

            if (orden == null || !SePuedeActualizar(orden.Estado))
                return;

            hfIdOrden.Value = idOrden.ToString();
            lblOrdenModal.Text = "Orden N.º " + idOrden + " · " + orden.Cliente;

            ddlNuevoEstado.Items.Clear();
            ddlNuevoEstado.Items.Add(new ListItem("Sigue " + orden.Estado, orden.Estado));

            if (orden.Estado == "Pendiente")
            {
                ddlNuevoEstado.Items.Add(new ListItem("Iniciada", "Iniciada"));
                ddlNuevoEstado.Items.Add(new ListItem("Cancelada", "Cancelada"));
            }
            else   // Iniciada
            {
                ddlNuevoEstado.Items.Add(new ListItem("Finalizada", "Finalizada"));
                ddlNuevoEstado.Items.Add(new ListItem("Cancelada", "Cancelada"));
            }

            txtObservacion.Text = "";
            lblErrorModal.Text = "";
            AbrirModal();
        }

        // Botón "Guardar" de la ventana
        protected void btnGuardarEstado_Click(object sender, EventArgs e)
        {
            int idOrden = int.Parse(hfIdOrden.Value);
            string estado = ddlNuevoEstado.SelectedValue;
            string observacion = txtObservacion.Text.Trim();

            if (ddlNuevoEstado.SelectedIndex == 0 && observacion == "")
            {
                lblErrorModal.Text = "Cambiá el estado o escribí una observación.";
                AbrirModal();
                return;
            }

            OrdenNegocio ordenNegocio = new OrdenNegocio();
            int resultado = ordenNegocio.CambiarEstado(idOrden, IdTecnicoActual(), estado,
                                                       observacion == "" ? null : observacion);

            if (resultado == -1)
            {
                lblErrorModal.Text = "Esta orden no está asignada a este técnico.";
                AbrirModal();
                return;
            }
            if (resultado == -2)
            {
                lblErrorModal.Text = "Ese cambio de estado no está permitido.";
                AbrirModal();
                return;
            }

            lblMensaje.Text = "Orden N.º " + idOrden + " actualizada: " + estado + ".";
            pnlMensaje.Visible = true;
            CargarTrabajos();
        }

        // Abre la ventana cuando la página termina de cargar
        private void AbrirModal()
        {
            ClientScript.RegisterStartupScript(GetType(), "abrirModal",
                "document.addEventListener('DOMContentLoaded', function () {" +
                "  new bootstrap.Modal(document.getElementById('modalEstado')).show();" +
                "});", true);
        }

        // Muestra si el técnico está disponible y prepara el botón
        private void MostrarDisponibilidad()
        {
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
            bool disponible = tecnicoNegocio.EstaDisponible(IdTecnicoActual());

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

        // Invierte la disponibilidad
        protected void btnDisponibilidad_Click(object sender, EventArgs e)
        {
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
            bool disponible = tecnicoNegocio.EstaDisponible(IdTecnicoActual());
            tecnicoNegocio.CambiarDisponibilidad(IdTecnicoActual(), !disponible);

            MostrarDisponibilidad();
        }
    }
}