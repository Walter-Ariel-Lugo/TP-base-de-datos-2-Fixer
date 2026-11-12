using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{

    public class ServicioContratado
    {
        public int IDServicio { get; set; }
        public string Servicio { get; set; }
        public string Categoria { get; set; }
        public decimal Precio { get; set; }
        public int TiempoPromedio { get; set; }
        public int VecesContratado { get; set; }
    }
}