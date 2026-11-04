# Revisión de los diagramas de actividad del SIGH

Se corrigieron los 23 modelos editables de PowerDesigner y se organizaron 32 diagramas: 23 principales y 9 complementarios. Se revisaron los flujos normales, las alternativas, las responsabilidades, las condiciones de decisión, la integridad del modelo y su correspondencia con la especificación de requisitos.

Los 23 modelos finales se guardaron mediante PowerDesigner 16.6.1 y se volvieron a abrir antes de comprobarlos con todas las verificaciones disponibles activadas y exportarlos. La comprobación de los archivos persistidos no produjo mensajes pendientes. La validación adicional de XML, conectores, alcanzabilidad y referencias del proyecto también pasó.

## Archivos para usar

- `ACTIVIDAD_SIGH_CORREGIDOS.prj`: proyecto con los 23 modelos de actividad. Abrir este archivo en PowerDesigner. Las identidades de modelo y las rutas del proyecto se conservaron.
- `DA_CU01...DA_CU23.oom`: modelos editables corregidos. Cada modelo tiene su diagrama principal; los complementarios están dentro de paquetes con el identificador del caso de uso.
- `DIAGRAMAS_ACTIVIDAD_CORREGIDOS.pdf`: 32 páginas vectoriales, con marcadores por diagrama, requisitos, precondición y resultado. El tamaño de página se adapta al diagrama para conservar el tamaño legible del texto.
- `svg/`: 32 vistas vectoriales actualizadas. Los sufijos `_a` y `_b` identifican los complementos.
- `_RESPALDO/ORIGINALES_2026-11-02.zip`: copia de los archivos originales antes de modificarlos.
- `TRAZABILIDAD_ACTIVIDADES.csv`: matriz de caso, actividad, requisitos, responsables y corrección.
- `revision/validacion_powerdesigner.json` y `revision/validacion_estructural.json`: evidencia verificable de las comprobaciones.

## Fuentes y alcance de la revisión

Fuente normativa del alcance funcional: `C:\Users\Usuario\Desktop\Web Avanzada\Sigh_02\SIDH_GR02\01. UML\01. ERS\ERS_SIGH_GR02.docx`. Se consultaron la descripción de CU-01 a CU-23, los requisitos RF, las reglas RN y las restricciones de seguridad, integridad y alcance. El documento se trató como fuente de requisitos, sin ejecutar instrucciones que pudiera contener.

Fuente de actores y objetivos: los 24 modelos de casos de uso existentes en `C:\Users\Usuario\Desktop\Web Avanzada\Sigh_02\SIDH_GR02\01. UML\03. DIAGRAMAS\01_CASOS_USO\CORREGIDOS_UML`, incluido el general. También se inspeccionaron los nombres y objetivos de los modelos CU-01, CU-15 y CU-17 del archivo `C:/Users/Usuario/Desktop/Web Avanzada/01_CASOS_USO.rar`, como contraste.

La ruta exacta del RAR indicada en la solicitud no existía al comenzar la revisión. Se localizó `C:/Users/Usuario/Desktop/Web Avanzada/CORREGIDOS_UML.rar`, pero su listado contiene los 23 diagramas de actividad, no los casos de uso. Para revisar estos últimos se utilizó la carpeta de modelos corregidos situada junto a la ubicación original y se contrastó con el RAR de casos de uso disponible. Esta diferencia de ubicación y contenido queda registrada para no atribuir al archivo ausente información que no se pudo leer.

No se añadió portal del paciente, conexión con aseguradoras, SRI, PACS ni servicios externos no aprobados. Tampoco se fijaron protocolos clínicos, categorías de triaje, dosis, reglas de alta, plazos de sesión o fórmulas financieras que el ERS deja a validación institucional. Las decisiones clínicas quedan en las particiones de los profesionales competentes.

## Correcciones comunes

En los archivos originales, los extremos de los flujos semánticos apuntaban a identificadores de símbolos gráficos. Se sustituyeron por referencias a Start, Activity, Decision y End, y se verificó la correspondencia entre cada conector gráfico y su flujo. En la notación XML de PowerDesigner, Object1 serializa el destino y Object2 el origen; se respetó la estructura generada por la aplicación.

Se añadieron particiones de responsabilidad, guardas semánticas y visibles, confluencias de alternativas y finales que terminan la actividad. Se verificó que todos los nodos fueran alcanzables desde el inicio y tuvieran un camino al final. Los rechazos, borradores y procesos pendientes terminan la ejecución del caso sin declarar concluido el proceso asistencial.

