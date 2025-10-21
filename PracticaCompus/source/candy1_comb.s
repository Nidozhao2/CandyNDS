@;=                                                               		=
@;=== candy1_comb.s: rutinas para detectar y sugerir combinaciones    ===
@;=                                                               		=
@;=== Programador tarea 1G: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 1H: yyy.yyy@estudiants.urv.cat				  ===
@;=                                                             	 	=



.include "candy1_incl.i"


@; .bss 
@;	.align 2
@;	vec_posi: .space 6 @;6 hwords

@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1G;
@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
@;	combinación entre dos elementos (diferentes) consecutivos que provoquen
@;	una secuencia válida, incluyendo elementos con gelatinas simples y dobles.
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_combinacion
hay_combinacion:
		push {r1-r12,lr}
		
		mov r7, r0
		mov r8, #0
		mov r9, #0
		
	.Lrecoregut:
		mov r5, #0x07
		mov r11 , r9
		mov r10 , #COLUMNS
		mul r11, r10
		mov r10, r11
		add r10, r8
		ldrb r4, [r7, r10]
		mov r3, r4
		and r3, r5
		cmp r3, #0 		@;buit
		beq .LSeguentPosi
		cmp r3, #7		@;solido, hueco
		beq .LSeguentPosi
	@; entrem a comprovar la fila
		mov r6, #COLUMNS-1 @;la penultima
		cmp r8, r6 
		beq .LcomprovaROWS
		add r10, #1
		ldrb r6, [r7, r10]
		sub r10, #1
		mov r3, r6	
		and r3, r5
		cmp r3, #0 		@;buit
		beq .LcomprovaROWS

		cmp r3, #7		@;solido, hueco
		beq .LcomprovaROWS

		mov r2, r4
		and r2, r5
		cmp r3, R2
		beq .LcomprovaROWS

		add r10, #1
		strb r4, [r7, r10] @;+1
		sub r10, #1
		strb r6, [r7, r10] @;0
		mov r0, r7
		bl hay_secuencia
		strb r4, [r7, r10] @;0
		add r10, #1
		strb r6, [r7, r10] @;+1
		sub r10, #1
		cmp r0, #1
		beq .Fi


	.LcomprovaROWS:
		mov r6, #ROWS-1 @; anterior a la penultima
		cmp r9, r6
		beq .LSeguentPosi

		mov r11, #COLUMNS
		add r10, r11
		ldrb r6, [r7, r10]
		sub r10, r11
		mov r3, r6	
		and r3, r5
		cmp r3, #0 		@;buit
		beq .LSeguentPosi

		cmp r3, #7		@;solido, hueco
		beq .LSeguentPosi

		mov r2, r4
		and r2, r5
		cmp r3, R2
		beq .LSeguentPosi

		add r10, r11
		strb r4, [r7, r10]
		sub r10, r11
		strb r6, [r7, r10]
		mov r0, r7
		bl hay_secuencia
		strb r4, [r7, r10]
		add r10, r11
		strb r6, [r7, r10]
		sub r10, r11
		cmp r0, #1
		beq .Fi

	.LSeguentPosi:
		cmp r8, #COLUMNS-1
		addlo r8, #1
		addeq r9, #1
		moveq r8, #0
		cmpeq r9, #ROWS
		blo .Lrecoregut
		moveq r0, #0
		beq .Fi

		
	.Fi:
		pop {r1-r12,pc}



