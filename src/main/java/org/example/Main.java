package org.example;

import org.example.controlador.LibroDAO;
import org.example.vista.Index;

import javax.swing.*;

public class Main {
    public static void main(String[] args) {

        LibroDAO dao = new LibroDAO();
        int id = Integer.parseInt(JOptionPane.showInputDialog(null,"Ingrese su id"));
        Index index = new Index(dao.obtenerLibrosDisponibles(),id);

    }
}