using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.EntityFrameworkCore;
using SIDH_GR02.Mvc.Dao;

namespace SIDH_GR02.Mvc.Controllers;

/// <summary>Equivale al try/catch de BaseServlet.service: traduce excepciones a 404, 400 o 409 con la vista de error.</summary>
public sealed class ManejoErroresFilter(ILogger<ManejoErroresFilter> log, IModelMetadataProvider metadatos) : IExceptionFilter
{
    public void OnException(ExceptionContext contexto)
    {
        (int estado, string mensaje)? respuesta = contexto.Exception switch
        {
            NoEncontradoException e => (404, e.Message),
            ValidacionException e => (400, e.Message),
            DbUpdateException e => Conflicto(e),
            _ => null,
        };
        if (respuesta is not var (estado, mensaje)) return;

        contexto.Result = new ViewResult
        {
            ViewName = "Error",
            StatusCode = estado,
            ViewData = new ViewDataDictionary(metadatos, contexto.ModelState) { ["Error"] = mensaje },
        };
        contexto.ExceptionHandled = true;
    }

    private (int, string) Conflicto(DbUpdateException e)
    {
        var referencia = Guid.NewGuid().ToString();
        log.LogError(e, "Operación revertida; referencia {Referencia}", referencia);
        return (409, "No se guardó la operación. El código puede estar repetido o el registro tiene dependencias. Referencia: " + referencia);
    }
}
