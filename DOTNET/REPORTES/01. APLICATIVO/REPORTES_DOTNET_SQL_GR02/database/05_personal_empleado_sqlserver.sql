/*==============================================================*/
/* SIGH - Subsistema de Personal                                */
/* Mantenimiento de Empleados con Tab Page (páginas de pestañas)*/
/*                                                              */
/* Equivalente a 05_personal_empleado_tabpage.sql del proyecto  */
/* Java (MySQL -> SQL Server).                                  */
/*                                                              */
/*   PEPER_PERSO  -> empleado (datos del marco + Datos General.)*/
/*   PEACA_ACADE  -> subtabla de Datos Académicos (grilla)      */
/*   PEFAM_FAMIL  -> subtabla de Datos Familiares (grilla)      */
/*                                                              */
/* Ejecutar sobre la base sigh_gr02, después de los scripts     */
/* 01, 02, 03 y 04. No elimina tablas ni modifica datos         */
/* existentes; los catálogos PEGEN_GENERO y PEESC_ESTCIV solo   */
/* reciben las filas que falten.                                */
/*==============================================================*/

USE sigh_gr02;
GO

/* --------------------------------------------------------------
   1) Catálogos reutilizados del esquema (por si faltara alguno)
   -------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM dbo.PEGEN_GENERO WHERE PEGEN_CODIGO = 'M')
    INSERT INTO dbo.PEGEN_GENERO (PEGEN_CODIGO, PEGEN_DESCRI) VALUES ('M', 'MASCULINO');

IF NOT EXISTS (SELECT 1 FROM dbo.PEGEN_GENERO WHERE PEGEN_CODIGO = 'F')
    INSERT INTO dbo.PEGEN_GENERO (PEGEN_CODIGO, PEGEN_DESCRI) VALUES ('F', 'FEMENINO');

IF NOT EXISTS (SELECT 1 FROM dbo.PEESC_ESTCIV WHERE PEESC_CODIGO = 'S')
    INSERT INTO dbo.PEESC_ESTCIV (PEESC_CODIGO, PEESC_DESCRI) VALUES ('S', 'SOLTERO');

IF NOT EXISTS (SELECT 1 FROM dbo.PEESC_ESTCIV WHERE PEESC_CODIGO = 'C')
    INSERT INTO dbo.PEESC_ESTCIV (PEESC_CODIGO, PEESC_DESCRI) VALUES ('C', 'CASADO');

IF NOT EXISTS (SELECT 1 FROM dbo.PEESC_ESTCIV WHERE PEESC_CODIGO = 'D')
    INSERT INTO dbo.PEESC_ESTCIV (PEESC_CODIGO, PEESC_DESCRI) VALUES ('D', 'DIVORCIADO');

IF NOT EXISTS (SELECT 1 FROM dbo.PEESC_ESTCIV WHERE PEESC_CODIGO = 'U')
    INSERT INTO dbo.PEESC_ESTCIV (PEESC_CODIGO, PEESC_DESCRI) VALUES ('U', 'UNION LIBRE');

IF NOT EXISTS (SELECT 1 FROM dbo.PEESC_ESTCIV WHERE PEESC_CODIGO = 'V')
    INSERT INTO dbo.PEESC_ESTCIV (PEESC_CODIGO, PEESC_DESCRI) VALUES ('V', 'VIUDO');
GO

/* --------------------------------------------------------------
   2) Empleado (PEPER_PERSO)
      El módulo de login ya usa esta tabla: si no existe se crea
      completa; si existe, se agregan las columnas del Tab Page
      que falten (peso y tipo de sangre).
   -------------------------------------------------------------- */
