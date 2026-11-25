<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="ec.edu.chango.modelo.Cargo"%>
<%@page import="ec.edu.chango.modelo.Departamento"%>
<%@page import="ec.edu.chango.util.Html"%>
<%@page import="java.util.List"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%
    String ctx = request.getContextPath();
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(ctx + "/ec/edu/chango/vista/index.jsp");
        return;
    }
    // La vista recibe sus datos exclusivamente del controlador.
    if (request.getAttribute("cargos") == null && !Boolean.TRUE.equals(request.getAttribute("datosNoDisponibles"))) {
        response.sendRedirect(ctx + "/CargoController");
        return;
    }
    String filtroDepartamento = (String) request.getAttribute("filtroDepartamento");
    if (filtroDepartamento == null) {
        filtroDepartamento = request.getParameter("filtroDepartamento");
        if (filtroDepartamento == null) filtroDepartamento = "";
    }
    String filtroUrl = URLEncoder.encode(filtroDepartamento, StandardCharsets.UTF_8);
    String urlListado = ctx + "/CargoController" + (filtroDepartamento.isEmpty() ? "" : "?filtroDepartamento=" + filtroUrl);
    Cargo formulario = (Cargo) request.getAttribute("cargo");
    if (formulario == null) {
        formulario = new Cargo();
        formulario.setCodigoDepart(filtroDepartamento);
    }
    boolean edicion = Boolean.TRUE.equals(request.getAttribute("modoEdicion"));
    boolean noDisponible = Boolean.TRUE.equals(request.getAttribute("datosNoDisponibles"));
    List<Cargo> cargos = (List<Cargo>) request.getAttribute("cargos");
    List<Departamento> departamentos = (List<Departamento>) request.getAttribute("departamentos");
    boolean sinDepartamentos = departamentos == null || departamentos.isEmpty();
    String csrf = Html.escape(session.getAttribute("cargoCsrf"));
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cargos | SIGH</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style_JCH.css">
</head>
<body>
<header class="encabezado">
    <div class="bienvenida">SUBSISTEMA DE PERSONAL</div>
    <div class="titulo">Gestión de Cargos</div>
    <div class="texto">Cargos y departamentos &middot; SIGH</div>
