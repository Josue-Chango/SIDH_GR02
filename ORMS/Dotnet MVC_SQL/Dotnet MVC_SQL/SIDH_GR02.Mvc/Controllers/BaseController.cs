using System.Globalization;
using Microsoft.AspNetCore.Mvc;
using SIDH_GR02.Mvc.Dao;

namespace SIDH_GR02.Mvc.Controllers;

/// <summary>Equivale a BaseServlet: lectura de parámetros, paginación y redirección tras el commit.</summary>
public abstract class BaseController : Controller
{
    protected string? P(string nombre)
    {
        string? v = Request.HasFormContentType && Request.Form.ContainsKey(nombre) ? Request.Form[nombre] : Request.Query[nombre];
        return string.IsNullOrWhiteSpace(v) ? null : v.Trim();
    }

    protected string Requerido(string nombre, int max) => Validaciones.Texto(P(nombre), max, nombre);

    protected DateOnly? Fecha(string nombre)
    {
        var v = P(nombre);
        if (v == null) return null;
        if (DateOnly.TryParseExact(v, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var fecha)) return fecha;
        throw new ValidacionException("Fecha inválida: " + nombre);
    }

    protected int? Entero(string nombre)
    {
        var v = P(nombre);
        if (v == null) return null;
        if (int.TryParse(v, NumberStyles.Integer, CultureInfo.InvariantCulture, out var n)) return n;
        throw new ValidacionException("Número inválido: " + nombre);
    }

    protected int Pagina()
    {
        var n = Entero("pagina") ?? 0;
        Validaciones.Exigir(n >= 0 && n <= 100000, "Página inválida");
        return n;
    }

    /// <summary>GET sólo admite listar o abrir el formulario de edición; los cambios requieren POST.</summary>
    protected bool LecturaPermitida() => P("accion") is null or "editar";

    protected IActionResult SoloPost() => StatusCode(StatusCodes.Status405MethodNotAllowed, "Esta operación requiere POST.");

    protected IActionResult Redirigir(string ruta)
    {
        TempData["Mensaje"] = "Operación confirmada.";
        return LocalRedirect(ruta);
    }
}
