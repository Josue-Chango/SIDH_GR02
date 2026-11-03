"""Especificación revisada de los flujos UML, ligada al ERS y a CU-01..23."""
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
MODELS=[]

class Graph:
 def __init__(self,cu,suffix,title,actors,rf,pre,post,change,auth=True):
  self.cu=cu; self.suffix=suffix; self.title=title
  self.lanes=actors+['Sistema SIGH']; self.sys=len(actors)
  self.rf=rf.split(); self.pre=pre; self.post=post; self.change=change
  self.nodes=[]; self.edges=[]
  self.n('inicio','start','',0)
  if auth:
   self.a('pedir','Seleccionar la operación y su contexto',0)
   self.a('autorizar','Verificar sesión, rol y permiso en el servidor')
   self.q('permiso','¿Operación autorizada?')
   self.a('denegado','Denegar la operación y registrar el intento sin secretos')
   self.n('fin_denegado','end','',self.sys)
   self.path('inicio pedir autorizar permiso')
   self.e('permiso','denegado','no'); self.e('denegado','fin_denegado')
   self.entry='permiso'
  else:self.entry='inicio'
  MODELS.append(self)
 def n(self,id,kind,label,lane=None):
  if id=='fin' and any(n['id']==id for n in self.nodes):return id
  assert id not in [n['id'] for n in self.nodes],id
  self.nodes.append(dict(id=id,kind=kind,label=label,lane=self.sys if lane is None else lane));return id
 def a(self,id,label,lane=None):return self.n(id,'action',label,lane)
 def q(self,id,label,lane=None):return self.n(id,'decision',label,lane)
 def e(self,a,b,guard=''):self.edges.append(dict(source=a,target=b,guard=guard))
 def path(self,seq):
  seq=seq.split()
  for a,b in zip(seq,seq[1:]):self.e(a,b)
 def begin(self,id):self.e(self.entry,id,'sí' if self.entry=='permiso' else '')
 def finish(self,last):
  if not any(n['id']=='fin' for n in self.nodes):self.n('fin','end','',self.sys)
  self.e(last,'fin')
 def done(self,src,text='Registrar auditoría con usuario, fecha, objeto y resultado'):
  self.a('audit_final',text);self.a('confirmar_final','Mostrar el resultado de la operación')
  self.e(src,'audit_final');self.e('audit_final','confirmar_final');self.finish('confirmar_final')

g=Graph(1,'','Iniciar sesión',['Usuario del sistema'],'RF-SEG-001 RF-AUD-001 RF-AUD-004',
 'Usuario con cuenta institucional; no se exige sesión previa.',
 'Sesión segura autorizada o autenticación rechazada y registrada.',
 'Se comprueban credenciales y estado de cuenta; se auditan éxito y rechazo.',False)
g.a('cred','Ingresar usuario y credencial',0)
g.a('ver','Validar formato, credenciales y cuenta activa no bloqueada')
g.q('ok','¿Autenticación válida?');g.a('error','Registrar intento fallido y mostrar error genérico')
g.q('reintento','¿Reintentar?',0);g.a('sesion','Crear sesión segura y cargar permisos vigentes')
g.a('audit','Registrar autenticación exitosa');g.a('panel','Mostrar funciones permitidas')
g.path('inicio cred ver ok');g.e('ok','error','no');g.path('error reintento')
g.e('reintento','cred','sí');g.n('fin_cancelado','end','',0);g.e('reintento','fin_cancelado','no')
g.e('ok','sesion','sí');g.path('sesion audit panel');g.finish('panel')

g=Graph(1,'a','Recuperar o restablecer credenciales',['Usuario del sistema','Personal autorizado de soporte'],
 'RF-SEG-005 RF-AUD-001','Solicitud de recuperación sin sesión previa; personal de soporte autorizado.',
 'Credencial restablecida con trazabilidad o solicitud rechazada.',
 'Se modela recuperación por procedimiento aprobado sin revelar contraseñas.',False)
g.a('sol','Solicitar recuperación o restablecimiento',0)
g.a('ident','Verificar identidad mediante el mecanismo aprobado',1)
g.q('idok','¿Identidad verificada?',1);g.a('rech','Registrar rechazo y mostrar respuesta genérica')
g.a('rest','Ejecutar el procedimiento controlado de restablecimiento',1)
g.a('audit','Guardar credencial protegida y registrar el evento')
g.a('info','Informar resultado sin revelar la contraseña existente')
g.path('inicio sol ident idok');g.e('idok','rest','sí');g.e('idok','rech','no')
g.path('rest audit info');g.finish('info');g.finish('rech')

g=Graph(1,'b','Cerrar o expirar una sesión',['Usuario del sistema'],
 'RF-SEG-004 RF-AUD-001','Existe una sesión iniciada.',
 'Sesión invalidada; una nueva operación protegida exige autenticación.',
 'Se añaden cierre explícito, inactividad y vencimiento según política.',False)
g.a('esperar','Esperar cierre solicitado o vencimiento de sesión')
g.q('causa','¿Evento de cierre?');g.a('cerrar','Solicitar cierre de sesión',0)
g.a('expirar','Detectar expiración o inactividad máxima configurada')
g.a('invalidar','Invalidar la sesión en el servidor')
g.a('audit','Registrar el cierre o expiración según política')
g.a('login','Exigir nueva autenticación para funciones protegidas')
g.path('inicio esperar causa');g.e('causa','cerrar','cierre solicitado')
g.e('causa','expirar','expiración o inactividad');g.e('cerrar','invalidar');g.e('expirar','invalidar')
g.path('invalidar audit login');g.finish('login')

g=Graph(2,'','Administrar cuentas de usuario',['Administrador del sistema'],
 'RF-SEG-002 RF-AUD-001','Administrador con permisos de gestión de cuentas.',
 'Cuenta consultada, creada, actualizada, activada o desactivada; historial conservado.',
 'Se separan las operaciones y se evita eliminar cuentas con operaciones históricas.')
