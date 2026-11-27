using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Acceso a datos de la tabla CARGO (PECAR_CARGO del diagrama de Personal)
    /// sobre SQL Server.
    ///
    /// Lista los cargos junto con la descripción del departamento al que
    /// pertenecen (JOIN con PEDEP_DEPAR) e implementa el CRUD por clave
    /// compuesta (PEDEP_CODIGO, PECAR_CODIGO).
    /// Equivalente a la clase CargoDAO del proyecto Java.
    /// </summary>
    public class CargoRepository
    {
        private const string SqlListarBase =
            "SELECT c.PEDEP_CODIGO, c.PECAR_CODIGO, c.PECAR_DESCRI, d.PEDEP_DESCRI " +
            "FROM PECAR_CARGO c " +
            "LEFT JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = c.PEDEP_CODIGO ";

        private const string SqlListar =
            SqlListarBase + "ORDER BY c.PEDEP_CODIGO, c.PECAR_CODIGO";

        private const string SqlListarPorDepartamento =
            SqlListarBase + "WHERE c.PEDEP_CODIGO = @departamento " +
            "ORDER BY c.PEDEP_CODIGO, c.PECAR_CODIGO";

        /// <summary>Lista todos los cargos con la descripción de su departamento.</summary>
        public List<Cargo> Listar()
        {
            var cargos = new List<Cargo>();
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(SqlListar, conexion))
            using (SqlDataReader lector = comando.ExecuteReader())
            {
                while (lector.Read())
                {
                    cargos.Add(Mapear(lector));
                }
            }
            return cargos;
        }

        /// <summary>Lista los cargos de un departamento indicado, ordenados por código.</summary>
        public List<Cargo> ListarPorDepartamento(string codigoDepart)
        {
            var cargos = new List<Cargo>();
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(SqlListarPorDepartamento, conexion))
            {
                comando.Parameters.Add("@departamento", SqlDbType.Char, 3).Value = codigoDepart;
                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    while (lector.Read())
                    {
                        cargos.Add(Mapear(lector));
                    }
                }
            }
            return cargos;
        }

        /// <summary>Busca por la clave primaria completa (departamento, cargo).</summary>
        public Cargo BuscarPorCodigo(string departamento, string codigo)
        {
            string sql = SqlListarBase + "WHERE c.PEDEP_CODIGO = @departamento AND c.PECAR_CODIGO = @codigo";
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sql, conexion))
            {
                comando.Parameters.Add("@departamento", SqlDbType.Char, 3).Value = departamento;
                comando.Parameters.Add("@codigo", SqlDbType.Char, 3).Value = codigo;
                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    if (!lector.Read())
                    {
                        return null;
                    }
                    return Mapear(lector);
                }
            }
        }

        public bool Existe(string departamento, string codigo)
        {
            return BuscarPorCodigo(departamento, codigo) != null;
        }

        public bool Insertar(Cargo cargo)
        {
            const string sql = "INSERT INTO PECAR_CARGO (PEDEP_CODIGO, PECAR_CODIGO, PECAR_DESCRI) " +
                               "VALUES (@departamento, @codigo, @descri)";
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sql, conexion))
            {
                comando.Parameters.Add("@departamento", SqlDbType.Char, 3).Value = cargo.CodigoDepart;
                comando.Parameters.Add("@codigo", SqlDbType.Char, 3).Value = cargo.CodigoCargo;
                comando.Parameters.Add("@descri", SqlDbType.VarChar, 50).Value = cargo.DescriCargo;
                return comando.ExecuteNonQuery() > 0;
            }
        }

        /// <summary>La clave se conserva; editar cambia únicamente la descripción.</summary>
        public bool Actualizar(Cargo cargo)
        {
            const string sql = "UPDATE PECAR_CARGO SET PECAR_DESCRI = @descri " +
                               "WHERE PEDEP_CODIGO = @departamento AND PECAR_CODIGO = @codigo";
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sql, conexion))
            {
                comando.Parameters.Add("@descri", SqlDbType.VarChar, 50).Value = cargo.DescriCargo;
                comando.Parameters.Add("@departamento", SqlDbType.Char, 3).Value = cargo.CodigoDepart;
                comando.Parameters.Add("@codigo", SqlDbType.Char, 3).Value = cargo.CodigoCargo;
                return comando.ExecuteNonQuery() > 0;
            }
        }

        /// <summary>No realiza borrados en cascada: respeta las relaciones del esquema.</summary>
        public bool Eliminar(string departamento, string codigo)
        {
            const string sql = "DELETE FROM PECAR_CARGO " +
                               "WHERE PEDEP_CODIGO = @departamento AND PECAR_CODIGO = @codigo";
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sql, conexion))
            {
                comando.Parameters.Add("@departamento", SqlDbType.Char, 3).Value = departamento;
                comando.Parameters.Add("@codigo", SqlDbType.Char, 3).Value = codigo;
                return comando.ExecuteNonQuery() > 0;
            }
        }

        private static Cargo Mapear(SqlDataReader lector)
        {
            return new Cargo(
                lector["PEDEP_CODIGO"].ToString(),
                lector["PECAR_CODIGO"].ToString(),
                lector["PECAR_DESCRI"].ToString())
            {
                DescriDepart = lector["PEDEP_DESCRI"].ToString()
            };
        }
    }
}
