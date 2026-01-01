//
// Mini Java Editor
//
// By Lim Thye Chean
//

import iss.awt.*;
import iss.util.*;

import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

class MJE extends Frame implements ActionListener, WindowListener {
  String path = null;
  String prefPath = "";
  String clipboard = "";
  String directory = null;
  boolean compileError = false;
  Table project = new Table();
  Hash windows = new Hash();

  MJEFiles list = new MJEFiles(this);
  MJEConsole console = new MJEConsole(this);

// Project options

  String mclass = "";
  String html = "";
  String cpath = "";
  String odir = "";
  boolean optimize = false;
  boolean debug = false;

// Preferences

  Font font;
  int width, height;
  String browser = "";
  String fonts[];
  String styles[] = {"Plain", "Bold", "Italic", "Bold-Italic"};

// File menu

  MenuItem newFileItem = new MenuItem("New File");
  MenuItem openFileItem = new MenuItem("Open File...");
  MenuItem newProjectItem = new MenuItem("New Project...");
  MenuItem openProjectItem = new MenuItem("Open Project...");
  MenuItem saveProjectItem = new MenuItem("Save Project");
  MenuItem saveProjectAsItem = new MenuItem("Save Project As...");
  MenuItem closeProjectItem = new MenuItem("Close Project");
  MenuItem preferencesItem = new MenuItem("Preferences");
  MenuItem exitItem = new MenuItem("Exit");

// Edit menu

  Menu editMenu = new Menu("Edit");
  MenuItem addFileItem = new MenuItem("Add File...");
  MenuItem addNewFileItem = new MenuItem("Add New File...");
  MenuItem addAllFilesItem = new MenuItem("Add All Files...");
  MenuItem addAllJavaFilesItem = new MenuItem("Add All Java Files...");
  MenuItem removeFileItem = new MenuItem("Remove File");
  MenuItem removeAllFilesItem = new MenuItem("Remove All Files");
  MenuItem moveFileUpItem = new MenuItem("Move File Up");
  MenuItem moveFileDownItem = new MenuItem("Move File Down");
  MenuItem sortFilesItem = new MenuItem("Sort Files");

// Project menu 

  Menu projectMenu = new Menu("Project");
  MenuItem compileItem = new MenuItem("Compile");
  MenuItem buildItem = new MenuItem("Build");
  MenuItem buildAllItem = new MenuItem("Build All");
  MenuItem runItem = new MenuItem("Run");
  MenuItem runAppletViewerItem = new MenuItem("Run AppletViewer");
  MenuItem runWebBrowserItem = new MenuItem("Run Web Browser");
  MenuItem globalSearchItem = new MenuItem("Global Search...");
  MenuItem optionsItem = new MenuItem("Options...");

// Help menu

  Menu helpMenu = new Menu("Help");
  MenuItem aboutItem = new MenuItem("About Mini Java Editor...");

// Dialogs

  MJEPrefDialog prefDialog = null;
  MJESearchDialog searchDialog = null;
  MJEOptionsDialog optionsDialog = null;
  MJEInfoDialog aboutDialog = null;

// Main

  public static void main(String args[]) {;
    MJE ed = new MJE("Mini Java Editor");

    if (args.length > 0) {
      ed.setTitle(new File(args[0]).getName());

      ed.path = args[0];
      ed.open(ed.path);
      ed.saveProjectItem.setEnabled(true);
    }
  }

