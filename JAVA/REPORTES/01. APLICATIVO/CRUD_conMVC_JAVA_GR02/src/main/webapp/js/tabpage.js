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
        entradaFoto.addEventListener("change", function () {
            var imagen = document.getElementById("tpFotoImg");
            var marcador = document.getElementById("tpFotoSf");
            if (!entradaFoto.files || !entradaFoto.files[0]) return;
            var lector = new FileReader();
            lector.onload = function (evento) {
                if (imagen) {
                    imagen.src = evento.target.result;
                    imagen.style.display = "inline-block";
                }
                if (marcador) marcador.style.display = "none";
            };
            lector.readAsDataURL(entradaFoto.files[0]);
        });
    }
})();
