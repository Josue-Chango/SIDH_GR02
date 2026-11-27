using System.Configuration;
using System.Data.SqlClient;

namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Administra la conexión JDBC hacia SQL Server (LocalDB).
    /// La configuración se lee de la cadena de conexión "SighGrab02" de Web.config.
    /// </summary>
    public static class ConexionBD
    {
        private const string NombreCadena = "SighGrab02";

        /// <summary>Cadena de conexión configurada en Web.config.</summary>
        public static string CadenaConexion
        {
            get
            {
                var cs = ConfigurationManager.ConnectionStrings[NombreCadena];
                return cs != null ? cs.ConnectionString : string.Empty;
            }
        }

        /// <summary>
        /// Abre una conexión nueva hacia SQL Server. La conexión se debe cerrar
        /// con using para que no quede abierta y cause fallas de conexión.
        /// </summary>
        public static SqlConnection Obtener()
        {
            var conexion = new SqlConnection(CadenaConexion);
            conexion.Open();
            return conexion;
        }
    }
}
