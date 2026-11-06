using SIDH_GR02.Mvc.Data;
using SIDH_GR02.Mvc.Models.Entidades;

namespace SIDH_GR02.Mvc.Dao;

public class DepartamentoDao(Transacciones tx) : GenericDao<Departamento>(tx);

public class EstadoDao(Transacciones tx) : GenericDao<Estado>(tx);

/// <summary>PK compuesta (departamento, código). Se exige el departamento dentro de la misma transacción.</summary>
public class CargoDao(Transacciones tx) : GenericDao<Cargo>(tx)
{
    public override Task<Cargo> GuardarAsync(Cargo cargo) =>
        Tx.EjecutarAsync(async db =>
        {
            cargo.Departamento = await ExigirAsync<Departamento>(db, cargo.DepartamentoId);
            db.Add(cargo);
            return cargo;
        });
}
