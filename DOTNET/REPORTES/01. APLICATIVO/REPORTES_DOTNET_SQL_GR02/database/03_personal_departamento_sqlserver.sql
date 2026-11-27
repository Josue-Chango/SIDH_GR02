/*==============================================================*/
/* SIGH - Datos de prueba del CRUD de DEPARTAMENTO              */
/* Subsistema de Personal - tabla PEDEP_DEPAR                   */
/*                                                                 */
/* Ejecutar sobre la base sigh_gr02. Si la tabla no existe,       */
/* se crea con el CREATE TABLE de abajo.                          */
/*==============================================================*/

USE sigh_gr02;
GO

IF OBJECT_ID('dbo.PEDEP_DEPAR', 'U') IS NULL
CREATE TABLE dbo.PEDEP_DEPAR
(
    PEDEP_CODIGO CHAR(3) NOT NULL,
    PEDEP_DESCRI VARCHAR(50) NOT NULL,
    PRIMARY KEY (PEDEP_CODIGO)
);
GO

BEGIN TRAN;

INSERT INTO dbo.PEDEP_DEPAR (PEDEP_CODIGO, PEDEP_DESCRI) VALUES
(N'VEN', N'VENTAS'),
(N'TAL', N'TALENTO HUMANO'),
(N'CON', N'CONTABILIDAD'),
(N'SIS', N'SISTEMAS'),
(N'MAR', N'MARKETING');

COMMIT;
GO
