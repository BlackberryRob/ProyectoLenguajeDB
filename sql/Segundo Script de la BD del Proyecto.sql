--Vistas

--Vista de inventario de libros
CREATE OR REPLACE VIEW Vista_Inventario_Libros AS
SELECT
    l.Id_Libro_PK,
    l.Titulo,
    l.Fecha_Publicacion,
    l.Disponible,
    LISTAGG(a.Nombre || ' ' || a.Apellido, ', ') WITHIN GROUP (ORDER BY a.Apellido) AS Autores,
    LISTAGG(c.Nombre, ', ') WITHIN GROUP (ORDER BY c.Nombre) AS Categorias
FROM Libro l
LEFT JOIN Libro_Autor la ON l.Id_Libro_PK = la.Id_Libro_PK
LEFT JOIN Autor a ON la.Id_Autor_PK = a.Id_Autor_PK
LEFT JOIN Libro_Categoria lc ON l.Id_Libro_PK = lc.Id_Libro_PK
LEFT JOIN Categoria c ON lc.Id_Categoria_PK = c.Id_Categoria_PK
GROUP BY l.Id_Libro_PK, l.Titulo, l.Fecha_Publicacion, l.Disponible;
/

--Vista de compras de libros
CREATE OR REPLACE VIEW Vista_Compras_Libros AS
SELECT
    c.Id_Compra_PK,
    l.Titulo,
    p.Nombre AS Proveedor,
    c.Precio,
    c.Fecha_Compra
FROM Compra c
JOIN Libro l ON c.Id_Libro_FK = l.Id_Libro_PK
JOIN Proveedor p ON c.Id_Proveedor_FK = p.Id_Proveedor_PK;
/


--
CREATE OR REPLACE VIEW Vista_Libros_Disponibles AS
SELECT
    l.Id_Libro_PK,
    l.Titulo,
    l.Fecha_Publicacion,
    LISTAGG(a.Nombre || ' ' || a.Apellido, ', ') WITHIN GROUP (ORDER BY a.Apellido) AS Autores,
    LISTAGG(c.Nombre, ', ') WITHIN GROUP (ORDER BY c.Nombre) AS Categorias
FROM
    Libro l
JOIN Libro_Autor la ON l.Id_Libro_PK = la.Id_Libro_PK
JOIN Autor a ON la.Id_Autor_PK = a.Id_Autor_PK
JOIN Libro_Categoria lc ON l.Id_Libro_PK = lc.Id_Libro_PK
JOIN Categoria c ON lc.Id_Categoria_PK = c.Id_Categoria_PK
WHERE
    l.Disponible = 1
GROUP BY
    l.Id_Libro_PK, l.Titulo, l.Fecha_Publicacion;

--Procedimientos Almacenados

--Inserta un nuevo pr�stamo.
CREATE OR REPLACE PROCEDURE Realizar_Prestamo (
    p_Id_Libro IN NUMBER,
    p_Id_Usuario IN NUMBER
) AS
    v_disponible NUMBER;
    v_new_id NUMBER;
    v_new_dev_id NUMBER;
BEGIN
    -- Verificar si el libro est� disponible
    SELECT Disponible INTO v_disponible
    FROM Libro
    WHERE Id_Libro_PK = p_Id_Libro;

    IF v_disponible = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El libro no est� disponible para pr�stamo.');
    END IF;

    -- Generar un nuevo ID para el pr�stamo
    SELECT MAX(Id_Prestamo_PK) + 1 INTO v_new_id FROM Prestamo;

    -- Insertar el pr�stamo
    INSERT INTO Prestamo (
        Id_Prestamo_PK,
        Id_Libro_PK,
        Id_Usuario_FK,
        Fecha_Prestamo
    ) VALUES (
        v_new_id,
        p_Id_Libro,
        p_Id_Usuario,
        SYSDATE
    );
    
    -- Marcar el libro como no disponible
    UPDATE Libro
    SET Disponible = 0
    WHERE Id_Libro_PK = p_Id_Libro;
    
    SELECT MAX(Id_Devolucion_PK) + 1 INTO v_new_dev_id FROM Devolucion;
    
    --Insertar Devolucion
    INSERT INTO Devolucion (
        Id_Devolucion_PK,
        Id_Prestamo_FK,
        Fecha_Devolucion,
        Devuelto
    ) VALUES (
        v_new_dev_id,
        v_new_id,
        SYSDATE + (7 * 6),
        0
    );


    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Pr�stamo registrado correctamente.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No se encontr� el libro.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

CALL Realizar_Prestamo(50, 49);

select * from libro;

-- Agregar Libro
CREATE OR REPLACE PROCEDURE Agregar_Libro (
    p_Titulo IN VARCHAR2,
    p_Fecha_Publicacion IN DATE,
    p_Id_Proveedor IN NUMBER,
    p_Precio IN NUMBER,
    p_Id_Autor IN NUMBER,
    p_Id_Categoria IN NUMBER
) AS
    v_new_libro_id NUMBER;
    v_new_compra_id NUMBER;
BEGIN
    -- Generar nuevo Id para libro
    SELECT NVL(MAX(Id_Libro_PK), 0) + 1 INTO v_new_libro_id FROM Libro;
    
    -- Insertar nuevo libro (disponible por defecto)
    INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible)
    VALUES (v_new_libro_id, p_Titulo, p_Fecha_Publicacion, 1);
    
    -- Asociar autor
    INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK)
    VALUES (v_new_libro_id, p_Id_Autor);
    
    -- Asociar categor�a
    INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK)
    VALUES (v_new_libro_id, p_Id_Categoria);
    
    -- Generar nuevo Id para compra
    SELECT NVL(MAX(Id_Compra_PK), 0) + 1 INTO v_new_compra_id FROM Compra;
    
    -- Registrar compra
    INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra)
    VALUES (v_new_compra_id, p_Id_Proveedor, v_new_libro_id, p_Precio, SYSDATE);
    
    COMMIT;
