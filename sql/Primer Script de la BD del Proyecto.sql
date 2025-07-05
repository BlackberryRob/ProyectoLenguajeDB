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

--6. Carga de datos inicial:
--Insertar entre 50 y 150 registros por tabla utilizando scripts SQL.

--Autor
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (1, 'Gabriel', 'García Márquez', 'Colombiana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (2, 'Isabel', 'Allende', 'Chilena');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (3, 'Mario', 'Vargas Llosa', 'Peruana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (4, 'Jorge Luis', 'Borges', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (5, 'Laura', 'Esquivel', 'Mexicana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (6, 'Carlos', 'Ruiz Zafón', 'Española');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (7, 'Julio', 'Cortázar', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (8, 'Paulo', 'Coelho', 'Brasileña');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (9, 'Elena', 'Poniatowska', 'Mexicana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (10, 'Eduardo', 'Galeano', 'Uruguaya');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (11, 'José', 'Saramago', 'Portuguesa');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (12, 'Reinaldo', 'Arenas', 'Cubana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (13, 'Ana María', 'Matute', 'Española');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (14, 'Antonio', 'Skármeta', 'Chilena');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (15, 'Homero', 'Aridjis', 'Mexicana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (16, 'Luis', 'Sepúlveda', 'Chilena');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (17, 'Cristina', 'Peri Rossi', 'Uruguaya');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (18, 'Rosario', 'Castellanos', 'Mexicana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (19, 'Juan', 'Rulfo', 'Mexicana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (20, 'Horacio', 'Quiroga', 'Uruguaya');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (21, 'César', 'Vallejo', 'Peruana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (22, 'Pablo', 'Neruda', 'Chilena');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (23, 'Octavio', 'Paz', 'Mexicana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (24, 'Alfonsina', 'Storni', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (25, 'Ricardo', 'Piglia', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (26, 'Silvina', 'Ocampo', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (27, 'José Emilio', 'Pacheco', 'Mexicana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (28, 'Ernesto', 'Sábato', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (29, 'Manuel', 'Puig', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (30, 'Claribel', 'Alegría', 'Nicaragüense');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (31, 'Juan', 'Gelman', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (32, 'María', 'Dueñas', 'Española');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (33, 'Fernando', 'Vallejo', 'Colombiana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (34, 'Rosa', 'Montero', 'Española');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (35, 'Carmen', 'Boullosa', 'Mexicana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (36, 'Ángeles', 'Mastretta', 'Mexicana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (37, 'Luis', 'Borges', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (38, 'Soledad', 'Puértolas', 'Española');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (39, 'Daniel', 'Moyano', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (40, 'Beatriz', 'Guido', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (41, 'Ricardo', 'Güiraldes', 'Argentina');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (42, 'Vicente', 'Huidobro', 'Chilena');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (43, 'Alejo', 'Carpentier', 'Cubana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (44, 'Josefina', 'Pla', 'Paraguaya');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (45, 'José', 'Martí', 'Cubana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (46, 'Pedro', 'Lemebel', 'Chilena');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (47, 'Carmen', 'Laforet', 'Española');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (48, 'Rebeca', 'Lane', 'Guatemalteca');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (49, 'Eduardo', 'Carranza', 'Colombiana');
INSERT INTO Autor (Id_Autor_PK, Nombre, Apellido, Nacionalidad) VALUES (50, 'Fina', 'García Marruz', 'Cubana');

--Categoria
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (1, 'Novela');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (2, 'Cuento');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (3, 'Poesía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (4, 'Ensayo');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (5, 'Teatro');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (6, 'Biografía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (7, 'Autobiografía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (8, 'Ficción Histórica');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (9, 'Realismo Mágico');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (10, 'Literatura Infantil');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (11, 'Ciencia Ficción');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (12, 'Fantasía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (13, 'Terror');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (14, 'Misterio');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (15, 'Romance');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (16, 'Aventura');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (17, 'Humor');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (18, 'Policial');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (19, 'Crónica');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (20, 'Narrativa breve');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (21, 'Mitología');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (22, 'Épica');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (23, 'Distopía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (24, 'Utopía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (25, 'Memorias');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (26, 'Viajes');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (27, 'Didáctica');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (28, 'Filología');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (29, 'Política');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (30, 'Filosofía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (31, 'Sociología');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (32, 'Psicología');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (33, 'Religión');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (34, 'Ética');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (35, 'Economía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (36, 'Ecología');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (37, 'Educación');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (38, 'Arquitectura');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (39, 'Arte');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (40, 'Música');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (41, 'Cine');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (42, 'Fotografía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (43, 'Medicina');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (44, 'Astronomía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (45, 'Historia');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (46, 'Geografía');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (47, 'Cómic');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (48, 'Ensayo Científico');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (49, 'Autoayuda');
INSERT INTO Categoria (Id_Categoria_PK, Nombre) VALUES (50, 'Tecnología');

--Libro
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (1, 'Cien años de soledad', TO_DATE('1967-05-30', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (2, 'La casa de los espíritus', TO_DATE('1982-08-12', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (3, 'Rayuela', TO_DATE('1963-06-28', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (4, 'Pedro Páramo', TO_DATE('1955-03-19', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (5, 'El túnel', TO_DATE('1948-09-05', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (6, 'Los detectives salvajes', TO_DATE('1998-02-20', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (7, 'La sombra del viento', TO_DATE('2001-06-06', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (8, 'Aura', TO_DATE('1962-11-23', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (9, 'El Aleph', TO_DATE('1949-08-15', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (10, 'La tregua', TO_DATE('1960-04-25', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (11, 'El coronel no tiene quien le escriba', TO_DATE('1961-10-20', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (12, 'La ciudad y los perros', TO_DATE('1963-10-18', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (13, 'Paula', TO_DATE('1994-05-14', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (14, 'El amor en los tiempos del cólera', TO_DATE('1985-09-05', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (15, 'Como agua para chocolate', TO_DATE('1989-01-01', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (16, 'El aliento del cielo', TO_DATE('2009-03-10', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (17, 'Del amor y otros demonios', TO_DATE('1994-04-07', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (18, 'Santa Evita', TO_DATE('1995-07-01', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (19, 'El lector de Julio Verne', TO_DATE('2012-09-15', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (20, 'El Zorro', TO_DATE('2005-11-22', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (21, 'La fiesta del Chivo', TO_DATE('2000-05-12', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (22, 'Crónica de una muerte anunciada', TO_DATE('1981-08-01', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (23, 'Los pasos perdidos', TO_DATE('1953-02-18', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (24, 'El reino de este mundo', TO_DATE('1949-10-10', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (25, 'Los ríos profundos', TO_DATE('1958-06-03', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (26, 'Doña Bárbara', TO_DATE('1929-04-17', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (27, 'El entenado', TO_DATE('1983-09-22', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (28, 'Bomarzo', TO_DATE('1962-01-12', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (29, 'La invención de Morel', TO_DATE('1940-06-30', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (30, 'Facundo', TO_DATE('1845-10-08', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (31, 'La región más transparente', TO_DATE('1958-03-14', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (32, 'Sombra sobre vidrio roto', TO_DATE('2008-11-04', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (33, 'La Reina del Sur', TO_DATE('2002-02-25', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (34, 'La voz dormida', TO_DATE('2002-10-01', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (35, 'La mujer habitada', TO_DATE('1988-05-19', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (36, 'La distancia que nos separa', TO_DATE('2015-03-09', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (37, 'El ruido de las cosas al caer', TO_DATE('2011-06-20', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (38, 'Caballo de fuego', TO_DATE('2010-04-11', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (39, 'El susurro de la mujer ballena', TO_DATE('2007-01-22', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (40, 'Papeles inesperados', TO_DATE('2009-05-12', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (41, '2666', TO_DATE('2004-12-07', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (42, '2666', TO_DATE('2004-12-07', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (43, 'El espíritu de mis padres sigue subiendo en la lluvia', TO_DATE('2011-08-09', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (44, 'El secreto del orfebre', TO_DATE('2003-04-02', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (45, 'Los enamorados', TO_DATE('2015-10-11', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (46, 'El país de las mujeres', TO_DATE('2011-03-01', 'YYYY-MM-DD'), 0);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (47, 'Demasiados héroes', TO_DATE('2009-06-15', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (48, 'El infinito en la palma de la mano', TO_DATE('2008-09-10', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (49, 'Mujeres de ojos grandes', TO_DATE('1990-01-18', 'YYYY-MM-DD'), 1);
INSERT INTO Libro (Id_Libro_PK, Titulo, Fecha_Publicacion, Disponible) VALUES (50, 'La dimensión desconocida', TO_DATE('2016-02-27', 'YYYY-MM-DD'), 1);

--Libro_Autor
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (1, 1);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (2, 2);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (3, 7);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (3, 4);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (4, 19);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (4, 9);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (5, 28);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (6, 20);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (7, 6);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (7, 29);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (8, 14);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (9, 4);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (9, 37);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (10, 10);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (11, 1);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (12, 3);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (13, 2);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (14, 1);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (14, 26);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (15, 5);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (15, 18);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (16, 35);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (17, 1);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (18, 24);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (18, 42);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (19, 32);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (20, 2);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (20, 47);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (21, 3);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (22, 1);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (23, 25);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (24, 43);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (25, 21);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (26, 15);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (27, 29);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (28, 39);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (29, 6);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (30, 41);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (31, 27);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (31, 22);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (32, 34);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (33, 38);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (34, 38);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (35, 30);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (36, 33);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (37, 33);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (37, 11);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (38, 45);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (39, 48);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (40, 7);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (41, 6);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (42, 43);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (43, 37);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (44, 13);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (45, 40);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (46, 36);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (46, 44);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (47, 38);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (48, 31);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (49, 36);
INSERT INTO Libro_Autor (Id_Libro_PK, Id_Autor_PK) VALUES (50, 49);

-- Libro_Categoria
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (1, 9);  -- Realismo Mágico
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (2, 1);  -- Novela
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (3, 2);  -- Cuento
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (4, 9);  -- Realismo Mágico
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (5, 14); -- Misterio
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (6, 18); -- Policial
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (7, 1);  -- Novela
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (8, 2);   -- Cuento
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (8, 13);  -- Terror
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (9, 2);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (9, 3);   -- Poesía
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (10, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (10, 15); -- Romance
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (11, 9);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (12, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (13, 6);  -- Biografía
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (13, 25); -- Memorias
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (14, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (14, 15);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (15, 9);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (15, 17); -- Humor
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (16, 12);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (16, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (17, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (17, 15);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (18, 8);  -- Ficción histórica
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (18, 6);  -- Biografía
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (19, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (19, 26); -- Viajes
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (20, 16); -- Aventura
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (20, 9);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (21, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (22, 14);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (23, 4);  -- Ensayo
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (24, 8);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (25, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (26, 8);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (27, 2);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (28, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (29, 11); -- Ciencia ficción
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (29, 24); -- Utopía
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (30, 4);   -- Ensayo
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (30, 45);  -- Historia
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (31, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (31, 29);  -- Política
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (32, 12);  -- Fantasía
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (33, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (33, 14);  -- Misterio
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (34, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (34, 46);  -- Geografía
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (35, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (36, 27);  -- Didáctica
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (36, 30);  -- Filosofía
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (37, 8);   -- Ficción Histórica
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (38, 16);  -- Aventura
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (38, 15);  -- Romance
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (39, 34);  -- Ética
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (40, 2);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (40, 3);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (41, 11);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (41, 23);  -- Distopía
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (42, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (42, 31);  -- Sociología
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (43, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (43, 47);  -- Cómic
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (44, 8);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (45, 15);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (46, 1);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (46, 33);  -- Religión
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (47, 29);  -- Política
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (48, 25);  -- Memorias
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (49, 15);
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (49, 17);  -- Humor
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (50, 24);  -- Utopía
INSERT INTO Libro_Categoria (Id_Libro_PK, Id_Categoria_PK) VALUES (50, 10);  -- Literatura infantil

--Proveedor
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (1, 'Distribuidora Literaria Centroamérica', '2284-1234', 'contacto@dilica.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (2, 'Mundo Editorial S.A.', '2225-9876', 'ventas@mundoeditorial.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (3, 'Ediciones del Saber', '2261-4433', 'info@saberediciones.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (4, 'Lecturas Universales', '2290-1122', 'servicio@lecturasuniv.net');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (5, 'Impresos Académicos', '2244-5566', 'impresos@academicos.co.cr');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (6, 'Libros Ágora', '2217-7788', 'agora@librosmail.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (7, 'Bibliotienda Express', '2233-8899', 'ventas@bibliotienda.net');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (8, 'Editorial Horizonte', '2277-3366', 'contacto@horizonteeditorial.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (9, 'LectoDistribuciones', '2202-4477', 'pedidos@lectodistribuciones.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (10, 'Panamericana Books', '2250-0033', 'info@panamericanabooks.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (11, 'Libromundo Global', '2205-7788', 'ventas@libromundo.cr');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (12, 'Impresiones Bolívar', '2280-9988', 'editorial@bolivarimpresiones.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (13, 'Lectura Viva', '2239-1111', 'info@lecturaviva.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (14, 'Distribuciones Quetzal', '2266-4411', 'pedidos@quetzal.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (15, 'Centro Editorial Mayasur', '2210-3344', 'mayasur@editorialeslatam.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (16, 'EcoEditores', '2204-5566', 'info@ecoeditores.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (17, 'Textos y Tinta S.A.', '2271-3344', 'contacto@textostinta.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (18, 'Editorial CostaVerde', '2222-9922', 'ventas@costaverdeed.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (19, 'Editorial Amazonas', '2289-4400', 'amazonased@editoreslat.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (20, 'Ediciones Raíz', '2200-7766', 'contacto@raizediciones.net');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (21, 'Nueva Palabra Editores', '2260-9988', 'ventas@nuevapalabra.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (22, 'Lectoespacio', '2291-1144', 'info@lectoespacio.cr');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (23, 'Distribuidora El Rincón', '2230-8866', 'elrincon@libroslat.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (24, 'Libros de Monteverde', '2240-9900', 'atencion@monteverdelibros.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (25, 'Editorial Siglo XXI', '2258-7799', 'ventas@sigloxxi.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (26, 'Luz y Letra', '2285-3311', 'contacto@luzyletra.cr');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (27, 'Editorial Valle Azul', '2229-7744', 'info@valleazul.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (28, 'LibroSur Ltda.', '2297-6655', 'librosur@literatura.net');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (29, 'Palabra y Papel', '2219-8800', 'pedidos@palabraypapel.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (30, 'Editorial El Búho', '2227-3388', 'editorial@elbuho.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (31, 'Contenidos Prisma', '2247-2200', 'info@prismaedit.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (32, 'Librería Aurora', '2273-1100', 'ventas@auroralibros.cr');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (33, 'Mística Editorial', '2295-6677', 'editor@misticaed.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (34, 'Amanuense Distribución', '2203-1234', 'pedidos@amanuense.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (35, 'Distribuidora Selva', '2266-3344', 'selva@libroslatam.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (36, 'Inkpress Ltda.', '2283-5566', 'ventas@inkpresslat.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (37, 'Editorial Surco', '2201-4411', 'surcoed@contacto.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (38, 'Vértice Ediciones', '2292-4433', 'ventas@verticeed.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (39, 'Editorial Esencia', '2275-6600', 'info@esenciaeditorial.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (40, 'Casa del Libro CR', '2238-2202', 'cr@casadellibro.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (41, 'Editorial Caligrama', '2241-3366', 'editorial@caligrama.cr');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (42, 'Publicaciones Encino', '2226-7788', 'encino@edicioneslat.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (43, 'Editorial Volcán', '2264-1188', 'info@editorialvolcan.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (44, 'Lecturística Costa Rica', '2278-5599', 'contacto@lecturistica.cr');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (45, 'Imprenta Altamira', '2253-1212', 'altamira@impresioneslat.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (46, 'Distribuidora Volumen', '2209-3311', 'volumen@envioslibros.net');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (47, 'Ediciones Horizonte Sur', '2298-7755', 'ventas@horizontesur.com');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (48, 'Editorial Origen', '2232-6688', 'info@editorialorigen.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (49, 'Fundación Lectura Abierta', '2218-7788', 'fundacion@lecturaabierta.org');
INSERT INTO Proveedor (Id_Proveedor_PK, Nombre, Telefono, Correo) VALUES (50, 'Distribuciones Estrofa', '2242-9901', 'ventas@estrofaed.com');

--Compra
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (1, 3, 1, 22.50, TO_DATE('2018-01-15', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (2, 7, 2, 19.99, TO_DATE('2019-03-28', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (3, 2, 3, 25.00, TO_DATE('2020-07-10', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (4, 10, 4, 18.75, TO_DATE('2018-09-12', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (5, 5, 5, 21.00, TO_DATE('2022-11-22', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (6, 9, 6, 27.45, TO_DATE('2021-02-17', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (7, 1, 7, 19.20, TO_DATE('2020-05-01', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (8, 11, 8, 16.80, TO_DATE('2018-10-03', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (9, 8, 9, 20.35, TO_DATE('2019-04-21', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (10, 4, 10, 24.99, TO_DATE('2021-06-13', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (11, 12, 11, 23.99, TO_DATE('2021-08-10', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (12, 13, 12, 20.45, TO_DATE('2022-01-20', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (13, 14, 13, 28.90, TO_DATE('2021-03-18', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (14, 15, 14, 26.50, TO_DATE('2020-10-03', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (15, 16, 15, 21.10, TO_DATE('2023-02-14', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (16, 17, 16, 29.99, TO_DATE('2022-06-30', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (17, 18, 17, 18.80, TO_DATE('2020-12-11', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (18, 19, 18, 22.00, TO_DATE('2023-05-07', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (19, 20, 19, 24.40, TO_DATE('2022-08-19', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (20, 21, 20, 19.95, TO_DATE('2021-01-05', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (21, 22, 21, 31.00, TO_DATE('2020-04-23', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (22, 23, 22, 33.25, TO_DATE('2019-07-10', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (23, 24, 23, 17.80, TO_DATE('2023-03-15', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (24, 25, 24, 28.60, TO_DATE('2022-10-28', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (25, 26, 25, 15.99, TO_DATE('2024-01-17', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (26, 27, 26, 27.70, TO_DATE('2019-09-22', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (27, 28, 27, 30.10, TO_DATE('2020-11-05', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (28, 29, 28, 16.00, TO_DATE('2023-09-01', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (29, 30, 29, 22.75, TO_DATE('2021-07-19', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (30, 31, 30, 34.80, TO_DATE('2022-05-03', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (31, 32, 31, 21.90, TO_DATE('2021-11-11', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (32, 33, 32, 26.99, TO_DATE('2023-06-27', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (33, 34, 33, 18.20, TO_DATE('2024-04-08', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (34, 35, 34, 20.00, TO_DATE('2020-02-01', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (35, 36, 35, 32.40, TO_DATE('2021-03-30', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (36, 37, 36, 19.75, TO_DATE('2019-05-08', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (37, 38, 37, 23.00, TO_DATE('2022-08-14', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (38, 39, 38, 29.10, TO_DATE('2019-12-20', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (39, 40, 39, 20.80, TO_DATE('2021-05-16', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (40, 41, 40, 17.60, TO_DATE('2022-12-30', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (41, 42, 41, 24.70, TO_DATE('2020-09-06', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (42, 43, 42, 27.30, TO_DATE('2023-11-09', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (43, 44, 43, 23.20, TO_DATE('2020-06-13', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (44, 45, 44, 19.40, TO_DATE('2023-01-19', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (45, 46, 45, 22.85, TO_DATE('2020-08-25', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (46, 47, 46, 26.70, TO_DATE('2022-11-07', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (47, 48, 47, 20.10, TO_DATE('2023-04-22', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (48, 49, 48, 18.99, TO_DATE('2019-06-30', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (49, 50, 49, 24.60, TO_DATE('2021-09-05', 'YYYY-MM-DD'));
INSERT INTO Compra (Id_Compra_PK, Id_Proveedor_FK, Id_Libro_FK, Precio, Fecha_Compra) VALUES (50, 6, 50, 23.50, TO_DATE('2024-02-18', 'YYYY-MM-DD'));

--Usuarios
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (1, 'María', 'González', 'maria.gonzalez01@mail.com', '88881234');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (2, 'José', 'Ramírez', 'jose.ramirez88@mail.com', '88770011');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (3, 'Ana', 'Hernández', 'ana.hdz15@mail.com', '88994422');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (4, 'Luis', 'Martínez', 'luis.mtz05@mail.com', '88884455');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (5, 'Sofía', 'Castro', 'sofia.castro91@mail.com', '88221133');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (6, 'Andrés', 'Vargas', 'andres.vargas17@mail.com', '88118877');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (7, 'Laura', 'López', 'laura.lopez23@mail.com', '88885566');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (8, 'Carlos', 'Jiménez', 'carlos.jmz10@mail.com', '88009977');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (9, 'Valeria', 'Torres', 'val.torres@mail.com', '88993322');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (10, 'Marco', 'Cruz', 'marco.cruz82@mail.com', '88776655');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (11, 'Daniela', 'Soto', 'daniela.soto05@mail.com', '88996677');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (12, 'Esteban', 'Mora', 'esteban.mora22@mail.com', '88887744');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (13, 'Natalia', 'Carvajal', 'natalia.carvajal@mail.com', '88112233');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (14, 'David', 'Rojas', 'david.rojas79@mail.com', '88223344');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (15, 'Camila', 'Araya', 'camila.araya13@mail.com', '88889966');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (16, 'Javier', 'Salazar', 'javier.salazar@mail.com', '88001122');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (17, 'Lucía', 'Corrales', 'lucia.corrales92@mail.com', '88774488');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (18, 'Diego', 'Barquero', 'diego.barquero@mail.com', '88332211');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (19, 'Mónica', 'Sequeira', 'monica.sequeira@mail.com', '88668822');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (20, 'Sebastián', 'Campos', 'sebastian.campos@mail.com', '88445566');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (21, 'Patricia', 'Alpízar', 'patricia.alpizar@mail.com', '88556644');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (22, 'Mauricio', 'Quiros', 'mauricio.quiros@mail.com', '88990077');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (23, 'Adriana', 'Venegas', 'adriana.venegas@mail.com', '88005599');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (24, 'Ricardo', 'Fernández', 'ricardo.fernandez@mail.com', '88114433');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (25, 'Andrea', 'Núñez', 'andrea.nunez@mail.com', '88446655');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (26, 'Pablo', 'León', 'pablo.leon@mail.com', '88887722');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (27, 'Karla', 'Solano', 'karla.solano@mail.com', '88229944');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (28, 'Felipe', 'Ureña', 'felipe.urena@mail.com', '88007766');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (29, 'Rebeca', 'Vargas', 'rebeca.vargas@mail.com', '88997711');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (30, 'Manuel', 'Alfaro', 'manuel.alfaro@mail.com', '88884422');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (31, 'Laura', 'Corrales', 'laura.corrales@mail.com', '88003366');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (32, 'Jonathan', 'Pérez', 'jonathan.perez@mail.com', '88776633');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (33, 'Melisa', 'Sáenz', 'melisa.saenz@mail.com', '88667799');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (34, 'Cristian', 'Arce', 'cristian.arce@mail.com', '88449933');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (35, 'Verónica', 'Esquivel', 'veronica.esquivel@mail.com', '88992200');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (36, 'Luis', 'Calderón', 'luis.calderon@mail.com', '88112288');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (37, 'Nathalie', 'Alvarado', 'nathalie.alvarado@mail.com', '88331155');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (38, 'Enrique', 'Marín', 'enrique.marin@mail.com', '88225544');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (39, 'Tatiana', 'Luna', 'tatiana.luna@mail.com', '88771100');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (40, 'Alexander', 'Valverde', 'alex.valverde@mail.com', '88998833');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (41, 'Yolanda', 'Zúñiga', 'yolanda.zuniga@mail.com', '88006611');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (42, 'Gabriel', 'Morales', 'gabriel.morales@mail.com', '88221100');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (43, 'Carolina', 'Navarro', 'carolina.navarro@mail.com', '88889922');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (44, 'Álvaro', 'Méndez', 'alvaro.mendez@mail.com', '88443377');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (45, 'Mariana', 'Delgado', 'mariana.delgado@mail.com', '88664411');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (46, 'Rodrigo', 'Leiva', 'rodrigo.leiva@mail.com', '88332255');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (47, 'Paola', 'Campos', 'paola.campos@mail.com', '88776699');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (48, 'Emilio', 'Rivera', 'emilio.rivera@mail.com', '88110077');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (49, 'Isabel', 'Del Valle', 'isabel.dv@mail.com', '88441166');
INSERT INTO Usuario (Id_Usuario_PK, Nombre, Apellido, Correo, Telefono) VALUES (50, 'Tomás', 'Zamora', 'tomas.zamora@mail.com', '88994400');

--Bibliotecario
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (1, 'Rocío', 'Zamora');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (2, 'Alan', 'Sandoval');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (3, 'Marlen', 'Durán');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (4, 'Rafael', 'Villalobos');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (5, 'Noelia', 'Pineda');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (6, 'Camilo', 'Sánchez');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (7, 'Evelyn', 'Granados');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (8, 'Andrés', 'Cordero');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (9, 'Rosa', 'Segura');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (10, 'Mauricio', 'Bolaños');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (11, 'Karina', 'Vargas');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (12, 'Esteban', 'Méndez');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (13, 'Daniela', 'Solís');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (14, 'Julio', 'Alpízar');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (15, 'Virginia', 'Calvo');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (16, 'Ignacio', 'Campos');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (17, 'Milena', 'Fallas');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (18, 'Óscar', 'Céspedes');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (19, 'Ileana', 'Chacón');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (20, 'Ronald', 'Arrieta');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (21, 'Laura', 'Guzmán');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (22, 'Kevin', 'Venegas');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (23, 'Fabiola', 'Porras');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (24, 'Joaquín', 'Valverde');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (25, 'Adriana', 'León');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (26, 'Héctor', 'Esquivel');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (27, 'Gabriela', 'Rodríguez');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (28, 'Eduardo', 'Fonseca');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (29, 'Silvia', 'Lozano');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (30, 'Jorge', 'Mora');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (31, 'Marisol', 'Cortés');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (32, 'Pablo', 'Sibaja');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (33, 'Lucía', 'Montoya');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (34, 'Carlos', 'Agüero');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (35, 'Jazmín', 'Arias');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (36, 'Gerardo', 'López');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (37, 'Rebeca', 'Salas');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (38, 'Harold', 'Valerio');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (39, 'Carla', 'Quesada');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (40, 'Francisco', 'Céspedes');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (41, 'Tatiana', 'Rojas');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (42, 'Manuel', 'Alvarado');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (43, 'Natalie', 'Vega');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (44, 'Samuel', 'Sequeira');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (45, 'Vanessa', 'Delgado');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (46, 'Leonardo', 'Cambronero');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (47, 'Fernanda', 'Méndez');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (48, 'Eric', 'Villalta');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (49, 'Ximena', 'Granados');
INSERT INTO Bibliotecario (Id_Bibliotecario_PK, Nombre, Apellido) VALUES (50, 'Tomás', 'Rojas');

--Prestamos
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (1, 2, 1, TO_DATE('2022-08-15', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (2, 3, 2, TO_DATE('2022-09-12', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (3, 5, 3, TO_DATE('2022-10-03', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (4, 6, 4, TO_DATE('2022-11-01', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (5, 7, 5, TO_DATE('2022-12-10', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (6, 10, 6, TO_DATE('2023-01-15', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (7, 11, 7, TO_DATE('2023-02-03', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (8, 12, 8, TO_DATE('2023-03-19', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (9, 14, 9, TO_DATE('2023-04-12', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (10, 15, 10, TO_DATE('2023-05-02', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (11, 17, 11, TO_DATE('2023-05-24', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (12, 18, 12, TO_DATE('2023-06-14', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (13, 20, 13, TO_DATE('2023-07-01', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (14, 22, 14, TO_DATE('2023-07-23', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (15, 23, 15, TO_DATE('2023-08-10', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (16, 26, 16, TO_DATE('2023-08-31', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (17, 28, 17, TO_DATE('2023-09-20', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (18, 29, 18, TO_DATE('2023-10-15', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (19, 30, 19, TO_DATE('2023-11-05', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (20, 31, 20, TO_DATE('2023-11-29', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (21, 33, 21, TO_DATE('2023-12-12', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (22, 34, 22, TO_DATE('2024-01-07', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (23, 35, 23, TO_DATE('2024-01-28', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (24, 36, 24, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (25, 38, 25, TO_DATE('2024-03-05', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (26, 39, 26, TO_DATE('2024-03-20', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (27, 40, 27, TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (28, 41, 28, TO_DATE('2024-04-24', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (29, 42, 29, TO_DATE('2024-05-10', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (30, 43, 30, TO_DATE('2024-05-28', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (31, 44, 31, TO_DATE('2024-06-08', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (32, 45, 32, TO_DATE('2024-06-21', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (33, 46, 33, TO_DATE('2024-07-09', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (34, 47, 34, TO_DATE('2024-07-25', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (35, 48, 35, TO_DATE('2024-08-14', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (36, 49, 36, TO_DATE('2024-08-30', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (37, 50, 37, TO_DATE('2024-09-12', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (38, 13, 38, TO_DATE('2024-09-26', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (39, 16, 39, TO_DATE('2024-10-07', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (40, 19, 40, TO_DATE('2024-10-20', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (41, 21, 41, TO_DATE('2024-11-02', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (42, 24, 42, TO_DATE('2024-11-18', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (43, 25, 43, TO_DATE('2024-12-05', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (44, 27, 44, TO_DATE('2024-12-21', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (45, 32, 45, TO_DATE('2025-01-10', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (46, 37, 46, TO_DATE('2025-01-25', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (47, 8, 47, TO_DATE('2025-02-03', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (48, 9, 48, TO_DATE('2025-02-20', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (49, 35, 49, TO_DATE('2025-03-06', 'YYYY-MM-DD'));
INSERT INTO Prestamo (Id_Prestamo_PK, Id_Libro_PK, Id_Usuario_FK, Fecha_Prestamo) VALUES (50, 4, 50, TO_DATE('2025-03-22', 'YYYY-MM-DD'));

--Devolucion
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (1, 1, TO_DATE('2022-08-25', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (2, 2, TO_DATE('2022-09-23', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (3, 3, TO_DATE('2022-10-12', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (4, 4, TO_DATE('2022-11-15', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (5, 5, TO_DATE('2022-12-20', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (6, 6, TO_DATE('2023-01-25', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (7, 7, TO_DATE('2023-02-14', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (8, 8, TO_DATE('2023-03-29', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (9, 9, TO_DATE('2023-04-22', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (10, 10, TO_DATE('2023-05-10', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (11, 11, NULL, 0);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (12, 12, NULL, 0);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (13, 13, TO_DATE('2023-07-10', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (14, 14, TO_DATE('2023-07-30', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (15, 15, TO_DATE('2023-08-22', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (16, 16, TO_DATE('2023-09-10', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (17, 17, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (18, 18, TO_DATE('2023-10-25', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (19, 19, TO_DATE('2023-11-16', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (20, 20, TO_DATE('2023-12-03', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (21, 21, NULL, 0);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (22, 22, NULL, 0);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (23, 23, TO_DATE('2024-02-04', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (24, 24, TO_DATE('2024-02-28', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (25, 25, TO_DATE('2024-03-12', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (26, 26, TO_DATE('2024-04-02', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (27, 27, TO_DATE('2024-04-15', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (28, 28, TO_DATE('2024-05-02', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (29, 29, TO_DATE('2024-05-18', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (30, 30, TO_DATE('2024-06-01', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (31, 31, NULL, 0);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (32, 32, NULL, 0);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (33, 33, TO_DATE('2024-08-01', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (34, 34, TO_DATE('2024-08-10', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (35, 35, TO_DATE('2024-08-28', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (36, 36, TO_DATE('2024-09-20', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (37, 37, TO_DATE('2024-09-30', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (38, 38, TO_DATE('2024-10-10', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (39, 39, TO_DATE('2024-10-30', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (40, 40, TO_DATE('2024-11-15', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (41, 41, NULL, 0);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (42, 42, NULL, 0);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (43, 43, TO_DATE('2024-12-29', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (44, 44, TO_DATE('2025-01-11', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (45, 45, TO_DATE('2025-01-28', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (46, 46, TO_DATE('2025-02-18', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (47, 47, TO_DATE('2025-02-28', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (48, 48, TO_DATE('2025-03-12', 'YYYY-MM-DD'), 1);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (49, 49, NULL, 0);
INSERT INTO Devolucion (Id_Devolucion_PK, Id_Prestamo_FK, Fecha_Devolucion, Devuelto) VALUES (50, 50, NULL, 0);

--Transacciones
INSERT INTO Transaccion VALUES (1, 1, 1, 5, 1, TO_DATE('2022-08-15', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (2, 2, 2, 12, 2, TO_DATE('2022-09-12', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (3, 3, 3, 7, 3, TO_DATE('2022-10-03', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (4, 4, 4, 20, 4, TO_DATE('2022-11-01', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (5, 5, 5, 4, 5, TO_DATE('2022-12-10', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (6, 6, 6, 9, 6, TO_DATE('2023-01-15', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (7, 7, 7, 13, 7, TO_DATE('2023-02-03', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (8, 8, 8, 2, 8, TO_DATE('2023-03-19', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (9, 9, 9, 17, 9, TO_DATE('2023-04-12', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (10, 10, 10, 15, 10, TO_DATE('2023-05-02', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (11, 11, 11, 18, 11, TO_DATE('2023-05-24', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (12, 12, 12, 22, 12, TO_DATE('2023-06-14', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (13, 13, 13, 1, 13, TO_DATE('2023-07-01', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (14, 14, 14, 19, 14, TO_DATE('2023-07-23', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (15, 15, 15, 8, 15, TO_DATE('2023-08-10', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (16, 16, 16, 23, 16, TO_DATE('2023-08-31', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (17, 17, 17, 26, 17, TO_DATE('2023-09-20', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (18, 18, 18, 6, 18, TO_DATE('2023-10-15', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (19, 19, 19, 28, 19, TO_DATE('2023-11-05', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (20, 20, 20, 25, 20, TO_DATE('2023-11-29', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (21, 21, 21, 30, 21, TO_DATE('2023-12-12', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (22, 22, 22, 3, 22, TO_DATE('2024-01-07', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (23, 23, 23, 10, 23, TO_DATE('2024-01-28', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (24, 24, 24, 16, 24, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (25, 25, 25, 24, 25, TO_DATE('2024-03-05', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (26, 26, 26, 11, 26, TO_DATE('2024-03-20', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (27, 27, 27, 21, 27, TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (28, 28, 28, 14, 28, TO_DATE('2024-04-24', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (29, 29, 29, 27, 29, TO_DATE('2024-05-10', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (30, 30, 30, 31, 30, TO_DATE('2024-05-28', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (31, 31, 31, 33, 31, TO_DATE('2024-06-08', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (32, 32, 32, 36, 32, TO_DATE('2024-06-21', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (33, 33, 33, 32, 33, TO_DATE('2024-07-09', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (34, 34, 34, 34, 34, TO_DATE('2024-07-25', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (35, 35, 35, 35, 35, TO_DATE('2024-08-14', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (36, 36, 36, 37, 36, TO_DATE('2024-08-30', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (37, 37, 37, 39, 37, TO_DATE('2024-09-12', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (38, 38, 38, 38, 38, TO_DATE('2024-09-26', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (39, 39, 39, 29, 39, TO_DATE('2024-10-07', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (40, 40, 40, 40, 40, TO_DATE('2024-10-20', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (41, 41, 41, 42, 41, TO_DATE('2024-11-02', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (42, 42, 42, 44, 42, TO_DATE('2024-11-18', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (43, 43, 43, 43, 43, TO_DATE('2024-12-05', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (44, 44, 44, 41, 44, TO_DATE('2024-12-21', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (45, 45, 45, 46, 45, TO_DATE('2025-01-10', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (46, 46, 46, 47, 46, TO_DATE('2025-01-25', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (47, 47, 47, 48, 47, TO_DATE('2025-02-03', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (48, 48, 48, 49, 48, TO_DATE('2025-02-20', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (49, 49, 49, 50, 49, TO_DATE('2025-03-06', 'YYYY-MM-DD'));
INSERT INTO Transaccion VALUES (50, 50, 50, 45, 50, TO_DATE('2025-03-22', 'YYYY-MM-DD'));

--Sanciones
INSERT INTO Sancion VALUES (1, 11, 11, 5.00, 0);
INSERT INTO Sancion VALUES (2, 12, 12, 3.50, 1);
INSERT INTO Sancion VALUES (3, 21, 21, 6.25, 0);
INSERT INTO Sancion VALUES (4, 22, 22, 4.75, 1);
INSERT INTO Sancion VALUES (5, 31, 31, 5.90, 0);
INSERT INTO Sancion VALUES (6, 32, 32, 2.30, 1);
INSERT INTO Sancion VALUES (7, 41, 41, 7.10, 0);
INSERT INTO Sancion VALUES (8, 42, 42, 3.00, 1);
INSERT INTO Sancion VALUES (9, 49, 49, 6.80, 0);
INSERT INTO Sancion VALUES (10, 50, 50, 4.25, 0);
INSERT INTO Sancion VALUES (11, 13, 11, 5.40, 1);
INSERT INTO Sancion VALUES (12, 23, 12, 3.75, 0);
INSERT INTO Sancion VALUES (13, 33, 21, 6.00, 1);
INSERT INTO Sancion VALUES (14, 43, 22, 7.20, 0);
INSERT INTO Sancion VALUES (15, 14, 31, 4.10, 0);
INSERT INTO Sancion VALUES (16, 24, 32, 2.80, 1);
INSERT INTO Sancion VALUES (17, 34, 41, 8.90, 0);
INSERT INTO Sancion VALUES (18, 44, 42, 5.60, 1);
INSERT INTO Sancion VALUES (19, 15, 49, 3.40, 0);
INSERT INTO Sancion VALUES (20, 25, 50, 6.70, 1);
INSERT INTO Sancion VALUES (21, 11, 12, 4.20, 0);
INSERT INTO Sancion VALUES (22, 21, 31, 7.50, 1);
INSERT INTO Sancion VALUES (23, 31, 32, 2.95, 1);
INSERT INTO Sancion VALUES (24, 41, 49, 9.10, 0);
INSERT INTO Sancion VALUES (25, 13, 50, 3.85, 1);
INSERT INTO Sancion VALUES (26, 35, 11, 4.80, 0);
INSERT INTO Sancion VALUES (27, 26, 12, 6.95, 1);
INSERT INTO Sancion VALUES (28, 16, 21, 3.30, 0);
INSERT INTO Sancion VALUES (29, 36, 22, 5.15, 1);
INSERT INTO Sancion VALUES (30, 46, 31, 7.90, 0);
INSERT INTO Sancion VALUES (31, 47, 32, 2.75, 0);
INSERT INTO Sancion VALUES (32, 18, 41, 8.10, 1);
INSERT INTO Sancion VALUES (33, 28, 42, 6.20, 0);
INSERT INTO Sancion VALUES (34, 38, 49, 5.85, 1);
INSERT INTO Sancion VALUES (35, 48, 50, 4.95, 1);
INSERT INTO Sancion VALUES (36, 29, 11, 3.60, 0);
INSERT INTO Sancion VALUES (37, 39, 12, 4.40, 1);
INSERT INTO Sancion VALUES (38, 19, 21, 9.25, 0);
INSERT INTO Sancion VALUES (39, 27, 22, 5.50, 1);
INSERT INTO Sancion VALUES (40, 17, 31, 6.60, 1);
INSERT INTO Sancion VALUES (41, 37, 32, 7.75, 0);
INSERT INTO Sancion VALUES (42, 45, 41, 3.95, 1);
INSERT INTO Sancion VALUES (43, 30, 42, 6.45, 0);
INSERT INTO Sancion VALUES (44, 40, 49, 4.60, 1);
INSERT INTO Sancion VALUES (45, 20, 50, 5.30, 0);
INSERT INTO Sancion VALUES (46, 14, 41, 8.85, 0);
INSERT INTO Sancion VALUES (47, 24, 49, 6.15, 0);
INSERT INTO Sancion VALUES (48, 44, 50, 2.65, 1);
INSERT INTO Sancion VALUES (49, 10, 12, 3.25, 0);
INSERT INTO Sancion VALUES (50, 12, 32, 4.05, 1);

COMMIT
