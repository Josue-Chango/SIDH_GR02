from pathlib import Path
from lxml import etree as E
import copy, json, re, time, uuid, zipfile, html, math

ROOT=Path(__file__).resolve().parents[1]
NS={'a':'attribute','c':'collection','o':'object'}
FACTOR=2540/30
DATA=json.loads((ROOT/'revision/flujos_layout.json').read_text(encoding='utf-8'))
STAMP=str(int(time.time()))

def at(parent,key,value):
 el=E.SubElement(parent,'{attribute}'+key);el.text=str(value);return el
def obj(parent,typ,id):return E.SubElement(parent,'{object}'+typ,Id=id)
def coll(parent,key):return E.SubElement(parent,'{collection}'+key)
def ref(parent,key,typ,id):
 c=coll(parent,key);E.SubElement(c,'{object}'+typ,Ref=id)
def meta(parent,scope,name,code):
 at(parent,'ObjectID',str(uuid.uuid5(uuid.NAMESPACE_URL,scope)).upper())
 at(parent,'Name',name);at(parent,'Code',code)
 for k,v in [('CreationDate',STAMP),('Creator','Revision UML'),('ModificationDate',STAMP),('Modifier','Revision UML')]:at(parent,k,v)
def num(v):return round(v*FACTOR)
def rect(x1,y1,x2,y2):return f'(({num(x1)},{num(y1)}), ({num(x2)},{num(y2)}))'
def color(hex):
 c=hex.lstrip('#');r,g,b=[int(c[i:i+2],16) for i in (0,2,4)];return r+g*256+b*65536
def points(e):
 tokens=e['pos'].split();tip=None;pts=[]
 for token in tokens:
  a=token.split(',')
  if a[0]=='e':tip=[float(a[1]),float(a[2])]
  elif a[0]=='s':pass
  else:pts.append([float(a[0]),float(a[1])])
 if tip:pts.append(tip)
 clean=[]
 for p in pts:
  if not clean or math.dist(clean[-1],p)>.05:clean.append(p)
 # Quitar puntos redundantes sin alterar el trazado ortogonal.
 out=[]
 for p in clean:
  if len(out)>=2 and ((abs(out[-2][0]-out[-1][0])<.05 and abs(out[-1][0]-p[0])<.05) or (abs(out[-2][1]-out[-1][1])<.05 and abs(out[-1][1]-p[1])<.05)):out.pop()
  out.append(p)
 return out

def enrich(g):
 lay=g['layout'];box=list(map(float,lay['bb'].split(',')))
 nodemap={o['name']:o for o in lay['objects'] if 'pos' in o and not o['name'].startswith('anchor_')}
 g['width']=box[2]+32;g['height']=box[3]+32
 g['clusters']=[]
 for i,lane in enumerate(g['lanes']):
  o=next(o for o in lay['objects'] if o['name']==f'cluster_{i}')
  x1,y1,x2,y2=map(float,o['bb'].split(','))
  g['clusters'].append(dict(x1=x1,x2=x2,y1=0,y2=box[3]+14,label=lane))
 for n in g['nodes']:
  o=nodemap[n['id']];n['x'],n['y']=map(float,o['pos'].split(','))
  n['w']=float(o['width'])*72;n['h']=float(o['height'])*72
 for i,e in enumerate(g['edges']):
  le=next(o for o in lay['edges'] if o.get('id')==f'flow_{i}')
  e['points']=points(le)
  if e['guard']:
   if 'xlp' in le:e['label_pos']=list(map(float,le['xlp'].split(',')))
   else:e['label_pos']=e['points'][0]
 return g

