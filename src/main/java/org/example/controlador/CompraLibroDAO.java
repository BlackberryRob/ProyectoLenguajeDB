package org.example.controlador;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import org.example.DBConnection;
import org.example.modelo.CompraLibro;

public class CompraLibroDAO {
    public List<CompraLibro> obtenerComprasLibros() {
        List<CompraLibro> compras = new ArrayList<>();
        String sql = "SELECT * FROM Vista_Compras_Libros";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                compras.add(new CompraLibro(
                        rs.getInt("Id_Compra_PK"),
                        rs.getString("Titulo"),
                        rs.getString("Proveedor"),
                        rs.getDouble("Precio"),
                        rs.getDate("Fecha_Compra") != null ? rs.getDate("Fecha_Compra").toString() : null
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return compras;
    }
}
