using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class Tecnico : Usuario
    {
        public bool Activo { get; set; }          // habilitado por el admin
        public bool Disponible { get; set; }      // el técnico acepta trabajos
        public int ServiciosActivos { get; set; } // cuántos servicios tiene activos
    }
}
