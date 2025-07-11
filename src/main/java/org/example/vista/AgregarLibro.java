package org.example.vista;

import org.example.controlador.LibroDAO;

import javax.swing.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class AgregarLibro extends JFrame{
    private JPanel mainPanel;
    private JButton agregarButton;
    private JButton regresarButton;
    private JTextField titulo;
    private JTextField fechaPublicacion;
    private JTextField proveedor;
    private JTextField precio;
    private JTextField autor;
    private JTextField categoria;
    LibroDAO dao = new LibroDAO();

    public AgregarLibro() {
        setTitle("Biblioteca");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(500, 550);
        setLocationRelativeTo(null);

        agregarButton.addActionListener(e -> {
            String tituloL = titulo.getText().trim();
            String fechaTexto = fechaPublicacion.getText().trim();
            String proveedorTexto = proveedor.getText().trim();
            String precioTexto = precio.getText().trim();
            String autorTexto = autor.getText().trim();
            String categoriaTexto = categoria.getText().trim();

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            sdf.setLenient(false);

            try {
                // Validar campos vacíos
                if (tituloL.isEmpty() || fechaTexto.isEmpty() || proveedorTexto.isEmpty() ||
                        precioTexto.isEmpty() || autorTexto.isEmpty() || categoriaTexto.isEmpty()) {
                    throw new IllegalArgumentException("Todos los campos deben estar completos.");
                }

                // Validar y convertir campos
                int idProveedor = Integer.parseInt(proveedorTexto);
                double precioL = Double.parseDouble(precioTexto);
                int idAutor = Integer.parseInt(autorTexto);
                int idCategoria = Integer.parseInt(categoriaTexto);

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
                proveedor.setText("");
                precio.setText("");
                autor.setText("");
                categoria.setText("");

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
        });


        regresarButton.addActionListener(e -> {
            Index index = new Index(dao.obtenerLibrosDisponibles());
        });
        regresarButton.addActionListener(e -> dispose());

        mainPanel.setBorder(BorderFactory.createTitledBorder("Agregar libro"));

        setContentPane(mainPanel);
        setVisible(true);
    }

}
