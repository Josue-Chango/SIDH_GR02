# Cambios de la migración Java → .NET (con SQL Server)

Proyecto: `WebConMVCDotnet` (ASP.NET MVC 5, .NET Framework 4.7.2)
Proyecto original: `SIGH_JAVA_MySQL_GR02` (Java 21 + MySQL)
Base de datos: `sigh_gr02` en **SQL Server** (instancia por defecto `MSSQLSERVER`, servidor `localhost`)

---

## 1. Conexión a la base de datos

### 1.1 `WebConMVCDotnet/Web.config`

La cadena de conexión apuntaba a LocalDB (que no es el SQL Server instalado). Se cambió
al servidor local, igual que el JDBC del proyecto Java (que usaba MySQL):

```xml
<!-- ANTES -->
<add name="SighGrab02"
     connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=sigh_gr02;Integrated Security=True;"
     providerName="System.Data.SqlClient" />

<!-- DESPUÉS -->
<add name="SighGrab02"
     connectionString="Data Source=localhost;Initial Catalog=sigh_gr02;Integrated Security=True;"
     providerName="System.Data.SqlClient" />
```

| Elemento Java | Equivalente .NET |
|---|---|
| `jdbc:mysql://localhost:3306/sigh_gr02` | `Data Source=localhost;Initial Catalog=sigh_gr02` |
| Usuario/contraseña JDBC | `Integrated Security=True` (autenticación de Windows) |

### 1.2 Creación de la base de datos

La base se creó ejecutando el DDL completo del proyecto Java:

```
C:\Users\josue\Documents\GITHUB\SIGH_JAVA_MySQL_GR02\03. BDD\01. SCRIPTS\02. SQL\01. DDL\SIGH_GR02_SQL_DDL.sql
```

- Contiene **82 tablas**, índices, llaves foráneas y los `INSERT` de datos de prueba
  (incluye los usuarios del login en `XEUSU_USUAR`).
- Alternativa incluida en este proyecto: la carpeta `database/` trae los scripts
  equivalentes en SQL Server para las tablas del módulo (`01_seguridad_tablas_sqlserver.sql`
  a `05_personal_empleado_tabpage_sqlserver.sql`), idempotentes y con los datos de prueba.
- Se ejecutó en SSMS conectándose a `localhost` con Windows Authentication.
  > 💡 En SSMS 22 el diálogo de conexión debe tener **Cifrar = Opcional**
  > (o marcar "Confiar en el certificado de servidor"), porque el SQL Server local
  > usa un certificado autofirmado y por defecto SSMS exige cifrado verificado.

---

## 2. Cambios en el código para igualar al Java

### 2.1 `Models/UsuarioRepository.cs` — criterio de login

En el Java (`UsuarioDAO.java`, línea 32) el login es por **código de persona**.
El .NET estaba buscando por cédula/correo/pasaporte, lo cual **no** coincidía. Se igualó:

```csharp
// ANTES (.NET)
"WHERE (p.PEPER_CEDULA = @ident OR p.PEPER_EMAIL = @ident OR p.PEPER_PASAPO = @ident) " +
"  AND u.XEUSU_PASWD = @pass "

// DESPUÉS (.NET) — igual que UsuarioDAO.java
"WHERE u.PEPER_CODIGO = @ident " +
"  AND u.XEUSU_PASWD = @pass "
```

Referencia Java (`src/main/java/ec/edu/chango/modelo/UsuarioDAO.java`):

```java
"WHERE u.PEPER_CODIGO = ? "
+ "  AND u.XEUSU_PASWD = ? "
```

También se actualizó el comentario XML de la clase para documentar que es
réplica del `UsuarioDAO` del proyecto Java.

### 2.2 `Controllers/AccountController.cs` — mensaje de error

```csharp
// ANTES
ViewBag.Error = "La identificación o la contraseña no son correctas.";

// DESPUÉS
ViewBag.Error = "El código de usuario o la contraseña no son correctos.";
```

### 2.3 `Views/Account/Index.cshtml` — vista del login

