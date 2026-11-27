package ec.edu.chango.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperReport;

/** Compila una sola vez por despliegue y genera los PDF usando la conexión del aplicativo. */
public final class ReportesJasper {
    private final Map<String, JasperReport> compilados = new HashMap<>();

    public byte[] generar(String nombre, Map<String, Object> parametros, Connection conexion,
            Function<String, InputStream> recursos) throws JRException, IOException {
        Map<String, Object> valores = new HashMap<>(parametros);
        if ("empleado_ficha".equals(nombre)) {
            valores.put("ACADEMICOS_REPORTE", cargar("empleado_academicos", recursos));
            valores.put("FAMILIARES_REPORTE", cargar("empleado_familiares", recursos));
        }
        return JasperExportManager.exportReportToPdf(
                JasperFillManager.fillReport(cargar(nombre, recursos), valores, conexion));
    }

    private synchronized JasperReport cargar(String nombre, Function<String, InputStream> recursos)
            throws JRException, IOException {
        JasperReport reporte = compilados.get(nombre);
        if (reporte == null) {
            String ruta = "/WEB-INF/reportes/" + nombre + ".jrxml";
            try (InputStream entrada = recursos.apply(ruta)) {
                if (entrada == null) {
                    throw new IOException("No se encontró la plantilla " + ruta);
                }
                reporte = JasperCompileManager.compileReport(entrada);
            }
            compilados.put(nombre, reporte);
        }
        return reporte;
    }
}
