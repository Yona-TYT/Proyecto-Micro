

;============================================================================================================================================
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;============================================================================================================================================

#include p16f877.inc                ; Include register definition file

;====================================================================
; VARIABLES
;====================================================================
teclas			equ			0x25
filas				equ			0x26			;No se usa.
rota				equ			0x27
cont0			equ			0x28
direc			equ			0x29

ciclos			equ			0x30
altura			equ			0x31
rotate			equ			0x32
save1			equ 			0x33
save2			equ 			0x34


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
					movwf			0x05
					movwf			0x07
					movwf			0x08
					movwf			0x09
					movlw			0x0f
					movwf			0x06
					movlw			0x86
					movwf			0x1f
					bcf				0x03,5
;------------------------- Limpia los puertos ----------------------------------------------------------------------------------------					
				
					clrf				05h
					clrf				06h
					clrf				07h
					clrf				08h
					clrf				09h
					
;-----------------------------------------------------------------------------------------------------------------------------------------			
													
					call				dibujo								;Selecciona la letra.

clc				
					call				muestra							;Muestra en pantalla el mensaje.
													
;---------------rota izq------------
					btfsc		0x06,0
					bsf			direc,0
					btfsc		0x06,0
					call			rotar										;Rota el mensaje a la izquierda
					clrf			direc

;---------------rota der------------					
					btfsc		0x06,1
					bsf			direc,1
					btfsc		0x06,1
					call			rotar										;Rota el mensaje a la derecha
					clrf			direc
					goto			clc
					
	
;----------------------------------------------------------------------------------------------------------------------------------------
;				Subrutina: Muestra el dibujo en pantalla.
;----------------------------------------------------------------------------------------------------------------------------------------
muestra
					movlw			0x15								;Numero de ciclos para el barrido de datos
					movwf			ciclos								;Contador de ciclos
				
clc1				movlw			0x08									;Altura de la pantalla
					movwf			altura								;Contador de dibujo: numero de ciclos para una altura dada
				
					movlw			0x01								;Habilitador de columnas: este registro va a mantener 
					movwf			rotate								;rotando  un uno continuamente			
				
					movlw			0x50 + 0x08						;Valor del dibujo mas bajo + 8 = Valor de dibujo mas alto (0x38)
					movwf			0x04								;Se envia 0x38 al registro FSR
				
clc2				movlw			0x00								;Se desctivan todas las filas/columnas
					movwf			0x07
					movwf			0x08
					
					decf				0x04,1								;Decrementa el registro FRS
				
					movf				0x00,0	
					movwf			0x08
				
					movf				rotate,0							;El uno en este registro se rota para habilitar una columnas por ciclo
					movwf			0x07								;Se envia el uno hacia el puerto C
				
					rlf					rotate								;Rota el habilitador de columnas
					bcf				rotate,0							;Pone en cero el primer bit del habilitador de columnas

;--------------------------Se espera un momento----------------------------------
					
					movlw			0x03
					movwf			0x20
rret3				movlw			0x05
					movwf			0x21
rret2			movlw			0x20
					movwf			0x22
rret1			decfsz			0x22
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
					
;----------------------------------------------------------------------------------------------------


;----------------------------------------------------------------------------------------------------------------------------------------
;				Subrutina: Selecciona las letras a mostrar.
;----------------------------------------------------------------------------------------------------------------------------------------
dibujo

d1			movlw		b'11111111'
				movwf		0x50
				movlw		b'11011011'
				movwf		0x50 + 0x01
				movlw		b'11011010'
				movwf		0x50 + 0x02
				movlw		b'11000010'
				movwf		0x50 + 0x03
				movlw		b'11011010'
				movwf		0x50 + 0x04
				movlw		b'11011011'
				movwf		0x50 + 0x05
				movlw		b'11111111'
				movwf		0x50 + 0x06
				movlw		b'11111111'
				movwf		0x50 + 0x07
	

								
d2			movlw		b'11111111'
				movwf		0x60
				movlw		b'00110111'
				movwf		0x60 + 0x01
				movlw		b'11010111'
				movwf		0x60 + 0x02
				movlw		b'11010111'
				movwf		0x60 + 0x03
				movlw		b'11010111'
				movwf		0x60 + 0x04
				movlw		b'00110001'
				movwf		0x60 + 0x05
				movlw		b'11111111'
				movwf		0x60 + 0x06
				movlw		b'11111111'
				movwf		0x60 + 0x07
	

				
d3			movlw		b'11111111'
				movwf		0x70
				movlw		b'00001111'
				movwf		0x70 + 0x01
				movlw		b'01101111'
				movwf		0x70 + 0x02
				movlw		b'00001111'
				movwf		0x70 + 0x03
				movlw		b'01101111'
				movwf		0x70 + 0x04
				movlw		b'01101111'
				movwf		0x70 + 0x05
				movlw		b'11111111'
				movwf		0x70 + 0x06
				movlw		b'11111111'
				movwf		0x70 + 0x07

				return
				
;----------------------------------------------------------------------------------------------------------------------------------------
;				Subrutina: Rota el mensje izq/der
;----------------------------------------------------------------------------------------------------------------------------------------
		
