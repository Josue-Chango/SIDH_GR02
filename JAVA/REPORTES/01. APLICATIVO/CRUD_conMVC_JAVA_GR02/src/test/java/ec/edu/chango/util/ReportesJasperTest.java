package ec.edu.chango.util;

import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.parser.PdfTextExtractor;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/** Ejecuta las consultas reales JRXML y exporta PDF contra H2; no usa la base del usuario. */
class ReportesJasperTest {
    private Connection conexion;
    private final ReportesJasper reportes = new ReportesJasper();

    @BeforeEach
    void preparar() throws Exception {
        conexion = DriverManager.getConnection("jdbc:h2:mem:reportes;MODE=MySQL;DB_CLOSE_DELAY=-1", "sa", "");
        try (Statement s = conexion.createStatement()) {
            s.execute("DROP ALL OBJECTS");
            s.execute("CREATE TABLE PEDEP_DEPAR (PEDEP_CODIGO CHAR(3) PRIMARY KEY, PEDEP_DESCRI VARCHAR(50))");
            s.execute("CREATE TABLE PECAR_CARGO (PEDEP_CODIGO CHAR(3), PECAR_CODIGO CHAR(3), PECAR_DESCRI VARCHAR(50), PRIMARY KEY(PEDEP_CODIGO, PECAR_CODIGO))");
            s.execute("INSERT INTO PEDEP_DEPAR VALUES ('SIS', 'Sistemas'), ('CON', 'Contabilidad')");
            s.execute("INSERT INTO PECAR_CARGO VALUES ('SIS', 'ADM', 'Administrador'), ('SIS', 'DEV', 'Desarrollador'), ('CON', 'ADM', 'Contador')");
            s.execute("CREATE TABLE PEGEN_GENERO (PEGEN_CODIGO CHAR(1), PEGEN_DESCRI VARCHAR(50))");
            s.execute("CREATE TABLE PEESC_ESTCIV (PEESC_CODIGO CHAR(1), PEESC_DESCRI VARCHAR(50))");
            s.execute("INSERT INTO PEGEN_GENERO VALUES ('F', 'FEMENINO')");
            s.execute("INSERT INTO PEESC_ESTCIV VALUES ('S', 'SOLTERO')");
            s.execute("CREATE TABLE peper_perso (PEPER_CODIGO CHAR(10) PRIMARY KEY, PEPER_APELLI VARCHAR(50), PEPER_NOMBRE VARCHAR(50), PEPER_FECNAC DATE, PEGEN_CODIGO CHAR(1), PEESC_CODIGO CHAR(1), PEPER_PESO DECIMAL(5,2), PEPER_TIPSANG VARCHAR(3), PEPER_FOTO VARCHAR(100))");
            s.execute("INSERT INTO peper_perso VALUES ('1712345678', 'MUÑOZ PÉREZ', 'MARÍA JOSÉ', '2000-03-14', 'F', 'S', 68.50, 'O+', NULL), ('0913456789', 'CAIZA', 'ANDREA', '1999-08-02', NULL, NULL, NULL, NULL, NULL)");
            s.execute("CREATE TABLE PEACA_ACADE (PEACA_CODIGO INT AUTO_INCREMENT PRIMARY KEY, PEPER_CODIGO CHAR(10), PEACA_NIVEL VARCHAR(50), PEACA_INSTI VARCHAR(100), PEACA_TITUL VARCHAR(100))");
            s.execute("CREATE TABLE PEFAM_FAMIL (PEFAM_CODIGO INT AUTO_INCREMENT PRIMARY KEY, PEPER_CODIGO CHAR(10), PEFAM_PAREN VARCHAR(20), PEFAM_NOMBRE VARCHAR(100), PEFAM_FECNAC DATE)");
            s.execute("INSERT INTO PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL) VALUES ('1712345678', 'Bachiller', 'Colegio Central', 'Ciencias'), ('1712345678', 'Maestría', 'Universidad de Quito', 'Magíster en Gestión')");
            s.execute("INSERT INTO PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC) VALUES ('1712345678', 'MADRE', 'PÉREZ LÓPEZ ANA', '1975-10-19')");
        }
    }

    @AfterEach void cerrar() throws Exception { conexion.close(); }

