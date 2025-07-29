package org.example.controlador;

import oracle.jdbc.internal.OracleTypes;
import org.example.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CursorDAO {

    public int verPrestamos(int idUsuario) {
        Connection con = null;
        CallableStatement stmt = null;
        int cantidad=0;
        try {
            con = DBConnection.getConnection();
            stmt = con.prepareCall("{ ? = call pkg_prestamos.Contar_Prestamos_Usuario(?) }");

            stmt.registerOutParameter(1, java.sql.Types.INTEGER);

            stmt.setInt(2, idUsuario);

            stmt.execute();

            cantidad = stmt.getInt(1);

            System.out.println("📚 El usuario tiene " + cantidad + " préstamo(s) activo(s).");
        } catch (SQLException e) {
            System.err.println("❌ Error al contar préstamos: " + e.getMessage());
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            } catch (SQLException ex) {
                System.err.println("❌ Error cerrando conexión: " + ex.getMessage());
            }
        }

        return cantidad;
    }

    public List<String> getProveedores() {
        List<String> usuarios = new ArrayList<>();
        Connection con = null;
        CallableStatement stmt = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection(); // Asegúrate de que tu conexión funciona correctamente

            stmt = con.prepareCall("{call pkg_catalogo.Listar_Proveedores(?)}");
            stmt.registerOutParameter(1, OracleTypes.CURSOR);
            stmt.execute();

            rs = (ResultSet) stmt.getObject(1);

            while (rs.next()) {
                int id = rs.getInt(1);
                String nombreCompleto = rs.getString(2);
                usuarios.add(id + " - " + nombreCompleto);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        return usuarios;
    }

    public List<String> getUsuarios() {
        List<String> usuarios = new ArrayList<>();
        Connection con = null;
        CallableStatement stmt = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection(); // Asegúrate de que tu conexión funciona correctamente

            stmt = con.prepareCall("{call pkg_catalogo.Listar_Usuarios(?)}");
            stmt.registerOutParameter(1, OracleTypes.CURSOR);
            stmt.execute();

            rs = (ResultSet) stmt.getObject(1);

            while (rs.next()) {
                int id = rs.getInt(1);
                String nombreCompleto = rs.getString(2);
                usuarios.add(id + " - " + nombreCompleto);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        return usuarios;
    }

    public List<String> getCategorias() {
        List<String> categorias = new ArrayList<>();
        Connection con = null;
        CallableStatement stmt = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();
            stmt = con.prepareCall("{ call pkg_catalogo.Listar_Categorias(?) }");
            stmt.registerOutParameter(1, OracleTypes.CURSOR);
            stmt.execute();

            rs = (ResultSet) stmt.getObject(1);

            while (rs.next()) {
                int id = rs.getInt(1);
                String nombre = rs.getString(2);
                categorias.add(id + " - " + nombre);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        return categorias;
    }

    public List<String> getAutores() {
        List<String> autores = new ArrayList<>();
        Connection con = null;
        CallableStatement stmt = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();
            stmt = con.prepareCall("{ call pkg_catalogo.Listar_Autores(?) }");
            stmt.registerOutParameter(1, OracleTypes.CURSOR);
            stmt.execute();

            rs = (ResultSet) stmt.getObject(1);

            while (rs.next()) {
                int id = rs.getInt(1);
                String nombreCompleto = rs.getString(2);
                String nacionalidad = rs.getString(3);
                autores.add(id + " - " + nombreCompleto + " (" + nacionalidad + ")");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        return autores;
    }

    public List<String> getBibliotecarios() {
        List<String> bibliotecarios = new ArrayList<>();
        Connection con = null;
        CallableStatement stmt = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();
            stmt = con.prepareCall("{ call pkg_catalogo.Listar_Bibliotecarios(?) }");
            stmt.registerOutParameter(1, OracleTypes.CURSOR);
            stmt.execute();

            rs = (ResultSet) stmt.getObject(1);

            while (rs.next()) {
                int id = rs.getInt(1);
                String nombreCompleto = rs.getString(2);
                bibliotecarios.add(id + " - " + nombreCompleto);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        return bibliotecarios;
    }

    // Prestamos pendientes del usuario
    public List<String> getPrestamosPorUsuario(int usuarioId) {
        List<String> prestamos = new ArrayList<>();
        Connection con = null;
        CallableStatement stmt = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();
            stmt = con.prepareCall("{ call CURSOR_PRESTAMO(?, ?) }");
            stmt.setInt(1, usuarioId);
            stmt.registerOutParameter(2, OracleTypes.CURSOR);
            stmt.execute();

            rs = (ResultSet) stmt.getObject(2);

            while (rs.next()) {
                int idPrestamo = rs.getInt("ID_PRESTAMO_PK");
                int idDevolucion = rs.getInt("ID_DEVOLUCION_PK");
                prestamos.add(idPrestamo + "-" + idDevolucion);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }

        return prestamos;
    }

}
