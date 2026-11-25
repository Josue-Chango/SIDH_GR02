<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="ec.edu.chango.modelo.Empleado"%>
<%@page import="ec.edu.chango.modelo.EmpleadoAcademico"%>
<%@page import="ec.edu.chango.modelo.EmpleadoFamiliar"%>
<%@page import="ec.edu.chango.modelo.Catalogo"%>
<%@page import="ec.edu.chango.util.Html"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%
    String ctx = request.getContextPath();
    if (session.getAttribute("usuario") == null) {
        response.sendRedirect(ctx + "/ec/edu/chango/vista/index.jsp");
        return;
    }
    // La vista recibe sus datos exclusivamente del controlador.
    if (request.getAttribute("empleados") == null && !Boolean.TRUE.equals(request.getAttribute("datosNoDisponibles"))) {
        response.sendRedirect(ctx + "/EmpleadoController");
        return;
    }
    Empleado formulario = (Empleado) request.getAttribute("empleado");
    if (formulario == null) {
        formulario = new Empleado();
    }
    boolean edicion = Boolean.TRUE.equals(request.getAttribute("modoEdicion"));
    boolean noDisponible = Boolean.TRUE.equals(request.getAttribute("datosNoDisponibles"));
    List<Empleado> empleados = (List<Empleado>) request.getAttribute("empleados");
    List<Catalogo> generos = (List<Catalogo>) request.getAttribute("generos");
    if (generos == null) generos = new ArrayList<>();
    List<Catalogo> estadosCiviles = (List<Catalogo>) request.getAttribute("estadosCiviles");
    if (estadosCiviles == null) estadosCiviles = new ArrayList<>();
    List<EmpleadoAcademico> academicos = formulario.getAcademicos();
    if (academicos == null) academicos = new ArrayList<>();
    List<EmpleadoFamiliar> familiares = formulario.getFamiliares();
    if (familiares == null) familiares = new ArrayList<>();
    String csrf = Html.escape(session.getAttribute("empleadoCsrf"));
    String[] tiposSangre = {"O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-"};
    String[] parentescos = {"PADRE", "MADRE", "CONYUGE", "HIJO/A", "HERMANO/A", "OTRO"};
    String[] parentescosTexto = {"Padre", "Madre", "Cónyuge", "Hijo/a", "Hermano/a", "Otro"};
    String fotoActual = formulario.getFoto() == null ? "" : formulario.getFoto();
    boolean tieneFoto = !fotoActual.isEmpty();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Empleados | SIGH</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style_JCH.css">
    <link rel="stylesheet" href="<%= ctx %>/css/tabpage.css">
</head>
<body>
<header class="encabezado">
    <div class="bienvenida">SUBSISTEMA DE PERSONAL</div>
    <div class="titulo">Mantenimiento de Empleados</div>
    <div class="texto">Ficha con Tab Page &middot; SIGH</div>
