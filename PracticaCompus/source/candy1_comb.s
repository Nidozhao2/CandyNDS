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
		push {lr}
		

		
		pop {pc}




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
		push {lr}
		
		
		pop {pc}



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
