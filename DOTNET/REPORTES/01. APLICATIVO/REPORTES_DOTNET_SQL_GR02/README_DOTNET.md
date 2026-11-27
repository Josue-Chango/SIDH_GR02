# Login + CRUD .NET con MVC (SIGH_GR02)

Aplicación **ASP.NET MVC 5 (.NET Framework 4.7.2)** que replica en .NET y SQL Server
el mismo módulo que el proyecto Java (`CRUD_conMVC_JAVA_GR02`):
un **login** por **código de usuario** (`PEPER_CODIGO`) + contraseña sobre el
subsistema de Seguridad, el **CRUD de Departamentos** (`PEDEP_DEPAR`), el
**CRUD de Cargos** con clave compuesta (`PECAR_CARGO`), el **Mantenimiento de
Empleados con Tab Page** (`PEPER_PERSO` + subtablas de datos académicos y
familiares) y los **4 Reportes PDF** que en Java se hacían con JasperReports.

## 1. Base de datos (SQL Server)

El proyecto está probado contra un **SQL Server local** (`localhost`, instancia
por defecto `MSSQLSERVER`, Windows Authentication) con la base `sigh_gr02`.

Si necesitas recrear la base (o solo el módulo de Seguridad), en la carpeta
`database` del proyecto están los scripts equivalentes en SQL Server:

```text
database/01_seguridad_tablas_sqlserver.sql        # crea sigh_gr02 y las tablas del módulo
database/02_seguridad_datos_prueba_sqlserver.sql  # usuarios, perfiles y datos de prueba
database/03_personal_departamento_sqlserver.sql   # tabla PEDEP_DEPAR y sus datos
database/04_personal_cargo_sqlserver.sql          # tabla PECAR_CARGO (clave compuesta)
database/05_personal_empleado_sqlserver.sql       # Tab Page del empleado: PEACA_ACADE, PEFAM_FAMIL + datos
```

Se ejecutan con `sqlcmd`, SSMS o Azure Data Studio sobre la instancia indicada
en `Web.config`. Los dos primeros se pueden re-ejecutar (01 borra y recrea las
tablas del módulo, 02 recarga los datos).

> 💡 En SSMS 22 el diálogo de conexión debe tener **Cifrar = Opcional**
> (o marcar "Confiar en el certificado de servidor"), porque el SQL Server local
> usa un certificado autofirmado y por defecto SSMS exige cifrado verificado.

## 2. Cadena de conexión

En `WebConMVCDotnet/Web.config`:

```xml
<connectionStrings>
  <add name="SighGrab02"
       connectionString="Data Source=localhost;Initial Catalog=sigh_gr02;Integrated Security=True;"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

Si usas un SQL Server distinto, solo cambia el `Data Source` y las credenciales.

## 3. Ejecutar en Visual Studio

1. Abre la solución `WebConMVCDotnet.sln`.
2. Verifica que el proyecto de inicio sea `WebConMVCDotnet`.
3. Presiona **F5** (o **Ctrl + F5**).

La URL inicial que se abre está registrada para el puerto configurado en el
`.csproj` (IIS Express). La ruta por defecto es `/Account/Index`, que muestra el
login. Puedes probar también la URL manual `http://localhost:<puerto>/Account/Index`.

## 4. Usuarios de prueba

Las mismas credenciales del proyecto Java (datos del script `02_seguridad_datos_prueba_sqlserver.sql`):

| Código de usuario | Contraseña | Persona | Perfil | Estado | Resultado |
|-------------------|-------------|---------|--------|--------|-----------|
| `P000000001` | `Admin123` | CHANGO JOSUE | ADMIN | ACTIVO | ingresa al panel de bienvenida |
| `P000000002` | `User1234` | PEREZ MARIA | USUARIO | ACTIVO | ingresa al panel de bienvenida |
| `P000000003` | `Bloqueado1` | GOMEZ CARLOS | USUARIO | BLOQUEADO | rechazado con mensaje |

El campo del formulario es **Código de usuario** (`P000000001`, etc.), igual que
el `PEPER_CODIGO` del login Java; no acepta cédula, correo ni pasaporte.

## 5. CRUD de Departamentos

Una vez iniciada la sesión, desde el panel de bienvenida entra al enlace
**Gestión de Departamentos (Personal)**, que abre `/Departamento/Index`.

| Acción | Ruta | Descripción |
|--------|------|-------------|
| Listar | `GET /Departamento/Index` | tabla con todos los departamentos |
| Nuevo  | `GET /Departamento/Nuevo`  | formulario vacío |
| Editar | `GET /Departamento/Editar?codigo=X01` | formulario precargado |
| Guardar| `POST /Departamento/Guardar` | inserta o actualiza; usa `token` anti-CSRF |
| Eliminar| `POST /Departamento/Eliminar` | elimina por código |

El controlador repite el patrón POST-Redirect-GET del proyecto Java y los
mensajes de éxito o error se muestran una sola vez con `TempData`.

## 6. CRUD de Cargos

Enlace **Gestión de Cargos (Personal)**, que abre `/Cargo/Index`. Clave
compuesta `(PEDEP_CODIGO, PECAR_CODIGO)`: el código de cargo puede repetirse
en otro departamento.

