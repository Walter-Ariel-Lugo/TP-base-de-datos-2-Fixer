<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="MisOrdenes.aspx.cs" Inherits="TP_Fixer_web.MisOrdenes" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-5">
    <h1 class="h3 fw-bold mb-4">Mis órdenes</h1>

    <asp:Repeater ID="rptOrdenes" runat="server">
        <HeaderTemplate>
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>N.º</th>
                        <th>Técnico</th>
                        <th>Estado</th>
                        <th>Fecha programada</th>
                        <th class="text-end">Presupuesto</th>
                        <th class="text-end">Tiempo</th>
                    </tr>
                </thead>
                <tbody>
        </HeaderTemplate>
        <ItemTemplate>
                    <tr>
                        <td><%# Eval("IDOrdenTrabajo") %></td>
                        <td><%# Eval("Tecnico") %></td>
                        <td><span class="badge text-bg-secondary"><%# Eval("Estado") %></span></td>
                        <td><%# Eval("FechaProgramada", "{0:dd/MM/yyyy}") %></td>
                        <td class="text-end">$<%# Eval("PresupuestoTotal", "{0:N0}") %></td>
                        <td class="text-end"><%# Eval("TiempoEstimadoTotal") %> min</td>
                    </tr>
        </ItemTemplate>
        <FooterTemplate>
                </tbody>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Label ID="lblSinOrdenes" runat="server" Visible="false"
        CssClass="text-secondary" Text="Todavía no hiciste ningún pedido." />
</div>
</asp:Content>
