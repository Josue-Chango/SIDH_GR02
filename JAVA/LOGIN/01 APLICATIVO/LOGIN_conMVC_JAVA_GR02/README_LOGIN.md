# Login SIGH - MÃ³dulo de Seguridad

Aplicativo web Jakarta EE (NetBeans + MVC) con inicio de sesiÃ³n contra la tabla
**USUARIO (`XEUSU_USUAR`)** del diagrama de Seguridad de PowerDesigner
(`SIGH_GR02_clases.oom`).

El login usa la persona asociada (`PEPER_PERSO`) para identificar al usuario por
**cÃ©dula, correo electrÃ³nico o pasaporte**, y valida la contraseÃ±a almacenada en
`XEUSU_USUAR`. TambiÃ©n carga los perfiles activos desde `XEUXP_USUPE` y
`XEPER_PERFI`.

## Estructura MVC

| Capa | Archivos |
|------|----------|
| Modelo | `modelo/Usuario.java`, `modelo/Persona.java`, `modelo/Perfil.java`, `modelo/UsuarioDAO.java` |
| Vista | `index.jsp` (login), `bienvenida.jsp` (pÃ¡gina privada), `css/style_JCH.css`, `js/login.js` |
| Controlador | `controlador/LoginController.java`, `controlador/LogoutController.java`, `controlador/FiltroAutenticacion.java` |
| Utilidades | `util/ConexionBD.java`, `util/Html.java` |
| Base de datos | `database/01_seguridad_tablas.sql`, `database/02_seguridad_datos_prueba.sql` |
| Modelo Personal | `modelo/Departamento.java`, `modelo/DepartamentoDAO.java` (CRUD DEPARTAMENTO) |
| Vista Personal | `departamento.jsp` (CRUD DEPARTAMENTO) |
| Controlador Personal | `controlador/DepartamentoController.java` (CRUD DEPARTAMENTO) |
| Base de datos Personal | `database/03_personal_departamento_datos_prueba.sql` |

## 1. Preparar la base de datos

La aplicaciÃ³n usa la base **`sigh_gr02`**, creada al importar el DDL completo
`SIGH_GR02_MySQL_DDL` en MySQL Workbench.

Sobre esa base ejecute Ãºnicamente el script de datos de prueba:

```sql
source C:/Users/josue/Documents/LOGIN/JAVA/LOGIN_conMVC_JAVA_GR02/database/02_seguridad_datos_prueba.sql;
```

TambiÃ©n puede abrirlo desde MySQL Workbench y ejecutar todo el script.

El script carga los catÃ¡logos, las personas, los usuarios, los perfiles y sus
asignaciones en las tablas del mÃ³dulo de Seguridad: `PEPER_PERSO`,
`XEUSU_USUAR`, `XEEST_ESTAD`, `XEPER_PERFI`, `XEUXP_USUPE`, `XEOPC_OPCIO`,
`XEOXP_OPCPE`, `XESIS_SISTE`, `PEGEN_GENERO` y `PEESC_ESTCIV`.

> Si su base tiene otro nombre, cambie el `USE` al inicio del script `02` y
> tambiÃ©n `db.url` en `db.properties`.

### OpciÃ³n alternativa: base `sigh` independiente

Si no desea usar `sigh_gr02`, el archivo `database/01_seguridad_tablas.sql`
crea una base llamada `sigh` solo con las tablas del mÃ³dulo de Seguridad.
En ese caso ejecute el `01`, luego el `02` (cambiando su `USE` a `sigh`) y
ajuste `db.url` en `db.properties`.

## 2. Configurar la conexiÃ³n

Edite:

`src/main/resources/db.properties`

```properties
db.url=jdbc:mysql://localhost:3306/sigh_gr02?useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=America/Guayaquil
db.user=root
db.password=
db.driver=com.mysql.cj.jdbc.Driver
```

Coloque la contraseÃ±a real de su usuario de MySQL en `db.password`.
Si MySQL escucha en otro puerto, cambie `3306`.

TambiÃ©n se pueden usar las variables de entorno `DB_URL`, `DB_USER`,
`DB_PASSWORD` y `DB_DRIVER` sin editar el archivo.

