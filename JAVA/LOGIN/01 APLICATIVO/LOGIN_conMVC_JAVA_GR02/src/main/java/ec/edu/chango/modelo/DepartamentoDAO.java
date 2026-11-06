package ec.edu.chango.modelo;

import ec.edu.chango.util.ConexionBD;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Acceso a datos del CRUD de DEPARTAMENTO.
 *
 * Implementa las operaciones Create, Read, Update y Delete sobre la tabla
 * PEDEP_DEPAR del diagrama de Personal:
 * listar (Read), buscarPorCodigo (Read), insertar (Create),
 * actualizar (Update) y eliminar (Delete).
 *
 * @author josue
 */
public class DepartamentoDAO {

    private static final String SQL_LISTAR
            = "SELECT PEDEP_CODIGO, PEDEP_DESCRI FROM PEDEP_DEPAR ORDER BY PEDEP_CODIGO";

    private static final String SQL_BUSCAR
            = "SELECT PEDEP_CODIGO, PEDEP_DESCRI FROM PEDEP_DEPAR WHERE PEDEP_CODIGO = ?";

    private static final String SQL_EXISTE
            = "SELECT 1 FROM PEDEP_DEPAR WHERE PEDEP_CODIGO = ?";

    private static final String SQL_INSERTAR
            = "INSERT INTO PEDEP_DEPAR (PEDEP_CODIGO, PEDEP_DESCRI) VALUES (?, ?)";

    private static final String SQL_ACTUALIZAR
            = "UPDATE PEDEP_DEPAR SET PEDEP_CODIGO = ?, PEDEP_DESCRI = ? WHERE PEDEP_CODIGO = ?";

    private static final String SQL_ELIMINAR
            = "DELETE FROM PEDEP_DEPAR WHERE PEDEP_CODIGO = ?";

    /**
     * Lista todos los departamentos ordenados por código.
     *
     * @return lista de departamentos; vacía si no hay registros.
     * @throws SQLException si ocurre un error de base de datos.
     */
    public List<Departamento> listar() throws SQLException {
        List<Departamento> departamentos = new ArrayList<>();
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_LISTAR);
             ResultSet resultado = sentencia.executeQuery()) {
            while (resultado.next()) {
                departamentos.add(mapear(resultado));
            }
        }
        return departamentos;
    }

    /**
     * Busca un departamento por su código (clave primaria).
     *
     * @param codigo código del departamento (PEDEP_CODIGO).
     * @return el departamento encontrado, o null si no existe.
     * @throws SQLException si ocurre un error de base de datos.
     */
    public Departamento buscarPorCodigo(String codigo) throws SQLException {
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_BUSCAR)) {
            sentencia.setString(1, codigo);
            try (ResultSet resultado = sentencia.executeQuery()) {
                return resultado.next() ? mapear(resultado) : null;
            }
        }
    }

    /**
     * Indica si ya existe un departamento con el código indicado.
     *
     * @param codigo código del departamento (PEDEP_CODIGO).
     * @return true si el código ya está registrado.
     * @throws SQLException si ocurre un error de base de datos.
     */
    public boolean existe(String codigo) throws SQLException {
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_EXISTE)) {
            sentencia.setString(1, codigo);
            try (ResultSet resultado = sentencia.executeQuery()) {
                return resultado.next();
            }
        }
    }

    /**
     * Inserta un departamento nuevo.
     *
     * @param departamento departamento con código y descripción.
     * @return true si se insertó el registro.
     * @throws SQLException si ocurre un error de base de datos.
     */
    public boolean insertar(Departamento departamento) throws SQLException {
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_INSERTAR)) {
            sentencia.setString(1, departamento.getCodigoDepart());
            sentencia.setString(2, departamento.getDescriDeparta());
            return sentencia.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza un departamento identificado por su código original.
     *
     * Permite cambiar el código (clave primaria) siempre que no tenga cargos
     * asociados: la llave foránea de PECAR_CARGO lo restringe y en ese caso
     * MySQL lanza una excepción de integridad referencial.
     *
     * @param codigoOriginal código actual del departamento a modificar.
     * @param departamento   datos nuevos (código y descripción).
     * @return true si se actualizó el registro.
     * @throws SQLException si ocurre un error de base de datos.
     */
    public boolean actualizar(String codigoOriginal, Departamento departamento) throws SQLException {
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_ACTUALIZAR)) {
            sentencia.setString(1, departamento.getCodigoDepart());
            sentencia.setString(2, departamento.getDescriDeparta());
            sentencia.setString(3, codigoOriginal);
            return sentencia.executeUpdate() > 0;
        }
    }

    /**
     * Elimina un departamento por su código.
     *
     * @param codigo código del departamento (PEDEP_CODIGO).
     * @return true si se eliminó el registro.
     * @throws SQLException si ocurre un error de base de datos; si el
     *         departamento tiene cargos asociados (PECAR_CARGO) la eliminación
     *         queda restringida por la llave foránea.
     */
    public boolean eliminar(String codigo) throws SQLException {
        try (Connection conexion = ConexionBD.obtener();
             PreparedStatement sentencia = conexion.prepareStatement(SQL_ELIMINAR)) {
            sentencia.setString(1, codigo);
            return sentencia.executeUpdate() > 0;
        }
    }

    private Departamento mapear(ResultSet resultado) throws SQLException {
        Departamento departamento = new Departamento();
        departamento.setCodigoDepart(resultado.getString("PEDEP_CODIGO"));
        departamento.setDescriDeparta(resultado.getString("PEDEP_DESCRI"));
        return departamento;
    }
}
