#line 1 "rtx_src\\rt_List.c"









 

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

 






 

#line 13 "rtx_src\\rt_List.c"
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



 
#line 14 "rtx_src\\rt_List.c"
#line 1 "rtx_src\\rt_System.h"









 

 


 
extern void rt_tsk_lock   (void);
extern void rt_tsk_unlock (void);
extern void rt_psh_req    (void);
extern void rt_pop_req    (void);
extern void rt_systick    (void);
extern void rt_stk_check  (void);



 

#line 15 "rtx_src\\rt_List.c"
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

 





 

#line 16 "rtx_src\\rt_List.c"
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




 






#line 17 "rtx_src\\rt_List.c"
#line 1 "rtx_src\\rt_Time.h"









 

 
extern U16 os_time;

 
extern void rt_dly_wait (U16 delay_time);
extern void rt_itv_set  (U16 interval_time);
extern void rt_itv_wait (void);



 

#line 18 "rtx_src\\rt_List.c"
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



 

#line 19 "rtx_src\\rt_List.c"



 

 
struct OS_XCB  os_rdy;
 
struct OS_XCB  os_dly;




 


 

void rt_put_prio (P_XCB p_CB, P_TCB p_task) {
   
   
   
  P_TCB p_CB2;
  U32 prio;
  BOOL sem_mbx = 0;

  if (p_CB->cb_type == 2 || p_CB->cb_type == 1 || p_CB->cb_type == 3) {
    sem_mbx = 1;
  }
  prio = p_task->prio;
  p_CB2 = p_CB->p_lnk;
   
  while (p_CB2 != ((void *) 0) && prio <= p_CB2->prio) {
    p_CB = (P_XCB)p_CB2;
    p_CB2 = p_CB2->p_lnk;
  }
   
  p_task->p_lnk = p_CB2;
  p_CB->p_lnk = p_task;
  if (sem_mbx) {
    if (p_CB2 != ((void *) 0)) {
      p_CB2->p_rlnk = p_task;
    }
    p_task->p_rlnk = (P_TCB)p_CB;
  }
  else {
    p_task->p_rlnk = ((void *) 0);
  }
}


 

P_TCB rt_get_first (P_XCB p_CB) {
   
   
  P_TCB p_first;

  p_first = p_CB->p_lnk;
  p_CB->p_lnk = p_first->p_lnk;
  if (p_CB->cb_type == 2 || p_CB->cb_type == 1 || p_CB->cb_type == 3) {
    if (p_first->p_lnk != ((void *) 0)) {
      p_first->p_lnk->p_rlnk = (P_TCB)p_CB;
      p_first->p_lnk = ((void *) 0);
    }
    p_first->p_rlnk = ((void *) 0);
  }
  else {
    p_first->p_lnk = ((void *) 0);
  }
  return (p_first);
}


 

void rt_put_rdy_first (P_TCB p_task) {
   
   
  p_task->p_lnk = os_rdy.p_lnk;
  p_task->p_rlnk = ((void *) 0);
  os_rdy.p_lnk = p_task;
}


 

P_TCB rt_get_same_rdy_prio (void) {
   
   
  P_TCB p_first;

  p_first = os_rdy.p_lnk;
  if (p_first->prio == os_tsk.run->prio) {
    os_rdy.p_lnk = os_rdy.p_lnk->p_lnk;
    return (p_first);
  }
  return (((void *) 0));
}


 

void rt_resort_prio (P_TCB p_task) {
   
  P_TCB p_CB;

  if (p_task->p_rlnk == ((void *) 0)) {
    if (p_task->state == 1) {
       
      p_CB = (P_TCB)&os_rdy;
      goto res;
    }
  }
  else {
    p_CB = p_task->p_rlnk;
    while (p_CB->cb_type == 0) {
       
      p_CB = p_CB->p_rlnk;
    }
res:rt_rmv_list (p_task);
    rt_put_prio ((P_XCB)p_CB, p_task);
  }
}


 

