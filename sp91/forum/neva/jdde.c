

////////////////////////////////////////////////////////////////
//
// Win32 DDEML for Java v.1.2. Tailored for use with Coroutine for Java    Last modified: 02/6/97
//
// Copyright (c) 1996 Neva Object Technology, Inc  software@nevaobject.com
//
// Permission to use, copy, modify and distribute this software and its
// documentation without fee for NON-COMMERCIAL purposes is hereby granted
// provided that this notice with a reference to the original source 
// appears in all copies or derivatives of this software.
//
// NEVA OBJECT TECHNOLOGY,INC. MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE 
// SUITABILITY OF THIS SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE, OR NON-INFRINGEMENT. NEVA OBJECT TECHNOLOGY,INC.
// SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY ANYBODY AS A RESULT OF 
// USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
//
////////////////////////////////////////////////////////////////

#define _MT
#define INCL_WINMESSAGES        
#include <windows.h>
#include <windowsx.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdarg.h>
#include <process.h>
#include <time.h>
#include <dde.h>
#include <ddeml.h>


typedef struct {
	unsigned long type;
	unsigned long format;
	char *item;
	long itemSize;
	char *data;
	long dataSize;
	void *next;
} QITEM,*PQITEM;

typedef struct {
	DWORD id;
	DWORD ddeInstanceId;
	char * service;
	char * topic;
	CRITICAL_SECTION cs;
	PQITEM queue;
	HANDLE hev;
	HANDLE hev2;
	HANDLE hevr;
	long rtimeout;
	void * rdata;
	long   rdatalen;	
	long   rformat;	
} DDEOBJ,*PDDEOBJ;



HINSTANCE hDll=NULL;
DWORD TlsIndex=TLS_OUT_OF_INDEXES;


void AddItem(PDDEOBJ dde,PQITEM obj) 
{
	PQITEM x;
	EnterCriticalSection(&dde->cs);
	if(!dde->queue) {
		dde->queue=obj;
		obj->next=(void*)NULL;
		LeaveCriticalSection(&dde->cs);
		return;
	}
	for(x=dde->queue;;x=(PQITEM)x->next) 
		if(!x->next)
			break;
	x->next=(void*)obj;
	obj->next=(void*)NULL;
	LeaveCriticalSection(&dde->cs);
}


PQITEM RemoveItem(PDDEOBJ dde) 
{
	PQITEM x;
	EnterCriticalSection(&dde->cs);
	x=dde->queue;
	if(!x) {
		LeaveCriticalSection(&dde->cs);
		return (PQITEM)NULL;
	}
	dde->queue=(PQITEM)x->next;
	if(dde->queue) 
		SetEvent(dde->hev);
	LeaveCriticalSection(&dde->cs);
	return x;
}

