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
        public int IDCliente { get; set; }
        public string Cliente { get; set; }
        public int IDTecnico { get; set; }
        public string Tecnico { get; set; }
        public string Estado { get; set; }
        public DateTime FechaSolicitud { get; set; }
        public DateTime? FechaProgramada { get; set; }
        public DateTime? FechaFinalizacion { get; set; }
        public decimal PresupuestoTotal { get; set; }
        public int TiempoEstimadoTotal { get; set; }   // en minutos
        public string Telefono { get; set; }        // del cliente
        public string Direccion { get; set; }
        public string Observaciones { get; set; }

    }
}