  MJE(String title) {

  // Initialize

    fonts = getToolkit().getFontList();
    MenuBar menuBar = new MenuBar();

  // Create file menu

    Menu fileMenu = new Menu("File");
    fileMenu.add(newFileItem);
    fileMenu.add(openFileItem);
    fileMenu.add("-");
    fileMenu.add(newProjectItem);
    fileMenu.add(openProjectItem);
    fileMenu.add(saveProjectItem);
    fileMenu.add(saveProjectAsItem);
    fileMenu.add(closeProjectItem);
    fileMenu.add("-");
    fileMenu.add(preferencesItem);
    fileMenu.add("-");
    fileMenu.add(exitItem);

    newFileItem.addActionListener(this);
    openFileItem.addActionListener(this);
    newProjectItem.addActionListener(this);
    openProjectItem.addActionListener(this);
    saveProjectItem.addActionListener(this);
    saveProjectAsItem.addActionListener(this);
    closeProjectItem.addActionListener(this);
    preferencesItem.addActionListener(this);
    exitItem.addActionListener(this);

    menuBar.add(fileMenu);

  // Create edit menu

    editMenu.add(addFileItem);
    editMenu.add(addNewFileItem);
    editMenu.add(addAllFilesItem);
    editMenu.add(addAllJavaFilesItem);
    editMenu.add("-");
    editMenu.add(removeFileItem);
    editMenu.add(removeAllFilesItem);
    editMenu.add("-");
    editMenu.add(moveFileUpItem);
    editMenu.add(moveFileDownItem);
    editMenu.add(sortFilesItem);

    addFileItem.addActionListener(this);
    addNewFileItem.addActionListener(this);
    addAllFilesItem.addActionListener(this);
    addAllJavaFilesItem.addActionListener(this);
    removeFileItem.addActionListener(this);
    removeAllFilesItem.addActionListener(this);
    moveFileUpItem.addActionListener(this);
    moveFileDownItem.addActionListener(this);
    sortFilesItem.addActionListener(this);

    menuBar.add(editMenu);

  // Add project menu
 
    projectMenu.add(compileItem);
    projectMenu.add(buildItem);
    projectMenu.add(buildAllItem);
    projectMenu.add("-");
    projectMenu.add(runItem);
    projectMenu.add(runAppletViewerItem);
    projectMenu.add(runWebBrowserItem);
    projectMenu.add("-");
    projectMenu.add(globalSearchItem);
    projectMenu.add(optionsItem);

    compileItem.addActionListener(this);
    buildItem.addActionListener(this);
    buildAllItem.addActionListener(this);
    runItem.addActionListener(this);
    runAppletViewerItem.addActionListener(this);
    runWebBrowserItem.addActionListener(this);
    globalSearchItem.addActionListener(this);
    optionsItem.addActionListener(this);

    menuBar.add(projectMenu);

  // Create help menu

    helpMenu.add(aboutItem);
    aboutItem.addActionListener(this);

    menuBar.add(helpMenu);
    menuBar.setHelpMenu(helpMenu);

  // Get preferences

    String prefPath = System.getProperty("user.home") + 
      System.getProperty("file.separator") + ".mje";

    try {
      FileReader fr = new FileReader(prefPath);
      BufferedReader br = new BufferedReader(fr);

    // Read font

      font = new Font(br.readLine(), Integer.parseInt(br.readLine()),
	Integer.parseInt(br.readLine()));

    // Read window size

      width = Integer.parseInt(br.readLine());
      height = Integer.parseInt(br.readLine());

    // Read web browser path

      browser = br.readLine();
      br.close();
    }
    catch(Exception err) {
      font = new Font("Courier", Font.PLAIN, 12);
      width = 80;
      height = 30;
    }

  // Show editor

    setMenuBar(menuBar);
    editMenu.setEnabled(false);
    projectMenu.setEnabled(false);
    saveProjectItem.setEnabled(false);
    saveProjectAsItem.setEnabled(false);
    setTitle(title);
    setBackground(Color.lightGray);
    addWindowListener(this);

    add("West", list);
    add("Center", console);
    setSize(700, 250);
    setVisible(true);
  }

// Set font

  public void changeFont(Font fnt) {
    font = fnt;
    Table wins = windows.keyNames();

    for (int i = 0; i < wins.size(); i++)
      ((MJEWindow) windows.get(wins.getString(i))).changeFont(fnt);
  }

// Open project

