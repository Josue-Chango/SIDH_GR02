# Comparación de los diagramas de casos de uso con la ERS

**Estado posterior:** las correcciones derivadas de esta revisión se aplicaron a los 24 modelos mediante PowerDesigner el 2 de noviembre de 2026. Este documento conserva los hallazgos previos; la correspondencia actual está en `TRAZABILIDAD_ERS_CASOS_USO.md`. Respaldo anterior a las correcciones: `_RESPALDO/Antes_Corregir_ERS_2026-11-02`.

Fecha de revisión: 2 de noviembre de 2026.

Fuentes: ERS_SIGH_GR02.docx y los 24 modelos .oom de esta carpeta. Se revisaron los objetos, actores, asociaciones y dependencias almacenados en los modelos, además del catálogo y los requisitos funcionales de la ERS. Esta revisión no modifica los modelos ni la ERS.

Los 23 casos principales coinciden en nombre y propósito con CU-01 a CU-23 de la tabla 23 de la ERS, sección 7.3. Existe además el diagrama general. Esta correspondencia de catálogo no equivale a cobertura completa: la ERS contiene 74 identificadores RF distintos y varias funciones no se representan explícitamente.

## Comparación de los 24 diagramas

“Correspondencia” indica coincidencia funcional visible; no certifica que los flujos, permisos o criterios de aceptación estén completamente especificados.

| Diagrama | Referencia principal en la ERS | Resultado de la comparación |
|---|---|---|
| CU-01 Iniciar sesión | RF-SEG-001, 004 y 005 | Autenticación y control de sesión representados. Falta recuperación de credenciales; cierre y expiración quedan agrupados bajo Controlar sesión. |
| CU-02 Usuarios y roles | RF-SEG-002 y 003 | Administración de cuentas y asignación de roles representadas. Activación y desactivación necesitan detalle en la especificación del caso. |
| CU-03 Catálogos | RF-CAT-001 a 003 | Correspondencia de las tres funciones principales. |
| CU-04 Pacientes | RF-PAC-001 a 005 | Registro, búsqueda, duplicados e historial representados. Actualización solo aparece en el caso principal, sin un caso específico para RF-PAC-003. Revisar participación directa del paciente. |
| CU-05 Citas | RF-CIT-001 a 006 | Programación, reprogramación, cancelación y consulta representadas. Faltan administración de agendas y gestión de asistencia como funciones explícitas. Consultar una agenda no cubre configurarla. |
| CU-06 Admisión | CU-06 del catálogo; RF-PAC-004 y RF-HOS-001 relacionados | Coincide con el catálogo. Precisar diferencias entre ingreso administrativo, ingreso hospitalario y apertura del episodio clínico. |
| CU-07 Historia clínica | RF-HC-005 y restricciones de acceso | Consulta de antecedentes y resultados representada. No cubre por sí sola gestionar alergias ni documentos. Acceso del auditor sujeto al alcance autorizado. |
| CU-08 Consulta | RF-HC-001 a 004 y 006 a 008 | Consulta, diagnóstico, evolución y finalización representados. Faltan apertura de episodio, gestión de alergias y documentos clínicos como funciones explícitas. |
| CU-09 Signos y cuidados | RF-HOS-005 | Correspondencia con cuidados y observaciones. Alertar valores críticos requiere trazabilidad adicional hacia una obligación concreta de la ERS. |
| CU-10 Urgencias | RF-EME-001 a 004 | Correspondencia de las cuatro funciones principales. El identificador temporal y su conciliación deben detallarse en el flujo. |
| CU-11 Solicitudes de laboratorio | RF-LAB-001 y 005 | Solicitud y consulta representadas. Consultar resultados es una operación posterior; revisar su relación con solicitar un examen. |
| CU-12 Resultados de laboratorio | RF-LAB-002 a 005 | Las funciones aparecen. Separar la participación del médico en consultar resultados de las tareas de registrar y validar del personal autorizado. |
| CU-13 Imagenología | RF-IMG-001 a 004 | Correspondencia funcional. Diferenciar las acciones del médico solicitante y del profesional de imágenes. |
| CU-14 Recetas | CU-14; RF-HC-002 y RF-FAR-001, 003 relacionados | Prescripción representada. Distinguir la emisión médica de la validación farmacéutica para dispensar, también representada en CU-15. |
| CU-15 Dispensación | RF-FAR-002 a 004 | Correspondencia con disponibilidad, validación y dispensación. |
| CU-16 Inventario | RF-FAR-005 a 007 | Correspondencia con lotes, movimientos y alertas de stock. |
| CU-17 Camas | RF-HOS-001 a 004 y 006 | Ingreso, asignación, traslado y alta representados. Administrar camas queda agrupado en el caso principal; explicitar gestión de recursos y estados de RF-HOS-002. |
| CU-18 Quirófano | RF-QUI-001 a 004 | Las cuatro funciones aparecen. Revisar si recuperación y cierre deben tratarse como extensión o como parte del proceso descrito. |
| CU-19 Alta | RF-HOS-006 | Alta, indicaciones y actualización de disponibilidad representadas. Documentar estados intermedios de limpieza o preparación. |
| CU-20 Facturas | RF-FAC-001 a 003 | Correspondencia de cargos, importes y documentos. La facturación tributaria externa continúa condicionada al alcance aprobado. |
| CU-21 Pagos | RF-FAC-004 a 006 | Correspondencia funcional. Distinguir cajero y facturador según el catálogo detallado. Participación del paciente condicionada al canal autorizado. |
| CU-22 Reportes | RF-INF-001 a 007 | Filtros, exportación y registro representados. Los cinco informes específicos están agrupados bajo Seleccionar tipo de informe y no tienen trazabilidad individual visible. |
| CU-23 Auditoría | RF-AUD-001 a 004 | Consulta y protección representadas. Falta registro explícito de accesos denegados. El registro de eventos aparece en CU-01, pero su alcance transversal no queda documentado. |
| General | Secciones 7.2, 7.3 y catálogo de usuarios | Contiene los 23 casos principales y 14 actores, pero omite asociaciones presentes en los diagramas individuales. El paciente queda aislado. |

