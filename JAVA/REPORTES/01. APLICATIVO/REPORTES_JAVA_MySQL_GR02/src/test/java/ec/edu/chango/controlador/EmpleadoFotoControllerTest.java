package ec.edu.chango.controlador;

import ec.edu.chango.modelo.Catalogo;
import ec.edu.chango.modelo.Empleado;
import ec.edu.chango.modelo.EmpleadoDAO;
import ec.edu.chango.modelo.Usuario;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.lang.reflect.Proxy;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import static org.junit.jupiter.api.Assertions.*;

/** Ejecuta la carga multipart y el guardado real de imágenes en una carpeta aislada. */
class EmpleadoFotoControllerTest {
    @TempDir Path web;
    private final Map<String, String> parametros = new HashMap<>();
    private final Map<String, Object> atributos = new HashMap<>();
    private final Logger log = Logger.getLogger(EmpleadoController.class.getName());
    private Level nivelAnterior;
    private EmpleadoController controller;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private Part foto;
    private String nombreSubido = "foto.png";
    private String fotoGuardada = "fotos_empleados/P000000001.jpg";
    private String redirect;
    private boolean falloBD;
    private boolean noActualizado;
    private boolean limiteMultipart;
    private int estado;
    private int actualizaciones;

    @SuppressWarnings("unchecked")
    private static <T> T proxy(Class<T> tipo, java.lang.reflect.InvocationHandler handler) {
        return (T) Proxy.newProxyInstance(tipo.getClassLoader(), new Class<?>[]{tipo}, handler);
    }

    @BeforeEach void preparar() throws Exception {
        nivelAnterior = log.getLevel();
        log.setLevel(Level.OFF); // Estas pruebas también provocan fallos de carga y BD deliberados.
        parametros.put("accion", "guardar");
        parametros.put("modo", "editar");
        parametros.put("codigo", "P000000001");
        parametros.put("apellidos", "PÉREZ");
        parametros.put("nombres", "ANA");
        parametros.put("fechaNacimiento", "2000-01-01");
        parametros.put("genero", "F");
        parametros.put("csrf", "token");
        parametros.put("fotoActual", fotoGuardada);
        Files.createDirectories(web.resolve("resource/fotos_empleados"));
        Files.write(archivo(fotoGuardada), imagen("jpg", false, Color.RED));
        HttpSession sesion = proxy(HttpSession.class, (p, m, a) -> {
            if ("getAttribute".equals(m.getName())) return "usuario".equals(a[0]) ? new Usuario() : "token";
            return null;
        });
        RequestDispatcher dispatcher = proxy(RequestDispatcher.class, (p, m, a) -> null);
        request = proxy(HttpServletRequest.class, (p, m, a) -> {
            switch (m.getName()) {
                case "getSession": return sesion;
                case "getContextPath": return "/sigh";
                case "getContentType": return "multipart/form-data; boundary=prueba";
                case "getParameter": return parametros.get(a[0]);
                case "getAttribute": return atributos.get(a[0]);
                case "setAttribute": atributos.put((String) a[0], a[1]); return null;
                case "getRequestDispatcher": return dispatcher;
                case "getPart": return foto;
                case "getParts":
                    if (limiteMultipart) throw new IllegalStateException("Carga mayor que maxFileSize");
                    return foto == null ? List.of() : List.of(foto);
                default: return null;
            }
        });
        response = proxy(HttpServletResponse.class, (p, m, a) -> {
            if ("sendRedirect".equals(m.getName())) redirect = (String) a[0];
            if ("sendError".equals(m.getName())) estado = (Integer) a[0];
            return null;
        });
        controller = new EmpleadoController(new EmpleadoDAO() {
            @Override public boolean existe(String codigo) { return true; }
            @Override public Empleado buscarPorCodigo(String codigo) {
                Empleado empleado = new Empleado();
                empleado.setCodigo(codigo);
                empleado.setFoto(fotoGuardada);
                return empleado;
            }
            @Override public boolean actualizar(Empleado empleado) throws SQLException {
                actualizaciones++;
                if (falloBD) throw new SQLException("Fallo simulado al guardar la nueva foto");
                if (noActualizado) return false;
                fotoGuardada = empleado.getFoto();
                return true;
            }
            @Override public List<Empleado> listar() { return List.of(); }
            @Override public List<Catalogo> listarGeneros() { return List.of(); }
            @Override public List<Catalogo> listarEstadosCiviles() { return List.of(); }
        });
        ServletContext contexto = proxy(ServletContext.class, (p, m, a) -> {
            if ("getRealPath".equals(m.getName())) return web.resolve(((String) a[0]).substring(1)).toString();
            return null;
        });
        ServletConfig configuracion = proxy(ServletConfig.class, (p, m, a) ->
                "getServletContext".equals(m.getName()) ? contexto : null);
        controller.init(configuracion);
    }

