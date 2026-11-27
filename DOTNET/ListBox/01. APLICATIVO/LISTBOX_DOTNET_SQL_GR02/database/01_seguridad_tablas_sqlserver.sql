/*==============================================================*/
/* SIGH - Subsistema de Seguridad                               */
/* Tablas del diagrama de clases de PowerDesigner (SQL Server)  */
/*                                                              */
/* Ejecutar antes de 02_seguridad_datos_prueba_sqlserver.sql    */
/*==============================================================*/

IF DB_ID('sigh_gr02') IS NULL
    CREATE DATABASE sigh_gr02;
GO

USE sigh_gr02;
GO

/* Se eliminan en orden inverso a las dependencias. */
IF OBJECT_ID('dbo.XEUXP_USUPE', 'U') IS NOT NULL DROP TABLE dbo.XEUXP_USUPE;
IF OBJECT_ID('dbo.XEOXP_OPCPE', 'U') IS NOT NULL DROP TABLE dbo.XEOXP_OPCPE;
IF OBJECT_ID('dbo.XEUSU_USUAR', 'U') IS NOT NULL DROP TABLE dbo.XEUSU_USUAR;
IF OBJECT_ID('dbo.PEPER_PERSO', 'U') IS NOT NULL DROP TABLE dbo.PEPER_PERSO;
IF OBJECT_ID('dbo.XEOXP_OPCIO', 'U') IS NOT NULL DROP TABLE dbo.XEOXP_OPCIO;
IF OBJECT_ID('dbo.XEOPC_OPCIO', 'U') IS NOT NULL DROP TABLE dbo.XEOPC_OPCIO;
IF OBJECT_ID('dbo.XEPER_PERFI', 'U') IS NOT NULL DROP TABLE dbo.XEPER_PERFI;
IF OBJECT_ID('dbo.XESIS_SISTE', 'U') IS NOT NULL DROP TABLE dbo.XESIS_SISTE;
IF OBJECT_ID('dbo.XEEST_ESTAD', 'U') IS NOT NULL DROP TABLE dbo.XEEST_ESTAD;
IF OBJECT_ID('dbo.PEGEN_GENERO', 'U') IS NOT NULL DROP TABLE dbo.PEGEN_GENERO;
IF OBJECT_ID('dbo.PEESC_ESTCIV', 'U') IS NOT NULL DROP TABLE dbo.PEESC_ESTCIV;
GO

/*==============================================================*/
/* Tabla: PEESC_ESTCIV (ESTADO CIVIL)                           */
/*==============================================================*/
CREATE TABLE dbo.PEESC_ESTCIV
(
    PEESC_CODIGO CHAR(1) NOT NULL,
    PEESC_DESCRI VARCHAR(50) NOT NULL,
    PRIMARY KEY (PEESC_CODIGO)
);
GO

/*==============================================================*/
/* Tabla: PEGEN_GENERO (GENERO)                                 */
/*==============================================================*/
CREATE TABLE dbo.PEGEN_GENERO
(
    PEGEN_CODIGO CHAR(1) NOT NULL,
    PEGEN_DESCRI VARCHAR(50) NOT NULL,
    PRIMARY KEY (PEGEN_CODIGO)
);
GO

/*==============================================================*/
/* Tabla: XEEST_ESTAD (ESTADO)                                  */
/*==============================================================*/
CREATE TABLE dbo.XEEST_ESTAD
(
    XEEST_CODIGO CHAR(1) NOT NULL,
    XEEST_DESCRI VARCHAR(50) NOT NULL,
    PRIMARY KEY (XEEST_CODIGO)
);
GO

/*==============================================================*/
/* Tabla: XESIS_SISTE (SISTEMA)                                 */
/*==============================================================*/
CREATE TABLE dbo.XESIS_SISTE
(
    XESIS_CODIGO CHAR(1) NOT NULL,
    XESIS_DESCRI VARCHAR(50) NOT NULL,
    PRIMARY KEY (XESIS_CODIGO)
);
GO

/*==============================================================*/
/* Tabla: XEPER_PERFI (PERFIL)                                  */
/*==============================================================*/
CREATE TABLE dbo.XEPER_PERFI
(
    XEPER_CODIGO CHAR(8) NOT NULL,
    XEPER_DESCRI VARCHAR(100) NOT NULL,
    XEPER_OBSER VARCHAR(200) NULL,
    PRIMARY KEY (XEPER_CODIGO)
);
GO