    private byte[] generar(String nombre, String departamento, String empleado) throws Exception {
        Map<String, Object> parametros = new HashMap<>();
        parametros.put("USUARIO", "Administrador GR02");
        parametros.put("DEPARTAMENTO", departamento);
        parametros.put("EMPLEADO", empleado);
        parametros.put("REPORT_LOCALE", new java.util.Locale("es", "EC"));
        byte[] pdf = reportes.generar(nombre, parametros, conexion, ReportesJasperTest::recurso);
        assertTrue(new String(pdf, 0, 5, java.nio.charset.StandardCharsets.US_ASCII).startsWith("%PDF-"));
        Path salida = Path.of("target/reportes-prueba", nombre + (departamento.isEmpty() ? "" : "-filtrado") + ".pdf");
        Files.createDirectories(salida.getParent());
        Files.write(salida, pdf);
        return pdf;
    }

    private static InputStream recurso(String ruta) {
        try {
            return Files.newInputStream(Path.of("src/main/webapp" + ruta));
        } catch (IOException ex) {
            return null;
        }
    }

    private static String texto(byte[] pdf) throws Exception {
        try (PdfReader reader = new PdfReader(pdf)) {
            PdfTextExtractor extractor = new PdfTextExtractor(reader);
            StringBuilder resultado = new StringBuilder();
            for (int p = 1; p <= reader.getNumberOfPages(); p++) resultado.append(extractor.getTextFromPage(p)).append('\n');
            return resultado.toString();
        }
    }

    @Test void departamentosConTotalesYTildes() throws Exception {
        String resultado = texto(generar("departamentos", "", ""));
        assertTrue(resultado.contains("Sistemas"));
        assertTrue(resultado.contains("Contabilidad"));
        assertTrue(resultado.contains("Total de departamentos: 2"));
        assertTrue(resultado.contains("Página 1 de"));
        assertTrue(resultado.contains("Administrador GR02"));
    }

    @Test void cargosCompletosConClaveCompuestaYSubtotales() throws Exception {
        String resultado = texto(generar("cargos", "", ""));
        assertTrue(resultado.contains("SIS / ADM"));
        assertTrue(resultado.contains("CON / ADM"));
        assertTrue(resultado.contains("Cargos en el departamento: 2"));
        assertTrue(resultado.contains("Cargos en el departamento: 1"));
        assertTrue(resultado.contains("Total de cargos: 3"));
    }

    @Test void cargosRespetanFiltroDelModulo() throws Exception {
        String resultado = texto(generar("cargos", "SIS", ""));
        assertTrue(resultado.contains("SIS / ADM"));
        assertFalse(resultado.contains("CON / ADM"));
        assertFalse(resultado.contains("Contador"));
        assertTrue(resultado.contains("Total de cargos: 2"));
    }

    @Test void sinResultadosYParametrosSqlSeguros() throws Exception {
        String resultado = texto(generar("cargos", "' OR 1=1 --", ""));
        assertTrue(resultado.contains("No hay datos para mostrar."));
        assertTrue(resultado.contains("Total de cargos: 0"));
        assertFalse(resultado.contains("SIS / ADM"));
    }

    @Test void empleadosConCatalogosOpcionalesYUnicode() throws Exception {
        String resultado = texto(generar("empleados", "", ""));
        assertTrue(resultado.contains("MUÑOZ PÉREZ, MARÍA JOSÉ"));
        assertTrue(resultado.contains("14/03/2000"));
        assertTrue(resultado.contains("CAIZA, ANDREA"));
        assertTrue(resultado.contains("Total de empleados: 2"));
        assertTrue(resultado.indexOf("CAIZA") < resultado.indexOf("MUÑOZ"));
    }

    @Test void fichaIncluyeDatosGeneralesAcademicosYFamiliares() throws Exception {
        byte[] pdf = generar("empleado_ficha", "", "1712345678");
        Files.write(Path.of("target/reportes-prueba/ficha-completa.pdf"), pdf);
        String resultado = texto(pdf);
        for (String esperado : new String[]{"MUÑOZ PÉREZ", "MARÍA JOSÉ", "14/03/2000", "O+", "68,50", "Bachiller", "Maestría", "Magíster en Gestión", "MADRE", "PÉREZ LÓPEZ ANA", "19/10/1975", "Sin fotografía", "Firma del empleado"}) {
            assertTrue(resultado.contains(esperado), esperado);
        }
        assertFalse(resultado.contains("CAIZA"));
    }

