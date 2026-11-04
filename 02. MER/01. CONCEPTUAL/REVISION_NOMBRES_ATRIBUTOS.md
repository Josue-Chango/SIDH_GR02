# Corrección de los 323 avisos de nombres de atributos

Se corrigió `SIDH_GR02_Conceptual_CORREGIDO.cdm`. **PowerDesigner 16.6.1.5066 valida el conceptual guardado con 0 mensajes**, con la comprobación de unicidad de nombres activada.

## Causa y corrección

Los 323 mensajes suministrados coinciden exactamente con 38 grupos de nombres repetidos entre entidades. Cada atributo utilizaba un elemento de datos independiente y un código técnico único, pero compartía nombres como `estado`, `registradoEl`, `cantidad` o `descripcion`.

Se contextualizaron los 323 nombres afectados con el nombre de su entidad, utilizando camelCase. Los otros 258 nombres se conservaron.

| Atributo original | Nombre corregido |
| --- | --- |
| ADMISION.estado | estadoAdmision |
| CITA.estado | estadoCita |
| ADMISION.registradoEl | registradoElAdmision |
| PACIENTE.tipoDocumento | tipoDocumentoPaciente |
| CARGO_SERVICIO.cantidad | cantidadCargoServicio |
| PERSONA.Apellidos | apellidosPersona |

Los 581 atributos conservan sus códigos técnicos y tipos de datos originales. También se conservaron los identificadores, la obligatoriedad de los atributos, las referencias entre objetos, las relaciones y sus cardinalidades. La comparación estructural comprende los 1459 objetos de definición del modelo; al normalizar las longitudes y precisiones implícitas en el tipo de datos, el cambio semántico se limita a los nombres previstos.

El guardado mediante PowerDesigner reorganiza el XML y explicita algunas longitudes y precisiones ya contenidas en los tipos de datos. Por ello, el cambio textual del archivo es mayor que la lista de nombres modificados.

## Resultados de validación

| Comprobación | Antes | Después |
| --- | ---: | ---: |
| Mensajes de unicidad de nombres en el conceptual | 323 | 0 |
| Total de mensajes en el conceptual | 323 | 0 |
| Nombres distintos de atributos | 296 | 581 |
| Atributos conservados | 581 | 581 |
| Entidades del conceptual | 79 | 79 |
| Relaciones del conceptual | 125 | 125 |

Se verificó el conceptual después de guardarlo y abrirlo mediante la API nativa de PowerDesigner. La comprobación `Entity.Entity Attribute / UniqueName` permanece activada. Las correcciones automáticas permanecen desactivadas.

## Avisos independientes en la generación lógica

La generación lógica de contraste detectó estos dos mensajes en la entidad asociativa que PowerDesigner crea automáticamente para la relación muchos a muchos R080 procesaMuestra:

- `Existence of attributes`: Entity 'R080 procesaMuestra'.
- `Existence of identifiers`: Entity 'R080 procesaMuestra'.

Se reprodujeron los mismos dos mensajes generando el lógico desde una copia del respaldo anterior al cambio de nombres. Por tanto, esta revisión elimina los 323 avisos solicitados y conserva ese comportamiento de generación previo. El lógico de contraste tiene 80 entidades y 131 relaciones, con 0 mensajes de circularidad. Los dos avisos de R080 corresponden a una revisión adicional de su transformación a entidad asociativa en el lógico.

## Archivos

- `SIDH_GR02_Conceptual_CORREGIDO.cdm`: conceptual actualizado.
- `SIDH_GR02_Conceptual_ANTES_NOMBRES.cdm.bak`: respaldo exacto anterior a esta corrección; incluye la corrección de circularidad realizada previamente.
- `VALIDACION_NOMBRES_ATRIBUTOS.json`: correspondencia completa de los 323 nombres anteriores y nuevos, códigos conservados, comprobaciones activas y resultados de integridad y validación.

Abra el conceptual actualizado y ejecute **Tools > Check Model (F4)**. Los modelos lógicos existentes deben regenerarse desde el conceptual para incorporar los nuevos nombres.

La comprobación y la corrección de nombres duplicados se describen en la documentación oficial de SAP, [Entity Attribute Checks (CDM/LDM)](https://help.sap.com/docs/SAP_POWERDESIGNER/856348b84a7c479489d5172a630f014d/c7ca493a6e1b10148673c7bab0dd76cd.html).
