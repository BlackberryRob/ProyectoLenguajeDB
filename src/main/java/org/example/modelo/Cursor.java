package org.example.modelo;

public class Cursor {
    private int idUsuarioPk;
    private String nombre;
    private String apellido;
    private String correo;
    private String telefono;

    // Constructor vacío
    public Cursor() {}

    // Constructor completo
    public Cursor(int idUsuarioPk, String nombre, String apellido, String correo, String telefono) {
        this.idUsuarioPk = idUsuarioPk;
        this.nombre = nombre;
        this.apellido = apellido;
        this.correo = correo;
        this.telefono = telefono;
    }

    // Getters y Setters
    public int getIdUsuarioPk() {
        return idUsuarioPk;
    }

    public void setIdUsuarioPk(int idUsuarioPk) {
        this.idUsuarioPk = idUsuarioPk;
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

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    // toString para depuración elegante
    @Override
    public String toString() {
        return "Usuario{" +
                "idUsuarioPk=" + idUsuarioPk +
                ", nombre='" + nombre + '\'' +
                ", apellido='" + apellido + '\'' +
                ", correo='" + correo + '\'' +
                ", telefono='" + telefono + '\'' +
                '}';
    }
}

