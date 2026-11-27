using System;
using System.Web;
using System.Web.Mvc;
using WebConMVCDotnet.Models;

namespace WebConMVCDotnet.Controllers
{
    public class DatosController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Salida()
        {
            DatosEncuesta datos = new DatosEncuesta();

            datos.nombre = Request.Form["txtNombre"];
            datos.apellido = Request.Form["txtApellido"];

            string lenguajes = Request.Form["chkProgLen"];
            datos.progleng = lenguajes != null ? lenguajes.Split(',') : new string[0];

            string nombreFoto = "";
            if (Request.Files.Count > 0 && Request.Files[0].ContentLength > 0)
            {
                HttpPostedFileBase archivo = Request.Files[0];
                nombreFoto = System.IO.Path.GetFileName(archivo.FileName);
                archivo.SaveAs(System.IO.Path.Combine(Server.MapPath("~/resources"), nombreFoto));
            }

            datos.foto = nombreFoto;
            return View(datos);
        }
    }
}