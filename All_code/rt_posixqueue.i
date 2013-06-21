#line 1 "rtx_src\\rt_PosixQueue.c"
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

 






 

#line 2 "rtx_src\\rt_PosixQueue.c"
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



 
#line 3 "rtx_src\\rt_PosixQueue.c"
#line 1 "rtx_src\\rt_System.h"









 

 


 
extern void rt_tsk_lock   (void);
extern void rt_tsk_unlock (void);
extern void rt_psh_req    (void);
extern void rt_pop_req    (void);
extern void rt_systick    (void);
extern void rt_stk_check  (void);



 

#line 4 "rtx_src\\rt_PosixQueue.c"
#line 1 "rtx_src\\rt_MemBox.h"









 

 


extern int     _init_box   (void *box_mem, U32 box_size, U32 blk_size);
extern void *rt_alloc_box  (void *box_mem);
extern void *  _calloc_box (void *box_mem);
extern int   rt_free_box   (void *box_mem, void *box);



 

#line 5 "rtx_src\\rt_PosixQueue.c"
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



 

#line 6 "rtx_src\\rt_PosixQueue.c"
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

 





 

#line 7 "rtx_src\\rt_PosixQueue.c"
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




 






#line 8 "rtx_src\\rt_PosixQueue.c"
#line 1 "C:\\Software\\Keil\\ARM\\RV31\\INC\\errno.h"
 
 
 
 





 











#line 29 "C:\\Software\\Keil\\ARM\\RV31\\INC\\errno.h"


extern __declspec(__nothrow) __pure volatile int *__aeabi_errno_addr(void);






















 





 





 
#line 75 "C:\\Software\\Keil\\ARM\\RV31\\INC\\errno.h"










 












 










 








 





 



 
#line 9 "rtx_src\\rt_PosixQueue.c"


#line 1 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdio.h"
 
 
 





 






 









#line 34 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdio.h"


  
  typedef unsigned int size_t;    








 
 

 
  typedef struct __va_list __va_list;





   




 




typedef struct __fpos_t_struct {
    unsigned __int64 __pos;
    



 
    struct {
        unsigned int __state1, __state2;
    } __mbstate;
} fpos_t;
   


 


   

 

typedef struct __FILE FILE;
   






 

extern FILE __stdin, __stdout, __stderr;
extern FILE *__aeabi_stdin, *__aeabi_stdout, *__aeabi_stderr;

#line 125 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdio.h"
    

    

    





     



   


 


   


 

   



 

   


 




   


 





    


 






extern __declspec(__nothrow) int remove(const char *  ) __attribute__((__nonnull__(1)));
   





 
extern __declspec(__nothrow) int rename(const char *  , const char *  ) __attribute__((__nonnull__(1,2)));
   








 
extern __declspec(__nothrow) FILE *tmpfile(void);
   




 
extern __declspec(__nothrow) char *tmpnam(char *  );
   











 

extern __declspec(__nothrow) int fclose(FILE *  ) __attribute__((__nonnull__(1)));
   







 
extern __declspec(__nothrow) int fflush(FILE *  );
   







 
extern __declspec(__nothrow) FILE *fopen(const char * __restrict  ,
                           const char * __restrict  ) __attribute__((__nonnull__(1,2)));
   








































 
extern __declspec(__nothrow) FILE *freopen(const char * __restrict  ,
                    const char * __restrict  ,
                    FILE * __restrict  ) __attribute__((__nonnull__(2,3)));
   








 
extern __declspec(__nothrow) void setbuf(FILE * __restrict  ,
                    char * __restrict  ) __attribute__((__nonnull__(1)));
   




 
extern __declspec(__nothrow) int setvbuf(FILE * __restrict  ,
                   char * __restrict  ,
                   int  , size_t  ) __attribute__((__nonnull__(1)));
   















 