| Línea | Antes | Después |
|---|---|---|
| Título pestaña | `Iniciar sesion \| SIGH` | `Iniciar sesión \| SIGH` |
| Encabezado | `Inicio de sesion` | `Inicio de sesión` |
| Alerta de error | `@Html.Encode(ViewBag.Error)` | `@ViewBag.Error` |
| Etiqueta campo | `Cedula, correo o pasaporte` | `Código de usuario` |
| Placeholder | `Ej.: 0102030405` | `Ej.: P000000001` |
| Etiqueta password | `Contrasea` | `Contraseña` |
| Texto de ayuda | "con la cedula, el correo o el pasaporte..." | "con el código de persona..." |

Notas técnicas:

- `@Html.Encode(...)` producía **doble codificación** (Razor ya codifica por sí solo):
  "identificación" se mostraba como `identificaci&#243;n`. Se quitó el `Html.Encode`.
- Los textos `Contrasea`, `Cedula`, `sesion` venían mal escritos en el archivo
  (pérdida de ñ/ó por codificación al crearlo). Se corrigieron.

### 2.4 `Scripts/login.js` — validación del formulario

```javascript
// ANTES
alert("Por favor, ingrese su cédula, correo o pasaporte.");

// DESPUÉS
alert("Por favor, ingrese su código de usuario.");
```

---

## 3. Consultas .NET vs Java (estado actual)

| Operación | Java | .NET | ¿Iguales? |
|---|---|---|---|
| Autenticar usuario | `WHERE u.PEPER_CODIGO = ? AND u.XEUSU_PASWD = ?` | `WHERE u.PEPER_CODIGO = @ident AND u.XEUSU_PASWD = @pass` | ✅ |
| Listar perfiles | `XEUXP_FECRET IS NULL OR XEUXP_FECRET >= CURDATE()` | `XEUXP_FECRET IS NULL OR XEUXP_FECRET >= CAST(GETDATE() AS DATE)` | ✅ (CURDATE → GETDATE por el cambio de motor) |
| Departamentos (CRUD) | `PEDEP_DEPAR` por `PEDEP_CODIGO` | igual | ✅ |
| Cargos (CRUD) | `PECAR_CARGO` por `(PEDEP_CODIGO, PECAR_CODIGO)` | igual | ✅ |

---

## 4. Credenciales de prueba (datos del DDL)

| Código de usuario | Contraseña | Persona | Estado |
|---|---|---|---|
| `P000000001` | `Admin123` | CHANGO JOSUE | ✅ Activo |
| `P000000002` | `User1234` | PEREZ MARIA | ✅ Activo |
| `P000000003` | `Bloqueado1` | GOMEZ CARLOS | ❌ Bloqueado (rechaza el login a propósito) |

---

## 5. Pendientes / observaciones

1. **Doble codificación en otras vistas**: `Bienvenida/Index.cshtml`, `Departamento/Index.cshtml`
   y `Cargo/Index.cshtml` usan el patrón `@Html.Encode(...)` en todo el markup. Con datos
   que contengan ñ/ó (nombres, descripciones de la BD) se verán como `&#243;`, `&#241;`, etc.
   Solución: quitar los `Html.Encode` y dejar que Razor codifique solo. No se hizo en esta
   pasada porque solo afecta a datos con acentos; aplicar el mismo cambio del login si aparece.
2. **Fotos de perfil**: la bienvenida referencia `~/resources/{foto}`; los archivos del Java
   (`josue1.jpeg`, `monster1.jpeg`, etc.) están en
   `SIGH_JAVA_MySQL_GR02\04. PROTOTIPO\01. APLICATIVO\SIGH_JAVA_MySQL_GR02\src\main\webapp\resource\`.
   Si la imagen no aparece, copiarlos a `WebConMVCDotnet\resources\`.
3. **Reportes JasperReports** (`.jrxml` del Java): no tienen equivalente aún en el .NET;
   si se necesitan, habría que migrarlos (por ejemplo a RDLC/Crystal o PDF con otra librería).
