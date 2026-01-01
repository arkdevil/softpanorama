//
// Find dialog
//
  
import iss.awt.*;
import java.awt.*;
import java.awt.event.*;

class MJEFindDialog extends VDialog implements ActionListener, WindowListener {
  MJEWindow win;
  HPanel p;
  TextField findText, replaceText;
  Checkbox match;
  Button find, replace, close;

  public MJEFindDialog(Frame parent) {
    super(parent, "Find...", false);
    win = (MJEWindow) parent;
    setBackground(Color.lightGray);

    findText = new TextField("", 10);
    replaceText = new TextField("", 10);    
    match = new Checkbox("Match Case");
    find = new Button("Find");
    replace = new Button("Replace");
    close = new Button("Close");

    p = addPanel();
    p.add(0, new Label("Find:"));
    p.add(0, findText);
    p.add(0, new Label("Replace:"));
    p.add(0, replaceText);

    p = addPanel();
    p.add(0, match);
    p.add(0, find);
    p.add(0, replace);
    p.add(0, close);

    findText.addActionListener(this);
    find.addActionListener(this);
    replace.addActionListener(this);
    close.addActionListener(this);
    addWindowListener(this);
  }

  public void actionPerformed(ActionEvent evt) {
    Object src = evt.getSource();
    TextArea area = win.getTextArea();

    if (src == close) {
      dispose();
    }
    else if (src == replace) {

    // Replace text

      int start = area.getSelectionStart();
      int end = area.getSelectionEnd();

      if (end > start) 
        area.replaceRange(replaceText.getText(), start, end);
    }

  // Find text

    String txt, str;
	
    if (match.getState()) {
      txt = area.getText();
      str = findText.getText();
    }
    else {
      txt = area.getText().toLowerCase();
      str = findText.getText().toLowerCase();
    }

    area.requestFocus();
    int pos = txt.indexOf(str, area.getSelectionEnd());
	
    if (pos > 0)
    area.select(pos, pos + str.length());
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
