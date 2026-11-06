-- Instalacion nueva sobre un esquema vacio. Sin DROP; mismas definiciones que el original.
/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     3/11/2026 22:40:05                           */
/*==============================================================*/


/*==============================================================*/
/* Table: FICAR_CARGO                                           */
/*==============================================================*/
CREATE TABLE FICAR_CARGO
(
   FICAR_CARGO_IDCARGO  VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_CUENTA_FACTURACION_IDCUENTA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FITAR_TARIF_IDTARIFA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FICAR_CARGO_CARGOEL  DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   FICAR_CARGO_TIPOORIGEN VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FICAR_CARGO_REFERENCIAORIGEN VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   FICAR_CARGO_CANTIDAD NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Cantidad. ',
   FICAR_CARGO_DESCRIPCIONORIGEN VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   FICAR_CARGO_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FICAR_CARGO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   FICAR_CARGO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (FICAR_CARGO_IDCARGO)
);

ALTER TABLE FICAR_CARGO COMMENT 'ERS: RF-FAC-001
Servicio o producto realmente prestado';

/*==============================================================*/
/* Table: FIFAC_FACTU                                           */
/*==============================================================*/
CREATE TABLE FIFAC_FACTU
(
   FIFAC_FACTU_IDFACTURA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_CUENTA_FACTURACION_IDCUENTA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FIFAC_FACTU_NUMERODOCUMENTO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   FIFAC_FACTU_TIPODOCUMENTO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FIFAC_FACTU_EMITIDAEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   FIFAC_FACTU_MONEDA   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FIFAC_FACTU_SUBTOTAL NUMERIC(18,6) COMMENT 'Tipo conceptual: Importe. ',
   FIFAC_FACTU_DESCUENTO NUMERIC(18,6) COMMENT 'Tipo conceptual: Importe. ',
   FIFAC_FACTU_IMPUESTO NUMERIC(18,6) COMMENT 'Tipo conceptual: Importe. ',
   FIFAC_FACTU_TOTAL    NUMERIC(18,6) COMMENT 'Tipo conceptual: Importe. ',
   FIFAC_FACTU_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FIFAC_FACTU_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   FIFAC_FACTU_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (FIFAC_FACTU_IDFACTURA),
   KEY AK_AK_FACTURA_NUMERODOCUMENTO (FIFAC_FACTU_NUMERODOCUMENTO)
);

ALTER TABLE FIFAC_FACTU COMMENT 'ERS: RF-FAC-002, RF-FAC-003, RF-FAC-006
Documento de l';

/*==============================================================*/
/* Table: FIFOR_FORMA                                           */
/*==============================================================*/
CREATE TABLE FIFOR_FORMA
(
   FIFOR_FORMA_IDFORMAPAGO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FIFOR_FORMA_CODIGO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FIFOR_FORMA_DESCRIPCION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   FIFOR_FORMA_VIGENTEDESDE DATE COMMENT 'Tipo conceptual: Fecha. ',
   FIFOR_FORMA_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   FIFOR_FORMA_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FIFOR_FORMA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   FIFOR_FORMA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (FIFOR_FORMA_IDFORMAPAGO),
   KEY AK_AK_FORMA_PAGO_CODIGO (FIFOR_FORMA_CODIGO)
);

ALTER TABLE FIFOR_FORMA COMMENT 'ERS: RF-FAC-004, RF-CAT-001, RF-CAT-002

registr';

/*==============================================================*/
/* Table: FIPAG_PAGO                                            */
/*==============================================================*/
CREATE TABLE FIPAG_PAGO
(
   FIPAG_PAGO_IDPAGO    VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FIFAC_FACTU_IDFACTURA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FIFOR_FORMA_IDFORMAPAGO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FIPAG_PAGO_PAGADOEL  DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   FIPAG_PAGO_IMPORTE   NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Importe. ',
   FIPAG_PAGO_REFERENCIA VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   FIPAG_PAGO_ESTADO    VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FIPAG_PAGO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   FIPAG_PAGO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (FIPAG_PAGO_IDPAGO)
);

ALTER TABLE FIPAG_PAGO COMMENT 'ERS: RF-FAC-004, RF-FAC-006
Pago de un documento con u';

/*==============================================================*/
/* Table: FISER_SERVIC                                          */
/*==============================================================*/
CREATE TABLE FISER_SERVIC
(
   FISER_SERVIC_IDSERVICIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FISER_SERVIC_CODIGO  VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FISER_SERVIC_DESCRIPCION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   FISER_SERVIC_TIPOSERVICIO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FISER_SERVIC_VIGENTEDESDE DATE COMMENT 'Tipo conceptual: Fecha. ',
   FISER_SERVIC_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   FISER_SERVIC_ESTADO  VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FISER_SERVIC_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   FISER_SERVIC_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (FISER_SERVIC_IDSERVICIO),
   KEY AK_AK_SERVICIO_CODIGO (FISER_SERVIC_CODIGO)
);

ALTER TABLE FISER_SERVIC COMMENT 'ERS: RF-FAC-001, RF-CAT-001, RF-CAT-002
Prestación fac';

/*==============================================================*/
/* Table: FITAR_TARIF                                           */
/*==============================================================*/
CREATE TABLE FITAR_TARIF
(
   FITAR_TARIF_IDTARIFA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FISER_SERVIC_IDSERVICIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FITAR_TARIF_DESCRIPCION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   FITAR_TARIF_VIGENTEDESDE DATE NOT NULL COMMENT 'Tipo conceptual: Fecha. ',
   FITAR_TARIF_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   FITAR_TARIF_PRECIOUNITARIO NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Importe. ',
   FITAR_TARIF_TASADESCUENTO NUMERIC(18,6) COMMENT 'Tipo conceptual: Cantidad. ',
   FITAR_TARIF_TASAIMPUESTO NUMERIC(18,6) COMMENT 'Tipo conceptual: Cantidad. ',
   FITAR_TARIF_MONEDA   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FITAR_TARIF_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   FITAR_TARIF_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   FITAR_TARIF_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (FITAR_TARIF_IDTARIFA)
);

ALTER TABLE FITAR_TARIF COMMENT 'ERS: RF-FAC-002, RF-CAT-002
Versión temporal de tarifa';

/*==============================================================*/
/* Table: GEPAC_PACIE                                           */
/*==============================================================*/
CREATE TABLE GEPAC_PACIE
(
   GEPAC_PACIE_IDPACIENTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_IDENTIFICADORHOSPITALARIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_TIPOIDENTIDAD VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GEPAC_PACIE_TIPODOCUMENTO VARCHAR(40) COMMENT 'Tipo conceptual: Codigo. ',
   GEPAC_PACIE_NUMERODOCUMENTO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GEPAC_PACIE_NOMBRES  VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GEPAC_PACIE_APELLIDOS VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GEPAC_PACIE_FECHANACIMIENTO DATE COMMENT 'Tipo conceptual: Fecha. ',
   GEPAC_PACIE_SEXOREGISTRADO VARCHAR(40) COMMENT 'Tipo conceptual: Codigo. ',
   GEPAC_PACIE_DIRECCION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GEPAC_PACIE_ENTIDADCOBERTURA VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GEPAC_PACIE_REFERENCIACOBERTURA VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GEPAC_PACIE_ESTADOREGISTRO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GEPAC_PACIE_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GEPAC_PACIE_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GEPAC_PACIE_IDPACIENTE),
   KEY AK_AK_PACIENTE_IDENTIFICADORHOSPITALARIO (GEPAC_PACIE_IDENTIFICADORHOSPITALARIO)
);

ALTER TABLE GEPAC_PACIE COMMENT 'ERS: RF-PAC-001, RF-PAC-002, RF-PAC-003, RF-PAC-004, RF-EME-';

/*==============================================================*/
/* Table: GHADM_ADMIS                                           */
/*==============================================================*/
CREATE TABLE GHADM_ADMIS
(
   GHADM_ADMIS_IDADMISION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_IDPACIENTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_EGRESO_ADMINISTRATIVO_IDEGRESO VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GHADM_ADMIS_INGRESOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHADM_ADMIS_TIPOADMISION VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHADM_ADMIS_INDICACIONINGRESO TEXT NOT NULL COMMENT 'Tipo conceptual: TextoLargo. ',
   GHADM_ADMIS_PROCEDENCIA VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHADM_ADMIS_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHADM_ADMIS_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHADM_ADMIS_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHADM_ADMIS_IDADMISION)
);

ALTER TABLE GHADM_ADMIS COMMENT 'ERS: RF-HOS-001, RF-PAC-004
Ingreso administrativo con';

/*==============================================================*/
/* Table: GHAGE_AGEND                                           */
/*==============================================================*/
CREATE TABLE GHAGE_AGEND
(
   GHAGE_AGEND_IDAGENDA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHESP_ESPEC_IDESPECIALIDAD VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHAGE_AGEND_FECHA    DATE NOT NULL COMMENT 'Tipo conceptual: Fecha. ',
   GHAGE_AGEND_INICIOJORNADA TIME NOT NULL COMMENT 'Tipo conceptual: Hora. ',
   GHAGE_AGEND_FINJORNADA TIME NOT NULL COMMENT 'Tipo conceptual: Hora. ',
   GHAGE_AGEND_DURACIONCITAMINUTOS INT NOT NULL COMMENT 'Tipo conceptual: Entero. ',
   GHAGE_AGEND_CAPACIDAD INT NOT NULL COMMENT 'Tipo conceptual: Entero. ',
   GHAGE_AGEND_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHAGE_AGEND_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHAGE_AGEND_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHAGE_AGEND_IDAGENDA)
);

ALTER TABLE GHAGE_AGEND COMMENT 'ERS: RF-CIT-001
Agenda de un profesional, especialidad';

/*==============================================================*/
/* Table: GHALE_ALERG                                           */
/*==============================================================*/
CREATE TABLE GHALE_ALERG
(
   GHALE_ALERG_IDALERGIA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_IDPACIENTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHALE_ALERG_SUSTANCIAOCONDICION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHALE_ALERG_REACCION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHALE_ALERG_SEVERIDAD VARCHAR(40) COMMENT 'Tipo conceptual: Codigo. ',
   GHALE_ALERG_FUENTEINFORMACION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHALE_ALERG_ESTADOVERIFICACION VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHALE_ALERG_FECHAEFECTIVA DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHALE_ALERG_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHALE_ALERG_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHALE_ALERG_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHALE_ALERG_IDALERGIA)
);

ALTER TABLE GHALE_ALERG COMMENT 'ERS: RF-HC-006
Conserva fuente, responsable y verifica';

/*==============================================================*/
/* Table: GHASI_ASIGN                                           */
/*==============================================================*/
CREATE TABLE GHASI_ASIGN
(
   GHASI_ASIGN_IDASIGNACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHADM_ADMIS_IDADMISION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHCAM_CAMA_IDCAMA    VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHASI_ASIGN_DESDE    DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHASI_ASIGN_HASTA    DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GHASI_ASIGN_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHASI_ASIGN_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHASI_ASIGN_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHASI_ASIGN_IDASIGNACION)
);

ALTER TABLE GHASI_ASIGN COMMENT 'ERS: RF-HOS-003, RF-HOS-004
Intervalo de ocupación de ';

/*==============================================================*/
/* Table: GHCAM_CAMA                                            */
/*==============================================================*/
CREATE TABLE GHCAM_CAMA
(
   GHCAM_CAMA_IDCAMA    VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_HABITACION_IDHABITACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHCAM_CAMA_CODIGO    VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHCAM_CAMA_TIPOCAMA  VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHCAM_CAMA_ESTADOOPERATIVO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHCAM_CAMA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHCAM_CAMA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHCAM_CAMA_IDCAMA),
   KEY AK_AK_CAMA_CODIGO (GHCAM_CAMA_CODIGO)
);

ALTER TABLE GHCAM_CAMA COMMENT 'ERS: RF-HOS-002
La habitación y su servicio se represe';

/*==============================================================*/
/* Table: GHCIT_CITA                                            */
/*==============================================================*/
CREATE TABLE GHCIT_CITA
(
   GHCIT_CITA_IDCITA    VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_TURNO_AGENDA_IDTURNO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_IDPACIENTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GHCIT_CITA_MOTIVO    VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHCIT_CITA_ESTADO    VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHCIT_CITA_MOTIVOCANCELACION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHCIT_CITA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHCIT_CITA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHCIT_CITA_IDCITA)
);

ALTER TABLE GHCIT_CITA COMMENT 'ERS: RF-CIT-002, RF-CIT-003, RF-CIT-004, RF-CIT-005, RF-CIT-';