  public boolean open(String path) {
    try {
      project.clear();
      FileReader fr = new FileReader(path);
      BufferedReader br = new BufferedReader(fr);

    // Read project

      mclass = br.readLine();
      html = br.readLine();
      cpath = br.readLine();
      odir = br.readLine();
      optimize = new Boolean(br.readLine()).booleanValue();
      debug = new Boolean(br.readLine()).booleanValue();
      String str = br.readLine();
 
      while (str != null) {
	String[] item = new String[2];
	item[0] = str;
	item[1] = br.readLine();

	project.add(item);
	str = br.readLine();
      }

      fr.close();
    } catch (Exception err) {
      console.set("Cannot open file.");
      return false;
    }

    return true;
  }

// Save project

  public void save(String path) {
    try {
      console.set("Saving project...");

      FileWriter fw = new FileWriter(path);
      BufferedWriter bw = new BufferedWriter(fw);

      bw.write(mclass);
      bw.newLine();
      bw.write(html);
      bw.newLine();
      bw.write(cpath);
      bw.newLine();
      bw.write(odir);
      bw.newLine();
      bw.write(new Boolean(optimize).toString());
      bw.newLine();
      bw.write(new Boolean(debug).toString());
      bw.newLine();

      for (int i = 0; i < project.size(); i++) {
	String[] item = (String[]) project.get(i);
	bw.write(item[0]);
        bw.newLine();
	bw.write(item[1]);
	bw.newLine();
      }

      bw.close();
      console.set("Ready.");
    } catch (Exception err) {
      console.set("Cannot save project.");
    }
  }

// Compile file

  public void compile(String file, boolean thread) {
    try {
      MJECompiler compiler = new MJECompiler(this);
      compiler.set(file);
 
      if (thread)
	compiler.start();
      else
	compiler.run();
    }
    catch (Exception err) {
      console.append("Cannot compiling " + file + ".");
    }
  }

// Get window

  public MJEWindow getWindow(String file) {
    MJEWindow win;
    Hash wins = windows;
    String pth;

    if (new File(file).exists())
      pth = file;
    else if (new File(directory + file).exists())
      pth = directory + file;
    else
      return null;

    if (wins.containsKey(pth))
      win = (MJEWindow) wins.get(pth);
    else {
      win = new MJEWindow(file, font, this);
      win.open(pth);
      wins.put(pth, win);
    }

    return win;
  }

// Exit editor

  public void exit() {
    System.exit(0);
  }

// Event handling

  public void windowActivated(WindowEvent evt) {
  }

  public void windowDeactivated(WindowEvent evt) {
  }

  public void windowOpened(WindowEvent evt) {
  }

  public void windowClosing(WindowEvent evt) {
    exit();
  }

  public void windowClosed(WindowEvent evt) {
  }

  public void windowDeiconified(WindowEvent evt) {
  }

  public void windowIconified(WindowEvent evt) {
  }

