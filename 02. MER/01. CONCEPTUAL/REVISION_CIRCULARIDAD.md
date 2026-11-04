# Corrección de circularidad en el modelo conceptual

Se corrigió `SIDH_GR02_Conceptual_CORREGIDO.cdm` y se verificó su generación a un modelo lógico mediante PowerDesigner 16.6.1.5066. La comprobación **Circularity with mandatory links** permanece activada y registra **0 mensajes de circularidad**. La revisión posterior de nombres de atributos está documentada en `REVISION_NOMBRES_ATRIBUTOS.md` y deja el conceptual con 0 mensajes totales.

## Causa comprobada

El aviso del lógico enumeraba R037 responsableIngreso, R036 admisiones, R011 citas, R010 reservas, R009 turnos y R006 agendas.

Las referencias a entidades de las relaciones hospitalarias estaban invertidas respecto de sus símbolos de diagrama. En la representación XML que utiliza este archivo, el símbolo de origen debe representar `Object2` y el de destino debe representar `Object1`. Las relaciones R001–R115 incumplían esa correspondencia, excepto la relación reflexiva R021, cuyos dos extremos representan la misma entidad.

Esto hacía que las reglas interpretadas por PowerDesigner no coincidieran con los comentarios del conceptual. Por ejemplo, al abrir el original, R006 exigía que cada PROFESIONAL tuviera exactamente una AGENDA; el requisito expresado en el comentario exige que cada AGENDA pertenezca a exactamente un PROFESIONAL. La generación lógica reproducía un aviso de circularidad con las seis relaciones indicadas.

La corrección intercambia únicamente las referencias de entidad de `Object1` y `Object2` en las 114 relaciones afectadas. Se revisaron las 115 relaciones hospitalarias y se comprobó la correspondencia de sus 144 símbolos. Se conservaron cardinalidades, nombres de rol, comentarios, entidades, atributos, identificadores y disposición de los diagramas. Los 1750 objetos XML con identificador se conservan.

## Reglas de las seis relaciones

La tabla expresa cantidades por instancia de cada entidad, para evitar confundirlas con la posición de las etiquetas en el dibujo.

| Relación | Regla desde la primera entidad | Regla inversa |
| --- | --- | --- |
| R006 agendas | Un PROFESIONAL puede tener 0..n AGENDA. | Cada AGENDA pertenece a 1 PROFESIONAL. |
| R009 turnos | Una AGENDA puede tener 0..n TURNO_AGENDA. | Cada TURNO_AGENDA pertenece a 1 AGENDA. |
| R010 reservas | Un TURNO_AGENDA puede registrar 0..n CITA. | Cada CITA corresponde a 1 TURNO_AGENDA. |
| R011 citas | Un PACIENTE puede tener 0..n CITA. | Cada CITA corresponde a 1 PACIENTE. |
| R036 admisiones | Un PACIENTE puede tener 0..n ADMISION. | Cada ADMISION corresponde a 1 PACIENTE. |
| R037 responsableIngreso | Un PROFESIONAL puede ser responsable de 0..n ADMISION. | Cada ADMISION tiene 1 PROFESIONAL responsable. |

Se mantiene la regla existente de R010: varias citas pueden referirse a un turno a lo largo del tiempo. Los requisitos de programación y cancelación exigen comprobar la disponibilidad y conservar la trazabilidad; la capacidad y la incompatibilidad de reservas simultáneas requieren su propia regla de negocio.

## Validación realizada

1. Se reprodujo el aviso mediante la generación de un lógico temporal desde el conceptual original: 1 mensaje de circularidad.
2. Se comprobó estructuralmente que el cambio afecta exclusivamente a las referencias de los extremos de las relaciones previstas.
3. Se reabrió el conceptual corregido desde su ubicación original y se contrastaron las 115 relaciones con sus comentarios mediante la API nativa de PowerDesigner.
4. Se generó un nuevo lógico temporal desde ese archivo y se ejecutó Check Model, con la comprobación de circularidad activada y las correcciones automáticas desactivadas.
5. Se verificó que las seis relaciones del aviso mantienen en el lógico las entidades y cardinalidades previstas en el conceptual.

| Modelo comprobado | Entidades | Relaciones | Mensajes de circularidad | Otros mensajes |
| --- | ---: | ---: | ---: | --- |
| Conceptual corregido, después de la revisión de nombres | 79 | 125 | 0 | 0. Los 323 mensajes de unicidad se corrigieron en la revisión posterior. |
| Lógico generado en el contraste posterior | 80 | 131 | 0 | 2 de R080 procesaMuestra: existencia de atributos y de identificadores. Reproducidos también desde el respaldo previo al cambio de nombres. |

El lógico de prueba se utilizó en memoria y se cerró tras la comprobación. La entrega consiste en el conceptual corregido; para actualizar un lógico anterior debe regenerarse desde este archivo.

## Archivos y uso

- `SIDH_GR02_Conceptual_CORREGIDO.cdm`: conceptual corregido.
- `SIDH_GR02_Conceptual_ANTES_CIRCULARIDAD.cdm.bak`: respaldo exacto del archivo original.
- `VALIDACION_CIRCULARIDAD.json`: registro de integridad, versión de PowerDesigner, resultados de comprobación y reglas interpretadas por la aplicación.

Abra el conceptual corregido, genere el modelo lógico desde él y ejecute **Tools > Check Model (F4)** en el lógico generado. El respaldo puede restaurarse como archivo `.cdm` si se necesita consultar el estado anterior.

El significado de la comprobación está descrito en la documentación oficial de SAP, [Package Checks (CDM/LDM/PDM)](https://help.sap.com/docs/SAP_POWERDESIGNER/856348b84a7c479489d5172a630f014d/c7ca9fc86e1b10148da98fdfc30324e3.html?locale=en-US&state=PRODUCTION&version=16.7.08). La semántica de obligatoriedad y cardinalidades se documenta en [Relationship Properties](https://help.sap.com/docs/SAP_POWERDESIGNER/856348b84a7c479489d5172a630f014d/c7c3dc1c6e1b1014a4a4db61b5ac0ca3.html).
