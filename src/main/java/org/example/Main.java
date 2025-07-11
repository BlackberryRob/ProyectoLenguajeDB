package org.example;

import org.example.controlador.LibroDAO;
import org.example.vista.Index;

public class Main {
    public static void main(String[] args) {

        LibroDAO dao = new LibroDAO();
        Index index = new Index(dao.obtenerLibrosDisponibles());

    }
}