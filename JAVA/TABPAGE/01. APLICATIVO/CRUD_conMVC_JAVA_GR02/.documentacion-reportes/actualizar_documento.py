from pathlib import Path
from copy import deepcopy
from zipfile import ZipFile, ZIP_DEFLATED
import json, hashlib, re
from lxml import etree as E
from PIL import Image
from contenido_reportes import INTRO, STEPS

ROOT=Path(__file__).resolve().parent
NS={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
    'r':'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
    'wp':'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
    'a':'http://schemas.openxmlformats.org/drawingml/2006/main',
    'pic':'http://schemas.openxmlformats.org/drawingml/2006/picture'}
REL='http://schemas.openxmlformats.org/package/2006/relationships'
def q(ns,name): return '{'+NS[ns]+'}'+name
def el(name,**attrs):
    p=E.Element(q('w',name))
    for key,val in attrs.items(): p.set(q('w',key),str(val))
    return p
def text(p): return ''.join(p.itertext())
def para(txt='',style=None,keep=False,break_before=False):
    p=el('p')
    pp=el('pPr')
    if style: pp.append(el('pStyle',val=style))
    if keep: pp.append(el('keepNext'))
    pp.append(el('keepLines'))
    if break_before: pp.append(el('pageBreakBefore'))
    p.append(pp)
    if txt:
        r=el('r'); t=el('t'); t.text=txt; r.append(t); p.append(r)
    return p

with ZipFile(ROOT/'original.docx') as z:
    original={n:z.read(n) for n in z.namelist()}
doc=E.fromstring(original['word/document.xml'])
body=doc.find(q('w','body'))
children=list(body)
anchor=next(p for p in children if p.tag==q('w','p') and ''.join(p.xpath('.//w:t/text()',namespaces=NS)).strip()=='CONCLUSIONES')
idx=children.index(anchor)
assert idx==703,idx
rels=E.fromstring(original['word/_rels/document.xml.rels'])
rid=max(int(x.get('Id')[3:]) for x in rels if re.fullmatch(r'rId\d+',x.get('Id','')))
drawing_id=max(int(x) for x in doc.xpath('//wp:docPr/@id',namespaces=NS))
media={}
added=[]

def image_para(filename,alt,max_height=6.8):
    global rid,drawing_id
    path=ROOT/'imagenes'/(filename+'.png')
    im=Image.open(path)
    w,h=im.size
    width=min(5.85,max_height*w/h)
    cx=round(width*914400); cy=round(cx*h/w)
    rid+=1; drawing_id+=1
    relation='rId'+str(rid)
    dest='media/reporte_documentacion_'+filename+'.png'
    E.SubElement(rels,'{'+REL+'}Relationship',Id=relation,Type=NS['r']+'/image',Target=dest)
    media['word/'+dest]=path.read_bytes()
    p=para(style='Imagenes',keep=True)
    p.find(q('w','pPr')).append(el('jc',val='center'))
    run=el('r'); drawing=el('drawing'); run.append(drawing);p.append(run)
    inline=E.SubElement(drawing,q('wp','inline'),distT='0',distB='0',distL='0',distR='0')
    E.SubElement(inline,q('wp','extent'),cx=str(cx),cy=str(cy))
    E.SubElement(inline,q('wp','effectExtent'),l='0',t='0',r='0',b='0')
    E.SubElement(inline,q('wp','docPr'),id=str(drawing_id),name=filename,descr=alt)
    frame=E.SubElement(inline,q('wp','cNvGraphicFramePr'))
    E.SubElement(frame,q('a','graphicFrameLocks'),noChangeAspect='1')
    graphic=E.SubElement(inline,q('a','graphic'))
    data=E.SubElement(graphic,q('a','graphicData'),uri=NS['pic'])
    pic=E.SubElement(data,q('pic','pic'))
    nv=E.SubElement(pic,q('pic','nvPicPr'))
    E.SubElement(nv,q('pic','cNvPr'),id='0',name=path.name)
    E.SubElement(nv,q('pic','cNvPicPr'))
    fill=E.SubElement(pic,q('pic','blipFill'))
    E.SubElement(fill,q('a','blip'),{q('r','embed'):relation})
    stretch=E.SubElement(fill,q('a','stretch'));E.SubElement(stretch,q('a','fillRect'))
    sp=E.SubElement(pic,q('pic','spPr'))
    xfrm=E.SubElement(sp,q('a','xfrm'))
    E.SubElement(xfrm,q('a','off'),x='0',y='0');E.SubElement(xfrm,q('a','ext'),cx=str(cx),cy=str(cy))
    geom=E.SubElement(sp,q('a','prstGeom'),prst='rect');E.SubElement(geom,q('a','avLst'))
    return p

