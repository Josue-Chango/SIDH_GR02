package ec.edu.chango.modelo;

import java.io.Serializable;

/**
 * Fila de la subtabla de Datos Académicos de un empleado
 * (tabla PEACA_ACADE del esquema de Personal).
 *
 * Una fila representa un estudio: nivel, institución y título.
 *
 * @author josue
 */
public class EmpleadoAcademico implements Serializable {

    private static final long serialVersionUID = 1L;

    /** Código generado por la base (PEACA_CODIGO). Solo lectura. */
    private int codigoAcademico;
    /** Nivel de estudio (PEACA_NIVEL). */
    private String nivel;
    /** Institución educativa (PEACA_INSTI). */
    private String institucion;
    /** Título obtenido (PEACA_TITUL). */
    private String titulo;

    public EmpleadoAcademico() {
    }

    public EmpleadoAcademico(String nivel, String institucion, String titulo) {
        this.nivel = nivel;
        this.institucion = institucion;
        this.titulo = titulo;
    }

    public int getCodigoAcademico() {
        return codigoAcademico;
    }

    public void setCodigoAcademico(int codigoAcademico) {
        this.codigoAcademico = codigoAcademico;
    }

    public String getNivel() {
        return nivel;
    }

    public void setNivel(String nivel) {
        this.nivel = nivel;
    }

    public String getInstitucion() {
        return institucion;
    }

    public void setInstitucion(String institucion) {
        this.institucion = institucion;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }
}
