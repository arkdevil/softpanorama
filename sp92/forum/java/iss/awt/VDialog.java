//
// Vertical Dialog
//

package iss.awt;
import java.awt.*;

public class VDialog extends Dialog {
  VGridLayout vgrid;

  public VDialog(Frame parent, boolean modal) {
    super(parent, modal);
    setup();
  }

  public VDialog(Frame parent, String title, boolean modal) {
    super(parent, modal);
    setup();
  }
 
  public void setup() {
    vgrid = new VGridLayout(new Insets(10, 10, 35, 20), 0, 0);
    setLayout(vgrid);
  }

  public Component add(int size, Component comp) {
    vgrid.setConstraints(comp, size);
    add(comp);

    return comp;
  }

  public HPanel addPanel() {
    HPanel hp = new HPanel();
    add(0, hp);

    return hp;
  }

  public HPanel addPanel(int border, int gap, int left) {
    HPanel hp = new HPanel(border, gap, left);
    add(0, hp);

    return hp;
  }
}