## 3. Ejecutar en NetBeans

1. Abra el proyecto `LOGIN_conMVC_JAVA_GR02`.
2. Verifique que Payara Server estÃ© configurado (el proyecto ya apunta a Payara).
3. Ejecute **Run Project**.
4. Se abrirÃ¡ `index.jsp` con el formulario de inicio de sesiÃ³n.

El driver `mysql-connector-j` ya estÃ¡ agregado al `pom.xml` y se empaqueta en el
WAR, por lo que no hace falta copiarlo manualmente al servidor.

## 4. Usuarios de prueba

| IdentificaciÃ³n | ContraseÃ±a | Perfil | Resultado |
|----------------|------------|--------|-----------|
| `0102030405` (cÃ©dula) | `Admin123` | ADMIN | Ingresa |
| `maria.perez@example.com` (correo) | `User1234` | USUARIO | Ingresa |
| `AB1234567` (pasaporte) | `Bloqueado1` | USUARIO | Rechazado por estado BLOQUEADO |

## 5. Flujo implementado

1. `index.jsp` envÃ­a el formulario a `LoginController`.
2. `LoginController` llama a `UsuarioDAO.autenticar(...)`.
3. `UsuarioDAO` ejecuta una consulta preparada con `JOIN` entre `XEUSU_USUAR` y
   `PEPER_PERSO`, y busca por cÃ©dula, correo o pasaporte + contraseÃ±a.
4. Si las credenciales son correctas y el estado no es inactivo/bloqueado, se
   crea una sesiÃ³n nueva con el atributo `usuario`.
5. `bienvenida.jsp` muestra los datos de la persona, el estado y los perfiles.
6. `LogoutController` invalida la sesiÃ³n.
7. `FiltroAutenticacion` impide abrir `bienvenida.jsp` sin sesiÃ³n.

## 6. CRUD de DEPARTAMENTO (modulo de Personal)

La aplicacion incluye un CRUD de la tabla **DEPARTAMENTO (`PEDEP_DEPAR`)** del
diagrama de Personal (`SIGH_GR02_clases.oom`): codigo `PEDEP_CODIGO`
(CHAR(3), clave primaria) y descripcion `PEDEP_DESCRI` (VARCHAR(50)).

| Capa | Archivos |
|------|----------|
| Modelo | `modelo/Departamento.java`, `modelo/DepartamentoDAO.java` |
| Vista | `departamento.jsp` |
| Controlador | `controlador/DepartamentoController.java` |

### Datos de prueba

Sobre la base `sigh_gr02` ejecute:

```sql
source C:/Users/josue/Documents/LOGIN/JAVA/LOGIN_conMVC_JAVA_GR02/database/03_personal_departamento_datos_prueba.sql;
```

### Uso

1. Inicie sesion (por ejemplo con `0102030405` / `Admin123`).
2. En `bienvenida.jsp` entre a **Gestion de Departamentos (Personal)** o abra
   `/departamento.jsp` (la pagina esta protegida por `FiltroAutenticacion`).
3. Desde ahi puede crear, editar y eliminar departamentos. El codigo debe
   tener exactamente 3 caracteres y la descripcion maximo 50.
4. No se puede eliminar un departamento (ni cambiar su codigo) cuando tiene
   cargos asociados en `PECAR_CARGO`: la llave foranea lo restringe y la
   aplicacion muestra el mensaje correspondiente.

## Notas

- Las contraseÃ±as se comparan en texto plano porque el DDL del diagrama define
  `XEUSU_PASWD VARCHAR(16)` sin mecanismo de hash. Para un sistema real se
  recomienda almacenar un hash (BCrypt/Argon2) y ampliar la columna.
- El identificador principal de `XEUSU_USUAR` en el diagrama es la contraseÃ±a.
  El cÃ³digo respeta ese diseÃ±o para poder trabajar con el script proporcionado.
- Los archivos del formulario de encuesta anterior (`ServletController.java`,
  `DatosEncuesta.java`, `salida.jsp`, `validaciones.js`) se conservan como
  referencia, pero ya no se enlazan desde la pÃ¡gina de inicio.

