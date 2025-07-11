package org.example.modelo;

public class LibroDisponible {
    private int id;
    private String titulo;
    private String fechaPublicacion;
    private String autores;
    private String categorias;
    private boolean disponible;

    // Constructor sin "disponible" (para libros disponibles solamente)
    public LibroDisponible(int id, String titulo, String fechaPublicacion, String autores, String categorias) {
        this.id = id;
        this.titulo = titulo;
        this.fechaPublicacion = fechaPublicacion;
        this.autores = autores;
        this.categorias = categorias;
    }

    // Constructor con "disponible" (para inventario general)
    public LibroDisponible(int id, String titulo, String fechaPublicacion, String autores, String categorias, boolean disponible) {
        this.id = id;
        this.titulo = titulo;
        this.fechaPublicacion = fechaPublicacion;
        this.autores = autores;
        this.categorias = categorias;
        this.disponible = disponible;
    }


    // Getters y setters opcionales

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getFechaPublicacion() {
        return fechaPublicacion;
    }

    public void setFechaPublicacion(String fechaPublicacion) {
        this.fechaPublicacion = fechaPublicacion;
    }

    public String getAutores() {
        return autores;
    }

    public void setAutores(String autores) {
        this.autores = autores;
    }

    public String getCategorias() {
        return categorias;
    }

    public void setCategorias(String categorias) {
        this.categorias = categorias;
    }

    public boolean isDisponible() {
        return disponible;
    }

    public void setDisponible(boolean disponible) {
        this.disponible = disponible;
    }
}
