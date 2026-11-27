using System;
using System.Data.SqlClient;
using System.Web.Mvc;
using WebConMVCDotnet.App_Start;
using WebConMVCDotnet.Models;

namespace WebConMVCDotnet.Controllers
{
    /// <summary>
    /// Controlador del CRUD de CARGOS por clave compuesta
    /// (PEDEP_CODIGO, PECAR_CODIGO). Equivalente al CargoController del
    /// proyecto Java. Misma política de acceso que Departamentos.
    ///
    /// Acciones:
    ///   Index  (GET)  listado con buscador por departamento (filtro).
    ///   Editar (GET)  formulario precargado conservando el filtro.
    ///   Guardar  (POST) inserta o actualiza.
    ///   Eliminar (POST) elimina por clave compuesta.
    ///
    /// Tras las operaciones POST se aplica el patrón POST-Redirect-GET y los
    /// mensajes viajan como TempData (flash).
    /// </summary>
    [FiltroAutenticacion]
    public class CargoController : Controller
    {
        private const string FlashExito = "CargoMensajeExito";
        private const string FlashError = "CargoMensajeError";

        private readonly CargoRepository cargoRepository = new CargoRepository();
        private readonly DepartamentoRepository departamentoRepository = new DepartamentoRepository();

        [HttpGet]
        public ActionResult Index(string filtroDepartamento)
        {
            CargarMensajesFlash();
            return Mostrar(Normalizar(filtroDepartamento), null, false, null);
        }

        /// <summary>
        /// Acción editar: carga el cargo indicado y muestra el formulario
        /// precargado conservando el filtro de departamento.
        /// </summary>
        [HttpGet]
        public ActionResult Editar(string departamento, string codigo, string filtroDepartamento)
        {
            CargarMensajesFlash();
            string filtro = Normalizar(filtroDepartamento);

            try
            {
                Cargo cargo = cargoRepository.BuscarPorCodigo(Normalizar(departamento), Normalizar(codigo));
                if (cargo == null)
                {
                    TempData[FlashError] = "No se encontró el cargo solicitado.";
                    return Redirect(UrlListado(filtro));
                }
                return Mostrar(filtro, cargo, true, null);
            }
            catch (Exception)
            {
                return Fallo(filtro);
            }
        }

        /// <summary>Acción guardar: valida los datos e inserta o actualiza el cargo.</summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Guardar(string departamento, string codigo, string descripcion,
            string modo, string filtroDepartamento)
        {
            string dep = Normalizar(departamento);
            string cod = Normalizar(codigo);
            string descri = Normalizar(descripcion);
            string filtro = Normalizar(filtroDepartamento);
            bool edicion = string.Equals(modo, "editar", StringComparison.Ordinal);

            // La acción "nuevo" solo es válida cuando no es edición (igual que en Java).
            if (!string.Equals(modo, "nuevo", StringComparison.Ordinal) && !edicion)
            {
                return new HttpStatusCodeResult(400, "Solicitud inválida.");
            }

            string error = null;
            try
            {
                if (dep.Length != 3 || cod.Length != 3)
                {
                    error = "El departamento y el código del cargo deben tener exactamente 3 caracteres.";
                }
                else if (descri.Length == 0 || descri.Length > 50)
                {
                    error = "Ingrese una descripción de entre 1 y 50 caracteres.";
                }
                else if (!departamentoRepository.Existe(dep))
                {
                    error = "El departamento seleccionado ya no existe.";
                }
                else if (edicion && !cargoRepository.Existe(dep, cod))
                {
                    error = "El cargo que intenta editar ya no existe.";
                }
                else if (!edicion && cargoRepository.Existe(dep, cod))
                {
                    error = "Ya existe ese código de cargo en el departamento seleccionado.";
                }
                else
                {
                    bool guardado = edicion
                        ? cargoRepository.Actualizar(Form(dep, cod, descri))
                        : cargoRepository.Insertar(Form(dep, cod, descri));
                    if (!guardado)
                    {
                        error = "No se pudo guardar: el registro ya no existe o no se modificó.";
                    }
                }
            }
            catch (SqlException ex)
            {
                error = MensajeBaseDatos(ex);
            }
            catch (Exception)
            {
                error = "No se pudo conectar con la base de datos. "
                    + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.";
            }

            if (error != null)
            {
                return Mostrar(filtro, Form(dep, cod, descri), edicion, error);
            }

            TempData[FlashExito] = "Cargo guardado correctamente.";
            return Redirect(UrlListado(filtro));
        }

