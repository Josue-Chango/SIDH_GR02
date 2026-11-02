# Revisión de casos de uso del SIGH

Los modelos revisados mantienen los 23 casos del catálogo de la ERS y distinguen objetivos del usuario, comportamientos incluidos y reglas automáticas. Se corrigen las relaciones UML y las responsabilidades, con trazabilidad explícita de los 74 requisitos funcionales. El resultado es un proyecto independiente de PowerDesigner, acompañado de un PDF y exportaciones SVG.

## Referencia de requisitos

Se utilizó la ERS de 31/10/2026 proporcionada en `C:/WEB_AVANZADA/SIGH_GR02/01. UML/01. ERS/ERS_SIGH_GR02.docx`. Su SHA-256 coincide con la copia del repositorio: `b0599b72f9ee9d1aab83be530a6048d50424c72358c87ea4e847083ed50ca4fa`. Se contrastaron el alcance, la tabla 23 de casos, los perfiles U-01 a U-20 y las especificaciones funcionales detalladas de los módulos 4.1 a 4.14.

La descripción y los criterios del requisito prevalecen para esta revisión sobre encabezados copiados incorrectamente: las tablas de RF-SEG-004 y RF-SEG-005 conservan títulos que no coinciden con sus descripciones. La ERS también contiene restos de una plantilla de taller mecánico; no se incorporaron al dominio hospitalario. El documento de requisitos permanece sin modificaciones.

## Criterios de modelado