#pragma __printf_args
extern __declspec(__nothrow) int fprintf(FILE * __restrict  ,
                    const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   


















 
#pragma __printf_args
extern __declspec(__nothrow) int _fprintf(FILE * __restrict  ,
                     const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   



 
#pragma __printf_args
extern __declspec(__nothrow) int printf(const char * __restrict  , ...) __attribute__((__nonnull__(1)));
   




 
#pragma __printf_args
extern __declspec(__nothrow) int _printf(const char * __restrict  , ...) __attribute__((__nonnull__(1)));
   



 
#pragma __printf_args
extern __declspec(__nothrow) int sprintf(char * __restrict  , const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   






 
#pragma __printf_args
extern __declspec(__nothrow) int _sprintf(char * __restrict  , const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   



 

#pragma __printf_args
extern __declspec(__nothrow) int snprintf(char * __restrict  , size_t  ,
                     const char * __restrict  , ...) __attribute__((__nonnull__(3)));
   















 

#pragma __printf_args
extern __declspec(__nothrow) int _snprintf(char * __restrict  , size_t  ,
                      const char * __restrict  , ...) __attribute__((__nonnull__(3)));
   



 
#pragma __scanf_args
extern __declspec(__nothrow) int fscanf(FILE * __restrict  ,
                    const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   






























 
#pragma __scanf_args
extern __declspec(__nothrow) int _fscanf(FILE * __restrict  ,
                     const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   



 
#pragma __scanf_args
extern __declspec(__nothrow) int scanf(const char * __restrict  , ...) __attribute__((__nonnull__(1)));
   






 
#pragma __scanf_args
extern __declspec(__nothrow) int _scanf(const char * __restrict  , ...) __attribute__((__nonnull__(1)));
   



 
#pragma __scanf_args
extern __declspec(__nothrow) int sscanf(const char * __restrict  ,
                    const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   








 
#pragma __scanf_args
extern __declspec(__nothrow) int _sscanf(const char * __restrict  ,
                     const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   



 

 
extern __declspec(__nothrow) int vfscanf(FILE * __restrict  , const char * __restrict  , __va_list) __attribute__((__nonnull__(1,2)));
extern __declspec(__nothrow) int vscanf(const char * __restrict  , __va_list) __attribute__((__nonnull__(1)));
extern __declspec(__nothrow) int vsscanf(const char * __restrict  , const char * __restrict  , __va_list) __attribute__((__nonnull__(1,2)));

extern __declspec(__nothrow) int _vfscanf(FILE * __restrict  , const char * __restrict  , __va_list) __attribute__((__nonnull__(1,2)));
extern __declspec(__nothrow) int _vscanf(const char * __restrict  , __va_list) __attribute__((__nonnull__(1)));
extern __declspec(__nothrow) int _vsscanf(const char * __restrict  , const char * __restrict  , __va_list) __attribute__((__nonnull__(1,2)));

extern __declspec(__nothrow) int vprintf(const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1)));
   





 
extern __declspec(__nothrow) int _vprintf(const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1)));
   



 
extern __declspec(__nothrow) int vfprintf(FILE * __restrict  ,
                    const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1,2)));
   






 
extern __declspec(__nothrow) int vsprintf(char * __restrict  ,
                     const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1,2)));
   






 

extern __declspec(__nothrow) int vsnprintf(char * __restrict  , size_t  ,
                     const char * __restrict  , __va_list  ) __attribute__((__nonnull__(3)));
   







 

extern __declspec(__nothrow) int _vsprintf(char * __restrict  ,
                      const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1,2)));
   



 
extern __declspec(__nothrow) int _vfprintf(FILE * __restrict  ,
                     const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1,2)));
   



 
extern __declspec(__nothrow) int _vsnprintf(char * __restrict  , size_t  ,
                      const char * __restrict  , __va_list  ) __attribute__((__nonnull__(3)));
   



 
extern __declspec(__nothrow) int fgetc(FILE *  ) __attribute__((__nonnull__(1)));
   







 
extern __declspec(__nothrow) char *fgets(char * __restrict  , int  ,
                    FILE * __restrict  ) __attribute__((__nonnull__(1,3)));
   










 
extern __declspec(__nothrow) int fputc(int  , FILE *  ) __attribute__((__nonnull__(2)));
   







 
extern __declspec(__nothrow) int fputs(const char * __restrict  , FILE * __restrict  ) __attribute__((__nonnull__(1,2)));
   




 
extern __declspec(__nothrow) int getc(FILE *  ) __attribute__((__nonnull__(1)));
   







 




    extern __declspec(__nothrow) int (getchar)(void);

   





 
