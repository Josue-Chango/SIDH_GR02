# Índice de diagramas UML — SIGHO (Sistema Integral de Gestión Hospitalaria)

Diagramas de **casos de uso**, **actividades** y **secuencia** elaborados a partir de
`01. UML/01. ERS/ERS_SIGH_GR02.docx` (ERS del SIGHO, Grupo 02).

Los diagramas conceptuales (`04_CLASES`) y de arquitectura/seguridad
(`05_ARQUITECTURA`) **no** se modificaron.

## Contenido generado

| Carpeta | Contenido | Modelos |
|---|---|---|
| `01_CASOS_USO` | 1 diagrama general + 1 diagrama por caso de uso | 24 |
| `02_ACTIVIDAD` | 1 diagrama de actividad por caso de uso | 23 |
| `03_SECUENCIA` | 1 diagrama de secuencia por caso de uso | 23 |
| **Total** | | **70** |

Cada carpeta incluye su proyecto de PowerDesigner (`.prj` con respaldo `.pjb`).
Los diagramas anteriores se conservaron en la subcarpeta `_RESPALDO` de cada
carpeta (no se borró nada).

## Correspondencia con la ERS

Los 23 casos de uso de la ERS (CU-01 a CU-23) tienen sus tres diagramas.
En los diagramas de casos de uso, cada caso principal se relaciona con casos de
apoyo mediante `<<include>>` o `<<extend>>`, y con los actores que intervienen
según la ERS.

## Detalle por caso de uso

