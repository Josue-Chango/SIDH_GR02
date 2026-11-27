namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Modelo de la entidad CARGO (tabla PECAR_CARGO del diagrama de Personal).
    ///
    /// La clave primaria es compuesta: (PEDEP_CODIGO, PECAR_CODIGO).
    /// Por ejemplo, SIS/ADM y CON/ADM son dos cargos diferentes.
    /// </summary>
    public class Cargo
    {
        public string CodigoDepart { get; set; }
        public string CodigoCargo { get; set; }
        public string DescriCargo { get; set; }
        /// <summary>Descripción del departamento asociado, para mostrarla en pantalla.</summary>
        public string DescriDepart { get; set; }

        public Cargo()
        {
            CodigoDepart = string.Empty;
            CodigoCargo = string.Empty;
            DescriCargo = string.Empty;
            DescriDepart = string.Empty;
        }

        public Cargo(string codigoDepart, string codigoCargo, string descriCargo)
        {
            CodigoDepart = codigoDepart ?? string.Empty;
            CodigoCargo = codigoCargo ?? string.Empty;
            DescriCargo = descriCargo ?? string.Empty;
            DescriDepart = string.Empty;
        }
    }
}
