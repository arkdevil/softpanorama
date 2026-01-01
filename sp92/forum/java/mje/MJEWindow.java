//
// Mini Java Editor window
//

import iss.util.*;

import java.io.*;
import java.awt.*;
import java.awt.event.*;

// Text Area

class MJETextArea extends TextArea implements KeyListener {
  MJEWindow window;
  boolean dirty;

  MJETextArea(MJEWindow win, int row, int col) {
    super(row, col);
    window = win; 
    addKeyListener(this);
  }

  boolean isDirty() {
    return dirty;
  }

  void clean() {
    dirty = false;
  }

  void dirty() {
    dirty = true;
  }

  public void keyTyped(KeyEvent evt) {
    dirty = true;
  }

  public void keyPressed(KeyEvent evt) {
  }

  public void keyReleased(KeyEvent evt) {
  }
}

class MJEWindow extends Frame implements ActionListener, WindowListener {
  MJETextArea area;
  MJE editor;
  String savePath = null;
  GotoDialog gotoDialog = null;
  FindDialog findDialog = null;

  MenuItem newItem = new MenuItem("New");
  MenuItem openItem = new MenuItem("Open...");
  MenuItem saveItem = new MenuItem("Save");
  MenuItem saveAsItem = new MenuItem("Save As...");
  MenuItem revertItem = new MenuItem("Revert");
  MenuItem compileItem = new MenuItem("Compile");

  MenuItem cutItem = new MenuItem("Cut");
  MenuItem copyItem = new MenuItem("Copy");
  MenuItem pasteItem = new MenuItem("Paste");
  MenuItem selectAllItem = new MenuItem("Select All");
  MenuItem indentLeftItem = new MenuItem("Indent Left");
  MenuItem indentRightItem = new MenuItem("Indent Right");
  MenuItem gotoLineItem = new MenuItem("Go to Line...");
  MenuItem findItem = new MenuItem("Find...");

  MJEWindow(String title, Font fnt, MJE ed) {

  // Initialize

    editor = ed;
    area = new MJETextArea(this, ed.height, ed.width);
    MenuBar menuBar = new MenuBar();

  // Create file menu

    Menu fileMenu = new Menu("File");
    fileMenu.add(newItem);
    fileMenu.add(openItem);
    fileMenu.add(saveItem);
    fileMenu.add(saveAsItem);
    fileMenu.add("-");
    fileMenu.add(revertItem);
    fileMenu.add("-");
    fileMenu.add(compileItem);
    menuBar.add(fileMenu);

    newItem.addActionListener(this);
    openItem.addActionListener(this);
    saveItem.addActionListener(this);
    saveAsItem.addActionListener(this);
    revertItem.addActionListener(this);
    compileItem.addActionListener(this);

  // Create edit menu

    Menu editMenu = new Menu("Edit");
    editMenu.add(cutItem);
    editMenu.add(copyItem);
    editMenu.add(pasteItem);
    editMenu.add(selectAllItem);
    editMenu.add("-");
    editMenu.add(indentLeftItem);
    editMenu.add(indentRightItem);
    editMenu.add("-");
    editMenu.add(gotoLineItem);
    editMenu.add(findItem);
    menuBar.add(editMenu);
 
    cutItem.addActionListener(this);
    copyItem.addActionListener(this);
    pasteItem.addActionListener(this);
    selectAllItem.addActionListener(this);
    indentLeftItem.addActionListener(this);
    indentRightItem.addActionListener(this);
    gotoLineItem.addActionListener(this);
    findItem.addActionListener(this);

  // Show window

    setMenuBar(menuBar);
    saveItem.disable();
    compileItem.disable();
    addWindowListener(this);

    changeFont(fnt);
    setTitle(title);

    add("Center", area);
    pack();
    show();
  }

// Open file

  public boolean open(String path) {
    if (path != null) {
      setTitle(getFile(path));
      savePath = path;
      area.setText(readFile(path));
      saveItem.enable();

      if (path.endsWith(".java")) 
	compileItem.enable();
      else
	compileItem.disable();

      return true;
    }

    return false;
  }

  public boolean save() {
    if (area.isDirty()) {
      writeFile(savePath, area.getText());
      area.clean();
    }

    return true;
  }

// Read file

  public String readFile(String fl) {
    File file = new File(fl);
    StringBuffer text = new StringBuffer((int) file.length());

    try {
      FileReader fr = new FileReader(fl);
      BufferedReader br = new BufferedReader(fr);
      String str = br.readLine();

      while (str != null) {
  	text.append(str);
	text.append("\n");
	str = br.readLine();
      }

      br.close();
      fr.close();
    } catch (Exception err) {
      editor.console.set("Cannot read file.");
    }

    return text.toString();
  }

// Write file

  public void writeFile(String fl, String txt) {
    try {
      editor.console.set("Saving " + savePath + "...");
      StringReader sr = new StringReader(txt);
      BufferedReader br = new BufferedReader(sr);
      FileWriter fw = new FileWriter(fl);
      BufferedWriter bw = new BufferedWriter(fw);
      String str = br.readLine();
   
      while (str != null) {
	bw.write(str);
	bw.newLine();
  	str = br.readLine();
      }

      bw.close();
      editor.console.append("Done.");
    } catch (Exception err) {
      editor.console.set("Cannot write file.");
    }
  }

// Handle window events

  public void windowActivated(WindowEvent evt) {
  }

  public void windowDeactivated(WindowEvent evt) {
  }

  public void windowOpened(WindowEvent evt) {
  }

