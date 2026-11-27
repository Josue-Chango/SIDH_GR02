package ec.edu.chango.controlador;

import ec.edu.chango.modelo.*;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.*;
import java.lang.reflect.Proxy;
import java.sql.SQLException;
import java.util.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CargoControllerTest {
    private Map<String, Object> sesion, atributos;
    private Map<String, String> parametros;
    private HttpServletRequest req;
    private HttpServletResponse res;
    private FakeCargos dao;
    private CargoController controller;
    private String redirect;
    private int status, forwards;

    @SuppressWarnings("unchecked")
    private static <T> T proxy(Class<T> tipo, java.lang.reflect.InvocationHandler h) {
        return (T) Proxy.newProxyInstance(tipo.getClassLoader(), new Class<?>[]{tipo}, h);
    }

    @BeforeEach void preparar() {
        sesion = new HashMap<>(); atributos = new HashMap<>(); parametros = new HashMap<>();
        sesion.put("usuario", new Usuario()); sesion.put("cargoCsrf", "token");
        parametros.put("csrf", "token"); parametros.put("accion", "guardar"); parametros.put("modo", "nuevo");
        parametros.put("departamento", "SIS"); parametros.put("codigo", "ADM"); parametros.put("descripcion", "Administrador");
        status = 200; forwards = 0; redirect = null;
        HttpSession session = proxy(HttpSession.class, (p,m,a) -> {
            switch(m.getName()) {
                case "getAttribute": return sesion.get(a[0]);
                case "setAttribute": sesion.put((String)a[0], a[1]); return null;
                case "removeAttribute": sesion.remove(a[0]); return null;
                default: return null;
            }
        });
        RequestDispatcher dispatcher = proxy(RequestDispatcher.class, (p,m,a) -> { forwards++; return null; });
        req = proxy(HttpServletRequest.class, (p,m,a) -> {
            switch(m.getName()) {
                case "getSession": return session;
                case "getParameter": return parametros.get(a[0]);
                case "getAttribute": return atributos.get(a[0]);
                case "setAttribute": atributos.put((String)a[0], a[1]); return null;
                case "getContextPath": return "/app";
                case "getRequestDispatcher": return dispatcher;
                default: return null;
            }
        });
        res = proxy(HttpServletResponse.class, (p,m,a) -> {
            if (m.getName().equals("sendRedirect")) redirect = (String)a[0];
            if (m.getName().equals("sendError") || m.getName().equals("setStatus")) status = (int)a[0];
            return null;
        });
        dao = new FakeCargos();
        DepartamentoDAO deps = new DepartamentoDAO() {
            @Override public boolean existe(String codigo) { return "SIS".equals(codigo); }
            @Override public List<Departamento> listar() { return Arrays.asList(new Departamento("SIS", "Sistemas")); }
        };
        controller = new CargoController(dao, deps);
    }

    @Test void crearRedirigeYPublicaConfirmacion() throws Exception {
        controller.doPost(req, res);
        assertTrue(dao.existe("SIS", "ADM")); assertEquals("/app/CargoController", redirect);
        assertNotNull(sesion.get("cargoExito"));
    }
    @Test void sinSesionNoEscribe() throws Exception {
        sesion.remove("usuario"); controller.doPost(req, res);
        assertTrue(dao.items.isEmpty()); assertTrue(redirect.endsWith("index.jsp"));
    }
    @Test void rechazaTokenInvalido() throws Exception {
        parametros.put("csrf", "otro"); controller.doPost(req, res);
        assertEquals(403, status); assertTrue(dao.items.isEmpty());
    }
    @Test void validaLongitudesYConservaFormulario() throws Exception {
        parametros.put("descripcion", "x".repeat(51)); controller.doPost(req, res);
        assertTrue(dao.items.isEmpty()); assertNotNull(atributos.get("mensajeError"));
        assertEquals(51, ((Cargo)atributos.get("cargo")).getDescriCargo().length()); assertEquals(1, forwards);
    }
    @Test void rechazaCodigoCorto() throws Exception {
        parametros.put("codigo", "A"); controller.doPost(req, res);
        assertTrue(dao.items.isEmpty()); assertNotNull(atributos.get("mensajeError"));
    }
    @Test void rechazaDepartamentoInexistente() throws Exception {
        parametros.put("departamento", "XXX"); controller.doPost(req, res);
        assertTrue(dao.items.isEmpty()); assertNotNull(atributos.get("mensajeError"));
    }
    @Test void duplicadoNoReemplazaRegistro() throws Exception {
        dao.insertar(new Cargo("SIS", "ADM", "Original")); controller.doPost(req, res);
        assertEquals("Original", dao.buscarPorCodigo("SIS", "ADM").getDescriCargo()); assertEquals(1, forwards);
    }
    @Test void editarYEliminarUsanAmbosCodigos() throws Exception {
        dao.insertar(new Cargo("SIS", "ADM", "Original")); dao.insertar(new Cargo("CON", "ADM", "Contable"));
        parametros.put("modo", "editar"); controller.doPost(req, res);
        assertEquals("Administrador", dao.buscarPorCodigo("SIS", "ADM").getDescriCargo());
        parametros.put("accion", "eliminar"); controller.doPost(req, res);
        assertFalse(dao.existe("SIS", "ADM")); assertTrue(dao.existe("CON", "ADM"));
    }
    @Test void getEliminarNoBorra() throws Exception {
        dao.insertar(new Cargo("SIS", "ADM", "Original")); parametros.put("accion", "eliminar");
        controller.doGet(req, res); assertEquals(400, status); assertTrue(dao.existe("SIS", "ADM"));
    }
    @Test void registroAusenteNoSeCreaAlEditar() throws Exception {
        parametros.put("modo", "editar"); controller.doPost(req, res);
        assertTrue(dao.items.isEmpty()); assertNotNull(atributos.get("mensajeError"));
    }
    @Test void caidaBDNoGeneraBucleDeRedirecciones() throws Exception {
        dao.falla = true; parametros.remove("accion");
        // La caída es deliberada; evita que su traza parezca un fallo de compilación.
        java.util.logging.Logger log = java.util.logging.Logger.getLogger(CargoController.class.getName());
        java.util.logging.Level nivelAnterior = log.getLevel();
        try {
            log.setLevel(java.util.logging.Level.OFF);
            controller.doGet(req, res);
        } finally {
            log.setLevel(nivelAnterior);
        }
        assertEquals(503, status); assertNull(redirect); assertEquals(1, forwards);
    }
    @Test void filtraSoloElDepartamentoElegido() throws Exception {
        dao.insertar(new Cargo("SIS", "ADM", "Sistemas"));
        dao.insertar(new Cargo("CON", "ADM", "Contabilidad"));
        parametros.remove("accion"); parametros.put("filtroDepartamento", "CON");
        controller.doGet(req, res);
        List<?> lista = (List<?>) atributos.get("cargos");
        assertEquals(1, lista.size());
        assertEquals("CON", ((Cargo) lista.get(0)).getCodigoDepart());
        assertEquals("CON", atributos.get("filtroDepartamento"));
    }
    @Test void sinFiltroListaTodosYDepartamentoVacioNoMezclaCargos() throws Exception {
        dao.insertar(new Cargo("SIS", "ADM", "Sistemas")); parametros.remove("accion");
        controller.doGet(req, res); assertEquals(1, ((List<?>) atributos.get("cargos")).size());
        parametros.put("filtroDepartamento", "CON"); controller.doGet(req, res);
        assertTrue(((List<?>) atributos.get("cargos")).isEmpty());
    }
    @Test void conservaFiltroAlCrearEditarYEliminar() throws Exception {
        parametros.put("filtroDepartamento", "SIS"); controller.doPost(req, res);
        assertEquals("/app/CargoController?filtroDepartamento=SIS", redirect);
        parametros.put("accion", "editar"); controller.doGet(req, res);
        assertTrue(Boolean.TRUE.equals(atributos.get("modoEdicion")));
        assertEquals("SIS", atributos.get("filtroDepartamento"));
        parametros.put("accion", "guardar"); parametros.put("modo", "editar");
        parametros.put("descripcion", "Nuevo nombre"); controller.doPost(req, res);
        assertEquals("Nuevo nombre", dao.buscarPorCodigo("SIS", "ADM").getDescriCargo());
        assertEquals("/app/CargoController?filtroDepartamento=SIS", redirect);
        parametros.put("accion", "eliminar"); controller.doPost(req, res);
        assertTrue(dao.items.isEmpty());
        assertEquals("/app/CargoController?filtroDepartamento=SIS", redirect);
    }
    @Test void errorConservaFiltroYResultados() throws Exception {
        dao.insertar(new Cargo("CON", "ADM", "Contable"));
        parametros.put("filtroDepartamento", "CON"); parametros.put("descripcion", "");
        controller.doPost(req, res);
        assertEquals("CON", atributos.get("filtroDepartamento"));
        assertEquals(1, ((List<?>) atributos.get("cargos")).size());
        assertNotNull(atributos.get("mensajeError"));
    }
    @Test void traduceErroresMySQL() {
        assertTrue(CargoController.mensajeBD(new SQLException("", "23000",1062)).contains("Ya existe"));
        assertTrue(CargoController.mensajeBD(new SQLException("", "23000",1451)).contains("vinculado"));
        assertTrue(CargoController.mensajeBD(new SQLException("", "23000",1452)).contains("departamento"));
    }

    private static class FakeCargos extends CargoDAO {
        final Map<String,Cargo> items = new HashMap<>(); boolean falla;
        private String clave(String d,String c) { return d+":"+c; }
        @Override public Cargo buscarPorCodigo(String d,String c) { return items.get(clave(d,c)); }
        @Override public boolean existe(String d,String c) { return items.containsKey(clave(d,c)); }
        @Override public boolean insertar(Cargo c) { items.put(clave(c.getCodigoDepart(),c.getCodigoCargo()),c); return true; }
        @Override public boolean actualizar(Cargo c) { return items.replace(clave(c.getCodigoDepart(),c.getCodigoCargo()),c) != null; }
        @Override public boolean eliminar(String d,String c) { return items.remove(clave(d,c)) != null; }
        @Override public List<Cargo> listarPorDepartamento(String departamento) throws SQLException {
            List<Cargo> resultado = new ArrayList<>();
            for (Cargo cargo : listar()) if (departamento.equals(cargo.getCodigoDepart())) resultado.add(cargo);
            return resultado;
        }
        @Override public List<Cargo> listar() throws SQLException {
            if(falla) throw new SQLException("Conexión no disponible"); return new ArrayList<>(items.values());
        }
    }
}
