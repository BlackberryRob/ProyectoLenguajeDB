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
JOIN Proveedor p ON c.Id_Proveedor_FK = p.Id_Proveedor_PK;

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

CREATE OR REPLACE PROCEDURE Registrar_Sancion(
    p_Id_Devolucion IN NUMBER
) AS
    v_Devuelto NUMBER(1);
    v_Fecha_Limite DATE;
    v_Fecha_Actual DATE := SYSDA
    v_Id_Usuario NUMBER;
    v_Monto_Sancion NUMBER(10, 2);
    v_Dias_Atraso NUMBER;
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

    -- Obtener el valor de Devuelto y la fecha límite (Fecha_Devolucion)
    SELECT Devuelto, Fecha_Devolucion
    INTO v_Devuelto, v_Fecha_Limite
    FROM Devolucion
    WHERE Id_Devolucion_PK = p_Id_Devolucion;

    IF v_Devuelto = 1 THEN
        DBMS_OUTPUT.PUT_LINE('No hay sanción. Devolución dentro del plazo.');
        RETURN;
    END IF;

    -- Si aún no ha devuelto el libro
    IF v_Fecha_Actual > v_Fecha_Limite THEN
        v_Dias_Atraso := TRUNC(v_Fecha_Actual - v_Fecha_Limite);
        v_Monto_Sancion := v_Dias_Atraso * 100; --se sancion con 100 colones por cada dia de atraso

        DBMS_OUTPUT.PUT_LINE('El monto de la sanción es: ' || v_Monto_Sancion);

        -- Obtener el usuario a partir de la devolución ? préstamo ? usuario
        SELECT P.Id_Usuario_FK
        INTO v_Id_Usuario
        FROM Prestamo P
        JOIN Devolucion D ON D.Id_Prestamo_FK = P.Id_Prestamo_PK
        WHERE D.Id_Devolucion_PK = p_Id_Devolucion;

        -- Obtener el nuevo ID de sanción
        SELECT NVL(MAX(Id_Sancion_PK), 0) + 1 INTO v_new_id FROM Sancion;

        -- Insertar la nueva sanción
        INSERT INTO Sancion (
            Id_Sancion_PK,
            Id_Usuario_FK,
            Id_Devolucion_FK,
            Monto,
            Pagado
        )
        VALUES (
            v_new_id,
            v_Id_Usuario,
            p_Id_Devolucion,
            v_Monto_Sancion,
            0
        );
    ELSE
        DBMS_OUTPUT.PUT_LINE('No hay sanción. Aún dentro del plazo.');
    END IF;
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
