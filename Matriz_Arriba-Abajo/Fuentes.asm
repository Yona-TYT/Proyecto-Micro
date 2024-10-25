

;============================================================================================================================================
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV:::::::: 
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;============================================================================================================================================

#include p16f877.inc                ; Include register definition file

;====================================================================
; VARIABLES
;====================================================================
indf				equ			0x00
pcl				equ			0x02
status			equ			0x03
fsr				equ			0x04

porta			equ			0x05
portb			equ			0x06
portc			equ			0x07
portd			equ			0x08
porte			equ			0x09

cont0			equ			0x26
cont1			equ			0x27
cont2			equ			0x28

direc			equ			0x29					;Lee los botones en el puerto b para rotar

;-----------Registros para la rutina "muestra"----------------
ciclos			equ			0x30				
altura			equ			0x31					
rotate			equ			0x32

;-----------Registros para la rutina "rotar"----------------
save1			equ 			0x33
save2			equ 			0x34
temp1			equ			0x37
temp2			equ			0x38

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
					bsf				status,5
					bcf				status,6
					movlw			0x00
					movwf			porta
					movwf			portc
					movwf			portd
					movwf			porte
					movlw			0x0f
					movwf			portb
					movlw			0x86
					movwf			0x1f
					bcf				status,5

;------------------------- Limpia los puertos ----------------------------------------------------------------------------------------					
				
					clrf			porta
					clrf			portb
					clrf			portc
					clrf			portd
					clrf			porte
					
;-----------------------------------------------------------------------------------------------------------------------------------------			
													
					call			dibujo					;Selecciona la letra.

clc				
					call			muestra							;Muestra en pantalla el mensaje.
													
;---------------rota izq------------
					btfsc			portb,0
					bsf				direc,0
					btfsc			portb,0
					call				rotar										;Rota el mensaje a la izquierda
					clrf				direc

;---------------rota der------------					
					btfsc			portb,1
					bsf				direc,1
					btfsc			portb,1
					call				rotar										;Rota el mensaje a la derecha
					clrf				direc
					

					goto				clc

	
;----------------------------------------------------------------------------------------------------------------------------------------
;				Subrutina: Muestra el dibujo en pantalla.
;----------------------------------------------------------------------------------------------------------------------------------------
muestra
					movlw			0x25								;Numero de ciclos para el barrido de datos
					movwf			ciclos								;Contador de ciclos
				
clc1				movlw			0x08									;Altura de la pantalla
					movwf			altura								;Contador de dibujo: numero de ciclos para una altura dada
				
					movlw			0x01								;Habilitador de columnas: este registro va a mantener 
					movwf			rotate								;rotando  un uno continuamente			
				
					movlw			0x50 + 0x08						;Valor del dibujo mas bajo + 8 = Valor de dibujo mas alto (0x38)
					movwf			0x04								;Se envia 0x38 al registro FSR
				
clc2				movlw			0x00								;Se desctivan todas las filas/columnas
					movwf			portc
					movwf			portd
					
					decf				fsr,1									;Decrementa el registro FRS
				
					movf				indf,0	
					movwf			portd
				
					movf				rotate,0							;El uno en este registro se rota para habilitar una columnas por ciclo
					movwf			portc								;Se envia el uno hacia el puerto C
				
					rlf					rotate								;Rota el habilitador de columnas
					bcf				rotate,0							;Pone en cero el primer bit del habilitador de columnas

;--------------------------Se espera un momento----------------------------------
					
					movlw			0xff
					movwf			0x20

rret3				decfsz			0x20
					goto				rret3
		
;---------------------------------------------------------------------------------------------
					
					movlw			0ffh
					movwf			portd
					
					movlw			0x00
					movwf			portc
								
					decfsz			altura				;Se decrementa el contador de dibujo hasta llegar a cero				
					goto 			clc2
				
					decfsz			ciclos				;Se decrementa el contador de ciclos hasta llegar a cero
					goto				clc1

					retlw			0
					



;----------------------------------------------------------------------------------------------------------------------------------------
;				Subrutina: Selecciona las letras a mostrar.
;----------------------------------------------------------------------------------------------------------------------------------------
dibujo

;Letra H
				movlw		b'11111111'
				movwf		0x50
				movlw		b'11011011'
				movwf		0x51
				movlw		b'11011011'
				movwf		0x52
				movlw		b'11000011'
				movwf		0x53
				movlw		b'11011011'
				movwf		0x54
				movlw		b'11011011'
				movwf		0x55
				movlw		b'11111111'
				movwf		0x56
				
;Letra E	
				movlw		b'11111111'
				movwf		0x57							
				movlw		b'11000011'
				movwf		0x58
				movlw		b'11011111'
				movwf		0x59
				movlw		b'11000111'
				movwf		0x5a
				movlw		b'11011111'
				movwf		0x5b
				movlw		b'11000011'
				movwf		0x5c
				movlw		b'11111111'
				movwf		0x5d
				