extern __declspec(__nothrow) char *gets(char *  ) __attribute__((__nonnull__(1)));
   









 
extern __declspec(__nothrow) int putc(int  , FILE *  ) __attribute__((__nonnull__(2)));
   





 




    extern __declspec(__nothrow) int (putchar)(int  );

   



 
extern __declspec(__nothrow) int puts(const char *  ) __attribute__((__nonnull__(1)));
   





 
extern __declspec(__nothrow) int ungetc(int  , FILE *  ) __attribute__((__nonnull__(2)));
   






















 

extern __declspec(__nothrow) size_t fread(void * __restrict  ,
                    size_t  , size_t  , FILE * __restrict  ) __attribute__((__nonnull__(1,4)));
   











 

extern __declspec(__nothrow) size_t __fread_bytes_avail(void * __restrict  ,
                    size_t  , FILE * __restrict  ) __attribute__((__nonnull__(1,3)));
   











 

extern __declspec(__nothrow) size_t fwrite(const void * __restrict  ,
                    size_t  , size_t  , FILE * __restrict  ) __attribute__((__nonnull__(1,4)));
   







 

extern __declspec(__nothrow) int fgetpos(FILE * __restrict  , fpos_t * __restrict  ) __attribute__((__nonnull__(1,2)));
   








 
extern __declspec(__nothrow) int fseek(FILE *  , long int  , int  ) __attribute__((__nonnull__(1)));
   














 
extern __declspec(__nothrow) int fsetpos(FILE * __restrict  , const fpos_t * __restrict  ) __attribute__((__nonnull__(1,2)));
   










 
extern __declspec(__nothrow) long int ftell(FILE *  ) __attribute__((__nonnull__(1)));
   











 
extern __declspec(__nothrow) void rewind(FILE *  ) __attribute__((__nonnull__(1)));
   





 

extern __declspec(__nothrow) void clearerr(FILE *  ) __attribute__((__nonnull__(1)));
   




 

extern __declspec(__nothrow) int feof(FILE *  ) __attribute__((__nonnull__(1)));
   


 
extern __declspec(__nothrow) int ferror(FILE *  ) __attribute__((__nonnull__(1)));
   


 
extern __declspec(__nothrow) void perror(const char *  );
   









 

extern __declspec(__nothrow) int _fisatty(FILE *   ) __attribute__((__nonnull__(1)));
    
 

extern __declspec(__nothrow) void __use_no_semihosting_swi(void);
extern __declspec(__nothrow) void __use_no_semihosting(void);
    





 











#line 944 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdio.h"



 
#line 12 "rtx_src\\rt_PosixQueue.c"
#line 1 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdlib.h"
 
 
 




 
 



 












  


 








#line 45 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdlib.h"


  
  typedef unsigned int size_t;










    



    typedef unsigned short wchar_t;  
#line 74 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdlib.h"

typedef struct div_t { int quot, rem; } div_t;
    
typedef struct ldiv_t { long int quot, rem; } ldiv_t;
    

typedef struct lldiv_t { __int64 quot, rem; } lldiv_t;
    


#line 95 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdlib.h"
   



 

   




 
#line 114 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdlib.h"
   


 
extern __declspec(__nothrow) int __aeabi_MB_CUR_MAX(void);

   




 

   




 




extern __declspec(__nothrow) double atof(const char *  ) __attribute__((__nonnull__(1)));
   



 
extern __declspec(__nothrow) int atoi(const char *  ) __attribute__((__nonnull__(1)));
   



 
extern __declspec(__nothrow) long int atol(const char *  ) __attribute__((__nonnull__(1)));
   



 

extern __declspec(__nothrow) __int64 atoll(const char *  ) __attribute__((__nonnull__(1)));
   



 


extern __declspec(__nothrow) double strtod(const char * __restrict  , char ** __restrict  ) __attribute__((__nonnull__(1)));
   

















 

extern __declspec(__nothrow) float strtof(const char * __restrict  , char ** __restrict  ) __attribute__((__nonnull__(1)));
extern __declspec(__nothrow) long double strtold(const char * __restrict  , char ** __restrict  ) __attribute__((__nonnull__(1)));
   

 

