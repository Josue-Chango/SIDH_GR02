from pathlib import Path
import json, hashlib
from PIL import Image, ImageOps, ImageDraw
import pypdfium2 as pdfium
from pypdf import PdfReader

root=Path(__file__).resolve().parent
final=root/'actualizado.pdf'
reader=PdfReader(final)
old=PdfReader(root/'original.pdf')
texts=[p.extract_text() or '' for p in reader.pages]
identical=[i for i in range(138) if (old.pages[i].extract_text() or '')==(reader.pages[i].extract_text() or '')]
print('Páginas anteriores con texto idéntico:',len(identical))
print('Páginas anteriores con diferencias de texto:',[i+1 for i in range(138) if i not in identical])
report=[]
for i,txt in enumerate(texts,1):
    if i>=138:report.append({'pagina':i,'texto':txt})
(root/'mapa-paginas.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
out=root/'render-final';out.mkdir(exist_ok=True)
doc=pdfium.PdfDocument(final)
baseline=pdfium.PdfDocument(root/'original.pdf')
same=0
thumbs=[]
for i in range(len(doc)):
    page=doc[i]
    im=page.render(scale=1.6).to_pil().convert('RGB')
    im.save(out/f'page-{i+1:03d}.png')
    if i in identical:
        ref=baseline[i].render(scale=1.6).to_pil().convert('RGB')
        if im.tobytes()==ref.tobytes():same+=1
        else: print('Diferencia visual anterior:',i+1)
    thumb=ImageOps.contain(im,(215,310))
    card=Image.new('RGB',(235,342),'#E8E8E8'); card.paste(thumb,((235-thumb.width)//2,8))
    ImageDraw.Draw(card).text((10,322),f'Página {i+1}',fill='black')
    thumbs.append(card)
    page.close()
for start in range(0,len(thumbs),20):
    selected=thumbs[start:start+20]
    sheet=Image.new('RGB',(235*5,342*4),'white')
    for j,im in enumerate(selected):sheet.paste(im,((j%5)*235,(j//5)*342))
    sheet.save(out/f'contacto-{start+1:03d}.png')
print('Páginas anteriores visualmente idénticas:',same)
print('Total páginas renderizadas:',len(doc))
for row in report:
    ls=[x for x in row['texto'].splitlines() if x.startswith('Paso ') or x.startswith('Figura ') or 'CONCLUSIONES' in x or 'REPORTES PDF CON JASPER' in x]
    if ls:print(row['pagina'],' | '.join(ls))
doc.close();baseline.close()
