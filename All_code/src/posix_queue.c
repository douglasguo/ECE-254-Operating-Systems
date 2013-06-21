//Includes
#include "RTL.h"
#include <LPC17xx.H>

int mq_send(mqd_t mqdes, const char *msg_ptr, size_t msg_len, unsigned int msg_prio)
{
	U8 returnValue;

	returnValue = _mq_send((U32)rt_mq_send,mqdes,msg_ptr,msg_len,msg_prio);

	if (returnValue == BLOCK) //if we blocked and unblocked might be able to send message now so try
	{
		mq_send(mqdes, msg_ptr, msg_len, msg_prio);
	}

  if (returnValue ==  BLOCK)
  {
    returnValue = 0;
  }
   
	return returnValue;
}

int mq_receive(mqd_t mqdes, char *msg_ptr, size_t msg_len, unsigned int *msg_prio)
{
	U8 returnValue;

	returnValue =  _mq_receive((U32)rt_mq_receive,mqdes,msg_ptr,msg_len,msg_prio);

	if (returnValue == BLOCK) //if we blocked and unblocked might be able to send message now so try
	{
		mq_receive(mqdes, msg_ptr, msg_len, msg_prio);
	}

   if (returnValue ==  BLOCK)
  {
    returnValue = 0;
  }
	return returnValue;
}
