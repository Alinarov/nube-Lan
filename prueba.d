#!/usr/bin/env dmd
import std.file;
import std;
import std.socket;
import std.conv;
import core.thread;
import std.json;
alias print = writeln;

void main () {

	/**
	 * Servidor donde quiero hacer un chat en lan
	 */
	class name {

		ushort puerto1 = 8080;
		ushort puerto2 = 9090;

		this() {
				
		}

		Socket serverInit () {
			auto server = new Socket(AddressFamily.INET, SocketType.STREAM);
			print(" [-] Nuevo servidor en el protocolo 0.0.0.0");

			try {

				print(" [!] Socket iniciado en el puerto  "~ to!string(puerto1));
				auto address = new InternetAddress(puerto1);
				server.bind(address);	

			} catch ( SocketException e) {

				print(" [!] Socket iniciado en el puerto "~ to!string(puerto2));
				auto address = new InternetAddress(puerto2);
				server.bind(address);

			}
	
			server.listen(5); // coloca el servidor en escucha
			print(" [-] servidor en escucha ...");

			while (true) {

				print(" [-] esperando a las jugadoras ");

				auto client = server.accept();  // servidor en espera de aceptar jugadores

				// recibimos el nombre del archivo

				task!nombre(client).executeInNewThread();
				
			
				print(" [+] servidor creado "); 
				

			}


		}











	}







}




/+
void main () {



}


void nombre (Socket c) {

	print("[!] Cliente conectado.. para recibir nombre del archivo");

	auto clientAddress = c.remoteAddress();
	string clientIP = clientAddress.toString();
	string _clientIp = clientIP[0 .. $-6];
	
	ushort puerto = 9090;
	auto address = new InternetAddress(_clientIp,puerto);


	print("envio");
	try {
		c.sendTo("hola".toUTF8(), address);
		print("enviado");
	} catch (Exception ex) {
		print(ex);
	}


 

}

+/