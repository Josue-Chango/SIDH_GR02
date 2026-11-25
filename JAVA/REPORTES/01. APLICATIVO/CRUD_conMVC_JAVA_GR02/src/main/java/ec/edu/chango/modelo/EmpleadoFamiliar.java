package ec.edu.chango.modelo;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * Fila de la subtabla de Datos Familiares de un empleado
 * (tabla PEFAM_FAMIL del esquema de Personal).
 *
 * Una fila representa un familiar: parentesco (persona),
 * apellidos y nombres, y fecha de nacimiento.
 *
 * @author josue
 */
public class EmpleadoFamiliar implements Serializable {

    private static final long serialVersionUID = 1L;

    /** Código generado por la base (PEFAM_CODIGO). Solo lectura. */
    private int codigoFamiliar;
    /** Parentesco o persona (PEFAM_PAREN): PADRE, MADRE, CONYUGE... */
    private String persona;
    /** Apellidos y nombres del familiar (PEFAM_NOMBRE). */
    private String nombres;
    /** Fecha de nacimiento del familiar (PEFAM_FECNAC). */
    private LocalDate fechaNacimiento;

    public EmpleadoFamiliar() {
    }

    public EmpleadoFamiliar(String persona, String nombres, LocalDate fechaNacimiento) {
        this.persona = persona;
        this.nombres = nombres;
        this.fechaNacimiento = fechaNacimiento;
    }

    public int getCodigoFamiliar() {
        return codigoFamiliar;
    }

    public void setCodigoFamiliar(int codigoFamiliar) {
        this.codigoFamiliar = codigoFamiliar;
    }

    public String getPersona() {
        return persona;
    }

    public void setPersona(String persona) {
        this.persona = persona;
    }

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    public LocalDate getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(LocalDate fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }
}
