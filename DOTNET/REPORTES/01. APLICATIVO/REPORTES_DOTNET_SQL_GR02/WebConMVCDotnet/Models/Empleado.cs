using System;
using System.Collections.Generic;

namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Empleado del esquema de Personal (tabla PEPER_PERSO).
    /// Reúne la información de las tres pestañas del Tab Page:
    /// - Marco de la ficha: código de persona, apellidos, nombres y foto.
    /// - Datos Generales: sexo, peso, estado civil y tipo de sangre.
    /// - Datos Académicos: subtabla PEACA_ACADE.
    /// - Datos Familiares: subtabla PEFAM_FAMIL.
    /// Equivalente a la clase Empleado del proyecto Java.
    /// </summary>
    public class Empleado
    {
        /// <summary>Código de persona (PEPER_CODIGO, hasta 10 caracteres).</summary>
        public string Codigo { get; set; }

        /// <summary>Apellidos completos (PEPER_APELLI).</summary>
        public string Apellidos { get; set; }

        /// <summary>Nombres completos (PEPER_NOMBRE).</summary>
        public string Nombres { get; set; }

        /// <summary>Fecha de nacimiento (PEPER_FECNAC).</summary>
        public DateTime? FechaNacimiento { get; set; }

        /// <summary>Código del sexo (PEGEN_CODIGO).</summary>
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

        /// <summary>Ruta relativa de la foto bajo /resource (PEPER_FOTO).</summary>
        public string Foto { get; set; }

        /// <summary>Subtabla de Datos Académicos (PEACA_ACADE).</summary>
        public List<EmpleadoAcademico> Academicos { get; set; }

        /// <summary>Subtabla de Datos Familiares (PEFAM_FAMIL).</summary>
        public List<EmpleadoFamiliar> Familiares { get; set; }

        public Empleado()
        {
            Codigo = string.Empty;
            Apellidos = string.Empty;
            Nombres = string.Empty;
            CodigoGenero = string.Empty;
            DescriGenero = string.Empty;
            CodigoEstadoCivil = string.Empty;
            DescriEstadoCivil = string.Empty;
            TipoSangre = string.Empty;
            Foto = string.Empty;
            Academicos = new List<EmpleadoAcademico>();
            Familiares = new List<EmpleadoFamiliar>();
        }

        /// <summary>Nombre completo "APELLIDOS Nombres" para el marco de la ficha.</summary>
        public string NombreCompleto
        {
            get { return (Apellidos + " " + Nombres).Trim(); }
        }
    }
}
