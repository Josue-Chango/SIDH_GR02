using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Acceso a datos del Mantenimiento de Empleados con Tab Page.
    /// Administra la tabla PEPER_PERSO junto con sus dos subtablas:
    /// PEACA_ACADE (Datos Académicos) y PEFAM_FAMIL (Datos Familiares).
    /// Los inserts y updates se realizan dentro de una transacción para
    /// que la persona y sus subtablas se guarden completas o nada.
    /// Réplica del EmpleadoDAO del proyecto Java (MySQL → SQL Server).
    /// </summary>
    public class EmpleadoRepository
    {
        private const string SqlListarBase =
            "SELECT p.PEPER_CODIGO, p.PEPER_APELLI, p.PEPER_NOMBRE, p.PEPER_FECNAC, " +
            "p.PEGEN_CODIGO, g.PEGEN_DESCRI, p.PEESC_CODIGO, e.PEESC_DESCRI, " +
            "p.PEPER_PESO, p.PEPER_TIPSANG, p.PEPER_FOTO " +
            "FROM PEPER_PERSO p " +
            "LEFT JOIN PEGEN_GENERO g ON g.PEGEN_CODIGO = p.PEGEN_CODIGO " +
            "LEFT JOIN PEESC_ESTCIV e ON e.PEESC_CODIGO = p.PEESC_CODIGO ";

        private const string SqlListar =
            SqlListarBase + "ORDER BY p.PEPER_APELLI, p.PEPER_NOMBRE";

        private const string SqlBuscar =
            SqlListarBase + "WHERE p.PEPER_CODIGO = @codigo";

        private const string SqlInsertar =
            "INSERT INTO PEPER_PERSO (PEPER_CODIGO, PEPER_APELLI, PEPER_NOMBRE, " +
            "PEPER_FECNAC, PEGEN_CODIGO, PEESC_CODIGO, PEPER_PESO, PEPER_TIPSANG, PEPER_FOTO, " +
            "PEPER_CARFAM, PEPER_DISC) " +
            "VALUES (@codigo, @apellidos, @nombres, @fecnac, @genero, @estciv, @peso, @tipsang, @foto, 0, 'N')";

        private const string SqlActualizar =
            "UPDATE PEPER_PERSO SET PEPER_APELLI = @apellidos, PEPER_NOMBRE = @nombres, PEPER_FECNAC = @fecnac, " +
            "PEGEN_CODIGO = @genero, PEESC_CODIGO = @estciv, PEPER_PESO = @peso, PEPER_TIPSANG = @tipsang, " +
            "PEPER_FOTO = @foto WHERE PEPER_CODIGO = @codigo";

        private const string SqlEliminar =
            "DELETE FROM PEPER_PERSO WHERE PEPER_CODIGO = @codigo";

        private const string SqlListarAcademicos =
            "SELECT PEACA_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL " +
            "FROM PEACA_ACADE WHERE PEPER_CODIGO = @codigo ORDER BY PEACA_CODIGO";

        private const string SqlListarFamiliares =
            "SELECT PEFAM_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC " +
            "FROM PEFAM_FAMIL WHERE PEPER_CODIGO = @codigo ORDER BY PEFAM_CODIGO";

        /// <summary>Lista todos los empleados con las descripciones de sexo y estado civil.</summary>
        public List<Empleado> Listar()
        {
            var empleados = new List<Empleado>();
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(SqlListar, conexion))
            using (SqlDataReader lector = comando.ExecuteReader())
            {
                while (lector.Read())
                {
                    empleados.Add(Mapear(lector));
                }
            }
            return empleados;
        }

        /// <summary>
        /// Busca el empleado por su código de persona y carga además sus
        /// subtablas de Datos Académicos y Datos Familiares.
        /// Devuelve null si no existe.
        /// </summary>
        public Empleado BuscarPorCodigo(string codigo)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            {
                Empleado empleado;
                // La fila principal se lee y el lector se cierra antes de
                // ejecutar las consultas de las subtablas (SQL Server no
                // admite dos lectores abiertos en la misma conexión).
                using (var comando = new SqlCommand(SqlBuscar, conexion))
                {
                    comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = codigo;
                    using (SqlDataReader lector = comando.ExecuteReader())
                    {
                        if (!lector.Read())
                        {
                            return null;
                        }
                        empleado = Mapear(lector);
                    }
                }
                empleado.Academicos = ListarAcademicos(conexion, codigo);
                empleado.Familiares = ListarFamiliares(conexion, codigo);
                return empleado;
            }
        }

        public bool Existe(string codigo)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(
                "SELECT 1 FROM PEPER_PERSO WHERE PEPER_CODIGO = @codigo", conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = codigo;
                return comando.ExecuteScalar() != null;
            }
        }

        /// <summary>Inserta el empleado y sus subtablas dentro de una transacción.</summary>
        public bool Insertar(Empleado empleado)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (SqlTransaction transaccion = conexion.BeginTransaction())
            {
                try
                {
                    using (var comando = new SqlCommand(SqlInsertar, conexion, transaccion))
                    {
                        LlenarParametrosPersona(comando, empleado);
                        comando.ExecuteNonQuery();
                    }
                    InsertarDetalles(conexion, transaccion, empleado);
                    transaccion.Commit();
                    return true;
                }
                catch
                {
                    try { transaccion.Rollback(); } catch { /* Ya no hay nada por hacer. */ }
                    throw;
                }
            }
        }

        /// <summary>
        /// Actualiza los datos del empleado y reemplaza el contenido completo
        /// de sus subtablas dentro de una transacción.
        /// </summary>
        public bool Actualizar(Empleado empleado)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (SqlTransaction transaccion = conexion.BeginTransaction())
            {
                try
                {
                    int filas;
                    using (var comando = new SqlCommand(SqlActualizar, conexion, transaccion))
                    {
                        LlenarParametrosPersona(comando, empleado);
                        filas = comando.ExecuteNonQuery();
                    }
                    if (filas == 0)
                    {
                        transaccion.Rollback();
                        return false;
                    }
                    using (var comando = new SqlCommand(
                        "DELETE FROM PEACA_ACADE WHERE PEPER_CODIGO = @codigo", conexion, transaccion))
                    {
                        comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = empleado.Codigo;
                        comando.ExecuteNonQuery();
                    }
                    using (var comando = new SqlCommand(
                        "DELETE FROM PEFAM_FAMIL WHERE PEPER_CODIGO = @codigo", conexion, transaccion))
                    {
                        comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = empleado.Codigo;
                        comando.ExecuteNonQuery();
                    }
                    InsertarDetalles(conexion, transaccion, empleado);
                    transaccion.Commit();
                    return true;
                }
                catch
                {
                    try { transaccion.Rollback(); } catch { /* Ya no hay nada por hacer. */ }
                    throw;
                }
            }
        }

        /// <summary>
        /// Elimina el empleado. Las subtablas se borran en cascada por la
        /// clave foránea (ON DELETE CASCADE).
        /// </summary>
        public bool Eliminar(string codigo)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(SqlEliminar, conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = codigo;
                return comando.ExecuteNonQuery() > 0;
            }
        }

        /// <summary>Catálogo de sexos para el combobox de Datos Generales.</summary>
        public List<Catalogo> ListarGeneros()
        {
            return ListarCatalogo(
                "SELECT PEGEN_CODIGO, PEGEN_DESCRI FROM PEGEN_GENERO ORDER BY PEGEN_DESCRI");
        }

        /// <summary>Catálogo de estados civiles para el combobox de Datos Generales.</summary>
        public List<Catalogo> ListarEstadosCiviles()
        {
            return ListarCatalogo(
                "SELECT PEESC_CODIGO, PEESC_DESCRI FROM PEESC_ESTCIV ORDER BY PEESC_CODIGO");
        }

        private List<Catalogo> ListarCatalogo(string sql)
        {
            var catalogo = new List<Catalogo>();
            using (SqlConnection conexion = ConexionBD.Obtener())
            using (var comando = new SqlCommand(sql, conexion))
            using (SqlDataReader lector = comando.ExecuteReader())
            {
                while (lector.Read())
                {
                    catalogo.Add(new Catalogo(
                        Convert.ToString(lector[0]),
                        Convert.ToString(lector[1])));
                }
            }
            return catalogo;
        }

        private List<EmpleadoAcademico> ListarAcademicos(SqlConnection conexion, string codigo)
        {
            var academicos = new List<EmpleadoAcademico>();
            using (var comando = new SqlCommand(SqlListarAcademicos, conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = codigo;
                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    while (lector.Read())
                    {
                        var academico = new EmpleadoAcademico(
                            Convert.ToString(lector["PEACA_NIVEL"]),
                            Convert.ToString(lector["PEACA_INSTI"]),
                            Convert.ToString(lector["PEACA_TITUL"]));
                        academico.CodigoAcademico = Convert.ToInt32(lector["PEACA_CODIGO"]);
                        academicos.Add(academico);
                    }
                }
            }
            return academicos;
        }

        private List<EmpleadoFamiliar> ListarFamiliares(SqlConnection conexion, string codigo)
        {
            var familiares = new List<EmpleadoFamiliar>();
            using (var comando = new SqlCommand(SqlListarFamiliares, conexion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = codigo;
                using (SqlDataReader lector = comando.ExecuteReader())
                {
                    while (lector.Read())
                    {
                        object valorFecha = lector["PEFAM_FECNAC"];
                        DateTime? fecha = valorFecha == DBNull.Value
                            ? (DateTime?)null
                            : Convert.ToDateTime(valorFecha);
                        var familiar = new EmpleadoFamiliar(
                            Convert.ToString(lector["PEFAM_PAREN"]),
                            Convert.ToString(lector["PEFAM_NOMBRE"]),
                            fecha);
                        familiar.CodigoFamiliar = Convert.ToInt32(lector["PEFAM_CODIGO"]);
                        familiares.Add(familiar);
                    }
                }
            }
            return familiares;
        }

        private void InsertarDetalles(SqlConnection conexion, SqlTransaction transaccion, Empleado empleado)
        {
            using (var comando = new SqlCommand(
                "INSERT INTO PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL) " +
                "VALUES (@codigo, @nivel, @insti, @titul)", conexion, transaccion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10);
                comando.Parameters.Add("@nivel", SqlDbType.VarChar, 50);
                comando.Parameters.Add("@insti", SqlDbType.VarChar, 100);
                comando.Parameters.Add("@titul", SqlDbType.VarChar, 100);
                foreach (EmpleadoAcademico academico in empleado.Academicos)
                {
                    comando.Parameters["@codigo"].Value = empleado.Codigo;
                    comando.Parameters["@nivel"].Value = academico.Nivel;
                    comando.Parameters["@insti"].Value = academico.Institucion;
                    comando.Parameters["@titul"].Value = academico.Titulo;
                    comando.ExecuteNonQuery();
                }
            }
            using (var comando = new SqlCommand(
                "INSERT INTO PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC) " +
                "VALUES (@codigo, @paren, @nombre, @fecnac)", conexion, transaccion))
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10);
                comando.Parameters.Add("@paren", SqlDbType.VarChar, 20);
                comando.Parameters.Add("@nombre", SqlDbType.VarChar, 100);
                comando.Parameters.Add("@fecnac", SqlDbType.Date);
                foreach (EmpleadoFamiliar familiar in empleado.Familiares)
                {
                    comando.Parameters["@codigo"].Value = empleado.Codigo;
                    comando.Parameters["@paren"].Value = familiar.Persona;
                    comando.Parameters["@nombre"].Value = familiar.Nombres;
                    comando.Parameters["@fecnac"].Value =
                        familiar.FechaNacimiento.HasValue
                            ? (object)familiar.FechaNacimiento.Value
                            : DBNull.Value;
                    comando.ExecuteNonQuery();
                }
            }
        }

        /// <summary>Llena los parámetros comunes del INSERT y del UPDATE.</summary>
        private static void LlenarParametrosPersona(SqlCommand comando, Empleado empleado)
        {
            comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = empleado.Codigo;
            comando.Parameters.Add("@apellidos", SqlDbType.VarChar, 50).Value = empleado.Apellidos;
            comando.Parameters.Add("@nombres", SqlDbType.VarChar, 50).Value = empleado.Nombres;
            comando.Parameters.Add("@fecnac", SqlDbType.Date).Value = empleado.FechaNacimiento.Value;
            AsignarOpcional(comando, "@genero", SqlDbType.Char, 1, empleado.CodigoGenero);
            AsignarOpcional(comando, "@estciv", SqlDbType.Char, 1, empleado.CodigoEstadoCivil);
            if (empleado.Peso > 0)
            {
                comando.Parameters.Add("@peso", SqlDbType.Decimal).Value = (decimal)empleado.Peso;
            }
            else
            {
                comando.Parameters.Add("@peso", SqlDbType.Decimal).Value = DBNull.Value;
            }
            AsignarOpcional(comando, "@tipsang", SqlDbType.VarChar, 3, empleado.TipoSangre);
            // La tabla compartida de personas exige foto NOT NULL; vacío representa sin foto.
            comando.Parameters.Add("@foto", SqlDbType.VarChar, 100)
                .Value = string.IsNullOrWhiteSpace(empleado.Foto) ? "" : empleado.Foto.Trim();
        }

        private static void AsignarOpcional(
            SqlCommand comando, string nombre, SqlDbType tipo, int tamano, string valor)
        {
            comando.Parameters.Add(nombre, tipo, tamano)
                .Value = string.IsNullOrWhiteSpace(valor) ? (object)DBNull.Value : valor.Trim();
        }

        private static Empleado Mapear(SqlDataReader lector)
        {
            var empleado = new Empleado
            {
                Codigo = Convert.ToString(lector["PEPER_CODIGO"]),
                Apellidos = Convert.ToString(lector["PEPER_APELLI"]),
                Nombres = Convert.ToString(lector["PEPER_NOMBRE"])
            };
            object valorFecha = lector["PEPER_FECNAC"];
            if (valorFecha != DBNull.Value)
            {
                empleado.FechaNacimiento = Convert.ToDateTime(valorFecha);
            }
            if (lector["PEGEN_CODIGO"] != DBNull.Value)
            {
                empleado.CodigoGenero = Convert.ToString(lector["PEGEN_CODIGO"]);
            }
            if (lector["PEGEN_DESCRI"] != DBNull.Value)
            {
                empleado.DescriGenero = Convert.ToString(lector["PEGEN_DESCRI"]);
            }
            if (lector["PEESC_CODIGO"] != DBNull.Value)
            {
                empleado.CodigoEstadoCivil = Convert.ToString(lector["PEESC_CODIGO"]);
            }
            if (lector["PEESC_DESCRI"] != DBNull.Value)
            {
                empleado.DescriEstadoCivil = Convert.ToString(lector["PEESC_DESCRI"]);
            }
            if (lector["PEPER_PESO"] != DBNull.Value)
            {
                empleado.Peso = Convert.ToDouble(lector["PEPER_PESO"]);
            }
            if (lector["PEPER_TIPSANG"] != DBNull.Value)
            {
                empleado.TipoSangre = Convert.ToString(lector["PEPER_TIPSANG"]);
            }
            if (lector["PEPER_FOTO"] != DBNull.Value)
            {
                empleado.Foto = Convert.ToString(lector["PEPER_FOTO"]);
            }
            return empleado;
        }
    }
}
