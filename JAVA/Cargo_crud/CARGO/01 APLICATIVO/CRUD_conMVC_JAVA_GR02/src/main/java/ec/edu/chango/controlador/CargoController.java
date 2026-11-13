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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/** CRUD de cargos por clave compuesta. Misma política de acceso que Departamentos. */
@WebServlet(name = "CargoController", urlPatterns = {"/CargoController"})
public class CargoController extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(CargoController.class.getName());
    private static final String VISTA = "/ec/edu/chango/vista/cargo.jsp";
    private static final String TOKEN = "cargoCsrf";
    private final CargoDAO cargos;
    private final DepartamentoDAO departamentos;

    public CargoController() { this(new CargoDAO(), new DepartamentoDAO()); }

    // Permite probar el controlador sin depender del servidor o la base real.
    CargoController(CargoDAO cargos, DepartamentoDAO departamentos) {
        this.cargos = cargos;
        this.departamentos = departamentos;
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
        Object mensaje = sesion.getAttribute("cargoExito");
        sesion.removeAttribute("cargoExito");
        req.setAttribute("mensajeExito", mensaje);
        try {
            String accion = valor(req, "accion");
            if ("editar".equals(accion)) {
                Cargo cargo = cargos.buscarPorCodigo(valor(req, "departamento"), valor(req, "codigo"));
                if (cargo == null) {
                    req.setAttribute("mensajeError", "No se encontró el cargo solicitado.");
                } else {
                    req.setAttribute("cargo", cargo);
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
        String departamento = valor(req, "departamento");
        String codigo = valor(req, "codigo");
        boolean edicion = "editar".equals(valor(req, "modo"));
        Cargo cargo = new Cargo(departamento, codigo, valor(req, "descripcion"));
        if ("guardar".equals(accion)) {
            req.setAttribute("cargo", cargo);
            req.setAttribute("modoEdicion", edicion);
        }
        try {
            String error = null;
            if (departamento.length() != 3 || codigo.length() != 3) {
                error = "El departamento y el código del cargo deben tener exactamente 3 caracteres.";
            } else if ("guardar".equals(accion)) {
                if (!"nuevo".equals(valor(req, "modo")) && !edicion) {
                    res.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
                if (cargo.getDescriCargo().isEmpty() || cargo.getDescriCargo().length() > 50) {
                    error = "Ingrese una descripción de entre 1 y 50 caracteres.";
                } else if (!departamentos.existe(departamento)) {
                    error = "El departamento seleccionado ya no existe.";
                } else if (edicion && !cargos.existe(departamento, codigo)) {
                    error = "El cargo que intenta editar ya no existe.";
                } else if (!edicion && cargos.existe(departamento, codigo)) {
                    error = "Ya existe ese código de cargo en el departamento seleccionado.";
                } else {
                    boolean guardado = edicion ? cargos.actualizar(cargo) : cargos.insertar(cargo);
                    if (!guardado) error = "No se pudo guardar: el registro ya no existe o no se modificó.";
                }
            } else if (!cargos.eliminar(departamento, codigo)) {
                error = "El cargo que intenta eliminar ya no existe.";
            }
            if (error != null) {
                req.setAttribute("mensajeError", error);
                mostrar(req, res);
                return;
            }
            req.getSession(false).setAttribute("cargoExito", "eliminar".equals(accion)
                    ? "Cargo eliminado correctamente." : "Cargo guardado correctamente.");
            res.sendRedirect(urlListado(req));
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "Error al modificar un cargo", ex);
            req.setAttribute("mensajeError", mensajeBD(ex));
            try { mostrar(req, res); } catch (SQLException consulta) { fallo(req, res, consulta); }
        }
    }

    private void mostrar(HttpServletRequest req, HttpServletResponse res)
            throws SQLException, ServletException, IOException {
        req.setAttribute("departamentos", departamentos.listar());
        String filtro = valor(req, "filtroDepartamento");
        req.setAttribute("filtroDepartamento", filtro);
        req.setAttribute("cargos", filtro.isEmpty() ? cargos.listar() : cargos.listarPorDepartamento(filtro));
        req.getRequestDispatcher(VISTA).forward(req, res);
    }

    // Forward directo: una caída de MySQL no produce un bucle de redirecciones.
    private void fallo(HttpServletRequest req, HttpServletResponse res, SQLException ex)
            throws ServletException, IOException {
        LOG.log(Level.SEVERE, "Error al consultar cargos", ex);
        req.setAttribute("datosNoDisponibles", true);
        req.setAttribute("mensajeError", "No se pudieron cargar los datos. Revise MySQL, db.properties y las tablas de Personal.");
        res.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        req.getRequestDispatcher(VISTA).forward(req, res);
    }

    static String mensajeBD(SQLException ex) {
        for (SQLException causa = ex; causa != null; causa = causa.getNextException()) {
            if (causa.getErrorCode() == 1062) return "Ya existe ese código de cargo en ese departamento.";
            if (causa.getErrorCode() == 1451) return "No se puede eliminar el cargo porque está vinculado a otros registros.";
            if (causa.getErrorCode() == 1452) return "El departamento seleccionado ya no existe.";
        }
        return "No se pudo completar la operación. Revise la conexión y las tablas de Personal.";
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

    private static String urlListado(HttpServletRequest req) {
        String filtro = valor(req, "filtroDepartamento");
        return req.getContextPath() + "/CargoController" + (filtro.isEmpty() ? ""
                : "?filtroDepartamento=" + URLEncoder.encode(filtro, StandardCharsets.UTF_8));
    }

    private static String valor(HttpServletRequest req, String nombre) {
        String valor = req.getParameter(nombre);
        return valor == null ? "" : valor.trim();
    }
}
