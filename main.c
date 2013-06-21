/**
 * @brief: A simple RL-RTX application with printf retargetd to UART so that
 *         you observer printf output in UART #2 window inside simulator when
 *         debugging
 */

//System files
#include <LPC17xx.h>
#include <system_LPC17xx.h>
#include "RTL.h"
#include <math.h>

//Output files
#include <stdio.h>
#include <stdlib.h>
#include "Serial.h"

//Defines
#define P 1
#define C 2
#define N 100
#define B 32
#define DELAY 10

#define EVER ;;

//Symbol defined in the scatter file
//refer to RVCT Linker User Guide
extern unsigned int Image$$RW_IRAM1$$ZI$$Limit;

//Forward Declarations
__task void BasicTest(void);
__task void Sender(void);
__task void Receiver(void);
__task void OpenCloseTest(void);
__task void NonBlockingTest(void);
__task void BlockingTest(void);
__task void BlockUnblockTest(void);
__task void Block(void);
__task void Unblock(void);
__task void SendBlockTest(void);
__task void MultiQueueTest(void);
__task void Lab2Test(void);
__task void Producer(void);
__task void Consumer(void);
__task void clock(void);

void finalize(void);

//Global variables
OS_MUT mutex_mailbox;
OS_MUT mutex_timing;

OS_SEM semRead;
OS_SEM semWrite;

int timingDisplayed = 0;

int produced = 0, consumed = 0;
int PID = 0, CID = 0;
int QID;

int displayLine = 0;
int second = 0;
int decimal = 0;
int startSec = 0;
int startDec = 0;
int endSec = 0;
int endDec = 0;


/******************************************************************************
 * @brief: Basic Test
 ******************************************************************************/
__task void BasicTest(void)
{
	printf("\n   ***BASIC TEST***\n");
  printf("   - Sends and receives messages of various sizes\n");
  printf("   - Does not block\n\n");
 
  printf("   Queue descripter 0x%x\n",mq_open("queue1",O_CREAT | O_EXCL));
  
  os_tsk_create(Sender,1);
  os_tsk_create(Receiver,1);
  
  os_tsk_delete_self();
}

__task void Sender(void)
{
	unsigned char smsg[10];
  int count;

  printf("   Queue descripter 0x%x\n",mq_open("queue1",0));

  for (count = 0; count < 10; count++)
  {
    smsg[count] = 0;
  }
	
  for (count = 0; count < 10; count++)
  {
    sprintf(&smsg[count],"%d",count);
    mq_send(0,smsg,count+1,count+1);
    os_dly_wait(1);
  }
  
	os_tsk_delete_self();
}

__task void Receiver(void)
{
  char rmsg[100];
  size_t msglen;
  unsigned int priority;
  int count;
  int count2;

  printf("   Queue descripter 0x%x\n",mq_open("queue1",0));

  for (count = 0 ; count < 10; count++)
  {
	  os_dly_wait(2);
    
    msglen = mq_receive(0,rmsg,msglen,&priority);
	  printf("   received message: %s  with priority: %d and size: %d\n\n",rmsg,priority,msglen);
    
	  for (count2 = 0; count2 < 100; count2++)
  	{
  		rmsg[count2] = 0;
  	}
  }

  os_tsk_delete_self();
}

/******************************************************************************
 * @brief: Open and Close Test
 ******************************************************************************/
__task void OpenCloseTest(void)
{
	printf("\n   ***OPEN AND CLOSE TEST***\n");
  printf("   - Sends a message while the queue is open and while\n     the queue is closed, comparing return values\n");
  printf("   - Does not block\n\n");
  
	printf("   Openning Queue...\n");
	printf("   Queue descripter 0x%x\n",mq_open("queue1",O_CREAT | O_EXCL));
	printf("   Making sure queue is open by sending one message ... \n");
	printf("   return code from send while queue is open: %d\n",mq_send(0,"1",1,1));
	printf("   return code from closing queue: %d \n", mq_close(0));
	printf("   return code from send while queue is closed: %d\n",mq_send(0,"1",1,1));
  
	os_tsk_delete_self();
}

/******************************************************************************
 * @brief: Non-Blocking Test
 ******************************************************************************/
