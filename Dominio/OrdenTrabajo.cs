using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class OrdenTrabajo
    {
        public int IDOrdenTrabajo { get; set; }
        public string Estado { get; set; }
        public decimal PresupuestoTotal { get; set; }
        public int TiempoEstimadoTotal { get; set; }   // en minutos
    }
}
