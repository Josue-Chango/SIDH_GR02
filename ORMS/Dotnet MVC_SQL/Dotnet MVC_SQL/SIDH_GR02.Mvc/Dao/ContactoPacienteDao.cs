using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using SIDH_GR02.Mvc.Data;
using SIDH_GR02.Mvc.Models.Entidades;

namespace SIDH_GR02.Mvc.Dao;

public partial class ContactoPacienteDao(Transacciones tx) : GenericDao<ContactoPaciente>(tx)
{
    [GeneratedRegex(@"^[^\s@]+@[^\s@]+\.[^\s@]+$")]
    private static partial Regex Correo();

    public Task<List<ContactoPaciente>> ListarDePacienteAsync(string pacienteId) =>
        Tx.EjecutarAsync(db => db.ContactoPacientes.AsNoTracking()
            .Where(c => c.PacienteId == pacienteId)
            .OrderBy(c => c.Prioridad).ThenBy(c => c.Id).Take(100).ToListAsync());

    public Task GuardarFormularioAsync(string pacienteId, ContactoPaciente datos, bool nuevo)
    {
        Validaciones.Texto(datos.TipoVinculo, 40, "Tipo de vínculo");
        Validaciones.Vigencia(datos.VigenteDesde, datos.VigenteHasta);
        Validaciones.Exigir(datos.Prioridad == null || datos.Prioridad >= 0, "Prioridad inválida.");
        Validaciones.Exigir(string.IsNullOrWhiteSpace(datos.Correo) || Correo().IsMatch(datos.Correo), "Correo inválido.");
        return Tx.EjecutarAsync(async db =>
        {
            var p = await ExigirAsync<Paciente>(db, pacienteId);
            var c = nuevo ? new ContactoPaciente { Id = Guid.NewGuid().ToString() } : await ExigirAsync<ContactoPaciente>(db, datos.Id);
            if (!nuevo) Validaciones.Exigir(c.PacienteId == pacienteId, "El contacto no pertenece al paciente.");
            c.Paciente = p; c.TipoVinculo = datos.TipoVinculo; c.NombreContacto = datos.NombreContacto;
            c.Telefono = datos.Telefono; c.Correo = datos.Correo; c.Parentesco = datos.Parentesco;
            c.Prioridad = datos.Prioridad; c.VigenteDesde = datos.VigenteDesde; c.VigenteHasta = datos.VigenteHasta;
            if (nuevo)
            {
                c.RegistradoPor = Validaciones.Texto(datos.RegistradoPor, 100, "Responsable");
                c.RegistradoEl = Validaciones.Ahora();
                db.Add(c);
            }
        });
    }

    public Task CerrarVigenciaAsync(string pacienteId, string id) =>
        Tx.EjecutarAsync(async db =>
        {
            var c = await ExigirAsync<ContactoPaciente>(db, id);
            Validaciones.Exigir(c.PacienteId == pacienteId, "El contacto no pertenece al paciente.");
            c.VigenteHasta = Validaciones.Hoy();
            Validaciones.Vigencia(c.VigenteDesde, c.VigenteHasta);
        });
}
