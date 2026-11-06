<%-- 
    Document   : departamento
    Author     : josue
    Descripción: CRUD de la tabla DEPARTAMENTO (PEDEP_DEPAR) del diagrama de
                 Personal. Muestra el formulario de ingreso/edición y el
                 listado de departamentos registrados.
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="ec.edu.chango.modelo.Departamento"%>
<%@page import="ec.edu.chango.util.Html"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.util.List"%>
<%
    String ctx = request.getContextPath();

    // La página es privada: sin sesión autenticada se vuelve al login.
    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect(ctx + "/index.jsp");
        return;
    }

    Departamento departamento = (Departamento) request.getAttribute("departamento");
    boolean modoEdicion = Boolean.TRUE.equals(request.getAttribute("modoEdicion"));
    String codigoOriginal = (String) request.getAttribute("codigoOriginal");
    if (departamento == null) {
        departamento = new Departamento();
    }

    List<Departamento> departamentos = (List<Departamento>) request.getAttribute("departamentos");

    String mensajeExito = (String) request.getAttribute("mensajeExito");
    String mensajeError = (String) request.getAttribute("mensajeError");

    String codigoFormulario = departamento.getCodigoDepart() != null ? departamento.getCodigoDepart() : "";
    String descriFormulario = departamento.getDescriDeparta() != null ? departamento.getDescriDeparta() : "";
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Departamentos | SIGH</title>
        <link rel="stylesheet" href="<%= ctx%>/css/style_JCH.css">
    </head>
    <body>
        <header class="encabezado">
            <div class="bienvenida">SUBSISTEMA DE PERSONAL</div>
            <div class="titulo">Gestión de Departamentos</div>
            <div class="texto">Tabla DEPARTAMENTO (PEDEP_DEPAR) &middot; SIGH</div>
        </header>

        <main class="crud-page">
            <% if (mensajeExito != null) {%>
            <div class="alerta-exito" role="status">
                <%= Html.escape(mensajeExito)%>
            </div>
            <% }%>

            <% if (mensajeError != null) {%>
            <div class="alerta-error" role="alert">
                <%= Html.escape(mensajeError)%>
            </div>
            <% }%>

            <section class="crud-card" aria-labelledby="tituloFormulario">
                <h2 id="tituloFormulario"><%= modoEdicion ? "Editar departamento" : "Nuevo departamento"%></h2>

                <form action="<%= ctx%>/DepartamentoController" method="post" class="crud-form">
                    <input type="hidden" name="accion" value="guardar">
                    <% if (modoEdicion && codigoOriginal != null) {%>
                    <input type="hidden" name="codigoOriginal" value="<%= Html.escape(codigoOriginal)%>">
                    <% }%>

                    <div class="campo campo-codigo">
                        <label for="txtCodigo">Código</label>
                        <input type="text" id="txtCodigo" name="txtCodigo"
                               maxlength="3" minlength="3" required
                               value="<%= Html.escape(codigoFormulario)%>"
                               placeholder="Ej.: VEN">
                        <small class="ayuda-campo">3 caracteres (PEDEP_CODIGO es CHAR(3)).</small>
                    </div>

                    <div class="campo">
                        <label for="txtDescripcion">Descripción</label>
                        <input type="text" id="txtDescripcion" name="txtDescripcion"
                               maxlength="50" required
                               value="<%= Html.escape(descriFormulario)%>"
                               placeholder="Ej.: VENTAS">
                        <small class="ayuda-campo">Máximo 50 caracteres.</small>
                    </div>

                    <div class="form-acciones">
                        <button type="submit" class="btn-guardar">
                            <%= modoEdicion ? "Guardar cambios" : "Guardar"%>
                        </button>
                        <% if (modoEdicion) {%>
                        <a class="btn-secundario" href="<%= ctx%>/DepartamentoController">Cancelar</a>
                        <% }%>
                    </div>
                </form>
            </section>

            <section class="crud-card" aria-labelledby="tituloListado">
                <h2 id="tituloListado">Departamentos registrados</h2>

                <div class="tabla-contenedor">
                    <table>
                        <thead>
                            <tr>
                                <th>Código</th>
                                <th>Descripción</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (departamentos == null || departamentos.isEmpty()) {
                            %>
                            <tr>
                                <td colspan="3" class="tabla-vacia">No hay departamentos registrados.</td>
                            </tr>
                            <%
                                } else {
                                    for (Departamento dep : departamentos) {
                                        String codigoDep = dep.getCodigoDepart() != null ? dep.getCodigoDepart() : "";
                                        String codigoUrl = URLEncoder.encode(codigoDep, StandardCharsets.UTF_8);
                            %>
                            <tr>
                                <td><%= Html.escape(codigoDep)%></td>
                                <td><%= Html.escape(dep.getDescriDeparta())%></td>
                                <td class="celda-acciones">
                                    <a class="btn-editar"
                                       href="<%= ctx%>/DepartamentoController?accion=editar&amp;codigo=<%= codigoUrl%>">Editar</a>

                                    <form action="<%= ctx%>/DepartamentoController" method="post" class="form-eliminar"
                                          onsubmit="return confirm('¿Eliminar este departamento?');">
                                        <input type="hidden" name="accion" value="eliminar">
                                        <input type="hidden" name="codigo" value="<%= Html.escape(codigoDep)%>">
                                        <button type="submit" class="btn-eliminar">Eliminar</button>
                                    </form>
                                </td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </section>

            <p class="volver-inicio"><a href="<%= ctx%>/bienvenida.jsp">&larr; Volver al inicio</a></p>
        </main>
    </body>
</html>