  public void actionPerformed(ActionEvent evt) {
    Object source = evt.getSource();

  // File menu

    if (source == newFileItem) {
      MJEWindow win = new MJEWindow("Untitled", font, this);
      win.editor = this;
    }

    if (source == openFileItem) {
      FileDialog dialog = new FileDialog(this, "Open File...", FileDialog.LOAD);

      dialog.setVisible(true);
      String file = dialog.getFile();

      if (file != null) {
	String path = dialog.getDirectory() + file;
	MJEWindow win = new MJEWindow(file, font, this);
        win.editor = this;
        win.open(path);
      }
    }

    if (source == newProjectItem) {
      FileDialog dialog = new FileDialog(this, "New Project...", FileDialog.LOAD);

      dialog.setVisible(true);
      String file = dialog.getFile();

      if (file != null) {
	if (file.endsWith(".*.*"))
	  file = file.substring(0, file.length() - 4);

	if (file.endsWith(".project"))
	  file = file.substring(0, file.length() - 8);

	file = file + ".project";

	if (new File(file).exists()) {
	  console.append("Project already exists.");
 	  return;
	}

	if (file.endsWith(".project")) {
	  directory = dialog.getDirectory();
	  path = directory + file;

	  mclass = "";
	  html = "";
	  cpath = "";
  	  odir = "";
  	  optimize = false;
  	  debug = false;

	  setTitle(file + " - Mini Java Editor");
          saveProjectItem.setEnabled(true);
	  saveProjectAsItem.setEnabled(true);
	  closeProjectItem.setEnabled(true);
 	  editMenu.setEnabled(true);
	  projectMenu.setEnabled(true);
	  list.removeAll();
          project.clear();
	  console.set("Ready.");
	}
      }
    }

    if (source == openProjectItem) {
      FileDialog dialog = new FileDialog(this, "Open Project...", FileDialog.LOAD);

      dialog.setVisible(true);
      String file = dialog.getFile();

      if (file != null) {
	if (file.endsWith(".project")) {
	  directory = dialog.getDirectory();
	  path = directory + file;

	  if (open(path)) {
	    setTitle(file + " - Mini Java Editor");
	    saveProjectItem.setEnabled(true);
	    saveProjectAsItem.setEnabled(true);
	    closeProjectItem.setEnabled(true);
	    editMenu.setEnabled(true);
	    projectMenu.setEnabled(true);
	    list.refresh();
	    console.set("Ready.");
	  }
	}
      }
    }

    if (source == saveProjectItem) {
      if (path != null)
        save(path);
    }

    if (source == saveProjectAsItem) {
      FileDialog dialog = new FileDialog(this, "Save Project As...", 
	FileDialog.SAVE);
      
      dialog.setFile("Untitled.project");
      dialog.setVisible(true);
      String file = dialog.getFile();

      if (file != null) {
	directory = dialog.getDirectory();
	path = directory + file;
	setTitle(file + " - Mini Java Editor");
	save(path);
      }
    }

    if (source == closeProjectItem) {
      directory = null;
      list.removeAll();
      saveProjectItem.setEnabled(false);
      saveProjectAsItem.setEnabled(false);
      editMenu.setEnabled(false);
      projectMenu.setEnabled(false);
      project.clear();
    }

    if (source == preferencesItem) {
      if (prefDialog == null) {
      	prefDialog = new MJEPrefDialog(this);
	prefDialog.pack();
      }

      prefDialog.setVisible(true);
    }

    if (source == exitItem)
      exit();

  // Edit menu

    if (source == addFileItem) {
      FileDialog dialog = new FileDialog(this, "Add File...", FileDialog.LOAD);

      dialog.setVisible(true);
      String file = dialog.getFile();

      if (file != null) {
	String dir = dialog.getDirectory();
	String str;
	String[] item = new String[2];

	if (dir.equals(directory)) 
	  item[0] = file;
	else
	  item[0] = dir + file;

	item[1] = "0";
	project.add(item);
	list.refresh();
      }
    }

    if (source == addNewFileItem) {
      FileDialog dialog = new FileDialog(this, "Add New File..", FileDialog.LOAD);

      dialog.setVisible(true);
      String file = dialog.getFile();

      if (file != null) {
	if (new File(file).exists()) {
	  console.append("File already exists.");
	  return;
	}

	String dir = dialog.getDirectory();
	String str;
	String[] item = new String[2];

	if (dir.equals(directory)) 
	  item[0] = file;
	else
	  item[0] = dir + file;

	item[1] = "0";
	project.add(item);
	list.refresh();

	try {
	  FileWriter fw = new FileWriter(item[0]);
	  fw.close();
	}
	catch (Exception err) {
          console.set("Cannot write file.");
        }
      }
    }

    if (source == addAllFilesItem) {
      String str;
      String[] files = new File(directory).list();

      for (int i = 0; i < files.length; i++) {
	String[] item = new String[2];

	item[0] = files[i];
	item[1] = "0";
	project.add(item);
      }

      list.refresh();
    }

   if (source == addAllJavaFilesItem) {
      String str;
      String[] files = new File(directory).list();

      for (int i = 0; i < files.length; i++) {
	if (files[i].endsWith(".java")) {
	  String[] item = new String[2];

	  item[0] = files[i];
	  item[1] = "0";
	  project.add(item);
	}
      }

      list.refresh();
    }

    if (source == removeFileItem) {
      for (int i = 0; i < project.size(); i++) {
	String str = ((String[]) project.get(i))[0];

	if (str.equals(list.getSelectedItem())) {
	  project.removeAt(i);

	  if (windows.containsKey(str)) {
	    MJEWindow win = (MJEWindow) windows.get(str);
	    win.dispose();
	  }
	}
      }

      list.refresh();
    }

    if (source == removeAllFilesItem) {
      for (int i = 0; i < project.size(); i++) {
        String str = ((String[]) project.get(i))[0];

	if (windows.containsKey(str)) {
	  MJEWindow win = (MJEWindow) windows.get(str);
	  win.dispose();
	}
      }

      project.clear();
      list.removeAll();
    }
     
    if (source == moveFileUpItem) {
      int pos = list.getSelectedIndex();

      if (pos > 0) {
	String str = list.getItem(pos);
	list.remove(pos);
	list.add(str, pos - 1);
	list.select(pos - 1);

	Object item = project.get(pos);
	project.removeAt(pos);
	project.addAt(item, pos - 1);
      }
    }

    if (source == moveFileDownItem) {
      int pos = list.getSelectedIndex();

      if (pos > -1 || pos < (list.countItems() - 1)) {
	String str = list.getItem(pos);
	list.remove(pos);
	list.add(str, pos + 1);
	list.select(pos + 1);

	Object item = project.get(pos);
	project.removeAt(pos);
	project.addAt(item, pos + 1);
      }
    }

    if (source == sortFilesItem) {
      for (int i = project.size() - 1; i > 0; i--) {
	for (int j = 0; j < i; j++) {
	  String[] file1 = (String[]) project.get(j);
	  String[] file2 = (String[]) project.get(j + 1);

	  if (file1[0].compareTo(file2[0]) > 0) {
	    project.removeAt(j);
	    project.addAt(file1, j + 1);
  	  }
        }
      }

      list.refresh();
    }

  // Project menu

    if (source == compileItem) {
      String str = (String) list.getSelectedItem();

      if (str != null && str.endsWith(".java"))
	compile(str, true);
    }

    if (source == buildItem) {
      int build = 0;

      for (int i = 0; i < project.size(); i++) {
	String[] item = (String[]) project.get(i);

	if (item[0].endsWith(".java")) {
	  File file = new File(item[0]);
	  long time = file.lastModified();

	  if (time != new Long(item[1]).longValue()) {
	    compile(item[0], false);
	
	    if (compileError)
	      break;
	    else {
	      item[1] = new Long(time).toString();
	      build++;
	    }
	  }
	}
      }

      if (build > 0)
        save(path);
    }

    if (source == buildAllItem) {
      boolean state = true;
      String str = (String) list.getSelectedItem();

      for (int i = 0; i < project.size(); i++) {
	String[] item = (String[]) project.get(i);

	if (item[0].endsWith(".java")) {
	  compile(item[0], false);

	  if (compileError) {
	    state = false;
	    break;
	  }
	  else
	    item[1] = new Long(new File(item[0]).lastModified()).toString();
	}
      }

      if (state)
        save(path);
    }


    if (source == runItem) {
      String cname = mclass.trim();

      if (cname.length() > 0) {
        String fs = System.getProperty("file.separator");
	String ipath = System.getProperty("java.home") + fs + "bin" + fs +
	  "java ";

	try {
	  console.set("Ready");
	  console.file = "";

          Process ps = Runtime.getRuntime().exec(ipath + cname);
	  InputStreamReader ir = new InputStreamReader(ps.getInputStream());
          BufferedReader br = new BufferedReader(ir);
          String str = br.readLine();

          while (str != null) {
 	    console.append(str);
	    str = br.readLine();
	  }
	}
	catch (Exception err) {
	  console.set("Problem running " + cname + ".");
	}
      }
      else
	console.set("No class to run.");
    }

    if (source == runAppletViewerItem) {
      String hname = html.trim();

      if (hname.length() > 0) {
        String fs = System.getProperty("file.separator");

	try {
	  Runtime.getRuntime().exec(System.getProperty("java.home") + fs + 
	    "bin" + fs + "appletviewer " + hname);
	}
	catch (Exception err) {
	  console.set("Problem running AppletViewer.");
	}
      }
      else
	console.set("Please specified the HTML file in Options menu");
    }

    if (source == runWebBrowserItem) {
      String hname = html.trim();

      if ((hname.length() > 0) && (browser.trim().length() > 0)) {
	try {
          String fs = System.getProperty("file.separator");
	  Runtime.getRuntime().exec(browser + " file://" + directory + fs
	    + hname);
	}
	catch (Exception err) {
	  console.set("Problem running web browser.");
	}
      }
      else {
	try {
	  Runtime.getRuntime().exec(browser);
	}
	catch (Exception err) {
  	  console.set("Problem running web browser.");
	}
      }
    }

    if (source == globalSearchItem) {
      if (searchDialog == null) {
      	searchDialog = new MJESearchDialog(this);
	searchDialog.pack();
      }

      searchDialog.setVisible(true);
    }

    if (source == optionsItem) {
      if (optionsDialog == null) {
      	optionsDialog = new MJEOptionsDialog(this);
	optionsDialog.pack();
      }

      optionsDialog.setVisible(true);
    }

   // Help menu

    if (source == aboutItem) {
      if (aboutDialog == null) {
        aboutDialog = new MJEInfoDialog(this, "About Mini Java Editor...",
          "Mini Java Editor v1.1b1 - By Lim Thye Chean");

	aboutDialog.pack();
      }

      aboutDialog.setVisible(true);
    }
  }
}

