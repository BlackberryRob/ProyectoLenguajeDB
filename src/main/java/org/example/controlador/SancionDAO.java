package org.example.controlador;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import org.example.DBConnection;

public class SancionDAO {

    public void registrarSancion(int idUsuario, int idDevolucion, double monto) {
        Connection con = null;
        CallableStatement stmt = null;

        try {
            con = DBConnection.getConnection();
            stmt = con.prepareCall("{ call Registrar_Sancion(?, ?, ?) }");

            stmt.setInt(1, idUsuario);
            stmt.setInt(2, idDevolucion);
            stmt.setDouble(3, monto);

            stmt.execute();
            System.out.println("✅ Sanción registrada correctamente.");
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
