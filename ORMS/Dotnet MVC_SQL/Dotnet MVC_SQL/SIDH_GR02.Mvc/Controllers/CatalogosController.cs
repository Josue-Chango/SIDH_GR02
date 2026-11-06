using Microsoft.AspNetCore.Mvc;
using SIDH_GR02.Mvc.Dao;
using SIDH_GR02.Mvc.Models.Entidades;
using SIDH_GR02.Mvc.Models.Vistas;

namespace SIDH_GR02.Mvc.Controllers;

/// <summary>Equivale a CatalogoServlet (catálogos) y ValorCatalogoServlet (valores del catálogo).</summary>
public class CatalogosController(CatalogoDao catalogos, ValorCatalogoDao valores) : BaseController
{
    [HttpGet("catalogos")]
    public async Task<IActionResult> Index()
    {
        if (!LecturaPermitida()) return SoloPost();
        var vista = new Listado<Catalogo> { Pagina = Pagina() };
        vista.Filas = await catalogos.ListarAsync(vista.Pagina * 20, 20);
        if (P("accion") == "editar") vista.Form = await catalogos.BuscarPorIdAsync(Requerido("id", 36)) ?? throw new NoEncontradoException();
        return View(vista);
    }

    [HttpPost("catalogos")]
    public async Task<IActionResult> Guardar()
    {
        var accion = Requerido("accion", 20);
        if (accion == "desactivar") await catalogos.DesactivarAsync(Requerido("id", 36));
        else
        {
            Validaciones.Exigir(accion is "crear" or "actualizar", "Acción inválida.");
            var c = new Catalogo
            {
                Id = P("id")!, Codigo = P("codigo")!, Nombre = P("nombre")!, Descripcion = P("descripcion"), RegistradoPor = P("responsable")!,
            };
            await catalogos.GuardarFormularioAsync(c, accion == "crear");
        }
        return Redirigir("~/catalogos");
    }

    [HttpGet("valores")]
    public async Task<IActionResult> Valores()
    {
        if (!LecturaPermitida()) return SoloPost();
        var catalogoId = Requerido("catalogo", 36);
        var vista = new ValoresVista { Catalogo = await catalogos.BuscarPorIdAsync(catalogoId) ?? throw new NoEncontradoException() };
        vista.Filas = await valores.ListarDeCatalogoAsync(catalogoId);
        if (P("accion") == "editar")
        {
            var v = await valores.BuscarPorIdAsync(Requerido("id", 36)) ?? throw new NoEncontradoException();
            Validaciones.Exigir(v.CatalogoId == catalogoId, "El valor no pertenece al catálogo.");
            vista.Form = v;
        }
        return View(vista);
    }

    [HttpPost("valores")]
    public async Task<IActionResult> GuardarValor()
    {
        var catalogoId = Requerido("catalogo", 36); var accion = Requerido("accion", 20);
        if (accion == "desactivar") await valores.DesactivarAsync(catalogoId, Requerido("id", 36));
        else
        {
            Validaciones.Exigir(accion is "crear" or "actualizar", "Acción inválida.");
            var v = new ValorCatalogo
            {
                Id = P("id")!, Codigo = P("codigo")!, Descripcion = P("descripcion")!,
                VigenteDesde = Fecha("vigenteDesde"), VigenteHasta = Fecha("vigenteHasta"), RegistradoPor = P("responsable")!,
            };
            await valores.GuardarFormularioAsync(catalogoId, v, accion == "crear");
        }
        return Redirigir("~/valores?catalogo=" + Uri.EscapeDataString(catalogoId));
    }
}
