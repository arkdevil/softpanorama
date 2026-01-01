//
// Preferences dialog
//

import iss.awt.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;

class MJEPrefDialog extends VDialog implements ActionListener, WindowListener {
  MJE editor;
  HPanel p;
  Choice fonts, styles, sizes;
  TextField width, height, browser;
  Button browse, ok, cancel;
  public String result;

  public MJEPrefDialog(Frame parent) {
    super(parent, "Preferences", false);
    editor = (MJE) parent;
    setBackground(Color.lightGray);
    addWindowListener(this);

  // Font selection
   
    fonts = new Choice();
    styles = new Choice();
    sizes = new Choice();

    for (int i = 0; i < editor.fonts.length; i++)
      fonts.addItem(editor.fonts[i]);

    fonts.select(editor.font.getName());

    for (int i = 0; i < editor.styles.length; i++)
      styles.addItem(editor.styles[i]);
   
    styles.select(editor.font.getStyle());

    for (int i = 8; i < 21; i++)
      sizes.addItem(String.valueOf(i));

    sizes.select(String.valueOf(editor.font.getSize()));

    p = addPanel();
    p.add(0, new Label("Font:"));
    p.add(0, fonts);
    p.add(0, styles);
    p.add(0, sizes);

  // Window size

    p = addPanel();
    width = new TextField(String.valueOf(editor.width), 3);
    height = new TextField(String.valueOf(editor.height), 3);
    p.add(0, new Label("Window Size (Chars)   Width:"));
    p.add(0, width);
    p.add(0, new Label("     Height:"));
    p.add(0, height);

  // Web browser

    p = addPanel();
    browser = new TextField(editor.browser, 10);
    browse = new Button("Browse...");
    browse.addActionListener(this);
    p.add(30, new Label("Web Browser:"));
    p.add(50, browser);
    p.add(20, browse);

  //
    p = addPanel(5, 0, 80);
    ok = new Button("OK");
    ok.addActionListener(this);
 
    p.add(0, ok);
  }

  public void actionPerformed(ActionEvent evt) {
    Object src = evt.getSource();

    if (src == browse) {
      FileDialog dialog = new FileDialog(editor, "Locate Web Browser", 
	FileDialog.LOAD);

      dialog.show();
      String file = dialog.getFile();

      if (file != null)
	browser.setText(dialog.getDirectory() + file);
    }
    else if (src == ok) {
      String font = fonts.getSelectedItem();
      int style = 0;

      for (int i = 0; i < editor.styles.length; i++)
	if (editor.styles[i].equals(styles.getSelectedItem()))
	  style = i;

      int size = new Integer(sizes.getSelectedItem()).intValue();
 
      editor.changeFont(new Font(font, style, size));
      editor.width = Integer.parseInt(width.getText());
      editor.height = Integer.parseInt(height.getText());
      editor.browser = browser.getText();

      try {
        String prefPath = System.getProperty("user.home") + 
	  System.getProperty("file.separator") + ".mje";

        FileWriter fw = new FileWriter(prefPath);
        PrintWriter pw = new PrintWriter(fw);

        pw.println(font);
        pw.println(style);
        pw.println(size);
	pw.println(editor.width);
	pw.println(editor.height);
	pw.println(editor.browser);

        fw.close();
        dispose();
      }
      catch(Exception err) {
	editor.console.set("Unable to save preference.");
      }

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
