from pathlib import Path
from lxml import etree as E
import re,uuid
R=Path(__file__).resolve().parents[1]
t=E.parse(str(R/'DA_CU01_Iniciar_Sesion.oom'))
N={'o':'object','a':'attribute','c':'collection'}
ids={o.get('Id'):o for o in t.xpath('//*[@Id]')}
for s in t.findall('.//o:FlowSymbol',N):
 if not s.get('Id'):continue
 ps=s.find('a:ListOfPoints',N)
 pairs=[tuple(map(int,m)) for m in re.findall(r'\((-?\d+),(-?\d+)\)',ps.text)]
 def center(side):
  ref=s.find('c:'+side+'/*',N).get('Ref');r=ids[ref].findtext('a:Rect',namespaces=N)
  a,b,c,d=map(int,re.findall(r'-?\d+',r));return ((a+c)//2,(b+d)//2)
 sc=center('SourceSymbol');dc=center('DestinationSymbol')
 if len(pairs)==2:
  if sc[0]==dc[0] or sc[1]==dc[1]:pairs=[sc,dc]
  else:pairs=[sc,(dc[0],sc[1]),dc]
 else:
  p1=(pairs[1][0],sc[1]) if abs(pairs[1][0]-pairs[0][0])>abs(pairs[1][1]-pairs[0][1]) else (sc[0],pairs[1][1])
  pn=(pairs[-2][0],dc[1]) if abs(pairs[-1][0]-pairs[-2][0])>abs(pairs[-1][1]-pairs[-2][1]) else (dc[0],pairs[-2][1])
  raw=[sc,p1]+pairs[2:-2]+[pn,dc];pairs=[]
  for p in raw:
   if pairs and p!=pairs[-1] and p[0]!=pairs[-1][0] and p[1]!=pairs[-1][1]:pairs.append((p[0],pairs[-1][1]))
   if not pairs or p!=pairs[-1]:pairs.append(p)
 ps.text='('+','.join(f'({a},{b})' for a,b in pairs)+')'
t.find('.//o:Model/a:ObjectID',N).text=str(uuid.uuid4()).upper()
(R/'revision/probe_render.oom').write_bytes(E.tostring(t,encoding='UTF-8',xml_declaration=True))
