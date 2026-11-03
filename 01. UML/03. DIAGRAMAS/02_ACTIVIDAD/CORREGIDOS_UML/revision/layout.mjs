import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
const require=createRequire('C:/Users/Usuario/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/');
const {instance}=require('@viz-js/viz');
const viz=await instance();
const root=path.resolve(import.meta.dirname,'..');
const data=JSON.parse(fs.readFileSync(path.join(root,'revision/flujos_corregidos.json'),'utf8'));
const wrap=(s,n=32)=>{let a=[],l='';for(const w of s.split(' ')){if((l+' '+w).trim().length>n){a.push(l);l=w;}else l=(l+' '+w).trim();}if(l)a.push(l);return a;};
const quote=s=>JSON.stringify(s);
const labelCounts=new Map();
for(const g of data)for(const n of g.nodes)if(n.kind==='action'){const k=g.cu+'|'+n.label;labelCounts.set(k,(labelCounts.get(k)||0)+1);}
for(const g of data){
 let dot='digraph G { graph [rankdir=TB,splines=ortho,nodesep=0.45,ranksep=0.5,pad=0.12,newrank=true,compound=true,forcelabels=true,bgcolor="white"]; node [fontname="Arial",fontsize=11,color="#334155",penwidth=1.1]; edge [fontname="Arial",fontsize=9,arrowsize=0.65,color="#334155"];\n';
 const anchors=[];
 for(let i=0;i<g.lanes.length;i++){
  dot+=`subgraph cluster_${i} { label=${quote(wrap(g.lanes[i],27).join('\n'))}; fontname="Arial"; fontsize=12; margin=25; `;
  dot+=`anchor_${i} [shape=point,width=0.01,height=0.01,label="",style=invis];\n`;anchors.push(`anchor_${i}`);
  for(const n of g.nodes.filter(n=>n.lane===i)){
   n.lines=wrap(n.label,n.kind==='decision'?25:34);
   if(n.kind==='action' && labelCounts.get(g.cu+'|'+n.label)>1)n.lines.unshift(`CU${String(g.cu).padStart(2,'0')}${g.suffix}`);
   let attrs=n.kind==='action'?`shape=box,style="rounded,filled",fillcolor="#eff6ff",width=2.9,height=${Math.max(.57,n.lines.length*.18+.20)}`:
    n.kind==='decision'?`shape=diamond,style=filled,fillcolor="#fff7ed",width=2.55,height=${Math.max(.8,n.lines.length*.29)}`:
    n.kind==='merge'?`shape=diamond,width=.22,height=.22,fixedsize=true`:
    n.kind==='end'?`shape=doublecircle,width=.23,height=.23,fixedsize=true,style=filled,fillcolor="#0f172a"`:
    `shape=circle,width=.20,height=.20,fixedsize=true,style=filled,fillcolor="#0f172a"`;
   dot+=`${n.id} [label=${quote(n.lines.join('\n'))},${attrs}];\n`;
  }
  dot+='}\n';
 }
 dot+=`{rank=same;${anchors.join(';')};}\n${anchors.join(' -> ')} [style=invis,weight=100];\n`;
 const order=Object.fromEntries(g.nodes.map((n,i)=>[n.id,i]));
 for(const [i,e] of g.edges.entries())dot+=`${e.source} -> ${e.target} [id="flow_${i}",xlabel=${quote(e.guard?'['+e.guard+']':'')}${order[e.source]>order[e.target]?',constraint=false':''}];\n`;
 dot+='}';
 g.layout=viz.renderJSON(dot);
 fs.writeFileSync(path.join(root,'revision',`layout_CU${String(g.cu).padStart(2,'0')}${g.suffix}.dot`),dot);
}
fs.writeFileSync(path.join(root,'revision/flujos_layout.json'),JSON.stringify(data,null,2));
console.log(`${data.length} diagramas distribuidos`);
