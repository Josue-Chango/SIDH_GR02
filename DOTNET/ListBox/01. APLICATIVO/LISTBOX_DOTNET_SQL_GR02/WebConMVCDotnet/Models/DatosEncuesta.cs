using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebConMVCDotnet.Models
{
    public class DatosEncuesta
    {
        public string nombre { get; set; }
        public string apellido { get; set; }
        
        public string foto { get; set; }
        public string[] progleng { get; set; }

    }
}