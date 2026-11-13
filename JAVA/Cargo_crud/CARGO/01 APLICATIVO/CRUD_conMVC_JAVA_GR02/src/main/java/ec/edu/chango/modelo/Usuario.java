package ec.edu.chango.modelo;

import java.io.Serializable;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Modelo de la entidad USUARIO (tabla XEUSU_USUAR del diagrama de Seguridad).
 *
 * La tabla del diagrama guarda la contraseña, el estado, la persona asociada y
 * las fechas de creación/modificación. La relación con PERSONA se resuelve
 * mediante el campo PEPER_CODIGO.
 *
 * @author josue
 */
public class Usuario implements Serializable {

    private static final long serialVersionUID = 1L;

    private String password;
    private String codEstado;
    private String descEstado;
    private Date fechaCrea;
    private Date fechaModi;
    private String piefirma;
    private Persona persona;
    private List<Perfil> perfiles = new ArrayList<>();

    public Usuario() {
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getCodEstado() {
        return codEstado;
    }

    public void setCodEstado(String codEstado) {
        this.codEstado = codEstado;
    }

    public String getDescEstado() {
        return descEstado;
    }

    public void setDescEstado(String descEstado) {
        this.descEstado = descEstado;
    }

    public Date getFechaCrea() {
        return fechaCrea;
    }

    public void setFechaCrea(Date fechaCrea) {
        this.fechaCrea = fechaCrea;
    }

    public Date getFechaModi() {
        return fechaModi;
    }

    public void setFechaModi(Date fechaModi) {
        this.fechaModi = fechaModi;
    }

    public String getPiefirma() {
        return piefirma;
    }

    public void setPiefirma(String piefirma) {
        this.piefirma = piefirma;
    }

    public Persona getPersona() {
        return persona;
    }

    public void setPersona(Persona persona) {
        this.persona = persona;
    }

    public List<Perfil> getPerfiles() {
        return perfiles;
    }

    public void setPerfiles(List<Perfil> perfiles) {
        this.perfiles = perfiles != null ? perfiles : new ArrayList<>();
    }

    /**
     * Devuelve el nombre completo de la persona asociada al usuario.
     *
     * @return nombres y apellidos, o una cadena vacía si no existe la persona.
     */
    public String getNombreCompleto() {
        if (persona == null) {
            return "";
        }
        String nombres = persona.getNombresPersona() != null ? persona.getNombresPersona() : "";
        String apellidos = persona.getApellidosPersona() != null ? persona.getApellidosPersona() : "";
        return (nombres + " " + apellidos).trim();
    }

    /**
     * Indica si el estado del usuario permite el acceso al sistema.
     *
     * El diagrama no define los códigos de estado, por eso se valida por la
     * descripción: se bloquean los estados INACTIVO, BLOQUEADO, SUSPENDIDO y
     * RETIRADO. Si no hay estado registrado se permite el acceso.
     *
     * @return true si el usuario puede iniciar sesión.
     */
    public boolean isActivo() {
        if (descEstado == null || descEstado.trim().isEmpty()) {
            return true;
        }
        String estado = Normalizer.normalize(descEstado, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toUpperCase();
        return !(estado.contains("INACTIV")
                || estado.contains("BLOQUE")
                || estado.contains("SUSPEND")
                || estado.contains("RETIRAD"));
    }
}