__declspec(dllexport) HDDEDATA CALLBACK DDEMLCallback(UINT uType, UINT uFmt, HCONV hconv,
									HSZ hsz1, HSZ hsz2, HDDEDATA hdata, DWORD dwData1, DWORD dwData2) 
{
    char *data;
    char *phdata;
    long len;
    char *topic;
    char *item;
	PQITEM pq;
	HDDEDATA hddedata;
	DWORD dw;  //

	PDDEOBJ ddeObj=(PDDEOBJ)TlsGetValue(TlsIndex);


    switch(uType) {
        case XTYP_REGISTER:
            return (HDDEDATA)NULL;

        case XTYP_CONNECT:
            len=DdeQueryString(ddeObj->ddeInstanceId,hsz1,NULL,0,CP_WINANSI);
            topic=malloc(len+1);
            DdeQueryString(ddeObj->ddeInstanceId,hsz1,topic,len+1,CP_WINANSI);
            if(strcmp(topic,ddeObj->topic)) {
                free(topic);
                return (HDDEDATA)FALSE;
            }
            free(topic);
            return (HDDEDATA)TRUE;

        case XTYP_POKE:

	//		if(uFmt != CF_TEXT)
	//			return (HDDEDATA)DDE_FNOTPROCESSED;

            len=DdeQueryString(ddeObj->ddeInstanceId,hsz1,NULL,0,CP_WINANSI);
            topic=malloc(len+1);
            DdeQueryString(ddeObj->ddeInstanceId, hsz1,topic,len+1,CP_WINANSI);
            if(strcmp(topic,ddeObj->topic)) {
                free(topic);
                return (HDDEDATA)DDE_FNOTPROCESSED;
            }
            free(topic);

            len=DdeQueryString(ddeObj->ddeInstanceId,hsz2,NULL,0,CP_WINANSI);
            item=malloc(len+1);
            DdeQueryString(ddeObj->ddeInstanceId, hsz2,item,len+1,CP_WINANSI);

			pq=malloc(sizeof(QITEM));

   			pq->item=item;
            pq->itemSize=len;
            pq->type=1;

            phdata=DdeAccessData(hdata,&len);
            data=strdup(phdata);
			DdeUnaccessData(hdata);
			DdeFreeDataHandle(hdata);

            pq->dataSize=strlen(data)+1;
            pq->data=data;
            pq->format=CF_TEXT;

			AddItem(ddeObj,pq);

			SetEvent(ddeObj->hev);
    	    
            return (HDDEDATA)DDE_FACK;

        case XTYP_EXECUTE:
            len=DdeQueryString(ddeObj->ddeInstanceId,hsz1,NULL,0,CP_WINANSI);
            topic=malloc(len+1);
            DdeQueryString(ddeObj->ddeInstanceId,hsz1,topic,len+1,CP_WINANSI);
            if(strcmp(topic,ddeObj->topic)) {
                free(topic);
                return (HDDEDATA)DDE_FNOTPROCESSED;
            }
            free(topic);


			pq=malloc(sizeof(QITEM));

            pq->itemSize=0;
            pq->type=2;
			pq->item=0;

            phdata=DdeAccessData(hdata,&len);
            data=strdup(phdata);
			DdeUnaccessData(hdata);
            DdeFreeDataHandle(hdata);

            pq->dataSize=strlen(data)+1;
            pq->data=data;
            pq->format=uFmt;


            AddItem(ddeObj,pq);
			
			SetEvent(ddeObj->hev);
     
			return (HDDEDATA)DDE_FACK;


        case XTYP_REQUEST:

            len=DdeQueryString(ddeObj->ddeInstanceId,hsz1,NULL,0,CP_WINANSI);
            topic=malloc(len+1);
            DdeQueryString(ddeObj->ddeInstanceId, hsz1,topic,len+1,CP_WINANSI);
            if(strcmp(topic,ddeObj->topic)) {
                free(topic);
                return (HDDEDATA)DDE_FNOTPROCESSED;
            }
            free(topic);

            len=DdeQueryString(ddeObj->ddeInstanceId,hsz2,NULL,0,CP_WINANSI);
            item=malloc(len+1);
            DdeQueryString(ddeObj->ddeInstanceId, hsz2,item,len+1,CP_WINANSI);
			pq=malloc(sizeof(QITEM));

   			pq->item=item;
            pq->itemSize=len;
            pq->type=3;


            pq->dataSize=1;
            pq->data=strdup(" ");
            pq->format=CF_TEXT;


			ddeObj->rdatalen=0;
			ddeObj->rdata=NULL;
			ddeObj->rformat=CF_TEXT;

			AddItem(ddeObj,pq);

			SetEvent(ddeObj->hev);
		
			if((dw=WaitForSingleObject(ddeObj->hevr,ddeObj->rtimeout)) != WAIT_OBJECT_0) {
				Beep(999,99);
				return (HDDEDATA)DDE_FNOTPROCESSED;
			}
			if(ddeObj->rdata==NULL || ddeObj->rdatalen==0) {
				Beep(999,99);
				return (HDDEDATA)DDE_FNOTPROCESSED;
			}

			hddedata=DdeCreateDataHandle(ddeObj->ddeInstanceId,ddeObj->rdata,ddeObj->rdatalen,0,hsz2,ddeObj->rformat,0);
			free(ddeObj->rdata);
			if( hddedata == 0) {
				Beep(999,99);
				return (HDDEDATA)DDE_FNOTPROCESSED;
			}
			return hddedata;


        default:

            return (HDDEDATA)NULL;
    }
}




