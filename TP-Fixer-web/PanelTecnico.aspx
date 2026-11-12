<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="PanelTecnico.aspx.cs" Inherits="TP_Fixer_web.PanelTecnico" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-5">
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
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 fw-bold mb-0">Mis trabajos</h1>

        <div class="d-flex align-items-center">
            <label for="ddlEstado" class="me-2 fw-semibold">Estado:</label>
            <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select"
                AutoPostBack="true" OnSelectedIndexChanged="ddlEstado_SelectedIndexChanged">
                <asp:ListItem Text="Pendiente" Value="Pendiente" />
                <asp:ListItem Text="Iniciada" Value="Iniciada" />
                <asp:ListItem Text="Finalizada" Value="Finalizada" />
                <asp:ListItem Text="Cancelada" Value="Cancelada" />
            </asp:DropDownList>
        </div>
    </div>

    <asp:Repeater ID="rptTrabajos" runat="server">
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
                    </tr>
        </ItemTemplate>
        <FooterTemplate>
                </tbody>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Label ID="lblSinTrabajos" runat="server" Visible="false"
        CssClass="text-secondary" Text="No tenés órdenes en este estado." />
</div>
</asp:Content>
