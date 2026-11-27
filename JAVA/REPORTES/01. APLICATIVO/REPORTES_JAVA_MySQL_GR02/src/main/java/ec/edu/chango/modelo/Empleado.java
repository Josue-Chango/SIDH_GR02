package ec.edu.chango.modelo;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Empleado del esquema de Personal (tabla peper_perso).
 *
 * Reúne la información de las tres pestañas del Tab Page:
 * - Marco de la ficha: código de persona, apellidos, nombres y foto.
 * - Datos Generales: sexo, peso, estado civil y tipo de sangre.
 * - Datos Académicos: subtabla PEACA_ACADE.
 * - Datos Familiares: subtabla PEFAM_FAMIL.
 *
 * @author josue
 */
public class Empleado implements Serializable {

    private static final long serialVersionUID = 1L;

    /** Código de persona (PEPER_CODIGO, hasta 10 caracteres; ej. P000000001). */
    private String codigo;
    /** Apellidos completos (PEPER_APELLI). */
    private String apellidos;
    /** Nombres completos (PEPER_NOMBRE). */
    private String nombres;
    /** Fecha de nacimiento (PEPER_FECNAC). */
    private LocalDate fechaNacimiento;
    /** Código de la pestaña Datos Generales: sexo (PEGEN_CODIGO). */
    private String codigoGenero;
    /** Descripción del sexo (catálogo PEGEN_GENERO). Solo lectura. */
    private String descriGenero;
    /** Código del estado civil (PEESC_CODIGO). */
    private String codigoEstadoCivil;
    /** Descripción del estado civil (catálogo PEESC_ESTCIV). Solo lectura. */
    private String descriEstadoCivil;
    /** Peso en kilogramos (PEPER_PESO). 0 significa sin dato. */
    private double peso;
    /** Tipo de sangre (PEPER_TIPSANG): O+, A-, ... */
    private String tipoSangre;
    /** Ruta relativa de la foto bajo /resource (PEPER_FOTO). */
    private String foto;
    /** Subtabla de Datos Académicos (PEACA_ACADE). */
    private List<EmpleadoAcademico> academicos = new ArrayList<>();
    /** Subtabla de Datos Familiares (PEFAM_FAMIL). */
    private List<EmpleadoFamiliar> familiares = new ArrayList<>();

    public Empleado() {
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
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

    public String getCodigoGenero() {
        return codigoGenero;
    }

    public void setCodigoGenero(String codigoGenero) {
        this.codigoGenero = codigoGenero;
    }

    public String getDescriGenero() {
        return descriGenero;
    }

    public void setDescriGenero(String descriGenero) {
        this.descriGenero = descriGenero;
    }

    public String getCodigoEstadoCivil() {
        return codigoEstadoCivil;
    }

    public void setCodigoEstadoCivil(String codigoEstadoCivil) {
        this.codigoEstadoCivil = codigoEstadoCivil;
    }

    public String getDescriEstadoCivil() {
        return descriEstadoCivil;
    }

    public void setDescriEstadoCivil(String descriEstadoCivil) {
        this.descriEstadoCivil = descriEstadoCivil;
    }

    public double getPeso() {
        return peso;
    }

    public void setPeso(double peso) {
        this.peso = peso;
    }

    public String getTipoSangre() {
        return tipoSangre;
    }

    public void setTipoSangre(String tipoSangre) {
        this.tipoSangre = tipoSangre;
    }

    public String getFoto() {
        return foto;
    }

    public void setFoto(String foto) {
        this.foto = foto;
    }

    public List<EmpleadoAcademico> getAcademicos() {
        return academicos;
    }

    public void setAcademicos(List<EmpleadoAcademico> academicos) {
        this.academicos = academicos == null ? new ArrayList<>() : academicos;
    }

    public List<EmpleadoFamiliar> getFamiliares() {
        return familiares;
    }

    public void setFamiliares(List<EmpleadoFamiliar> familiares) {
        this.familiares = familiares == null ? new ArrayList<>() : familiares;
    }
}
