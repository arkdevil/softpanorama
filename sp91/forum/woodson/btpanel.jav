/*
 * Program: btPanel.java
 * 
 * Author: Michael Woodson
 * 
 * E-mail: n9442097@fozzie.cc.wwu.edu
 *
 * Date: March 16, 1996
 * 
 * Please send suggestions to the above e-mail address.
 * 
 * This applet is intended to be used as a learning tool for concepts in
 * binary trees.
 *
 */


import java.awt.*;
import java.applet.*;


public class btPanel extends Panel implements Runnable {

   public static final int TOTALWIDTH = 640;
   public static final int WIDTH = 640;
   public static final int HEIGHT = 300;
   
   static final int LongTime=5000; // Times in milliseconds.
   static final int ShortTime=500;
   static final int AnimationTime=50;
   static final int framenumber=10;

   static final int NodeNumber=1000; // The maximum number of nodes in the tree
   static final int MaxHeight=10;    // The maximum height of the tree.
     
   static final String pausestr="Pause";
   static final String balancestr="Balance";
   static final String highspeedstr="High Speed";
   static final String randomstr="Random List";
   static final String orderedstr="Ordered List";
   static final String userdefinedstr="User Defined";
   static final String autostr="Auto Growing";
   static final String manualstr="Manual Growing";

   static final String incrementstr="Next";

   static final String resetstr="Reset";
   
   public Thread btThread;
   public boolean order,generate,useBuilder,random,move;
  
   Applet a;			// Needed for images.

   Image buffer;		// For double-buffering.
   Graphics bg;			// Buffer Graphics.  Not background.

   Button PauseResume,RandomOrdered,BalanceNormal,Speed,AutoManual,Next;
   Panel bottom,info;

   btPanel btp;
   btNode root,temp;
   btCanvas screen;

   Panel changepanel=new Panel();
   Panel pausespeedpanel=new Panel();

   Checkbox pausecb=new Checkbox(pausestr);
   Checkbox highspeedcb=new Checkbox(highspeedstr);
   Checkbox balancecb=new Checkbox(balancestr);

   int sleepTime;
   int currentWidth = 5;
   int oldheight;
   

   Builder builder;		// Used to balance the tree.
   int next,counter;

   Label nextlabel,heightlabel;
   Choice listchoice=new Choice(),growthchoice=new Choice();
   
   CardLayout cl=new CardLayout();
   TextField tf=new TextField();

   char[] liststr={'0'};
   int marker=0;

   public btPanel(Applet a) {
      
      resize(WIDTH,HEIGHT);
            
      this.a=a;
      
      setLayout(null);

      pausespeedpanel.setLayout(new GridLayout(1,2));
      pausespeedpanel.add(pausecb);
      pausespeedpanel.add(highspeedcb);

      changepanel.setLayout(cl);
      changepanel.add(manualstr,new Button(incrementstr));
      changepanel.add(autostr,pausespeedpanel);
      cl.show(changepanel,autostr);

      bottom = new Panel();
      bottom.setLayout(new GridLayout(1,5));
      bottom.add(balancecb);
      listchoice.addItem(orderedstr);
      listchoice.addItem(randomstr);
      listchoice.addItem(userdefinedstr);
      bottom.add(listchoice);
      growthchoice.addItem(manualstr);
      growthchoice.addItem(autostr);
      bottom.add(growthchoice);
      bottom.add(changepanel);
      bottom.add(new Button(resetstr));
      growthchoice.select(autostr);
      listchoice.select(randomstr);

      bottom.reshape(0,275,640,25);
      add(bottom);
      
      screen=new btCanvas(this);
      screen.reshape(0,25,640,225);
      add(screen);

      info=new Panel();
      info.setLayout(new FlowLayout());
      info.add(new Label("Next: "));
      info.add(nextlabel=new Label(" "));
      info.add(new Label("Height: "));
      info.add(heightlabel=new Label(" "));
      info.reshape(0,0,640,25);
      add(info);

      buffer = a.createImage(WIDTH,HEIGHT);
      bg = buffer.getGraphics();

      move = useBuilder = false;
      random = generate = true;

      builder = new Builder();
      sleepTime=ShortTime;

      tf.reshape(0,250,640,25);

      reset();
      
   }

