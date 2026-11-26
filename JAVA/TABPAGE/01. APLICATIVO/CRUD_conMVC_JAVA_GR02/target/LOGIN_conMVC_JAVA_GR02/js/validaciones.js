function validarFormulario() {
    // Capturamos los elementos usando los NUEVOS nombres de tu form
    let nombre = document.querySelector('input[name="nombre"]').value;
    let apellido = document.querySelector('input[name="apellido"]').value;
    let lenguajes = document.querySelectorAll('input[name="progLeng"]');
    let foto = document.querySelector('input[name="foto"]').value;

    // Expresión regular para permitir solo letras y espacios
    let regexLetras = /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/;

    // 1. Validar Nombre
    if (nombre.trim() === "") {
        alert("Por favor, ingrese sus nombres.");
        return false; 
    } else if (!regexLetras.test(nombre)) {
        alert("El campo 'Nombres' no es válido. Solo se permiten letras.");
        return false;
    }

    // 2. Validar Apellido
    if (apellido.trim() === "") {
        alert("Por favor, ingrese sus apellidos.");
        return false;
    } else if (!regexLetras.test(apellido)) {
        alert("El campo 'Apellidos' no es válido. Solo se permiten letras.");
        return false;
    }

    // 3. Validar que al menos un checkbox esté seleccionado
    let lenguajeSeleccionado = false;
    for (let i = 0; i < lenguajes.length; i++) {
        if (lenguajes[i].checked) {
            lenguajeSeleccionado = true;
            break;
        }
    }
    
    if (!lenguajeSeleccionado) {
        alert("Por favor, seleccione al menos un lenguaje de programación.");
        return false;
    }

    // 4. Validar que se haya seleccionado un archivo (Foto)
    if (foto === "") {
        alert("Por favor, adjunte una foto.");
        return false;
    }

    // Si todo es correcto, permite enviar los datos al ServletController
    return true;
}