package ec.edu.chango.controlador;

import ec.edu.chango.modelo.Usuario;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.lang.reflect.Proxy;
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
import static org.junit.jupiter.api.Assumptions.assumeTrue;

class ReporteControllerTest {
    private final Map<String, String> parametros = new HashMap<>();
    private final Map<String, String> cabeceras = new HashMap<>();
    private final Map<String, String> propiedades = new HashMap<>();
    private final ByteArrayOutputStream salida = new ByteArrayOutputStream();
    private ReporteController controller;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private boolean autenticado;
    private String redirect, contentType;
    private int estado, longitud;

    @SuppressWarnings("unchecked")
    private static <T> T proxy(Class<T> tipo, java.lang.reflect.InvocationHandler handler) {
        return (T) Proxy.newProxyInstance(tipo.getClassLoader(), new Class<?>[]{tipo}, handler);
    }

    @BeforeEach void preparar() throws Exception {
        for (String variable : new String[]{"DB_URL", "DB_USER", "DB_PASSWORD", "DB_DRIVER"}) {
            assumeTrue(System.getenv(variable) == null || System.getenv(variable).isBlank(), "Se omite para respetar DB_* del entorno.");
        }
        for (String clave : new String[]{"db.url", "db.user", "db.password", "db.driver"}) propiedades.put(clave, System.getProperty(clave));
        String url = "jdbc:h2:mem:controladorReportes;MODE=MySQL;DB_CLOSE_DELAY=-1";
        System.setProperty("db.url", url);
        System.setProperty("db.user", "sa");
        System.setProperty("db.password", "reportes-test");
        System.setProperty("db.driver", "org.h2.Driver");
        try (Connection c = DriverManager.getConnection(url, "sa", "reportes-test"); Statement s = c.createStatement()) {
            s.execute("DROP ALL OBJECTS");
            s.execute("CREATE TABLE PEDEP_DEPAR (PEDEP_CODIGO CHAR(3), PEDEP_DESCRI VARCHAR(50))");
            s.execute("INSERT INTO PEDEP_DEPAR VALUES ('SIS', 'Sistemas')");
            s.execute("CREATE TABLE peper_perso (PEPER_CODIGO CHAR(10), PEPER_FOTO VARCHAR(100), PEPER_APELLI VARCHAR(50), PEPER_NOMBRE VARCHAR(50), PEPER_FECNAC DATE, PEGEN_CODIGO CHAR(1), PEESC_CODIGO CHAR(1), PEPER_PESO DECIMAL(5,2), PEPER_TIPSANG VARCHAR(3))");
            s.execute("INSERT INTO peper_perso VALUES ('P000000001', '', 'PÉREZ', 'JOSÉ', '2000-03-14', 'M', NULL, 68.50, 'O+')");
            s.execute("CREATE TABLE PEGEN_GENERO (PEGEN_CODIGO CHAR(1), PEGEN_DESCRI VARCHAR(50))");
            s.execute("INSERT INTO PEGEN_GENERO VALUES ('M', 'MASCULINO')");
            s.execute("CREATE TABLE PEESC_ESTCIV (PEESC_CODIGO CHAR(1), PEESC_DESCRI VARCHAR(50))");
            s.execute("CREATE TABLE PEACA_ACADE (PEACA_CODIGO INT, PEPER_CODIGO CHAR(10), PEACA_NIVEL VARCHAR(50), PEACA_INSTI VARCHAR(100), PEACA_TITUL VARCHAR(100))");
            s.execute("CREATE TABLE PEFAM_FAMIL (PEFAM_CODIGO INT, PEPER_CODIGO CHAR(10), PEFAM_PAREN VARCHAR(20), PEFAM_NOMBRE VARCHAR(100), PEFAM_FECNAC DATE)");
        }
        autenticado = true;
        estado = 200;
        parametros.put("r", "departamentos");
        HttpSession session = proxy(HttpSession.class, (p,m,a) -> "getAttribute".equals(m.getName()) ? new Usuario() : null);
        request = proxy(HttpServletRequest.class, (p,m,a) -> {
            switch (m.getName()) {
                case "getSession": return autenticado ? session : null;
                case "getContextPath": return "/sigh";
                case "getParameter": return parametros.get(a[0]);
                default: return null;
            }
        });
        ServletOutputStream stream = new ServletOutputStream() {
            @Override public void write(int valor) { salida.write(valor); }
            @Override public boolean isReady() { return true; }
            @Override public void setWriteListener(WriteListener listener) { }
        };
        response = proxy(HttpServletResponse.class, (p,m,a) -> {
            switch (m.getName()) {
                case "sendRedirect": redirect = (String) a[0]; return null;
                case "sendError": estado = (int) a[0]; return null;
                case "setHeader": cabeceras.put((String)a[0], (String)a[1]); return null;
                case "setContentType": contentType = (String) a[0]; return null;
                case "setContentLength": longitud = (int) a[0]; return null;
                case "getOutputStream": return stream;
                case "isCommitted": return false;
                default: return null;
            }
        });
        ServletContext context = proxy(ServletContext.class, (p,m,a) -> {
            if ("getResourceAsStream".equals(m.getName())) {
                try { return Files.newInputStream(Path.of("src/main/webapp" + a[0])); }
                catch (IOException ex) { return null; }
            }
            return null;
        });
        ServletConfig config = proxy(ServletConfig.class, (p,m,a) -> "getServletContext".equals(m.getName()) ? context : null);
        controller = new ReporteController();
        controller.init(config);
    }