   public void add(Builder b) {
      builder = b;		// This replaces the default builder.
   }

   public void start() 
   {
      if (btThread == null) 
      {
	 btThread=new Thread(this);
	 btThread.start();
      }
   }   

   public void stop()
   {
      if (btThread != null) 
      {
	 btThread.stop();
	 btThread = null;
      }
   }

   boolean adigit(char c) {
      return (c>='0')&&(c<='9');
   }

   void say(String s) {
      System.out.println(s);
   }

   int getNext() throws NumberFormatException {
      StringBuffer sb=new StringBuffer();
      liststr=tf.getText().toCharArray();
      try {
         while (!adigit(liststr[marker])) marker++;
         while (adigit(liststr[marker])) {
            sb=sb.append(liststr[marker]);
            marker++;
         }
         return Integer.parseInt(sb.toString());
      } catch(ArrayIndexOutOfBoundsException e) {
         String s=sb.toString();
         marker=0;                      
         if (s!="") return Integer.parseInt(s);
         else return getNext();
      }
   }

   
   synchronized void addnode() {
      try {
	 if (root==null) root=new btNode(next);
	 else 
	 {
	    temp=new btNode(next);
	    if (balancecb.getState()) 
	       root = builder.add(temp,root);
	    else
	       root.add(temp);
	 }
	 
	 if (random)
            next=(int)(Math.random()*NodeNumber);
         else if (order)
            next=--counter;
         else {
            try {next=getNext();}
            catch (NumberFormatException ex) {}
         }

         next%=1000;
	 
	 if (oldheight!=root.tightheight()) {
	    int idealWidth = 5;
	    for (int i=0;i<root.tightheight();i++) {
	       idealWidth *= 2;
	    }
	    double wstep = ((idealWidth-currentWidth)/framenumber);
	    for (int i=0;i<framenumber;i++) {
	       currentWidth += (int)(wstep*i);
               root.setLocation(WIDTH/2,btNode.nodesize/2,currentWidth);
	       currentWidth -= (int)(wstep*i);
	       screen.paint(screen.getGraphics());
	       try{Thread.sleep(AnimationTime);}
	       catch (InterruptedException e) {}
	    }
	    currentWidth = idealWidth;
	    if (root.height() > MaxHeight)
	       reset();
	    if (currentWidth > TOTALWIDTH) 
	       reset();
	 }
         root.setLocation(WIDTH/2,10,currentWidth);
	 screen.paint(screen.getGraphics());
	 nextlabel.setText(Integer.toString(next));
	 heightlabel.setText(Integer.toString(root.height()));
	 oldheight=root.tightheight();
      }
      catch (NullPointerException e) {}
   }
   
   
   
   public void run() {
      
      while (true) {
         if (highspeedcb.getState()) sleepTime=ShortTime;
         else sleepTime=LongTime;
	 if (!pausecb.getState()) {
            if(generate)addnode();
	 }
	 try{Thread.sleep(sleepTime);}
	 catch (InterruptedException e) {}
      }
   }

   void reset() {
      root=temp=null;
      marker=0;
      if(random) next = (int)(Math.random()*NodeNumber);
      else if (order) next = counter = NodeNumber-1;
      else {
         try{next=getNext();}
         catch(NumberFormatException e) {}
      }
      addnode();
   }

