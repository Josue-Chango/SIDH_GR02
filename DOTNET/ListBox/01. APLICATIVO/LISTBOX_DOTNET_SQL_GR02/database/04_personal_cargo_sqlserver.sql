/*==============================================================*/
/* SIGH - Tabla CARGO del mdulo de Personal                    */
/*                                                              */
/* Ejecutar sobre la base sigh_gr02 despus de tener creada      */
/* PEDEP_DEPAR (script 03). Si PECAR_CARGO ya existe en el       */
/* DDL completo, se conserva sin cambios.                        */
/* No elimina tablas ni modifica datos existentes.               */
/*==============================================================*/

USE sigh_gr02;
GO

IF OBJECT_ID('dbo.PECAR_CARGO', 'U') IS NULL
CREATE TABLE dbo.PECAR_CARGO
(
    PEDEP_CODIGO CHAR(3) NOT NULL,
    PECAR_CODIGO CHAR(3) NOT NULL,
    PECAR_DESCRI VARCHAR(50) NOT NULL,
   PRIMARY KEY (PEDEP_CODIGO, PECAR_CODIGO),
    CONSTRAINT FK_CARGO_DEPARTAMENTO
        FOREIGN KEY (PEDEP_CODIGO) REFERENCES dbo.PEDEP_DEPAR (PEDEP_CODIGO)
);
GO
