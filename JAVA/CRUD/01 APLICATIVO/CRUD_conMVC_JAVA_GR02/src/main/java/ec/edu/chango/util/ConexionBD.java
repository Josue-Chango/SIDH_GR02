package ec.edu.chango.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Administra la conexión JDBC hacia MySQL.
 *
 * La configuración se lee de /db.properties. También se puede sobrescribir con
 * las variables de entorno DB_URL, DB_USER, DB_PASSWORD y DB_DRIVER, o con las
 * propiedades de sistema db.url, db.user, db.password y db.driver.
 *
 * @author josue
 */
public final class ConexionBD {

    private static final Logger LOG = Logger.getLogger(ConexionBD.class.getName());
    private static final String ARCHIVO_CONFIG = "/db.properties";
    private static final Properties CONFIG = new Properties();

    static {
        try (InputStream entrada = ConexionBD.class.getResourceAsStream(ARCHIVO_CONFIG)) {
            if (entrada == null) {
                throw new IllegalStateException("No se encontró el archivo " + ARCHIVO_CONFIG);
            }
            try (Reader lector = new InputStreamReader(entrada, StandardCharsets.UTF_8)) {
                CONFIG.load(lector);
            }
        } catch (IOException ex) {
            throw new ExceptionInInitializerError(ex);
        }
    }

    private ConexionBD() {
    }

    /**
     * Abre una conexión nueva con MySQL.
     *
     * @return conexión JDBC lista para usarse.
     * @throws SQLException si no se puede cargar el driver o conectar.
     */
    public static Connection obtener() throws SQLException {
        String driver = obtenerValor("db.driver", "com.mysql.cj.jdbc.Driver");
        String url = obtenerValor("db.url", null);
        String usuario = obtenerValor("db.user", null);
        String password = obtenerValor("db.password", "");

        if (url == null || url.trim().isEmpty()) {
            throw new SQLException("Configure db.url en src/main/resources/db.properties");
        }
        if (usuario == null || usuario.trim().isEmpty()) {
            throw new SQLException("Configure db.user en src/main/resources/db.properties");
        }

        try {
            Class.forName(driver);
        } catch (ClassNotFoundException ex) {
            throw new SQLException("No se encontró el driver JDBC: " + driver, ex);
        }

        LOG.log(Level.FINE, "Conectando a {0} como {1}", new Object[]{url, usuario});
        return DriverManager.getConnection(url, usuario, password);
    }

    private static String obtenerValor(String clave, String valorPorDefecto) {
        String variableEntorno = clave.toUpperCase().replace('.', '_');
        String valor = System.getenv(variableEntorno);
        if (valor != null && !valor.trim().isEmpty()) {
            return valor;
        }

        valor = System.getProperty(clave);
        if (valor != null && !valor.trim().isEmpty()) {
            return valor;
        }

        valor = CONFIG.getProperty(clave);
        return valor != null ? valor : valorPorDefecto;
    }
}
