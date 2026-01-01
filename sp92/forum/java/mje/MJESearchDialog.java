//
// Global Search dialog
//
  
import iss.awt.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;

class MJESearchDialog extends VDialog implements ActionListener, WindowListener {
  MJE editor;
  HPanel p;
  TextField findText;
  Checkbox match;
  Button ok = new Button("OK");
  Button cancel = new Button("Cancel");
  String result;

  public MJESearchDialog(Frame parent) {
    super(parent, "Global Search", true);
    editor = (MJE) parent;
    setBackground(Color.lightGray);

    findText = new TextField("", 10);
    match = new Checkbox("Match Case");

    p = addPanel();
    p.add(0, new Label("Find:"));
    p.add(0, findText);
    p.add(0, match);

    p = addPanel();
    p.add(0, ok);
    p.add(0, cancel);

    ok.addActionListener(this);
    cancel.addActionListener(this);
    addWindowListener(this);
  }

  public void actionPerformed(ActionEvent evt) {
    Object src = evt.getSource();

    if (src == ok) {
      String str = findText.getText();
      editor.console.set("Searching for " + str + "...");

      for (int i = 0; i < editor.project.size(); i++) {
        String file = ((String[]) editor.project.get(i))[0];

	try {
      	  FileReader fr = new FileReader(file);
          BufferedReader br = new BufferedReader(fr);
	  int count = 0;
	  String txt = br.readLine();

	  if (!match.getState())
	    str = str.toLowerCase();

	  while (txt != null) {
	    if (!match.getState())
	      txt = txt.toLowerCase();

            if (txt.indexOf(str) > 0)
	      count++;

  	    txt = br.readLine();
	  }	    

	  if (count > 0)	  
	    editor.console.append("Found " + count + " in " + file + ".");

  	  fr.close();
        }
	catch (Exception err) {
      	  editor.console.append("Cannot open file " + file + ".");
        }
      }

      editor.console.append("Done.");
    }

    dispose();
  }

  public void windowActivated(WindowEvent evt) {
  }

  public void windowDeactivated(WindowEvent evt) {
  }

  public void windowOpened(WindowEvent evt) {
  }

  public void windowClosing(WindowEvent evt) {
   dispose();
  }

  public void windowClosed(WindowEvent evt) {
  }

  public void windowDeiconified(WindowEvent evt) {
  }

  public void windowIconified(WindowEvent evt) {
  }
}
