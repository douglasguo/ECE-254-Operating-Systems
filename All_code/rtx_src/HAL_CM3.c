/*----------------------------------------------------------------------------
 *      RL-ARM - RTX
 *----------------------------------------------------------------------------
 *      Name:    HAL_CM3.C
 *      Purpose: Hardware Abstraction Layer for Cortex-M3
 *      Rev.:    V4.20
 *----------------------------------------------------------------------------
 *      This code is part of the RealView Run-Time Library.
 *      Copyright (c) 2004-2011 KEIL - An ARM Company. All rights reserved.
 *---------------------------------------------------------------------------*/

#include "rt_TypeDef.h"
#include "RTX_Config.h"
#include "rt_System.h"
#include "rt_HAL_CM.h"
#include "rt_Task.h"
#include "rt_List.h"
#include "rt_MemBox.h"


/*----------------------------------------------------------------------------
 *      Global Variables
 *---------------------------------------------------------------------------*/

BIT dbg_msg;

/*----------------------------------------------------------------------------
 *      Functions
 *---------------------------------------------------------------------------*/


/*--------------------------- rt_set_PSP ------------------------------------*/

__asm void rt_set_PSP (U32 stack) {
        MSR     PSP,R0
        BX      LR
}


/*--------------------------- os_set_env ------------------------------------*/

__asm void os_set_env (void) {
   /* Switch to Unpriviliged/Priviliged Thread mode, use PSP. */
        MOV     R0,SP                   ; PSP = MSP
        MSR     PSP,R0
        LDR     R0,=__cpp(&os_flags)
        LDRB    R0,[R0]
        LSLS    R0,#31
        MOVNE   R0,#0x02                ; Priviliged Thread mode, use PSP
        MOVEQ   R0,#0x03                ; Unpriviliged Thread mode, use PSP
        MSR     CONTROL,R0
        BX      LR

        ALIGN
}


/*--------------------------- _alloc_box ------------------------------------*/

__asm void *_alloc_box (void *box_mem) {
   /* Function wrapper for Unpriviliged/Priviliged mode. */
        LDR     R12,=__cpp(rt_alloc_box)
        MRS     R3,IPSR
        LSLS    R3,#24
        BXNE    R12
        MRS     R3,CONTROL
        LSLS    R3,#31
        BXEQ    R12
        SVC     0
        BX      LR

        ALIGN
}


/*--------------------------- _free_box -------------------------------------*/

__asm int _free_box (void *box_mem, void *box) {
   /* Function wrapper for Unpriviliged/Priviliged mode. */
        LDR     R12,=__cpp(rt_free_box)
        MRS     R3,IPSR
        LSLS    R3,#24
        BXNE    R12
        MRS     R3,CONTROL
        LSLS    R3,#31
        BXEQ    R12
        SVC     0
        BX      LR

        ALIGN
}


/*-------------------------- SVC_Handler -----------------------------------*/