/*==============================================================*/
/* Table: GHDIA_DIAGN                                           */
/*==============================================================*/
CREATE TABLE GHDIA_DIAGN
(
   GHDIA_DIAGN_IDDIAGNOSTICO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_CATALOGO_DIAGNOSTICO_IDCONCEPTODIAGNOSTICO VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GHDIA_DIAGN_FECHAEFECTIVA DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHDIA_DIAGN_DESCRIPCIONREGISTRADA VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHDIA_DIAGN_TIPODIAGNOSTICO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHDIA_DIAGN_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHDIA_DIAGN_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHDIA_DIAGN_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHDIA_DIAGN_IDDIAGNOSTICO)
);

ALTER TABLE GHDIA_DIAGN COMMENT 'ERS: RF-HC-003
Diagnóstico ingresado por un profesiona';

/*==============================================================*/
/* Table: GHEPI_EPISO                                           */
/*==============================================================*/
CREATE TABLE GHEPI_EPISO
(
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_IDPACIENTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHCIT_CITA_IDCITA    VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GHADM_ADMIS_IDADMISION VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_ATENCION_EMERGENCIA_IDEMERGENCIA VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_TIPOATENCION VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHEPI_EPISO_INICIO   DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHEPI_EPISO_FIN      DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GHEPI_EPISO_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHEPI_EPISO_MOTIVOATENCION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHEPI_EPISO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHEPI_EPISO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHEPI_EPISO_IDEPISODIO)
);

ALTER TABLE GHEPI_EPISO COMMENT 'ERS: RF-HC-001, RF-HC-005
Pertenece a un paciente, pro';

/*==============================================================*/
/* Table: GHESP_ESPEC                                           */
/*==============================================================*/
CREATE TABLE GHESP_ESPEC
(
   GHESP_ESPEC_IDESPECIALIDAD VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHESP_ESPEC_CODIGO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHESP_ESPEC_DESCRIPCION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHESP_ESPEC_VIGENTEDESDE DATE COMMENT 'Tipo conceptual: Fecha. ',
   GHESP_ESPEC_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   GHESP_ESPEC_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHESP_ESPEC_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHESP_ESPEC_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHESP_ESPEC_IDESPECIALIDAD),
   KEY AK_AK_ESPECIALIDAD_CODIGO (GHESP_ESPEC_CODIGO)
);

ALTER TABLE GHESP_ESPEC COMMENT 'ERS: RF-CIT-001, RF-CAT-001, RF-CAT-002

registr';

/*==============================================================*/
/* Table: GHEST_ESTUD                                           */
/*==============================================================*/
CREATE TABLE GHEST_ESTUD
(
   GHEST_ESTUD_IDESTUDIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEST_ESTUD_SOLICITADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHEST_ESTUD_TIPOESTUDIO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHEST_ESTUD_INDICACIONCLINICA VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHEST_ESTUD_PROGRAMADOEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GHEST_ESTUD_INICIADOEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GHEST_ESTUD_FINALIZADOEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GHEST_ESTUD_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHEST_ESTUD_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHEST_ESTUD_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHEST_ESTUD_IDESTUDIO)
);

ALTER TABLE GHEST_ESTUD COMMENT 'ERS: RF-IMG-001, RF-IMG-002
Solicitud y ejecución del ';

/*==============================================================*/
/* Table: GHLOT_LOTE                                            */
/*==============================================================*/
CREATE TABLE GHLOT_LOTE
(
   GHLOT_LOTE_IDLOTE    VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHMED_MEDIC_IDMEDICAMENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHLOT_LOTE_NUMEROLOTE VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHLOT_LOTE_FABRICADOEL DATE COMMENT 'Tipo conceptual: Fecha. ',
   GHLOT_LOTE_CADUCAEL  DATE COMMENT 'Tipo conceptual: Fecha. ',
   GHLOT_LOTE_ESTADO    VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHLOT_LOTE_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHLOT_LOTE_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHLOT_LOTE_IDLOTE)
);

ALTER TABLE GHLOT_LOTE COMMENT 'ERS: RF-FAR-005
Lote de un medicamento, sin cantidad g';

/*==============================================================*/
/* Table: GHMED_MEDIC                                           */
/*==============================================================*/
CREATE TABLE GHMED_MEDIC
(
   GHMED_MEDIC_IDMEDICAMENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHMED_MEDIC_CODIGO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHMED_MEDIC_NOMBRE   VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHMED_MEDIC_PRESENTACION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHMED_MEDIC_CONCENTRACION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHMED_MEDIC_FORMAFARMACEUTICA VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHMED_MEDIC_UNIDADMEDIDA VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHMED_MEDIC_REQUIERELOTE BOOL NOT NULL COMMENT 'Tipo conceptual: Booleano. ',
   GHMED_MEDIC_REQUIERECADUCIDAD BOOL NOT NULL COMMENT 'Tipo conceptual: Booleano. ',
   GHMED_MEDIC_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHMED_MEDIC_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHMED_MEDIC_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHMED_MEDIC_IDMEDICAMENTO),
   KEY AK_AK_MEDICAMENTO_CODIGO (GHMED_MEDIC_CODIGO)
);

ALTER TABLE GHMED_MEDIC COMMENT 'ERS: RF-FAR-001
Catálogo; no almacena un stock global ';

/*==============================================================*/
/* Table: GHMOV_MOVIM                                           */
/*==============================================================*/
CREATE TABLE GHMOV_MOVIM
(
   GHMOV_MOVIM_IDMOVIMIENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHMED_MEDIC_IDMEDICAMENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHLOT_LOTE_IDLOTE    VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_UBICACION_INVENTARIO_IDUBICACION VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH__GH_UBICACION_INVENTARIO_IDUBICACION VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_DETALLE_DISPENSACION_IDDETALLEDISPENSACION VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GHMOV_MOVIM_MOVIDOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHMOV_MOVIM_TIPOMOVIMIENTO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHMOV_MOVIM_CANTIDAD NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Cantidad. ',
   GHMOV_MOVIM_MOTIVO   VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHMOV_MOVIM_REFERENCIADOCUMENTO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHMOV_MOVIM_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHMOV_MOVIM_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHMOV_MOVIM_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHMOV_MOVIM_IDMOVIMIENTO)
);

ALTER TABLE GHMOV_MOVIM COMMENT 'ERS: RF-FAR-006, RF-FAR-004
Un producto y lote aplicab';

/*==============================================================*/
/* Table: GHNOT_NOTAC                                           */
/*==============================================================*/
CREATE TABLE GHNOT_NOTAC
(
   GHNOT_NOTAC_IDNOTA   VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHN_GHNOT_NOTAC_IDNOTA VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GHNOT_NOTAC_TIPONOTA VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHNOT_NOTAC_FECHAEFECTIVA DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHNOT_NOTAC_CONTENIDO TEXT NOT NULL COMMENT 'Tipo conceptual: TextoLargo. ',
   GHNOT_NOTAC_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHNOT_NOTAC_VERSION  INT NOT NULL COMMENT 'Tipo conceptual: Entero. ',
   GHNOT_NOTAC_FINALIZADAEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GHNOT_NOTAC_MECANISMOFINALIZACION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHNOT_NOTAC_MOTIVORECTIFICACION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHNOT_NOTAC_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHNOT_NOTAC_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHNOT_NOTAC_IDNOTA)
);

ALTER TABLE GHNOT_NOTAC COMMENT 'ERS: RF-HC-002, RF-HC-004, RF-HC-007
El autor es un pr';

/*==============================================================*/
/* Table: GHPRES_PRESC                                          */
/*==============================================================*/
CREATE TABLE GHPRES_PRESC
(
   GHPRES_PRESC_IDPRESCRIPCION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRES_PRESC_PRESCRITAEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHPRES_PRESC_ESTADO  VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHPRES_PRESC_OBSERVACIONES VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHPRES_PRESC_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHPRES_PRESC_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHPRES_PRESC_IDPRESCRIPCION)
);

ALTER TABLE GHPRES_PRESC COMMENT 'ERS: RF-HC-002, RF-FAR-003
Cabecera de orden terapéuti';

/*==============================================================*/
/* Table: GHPRO_PROFE                                           */
/*==============================================================*/
CREATE TABLE GHPRO_PROFE
(
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_NOMBRES  VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHPRO_PROFE_APELLIDOS VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHPRO_PROFE_TIPOPROFESIONAL VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHPRO_PROFE_REGISTROPROFESIONAL VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHPRO_PROFE_TELEFONO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHPRO_PROFE_CORREO   VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHPRO_PROFE_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHPRO_PROFE_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHPRO_PROFE_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHPRO_PROFE_IDPROFESIONAL)
);

ALTER TABLE GHPRO_PROFE COMMENT 'ERS: RF-CIT-001, RF-HC-001
Identidad profesional clíni';

/*==============================================================*/
/* Table: GHPRQ_PROCQ                                           */
/*==============================================================*/
CREATE TABLE GHPRQ_PROCQ
(
   GHPRQ_PROCQ_IDPROCEDIMIENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRQ_PROCQ_PROCEDIMIENTOINDICADO VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GHPRQ_PROCQ_PROGRAMADODESDE DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHPRQ_PROCQ_PROGRAMADOHASTA DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHPRQ_PROCQ_INICIOREAL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GHPRQ_PROCQ_FINREAL  DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GHPRQ_PROCQ_PROCEDIMIENTOREALIZADO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHPRQ_PROCQ_OBSERVACIONES TEXT COMMENT 'Tipo conceptual: TextoLargo. ',
   GHPRQ_PROCQ_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHPRQ_PROCQ_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHPRQ_PROCQ_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHPRQ_PROCQ_IDPROCEDIMIENTO)
);

ALTER TABLE GHPRQ_PROCQ COMMENT 'ERS: RF-QUI-001, RF-QUI-003
Programación e intervenció';

/*==============================================================*/
/* Table: GHRES_RESUL                                           */
/*==============================================================*/
CREATE TABLE GHRES_RESUL
(
   GHRES_RESUL_IDRESULTADO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_ITEM_SOLICITUD_LAB_IDITEMSOLICITUD VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_PARAMETRO_EXAMEN_IDPARAMETRO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_MUESTRA_LABORATORIO_IDMUESTRA VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GHRES_RESUL_PROCESADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHRES_RESUL_TIPOVALOR VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHRES_RESUL_VALORREGISTRADO TEXT NOT NULL COMMENT 'Tipo conceptual: TextoLargo. ',
   GHRES_RESUL_UNIDADAPLICADA VARCHAR(40) COMMENT 'Tipo conceptual: Codigo. ',
   GHRES_RESUL_REFERENCIAAPLICADA VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHRES_RESUL_METODOAPLICADO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHRES_RESUL_OBSERVACIONES VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHRES_RESUL_VERSION  INT NOT NULL COMMENT 'Tipo conceptual: Entero. ',
   GHRES_RESUL_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHRES_RESUL_LIBERADOEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GHRES_RESUL_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHRES_RESUL_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHRES_RESUL_IDRESULTADO)
);

ALTER TABLE GHRES_RESUL COMMENT 'ERS: RF-LAB-003, RF-LAB-004, RF-LAB-005
Resultado de u';

/*==============================================================*/
/* Table: GHSOL_SOLIC                                           */
/*==============================================================*/
CREATE TABLE GHSOL_SOLIC
(
   GHSOL_SOLIC_IDSOLICITUD VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHSOL_SOLIC_SOLICITADAEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHSOL_SOLIC_INSTRUCCIONESCLINICAS VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GHSOL_SOLIC_PRIORIDAD VARCHAR(40) COMMENT 'Tipo conceptual: Codigo. ',
   GHSOL_SOLIC_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GHSOL_SOLIC_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GHSOL_SOLIC_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GHSOL_SOLIC_IDSOLICITUD)
);

ALTER TABLE GHSOL_SOLIC COMMENT 'ERS: RF-LAB-001, RF-LAB-002
Cabecera del episodio y pr';

/*==============================================================*/
/* Table: GH_AJUSTE_FINANCIERO                                  */
/*==============================================================*/
CREATE TABLE GH_AJUSTE_FINANCIERO
(
   GH_AJUSTE_FINANCIERO_IDAJUSTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FIFAC_FACTU_IDFACTURA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FIPAG_PAGO_IDPAGO    VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_AJUSTE_FINANCIERO_TIPOAJUSTE VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_AJUSTE_FINANCIERO_AJUSTADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_AJUSTE_FINANCIERO_IMPORTE NUMERIC(18,6) COMMENT 'Tipo conceptual: Importe. ',
   GH_AJUSTE_FINANCIERO_MOTIVO VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_AJUSTE_FINANCIERO_REFERENCIAAUTORIZACION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_AJUSTE_FINANCIERO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_AJUSTE_FINANCIERO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_AJUSTE_FINANCIERO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_AJUSTE_FINANCIERO_IDAJUSTE)
);

ALTER TABLE GH_AJUSTE_FINANCIERO COMMENT 'ERS: RF-FAC-005, RF-FAC-006
Anulación o devolución exp';

