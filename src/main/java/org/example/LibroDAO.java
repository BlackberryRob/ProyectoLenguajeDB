package org.example;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LibroDAO {
    public void crearLibro(Libro libro) {
        String sql = "INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, libro.getId());
            stmt.setString(2, libro.getTitulo());
            stmt.setString(3, libro.getFechaPublicacion());
            stmt.setInt(4, libro.isDisponible() ? 1 : 0);
            stmt.executeUpdate();
            System.out.println("Libro creado.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Libro> obtenerLibros() {
        List<Libro> libros = new ArrayList<>();
        String sql = "SELECT * FROM Libro";
        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                libros.add(new Libro(
                        rs.getInt("Id_Libro_PK"),
                        rs.getString("Titulo"),
                        rs.getDate("Fecha_Publicacion") != null ? rs.getDate("Fecha_Publicacion").toString() : null,
                        rs.getInt("Disponible") == 1
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return libros;
    }

    public void actualizarLibro(Libro libro) {
        String sql = "UPDATE Libro SET Titulo = ?, Fecha_Publicacion = TO_DATE(?, 'YYYY-MM-DD'), Disponible = ? WHERE Id_Libro_PK = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, libro.getTitulo());
            stmt.setString(2, libro.getFechaPublicacion());
            stmt.setInt(3, libro.isDisponible() ? 1 : 0);
            stmt.setInt(4, libro.getId());
            stmt.executeUpdate();
            System.out.println("Libro actualizado.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void eliminarLibro(int idLibro) {
        String sql = "DELETE FROM Libro WHERE Id_Libro_PK = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, idLibro);
            stmt.executeUpdate();
            System.out.println("Libro eliminado.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
