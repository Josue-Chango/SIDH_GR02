package ec.edu.chango.controlador;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filtro que protege las páginas privadas: si no existe un usuario en sesión,
 * redirige al inicio de sesión.
 *
 * @author josue
 */
@WebFilter(filterName = "FiltroAutenticacion", urlPatterns = {"/bienvenida.jsp", "/departamento.jsp"})
public class FiltroAutenticacion implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest peticion = (HttpServletRequest) request;
        HttpServletResponse respuesta = (HttpServletResponse) response;
        HttpSession sesion = peticion.getSession(false);

        if (sesion == null || sesion.getAttribute("usuario") == null) {
            respuesta.sendRedirect(peticion.getContextPath() + "/index.jsp");
            return;
        }

        respuesta.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        respuesta.setHeader("Pragma", "no-cache");
        respuesta.setDateHeader("Expires", 0);

        chain.doFilter(request, response);
    }
}