added.append(para('REPORTES PDF CON JASPERREPORTS EN SIGH GR02',style='Ttulo1',keep=True,break_before=True))
for s in INTRO: added.append(para(s))
for i,(section,title,description,filename,caption) in enumerate(STEPS,67):
    if section: added.append(para(section,style='Ttulo2',keep=True))
    added.append(para(title,style='Ttulo3',keep=True))
    added.append(para(description,keep=True))
    added.append(image_para(filename,caption))
    cap=para(f'Figura {i}. {caption}',style='Imagenes')
    cap.find(q('w','pPr')).append(el('jc',val='center'))
    added.append(cap)

# El salto pertenece al contenido añadido; las conclusiones originales no se modifican.
last=para(); r=el('r');r.append(el('br',type='page'));last.append(r);added.append(last)
for offset,node in enumerate(added): body.insert(idx+offset,node)
replacement={
 'word/document.xml':E.tostring(doc,encoding='UTF-8',xml_declaration=True,standalone=True),
 'word/_rels/document.xml.rels':E.tostring(rels,encoding='UTF-8',xml_declaration=True,standalone=True)
}
ctype=E.fromstring(original['[Content_Types].xml'])
if not any(n.get('Extension')=='png' for n in ctype):
    E.SubElement(ctype,'{'+ctype.nsmap[None]+'}Default',Extension='png',ContentType='image/png')
    replacement['[Content_Types].xml']=E.tostring(ctype,encoding='UTF-8',xml_declaration=True,standalone=True)

target=ROOT/'actualizado.docx'
with ZipFile(target,'w',ZIP_DEFLATED) as z:
    for name,data in original.items():z.writestr(name,replacement.get(name,data))
    for name,data in media.items():z.writestr(name,data)

# Conservación estricta de los nodos originales y de todos los demás componentes.
with ZipFile(target) as z:
    final=E.fromstring(z.read('word/document.xml')).find(q('w','body'))
    prior=[E.tostring(n,method='c14n') for n in children]
    restored=list(final[:idx])+list(final[idx+len(added):])
    assert prior==[E.tostring(n,method='c14n') for n in restored]
    unchanged=[]
    for name,data in original.items():
        if name not in replacement:
            assert z.read(name)==data,name
            unchanged.append(name)
    finalrels=E.fromstring(z.read('word/_rels/document.xml.rels'))
    oldrels=E.fromstring(original['word/_rels/document.xml.rels'])
    assert [E.tostring(n,method='c14n') for n in oldrels]==[E.tostring(n,method='c14n') for n in list(finalrels)[:len(oldrels)]]
    all_ids=E.fromstring(z.read('word/document.xml')).xpath('//wp:docPr/@id',namespaces=NS)
    assert len(all_ids)==len(set(all_ids))
report={'pasos':len(STEPS),'capturas':len(STEPS),'figuras':'67–86','nodos_originales_conservados':len(children),'nodos_añadidos':len(added),'componentes_sin_cambios':len(unchanged),'sha256_original':hashlib.sha256((ROOT/'original.docx').read_bytes()).hexdigest(),'sha256_actualizado':hashlib.sha256(target.read_bytes()).hexdigest()}
(ROOT/'verificacion.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
