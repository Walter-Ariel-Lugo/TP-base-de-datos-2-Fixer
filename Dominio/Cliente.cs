using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class Cliente : Usuario
    {
        public int CantidadOrdenes { get; set; }
        public decimal TotalContratado { get; set; }
    }
}
