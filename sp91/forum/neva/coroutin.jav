////////////////////////////////////////////////////////////////
// Win32PlatformFunction  Class. 
//
// Copyright (c) 1996 Neva Object Technology, Inc  www.nevaobject.com
//
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
//import ExternalObject;
//import Coroutine;
import java.util.*;
public class Win32PlatformFunction {

	Coroutine coroutine;

	public static final int MB_OK=                       0x00000000;
	public static final int MB_OKCANCEL=                 0x00000001;
	public static final int MB_ABORTRETRYIGNORE=         0x00000002;
	public static final int MB_YESNOCANCEL=              0x00000003;
	public static final int MB_YESNO=                    0x00000004;
	public static final int MB_RETRYCANCEL=              0x00000005;
	public static final int MB_ICONHAND=                 0x00000010;
	public static final int MB_ICONQUESTION=             0x00000020;
	public static final int MB_ICONEXCLAMATION=          0x00000030;
	public static final int MB_ICONASTERISK=             0x00000040;
	public static final int MB_ICONWARNING=              0x00000030;
	public static final int MB_ICONERROR=                0x00000010;
	public static final int MB_ICONINFORMATION=          0x00000040;
	public static final int MB_ICONSTOP=                 0x00000010;
	public static final int MB_DEFBUTTON1=               0x00000000;
	public static final int MB_DEFBUTTON2=               0x00000100;
	public static final int MB_DEFBUTTON3=               0x00000200;
	public static final int MB_DEFBUTTON4=               0x00000300;
	public static final int MB_APPLMODAL=                0x00000000;
	public static final int MB_SYSTEMMODAL=              0x00001000;
	public static final int MB_TASKMODAL=                0x00002000;
	public static final int MB_NOFOCUS=                  0x00008000;
	public static final int IDOK=               1;
	public static final int IDCANCEL=           2;
	public static final int IDABORT=            3;
	public static final int IDRETRY=            4;
	public static final int IDIGNORE=           5;
	public static final int IDYES=              6;
	public static final int IDNO=               7;

////////////////////////////////////////////////////////////////////////////////////////////
	public Win32PlatformFunction() { 
		coroutine=new Coroutine();
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////
	public Win32PlatformFunction(String library,String function) { 
		coroutine=new Coroutine(library,function);
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////
	public static void Beep(int freq, int dura) throws SecurityException {
		Coroutine coro=new Coroutine("KERNEL32","Beep");
		coro.addArg(freq);
		coro.addArg(dura);
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////
	public static String GetEnvironmentVariable(String env) throws SecurityException {
		Coroutine coro=new Coroutine("KERNEL32","GetEnvironmentVariableA");
		String ret;
		coro.addArg(env);
		byte [] buf=new byte[1024];
		coro.addArg(buf,1024);
		coro.addArg(1024);
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		if(coro.answerAsInteger() > 0)
			ret= coro.parameterAt(1).valueAsString();
		else
			ret=(String)null;
		return ret; 							
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////
	public static int MessageBox(String message, String title, int style) throws SecurityException {
		Coroutine coro=new Coroutine("USER32","MessageBoxA");
		coro.addArg(0);
		coro.addArg(message);
		coro.addArg(title);
		coro.addArg(style);
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		int ret=coro.answerAsInteger();
		return ret;
} 
///////////////////////////////////////////////////////////////////////////////////////////////////////
	public static boolean Play(String path, int how) throws SecurityException {
		Coroutine coro=new Coroutine("WINMM","PlaySound");
		coro.addArg(path);
		coro.addArg(0);
		coro.addArg(how);
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		return coro.answerAsBoolean();
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////
	public static boolean Play(String path) throws SecurityException {
		try {
			return Play(path,1);
		} catch(Exception e) {
			throw (SecurityException)e;
		}	
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static boolean OpenClipboard() throws SecurityException {
		Coroutine coro=new Coroutine("USER32","OpenClipboard");
		coro.addArgNull();
		int rc;
		try {
			rc=coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		if(rc != 0)
			return false;
		return coro.answerAsBoolean();
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static boolean CloseClipboard() throws SecurityException {
		Coroutine coro=new Coroutine("USER32","CloseClipboard");
		coro.addArgNull();
		int rc;
		try {
			rc=coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		if(rc != 0)
			return false;
		return coro.answerAsBoolean();
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static boolean EmptyClipboard() throws SecurityException {
		Coroutine coro=new Coroutine("USER32","EmptyClipboard");
		int rc;
		try {
			rc=coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		if(rc != 0)
			return false;
		return coro.answerAsBoolean();
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static int SetClipboardTextData(String data) throws SecurityException {
		try {
			Coroutine coro=new Coroutine("KERNEL32","GlobalAlloc");
			coro.addArg(8194);  // GMEM_DDESHARE|GMEM_MOVEABLE
			coro.addArg(data.length()+1);
			int rc;
			rc=coro.invoke();
			if(rc != 0)
				return rc;
			int handle=coro.answerAsInteger(); 
			if(handle == 0)
				return GetLastOsError();

			coro=new Coroutine("KERNEL32","GlobalLock");
			coro.addArg(handle);		
			rc=coro.invoke();
			if(rc != 0)
				return rc;
			int ptr=coro.answerAsInteger(); 

			if(ptr == 0)
				return GetLastOsError();
			ExternalObject ext=new ExternalObject(data);
			coro.copyMemory(ptr,ext.getValue(),data.length());
			coro.copyByte(ptr+data.length(),(byte)0);
			coro=new Coroutine("USER32","SetClipboardData");
			coro.addArg(1);  //CF_TEXT
			coro.addArg(handle);
			rc=coro.invoke();
			if(rc != 0)
				return rc;
			if(coro.answerAsInteger() == 0) 
				return  GetLastOsError();
			coro=new Coroutine("KERNEL32","GlobalUnlock");
			coro.addArg(handle);		
			rc=coro.invoke();
			if(rc != 0)
				return rc;
			return 0;
		} catch(Exception e) {
			throw (SecurityException)e;		
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static String GetClipboardTextData() throws SecurityException {
		try {
			Coroutine coro=new Coroutine("USER32","GetClipboardData");
			coro.addArg(1);  //CF_TEXT
			int rc;
			rc=coro.invoke();
			if(rc != 0)
				return (String)null;
			int handle=coro.answerAsInteger(); 
			coro=new Coroutine("KERNEL32","GlobalLock");
			coro.addArg(handle);		
			rc=coro.invoke();
			if(rc != 0)
				return (String)null;
			int ptr=coro.answerAsInteger(); 
			ExternalObject ext=new ExternalObject();
			ext.setValue(ptr);
			String str=ext.valueAsString();
			coro=new Coroutine("KERNEL32","GlobalUnlock");
			coro.addArg(handle);		
			rc=coro.invoke();
			if(rc != 0)
				return (String)null;
			return str;
		} catch(Exception e) {
			throw (SecurityException)e;		
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////
	public static boolean SetClipboardText(String data) throws SecurityException {
		try {
			if(OpenClipboard()) {
				EmptyClipboard();
				int rc=SetClipboardTextData(data);
				CloseClipboard();
				return rc == 0;
			} else
				return false;
		} catch(Exception e) {
			throw (SecurityException)e;		
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////
	public static String GetClipboardText() throws SecurityException {
		try {
			if(OpenClipboard()) {
				String str=GetClipboardTextData();
				CloseClipboard();
				return str;
			} else
				return (String)null;
		} catch(Exception e) {
			throw (SecurityException)e;		
		}
	}

///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static String GetSaveFileName (String filter, String title,String init,  String initDir) throws SecurityException {
		return  GetFileName ("GetSaveFileNameA",filter,title,init, initDir, false );
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static String GetOpenFileName (String filter, String title,String init,  String initDir,boolean allowMultiple) throws SecurityException {
		return  GetFileName ("GetOpenFileNameA",filter,title,init, initDir, allowMultiple );
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static String GetFileName (String api, String filter, String title,String init,  String initDir,
			boolean allowMultiple) throws SecurityException {

		Coroutine coro=new Coroutine("COMDLG32",api);
		int MAXSIZE=1024;
		byte [] st=new byte[76];		
		coro.setDWORDAtOffset(st,76,0);
		ExternalObject eo,eo2,eo3,eo4;
		if(filter != null) {
			byte fi []=new byte[filter.length() + 2];
			filter.getBytes(0,filter.length(),fi,0); 
			eo=new ExternalObject(fi,filter.length() + 2);
			coro.setDWORDAtOffset(st,eo.getValue(),12);
		}

		byte [] ft=new byte[MAXSIZE];
		if(init != null && init.length() < MAXSIZE)  {
			init.getBytes(0,init.length(),ft,0);
		}
		eo2=new ExternalObject(ft,MAXSIZE);	
		coro.setDWORDAtOffset(st,eo2.getValue(),28);
		coro.setDWORDAtOffset(st,MAXSIZE,32);
		if(initDir != null) {
			eo4=new ExternalObject(initDir);
			coro.setDWORDAtOffset(st,eo4.getValue(),44);
		}
		if(title != null) {
			eo3=new ExternalObject(title);
			coro.setDWORDAtOffset(st,eo3.getValue(),48);
		}		

		int flag=0x200000  | 0x80000;   //OFN_LONGNAMES | OFN_EXPLORER
		if(allowMultiple)
			flag |= 0x0200;   //OFN_ALLOWMULTIPLE

		coro.setDWORDAtOffset(st,flag,52);	
		
		coro.setDWORDAtOffset(st,0,4);

		coro.addArg(st,76);
		int rc;
		try {
			rc=coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		if(rc != 0) {
			coro.freeArg();
			return null;
		}
		if(!coro.answerAsBoolean())
			return null;
		if(allowMultiple) {
			byte names []=eo2.valueAsByteArray(MAXSIZE+1);		
			int sw=0,k=0;
			for(k=0;k<MAXSIZE;k++)  {
				if(names[k] == (byte)0) {
					names[k]=(byte)'\t';
					if(sw == 0) {
						sw=1;
					} else {
						sw=k;
						break;
					}
				} else 
					sw=0;
			}
			return new String(names,0,0,k);
		} else
			return eo2.valueAsString();
		

	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static int CreateProcess(String commandLine,boolean showWindow, int [] id) throws SecurityException {
		Coroutine coro=new Coroutine("KERNEL32","CreateProcessA");
		coro.addArg(0);
		coro.addArg(commandLine);
		coro.addArg(0);
		coro.addArg(0);
		coro.addArg(true);
		coro.addArg(0);
		coro.addArg(0);  
		coro.addArg(0);  
		byte [] si=new byte[68];
		coro.setDWORDAtOffset(si,68,0);
		if(!showWindow) {
			coro.setWORDAtOffset(si,7,48);
			coro.setWORDAtOffset(si,1,44);
		}
		coro.addArg(si,68);
		byte [] pi=new byte[16];
		coro.addArg(pi,16);
		int rc;
		try {
			rc=coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		if(rc != 0) {
			coro.freeArg();
			return rc;
		}
		ExternalObject ex=coro.parameterAt(9);
		byte [] pix=new byte[16];
		try {
			pix=ex.valueAsByteArray(16);
			id[0]=coro.getDWORDAtOffset(pix,0);
			id[1]=coro.getDWORDAtOffset(pix,8);
		} catch(Exception e) {
			id[0]=-1;
			id[1]=-1;
		}
		coro.freeArg();
		return 0;
	}
///////////////////////////////////////////////////////////////////////////////////////////////////
	public static int CreateProcess(String commandLine, boolean showWindow) throws SecurityException {
		int [] id=new int[2];
		try {
			return CreateProcess(commandLine,showWindow,id);	
		} catch(Exception e) {
			throw (SecurityException)e;
		}
	}

///////////////////////////////////////////////////////////////////////////////////////////////////
	public static int CreateProcess(String commandLine) throws SecurityException {
		try {
			return CreateProcess(commandLine,true);	
		} catch(Exception e) {
			throw (SecurityException)e;
		}
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	public static int Wait(int handle,int howLong) throws SecurityException {
		Coroutine coro=new Coroutine("KERNEL32","WaitForSingleObject");
		coro.addArg(handle);
		coro.addArg(howLong);
		int rc;
		try {
			rc=coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		if(rc!=0)
			return rc;
		return coro.answerAsInteger();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	public static int CreateEvent(String name, boolean state) {
		Coroutine coro=new Coroutine("KERNEL32","CreateEventA");
		coro.addArgNull();
		coro.addArg(false);		
		coro.addArg(state);		
		if(name == null)
			coro.addArgNull();		
		else
			coro.addArg(name);		
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}	
		return coro.answerAsInteger();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	public static boolean SetEvent(int handle) {
		Coroutine coro=new Coroutine("KERNEL32","SetEvent");
		coro.addArg(handle);		
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}	
		return coro.answerAsBoolean();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	public static int OpenEvent(String name) {
		Coroutine coro=new Coroutine("KERNEL32","OpenEventA");
		coro.addArg(0x1F0003);  //EVENT_ALL_ACCESS		 
		coro.addArg(true);		
		if(name == null)
			coro.addArgNull();		
		else
			coro.addArg(name);		
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}	
		return coro.answerAsInteger();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	public static boolean CloseHandle(int handle) {
		Coroutine coro=new Coroutine("KERNEL32","CloseHandle");
		coro.addArg(handle);		
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}	
		return coro.answerAsBoolean();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	public static int GetLastOsError() throws SecurityException {
		Coroutine coro= new Coroutine("KERNEL32","GetLastError");	
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}	
		return coro.answerAsInteger();
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static ExternalObject ReadFile(String path) throws SecurityException {
		try {
			Coroutine coro=new Coroutine("KERNEL32","CreateFileA");
			coro.addArg(path);
			coro.addArg(0x80000000);  //GENERIC_READ
			coro.addArg(1); //FILE_SHARE_READ
			coro.addArgNull(); // security attributes
			coro.addArg(3); //OPEN_EXISTING
			coro.addArg(128); //FILE_ATTRIBUTE_NORMAL
			coro.addArgNull(); //template file

			int rc=coro.invoke();

			if(rc != 0)
				return (ExternalObject)null;
			int handle=coro.answerAsInteger(); 

			if(handle == 0xFFFFFFFF)  //INVALID HANDLE_VALUE
				return (ExternalObject)null;
			coro=new Coroutine("KERNEL32","GetFileSize");
			coro.addArg(handle);		
			coro.addArg(new byte [4],4);	
			rc=coro.invoke();
			if(rc != 0)
				return (ExternalObject)null;
			int size=coro.answerAsInteger(); 
			if(size == 0)
				return (ExternalObject)null;
			ExternalObject ext=new ExternalObject(new byte[size],size);
			coro=new Coroutine("KERNEL32","ReadFile");
			coro.addArg(handle);		
			coro.addArg(ext);	
			coro.addArg(size);			
			coro.addArg(new byte[4],4);	
			coro.addArgNull();			
			rc=coro.invoke();
			if(rc != 0)
				ext=(ExternalObject)null;
			coro=new Coroutine("KERNEL32","CloseHandle");
			coro.addArg(handle);		
			coro.invoke();
			return ext;
		} catch(Exception e) {
			throw (SecurityException)e;		
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static boolean WriteFile(String path,byte [] data,int length) throws SecurityException {
		try {
			boolean res;
			Coroutine coro=new Coroutine("KERNEL32","CreateFileA");
			coro.addArg(path);
			coro.addArg(0x40000000);  //GENERIC_WRITE
			coro.addArg(0); //EXCLUSIVE (non-shared)
			coro.addArgNull(); // security attributes
			coro.addArg(4); //OPEN_ALWAYS
			coro.addArg(128); //FILE_ATTRIBUTE_NORMAL
			coro.addArgNull(); //template file

			int rc=coro.invoke();

			if(rc != 0)
				return false;
			int handle=coro.answerAsInteger(); 

			if(handle == 0xFFFFFFFF)  //INVALID HANDLE_VALUE
				return false;

			coro=new Coroutine("KERNEL32","WriteFile");
			coro.addArg(handle);		
			coro.addArg(data,length);	
			coro.addArg(length);			
			coro.addArg(new byte[4],4);	
			coro.addArgNull();			
			rc=coro.invoke();
			if(rc != 0) 
				res=false;
			else {
				res=true;
				coro=new Coroutine("KERNEL32","SetEndOfFile");
				coro.addArg(handle);		
				coro.invoke();
				res=coro.answerAsBoolean(); 
			}
			coro=new Coroutine("KERNEL32","CloseHandle");
			coro.addArg(handle);		
			coro.invoke();
			return res && coro.answerAsBoolean();
		} catch(Exception e) {
			throw (SecurityException)e;		
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static boolean WriteFile(String path,String data) throws SecurityException {
		char [] cdata=data.toCharArray();
		byte [] bdata=new byte[data.length()+1];
		for(int i=0;i<data.length();i++) bdata[i]=(byte)cdata[i];
		try {
			return WriteFile(path,bdata,data.length());
		} catch(Exception e) {
			throw (SecurityException)e;		
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static boolean WriteFile(String path,char [] data, int length) throws SecurityException {
		byte [] bdata=new byte[length+1];
		for(int i=0;i<length;i++) bdata[i]=(byte)data[i];
		try {
			return WriteFile(path,bdata,length);
		} catch(Exception e) {
			throw (SecurityException)e;		
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static int GetActiveWindow() throws SecurityException {
		Coroutine coro=new Coroutine("USER32","GetActiveWindow");
		int rc;
		try {
			rc=coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		if(rc != 0)
			return 0;
		return coro.answerAsInteger();
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static int GetDesktopWindow() throws SecurityException {
		Coroutine coro=new Coroutine("USER32","GetDesktopWindow");
		int rc;
		try {
			rc=coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		if(rc != 0)
			return 0;
		return coro.answerAsInteger();
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static int GetTopWindow(int handle) throws SecurityException {
		Coroutine coro=new Coroutine("USER32","GetTopWindow");
		coro.addArg(handle);
		int rc;
		try {
			rc=coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}
		if(rc != 0)
			return 0;
		return coro.answerAsInteger();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	public static int GetCurrentThreadId() throws SecurityException {
		Coroutine coro= new Coroutine("KERNEL32","GetCurrentThreadId");	
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}	
		return coro.answerAsInteger();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	public static int GetCurrentProcess() throws SecurityException {
		Coroutine coro= new Coroutine("KERNEL32","GetCurrentProcess");	
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}	
		return coro.answerAsInteger();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	static int [] EnumerateWindows() throws SecurityException {
		int GW_HWNDNEXT=2;
		int hwnd=Win32PlatformFunction.GetTopWindow(0);
		Vector accum=new Vector(12);
		while(hwnd>0) {
			accum.addElement(new Integer(hwnd));
			Coroutine coro = new Coroutine("USER32", "GetWindow");
			coro.addArg(hwnd);
			coro.addArg(GW_HWNDNEXT);
			try {
				coro.invoke();
			} catch(Exception e) {
				throw (SecurityException)e;
			}	
			hwnd=coro.answerAsInteger();
		}		
		if(accum.size() > 0) {
			int total=accum.size();
			int j;
			int [] wnds= new int[total];
			for(j=0;j<total;j++) wnds[j]=((Integer)(accum.elementAt(j))).intValue();
			return wnds;
		} else
			return null;
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	static int GetWindowThreadProcessId(int hwnd) throws SecurityException {
		Coroutine coro = new Coroutine("USER32", "GetWindowThreadProcessId");
		coro.addArg(hwnd);
		coro.addArg(new byte[4],4);
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}	
		ExternalObject ex=coro.parameterAt(1);
		byte [] p=ex.valueAsByteArray(16);
		return coro.getDWORDAtOffset(p,0);
	}
//////////////////////////////////////////////////////////////////////////////////////////////////
	static String GetWindowText(int hwnd) throws SecurityException {
		Coroutine coro = new Coroutine("USER32", "GetWindowTextA");
		coro.addArg(hwnd);
		coro.addArg(new byte[512],512);
		coro.addArg(512);
		try {
			coro.invoke();
		} catch(Exception e) {
			throw (SecurityException)e;
		}	
		ExternalObject ex1=coro.parameterAt(1);
		return ex1.valueAsString();
	}
}