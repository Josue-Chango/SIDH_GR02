/*==============================================================*/
/* SIGH - Datos de prueba del módulo de Seguridad (SQL Server)  */
/* Ejecutar después de 01_seguridad_tablas_sqlserver.sql        */
/*==============================================================*/

USE sigh_gr02;
GO

BEGIN TRAN;

INSERT INTO dbo.PEESC_ESTCIV (PEESC_CODIGO, PEESC_DESCRI) VALUES
('S', N'SOLTERO'),
('C', N'CASADO'),
('V', N'VIUDO');

INSERT INTO dbo.PEGEN_GENERO (PEGEN_CODIGO, PEGEN_DESCRI) VALUES
('M', N'MASCULINO'),
('F', N'FEMENINO');

INSERT INTO dbo.XEEST_ESTAD (XEEST_CODIGO, XEEST_DESCRI) VALUES
('A', N'ACTIVO'),
('I', N'INACTIVO'),
('B', N'BLOQUEADO');

INSERT INTO dbo.XESIS_SISTE (XESIS_CODIGO, XESIS_DESCRI) VALUES
('S', N'SIGH');

INSERT INTO dbo.XEPER_PERFI (XEPER_CODIGO, XEPER_DESCRI, XEPER_OBSER) VALUES
('ADMIN', N'Administrador', N'Acceso total al sistema'),
('MEDICO', N'Médico', N'Acceso al módulo clínico'),
('USUARIO', N'Usuario', N'Acceso básico al sistema');

INSERT INTO dbo.XEOPC_OPCIO (XEOPC_CODIGO, XESIS_CODIGO, XEOPC_DESCRI) VALUES
('001', 'S', N'Inicio'),
('002', 'S', N'Gestión de usuarios'),
('003', 'S', N'Gestión de perfiles'),
('004', 'S', N'Historia clínica');

INSERT INTO dbo.PEPER_PERSO
(PEPER_CODIGO, PEGEN_CODIGO, PEESC_CODIGO, PEPER_APELLI, PEPER_NOMBRE,
 PEPER_FECNAC, PEPER_CEDULA, PEPER_PASAPO, PEPER_EMAIL, PEPER_CARFAM,
 PEPER_FOTO, PEPER_DISC)
VALUES
('P000000001', 'M', 'S', N'CHANGO', N'JOSUE',
 '2000-05-10', '0102030405', NULL, N'josue.chango@example.com', 0,
 N'josue1.jpeg', 'N'),
('P000000002', 'F', 'C', N'PEREZ', N'MARIA',
 '1995-08-20', '0987654321', NULL, N'maria.perez@example.com', 2,
 N'monster1.jpeg', 'N'),
('P000000003', 'M', 'S', N'GOMEZ', N'CARLOS',
 '1988-01-15', NULL, N'AB1234567', N'carlos.gomez@example.com', 1,
 N'monster2.jpeg', 'N');

INSERT INTO dbo.XEUSU_USUAR
(XEUSU_PASWD, XEEST_CODIGO, PEPER_CODIGO, XEUSU_FECCRE, XEUSU_FECMOD, XEUSU_PIEFIR)
VALUES
('Admin123', 'A', 'P000000001', GETDATE(), GETDATE(), N'firmas/josue.png'),
('User1234', 'A', 'P000000002', GETDATE(), GETDATE(), N'firmas/maria.png'),
('Bloqueado1', 'B', 'P000000003', GETDATE(), GETDATE(), N'firmas/carlos.png');

INSERT INTO dbo.XEUXP_USUPE (XEUSU_PASWD, XEPER_CODIGO, XEUXP_FECASI, XEUXP_FECRET) VALUES
('Admin123', 'ADMIN', GETDATE(), NULL),
('User1234', 'USUARIO', GETDATE(), NULL),
('Bloqueado1', 'USUARIO', GETDATE(), NULL);

INSERT INTO dbo.XEOXP_OPCPE (XEOPC_CODIGO, XEPER_CODIGO, XEOXP_FECASI, XEOXP_FECRET) VALUES
('001', 'ADMIN', GETDATE(), NULL),
('002', 'ADMIN', GETDATE(), NULL),
('003', 'ADMIN', GETDATE(), NULL),
('004', 'ADMIN', GETDATE(), NULL),
('001', 'USUARIO', GETDATE(), NULL),
('001', 'MEDICO', GETDATE(), NULL),
('004', 'MEDICO', GETDATE(), NULL);

COMMIT;
GO
