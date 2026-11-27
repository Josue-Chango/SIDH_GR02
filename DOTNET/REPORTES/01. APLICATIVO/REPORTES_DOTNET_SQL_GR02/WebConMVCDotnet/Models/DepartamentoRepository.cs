using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Acceso a datos del CRUD de DEPARTAMENTO (tabla PEDEP_DEPAR) sobre SQL Server.
    /// Implementa Listar (Read), Existe, Insertar (Create),
    /// Actualizar (Update) y Eliminar (Delete).
    /// </summary>
    public class DepartamentoRepository
    {
        private const string SqlListar =
            "SELECT PEDEP_CODIGO, PEDEP_DESCRI FROM PEDEP_DEPAR ORDER BY PEDEP_CODIGO";

        private const string SqlBuscar =
            "SELECT PEDEP_CODIGO, PEDEP_DESCRI FROM PEDEP_DEPAR WHERE PEDEP_CODIGO = @codigo";

        private const string SqlExiste =
            "SELECT 1 FROM PEDEP_DEPAR WHERE PEDEP_CODIGO = @codigo";

        private const string SqlInsertar =
            "INSERT INTO PEDEP_DEPAR (PEDEP_CODIGO, PEDEP_DESCRI) VALUES (@codigo, @descri)";

        private const string SqlActualizar =
            "UPDATE PEDEP_DEPAR SET PEDEP_CODIGO = @nuevo, PEDEP_DESCRI = @descri WHERE PEDEP_CODIGO = @original";

        private const string SqlEliminar =
            "DELETE FROM PEDEP_DEPAR WHERE PEDEP_CODIGO = @codigo";

        public List<Departamento> Listar()
        {
            var departamentos = new List<Departamento>();
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(SqlListar, conexion))
            using (SqlDataReader lector = comando.ExecuteReader())
            {
                while (lector.Read())
                {
                    departamentos.Add(new Departamento(
                        lector["PEDEP_CODIGO"].ToString(),
                        lector["PEDEP_DESCRI"].ToString()));
                }
            }
            return departamentos;
        }

        public Departamento BuscarPorCodigo(string codigo)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(SqlBuscar, conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 3).Value = codigo;
                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    if (!lector.Read())
                    {
                        return null;
                    }
                    return new Departamento(
                        lector["PEDEP_CODIGO"].ToString(),
                        lector["PEDEP_DESCRI"].ToString());
                }
            }
        }

        public bool Existe(string codigo)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(SqlExiste, conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 3).Value = codigo;
                return comando.ExecuteScalar() != null;
            }
        }

        public bool Insertar(Departamento departamento)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(SqlInsertar, conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 3).Value = departamento.CodigoDepart;
                comando.Parameters.Add("@descri", SqlDbType.VarChar, 50).Value = departamento.DescriDeparta;
                return comando.ExecuteNonQuery() > 0;
            }
        }

        public bool Actualizar(string codigoOriginal, Departamento departamento)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(SqlActualizar, conexion))
            {
                comando.Parameters.Add("@nuevo", SqlDbType.Char, 3).Value = departamento.CodigoDepart;
                comando.Parameters.Add("@descri", SqlDbType.VarChar, 50).Value = departamento.DescriDeparta;
                comando.Parameters.Add("@original", SqlDbType.Char, 3).Value = codigoOriginal;
                return comando.ExecuteNonQuery() > 0;
            }
        }

        public bool Eliminar(string codigo)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(SqlEliminar, conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 3).Value = codigo;
                return comando.ExecuteNonQuery() > 0;
            }
        }
    }
}
