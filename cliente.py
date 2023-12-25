#!/usr/bin/env python
import threading
import socket
import time
import multiprocessing


"""
def abrir_conexion():
    cliente = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    servidor = '192.168.0.13'
    puerto = 9090
    cliente.connect((servidor, puerto))
    return cliente


def enviar_archivo(cliente):
    # envío de nombre de archivo
    nombreArchivo = "images.png"
    archivo = open(nombreArchivo, "rb")
    cliente.send(nombreArchivo.encode())

    # tiempo de espera para que el servidor capte el nombre del archivo y no se junte todo
    time.sleep(1)

    # bucle para que el programa envíe el archivo en paquetes distintos
    imagen_data = archivo.read(2048)
    while imagen_data:
        cliente.send(imagen_data)
        imagen_data = archivo.read(2048)

    archivo.close()
    print("archivo enviado")
    cliente.close()

# Abrir la conexión
cliente = abrir_conexion()

# Enviar el archivo
enviar_archivo(cliente)

def recivoError(cliente):
    time.sleep(3)
    cliente = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    servidor = '192.168.0.13'
    puerto = 9090
    cliente.connect((servidor, puerto))

    print("inicio de conexion ..")
    respuesta = cliente.recv(1024).decode()
    print('Respuesta recibida del servidor:', respuesta)

recivoError(cliente)


"""



import threading 
import socket 
import time
import multiprocessing

cliente = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
servidor = '192.168.0.13'
puerto = 9090
try:
    cliente.connect((servidor,puerto))
    
except:
    puerto = 8090
    cliente.connect((servidor,puerto))
    




# envio de nombre de archivo
nombreArchivo = "images.png"
archivo =  open(nombreArchivo, "rb")
cliente.send(nombreArchivo.encode())


# tiempo de espera para que el servidor capte el nombre del archivo y no se junte todo
time.sleep(1)


# bucle para que el programa envie el archivo en paquetes distintios

# numero de bytes de envio por paquete 
imagen_data = archivo.read(2048)
while imagen_data:
	cliente.send(imagen_data)
	imagen_data = archivo.read(2048)
	# Recibir la respuesta del servidor
	pass


cliente.close()








"""
def respuesta(): # esta es una funcion que va a estar al tanto por si hay algun error del servidor entonces, el servidor enviara un mensaje al cliente correspondiente.
	buffer_size = 1024
	# esperando respuesta
	print("esperando respuesta")
	respuesta = cliente.recv(buffer_size).decode()
	print('Respuesta recibida del servidor:', respuesta)
"""








