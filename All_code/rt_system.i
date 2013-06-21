#line 1 "rtx_src\\rt_System.c"









 

#line 1 "rtx_src\\rt_TypeDef.h"









 




#line 21 "rtx_src\\rt_TypeDef.h"

#line 29 "rtx_src\\rt_TypeDef.h"




 
typedef char               S8;
typedef unsigned char      U8;
typedef short              S16;
typedef unsigned short     U16;
typedef int                S32;
typedef unsigned int       U32;
typedef long long          S64;
typedef unsigned long long U64;
typedef unsigned char      BIT;
typedef unsigned int       BOOL;
typedef void               (*FUNCP)(void);

typedef U32     OS_TID;
typedef void    *OS_ID;
typedef U32     OS_RESULT;
typedef S16			mqd_t;
typedef unsigned int			size_t;


 



typedef struct OS_TCB {
   
  U8     cb_type;                  
  U8     state;                    
  U8     prio;                     
  U8     task_id;                  
  struct OS_TCB *p_lnk;            
  struct OS_TCB *p_rlnk;           
  struct OS_TCB *p_dlnk;           
  struct OS_TCB *p_blnk;           
  U16    delta_time;               
  U16    interval_time;            
  U16    events;                   
  U16    waits;                    
  void   **msg;                    
  U8     ret_val;                  

   
  U8     ret_upd;                  
  U16    priv_stack;               
  U32    tsk_stack;                
  U32    *stack;                   

   
  FUNCP  ptask;                    
} *P_TCB;




typedef struct OS_PSFE {           
  void  *id;                       
  U32    arg;                      
} *P_PSFE;

typedef struct OS_PSQ {            
  U8     first;                    
  U8     last;                     
  U8     count;                    
  U8     size;                     
  struct OS_PSFE q[1];             
} *P_PSQ;

typedef struct OS_TSK {
  P_TCB  run;                      
  P_TCB  new;                      
} *P_TSK;

typedef struct OS_ROBIN {          
  P_TCB  task;                     
  U16    time;                     
  U16    tout;                     
} *P_ROBIN;

typedef struct OS_XCB {
  U8     cb_type;                  
  struct OS_TCB *p_lnk;            
  struct OS_TCB *p_rlnk;           
  struct OS_TCB *p_dlnk;           
  struct OS_TCB *p_blnk;           
  U16    delta_time;               
} *P_XCB;

typedef struct OS_MCB {
  U8     cb_type;                  
  U8     isr_st;                   
  struct OS_TCB *p_lnk;            
  U16    first;                    
  U16    last;                     
  U16    count;                    
  U16    size;                     
  void   *msg[1];                  
} *P_MCB;

typedef struct OS_SCB {
  U8     cb_type;                  
  U16    tokens;                   
  struct OS_TCB *p_lnk;            
} *P_SCB;

typedef struct OS_MUCB {
  U8     cb_type;                  
  U8     prio;                     
  U16    level;                    
  struct OS_TCB *p_lnk;            
  struct OS_TCB *owner;            
} *P_MUCB;

typedef struct OS_XTMR {
  struct OS_TMR  *next;
  U16    tcnt;
} *P_XTMR;

typedef struct OS_TMR {
  struct OS_TMR  *next;            
  U16    tcnt;                     
  U16    info;                     
} *P_TMR;

typedef struct OS_BM {
  void *free;                      
  void *end;                       
  U32  blk_size;                   
} *P_BM;

 






 

