const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const script = fs.readFileSync(path.join(__dirname, "../../main/webapp/js/tabpage.js"), "utf8");

function formulario(fotoInicial = "/resource/foto-anterior.jpg") {
    const lectores = [];
    const cabeceras = [];
    const imagenes = [];
    let cambio;
    const entrada = {
        files: [], validity: "",
        setCustomValidity(mensaje) { this.validity = mensaje; },
        addEventListener(evento, callback) { if (evento === "change") cambio = callback; }
    };
    const imagen = {
        src: fotoInicial, style: { display: fotoInicial ? "inline-block" : "none" },
        getAttribute() { return fotoInicial; }
    };
    const marcador = { style: { display: fotoInicial ? "none" : "" } };
    const estado = { textContent: "" };
    const elementos = { tpFotoInput: entrada, tpFotoImg: imagen, tpFotoSf: marcador, tpFotoEstado: estado };
    vm.runInNewContext(script, {
        document: { querySelectorAll: () => [], getElementById: id => elementos[id] },
        FileReader: class {
            constructor() { lectores.push(this); }
            readAsDataURL() {}
            readAsArrayBuffer() { cabeceras.push(this); }
        },
        Image: class { constructor() { imagenes.push(this); } }
    });
    function leerSeleccion(indice, datos, firma = [137, 80, 78, 71, 13, 10, 26, 10]) {
        cabeceras[indice].onload({ target: { result: new Uint8Array(firma).buffer } });
        lectores.at(-1).onload({ target: { result: datos } });
    }
    return {
        entrada, imagen, marcador, estado, lectores, imagenes, cabeceras, leerSeleccion,
        seleccionar(archivo) { entrada.files = archivo ? [archivo] : []; cambio(); },
        completar(indice, datos, firma) {
            leerSeleccion(indice, datos, firma);
            imagenes.at(-1).onload();
        }
    };
}

const png = { name: "foto.png", type: "image/png", size: 2000, slice() { return this; } };

test("seleccionar una foto muestra la nueva vista previa y recuerda guardar", () => {
    const f = formulario("");
    f.seleccionar(png);
    f.completar(0, "data:image/png;base64,nueva");
    assert.equal(f.imagen.src, "data:image/png;base64,nueva");
    assert.equal(f.imagen.style.display, "inline-block");
    assert.equal(f.marcador.style.display, "none");
    assert.match(f.estado.textContent, /Guarde la ficha/);
    assert.equal(f.entrada.validity, "");
});

test("fotos mayores que 5 MB y formatos no admitidos impiden guardar", () => {
    const f = formulario();
    f.seleccionar({ ...png, size: 5 * 1024 * 1024 + 1 });
    assert.match(f.entrada.validity, /5 MB/);
    assert.equal(f.lectores.length, 0);
    f.seleccionar({ ...png, type: "application/pdf", name: "documento.pdf" });
    f.cabeceras[0].onload({ target: { result: new Uint8Array([37, 80, 68, 70]).buffer } });
    assert.match(f.entrada.validity, /JPG o PNG/);
    assert.equal(f.imagen.src, "/resource/foto-anterior.jpg");
});

test("imagen dañada conserva la foto anterior y presenta un error", () => {
    const f = formulario();
    f.seleccionar(png);
    f.leerSeleccion(0, "data:image/png;base64,danada");
    f.imagenes[0].onerror();
    assert.match(f.entrada.validity, /dañada o incompleta/);
    assert.equal(f.imagen.src, "/resource/foto-anterior.jpg");
});

test("quitar la selección restaura la foto guardada", () => {
    const f = formulario();
    f.seleccionar(png);
    f.completar(0, "data:image/png;base64,nueva");
    f.seleccionar(null);
    assert.equal(f.imagen.src, "/resource/foto-anterior.jpg");
    assert.equal(f.entrada.validity, "");
    assert.equal(f.estado.textContent, "");
});

test("al elegir dos imágenes rápidamente solo se muestra la última", () => {
    const f = formulario();
    f.seleccionar(png);
    f.leerSeleccion(0, "data:image/png;base64,primera");
    f.seleccionar(png);
    f.completar(1, "data:image/png;base64,segunda");
    f.imagenes[0].onload();
    assert.equal(f.imagen.src, "data:image/png;base64,segunda");
});

test("JPEG con extensión JFIF y MIME genérico se acepta por su firma", () => {
    const f = formulario();
    f.seleccionar({ ...png, name: "perfil.jfif", type: "application/octet-stream" });
    f.completar(0, "data:application/octet-stream;base64,nueva", [255, 216, 255, 224]);
    assert.equal(f.imagen.src, "data:image/jpeg;base64,nueva");
    assert.equal(f.entrada.validity, "");
});

test("WebP renombrado a jpg explica el formato y cómo convertirlo", () => {
    const f = formulario();
    f.seleccionar({ ...png, name: "perfil.jpg", type: "image/jpeg" });
    f.cabeceras[0].onload({ target: { result: Uint8Array.from(Buffer.from("RIFF1234WEBPVP8 ")).buffer } });
    assert.match(f.entrada.validity, /WebP/);
    assert.match(f.estado.textContent, /Paint/);
    assert.equal(f.imagenes.length, 0);
});

test("HEIC renombrado a jpg también informa el formato verdadero", () => {
    const f = formulario();
    f.seleccionar({ ...png, name: "perfil.jpg", type: "image/jpeg" });
    f.cabeceras[0].onload({ target: { result: Uint8Array.from(Buffer.from("0000ftypheic0000")).buffer } });
    assert.match(f.entrada.validity, /HEIC\/AVIF/);
    assert.equal(f.imagen.src, "/resource/foto-anterior.jpg");
});

test("archivo seleccionado vacío no se confunde con no cambiar la foto", () => {
    const f = formulario();
    f.seleccionar({ ...png, size: 0 });
    f.cabeceras[0].onload({ target: { result: new ArrayBuffer(0) } });
    assert.match(f.entrada.validity, /archivo vacío/);
});
