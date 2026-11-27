/*==============================================================*/
/* SIGH - Mantenimiento de Empleados con Tab Page               */
/* Subsistema de Personal - SQL Server                          */
/*                                                              */
/* Tabla principal: PEPER_PERSO (PERSONA del esquema de         */
/* Seguridad, la misma que usa el modulo de login).             */
/*   PEACA_ACADE -> subtabla de Datos Academicos (grilla)       */
/*   PEFAM_FAMIL -> subtabla de Datos Familiares (grilla)       */
/*   PEPER_PERSO recibe 2 columnas nuevas para la pestana       */
/*   Datos Generales: PEPER_PESO y PEPER_TIPSANG (ambas NULL).  */
/*                                                              */
/* Ejecutar sobre la base sigh_gr02. Se puede ejecutar varias   */
/* veces sin danar datos: las columnas y tablas solo se crean   */
/* si no existen y los datos de prueba se insertan unicamente   */
/* si estan vacios.                                             */
/*==============================================================*/

USE sigh_gr02;
GO

/* -------------------------------------------------------------- */
/* 1) Columnas nuevas de Datos Generales en PEPER_PERSO            */
/*    (se agregan una sola vez; las personas existentes quedan     */
/*    con NULL y el modulo de login no se ve afectado)             */
/* -------------------------------------------------------------- */
IF COL_LENGTH('dbo.PEPER_PERSO', 'PEPER_PESO') IS NULL
    ALTER TABLE dbo.PEPER_PERSO
        ADD PEPER_PESO DECIMAL(5,2) NULL;
GO

IF COL_LENGTH('dbo.PEPER_PERSO', 'PEPER_TIPSANG') IS NULL
    ALTER TABLE dbo.PEPER_PERSO
        ADD PEPER_TIPSANG VARCHAR(3) NULL;
GO

/* -------------------------------------------------------------- */
/* 2) Datos Academicos del empleado (subtabla / grilla de la       */
/*    pestana 2). Varios estudios por persona.                     */
/* -------------------------------------------------------------- */
IF OBJECT_ID('dbo.PEACA_ACADE', 'U') IS NULL
CREATE TABLE dbo.PEACA_ACADE
(
    PEACA_CODIGO INT IDENTITY(1,1) NOT NULL,
    PEPER_CODIGO CHAR(10) NOT NULL,
    PEACA_NIVEL  VARCHAR(50) NOT NULL,
    PEACA_INSTI  VARCHAR(100) NOT NULL,
    PEACA_TITUL  VARCHAR(100) NOT NULL,
    PRIMARY KEY (PEACA_CODIGO),
    CONSTRAINT FK_ACA_PERSONA FOREIGN KEY (PEPER_CODIGO)
        REFERENCES dbo.PEPER_PERSO (PEPER_CODIGO)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

/* -------------------------------------------------------------- */
/* 3) Datos Familiares del empleado (subtabla / grilla de la       */
/*    pestana 3). Varios familiares por persona.                   */
/* -------------------------------------------------------------- */
IF OBJECT_ID('dbo.PEFAM_FAMIL', 'U') IS NULL
CREATE TABLE dbo.PEFAM_FAMIL
(
    PEFAM_CODIGO INT IDENTITY(1,1) NOT NULL,
    PEPER_CODIGO CHAR(10) NOT NULL,
    PEFAM_PAREN  VARCHAR(20) NOT NULL,
    PEFAM_NOMBRE VARCHAR(100) NOT NULL,
    PEFAM_FECNAC DATE NOT NULL,
    PRIMARY KEY (PEFAM_CODIGO),
    CONSTRAINT FK_FAM_PERSONA FOREIGN KEY (PEPER_CODIGO)
        REFERENCES dbo.PEPER_PERSO (PEPER_CODIGO)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

/* -------------------------------------------------------------- */
/* 4) Datos de prueba                                              */
/*    a) Peso y tipo de sangre de las personas que ya existen      */
/*       (solo si aun estan vacios: no sobrescribe datos reales)   */
/* -------------------------------------------------------------- */
UPDATE dbo.PEPER_PERSO SET PEPER_PESO = 70.50, PEPER_TIPSANG = N'O+'
WHERE PEPER_CODIGO = N'P000000001' AND PEPER_PESO IS NULL;

UPDATE dbo.PEPER_PERSO SET PEPER_PESO = 62.30, PEPER_TIPSANG = N'A-'
WHERE PEPER_CODIGO = N'P000000002' AND PEPER_PESO IS NULL;

UPDATE dbo.PEPER_PERSO SET PEPER_PESO = 81.00, PEPER_TIPSANG = N'B+'
WHERE PEPER_CODIGO = N'P000000003' AND PEPER_PESO IS NULL;
GO

/*    b) Estudios academicos de las personas existentes            */
/*       (solo si la persona aun no tiene estudios registrados)    */
INSERT INTO dbo.PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL)
SELECT p.PEPER_CODIGO, v.NIVEL, v.INSTI, v.TITUL
FROM dbo.PEPER_PERSO p
JOIN (VALUES
    (N'P000000001', N'Bachiller',  N'Unidad Educativa Benalcázar',        N'Bachiller en Ciencias'),
    (N'P000000001', N'Licenciado', N'Escuela Politécnica Nacional',       N'Licenciado en Informática'),
    (N'P000000002', N'Bachiller',  N'Unidad Educativa Manuela Cañizares', N'Bachiller en Contabilidad'),
    (N'P000000002', N'Licenciado', N'Universidad Central del Ecuador',    N'Licenciada en Contabilidad'),
    (N'P000000003', N'Tecnólogo',  N'Instituto Tecnológico Quito',        N'Tecnólogo en Redes')
) v (CODIGO, NIVEL, INSTI, TITUL)
    ON v.CODIGO = p.PEPER_CODIGO
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.PEACA_ACADE a WHERE a.PEPER_CODIGO = p.PEPER_CODIGO
);
GO

/*    c) Familiares de las personas existentes                     */
/*       (solo si la persona aun no tiene familiares registrados)  */
INSERT INTO dbo.PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC)
SELECT p.PEPER_CODIGO, v.PAREN, v.NOMBRE, CAST(v.FECNAC AS DATE)
FROM dbo.PEPER_PERSO p
JOIN (VALUES
    (N'P000000001', N'PADRE',     N'CHANGO PÉREZ LUIS ALBERTO', '1968-02-17'),
    (N'P000000001', N'MADRE',     N'DÍAZ ANA LUCÍA',            '1971-09-05'),
    (N'P000000002', N'CONYUGE',   N'GÓMEZ ROJAS PABLO ANDRÉS',  '1996-04-22'),
    (N'P000000002', N'HIJO/A',    N'GÓMEZ PEREZ EMILIANO',      '2022-06-11'),
    (N'P000000003', N'HERMANO/A', N'GÓMEZ GÓMEZ LUIS MATEO',    '2004-04-03')
) v (CODIGO, PAREN, NOMBRE, FECNAC)
    ON v.CODIGO = p.PEPER_CODIGO
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.PEFAM_FAMIL f WHERE f.PEPER_CODIGO = p.PEPER_CODIGO
);
GO