rotar

				movlw		.8
				movwf		cont0
			
				movlw		40h
				movwf		save1
								
				btfsc		direc,0
				movlw		50h
				btfsc		direc,1
				movlw		70h		
				movwf		save2

rclc00		movf			save1,0
				movwf		0x04
				
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00
				
;-----------rota izq/der     BSF   ------------
				btfsc		direc,0
				bsf			0x00,0	
				btfsc		direc,1
				bsf			0x00,7	
						
				movf			save2,0
				movwf		0x04
				
;-----------rota izq/der   BTFSC------------
				btfss		direc,0
				goto			ssal00
				btfss		0x00,7
				goto			cer00
				goto			salcer00
ssal00
;-----------rota izq/der   BTFSC------------			
				btfsc		direc,1
				btfss		0x00,0
				goto			cer00							
				goto			salcer00
cer00							

				movf			save1,0
				movwf		0x04			
;-----------rota izq/der     BCF   ------------
				btfsc		direc,0
				bcf			0x00,0	
				btfsc		direc,1
				bcf			0x00,7	
				
salcer00		
				incf			save1,1
				incf			save2,1
				
				decfsz		cont0		
				goto			rclc00

;-----------------------------------------------------------------------------------------------------------------------------
	
				movlw		.8
				movwf		cont0

				btfsc		direc,0
				movlw		50h
				btfsc		direc,1
				movlw		70h			
				movwf		save1
				movlw		60h
				movwf		save2
										
rclc0		movf			save1,0
				movwf		0x04
				
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00
				
;-----------rota izq/der     BSF   ------------
				btfsc		direc,0
				bsf			0x00,0	
				btfsc		direc,1
				bsf			0x00,7	
				
				movf			save2,0
				movwf		0x04
				
;-----------rota izq/der   BTFSC------------
				btfss		direc,0
				goto			ssal0
				btfss		0x00,7
				goto			cer0
		

;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00			
				goto			salcer0
				
ssal0			
;-----------rota izq/der   BTFSC------------
				btfsc		direc,1
				btfss		0x00,0
				goto			cer0	
							
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00			
				goto			salcer0
cer0	
						
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00

				movf			save1,0
				movwf		0x04
				
;-----------rota izq/der     BCF   ------------
				btfsc		direc,0
				bcf			0x00,0	
				btfsc		direc,1
				bcf			0x00,7	
				
salcer0			
				incf			save1,1
				incf			save2,1
				
				decfsz		cont0		
				goto			rclc0

;-----------------------------------------------------------------------------------------------------------------------------
				
				movlw		.8
				movwf		cont0

				movlw		60h
				movwf		save1
				
				btfsc		direc,0
				movlw		70h			
				btfsc		direc,1
				movlw		50h
				
				movwf		save2
											
rclc1		movf			save1,0
				movwf		0x04
				
;-----------rota izq/der     BSF   ------------
				btfsc		direc,0
				bsf			0x00,0				
				btfsc		direc,1
				bsf			0x00,7	
				
				movf			save2,0
				movwf		0x04		
				
;-----------rota izq/der   BTFSC------------
				btfss		direc,0
				goto			ssal1
				btfss		0x00,7
				goto			cer1
				
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00			
				goto			salcer1

ssal1	
;-----------rota izq/der   BTFSC------------	
				btfsc		direc,1
				btfss		0x00,0
				goto			cer1	
				
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00			
				goto			salcer1
								
cer1							
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00

				movf			save1,0
				movwf		0x04	
				
;-----------rota izq/der     BCF   ------------
				btfsc		direc,0
				bcf			0x00,0	
				btfsc		direc,1
				bcf			0x00,7	
				
salcer1			
				incf			save1,1
				incf			save2,1
				
				decfsz		cont0		
				goto			rclc1

;-----------------------------------------------------------------------------------------------------------------------------
				
				movlw		.8
				movwf		cont0

				btfsc		direc,0
				movlw		70h
				btfsc		direc,1
				movlw		50h
				
				movwf		save1
				movlw		40h
				movwf		save2
											
rclc2		movf			save1,0
				movwf		0x04
				
;-----------rota izq/der     BSF   ------------
				btfsc		direc,0
				bsf			0x00,0	
				btfsc		direc,1
				bsf			0x00,7	
				
				movf			save2,0
				movwf		0x04	
				
;-----------rota izq/der   BTFSC------------
				btfss		direc,0
				goto			ssal2
				btfss		0x00,0
				goto			cer2
						
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00		
				goto			salcer2
				
ssal2	
;-----------rota izq/der   BTFSC------------
				btfsc		direc,1
				btfss		0x00,7
				goto			cer2	

										
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00			
				goto			salcer2
				
cer2
						
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				0x00
				btfsc		direc,1
				rrf			0x00

				movf			save1,0
				movwf		0x04
				
;-----------rota izq/der     BCF   -------------
				btfsc		direc,0
				bcf			0x00,0	
				btfsc		direc,1
				bcf			0x00,7	
				
salcer2			
				incf			save1,1
				incf			save2,1
				
				decfsz		cont0		
				goto			rclc2
				
				return


;============================================================================================================================================
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;============================================================================================================================================

				END