/*==============================================================*/
/* Table: GH_ALTA_MEDICA                                        */
/*==============================================================*/
CREATE TABLE GH_ALTA_MEDICA
(
   GH_ALTA_MEDICA_IDALTAMEDICA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHADM_ADMIS_IDADMISION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_EGRESO_ADMINISTRATIVO_IDEGRESO VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_ALTA_MEDICA_AUTORIZADAEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_ALTA_MEDICA_INDICACIONESSALIDA TEXT NOT NULL COMMENT 'Tipo conceptual: TextoLargo. ',
   GH_ALTA_MEDICA_DOCUMENTACIONREQUERIDA TEXT COMMENT 'Tipo conceptual: TextoLargo. ',
   GH_ALTA_MEDICA_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_ALTA_MEDICA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_ALTA_MEDICA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_ALTA_MEDICA_IDALTAMEDICA)
);

ALTER TABLE GH_ALTA_MEDICA COMMENT 'ERS: RF-HOS-006
Decisión clínica del médico para admis';

/*==============================================================*/
/* Table: GH_ATENCION_EMERGENCIA                                */
/*==============================================================*/
CREATE TABLE GH_ATENCION_EMERGENCIA
(
   GH_ATENCION_EMERGENCIA_IDEMERGENCIA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_IDPACIENTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_ATENCION_EMERGENCIA_INGRESOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_ATENCION_EMERGENCIA_PROCEDENCIA VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_ATENCION_EMERGENCIA_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_ATENCION_EMERGENCIA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_ATENCION_EMERGENCIA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_ATENCION_EMERGENCIA_IDEMERGENCIA)
);

ALTER TABLE GH_ATENCION_EMERGENCIA COMMENT 'ERS: RF-EME-001, RF-EME-003
El paciente puede conserva';

/*==============================================================*/
/* Table: GH_CAMBIO_CATALOGO                                    */
/*==============================================================*/
CREATE TABLE GH_CAMBIO_CATALOGO
(
   GH_CAMBIO_CATALOGO_IDCAMBIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_VALOR_CATALOGO_IDVALOR VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_CAMBIO_CATALOGO_CAMBIADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_CAMBIO_CATALOGO_OPERACION VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_CAMBIO_CATALOGO_VALORANTERIOR TEXT COMMENT 'Tipo conceptual: TextoLargo. ',
   GH_CAMBIO_CATALOGO_VALORNUEVO TEXT COMMENT 'Tipo conceptual: TextoLargo. ',
   GH_CAMBIO_CATALOGO_MOTIVO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_CAMBIO_CATALOGO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_CAMBIO_CATALOGO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_CAMBIO_CATALOGO_IDCAMBIO)
);

ALTER TABLE GH_CAMBIO_CATALOGO COMMENT 'ERS: RF-CAT-003
Historial de configuración de negocio ';

/*==============================================================*/
/* Table: GH_CATALOGO                                           */
/*==============================================================*/
CREATE TABLE GH_CATALOGO
(
   GH_CATALOGO_IDCATALOGO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_CATALOGO_CODIGO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_CATALOGO_NOMBRE   VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_CATALOGO_DESCRIPCION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_CATALOGO_ESTADO   VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_CATALOGO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_CATALOGO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_CATALOGO_IDCATALOGO),
   KEY AK_AK_CATALOGO_CODIGO (GH_CATALOGO_CODIGO)
);

ALTER TABLE GH_CATALOGO COMMENT 'ERS: RF-CAT-001, RF-CAT-002
Catálogos operativos aprob';

/*==============================================================*/
/* Table: GH_CATALOGO_DIAGNOSTICO                               */
/*==============================================================*/
CREATE TABLE GH_CATALOGO_DIAGNOSTICO
(
   GH_CATALOGO_DIAGNOSTICO_IDCONCEPTODIAGNOSTICO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_CATALOGO_DIAGNOSTICO_SISTEMACLASIFICACION VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_CATALOGO_DIAGNOSTICO_VERSIONCLASIFICACION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_CATALOGO_DIAGNOSTICO_CODIGO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_CATALOGO_DIAGNOSTICO_DESCRIPCION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_CATALOGO_DIAGNOSTICO_VIGENTEDESDE DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_CATALOGO_DIAGNOSTICO_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_CATALOGO_DIAGNOSTICO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_CATALOGO_DIAGNOSTICO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_CATALOGO_DIAGNOSTICO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_CATALOGO_DIAGNOSTICO_IDCONCEPTODIAGNOSTICO)
);

ALTER TABLE GH_CATALOGO_DIAGNOSTICO COMMENT 'ERS: RF-HC-003, RF-CAT-001, RF-CAT-002
Clasificación i';

/*==============================================================*/
/* Table: GH_CONTACTO_PACIENTE                                  */
/*==============================================================*/
CREATE TABLE GH_CONTACTO_PACIENTE
(
   GH_CONTACTO_PACIENTE_IDCONTACTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_IDPACIENTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_CONTACTO_PACIENTE_TIPOVINCULO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_CONTACTO_PACIENTE_NOMBRECONTACTO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_CONTACTO_PACIENTE_TELEFONO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_CONTACTO_PACIENTE_CORREO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_CONTACTO_PACIENTE_PARENTESCO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_CONTACTO_PACIENTE_PRIORIDAD INT COMMENT 'Tipo conceptual: Entero. ',
   GH_CONTACTO_PACIENTE_VIGENTEDESDE DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_CONTACTO_PACIENTE_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_CONTACTO_PACIENTE_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_CONTACTO_PACIENTE_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_CONTACTO_PACIENTE_IDCONTACTO)
);

ALTER TABLE GH_CONTACTO_PACIENTE COMMENT 'ERS: RF-PAC-001, RF-PAC-003
Contacto propio, represent';

/*==============================================================*/
/* Table: GH_CONTROL_PREOPERATORIO                              */
/*==============================================================*/
CREATE TABLE GH_CONTROL_PREOPERATORIO
(
   GH_CONTROL_PREOPERATORIO_IDCONTROL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRQ_PROCQ_IDPROCEDIMIENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_CONTROL_PREOPERATORIO_PROTOCOLO VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_CONTROL_PREOPERATORIO_VERSIONPROTOCOLO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_CONTROL_PREOPERATORIO_CODIGOCONTROL VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_CONTROL_PREOPERATORIO_RESULTADOREGISTRADO VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_CONTROL_PREOPERATORIO_COMPLETADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_CONTROL_PREOPERATORIO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_CONTROL_PREOPERATORIO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_CONTROL_PREOPERATORIO_IDCONTROL)
);

ALTER TABLE GH_CONTROL_PREOPERATORIO COMMENT 'ERS: RF-QUI-002
Controles y personal que los completa ';

/*==============================================================*/
/* Table: GH_CUENTA_FACTURACION                                 */
/*==============================================================*/
CREATE TABLE GH_CUENTA_FACTURACION
(
   GH_CUENTA_FACTURACION_IDCUENTA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_IDPACIENTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_CUENTA_FACTURACION_ABIERTAEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_CUENTA_FACTURACION_CERRADAEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_CUENTA_FACTURACION_MONEDA VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_CUENTA_FACTURACION_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_CUENTA_FACTURACION_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_CUENTA_FACTURACION_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_CUENTA_FACTURACION_IDCUENTA)
);

ALTER TABLE GH_CUENTA_FACTURACION COMMENT 'ERS: RF-FAC-001, RF-FAC-006
Cuenta de un paciente, vin';

/*==============================================================*/
/* Table: GH_DETALLE_DISPENSACION                               */
/*==============================================================*/
CREATE TABLE GH_DETALLE_DISPENSACION
(
   GH_DETALLE_DISPENSACION_IDDETALLEDISPENSACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_DISPENSACION_IDDISPENSACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_ITEM_PRESCRIPCION_IDITEMPRESCRIPCION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHLOT_LOTE_IDLOTE    VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GHMOV_MOVIM_IDMOVIMIENTO VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_DETALLE_DISPENSACION_CANTIDAD NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Cantidad. ',
   GH_DETALLE_DISPENSACION_UNIDAD VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_DETALLE_DISPENSACION_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_DETALLE_DISPENSACION_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_DETALLE_DISPENSACION_IDDETALLEDISPENSACION)
);

ALTER TABLE GH_DETALLE_DISPENSACION COMMENT 'ERS: RF-FAR-004, RF-FAR-005, RF-FAR-006
Cantidad entre';

/*==============================================================*/
/* Table: GH_DETALLE_FACTURA                                    */
/*==============================================================*/
CREATE TABLE GH_DETALLE_FACTURA
(
   GH_DETALLE_FACTURA_IDDETALLEFACTURA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FIFAC_FACTU_IDFACTURA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   FICAR_CARGO_IDCARGO  VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_DETALLE_FACTURA_DESCRIPCIONAPLICADA VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_DETALLE_FACTURA_CANTIDAD NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Cantidad. ',
   GH_DETALLE_FACTURA_PRECIOUNITARIOAPLICADO NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Importe. ',
   GH_DETALLE_FACTURA_DESCUENTOAPLICADO NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Importe. ',
   GH_DETALLE_FACTURA_TASAIMPUESTOAPLICADA NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Cantidad. ',
   GH_DETALLE_FACTURA_IMPUESTOAPLICADO NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Importe. ',
   GH_DETALLE_FACTURA_TOTALLINEA NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Importe. ',
   GH_DETALLE_FACTURA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_DETALLE_FACTURA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_DETALLE_FACTURA_IDDETALLEFACTURA)
);

ALTER TABLE GH_DETALLE_FACTURA COMMENT 'ERS: RF-FAC-001, RF-FAC-002, RF-FAC-003
Instantánea de';

/*==============================================================*/
/* Table: GH_DISPENSACION                                       */
/*==============================================================*/
CREATE TABLE GH_DISPENSACION
(
   GH_DISPENSACION_IDDISPENSACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRES_PRESC_IDPRESCRIPCION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_UBICACION_INVENTARIO_IDUBICACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_DISPENSACION_DISPENSADAEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_DISPENSACION_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_DISPENSACION_OBSERVACIONES VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_DISPENSACION_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_DISPENSACION_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_DISPENSACION_IDDISPENSACION)
);

ALTER TABLE GH_DISPENSACION COMMENT 'ERS: RF-FAR-003, RF-FAR-004
Entrega vinculada a una pr';

/*==============================================================*/
/* Table: GH_DISPOSICION_EMERGENCIA                             */
/*==============================================================*/
CREATE TABLE GH_DISPOSICION_EMERGENCIA
(
   GH_DISPOSICION_EMERGENCIA_IDDISPOSICION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_ATENCION_EMERGENCIA_IDEMERGENCIA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_DISPOSICION_EMERGENCIA_DECIDIDAEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_DISPOSICION_EMERGENCIA_TIPODISPOSICION VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_DISPOSICION_EMERGENCIA_INDICACIONES TEXT COMMENT 'Tipo conceptual: TextoLargo. ',
   GH_DISPOSICION_EMERGENCIA_DOCUMENTACION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_DISPOSICION_EMERGENCIA_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_DISPOSICION_EMERGENCIA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_DISPOSICION_EMERGENCIA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_DISPOSICION_EMERGENCIA_IDDISPOSICION)
);

ALTER TABLE GH_DISPOSICION_EMERGENCIA COMMENT 'ERS: RF-EME-004
Decisión profesional de alta, hospital';

/*==============================================================*/
/* Table: GH_DOCUMENTO_CLINICO                                  */
/*==============================================================*/
CREATE TABLE GH_DOCUMENTO_CLINICO
(
   GH_DOCUMENTO_CLINICO_IDDOCUMENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEST_ESTUD_IDESTUDIO VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_DOCUMENTO_CLINICO_TIPODOCUMENTO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_DOCUMENTO_CLINICO_NOMBRE VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_DOCUMENTO_CLINICO_TIPOCONTENIDO VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_DOCUMENTO_CLINICO_TAMANOBYTES INT NOT NULL COMMENT 'Tipo conceptual: Entero. ',
   GH_DOCUMENTO_CLINICO_REFERENCIAREPOSITORIO VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_DOCUMENTO_CLINICO_VERSION INT NOT NULL COMMENT 'Tipo conceptual: Entero. ',
   GH_DOCUMENTO_CLINICO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_DOCUMENTO_CLINICO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_DOCUMENTO_CLINICO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_DOCUMENTO_CLINICO_IDDOCUMENTO)
);

ALTER TABLE GH_DOCUMENTO_CLINICO COMMENT 'ERS: RF-HC-008, RF-IMG-004
Referencia al contenido pro';

