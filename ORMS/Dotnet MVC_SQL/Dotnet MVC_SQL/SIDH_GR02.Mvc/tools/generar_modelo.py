"""Genera las entidades C# y el mapeo EF Core desde el DDL MySQL. No se ejecuta al iniciar la app.

Replica tools/generate_model.py del proyecto Java (mismos nombres de clases y atributos),
cambiando la salida de Jakarta Persistence a EF Core. Sobrescribe Models/Entidades y
Data/SidhDbContext.Modelo.cs si se vuelve a ejecutar.

Uso: python tools/generar_modelo.py
"""
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
SQL = (ROOT / 'db/schema-create.sql').read_text(encoding='utf-8').replace('\r\n', '\n')
MODEL = ROOT / 'Models/Entidades'
MODEL.mkdir(parents=True, exist_ok=True)
NS = 'SIDH_GR02.Mvc.Models.Entidades'

NAMES = dict(zip('''FICAR_CARGO FIFAC_FACTU FIFOR_FORMA FIPAG_PAGO FISER_SERVIC FITAR_TARIF GEPAC_PACIE GHADM_ADMIS GHAGE_AGEND GHALE_ALERG GHASI_ASIGN GHCAM_CAMA GHCIT_CITA GHDIA_DIAGN GHEPI_EPISO GHESP_ESPEC GHEST_ESTUD GHLOT_LOTE GHMED_MEDIC GHMOV_MOVIM GHNOT_NOTAC GHPRES_PRESC GHPRO_PROFE GHPRQ_PROCQ GHRES_RESUL GHSOL_SOLIC GH_AJUSTE_FINANCIERO GH_ALTA_MEDICA GH_ATENCION_EMERGENCIA GH_CAMBIO_CATALOGO GH_CATALOGO GH_CATALOGO_DIAGNOSTICO GH_CONTACTO_PACIENTE GH_CONTROL_PREOPERATORIO GH_CUENTA_FACTURACION GH_DETALLE_DISPENSACION GH_DETALLE_FACTURA GH_DISPENSACION GH_DISPOSICION_EMERGENCIA GH_DOCUMENTO_CLINICO GH_EGRESO_ADMINISTRATIVO GH_EXAMEN_LABORATORIO GH_EXISTENCIA GH_HABILITACION_PROFESIONAL GH_HABITACION GH_HISTORIAL_CITA GH_HISTORIAL_ESTADO_CAMA GH_INFORME_IMAGEN GH_ITEM_PRESCRIPCION GH_ITEM_SOLICITUD_LAB GH_MEDICION_SIGNO GH_MUESTRA_LABORATORIO GH_PARAMETRO_EXAMEN GH_PARTICIPACION_QUIRURGICA GH_POLITICA_STOCK GH_RECURSO_QUIRURGICO GH_REGISTRO_ENFERMERIA GH_REGISTRO_RECUPERACION GH_RESERVA_RECURSO GH_REVISION_IDENTIDAD GH_SERVICIO_HOSPITALARIO GH_TRASLADO_HOSPITALARIO GH_TRIAJE GH_TURNO_AGENDA GH_UBICACION_INVENTARIO GH_VALIDACION_RESULTADO GH_VALOR_CATALOGO PECAR_CARGO PEDEP_DEPAR PEESC_ESTCIV PEGEN_GENERO PEPER_PERSO R080_PROCESAMUESTRA XEEST_ESTAD XEOPC_OPCIO XEOXP_OPCPE XEPER_PERFI XESIS_SISTE XEUSU_USUAR XEUXP_USUPE'''.split(), '''CargoFacturable Factura FormaPago Pago ServicioFacturable Tarifa Paciente Admision Agenda Alergia AsignacionCama Cama Cita Diagnostico Episodio Especialidad EstudioImagen Lote Medicamento MovimientoInventario NotaClinica Prescripcion Profesional ProcedimientoQuirurgico ResultadoLaboratorio SolicitudLaboratorio AjusteFinanciero AltaMedica AtencionEmergencia CambioCatalogo Catalogo CatalogoDiagnostico ContactoPaciente ControlPreoperatorio CuentaFacturacion DetalleDispensacion DetalleFactura Dispensacion DisposicionEmergencia DocumentoClinico EgresoAdministrativo ExamenLaboratorio Existencia HabilitacionProfesional Habitacion HistorialCita HistorialEstadoCama InformeImagen ItemPrescripcion ItemSolicitudLab MedicionSigno MuestraLaboratorio ParametroExamen ParticipacionQuirurgica PoliticaStock RecursoQuirurgico RegistroEnfermeria RegistroRecuperacion ReservaRecurso RevisionIdentidad ServicioHospitalario TrasladoHospitalario Triaje TurnoAgenda UbicacionInventario ValidacionResultado ValorCatalogo Cargo Departamento EstadoCivil Genero Persona ProcesaMuestra Estado Opcion OpcionPerfil Perfil Sistema Usuario UsuarioPerfil'''.split()))
WORDS = sorted(set('''identificador hospitalario fecha nacimiento nombre nombres apellido apellidos direccion entidad cobertura referencia tipo documento identidad sexo registrado registro estado desde hasta vigente descripcion codigo cantidad responsable telefono correo parentesco prioridad contacto vinculo capacidad inicio fin jornada duracion cita minutos efectiva efectivo ingreso egreso indicacion indicaciones procedencia servicio profesional diagnostico concepto paciente atencion motivo origen destino movimiento sustancia condicion reaccion severidad fuente informacion verificacion alergia cargo lote medicamento caducidad version finalizada mecanismo finalizacion rectificacion emitida moneda subtotal descuento impuesto total pagado importe pago numero unitario tasa precio principio activo concentracion forma farmaceutica presentacion unidad requiere control stock minimo maximo punto reposicion almacen ubicacion recurso quirurgico autorizada salida documentacion requerida verificada observacion observaciones resultado parametro muestra solicitud examen valor valido validado validacion validada rango inferior superior toma tomado recibida recepcion secuencia actual anterior nueva nuevo cambio operacion evidencia informe contenido hallazgo hallazgos conclusion conclusiones recomendacion recomendaciones informado interpretacion interpretado prescripcion dosis frecuencia via administracion tratamiento instruccion instrucciones dispensacion dispensada dispensado medido medicion signo enfermeria recuperacion reserva orden detalle factura cuenta financiero ajuste triaje nivel dolor escala peso talla temperatura sistolica diastolica cardiaca respiratoria saturacion oxigeno glucemia programada programado realizada realizado especialista rol participacion proceso procesamiento autorizacion autorizador identificacion laboratorio procedimiento cama habitacion emergencia traslado ocupado ocupacion reservada cupo costo monto anulacion anulado vigencia notas aplicado asignacion retiro acceso usuario perfil opcion sistema persona genero civil departamento'''.split()), key=len, reverse=True)
SPECIAL = {'DESCRI':'descripcion','NOMBRE':'nombre','APELLI':'apellidos','FECNAC':'fechaNacimiento','CEDULA':'cedula','PASAPO':'pasaporte','EMAIL':'email','CARFAM':'cargasFamiliares','FOTO':'foto','DISC':'discapacidad','FECCRE':'fechaCreacion','FECMOD':'fechaModificacion','PIEFIR':'pieFirma','FECASI':'fechaAsignacion','FECRET':'fechaRetiro','OBSER':'observaciones','PASWD':'claveHeredada'}
PLURAL = {'ItemSolicitudLab': 'ItemsSolicitudLab', 'ItemPrescripcion': 'ItemsPrescripcion'}

