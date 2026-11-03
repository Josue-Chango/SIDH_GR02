# Revisión del modelo conceptual del SIGH

Se entrega una copia conceptual corregida de las áreas de negocio, contrastada con el ERS y con los casos de uso y secuencias revisados. El archivo original permanece intacto. Seguridad y Personal se conservan literalmente dentro de la copia: sus diagramas, objetos, atributos, identificadores, datos y relaciones no se vuelven a serializar.

## Archivos y apertura

Abra `SIDH_GR02_Conceptual_CORREGIDO.cdm` en SAP PowerDesigner. El árbol contiene 14 vistas: las dos preservadas y 12 vistas de negocio. Se reutilizan las mismas entidades entre vistas; no son bases de datos separadas. Use F8 para centrar y F5 para tamaño real. Las vistas de negocio también están en `VISTA_PREVIA.html`, `svg` y `MODELOS_CONCEPTUALES_SIGH.pdf`.

El modelo contiene 79 entidades: 67 de negocio revisadas y 12 preservadas. Hay 115 relaciones de negocio y 125 en total. Las identidades de las entidades de negocio originales se conservan; sus atributos y relaciones se corrigen o amplían según el análisis. Esta copia es un modelo de diseño, no una migración de datos existentes.

## Garantía de preservación

La vista Seguridad comparte PERSONA con Personal. Se preservó la unión de ambas vistas y sus dependencias para evitar cambios indirectos sobre Seguridad. Se conservaron 106 objetos protegidos, de los que 78 pertenecen al cierre de dependencias de Seguridad, además de sus símbolos incluidos en los bloques de diagrama. No se agregaron ni alteraron relaciones incidentes a las entidades protegidas.

`PRESERVACION_SEGURIDAD.json` contiene los SHA-256 antes y después de cada bloque protegido. La comparación es byte por byte, incluyendo nombres, códigos, identificadores, cardinalidades, tipos, distribución y formato XML. El SHA-256 del archivo original es `89d581531d116f9caba3709c8be42de0fbaa864ab1bdac59119d4e871991c902`. El modelo corregido tiene una identidad raíz diferente para permitir abrirlo junto con el original, conservando intactos los bloques protegidos y las opciones globales de notación.

La revisión no evalúa ni declara corregidos los requisitos de autenticación, permisos, sesiones o auditoría del bloque excluido. Tampoco añade una entidad o un diseño paralelo de seguridad. La autoría administrativa de negocio utiliza `registradoPor` como contrato de referencia al responsable existente; los vínculos con cuentas y la verificación de esa identidad corresponden a la integración lógica posterior, sin cambiar el modelo protegido. La autoría profesional clínica se modela con relaciones explícitas a PROFESIONAL.

## Hallazgos y correcciones

