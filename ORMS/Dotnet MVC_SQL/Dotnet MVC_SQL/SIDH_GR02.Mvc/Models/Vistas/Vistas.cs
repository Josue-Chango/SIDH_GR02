using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.AspNetCore.Mvc;
using SIDH_GR02.Mvc.Models.Entidades;

namespace SIDH_GR02.Mvc.Models.Vistas;

/// <summary>Datos que la vista recibe del controlador; la vista no consulta la base.</summary>
public class Listado<T> where T : class
{
    public List<T> Filas { get; set; } = [];
    public T? Form { get; set; }
    public int Pagina { get; set; }
    public string? Q { get; set; }
}

public class ContactosVista : Listado<ContactoPaciente>
{
    public Paciente Paciente { get; set; } = null!;
}

public class ValoresVista : Listado<ValorCatalogo>
{
    public Catalogo Catalogo { get; set; } = null!;
}

public record FilaAuxiliar(string? Dep, string Codigo, string Descripcion);

public class AuxiliaresVista : Listado<FilaAuxiliar>
{
    public string Titulo { get; set; } = "";
    public string Ruta { get; set; } = "";
    public bool EsCargo { get; set; }
    public int MaxCodigo { get; set; }
    public List<Departamento> Departamentos { get; set; } = [];
}

public static class UrlExtensiones
{
    /// <summary>Ruta con parámetros escapados, p. ej. Url.Con("~/cargos", ("accion", "editar"), ("id", f.Codigo)).</summary>
    public static string Con(this IUrlHelper url, string ruta, params (string clave, string? valor)[] parametros)
    {
        var qb = new QueryBuilder();
        foreach (var (clave, valor) in parametros) if (valor != null) qb.Add(clave, valor);
        return url.Content(ruta) + qb.ToQueryString();
    }

    public static string Iso(this DateOnly? fecha) => fecha?.ToString("yyyy-MM-dd") ?? "";
}
