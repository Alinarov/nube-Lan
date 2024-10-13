#!/usr/bin/env dmd 
module servidor;
import std;
import core.thread;
import std.json;
import std.algorithm;

import crud;
import gestor_clientes;

alias print = writeln;
alias pront = write;


//void main () {

//	//Servidor servidor = new Servidor();
//	//servidor.fn_init();

//}


/**
 * Servidor
 */
class Servidor {
	ushort puerto1, puerto2;
	Socket server, cliente;
	string mi_ip_v4_lan;    
	string mi_public_ip;

	ushort puerto_activo;

	this () {
		this.puerto_activo = puerto_activo;
		this.puerto1 = 9090;
		this.puerto2 = 8080;    

		this.mi_ip_v4_lan = fn_get_ip_v4();
		this.mi_public_ip = fn_get_public_ip();

	} // constructor

	public void fn_init () {
		print(" [+] Iniciando el gestor de archivos ");
		server = new Socket(AddressFamily.INET, SocketType.STREAM);

		print(" [!] Protocolo iniciado : " ~ mi_ip_v4_lan);
		print(" [!] Direccion Servidor : " ~ mi_public_ip);

		try {

			print(" [!] Socket iniciado en el puerto  "~ to!string(puerto1));
			puerto_activo = puerto1;
			auto address = new InternetAddress(puerto1);
			server.bind(address);	

		} catch ( SocketException e) {

			print(" [!] Socket iniciado en el puerto "~to!string(puerto2));
			puerto_activo = puerto2;
			auto address = new InternetAddress(puerto2);
			server.bind(address);

		}

		server.listen(5);
		print("\n [-] Servidor en escucha ...");

		fn_escucha();

	} // init()

	public void fn_escucha() {

	    while (true) {
	        // Lanza el spinner en un hilo independiente
	        spawn(&fn_loadSpinner);  // O simplemente: spawn(fn_loadSpinner);

	        // Acepta el cliente (espera de conexión)
	        auto cliente = server.accept();

	        // Procesa la conexión del cliente
	        fn_recepcion_orden(cliente);
	    }
	} // escucha()

	public void fn_recepcion_orden (Socket socket_cliente) { // aqui voy a recibir el mensaje o la orden 

		print(" \n\n[+] Cliente conectado, listo para recibir la orden");
		auto clienteAddress = socket_cliente.remoteAddress(); // identificamos el cliente para enviarle 
												// el resultado de la operacion
		// Identificacion del cliente 	
		string clienteIp = clienteAddress.toString()[0 .. $-6]; // conversion a string el Ip_cliente
		print("El cliente IP quiere mandar un mensaje: "~ clienteIp);
		string puertoEfimero = clienteAddress.toString()[$-6 .. $];
		print("El puerto efimero es: " ~ puertoEfimero);

		// Esto agregara una carpeta de trabajo 
		Gestor_clients g_c = new Gestor_clients(clienteIp);




	    char[1024] buffer; // Buffer para recibir los datos

	    auto largo_bytes = socket_cliente.receive(buffer); // Recibir datos en el buffer

	    // Validar que se recibieron datos
	    if (largo_bytes == 0) {
	        print("No se recibieron datos del cliente.");
	        return; // Salimos si no hay datos
	    }

		string mensaje_filtrado = to!string(buffer[0 .. largo_bytes]); // Concatenar los datos al string

		print("Mensaje \"" ~ mensaje_filtrado ~ "\""); // impresion del mensaje filtrado

	    // Procesar el mensaje para preparar la decodificación JSON
	    string ordenEncode = mensaje_filtrado.replace("`", "\"").replace("\\", "/");
	    
	    // Intentar decodificar el JSON
	    JSONValue ordenDecode;

	    try {
	        ordenDecode = parseJSON(ordenEncode);    
	        // Imprime el comando si se decodifica correctamente
	        print("La orden es " ~ ordenDecode["comando"].str);
	    } catch (JSONException e) {
	        // Manejo de errores si ocurre una excepción al decodificar el JSON
	        writeln("Error al decodificar JSON: ", e.msg);
	        print("Contenido recibido: ", ordenEncode); // Imprimir el contenido que causó el error
	        socket_cliente.close(); // Cerramos la conexión con el cliente
	        return;
	    }


		// Switch de casos a las funciones
		switch (ordenDecode["comando"].str) { 

			case "ls": { 
				print("ls");
				string ruta_recivida;
				try {
					ruta_recivida = ordenDecode["ruta_dir"].str;
				} catch (Exception e) {
					print(" {!} Error: " ~ e.msg);
					return;
				}
				Gestor_archivos gestor = new Gestor_archivos();
				string elementos = gestor.fn_ls_dir(ruta_recivida);

				// enviar el resultado al cliente
				fn_enviar_mensaje(elementos, socket_cliente);

				break;
			} 

			case "entrar": {
				string ruta_recivida;
				try {
					ruta_recivida = ordenDecode["ruta_dir"].str;
				} catch (Exception e) {
					print(" {!} Error: " ~ e.msg);
					return;
				}
				print("entrar");
				Gestor_archivos gestor = new Gestor_archivos();
				string elementos = gestor.fn_ingresar_dir(ruta_recivida);
				fn_enviar_mensaje(elementos, socket_cliente);

				break;
			}

			case "descargar" : {
				print("descargar");
				Gestor_archivos gestor = new Gestor_archivos();
				string ruta_archivo;
				try { 
					ruta_archivo= ordenDecode["ruta_archivo"].str;
				} catch (Exception e) {
					print(" {!} Error: " ~ e.msg);
					return;
				}
				string elementos = gestor.fn_descargar(ruta_archivo);

				Thread.sleep(dur!"seconds"(1)); // hacemos un sleep de 1 segundo
				fn_enviar_mensaje(elementos, socket_cliente);
				print(" {+} Proceso de descargar al cliente ha terminado");
				break;

			}

			case "almacenar" : {

		        char[4096] buffer_subir; // Aumentar el tamaño del buffer_subir para recibir más datos si es posible
				string bytes_filtrados;     // Variable para almacenar todos los datos recibidos

				while (true) {
				    auto largo_bytes_subida = socket_cliente.receive(buffer_subir); // Recibir datos en el buffer_subir
				    
				    if (largo_bytes_subida <= 0) {
				        break; // Si no se reciben más datos, salir del bucle
				    }

				    // Convertir los bytes recibidos a string y añadirlos a la bytes_filtrados completa
				    bytes_filtrados ~= to!string(buffer_subir[0 .. largo_bytes_subida]);
				}


				// Aqui si recive los datos
				//writeln("Datos recibidos:", bytes_filtrados);


				Gestor_archivos gestor = new Gestor_archivos();

				string ruta_archivo;
				try {
				 	ruta_archivo = ordenDecode["ruta_archivo"].str;
					
					gestor.fn_subir_archivo(ruta_archivo, bytes_filtrados);

				 } catch (Exception e) {
				 	print(" {!} Error: " ~ e.msg);
				 	return;
				 } 
								

				print(" {+} Proceso de almacenado terminado");
				break;
			}

			case "eliminar" : {

				string ruta_elemento; 
				try {
					ruta_elemento = ordenDecode["ruta_elemento"].str;

					Gestor_archivos gestor = new Gestor_archivos();
					gestor.fn_eliminar_elemento(ruta_elemento);
					print(" {+} Proceso de eliminar ha terminado");
				} catch (Exception e) {
					print(" {!} Error: " ~ e.msg);
					return;
				}

				break;

			}

			case "mensaje" : {
				string mensaje = ordenDecode["contenido_mensaje"].str;
				print(mensaje);

				break;

			}

			default: {
				print(" {!} No se encontro el comando");
				fn_enviar_mensaje("No se encontro el comando" ~ "\n" ~ to!string(ordenDecode), socket_cliente);
				fn_escucha();		
				return;
				break;
			}

		}

	} // fn_recepcion_orden

