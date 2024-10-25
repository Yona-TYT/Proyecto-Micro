;Rotar texto + cambio entre lineas con LCD

indf		equ			1h
pc		equ			2h
status	equ			3h

fsr		equ			4h		
prta		equ			5h
prtb		equ			6h
r0c		equ			0ch
r0d		equ			0dh
r13		equ			13h
contt	equ			25h
con0		equ			26h
con1		equ			27h
band	equ			28h
z			equ			2h
c			equ			0h
w			equ			1h
e			equ			1h
rs			equ			0h

;----------------------------------------------------------------------------------------------------

			org			00
			goto		inicio
			org			05h

;----------------------------------------------------------------------------------------------------

retardo2
				movlw		04h
				movwf		20h
ret3			movlw		60h
				movwf		21h
ret2			movlw		90h
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
				retlw		"R"
				retlw		"o"
				retlw		"t"
				retlw		"a"
				retlw		"n"
				retlw		"d"
				retlw		"o"
				retlw		" "
				retlw		"t"
				retlw		"e"
				retlw		"x"
				retlw		"t"
				retlw		"o"
				retlw		0

				
;--------------------------------------------------------------------------------------------------------------------
;								Config de puertos
;--------------------------------------------------------------------------------------------------------------------

inicio	bsf			03h,5	
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
				movlw		06h				;Seleccoina el modo de desplazamiento (desplazar 0ff)
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

				incf			r0c,1						;Sigue con el proximo caracter del  mensaje
				movlw		.12							;Numero de caracteres
				xorwf		r0c,0						;Pregunta si termino el mensaje
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
				incf			r0c,1						;Sigue con el proximo caracter del  mensaje
				movlw		.15							;Numero de caracteres
				xorwf		r0c,0						;Pregunta si termino el mensaje
				btfss		status,2
				goto			clc1
				
;--------------------------------------------------------------------------------------------------------------------
;								Boton de iniciar
;--------------------------------------------------------------------------------------------------------------------

clcb0		btfsc		09h,2
				goto			slr0
				goto			clcb0
slr0
				btfsc		09h,2
				goto			slr0
				
;-------------------------------------------------------------------------------------------------------------------
slr1
				movlw		01h
				call			control
				movlw		02h
				call			control			
clcb1		
			
;------------------------- Se hace efectivo el cambiar de linea ------------------------------------------------

				btfsc		09h,1
				goto			l2
				movlw		01h
				movwf		band
				movlw		0x90
				call			control
				goto			slr2
l2			
				movlw		02h
				movwf		band
				movlw		0xd0
				call			control
slr2	

;-----------------------------------------------------------------------------------------------------------------------		
				
				movlw		00h							;Inicia el envio de caracteres al 				
				movwf		r0c							;modulo														
clc2

;------------------- Escanea pin1 del puerto E para cambiar de linea -----------------------------------
				btfss		09h,1
				movlw		01h							;Si es cero (boton no precionado)
				btfsc		09h,1
				movlw		02h							;Si es uno (boton  precionado)
				xorwf		band,0
				btfss		status,2
				goto			slr1
				
;----------------------- Escanea pin0 del puerto E para rotar --------------------------------------------

				btfsc		09h,0						;Escanea boton en el puerto E
				goto			rl
				movlw		0x18							;Desplaza haci la izquierda
				call			control	
				goto			salt1
rl
				movlw		0x1c							;Desplaza haci la Derecha
				call			control
salt1
							
;--------------------------------------------------------------------------------------------------------------------
;								Muestra "Rotando texto" en pantalla.	
;--------------------------------------------------------------------------------------------------------------------
				movlw		02h
				movwf		contt
				call			tabla							;Hacer barrido de la tabla
				call			dato

				incf			r0c,1							;Sigue con el proximo caracter del  mensaje
				call			retardo2
				movlw		.14								;Numero de caracteres
				xorwf		r0c,0							;Pregunta si termino el mensaje
				btfss		status,2
				goto			clc2						
				goto			clcb1	
		
				end
			