END;
/


-- Actualizar la disponibilidad del libro
CREATE OR REPLACE PROCEDURE Actualizar_Disponibilidad_Libro (
    p_Id_Libro IN NUMBER,
    p_Disponible IN NUMBER
) AS
BEGIN
    UPDATE Libro
    SET Disponible = p_Disponible
    WHERE Id_Libro_PK = p_Id_Libro;
    
    COMMIT;
END;
/


--Eliminar libro
CREATE OR REPLACE PROCEDURE Eliminar_Libro (
    p_Id_Libro IN NUMBER
) AS
    v_prestamos NUMBER;
    v_sanciones NUMBER;
BEGIN
    -- Verificar pr�stamos
    SELECT COUNT(*) INTO v_prestamos FROM Prestamo WHERE Id_Libro_PK = p_Id_Libro;
    
    -- Verificar sanciones asociadas a devoluciones del libro
    SELECT COUNT(*)
    INTO v_sanciones
    FROM Sancion s
    JOIN Devolucion d ON s.Id_Devolucion_FK = d.Id_Devolucion_PK
    JOIN Prestamo p ON d.Id_Prestamo_FK = p.Id_Prestamo_PK
    WHERE p.Id_Libro_PK = p_Id_Libro;
    
    IF v_prestamos > 0 OR v_sanciones > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'No se puede eliminar: existen pr�stamos o sanciones asociadas.');
    ELSE
        DELETE FROM Libro_Autor WHERE Id_Libro_PK = p_Id_Libro;
        DELETE FROM Libro_Categoria WHERE Id_Libro_PK = p_Id_Libro;
        DELETE FROM Compra WHERE Id_Libro_FK = p_Id_Libro;
        DELETE FROM Libro WHERE Id_Libro_PK = p_Id_Libro;
        COMMIT;
    END IF;
END;
/

--

-- PLSQL
SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION Obtener_Titulo_Libro(
    p_Id_Libro IN NUMBER
) RETURN VARCHAR2 IS
    v_Titulo VARCHAR2(255);
BEGIN
    SELECT Titulo INTO v_Titulo
    FROM Libro
    WHERE Id_Libro_PK = p_Id_Libro;

    RETURN v_Titulo;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'No existe libro con ese ID';
    WHEN OTHERS THEN
        RETURN 'Error al consultar';
END;
/

CREATE OR REPLACE PROCEDURE Listar_Libros_Disponibles IS
    CURSOR c_libros IS
        SELECT Titulo FROM Libro WHERE Disponible = 1;
    v_titulo VARCHAR2(255);
BEGIN
    OPEN c_libros;
    LOOP
        FETCH c_libros INTO v_titulo;
        EXIT WHEN c_libros%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Libro: ' || v_titulo);
    END LOOP;
    CLOSE c_libros;
END;
/

SELECT Obtener_Titulo_Libro(1) FROM dual;
EXEC Listar_Libros_Disponibles;















//AVANCE ALEJANDRO
CREATE SEQUENCE Devolucion_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE Sancion_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE Registrar_Devolucion (
    P_Id_Prestamo NUMBER,
    P_Fecha_Devolucion DATE
) AS
    V_Id_Usuario NUMBER;
    V_Id_Libro NUMBER;
    V_Fecha_Prestamo DATE;
    V_Fecha_Limite DATE;
    V_Retraso NUMBER;
    V_Id_Devolucion NUMBER;
BEGIN
    -- Obtener datos del préstamo
    SELECT Id_Usuario_FK, Id_Libro_PK, Fecha_Prestamo
    INTO V_Id_Usuario, V_Id_Libro, V_Fecha_Prestamo
    FROM Prestamo
    WHERE Id_Prestamo_PK = P_Id_Prestamo;

    -- Calcular fecha límite: préstamo + 7 días
    V_Fecha_Limite := V_Fecha_Prestamo + 7;

    -- Generar ID devolución
    V_Id_Devolucion := Devolucion_seq.NEXTVAL;

    -- Insertar devolución
    INSERT INTO Devolucion (
        Id_Devolucion_PK,
        Id_Prestamo_FK,
        Fecha_Devolucion,
        Devuelto
    ) VALUES (
        V_Id_Devolucion,
        P_Id_Prestamo,
        P_Fecha_Devolucion,
        1 -- Devuelto = sí
    );

    -- Marcar libro como disponible
    UPDATE Libro
    SET Disponible = 1
    WHERE Id_Libro_PK = V_Id_Libro;

    -- Verificar retraso y registrar sanción si aplica
    IF P_Fecha_Devolucion > V_Fecha_Limite THEN
        V_Retraso := P_Fecha_Devolucion - V_Fecha_Limite;
        Registrar_Sancion(
            P_Id_Usuario => V_Id_Usuario,
            P_Id_Devolucion => V_Id_Devolucion,
            P_Monto => V_Retraso * 1000 -- ajusta monto
        );
    END IF;
END;
/



CREATE OR REPLACE PROCEDURE Registrar_Sancion (
    P_Id_Usuario NUMBER,
    P_Id_Devolucion NUMBER,
    P_Monto NUMBER
) AS
BEGIN
    INSERT INTO Sancion (
        Id_Sancion_PK,
        Id_Usuario_FK,
        Id_Devolucion_FK,
        Monto,
        Pagado
    ) VALUES (
        Sancion_seq.NEXTVAL,
        P_Id_Usuario,
        P_Id_Devolucion,
        P_Monto,
        0  -- No pagado
    );
END;
/
