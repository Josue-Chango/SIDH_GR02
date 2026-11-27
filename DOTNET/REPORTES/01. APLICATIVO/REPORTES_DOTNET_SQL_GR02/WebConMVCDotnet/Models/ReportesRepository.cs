using System;
using System.Data;
using System.Data.SqlClient;

namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Consultas de solo lectura que alimentan los reportes.
    /// Réplica del ReportesDAO del proyecto Java (consultas SQL de las
    /// plantillas .jrxml): cada método devuelve un DataSet que la vista
    /// del reporte recorre para armar la salida imprimible (PDF).
    /// Tablas usadas: PEDEP_DEPAR, PECAR_CARGO, PEPER_PERSO,
    /// PEACA_ACADE, PEFAM_FAMIL, PEGEN_GENERO y PEESC_ESTCIV.
    /// </summary>
    public class ReportesRepository
    {
        /// <summary>Todos los departamentos con su código y descripción.</summary>
        public DataSet Departamentos()
        {
            var tabla = new DataTable("Departamentos");
            tabla.Columns.Add("PEDEP_CODIGO", typeof(string));
            tabla.Columns.Add("PEDEP_DESCRI", typeof(string));

            const string sql =
                "SELECT PEDEP_CODIGO, PEDEP_DESCRI FROM PEDEP_DEPAR ORDER BY PEDEP_CODIGO";
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sql, conexion))
            using (SqlDataReader lector = comando.ExecuteReader())
            {
                while (lector.Read())
                {
                    tabla.Rows.Add(lector.GetString(0), lector.GetString(1));
                }
            }

            var conjunto = new DataSet("datos");
            conjunto.Tables.Add(tabla);
            return conjunto;
        }

        /// <summary>
        /// Cargos con la descripción de su departamento. departamento vacío
        /// devuelve todos; un código de tres caracteres filtra (igual que el
        /// reporte de cargos del proyecto Java).
        /// </summary>
        public DataSet Cargos(string departamento)
        {
            var tabla = new DataTable("Cargos");
            tabla.Columns.Add("PEDEP_CODIGO", typeof(string));
            tabla.Columns.Add("PEDEP_DESCRI", typeof(string));
            tabla.Columns.Add("PECAR_CODIGO", typeof(string));
            tabla.Columns.Add("PECAR_DESCRI", typeof(string));

            var sql =
                "SELECT c.PEDEP_CODIGO, d.PEDEP_DESCRI, c.PECAR_CODIGO, c.PECAR_DESCRI " +
                "FROM PECAR_CARGO c JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = c.PEDEP_CODIGO ";
            if (departamento.Length > 0)
            {
                sql += "WHERE c.PEDEP_CODIGO = @departamento ";
            }
            sql += "ORDER BY c.PEDEP_CODIGO, c.PECAR_CODIGO";

            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sql, conexion))
            {
                if (departamento.Length > 0)
                {
                    comando.Parameters.Add("@departamento", SqlDbType.Char, 3).Value = departamento;
                }
                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    while (lector.Read())
                    {
                        tabla.Rows.Add(
                            lector.GetString(0),
                            lector.GetString(1),
                            lector.GetString(2),
                            lector.GetString(3));
                    }
                }
            }

            var conjunto = new DataSet("datos");
            conjunto.Tables.Add(tabla);
            return conjunto;
        }

        /// <summary>Empleados con las descripciones de sexo y estado civil.</summary>
        public DataSet Empleados()
        {
            var tabla = new DataTable("Empleados");
            tabla.Columns.Add("PEPER_CODIGO", typeof(string));
            tabla.Columns.Add("PEPER_APELLI", typeof(string));
            tabla.Columns.Add("PEPER_NOMBRE", typeof(string));
            tabla.Columns.Add("FECNAC", typeof(string));
            tabla.Columns.Add("PEGEN_DESCRI", typeof(string));
            tabla.Columns.Add("PEESC_DESCRI", typeof(string));

            const string sql =
                "SELECT p.PEPER_CODIGO, p.PEPER_APELLI, p.PEPER_NOMBRE, p.PEPER_FECNAC, " +
                "g.PEGEN_DESCRI, e.PEESC_DESCRI " +
                "FROM PEPER_PERSO p " +
                "LEFT JOIN PEGEN_GENERO g ON g.PEGEN_CODIGO = p.PEGEN_CODIGO " +
                "LEFT JOIN PEESC_ESTCIV e ON e.PEESC_CODIGO = p.PEESC_CODIGO " +
                "ORDER BY p.PEPER_APELLI, p.PEPER_NOMBRE, p.PEPER_CODIGO";

            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sql, conexion))
            using (SqlDataReader lector = comando.ExecuteReader())
            {
                while (lector.Read())
                {
                    tabla.Rows.Add(
                        lector.GetString(0),
                        lector.GetString(1),
                        lector.GetString(2),
                        Fecha(lector, 3),
                        Descri(lector, 4),
                        Descri(lector, 5));
                }
            }

            var conjunto = new DataSet("datos");
            conjunto.Tables.Add(tabla);
            return conjunto;
        }

        /// <summary>
        /// Ficha completa de un empleado: sus datos principales y sus
        /// subtablas de Datos Académicos y Datos Familiares.
        /// </summary>
        public DataSet Ficha(string codigo)
        {
            var conjunto = new DataSet("datos");

            var tabla = new DataTable("Empleados");
            tabla.Columns.Add("PEPER_CODIGO", typeof(string));
            tabla.Columns.Add("PEPER_APELLI", typeof(string));
            tabla.Columns.Add("PEPER_NOMBRE", typeof(string));
            tabla.Columns.Add("FECNAC", typeof(string));
            tabla.Columns.Add("PEGEN_DESCRI", typeof(string));
            tabla.Columns.Add("PEESC_DESCRI", typeof(string));
            tabla.Columns.Add("PESO", typeof(string));
            tabla.Columns.Add("PEPER_TIPSANG", typeof(string));
            tabla.Columns.Add("PEPER_FOTO", typeof(string));

            const string sql =
                "SELECT p.PEPER_CODIGO, p.PEPER_APELLI, p.PEPER_NOMBRE, p.PEPER_FECNAC, " +
                "g.PEGEN_DESCRI, e.PEESC_DESCRI, p.PEPER_PESO, p.PEPER_TIPSANG, p.PEPER_FOTO " +
                "FROM PEPER_PERSO p " +
                "LEFT JOIN PEGEN_GENERO g ON g.PEGEN_CODIGO = p.PEGEN_CODIGO " +
                "LEFT JOIN PEESC_ESTCIV e ON e.PEESC_CODIGO = p.PEESC_CODIGO " +
                "WHERE p.PEPER_CODIGO = @codigo";

            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sql, conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = codigo;
                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    if (!lector.Read())
                    {
                        throw new InvalidOperationException("El empleado no existe.");
                    }
                    tabla.Rows.Add(
                        lector.GetString(0),
                        lector.GetString(1),
                        lector.GetString(2),
                        Fecha(lector, 3),
                        Descri(lector, 4),
                        Descri(lector, 5),
                        Peso(lector, 6),
                        Descri(lector, 7),
                        lector.IsDBNull(8) ? "" : lector.GetString(8));
                }
            }
            conjunto.Tables.Add(tabla);

            var academicos = new DataTable("Academicos");
            academicos.Columns.Add("PEACA_NIVEL", typeof(string));
            academicos.Columns.Add("PEACA_INSTI", typeof(string));
            academicos.Columns.Add("PEACA_TITUL", typeof(string));
            const string sqlAca =
                "SELECT PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL " +
                "FROM PEACA_ACADE WHERE PEPER_CODIGO = @codigo ORDER BY PEACA_CODIGO";
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sqlAca, conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = codigo;
                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    while (lector.Read())
                    {
                        academicos.Rows.Add(lector.GetString(0), lector.GetString(1), lector.GetString(2));
                    }
                }
            }
            conjunto.Tables.Add(academicos);

            var familiares = new DataTable("Familiares");
            familiares.Columns.Add("PAREN", typeof(string));
            familiares.Columns.Add("PEFAM_NOMBRE", typeof(string));
            familiares.Columns.Add("FECNAC", typeof(string));
            const string sqlFam =
                "SELECT PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC " +
                "FROM PEFAM_FAMIL WHERE PEPER_CODIGO = @codigo ORDER BY PEFAM_CODIGO";
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sqlFam, conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = codigo;
                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    while (lector.Read())
                    {
                        familiares.Rows.Add(
                            Parentesco(lector.GetString(0)),
                            lector.GetString(1),
                            Fecha(lector, 2));
                    }
                }
            }
            conjunto.Tables.Add(familiares);

            return conjunto;
        }

        // ------------------------------------------------------------------
        // Utilidades de formato
        // ------------------------------------------------------------------

        /// <summary>Fecha como dd/MM/yyyy; cadena vacía si el dato es nulo.</summary>
        private static string Fecha(SqlDataReader lector, int indice)
        {
            return lector.IsDBNull(indice) ? "" : lector.GetDateTime(indice).ToString("dd/MM/yyyy");
        }

        /// <summary>Descripción de catálogo o cadena vacía si el dato es nulo.</summary>
        private static string Descri(SqlDataReader lector, int indice)
        {
            return lector.IsDBNull(indice) ? "" : lector.GetString(indice);
        }

        /// <summary>Peso con hasta dos decimales; cadena vacía si no hay dato.</summary>
        private static string Peso(SqlDataReader lector, int indice)
        {
            if (lector.IsDBNull(indice))
            {
                return "";
            }
            return lector.GetDecimal(indice).ToString("0.##",
                System.Globalization.CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// Traduce el código de parentesco al texto legible (igual que la
        /// vista del mantenimiento de empleados del proyecto Java).
        /// </summary>
        private static string Parentesco(string codigo)
        {
            switch (codigo)
            {
                case "PADRE": return "Padre";
                case "MADRE": return "Madre";
                case "CONYUGE": return "Cónyuge";
                case "HIJO/A": return "Hijo/a";
                case "HERMANO/A": return "Hermano/a";
                case "OTRO": return "Otro";
                default: return codigo;
            }
        }
    }
}
