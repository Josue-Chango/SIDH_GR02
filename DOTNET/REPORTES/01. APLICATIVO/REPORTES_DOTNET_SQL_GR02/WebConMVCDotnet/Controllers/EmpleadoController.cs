using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.Mvc;
using WebConMVCDotnet.App_Start;
using WebConMVCDotnet.Models;

namespace WebConMVCDotnet.Controllers
{
    /// <summary>
    /// Mantenimiento de Empleados con Tab Page (réplica del Tab Page del
    /// proyecto Java). La ficha tiene un marco superior con foto, apellidos
    /// y nombres, y tres pestañas: Datos Generales, Datos Académicos
    /// (subtabla) y Datos Familiares (subtabla).
    ///
    /// Misma política de acceso, CSRF y POST-Redirect-GET que CargoController.
    /// Equivalente al EmpleadoController del proyecto Java.
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
        public ActionResult Index(string accion, string codigo)
        {
            CargarMensajesFlash();
            PrepararListado();

            if ("editar".Equals(accion, StringComparison.OrdinalIgnoreCase)
                && !string.IsNullOrWhiteSpace(codigo))
            {
                Empleado empleado;
                try
                {
                    empleado = empleadoRepository.BuscarPorCodigo(codigo.Trim());
                }
                catch (Exception)
                {
                    ViewBag.MensajeError = "No se pudo conectar con la base de datos. "
                        + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.";
                    return View("Index");
                }

                if (empleado == null)
                {
                    ViewBag.MensajeError = "No se encontró el empleado solicitado.";
                }
                else
                {
                    ViewBag.Empleado = empleado;
                    ViewBag.ModoEdicion = true;
                }
            }
            else if (!string.IsNullOrEmpty(accion)
                     && !"listar".Equals(accion, StringComparison.OrdinalIgnoreCase)
                     && !"nuevo".Equals(accion, StringComparison.OrdinalIgnoreCase))
            {
                return new HttpStatusCodeResult(400);
            }

            return View("Index");
        }