// 
// File list area
//

class MJEFiles extends List {
  MJE editor;

  public MJEFiles(MJE ed) {
    super();
    editor = ed;
  }

  public void refresh() {
    removeAll();

    for (int i = 0; i < editor.project.size(); i++)
      add(((String[]) editor.project.get(i))[0]);
  }

  public boolean action(Event evt, Object obj) {
    MJEWindow win = editor.getWindow((String) obj);

    if (win != null)
      win.setVisible(true);
    else
      editor.console.set("Cannot find " + obj + ".");

    return true;
  }
}

//
// Console
//

class MJEConsole extends List {
  MJE editor;
  String file = "";

  public MJEConsole(MJE ed) {
    super();
    editor = ed;
    set("Welcome to Mini Java Editor!");
  }

  public void set(String str) {
    removeAll();
    add(str);
  }

  public void append(String str) {
    add(str);
  }

  public boolean action(Event evt, Object obj) {
    if (file.length() > 0) {
      String str = (String) obj;

      if (str.charAt(0) == '*') {
        str = getItem(getSelectedIndex() + 1);
      }

      if (str.charAt(0) == ' ') { 
        for (int i = 4; i < 8; i++)
          if (str.charAt(i) == ' ') {
	    int line = Integer.parseInt(str.substring(3, i));
	    int col = 0;

	    for (int j = i + 2; j < i + 5; j++)
	      if (str.charAt(j) == ')') 
	        col = Integer.parseInt(str.substring(i + 2, j));

	    MJEWindow win = editor.getWindow(file);
	    win.show();

	    if (win != null)
	      win.gotoLine(line, col);

	    break;
          }
      }
    }

    return true;
  }
}

