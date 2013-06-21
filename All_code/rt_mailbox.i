#line 1 "rtx_src\\rt_Mailbox.c"









 

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

 






 

#line 13 "rtx_src\\rt_Mailbox.c"
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



 
#line 14 "rtx_src\\rt_Mailbox.c"
#line 1 "rtx_src\\rt_System.h"









 

 


 
extern void rt_tsk_lock   (void);
extern void rt_tsk_unlock (void);
extern void rt_psh_req    (void);
extern void rt_pop_req    (void);
extern void rt_systick    (void);
extern void rt_stk_check  (void);



 

#line 15 "rtx_src\\rt_Mailbox.c"
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

 





 

#line 16 "rtx_src\\rt_Mailbox.c"
#line 1 "rtx_src\\rt_Mailbox.h"









 

 
extern void      rt_mbx_init  (OS_ID mailbox, U16 mbx_size);
extern OS_RESULT rt_mbx_send  (OS_ID mailbox, void *p_msg,    U16 timeout);
extern OS_RESULT rt_mbx_wait  (OS_ID mailbox, void **message, U16 timeout);
extern OS_RESULT rt_mbx_check (OS_ID mailbox);
extern void      isr_mbx_send (OS_ID mailbox, void *p_msg);
extern OS_RESULT isr_mbx_receive (OS_ID mailbox, void **message);
extern void      rt_mbx_psh   (P_MCB p_CB,    void *p_msg);




 

#line 17 "rtx_src\\rt_Mailbox.c"
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




 






#line 18 "rtx_src\\rt_Mailbox.c"
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



 

#line 19 "rtx_src\\rt_Mailbox.c"




 


 

void rt_mbx_init (OS_ID mailbox, U16 mbx_size) {
   
  P_MCB p_MCB = mailbox;

  p_MCB->cb_type = 1;
  p_MCB->isr_st  = 0;
  p_MCB->p_lnk   = ((void *) 0);
  p_MCB->first   = 0;
  p_MCB->last    = 0;
  p_MCB->count   = 0;
  p_MCB->size    = (mbx_size + sizeof(void *) - sizeof(struct OS_MCB)) /
                                                     (U32)sizeof (void *);
}


 

OS_RESULT rt_mbx_send (OS_ID mailbox, void *p_msg, U16 timeout) {
   
  P_MCB p_MCB = mailbox;
  P_TCB p_TCB;

  if (p_MCB->p_lnk != ((void *) 0) && p_MCB->count == 0) {
     
    p_TCB = rt_get_first ((P_XCB)p_MCB);
    *p_TCB->msg    = p_msg;
    p_TCB->ret_val = 0x04;
    rt_rmv_dly (p_TCB);
    rt_dispatch (p_TCB);
    os_tsk.run->ret_val = 0x00;
  }
  else {
     
    if (p_MCB->count == p_MCB->size) {
       
       
       
      if (timeout == 0) {
        return (0x01);
      }
      if (p_MCB->p_lnk != ((void *) 0)) {
        rt_put_prio ((P_XCB)p_MCB, os_tsk.run);
      }
      else {
        p_MCB->p_lnk = os_tsk.run;
        os_tsk.run->p_lnk  = ((void *) 0);
        os_tsk.run->p_rlnk = (P_TCB)p_MCB;
         
         
        p_MCB->isr_st = 1;
      }
      os_tsk.run->msg = p_msg;
      rt_block (timeout, 8);
      return (0x01);
    }
     
    p_MCB->msg[p_MCB->first] = p_msg;
    while(__strex((__ldrex(&p_MCB->count)+1),&p_MCB->count));
    if (++p_MCB->first == p_MCB->size) {
      p_MCB->first = 0;
    }
  }
  return (0x00);
}


 

OS_RESULT rt_mbx_wait (OS_ID mailbox, void **message, U16 timeout) {
   
  P_MCB p_MCB = mailbox;
  P_TCB p_TCB;

   
   
  if (p_MCB->count) {
    *message = p_MCB->msg[p_MCB->last];
    if (++p_MCB->last == p_MCB->size) {
      p_MCB->last = 0;
    }
    if (p_MCB->p_lnk != ((void *) 0)) {
       
      p_TCB = rt_get_first ((P_XCB)p_MCB);
      p_TCB->ret_val = 0x00;
      p_MCB->msg[p_MCB->first] = p_TCB->msg;
      if (++p_MCB->first == p_MCB->size) {
        p_MCB->first = 0;
      }
      rt_rmv_dly (p_TCB);
      rt_dispatch (p_TCB);
      os_tsk.run->ret_val = 0x00;
    }
    else {
      while(__strex((__ldrex(&p_MCB->count)-1),&p_MCB->count));
    }
    return (0x00);
  }
   
  if (timeout == 0) {
    return (0x01);
  }
  if (p_MCB->p_lnk != ((void *) 0)) {
    rt_put_prio ((P_XCB)p_MCB, os_tsk.run);
  }
  else {
    p_MCB->p_lnk = os_tsk.run;
    os_tsk.run->p_lnk = ((void *) 0);
    os_tsk.run->p_rlnk = (P_TCB)p_MCB;
  }
  rt_block(timeout, 8);
  os_tsk.run->msg = message;
  return (0x01);
}


 

OS_RESULT rt_mbx_check (OS_ID mailbox) {
   
   
  P_MCB p_MCB = mailbox;

  return (p_MCB->size - p_MCB->count);
}


 

void isr_mbx_send (OS_ID mailbox, void *p_msg) {
   
  P_MCB p_MCB = mailbox;

  rt_psq_enq (p_MCB, (U32)p_msg);
  rt_psh_req ();
}


 

OS_RESULT isr_mbx_receive (OS_ID mailbox, void **message) {
   
   
  P_MCB p_MCB = mailbox;

  if (p_MCB->count) {
     
    *message = p_MCB->msg[p_MCB->last];
    if (p_MCB->isr_st == 1) {
       
      p_MCB->isr_st = 2;
      rt_psq_enq (p_MCB, 0);
      rt_psh_req ();
    }
    while(__strex((__ldrex(&p_MCB->count)-1),&p_MCB->count));
    if (++p_MCB->last == p_MCB->size) {
      p_MCB->last = 0;
    }
    return (0x04);
  }
  return (0x00);
}


 

void rt_mbx_psh (P_MCB p_CB, void *p_msg) {
   
  P_TCB p_TCB;

   
  if (p_CB->p_lnk != ((void *) 0) && p_CB->isr_st == 2) {
     
    p_CB->isr_st = 0;
    p_TCB = rt_get_first ((P_XCB)p_CB);
    p_TCB->ret_val = 0x00;
     
    p_CB->msg[p_CB->first] = p_TCB->msg;
    while(__strex((__ldrex(&p_CB->count)+1),&p_CB->count));
    if (++p_CB->first == p_CB->size) {
      p_CB->first = 0;
    }
    goto rdy;
  }
   
  if (p_CB->p_lnk != ((void *) 0) && p_CB->count == 0) {
    p_TCB = rt_get_first ((P_XCB)p_CB);
    *p_TCB->msg = p_msg;
    p_TCB->ret_val = 0x04;
rdy:p_TCB->state = 1;
    rt_rmv_dly (p_TCB);
    rt_put_prio (&os_rdy, p_TCB);
  }
  else {
     
    if (p_CB->count < p_CB->size) {
      p_CB->msg[p_CB->first] = p_msg;
      while(__strex((__ldrex(&p_CB->count)+1),&p_CB->count));
      if (++p_CB->first == p_CB->size) {
        p_CB->first = 0;
      }
    }
    else {
      os_error (3);
    }
  }
}



 

