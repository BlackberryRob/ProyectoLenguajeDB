package org.example.vista;

import org.example.controlador.CompraLibroDAO;
import org.example.modelo.CompraLibro;
import org.example.modelo.LibroDisponible;

import javax.swing.*;
import java.awt.*;
import java.util.List;

public class HistorialCompras extends JFrame{
    private JPanel mainPanel;
    private JScrollPane historialCompras;
    private JButton regresarButton;

    CompraLibroDAO compraLibroDAO = new CompraLibroDAO();

    public HistorialCompras (List<CompraLibro> comprasLibro){
        setTitle("Biblioteca");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(500, 450);
        setLocationRelativeTo(null);

        regresarButton.addActionListener(e -> {Index index = new Index();});
        regresarButton.addActionListener(e -> dispose());

        JPanel contentPanel = new JPanel();
        contentPanel.setLayout(new BoxLayout(contentPanel, BoxLayout.Y_AXIS));
        contentPanel.setBackground(Color.WHITE);

        for (CompraLibro compraLibro : comprasLibro) {
            JPanel compraPanel = new JPanel();
            compraPanel.setLayout(new BoxLayout(compraPanel, BoxLayout.X_AXIS));
            compraPanel.setBackground(Color.WHITE);
            compraPanel.setBorder(BorderFactory.createCompoundBorder(
                    BorderFactory.createLineBorder(Color.LIGHT_GRAY, 1),
                    BorderFactory.createEmptyBorder(10, 10, 10, 10)
            ));

            JLabel idCompra = new JLabel(String.valueOf(compraLibro.getIdCompra()));
            idCompra.setFont(new Font("Segoe UI", Font.PLAIN, 14));
            JLabel nombrelibro = new JLabel(compraLibro.getTitulo());
            nombrelibro.setFont(new Font("Segoe UI", Font.PLAIN, 14));
            JLabel proveedor = new JLabel(compraLibro.getProveedor());
            proveedor.setFont(new Font("Segoe UI", Font.PLAIN, 14));
            JLabel Precio = new JLabel(String.valueOf(compraLibro.getPrecio()));
            Precio.setFont(new Font("Segoe UI", Font.PLAIN, 14));
            JLabel fecha = new JLabel(compraLibro.getFechaCompra());
            fecha.setFont(new Font("Segoe UI", Font.PLAIN, 14));


            compraPanel.add(idCompra);
            compraPanel.add(Box.createHorizontalGlue());
            compraPanel.add(nombrelibro);
            compraPanel.add(Box.createHorizontalGlue());
            compraPanel.add(proveedor);
            compraPanel.add(Box.createHorizontalGlue());
            compraPanel.add(Precio);
            compraPanel.add(Box.createHorizontalGlue());
            compraPanel.add(fecha);
            compraPanel.add(Box.createHorizontalGlue());

            contentPanel.add(compraPanel);
            contentPanel.add(Box.createVerticalStrut(10)); // Espacio entre compras
        }

        // ScrollPane con título y scroll suave
        historialCompras.setBorder(BorderFactory.createTitledBorder("Libros Disponibles"));
        historialCompras.setViewportView(contentPanel);
        historialCompras.getVerticalScrollBar().setUnitIncrement(16);

        // Establecer el panel principal
        setContentPane(mainPanel);
        setVisible(true);
    }
}
