/*                         (c) by 1991 Troffimovsky                       */
main()
{
int x,y,a,b,c,d,e;
a=0;
b=360;
while(1){
       while(((c=scan(a,5))==0)&&((d=scan(b,5))==0)) { a+=10; b-=10; }
         if((c!=0)&&(c<700))
           cannon(a,c);
         if((d!=0)&&(d<700))
           cannon(b,d);
	 if(d!=damage())drive(a+90,49); 
         drive(a,49);
         x=loc_x();
         y=loc_y();
         if(b<180) b=360;
	 if(a>180) a=0; 
         if(x<40||y<40||y>969||x>966) {
           if (a>=180) a-=180; else a+=180;
             drive(0,0);
	 e = damage();
	 }
 }
}
