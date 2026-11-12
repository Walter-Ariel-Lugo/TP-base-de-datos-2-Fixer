<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Administracion.aspx.cs" Inherits="TP_Fixer_web.Administracion" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-5">
    <h1 class="h3 fw-bold mb-4">Panel de administración</h1>

    <%-- Pestañas --%>
    <ul class="nav nav-tabs mb-4">
        <li class="nav-item">
            <asp:LinkButton ID="lnkTecnicos" runat="server" CssClass="nav-link"
                CommandArgument="0" OnClick="Pestana_Click">Técnicos</asp:LinkButton>
        </li>
        <li class="nav-item">
            <asp:LinkButton ID="lnkServicios" runat="server" CssClass="nav-link"
                CommandArgument="1" OnClick="Pestana_Click">Servicios</asp:LinkButton>
        </li>
        <li class="nav-item">
            <asp:LinkButton ID="lnkClientes" runat="server" CssClass="nav-link"
                CommandArgument="2" OnClick="Pestana_Click">Clientes</asp:LinkButton>
        </li>
        <li class="nav-item">
            <asp:LinkButton ID="lnkReportes" runat="server" CssClass="nav-link"
                CommandArgument="3" OnClick="Pestana_Click">Reportes</asp:LinkButton>
        </li>
    </ul>

    <asp:Label ID="lblMensaje" runat="server" CssClass="d-block mb-3" />

    <%-- Contenido de cada pestaña --%>
    <asp:MultiView ID="mvAdmin" runat="server" ActiveViewIndex="0">

        <%-- 0: TÉCNICOS --%>
        <asp:View ID="vTecnicos" runat="server">
            <div class="card border-0 rounded-4 shadow-sm p-4 mb-4">
    <h2 class="h6 fw-bold mb-3">Nuevo técnico</h2>
    <div class="row g-2">
        <div class="col-4">
            <label class="form-label small">Nombre</label>
            <asp:TextBox ID="txtNombreTecnico" runat="server" CssClass="form-control" MaxLength="50" />
        </div>
        <div class="col-4">
            <label class="form-label small">Mail</label>
            <asp:TextBox ID="txtMailTecnico" runat="server" TextMode="Email" CssClass="form-control" MaxLength="100" />
        </div>
        <div class="col-4">
            <label class="form-label small">Teléfono</label>
            <asp:TextBox ID="txtTelefonoTecnico" runat="server" CssClass="form-control" MaxLength="50" />
        </div>
        <div class="col-4">
            <label class="form-label small">Contraseña inicial</label>
            <asp:TextBox ID="txtPassTecnico" runat="server" CssClass="form-control" />
        </div>
        <div class="col-12">
            <label class="form-label small">Servicios que puede hacer</label>
            <asp:CheckBoxList ID="cblServiciosTecnico" runat="server"
                DataTextField="Nombre" DataValueField="IDServicio"
                RepeatColumns="3" CssClass="small" CellPadding="4" />
        </div>
    </div>
    <div class="mt-3">
        <asp:Button ID="btnCrearTecnico" runat="server" Text="Crear técnico"
            CssClass="btn btn-primary rounded-pill" OnClick="btnCrearTecnico_Click" />
    </div>
</div>
            <asp:Panel ID="pnlEditarServicios" runat="server" Visible="false"
    CssClass="card border-0 rounded-4 shadow-sm p-4 mb-4 bg-primary-subtle">
    <h2 class="h6 fw-bold mb-3">
        Servicios de <asp:Label ID="lblTecnicoEditar" runat="server" />
    </h2>
    <asp:HiddenField ID="hfTecnicoEditar" runat="server" />
    <asp:CheckBoxList ID="cblEditarServicios" runat="server"
        DataTextField="Nombre" DataValueField="IDServicio"
        RepeatColumns="3" CssClass="small" CellPadding="4" />
    <div class="mt-3">
        <asp:Button ID="btnGuardarServicios" runat="server" Text="Guardar"
            CssClass="btn btn-primary rounded-pill" OnClick="btnGuardarServicios_Click" />
        <asp:Button ID="btnCancelarEdicion" runat="server" Text="Cancelar"
            CssClass="btn btn-outline-secondary rounded-pill ms-2" OnClick="btnCancelarEdicion_Click" />
    </div>