#line 13 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\RTX_Config.h"









 


 




 





 
extern U32 mp_tcb[];
extern U64 mp_stk[];
extern U32 os_fifo[];
extern void *os_active_TCB[];

 
extern U16 const os_maxtaskrun;
extern U32 const os_trv;
extern U8  const os_flags;
extern U32 const os_stackinfo;
extern U32 const os_rrobin;
extern U32 const os_clockrate;
extern U32 const os_timernum;
extern U16 const mp_tcb_size;
extern U32 const mp_stk_size;
extern U32 const *m_tmr;
extern U16 const mp_tmr_size;
extern U8  const os_fifo_size;

 
extern void os_idle_demon   (void);
extern void os_tmr_call     (U16  info);
extern void os_error        (U32 err_code);



 
#line 14 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\rt_Task.h"









 

 

 
#line 25 "rtx_src\\rt_Task.h"

 









 
extern struct OS_TSK os_tsk;
extern struct OS_TCB os_idle_TCB;

 
extern void      rt_switch_req (P_TCB p_new);
extern void      rt_dispatch   (P_TCB next_TCB);
extern void      rt_block      (U16 timeout, U8 block_state);
extern void      rt_tsk_pass   (void);
extern OS_TID    rt_tsk_self   (void);
extern OS_RESULT rt_tsk_prio   (OS_TID task_id, U8 new_prio);
extern OS_TID    rt_tsk_create (FUNCP task, U32 prio_stksz, void *stk, void *argv);
extern OS_RESULT rt_tsk_delete (OS_TID task_id);
extern void      rt_sys_init   (FUNCP first_task, U32 prio_stksz, void *stk);




 






#line 15 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\rt_System.h"









 

 


 
extern void rt_tsk_lock   (void);
extern void rt_tsk_unlock (void);
extern void rt_psh_req    (void);
extern void rt_pop_req    (void);
extern void rt_systick    (void);
extern void rt_stk_check  (void);



 

#line 16 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\rt_Event.h"









 

 
extern OS_RESULT rt_evt_wait (U16 wait_flags,  U16 timeout, BOOL and_wait);
extern void      rt_evt_set  (U16 event_flags, OS_TID task_id);
extern void      rt_evt_clr  (U16 clear_flags, OS_TID task_id);
extern void      isr_evt_set (U16 event_flags, OS_TID task_id);
extern U16       rt_evt_get  (void);
extern void      rt_evt_psh  (P_TCB p_CB, U16 set_flags);



 

#line 17 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\rt_List.h"









 

 

 






 
extern struct OS_XCB os_rdy;
extern struct OS_XCB os_dly;

 
extern void  rt_put_prio      (P_XCB p_CB, P_TCB p_task);
extern P_TCB rt_get_first     (P_XCB p_CB);
extern void  rt_put_rdy_first (P_TCB p_task);
extern P_TCB rt_get_same_rdy_prio (void);
extern void  rt_resort_prio   (P_TCB p_task);
extern void  rt_put_dly       (P_TCB p_task, U16 delay);
extern void  rt_dec_dly       (void);
extern void  rt_rmv_list      (P_TCB p_task);
extern void  rt_rmv_dly       (P_TCB p_task);
extern void  rt_psq_enq       (OS_ID entry, U32 arg);

 





 

#line 18 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\rt_Mailbox.h"









 

 
extern void      rt_mbx_init  (OS_ID mailbox, U16 mbx_size);
extern OS_RESULT rt_mbx_send  (OS_ID mailbox, void *p_msg,    U16 timeout);
extern OS_RESULT rt_mbx_wait  (OS_ID mailbox, void **message, U16 timeout);
extern OS_RESULT rt_mbx_check (OS_ID mailbox);
extern void      isr_mbx_send (OS_ID mailbox, void *p_msg);
extern OS_RESULT isr_mbx_receive (OS_ID mailbox, void **message);
extern void      rt_mbx_psh   (P_MCB p_CB,    void *p_msg);




 

#line 19 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\rt_Semaphore.h"









 

 
extern void      rt_sem_init (OS_ID semaphore, U16 token_count);
extern OS_RESULT rt_sem_send (OS_ID semaphore);
extern OS_RESULT rt_sem_wait (OS_ID semaphore, U16 timeout);
extern void      isr_sem_send (OS_ID semaphore);
extern void      rt_sem_psh (P_SCB p_CB);



 

#line 20 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\rt_Time.h"









 

 
extern U16 os_time;

 
extern void rt_dly_wait (U16 delay_time);
extern void rt_itv_set  (U16 interval_time);
extern void rt_itv_wait (void);



 

#line 21 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\rt_Timer.h"









 

 
extern struct OS_XTMR os_tmr;

 
extern void  rt_tmr_tick   (void);
extern OS_ID rt_tmr_create (U16 tcnt, U16 info);
extern OS_ID rt_tmr_kill   (OS_ID timer);



 

#line 22 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\rt_Robin.h"









 

 
extern struct OS_ROBIN os_robin;

 
extern void rt_init_robin (void);
extern void rt_chk_robin  (void);



 

