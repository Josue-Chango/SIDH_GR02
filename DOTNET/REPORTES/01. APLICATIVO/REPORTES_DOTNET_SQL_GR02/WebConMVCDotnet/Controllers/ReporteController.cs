using System;
using System.Data;
using System.Web.Mvc;
using WebConMVCDotnet.App_Start;
using WebConMVCDotnet.Models;

namespace WebConMVCDotnet.Controllers
{
    /// <summary>
    /// Reportes de los tres módulos y ficha completa del empleado,
    /// como en el proyecto Java (ReporteController + ReportesJasper +
    /// plantillas .jrxml).
    ///
    /// En .NET Framework el equivalente de JasperReports se resuelve con
    /// vistas Razor de impresión: cada reporte abre una página con el
    /// mismo diseño de los PDF (título, usuario, fecha, tabla, subtotales)
    /// y se obtiene el PDF con el diálogo de impresión del navegador
    /// (Ctrl+P → "Guardar como PDF").
    ///
    /// Rutas:
    ///   /Reporte/Departamentos
    ///   /Reporte/Cargos?departamento=SIS
    ///   /Reporte/Empleados
    ///   /Reporte/Ficha?codigo=P000000001
    /// </summary>
    [FiltroAutenticacion]
    public class ReporteController : Controller
    {
        private readonly ReportesRepository reportesRepository = new ReportesRepository();

        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Departamentos()
        {
            try
            {
                DataSet datos = reportesRepository.Departamentos();
                ViewBag.Usuario = UsuarioSesion();
                ViewBag.Fecha = FechaEcuador();
                ViewBag.Total = datos.Tables["Departamentos"].Rows.Count;
                return View("Departamentos", datos);
            }
            catch (Exception)
            {
                return VistaSinDatos(
                    "No se pudo generar el reporte. Revise que SQL Server esté activo "
                    + "y la cadena de conexión en Web.config.");
            }
        }

        public ActionResult Cargos(string departamento)
        {
            string dep = Normalizar(departamento);
            if (dep.Length > 0 && dep.Length != 3)
            {
                return new HttpStatusCodeResult(400, "El departamento debe tener 3 caracteres.");
            }

            try
            {
                DataSet datos = reportesRepository.Cargos(dep);
                ViewBag.Usuario = UsuarioSesion();
                ViewBag.Fecha = FechaEcuador();
                ViewBag.Subtitulo = dep.Length == 0
                    ? "Todos los departamentos"
                    : "Departamento seleccionado: " + dep;
                ViewBag.FiltroDepartamento = dep;
                ViewBag.Total = datos.Tables["Cargos"].Rows.Count;
                return View("Cargos", datos);
            }
            catch (Exception)
            {
                return VistaSinDatos(
                    "No se pudo generar el reporte. Revise que SQL Server esté activo "
                    + "y la cadena de conexión en Web.config.");
            }
        }

        public ActionResult Empleados()
        {
            try
            {
                DataSet datos = reportesRepository.Empleados();
                ViewBag.Usuario = UsuarioSesion();
                ViewBag.Fecha = FechaEcuador();
                ViewBag.Total = datos.Tables["Empleados"].Rows.Count;
                return View("Empleados", datos);
            }
            catch (Exception)
            {
                return VistaSinDatos(
                    "No se pudo generar el reporte. Revise que SQL Server esté activo "
                    + "y la cadena de conexión en Web.config.");
            }
        }

        public ActionResult Ficha(string codigo)
        {
            string cod = Normalizar(codigo);
            if (!System.Text.RegularExpressions.Regex.IsMatch(cod, "^[A-Za-z0-9-]{1,10}$"))
            {
                return new HttpStatusCodeResult(400,
                    "Indique un código de empleado válido (hasta 10 letras, números o guiones).");
            }

            try
            {
                DataSet datos = reportesRepository.Ficha(cod);
                ViewBag.Usuario = UsuarioSesion();
                ViewBag.Fecha = FechaEcuador();
                return View("Ficha", datos);
            }
            catch (InvalidOperationException)
            {
                ViewBag.Usuario = UsuarioSesion();
                ViewBag.Fecha = FechaEcuador();
                ViewBag.Error = "El empleado " + cod + " no existe. "
                    + "Revise el código o regístrelo en el mantenimiento de empleados.";
                return View("SinDatos");
            }
            catch (Exception)
            {
                return VistaSinDatos(
                    "No se pudo generar el reporte. Revise que SQL Server esté activo "
                    + "y la cadena de conexión en Web.config.");
            }
        }

        /// <summary>Vista genérica de error para reportes que no pudieron consultar la base.</summary>
        private ActionResult VistaSinDatos(string mensaje)
        {
            ViewBag.Usuario = UsuarioSesion();
            ViewBag.Fecha = FechaEcuador();
            ViewBag.Error = mensaje;
            return View("SinDatos");
        }

        /// <summary>Nombre completo del usuario autenticado (parámetro USUARIO del Jasper).</summary>
        private static string UsuarioSesion()
        {
            Usuario usuario = System.Web.HttpContext.Current.Session["Usuario"] as Usuario;
            return usuario != null && usuario.Persona != null
                ? usuario.Persona.NombreCompleto
                : "";
        }

        /// <summary>Fecha y hora de Ecuador (igual que los PDF del proyecto Java).</summary>
        private static string FechaEcuador()
        {
            try
            {
                var zona = TimeZoneInfo.FindSystemTimeZoneById("SA Pacific Standard Time");
                return TimeZoneInfo.ConvertTime(DateTime.Now, zona).ToString("dd/MM/yyyy HH:mm");
            }
            catch (TimeZoneNotFoundException)
            {
                return DateTime.Now.ToString("dd/MM/yyyy HH:mm");
            }
            catch (InvalidTimeZoneException)
            {
                return DateTime.Now.ToString("dd/MM/yyyy HH:mm");
            }
        }

        private static string Normalizar(string valor)
        {
            return valor == null ? "" : valor.Trim();
        }
    }
}