Un actor es un rol externo que intercambia información con el sujeto. Los profesionales del hospital son externos al software SIGH aunque pertenezcan a la institución. La base de datos, los módulos, la auditoría automática y los cálculos internos no se representan como actores. Se toma como referencia [OMG UML 2.5.1, capítulo 18](https://www.omg.org/spec/UML/2.5.1) y la [guía oficial de diagramas de casos de uso de Sparx Systems](https://sparxsystems.com/enterprise_architect_user_guide/17.2/modeling_languages/usecasediagram.html).

Las asociaciones son líneas sin flecha entre actor y caso; indican participación, no secuencia ni acceso a todas las operaciones del módulo. Los actores permanecen fuera del rectángulo del sujeto y los casos dentro. Los nombres describen objetivos mediante verbos y objetos del dominio.

Una relación `«include»` va del caso que necesita un comportamiento al comportamiento incluido. Solo se conserva cuando esa ejecución es parte obligatoria del caso base. La referencia es la [documentación oficial de Include](https://sparxsystems.org/enterprise_architect_user_guide/17.1/modeling_languages/include.html). Se eliminaron las dependencias `trace` que conservaban una descomposición sin semántica de ejecución y las relaciones que imponían operaciones independientes.

Una relación `«extend»` necesita una ampliación de una ejecución base, condiciones y puntos de extensión definidos. El hecho de que una tarea sea opcional o posterior no basta para crear esa relación. Se conservaron objetivos independientes cuando la ERS no define ese punto, por ejemplo exportar un informe disponible o registrar una devolución. Véase la [documentación oficial de Extend](https://sparxsystems.org/enterprise_architect_user_guide/17.2/modeling_languages/extend.html). No se inventan extensiones para aumentar la cantidad de flechas.

La sesión válida, la autorización contextual y la existencia de datos previos se documentan como precondiciones cuando corresponden. La expiración de sesión, la protección de bitácoras y el registro automático de eventos se documentan como reglas. Los pasos de interfaz, como seleccionar un tipo de reporte, no se convierten automáticamente en objetivos adicionales. Las inclusiones usan dependencias de casos de uso compatibles con la [guía de modelado orientado a objetos de SAP PowerDesigner](https://help.sap.com/doc/c7bcdbf06e1b1014b1fadaaf5f160630/16.6.6/enUS/object_oriented_modeling.pdf).

## Correcciones principales

| Hallazgo en los modelos anteriores | Corrección aplicada |
|---|---|
| Límite del sistema ausente en los 23 diagramas detallados | Sujeto SIGH identificado y actores fuera del límite en las 29 vistas. |
| Relaciones `include` invertidas o usadas como agrupación en reportes | Cinco tipos de informe explícitos; filtros dentro del flujo y exportación como objetivo independiente. |
| Supervisión de seguridad asociada a asignación de permisos | Se separan consultar permisos y asignarlos; la asignación corresponde al administrador autorizado. |
| Médico asociado al resumen de resultados de laboratorio sin distinción de tareas | En el detalle el médico consulta; solo personal facultado registra, valida o libera. |
| Cobertura administrativa interpretada como verificación externa | Se consultan datos registrados, sin presumir conexión con aseguradoras. |
| Alta médica, egreso y disponibilidad de cama confundidos | CU-19 registra el alta clínica; CU-17 registra el egreso y respeta limpieza o preparación. |
| Prescripción y validación farmacéutica mezcladas | CU-14 conserva la prescripción médica y su consulta; CU-15 verifica prescripción y existencias al dispensar. |
| Alertas clínicas sin requisito definido | Se retira Alertar valores críticos del alcance base; se mantienen las alertas de stock exigidas por RF-FAR-007. |
| Actores sin interacción o funciones condicionales asumidas | Se omiten paciente, integraciones externas y privilegios de soporte mientras no exista función aprobada. |
| Registro de auditoría y protección tratados como tareas del auditor | Reglas transversales automáticas y consulta autorizada sin edición de evidencias. |
| Objetos y relaciones ocultos con comentarios contradictorios | El proyecto revisado contiene únicamente elementos pertinentes, visibles y con referencias coherentes. |

## Catálogo general por áreas

Las seis vistas de `CU_SIGHO_General.oom` representan el mismo sujeto SIGH. Cada caso del catálogo aparece una vez en su área. La asociación general agrega la participación existente en los casos detallados y no autoriza todas las funciones del módulo. La separación por áreas reduce cruces y permite leer los 23 casos sin concentrarlos en una sola lámina.

| Vista | Casos del catálogo |
|---|---|
| [Seguridad y administración](svg/G01_Seguridad_y_auditoria.svg) | CU-01, CU-02, CU-03, CU-23 |
| [Pacientes, citas y admisión](svg/G02_Pacientes_y_citas.svg) | CU-04, CU-05, CU-06 |
| [Historia clínica y atención](svg/G03_Atencion_clinica.svg) | CU-07, CU-08, CU-09, CU-10, CU-19 |
| [Diagnóstico y farmacia](svg/G04_Diagnostico_y_farmacia.svg) | CU-11, CU-12, CU-13, CU-14, CU-15, CU-16 |
| [Hospitalización y cirugía](svg/G05_Hospitalizacion_y_cirugia.svg) | CU-17, CU-18 |
| [Facturación e informes](svg/G06_Facturacion_y_reportes.svg) | CU-20, CU-21, CU-22 |

## Responsabilidades de los actores

| Actor | Correspondencia y restricciones |
|---|---|
| Usuario del sistema | Todos los perfiles internos con cuenta individual. Esta abstracción solo participa en autenticación, recuperación y cierre; no concede permisos funcionales. |
| Administrador del sistema | U-01. Administración de cuentas, asignación de permisos, políticas y catálogos. Sin acceso clínico general. |
| Responsable de seguridad | U-02. Consulta y supervisión de permisos y auditoría. La supervisión no concede la facultad de asignar permisos ni editar historias clínicas. |
| Recepcionista | U-03. Registro administrativo, búsqueda de pacientes, citas y llegada. La modificación de agendas requiere autorización específica. |
| Responsable de admisión hospitalaria | U-04. Admisiones y egresos administrativos autorizados. La resolución de duplicados se propone para este rol solo cuando esté expresamente autorizado por la institución. |
| Médico | Abstracción de U-05, U-06 y U-07. Cada operación queda limitada por competencia profesional, especialidad, servicio, relación asistencial y autorización; no todos los médicos realizan cirugía o triaje. |
| Enfermero | U-08. Cuidados, signos vitales y consulta pertinente. El triaje y la documentación de intervenciones se limitan a su competencia y protocolo. |
| Personal de laboratorio | U-09. Solicitudes y resultados del laboratorio. Validar y liberar resultados exige competencia y permiso específicos. |
| Profesional de imagenología | U-10. Programación, estado, documentos e informes de imagenología. La interpretación y validación exigen habilitación y autorización específicas. |
| Farmacéutico | U-11. Consulta de prescripciones autorizadas, dispensación, existencias, lotes y movimientos. No modifica la prescripción médica. |
| Personal de quirófano | U-12. Programación y documentación perioperatoria según competencias. No sustituye al profesional responsable de la intervención. |
| Gestor de camas y hospitalización | U-13. Camas, asignaciones, traslados y liberación administrativa. No decide el alta médica ni presume la disponibilidad física de una cama. |
| Cajero | U-14. Registro de pagos, saldos y reportes de caja autorizados. Sin administración de tarifas ni acceso clínico. |
| Facturador | U-15. Cargos, documentos, ajustes y saldos. Anulaciones y devoluciones sujetas a autorización y trazabilidad. |
| Analista de estadísticas hospitalarias | U-16. Datos e indicadores agregados autorizados, con minimización de datos identificables. |
| Director hospitalario | U-17. Reportes agregados y gerenciales autorizados. El cargo no otorga acceso general a historias clínicas. |
| Auditor | U-18. Consulta de bitácoras y evidencias dentro del alcance asignado. No modifica registros examinados. |

U-19, soporte informático, y U-20, paciente o representante, permanecen como perfiles del ERS. No se presupone un portal, una mesa de ayuda ni una facultad de restablecer cuentas para soporte. La recuperación controlada de RF-SEG-005 sí se representa para el solicitante. No se añaden servicios externos de identidad, laboratorio, imagenología, aseguramiento ni tributación al alcance base.

## Revisión por caso del catálogo

Cada objetivo detallado tiene un código estable, una correspondencia con requisitos y una descripción en las propiedades del objeto OOM. Los comportamientos incluidos no tienen un actor ficticio. Las restricciones también aparecen en los comentarios del diagrama y en las notas de la lámina PDF.

### CU-01 Iniciar sesión

La autenticación es un objetivo propio. En los demás módulos una sesión válida es una precondición; no se repite un include a Iniciar sesión. No se presupone servicio externo de identidad ni soporte con privilegios de restablecimiento.

[Modelo editable](CU_01_Iniciar_Sesion.oom) · [Diagrama SVG](svg/CU_01_Iniciar_Sesion.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-01.01 | Iniciar sesión | RF-SEG-001 | Usuario del sistema |
| CU-01.02 | Cerrar sesión | RF-SEG-004 | Usuario del sistema |
| CU-01.03 | Recuperar o restablecer credenciales | RF-SEG-005 | Usuario del sistema |
| CU-01.04 | Verificar credenciales | RF-SEG-001 | Incluido por el caso base |
| CU-01.05 | Verificar identidad del solicitante | RF-SEG-005 | Incluido por el caso base |

Inclusiones obligatorias:
- `CU-01.01` → `CU-01.04`: Iniciar sesión incluye verificar credenciales.
- `CU-01.03` → `CU-01.05`: Recuperar o restablecer credenciales incluye verificar identidad del solicitante.

Reglas del comportamiento:
- **RF-SEG-004**: Inicio, expiración, cierre e inactividad conforme a la política institucional.
- **RF-AUD-001**: Registrar eventos de autenticación, recuperación y cierre definidos por la política.
- **RF-AUD-004**: Registrar los intentos denegados relevantes sin contraseñas ni secretos.

### CU-02 Gestionar usuarios, roles y permisos

Se distinguen la modificación administrativa y la supervisión de seguridad. Las operaciones requieren sesión y permisos; la consulta no implica facultades de edición.

[Modelo editable](CU_02_Gestionar_Usuarios_Roles.oom) · [Diagrama SVG](svg/CU_02_Gestionar_Usuarios_Roles.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-02.01 | Administrar cuentas de usuario | RF-SEG-002 | Administrador del sistema |
| CU-02.02 | Asignar roles y permisos | RF-SEG-003 | Administrador del sistema |
| CU-02.03 | Consultar roles y permisos | RF-SEG-003 | Administrador del sistema, Responsable de seguridad |
| CU-02.04 | Configurar políticas de sesión | RF-SEG-004 | Administrador del sistema |
| CU-02.05 | Consultar auditoría de cambios | RF-AUD-002 | Administrador del sistema, Responsable de seguridad |

### CU-03 Administrar catálogos y parámetros

Los cambios de configuración se registran automáticamente. La auditoría es una obligación del comportamiento, no una tarea que el administrador deba ejecutar manualmente.

[Modelo editable](CU_03_Administrar_Catalogos.oom) · [Diagrama SVG](svg/CU_03_Administrar_Catalogos.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-03.01 | Administrar catálogos institucionales | RF-CAT-001 | Administrador del sistema |
| CU-03.02 | Controlar vigencia de catálogos | RF-CAT-002 | Administrador del sistema |

Reglas del comportamiento:
- **RF-CAT-003**: Registrar cambios relevantes, usuario, fecha y valores anteriores y nuevos cuando correspondan.

### CU-04 Registrar y actualizar pacientes

El paciente aporta información al proceso hospitalario; no interactúa con el software en el alcance base. La asignación de la función de depuración a admisión es una propuesta de responsabilidad que debe ratificarse.

[Modelo editable](CU_04_Registrar_Pacientes.oom) · [Diagrama SVG](svg/CU_04_Registrar_Pacientes.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-04.01 | Registrar paciente | RF-PAC-001 | Recepcionista |
| CU-04.02 | Buscar pacientes | RF-PAC-002 | Recepcionista, Responsable de admisión hospitalaria |
| CU-04.03 | Actualizar datos demográficos | RF-PAC-003 | Recepcionista |
| CU-04.04 | Consultar historial administrativo | RF-PAC-004 | Recepcionista, Responsable de admisión hospitalaria |
| CU-04.05 | Resolver posibles duplicados | RF-PAC-005 | Responsable de admisión hospitalaria |
| CU-04.06 | Comprobar posibles duplicados | RF-PAC-001 | Incluido por el caso base |

Inclusiones obligatorias:
- `CU-04.01` → `CU-04.06`: Registrar paciente incluye comprobar posibles duplicados.

### CU-05 Gestionar citas médicas

Consultar, reservar, reprogramar y cancelar son objetivos independientes. El diagrama no impone que consultar una agenda ejecute una reserva.

[Modelo editable](CU_05_Gestionar_Citas.oom) · [Diagrama SVG](svg/CU_05_Gestionar_Citas.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-05.01 | Administrar agendas médicas | RF-CIT-001 | Recepcionista |
| CU-05.02 | Consultar agenda diaria | RF-CIT-006 | Recepcionista, Médico |
| CU-05.03 | Programar cita | RF-CIT-002 | Recepcionista |
| CU-05.04 | Reprogramar cita | RF-CIT-003 | Recepcionista |
| CU-05.05 | Cancelar cita | RF-CIT-004 | Recepcionista |
| CU-05.06 | Registrar asistencia y estado de cita | RF-CIT-005 | Recepcionista |
| CU-05.07 | Comprobar disponibilidad de turno | RF-CIT-002, RF-CIT-003 | Incluido por el caso base |

Inclusiones obligatorias:
- `CU-05.03` → `CU-05.07`: Programar cita incluye comprobar disponibilidad de turno.
- `CU-05.04` → `CU-05.07`: Reprogramar cita incluye comprobar disponibilidad de turno.

### CU-06 Admitir pacientes

CU-06 se concreta como admisión administrativa. CU-17 se ocupa de camas y egreso; la llegada a consulta externa se registra en CU-05. La ERS no define un RF independiente para verificar cobertura externa.

[Modelo editable](CU_06_Admitir_Pacientes.oom) · [Diagrama SVG](svg/CU_06_Admitir_Pacientes.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-06.01 | Registrar admisión hospitalaria | RF-HOS-001 | Responsable de admisión hospitalaria |
| CU-06.02 | Consultar datos administrativos y cobertura | RF-PAC-001, RF-PAC-004 | Responsable de admisión hospitalaria |
| CU-06.03 | Consultar ingresos y egresos | RF-PAC-004 | Responsable de admisión hospitalaria, Gestor de camas y hospitalización |

### CU-07 Consultar historia clínica electrónica

Autorización contextual y registro de accesos son reglas de todas las consultas. Una asociación de auditoría no concede edición ni acceso clínico indiscriminado.

[Modelo editable](CU_07_Consultar_HCE.oom) · [Diagrama SVG](svg/CU_07_Consultar_HCE.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-07.01 | Consultar antecedentes clínicos | RF-HC-005 | Médico, Enfermero |
| CU-07.02 | Consultar resultados clínicos | RF-HC-005, RF-LAB-005 | Médico, Enfermero |
| CU-07.03 | Consultar evidencias clínicas de auditoría | RF-AUD-002 | Auditor |

### CU-08 Registrar consulta, diagnóstico y tratamiento

El episodio existente es precondición de los registros que lo requieren. Abrir, documentar, evolucionar y finalizar no se enlazan mediante include para representar su orden temporal.

[Modelo editable](CU_08_Registrar_Consulta.oom) · [Diagrama SVG](svg/CU_08_Registrar_Consulta.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-08.01 | Abrir episodio de atención | RF-HC-001 | Médico |
| CU-08.02 | Registrar consulta médica | RF-HC-002 | Médico |
| CU-08.03 | Registrar diagnósticos | RF-HC-003 | Médico |
| CU-08.04 | Registrar evoluciones clínicas | RF-HC-004 | Médico |
| CU-08.05 | Gestionar alergias y reacciones adversas | RF-HC-006 | Médico |
| CU-08.06 | Firmar o finalizar atención | RF-HC-007 | Médico |
| CU-08.07 | Gestionar documentos clínicos | RF-HC-008 | Médico |

### CU-09 Registrar signos vitales y cuidados

Se elimina Alertar valores críticos como objetivo del alcance base: no existe requisito que defina ni apruebe ese motor clínico. Las alertas de inventario de RF-FAR-007 sí se conservan en CU-16.

[Modelo editable](CU_09_Registrar_Signos_Vitales.oom) · [Diagrama SVG](svg/CU_09_Registrar_Signos_Vitales.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-09.01 | Registrar signos vitales | RF-HOS-005 | Enfermero |
| CU-09.02 | Registrar cuidados y observaciones | RF-HOS-005 | Enfermero |

### CU-10 Gestionar urgencias

La admisión administrativa, el triaje y la atención clínica tienen responsables distintos. La conciliación de identidad puede ocurrir después y no se fuerza como include del ingreso.

[Modelo editable](CU_10_Gestionar_Urgencias.oom) · [Diagrama SVG](svg/CU_10_Gestionar_Urgencias.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-10.01 | Registrar ingreso de emergencia | RF-EME-001 | Recepcionista, Responsable de admisión hospitalaria |
| CU-10.02 | Completar o conciliar identidad temporal | RF-EME-001 | Recepcionista, Responsable de admisión hospitalaria |
| CU-10.03 | Registrar clasificación de prioridad | RF-EME-002 | Médico, Enfermero |
| CU-10.04 | Registrar atención de emergencia | RF-EME-003 | Médico, Enfermero |
| CU-10.05 | Registrar disposición del paciente | RF-EME-004 | Médico |

### CU-11 Solicitar exámenes de laboratorio

Seleccionar exámenes es parte del flujo de solicitud. No se fuerza la consulta de resultados como parte de solicitar un examen. El personal del hospital es el actor; un laboratorio externo solo se incorporaría con integración aprobada.

[Modelo editable](CU_11_Solicitar_Laboratorio.oom) · [Diagrama SVG](svg/CU_11_Solicitar_Laboratorio.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-11.01 | Crear solicitud de laboratorio | RF-LAB-001 | Médico |
| CU-11.02 | Consultar resultados de laboratorio | RF-LAB-005 | Médico |

### CU-12 Registrar resultados de laboratorio

Guardar resultados y validarlos son objetivos separados. Un include entre ambos impondría validación cada vez que se guarda un borrador y confundiría responsabilidades.

[Modelo editable](CU_12_Registrar_Resultados_Lab.oom) · [Diagrama SVG](svg/CU_12_Registrar_Resultados_Lab.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-12.01 | Gestionar estado de solicitud y muestra | RF-LAB-002 | Personal de laboratorio |
| CU-12.02 | Registrar resultados | RF-LAB-003 | Personal de laboratorio |
| CU-12.03 | Validar y liberar resultados | RF-LAB-004 | Personal de laboratorio |
| CU-12.04 | Consultar resultados de laboratorio | RF-LAB-005 | Personal de laboratorio, Médico |

### CU-13 Gestionar estudios de imagenología

El actor Profesional de imagenología representa funciones con habilitaciones distintas. Su asociación no autoriza a todo técnico a interpretar o validar un informe.

[Modelo editable](CU_13_Gestionar_Imagenologia.oom) · [Diagrama SVG](svg/CU_13_Gestionar_Imagenologia.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-13.01 | Solicitar estudio de imagen | RF-IMG-001 | Médico |
| CU-13.02 | Registrar programación y ejecución de estudio | RF-IMG-002 | Profesional de imagenología |
| CU-13.03 | Elaborar informe radiológico | RF-IMG-003 | Profesional de imagenología |
| CU-13.04 | Validar y publicar informe radiológico | RF-IMG-003 | Profesional de imagenología |
| CU-13.05 | Vincular imágenes e informes | RF-IMG-004 | Profesional de imagenología |
| CU-13.06 | Consultar informe de imagenología | RF-HC-005 | Médico, Profesional de imagenología |

### CU-14 Gestionar recetas médicas

Se separan la prescripción médica y su verificación para dispensación. Consultar un catálogo no obliga a emitir una receta.

[Modelo editable](CU_14_Gestionar_Recetas.oom) · [Diagrama SVG](svg/CU_14_Gestionar_Recetas.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-14.01 | Consultar catálogo de medicamentos | RF-FAR-001 | Médico, Farmacéutico |
| CU-14.02 | Registrar prescripción médica | RF-HC-002 | Médico |
| CU-14.03 | Consultar prescripciones autorizadas | RF-FAR-003 | Médico, Farmacéutico |

### CU-15 Dispensar medicamentos

Los include representan verificaciones y efectos obligatorios de la dispensación, con la flecha desde el caso base hacia el comportamiento incluido.

[Modelo editable](CU_15_Dispensar_Medicamentos.oom) · [Diagrama SVG](svg/CU_15_Dispensar_Medicamentos.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-15.01 | Registrar dispensación | RF-FAR-004 | Farmacéutico |
| CU-15.02 | Validar prescripción para dispensación | RF-FAR-003 | Incluido por el caso base |
| CU-15.03 | Comprobar existencias dispensables | RF-FAR-002, RF-FAR-005 | Incluido por el caso base |
| CU-15.04 | Registrar salida de inventario | RF-FAR-004, RF-FAR-006 | Incluido por el caso base |

Inclusiones obligatorias:
- `CU-15.01` → `CU-15.02`: Registrar dispensación incluye validar prescripción para dispensación.
- `CU-15.01` → `CU-15.03`: Registrar dispensación incluye comprobar existencias dispensables.
- `CU-15.01` → `CU-15.04`: Registrar dispensación incluye registrar salida de inventario.

### CU-16 Gestionar inventario de farmacia

El sistema genera automáticamente las alertas de RF-FAR-007. El farmacéutico configura umbrales y consulta el resultado, no ejecuta manualmente el evento automático.

[Modelo editable](CU_16_Gestionar_Inventario.oom) · [Diagrama SVG](svg/CU_16_Gestionar_Inventario.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-16.01 | Consultar disponibilidad de inventario | RF-FAR-002 | Farmacéutico |
| CU-16.02 | Registrar movimientos de inventario | RF-FAR-006 | Farmacéutico |
| CU-16.03 | Controlar lotes y caducidad | RF-FAR-005 | Farmacéutico |
| CU-16.04 | Configurar niveles mínimos de stock | RF-FAR-007 | Farmacéutico |
| CU-16.05 | Consultar alertas de stock | RF-FAR-007 | Farmacéutico |

### CU-17 Gestionar camas y hospitalización

CU-06 registra la admisión. CU-19 corresponde a la decisión y documentación médica. El egreso actualiza la cama respetando limpieza o preparación; no equivale a disponibilidad inmediata.

[Modelo editable](CU_17_Gestionar_Camas.oom) · [Diagrama SVG](svg/CU_17_Gestionar_Camas.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-17.01 | Administrar camas y estados operativos | RF-HOS-002 | Gestor de camas y hospitalización |
| CU-17.02 | Consultar ocupación hospitalaria | RF-HOS-002 | Gestor de camas y hospitalización, Responsable de admisión hospitalaria |
| CU-17.03 | Asignar cama | RF-HOS-003 | Gestor de camas y hospitalización |
| CU-17.04 | Registrar traslado hospitalario | RF-HOS-004 | Gestor de camas y hospitalización, Responsable de admisión hospitalaria |
| CU-17.05 | Registrar egreso administrativo | RF-HOS-006 | Responsable de admisión hospitalaria, Gestor de camas y hospitalización |
| CU-17.06 | Comprobar disponibilidad y restricciones del destino | RF-HOS-003, RF-HOS-004 | Incluido por el caso base |

Inclusiones obligatorias:
- `CU-17.03` → `CU-17.06`: Asignar cama incluye comprobar disponibilidad y restricciones del destino.
- `CU-17.04` → `CU-17.06`: Registrar traslado hospitalario incluye comprobar disponibilidad y restricciones del destino.

Reglas del comportamiento:
- **RF-HOS-006**: Después del egreso, actualizar el estado de cama según el flujo institucional; conservar estados intermedios.

### CU-18 Gestionar procedimientos quirúrgicos

La secuencia clínica no se expresa mediante include o extend. Recuperación y cierre son un objetivo propio que puede registrarse posteriormente.

[Modelo editable](CU_18_Gestionar_Quirofano.oom) · [Diagrama SVG](svg/CU_18_Gestionar_Quirofano.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-18.01 | Programar cirugía | RF-QUI-001 | Personal de quirófano, Médico |
| CU-18.02 | Registrar lista de verificación preoperatoria | RF-QUI-002 | Personal de quirófano, Médico |
| CU-18.03 | Registrar intervención quirúrgica | RF-QUI-003 | Médico |
| CU-18.04 | Registrar recuperación y cierre | RF-QUI-004 | Personal de quirófano, Médico |
| CU-18.05 | Comprobar disponibilidad de recursos quirúrgicos | RF-QUI-001 | Incluido por el caso base |

Inclusiones obligatorias:
- `CU-18.01` → `CU-18.05`: Programar cirugía incluye comprobar disponibilidad de recursos quirúrgicos.

### CU-19 Registrar alta médica

El alta médica y el egreso administrativo son operaciones distintas. CU-17 conserva la actualización operativa de camas y los estados de limpieza o preparación.

[Modelo editable](CU_19_Registrar_Alta.oom) · [Diagrama SVG](svg/CU_19_Registrar_Alta.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-19.01 | Registrar alta médica autorizada | RF-HOS-006 | Médico |
| CU-19.02 | Registrar indicaciones de salida | RF-HOS-006 | Incluido por el caso base |

Inclusiones obligatorias:
- `CU-19.01` → `CU-19.02`: Registrar alta médica autorizada incluye registrar indicaciones de salida.

### CU-20 Generar facturas

Cargar servicios y emitir documentos son objetivos independientes. Calcular importes es comportamiento incluido al emitir, sin convertir al cálculo automático en una interacción del facturador.

[Modelo editable](CU_20_Generar_Facturas.oom) · [Diagrama SVG](svg/CU_20_Generar_Facturas.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-20.01 | Registrar cargos por servicios | RF-FAC-001 | Facturador |
| CU-20.02 | Emitir documento de facturación | RF-FAC-003 | Facturador |
| CU-20.03 | Calcular importes | RF-FAC-002 | Incluido por el caso base |

Inclusiones obligatorias:
- `CU-20.02` → `CU-20.03`: Emitir documento de facturación incluye calcular importes.

### CU-21 Registrar pagos y consultar saldos

Caja y facturación tienen responsabilidades separadas. Una devolución posterior no es automáticamente extend de Registrar pago; no se ha especificado un punto de extensión dentro de esa ejecución.

[Modelo editable](CU_21_Registrar_Pagos.oom) · [Diagrama SVG](svg/CU_21_Registrar_Pagos.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-21.01 | Consultar estado de cuenta | RF-FAC-006 | Cajero, Facturador |
| CU-21.02 | Registrar pago | RF-FAC-004 | Cajero |
| CU-21.03 | Gestionar anulaciones y devoluciones | RF-FAC-005 | Facturador |

### CU-22 Generar reportes e indicadores

Se elimina Seleccionar tipo de informe como caso incluido desde cada informe ya tipado, junto con sus flechas invertidas. Los filtros forman parte del flujo de cada consulta. La exportación es un objetivo independiente, con informe autorizado como precondición.

[Modelo editable](CU_22_Generar_Reportes.oom) · [Diagrama SVG](svg/CU_22_Generar_Reportes.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-22.01 | Generar informe de citas | RF-INF-001 | Analista de estadísticas hospitalarias, Director hospitalario |
| CU-22.02 | Generar informe de atenciones | RF-INF-002 | Analista de estadísticas hospitalarias, Director hospitalario |
| CU-22.03 | Generar informe de ocupación | RF-INF-003 | Analista de estadísticas hospitalarias, Director hospitalario, Gestor de camas y hospitalización |
| CU-22.04 | Generar informe de farmacia | RF-INF-004 | Analista de estadísticas hospitalarias, Director hospitalario, Farmacéutico |
| CU-22.05 | Generar informe financiero | RF-INF-005 | Facturador, Cajero, Director hospitalario |
| CU-22.06 | Exportar informe autorizado | RF-INF-006 | Analista de estadísticas hospitalarias, Director hospitalario, Gestor de camas y hospitalización, Farmacéutico, Facturador, Cajero |

Reglas del comportamiento:
- **RF-INF-007**: Registrar generación y exportación de informes sensibles cuando lo exija la política de auditoría; no es include incondicional de todo informe.

### CU-23 Consultar auditoría y trazabilidad

La generación y protección de bitácoras son reglas transversales del sistema. No se presentan como tareas del auditor ni como actores internos.

[Modelo editable](CU_23_Consultar_Auditoria.oom) · [Diagrama SVG](svg/CU_23_Consultar_Auditoria.svg)

| Código | Objetivo o comportamiento | Requisitos | Actor directo |
|---|---|---|---|
| CU-23.01 | Consultar registros de auditoría | RF-AUD-002 | Auditor, Responsable de seguridad, Administrador del sistema |

Reglas del comportamiento:
- **RF-AUD-001**: Registrar eventos definidos por la institución con usuario, fecha, tipo, objeto y resultado. Aplica a autenticación, permisos, accesos, cambios, validaciones, anulaciones y exportaciones.
- **RF-AUD-003**: Impedir modificación o eliminación por usuarios ordinarios; la administración de registros exige controles adicionales.
- **RF-AUD-004**: Registrar accesos denegados relevantes sin contraseñas ni secretos.

## Decisiones institucionales pendientes

1. Ratificar quién tiene autorización expresa para resolver duplicados de pacientes. Se propone al responsable de admisión como participante de CU-04.05, con permiso adicional; no se atribuye esa facultad a todos los usuarios de admisión.

2. Confirmar los permisos específicos para modificar agendas, registrar triaje, validar resultados e informes, efectuar anulaciones y acceder a evidencias clínicas de auditoría. Las asociaciones están limitadas por las competencias y restricciones documentadas; no sustituyen la matriz de autorizaciones definitiva.

3. Mantener como decisiones de alcance cualquier portal del paciente, servicio externo, procedimiento asistido de soporte o motor de alertas clínicas. No se consideran aprobados por aparecer en una ficha, glosario o lista de posibles actores.

4. Corregir posteriormente las inconsistencias internas de la ERS y completar las fichas ECUD con flujos, alternativas y criterios de aceptación. Esta entrega corrige los diagramas y su trazabilidad; no reescribe esos documentos.

## Trazabilidad y comprobación

La [matriz CSV](TRAZABILIDAD_ERS.csv) y su [versión JSON](TRAZABILIDAD_ERS.json) relacionan los 74 requisitos funcionales con objetivos, comportamientos incluidos o reglas transversales. Distinguir estos tipos evita atribuir al auditor una tarea automática o afirmar que un requisito desapareció porque no se dibujó como un óvalo. La cobertura documental no demuestra que el software esté implementado o aceptado.

La [validación estructural](VALIDACION_ESTRUCTURAL.json) comprueba los 24 OOM, los vínculos de los 24 modelos en el proyecto, referencias locales, coincidencia entre extremos gráficos y semánticos, actores fuera del sujeto, casos dentro, ausencia de elementos semánticos ocultos y ausencia de ciclos de inclusión. También comprueba que el general conserve los 23 códigos y los actores del detalle, y que existan 29 láminas PDF y 29 SVG. El proyecto se abrió en PowerDesigner 16 y se comprobaron visualmente muestras de dispensación, reportes y la vista general de seguridad. Las 29 páginas del PDF se renderizaron y revisaron. La comprobación programática no equivale a ejecutar todas las reglas de Check Model de PowerDesigner.

Los SVG y el PDF se dibujaron a partir de los nombres, símbolos, geometría y relaciones guardados en los OOM. Son exportaciones de lectura; las propiedades y comentarios completos permanecen en los archivos editables.

## Archivos y apertura

Abrir [CASOS_USO_SIGH_CORREGIDOS.prj](CASOS_USO_SIGH_CORREGIDOS.prj) en PowerDesigner y hacer doble clic en el modelo deseado. En `CU_SIGHO_General` se pueden abrir las seis vistas G01 a G06. La tecla **F8** centra la vista general del diagrama. Si PowerDesigner muestra un diagrama de proyecto vacío llamado Diagram_1, abrir uno de los modelos de su árbol: los casos están en los OOM.

Para lectura, usar la [vista previa HTML](VISTA_PREVIA.html) o el [PDF de diagramas](DIAGRAMAS_CASOS_USO_CORREGIDOS.pdf). Conservar juntos el proyecto y los OOM, ya que las rutas son relativas. Los modelos previos permanecen en la carpeta superior; sus identificadores no se reutilizaron para evitar colisiones con modelos ya abiertos.
