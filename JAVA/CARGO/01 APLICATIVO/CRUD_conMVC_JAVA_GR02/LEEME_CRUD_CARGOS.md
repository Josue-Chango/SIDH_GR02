# CRUD de cargos — SIGH GR02

## Qué se encontró

El aplicativo usa MVC con Servlets y JSP de Jakarta EE 10, y acceso JDBC a MySQL mediante `ConexionBD`. No utiliza Hibernate/JPA en este módulo. Ya existían `Cargo`, las consultas de `CargoDAO` y la pantalla de consultas; faltaban las escrituras, el controlador y la vista de gestión.

Un cargo pertenece a un departamento. Su clave primaria es **(PEDEP_CODIGO, PECAR_CODIGO)**. Por ejemplo, SIS/ADM y CON/ADM son dos cargos diferentes. La descripción admite hasta 50 caracteres.

## Qué se implementó

| Archivo | Cambio |
| --- | --- |
| `CargoDAO.java` | Buscar por ambos códigos, comprobar existencia, insertar, actualizar descripción y eliminar. Conserva las consultas anteriores. |
| `CargoController.java` | Acciones listar/nuevo/editar por GET; guardar/eliminar por POST. Valida los datos y conserva el formulario cuando hay errores. |
| `cargo.jsp` | Formulario con departamentos, listado, botones de edición y eliminación, y mensajes. |
| `bienvenida.jsp` | Acceso «Gestión de Cargos (Personal)». |
| `FiltroAutenticacion.java` | Protege el nuevo controlador y la vista. |
| `style_JCH.css` | Estilos del selector y de los campos de solo lectura. |
| `database/04_personal_cargo_tabla.sql` | Creación opcional de PECAR_CARGO si no existe. No borra datos. |
| `src/test/java` y `pom.xml` | Pruebas del controlador y pruebas SQL aisladas con H2 en modo MySQL. |

Al editar se conserva el departamento y el código; únicamente cambia la descripción. Para registrar una combinación diferente, cree otro cargo. La eliminación usa los dos códigos y muestra un mensaje si MySQL impide borrarlo por tener referencias. No se agregaron borrados en cascada.

Se exige sesión iniciada, igual que en el CRUD de departamentos del proyecto recibido. **Este módulo no distingue permisos entre administrador y usuario**: cualquier usuario autenticado puede gestionarlo, siguiendo la política actual de Departamentos. Los formularios incorporan un token contra envíos desde otros sitios y la salida HTML se escapa.

## Cómo abrirlo y ejecutarlo

1. Descomprima el ZIP en una carpeta nueva para conservar su copia anterior.
2. En NetBeans, seleccione **Archivo → Abrir proyecto** y abra `01 APLICATIVO/CRUD_conMVC_JAVA_GR02` (la carpeta que contiene `pom.xml`).
3. Active MySQL. Revise `src/main/resources/db.properties` y configure la URL, el usuario y la contraseña de su base. Si utiliza variables `DB_*`, estas tienen prioridad sobre el archivo.
4. En MySQL Workbench, seleccione **la misma base indicada en db.properties**. Si ya tiene `PEDEP_DEPAR` y `PECAR_CARGO` del DDL de SIGH, no necesita crear tablas. Si solo falta `PECAR_CARGO`, ejecute `database/04_personal_cargo_tabla.sql` después de tener creada `PEDEP_DEPAR`. No es necesario crear otra base ni volver a importar los datos de seguridad.
5. Seleccione JDK 21 y configure Payara 6 en las propiedades del proyecto. Ejecute **Clean and Build / Limpiar y construir** y luego **Run / Ejecutar**.
6. Inicie sesión con su cuenta existente. En **Módulos**, ingrese a **Gestión de Cargos (Personal)**.
7. Elija un departamento, escriba un código de 3 caracteres y una descripción; pulse **Guardar cargo**. Si no tiene departamentos, regístrelos primero desde Gestión de Departamentos.

La ruta del módulo, dentro de la aplicación desplegada, es `/CargoController`.

En `dist/LOGIN_conMVC_JAVA_GR02.war` se incluye también el WAR compilado. Puede desplegarlo directamente si su configuración de conexión coincide; si cambia `db.properties`, reconstruya el proyecto antes de desplegar. Evite desplegar al mismo tiempo el WAR anterior con el mismo nombre/contexto.

## Comprobación manual en su equipo

1. Cree SIS/ADM (o use un departamento existente) con descripción «Administrador».
2. Intente repetir la misma combinación: debe mostrarse un error sin insertar otro registro.
3. Cree ADM en otro departamento: debe permitirse.
4. Edite la descripción del primer cargo: el del otro departamento debe conservarse.
5. Elimine uno: debe desaparecer únicamente el cargo seleccionado.
6. Intente guardar una descripción vacía y compruebe que se solicita completarla.
7. Cierre sesión y trate de abrir el módulo: debe volver al login.

Los cambios también se reflejan en la pantalla anterior de Consulta de Cargos y Departamentos al volver a consultar.

## Pruebas automatizadas

Con un JDK instalado y Maven disponible, ejecute desde la carpeta del proyecto:

```bash
mvn clean package
```

Las pruebas SQL usan una base H2 temporal, no la base configurada para su aplicación. Si tiene variables de entorno `DB_*`, quite esas variables en la terminal de pruebas para ejecutar las pruebas SQL; en ese caso se omiten por precaución. H2 y JUnit solo tienen alcance `test` y no se incluyen en el WAR.

También se compilaron las JSP modificadas con Jasper sin errores.

La validación realizada cubre la compilación, el empaquetado y 16 pruebas: clave compuesta, CRUD, duplicados, integridad referencial, sesión, token, validación y caída de la base. La conexión con su MySQL y el despliegue en su Payara deben comprobarse en su equipo.

Los documentos y la presentación recibidos se conservan como material previo; no se actualizaron para describir este nuevo módulo.
