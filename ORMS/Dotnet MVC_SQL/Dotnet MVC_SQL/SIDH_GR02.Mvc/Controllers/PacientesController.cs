using Microsoft.AspNetCore.Mvc;
using SIDH_GR02.Mvc.Dao;
using SIDH_GR02.Mvc.Models.Entidades;
using SIDH_GR02.Mvc.Models.Vistas;

namespace SIDH_GR02.Mvc.Controllers;

/// <summary>Equivale a PacienteServlet (pacientes) y ContactoServlet (contactos del paciente).</summary>
public class PacientesController(PacienteDao pacientes, ContactoPacienteDao contactos) : BaseController
{
    [HttpGet("pacientes")]
    public async Task<IActionResult> Index()
    {
        if (!LecturaPermitida()) return SoloPost();
        var vista = new Listado<Paciente> { Pagina = Pagina(), Q = P("q") };
        vista.Filas = await pacientes.BuscarAsync(vista.Q, vista.Pagina);
        if (P("accion") == "editar") vista.Form = await pacientes.BuscarPorIdAsync(Requerido("id", 36)) ?? throw new NoEncontradoException();
        return View(vista);
    }

    [HttpPost("pacientes")]
    public async Task<IActionResult> Guardar()
    {
        var accion = Requerido("accion", 20);
        if (accion == "desactivar") await pacientes.DesactivarAsync(Requerido("id", 36));
        else
        {
            Validaciones.Exigir(accion is "crear" or "actualizar", "Acción inválida.");
            var p = new Paciente
            {
                Id = P("id")!, TipoIdentidad = P("tipoIdentidad")!, TipoDocumento = P("tipoDocumento"),
                NumeroDocumento = P("numeroDocumento"), Nombres = P("nombres"), Apellidos = P("apellidos"),
                FechaNacimiento = Fecha("fechaNacimiento"), SexoRegistrado = P("sexoRegistrado"), Direccion = P("direccion"),
                EntidadCobertura = P("entidadCobertura"), ReferenciaCobertura = P("referenciaCobertura"), RegistradoPor = P("responsable")!,
            };
            await pacientes.GuardarFormularioAsync(p, accion == "crear");
        }
        return Redirigir("~/pacientes");
    }

    [HttpGet("contactos")]
    public async Task<IActionResult> Contactos()
    {
        if (!LecturaPermitida()) return SoloPost();
        var pacienteId = Requerido("paciente", 36);
        var vista = new ContactosVista { Paciente = await pacientes.BuscarPorIdAsync(pacienteId) ?? throw new NoEncontradoException() };
        vista.Filas = await contactos.ListarDePacienteAsync(pacienteId);
        if (P("accion") == "editar")
        {
            var c = await contactos.BuscarPorIdAsync(Requerido("id", 36)) ?? throw new NoEncontradoException();
            Validaciones.Exigir(c.PacienteId == pacienteId, "El contacto no pertenece al paciente.");
            vista.Form = c;
        }
        return View(vista);
    }

    [HttpPost("contactos")]
    public async Task<IActionResult> GuardarContacto()
    {
        var pacienteId = Requerido("paciente", 36); var accion = Requerido("accion", 20);
        if (accion == "cerrar") await contactos.CerrarVigenciaAsync(pacienteId, Requerido("id", 36));
        else
        {
            Validaciones.Exigir(accion is "crear" or "actualizar", "Acción inválida.");
            var c = new ContactoPaciente
            {
                Id = P("id")!, TipoVinculo = P("tipoVinculo")!, NombreContacto = P("nombreContacto"), Telefono = P("telefono"),
                Correo = P("correo"), Parentesco = P("parentesco"), Prioridad = Entero("prioridad"),
                VigenteDesde = Fecha("vigenteDesde"), VigenteHasta = Fecha("vigenteHasta"), RegistradoPor = P("responsable")!,
            };
            await contactos.GuardarFormularioAsync(pacienteId, c, accion == "crear");
        }
        return Redirigir("~/contactos?paciente=" + Uri.EscapeDataString(pacienteId));
    }
}
