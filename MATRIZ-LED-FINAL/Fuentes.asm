

;============================================================================================================================================
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV:::::::: 
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;============================================================================================================================================

list	p=16f877a

;----------Definiciones-----------

indf				equ			0x00
pcl				equ			0x02
status			equ			0x03
fsr				equ			0x04

porta			equ			0x05
portb			equ			0x06
portc			equ			0x07
portd			equ			0x08
porte			equ			0x09

cont0			equ			0x28
direc			equ			0x29

ciclos			equ			0x30
altura			equ			0x31
rotate			equ			0x32
save1			equ 			0x33
save2			equ 			0x34


;--------Vector reset------------
	org			00
	goto			inicio
	org			05

;-----------Config de puertos-------------

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
					
;------------------------- Programa pricipal ------------------------------------------------------------------------------------------			
													
					call			dibujo									

clc
					movf			portb,0
					addwf		02h,1
					goto			opt0
					goto			opt1
					goto			opt2
					goto			opt3
					
opt0
					clrf			portc
					clrf			portd
					
					goto			clc
					
opt1				
					call			muestra								
					bsf				direc,1
					call				rotar									
					clrf				direc
					
					goto				clc

opt2			
					call			muestra								
					bsf				direc,0
					call				rotar									
					clrf				direc

opt3
					clrf			portc
					clrf			portd
					
					goto			clc				
			
;-----------------------------------------------------------------------------------------------------------------------------------------------------
;	Muestra el dibujo en pantalla: Esta subrutina mantiene rotando un bit en el puerto c haciendo un barrido de los datos.
;	El registro "Altura indica que la matriz es de 8x8 led, esto quiere decir que el barrido se hace de 8 en 8
;	El registro FRS se carga con los datos de la ultima fila (0x50 + 0x08), este se decrementa 8 veces (hasta llegar a 0x50)
;	Al cargar FRS con el valor de la ultima fila (0x50 + 0x08), el registro INDF se dirrecciona con el valor cargado en FRS
;	INDF se va ir pasando por cada uno de los registros (del 0x58 a 0x50) a mediada que se decrementa FRS
;	El valor de cada registro redireccionado por INDF se envia al puerto D y se va mostrando en pantalla fila por fila.
;	El registro "ciclos"  determina el numero de veces que se hara el barrido, a su vez controla la velocidad de rotacion.
;----------------------------------------------------------------------------------------------------------------------------------------------------
muestra
					movlw			0x25								;Numero de ciclos para el barrido de datos
					movwf			ciclos								;Contador de ciclos
				
clc1				movlw			0x08									;Altura de la pantalla
					movwf			altura								;Contador de dibujo: numero de ciclos para una altura dada
				
					movlw			0x01								;Habilitador de columnas: este registro va a mantener 
					movwf			rotate								;rotando  un uno continuamente			
				
					movlw			0x50 + 0x08						;Valor del dibujo mas bajo + 8 = Valor de dibujo mas alto (0x38)
					movwf			fsr									;Se envia 0x38 al registro FSR
				
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

;--------------------------Se espera un momento (Retardo)----------------------------------
					
					movlw			0xff
					movwf			0x20
rret1			decfsz			0x20
					goto				rret1
				
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
;				Selecciona las letras a mostrar: Esta subrutina carga los datos del mensaje desde la posicion 
;				0x50 hasta la 0x78, un cero enciende un led mientras un  uno apaga un led.
;				Notar tambien que los datos se guardan en lotes de 8
;----------------------------------------------------------------------------------------------------------------------------------------
dibujo


;Primer  lote
				movlw		b'11111111'
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
	
;Segundo lote								
				movlw		b'11111111'
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
	
;Tercer lote
				movlw		b'11111111'
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
;				Rota el mensje izq/der:  Esta rutina le rota un bit a cada uno de los registros del mensaje
;				El registro "direc" indica si el dato se rota a la iszquierda o a la derecha
;				Solo se muestran los datos del registro 0x50 al 0x58, lo que significa que todos los datos 
;				deberan pasar por esos registros (0x50 a 0x58) para poder ser mostrados en pantalla
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
				movwf		fsr
				
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf
				