g.a('listar','Consultar cuentas y seleccionar operación',0);g.q('op','¿Tipo de operación?',0)
g.a('ver','Mostrar los datos autorizados de la cuenta');g.a('capt','Capturar alta o cambios de cuenta',0)
g.a('estado','Seleccionar activar o desactivar la cuenta',0)
g.a('validar','Validar identificador único, campos y estado solicitado')
g.q('ok','¿Datos y transición válidos?');g.a('err','Mostrar errores de validación')
g.a('hist','Guardar alta, cambios o estado de cuenta; conservar identidad e historial y usar desactivación lógica')
g.begin('listar');g.path('listar op');g.e('op','ver','consultar');g.finish('ver')
g.e('op','capt','crear o actualizar');g.e('op','estado','activar o desactivar')
g.e('capt','validar');g.e('estado','validar');g.path('validar ok')
g.e('ok','err','no');g.e('err','listar');g.e('ok','hist','sí');g.done('hist')

g=Graph(2,'a','Gestionar permisos y políticas de sesión',['Administrador / Responsable de seguridad'],
 'RF-SEG-003 RF-SEG-004 RF-AUD-001 RF-AUD-002',
 'Permiso específico para la operación de seguridad elegida.',
 'Roles, permisos o política actualizados; o auditoría consultada.',
 'Se incorporan consulta de roles, políticas de sesión y auditoría de cambios.')
g.a('op','Seleccionar roles, permisos, políticas de sesión o auditoría',0)
g.q('tipo','¿Operación de consulta?',0);g.a('consultar','Consultar roles y permisos o auditoría de cambios autorizados')
g.a('editar','Definir asignaciones o política de sesión aprobada',0)
g.a('validar','Validar alcance del permiso y valores de la política');g.q('ok','¿Configuración válida?')
g.a('err','Mostrar errores y solicitar corrección');g.a('aplicar','Aplicar permisos en solicitudes siguientes y sesiones según política')
g.begin('op');g.path('op tipo');g.e('tipo','consultar','sí');g.finish('consultar')
g.e('tipo','editar','no');g.path('editar validar ok');g.e('ok','err','no');g.e('err','editar')
g.e('ok','aplicar','sí');g.done('aplicar','Guardar valores anteriores y nuevos, responsable y auditoría')

g=Graph(3,'','Administrar catálogos institucionales',['Administrador del sistema'],
 'RF-CAT-001 RF-CAT-002 RF-CAT-003','Usuario con permisos sobre el catálogo seleccionado.',
 'Elemento consultado o mantenido con vigencia e historial.',
 'Se distinguen consulta y mantenimiento; la desactivación conserva referencias históricas.')
g.a('select','Seleccionar catálogo, elemento y operación',0);g.q('consulta','¿Solo consultar?',0)
g.a('ver','Mostrar catálogo y vigencias');g.a('editar','Registrar, modificar o desactivar el elemento y su vigencia',0)
g.a('validar','Validar unicidad, campos, fechas y referencias históricas')
g.q('ok','¿Elemento válido?');g.a('err','Mostrar errores sin guardar cambios')
g.begin('select');g.path('select consulta');g.e('consulta','ver','sí');g.finish('ver')
g.e('consulta','editar','no');g.path('editar validar ok');g.e('ok','err','no');g.e('err','editar')
g.e('ok','guardar','sí');g.a('guardar','Guardar vigencia y conservar referencias históricas')
g.a('audit','Registrar cambio, responsable, fecha y valores anteriores y nuevos')
g.path('guardar audit');g.finish('audit')

g=Graph(4,'','Registrar y actualizar pacientes',['Recepcionista / Responsable de admisión'],
 'RF-PAC-001 RF-PAC-002 RF-PAC-003 RF-PAC-004 RF-PAC-005',
 'Personal autorizado; catálogo de campos y validaciones aprobado.',
 'Paciente identificado o actualizado sin duplicación automática; historial consultable.',
 'El identificador se genera solo para pacientes nuevos y las coincidencias exigen revisión.')
g.a('buscar','Buscar por identificador, documento o nombres',0);g.a('matches','Mostrar coincidencias con datos mínimos')
g.q('existe','¿Paciente existente seleccionado?',0);g.a('consulta','Consultar datos e historial administrativo autorizado')
g.q('actualizar','¿Actualizar datos?',0);g.a('capt','Capturar datos nuevos o cambios demográficos',0)
g.a('validar','Validar campos, formatos, fechas e identificadores sensibles');g.q('ok','¿Datos válidos?')
g.a('err','Mostrar errores para su corrección');g.a('dup','Buscar posibles duplicados del registro')
g.q('coinc','¿Existen posibles duplicados?');g.a('rev','Solicitar revisión fundamentada de coincidencias mediante DA CU04a')
g.q('nuevo','¿Alta nueva autorizada tras revisión?');g.a('id','Generar identificador hospitalario único')
g.a('save','Guardar alta o actualización, conservar identificador existente y auditar')
g.begin('buscar');g.path('buscar matches existe');g.e('existe','consulta','sí');g.path('consulta actualizar')
g.e('actualizar','capt','sí');g.e('actualizar','fin','no');g.n('fin','end','',g.sys)
g.e('existe','capt','no');g.path('capt validar ok');g.e('ok','err','no');g.e('err','capt')
g.e('ok','dup','sí');g.path('dup coinc');g.e('coinc','rev','sí');g.path('rev nuevo')
g.e('nuevo','buscar','no');g.e('nuevo','id','sí');g.q('alta','¿Es un registro nuevo?')
g.e('coinc','alta','no');g.e('alta','id','sí');g.e('alta','save','no');g.e('id','save');g.finish('save')

g=Graph(4,'a','Resolver posibles duplicados',['Personal expresamente autorizado'],
 'RF-PAC-005 RN-001 RN-002','Coincidencia detectada y permiso específico para resolver duplicados.',
 'Decisión fundamentada registrada; fusión autorizada conserva las referencias históricas.',
 'Se elimina cualquier fusión automática por similitud de nombres.')
g.a('revisar','Revisar identidad, evidencias y registros potencialmente duplicados',0)
g.q('decision','¿Decisión autorizada?',0)
g.a('fusion','Consolidar conforme al procedimiento aprobado; mantener identificadores vinculados e historial')
g.a('distintos','Conservar registros separados y justificar la decisión')
g.a('pendiente','Conservar caso pendiente de revisión sin fusionar')
g.a('registrar','Registrar evidencia, decisión, responsable y fecha; conservar atenciones y documentos')
g.begin('revisar');g.path('revisar decision');g.e('decision','fusion','fusionar')
g.e('decision','distintos','personas distintas');g.e('decision','pendiente','evidencia insuficiente')
for x in ['fusion','distintos','pendiente']:g.e(x,'registrar')
g.finish('registrar')

