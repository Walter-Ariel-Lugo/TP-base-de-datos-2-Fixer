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
            <p class="text-secondary">Próximamente: lista, alta y baja de servicios.</p>
        </asp:View>

        <%-- 2: CLIENTES --%>
        <asp:View ID="vClientes" runat="server">
            <p class="text-secondary">Próximamente: lista de clientes.</p>
        </asp:View>

        <%-- 3: REPORTES --%>
        <asp:View ID="vReportes" runat="server">
            <p class="text-secondary">Próximamente: servicios más contratados.</p>
        </asp:View>

    </asp:MultiView>
</div>
</asp:Content>
