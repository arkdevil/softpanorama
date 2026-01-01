////////////////////////////////////////////////////////////////
// Win32 DDEML Class v 1.2
//
// Copyright (c) 1996 Neva Object Technology, Inc   www.nevaobject.com
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
//
////////////////////////////////////////////////////////////////
import Coroutine;
import ExternalObject;
import Win32PlatformFunction;

public class Jddeml {

	public final static int XTYP_REQUEST=3;
	public final static int XTYP_EXECUTE=2;
	public final static int XTYP_POKE=1;
	public final static int CF_TEXT=1;	
	protected String ServiceName;
	protected String TopicName;

	protected int transactionType;
	protected int uFmt;
	protected String item;
	protected byte[] data;
	protected int dataSize;
	protected int ddeobj;
	
	public Jddeml() { 
		ServiceName=new String("Java");
		TopicName=new String("Coffee");
		ddeobj=0;
	}
	public Jddeml(String serv,String topic) {
		ServiceName=serv;
		TopicName=topic;
		ddeobj=0;

	}
	public void ddeServiceName(String str) {
		ServiceName=str;
	}
	
	public void ddeTopicName(String str) {
		TopicName=str;
	}

	public int TransactionType() { return transactionType; };
	public int DataFormatRequested() { return uFmt; };
	public int DataSize() { return dataSize;};
	public String Item() { return item;};
	public byte[] Data() { return data;};


	public int ddePoke(String server, String topic, String item, byte [] data, int length, int timeout) {
		return ddeTransact(server,topic,item,data,length,XTYP_POKE,timeout );		
	}

	public int ddeExecute(String server, String topic, String command,int timeout) {
		byte [] data;
		int length=command.length();
		data=new byte [length];
		command.getBytes(0,length,data,0);
		return ddeTransact(server,topic,new String(" "),data,length,XTYP_EXECUTE,timeout);		
	}

	public int ddeRequest(String service, String topic, String item, int timeout) {
		Coroutine co=new Coroutine("JDDE","DDEMLTransact");
		co.addArg(service);
		co.addArg(topic);
		co.addArg(item);
		co.addArg(0);
		co.addArg(0);
		co.addArg(XTYP_REQUEST);
		co.addArg(timeout);
		co.addArg(new byte[4],4);
		co.addArg(new byte[4],4);
		int rc=co.invoke();
		if(rc != 0) {
			return -1;
		}
		rc= Coroutine.getDWORDAtOffset(co.parameterAt(7).valueAsByteArray(4),0);
		if(rc != 0)
			return rc;
		int datalen= Coroutine.getDWORDAtOffset(co.parameterAt(8).valueAsByteArray(4),0);
		if(datalen == 0)
			data=null;
		else 
			data=co.answerAsBytes(datalen);
		return 0;
	}

	private int ddeTransact(String service, String topic, String item, byte [] data, int length, int type, int timeout) {
		Coroutine co=new Coroutine("JDDE","DDEMLTransact");
		co.addArg(service);
		co.addArg(topic);
		co.addArg(item);
		co.addArg(data,length);
		co.addArg(length);
		co.addArg(type);
		co.addArg(timeout);
		co.addArg(new byte[4],4);
		co.addArg(new byte[4],4);
		int rc=co.invoke();
		if(rc != 0) {
			return -1;
		}
		return Coroutine.getDWORDAtOffset(co.parameterAt(7).valueAsByteArray(4),0);
	}
	
	public boolean ddeStartService() {
		Coroutine co=new Coroutine("JDDE","DDEMLStartService");
		co.addArg(ServiceName);
		co.addArg(TopicName);
		int rc=co.invoke();
		if(rc != 0) {
			return false;
		}
		ddeobj=co.answerAsInteger();
		if(ddeobj == 0)
			return false;
		return true;
	}

	public int ddeWait() {
		return ddeWait(-1);
	}


	public int ddeWait(int howLong) {
		Coroutine co=new Coroutine("JDDE","DDEMLWait");
		co.addArg(ddeobj);
		co.addArg(howLong);				
		int rc=co.invoke();
		if(rc != 0)
			return -1;
		int val=co.answerAsInteger();
		if(val == 0 )
			return -1;
		ExternalObject eo=new ExternalObject();
		/*typedef struct {
			unsigned long type;
			unsigned long format;
			char *item;
			long itemSize;
			char *data;
			long dataSize;
			void *next;
		} QITEM,*PQITEM;*/
		eo.value=val;
		eo.length=28;
		byte [] dde=eo.valueAsByteArray(28);
		eo.value=0;  
		transactionType=Coroutine.getDWORDAtOffset(dde,0);		
		uFmt=Coroutine.getDWORDAtOffset(dde,4);	
		int aitem=Coroutine.getDWORDAtOffset(dde,8);
		if(aitem > 0) {
			ExternalObject ee=new ExternalObject();
			ee.value=aitem;
			item=ee.valueAsString();
			ee.value=0;
		} else
			item=null;
		int adata=Coroutine.getDWORDAtOffset(dde,16);
		int ldata=Coroutine.getDWORDAtOffset(dde,20);
		if(ldata > 0  && adata > 0) {
			data=new byte[ldata];
			ExternalObject ed=new ExternalObject();
			ed.value=adata;
			data=ed.valueAsByteArray(ldata);
			ed.value=0;
			dataSize=ldata;
		} else {
			data=null;
			dataSize=0;
		}
		int next=Coroutine.getDWORDAtOffset(dde,24);	
		co=new Coroutine("JDDE","DDEMLRelease");
		co.addArg(val);		
		co.invoke();
		return next;
	}

	public void ddeStopService() {
		Coroutine co=new Coroutine("JDDE","DDEMLStopService");
		co.addArg(ddeobj);	
		co.invoke();
		return;

	}

	public int ddeLastError() {
		Coroutine co=new Coroutine("JDDE","DDEMLGetLastError");
		co.addArg(ddeobj);	
		co.invoke();
		return co.answerAsInteger();;

	}

	public int ddeProcessRequest(String respond) {
		Coroutine co=new Coroutine("JDDE","DDEMLProcessRequest");
		co.addArg(ddeobj);	
		if(respond == (String)null)
			co.addArg(0);
		else		
			co.addArg(respond);
		co.addArg(CF_TEXT);	
		co.invoke();
		return co.answerAsInteger();
	}

	public static int ddeRegisterClipboardFormat(String fmt) {
		Coroutine co=new Coroutine("USER32","RegisterClipboardFormatA");
		co.addArg(fmt);	
		co.invoke();
		return co.answerAsInteger();
	}
}
