<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="PanelTecnico.aspx.cs" Inherits="TP_Fixer_web.PanelTecnico" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<div class="container py-5">

        <%-- Cartel que ve solo el administrador --%>
    <asp:Panel ID="pnlVistaAdmin" runat="server" Visible="false"
        CssClass="alert alert-primary d-flex justify-content-between align-items-center">
        <span>Estás viendo el panel de <strong><asp:Label ID="lblTecnicoAdmin" runat="server" /></strong></span>
        <a href="Administracion.aspx" class="btn btn-sm btn-primary rounded-pill">Volver a Administración</a>
    </asp:Panel>

    <%-- DISPONIBILIDAD (sin cambios) --%>
    <div class="card border-0 rounded-4 shadow-sm p-4 mb-4">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <div class="small text-secondary">Tu estado para recibir trabajos</div>
                <asp:Label ID="lblDisponibilidad" runat="server" CssClass="fs-5 fw-bold" />
            </div>
            <asp:Button ID="btnDisponibilidad" runat="server"
                CssClass="btn rounded-pill" OnClick="btnDisponibilidad_Click" />
        </div>
        <div class="small text-secondary mt-2">
            Si estás no disponible, no te vamos a proponer a los clientes.
        </div>
    </div>

    <%-- Mensaje después de actualizar una orden --%>
    <asp:Panel ID="pnlMensaje" runat="server" Visible="false" CssClass="alert alert-success">
        <asp:Label ID="lblMensaje" runat="server" />
    </asp:Panel>

    <%-- TÍTULO + FILTRO (ahora con "Todos") --%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 fw-bold mb-0">Mis trabajos</h1>

        <div class="d-flex align-items-center">
            <label for="ddlEstado" class="me-2 fw-semibold">Estado:</label>
            <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select"
                AutoPostBack="true" OnSelectedIndexChanged="ddlEstado_SelectedIndexChanged">
                <asp:ListItem Text="Todos" Value="" />
                <asp:ListItem Text="Pendiente" Value="Pendiente" />
                <asp:ListItem Text="Iniciada" Value="Iniciada" />
                <asp:ListItem Text="Finalizada" Value="Finalizada" />
                <asp:ListItem Text="Cancelada" Value="Cancelada" />
            </asp:DropDownList>
        </div>
    </div>

    <%-- LISTA DE ÓRDENES (ahora con Estado y botón Actualizar) --%>
    <asp:Repeater ID="rptTrabajos" runat="server" OnItemCommand="rptTrabajos_ItemCommand">
        <HeaderTemplate>
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>N.º</th>
                        <th>Cliente</th>
                        <th>Teléfono</th>
                        <th>Dirección</th>
                        <th>Fecha programada</th>
                        <th class="text-end">Presupuesto</th>
                        <th class="text-end">Tiempo</th>
                        <th>Observaciones</th>
                        <th>Estado</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
                    <tr>
                        <td><%# Eval("IDOrdenTrabajo") %></td>
                        <td><%# Eval("Cliente") %></td>
                        <td><%# Eval("Telefono") %></td>
                        <td><%# Eval("Direccion") %></td>
                        <td><%# Eval("FechaProgramada", "{0:dd/MM/yyyy}") %></td>
                        <td class="text-end">$<%# Eval("PresupuestoTotal", "{0:N0}") %></td>
                        <td class="text-end"><%# Eval("TiempoEstimadoTotal") %> min</td>
                        <td class="text-secondary small"><%# Eval("Observaciones") %></td>
                        <td>
                            <span class='badge rounded-pill <%# ClaseEstado((string)Eval("Estado")) %>'>
                                <%# Eval("Estado") %>
                            </span>
                        </td>
                        <td class="text-end">
                            <asp:Button ID="btnActualizar" runat="server" Text="Actualizar"
                                CssClass="btn btn-sm btn-outline-primary rounded-pill"
                                CommandName="Actualizar"
                                CommandArgument='<%# Eval("IDOrdenTrabajo") %>'
                                Visible='<%# SePuedeActualizar((string)Eval("Estado")) %>' />
                        </td>
                    </tr>
        </ItemTemplate>
        <FooterTemplate>
                </tbody>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Label ID="lblSinTrabajos" runat="server" Visible="false"
        CssClass="text-secondary" Text="No tenés órdenes para mostrar." />
</div>

<%-- VENTANA PARA ACTUALIZAR UNA ORDEN --%>
<div class="modal fade" id="modalEstado" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4">

            <div class="modal-header">
                <h5 class="modal-title fw-bold">
                    <asp:Label ID="lblOrdenModal" runat="server" />
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <asp:HiddenField ID="hfIdOrden" runat="server" />

                <div class="mb-3">
                    <label class="form-label fw-semibold">Estado</label>
                    <asp:DropDownList ID="ddlNuevoEstado" runat="server" CssClass="form-select" />
                </div>

                <div class="mb-2">
                    <label class="form-label fw-semibold">Observación (opcional)</label>
                    <asp:TextBox ID="txtObservacion" runat="server" CssClass="form-control"
                        TextMode="MultiLine" Rows="3" MaxLength="200"
                        placeholder="Ej.: se cambió el cuerito, quedó sin pérdida" />
                </div>

                <asp:Label ID="lblErrorModal" runat="server" CssClass="text-danger d-block mt-2" />
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Cancelar</button>
                <asp:Button ID="btnGuardarEstado" runat="server" Text="Guardar"
                    CssClass="btn btn-primary rounded-pill" OnClick="btnGuardarEstado_Click" />
            </div>

        </div>
    </div>
</div>
</asp:Content>