using System;
using System.Data.SqlClient;
using System.Web.Mvc;
using WebConMVCDotnet.App_Start;
using WebConMVCDotnet.Models;

namespace WebConMVCDotnet.Controllers
{
    /// <summary>
    /// Controlador del CRUD de CARGO (tabla PECAR_CARGO del diagrama de
    /// Personal). Clave compuesta: departamento (PEDEP_CODIGO) + cargo
    /// (PECAR_CODIGO). Equivalente al CargoController del proyecto Java.
    ///
    /// Acciones:
    ///   Index  (GET) listado, con filtro opcional por departamento.
    ///   Nuevo  (GET) formulario vacío.
    ///   Editar (GET) formulario precargado con (departamento, codigo).
    ///   Guardar  (POST) inserta o actualiza (solo la descripción).
    ///   Eliminar (POST) elimina por la clave compuesta.
    ///
    /// Misma política de acceso, CSRF y POST-Redirect-GET que
    /// DepartamentoController; los mensajes viajan como TempData (flash).
    /// </summary>
    [FiltroAutenticacion]
    public class CargoController : Controller
    {
        private readonly CargoRepository cargoRepository = new CargoRepository();
        private readonly DepartamentoRepository departamentoRepository = new DepartamentoRepository();

        private const string FlashExito = "CargoMensajeExito";
        private const string FlashError = "CargoMensajeError";

        [HttpGet]
        public ActionResult Index(string filtroDepartamento)
        {
            CargarMensajesFlash();
            ViewBag.FiltroDepartamento = Normalizar(filtroDepartamento);
            return VistaListado();
        }

        [HttpGet]
        public ActionResult Nuevo(string filtroDepartamento)
        {
            CargarMensajesFlash();
            ViewBag.FiltroDepartamento = Normalizar(filtroDepartamento);
            ViewBag.ModoEdicion = false;
            ViewBag.DepartamentoSeleccionado = string.Empty;
            ViewBag.Cargo = new Cargo();
            ViewBag.Departamentos = departamentoRepository.Listar();
            CargarListadoCargos();
            return View("Index");
        }

