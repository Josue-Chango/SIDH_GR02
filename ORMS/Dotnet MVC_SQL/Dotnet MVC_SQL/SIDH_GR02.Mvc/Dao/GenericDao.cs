using Microsoft.EntityFrameworkCore;
using SIDH_GR02.Mvc.Data;

namespace SIDH_GR02.Mvc.Dao;

/// <summary>CRUD reutilizable para todas las entidades, incluidas las de clave compuesta (valores en orden de la PK).</summary>
public class GenericDao<T>(Transacciones tx) where T : class
{
    protected readonly Transacciones Tx = tx;

    public virtual Task<T> GuardarAsync(T entidad) =>
        Tx.EjecutarAsync(db => { db.Add(entidad); return Task.FromResult(entidad); });

    public Task<T?> BuscarPorIdAsync(params object[] id) =>
        Tx.EjecutarAsync(db => db.Set<T>().FindAsync(id).AsTask());

    public Task<List<T>> ListarAsync(int inicio, int cantidad)
    {
        if (inicio < 0 || cantidad < 1 || cantidad > 100) throw new ArgumentOutOfRangeException(nameof(cantidad), "Paginación inválida");
        return Tx.EjecutarAsync(db => OrdenarPorClave(db, db.Set<T>().AsNoTracking()).Skip(inicio).Take(cantidad).ToListAsync());
    }

    public Task<T> ActualizarAsync(Action<T> cambios, params object[] id) =>
        Tx.EjecutarAsync(async db => { var actual = await ExigirAsync<T>(db, id); cambios(actual); return actual; });

    public Task EliminarAsync(params object[] id) =>
        Tx.EjecutarAsync(async db => db.Remove(await ExigirAsync<T>(db, id)));

    public static async Task<E> ExigirAsync<E>(SidhDbContext db, params object?[] id) where E : class
    {
        if (id.Length == 0 || id.Any(v => v == null)) throw new NoEncontradoException();
        return await db.Set<E>().FindAsync(id) ?? throw new NoEncontradoException();
    }

    // "order by e.id": ordena por todas las columnas de la PK, también si es compuesta.
    private static IQueryable<T> OrdenarPorClave(SidhDbContext db, IQueryable<T> origen)
    {
        IOrderedQueryable<T>? ordenada = null;
        foreach (var p in db.Model.FindEntityType(typeof(T))!.FindPrimaryKey()!.Properties)
            ordenada = ordenada == null
                ? origen.OrderBy(e => EF.Property<object>(e, p.Name))
                : ordenada.ThenBy(e => EF.Property<object>(e, p.Name));
        return ordenada ?? origen;
    }
}