;-----------rota izq/der     BSF   ------------
				btfsc		direc,0
				bsf			indf,0	
				btfsc		direc,1
				bsf			indf,7	
						
				movf			save2,0
				movwf		fsr
				
;-----------rota izq/der   BTFSC------------
				btfss		direc,0
				goto			ssal00
				btfss		indf,7
				goto			cer00
				goto			salcer00
ssal00
;-----------rota izq/der   BTFSC------------			
				btfsc		direc,1
				btfss		indf,0
				goto			cer00							
				goto			salcer00
cer00							

				movf			save1,0
				movwf		fsr			
;-----------rota izq/der     BCF   ------------
				btfsc		direc,0
				bcf			indf,0	
				btfsc		direc,1
				bcf			indf,7	
				
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
				movwf		fsr
				
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf
				
;-----------rota izq/der     BSF   ------------
				btfsc		direc,0
				bsf			indf,0	
				btfsc		direc,1
				bsf			indf,7	
				
				movf			save2,0
				movwf		fsr
				
;-----------rota izq/der   BTFSC------------
				btfss		direc,0
				goto			ssal0
				btfss		indf,7
				goto			cer0
		

;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf			
				goto			salcer0
				
ssal0			
;-----------rota izq/der   BTFSC------------
				btfsc		direc,1
				btfss		indf,0
				goto			cer0	
							
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf			
				goto			salcer0
cer0	
						
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf

				movf			save1,0
				movwf		fsr
				
;-----------rota izq/der     BCF   ------------
				btfsc		direc,0
				bcf			indf,0	
				btfsc		direc,1
				bcf			indf,7	
				
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
				movwf		fsr
				
;-----------rota izq/der     BSF   ------------
				btfsc		direc,0
				bsf			indf,0				
				btfsc		direc,1
				bsf			indf,7	
				
				movf			save2,0
				movwf		fsr		
				
;-----------rota izq/der   BTFSC------------
				btfss		direc,0
				goto			ssal1
				btfss		indf,7
				goto			cer1
				
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf			
				goto			salcer1

ssal1	
;-----------rota izq/der   BTFSC------------	
				btfsc		direc,1
				btfss		indf,0
				goto			cer1	
				
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf			
				goto			salcer1
								
cer1							
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf

				movf			save1,0
				movwf		fsr	
				
;-----------rota izq/der     BCF   ------------
				btfsc		direc,0
				bcf			indf,0	
				btfsc		direc,1
				bcf			indf,7	
				
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
				movwf		fsr
				
;-----------rota izq/der     BSF   ------------
				btfsc		direc,0
				bsf			indf,0	
				btfsc		direc,1
				bsf			indf,7	
				
				movf			save2,0
				movwf		fsr	
				
;-----------rota izq/der   BTFSC------------
				btfss		direc,0
				goto			ssal2
				btfss		indf,0
				goto			cer2
						
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf		
				goto			salcer2
				
ssal2	
;-----------rota izq/der   BTFSC------------
				btfsc		direc,1
				btfss		indf,7
				goto			cer2	

										
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf			
				goto			salcer2
				
cer2
						
;-----------rota izq/der   RLF/RRF------------
				btfsc		direc,0
				rlf				indf
				btfsc		direc,1
				rrf			indf

				movf			save1,0
				movwf		fsr
				
;-----------rota izq/der     BCF   -------------
				btfsc		direc,0
				bcf			indf,0	
				btfsc		direc,1
				bcf			indf,7	
				
salcer2			
				incf			save1,1
				incf			save2,1
				
				decfsz		cont0		
				goto			rclc2
				
				return

;============================================================================================================================================
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV:::::::: 
;::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::::::@Yonatan MV::::::::
;============================================================================================================================================
				END
