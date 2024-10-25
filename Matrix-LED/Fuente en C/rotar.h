/* 
 *
 * Created:   Vie May 13 2016
 * Processor: PIC16F877
 * Compiler:  CCS for PIC
 */

#include <stdio.h>

/*Operaciones especiales:*/
int	op(int	op, int v1, int v2, int bit)
{
	//Subrutina para rotar los datos (Izquierda/Derecha)
	if	(op==6)
	{		
			int	bitou[8],	tes;
	
					if(bit==0)
						
						{
							tes=bit_test(v1,7);
							v1=v1<<1;
							if(tes==1)	bit_set(v1,0);
							else		bit_clear(v1,0);
						
						}
					
					else	if	(bit==1)
								
						{
							tes=bit_test(v1,0);
							v1=v1>>1;
							if(tes==1)	bit_set(v1,7);
							else		bit_clear(v1,7);
						
						}
					
				return bitou[v2]=v1;
	}

	
}






