from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent
src = ROOT / 'capturas'
out = ROOT / 'imagenes'
out.mkdir(exist_ok=True)

def crop(name, box=None, dest=None):
    im=Image.open(src/(name+'.png')).convert('RGB')
    if box: im=im.crop(box)
    im.save(out/((dest or name)+'.png'))

crop('plantillas')
crop('controlador',(28,272,1160,642))
crop('utilidad-jasper',(28,372,1125,633))
crop('studio-diseno',(387,65,1017,605))
style_source=Image.open(src/'studio-estilos.png').convert('RGB')
outline=style_source.crop((0,425,383,630))
properties=style_source.crop((1192,355,1536,560))
panels=Image.new('RGB',(741,205),'white')
panels.paste(outline,(0,0));panels.paste(properties,(397,0))
panels.save(out/'studio-estilos.png')
crop('bienvenida-reportes',(774,485,1280,775))
crop('departamentos-interfaz',(239,174,1283,776))
crop('cargos-interfaz',(239,185,1283,810))
crop('cargos-filtro',(239,178,1283,776))
crop('cargos-pdf-navegador',(361,126,1162,704))
crop('departamentos-1',(18,22,795,610))
crop('cargos-1',(18,22,795,1118))
crop('cargos-2',(18,22,795,1118))
crop('cargos-filtrado-1',(18,22,795,590))
crop('empleados-1',(18,22,795,436))
crop('empleado_ficha-1',(18,22,795,543),'ficha-general')
crop('empleado_ficha-1',(18,540,795,976),'ficha-detalles')

crop('empleados-interfaz',(239,305,1283,736))
crop('ficha-navegador-general',(385,155,1134,652),'ficha-general')
crop('ficha-navegador-detalles',(385,279,1134,690),'ficha-detalles')
if (src/'pom.png').exists(): crop('pom',(129,321,825,573))
if (src/'validacion.png').exists(): crop('validacion',(33,178,1140,470))
if (src/'construir.png').exists(): crop('construir')
print('Capturas preparadas:',len(list(out.glob('*.png'))))