</header>
<main class="crud-page">
    <% if (request.getAttribute("mensajeExito") != null) { %>
    <div class="alerta-exito" role="status"><%= Html.escape(request.getAttribute("mensajeExito")) %></div>
    <% } if (request.getAttribute("mensajeError") != null) { %>
    <div class="alerta-error" role="alert"><%= Html.escape(request.getAttribute("mensajeError")) %></div>
    <% } if (noDisponible) { %>
    <p><a class="btn-secundario" href="<%= Html.escape(urlListado) %>">Reintentar</a></p>
    <% } else { %>
    <section class="crud-card" aria-labelledby="tituloFormulario">
        <h2 id="tituloFormulario"><%= edicion ? "Editar cargo" : "Nuevo cargo" %></h2>
        <% if (sinDepartamentos) { %>
        <p>Primero <a href="<%= ctx %>/DepartamentoController">registre un departamento</a> para crear cargos.</p>
        <% } %>
        <form action="<%= ctx %>/CargoController" method="post" class="crud-form">
            <input type="hidden" name="accion" value="guardar">
            <input type="hidden" name="csrf" value="<%= csrf %>">
            <input type="hidden" name="filtroDepartamento" value="<%= Html.escape(filtroDepartamento) %>">
            <input type="hidden" name="modo" value="<%= edicion ? "editar" : "nuevo" %>">
            <div class="campo">
                <label for="departamento">Departamento</label>
                <% if (edicion) { %>
                <input type="hidden" name="departamento" value="<%= Html.escape(formulario.getCodigoDepart()) %>">
                <input id="departamento" type="text" readonly value="<%= Html.escape(formulario.getCodigoDepart()) %>">
                <% } else { %>
                <select id="departamento" name="departamento" required <%= sinDepartamentos ? "disabled" : "" %>>
                    <option value="">Seleccione un departamento</option>
                    <% if (departamentos != null) { for (Departamento dep : departamentos) { %>
                    <option value="<%= Html.escape(dep.getCodigoDepart()) %>"
                        <%= dep.getCodigoDepart().equals(formulario.getCodigoDepart()) ? "selected" : "" %>>
                        <%= Html.escape(dep.getCodigoDepart()) %> — <%= Html.escape(dep.getDescriDeparta()) %>
                    </option>
                    <% } } %>
                </select>
                <% } %>
            </div>
            <div class="campo campo-codigo">
                <label for="codigo">Código del cargo</label>
                <input type="text" id="codigo" name="codigo" minlength="3" maxlength="3" required
                    value="<%= Html.escape(formulario.getCodigoCargo()) %>" <%= edicion ? "readonly" : "" %> placeholder="Ej.: ADM">
                <small class="ayuda-campo">3 caracteres. El código puede repetirse en otro departamento.</small>
            </div>
            <div class="campo">
                <label for="descripcion">Descripción</label>
                <input type="text" id="descripcion" name="descripcion" maxlength="50" required
                    value="<%= Html.escape(formulario.getDescriCargo()) %>" placeholder="Ej.: Administrador">
                <small class="ayuda-campo">Máximo 50 caracteres.<%= edicion ? " El departamento y el código se conservan." : "" %></small>
            </div>
            <div class="form-acciones">
                <button class="btn-guardar" type="submit" <%= sinDepartamentos ? "disabled" : "" %>><%= edicion ? "Guardar cambios" : "Guardar cargo" %></button>
                <% if (edicion) { %><a class="btn-secundario" href="<%= Html.escape(urlListado) %>">Cancelar</a><% } %>
            </div>
        </form>
    </section>
    <section class="crud-card" aria-labelledby="tituloListado">
        <h2 id="tituloListado">Cargos registrados</h2>
        <form action="<%= ctx %>/CargoController" method="get" class="crud-form" role="search">
            <div class="campo">
                <label for="filtroDepartamento">Buscar cargos por departamento</label>
                <select id="filtroDepartamento" name="filtroDepartamento" onchange="this.form.requestSubmit()">
                    <option value="">Todos los departamentos</option>
                    <% if (departamentos != null) { for (Departamento dep : departamentos) { %>
                    <option value="<%= Html.escape(dep.getCodigoDepart()) %>"
                        <%= dep.getCodigoDepart().equals(filtroDepartamento) ? "selected" : "" %>>
                        <%= Html.escape(dep.getCodigoDepart()) %> — <%= Html.escape(dep.getDescriDeparta()) %>
                    </option>
                    <% } } %>
                </select>
            </div>
            <div class="form-acciones"><button type="submit" class="btn-guardar">Consultar</button></div>
        </form>
        <p role="status"><%= cargos == null ? 0 : cargos.size() %> cargo(s) encontrado(s).</p>
        <div class="acciones-reportes">
            <a class="btn-reporte" target="_blank" rel="noopener" href="<%= ctx %>/ReporteController?r=cargos&amp;departamento=<%= Html.escape(filtroUrl) %>">Reporte PDF<%= filtroDepartamento.isEmpty() ? " de cargos" : " del departamento seleccionado" %></a>
        </div>
        <div class="tabla-contenedor">
            <table>
                <thead><tr><th>Departamento</th><th>Código</th><th>Descripción</th><th>Acciones</th></tr></thead>
                <tbody>
                    <% if (cargos == null || cargos.isEmpty()) { %>
                    <tr><td colspan="4" class="tabla-vacia"><%= filtroDepartamento.isEmpty() ? "No hay cargos registrados." : "No hay cargos registrados en el departamento seleccionado." %></td></tr>
                    <% } else { for (Cargo cargo : cargos) {
                        String enlace = ctx + "/CargoController?accion=editar&departamento="
                            + URLEncoder.encode(cargo.getCodigoDepart(), StandardCharsets.UTF_8)
                            + "&codigo=" + URLEncoder.encode(cargo.getCodigoCargo(), StandardCharsets.UTF_8)
                            + "&filtroDepartamento=" + filtroUrl;
                    %>
                    <tr>
                        <td><%= Html.escape(cargo.getCodigoDepart()) %> — <%= Html.escape(cargo.getDescriDepart()) %></td>
                        <td><%= Html.escape(cargo.getCodigoCargo()) %></td>
                        <td><%= Html.escape(cargo.getDescriCargo()) %></td>
                        <td class="celda-acciones">
                            <a class="btn-editar" href="<%= Html.escape(enlace) %>">Editar</a>
                            <form action="<%= ctx %>/CargoController" method="post" class="form-eliminar"
                                  onsubmit="return confirm('¿Eliminar este cargo?');">
                                <input type="hidden" name="accion" value="eliminar">
                                <input type="hidden" name="csrf" value="<%= csrf %>">
            <input type="hidden" name="filtroDepartamento" value="<%= Html.escape(filtroDepartamento) %>">
                                <input type="hidden" name="departamento" value="<%= Html.escape(cargo.getCodigoDepart()) %>">
                                <input type="hidden" name="codigo" value="<%= Html.escape(cargo.getCodigoCargo()) %>">
                                <button type="submit" class="btn-eliminar">Eliminar</button>
                            </form>
                        </td>
                    </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </section>
    <% } %>
    <p class="volver-inicio"><a href="<%= ctx %>/ec/edu/chango/vista/bienvenida.jsp">&larr; Volver al inicio</a></p>
</main>
</body>
</html>