DWORD WINAPI ThreadProc(void *param)
{
    MSG msg;

    HSZ hsz;
	int rc;
    char ev[64];
	PDDEOBJ ddeObj=(PDDEOBJ)param;

	TlsSetValue(TlsIndex,(LPVOID)ddeObj);

	ddeObj->ddeInstanceId=0;
    rc=DdeInitialize(&ddeObj->ddeInstanceId,DDEMLCallback,APPCLASS_STANDARD|APPCMD_FILTERINITS|MF_SENDMSGS,0);
    if(DMLERR_NO_ERROR != rc) {
        ddeObj->ddeInstanceId=0;
		SetEvent(ddeObj->hev2);
        return 1;
    }

    ddeObj->id=GetCurrentThreadId();

    hsz=DdeCreateStringHandle(ddeObj->ddeInstanceId,ddeObj->service,CP_WINANSI);    

    if(!DdeNameService(ddeObj->ddeInstanceId,hsz,0,DNS_REGISTER)) {
		DdeUninitialize(ddeObj->ddeInstanceId);
        ddeObj->ddeInstanceId=0;
		SetEvent(ddeObj->hev2);
        return 1;
    }

    sprintf(ev,"DDEVR%x",GetCurrentThreadId());
    ddeObj->hevr=CreateEvent(NULL,FALSE,FALSE,ev);

    sprintf(ev,"DDEV%x",GetCurrentThreadId());
    ddeObj->hev=CreateEvent(NULL,FALSE,FALSE,ev);

	InitializeCriticalSection(&ddeObj->cs);
	ddeObj->queue=NULL;
	SetEvent(ddeObj->hev2);


    while(TRUE == GetMessage(&msg,NULL,0,0)) {
        DispatchMessage(&msg);
    }

	
    DdeNameService(ddeObj->ddeInstanceId,0,0,DNS_UNREGISTER);
    DdeFreeStringHandle(ddeObj->ddeInstanceId,hsz);
    DdeUninitialize(ddeObj->ddeInstanceId);
	free(ddeObj->service);
	free(ddeObj->topic);
	free(ddeObj);
	TlsSetValue(TlsIndex,(LPVOID)NULL);

	EnterCriticalSection(&ddeObj->cs);	
	ddeObj->queue=NULL;	
	LeaveCriticalSection(&ddeObj->cs);

	SetEvent(ddeObj->hev);
	CloseHandle(ddeObj->hev);
	CloseHandle(ddeObj->hevr);
	Beep(99,99);
    return 0;
}



__declspec(dllexport) DWORD DDEMLStartService(char *service, char *topic) 
{
 
	PDDEOBJ obj=malloc(sizeof(DDEOBJ));
	DWORD dwThreadId;
    HANDLE hthread;
	obj->service=strdup(service);
	obj->topic=strdup(topic);
	obj->hev2=CreateEvent(NULL,FALSE,FALSE,NULL);
	
	obj->rtimeout=INFINITE;  //!!!!

    hthread=(HANDLE)_beginthreadex(NULL,0x100000,ThreadProc,(void*)obj,0,&dwThreadId);
	
	WaitForSingleObject(obj->hev2,INFINITE);
	CloseHandle(obj->hev2);
    CloseHandle(hthread);

	if(obj->ddeInstanceId)
	    return (DWORD)obj;
	else {
		free(obj->service);
		free(obj->topic);
		free(obj);
		return 0;
	}
}


__declspec(dllexport) void DDEMLStopService(DWORD param)
{
	PDDEOBJ dde=(PDDEOBJ)param;
    PostThreadMessage(dde->id,WM_QUIT,0,0);

}



__declspec(dllexport) PQITEM DDEMLWait(DWORD param, long howLong) 
{

	PDDEOBJ obj=(PDDEOBJ)param;
	PQITEM pItem;
    WaitForSingleObject(obj->hev,howLong);
	__try {
		pItem=RemoveItem(obj);
	}
	__except (
		pItem=NULL,
		EXCEPTION_EXECUTE_HANDLER) {
	}
	return pItem;
}


__declspec(dllexport) int DDEMLProcessRequest(DWORD param, char *respond, int format) {
	PDDEOBJ obj=(PDDEOBJ)param;
	if(respond != NULL) {
		obj->rdata=strdup(respond);
		obj->rdatalen=strlen(respond)+1;
		obj->rformat=CF_TEXT;
	} else 
		obj->rdata=NULL;
	SetEvent(obj->hevr);
	return 0;
}

__declspec(dllexport) int DDEMLGetLastError(DWORD param) {
	PDDEOBJ obj=(PDDEOBJ)param;
	return DdeGetLastError(obj->ddeInstanceId);
}

__declspec(dllexport) void DDEMLRelease(void *param) 
{
	PQITEM obj=(PQITEM)param;
	if(!obj)
		return;
	if(obj->data)	
		free(obj->data);
	if(obj->item)
		free(obj->item);
	free(obj);

}

