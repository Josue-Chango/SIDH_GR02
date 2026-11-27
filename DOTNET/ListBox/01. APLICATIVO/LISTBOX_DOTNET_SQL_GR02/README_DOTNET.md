# Login + CRUD .NET con MVC (SIGH_GR02)

Aplicación **ASP.NET MVC 5 (.NET Framework 4.7.2)** que replica en .NET y SQL Server
el mismo módulo que el proyecto Java (`CRUD_conMVC_JAVA_GR02`):
un **login** con cédula / correo / pasaporte + contraseña sobre el subsistema de
Seguridad, un **CRUD de Departamentos** sobre la tabla `PEDEP_DEPAR` y un
**CRUD de Cargos** sobre la tabla `PECAR_CARGO` (clave compuesta departamento +
cargo, con buscador por departamento).

## 1. Base de datos (SQL Server)

El proyecto está probado contra **SQL Server LocalDB** (`(localdb)\MSSQLLocalDB`)
con la base `sigh_gr02`. Las tablas del módulo ya están cargadas en la base
`sigh_gr02` del equipo, con los mismos usuarios de prueba del proyecto Java.

Si necesitas recrear la base, en la carpeta `database` del proyecto están los
scripts equivalentes:

```text
database/01_seguridad_tablas_sqlserver.sql
database/02_seguridad_datos_prueba_sqlserver.sql
database/03_personal_departamento_sqlserver.sql
database/04_personal_cargo_sqlserver.sql
```

Se ejecutan con `sqlcmd`, SSMS o Azure Data Studio sobre la instancia indicada
en `Web.config`.

## 2. Cadena de conexión

En `WebConMVCDotnet/Web.config`:

```xml
<connectionStrings>
  <add name="SighGrab02"
       connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=sigh_gr02;Integrated Security=True;"
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

Las mismas credenciales del proyecto Java:

| Identificación | Contraseña | Perfil | Estado | Resultado |
|----------------|------------|--------|--------|-----------|
| `0102030405`   | `Admin123` | ADMIN  | ACTIVO | ingresa al panel de bienvenida |
| `maria.perez@example.com` | `User1234` | USUARIO | ACTIVO | ingresa al panel de bienvenida |
| `AB1234567`    | `Bloqueado1` | USUARIO | BLOQUEADO | rechazado con mensaje |

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

## 6. Seguridad de sesiones

- `AccountController.Index` (POST) crea la sesión con `Session["Usuario"]`.
- `BienvenidaController`, `DepartamentoController` y `CargoController` llevan
  el atributo `[FiltroAutenticacion]`, que redirige a `/Account/Index` si no
  hay sesión.
- `AccountController.Logout` hace `Session.Clear()` + `Session.Abandon()` y
  redirige al login, igual que el `LogoutController` de Java.
- Las conexiones SQL Server se abren y cierran con `using`, por lo que no quedan
  conexiones abiertas ni fallas de sesión sin cerrar.

## 7. CRUD de Cargos

Una vez iniciada la sesión, desde el panel de bienvenida entra al enlace
**Gestión de Cargos (Personal)**, que abre `/Cargo/Index`.

| Acción | Ruta | Descripción |
|--------|------|-------------|
| Listar | `GET /Cargo/Index` | tabla con los cargos y el buscador por departamento |
| Filtrar| `GET /Cargo/Index?filtroDepartamento=SIS` | solo los cargos del departamento indicado |
| Editar | `GET /Cargo/Editar?departamento=SIS&codigo=ADM&filtroDepartamento=SIS` | formulario precargado; conserva el filtro |
| Guardar| `POST /Cargo/Guardar` | inserta o actualiza; usa token anti-CSRF |
| Eliminar| `POST /Cargo/Eliminar` | elimina por la clave compuesta (departamento, cargo) |

Comportamiento equivalente al proyecto Java:

- La clave primaria de `PECAR_CARGO` es compuesta: el mismo código de cargo
  (por ejemplo `ADM`) puede repetirse en departamentos distintos.
- Al editar solo cambia la descripción: el departamento y el código se
  conservan (campos de solo lectura).
- El buscador «Buscar cargos por departamento» actualiza el listado al
  seleccionar un departamento; «Todos los departamentos» lo restaura, y el
  filtro se conserva tras guardar, eliminar o cancelar una edición.
- La eliminación y el cambio de código de un departamento con cargos quedan
  restringidos por la llave foránea (error 547 de SQL Server, equivalente a
  los errores 1451/1452 de MySQL); la aplicación muestra el mensaje
  correspondiente.
- Si SQL Server no está disponible, la vista se muestra con un mensaje y el
  estado HTTP 503 y un enlace «Reintentar», sin bucles de redirección.

Si la tabla `PECAR_CARGO` no existe todavía, ejecute el script
`database/04_personal_cargo_sqlserver.sql` después de tener `PEDEP_DEPAR`.
