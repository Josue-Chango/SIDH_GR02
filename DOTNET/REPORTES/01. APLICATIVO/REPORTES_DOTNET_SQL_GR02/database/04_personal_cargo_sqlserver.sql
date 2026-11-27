/*==============================================================*/
/* SIGH - Tabla CARGO del mdulo de Personal                    */
/*                                                              */
/* Equivalente a 04_personal_cargo_tabla.sql del proyecto Java  */
/* (MySQL -> SQL Server).                                       */
/*                                                              */
/* Ejecutar el script 03 (PEDEP_DEPAR) antes de este archivo.   */
/* Si PECAR_CARGO ya existe, se conserva sin cambios.           */
/*==============================================================*/

USE sigh_gr02;
GO

IF OBJECT_ID('dbo.PECAR_CARGO', 'U') IS NULL
CREATE TABLE dbo.PECAR_CARGO
(
    PEDEP_CODIGO CHAR(3) NOT NULL,
    PECAR_CODIGO CHAR(3) NOT NULL,
    PECAR_DESCRI VARCHAR(50) NOT NULL,
    CONSTRAINT PK_PECAR_CARGO PRIMARY KEY (PEDEP_CODIGO, PECAR_CODIGO),
    CONSTRAINT FK_CARGO_DEPARTAMENTO_CRUD
        FOREIGN KEY (PEDEP_CODIGO) REFERENCES dbo.PEDEP_DEPAR (PEDEP_CODIGO)
);
GO
/* No elimina tablas ni modifica datos existentes. */
