#!/usr/bin/env dmd
import std.stdio;
import std;
import core.thread;
import std.json;
import std.algorithm;

alias print = writeln;
alias pront = write;

void main () {

	Visor visor = new Visor();
	visor.init();

}

class Visor {

	ushort puerto1, puerto2;
	Socket server, cliente;
    string dirActual;
    string home;

	this () {
		this.home = dirActual;
		this.puerto1 = 5070;
		this.puerto2 = 5080;
    	this.dirActual = getcwd(); // string del directorio actual 
    
	} // constructor

	void init () {
		print(" [+] Iniciando el gestor de archivos ");
		server = new Socket(AddressFamily.INET, SocketType.STREAM);
		print(" [!] Protocolo iniciado ");

		try {

			print(" [!] Socket iniciado en el puerto  "~ to!string(puerto1));
			auto address = new InternetAddress(puerto1);
			server.bind(address);	

		} catch ( SocketException e) {

			print(" [!] Socket iniciado en el puerto 5080 "~to!string(puerto2));
			auto address = new InternetAddress(puerto2);
			server.bind(address);

		}

		server.listen(5);
		print("\n [-] Servidor en escucha ...");

		escucha();

	} // init()

	void escucha () { // {+}  Servidor en escucha 
        // Imprime el caracter actual del spinner
        while (true) {
        	//Thread.sleep(dur!"msecs"(100));
			cliente = server.accept();  // servidor en espera de aceptar jugadores
			orden(cliente);

        }

	} // escucha()

	void orden (Socket c) { // aqui voy a recibir el mensaje o la orden 

		print(" \n\n[+] Cliente conectado, listo para recibir la orden");
		char[1024] buffer; // definicion del buffer 
	 	auto n = c.receive(buffer); // tamaño del buffer recivido
		auto clienteAddress = c.remoteAddress(); // identificamos el cliente para enviarle 
												// el resultado de la operacion
		string clienteIp = clienteAddress.toString()[0 .. $-6]; // conversion a string el Ip_cliente

		string puertoEfimero = clienteAddress.toString()[$-6 .. $];


		print("El puerto efimero es: " ~ puertoEfimero);
		string cadena = to!string(buffer[0 .. n]); // filtracion del mensaje en el buffer 
		
		print("Mensaje \"" ~ cadena ~ "\""); // impresion del mensaje filtrado

		string ordenEncode = cadena; 
		ordenEncode = ordenEncode.replace("\"", "`");
		ordenEncode = ordenEncode.replace("\'", "\"");

		print(ordenEncode);


		JSONValue ordenDecode = parseJSON(ordenEncode);
		
		print("La orden es "~ ordenDecode["comando"].str);

		// Switch de casos a las funciones
		switch (ordenDecode["comando"].str) { 

			case "ls": { 
				string resultado = lsDir(dirActual); // obtenemos el resultado del listado
				print(resultado);

				Thread.sleep(dur!"seconds"(1)); // hacemos un sleep de 1 segundo
				c.send(resultado);
				print("enviado \n");
				break;
			} 

			case "home" : {
				print("hoa");
		        ///print("Ruta antes del cambio" ~ dirActual);

		        ///writeln("\n {+} Ahora la ruta actual: ", home);

		        ///// [2] Barrido de la ruta y sus archivos
				string resultado = lsDir("/home/dani/Archivos/Proyecto/");
				Thread.sleep(dur!"seconds"(1));
		        ///// [3] Enviación de la ruta
				c.send("/home/dani/Archivos/Proyecto/");

				writeln("Enviación de entrando a ", "/home/dani/Archivos/Proyecto/");

		        break;
			}

			case "entrar": {
				// [1] Cambio de ruta y actualizacion de la ruta
				string carpeta = ordenDecode["directorio"].str.strip();
				print("\n {+} Carpeta a entrar es " ~ carpeta);
				dirActual ~= "/" ~ carpeta;
				print("\n {+} Ahora la ruta actual: " ~ dirActual);
				dirActual = buildNormalizedPath(dirActual);

				// [2] Barrido de la ruta y sus archivos
				string resultado = lsDir(dirActual);
				Thread.sleep(dur!"seconds"(1));

				// [3] Enviacion de la ruta
				c.send(resultado);

				print("Enviacion de entrando a "~ ordenDecode["directorio"].str);

				break;
			}

			case "descargar" : {
				// primero identificamos el nombre del elemento que nos piden
				string nombreElemento = ordenDecode["elemento"].str;	
				string[] nombresNoPermitidos = [".so", "visorArchivos.o"];
				// variable que almacenara el contenido de lo que se va a enviar
				void[] contenido;

				try {
					print("\n Elemento a descargar  \n" ~ dirActual~"/"~nombreElemento);

					if ((dirActual~"/"~nombreElemento).strip().isFile) {				
						contenido = read((dirActual~"/"~nombreElemento).strip());
					
					} else if (dirActual ~ "/" ~ nombreElemento.isDir) {
						print("La peticion en un dir");	
					}			

				}catch (FileException e) {
					print(e);
				}
				Thread.sleep(dur!"seconds"(1)); // hacemos un sleep de 1 segundo
				// enviamos el contenido del archivo
				c.send(contenido); 
				// hacemos una pequeña espera 
				// Aqui solo mando el contenido del archivo ya que el cliente de por si 
				// ya tiene el nombre del archivo que quiere descargar
				// cerramos la conexion
				c.close();
				print("Elemento enviado con exito");
				break;

			}

			default: {
				print("no se encontro el comando");
				print(ordenDecode);
				escucha();				
				break;
			}

		}


	} // orden()

