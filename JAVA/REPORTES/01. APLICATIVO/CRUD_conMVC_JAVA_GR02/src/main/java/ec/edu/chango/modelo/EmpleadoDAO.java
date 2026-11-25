package ec.edu.chango.modelo;

import ec.edu.chango.util.ConexionBD;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Acceso a datos del Mantenimiento de Empleados con Tab Page.
 *
 * Administra la tabla peper_perso junto con sus dos subtablas:
 * PEACA_ACADE (Datos Académicos) y PEFAM_FAMIL (Datos Familiares).
 * Los inserts y updates se realizan dentro de una transacción para
 * que la persona y sus subtablas se guarden completas o nada.
 *
 * @author josue
 */
public class EmpleadoDAO {

    /** SELECT base del empleado junto a las descripciones de sus catálogos. */
    private static final String SQL_LISTAR_BASE
            = "SELECT p.PEPER_CODIGO, p.PEPER_APELLI, p.PEPER_NOMBRE, p.PEPER_FECNAC, "
            + "p.PEGEN_CODIGO, g.PEGEN_DESCRI, p.PEESC_CODIGO, e.PEESC_DESCRI, "
            + "p.PEPER_PESO, p.PEPER_TIPSANG, p.PEPER_FOTO "
            + "FROM peper_perso p "
            + "LEFT JOIN PEGEN_GENERO g ON g.PEGEN_CODIGO = p.PEGEN_CODIGO "
            + "LEFT JOIN PEESC_ESTCIV e ON e.PEESC_CODIGO = p.PEESC_CODIGO ";

    private static final String SQL_LISTAR
            = SQL_LISTAR_BASE + "ORDER BY p.PEPER_APELLI, p.PEPER_NOMBRE";

    private static final String SQL_BUSCAR
            = SQL_LISTAR_BASE + "WHERE p.PEPER_CODIGO = ?";

    private static final String SQL_INSERTAR
            = "INSERT INTO peper_perso (PEPER_CODIGO, PEPER_APELLI, PEPER_NOMBRE, "
            + "PEPER_FECNAC, PEGEN_CODIGO, PEESC_CODIGO, PEPER_PESO, PEPER_TIPSANG, PEPER_FOTO, "
            + "PEPER_CARFAM, PEPER_DISC) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 'N')";

    private static final String SQL_ACTUALIZAR
            = "UPDATE peper_perso SET PEPER_APELLI = ?, PEPER_NOMBRE = ?, PEPER_FECNAC = ?, "
            + "PEGEN_CODIGO = ?, PEESC_CODIGO = ?, PEPER_PESO = ?, PEPER_TIPSANG = ?, PEPER_FOTO = ? "
            + "WHERE PEPER_CODIGO = ?";

    private static final String SQL_ELIMINAR
            = "DELETE FROM peper_perso WHERE PEPER_CODIGO = ?";

    private static final String SQL_ELIMINAR_ACADEMICOS
            = "DELETE FROM PEACA_ACADE WHERE PEPER_CODIGO = ?";

    private static final String SQL_ELIMINAR_FAMILIARES
            = "DELETE FROM PEFAM_FAMIL WHERE PEPER_CODIGO = ?";

    private static final String SQL_INSERTAR_ACADEMICO
            = "INSERT INTO PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL) "
            + "VALUES (?, ?, ?, ?)";

    private static final String SQL_INSERTAR_FAMILIAR
            = "INSERT INTO PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC) "
            + "VALUES (?, ?, ?, ?)";

    private static final String SQL_LISTAR_ACADEMICOS
            = "SELECT PEACA_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL "
            + "FROM PEACA_ACADE WHERE PEPER_CODIGO = ? ORDER BY PEACA_CODIGO";

    private static final String SQL_LISTAR_FAMILIARES
            = "SELECT PEFAM_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC "
            + "FROM PEFAM_FAMIL WHERE PEPER_CODIGO = ? ORDER BY PEFAM_CODIGO";