g=Graph(5,'','Programar o reprogramar citas',['Recepcionista'],
 'RF-CIT-002 RF-CIT-003 RF-CIT-006 RN-003','Paciente registrado; agenda configurada; permiso de programación.',
 'Cita confirmada o reprogramada con reserva exclusiva; el turno anterior se libera al confirmar el nuevo.',
 'Se validan concurrencia y disponibilidad antes de confirmar, sin perder la cita anterior ante un conflicto.')
g.a('datos','Seleccionar paciente, profesional, especialidad y operación',0)
g.a('agenda','Consultar agenda y disponibilidad del periodo');g.a('turno','Elegir turno, motivo y cita anterior si se reprograma',0)
g.a('validar','Validar datos, estado de cita y disponibilidad del nuevo turno')
g.q('ok','¿Reserva válida y exclusiva?');g.a('error','Informar conflicto y conservar la cita anterior')
g.q('seguir','¿Elegir otro turno?',0);g.a('reservar','Confirmar reserva en transacción; liberar turno anterior solo si se reprograma')
g.a('audit','Asignar o conservar identificador de cita; registrar estado e historial del cambio')
g.begin('datos');g.path('datos agenda turno validar ok');g.e('ok','error','no');g.path('error seguir')
g.e('seguir','agenda','sí');g.e('seguir','fin','no');g.n('fin','end','',g.sys)
g.e('ok','reservar','sí');g.path('reservar audit');g.finish('audit')

g=Graph(5,'a','Gestionar agendas y estados de cita',['Recepcionista / Médico según permiso'],
 'RF-CIT-001 RF-CIT-004 RF-CIT-005 RF-CIT-006',
 'Agenda o cita existente; médicos consultan según rol y recepcionistas operan según permiso.',
 'Agenda consultada o configurada; cancelación o asistencia registrada con historial.',
 'Consulta, configuración, cancelación y asistencia son alternativas independientes.')
g.a('op','Seleccionar consulta, configuración, cancelación o asistencia',0);g.q('tipo','¿Operación seleccionada?',0)
g.a('ver','Mostrar agenda diaria autorizada y datos mínimos')
g.a('config','Definir profesional, servicio, jornada, duración y capacidad',0)
g.a('cancel','Seleccionar cita y registrar motivo de cancelación',0)
g.a('asist','Registrar estado de asistencia permitido',0)
g.a('validar','Validar permiso específico, campos y transición según el flujo aprobado')
g.q('ok','¿Cambio permitido?');g.a('err','Mostrar motivo de rechazo')
g.a('aplicar','Guardar agenda o estado; liberar turno al cancelar cuando corresponda; conservar historial')
g.begin('op');g.path('op tipo');g.e('tipo','ver','consultar');g.finish('ver')
for x,guard in [('config','configurar agenda'),('cancel','cancelar cita'),('asist','registrar asistencia')]:g.e('tipo',x,guard);g.e(x,'validar')
g.path('validar ok');g.e('ok','err','no');g.e('err','op');g.e('ok','aplicar','sí');g.done('aplicar')

g=Graph(6,'','Admitir pacientes y consultar ingresos',['Responsable de admisión / Gestor de camas'],
 'RF-HOS-001 RF-PAC-002 RF-PAC-004','Paciente registrado; indicación de ingreso y responsable cuando se admite.',
 'Admisión asociada al paciente y episodio, o historial de ingresos y egresos consultado.',
 'La cobertura es un dato administrativo; su validación externa no se presupone.')
g.a('buscar','Buscar y seleccionar paciente',0);g.a('datos','Consultar datos administrativos, cobertura registrada e historial autorizado')
g.q('ingreso','¿Registrar nueva admisión?',0);g.a('capt','Registrar indicación, motivo, profesional responsable y datos del ingreso',0)
g.a('validar','Comprobar paciente, campos obligatorios e indicación');g.q('ok','¿Admisión completa?')
g.a('err','Solicitar completar o corregir datos');g.a('crear','Crear admisión y asociar o abrir episodio único del paciente')
g.begin('buscar');g.path('buscar datos ingreso');g.e('ingreso','capt','sí');g.e('ingreso','fin','no');g.n('fin','end','',g.sys)
g.path('capt validar ok');g.e('ok','err','no');g.e('err','capt');g.e('ok','crear','sí');g.done('crear')

g=Graph(7,'','Consultar historia clínica electrónica',['Médico / Enfermero / Auditor según rol'],
 'RF-HC-005 RF-LAB-005 RF-AUD-001 RF-AUD-004 RN-015 RN-017',
 'Sesión válida; acceso limitado por rol, relación asistencial o finalidad de auditoría autorizada.',
 'Información clínica permitida presentada y acceso trazado, o consulta denegada.',
 'La autorización precede a la lectura; el auditor accede solo a evidencias permitidas.')
g.a('buscar','Solicitar paciente y finalidad de consulta',0)
g.a('alcance','Verificar rol, relación asistencial o autorización de auditoría y datos permitidos')
g.q('ok','¿Acceso clínico autorizado?');g.a('no','Denegar y registrar el intento sin revelar datos clínicos')
g.a('leer','Recuperar antecedentes, diagnósticos, alergias, atenciones y resultados autorizados')
g.a('mostrar','Mostrar datos mínimos y distinguir resultados pendientes de definitivos')
g.a('audit','Registrar usuario, finalidad, paciente, fecha y resultado del acceso')
g.begin('buscar');g.path('buscar alcance ok');g.e('ok','no','no');g.finish('no');g.e('ok','leer','sí')
g.path('leer mostrar audit');g.finish('audit')

g=Graph(8,'','Registrar consulta y finalizar nota clínica',['Médico'],
 'RF-HC-001 RF-HC-002 RF-HC-003 RF-HC-006 RF-HC-007 RN-006 RN-007 RN-022',
 'Paciente identificado o temporal de emergencia; cita, admisión o emergencia vinculable.',
 'Nota en borrador o finalizada con autoría; el episodio conserva su estado asistencial.',
 'Se separan borrador y finalización; finalizar una nota no cierra automáticamente todo el episodio.')
