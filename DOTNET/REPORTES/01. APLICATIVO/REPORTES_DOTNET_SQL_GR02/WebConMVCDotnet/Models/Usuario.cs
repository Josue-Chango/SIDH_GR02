using System;
using System.Collections.Generic;

namespace WebConMVCDotnet.Models
{
    public class Usuario
    {
        public string Password { get; set; }
        public string CodEstado { get; set; }
        public string DescEstado { get; set; }
        public DateTime? FechaCrea { get; set; }
        public DateTime? FechaModi { get; set; }
        public string Piefirma { get; set; }
        public Persona Persona { get; set; }
        public List<Perfil> Perfiles { get; set; }

        /// <summary>Activo solo si el estado no es inactivo/bloqueado/suspendido/retirado.</summary>
        public bool Activo
        {
            get
            {
                string estado = DescEstado == null ? "" : DescEstado.ToUpperInvariant();
                return !(estado.Contains("INACTIVO") || estado.Contains("BLOQUEADO")
                         || estado.Contains("SUSPENDIDO") || estado.Contains("RETIRADO"));
            }
        }
    }
}
