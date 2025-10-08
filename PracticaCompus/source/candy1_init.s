@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: yyy.yyy@estudiants.urv.cat				  ===
@;=                                                       	        	=



.include "candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS




@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global mapas[][][]) y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = número de mapa de configuración
	.global inicializa_matriz
inicializa_matriz:
		push {r0-r11,lr}			@;guardar registros utilizados + link register
		
		mov r7, r0 @;guarda la direccio base de la matriu de joc

		mov r0, #COLUMNS
		mov r2, #ROWS
		mul r0, r2, r0

		mul r5, r0, r1 @; offset del mapa que juguem

		ldr r4,=mapas @; direccio on comença la configuracio de mapes

		mov r8, #0 @; offset per la direccio base de la matriu

		mov r1, #0			@;R5 = contador de columna (inicialment 0)
		.lseguentfila:
		mov r2, #0			@;R4 = contador de filas(inicialment 0)		

		.lseguentcolumna:

		ldrb r6, [r4, r5] @;primer valor del mapa que volem jugar
		strb r6, [r7, r8]
		mov r9, r6 @; per no perdre el valor

		and r6, #MASK_GEL
		cmp r6, #0
		bne .Lseguent_iteracio_init



		.Lgenerar_caramel:   @; mejora necesaria: cambiarlo por mascaras

		
		mov r6, #3
		lsl r6, #3
		and r6, r9 @; guardem a r6 les marques de gelatines


		mov r0, #6 @; per a obtenir numero entre 0-5 
		bl mod_random
		add r0, r0, #1
		add r0, r6 @; li afegim la gelatina

		mov r10 , #0 @; contador de horizontales (este-oeste)
		mov r11, #0 @; contador verticales (norte-sur)






		
		strb r0, [r7,r8]
		mov r3, #2
		
		.Lcomprobar_repetits_init:

		mov r0, r7 @; movem a r0 la direccio de memoria
		bl cuenta_repeticiones
		
		cmp r3, #2
		addeq r3, #1
		addeq r10, r10, r0
		beq .Lcomprobar_repetits_init
		
		cmp r3, #3		
		addeq r11, r11, r0
		
		cmp r10, #3
		bhs .Lgenerar_caramel
		cmp r11, #3
		bhs .Lgenerar_caramel




		.Lseguent_iteracio_init:
	
		add r8, #1 @; movem un byte
		add r5, #1 @; movem un byte

		add r2, r2,#1
		cmp r2, #COLUMNS		@;comprobar si se han recorrido todas las columnas
		bne .lseguentcolumna
		add r1, r1 ,#1 
		cmp r1, #ROWS	@;comprobar si se han recorrido todas las filas
		bne .lseguentfila

		pop {r0-r11,pc}			@;recuperar registros y retornar al invocador

@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en mat_recomb1[][], para luego ir
@;	escogiendo elementos de forma aleatoria y colocándolos en mat_recomb2[][],
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina hay_combinacion() (ver fichero 'candy1_comb.s')
@;		* se puede asumir que siempre existirá una recombinación sin secuencias
@;			y con posibles combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
		push {r0-r12, lr}
		
		mov r7, r0 				@; conservem direcció base de memòria a r7

		@; Còpia de la matriu de joc 
		ldr r8, =mat_recomb1 	@; r1 = adreça de mat_recomb1[][]
		ldr r9, =mat_recomb2 	@; r2 = adreça de mat_recomb2[][]

		.Linici_recomb:
		mov r3, #0 @; r2 = index

		.Lcopia_matriu:
			ldrb r4, [r7, r3]  	@; r4 = element de la matriu base per copiar
			and r5, r4, #MASK_GEL	@; r5 = últims tres bits de l'element (element a copiar sense gelatines)
			cmp r5, #MASK_GEL
			moveq r5, #0 		@; si l'element és solid o buit es guarda un 0
			//cmpne r5, #0   no hace falta realment
			//moveq r5, #0		@; si el element vacio (0,8,16)
			strb r5, [r8, r3] 	@; guardem l'element a la matriu mat_recomb1[][]

			add r3, #1
			cmp r3, #ROWS*COLUMNS
			blo .Lcopia_matriu



		mov r10, #0 //offset total columna*fila+columna
		mov r1, #0 @; iterador fila
		.lb_seguentfila:
		mov r2, #0 @; iterador de columna
		.lb_seguentcolumna:
		
		mov r11, #25
		.Lrecombinacio:
			


			ldrb r4, [r7,r10]
			and r5, r4, #MASK_GEL

  
			//cmp r5, #0						                     
			//beq .Lseguent_iteracio_base
			cmp r5, #MASK_GEL        @; si l'element de la matriu base és buida, forat o sòlid ignorem
			beq .Leshueco

			mov r6, #3
			lsl r6, #3		@; en teoria reduntant r6 = codi de gelatina
			and r6, r6, r5



			.Lcasella_aleatoria:
				mov r0, #ROWS*COLUMNS
				
				bl mod_random
				mov r12, r0 @; per no perdre el offset de la posicio per posar a 0 mes endavant
				ldrb r4, [r8, r0] 	@; obtenir posició aleatòria de mat_recomb1[][]
				cmp r4, #0			

				beq .Lcasella_aleatoria @; torna a intentar si la posició conté un 0
			
			

			@; afegim el codi de la gelatina de la casella

			add r4, r6
			sub r11, #1		@; gastem un intent de recombinació
			cmp r11, #0

			beq .Linici_recomb @; tornem a començar de nou la recombinació si es supera els intents màxims

			



				



				.Lseguent_iteracio_base:	
				strb r4, [r9, r10]			


				.Lcomprobar_repetetits_recom:
						mov r0, r9
						mov r3, #2 @; pasem a r3 la orientació que volem que miri, oest i nord (2 i 3)
						bl cuenta_repeticiones
						
						cmp r0, #3
						bhs .Lrecombinacio	@; torna a intentar amb altre element si forma secuència
						mov r0, r9
						add r3, #1
						bl cuenta_repeticiones
						cmp r0, #3
						bhs .Lrecombinacio	@; torna a intentar amb altre element si forma secuència			
						
				.Leshueco:
				strb r4, [r9, r10]	
				mov r5, #0
				strb r5, [r8, r12]	@; fixem 0 a la posició visitada de mat_recomb1[][]


				add r2, #1
				add r10, #1
				cmp r2, #COLUMNS
				bne .lb_seguentcolumna

				add r1, #1
				cmp r1, #ROWS
				bne .lb_seguentfila
 
		@; Còpia de mat_recomb2[][] a r0
		mov r3, #0
		.Lcopia_final:
			ldrb r4, [r9, r3]
			strb r4, [r7, r3]
			add r3, #1
			cmp r3, #ROWS*COLUMNS
			blo .Lcopia_final

		pop {r0-r12, pc}



@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina random()
@;	Restricciones:
@;		* el parámetro n tiene que ser un natural entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r1,r2,lr}
		
		mov r1, r0 
		bl random @;numero de 32 bits random en r0

		mov r2, #0xff
		and r0, r0, r2
		 
		.lmod_random:

		cmp r0, r1
		
		subhs r0, r0, r1 @; r1-r0, bucle fins q r0<r1
		bhs .lmod_random

		pop {r1,r2,pc}



@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global seed32 (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de seed32 no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en seed32)
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable seed32
	ldr r1, [r0]				@;R1 = valor actual de seed32
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en seed32
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end