__declspec(dllexport) HDDEDATA CALLBACK DDEMLCallbackNull(UINT uType, UINT uFmt, HCONV hconv,
								HSZ hsz1, HSZ hsz2, HDDEDATA hdata, DWORD dwData1, DWORD dwData2) {
            return (HDDEDATA)NULL;
}	

__declspec(dllexport) long DDEMLTransact(char * service ,char *topic,char *item ,char * data,long length,
										   long tType,long timeout, long *rc, long *szz) {
	
	DWORD instanceId=0;
	HSZ sservice,stopic,sitem;
	HCONV hconv;
	BOOL how;
	int xtype;	
	long res;
	UINT fmt=CF_TEXT;
	HDDEDATA reply;

	if(!strlen(service)*strlen(topic)) {
		*rc=-1;
		return 0;
	}


   	if(DMLERR_NO_ERROR != DdeInitialize(&instanceId,DDEMLCallbackNull,
		APPCLASS_STANDARD|APPCMD_FILTERINITS|CBF_FAIL_ALLSVRXACTIONS|CBF_SKIP_ALLNOTIFICATIONS,0)) {
		*rc=DdeGetLastError(instanceId) + 0x70000;
		return 0;
	}

	sservice=DdeCreateStringHandle(instanceId,(const char*)service,CP_WINANSI);
	if((HSZ)0==sservice) {
		DdeUninitialize(instanceId);	
		*rc=DdeGetLastError(instanceId) + 0x10000;
		return 0;
	}
	stopic=DdeCreateStringHandle(instanceId,(const char*)topic,CP_WINANSI);

	if((HSZ)0==stopic) {
		DdeFreeStringHandle(instanceId,sservice);
		DdeUninitialize(instanceId);	
		*rc=DdeGetLastError(instanceId) + 0x20000;
		return 0;
	}

	hconv=DdeConnect(instanceId,sservice,stopic,NULL);

	if((HCONV)0 == hconv) {
		DdeFreeStringHandle(instanceId,service);
		DdeFreeStringHandle(instanceId,topic);
		DdeUninitialize(instanceId);	
		*rc=DdeGetLastError(instanceId) + 0x30000;
		return 0;

	}
	sitem=DdeCreateStringHandle(instanceId,(const char*)item,CP_WINANSI);
	if((HCONV)0 == sitem) {
		DdeFreeStringHandle(instanceId,service);
		DdeFreeStringHandle(instanceId,topic);
		DdeDisconnect(hconv);
		DdeUninitialize(instanceId);	
		*rc=DdeGetLastError(instanceId) + 0x40000;
		return 0;
	}
	
	
	switch(tType) {
		case 1: xtype=XTYP_POKE; break;
		case 2: xtype=XTYP_EXECUTE; fmt=0; break;
		case 3: xtype=XTYP_REQUEST; break;
		default: xtype=0;
	}
	
	
	reply=DdeClientTransaction(data,length,hconv,(tType==2?0:sitem),fmt,xtype,timeout,NULL);

	how=(HDDEDATA)0	== reply;
	
	res=0;
	if(how) {
		*rc=DdeGetLastError(instanceId) + 0x50000;
	} else 
		if(xtype == XTYP_REQUEST) {
			char *phdata;
			DWORD len;
			*rc=0;
			phdata=DdeAccessData(reply,&len);
			if(len > 0) {	
				char *rep;
				long f;
				rep=malloc(len);
				memcpy(rep,phdata,len);
				res=(int)rep;
				*szz=len;
			}
			DdeUnaccessData(reply);
			DdeFreeDataHandle(reply);
		} else 
			*rc=0;
	

	DdeFreeStringHandle(instanceId,sitem);
	DdeFreeStringHandle(instanceId,service);
	DdeFreeStringHandle(instanceId,topic);
	DdeDisconnect(hconv);
	DdeUninitialize(instanceId);	
Beep(99,2000);	
	return res;

}


BOOL WINAPI DllMain(HINSTANCE hinstDll,DWORD fdwReason, LPVOID lpvReserved) {
        switch(fdwReason) {
                case DLL_PROCESS_ATTACH:
					hDll=hinstDll;			
					TlsIndex=TlsAlloc();
					if(TlsIndex == TLS_OUT_OF_INDEXES)
						return FALSE;
					Beep(11000,100);
                    return TRUE;
                case DLL_PROCESS_DETACH:
					TlsFree(TlsIndex);
                    break;
        }
        return TRUE;
}