	string lsDir (string dirActual) { // funcion para obtener el listado de las los Dir y Archivos en  el 
					// directorio actual 
	    //string dirActual = getcwd(); // (pwd) string del nuestra ruta de directorio actual 
	    int lengthRuta = to!int(dirActual.length); // con esto obtendre el nombre  de los elementos
	    // string dirAnterior = dirName(getcwd()); // con el dirName podemos hacer que el 
	                                                // directorio sea desde el anterior 
	    //print(dirActual);
	    int elementos; // numero de elementos en el directorio actual 
	    string [] contenido = []; // creacion de la lista
	    string nombres; // variable para filtrar los nombres
	
	    // creo el json para los directorios y archivos
	    string contenidoJson = `{
	        "directorios" : [],
	        "archivos" : [],
	        "elementos": []
	    }`;
	    JSONValue JsonContenido = parseJSON(contenidoJson);
	
	
		// [+] Control de errores, si el directorio que nos mandan no existe, entonces lo creamos 
	    if (!dirActual.exists) {
	    	mkdir(dirActual);
	    }
	    // Hare un foreach para ver los 
	    foreach (DirEntry entrada; dirEntries(dirActual, SpanMode.shallow)) { 
	        elementos++ ; // numero de elementos iniciando del 0
	        contenido ~= entrada.name; // Almaceno el resultado en una lista unidimencional
	        
	        nombres = entrada.name[lengthRuta .. $]; // filtracion de los nombres de las 
	        											// rutas
	        //print(nombres); 
	
	        nombres = nombres.replace("/",""); // eliminamos los "/" para que no haiga 
	                                            //incomvenientes
	        
	        // filtracion de los archivos y los directorios encontrados
	        if (entrada.isFile && entrada != ".so") { // filtracion si es archivo
				
	            JsonContenido.object["archivos"].array ~= JSONValue(nombres);
	
	        } else if (entrada.isDir) { // fitracion si es directorio
	
	            JsonContenido.object["directorios"].array ~= JSONValue(nombres);
	
	        } // condicional if

	    } // iterador foreach

		// Numero de elementos 
	    JsonContenido.object["elementos"] = JSONValue(elementos);

	    //print(JsonContenido);
	    //print("El numero de elementos es ", elementos );
	    //    print(contenido[0 .. $]); // 

	    return to!string(JsonContenido);
	} // lsDir()

} // CLASE PADRE

