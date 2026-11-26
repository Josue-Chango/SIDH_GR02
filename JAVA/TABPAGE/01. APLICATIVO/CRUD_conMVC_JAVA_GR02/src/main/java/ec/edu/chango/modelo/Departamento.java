package ec.edu.chango.modelo;

import java.io.Serializable;

/**
 * Modelo de la entidad DEPARTAMENTO (tabla PEDEP_DEPAR del diagrama de Personal).
 *
 * La tabla del diagrama almacena el código del departamento (PEDEP_CODIGO,
 * CHAR(3), clave primaria) y su descripción (PEDEP_DESCRI, VARCHAR(50)).
 *
 * @author josue
 */
public class Departamento implements Serializable {

    private static final long serialVersionUID = 1L;

    private String codigoDepart;
    private String descriDeparta;

    public Departamento() {
    }

    public Departamento(String codigoDepart, String descriDeparta) {
        this.codigoDepart = codigoDepart;
        this.descriDeparta = descriDeparta;
    }

    public String getCodigoDepart() {
        return codigoDepart;
    }

    public void setCodigoDepart(String codigoDepart) {
        this.codigoDepart = codigoDepart;
    }

    public String getDescriDeparta() {
        return descriDeparta;
    }

    public void setDescriDeparta(String descriDeparta) {
        this.descriDeparta = descriDeparta;
    }
}
