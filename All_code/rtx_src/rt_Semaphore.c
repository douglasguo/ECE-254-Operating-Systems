/*----------------------------------------------------------------------------
 *      RL-ARM - RTX
 *----------------------------------------------------------------------------
 *      Name:    RT_SEMAPHORE.C
 *      Purpose: Implements binary and counting semaphores
 *      Rev.:    V4.20
 *----------------------------------------------------------------------------
 *      This code is part of the RealView Run-Time Library.
 *      Copyright (c) 2004-2011 KEIL - An ARM Company. All rights reserved.
 *---------------------------------------------------------------------------*/

#include "rt_TypeDef.h"
#include "RTX_Config.h"
#include "rt_System.h"
#include "rt_List.h"
#include "rt_Task.h"
#include "rt_Semaphore.h"


/*----------------------------------------------------------------------------
 *      Functions
 *---------------------------------------------------------------------------*/


/*--------------------------- rt_sem_init -----------------------------------*/

void rt_sem_init (OS_ID semaphore, U16 token_count) {
  /* Initialize a semaphore */
  P_SCB p_SCB = semaphore;

  p_SCB->cb_type = SCB;
  p_SCB->p_lnk  = NULL;
  p_SCB->tokens = token_count;
}


/*--------------------------- rt_sem_send -----------------------------------*/

OS_RESULT rt_sem_send (OS_ID semaphore) {
  /* Return a token to semaphore */
  P_SCB p_SCB = semaphore;
  P_TCB p_TCB;

  if (p_SCB->p_lnk != NULL) {
    /* A task is waiting for token */
    p_TCB = rt_get_first ((P_XCB)p_SCB);
    p_TCB->ret_val = OS_R_SEM;
    rt_rmv_dly (p_TCB);
    rt_dispatch (p_TCB);
    os_tsk.run->ret_val = OS_R_OK;
  }
  else {
    /* Store token. */
    p_SCB->tokens++;
  }
  return (OS_R_OK);
}


/*--------------------------- rt_sem_wait -----------------------------------*/

OS_RESULT rt_sem_wait (OS_ID semaphore, U16 timeout) {
  /* Obtain a token; possibly wait for it */
  P_SCB p_SCB = semaphore;

  if (p_SCB->tokens) {
    p_SCB->tokens--;
    return (OS_R_OK);
  }
  /* No token available: wait for one */
  if (timeout == 0) {
    return (OS_R_TMO);
  }
  if (p_SCB->p_lnk != NULL) {
    rt_put_prio ((P_XCB)p_SCB, os_tsk.run);
  }
  else {
    p_SCB->p_lnk = os_tsk.run;
    os_tsk.run->p_lnk = NULL;
    os_tsk.run->p_rlnk = (P_TCB)p_SCB;
  }
  rt_block(timeout, WAIT_SEM);
  return (OS_R_TMO);
}


/*--------------------------- isr_sem_send ----------------------------------*/

void isr_sem_send (OS_ID semaphore) {
  /* Same function as "os_sem"send", but to be called by ISRs */
  P_SCB p_SCB = semaphore;

  rt_psq_enq (p_SCB, 0);
  rt_psh_req ();
}


/*--------------------------- rt_sem_psh ------------------------------------*/

void rt_sem_psh (P_SCB p_CB) {
  /* Check if task has to be waken up */
  P_TCB p_TCB;

  if (p_CB->p_lnk != NULL) {
    /* A task is waiting for token */
    p_TCB = rt_get_first ((P_XCB)p_CB);
    rt_rmv_dly (p_TCB);
    p_TCB->state   = READY;
    p_TCB->ret_val = OS_R_SEM;
    rt_put_prio (&os_rdy, p_TCB);
  }
  else {
    /* Store token */
    p_CB->tokens++;
  }
}

/*----------------------------------------------------------------------------
 * end of file
 *---------------------------------------------------------------------------*/

