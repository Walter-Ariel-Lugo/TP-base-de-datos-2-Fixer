<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="TP_Fixer_web.Default" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
 
<%--    ¿QUÉ ES FIXER?    --%>
<section id="que-es" class="bg-primary text-white py-5">
    <div class="container">
        <h2 class="fw-bold">¿Qué es Fixer?</h2>
        <p class="mb-4 opacity-75">Arreglos del hogar con precio claro desde el principio</p>

        <div class="row g-4">
            <div class="col-6">
                <div class="card h-100 border-0 rounded-4 shadow p-4">
                    <h3 class="h5 fw-bold">¿Por qué cuesta tanto arreglar lo simple?</h3>
                    <p class="text-secondary">Nadie quiere venir por un enchufe flojo o una canilla que gotea, y cuando alguien viene,
                       el presupuesto llega recién después de la visita.</p>
                    <p class="text-secondary mb-0">En Fixer elegís los servicios que necesitás de un catálogo y el sistema calcula
                       al instante el presupuesto total y el tiempo estimado de trabajo.</p>
                </div>
            </div>
            <div class="col-6">
                <div class="card h-100 border-0 rounded-4 shadow p-4">
                    <h3 class="h5 fw-bold">Técnicos habilitados para tu arreglo</h3>
                    <p class="text-secondary mb-0">Cada técnico está habilitado por nuestro equipo solo para los servicios que sabe hacer.
                       Cuando armás tu pedido, te proponemos únicamente técnicos disponibles que pueden
                       realizar todos los servicios que elegiste.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<%--CATEGORÍAS (salen de la base)--%>
<section id="servicios" class="bg-body-tertiary py-5">
    <div class="container">
        <h2 class="fw-bold">¿Qué necesitás arreglar?</h2>
        <p class="text-secondary mb-4">Elegí una categoría para ver sus servicios, con precio y tiempo estimado.</p>

        <div class="row row-cols-4 g-4">
            <asp:Repeater ID="rptCategorias" runat="server" OnItemCommand="rptCategorias_ItemCommand">
                <ItemTemplate>
                    <div class="col">
                        <div class="card h-100 border-0 border-top border-4 border-primary rounded-4 shadow-sm p-4">
                            <h3 class="h5 fw-bold"><%# Eval("Nombre") %></h3>
                            <p class="text-secondary small mb-0"><%# Eval("Descripcion") %></p>
                            <asp:LinkButton ID="lnkCategoria" runat="server" CssClass="stretched-link"
    CommandName="VerServicios"
    CommandArgument='<%# Eval("IDTipoServicio") %>' />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</section>

<%--   SUMATE COMO FIXER   --%>
<section id="sumate" class="bg-primary text-white py-5">
    <div class="container">
        <div class="card border-0 rounded-4 shadow p-5 text-center">
            <h2 class="fw-bold">Sumate como fixer</h2>
            <p class="text-secondary mx-auto mb-4" style="max-width: 600px;">
                ¿Sabés arreglar cosas de la casa? Escribinos un mail contándonos qué tipo de
                arreglos sabés hacer y nos contactamos para habilitarte como técnico en nuestra plataforma.
            </p>
            <div>
                <a href="mailto:contacto@fixer.com?subject=Quiero sumarme como fixer"
                   class="btn btn-primary btn-lg rounded-pill px-4">Escribinos un mail</a>
            </div>
        </div>
    </div>
</section>
<div class="modal fade" id="modalServicios" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content rounded-4">

            <div class="modal-header">
                <h5 class="modal-title fw-bold">
                    <asp:Label ID="lblCategoriaModal" runat="server" />
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <asp:Repeater ID="rptServicios" runat="server">
                    <ItemTemplate>
                        <div class="d-flex justify-content-between align-items-center border-bottom py-3">
                            <div>
                                <div class="fw-semibold"><%# Eval("Nombre") %></div>
                                <div class="text-secondary small"><%# Eval("Descripcion") %></div>
                            </div>
                            <div class="text-end">
                                <div class="fw-bold text-primary">$<%# Eval("Precio", "{0:N0}") %></div>
                                <div class="text-secondary small"><%# Eval("TiempoPromedio") %> min</div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Label ID="lblSinServicios" runat="server" Visible="false"
                    CssClass="text-secondary" Text="Todavía no hay servicios en esta categoría." />
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Cerrar</button>
            </div>

        </div>
    </div>
</div>
</asp:Content>
