using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Servicio
{
    public class AccesoDatos
    {
        private SqlConnection conexion;
        private SqlCommand comando;
        private SqlDataReader lector;

        // Permite leer los resultados desde afuera de la clase
        public SqlDataReader Lector
        {
            get { return lector; }
        }

        // Constructor: prepara la conexión con los datos del Web.config
        public AccesoDatos()
        {
            string cadena = ConfigurationManager.ConnectionStrings["FixerDB"].ConnectionString;
            conexion = new SqlConnection(cadena);
            comando = new SqlCommand();
            comando.Connection = conexion;
        }

        // Indica la consulta SQL a ejecutar
        public void SetConsulta(string consulta)
        {
            comando.CommandType = CommandType.Text;
            comando.CommandText = consulta;
        }

        // Agrega un parámetro. Si el valor es null, manda NULL a SQL
        public void SetParametro(string nombre, object valor)
        {
            comando.Parameters.AddWithValue(nombre, valor ?? DBNull.Value);
        }
        // Para llamar a un stored procedure por su nombre
        public void SetProcedimiento(string nombre)
        {
            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = nombre;
        }

        // INSERT, UPDATE, DELETE o un SP que modifica datos
        public int EjecutarAccion()
        {
            conexion.Open();
            return comando.ExecuteNonQuery();
        }

        // Consulta que devuelve un solo valor (un COUNT o el ID de una orden nueva)
        public object EjecutarEscalar()
        {
            conexion.Open();
            return comando.ExecuteScalar();
        }

        // Ejecuta un SELECT que devuelve filas
        public void EjecutarLectura()
        {
            conexion.Open();
            lector = comando.ExecuteReader();
        }

        // Cierra el lector y la conexión. Se llama siempre al terminar
        public void CerrarConexion()
        {
            if (lector != null)
                lector.Close();
            conexion.Close();
        }
    }
}