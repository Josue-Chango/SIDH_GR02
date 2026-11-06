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
 * Recibe la identificación (cédula, correo o pasaporte) y la contraseña,
 * autentica contra la tabla XEUSU_USUAR y crea la sesión del usuario.
 *
 * @author josue
 */
@WebServlet(name = "LoginController", urlPatterns = {"/LoginController"})
public class LoginController extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(LoginController.class.getName());
    private static final int TIEMPO_SESION_SEGUNDOS = 30 * 60;

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String identificacion = request.getParameter("txtIdentificacion");
        String password = request.getParameter("txtPassword");

        try {
            Usuario usuario = usuarioDAO.autenticar(identificacion, password);

            if (usuario == null) {
                mostrarError(request, response,
                        "La identificación o la contraseña no son correctas.");
                return;
            }

            if (!usuario.isActivo()) {
                mostrarError(request, response,
                        "El usuario se encuentra inactivo o bloqueado. Contacte al administrador.");
                return;
            }

            // La contraseña no se guarda en la sesión.
            usuario.setPassword(null);

            HttpSession sesionAnterior = request.getSession(false);
            if (sesionAnterior != null) {
                sesionAnterior.invalidate();
            }

            HttpSession sesion = request.getSession(true);
            sesion.setAttribute("usuario", usuario);
            sesion.setMaxInactiveInterval(TIEMPO_SESION_SEGUNDOS);

            response.sendRedirect(request.getContextPath() + "/bienvenida.jsp");
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
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}
