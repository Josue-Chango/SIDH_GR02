using Microsoft.EntityFrameworkCore;
using SIDH_GR02.Mvc.Data;
using SIDH_GR02.Mvc.Models.Entidades;

namespace SIDH_GR02.Mvc.Dao;

public class PacienteDao(Transacciones tx) : GenericDao<Paciente>(tx)
{
    public Task<List<Paciente>> BuscarAsync(string? criterio, int pagina)
    {
        Validaciones.Exigir(pagina >= 0 && pagina <= 100000, "Página inválida");
        var q = (criterio ?? "").Trim().ToLowerInvariant();
        Validaciones.Exigir(q.Length <= 200, "La búsqueda es demasiado larga.");
        var patron = "%" + q + "%";
        return Tx.EjecutarAsync(db => db.Pacientes.AsNoTracking()
            .Where(p => EF.Functions.Like(p.IdentificadorHospitalario.ToLower(), patron)
                     || EF.Functions.Like(p.NumeroDocumento!.ToLower(), patron)
                     || EF.Functions.Like(p.Nombres!.ToLower(), patron)
                     || EF.Functions.Like(p.Apellidos!.ToLower(), patron))
            .OrderByDescending(p => p.RegistradoEl).ThenBy(p => p.Id)
            .Skip(pagina * 20).Take(20).ToListAsync());
    }

    public Task<Paciente> GuardarFormularioAsync(Paciente datos, bool nuevo)
    {
        ValidarDatos(datos);
        return Tx.EjecutarAsync(async db =>
        {
            Paciente actual;
            if (nuevo)
            {
                actual = new Paciente
                {
                    Id = Guid.NewGuid().ToString(),
                    IdentificadorHospitalario = Guid.NewGuid().ToString(),
                    RegistradoEl = Validaciones.Ahora(),
                    RegistradoPor = Validaciones.Texto(datos.RegistradoPor, 100, "Responsable"),
                    EstadoRegistro = "ACTIVO",
                };
            }
            else actual = await ExigirAsync<Paciente>(db, datos.Id);

            if (!string.IsNullOrWhiteSpace(datos.NumeroDocumento))
            {
                var n = await db.Pacientes.CountAsync(p => p.TipoDocumento == datos.TipoDocumento
                    && p.NumeroDocumento == datos.NumeroDocumento && p.Id != actual.Id);
                Validaciones.Exigir(n == 0, "Existe un paciente con ese documento. Revise los posibles duplicados.");
            }
            actual.TipoIdentidad = datos.TipoIdentidad; actual.TipoDocumento = datos.TipoDocumento;
            actual.NumeroDocumento = datos.NumeroDocumento; actual.Nombres = datos.Nombres;
            actual.Apellidos = datos.Apellidos; actual.FechaNacimiento = datos.FechaNacimiento;
            actual.SexoRegistrado = datos.SexoRegistrado; actual.Direccion = datos.Direccion;
            actual.EntidadCobertura = datos.EntidadCobertura; actual.ReferenciaCobertura = datos.ReferenciaCobertura;
            if (nuevo) db.Add(actual);
            return actual;
        });
    }

    public Task DesactivarAsync(string id) => ActualizarAsync(p => p.EstadoRegistro = "INACTIVO", id);

    private static void ValidarDatos(Paciente p)
    {
        Validaciones.Exigir(p.TipoIdentidad is "IDENTIFICADO" or "TEMPORAL", "Tipo de identidad inválido.");
        if (p.TipoIdentidad == "IDENTIFICADO")
        {
            Validaciones.Texto(p.Nombres, 200, "Nombres"); Validaciones.Texto(p.Apellidos, 200, "Apellidos");
            Validaciones.Texto(p.TipoDocumento, 40, "Tipo de documento"); Validaciones.Texto(p.NumeroDocumento, 200, "Documento");
        }
        Validaciones.Exigir(p.FechaNacimiento == null || p.FechaNacimiento <= Validaciones.Hoy(), "El nacimiento no puede ser futuro.");
    }
}