@;TAREA 1H;
@; sugiere_combinacion(*matriz, *psug): rutina para detectar una combinación
@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
@;	válida, incluyendo elementos con gelatinas simples y dobles, y devolver
@;	las coordenadas de las tres posiciones de la combinación (por referencia).
@;	Restricciones:
@;		* se asume que existe por lo menos una combinación en la matriz
@;			 (se puede verificar con la rutina hay_combinacion() antes de
@;			  llamar a esta rutina)
@;		* la combinación sugerida tiene que ser escogida aleatoriamente de
@;			 entre todas las posibles, es decir, no tiene que ser siempre
@;			 la primera empezando por el principio de la matriz (o por el final)
@;		* para obtener posiciones aleatorias, se invocará la rutina mod_random()
@;			 (ver fichero 'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección del vector de posiciones (unsigned char *), donde se
@;				guardarán las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
	.global sugiere_combinacion
sugiere_combinacion:
		push {r2-r10, lr}
		mov r7, r0	@;r7 es la matriu
		mov r8, r1	@;r8 es el vector de posicions
		
		mov r0, #ROWS	@;Calculem fila i columna aleatoria
		bl mod_random
		mov r1, r0	
		mov r0, #COLUMNS
		bl mod_random
		mov r2, r0

		.Linici:
		mov r3, #COLUMNS
		mul r3, r1
		add r3, r2	@;r3 es l'offset
		ldrb r4, [r7, r3] @;r4 es el valor de la llaminadura a la posicio aleatoria
		mov r5, r4
		and r5, #0x07
		cmp r5, #0				@;comprovem que no sigui ni buit ni un bloc solid, etc
		beq .LSeguentPosicio
		cmp r5, #7
		beq .LSeguentPosicio
	
		cmp r2, #0
		beq .Lderechagen

		@;si no està al limit per la dreta, comprovem el moviment de l'esquerra
		@;ESQUERRA
		ldrb r4, [r7, r3]
		sub r3, #1
		ldrb r5, [r7, r3] @;r5 es la llaminatura que es mou involuntariament
		mov r6, r5
		and r6, #0x07
		cmp r6, #7		@;comprovem que no sigui bloc solid ni buit
		addeq r3, #1
		beq .Lderechagen
		mov r9, r4
		and r9, #0x07
		cmp r9, r6
		beq .Lderechagen

		

		strb r4, [r7, r3]
		add r3, #1
		strb r5, [r7, r3]
		
		mov r4, r7
		sub r2, #1
		bl detecta_orientacion
		add r2, #1
		@;retornem la matriu a com estava
		ldrb r5, [r7, r3]
		sub r3, #1
		ldrb r4, [r7, r3]
		strb r5, [r7, r3]
		add r3, #1
		strb r4, [r7, r3]

		cmp r0, #6		@;si no ha trobat cap orientacio vàlida, passa
		beq .Lderechagen

		mov r9, r0 @;r9 es ori
		mov r10, #0 @;r10 es cpi
		b .Lcridagenerapos


		@;DRETA
		.Lderechagen:
		cmp r2, #COLUMNS-1	@;comprovem que no estigui al limit
		beq .Larribagen
		ldrb r4, [r7, r3]
		add r3, #1
		ldrb r5, [r7, r3] @;r5 es la llaminadura que es mou involuntariament
		mov r6, r5
		and r6, #0x07
		cmp r6, #7
		subeq r3, #1
		beq .Larribagen
		mov r9, r4
		and r9, #0x07
		cmp r9, r6
		beq .Larribagen


		
		strb r4, [r7, r3]
		sub r3, #1
		strb r5, [r7, r3]
		
		mov r4, r7
		add r2, #1
		bl detecta_orientacion
		sub r2, #1
		@;retornem la matriu a com estava
		ldrb r5, [r7, r3]
		add r3, #1
		ldrb r4, [r7, r3]
		strb r5, [r7, r3]
		sub r3, #1
		strb r4, [r7, r3]

		cmp r0, #6			@;Si no ha trobat cap direccio valida, seguent
		beq .Larribagen
		mov r9, r0 @;ori
		mov r10, #1 @;cpi
		b .Lcridagenerapos


		@;ADALT
		.Larribagen:
		cmp r1, #0
		beq .Labajogen
		ldrb r4, [r7, r3]
		sub r3, #COLUMNS
		ldrb r5, [r7, r3]
		mov r6, r5
		and r6, #0x07	@;comprovem que no sigui solid ni buit
		cmp r6, #7
		addeq r3, #COLUMNS
		beq .Labajogen
		mov r9, r4
		and r9, #0x07
		cmp r9, r6
		beq .Labajogen



		strb r4, [r7, r3]
		add r3, #COLUMNS
		strb r5, [r7, r3]

		mov r4, r7
		sub r1, #1
		bl detecta_orientacion
		add r1, #1
		@;retornem la matriu a com estava
		ldrb r5, [r7, r3]
		sub r3, #COLUMNS
		ldrb r4, [r7, r3]
		strb r5, [r7, r3]
		add r3, #COLUMNS
		strb r4, [r7, r3]

		cmp r0, #6
		beq .Labajogen
		mov r9, r0 @;ori
		mov r10, #2 @;cpi
		b .Lcridagenerapos

		@;ABAIX
		.Labajogen:
		cmp r1, #ROWS-1
		beq .LSeguentPosicio
		ldrb r4, [r7, r3]
		add r3, #COLUMNS
		ldrb r5, [r7, r3]
		mov r6, r5
		and r6, #0x07	@;comprovem que no sigui solid ni buit
		cmp r6, #7
		subeq r3, #COLUMNS
		beq .LSeguentPosicio
		mov r9, r4
		and r9, #0x07
		cmp r9, r6
		beq .LSeguentPosicio


		
		strb r4, [r7, r3]
		sub r3, #COLUMNS
		strb r5, [r7, r3]

		mov r4, r7
		add r1, #1
		bl detecta_orientacion
		sub r1, #1
		@;retornem la matriu a com estava
		ldrb r5, [r7, r3]
		add r3, #COLUMNS
		ldrb r4, [r7, r3]
		strb r5, [r7, r3]
		sub r3, #COLUMNS
		strb r4, [r7, r3]

		cmp r0, #6
		beq .LSeguentPosicio
		mov r9, r0 @;ori
		mov r10, #3 @;cpi
		b .Lcridagenerapos

		.LSeguentPosicio:
		cmp r2, #COLUMNS-1
		bne .LNofinalcol	@;si no s'ha arriba al final de la fila, seguir
		cmp r1, #ROWS-1	@;si ha arribat al final, reiniciar el recorregut
		moveq r2, #0
		moveq r1, #0
		beq .Linici
		mov r2, #0
		add r1, #1
		b .Linici
		.LNofinalcol:
		add r2, #1
		b .Linici


		.Lcridagenerapos:
		@;r9 es ori
		@;r10 es cpi
		@;r1 es fila
		@;r2 es columna
		@;r8 es el vect
		mov r0, r8
		mov r3, r9
		mov r4, r10
		bl genera_posiciones

		
		pop {r2-r10,pc}




@;:::RUTINAS DE SOPORTE:::

@; genera_posiciones(vect_pos, f, c, ori, cpi): genera las posiciones de 
@;	sugerencia de combinación, a partir de la posición inicial (f,c), el código
@;	de orientación ori y el código de posición inicial cpi, dejando las
@;	coordenadas en el vector vect_pos[].
@;	Restricciones:
@;		* se asume que la posición y orientación pasadas por parámetro se
@;			corresponden con una disposición de posiciones dentro de los
@;			límites de la matriz de juego
@;	Parámetros:
@;		R0 = dirección del vector de posiciones vect_pos[]
@;		R1 = fila inicial f
@;		R2 = columna inicial c
@;		R3 = código de orientación ori:
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = código de posición inicial cpi:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
genera_posiciones:
		push {r5-r6,lr}
		mov r6, r0
		strb r2, [r6]	@;x1
		add r6, #1
		strb r1, [r6]	@;y1
		add r6, #1 @;ara r6 esta la direccio de x2
		cmp r4, #1
		blo .Lizquierda
		beq .Lderecha
		cmp r4, #3
		blo .Larriba
		beq .Labajo


		.Lizquierda: @; si es izquierda tienes que hacer columna-1
			sub r2, r2, #1
			b .Lori
		.Lderecha: @; si es derecha """""" columna+1
			add r2, r2, #1
			b .Lori
		.Larriba: @; si es arriba """" fila -1
			sub r1, r1, #1
			b .Lori
		.Labajo: @; si es abajo """" fila +1
			add r1, r1, #1
			

		.Lori:
		@;r6 segueix estant la direccio de x2

		cmp r3, #1
		blo .Leste
		beq .Lsur
		cmp r3, #3
		blo .Loeste
		beq .Lnorte
		cmp r3, #4
		beq .Lhorizontal
		
		@;sino el vertical

		.Lvertical:

		strb r2, [r6]
		add r6, #1
		add r1, #1
		strb r1,[r6]
		add r6, #1
		strb r2, [r6]
		add r6, #1
		sub r1, #2
		strb r1,[r6]
		b .Lend



		.Leste:
		add r2, #1
		strb r2,[r6]
		add r6, #1
		strb r1, [r6]

		add r2, #1
		add r6, #1
		strb r2,[r6]
		add r6, #1
		strb r1, [r6]
		b .Lend


		.Lsur:

		strb r2,[r6]
		add r6, #1
		add r1, #1
		strb r1, [r6]

		add r6, #1
		strb r2, [r6]
		add r6, #1
		add r1, #1
		strb r1, [r6]
		b .Lend



		.Loeste:

		sub r2, #1
		strb r2,[r6]
		add r6, #1
		strb r1, [r6]

		sub r2, #1
		add r6, #1
		strb r2,[r6]
		add r6, #1
		strb r1, [r6]
		b .Lend

		.Lnorte:

		strb r2,[r6]
		add r6, #1
		sub r1, #1
		strb r1, [r6]

		add r6, #1
		strb r2, [r6]
		add r6, #1
		sub r1, #1
		strb r1, [r6]
		b .Lend


		.Lhorizontal:

		add r2, #1
		strb r2, [r6]
		add r6, #1
		strb r1, [r6]
		add r6, #1
		sub r2, #2
		strb r2, [r6]
		add r6, #1
		strb r1,[r6]

		.Lend:
		
		pop {r5-r6,pc}



@; detecta_orientacion(f, c, mat): devuelve el código de la primera orientación
@;	en la que detecta una secuencia de 3 o más repeticiones del elemento de la
@;	matriz situado en la posición (f,c).
@;	Restricciones:
@;		* para proporcionar aleatoriedad a la detección de orientaciones en las
@;			que se detectan secuencias, se invocará la rutina mod_random()
@;			(ver fichero 'candy1_init.s')
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;		* solo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;	Parámetros:
@;		R1 = fila f
@;		R2 = columna c
@;		R4 = dirección base de la matriz
@;	Resultado:
@;		R0 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;				sin secuencia: 6 
detecta_orientacion:
		push {r3, r5, lr}
		
		mov r5, #0				@;R5 = índice bucle de orientaciones
		mov r0, #4
		bl mod_random
		mov r3, r0				@;R3 = orientación aleatoria (0..3)
	.Ldetori_for:
		mov r0, r4
		bl cuenta_repeticiones
		cmp r0, #1
		beq .Ldetori_cont		@;no hay inicio de secuencia
		cmp r0, #3
		bhs .Ldetori_fin		@;hay inicio de secuencia
		add r3, #2
		and r3, #3				@;R3 = salta dos orientaciones (módulo 4)
		mov r0, r4
		bl cuenta_repeticiones
		add r3, #2
		and r3, #3				@;restituye orientación (módulo 4)
		cmp r0, #1
		beq .Ldetori_cont		@;no hay continuación de secuencia
		tst r3, #1
		moveq r3, #4			@;detección secuencia horizontal
		beq .Ldetori_fin
	.Ldetori_vert:
		mov r3, #5				@;detección secuencia vertical
		b .Ldetori_fin
	.Ldetori_cont:
		add r3, #1
		and r3, #3				@;R3 = siguiente orientación (módulo 4)
		add r5, #1
		cmp r5, #4
		blo .Ldetori_for		@;repetir 4 veces
		
		mov r3, #6				@;marca de no encontrada
		
	.Ldetori_fin:
		mov r0, r3				@;devuelve orientación o marca de no encontrada
		
		pop {r3, r5, pc}


.end
