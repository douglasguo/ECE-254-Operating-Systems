#include "rt_TypeDef.h"
#include "RTX_Config.h"
#include "rt_System.h"
#include "rt_MemBox.h"
#include "rt_HAL_CM.h"
#include "rt_List.h"
#include "rt_Task.h"
#include <errno.h>

//these are included for debugging purposes to be able to call printf when debugging 
#include <stdio.h>
#include <stdlib.h>
#include "Serial.h"

//macro definitions

#define MAXMESSAGES 10
#define MAXPROCESSESPERQUEUE 10
#define MAXQUEUES 10
#define MAXBLOCKEDTASKS 10
#define QUEUEEMPTY 1

//type definitions

//structs to store information for processes blocked waiting to send / receive messages

struct blocked
{
	OS_TID blockedTasks[MAXBLOCKEDTASKS];
	int numBlocked;
};

typedef struct blocked blocked;

//struct to store process info for processes currently using queue
struct processInfo
{
	OS_TID taskId;
	int oflag;
	U8 inuse;
};

typedef struct processInfo processInfo;

//struct to contain information for each message
struct message
{
	unsigned int priority;
	char *msg_ptr;
	size_t msg_size;
	
};

typedef struct message message;


//struct to hold all information pertaining to each queue 
struct mqueue
{
	message messages[MAXMESSAGES];
	processInfo	processInfos[MAXPROCESSESPERQUEUE];
	blocked blockedSenders;
	blocked blockedReceivers;
	int nummessages;
	char *name;
	mqd_t descriptor;
	U8 inuse;
};

typedef struct mqueue mqueue;




mqueue mqueues[MAXQUEUES];
int numqueues = 0;


//forward declarations


//heap functions
message removemax(mqueue *msgqueue);
void insert(mqueue *msgqueue, message toInsert);
void printheap(mqueue msgqueue, int rootlocation);
void print(mqueue msgqueue);

//message queue functions
mqd_t rt_mq_open(const char *name, int oflag);
int rt_mq_close(mqd_t mqdes);
int rt_mq_send(mqd_t mqdes, const char *msg_ptr, size_t msg_len, unsigned msg_prio);
int rt_mq_receive(mqd_t mqdes, char *msg_ptr, size_t msg_len, unsigned *msg_prio);


//create a priority queue using a heap stored in an array
//Functions for manipulating priority queue in terms of a heap



//removes maximum element in heap used as priority queue
message removemax(mqueue *msgqueue)
{
	int done = 0;
	int parentlocation;
	int childlocation;
	message swap;
	message highestprio;

		print(*msgqueue);

	//replace value in root with value at end of array which corresponds to last element in heap

	parentlocation = 1;
	highestprio = msgqueue->messages[parentlocation];	   //save the message with highest priority that is going to be returned
	msgqueue->messages[parentlocation] = msgqueue->messages[msgqueue->nummessages];

	while(!done)
	{
		//first determine which child to compare to

		//check if the left child exists
		if (parentlocation * 2 < msgqueue->nummessages )
		{
			//left child exists check if right exists
			if(parentlocation * 2 + 1 < msgqueue->nummessages )
			{
				//both exist find largest priority
				if(msgqueue->messages[parentlocation * 2].priority >= msgqueue->messages[parentlocation * 2 + 1].priority)
				{
					childlocation = parentlocation * 2;
				}
				else //right is bigger use it
				{
					childlocation = parentlocation * 2 + 1;
				}
			}
			else //right doesn't exist use left
			{
				childlocation = parentlocation * 2 + 1;
			}

			//see if we need to swap
			if(msgqueue->messages[childlocation].priority > msgqueue->messages[parentlocation].priority)
			{
				swap = msgqueue->messages[parentlocation];
				msgqueue->messages[parentlocation] = msgqueue->messages[childlocation];
				msgqueue->messages[childlocation] = swap;

				parentlocation = childlocation;

			}
			else //don't need to swap were done
			{
				done = 1;
			}
		}
		else //no child exists we are done
		{
			done = 1;
		}
	}
		

	--msgqueue->nummessages;

	print(*msgqueue);
	return highestprio;
	
}