</header>
<main class="crud-page">
    <% if (request.getAttribute("mensajeExito") != null) { %>
    <div class="alerta-exito" role="status"><%= Html.escape(request.getAttribute("mensajeExito")) %></div>
    <% } if (request.getAttribute("mensajeError") != null) { %>
    <div class="alerta-error" role="alert"><%= Html.escape(request.getAttribute("mensajeError")) %></div>
    <% } if (noDisponible) { %>
    <p><a class="btn-secundario" href="<%= ctx %>/EmpleadoController">Reintentar</a></p>
    <% } else { %>

    <%-- ================= MARCO DE LA FICHA (fuera del tab page) ================= --%>
    <section class="crud-card" aria-labelledby="tituloMarco">
        <h2 id="tituloMarco"><%= edicion ? "Editar ficha del empleado" : "Nueva ficha de empleado" %></h2>
        <p class="tp-descripcion">Marco de página: identificación del empleado con foto, apellidos y
            nombres. El detalle se organiza en pestañas más abajo.</p>
        <form action="<%= ctx %>/EmpleadoController" method="post" enctype="multipart/form-data" class="crud-form">
            <input type="hidden" name="accion" value="guardar">
            <input type="hidden" name="csrf" value="<%= csrf %>">
            <input type="hidden" name="modo" value="<%= edicion ? "editar" : "nuevo" %>">
            <input type="hidden" name="fotoActual" value="<%= Html.escape(fotoActual) %>">

            <div class="tp-marco-cuerpo">
                <div class="tp-marco-foto">
                    <% if (tieneFoto) { %>
                    <img class="tp-foto" id="tpFotoImg" src="<%= ctx %>/resource/<%= Html.escape(fotoActual) %>"
                         alt="Foto del empleado">
                    <div class="tp-foto-placeholder" id="tpFotoSf" aria-hidden="true" style="display:none;">S/F</div>
                    <% } else { %>
                    <div class="tp-foto-placeholder" id="tpFotoSf" aria-hidden="true">S/F</div>
                    <img class="tp-foto" id="tpFotoImg" src="" alt="" style="display:none;">
                    <% } %>
                    <label for="tpFotoInput">Foto de perfil (opcional)</label>
                    <input type="file" id="tpFotoInput" name="foto" accept="image/*">
                    <small class="ayuda-campo">JPG o PNG. Se guarda como JPEG con el código de la persona como nombre.</small>
                </div>
                <div class="tp-marco-campos">
                    <div class="campo">
                        <label for="codigo">Código de persona</label>
                        <input type="text" id="codigo" name="codigo" minlength="1" maxlength="10" required
                               pattern="[A-Za-z0-9\-]{1,10}" value="<%= Html.escape(formulario.getCodigo()) %>"
                               <%= edicion ? "readonly" : "" %> placeholder="Ej.: P000000001">
                        <small class="ayuda-campo">Hasta 10 letras, números o guiones.<%= edicion ? " El código no se puede modificar." : "" %></small>
                    </div>
                    <div class="campo">
                        <label for="apellidos">Apellidos</label>
                        <input type="text" id="apellidos" name="apellidos" maxlength="50" required
                               value="<%= Html.escape(formulario.getApellidos()) %>" placeholder="Apellidos completos">
                    </div>
                    <div class="campo">
                        <label for="nombres">Nombres</label>
                        <input type="text" id="nombres" name="nombres" maxlength="50" required
                               value="<%= Html.escape(formulario.getNombres()) %>" placeholder="Nombres completos">
                    </div>
                </div>
            </div>

            <%-- ================= TAB PAGE (3 pestañas) ================= --%>
            <div class="tp-tabpage">
                <nav class="tp-tabs" role="tablist" aria-label="Secciones de la ficha">
                    <button type="button" class="tp-pill tp-activa" data-panel="panelGenerales" role="tab">
                        Datos Generales
                    </button>
                    <button type="button" class="tp-pill" data-panel="panelAcademicos" role="tab">
                        Datos Académicos
                    </button>
                    <button type="button" class="tp-pill" data-panel="panelFamiliares" role="tab">
                        Datos Familiares
                    </button>
                </nav>

                <div class="tp-contenido">
                    <%-- ---- Pestaña 1: Datos Generales ---- --%>
                    <section id="panelGenerales" class="tp-panel tp-activa" role="tabpanel">
                        <h3>Datos Generales</h3>
                        <p class="tp-descripcion">Sexo, peso, estado civil y tipo de sangre del empleado.</p>
                        <div class="tp-rejilla">
                            <div class="campo">
                                <label for="fechaNacimiento">Fecha de nacimiento <span class="obligatorio">*</span></label>
                                <input type="date" id="fechaNacimiento" name="fechaNacimiento" required
                                       value="<%= formulario.getFechaNacimiento() == null ? "" : formulario.getFechaNacimiento().toString() %>">
                            </div>
                            <div class="campo">
                                <label for="genero">Sexo <span class="obligatorio">*</span></label>
                                <select id="genero" name="genero" required>
                                    <option value="">-- Seleccione --</option>
                                    <% for (Catalogo genero : generos) { %>
                                    <option value="<%= Html.escape(genero.getCodigo()) %>"
                                        <%= genero.getCodigo().equals(formulario.getCodigoGenero()) ? "selected" : "" %>>
                                        <%= Html.escape(genero.getDescri()) %>
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="campo">
                                <label for="peso">Peso (kg)</label>
                                <input type="number" id="peso" name="peso" min="1" max="500" step="0.01"
                                       value="<%= formulario.getPeso() > 0 ? formulario.getPeso() : "" %>"
                                       placeholder="Ej.: 68.5">
                            </div>
                            <div class="campo">
                                <label for="estadoCivil">Estado civil</label>
                                <select id="estadoCivil" name="estadoCivil">
                                    <option value="">-- Seleccione --</option>
                                    <% for (Catalogo estado : estadosCiviles) { %>
                                    <option value="<%= Html.escape(estado.getCodigo()) %>"
                                        <%= estado.getCodigo().equals(formulario.getCodigoEstadoCivil()) ? "selected" : "" %>>
                                        <%= Html.escape(estado.getDescri()) %>
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="campo">
                                <label for="tipoSangre">Tipo de sangre</label>
                                <select id="tipoSangre" name="tipoSangre">
                                    <option value="">-- Seleccione --</option>
                                    <% for (String tipo : tiposSangre) { %>
                                    <option value="<%= tipo %>"
                                        <%= tipo.equals(formulario.getTipoSangre()) ? "selected" : "" %>><%= tipo %></option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                    </section>

                    <%-- ---- Pestaña 2: Datos Académicos (subtabla) ---- --%>
                    <section id="panelAcademicos" class="tp-panel" role="tabpanel">
                        <h3>Datos Académicos</h3>
                        <p class="tp-descripcion">Subtabla de estudios del empleado: agregue una fila por
                            cada nivel, institución y título.</p>
                        <table class="tp-grilla">
                            <thead>
                                <tr><th>Nivel</th><th>Institución</th><th>Título</th><th></th></tr>
                            </thead>
                            <tbody id="cuerpoAcademica" data-plantilla="plantillaAcademica">
                                <% for (EmpleadoAcademico academico : academicos) { %>
                                <tr>
                                    <td><input type="text" name="acaNivel" maxlength="50" value="<%= Html.escape(academico.getNivel()) %>" placeholder="Ej.: Licenciado"></td>
                                    <td><input type="text" name="acaInstitucion" maxlength="100" value="<%= Html.escape(academico.getInstitucion()) %>" placeholder="Ej.: Escuela Politécnica Nacional"></td>
                                    <td><input type="text" name="acaTitulo" maxlength="100" value="<%= Html.escape(academico.getTitulo()) %>" placeholder="Ej.: Licenciado en Informática"></td>
                                    <td class="tp-celda-accion"><button type="button" class="tp-quitar" title="Quitar fila">X</button></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <template id="plantillaAcademica">
                            <tr>
                                <td><input type="text" name="acaNivel" maxlength="50" placeholder="Ej.: Licenciado"></td>
                                <td><input type="text" name="acaInstitucion" maxlength="100" placeholder="Ej.: Escuela Politécnica Nacional"></td>
                                <td><input type="text" name="acaTitulo" maxlength="100" placeholder="Ej.: Licenciado en Informática"></td>
                                <td class="tp-celda-accion"><button type="button" class="tp-quitar" title="Quitar fila">X</button></td>
                            </tr>
                        </template>
                        <div class="tp-acciones-grilla">
                            <button type="button" class="btn-secundario tp-agregar"
                                    data-grilla="cuerpoAcademica" data-plantilla="plantillaAcademica">+ Agregar estudio</button>
                        </div>
                    </section>

                    <%-- ---- Pestaña 3: Datos Familiares (subtabla) ---- --%>
                    <section id="panelFamiliares" class="tp-panel" role="tabpanel">
                        <h3>Datos Familiares</h3>
                        <p class="tp-descripcion">Subtabla de familiares: persona (parentesco), apellidos
                            y nombres, y fecha de nacimiento.</p>
                        <table class="tp-grilla">
                            <thead>
                                <tr><th>Persona</th><th>Apellidos y nombres</th><th>Fecha de nacimiento</th><th></th></tr>
                            </thead>
                            <tbody id="cuerpoFamilia" data-plantilla="plantillaFamilia">
                                <% for (EmpleadoFamiliar familiar : familiares) { %>
                                <tr>
                                    <td>
                                        <select name="famPersona">
                                            <% for (int i = 0; i < parentescos.length; i++) { %>
                                            <option value="<%= parentescos[i] %>"
                                                <%= parentescos[i].equals(familiar.getPersona()) ? "selected" : "" %>><%= parentescosTexto[i] %></option>
                                            <% } %>
                                        </select>
                                    </td>
                                    <td><input type="text" name="famNombres" maxlength="100" value="<%= Html.escape(familiar.getNombres()) %>" placeholder="Ej.: PERALTA LÓPEZ CARLOS"></td>
                                    <td><input type="date" name="famFecha" value="<%= familiar.getFechaNacimiento() == null ? "" : familiar.getFechaNacimiento().toString() %>"></td>
                                    <td class="tp-celda-accion"><button type="button" class="tp-quitar" title="Quitar fila">X</button></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <template id="plantillaFamilia">
                            <tr>
                                <td>
                                    <select name="famPersona">
                                        <option value="PADRE">Padre</option>
                                        <option value="MADRE">Madre</option>
                                        <option value="CONYUGE">Cónyuge</option>
                                        <option value="HIJO/A">Hijo/a</option>
                                        <option value="HERMANO/A">Hermano/a</option>
                                        <option value="OTRO">Otro</option>
                                    </select>
                                </td>
                                <td><input type="text" name="famNombres" maxlength="100" placeholder="Ej.: PERALTA LÓPEZ CARLOS"></td>
                                <td><input type="date" name="famFecha"></td>
                                <td class="tp-celda-accion"><button type="button" class="tp-quitar" title="Quitar fila">X</button></td>
                            </tr>
                        </template>
                        <div class="tp-acciones-grilla">
                            <button type="button" class="btn-secundario tp-agregar"
                                    data-grilla="cuerpoFamilia" data-plantilla="plantillaFamilia">+ Agregar familiar</button>
                        </div>
                    </section>
                </div>
            </div>

            <div class="form-acciones">
                <button class="btn-guardar" type="submit"><%= edicion ? "Guardar cambios de la ficha" : "Guardar ficha" %></button>
                <% if (edicion) { %>
                <a class="btn-secundario" href="<%= ctx %>/EmpleadoController">Cancelar</a>
                <a class="btn-reporte" target="_blank" rel="noopener" href="<%= ctx %>/ReporteController?r=ficha&amp;codigo=<%= Html.escape(URLEncoder.encode(formulario.getCodigo(), StandardCharsets.UTF_8)) %>">Ficha PDF guardada</a>
                <% } %>
            </div>
        </form>
    </section>

    <%-- ================= LISTADO DE EMPLEADOS ================= --%>
    <section class="crud-card" aria-labelledby="tituloListado">
        <h2 id="tituloListado">Empleados registrados</h2>
        <div class="acciones-reportes">
            <a class="btn-reporte" href="<%= ctx %>/ReporteController?r=empleados" target="_blank" rel="noopener">Reporte PDF de empleados</a>
        </div>
        <p role="status"><%= empleados == null ? 0 : empleados.size() %> empleado(s) encontrado(s).</p>
        <div class="tabla-contenedor">
            <table>
                <thead>
                    <tr><th>Foto</th><th>Código</th><th>Apellidos y nombres</th><th>Sexo</th><th>Estado civil</th><th>Acciones</th></tr>
                </thead>
                <tbody>
                    <% if (empleados == null || empleados.isEmpty()) { %>
                    <tr><td colspan="6" class="tabla-vacia">No hay empleados registrados.</td></tr>
                    <% } else { for (Empleado empleado : empleados) {
                        String enlace = ctx + "/EmpleadoController?accion=editar&codigo="
                            + URLEncoder.encode(empleado.getCodigo(), StandardCharsets.UTF_8);
                        String fotoFila = empleado.getFoto();
                    %>
                    <tr>
                        <td class="tp-celda-foto">
                            <% if (fotoFila != null && !fotoFila.trim().isEmpty()) { %>
                            <img class="tp-mini-foto" src="<%= ctx %>/resource/<%= Html.escape(fotoFila) %>" alt="Foto de <%= Html.escape(empleado.getNombres()) %>">
                            <% } else { %>
                            <span class="tp-mini-placeholder">S/F</span>
                            <% } %>
                        </td>
                        <td><%= Html.escape(empleado.getCodigo()) %></td>
                        <td><strong><%= Html.escape(empleado.getApellidos()) %></strong>, <%= Html.escape(empleado.getNombres()) %></td>
                        <td><%= Html.escape(empleado.getDescriGenero() == null ? "—" : empleado.getDescriGenero()) %></td>
                        <td><%= Html.escape(empleado.getDescriEstadoCivil() == null ? "—" : empleado.getDescriEstadoCivil()) %></td>
                        <td class="celda-acciones">
                            <a class="btn-editar" href="<%= Html.escape(enlace) %>">Editar</a>
                            <a class="btn-reporte" href="<%= ctx %>/ReporteController?r=ficha&amp;codigo=<%= Html.escape(URLEncoder.encode(empleado.getCodigo(), StandardCharsets.UTF_8)) %>" target="_blank" rel="noopener">Ficha PDF</a>
                            <form action="<%= ctx %>/EmpleadoController" method="post" class="form-eliminar"
                                  onsubmit="return confirm('¿Eliminar este empleado y sus datos académicos y familiares?');">
                                <input type="hidden" name="accion" value="eliminar">
                                <input type="hidden" name="csrf" value="<%= csrf %>">
                                <input type="hidden" name="modo" value="editar">
                                <input type="hidden" name="codigo" value="<%= Html.escape(empleado.getCodigo()) %>">
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
<script src="<%= ctx %>/js/tabpage.js"></script>
</body>
</html>
