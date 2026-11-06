package ec.edu.chango.controlador;

import ec.edu.chango.modelo.Departamento;
import ec.edu.chango.modelo.DepartamentoDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controlador del CRUD de DEPARTAMENTO (tabla PEDEP_DEPAR del diagrama de Personal).
 *
 * Acciones (parámetro "accion"):
 * <ul>
 *   <li>listar (GET, por defecto): muestra la vista departamento.jsp con todos
 *       los departamentos.</li>
 *   <li>nuevo (GET): muestra el formulario vacío.</li>
 *   <li>editar (GET): muestra el formulario con los datos del departamento
 *       indicado en el parámetro "codigo".</li>
 *   <li>guardar (POST): inserta o actualiza un departamento según venga o no
 *       el campo codigoOriginal.</li>
 *   <li>eliminar (POST): elimina el departamento indicado en "codigo".</li>
 * </ul>
 *
 * Tras las operaciones POST se aplica el patrón POST-Redirect-GET y los
 * mensajes de éxito o error viajan como atributos de sesión (flash) que la
 * vista lee una sola vez.
 *
 * @author josue
 */
@WebServlet(name = "DepartamentoController", urlPatterns = {"/DepartamentoController"})
public class DepartamentoController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(DepartamentoController.class.getName());

    private static final String VISTA = "/departamento.jsp";
    private static final String ATTR_DEPARTAMENTOS = "departamentos";
    private static final String ATTR_DEPARTAMENTO = "departamento";
    private static final String ATTR_CODIGO_ORIGINAL = "codigoOriginal";
    private static final String ATTR_MODO_EDICION = "modoEdicion";
    private static final String ATTR_MENSAJE_EXITO = "mensajeExito";
    private static final String ATTR_MENSAJE_ERROR = "mensajeError";
    private static final String FLASH_EXITO = "departamentoMensajeExito";
    private static final String FLASH_ERROR = "departamentoMensajeError";

    private final DepartamentoDAO departamentoDAO = new DepartamentoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        if (!sesionValida(request)) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        leerMensajes(request);
        String accion = request.getParameter("accion");

        try {
            if ("nuevo".equals(accion)) {
                request.setAttribute(ATTR_DEPARTAMENTO, new Departamento());
                request.setAttribute(ATTR_MODO_EDICION, Boolean.FALSE);
                request.setAttribute(ATTR_DEPARTAMENTOS, departamentoDAO.listar());
                request.getRequestDispatcher(VISTA).forward(request, response);
            } else if ("editar".equals(accion)) {
                editar(request, response);
            } else {
                request.setAttribute(ATTR_DEPARTAMENTOS, departamentoDAO.listar());
                request.getRequestDispatcher(VISTA).forward(request, response);
            }
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "No se pudo consultar los departamentos", ex);
            ponerMensajeError(request, "No se pudo conectar con la base de datos. "
                    + "Verifique que MySQL esté activo y la configuración de db.properties.");
            response.sendRedirect(request.getContextPath() + "/DepartamentoController");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        if (!sesionValida(request)) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        try {
            if ("guardar".equals(accion)) {
                guardar(request, response);
            } else if ("eliminar".equals(accion)) {
                eliminar(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/DepartamentoController");
            }
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "No se pudo ejecutar la operacion sobre el departamento", ex);
            ponerMensajeError(request, mensajeBaseDatos(ex));
            response.sendRedirect(request.getContextPath() + "/DepartamentoController");
        }
    }

    /**
     * Acción editar: carga el departamento indicado y muestra el formulario
     * precargado en la vista.
     */
    private void editar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String codigo = normalizar(request.getParameter("codigo"));
        Departamento departamento = codigo.isEmpty() ? null : departamentoDAO.buscarPorCodigo(codigo);

        if (departamento == null) {
            ponerMensajeError(request, "No se encontró el departamento solicitado.");
            response.sendRedirect(request.getContextPath() + "/DepartamentoController");
            return;
        }

        request.setAttribute(ATTR_DEPARTAMENTO, departamento);
        request.setAttribute(ATTR_CODIGO_ORIGINAL, departamento.getCodigoDepart());
        request.setAttribute(ATTR_MODO_EDICION, Boolean.TRUE);
        request.setAttribute(ATTR_DEPARTAMENTOS, departamentoDAO.listar());
        request.getRequestDispatcher(VISTA).forward(request, response);
    }

    /**
     * Acción guardar: valida los datos del formulario e inserta o actualiza
     * el departamento según el modo.
     */
    private void guardar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String codigo = normalizar(request.getParameter("txtCodigo"));
        String descripcion = normalizar(request.getParameter("txtDescripcion"));
        String codigoOriginal = normalizar(request.getParameter("codigoOriginal"));

        Departamento formulario = new Departamento(codigo, descripcion);

        // Validaciones de servidor acordes al DDL: PEDEP_CODIGO CHAR(3) y
        // PEDEP_DESCRI VARCHAR(50), ambos obligatorios.
        if (codigo.isEmpty()) {
            devolverFormulario(request, response, formulario, codigoOriginal,
                    "Ingrese el código del departamento.");
            return;
        }
        if (codigo.length() != 3) {
            devolverFormulario(request, response, formulario, codigoOriginal,
                    "El código debe tener exactamente 3 caracteres (la columna PEDEP_CODIGO es CHAR(3)).");
            return;
        }
        if (descripcion.isEmpty()) {
            devolverFormulario(request, response, formulario, codigoOriginal,
                    "Ingrese la descripción del departamento.");
            return;
        }
        if (descripcion.length() > 50) {
            devolverFormulario(request, response, formulario, codigoOriginal,
                    "La descripción no puede superar los 50 caracteres.");
            return;
        }

        boolean esEdicion = !codigoOriginal.isEmpty();

        if (!esEdicion) {
            if (departamentoDAO.existe(codigo)) {
                devolverFormulario(request, response, formulario, codigoOriginal,
                        "Ya existe un departamento con el código " + codigo + ".");
                return;
            }
            departamentoDAO.insertar(formulario);
            ponerMensajeExito(request, "Departamento " + codigo + " creado correctamente.");
        } else {
            if (!codigo.equals(codigoOriginal) && departamentoDAO.existe(codigo)) {
                devolverFormulario(request, response, formulario, codigoOriginal,
                        "Ya existe un departamento con el código " + codigo + ".");
                return;
            }
            boolean actualizado = departamentoDAO.actualizar(codigoOriginal, formulario);
            if (!actualizado) {
                devolverFormulario(request, response, formulario, codigoOriginal,
                        "No se encontró el departamento con código " + codigoOriginal + ".");
                return;
            }
            ponerMensajeExito(request, "Departamento " + codigo + " actualizado correctamente.");
        }

        // POST-Redirect-GET para evitar reenvíos del formulario al refrescar.
        response.sendRedirect(request.getContextPath() + "/DepartamentoController");
    }

    /**
     * Acción eliminar: borra el departamento indicado por su código.
     */
    private void eliminar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String codigo = normalizar(request.getParameter("codigo"));

        if (codigo.isEmpty()) {
            ponerMensajeError(request, "Indique el código del departamento a eliminar.");
            response.sendRedirect(request.getContextPath() + "/DepartamentoController");
            return;
        }

        if (departamentoDAO.eliminar(codigo)) {
            ponerMensajeExito(request, "Departamento " + codigo + " eliminado correctamente.");
        } else {
            ponerMensajeError(request, "No se encontró el departamento con código " + codigo + ".");
        }
        response.sendRedirect(request.getContextPath() + "/DepartamentoController");
    }

    /**
     * Reenvía el formulario a la vista conservando lo digitado por el usuario,
     * el modo de edición y un mensaje de error de validación.
     */
    private void devolverFormulario(HttpServletRequest request, HttpServletResponse response,
            Departamento departamento, String codigoOriginal, String error)
            throws ServletException, IOException, SQLException {
        boolean esEdicion = codigoOriginal != null && !codigoOriginal.isEmpty();
        request.setAttribute(ATTR_DEPARTAMENTO, departamento);
        request.setAttribute(ATTR_CODIGO_ORIGINAL, esEdicion ? codigoOriginal : null);
        request.setAttribute(ATTR_MODO_EDICION, esEdicion);
        request.setAttribute(ATTR_MENSAJE_ERROR, error);
        request.setAttribute(ATTR_DEPARTAMENTOS, departamentoDAO.listar());
        request.getRequestDispatcher(VISTA).forward(request, response);
    }

    /**
     * Indica si existe un usuario autenticado en la sesión.
     */
    private boolean sesionValida(HttpServletRequest request) {
        HttpSession sesion = request.getSession(false);
        return sesion != null && sesion.getAttribute("usuario") != null;
    }

    private String normalizar(String valor) {
        return valor != null ? valor.trim() : "";
    }

    /**
     * Guarda el mensaje de éxito en sesión para que la vista lo muestre una
     * sola vez después del redirect.
     */
    private void ponerMensajeExito(HttpServletRequest request, String mensaje) {
        HttpSession sesion = request.getSession(true);
        sesion.setAttribute(FLASH_EXITO, mensaje);
    }

    /**
     * Guarda el mensaje de error en sesión para que la vista lo muestre una
     * sola vez después del redirect.
     */
    private void ponerMensajeError(HttpServletRequest request, String mensaje) {
        HttpSession sesion = request.getSession(true);
        sesion.setAttribute(FLASH_ERROR, mensaje);
    }

    /**
     * Mueve los mensajes flash de la sesión al request y los limpia, para que
     * la vista los muestre una única vez.
     */
    private void leerMensajes(HttpServletRequest request) {
        HttpSession sesion = request.getSession(false);
        if (sesion == null) {
            return;
        }
        Object exito = sesion.getAttribute(FLASH_EXITO);
        Object error = sesion.getAttribute(FLASH_ERROR);
        if (exito != null) {
            request.setAttribute(ATTR_MENSAJE_EXITO, exito);
            sesion.removeAttribute(FLASH_EXITO);
        }
        if (error != null) {
            request.setAttribute(ATTR_MENSAJE_ERROR, error);
            sesion.removeAttribute(FLASH_ERROR);
        }
    }

    /**
     * Traduce los errores de base de datos más comunes del CRUD a mensajes
     * entendibles: duplicados de clave primaria y llaves foráneas que
     * restringen eliminar o cambiar el código de un departamento con cargos.
     */
    private String mensajeBaseDatos(SQLException ex) {
        if (ex.getErrorCode() == 1062) {
            return "Ya existe un departamento con el código ingresado.";
        }
        if (ex instanceof SQLIntegrityConstraintViolationException
                || ex.getErrorCode() == 1451 || ex.getErrorCode() == 1452) {
            return "No se puede eliminar el departamento, o cambiar su código, "
                    + "porque tiene cargos asociados (tabla PECAR_CARGO).";
        }
        return "Error de base de datos: " + ex.getMessage();
    }
}
