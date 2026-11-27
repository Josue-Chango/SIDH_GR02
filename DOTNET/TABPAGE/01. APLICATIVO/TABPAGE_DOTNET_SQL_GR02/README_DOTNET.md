# Login + CRUD .NET con MVC (SIGH_GR02)

Aplicación **ASP.NET MVC 5 (.NET Framework 4.7.2)** que replica en .NET y SQL Server
el mismo módulo que el proyecto Java (`CRUD_conMVC_JAVA_GR02`):

- **Login** con **código de usuario** (`PEPER_CODIGO` de la tabla `XEUSU_USUAR`)
  + contraseña sobre el subsistema de Seguridad, igual que el `UsuarioDAO` del proyecto Java.
- **CRUD de Departamentos** sobre la tabla `PEDEP_DEPAR`.
- **CRUD de Cargos** sobre la tabla `PECAR_CARGO` (clave compuesta) con buscador por departamento.
- **Mantenimiento de Empleados con Tab Page** sobre `PEPER_PERSO` + subtablas
  `PEACA_ACADE` (Datos Académicos) y `PEFAM_FAMIL` (Datos Familiares).

## 1. Base de datos (SQL Server)

El proyecto está probado contra **SQL Server local** (`localhost`, instancia
`MSSQLSERVER`) con la base `sigh_gr02`. Las tablas del módulo ya están cargadas
en la base `sigh_gr02` del equipo, con los mismos usuarios de prueba del
proyecto Java.

Si necesitas recrear la base, en la carpeta `database` del proyecto están los
scripts equivalentes:

```text
database/01_seguridad_tablas_sqlserver.sql
database/02_seguridad_datos_prueba_sqlserver.sql
database/03_personal_departamento_sqlserver.sql
database/04_personal_cargo_sqlserver.sql
database/05_personal_empleado_tabpage_sqlserver.sql
```

Se ejecutan con `sqlcmd`, SSMS o Azure Data Studio sobre la instancia indicada
en `Web.config`. Los scripts 04 y 05 se pueden ejecutar varias veces sin
dañar datos: solo crean tablas/columnas si no existen y los datos de prueba
se insertan únicamente si están vacíos.

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

Las mismas credenciales del proyecto Java (login por **código de usuario**):

| Código de usuario | Contraseña | Persona | Estado | Resultado |
|-------------------|------------|------------------|--------|-----------|
| `P000000001` | `Admin123` | CHANGO JOSUE | ACTIVO | ingresa al panel de bienvenida |
| `P000000002` | `User1234` | PEREZ MARIA | ACTIVO | ingresa al panel de bienvenida |
| `P000000003` | `Bloqueado1` | GOMEZ CARLOS | BLOQUEADO | rechazado con mensaje |

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

Desde el panel de bienvenida entra a **Gestión de Cargos (Personal)**, que abre
`/Cargo/Index`. La clave primaria es compuesta: **(PEDEP_CODIGO, PECAR_CODIGO)**;
al editar se conservan departamento y código y solo cambia la descripción.

| Acción | Ruta | Descripción |
|--------|------|-------------|
| Listar | `GET /Cargo/Index` | listado completo + formulario nuevo |
| Filtro | `GET /Cargo/Index?filtroDepartamento=SIS` | solo los cargos de ese departamento |
| Editar | `GET /Cargo/Editar?departamento=SIS&codigo=PRO` | formulario precargado |
| Guardar| `POST /Cargo/Guardar` | inserta o actualiza |
| Eliminar| `POST /Cargo/Eliminar` | elimina por la clave compuesta |

El combobox «Buscar cargos por departamento» consulta al cambiar la selección y
el filtro se conserva tras guardar, eliminar o cancelar una edición, igual que
en el proyecto Java.

## 7. Mantenimiento de Empleados (Tab Page)

Desde el panel de bienvenida entra a **Mantenimiento de Empleados (Tab Page)**,
que abre `/Empleado/Index`. La ficha replica el Tab Page del proyecto Java:
marco superior con foto, apellidos y nombres, y tres pestañas:

1. **Datos Generales**: sexo, peso, estado civil, tipo de sangre y cargas familiares.
2. **Datos Académicos**: grilla editable (subtabla `PEACA_ACADE`).
3. **Datos Familiares**: grilla editable (subtabla `PEFAM_FAMIL`).

| Acción | Ruta | Descripción |
|--------|------|-------------|
| Listar | `GET /Empleado/Index` | listado con foto en miniatura |
| Editar | `GET /Empleado/Editar?codigo=P000000001` | ficha precargada con sus subtablas |
| Guardar| `POST /Empleado/Guardar` | inserta o actualiza dentro de una transacción (persona + subtablas) |
| Eliminar| `POST /Empleado/Eliminar` | elimina la persona; las subtablas se borran por `ON DELETE CASCADE` |

La foto se sube desde el marco de la ficha (JPG o PNG), se convierte a JPEG y
se guarda en `resources/fotos_empleados/{código}.jpg`; las filas de las grillas
se agregan y quitan con `Scripts/tabpage.js` y el estilo del Tab Page está en
`Content/tabpage.css`.

## 8. Seguridad de sesiones

- `AccountController.Index` (POST) crea la sesión con `Session["Usuario"]`.
- `BienvenidaController` y `DepartamentoController` llevan el atributo
  `[FiltroAutenticacion]`, que redirige a `/Account/Index` si no hay sesión.
- `AccountController.Logout` hace `Session.Clear()` + `Session.Abandon()` y
  redirige al login, igual que el `LogoutController` de Java.
- Las conexiones SQL Server se abren y cierran con `using`, por lo que no quedan
  conexiones abiertas ni fallas de sesión sin cerrar.
