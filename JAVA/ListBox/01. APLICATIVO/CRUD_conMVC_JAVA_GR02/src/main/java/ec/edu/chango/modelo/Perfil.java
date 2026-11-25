package ec.edu.chango.modelo;

import java.io.Serializable;

/**
 * Modelo de la entidad PERFIL (tabla XEPER_PERFI del diagrama de Seguridad).
 *
 * @author josue
 */
public class Perfil implements Serializable {

    private static final long serialVersionUID = 1L;

    private String codPerfil;
    private String descPerfil;
    private String observacionesPerfil;

    public Perfil() {
    }

    public String getCodPerfil() {
        return codPerfil;
    }

    public void setCodPerfil(String codPerfil) {
        this.codPerfil = codPerfil;
    }

    public String getDescPerfil() {
        return descPerfil;
    }

    public void setDescPerfil(String descPerfil) {
        this.descPerfil = descPerfil;
    }

    public String getObservacionesPerfil() {
        return observacionesPerfil;
    }

    public void setObservacionesPerfil(String observacionesPerfil) {
        this.observacionesPerfil = observacionesPerfil;
    }
}