    /**
     * Lista todos los empleados con las descripciones de sexo y estado civil.
     */
    public List<Empleado> listar() throws SQLException {
        List<Empleado> empleados = new ArrayList<>();
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_LISTAR);
             ResultSet resultado = sentencia.executeQuery()) {
            while (resultado.next()) {
                empleados.add(mapear(resultado));
            }
        }
        return empleados;
    }

    /**
     * Busca el empleado por su código de persona y carga además sus
     * subtablas de Datos Académicos y Datos Familiares.
     *
     * @return el empleado con sus detalles, o null si no existe.
     */
    public Empleado buscarPorCodigo(String codigo) throws SQLException {
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_BUSCAR)) {
            sentencia.setString(1, codigo);
            try (ResultSet resultado = sentencia.executeQuery()) {
                if (!resultado.next()) {
                    return null;
                }
                Empleado empleado = mapear(resultado);
                empleado.setAcademicos(listarAcademicos(conexion, codigo));
                empleado.setFamiliares(listarFamiliares(conexion, codigo));
                return empleado;
            }
        }
    }

    public boolean existe(String codigo) throws SQLException {
        String sql = "SELECT 1 FROM peper_perso WHERE PEPER_CODIGO = ?";
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(sql)) {
            sentencia.setString(1, codigo);
            try (ResultSet resultado = sentencia.executeQuery()) {
                return resultado.next();
            }
        }
    }

    /**
     * Inserta el empleado y sus subtablas dentro de una transacción.
     */
    public boolean insertar(Empleado empleado) throws SQLException {
        Connection conexion = null;
        try {
            conexion = ConexionBD.obtener();
            conexion.setAutoCommit(false);
            try (PreparedStatement sentencia = conexion.prepareStatement(SQL_INSERTAR)) {
                llenarParametrosPersona(sentencia, empleado, true);
                sentencia.executeUpdate();
            }
            insertarDetalles(conexion, empleado);
            conexion.commit();
            return true;
        } catch (SQLException ex) {
            revertir(conexion);
            throw ex;
        } finally {
            cerrar(conexion);
        }
    }

    /**
     * Actualiza los datos del empleado y reemplaza el contenido completo
     * de sus subtablas dentro de una transacción.
     */
    public boolean actualizar(Empleado empleado) throws SQLException {
        Connection conexion = null;
        try {
            conexion = ConexionBD.obtener();
            conexion.setAutoCommit(false);
            int filas;
            try (PreparedStatement sentencia = conexion.prepareStatement(SQL_ACTUALIZAR)) {
                llenarParametrosPersona(sentencia, empleado, false);
                filas = sentencia.executeUpdate();
            }
            if (filas == 0) {
                conexion.rollback();
                return false;
            }
            try (PreparedStatement sentencia = conexion.prepareStatement(SQL_ELIMINAR_ACADEMICOS)) {
                sentencia.setString(1, empleado.getCodigo());
                sentencia.executeUpdate();
            }
            try (PreparedStatement sentencia = conexion.prepareStatement(SQL_ELIMINAR_FAMILIARES)) {
                sentencia.setString(1, empleado.getCodigo());
                sentencia.executeUpdate();
            }
            insertarDetalles(conexion, empleado);
            conexion.commit();
            return true;
        } catch (SQLException ex) {
            revertir(conexion);
            throw ex;
        } finally {
            cerrar(conexion);
        }
    }

    /**
     * Elimina el empleado. Las subtablas se borran en cascada por la
     * clave foránea (ON DELETE CASCADE).
     */
    public boolean eliminar(String codigo) throws SQLException {
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_ELIMINAR)) {
            sentencia.setString(1, codigo);
            return sentencia.executeUpdate() > 0;
        }
    }

    /** Catálogo de sexos para el combobox de Datos Generales. */
    public List<Catalogo> listarGeneros() throws SQLException {
        return listarCatalogo("SELECT PEGEN_CODIGO, PEGEN_DESCRI FROM PEGEN_GENERO ORDER BY PEGEN_DESCRI");
    }

    /** Catálogo de estados civiles para el combobox de Datos Generales. */
    public List<Catalogo> listarEstadosCiviles() throws SQLException {
        return listarCatalogo("SELECT PEESC_CODIGO, PEESC_DESCRI FROM PEESC_ESTCIV ORDER BY PEESC_CODIGO");
    }

    private List<Catalogo> listarCatalogo(String sql) throws SQLException {
        List<Catalogo> catalogo = new ArrayList<>();
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(sql);
             ResultSet resultado = sentencia.executeQuery()) {
            while (resultado.next()) {
                catalogo.add(new Catalogo(resultado.getString(1), resultado.getString(2)));
            }
        }
        return catalogo;
    }

    private List<EmpleadoAcademico> listarAcademicos(Connection conexion, String codigo) throws SQLException {
        List<EmpleadoAcademico> academicos = new ArrayList<>();
        try (PreparedStatement sentencia = conexion.prepareStatement(SQL_LISTAR_ACADEMICOS)) {
            sentencia.setString(1, codigo);
            try (ResultSet resultado = sentencia.executeQuery()) {
                while (resultado.next()) {
                    EmpleadoAcademico academico = new EmpleadoAcademico(
                            resultado.getString("PEACA_NIVEL"),
                            resultado.getString("PEACA_INSTI"),
                            resultado.getString("PEACA_TITUL"));
                    academico.setCodigoAcademico(resultado.getInt("PEACA_CODIGO"));
                    academicos.add(academico);
                }
            }
        }
        return academicos;
    }

    private List<EmpleadoFamiliar> listarFamiliares(Connection conexion, String codigo) throws SQLException {
        List<EmpleadoFamiliar> familiares = new ArrayList<>();
        try (PreparedStatement sentencia = conexion.prepareStatement(SQL_LISTAR_FAMILIARES)) {
            sentencia.setString(1, codigo);
            try (ResultSet resultado = sentencia.executeQuery()) {
                while (resultado.next()) {
                    Date fecha = resultado.getDate("PEFAM_FECNAC");
                    EmpleadoFamiliar familiar = new EmpleadoFamiliar(
                            resultado.getString("PEFAM_PAREN"),
                            resultado.getString("PEFAM_NOMBRE"),
                            fecha == null ? null : fecha.toLocalDate());
                    familiar.setCodigoFamiliar(resultado.getInt("PEFAM_CODIGO"));
                    familiares.add(familiar);
                }
            }
        }
        return familiares;
    }

    private void insertarDetalles(Connection conexion, Empleado empleado) throws SQLException {
        try (PreparedStatement sentencia = conexion.prepareStatement(SQL_INSERTAR_ACADEMICO)) {
            for (EmpleadoAcademico academico : empleado.getAcademicos()) {
                sentencia.setString(1, empleado.getCodigo());
                sentencia.setString(2, academico.getNivel());
                sentencia.setString(3, academico.getInstitucion());
                sentencia.setString(4, academico.getTitulo());
                sentencia.addBatch();
            }
            sentencia.executeBatch();
        }
        try (PreparedStatement sentencia = conexion.prepareStatement(SQL_INSERTAR_FAMILIAR)) {
            for (EmpleadoFamiliar familiar : empleado.getFamiliares()) {
                sentencia.setString(1, empleado.getCodigo());
                sentencia.setString(2, familiar.getPersona());
                sentencia.setString(3, familiar.getNombres());
                sentencia.setDate(4, Date.valueOf(familiar.getFechaNacimiento()));
                sentencia.addBatch();
            }
            sentencia.executeBatch();
        }
    }

    /**
     * Llena los parámetros del INSERT (con el código como primer
     * parámetro) o del UPDATE (con el código al final).
     */
    private void llenarParametrosPersona(PreparedStatement sentencia, Empleado empleado,
                                         boolean esInsercion) throws SQLException {
        int indice = 0;
        if (esInsercion) {
            sentencia.setString(++indice, empleado.getCodigo());
        }
        sentencia.setString(++indice, empleado.getApellidos());
        sentencia.setString(++indice, empleado.getNombres());
        sentencia.setDate(++indice, Date.valueOf(empleado.getFechaNacimiento()));
        asignarOpcional(sentencia, ++indice, vacioANulo(empleado.getCodigoGenero()), Types.CHAR);
        asignarOpcional(sentencia, ++indice, vacioANulo(empleado.getCodigoEstadoCivil()), Types.CHAR);
        if (empleado.getPeso() > 0) {
            sentencia.setBigDecimal(++indice, BigDecimal.valueOf(empleado.getPeso()));
        } else {
            sentencia.setNull(++indice, Types.DECIMAL);
        }
        asignarOpcional(sentencia, ++indice, vacioANulo(empleado.getTipoSangre()), Types.VARCHAR);
        // La tabla compartida de personas exige foto NOT NULL; vacío representa sin foto.
        sentencia.setString(++indice, empleado.getFoto() == null ? "" : empleado.getFoto().trim());
        if (!esInsercion) {
            sentencia.setString(++indice, empleado.getCodigo());
        }
    }

    private static String vacioANulo(String valor) {
        return valor == null || valor.trim().isEmpty() ? null : valor.trim();
    }

    private static void asignarOpcional(PreparedStatement sentencia, int indice,
                                        String valor, int tipo) throws SQLException {
        if (valor == null) {
            sentencia.setNull(indice, tipo);
        } else {
            sentencia.setString(indice, valor);
        }
    }

    private static void revertir(Connection conexion) {
        if (conexion != null) {
            try {
                conexion.rollback();
            } catch (SQLException ignorada) {
                // Ya no hay nada por hacer si el rollback falla.
            }
        }
    }

    private static void cerrar(Connection conexion) {
        if (conexion != null) {
            try {
                conexion.setAutoCommit(true);
                conexion.close();
            } catch (SQLException ignorada) {
                // El pool o el driver terminarán de liberar la conexión.
            }
        }
    }

    private Empleado mapear(ResultSet resultado) throws SQLException {
        Empleado empleado = new Empleado();
        empleado.setCodigo(resultado.getString("PEPER_CODIGO"));
        empleado.setApellidos(resultado.getString("PEPER_APELLI"));
        empleado.setNombres(resultado.getString("PEPER_NOMBRE"));
        Date fecha = resultado.getDate("PEPER_FECNAC");
        empleado.setFechaNacimiento(fecha == null ? null : fecha.toLocalDate());
        empleado.setCodigoGenero(resultado.getString("PEGEN_CODIGO"));
        empleado.setDescriGenero(resultado.getString("PEGEN_DESCRI"));
        empleado.setCodigoEstadoCivil(resultado.getString("PEESC_CODIGO"));
        empleado.setDescriEstadoCivil(resultado.getString("PEESC_DESCRI"));
        BigDecimal peso = resultado.getBigDecimal("PEPER_PESO");
        empleado.setPeso(peso == null ? 0 : peso.doubleValue());
        empleado.setTipoSangre(resultado.getString("PEPER_TIPSANG"));
        empleado.setFoto(resultado.getString("PEPER_FOTO"));
        return empleado;
    }
}
