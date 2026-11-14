<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Registro.aspx.cs" Inherits="TP_Fixer_web.Registro" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<div class="container py-5" style="max-width: 420px;">
    <h1 class="h3 fw-bold mb-4">Crear cuenta de cliente</h1>

    <%-- Aviso que aparece solo si viene de intentar contratar --%>
    <asp:Panel ID="pnlAviso" runat="server" CssClass="alert alert-info" Visible="false">
        Registrate para poder contratar el servicio.
    </asp:Panel>

    <div class="mb-3">
        <label for="txtNombre" class="form-label">Nombre y apellido</label>
        <asp:TextBox ID="txtNombre" runat="server" MaxLength="50" CssClass="form-control" />
    </div>
    <div class="mb-3">
        <label for="txtMail" class="form-label">Mail</label>
        <asp:TextBox ID="txtMail" runat="server" TextMode="Email" MaxLength="100" CssClass="form-control" />
    </div>
    <div class="mb-3">
        <label for="txtTelefono" class="form-label">Teléfono</label>
        <asp:TextBox ID="txtTelefono" runat="server" MaxLength="50" CssClass="form-control" />
    </div>
    <div class="mb-3">
        <label for="txtPassword" class="form-label">Contraseña</label>
        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" />
    </div>
    <div class="mb-3">
        <label for="txtPassword2" class="form-label">Repetir contraseña</label>
        <asp:TextBox ID="txtPassword2" runat="server" TextMode="Password" CssClass="form-control" />
    </div>

    <asp:Label ID="lblError" runat="server" CssClass="text-danger d-block mb-3" />

    <asp:Button ID="btnRegistrar" runat="server" Text="Registrarme"
        CssClass="btn btn-primary w-100" OnClick="btnRegistrar_Click" />

    <p class="text-center mt-3 mb-0">
        ¿Ya tenés cuenta? <a href="Login.aspx">Iniciá sesión</a>
    </p>
</div>

</asp:Content>