__task void NonBlockingTest(void)
{
	char rmsg[100];
	size_t msglen;
	unsigned int priority;
  
	printf("\n   ***NON-BLOCKING TEST***\n");
  printf("   - Tries to receive a message that does not exist\n");
  printf("   - Does not block\n\n");
	
	printf("   Queue descripter 0x%x\n",mq_open("queue1",O_CREAT | O_EXCL | O_NONBLOCK));
	printf("   Creating Receiving task which should not block \n");

	printf("   mq_receive returned : %d \n", mq_receive(0,rmsg,msglen,&priority)); 

	os_tsk_delete_self();
}

/******************************************************************************
 * @brief: Blocking Test
 ******************************************************************************/
__task void BlockingTest(void)
{
	printf("\n   ***BLOCKING TEST***\n");
  printf("   - Tries to receive a message that does not exist\n");
  printf("   - Blocks until the message is available (never)\n\n");
  
  os_tsk_create (Block,1);
  
	os_tsk_delete_self();
}

/******************************************************************************
 * @brief: Block/Unblock Test
 ******************************************************************************/
__task void BlockUnblockTest(void)
{
  printf("\n   ***BLOCK/UNBLOCK TEST***\n");
  printf("   - Tries to receive a message that does not exist\n");
  printf("   - Blocks until the message is available (from another task)\n\n");
  
	os_tsk_create(Block,1);
	os_dly_wait(1);
	os_tsk_create(Unblock,1);

	os_tsk_delete_self();
}

__task void Block(void)
{
	char rmsg[100];
  size_t msglen;
  unsigned int priority;
  
	printf("   Queue descripter 0x%x\n",mq_open("queue1",O_CREAT | O_EXCL));
	printf("   Creating Receiving task which should block as no messages\n");
	printf("   mq_receive returned : %d \n", mq_receive(0,rmsg,msglen,&priority));
	printf("   received message: %s  with priority: %d and size: %d\n\n",rmsg,priority,msglen);
  
  os_tsk_delete_self ();
}

__task void Unblock(void)
{
  printf("   Queue descripter 0x%x\n",mq_open("queue1",0));
  
  mq_send(0,"a",1,1);
  
  printf("   Sent message other task should unblock \n");

	os_tsk_delete_self();
}

/******************************************************************************
 * @brief: Send Block Test
 ******************************************************************************/
__task void SendBlockTest(void)
{
  int count;
  
  printf("\n   ***SEND BLOCK TEST***\n");
  printf("   - Sends messages until the queue is full\n");
  printf("   - Sends an additional message to force the queue to block\n");
  printf("   - A message is received in another task, allowing the last message to send\n\n");
  
	printf("   Queue descripter 0x%x\n",mq_open("queue1",O_CREAT | O_EXCL));
  printf("   Filling queue...\n");
  
  for (count = 0; count < 11; count++)
  {
    mq_send(0,"ab",1,2);
  }
  


  printf("   Done Sending\n");
  
  os_tsk_delete_self ();
}



/******************************************************************************
 * @brief: Multi-Queue Test
 ******************************************************************************/
__task void MultiQueueTest(void)
{
	char rmsg[100];
  size_t msglen;
  unsigned int priority;
  int qid1, qid2;
  
  printf("\n   ***MULTI-QUEUE TEST***\n");
  printf("   - Sends and receives messages using two different queues\n\n");
  
  qid1 = mq_open("queue1",O_CREAT | O_EXCL);
	printf("   Queue descripter 0x%x\n",qid1);
  
  qid2 = mq_open("queue2",O_CREAT | O_EXCL);
	printf("   Queue descripter 0x%x\n",qid2);
  
  printf("   Sending message to queue1\n");
  mq_send(qid1,"a",1,1);
  
  printf("   Sending message to queue2\n");
  mq_send(qid2,"b",1,1);
  
  printf("   Message received from queue2: %d \n", mq_receive(qid2,rmsg,msglen,&priority));
  printf("   Message received from queue1: %d \n", mq_receive(qid1,rmsg,msglen,&priority));
  
  printf("   Done");
  
  os_tsk_delete_self ();
}

/******************************************************************************
 * @brief: Lab 2 Test
 ******************************************************************************/