	public void fn_enviar_mensaje(string mensaje = null, Socket socket_cliente) {

		Thread.sleep(dur!"seconds"(1)); // hacemos un sleep de 1 segundo
		// enviamos el contenido del archivo
		socket_cliente.send(mensaje); 
		// hacemos una pequeña espera 
		// Aqui solo mando el contenido del archivo ya que el cliente de por si 
		// ya tiene el nombre del archivo que quiere descargar
		// cerramos la conexion
		socket_cliente.close();
		print(" [+] Mi address es " ~ mi_ip_v4_lan);
		print(" [:3] Se esta usando el puerto " ~ to!string(puerto_activo));
		print(" [!] Elemento enviado con exito\n");

	} // fn_enviar_mensaje

	public string fn_get_ip_v4() {
	    string hostName = Socket.hostName(); // Obtiene el nombre del host actual de la máquina
	    InternetHost ih = new InternetHost; // Crea una nueva instancia de InternetHost

	    if (!ih.getHostByName(hostName)) {
	        //writeln("No se pudo encontrar el host: ", hostName);
	        return " [-] Error: Host no encontrado";
	    }

	    // Verifica si hay direcciones IP en la lista
	    if (ih.addrList.length == 0) {
	        //writeln("No se encontraron direcciones IP para el host: ", hostName);
	        return " [-] Error: No hay direcciones IP";
	    }

	    // Crea un objeto InternetAddress a partir de la segunda dirección IP en la lista
	    InternetAddress ipAddr = new InternetAddress(ih.addrList[0], InternetAddress.PORT_ANY);
	    this.mi_ip_v4_lan = ipAddr.toAddrString(); // Imprime la dirección en formato legible
	    return mi_ip_v4_lan;
	} // fn_get_ip_v4

	public string fn_get_public_ip() {
	    try {
	        auto respuesta_ip_publica = std.net.curl.get("https://api.ipify.org");
	        
	        // Verifica si la respuesta es válida
	        if (respuesta_ip_publica.empty) {
	            writeln("Error: No se recibió respuesta de la API.");
	            return "Error: Respuesta vacía";
	        }

	        this.mi_public_ip = to!string(respuesta_ip_publica);
	        return this.mi_public_ip;
	    } catch (Exception e) {
	        writeln("Error al obtener la IP pública: ", e.msg);
	        return "Error: No se pudo obtener la IP pública";
	    }
	} // fn_get_public_ip



} // Clase: Servidor 


public void fn_loadSpinner() {
    enum Spinner = [ '|', '/', '-', '\\' ]; // Los caracteres del spinner
    size_t currentSpinnerIndex = 0; // Índice del caracter actual en el spinner
    bool continuar = true; // Puedes usar esto para controlar cuándo detener el spinner

    while (continuar) {
        // Mensaje con el caracter del spinner
        string mensaje = " [" ~ Spinner[currentSpinnerIndex] ~ "] Esperando nuevos clientes \r";
        write(mensaje);
        // Limpia el buffer de salida inmediatamente
        stdout.flush();

        // Incrementa el índice del spinner
        currentSpinnerIndex = (currentSpinnerIndex + 1) % Spinner.length;

        // Espera 100 milisegundos antes de imprimir el siguiente caracter
        Thread.sleep(dur!"msecs"(200));
    }
    
} // fn_loadSpinner