def camel(value):
    if value in SPECIAL: return SPECIAL[value]
    text = value.lower(); parts = []
    while text:
        word = next((w for w in WORDS if text.startswith(w)), None)
        if word is None:
            parts.append(text); break
        parts.append(word); text = text[len(word):]
    return parts[0] + ''.join(w.capitalize() for w in parts[1:])

def pascal(name): return name[0].upper() + name[1:]

def plural(cls):
    if cls in PLURAL: return PLURAL[cls]
    return cls + ('s' if cls[-1] in 'aeiou' else 'es')

tables = {}
for name, body in re.findall(r'CREATE TABLE (\w+)\s*\((.*?)\n\);', SQL, re.S):
    cols = []
    for line in body.splitlines():
        m = re.match(r'\s*(\w+)\s+(VARCHAR\(\d+\)|CHAR\(\d+\)|NUMERIC\(\d+,\d+\)|INT|DATETIME|DATE|TIME|TEXT|BOOL)', line)
        if m: cols.append(dict(name=m[1], type=m[2], nullable='NOT NULL' not in line))
        elif line.strip() and not line.strip().startswith(('PRIMARY KEY', 'KEY ')):
            raise ValueError('Definición SQL no reconocida: ' + line)
    pk = re.search(r'PRIMARY KEY \(([^)]+)\)', body)[1].split(',')
    tables[name] = dict(name=name, cls=NAMES[name], columns=cols, pk=[p.strip() for p in pk], relations=[])
