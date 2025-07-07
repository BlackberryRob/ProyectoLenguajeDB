package org.example.vista;

import org.example.controlador.LibroDAO;
import org.example.modelo.LibroDisponible;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.List;

public class Index extends JFrame {
    private JPanel MainPanel;
    private JButton Salir;
    private JScrollPane LibrosDisponibles;
    LibroDAO dao = new LibroDAO();

    public Index(List<LibroDisponible> librosDisponibles, int userId) {
        // Configuraciones b�sicas de la ventana
        setTitle("Biblioteca");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(400, 400);
        setLocationRelativeTo(null);

        // Panel principal con BorderLayout
        MainPanel = new JPanel(new BorderLayout());

        // Panel para los libros con BoxLayout vertical
        JPanel contentPanel = new JPanel();
        contentPanel.setLayout(new BoxLayout(contentPanel, BoxLayout.Y_AXIS));

        // Bot�n para registrar devoluci�n
        JButton btnRegistrarDevolucion = new JButton("Registrar Devoluci�n");
        btnRegistrarDevolucion.setAlignmentX(Component.CENTER_ALIGNMENT);
        btnRegistrarDevolucion.addActionListener(e -> new FrmRegistrarDevolucion().setVisible(true));
        contentPanel.add(btnRegistrarDevolucion);
        contentPanel.add(Box.createRigidArea(new Dimension(0, 10)));

        // Bot�n para registrar sanci�n
        JButton btnRegistrarSancion = new JButton("Registrar Sanci�n");
        btnRegistrarSancion.setAlignmentX(Component.CENTER_ALIGNMENT);
        btnRegistrarSancion.addActionListener(e -> new FrmRegistrarSancion().setVisible(true));
        contentPanel.add(btnRegistrarSancion);
        contentPanel.add(Box.createRigidArea(new Dimension(0, 10)));

        // Lista din�mica de libros disponibles con bot�n solicitar
        for (LibroDisponible libroDisponible : librosDisponibles) {
            JPanel libroPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));

            JLabel nombreLibro = new JLabel(libroDisponible.getTitulo());
            JButton solicitar = new JButton("Solicitar");
            solicitar.addActionListener(e -> {
                int idLibroDisponibleInt = libroDisponible.getId();
                dao.realizarPrestamo(idLibroDisponibleInt, userId);
                dispose();
            });

            libroPanel.add(nombreLibro);
            libroPanel.add(solicitar);
            contentPanel.add(libroPanel);
        }

        // Bot�n Salir inicializado y agregado
        Salir = new JButton("Salir");
        Salir.setAlignmentX(Component.CENTER_ALIGNMENT);
        Salir.addActionListener(e -> dispose());
        contentPanel.add(Box.createRigidArea(new Dimension(0, 10)));
        contentPanel.add(Salir);

        // JScrollPane para libros y botones
        LibrosDisponibles = new JScrollPane(contentPanel);

        // Agregar el scroll pane al panel principal
        MainPanel.add(LibrosDisponibles, BorderLayout.CENTER);

        // Setear panel principal como contenido del JFrame
        setContentPane(MainPanel);

        // Hacer visible la ventana al final de la configuraci�n
        setVisible(true);
    }
}

