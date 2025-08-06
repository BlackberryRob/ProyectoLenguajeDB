ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

--Crear el esquema
CREATE USER BIBLIOTECA_LBD IDENTIFIED BY "Biblioteca123"
DEFAULT TABLESPACE BIBLIOTECA_LBD
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON BIBLIOTECA_LBD;

--Otorgar privilegios necesarios
GRANT CONNECT, RESOURCE TO BIBLIOTECA_LBD;

--Otorgar privilegios adicionales si va a administrar tablespaces o crear objetos avanzados
GRANT CREATE SESSION TO BIBLIOTECA_LBD;
GRANT CREATE TABLE TO BIBLIOTECA_LBD;
GRANT CREATE VIEW TO BIBLIOTECA_LBD;
GRANT CREATE SEQUENCE TO BIBLIOTECA_LBD;
GRANT CREATE PROCEDURE TO BIBLIOTECA_LBD;

--Permisos de DBA, solo si deseas acceso total:
GRANT DBA TO BIBLIOTECA_LBD;

-- Crear un tablespace personalizado
CREATE TABLESPACE BIBLIOTECA_LBD
DATAFILE 'C:\ORACLE\ORADATA\ORCL\BIBLIOTECA_LBD.DBF'
SIZE 100M 
AUTOEXTEND ON 
NEXT 10M 
MAXSIZE UNLIMITED;

