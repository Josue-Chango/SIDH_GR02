<%-- 
    Document   : index
    Created on : 5 oct 2026, 07:54:06
    Author     : josue
    Descripción: Inicio de sesión del módulo de Seguridad (tabla XEUSU_USUAR).
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="ec.edu.chango.util.Html"%>
<%
    String ctx = request.getContextPath();

    // Si ya existe una sesión autenticada, no se vuelve a mostrar el login.
    if (session != null && session.getAttribute("usuario") != null) {
        response.sendRedirect(ctx + "/bienvenida.jsp");
        return;
    }

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Iniciar sesión | SIGH</title>
        <link rel="stylesheet" href="<%= ctx%>/css/style_JCH.css">
        <script src="<%= ctx%>/js/login.js" defer></script>
    </head>
    <body>
        <main class="login-page">
            <section class="login-card" aria-labelledby="tituloLogin">
                <div class="login-brand">SIGH</div>
                <h1 id="tituloLogin">Inicio de sesión</h1>
                <p class="login-subtitle">
                    Subsistema de Seguridad &middot; Tabla <strong>USUARIO</strong>
                </p>

                <% if (error != null) {%>
                <div class="alerta-error" role="alert">
                    <%= Html.escape(error)%>
                </div>
                <% }%>

                <form action="<%= ctx%>/LoginController" method="post"
                      onsubmit="return validarLogin();" autocomplete="on">
                    <label for="identificacion">Cédula, correo o pasaporte</label>
                    <input type="text" id="identificacion" name="txtIdentificacion"
                           maxlength="50" required autofocus
                           placeholder="Ej.: 0102030405"
                           autocomplete="username">

                    <label for="password">Contraseña</label>
                    <input type="password" id="password" name="txtPassword"
                           maxlength="16" required
                           placeholder="Ingrese su contraseña"
                           autocomplete="current-password">

                    <button type="submit" class="btn-login">Ingresar</button>
                </form>

                <p class="login-hint">
                    Ingrese con la cédula, el correo o el pasaporte registrado en la
                    tabla <strong>PERSONA</strong> y la contraseña de <strong>USUARIO</strong>.
                </p>
            </section>
        </main>
    </body>
</html>