</asp:Panel>
            <asp:Repeater ID="rptTecnicos" runat="server" OnItemCommand="rptTecnicos_ItemCommand">
                <HeaderTemplate>
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Nombre</th>
                                <th>Mail</th>
                                <th>Teléfono</th>
                                <th>Estado</th>
                                <th>Disponible</th>
                                <th class="text-center">Servicios activos</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                            <tr>
                                <td class="fw-semibold"><%# Eval("Nombre") %></td>
                                <td><%# Eval("Mail") %></td>
                                <td><%# Eval("Telefono") %></td>
                                <td>
                                    <span class='badge <%# (bool)Eval("Activo") ? "text-bg-success" : "text-bg-secondary" %>'>
                                        <%# (bool)Eval("Activo") ? "Activo" : "Inactivo" %>
                                    </span>
                                </td>
                                <td><%# (bool)Eval("Disponible") ? "Sí" : "No" %></td>
                                <td class="text-center"><%# Eval("ServiciosActivos") %></td>
                                <td class="text-end">
                                    <asp:Button ID="btnEditarServicios" runat="server" Text="Editar servicios"
    CssClass="btn btn-outline-primary btn-sm rounded-pill me-1"
    CommandName="EditarServicios"
    CommandArgument='<%# Eval("IDUsuario") %>' />
                                    <asp:Button ID="btnBaja" runat="server" Text="Dar de baja"
                                        CssClass="btn btn-outline-danger btn-sm rounded-pill"
                                        CommandName="DarDeBaja"
                                        CommandArgument='<%# Eval("IDUsuario") %>'
                                        Visible='<%# (bool)Eval("Activo") %>'
                                        OnClientClick="return confirm('¿Dar de baja a este técnico?');" />
                                </td>
                            </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </asp:View>

        <%-- 1: SERVICIOS --%>
       <asp:View ID="vServicios" runat="server">

    <%-- ===== FORMULARIOS ===== --%>
    <div class="row g-4 mb-4">

        <%-- Nueva categoría --%>
        <div class="col-4">
            <div class="card h-100 border-0 rounded-4 shadow-sm p-4">
                <h2 class="h6 fw-bold mb-3">Nueva categoría</h2>
                <label class="form-label small">Nombre</label>
                <asp:TextBox ID="txtNombreCategoria" runat="server" CssClass="form-control mb-2" MaxLength="50" />
                <label class="form-label small">Descripción</label>
                <asp:TextBox ID="txtDescCategoria" runat="server" CssClass="form-control mb-3" MaxLength="255" />
                <asp:Button ID="btnCrearCategoria" runat="server" Text="Crear categoría"
                    CssClass="btn btn-primary rounded-pill" OnClick="btnCrearCategoria_Click" />
            </div>
        </div>

        <%-- Nuevo servicio --%>
        <div class="col-8">
            <div class="card h-100 border-0 rounded-4 shadow-sm p-4">
                <h2 class="h6 fw-bold mb-3">Nuevo servicio</h2>
                <div class="row g-2">
                    <div class="col-6">
                        <label class="form-label small">Categoría</label>
                        <asp:DropDownList ID="ddlCategoriaServicio" runat="server" CssClass="form-select"
                            DataTextField="Nombre" DataValueField="IDTipoServicio" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small">Nombre</label>
                        <asp:TextBox ID="txtNombreServicio" runat="server" CssClass="form-control" MaxLength="50" />
                    </div>
                    <div class="col-12">
                        <label class="form-label small">Descripción</label>
                        <asp:TextBox ID="txtDescServicio" runat="server" CssClass="form-control" MaxLength="255" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small">Precio ($)</label>
                        <asp:TextBox ID="txtPrecioServicio" runat="server" TextMode="Number" CssClass="form-control" />
                    </div>
                    <div class="col-6">
                        <label class="form-label small">Tiempo promedio (minutos)</label>
                        <asp:TextBox ID="txtTiempoServicio" runat="server" TextMode="Number" CssClass="form-control" />
                    </div>
                </div>
                <div class="mt-3">
                    <asp:Button ID="btnCrearServicio" runat="server" Text="Crear servicio"
                        CssClass="btn btn-primary rounded-pill" OnClick="btnCrearServicio_Click" />
                </div>
            </div>
        </div>
    </div>

    <%-- ===== SERVICIOS AGRUPADOS POR CATEGORÍA ===== --%>
    <asp:Repeater ID="rptCategoriasAdmin" runat="server">
        <ItemTemplate>
            <h3 class="h6 fw-bold mt-4 text-primary"><%# Eval("Nombre") %></h3>

            <asp:Repeater ID="rptServiciosAdmin" runat="server"
                DataSource='<%# ServiciosDe((int)Eval("IDTipoServicio")) %>'
                OnItemCommand="rptServiciosAdmin_ItemCommand">
                <HeaderTemplate>
                    <table class="table table-sm table-hover align-middle mb-0">
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                            <tr>
                                <td class="fw-semibold" style="width: 30%;"><%# Eval("Nombre") %></td>
                                <td class="text-end">$<%# Eval("Precio", "{0:N0}") %></td>
                                <td class="text-end"><%# Eval("TiempoPromedio") %> min</td>
                                <td class="text-center">
                                    <span class='<%# (int)Eval("CantidadTecnicos") == 0 ? "text-danger fw-bold" : "text-secondary" %>'>
                                        <%# Eval("CantidadTecnicos") %> técnico(s)
                                    </span>
                                </td>
                                <td class="text-center">
                                    <span class='badge <%# (bool)Eval("Activo") ? "text-bg-success" : "text-bg-secondary" %>'>
                                        <%# (bool)Eval("Activo") ? "Activo" : "Inactivo" %>
                                    </span>
                                </td>
                                <td class="text-end">
                                    <asp:Button ID="btnEstado" runat="server"
                                        Text='<%# (bool)Eval("Activo") ? "Dar de baja" : "Dar de alta" %>'
                                        CommandName='<%# (bool)Eval("Activo") ? "Baja" : "Alta" %>'
                                        CommandArgument='<%# Eval("IDServicio") %>'
                                        CssClass='<%# (bool)Eval("Activo") ? "btn btn-outline-danger btn-sm rounded-pill" : "btn btn-outline-success btn-sm rounded-pill" %>' />
                                </td>
                            </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

            <asp:Label ID="lblCategoriaVacia" runat="server" CssClass="text-secondary small"
                Text="Todavía no hay servicios en esta categoría."
                Visible='<%# ServiciosDe((int)Eval("IDTipoServicio")).Count == 0 %>' />
        </ItemTemplate>
    </asp:Repeater>