;Letra L				
				movlw		b'11011111'
				movwf		0x5e
				movlw		b'11011111'
				movwf		0x5f	
				movlw		b'11011111'
				movwf		0x60
				movlw		b'11011111'
				movwf		0x61
				movlw		b'11011111'
				movwf		0x62
				movlw		b'11000011'
				movwf		0x63
				movlw		b'11111111'
				movwf		0x64
				
;Letra P			
				movlw		b'11000111'
				movwf		0x65
				movlw		b'11011011'
				movwf		0x66
				movlw		b'11000111'
				movwf		0x67
				movlw		b'11011111'
				movwf		0x68
				movlw		b'11011111'
				movwf		0x69
				movlw		b'11011111'
				movwf		0x6a
				movlw		b'11111111'
				movwf		0x6b
				
;Espacio en blaco entre HELP
				movlw		b'11111111'
				movwf		0x6c
				movlw		b'11111111'
				movwf		0x6d
				movlw		b'11111111'
				movwf		0x6e
				movlw		b'11111111'
				movwf		0x6f
				return
				
;----------------------------------------------------------------------------------------------------------------------------------------
;				Subrutina: Rota el mensje izq/der
;----------------------------------------------------------------------------------------------------------------------------------------
		
rotar
;-------------- Rotar: Arriba/Abajo -------------------
				btfsc		direc,0
				movlw		78h				
				btfsc		direc,1
				movlw		47h
				
				movwf		save1

;-------------- Rotar: Arriba/Abajo -------------------				
				btfsc		direc,0
				movlw		58h				
				btfsc		direc,1
				movlw		67h
				
				movwf		save2
				
				movlw		.8
				movwf		cont1
				
aclc0
				movf			save1,0
				movwf		fsr
				movf			indf,0
				movwf		temp1
				
				movf			save2,0
				movwf		fsr
				movf			indf,0
				movwf		temp2
				
				movlw		.8
				movwf		cont0
			
bclc0		
				rlf				temp1	
				bsf			temp1,0
				btfss		temp2,7
				bcf			temp1,0				
				rlf				temp2
		
				decfsz		cont0		
				goto			bclc0
				
				movf			save1,0
				movwf		fsr
				movf			temp1,0
				movwf		indf	

;--------------Decrementa para mover hacia abajo---------------------
				btfsc			direc,0
				decf			save1,1
				btfsc			direc,0
				decf			save2,1
			
;--------------Incrementa para mover hacia arriba---------------------	
				btfsc			direc,1
				incf			save1,1
				btfsc			direc,1
				incf			save2,1
							
				decfsz		cont1
				goto			aclc0
				
;----------------------------------------------------------------------------------------------------

;-------------- Rotar: Arriba/Abajo -------------------			
				btfsc		direc,0
				movlw		70h				
				btfsc		direc,1
				movlw		4fh
				
				movwf		save1
				
;-------------- Rotar: Arriba/Abajo -------------------
				btfsc		direc,0
				movlw		6fh				
				btfsc		direc,1
				movlw		50h
				
				movwf		save2
				
			
				movlw		.8
				movwf		cont1
				
aclc1
				movf			save1,0
				movwf		fsr
				movf			indf,0
				movwf		temp1
				
				movf			save2,0
				movwf		fsr
				movf			indf,0
				movwf		temp2
				
				movlw		.8
				movwf		cont0
			
bclc1		
				rlf				temp1	
				bsf			temp1,0
				btfss		temp2,7
				bcf			temp1,0				
				rlf				temp2
		
				decfsz		cont0		
				goto			bclc1
				
				movf			save1,0
				movwf		fsr
				movf			temp1,0
				movwf		indf	

;--------------Decrementa para mover hacia abajo---------------------
				btfsc			direc,0
				decf			save1,1
				btfsc			direc,0
				decf			save2,1
			
;--------------Incrementa para mover hacia arriba---------------------	
				btfsc			direc,1
				incf			save1,1
				btfsc			direc,1
				incf			save2,1
							
				decfsz		cont1
				goto			aclc1
		
;----------------------------------------------------------------------------------------------------		

;-------------- Rotar: Arriba/Abajo -------------------			
				btfsc		direc,0
				movlw		68h				
				btfsc		direc,1
				movlw		57h
				
				movwf		save1
				
;-------------- Rotar: Arriba/Abajo -------------------
				btfsc		direc,0
				movlw		67h				
				btfsc		direc,1
				movlw		58h
				
				movwf		save2
							
				movlw		.8
				movwf		cont1
				
aclc2
				movf			save1,0
				movwf		fsr
				movf			indf,0
				movwf		temp1
				
				movf			save2,0
				movwf		fsr
				movf			indf,0
				movwf		temp2
				
				movlw		.8
				movwf		cont0
			
