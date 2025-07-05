--Vistas

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

--Inserta un nuevo préstamo.
CREATE OR REPLACE PROCEDURE Realizar_Prestamo (
    p_Id_Libro IN NUMBER,
    p_Id_Usuario IN NUMBER
) AS
    v_disponible NUMBER;
    v_new_id NUMBER;
    v_new_dev_id NUMBER;
BEGIN
    -- Verificar si el libro está disponible
    SELECT Disponible INTO v_disponible
    FROM Libro
    WHERE Id_Libro_PK = p_Id_Libro;

    IF v_disponible = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El libro no está disponible para préstamo.');
    END IF;

    -- Generar un nuevo ID para el préstamo
    SELECT MAX(Id_Prestamo_PK) + 1 INTO v_new_id FROM Prestamo;

    -- Insertar el préstamo
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
    DBMS_OUTPUT.PUT_LINE('Préstamo registrado correctamente.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No se encontró el libro.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

CALL Realizar_Prestamo(50, 49);

select * from libro;
