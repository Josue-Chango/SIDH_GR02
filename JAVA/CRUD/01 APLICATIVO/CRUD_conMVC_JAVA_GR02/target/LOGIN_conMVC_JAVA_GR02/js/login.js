/**
 * Validaciones del formulario de inicio de sesión.
 * La validación definitiva se realiza en el servidor (LoginController).
 */
function validarLogin() {
    const identificacion = document.getElementById("identificacion");
    const password = document.getElementById("password");

    if (!identificacion.value.trim()) {
        alert("Por favor, ingrese su cédula, correo o pasaporte.");
        identificacion.focus();
        return false;
    }

    if (!password.value) {
        alert("Por favor, ingrese su contraseña.");
        password.focus();
        return false;
    }

    if (password.value.length > 16) {
        alert("La contraseña no puede superar los 16 caracteres.");
        password.focus();
        return false;
    }

    return true;
}