| Acción | Ruta | Descripción |
|--------|------|-------------|
| Listar / filtrar | `GET /Cargo/Index?filtroDepartamento=SIS` | tabla filtrable por departamento |
| Nuevo  | `GET /Cargo/Nuevo`  | formulario con combobox de departamentos |
| Editar | `GET /Cargo/Editar?departamento=SIS&codigo=ADM` | precargado; la clave se bloquea y solo cambia la descripción |
| Guardar| `POST /Cargo/Guardar` | inserta (o actualiza en edición) con token anti-CSRF |
| Eliminar| `POST /Cargo/Eliminar` | elimina por la clave compuesta |

## 7. Mantenimiento de Empleados (Tab Page)

Enlace **Mantenimiento de Empleados (Tab Page)**, que abre
`/Empleado?accion=nuevo`. Réplica del Tab Page del proyecto Java: marco con
foto, apellidos y nombres, y tres pestañas:

1. **Datos Generales** — fecha de nacimiento, sexo, peso, estado civil y tipo de sangre.
2. **Datos Académicos** — subtabla dinámica (`PEACA_ACADE`): nivel, institución y título.
3. **Datos Familiares** — subtabla dinámica (`PEFAM_FAMIL`): parentesco, nombres y fecha.

| Acción | Ruta | Descripción |
|--------|------|-------------|
| Nuevo  | `GET /Empleado?accion=nuevo` | ficha vacía con una fila en cada subtabla |
| Editar | `GET /Empleado?accion=editar&codigo=P000000001` | carga empleado + subtablas |
| Guardar| `POST /Empleado/Guardar` | persona + subtablas dentro de una transacción; foto JPG/PNG (validada por firma binaria) guardada en `~/resources/fotos_empleados/` |
| Eliminar| `POST /Empleado/Eliminar` | borra la ficha (las subtablas se van en cascada) y su foto |

Las filas vacías de las subtablas se descartan al guardar, igual que en el Java.

## 8. Reportes (PDF)

Enlace **Reportes (PDF)**, que abre `/Reporte/Index`. Los 4 reportes del Java
(`.jrxml` de JasperReports) se replican como vistas con el mismo diseño
(paleta Jasper: vino y crema) y botón **"Imprimir / Guardar PDF"** (Ctrl+P):

| Reporte | Ruta | Detalle |
|---------|------|---------|
| Departamentos | `/Reporte/Departamentos` | listado + total |
| Cargos | `/Reporte/Cargos?filtroDepartamento=` | agrupado por departamento con **subtotales**; filtro opcional |
| Empleados | `/Reporte/Empleados` | listado con sexo y estado civil + total |
| Ficha del empleado | `/Reporte/Ficha?codigo=P000000001` | foto + datos generales + subtablas académicos/familiares + firmas |

Cada PDF incluye "Generado por" (usuario de la sesión), fecha/hora de Ecuador
y el mensaje de total, como en los PDF de JasperReports del Java.

## 9. Seguridad de sesiones

- `AccountController.Index` (POST) crea la sesión con `Session["Usuario"]`.
- `BienvenidaController` y `DepartamentoController` llevan el atributo
  `[FiltroAutenticacion]`, que redirige a `/Account/Index` si no hay sesión.
- `AccountController.Logout` hace `Session.Clear()` + `Session.Abandon()` y
  redirige al login, igual que el `LogoutController` de Java.
- Las conexiones SQL Server se abren y cierran con `using`, por lo que no quedan
  conexiones abiertas ni fallas de sesión sin cerrar.

## 10. Equivalencia con el proyecto Java

| Java (`CRUD_conMVC_JAVA_GR02`) | .NET (`WebConMVCDotnet`) |
|---|---|
| `LoginController.java` | `Controllers/AccountController.cs` (GET/POST `Index`) |
| `LogoutController.java` | `AccountController.Logout` |
| `UsuarioDAO.java` | `Models/UsuarioRepository.cs` |
| `DepartamentoDAO.java` | `Models/DepartamentoRepository.cs` |
| `DepartamentoController.java` | `Controllers/DepartamentoController.cs` |
| `CargoDAO.java` | `Models/CargoRepository.cs` |
| `CargoController.java` | `Controllers/CargoController.cs` |
| `EmpleadoDAO.java` | `Models/EmpleadoRepository.cs` (transacción + subtablas) |
| `EmpleadoController.java` | `Controllers/EmpleadoController.cs` (Tab Page con foto) |
| `Empleado.java`, `EmpleadoAcademico.java`, `EmpleadoFamiliar.java` | `Models/Empleado.cs`, `EmpleadoAcademico.cs`, `EmpleadoFamiliar.cs` |
| `ReporteController.java` + `ReportesJasper.java` + `.jrxml` | `Controllers/ReporteController.cs` + `Models/ReportesRepository.cs` + `Views/Reporte/*` + `Content/reportes.css` |
| `FiltroAutenticacion.java` | `App_Start/FiltroAutenticacion.cs` |
| Vistas JSP (login, bienvenida, cargo, empleado, reportes) | `Views/Account`, `Views/Bienvenida`, `Views/Cargo`, `Views/Empleado`, `Views/Reporte` |
| `ConexionBD.java` (JDBC + MySQL) | `Models/ConexionBD.cs` (SqlClient + SQL Server) |
| `tabpage.css` / `tabpage.js` del prototipo .NET | `Content/tabpage.css` + `Scripts/tabpage.js` |

Detalle completo de los cambios: ver `CAMBIOS_MIGRACION_JAVA_A_DOTNET.md`.
