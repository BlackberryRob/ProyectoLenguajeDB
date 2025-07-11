package org.example.controlador;

import org.example.DBConnection;
import org.example.modelo.LibroDisponible;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LibroDAO {

    //Vistas
    //1. Vista_Libros_Disponibles
    public List<LibroDisponible> obtenerLibrosDisponibles() {
        List<LibroDisponible> libros = new ArrayList<>();
        String sql = "SELECT * FROM Vista_Libros_Disponibles";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                libros.add(new LibroDisponible(
                        rs.getInt("Id_Libro_PK"),
                        rs.getString("Titulo"),
                        rs.getDate("Fecha_Publicacion") != null ? rs.getDate("Fecha_Publicacion").toString() : null,
                        rs.getString("Autores"),
                        rs.getString("Categorias")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return libros;
    }

    //2. Vista_Inventario_Libros
    public List<LibroDisponible> obtenerInventarioLibros() {
        List<LibroDisponible> libros = new ArrayList<>();
        String sql = "SELECT * FROM Vista_Inventario_Libros";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                libros.add(new LibroDisponible(
                        rs.getInt("Id_Libro_PK"),
                        rs.getString("Titulo"),
                        rs.getDate("Fecha_Publicacion") != null ? rs.getDate("Fecha_Publicacion").toString() : null,
                        rs.getString("Autores"),
                        rs.getString("Categorias"),
                        rs.getBoolean("Disponible")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return libros;
    }

    //Procedimientos Almacenados
    //Realizar_Prestamo
    public void realizarPrestamo(int idLibro, int idUsuario, int idBibliotecario) {
        String sql = "{ call Realizar_Prestamo(?, ?, ?) }";

        try (Connection conn = DBConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {

            stmt.setInt(1, idLibro);
            stmt.setInt(2, idUsuario);
            stmt.setInt(3, idBibliotecario);

            stmt.execute();

            System.out.println("Préstamo realizado correctamente.");

        } catch (SQLException e) {
            System.err.println("Error al realizar el préstamo: " + e.getMessage());
        }
    }

    //Agregar_Libro
    public void agregarLibro(String titulo, Date fechaPublicacion, int idProveedor, double precio, int idAutor, int idCategoria) {
        String sql = "{ call Agregar_Libro(?, ?, ?, ?, ?, ?) }";

        try (Connection conn = DBConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {

            stmt.setString(1, titulo);
            stmt.setDate(2, new java.sql.Date(fechaPublicacion.getTime()));
            stmt.setInt(3, idProveedor);
            stmt.setDouble(4, precio);
            stmt.setInt(5, idAutor);
            stmt.setInt(6, idCategoria);

            stmt.execute();

            System.out.println("Libro agregado correctamente.");

        } catch (SQLException e) {
            System.err.println("Error al agregar el libro: " + e.getMessage());
        }
    }

}
