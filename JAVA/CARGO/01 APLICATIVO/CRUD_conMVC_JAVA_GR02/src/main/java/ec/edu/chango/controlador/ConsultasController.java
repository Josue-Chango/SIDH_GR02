package ec.edu.chango.controlador;

import ec.edu.chango.modelo.Cargo;
import ec.edu.chango.modelo.CargoDAO;
import ec.edu.chango.modelo.DepartamentoDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controlador del apartado de consulta de CARGOS y DEPARTAMENTOS (módulo de
 * Personal).
 *
 * La vista consultas.jsp muestra:
 * <ul>
 *   <li>un listbox con los departamentos de la tabla PEDEP_DEPAR,</li>
 *   <li>un combobox con los cargos de la tabla PECAR_CARGO.</li>
 * </ul>
 *
 * Acciones:
 * <ul>
 *   <li>GET (por defecto): muestra la vista con todos los cargos.</li>
 *   <li>POST con accion=consultar: toma los departamentos seleccionados en el
 *       listbox y recarga la vista mostrando en el combobox únicamente los
 *       cargos de esos departamentos.</li>
 * </ul>
 *
 * La página es privada: sin sesión autenticada se vuelve al login.
 *
 * @author josue
 */
@WebServlet(name = "ConsultasController", urlPatterns = {"/ConsultasController"})
public class ConsultasController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(ConsultasController.class.getName());

    private static final String VISTA = "/ec/edu/chango/vista/consultas.jsp";
    private static final String ATTR_CARGOS = "cargos";
    private static final String ATTR_DEPARTAMENTOS = "departamentos";
    private static final String ATTR_DEPARTAMENTOS_SEL = "departamentosSeleccionados";
    private static final String ATTR_MENSAJE_ERROR = "mensajeError";
    private static final String ATTR_MENSAJE_INFO = "mensajeInfo";
    private static final String FLASH_ERROR = "consultasMensajeError";

    private final CargoDAO cargoDAO = new CargoDAO();
    private final DepartamentoDAO departamentoDAO = new DepartamentoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        if (!sesionValida(request)) {
            response.sendRedirect(request.getContextPath() + "/ec/edu/chango/vista/index.jsp");
            return;
        }

        // Mensaje flash de error (por ejemplo, si falló la conexión en el
        // intento anterior) para que la vista lo muestre una sola vez.
        HttpSession sesion = request.getSession(false);
        if (sesion != null) {
            Object error = sesion.getAttribute(FLASH_ERROR);
            if (error != null) {
                request.setAttribute(ATTR_MENSAJE_ERROR, error);
                sesion.removeAttribute(FLASH_ERROR);
            }
        }

        try {
            cargarVista(request, response, null, null, null);
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "No se pudo consultar los cargos y departamentos", ex);
            ponerMensajeError(request,
                    "No se pudo conectar con la base de datos. Verifique que MySQL "
                    + "esté activo y la configuración de db.properties.");
            response.sendRedirect(request.getContextPath() + "/ConsultasController");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        if (!sesionValida(request)) {
            response.sendRedirect(request.getContextPath() + "/ec/edu/chango/vista/index.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        try {
            if ("consultar".equals(accion)) {
                consultar(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/ConsultasController");
            }
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "No se pudo ejecutar la consulta de cargos", ex);
            ponerMensajeError(request, "Error de base de datos: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/ConsultasController");
        }
    }

    /**
     * Acción consultar: toma los departamentos seleccionados en el listbox y
     * recarga la vista mostrando en el combobox solo los cargos de esos
     * departamentos.
     */
    private void consultar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        // El listbox envía el parámetro lstDepartamento una vez por cada
        // opción marcada (Ctrl/Shift para selección múltiple).
        String[] valores = request.getParameterValues("lstDepartamento");
        Set<String> seleccionados = new LinkedHashSet<>();
        if (valores != null) {
            for (String valor : valores) {
                if (valor != null && !valor.trim().isEmpty()) {
                    seleccionados.add(valor.trim());
                }
            }
        }

        List<String> codigos = new ArrayList<>(seleccionados);

        if (codigos.isEmpty()) {
            // Sin selección se muestra la vista completa con un aviso.
            cargarVista(request, response, null, null,
                    "Seleccione al menos un departamento del listbox antes de consultar.");
            return;
        }

        // Carga los cargos solo de los departamentos elegidos.
        List<Cargo> cargos;
        if (codigos.size() == 1) {
            cargos = cargoDAO.listarPorDepartamento(codigos.get(0));
        } else {
            cargos = new ArrayList<>();
            for (String codigo : codigos) {
                cargos.addAll(cargoDAO.listarPorDepartamento(codigo));
            }
        }

        String info = codigos.size() == 1
                ? "Cargos del departamento " + codigos.get(0) + ": " + cargos.size()
                : "Cargos de los departamentos " + String.join(", ", codigos) + ": " + cargos.size();

        cargarVista(request, response, cargos, codigos, info);
    }

    /**
     * Carga las listas y reenvía a la vista. Si no se indican cargos se
     * muestran todos; si se indican, la vista marca los departamentos
     * seleccionados en el listbox.
     */
    private void cargarVista(HttpServletRequest request, HttpServletResponse response,
            List<Cargo> cargos, List<String> seleccionados, String mensajeInfo)
            throws ServletException, IOException, SQLException {

        if (cargos == null) {
            request.setAttribute(ATTR_CARGOS, cargoDAO.listar());
        } else {
            request.setAttribute(ATTR_CARGOS, cargos);
        }
        request.setAttribute(ATTR_DEPARTAMENTOS, departamentoDAO.listar());
        if (seleccionados != null && !seleccionados.isEmpty()) {
            request.setAttribute(ATTR_DEPARTAMENTOS_SEL, seleccionados);
        }
        if (mensajeInfo != null) {
            request.setAttribute(ATTR_MENSAJE_INFO, mensajeInfo);
        }
        request.getRequestDispatcher(VISTA).forward(request, response);
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
     * Indica si existe un usuario autenticado en la sesión.
     */
    private boolean sesionValida(HttpServletRequest request) {
        HttpSession sesion = request.getSession(false);
        return sesion != null && sesion.getAttribute("usuario") != null;
    }
}
