namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Fila de una tabla catálogo (PEGEN_GENERO, PEESC_ESTCIV).
    /// Equivalente a la clase Catalogo del proyecto Java.
    /// </summary>
    public class Catalogo
    {
        public string Codigo { get; set; }
        public string Descri { get; set; }

        public Catalogo()
        {
            Codigo = string.Empty;
            Descri = string.Empty;
        }

        public Catalogo(string codigo, string descri)
        {
            Codigo = codigo ?? string.Empty;
            Descri = descri ?? string.Empty;
        }
    }
}