/*==============================================================*/
/* Table: GH_EGRESO_ADMINISTRATIVO                              */
/*==============================================================*/
CREATE TABLE GH_EGRESO_ADMINISTRATIVO
(
   GH_EGRESO_ADMINISTRATIVO_IDEGRESO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHADM_ADMIS_IDADMISION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_ALTA_MEDICA_IDALTAMEDICA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_EGRESO_ADMINISTRATIVO_EGRESOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_EGRESO_ADMINISTRATIVO_DOCUMENTACIONVERIFICADA VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_EGRESO_ADMINISTRATIVO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_EGRESO_ADMINISTRATIVO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_EGRESO_ADMINISTRATIVO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_EGRESO_ADMINISTRATIVO_IDEGRESO)
);

ALTER TABLE GH_EGRESO_ADMINISTRATIVO COMMENT 'ERS: RF-HOS-006
Solo se confirma con alta médica autor';

/*==============================================================*/
/* Table: GH_EXAMEN_LABORATORIO                                 */
/*==============================================================*/
CREATE TABLE GH_EXAMEN_LABORATORIO
(
   GH_EXAMEN_LABORATORIO_IDEXAMEN VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_EXAMEN_LABORATORIO_CODIGO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_EXAMEN_LABORATORIO_NOMBRE VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_EXAMEN_LABORATORIO_VIGENTEDESDE DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_EXAMEN_LABORATORIO_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_EXAMEN_LABORATORIO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_EXAMEN_LABORATORIO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_EXAMEN_LABORATORIO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_EXAMEN_LABORATORIO_IDEXAMEN),
   KEY AK_AK_EXAMEN_LABORATORIO_CODIGO (GH_EXAMEN_LABORATORIO_CODIGO)
);

ALTER TABLE GH_EXAMEN_LABORATORIO COMMENT 'ERS: RF-LAB-001, RF-CAT-001, RF-CAT-002

registr';

/*==============================================================*/
/* Table: GH_EXISTENCIA                                         */
/*==============================================================*/
CREATE TABLE GH_EXISTENCIA
(
   GH_EXISTENCIA_IDEXISTENCIA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHMED_MEDIC_IDMEDICAMENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_UBICACION_INVENTARIO_IDUBICACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHLOT_LOTE_IDLOTE    VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_EXISTENCIA_CANTIDADFISICA NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Cantidad. ',
   GH_EXISTENCIA_CANTIDADRESERVADA NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Cantidad. ',
   GH_EXISTENCIA_CANTIDADNODISPENSABLE NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Cantidad. ',
   GH_EXISTENCIA_ACTUALIZADAEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_EXISTENCIA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_EXISTENCIA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_EXISTENCIA_IDEXISTENCIA)
);

ALTER TABLE GH_EXISTENCIA COMMENT 'ERS: RF-FAR-002, RF-FAR-004, RF-FAR-005
Única por medi';

/*==============================================================*/
/* Table: GH_HABILITACION_PROFESIONAL                           */
/*==============================================================*/
CREATE TABLE GH_HABILITACION_PROFESIONAL
(
   GH_HABILITACION_PROFESIONAL_IDHABILITACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHESP_ESPEC_IDESPECIALIDAD VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_HABILITACION_PROFESIONAL_REGISTROHABILITACION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_HABILITACION_PROFESIONAL_VIGENTEDESDE DATE NOT NULL COMMENT 'Tipo conceptual: Fecha. ',
   GH_HABILITACION_PROFESIONAL_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_HABILITACION_PROFESIONAL_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_HABILITACION_PROFESIONAL_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_HABILITACION_PROFESIONAL_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_HABILITACION_PROFESIONAL_IDHABILITACION)
);

ALTER TABLE GH_HABILITACION_PROFESIONAL COMMENT 'ERS: RF-CIT-001
Asociación temporal entre profesional ';

/*==============================================================*/
/* Table: GH_HABITACION                                         */
/*==============================================================*/
CREATE TABLE GH_HABITACION
(
   GH_HABITACION_IDHABITACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_HABITACION_CODIGO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_HABITACION_PISO   VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_HABITACION_DESCRIPCION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_HABITACION_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_HABITACION_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_HABITACION_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_HABITACION_IDHABITACION),
   KEY AK_AK_HABITACION_CODIGO (GH_HABITACION_CODIGO)
);

ALTER TABLE GH_HABITACION COMMENT 'ERS: RF-HOS-002

registradoPor identifica al res';

/*==============================================================*/
/* Table: GH_HISTORIAL_CITA                                     */
/*==============================================================*/
CREATE TABLE GH_HISTORIAL_CITA
(
   GH_HISTORIAL_CITA_IDCAMBIOCITA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHCIT_CITA_IDCITA    VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_HISTORIAL_CITA_FECHAEFECTIVA DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_HISTORIAL_CITA_ESTADOANTERIOR VARCHAR(40) COMMENT 'Tipo conceptual: Codigo. ',
   GH_HISTORIAL_CITA_ESTADONUEVO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_HISTORIAL_CITA_INICIOANTERIOR DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_HISTORIAL_CITA_INICIONUEVO DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_HISTORIAL_CITA_MOTIVO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_HISTORIAL_CITA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_HISTORIAL_CITA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_HISTORIAL_CITA_IDCAMBIOCITA)
);

ALTER TABLE GH_HISTORIAL_CITA COMMENT 'ERS: RF-CIT-003, RF-CIT-004, RF-CIT-005
Registra creac';

/*==============================================================*/
/* Table: GH_HISTORIAL_ESTADO_CAMA                              */
/*==============================================================*/
CREATE TABLE GH_HISTORIAL_ESTADO_CAMA
(
   GH_HISTORIAL_ESTADO_CAMA_IDESTADOCAMA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHCAM_CAMA_IDCAMA    VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_HISTORIAL_ESTADO_CAMA_DESDE DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_HISTORIAL_ESTADO_CAMA_HASTA DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_HISTORIAL_ESTADO_CAMA_ESTADOOPERATIVO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_HISTORIAL_ESTADO_CAMA_MOTIVO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_HISTORIAL_ESTADO_CAMA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_HISTORIAL_ESTADO_CAMA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_HISTORIAL_ESTADO_CAMA_IDESTADOCAMA)
);

ALTER TABLE GH_HISTORIAL_ESTADO_CAMA COMMENT 'ERS: RF-HOS-002, RF-HOS-006
Permite reconstruir estado';

/*==============================================================*/
/* Table: GH_INFORME_IMAGEN                                     */
/*==============================================================*/
CREATE TABLE GH_INFORME_IMAGEN
(
   GH_INFORME_IMAGEN_IDINFORME VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEST_ESTUD_IDESTUDIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHP_GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_INFORME_IMAGEN_VERSION INT NOT NULL COMMENT 'Tipo conceptual: Entero. ',
   GH_INFORME_IMAGEN_CONTENIDO TEXT NOT NULL COMMENT 'Tipo conceptual: TextoLargo. ',
   GH_INFORME_IMAGEN_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_INFORME_IMAGEN_ELABORADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_INFORME_IMAGEN_VALIDADOEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_INFORME_IMAGEN_PUBLICADOEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_INFORME_IMAGEN_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_INFORME_IMAGEN_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_INFORME_IMAGEN_IDINFORME)
);

ALTER TABLE GH_INFORME_IMAGEN COMMENT 'ERS: RF-IMG-003, RF-IMG-004
Informe del profesional ha';

/*==============================================================*/
/* Table: GH_ITEM_PRESCRIPCION                                  */
/*==============================================================*/
CREATE TABLE GH_ITEM_PRESCRIPCION
(
   GH_ITEM_PRESCRIPCION_IDITEMPRESCRIPCION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRES_PRESC_IDPRESCRIPCION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHMED_MEDIC_IDMEDICAMENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_ITEM_PRESCRIPCION_DOSIS VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_ITEM_PRESCRIPCION_VIA VARCHAR(40) COMMENT 'Tipo conceptual: Codigo. ',
   GH_ITEM_PRESCRIPCION_FRECUENCIA VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_ITEM_PRESCRIPCION_DURACION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_ITEM_PRESCRIPCION_CANTIDADINDICADA NUMERIC(18,6) COMMENT 'Tipo conceptual: Cantidad. ',
   GH_ITEM_PRESCRIPCION_INDICACIONES VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_ITEM_PRESCRIPCION_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_ITEM_PRESCRIPCION_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_ITEM_PRESCRIPCION_IDITEMPRESCRIPCION)
);

ALTER TABLE GH_ITEM_PRESCRIPCION COMMENT 'ERS: RF-HC-002, RF-FAR-003
Un medicamento por ítem. La';

/*==============================================================*/
/* Table: GH_ITEM_SOLICITUD_LAB                                 */
/*==============================================================*/
CREATE TABLE GH_ITEM_SOLICITUD_LAB
(
   GH_ITEM_SOLICITUD_LAB_IDITEMSOLICITUD VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHSOL_SOLIC_IDSOLICITUD VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_EXAMEN_LABORATORIO_IDEXAMEN VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_ITEM_SOLICITUD_LAB_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_ITEM_SOLICITUD_LAB_INSTRUCCIONES VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_ITEM_SOLICITUD_LAB_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_ITEM_SOLICITUD_LAB_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_ITEM_SOLICITUD_LAB_IDITEMSOLICITUD)
);

ALTER TABLE GH_ITEM_SOLICITUD_LAB COMMENT 'ERS: RF-LAB-001, RF-LAB-002
Un examen solicitado dentr';

/*==============================================================*/
/* Table: GH_MEDICION_SIGNO                                     */
/*==============================================================*/
CREATE TABLE GH_MEDICION_SIGNO
(
   GH_MEDICION_SIGNO_IDMEDICION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_REGISTRO_ENFERMERIA_IDREGISTROENFERMERIA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_MEDICION_SIGNO_TIPOSIGNO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_MEDICION_SIGNO_VALOR NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Cantidad. ',
   GH_MEDICION_SIGNO_UNIDAD VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_MEDICION_SIGNO_MEDIDOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_MEDICION_SIGNO_OBSERVACION VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_MEDICION_SIGNO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_MEDICION_SIGNO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_MEDICION_SIGNO_IDMEDICION)
);

ALTER TABLE GH_MEDICION_SIGNO COMMENT 'ERS: RF-HOS-005, RF-EME-003
Una medición identificable';

/*==============================================================*/
/* Table: GH_MUESTRA_LABORATORIO                                */
/*==============================================================*/
CREATE TABLE GH_MUESTRA_LABORATORIO
(
   GH_MUESTRA_LABORATORIO_IDMUESTRA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_IDPACIENTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_MUESTRA_LABORATORIO_IDENTIFICADORMUESTRA VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_MUESTRA_LABORATORIO_TIPOMUESTRA VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_MUESTRA_LABORATORIO_TOMADAEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_MUESTRA_LABORATORIO_RECIBIDAEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_MUESTRA_LABORATORIO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_MUESTRA_LABORATORIO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_MUESTRA_LABORATORIO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_MUESTRA_LABORATORIO_IDMUESTRA),
   KEY AK_AK_MUESTRA_LABORATORIO_IDENTIFICADORMUESTRA (GH_MUESTRA_LABORATORIO_IDENTIFICADORMUESTRA)
);

ALTER TABLE GH_MUESTRA_LABORATORIO COMMENT 'ERS: RF-LAB-002, RF-LAB-003
Pertenece al paciente de l';

/*==============================================================*/
/* Table: GH_PARAMETRO_EXAMEN                                   */
/*==============================================================*/
CREATE TABLE GH_PARAMETRO_EXAMEN
(
   GH_PARAMETRO_EXAMEN_IDPARAMETRO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_EXAMEN_LABORATORIO_IDEXAMEN VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_PARAMETRO_EXAMEN_CODIGO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_PARAMETRO_EXAMEN_NOMBRE VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_PARAMETRO_EXAMEN_TIPOVALOR VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_PARAMETRO_EXAMEN_UNIDADORIENTATIVA VARCHAR(40) COMMENT 'Tipo conceptual: Codigo. ',
   GH_PARAMETRO_EXAMEN_METODO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_PARAMETRO_EXAMEN_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_PARAMETRO_EXAMEN_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_PARAMETRO_EXAMEN_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_PARAMETRO_EXAMEN_IDPARAMETRO)
);

ALTER TABLE GH_PARAMETRO_EXAMEN COMMENT 'ERS: RF-LAB-003
Componente de un examen, incluso una c';

/*==============================================================*/
/* Table: GH_PARTICIPACION_QUIRURGICA                           */
/*==============================================================*/
CREATE TABLE GH_PARTICIPACION_QUIRURGICA
(
   GH_PARTICIPACION_QUIRURGICA_IDPARTICIPACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRQ_PROCQ_IDPROCEDIMIENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_PARTICIPACION_QUIRURGICA_ROLENEQUIPO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_PARTICIPACION_QUIRURGICA_DESDE DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_PARTICIPACION_QUIRURGICA_HASTA DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_PARTICIPACION_QUIRURGICA_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_PARTICIPACION_QUIRURGICA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_PARTICIPACION_QUIRURGICA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_PARTICIPACION_QUIRURGICA_IDPARTICIPACION)
);

