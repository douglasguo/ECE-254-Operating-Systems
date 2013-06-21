#line 1 "rtx_src\\rt_Event.c"









 

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

 






 

#line 13 "rtx_src\\rt_Event.c"
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



 
#line 14 "rtx_src\\rt_Event.c"
#line 1 "rtx_src\\rt_System.h"









 

 


 
extern void rt_tsk_lock   (void);
extern void rt_tsk_unlock (void);
extern void rt_psh_req    (void);
extern void rt_pop_req    (void);
extern void rt_systick    (void);
extern void rt_stk_check  (void);



 

#line 15 "rtx_src\\rt_Event.c"
#line 1 "rtx_src\\rt_Event.h"









 

 
extern OS_RESULT rt_evt_wait (U16 wait_flags,  U16 timeout, BOOL and_wait);
extern void      rt_evt_set  (U16 event_flags, OS_TID task_id);
extern void      rt_evt_clr  (U16 clear_flags, OS_TID task_id);
extern void      isr_evt_set (U16 event_flags, OS_TID task_id);
extern U16       rt_evt_get  (void);
extern void      rt_evt_psh  (P_TCB p_CB, U16 set_flags);



 

#line 16 "rtx_src\\rt_Event.c"
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

 





 

#line 17 "rtx_src\\rt_Event.c"
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




 






#line 18 "rtx_src\\rt_Event.c"




 


 

OS_RESULT rt_evt_wait (U16 wait_flags, U16 timeout, BOOL and_wait) {
   
   
   
   
   
  U32 block_state;

  if (and_wait) {
     
    if ((os_tsk.run->events & wait_flags) == wait_flags) {
      os_tsk.run->events &= ~wait_flags;
      return (0x02);
    }
    block_state = 6;
  }
  else {
     
    if (os_tsk.run->events & wait_flags) {
      os_tsk.run->waits = os_tsk.run->events & wait_flags;
      os_tsk.run->events &= ~wait_flags;
      return (0x02);
    }
    block_state = 5;
  }
   
  os_tsk.run->waits = wait_flags;
  rt_block (timeout, (U8)block_state);
  return (0x01);
}


 

void rt_evt_set (U16 event_flags, OS_TID task_id) {
   
  P_TCB p_tcb;

  p_tcb = os_active_TCB[task_id-1];
  if (p_tcb == ((void *) 0)) {
    return;
  }
  p_tcb->events |= event_flags;
  event_flags    = p_tcb->waits;
   
   
  if (p_tcb->state == 6) {
     
    if ((p_tcb->events & event_flags) == event_flags) {
      goto wkup;
    }
  }
  if (p_tcb->state == 5) {
     
    if (p_tcb->events & event_flags) {
      p_tcb->waits  &= p_tcb->events;
wkup: p_tcb->events &= ~event_flags;
      rt_rmv_dly (p_tcb);
      p_tcb->events &= ~event_flags;
      p_tcb->state   = 1;
      p_tcb->ret_val = 0x02;
      rt_dispatch (p_tcb);
    }
  }
}


 

void rt_evt_clr (U16 clear_flags, OS_TID task_id) {
   
   
  P_TCB task = os_active_TCB[task_id-1];

  if (task == ((void *) 0)) {
    return;
  }
  task->events &= ~clear_flags;
}


 

void isr_evt_set (U16 event_flags, OS_TID task_id) {
   
  P_TCB p_tcb = os_active_TCB[task_id-1];

  if (p_tcb == ((void *) 0)) {
    return;
  }
  rt_psq_enq (p_tcb, event_flags);
  rt_psh_req ();
}


 

U16 rt_evt_get (void) {
   
  return (os_tsk.run->waits);
}


 

void rt_evt_psh (P_TCB p_CB, U16 set_flags) {
   
  U16 event_flags;

  p_CB->events |= set_flags;
  event_flags = p_CB->waits;
  if (p_CB->state == 6) {
     
    if ((p_CB->events & event_flags) == event_flags) {
      goto rdy;
    }
  }
  if (p_CB->state == 5) {
     
    if (p_CB->events & event_flags) {
      p_CB->waits  &= p_CB->events;
rdy:  p_CB->events &= ~event_flags;
      rt_rmv_dly (p_CB);
      p_CB->state   = 1;
      p_CB->ret_val = 0x02;
      rt_put_prio (&os_rdy, p_CB);
    }
  }
}



 
