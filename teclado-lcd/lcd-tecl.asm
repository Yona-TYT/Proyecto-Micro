

;====================================================================
; DEFINITIONS
;====================================================================

#include p16f877.inc                ; Include register definition file

;====================================================================
; VARIABLES
;====================================================================
teclas			equ			0x25
filas				equ			0x26			;No se usa.
rota				equ			0x27
cont				equ			0x28
vlo				equ			0x29

cont0			equ			0x20
cont1			equ			0x21
cont2			equ			0x22


;====================================================================
;				 RESET and INTERRUPT VECTORS
;====================================================================
	org			00
	goto			inicio
	org			05

;====================================================================
; 				Config de puertos
;====================================================================

inicio
					bsf				0x03,5
					bcf				0x03,6
					movlw			0x00
					movwf			0x06
					movwf			0x07
					movwf			0x08
					movlw			0x04
					movwf			0x09
					movlw			0x0f
					movwf			0x05
					movlw			0x86
					movwf			0x1f
					bcf				0x03,5
;----------------------------------------------------------------------------------------------------------------------------------------					
				
					clrf				05h
					clrf				06h
					clrf				07h
					clrf				08h
					clrf				09h
					
	
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
;								Config del Teclado
;--------------------------------------------------------------------------------------------------------------------			
					movlw			0x00						
					movwf			teclas						;Teclas
										
scan				clrf				cont
					movlw			b'00001110'				;Se prepara para enviar un cero a las filas
					movwf			rota							;Se en envia el dato (con el cero) a rota
					
probar			movf				rota,0
					movwf			0x06							;Se envia rota a las filas (puerto B)
					nop												;Tiempo para la estabilidad de las lineas
					
;----------------------Limpia pantalla LCD-----------------------------------------------------------------------------------------

					btfss			0x09,2
					goto				saltt
					
					movlw			01h
					call				control
					movlw			02h
					call				control	
saltt				
					
;--------------------- Lee  valor del puerto A ------------------------------------------------------------------------------------
			
					movf				0x05,0						;Mueve el valor del puerto A a W
					andlw			0x0f							;Limpia los cuatro bis mas altos
					xorlw			0x0f							;Invierte los bits para obtener: 0 = boton inactivo, 1 = boton activo.
					movwf			vlo
					btfss			0x03,2						;Si hay un boton activo = salir, si no hay boton activo = salto.
					goto				salir
					
;--------------- Rotar bit --------------------------------------------------------------------------------------------------------------
					
					btfss			rota,3						;Comprueba el bit en "rota" : si llego al 3 = scan, si no = salto.	
					goto				scan							;Sigue escaneando el teclado.
					bsf				0x03,0
					bcf				rota,3
					rlf					rota,1
					incf				cont,1
					goto				probar						;Continua con la siguiente fila
					
;-----------------------------------------------------------------------------------------------------------------------------------------	
									
salir	
					call				tabla								;Se determinan las coordenadas (fila/columna) del teclado y retorna un valor.
					call				dato	
					call				retardo2

					goto				scan								;Regresa a escanear el teclado nuevamente.
	
;===================================================================

;----------------------------------------------------------------------------------------------------------------------------------------
;				Subrutina: Todas las tablas para mostrar datos en pantalla.
;----------------------------------------------------------------------------------------------------------------------------------------

tabla	
					movf				cont,0
					addwf			0x02,1
					goto				tbl0
					goto				tbl1
					goto				tbl2
					goto				tbl3
					goto				tbl4
	
tbl0				movf				vlo,0
					addwf			0x02,1
					nop
					retlw			'0'										;Primera columna
					retlw			'1'										;Segunda columna
					nop
					retlw			'2'										;Tercera columna
					nop
					nop
					nop
					retlw			'3'										;Cuarta columna

tbl1				movf				vlo,0
					addwf			0x02,1
					nop
					retlw			'4'										;Primera columna
					retlw			'5'										;Segunda columna
					nop
					retlw			'6'										;Tercera columna
					nop
					nop
					nop
					retlw			'7'										;Cuarta columna

tbl2				movf				vlo,0
					addwf			0x02,1
					nop
					retlw			'8'										;Primera columna
					retlw			'9'										;Segunda columna
					nop
					retlw			'A'										;Tercera columna
					nop
					nop
					nop
					retlw			'B'										;Cuarta columna
					
tbl3				movf				vlo,0
					addwf			0x02,1
					nop
					retlw			'C'										;Primera columna
					retlw			'D'										;Segunda columna
					nop
					retlw			'E'										;Tercera columna
					nop
					nop
					nop
					retlw			'F'										;Cuarta columna
					
tbl4				movf				vlo,0
					addwf			0x02,1
					nop
					retlw			0										;Primera columna
					retlw			1										;Segunda columna
					nop
					retlw			2										;Tercera columna
					nop
					nop
					nop
					retlw			3										;Cuarta columna
					
;----------------------------------------------------------------------------------------------------
;				Subrutinas para controlar la LCD:
;			Esta rutina genera las señales de control y
;	 		entrega el dato correspondiente al modulo
;----------------------------------------------------------------------------------------------------

control			bcf				0x09,0							;Pin RS a cero modo = control.							
					goto				dato2							;Salto
dato				bsf				0x09,0							;Pin RS a uno modo = dato.
dato2			bsf				0x09,1							;Pin E a uno habilitador = activado.
					movwf			0x08								;Envia el dato a la LCD (puertoE).
					call				retardo
					bcf				0x09,1							;Pin E a cero habilitador = desactivado.
					call				retardo
					retlw			0
														
;----------------------------------------------------------------------------------------------------
;				Subrutinas de retardo
;----------------------------------------------------------------------------------------------------

retardo2
				movlw		05h
				movwf		cont0
ret3			movlw		80h
				movwf		cont1
ret2			movlw		0ffh
				movwf		cont2
ret1			decfsz		cont2
				goto			ret1
				decfsz		cont1
				goto			ret2
				decfsz		cont0
				goto			ret3
				clrf			cont0
				goto			decre
retardo
				movlw		0ffh
				movwf		cont0
decre		decfsz		cont0,1
				goto			decre
				retlw		0


;====================================================================
      END
