#!/usr/bin/env dmd 
/**
 * Aqui hay tipos de funciones
 * 	protected : funciones para esta misma clase
 * 	public : funciones que pueden usar cualquier codigo del proyecto
 */
module gestor_clientes;

import std;
import core.thread;
import core.stdc.string;
alias print = writeln;

void main () {

	Datos_clientes d_c = new Datos_clientes();



}

/**
 * Datos_clientes
 */
class Datos_clientes {

	long tamanio_actual;

	JSONValue clientes_cargados_formateado; 

	this() {
		
		this.clientes_cargados_formateado = parseJSON(readText("dir_data_clients/data_clients.json"));


	}




	public int[] fn_encontrar(string usuario, string contrasenia) {

        JSONValue c = clientes_cargados_formateado["clientes"].array;

        for (int i = 0; i < c.array.length; i++) {

        	//if ("barkacod457345465" in c[i]["usuario"]) {
        		print(c[i]["usuario"]);
        		if (c[i]["usuario"].str == usuario && c[i]["contrasenia"].str == contrasenia) {
        			print(true);
        			print(i);

        			return [true, i];
        		}
        	//}
        }
		return [false];
	}	


	protected void fn_actualizacion_archivo_fn () {
		// Función que obtiene el tamaño del archivo
		long obtener_tamanio_archivo() {
			auto filePath = "clientes.db"; // Reemplaza con la ruta a tu archivo

			// Obtiene el tamaño del archivo
			try {
				
				return to!long(getSize(filePath)); // Obtener el tamaño directamente
				
			} catch (Exception e) {
				// Captura y muestra cualquier error que ocurra
				print(" {!} Error: ", e.msg);
			}
			return 0;
		}

		// Aqui verifico si es que no ha habido 
		if (tamanio_actual != obtener_tamanio_archivo()) {
			print(" (?) Validando actualizacion de los datos ... ");
			clientes_cargados_formateado = parseJSON(readText("dir_data_clients/data_clients.json"));
		} else {
			print(" (+) No hay nada por actualizar");
		}




	} // validar_actualizacion_archi_fnvo


}
