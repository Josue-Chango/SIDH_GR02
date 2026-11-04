# Diagramas de secuencia del SIGH

Este conjunto desarrolla las interacciones de los 23 casos generales del catálogo: 84 objetivos de usuario y dos reglas transversales, en 86 secuencias. Los 11 comportamientos incluidos se detallan dentro de sus operaciones base, sin convertirlos en interacciones independientes obligatorias para el usuario.

## Cómo abrir los diagramas

Abra `SECUENCIAS_SIGH_CORREGIDAS.prj` en SAP PowerDesigner y despliegue el modelo del módulo que necesite. Cada objetivo tiene una vista identificada por su código, por ejemplo `DS_CU05.03` para programar una cita. También puede abrir directamente cualquier `.oom` de esta carpeta. El proyecto utiliza rutas relativas. Al abrir una vista, use F8 para centrar todo el diagrama y F5 para ver el tamaño real; también puede ampliar con F6.

`VISTA_PREVIA.html` permite buscar y consultar todas las secuencias sin PowerDesigner. `DIAGRAMAS_SECUENCIA_SIGH.pdf` contiene una página vectorial por secuencia, con marcadores por módulo. Las láminas tienen formato amplio para leerlas con zoom, sin repartir una interacción entre páginas.

Las carpetas `svg` y `plantuml` contienen respectivamente la versión vectorial y una fuente textual editable por secuencia. Los archivos `.oom` conservan mensajes, activaciones y fragmentos como elementos nativos editables; las precondiciones, resultados y restricciones están en los comentarios del diagrama. La fuente PlantUML omite barras de activación para evitar las limitaciones de su balance lineal entre ramas; las versiones PowerDesigner, SVG y PDF sí las incluyen.

Los modelos originales de `03_SECUENCIA` se conservan. Este conjunto corregido se guarda en `03_SECUENCIA/CORREGIDOS_UML`.

## Nivel de diseño y convenciones

El tiempo avanza de arriba abajo. Una flecha continua con punta cerrada representa una llamada síncrona; una flecha discontinua con punta abierta representa su respuesta. Cada respuesta está vinculada en los datos de generación a su llamada. Las activaciones empiezan con la recepción de una llamada y terminan con su respuesta; cuando una llamada exterior tiene respuestas alternativas, su barra abarca las alternativas gráficas, pero solo se ejecuta el operando seleccionado.

`alt` expresa alternativas mutuamente excluyentes mediante una condición y su rama `[else]`. `opt` expresa una acción condicional, por ejemplo auditar una consulta cuando la política lo requiere. Los fragmentos contienen mensajes del escenario; no se utilizan como agrupaciones de objetivos independientes. La autenticación es una interacción propia y las demás solicitudes comprueban sesión y autorización en servidor.

Los participantes internos son instancias lógicas propuestas: `interfaz` recibe solicitudes, `aplicacion` coordina el caso, `seguridad` comprueba sesión y alcance, `reglas` evalúa consistencia y reglas institucionales, `datos` encapsula persistencia y transacciones, y `auditoria` prepara o registra eventos protegidos. Los estereotipos `boundary`, `control` y `repository` documentan esas responsabilidades. Esta descomposición es una propuesta de análisis; no afirma que la ERS haya definido esas clases, APIs, microservicios o una tecnología concreta. El diagrama no es un flujo de actividades ni una llamada directa del actor a la base de datos.

Cada lámina elige un actor concreto de los casos corregidos. Los otros roles permitidos aparecen en las restricciones y solo pueden sustituirlo dentro de su competencia, relación asistencial y permiso específico. No deben interpretarse como participantes que ejecutan todas las operaciones en una misma atención.

## Consistencia y seguridad

