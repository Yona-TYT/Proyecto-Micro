

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

ciclos			equ			0x40
altura			equ			0x41
rotate			equ			0x42


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
					
;-----------------------------------------------------------------------------------------------------------------------------------------			
					
					movlw			0x00							;Se muestra un cero en el display
					movwf			teclas						;Teclas
										
scan				clrf				cont
					movlw			b'00001110'				;Se prepara para enviar un cero a las filas
					movwf			rota							;Se en envia el dato (con el cero) a rota
					
probar			movf				rota,0
					movwf			0x06							;Se envia rota a las filas (puerto B)
					nop												;Tiempo para la estabilidad de las lineas
					
;--------------------- Lee  vlaor del puerto A ------------------------------------------------------------------------------------
			
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
									
salir				call				tabla								;Se determinan las coordenadas (fila/columna) del teclado y retorna un valor.
					movwf			0x50	
					call				dibujo							;Selecciona la letra.
					call				muestra						;Muestra en pantalla la letra.
					goto				scan								;Regresa a escanear el teclado nuevamente.
	
;===================================================================
retardo				
					movlw			0x05
					movwf			0x20
ret3				movlw			0x81
					movwf			0x21
ret2				movlw			0xff
					movwf			0x22
ret1				decfsz			0x22,1
					goto				ret1
					decfsz			0x21,1
					goto				ret2
					decfsz			0x20,1
					goto				ret3
					return

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
					retlw			0										;Primera columna
					retlw			1										;Segunda columna
					nop
					retlw			2										;Tercera columna
					nop
					nop
					nop
					retlw			3										;Cuarta columna

tbl1				movf				vlo,0
					addwf			0x02,1
					nop
					retlw			4										;Primera columna
					retlw			5										;Segunda columna
					nop
					retlw			6										;Tercera columna
					nop
					nop
					nop
					retlw			7										;Cuarta columna

tbl2				movf				vlo,0
					addwf			0x02,1
					nop
					retlw			8										;Primera columna
					retlw			9										;Segunda columna
					nop
					retlw			10										;Tercera columna
					nop
					nop
					nop
					retlw			11										;Cuarta columna
					
tbl3				movf				vlo,0
					addwf			0x02,1
					nop
					retlw			12										;Primera columna
					retlw			13										;Segunda columna
					nop
					retlw			14										;Tercera columna
					nop
					nop
					nop
					retlw			15										;Cuarta columna
					
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
										
;----------------------------------------------------------------------------------------------------------------------------------------
;				Subrutina: Muestra el dibujo en pantalla.
;----------------------------------------------------------------------------------------------------------------------------------------
muestra
					movlw			0x90									;Numero de ciclos para el barrido de datos
					movwf			ciclos								;Contador de ciclos
				
clc1				movlw			0x08									;Altura de la pantalla
					movwf			altura								;Contador de dibujo: numero de ciclos para una altura dada
				
					movlw			0x01									;Habilitador de columnas: este registro va a mantener 
					movwf			rotate								;rotando  un uno continuamente			
				
					movlw			0x30 + 0x08						;Valor del dibujo mas bajo + 8 = Valor de dibujo mas alto (0x38)
					movwf			0x04									;Se envia 0x38 al registro FSR
				
clc2				movlw			0x00									;Se desctivan todas las filas/columnas
					movwf			0x07
					movwf			0x08
					
					decf				0x04,1								;Decrementa el registro FRS
				
					movf				0x00,0	
					movwf			0x08
				
					movf				rotate,0							;El uno en este registro se rota para habilitar una columnas por ciclo
					movwf			0x07									;Se envia el uno hacia el puerto C
				
					rlf					rotate								;Rota el habilitador de columnas
					bcf				rotate,0							;Pone en cero el primer bit del habilitador de columnas

;--------------------------Se espera un momento----------------------------------
					
					movlw			0x03
					movwf			0x20
rret3				movlw			0x05
					movwf			0x21
rret2				movlw			0x20
					movwf			0x22
rret1				decfsz			0x22
					goto				rret1
					decfsz			0x21
					goto				rret2
					decfsz			0x20
					goto				rret3
		
;---------------------------------------------------------------------------------------------
					
					movlw			0ffh
					movwf			0x08
					
					movlw			0x00
					movwf			0x07
								
					decfsz			altura				;Se decrementa el contador de dibujo hasta llegar a cero				
					goto 			clc2
				
					decfsz			ciclos				;Se decrementa el contador de ciclos hasta llegar a cero
					goto				clc1

					retlw			0
					
;----------------------------------------------------------------------------------------------------------------------------------------
;				Subrutina: Selecciona las letras a mostrar (A-J). 
;----------------------------------------------------------------------------------------------------------------------------------------
dibujo
				movf			0x50,0
				addwf		0x02,1
				goto			d1
				goto			d2
				goto			d3
				goto			d4
				goto			d5
				goto			d6
				goto			d7
				goto			d8
				goto			d9
				goto			d10	
			
;A
d1			movlw		b'11111111'
				movwf		0x30
				movlw		b'11000011'
				movwf		0x30 + 0x01
				movlw		b'11011011'
				movwf		0x30 + 0x02
				movlw		b'11000011'
				movwf		0x30 + 0x03
				movlw		b'11011011'
				movwf		0x30 + 0x04
				movlw		b'11011011'
				movwf		0x30 + 0x05
				movlw		b'11111111'
				movwf		0x30 + 0x06
				movlw		b'11111111'
				movwf		0x30 + 0x07
				goto			dfin

