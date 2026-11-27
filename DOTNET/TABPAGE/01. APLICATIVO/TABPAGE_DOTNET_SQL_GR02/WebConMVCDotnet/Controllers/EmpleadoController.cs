using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Imaging;
using System.Globalization;
using System.IO;
using System.Web;
using System.Web.Mvc;
using WebConMVCDotnet.App_Start;
using WebConMVCDotnet.Models;

namespace WebConMVCDotnet.Controllers
{
    /// <summary>
    /// Mantenimiento de Empleados con Tab Page (equivalente al
    /// EmpleadoController del proyecto Java).
    ///
    /// La ficha tiene un marco superior con foto, apellidos y nombres,
    /// y tres pestañas: Datos Generales, Datos Académicos (subtabla)
    /// y Datos Familiares (subtabla). El formulario envía la foto junto
    /// con todas las pestañas (multipart/form-data) y la imagen se
    /// guarda como JPEG en /resources/fotos_empleados/{código}.jpg.
    ///
    /// Misma política de acceso, anti-forgery y PRG que CargoController.
    /// </summary>
    [FiltroAutenticacion]
    public class EmpleadoController : Controller
    {
        private readonly EmpleadoRepository empleadoRepository = new EmpleadoRepository();

        private const string FlashExito = "EmpleadoMensajeExito";
        private const string FlashError = "EmpleadoMensajeError";

        /// <summary>Carpeta dentro de /resources donde se guardan las fotos subidas.</summary>
        private const string CarpetaFotos = "~/resources/fotos_empleados";

        /// <summary>Tipos de sangre aceptados en la pestaña Datos Generales.</summary>
        private static readonly string[] TiposSangre =
            { "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" };

        /// <summary>Parentescos aceptados en la pestaña Datos Familiares.</summary>
        private static readonly string[] Parentescos =
            { "PADRE", "MADRE", "CONYUGE", "HIJO/A", "HERMANO/A", "OTRO" };

        [HttpGet]
        public ActionResult Index()
        {
            CargarMensajesFlash();
            return VistaListado(null, false);
        }