__asm void SVC_Handler (void) {
        PRESERVE8

        IMPORT  SVC_Count
        IMPORT  SVC_Table
        IMPORT  rt_stk_check

        MRS     R0,PSP                  ; Read PSP
        LDR     R1,[R0,#24]             ; Read Saved PC from Stack
        LDRH    R1,[R1,#-2]             ; Load Halfword
        BICS    R1,R1,#0xFF00           ; Extract SVC Number
        BNE     SVC_User

        LDM     R0,{R0-R3,R12}          ; Read R0-R3,R12 from stack
        BLX     R12                     ; Call SVC Function 

        MRS     R12,PSP                 ; Read PSP
        LDR     R3,=__cpp(&os_tsk)
        LDM     R3,{R1,R2}              ; os_tsk.run, os_tsk.new
        CMP     R1,R2
        BEQ     SVC_Exit                ; no task switch

        PUSH    {R2,R3}
        MOV     R3,#1
        CMP     R1,#0                   ; Runtask deleted?
        STRBNE  R3,[R1,#TCB_RETUPD]     ; os_tsk.run->ret_upd = 1
        STMDBNE R12!,{R4-R11}           ; Save Old context
        STRNE   R12,[R1,#TCB_TSTACK]    ; Update os_tsk.run->tsk_stack
        BLNE    rt_stk_check            ; Check for Stack overflow

        POP     {R2,R3}
        STR     R2,[R3]                 ; os_tsk.run = os_tsk.new

        LDR     R12,[R2,#TCB_TSTACK]    ; os_tsk.new->tsk_stack
        LDMIA   R12!,{R4-R11}           ; Restore New Context
        LDRH    R3,[R2,#TCB_RETUPD]     ; Update ret_val?
        MSR     PSP,R12                 ; Write PSP

        CBZ     R3,SVC_Return
        LDRB    R0,[R2,#TCB_RETVAL]     ; Write os_tsk.new->ret_val

SVC_Exit
        STR     R0,[R12]                ; Function return value

SVC_Return
        MVN     LR,#:NOT:0xFFFFFFFD     ; set EXC_RETURN value
        BX      LR

        /*------------------- User SVC ------------------------------*/

SVC_User
        PUSH    {R4,LR}                 ; Save Registers
        LDR     R2,=SVC_Count
        LDR     R2,[R2]
        CMP     R1,R2
        BHI     SVC_Done                ; Overflow

        LDR     R4,=SVC_Table-4
        LDR     R4,[R4,R1,LSL #2]       ; Load SVC Function Address

        LDM     R0,{R0-R3,R12}          ; Read R0-R3,R12 from stack
        BLX     R4                      ; Call SVC Function

        MRS     R12,PSP
        STM     R12,{R0-R3}             ; Function return values
SVC_Done
        POP     {R4,PC}                 ; RETI

        ALIGN
}


/*-------------------------- Sys_Handler ------------------------------------*/

__asm void Sys_Handler (void) {
        PRESERVE8

        EXPORT  SysTick_Handler
        EXPORT  PendSV_Handler

PendSV_Handler
        BL      __cpp(rt_pop_req)

Sys_Switch
        LDR     R3,=__cpp(&os_tsk)
        LDM     R3,{R1,R2}              ; os_tsk.run, os_tsk.new
        CMP     R1,R2
        BEQ     SysExit

        PUSH    {R2,R3}
        MOV     R3,#0
        STRB    R3,[R1,#TCB_RETUPD]     ; os_tsk.run->ret_upd = 0
        MRS     R12,PSP                 ; Read PSP
        STMDB   R12!,{R4-R11}           ; Save Old context
        STR     R12,[R1,#TCB_TSTACK]    ; Update os_tsk.run->tsk_stack
        BL      rt_stk_check            ; Check for Stack overflow

        POP     {R2,R3}
        STR     R2,[R3]                 ; os_tsk.run = os_tsk.new

        LDR     R12,[R2,#TCB_TSTACK]    ; os_tsk.new->tsk_stack
        LDMIA   R12!,{R4-R11}           ; Restore New Context
        MSR     PSP,R12                 ; Write PSP

        LDRB    R3,[R2,#TCB_RETUPD]     ; Update ret_val?
        CBZ     R3,SysExit
        LDRB    R3,[R2,#TCB_RETVAL]     ; Write os_tsk.new->ret_val
        STR     R3,[R12]
SysExit
        MVN     LR,#:NOT:0xFFFFFFFD     ; set EXC_RETURN value
        BX      LR                      ; Return to Thread Mode

SysTick_Handler
        BL      __cpp(rt_systick)
        B       Sys_Switch

        ALIGN
}


/*--------------------------- rt_init_stack ---------------------------------*/

void rt_init_stack (P_TCB p_TCB, FUNCP task_body) {
  /* Prepare TCB and saved context for a first time start of a task. */
  U32 *stk,i,size;

  /* Prepare a complete interrupt frame for first task start */
  size = p_TCB->priv_stack >> 2;
  if (size == 0) {
    size = (U16)os_stackinfo >> 2;
  }

  /* Write to the top of stack. */
  stk = &p_TCB->stack[size];

  /* Auto correct to 8-byte ARM stack alignment. */
  if ((U32)stk & 0x04) {
    stk--;
  }

  stk -= 16;

  /* Default xPSR and initial PC */
  stk[15] = INITIAL_xPSR;
  stk[14] = (U32)task_body;

  /* Clear R1-R12,LR registers. */
  for (i = 0; i < 14; i++) {
    stk[i] = 0;
  }

  /* Assign a void pointer to R0. */
  stk[8] = (U32)p_TCB->msg;

  /* Initial Task stack pointer. */
  p_TCB->tsk_stack = (U32)stk;

  /* Task entry point. */
  p_TCB->ptask = task_body;

  /* Set a magic word for checking of stack overflow. */
  p_TCB->stack[0] = MAGIC_WORD;
}


/*--------------------------- dbg_init --------------------------------------*/

void dbg_init (void) {
  if ((DEMCR & DEMCR_TRCENA)     && 
      (ITM_CONTROL & ITM_ITMENA) &&
      (ITM_ENABLE & (1UL << 31))) {
    dbg_msg = __TRUE;
  }
}


/*--------------------------- dbg_task_notify -------------------------------*/

void dbg_task_notify (P_TCB p_tcb, BOOL create) {
  while (ITM_PORT31_U32 == 0);
  ITM_PORT31_U32 = (U32)p_tcb->ptask;
  while (ITM_PORT31_U32 == 0);
  ITM_PORT31_U16 = (create << 8) | p_tcb->task_id;
}


/*--------------------------- dbg_task_switch -------------------------------*/

void dbg_task_switch (U32 task_id) {
  while (ITM_PORT31_U32 == 0);
  ITM_PORT31_U8 = task_id;
}


/*----------------------------------------------------------------------------
 * end of file
 *---------------------------------------------------------------------------*/

