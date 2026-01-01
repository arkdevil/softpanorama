//
// Project options dialog
//

import iss.awt.*;
import java.awt.*;
import java.awt.event.*;

class MJEOptionsDialog extends VDialog implements ActionListener, 
  ItemListener, WindowListener {
  MJE editor;
  HPanel p;
  TextField mclass, html, cpath, odir;
  Checkbox optimize, debug; 
  Choice fonts, styles, sizes;
  Button close;
  public String result;

  public MJEOptionsDialog(Frame parent) {
    super(parent, "Project Options", false);
    editor = (MJE) parent;
    setBackground(Color.lightGray);

  // Main class

    mclass = new TextField(editor.mclass, 10);
    p = addPanel();
    p.add(50, new Label("Main Class:"));
    p.add(50, mclass);

  // HTML file

    html = new TextField(editor.html, 10);
    p = addPanel();
    p.add(50, new Label("HTML File:"));
    p.add(50, html);

  // Class path

    cpath = new TextField(editor.cpath, 10);
    p = addPanel();
    p.add(50, new Label("Class Path:"));
    p.add(50, cpath);

  // Output directory

    odir = new TextField(editor.odir, 10);
    p = addPanel();
    p.add(50, new Label("Output Directory:"));
    p.add(50, odir);

  // Compiler options

    p = addPanel();
    optimize = new Checkbox("Optimize");
    debug = new Checkbox("Debug Information");
    optimize.setState(editor.optimize);
    debug.setState(editor.debug);
    p.add(0, new Label("Compiler:"));
    p.add(0, optimize);
    p.add(0, debug);

  // Close button

    p = addPanel(5, 0, 80);
    close = new Button("Close");
    p.add(0, close);

    close.addActionListener(this);
    optimize.addItemListener(this);
    debug.addItemListener(this);
    addWindowListener(this);
  }

  public void actionPerformed(ActionEvent evt) {
    editor.mclass = mclass.getText();
    editor.html = html.getText();
    editor.cpath = cpath.getText();
    editor.odir = odir.getText(); 

    dispose();
  }

  public void itemStateChanged(ItemEvent evt) {
    Object src = evt.getSource();
 
    if (src == optimize)
      editor.optimize = optimize.getState();
    else
      editor.debug = debug.getState();
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