//insert assumes size has been checked outside and that message is valid to be inserted

//inserts value into priority queue
void insert(mqueue *msgqueue,message toInsert)
{
	int parentlocation;
	int childlocation;
	message swap;
	int done = 0;

	//want to insert child at whatever space is available on the current level
	//this is done by adding it as the last element in the array

	msgqueue->messages[msgqueue->nummessages+1] = toInsert;

	//now need to make sure this value is less then parent if not swap
	//first check if parent exists

	childlocation = msgqueue->nummessages + 1;
	parentlocation = childlocation / 2 ;

	while(parentlocation > 0 && !done)
	{
		//check if child is bigger then parent
		if(msgqueue->messages[childlocation].priority >  msgqueue->messages[parentlocation].priority)
		{
			//if so swap them
			swap = msgqueue->messages[parentlocation];
			msgqueue->messages[parentlocation] = msgqueue->messages[childlocation];
			msgqueue->messages[childlocation] = swap;
		}
		else //child not bigger then parent we are done
		{
			done = 1;
		}

		childlocation = parentlocation;
		parentlocation = childlocation / 2;
	}




}


//functions for printing heap for debugging purposes
void printheap(mqueue msgqueue, int rootpos)
{
	if(rootpos> msgqueue.nummessages)
	{
		return;
	}
	printheap(msgqueue,rootpos * 2);
	printf("   message: '%s' | message size: %d | priority: %d | arraypos: %d\n",msgqueue.messages[rootpos].msg_ptr, msgqueue.messages[rootpos].msg_size, msgqueue.messages[rootpos].priority,rootpos);
	printheap(msgqueue,rootpos * 2 + 1);

}

void print(mqueue msgqueue)
{

	printf("   Queue information -> queuename: '%s' | nummessages: %d\n",msgqueue.name,msgqueue.nummessages); 
	printheap(msgqueue,1);
	printf("\n\n");
}



//open a queue do various things based on value of oflag as defined in POSIX definitions
mqd_t rt_mq_open(const char *name, int oflag)
{

	U8 queueon;
	U8 action= 0;
	U8 queuelocation;
	U8 processon;
	U8 found = 0;

	//check for permissions if none specified default to R/W
	if ( ((oflag &  O_RDONLY) == 0) && ((oflag & O_WRONLY) ==0) && ((oflag & O_RDWR) ==0))
	{
		oflag = oflag | O_RDWR;
	}


	//check for reasons of failure

	if ( (oflag & O_EXCL) != 0  &&  (oflag & O_CREAT) != 0 ) //we only wish to create a message queue if it does not already exist
	{
		//check if message queue exists
		for (queueon = 0; queueon < MAXQUEUES; queueon ++)
		{
			if(mqueues[queueon].name == name && mqueues[queueon].inuse )
			{
				//message queue already exists set appropriate error and return
				return EEXIST;
			}
		}

		action = 1; //if we got here wish to create a message queue


	}
	if ((oflag & O_CREAT != 0) && (oflag & O_EXCL == 0))
	{
		//if we just wish to create a queue not caring if it already exists

		//check if message queue exists
		for (queueon = 0; queueon < MAXQUEUES; queueon ++)
		{
			if(mqueues[queueon].name == name && mqueues[queueon].inuse)
			{
				//message queue already exists do nothinig
				queuelocation = queueon;
				found = 1;
				break;
			}
		}
		if (!found)
		{
			//message queue didn't already exist therefore we wish to create it
			action = 1;
		}
	}


	//if not creating new queue make sure selected queue exists
	if( (oflag & O_CREAT) == 0)
	{
		for (queueon = 0; queueon < MAXQUEUES; queueon ++)
		{
			if(mqueues[queueon].name == name && mqueues[queueon].inuse)
			{
				queuelocation = queueon;
				found = 1;
				break; //queue exists were good
				
			}
		}
		
		if (!found)
		{
			//queue didnt exist set error and return
			return ENOENT;
		}

		//if we got here wish to open existing queue
		action = 2;


	}


	//try and create messagequeue
	if(action == 1 && numqueues == MAXQUEUES)
	{
		return ENFILE;
	}
	if (action == 1)
	{
		//check for space			  --current queues precreated and have 10 of them so there is automatically space because they already exist
		//create queue here		  	  --dont actually create because already exists return descriptor
		for ( queueon =0; queueon < MAXQUEUES; queueon++)
		{
			if (mqueues[queueon].inuse == 0)
			{
				mqueues[queueon].name = (char *)name;
				mqueues[queueon].descriptor = queueon;
				mqueues[queueon].inuse = 1;

				//we created this queue so we are first process to use it
				mqueues[queueon].processInfos[0].oflag = oflag;
				mqueues[queueon].processInfos[0].taskId = rt_tsk_self();
				mqueues[queueon].processInfos[0].inuse = 1;

				break;
			}
		}

		++numqueues;

		return mqueues[queueon].descriptor;
	}

	//try and open messagequeue
	if(action == 2)
	{

		//attach our task to the message queue

		for(processon = 0; processon < MAXPROCESSESPERQUEUE; processon++)
		{
			if(mqueues[queuelocation].processInfos[processon].inuse == 0)
			{
				mqueues[queuelocation].processInfos[processon].inuse = 1;
				mqueues[queuelocation].processInfos[processon].oflag = oflag;
				mqueues[queuelocation].processInfos[processon].taskId = rt_tsk_self();
				break;
			}
		}
		 
		//return descriptor of messagequeue
		return mqueues[queuelocation].descriptor ;
	}


	return (mqd_t)-1;
}