g.a('episodio','Seleccionar o abrir episodio asociado al paciente y origen asistencial',0)
g.a('clinica','Registrar motivo, problema actual, antecedentes, hallazgos y evaluación',0)
g.a('alergias','Registrar diagnósticos, alergias, fuente y estado de verificación',0)
g.a('plan','Registrar tratamiento, órdenes o prescripciones cuando proceda y seguimiento',0)
g.q('finalizar','¿Finalizar la nota?',0);g.a('borrador','Guardar como borrador identificado; permitir completarlo posteriormente')
g.a('validar','Validar contenido obligatorio y competencia del profesional')
g.q('ok','¿Nota completa y autorizada?');g.a('err','Mostrar campos o permisos pendientes')
g.a('firmar','Confirmar finalización con el mecanismo aprobado',0)
g.a('final','Conservar nota finalizada, autor y fecha; rectificar solo con trazabilidad')
g.begin('episodio');g.path('episodio clinica alergias plan finalizar')
g.e('finalizar','borrador','no');g.finish('borrador');g.e('finalizar','validar','sí')
g.path('validar ok');g.e('ok','err','no');g.e('err','clinica');g.e('ok','firmar','sí');g.path('firmar final');g.done('final')

g=Graph(8,'a','Registrar evoluciones y documentos clínicos',['Médico'],
 'RF-HC-004 RF-HC-008 RN-007','Episodio existente y autorización sobre sus documentos.',
 'Evolución, adenda o documento asociado con autoría, controles de archivo y auditoría.',
 'Se añaden evoluciones, rectificación trazada y documentos; el original finalizado se conserva.')
g.a('op','Seleccionar episodio y evolución, rectificación o documento',0);g.q('tipo','¿Operación elegida?',0)
g.a('nota','Registrar evolución o adenda vinculada al original; conservar autor, fecha y contenido',0)
g.a('archivo','Seleccionar documento y datos de asociación al episodio',0)
g.a('val','Validar competencia, acceso y, para archivos, tipo y tamaño permitidos')
g.q('ok','¿Registro válido?');g.a('err','Mostrar errores para su corrección')
g.begin('op');g.path('op tipo');g.e('tipo','nota','evolución o rectificación');g.e('tipo','archivo','adjuntar o vincular documento')
g.e('nota','val');g.e('archivo','val');g.path('val ok');g.e('ok','err','no');g.e('err','op')
g.e('ok','guardar','sí');g.a('guardar','Guardar con trazabilidad sin sobrescribir documentos clínicos finalizados');g.finish('guardar')

g=Graph(9,'','Registrar signos vitales y cuidados',['Enfermero'],
 'RF-HOS-005 RN-005 RN-022','Paciente y episodio identificados; profesional de enfermería autorizado.',
 'Observaciones, signos medidos y cuidados guardados con responsable y fecha.',
 'Los datos no medidos o desconocidos se distinguen de negativos; los errores regresan a captura.')
g.a('pac','Confirmar paciente y episodio activo',0)
g.a('datos','Registrar signos medidos, observaciones y cuidados realizados',0)
g.a('validar','Validar campos, unidades y fecha; distinguir no medido, desconocido y negativo')
g.q('ok','¿Registro válido?');g.a('err','Mostrar errores de registro')
g.begin('pac');g.path('pac datos validar ok');g.e('ok','err','no');g.e('err','datos')
g.e('ok','guardar','sí');g.a('guardar','Guardar con autor, fecha, paciente, episodio y auditoría');g.finish('guardar')

g=Graph(10,'','Registrar atención de urgencias',['Admisión / Recepcionista','Médico / Enfermero según competencia'],
 'RF-EME-001 RF-EME-002 RF-EME-003 RF-EME-004 RN-005',
 'Personal autorizado para su intervención; la falta de datos administrativos admite identidad temporal.',
 'Atención documentada con disposición indicada por el profesional, o atención aún abierta.',
 'La identidad se concilia después; no se exige estabilización como condición inventada de cierre.')
g.a('ingreso','Registrar ingreso con datos disponibles',0);g.q('ident','¿Identidad suficiente?',0)
g.a('temp','Generar identificador temporal controlado y dejar conciliación pendiente')
g.a('episode','Crear o asociar episodio de emergencia al identificador del paciente')
g.a('prioridad','Registrar prioridad según protocolo aprobado por el hospital',1)
g.a('atender','Registrar valoración, signos vitales, intervenciones, órdenes y observaciones',1)
g.q('disp','¿Existe disposición clínica definida?',1)
g.a('continuar','Guardar evolución y mantener la atención abierta')
g.a('destino','Registrar alta, hospitalización, traslado o derivación según decisión clínica',1)
g.a('validar','Comprobar datos obligatorios para el cierre y vínculos del destino')
g.q('ok','¿Cierre documentado?');g.a('err','Indicar información clínica pendiente')
g.a('cerrar','Cerrar atención de emergencia y conservar pendiente de identidad si corresponde')
g.begin('ingreso');g.path('ingreso ident');g.e('ident','temp','no');g.e('ident','episode','sí');g.e('temp','episode')
g.path('episode prioridad atender disp');g.e('disp','continuar','no');g.finish('continuar')
g.e('disp','destino','sí');g.path('destino validar ok');g.e('ok','err','no');g.e('err','atender')
g.e('ok','cerrar','sí');g.done('cerrar')

g=Graph(10,'a','Conciliar identidad temporal de emergencia',['Personal autorizado de admisión'],
 'RF-EME-001 RF-PAC-005 RN-001 RN-002 RN-005',
 'Registro temporal existente y procedimiento de conciliación aprobado.',
 'Identidad conciliada con historia preservada o pendiente justificada.',
 'La conciliación es un proceso posterior independiente de la atención urgente.')
g.a('sel','Seleccionar registro temporal y recopilar datos de identificación',0)
g.a('buscar','Buscar coincidencias de paciente y preservar atenciones del temporal')
g.a('rev','Revisar evidencias de identidad y posibles duplicados',0)
g.q('ok','¿Conciliación autorizada y fundamentada?',0)
g.a('pend','Registrar motivo pendiente y conservar el identificador temporal')
g.a('vinc','Vincular identidad confirmada sin perder episodios, órdenes ni resultados')
g.begin('sel');g.path('sel buscar rev ok');g.e('ok','pend','no');g.finish('pend');g.e('ok','vinc','sí');g.done('vinc')