def native_model(path,graphs):
 t=E.parse(str(path));m=t.find('.//o:Model',NS)
 for key in ['Flows','Activities','Decisions','ActivityDiagrams','Starts','Ends','DefaultDiagram','OrganizationUnits','Packages']:
  for el in m.findall('c:'+key,NS):m.remove(el)
 for key in ['ModificationDate','Modifier','Comment']:
  for el in m.findall('a:'+key,NS):m.remove(el)
 at(m,'ModificationDate',STAMP);at(m,'Modifier','Revision UML')
 at(m,'Comment','Revisado contra ERS_SIGH_GR02: '+', '.join(sorted(set(r for g in graphs for r in g['rf'])))+'. Consultar INFORME_REVISION.md para trazabilidad y decisiones.')
 seed=E.parse(str(ROOT/'revision/native_template.oom'))
 pref=seed.find('.//o:ActivityDiagram/a:DisplayPreferences',NS).text
 # Las decisiones muestran su expresión; los merges no llevan texto.
 pref=pref.replace('Decision.DisplayedExpression=No','Decision.DisplayedExpression=Yes').replace('Decision.DisplayedExpressionOrName=Yes','Decision.DisplayedExpressionOrName=No')
 pref=re.sub(r'Decision_SymbolLayout=.*?(?=\n|$)','Decision_SymbolLayout=<Form><StandardAttribute Name="Expression" Attribute="DisplayedExpression" Mandatory="No" /></Form>',pref)
 # El rótulo se coloca sobre el conector como texto, conservando la condición semántica en el flujo.
 pref=re.sub(r'ActivityFlow_SymbolLayout=.*?(?=\n|$)','ActivityFlow_SymbolLayout=<Form></Form>',pref)
 nextid=1000
 def alloc():
  nonlocal nextid
  nextid+=1;return 'o'+str(nextid)
 packages=coll(m,'Packages') if len(graphs)>1 else None
 organization_collection=coll(m,'OrganizationUnits')
 organizations_by_name={}
 for g in graphs:
  container=m
  if g['suffix']:
   container=obj(packages,'Package',alloc())
   meta(container,str(path)+g['suffix']+'package',f'CU{g["cu"]:02d}{g["suffix"]} {g["title"]}',f'CU{g["cu"]:02d}{g["suffix"]}')
  collections={key:coll(container,key) for key in ['Flows','Activities','Decisions','ActivityDiagrams','Starts','Ends']}
  did=alloc();g['native_diagram_id']=did
  d=obj(collections['ActivityDiagrams'],'ActivityDiagram',did)
  tag=f'CU{g["cu"]:02d}{g["suffix"]}'
  meta(d,str(path)+tag,g['title'],f'DA_{tag}')
  at(d,'Comment','Requisitos: '+', '.join(g['rf'])+'\nPrecondición: '+g['pre']+'\nPostcondición: '+g['post'])
  at(d,'Scale',75);at(d,'DisplayPreferences',pref)
  at(d,'PaperSize','(11693, 16535)');at(d,'PageMargins','((315,315), (315,315))');at(d,'PageOrientation',1)
  at(d,'SwimlaneHeaderHeight',num(60))
  symbols=coll(d,'Symbols')
  group=obj(symbols,'SwimlaneGroupSymbol',alloc())
  at(group,'Rect',rect(min(c['x1'] for c in g['clusters']),0,max(c['x2'] for c in g['clusters']),g['height']-18))
  at(group,'LineColor',color('#94a3b8'))
  subs=coll(group,'SubSymbols');orgids={}
  for i,c in sorted(enumerate(g['clusters']),key=lambda item:item[1]['x1']):
   lane_lines=[];line=''
   for word in c['label'].split():
    if len((line+' '+word).strip())>28 and line:lane_lines.append(line);line=word
    else:line=(line+' '+word).strip()
   if line:lane_lines.append(line)
   lane_name='\n'.join(lane_lines)
   if lane_name not in organizations_by_name:
    oid=alloc();organizations_by_name[lane_name]=oid
    u=obj(organization_collection,'OrganizationUnit',oid)
    meta(u,str(path)+tag+'lane'+str(i),lane_name,f'{tag}_Responsable_{i}')
   oid=organizations_by_name[lane_name];orgids[i]=oid
   s=obj(subs,'SwimlaneSymbol',alloc())
   for k,v in [('IconMode',-1),('Rect',rect(c['x1'],0,c['x2'],g['height']-18)),('AutoAdjustToText',0),('LineColor',color('#94a3b8')),('FillColor',color('#ffffff')),('FontList','STRN 0 Arial,11,B\nDISPNAME 0 Arial,11,B'),('BrushStyle',1),('GradientFillMode',0),('KeepAspect',0)]:at(s,k,v)
   ref(s,'Object','OrganizationUnit',oid)
  nm={};sm={};types={'action':('Activity','Activities','ActivitySymbol'),'decision':('Decision','Decisions','BaseDecisionSymbol'),'merge':('Decision','Decisions','BaseDecisionSymbol'),'start':('Start','Starts','StartSymbol'),'end':('End','Ends','EndSymbol')}
  for n in g['nodes']:
   n['native_h']=n['h']+40 if n['kind']=='decision' else n['h']
   typ,key,styp=types[n['kind']];oid=alloc();sid=alloc();nm[n['id']]=(typ,oid);sm[n['id']]=(styp,sid)
   o=obj(collections[key],typ,oid)
   label=n['label'] or ('Confluencia '+n['id'] if n['kind']=='merge' else ('Inicio' if n['kind']=='start' else 'Fin '+n['id']))
   if n['kind']=='action':label='\n'.join(n['lines'])
   meta(o,str(path)+tag+n['id'],label,f'{tag}_{n["id"]}')
   if n['kind']=='action':at(o,'ActionType','UNDEF')
   if n['kind']=='end':at(o,'ActivityTermination',1)
   if n['kind'] in ('action','decision','merge'):ref(o,'OrganizationUnit','OrganizationUnit',orgids[n['lane']])
   if n['kind']=='decision':
    at(o,'Expression',n['label']);at(o,'ExpressionAlias','\r\n'.join(n['lines']))
   elif n['kind']=='merge':at(o,'Expression','')
   s=obj(symbols,styp,sid)
   fill='#eff6ff' if n['kind']=='action' else '#fff7ed' if n['kind']=='decision' else '#ffffff'
   if n['kind'] in ('start','end'):fill='#0f172a'
   for k,v in [('IconMode',-1),('Rect',rect(n['x']-n['w']/2,n['y']-n['native_h']/2,n['x']+n['w']/2,n['y']+n['native_h']/2)),('AutoAdjustToText',0),('LineColor',color('#334155')),('FillColor',color(fill)),('FontList','STRN 0 Arial,10,N\nDISPNAME 0 Arial,10,N\nLABL 0 Arial,10,N\nDEXP 0 Arial,10,N\nDEXN 0 Arial,10,N'),('BrushStyle',6),('GradientFillMode',0),('Shadow',0),('ManuallyResized',1)]:at(s,k,v)
   ref(s,'Object',typ,oid)
  nodes_by_id={n['id']:n for n in g['nodes']}
  for i,e in enumerate(g['edges']):
   fid=alloc();f=obj(collections['Flows'],'ActivityFlow',fid)
   meta(f,str(path)+tag+'flow'+str(i),'',f'{tag}_Flujo_{i:03d}')
   if e['guard']:at(f,'ConditionExpression',e['guard'])
   # La serialización nativa guarda Object1=destino y Object2=origen.
   ref(f,'Object1',*nm[e['target']]);ref(f,'Object2',*nm[e['source']])
   s=obj(symbols,'FlowSymbol',alloc());ps=e['points']
   at(s,'Rect',rect(min(p[0] for p in ps),min(p[1] for p in ps),max(p[0] for p in ps),max(p[1] for p in ps)))
   # PowerDesigner recalcula los extremos a partir de los centros de los símbolos.
   # Los puntos intermedios deben estar alineados exactamente para conservar los codos.
   sn=nodes_by_id[e['source']];dn=nodes_by_id[e['target']]
   raw=[(sn['x'],sn['y'])]+[tuple(p) for p in ps[1:-1]]+[(dn['x'],dn['y'])]
   native_points=[]
   for p in raw:
    p=(num(p[0]),num(p[1]))
    if native_points and p[0]!=native_points[-1][0] and p[1]!=native_points[-1][1]:native_points.append((p[0],native_points[-1][1]))
    if not native_points or p!=native_points[-1]:native_points.append(p)
   # Los anclajes verticales se mantienen estables al reabrir un OOM en esta versión.
   # En las llegadas horizontales, aproximarse por arriba o por abajo del destino.
   dc=native_points[-1]
   side=1 if sn['y']>=dn['y'] else -1
   approach=(dc[0],dc[1]+side*num(dn['native_h']/2+8))
   prefix=native_points[:-1]
   while len(prefix)>1 and abs(prefix[-1][0]-dc[0])<=num(dn['w']/2+8) and abs(prefix[-1][1]-dc[1])<=num(dn['native_h']/2+8):prefix.pop()
   # Mantener un tramo final exterior al símbolo: evita segmentos diminutos dentro de su texto.
   if prefix[-1][0]!=approach[0] and prefix[-1][1]!=approach[1]:prefix.append((prefix[-1][0],approach[1]))
   native_points=prefix+[approach,dc]
   at(s,'ListOfPoints','('+','.join(f'({x},{y})' for x,y in native_points)+')')
   for k,v in [('CornerStyle',2),('ArrowStyle',1),('LineColor',color('#334155')),('FontList','SOURCE 0 Arial,9,N\nDESTINATION 0 Arial,9,N')]:at(s,k,v)
   ref(s,'SourceSymbol',*sm[e['source']]);ref(s,'DestinationSymbol',*sm[e['target']]);ref(s,'Object','ActivityFlow',fid)
   if e['guard']:
    x,y=e['label_pos'];text='['+e['guard']+']';width=max(30,len(text)*4.9)
    st=obj(symbols,'TextSymbol',alloc())
    for k,v in [('Rect',rect(x-width/2,y-7,x+width/2,y+7)),('Text',text),('LineStyle',0),('FillColor',color('#ffffff')),('LineColor',color('#ffffff')),('FontList','Free Text 0 Arial,9,N'),('AutoAdjustToText',0),('ManuallyResized',1)]:at(st,k,v)
  ref(container,'DefaultDiagram','ActivityDiagram',did)
 # Actualizar el encabezado sin cambiar la identidad de cada modelo ni el proyecto.
 pi=t.getroot().getprevious()
 while pi is not None:
  if isinstance(pi,E._ProcessingInstruction) and pi.target=='PowerDesigner':
   pi.text=re.sub(r'LastModificationDate="[^"]*"',f'LastModificationDate="{STAMP}"',pi.text)
   pi.text=re.sub(r'Objects="[^"]*"',f'Objects="{len(m.xpath(".//*[@Id]"))}"',pi.text)
   pi.text=re.sub(r'Symbols="[^"]*"',f'Symbols="{sum(len(d.xpath(".//*[@Id]")) for d in m.findall("c:ActivityDiagrams/o:ActivityDiagram",NS))}"',pi.text)
  pi=pi.getprevious()
 path.write_bytes(E.tostring(t,encoding='UTF-8',xml_declaration=True,pretty_print=True))

