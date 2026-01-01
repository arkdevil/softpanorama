/*              Simply Winner.   (C) Copr. 1991 Trofimovsky.                 */
main()
{

int x,y,a,c;

a=0;

while(1){

       while((c=scan(a,5))==0) a+=10;
         if(c!=0)
           cannon(a,c);
         drive(a,20);
         x=loc_x();
         y=loc_y();
         if(x<40||y<40||y>969||x>966) {
           if (a>=180) a-=180; else a+=180;
             drive(0,0);
	 }
 }
}