g=Graph(11,'','Solicitar laboratorio o consultar resultados',['Médico'],
 'RF-LAB-001 RF-LAB-005','Paciente y episodio identificados; médico autorizado.',
 'Solicitud creada en estado solicitada o resultados autorizados consultados.',
 'Se añade consulta de resultados y corrección de solicitudes inválidas.')
g.a('sel','Seleccionar paciente, episodio y operación',0);g.q('op','¿Crear solicitud?',0)
g.a('result','Consultar resultados y mostrar estado, fecha y validador cuando corresponda')
g.a('catalogo','Consultar catálogo de exámenes');g.a('datos','Seleccionar exámenes e indicaciones clínicas',0)
g.a('validar','Validar paciente, episodio, exámenes, solicitante y datos obligatorios')
g.q('ok','¿Solicitud válida?');g.a('err','Mostrar errores de la solicitud')
g.a('crear','Guardar solicitud única, fecha, solicitante y estado solicitada')
g.a('lab','Dejar solicitud disponible al laboratorio y registrar auditoría')
g.begin('sel');g.path('sel op');g.e('op','result','no');g.finish('result');g.e('op','catalogo','sí')
g.path('catalogo datos validar ok');g.e('ok','err','no');g.e('err','datos');g.e('ok','crear','sí');g.path('crear lab');g.finish('lab')

g=Graph(12,'','Procesar y validar resultados de laboratorio',['Personal de laboratorio','Médico consultante'],
 'RF-LAB-002 RF-LAB-003 RF-LAB-004 RF-LAB-005 RN-008',
 'Solicitud existente; recepción, procesamiento y validación limitados a competencias autorizadas.',
 'Solicitud cancelada con motivo, pendiente de validación o resultado validado y consultable.',
 'Un valor fuera de referencia no se toma como error; la validación depende del profesional competente.')
g.a('sel','Seleccionar solicitud y verificar paciente, muestra y estado',0)
g.q('cancel','¿Cancelar según procedimiento?',0);g.a('cancelar','Registrar motivo y cancelar solo si la transición está permitida')
g.a('recibir','Registrar recepción de muestra y estado recibida',0)
g.a('procesar','Registrar estado en proceso y resultados con valores, unidades, intervalos y observaciones',0)
g.a('pendiente','Guardar resultados claramente pendientes de validación')
g.a('revisar','Revisar resultados y competencia para su validación',0)
g.q('validos','¿Validación aprobada?',0);g.a('corregir','Corregir registro o repetir según procedimiento; conservar trazabilidad',0)
g.a('validar','Registrar validación con responsable y fecha; cambiar estado a validada')
g.a('liberar','Liberar resultados definitivos para consulta autorizada')
g.a('consulta','Consultar resultados y estado del informe',1)
g.begin('sel');g.path('sel cancel');g.e('cancel','cancelar','sí');g.finish('cancelar');g.e('cancel','recibir','no')
g.path('recibir procesar pendiente revisar validos');g.e('validos','corregir','no');g.e('corregir','procesar')
g.e('validos','validar','sí');g.path('validar liberar consulta');g.done('consulta','Registrar entrega o consulta conforme al flujo de laboratorio y auditar')

g=Graph(13,'','Gestionar estudios de imagenología',['Médico','Profesional de imagenología'],
 'RF-IMG-001 RF-IMG-002 RF-IMG-003 RF-IMG-004','Paciente y episodio identificados; cada profesional autorizado para su función.',
 'Estudio programado, ejecutado e informe publicado, o informe conservado en borrador.',
 'Se separan solicitud, ejecución, borrador, validación y publicación; se usa repositorio interno aprobado.')
g.a('sol','Solicitar estudio con paciente, episodio e indicación clínica',0)
g.a('validar','Validar solicitud y datos obligatorios');g.q('ok','¿Solicitud válida?')
g.a('err','Mostrar datos pendientes de la solicitud')
g.a('programar','Registrar programación y ejecución del estudio con su estado',1)
g.a('informe','Elaborar informe radiológico en borrador',1)
g.a('vincular','Vincular imágenes y documentos al estudio en repositorio aprobado')
g.q('publicar','¿Informe validado por profesional autorizado?',1)
g.a('borrador','Conservar borrador sin publicarlo como definitivo')
g.a('definitivo','Guardar informe validado con autoría y publicar según permiso')
g.a('consulta','Consultar informe e imágenes autorizados',0)
g.begin('sol');g.path('sol validar ok');g.e('ok','err','no');g.e('err','sol');g.e('ok','programar','sí')
g.path('programar informe vincular publicar');g.e('publicar','borrador','no');g.finish('borrador')
g.e('publicar','definitivo','sí');g.path('definitivo consulta');g.done('consulta')

g=Graph(14,'','Registrar y consultar prescripciones',['Médico','Farmacéutico'],
 'RF-HC-002 RF-HC-006 RF-FAR-001 RF-FAR-003',
 'Paciente y episodio identificados; catálogo vigente; autorización para prescribir o consultar.',
 'Prescripción autorizada y disponible para validación farmacéutica, o consulta realizada.',
 'La autorización médica y la validación para dispensar se distinguen; no se inventan alertas clínicas automáticas.')
g.q('op','¿Operación solicitada?',0);g.a('consulta','Consultar catálogo y prescripciones autorizadas',1)
g.a('context','Seleccionar paciente y episodio; consultar alergias y antecedentes relevantes',0)
g.a('catalogo','Consultar catálogo institucional de medicamentos')
g.a('datos','Registrar medicamento, dosis, vía, frecuencia, duración e indicaciones aplicables',0)
g.a('validar','Validar campos institucionales y autorización del prescriptor');g.q('ok','¿Prescripción completa y autorizada?')
g.a('err','Mostrar errores de registro');g.a('firmar','Confirmar o firmar prescripción con mecanismo aprobado',0)
g.a('guardar','Guardar con autoría y dejar disponible para validación farmacéutica en DA CU15')
g.begin('op');g.e('op','consulta','consultar');g.finish('consulta');g.e('op','context','prescribir')
g.path('context catalogo datos validar ok');g.e('ok','err','no');g.e('err','datos');g.e('ok','firmar','sí')
g.path('firmar guardar');g.done('guardar')

