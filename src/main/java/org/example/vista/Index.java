package org.example.vista;

import org.example.controlador.CompraLibroDAO;
import org.example.controlador.DevolucionDAO;
import org.example.controlador.LibroDAO;
import org.example.controlador.SancionDAO;

import javax.swing.*;
import java.awt.*;

public class Index extends JFrame {
    private JPanel mainPanel;
    private JLabel Bienvenido;
    private JButton librosDisponiblesButton;
    private JButton AgregarLibroButton;
    private JButton registraDevolucionButton;
    private JButton inventarioLibros;
    private JButton registrarSancion;
    private JButton historialCompras;


    public Index() {

        // Configurar ventana
        setTitle("Biblioteca");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(450, 450);
        setLocationRelativeTo(null);


        Bienvenido.setFont(new Font("Segoe UI", Font.BOLD, 20));
        Bienvenido.setAlignmentX(Component.CENTER_ALIGNMENT);
        Bienvenido.setForeground(new Color(33, 37, 41));

        // Listeners
        librosDisponiblesButton.addActionListener(e -> {
            LibroDAO dao = new LibroDAO();

            try {
                String inputBbtc = JOptionPane.showInputDialog(null, "Ingrese id de bibliotecario (1-50)");
                String inputUsr = JOptionPane.showInputDialog(null, "Ingrese su id");

                if (inputBbtc == null || inputUsr == null) {
                    // Cancelado por el usuario
                    return;
                }

                int idBbtc = Integer.parseInt(inputBbtc.trim());
                int idUsr = Integer.parseInt(inputUsr.trim());

                if (idBbtc < 1 || idBbtc > 50) {
                    JOptionPane.showMessageDialog(null, "⚠️ El id del bibliotecario debe estar entre 1 y 50.",
                            "ID inválido", JOptionPane.WARNING_MESSAGE);
                    Index index = new Index();
                    return;

                }

                if (idUsr <= 0) {
                    JOptionPane.showMessageDialog(null, "⚠️ El id del usuario debe ser un número positivo.",
                            "ID inválido", JOptionPane.WARNING_MESSAGE);
                    Index index = new Index();
                    return;
                }

                VerLibrosDisponibles verLibrosDisponibles = new VerLibrosDisponibles(
                        dao.obtenerLibrosDisponibles(), idUsr, idBbtc);

            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(null, "❌ Ingrese solo números válidos para los IDs.",
                        "Error de formato", JOptionPane.ERROR_MESSAGE);
                Index index = new Index();
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(null, "❌ Ocurrió un error inesperado.\nDetalles: " + ex.getMessage(),
                        "Error", JOptionPane.ERROR_MESSAGE);
                ex.printStackTrace();
                Index index = new Index();
            }
        });


        librosDisponiblesButton.addActionListener(e -> dispose());

        inventarioLibros.addActionListener(e -> {
            LibroDAO dao = new LibroDAO();
            InventarioLibros inventarioLibros1 = new InventarioLibros(dao.obtenerInventarioLibros());
                });
        inventarioLibros.addActionListener(e -> dispose());

        historialCompras.addActionListener(e -> {
            CompraLibroDAO dao = new CompraLibroDAO();
            HistorialCompras historialCompras = new HistorialCompras(dao.obtenerComprasLibros());
        });

        historialCompras.addActionListener(e -> dispose());

        // Acción del botón Devolución
        registraDevolucionButton.addActionListener(e -> {
            try {
                int idDevolucion = Integer.parseInt(
                        JOptionPane.showInputDialog(null, "Ingrese el ID del préstamo")
                );
                DevolucionDAO ddao = new DevolucionDAO();

                try {
                    ddao.registrarDevolucion(idDevolucion);
                } catch (Exception ex) {
                    JOptionPane.showMessageDialog(null, "❌ Error al registrar la devolución:\n" + ex.getMessage());
                    ex.printStackTrace(); // Opcional: ayuda en desarrollo
                }
            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(null, "⚠️ ID inválido. Intente nuevamente.");
            }
        });

        registrarSancion.addActionListener(e -> {
            try {
                int idDevolucion = Integer.parseInt(
                        JOptionPane.showInputDialog(null, "Ingrese el ID de la devolución")
                );
                SancionDAO sdao = new SancionDAO();

                try {
                    sdao.registrarSancion(idDevolucion);
                } catch (Exception ex) {
                    JOptionPane.showMessageDialog(null, "❌ Error al registrar la devolución:\n" + ex.getMessage());
                    ex.printStackTrace(); // Opcional: ayuda en desarrollo
                }
            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(null, "⚠️ ID inválido. Intente nuevamente.");
            }
        });

        AgregarLibroButton.addActionListener(e -> {
            AgregarLibro agregarLibro = new AgregarLibro();
        });
        AgregarLibroButton.addActionListener(e -> dispose());

        mainPanel.setBorder(BorderFactory.createTitledBorder("Menu Principal"));

        setContentPane(mainPanel);
        setVisible(true);
    }
}
