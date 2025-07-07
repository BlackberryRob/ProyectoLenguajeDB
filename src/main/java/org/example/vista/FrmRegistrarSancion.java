package org.example.vista;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import org.example.controlador.SancionDAO;

public class FrmRegistrarSancion extends JFrame {

    private JTextField txtIdUsuario;
    private JTextField txtIdDevolucion;
    private JTextField txtMonto;
    private JButton btnRegistrar;

    public FrmRegistrarSancion() {
        setTitle("Registrar Sanción");
        setSize(350, 250);
        setLocationRelativeTo(null);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        initComponents();
    }

    private void initComponents() {
        JLabel lblIdUsuario = new JLabel("ID Usuario:");
        JLabel lblIdDevolucion = new JLabel("ID Devolución:");
        JLabel lblMonto = new JLabel("Monto:");

        txtIdUsuario = new JTextField();
        txtIdDevolucion = new JTextField();
        txtMonto = new JTextField();

        btnRegistrar = new JButton("Registrar");

        btnRegistrar.addActionListener(e -> registrarSancion());

        setLayout(new GridLayout(4, 2, 10, 10));
        add(lblIdUsuario);
        add(txtIdUsuario);
        add(lblIdDevolucion);
        add(txtIdDevolucion);
        add(lblMonto);
        add(txtMonto);
        add(new JLabel());  // espacio vacío
        add(btnRegistrar);
    }

    private void registrarSancion() {
        try {
            int idUsuario = Integer.parseInt(txtIdUsuario.getText().trim());
            int idDevolucion = Integer.parseInt(txtIdDevolucion.getText().trim());
            double monto = Double.parseDouble(txtMonto.getText().trim());

            // Validar valores (por ejemplo, monto no negativo)
            if (monto < 0) {
                JOptionPane.showMessageDialog(this, "?? El monto no puede ser negativo.");
                return;
            }

            SancionDAO dao = new SancionDAO();
            dao.registrarSancion(idUsuario, idDevolucion, monto);

            JOptionPane.showMessageDialog(this, "? Sanción registrada correctamente.");

            // Limpiar campos después de registrar
            txtIdUsuario.setText("");
            txtIdDevolucion.setText("");
            txtMonto.setText("");
        } catch (NumberFormatException ex) {
            JOptionPane.showMessageDialog(this, "?? Valores inválidos. Verifica los datos.");
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "? Error: " + ex.getMessage());
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new FrmRegistrarSancion().setVisible(true));
    }
}

