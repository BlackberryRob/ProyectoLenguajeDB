package org.example.vista;

import org.example.controlador.*;
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
    private JComboBox<String> listaUsuarios;
    private JPanel panelUsuarios;
    private JButton prestamosPendientes;
    private JComboBox<String> listaBiliotecarios;
    private JPanel panelBibliotecario;
    private JComboBox<String> devolucion;
    private JButton verSanciónButton;
    LibroDAO dao = new LibroDAO();

    public Index(List<LibroDisponible> librosDisponibles) {
        // Configurar ventana
        setTitle("Biblioteca");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(800, 600);
        setLocationRelativeTo(null);

        //panelLibrosDisponibles.setPreferredSize(new Dimension(500, 530));
        panelLibrosDisponibles.setMinimumSize(new Dimension(500, 500));

        cargarUsuarios();
        cargarBibliotecarios();

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
                    // Obtener los elementos seleccionados de los JComboBox
                    String seleccionadoUsuario = (String) listaUsuarios.getSelectedItem();
                    String seleccionadoBibliotecario = (String) listaBiliotecarios.getSelectedItem();

                    if (seleccionadoUsuario == null || seleccionadoUsuario.isEmpty()
                            || seleccionadoBibliotecario == null || seleccionadoBibliotecario.isEmpty()) {
                        JOptionPane.showMessageDialog(null, "⚠️ Debe seleccionar un usuario y un bibliotecario.");
                        return;
                    }

                    // Extraer los IDs antes del primer guion
                    String idUsrStr = seleccionadoUsuario.split("-")[0].trim();
                    String idBbtcStr = seleccionadoBibliotecario.split("-")[0].trim();

                    int idUsr = Integer.parseInt(idUsrStr);
                    int idBbtc = Integer.parseInt(idBbtcStr);


                    int idLibroDisponibleInt = libroDisponible.getId(); // Asegúrate de que esta variable está correctamente inicializada
                    dao.realizarPrestamo(idLibroDisponibleInt, idUsr, idBbtc);

                    Index index = new Index(dao.obtenerLibrosDisponibles());
                    dispose();

                } catch (NumberFormatException ex) {
                    JOptionPane.showMessageDialog(null, "❌ Error al leer los IDs seleccionados.",
                            "Error de formato", JOptionPane.ERROR_MESSAGE);
                } catch (Exception ex) {
                    JOptionPane.showMessageDialog(null, "❌ Ocurrió un error inesperado.\nDetalles: " + ex.getMessage(),
                            "Error", JOptionPane.ERROR_MESSAGE);
                    ex.printStackTrace();
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
        panelUsuarios.setBorder(BorderFactory.createTitledBorder("Usuarios"));
        panelBibliotecario.setBorder(BorderFactory.createTitledBorder("Bibliotecario"));

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
                String seleccionado = (String) devolucion.getSelectedItem();

                if (seleccionado == null || seleccionado.isEmpty()) {
                    JOptionPane.showMessageDialog(null, "⚠️ El usuario seleccionado no tiene pendientes.");
                    return;
                }

                // Extraer el ID despues del primer guion
                String idStr = seleccionado.split("-")[0].trim();
                int id = Integer.parseInt(idStr);

                DevolucionDAO ddao = new DevolucionDAO();
                ddao.registrarDevolucion(id);

                Index index = new Index(dao.obtenerLibrosDisponibles());
                dispose();

            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(null, "⚠️ ID inválido. Intente nuevamente.");
            }
        });

        sanciónButton.addActionListener(e -> {
            try {
                String seleccionado = (String) devolucion.getSelectedItem();

                if (seleccionado == null || seleccionado.isEmpty()) {
                    JOptionPane.showMessageDialog(null, "⚠️ El usuario seleccionado no tiene pendientes.");
                    return;
                }

                // Extraer el ID despues del primer guion
                String idStr = seleccionado.split("-")[1].trim();
                int id = Integer.parseInt(idStr);

                SancionDAO sdao = new SancionDAO();
                sdao.registrarSancion(id);

                Index index = new Index(dao.obtenerLibrosDisponibles());
                dispose();

            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(null, "⚠️ ID inválido. Intente nuevamente.");
            }
        });

        prestamosPendientes.addActionListener(e -> {
            try {
                String seleccionado = (String) listaUsuarios.getSelectedItem();

                if (seleccionado == null || seleccionado.isEmpty()) {
                    JOptionPane.showMessageDialog(null, "⚠️ No hay ningún usuario seleccionado.");
                    return;
                }

                // Extraer el ID antes del primer guion
                String idStr = seleccionado.split("-")[0].trim();
                int id = Integer.parseInt(idStr);

                CursorDAO udao = new CursorDAO();
                int resultado = udao.verPrestamos(id);

                JOptionPane.showMessageDialog(null, "El usuario " + id + " tiene: " + resultado + " préstamos sin devolver.");

            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(null, "⚠️ Error al leer el ID del usuario seleccionado.");
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(null, "❌ Ocurrió un error inesperado: " + ex.getMessage());
            }
        });

        verSanciónButton.addActionListener(e -> {
            try {
                String seleccionado = (String) devolucion.getSelectedItem();

                if (seleccionado == null || seleccionado.isEmpty()) {
                    JOptionPane.showMessageDialog(null, "⚠️ No ha seleccionado ningún préstamo.");
                    return;
                }

                // Extraer el ID antes del primer guion
                String idStr = seleccionado.split("-")[0].trim();
                int id = Integer.parseInt(idStr);

                CursorDAO udao = new CursorDAO();
                int resultado = udao.verSancion(id);


            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(null, "⚠️ Error al leer el ID de la devolucion seleccionada.");
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(null, "❌ Ocurrió un error inesperado: " + ex.getMessage());
            }
        });

        listaUsuarios.addActionListener(e -> {
            String seleccionado = (String) listaUsuarios.getSelectedItem();

            if (seleccionado != null && !seleccionado.isEmpty()) {
                try {
                    int idUsuario = Integer.parseInt(seleccionado.split("-")[0].trim());

                    CursorDAO dao = new CursorDAO();

                    // Préstamos pendientes
                    List<String> prestamos = dao.getPrestamosPorUsuario(idUsuario);
                    devolucion.removeAllItems();
                    for (String p : prestamos) {
                        devolucion.addItem(p);
                    }
                } catch (NumberFormatException ex) {
                    JOptionPane.showMessageDialog(null, "⚠️ Error al interpretar el ID del usuario.");
                }
            }
        });


        setContentPane(mainPanel);
        setVisible(true);
    }

    private void cargarUsuarios() {
        CursorDAO dao = new CursorDAO();
        List<String> usuarios = dao.getUsuarios();

        listaUsuarios.removeAllItems();
        for (String usuario : usuarios) {
            listaUsuarios.addItem(usuario);
        }
    }

    private void cargarBibliotecarios() {
        CursorDAO dao = new CursorDAO();
        List<String> usuarios = dao.getBibliotecarios();

        listaBiliotecarios.removeAllItems();
        for (String usuario : usuarios) {
            listaBiliotecarios.addItem(usuario);
        }
    }

}
