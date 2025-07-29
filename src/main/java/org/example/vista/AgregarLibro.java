package org.example.vista;

import org.example.controlador.LibroDAO;
import org.example.controlador.CursorDAO;

import javax.swing.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class AgregarLibro extends JFrame{
    private JPanel mainPanel;
    private JButton agregarButton;
    private JButton regresarButton;
    private JTextField titulo;
    private JTextField fechaPublicacion;
    private JComboBox<String>  proveedor;
    private JTextField precio;
    private JComboBox<String> autor;
    private JComboBox<String> categoria;
    LibroDAO dao = new LibroDAO();

    public AgregarLibro() {
        setTitle("Biblioteca");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(500, 450);
        setLocationRelativeTo(null);

        cargarProveedores();
        cargarCategorias();
        cargarAutor();

        agregarButton.addActionListener(e -> {
            String tituloL = titulo.getText().trim();
            String fechaTexto = fechaPublicacion.getText().trim();
            String proveedorseleccionado = (String) proveedor.getSelectedItem();
            String idStr = proveedorseleccionado.split("-")[0].trim();
            String precioTexto = precio.getText().trim();
            String autorseleccionado = (String) autor.getSelectedItem();
            String idStr3 = autorseleccionado.split("-")[0].trim();
            String categoriaSeleccionada = (String) categoria.getSelectedItem();
            String idStr2 = categoriaSeleccionada.split("-")[0].trim();

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            sdf.setLenient(false);

            try {
                // Validar campos vacíos
                if (tituloL.isEmpty() || fechaTexto.isEmpty() || precioTexto.isEmpty()) {
                    throw new IllegalArgumentException("Todos los campos deben estar completos.");
                }

                // Validar y convertir campos
                int idProveedor = Integer.parseInt(idStr);
                double precioL = Double.parseDouble(precioTexto);
                int idAutor = Integer.parseInt(idStr3);
                int idCategoria = Integer.parseInt(idStr2);

                // Parsear fecha
                Date fechaPublicacionL = sdf.parse(fechaTexto);
                java.sql.Date sqlDate = new java.sql.Date(fechaPublicacionL.getTime());

                // Mostrar confirmación de fecha válida
                JOptionPane.showMessageDialog(null, "Fecha válida: " + sqlDate.toString());

                // Intentar agregar el libro
                LibroDAO dao = new LibroDAO();
                dao.agregarLibro(tituloL, sqlDate, idProveedor, precioL, idAutor, idCategoria);

                // Éxito
                JOptionPane.showMessageDialog(null, "✅ El libro fue agregado con éxito.");

                // Limpiar campos
                titulo.setText("");
                fechaPublicacion.setText("");
                precio.setText("");

            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(null, "❌ Verifique que los campos numéricos sean válidos.",
                        "Error de formato", JOptionPane.WARNING_MESSAGE);
            } catch (IllegalArgumentException ex) {
                JOptionPane.showMessageDialog(null, "⚠️ " + ex.getMessage(),
                        "Campos incompletos", JOptionPane.WARNING_MESSAGE);
            } catch (ParseException ex) {
                JOptionPane.showMessageDialog(null, "❌ Fecha inválida. Use el formato correcto (yyyy-MM-dd).",
                        "Error de fecha", JOptionPane.WARNING_MESSAGE);
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(null, "❌ Hubo un error y el libro no fue agregado.\nDetalles: " + ex.getMessage(),
                        "Error", JOptionPane.ERROR_MESSAGE);
                ex.printStackTrace(); // Para depuración
            }
            Index index = new Index(dao.obtenerLibrosDisponibles());
        });

        agregarButton.addActionListener(e -> dispose());


        regresarButton.addActionListener(e -> {
            Index index = new Index(dao.obtenerLibrosDisponibles());
        });
        regresarButton.addActionListener(e -> dispose());

        mainPanel.setBorder(BorderFactory.createTitledBorder("Agregar libro"));

        setContentPane(mainPanel);
        setVisible(true);
    }

    private void cargarProveedores() {
        CursorDAO dao = new CursorDAO();
        List<String> usuarios = dao.getProveedores();

        proveedor.removeAllItems();
        for (String usuario : usuarios) {
            proveedor.addItem(usuario);
        }
    }

    private void cargarCategorias() {
        CursorDAO dao = new CursorDAO();
        List<String> usuarios = dao.getCategorias();

        categoria.removeAllItems();
        for (String usuario : usuarios) {
            categoria.addItem(usuario);
        }
    }

    private void cargarAutor() {
        CursorDAO dao = new CursorDAO();
        List<String> usuarios = dao.getAutores();

        autor.removeAllItems();
        for (String usuario : usuarios) {
            autor.addItem(usuario);
        }
    }

}
