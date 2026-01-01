//
Mini Java Editor - By Lim Thye Chean
This is a test.
//fff
Frame {
  static int max = 1;
ew MenuItem("Exit"));
    menuBar.add(fileMenu);

  // Create edit menu

      writeFile(saveFile, area.getText());
    }

    if (label.equals("Save as...")) {
      FileDialog dialog = new FileDialog(this, "Save as...", FileDialog.SAVE);
      
      dialog.setFile(saveFile);
      dialog.show();
      file = dialog.getFile();

      if (file != null) {
	setTitle(file + " - Mini Java Editor");
	saveFile = file;
    s.r

//
// Output area
//

class MJEOutput extends List {
  MJEWindow win;

  public MJEOutput(MJEWindow w, int rows) {
    super(rows, false);
    win = w;
  }

  public void clear() {
    set("Ready.");
  }

  public void set(String str) {
    delItems(0, countItems() - 1);
    addItem(str);
  }

  public boolean action(Event evt, Object obj) {
    String str = (String) obj;

    if (str.charAt(0) 
