using Microsoft.EntityFrameworkCore;

namespace SIDH_GR02.Mvc.Data;

/// <summary>
/// Un contexto y una transacción por operación. El callback permite agrupar varias entidades en un único commit.
/// Si el trabajo o SaveChanges fallan, la transacción se descarta sin commit (rollback) y la excepción se propaga.
/// </summary>
public sealed class Transacciones(IDbContextFactory<SidhDbContext> fabrica)
{
    public async Task<T> EjecutarAsync<T>(Func<SidhDbContext, Task<T>> trabajo)
    {
        await using var db = await fabrica.CreateDbContextAsync();
        await using var tx = await db.Database.BeginTransactionAsync();
        var resultado = await trabajo(db);
        await db.SaveChangesAsync();
        await tx.CommitAsync();
        return resultado;
    }

    public Task EjecutarAsync(Func<SidhDbContext, Task> trabajo) =>
        EjecutarAsync(async db => { await trabajo(db); return true; });
}
