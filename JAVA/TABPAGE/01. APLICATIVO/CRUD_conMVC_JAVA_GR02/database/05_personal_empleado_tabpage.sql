-- ==============================================================
-- SIGH - Subsistema de Personal
-- Mantenimiento de Empleados con Tab Page (páginas de pestañas).
--
-- Tabla principal: PEPER_PERSO (PERSONA del esquema de Seguridad,
-- la misma que usa el módulo de login).
--   PEACA_ACADE -> subtabla de Datos Académicos (grilla)
--   PEFAM_FAMIL -> subtabla de Datos Familiares (grilla)
--   PEPER_PERSO recibe 2 columnas nuevas para la pestaña
--   Datos Generales: PEPER_PESO y PEPER_TIPSANG (ambas NULL).
--
-- Ejecutar sobre la base sigh_gr02 (ver db.properties).
-- Se puede ejecutar varias veces sin dañar datos: las columnas y
-- tablas solo se crean si no existen y los datos de prueba se
-- insertan únicamente si están vacíos.
-- ==============================================================

USE sigh_gr02;

-- --------------------------------------------------------------
-- 1) Columnas nuevas de Datos Generales en PEPER_PERSO
--    (se agregan una sola vez; las personas existentes quedan
--    con NULL y el módulo de login no se ve afectado)
-- --------------------------------------------------------------
SET @hay_peso = (SELECT COUNT(*) FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA = DATABASE()
                   AND TABLE_NAME = 'PEPER_PERSO' AND COLUMN_NAME = 'PEPER_PESO');
SET @ddl = IF(@hay_peso = 0,
    'ALTER TABLE PEPER_PERSO ADD COLUMN PEPER_PESO DECIMAL(5,2) NULL COMMENT ''Peso en kilogramos'' AFTER PEPER_FOTO',
    'SELECT 1');
PREPARE sentencia FROM @ddl; EXECUTE sentencia; DEALLOCATE PREPARE sentencia;

SET @hay_sangre = (SELECT COUNT(*) FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'PEPER_PERSO' AND COLUMN_NAME = 'PEPER_TIPSANG');
SET @ddl = IF(@hay_sangre = 0,
    'ALTER TABLE PEPER_PERSO ADD COLUMN PEPER_TIPSANG VARCHAR(3) NULL COMMENT ''Tipo de sangre: O+, A-, ...'' AFTER PEPER_PESO',
    'SELECT 1');
PREPARE sentencia FROM @ddl; EXECUTE sentencia; DEALLOCATE PREPARE sentencia;

-- --------------------------------------------------------------
-- 2) Datos Académicos del empleado (subtabla / grilla de la
--    pestaña 2). Varios estudios por persona.
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS PEACA_ACADE (
    PEACA_CODIGO INT          NOT NULL AUTO_INCREMENT,
    PEPER_CODIGO CHAR(10)     NOT NULL,
    PEACA_NIVEL  VARCHAR(50)  NOT NULL COMMENT 'Bachiller, Tecnólogo, Licenciado...',
    PEACA_INSTI  VARCHAR(100) NOT NULL COMMENT 'Institución educativa',
    PEACA_TITUL  VARCHAR(100) NOT NULL COMMENT 'Título obtenido',
    PRIMARY KEY (PEACA_CODIGO),
    CONSTRAINT FK_ACA_PERSONA FOREIGN KEY (PEPER_CODIGO)
        REFERENCES PEPER_PERSO (PEPER_CODIGO)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------------
-- 3) Datos Familiares del empleado (subtabla / grilla de la
--    pestaña 3). Varios familiares por persona.
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS PEFAM_FAMIL (
    PEFAM_CODIGO INT          NOT NULL AUTO_INCREMENT,
    PEPER_CODIGO CHAR(10)     NOT NULL,
    PEFAM_PAREN  VARCHAR(20)  NOT NULL COMMENT 'Persona: PADRE, MADRE, CONYUGE...',
    PEFAM_NOMBRE VARCHAR(100) NOT NULL COMMENT 'Apellidos y nombres',
    PEFAM_FECNAC DATE         NOT NULL COMMENT 'Fecha de nacimiento',
    PRIMARY KEY (PEFAM_CODIGO),
    CONSTRAINT FK_FAM_PERSONA FOREIGN KEY (PEPER_CODIGO)
        REFERENCES PEPER_PERSO (PEPER_CODIGO)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------------
-- 4) Datos de prueba
--    a) Peso y tipo de sangre de las personas que ya existen
--       (solo si aún están vacíos: no sobrescribe datos reales)
-- --------------------------------------------------------------
UPDATE PEPER_PERSO SET PEPER_PESO = 70.50, PEPER_TIPSANG = 'O+'
WHERE PEPER_CODIGO = 'P000000001' AND PEPER_PESO IS NULL;

