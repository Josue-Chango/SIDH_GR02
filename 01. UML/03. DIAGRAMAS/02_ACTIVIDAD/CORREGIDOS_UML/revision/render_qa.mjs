import fs from 'node:fs';import path from 'node:path';import {createRequire} from 'node:module';
const require=createRequire('C:/Users/Usuario/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/');
const sharp=require('sharp');const root=path.resolve(import.meta.dirname,'..');
const data=JSON.parse(fs.readFileSync(path.join(root,'revision/diagramas_publicados.json'),'utf8'));
const out=path.join(root,'revision/svg_png');fs.mkdirSync(out,{recursive:true});
for(const g of data){
 const p=path.join(out,path.basename(g.svg_file,'.svg')+'.png');
 await sharp(path.join(root,g.svg_file),{density:120}).png().toFile(p);
}
const thumbW=500,thumbH=800;
for(let start=0;start<data.length;start+=4){
 const comps=[];
 for(let k=0;k<4&&start+k<data.length;k++){
  const g=data[start+k];const buf=await sharp(path.join(out,path.basename(g.svg_file,'.svg')+'.png')).resize(thumbW,thumbH,{fit:'contain',background:'white'}).png().toBuffer();
  comps.push({input:buf,left:k*thumbW,top:0});
 }
 await sharp({create:{width:thumbW*4,height:thumbH,channels:3,background:'#cbd5e1'}}).composite(comps).png().toFile(path.join(root,'revision',`contacto_svg_${start/4+1}.png`));
}
console.log('Renderizados 32 SVG y 8 hojas de inspección');
