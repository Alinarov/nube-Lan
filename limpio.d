#!/usr/bin/env dmd
// este es el servidor 100%
// pero solo es la version alfa 1.0 
// aun falta:
// - que ponga seguridad a las carpetas.
// - que de una descargue el archivo en la ruta deseada del cliente y no desde 
// 	 la ruta actual.
// ESTE ARCHIVO NECESITA MEJORAS
import std;
import std.file;
import std.socket;
import std.conv;
import std.ascii: isAlpha, isAlphaNum;
import core.thread;
import std.concurrency;

alias print = writeln;
alias pront = write;


void main () {

	auto servidor = new Servidor();
	servidor.iniciar();

}

class Servidor {
	int o = 1;
	ushort puerto = 8090; // puerto princìpal
	ushort puerto2 = 9090; // puerto secundario en casos de errores
	Socket server; // iniciador del servidor
	Socket cliente; // socketAddres del cliente
	public string archivoRecivido; // nombre del archivo recivido
	
	this() {
		this.archivoRecivido = archivoRecivido;
		this.o = o;
		print(" [+] Iniciando dependencias ... ");

		server = new Socket(AddressFamily.INET, SocketType.STREAM);
		print(" [-] Nuevo servidor en el protocolo ");

		try {
			
			print(" [!] Socket iniciado en el puerto 8090 ");
			auto address = new InternetAddress(puerto);
			server.bind(address);

		} catch (SocketException ex) {

			print(" [!] Socket iniciado en el puerto 9090 ");
			auto address = new InternetAddress(puerto2);
			server.bind(address);

		}

		pront(" [-] Puerto de server ");
		pront(puerto);

		server.listen(5);
		print("\n [-] Servidor en escucha ...");

	}

	void iniciar() {
        // Imprime el caracter actual del spinner
        //o = false;

        while (true) {
        	//Thread.sleep(dur!"msecs"(100));
        	if (o == 1) {spawn(&loadSpinner, o);} else {}
			cliente = server.accept();  // servidor en espera de aceptar jugadores
			nombre(cliente, o);

        }

	}

	void nombre (Socket c, int o) {

		//print("sasa"~ to!string(o));
		print("\n\n[!] Cliente conectado.. para recibir nombre del archivo");

	    char[1024] bufferMensaje;
	    
	    c.receive(bufferMensaje);
	
	   	char [27] alfaNumerico = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', ' '];
		char[2] enhe = [0xC3, 0xB1];
		char [10] numeros = ['1','2','3','4','5','6','7','8','9','0'];
		char [10] simbolos = ['\\', '/', ':', '*', '?', '"', '<', '>', '|','.'];
	
		char[] permitido = alfaNumerico ~ numeros ~ simbolos;
	
		string nombreArchivo = "rec-";
	
		foreach (char caracter; bufferMensaje) {
			if (permitido.canFind(caracter)) {
				nombreArchivo~= caracter; // esta linea añade los caracteres 
										  // especiales al string 
			} else {
				//print(" Mensaje no permitido o solo es binario del envio ");
			}


		
		}

		try {
			print("El nombre del archivo es "~ nombreArchivo);

			// establecemos conexciones en un hilo diferente, para estar siempre
			// en escucha y conectar hosts
			conexion(c, nombreArchivo); // establecer una conexcion con las jugadoras

		} catch (Exception e) {
			print("error");
		}



	}

	void conexion(Socket c, string nombreArchivo) {
		// esta funcion es donde se va a recivir el contenido del archivo

		o = 0;
		print("[!] cliente conectado..");
		
	
		auto file = File(nombreArchivo , "wb");
	
		while (true) {
	
			char [1024] buffer;
	
			auto size = c.receive(buffer); 
	
			if (size == 0) {
				break;
			}
	
			file.write(buffer[0 .. size]); // filtracion del mensaje dentro del buffer 
		}
	
		file.close();
	
		print("\nArchivo recivido \n");
		
		// task!IdentificacionClient(c, nombreArchivo).executeInNewThread();
		

		archivoRecivido = nombreArchivo;
		print(archivoRecivido);
		identificacionIpv4(c);

		print("moviendo..");

		

		// Hasta aqui ya el archivo a sido recivido y guardado
	}


