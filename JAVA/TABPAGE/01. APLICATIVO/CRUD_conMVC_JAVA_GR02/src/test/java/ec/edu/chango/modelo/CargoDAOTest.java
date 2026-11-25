package ec.edu.chango.modelo;

import ec.edu.chango.util.ConexionBD;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/** Integración SQL con H2 en modo MySQL; nunca usa la base del usuario. */
class CargoDAOTest {
    private final CargoDAO dao = new CargoDAO();

    @BeforeEach void preparar() throws Exception {
        org.junit.jupiter.api.Assumptions.assumeTrue(
            System.getenv("DB_URL") == null && System.getenv("DB_DRIVER") == null
            && System.getenv("DB_USER") == null && System.getenv("DB_PASSWORD") == null,
            "Quite las variables DB_* para ejecutar las pruebas aisladas con H2.");
        System.setProperty("db.driver", "org.h2.Driver");
        System.setProperty("db.url", "jdbc:h2:mem:cargos;MODE=MySQL;DB_CLOSE_DELAY=-1");
        System.setProperty("db.user", "sa");
        System.setProperty("db.password", "");
        try (Connection con = ConexionBD.obtener(); Statement st = con.createStatement()) {
            st.execute("DROP ALL OBJECTS");
            st.execute("CREATE TABLE PEDEP_DEPAR (PEDEP_CODIGO CHAR(3) PRIMARY KEY, PEDEP_DESCRI VARCHAR(50))");
            st.execute("CREATE TABLE PECAR_CARGO (PEDEP_CODIGO CHAR(3), PECAR_CODIGO CHAR(3), PECAR_DESCRI VARCHAR(50) NOT NULL, PRIMARY KEY(PEDEP_CODIGO, PECAR_CODIGO), FOREIGN KEY(PEDEP_CODIGO) REFERENCES PEDEP_DEPAR(PEDEP_CODIGO))");
            st.execute("INSERT INTO PEDEP_DEPAR VALUES ('SIS','Sistemas'), ('CON','Contabilidad')");
        }
    }

    @Test void crudAislaLaClaveCompuesta() throws Exception {
        assertTrue(dao.insertar(new Cargo("SIS", "ADM", "Administrador")));
        assertTrue(dao.insertar(new Cargo("CON", "ADM", "Administrador contable")));
        assertEquals(2, dao.listar().size());
        assertEquals("Sistemas", dao.buscarPorCodigo("SIS", "ADM").getDescriDepart());
        assertEquals(1, dao.listarPorDepartamento("CON").size());
        assertTrue(dao.actualizar(new Cargo("SIS", "ADM", "Jefe de sistemas")));
        assertEquals("Administrador contable", dao.buscarPorCodigo("CON", "ADM").getDescriCargo());
        assertTrue(dao.eliminar("SIS", "ADM"));
        assertNull(dao.buscarPorCodigo("SIS", "ADM"));
        assertTrue(dao.existe("CON", "ADM"));
    }

    @Test void restringeDuplicadosYDepartamentoInexistente() throws Exception {
        dao.insertar(new Cargo("SIS", "ADM", "Administrador"));
        assertThrows(SQLException.class, () -> dao.insertar(new Cargo("SIS", "ADM", "Duplicado")));
        assertThrows(SQLException.class, () -> dao.insertar(new Cargo("XXX", "ADM", "Sin departamento")));
    }

    @Test void conservaCargoConReferencias() throws Exception {
        dao.insertar(new Cargo("SIS", "ADM", "Administrador"));
        try (Connection con = ConexionBD.obtener(); Statement st = con.createStatement()) {
            st.execute("CREATE TABLE REFERENCIA_CARGO (DEP CHAR(3), CAR CHAR(3), FOREIGN KEY(DEP,CAR) REFERENCES PECAR_CARGO(PEDEP_CODIGO,PECAR_CODIGO))");
            st.execute("INSERT INTO REFERENCIA_CARGO VALUES ('SIS','ADM')");
        }
        assertThrows(SQLException.class, () -> dao.eliminar("SIS", "ADM"));
        assertTrue(dao.existe("SIS", "ADM"));
    }

    @Test void reportaRegistroInexistente() throws Exception {
        assertFalse(dao.actualizar(new Cargo("SIS", "XXX", "Ausente")));
        assertFalse(dao.eliminar("SIS", "XXX"));
    }
}
