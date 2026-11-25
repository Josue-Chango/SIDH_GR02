package ec.edu.chango.controlador;

import ec.edu.chango.modelo.Usuario;
import ec.edu.chango.util.ConexionBD;
import ec.edu.chango.util.ReportesJasper;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRParameter;

/** Reportes PDF de los tres módulos y ficha completa del empleado, como en GR01. */
@WebServlet(name = "ReporteController", urlPatterns = {"/ReporteController", "/reporte"})
public class ReporteController extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(ReporteController.class.getName());
    private final ReportesJasper reportes = new ReportesJasper();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession sesion = request.getSession(false);
        if (sesion == null || !(sesion.getAttribute("usuario") instanceof Usuario)) {
            response.sendRedirect(request.getContextPath() + "/ec/edu/chango/vista/index.jsp");
            return;
        }
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("X-Content-Type-Options", "nosniff");

        String tipo = valor(request, "r");
        String nombre;
        String archivo;
        Map<String, Object> parametros = new HashMap<>();
        parametros.put(JRParameter.REPORT_LOCALE, new Locale("es", "EC"));
        parametros.put(JRParameter.REPORT_TIME_ZONE, TimeZone.getTimeZone("America/Guayaquil"));
        parametros.put("USUARIO", ((Usuario) sesion.getAttribute("usuario")).getNombreCompleto());

        switch (tipo) {
            case "departamentos":
                nombre = "departamentos";
                archivo = "departamentos.pdf";
                break;
            case "cargos":
                nombre = "cargos";
                archivo = "cargos.pdf";
                String departamento = valor(request, "departamento");
                if (!departamento.isEmpty() && departamento.length() != 3) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "El departamento debe tener 3 caracteres.");
                    return;
                }
                parametros.put("DEPARTAMENTO", departamento);
                break;
            case "empleados":
                nombre = "empleados";
                archivo = "empleados.pdf";
                break;
            case "ficha":
                String codigo = valor(request, "codigo");
                if (!codigo.matches("[A-Za-z0-9-]{1,10}")) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Indique un código de empleado válido (hasta 10 letras, números o guiones).");
                    return;
                }
                nombre = "empleado_ficha";
                archivo = "ficha-empleado-" + codigo + ".pdf";
                parametros.put("EMPLEADO", codigo);
                break;
            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Reporte desconocido.");
                return;
        }

        try (Connection conexion = ConexionBD.obtener()) {
            if ("ficha".equals(tipo)) {
                // Comprueba existencia y obtiene la foto en la misma base usada por el reporte.
                try (PreparedStatement consulta = conexion.prepareStatement(
                        "SELECT PEPER_FOTO FROM peper_perso WHERE PEPER_CODIGO = ?")) {
                    consulta.setString(1, (String) parametros.get("EMPLEADO"));
                    try (ResultSet fila = consulta.executeQuery()) {
                        if (!fila.next()) {
                            response.sendError(HttpServletResponse.SC_NOT_FOUND, "El empleado no existe.");
                            return;
                        }
                        parametros.put("FOTO", foto(fila.getString("PEPER_FOTO")));
                    }
                }
            }
            // Genera todo antes de enviar cabeceras para no devolver un PDF incompleto ante un error.
            byte[] pdf = reportes.generar(nombre, parametros, conexion,
                    getServletContext()::getResourceAsStream);
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "inline; filename=\"" + archivo + "\"");
            response.setContentLength(pdf.length);
            response.getOutputStream().write(pdf);
        } catch (SQLException | JRException ex) {
            LOG.log(Level.SEVERE, "No se pudo generar el reporte " + nombre, ex);
            response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "No se pudo generar el reporte. Revise MySQL y la configuración del aplicativo.");
        } catch (IOException ex) {
            if (response.isCommitted()) {
                throw ex;
            }
            LOG.log(Level.SEVERE, "No se pudo leer la plantilla del reporte " + nombre, ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "No se pudo cargar la plantilla del reporte.");
        }
    }

    private BufferedImage foto(String ruta) {
        // Solo recursos locales del aplicativo: admite las fotos existentes y las subidas por Empleados.
        if (ruta == null || !ruta.matches("(?:fotos_empleados/)?[A-Za-z0-9][A-Za-z0-9_.-]{0,99}")) {
            return null;
        }
        try (InputStream entrada = getServletContext().getResourceAsStream("/resource/" + ruta)) {
            return entrada == null ? null : ImageIO.read(entrada);
        } catch (IOException ex) {
            LOG.log(Level.WARNING, "No se pudo leer la foto para la ficha del empleado", ex);
            return null;
        }
    }

    private static String valor(HttpServletRequest request, String nombre) {
        String valor = request.getParameter(nombre);
        return valor == null ? "" : valor.trim();
    }
}