/*==============================================================*/
/* Tabla: PEPER_PERSO (PERSONA)                                 */
/*==============================================================*/
CREATE TABLE dbo.PEPER_PERSO
(
    PEPER_CODIGO CHAR(10) NOT NULL,
    PEGEN_CODIGO CHAR(1) NOT NULL,
    PEESC_CODIGO CHAR(1) NULL,
    PEPER_APELLI VARCHAR(50) NOT NULL,
    PEPER_NOMBRE VARCHAR(50) NOT NULL,
    PEPER_FECNAC DATETIME NULL,
    PEPER_CEDULA VARCHAR(10) NULL,
    PEPER_PASAPO VARCHAR(15) NULL,
    PEPER_EMAIL VARCHAR(50) NULL,
    PEPER_CARFAM NUMERIC(2,0) NULL,
    PEPER_FOTO VARCHAR(100) NULL,
    PEPER_DISC CHAR(1) NULL,
    PRIMARY KEY (PEPER_CODIGO),
    CONSTRAINT FK_PR_PEGEN_PEPER FOREIGN KEY (PEGEN_CODIGO)
        REFERENCES dbo.PEGEN_GENERO (PEGEN_CODIGO),
    CONSTRAINT FK_PR_PEESC_PEPER FOREIGN KEY (PEESC_CODIGO)
        REFERENCES dbo.PEESC_ESTCIV (PEESC_CODIGO)
);
GO

/*==============================================================*/
/* Tabla: XEUSU_USUAR (USUARIO)                                 */
/*==============================================================*/
CREATE TABLE dbo.XEUSU_USUAR
(
    XEUSU_PASWD VARCHAR(16) NOT NULL,
    XEEST_CODIGO CHAR(1) NOT NULL,
    PEPER_CODIGO CHAR(10) NOT NULL,
    XEUSU_FECCRE DATETIME NULL,
    XEUSU_FECMOD DATETIME NULL,
    XEUSU_PIEFIR VARCHAR(100) NULL,
    PRIMARY KEY (XEUSU_PASWD),
    CONSTRAINT FK_XR_PEPER_XEUSU FOREIGN KEY (PEPER_CODIGO)
        REFERENCES dbo.PEPER_PERSO (PEPER_CODIGO),
    CONSTRAINT FK_XR_XEEST_XEUSU FOREIGN KEY (XEEST_CODIGO)
        REFERENCES dbo.XEEST_ESTAD (XEEST_CODIGO)
);
GO

/*==============================================================*/
/* Tabla: XEOXP_OPCPE (OPCION - PERFIL)                         */
/*==============================================================*/
CREATE TABLE dbo.XEOXP_OPCPE
(
    XEOPC_CODIGO CHAR(3) NOT NULL,
    XEPER_CODIGO CHAR(8) NOT NULL,
    XEOXP_FECASI DATETIME NULL,
    XEOXP_FECRET DATETIME NULL,
    PRIMARY KEY (XEOPC_CODIGO, XEPER_CODIGO),
    CONSTRAINT FK_XR_XEOXP FOREIGN KEY (XEOPC_CODIGO) REFERENCES dbo.XEOPC_OPCIO (XEOPC_CODIGO),
    CONSTRAINT FK_XR_XEPER FOREIGN KEY (XEPER_CODIGO) REFERENCES dbo.XEPER_PERFI (XEPER_CODIGO)
);
GO

/*==============================================================*/
/* Tabla: XEOXP_OPCIO (OPCION)                                  */
/*==============================================================*/
CREATE TABLE dbo.XEOPC_OPCIO
(
    XEOPC_CODIGO CHAR(3) NOT NULL,
    XESIS_CODIGO CHAR(1) NOT NULL,
    XEOPC_DESCRI VARCHAR(100) NOT NULL,
    PRIMARY KEY (XEOPC_CODIGO),
    CONSTRAINT FK_XR_XESIS_XEOPC FOREIGN KEY (XESIS_CODIGO) REFERENCES dbo.XESIS_SISTE (XESIS_CODIGO)
);
GO

/*==============================================================*/
/* Tabla: XEUXP_USUPE (USUARIO - PERFIL)                        */
/*==============================================================*/
CREATE TABLE dbo.XEUXP_USUPE
(
    XEUSU_PASWD VARCHAR(16) NOT NULL,
    XEPER_CODIGO CHAR(8) NOT NULL,
    XEUXP_FECASI DATETIME NULL,
    XEUXP_FECRET DATETIME NULL,
    PRIMARY KEY (XEUSU_PASWD, XEPER_CODIGO),
    CONSTRAINT FK_XR_XEUSU_XEUXP FOREIGN KEY (XEUSU_PASWD) REFERENCES dbo.XEUSU_USUAR (XEUSU_PASWD),
    CONSTRAINT FK_XR_XEPER_XEUXP FOREIGN KEY (XEPER_CODIGO) REFERENCES dbo.XEPER_PERFI (XEPER_CODIGO)
);
GO