extern __declspec(__nothrow) long int strtol(const char * __restrict  ,
                        char ** __restrict  , int  ) __attribute__((__nonnull__(1)));
   



























 
extern __declspec(__nothrow) unsigned long int strtoul(const char * __restrict  ,
                                       char ** __restrict  , int  ) __attribute__((__nonnull__(1)));
   


























 

 
extern __declspec(__nothrow) __int64 strtoll(const char * __restrict  ,
                               char ** __restrict  , int  ) __attribute__((__nonnull__(1)));
   




 
extern __declspec(__nothrow) unsigned __int64 strtoull(const char * __restrict  ,
                                         char ** __restrict  , int  ) __attribute__((__nonnull__(1)));
   



 

extern __declspec(__nothrow) int rand(void);
   







 
extern __declspec(__nothrow) void srand(unsigned int  );
   






 

struct _rand_state { int __x[57]; };
extern __declspec(__nothrow) int _rand_r(struct _rand_state *);
extern __declspec(__nothrow) void _srand_r(struct _rand_state *, unsigned int);
struct _ANSI_rand_state { int __x[1]; };
extern __declspec(__nothrow) int _ANSI_rand_r(struct _ANSI_rand_state *);
extern __declspec(__nothrow) void _ANSI_srand_r(struct _ANSI_rand_state *, unsigned int);
   


 

extern __declspec(__nothrow) void *calloc(size_t  , size_t  );
   



 
extern __declspec(__nothrow) void free(void *  );
   





 
extern __declspec(__nothrow) void *malloc(size_t  );
   



 
extern __declspec(__nothrow) void *realloc(void *  , size_t  );
   













 

extern __declspec(__nothrow) int posix_memalign(void **  , size_t  , size_t  );
   









 

typedef int (*__heapprt)(void *, char const *, ...);
extern __declspec(__nothrow) void __heapstats(int (*  )(void *  ,
                                           char const *  , ...),
                        void *  ) __attribute__((__nonnull__(1)));
   










 
extern __declspec(__nothrow) int __heapvalid(int (*  )(void *  ,
                                           char const *  , ...),
                       void *  , int  ) __attribute__((__nonnull__(1)));
   














 
extern __declspec(__nothrow) __declspec(__noreturn) void abort(void);
   







 

extern __declspec(__nothrow) int atexit(void (*  )(void)) __attribute__((__nonnull__(1)));
   




 
#line 414 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdlib.h"


extern __declspec(__nothrow) __declspec(__noreturn) void exit(int  );
   












 

extern __declspec(__nothrow) __declspec(__noreturn) void _Exit(int  );
   







      

extern __declspec(__nothrow) char *getenv(const char *  ) __attribute__((__nonnull__(1)));
   









 

extern __declspec(__nothrow) int  system(const char *  );
   









 

extern  void *bsearch(const void *  , const void *  ,
              size_t  , size_t  ,
              int (*  )(const void *, const void *)) __attribute__((__nonnull__(1,2,5)));
   












 
#line 502 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdlib.h"


extern  void qsort(void *  , size_t  , size_t  ,
           int (*  )(const void *, const void *)) __attribute__((__nonnull__(1,4)));
   









 

#line 531 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdlib.h"

extern __declspec(__nothrow) __pure int abs(int  );
   



 

extern __declspec(__nothrow) __pure div_t div(int  , int  );
   









 
extern __declspec(__nothrow) __pure long int labs(long int  );
   



 




extern __declspec(__nothrow) __pure ldiv_t ldiv(long int  , long int  );
   











 







extern __declspec(__nothrow) __pure __int64 llabs(__int64  );
   



 




extern __declspec(__nothrow) __pure lldiv_t lldiv(__int64  , __int64  );
   











 
#line 612 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdlib.h"



 
typedef struct __sdiv32by16 { int quot, rem; } __sdiv32by16;
typedef struct __udiv32by16 { unsigned int quot, rem; } __udiv32by16;
    
typedef struct __sdiv64by32 { int rem, quot; } __sdiv64by32;

__value_in_regs extern __declspec(__nothrow) __pure __sdiv32by16 __rt_sdiv32by16(
     int  ,
     short int  );
   

 
__value_in_regs extern __declspec(__nothrow) __pure __udiv32by16 __rt_udiv32by16(
     unsigned int  ,
     unsigned short  );
   

 
