/*==============================================================*/
/* SIGH - Datos de prueba del CRUD de DEPARTAMENTO              */
/* Subsistema de Personal - tabla PEDEP_DEPAR                   */
/*                                                              */
/* Ejecutar sobre la base sigh_gr02, creada al importar el      */
/* DDL completo SIGH_GR02_MySQL_DDL en MySQL Workbench.         */
/*                                                              */
/* Si usa la base alternativa sigh (01_seguridad_tablas.sql),   */
/* el CREATE TABLE IF NOT EXISTS crea la tabla antes de cargar  */
/* los datos.                                                   */
/*==============================================================*/

USE sigh_gr02;

START TRANSACTION;

CREATE TABLE IF NOT EXISTS PEDEP_DEPAR
(
   PEDEP_CODIGO         CHAR(3) NOT NULL,
   PEDEP_DESCRI         VARCHAR(50) NOT NULL,
   PRIMARY KEY (PEDEP_CODIGO)
);

/*==================== Departamentos ====================*/
INSERT INTO PEDEP_DEPAR (PEDEP_CODIGO, PEDEP_DESCRI) VALUES
('VEN', 'VENTAS'),
('TAL', 'TALENTO HUMANO'),
('CON', 'CONTABILIDAD'),
('SIS', 'SISTEMAS'),
('MAR', 'MARKETING');

COMMIT;
