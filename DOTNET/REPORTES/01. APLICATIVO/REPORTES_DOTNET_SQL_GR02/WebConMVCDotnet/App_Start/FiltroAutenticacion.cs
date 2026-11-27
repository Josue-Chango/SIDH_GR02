using System;
using System.Web.Mvc;
using System.Web.Routing;

namespace WebConMVCDotnet.App_Start
{
    /// <summary>
    /// Filtro que protege las páginas privadas: si no existe un usuario en la
    /// sesión, redirige al inicio de sesión.
    /// </summary>
    public class FiltroAutenticacionAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var sesion = filterContext.HttpContext.Session;
            if (sesion == null || sesion["Usuario"] == null)
            {
                filterContext.Result = new RedirectResult("~/Account/Index");
                return;
            }

            filterContext.HttpContext.Response.Cache.SetNoStore();
            filterContext.HttpContext.Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
        }
    }
}