for table, constraint, col, target, ref in re.findall(r'ALTER TABLE (\w+) ADD CONSTRAINT (\w+) FOREIGN KEY \(([^)]+)\)\s*REFERENCES (\w+) \(([^)]+)\)', SQL, re.I):
    assert ',' not in col, 'Revisar FK multicolumna'
    t = tables[table]; field = NAMES[target][0].lower() + NAMES[target][1:]
    n = sum(1 for r in t['relations'] if r['target'] == target)
    if n: field += str(n + 1)
    t['relations'].append(dict(column=col, target=target, ref=ref, field=field, constraint=constraint))

def cs_type(c):
    base = {'DATE': 'DateOnly', 'DATETIME': 'DateTime', 'TIME': 'TimeOnly', 'INT': 'int', 'BOOL': 'bool'}.get(
        c['type'], 'decimal' if c['type'].startswith('NUMERIC') else 'string')
    return base + ('?' if c['nullable'] else '')

def default(c):
    return ' = null!;' if cs_type(c) == 'string' else ''

def col_attrs(c, prop):
    a = []
    if not c['nullable'] and cs_type(c) == 'string': a.append('[Required]')
    args = [f'"{c["name"]}"']
    if c['type'].startswith(('VARCHAR', 'CHAR')):
        a.append(f'[StringLength({re.search(r"\d+", c["type"])[0]})]')
        if c['type'].startswith('CHAR'): args.append(f'TypeName = "{c["type"].lower()}"')
    elif c['type'] == 'TEXT': args.append('TypeName = "text"')
    elif c['type'].startswith('NUMERIC'):
        p, s = re.findall(r'\d+', c['type']); a.append(f'[Precision({p}, {s})]')
    a.append('[Column(' + ', '.join(args) + ')]')
    return a

# Resolver los nombres de propiedades (mismo criterio que el generador Java).
for t in tables.values():
    composite = len(t['pk']) > 1; fk = {r['column']: r for r in t['relations']}
    usados = set()
    for c in t['columns']:
        if c['name'] in fk:
            c['prop'] = pascal(fk[c['name']]['field']) + 'Id'
        elif c['name'] in t['pk'] and not composite:
            c['prop'] = 'Id'
        else:
            c['prop'] = pascal(camel(c['name'].split('_')[-1]))
        if c['prop'] == t['cls']: c['prop'] += 'Valor'   # C# no admite miembros con el nombre de la clase
        assert c['prop'] not in usados, f'Propiedad repetida {t["cls"]}.{c["prop"]}'
        usados.add(c['prop'])
    for r in t['relations']:
        r['nav'] = pascal(r['field'])
        if r['nav'] == t['cls']: r['nav'] += 'Relacionada'   # autorreferencia (p. ej. NotaClinica)
        assert r['nav'] not in usados, f'Navegación repetida {t["cls"]}.{r["nav"]}'
        usados.add(r['nav'])

# Colecciones inversas
for t in tables.values():
    t['inversas'] = []
for child in tables.values():
    for r in child['relations']:
        r['coleccion'] = 'Registros' + child['cls'] + r['nav']
        tables[r['target']]['inversas'].append((child['cls'], r))

