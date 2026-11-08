using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;

namespace Utils
{
    public static class Seguridad
    {
        // Convierte un texto (la contraseña) en su versión encriptada con SHA-256
        public static string Encriptar(string texto)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(texto));

                StringBuilder resultado = new StringBuilder();
                foreach (byte b in bytes)
                {
                    resultado.Append(b.ToString("x2"));
                }
                return resultado.ToString();
            }
        }
    }
}