IF OBJECT_ID('dbo.PEPER_PERSO', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PEPER_PERSO
    (
        PEPER_CODIGO CHAR(10)     NOT NULL,
        PEPER_APELLI VARCHAR(50)  NOT NULL,
        PEPER_NOMBRE VARCHAR(50)  NOT NULL,
        PEPER_FECNAC DATE          NOT NULL,
        PEGEN_CODIGO CHAR(1)       NOT NULL, /* Sexo (catálogo PEGEN_GENERO) */
        PEESC_CODIGO CHAR(1)       NULL,     /* Estado civil (catálogo PEESC_ESTCIV) */
        PEPER_CEDULA VARCHAR(10)   NULL,
        PEPER_PASAPO VARCHAR(15)   NULL,
        PEPER_EMAIL  VARCHAR(50)   NULL,
        PEPER_CARFAM NUMERIC(2,0)  NOT NULL,
        PEPER_PESO   NUMERIC(5,2)  NULL,     /* Peso en kilogramos */
        PEPER_TIPSANG VARCHAR(3)   NULL,     /* Tipo de sangre: O+, A-, ... */
        PEPER_FOTO   VARCHAR(100)  NOT NULL, /* Ruta relativa bajo /resource; vacía si no hay foto */
        PEPER_DISC   CHAR(1)       NOT NULL,
        CONSTRAINT PK_PEPER_PERSO PRIMARY KEY (PEPER_CODIGO),
        CONSTRAINT FK_EMPL_GENERO FOREIGN KEY (PEGEN_CODIGO)
            REFERENCES dbo.PEGEN_GENERO (PEGEN_CODIGO),
        CONSTRAINT FK_EMPL_ESTCIV FOREIGN KEY (PEESC_CODIGO)
            REFERENCES dbo.PEESC_ESTCIV (PEESC_CODIGO)
    );
END
GO

/* Columnas del Tab Page que puede no tener la tabla del login. */
IF COL_LENGTH('dbo.PEPER_PERSO', 'PEPER_PESO') IS NULL
    ALTER TABLE dbo.PEPER_PERSO ADD PEPER_PESO NUMERIC(5,2) NULL;
GO
IF COL_LENGTH('dbo.PEPER_PERSO', 'PEPER_TIPSANG') IS NULL
    ALTER TABLE dbo.PEPER_PERSO ADD PEPER_TIPSANG VARCHAR(3) NULL;
GO

/* --------------------------------------------------------------
   3) Datos Académicos del empleado (subtabla / grilla de la
      pestaña 2). Varios estudios por empleado.
   -------------------------------------------------------------- */
IF OBJECT_ID('dbo.PEACA_ACADE', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PEACA_ACADE
    (
        PEACA_CODIGO INT IDENTITY(1,1) NOT NULL,
        PEPER_CODIGO CHAR(10)          NOT NULL,
        PEACA_NIVEL  VARCHAR(50)       NOT NULL, /* Bachiller, Tecnólogo, Licenciado... */
        PEACA_INSTI  VARCHAR(100)      NOT NULL, /* Institución educativa */
        PEACA_TITUL  VARCHAR(100)      NOT NULL, /* Título obtenido */
        CONSTRAINT PK_PEACA_ACADE PRIMARY KEY (PEACA_CODIGO),
        CONSTRAINT FK_ACA_PERSONA FOREIGN KEY (PEPER_CODIGO)
            REFERENCES dbo.PEPER_PERSO (PEPER_CODIGO)
            ON DELETE CASCADE
    );
END
GO

/* --------------------------------------------------------------
   4) Datos Familiares del empleado (subtabla / grilla de la
      pestaña 3). Varios familiares por empleado.
   -------------------------------------------------------------- */
IF OBJECT_ID('dbo.PEFAM_FAMIL', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PEFAM_FAMIL
    (
        PEFAM_CODIGO INT IDENTITY(1,1) NOT NULL,
        PEPER_CODIGO CHAR(10)          NOT NULL,
        PEFAM_PAREN  VARCHAR(20)       NOT NULL, /* Persona: PADRE, MADRE, CONYUGE... */
        PEFAM_NOMBRE VARCHAR(100)      NOT NULL, /* Apellidos y nombres */
        PEFAM_FECNAC DATE               NOT NULL,
        CONSTRAINT PK_PEFAM_FAMIL PRIMARY KEY (PEFAM_CODIGO),
        CONSTRAINT FK_FAM_PERSONA FOREIGN KEY (PEPER_CODIGO)
            REFERENCES dbo.PEPER_PERSO (PEPER_CODIGO)
            ON DELETE CASCADE
    );
END
GO

/* --------------------------------------------------------------
   5) Datos de prueba (se ignoran si los códigos ya existen)
   -------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM dbo.PEPER_PERSO WHERE PEPER_CODIGO = '1712345678')
    INSERT INTO dbo.PEPER_PERSO
        (PEPER_CODIGO, PEPER_APELLI, PEPER_NOMBRE, PEPER_FECNAC,
         PEGEN_CODIGO, PEESC_CODIGO, PEPER_PESO, PEPER_TIPSANG, PEPER_FOTO, PEPER_CARFAM, PEPER_DISC)
    VALUES ('1712345678', 'PERALTA SILVA', 'JOSUE DANIEL', '2000-03-14',
            'M', 'S', 68.50, 'O+', 'josue1.jpeg', 0, 'N');

IF NOT EXISTS (SELECT 1 FROM dbo.PEPER_PERSO WHERE PEPER_CODIGO = '0913456789')
    INSERT INTO dbo.PEPER_PERSO
        (PEPER_CODIGO, PEPER_APELLI, PEPER_NOMBRE, PEPER_FECNAC,
         PEGEN_CODIGO, PEESC_CODIGO, PEPER_PESO, PEPER_TIPSANG, PEPER_FOTO, PEPER_CARFAM, PEPER_DISC)
    VALUES ('0913456789', 'CAIZA MUÑOZ', 'DEIVIS ALEJANDRO', '1999-08-02',
            'M', 'C', 75.20, 'A+', 'deivis1.png.jpg', 0, 'N');

IF NOT EXISTS (SELECT 1 FROM dbo.PEPER_PERSO WHERE PEPER_CODIGO = '1726543210')
    INSERT INTO dbo.PEPER_PERSO
        (PEPER_CODIGO, PEPER_APELLI, PEPER_NOMBRE, PEPER_FECNAC,
         PEGEN_CODIGO, PEESC_CODIGO, PEPER_PESO, PEPER_TIPSANG, PEPER_FOTO, PEPER_CARFAM, PEPER_DISC)
    VALUES ('1726543210', 'VISCAINO TORRES', 'ALISON GABRIELA', '2001-11-23',
            'F', 'U', 57.00, 'O-', '', 0, 'N');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.PEACA_ACADE WHERE PEPER_CODIGO = '1712345678')
    INSERT INTO dbo.PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL)
    VALUES
        ('1712345678', 'Bachiller', 'Unidad Educativa Benalcázar',          'Bachiller en Ciencias'),
        ('1712345678', 'Licenciado','Escuela Politécnica Nacional',        'Licenciado en Informática');

IF NOT EXISTS (SELECT 1 FROM dbo.PEACA_ACADE WHERE PEPER_CODIGO = '0913456789')
    INSERT INTO dbo.PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL)
    VALUES
        ('0913456789', 'Bachiller', 'Unidad Educativa Manuela Cañizares',  'Bachiller en Contabilidad'),
        ('0913456789', 'Tecnólogo', 'Instituto Tecnológico Quito',         'Tecnólogo en Redes');

IF NOT EXISTS (SELECT 1 FROM dbo.PEACA_ACADE WHERE PEPER_CODIGO = '1726543210')
    INSERT INTO dbo.PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL)
    VALUES
        ('1726543210', 'Maestría', 'Universidad Central del Ecuador', 'Magíster en Gestión de Talento');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.PEFAM_FAMIL WHERE PEPER_CODIGO = '1712345678')
    INSERT INTO dbo.PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC)
    VALUES
        ('1712345678', 'PADRE',      'PERALTA LÓPEZ CARLOS ERNESTO', '1972-05-09'),
        ('1712345678', 'MADRE',      'SILVA RUIZ MARÍA FERNANDA',    '1975-10-19');

IF NOT EXISTS (SELECT 1 FROM dbo.PEFAM_FAMIL WHERE PEPER_CODIGO = '0913456789')
    INSERT INTO dbo.PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC)
    VALUES
        ('0913456789', 'CONYUGE',    'CAIZA PÁEZ ANDREA NICOLE',     '2000-01-30'),
        ('0913456789', 'HIJO/A',     'CAIZA PÁEZ EMILIANO',          '2022-06-11');

IF NOT EXISTS (SELECT 1 FROM dbo.PEFAM_FAMIL WHERE PEPER_CODIGO = '1726543210')
    INSERT INTO dbo.PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC)
    VALUES
        ('1726543210', 'HERMANO/A',  'VISCAINO TORRES LUIS MATEO',   '2004-04-03');
GO

/* No elimina tablas ni modifica datos existentes. */
