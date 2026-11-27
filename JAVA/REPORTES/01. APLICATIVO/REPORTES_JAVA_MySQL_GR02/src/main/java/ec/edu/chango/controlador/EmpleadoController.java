package ec.edu.chango.controlador;

import ec.edu.chango.modelo.Empleado;
import ec.edu.chango.modelo.EmpleadoAcademico;
import ec.edu.chango.modelo.EmpleadoFamiliar;
import ec.edu.chango.modelo.EmpleadoDAO;
import ec.edu.chango.util.ImagenPerfil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Mantenimiento de Empleados con Tab Page (réplica del Tab Page del
 * proyecto .NET GR02). La ficha tiene un marco superior con foto,
 * apellidos y nombres, y tres pestañas: Datos Generales, Datos
 * Académicos (subtabla) y Datos Familiares (subtabla).
 *
 * Misma política de acceso, CSRF y PRG que CargoController.
 */
@WebServlet(name = "EmpleadoController", urlPatterns = {"/EmpleadoController"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024,
        maxFileSize = 1024L * 1024 * 5,
        maxRequestSize = 1024L * 1024 * 12)
public class EmpleadoController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(EmpleadoController.class.getName());
    private static final String VISTA = "/ec/edu/chango/vista/empleado.jsp";
    private static final String TOKEN = "empleadoCsrf";
    private static final String MENSAJE_FLASH = "empleadoExito";

    /** Carpeta dentro de /resource donde se guardan las fotos subidas. */
    private static final String CARPETA_FOTOS = "/resource/fotos_empleados";

    /** Tipos de sangre aceptados en la pestaña Datos Generales. */
    private static final Set<String> TIPOS_SANGRE
            = Set.of("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-");

    /** Parentescos aceptados en la pestaña Datos Familiares. */
    private static final Set<String> PARENTESCOS
            = Set.of("PADRE", "MADRE", "CONYUGE", "HIJO/A", "HERMANO/A", "OTRO");

    private final EmpleadoDAO empleados;

    public EmpleadoController() { this(new EmpleadoDAO()); }

    // Permite probar el controlador sin depender del servidor o la base real.
    EmpleadoController(EmpleadoDAO empleados) {
        this.empleados = empleados;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!autenticado(req, res)) return;
        HttpSession sesion = req.getSession(false);
        if (sesion.getAttribute(TOKEN) == null) {
            sesion.setAttribute(TOKEN, UUID.randomUUID().toString());
        }
        Object mensaje = sesion.getAttribute(MENSAJE_FLASH);
        sesion.removeAttribute(MENSAJE_FLASH);
        req.setAttribute("mensajeExito", mensaje);
        try {
            String accion = valor(req, "accion");
            if ("editar".equals(accion)) {
                Empleado empleado = empleados.buscarPorCodigo(valor(req, "codigo"));
                if (empleado == null) {
                    req.setAttribute("mensajeError", "No se encontró el empleado solicitado.");
                } else {
                    req.setAttribute("empleado", empleado);
                    req.setAttribute("modoEdicion", true);
                }
            } else if (!accion.isEmpty() && !"listar".equals(accion) && !"nuevo".equals(accion)) {
                res.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            mostrar(req, res);
        } catch (SQLException ex) {
            fallo(req, res, ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!autenticado(req, res)) return;
        if (req.getContentType() != null && req.getContentType().startsWith("multipart/form-data")) {
            try {
                req.getParts();
            } catch (IllegalStateException ex) {
                res.sendError(413, "La foto no puede superar 5 MB y el formulario completo no puede superar 12 MB.");
                return;
            }
        }
        Object token = req.getSession(false).getAttribute(TOKEN);
        if (token == null || !token.equals(req.getParameter("csrf"))) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Formulario vencido. Recargue la página.");
            return;
        }
        String accion = valor(req, "accion");
        if (!"guardar".equals(accion) && !"eliminar".equals(accion)) {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        boolean edicion = "editar".equals(valor(req, "modo"));
        String codigo = valor(req, "codigo");
        Empleado empleado = null;
        String fotoAnterior = "";
        String fotoNueva = null;
        boolean guardado = false;
        try {
            if ("eliminar".equals(accion)) {
                Empleado eliminado = empleados.buscarPorCodigo(codigo);
                if (empleados.eliminar(codigo)) {
                    if (eliminado != null) eliminarArchivoFoto(eliminado.getFoto());
                    confirmar(req, res, "Empleado eliminado correctamente.");
                } else {
                    req.setAttribute("mensajeError", "El empleado que intenta eliminar ya no existe.");
                    mostrar(req, res);
                }
                return;
            }
            if (!"nuevo".equals(valor(req, "modo")) && !edicion) {
                res.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            // El formulario de la ficha envía la foto junto con todas las pestañas.
            empleado = construirEmpleado(req, edicion);
            fotoAnterior = empleado.getFoto();
            req.setAttribute("empleado", empleado);
            req.setAttribute("modoEdicion", edicion);
            String error = validar(empleado, edicion);
            if (error == null) {
                try {
                    fotoNueva = guardarArchivoFoto(req, empleado);
                } catch (IOException exFoto) {
                    LOG.log(Level.WARNING, "No se pudo guardar la foto del empleado", exFoto);
                    error = exFoto.getMessage();
                }
            }
            if (error == null) {
                guardado = edicion ? empleados.actualizar(empleado)
                        : empleados.insertarConCodigoAutomatico(empleado);
                if (!guardado) {
                    error = "No se pudo guardar: el empleado ya no existe o no se modificó.";
                }
            }
            if (error != null) {
                empleado.setFoto(fotoAnterior);
                req.setAttribute("mensajeError", error);
                req.setAttribute("empleado", empleado);
                req.setAttribute("modoEdicion", edicion);
                mostrar(req, res);
                return;
            }
            if (fotoNueva != null) eliminarArchivoFoto(fotoAnterior);
            confirmar(req, res, "Ficha del empleado guardada correctamente.", empleado.getCodigo());
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Error al modificar un empleado", ex);
            if (empleado != null && !guardado) empleado.setFoto(fotoAnterior);
            req.setAttribute("mensajeError", mensajeBD(ex));
            try {
                mostrar(req, res);
            } catch (SQLException consulta) {
                fallo(req, res, consulta);
            }
        } finally {
            // El archivo anterior solo se retira después de confirmar el cambio en BD.
            if (!guardado && fotoNueva != null) eliminarArchivoFoto(fotoNueva);
        }
    }

    private void mostrar(HttpServletRequest req, HttpServletResponse res)
            throws SQLException, ServletException, IOException {
        req.setAttribute("empleados", empleados.listar());
        req.setAttribute("generos", empleados.listarGeneros());
        req.setAttribute("estadosCiviles", empleados.listarEstadosCiviles());
        if (!Boolean.TRUE.equals(req.getAttribute("modoEdicion"))) {
            Empleado formulario = (Empleado) req.getAttribute("empleado");
            if (formulario == null) formulario = new Empleado();
            formulario.setCodigo(empleados.siguienteCodigoDisponible());
            req.setAttribute("empleado", formulario);
        }
        req.getRequestDispatcher(VISTA).forward(req, res);
    }

    /** Arma el empleado con los campos del marco, las pestañas y las subtablas. */
    private Empleado construirEmpleado(HttpServletRequest req, boolean edicion) throws SQLException {
        Empleado empleado = new Empleado();
        empleado.setCodigo(edicion ? valor(req, "codigo") : empleados.siguienteCodigoDisponible());
        empleado.setApellidos(valor(req, "apellidos"));
        empleado.setNombres(valor(req, "nombres"));
        empleado.setFechaNacimiento(leerFecha(valor(req, "fechaNacimiento")));
        empleado.setCodigoGenero(valor(req, "genero"));
        empleado.setCodigoEstadoCivil(valor(req, "estadoCivil"));
        empleado.setPeso(leerPeso(valor(req, "peso")));
        empleado.setTipoSangre(valor(req, "tipoSangre").toUpperCase());
        // La foto vigente se obtiene de la BD; un formulario antiguo no debe restaurar otra ruta.
        empleado.setFoto("");
        if (edicion && empleado.getCodigo().matches("[A-Za-z0-9-]{1,10}")) {
            Empleado actual = empleados.buscarPorCodigo(empleado.getCodigo());
            if (actual != null && actual.getFoto() != null) empleado.setFoto(actual.getFoto());
        }
        empleado.setAcademicos(leerAcademicos(req));
        empleado.setFamiliares(leerFamiliares(req));
        return empleado;
    }

    /**
     * Lee la subtabla de Datos Académicos. Las filas completamente vacías
     * se descartan; las incompletas se conservan para que validar() pida
     * completarlas.
     */
    private List<EmpleadoAcademico> leerAcademicos(HttpServletRequest req) {
        String[] niveles = req.getParameterValues("acaNivel");
        String[] instituciones = req.getParameterValues("acaInstitucion");
        String[] titulos = req.getParameterValues("acaTitulo");
        List<EmpleadoAcademico> academicos = new ArrayList<>();
        if (niveles == null) {
            return academicos;
        }
        for (int i = 0; i < niveles.length; i++) {
            String nivel = textoSeguro(niveles, i);
            String institucion = textoSeguro(instituciones, i);
            String titulo = textoSeguro(titulos, i);
            if (nivel.isEmpty() && institucion.isEmpty() && titulo.isEmpty()) {
                continue; // Fila vacía: no se guarda.
            }
            academicos.add(new EmpleadoAcademico(nivel, institucion, titulo));
        }
        return academicos;
    }

    /** Igual que leerAcademicos, pero para la subtabla de Datos Familiares. */
    private List<EmpleadoFamiliar> leerFamiliares(HttpServletRequest req) {
        String[] personas = req.getParameterValues("famPersona");
        String[] nombres = req.getParameterValues("famNombres");
        String[] fechas = req.getParameterValues("famFecha");
        List<EmpleadoFamiliar> familiares = new ArrayList<>();
        if (personas == null) {
            return familiares;
        }
        for (int i = 0; i < personas.length; i++) {
            String persona = textoSeguro(personas, i);
            String nombre = textoSeguro(nombres, i);
            String fecha = textoSeguro(fechas, i);
            if (persona.isEmpty() && nombre.isEmpty() && fecha.isEmpty()) {
                continue; // Fila vacía: no se guarda.
            }
            LocalDate fechaNacimiento = fecha.isEmpty() ? null : leerFecha(fecha);
            familiares.add(new EmpleadoFamiliar(persona, nombre, fechaNacimiento));
        }
        return familiares;
    }

    /** Aplica las reglas de negocio de la ficha. Devuelve null si todo está bien. */
    private String validar(Empleado empleado, boolean edicion) throws SQLException {
        if (!empleado.getCodigo().matches("[A-Za-z0-9-]{1,10}")) {
            return "El código de persona no es válido. Vuelva a cargar la ficha.";
        }
        if (empleado.getApellidos().isEmpty() || empleado.getApellidos().length() > 50) {
            return "Ingrese los apellidos del empleado (entre 1 y 50 caracteres).";
        }
        if (empleado.getNombres().isEmpty() || empleado.getNombres().length() > 50) {
            return "Ingrese los nombres del empleado (entre 1 y 50 caracteres).";
        }
        if (empleado.getFechaNacimiento() == null
                || empleado.getFechaNacimiento().isAfter(LocalDate.now())) {
            return "Ingrese una fecha de nacimiento válida (no puede ser futura).";
        }
        if (empleado.getCodigoGenero().isEmpty()) {
            return "Seleccione el sexo del empleado.";
        }
        if (!empleado.getTipoSangre().isEmpty() && !TIPOS_SANGRE.contains(empleado.getTipoSangre())) {
            return "El tipo de sangre indicado no es válido.";
        }
        for (EmpleadoAcademico academico : empleado.getAcademicos()) {
            if (academico.getNivel().isEmpty() || academico.getInstitucion().isEmpty()
                    || academico.getTitulo().isEmpty()) {
                return "En Datos Académicos complete nivel, institución y título de cada fila, "
                        + "o deje la fila vacía para descartarla.";
            }
            if (academico.getNivel().length() > 50 || academico.getInstitucion().length() > 100
                    || academico.getTitulo().length() > 100) {
                return "En Datos Académicos se excedió el tamaño permitido de algún campo.";
            }
        }
        for (EmpleadoFamiliar familiar : empleado.getFamiliares()) {
            if (familiar.getPersona().isEmpty() || familiar.getNombres().isEmpty()
                    || familiar.getFechaNacimiento() == null) {
                return "En Datos Familiares complete persona, apellidos y nombres, y fecha de "
                        + "nacimiento de cada fila, o deje la fila vacía para descartarla.";
            }
            if (familiar.getNombres().length() > 100) {
                return "En Datos Familiares los apellidos y nombres no pueden superar 100 caracteres.";
            }
        }
        if (edicion && !empleados.existe(empleado.getCodigo())) {
            return "El empleado que intenta editar ya no existe.";
        }
        return null;
    }

    /**
     * Guarda los bytes originales de un JPEG/JFIF o PNG real, como en .NET.
     * Cada carga usa un nombre nuevo para evitar la caché y mantener la imagen
     * anterior hasta confirmar el cambio en BD. No se vuelve a leer un stream cerrado.
     */
    private String guardarArchivoFoto(HttpServletRequest req, Empleado empleado)
            throws ServletException, IOException {
        Part parte = req.getPart("foto");
        if (parte == null || (parte.getSize() == 0
                && (parte.getSubmittedFileName() == null || parte.getSubmittedFileName().isBlank()))) {
            return null; // Sin foto nueva: se conserva la actual.
        }
        if (parte.getSize() > ImagenPerfil.MAXIMO_BYTES) throw new IOException("La foto no puede superar 5 MB.");
        ImagenPerfil imagen;
        try (InputStream entrada = parte.getInputStream()) {
            imagen = ImagenPerfil.leer(entrada);
        }
        String rutaReal = getServletContext().getRealPath(CARPETA_FOTOS);
        if (rutaReal == null) {
            throw new IOException("No se pudo resolver la carpeta de fotos del servidor.");
        }
        Path destino;
        try {
            Path carpeta = Files.createDirectories(Path.of(rutaReal));
            destino = Files.createTempFile(carpeta, "foto-", imagen.getExtension());
        } catch (IOException ex) {
            throw new IOException("No se pudo crear la foto. Revise los permisos de la carpeta de fotos del servidor.", ex);
        }
        boolean completo = false;
        try {
            Files.write(destino, imagen.getContenido());
            if (Files.size(destino) != imagen.getContenido().length) throw new IOException("La foto no se escribió completa.");
            String ruta = "fotos_empleados/" + destino.getFileName();
            empleado.setFoto(ruta);
            completo = true;
            return ruta;
        } finally {
            if (!completo) Files.deleteIfExists(destino);
        }
    }

    /** Borra la foto del empleado eliminado. Falla en silencio: es limpieza secundaria. */
    private void eliminarArchivoFoto(String foto) {
        if (foto == null || !foto.matches("fotos_empleados/[A-Za-z0-9-]+\\.(?:jpg|png)")) {
            return;
        }
        try {
            String rutaReal = getServletContext().getRealPath(CARPETA_FOTOS);
            if (rutaReal != null) {
                Path destino = Path.of(rutaReal).resolve(Path.of(foto).getFileName());
                Files.deleteIfExists(destino);
            }
        } catch (IOException | SecurityException ex) {
            LOG.log(Level.WARNING, "No se pudo borrar la foto del empleado " + foto, ex);
        }
    }

    private void confirmar(HttpServletRequest req, HttpServletResponse res, String mensaje)
            throws IOException {
        confirmar(req, res, mensaje, null);
    }

    private void confirmar(HttpServletRequest req, HttpServletResponse res, String mensaje, String codigo)
            throws IOException {
        req.getSession(false).setAttribute(MENSAJE_FLASH, mensaje);
        String destino = req.getContextPath() + "/EmpleadoController";
        if (codigo != null) destino += "?accion=editar&codigo=" + URLEncoder.encode(codigo, StandardCharsets.UTF_8);
        res.sendRedirect(destino);
    }

    // Forward directo: una caída de MySQL no produce un bucle de redirecciones.
    private void fallo(HttpServletRequest req, HttpServletResponse res, SQLException ex)
            throws ServletException, IOException {
        LOG.log(Level.SEVERE, "Error al consultar empleados", ex);
        req.setAttribute("datosNoDisponibles", true);
        req.setAttribute("mensajeError", "No se pudieron cargar los datos. Revise MySQL, db.properties y la tabla peper_perso.");
        res.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        req.getRequestDispatcher(VISTA).forward(req, res);
    }

    static String mensajeBD(SQLException ex) {
        for (SQLException causa = ex; causa != null; causa = causa.getNextException()) {
            if (causa.getErrorCode() == 1062) return "Ya existe una persona con ese código o cédula.";
            if (causa.getErrorCode() == 1451) return "No se puede eliminar el empleado porque está vinculado a otros registros.";
            if (causa.getErrorCode() == 1452) return "El sexo o el estado civil seleccionado ya no existe en el catálogo.";
        }
        return "No se pudo completar la operación. Revise la conexión y la tabla peper_perso.";
    }

    private boolean autenticado(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession sesion = req.getSession(false);
        if (sesion == null || sesion.getAttribute("usuario") == null) {
            res.sendRedirect(req.getContextPath() + "/ec/edu/chango/vista/index.jsp");
            return false;
        }
        res.setHeader("Cache-Control", "no-store");
        return true;
    }

    private static LocalDate leerFecha(String valor) {
        if (valor == null || valor.isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(valor);
        } catch (DateTimeParseException ex) {
            return null;
        }
    }

    /** Devuelve el peso como double; Double.NaN si el texto no es un peso válido. */
    private static double leerPeso(String valor) {
        if (valor == null || valor.isEmpty()) {
            return 0;
        }
        try {
            return Double.parseDouble(valor.replace(',', '.'));
        } catch (NumberFormatException ex) {
            return Double.NaN;
        }
    }

    private static String textoSeguro(String[] valores, int indice) {
        return indice < valores.length && valores[indice] != null ? valores[indice].trim() : "";
    }

    private static String valor(HttpServletRequest req, String nombre) {
        String valor = req.getParameter(nombre);
        return valor == null ? "" : valor.trim();
    }
}