;B
d2			movlw		b'11111111'
				movwf		0x30
				movlw		b'11000111'
				movwf		0x30 + 0x01
				movlw		b'11011011'
				movwf		0x30 + 0x02
				movlw		b'11000111'
				movwf		0x30 + 0x03
				movlw		b'11011011'
				movwf		0x30 + 0x04
				movlw		b'11000111'
				movwf		0x30 + 0x05
				movlw		b'11111111'
				movwf		0x30 + 0x06
				movlw		b'11111111'
				movwf		0x30 + 0x07
				goto			dfin

;C			
d3			movlw		b'11111111'
				movwf		0x30
				movlw		b'11000011'
				movwf		0x30 + 0x01
				movlw		b'11011111'
				movwf		0x30 + 0x02
				movlw		b'11011111'
				movwf		0x30 + 0x03
				movlw		b'11011111'
				movwf		0x30 + 0x04
				movlw		b'11000011'
				movwf		0x30 + 0x05
				movlw		b'11111111'
				movwf		0x30 + 0x06
				movlw		b'11111111'
				movwf		0x30 + 0x07
				goto			dfin

;D
d4			movlw		b'11111111'
				movwf		0x30
				movlw		b'11000111'
				movwf		0x30 + 0x01
				movlw		b'11011011'
				movwf		0x30 + 0x02
				movlw		b'11011011'
				movwf		0x30 + 0x03
				movlw		b'11011011'
				movwf		0x30 + 0x04
				movlw		b'11000111'
				movwf		0x30 + 0x05
				movlw		b'11111111'
				movwf		0x30 + 0x06
				movlw		b'11111111'
				movwf		0x30 + 0x07	
				goto			dfin

;E				
d5			movlw		b'11111111'
				movwf		0x30
				movlw		b'11000011'
				movwf		0x30 + 0x01
				movlw		b'11011111'
				movwf		0x30 + 0x02
				movlw		b'11000011'
				movwf		0x30 + 0x03
				movlw		b'11011111'
				movwf		0x30 + 0x04
				movlw		b'11000011'
				movwf		0x30 + 0x05
				movlw		b'11111111'
				movwf		0x30 + 0x06
				movlw		b'11111111'
				movwf		0x30 + 0x07
				goto			dfin
;F			
d6			movlw		b'11111111'
				movwf		0x30
				movlw		b'11000011'
				movwf		0x30 + 0x01
				movlw		b'11011111'
				movwf		0x30 + 0x02
				movlw		b'11000111'
				movwf		0x30 + 0x03
				movlw		b'11011111'
				movwf		0x30 + 0x04
				movlw		b'11011111'
				movwf		0x30 + 0x05
				movlw		b'11111111'
				movwf		0x30 + 0x06
				movlw		b'11111111'
				movwf		0x30 + 0x07
				goto			dfin				

;G				
d7			movlw		b'11111111'
				movwf		0x30
				movlw		b'11000011'
				movwf		0x30 + 0x01
				movlw		b'11011111'
				movwf		0x30 + 0x02
				movlw		b'11010011'
				movwf		0x30 + 0x03
				movlw		b'11011011'
				movwf		0x30 + 0x04
				movlw		b'11000011'
				movwf		0x30 + 0x05
				movlw		b'11111111'
				movwf		0x30 + 0x06
				movlw		b'11111111'
				movwf		0x30 + 0x07
				goto			dfin
				
;H				
d8			movlw		b'11111111'
				movwf		0x30
				movlw		b'11011011'
				movwf		0x30 + 0x01
				movlw		b'11011011'
				movwf		0x30 + 0x02
				movlw		b'11000011'
				movwf		0x30 + 0x03
				movlw		b'11011011'
				movwf		0x30 + 0x04
				movlw		b'11011011'
				movwf		0x30 + 0x05
				movlw		b'11111111'
				movwf		0x30 + 0x06
				movlw		b'11111111'
				movwf		0x30 + 0x07
				goto			dfin	
				
;I
d9			movlw		b'11111111'
				movwf		0x30
				movlw		b'11000111'
				movwf		0x30 + 0x01
				movlw		b'11101111'
				movwf		0x30 + 0x02
				movlw		b'11101111'
				movwf		0x30 + 0x03
				movlw		b'11101111'
				movwf		0x30 + 0x04
				movlw		b'11000111'
				movwf		0x30 + 0x05
				movlw		b'11111111'
				movwf		0x30 + 0x06
				movlw		b'11111111'
				movwf		0x30 + 0x07
				goto			dfin
;J									
d10			movlw		b'11111111'
				movwf		0x30
				movlw		b'11100011'
				movwf		0x30 + 0x01
				movlw		b'11110111'
				movwf		0x30 + 0x02
				movlw		b'11110111'
				movwf		0x30 + 0x03
				movlw		b'11110111'
				movwf		0x30 + 0x04
				movlw		b'11000111'
				movwf		0x30 + 0x05
				movlw		b'11111111'
				movwf		0x30 + 0x06
				movlw		b'11111111'
				movwf		0x30 + 0x07
				goto			dfin		
				
dfin			return
					
;====================================================================
      END
