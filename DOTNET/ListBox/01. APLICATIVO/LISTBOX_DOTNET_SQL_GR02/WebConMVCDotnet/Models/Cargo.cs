namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Modelo de la entidad CARGO (tabla PECAR_CARGO del diagrama de Personal).
    ///
    /// La tabla almacena el código del cargo (PECAR_CODIGO, CHAR(3)), su
    /// descripción (PECAR_DESCRI, VARCHAR(50)) y el código del departamento al
    /// que pertenece (PEDEP_CODIGO, CHAR(3), llave foránea hacia PEDEP_DEPAR).
    ///
    /// La clave primaria es compuesta: (PEDEP_CODIGO, PECAR_CODIGO).
    /// Equivalente a la clase Cargo del proyecto Java.
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
