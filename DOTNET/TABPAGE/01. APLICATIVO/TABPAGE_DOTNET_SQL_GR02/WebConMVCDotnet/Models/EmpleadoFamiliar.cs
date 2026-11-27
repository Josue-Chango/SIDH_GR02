using System;

namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Fila de la subtabla de Datos Familiares de un empleado
    /// (tabla PEFAM_FAMIL del esquema de Personal).
    ///
    /// Una fila representa un familiar: parentesco (persona),
    /// apellidos y nombres, y fecha de nacimiento.
    /// </summary>
    public class EmpleadoFamiliar
    {
        /// <summary>Código generado por la base (PEFAM_CODIGO). Solo lectura.</summary>
        public int CodigoFamiliar { get; set; }
        /// <summary>Parentesco o persona (PEFAM_PAREN): PADRE, MADRE, CONYUGE...</summary>
        public string Persona { get; set; }
        /// <summary>Apellidos y nombres del familiar (PEFAM_NOMBRE).</summary>
        public string Nombres { get; set; }
        /// <summary>Fecha de nacimiento del familiar (PEFAM_FECNAC).</summary>
        public DateTime? FechaNacimiento { get; set; }

        public EmpleadoFamiliar()
        {
            Persona = string.Empty;
            Nombres = string.Empty;
        }

        public EmpleadoFamiliar(string persona, string nombres, DateTime? fechaNacimiento)
        {
            Persona = persona ?? string.Empty;
            Nombres = nombres ?? string.Empty;
            FechaNacimiento = fechaNacimiento;
        }
    }
}
