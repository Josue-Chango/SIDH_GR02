/*
 * Comportamiento del Tab Page de Empleados:
 * 1) Cambio de pestañas (menú vertical de píldoras, como el .NET).
 * 2) Agregar/quitar filas de las subtablas (Datos Académicos y
 *    Datos Familiares).
 * 3) Vista previa de la foto del marco al elegir el archivo.
 */
(function () {
    "use strict";

    /* ---------- 1) Pestañas ---------- */
    var pildoras = document.querySelectorAll(".tp-pill");
    function activarPestana(pildora) {
        pildoras.forEach(function (otra) { otra.classList.remove("tp-activa"); });
        document.querySelectorAll(".tp-panel").forEach(function (panel) {
            panel.classList.remove("tp-activa");
        });
        pildora.classList.add("tp-activa");
        var panel = document.getElementById(pildora.dataset.panel);
        if (panel) panel.classList.add("tp-activa");
    }
    pildoras.forEach(function (pildora) {
        pildora.addEventListener("click", function () { activarPestana(pildora); });
    });

    /* ---------- 2) Subtablas (grillas editables) ---------- */
    function filaVacia(fila) {
        var campos = fila.querySelectorAll("input, select");
        for (var i = 0; i < campos.length; i++) {
            if (campos[i].value.trim() !== "") return false;
        }
        return true;
    }

    function agregarFilaDesdePlantilla(idPlantilla, cuerpo) {
        var plantilla = document.getElementById(idPlantilla);
        if (!plantilla) return;
        var fila = plantilla.content.firstElementChild.cloneNode(true);
        // La plantilla llega deshabilitada para que el navegador no la envíe.
        fila.querySelectorAll("input, select, button").forEach(function (campo) {
            campo.disabled = false;
        });
        cuerpo.appendChild(fila);
    }

    // Botones "+ Agregar ..." de cada subtabla.
    document.querySelectorAll(".tp-agregar").forEach(function (boton) {
        boton.addEventListener("click", function () {
            var cuerpo = document.getElementById(boton.dataset.grilla);
            if (!cuerpo) return;
            agregarFilaDesdePlantilla(boton.dataset.plantilla, cuerpo);
        });
    });

    // Quitar filas con delegación de eventos (funciona para filas nuevas).
    document.querySelectorAll("table.tp-grilla tbody").forEach(function (cuerpo) {
        cuerpo.addEventListener("click", function (evento) {
            var boton = evento.target.closest(".tp-quitar");
            if (!boton) return;
            evento.preventDefault();
            var filas = cuerpo.querySelectorAll("tr");
            if (filas.length === 1 && filaVacia(filas[0])) return; // Nunca dejar la grilla sin fila.
            boton.closest("tr").remove();
        });
    });

    // Al cargar, cada subtabla arranca con una fila vacía lista para usar.
    document.querySelectorAll("table.tp-grilla tbody").forEach(function (cuerpo) {
        if (cuerpo.querySelectorAll("tr").length === 0) {
            agregarFilaDesdePlantilla(cuerpo.dataset.plantilla, cuerpo);
        }
    });

    /* ---------- 3) Vista previa de la foto del marco ---------- */
    var entradaFoto = document.getElementById("tpFotoInput");
    if (entradaFoto) {
        var imagen = document.getElementById("tpFotoImg");
        var marcador = document.getElementById("tpFotoSf");
        var estadoFoto = document.getElementById("tpFotoEstado");
        var fotoInicial = imagen ? imagen.getAttribute("src") : "";
        var seleccion = 0;
        function estadoCarga(mensaje) {
            if (estadoFoto) estadoFoto.textContent = mensaje;
        }
        function restaurarFoto() {
            if (imagen) {
                imagen.src = fotoInicial;
                imagen.style.display = fotoInicial ? "inline-block" : "none";
            }
            if (marcador) marcador.style.display = fotoInicial ? "none" : "";
        }
        function errorFoto(mensaje) {
            entradaFoto.setCustomValidity(mensaje);
            estadoCarga(mensaje);
            restaurarFoto();
        }
        // La extensión y el MIME del navegador no garantizan el formato real.
        function formatoFoto(datos) {
            function firma(inicio, valores) {
                return valores.every(function (valor, i) { return datos[inicio + i] === valor; });
            }
            function texto(inicio, valor) {
                return firma(inicio, valor.split("").map(function (letra) { return letra.charCodeAt(0); }));
            }
            if (!datos.length) return { nombre: "un archivo vacío" };
            if (firma(0, [255, 216, 255])) return { nombre: "JPEG", mime: "image/jpeg" };
            if (firma(0, [137, 80, 78, 71, 13, 10, 26, 10])) return { nombre: "PNG", mime: "image/png" };
            if (texto(0, "RIFF") && texto(8, "WEBP")) return { nombre: "WebP" };
            if (texto(0, "GIF87a") || texto(0, "GIF89a")) return { nombre: "GIF" };
            if (texto(0, "BM")) return { nombre: "BMP" };
            if (texto(4, "ftyp")) {
                for (var i = 8; i + 4 <= datos.length; i += 4) {
                    if (i === 12) continue;
                    if (["heic", "heix", "hevc", "hevx", "mif1", "msf1", "avif", "avis"].some(function (marca) {
                        return texto(i, marca);
                    })) return { nombre: "HEIC/AVIF" };
                }
            }
            return { nombre: "un formato desconocido" };
        }
        entradaFoto.addEventListener("change", function () {
            var actual = ++seleccion;
            entradaFoto.setCustomValidity("");
            if (!entradaFoto.files || !entradaFoto.files[0]) {
                restaurarFoto();
                estadoCarga("");
                return;
            }
            var archivo = entradaFoto.files[0];
            if (archivo.size > 5 * 1024 * 1024) {
                errorFoto("La foto no puede superar 5 MB.");
                return;
            }
            estadoCarga("Cargando vista previa…");
            var cabecera = new FileReader();
            cabecera.onerror = function () {
                if (actual === seleccion) errorFoto("No se pudo leer la imagen. Vuelva a seleccionarla.");
            };
            cabecera.onload = function (eventoCabecera) {
                if (actual !== seleccion) return;
                var formato = formatoFoto(new Uint8Array(eventoCabecera.target.result));
                if (!formato.mime) {
                    errorFoto("La imagen no es un JPG o PNG válido: se detectó " + formato.nombre
                        + ". Ábrala en Paint y guárdela como JPEG o PNG.");
                    return;
                }
                var lector = new FileReader();
                lector.onload = function (evento) {
                    if (actual !== seleccion) return;
                    var previa = new Image();
                    previa.onload = function () {
                        if (actual !== seleccion) return;
                        if (imagen) {
                            imagen.src = previa.src;
                            imagen.alt = "Foto del empleado";
                            imagen.style.display = "inline-block";
                        }
                        if (marcador) marcador.style.display = "none";
                        estadoCarga("Vista previa lista. Guarde la ficha para aplicar la nueva foto.");
                    };
                    previa.onerror = function () {
                        if (actual === seleccion) errorFoto("Se detectó " + formato.nombre
                            + ", pero la imagen está dañada o incompleta. Guárdela de nuevo desde Paint.");
                    };
                    previa.src = evento.target.result.replace(/^data:[^;]*;base64,/, "data:" + formato.mime + ";base64,");
                };
                lector.onerror = function () {
                    if (actual === seleccion) errorFoto("No se pudo leer la imagen. Vuelva a seleccionarla.");
                };
                lector.readAsDataURL(archivo);
            };
            cabecera.readAsArrayBuffer(archivo.slice(0, 64));
        });
    }
})();
