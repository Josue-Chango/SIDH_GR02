from pathlib import Path
from lxml import etree as E
import json
R=Path(__file__).resolve().parents[1]
N={'a':'attribute','c':'collection','o':'object'}
for p in sorted(R.glob('*.oom')):
 t=E.parse(str(p)); ids={o.get('Id'):o for o in t.xpath('//*[@Id]')}
 errors=[]
 for f in t.findall('.//o:ActivityFlow',N):
  if not f.get('Id'): continue
  for side in ('Object1','Object2'):
   refs=f.findall(f'c:{side}/*',N)
   if len(refs)!=1: errors.append(f'{f.get("Id")} sin {side}'); continue
   ref=refs[0]; target=ids.get(ref.get('Ref'))
   if target is None or target.tag!=ref.tag:
    errors.append(f'{f.get("Id")} {side}: {E.QName(ref).localname} referencia {ref.get("Ref")} ({E.QName(target).localname if target is not None else "inexistente"})')
 print(p.stem, 'extremos inconsistentes:',len(errors))
 if p.name.startswith('DA_CU01'): print('\n'.join(errors))

examples=Path(r'C:\Program Files\SAP\PowerDesigner 16\Examples')
for p in examples.glob('*.oom'):
 try:t=E.parse(str(p))
 except:continue
 for tag in ('ActivityFlow','Swimlane','SwimlaneSymbol','OrganizationUnit','Start','End','Decision'):
  els=t.findall(f'.//o:{tag}[@Id]',N)
  if els:
   print(p.name,tag,len(els))
   if tag in ('Swimlane','SwimlaneSymbol','OrganizationUnit','ActivityFlow'):
    (R/'revision'/f'example_{tag}.xml').write_bytes(E.tostring(els[0],pretty_print=True))
