using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Acceso a datos del Mantenimiento de Empleados con Tab Page sobre
    /// SQL Server. Equivalente al EmpleadoDAO del proyecto Java.
    ///
    /// Administra la tabla PEPER_PERSO (PERSONA del esquema de Seguridad)
    /// junto con sus dos subtablas: PEACA_ACADE (Datos Académicos) y
    /// PEFAM_FAMIL (Datos Familiares). Los inserts y updates se realizan
    /// dentro de una transacción para que la persona y sus subtablas se
    /// guarden completas o nada.
    /// </summary>
    public class EmpleadoRepository
    {
        /// <summary>SELECT base del empleado junto a las descripciones de sus catálogos.</summary>
        private const string SqlListarBase =
            "SELECT p.PEPER_CODIGO, p.PEPER_CEDULA, p.PEPER_APELLI, p.PEPER_NOMBRE, p.PEPER_FECNAC, " +
            "p.PEGEN_CODIGO, g.PEGEN_DESCRI, p.PEESC_CODIGO, e.PEESC_DESCRI, " +
            "p.PEPER_PESO, p.PEPER_TIPSANG, p.PEPER_CARFAM, p.PEPER_FOTO " +
            "FROM PEPER_PERSO p " +
            "LEFT JOIN PEGEN_GENERO g ON g.PEGEN_CODIGO = p.PEGEN_CODIGO " +
            "LEFT JOIN PEESC_ESTCIV e ON e.PEESC_CODIGO = p.PEESC_CODIGO ";

        private const string SqlListar =
            SqlListarBase + "ORDER BY p.PEPER_APELLI, p.PEPER_NOMBRE";

        private const string SqlBuscar =
            SqlListarBase + "WHERE p.PEPER_CODIGO = @codigo";

        private const string SqlInsertar =
            "INSERT INTO PEPER_PERSO (PEPER_CODIGO, PEPER_CEDULA, PEPER_APELLI, PEPER_NOMBRE, " +
            "PEPER_FECNAC, PEGEN_CODIGO, PEESC_CODIGO, PEPER_PESO, PEPER_TIPSANG, " +
            "PEPER_CARFAM, PEPER_FOTO, PEPER_DISC) " +
            "VALUES (@codigo, @cedula, @apelli, @nombre, @fecnac, @genero, @estciv, " +
            "@peso, @tipsang, @carfam, @foto, 'N')";

        private const string SqlActualizar =
            "UPDATE PEPER_PERSO SET PEPER_CEDULA = @cedula, PEPER_APELLI = @apelli, PEPER_NOMBRE = @nombre, " +
            "PEPER_FECNAC = @fecnac, PEGEN_CODIGO = @genero, PEESC_CODIGO = @estciv, PEPER_PESO = @peso, " +
            "PEPER_TIPSANG = @tipsang, PEPER_CARFAM = @carfam, PEPER_FOTO = @foto " +
            "WHERE PEPER_CODIGO = @codigo";

        private const string SqlEliminar =
            "DELETE FROM PEPER_PERSO WHERE PEPER_CODIGO = @codigo";

        private const string SqlEliminarAcademicos =
            "DELETE FROM PEACA_ACADE WHERE PEPER_CODIGO = @codigo";

        private const string SqlEliminarFamiliares =
            "DELETE FROM PEFAM_FAMIL WHERE PEPER_CODIGO = @codigo";

        private const string SqlInsertarAcademico =
            "INSERT INTO PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL) " +
            "VALUES (@codigo, @nivel, @insti, @titul)";

        private const string SqlInsertarFamiliar =
            "INSERT INTO PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC) " +
            "VALUES (@codigo, @paren, @nombre, @fecnac)";

        private const string SqlListarAcademicos =
            "SELECT PEACA_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL " +
            "FROM PEACA_ACADE WHERE PEPER_CODIGO = @codigo ORDER BY PEACA_CODIGO";

        private const string SqlListarFamiliares =
            "SELECT PEFAM_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC " +
            "FROM PEFAM_FAMIL WHERE PEPER_CODIGO = @codigo ORDER BY PEFAM_CODIGO";

        private const string SqlExiste =
            "SELECT 1 FROM PEPER_PERSO WHERE PEPER_CODIGO = @codigo";

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
        /// Busca el empleado por su código y carga además sus subtablas
        /// de Datos Académicos y Datos Familiares.
        /// </summary>
        public Empleado BuscarPorCodigo(string codigo)
        {
            using (SqlConnection conexion = ConexionBD.Obtener())
            {
                Empleado empleado;
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
            using (var comando = new SqlCommand(SqlExiste, conexion))
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
                        LlenarParametrosPersona(comando, empleado, true);
                        comando.ExecuteNonQuery();
                    }
                    InsertarDetalles(conexion, transaccion, empleado);
                    transaccion.Commit();
                    return true;
                }
                catch
                {
                    transaccion.Rollback();
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
                        LlenarParametrosPersona(comando, empleado, false);
                        filas = comando.ExecuteNonQuery();
                    }
                    if (filas == 0)
                    {
                        transaccion.Rollback();
                        return false;
                    }
                    using (var comando = new SqlCommand(SqlEliminarAcademicos, conexion, transaccion))
                    {
                        comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = empleado.Codigo;
                        comando.ExecuteNonQuery();
                    }
                    using (var comando = new SqlCommand(SqlEliminarFamiliares, conexion, transaccion))
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
                    transaccion.Rollback();
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
                        Convert.ToString(lector.GetValue(0)),
                        Convert.ToString(lector.GetValue(1))));
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
                        academicos.Add(new EmpleadoAcademico(
                            Convert.ToString(lector["PEACA_NIVEL"]),
                            Convert.ToString(lector["PEACA_INSTI"]),
                            Convert.ToString(lector["PEACA_TITUL"]))
                        {
                            CodigoAcademico = Convert.ToInt32(lector["PEACA_CODIGO"])
                        });
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
                        familiares.Add(new EmpleadoFamiliar(
                            Convert.ToString(lector["PEFAM_PAREN"]),
                            Convert.ToString(lector["PEFAM_NOMBRE"]),
                            fecha)
                        {
                            CodigoFamiliar = Convert.ToInt32(lector["PEFAM_CODIGO"])
                        });
                    }
                }
            }
            return familiares;
        }

        private void InsertarDetalles(SqlConnection conexion, SqlTransaction transaccion, Empleado empleado)
        {
            foreach (EmpleadoAcademico academico in empleado.Academicos)
            {
                using (var comando = new SqlCommand(SqlInsertarAcademico, conexion, transaccion))
                {
                    comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = empleado.Codigo;
                    comando.Parameters.Add("@nivel", SqlDbType.VarChar, 50).Value = academico.Nivel;
                    comando.Parameters.Add("@insti", SqlDbType.VarChar, 100).Value = academico.Institucion;
                    comando.Parameters.Add("@titul", SqlDbType.VarChar, 100).Value = academico.Titulo;
                    comando.ExecuteNonQuery();
                }
            }
            foreach (EmpleadoFamiliar familiar in empleado.Familiares)
            {
                using (var comando = new SqlCommand(SqlInsertarFamiliar, conexion, transaccion))
                {
                    comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = empleado.Codigo;
                    comando.Parameters.Add("@paren", SqlDbType.VarChar, 20).Value = familiar.Persona;
                    comando.Parameters.Add("@nombre", SqlDbType.VarChar, 100).Value = familiar.Nombres;
                    comando.Parameters.Add("@fecnac", SqlDbType.Date).Value = familiar.FechaNacimiento.Value;
                    comando.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Llena los parámetros del INSERT (con el código como primer
        /// parámetro) o del UPDATE (con el código al final).
        ///
        /// PEPER_DISC se fija en 'N' al insertar (literal del INSERT) y
        /// no se toca al actualizar.
        /// </summary>
        private static void LlenarParametrosPersona(SqlCommand comando, Empleado empleado, bool esInsercion)
        {
            if (esInsercion)
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = empleado.Codigo;
            }
            comando.Parameters.Add("@cedula", SqlDbType.VarChar, 10).Value = VacioANulo(empleado.Cedula) ?? (object)DBNull.Value;
            comando.Parameters.Add("@apelli", SqlDbType.VarChar, 50).Value = empleado.Apellidos;
            comando.Parameters.Add("@nombre", SqlDbType.VarChar, 50).Value = empleado.Nombres;
            comando.Parameters.Add("@fecnac", SqlDbType.Date).Value = empleado.FechaNacimiento.Value;
            comando.Parameters.Add("@genero", SqlDbType.Char, 1).Value = empleado.CodigoGenero;
            comando.Parameters.Add("@estciv", SqlDbType.Char, 1).Value = VacioANulo(empleado.CodigoEstadoCivil) ?? (object)DBNull.Value;
            comando.Parameters.Add("@peso", SqlDbType.Decimal).Value = empleado.Peso > 0
                ? (object)Convert.ToDecimal(empleado.Peso)
                : DBNull.Value;
            ((SqlParameter)comando.Parameters["@peso"]).Precision = 5;
            ((SqlParameter)comando.Parameters["@peso"]).Scale = 2;
            comando.Parameters.Add("@tipsang", SqlDbType.VarChar, 3).Value = VacioANulo(empleado.TipoSangre) ?? (object)DBNull.Value;
            comando.Parameters.Add("@carfam", SqlDbType.Int).Value = empleado.CargasFam;
            comando.Parameters.Add("@foto", SqlDbType.VarChar, 100).Value =
                (empleado.Foto == null ? "" : empleado.Foto.Trim());
            if (!esInsercion)
            {
                comando.Parameters.Add("@codigo", SqlDbType.Char, 10).Value = empleado.Codigo;
            }
        }

        private static string VacioANulo(string valor)
        {
            if (valor == null || valor.Trim().Length == 0)
            {
                return null;
            }
            return valor.Trim();
        }

        private static Empleado Mapear(SqlDataReader lector)
        {
            Empleado empleado = new Empleado
            {
                Codigo = Leer(lector, "PEPER_CODIGO"),
                Cedula = Leer(lector, "PEPER_CEDULA"),
                Apellidos = Leer(lector, "PEPER_APELLI"),
                Nombres = Leer(lector, "PEPER_NOMBRE"),
                CodigoGenero = Leer(lector, "PEGEN_CODIGO"),
                DescriGenero = Leer(lector, "PEGEN_DESCRI"),
                CodigoEstadoCivil = Leer(lector, "PEESC_CODIGO"),
                DescriEstadoCivil = Leer(lector, "PEESC_DESCRI"),
                TipoSangre = Leer(lector, "PEPER_TIPSANG"),
                Foto = Leer(lector, "PEPER_FOTO")
            };

            object valorFecha = lector["PEPER_FECNAC"];
            empleado.FechaNacimiento = valorFecha == DBNull.Value
                ? (DateTime?)null
                : Convert.ToDateTime(valorFecha);

            object valorPeso = lector["PEPER_PESO"];
            empleado.Peso = valorPeso == DBNull.Value ? 0.0 : Convert.ToDouble(valorPeso);

            object valorCargas = lector["PEPER_CARFAM"];
            empleado.CargasFam = valorCargas == DBNull.Value ? 0 : Convert.ToInt32(valorCargas);

            return empleado;
        }

        private static string Leer(SqlDataReader lector, string columna)
        {
            object valor = lector[columna];
            return valor == DBNull.Value ? null : Convert.ToString(valor);
        }
    }
}
