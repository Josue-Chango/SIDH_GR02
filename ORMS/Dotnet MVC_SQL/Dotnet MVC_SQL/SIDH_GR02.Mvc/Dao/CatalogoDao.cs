using Microsoft.EntityFrameworkCore;
using SIDH_GR02.Mvc.Data;
using SIDH_GR02.Mvc.Models.Entidades;

namespace SIDH_GR02.Mvc.Dao;

public class CatalogoDao(Transacciones tx) : GenericDao<Catalogo>(tx)
{
    public Task GuardarFormularioAsync(Catalogo datos, bool nuevo)
    {
        Validaciones.Texto(datos.Codigo, 40, "Código"); Validaciones.Texto(datos.Nombre, 200, "Nombre");
        return Tx.EjecutarAsync(async db =>
        {
            var c = nuevo ? new Catalogo { Id = Guid.NewGuid().ToString() } : await ExigirAsync<Catalogo>(db, datos.Id);
            var n = await db.Catalogos.CountAsync(x => x.Codigo == datos.Codigo && x.Id != c.Id);
            Validaciones.Exigir(n == 0, "Ese código de catálogo ya está registrado.");
            c.Codigo = datos.Codigo; c.Nombre = datos.Nombre; c.Descripcion = datos.Descripcion;
            if (nuevo)
            {
                c.Estado = "ACTIVO"; c.RegistradoEl = Validaciones.Ahora();
                c.RegistradoPor = Validaciones.Texto(datos.RegistradoPor, 100, "Responsable");
                db.Add(c);
            }
        });
    }

    public Task DesactivarAsync(string id) => ActualizarAsync(c => c.Estado = "INACTIVO", id);
}

public class ValorCatalogoDao(Transacciones tx) : GenericDao<ValorCatalogo>(tx)
{
    public Task<List<ValorCatalogo>> ListarDeCatalogoAsync(string id) =>
        Tx.EjecutarAsync(db => db.ValorCatalogos.AsNoTracking()
            .Where(v => v.CatalogoId == id).OrderBy(v => v.Codigo).ThenBy(v => v.Id).Take(100).ToListAsync());

    public Task GuardarFormularioAsync(string catalogoId, ValorCatalogo datos, bool nuevo)
    {
        Validaciones.Texto(datos.Codigo, 40, "Código"); Validaciones.Texto(datos.Descripcion, 200, "Descripción");
        Validaciones.Vigencia(datos.VigenteDesde, datos.VigenteHasta);
        return Tx.EjecutarAsync(async db =>
        {
            var c = await ExigirAsync<Catalogo>(db, catalogoId);
            var v = nuevo ? new ValorCatalogo { Id = Guid.NewGuid().ToString() } : await ExigirAsync<ValorCatalogo>(db, datos.Id);
            if (!nuevo) Validaciones.Exigir(v.CatalogoId == catalogoId, "El valor no pertenece al catálogo.");
            Validaciones.Exigir(c.Estado == "ACTIVO", "El catálogo está inactivo.");
            v.Catalogo = c; v.Codigo = datos.Codigo; v.Descripcion = datos.Descripcion;
            v.VigenteDesde = datos.VigenteDesde; v.VigenteHasta = datos.VigenteHasta;
            if (nuevo)
            {
                v.Estado = "ACTIVO"; v.RegistradoEl = Validaciones.Ahora();
                v.RegistradoPor = Validaciones.Texto(datos.RegistradoPor, 100, "Responsable");
                db.Add(v);
            }
        });
    }

    public Task DesactivarAsync(string catalogoId, string id) =>
        ActualizarAsync(v =>
        {
            Validaciones.Exigir(v.CatalogoId == catalogoId, "El valor no pertenece al catálogo.");
            v.Estado = "INACTIVO";
        }, id);
}