g=Graph(15,'','Dispensar medicamentos',['Farmacéutico'],
 'RF-FAR-002 RF-FAR-003 RF-FAR-004 RF-FAR-005 RF-FAR-006 RN-011 RN-012 RN-021',
 'Prescripción autorizada; farmacéutico con permiso; paciente identificado.',
 'Dispensación única e inventario actualizados consistentemente, o entrega no realizada.',
 'Se elimina duplicación y se incorporan rechazo por receta, lote y concurrencia.')
g.a('receta','Seleccionar paciente y prescripción autorizada',0)
g.a('validar','Comprobar información de prescripción para dispensación',0)
g.q('valida','¿Prescripción válida para dispensar?',0)
g.a('rech','Registrar rechazo y solicitar revisión al prescriptor sin entregar medicamento')
g.a('stock','Consultar existencias dispensables por producto, ubicación y lote')
g.q('disponible','¿Cantidad suficiente y lote vigente no bloqueado?')
g.a('falta','Informar faltante o bloqueo y conservar receta pendiente')
g.a('confirmar','Confirmar cantidad y lote a dispensar',0)
g.a('tx','Revalidar cantidad y lote; guardar dispensación y salida en una transacción')
g.q('commit','¿Transacción confirmada?');g.a('conflicto','Revertir operación completa e informar conflicto de inventario')
g.a('entrega','Entregar medicamento y registrar responsable y fecha',0)
g.begin('receta');g.path('receta validar valida');g.e('valida','rech','no');g.finish('rech')
g.e('valida','stock','sí');g.path('stock disponible');g.e('disponible','falta','no');g.finish('falta')
g.e('disponible','confirmar','sí');g.path('confirmar tx commit');g.e('commit','conflicto','no');g.e('conflicto','stock')
g.e('commit','entrega','sí');g.done('entrega','Registrar auditoría de dispensación y movimiento asociado sin duplicar la salida')

g=Graph(16,'','Gestionar inventario de farmacia',['Farmacéutico'],
 'RF-FAR-002 RF-FAR-005 RF-FAR-006 RF-FAR-007',
 'Producto y ubicación registrados; ajustes sujetos a permiso específico.',
 'Consulta realizada o movimiento, lote o umbral actualizado con trazabilidad.',
 'Se añaden transferencias y control de lotes; consultar no genera un movimiento.')
g.a('sel','Seleccionar producto, ubicación y operación',0);g.q('op','¿Operación elegida?',0)
g.a('ver','Mostrar existencias disponibles, reservadas y no dispensables; lotes y alertas')
g.a('mov','Capturar entrada, salida, ajuste o transferencia con cantidad, motivo y referencia',0)
g.a('lote','Registrar lote, caducidad o bloqueo conforme a la política',0)
g.a('min','Definir nivel mínimo por producto y ubicación',0)
g.a('validar','Validar campos, permiso específico, saldo y restricciones del movimiento')
g.q('ok','¿Operación válida?');g.a('err','Mostrar errores sin alterar existencias')
g.a('tx','Guardar movimiento y saldos de origen y destino en transacción, o configuración elegida')
g.a('eval','Evaluar existencias disponibles frente al umbral configurado');g.q('bajo','¿Umbral de alerta alcanzado?')
g.a('alerta','Generar o actualizar alerta de stock visible al farmacéutico')
g.a('normal','Mantener estado sin alerta de stock bajo')
g.begin('sel');g.path('sel op');g.e('op','ver','consultar');g.finish('ver')
for x,guard in [('mov','movimiento'),('lote','lote o caducidad'),('min','nivel mínimo')]:g.e('op',x,guard);g.e(x,'validar')
g.path('validar ok');g.e('ok','err','no');g.e('err','sel');g.e('ok','tx','sí');g.path('tx eval bajo')
g.e('bajo','alerta','sí');g.e('bajo','normal','no');g.a('audit','Registrar operación y responsable sin duplicar movimientos de dispensación')
g.e('alerta','audit');g.e('normal','audit');g.finish('audit')

g=Graph(17,'','Asignar cama o registrar traslado',['Gestor de camas / Responsable de admisión según permiso'],
 'RF-HOS-001 RF-HOS-002 RF-HOS-003 RF-HOS-004 RN-009 RN-010 RN-021',
 'Ingreso hospitalario existente; cama y restricciones configuradas.',
 'Asignación o traslado consistente con historial, o paciente conserva ubicación anterior / espera.',
 'El traslado no ejecuta un egreso administrativo; origen y destino se actualizan juntos.')
g.a('ocup','Consultar ocupación e ingreso del paciente',0)
g.a('sel','Seleccionar asignación o traslado, destino y motivo',0)
g.a('val','Comprobar disponibilidad operativa y restricciones institucionales')
g.q('ok','¿Destino compatible y disponible?');g.a('espera','Informar falta de cama; conservar ubicación actual o registrar espera')
g.a('tx','Revalidar destino y actualizar ocupaciones de origen y destino en transacción')
g.q('commit','¿Asignación confirmada?');g.a('conf','Revertir cambios e informar conflicto concurrente')
g.a('hist','Registrar origen, destino, motivo, fecha y responsable; conservar historial')
g.begin('ocup');g.path('ocup sel val ok');g.e('ok','espera','no');g.finish('espera')
g.e('ok','tx','sí');g.path('tx commit');g.e('commit','conf','no');g.e('conf','ocup')
g.e('commit','hist','sí');g.done('hist')

g=Graph(17,'a','Administrar estados de cama y egreso',['Gestor de camas y hospitalización'],
 'RF-HOS-002 RF-HOS-006 RN-009','Cama registrada; el egreso requiere alta médica autorizada de DA CU19.',
 'Estado operativo o egreso registrado; disponibilidad respeta limpieza y preparación.',
 'Se separa alta médica de egreso; no se marca disponible una cama sin completar su preparación.')
