# Trazabilidad de requisitos funcionales a casos de uso

Alcance base sin portal del paciente ni integraciones externas no aprobadas. Los 23 casos principales se conservan en el general y en cada modelo; los individuales detallan objetivos y responsabilidades.

| Requisito | Diagrama | Función representada | Actores o comportamiento |
|---|---|---|---|
| RF-SEG-001 | CU-01 | Iniciar sesión | Usuario del sistema |
| RF-SEG-004 | CU-01 | Controlar sesión | Usuario del sistema |
| RF-SEG-005 | CU-01 | Recuperar credenciales | Usuario del sistema |
| RF-SEG-005 | CU-01 | Restablecer credenciales mediante procedimiento autorizado | Técnico de soporte informático |
| RF-SEG-001 | CU-01 | Verificar credenciales | Comportamiento interno/transversal |
| RF-AUD-001 | CU-01 | Registrar evento de auditoría | Comportamiento interno/transversal |
| RF-SEG-002 | CU-02 | Administrar cuentas de usuario | Administrador del sistema |
| RF-SEG-003 | CU-02 | Asignar roles y permisos | Administrador del sistema, Responsable de seguridad |
| RF-AUD-002 | CU-02 | Consultar auditoría de cambios | Administrador del sistema, Responsable de seguridad |
| RF-CAT-001 | CU-03 | Gestionar catálogos | Administrador del sistema |
| RF-CAT-002 | CU-03 | Controlar vigencia de catálogos | Administrador del sistema |
| RF-CAT-003 | CU-03 | Registrar cambios de configuración | Comportamiento interno/transversal |
| RF-PAC-001 | CU-04 | Registrar paciente | Personal de admisión |
| RF-PAC-002 | CU-04 | Buscar pacientes | Personal de admisión |
| RF-PAC-003 | CU-04 | Actualizar datos demográficos | Personal de admisión |
| RF-PAC-005 | CU-04 | Gestionar posibles duplicados | Personal de admisión |
| RF-PAC-004 | CU-04 | Consultar historial administrativo | Personal de admisión |
| RF-CIT-001 | CU-05 | Administrar agendas médicas | Personal de admisión |
| RF-CIT-006 | CU-05 | Consultar agenda médica | Personal de admisión, Médico |
| RF-CIT-002 | CU-05 | Programar cita | Personal de admisión |
| RF-CIT-003 | CU-05 | Reprogramar cita | Personal de admisión |
| RF-CIT-004 | CU-05 | Cancelar cita | Personal de admisión |
| RF-CIT-005 | CU-05 | Gestionar asistencia | Personal de admisión |
| RF-HOS-001 | CU-06 | Registrar ingreso del paciente | Personal de admisión |
| RF-PAC-001 | CU-06 | Verificar cobertura | Personal de admisión |
| RF-PAC-004 | CU-06 | Consultar historial administrativo | Personal de admisión, Personal de hospitalización |
| RF-HC-005 | CU-07 | Verificar autorización de acceso | Comportamiento interno/transversal |
| RF-HC-005 | CU-07 | Consultar antecedentes clínicos | Médico, Enfermero |
| RF-LAB-005 | CU-07 | Consultar resultados | Médico, Enfermero |
| RF-HC-005, RF-AUD-002 | CU-07 | Consultar evidencias clínicas autorizadas para auditoría | Auditor |
| RF-HC-001 | CU-08 | Abrir episodio de atención | Médico |
| RF-HC-002 | CU-08 | Registrar consulta médica | Médico |
| RF-HC-003 | CU-08 | Registrar diagnósticos | Médico |
| RF-HC-004 | CU-08 | Registrar evoluciones clínicas | Médico |
| RF-HC-006 | CU-08 | Gestionar alergias | Médico |
| RF-HC-007 | CU-08 | Firmar o finalizar atención | Médico |
| RF-HC-008 | CU-08 | Gestionar documentos clínicos | Médico |
| RF-HOS-005 | CU-09 | Registrar signos vitales | Enfermero |
| RF-HOS-005 | CU-09 | Registrar cuidados y observaciones | Enfermero |
| RF-EME-001 | CU-10 | Registrar ingreso de emergencia | Personal de admisión |
| RF-EME-002 | CU-10 | Registrar clasificación de prioridad | Médico, Enfermero |
| RF-EME-003 | CU-10 | Registrar atención de emergencia | Médico, Enfermero |
| RF-EME-004 | CU-10 | Registrar disposición del paciente | Médico |
| RF-LAB-001 | CU-11 | Consultar catálogo de exámenes | Médico |
| RF-LAB-001 | CU-11 | Crear solicitud de laboratorio | Médico |
| RF-LAB-005 | CU-11 | Consultar resultados | Médico |
| RF-LAB-002 | CU-12 | Gestionar estado de la solicitud | Personal de laboratorio |
| RF-LAB-003 | CU-12 | Registrar resultados | Personal de laboratorio |
| RF-LAB-004 | CU-12 | Validar resultados | Personal de laboratorio |
| RF-LAB-005 | CU-12 | Consultar resultados | Médico, Personal de laboratorio |
| RF-IMG-001 | CU-13 | Solicitar estudio de imagen | Médico |
| RF-IMG-002 | CU-13 | Registrar ejecución del estudio | Profesional de imágenes |
| RF-IMG-003 | CU-13 | Registrar informe radiológico | Profesional de imágenes |
| RF-IMG-004 | CU-13 | Vincular imágenes e informes | Profesional de imágenes |
| RF-FAR-001 | CU-14 | Consultar catálogo de medicamentos | Médico, Farmacéutico |
| RF-HC-002 | CU-14 | Registrar prescripción | Médico |
| RF-FAR-003 | CU-14 | Validar prescripción | Farmacéutico |
| RF-FAR-003 | CU-15 | Validar prescripción | Farmacéutico |
| RF-FAR-002 | CU-15 | Consultar disponibilidad de inventario | Farmacéutico |
| RF-FAR-004 | CU-15 | Registrar dispensación | Farmacéutico |
| RF-FAR-006 | CU-16 | Registrar movimientos de inventario | Farmacéutico |
| RF-FAR-005 | CU-16 | Controlar lotes y caducidad | Farmacéutico |
| RF-FAR-007 | CU-16 | Alertar niveles de stock | Farmacéutico |
| RF-HOS-002 | CU-17 | Administrar camas y estados operativos | Personal de hospitalización |
| RF-HOS-001 | CU-17 | Registrar ingreso hospitalario | Personal de hospitalización, Personal de admisión |
| RF-HOS-003 | CU-17 | Asignar cama | Personal de hospitalización |
| RF-HOS-004 | CU-17 | Registrar traslados | Personal de hospitalización |
| RF-HOS-006 | CU-17 | Gestionar alta hospitalaria | Personal de hospitalización |
| RF-QUI-001 | CU-18 | Programar cirugía | Personal de quirófano, Médico |
| RF-QUI-002 | CU-18 | Registrar lista de verificación preoperatoria | Personal de quirófano, Médico |
| RF-QUI-003 | CU-18 | Registrar intervención quirúrgica | Médico |
| RF-QUI-004 | CU-18 | Registrar recuperación y cierre | Personal de quirófano, Médico |
| RF-HOS-006 | CU-19 | Gestionar alta hospitalaria | Médico |
| RF-HOS-006 | CU-19 | Registrar indicaciones de salida | Médico |
| RF-HOS-006 | CU-19 | Actualizar disponibilidad de cama | Personal de hospitalización |
| RF-FAC-001 | CU-20 | Generar cargos por servicios | Facturador |
| RF-FAC-002 | CU-20 | Calcular importes | Facturador |
| RF-FAC-003 | CU-20 | Emitir documento de facturación | Facturador |
| RF-FAC-006 | CU-21 | Consultar estado de cuenta | Cajero, Facturador |
| RF-FAC-004 | CU-21 | Registrar pagos | Cajero |
| RF-FAC-005 | CU-21 | Gestionar anulaciones y devoluciones | Facturador |
| RF-INF-001 | CU-22 | Generar informe de citas | Analista de estadísticas hospitalarias, Director hospitalario |
| RF-INF-002 | CU-22 | Generar informe de atenciones | Analista de estadísticas hospitalarias, Director hospitalario |
| RF-INF-003 | CU-22 | Generar informe de ocupación | Analista de estadísticas hospitalarias, Director hospitalario |
| RF-INF-004 | CU-22 | Generar informe de farmacia | Analista de estadísticas hospitalarias, Director hospitalario |
| RF-INF-005 | CU-22 | Generar informe financiero | Facturador, Director hospitalario |
| RF-INF-006 | CU-22 | Exportar informe | Analista de estadísticas hospitalarias, Facturador, Director hospitalario, Auditor |
| RF-INF-007 | CU-22 | Registrar generación de informes | Comportamiento interno/transversal |
| RF-INF-001, RF-INF-002, RF-INF-003, RF-INF-004, RF-INF-005 | CU-22 | Seleccionar tipo de informe | Comportamiento interno/transversal |
| RF-INF-001, RF-INF-002, RF-INF-003, RF-INF-004, RF-INF-005 | CU-22 | Aplicar filtros de consulta | Comportamiento interno/transversal |
| RF-AUD-002 | CU-23 | Consultar registros de auditoría | Auditor, Responsable de seguridad, Administrador del sistema |
| RF-AUD-002 | CU-23 | Aplicar filtros de auditoría | Comportamiento interno/transversal |
| RF-AUD-001 | CU-23 | Registrar eventos relevantes | Comportamiento interno/transversal |
| RF-AUD-004 | CU-23 | Registrar accesos denegados | Comportamiento interno/transversal |
| RF-AUD-003 | CU-23 | Proteger registros de auditoría | Comportamiento interno/transversal |

Se conservan las referencias anteriores de descomposición como dependencias «trace» sin representación gráfica; no mantienen la semántica incorrecta de obligatoriedad. Los enlaces visibles «include» se limitan al comportamiento reutilizado. Los perfiles amplios se relacionan con el catálogo detallado en el comentario del diagrama general.

RF-AUD-001/004/003 son comportamientos transversales; no se confieren al auditor permisos para modificar evidencias. El acceso de soporte a restablecimiento no implica administración de cuentas ni acceso clínico.