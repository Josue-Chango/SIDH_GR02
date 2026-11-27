using System;
using System.Web.Mvc;
using WebConMVCDotnet.App_Start;
using WebConMVCDotnet.Models;

namespace WebConMVCDotnet.Controllers
{
    /// <summary>
    /// Página privada que se muestra después de un login correcto.
    /// Equivalente a bienvenida.jsp del proyecto Java.
    /// </summary>
    [FiltroAutenticacion]
    public class BienvenidaController : Controller
    {
        public ActionResult Index()
        {
            var usuario = (Usuario)Session["Usuario"];
            return View(usuario);
        }
    }
}
