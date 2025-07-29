package org.example.controlador;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import org.example.DBConnection;

import javax.swing.*;

public class SancionDAO {

    public void registrarSancion(int idDevolucion) {
        Connection con = null;
        CallableStatement stmt = null;

        try {
            con = DBConnection.getConnection();
            stmt = con.prepareCall("{ call pkg_prestamos.Registrar_Sancion(?) }");

            stmt.setInt(1, idDevolucion);

            stmt.execute();
            System.out.println("✅ Sanción registrada correctamente (si aplicaba).");
            JOptionPane.showMessageDialog(null, "✅ Sanción registrada correctamente (si aplicaba).");
        } catch (SQLException e) {
            System.err.println("❌ Error al registrar sanción: " + e.getMessage());
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (SQLException ex) {
                System.err.println("❌ Error cerrando conexión: " + ex.getMessage());
            }
        }
    }
}
