using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.Mvc;
using WebConMVCDotnet.App_Start;
using WebConMVCDotnet.Models;

namespace WebConMVCDotnet.Controllers
{
    /// <summary>
    /// Controlador del CRUD de CARGO (tabla PECAR_CARGO del diagrama de
    /// Personal). Equivalente al CargoController del proyecto Java.
    ///
    /// La clave primaria es compuesta (PEDEP_CODIGO, PECAR_CODIGO):
    /// al editar se conservan departamento y código, y únicamente cambia
    /// la descripción. Incluye el buscador por departamento que conserva
    /// el filtro tras guardar, eliminar o corregir un error.
    ///
    /// Acciones:
    ///   Index  (GET)  listado + formulario nuevo.
    ///   Editar (GET)  formulario precargado (departamento + código).
    ///   Guardar  (POST) inserta o actualiza.
    ///   Eliminar (POST) elimina por la clave compuesta.
    ///
    /// Tras las operaciones POST se aplica el patrón
    /// POST-Redirect-GET y los mensajes viajan como TempData (flash).
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
            return VistaListado(Normalizar(filtroDepartamento), null, false);
        }

        [HttpGet]
        public ActionResult Editar(string departamento, string codigo, string filtroDepartamento)
        {
            CargarMensajesFlash();
            string filtro = Normalizar(filtroDepartamento);
            departamento = Normalizar(departamento);
            codigo = Normalizar(codigo);

            Cargo cargo = null;
            try
            {
                cargo = departamento.Length > 0 && codigo.Length > 0
                    ? cargoRepository.BuscarPorCodigo(departamento, codigo)
                    : null;
            }
            catch (Exception)
            {
                TempData[FlashError] = MensajeConexion();
                return RedirigirListado(filtro);
            }

            if (cargo == null)
            {
                TempData[FlashError] = "No se encontró el cargo solicitado.";
                return RedirigirListado(filtro);
            }

            return VistaListado(filtro, cargo, true);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Guardar(string modo, string filtroDepartamento,
            string departamento, string codigo, string descripcion)
        {
            string filtro = Normalizar(filtroDepartamento);
            string dep = Normalizar(departamento);
            string cod = Normalizar(codigo);
            string descri = Normalizar(descripcion);
            bool edicion = "editar".Equals(Normalizar(modo), StringComparison.OrdinalIgnoreCase);

            try
            {
                if (dep.Length != 3 || cod.Length != 3)
                {
                    return DevolverFormulario(filtro, new Cargo(dep, cod, descri), edicion,
                        "El departamento y el código del cargo deben tener exactamente 3 caracteres.");
                }
                if (descri.Length == 0 || descri.Length > 50)
                {
                    return DevolverFormulario(filtro, new Cargo(dep, cod, descri), edicion,
                        "Ingrese una descripción de entre 1 y 50 caracteres.");
                }

                Cargo cargo = new Cargo(dep, cod, descri);

                try
                {
                    if (!departamentoRepository.Existe(dep))
                    {
                        return DevolverFormulario(filtro, cargo, edicion,
                            "El departamento seleccionado ya no existe.");
                    }
                    if (edicion)
                    {
                        if (!cargoRepository.Existe(dep, cod))
                        {
                            return DevolverFormulario(filtro, cargo, edicion,
                                "El cargo que intenta editar ya no existe.");
                        }
                        if (!cargoRepository.Actualizar(cargo))
                        {
                            return DevolverFormulario(filtro, cargo, edicion,
                                "No se pudo guardar: el registro ya no existe o no se modificó.");
                        }
                    }
                    else
                    {
                        if (cargoRepository.Existe(dep, cod))
                        {
                            return DevolverFormulario(filtro, cargo, edicion,
                                "Ya existe ese código de cargo en el departamento seleccionado.");
                        }
                        if (!cargoRepository.Insertar(cargo))
                        {
                            return DevolverFormulario(filtro, cargo, edicion,
                                "No se pudo guardar: el registro ya no existe o no se modificó.");
                        }
                    }
                }
                catch (SqlException ex)
                {
                    return DevolverFormulario(filtro, cargo, edicion, MensajeBaseDatos(ex, "guardar"));
                }
                catch (Exception)
                {
                    return DevolverFormulario(filtro, cargo, edicion, MensajeConexion());
                }

                TempData[FlashExito] = "Cargo guardado correctamente.";
                return RedirigirListado(filtro);
            }
            catch (Exception)
            {
                return DevolverFormulario(filtro, new Cargo(dep, cod, descri), edicion,
                    "No se pudo procesar la operación.");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Eliminar(string filtroDepartamento, string departamento, string codigo)
        {
            string filtro = Normalizar(filtroDepartamento);
            string dep = Normalizar(departamento);
            string cod = Normalizar(codigo);
            try
            {
                if (dep.Length == 0 || cod.Length == 0)
                {
                    TempData[FlashError] = "Indique el departamento y el código del cargo a eliminar.";
                    return RedirigirListado(filtro);
                }

                if (cargoRepository.Eliminar(dep, cod))
                {
                    TempData[FlashExito] = "Cargo eliminado correctamente.";
                }
                else
                {
                    TempData[FlashError] = "El cargo que intenta eliminar ya no existe.";
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

            return RedirigirListado(filtro);
        }

        // ----- Métodos privados de apoyo -----

        /// <summary>
        /// Prepara la vista: en edición conserva el cargo indicado; en el
        /// resto de casos usa un formulario vacío cuyo departamento inicial
        /// es el del filtro de búsqueda.
        /// </summary>
        private ViewResult VistaListado(string filtro, Cargo cargo, bool edicion)
        {
            bool sinFiltro = string.IsNullOrEmpty(filtro);
            ViewBag.Cargos = sinFiltro ? cargoRepository.Listar() : cargoRepository.ListarPorDepartamento(filtro);
            ViewBag.Departamentos = departamentoRepository.Listar();
            ViewBag.FiltroDepartamento = filtro ?? string.Empty;
            ViewBag.Cargo = cargo ?? FormularioPorDefecto(filtro);
            ViewBag.ModoEdicion = edicion;
            return View("Index");
        }

        private ActionResult DevolverFormulario(string filtro, Cargo cargo, bool edicion, string error)
        {
            ViewBag.ModoEdicion = edicion;
            ViewBag.Cargo = cargo;
            ViewBag.FiltroDepartamento = filtro ?? string.Empty;
            try
            {
                ViewBag.Cargos = string.IsNullOrEmpty(filtro)
                    ? cargoRepository.Listar()
                    : cargoRepository.ListarPorDepartamento(filtro);
                ViewBag.Departamentos = departamentoRepository.Listar();
            }
            catch (Exception)
            {
                // Forward directo: una caída de SQL Server no produce bucles de redirección.
                ViewBag.Cargos = new List<Cargo>();
                ViewBag.Departamentos = new List<Departamento>();
            }
            ViewBag.MensajeError = error;
            return View("Index");
        }

        private static Cargo FormularioPorDefecto(string filtro)
        {
            return new Cargo(filtro, string.Empty, string.Empty);
        }

        private ActionResult RedirigirListado(string filtro)
        {
            if (string.IsNullOrEmpty(filtro))
            {
                return RedirectToAction("Index");
            }
            return RedirectToAction("Index", new { filtroDepartamento = filtro });
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
        /// Traduce los errores de base de datos más comunes del CRUD:
        /// duplicados de clave primaria y violaciones de llave foránea.
        /// </summary>
        private static string MensajeBaseDatos(SqlException ex, string operacion)
        {
            if (ex.Number == 2601 || ex.Number == 2627)
            {
                return "Ya existe ese código de cargo en ese departamento.";
            }
            if (ex.Number == 547)
            {
                if ("eliminar".Equals(operacion, StringComparison.OrdinalIgnoreCase))
                {
                    return "No se puede eliminar el cargo porque está vinculado a otros registros.";
                }
                return "El departamento seleccionado ya no existe.";
            }
            return "No se pudo completar la operación. Revise la conexión y las tablas de Personal.";
        }
    }
}