  public void windowClosing(WindowEvent evt) {
    hide();
  }

  public void windowClosed(WindowEvent evt) {
  }

  public void windowDeiconified(WindowEvent evt) {
  }

  public void windowIconified(WindowEvent evt) {
  }

// Handle component events

  public void actionPerformed(ActionEvent evt) {
    Object src = evt.getSource();
    String file = null;
  
  // Handle file menu

    if (src == newItem) {
      area.setText("");
      area.clean();
      setTitle("Untitled");
      saveItem.disable();
    }

    if (src == openItem) {
      FileDialog dialog = new FileDialog(this, "Open...", FileDialog.LOAD);

      dialog.show();
      file = dialog.getFile();

      if (file != null)
	open(dialog.getDirectory() + file);

      area.clean();
    }

    if (src == saveItem) {
      writeFile(savePath, area.getText());
      area.clean();
    }

    if (src == saveAsItem) {
      FileDialog dialog = new FileDialog(this, "Save As...", FileDialog.SAVE);
      
      dialog.setFile(savePath);
      dialog.show();
      file = dialog.getFile();

      if (file != null) {
	setTitle(file);
	savePath = dialog.getDirectory() + file;
        saveItem.enable();
	writeFile(file, area.getText());
      }

      area.clean();
    }

    if (src == revertItem) {
      open(savePath);
      area.clean();
    }

    if (src == compileItem) {
      if (area.isDirty()) {
        editor.console.set("Saving " + savePath + "...");
        writeFile(savePath, area.getText());
	area.clean();
      }

      editor.compile(savePath, true);
    }

  // Handle edit menu

    if (src == cutItem) {
      editor.clipboard = area.getSelectedText();
      area.replaceRange("", area.getSelectionStart(), 
      area.getSelectionEnd());
      area.dirty();
    }

    if (src == copyItem) 
      editor.clipboard = area.getSelectedText();

    if (src == pasteItem) {
      int start = area.getSelectionStart();
      int end = area.getSelectionEnd();

      if (start == end) 
        area.insert(editor.clipboard, start);
      else
        area.replaceRange(editor.clipboard, start, end);

      area.dirty();
    }

    if (src == selectAllItem)
      area.selectAll();

    if (src == indentLeftItem) {
      int start = getLine(area.getSelectionStart());
      int end = getLine(area.getSelectionEnd());
      String str = area.getText();
      String rstr = "";

      for (int i = start; i < end + 1; i++) {
	int pos = getPosition(str, i);

        int count = 0; 
        int j = pos;
        char ch = str.charAt(j);

        while (ch == ' ' || ch == '\t') {
	  if (ch == ' ')
	    count++;
  	  else
	    count += ((count + 8) / 8 * 8 - count);

	  j++;
	  ch = str.charAt(j);
        }

        rstr = str.substring(0, pos);

	if (count > 2)
          for (int k = 0; k < count - 2; k++)
	    rstr = rstr + " ";

        str = rstr + str.substring(j);
      }

      area.setText(str);
      area.select(getPosition(start), getPosition(end + 1) - 1);
    }

    if (src == indentRightItem) {
      int start = getLine(area.getSelectionStart());
      int end = getLine(area.getSelectionEnd());
      String str = area.getText();
      String rstr = "";

      for (int i = start; i < end + 1; i++) {
	int pos = getPosition(str, i);

        int count = 0; 
        int j = pos;
        char ch = str.charAt(j);

        while (ch == ' ' || ch == '\t') {
	  if (ch == ' ')
	    count++;
  	  else
	    count += ((count + 8) / 8 * 8 - count);

	  j++;
	  ch = str.charAt(j);
        }

        rstr = str.substring(0, pos);

        for (int k = 0; k < count + 2; k++)
	  rstr = rstr + " ";

        str = rstr + str.substring(j);
      }

      area.setText(str);
      area.select(getPosition(start), getPosition(end + 1) - 1);
    }

    if (src == gotoLineItem) {
      if (gotoDialog == null) {
      	gotoDialog = new GotoDialog(this);
     	gotoDialog.pack();
      }

      gotoDialog.show();	
    }

    if (src == findItem) {
      if (findDialog == null) {
      	findDialog = new FindDialog(this);
      	findDialog.pack();
      }

      area.dirty();
      findDialog.show();	
    }
  }

// Change font

  public void changeFont(Font fnt) {
    if (fnt != null)
      area.setFont(fnt);
  }

// Get text area

  public TextArea getTextArea() {
    return area;
  }

// Get file name from path

  public String getFile(String path) {
    char sp = System.getProperty("file.separator").charAt(0);

    for (int i = path.length() - 1; i > 0; i--)
      if (path.charAt(i) == sp)
	return path.substring(i + 1, path.length());

    return path;  
  }

// Go to line

  public void gotoLine(int line) {
    gotoLine(line, 0);
  }

  public void gotoLine(int line, int col) {
    int pos = getPosition(line);

    area.requestFocus();
    area.select(pos + col, pos + col);
  }

// Get position

  public int getPosition(int line) {
    return getPosition(area.getText(), line);
  }

  public int getPosition(String str, int line) {
    int i = 1, pos = 0;

    while (i < line) {
      if (str.charAt(pos) == '\n')
	i++;

      pos++;
    }

    return pos;
  }

// Get line

  public int getLine(int pos) {
    int i = 0, line = 1;
    String str = area.getText();

    while (i < pos) {
      if (str.charAt(i) == '\n')
	line++;

      i++;
    }

    return line;
  }
}
