import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import {FileBlob,PresentationFile} from '@oai/artifact-tool';
import edit from './editar_reportes.mjs';

const ROOT=path.dirname(fileURLToPath(import.meta.url));
const SOURCE='C:/Users/Usuario/Desktop/Web Avanzada/Sigh_02/SIDH_GR02/JAVA/REPORTES/02. DOCUMENTACION/LOGIN_CRUD_JAVA_MYSQL_GR02_FINAL.pptx';
const SKILL='C:/Users/Usuario/.codex/plugins/cache/openai-primary-runtime/presentations/26.1123.11515/skills/presentations';
const PYTHON='C:/Program Files/WindowsApps/OpenAI.CodexPrimaryRuntime.v26-1123-915-0_26.1123.915.0_x64__3k8sg7r9htsxt/dependencies/python/python.exe';
process.env.RUNTIME_NODE_MODULES='C:/Program Files/WindowsApps/OpenAI.CodexPrimaryRuntime.v26-1123-915-0_26.1123.915.0_x64__3k8sg7r9htsxt/dependencies/node/node_modules';
const BUILD=path.join(ROOT,'build');
const OUT=path.join(ROOT,'salida');
await fs.mkdir(BUILD,{recursive:true});await fs.mkdir(OUT,{recursive:true});
const candidate=path.join(BUILD,'candidate.pptx');
if(!process.argv.includes('--finalize-only')){
const presentation=await PresentationFile.importPptx(await FileBlob.load(SOURCE));
const cover=presentation.slides.getItem(0);
function named(n){const s=cover.shapes.items.find(s=>s.name===n);if(!s)throw Error(n);return s;}
named('TextBox 18').text='REPORTES PDF DEL SISTEMA SIGH';
named('TextBox 21').text='JasperReports 7.0.8 con Java MVC y MySQL';
named('TextBox 22').text='PROYECTO GRUPO 02\nREPORTES DE LOS MÓDULOS\nY FICHA DEL EMPLEADO';
cover.speakerNotes.text='Reportes implementados en el proyecto CRUD_conMVC_JAVA_GR02. Portada institucional, logotipos y datos de la asignatura proceden de la plantilla proporcionada por el usuario.';
for(const phase of ['structure','fundamentals','studio-dept-cargo','filter-employees-ficha','details-results','closing']){
 console.log(JSON.stringify(await edit({presentation,input:{phase}})));
}
const check=await presentation.inspect({select:'$.slides[*]',include:['id','index','title','elements.id','elements.kind','elements.name','elements.text','elements.position','elements.style','notes.text']});
await fs.writeFile(path.join(BUILD,'contenido.ndjson'),check.ndjson);
for(let i=0;i<presentation.slides.items.length;i++){
 const slide=presentation.slides.getItem(i);
 const png=await presentation.export({slide,format:'png',scale:1});
 await fs.writeFile(path.join(BUILD,`slide-${i+1}.png`),new Uint8Array(await png.arrayBuffer()));
 const layout=await slide.export({format:'layout'});
 await fs.writeFile(path.join(BUILD,`slide-${i+1}.layout.json`),await layout.text());
 console.log('Diapositiva renderizada: '+(i+1));
}
await (await PresentationFile.exportPptx(presentation)).save(candidate);
console.log('Candidato exportado: '+candidate);
}
const {finalizePresentation}=await import(pathToFileURL(path.join(SKILL,'container_tools/artifact_tool_utils.mjs')).href);
const finalPath=path.join(OUT,'REPORTES_JAVA_MYSQL_GR02.pptx');
const sourceSha=createHash('sha256').update(await fs.readFile(SOURCE)).digest('hex');
const result=await finalizePresentation({
 workspaceDir:ROOT,candidatePath:candidate,finalPath,
 explicitTotalSlideCount:16,
 requiredNativeTableOwnerSlides:[],requiredNativeChartOwnerSlides:[],
 pythonExecutable:PYTHON,
 integrityValidatorPath:path.join(SKILL,'container_tools/inspect_presentation_package_integrity.py'),
 layoutValidatorPath:path.join(SKILL,'container_tools/inspect_presentation_layout_geometry.py'),
 layoutArgs:['--expected-slide-size-emu','18288000,10287000','--validate-bullet-geometry','--validate-heading-fit'],
 fontPolicy:{basis:'reference',families:['Arial','Calibri (MS)','Calibri (MS) Bold','Calibri (MS) Italics','Courier New'],referencePath:SOURCE,referenceSha256:sourceSha},
 verifyArtifactToolImport:true,
 receiptPath:path.join(BUILD,'validacion.json')
});
console.log(JSON.stringify(result));