    @AfterEach void restaurarLog() { log.setLevel(nivelAnterior); }

    private Path archivo(String ruta) { return web.resolve("resource").resolve(ruta); }

    private byte[] imagen(String formato, boolean transparente, Color color) throws Exception {
        BufferedImage imagen = new BufferedImage(8, 8,
                transparente ? BufferedImage.TYPE_INT_ARGB : BufferedImage.TYPE_INT_RGB);
        for (int x = 0; x < 4; x++) for (int y = 0; y < 8; y++) imagen.setRGB(x, y, color.getRGB());
        ByteArrayOutputStream salida = new ByteArrayOutputStream();
        assertTrue(ImageIO.write(imagen, formato, salida));
        return salida.toByteArray();
    }

    private void adjuntar(byte[] bytes) {
        foto = proxy(Part.class, (p, m, a) -> {
            switch (m.getName()) {
                case "getSize": return (long) bytes.length;
                case "getInputStream": return new ByteArrayInputStream(bytes);
                case "getContentType": return "image/png";
                case "getSubmittedFileName": return nombreSubido;
                default: return null;
            }
        });
    }

    private long cantidadFotos() throws Exception {
        try (java.util.stream.Stream<Path> fotos = Files.list(web.resolve("resource/fotos_empleados"))) {
            return fotos.count();
        }
    }

    @Test void pngTransparenteSeGuardaCompletoSinPerderSusBytesNiTransparencia() throws Exception {
        String anterior = fotoGuardada;
        byte[] contenido = imagen("png", true, Color.BLUE);
        adjuntar(contenido);
        controller.doPost(request, response);
        assertNotEquals(anterior, fotoGuardada);
        assertTrue(fotoGuardada.endsWith(".png"));
        assertArrayEquals(contenido, Files.readAllBytes(archivo(fotoGuardada)));
        BufferedImage guardada = ImageIO.read(archivo(fotoGuardada).toFile());
        assertNotNull(guardada);
        assertEquals(8, guardada.getWidth());
        assertTrue(guardada.getColorModel().hasAlpha());
        assertEquals(0, guardada.getRGB(7, 4) >>> 24);
        assertFalse(Files.exists(archivo(anterior)));
        assertEquals(1, cantidadFotos());
        assertEquals("/sigh/EmpleadoController?accion=editar&codigo=P000000001", redirect);
    }

    @Test void cadaReemplazoCambiaLaDireccionParaEvitarLaFotoEnCache() throws Exception {
        String original = fotoGuardada;
        adjuntar(imagen("jpg", false, Color.BLUE));
        controller.doPost(request, response);
        String primera = fotoGuardada;
        adjuntar(imagen("jpg", false, Color.GREEN));
        controller.doPost(request, response);
        assertNotEquals(original, primera);
        assertNotEquals(primera, fotoGuardada);
        assertFalse(Files.exists(archivo(primera)));
        assertNotNull(ImageIO.read(archivo(fotoGuardada).toFile()));
        assertEquals(1, cantidadFotos());
    }

    @Test void sinArchivoNuevoConservaLaFotoDeLaBaseAunqueElCampoOcultoEsteDesactualizado() throws Exception {
        parametros.put("fotoActual", "fotos_empleados/otra-persona.jpg");
        controller.doPost(request, response);
        assertEquals("fotos_empleados/P000000001.jpg", fotoGuardada);
        assertEquals(1, cantidadFotos());
    }

