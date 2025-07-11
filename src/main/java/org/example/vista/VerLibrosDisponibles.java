package org.example.vista;

import org.example.controlador.DevolucionDAO;
import org.example.controlador.LibroDAO;
import org.example.modelo.LibroDisponible;
import org.example.vista.Index;

import javax.swing.*;
import java.awt.*;
import java.util.List;



public class VerLibrosDisponibles extends JFrame{


    private JPanel MainPanel;
    private JButton Salir;
    private JScrollPane LibrosDisponibles;
    LibroDAO dao = new LibroDAO();

    public VerLibrosDisponibles(List<LibroDisponible> librosDisponibles, int userId, int bibliotecarioId) {
        // Configuración básica de la ventana
        setTitle("Biblioteca");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(500, 450);
        setLocationRelativeTo(null);

        // Acción del botón Salir
        Salir.addActionListener(e -> {Index index = new Index();});
        Salir.addActionListener(e -> dispose());

        // Panel principal para los libros
        JPanel contentPanel = new JPanel();
        contentPanel.setLayout(new BoxLayout(contentPanel, BoxLayout.Y_AXIS));
        contentPanel.setBackground(Color.WHITE);

        for (LibroDisponible libroDisponible : librosDisponibles) {
            JPanel libroPanel = new JPanel();
            libroPanel.setLayout(new BoxLayout(libroPanel, BoxLayout.X_AXIS));
            libroPanel.setBackground(Color.WHITE);
            libroPanel.setBorder(BorderFactory.createCompoundBorder(
                    BorderFactory.createLineBorder(Color.LIGHT_GRAY, 1),
                    BorderFactory.createEmptyBorder(10, 10, 10, 10)
            ));

            JLabel nombreLibro = new JLabel(libroDisponible.getTitulo());
            nombreLibro.setFont(new Font("Segoe UI", Font.PLAIN, 14));

            JButton solicitar = new JButton("Solicitar");
            solicitar.setBackground(new Color(70, 130, 180));
            solicitar.setForeground(Color.WHITE);
            solicitar.setFocusPainted(false);
            solicitar.setFont(new Font("Arial", Font.BOLD, 12));

            solicitar.addActionListener(e -> {
                int idLibroDisponibleInt = libroDisponible.getId();
                dao.realizarPrestamo(idLibroDisponibleInt, userId, bibliotecarioId);
                Index index = new Index();
                dispose();
            });

            libroPanel.add(nombreLibro);
            libroPanel.add(Box.createHorizontalGlue());
            libroPanel.add(solicitar);

            contentPanel.add(libroPanel);
            contentPanel.add(Box.createVerticalStrut(10)); // Espacio entre libros
        }

        // ScrollPane con título y scroll suave
        LibrosDisponibles.setBorder(BorderFactory.createTitledBorder("Libros Disponibles"));
        LibrosDisponibles.setViewportView(contentPanel);
        LibrosDisponibles.getVerticalScrollBar().setUnitIncrement(16);

        // Establecer el panel principal
        setContentPane(MainPanel);
        setVisible(true);
    }


}