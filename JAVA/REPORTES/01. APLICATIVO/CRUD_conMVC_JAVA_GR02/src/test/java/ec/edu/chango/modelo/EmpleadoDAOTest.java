package ec.edu.chango.modelo;

import ec.edu.chango.util.ConexionBD;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

/** Reproduce la tabla real peper_perso y sus restricciones en H2, sin escribir en MySQL. */
class EmpleadoDAOTest {
    private final EmpleadoDAO dao = new EmpleadoDAO();
    private final Map<String, String> configuracionAnterior = new HashMap<>();

    @BeforeEach void preparar() throws Exception {
        for (String variable : new String[]{"DB_URL", "DB_USER", "DB_PASSWORD", "DB_DRIVER"}) {
            assumeTrue(System.getenv(variable) == null || System.getenv(variable).isBlank(), "Se respetan las variables DB_* del entorno.");
        }
        for (String clave : new String[]{"db.url", "db.user", "db.password", "db.driver"}) configuracionAnterior.put(clave, System.getProperty(clave));
        System.setProperty("db.url", "jdbc:h2:mem:empleados;MODE=MySQL;DB_CLOSE_DELAY=-1");
        System.setProperty("db.user", "sa");
        System.setProperty("db.password", "empleados-test");
        System.setProperty("db.driver", "org.h2.Driver");
        try (Connection c = ConexionBD.obtener(); Statement s = c.createStatement()) {
            s.execute("DROP ALL OBJECTS");
            s.execute("CREATE TABLE PEGEN_GENERO (PEGEN_CODIGO CHAR(1) PRIMARY KEY, PEGEN_DESCRI VARCHAR(50))");
            s.execute("CREATE TABLE PEESC_ESTCIV (PEESC_CODIGO CHAR(1) PRIMARY KEY, PEESC_DESCRI VARCHAR(50))");
            s.execute("INSERT INTO PEGEN_GENERO VALUES ('M', 'MASCULINO'), ('F', 'FEMENINO')");
            s.execute("INSERT INTO PEESC_ESTCIV VALUES ('S', 'SOLTERO')");
            s.execute("CREATE TABLE peper_perso (PEPER_CODIGO CHAR(10) PRIMARY KEY, PEGEN_CODIGO CHAR(1) NOT NULL REFERENCES PEGEN_GENERO(PEGEN_CODIGO), PEESC_CODIGO CHAR(1) REFERENCES PEESC_ESTCIV(PEESC_CODIGO), PEPER_APELLI VARCHAR(50) NOT NULL, PEPER_NOMBRE VARCHAR(50) NOT NULL, PEPER_FECNAC DATE NOT NULL, PEPER_CEDULA VARCHAR(10), PEPER_PASAPO VARCHAR(15), PEPER_EMAIL VARCHAR(50), PEPER_CARFAM DECIMAL(2,0) NOT NULL, PEPER_FOTO VARCHAR(100) NOT NULL, PEPER_PESO DECIMAL(5,2), PEPER_TIPSANG VARCHAR(3), PEPER_DISC CHAR(1) NOT NULL)");
            s.execute("CREATE TABLE PEACA_ACADE (PEACA_CODIGO INT AUTO_INCREMENT PRIMARY KEY, PEPER_CODIGO CHAR(10) NOT NULL REFERENCES peper_perso(PEPER_CODIGO) ON DELETE CASCADE, PEACA_NIVEL VARCHAR(50) NOT NULL, PEACA_INSTI VARCHAR(100) NOT NULL, PEACA_TITUL VARCHAR(100) NOT NULL)");
            s.execute("CREATE TABLE PEFAM_FAMIL (PEFAM_CODIGO INT AUTO_INCREMENT PRIMARY KEY, PEPER_CODIGO CHAR(10) NOT NULL REFERENCES peper_perso(PEPER_CODIGO) ON DELETE CASCADE, PEFAM_PAREN VARCHAR(20) NOT NULL, PEFAM_NOMBRE VARCHAR(100) NOT NULL, PEFAM_FECNAC DATE NOT NULL)");
            s.execute("CREATE TABLE USUARIO_PRUEBA (PEPER_CODIGO CHAR(10) REFERENCES peper_perso(PEPER_CODIGO) ON DELETE RESTRICT)");
            s.execute("INSERT INTO peper_perso VALUES ('1712345678', 'M', NULL, 'PÉREZ', 'JOSÉ', '2000-03-14', '1712345678', NULL, 'persona@example.com', 2, 'josue1.jpeg', 68.50, 'O+', 'S')");
            s.execute("INSERT INTO PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL) VALUES ('1712345678', 'Maestría', 'Universidad', 'Magíster')");
            s.execute("INSERT INTO PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC) VALUES ('1712345678', 'MADRE', 'MARÍA', '1975-01-01')");
        }
    }