bclc2		
				rlf				temp1	
				bsf			temp1,0
				btfss		temp2,7
				bcf			temp1,0				
				rlf				temp2
		
				decfsz		cont0		
				goto			bclc2
				
				movf			save1,0
				movwf		fsr
				movf			temp1,0
				movwf		indf	

;--------------Decrementa para mover hacia abajo---------------------
				btfsc			direc,0
				decf			save1,1
				btfsc			direc,0
				decf			save2,1
			
;--------------Incrementa para mover hacia arriba---------------------	
				btfsc			direc,1
				incf			save1,1
				btfsc			direc,1
				incf			save2,1
							
				decfsz		cont1
				goto			aclc2
		
;----------------------------------------------------------------------------------------------------		

;-------------- Rotar: Arriba/Abajo -------------------			
				btfsc		direc,0
				movlw		60h				
				btfsc		direc,1
				movlw		5fh
				
				movwf		save1
				
;-------------- Rotar: Arriba/Abajo -------------------
				btfsc		direc,0
				movlw		5fh				
				btfsc		direc,1
				movlw		60h
				
				movwf		save2
		
				movlw		.8
				movwf		cont1
				
aclc3
				movf			save1,0
				movwf		fsr
				movf			indf,0
				movwf		temp1
				
				movf			save2,0
				movwf		fsr
				movf			indf,0
				movwf		temp2
				
				movlw		.8
				movwf		cont0
			
bclc3	
				rlf				temp1	
				bsf			temp1,0
				btfss		temp2,7
				bcf			temp1,0				
				rlf				temp2
		
				decfsz		cont0		
				goto			bclc3
				
				movf			save1,0
				movwf		fsr
				movf			temp1,0
				movwf		indf	

;--------------Decrementa para mover hacia abajo---------------------
				btfsc			direc,0
				decf			save1,1
				btfsc			direc,0
				decf			save2,1
			
;--------------Incrementa para mover hacia arriba---------------------	
				btfsc			direc,1
				incf			save1,1
				btfsc			direc,1
				incf			save2,1
							
				decfsz		cont1
				goto			aclc3
		
;----------------------------------------------------------------------------------------------------		

;-------------- Rotar: Arriba/Abajo -------------------			
				btfsc		direc,0
				movlw		58h				
				btfsc		direc,1
				movlw		67h
				
				movwf		save1
				
;-------------- Rotar: Arriba/Abajo -------------------
				btfsc		direc,0
				movlw		57h				
				btfsc		direc,1
				movlw		68h
				
				movwf		save2
				
				movlw		.8
				movwf		cont1
				
aclc4
				movf			save1,0
				movwf		fsr
				movf			indf,0
				movwf		temp1
				
				movf			save2,0
				movwf		fsr
				movf			indf,0
				movwf		temp2
				
				movlw		.8
				movwf		cont0
			
bclc4	
				rlf				temp1	
				bsf			temp1,0
				btfss		temp2,7
				bcf			temp1,0				
				rlf				temp2
		
				decfsz		cont0		
				goto			bclc4
				
				movf			save1,0
				movwf		fsr
				movf			temp1,0
				movwf		indf	

;--------------Decrementa para mover hacia abajo---------------------
				btfsc			direc,0
				decf			save1,1
				btfsc			direc,0
				decf			save2,1
			
;--------------Incrementa para mover hacia arriba---------------------	
				btfsc			direc,1
				incf			save1,1
				btfsc			direc,1
				incf			save2,1
							
				decfsz		cont1
				goto			aclc4	

;----------------------------------------------------------------------------------------------------		

;-------------- Rotar: Arriba/Abajo -------------------			
				btfsc		direc,0
				movlw		50h				
				btfsc		direc,1
				movlw		6fh
				
				movwf		save1
				
;-------------- Rotar: Arriba/Abajo -------------------
				btfsc		direc,0
				movlw		70h				
				btfsc		direc,1
				movlw		4fh
				
				movwf		save2
				
				movlw		.8
				movwf		cont1
				
aclc5
				movf			save1,0
				movwf		fsr
				movf			indf,0
				movwf		temp1
				
				movf			save2,0
				movwf		fsr
				movf			indf,0
				movwf		temp2
				
				movlw		.8
				movwf		cont0
			
bclc5	
				rlf				temp1	
				bsf			temp1,0
				btfss		temp2,7
				bcf			temp1,0				
				rlf				temp2
		
				decfsz		cont0		
				goto			bclc5
				
				movf			save1,0
				movwf		fsr
				movf			temp1,0
				movwf		indf	

;--------------Decrementa para mover hacia abajo---------------------
				btfsc			direc,0
				decf			save1,1
				btfsc			direc,0
				decf			save2,1
			
;--------------Incrementa para mover hacia arriba---------------------	
				btfsc			direc,1
				incf			save1,1
				btfsc			direc,1
				incf			save2,1
							
				decfsz		cont1
				goto			aclc5
				
				return
				
;============================================================================================================================================
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV:::::::: 
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;============================================================================================================================================
				END
