package org.example.vista;

import javax.swing.*;
import java.awt.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import org.example.controlador.DevolucionDAO;

public class FrmRegistrarDevolucion extends JFrame {

    private JTextField txtIdPrestamo;
    private JTextField txtFechaDevolucion;
    private JButton btnRegistrar;

    private static final SimpleDateFormat FORMATO_FECHA = new SimpleDateFormat("yyyy-MM-dd");

    public FrmRegistrarDevolucion() {
        setTitle("Registrar Devolución");
        setSize(350, 200);
        setLocationRelativeTo(null);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        initComponents();
    }

    private void initComponents() {
        JLabel lblIdPrestamo = new JLabel("ID Préstamo:");
        JLabel lblFechaDevolucion = new JLabel("Fecha Devolución (yyyy-MM-dd):");

        txtIdPrestamo = new JTextField();
        txtFechaDevolucion = new JTextField(FORMATO_FECHA.format(new Date()));

        btnRegistrar = new JButton("Registrar");

        btnRegistrar.addActionListener(e -> registrarDevolucion());

        setLayout(new GridLayout(3, 2, 10, 10));
        add(lblIdPrestamo);
        add(txtIdPrestamo);
        add(lblFechaDevolucion);
        add(txtFechaDevolucion);
        add(new JLabel());
        add(btnRegistrar);
    }

    private void registrarDevolucion() {
        try {
            int idPrestamo = Integer.parseInt(txtIdPrestamo.getText().trim());
            String fechaTexto = txtFechaDevolucion.getText().trim();

            Date fechaDevolucion;
            try {
                fechaDevolucion = FORMATO_FECHA.parse(fechaTexto);
            } catch (ParseException e) {
                JOptionPane.showMessageDialog(this, "?? Formato de fecha inválido. Use yyyy-MM-dd.");
                return;
            }

            DevolucionDAO dao = new DevolucionDAO();
            dao.registrarDevolucion(idPrestamo, fechaDevolucion);

            JOptionPane.showMessageDialog(this, "? Devolución registrada correctamente.");

            // Limpiar campos
            txtIdPrestamo.setText("");
            txtFechaDevolucion.setText(FORMATO_FECHA.format(new Date()));

        } catch (NumberFormatException ex) {
            JOptionPane.showMessageDialog(this, "?? ID de préstamo inválido.");
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "? Error: " + ex.getMessage());
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new FrmRegistrarDevolucion().setVisible(true));
    }
}
