#!/usr/bin/env dmd
module cache;
// este archivo esta destinado a manejar la cache de las sesiones iniciadas
import std;
import std.datetime;
import core.thread;

alias print = writeln;

void main(string[] args) {
	
    Cache c = new Cache();

    // Crear el hilo que ejecuta la función actualizador
    Thread hilo_fn_actualizador = new Thread(() => c.actualizador());

    // Iniciar el hilo
    hilo_fn_actualizador.start();

    // No llamamos a join() inmediatamente, sino que dejamos que el hilo se ejecute en paralelo

    // Hacemos un sleep de 10 segundos en el hilo principal
    Thread.sleep(dur!"seconds"(10));

    // Ahora agregamos una sesión
    c.agregar_sesion("192.168.1.15", "usuario_007");

    // Finalmente, aseguramos que el hilo actualizador haya terminado antes de salir
    hilo_fn_actualizador.join();
}


/**
 * Cache :  Esta clase lo que hace guardar en una cache las sesiones que sean de menos de 
 * 60 minutos de inactividad
 */
class Cache {
	/*
	{
		"sesiones" : {
			"ip_mac" : {
				"ultima_sesion": "09:30",
				"usuario_cliente": "usuario_001"

			}
		}
	}*/

	JSONValue cache_clientes_iniciados;

	this() {

		//actualizador();

		cache_clientes_iniciados = parseJSON(`{
			"sesiones": {
				"192.168.1.10": {
					"ultima_sesion": "2024-10-11T14:15:00",
					"usuario_cliente": "usuario_002"
				},
				"192.168.1.11": {
					"ultima_sesion": "2024-10-11T14:45:00",
					"usuario_cliente": "usuario_003"
				},
				"192.168.1.12": {
					"ultima_sesion": "2024-10-11T04:50:00",
					"usuario_cliente": "usuario_004"
				},
				"192.168.1.13": {
					"ultima_sesion": "2024-10-11T15:00:00",
					"usuario_cliente": "usuario_005"
				},
				"192.168.1.14": {
					"ultima_sesion": "2024-10-11T15:30:00",
					"usuario_cliente": "usuario_006"
				}
			}
		}`);

	}

	protected void actualizador () {
		/**
		 * Esta funcion lo que hace es verificar en cuestion a la inactividad de el cliente si no ha hecho alguna peticion mas 
		 * entonces si pasan 60 minutos el cliente es borrado y libero memoria de procesamiento 
		 * para no buscar desde la base de datos 
		*/
		while (true) {

			// Obtener la hora actual
			SysTime hoy_ahora = Clock.currTime();

			// Convertir SysTime a DateTime
			//auto fecha_hora = DateTime(hoy_ahora.year,hoy_ahora.month,hoy_ahora.day,hoy_ahora.hour,hoy_ahora.minute);
			//print("Hoy estamos " ~ to!string(fecha_hora));

			// Iterar sobre las claves de "sesiones"
			foreach (clave, sesion; cache_clientes_iniciados["sesiones"].object) {
				// Convertir la hora "ultima_sesion" del JSON a DateTime
				string ultima_sesion_str = sesion["ultima_sesion"].str;

				SysTime ultima_sesion = SysTime.fromISOExtString(ultima_sesion_str);

				// Añadir 60 minutos
				ultima_sesion += minutes(60); // Sumar 60 minutos

				// Comparar con la hora actual
				if (ultima_sesion > hoy_ahora) {
					writeln("Clave: ", clave, " - Última sesión es posterior a la hora actual");
				} else {
					writeln("Clave: ", clave, " - Última sesión es anterior a la hora actual");
					
				}
			}

			Thread.sleep(dur!"seconds"(10)); // Hacemos un sleep de 1 minuto


		}


	}


	public bool validar_en_cache (string ip_macToCheck) {

		// Verificar si una clave existe
		if (ip_macToCheck in cache_clientes_iniciados["sesiones"].object) {

			writeln("La clave ", ip_macToCheck, " existe.");
			return true;

		} else {

			writeln("La clave ", ip_macToCheck, " no existe.");
			return true;

		}


		return false;
	}	


    bool agregar_sesion(string ip_mac_cliente, string usuario) {
        if (ip_mac_cliente.empty || usuario.empty) {
            writeln("Error: IP/MAC o usuario no pueden estar vacíos.");
            return false;
        }

        SysTime ultima_sesion = Clock.currTime();
        JSONValue nueva_sesion;
        nueva_sesion["ultima_sesion"] = ultima_sesion.toISOExtString();
        nueva_sesion["usuario_cliente"] = usuario;

        cache_clientes_iniciados["sesiones"][ip_mac_cliente] = nueva_sesion;

        writeln("Sesión agregada/actualizada correctamente para el cliente con IP: ", ip_mac_cliente);
        return true;
    }

}

