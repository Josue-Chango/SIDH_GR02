namespace WebConMVCDotnet.Models
{
    public class Departamento
    {
        public string CodigoDepart { get; set; }
        public string DescriDeparta { get; set; }

        public Departamento()
        {
            CodigoDepart = string.Empty;
            DescriDeparta = string.Empty;
        }

        public Departamento(string codigo, string descripcion)
        {
            CodigoDepart = codigo ?? string.Empty;
            DescriDeparta = descripcion ?? string.Empty;
        }
    }
}
