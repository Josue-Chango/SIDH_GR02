INTRO = (
    'Se incorporó la generación de reportes PDF con JasperReports a los módulos de Departamentos, Cargos y Empleados del aplicativo SIGH GR02. Además del listado de cada módulo, se añadió la ficha individual del empleado con fotografía, datos generales, estudios, familiares y firmas. Las plantillas conservan la información de los reportes y presentan un diseño sobrio para la gestión hospitalaria.',
    'La implementación utiliza la conexión MySQL existente del proyecto y las tablas de la base sigh_gr02. Para el personal se utiliza peper_perso, nombre real de la tabla en la base actual. Los siguientes pasos describen los archivos añadidos, su integración con MVC, el uso de los reportes y la edición de su presentación en Jaspersoft Studio.'
)

# Cada paso incorpora al menos una captura real del proyecto o del PDF generado.
STEPS = [
('CONFIGURACIÓN DE JASPERREPORTS', 'Paso 1 Incorporar las dependencias Maven',
 'En pom.xml se definió jasperreports.version con el valor 7.0.8, correspondiente a la versión de Jaspersoft Studio utilizada. Se añadieron jasperreports para compilar y llenar los diseños, jasperreports-pdf para exportarlos, jasperreports-fonts para las fuentes y jasperreports-jdt para compilar las expresiones Java. Estas dependencias se empaquetan con la aplicación web para generar los documentos desde el servidor.',
 'pom', 'Dependencias de JasperReports incorporadas en pom.xml'),

('INTEGRACIÓN CON EL PATRÓN MVC', 'Paso 2 Crear el controlador y proteger los reportes',
 'En el paquete ec.edu.chango.controlador se añadió ReporteController.java, disponible mediante /ReporteController y /reporte. El parámetro r selecciona departamentos, cargos, empleados o ficha. El controlador comprueba la sesión de usuario y el filtro de autenticación protege ambas rutas. Para cargos recibe el departamento y para la ficha valida el código de persona, por ejemplo P000000001. También envía el usuario de la sesión y configura el idioma español y la zona horaria de Guayaquil.',
 'controlador', 'Controlador de reportes y comprobación de la sesión de usuario'),

(None, 'Paso 3 Compilar las plantillas y generar el PDF',
 'En ec.edu.chango.util se creó ReportesJasper.java. Esta clase carga las plantillas desde /WEB-INF/reportes/, las compila con JasperCompileManager, completa los datos con JasperFillManager y exporta el resultado mediante JasperExportManager. La ficha recibe los subreportes académicos y familiares compilados. Las plantillas se guardan en memoria durante el despliegue. ReporteController utiliza ConexionBD y devuelve el archivo con el tipo application/pdf para abrirlo en el navegador.',
 'utilidad-jasper', 'Utilidad que llena los reportes e incorpora los dos subreportes de la ficha'),

('DISEÑOS EDITABLES EN JASPERSOFT STUDIO', 'Paso 4 Localizar las seis plantillas del proyecto',
 'Dentro del proyecto CRUD_conMVC_JAVA_GR02 se creó la carpeta src/main/webapp/WEB-INF/reportes. Contiene departamentos.jrxml, cargos.jrxml, empleados.jrxml y empleado_ficha.jrxml. Los archivos empleado_academicos.jrxml y empleado_familiares.jrxml corresponden al detalle de la ficha. Esta es la carpeta que se debe abrir para modificar los diseños; el archivo WAR corresponde al aplicativo empaquetado. Cada JRXML conserva la consulta, los campos, los parámetros y las bandas de su reporte.',
 'plantillas', 'Carpeta reportes con las seis plantillas JRXML editables'),

(None, 'Paso 5 Abrir una plantilla en Jaspersoft Studio',
 'Se abre Jaspersoft Studio.exe desde C:\\Users\\Usuario\\Desktop\\Web Avanzada\\jaspersoftstudio. En File > Open File se busca la carpeta reportes del proyecto y se selecciona, por ejemplo, departamentos.jrxml. La pestaña Design muestra el encabezado, las columnas, la banda de detalle, el total y el pie de página. Source permite revisar el JRXML y Preview permite comprobar el resultado cuando se dispone de una conexión de datos configurada.',
 'studio-diseno', 'Plantilla de departamentos abierta en la pestaña Design de Jaspersoft Studio'),

(None, 'Paso 6 Aplicar el diseño hospitalario',
 'Se definieron los estilos Base, Celda, Cabecera, Seccion, Etiqueta, Meta y Total. El diseño combina fondo blanco, azul oscuro #17374D, verde petróleo #137D88 y fondos claros para las tablas. Incluye símbolo sanitario, nombre del sistema, usuario, fecha, filas alternadas, totales y numeración de páginas. En Outline > Styles se selecciona un estilo y se revisan sus propiedades. Los cambios de presentación mantienen las consultas, los campos y la información de cada reporte.',
 'studio-estilos', 'Detalle de Outline y de las propiedades del estilo Cabecera en Jaspersoft Studio'),

('ACCESO A LOS REPORTES DESDE EL APLICATIVO', 'Paso 7 Utilizar los accesos de la bienvenida',
 'Después de iniciar sesión se muestra la sección Reportes PDF en bienvenida.jsp. Los enlaces Departamentos, Cargos y Empleados abren el listado correspondiente en una pestaña nueva. Se añadieron también botones dentro de cada módulo para generar el documento desde el contexto de trabajo. El nombre del usuario autenticado se coloca en el encabezado del PDF; si la sesión no está activa, el acceso se redirige al inicio de sesión.',
 'bienvenida-reportes', 'Sección Reportes PDF añadida a la página de bienvenida'),

('REPORTE DEL MÓDULO DE DEPARTAMENTOS', 'Paso 8 Generar el listado de departamentos',
 'Se ingresa a Gestión de Departamentos y se ubica la sección Departamentos registrados. El botón Reporte PDF de departamentos solicita ReporteController?r=departamentos. La plantilla departamentos.jrxml consulta PEDEP_DEPAR y ordena los registros por PEDEP_CODIGO. El reporte presenta el código y la descripción de cada departamento, junto con el total de registros. Su generación permite consultar e imprimir la información registrada sin modificarla.',
 'departamentos-interfaz', 'Botón Reporte PDF de departamentos dentro del módulo'),

(None, 'Paso 9 Revisar el PDF de departamentos',
 'Al abrir el documento se comprueba el encabezado institucional, el usuario que lo generó, la fecha y la tabla de departamentos. En la validación con la base actual se obtuvieron siete registros. El cuadro final muestra Total de departamentos: 7. El archivo se entrega como departamentos.pdf y puede imprimirse o guardarse desde el visor PDF. La captura corresponde al documento generado durante la verificación local de la base de datos.',
 'departamentos-1', 'Reporte PDF de departamentos con el nuevo diseño y siete registros'),

('REPORTE DEL MÓDULO DE CARGOS', 'Paso 10 Solicitar el reporte general de cargos',
 'En Gestión de Cargos se ubica Cargos registrados y se mantiene Todos los departamentos en el filtro. El botón Reporte PDF de cargos solicita el listado completo. La plantilla cargos.jrxml consulta PECAR_CARGO junto con PEDEP_DEPAR, agrupa los registros por departamento y presenta la clave departamento/cargo y su descripción. Esta clave permite identificar cargos cuyo código se repite en departamentos distintos.',
 'cargos-interfaz', 'Acceso al reporte general de cargos con todos los departamentos'),

(None, 'Paso 11 Revisar la agrupación por departamento',
 'El PDF general utiliza una franja de sección para identificar cada departamento. Debajo muestra sus cargos con filas alternadas y un subtotal del grupo. La primera página permite verificar la agrupación y la relación entre el departamento y el código de cargo. Las filas y sus textos conservan los datos de la consulta. El documento utiliza las páginas necesarias cuando el listado supera el espacio disponible.',
 'cargos-1', 'Primera página del PDF de cargos agrupados por departamento'),

(None, 'Paso 12 Comprobar la continuación y el total de cargos',
 'Se revisa la página siguiente del reporte general para comprobar la continuidad del listado. El encabezado de continuación mantiene la identificación del reporte y el pie indica la página actual y el total de páginas. Al terminar se muestra el total general. Con la base actual, el documento contiene diecinueve cargos distribuidos en siete departamentos y ocupa dos páginas. Los subtotales permiten comprobar la cantidad de cargos de cada departamento.',
 'cargos-2', 'Segunda página del PDF general de cargos y total de diecinueve registros'),

(None, 'Paso 13 Filtrar cargos antes de generar el PDF',
 'En Buscar cargos por departamento se selecciona 001 — Medicina y se consulta el listado. La pantalla muestra cuatro cargos y el botón cambia a Reporte PDF del departamento seleccionado. El enlace conserva el filtro mediante departamento=001. Si se selecciona Todos los departamentos, el valor se envía vacío y el reporte vuelve a incluir el listado completo. De esta manera, el PDF coincide con el alcance de la consulta realizada en el módulo.',
 'cargos-filtro', 'Filtro del departamento Medicina con cuatro cargos y botón de reporte específico'),

(None, 'Paso 14 Verificar el PDF del departamento seleccionado',
 'Al pulsar el botón se abre el PDF filtrado en una pestaña nueva. El encabezado indica Departamento seleccionado: 001 y la tabla contiene únicamente los cuatro cargos de Medicina. El subtotal del departamento y el total general coinciden en cuatro registros. La captura del navegador confirma que el controlador recibe el filtro y genera el documento con el nuevo diseño, incluyendo el nombre del usuario de la sesión.',
 'cargos-pdf-navegador', 'PDF filtrado de Medicina abierto desde el aplicativo'),

('REPORTES DEL MÓDULO DE EMPLEADOS', 'Paso 15 Acceder al listado y a la ficha individual',
 'En Mantenimiento de Empleados se añadieron dos accesos a reportes. Reporte PDF de empleados genera el listado general y Ficha PDF, ubicado en cada fila, genera el documento de esa persona. En edición también está disponible Ficha PDF guardada; este enlace utiliza los datos almacenados, por lo que los cambios del formulario deben guardarse antes de generar una ficha actualizada. El código se toma del registro seleccionado en la tabla peper_perso.',
 'empleados-interfaz', 'Listado de empleados con el reporte general y el botón Ficha PDF por persona'),

(None, 'Paso 16 Revisar el listado PDF de empleados',
 'La plantilla empleados.jrxml consulta peper_perso y utiliza las descripciones de PEGEN_GENERO y PEESC_ESTCIV. El documento conserva código, apellidos y nombres, fecha de nacimiento, sexo y estado civil. El total indica la cantidad de empleados incluidos. En la verificación local se generó empleados.pdf con tres personas. El listado mantiene el encabezado institucional y el mismo tratamiento de tablas aplicado a los otros módulos.',
 'empleados-1', 'Reporte general de empleados generado con los tres registros de la base actual'),

(None, 'Paso 17 Generar la ficha con fotografía y datos generales',
 'Se pulsa Ficha PDF en la fila del empleado P000000001. El controlador valida el código y comprueba su existencia en peper_perso; después carga la fotografía local indicada en PEPER_FOTO. La plantilla empleado_ficha.jrxml presenta código, apellidos, nombres, nacimiento, sexo, estado civil, peso y tipo de sangre. Cuando no existe una fotografía válida, el diseño muestra un espacio de identificación. El archivo utiliza el nombre ficha-empleado seguido del código de la persona.',
 'ficha-general', 'Ficha individual con fotografía y datos principales y generales'),

(None, 'Paso 18 Incorporar datos académicos familiares y firmas',
 'La ficha integra empleado_academicos.jrxml, que consulta PEACA_ACADE, y empleado_familiares.jrxml, que consulta PEFAM_FAMIL. Ambos reciben EMPLEADO con el mismo código de persona. El primer subreporte muestra nivel, institución y título; el segundo muestra parentesco, apellidos y nombres y nacimiento. Al final se incluyen las líneas de firma del empleado y del responsable. Las bandas y las celdas se ajustan al texto y permiten continuar en otras páginas cuando aumenta el detalle.',
 'ficha-detalles', 'Subreportes académicos y familiares con las firmas al final de la ficha'),

('VALIDACIÓN Y ACTUALIZACIÓN DE LOS REPORTES', 'Paso 19 Comprobar la generación y las pruebas',
 'La clase ReportesJasperTest valida la compilación de las seis plantillas y la generación de los documentos. La ejecución registrada para el diseño final completó diez pruebas sin fallos ni errores. También se verificaron los PDF con la base MySQL actual, incluido el filtro de Medicina. Las pruebas de la ficha contemplan fotografía, ausencia de detalles y texto extenso; este último caso permite revisar los encabezados, los pies de página y la ubicación final de las firmas.',
 'validacion', 'Registro de validación del diseño final con diez pruebas satisfactorias'),

(None, 'Paso 20 Guardar el diseño y volver a desplegar',
 'Para dar otro estilo a los reportes se abre el JRXML original en Jaspersoft Studio, se ajustan los elementos o Styles y se guarda el archivo. Para Preview con datos se configura un adaptador JDBC a sigh_gr02 con el controlador MySQL; en la ficha se utiliza un código real en EMPLEADO y se compilan los dos subreportes junto a la plantilla principal. Después, en NetBeans se utiliza Clean and Build y Run para volver a desplegar en Payara. El nuevo despliegue renueva la caché de plantillas y permite comprobar los cambios desde los botones PDF.',
 'construir', 'Opción Clean and Build de NetBeans para incorporar las plantillas actualizadas')
]
