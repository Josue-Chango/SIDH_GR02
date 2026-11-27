using System;
using System.Collections.Generic;

namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Empleado del esquema de Personal (tabla PEPER_PERSO del esquema de
    /// Seguridad, la misma que usa el módulo de login).
    ///
    /// Reúne la información de las tres pestañas del Tab Page:
    /// - Marco de la ficha: código (cédula), apellidos, nombres y foto.
    /// - Datos Generales: sexo, peso, estado civil y tipo de sangre.
    /// - Datos Académicos: subtabla PEACA_ACADE.
    /// - Datos Familiares: subtabla PEFAM_FAMIL.
    /// </summary>
    public class Empleado
    {
        /// <summary>Código del empleado: identificador de la persona (PEPER_CODIGO).</summary>
        public string Codigo { get; set; }
        /// <summary>Cédula de identidad (PEPER_CEDULA). Opcional en la tabla.</summary>
        public string Cedula { get; set; }
        /// <summary>Apellidos completos (PEPER_APELLI).</summary>
        public string Apellidos { get; set; }
        /// <summary>Nombres completos (PEPER_NOMBRE).</summary>
        public string Nombres { get; set; }
        /// <summary>Fecha de nacimiento (PEPER_FECNAC).</summary>
        public DateTime? FechaNacimiento { get; set; }
        /// <summary>Código de la pestaña Datos Generales: sexo (PEGEN_CODIGO).</summary>
        public string CodigoGenero { get; set; }
        /// <summary>Descripción del sexo (catálogo PEGEN_GENERO). Solo lectura.</summary>
        public string DescriGenero { get; set; }
        /// <summary>Código del estado civil (PEESC_CODIGO).</summary>
        public string CodigoEstadoCivil { get; set; }
        /// <summary>Descripción del estado civil (catálogo PEESC_ESTCIV). Solo lectura.</summary>
        public string DescriEstadoCivil { get; set; }
        /// <summary>Peso en kilogramos (PEPER_PESO). 0 significa sin dato.</summary>
        public double Peso { get; set; }
        /// <summary>Tipo de sangre (PEPER_TIPSANG): O+, A-, ...</summary>
        public string TipoSangre { get; set; }
        /// <summary>Cargas familiares (PEPER_CARFAM).</summary>
        public int CargasFam { get; set; }
        /// <summary>Ruta relativa de la foto bajo /resources (PEPER_FOTO).</summary>
        public string Foto { get; set; }
        /// <summary>Subtabla de Datos Académicos (PEACA_ACADE).</summary>
        public List<EmpleadoAcademico> Academicos { get; set; }
        /// <summary>Subtabla de Datos Familiares (PEFAM_FAMIL).</summary>
        public List<EmpleadoFamiliar> Familiares { get; set; }

        public Empleado()
        {
            Codigo = string.Empty;
            Cedula = string.Empty;
            Apellidos = string.Empty;
            Nombres = string.Empty;
            CodigoGenero = string.Empty;
            CodigoEstadoCivil = string.Empty;
            TipoSangre = string.Empty;
            Foto = string.Empty;
            Academicos = new List<EmpleadoAcademico>();
            Familiares = new List<EmpleadoFamiliar>();
        }

        /// <summary>Fecha de nacimiento en formato ISO (yyyy-MM-dd) para el input date.</summary>
        public string FechaNacimientoIso
        {
            get
            {
                return FechaNacimiento.HasValue
                    ? FechaNacimiento.Value.ToString("yyyy-MM-dd")
                    : string.Empty;
            }
        }
    }
}
