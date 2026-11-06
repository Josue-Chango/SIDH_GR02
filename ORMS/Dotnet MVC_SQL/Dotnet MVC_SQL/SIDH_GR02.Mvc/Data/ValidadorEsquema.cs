using System.Data.Common;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace SIDH_GR02.Mvc.Data;

/// <summary>
/// Equivale a hibernate.hbm2ddl.auto=validate: al iniciar comprueba que cada tabla y columna mapeada
/// exista en MySQL. Nunca crea ni altera tablas.
/// </summary>
public static class ValidadorEsquema
{
    public static async Task ValidarAsync(IServiceProvider servicios)
    {
        var fabrica = servicios.GetRequiredService<IDbContextFactory<SidhDbContext>>();
        await using var db = await fabrica.CreateDbContextAsync();
        DbConnection conexion = db.Database.GetDbConnection();
        await conexion.OpenAsync();

        var existentes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        await using (var cmd = conexion.CreateCommand())
        {
            cmd.CommandText = "SELECT TABLE_NAME, COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE()";
            await using var lector = await cmd.ExecuteReaderAsync();
            while (await lector.ReadAsync()) existentes.Add(lector.GetString(0) + "." + lector.GetString(1));
        }

        var faltantes = new List<string>();
        foreach (var entidad in db.Model.GetEntityTypes())
        {
            var tabla = entidad.GetTableName()!;
            var objeto = StoreObjectIdentifier.Table(tabla, null);
            foreach (var propiedad in entidad.GetProperties())
            {
                var columna = tabla + "." + propiedad.GetColumnName(objeto);
                if (!existentes.Contains(columna)) faltantes.Add(columna);
            }
        }
        if (faltantes.Count > 0)
            throw new InvalidOperationException("El esquema MySQL no coincide con el modelo. Faltan: " + string.Join(", ", faltantes.Take(20)));
    }
}
