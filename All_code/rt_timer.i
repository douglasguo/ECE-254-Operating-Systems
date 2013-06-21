#line 1 "rtx_src\\rt_Timer.c"









 

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

 






 

#line 13 "rtx_src\\rt_Timer.c"
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



 
#line 14 "rtx_src\\rt_Timer.c"
#line 1 "rtx_src\\rt_Timer.h"









 

 
extern struct OS_XTMR os_tmr;

 
extern void  rt_tmr_tick   (void);
extern OS_ID rt_tmr_create (U16 tcnt, U16 info);
extern OS_ID rt_tmr_kill   (OS_ID timer);



 

#line 15 "rtx_src\\rt_Timer.c"
#line 1 "rtx_src\\rt_MemBox.h"









 

 


extern int     _init_box   (void *box_mem, U32 box_size, U32 blk_size);
extern void *rt_alloc_box  (void *box_mem);
extern void *  _calloc_box (void *box_mem);
extern int   rt_free_box   (void *box_mem, void *box);



 

#line 16 "rtx_src\\rt_Timer.c"




 

 
struct OS_XTMR os_tmr;



 

 

void rt_tmr_tick (void) {
   
   
  P_TMR p;

  if (os_tmr.next == ((void *) 0)) {
    return;
  }
  os_tmr.tcnt--;
  while (os_tmr.tcnt == 0 && (p = os_tmr.next) != ((void *) 0)) {
     
    os_tmr_call (p->info);
    os_tmr.tcnt = p->tcnt;
    os_tmr.next = p->next;
    rt_free_box ((U32 *)m_tmr, p);
  }
}

 

OS_ID rt_tmr_create (U16 tcnt, U16 info)  {
   
   
   
  P_TMR p_tmr, p;
  U32 delta,itcnt = tcnt;

  if (tcnt == 0 || m_tmr == ((void *) 0))  {
    return (((void *) 0));
  }
  p_tmr = rt_alloc_box ((U32 *)m_tmr);
  if (!p_tmr)  {
    return (((void *) 0));
  }
  p_tmr->info = info;
  p = (P_TMR)&os_tmr;
  delta = p->tcnt;
  while (delta < itcnt && p->next != ((void *) 0)) {
    p = p->next;
    delta += p->tcnt;
  }
   
  p_tmr->next = p->next;
  p_tmr->tcnt = (U16)(delta - itcnt);
  p->next = p_tmr;
  p->tcnt -= p_tmr->tcnt;
  return (p_tmr);
}

 

OS_ID rt_tmr_kill (OS_ID timer)  {
   
  P_TMR p, p_tmr;

  p_tmr = (P_TMR)timer;
  p = (P_TMR)&os_tmr;
   
  while (p->next != p_tmr)  {
    if (p->next == ((void *) 0)) {
       
      return (p_tmr);
    }
    p = p->next;
  }
   
  p->next = p_tmr->next;
  p->tcnt += p_tmr->tcnt;
  rt_free_box ((U32 *)m_tmr, p_tmr);
   
  return (((void *) 0));
}



 