g.a('sel','Seleccionar cama, estado operativo o egreso administrativo',0);g.q('tipo','¿Registrar egreso?',0)
g.a('estado','Definir estado operativo aprobado y motivo del cambio',0)
g.a('alta','Verificar alta médica, salida registrada y documentación de egreso')
g.q('ok','¿Egreso autorizado y completo?');g.a('pend','Mantener ocupación e informar pendientes')
g.a('egreso','Preparar egreso con fecha y responsable sin confirmar todavía los cambios')
g.a('limpieza','Determinar el estado de limpieza o preparación que corresponda')
g.a('validar','Validar transición operativa y ausencia de ocupaciones incompatibles')
g.q('val','¿Transición permitida?');g.a('err','Rechazar cambio y conservar estado actual')
g.a('save','Guardar egreso, fin de ocupación y estado en transacción; disponer cama solo tras preparación requerida')
g.begin('sel');g.path('sel tipo');g.e('tipo','estado','no');g.e('estado','validar')
g.e('tipo','alta','sí');g.path('alta ok');g.e('ok','pend','no');g.finish('pend')
g.e('ok','egreso','sí');g.path('egreso limpieza validar val');g.e('val','err','no');g.finish('err')
g.e('val','save','sí');g.done('save')

g=Graph(18,'','Programar y registrar cirugía',['Personal de quirófano','Médico'],
 'RF-QUI-001 RF-QUI-002 RF-QUI-003 RF-QUI-004',
 'Paciente y procedimiento identificados; recursos gestionados por el sistema.',
 'Cirugía programada o realizada y recuperación documentada; pendientes no se dan por resueltos.',
 'La disponibilidad se valida antes de programar y la lista preoperatoria antes de documentar la intervención.')
g.a('datos','Registrar paciente, procedimiento, equipo, fecha, hora y recursos',0)
g.a('recursos','Comprobar disponibilidad de recursos gestionados');g.q('ok','¿Recursos disponibles?')
g.a('conf','Informar conflicto y solicitar reprogramación');g.a('program','Confirmar programación y registrar responsable')
g.a('lista','Registrar lista preoperatoria y quién completa los controles',0)
g.q('pre','¿Controles y autorización completos?',1)
g.a('pend','Registrar pendientes y decisión del equipo; mantener programación pendiente o reprogramar',0)
g.a('cirugia','Registrar intervención, tiempos, participantes y observaciones',1)
g.a('recup','Registrar recuperación y disposición posterior del paciente',0)
g.a('cierre','Actualizar estado del procedimiento y cerrar registro según protocolo')
g.begin('datos');g.path('datos recursos ok');g.e('ok','conf','no');g.e('conf','datos')
g.e('ok','program','sí');g.path('program lista pre');g.e('pre','pend','no');g.finish('pend')
g.e('pre','cirugia','sí');g.path('cirugia recup cierre');g.done('cierre')

g=Graph(19,'','Registrar alta médica autorizada',['Médico'],
 'RF-HOS-006 RN-006','Paciente hospitalizado y episodio abierto; profesional competente para autorizar el alta.',
 'Alta médica e indicaciones guardadas y disponibles para el egreso administrativo.',
 'La decisión es clínica; se valida documentación antes de guardar el alta definitiva.')
g.a('episodio','Revisar paciente, episodio y documentación clínica',0)
g.q('decision','¿Alta clínicamente indicada por el médico?',0)
g.a('seguir','Conservar atención abierta y registrar evolución cuando corresponda')
g.a('datos','Registrar autorización, fecha, responsable e indicaciones de salida',0)
g.a('validar','Comprobar documentación requerida por el proceso institucional')
g.q('ok','¿Documentación completa?');g.a('err','Mostrar pendientes para completar el alta')
g.a('alta','Guardar alta autorizada y documentación; registrar autoría y auditoría')
g.a('egreso','Dejar alta disponible para DA CU17a; la cama sigue el flujo de egreso y preparación')
g.begin('episodio');g.path('episodio decision');g.e('decision','seguir','no');g.finish('seguir')
g.e('decision','datos','sí');g.path('datos validar ok');g.e('ok','err','no');g.e('err','datos')
g.e('ok','alta','sí');g.path('alta egreso');g.finish('egreso')

g=Graph(20,'','Generar documento de facturación',['Facturador'],
 'RF-FAC-001 RF-FAC-002 RF-FAC-003 RN-013','Servicios o productos prestados; tarifas y reglas vigentes configuradas.',
 'Documento de facturación emitido con estado, cálculo reproducible y referencia a cargos originales.',
 'Se conservan los orígenes de cargo y no se presupone emisión tributaria electrónica externa.')
g.a('cuenta','Seleccionar paciente, episodio o cuenta',0)
g.a('cargos','Cargar cargos de servicios prestados y productos dispensados con referencia a su origen')
g.a('revision','Revisar cargos y corregir datos autorizados',0)
g.a('calc','Calcular precios, tarifas, descuentos e impuestos vigentes; conservar reglas utilizadas')
g.q('ok','¿Cargos y cálculo válidos?');g.a('err','Mostrar inconsistencias sin emitir documento')
g.a('emitir','Emitir documento del alcance aprobado con identificador, estado y referencia')
g.a('comprobante','Mostrar o entregar comprobante autorizado y registrar auditoría')
g.begin('cuenta');g.path('cuenta cargos revision calc ok');g.e('ok','err','no');g.e('err','revision')
g.e('ok','emitir','sí');g.path('emitir comprobante');g.finish('comprobante')

g=Graph(21,'','Registrar pagos y consultar saldo',['Cajero / Facturador según permiso'],
 'RF-FAC-004 RF-FAC-006 RN-021','Cuenta y documentos relacionados existentes; permiso específico para registrar pagos.',
 'Estado consultado o pago registrado con saldo pendiente y comprobante consistentes.',
 'Se contemplan pagos parciales; el saldo se actualiza antes de emitir comprobante.')