   public boolean action(Event e,Object arg) {

      if (resetstr.equals(arg)) {
	 reset();
      }
      else if (balancecb.equals(arg)) {
         reset();
      }
      else if (randomstr.equals(arg)) 
      {
	 random=true;
         remove(tf);
	 reset();
      }
      else if (orderedstr.equals(arg)) 
      {
	 random=false;
         order=true;
         remove(tf);
	 reset();
      }
      else if (userdefinedstr.equals(arg)) {
         random=order=false;
         reset();
         liststr=tf.getText().toCharArray();
         add(tf);
      }
      else if (incrementstr.equals(arg)) {
	 addnode();
      } else {
         switch(e.id) {
            case Event.ACTION_EVENT:
               if (growthchoice.equals(e.target)) {
                  if (growthchoice.getSelectedItem().equals(autostr)) {
                     cl.show(changepanel,autostr);
                     generate=true;
                  } else {
                     cl.show(changepanel,manualstr);
                     generate=false;
                  }
               } else if (balancecb.equals(e.target)) {
                  reset();
               }
            
         }
      }
      
      return true;
   }
}




class Builder {

/* Extend this class to write your own balancing algorithm */

   public btNode add(btNode x,btNode tree) {
      tree.add(x);
      return tree;
   }
}

class btCanvas extends Canvas {

   btPanel btp;

   public btCanvas (btPanel btp) {
      super();
      this.btp = btp;
   }

   public void update(Graphics g) {
      paint(g);
   }
   
   public synchronized void paint(Graphics g) {
      try {
	 btp.bg.setColor(Color.white);
	 btp.bg.fillRect(0,0,btp.TOTALWIDTH,btp.HEIGHT);
	 btp.bg.setColor(Color.black);
	 btp.root.drawPath(btp.bg);
	 btp.root.drawCells(btp.bg);
	 g.drawImage(btp.buffer,0,0,null);
      } catch (NullPointerException e) {}
   }
}

class btNode 
{
   int key;
   
   btNode left;
   btNode right;
   
   int width=10;
   int height=10;
   
   static final int nodesize=20;
   static final int vstep=nodesize+5;
   static int idealWidth;

   static final Color NodeColor=Color.yellow;
   static final Color TextColor=Color.black;
   

   public btNode(int x) {
      key = x;
   }
   
   public void add(btNode x) {

      if (x.key<key) {
	 if (left == null) left = x;
	 else {
	    left.add(x);
	 }
      }
      else if (x.key>key) {
	 if (right == null) right = x;
	 else {
	    right.add(x);
	 }
      }
   }
   
   public int height() { 
      int lh,rh;

      if (left == null) lh = -1;
      else lh = left.height();

      if (right == null) rh = -1;
      else rh = right.height();

      if (rh > lh) return rh + 1;
      else return lh + 1;
   }
   
   public int tightheight() 
   {
      int ch,lh,rh;
      lh=rh=ch=-1;
      
      if ((left != null) && (right != null))
      {
	 lh=left.tightheight();
	 rh=right.tightheight();
	 ch=0;
      }
      else if (left != null) lh=left.tightheight();
      else if (right != null) rh=right.tightheight();
      
      if (lh > ch) ch=lh;
      if (rh > ch) ch=rh;

      if (ch<0) return -1;
      else return ch+1;
   }
   
      

   public void setLocation(int newwidth,int newheight,int hstep) {

      width=newwidth;
      height=newheight;

      if (left != null) 
	 left.setLocation(newwidth-hstep,newheight+vstep,hstep/2);

      if (right != null) 
	 right.setLocation(newwidth+hstep,newheight+vstep,hstep/2);
   }

   public void drawPath(Graphics g) {

      if (left != null) {
	 g.drawLine(width,height,left.width,left.height);
	 left.drawPath(g);
      }

      if (right != null) {
	 g.drawLine(width,height,right.width,right.height);
	 right.drawPath(g);
      }
   }
  
   public void drawCells(Graphics g) {

      g.setColor(NodeColor);
      g.fillOval(width-nodesize/2, height-nodesize/2, nodesize, nodesize);

      g.setColor(TextColor);
      g.drawString(Integer.toString(key),width-8,height+5);
      
      if(left!=null) left.drawCells(g);
      if(right!=null) right.drawCells(g);
   }
}
