@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 1D: yyy.yyy@estudiants.urv.cat				  ===
@;=                                                           		   	=



.include "candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
@; número de secuencia: se utiliza para generar números de secuencia únicos,
@;	(ver rutinas marcar_horizontales() y marcar_verticales()) 
	num_sec:	.space 1



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
.global hay_secuencia
hay_secuencia:
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

		mov r6, #COLUMNS-2 @; anterior a la penultima
		cmp r8, r6
		movlo r0, r7
		movlo r1, r9
		movlo r2, r8
		movlo r3, #0
		bllo cuenta_repeticiones
		cmp r0, #2
		bhi .Fi1	
		
		mov r6, #ROWS-2 @; anterior a la penultima
		cmp r9, r6
		movlo r0, r7
		movlo r1, r9
		movlo r2, r8
		movlo r3, #1
		bllo cuenta_repeticiones
		cmp r0, #2
		bhi .Fi1	

		.LSeguentPosi:
		cmp r8, #COLUMNS-1
		addlo r8, #1
		addeq r9, #1
		moveq r8, #0
		cmpeq r9, #ROWS
		blo .Lrecoregut
		moveq r0, #0
		beq .Fi

		.Fi1:
		mov r0, #1
		.Fi:
		pop {r1-r12,pc}


@;TAREA 1D;
@; elimina_secuencias(*matriz, *marcas): rutina para eliminar todas las
@;	secuencias de 3 o más elementos repetidos consecutivamente en horizontal,
@;	vertical o cruzados, así como para reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	además, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador único para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
	.global elimina_secuencias
elimina_secuencias:
		push {r2-r12, lr}
		mov r7, r0
		mov r5, r1
		mov r6, #0
		mov r8, #0				@;R8 es desplazamiento posiciones matriz
	.Lelisec_for0:
		strb r6, [r1, r8]		@;pone matriz de marcas a cero
		add r8, #1
		cmp r8, #ROWS*COLUMNS
		blo .Lelisec_for0
		
		bl marca_horizontales
		mov r0, r7
		mov r1, r5
		bl marca_verticales
		mov r0, r7
		mov r1, r5
		

@; ATENCIÓN: FALTA CÓDIGO PARA ELIMINAR SECUENCIAS MARCADAS Y GELATINAS

		mov r3, #0
		mov r5, #0
		mov r6, #8
		mov r7, #ROWS
		mov r4, #COLUMNS
		mul r7, r4

		.LDonaVoltes:
		ldrb r4, [r1, r3]
		cmp r4, #0
		beq .LSeguirVoltejant
		ldrb r4, [r0, r3]
		cmp r4, #16
		bhi .LStrhi
		strb r5, [r0, r3]
		b .LFiStrs
		.LStrhi:
		strb r6, [r0, r3]
		.LFiStrs:


		.LSeguirVoltejant:
		add r3, #1
		cmp r3, r7
		ble .LDonaVoltes



		pop {r2-r12, pc}


	
@;:::RUTINAS DE SOPORTE:::



@; marca_horizontales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en horizontal, con un número identifi-
@;	cativo diferente para cada secuencia, que empezará siempre por 1 y se irá
@;	incrementando para cada nueva secuencia, y cuyo último valor se guardará en
@;	la variable global num_sec; las marcas se guardarán en la matriz que se
@;	pasa por parámetro mat[][] (por referencia).
@;	Restricciones:
@;		* se supone que la matriz mat[][] está toda a ceros
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marca_horizontales:
		push {r2-r12, lr}
		
		mov r7 ,r0
		ldr r12, =num_sec
		ldrb r12, [r12]
		mov r8, #0  @;inicialitzem x i y
		mov r9, #0
		.LbucleHorizontal:
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
		beq .LSeguentPos
		cmp r3, #7		@;solido, hueco
		beq .LSeguentPos
		push {r1}
		mov r0, r7
		mov r1, r9
		mov r2, r8
		mov	r3, #0
		bl cuenta_repeticiones
		pop {r1}
		mov r5, #0
		cmp r0, #3
		blo .LSeguentPos
		add r12, #1
		.LBuclefor:
		strb r12, [r1, r10]
		add r10, #1
		add r5, #1
		cmp r5, r0
		blo .LBuclefor
		addeq r8, r0
		subeq r8, #1
		
		


		.LSeguentPos:
		cmp r8, #COLUMNS-1
		addlo r8, #1
		addeq r9, #1
		moveq r8, #0
		cmpeq r9, #ROWS
		blo .LbucleHorizontal
		beq .Lfinal

.Lfinal:
		pop {r2-r12, pc}



@; marca_verticales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en vertical, con un número identifi-
@;	cativo diferente para cada secuencia, que seguirá al último valor almacenado
@;	en la variable global num_sec; las marcas se guardarán en la matriz que se
@;	pasa por parámetro mat[][] (por referencia);
@;	sin embargo, habrá que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habrán
@;	almacenado en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz mat[][] está marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable num_sec contendrá el siguiente identificador (>=1)
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marca_verticales:
		push {r2-r12, lr}
		
		mov r7 ,r0
		ldr r12, =num_sec
		ldrb r12, [r12]
		mov r8, #0  @;inicialitzem x i y
		mov r9, #0
		.LbucleVertical:
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
		beq .LSeguentPosV
		cmp r3, #7		@;solido, hueco
		beq .LSeguentPosV
		push {r1}
		mov r0, r7
		mov r1, r9
		mov r2, r8
		mov	r3, #1
		bl cuenta_repeticiones
		pop {r1}

		mov r5, #0
		cmp r0, #3
		blo .LSeguentPosV

		mov r3, r10
		.LBucle1rrecorregut:
		ldrb r2, [r1, r3]
		cmp r2, #0
		bne .LAbansBucle
		add r3, #COLUMNS
		add r5, #1
		cmp r5, r0
		blo .LBucle1rrecorregut

		.LAbansBucle:
		mov r5, #0
		cmp r2, #0
		movne r3, r2
		addeq r12, #1
		moveq r3, r12
		.LBuclefor2:
		strb r3, [r1, r10]
		add r10, #COLUMNS
		add r5, #1
		cmp r5, r0
		blo .LBuclefor2
		
		


		.LSeguentPosV:
		cmp r8, #COLUMNS
		addlo r8, #1
		blo .LbucleVertical
		addeq r9, #1
		moveq r8, #0
		cmpeq r9, #ROWS-1
		blo .LbucleVertical
		beq .LfinalV

.LfinalV:
		ldr r7, =num_sec
		strb r12, [r7]
		pop {r2-r12, pc}



.end