__value_in_regs extern __declspec(__nothrow) __pure __sdiv64by32 __rt_sdiv64by32(
     int  , unsigned int  ,
     int  );
   

 



 
extern __declspec(__nothrow) unsigned int __fp_status(unsigned int  , unsigned int  );
   







 























 
extern __declspec(__nothrow) int mblen(const char *  , size_t  );
   












 
extern __declspec(__nothrow) int mbtowc(wchar_t * __restrict  ,
                   const char * __restrict  , size_t  );
   















 
extern __declspec(__nothrow) int wctomb(char *  , wchar_t  );
   













 





 
extern __declspec(__nothrow) size_t mbstowcs(wchar_t * __restrict  ,
                      const char * __restrict  , size_t  ) __attribute__((__nonnull__(2)));
   














 
extern __declspec(__nothrow) size_t wcstombs(char * __restrict  ,
                      const wchar_t * __restrict  , size_t  ) __attribute__((__nonnull__(2)));
   














 

extern __declspec(__nothrow) void __use_realtime_heap(void);
extern __declspec(__nothrow) void __use_realtime_division(void);
extern __declspec(__nothrow) void __use_two_region_memory(void);
extern __declspec(__nothrow) void __use_no_heap(void);
extern __declspec(__nothrow) void __use_no_heap_region(void);

extern __declspec(__nothrow) char const *__C_library_version_string(void);
extern __declspec(__nothrow) int __C_library_version_number(void);











#line 866 "C:\\Software\\Keil\\ARM\\RV31\\INC\\stdlib.h"


 
#line 13 "rtx_src\\rt_PosixQueue.c"
#line 1 "rtx_src\\Serial.h"













 




extern void SER_init      (int uart);
extern int  SER_getChar   (int uart);
extern int  SER_getChar_nb(int uart);
extern int  SER_putChar   (int uart, int c);
extern void SER_putString (int uart, unsigned char *s);

#line 14 "rtx_src\\rt_PosixQueue.c"













struct blocked
{
	OS_TID blockedTasks[10];
	int numBlocked;
};

typedef struct blocked blocked;


struct processInfo
{
	OS_TID taskId;
	int oflag;
	U8 inuse;
};

typedef struct processInfo processInfo;


struct message
{
	unsigned int priority;
	char *msg_ptr;
	size_t msg_size;
	
};

typedef struct message message;



struct mqueue
{
	message messages[10];
	processInfo	processInfos[10];
	blocked blockedSenders;
	blocked blockedReceivers;
	int nummessages;
	char *name;
	mqd_t descriptor;
	U8 inuse;
};

typedef struct mqueue mqueue;




mqueue mqueues[10];
int numqueues = 0;






message removemax(mqueue *msgqueue);
void insert(mqueue *msgqueue, message toInsert);
void printheap(mqueue msgqueue, int rootlocation);
void print(mqueue msgqueue);


mqd_t rt_mq_open(const char *name, int oflag);
int rt_mq_close(mqd_t mqdes);
int rt_mq_send(mqd_t mqdes, const char *msg_ptr, size_t msg_len, unsigned msg_prio);
int rt_mq_receive(mqd_t mqdes, char *msg_ptr, size_t msg_len, unsigned *msg_prio);








message removemax(mqueue *msgqueue)
{
	int done = 0;
	int parentlocation;
	int childlocation;
	message swap;
	message highestprio;

		print(*msgqueue);

	

	parentlocation = 1;
	highestprio = msgqueue->messages[parentlocation];	   
	msgqueue->messages[parentlocation] = msgqueue->messages[msgqueue->nummessages];

	while(!done)
	{
		

		
		if (parentlocation * 2 < msgqueue->nummessages )
		{
			
			if(parentlocation * 2 + 1 < msgqueue->nummessages )
			{
				
				if(msgqueue->messages[parentlocation * 2].priority >= msgqueue->messages[parentlocation * 2 + 1].priority)
				{
					childlocation = parentlocation * 2;
				}
				else 
				{
					childlocation = parentlocation * 2 + 1;
				}
			}
			else 
			{
				childlocation = parentlocation * 2 + 1;
			}

			
			if(msgqueue->messages[childlocation].priority > msgqueue->messages[parentlocation].priority)
			{
				swap = msgqueue->messages[parentlocation];
				msgqueue->messages[parentlocation] = msgqueue->messages[childlocation];
				msgqueue->messages[childlocation] = swap;

				parentlocation = childlocation;

			}
			else 
			{
				done = 1;
			}
		}
		else 
		{
			done = 1;
		}
	}
		

	--msgqueue->nummessages;

	print(*msgqueue);
	return highestprio;
	
}





