<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="TP_Fixer_web.Login" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

  <div class="container py-5" style="max-width: 420px;">
    <h1 class="h3 fw-bold mb-4">Iniciar sesión</h1>

    <div class="mb-3">
        <label for="txtMail" class="form-label">Mail</label>
        <asp:TextBox ID="txtMail" runat="server" TextMode="Email" CssClass="form-control" />
    </div>

    <div class="mb-3">
        <label for="txtPassword" class="form-label">Contraseña</label>
        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" />
    </div>

    <asp:Label ID="lblError" runat="server" CssClass="text-danger d-block mb-3" />

    <asp:Button ID="btnIngresar" runat="server" Text="Ingresar"
        CssClass="btn btn-primary w-100" OnClick="btnIngresar_Click" />
</div>

</asp:Content>
