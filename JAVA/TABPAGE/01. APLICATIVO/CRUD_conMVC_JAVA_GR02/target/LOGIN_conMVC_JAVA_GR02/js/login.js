/**
 * Validaciones del formulario de inicio de sesión.
 * La validación definitiva se realiza en el servidor (LoginController).
 */
function validarLogin() {
    const usuario = document.getElementById("usuario");
    const password = document.getElementById("password");

    if (!usuario.value.trim()) {
        alert("Por favor, ingrese su usuario.");
        usuario.focus();
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