void rt_put_dly (P_TCB p_task, U16 delay) {
   
   
  P_TCB p;
  U32 delta,idelay = delay;

  p = (P_TCB)&os_dly;
  if (p->p_dlnk == ((void *) 0)) {
     
    delta = 0;
    goto last;
  }
  delta = os_dly.delta_time;
  while (delta < idelay) {
    if (p->p_dlnk == ((void *) 0)) {
       
last: p_task->p_dlnk = ((void *) 0);
      p->p_dlnk = p_task;
      p_task->p_blnk = p;
      p->delta_time = (U16)(idelay - delta);
      p_task->delta_time = 0;
      return;
    }
    p = p->p_dlnk;
    delta += p->delta_time;
  }
   
  p_task->p_dlnk = p->p_dlnk;
  p->p_dlnk = p_task;
  p_task->p_blnk = p;
  if (p_task->p_dlnk != ((void *) 0)) {
    p_task->p_dlnk->p_blnk = p_task;
  }
  p_task->delta_time = (U16)(delta - idelay);
  p->delta_time -= p_task->delta_time;
}


 

void rt_dec_dly (void) {
   
  P_TCB p_rdy;

  if (os_dly.p_dlnk == ((void *) 0)) {
    return;
  }
  os_dly.delta_time--;
  while ((os_dly.delta_time == 0) && (os_dly.p_dlnk != ((void *) 0))) {
    p_rdy = os_dly.p_dlnk;
    if (p_rdy->p_rlnk != ((void *) 0)) {
       
       
      p_rdy->p_rlnk->p_lnk = p_rdy->p_lnk;
      if (p_rdy->p_lnk != ((void *) 0)) {
        p_rdy->p_lnk->p_rlnk = p_rdy->p_rlnk;
        p_rdy->p_lnk = ((void *) 0);
      }
      p_rdy->p_rlnk = ((void *) 0);
    }
    rt_put_prio (&os_rdy, p_rdy);
    os_dly.delta_time = p_rdy->delta_time;
    if (p_rdy->state == 4) {
       
      p_rdy->delta_time = p_rdy->interval_time + os_time;
    }
    p_rdy->state   = 1;
    p_rdy->ret_val = 0x01;
    os_dly.p_dlnk = p_rdy->p_dlnk;
    if (p_rdy->p_dlnk != ((void *) 0)) {
      p_rdy->p_dlnk->p_blnk =  (P_TCB)&os_dly;
      p_rdy->p_dlnk = ((void *) 0);
    }
    p_rdy->p_blnk = ((void *) 0);
  }
}


 

void rt_rmv_list (P_TCB p_task) {
   
   
  P_TCB p_b;

  if (p_task->p_rlnk != ((void *) 0)) {
     
    p_task->p_rlnk->p_lnk = p_task->p_lnk;
    if (p_task->p_lnk != ((void *) 0)) {
      p_task->p_lnk->p_rlnk = p_task->p_rlnk;
    }
    return;
  }

  p_b = (P_TCB)&os_rdy;
  while (p_b != ((void *) 0)) {
     
    if (p_b->p_lnk == p_task) {
      p_b->p_lnk = p_task->p_lnk;
      return;
    }
    p_b = p_b->p_lnk;
  }
}


 

void rt_rmv_dly (P_TCB p_task) {
   
  P_TCB p_b;

  p_b = p_task->p_blnk;
  if (p_b != ((void *) 0)) {
     
    p_b->p_dlnk = p_task->p_dlnk;
    if (p_task->p_dlnk != ((void *) 0)) {
       
      p_b->delta_time += p_task->delta_time;
      p_task->p_dlnk->p_blnk = p_b;
      p_task->p_dlnk = ((void *) 0);
    }
    else {
       
      p_b->delta_time = 0;
    }
    p_task->p_blnk = ((void *) 0);
  }
}


 

void rt_psq_enq (OS_ID entry, U32 arg) {
   
  U32 idx;

  idx = rt_inc_qi (((P_PSQ)&os_fifo)->size, &((P_PSQ)&os_fifo)->count, &((P_PSQ)&os_fifo)->first);
  if (idx < ((P_PSQ)&os_fifo)->size) {
    ((P_PSQ)&os_fifo)->q[idx].id  = entry;
    ((P_PSQ)&os_fifo)->q[idx].arg = arg;
  }
  else {
    os_error (2);
  }
}




 

