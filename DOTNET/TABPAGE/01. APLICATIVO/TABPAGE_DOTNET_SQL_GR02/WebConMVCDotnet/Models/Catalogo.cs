namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Fila de un catálogo (por ejemplo PEGEN_GENERO o PEESC_ESTCIV):
    /// código corto y descripción para los combobox de las vistas.
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
