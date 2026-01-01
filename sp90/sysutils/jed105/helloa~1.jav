import java.applet.* ;
import java.awt.* ;

public class HelloApplet extends Applet 
  {

    public void init()
      {
      }

    public void paint(Graphics gObject)
      {
        gObject.drawString("Hello, world!",40,40) ;
      }
  }

