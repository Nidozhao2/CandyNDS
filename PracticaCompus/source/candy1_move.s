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

		add r0, r0, r4

		ldrb r4, [r0] 

		mov r9, #7  @; carreguem la mascara 
		and r4, r4, r9


		mov r8, #1  @; r8 tenim el contador de repetits, mínim 1


		@; per tant a r0 queda el valor de la posició (f,c)

		cmp r3, #1  @; comparem amb 1 per extreure el casos de orientació propis dels valors 0 i 1
		beq .Lsur
		blo .Leste
		cmp r3, #2 @; comparemb amb 2 per extreure el cas de 2(oest), en cas contrari tenim el 3 (nord)
		beq .Loeste
		
		.Lnorte:
		 


		cmp r1, #0
		beq .Lfi_cuenta
		mov r7, r1  @; r7 fila
		mov r5, #COLUMNS 
		rsb r5,r5,#0  @; r5 obté el offser per iteració 

		b .Lcuenta_rep

		.Leste:		



		mov r6, #COLUMNS-1


		sub r7, r6, r2 @;r7=numero de columnas menos columna actual
		cmp r7, #0
		beq .Lfi_cuenta 

		mov r5, #1 @; r5 obté el offser per iteració 


		b .Lcuenta_rep

		.Lsur:


		mov r6, #ROWS-1
		sub r7, r6, r1


		mov r5, #COLUMNS @; r5 obté el offser per iteració 
		b .Lcuenta_rep

		.Loeste:

		mov r7, r2
		cmp r2, #0
		beq .Lfi_cuenta	
		mov r5, #1  @; r5 obté el offser per iteració 	
		rsb r5,r5, #0
		
	
		.Lcuenta_rep:

		add r0, r0, r5
		ldrb r6, [r0]  @;el valor que estem comprovant es troba a r6


		and r6, r6, r9  @; apliquem la mascara que ens compara els 3 bits inferiors


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
		push {r1- r12, lr}
		mov r4, r0 @; conservem direcció de matriu de joc

		bl baja_verticales
		cmp r0, #0
		bleq baja_laterales

		
		pop {r1-r12, pc}



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
		push {r1-r12, lr}
		mov r6, #ROWS-1 @; index de row
		mov r7, #COLUMNS-1 @; index de column
		mov r0, #0

		.Lrecorregut_ver:

			mov r3, #COLUMNS	
			mul r10, r6, r3		@; r10 = N_columns * index_row
			add r10, r7			@; r10 = r10 + index_col
			add r3, r4, r10
			ldrb r3, [r3]

			mov r2, r6 @; r2 és l'iterador de les files per damunt
			mov r1, r10 @; conservem el offset a altre registre per manipular-lo després

			and r12, r3, #0x07
			cmp r12, #0	@; només moguem si la casella es buida
			bne .Lfi_bucle_vertical

			.Lbucle_vertical:
				cmp r2, #0
				beq .Lrandom
				sub r2, #1
				sub r1, #COLUMNS

				ldrb r11, [r4, r1]
				and r12, r11, #0x0f
				cmp r12, #0x0f @; ignoramos huecos
				beq .Lbucle_vertical
				cmp r12, #7	
				beq .Lfi_bucle_vertical
				and r12, r11, #0x07
				cmp r12, #0
				beq .Lfi_bucle_vertical

				mov r3, r3, lsr #3
				cmp r3, #1
				addeq r12, #8
				cmp r3, #2
				addeq r12, #16
				strb r12, [r4, r10]
				mov r0, #1

				mov r12, r11, lsr #3
				cmp r12, #1
				moveq r12, #8
				cmp r12, #2
				moveq r12, #16

				strb r12, [r4, r1]
				b .Lrecorregut_ver

				.Lrandom:

					ldrb r11, [r4, r1]
					
					and r12, r11, #0x07
					cmp r12, #7
					moveq r12, #0
					beq .Lgenerar_caramel_vertical

					mov r12, r11, lsr #3
					cmp r12, #2
					moveq r12, #16
					cmpne r12, #1
					moveq r12, #8
					movne r12, #0

					.Lgenerar_caramel_vertical:
					mov r0, #6
					bl mod_random
					add r0, #1

					add r0, r12
					strb r0, [r4, r10]
					mov r0, #1

			.Lfi_bucle_vertical:
				cmp r7, #0
				subhi r7, #1
				subeq r6, #1
				moveq r7, #COLUMNS-1
				cmpeq r6, #0
				bge .Lrecorregut_ver
				blo .Lfi_ver

		.Lfi_ver:
		
		pop {r1-r12, pc}


