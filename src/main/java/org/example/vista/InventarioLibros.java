package org.example.vista;

import org.example.controlador.LibroDAO;
import org.example.modelo.LibroDisponible;

import javax.swing.*;
import java.awt.*;
import java.util.List;

public class InventarioLibros extends JFrame {
    private JPanel mainPanel;
    private JButton regresarButton;
    private JScrollPane inventarioLibros;
    private JPanel panelScroll; // Panel para contener los libros

    LibroDAO dao = new LibroDAO();

    public InventarioLibros(List<LibroDisponible> librosDisponibles) {
        setTitle("Biblioteca");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(500, 450);
        setLocationRelativeTo(null);

        mainPanel = new JPanel(new BorderLayout());
        panelScroll = new JPanel();
        panelScroll.setLayout(new BoxLayout(panelScroll, BoxLayout.Y_AXIS));
        panelScroll.setBackground(Color.WHITE);

        // Crear el botón regresar
        regresarButton = new JButton("Regresar");
        regresarButton.addActionListener(e -> {
            new Index(); // Abrir ventana Index
            dispose();   // Cerrar actual
        });

        // Agregar los libros al panel
        for (LibroDisponible libro : librosDisponibles) {
            JPanel libroPanel = new JPanel();
            libroPanel.setLayout(new BoxLayout(libroPanel, BoxLayout.Y_AXIS));
            libroPanel.setBackground(Color.WHITE);
            libroPanel.setBorder(BorderFactory.createCompoundBorder(
                    BorderFactory.createLineBorder(Color.LIGHT_GRAY, 2),
                    BorderFactory.createEmptyBorder(10, 10, 10, 10)
            ));

            JLabel id = new JLabel("ID: " + libro.getId());
            JLabel titulo = new JLabel("Título: " + libro.getTitulo());
            JLabel fecha = new JLabel("Fecha de publicación: " + libro.getFechaPublicacion());
            JLabel autores = new JLabel("Autor(es): " + libro.getAutores());
            JLabel categorias = new JLabel("Categoría(s): " + libro.getCategorias());
            JLabel disponible = new JLabel("Disponible: " + (libro.isDisponible() ? "Sí" : "No"));

            // Fuente para todos los labels
            Font font = new Font("Segoe UI", Font.PLAIN, 14);
            for (JLabel lbl : new JLabel[]{titulo, id, fecha, autores, categorias, disponible}) {
                lbl.setFont(font);
                libroPanel.add(lbl);
            }

            panelScroll.add(libroPanel);
            panelScroll.add(Box.createVerticalStrut(3)); // Espacio entre libros
        }

        // ScrollPane que contiene el panelScroll
        inventarioLibros = new JScrollPane(panelScroll);
        inventarioLibros.setBorder(BorderFactory.createTitledBorder("Inventario de libros"));
        inventarioLibros.getVerticalScrollBar().setUnitIncrement(16);

        // Agregar componentes al mainPanel
        mainPanel.add(inventarioLibros, BorderLayout.CENTER);
        mainPanel.add(regresarButton, BorderLayout.SOUTH);

        // Mostrar ventana
        setContentPane(mainPanel);
        setVisible(true);
    }
}