</asp:View>

        <%-- 2: CLIENTES --%>
        <asp:View ID="vClientes" runat="server">
    <asp:Repeater ID="rptClientes" runat="server">
        <HeaderTemplate>
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>Nombre</th>
                        <th>Mail</th>
                        <th>Teléfono</th>
                        <th class="text-center">Órdenes</th>
                        <th class="text-end">Total contratado</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
                    <tr>
                        <td class="fw-semibold"><%# Eval("Nombre") %></td>
                        <td><%# Eval("Mail") %></td>
                        <td><%# Eval("Telefono") %></td>
                        <td class="text-center"><%# Eval("CantidadOrdenes") %></td>
                        <td class="text-end">$<%# Eval("TotalContratado", "{0:N0}") %></td>
                    </tr>
        </ItemTemplate>
        <FooterTemplate>
                </tbody>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Label ID="lblSinClientes" runat="server" Visible="false"
        CssClass="text-secondary" Text="Todavía no hay clientes registrados." />
</asp:View>

        <%-- 3: REPORTES --%>
        <asp:View ID="vReportes" runat="server">
    <h2 class="h5 fw-bold mb-3">Servicios más contratados</h2>

    <asp:Repeater ID="rptReporte" runat="server">
        <HeaderTemplate>
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Servicio</th>
                        <th>Categoría</th>
                        <th class="text-end">Precio</th>
                        <th class="text-end">Tiempo</th>
                        <th class="text-center">Veces contratado</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
                    <tr>
                        <td class="fw-bold"><%# Container.ItemIndex + 1 %></td>
                        <td class="fw-semibold"><%# Eval("Servicio") %></td>
                        <td><%# Eval("Categoria") %></td>
                        <td class="text-end">$<%# Eval("Precio", "{0:N0}") %></td>
                        <td class="text-end"><%# Eval("TiempoPromedio") %> min</td>
                        <td class="text-center"><%# Eval("VecesContratado") %></td>
                    </tr>
        </ItemTemplate>
        <FooterTemplate>
                </tbody>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Label ID="lblSinReporte" runat="server" Visible="false"
        CssClass="text-secondary" Text="Todavía no hay órdenes para armar el reporte." />
</asp:View>

    </asp:MultiView>
</div>
</asp:Content>