    @Test void fichaSinDetallesMuestraMensajes() throws Exception {
        byte[] pdf = generar("empleado_ficha", "", "0913456789");
        Files.write(Path.of("target/reportes-prueba/ficha-sin-detalles.pdf"), pdf);
        String resultado = texto(pdf);
        assertTrue(resultado.contains("Sin datos académicos registrados."));
        assertTrue(resultado.contains("Sin datos familiares registrados."));
        assertFalse(resultado.contains("null"));
        assertFalse(resultado.contains("MUÑOZ"));
    }

    @Test void fichaLargaPaginaSinPerderDetalles() throws Exception {
        try (Statement s = conexion.createStatement()) {
            for (int i = 1; i <= 60; i++) {
                s.execute("INSERT INTO PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL) VALUES ('1712345678', 'Nivel " + i + "', 'Universidad de Ciencias Administrativas y Tecnológicas de la Provincia de Pichincha', 'Título de especialización en Administración de Sistemas de Información y Redes de Comunicación')");
                s.execute("INSERT INTO PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC) VALUES ('1712345678', 'OTRO', 'Familiar " + i + "', '2000-01-01')");
            }
        }
        byte[] pdf = generar("empleado_ficha", "", "1712345678");
        try (PdfReader reader = new PdfReader(pdf)) { assertTrue(reader.getNumberOfPages() > 3); }
        String resultado = texto(pdf);
        assertTrue(resultado.contains("Nivel 60"));
        assertTrue(resultado.contains("Familiar 60"));
        assertTrue(resultado.contains("Firma del responsable"));
        Files.write(Path.of("target/reportes-prueba/ficha-larga.pdf"), pdf);
    }

    @Test void fichaConFotografiaIncrustada() throws Exception {
        Map<String, Object> parametros = new HashMap<>();
        parametros.put("USUARIO", "Administrador GR02");
        parametros.put("EMPLEADO", "1712345678");
        parametros.put("FOTO", javax.imageio.ImageIO.read(Path.of("src/main/webapp/resource/josue1.jpeg").toFile()));
        byte[] pdf = reportes.generar("empleado_ficha", parametros, conexion, ReportesJasperTest::recurso);
        assertFalse(texto(pdf).contains("Sin fotografía"));
        try (PdfReader reader = new PdfReader(pdf)) {
            com.lowagie.text.pdf.PdfDictionary recursos = reader.getPageN(1).getAsDict(com.lowagie.text.pdf.PdfName.RESOURCES);
            assertNotNull(recursos.getAsDict(com.lowagie.text.pdf.PdfName.XOBJECT));
        }
        Files.createDirectories(Path.of("target/reportes-prueba"));
        Files.write(Path.of("target/reportes-prueba/ficha-con-foto.pdf"), pdf);
    }

    @Test void fichaAdmiteSubreportesCompiladosParaPreviewDeStudio() throws Exception {
        Path carpeta = Path.of("target/studio-preview").toAbsolutePath();
        Files.createDirectories(carpeta);
        for (String nombre : new String[]{"empleado_academicos", "empleado_familiares", "empleado_ficha"}) {
            net.sf.jasperreports.engine.JasperCompileManager.compileReportToFile(
                    Path.of("src/main/webapp/WEB-INF/reportes", nombre + ".jrxml").toString(),
                    carpeta.resolve(nombre + ".jasper").toString());
        }
        Map<String, Object> parametros = new HashMap<>();
        parametros.put("USUARIO", "Vista previa de Jaspersoft Studio");
        parametros.put("EMPLEADO", "1712345678");
        byte[] pdf = net.sf.jasperreports.engine.JasperExportManager.exportReportToPdf(
                net.sf.jasperreports.engine.JasperFillManager.fillReport(
                        carpeta.resolve("empleado_ficha.jasper").toString(), parametros, conexion));
        String resultado = texto(pdf);
        assertTrue(resultado.contains("Magíster en Gestión"));
        assertTrue(resultado.contains("PÉREZ LÓPEZ ANA"));
    }
}
