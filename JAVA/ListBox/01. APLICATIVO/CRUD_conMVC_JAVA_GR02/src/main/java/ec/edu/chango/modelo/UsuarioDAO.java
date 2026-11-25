package ec.edu.chango.modelo;

import ec.edu.chango.util.ConexionBD;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Acceso a datos del módulo de Seguridad.
 *
 * Implementa el inicio de sesión contra las tablas del diagrama:
 * XEUSU_USUAR (USUARIO), PEPER_PERSO (PERSONA), XEEST_ESTAD (ESTADO),
 * XEUXP_USUPE (USUPER) y XEPER_PERFI (PERFIL).
 *
 * @author josue
 */
public class UsuarioDAO {

    private static final String SQL_AUTENTICAR
            = "SELECT u.XEUSU_PASWD, u.XEEST_CODIGO, u.PEPER_CODIGO, "
            + "       u.XEUSU_FECCRE, u.XEUSU_FECMOD, u.XEUSU_PIEFIR, "
            + "       p.PEPER_APELLI, p.PEPER_NOMBRE, p.PEPER_FECNAC, "
            + "       p.PEPER_CEDULA, p.PEPER_PASAPO, p.PEPER_EMAIL, "
            + "       p.PEPER_CARFAM, p.PEPER_FOTO, p.PEPER_DISC, "
            + "       e.XEEST_DESCRI "
            + "FROM XEUSU_USUAR u "
            + "INNER JOIN PEPER_PERSO p ON p.PEPER_CODIGO = u.PEPER_CODIGO "
            + "LEFT JOIN XEEST_ESTAD e ON e.XEEST_CODIGO = u.XEEST_CODIGO "
            + "WHERE u.PEPER_CODIGO = ? "
            + "  AND u.XEUSU_PASWD = ? "
            + "LIMIT 1";

    private static final String SQL_PERFILES
            = "SELECT pf.XEPER_CODIGO, pf.XEPER_DESCRI, pf.XEPER_OBSER "
            + "FROM XEUXP_USUPE up "
            + "INNER JOIN XEPER_PERFI pf ON pf.XEPER_CODIGO = up.XEPER_CODIGO "
            + "WHERE up.XEUSU_PASWD = ? "
            + "  AND (up.XEUXP_FECRET IS NULL OR up.XEUXP_FECRET >= CURDATE()) "
            + "ORDER BY pf.XEPER_DESCRI";

    /**
     * Autentica un usuario por su identificador (PEPER_CODIGO) y contraseña.
     *
     * @param usuario  código del usuario (campo PEPER_CODIGO).
     * @param password contraseña almacenada en XEUSU_USUAR.
     * @return el usuario autenticado con su persona y perfiles, o null si las
     *         credenciales no coinciden.
     * @throws SQLException si ocurre un error de base de datos.
     */
    public Usuario autenticar(String usuario, String password) throws SQLException {
        String usuarioLimpio = usuario != null ? usuario.trim() : "";
        if (usuarioLimpio.isEmpty() || password == null || password.isEmpty()) {
            return null;
        }

        try (Connection conexion = ConexionBD.obtener()) {
            Usuario usuarioEncontrado = buscarUsuario(conexion, usuarioLimpio, password);
            if (usuarioEncontrado != null) {
                usuarioEncontrado.setPerfiles(listarPerfiles(conexion, password));
            }
            return usuarioEncontrado;
        }
    }

    private Usuario buscarUsuario(Connection conexion, String usuario, String password)
            throws SQLException {
        try (PreparedStatement sentencia = conexion.prepareStatement(SQL_AUTENTICAR)) {
            sentencia.setString(1, usuario);
            sentencia.setString(2, password);

            try (ResultSet rs = sentencia.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return mapearUsuario(rs);
            }
        }
    }

    private Usuario mapearUsuario(ResultSet rs) throws SQLException {
        Persona persona = new Persona();
        persona.setCodigoPersona(rs.getString("PEPER_CODIGO"));
        persona.setApellidosPersona(rs.getString("PEPER_APELLI"));
        persona.setNombresPersona(rs.getString("PEPER_NOMBRE"));
        persona.setFecNacimiento(rs.getDate("PEPER_FECNAC"));
        persona.setCedula(rs.getString("PEPER_CEDULA"));
        persona.setPasaporte(rs.getString("PEPER_PASAPO"));
        persona.setEmail(rs.getString("PEPER_EMAIL"));
        persona.setCargasFam(rs.getDouble("PEPER_CARFAM"));
        persona.setFoto(rs.getString("PEPER_FOTO"));
        persona.setDiscapacidad(rs.getString("PEPER_DISC"));

        Usuario usuario = new Usuario();
        usuario.setPassword(rs.getString("XEUSU_PASWD"));
        usuario.setCodEstado(rs.getString("XEEST_CODIGO"));
        usuario.setDescEstado(rs.getString("XEEST_DESCRI"));
        usuario.setFechaCrea(rs.getTimestamp("XEUSU_FECCRE"));
        usuario.setFechaModi(rs.getTimestamp("XEUSU_FECMOD"));
        usuario.setPiefirma(rs.getString("XEUSU_PIEFIR"));
        usuario.setPersona(persona);
        return usuario;
    }

    private List<Perfil> listarPerfiles(Connection conexion, String password) throws SQLException {
        List<Perfil> perfiles = new ArrayList<>();
        try (PreparedStatement sentencia = conexion.prepareStatement(SQL_PERFILES)) {
            sentencia.setString(1, password);
            try (ResultSet rs = sentencia.executeQuery()) {
                while (rs.next()) {
                    Perfil perfil = new Perfil();
                    perfil.setCodPerfil(rs.getString("XEPER_CODIGO"));
                    perfil.setDescPerfil(rs.getString("XEPER_DESCRI"));
                    perfil.setObservacionesPerfil(rs.getString("XEPER_OBSER"));
                    perfiles.add(perfil);
                }
            }
        }
        return perfiles;
    }
}
