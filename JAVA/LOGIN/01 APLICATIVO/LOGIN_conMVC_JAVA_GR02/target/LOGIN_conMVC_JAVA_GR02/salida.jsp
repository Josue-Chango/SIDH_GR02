<%-- 
    Document   : salida
    Created on : 5 oct 2026, 08:41:56
    Author     : josue
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="DatosEncuesta" scope="request" class="ec.edu.chango.modelo.DatosEncuesta" />
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Reporte de Formulario</title>
        <link rel="stylesheet" href="css/style_JCH.css"/>
    </head>
    <body>
        <div class="encabezado">
            <div class="titulo">
                Formulario realizado con MVC
            </div>
            <div class="texto">
                Resultados finales del formulario
            </div>
        </div>
        <div class="parent">
            <div class="div1">

            </div>  
            <div class="div2">
                <table>
                    <thead>
                        <tr>
                            <td colspan="2">Datos personales</td>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Nombres</td>
                            <td>
                                <p>
                                    <jsp:getProperty name="DatosEncuesta" property="nombre"/>
                                </p>
                            </td>
                        </tr>
                        <tr>
                            <td>Apellidos</td>
                            <td>
                                <p>
                                    <jsp:getProperty name="DatosEncuesta" property="apellido"/>
                                </p>
                            </td>
                        </tr>
                        <!-- ;enguajes -->
                        <tr>
                            <th colspan="2">Lenguajes de Programación</th>
                        </tr>
                        <tr>
                            <td colspan="2" align="center">
                                <ul>
                                    <%
                                        String[] lenguajes = DatosEncuesta.getProgLeng();
                                        if (lenguajes != null) {
                                            for (int i = 0; i < lenguajes.length; i++) {
                                    %>
                                    <li><%= lenguajes[i] %></li>
                                        <%
                                                }
                                            } else {
                                        %>
                                    <li>No seleccionó lenguajes</li>
                                        <%
                                            }
                                        %>
                                </ul>

                            </td>
                        </tr>
                        <tr>
                            <th colspan="2">Archivo</th>
                        </tr>

                        <tr>
                            <td colspan="2" align="center">
                                <%
                                    String file_name = DatosEncuesta.getFoto();
                                    if (file_name != null && !file_name.equals("")) {
                                %>
                                <img src="${pageContext.request.contextPath}/resource/<%= file_name %>"
                                     alt="Imagen de perfil" style="max-width: 300px;">
                                <%
                                    } else {
                                %>
                                No se seleccionó imagen
                                <%
                                    }
                                %>
                            </td>
                        </tr>
                    </tbody>

                </table>


                <form action="index.jsp">
                    <input type="submit" value="Volver al formulario">
                </form>
            </div>
            <div class="div3">

            </div>  

        </div>

    </body>
</html>