# SIDH GR02 — ORM con EF Core y ASP.NET Core MVC

Réplica en C# de `proyectos-monster` (Java · Hibernate 6.6 · Servlet/JSP). Mapea las **80 tablas, 712 columnas, 131 FK y 4 claves compuestas** del DDL MySQL y reproduce los siete mantenimientos web con la misma lógica de negocio.

| Componente | Versión |
|---|---|
| .NET / ASP.NET Core MVC | 10.0 |
| ORM | EF Core 9.0.11 + Pomelo.EntityFrameworkCore.MySql 9.0.0 |
| Driver | MySqlConnector 2.6.2 (fijado: 2.4.0 tiene un aviso de seguridad) |
| Base | MySQL 8.0.44 en `localhost:3307`, esquema `sidh_gr02` |

## Ejecutar

```powershell
cd SIDH_GR02.Mvc
dotnet run --launch-profile http     # http://localhost:5015
```

La cadena de conexión está en `appsettings.json` → `ConnectionStrings:Sidh`. Al iniciar, `ValidadorEsquema` comprueba que cada tabla y columna mapeada exista (equivale a `hbm2ddl.auto=validate`); si falta alguna, la app no arranca. **No se usan migraciones**: el DDL es la autoridad y EF nunca crea ni altera tablas.

Instalación nueva del esquema (una sola vez, sobre un esquema vacío):

```powershell
mysql -h 127.0.0.1 -P 3307 -u root -p -e "CREATE DATABASE sidh_gr02 CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci"
mysql -h 127.0.0.1 -P 3307 -u root -p --default-character-set=utf8mb4 sidh_gr02 < db/schema-create.sql
```

## Estructura y equivalencias con Java

```text
SIDH_GR02.Mvc/
  Models/Entidades/   80 entidades (generadas)          ← modelo/*.java
  Data/
    SidhDbContext.cs          contexto + validación      ← JPAUtil + validation.mode=CALLBACK
    SidhDbContext.Modelo.cs   DbSet y 131 FK (generado)  ← @ManyToOne/@OneToMany
    Transacciones.cs          1 contexto + 1 tx por op.  ← Transacciones.java
    ValidadorEsquema.cs       verificación al iniciar    ← hbm2ddl.auto=validate
  Dao/                GenericDao y DAOs específicos      ← dao/*.java
  Controllers/        Controladores MVC                  ← controlador/*Servlet.java
    ManejoErroresFilter.cs    404 / 400 / 409            ← BaseServlet.service
  Views/              Razor                              ← WEB-INF/vistas/*.jsp
  db/schema-create.sql  DDL sin DROP
  tools/generar_modelo.py  generador de entidades       ← tools/generate_model.py
```

| Java / Jakarta | C# / EF Core |
|---|---|
| `@Entity @Table @Column` | `[Table]` `[Column]` |
| `@Id` / `@EmbeddedId` + `CargoId` | `[Key]` / `[PrimaryKey(nameof(DepartamentoId), nameof(Codigo))]` |
| `@MapsId` | la columna FK es parte de la PK; `DepartamentoId` + navegación `Departamento` |
| `@ManyToOne(LAZY)` sin cascada | `HasOne().WithMany().OnDelete(DeleteBehavior.Restrict)` |
| `@NotBlank @Size @Digits` | `[Required] [StringLength] [Precision]`, validados antes de `SaveChanges` |
| `@PrePersist` UUID | `Guid.NewGuid().ToString()` en el DAO |
| `LocalDate / LocalDateTime / BigDecimal` | `DateOnly / DateTime / decimal` |
| token CSRF de `ProteccionFilter` | `AutoValidateAntiforgeryToken` + `@Html.AntiForgeryToken()` |
| `session.mensaje` | `TempData["Mensaje"]` |

Las URLs son las mismas: `/departamentos`, `/estados`, `/cargos`, `/pacientes`, `/contactos?paciente=…`, `/catalogos`, `/valores?catalogo=…`. Los GET sólo listan o abren el formulario de edición (`accion=editar`); todo cambio requiere POST con token.

Para operaciones que abarquen varias entidades usa `Transacciones.EjecutarAsync(async db => { … })`: todo lo que hagas con ese `db` se confirma en un único commit, o se revierte entero si algo falla.

## Regenerar el modelo

`python tools/generar_modelo.py` vuelve a leer `db/schema-create.sql` y **sobrescribe** `Models/Entidades/*.cs`, `Data/SidhDbContext.Modelo.cs` y `docs/MAPEOS.md`. Usa los mismos nombres que el generador Java. Hay un único ajuste propio de C#, porque un miembro no puede llamarse igual que su clase: la autorreferencia de `NotaClinica` se llama `NotaClinicaRelacionada`.

## Limitaciones heredadas

Son las mismas del proyecto Java (ver su `docs/ANALISIS.md`): `XEUSU_PASWD` es la PK de usuarios, los índices `AK_` no son UNIQUE y `REGISTRADOPOR` es texto, no una identidad autenticada.