ALTER TABLE GH_PARTICIPACION_QUIRURGICA COMMENT 'ERS: RF-QUI-001, RF-QUI-003
Equipo profesional con rol';

/*==============================================================*/
/* Table: GH_POLITICA_STOCK                                     */
/*==============================================================*/
CREATE TABLE GH_POLITICA_STOCK
(
   GH_POLITICA_STOCK_IDPOLITICASTOCK VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHMED_MEDIC_IDMEDICAMENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_UBICACION_INVENTARIO_IDUBICACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_POLITICA_STOCK_NIVELMINIMO NUMERIC(18,6) NOT NULL COMMENT 'Tipo conceptual: Cantidad. ',
   GH_POLITICA_STOCK_VIGENTEDESDE DATE NOT NULL COMMENT 'Tipo conceptual: Fecha. ',
   GH_POLITICA_STOCK_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_POLITICA_STOCK_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_POLITICA_STOCK_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_POLITICA_STOCK_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_POLITICA_STOCK_IDPOLITICASTOCK)
);

ALTER TABLE GH_POLITICA_STOCK COMMENT 'ERS: RF-FAR-007
Umbral por medicamento y ubicación. La';

/*==============================================================*/
/* Table: GH_RECURSO_QUIRURGICO                                 */
/*==============================================================*/
CREATE TABLE GH_RECURSO_QUIRURGICO
(
   GH_RECURSO_QUIRURGICO_IDRECURSO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_RECURSO_QUIRURGICO_CODIGO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_RECURSO_QUIRURGICO_TIPORECURSO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_RECURSO_QUIRURGICO_DESCRIPCION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_RECURSO_QUIRURGICO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_RECURSO_QUIRURGICO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_RECURSO_QUIRURGICO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_RECURSO_QUIRURGICO_IDRECURSO),
   KEY AK_AK_RECURSO_QUIRURGICO_CODIGO (GH_RECURSO_QUIRURGICO_CODIGO)
);

ALTER TABLE GH_RECURSO_QUIRURGICO COMMENT 'ERS: RF-QUI-001

registradoPor identifica al res';

/*==============================================================*/
/* Table: GH_REGISTRO_ENFERMERIA                                */
/*==============================================================*/
CREATE TABLE GH_REGISTRO_ENFERMERIA
(
   GH_REGISTRO_ENFERMERIA_IDREGISTROENFERMERIA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHEPI_EPISO_IDEPISODIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_REGISTRO_ENFERMERIA_TIPOREGISTRO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_REGISTRO_ENFERMERIA_FECHAEFECTIVA DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_REGISTRO_ENFERMERIA_OBSERVACIONOCUIDADO TEXT COMMENT 'Tipo conceptual: TextoLargo. ',
   GH_REGISTRO_ENFERMERIA_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_REGISTRO_ENFERMERIA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_REGISTRO_ENFERMERIA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_REGISTRO_ENFERMERIA_IDREGISTROENFERMERIA)
);

ALTER TABLE GH_REGISTRO_ENFERMERIA COMMENT 'ERS: RF-HOS-005, RF-EME-003
Documenta mediciones y cui';

/*==============================================================*/
/* Table: GH_REGISTRO_RECUPERACION                              */
/*==============================================================*/
CREATE TABLE GH_REGISTRO_RECUPERACION
(
   GH_REGISTRO_RECUPERACION_IDRECUPERACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRQ_PROCQ_IDPROCEDIMIENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_REGISTRO_RECUPERACION_FECHAEFECTIVA DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_REGISTRO_RECUPERACION_EVENTO TEXT NOT NULL COMMENT 'Tipo conceptual: TextoLargo. ',
   GH_REGISTRO_RECUPERACION_ESTADOPROCEDIMIENTO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_REGISTRO_RECUPERACION_DISPOSICIONPOSTERIOR VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_REGISTRO_RECUPERACION_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_REGISTRO_RECUPERACION_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_REGISTRO_RECUPERACION_IDRECUPERACION)
);

ALTER TABLE GH_REGISTRO_RECUPERACION COMMENT 'ERS: RF-QUI-004
Eventos de recuperación y cierre docum';

/*==============================================================*/
/* Table: GH_RESERVA_RECURSO                                    */
/*==============================================================*/
CREATE TABLE GH_RESERVA_RECURSO
(
   GH_RESERVA_RECURSO_IDRESERVA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRQ_PROCQ_IDPROCEDIMIENTO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_RECURSO_QUIRURGICO_IDRECURSO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_RESERVA_RECURSO_DESDE DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_RESERVA_RECURSO_HASTA DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_RESERVA_RECURSO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_RESERVA_RECURSO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_RESERVA_RECURSO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_RESERVA_RECURSO_IDRESERVA)
);

ALTER TABLE GH_RESERVA_RECURSO COMMENT 'ERS: RF-QUI-001
Un recurso gestionado para una cirugía';

/*==============================================================*/
/* Table: GH_REVISION_IDENTIDAD                                 */
/*==============================================================*/
CREATE TABLE GH_REVISION_IDENTIDAD
(
   GH_REVISION_IDENTIDAD_IDREVISION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEPAC_PACIE_IDPACIENTE VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GEP_GEPAC_PACIE_IDPACIENTE VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_REVISION_IDENTIDAD_TIPOREVISION VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_REVISION_IDENTIDAD_DECISION VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_REVISION_IDENTIDAD_FUNDAMENTO TEXT NOT NULL COMMENT 'Tipo conceptual: TextoLargo. ',
   GH_REVISION_IDENTIDAD_IDENTIFICADORANTERIOR VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_REVISION_IDENTIDAD_IDENTIFICADORCONFIRMADO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_REVISION_IDENTIDAD_RESUELTOEL DATETIME COMMENT 'Tipo conceptual: FechaHora. ',
   GH_REVISION_IDENTIDAD_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_REVISION_IDENTIDAD_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_REVISION_IDENTIDAD_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_REVISION_IDENTIDAD_IDREVISION)
);

ALTER TABLE GH_REVISION_IDENTIDAD COMMENT 'ERS: RF-PAC-005, RF-EME-001
Distingue coincidencia des';

/*==============================================================*/
/* Table: GH_SERVICIO_HOSPITALARIO                              */
/*==============================================================*/
CREATE TABLE GH_SERVICIO_HOSPITALARIO
(
   GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_SERVICIO_HOSPITALARIO_CODIGO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_SERVICIO_HOSPITALARIO_DESCRIPCION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_SERVICIO_HOSPITALARIO_VIGENTEDESDE DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_SERVICIO_HOSPITALARIO_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_SERVICIO_HOSPITALARIO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_SERVICIO_HOSPITALARIO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_SERVICIO_HOSPITALARIO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO),
   KEY AK_AK_SERVICIO_HOSPITALARIO_CODIGO (GH_SERVICIO_HOSPITALARIO_CODIGO)
);

ALTER TABLE GH_SERVICIO_HOSPITALARIO COMMENT 'ERS: RF-CIT-001, RF-HC-001, RF-HOS-001, RF-HOS-002, RF-CAT-0';

/*==============================================================*/
/* Table: GH_TRASLADO_HOSPITALARIO                              */
/*==============================================================*/
CREATE TABLE GH_TRASLADO_HOSPITALARIO
(
   GH_TRASLADO_HOSPITALARIO_IDTRASLADO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHADM_ADMIS_IDADMISION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH__GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHCAM_CAMA_IDCAMA    VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GHC_GHCAM_CAMA_IDCAMA VARCHAR(36) COMMENT 'Tipo conceptual: ID. ',
   GH_TRASLADO_HOSPITALARIO_TRASLADADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_TRASLADO_HOSPITALARIO_MOTIVO VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_TRASLADO_HOSPITALARIO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_TRASLADO_HOSPITALARIO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_TRASLADO_HOSPITALARIO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_TRASLADO_HOSPITALARIO_IDTRASLADO)
);

ALTER TABLE GH_TRASLADO_HOSPITALARIO COMMENT 'ERS: RF-HOS-004
Registra admisión, servicios origen y ';

/*==============================================================*/
/* Table: GH_TRIAJE                                             */
/*==============================================================*/
CREATE TABLE GH_TRIAJE
(
   GH_TRIAJE_IDTRIAJE   VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_ATENCION_EMERGENCIA_IDEMERGENCIA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_TRIAJE_EVALUADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_TRIAJE_PROTOCOLO  VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_TRIAJE_VERSIONPROTOCOLO VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_TRIAJE_PRIORIDADREGISTRADA VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_TRIAJE_OBSERVACIONES VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_TRIAJE_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_TRIAJE_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_TRIAJE_IDTRIAJE)
);

ALTER TABLE GH_TRIAJE COMMENT 'ERS: RF-EME-002
La prioridad la ingresa personal compe';

/*==============================================================*/
/* Table: GH_TURNO_AGENDA                                       */
/*==============================================================*/
CREATE TABLE GH_TURNO_AGENDA
(
   GH_TURNO_AGENDA_IDTURNO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHAGE_AGEND_IDAGENDA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_TURNO_AGENDA_INICIO DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_TURNO_AGENDA_FIN  DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_TURNO_AGENDA_CAPACIDAD INT NOT NULL COMMENT 'Tipo conceptual: Entero. ',
   GH_TURNO_AGENDA_ESTADODISPONIBILIDAD VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_TURNO_AGENDA_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_TURNO_AGENDA_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_TURNO_AGENDA_IDTURNO)
);

ALTER TABLE GH_TURNO_AGENDA COMMENT 'ERS: RF-CIT-001, RF-CIT-002, RF-CIT-003
Unidad reserva';

/*==============================================================*/
/* Table: GH_UBICACION_INVENTARIO                               */
/*==============================================================*/
CREATE TABLE GH_UBICACION_INVENTARIO
(
   GH_UBICACION_INVENTARIO_IDUBICACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_UBICACION_INVENTARIO_CODIGO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_UBICACION_INVENTARIO_DESCRIPCION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_UBICACION_INVENTARIO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_UBICACION_INVENTARIO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_UBICACION_INVENTARIO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_UBICACION_INVENTARIO_IDUBICACION),
   KEY AK_AK_UBICACION_INVENTARIO_CODIGO (GH_UBICACION_INVENTARIO_CODIGO)
);

ALTER TABLE GH_UBICACION_INVENTARIO COMMENT 'ERS: RF-FAR-002, RF-FAR-006

registradoPor ident';

/*==============================================================*/
/* Table: GH_VALIDACION_RESULTADO                               */
/*==============================================================*/
CREATE TABLE GH_VALIDACION_RESULTADO
(
   GH_VALIDACION_RESULTADO_IDVALIDACION VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHRES_RESUL_IDRESULTADO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GHPRO_PROFE_IDPROFESIONAL VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_VALIDACION_RESULTADO_VALIDADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_VALIDACION_RESULTADO_DECISION VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_VALIDACION_RESULTADO_OBSERVACIONES VARCHAR(200) COMMENT 'Tipo conceptual: Texto. ',
   GH_VALIDACION_RESULTADO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_VALIDACION_RESULTADO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_VALIDACION_RESULTADO_IDVALIDACION)
);

ALTER TABLE GH_VALIDACION_RESULTADO COMMENT 'ERS: RF-LAB-004, RF-LAB-005
Validación por profesional';

/*==============================================================*/
/* Table: GH_VALOR_CATALOGO                                     */
/*==============================================================*/
CREATE TABLE GH_VALOR_CATALOGO
(
   GH_VALOR_CATALOGO_IDVALOR VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_CATALOGO_IDCATALOGO VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_VALOR_CATALOGO_CODIGO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_VALOR_CATALOGO_DESCRIPCION VARCHAR(200) NOT NULL COMMENT 'Tipo conceptual: Texto. ',
   GH_VALOR_CATALOGO_VIGENTEDESDE DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_VALOR_CATALOGO_VIGENTEHASTA DATE COMMENT 'Tipo conceptual: Fecha. ',
   GH_VALOR_CATALOGO_ESTADO VARCHAR(40) NOT NULL COMMENT 'Tipo conceptual: Codigo. ',
   GH_VALOR_CATALOGO_REGISTRADOEL DATETIME NOT NULL COMMENT 'Tipo conceptual: FechaHora. ',
   GH_VALOR_CATALOGO_REGISTRADOPOR VARCHAR(100) NOT NULL COMMENT 'Tipo conceptual: Responsable. Referencia al responsable de registro; la cuenta existente no se modifica.',
   PRIMARY KEY (GH_VALOR_CATALOGO_IDVALOR)
);