int rt_mq_close(mqd_t mqdes)
{
	U8 processon;

	for (processon = 0; processon < MAXPROCESSESPERQUEUE; processon++)
	{
		if ((mqueues[mqdes].processInfos[processon].taskId == rt_tsk_self()) &&  mqueues[mqdes].processInfos[processon].inuse == 1)
		{
			mqueues[mqdes].processInfos[processon].inuse = 0;
			return 0;
		}
	}

	return EBADF;

}

int rt_mq_send(mqd_t mqdes, const char *msg_ptr, size_t msg_len, unsigned int msg_prio)
{
	

	U8 processon;
	message toInsert;
	int oflag = -1;
	OS_TID ID;
	U8 taskOn;
	P_TCB taskContext;
	P_TCB myContext;

	myContext = os_active_TCB[rt_tsk_self()];


	//check if passed a valid queue descriptor

	if(mqdes > MAXQUEUES - 1)
	{
		return EBADF;
	}
	//check we have a valid message
	if (msg_ptr == NULL )
	{
		return EINVAL;
	}

	//load flags for current process
	for (processon = 0; processon < MAXPROCESSESPERQUEUE; processon++)
	{
		if ((mqueues[mqdes].processInfos[processon].taskId == rt_tsk_self()) &&  mqueues[mqdes].processInfos[processon].inuse == 1)
		{
			oflag = mqueues[mqdes].processInfos[processon].oflag; 
		}	
	}

  if (oflag == -1)
  {
    return EBADF;
  }

	//check if process has permissions to send message
	if(	(oflag & O_RDONLY) != 0)
	{
		return EBADF;
	}

	//check to make sure there is space for another message

	if(mqueues[mqdes].nummessages >= MAXMESSAGES)
	{
		if ( (oflag & O_NONBLOCK) != 0)	 //if non block flag is set just return an error
		{
			return EAGAIN;
		}
		else //otherwise block and signal we have done so
		{
			myContext = os_active_TCB[rt_tsk_self() - 1];
			myContext->ret_val = BLOCK;

			ID = rt_tsk_self();

			//add process to blocked list for this particular queue
			mqueues[mqdes].blockedSenders.blockedTasks[mqueues[mqdes].blockedSenders.numBlocked] = ID;

			//increment the number of processes blocked for this particular queue
			++mqueues[mqdes].blockedSenders.numBlocked;

			
	
  			rt_block(0xffff,INACTIVE);


			return BLOCK; 
		}
		
	}

	//send the message

	toInsert.priority = msg_prio;
	toInsert.msg_size = msg_len;
	toInsert.msg_ptr = (char *)rt_mem_alloc(msg_len,(unsigned char) 0);
	memcpy((void *)toInsert.msg_ptr,(void *)msg_ptr,msg_len);
	insert(&mqueues[mqdes], toInsert);
  	++mqueues[mqdes].nummessages;
	print(mqueues[mqdes]);

	//unblock any processes blocked waiting for a message on the queue I'm sending a message to

	for (taskOn = 0; taskOn < mqueues[mqdes].blockedReceivers.numBlocked; taskOn++)
	{

		taskContext = os_active_TCB[mqueues[mqdes].blockedReceivers.blockedTasks[taskOn]];
		taskContext->state = READY;
	  	rt_put_prio(&os_rdy,taskContext);
	}
	  
	mqueues[mqdes].blockedReceivers.numBlocked = 0;

	myContext->ret_val = 0;
	return 0;
}