    @Test void errorDeBaseConservaLaFotoAnteriorYEliminaLaCargaSinGuardar() throws Exception {
        String anterior = fotoGuardada;
        byte[] contenidoAnterior = Files.readAllBytes(archivo(anterior));
        falloBD = true;
        adjuntar(imagen("jpg", false, Color.BLUE));
        controller.doPost(request, response);
        assertEquals(anterior, fotoGuardada);
        assertArrayEquals(contenidoAnterior, Files.readAllBytes(archivo(anterior)));
        assertEquals(anterior, ((Empleado) atributos.get("empleado")).getFoto());
        assertEquals(1, cantidadFotos());
        assertNotNull(atributos.get("mensajeError"));
        assertNull(redirect);
    }

    @Test void actualizacionSinFilasConservaLaFotoAnterior() throws Exception {
        noActualizado = true;
        byte[] anterior = Files.readAllBytes(archivo(fotoGuardada));
        adjuntar(imagen("jpg", false, Color.BLUE));
        controller.doPost(request, response);
        assertArrayEquals(anterior, Files.readAllBytes(archivo(fotoGuardada)));
        assertEquals(1, cantidadFotos());
        assertNotNull(atributos.get("mensajeError"));
    }

    @Test void archivoQueNoEsImagenNoModificaLaFichaNiLaFotoAnterior() throws Exception {
        byte[] anterior = Files.readAllBytes(archivo(fotoGuardada));
        adjuntar(new byte[]{1, 2, 3, 4});
        controller.doPost(request, response);
        assertEquals(0, actualizaciones);
        assertArrayEquals(anterior, Files.readAllBytes(archivo(fotoGuardada)));
        assertEquals(1, cantidadFotos());
        assertNotNull(atributos.get("mensajeError"));
    }

    @Test void cargaQueSuperaElLimiteDevuelveUnErrorControlado() throws Exception {
        limiteMultipart = true;
        controller.doPost(request, response);
        assertEquals(413, estado);
        assertEquals(0, actualizaciones);
        assertEquals(1, cantidadFotos());
    }

    @Test void jpegConExtensionJfifSeGuardaSinReusarElStreamCerrado() throws Exception {
        byte[] contenido = imagen("jpg", false, Color.BLUE);
        nombreSubido = "perfil.jfif";
        adjuntar(contenido);
        controller.doPost(request, response);
        assertTrue(fotoGuardada.endsWith(".jpg"));
        assertArrayEquals(contenido, Files.readAllBytes(archivo(fotoGuardada)));
        assertTrue(Files.size(archivo(fotoGuardada)) > 0);
    }

    @Test void webpRenombradoAJpgMuestraElFormatoRealYConservaLaFotoAnterior() throws Exception {
        nombreSubido = "perfil.jpg";
        adjuntar("RIFF1234WEBPVP8 ".getBytes(java.nio.charset.StandardCharsets.US_ASCII));
        controller.doPost(request, response);
        String error = (String) atributos.get("mensajeError");
        assertTrue(error.contains("WebP"));
        assertTrue(error.contains("Paint"));
        assertEquals(0, actualizaciones);
        assertEquals(1, cantidadFotos());
    }

    @Test void fotoSeleccionadaConCeroBytesMuestraErrorEnLugarDeConfirmarElGuardado() throws Exception {
        adjuntar(new byte[0]);
        controller.doPost(request, response);
        assertTrue(((String) atributos.get("mensajeError")).contains("archivo vacío"));
        assertEquals(0, actualizaciones);
        assertEquals(1, cantidadFotos());
        assertNull(redirect);
    }

    @Test void alReemplazarUnPngTambienEliminaElArchivoAnteriorTrasGuardar() throws Exception {
        adjuntar(imagen("png", true, Color.BLUE));
        controller.doPost(request, response);
        String anterior = fotoGuardada;
        adjuntar(imagen("jpg", false, Color.GREEN));
        controller.doPost(request, response);
        assertFalse(Files.exists(archivo(anterior)));
        assertTrue(fotoGuardada.endsWith(".jpg"));
        assertEquals(1, cantidadFotos());
    }
}
