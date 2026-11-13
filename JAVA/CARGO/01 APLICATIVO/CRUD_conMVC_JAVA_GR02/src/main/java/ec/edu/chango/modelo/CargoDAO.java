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

    private Cargo mapear(ResultSet resultado) throws SQLException {
        Cargo cargo = new Cargo();
        cargo.setCodigoDepart(resultado.getString("PEDEP_CODIGO"));
        cargo.setCodigoCargo(resultado.getString("PECAR_CODIGO"));
        cargo.setDescriCargo(resultado.getString("PECAR_DESCRI"));
        cargo.setDescriDepart(resultado.getString("PEDEP_DESCRI"));
        return cargo;
    }
}