void insert(mqueue *msgqueue,message toInsert)
{
	int parentlocation;
	int childlocation;
	message swap;
	int done = 0;

	
	

	msgqueue->messages[msgqueue->nummessages+1] = toInsert;

	
	

	childlocation = msgqueue->nummessages + 1;
	parentlocation = childlocation / 2 ;

	while(parentlocation > 0 && !done)
	{
		
		if(msgqueue->messages[childlocation].priority >  msgqueue->messages[parentlocation].priority)
		{
			
			swap = msgqueue->messages[parentlocation];
			msgqueue->messages[parentlocation] = msgqueue->messages[childlocation];
			msgqueue->messages[childlocation] = swap;
		}
		else 
		{
			done = 1;
		}

		childlocation = parentlocation;
		parentlocation = childlocation / 2;
	}




}



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




mqd_t rt_mq_open(const char *name, int oflag)
{

	U8 queueon;
	U8 action= 0;
	U8 queuelocation;
	U8 processon;
	U8 found = 0;

	
	if ( ((oflag &  1) == 0) && ((oflag & 2) ==0) && ((oflag & 4) ==0))
	{
		oflag = oflag | 4;
	}


	

	if ( (oflag & 16) != 0  &&  (oflag & 8) != 0 ) 
	{
		
		for (queueon = 0; queueon < 10; queueon ++)
		{
			if(mqueues[queueon].name == name && mqueues[queueon].inuse )
			{
				
				return 249;
			}
		}

		action = 1; 


	}
	if ((oflag & 8 != 0) && (oflag & 16 == 0))
	{
		

		
		for (queueon = 0; queueon < 10; queueon ++)
		{
			if(mqueues[queueon].name == name && mqueues[queueon].inuse)
			{
				
				queuelocation = queueon;
				found = 1;
				break;
			}
		}
		if (!found)
		{
			
			action = 1;
		}
	}


	
	if( (oflag & 8) == 0)
	{
		for (queueon = 0; queueon < 10; queueon ++)
		{
			if(mqueues[queueon].name == name && mqueues[queueon].inuse)
			{
				queuelocation = queueon;
				found = 1;
				break; 
				
			}
		}
		
		if (!found)
		{
			
			return 250;
		}

		
		action = 2;


	}


	
	if(action == 1 && numqueues == 10)
	{
		return 251;
	}
	if (action == 1)
	{
		
		
		for ( queueon =0; queueon < 10; queueon++)
		{
			if (mqueues[queueon].inuse == 0)
			{
				mqueues[queueon].name = (char *)name;
				mqueues[queueon].descriptor = queueon;
				mqueues[queueon].inuse = 1;

				
				mqueues[queueon].processInfos[0].oflag = oflag;
				mqueues[queueon].processInfos[0].taskId = rt_tsk_self();
				mqueues[queueon].processInfos[0].inuse = 1;

				break;
			}
		}

		++numqueues;

		return mqueues[queueon].descriptor;
	}

	
	if(action == 2)
	{

		

		for(processon = 0; processon < 10; processon++)
		{
			if(mqueues[queuelocation].processInfos[processon].inuse == 0)
			{
				mqueues[queuelocation].processInfos[processon].inuse = 1;
				mqueues[queuelocation].processInfos[processon].oflag = oflag;
				mqueues[queuelocation].processInfos[processon].taskId = rt_tsk_self();
				break;
			}
		}
		 
		
		return mqueues[queuelocation].descriptor ;
	}


	return (mqd_t)-1;
}

