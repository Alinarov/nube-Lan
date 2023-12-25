#include <windows.h>
#include <iostream>
#include <cmath>
#include <cstdlib>
#include <math.h>
#include <stdio.h>
#include <conio.h>
#include <string>

using namespace std;
//void numeros(int&,int&);
void menu();
void funcion(int&, int&, int&, int&, int&, int&);
void entrada(int&, int&, int&, int&, int&, int&);
void opciones();


int main(){
	system("@title Operador de ecuacoines lineales v1.0 ᓚᘏᗢ ");
	int va1;
	int va2;
	int va3;
	int va4;
	int r1;
	int r2;
	int determinante_S;
	int determinante_Y;
	int determinante_X;
	int x;
	int y;

	menu();
	opciones();
	entrada(va1,va2,va3,va4, r1,r2);// funcion de entrada
	funcion(va1,va2,va3,va4, r1,r2);// funcion de operador

	getch();
	return 0;
}


void  menu(){
	/*
	(1) 5(x)-2(y)= -2
	(2) -3(x)+7(y)= -22
	*/
	string cadena0 = "                        ";
	string cadena1 = "     va1    va2     r1";
	string cadena2 = "(1)  5(x)  -2(y) =  -2";
	string cadena3 = "(2) -3(x)  +7(y) =  -22";
	string cadena4 =  "     va3    va4     r2";
    string ejemplo = " ojo con las variables ";

    int matris[6][60]= {{1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,7,0,0,0,0,0,0,1,0},
                        {1,0,0,1,1,1,0,0,0,1,1,0,0,0,1,1,1,0,0,1,1,0,0,1,1,1,0,0,0,1,1,0,0,1,0,0,1,0,0,1,1,0,0,1,0,0,0,0,0,1,1,6,0,0,0,0,0,1,0,0},
                        {1,0,0,0,1,0,0,0,0,1,1,0,0,1,0,0,0,1,0,1,1,0,0,1,0,0,1,0,0,1,1,0,0,1,0,0,1,0,0,1,1,0,0,1,0,0,0,0,0,1,1,2,0,0,0,0,0,0,0,1},
                        {1,0,0,0,1,0,0,0,0,1,1,0,0,1,0,0,0,1,0,1,1,0,0,1,0,1,0,0,0,1,1,0,0,1,0,0,1,0,0,1,1,0,0,1,0,0,0,0,0,1,1,3,0,0,0,0,0,0,0,1},
                        {1,0,0,0,1,0,0,0,0,1,1,0,0,0,1,1,1,0,0,1,1,0,0,1,0,0,1,0,0,1,1,0,0,0,1,1,1,0,0,1,1,0,0,1,1,1,1,0,0,1,1,4,0,0,0,0,0,0,1,0},
                        {1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,5,0,0,0,0,0,0,0,1}};

    for (int i=0;i<6;i++){
        for(int j=0;j<60;j++){
            if (matris[i][j]== 1)cout<<char(219);
            else cout<<" ";
            // ejemplo de ecuacion
            if(matris[i][j] == 2)cout<< cadena1;
            if(matris[i][j] == 3)cout<< cadena2;
            if(matris[i][j] == 4)cout<< cadena3;
            if(matris[i][j] == 5)cout<< cadena4;
            if(matris[i][j] == 6)cout<< cadena0;

            if(matris[i][j] == 7)cout<< ejemplo;



        } cout<<endl;

    }
}

void opciones(){
    printf("<instruciones> <inicio> <acerca de> \n");
    string opcion;
    cin >> opcion;


    if (opcion == "instruciones"|| "instruciones "){
        system("cls");
        printf("instruciones");
    }
    if (opcion == "inicio" || "inicio"){
        system("cls");
        void entrada(int&, int&, int&, int&, int&, int&);
    }
}

void entrada(int& va1, int& va2, int& va3, int& va4, int& r1, int& r2){
    // ecuacion 1
    menu();
    cout<<"va1: ",cin >> va1; // variable 1
    if (va1!=va1<0) int va1 = -(va1); // si la variable es negativa 
    if (va1||-(va1)>0){ // si va1 es mayor a 0 entonces pedir el siguiente valor y asi sucesivamente
    	system("cls");
        menu(); // variable 2
        cout <<"va1: "<< va1<< "  ", cout<< "va2: ",cin >> va2;
        if(va2!=va2<0) int va2 = -(va2); // si la variable es negativa
        if (va1||-(va1)&&va2||-(va2)>0){
        	system("cls");
        	menu(); // resultado 1
        	cout <<"va1: "<< va1<< "  ", cout<< "va2: "<<va2<< "  ", cout<<"r1: ", cin >> r1;
        	if(r1 != r1<0) int r1 = -(r1);

        	/* ecuacion 2 */
        	if (va1||-(va1)&&va2||-(va2)&&r1||-(r1) > 0) {
        		system("cls");
        		menu();
        		cout <<"va1: "<< va1<< "  ", cout<< "va2: "<<va2<< "  ", cout<<"r1: " , cout <<r1 << endl;
        		cout <<"va3: ", cin >> va3;
        		if (va3 != va3<0) int va3 = -(va3);

        		if (va1||-(va1)&&va2||-(va2)&&r1||-(r1)&&va3||-(va3) > 0){
        			system("cls");
        			menu();
        			cout <<"va1: "<< va1<< "  ", cout<< "va2: "<<va2<< "  ", cout<<"r1: " , cout <<r1 << endl;
                    cout <<"va3: "<< va3<< "  ", cout<< "va4: " , cin>>va4 ;
                    if(va4 != va4<0) int va4 = -(va4);

                    if (va1||-(va1)&&va2||-(va2)&&r1||-(r1)&&va3||-(va3)&&va4||-(va4) > 0){
                    	system("cls");
                    	menu();
        				cout <<"va1: "<< va1<< "  ", cout<< "va2: "<<va2<< "  ", cout<<"r1: " , cout <<r1 << endl;
                    	cout <<"va3: "<< va3<< "  ", cout<< "va4: "<<va4<< "  ", cout<<"r2: " , cin>>r2;
                    	if(r2 != r2<0) int r2 = -(r2);

                	}
				}
    		}
    	}
    }
}


void funcion(int& va1, int& va2, int& va3, int& va4, int& r1, int& r2){ // aqui ira la operacion

	// rectificadores
	bool opt1 = 0; // comprobante con la ecuacion 1

	int determinante_S = (va1*va4)-(va2*va3);
	int determinante_X = (r1*va4)-(r2*va2);
	int determinante_Y = (va1*r2)-(r1*va3);

	int x = determinante_X/determinante_S;
	int y = determinante_Y/determinante_S;

	if (va1*x + va2*y == r1){
		opt1 = 1;
	}else{
		opt1 = 0;
	}

	if (opt1 == 1){
		cout<<"true"<< endl<< "x = " << x << endl <<"y = "<< y<< endl;
	}else{
		cout<<"false";
	}
	printf("\n ir a inicio? (y/n)");
	string fin;
	cin>>fin;
	if(fin =="y"||"y "){
		main();
	}
	if (fin == "n"||"n "){ 
		system("exit");
	}

}
