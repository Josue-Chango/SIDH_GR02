package ec.edu.chango.modelo;

public class DatosEncuesta {

    private String nombre;
    private String apellido;
    private String[] progLeng;
    private String foto;

    public DatosEncuesta() {
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }

    public String[] getProgLeng() {
        return progLeng;
    }

    public void setProgLeng(String[] progLeng) {
        this.progLeng = progLeng;
    }

    public String getFoto() {
        return foto;
    }

    public void setFoto(String foto) {
        this.foto = foto;
    }
}