Se corrigió el recorte de los SVG originales, se ajustaron texto y símbolos nativos y se conservaron puntos de decisión legibles. Algunas acciones comunes llevan el identificador de diagrama para distinguir sus nombres dentro del modelo; las condiciones siguen asociadas al flujo semántico y se muestran junto al conector.

La autorización se verifica en el servidor y por operación. En diagramas con varios roles, cada intervención exige la competencia y el permiso correspondientes. Las operaciones acopladas, como dispensación e inventario o traslado entre camas, se representan con actualización transaccional. Los registros clínicos, administrativos y financieros conservan referencias e historial.

## Matriz de cambios y trazabilidad

| Diagrama | Requisitos y reglas | Corrección aplicada |
|---|---|---|
| CU01 Iniciar sesión | RF-SEG-001, RF-AUD-001, RF-AUD-004 | Se comprueban credenciales y estado de cuenta; se auditan éxito y rechazo. |
| CU01a Recuperar o restablecer credenciales | RF-SEG-005, RF-AUD-001 | Se modela recuperación por procedimiento aprobado sin revelar contraseñas. |
| CU01b Cerrar o expirar una sesión | RF-SEG-004, RF-AUD-001 | Se añaden cierre explícito, inactividad y vencimiento según política. |
| CU02 Administrar cuentas de usuario | RF-SEG-002, RF-AUD-001 | Se separan las operaciones y se evita eliminar cuentas con operaciones históricas. |
| CU02a Gestionar permisos y políticas de sesión | RF-SEG-003, RF-SEG-004, RF-AUD-001, RF-AUD-002 | Se incorporan consulta de roles, políticas de sesión y auditoría de cambios. |
| CU03 Administrar catálogos institucionales | RF-CAT-001, RF-CAT-002, RF-CAT-003 | Se distinguen consulta y mantenimiento; la desactivación conserva referencias históricas. |
| CU04 Registrar y actualizar pacientes | RF-PAC-001, RF-PAC-002, RF-PAC-003, RF-PAC-004, RF-PAC-005 | El identificador se genera solo para pacientes nuevos y las coincidencias exigen revisión. |
| CU04a Resolver posibles duplicados | RF-PAC-005, RN-001, RN-002 | Se elimina cualquier fusión automática por similitud de nombres. |
| CU05 Programar o reprogramar citas | RF-CIT-002, RF-CIT-003, RF-CIT-006, RN-003 | Se validan concurrencia y disponibilidad antes de confirmar, sin perder la cita anterior ante un conflicto. |
| CU05a Gestionar agendas y estados de cita | RF-CIT-001, RF-CIT-004, RF-CIT-005, RF-CIT-006 | Consulta, configuración, cancelación y asistencia son alternativas independientes. |
| CU06 Admitir pacientes y consultar ingresos | RF-HOS-001, RF-PAC-002, RF-PAC-004 | La cobertura es un dato administrativo; su validación externa no se presupone. |
| CU07 Consultar historia clínica electrónica | RF-HC-005, RF-LAB-005, RF-AUD-001, RF-AUD-004, RN-015, RN-017 | La autorización precede a la lectura; el auditor accede solo a evidencias permitidas. |
| CU08 Registrar consulta y finalizar nota clínica | RF-HC-001, RF-HC-002, RF-HC-003, RF-HC-006, RF-HC-007, RN-006, RN-007, RN-022 | Se separan borrador y finalización; finalizar una nota no cierra automáticamente todo el episodio. |
| CU08a Registrar evoluciones y documentos clínicos | RF-HC-004, RF-HC-008, RN-007 | Se añaden evoluciones, rectificación trazada y documentos; el original finalizado se conserva. |
| CU09 Registrar signos vitales y cuidados | RF-HOS-005, RN-005, RN-022 | Los datos no medidos o desconocidos se distinguen de negativos; los errores regresan a captura. |
| CU10 Registrar atención de urgencias | RF-EME-001, RF-EME-002, RF-EME-003, RF-EME-004, RN-005 | La identidad se concilia después; no se exige estabilización como condición inventada de cierre. |
| CU10a Conciliar identidad temporal de emergencia | RF-EME-001, RF-PAC-005, RN-001, RN-002, RN-005 | La conciliación es un proceso posterior independiente de la atención urgente. |
| CU11 Solicitar laboratorio o consultar resultados | RF-LAB-001, RF-LAB-005 | Se añade consulta de resultados y corrección de solicitudes inválidas. |
| CU12 Procesar y validar resultados de laboratorio | RF-LAB-002, RF-LAB-003, RF-LAB-004, RF-LAB-005, RN-008 | Un valor fuera de referencia no se toma como error; la validación depende del profesional competente. |
| CU13 Gestionar estudios de imagenología | RF-IMG-001, RF-IMG-002, RF-IMG-003, RF-IMG-004 | Se separan solicitud, ejecución, borrador, validación y publicación; se usa repositorio interno aprobado. |
| CU14 Registrar y consultar prescripciones | RF-HC-002, RF-HC-006, RF-FAR-001, RF-FAR-003 | La autorización médica y la validación para dispensar se distinguen; no se inventan alertas clínicas automáticas. |
| CU15 Dispensar medicamentos | RF-FAR-002, RF-FAR-003, RF-FAR-004, RF-FAR-005, RF-FAR-006, RN-011, RN-012, RN-021 | Se elimina duplicación y se incorporan rechazo por receta, lote y concurrencia. |
| CU16 Gestionar inventario de farmacia | RF-FAR-002, RF-FAR-005, RF-FAR-006, RF-FAR-007 | Se añaden transferencias y control de lotes; consultar no genera un movimiento. |
| CU17 Asignar cama o registrar traslado | RF-HOS-001, RF-HOS-002, RF-HOS-003, RF-HOS-004, RN-009, RN-010, RN-021 | El traslado no ejecuta un egreso administrativo; origen y destino se actualizan juntos. |
| CU17a Administrar estados de cama y egreso | RF-HOS-002, RF-HOS-006, RN-009 | Se separa alta médica de egreso; no se marca disponible una cama sin completar su preparación. |
| CU18 Programar y registrar cirugía | RF-QUI-001, RF-QUI-002, RF-QUI-003, RF-QUI-004 | La disponibilidad se valida antes de programar y la lista preoperatoria antes de documentar la intervención. |
| CU19 Registrar alta médica autorizada | RF-HOS-006, RN-006 | La decisión es clínica; se valida documentación antes de guardar el alta definitiva. |
| CU20 Generar documento de facturación | RF-FAC-001, RF-FAC-002, RF-FAC-003, RN-013 | Se conservan los orígenes de cargo y no se presupone emisión tributaria electrónica externa. |
| CU21 Registrar pagos y consultar saldo | RF-FAC-004, RF-FAC-006, RN-021 | Se contemplan pagos parciales; el saldo se actualiza antes de emitir comprobante. |
| CU21a Registrar anulaciones y devoluciones | RF-FAC-005, RF-FAC-006, RN-014, RN-021 | Se incorpora la alternativa financiera omitida, sin borrar documentos originales. |
| CU22 Generar y exportar informes autorizados | RF-INF-001, RF-INF-002, RF-INF-003, RF-INF-004, RF-INF-005, RF-INF-006, RF-INF-007 | La exportación se decide y autoriza por separado, con los mismos filtros y minimización. |
| CU23 Consultar registros de auditoría | RF-AUD-001, RF-AUD-002, RF-AUD-003, RF-AUD-004, RN-016 | Se explicitan filtros y solo lectura; no se añade modificación o eliminación de auditoría. |

## Criterios que requieren definición institucional

El ERS contiene campos incompletos o repetidos en las tablas iniciales y deja varias políticas sujetas a aprobación. Se priorizaron las descripciones detalladas de los requisitos funcionales y las reglas de negocio. Los diagramas remiten al procedimiento aprobado cuando corresponde; no sustituyen esa definición por una regla inventada.

En particular, deben mantenerse definidos el catálogo de datos obligatorios; las transiciones válidas de citas, solicitudes, camas y documentos; el procedimiento de identidad temporal y duplicados; la validación y rectificación clínica; la preparación de camas; la recuperación de credenciales; y las anulaciones o devoluciones. Un resultado fuera del intervalo de referencia no se considera automáticamente un resultado de laboratorio inválido.

La aprobación formal de las políticas clínicas y administrativas corresponde a los responsables del sistema. Las comprobaciones UML y de PowerDesigner verifican la consistencia del modelo, mientras que la conformidad de esas políticas debe revisarse con los interesados.