ALTER TABLE GH_VALOR_CATALOGO COMMENT 'ERS: RF-CAT-001, RF-CAT-002
Código único dentro de su ';

/*==============================================================*/
/* Table: PECAR_CARGO                                           */
/*==============================================================*/
CREATE TABLE PECAR_CARGO
(
   PEDEP_CODIGO         CHAR(3) NOT NULL,
   PECAR_CODIGO         CHAR(3) NOT NULL,
   PECAR_DESCRI         VARCHAR(50) NOT NULL,
   PRIMARY KEY (PEDEP_CODIGO, PECAR_CODIGO)
);

ALTER TABLE PECAR_CARGO COMMENT 'Entidad utilizada para gestionar los cargos que pertenecen a';

/*==============================================================*/
/* Table: PEDEP_DEPAR                                           */
/*==============================================================*/
CREATE TABLE PEDEP_DEPAR
(
   PEDEP_CODIGO         CHAR(3) NOT NULL,
   PEDEP_DESCRI         VARCHAR(50) NOT NULL,
   PRIMARY KEY (PEDEP_CODIGO)
);

ALTER TABLE PEDEP_DEPAR COMMENT 'Entidad utilizada para gestionar los diferentes departamento';

/*==============================================================*/
/* Table: PEESC_ESTCIV                                          */
/*==============================================================*/
CREATE TABLE PEESC_ESTCIV
(
   PEESC_CODIGO         CHAR(1) NOT NULL,
   PEESC_DESCRI         VARCHAR(50) NOT NULL,
   PRIMARY KEY (PEESC_CODIGO)
);

ALTER TABLE PEESC_ESTCIV COMMENT 'Entidad utilizada para gestionar el ESTADO CIVIL de una pers';

/*==============================================================*/
/* Table: PEGEN_GENERO                                          */
/*==============================================================*/
CREATE TABLE PEGEN_GENERO
(
   PEGEN_CODIGO         CHAR(1) NOT NULL,
   PEGEN_DESCRI         VARCHAR(50) NOT NULL,
   PRIMARY KEY (PEGEN_CODIGO)
);

ALTER TABLE PEGEN_GENERO COMMENT 'Entidad utilizada para gestionar el genero o sexo de una per';

/*==============================================================*/
/* Table: PEPER_PERSO                                           */
/*==============================================================*/
CREATE TABLE PEPER_PERSO
(
   PEPER_CODIGO         CHAR(10) NOT NULL,
   PEGEN_CODIGO         CHAR(1) NOT NULL,
   PEESC_CODIGO         CHAR(1),
   PEPER_APELLI         VARCHAR(50) NOT NULL,
   PEPER_NOMBRE         VARCHAR(50) NOT NULL,
   PEPER_FECNAC         DATE NOT NULL,
   PEPER_CEDULA         VARCHAR(10),
   PEPER_PASAPO         VARCHAR(15),
   PEPER_EMAIL          VARCHAR(50),
   PEPER_CARFAM         NUMERIC(2,0) NOT NULL,
   PEPER_FOTO           VARCHAR(100) NOT NULL,
   PEPER_DISC           CHAR(1) NOT NULL,
   PRIMARY KEY (PEPER_CODIGO)
);

ALTER TABLE PEPER_PERSO COMMENT 'Entidad utilizada para gestionar las personas que haran uso ';

/*==============================================================*/
/* Table: R080_PROCESAMUESTRA                                   */
/*==============================================================*/
CREATE TABLE R080_PROCESAMUESTRA
(
   GH_ITEM_SOLICITUD_LAB_IDITEMSOLICITUD VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   GH_MUESTRA_LABORATORIO_IDMUESTRA VARCHAR(36) NOT NULL COMMENT 'Tipo conceptual: ID. ',
   PRIMARY KEY (GH_ITEM_SOLICITUD_LAB_IDITEMSOLICITUD, GH_MUESTRA_LABORATORIO_IDMUESTRA)
);

ALTER TABLE R080_PROCESAMUESTRA COMMENT 'Por cada MUESTRA_LABORATORIO: 0,n de ITEM_SOLICITUD_LAB. Por';

/*==============================================================*/
/* Table: XEEST_ESTAD                                           */
/*==============================================================*/
CREATE TABLE XEEST_ESTAD
(
   XEEST_CODIGO         CHAR(1) NOT NULL,
   XEEST_DESCRI         VARCHAR(50) NOT NULL,
   PRIMARY KEY (XEEST_CODIGO)
);

ALTER TABLE XEEST_ESTAD COMMENT 'Entidad utilizada para gestionar el estado de las difetrente';

/*==============================================================*/
/* Table: XEOPC_OPCIO                                           */
/*==============================================================*/
CREATE TABLE XEOPC_OPCIO
(
   XEOPC_CODIGO         CHAR(3) NOT NULL,
   XESIS_CODIGO         CHAR(1) NOT NULL,
   XEOPC_DESCRI         VARCHAR(100) NOT NULL,
   PRIMARY KEY (XEOPC_CODIGO)
);

ALTER TABLE XEOPC_OPCIO COMMENT 'Entidad utilizada para realizar el registro de las diferente';

/*==============================================================*/
/* Table: XEOXP_OPCPE                                           */
/*==============================================================*/
CREATE TABLE XEOXP_OPCPE
(
   XEOPC_CODIGO         CHAR(3) NOT NULL,
   XEPER_CODIGO         CHAR(8) NOT NULL,
   XEOXP_FECASI         DATE NOT NULL,
   XEOXP_FECRET         DATE,
   PRIMARY KEY (XEOPC_CODIGO, XEPER_CODIGO, XEOXP_FECASI)
);

ALTER TABLE XEOXP_OPCPE COMMENT 'Entidad utilizada para llevar el registro de las opciones qu';

/*==============================================================*/
/* Table: XEPER_PERFI                                           */
/*==============================================================*/
CREATE TABLE XEPER_PERFI
(
   XEPER_CODIGO         CHAR(8) NOT NULL,
   XEPER_DESCRI         VARCHAR(100) NOT NULL,
   XEPER_OBSER          TEXT,
   PRIMARY KEY (XEPER_CODIGO)
);

ALTER TABLE XEPER_PERFI COMMENT 'Entidad utilizada para realizar la gestión de los diferentes';

/*==============================================================*/
/* Table: XESIS_SISTE                                           */
/*==============================================================*/
CREATE TABLE XESIS_SISTE
(
   XESIS_CODIGO         CHAR(1) NOT NULL,
   XESIS_DESCRI         VARCHAR(50) NOT NULL,
   PRIMARY KEY (XESIS_CODIGO)
);

ALTER TABLE XESIS_SISTE COMMENT 'Entidad utilizada para realziar la gestión de los diferentes';

/*==============================================================*/
/* Table: XEUSU_USUAR                                           */
/*==============================================================*/
CREATE TABLE XEUSU_USUAR
(
   XEUSU_PASWD          VARCHAR(16) NOT NULL,
   XEEST_CODIGO         CHAR(1) NOT NULL,
   PEPER_CODIGO         CHAR(10) NOT NULL,
   XEUSU_FECCRE         DATETIME NOT NULL,
   XEUSU_FECMOD         DATETIME NOT NULL,
   XEUSU_PIEFIR         VARCHAR(100) NOT NULL,
   PRIMARY KEY (XEUSU_PASWD)
);

ALTER TABLE XEUSU_USUAR COMMENT 'Entidad relacionada para gentionar los usuario que ingrsan a';

/*==============================================================*/
/* Table: XEUXP_USUPE                                           */
/*==============================================================*/
CREATE TABLE XEUXP_USUPE
(
   XEUSU_PASWD          VARCHAR(16) NOT NULL,
   XEPER_CODIGO         CHAR(8) NOT NULL,
   XEUXP_FECASI         DATE NOT NULL,
   XEUXP_FECRET         DATE,
   PRIMARY KEY (XEUSU_PASWD, XEPER_CODIGO, XEUXP_FECASI)
);

ALTER TABLE XEUXP_USUPE COMMENT 'Entidad utilizada para realizar el registro de los diferente';

