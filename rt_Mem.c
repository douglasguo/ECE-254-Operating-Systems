/*----------------------------------------------------------------------------
 *      Name:    RT_MEM.C
 *      Purpose: Interface functions for dynamic memory block management system
 *      NOTES:   Template file for ECE254 Lab3 Assignment
 *----------------------------------------------------------------------------*/

/** 
  * @author: Group 55, Dominic Aquilina (dijaquil) and Jesse Brick (djbrick)
  */

#include "rt_TypeDef.h"
#include "RTX_Config.h"
#include "rt_System.h"
#include "rt_MemBox.h"
#include "rt_HAL_CM.h"
#include "rt_List.h"
#include "rt_Task.h"


//these are included for debugging purposes to be able to call printf when debugging 
#include <stdio.h>
#include <stdlib.h>
#include "Serial.h"


//Start of free memory
extern unsigned int Image$$RW_IRAM1$$ZI$$Limit;

/*----------------------------------------------------------------------------
 *      Binary Tree
 *---------------------------------------------------------------------------*/

#define MAXNUMBLOCKS 128
#define HEIGHT 8

//Size of each block of memory that we are allocating, in bytes
int MINBLOCKSIZE;

//Node for the binary tree
struct tree_node
{
	void *startloc, *endloc;
	struct tree_node *left, *right;
	U8 inuse;
  U16 index;
};



typedef struct tree_node tree_node;


int initmem = 0;
tree_node* root;

OS_TID* blockedTasks;
int numBlocked;

_declare_box (mpool, sizeof (tree_node), 2 * MAXNUMBLOCKS + 1);		    //block to hold tree data structure
_declare_box (blockedArray, sizeof(OS_TID), 10);					        //block to hold ids of all blocked tasks supports up to 250 tasks which is max tasks on board waiting for memory

/*----------------------------------------------------------------------------
 *      Global Functions
 *---------------------------------------------------------------------------*/
extern int rt_init_mem  (unsigned int addr_start, unsigned int addr_end);
extern void* rt_mem_alloc (int size, unsigned char flag);
extern int rt_free (void* ptr);

//Forward Declarations
void* allocate_block (tree_node* tree, int size, int treelevel);
int freeblock (tree_node* tree, void* startofmem);
int cleantree (tree_node* tree);
int cleanleaves (tree_node* tree);
void print_tree (tree_node* tree);

/*--------------------------- _init_box -------------------------------------*/

/** 
 * @brief: initialize the free memory region for dynamic memory allocation
 *         For example buddy system
 * @param addr_start, starting address value of a dynamic memory region
 * @param addr_end, end address value of a dynamic memory region
 * @return: 0 on success and -1 otherwise
 * NOTE: You are allowed to change the signature of this function.
 *       You may also need to extern this function 
 **/
int rt_init_mem  (unsigned int addr_start, unsigned int addr_end)
{
  int memspace;
  int binaryend;
  _init_box (mpool, sizeof (mpool), sizeof (tree_node));
  _init_box (blockedArray, sizeof (blockedArray), sizeof (OS_TID));

  blockedTasks = _calloc_box(blockedArray);
  numBlocked = 0;

  root = _calloc_box (mpool);
  
  root += 1;
  
  root->startloc = (void*) &Image$$RW_IRAM1$$ZI$$Limit;		 //get start of memory
   memspace = (int)0x10008000 - (int)root->startloc;		//get available memory
  binaryend = memspace - memspace % MAXNUMBLOCKS;			//round available memory down to make sure it is  wholely divisible H times where H is height of binary tree
  
  MINBLOCKSIZE = binaryend / MAXNUMBLOCKS;				   //calculate smallest possible block size 
  

  root->endloc = (void*)(binaryend + (int)root->startloc); //calculate our new end of memory based on above
  root->left = 0;
  root->right = 0;
  root->inuse = 0;
  root->index = 1;
  
  initmem = 1;
  return 0;
}

/*--------------------------- rt_alloc_box ----------------------------------*/

/**
 * @brief: allocate a block of memory to a task which requests it
 * @param size: the size of the memory block
 * @param flag: MEM_NOWAIT (0) or MEM_WAIT (1). Blocks on MEM_WAIT
 **/
void* rt_mem_alloc (int size, unsigned char flag)
{
  void* startAddress = NULL;
  OS_TID ID;
  
  if (!initmem ) //if memory has not been initialized we'd better do that
  {
    rt_init_mem(0,0);
  }
  
  startAddress = allocate_block (root, size,1); //try and allocate requested memory
  
  if (startAddress == 0 && flag) //unable to allocate memory and process wants to wait for memory
  {
  	//store task id in blocked task array
    ID = rt_tsk_self();
	  blockedTasks[numBlocked]= ID;
	  numBlocked++;
  	rt_block(0xffff,INACTIVE);
  }
  else if(startAddress ==0 && !flag) //no memory but not supposed to wait
  {
  	return (void*)0;
  }
  
	return startAddress;
}