#line 23 "rtx_src\\rt_System.c"
#line 1 "rtx_src\\rt_HAL_CM.h"









 

 





 
#line 25 "rtx_src\\rt_HAL_CM.h"

#line 34 "rtx_src\\rt_HAL_CM.h"

 


 
#line 45 "rtx_src\\rt_HAL_CM.h"

 
extern BIT dbg_msg;

 
#line 57 "rtx_src\\rt_HAL_CM.h"
__inline U32 rt_inc_qi (U32 size, U8 *count, U8 *first) {
  U32 cnt,c2;

  do {
    if ((cnt = __ldrex(count)) == size) {
      __clrex();
      return (cnt); }
  } while (__strex(cnt+1, count));
  do {
    c2 = (cnt = __ldrex(first)) + 1;
    if (c2 == size) c2 = 0;
  } while (__strex(c2, first));
#line 79 "rtx_src\\rt_HAL_CM.h"
  return (cnt);
}


extern void rt_init_stack (P_TCB p_TCB, FUNCP task_body);
extern void rt_set_PSP (U32 stack);
extern void os_set_env (void);
extern void *_alloc_box (void *box_mem);
extern int  _free_box (void *box_mem, void *box);

extern void dbg_init (void);
extern void dbg_task_notify (P_TCB p_tcb, BOOL create);
extern void dbg_task_switch (U32 task_id);

#line 103 "rtx_src\\rt_HAL_CM.h"



 

#line 24 "rtx_src\\rt_System.c"



 

static BIT os_lock;
static BIT os_psh_flag;



 

__asm void $$RTX$$version (void) {
    

                EXPORT  __RL_RTX_VER

__RL_RTX_VER    EQU     0x420
}


 

void rt_tsk_lock (void) {
   
  (*((volatile U32 *)0xE000E010)) = 0x0005;;
  os_lock = 1;
}


 

void rt_tsk_unlock (void) {
   
  (*((volatile U32 *)0xE000E010)) = 0x0007;;
  os_lock = 0;
  if (os_psh_flag) {
    (*((volatile U32 *)0xE000ED04)) = (1<<28);;
  }
}


 

void rt_psh_req (void) {
   
  if (os_lock == 0) {
    (*((volatile U32 *)0xE000ED04)) = (1<<28);;
  }
  else {
    os_psh_flag = 1;
  }
}


 

void rt_pop_req (void) {
   
  struct OS_XCB *p_CB;
  P_TCB next;
  U32  idx;

  os_tsk.run->state = 1;
  rt_put_rdy_first (os_tsk.run);

  os_psh_flag = 0;
  idx = ((P_PSQ)&os_fifo)->last;
  while (((P_PSQ)&os_fifo)->count) {
    p_CB = ((P_PSQ)&os_fifo)->q[idx].id;
    if (p_CB->cb_type == 0) {
       
      rt_evt_psh ((P_TCB)p_CB, (U16)((P_PSQ)&os_fifo)->q[idx].arg);
    }
    else if (p_CB->cb_type == 1) {
       
      rt_mbx_psh ((P_MCB)p_CB, (void *)((P_PSQ)&os_fifo)->q[idx].arg);
    }
    else {
       
      rt_sem_psh ((P_SCB)p_CB);
    }
    if (++idx == ((P_PSQ)&os_fifo)->size) idx = 0;
    while(__strex((__ldrex(&((P_PSQ)&os_fifo)->count)-1),&((P_PSQ)&os_fifo)->count));
  }
  ((P_PSQ)&os_fifo)->last = idx;

  next = rt_get_first (&os_rdy);
  rt_switch_req (next);
}


 

void rt_systick (void) {
   
  P_TCB next;

  os_tsk.run->state = 1;
  rt_put_rdy_first (os_tsk.run);

   
  rt_chk_robin ();

   
  os_time++;
  rt_dec_dly ();

   
  rt_tmr_tick ();

   
  next = rt_get_first (&os_rdy);
  rt_switch_req (next);
}

 

__weak void rt_stk_check (void) {
   
  if ((os_tsk.run->tsk_stack < (U32)os_tsk.run->stack) || 
      (os_tsk.run->stack[0] != 0xE25A2EA5)) {
    os_error (1);
  }
}



 

