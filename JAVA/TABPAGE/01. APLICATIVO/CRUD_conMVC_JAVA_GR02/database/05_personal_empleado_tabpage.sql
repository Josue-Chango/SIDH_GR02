-- ==============================================================
-- SIGH - Subsistema de Personal
-- Mantenimiento de Empleados con Tab Page (páginas de pestañas).
--
-- Réplica en Java del "Tab Page" del proyecto .NET GR02:
--   PE_PER_PERSON  -> empleado (datos del marco + Datos Generales)
--   PEACA_ACADE    -> subtabla de Datos Académicos (grilla)
--   PEFAM_FAMIL    -> subtabla de Datos Familiares (grilla)
--
-- Ejecutar sobre la base sigh_gr02 (ver db.properties).
-- No elimina tablas ni modifica datos existentes; los catálogos
-- PEGEN_GENERO y PEESC_ESTCIV solo reciben filas que falten.
-- ==============================================================

USE sigh_gr02;

-- --------------------------------------------------------------
-- 1) Catálogos reutilizados del esquema (por si faltara alguno)
-- --------------------------------------------------------------
INSERT IGNORE INTO PEGEN_GENERO (PEGEN_CODIGO, PEGEN_DESCRI) VALUES
('M', 'MASCULINO'),
('F', 'FEMENINO');

INSERT IGNORE INTO PEESC_ESTCIV (PEESC_CODIGO, PEESC_DESCRI) VALUES
('S', 'SOLTERO'),
('C', 'CASADO'),
('D', 'DIVORCIADO'),
('U', 'UNION LIBRE'),
('V', 'VIUDO');

-- --------------------------------------------------------------
-- 2) Empleado (PE_PER_PERSON)
--    El código del empleado es la cédula (10 dígitos), igual que
--    en el proyecto .NET donde PEPER_CODIGO guarda la cédula.
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS PE_PER_PERSON (
    PEPER_CODIGO  CHAR(10)      NOT NULL,
    PEPER_APELLI  VARCHAR(50)   NOT NULL,
    PEPER_NOMBRE  VARCHAR(50)   NOT NULL,
    PEPER_FECNAC  DATE          NOT NULL,
    PEGEN_CODIGO  CHAR(1)       NULL COMMENT 'Sexo (catálogo PEGEN_GENERO)',
    PEESC_CODIGO  CHAR(1)       NULL COMMENT 'Estado civil (catálogo PEESC_ESTCIV)',
    PEPER_PESO    DECIMAL(5,2)  NULL COMMENT 'Peso en kilogramos',
    PEPER_TIPSANG VARCHAR(3)    NULL COMMENT 'Tipo de sangre: O+, A-, ...',
    PEPER_FOTO    VARCHAR(100)  NULL COMMENT 'Ruta relativa de la foto bajo /resource',
    PRIMARY KEY (PEPER_CODIGO),
    CONSTRAINT FK_EMPL_GENERO FOREIGN KEY (PEGEN_CODIGO)
        REFERENCES PEGEN_GENERO (PEGEN_CODIGO)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT FK_EMPL_ESTCIV FOREIGN KEY (PEESC_CODIGO)
        REFERENCES PEESC_ESTCIV (PEESC_CODIGO)
        ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------------
-- 3) Datos Académicos del empleado (subtabla / grilla de la
--    pestaña 2). Varios estudios por empleado.
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS PEACA_ACADE (
    PEACA_CODIGO INT          NOT NULL AUTO_INCREMENT,
    PEPER_CODIGO CHAR(10)     NOT NULL,
    PEACA_NIVEL  VARCHAR(50)  NOT NULL COMMENT 'Bachiller, Tecnólogo, Licenciado...',
    PEACA_INSTI  VARCHAR(100) NOT NULL COMMENT 'Institución educativa',
    PEACA_TITUL  VARCHAR(100) NOT NULL COMMENT 'Título obtenido',
    PRIMARY KEY (PEACA_CODIGO),
    CONSTRAINT FK_ACA_PERSONA FOREIGN KEY (PEPER_CODIGO)
        REFERENCES PE_PER_PERSON (PEPER_CODIGO)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------------
-- 4) Datos Familiares del empleado (subtabla / grilla de la
--    pestaña 3). Varios familiares por empleado.
-- --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS PEFAM_FAMIL (
    PEFAM_CODIGO INT          NOT NULL AUTO_INCREMENT,
    PEPER_CODIGO CHAR(10)     NOT NULL,
    PEFAM_PAREN  VARCHAR(20)  NOT NULL COMMENT 'Persona: PADRE, MADRE, CONYUGE...',
    PEFAM_NOMBRE VARCHAR(100) NOT NULL COMMENT 'Apellidos y nombres',
    PEFAM_FECNAC DATE         NOT NULL COMMENT 'Fecha de nacimiento',
    PRIMARY KEY (PEFAM_CODIGO),
    CONSTRAINT FK_FAM_PERSONA FOREIGN KEY (PEPER_CODIGO)
        REFERENCES PE_PER_PERSON (PEPER_CODIGO)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------------
-- 5) Datos de prueba (se ignoran si los códigos ya existen)
-- --------------------------------------------------------------
START TRANSACTION;

