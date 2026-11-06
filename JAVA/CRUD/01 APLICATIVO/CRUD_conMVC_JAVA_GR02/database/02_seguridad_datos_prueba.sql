/*==============================================================*/
/* SIGH - Datos de prueba del Subsistema de Seguridad           */
/* Ejecutar sobre la base sigh_gr02, creada al importar el      */
/* DDL completo SIGH_GR02_MySQL_DDL en MySQL Workbench.         */
/*                                                              */
/* Si tu base tiene otro nombre, cambia el USE y db.url en      */
/* src/main/resources/db.properties.                            */
/*==============================================================*/

USE sigh_gr02;

START TRANSACTION;

/*==================== Catálogos ====================*/
INSERT INTO PEESC_ESTCIV (PEESC_CODIGO, PEESC_DESCRI) VALUES
('S', 'SOLTERO'),
('C', 'CASADO'),
('V', 'VIUDO');

INSERT INTO PEGEN_GENERO (PEGEN_CODIGO, PEGEN_DESCRI) VALUES
('M', 'MASCULINO'),
('F', 'FEMENINO');

INSERT INTO XEEST_ESTAD (XEEST_CODIGO, XEEST_DESCRI) VALUES
('A', 'ACTIVO'),
('I', 'INACTIVO'),
('B', 'BLOQUEADO');

INSERT INTO XESIS_SISTE (XESIS_CODIGO, XESIS_DESCRI) VALUES
('S', 'SIGH');

INSERT INTO XEPER_PERFI (XEPER_CODIGO, XEPER_DESCRI, XEPER_OBSER) VALUES
('ADMIN', 'Administrador', 'Acceso total al sistema'),
('MEDICO', 'Médico', 'Acceso al módulo clínico'),
('USUARIO', 'Usuario', 'Acceso básico al sistema');

INSERT INTO XEOPC_OPCIO (XEOPC_CODIGO, XESIS_CODIGO, XEOPC_DESCRI) VALUES
('001', 'S', 'Inicio'),
('002', 'S', 'Gestión de usuarios'),
('003', 'S', 'Gestión de perfiles'),
('004', 'S', 'Historia clínica');

/*==================== Personas ====================*/
INSERT INTO PEPER_PERSO
(PEPER_CODIGO, PEGEN_CODIGO, PEESC_CODIGO, PEPER_APELLI, PEPER_NOMBRE,
 PEPER_FECNAC, PEPER_CEDULA, PEPER_PASAPO, PEPER_EMAIL, PEPER_CARFAM,
 PEPER_FOTO, PEPER_DISC)
VALUES
('P000000001', 'M', 'S', 'CHANGO', 'JOSUE',
 '2000-05-10', '0102030405', NULL, 'josue.chango@example.com', 0,
 'josue1.jpeg', 'N'),
('P000000002', 'F', 'C', 'PEREZ', 'MARIA',
 '1995-08-20', '0987654321', NULL, 'maria.perez@example.com', 2,
 'monster1.jpeg', 'N'),
('P000000003', 'M', 'S', 'GOMEZ', 'CARLOS',
 '1988-01-15', NULL, 'AB1234567', 'carlos.gomez@example.com', 1,
 'monster2.jpeg', 'N');

/*==================== Usuarios ====================*/
/* La contraseña se almacena en texto plano porque así la define el DDL
   del diagrama (XEUSU_PASWD VARCHAR(16)). Los valores tienen máximo 16. */
INSERT INTO XEUSU_USUAR
(XEUSU_PASWD, XEEST_CODIGO, PEPER_CODIGO, XEUSU_FECCRE, XEUSU_FECMOD, XEUSU_PIEFIR)
VALUES
('Admin123', 'A', 'P000000001', NOW(), NOW(), 'firmas/josue.png'),
('User1234', 'A', 'P000000002', NOW(), NOW(), 'firmas/maria.png'),
('Bloqueado1', 'B', 'P000000003', NOW(), NOW(), 'firmas/carlos.png');

/*==================== Usuario - Perfil ====================*/
INSERT INTO XEUXP_USUPE (XEUSU_PASWD, XEPER_CODIGO, XEUXP_FECASI, XEUXP_FECRET) VALUES
('Admin123', 'ADMIN', CURDATE(), NULL),
('User1234', 'USUARIO', CURDATE(), NULL),
('Bloqueado1', 'USUARIO', CURDATE(), NULL);

/*==================== Opción - Perfil ====================*/
INSERT INTO XEOXP_OPCPE (XEOPC_CODIGO, XEPER_CODIGO, XEOXP_FECASI, XEOXP_FECRET) VALUES
('001', 'ADMIN', CURDATE(), NULL),
('002', 'ADMIN', CURDATE(), NULL),
('003', 'ADMIN', CURDATE(), NULL),
('004', 'ADMIN', CURDATE(), NULL),
('001', 'USUARIO', CURDATE(), NULL),
('001', 'MEDICO', CURDATE(), NULL),
('004', 'MEDICO', CURDATE(), NULL);

COMMIT;

/*==============================================================*/
/* Usuarios de prueba                                           */
/*--------------------------------------------------------------*/
/* ADMIN     -> cédula 0102030405        / Admin123              */
/* USUARIO   -> correo maria.perez@...   / User1234              */
/* BLOQUEADO -> pasaporte AB1234567      / Bloqueado1            */
/*==============================================================*/
