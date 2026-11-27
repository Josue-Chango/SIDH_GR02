package ec.edu.chango.modelo;

import java.io.Serializable;

/**
 * Par código/descripción de una tabla catálogo del esquema
 * (PEGEN_GENERO, PEESC_ESTCIV, ...). Se usa para llenar los
 * combobox de las vistas.
 *
 * @author josue
 */
public class Catalogo implements Serializable {

    private static final long serialVersionUID = 1L;

    private String codigo;
    private String descri;

    public Catalogo() {
    }

    public Catalogo(String codigo, String descri) {
        this.codigo = codigo;
        this.descri = descri;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getDescri() {
        return descri;
    }

    public void setDescri(String descri) {
        this.descri = descri;
    }
}