@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 indica que no ha
@;				movido nada 
baja_laterales:
		push {r1-r12, lr}
		
		mov r6, #ROWS-1 @; index de row
		mov r7, #COLUMNS-1 @; index de column
		mov r0, #0

		.Lrecorregut_lat:
			mov r3, #COLUMNS	
			mul r10, r6, r3		@; r10 = N_columns * index_row
			add r10, r7			@; r10 = r10 + index_col
			ldrb r3, [r4, r10]

			mov r1, r10 @; conservem el offset a altre registre per manipular-lo després

			and r5, r3, #0x07 @; si no es 0, ignorem
			cmp r5, #0
			bne .Lfi_bucle_lat

			sub r1, #COLUMNS
			ldrb r2, [r4, r1]
			cmp r2, #7		@; si el imediatament superior és sòlid continuem
			beq .LcheckDiagonals

			and r2, #0x07
			cmp r2, #0
			beq .LcheckDiagonals	@; si el inmediataments superior es buit també continuem
			bne .Lfi_bucle_lat

			.LcheckDiagonals:
				mov r11, #0 	@; r11 es el codi que diu si adalt-dreta/adalt-esquerra o els dos son vàlids

				sub r1, #1	@; agafem el de adalt a la esquerra
				ldrb r5, [r4, r1]
				add r1, #2 @; agafem el de adalt a la dreta
				ldrb r9, [r4, r1]

				and r12, r5, #0x07
				cmp r12, #7
				cmpne r12, #0
				addne r11, #1	@; r11=1 adalt-esquerra es vàlid

				sub r1, #1 @; retornem r1 a la posició inmediatament superior
				
				cmp r11, #1
				cmpeq r7, #COLUMNS-1 @; si adalt-esquerra es vàlid i index_col == COLUMNS-1, baixem d'esquerra
				beq .LbaixarEsquerra

				and r12, r9, #0x07
				cmp r12, #7
				cmpne r12, #0
				addne r11, #2	@; r11=2 adalt-dreta es vàlid
				cmp r11, #2
				cmpeq r7, #0	@; si adalt-dreta es vàlid i index_col == 0, baixem de dreta
				beq .LbaixarDreta

				
				cmp r11, #0
				beq .Lfi_bucle_lat	@; si cap es vàlid seguent iteració
				cmp r11, #1
				beq .LbaixarEsquerra
				cmp r11, #2
				beq .LbaixarDreta
				cmp r11, #3
				beq .LbaixaRandom


			.LbaixarEsquerra:
				push {r3,r6, r7}

				sub r1, #1 @; posició adalt-esquerra
				mov r7, r3, lsr #3
				mov r6, r5, lsr #3
				and r2, r5, #0x07

				cmp r7, #1
				addeq r2, #8
				cmp r7, #2
				addeq r2, #16
				strb r2, [r4, r10]

				cmp r6, #1
				moveq r8, #8
				cmp r6, #2
				moveq r8, #16
				cmp r6, #0
				moveq r8, #0
				strb r8, [r4, r1]

				mov r0, #1
				pop {r3,r6, r7}
				b .Lfi_bucle_lat

			.LbaixarDreta:
				push {r3,r6, r7}
				
				add r1, #1
				mov r7, r3, lsr #3
				mov r6, r9, lsr #3
				and r2, r9, #0x07

				cmp r7, #1
				addeq r2, #8
				cmp r7, #2
				addeq r2, #16
				strb r2, [r4, r10]

				cmp r6, #1
				moveq r8, #8
				cmp r6, #2
				moveq r8, #16
				cmp r6, #0
				moveq r8, #0
				strb r8, [r4, r1]
				mov r0, #1
				pop {r3,r6, r7}
				b .Lfi_bucle_lat

			.LbaixaRandom:
				mov r0, #2
				bl mod_random
				cmp r0, #1
				beq .LbaixarDreta
				bne .LbaixarEsquerra

			.Lfi_bucle_lat:
			cmp r7, #0
			subhi r7, #1
			subeq r6, #1
			moveq r7, #COLUMNS-1
			cmpeq r6, #1
			bge .Lrecorregut_lat
			blo .Lfi_lat

		.Lfi_lat:
		
		pop {r1-r12, pc}


.end
