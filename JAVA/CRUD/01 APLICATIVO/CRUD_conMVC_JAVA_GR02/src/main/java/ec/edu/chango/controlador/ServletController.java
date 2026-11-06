package ec.edu.chango.controlador;

import ec.edu.chango.modelo.DatosEncuesta;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ServletController", urlPatterns = {"/ServletController"})
public class ServletController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String nombre = request.getParameter("txtNombre");
        String apellido = request.getParameter("txtApellido");
        String[] lenguajes = request.getParameterValues("progLeng");
        String foto = request.getParameter("foto");

        // Si el navegador envía la ruta completa, nos quedamos solo con el nombre del archivo
        if (foto != null && !foto.isEmpty()) {
            foto = foto.substring(foto.lastIndexOf("\\") + 1);
            foto = foto.substring(foto.lastIndexOf("/") + 1);
        }

        DatosEncuesta datos = new DatosEncuesta();
        datos.setNombre(nombre);
        datos.setApellido(apellido);
        datos.setProgLeng(lenguajes);
        datos.setFoto(foto);

        request.setAttribute("DatosEncuesta", datos);
        request.getRequestDispatcher("salida.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("index.jsp");
    }
}