@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 1F: yyy.yyy@estudiants.urv.cat				  ===
@;=                                                         	      	=



.include "candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz, f, c, ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación ori.
@;	Restricciones:
@;		* solo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila f
@;		R2 = columna c
@;		R3 = orientación ori (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r1-r10,lr}

		mov r4, #COLUMNS
		mla r4, r1, r4, r2 

		ldrb r4, [r0, r4] 

		mov r8, #1  @; r8 tenim el contador de repetits, mínim 1


		@; per tant a r0 queda el valor de la posició (f,c)

		cmp r3, #1  @; comparem amb 1 per extreure el casos de orientació propis dels valors 0 i 1
		beq .Lsur
		blo .Leste
		cmp r3, #2 @; comparemb amb 2 per extreure el cas de 2(oest), en cas contrari tenim el 3 (nord)
		beq .Loeste
		
		.Lnorte:
		 


		
		mov r7, r1
		mov r5, #COLUMNS 
		rsb r5,r5,#0  @; r5 obté el offser per iteració 

		b .Lcuenta_rep

		.Leste:		


		mov r6, #COLUMNS-1
		sub r7, r6, r2

		mov r5, #1 @; r5 obté el offser per iteració 


		b .Lcuenta_rep

		.Lsur:


		mov r6, #ROWS-1
		sub r7, r6, r1


		mov r5, #COLUMNS @; r5 obté el offser per iteració 
		b .Lcuenta_rep

		.Loeste:

		mov r7, r2		
		rsb r5,r5, #0
		mov r5, #1  @; r5 obté el offser per iteració 
	
		.Lcuenta_rep:

		add r0, r0, r5
		ldrb r6, [r0]  @;el valor que estem comprovant es troba a r6

		mov r9, #7
		and r6, r6, r9

		cmp r6, r4
		addeq r8, #1
		bne .Lfi_cuenta

		
		sub r7,#1
		cmp r7, #0
		bne .Lcuenta_rep


		.Lfi_cuenta:
		mov r0, r8 @; finalment retornem el resultat per r0


		pop {r1-r10,pc}


@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en diagonal; cada llamada a la función
@;	baja múltiples elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si no se ha movido ningún elemento.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina mod_random() (ver fichero
@;			'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que pueden
@;				quedar movimientos pendientes; 0 indica que no ha movido nada 
	.global baja_elementos
baja_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 indica que no ha
@;				movido nada  
baja_verticales:
		push {lr}
		
		
		pop {pc}


@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 indica que no ha
@;				movido nada 
baja_laterales:
		push {lr}
		
		
		pop {pc}


.end
