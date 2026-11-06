using Microsoft.AspNetCore.Mvc;
using SIDH_GR02.Mvc.Dao;
using SIDH_GR02.Mvc.Models.Entidades;
using SIDH_GR02.Mvc.Models.Vistas;

namespace SIDH_GR02.Mvc.Controllers;

/// <summary>Equivale a AuxiliaresServlet: departamentos, estados de usuario y cargos (PK compuesta).</summary>
public class AuxiliaresController(DepartamentoDao departamentos, EstadoDao estados, CargoDao cargos) : BaseController
{
    private string Ruta => Request.Path.Value!.TrimEnd('/').ToLowerInvariant();

    [HttpGet("departamentos"), HttpGet("estados"), HttpGet("cargos")]
    public async Task<IActionResult> Listar()
    {
        if (!LecturaPermitida()) return SoloPost();
        var ruta = Ruta; var pagina = Pagina(); var editar = P("accion") == "editar";
        var vista = new AuxiliaresVista
        {
            Ruta = "~" + ruta, Pagina = pagina, EsCargo = ruta == "/cargos", MaxCodigo = ruta == "/estados" ? 1 : 3,
            Titulo = ruta switch { "/departamentos" => "Departamentos", "/estados" => "Estados de usuario", _ => "Cargos por departamento" },
        };
        if (vista.EsCargo)
        {
            vista.Filas = (await cargos.ListarAsync(pagina * 20, 20)).Select(c => new FilaAuxiliar(c.DepartamentoId, c.Codigo, c.Descripcion)).ToList();
            vista.Departamentos = await departamentos.ListarAsync(0, 100);
            if (editar)
            {
                var c = await cargos.BuscarPorIdAsync(Requerido("dep", 3), Requerido("id", 3)) ?? throw new NoEncontradoException();
                vista.Form = new FilaAuxiliar(c.DepartamentoId, c.Codigo, c.Descripcion);
            }
        }
        else if (ruta == "/estados")
        {
            vista.Filas = (await estados.ListarAsync(pagina * 20, 20)).Select(e => new FilaAuxiliar(null, e.Id, e.Descripcion)).ToList();
            if (editar)
            {
                var e = await estados.BuscarPorIdAsync(Requerido("id", 1)) ?? throw new NoEncontradoException();
                vista.Form = new FilaAuxiliar(null, e.Id, e.Descripcion);
            }
        }
        else
        {
            vista.Filas = (await departamentos.ListarAsync(pagina * 20, 20)).Select(d => new FilaAuxiliar(null, d.Id, d.Descripcion)).ToList();
            if (editar)
            {
                var d = await departamentos.BuscarPorIdAsync(Requerido("id", 3)) ?? throw new NoEncontradoException();
                vista.Form = new FilaAuxiliar(null, d.Id, d.Descripcion);
            }
        }
        return View("Auxiliares", vista);
    }

    [HttpPost("departamentos"), HttpPost("estados"), HttpPost("cargos")]
    public async Task<IActionResult> Guardar()
    {
        var ruta = Ruta; var accion = Requerido("accion", 20);
        Validaciones.Exigir(accion is "crear" or "actualizar" or "eliminar", "Acción inválida.");
        bool nuevo = accion == "crear", eliminar = accion == "eliminar";
        var id = Requerido("id", ruta == "/estados" ? 1 : 3);
        var descripcion = eliminar ? null : Requerido("descripcion", 50);

        if (ruta == "/cargos")
        {
            var dep = Requerido("dep", 3);
            if (eliminar) await cargos.EliminarAsync(dep, id);
            else if (nuevo) await cargos.GuardarAsync(new Cargo { DepartamentoId = dep, Codigo = id, Descripcion = descripcion! });
            else await cargos.ActualizarAsync(c => c.Descripcion = descripcion!, dep, id);
        }
        else if (ruta == "/estados")
        {
            if (eliminar) await estados.EliminarAsync(id);
            else if (nuevo) await estados.GuardarAsync(new Estado { Id = id, Descripcion = descripcion! });
            else await estados.ActualizarAsync(e => e.Descripcion = descripcion!, id);
        }
        else
        {
            if (eliminar) await departamentos.EliminarAsync(id);
            else if (nuevo) await departamentos.GuardarAsync(new Departamento { Id = id, Descripcion = descripcion! });
            else await departamentos.ActualizarAsync(d => d.Descripcion = descripcion!, id);
        }
        return Redirigir("~" + ruta);
    }
}
