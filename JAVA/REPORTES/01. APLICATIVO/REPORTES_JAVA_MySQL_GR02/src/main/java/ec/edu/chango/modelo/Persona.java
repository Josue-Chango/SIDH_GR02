package ec.edu.chango.modelo;

import java.io.Serializable;
import java.util.Date;

/**
 * Modelo de la entidad PERSONA (tabla PEPER_PERSO del diagrama de Seguridad).
 *
 * @author josue
 */
public class Persona implements Serializable {

    private static final long serialVersionUID = 1L;

    private String codigoPersona;
    private String apellidosPersona;
    private String nombresPersona;
    private Date fecNacimiento;
    private String cedula;
    private String pasaporte;
    private String email;
    private double cargasFam;
    private String foto;
    private String discapacidad;

    public Persona() {
    }

    public String getCodigoPersona() {
        return codigoPersona;
    }

    public void setCodigoPersona(String codigoPersona) {
        this.codigoPersona = codigoPersona;
    }

    public String getApellidosPersona() {
        return apellidosPersona;
    }

    public void setApellidosPersona(String apellidosPersona) {
        this.apellidosPersona = apellidosPersona;
    }

    public String getNombresPersona() {
        return nombresPersona;
    }

    public void setNombresPersona(String nombresPersona) {
        this.nombresPersona = nombresPersona;
    }

    public Date getFecNacimiento() {
        return fecNacimiento;
    }

    public void setFecNacimiento(Date fecNacimiento) {
        this.fecNacimiento = fecNacimiento;
    }

    public String getCedula() {
        return cedula;
    }

    public void setCedula(String cedula) {
        this.cedula = cedula;
    }

    public String getPasaporte() {
        return pasaporte;
    }

    public void setPasaporte(String pasaporte) {
        this.pasaporte = pasaporte;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public double getCargasFam() {
        return cargasFam;
    }

    public void setCargasFam(double cargasFam) {
        this.cargasFam = cargasFam;
    }

    public String getFoto() {
        return foto;
    }

    public void setFoto(String foto) {
        this.foto = foto;
    }

    public String getDiscapacidad() {
        return discapacidad;
    }

    public void setDiscapacidad(String discapacidad) {
        this.discapacidad = discapacidad;
    }
}