def svg(g):
 W=g['width'];H=g['height'];header=70;footer=32
 esc=html.escape
 def yy(y):return H-y+header
 out=[f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="-14 0 {W+14:.2f} {H+header+footer:.2f}" width="{W+14:.0f}" height="{H+header+footer:.0f}" font-family="Arial, sans-serif">',f'<title>DA CU{g["cu"]:02d}{g["suffix"]} {esc(g["title"])}</title>',f'<rect x="-14" width="{W+14}" height="{H+header+footer}" fill="white"/>',f'<text x="8" y="24" font-size="17" font-weight="bold" fill="#0f172a">DA CU{g["cu"]:02d}{g["suffix"]}  {esc(g["title"])}</text>',f'<text x="8" y="44" font-size="10" fill="#475569">{esc(", ".join(g["rf"]))}</text>']
 for i,c in enumerate(g['clusters']):
  x=c['x1'];w=c['x2']-x;top=yy(H-14)
  out.append(f'<rect x="{x}" y="{top}" width="{w}" height="{H-14}" fill="white" stroke="#94a3b8" stroke-width=".7"/>')
  out.append(f'<rect x="{x}" y="{top}" width="{w}" height="48" fill="#f1f5f9" stroke="#94a3b8" stroke-width=".7"/>')
  # Los rótulos largos se parten a espacios, nunca se cortan.
  words=c['label'].split();lines=[];l=''
  for word in words:
   if len(l+' '+word)>max(25,int(w/6)):lines.append(l);l=word
   else:l=(l+' '+word).strip()
  if l:lines.append(l)
  for j,l in enumerate(lines):out.append(f'<text x="{x+w/2}" y="{top+18+j*13}" text-anchor="middle" font-size="11" font-weight="bold" fill="#0f172a">{esc(l)}</text>')
 for e in g['edges']:
  ps=e['points'];coords=' '.join(f'{x:.2f},{yy(y):.2f}' for x,y in ps)
  out.append(f'<polyline points="{coords}" fill="none" stroke="#334155" stroke-width="1.05"/>')
  x,y=ps[-1];px,py=ps[-2];ang=math.atan2(y-py,x-px);size=6
  arr=[(x,y),(x-size*math.cos(ang)+size*.4*math.sin(ang),y-size*math.sin(ang)-size*.4*math.cos(ang)),(x-size*math.cos(ang)-size*.4*math.sin(ang),y-size*math.sin(ang)+size*.4*math.cos(ang))]
  out.append('<polygon points="'+' '.join(f'{a:.2f},{yy(b):.2f}' for a,b in arr)+'" fill="#334155"/>')
 for n in g['nodes']:
  x=n['x'];y=yy(n['y']);w=n['w'];h=n['h'];kind=n['kind']
  if kind=='action':out.append(f'<rect x="{x-w/2}" y="{y-h/2}" width="{w}" height="{h}" rx="10" fill="#eff6ff" stroke="#334155" stroke-width="1.05"/>')
  elif kind in ('decision','merge'):out.append(f'<polygon points="{x-w/2},{y} {x},{y-h/2} {x+w/2},{y} {x},{y+h/2}" fill="{"#fff7ed" if kind=="decision" else "white"}" stroke="#334155" stroke-width="1.05"/>')
  elif kind=='start':out.append(f'<circle cx="{x}" cy="{y}" r="{w/2}" fill="#0f172a"/>')
  else:
   out.append(f'<circle cx="{x}" cy="{y}" r="{w/2}" fill="white" stroke="#0f172a" stroke-width="1.2"/>')
   out.append(f'<circle cx="{x}" cy="{y}" r="{max(2,w/2-3)}" fill="#0f172a"/>')
  for j,line in enumerate(n['lines']):out.append(f'<text x="{x}" y="{y-(len(n["lines"])-1)*6.5+j*13+3.6}" text-anchor="middle" font-size="11" fill="#0f172a">{esc(line)}</text>')
 for e in g['edges']:
  if e['guard']:
   x,y=e['label_pos'];text='['+e['guard']+']';w=len(text)*4.8+6
   out.append(f'<rect x="{x-w/2}" y="{yy(y)-7}" width="{w}" height="14" rx="2" fill="white"/>')
   out.append(f'<text x="{x}" y="{yy(y)+3}" text-anchor="middle" font-size="9" fill="#334155">{esc(text)}</text>')
 out.append(f'<text x="8" y="{H+header+21}" font-size="9" fill="#64748b">SIGH · Revisión de actividades · ERS y casos de uso CU01 a CU23 · 2 noviembre 2026</text></svg>')
 return '\n'.join(out)

def main():
 backup=ROOT/'_RESPALDO'/'ORIGINALES_2026-11-02.zip';backup.parent.mkdir(exist_ok=True)
 if not backup.exists():
  with zipfile.ZipFile(backup,'w',zipfile.ZIP_DEFLATED) as z:
   for p in sorted(list(ROOT.glob('*.oom'))+list(ROOT.glob('*.prj'))+list(ROOT.glob('*.pjb'))+list((ROOT/'svg').glob('*.svg'))):z.write(p,p.relative_to(ROOT))
 for g in DATA:enrich(g)
 for p in sorted(ROOT.glob('*.oom')):
  cu=int(p.name[5:7]);graphs=[g for g in DATA if g['cu']==cu]
  native_model(p,graphs)
  for g in graphs:
   filename=p.stem+(('_'+g['suffix']) if g['suffix'] else '')+'.svg';g['svg_file']='svg/'+filename
   (ROOT/g['svg_file']).write_text(svg(g),encoding='utf-8')
 (ROOT/'revision'/'diagramas_publicados.json').write_text(json.dumps(DATA,ensure_ascii=False,indent=2),encoding='utf-8')
 print(f'Actualizados 23 modelos nativos y {len(DATA)} SVG; originales preservados en {backup.name}')

if __name__=='__main__':main()