    @AfterEach void restaurar() {
        configuracionAnterior.forEach((clave, valor) -> { if (valor == null) System.clearProperty(clave); else System.setProperty(clave, valor); });
    }

    private Empleado nuevo() {
        Empleado e = new Empleado();
        e.setCodigo("0913456789");
        e.setApellidos("CAIZA");
        e.setNombres("ANDREA");
        e.setFechaNacimiento(LocalDate.of(1999, 8, 2));
        e.setCodigoGenero("F");
        e.setCodigoEstadoCivil("");
        e.setTipoSangre("");
        e.setAcademicos(List.of(new EmpleadoAcademico("Bachiller", "Colegio", "Ciencias")));
        e.setFamiliares(List.of(new EmpleadoFamiliar("MADRE", "ANA", LocalDate.of(1970, 1, 1))));
        return e;
    }

    private int contar(String tabla) throws Exception {
        try (Connection c = ConexionBD.obtener(); Statement s = c.createStatement(); ResultSet r = s.executeQuery("SELECT COUNT(*) FROM " + tabla)) {
            r.next(); return r.getInt(1);
        }
    }

    @Test void consultaLaPersonaRealYSusDetalles() throws Exception {
        assertEquals(1, dao.listar().size());
        Empleado e = dao.buscarPorCodigo("1712345678");
        assertEquals("PÉREZ", e.getApellidos());
        assertEquals("MASCULINO", e.getDescriGenero());
        assertNull(e.getCodigoEstadoCivil());
        assertEquals(1, e.getAcademicos().size());
        assertEquals(1, e.getFamiliares().size());
    }

    @Test void insertaSinFotoConTodosLosCamposObligatorios() throws Exception {
        assertTrue(dao.insertar(nuevo()));
        assertTrue(dao.existe("0913456789"));
        Empleado e = dao.buscarPorCodigo("0913456789");
        assertEquals("", e.getFoto());
        assertEquals(1, e.getAcademicos().size());
        assertEquals(1, e.getFamiliares().size());
        try (Connection c = ConexionBD.obtener(); Statement s = c.createStatement(); ResultSet r = s.executeQuery("SELECT PEPER_CARFAM, PEPER_DISC FROM peper_perso WHERE PEPER_CODIGO = '0913456789'")) {
            assertTrue(r.next());
            assertEquals(0, r.getInt(1));
            assertEquals("N", r.getString(2));
        }
    }

    @Test void editarConservaLosDatosDePersonaQueNoEstanEnLaFicha() throws Exception {
        Empleado e = dao.buscarPorCodigo("1712345678");
        e.setNombres("JOSÉ DANIEL");
        e.setFoto(null);
        e.setFamiliares(List.of());
        assertTrue(dao.actualizar(e));
        assertEquals("JOSÉ DANIEL", dao.buscarPorCodigo(e.getCodigo()).getNombres());
        assertEquals(0, dao.buscarPorCodigo(e.getCodigo()).getFamiliares().size());
        try (Connection c = ConexionBD.obtener(); Statement s = c.createStatement(); ResultSet r = s.executeQuery("SELECT PEPER_CARFAM, PEPER_DISC, PEPER_EMAIL, PEPER_CEDULA FROM peper_perso WHERE PEPER_CODIGO = '1712345678'")) {
            assertTrue(r.next());
            assertEquals(2, r.getInt(1));
            assertEquals("S", r.getString(2));
            assertEquals("persona@example.com", r.getString(3));
            assertEquals("1712345678", r.getString(4));
        }
    }

    @Test void noEliminaUnaPersonaConUsuarioAsociado() throws Exception {
        try (Connection c = ConexionBD.obtener(); Statement s = c.createStatement()) { s.execute("INSERT INTO USUARIO_PRUEBA VALUES ('1712345678')"); }
        assertThrows(SQLException.class, () -> dao.eliminar("1712345678"));
        assertTrue(dao.existe("1712345678"));
        assertEquals(1, contar("PEACA_ACADE"));
        assertEquals(1, contar("PEFAM_FAMIL"));
    }

    @Test void eliminaPersonaSinUsuarioYSusDetalles() throws Exception {
        assertTrue(dao.eliminar("1712345678"));
        assertEquals(0, contar("peper_perso"));
        assertEquals(0, contar("PEACA_ACADE"));
        assertEquals(0, contar("PEFAM_FAMIL"));
    }

    @Test void detalleInvalidoRevierteTodaLaInsercion() throws Exception {
        Empleado e = nuevo();
        e.setFamiliares(List.of(new EmpleadoFamiliar("MADRE", "x".repeat(101), LocalDate.of(1970, 1, 1))));
        assertThrows(SQLException.class, () -> dao.insertar(e));
        assertFalse(dao.existe(e.getCodigo()));
        assertEquals(1, contar("peper_perso"));
        assertEquals(1, contar("PEACA_ACADE"));
    }
}
