namespace WebConMVCDotnet.Models
{
    /// <summary>
    /// Fila de la subtabla de Datos Académicos de un empleado
    /// (tabla PEACA_ACADE del esquema de Personal).
    ///
    /// Una fila representa un estudio: nivel, institución y título.
    /// </summary>
    public class EmpleadoAcademico
    {
        /// <summary>Código generado por la base (PEACA_CODIGO). Solo lectura.</summary>
        public int CodigoAcademico { get; set; }
        /// <summary>Nivel de estudio (PEACA_NIVEL).</summary>
        public string Nivel { get; set; }
        /// <summary>Institución educativa (PEACA_INSTI).</summary>
        public string Institucion { get; set; }
        /// <summary>Título obtenido (PEACA_TITUL).</summary>
        public string Titulo { get; set; }

        public EmpleadoAcademico()
        {
            Nivel = string.Empty;
            Institucion = string.Empty;
            Titulo = string.Empty;
        }

        public EmpleadoAcademico(string nivel, string institucion, string titulo)
        {
            Nivel = nivel ?? string.Empty;
            Institucion = institucion ?? string.Empty;
            Titulo = titulo ?? string.Empty;
        }
    }
}
