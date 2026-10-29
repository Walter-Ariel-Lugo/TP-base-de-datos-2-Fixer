<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="TP_Fixer_web.Default" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
     <%-- Seccion que se accede desde el menu con el enlace QUE ES ? agregar estilo mas adelante --%>
    <section id="que-es">
    <h2>¿Qué es Fixer?</h2>
    <p>Arreglos del hogar con precio claro desde el principio</p>

    <div>
        <div>
            <h3>¿Por qué cuesta tanto arreglar lo simple?</h3>
            <p>Nadie quiere venir por un enchufe flojo o una canilla que gotea, y cuando alguien viene,
               el presupuesto llega recién después de la visita.</p>
            <p>En Fixer elegís los servicios que necesitás de un catálogo y el sistema calcula
               al instante el presupuesto total y el tiempo estimado de trabajo.</p>
        </div>

        <div>
            <h3>Técnicos habilitados para tu arreglo</h3>
            <p>Cada técnico está habilitado por nuestro equipo solo para los servicios que sabe hacer.
               Cuando armás tu pedido, te proponemos únicamente técnicos disponibles que pueden
               realizar todos los servicios que elegiste.</p>
        </div>


    </div>
</section>

    <%-- Categorías: el Repeater arma una tarjeta por cada TipoServicio.
     Por ahora la lista se carga a mano en Default.aspx.cs; después sale de la base. --%>
      <section id="servicios">
    <h2>¿Qué necesitás arreglar?</h2>
          
    <asp:Repeater ID="rptCategorias" runat="server">
        <ItemTemplate>
            <div>
                <a href='Servicios.aspx?tipo=<%# Eval("IDTipoServicio") %>'>
                    <h3><%# Eval("Nombre") %></h3>
                    <p><%# Eval("Descripcion") %></p>
                </a>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</section>
    <%-- seccion informativa para futuros fixer con enlace a correo electronico,
    luego podria agregarse dejar mensaje directamente en la web pero habia que modificar la bd para almacenar los mensajes --%>
    <section id="sumate">
    <h2>Sumate como fixer</h2>
    <p>¿Sabés arreglar cosas de la casa? Escribinos un mail contándonos qué tipo de
       arreglos sabés hacer y nos contactamos para habilitarte como técnico en nuestra plataforma.</p>

    <a href="mailto:contacto@fixer.com?subject=Quiero sumarme como fixer">Escribinos un mail</a>
</section>

</asp:Content>
