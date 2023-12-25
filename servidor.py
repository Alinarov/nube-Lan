import socket

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

server.bind(("192.168.0.13",9090))
server.listen()

print("server creado")

client_socket, client_address = server.accept()

file = open("6594-bosques.jpg", "wb")

imagechuk = client_socket.recv(2048)

while imagechuk:
	file.write(imagechuk)
	imagechuk = client_socket.recv(2048)

print("archivo descargado")
file.close()
client_socket.close()


