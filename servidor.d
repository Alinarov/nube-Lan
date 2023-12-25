#!/usr/bin/env dmd
// este es el servidor 100%
import std;
import std.file;
import std.socket;
import std.conv;
import std.ascii: isAlpha, isAlphaNum;
import core.thread;

alias print = writeln;

void main() {

	auto server = new Socket(AddressFamily.INET, SocketType.STREAM);
	print(" [-] Nuevo servidor en el protocolo 0.0.0.0");

	ushort port = 9090;

	auto address = new InternetAddress(port);
	server.bind(address);
	print(" [-] puerto de server 5500");


	server.listen(5); // coloca el servidor en escucha
	print(" [-] servidor en escucha ...");

	while (true) {

		print(" [-] esperando a las jugadoras ");

		auto client = server.accept();  // servidor en espera de aceptar jugadores

		// recibimos el nombre del archivo

		client.close();
		//server.close();
		task!nombre(client).executeInNewThread();
		
	
		print(" [+] servidor creado "); 
		

	}
}

void nombre(Socket c) {


    print("[!] Cliente conectado.. para recibir nombre del archivo");

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
			nombreArchivo~= caracter; // esta linea añade los caracteres especiales al string 
		} else {
			//print(" Mensaje no permitido o solo es binario del envio ");
		}

	}

	
	try {
		print("El nombre del archivo es "~ nombreArchivo);

		// establecemos conexciones en un hilo diferente, para estar siempre en escucha y conectar hosts
		task!conexion(c, nombreArchivo).executeInNewThread(); // establecer una conexcion con las jugadoras

	} catch (Exception e) {
		print("error");
	}
}



void conexion(Socket c, string nombreArchivo) {
	print("[!] cliente conectado..");


	auto file = File(nombreArchivo , "wb");

	while (true) {

		char [1024] buffer;

		auto size = c.receive(buffer);

		if (size == 0) {
			break;
		}

		file.write(buffer[0 .. size]);
	}

	file.close();

	print("Archivo recivido \n");
	
	task!mover(c, nombreArchivo).executeInNewThread();

	print("moviendo..");
}



void mover(Socket c, string nombreArchivo) {
	print("moviendo ruta");
 	string ruta = "~/Descargas/"~nombreArchivo;
	//string ruta = "/home/dani/Descargas/"~nombreArchivo;
	try {

		copy(nombreArchivo, ruta);
		
		remove(nombreArchivo);
		
		print("Archivo movido a la carpeta de Descargas/");

	} catch (Exception ex) {

		string errorMover = " \n\nAsi que puedes moverlo a tu donde quieras manualmente :D ";
		print("Error de movido .. :(");
		print("Pero no te preocupes tu archivo esta en esta ruta: \n");

		print(getcwd()~errorMover); // esto imprime la ruta actual mas el error errorMover
		
		// creacion de otro servidor
		auto clientAddress = c.remoteAddress();

		print("creando nuevo server.. ");
		string clientIP = clientAddress.toString();
		string _clientIp = clientIP[0 .. $-6];
	    print("client: "~clientIP);
		ushort puerto = 9090;
		c.close();




	}


}




