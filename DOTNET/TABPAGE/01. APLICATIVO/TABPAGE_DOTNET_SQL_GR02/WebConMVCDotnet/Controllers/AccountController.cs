using System;
using System.Web;
using System.Web.Mvc;
using WebConMVCDotnet.Models;

namespace WebConMVCDotnet.Controllers
{
    /// <summary>
    /// Controlador del inicio de sesión contra la tabla XEUSU_USUAR,
    /// equivalente al LoginController del proyecto Java.
    /// </summary>
    public class AccountController : Controller
    {
        private readonly UsuarioRepository usuarioRepository = new UsuarioRepository();

        [HttpGet]
        public ActionResult Index()
        {
            if (Session["Usuario"] != null)
            {
                return RedirectToAction("Index", "Bienvenida");
            }

            ViewBag.Error = null;
            return View();
        }

        [HttpPost]
        public ActionResult Index(string txtIdentificacion, string txtPassword)
        {
            string identificacion = Normalizar(txtIdentificacion);
            string password = txtPassword ?? "";

            try
            {
                Usuario usuario = usuarioRepository.Autenticar(identificacion, password);

                if (usuario == null)
                {
                    ViewBag.Error = "El código de usuario o la contraseña no son correctos.";
                    return View();
                }

                if (!usuario.Activo)
                {
                    ViewBag.Error = "El usuario se encuentra inactivo o bloqueado. Contacte al administrador.";
                    return View();
                }

                // La contraseña no se guarda en la sesión.
                usuario.Password = null;

                // Se limpia la sesión anterior y se guarda el usuario autenticado.
                Session.Clear();
                Session["Usuario"] = usuario;

                return RedirectToAction("Index", "Bienvenida");
            }
            catch (Exception)
            {
                ViewBag.Error = "No se pudo conectar con la base de datos. "
                    + "Verifique que SQL Server esté activo y la cadena de conexión en Web.config.";
                return View();
            }
        }

        /// <summary>
        /// Acción equivalente al LogoutController del proyecto Java: invalida la
        /// sesión activa y redirige de regreso al login.
        /// </summary>
        [HttpGet]
        public ActionResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            return Redirect("~/Account/Index");
        }

        private static string Normalizar(string valor)
        {
            return valor == null ? string.Empty : valor.Trim();
        }
    }
}
