package ec.edu.chango.controlador;

import ec.edu.chango.modelo.Usuario;
import ec.edu.chango.modelo.UsuarioDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controlador del inicio de sesión.
 *
 * Recibe el identificador del usuario (PEPER_CODIGO) y la contraseña,
 * autentica contra la tabla XEUSU_USUAR y crea la sesión del usuario.
 *
 * @author josue
 */
@WebServlet(name = "LoginController", urlPatterns = {"/LoginController"})
public class LoginController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(LoginController.class.getName());
    private static final int TIEMPO_SESION_SEGUNDOS = 30 * 60;

    /** Ruta de las vistas JSP dentro del paquete ec.edu.chango.vista. */
    private static final String VISTA = "/ec/edu/chango/vista";

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + VISTA + "/index.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String usuario = request.getParameter("txtUsuario");
        String password = request.getParameter("txtPassword");

        try {
            Usuario usuarioAutenticado = usuarioDAO.autenticar(usuario, password);

            if (usuarioAutenticado == null) {
                mostrarError(request, response,
                        "El usuario o la contraseña no son correctos.");
                return;
            }

            if (!usuarioAutenticado.isActivo()) {
                mostrarError(request, response,
                        "El usuario se encuentra inactivo o bloqueado. Contacte al administrador.");
                return;
            }

            // La contraseña no se guarda en la sesión.
            usuarioAutenticado.setPassword(null);

            HttpSession sesionAnterior = request.getSession(false);
            if (sesionAnterior != null) {
                sesionAnterior.invalidate();
            }

            HttpSession sesion = request.getSession(true);
            sesion.setAttribute("usuario", usuarioAutenticado);
            sesion.setMaxInactiveInterval(TIEMPO_SESION_SEGUNDOS);

            response.sendRedirect(request.getContextPath() + VISTA + "/bienvenida.jsp");
        } catch (SQLException ex) {
            LOG.log(Level.SEVERE, "No se pudo autenticar al usuario", ex);
            mostrarError(request, response,
                    "No se pudo conectar con la base de datos. "
                    + "Verifique que MySQL esté activo y la configuración de db.properties.");
        }
    }

    private void mostrarError(HttpServletRequest request, HttpServletResponse response, String mensaje)
            throws ServletException, IOException {
        request.setAttribute("error", mensaje);
        request.getRequestDispatcher(VISTA + "/index.jsp").forward(request, response);
    }
}