    @AfterEach void restaurar() {
        propiedades.forEach((clave, valor) -> { if (valor == null) System.clearProperty(clave); else System.setProperty(clave, valor); });
    }

    @Test void sinSesionRedirigeAlLogin() throws Exception {
        autenticado = false;
        controller.doGet(request, response);
        assertEquals("/sigh/ec/edu/chango/vista/index.jsp", redirect);
        assertEquals(0, salida.size());
    }

    @Test void reporteDesconocidoNoPermiteLeerArchivos() throws Exception {
        parametros.put("r", "../../db.properties");
        controller.doGet(request, response);
        assertEquals(404, estado);
        assertEquals(0, salida.size());
    }

    @Test void filtroInvalidoNoAmpliaConsulta() throws Exception {
        parametros.put("r", "cargos");
        parametros.put("departamento", "' OR 1=1 --");
        controller.doGet(request, response);
        assertEquals(400, estado);
        assertEquals(0, salida.size());
    }

    @Test void fichaRequiereCodigoValido() throws Exception {
        parametros.put("r", "ficha");
        parametros.put("codigo", "P/001");
        controller.doGet(request, response);
        assertEquals(400, estado);
    }

    @Test void fichaAceptaCodigoAlfanumericoExistente() throws Exception {
        parametros.put("r", "ficha");
        parametros.put("codigo", "P000000001");
        controller.doGet(request, response);
        assertEquals(200, estado);
        assertEquals("application/pdf", contentType);
        assertEquals("inline; filename=\"ficha-empleado-P000000001.pdf\"", cabeceras.get("Content-Disposition"));
        assertTrue(salida.size() > 1000);
    }

    @Test void fichaDeEmpleadoInexistenteDevuelve404() throws Exception {
        parametros.put("r", "ficha");
        parametros.put("codigo", "1712345678");
        controller.doGet(request, response);
        assertEquals(404, estado);
        assertEquals(0, salida.size());
    }

    @Test void generaPdfConCabecerasYLongitudCorrectas() throws Exception {
        controller.doGet(request, response);
        assertEquals(200, estado);
        assertEquals("application/pdf", contentType);
        assertEquals("inline; filename=\"departamentos.pdf\"", cabeceras.get("Content-Disposition"));
        assertTrue(cabeceras.get("Cache-Control").contains("no-store"));
        assertEquals("nosniff", cabeceras.get("X-Content-Type-Options"));
        assertEquals(salida.size(), longitud);
        assertTrue(salida.size() > 1000);
        assertTrue(salida.toString(java.nio.charset.StandardCharsets.ISO_8859_1).startsWith("%PDF-"));
    }

    @Test void falloDeBaseNoEnviaPdfParcial() throws Exception {
        System.setProperty("db.driver", "driver.inexistente");
        // Este driver falla intencionalmente. Solo se silencia la traza de esta prueba.
        java.util.logging.Logger log = java.util.logging.Logger.getLogger(ReporteController.class.getName());
        java.util.logging.Level nivelAnterior = log.getLevel();
        try {
            log.setLevel(java.util.logging.Level.OFF);
            controller.doGet(request, response);
        } finally {
            log.setLevel(nivelAnterior);
        }
        assertEquals(503, estado);
        assertEquals(0, salida.size());
        assertNull(contentType);
    }
}
