from pathlib import Path
import zipfile,json,hashlib
from pypdf import PdfReader

R=Path(__file__).resolve().parents[1]
native=json.loads((R/'revision/validacion_powerdesigner.json').read_text(encoding='utf-8-sig'))
assert len(native)==23 and sum(x['diagrams'] for x in native)==32
assert all(not x.get('failure') and not x.get('messages') for x in native)
struct=json.loads((R/'revision/validacion_estructural.json').read_text(encoding='utf-8'))
assert struct['graph_errors']==0 and struct['project_models']==23
assert len(PdfReader(str(R/'DIAGRAMAS_ACTIVIDAD_CORREGIDOS.pdf')).pages)==32
files=sorted(R.glob('DA_CU*.oom'))+sorted((R/'svg').glob('*.svg'))
files += [R/n for n in ['ACTIVIDAD_SIGH_CORREGIDOS.prj','DIAGRAMAS_ACTIVIDAD_CORREGIDOS.pdf','INFORME_REVISION.md','TRAZABILIDAD_ACTIVIDADES.csv','INDICE_DIAGRAMAS.html','LEEME.txt','_RESPALDO/ORIGINALES_2026-11-02.zip','revision/validacion_powerdesigner.json','revision/validacion_estructural.json']]
manifest={str(p.relative_to(R)).replace('\\','/'):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
out=R/'SIGH_ACTIVIDADES_REVISADAS.zip'
with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED) as z:
 for p in files:z.write(p,p.relative_to(R))
 z.writestr('MANIFIESTO_SHA256.json',json.dumps(manifest,ensure_ascii=False,indent=2))
with zipfile.ZipFile(out) as z:
 assert z.testzip() is None
 assert len([n for n in z.namelist() if n.endswith('.oom')])==23
 assert len([n for n in z.namelist() if n.endswith('.svg')])==32
 for n,digest in manifest.items():assert hashlib.sha256(z.read(n)).hexdigest()==digest
print(f'Paquete verificado: {len(files)} archivos finales y manifiesto; {out.stat().st_size:,} bytes')