| Hallazgo del modelo anterior | Corrección conceptual |
|---|---|
| Documento, nombres y fecha de nacimiento siempre obligatorios en PACIENTE | Identidad hospitalaria estable y estado de identidad; datos incompletos admitidos para emergencias, con conciliación y revisión documentadas. |
| Profesional limitado a una especialidad | HABILITACION_PROFESIONAL relaciona profesionales y especialidades con vigencia. |
| Servicio asistencial y prestación facturable confundidos | SERVICIO_HOSPITALARIO organiza la atención y sus ubicaciones; SERVICIO identifica la prestación a la que se aplica una tarifa. |
| Reservas sin unidad de turno ni historial | TURNO_AGENDA representa capacidad y periodo; HISTORIAL_CITA conserva estados y horarios anteriores y nuevos. |
| Admisión y episodio con dependencia obligatoria que dificulta su creación | Contextos opcionales según tipo, con reglas de mismo paciente y origen autorizado. |
| Autor clínico como texto y sin corrección conservada | Relaciones a PROFESIONAL, finalización con fecha y mecanismo, y relación de rectificaciones a la nota original. |
| Diagnósticos sin versión de clasificación y alergias sin fuente ni verificación | Catálogo diagnóstico versionado; alergia con fuente, reacción y estado de verificación. |
| Enfermería, prioridad de emergencia y disposición sin estructura propia | Registros de enfermería y mediciones, triajes y disposiciones con responsables y momento efectivo. |
| Una prescripción asociada directamente a un medicamento y sin entrega | Cabecera, ítems de prescripción, dispensación y detalles de entrega vinculados al movimiento de salida. |
| Cantidad global por lote y mínimos globales sin ubicación | EXISTENCIA por producto, ubicación y lote aplicable; cantidades disponibles, reservadas y no dispensables diferenciadas y política de mínimos por ubicación. |
| Solicitud de laboratorio con un tipo de examen textual y validación textual | Ítems, exámenes, parámetros, muestras, resultados versionados y validaciones profesionales separadas. |
| Informe de imagen dentro del estudio, sin estados independientes | INFORME_IMAGEN versionado con autor y validador; documentos y contenido del repositorio separados. |
| Habitaciones como texto y egreso sin distinguir autorización clínica | Habitación, intervalos de asignación, historial operativo, traslados, ALTA_MEDICA y EGRESO_ADMINISTRATIVO independientes. |
| Cirugía sin recursos reservados, equipo ni controles trazables | Reservas temporales, participaciones, controles preoperatorios y recuperación. |
| Cargo obligado a pertenecer a una factura y ausencia de líneas reproducibles | Cuenta, cargos pendientes, detalles con precios y reglas aplicados, pagos parciales y ajustes vinculados al documento original. |
| Catálogos sin historial de configuración del negocio | Vigencia, valores operativos y cambios de catálogo; no se altera la auditoría del modelo protegido. |
| Varias relaciones exigían hijos desde la creación del padre | Mínimos 0 cuando una entidad puede existir antes de sus registros dependientes; requisitos de finalización se expresan como reglas condicionales. |

## Criterios y reglas de integridad

Los conceptos representan información del dominio, con identificadores estables y relaciones mínimas y máximas explícitas. No se agregan columnas FK, índices, triggers, credenciales o mecanismos físicos al diagrama conceptual. Los tipos nativos de PowerDesigner son representaciones orientativas; el diccionario conserva tipos conceptuales y las longitudes y precisiones deben ratificarse en el diseño lógico y físico.

Los estados en borrador o programación admiten información que todavía no corresponde completar. Autorizar una receta exige ítems; emitir un documento exige líneas y totales válidos; liberar un resultado requiere validación aprobada de esa versión; publicar un informe requiere validación previa. Estas reglas no se sustituyen por una cardinalidad mínima 1 que impida guardar un borrador.

La asignación de turnos y camas y las reservas quirúrgicas deben prevenir solapamientos incompatibles en una operación atómica. La dispensación y la salida de inventario se confirman juntas. Las cantidades no son negativas y el disponible se obtiene sin descontar dos veces reservas y productos no dispensables. Los intervalos terminan después de comenzar y las reglas de vigencia se aplican según la fecha del evento. Los diagramas especifican estas invariantes; su cumplimiento transaccional se implementará en el diseño posterior.

Una fusión o conciliación de identidad conserva origen y referencias; no borra atenciones ni evidencia financiera. La nota original y los informes o resultados anteriores se conservan al rectificar. Las tarifas utilizadas y los importes aplicados permanecen reproducibles, sin depender de precios actuales. La baja de un catálogo conserva las referencias históricas.

Los conceptos de paciente, episodio, admisión, prescripción, ítem, muestra, resultado, estudio y documento deben ser coherentes entre sí: una referencia existente no basta si pertenece a otro paciente o contexto. En el modelo lógico se definirán restricciones compuestas o verificaciones equivalentes para estas invariantes.

Se mantiene el alcance base con repositorio interno. No se presuponen aseguradoras, PACS/DICOM, laboratorio externo ni facturación tributaria electrónica. No se fijan protocolos o umbrales clínicos, ni se incorpora un motor autónomo de diagnóstico o prioridad.

