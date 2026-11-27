/*==============================================================*/
/* SIGH - CRUD de CARGO (PECAR_CARGO)                           */
/* Subsistema de Personal - SQL Server                          */
/*                                                              */
/* Ejecutar sobre la base sigh_gr02 despues de tener creada     */
/* PEDEP_DEPAR (script 03). Si PECAR_CARGO ya existe, se        */
/* conserva sin cambios. No elimina tablas ni borra datos.      */
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
    CONSTRAINT FK_CARGO_DEPARTAMENTO_CRUD FOREIGN KEY (PEDEP_CODIGO)
        REFERENCES dbo.PEDEP_DEPAR (PEDEP_CODIGO)
);
GO

/* Datos de prueba: solo si la tabla esta vacia. */
IF NOT EXISTS (SELECT 1 FROM dbo.PECAR_CARGO)
BEGIN
    BEGIN TRAN;

    INSERT INTO dbo.PECAR_CARGO (PEDEP_CODIGO, PECAR_CODIGO, PECAR_DESCRI) VALUES
    (N'SIS', N'ADM', N'Administrador'),
    (N'SIS', N'ANA', N'Analista de Sistemas'),
    (N'TAL', N'ASI', N'Asistente de Talento Humano'),
    (N'CON', N'AUX', N'Auxiliar Contable'),
    (N'MAR', N'VEN', N'Ejecutivo de Ventas');

    COMMIT;
END
GO
