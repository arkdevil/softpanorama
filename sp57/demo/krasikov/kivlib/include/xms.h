/***************************************************************/
/*                                                             */
/*              KIVLIB include file XMS.H                      */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#ifndef ___XMS___
#define ___XMS___


typedef struct ___EMMSTRUCT___ {
		  unsigned long size; //must be even!
		  unsigned int  soh;  //source handle
		  unsigned long soo;  //source offset
		  unsigned int  dsh;  //destination handle
		  unsigned long dso;  //destination offset
		  }  EMMSTRUCT;

#ifdef __cplusplus
extern "C" {
#endif

unsigned char  far cdecl XMSerror(void);

int far  cdecl XMSinstalled(void);

void  cdecl getXMSmem(unsigned int * Total, unsigned int * Block); //in Kb

unsigned int  cdecl allocXMS(unsigned int Mem);                   //in Kb

int  cdecl reallocXMS(unsigned int handle, unsigned int mem);     //in Kb

int  cdecl freeXMS(unsigned int handle);

int  cdecl moveXMS(EMMSTRUCT far * M);

int  cdecl mem2xms(void far * Buf, unsigned int Count, unsigned int handle,
	    unsigned long offset);

int  cdecl xms2mem(unsigned int handle, unsigned long offset,
	    void far * Buf, unsigned int Count);

int  cdecl lockBlock(unsigned int handle, unsigned long * Address);

int  cdecl unlockBlock(unsigned int handle);

int  cdecl getXMShandleInfo(unsigned int handle,
		     unsigned char * LockCount,
		     unsigned char * FreeHandles,
		     unsigned int  * Size);
//Attention - this function return wrong error code!
//Use it if function return zero only!

int  cdecl requestHMA(unsigned int Mem); //in bytes; $FFFF for all

int  cdecl releaseHMA(void);

const char * cdecl XMSerrorMSG(unsigned char Error);


/*************************************************
*    Don't use follow functions directly !!!     *
**************************************************/

void far  cdecl CallXMS(void);
void far  cdecl StartUpXMS(void);

#ifdef __cplusplus
}
#endif


#endif

