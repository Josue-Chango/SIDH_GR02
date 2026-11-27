# Cambios de la migración Java → .NET (con SQL Server)

Proyecto: `WebConMVCDotnet` (ASP.NET MVC 5, .NET Framework 4.7.2)
Proyecto original: `CRUD_conMVC_JAVA_GR02` (Java + MySQL — login, CRUDs y reportes)
DDL completo de la base: `SIGH_JAVA_MySQL_GR02` (Java 21 + MySQL, 82 tablas)
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
  equivalentes en SQL Server para las tablas del módulo:
  `01_seguridad_tablas_sqlserver.sql` (crea `sigh_gr02` y las tablas del módulo),
  `02_seguridad_datos_prueba_sqlserver.sql` (usuarios y perfiles de prueba),
  `03_personal_departamento_sqlserver.sql` (tabla `PEDEP_DEPAR` y sus datos),
  `04_personal_cargo_sqlserver.sql` (tabla `PECAR_CARGO`) y
  `05_personal_empleado_sqlserver.sql` (Tab Page del empleado: `PEACA_ACADE`
  y `PEFAM_FAMIL` más datos de prueba).
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

### 2.5 `Views/Bienvenida/Index.cshtml` y `Views/Departamento/Index.cshtml` — doble codificación

Se aplicó el mismo arreglo del login: se quitó `Html.Encode(...)` de todas las
salidas Razor (`@Html.Encode(x)` → `@x`), porque Razor ya codifica por sí solo
y el doble paso mostraba `&#243;`, `&#241;`, etc. en los datos con acentos
(nombres, apellidos, descripciones). Se conservó `HttpUtility.HtmlEncode(foto)`
dentro de `Url.Content(...)`, que ahí sí es necesario para construir la URL de
la imagen.

### 2.6 `database/02_seguridad_datos_prueba_sqlserver.sql` — acentos de los perfiles

Las descripciones de los perfiles venían con caracteres perdidos al crear el
archivo (`M??dico`, `m??dulo cl??nico`, `b??sico`). Se corrigieron a
`Médico`, `módulo clínico` y `básico`. Si la base ya tenía los datos viejos,
volver a ejecutar `01_seguridad_tablas_sqlserver.sql` + `02_seguridad_datos_prueba_sqlserver.sql`
(01 borra y recrea las tablas del módulo y 02 recarga los datos de prueba).

### 2.7 Codificación de archivos (tildes rotas: "sesiÃ³n")
Al escribir acentos en las vistas (`Inicio de sesión`, `Contraseña`), la página
mostraba `sesiÃ³n`: los archivos `.cshtml`/`.js` quedaron en **UTF-8 sin BOM** y
ASP.NET los compilaba como Windows-1252, duplicando los bytes de la ñ/ó.
Solución aplicada (doble):

- Todas las vistas, `login.js`, `tabpage.js` y los scripts SQL se guardaron
  como **UTF-8 con BOM**.
- `Web.config` ahora incluye
  `<globalization fileEncoding="utf-8" requestEncoding="utf-8" responseEncoding="utf-8" />`
  como red de seguridad (define UTF-8 para archivos sin BOM y para los formularios).

### 2.8 `Views/Bienvenida/Index.cshtml` — botón "Cerrar sesión" solapado

Al agregar los nuevos módulos, el botón se montaba sobre el último enlace de
la lista: el `<a class="btn-logout">` es `inline-block` y, alineado por
línea base, crecía hacia arriba dentro de su line box. Se envolvió en
`<div class="form-logout">` (clase que ya existía en el CSS con
`margin-top` y `text-align: right`), quedando debajo de la lista de módulos
y alineado a la derecha, como estaba previsto.

También se limpió en la base un residuo de pruebas: `P000000001` tenía el
campo `PEPER_PASAPO` con el valor "Admin123" (la contraseña guardada como
pasaporte); se dejó en `NULL` como el script de datos original.

---

