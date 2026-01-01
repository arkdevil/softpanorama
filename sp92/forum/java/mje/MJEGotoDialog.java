//
// Go to line dialog
//

import iss.awt.*;
import java.awt.*;
import java.awt.event.*;

class MJEGotoDialog extends VDialog implements ActionListener, WindowListener {
  MJEWindow win;
  HPanel p;
  TextField lineText;
  Button go, close;

  public MJEGotoDialog(Frame parent) {
    super(parent, "Go to Line...", false);
    win = (MJEWindow) parent;
    setBackground(Color.lightGray);

    lineText = new TextField("", 7);
    go = new Button("Go");
    close = new Button("Close");

    p = addPanel();
    p.add(0, new Label("Go to Line:"));
    p.add(0, lineText);

    p = addPanel();
    p.add(0, go);
    p.add(0, close);

    lineText.addActionListener(this);
    go.addActionListener(this);
    close.addActionListener(this);
    addWindowListener(this);
  }

  public void actionPerformed(ActionEvent evt) {
    Object src = evt.getSource();

    if (src == lineText || src == go) {
      try {
      	win.gotoLine(new Integer(lineText.getText()).intValue());
      }
      catch (Exception err) { }
    }
    else if (src == close) {
      dispose();
    }
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
