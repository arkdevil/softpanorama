//
// Vertical Panel
//

package iss.awt;

import java.awt.*;

public class VPanel extends Panel {
  VGridLayout vgrid;

  public VPanel() {
    this(5, 0, 0);
  }

  public VPanel(int border, int gap, int left) {
    vgrid = new VGridLayout(new Insets(border, border, border, border), gap, 
      left);

    setLayout(vgrid);
  }

  public Component add(int size, Component comp) {
    vgrid.setConstraints(comp, size);
    add(comp);

    return comp;
  }
}
