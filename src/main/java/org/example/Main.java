package org.example;

public class Main {
    public static void main(String[] args) {

        LibroDAO dao = new LibroDAO();

        // Crear libro
        Libro libro = new Libro(52, "El Señor de los Anillos", "1954-07-29", true);
        dao.crearLibro(libro);

        // Leer libros
        System.out.println("Lista de libros:");
        dao.obtenerLibros().forEach(l ->
                System.out.println(l.getId() + " - " + l.getTitulo() + " - " + l.getFechaPublicacion())
        );

    }
}