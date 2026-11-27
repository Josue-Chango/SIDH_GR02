using System;

namespace WebConMVCDotnet.Models
{
    public class Persona
    {
        public string CodigoPersona { get; set; }
        public string ApellidosPersona { get; set; }
        public string NombresPersona { get; set; }
        public DateTime? FecNacimiento { get; set; }
        public string Cedula { get; set; }
        public string Pasaporte { get; set; }
        public string Email { get; set; }
        public double CargasFam { get; set; }
        public string Foto { get; set; }
        public string Discapacidad { get; set; }

        public string NombreCompleto
        {
            get
            {
                string nombres = NombresPersona ?? string.Empty;
                string apellidos = ApellidosPersona ?? string.Empty;
                return (nombres + " " + apellidos).Trim();
            }
        }
    }
}