## Decisiones que deben ratificarse

La relación propuesta entre una cita y su episodio principal es 0..1 a 0..1. Si el hospital admite varias atenciones principales para una cita, debe ampliarse de forma explícita. La regla propuesta de una línea activa por cargo evita facturación duplicada; si se requiere fraccionar cargos, se definirá el control de cantidades facturadas. La responsabilidad para resolver duplicados sigue exigiendo autorización institucional expresa, como en los casos corregidos. Los formatos de identificación, campos clínicos, estados, medios de pago, tasas, monedas, precisión de cantidades y procedimientos de firma se concretan con los responsables del hospital.

## Trazabilidad y verificación

El ERS consultado está en `01. UML/01. ERS/ERS_SIGH_GR02.docx`, con SHA-256 `b0599b72f9ee9d1aab83be530a6048d50424c72358c87ea4e847083ed50ca4fa`. Se contrastaron sus módulos 4.1 a 4.14 y las reglas DAT-001 a DAT-008. Los casos de uso corregidos y las secuencias se usaron para distinguir objetivos y ciclos de vida, sin convertir pasos de interfaz en entidades.

`TRAZABILIDAD_ERS.csv` clasifica los 74 RF por conceptos revisados, consultas derivadas o bloque excluido. Los informes agregados se obtienen de las entidades operativas; exportar no obliga a persistir otra entidad. RF-INF-007 depende de la política de auditoría, que se deja intacta. La trazabilidad de estructuras no certifica por sí sola permisos, transacciones, rendimiento o implementación funcional.

`DICCIONARIO_CONCEPTUAL.csv` detalla los atributos y sus tipos, obligatoriedad e identificadores. `RELACIONES_Y_CARDINALIDADES.csv` precisa ambos sentidos de cada vínculo. `VALIDACION_ESTRUCTURAL.json` comprueba IDs y referencias, tipos de símbolos, coincidencia de extremos gráficos y semánticos, identificadores del negocio, visibilidad y rutas que no atraviesan entidades.

## Referencias

Se aplican las distinciones entre entidades, atributos, identificadores y relaciones del [manual oficial de SAP PowerDesigner Data Architecture, secciones 1.1 y 1.2](https://help.sap.com/doc/c7bcb6fe6e1b10148e8eca8d2c439245/16.7.06/en-US/data_modeling.pdf). Las multiplicidades y la dependencia identificadora se contrastaron con la [documentación oficial de cardinalidades de SAP/Sybase](https://infocenter-archive.sybase.com/help/topic/com.sybase.stf.powerdesigner.docs_12.5.0/html/cdug/cdugp59.htm). Las decisiones concretas del dominio son análisis de la ERS, no reglas hospitalarias impuestas por esas fuentes.

## Vistas revisadas

| Página PDF | Vista | Entidades | Relaciones |
|---|---|---|---|
| 1 | [Pacientes e identidad](svg/GH01.svg) | 6 | 8 |
| 2 | [Profesionales, agendas y citas](svg/GH02.svg) | 9 | 9 |
| 3 | [Historia clínica y enfermería](svg/GH03.svg) | 10 | 14 |
| 4 | [Emergencias y origen de atención](svg/GH04.svg) | 9 | 15 |
| 5 | [Solicitudes y resultados de laboratorio](svg/GH05.svg) | 10 | 14 |
| 6 | [Imagenología y documentos](svg/GH06.svg) | 5 | 8 |
| 7 | [Prescripción y dispensación](svg/GH07.svg) | 10 | 16 |
| 8 | [Inventario por ubicación y lote](svg/GH08.svg) | 7 | 12 |
| 9 | [Hospitalización, camas y egreso](svg/GH09.svg) | 12 | 22 |
| 10 | [Cirugía, recursos y recuperación](svg/GH10.svg) | 8 | 11 |
| 11 | [Finanzas](svg/FI01.svg) | 11 | 13 |
| 12 | [Catálogos y vigencia](svg/CA01.svg) | 10 | 2 |