	void identificacionIpv4 (Socket c) {
		print("funcion de identificar el cliente");
		// definicion y filtrado de la Ipv4 y el puerto efimeto
		auto clienteAddress = c.remoteAddress();
		
		// Identificando la IPv4
		string clienteIp = clienteAddress.toString()[0.. $-6];
		print("Ipv4 entrante es: "~ clienteIp);

		// Identificacion el puerto efimero del cliente
		string puertoEfimero = clienteAddress.toString()[$-6 .. $];
		print("El puerto efimero es: " ~ puertoEfimero);

		print("Impresion de comprobacion del nombre del archivoRecivido" ~ archivoRecivido);

		task!IdentificacionClient(cliente, archivoRecivido, clienteIp).executeInNewThread();


	}

	static void IdentificacionClient(Socket c, string nombreArchivo, string IpCliente) {
		// En esta funcion verificare si el cliente que se ha conectado ya esta 
		// registrado, si es asi solo se movera el archivo recivido a la carpeta 
		// que le corresponte de lo contrario creara una nueva carpeta y ahi 
		// movera el archivo recivido
		print("La ip del cliente conectado es " ~ IpCliente);
		// primero definimos la ruta del cliente que sera su misma Ip
		IpCliente = IpCliente.replace(".", ""); // eliminamos los puntos de las Ip
		IpCliente = IpCliente ~ "/"; // agregamos el / para indicar que crearemos un dir
		
		if (IpCliente.exists && IpCliente.isDir) { // verificacion si el dir es existente

			print("si existe y es un directorio");
			moverArchivos(nombreArchivo, IpCliente);


		} else { // si existe entonces lo creara el directorio o el usuario

			print("no existe asi que creare el usuario");
			IpCliente.mkdir;
			print("cliente creado");
			moverArchivos(nombreArchivo, IpCliente);

		}

		/+
		} else if (IpCliente.exists && IpCliente.isFile) { // verifica si el directorio existe

			print("si existe y es archivo");
		+/
	}


	static void moverArchivos (string archivoRecivido, string rutaUsuario) {
		// Esta es la funcion donde se mueve el archivo a la carpeta del usuario 
		print("[+] Moviendo el archivo a la carpeta del propietario.. ");
		copy(archivoRecivido, rutaUsuario~archivoRecivido); // primero lo copia
		remove(archivoRecivido); // luego remueve el original 
		if ( rutaUsuario~archivoRecivido.exists) { // aqui comprobamos que se haiga copiado
			
			print("[✔] El archivo se entrego satisfactoriamente a la carpeta del propietario");
		
		} else { // sino pos simplemente imprimimos este mensaje 
		
			print("[!] Creo que ha ocurrido un error..");
		
		}

	}
    



}



// la siguiente funcion es un loadspiner, aun faltan mejoras pero no tengo tiempo 
// y no es lo mas importante 
public void loadSpinner(int o) {
	enum Spinner = [ '|', '/', '-', '\\' ]; // Los caracteres del spinner
    size_t currentSpinnerIndex = 0; // Índice del caracter actual en el spinner
    while (o != 0) {


		string mensaje = " [" ~ Spinner[currentSpinnerIndex] ~ "] Esperacion por las nuevas jugadoras \r" ;
		pront(mensaje);

        // Incrementa el índice del spinner
        currentSpinnerIndex = (currentSpinnerIndex + 1) % Spinner.length;

        // Espera 100 milisegundos antes de imprimir el siguiente caracter
        Thread.sleep(dur!"msecs"(5));
       	if (o == 0) {break;}

    }


}









