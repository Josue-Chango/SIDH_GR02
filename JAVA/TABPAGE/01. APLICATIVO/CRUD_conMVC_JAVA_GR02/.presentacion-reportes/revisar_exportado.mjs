import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {FileBlob,PresentationFile} from '@oai/artifact-tool';
const root=path.dirname(fileURLToPath(import.meta.url));
const receipt=JSON.parse(await fs.readFile(path.join(root,'build/validacion.json'),'utf8'));
const file=path.join(root,'salida/REPORTES_JAVA_MYSQL_GR02.pptx');
const hash=createHash('sha256').update(await fs.readFile(file)).digest('hex');
if(hash!==receipt.finalSha256)throw Error('La versión final no coincide con la validación');
const deck=await PresentationFile.importPptx(await FileBlob.load(file));
if(deck.slides.items.length!==16)throw Error('Cantidad de diapositivas incorrecta');
const out=path.join(root,'build/roundtrip');await fs.mkdir(out,{recursive:true});
for(let i=0;i<16;i++){
 const slide=deck.slides.getItem(i);
 const png=await deck.export({slide,format:'png',scale:1});
 await fs.writeFile(path.join(out,`slide-${i+1}.png`),new Uint8Array(await png.arrayBuffer()));
}
const text=await deck.inspect({select:'$.slides[*]',include:['id','index','elements.text']});
await fs.writeFile(path.join(out,'texto.ndjson'),text.ndjson);
console.log(JSON.stringify({slides:16,sha256:hash,rendered:16}));