int rt_mq_receive(mqd_t mqdes, char *msg_ptr, size_t msg_len, unsigned int *msg_prio)
{
	message readMessage;
	U8 processon;
	OS_TID ID;
	U8 taskOn;
	P_TCB taskContext;
	P_TCB myContext;
	int oflag = -1;
	int tmp;


	

	//check if passed a valid queue descriptor

	if(mqdes > MAXQUEUES - 1)
	{
		return EBADF;
	}


	//load flags for current process
	for (processon = 0; processon < MAXPROCESSESPERQUEUE; processon++)
	{
		tmp = rt_tsk_self();
		if ((mqueues[mqdes].processInfos[processon].taskId == rt_tsk_self()) &&  mqueues[mqdes].processInfos[processon].inuse == 1)
		{
			oflag = mqueues[mqdes].processInfos[processon].oflag; 
		}	
	}
  
  if (oflag == -1)
  {
    return EBADF;
  }

	if (oflag & O_WRONLY == 1)
	{
		return EBADF;
	}

	
  //check if there is a message to be read
  if(mqueues[mqdes].nummessages <= 0)
  {
   	if ( (oflag & O_NONBLOCK) != 0)	 //if non block flag is set just return an error
		{

			return EAGAIN;
		}
		else //otherwise block and signal we have done so
		{

			myContext = os_active_TCB[rt_tsk_self() - 1];
			myContext->ret_val = BLOCK;

			ID = rt_tsk_self();

			//add process to blocked list for this particular queue
			mqueues[mqdes].blockedReceivers.blockedTasks[mqueues[mqdes].blockedReceivers.numBlocked ] = ID;

			//increment the number of processes blocked for this particular queue
			++mqueues[mqdes].blockedReceivers.numBlocked;
  			rt_block(0xffff,INACTIVE);

		
			return BLOCK; 
		}

  }
  
	//now read the message

	readMessage = removemax(&mqueues[mqdes]);

	//make sure we have read a valid message

	if (readMessage.msg_ptr == 0 || readMessage.msg_size < 0)
	{
		myContext->ret_val = EINVAL;
		return EINVAL;
	}

 
 // printf("   real message: %s msgsize: %d", readMessage.msg_ptr,readMessage.msg_size);
  memcpy((void *)msg_ptr,(void *)readMessage.msg_ptr,readMessage.msg_size);
	*msg_prio = readMessage.priority;

  rt_mem_free((void*)readMessage.msg_ptr);

	//now that we have read a message unblock any process waiting to send a message to this queue

	for (taskOn = 0; taskOn < mqueues[mqdes].blockedSenders.numBlocked; taskOn++)
	{
		taskContext = os_active_TCB[mqueues[mqdes].blockedSenders.blockedTasks[taskOn]-1];
		taskContext->state = READY;
	  	rt_put_prio(&os_rdy,taskContext);
	}
	  
	mqueues[mqdes].blockedSenders.numBlocked = 0;

	myContext->ret_val = readMessage.msg_size;
	return readMessage.msg_size;


}