ALTER TABLE FICAR_CARGO ADD CONSTRAINT FK_R104_CARGOS FOREIGN KEY (GH_CUENTA_FACTURACION_IDCUENTA)
      REFERENCES GH_CUENTA_FACTURACION (GH_CUENTA_FACTURACION_IDCUENTA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE FICAR_CARGO ADD CONSTRAINT FK_R106_TARIFAORIGEN FOREIGN KEY (FITAR_TARIF_IDTARIFA)
      REFERENCES FITAR_TARIF (FITAR_TARIF_IDTARIFA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE FIFAC_FACTU ADD CONSTRAINT FK_R107_DOCUMENTOS FOREIGN KEY (GH_CUENTA_FACTURACION_IDCUENTA)
      REFERENCES GH_CUENTA_FACTURACION (GH_CUENTA_FACTURACION_IDCUENTA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE FIPAG_PAGO ADD CONSTRAINT FK_R110_PAGOS FOREIGN KEY (FIFAC_FACTU_IDFACTURA)
      REFERENCES FIFAC_FACTU (FIFAC_FACTU_IDFACTURA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE FIPAG_PAGO ADD CONSTRAINT FK_R111_MEDIO FOREIGN KEY (FIFOR_FORMA_IDFORMAPAGO)
      REFERENCES FIFOR_FORMA (FIFOR_FORMA_IDFORMAPAGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE FITAR_TARIF ADD CONSTRAINT FK_R105_TARIFAS FOREIGN KEY (FISER_SERVIC_IDSERVICIO)
      REFERENCES FISER_SERVIC (FISER_SERVIC_IDSERVICIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHADM_ADMIS ADD CONSTRAINT FK_R036_ADMISIONES FOREIGN KEY (GEPAC_PACIE_IDPACIENTE)
      REFERENCES GEPAC_PACIE (GEPAC_PACIE_IDPACIENTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHADM_ADMIS ADD CONSTRAINT FK_R037_RESPONSABLEINGRESO FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHADM_ADMIS ADD CONSTRAINT FK_R038_SERVICIOINGRESO FOREIGN KEY (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO)
      REFERENCES GH_SERVICIO_HOSPITALARIO (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHADM_ADMIS ADD CONSTRAINT FK_R052_EGRESO FOREIGN KEY (GH_EGRESO_ADMINISTRATIVO_IDEGRESO)
      REFERENCES GH_EGRESO_ADMINISTRATIVO (GH_EGRESO_ADMINISTRATIVO_IDEGRESO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHAGE_AGEND ADD CONSTRAINT FK_R006_AGENDAS FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHAGE_AGEND ADD CONSTRAINT FK_R007_ESPECIALIDAD FOREIGN KEY (GHESP_ESPEC_IDESPECIALIDAD)
      REFERENCES GHESP_ESPEC (GHESP_ESPEC_IDESPECIALIDAD) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHAGE_AGEND ADD CONSTRAINT FK_R008_SERVICIO FOREIGN KEY (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO)
      REFERENCES GH_SERVICIO_HOSPITALARIO (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHALE_ALERG ADD CONSTRAINT FK_R025_ALERGIAS FOREIGN KEY (GEPAC_PACIE_IDPACIENTE)
      REFERENCES GEPAC_PACIE (GEPAC_PACIE_IDPACIENTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHALE_ALERG ADD CONSTRAINT FK_R026_REGISTRAALERGIA FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHASI_ASIGN ADD CONSTRAINT FK_R042_OCUPACIONES FOREIGN KEY (GHADM_ADMIS_IDADMISION)
      REFERENCES GHADM_ADMIS (GHADM_ADMIS_IDADMISION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHASI_ASIGN ADD CONSTRAINT FK_R043_ASIGNACIONES FOREIGN KEY (GHCAM_CAMA_IDCAMA)
      REFERENCES GHCAM_CAMA (GHCAM_CAMA_IDCAMA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHCAM_CAMA ADD CONSTRAINT FK_R040_CAMAS FOREIGN KEY (GH_HABITACION_IDHABITACION)
      REFERENCES GH_HABITACION (GH_HABITACION_IDHABITACION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHCIT_CITA ADD CONSTRAINT FK_R010_RESERVAS FOREIGN KEY (GH_TURNO_AGENDA_IDTURNO)
      REFERENCES GH_TURNO_AGENDA (GH_TURNO_AGENDA_IDTURNO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHCIT_CITA ADD CONSTRAINT FK_R011_CITAS FOREIGN KEY (GEPAC_PACIE_IDPACIENTE)
      REFERENCES GEPAC_PACIE (GEPAC_PACIE_IDPACIENTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHCIT_CITA ADD CONSTRAINT FK_R016_ORIGINA FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHDIA_DIAGN ADD CONSTRAINT FK_R022_DIAGNOSTICOS FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHDIA_DIAGN ADD CONSTRAINT FK_R023_DOCUMENTA FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHDIA_DIAGN ADD CONSTRAINT FK_R024_CLASIFICA FOREIGN KEY (GH_CATALOGO_DIAGNOSTICO_IDCONCEPTODIAGNOSTICO)
      REFERENCES GH_CATALOGO_DIAGNOSTICO (GH_CATALOGO_DIAGNOSTICO_IDCONCEPTODIAGNOSTICO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHEPI_EPISO ADD CONSTRAINT FK_R013_EPISODIOS FOREIGN KEY (GEPAC_PACIE_IDPACIENTE)
      REFERENCES GEPAC_PACIE (GEPAC_PACIE_IDPACIENTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHEPI_EPISO ADD CONSTRAINT FK_R014_RESPONSABLE FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHEPI_EPISO ADD CONSTRAINT FK_R015_ATENCIONES FOREIGN KEY (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO)
      REFERENCES GH_SERVICIO_HOSPITALARIO (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHEPI_EPISO ADD CONSTRAINT FK_R016_ORIGINA2 FOREIGN KEY (GHCIT_CITA_IDCITA)
      REFERENCES GHCIT_CITA (GHCIT_CITA_IDCITA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHEPI_EPISO ADD CONSTRAINT FK_R017_CONTEXTOINGRESO FOREIGN KEY (GHADM_ADMIS_IDADMISION)
      REFERENCES GHADM_ADMIS (GHADM_ADMIS_IDADMISION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHEPI_EPISO ADD CONSTRAINT FK_R018_ORIGINAEMERGENCIA2 FOREIGN KEY (GH_ATENCION_EMERGENCIA_IDEMERGENCIA)
      REFERENCES GH_ATENCION_EMERGENCIA (GH_ATENCION_EMERGENCIA_IDEMERGENCIA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHEST_ESTUD ADD CONSTRAINT FK_R086_ESTUDIOS FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHEST_ESTUD ADD CONSTRAINT FK_R087_SOLICITANTEIMAGEN FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHLOT_LOTE ADD CONSTRAINT FK_R063_LOTES FOREIGN KEY (GHMED_MEDIC_IDMEDICAMENTO)
      REFERENCES GHMED_MEDIC (GHMED_MEDIC_IDMEDICAMENTO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHMOV_MOVIM ADD CONSTRAINT FK_R067_MOVIMIENTOS FOREIGN KEY (GHMED_MEDIC_IDMEDICAMENTO)
      REFERENCES GHMED_MEDIC (GHMED_MEDIC_IDMEDICAMENTO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHMOV_MOVIM ADD CONSTRAINT FK_R068_LOTEMOVIDO FOREIGN KEY (GHLOT_LOTE_IDLOTE)
      REFERENCES GHLOT_LOTE (GHLOT_LOTE_IDLOTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHMOV_MOVIM ADD CONSTRAINT FK_R069_ORIGEN FOREIGN KEY (GH_UBICACION_INVENTARIO_IDUBICACION)
      REFERENCES GH_UBICACION_INVENTARIO (GH_UBICACION_INVENTARIO_IDUBICACION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHMOV_MOVIM ADD CONSTRAINT FK_R070_DESTINO FOREIGN KEY (GH__GH_UBICACION_INVENTARIO_IDUBICACION)
      REFERENCES GH_UBICACION_INVENTARIO (GH_UBICACION_INVENTARIO_IDUBICACION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHMOV_MOVIM ADD CONSTRAINT FK_R071_SALIDADISPENSACION2 FOREIGN KEY (GH_DETALLE_DISPENSACION_IDDETALLEDISPENSACION)
      REFERENCES GH_DETALLE_DISPENSACION (GH_DETALLE_DISPENSACION_IDDETALLEDISPENSACION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHNOT_NOTAC ADD CONSTRAINT FK_R019_NOTAS FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHNOT_NOTAC ADD CONSTRAINT FK_R020_AUTOR FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHNOT_NOTAC ADD CONSTRAINT FK_R021_RECTIFICACIONES FOREIGN KEY (GHN_GHNOT_NOTAC_IDNOTA)
      REFERENCES GHNOT_NOTAC (GHNOT_NOTAC_IDNOTA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHPRES_PRESC ADD CONSTRAINT FK_R054_PRESCRIPCIONES FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHPRES_PRESC ADD CONSTRAINT FK_R055_PRESCRIPTOR FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHPRQ_PROCQ ADD CONSTRAINT FK_R092_CIRUGIAS FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHPRQ_PROCQ ADD CONSTRAINT FK_R093_RESPONSABLECIRUGIA FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHRES_RESUL ADD CONSTRAINT FK_R081_RESULTADOS FOREIGN KEY (GH_ITEM_SOLICITUD_LAB_IDITEMSOLICITUD)
      REFERENCES GH_ITEM_SOLICITUD_LAB (GH_ITEM_SOLICITUD_LAB_IDITEMSOLICITUD) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHRES_RESUL ADD CONSTRAINT FK_R082_PARAMETRO FOREIGN KEY (GH_PARAMETRO_EXAMEN_IDPARAMETRO)
      REFERENCES GH_PARAMETRO_EXAMEN (GH_PARAMETRO_EXAMEN_IDPARAMETRO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHRES_RESUL ADD CONSTRAINT FK_R083_MUESTRAANALIZADA FOREIGN KEY (GH_MUESTRA_LABORATORIO_IDMUESTRA)
      REFERENCES GH_MUESTRA_LABORATORIO (GH_MUESTRA_LABORATORIO_IDMUESTRA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHSOL_SOLIC ADD CONSTRAINT FK_R074_SOLICITUDES FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GHSOL_SOLIC ADD CONSTRAINT FK_R075_SOLICITANTELAB FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_AJUSTE_FINANCIERO ADD CONSTRAINT FK_R112_DOCUMENTOORIGINAL FOREIGN KEY (FIFAC_FACTU_IDFACTURA)
      REFERENCES FIFAC_FACTU (FIFAC_FACTU_IDFACTURA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_AJUSTE_FINANCIERO ADD CONSTRAINT FK_R113_PAGOORIGINAL FOREIGN KEY (FIPAG_PAGO_IDPAGO)
      REFERENCES FIPAG_PAGO (FIPAG_PAGO_IDPAGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_ALTA_MEDICA ADD CONSTRAINT FK_R049_ALTAS FOREIGN KEY (GHADM_ADMIS_IDADMISION)
      REFERENCES GHADM_ADMIS (GHADM_ADMIS_IDADMISION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_ALTA_MEDICA ADD CONSTRAINT FK_R050_DOCUMENTAALTA FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_ALTA_MEDICA ADD CONSTRAINT FK_R051_AUTORIZAALTA FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_ALTA_MEDICA ADD CONSTRAINT FK_R053_HABILITAEGRESO FOREIGN KEY (GH_EGRESO_ADMINISTRATIVO_IDEGRESO)
      REFERENCES GH_EGRESO_ADMINISTRATIVO (GH_EGRESO_ADMINISTRATIVO_IDEGRESO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_ATENCION_EMERGENCIA ADD CONSTRAINT FK_R018_ORIGINAEMERGENCIA FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_ATENCION_EMERGENCIA ADD CONSTRAINT FK_R031_EMERGENCIAS FOREIGN KEY (GEPAC_PACIE_IDPACIENTE)
      REFERENCES GEPAC_PACIE (GEPAC_PACIE_IDPACIENTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_CAMBIO_CATALOGO ADD CONSTRAINT FK_R115_HISTORIALCONFIGURACION FOREIGN KEY (GH_VALOR_CATALOGO_IDVALOR)
      REFERENCES GH_VALOR_CATALOGO (GH_VALOR_CATALOGO_IDVALOR) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_CONTACTO_PACIENTE ADD CONSTRAINT FK_R001_CONTACTOS FOREIGN KEY (GEPAC_PACIE_IDPACIENTE)
      REFERENCES GEPAC_PACIE (GEPAC_PACIE_IDPACIENTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_CONTROL_PREOPERATORIO ADD CONSTRAINT FK_R098_VERIFICACIONES FOREIGN KEY (GHPRQ_PROCQ_IDPROCEDIMIENTO)
      REFERENCES GHPRQ_PROCQ (GHPRQ_PROCQ_IDPROCEDIMIENTO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_CONTROL_PREOPERATORIO ADD CONSTRAINT FK_R099_COMPLETACONTROL FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_CUENTA_FACTURACION ADD CONSTRAINT FK_R102_CUENTAS FOREIGN KEY (GEPAC_PACIE_IDPACIENTE)
      REFERENCES GEPAC_PACIE (GEPAC_PACIE_IDPACIENTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_CUENTA_FACTURACION ADD CONSTRAINT FK_R103_CUENTAEPISODIO FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DETALLE_DISPENSACION ADD CONSTRAINT FK_R059_DETALLES FOREIGN KEY (GH_DISPENSACION_IDDISPENSACION)
      REFERENCES GH_DISPENSACION (GH_DISPENSACION_IDDISPENSACION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DETALLE_DISPENSACION ADD CONSTRAINT FK_R060_ENTREGADO FOREIGN KEY (GH_ITEM_PRESCRIPCION_IDITEMPRESCRIPCION)
      REFERENCES GH_ITEM_PRESCRIPCION (GH_ITEM_PRESCRIPCION_IDITEMPRESCRIPCION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DETALLE_DISPENSACION ADD CONSTRAINT FK_R061_LOTEENTREGADO FOREIGN KEY (GHLOT_LOTE_IDLOTE)
      REFERENCES GHLOT_LOTE (GHLOT_LOTE_IDLOTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DETALLE_DISPENSACION ADD CONSTRAINT FK_R071_SALIDADISPENSACION FOREIGN KEY (GHMOV_MOVIM_IDMOVIMIENTO)
      REFERENCES GHMOV_MOVIM (GHMOV_MOVIM_IDMOVIMIENTO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DETALLE_FACTURA ADD CONSTRAINT FK_R108_LINEAS FOREIGN KEY (FIFAC_FACTU_IDFACTURA)
      REFERENCES FIFAC_FACTU (FIFAC_FACTU_IDFACTURA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DETALLE_FACTURA ADD CONSTRAINT FK_R109_CARGOFACTURADO FOREIGN KEY (FICAR_CARGO_IDCARGO)
      REFERENCES FICAR_CARGO (FICAR_CARGO_IDCARGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DISPENSACION ADD CONSTRAINT FK_R058_ENTREGAS FOREIGN KEY (GHPRES_PRESC_IDPRESCRIPCION)
      REFERENCES GHPRES_PRESC (GHPRES_PRESC_IDPRESCRIPCION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DISPENSACION ADD CONSTRAINT FK_R062_FARMACIAORIGEN FOREIGN KEY (GH_UBICACION_INVENTARIO_IDUBICACION)
      REFERENCES GH_UBICACION_INVENTARIO (GH_UBICACION_INVENTARIO_IDUBICACION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DISPOSICION_EMERGENCIA ADD CONSTRAINT FK_R034_DISPOSICIONES FOREIGN KEY (GH_ATENCION_EMERGENCIA_IDEMERGENCIA)
      REFERENCES GH_ATENCION_EMERGENCIA (GH_ATENCION_EMERGENCIA_IDEMERGENCIA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DISPOSICION_EMERGENCIA ADD CONSTRAINT FK_R035_DECIDEDISPOSICION FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DOCUMENTO_CLINICO ADD CONSTRAINT FK_R027_DOCUMENTOS FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_DOCUMENTO_CLINICO ADD CONSTRAINT FK_R091_IMAGENESYDOCUMENTOS FOREIGN KEY (GHEST_ESTUD_IDESTUDIO)
      REFERENCES GHEST_ESTUD (GHEST_ESTUD_IDESTUDIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_EGRESO_ADMINISTRATIVO ADD CONSTRAINT FK_R052_EGRESO2 FOREIGN KEY (GHADM_ADMIS_IDADMISION)
      REFERENCES GHADM_ADMIS (GHADM_ADMIS_IDADMISION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_EGRESO_ADMINISTRATIVO ADD CONSTRAINT FK_R053_HABILITAEGRESO2 FOREIGN KEY (GH_ALTA_MEDICA_IDALTAMEDICA)
      REFERENCES GH_ALTA_MEDICA (GH_ALTA_MEDICA_IDALTAMEDICA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_EXISTENCIA ADD CONSTRAINT FK_R064_EXISTENCIAS FOREIGN KEY (GHMED_MEDIC_IDMEDICAMENTO)
      REFERENCES GHMED_MEDIC (GHMED_MEDIC_IDMEDICAMENTO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_EXISTENCIA ADD CONSTRAINT FK_R065_UBICADO FOREIGN KEY (GH_UBICACION_INVENTARIO_IDUBICACION)
      REFERENCES GH_UBICACION_INVENTARIO (GH_UBICACION_INVENTARIO_IDUBICACION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_EXISTENCIA ADD CONSTRAINT FK_R066_PORLOTE FOREIGN KEY (GHLOT_LOTE_IDLOTE)
      REFERENCES GHLOT_LOTE (GHLOT_LOTE_IDLOTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_HABILITACION_PROFESIONAL ADD CONSTRAINT FK_R004_HABILITACIONES FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_HABILITACION_PROFESIONAL ADD CONSTRAINT FK_R005_ESPECIALIZA FOREIGN KEY (GHESP_ESPEC_IDESPECIALIDAD)
      REFERENCES GHESP_ESPEC (GHESP_ESPEC_IDESPECIALIDAD) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_HABITACION ADD CONSTRAINT FK_R039_HABITACIONES FOREIGN KEY (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO)
      REFERENCES GH_SERVICIO_HOSPITALARIO (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_HISTORIAL_CITA ADD CONSTRAINT FK_R012_CAMBIOS FOREIGN KEY (GHCIT_CITA_IDCITA)
      REFERENCES GHCIT_CITA (GHCIT_CITA_IDCITA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_HISTORIAL_ESTADO_CAMA ADD CONSTRAINT FK_R041_ESTADOS FOREIGN KEY (GHCAM_CAMA_IDCAMA)
      REFERENCES GHCAM_CAMA (GHCAM_CAMA_IDCAMA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_INFORME_IMAGEN ADD CONSTRAINT FK_R088_INFORMES FOREIGN KEY (GHEST_ESTUD_IDESTUDIO)
      REFERENCES GHEST_ESTUD (GHEST_ESTUD_IDESTUDIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_INFORME_IMAGEN ADD CONSTRAINT FK_R089_AUTORINFORME FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_INFORME_IMAGEN ADD CONSTRAINT FK_R090_VALIDADORIMAGEN FOREIGN KEY (GHP_GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_ITEM_PRESCRIPCION ADD CONSTRAINT FK_R056_ITEMS FOREIGN KEY (GHPRES_PRESC_IDPRESCRIPCION)
      REFERENCES GHPRES_PRESC (GHPRES_PRESC_IDPRESCRIPCION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_ITEM_PRESCRIPCION ADD CONSTRAINT FK_R057_MEDICAMENTOINDICADO FOREIGN KEY (GHMED_MEDIC_IDMEDICAMENTO)
      REFERENCES GHMED_MEDIC (GHMED_MEDIC_IDMEDICAMENTO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_ITEM_SOLICITUD_LAB ADD CONSTRAINT FK_R076_EXAMENES FOREIGN KEY (GHSOL_SOLIC_IDSOLICITUD)
      REFERENCES GHSOL_SOLIC (GHSOL_SOLIC_IDSOLICITUD) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_ITEM_SOLICITUD_LAB ADD CONSTRAINT FK_R077_TIPOEXAMEN FOREIGN KEY (GH_EXAMEN_LABORATORIO_IDEXAMEN)
      REFERENCES GH_EXAMEN_LABORATORIO (GH_EXAMEN_LABORATORIO_IDEXAMEN) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_MEDICION_SIGNO ADD CONSTRAINT FK_R030_MEDICIONES FOREIGN KEY (GH_REGISTRO_ENFERMERIA_IDREGISTROENFERMERIA)
      REFERENCES GH_REGISTRO_ENFERMERIA (GH_REGISTRO_ENFERMERIA_IDREGISTROENFERMERIA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_MUESTRA_LABORATORIO ADD CONSTRAINT FK_R079_MUESTRAS FOREIGN KEY (GEPAC_PACIE_IDPACIENTE)
      REFERENCES GEPAC_PACIE (GEPAC_PACIE_IDPACIENTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_PARAMETRO_EXAMEN ADD CONSTRAINT FK_R078_PARAMETROS FOREIGN KEY (GH_EXAMEN_LABORATORIO_IDEXAMEN)
      REFERENCES GH_EXAMEN_LABORATORIO (GH_EXAMEN_LABORATORIO_IDEXAMEN) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_PARTICIPACION_QUIRURGICA ADD CONSTRAINT FK_R096_EQUIPO FOREIGN KEY (GHPRQ_PROCQ_IDPROCEDIMIENTO)
      REFERENCES GHPRQ_PROCQ (GHPRQ_PROCQ_IDPROCEDIMIENTO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_PARTICIPACION_QUIRURGICA ADD CONSTRAINT FK_R097_INTEGRANTE FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_POLITICA_STOCK ADD CONSTRAINT FK_R072_MINIMOS FOREIGN KEY (GHMED_MEDIC_IDMEDICAMENTO)
      REFERENCES GHMED_MEDIC (GHMED_MEDIC_IDMEDICAMENTO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_POLITICA_STOCK ADD CONSTRAINT FK_R073_UMBRALUBICACION FOREIGN KEY (GH_UBICACION_INVENTARIO_IDUBICACION)
      REFERENCES GH_UBICACION_INVENTARIO (GH_UBICACION_INVENTARIO_IDUBICACION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_REGISTRO_ENFERMERIA ADD CONSTRAINT FK_R028_CUIDADOS FOREIGN KEY (GHEPI_EPISO_IDEPISODIO)
      REFERENCES GHEPI_EPISO (GHEPI_EPISO_IDEPISODIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_REGISTRO_ENFERMERIA ADD CONSTRAINT FK_R029_PERSONALENFERMERIA FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_REGISTRO_RECUPERACION ADD CONSTRAINT FK_R100_RECUPERACION FOREIGN KEY (GHPRQ_PROCQ_IDPROCEDIMIENTO)
      REFERENCES GHPRQ_PROCQ (GHPRQ_PROCQ_IDPROCEDIMIENTO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_REGISTRO_RECUPERACION ADD CONSTRAINT FK_R101_DOCUMENTARECUPERACION FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_RESERVA_RECURSO ADD CONSTRAINT FK_R094_RESERVASRECURSOS FOREIGN KEY (GHPRQ_PROCQ_IDPROCEDIMIENTO)
      REFERENCES GHPRQ_PROCQ (GHPRQ_PROCQ_IDPROCEDIMIENTO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_RESERVA_RECURSO ADD CONSTRAINT FK_R095_RECURSO FOREIGN KEY (GH_RECURSO_QUIRURGICO_IDRECURSO)
      REFERENCES GH_RECURSO_QUIRURGICO (GH_RECURSO_QUIRURGICO_IDRECURSO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_REVISION_IDENTIDAD ADD CONSTRAINT FK_R002_ORIGEN FOREIGN KEY (GEPAC_PACIE_IDPACIENTE)
      REFERENCES GEPAC_PACIE (GEPAC_PACIE_IDPACIENTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_REVISION_IDENTIDAD ADD CONSTRAINT FK_R003_DESTINO FOREIGN KEY (GEP_GEPAC_PACIE_IDPACIENTE)
      REFERENCES GEPAC_PACIE (GEPAC_PACIE_IDPACIENTE) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_TRASLADO_HOSPITALARIO ADD CONSTRAINT FK_R044_TRASLADOS FOREIGN KEY (GHADM_ADMIS_IDADMISION)
      REFERENCES GHADM_ADMIS (GHADM_ADMIS_IDADMISION) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_TRASLADO_HOSPITALARIO ADD CONSTRAINT FK_R045_SERVICIOORIGEN FOREIGN KEY (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO)
      REFERENCES GH_SERVICIO_HOSPITALARIO (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_TRASLADO_HOSPITALARIO ADD CONSTRAINT FK_R046_SERVICIODESTINO FOREIGN KEY (GH__GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO)
      REFERENCES GH_SERVICIO_HOSPITALARIO (GH_SERVICIO_HOSPITALARIO_IDSERVICIOHOSPITALARIO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_TRASLADO_HOSPITALARIO ADD CONSTRAINT FK_R047_CAMAORIGEN FOREIGN KEY (GHCAM_CAMA_IDCAMA)
      REFERENCES GHCAM_CAMA (GHCAM_CAMA_IDCAMA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_TRASLADO_HOSPITALARIO ADD CONSTRAINT FK_R048_CAMADESTINO FOREIGN KEY (GHC_GHCAM_CAMA_IDCAMA)
      REFERENCES GHCAM_CAMA (GHCAM_CAMA_IDCAMA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_TRIAJE ADD CONSTRAINT FK_R032_EVALUACIONES FOREIGN KEY (GH_ATENCION_EMERGENCIA_IDEMERGENCIA)
      REFERENCES GH_ATENCION_EMERGENCIA (GH_ATENCION_EMERGENCIA_IDEMERGENCIA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_TRIAJE ADD CONSTRAINT FK_R033_CLASIFICAPRIORIDAD FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_TURNO_AGENDA ADD CONSTRAINT FK_R009_TURNOS FOREIGN KEY (GHAGE_AGEND_IDAGENDA)
      REFERENCES GHAGE_AGEND (GHAGE_AGEND_IDAGENDA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_VALIDACION_RESULTADO ADD CONSTRAINT FK_R084_VALIDACIONES FOREIGN KEY (GHRES_RESUL_IDRESULTADO)
      REFERENCES GHRES_RESUL (GHRES_RESUL_IDRESULTADO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_VALIDACION_RESULTADO ADD CONSTRAINT FK_R085_VALIDADORLAB FOREIGN KEY (GHPRO_PROFE_IDPROFESIONAL)
      REFERENCES GHPRO_PROFE (GHPRO_PROFE_IDPROFESIONAL) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE GH_VALOR_CATALOGO ADD CONSTRAINT FK_R114_VALORES FOREIGN KEY (GH_CATALOGO_IDCATALOGO)
      REFERENCES GH_CATALOGO (GH_CATALOGO_IDCATALOGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE PECAR_CARGO ADD CONSTRAINT FK_PR_PEDEP_PECAR FOREIGN KEY (PEDEP_CODIGO)
      REFERENCES PEDEP_DEPAR (PEDEP_CODIGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE PEPER_PERSO ADD CONSTRAINT FK_PR_PEESC_PEPER FOREIGN KEY (PEESC_CODIGO)
      REFERENCES PEESC_ESTCIV (PEESC_CODIGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE PEPER_PERSO ADD CONSTRAINT FK_PR_PEGEN_PEPER FOREIGN KEY (PEGEN_CODIGO)
      REFERENCES PEGEN_GENERO (PEGEN_CODIGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE R080_PROCESAMUESTRA ADD CONSTRAINT FK_R080_PROCESAMUESTRA FOREIGN KEY (GH_ITEM_SOLICITUD_LAB_IDITEMSOLICITUD)
      REFERENCES GH_ITEM_SOLICITUD_LAB (GH_ITEM_SOLICITUD_LAB_IDITEMSOLICITUD) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE R080_PROCESAMUESTRA ADD CONSTRAINT FK_R080_PROCESAMUESTRA2 FOREIGN KEY (GH_MUESTRA_LABORATORIO_IDMUESTRA)
      REFERENCES GH_MUESTRA_LABORATORIO (GH_MUESTRA_LABORATORIO_IDMUESTRA) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE XEOPC_OPCIO ADD CONSTRAINT FK_XR_XESIS_XEOPC FOREIGN KEY (XESIS_CODIGO)
      REFERENCES XESIS_SISTE (XESIS_CODIGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE XEOXP_OPCPE ADD CONSTRAINT FK_XR_XEOPC_XEOXP FOREIGN KEY (XEOPC_CODIGO)
      REFERENCES XEOPC_OPCIO (XEOPC_CODIGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE XEOXP_OPCPE ADD CONSTRAINT FK_XR_XEPER_XEOXP FOREIGN KEY (XEPER_CODIGO)
      REFERENCES XEPER_PERFI (XEPER_CODIGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE XEUSU_USUAR ADD CONSTRAINT FK_XR_PEPER_XEUSU FOREIGN KEY (PEPER_CODIGO)
      REFERENCES PEPER_PERSO (PEPER_CODIGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE XEUSU_USUAR ADD CONSTRAINT FK_XR_XEEST_XEUSU FOREIGN KEY (XEEST_CODIGO)
      REFERENCES XEEST_ESTAD (XEEST_CODIGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE XEUXP_USUPE ADD CONSTRAINT FK_XR_XEPER_XEUXP FOREIGN KEY (XEPER_CODIGO)
      REFERENCES XEPER_PERFI (XEPER_CODIGO) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE XEUXP_USUPE ADD CONSTRAINT FK_XR_XEUSU_XEUXP FOREIGN KEY (XEUSU_PASWD)
      REFERENCES XEUSU_USUAR (XEUSU_PASWD) ON DELETE RESTRICT ON UPDATE RESTRICT;