Las escrituras confirman los cambios y su evento de auditoría en una unidad de persistencia. Es una decisión de diseño para mantener trazabilidad; el mecanismo físico puede implementarse mediante transacción local o registro duradero equivalente. Si no se confirma, el resultado indica ausencia de cambios parciales y permite informar conflicto, validación o fallo. En la reserva de turnos, camas, cirugía, inventario y pagos se vuelve a comprobar la vigencia dentro de la confirmación atómica. Una lectura previa de disponibilidad no basta para garantizar exclusión.

No se revelan contraseñas ni se registran secretos. La recuperación utiliza el mecanismo aprobado por el hospital sin imponer correo, tokens o un proveedor externo. Las consultas aplican minimización y autorización contextual antes de entregar datos. Los informes y exportaciones se auditan de acuerdo con la política de información sensible. La protección frente a un usuario ordinario que intente alterar la bitácora se representa en `DS_TR02`.

La sesión expirada se rechaza en `DS_TR01`; es una regla automática y no un nuevo objetivo de negocio. La generación de alertas de stock forma parte del procesamiento del inventario y de sus umbrales. Los métodos de reglas no asignan diagnósticos, prioridad clínica o decisiones terapéuticas: verifican datos ingresados por profesionales.

## Decisiones de alcance que se conservan

- Alta médica, indicaciones de salida y egreso administrativo mantienen responsabilidades diferentes; una cama puede quedar en limpieza o preparación.
- El resultado provisional de laboratorio y el borrador radiológico se conservan antes de validar y liberar o publicar. La habilitación del profesional se verifica de manera específica.
- Una prescripción médica no es una dispensación. La entrega se vincula con la prescripción y con la salida consistente del inventario, excluyendo lotes caducados o bloqueados.
- La consulta de cobertura utiliza los datos internos. No se incorporan aseguradoras, PACS/DICOM, laboratorio externo, proveedor de identidad o facturación electrónica sin una integración aprobada.
- La resolución de duplicados se limita a personal expresamente autorizado. La asignación propuesta a admisión en el caso corregido debe ratificarse; se conserva la advertencia y no se habilita por el solo nombre del rol.
- Las tarifas, los impuestos, los campos clínicos y los protocolos son los configurados y aprobados por el hospital. Estas interacciones no especifican sus valores ni sustituyen decisiones profesionales.

## Trazabilidad y verificación

`TRAZABILIDAD_ERS.csv` relaciona los 74 RF con secuencias y páginas. `TRAZABILIDAD_CASOS_USO.csv` relaciona los 95 objetivos y comportamientos incluidos con sus interacciones. Una referencia transversal significa que se aplica el control correspondiente, no que el diagrama implemente todo el requisito por sí solo.

Se contrastó la copia actual del ERS y los nombres y códigos de los casos en los 23 modelos corregidos. SHA-256 del ERS: `b0599b72f9ee9d1aab83be530a6048d50424c72358c87ea4e847083ed50ca4fa`. Los encabezados de tablas copiados de otras funciones no prevalecen sobre la descripción y criterios del requisito. El ERS no se modifica.

`VALIDACION_ESTRUCTURAL.json` registra los recuentos y comprueba referencias XML, tipos de símbolos, correspondencia entre extremos gráficos y semánticos, visibilidad, pertenencia de mensajes a operandos, coherencia de llamadas y respuestas por cada alternativa, activaciones, trazabilidad y correspondencia de páginas. La inspección visual de las exportaciones complementa esas comprobaciones.

## Referencias de modelado