void* allocate_block (tree_node *tree, int size, int treelevel)
{
	int currsize;

	void* returnvalue;
  tree_node *toaddleft;
  tree_node *toaddright;
  
	currsize = MINBLOCKSIZE << (HEIGHT - treelevel);
  
  if (size < MINBLOCKSIZE)
  {
    size = MINBLOCKSIZE;
  }
  
	//first check if any children as can only allocate in leaves
	if (tree->left != 0)
	{
		returnvalue = allocate_block (tree->left, size, treelevel+1);
		
    if (returnvalue == 0)
		{
			returnvalue = allocate_block (tree->right, size,treelevel+1);
		}
		
    return returnvalue;
	}
	else
	{
		//no children we are in a leaf node check if it is of appropriate size
		if (size <= currsize)
		{
      if (size <= (currsize / 2))
      {
        //this block is too big compared to requested memory check
  			//check if it is in use and return 0 if it is if not
  			//create children to split block
  			
  			if (tree->inuse != 0)
  			{
  				return 0;
  			}
  			
  			//allocate memory for children
  			toaddleft = root + (tree->index << 1);
  			toaddright = root + (tree->index << 1) + 1;
  			
  			//create left child
  			toaddleft->left = 0;
  			toaddleft->right = 0;
  			toaddleft->inuse = 0;
  			toaddleft->startloc = tree->startloc;
  			toaddleft->endloc = (void*) ((((unsigned int) tree->endloc - (unsigned int) tree->startloc + 1) / 2) - 1 + (unsigned int) tree->startloc);
        toaddleft->index = (tree->index << 1);
  			
  			tree->left = toaddleft;
  			
  			//create right child
  			toaddright->left = 0;
  			toaddright->right = 0;
  			toaddright->inuse = 0;
  			toaddright->startloc = (void*) ((((unsigned int) tree->endloc - (unsigned int) tree->startloc + 1) / 2) + (unsigned int) tree->startloc);
  			toaddright->endloc = tree->endloc;
  			toaddright->index = (tree->index << 1) + 1;
        
  			tree->right = toaddright;
  			
  			//created children now attempt to allocate in one
  			return allocate_block (tree->left, size,treelevel + 1);
      }
      else
      {
        //right block size
  			//check if this memory is in use
  			if (tree->inuse)
  			{
  				return 0; //in use can't use this
  			}
  			else
  			{
  				//allocate memory
  				tree->inuse = 1;
          
  				return tree->startloc;
  			}
      }
    }
		else
		{
			return 0; //no space in memory
		}
	}
}

/*--------------------------- rt_free_box -----------------------------------*/

/**
 * @brief: free memory pointed by ptr
 * @return: 0 on success and -1 otherwise.
 **/
int rt_mem_free (void* ptr)
{
  int result;
  int taskOn;
  P_TCB taskContext;
  
  if (!initmem ) //if silly programmer tries to free mem before allocating it 
  {
    return -1;
  }
  
  result = freeblock(root,ptr);
  
  cleantree(root);
  
  if(result) //if some memory has been freed try to allocate this memory to any tasks waiting for memory
  {
    for (taskOn = 0; taskOn < numBlocked; taskOn++)
	  {
		  //some memory has been freed dispatch all tasks to try and allocate memory	
			//set task into ready state and change its return value

			taskContext = os_active_TCB[blockedTasks[taskOn] - 1];
			taskContext->state = READY;
      rt_put_prio(&os_rdy,taskContext);
	  }
      
	  numBlocked = 0;
  }  
  
  //Note: To handle recursion the actual free algorithm returns 0 and 1 respectively.
  return (--result);
}

/**
 *@brief: Release the hounds! (err... memory)
 *@return: 1 if the memory was found and removed, 0 otherwise
 **/
int freeblock (tree_node *tree, void* startofmem)
{
  if (tree->left != 0)
	{
		return (freeblock (tree->left, startofmem) || freeblock (tree->right, startofmem));
	}
	else //no children must be in leaf node
	{
		if (tree->startloc == startofmem)
		{
			tree->inuse = 0;
			return 1;
		}
		else
		{
			return 0;
		}
	}
}

/**
 * @brief: Remove all dead branches from the tree
 * @return: The number of times the cleanleaves removed dead leaves.
 **/
int cleantree(tree_node *tree)
{
	int cleancounter = 0;
	
	while(cleanleaves(tree))
	{
		++cleancounter;
	}
	
	return cleancounter;
}

/**
 * @brief: Called multiple times to recursively scan the tree for dead leaves and eliminate them
 * @return: 1 if any nodes were removed, 0 otherwise.
 **/
int cleanleaves(tree_node *tree)
{
	int flagLeft, flagRight;
	int result = 0;
	
	//if parent has both children with taskid of 0 delete them
	
	//first check if children exist
	if (tree->left != 0)
	{
    //is left tree in use
    flagLeft = tree->left->inuse;
    
    //left tree is not in use, does it have children
    if (flagLeft == 0)
    {
      flagLeft = (tree->left->left != 0);
    }
    
    //is right tree in use
    flagRight = tree->right->inuse;
    
    //right tree is not in use, does it have children
    if (flagRight == 0)
    {
      flagRight = (tree->right->left != 0);
    }
    
    //Dead tree, delete it
    if (flagLeft == 0 && flagRight == 0)
    {
      tree->left = 0;
      tree->right = 0;
      
      return 1;
    }
    else
    {
    	//Clean the trees that have children
			if (tree->left->left != 0)
	    {
    		result = cleanleaves (tree->left);
    	}
    	
    	if (tree->right->left != 0)
    	{
    		result = result | cleanleaves (tree->right);
			}
		  
		  return result;
    }
	}
	else
	{
		return 0; 
  }
}

/*--------------------------- print_tree -----------------------------------*/

/**
 * @brief: Output the contents of the tree to the "console".
 **/
void print_tree (tree_node* tree)
{
 	if(tree->left)
  {
    print_tree (tree->left);
  }
  
  printf ("StartLocation: %d | EndLocation: %d | In Use: %d | Array Position: %d \n", ((unsigned int) tree->startloc - (unsigned int)root->startloc) , ((unsigned int) tree->endloc - (unsigned int)root->startloc), tree->inuse, tree->index);
  
  if(tree->right)
  {
    print_tree (tree->right);
  }
}

/*----------------------------------------------------------------------------
 * end of file
 *---------------------------------------------------------------------------*/

