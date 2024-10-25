;Contador con LCD @Yona-TYT

indf		equ			1h
pc			equ			2h
status	equ			3h

fsr		equ			4h		;Seleccion de bacos de memoria y registros
prta		equ			5h
prtb		equ			6h
r0c		equ			0ch
r0d		equ			0dh
r13		equ			13h
contt		equ			25h
con0		equ			26h
con1		equ			27h
z			equ			2h
c			equ			0h
w			equ			1h
e			equ			1h
rs			equ			0h

			org			00
			goto		inicio
			org			05h

retardo2
				movlw		05h
				movwf		20h
ret3			movlw		82h
				movwf		21h
ret2			movlw		0ffh
				movwf		22h
ret1			decfsz		22h
				goto			ret1
				decfsz		21h
				goto			ret2
				decfsz		20h
				goto			ret3
				clrf			r13
				goto			decre
retardo
				movlw		0ffh
				movwf		r13
decre		decfsz		r13,1
				goto			decre
				retlw		0

;--------------------------------------------------------------------------------------

control		bcf			prta,0		;Esta rutina genera las señales de control
												;y entrega el dato correspondiente al
				goto			dato2		;modulo
dato			bsf			prta,0		;Utiliza interfaz a 8 bits
dato2		bsf			prta,e
				movwf		prtb
				call			retardo
				bcf			prta,e
				call			retardo
				retlw		0
				
;--------------------------------------------------------------------------------------------------------------------
;								Todas las tablas en una subrutina
;--------------------------------------------------------------------------------------------------------------------

tabla			movf			contt,0
				addwf		pc,1
				goto			tbl0
				goto			tbl1
				goto			tbl2
				goto			tbl3
				goto			tbl4
				goto			tbl5
				goto			tbl6

tbl0
				movf			r0c,0	
				addwf		02h,1
				retlw		"P"
				retlw		"u"
				retlw		"l"
				retlw		"s"
				retlw		"a"
				retlw		"r"
				retlw		" "
				retlw		"B"
				retlw		"o"
				retlw		"t"
				retlw		"o"
				retlw		"n"
				retlw		0
tbl1
				movf			r0c,0	
				addwf		02h,1
				retlw		"P"
				retlw		"a"
				retlw		"r"
				retlw		"a"
				retlw		" "
				retlw		"C"
				retlw		"o"
				retlw		"n"
				retlw		"t"
				retlw		"i"
				retlw		"n"
				retlw		"u"
				retlw		"a"
				retlw		"r"
				retlw		0		
tbl2
				movf			r0c,0	
				addwf		02h,1
				retlw		"C"
				retlw		"o"
				retlw		"n"
				retlw		"t"
				retlw		"a"
				retlw		"d"
				retlw		"o"
				retlw		"r"
				retlw		0
tbl3
				movf			con1,0	
				addwf		02h,1
				retlw		"0"
				retlw		"1"
				retlw		"2"
				retlw		"3"
				retlw		"4"
				retlw		"5"
				retlw		"6"
				retlw		"7"
				retlw		"8"
				retlw		"9"
				retlw		0	
tbl4
				movf			con0,0	
				addwf		02h,1
				retlw		"0"
				retlw		"1"
				retlw		"2"
				retlw		"3"
				retlw		"4"
				retlw		"5"
				retlw		"6"
				retlw		"7"
				retlw		"8"
				retlw		"9"
				retlw		0	
tbl5
				retlw		0
tbl6
				retlw		0
				
;--------------------------------------------------------------------------------------------------------------------
;								Config de puertos
;--------------------------------------------------------------------------------------------------------------------

inicio		bsf			03h,5	
			movlw		0fch
			movwf		prta
			movlw		00h
			movwf		prtb
			movlw		07h
			movwf		09h
			movlw		86h
			movwf		1fh
			bcf			03h,5
			
;--------------------------------------------------------------------------------------------------------------------
;								Config de la LCD
;--------------------------------------------------------------------------------------------------------------------

			
begin		movlw		3ch				;Inicia display	a 8 bits y 1 linea
				call			control
				movlw		06h				;Seleccoina el modo de desplazamiento
				call			control
				movlw		0ch				;Activa display
				call			control		

;--------------------------------------------------------------------------------------------------------------------
;								Muestra "Pulsar Boton" en pantalla.	
;--------------------------------------------------------------------------------------------------------------------

				movlw		0x82							;Para alinera el texto (fila 1, columna 3)
				call			control
				movlw		00h							;Inicia el envio de caracteres al 				
				movwf		r0c							;modulo														
clc0	
				movlw		00h
				movwf		contt
				call			tabla							;Hacer barrido de la tabla
				call			dato

				incf			r0c,1							;Sigue con el proximo caracter del  mensaje
				movlw		.12							;Numero de caracteres
				xorwf		r0c,0							;Pregunta si termino el mensaje
				btfss		status,2
				goto			clc0

;--------------------------------------------------------------------------------------------------------------------
;								Muestra "Para Continuar" en pantalla.	
;--------------------------------------------------------------------------------------------------------------------

				movlw		0xc1							;Para alinera el texto (fila 2, columna 1)
				call			control
				movlw		00h							;Inicia el envio de caracteres al 				
				movwf		r0c							;modulo														
clc1	
				movlw		01h
				movwf		contt
				call			tabla							;Hacer barrido de la tabla
				call			dato

				incf			r0c,1							;Sigue con el proximo caracter del  mensaje
				movlw		.15							;Numero de caracteres
				xorwf		r0c,0							;Pregunta si termino el mensaje
				btfss			status,2
				goto			clc1
				
;--------------------------------------------------------------------------------------------------------------------
;								Boton de iniciar
;--------------------------------------------------------------------------------------------------------------------

clcb0			btfsc			09h,0
				goto			slr0
				goto			clcb0
slr0
				btfss			09h,0
				goto			slr1
				goto			slr0
				
slr1
				movlw		01h
				call		control
				movlw		00h
				call		control
				
;--------------------------------------------------------------------------------------------------------------------
;								Muestra "Contador" en pantalla.	
;--------------------------------------------------------------------------------------------------------------------

				movlw		0xc3							;Para alinera el texto (fila 2, columna 3)
				call			control
				
				movlw		00h							;Inicia el envio de caracteres al 				
				movwf		r0c							;modulo														
clc2
				movlw		02h
				movwf		contt
				call			tabla							;Hacer barrido de la tabla
				call			dato

				incf			r0c,1							;Sigue con el proximo caracter del  mensaje
				movlw		.8								;Numero de caracteres
				xorwf		r0c,0							;Pregunta si termino el mensaje
				btfss			status,2
				goto			clc2

;--------------------------------------------------------------------------------------------------------------------
;								Inicia el contador de 0 a 99 (En teoria XD).
;--------------------------------------------------------------------------------------------------------------------

				movlw		00h
				movwf		con1				
				movlw		01h
				movwf		con0
				
clcb1			btfsc			09h,0
				goto			salir
				goto			clcb1
salir		
				movlw		0x86							;Para alinera el texto (fila 1, columna 6)
				call			control
				
				movlw		03h
				movwf		contt
				call			tabla							;Hacer barrido de la tabla
				call			dato
				
				movlw		04h
				movwf		contt
				call			tabla							;Hacer barrido de la tabla
				call			dato

				incf			con0						
				movlw		.10							; Valor maximo 9
				xorwf		con0,0						;Pregunta si con0 llego a 10
				btfsc			status,2
				clrf			con0				
				btfsc			status,2
				incf			con1
							
clcb2			btfss			09h,0
				goto			clcb1	
				goto			clcb2
			
				end
			
