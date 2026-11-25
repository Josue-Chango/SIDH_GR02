/*==============================================================*/
/* SIGH - Subsistema de Seguridad                               */
/* Tablas del diagrama de clases de PowerDesigner (MySQL)       */
/*                                                              */
/* Ejecutar este script antes de 02_seguridad_datos_prueba.sql. */
/*==============================================================*/

CREATE DATABASE IF NOT EXISTS sigh
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE sigh;

/* Se eliminan en orden inverso a las dependencias. */
DROP TABLE IF EXISTS XEUXP_USUPE;
DROP TABLE IF EXISTS XEOXP_OPCPE;
DROP TABLE IF EXISTS XEUSU_USUAR;
DROP TABLE IF EXISTS XEPER_PERFI;
DROP TABLE IF EXISTS XEOPC_OPCIO;
DROP TABLE IF EXISTS XESIS_SISTE;
DROP TABLE IF EXISTS XEEST_ESTAD;
DROP TABLE IF EXISTS PEPER_PERSO;
DROP TABLE IF EXISTS PEGEN_GENERO;
DROP TABLE IF EXISTS PEESC_ESTCIV;

/*==============================================================*/
/* Tabla: PEESC_ESTCIV (ESTADO CIVIL)                           */
/*==============================================================*/
CREATE TABLE PEESC_ESTCIV
(
    PEESC_CODIGO CHAR(1) NOT NULL,
    PEESC_DESCRI VARCHAR(50) NOT NULL,
    PRIMARY KEY (PEESC_CODIGO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*==============================================================*/
/* Tabla: PEGEN_GENERO (GENERO)                                 */
/*==============================================================*/
CREATE TABLE PEGEN_GENERO
(
    PEGEN_CODIGO CHAR(1) NOT NULL,
    PEGEN_DESCRI VARCHAR(50) NOT NULL,
    PRIMARY KEY (PEGEN_CODIGO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*==============================================================*/
/* Tabla: XEEST_ESTAD (ESTADO)                                  */
/*==============================================================*/
CREATE TABLE XEEST_ESTAD
(
    XEEST_CODIGO CHAR(1) NOT NULL,
    XEEST_DESCRI VARCHAR(50) NOT NULL,
    PRIMARY KEY (XEEST_CODIGO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*==============================================================*/
/* Tabla: XESIS_SISTE (SISTEMA)                                 */
/*==============================================================*/
CREATE TABLE XESIS_SISTE
(
    XESIS_CODIGO CHAR(1) NOT NULL,
    XESIS_DESCRI VARCHAR(50) NOT NULL,
    PRIMARY KEY (XESIS_CODIGO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*==============================================================*/
/* Tabla: XEPER_PERFI (PERFIL)                                  */
/*==============================================================*/
CREATE TABLE XEPER_PERFI
(
    XEPER_CODIGO CHAR(8) NOT NULL,
    XEPER_DESCRI VARCHAR(100) NOT NULL,
    XEPER_OBSER TEXT,
    PRIMARY KEY (XEPER_CODIGO)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*==============================================================*/
/* Tabla: XEOPC_OPCIO (OPCION)                                  */
/*==============================================================*/
CREATE TABLE XEOPC_OPCIO
(
    XEOPC_CODIGO CHAR(3) NOT NULL,
    XESIS_CODIGO CHAR(1) NOT NULL,
    XEOPC_DESCRI VARCHAR(100) NOT NULL,
    PRIMARY KEY (XEOPC_CODIGO),
    CONSTRAINT FK_XR_XESIS_XEOPC FOREIGN KEY (XESIS_CODIGO)
        REFERENCES XESIS_SISTE (XESIS_CODIGO)
        ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*==============================================================*/
/* Tabla: PEPER_PERSO (PERSONA)                                 */
/*==============================================================*/
CREATE TABLE PEPER_PERSO
(
    PEPER_CODIGO CHAR(10) NOT NULL,
    PEGEN_CODIGO CHAR(1) NOT NULL,
    PEESC_CODIGO CHAR(1),
    PEPER_APELLI VARCHAR(50) NOT NULL,
    PEPER_NOMBRE VARCHAR(50) NOT NULL,
    PEPER_FECNAC DATE NOT NULL,
    PEPER_CEDULA VARCHAR(10),
    PEPER_PASAPO VARCHAR(15),
    PEPER_EMAIL VARCHAR(50),
    PEPER_CARFAM NUMERIC(2,0) NOT NULL,
    PEPER_FOTO VARCHAR(100) NOT NULL,
    PEPER_DISC CHAR(1) NOT NULL,
    PRIMARY KEY (PEPER_CODIGO),
    CONSTRAINT FK_PR_PEGEN_PEPER FOREIGN KEY (PEGEN_CODIGO)
        REFERENCES PEGEN_GENERO (PEGEN_CODIGO)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT FK_PR_PEESC_PEPER FOREIGN KEY (PEESC_CODIGO)
        REFERENCES PEESC_ESTCIV (PEESC_CODIGO)
        ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*==============================================================*/
/* Tabla: XEUSU_USUAR (USUARIO)                                 */
/*==============================================================*/
CREATE TABLE XEUSU_USUAR
(
    XEUSU_PASWD VARCHAR(16) NOT NULL,
    XEEST_CODIGO CHAR(1) NOT NULL,
    PEPER_CODIGO CHAR(10) NOT NULL,
    XEUSU_FECCRE DATETIME NOT NULL,
    XEUSU_FECMOD DATETIME NOT NULL,
    XEUSU_PIEFIR VARCHAR(100) NOT NULL,
    PRIMARY KEY (XEUSU_PASWD),
    CONSTRAINT FK_XR_PEPER_XEUSU FOREIGN KEY (PEPER_CODIGO)
        REFERENCES PEPER_PERSO (PEPER_CODIGO)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT FK_XR_XEEST_XEUSU FOREIGN KEY (XEEST_CODIGO)
        REFERENCES XEEST_ESTAD (XEEST_CODIGO)
        ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*==============================================================*/
/* Tabla: XEOXP_OPCPE (OPCION - PERFIL)                         */
/*==============================================================*/
CREATE TABLE XEOXP_OPCPE
(
    XEOPC_CODIGO CHAR(3) NOT NULL,
    XEPER_CODIGO CHAR(8) NOT NULL,
    XEOXP_FECASI DATE NOT NULL,
    XEOXP_FECRET DATE,
    PRIMARY KEY (XEOPC_CODIGO, XEPER_CODIGO, XEOXP_FECASI),
    CONSTRAINT FK_XR_XEOPC_XEOXP FOREIGN KEY (XEOPC_CODIGO)
        REFERENCES XEOPC_OPCIO (XEOPC_CODIGO)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT FK_XR_XEPER_XEOXP FOREIGN KEY (XEPER_CODIGO)
        REFERENCES XEPER_PERFI (XEPER_CODIGO)
        ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*==============================================================*/
/* Tabla: XEUXP_USUPE (USUARIO - PERFIL)                        */
/*==============================================================*/
CREATE TABLE XEUXP_USUPE
(
    XEUSU_PASWD VARCHAR(16) NOT NULL,
    XEPER_CODIGO CHAR(8) NOT NULL,
    XEUXP_FECASI DATE NOT NULL,
    XEUXP_FECRET DATE,
    PRIMARY KEY (XEUSU_PASWD, XEPER_CODIGO, XEUXP_FECASI),
    CONSTRAINT FK_XR_XEPER_XEUXP FOREIGN KEY (XEPER_CODIGO)
        REFERENCES XEPER_PERFI (XEPER_CODIGO)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT FK_XR_XEUSU_XEUXP FOREIGN KEY (XEUSU_PASWD)
        REFERENCES XEUSU_USUAR (XEUSU_PASWD)
        ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
