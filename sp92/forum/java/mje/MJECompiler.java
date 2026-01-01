//
// Mini Java Editor Compiler
//

import iss.util.*;
import java.io.*;

class MJECompiler extends Thread {
  MJE editor;
  String file;
  String path;
  String cpath;
  String options;

  public MJECompiler(MJE ed) {
    editor = ed;
    String fs = System.getProperty("file.separator");
    cpath = System.getProperty("java.home") + fs + "bin" + fs + "javac";
  }

  public void set(String fl) {
    file = fl;

    if (new File(file).exists())
      path = file;
    else if (new File(editor.directory + file).exists())
      path = editor.directory + file;
    else {
      editor.console.set("Cannot locate " + file + ".");
      return;
    }

    options = "";

    if (editor != null) {
      if (editor.cpath.trim().length() > 0) 
	options = options + " -classpath " + editor.cpath;

      if (editor.odir.trim().length() > 0)
	options = options + " -d " + editor.odir;

      if (editor.optimize)
	options = options + " -O";

      if (editor.debug)
	options = options + " -g";
    }
  }

  public void run() {
    editor.console.set("Compiling " + file + "...");
    boolean error = false;
    Table msgs = new Table();

    try {
      Process ps = Runtime.getRuntime().exec(cpath + options + " " + path);
      InputStream is = ps.getErrorStream();
      BufferedReader br = new BufferedReader(new InputStreamReader(is));

      String str = br.readLine();

      while (str != null) {
 	if (str.startsWith(path)) {
	  error = true;
	  String msg = str.substring(path.length() + 1);

	  for (int i = 1; i < 5; i++)
       	    if (msg.charAt(i) == ':') {
	      int pos = 0;

 	      String line = msg.substring(0, i);
	      String err = msg.substring(i + 2, msg.length());
	      String code = br.readLine().trim();
	      String tmp = br.readLine();

	      for (int j = 0; j < tmp.length(); j++)
		if (tmp.charAt(j) == '^')
		  pos = j;

	      msgs.add("** " + err);
	      msgs.add("   " + line + " (" + pos + "): " + code);
	    }
	}

  	str = br.readLine();
      }

      is.close();
    }
    catch (Exception err) {
      error = true;
      msgs.add("Error compiling " + file + ".");
    }

    if (!error)
      editor.console.append("Done compiling " + file + ".");
    else {
      editor.compileError = true;
      editor.console.file = file;

      for (int i = 0; i < msgs.size(); i++)
        editor.console.append(msgs.getString(i));
    }
  }
}
