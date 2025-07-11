package org.example.vista;

import org.example.controlador.CompraLibroDAO;
import org.example.controlador.DevolucionDAO;
import org.example.controlador.LibroDAO;
import org.example.controlador.SancionDAO;
import org.example.modelo.LibroDisponible;

import javax.swing.*;
import java.awt.*;
import java.util.List;

public class Index extends JFrame{
    private JPanel mainPanel;
    private JButton agregarLibroButton;
    private JButton comprasButton;
    private JButton todosLoLibrosButton;
    private JButton devoluciónButton;
    private JButton sanciónButton;
    private JScrollPane librosDisponiblesPanel;
    private JLabel Bienvenido;
    private JPanel panelLibrosDisponibles;
    private JPanel panelInventario;
    private JPanel panelAcciones;
    LibroDAO dao = new LibroDAO();

    public Index(List<LibroDisponible> librosDisponibles) {
        // Configurar ventana
        setTitle("Biblioteca");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(660, 450);
        setLocationRelativeTo(null);

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
                try {
                    String inputBbtc = JOptionPane.showInputDialog(null, "Ingrese id de bibliotecario (1-50)");
                    String inputUsr = JOptionPane.showInputDialog(null, "Ingrese su id");

                    if (inputBbtc == null || inputUsr == null) {
                        // Cancelado por el usuario
                        Index index = new Index(dao.obtenerLibrosDisponibles());
                        return;
                    }

                    int idBbtc = Integer.parseInt(inputBbtc.trim());
                    int idUsr = Integer.parseInt(inputUsr.trim());

                    if (idBbtc < 1 || idBbtc > 50) {
                        JOptionPane.showMessageDialog(null, "⚠️ El id del bibliotecario debe estar entre 1 y 50.",
                                "ID inválido", JOptionPane.WARNING_MESSAGE);
                        Index index = new Index(dao.obtenerLibrosDisponibles());
                        return;

                    }

                    if (idUsr <= 0) {
                        JOptionPane.showMessageDialog(null, "⚠️ El id del usuario debe ser un número positivo.",
                                "ID inválido", JOptionPane.WARNING_MESSAGE);
                        Index index = new Index(dao.obtenerLibrosDisponibles());
                        return;
                    }

                    int idLibroDisponibleInt = libroDisponible.getId();
                    dao.realizarPrestamo(idLibroDisponibleInt, idUsr, idBbtc);
                    Index index = new Index(dao.obtenerLibrosDisponibles());
                    dispose();

                } catch (NumberFormatException ex) {
                    JOptionPane.showMessageDialog(null, "❌ Ingrese solo números válidos para los IDs.",
                            "Error de formato", JOptionPane.ERROR_MESSAGE);
                    Index index = new Index(dao.obtenerLibrosDisponibles());
                } catch (Exception ex) {
                    JOptionPane.showMessageDialog(null, "❌ Ocurrió un error inesperado.\nDetalles: " + ex.getMessage(),
                            "Error", JOptionPane.ERROR_MESSAGE);
                    ex.printStackTrace();
                    Index index = new Index(dao.obtenerLibrosDisponibles());
                }
            });

            libroPanel.add(nombreLibro);
            libroPanel.add(Box.createHorizontalGlue());
            libroPanel.add(solicitar);

            contentPanel.add(libroPanel);
            contentPanel.add(Box.createVerticalStrut(10)); // Espacio entre libros
        }

        // ScrollPane con título y scroll suave
        librosDisponiblesPanel.setViewportView(contentPanel);
        librosDisponiblesPanel.getVerticalScrollBar().setUnitIncrement(16);


        agregarLibroButton.addActionListener(e -> {
            AgregarLibro agregarLibro = new AgregarLibro();
        });
        agregarLibroButton.addActionListener(e -> dispose());

        Bienvenido.setFont(new Font("Segoe UI", Font.BOLD, 20));
        Bienvenido.setAlignmentX(Component.CENTER_ALIGNMENT);
        Bienvenido.setForeground(new Color(33, 37, 41));

        mainPanel.setBorder(BorderFactory.createTitledBorder("Menu Principal"));
        panelLibrosDisponibles.setBorder(BorderFactory.createTitledBorder("Libros Disponibles"));

        panelInventario.setBorder(BorderFactory.createTitledBorder("Inventario"));
        panelAcciones.setBorder(BorderFactory.createTitledBorder("Acciones"));

        todosLoLibrosButton.addActionListener(e -> {
            LibroDAO dao = new LibroDAO();
            InventarioLibros inventarioLibros1 = new InventarioLibros(dao.obtenerInventarioLibros());
        });
        todosLoLibrosButton.addActionListener(e -> dispose());

        comprasButton.addActionListener(e -> {
            CompraLibroDAO dao = new CompraLibroDAO();
            HistorialCompras historialCompras = new HistorialCompras(dao.obtenerComprasLibros());
        });

        comprasButton.addActionListener(e -> dispose());

        devoluciónButton.addActionListener(e -> {
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

        sanciónButton.addActionListener(e -> {
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



        setContentPane(mainPanel);
        setVisible(true);
    }
}
