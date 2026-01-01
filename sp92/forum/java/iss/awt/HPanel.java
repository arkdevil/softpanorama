//
// Horizontal Panel
//

package iss.awt;

import java.awt.*;

public class HPanel extends Panel {
  HGridLayout hgrid;

  public HPanel() {
    this(5, 0, 0);
  }

  public HPanel(int border, int gap, int left) {
    hgrid = new HGridLayout(new Insets(border, border, border, border), gap, 
      left);

    setLayout(hgrid);
  }

  public Component add(int size, Component comp) {
    hgrid.setConstraints(comp, size);
    add(comp);

    return comp;
  }

  public Component add(int size, Component comp, int pos) {
    hgrid.setConstraints(comp, size);
    add(comp, pos);

    return comp;
  }
}
