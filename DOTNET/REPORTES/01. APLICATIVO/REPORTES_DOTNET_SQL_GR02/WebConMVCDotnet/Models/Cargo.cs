namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Cargo del esquema de Personal (tabla PECAR_CARGO).
    /// Clave compuesta: departamento (PEDEP_CODIGO) + cargo (PECAR_CODIGO).
    /// Equivalente a la clase Cargo del proyecto Java.
    /// </summary>
    public class Cargo
    {
        public string CodigoDepart { get; set; }
        public string CodigoCargo { get; set; }
        public string DescriCargo { get; set; }

        /// <summary>Descripción del departamento (JOIN con PEDEP_DEPAR). Solo lectura.</summary>
        public string DescriDepart { get; set; }

        public Cargo()
        {
            CodigoDepart = string.Empty;
            CodigoCargo = string.Empty;
            DescriCargo = string.Empty;
            DescriDepart = string.Empty;
        }

        public Cargo(string departamento, string codigo, string descripcion)
        {
            CodigoDepart = departamento ?? string.Empty;
            CodigoCargo = codigo ?? string.Empty;
            DescriCargo = descripcion ?? string.Empty;
            DescriDepart = string.Empty;
        }
    }
}