INSERT IGNORE INTO PE_PER_PERSON
    (PEPER_CODIGO, PEPER_APELLI, PEPER_NOMBRE, PEPER_FECNAC,
     PEGEN_CODIGO, PEESC_CODIGO, PEPER_PESO, PEPER_TIPSANG, PEPER_FOTO)
VALUES
    ('1712345678', 'PERALTA SILVA', 'JOSUE DANIEL',     '2000-03-14', 'M', 'S', 68.50, 'O+', 'josue1.jpeg'),
    ('0913456789', 'CAIZA MUÑOZ',   'DEIVIS ALEJANDRO', '1999-08-02', 'M', 'C', 75.20, 'A+', 'deivis1.png.jpg'),
    ('1726543210', 'VISCAINO TORRES', 'ALISON GABRIELA', '2001-11-23', 'F', 'U', 57.00, 'O-', NULL);

INSERT INTO PEACA_ACADE (PEPER_CODIGO, PEACA_NIVEL, PEACA_INSTI, PEACA_TITUL)
SELECT p.PEPER_CODIGO, v.NIVEL, v.INSTI, v.TITUL
FROM PE_PER_PERSON p
JOIN (
    SELECT '1712345678' AS CODIGO, 'Bachiller'   AS NIVEL, 'Unidad Educativa Benalcázar'   AS INSTI, 'Bachiller en Ciencias'    AS TITUL
    UNION ALL SELECT '1712345678', 'Licenciado', 'Escuela Politécnica Nacional', 'Licenciado en Informática'
    UNION ALL SELECT '0913456789', 'Bachiller',  'Unidad Educativa Manuela Cañizares', 'Bachiller en Contabilidad'
    UNION ALL SELECT '0913456789', 'Tecnólogo',  'Instituto Tecnológico Quito',  'Tecnólogo en Redes'
    UNION ALL SELECT '1726543210', 'Maestría',   'Universidad Central del Ecuador', 'Magíster en Gestión de Talento'
) v ON v.CODIGO = p.PEPER_CODIGO
WHERE NOT EXISTS (
    SELECT 1 FROM PEACA_ACADE a WHERE a.PEPER_CODIGO = p.PEPER_CODIGO
);

INSERT INTO PEFAM_FAMIL (PEPER_CODIGO, PEFAM_PAREN, PEFAM_NOMBRE, PEFAM_FECNAC)
SELECT p.PEPER_CODIGO, v.PAREN, v.NOMBRE, v.FECNAC
FROM PE_PER_PERSON p
JOIN (
    SELECT '1712345678' AS CODIGO, 'PADRE'      AS PAREN, 'PERALTA LÓPEZ CARLOS ERNESTO' AS NOMBRE, '1972-05-09' AS FECNAC
    UNION ALL SELECT '1712345678', 'MADRE',     'SILVA RUIZ MARÍA FERNANDA',    '1975-10-19'
    UNION ALL SELECT '0913456789', 'CONYUGE',   'CAIZA PÁEZ ANDREA NICOLE',     '2000-01-30'
    UNION ALL SELECT '0913456789', 'HIJO/A',    'CAIZA PÁEZ EMILIANO',          '2022-06-11'
    UNION ALL SELECT '1726543210', 'HERMANO/A', 'VISCAINO TORRES LUIS MATEO',   '2004-04-03'
) v ON v.CODIGO = p.PEPER_CODIGO
WHERE NOT EXISTS (
    SELECT 1 FROM PEFAM_FAMIL f WHERE f.PEPER_CODIGO = p.PEPER_CODIGO
);

COMMIT;

-- No elimina tablas ni modifica datos existentes.
