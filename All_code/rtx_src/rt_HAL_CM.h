/*----------------------------------------------------------------------------
 *      RL-ARM - RTX
 *----------------------------------------------------------------------------
 *      Name:    RT_HAL_CM.H
 *      Purpose: Hardware Abstraction Layer for Cortex-M definitions
 *      Rev.:    V4.20
 *----------------------------------------------------------------------------
 *      This code is part of the RealView Run-Time Library.
 *      Copyright (c) 2004-2011 KEIL - An ARM Company. All rights reserved.
 *---------------------------------------------------------------------------*/

/* Definitions */
#define INITIAL_xPSR    0x01000000
#define DEMCR_TRCENA    0x01000000
#define ITM_ITMENA      0x00000001
#define MAGIC_WORD      0xE25A2EA5

/* NVIC SysTick registers */
#define NVIC_ST_CTRL    (*((volatile U32 *)0xE000E010))
#define NVIC_ST_RELOAD  (*((volatile U32 *)0xE000E014))
#define NVIC_ST_CURRENT (*((volatile U32 *)0xE000E018))
#define NVIC_INT_CTRL   (*((volatile U32 *)0xE000ED04))
#define NVIC_SYS_PRI2   (*((volatile U32 *)0xE000ED1C))
#define NVIC_SYS_PRI3   (*((volatile U32 *)0xE000ED20))

#define OS_PEND_IRQ()   NVIC_INT_CTRL  = (1<<28);
#define OS_TINIT()      NVIC_ST_RELOAD =  os_trv;                        \
                        NVIC_ST_CURRENT=  0;                             \
                        NVIC_ST_CTRL   =  0x0007;                        \
                        NVIC_SYS_PRI3 |=  0xFFFF0000;                    \
                        NVIC_SYS_PRI2 |=  (NVIC_SYS_PRI3<<1) & 0xFC000000;
#define OS_LOCK()       NVIC_ST_CTRL   =  0x0005;
#define OS_UNLOCK()     NVIC_ST_CTRL   =  0x0007;

/* Core Debug registers */
#define DEMCR           (*((volatile U32 *)0xE000EDFC))

/* ITM registers */
#define ITM_CONTROL     (*((volatile U32 *)0xE0000E80))
#define ITM_ENABLE      (*((volatile U32 *)0xE0000E00))
#define ITM_PORT30_U32  (*((volatile U32 *)0xE0000078))
#define ITM_PORT31_U32  (*((volatile U32 *)0xE000007C))
#define ITM_PORT31_U16  (*((volatile U16 *)0xE000007C))
#define ITM_PORT31_U8   (*((volatile U8  *)0xE000007C))

/* Variables */
extern BIT dbg_msg;

/* Functions */
#if defined(__TARGET_ARCH_7_M) || defined(__TARGET_ARCH_7E_M)
 #define rt_inc(p)     while(__strex((__ldrex(p)+1),p))
 #define rt_dec(p)     while(__strex((__ldrex(p)-1),p))
#else
 #define rt_inc(p)     __disable_irq();(*p)++;__enable_irq();
 #define rt_dec(p)     __disable_irq();(*p)--;__enable_irq();
#endif
__inline U32 rt_inc_qi (U32 size, U8 *count, U8 *first) {
  U32 cnt,c2;
#if defined(__TARGET_ARCH_7_M) || defined(__TARGET_ARCH_7E_M)
  do {
    if ((cnt = __ldrex(count)) == size) {
      __clrex();
      return (cnt); }
  } while (__strex(cnt+1, count));
  do {
    c2 = (cnt = __ldrex(first)) + 1;
    if (c2 == size) c2 = 0;
  } while (__strex(c2, first));
#else
  __disable_irq();
  if ((cnt = *count) < size) {
    *count = cnt+1;
    c2 = (cnt = *first) + 1;
    if (c2 == size) c2 = 0;
    *first = c2; 
  }
  __enable_irq ();
#endif
  return (cnt);
}

#define rt_tmr_init()   OS_TINIT();
extern void rt_init_stack (P_TCB p_TCB, FUNCP task_body);
extern void rt_set_PSP (U32 stack);
extern void os_set_env (void);
extern void *_alloc_box (void *box_mem);
extern int  _free_box (void *box_mem, void *box);

extern void dbg_init (void);
extern void dbg_task_notify (P_TCB p_tcb, BOOL create);
extern void dbg_task_switch (U32 task_id);

#ifdef DBG_MSG
#define DBG_INIT() dbg_init()
#define DBG_TASK_NOTIFY(p_tcb,create) if (dbg_msg) dbg_task_notify(p_tcb,create)
#define DBG_TASK_SWITCH(task_id)      if (dbg_msg && (os_tsk.new!=os_tsk.run)) \
                                                   dbg_task_switch(task_id)
#else
#define DBG_INIT()
#define DBG_TASK_NOTIFY(p_tcb,create)
#define DBG_TASK_SWITCH(task_id)
#endif

/*----------------------------------------------------------------------------
 * end of file
 *---------------------------------------------------------------------------*/

