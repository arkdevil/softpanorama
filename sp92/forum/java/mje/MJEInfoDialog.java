//
// Info dialog
//

import iss.awt.*;
import java.awt.*;
import java.awt.event.*;

class MJEInfoDialog extends VDialog implements ActionListener, WindowListener {
  HPanel p;
  Button button = new Button("Close");

  public MJEInfoDialog(Frame parent, String title, String msg) {
    super(parent, title, true);
    setBackground(Color.lightGray);

    add(0, new Label(msg));

    p = addPanel(5, 0, 80);
    p.add(0, button);

    button.addActionListener(this);
    addWindowListener(this);
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
 
  public void actionPerformed(ActionEvent evt) {
    dispose();
  }
}