- [OMG UML 2.5.1, capítulo 17 Interactions](https://www.omg.org/spec/UML/2.5.1): semántica de líneas de vida, mensajes, respuestas, ejecuciones y fragmentos combinados.
- [SAP PowerDesigner 16.6.6 Object Oriented Architecture, secciones 1.4.2, 1.4.7 y 1.4.8](https://help.sap.com/doc/c7bcdbf06e1b1014b1fadaaf5f160630/16.6.6/enUS/object_oriented_modeling.pdf): representación nativa de secuencias, fragmentos y mensajes.
- [Sparx Systems Interaction Operators](https://sparxsystems.com/enterprise_architect_user_guide/17.1/modeling_languages/interactionoperators.html): condiciones de operadores `alt` y `opt`.

## Catálogo de secuencias

| Página PDF | Secuencia | Objetivo | Modelo |
|---|---|---|---|
| 1 | [DS_CU01.01](svg/DS_CU01_01.svg) | Iniciar sesión | [DS_CU01_Iniciar_Sesion.oom](DS_CU01_Iniciar_Sesion.oom) |
| 2 | [DS_CU01.02](svg/DS_CU01_02.svg) | Cerrar sesión | [DS_CU01_Iniciar_Sesion.oom](DS_CU01_Iniciar_Sesion.oom) |
| 3 | [DS_CU01.03](svg/DS_CU01_03.svg) | Recuperar o restablecer credenciales | [DS_CU01_Iniciar_Sesion.oom](DS_CU01_Iniciar_Sesion.oom) |
| 4 | [DS_TR01](svg/DS_TR01.svg) | Rechazar solicitud con sesión expirada | [DS_CU01_Iniciar_Sesion.oom](DS_CU01_Iniciar_Sesion.oom) |
| 5 | [DS_CU02.01](svg/DS_CU02_01.svg) | Administrar cuentas de usuario | [DS_CU02_Gestionar_Usuarios_Roles.oom](DS_CU02_Gestionar_Usuarios_Roles.oom) |
| 6 | [DS_CU02.02](svg/DS_CU02_02.svg) | Asignar roles y permisos | [DS_CU02_Gestionar_Usuarios_Roles.oom](DS_CU02_Gestionar_Usuarios_Roles.oom) |
| 7 | [DS_CU02.03](svg/DS_CU02_03.svg) | Consultar roles y permisos | [DS_CU02_Gestionar_Usuarios_Roles.oom](DS_CU02_Gestionar_Usuarios_Roles.oom) |
| 8 | [DS_CU02.04](svg/DS_CU02_04.svg) | Configurar políticas de sesión | [DS_CU02_Gestionar_Usuarios_Roles.oom](DS_CU02_Gestionar_Usuarios_Roles.oom) |
| 9 | [DS_CU02.05](svg/DS_CU02_05.svg) | Consultar auditoría de cambios | [DS_CU02_Gestionar_Usuarios_Roles.oom](DS_CU02_Gestionar_Usuarios_Roles.oom) |
| 10 | [DS_CU03.01](svg/DS_CU03_01.svg) | Administrar catálogos institucionales | [DS_CU03_Administrar_Catalogos.oom](DS_CU03_Administrar_Catalogos.oom) |
| 11 | [DS_CU03.02](svg/DS_CU03_02.svg) | Controlar vigencia de catálogos | [DS_CU03_Administrar_Catalogos.oom](DS_CU03_Administrar_Catalogos.oom) |
| 12 | [DS_CU04.01](svg/DS_CU04_01.svg) | Registrar paciente | [DS_CU04_Registrar_Pacientes.oom](DS_CU04_Registrar_Pacientes.oom) |
| 13 | [DS_CU04.02](svg/DS_CU04_02.svg) | Buscar pacientes | [DS_CU04_Registrar_Pacientes.oom](DS_CU04_Registrar_Pacientes.oom) |
| 14 | [DS_CU04.03](svg/DS_CU04_03.svg) | Actualizar datos demográficos | [DS_CU04_Registrar_Pacientes.oom](DS_CU04_Registrar_Pacientes.oom) |
| 15 | [DS_CU04.04](svg/DS_CU04_04.svg) | Consultar historial administrativo | [DS_CU04_Registrar_Pacientes.oom](DS_CU04_Registrar_Pacientes.oom) |
| 16 | [DS_CU04.05](svg/DS_CU04_05.svg) | Resolver posibles duplicados | [DS_CU04_Registrar_Pacientes.oom](DS_CU04_Registrar_Pacientes.oom) |
| 17 | [DS_CU05.01](svg/DS_CU05_01.svg) | Administrar agendas médicas | [DS_CU05_Gestionar_Citas.oom](DS_CU05_Gestionar_Citas.oom) |
| 18 | [DS_CU05.02](svg/DS_CU05_02.svg) | Consultar agenda diaria | [DS_CU05_Gestionar_Citas.oom](DS_CU05_Gestionar_Citas.oom) |
| 19 | [DS_CU05.03](svg/DS_CU05_03.svg) | Programar cita | [DS_CU05_Gestionar_Citas.oom](DS_CU05_Gestionar_Citas.oom) |
| 20 | [DS_CU05.04](svg/DS_CU05_04.svg) | Reprogramar cita | [DS_CU05_Gestionar_Citas.oom](DS_CU05_Gestionar_Citas.oom) |
| 21 | [DS_CU05.05](svg/DS_CU05_05.svg) | Cancelar cita | [DS_CU05_Gestionar_Citas.oom](DS_CU05_Gestionar_Citas.oom) |
| 22 | [DS_CU05.06](svg/DS_CU05_06.svg) | Registrar asistencia y estado de cita | [DS_CU05_Gestionar_Citas.oom](DS_CU05_Gestionar_Citas.oom) |
| 23 | [DS_CU06.01](svg/DS_CU06_01.svg) | Registrar admisión hospitalaria | [DS_CU06_Admitir_Pacientes.oom](DS_CU06_Admitir_Pacientes.oom) |
| 24 | [DS_CU06.02](svg/DS_CU06_02.svg) | Consultar datos administrativos y cobertura | [DS_CU06_Admitir_Pacientes.oom](DS_CU06_Admitir_Pacientes.oom) |
| 25 | [DS_CU06.03](svg/DS_CU06_03.svg) | Consultar ingresos y egresos | [DS_CU06_Admitir_Pacientes.oom](DS_CU06_Admitir_Pacientes.oom) |
| 26 | [DS_CU07.01](svg/DS_CU07_01.svg) | Consultar antecedentes clínicos | [DS_CU07_Consultar_HCE.oom](DS_CU07_Consultar_HCE.oom) |
| 27 | [DS_CU07.02](svg/DS_CU07_02.svg) | Consultar resultados clínicos | [DS_CU07_Consultar_HCE.oom](DS_CU07_Consultar_HCE.oom) |
| 28 | [DS_CU07.03](svg/DS_CU07_03.svg) | Consultar evidencias clínicas de auditoría | [DS_CU07_Consultar_HCE.oom](DS_CU07_Consultar_HCE.oom) |
| 29 | [DS_CU08.01](svg/DS_CU08_01.svg) | Abrir episodio de atención | [DS_CU08_Registrar_Consulta.oom](DS_CU08_Registrar_Consulta.oom) |
| 30 | [DS_CU08.02](svg/DS_CU08_02.svg) | Registrar consulta médica | [DS_CU08_Registrar_Consulta.oom](DS_CU08_Registrar_Consulta.oom) |
| 31 | [DS_CU08.03](svg/DS_CU08_03.svg) | Registrar diagnósticos | [DS_CU08_Registrar_Consulta.oom](DS_CU08_Registrar_Consulta.oom) |
| 32 | [DS_CU08.04](svg/DS_CU08_04.svg) | Registrar evoluciones clínicas | [DS_CU08_Registrar_Consulta.oom](DS_CU08_Registrar_Consulta.oom) |
| 33 | [DS_CU08.05](svg/DS_CU08_05.svg) | Gestionar alergias y reacciones adversas | [DS_CU08_Registrar_Consulta.oom](DS_CU08_Registrar_Consulta.oom) |
| 34 | [DS_CU08.06](svg/DS_CU08_06.svg) | Firmar o finalizar atención | [DS_CU08_Registrar_Consulta.oom](DS_CU08_Registrar_Consulta.oom) |
| 35 | [DS_CU08.07](svg/DS_CU08_07.svg) | Gestionar documentos clínicos | [DS_CU08_Registrar_Consulta.oom](DS_CU08_Registrar_Consulta.oom) |
| 36 | [DS_CU09.01](svg/DS_CU09_01.svg) | Registrar signos vitales | [DS_CU09_Registrar_Signos_Vitales.oom](DS_CU09_Registrar_Signos_Vitales.oom) |
| 37 | [DS_CU09.02](svg/DS_CU09_02.svg) | Registrar cuidados y observaciones | [DS_CU09_Registrar_Signos_Vitales.oom](DS_CU09_Registrar_Signos_Vitales.oom) |
| 38 | [DS_CU10.01](svg/DS_CU10_01.svg) | Registrar ingreso de emergencia | [DS_CU10_Gestionar_Urgencias.oom](DS_CU10_Gestionar_Urgencias.oom) |
| 39 | [DS_CU10.02](svg/DS_CU10_02.svg) | Completar o conciliar identidad temporal | [DS_CU10_Gestionar_Urgencias.oom](DS_CU10_Gestionar_Urgencias.oom) |
| 40 | [DS_CU10.03](svg/DS_CU10_03.svg) | Registrar clasificación de prioridad | [DS_CU10_Gestionar_Urgencias.oom](DS_CU10_Gestionar_Urgencias.oom) |
| 41 | [DS_CU10.04](svg/DS_CU10_04.svg) | Registrar atención de emergencia | [DS_CU10_Gestionar_Urgencias.oom](DS_CU10_Gestionar_Urgencias.oom) |
| 42 | [DS_CU10.05](svg/DS_CU10_05.svg) | Registrar disposición del paciente | [DS_CU10_Gestionar_Urgencias.oom](DS_CU10_Gestionar_Urgencias.oom) |
| 43 | [DS_CU11.01](svg/DS_CU11_01.svg) | Crear solicitud de laboratorio | [DS_CU11_Solicitar_Laboratorio.oom](DS_CU11_Solicitar_Laboratorio.oom) |
| 44 | [DS_CU11.02](svg/DS_CU11_02.svg) | Consultar resultados de laboratorio | [DS_CU11_Solicitar_Laboratorio.oom](DS_CU11_Solicitar_Laboratorio.oom) |
| 45 | [DS_CU12.01](svg/DS_CU12_01.svg) | Gestionar estado de solicitud y muestra | [DS_CU12_Registrar_Resultados_Lab.oom](DS_CU12_Registrar_Resultados_Lab.oom) |
| 46 | [DS_CU12.02](svg/DS_CU12_02.svg) | Registrar resultados | [DS_CU12_Registrar_Resultados_Lab.oom](DS_CU12_Registrar_Resultados_Lab.oom) |
| 47 | [DS_CU12.03](svg/DS_CU12_03.svg) | Validar y liberar resultados | [DS_CU12_Registrar_Resultados_Lab.oom](DS_CU12_Registrar_Resultados_Lab.oom) |
| 48 | [DS_CU12.04](svg/DS_CU12_04.svg) | Consultar resultados de laboratorio | [DS_CU12_Registrar_Resultados_Lab.oom](DS_CU12_Registrar_Resultados_Lab.oom) |
| 49 | [DS_CU13.01](svg/DS_CU13_01.svg) | Solicitar estudio de imagen | [DS_CU13_Gestionar_Imagenologia.oom](DS_CU13_Gestionar_Imagenologia.oom) |
| 50 | [DS_CU13.02](svg/DS_CU13_02.svg) | Registrar programación y ejecución de estudio | [DS_CU13_Gestionar_Imagenologia.oom](DS_CU13_Gestionar_Imagenologia.oom) |
| 51 | [DS_CU13.03](svg/DS_CU13_03.svg) | Elaborar informe radiológico | [DS_CU13_Gestionar_Imagenologia.oom](DS_CU13_Gestionar_Imagenologia.oom) |
| 52 | [DS_CU13.04](svg/DS_CU13_04.svg) | Validar y publicar informe radiológico | [DS_CU13_Gestionar_Imagenologia.oom](DS_CU13_Gestionar_Imagenologia.oom) |
| 53 | [DS_CU13.05](svg/DS_CU13_05.svg) | Vincular imágenes e informes | [DS_CU13_Gestionar_Imagenologia.oom](DS_CU13_Gestionar_Imagenologia.oom) |
| 54 | [DS_CU13.06](svg/DS_CU13_06.svg) | Consultar informe de imagenología | [DS_CU13_Gestionar_Imagenologia.oom](DS_CU13_Gestionar_Imagenologia.oom) |
| 55 | [DS_CU14.01](svg/DS_CU14_01.svg) | Consultar catálogo de medicamentos | [DS_CU14_Gestionar_Recetas.oom](DS_CU14_Gestionar_Recetas.oom) |
| 56 | [DS_CU14.02](svg/DS_CU14_02.svg) | Registrar prescripción médica | [DS_CU14_Gestionar_Recetas.oom](DS_CU14_Gestionar_Recetas.oom) |
| 57 | [DS_CU14.03](svg/DS_CU14_03.svg) | Consultar prescripciones autorizadas | [DS_CU14_Gestionar_Recetas.oom](DS_CU14_Gestionar_Recetas.oom) |
| 58 | [DS_CU15.01](svg/DS_CU15_01.svg) | Registrar dispensación | [DS_CU15_Dispensar_Medicamentos.oom](DS_CU15_Dispensar_Medicamentos.oom) |
| 59 | [DS_CU16.01](svg/DS_CU16_01.svg) | Consultar disponibilidad de inventario | [DS_CU16_Gestionar_Inventario.oom](DS_CU16_Gestionar_Inventario.oom) |
| 60 | [DS_CU16.02](svg/DS_CU16_02.svg) | Registrar movimientos de inventario | [DS_CU16_Gestionar_Inventario.oom](DS_CU16_Gestionar_Inventario.oom) |
| 61 | [DS_CU16.03](svg/DS_CU16_03.svg) | Controlar lotes y caducidad | [DS_CU16_Gestionar_Inventario.oom](DS_CU16_Gestionar_Inventario.oom) |
| 62 | [DS_CU16.04](svg/DS_CU16_04.svg) | Configurar niveles mínimos de stock | [DS_CU16_Gestionar_Inventario.oom](DS_CU16_Gestionar_Inventario.oom) |
| 63 | [DS_CU16.05](svg/DS_CU16_05.svg) | Consultar alertas de stock | [DS_CU16_Gestionar_Inventario.oom](DS_CU16_Gestionar_Inventario.oom) |
| 64 | [DS_CU17.01](svg/DS_CU17_01.svg) | Administrar camas y estados operativos | [DS_CU17_Gestionar_Camas.oom](DS_CU17_Gestionar_Camas.oom) |
| 65 | [DS_CU17.02](svg/DS_CU17_02.svg) | Consultar ocupación hospitalaria | [DS_CU17_Gestionar_Camas.oom](DS_CU17_Gestionar_Camas.oom) |
| 66 | [DS_CU17.03](svg/DS_CU17_03.svg) | Asignar cama | [DS_CU17_Gestionar_Camas.oom](DS_CU17_Gestionar_Camas.oom) |
| 67 | [DS_CU17.04](svg/DS_CU17_04.svg) | Registrar traslado hospitalario | [DS_CU17_Gestionar_Camas.oom](DS_CU17_Gestionar_Camas.oom) |
| 68 | [DS_CU17.05](svg/DS_CU17_05.svg) | Registrar egreso administrativo | [DS_CU17_Gestionar_Camas.oom](DS_CU17_Gestionar_Camas.oom) |
| 69 | [DS_CU18.01](svg/DS_CU18_01.svg) | Programar cirugía | [DS_CU18_Gestionar_Quirofano.oom](DS_CU18_Gestionar_Quirofano.oom) |
| 70 | [DS_CU18.02](svg/DS_CU18_02.svg) | Registrar lista de verificación preoperatoria | [DS_CU18_Gestionar_Quirofano.oom](DS_CU18_Gestionar_Quirofano.oom) |
| 71 | [DS_CU18.03](svg/DS_CU18_03.svg) | Registrar intervención quirúrgica | [DS_CU18_Gestionar_Quirofano.oom](DS_CU18_Gestionar_Quirofano.oom) |
| 72 | [DS_CU18.04](svg/DS_CU18_04.svg) | Registrar recuperación y cierre | [DS_CU18_Gestionar_Quirofano.oom](DS_CU18_Gestionar_Quirofano.oom) |
| 73 | [DS_CU19.01](svg/DS_CU19_01.svg) | Registrar alta médica autorizada | [DS_CU19_Registrar_Alta.oom](DS_CU19_Registrar_Alta.oom) |
| 74 | [DS_CU20.01](svg/DS_CU20_01.svg) | Registrar cargos por servicios | [DS_CU20_Generar_Facturas.oom](DS_CU20_Generar_Facturas.oom) |
| 75 | [DS_CU20.02](svg/DS_CU20_02.svg) | Emitir documento de facturación | [DS_CU20_Generar_Facturas.oom](DS_CU20_Generar_Facturas.oom) |
| 76 | [DS_CU21.01](svg/DS_CU21_01.svg) | Consultar estado de cuenta | [DS_CU21_Registrar_Pagos.oom](DS_CU21_Registrar_Pagos.oom) |
| 77 | [DS_CU21.02](svg/DS_CU21_02.svg) | Registrar pago | [DS_CU21_Registrar_Pagos.oom](DS_CU21_Registrar_Pagos.oom) |
| 78 | [DS_CU21.03](svg/DS_CU21_03.svg) | Gestionar anulaciones y devoluciones | [DS_CU21_Registrar_Pagos.oom](DS_CU21_Registrar_Pagos.oom) |
| 79 | [DS_CU22.01](svg/DS_CU22_01.svg) | Generar informe de citas | [DS_CU22_Generar_Reportes.oom](DS_CU22_Generar_Reportes.oom) |
| 80 | [DS_CU22.02](svg/DS_CU22_02.svg) | Generar informe de atenciones | [DS_CU22_Generar_Reportes.oom](DS_CU22_Generar_Reportes.oom) |
| 81 | [DS_CU22.03](svg/DS_CU22_03.svg) | Generar informe de ocupación | [DS_CU22_Generar_Reportes.oom](DS_CU22_Generar_Reportes.oom) |
| 82 | [DS_CU22.04](svg/DS_CU22_04.svg) | Generar informe de farmacia | [DS_CU22_Generar_Reportes.oom](DS_CU22_Generar_Reportes.oom) |
| 83 | [DS_CU22.05](svg/DS_CU22_05.svg) | Generar informe financiero | [DS_CU22_Generar_Reportes.oom](DS_CU22_Generar_Reportes.oom) |
| 84 | [DS_CU22.06](svg/DS_CU22_06.svg) | Exportar informe autorizado | [DS_CU22_Generar_Reportes.oom](DS_CU22_Generar_Reportes.oom) |
| 85 | [DS_CU23.01](svg/DS_CU23_01.svg) | Consultar registros de auditoría | [DS_CU23_Consultar_Auditoria.oom](DS_CU23_Consultar_Auditoria.oom) |
| 86 | [DS_TR02](svg/DS_TR02.svg) | Proteger evidencia frente a usuario ordinario | [DS_CU23_Consultar_Auditoria.oom](DS_CU23_Consultar_Auditoria.oom) |
