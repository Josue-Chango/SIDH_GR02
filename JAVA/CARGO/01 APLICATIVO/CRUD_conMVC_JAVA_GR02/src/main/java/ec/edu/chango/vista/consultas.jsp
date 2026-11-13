<%--
    Document   : consultas
    Author     : josue
    Descripción: Apartado de consulta del módulo de Personal. Muestra un
                 listbox con los departamentos de la tabla PEDEP_DEPAR y un
                 combobox con los cargos de la tabla PECAR_CARGO. Al elegir
                 uno o varios departamentos y pulsar Consultar, el combobox
                 muestra únicamente los cargos de esos departamentos.
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="ec.edu.chango.modelo.Cargo"%>
<%@page import="ec.edu.chango.modelo.Departamento"%>
<%@page import="ec.edu.chango.util.Html"%>
<%@page import="java.util.List"%>
<%
    String ctx = request.getContextPath();

    // La página es privada: sin sesión autenticada se vuelve al login.
    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect(ctx + "/ec/edu/chango/vista/index.jsp");
        return;
    }

    List<Cargo> cargos = (List<Cargo>) request.getAttribute("cargos");
    List<Departamento> departamentos = (List<Departamento>) request.getAttribute("departamentos");
    List<String> departamentosSeleccionados
            = (List<String>) request.getAttribute("departamentosSeleccionados");

    String mensajeError = (String) request.getAttribute("mensajeError");
    String mensajeInfo = (String) request.getAttribute("mensajeInfo");

    boolean filtroActivo = departamentosSeleccionados != null && !departamentosSeleccionados.isEmpty();
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cargos y Departamentos | SIGH</title>
        <link rel="stylesheet" href="<%= ctx%>/css/style_JCH.css">
    </head>
    <body>
        <header class="encabezado">
            <div class="bienvenida">SUBSISTEMA DE PERSONAL</div>
            <div class="titulo">Consulta de Cargos y Departamentos</div>
            <div class="texto">Tablas DEPARTAMENTO (PEDEP_DEPAR) y CARGO (PECAR_CARGO) &middot; SIGH</div>
        </header>

        <main class="crud-page">
            <% if (mensajeError != null) {%>
            <div class="alerta-error" role="alert">
                <%= Html.escape(mensajeError)%>
            </div>
            <% }%>

            <% if (mensajeInfo != null) {%>
            <div class="alerta-exito" role="status">
                <%= Html.escape(mensajeInfo)%>
            </div>
            <% }%>

            <section class="crud-card" aria-labelledby="tituloConsulta">
                <h2 id="tituloConsulta">Cargos por Departamento</h2>

                <form action="<%= ctx%>/ConsultasController" method="post" class="crud-form consulta-form">
                    <input type="hidden" name="accion" value="consultar">

                    <div class="consulta-columnas">
                        <div class="campo">
                            <label for="lstDepartamento">Departamentos (PEDEP_DEPAR)</label>
                            <select id="lstDepartamento" name="lstDepartamento" multiple size="8" required>
                                <%
                                    if (departamentos != null) {
                                        for (Departamento dep : departamentos) {
                                            String codigoDep = dep.getCodigoDepart() != null ? dep.getCodigoDepart() : "";
                                            String etiqueta = codigoDep + " - " + dep.getDescriDeparta();
                                            boolean marcado = filtroActivo && departamentosSeleccionados.contains(codigoDep);
                                %>
                                <option value="<%= Html.escape(codigoDep)%>" <%= marcado ? "selected" : ""%>>
                                    <%= Html.escape(etiqueta)%>
                                </option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                            <small class="ayuda-campo">Elija un departamento (o varios con Ctrl / Shift).</small>
                        </div>

                        <div class="campo">
                            <label for="cmbCargo">Cargos (PECAR_CARGO)</label>
                            <select id="cmbCargo" name="cmbCargo" size="1">
                                <option value="">-- <%= filtroActivo ? "Cargos del departamento seleccionado" : "Todos los cargos" %> --</option>
                                <%
                                    if (cargos != null && !cargos.isEmpty()) {
                                        for (Cargo cargo : cargos) {
                                            String codDep = cargo.getCodigoDepart() != null ? cargo.getCodigoDepart() : "";
                                            String codCar = cargo.getCodigoCargo() != null ? cargo.getCodigoCargo() : "";
                                            String etiqueta = codCar + " - " + cargo.getDescriCargo()
                                                    + "  [" + codDep + " - " + cargo.getDescriDepart() + "]";
                                %>
                                <option value="<%= Html.escape(codDep + "|" + codCar)%>">
                                    <%= Html.escape(etiqueta)%>
                                </option>
                                <%
                                        }
                                    } else if (filtroActivo) {
                                %>
                                <option value="" disabled>El departamento seleccionado no tiene cargos.</option>
                                <%
                                    }
                                %>
                            </select>
                            <small class="ayuda-campo" id="ayudaCargo">
                                <%= filtroActivo
                                        ? "Presione Limpiar para volver a ver todos los cargos."
                                        : "Elija un departamento y presione Consultar para filtrar los cargos." %>
                            </small>
                        </div>
                    </div>

                    <div class="form-acciones">
                        <button type="submit" class="btn-guardar">Consultar</button>
                        <a class="btn-secundario" href="<%= ctx%>/ConsultasController">Limpiar</a>
                    </div>
                </form>
            </section>

            <p class="volver-inicio"><a href="<%= ctx%>/ec/edu/chango/vista/bienvenida.jsp">&larr; Volver al inicio</a></p>
        </main>
    </body>
</html>