        /// <summary>Acción eliminar: borra el cargo por su clave compuesta.</summary>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Eliminar(string departamento, string codigo, string filtroDepartamento)
        {
            string dep = Normalizar(departamento);
            string cod = Normalizar(codigo);
            string filtro = Normalizar(filtroDepartamento);

            try
            {
                if (!cargoRepository.Eliminar(dep, cod))
                {
                    TempData[FlashError] = "El cargo que intenta eliminar ya no existe.";
                    return Redirect(UrlListado(filtro));
                }
                TempData[FlashExito] = "Cargo eliminado correctamente.";
                return Redirect(UrlListado(filtro));
            }
            catch (SqlException ex)
            {
                return Mostrar(filtro, null, false, MensajeBaseDatos(ex));
            }
            catch (Exception)
            {
                return Fallo(filtro);
            }
        }

        /// <summary>
        /// Muestra la vista con el listado y el filtro actual conservando, si
        /// viene, el formulario digitado y un mensaje de error de validación.
        /// </summary>
        private ActionResult Mostrar(string filtro, Cargo formulario, bool modoEdicion, string mensajeError)
        {
            ViewBag.FiltroDepartamento = filtro;
            ViewBag.Cargo = formulario ?? new Cargo(filtro, string.Empty, string.Empty);
            ViewBag.ModoEdicion = modoEdicion;
            if (mensajeError != null)
            {
                ViewBag.MensajeError = mensajeError;
            }

            try
            {
                ViewBag.Departamentos = departamentoRepository.Listar();
                ViewBag.Cargos = string.IsNullOrEmpty(filtro)
                    ? cargoRepository.Listar()
                    : cargoRepository.ListarPorDepartamento(filtro);
                ViewBag.DatosNoDisponibles = false;
            }
            catch (Exception)
            {
                // Forward directo: una caída de SQL Server no produce un bucle
                // de redirecciones.
                ViewBag.DatosNoDisponibles = true;
                ViewBag.Cargos = new System.Collections.Generic.List<Cargo>();
                ViewBag.MensajeError = "No se pudieron cargar los datos. Revise SQL Server, "
                    + "la cadena de conexión en Web.config y las tablas de Personal.";
                Response.StatusCode = (int)System.Net.HttpStatusCode.ServiceUnavailable;
            }

            return View("Index");
        }

        // Vista de datos no disponibles con estado 503 (equivalente a fallo() en Java).
        private ActionResult Fallo(string filtro)
        {
            return Mostrar(filtro, null, false, null);
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

        private string UrlListado(string filtro)
        {
            return string.IsNullOrEmpty(filtro)
                ? Url.Action("Index", "Cargo")
                : Url.Action("Index", "Cargo", new { filtroDepartamento = filtro });
        }

        private Cargo Form(string dep, string cod, string descri)
        {
            return new Cargo(dep, cod, descri);
        }

        private static string Normalizar(string valor)
        {
            return valor == null ? "" : valor.Trim();
        }

        /// <summary>
        /// Traduce los errores de base de datos más comunes del CRUD a mensajes
        /// entendibles: duplicados de clave (2601/2627) y llaves foráneas (547).
        /// En SQL Server el error 547 se usa tanto al insertar como al eliminar,
        /// por eso se distingue por el texto de la sentencia.
        /// </summary>
        private static string MensajeBaseDatos(SqlException ex)
        {
            if (ex.Number == 2601 || ex.Number == 2627)
            {
                return "Ya existe ese código de cargo en ese departamento.";
            }
            if (ex.Number == 547)
            {
                string mensaje = ex.Message != null ? ex.Message.ToUpperInvariant() : string.Empty;
                if (mensaje.Contains("DELETE"))
                {
                    return "No se puede eliminar el cargo porque está vinculado a otros registros.";
                }
                return "El departamento seleccionado ya no existe.";
            }
            return "Error de base de datos: " + ex.Message;
        }
    }
}
