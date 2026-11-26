const BASE = 'C:/Users/Usuario/Desktop/Web Avanzada/Sigh_02/SIDH_GR02/JAVA/TABPAGE/01. APLICATIVO/CRUD_conMVC_JAVA_GR02/.documentacion-reportes/imagenes/';
const PROJECT = 'C:/Users/Usuario/Desktop/Web Avanzada/Sigh_02/SIDH_GR02/JAVA/REPORTES/01. APLICATIVO/CRUD_conMVC_JAVA_GR02/';
import {readFileSync} from 'node:fs';
const BLUE = '#1F3864', GRAY = '#595959';
const FONT = 'Calibri (MS)', BOLD = 'Calibri (MS) Bold';
const nav = ['INTRODUCCIÓN','OBJETIVOS','MARCO TEÓRICO','PARTE PRÁCTICA','DEPENDENCIAS Y MVC','PLANTILLAS EN STUDIO','DEPARTAMENTOS','CARGOS Y FILTROS','EMPLEADOS','FICHA INDIVIDUAL','PRUEBAS Y RESULTADOS','CONCLUSIONES','RECOMENDACIONES','BIBLIOGRAFÍA'];
const active = [[0],[0],[1],[2],[3,4],[3,5],[3,6],[3,7],[3,7],[3,8],[3,9],[3,9],[3,10],[11],[12],[13]];

function byName(slide,name){const x=slide.shapes.items.find(x=>x.name===name);if(!x)throw Error('No existe '+name);return x;}
function title(slide,text){byName(slide,'TextBox 12').text=text;}
function rich(shape,head,body,{headingSize=32,bodySize=29.33,alignment='left'}={}){
  shape.text.style={insets:0,autoFit:'none',wrap:'square',alignment,verticalAlignment:'top'};
  shape.text=[
    {spaceAfter:400,runs:[{run:head,style:{bold:true,fontSize:headingSize+'px',typeface:BOLD,color:BLUE}}]},
    {runs:[{run:body,style:{bold:false,fontSize:bodySize+'px',typeface:FONT,color:GRAY}}]}
  ];
}
function bodyText(slide,name,text,position,{size=28,color=GRAY,bold=false,align='left'}={}){
  const shape=slide.shapes.add({name,geometry:'textbox',position,fill:'none',line:{fill:'none',width:0}});
  shape.text=text;
  shape.text.style={typeface:bold?BOLD:FONT,fontSize:size,bold,color,alignment:align,verticalAlignment:'top',autoFit:'none',wrap:'square',insets:0};
  return shape;
}
function textBlock(slide,name,head,body,position,opts={}){
  const shape=bodyText(slide,name,'',position,opts);rich(shape,head,body,opts);return shape;
}
function image(slide,name,file,position){return slide.images.add({blob:new Uint8Array(readFileSync(BASE+file+'.png')),contentType:'image/png',fit:'contain',position,alt:name});}
function notes(slide,files,extra=''){
  slide.speakerNotes.text='Fuentes del proyecto: '+files.map(x=>PROJECT+x).join('\n')+(extra?'\n'+extra:'');
}
function navigation(slide,index){
  const shape=slide.shapes.items.find(s=>s.position.left>1490&&s.name.startsWith('TextBox'));
  if(!shape)throw Error('No existe el índice lateral');
  shape.text.style={insets:0,wrap:'square',alignment:'left',verticalAlignment:'top',autoFit:'none'};
  shape.text=nav.map((name,i)=>({spaceAfter:200,runs:[{
    run:(i>=4&&i<=10?'\u2002\u2002':'')+(active[index].includes(i)?'✓  ':'□  ')+name,
    style:{typeface:BOLD,bold:true,fontSize:(i>=4&&i<=10?'20px':'22.67px'),color:active[index].includes(i)?'#FFC000':'#FFFFFF'}
  }]}));
}
function evidenceBase(slide,heading,footer){
  title(slide,heading);
  const keep=new Set(['Freeform 3','Freeform 5','Freeform 7','Freeform 9','Freeform 11','TextBox 12','Freeform 14','Freeform 28','Freeform 30','TextBox 31']);
  for(const shape of [...slide.shapes.items]){
    if(shape.position.left>1490&&shape.name.startsWith('TextBox'))continue;
    if(!keep.has(shape.name))shape.delete();
  }
  for(const im of [...slide.images.items])im.delete();
  const f=byName(slide,'TextBox 31');f.text=footer;
  f.text.style={typeface:BOLD,fontSize:26.67,bold:true,color:'#FFFFFF',alignment:'center',verticalAlignment:'middle',insets:0,wrap:'square'};
}

