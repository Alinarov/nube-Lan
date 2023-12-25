import std.stdio;
import core.thread;
import core.time;

void main() {
	loadSpinner();
}


string loadSpinner() {
    enum Spinner = [ '|', '/', '-', '\\' ]; // Los caracteres del spinner
    size_t currentSpinnerIndex = 0; // Índice del caracter actual en el spinner

    while (true)
    {
        // Imprime el caracter actual del spinner
        writef("\r%c", Spinner[currentSpinnerIndex]);
        write("hola");


        // Incrementa el índice del spinner
        currentSpinnerIndex = (currentSpinnerIndex + 1) % Spinner.length;

        // Espera 100 milisegundos antes de imprimir el siguiente caracter
        //Thread.sleep(dur!"msecs"(100));
    }

}

		//core.thread.Thread.sleep(dur!"seconds"(2)); // time.sleep(5) 
        // Espera 100 milisegundos antes de imprimir el siguiente caracter
        //Thread.sleep(dur!"msecs"(100));