        [HttpGet]
        public ActionResult Editar(string departamento, string codigo, string filtroDepartamento)
        {
            CargarMensajesFlash();
            string dep = Normalizar(departamento);
            string cod = Normalizar(codigo);
            ViewBag.FiltroDepartamento = Normalizar(filtroDepartamento);

            Cargo cargo = null;
            try
            {
                cargo = dep.Length == 0 || cod.Length == 0
                    ? null
                    : cargoRepository.BuscarPorCodigo(dep, cod);
            }
            catch (Exception)
            {
                TempData[FlashError] = "No se pudo conectar con la base de datos. "
                    + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.";
                return RedirectToAction("Index");
            }

            if (cargo == null)
            {
                TempData[FlashError] = "No se encontró el cargo solicitado.";
                return RedirectToAction("Index");
            }

            ViewBag.ModoEdicion = true;
            ViewBag.DepartamentoSeleccionado = cargo.CodigoDepart;
            ViewBag.Cargo = cargo;
            ViewBag.Departamentos = departamentoRepository.Listar();
            CargarListadoCargos();
            return View("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Guardar(string filtroDepartamento, string modo,
            string txtDepartamento, string txtCodigo, string txtDescripcion,
            string originalDepartamento, string originalCodigo)
        {
            string filtro = Normalizar(filtroDepartamento);
            bool esEdicion = "editar".Equals(Normalizar(modo), StringComparison.OrdinalIgnoreCase);

            // En edición, la clave viaja bloqueada; en creación viene del combobox/campo.
            string departamento = esEdicion ? Normalizar(originalDepartamento) : Normalizar(txtDepartamento);
            string codigo = esEdicion ? Normalizar(originalCodigo) : Normalizar(txtCodigo);
            string descri = Normalizar(txtDescripcion);
            var formulario = new Cargo(departamento, codigo, descri);
            ViewBag.FiltroDepartamento = filtro;

            try
            {
                if (departamento.Length != 3 || codigo.Length != 3)
                {
                    return DevolverFormulario(formulario, filtro, esEdicion,
                        "El departamento y el código del cargo deben tener exactamente 3 caracteres.");
                }
                if (descri.Length == 0 || descri.Length > 50)
                {
                    return DevolverFormulario(formulario, filtro, esEdicion,
                        "Ingrese una descripción de entre 1 y 50 caracteres.");
                }

                try
                {
                    if (!esEdicion)
                    {
                        if (!departamentoRepository.Existe(departamento))
                        {
                            return DevolverFormulario(formulario, filtro, esEdicion,
                                "El departamento seleccionado ya no existe.");
                        }
                        if (cargoRepository.Existe(departamento, codigo))
                        {
                            return DevolverFormulario(formulario, filtro, esEdicion,
                                "Ya existe ese código de cargo en el departamento seleccionado.");
                        }
                        cargoRepository.Insertar(formulario);
                        TempData[FlashExito] = "Cargo " + codigo + " creado correctamente.";
                    }
                    else
                    {
                        if (!cargoRepository.Existe(departamento, codigo))
                        {
                            return DevolverFormulario(formulario, filtro, esEdicion,
                                "El cargo que intenta editar ya no existe.");
                        }
                        if (!cargoRepository.Actualizar(formulario))
                        {
                            return DevolverFormulario(formulario, filtro, esEdicion,
                                "No se pudo guardar: el registro ya no existe o no se modificó.");
                        }
                        TempData[FlashExito] = "Cargo " + codigo + " actualizado correctamente.";
                    }
                }
                catch (SqlException ex)
                {
                    return DevolverFormulario(formulario, filtro, esEdicion, MensajeBaseDatos(ex));
                }
                catch (Exception)
                {
                    return DevolverFormulario(formulario, filtro, esEdicion,
                        "No se pudo conectar con la base de datos. "
                        + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.");
                }

                return RedirectToAction("Index", new { filtroDepartamento = filtro });
            }
            catch (Exception)
            {
                return DevolverFormulario(formulario, filtro, esEdicion,
                    "No se pudo procesar la operación.");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Eliminar(string departamento, string codigo, string filtroDepartamento)
        {
            string dep = Normalizar(departamento);
            string cod = Normalizar(codigo);
            string filtro = Normalizar(filtroDepartamento);
            try
            {
                if (dep.Length == 0 || cod.Length == 0)
                {
                    TempData[FlashError] = "Indique el departamento y el código del cargo a eliminar.";
                    return RedirectToAction("Index", new { filtroDepartamento = filtro });
                }

                if (cargoRepository.Eliminar(dep, cod))
                {
                    TempData[FlashExito] = "Cargo " + cod + " eliminado correctamente.";
                }
                else
                {
                    TempData[FlashError] = "El cargo que intenta eliminar ya no existe.";
                }
            }
            catch (SqlException ex)
            {
                TempData[FlashError] = MensajeBaseDatos(ex);
            }
            catch (Exception)
            {
                TempData[FlashError] = "No se pudo conectar con la base de datos. "
                    + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.";
            }

            return RedirectToAction("Index", new { filtroDepartamento = filtro });
        }

        private ActionResult DevolverFormulario(Cargo cargo, string filtro, bool esEdicion, string error)
        {
            ViewBag.FiltroDepartamento = filtro;
            ViewBag.ModoEdicion = esEdicion;
            ViewBag.DepartamentoSeleccionado = esEdicion ? cargo.CodigoDepart : string.Empty;
            ViewBag.Cargo = cargo;
            ViewBag.MensajeError = error;
            ViewBag.Departamentos = departamentoRepository.Listar();
            CargarListadoCargos();
            return View("Index");
        }

        private ViewResult VistaListado()
        {
            ViewBag.ModoEdicion = ViewBag.ModoEdicion ?? false;
            if (ViewBag.FiltroDepartamento == null)
            {
                ViewBag.FiltroDepartamento = string.Empty;
            }
            if (ViewBag.DepartamentoSeleccionado == null)
            {
                ViewBag.DepartamentoSeleccionado = string.Empty;
            }
            if (ViewBag.Cargo == null)
            {
                ViewBag.Cargo = new Cargo();
            }
            ViewBag.Departamentos = departamentoRepository.Listar();
            CargarListadoCargos();
            return View("Index");
        }

        /// <summary>Carga el listado de cargos aplicando el filtro de departamento activo.</summary>
        private void CargarListadoCargos()
        {
            string filtro = ViewBag.FiltroDepartamento as string ?? string.Empty;
            ViewBag.Cargos = filtro.Length == 0
                ? cargoRepository.Listar()
                : cargoRepository.ListarPorDepartamento(filtro);
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

        /// <summary>
        /// Traduce los errores de base de datos más comunes del CRUD:
        /// duplicados de clave y llaves que restringen eliminar o insertar.
        /// Equivalente a mensajeBD del CargoController de Java.
        /// </summary>
        private static string MensajeBaseDatos(SqlException ex)
        {
            if (ex.Number == 2601 || ex.Number == 2627)
            {
                return "Ya existe ese código de cargo en ese departamento.";
            }
            if (ex.Number == 547)
            {
                string mensaje = ex.Message.ToUpperInvariant();
                if (mensaje.Contains("DELETE"))
                {
                    return "No se puede eliminar el cargo porque está vinculado a otros registros.";
                }
                return "El departamento seleccionado ya no existe.";
            }
            return "No se pudo completar la operación. Revise la conexión y las tablas de Personal.";
        }

        private static string Normalizar(string valor)
        {
            return valor == null ? "" : valor.Trim();
        }
    }
}
