package org.example.modelo;

public class CompraLibro {
    private int idCompra;
    private String titulo;
    private String proveedor;
    private double precio;
    private String fechaCompra;

    public CompraLibro(int idCompra, String titulo, String proveedor, double precio, String fechaCompra) {
        this.idCompra = idCompra;
        this.titulo = titulo;
        this.proveedor = proveedor;
        this.precio = precio;
        this.fechaCompra = fechaCompra;
    }

    // Getters y setters si los necesitas

    public int getIdCompra() {
        return idCompra;
    }

    public void setIdCompra(int idCompra) {
        this.idCompra = idCompra;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getProveedor() {
        return proveedor;
    }

    public void setProveedor(String proveedor) {
        this.proveedor = proveedor;
    }

    public double getPrecio() {
        return precio;
    }

    public void setPrecio(double precio) {
        this.precio = precio;
    }

    public String getFechaCompra() {
        return fechaCompra;
    }

    public void setFechaCompra(String fechaCompra) {
        this.fechaCompra = fechaCompra;
    }
}