g.a('sel','Seleccionar cuenta y consultar cargos, pagos, ajustes y saldo',0)
g.q('pagar','¿Registrar pago?',0);g.a('datos','Registrar importe, fecha, medio y documento relacionado',0)
g.a('validar','Validar permiso de caja, datos y reglas del importe aplicables')
g.q('ok','¿Pago válido?');g.a('err','Mostrar motivo de rechazo sin aplicar el pago')
g.a('tx','Guardar pago y actualizar saldo pendiente de forma transaccional')
g.q('commit','¿Registro confirmado?');g.a('fallo','Revertir pago y saldo; informar fallo sin emitir comprobante')
g.a('comprob','Emitir comprobante del pago confirmado, incluido pago parcial')
g.a('saldo','Mostrar saldo actualizado y registrar auditoría')
g.begin('sel');g.path('sel pagar');g.e('pagar','fin','no');g.n('fin','end','',g.sys)
g.e('pagar','datos','sí');g.path('datos validar ok');g.e('ok','err','no');g.e('err','datos')
g.e('ok','tx','sí');g.path('tx commit');g.e('commit','fallo','no');g.finish('fallo')
g.e('commit','comprob','sí');g.path('comprob saldo');g.finish('saldo')

g=Graph(21,'a','Registrar anulaciones y devoluciones',['Facturador autorizado'],
 'RF-FAC-005 RF-FAC-006 RN-014 RN-021',
 'Documento original identificado; permiso y procedimiento institucional para la operación.',
 'Anulación o devolución ligada al original con saldo e historial consistentes, o rechazo trazado.',
 'Se incorpora la alternativa financiera omitida, sin borrar documentos originales.')
g.a('sel','Seleccionar documento original y consultar estado de cuenta',0)
g.a('datos','Registrar anulación o devolución con importe, motivo y soporte requerido',0)
g.a('validar','Comprobar permiso específico, estado y reglas del procedimiento aprobado')
g.q('ok','¿Operación autorizada y válida?');g.a('err','Rechazar operación e informar motivo')
g.a('tx','Registrar reverso y actualizar saldo en transacción; mantener referencia al original')
g.q('commit','¿Transacción confirmada?');g.a('fallo','Revertir cambios y conservar documentos y saldo previos')
g.a('resultado','Mostrar resultado y conservar trazabilidad sin borrar el documento original')
g.begin('sel');g.path('sel datos validar ok');g.e('ok','err','no');g.finish('err')
g.e('ok','tx','sí');g.path('tx commit');g.e('commit','fallo','no');g.finish('fallo')
g.e('commit','resultado','sí');g.done('resultado')

g=Graph(22,'','Generar y exportar informes autorizados',['Usuario autorizado según tipo de informe'],
 'RF-INF-001 RF-INF-002 RF-INF-003 RF-INF-004 RF-INF-005 RF-INF-006 RF-INF-007',
 'Analista, director, gestor de camas, farmacéutico, facturador o cajero con permiso de informe.',
 'Informe de citas, atenciones, ocupación, farmacia o finanzas presentado; exportación opcional controlada.',
 'La exportación se decide y autoriza por separado, con los mismos filtros y minimización.')
g.a('tipo','Elegir informe de citas, atenciones, ocupación, farmacia o finanzas y filtros',0)
g.a('scope','Comprobar permiso por tipo, periodo y datos solicitados')
g.q('ok','¿Consulta permitida?');g.a('err','Denegar consulta y registrar intento')
g.a('generar','Generar informe con datos mínimos y definiciones de indicadores aprobadas')
g.a('ver','Mostrar informe o resultado sin datos; registrar generación sensible según política')
g.q('export','¿Solicitar exportación?',0);g.a('expcheck','Verificar permiso de exportación, formato y alcance de datos')
g.q('expok','¿Exportación autorizada?');g.a('noexp','Denegar exportación y registrar el intento')
g.a('archivo','Generar archivo autorizado en PDF o CSV con los mismos controles y filtros')
g.a('audit','Registrar exportación sensible conforme a la política institucional')
g.begin('tipo');g.path('tipo scope ok');g.e('ok','err','no');g.finish('err');g.e('ok','generar','sí')
g.path('generar ver export');g.e('export','fin','no');g.n('fin','end','',g.sys)
g.e('export','expcheck','sí');g.path('expcheck expok');g.e('expok','noexp','no');g.finish('noexp')
g.e('expok','archivo','sí');g.path('archivo audit');g.finish('audit')

g=Graph(23,'','Consultar registros de auditoría',['Auditor / Responsable de seguridad / Administrador'],
 'RF-AUD-001 RF-AUD-002 RF-AUD-003 RF-AUD-004 RN-016',
 'Sesión y autorización específica de auditoría; registros protegidos.',
 'Trazabilidad autorizada mostrada en modo consulta y acceso registrado.',
 'Se explicitan filtros y solo lectura; no se añade modificación o eliminación de auditoría.')
g.a('filtros','Definir usuario, periodo, módulo, operación u objeto afectado',0)
g.a('val','Validar filtros y alcance autorizado de la consulta');g.q('ok','¿Filtros y alcance permitidos?')
g.a('err','Rechazar consulta e informar motivo sin exponer información restringida')
g.a('buscar','Consultar registros protegidos; aplicar filtros y permisos')
g.a('mostrar','Mostrar usuario, fecha, operación, objeto y resultado en modo solo lectura')
g.a('audit','Registrar acceso a auditoría o intento denegado conforme a política')
g.begin('filtros');g.path('filtros val ok');g.e('ok','err','no');g.e('err','audit')
g.e('ok','buscar','sí');g.path('buscar mostrar audit');g.finish('audit')

def normalize(g):
 # Los puntos donde confluyen alternativas son merges UML explícitos.
 for node in list(g.nodes):
  incoming=[e for e in g.edges if e['target']==node['id']]
  if len(incoming)>1 and node['kind'] not in ('end','merge'):
   mid='merge_'+node['id'];g.n(mid,'merge','',node['lane'])
   for e in incoming:e['target']=mid
   g.e(mid,node['id'])
 # Conservar el orden semántico, con merges inmediatamente antes de su destino.
 positions={n['id']:i for i,n in enumerate(g.nodes)}
 g.nodes.sort(key=lambda n: positions[n['id'][6:]]-.1 if n['kind']=='merge' else positions[n['id']])
 return dict(cu=g.cu,suffix=g.suffix,title=g.title,lanes=g.lanes,rf=g.rf,pre=g.pre,post=g.post,change=g.change,nodes=g.nodes,edges=g.edges)

if __name__=='__main__':
 data=[normalize(g) for g in MODELS]
 (ROOT/'revision'/'flujos_corregidos.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')
 print(f'{len(data)} diagramas en {len(set(g.cu for g in MODELS))} modelos')
