package ec.edu.chango.util;

/**
 * Utilidades para mostrar texto de forma segura en las páginas JSP.
 *
 * @author josue
 */
public final class Html {

    private Html() {
    }

    /**
     * Escapa los caracteres especiales de HTML.
     *
     * @param valor texto a escapar.
     * @return texto seguro para insertar en el HTML.
     */
    public static String escape(Object valor) {
        if (valor == null) {
            return "";
        }
        return String.valueOf(valor)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
