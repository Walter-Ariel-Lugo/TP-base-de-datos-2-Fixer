using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Dominio;
using Servicio;
using System.Globalization;


namespace TP_Fixer_web
{
    public partial class Administracion : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Solo administradores (rol 1)
            Usuario usuario = Session["Usuario"] as Usuario;
            if (usuario == null || usuario.Rol != 1)
            {
                Response.Redirect("Default.aspx", false);
                return;
            }

            if (!IsPostBack)
            {
                MostrarPestana(0);
            }
        }

        // Al hacer clic en una pestaña
        protected void Pestana_Click(object sender, EventArgs e)
        {
            LinkButton pestana = (LinkButton)sender;
            lblMensaje.Text = "";
            lblMensaje.CssClass = "d-block mb-3";
            MostrarPestana(int.Parse(pestana.CommandArgument));
            pnlEditarServicios.Visible = false;
        }

        // Muestra la pestaña elegida, la marca como activa y carga sus datos
        private void MostrarPestana(int indice)
        {
            mvAdmin.ActiveViewIndex = indice;

            lnkTecnicos.CssClass = indice == 0 ? "nav-link active" : "nav-link";
            lnkServicios.CssClass = indice == 1 ? "nav-link active" : "nav-link";
            lnkClientes.CssClass = indice == 2 ? "nav-link active" : "nav-link";
            lnkReportes.CssClass = indice == 3 ? "nav-link active" : "nav-link";

            if (indice == 0)
                CargarTecnicos();

            if (indice == 2)
                CargarClientes();

            if (indice == 1)
                CargarServicios();

            if (indice == 3)
                CargarReporte();

        }

        // ---------- TÉCNICOS ----------

        private void CargarTecnicos()
        {
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
            rptTecnicos.DataSource = tecnicoNegocio.ListarTodos();
            rptTecnicos.DataBind();

            // Casillas del formulario: solo servicios activos
            ServicioServicio servicioServicio = new ServicioServicio();
            cblServiciosTecnico.DataSource = servicioServicio.ListarTodos().Where(s => s.Activo).ToList();
            cblServiciosTecnico.DataBind();
        }

        protected void rptTecnicos_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idTecnico = int.Parse(e.CommandArgument.ToString());
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();

            if (e.CommandName == "DarDeBaja")
            {
                tecnicoNegocio.DarDeBaja(idTecnico);   // DELETE → triggers de Mateo
                pnlEditarServicios.Visible = false;
                MostrarMensaje("El técnico fue dado de baja. Sus órdenes anteriores se conservan.", true);
                CargarTecnicos();
            }
            else if (e.CommandName == "EditarServicios")
            {
                AbrirEdicionServicios(idTecnico);
            }
        }
        // Botón "Crear técnico"
        protected void btnCrearTecnico_Click(object sender, EventArgs e)
        {
            string nombre = txtNombreTecnico.Text.Trim();
            string mail = txtMailTecnico.Text.Trim();
            string telefono = txtTelefonoTecnico.Text.Trim();
            string password = txtPassTecnico.Text;

            // 1. Datos obligatorios
            if (nombre == "" || mail == "" || telefono == "" || password == "")
            {
                MostrarMensaje("Completá nombre, mail, teléfono y contraseña.", false);
                return;
            }

            // 2. Crear usuario + técnico (sp_crearTecnico, con transacción)
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
            int idNuevo = tecnicoNegocio.Crear(nombre, mail, password, telefono);

            if (idNuevo == -1)
            {
                MostrarMensaje("Ya existe un usuario con ese mail.", false);
                return;
            }
            if (idNuevo == -2)
            {
                MostrarMensaje("No se pudo crear el técnico. No se guardó ningún dato.", false);
                return;
            }

            // 3. Asignar los servicios tildados
            int asignados = 0;
            foreach (ListItem item in cblServiciosTecnico.Items)
            {
                if (item.Selected)
                {
                    tecnicoNegocio.AsignarServicio(idNuevo, int.Parse(item.Value));
                    asignados++;
                }
            }

            // 4. Limpiar el formulario y recargar la lista
            txtNombreTecnico.Text = "";
            txtMailTecnico.Text = "";
            txtTelefonoTecnico.Text = "";
            txtPassTecnico.Text = "";

            MostrarMensaje("Técnico creado: " + nombre + ", con " + asignados + " servicio(s) asignado(s).", true);
            CargarTecnicos();
        }

        // Muestra el recuadro con los servicios del técnico ya tildados
        private void AbrirEdicionServicios(int idTecnico)
        {
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();
            Tecnico tecnico = tecnicoNegocio.ListarTodos().FirstOrDefault(t => t.IDUsuario == idTecnico);
            if (tecnico == null)
                return;

            hfTecnicoEditar.Value = idTecnico.ToString();
            lblTecnicoEditar.Text = tecnico.Nombre;

            // Todas las casillas: servicios activos
            ServicioServicio servicioServicio = new ServicioServicio();
            cblEditarServicios.DataSource = servicioServicio.ListarTodos().Where(s => s.Activo).ToList();
            cblEditarServicios.DataBind();

            // Tildar los que el técnico ya hace
            List<int> asignados = tecnicoNegocio.ServiciosAsignados(idTecnico);
            foreach (ListItem item in cblEditarServicios.Items)
            {
                item.Selected = asignados.Contains(int.Parse(item.Value));
            }

            lblMensaje.Text = "";
            lblMensaje.CssClass = "d-block mb-3";
            pnlEditarServicios.Visible = true;
        }

        // Botón "Guardar": aplica cada casilla con el SP
        protected void btnGuardarServicios_Click(object sender, EventArgs e)
        {
            int idTecnico = int.Parse(hfTecnicoEditar.Value);
            TecnicoNegocio tecnicoNegocio = new TecnicoNegocio();

            int activos = 0;
            foreach (ListItem item in cblEditarServicios.Items)
            {
                tecnicoNegocio.ActualizarServicio(idTecnico, int.Parse(item.Value), item.Selected);
                if (item.Selected)
                    activos++;
            }

            pnlEditarServicios.Visible = false;
            MostrarMensaje("Servicios actualizados: " + lblTecnicoEditar.Text + " ahora hace " + activos + " servicio(s).", true);
            CargarTecnicos();
        }

        // Botón "Cancelar"
        protected void btnCancelarEdicion_Click(object sender, EventArgs e)
        {
            pnlEditarServicios.Visible = false;
        }

        // ---------- REPORTES ----------

        private void CargarReporte()
        {
            ServicioServicio servicioServicio = new ServicioServicio();
            var reporte = servicioServicio.ListarMasContratados();

            rptReporte.DataSource = reporte;
            rptReporte.DataBind();
            lblSinReporte.Visible = (reporte.Count == 0);
        }

        // ---------- SERVICIOS ----------

        // Todos los servicios, cargados una sola vez y repartidos por categoría
        private List<Dominio.Servicio> todosLosServicios;

        // La usa el Repeater de adentro: servicios de una categoría
        protected List<Dominio.Servicio> ServiciosDe(int idTipo)
        {
            return todosLosServicios.Where(s => s.IDTipo == idTipo).ToList();
        }

        private void CargarServicios()
        {
            TipoServicioServicio tipoServicioServicio = new TipoServicioServicio();
            List<TipoServicio> categorias = tipoServicioServicio.Listar();

            ServicioServicio servicioServicio = new ServicioServicio();
            todosLosServicios = servicioServicio.ListarTodos();

            rptCategoriasAdmin.DataSource = categorias;
            rptCategoriasAdmin.DataBind();

            ddlCategoriaServicio.DataSource = categorias;
            ddlCategoriaServicio.DataBind();
        }

        // Botón "Dar de baja" / "Dar de alta"
        protected void rptServiciosAdmin_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idServicio = int.Parse(e.CommandArgument.ToString());
            bool activar = (e.CommandName == "Alta");

            ServicioServicio servicioServicio = new ServicioServicio();
            servicioServicio.CambiarEstado(idServicio, activar);

            MostrarMensaje(activar ? "El servicio fue dado de alta." : "El servicio fue dado de baja.", true);
            CargarServicios();
        }

        // Botón "Crear categoría"
        protected void btnCrearCategoria_Click(object sender, EventArgs e)
        {
            string nombre = txtNombreCategoria.Text.Trim();
            string descripcion = txtDescCategoria.Text.Trim();

            if (nombre == "")
            {
                MostrarMensaje("Completá el nombre de la categoría.", false);
                return;
            }

            TipoServicioServicio tipoServicioServicio = new TipoServicioServicio();
            tipoServicioServicio.Agregar(nombre, descripcion == "" ? null : descripcion);

            txtNombreCategoria.Text = "";
            txtDescCategoria.Text = "";
            MostrarMensaje("Categoría creada: " + nombre + ".", true);
            CargarServicios();
        }

        // Botón "Crear servicio"
        protected void btnCrearServicio_Click(object sender, EventArgs e)
        {
            string nombre = txtNombreServicio.Text.Trim();
            string descripcion = txtDescServicio.Text.Trim();

            if (ddlCategoriaServicio.SelectedValue == "" || nombre == "")
            {
                MostrarMensaje("Elegí una categoría y completá el nombre del servicio.", false);
                return;
            }

            decimal precio;
            if (!decimal.TryParse(txtPrecioServicio.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out precio)
                || precio < 0)
            {
                MostrarMensaje("El precio tiene que ser un número mayor o igual a 0.", false);
                return;
            }

            int tiempo;
            if (!int.TryParse(txtTiempoServicio.Text, out tiempo) || tiempo <= 0)
            {
                MostrarMensaje("El tiempo tiene que ser un número de minutos mayor a 0.", false);
                return;
            }

            Dominio.Servicio servicio = new Dominio.Servicio();
            servicio.IDTipo = int.Parse(ddlCategoriaServicio.SelectedValue);
            servicio.Nombre = nombre;
            servicio.Descripcion = descripcion == "" ? null : descripcion;
            servicio.Precio = precio;
            servicio.TiempoPromedio = tiempo;

            ServicioServicio servicioServicio = new ServicioServicio();
            servicioServicio.Agregar(servicio);

            txtNombreServicio.Text = "";
            txtDescServicio.Text = "";
            txtPrecioServicio.Text = "";
            txtTiempoServicio.Text = "";
            MostrarMensaje("Servicio creado: " + nombre + ".", true);
            CargarServicios();
        }

        // Mensaje verde (bien) o rojo (error) arriba del panel
        private void MostrarMensaje(string texto, bool exito)
        {
            lblMensaje.Text = texto;
            lblMensaje.CssClass = exito ? "alert alert-success d-block mb-3" : "alert alert-danger d-block mb-3";
        }

        // ---------- CLIENTES ----------

        private void CargarClientes()
        {
            UsuarioNegocio usuarioNegocio = new UsuarioNegocio();
            List<Cliente> clientes = usuarioNegocio.ListarClientes();

            rptClientes.DataSource = clientes;
            rptClientes.DataBind();
            lblSinClientes.Visible = (clientes.Count == 0);
        }
    }

}