        /// <summary>Acción guardar: valida e inserta o actualiza la ficha completa.</summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Guardar(string modo, string txtCodigo, string txtApellidos,
            string txtNombres, string txtFechaNacimiento, string cboGenero, string cboEstadoCivil,
            string txtPeso, string txtTipoSangre, string fotoActual, HttpPostedFileBase foto,
            string[] acaNivel, string[] acaInstitucion, string[] acaTitulo,
            string[] famPersona, string[] famNombres, string[] famFecha)
        {
            bool edicion = "editar".Equals(Normalizar(modo), StringComparison.OrdinalIgnoreCase);
            if (!"nuevo".Equals(Normalizar(modo), StringComparison.OrdinalIgnoreCase) && !edicion)
            {
                return new HttpStatusCodeResult(400);
            }

            var empleado = new Empleado
            {
                Codigo = Normalizar(txtCodigo),
                Apellidos = Normalizar(txtApellidos),
                Nombres = Normalizar(txtNombres),
                FechaNacimiento = LeerFecha(txtFechaNacimiento),
                CodigoGenero = Normalizar(cboGenero),
                CodigoEstadoCivil = Normalizar(cboEstadoCivil),
                Peso = LeerPeso(txtPeso),
                TipoSangre = Normalizar(txtTipoSangre).ToUpperInvariant(),
                // Si no se sube una foto nueva, se conserva la ruta actual de la ficha.
                Foto = Normalizar(fotoActual),
                Academicos = LeerAcademicos(acaNivel, acaInstitucion, acaTitulo),
                Familiares = LeerFamiliares(famPersona, famNombres, famFecha)
            };

            try
            {
                string error = Validar(empleado, edicion);
                if (error == null)
                {
                    try
                    {
                        GuardarArchivoFoto(foto, empleado);
                    }
                    catch (IOException)
                    {
                        error = "No se pudo guardar la foto indicada. Revise el formato (JPG o PNG).";
                    }
                    catch (ArgumentException)
                    {
                        error = "No se pudo guardar la foto indicada. Revise el formato (JPG o PNG).";
                    }
                }

                if (error == null)
                {
                    bool guardado = edicion
                        ? empleadoRepository.Actualizar(empleado)
                        : empleadoRepository.Insertar(empleado);
                    if (!guardado)
                    {
                        error = "No se pudo guardar: el empleado ya no existe o no se modificó.";
                    }
                }

                if (error != null)
                {
                    return MostrarConFormulario(empleado, edicion, error);
                }

                TempData[FlashExito] = "Ficha del empleado guardada correctamente.";
                return RedirectToAction("Index");
            }
            catch (SqlException ex)
            {
                return MostrarConFormulario(empleado, edicion, MensajeBaseDatos(ex));
            }
            catch (Exception)
            {
                return MostrarConFormulario(empleado, edicion,
                    "No se pudo conectar con la base de datos. "
                    + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.");
            }
        }

        /// <summary>Acción eliminar: borra la ficha y su foto.</summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Eliminar(string codigo)
        {
            string cod = Normalizar(codigo);
            try
            {
                if (!empleadoRepository.Eliminar(cod))
                {
                    return Mostrar("El empleado que intenta eliminar ya no existe.");
                }
                EliminarArchivoFoto(cod);
                TempData[FlashExito] = "Empleado eliminado correctamente.";
                return RedirectToAction("Index");
            }
            catch (SqlException ex)
            {
                return Mostrar(MensajeBaseDatos(ex));
            }
            catch (Exception)
            {
                return Mostrar("No se pudo conectar con la base de datos. "
                    + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.");
            }
        }

        /// <summary>Muestra la vista con el listado completo.</summary>
        private ActionResult Mostrar(string mensajeError)
        {
            CargarMensajesFlash();
            PrepararListado();
            ViewBag.MensajeError = mensajeError;
            return View("Index");
        }

        /// <summary>
        /// Muestra la vista conservando lo digitado en el formulario y un mensaje
        /// de error de validación.
        /// </summary>
        private ActionResult MostrarConFormulario(Empleado formulario, bool edicion, string error)
        {
            CargarMensajesFlash();
            PrepararListado();
            ViewBag.Empleado = formulario;
            ViewBag.ModoEdicion = edicion;
            ViewBag.MensajeError = error;
            return View("Index");
        }

        private void PrepararListado()
        {
            ViewBag.ModoEdicion = ViewBag.ModoEdicion ?? false;
            if (ViewBag.Empleado == null)
            {
                ViewBag.Empleado = new Empleado();
            }
            ViewBag.Empleados = empleadoRepository.Listar();
            ViewBag.Generos = empleadoRepository.ListarGeneros();
            ViewBag.EstadosCiviles = empleadoRepository.ListarEstadosCiviles();
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

        // ------------------------------------------------------------------
        // Lectura de las subtablas del formulario (pestañas 2 y 3)
        // ------------------------------------------------------------------

        /// <summary>
        /// Lee la subtabla de Datos Académicos. Las filas completamente vacías
        /// se descartan; las incompletas se conservan para que Validar() pida
        /// completarlas.
        /// </summary>
        private static List<EmpleadoAcademico> LeerAcademicos(
            string[] niveles, string[] instituciones, string[] titulos)
        {
            var academicos = new List<EmpleadoAcademico>();
            int total = Math.Max(Math.Max(Tamano(niveles), Tamano(instituciones)), Tamano(titulos));
            for (int i = 0; i < total; i++)
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
        private static List<EmpleadoFamiliar> LeerFamiliares(
            string[] personas, string[] nombres, string[] fechas)
        {
            var familiares = new List<EmpleadoFamiliar>();
            int total = Math.Max(Math.Max(Tamano(personas), Tamano(nombres)), Tamano(fechas));
            for (int i = 0; i < total; i++)
            {
                string persona = TextoSeguro(personas, i);
                string nombre = TextoSeguro(nombres, i);
                string fecha = TextoSeguro(fechas, i);
                if (persona.Length == 0 && nombre.Length == 0 && fecha.Length == 0)
                {
                    continue; // Fila vacía: no se guarda.
                }
                familiares.Add(new EmpleadoFamiliar(persona, nombre, LeerFecha(fecha)));
            }
            return familiares;
        }

        // ------------------------------------------------------------------
        // Reglas de negocio de la ficha
        // ------------------------------------------------------------------

        /// <summary>Aplica las reglas de negocio de la ficha. Devuelve null si todo está bien.</summary>
        private string Validar(Empleado empleado, bool edicion)
        {
            if (empleado.Codigo.Length == 0 || !System.Text.RegularExpressions.Regex.IsMatch(
                    empleado.Codigo, "^[A-Za-z0-9-]{1,10}$"))
            {
                return "Ingrese un código de hasta 10 letras, números o guiones (por ejemplo, P000000001).";
            }
            if (empleado.Apellidos.Length == 0 || empleado.Apellidos.Length > 50)
            {
                return "Ingrese los apellidos del empleado (entre 1 y 50 caracteres).";
            }
            if (empleado.Nombres.Length == 0 || empleado.Nombres.Length > 50)
            {
                return "Ingrese los nombres del empleado (entre 1 y 50 caracteres).";
            }
            if (empleado.FechaNacimiento == null || empleado.FechaNacimiento > DateTime.Today)
            {
                return "Ingrese una fecha de nacimiento válida (no puede ser futura).";
            }
            if (empleado.CodigoGenero.Length == 0)
            {
                return "Seleccione el sexo del empleado.";
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
                    || familiar.FechaNacimiento == null)
                {
                    return "En Datos Familiares complete persona, apellidos y nombres, y fecha de "
                        + "nacimiento de cada fila, o deje la fila vacía para descartarla.";
                }
                if (familiar.Nombres.Length > 100)
                {
                    return "En Datos Familiares los apellidos y nombres no pueden superar 100 caracteres.";
                }
            }
            if (edicion && !empleadoRepository.Existe(empleado.Codigo))
            {
                return "El empleado que intenta editar ya no existe.";
            }
            if (!edicion && empleadoRepository.Existe(empleado.Codigo))
            {
                return "Ya existe una persona registrada con ese código.";
            }
            return null;
        }

        // ------------------------------------------------------------------
        // Foto de la ficha
        // ------------------------------------------------------------------

        /// <summary>
        /// Guarda la foto subida en ~/resource/fotos_empleados/{codigo}.{ext}.
        /// Solo se aceptan JPG y PNG (se comprueba la firma del archivo); la ruta
        /// relativa se deja en el empleado para que la vista la muestre como foto
        /// de perfil y el reporte la pueda cargar.
        /// </summary>
        private void GuardarArchivoFoto(HttpPostedFileBase foto, Empleado empleado)
        {
            if (foto == null || foto.ContentLength == 0)
            {
                return; // Sin foto nueva: se conserva la actual.
            }

            string extension = DetectarExtension(foto);
            if (extension.Length == 0)
            {
                throw new IOException("El archivo adjuntado no es una imagen válida (JPG o PNG).");
            }

            string carpeta = Server.MapPath(CarpetaFotos);
            if (!Directory.Exists(carpeta))
            {
                Directory.CreateDirectory(carpeta);
            }

            string destino = Path.Combine(carpeta, empleado.Codigo + extension);
            foto.SaveAs(destino);
            empleado.Foto = "fotos_empleados/" + Path.GetFileName(destino);
        }

        /// <summary>Comprueba la firma binaria del archivo: JPG o PNG.</summary>
        private static string DetectarExtension(HttpPostedFileBase foto)
        {
            using (Stream flujo = foto.InputStream)
            {
                flujo.Position = 0;
                byte[] firma = new byte[8];
                int leidos = flujo.Read(firma, 0, firma.Length);
                flujo.Position = 0;
                if (leidos < 8)
                {
                    return "";
                }
                // JPEG: FF D8 FF
                if (firma[0] == 0xFF && firma[1] == 0xD8 && firma[2] == 0xFF)
                {
                    return ".jpg";
                }
                // PNG: 89 50 4E 47 0D 0A 1A 0A
                if (firma[0] == 0x89 && firma[1] == 0x50 && firma[2] == 0x4E && firma[3] == 0x47
                    && firma[4] == 0x0D && firma[5] == 0x0A && firma[6] == 0x1A && firma[7] == 0x0A)
                {
                    return ".png";
                }
                return "";
            }
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
                if (!Directory.Exists(carpeta))
                {
                    return;
                }
                foreach (string archivo in Directory.GetFiles(carpeta, codigo + ".*"))
                {
                    System.IO.File.Delete(archivo);
                }
            }
            catch (IOException)
            {
                // Limpieza secundaria: no interrumpe la operación principal.
            }
            catch (UnauthorizedAccessException)
            {
                // Limpieza secundaria: no interrumpe la operación principal.
            }
        }

        // ------------------------------------------------------------------
        // Utilidades
        // ------------------------------------------------------------------

        /// <summary>
        /// Traduce los errores de base de datos más comunes a mensajes entendibles:
        /// duplicados de clave (2601/2627) y llaves foráneas (547).
        /// Equivalente a mensajeBD de EmpleadoController.java.
        /// </summary>
        private static string MensajeBaseDatos(SqlException ex)
        {
            if (ex.Number == 2601 || ex.Number == 2627)
            {
                return "Ya existe una persona con ese código o cédula.";
            }
            if (ex.Number == 547)
            {
                string mensaje = ex.Message.ToUpperInvariant();
                if (mensaje.Contains("DELETE"))
                {
                    return "No se puede eliminar el empleado porque está vinculado a otros registros.";
                }
                return "El sexo o el estado civil seleccionado ya no existe en el catálogo.";
            }
            return "No se pudo completar la operación. Revise la conexión y la tabla PEPER_PERSO.";
        }

        private static string Normalizar(string valor)
        {
            return valor == null ? "" : valor.Trim();
        }

        private static DateTime? LeerFecha(string valor)
        {
            DateTime fecha;
            return DateTime.TryParse(valor, out fecha) ? fecha : (DateTime?)null;
        }

        /// <summary>Devuelve el peso como double; 0 si el texto no es un peso válido.</summary>
        private static double LeerPeso(string valor)
        {
            if (string.IsNullOrWhiteSpace(valor))
            {
                return 0;
            }
            double peso;
            return double.TryParse(valor.Replace(',', '.'), out peso) ? peso : 0;
        }

        private static int Tamano(string[] valores)
        {
            return valores != null ? valores.Length : 0;
        }

        private static string TextoSeguro(string[] valores, int indice)
        {
            return valores != null && indice < valores.Length && valores[indice] != null
                ? valores[indice].Trim()
                : "";
        }
    }
}