for table, t in tables.items():
    cls = t['cls']; composite = len(t['pk']) > 1; fk = {r['column']: r for r in t['relations']}
    L = ['// <auto-generated> Generado por tools/generar_modelo.py desde db/schema-create.sql. </auto-generated>', '#nullable enable',
         'using System.ComponentModel.DataAnnotations;',
         'using System.ComponentModel.DataAnnotations.Schema;',
         'using Microsoft.EntityFrameworkCore;', '',
         f'namespace {NS};', '',
         f'/// <summary>Mapeo de {table}; sin cambios al esquema físico.</summary>',
         f'[Table("{table}")]']
    if composite:
        props = [next(c['prop'] for c in t['columns'] if c['name'] == p) for p in t['pk']]
        L.append('[PrimaryKey(' + ', '.join(f'nameof({p})' for p in props) + ')]')
    L.append(f'public class {cls}')
    L.append('{')
    for c in t['columns']:
        attrs = (['[Key]'] if c['name'] in t['pk'] and not composite else []) + col_attrs(c, c['prop'])
        L.extend('    ' + a for a in attrs)
        L.append(f'    public {cs_type(c)} {c["prop"]} {{ get; set; }}{default(c)}')
        L.append('')
        if c['name'] in fk:
            r = fk[c['name']]; q = '?' if c['nullable'] else ''
            L.append(f'    public {NAMES[r["target"]]}{q} {r["nav"]} {{ get; set; }}' + ('' if q else ' = null!;'))
            L.append('')
    for child_cls, r in t['inversas']:
        L.append(f'    public List<{child_cls}> {r["coleccion"]} {{ get; set; }} = [];')
    if t['inversas']: L.append('')
    if L[-1] == '': L.pop()
    L.append('}')
    (MODEL / (cls + '.cs')).write_text('\n'.join(L) + '\n', encoding='utf-8')

# Configuración Fluent: DbSet por tabla y FK con su nombre de restricción, sin borrado en cascada.
C = ['// <auto-generated> Generado por tools/generar_modelo.py desde db/schema-create.sql. </auto-generated>',
     'using Microsoft.EntityFrameworkCore;',
     f'using {NS};', '',
     'namespace SIDH_GR02.Mvc.Data;', '',
     'public partial class SidhDbContext', '{']
for t in tables.values():
    C.append(f'    public DbSet<{t["cls"]}> {plural(t["cls"])} => Set<{t["cls"]}>();')
C += ['', '    private static void ConfigurarRelaciones(ModelBuilder mb)', '    {']
for t in tables.values():
    for r in t['relations']:
        C.append(f'        mb.Entity<{t["cls"]}>().HasOne(e => e.{r["nav"]}).WithMany(p => p.{r["coleccion"]})'
                 f'.HasForeignKey(e => e.{pascal(r["field"])}Id).HasConstraintName("{r["constraint"]}").OnDelete(DeleteBehavior.Restrict);')
C += ['    }', '}']
(ROOT / 'Data/SidhDbContext.Modelo.cs').parent.mkdir(exist_ok=True)
(ROOT / 'Data/SidhDbContext.Modelo.cs').write_text('\n'.join(C) + '\n', encoding='utf-8')

report = ['# Mapa de persistencia (C# / EF Core)', '', '| Tabla | Entidad | PK | FK |', '|---|---|---|---|']
report.extend(f'| `{name}` | `{t["cls"]}` | ' + ', '.join('`' + p + '`' for p in t['pk']) + f' | {len(t["relations"])} |' for name, t in tables.items())
(ROOT / 'docs').mkdir(exist_ok=True)
(ROOT / 'docs/MAPEOS.md').write_text('\n'.join(report) + '\n', encoding='utf-8')
print(f'Generadas {len(tables)} entidades; {sum(len(t["pk"]) > 1 for t in tables.values())} claves compuestas; '
      f'{sum(len(t["relations"]) for t in tables.values())} FK; {sum(len(t["columns"]) for t in tables.values())} columnas.')