        [HttpGet]
        public ActionResult Editar(string codigo)
        {
            CargarMensajesFlash();
            codigo = Normalizar(codigo);

            Empleado empleado = null;
            try
            {
                empleado = codigo.Length > 0 ? empleadoRepository.BuscarPorCodigo(codigo) : null;
            }
            catch (Exception)
            {
                TempData[FlashError] = MensajeConexion();
                return RedirectToAction("Index");
            }

            if (empleado == null)
            {
                TempData[FlashError] = "No se encontró el empleado solicitado.";
                return RedirectToAction("Index");
            }

            return VistaListado(empleado, true);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Guardar(string modo, HttpPostedFileBase foto)
        {
            bool edicion = "editar".Equals(Normalizar(modo), StringComparison.OrdinalIgnoreCase);
            try
            {
                if (!"nuevo".Equals(Normalizar(modo), StringComparison.OrdinalIgnoreCase) && !edicion)
                {
                    return new HttpStatusCodeResult(400);
                }

                // El formulario de la ficha envía la foto junto con todas las pestañas.
                Empleado empleado = ConstruirEmpleado();
                string error = Validar(empleado, edicion);
                if (error == null)
                {
                    try
                    {
                        GuardarArchivoFoto(foto, empleado);
                    }
                    catch (Exception exFoto)
                    {
                        error = "No se pudo guardar la foto indicada. Revise el formato (JPG o PNG).";
                        System.Diagnostics.Debug.WriteLine("No se pudo guardar la foto del empleado: " + exFoto.Message);
                    }
                }
                if (error == null)
                {
                    try
                    {
                        bool guardado = edicion
                            ? empleadoRepository.Actualizar(empleado)
                            : empleadoRepository.Insertar(empleado);
                        if (!guardado)
                        {
                            error = "No se pudo guardar: el empleado ya no existe o no se modificó.";
                        }
                    }
                    catch (SqlException ex)
                    {
                        error = MensajeBaseDatos(ex, "guardar");
                    }
                    catch (Exception)
                    {
                        error = MensajeConexion();
                    }
                }

                if (error != null)
                {
                    ViewBag.MensajeError = error;
                    return VistaListado(empleado, edicion);
                }

                TempData[FlashExito] = "Ficha del empleado guardada correctamente.";
                return RedirectToAction("Index");
            }
            catch (Exception)
            {
                ViewBag.MensajeError = "No se pudo procesar la operación.";
                return VistaListado(new Empleado(), edicion);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Eliminar(string codigo)
        {
            string cod = Normalizar(codigo);
            try
            {
                if (cod.Length == 0)
                {
                    TempData[FlashError] = "Indique el código del empleado a eliminar.";
                    return RedirectToAction("Index");
                }

                if (empleadoRepository.Eliminar(cod))
                {
                    EliminarArchivoFoto(cod);
                    TempData[FlashExito] = "Empleado eliminado correctamente.";
                }
                else
                {
                    TempData[FlashError] = "El empleado que intenta eliminar ya no existe.";
                }
            }
            catch (SqlException ex)
            {
                TempData[FlashError] = MensajeBaseDatos(ex, "eliminar");
            }
            catch (Exception)
            {
                TempData[FlashError] = MensajeConexion();
            }

            return RedirectToAction("Index");
        }

        // ----- Métodos privados de apoyo -----

        private ViewResult VistaListado(Empleado empleado, bool edicion)
        {
            ViewBag.Empleados = empleadoRepository.Listar();
            ViewBag.Generos = empleadoRepository.ListarGeneros();
            ViewBag.EstadosCiviles = empleadoRepository.ListarEstadosCiviles();
            ViewBag.Empleado = empleado ?? new Empleado();
            ViewBag.ModoEdicion = edicion;
            return View("Index");
        }

        /// <summary>Arma el empleado con los campos del marco, las pestañas y las subtablas.</summary>
        private Empleado ConstruirEmpleado()
        {
            return new Empleado
            {
                Codigo = Valor("codigo"),
                Cedula = Valor("cedula"),
                Apellidos = Valor("apellidos"),
                Nombres = Valor("nombres"),
                FechaNacimiento = LeerFecha(Valor("fechaNacimiento")),
                CodigoGenero = Valor("genero"),
                CodigoEstadoCivil = Valor("estadoCivil"),
                Peso = LeerPeso(Valor("peso")),
                TipoSangre = Valor("tipoSangre").ToUpperInvariant(),
                CargasFam = LeerEntero(Valor("cargasFam"), -1),
                // Si no se sube una foto nueva, se conserva la ruta actual de la ficha.
                Foto = Valor("fotoActual"),
                Academicos = LeerAcademicos(),
                Familiares = LeerFamiliares()
            };
        }

        /// <summary>
        /// Lee la subtabla de Datos Académicos. Las filas completamente
        /// vacías se descartan; las incompletas se conservan para que
        /// Validar() pida completarlas.
        /// </summary>
        private List<EmpleadoAcademico> LeerAcademicos()
        {
            string[] niveles = Request.Form.GetValues("acaNivel") ?? new string[0];
            string[] instituciones = Request.Form.GetValues("acaInstitucion") ?? new string[0];
            string[] titulos = Request.Form.GetValues("acaTitulo") ?? new string[0];

            var academicos = new List<EmpleadoAcademico>();
            for (int i = 0; i < niveles.Length; i++)
            {
                string nivel = TextoSeguro(niveles, i);
                string institucion = TextoSeguro(instituciones, i);
                string titulo = TextoSeguro(titulos, i);
                if (nivel.Length == 0 && institucion.Length == 0 && titulo.Length == 0)
                {
                    continue; // Fila vacía: no se guarda.
                }
                academicos.Add(new EmpleadoAcademico(nivel, institucion, titulo));
            }
            return academicos;
        }

        /// <summary>Igual que LeerAcademicos, pero para la subtabla de Datos Familiares.</summary>
        private List<EmpleadoFamiliar> LeerFamiliares()
        {
            string[] personas = Request.Form.GetValues("famPersona") ?? new string[0];
            string[] nombres = Request.Form.GetValues("famNombres") ?? new string[0];
            string[] fechas = Request.Form.GetValues("famFecha") ?? new string[0];

            var familiares = new List<EmpleadoFamiliar>();
            for (int i = 0; i < personas.Length; i++)
            {
                string persona = TextoSeguro(personas, i);
                string nombre = TextoSeguro(nombres, i);
                string fecha = TextoSeguro(fechas, i);
                if (persona.Length == 0 && nombre.Length == 0 && fecha.Length == 0)
                {
                    continue; // Fila vacía: no se guarda.
                }
                DateTime? fechaNacimiento = fecha.Length == 0 ? (DateTime?)null : LeerFecha(fecha);
                familiares.Add(new EmpleadoFamiliar(persona, nombre, fechaNacimiento));
            }
            return familiares;
        }

        /// <summary>Aplica las reglas de negocio de la ficha. Devuelve null si todo está bien.</summary>
        private string Validar(Empleado empleado, bool edicion)
        {
            if (empleado.Codigo.Length == 0 || empleado.Codigo.Length > 10)
            {
                return "Ingrese el código del empleado (hasta 10 caracteres).";
            }
            if (empleado.Cedula.Length > 0 && !System.Text.RegularExpressions.Regex.IsMatch(empleado.Cedula, "^\\d{10}$"))
            {
                return "La cédula debe tener exactamente 10 dígitos (o déjela vacía).";
            }
            if (empleado.Apellidos.Length == 0 || empleado.Apellidos.Length > 50)
            {
                return "Ingrese los apellidos del empleado (entre 1 y 50 caracteres).";
            }
            if (empleado.Nombres.Length == 0 || empleado.Nombres.Length > 50)
            {
                return "Ingrese los nombres del empleado (entre 1 y 50 caracteres).";
            }
            if (!empleado.FechaNacimiento.HasValue
                || empleado.FechaNacimiento.Value.Date > DateTime.Today)
            {
                return "Ingrese una fecha de nacimiento válida (no puede ser futura).";
            }
            // PEGEN_CODIGO es obligatorio en PEPER_PERSO (esquema de Seguridad).
            if (empleado.CodigoGenero.Length == 0)
            {
                return "Seleccione el sexo del empleado en Datos Generales.";
            }
            if (double.IsNaN(empleado.Peso)
                || (empleado.Peso > 0 && empleado.Peso > 500))
            {
                return "Ingrese un peso válido en kilogramos (entre 1 y 500).";
            }
            if (empleado.CargasFam < 0 || empleado.CargasFam > 20)
            {
                return "Las cargas familiares deben estar entre 0 y 20.";
            }
            if (empleado.TipoSangre.Length > 0
                && Array.IndexOf(TiposSangre, empleado.TipoSangre) < 0)
            {
                return "El tipo de sangre indicado no es válido.";
            }
            foreach (EmpleadoAcademico academico in empleado.Academicos)
            {
                if (academico.Nivel.Length == 0 || academico.Institucion.Length == 0
                    || academico.Titulo.Length == 0)
                {
                    return "En Datos Académicos complete nivel, institución y título de cada fila, "
                        + "o deje la fila vacía para descartarla.";
                }
                if (academico.Nivel.Length > 50 || academico.Institucion.Length > 100
                    || academico.Titulo.Length > 100)
                {
                    return "En Datos Académicos se excedió el tamaño permitido de algún campo.";
                }
            }
            foreach (EmpleadoFamiliar familiar in empleado.Familiares)
            {
                if (familiar.Persona.Length == 0 || familiar.Nombres.Length == 0
                    || !familiar.FechaNacimiento.HasValue)
                {
                    return "En Datos Familiares complete persona, apellidos y nombres, y fecha de "
                        + "nacimiento de cada fila, o deje la fila vacía para descartarla.";
                }
                if (familiar.Nombres.Length > 100)
                {
                    return "En Datos Familiares los apellidos y nombres no pueden superar 100 caracteres.";
                }
            }
            try
            {
                if (edicion && !empleadoRepository.Existe(empleado.Codigo))
                {
                    return "El empleado que intenta editar ya no existe.";
                }
                if (!edicion && empleadoRepository.Existe(empleado.Codigo))
                {
                    return "Ya existe un empleado registrado con esa cédula.";
                }
            }
            catch (SqlException)
            {
                throw;
            }
            return null;
        }

        /// <summary>
        /// Guarda la foto subida en /resources/fotos_empleados/{código}.jpg,
        /// igual que el proyecto Java. La imagen se convierte a JPEG y la
        /// ruta relativa queda en el empleado para que la vista la muestre.
        /// </summary>
        private void GuardarArchivoFoto(HttpPostedFileBase archivo, Empleado empleado)
        {
            if (archivo == null || archivo.ContentLength == 0)
            {
                return; // Sin foto nueva: se conserva la actual.
            }
            using (Image imagen = Image.FromStream(archivo.InputStream))
            {
                string carpeta = Server.MapPath(CarpetaFotos);
                if (!Directory.Exists(carpeta))
                {
                    Directory.CreateDirectory(carpeta);
                }
                string destino = Path.Combine(carpeta, empleado.Codigo + ".jpg");
                if (System.IO.File.Exists(destino))
                {
                    System.IO.File.Delete(destino);
                }
                imagen.Save(destino, ImageFormat.Jpeg);
            }
            empleado.Foto = "fotos_empleados/" + empleado.Codigo + ".jpg";
        }

        /// <summary>Borra la foto del empleado eliminado. Falla en silencio: es limpieza secundaria.</summary>
        private void EliminarArchivoFoto(string codigo)
        {
            if (string.IsNullOrEmpty(codigo))
            {
                return;
            }
            try
            {
                string carpeta = Server.MapPath(CarpetaFotos);
                string destino = Path.Combine(carpeta, codigo + ".jpg");
                if (System.IO.File.Exists(destino))
                {
                    System.IO.File.Delete(destino);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("No se pudo borrar la foto del empleado " + codigo + ": " + ex.Message);
            }
        }

        private void CargarMensajesFlash()
        {
            object exito = TempData[FlashExito];
            object error = TempData[FlashError];

            if (exito != null)
            {
                ViewBag.MensajeExito = exito.ToString();
            }
            if (error != null)
            {
                ViewBag.MensajeError = error.ToString();
            }
        }

        private static string Normalizar(string valor)
        {
            return valor == null ? "" : valor.Trim();
        }

        private static string MensajeConexion()
        {
            return "No se pudo conectar con la base de datos. "
                + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.";
        }

        /// <summary>
        /// Traduce los errores de base de datos más comunes de la ficha:
        /// duplicados de clave primaria y violaciones de llave foránea.
        /// </summary>
        private static string MensajeBaseDatos(SqlException ex, string operacion)
        {
            if (ex.Number == 2601 || ex.Number == 2627)
            {
                return "Ya existe una persona con ese código.";
            }
            if (ex.Number == 547)
            {
                if ("eliminar".Equals(operacion, StringComparison.OrdinalIgnoreCase))
                {
                    return "No se puede eliminar la persona porque está vinculada a un usuario "
                        + "u otros registros del sistema.";
                }
                return "El sexo o el estado civil seleccionado ya no existe en el catálogo.";
            }
            return "No se pudo completar la operación. Revise la conexión y la tabla PEPER_PERSO.";
        }

        /// <summary>Lee la fecha en formato ISO (yyyy-MM-dd) del input date.</summary>
        private static DateTime? LeerFecha(string valor)
        {
            if (valor == null || valor.Length == 0)
            {
                return null;
            }
            DateTime fecha;
            if (DateTime.TryParseExact(valor, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                    DateTimeStyles.None, out fecha)
                || DateTime.TryParse(valor, CultureInfo.InvariantCulture,
                    DateTimeStyles.None, out fecha))
            {
                return fecha.Date;
            }
            return null;
        }

        /// <summary>Devuelve el peso como double; Double.NaN si el texto no es un peso válido.</summary>
        private static double LeerPeso(string valor)
        {
            if (valor == null || valor.Length == 0)
            {
                return 0;
            }
            double peso;
            return double.TryParse(valor.Replace(',', '.'),
                NumberStyles.Float, CultureInfo.InvariantCulture, out peso)
                ? peso
                : double.NaN;
        }

        /// <summary>Devuelve el entero del texto, o el valor por defecto si no se puede leer.</summary>
        private static int LeerEntero(string valor, int defecto)
        {
            if (valor == null || valor.Length == 0)
            {
                return defecto;
            }
            int entero;
            return int.TryParse(valor, out entero) ? entero : defecto;
        }

        private static string TextoSeguro(string[] valores, int indice)
        {
            return indice < valores.Length && valores[indice] != null ? valores[indice].Trim() : "";
        }

        private string Valor(string nombre)
        {
            string valor = Request.Form[nombre];
            return valor == null ? "" : valor.Trim();
        }
    }
}
