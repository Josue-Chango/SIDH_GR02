using System.ComponentModel.DataAnnotations;
using Microsoft.EntityFrameworkCore;
using SIDH_GR02.Mvc.Dao;

namespace SIDH_GR02.Mvc.Data;

/// <summary>
/// Equivale a la EntityManagerFactory de JPAUtil. Las 80 entidades, sus DbSet y las 131 FK
/// están en SidhDbContext.Modelo.cs (generado). No se usan migraciones: el DDL es la autoridad.
/// </summary>
public partial class SidhDbContext(DbContextOptions<SidhDbContext> options) : DbContext(options)
{
    protected override void OnModelCreating(ModelBuilder modelBuilder) => ConfigurarRelaciones(modelBuilder);

    public override int SaveChanges(bool acceptAllChangesOnSuccess)
    {
        ValidarEntidades();
        return base.SaveChanges(acceptAllChangesOnSuccess);
    }

    public override Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken cancellationToken = default)
    {
        ValidarEntidades();
        return base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken);
    }

    // Equivale a jakarta.persistence.validation.mode=CALLBACK: valida las anotaciones antes del SQL.
    private void ValidarEntidades()
    {
        foreach (var entrada in ChangeTracker.Entries())
        {
            if (entrada.State is not (EntityState.Added or EntityState.Modified)) continue;
            if (!Validator.TryValidateObject(entrada.Entity, new ValidationContext(entrada.Entity), null, validateAllProperties: true))
                throw new ValidacionException("Revise los campos obligatorios, las longitudes y los formatos.");
        }
    }
}
