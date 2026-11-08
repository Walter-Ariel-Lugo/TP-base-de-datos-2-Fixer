using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class Usuario
    {
        public int IDUsuario { get; set; }
        public int Rol { get; set; }        // 1 = Administrador 2 = Cliente 3 = Técnico
        public string Nombre { get; set; }
        public string Mail { get; set; }
        public string Telefono { get; set; }
    }
}
