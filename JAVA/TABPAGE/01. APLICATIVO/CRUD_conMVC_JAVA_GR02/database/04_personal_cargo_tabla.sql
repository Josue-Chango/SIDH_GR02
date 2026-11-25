-- Seleccione primero el esquema de su db.properties en MySQL Workbench.
-- Cree PEDEP_DEPAR antes de ejecutar este archivo.
-- Si PECAR_CARGO ya existe en el DDL completo, se conserva sin cambios.
CREATE TABLE IF NOT EXISTS PECAR_CARGO (
    PEDEP_CODIGO CHAR(3) NOT NULL,
    PECAR_CODIGO CHAR(3) NOT NULL,
    PECAR_DESCRI VARCHAR(50) NOT NULL,
    PRIMARY KEY (PEDEP_CODIGO, PECAR_CODIGO),
    CONSTRAINT FK_CARGO_DEPARTAMENTO_CRUD
        FOREIGN KEY (PEDEP_CODIGO) REFERENCES PEDEP_DEPAR (PEDEP_CODIGO)
        ON UPDATE RESTRICT ON DELETE RESTRICT
);
-- No elimina tablas ni modifica datos existentes.
