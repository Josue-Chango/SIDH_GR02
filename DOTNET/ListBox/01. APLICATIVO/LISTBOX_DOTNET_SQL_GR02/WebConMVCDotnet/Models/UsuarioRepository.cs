using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Acceso a datos del módulo de Seguridad contra SQL Server.
    /// Réplica de UsuarioDAO del proyecto Java: el inicio de sesión se hace
    /// por PEPER_CODIGO (código de la persona) y XEUSU_PASWD.
    /// Tablas: XEUSU_USUAR (USUARIO), PEPER_PERSO (PERSONA),
    /// XEEST_ESTAD (ESTADO), XEUXP_USUPE (USUPER) y XEPER_PERFI (PERFIL).
    /// </summary>
    public class UsuarioRepository
    {
        private const string SqlAutenticar =
            "SELECT TOP 1 u.XEUSU_PASWD, u.XEEST_CODIGO, u.PEPER_CODIGO, " +
            "       u.XEUSU_FECCRE, u.XEUSU_FECMOD, u.XEUSU_PIEFIR, " +
            "       p.PEPER_APELLI, p.PEPER_NOMBRE, p.PEPER_FECNAC, " +
            "       p.PEPER_CEDULA, p.PEPER_PASAPO, p.PEPER_EMAIL, " +
            "       p.PEPER_CARFAM, p.PEPER_FOTO, p.PEPER_DISC, " +
            "       e.XEEST_DESCRI " +
            "FROM XEUSU_USUAR u " +
            "INNER JOIN PEPER_PERSO p ON p.PEPER_CODIGO = u.PEPER_CODIGO " +
            "LEFT JOIN XEEST_ESTAD e ON e.XEEST_CODIGO = u.XEEST_CODIGO " +
            "WHERE u.PEPER_CODIGO = @ident " +
            "  AND u.XEUSU_PASWD = @pass " +
            "ORDER BY u.XEUSU_PASWD";

        private const string SqlPerfiles =
            "SELECT pf.XEPER_CODIGO, pf.XEPER_DESCRI, pf.XEPER_OBSER " +
            "FROM XEUXP_USUPE up " +
            "INNER JOIN XEPER_PERFI pf ON pf.XEPER_CODIGO = up.XEPER_CODIGO " +
            "WHERE up.XEUSU_PASWD = @pass " +
            "  AND (up.XEUXP_FECRET IS NULL OR up.XEUXP_FECRET >= CAST(GETDATE() AS DATE)) " +
            "ORDER BY pf.XEPER_DESCRI";

        public Usuario Autenticar(string identificacion, string password)
        {
            string identificacionLimpia = identificacion == null ? "" : identificacion.Trim();
            if (identificacionLimpia.Length == 0 || string.IsNullOrEmpty(password))
            {
                return null;
            }

            using (SqlConnection conexion = ConexionBD.Obtener())
            {
                Usuario usuario = BuscarUsuario(conexion, identificacionLimpia, password);
                if (usuario != null)
                {
                    usuario.Perfiles = ListarPerfiles(conexion, password);
                }
                return usuario;
            }
        }

        private Usuario BuscarUsuario(SqlConnection conexion, string identificacion, string password)
        {
            using (var comando = new SqlCommand(SqlAutenticar, conexion))
            {
                comando.CommandType = CommandType.Text;
                comando.Parameters.Add("@ident", SqlDbType.VarChar, 50).Value = identificacion;
                comando.Parameters.Add("@pass", SqlDbType.VarChar, 16).Value = password;

                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    if (!lector.Read())
                    {
                        return null;
                    }
                    return MapearUsuario(lector);
                }
            }
        }

        private Usuario MapearUsuario(SqlDataReader lector)
        {
            object valorFecNac = lector["PEPER_FECNAC"];
            DateTime? fecNacimiento = valorFecNac == DBNull.Value
                ? (DateTime?)null
                : Convert.ToDateTime(valorFecNac);

            object valorCrea = lector["XEUSU_FECCRE"];
            DateTime? fechaCrea = valorCrea == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(valorCrea);

            object valorModi = lector["XEUSU_FECMOD"];
            DateTime? fechaModi = valorModi == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(valorModi);

            double cargas = Convert.ToDouble(lector["PEPER_CARFAM"]);

            Persona persona = new Persona
            {
                CodigoPersona = Leer(lector, "PEPER_CODIGO"),
                ApellidosPersona = Leer(lector, "PEPER_APELLI"),
                NombresPersona = Leer(lector, "PEPER_NOMBRE"),
                FecNacimiento = fecNacimiento,
                Cedula = Leer(lector, "PEPER_CEDULA"),
                Pasaporte = Leer(lector, "PEPER_PASAPO"),
                Email = Leer(lector, "PEPER_EMAIL"),
                Foto = Leer(lector, "PEPER_FOTO"),
                Discapacidad = Leer(lector, "PEPER_DISC"),
                CargasFam = cargas
            };

            Usuario usuario = new Usuario
            {
                Password = Leer(lector, "XEUSU_PASWD"),
                CodEstado = Leer(lector, "XEEST_CODIGO"),
                DescEstado = Leer(lector, "XEEST_DESCRI"),
                FechaCrea = fechaCrea,
                FechaModi = fechaModi,
                Piefirma = Leer(lector, "XEUSU_PIEFIR"),
                Persona = persona
            };
            return usuario;
        }

        private List<Perfil> ListarPerfiles(SqlConnection conexion, string password)
        {
            var perfiles = new List<Perfil>();
            using (var comando = new SqlCommand(SqlPerfiles, conexion))
            {
                comando.CommandType = CommandType.Text;
                comando.Parameters.Add("@pass", SqlDbType.VarChar, 16).Value = password;

                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    while (lector.Read())
                    {
                        perfiles.Add(new Perfil
                        {
                            CodPerfil = Leer(lector, "XEPER_CODIGO"),
                            DescPerfil = Leer(lector, "XEPER_DESCRI"),
                            ObservacionesPerfil = Leer(lector, "XEPER_OBSER")
                        });
                    }
                }
            }
            return perfiles;
        }

        private static string Leer(SqlDataReader lector, string columna)
        {
            object valor = lector[columna];
            return valor == DBNull.Value ? null : Convert.ToString(valor);
        }
    }
}