UPDATE PEPER_PERSO SET PEPER_PESO = 62.30, PEPER_TIPSANG = 'A-'
WHERE PEPER_CODIGO = 'P000000002' AND PEPER_PESO IS NULL;

UPDATE PEPER_PERSO SET PEPER_PESO = 81.00, PEPER_TIPSANG = 'B+'
WHERE PEPER_CODIGO = 'P000000003' AND PEPER_PESO IS NULL;

--    b) Estudios académicos de las personas existentes
--       (solo si la persona aún no tiene estudios registrados)
INSERT INTO PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL)
SELECT p.PEPER_CODIGO, v.NIVEL, v.INSTI, v.TITUL
FROM PEPER_PERSO p
JOIN (
    SELECT 'P000000001' AS CODIGO, 'Bachiller'   AS NIVEL, 'Unidad Educativa Benalcázar'     AS INSTI, 'Bachiller en Ciencias'    AS TITUL
    UNION ALL SELECT 'P000000001', 'Licenciado', 'Escuela Politécnica Nacional',   'Licenciado en Informática'
    UNION ALL SELECT 'P000000002', 'Bachiller',  'Unidad Educativa Manuela Cañizares', 'Bachiller en Contabilidad'
    UNION ALL SELECT 'P000000002', 'Licenciado', 'Universidad Central del Ecuador', 'Licenciada en Contabilidad'
    UNION ALL SELECT 'P000000003', 'Tecnólogo',  'Instituto Tecnológico Quito',    'Tecnólogo en Redes'
) v ON v.CODIGO = p.PEPER_CODIGO
WHERE NOT EXISTS (
    SELECT 1 FROM PEACA_ACADE a WHERE a.PEPER_CODIGO = p.PEPER_CODIGO
);

--    c) Familiares de las personas existentes
--       (solo si la persona aún no tiene familiares registrados)
INSERT INTO PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC)
SELECT p.PEPER_CODIGO, v.PAREN, v.NOMBRE, v.FECNAC
FROM PEPER_PERSO p
JOIN (
    SELECT 'P000000001' AS CODIGO, 'PADRE'      AS PAREN, 'CHANGO PÉREZ LUIS ALBERTO' AS NOMBRE, '1968-02-17' AS FECNAC
    UNION ALL SELECT 'P000000001', 'MADRE',     'DÍAZ ANA LUCÍA',           '1971-09-05'
    UNION ALL SELECT 'P000000002', 'CONYUGE',   'GÓMEZ ROJAS PABLO ANDRÉS', '1996-04-22'
    UNION ALL SELECT 'P000000002', 'HIJO/A',    'GÓMEZ PEREZ EMILIANO',     '2022-06-11'
    UNION ALL SELECT 'P000000003', 'HERMANO/A', 'GÓMEZ GÓMEZ LUIS MATEO',   '2004-04-03'
) v ON v.CODIGO = p.PEPER_CODIGO
WHERE NOT EXISTS (
    SELECT 1 FROM PEFAM_FAMIL f WHERE f.PEPER_CODIGO = p.PEPER_CODIGO
);

-- No elimina tablas ni modifica datos existentes.
