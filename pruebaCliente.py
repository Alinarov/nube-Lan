import socket

def recibirMensaje():
    servidor = '192.168.0.13'
    puerto = 8090

    cliente = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    cliente.connect((servidor, puerto))

    buffer_size = 1024
    mensaje = cliente.recv(buffer_size).decode()
    print("Mensaje recibido del servidor:", mensaje)

    cliente.close()

recibirMensaje()