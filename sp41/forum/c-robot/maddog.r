/*            (c) Copyright 1991 by Troffimovky                          */
main()
{
int d,x,y,a,c;
while(1){
         while((c=scan(a,5))==0) a+=10;
         if(c<700) cannon(a,c);
         if(c>50) drive(a,49);
         if(c<50) {if(a>180) a-=180; else a+=180;}
	 drive(a,49);
         x=loc_x();
         y=loc_y();
         if(d!=damage()) drive(a+90,49);
         d=damage();
         if(x<40||y<40||y>960||x>960) drive(0,0);
       }
}