export default async function edit({presentation,input}){
  const phase=input.phase;
  if(phase==='structure'){
    if(presentation.slides.items.length!==11)throw Error('La estructura ya fue modificada');
    const template=presentation.slides.getItem(5).copy();
    for(let i=0;i<5;i++)presentation.slides.addCopy(template).moveTo(6+i);
    for(let i=1;i<16;i++)navigation(presentation.slides.getItem(i),i);
    return {slides:presentation.slides.items.length};
  }
  if(phase==='fundamentals'){
    const s2=presentation.slides.getItem(1);
    const blocks=[
      ['TextBox 34','Contexto del proyecto','Reportes PDF de Departamentos, Cargos y Empleados integrados al aplicativo Java MVC.'],
      ['TextBox 35','Documentos generados','Tres listados y una ficha individual con fotografía, estudios, familiares y firmas.'],
      ['TextBox 36','Acceso desde el sistema','Botones en bienvenida y en cada módulo. El controlador requiere una sesión activa.'],
      ['TextBox 37','Diseño de los reportes','Encabezado hospitalario, usuario, fecha, totales y numeración de páginas.']
    ];
    blocks.forEach(([name,head,body])=>rich(byName(s2,name),head,body));
    byName(s2,'Freeform 32').delete();
    textBlock(s2,'Acceso a reportes','Reportes PDF en la bienvenida','Los enlaces abren cada documento en una pestaña nueva.',{left:818.84,top:290,width:600,height:140});
    image(s2,'Accesos a reportes desde la bienvenida','bienvenida-reportes',{left:818.84,top:460,width:617,height:355});
    bodyText(s2,'Alcance del reporte','El PDF utiliza los datos guardados en MySQL al momento de generarlo.',{left:818.84,top:865,width:600,height:130},{size:29.33});
    notes(s2,['src/main/java/ec/edu/chango/vista/bienvenida.jsp','src/main/java/ec/edu/chango/controlador/ReporteController.java']);

    const s3=presentation.slides.getItem(2);
    rich(byName(s3,'TextBox 18'),'OBJETIVO GENERAL','Implementar reportes PDF con JasperReports para los módulos del sistema SIGH GR02 y la ficha del empleado, reutilizando el patrón MVC, la sesión y la conexión a MySQL.');
    byName(s3,'TextBox 26').text='Generar los listados de Departamentos, Cargos y Empleados con sus totales.';
    byName(s3,'TextBox 34').text='Integrar la ficha del empleado con fotografía y subreportes académicos y familiares.';
    byName(s3,'TextBox 42').text='Aplicar un diseño hospitalario editable en Jaspersoft Studio y verificar los PDF.';
    notes(s3,['src/main/webapp/WEB-INF/reportes/','src/main/java/ec/edu/chango/util/ReportesJasper.java']);

    const s4=presentation.slides.getItem(3);
    const terms=[
      ['TextBox 22','JasperReports','Motor 7.0.8 que compila las plantillas y genera los documentos PDF.'],
      ['TextBox 29','Plantillas JRXML','Archivos editables con consultas, parámetros, campos y bandas del reporte.'],
      ['TextBox 36','Jaspersoft Studio','Editor visual que permite modificar el diseño y revisar su vista previa.'],
      ['TextBox 43','JDBC y MySQL','La conexión existente proporciona los datos de la base sigh_gr02.'],
      ['TextBox 50','Subreportes','La ficha incorpora los estudios y familiares mediante dos diseños independientes.'],
      ['TextBox 57','Salida PDF','El navegador muestra el documento para consultarlo, guardarlo o imprimirlo.']
    ];
    terms.forEach(([name,h,b])=>rich(byName(s4,name),h,b,{headingSize:32,bodySize:25.33,alignment:'center'}));
    notes(s4,['pom.xml','src/main/java/ec/edu/chango/util/ReportesJasper.java','src/main/webapp/WEB-INF/reportes/']);

    const s5=presentation.slides.getItem(4);
    title(s5,'4.1 IMPLEMENTACIÓN DE JASPERREPORTS');
    [['TextBox 20','Vista JSP'],['TextBox 25','Reporte\nController'],['TextBox 30','Reportes\nJasper'],['TextBox 35','JDBC / MySQL'],['TextBox 40','PDF']].forEach(([n,t])=>byName(s5,n).text=t);
    rich(byName(s5,'TextBox 43'),'ReporteController','Valida la sesión. Recibe el tipo de reporte, el departamento o el código del empleado.',{headingSize:30,bodySize:25.33});
    rich(byName(s5,'TextBox 46'),'ReportesJasper','Compila los JRXML, llena los datos y exporta el PDF. Mantiene una caché por despliegue.',{headingSize:30,bodySize:25.33});
    rich(byName(s5,'TextBox 49'),'ConexionBD','Reutiliza la conexión a sigh_gr02. Los reportes de personal consultan peper_perso.',{headingSize:30,bodySize:25.33});
    const f=byName(s5,'TextBox 56');f.text='JasperReports 7.0.8\njasperreports, jasperreports-pdf, jasperreports-fonts y jasperreports-jdt';
    f.text.style={fontSize:26.67,typeface:BOLD,bold:true,color:'#FFFFFF',alignment:'left'};
    for(const sh of [...s5.shapes.items])if(sh.position.top>=890&&sh.position.left<1463)sh.delete();
    bodyText(s5,'Parámetros del controlador','r = departamentos, cargos, empleados o ficha\nFiltros: departamento y codigo',{left:95,top:920,width:1310,height:100},{size:28,color:BLUE});
    notes(s5,['pom.xml','src/main/java/ec/edu/chango/controlador/ReporteController.java','src/main/java/ec/edu/chango/util/ReportesJasper.java','src/main/java/ec/edu/chango/util/ConexionBD.java']);
    return{updated:[2,3,4,5]};
  }
  if(phase==='studio-dept-cargo'){
    const studio=presentation.slides.getItem(5);
    evidenceBase(studio,'4.2 PLANTILLAS EN JASPERSOFT STUDIO','Diseños editables en src/main/webapp/WEB-INF/reportes/');
    image(studio,'Diseño real de departamentos en Jaspersoft Studio','studio-diseno',{left:80,top:278,width:710,height:608});
    textBlock(studio,'Plantillas de los módulos','Seis diseños JRXML','departamentos.jrxml\ncargos.jrxml\nempleados.jrxml\nempleado_ficha.jrxml\nempleado_academicos.jrxml\nempleado_familiares.jrxml',{left:835,top:295,width:560,height:315},{headingSize:32,bodySize:27});
    textBlock(studio,'Edición del diseño','Diseño hospitalario','Azul oscuro y verde petróleo.\nFilas alternadas y totales.\nUsuario, fecha y páginas.',{left:835,top:645,width:550,height:190},{headingSize:32,bodySize:28});
    notes(studio,['src/main/webapp/WEB-INF/reportes/'],'Jaspersoft Studio instalado en C:/Users/Usuario/Desktop/Web Avanzada/jaspersoftstudio. Para editar se utiliza File > Open File y la pestaña Design.');

    const dep=presentation.slides.getItem(6);
    evidenceBase(dep,'4.3 REPORTE DE DEPARTAMENTOS','departamentos.pdf con código, descripción y total de registros');
    image(dep,'Reporte PDF de departamentos generado desde MySQL','departamentos-1',{left:80,top:285,width:820,height:620});
    image(dep,'Botón de reporte en el módulo de departamentos','departamentos-interfaz',{left:950,top:290,width:455,height:263});
    textBlock(dep,'Datos del reporte de departamentos','Siete departamentos','Consulta PEDEP_DEPAR.\nOrdena por código.\nMuestra el total al final.',{left:950,top:600,width:455,height:220},{headingSize:32,bodySize:29.33});
    notes(dep,['src/main/webapp/WEB-INF/reportes/departamentos.jrxml','src/main/java/ec/edu/chango/vista/departamento.jsp'],'La captura corresponde a la verificación local de la base actual, con siete registros.');

    const cargo=presentation.slides.getItem(7);
    evidenceBase(cargo,'4.4 REPORTE DE CARGOS','Diecinueve cargos en siete departamentos y dos páginas de reporte');
    image(cargo,'Primera página del reporte general de cargos','cargos-1',{left:65,top:260,width:485,height:645});
    image(cargo,'Segunda página del reporte general y total de cargos','cargos-2',{left:550,top:260,width:485,height:645});
    textBlock(cargo,'Agrupación y clave compuesta','Agrupación por departamento','Código del departamento y del cargo.\nDescripción del cargo.\nSubtotal de cada grupo.\nTotal general de 19.',{left:1070,top:330,width:335,height:480},{headingSize:30,bodySize:28});
    notes(cargo,['src/main/webapp/WEB-INF/reportes/cargos.jrxml'],'Las dos páginas provienen del reporte general generado desde MySQL. La clave departamento/cargo distingue los códigos que se repiten en departamentos distintos.');
    return{updated:[6,7,8]};
  }
  if(phase==='filter-employees-ficha'){
    const filter=presentation.slides.getItem(8);
    evidenceBase(filter,'4.5 CARGOS POR DEPARTAMENTO','El PDF conserva el filtro seleccionado en el módulo de cargos');
    image(filter,'Filtro Medicina con cuatro cargos en la interfaz','cargos-filtro',{left:70,top:285,width:665,height:390});
    image(filter,'PDF filtrado del departamento Medicina','cargos-pdf-navegador',{left:775,top:285,width:635,height:458});
    textBlock(filter,'Uso del filtro','Departamento 001 Medicina','La pantalla muestra cuatro cargos y habilita el reporte del departamento seleccionado.',{left:80,top:705,width:630,height:170},{headingSize:30,bodySize:28});
    bodyText(filter,'Parámetro del filtro','departamento=001\nSubtotal y total general: 4',{left:790,top:773,width:610,height:100},{size:28,color:BLUE});
    notes(filter,['src/main/webapp/WEB-INF/reportes/cargos.jrxml','src/main/java/ec/edu/chango/controlador/ReporteController.java','src/main/java/ec/edu/chango/vista/cargo.jsp']);

    const emp=presentation.slides.getItem(9);
    evidenceBase(emp,'4.6 REPORTE DE EMPLEADOS','empleados.pdf con los tres registros de la base actual');
    image(emp,'Listado PDF de empleados de la base actual','empleados-1',{left:80,top:325,width:875,height:470});
    image(emp,'Accesos al listado y a la ficha PDF de cada empleado','empleados-interfaz',{left:990,top:290,width:420,height:185});
    textBlock(emp,'Información del listado','Datos del empleado','Código y nombre completo.\nFecha de nacimiento.\nSexo y estado civil.\nTotal de empleados.',{left:990,top:525,width:420,height:300},{headingSize:32,bodySize:28});
    notes(emp,['src/main/webapp/WEB-INF/reportes/empleados.jrxml','src/main/java/ec/edu/chango/vista/empleado.jsp'],'Consulta peper_perso con los catálogos PEGEN_GENERO y PEESC_ESTCIV.');

    const ficha=presentation.slides.getItem(10);
    evidenceBase(ficha,'4.7 FICHA INDIVIDUAL DEL EMPLEADO','La ficha utiliza los datos guardados del empleado seleccionado');
    image(ficha,'Ficha PDF con fotografía y datos generales','ficha-general',{left:80,top:280,width:900,height:597});
    textBlock(ficha,'Código del empleado','Empleado P000000001','Código, apellidos y nombres.\nFotografía local.\nNacimiento, sexo y estado civil.\nPeso y tipo de sangre.',{left:1020,top:335,width:380,height:370},{headingSize:31,bodySize:28});
    bodyText(ficha,'Nombre del archivo de la ficha','Ficha PDF desde el listado\no desde la ficha guardada.',{left:1020,top:745,width:380,height:110},{size:28,color:BLUE});
    notes(ficha,['src/main/webapp/WEB-INF/reportes/empleado_ficha.jrxml','src/main/java/ec/edu/chango/controlador/ReporteController.java'],'La tabla real es peper_perso y el identificador es el código de persona, por ejemplo P000000001. El controlador valida existencia y fotografía.');
    return{updated:[9,10,11]};
  }
  if(phase==='details-results'){
    const detail=presentation.slides.getItem(11);
    evidenceBase(detail,'4.8 SUBREPORTES Y FIRMAS','Dos subreportes vinculados mediante el parámetro EMPLEADO');
    image(detail,'Datos académicos familiares y firmas de la ficha PDF','ficha-detalles',{left:80,top:320,width:900,height:495});
    textBlock(detail,'Datos académicos','Datos académicos','Nivel, institución y título.\nTabla PEACA_ACADE.',{left:1020,top:300,width:380,height:170},{headingSize:31,bodySize:28});
    textBlock(detail,'Datos familiares','Datos familiares','Parentesco, nombres y nacimiento.\nTabla PEFAM_FAMIL.',{left:1020,top:505,width:380,height:190},{headingSize:31,bodySize:28});
    textBlock(detail,'Firmas de la ficha','Firmas','Empleado y responsable al final del documento.',{left:1020,top:735,width:380,height:135},{headingSize:31,bodySize:28});
    notes(detail,['src/main/webapp/WEB-INF/reportes/empleado_academicos.jrxml','src/main/webapp/WEB-INF/reportes/empleado_familiares.jrxml','src/main/webapp/WEB-INF/reportes/empleado_ficha.jrxml'],'Los subreportes admiten textos extensos y continuaciones. Las firmas se ubican después del detalle.');

    const result=presentation.slides.getItem(12);
    title(result,'4.9 PRUEBAS Y RESULTADOS');
    const tests=[['TextBox 20','Compilación'],['TextBox 25','Tildes y\nfuentes'],['TextBox 30','Totales'],['TextBox 35','Filtro por\ndepartamento'],['TextBox 40','Ficha con\nfotografía'],['TextBox 45','Sin detalles'],['TextBox 50','Texto extenso'],['TextBox 55','Subreportes'],['TextBox 60','PDF válido']];
    tests.forEach(([n,t])=>byName(result,n).text=t);
    byName(result,'TextBox 63').text='Diez pruebas sin fallos ni errores';
    byName(result,'TextBox 66').text='RESULTADOS CON LA BASE MYSQL ACTUAL';
    [['TextBox 73','7 departamentos'],['TextBox 80','19 cargos en total'],['TextBox 87','4 cargos de Medicina'],['TextBox 94','3 empleados'],['TextBox 101','Ficha con subreportes'],['TextBox 108','PDF con paginación']].forEach(([n,t])=>byName(result,n).text=t);
    notes(result,['src/test/java/ec/edu/chango/util/ReportesJasperTest.java','.build/validacion-diseno-final.log','target/reportes-mysql/'],'Diez pruebas ejecutadas sin fallos ni errores en la validación del diseño final. Los conteos provienen de las consultas de la base MySQL actual.');
    return{updated:[12,13]};
  }
  if(phase==='closing'){
    const conclusion=presentation.slides.getItem(13);
    rich(byName(conclusion,'TextBox 20'),'Reportes integrados al aplicativo','Los módulos generan sus listados PDF y la ficha individual desde los botones del sistema, utilizando la sesión y la conexión existentes.');
    rich(byName(conclusion,'TextBox 25'),'Información completa y filtros coherentes','El listado de cargos conserva el departamento seleccionado. La ficha reúne la fotografía y los detalles académicos y familiares.');
    rich(byName(conclusion,'TextBox 30'),'Diseños editables y verificación','Las seis plantillas JRXML mantienen los datos de cada reporte. La validación del diseño final completó diez pruebas sin fallos ni errores.');
    notes(conclusion,['src/main/java/ec/edu/chango/controlador/ReporteController.java','src/main/java/ec/edu/chango/util/ReportesJasper.java','.build/validacion-diseno-final.log']);

    const rec=presentation.slides.getItem(14);
    rich(byName(rec,'TextBox 20'),'Edición en Jaspersoft Studio','Modificar los JRXML de WEB-INF/reportes y conservar sus parámetros, consultas y campos cuando el cambio sea únicamente de presentación.');
    rich(byName(rec,'TextBox 25'),'Guardado y nuevo despliegue','Guardar el diseño y ejecutar Clean and Build y Run en NetBeans. El despliegue renueva la caché de plantillas del servidor.');
    rich(byName(rec,'TextBox 30'),'Comprobación de los documentos','Revisar el filtro de cargos, la fotografía, los registros sin detalles y los textos extensos. Confirmar totales, firmas y páginas.');
    notes(rec,['src/main/java/ec/edu/chango/util/ReportesJasper.java','src/test/java/ec/edu/chango/util/ReportesJasperTest.java','src/main/webapp/WEB-INF/reportes/']);

    const bib=presentation.slides.getItem(15);
    const refs=[
      ['TextBox 18','Grupo 02. (2026).\nCRUD_CONMVC_JAVA_GR02.\nCapítulo Reportes PDF con JasperReports en SIGH GR02.'],
      ['TextBox 21','Grupo 02. (2026).\nCRUD_conMVC_JAVA_GR02.\nReporteController.java, ReportesJasper.java y configuración pom.xml.'],
      ['TextBox 24','Plantillas del aplicativo.\nDepartamentos, Cargos, Empleados y ficha individual.\nSubreportes empleado_academicos.jrxml y empleado_familiares.jrxml.'],
      ['TextBox 27','Evidencia de implementación.\nReportesJasperTest y registro de validación del diseño final.\nPDF generados desde la base sigh_gr02.']
    ];
    refs.forEach(([n,t])=>byName(bib,n).text=t);
    notes(bib,['pom.xml','src/main/java/ec/edu/chango/controlador/ReporteController.java','src/main/java/ec/edu/chango/util/ReportesJasper.java','src/main/webapp/WEB-INF/reportes/','src/test/java/ec/edu/chango/util/ReportesJasperTest.java'],'Documentación: C:/Users/Usuario/Desktop/Web Avanzada/Sigh_02/SIDH_GR02/JAVA/REPORTES/02. DOCUMENTACION/CRUD_CONMVC_JAVA_GR02.docx');
    return{updated:[14,15,16]};
  }
  throw Error('Fase desconocida');
}
