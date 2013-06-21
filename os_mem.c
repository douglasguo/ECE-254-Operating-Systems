//Includes
#include "RTL.h"
#include <LPC17xx.H>

void* os_mem_alloc(int size, unsigned char flag)
{
	void *result;
	
	//try and allocate memory 
	result = _os_mem_alloc((U32)rt_mem_alloc, size, flag);

	if (((int)result < 256) && flag)  //we blocked and then unblocked therefore memory might be free now
	{
		result = os_mem_alloc(size,MEM_WAIT); //allocate free memory
	}

	return result;
}