## 3. Consultas .NET vs Java (estado actual)

| Operación | Java | .NET | ¿Iguales? |
|---|---|---|---|
| Autenticar usuario | `WHERE u.PEPER_CODIGO = ? AND u.XEUSU_PASWD = ?` | `WHERE u.PEPER_CODIGO = @ident AND u.XEUSU_PASWD = @pass` | ✅ |
| Listar perfiles | `XEUXP_FECRET IS NULL OR XEUXP_FECRET >= CURDATE()` | `XEUXP_FECRET IS NULL OR XEUXP_FECRET >= CAST(GETDATE() AS DATE)` | ✅ (CURDATE → GETDATE por el cambio de motor) |
| Departamentos (CRUD) | `PEDEP_DEPAR` por `PEDEP_CODIGO` | igual | ✅ |
| Cargos (CRUD) | `PECAR_CARGO` por `(PEDEP_CODIGO, PECAR_CODIGO)`, filtro por departamento | igual | ✅ |
| Empleados (Tab Page) | `PEPER_PERSO` + subtablas `PEACA_ACADE`/`PEFAM_FAMIL` en transacción, foto con firma JPG/PNG | igual (DateTime en vez de DateOnly, `HttpPostedFileBase` en vez de `IFormFile`) | ✅ |
| Reportes PDF | JasperReports: 4 plantillas `.jrxml` (departamentos, cargos agrupados con subtotales, empleados, ficha con subreportes) | vistas Razor de impresión con el mismo diseño (`Content/reportes.css`); PDF con Ctrl+P del navegador | ✅ (ver 6.3) |

---

## 4. Credenciales de prueba (datos del DDL)

| Código de usuario | Contraseña | Persona | Estado |
|---|---|---|---|
| `P000000001` | `Admin123` | CHANGO JOSUE | ✅ Activo |
| `P000000002` | `User1234` | PEREZ MARIA | ✅ Activo |
| `P000000003` | `Bloqueado1` | GOMEZ CARLOS | ❌ Bloqueado (rechaza el login a propósito) |

---

## 5. Segunda pasada: módulos agregados (Cargos, Empleados y Reportes)

Lo que faltaba del proyecto Java, portado sobre el patrón ya establecido
(POST-Redirect-GET, `TempData` como flash, `[FiltroAutenticacion]`,
`[ValidateAntiForgeryToken]` y repositorios con `System.Data.SqlClient`):

### 5.1 CRUD de Cargos — `CargoController` + `CargoRepository` + `Views/Cargo`

- Tabla `PECAR_CARGO` con clave compuesta `(PEDEP_CODIGO, PECAR_CODIGO)`.
- Combobox de departamentos en el formulario; en edición la clave viaja
  bloqueada y solo se puede cambiar la descripción (igual que el Java).
- Listado con **filtro por departamento** (`?filtroDepartamento=`), como el
  `filtroDepartamento` de `cargo.jsp`.
- Mensajes de BD traducidos: duplicados (2601/2627) y llaves que restringen
  eliminar (547), equivalente a `mensajeBD` del `CargoController` de Java.

### 5.2 Mantenimiento de Empleados (Tab Page) — `EmpleadoController` + `EmpleadoRepository` + `Views/Empleado`

Réplica del Tab Page: marco con **foto**, apellidos y nombres, y **tres
pestañas** (`Content/tabpage.css` + `Scripts/tabpage.js`, portados de la
versión .NET de referencia):

1. **Datos Generales**: fecha de nacimiento, sexo, peso, estado civil y tipo de sangre.
2. **Datos Académicos**: subtabla editable `PEACA_ACADE` (filas dinámicas con
   plantillas HTML + JS; filas vacías se descartan).
3. **Datos Familiares**: subtabla editable `PEFAM_FAMIL` (parentesco, nombres,
   fecha de nacimiento).

Detalles de fidelidad con el Java:

