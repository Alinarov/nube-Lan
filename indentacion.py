#!/usr/bin/env python
# Este archivo ordenara y pondra tabulaciones en el archivo de cuentas.
import json 
import os 


def identacion(yeison):
    # el if verifica si el archivo esxiste
    if os.path.exists(yeison):
        # si existe el archivo entonces, hara el proceso de indentacion
        with open(yeison, "r+") as clientesIpv4:
            datos = json.load(clientesIpv4)
            jsonString = json.dumps(datos, indent = 4, ensure_ascii=False)

        # primero lo lee, convierte el string en json con indentacion y 
        # aqui abajo lo va a sobreescribir para que estea con indentacion el archivo
        with open(yeison, "w") as archivo2:
            archivo2.write(jsonString)        

    else: # si no existe el archivo entonces lo creara
        with open(yeison,"w") as creacion:
            creacion.write("{}")
        creacion.close()
        identacion(yeison) # aqui hara el proceso de indentacion una ves creado el archivo


with open("archivo.json", "r") as nombre:
    nombreArchivo = json.load(nombre)
    identacion(nombreArchivo["nombre"])
