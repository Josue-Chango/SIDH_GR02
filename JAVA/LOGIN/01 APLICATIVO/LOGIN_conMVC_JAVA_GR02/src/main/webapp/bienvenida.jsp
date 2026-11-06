<%-- 
    Document   : bienvenida
    Author     : josue
    Descripción: Página privada que se muestra después de un login correcto.
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="ec.edu.chango.modelo.Usuario"%>
<%@page import="ec.edu.chango.modelo.Persona"%>
<%@page import="ec.edu.chango.modelo.Perfil"%>
<%@page import="ec.edu.chango.util.Html"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%
    String ctx = request.getContextPath();
    Usuario usuario = (Usuario) session.getAttribute("usuario");

    if (usuario == null) {
        response.sendRedirect(ctx + "/index.jsp");
        return;
    }

    Persona persona = usuario.getPersona();
    List<Perfil> perfiles = usuario.getPerfiles();
    String foto = persona != null ? persona.getFoto() : null;
    boolean tieneFoto = foto != null && !foto.trim().isEmpty();
    String fechaCrea = usuario.getFechaCrea() != null
            ? new SimpleDateFormat("dd/MM/yyyy HH:mm", new Locale("es", "EC")).format(usuario.getFechaCrea())
            : "No registrada";
    String estado = usuario.getDescEstado() != null ? usuario.getDescEstado() : "SIN ESTADO";
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bienvenido | SIGH</title>
        <link rel="stylesheet" href="<%= ctx%>/css/style_JCH.css">
    </head>
    <body>
        <header class="encabezado">
            <div class="bienvenida">SESIÓN INICIADA CORRECTAMENTE</div>
            <div class="titulo">Bienvenido/a, <%= Html.escape(usuario.getNombreCompleto())%></div>
            <div class="texto">Subsistema de Seguridad &middot; SIGH</div>
        </header>

        <main class="dashboard">
            <section class="info-card" aria-labelledby="tituloPersona">
                <h2 id="tituloPersona">Datos de la persona</h2>

                <div class="persona-resumen">
                    <% if (tieneFoto) {%>
                    <img class="foto-perfil"
                         src="<%= ctx%>/resource/<%= Html.escape(foto)%>"
                         alt="Foto de <%= Html.escape(usuario.getNombreCompleto())%>">
                    <% } else { %>
                    <div class="foto-perfil foto-placeholder" aria-hidden="true">S/F</div>
                    <% }%>

                    <dl class="dl-usuario">
                        <dt>Nombres</dt>
                        <dd><%= Html.escape(persona != null ? persona.getNombresPersona() : "")%></dd>

                        <dt>Apellidos</dt>
                        <dd><%= Html.escape(persona != null ? persona.getApellidosPersona() : "")%></dd>

                        <dt>Cédula</dt>
                        <dd><%= Html.escape(persona != null ? persona.getCedula() : "")%></dd>

                        <dt>Pasaporte</dt>
                        <dd><%= Html.escape(persona != null ? persona.getPasaporte() : "")%></dd>

                        <dt>Correo</dt>
                        <dd><%= Html.escape(persona != null ? persona.getEmail() : "")%></dd>
                    </dl>
                </div>
            </section>

            <section class="info-card" aria-labelledby="tituloCuenta">
                <h2 id="tituloCuenta">Cuenta de usuario</h2>

                <dl class="dl-usuario">
                    <dt>Código</dt>
                    <dd><%= Html.escape(persona != null ? persona.getCodigoPersona() : "")%></dd>

                    <dt>Estado</dt>
                    <dd>
                        <span class="estado-badge <%= usuario.isActivo() ? "estado-activo" : "estado-inactivo"%>">
                            <%= Html.escape(estado)%>
                        </span>
                    </dd>

                    <dt>Creado el</dt>
                    <dd><%= Html.escape(fechaCrea)%></dd>
                </dl>

                <h3>Perfiles asignados</h3>
                <ul class="perfil-list">
                    <%
                        if (perfiles == null || perfiles.isEmpty()) {
                    %>
                    <li class="sin-perfiles">Sin perfiles asignados</li>
                    <%
                        } else {
                            for (Perfil perfil : perfiles) {
                    %>
                    <li>
                        <strong><%= Html.escape(perfil.getDescPerfil())%></strong>
                        <small><%= Html.escape(perfil.getCodPerfil())%></small>
                    </li>
                    <%
                            }
                        }
                    %>
                </ul>

                <h3>Módulos</h3>
                <ul class="modulo-list">
                    <li>
                        <a class="enlace-modulo" href="<%= ctx%>/DepartamentoController">
                            Gestión de Departamentos (Personal)
                        </a>
                    </li>
                </ul>

                <form action="<%= ctx%>/LogoutController" method="post" class="form-logout">
                    <button type="submit" class="btn-logout">Cerrar sesión</button>
                </form>
            </section>
        </main>
    </body>
</html>