- La persona y sus subtablas se guardan **dentro de una transacción** (todo o nada).
- La foto se valida por **firma binaria** (solo JPG `FF D8 FF` o PNG `89 50 4E 47…`),
  se guarda en `~/resources/fotos_empleados/{codigo}.{ext}` y se borra al eliminar
  el empleado.
- Validaciones: código `[A-Za-z0-9-]{1,10}`, fechas no futuras, tamaños máximos
  por columna, sexo obligatorio y tipos de sangre/parentescos de catálogo.
- `UPDATE` reemplaza el contenido completo de las subtablas (borrar + insertar),
  igual que `EmpleadoDAO`.

### 5.3 Reportes — `ReporteController` + `ReportesRepository` + `Views/Reporte`

Los **4 reportes** del Java (`departamentos.jrxml`, `cargos.jrxml`,
`empleados.jrxml`, `empleado_ficha.jrxml`) migran como vistas Razor de
impresión con el mismo diseño (paleta Jasper: vino `#4E0A0B`, crema `#F1E7DC`):

| Ruta | Contenido | Equivalente Java |
|---|---|---|
| `/Reporte/Departamentos` | listado + total | `departamentos.jrxml` |
| `/Reporte/Cargos?departamento=SIS` | agrupado por departamento **con subtotales** y subtítulo del filtro | `cargos.jrxml` |
| `/Reporte/Empleados` | listado con sexo y estado civil + total | `empleados.jrxml` |
| `/Reporte/Ficha?codigo=P000000001` | foto + datos generales + 2 subreportes (académicos y familiares) + firmas | `empleado_ficha.jrxml` |

- Cada reporte abre en una pestaña nueva con botón **"Imprimir / Guardar PDF"**
  (el PDF sale del diálogo del navegador, `Ctrl+P` → "Guardar como PDF").
  Se eligió esto en lugar de FastReport/Jasper porque no agrega dependencias
  NuGet al proyecto .NET Framework y el resultado impreso es idéntico.
- Incluye los parámetros del Jasper: **USUARIO** (sesión), **FECHA** (zona
  `SA Pacific Standard Time`, como `America/Guayaquil` en el Java) y
  **MENSAJE_TOTAL** ("Cargos: 19", o aviso sin datos).
- El filtro de cargos por departamento y la validación de códigos replican el
  `ReporteController.java`.
- Si la base no responde, se muestra una vista amable (`SinDatos.cshtml`) en
  lugar del error crudo de IIS.

### 5.4 Registro de los archivos nuevos en `WebConMVCDotnet.csproj`

Al ser un proyecto .NET Framework clásico (no SDK), los archivos nuevos se
agregaron a mano en el `.csproj` (`<Compile>` para `.cs`, `<Content>` para
`.cshtml`, `.css` y `.js`). Si creas archivos nuevos, recuérdalo.

---

## 6. Pendientes / observaciones

1. **Fotos de perfil**: la bienvenida y las fichas referencian
   `~/resources/{foto}`; los archivos del Java (`josue1.jpeg`, `monster1.jpeg`,
   `deivis1.png.jpg`, etc.) están en
   `SIGH_JAVA_MySQL_GR02\04. PROTOTIPO\01. APLICATIVO\SIGH_JAVA_MySQL_GR02\src\main\webapp\resource\`.
   Si una imagen no aparece (404 en el log de IIS), copiarlos a `WebConMVCDotnet\resources\`.
   Los datos de prueba de empleados apuntan a `josue1.jpeg`, `deivis1.png.jpg`
   y a una foto vacía.
2. **PDF del lado servidor**: si más adelante se requieren PDF generados por el
   servidor (sin diálogo de impresión), la vía es FastReport OpenSource
   2023.x (soporta .NET Framework) portando `FabricaReportes` de la versión
   .NET Core de referencia (`03. DOTNET\CRUD_REPORTES_DOTNET_GR02`), o migrar el
   proyecto completo a .NET Core/5+.
