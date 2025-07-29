package org.example.controlador;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import org.example.DBConnection;

import javax.swing.*;

public class DevolucionDAO {

    public void registrarDevolucion(int idPrestamo) {
        Connection con = null;
        CallableStatement stmt = null;

        try {
            con = DBConnection.getConnection();
            stmt = con.prepareCall("{ call pkg_prestamos.Registrar_Devolucion(?) }");

            stmt.setInt(1, idPrestamo);

            stmt.execute();
            System.out.println("✅ Devolución registrada correctamente.");
            JOptionPane.showMessageDialog(null, "✅ Devolución registrada correctamente.");
        } catch (SQLException e) {
            System.err.println("❌ Error al registrar devolución: " + e.getMessage());
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