## Diferencias que deben resolverse primero

1. **Completar funciones sin representación explícita.** RF-SEG-005 Recuperación de credenciales; RF-CIT-001 Administrar agendas; RF-CIT-005 Gestionar asistencia; RF-HC-001 Abrir episodio; RF-HC-006 Gestionar alergias; RF-HC-008 Gestionar documentos; RF-AUD-004 Registrar accesos denegados. Una función podría estar prevista en un flujo interno, pero no hay evidencia suficiente en el diagrama para darla por cubierta.

2. **Sincronizar el general con los individuales.** En los individuales aparecen, entre otras, las asociaciones Médico–Gestionar citas, Enfermero y Auditor–Consultar HCE, Enfermero y Admisión–Gestionar urgencias, Médico–Imagenología, Personal de hospitalización–Alta y Administrador–Auditoría. Estas asociaciones no aparecen en el general. Un diagrama general puede simplificar, pero debe explicar su criterio de selección para evitar interpretaciones contradictorias.

3. **Resolver el acceso del paciente.** La ERS, secciones 7.1 y 7.2 y ficha U-20, condiciona el autoservicio a su aprobación. CU-04, CU-05 y CU-21 muestran al paciente asociado a funciones del sistema; el general lo muestra sin relaciones. Debe decidirse si interactúa directamente por un portal aprobado o participa en el proceso hospitalario a través del personal.

4. **Precisar responsabilidades.** La ERS diferencia 20 perfiles; los diagramas usan actores más amplios. Agrupar médicos o personal de admisión es una abstracción posible, pero necesita una correspondencia documentada. Responsable de seguridad, analista de estadísticas y técnico de soporte no tienen un actor explícito. Cajero y facturador se agrupan en Personal de facturación. La ausencia de un perfil no obliga por sí sola a crear un módulo, especialmente cuando sus funciones son condicionales.

5. **Revisar las relaciones include y extend.** Los diagramas usan un caso principal “Gestionar…” para agrupar operaciones. Debe justificarse cuáles se ejecutan obligatoriamente dentro del caso y cuáles son objetivos independientes. Por ejemplo, consultar citas no debería implicar necesariamente programar una nueva; registrar resultados no implica que el médico deba registrarlos o validarlos para consultarlos. Estas son observaciones de modelado, no errores de dirección de flecha demostrados.

6. **Completar trazabilidad.** La tabla 18 de la ERS tiene columnas Caso de uso y Actor sin completar y una lista funcional parcial. Relacionar los 74 RF con CU, actor, flujo y criterio de aceptación permitirá distinguir cobertura explícita, cobertura agrupada y omisiones. No se calcula un porcentaje de cumplimiento a partir de los nombres.

## Observaciones sobre la ERS

La tabla 23 proporciona una base consistente de 23 casos. Sin embargo, hay diferencias internas que conviene corregir antes de tomarla como referencia definitiva: RF-SEG-004 aparece titulado Gestión de usuarios en su tabla aunque describe sesiones; RF-SEG-005 aparece titulado Autenticación de usuarios en su tabla aunque describe recuperación, y su prioridad cambia entre el texto y la tabla. El índice de tablas conserva referencias a clientes, vehículos, mecánicos y taller ajenas al dominio hospitalario.

Los requisitos no funcionales de rendimiento, seguridad, respaldo y disponibilidad requieren especificaciones y pruebas complementarias. Su ausencia como óvalos en un diagrama de casos de uso no constituye por sí sola una omisión.

**Conclusión:** el catálogo de casos principales está alineado con la ERS. La cobertura detallada y la asignación de responsabilidades son parciales y requieren las correcciones anteriores antes de considerar validado el conjunto.
