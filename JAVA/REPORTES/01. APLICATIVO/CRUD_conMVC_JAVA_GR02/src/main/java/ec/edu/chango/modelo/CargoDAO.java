package ec.edu.chango.modelo;

import ec.edu.chango.util.ConexionBD;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Acceso a datos de la tabla CARGO (PECAR_CARGO del diagrama de Personal).
 *
 * Para el apartado de consulta se listan todos los cargos junto con la
 * descripción del departamento al que pertenecen (JOIN con PEDEP_DEPAR),
 * de modo que el combobox de la vista pueda mostrar esa relación.
 *
 * @author josue
 */
public class CargoDAO {

    /**
     * Lista los cargos con la descripción de su departamento, ordenados por
     * departamento y por código de cargo.
     */
    private static final String SQL_LISTAR_BASE
            = "SELECT c.PEDEP_CODIGO, c.PECAR_CODIGO, c.PECAR_DESCRI, d.PEDEP_DESCRI "
            + "FROM PECAR_CARGO c "
            + "LEFT JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = c.PEDEP_CODIGO ";

    private static final String SQL_LISTAR
            = SQL_LISTAR_BASE + "ORDER BY c.PEDEP_CODIGO, c.PECAR_CODIGO";

    private static final String SQL_LISTAR_POR_DEPARTAMENTO
            = SQL_LISTAR_BASE + "WHERE c.PEDEP_CODIGO = ? "
            + "ORDER BY c.PEDEP_CODIGO, c.PECAR_CODIGO";

    /**
     * Lista todos los cargos de la tabla PECAR_CARGO con la descripción del
     * departamento al que pertenecen.
     *
     * @return lista de cargos; vacía si no hay registros.
     * @throws SQLException si ocurre un error de base de datos.
     */
    public List<Cargo> listar() throws SQLException {
        List<Cargo> cargos = new ArrayList<>();
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_LISTAR);
             ResultSet resultado = sentencia.executeQuery()) {
            while (resultado.next()) {
                cargos.add(mapear(resultado));
            }
        }
        return cargos;
    }

    /**
     * Lista los cargos de un departamento indicado, ordenados por código.
     *
     * @param codigoDepart código del departamento (PEDEP_CODIGO).
     * @return lista de cargos; vacía si el departamento no tiene cargos.
     * @throws SQLException si ocurre un error de base de datos.
     */
    public List<Cargo> listarPorDepartamento(String codigoDepart) throws SQLException {
        List<Cargo> cargos = new ArrayList<>();
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_LISTAR_POR_DEPARTAMENTO)) {
            sentencia.setString(1, codigoDepart);
            try (ResultSet resultado = sentencia.executeQuery()) {
                while (resultado.next()) {
                    cargos.add(mapear(resultado));
                }
            }
        }
        return cargos;
    }

    /** Busca por la clave primaria completa (departamento, cargo). */
    public Cargo buscarPorCodigo(String departamento, String codigo) throws SQLException {
        String sql = SQL_LISTAR_BASE + "WHERE c.PEDEP_CODIGO = ? AND c.PECAR_CODIGO = ?";
        try (Connection con = ConexionBD.obtener(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, departamento);
            ps.setString(2, codigo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapear(rs) : null;
            }
        }
    }

    public boolean existe(String departamento, String codigo) throws SQLException {
        return buscarPorCodigo(departamento, codigo) != null;
    }

    public boolean insertar(Cargo cargo) throws SQLException {
        String sql = "INSERT INTO PECAR_CARGO (PEDEP_CODIGO, PECAR_CODIGO, PECAR_DESCRI) VALUES (?, ?, ?)";
        try (Connection con = ConexionBD.obtener(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, cargo.getCodigoDepart());
            ps.setString(2, cargo.getCodigoCargo());
            ps.setString(3, cargo.getDescriCargo());
            return ps.executeUpdate() > 0;
        }
    }

    /** La clave se conserva; editar cambia únicamente la descripción. */
    public boolean actualizar(Cargo cargo) throws SQLException {
        String sql = "UPDATE PECAR_CARGO SET PECAR_DESCRI = ? WHERE PEDEP_CODIGO = ? AND PECAR_CODIGO = ?";
        try (Connection con = ConexionBD.obtener(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, cargo.getDescriCargo());
            ps.setString(2, cargo.getCodigoDepart());
            ps.setString(3, cargo.getCodigoCargo());
            return ps.executeUpdate() > 0;
        }
    }

    /** No realiza borrados en cascada: respeta las relaciones del esquema. */
    public boolean eliminar(String departamento, String codigo) throws SQLException {
        String sql = "DELETE FROM PECAR_CARGO WHERE PEDEP_CODIGO = ? AND PECAR_CODIGO = ?";
        try (Connection con = ConexionBD.obtener(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, departamento);
            ps.setString(2, codigo);
            return ps.executeUpdate() > 0;
        }
    }

    private Cargo mapear(ResultSet resultado) throws SQLException {
        Cargo cargo = new Cargo();
        cargo.setCodigoDepart(resultado.getString("PEDEP_CODIGO"));
        cargo.setCodigoCargo(resultado.getString("PECAR_CODIGO"));
        cargo.setDescriCargo(resultado.getString("PECAR_DESCRI"));
        cargo.setDescriDepart(resultado.getString("PEDEP_DESCRI"));
        return cargo;
    }
}
