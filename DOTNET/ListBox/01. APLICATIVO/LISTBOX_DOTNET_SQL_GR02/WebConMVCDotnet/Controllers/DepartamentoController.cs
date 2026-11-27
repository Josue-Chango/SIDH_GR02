using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.Mvc;
using WebConMVCDotnet.App_Start;
using WebConMVCDotnet.Models;

namespace WebConMVCDotnet.Controllers
{
    /// <summary>
    /// Controlador del CRUD de DEPARTAMENTO (tabla PEDEP_DEPAR del diagrama
    /// de Personal). Equivalente al DepartamentoController del proyecto Java.
    ///
    /// Acciones:
    ///   Index  (GET)  listado.
    ///   Nuevo  (GET)  formulario vacío.
    ///   Editar (GET)  formulario precargado con el código indicado.
    ///   Guardar  (POST) inserta o actualiza.
    ///   Eliminar (POST) elimina por código.
    ///
    /// Tras las operaciones POST se aplica el patrón
    /// POST-Redirect-GET y los mensajes viajan como TempData (flash).
    /// </summary>
    [FiltroAutenticacion]
    public class DepartamentoController : Controller
    {
        private readonly DepartamentoRepository departamentoRepository = new DepartamentoRepository();

        private const string FlashExito = "DepartamentoMensajeExito";
        private const string FlashError = "DepartamentoMensajeError";

        [HttpGet]
        public ActionResult Index()
        {
            CargarMensajesFlash();
            return VistaListado();
        }

        [HttpGet]
        public ActionResult Nuevo()
        {
            CargarMensajesFlash();
            ViewBag.ModoEdicion = false;
            ViewBag.CodigoOriginal = string.Empty;
            ViewBag.Departamento = new Departamento();
            ViewBag.Departamentos = departamentoRepository.Listar();
            return View("Index");
        }

        [HttpGet]
        public ActionResult Editar(string codigo)
        {
            CargarMensajesFlash();
            codigo = Normalizar(codigo);

            Departamento departamento = null;
            try
            {
                departamento = string.IsNullOrEmpty(codigo) ? null : departamentoRepository.BuscarPorCodigo(codigo);
            }
            catch (Exception)
            {
                TempData[FlashError] = "No se pudo conectar con la base de datos. "
                    + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.";
                return RedirectToAction("Index");
            }

            if (departamento == null)
            {
                TempData[FlashError] = "No se encontró el departamento solicitado.";
                return RedirectToAction("Index");
            }

            ViewBag.ModoEdicion = true;
            ViewBag.CodigoOriginal = departamento.CodigoDepart;
            ViewBag.Departamento = departamento;
            ViewBag.Departamentos = departamentoRepository.Listar();
            return View("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Guardar(string txtCodigo, string txtDescripcion, string codigoOriginal)
        {
            string codigo = Normalizar(txtCodigo);
            string descri = Normalizar(txtDescripcion);
            string original = Normalizar(codigoOriginal);
            try
            {
                if (codigo.Length == 0)
                {
                    return DevolverFormulario(Form(codigo, descri), original, "Ingrese el código del departamento.");
                }
                if (codigo.Length != 3)
                {
                    return DevolverFormulario(Form(codigo, descri), original,
                        "El código debe tener exactamente 3 caracteres (la columna PEDEP_CODIGO es CHAR(3)).");
                }
                if (descri.Length == 0)
                {
                    return DevolverFormulario(Form(codigo, descri), original, "Descripción del departamento inválida.");
                }
                if (descri.Length > 50)
                {
                    return DevolverFormulario(Form(codigo, descri), original, "Descripción del departamento máxima 50 caracteres.");
                }

                bool esEdicion = original.Length > 0;

                try
                {
                    if (!esEdicion)
                    {
                        if (departamentoRepository.Existe(codigo))
                        {
                            return DevolverFormulario(Form(codigo, descri), original,
                                "Ya existe un departamento con el código " + codigo + ".");
                        }
                        departamentoRepository.Insertar(Form(codigo, descri));
                        TempData[FlashExito] = "Departamento " + codigo + " creado correctamente.";
                    }
                    else
                    {
                        if (!string.Equals(codigo, original, StringComparison.OrdinalIgnoreCase)
                            && departamentoRepository.Existe(codigo))
                        {
                            return DevolverFormulario(Form(codigo, descri), original,
                                "Ya existe un departamento con el código " + codigo + ".");
                        }
                        bool actualizado = departamentoRepository.Actualizar(original, Form(codigo, descri));
                        if (!actualizado)
                        {
                            return DevolverFormulario(Form(codigo, descri), original,
                                "No se encontró el departamento con código " + original + ".");
                        }
                        TempData[FlashExito] = "Departamento " + codigo + " actualizado correctamente.";
                    }
                }
                catch (SqlException ex)
                {
                    return DevolverFormulario(Form(codigo, descri), original, MensajeBaseDatos(ex));
                }
                catch (Exception)
                {
                    return DevolverFormulario(Form(codigo, descri), original,
                        "No se pudo conectar con la base de datos. "
                        + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.");
                }

                return RedirectToAction("Index");
            }
            catch (Exception)
            {
                return DevolverFormulario(Form(codigo, descri), original,
                    "No se pudo procesar la operación.");
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
                    TempData[FlashError] = "Indique el código del departamento a eliminar.";
                    return RedirectToAction("Index");
                }

                if (departamentoRepository.Eliminar(cod))
                {
                    TempData[FlashExito] = "Departamento " + cod + " eliminado correctamente.";
                }
                else
                {
                    TempData[FlashError] = "No se encontró el departamento con código " + cod + ".";
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

            return RedirectToAction("Index");
        }

        private ActionResult DevolverFormulario(Departamento departamento, string codigoOriginal, string error)
        {
            bool esEdicion = !string.IsNullOrEmpty(codigoOriginal);
            ViewBag.ModoEdicion = esEdicion;
            ViewBag.CodigoOriginal = esEdicion ? codigoOriginal : string.Empty;
            ViewBag.Departamento = departamento;
            ViewBag.Departamentos = departamentoRepository.Listar();
            ViewBag.MensajeError = error;
            return View("Index");
        }

        private ViewResult VistaListado()
        {
            ViewBag.ModoEdicion = ViewBag.ModoEdicion ?? false;
            if (ViewBag.CodigoOriginal == null)
            {
                ViewBag.CodigoOriginal = string.Empty;
            }
            if (ViewBag.Departamento == null)
            {
                ViewBag.Departamento = new Departamento();
            }
            ViewBag.Departamentos = departamentoRepository.Listar();
            return View("Index");
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

        private Departamento Form(string codigo, string descri)
        {
            return new Departamento(codigo, descri);
        }

        private static string Normalizar(string valor)
        {
            return valor == null ? "" : valor.Trim();
        }

        /// <summary>
        /// Traduce los errores de base de datos más comunes del CRUD:
        /// duplicados de clave primaria y cilindros que restringen eliminar.
        /// </summary>
        private static string MensajeBaseDatos(SqlException ex)
        {
            if (ex.Number == 2601 || ex.Number == 2627)
            {
                return "Ya existe un departamento con el código ingresado.";
            }
            return "Error de base de datos: " + ex.Message;
        }
    }
}
