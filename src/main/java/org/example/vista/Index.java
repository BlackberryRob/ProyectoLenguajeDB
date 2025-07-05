package org.example.vista;

import org.example.controlador.LibroDAO;
import org.example.modelo.LibroDisponible;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.List;

public class Index extends JFrame{
    private JPanel MainPanel;
    private JButton Salir;
    private JScrollPane LibrosDisponibles;
    LibroDAO dao = new LibroDAO();

    public Index (List<LibroDisponible> librosDisponibles, int userId){
        Salir.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                dispose();
            }
        });

        setContentPane(MainPanel); // Definir la ventana principal
        setTitle("Biblioteca"); // Ponerle título a la ventana
        setDefaultCloseOperation(EXIT_ON_CLOSE); // Cerrar la aplicación en el X
        setSize(400, 400); // Tamaño: ancho x alto
        setLocationRelativeTo(null); // Abrir en el centro
        setVisible(true); // Hacer visible la ventana

        // Configurar el panel principal dentro del JScrollPane
        JPanel contentPanel = new JPanel();
        contentPanel.setLayout(new BoxLayout(contentPanel, BoxLayout.Y_AXIS)); // Configuración vertical

        // Crear elementos para cada restaurante
        for (LibroDisponible libroDisponible : librosDisponibles) {
            JPanel libroPanel = new JPanel();
            libroPanel.setLayout(new FlowLayout(FlowLayout.CENTER)); // Alinear elementos al centro

            JLabel nombreLibro = new JLabel(libroDisponible.getTitulo());
            JButton solicitar = new JButton("Solicitar");
            solicitar.addActionListener(e -> {
                // Acción para el botón
                String idLibroDisponible = String.valueOf(libroDisponible.getId());
                int idLibroDisponibleInt = Integer.parseInt(idLibroDisponible);
                dao.realizarPrestamo(idLibroDisponibleInt, userId);
                dispose();
            });
            // Agregar elementos al panel del restaurante
            libroPanel.add(nombreLibro);
            libroPanel.add(solicitar);
            // Agregar el panel del restaurante al panel principal
            contentPanel.add(libroPanel);
        }
        // Agregar el panel principal al JScrollPane
        LibrosDisponibles.setViewportView(contentPanel);

    }


}
