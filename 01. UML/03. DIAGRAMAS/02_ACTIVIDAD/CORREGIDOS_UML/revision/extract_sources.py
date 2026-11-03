from pathlib import Path
from zipfile import ZipFile
from lxml import etree as E
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'revision'
SRC = Path(r'C:\Users\Usuario\Desktop\Web Avanzada\Sigh_02\SIDH_GR02\01. UML')
NS = {'o':'object','a':'attribute','c':'collection'}
W = {'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
doc = SRC / '01. ERS' / 'ERS_SIGH_GR02.docx'
with ZipFile(doc) as z:
    xml = E.fromstring(z.read('word/document.xml'))
    lines = []
    for i,p in enumerate(xml.findall('.//w:p', W),1):
        text = ''.join(p.itertext()) if False else ''.join(p.xpath('.//w:t/text()', namespaces=W))
        if text.strip():
            lines.append(f'P{i:04d} {text}')
    (OUT/'ERS_extraido.txt').write_text('\n'.join(lines), encoding='utf-8')

def model_summary(path):
    t = E.parse(str(path))
    objects = {}
    for o in t.xpath('//*[@Id]'):
        objects[o.get('Id')] = {
            'type': E.QName(o).localname,
            'name': o.findtext('a:Name', namespaces=NS),
            'code': o.findtext('a:Code', namespaces=NS),
        }
    res = {'file':str(path), 'objects':[]}
    for o in t.xpath('//*[@Id]'):
        typ = E.QName(o).localname
        if typ in ('Activity','Decision','Start','End','ActivityFlow','Actor','UseCase','UseCaseAssociation','UseCaseDependency','Dependency','Association','Swimlane'):
            attrs={E.QName(c).localname:c.text for c in o if E.QName(c).namespace=='attribute'}
            attrs={k:v for k,v in attrs.items() if k not in ('CreationDate','ModificationDate','Creator','Modifier','ObjectID')}
            refs={E.QName(c).localname:[dict(ref=r.get('Ref'), **objects.get(r.get('Ref'),{})) for r in c if r.get('Ref')] for c in o if E.QName(c).namespace=='collection'}
            res['objects'].append(dict(id=o.get('Id'), type=typ, **attrs, refs=refs))
    return res

acts=[model_summary(p) for p in sorted(ROOT.glob('*.oom'))]
cu_root=SRC / '03. DIAGRAMAS' / '01_CASOS_USO' / 'CORREGIDOS_UML'
cus=[model_summary(p) for p in sorted(cu_root.glob('*.oom'))]
(OUT/'actividades_originales.json').write_text(json.dumps(acts,ensure_ascii=False,indent=2), encoding='utf-8')
(OUT/'casos_uso_carpeta.json').write_text(json.dumps(cus,ensure_ascii=False,indent=2), encoding='utf-8')
print(f'ERS: {len(lines)} párrafos; actividades: {len(acts)}; modelos de casos de uso: {len(cus)}')
for a in acts:
    print(Path(a['file']).stem + ': ' + ' -> '.join(o.get('Name','') for o in a['objects'] if o['type'] in ('Activity','Decision')))