int rt_mq_close(mqd_t mqdes)
{
	U8 processon;

	for (processon = 0; processon < 10; processon++)
	{
		if ((mqueues[mqdes].processInfos[processon].taskId == rt_tsk_self()) &&  mqueues[mqdes].processInfos[processon].inuse == 1)
		{
			mqueues[mqdes].processInfos[processon].inuse = 0;
			return 0;
		}
	}

	return 252;

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


	

	if(mqdes > 10 - 1)
	{
		return 252;
	}
	
	if (msg_ptr == 0 )
	{
		return 5;
	}

	
	for (processon = 0; processon < 10; processon++)
	{
		if ((mqueues[mqdes].processInfos[processon].taskId == rt_tsk_self()) &&  mqueues[mqdes].processInfos[processon].inuse == 1)
		{
			oflag = mqueues[mqdes].processInfos[processon].oflag; 
		}	
	}

  if (oflag == -1)
  {
    return 252;
  }

	
	if(	(oflag & 1) != 0)
	{
		return 252;
	}

	

	if(mqueues[mqdes].nummessages >= 10)
	{
		if ( (oflag & 32) != 0)	 
		{
			return 254;
		}
		else 
		{
			myContext = os_active_TCB[rt_tsk_self() - 1];
			myContext->ret_val = 255;

			ID = rt_tsk_self();

			
			mqueues[mqdes].blockedSenders.blockedTasks[mqueues[mqdes].blockedSenders.numBlocked] = ID;

			
			++mqueues[mqdes].blockedSenders.numBlocked;

			
	
  			rt_block(0xffff,0);


			return 255; 
		}
		
	}

	

	toInsert.priority = msg_prio;
	toInsert.msg_size = msg_len;
	toInsert.msg_ptr = (char *)rt_mem_alloc(msg_len,(unsigned char) 0);
	memcpy((void *)toInsert.msg_ptr,(void *)msg_ptr,msg_len);
	insert(&mqueues[mqdes], toInsert);
  	++mqueues[mqdes].nummessages;
	print(mqueues[mqdes]);

	

	for (taskOn = 0; taskOn < mqueues[mqdes].blockedReceivers.numBlocked; taskOn++)
	{

		taskContext = os_active_TCB[mqueues[mqdes].blockedReceivers.blockedTasks[taskOn]];
		taskContext->state = 1;
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


	

	

	if(mqdes > 10 - 1)
	{
		return 252;
	}


	
	for (processon = 0; processon < 10; processon++)
	{
		tmp = rt_tsk_self();
		if ((mqueues[mqdes].processInfos[processon].taskId == rt_tsk_self()) &&  mqueues[mqdes].processInfos[processon].inuse == 1)
		{
			oflag = mqueues[mqdes].processInfos[processon].oflag; 
		}	
	}
  
  if (oflag == -1)
  {
    return 252;
  }

	if (oflag & 2 == 1)
	{
		return 252;
	}

	
  
  if(mqueues[mqdes].nummessages <= 0)
  {
   	if ( (oflag & 32) != 0)	 
		{

			return 254;
		}
		else 
		{

			myContext = os_active_TCB[rt_tsk_self() - 1];
			myContext->ret_val = 255;

			ID = rt_tsk_self();

			
			mqueues[mqdes].blockedReceivers.blockedTasks[mqueues[mqdes].blockedReceivers.numBlocked ] = ID;

			
			++mqueues[mqdes].blockedReceivers.numBlocked;
  			rt_block(0xffff,0);

		
			return 255; 
		}

  }
  
	

	readMessage = removemax(&mqueues[mqdes]);

	

	if (readMessage.msg_ptr == 0 || readMessage.msg_size < 0)
	{
		myContext->ret_val = 5;
		return 5;
	}

 
 
  memcpy((void *)msg_ptr,(void *)readMessage.msg_ptr,readMessage.msg_size);
	*msg_prio = readMessage.priority;

  rt_mem_free((void*)readMessage.msg_ptr);

	

	for (taskOn = 0; taskOn < mqueues[mqdes].blockedSenders.numBlocked; taskOn++)
	{
		taskContext = os_active_TCB[mqueues[mqdes].blockedSenders.blockedTasks[taskOn]-1];
		taskContext->state = 1;
	  	rt_put_prio(&os_rdy,taskContext);
	}
	  
	mqueues[mqdes].blockedSenders.numBlocked = 0;

	myContext->ret_val = readMessage.msg_size;
	return readMessage.msg_size;


}