| CU | Caso de uso | Objetivo (ERS) | Actores | Casos relacionados | Archivos |
|---|---|---|---|---|---|
| CU-01 | **Iniciar sesión** | Verificar la identidad del usuario y permitir el acceso según sus permisos. | Usuario del sistema, Administrador del sistema | Verificar credenciales (include), Controlar sesión (include), Registrar evento de auditoría (include) | `CU_01_Iniciar_Sesion.oom` · `DA_CU01_Iniciar_Sesion.oom` · `DS_CU01_Iniciar_Sesion.oom` |
| CU-02 | **Gestionar usuarios, roles y permisos** | Crear, modificar, desactivar usuarios y asignar privilegios. | Administrador del sistema | Administrar cuentas de usuario (include), Asignar roles y permisos (include), Consultar auditoría de cambios (extend) | `CU_02_Gestionar_Usuarios_Roles.oom` · `DA_CU02_Gestionar_Usuarios_Roles.oom` · `DS_CU02_Gestionar_Usuarios_Roles.oom` |
| CU-03 | **Administrar catálogos y parámetros** | Mantener configuraciones y datos maestros del hospital. | Administrador del sistema | Gestionar catálogos (include), Controlar vigencia de catálogos (include), Registrar cambios de configuración (include) | `CU_03_Administrar_Catalogos.oom` · `DA_CU03_Administrar_Catalogos.oom` · `DS_CU03_Administrar_Catalogos.oom` |
| CU-04 | **Registrar y actualizar pacientes** | Crear y mantener los datos de identificación de los pacientes. | Personal de admisión, Paciente | Registrar paciente (include), Buscar pacientes (include), Gestionar posibles duplicados (extend), Consultar historial administrativo (extend) | `CU_04_Registrar_Pacientes.oom` · `DA_CU04_Registrar_Pacientes.oom` · `DS_CU04_Registrar_Pacientes.oom` |
| CU-05 | **Gestionar citas médicas** | Registrar, reprogramar, cancelar y consultar citas. | Personal de admisión, Médico, Paciente | Consultar agenda médica (include), Programar cita (include), Reprogramar cita (extend), Cancelar cita (extend) | `CU_05_Gestionar_Citas.oom` · `DA_CU05_Gestionar_Citas.oom` · `DS_CU05_Gestionar_Citas.oom` |
| CU-06 | **Admitir pacientes** | Registrar el ingreso de un paciente para recibir atención. | Personal de admisión, Personal de hospitalización | Registrar ingreso del paciente (include), Verificar cobertura (include), Consultar historial administrativo (include) | `CU_06_Admitir_Pacientes.oom` · `DA_CU06_Admitir_Pacientes.oom` · `DS_CU06_Admitir_Pacientes.oom` |
| CU-07 | **Consultar historia clínica electrónica** | Consultar antecedentes, consultas, diagnósticos y tratamientos autorizados. | Médico, Enfermero, Auditor | Verificar autorización de acceso (include), Consultar antecedentes clínicos (include), Consultar resultados (include) | `CU_07_Consultar_HCE.oom` · `DA_CU07_Consultar_HCE.oom` · `DS_CU07_Consultar_HCE.oom` |
| CU-08 | **Registrar consulta, diagnóstico y tratamiento** | Documentar la atención médica y las decisiones clínicas. | Médico | Registrar consulta médica (include), Registrar diagnósticos (include), Registrar evoluciones clínicas (extend), Firmar o finalizar atención (include) | `CU_08_Registrar_Consulta.oom` · `DA_CU08_Registrar_Consulta.oom` · `DS_CU08_Registrar_Consulta.oom` |
| CU-09 | **Registrar signos vitales y cuidados** | Registrar observaciones y actividades de enfermería. | Enfermero | Registrar signos vitales (include), Registrar cuidados y observaciones (include), Alertar valores críticos (extend) | `CU_09_Registrar_Signos_Vitales.oom` · `DA_CU09_Registrar_Signos_Vitales.oom` · `DS_CU09_Registrar_Signos_Vitales.oom` |
| CU-10 | **Gestionar urgencias** | Registrar y gestionar la atención de pacientes de emergencia. | Médico, Enfermero, Personal de admisión | Registrar ingreso de emergencia (include), Registrar clasificación de prioridad (include), Registrar atención de emergencia (include), Registrar disposición del paciente (include) | `CU_10_Gestionar_Urgencias.oom` · `DA_CU10_Gestionar_Urgencias.oom` · `DS_CU10_Gestionar_Urgencias.oom` |
| CU-11 | **Solicitar exámenes de laboratorio** | Registrar solicitudes de pruebas clínicas. | Médico | Consultar catálogo de exámenes (include), Crear solicitud de laboratorio (include), Consultar resultados (extend) | `CU_11_Solicitar_Laboratorio.oom` · `DA_CU11_Solicitar_Laboratorio.oom` · `DS_CU11_Solicitar_Laboratorio.oom` |
| CU-12 | **Registrar resultados de laboratorio** | Ingresar, validar y publicar resultados autorizados. | Personal de laboratorio, Médico | Gestionar estado de la solicitud (include), Registrar resultados (include), Validar resultados (include), Consultar resultados (include) | `CU_12_Registrar_Resultados_Lab.oom` · `DA_CU12_Registrar_Resultados_Lab.oom` · `DS_CU12_Registrar_Resultados_Lab.oom` |
| CU-13 | **Gestionar estudios de imagenología** | Gestionar solicitudes, estudios e informes de imágenes médicas. | Profesional de imágenes, Médico | Solicitar estudio de imagen (include), Registrar ejecución del estudio (include), Registrar informe radiológico (include), Vincular imágenes e informes (extend) | `CU_13_Gestionar_Imagenologia.oom` · `DA_CU13_Gestionar_Imagenologia.oom` · `DS_CU13_Gestionar_Imagenologia.oom` |
| CU-14 | **Gestionar recetas médicas** | Registrar las prescripciones emitidas por profesionales autorizados. | Médico, Farmacéutico | Consultar catálogo de medicamentos (include), Registrar prescripción (include), Validar prescripción (extend) | `CU_14_Gestionar_Recetas.oom` · `DA_CU14_Gestionar_Recetas.oom` · `DS_CU14_Gestionar_Recetas.oom` |
| CU-15 | **Dispensar medicamentos** | Registrar la entrega de medicamentos al paciente. | Farmacéutico | Validar prescripción (include), Consultar disponibilidad de inventario (include), Registrar dispensación (include) | `CU_15_Dispensar_Medicamentos.oom` · `DA_CU15_Dispensar_Medicamentos.oom` · `DS_CU15_Dispensar_Medicamentos.oom` |
| CU-16 | **Gestionar inventario de farmacia** | Controlar existencias, lotes, vencimientos y movimientos. | Farmacéutico | Registrar movimientos de inventario (include), Controlar lotes y caducidad (include), Alertar niveles de stock (extend) | `CU_16_Gestionar_Inventario.oom` · `DA_CU16_Gestionar_Inventario.oom` · `DS_CU16_Gestionar_Inventario.oom` |
| CU-17 | **Gestionar camas y hospitalización** | Asignar camas y gestionar la ocupación hospitalaria. | Personal de hospitalización | Registrar ingreso hospitalario (include), Asignar cama (include), Registrar traslados (extend), Gestionar alta hospitalaria (extend) | `CU_17_Gestionar_Camas.oom` · `DA_CU17_Gestionar_Camas.oom` · `DS_CU17_Gestionar_Camas.oom` |
| CU-18 | **Gestionar procedimientos quirúrgicos** | Programar y documentar procedimientos quirúrgicos. | Personal de quirófano, Médico | Programar cirugía (include), Registrar lista de verificación preoperatoria (include), Registrar intervención quirúrgica (include), Registrar recuperación y cierre (extend) | `CU_18_Gestionar_Quirofano.oom` · `DA_CU18_Gestionar_Quirofano.oom` · `DS_CU18_Gestionar_Quirofano.oom` |
| CU-19 | **Registrar alta médica** | Registrar el alta y las indicaciones de salida del paciente. | Médico, Personal de hospitalización | Gestionar alta hospitalaria (include), Registrar indicaciones de salida (include), Actualizar disponibilidad de cama (include) | `CU_19_Registrar_Alta.oom` · `DA_CU19_Registrar_Alta.oom` · `DS_CU19_Registrar_Alta.oom` |
| CU-20 | **Generar facturas** | Calcular y emitir los cargos por servicios prestados. | Personal de facturación | Generar cargos por servicios (include), Calcular importes (include), Emitir documento de facturación (include) | `CU_20_Generar_Facturas.oom` · `DA_CU20_Generar_Facturas.oom` · `DS_CU20_Generar_Facturas.oom` |
| CU-21 | **Registrar pagos y consultar saldos** | Registrar pagos y consultar valores pendientes. | Personal de facturación, Paciente | Consultar estado de cuenta (include), Registrar pagos (include), Gestionar anulaciones y devoluciones (extend) | `CU_21_Registrar_Pagos.oom` · `DA_CU21_Registrar_Pagos.oom` · `DS_CU21_Registrar_Pagos.oom` |
| CU-22 | **Generar reportes e indicadores** | Producir información operativa y gerencial autorizada. | Director hospitalario, Personal de facturación, Auditor | Seleccionar tipo de informe (include), Aplicar filtros de consulta (include), Registrar generación de informes (include), Exportar informe (extend) | `CU_22_Generar_Reportes.oom` · `DA_CU22_Generar_Reportes.oom` · `DS_CU22_Generar_Reportes.oom` |
| CU-23 | **Consultar auditoría y trazabilidad** | Consultar registros de acceso y cambios relevantes. | Auditor, Administrador del sistema | Aplicar filtros de auditoría (include), Consultar registros de auditoría (include), Proteger registros de auditoría (include) | `CU_23_Consultar_Auditoria.oom` · `DA_CU23_Consultar_Auditoria.oom` · `DS_CU23_Consultar_Auditoria.oom` |

## Convenciones de los diagramas

**Casos de uso**
- Un actor por cada actor de la ERS que participa en el caso.
- El caso principal (elipse central) se conecta con casos de apoyo mediante
  dependencias `<<include>>` (el principal requiere al apoyo) o `<<extend>>`
  (el apoyo amplía al principal).
- `CU_SIGHO_General.oom` muestra los 23 casos dentro del límite del sistema y
  los 13 actores de la ERS más el actor genérico *Usuario del sistema*.

**Actividades**
- Flujo: inicio → pasos → decisión → rama **SI** (conclusión satisfactoria) y
  rama **NO** (manejo del error o rechazo) → dos nodos de fin.

**Secuencia**
- Intervienen el actor principal, una vista (`Vista*`), un controlador
  (`Controlador*`) y un repositorio (`Repositorio*`).
- Las llamadas se dibujan con control `C` y los retornos con control `R`.

## Cómo abrirlos

1. Abrir PowerDesigner 16.
2. `File > Open Project` y elegir `01 CASOS DE USO.prj`, `02_ACTIVIDAD.prj` o
   `03_SECUENCIA.prj` según el tipo de diagrama.
3. También se puede abrir cada `.oom` de forma individual.
