package ec.edu.chango.controlador;

import ec.edu.chango.modelo.Catalogo;
import ec.edu.chango.modelo.Empleado;
import ec.edu.chango.modelo.EmpleadoDAO;
import ec.edu.chango.modelo.Usuario;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class EmpleadoControllerTest {
    private final Map<String, String> parametros = new HashMap<>();
    private final Map<String, Object> atributos = new HashMap<>();
    private HttpServletRequest request;
    private HttpServletResponse response;
    private EmpleadoController controller;
    private Empleado actualizado;
    private Empleado insertado;
    private String codigoDisponible = "P000000004";
    private String redirect;
    private int forwards;

    @SuppressWarnings("unchecked")
    private static <T> T proxy(Class<T> tipo, java.lang.reflect.InvocationHandler handler) {
        return (T) Proxy.newProxyInstance(tipo.getClassLoader(), new Class<?>[]{tipo}, handler);
    }

    @BeforeEach void preparar() {
        parametros.put("accion", "guardar");
        parametros.put("modo", "editar");
        parametros.put("codigo", "P000000001");
        parametros.put("apellidos", "CHANGO");
        parametros.put("nombres", "JOSUÉ");
        parametros.put("fechaNacimiento", "2003-04-21");
        parametros.put("genero", "M");
        parametros.put("csrf", "token");
        HttpSession session = proxy(HttpSession.class, (p,m,a) -> {
            if ("getAttribute".equals(m.getName())) return "usuario".equals(a[0]) ? new Usuario() : "token";
            return null;
        });
        RequestDispatcher dispatcher = proxy(RequestDispatcher.class, (p,m,a) -> { if ("forward".equals(m.getName())) forwards++; return null; });
        request = proxy(HttpServletRequest.class, (p,m,a) -> {
            switch (m.getName()) {
                case "getSession": return session;
                case "getContextPath": return "/sigh";
                case "getParameter": return parametros.get(a[0]);
                case "getAttribute": return atributos.get(a[0]);
                case "getRequestDispatcher": return dispatcher;
                case "setAttribute": atributos.put((String)a[0], a[1]); return null;
                default: return null;
            }
        });
        response = proxy(HttpServletResponse.class, (p,m,a) -> {
            if ("sendRedirect".equals(m.getName())) redirect = (String)a[0];
            return null;
        });
        controller = new EmpleadoController(new EmpleadoDAO() {
            @Override public boolean existe(String codigo) { return "P000000001".equals(codigo); }
            @Override public boolean actualizar(Empleado empleado) { actualizado = empleado; return true; }
            @Override public String siguienteCodigoDisponible() { return codigoDisponible; }
            @Override public boolean insertarConCodigoAutomatico(Empleado empleado) { insertado = empleado; return true; }
            @Override public Empleado buscarPorCodigo(String codigo) {
                Empleado empleado = new Empleado();
                empleado.setCodigo(codigo);
                return empleado;
            }
            @Override public List<Empleado> listar() { return List.of(); }
            @Override public List<Catalogo> listarGeneros() { return List.of(new Catalogo("M", "MASCULINO")); }
            @Override public List<Catalogo> listarEstadosCiviles() { return List.of(); }
        });
    }

    @Test void permiteEditarLaFichaConElCodigoAlfanumericoDeLaBase() throws Exception {
        controller.doPost(request, response);
        assertNotNull(actualizado);
        assertEquals("P000000001", actualizado.getCodigo());
        assertEquals("JOSUÉ", actualizado.getNombres());
        assertEquals("/sigh/EmpleadoController?accion=editar&codigo=P000000001", redirect);
        assertEquals(0, forwards);
    }

    @Test void rechazaCodigoConCaracteresInvalidosAntesDeGuardar() throws Exception {
        parametros.put("codigo", "../P000001");
        controller.doPost(request, response);
        assertNull(actualizado);
        assertNotNull(atributos.get("mensajeError"));
        assertEquals(1, forwards);
    }

    @Test void solicitaElGeneroObligatorioDeLaTablaReal() throws Exception {
        parametros.put("genero", "");
        controller.doPost(request, response);
        assertNull(actualizado);
        assertEquals("Seleccione el sexo del empleado.", atributos.get("mensajeError"));
        assertEquals(1, forwards);
    }

    @Test void nuevaFichaMuestraElPrimerCodigoDisponibleDeLaBase() throws Exception {
        parametros.put("accion", "nuevo");
        controller.doGet(request, response);
        assertEquals("P000000004", ((Empleado) atributos.get("empleado")).getCodigo());
        assertEquals(1, forwards);
        assertNull(insertado);
    }

    @Test void listadoTambienPreparaElCodigoDeLaNuevaFicha() throws Exception {
        parametros.remove("accion");
        controller.doGet(request, response);
        assertEquals("P000000004", ((Empleado) atributos.get("empleado")).getCodigo());
    }

    @Test void editarConservaElCodigoExistente() throws Exception {
        parametros.put("accion", "editar");
        controller.doGet(request, response);
        assertEquals("P000000001", ((Empleado) atributos.get("empleado")).getCodigo());
        assertEquals(true, atributos.get("modoEdicion"));
    }

    @Test void alCrearIgnoraInclusoUnCodigoManipuladoEnElFormulario() throws Exception {
        parametros.put("modo", "nuevo");
        parametros.put("codigo", "../manual");
        controller.doPost(request, response);
        assertNotNull(insertado);
        assertEquals("P000000004", insertado.getCodigo());
        assertEquals("/sigh/EmpleadoController?accion=editar&codigo=P000000004", redirect);
    }

    @Test void noNecesitaRecibirCodigoParaCrearLaFicha() throws Exception {
        parametros.put("modo", "nuevo");
        parametros.remove("codigo");
        controller.doPost(request, response);
        assertNotNull(insertado);
        assertEquals("P000000004", insertado.getCodigo());
    }

    @Test void guardarConsultaOtraVezLaBaseSiElCodigoMostradoYaSeOcupo() throws Exception {
        parametros.put("modo", "nuevo");
        parametros.put("codigo", "P000000004");
        codigoDisponible = "P000000005";
        controller.doPost(request, response);
        assertEquals("P000000005", insertado.getCodigo());
    }

    @Test void errorDeValidacionConservaLosDatosYElCodigoAutomatico() throws Exception {
        parametros.put("modo", "nuevo");
        parametros.put("genero", "");
        controller.doPost(request, response);
        Empleado formulario = (Empleado) atributos.get("empleado");
        assertEquals("P000000004", formulario.getCodigo());
        assertEquals("JOSUÉ", formulario.getNombres());
        assertNotNull(atributos.get("mensajeError"));
        assertNull(insertado);
        assertEquals(1, forwards);
    }
}
