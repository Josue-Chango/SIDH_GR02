package ec.edu.chango.modelo;

import java.io.Serializable;

/**
 * Modelo de la entidad CARGO (tabla PECAR_CARGO del diagrama de Personal).
 *
 * La tabla almacena el código del cargo (PECAR_CODIGO, CHAR(3)), su
 * descripción (PECAR_DESCRI, VARCHAR(50)) y el código del departamento al que
 * pertenece (PEDEP_CODIGO, CHAR(3), llave foránea hacia PEDEP_DEPAR).
 *
 * La clave primaria es compuesta: (PEDEP_CODIGO, PECAR_CODIGO).
 *
 * @author josue
 */
public class Cargo implements Serializable {

    private static final long serialVersionUID = 1L;

    private String codigoDepart;
    private String codigoCargo;
    private String descriCargo;
    /** Descripción del departamento asociado, para mostrarla en pantalla. */
    private String descriDepart;

    public Cargo() {
    }

    public Cargo(String codigoDepart, String codigoCargo, String descriCargo) {
        this.codigoDepart = codigoDepart;
        this.codigoCargo = codigoCargo;
        this.descriCargo = descriCargo;
    }

    public String getCodigoDepart() {
        return codigoDepart;
    }

    public void setCodigoDepart(String codigoDepart) {
        this.codigoDepart = codigoDepart;
    }

    public String getCodigoCargo() {
        return codigoCargo;
    }

    public void setCodigoCargo(String codigoCargo) {
        this.codigoCargo = codigoCargo;
    }

    public String getDescriCargo() {
        return descriCargo;
    }

    public void setDescriCargo(String descriCargo) {
        this.descriCargo = descriCargo;
    }

    public String getDescriDepart() {
        return descriDepart;
    }

    public void setDescriDepart(String descriDepart) {
        this.descriDepart = descriDepart;
    }
}
