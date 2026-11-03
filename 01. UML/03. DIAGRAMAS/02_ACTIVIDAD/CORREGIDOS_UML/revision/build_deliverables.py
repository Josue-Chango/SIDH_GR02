from pathlib import Path
import json, math, html, textwrap, re, hashlib, zipfile
from collections import Counter
from lxml import etree as E
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.colors import HexColor
import pypdfium2 as pdfium
from PIL import Image, ImageOps, ImageDraw

R=Path(__file__).resolve().parents[1]
D=json.loads((R/'revision/diagramas_publicados.json').read_text(encoding='utf-8'))
N={'o':'object','a':'attribute','c':'collection'}

def audit():
 checks=[]
 for p in sorted(R.glob('DA_CU*.oom')):
  t=E.parse(str(p));ids={o.get('Id'):o for o in t.xpath('//*[@Id]')};errors=[]
  for ref in t.xpath('//*[@Ref]'):
   target=ids.get(ref.get('Ref'))
   if target is None or ref.tag!=target.tag:errors.append('Referencia inválida '+ref.get('Ref'))
  for d in t.findall('.//o:ActivityDiagram',N):
   if not d.get('Id'):continue
   symbols=d.find('c:Symbols',N)
   flow_symbols=[s for s in symbols if E.QName(s).localname=='FlowSymbol']
   node_ids=set();arcs=[]
   for s in symbols:
    typ=E.QName(s).localname
    if typ not in ('ActivitySymbol','BaseDecisionSymbol','StartSymbol','EndSymbol'):continue
    target=s.find('c:Object/*',N)
    if target is not None:node_ids.add(target.get('Ref'))
   for s in flow_symbols:
    f=ids[s.find('c:Object/*',N).get('Ref')]
    dest=f.find('c:Object1/*',N).get('Ref');src=f.find('c:Object2/*',N).get('Ref')
    arcs.append((src,dest))
    for side,objid in [('SourceSymbol',src),('DestinationSymbol',dest)]:
     sym=ids[s.find('c:'+side+'/*',N).get('Ref')]
     if sym.find('c:Object/*',N).get('Ref')!=objid:errors.append('Conector semántico y gráfico discordantes')
   starts=[i for i in node_ids if E.QName(ids[i]).localname=='Start']
   ends=[i for i in node_ids if E.QName(ids[i]).localname=='End']
   if len(starts)!=1:errors.append('Inicio distinto de uno')
   def reach(seed,arcs):
    found=set(seed)
    while True:
     new=found|{b for a,b in arcs if a in found}
     if new==found:return found
     found=new
   if node_ids-reach(starts,arcs):errors.append('Nodos no alcanzables desde el inicio')
   if node_ids-reach(ends,[(b,a) for a,b in arcs]):errors.append('Nodos sin camino a final')
   for i in ends:
    if ids[i].findtext('a:ActivityTermination',namespaces=N)!='1':errors.append('Final no termina la actividad')
   for i in node_ids:
    kind=E.QName(ids[i]).localname
    incoming=[a for a,b in arcs if b==i];outgoing=[b for a,b in arcs if a==i]
    if kind=='Activity' and (len(incoming)!=1 or len(outgoing)!=1):errors.append('Acción sin flujo único de entrada o salida')
    if kind=='Decision' and len(outgoing)>1:
     guards=[]
     for s in flow_symbols:
      f=ids[s.find('c:Object/*',N).get('Ref')]
      if f.find('c:Object2/*',N).get('Ref')==i:guards.append(f.findtext('a:ConditionExpression',namespaces=N))
     if not all(guards) or len(guards)!=len(set(guards)):errors.append('Guardas ausentes o repetidas')
  checks.append(dict(file=p.name,errors=errors,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
 project=E.parse(str(R/'ACTIVIDAD_SIGH_CORREGIDOS.prj'))
 docs=project.findall('.//o:ModelDocument',N)
 for d in docs:
  if not d.get('Id'):continue
  location=d.findtext('a:Location',namespaces=N);f=R/location.rsplit('/',1)[-1]
  assert f.exists(),f
  expected=d.findtext('a:ModelDocument.ModelID',namespaces=N)
  actual=E.parse(str(f)).findtext('.//o:Model/a:ObjectID',namespaces=N)
  assert expected==actual,(f,expected,actual)
 result=dict(models=checks,project_models=len([d for d in docs if d.get('Id')]),diagrams=len(D),graph_errors=sum(len(x['errors']) for x in checks))
 (R/'revision/validacion_estructural.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
 assert result['graph_errors']==0,result
 return result

def wrap(s,width,font='Arial',size=10):
 lines=[];line=''
 for word in s.split():
  test=(line+' '+word).strip()
  if pdfmetrics.stringWidth(test,font,size)>width and line:lines.append(line);line=word
  else:line=test
 if line:lines.append(line)
 return lines

def make_pdf():
 pdfmetrics.registerFont(TTFont('Arial',r'C:\Windows\Fonts\arial.ttf'))
 pdfmetrics.registerFont(TTFont('ArialBold',r'C:\Windows\Fonts\arialbd.ttf'))
 out=R/'DIAGRAMAS_ACTIVIDAD_CORREGIDOS.pdf';c=canvas.Canvas(str(out))
 c.setTitle('Diagramas de actividad corregidos del SIGH')
 c.setAuthor('Revision de modelos UML SIGH')
 for i,g in enumerate(D,1):
  W=g['width']+64;H=g['height']+210;ox=32;oy=58
  c.setPageSize((W,H));c.bookmarkPage('d'+str(i))
  title=f'DA CU{g["cu"]:02d}{g["suffix"]}  {g["title"]}'
  c.addOutlineEntry(title,'d'+str(i),0,False)
  c.setFillColor(HexColor('#0f172a'));c.setFont('ArialBold',16)
  c.drawString(32,H-30,title)
  y=H-48;c.setFillColor(HexColor('#475569'));c.setFont('Arial',9)
  c.drawString(32,y,', '.join(g['rf']));y-=17
  for text in ['Precondición: '+g['pre'],'Resultado: '+g['post']]:
   for line in wrap(text,W-64,size=9):c.drawString(32,y,line);y-=11
   y-=4
  for lane in g['clusters']:
   x=lane['x1']+ox;w=lane['x2']-lane['x1'];top=g['height']-14+oy
   c.setLineWidth(.65);c.setStrokeColor(HexColor('#94a3b8'));c.setFillColor(HexColor('#ffffff'))
   c.rect(x,oy,w,g['height']-14,stroke=1,fill=1)
   c.setFillColor(HexColor('#f1f5f9'));c.rect(x,top-48,w,48,stroke=1,fill=1)
   lines=wrap(lane['label'],w-16,'ArialBold',11)
   c.setFont('ArialBold',11);c.setFillColor(HexColor('#0f172a'))
   for j,line in enumerate(lines):c.drawCentredString(x+w/2,top-18-j*13,line)
  for e in g['edges']:
   ps=e['points'];p=c.beginPath();p.moveTo(ps[0][0]+ox,ps[0][1]+oy)
   for x,y in ps[1:]:p.lineTo(x+ox,y+oy)
   c.setLineWidth(.85);c.setStrokeColor(HexColor('#334155'));c.drawPath(p,stroke=1)
   x,y=ps[-1];px,py=ps[-2];angle=math.atan2(y-py,x-px);s=5.6
   a=(x-s*math.cos(angle)+s*.38*math.sin(angle),y-s*math.sin(angle)-s*.38*math.cos(angle))
   b=(x-s*math.cos(angle)-s*.38*math.sin(angle),y-s*math.sin(angle)+s*.38*math.cos(angle))
   p=c.beginPath();p.moveTo(x+ox,y+oy);p.lineTo(a[0]+ox,a[1]+oy);p.lineTo(b[0]+ox,b[1]+oy);p.close()
   c.setFillColor(HexColor('#334155'));c.drawPath(p,stroke=0,fill=1)
  for n in g['nodes']:
   x=n['x']+ox;y=n['y']+oy;w=n['w'];h=n['h'];kind=n['kind']
   c.setStrokeColor(HexColor('#334155'));c.setLineWidth(.9)
   if kind=='action':
    c.setFillColor(HexColor('#eff6ff'));c.roundRect(x-w/2,y-h/2,w,h,9,stroke=1,fill=1)
   elif kind in ('decision','merge'):
    c.setFillColor(HexColor('#fff7ed' if kind=='decision' else '#ffffff'))
    p=c.beginPath();p.moveTo(x-w/2,y);p.lineTo(x,y+h/2);p.lineTo(x+w/2,y);p.lineTo(x,y-h/2);p.close();c.drawPath(p,stroke=1,fill=1)
   elif kind=='start':c.setFillColor(HexColor('#0f172a'));c.circle(x,y,w/2,stroke=0,fill=1)
   else:
    c.setFillColor(HexColor('#ffffff'));c.circle(x,y,w/2,stroke=1,fill=1)
    c.setFillColor(HexColor('#0f172a'));c.circle(x,y,w/2-3,stroke=0,fill=1)
   c.setFillColor(HexColor('#0f172a'));c.setFont('Arial',11)
   for j,line in enumerate(n['lines']):c.drawCentredString(x,y+(len(n['lines'])-1)*6.5-j*13-3.6,line)
  for e in g['edges']:
   if not e['guard']:continue
   x,y=e['label_pos'];x+=ox;y+=oy;text='['+e['guard']+']';w=pdfmetrics.stringWidth(text,'Arial',9)+6
   c.setFillColor(HexColor('#ffffff'));c.roundRect(x-w/2,y-7,w,14,2,stroke=0,fill=1)
   c.setFillColor(HexColor('#334155'));c.setFont('Arial',9);c.drawCentredString(x,y-3,text)
  c.setFillColor(HexColor('#64748b'));c.setFont('Arial',9)
  c.drawString(32,27,'SIGH · Diagramas de actividad revisados · 2 noviembre 2026')
  c.drawRightString(W-32,27,f'{i} / {len(D)}');c.showPage()
 c.save()
 # Renderizar todas las páginas para verificar el PDF real.
 qa=R/'revision/pdf_png';qa.mkdir(exist_ok=True)
 doc=pdfium.PdfDocument(str(out))
 for i,page in enumerate(doc):
  im=page.render(scale=1.25).to_pil();im.save(qa/f'pagina_{i+1:02d}.png');page.close()
 doc.close()
 print(f'PDF generado y renderizado: {len(D)} páginas')

def contacts():
 # Las hojas de control se generan tanto del PDF final como de la exportación nativa.
 sources=[('pdf',R/'revision/pdf_png'),('native',R/'revision/powerdesigner_png')]
 for kind,folder in sources:
  files=sorted(folder.glob('*.png'))
  for start in range(0,len(files),4):
   page=Image.new('RGB',(2000,1000),'#cbd5e1')
   for k,p in enumerate(files[start:start+4]):
    im=Image.open(p).convert('RGB');im.thumbnail((492,960))
    page.paste(im,(k*500+(500-im.width)//2,20))
    ImageDraw.Draw(page).text((k*500+5,980),p.name[:60],fill='black')
   page.save(R/'revision'/f'contacto_{kind}_{start//4+1}.png')

def report(validation):
 native=json.loads((R/'revision/validacion_powerdesigner.json').read_text(encoding='utf-8-sig'))
 assert len(native)==23 and not any(x.get('failure') or x.get('messages') for x in native), 'Existen hallazgos nativos pendientes'
 cases=Path(r'C:\Users\Usuario\Desktop\Web Avanzada\Sigh_02\SIDH_GR02\01. UML\03. DIAGRAMAS\01_CASOS_USO\CORREGIDOS_UML')
 ers=Path(r'C:\Users\Usuario\Desktop\Web Avanzada\Sigh_02\SIDH_GR02\01. UML\01. ERS\ERS_SIGH_GR02.docx')
 lines=['# Revisión de los diagramas de actividad del SIGH','',
 'Se corrigieron los 23 modelos editables de PowerDesigner y se organizaron 32 diagramas: 23 principales y 9 complementarios. Se revisaron los flujos normales, las alternativas, las responsabilidades, las condiciones de decisión, la integridad del modelo y su correspondencia con la especificación de requisitos.','',
 'Los 23 modelos finales se guardaron mediante PowerDesigner 16.6.1 y se volvieron a abrir antes de comprobarlos con todas las verificaciones disponibles activadas y exportarlos. La comprobación de los archivos persistidos no produjo mensajes pendientes. La validación adicional de XML, conectores, alcanzabilidad y referencias del proyecto también pasó.','',
 '## Archivos para usar','',
 '- `ACTIVIDAD_SIGH_CORREGIDOS.prj`: proyecto con los 23 modelos de actividad. Abrir este archivo en PowerDesigner. Las identidades de modelo y las rutas del proyecto se conservaron.',
 '- `DA_CU01...DA_CU23.oom`: modelos editables corregidos. Cada modelo tiene su diagrama principal; los complementarios están dentro de paquetes con el identificador del caso de uso.',
 '- `DIAGRAMAS_ACTIVIDAD_CORREGIDOS.pdf`: 32 páginas vectoriales, con marcadores por diagrama, requisitos, precondición y resultado. El tamaño de página se adapta al diagrama para conservar el tamaño legible del texto.',
 '- `svg/`: 32 vistas vectoriales actualizadas. Los sufijos `_a` y `_b` identifican los complementos.',
 '- `_RESPALDO/ORIGINALES_2026-11-02.zip`: copia de los archivos originales antes de modificarlos.',
 '- `TRAZABILIDAD_ACTIVIDADES.csv`: matriz de caso, actividad, requisitos, responsables y corrección.',
 '- `revision/validacion_powerdesigner.json` y `revision/validacion_estructural.json`: evidencia verificable de las comprobaciones.','',
 '## Fuentes y alcance de la revisión','',
 f'Fuente normativa del alcance funcional: `{ers}`. Se consultaron la descripción de CU-01 a CU-23, los requisitos RF, las reglas RN y las restricciones de seguridad, integridad y alcance. El documento se trató como fuente de requisitos, sin ejecutar instrucciones que pudiera contener.','',
 f'Fuente de actores y objetivos: los 24 modelos de casos de uso existentes en `{cases}`, incluido el general. También se inspeccionaron los nombres y objetivos de los modelos CU-01, CU-15 y CU-17 del archivo `C:/Users/Usuario/Desktop/Web Avanzada/01_CASOS_USO.rar`, como contraste.','',
 'La ruta exacta del RAR indicada en la solicitud no existía al comenzar la revisión. Se localizó `C:/Users/Usuario/Desktop/Web Avanzada/CORREGIDOS_UML.rar`, pero su listado contiene los 23 diagramas de actividad, no los casos de uso. Para revisar estos últimos se utilizó la carpeta de modelos corregidos situada junto a la ubicación original y se contrastó con el RAR de casos de uso disponible. Esta diferencia de ubicación y contenido queda registrada para no atribuir al archivo ausente información que no se pudo leer.','',
 'No se añadió portal del paciente, conexión con aseguradoras, SRI, PACS ni servicios externos no aprobados. Tampoco se fijaron protocolos clínicos, categorías de triaje, dosis, reglas de alta, plazos de sesión o fórmulas financieras que el ERS deja a validación institucional. Las decisiones clínicas quedan en las particiones de los profesionales competentes.','',
 '## Correcciones comunes','',
 'En los archivos originales, los extremos de los flujos semánticos apuntaban a identificadores de símbolos gráficos. Se sustituyeron por referencias a Start, Activity, Decision y End, y se verificó la correspondencia entre cada conector gráfico y su flujo. En la notación XML de PowerDesigner, Object1 serializa el destino y Object2 el origen; se respetó la estructura generada por la aplicación.','',
 'Se añadieron particiones de responsabilidad, guardas semánticas y visibles, confluencias de alternativas y finales que terminan la actividad. Se verificó que todos los nodos fueran alcanzables desde el inicio y tuvieran un camino al final. Los rechazos, borradores y procesos pendientes terminan la ejecución del caso sin declarar concluido el proceso asistencial.','',
 'Se corrigió el recorte de los SVG originales, se ajustaron texto y símbolos nativos y se conservaron puntos de decisión legibles. Algunas acciones comunes llevan el identificador de diagrama para distinguir sus nombres dentro del modelo; las condiciones siguen asociadas al flujo semántico y se muestran junto al conector.','',
 'La autorización se verifica en el servidor y por operación. En diagramas con varios roles, cada intervención exige la competencia y el permiso correspondientes. Las operaciones acopladas, como dispensación e inventario o traslado entre camas, se representan con actualización transaccional. Los registros clínicos, administrativos y financieros conservan referencias e historial.','',
 '## Matriz de cambios y trazabilidad','',
 '| Diagrama | Requisitos y reglas | Corrección aplicada |','|---|---|---|']
 for g in D:
  id=f'CU{g["cu"]:02d}{g["suffix"]}'
  lines.append(f'| {id} {g["title"]} | {", ".join(g["rf"])} | {g["change"]} |')
 lines += ['', '## Criterios que requieren definición institucional','',
 'El ERS contiene campos incompletos o repetidos en las tablas iniciales y deja varias políticas sujetas a aprobación. Se priorizaron las descripciones detalladas de los requisitos funcionales y las reglas de negocio. Los diagramas remiten al procedimiento aprobado cuando corresponde; no sustituyen esa definición por una regla inventada.','',
 'En particular, deben mantenerse definidos el catálogo de datos obligatorios; las transiciones válidas de citas, solicitudes, camas y documentos; el procedimiento de identidad temporal y duplicados; la validación y rectificación clínica; la preparación de camas; la recuperación de credenciales; y las anulaciones o devoluciones. Un resultado fuera del intervalo de referencia no se considera automáticamente un resultado de laboratorio inválido.','',
 'La aprobación formal de las políticas clínicas y administrativas corresponde a los responsables del sistema. Las comprobaciones UML y de PowerDesigner verifican la consistencia del modelo, mientras que la conformidad de esas políticas debe revisarse con los interesados.','']
 (R/'INFORME_REVISION.md').write_text('\n'.join(lines),encoding='utf-8')
 import csv
 with (R/'TRAZABILIDAD_ACTIVIDADES.csv').open('w',encoding='utf-8-sig',newline='') as f:
  w=csv.writer(f,delimiter=';');w.writerow(['Diagrama','Nombre','Modelo PowerDesigner','SVG','Requisitos y reglas','Responsables','Precondición','Resultado','Corrección'])
  for g in D:
   model=next(R.glob(f'DA_CU{g["cu"]:02d}_*.oom'))
   w.writerow([f'CU{g["cu"]:02d}{g["suffix"]}',g['title'],model.name,g['svg_file'],', '.join(g['rf']),'; '.join(g['lanes']),g['pre'],g['post'],g['change']])
 # Visor local con navegación por caso y acceso directo al SVG original.
 items=[dict(id=f'CU{g["cu"]:02d}{g["suffix"]}',title=g['title'],file=g['svg_file']) for g in D]
 viewer='''<!doctype html><html lang="es"><meta charset="utf-8"><title>Diagramas de actividad del SIGH</title><style>body{margin:0;font:16px Arial;color:#14233a;background:#f1f5f9}header{position:sticky;top:0;background:white;padding:18px 24px;border-bottom:1px solid #cbd5e1;display:flex;gap:18px;align-items:center;flex-wrap:wrap}select,button,a{font:inherit}select{padding:8px;max-width:70vw}main{padding:24px;text-align:center}img{max-width:100%;height:auto;background:white}a{color:#164ba0}</style><header><strong>Actividades del SIGH</strong><select id="sel" aria-label="Seleccionar diagrama"></select><a id="original" target="_blank">Abrir SVG</a><a href="DIAGRAMAS_ACTIVIDAD_CORREGIDOS.pdf">Ver PDF completo</a></header><main><img id="img" alt="Diagrama de actividad seleccionado"></main><script>const items=ITEMS;const s=document.getElementById('sel');for(const d of items){const o=document.createElement('option');o.value=d.file;o.textContent=d.id+' '+d.title;s.append(o)}function show(){document.getElementById('img').src=s.value;document.getElementById('original').href=s.value} s.onchange=show;show();</script></html>'''
 (R/'INDICE_DIAGRAMAS.html').write_text(viewer.replace('ITEMS',json.dumps(items,ensure_ascii=False)),encoding='utf-8')
 print(f'Informe y matriz completados; {validation["project_models"]} referencias de proyecto verificadas')

if __name__=='__main__':
 result=audit();make_pdf();contacts();report(result)