__task void Lab2Test(void)
{
  int count = 0;
  
  printf("\n   ***LAB 2 TEST***\n");
  printf("   - Lab 2 implemented using the Posix message queue\n\n");
  
  //Clock
  os_tsk_create (clock, 255);
  
  //Semaphores and mutex
  os_mut_init (mutex_mailbox);
  os_mut_init (mutex_timing);
  os_sem_init (semWrite, B);
  os_sem_init (semRead, 0);
  
  QID = mq_open("Lab2Queue",O_CREAT | O_EXCL);
	printf("   Queue descripter 0x%x\n",QID);
  
  //Producers
  for (count = 0; count < P; count++)
  {
    os_tsk_create (Producer,2);
  }
  
  //Consumers
  for (count = 0; count < C; count++)
  {
    os_tsk_create (Consumer,2);
  }
  
  //Store the initialization time
  startSec = second;
  startDec = decimal;
  
  //Housekeeping
  os_tsk_delete_self ();
}

__task void Producer(void)
{
  char Message[5];
  int pid = PID++;
  
  os_dly_wait (5);
  mq_open("Lab2Queue", 0);
  
  for (EVER)
  {
    if ((produced % P) == pid)
    {
      //Wait for the mailbox to have free space
      os_sem_wait (semWrite, 0xffff);
      
      //Wait for the ciritcal section to be available
      os_mut_wait (mutex_mailbox, 0xffff);
      
      sprintf (Message, "%d", produced);
      Message[4] =0;
      mq_send(QID,Message,5,1);
      
//	    printf("   Message sent: %d\n",produced);
      
      produced++;
      
      //Housekeeping
      os_mut_release (mutex_mailbox);
      os_sem_send (semRead);
    }
    
    if (produced == N) break;
    
    os_dly_wait (DELAY);
  }
  
  os_tsk_delete_self ();
}

__task void Consumer(void)
{
  char Message[5];
  int cid = CID++;
  int root, received;
  int compare;
  size_t msglen;
  unsigned int priority;
  
  mq_open("Lab2Queue", 0);
  
  for (EVER)
  {
    //Wait for the mailbox to have free space
    os_sem_wait (semRead, 0xffff);
    
    //Wait for the ciritcal section to be available
    os_mut_wait (mutex_mailbox, 0xffff);
    
  	mq_receive (QID,Message,msglen,&priority);
    
    //Consume the value
    received = strtol (Message,0,10);
    root = sqrt (received);
    compare = root*root;
    
    if (compare == received)
    {
      printf ("   Received: %d\n", received);
    }
    
    consumed++;
    
    //Housekeeping
    os_mut_release (mutex_mailbox);
    os_sem_send (semWrite);
    
    if (consumed == N) break;
    
    os_dly_wait (DELAY);
  }
  
  finalize ();
  
  os_tsk_delete_self ();
}

/**
 * A clock with a period of 1 millisecond
 **/
__task void clock (void)
{
  os_itv_set (10);
  
  for (EVER)
  {
    decimal++;
    
    if (decimal == 10)
    {
      second++;
      decimal = 0;
    }
    
    os_itv_wait ();
  }
}

void finalize (void)
{
  //char strMessage [32];
  
  os_mut_wait (mutex_timing, 0xffff);
  
  //Only one process should display the timing summary
  if (!timingDisplayed)
  {
    //Store end time
    endSec = second;
    endDec = decimal;
    
    //sprintf (strMessage, "Init: %u.%04u s", startSec, startDec);
    //Display ((unsigned char*) strMessage);
    
    printf ("Init: %u.%04u s", startSec, startDec);
    
    //sprintf (strMessage, "Done: %u.%04u s", endSec, endDec);
    //Display ((unsigned char*) strMessage);
    
    printf ("Done: %u.%04u s", endSec, endDec);
    
    timingDisplayed = 1;
  }
  
  os_mut_release (mutex_timing);
}

/******************************************************************************
 * @brief: Program Entry Point
 ******************************************************************************/
int main ()
{
  SystemInit();
  
  // initialize the 2nd serial port (UART#2 in simulator)
	// UART index starts from 0 in code
	// UART index starts from 1 in simulator
	SER_init(1);
	
	//os_sys_init(BasicTest);
	//os_sys_init(OpenClose);
	os_sys_init(NonBlockingTest);
//	os_sys_init(BlockingTest);
	//os_sys_init(BlockUnblockTest);
  //os_sys_init(SendBlockTest); 
  //os_sys_init(MultiQueueTest);
  //os_sys_init(Lab2Test);
  
	return 0;
}