--Crear tablas
CREATE TABLE Libro (
    Id_Libro_PK NUMBER PRIMARY KEY,
    Titulo VARCHAR2(255) NOT NULL,
    Fecha_Publicacion DATE,
    Disponible NUMBER(1) DEFAULT 1 CHECK (Disponible IN (0, 1))
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Autor (
    Id_Autor_PK NUMBER PRIMARY KEY,
    Nombre VARCHAR2(100) NOT NULL,
    Apellido VARCHAR2(100) NOT NULL,
    Nacionalidad VARCHAR2(100)
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Libro_Autor (
    Id_Libro_PK NUMBER NOT NULL,
    Id_Autor_PK NUMBER NOT NULL,
    PRIMARY KEY (Id_Libro_PK, Id_Autor_PK),
    FOREIGN KEY (Id_Libro_PK) REFERENCES Libro(Id_Libro_PK),
    FOREIGN KEY (Id_Autor_PK) REFERENCES Autor(Id_Autor_PK)
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Categoria (
    Id_Categoria_PK NUMBER PRIMARY KEY,
    Nombre VARCHAR2(100) NOT NULL UNIQUE
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Libro_Categoria (
    Id_Libro_PK NUMBER NOT NULL,
    Id_Categoria_PK NUMBER NOT NULL,
    PRIMARY KEY (Id_Libro_PK, Id_Categoria_PK),
    FOREIGN KEY (Id_Libro_PK) REFERENCES Libro(Id_Libro_PK),
    FOREIGN KEY (Id_Categoria_PK) REFERENCES Categoria(Id_Categoria_PK)
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Proveedor (
    Id_Proveedor_PK NUMBER PRIMARY KEY,
    Nombre VARCHAR2(100) NOT NULL,
    Telefono VARCHAR2(15),
    Correo VARCHAR2(255) UNIQUE
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Compra (
    Id_Compra_PK NUMBER PRIMARY KEY,
    Id_Proveedor_FK NUMBER NOT NULL,
    Id_Libro_FK NUMBER NOT NULL,
    Precio NUMBER(10,2),
    Fecha_Compra DATE,
    FOREIGN KEY (Id_Proveedor_FK) REFERENCES Proveedor(Id_Proveedor_PK),
    FOREIGN KEY (Id_Libro_FK) REFERENCES Libro(Id_Libro_PK)
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Usuario (
    Id_Usuario_PK NUMBER PRIMARY KEY,
    Nombre VARCHAR2(100) NOT NULL,
    Apellido VARCHAR2(100) NOT NULL,
    Correo VARCHAR2(255) UNIQUE,
    Telefono VARCHAR2(15),
    CONSTRAINT chk_usuario_tel CHECK (Telefono IS NULL OR LENGTH(Telefono) >= 8)
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Prestamo(
    Id_Prestamo_PK NUMBER PRIMARY KEY,
    Id_Libro_PK NUMBER NOT NULL,
    Id_Usuario_FK NUMBER NOT NULL,
    Fecha_Prestamo DATE DEFAULT SYSDATE,
    FOREIGN KEY (Id_Libro_PK) REFERENCES Libro(Id_Libro_PK),
    FOREIGN KEY (Id_Usuario_FK) REFERENCES Usuario(Id_Usuario_PK)
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Bibliotecario(
    Id_Bibliotecario_PK NUMBER PRIMARY KEY,
    Nombre VARCHAR2(100) NOT NULL,
    Apellido VARCHAR2(100) NOT NULL
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Devolucion(
    Id_Devolucion_PK NUMBER PRIMARY KEY,
    Id_Prestamo_FK NUMBER NOT NULL UNIQUE,
    Fecha_Devolucion DATE,
    Devuelto NUMBER(1) DEFAULT 0 CHECK (Devuelto IN (0, 1)),
    FOREIGN KEY (Id_Prestamo_FK) REFERENCES Prestamo(Id_Prestamo_PK)
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Transaccion(
    Id_Transaccion_PK NUMBER PRIMARY KEY,
    Id_Prestamo_PK NUMBER NOT NULL,
    Id_Usuario_FK NUMBER NOT NULL,
    Id_Bibliotecario_FK NUMBER NOT NULL,
    Id_Devolucion_FK NUMBER,
    Fecha_Prestamo DATE,
    FOREIGN KEY (Id_Prestamo_PK) REFERENCES Prestamo(Id_Prestamo_PK),
    FOREIGN KEY (Id_Usuario_FK) REFERENCES Usuario(Id_Usuario_PK),
    FOREIGN KEY (Id_Bibliotecario_FK) REFERENCES Bibliotecario(Id_Bibliotecario_PK),
    FOREIGN KEY (Id_Devolucion_FK) REFERENCES Devolucion(Id_Devolucion_PK)
) TABLESPACE BIBLIOTECA_LBD;

CREATE TABLE Sancion(
    Id_Sancion_PK NUMBER PRIMARY KEY,
    Id_Usuario_FK NUMBER NOT NULL,
    Id_Devolucion_FK NUMBER NOT NULL,
    Monto NUMBER(10,2) CHECK (Monto >= 0),
    Pagado NUMBER(1) DEFAULT 0 CHECK (Pagado IN (0,1)),
    FOREIGN KEY (Id_Usuario_FK) REFERENCES Usuario(Id_Usuario_PK),
    FOREIGN KEY (Id_Devolucion_FK) REFERENCES Devolucion(Id_Devolucion_PK)
) TABLESPACE BIBLIOTECA_LBD;

--Crear objetos

--Vistas

--Vista_Libros_Disponibles
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
    
--Vista_Inventario_Libros
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

--Vista_Compras_Libros
CREATE OR REPLACE VIEW Vista_Compras_Libros AS
SELECT
    c.Id_Compra_PK,
    l.Titulo,
    p.Nombre AS Proveedor,
    c.Precio,
    c.Fecha_Compra
FROM Compra c
JOIN Libro l ON c.Id_Libro_FK = l.Id_Libro_PK
JOIN Proveedor p ON c.Id_Proveedor_FK = p.Id_Proveedor_PK
ORDER BY c.Id_Compra_PK;

--Procedimientos Almacenados

--Realizar_Préstamo
CREATE OR REPLACE PROCEDURE Realizar_Prestamo (
    p_Id_Libro IN NUMBER,
    p_Id_Usuario IN NUMBER,
    p_Id_Bibliotecario IN NUMBER
) AS
    v_disponible NUMBER;
    v_new_id NUMBER;
    v_new_dev_id NUMBER;
    v_new_tra_id NUMBER;
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

    --Insertar Transaccion
    
    SELECT MAX(Id_Transaccion_PK) + 1 INTO v_new_tra_id FROM Transaccion;
    
    INSERT INTO Transaccion (
        Id_Transaccion_PK,
        Id_Prestamo_PK,
        Id_Usuario_FK,
        Id_Bibliotecario_FK,
        Id_Devolucion_FK,
        Fecha_Prestamo
    ) VALUES (
        v_new_tra_id,
        v_new_id,
        p_Id_Usuario,
        p_Id_Bibliotecario,
        v_new_dev_id,
        SYSDATE
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

--Registrar_Devolución

CREATE OR REPLACE PROCEDURE Registrar_Devolucion (
    p_Id_Prestamo IN NUMBER
) AS
    v_Id_Libro NUMBER;
    v_Id_Devolucion NUMBER;
    v_devuelto NUMBER;
BEGIN
    -- Obtener ID del libro asociado al préstamo
    SELECT Id_Libro_PK INTO v_Id_Libro
    FROM Prestamo
    WHERE Id_Prestamo_PK = p_Id_Prestamo;

    -- Verificar si existe la devolución correspondiente
    SELECT Id_Devolucion_PK, Devuelto INTO v_Id_Devolucion, v_devuelto
    FROM Devolucion
    WHERE Id_Prestamo_FK = p_Id_Prestamo;

    -- Verificar si ya ha sido devuelto
    IF v_devuelto = 1 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Este préstamo ya ha sido devuelto.');
    END IF;

    -- Actualizar estado de devolución
    UPDATE Devolucion
    SET Devuelto = 1,
        Fecha_Devolucion = SYSDATE
    WHERE Id_Devolucion_PK = v_Id_Devolucion;

    -- Marcar el libro como disponible
    UPDATE Libro
    SET Disponible = 1
    WHERE Id_Libro_PK = v_Id_Libro;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Devolución registrada correctamente.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'No se encontró el préstamo o la devolución asociada.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;

--Registrar_Sanción

CREATE OR REPLACE PROCEDURE Registrar_Sancion (
    p_Id_Devolucion IN NUMBER
) AS
    v_Devuelto NUMBER(1);
    v_Monto_Sancion NUMBER(10, 2);
    v_Id_Usuario NUMBER;
    v_new_id NUMBER;
BEGIN
    -- Verificar si la devolución existe
    SELECT COUNT(*) INTO v_Devuelto
    FROM Devolucion
    WHERE Id_Devolucion_PK = p_Id_Devolucion;

    IF v_Devuelto = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró la devolución especificada.');
        RETURN;
    END IF;

    -- Verificar si ya ha sido devuelto
    SELECT Devuelto INTO v_Devuelto
    FROM Devolucion
    WHERE Id_Devolucion_PK = p_Id_Devolucion;

    IF v_Devuelto = 1 THEN
        DBMS_OUTPUT.PUT_LINE('No hay sanción. El libro ya fue devuelto.');
        RETURN;
    END IF;

    -- Calcular el monto de la sanción usando la función Calcular_Multa
    v_Monto_Sancion := Calcular_Multa(p_Id_Devolucion);

    IF v_Monto_Sancion <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('No hay sanción. Aún dentro del plazo.');
        RETURN;
    END IF;

    -- Obtener el usuario a partir del préstamo
    SELECT P.Id_Usuario_FK
    INTO v_Id_Usuario
    FROM Prestamo P
    JOIN Devolucion D ON D.Id_Prestamo_FK = P.Id_Prestamo_PK
    WHERE D.Id_Devolucion_PK = p_Id_Devolucion;

    -- Obtener nuevo ID de sanción
    SELECT NVL(MAX(Id_Sancion_PK), 0) + 1 INTO v_new_id FROM Sancion;

    -- Insertar sanción
    INSERT INTO Sancion (
        Id_Sancion_PK,
        Id_Usuario_FK,
        Id_Devolucion_FK,
        Monto,
        Pagado
    ) VALUES (
        v_new_id,
        v_Id_Usuario,
        p_Id_Devolucion,
        v_Monto_Sancion,
        0
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Sanción registrada correctamente. Monto: ?' || v_Monto_Sancion);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Datos no encontrados.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Agregar_Libro 
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
    
    -- Asociar categoría
    INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK)
    VALUES (v_new_libro_id, p_Id_Categoria);
    
    -- Generar nuevo Id para compra
    SELECT NVL(MAX(Id_Compra_PK), 0) + 1 INTO v_new_compra_id FROM Compra;
    
    -- Registrar compra
    INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra)
    VALUES (v_new_compra_id, p_Id_Proveedor, v_new_libro_id, p_Precio, SYSDATE);
    
    COMMIT;
END;

--Funciones

--Calcula cuántos días han pasado desde la fecha límite de devolución, y retorna la multa en colones (?100 por día de atraso).
--sql dinamico:

CREATE OR REPLACE FUNCTION Calcular_Multa(p_Id_Devolucion IN NUMBER)
RETURN NUMBER
AS
    v_Fecha_Limite DATE;
    v_Fecha_Actual DATE := SYSDATE;
    v_Dias_Atraso NUMBER;
    v_Multa NUMBER;
BEGIN
    EXECUTE IMMEDIATE '
        SELECT Fecha_Devolucion
        FROM Devolucion
        WHERE Id_Devolucion_PK = :1'
    INTO v_Fecha_Limite
    USING p_Id_Devolucion;

    IF v_Fecha_Actual > v_Fecha_Limite THEN
        v_Dias_Atraso := TRUNC(v_Fecha_Actual - v_Fecha_Limite);
        v_Multa := v_Dias_Atraso * 100;
    ELSE
        v_Multa := 0;
    END IF;

    RETURN v_Multa;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN -1;
END;

--Cuenta cuántos préstamos tiene el usuario que aún no han sido devueltos.
--sql dinamico:

CREATE OR REPLACE FUNCTION Contar_Prestamos_Usuario(p_Id_Usuario IN NUMBER)
RETURN NUMBER
AS
    v_Cantidad NUMBER;
BEGIN
    EXECUTE IMMEDIATE '
        SELECT COUNT(*)
        FROM Prestamo p
        JOIN Devolucion d ON p.Id_Prestamo_PK = d.Id_Prestamo_FK
        WHERE p.Id_Usuario_FK = :1
        AND d.Devuelto = 0'
    INTO v_Cantidad
    USING p_Id_Usuario;

    RETURN v_Cantidad;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN -1;
END;

--Cursores

--Cursor de prestamos y devoluciones
CREATE OR REPLACE PROCEDURE CURSOR_PRESTAMO (
    PID IN NUMBER,
    P_CURSOR OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN P_CURSOR FOR
        SELECT P.ID_PRESTAMO_PK, D.ID_DEVOLUCION_PK
        FROM PRESTAMO P
        JOIN DEVOLUCION D ON P.ID_PRESTAMO_PK = D.ID_PRESTAMO_FK
        WHERE P.ID_USUARIO_FK = PID
        AND D.DEVUELTO = 0;
END;

--Cursor de Sistema

--Cursor para ver usuarios
CREATE OR REPLACE PROCEDURE Listar_Usuarios (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT Id_Usuario_PK, Nombre || ' ' || Apellido
        FROM Usuario
        ORDER BY 1;
END;

--Llamado al cursor para ver usuarios
CREATE OR REPLACE PROCEDURE Call_Listar_Usuarios
AS
    DATOS SYS_REFCURSOR;     
    VID NUMBER;
    VNOM VARCHAR2(150);
BEGIN
    Listar_Usuarios(DATOS);
    LOOP
        FETCH DATOS INTO VID,VNOM;
        EXIT WHEN DATOS%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(VID || ' ' || VNOM);
    END LOOP;
    CLOSE DATOS;
END CALL_Listar_Usuarios;    

--Cursor para ver bibliotecarios

CREATE OR REPLACE PROCEDURE Listar_Bibliotecarios(p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT Id_Bibliotecario_PK, Nombre || ' ' || Apellido
        FROM Bibliotecario
        ORDER BY 1;
END;

--Llamado al cursor para ver bibliotecarios

CREATE OR REPLACE PROCEDURE Call_Listar_Bibliotecarios
AS
    DATOS SYS_REFCURSOR;     
    VID NUMBER;
    VNOM VARCHAR2(150);
BEGIN
    Listar_Bibliotecarios(DATOS);
    LOOP
        FETCH DATOS INTO VID,VNOM;
        EXIT WHEN DATOS%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(VID || ' ' || VNOM);
    END LOOP;
    CLOSE DATOS;
END Call_Listar_Bibliotecarios; 

--Cursor para ver proveedores

CREATE OR REPLACE PROCEDURE Listar_Proveedores(p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT Id_Proveedor_PK, Nombre
        FROM Proveedor
        ORDER BY 1;
END;

--Llamado al cursor para ver proveedores

CREATE OR REPLACE PROCEDURE Call_Listar_Proveedores
AS
    DATOS SYS_REFCURSOR;     
    VID NUMBER;
    VNOM VARCHAR2(150);
BEGIN
    Listar_Proveedores(DATOS);
    LOOP
        FETCH DATOS INTO VID,VNOM;
        EXIT WHEN DATOS%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(VID || ' ' || VNOM);
    END LOOP;
    CLOSE DATOS;
END Call_Listar_Proveedores; 

--Cursor para ver autores

CREATE OR REPLACE PROCEDURE Listar_Autores(p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT Id_Autor_PK, Nombre || ' ' || Apellido, NAcionalidad
        FROM Autor
        ORDER BY 1;
END;

-- Llamado al cursor para ver autores

CREATE OR REPLACE PROCEDURE Call_Listar_Autores
AS
    DATOS SYS_REFCURSOR;     
    VID NUMBER;
    VNOM VARCHAR2(150);
    VNAC autor.nacionalidad%type;
BEGIN
    Listar_Autores(DATOS);
    LOOP
        FETCH DATOS INTO VID,VNOM, VNAC;
        EXIT WHEN DATOS%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(VID || ' ' || VNOM);
    END LOOP;
    CLOSE DATOS;
END Call_Listar_Autores; 

--Cursor para ver categorias

CREATE OR REPLACE PROCEDURE Listar_Categorias (p_cursor OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT Id_Categoria_PK, Nombre
        FROM Categoria
        ORDER BY 1;
END;

--Llamado al cursor para ver categorias

CREATE OR REPLACE PROCEDURE Call_Listar_Categorias 
AS
    DATOS SYS_REFCURSOR;     
    VID NUMBER;
    VNOM VARCHAR2(150);
BEGIN
    Listar_Categorias(DATOS);
    LOOP
        FETCH DATOS INTO VID,VNOM;
        EXIT WHEN DATOS%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(VID || ' ' || VNOM);
    END LOOP;
    CLOSE DATOS;
END Call_Listar_Categorias; 

--Paquetes

--Cabecera paquete de prestamos
CREATE OR REPLACE PACKAGE pkg_prestamos AS
    PROCEDURE Realizar_Prestamo (
        p_Id_Libro IN NUMBER,
        p_Id_Usuario IN NUMBER,
        p_Id_Bibliotecario IN NUMBER
    );

    PROCEDURE Registrar_Devolucion (
        p_Id_Prestamo IN NUMBER
    );

    PROCEDURE Registrar_Sancion (
        p_Id_Devolucion IN NUMBER
    );

    FUNCTION Calcular_Multa(p_Id_Devolucion IN NUMBER) RETURN NUMBER;
    FUNCTION Contar_Prestamos_Usuario(p_Id_Usuario IN NUMBER) RETURN NUMBER;

    PROCEDURE CURSOR_PRESTAMO (
        PID IN NUMBER,
        P_CURSOR OUT SYS_REFCURSOR
    );
END pkg_prestamos;

--Body paquete de prestamos
CREATE OR REPLACE PACKAGE BODY pkg_prestamos AS

    -- Tu código actual de Realizar_Prestamo va aquí (sin el encabezado CREATE OR REPLACE ...)
    PROCEDURE Realizar_Prestamo (
        p_Id_Libro IN NUMBER,
        p_Id_Usuario IN NUMBER,
        p_Id_Bibliotecario IN NUMBER
    ) AS
        v_disponible NUMBER;
        v_new_id NUMBER;
        v_new_dev_id NUMBER;
        v_new_tra_id NUMBER;
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
    
        --Insertar Transaccion
        
        SELECT MAX(Id_Transaccion_PK) + 1 INTO v_new_tra_id FROM Transaccion;
        
        INSERT INTO Transaccion (
            Id_Transaccion_PK,
            Id_Prestamo_PK,
            Id_Usuario_FK,
            Id_Bibliotecario_FK,
            Id_Devolucion_FK,
            Fecha_Prestamo
        ) VALUES (
            v_new_tra_id,
            v_new_id,
            p_Id_Usuario,
            p_Id_Bibliotecario,
            v_new_dev_id,
            SYSDATE
        );
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Préstamo registrado correctamente.');
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'No se encontró el libro.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END Realizar_Prestamo;

    -- Código de Registrar_Devolucion
    PROCEDURE Registrar_Devolucion (
        p_Id_Prestamo IN NUMBER
    ) AS
        v_Id_Libro NUMBER;
        v_Id_Devolucion NUMBER;
        v_devuelto NUMBER;
    BEGIN
        -- Obtener ID del libro asociado al préstamo
        SELECT Id_Libro_PK INTO v_Id_Libro
        FROM Prestamo
        WHERE Id_Prestamo_PK = p_Id_Prestamo;
    
        -- Verificar si existe la devolución correspondiente
        SELECT Id_Devolucion_PK, Devuelto INTO v_Id_Devolucion, v_devuelto
        FROM Devolucion
        WHERE Id_Prestamo_FK = p_Id_Prestamo;
    
        -- Verificar si ya ha sido devuelto
        IF v_devuelto = 1 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Este préstamo ya ha sido devuelto.');
        END IF;
    
        -- Actualizar estado de devolución
        UPDATE Devolucion
        SET Devuelto = 1,
            Fecha_Devolucion = SYSDATE
        WHERE Id_Devolucion_PK = v_Id_Devolucion;
    
        -- Marcar el libro como disponible
        UPDATE Libro
        SET Disponible = 1
        WHERE Id_Libro_PK = v_Id_Libro;
    
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Devolución registrada correctamente.');
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'No se encontró el préstamo o la devolución asociada.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END Registrar_Devolucion;

    -- Código de Registrar_Sancion
    PROCEDURE Registrar_Sancion (
        p_Id_Devolucion IN NUMBER
    ) AS
        v_Devuelto NUMBER(1);
        v_Monto_Sancion NUMBER(10, 2);
        v_Id_Usuario NUMBER;
        v_new_id NUMBER;
    BEGIN
        -- Verificar si la devolución existe
        SELECT COUNT(*) INTO v_Devuelto
        FROM Devolucion
        WHERE Id_Devolucion_PK = p_Id_Devolucion;
    
        IF v_Devuelto = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No se encontró la devolución especificada.');
            RETURN;
        END IF;
    
        -- Verificar si ya ha sido devuelto
        SELECT Devuelto INTO v_Devuelto
        FROM Devolucion
        WHERE Id_Devolucion_PK = p_Id_Devolucion;
    
        IF v_Devuelto = 1 THEN
            DBMS_OUTPUT.PUT_LINE('No hay sanción. El libro ya fue devuelto.');
            RETURN;
        END IF;
    
        -- Calcular el monto de la sanción usando la función Calcular_Multa
        v_Monto_Sancion := Calcular_Multa(p_Id_Devolucion);
    
        IF v_Monto_Sancion <= 0 THEN
            DBMS_OUTPUT.PUT_LINE('No hay sanción. Aún dentro del plazo.');
            RETURN;
        END IF;
    
        -- Obtener el usuario a partir del préstamo
        SELECT P.Id_Usuario_FK
        INTO v_Id_Usuario
        FROM Prestamo P
        JOIN Devolucion D ON D.Id_Prestamo_FK = P.Id_Prestamo_PK
        WHERE D.Id_Devolucion_PK = p_Id_Devolucion;
    
        -- Obtener nuevo ID de sanción
        SELECT NVL(MAX(Id_Sancion_PK), 0) + 1 INTO v_new_id FROM Sancion;
    
        -- Insertar sanción
        INSERT INTO Sancion (
            Id_Sancion_PK,
            Id_Usuario_FK,
            Id_Devolucion_FK,
            Monto,
            Pagado
        ) VALUES (
            v_new_id,
            v_Id_Usuario,
            p_Id_Devolucion,
            v_Monto_Sancion,
            0
        );
    
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Sanción registrada correctamente. Monto: ?' || v_Monto_Sancion);
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Datos no encontrados.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END Registrar_Sancion;

    -- Función Calcular_Multa
    FUNCTION Calcular_Multa(p_Id_Devolucion IN NUMBER)
    RETURN NUMBER
    AS
        v_Fecha_Limite DATE;
        v_Fecha_Actual DATE := SYSDATE;
        v_Dias_Atraso NUMBER;
        v_Multa NUMBER;
    BEGIN
        EXECUTE IMMEDIATE '
            SELECT Fecha_Devolucion
            FROM Devolucion
            WHERE Id_Devolucion_PK = :1'
        INTO v_Fecha_Limite
        USING p_Id_Devolucion;
    
        IF v_Fecha_Actual > v_Fecha_Limite THEN
            v_Dias_Atraso := TRUNC(v_Fecha_Actual - v_Fecha_Limite);
            v_Multa := v_Dias_Atraso * 100;
        ELSE
            v_Multa := 0;
        END IF;
    
        RETURN v_Multa;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN -1;
    END;

    -- Función Contar_Prestamos_Usuario
    FUNCTION Contar_Prestamos_Usuario(p_Id_Usuario IN NUMBER)
    RETURN NUMBER
    AS
        v_Cantidad NUMBER;
    BEGIN
        EXECUTE IMMEDIATE '
            SELECT COUNT(*)
            FROM Prestamo p
            JOIN Devolucion d ON p.Id_Prestamo_PK = d.Id_Prestamo_FK
            WHERE p.Id_Usuario_FK = :1
            AND d.Devuelto = 0'
        INTO v_Cantidad
        USING p_Id_Usuario;
    
        RETURN v_Cantidad;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN -1;
    END;

    -- CURSOR_PRESTAMO
    PROCEDURE CURSOR_PRESTAMO (
        PID IN NUMBER,
        P_CURSOR OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN P_CURSOR FOR
            SELECT P.ID_PRESTAMO_PK, D.ID_DEVOLUCION_PK
            FROM PRESTAMO P
            JOIN DEVOLUCION D ON P.ID_PRESTAMO_PK = D.ID_PRESTAMO_FK
            WHERE P.ID_USUARIO_FK = PID
            AND D.DEVUELTO = 0;
    END CURSOR_PRESTAMO;

END pkg_prestamos;

--Cabecera paquete catalogo

CREATE OR REPLACE PACKAGE pkg_catalogo AS
    PROCEDURE Agregar_Libro (
        p_Titulo IN VARCHAR2,
        p_Fecha_Publicacion IN DATE,
        p_Id_Proveedor IN NUMBER,
        p_Precio IN NUMBER,
        p_Id_Autor IN NUMBER,
        p_Id_Categoria IN NUMBER
    );

    -- Cursores
    PROCEDURE Listar_Usuarios(p_cursor OUT SYS_REFCURSOR);
    PROCEDURE Call_Listar_Usuarios;

    PROCEDURE Listar_Bibliotecarios(p_cursor OUT SYS_REFCURSOR);
    PROCEDURE Call_Listar_Bibliotecarios;

    PROCEDURE Listar_Proveedores(p_cursor OUT SYS_REFCURSOR);
    PROCEDURE Call_Listar_Proveedores;

    PROCEDURE Listar_Autores(p_cursor OUT SYS_REFCURSOR);
    PROCEDURE Call_Listar_Autores;

    PROCEDURE Listar_Categorias(p_cursor OUT SYS_REFCURSOR);
    PROCEDURE Call_Listar_Categorias;
END pkg_catalogo;

--Body paquete catalogo

CREATE OR REPLACE PACKAGE BODY pkg_catalogo AS

    PROCEDURE Agregar_Libro (
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
        
        -- Asociar categoría
        INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK)
        VALUES (v_new_libro_id, p_Id_Categoria);
        
        -- Generar nuevo Id para compra
        SELECT NVL(MAX(Id_Compra_PK), 0) + 1 INTO v_new_compra_id FROM Compra;
        
        -- Registrar compra
        INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra)
        VALUES (v_new_compra_id, p_Id_Proveedor, v_new_libro_id, p_Precio, SYSDATE);
        
        COMMIT;
    END Agregar_Libro;

    PROCEDURE Listar_Usuarios(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT Id_Usuario_PK, Nombre || ' ' || Apellido
            FROM Usuario
            ORDER BY 1;
    END;

    PROCEDURE Call_Listar_Usuarios IS
        DATOS SYS_REFCURSOR;
        VID NUMBER;
        VNOM VARCHAR2(150);
    BEGIN
        Listar_Usuarios(DATOS);
        LOOP
            FETCH DATOS INTO VID,VNOM;
            EXIT WHEN DATOS%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(VID || ' ' || VNOM);
        END LOOP;
        CLOSE DATOS;
    END;

    PROCEDURE Listar_Bibliotecarios(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT Id_Bibliotecario_PK, Nombre || ' ' || Apellido
            FROM Bibliotecario
            ORDER BY 1;
    END;

    PROCEDURE Call_Listar_Bibliotecarios IS
        DATOS SYS_REFCURSOR;
        VID NUMBER;
        VNOM VARCHAR2(150);
    BEGIN
        Listar_Bibliotecarios(DATOS);
        LOOP
            FETCH DATOS INTO VID,VNOM;
            EXIT WHEN DATOS%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(VID || ' ' || VNOM);
        END LOOP;
        CLOSE DATOS;
    END;

    PROCEDURE Listar_Proveedores(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT Id_Proveedor_PK, Nombre
            FROM Proveedor
            ORDER BY 1;
    END;

    PROCEDURE Call_Listar_Proveedores IS
        DATOS SYS_REFCURSOR;
        VID NUMBER;
        VNOM VARCHAR2(150);
    BEGIN
        Listar_Proveedores(DATOS);
        LOOP
            FETCH DATOS INTO VID,VNOM;
            EXIT WHEN DATOS%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(VID || ' ' || VNOM);
        END LOOP;
        CLOSE DATOS;
    END;

    PROCEDURE Listar_Autores(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT Id_Autor_PK, Nombre || ' ' || Apellido, Nacionalidad
            FROM Autor
            ORDER BY 1;
    END;

    PROCEDURE Call_Listar_Autores IS
        DATOS SYS_REFCURSOR;
        VID NUMBER;
        VNOM VARCHAR2(150);
        VNAC autor.nacionalidad%type;
    BEGIN
        Listar_Autores(DATOS);
        LOOP
            FETCH DATOS INTO VID, VNOM, VNAC;
            EXIT WHEN DATOS%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(VID || ' ' || VNOM);
        END LOOP;
        CLOSE DATOS;
    END;

    PROCEDURE Listar_Categorias(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT Id_Categoria_PK, Nombre
            FROM Categoria
            ORDER BY 1;
    END;

    PROCEDURE Call_Listar_Categorias IS
        DATOS SYS_REFCURSOR;
        VID NUMBER;
        VNOM VARCHAR2(150);
    BEGIN
        Listar_Categorias(DATOS);
        LOOP
            FETCH DATOS INTO VID,VNOM;
            EXIT WHEN DATOS%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(VID || ' ' || VNOM);
        END LOOP;
        CLOSE DATOS;
    END;

END pkg_catalogo;
   
   
--Triggers

--Eliminar sanción previa antes de insertar una nueva

CREATE OR REPLACE TRIGGER trg_actualizar_sancion
BEFORE INSERT ON Sancion
FOR EACH ROW
DECLARE
    v_Existe NUMBER;
BEGIN
    -- Verificar si ya existe una sanción para el mismo usuario y devolución
    SELECT COUNT(*) INTO v_Existe
    FROM Sancion
    WHERE Id_Usuario_FK = :NEW.Id_Usuario_FK
      AND Id_Devolucion_FK = :NEW.Id_Devolucion_FK;

    IF v_Existe > 0 THEN
        DELETE FROM Sancion
        WHERE Id_Usuario_FK = :NEW.Id_Usuario_FK
          AND Id_Devolucion_FK = :NEW.Id_Devolucion_FK;
    END IF;
END;

--Actulizar sancion a pagada al devolver el libro
CREATE OR REPLACE TRIGGER trg_sancion_pagada
AFTER UPDATE OF Devuelto ON Devolucion
FOR EACH ROW
BEGIN
    -- Solo actualiza si el nuevo valor de Devuelto es 1 y el anterior no lo era
    IF :NEW.Devuelto = 1 AND :OLD.Devuelto <> 1 THEN
        UPDATE Sancion
        SET Pagado = 1
        WHERE Id_Devolucion_FK = :NEW.Id_Devolucion_PK
          AND Pagado = 0; -- Solo actualiza si aún no está pagado
    END IF;
END;

