char c[]="PYRO - A Simulated Pyrotechnics display  20/10/87  (c) 1987 K.G. Shields",
    inkey,txt[]="THE END";
#include <stdlib.h>
#include <dos.h>
#include <math.h>
#define NI 6 /*Number of items*/
#define NP 60 /*Number of points per item*/
#define TP 400 /*Total number of points*/
union REGS inr,outr;
int xl[NI],xh[NI],yl[NI],yh[NI],vell[NI],velh[NI],angl[NI],angh[NI],alivel[NI],
    aliveh[NI],coll[NI],colh[NI],sizel[NI],sizeh[NI],fadev[NI],item_alive[NI],
    devicetype[NI],wait[NI],master[NI],g[TP],x[TP],y[TP],xvel[TP],yvel[TP],
    alive[TP],col[TP],size[TP],fade[TP],itemno[TP],next[TP],state[TP],im,jm,km,
    xmin,xmax,ymin,ymax,xend,yend,newpt,endpt,ci,num_active,num_dormant,freep,
    mastercol,sh=5,spurt=1,flare=2,burst=3,rocket=4,roman=5,sep=180,scan=179,
    gv=2,slowdown=80,statev=0,burstlife=10,noise=0;
float sina[361],cosa[361];
void terminate();
void setrange(int *d1,int *d2,int s1,int s2) /*Store limits information*/
{   if (s1<=s2) {*d1=s1;    *d2=s2;} else {*d1=s2;    *d2=s1;}   } /*End setrange*/
void limits(int it,int lxl,int lxh,int lyl,int lyh,int lvell,int lvelh,int langl,int langh,int lalivel,int laliveh,
int lcoll,int lcolh,int lsizel,int lsizeh,int lfade) /*Set limits for point generation for item it*/
{   setrange(&xl[it],&xh[it],lxl<<sh,lxh<<sh);
    setrange(&yl[it],&yh[it],lyl<<sh,lyh<<sh);
    setrange(&vell[it],&velh[it],lvell<<sh,lvelh<<sh);
    setrange(&angl[it],&angh[it],langl,langh);
    setrange(&alivel[it],&aliveh[it],lalivel,laliveh);
    setrange(&coll[it],&colh[it],lcoll,lcolh);
    setrange(&sizel[it],&sizeh[it],lsizel,lsizeh);
    fadev[it]=lfade;} /*End limits*/
int rnd(int low,int high) /*Returns a value between low and high (inclusive)*/
{   return low+(((long)rand()*(high-low+1))>>15);} /*End rnd*/
void show(int x,int y,int col,int size) /*Show (or remove) point x,y if it is visible*/
{   int i,x1,x2,dummy,address,lbit,rbit;
    if (y>=ymin) if (y<=ymax) if (x>=xmin) if (x<=xmax) {
        outportb(0x3ce,3);    outportb(0x3cf,0x18);/*Select Xor operation*/
        for (i=-(size-1); i<=size-1; i++) {
            x1=(x>>sh)-(size-1-abs(i));    x2=(x>>sh)+(size-1-abs(i));
            while (x1<=x2) {
                lbit=x1 & 7;    rbit=(x2>=(x1 | 7))? 7 : lbit+x2-x1;
                outportb(0x3ce,8);
                outportb(0x3cf,(unsigned char)(0xff<<(7-rbit+lbit))>>lbit);/*Set mask*/
                dummy=peekb(0xa000,address=((y>>sh)+i)*80+(x1>>3));/*Load latches*/
                outportb(0x3c4,2);    outportb(0x3c5,col);/*Select bit planes*/
                pokeb(0xa000,address,0xff);/*Set selected bits to 1*/
                x1=x1+rbit-lbit+1;}   }
    outportb(0x3ce,3);    outportb(0x3cf,0);/*Cancel Xor*/
    outportb(0x3ce,8);    outportb(0x3cf,0xff);/*No mask*/
    outportb(0x3c4,2);    outportb(0x3c5,0xff);/*Enable all bit planes*/}   } /*End limits*/
void release(int pt) /*Release point pt*/
{   alive[pt]=abs(alive[pt]);    scan=max(scan,pt);} /*End release*/
void create(int it,int *pt) /*Create a point for item it*/
{   int vel,angle;
    if (freep>=0) {*pt=freep;    freep=next[*pt];
    } else {for (*pt=sep;(*pt<TP) && (alive[*pt]!=0);(*pt)++); *pt=min(*pt,TP-1);}
    itemno[*pt]=it;    g[*pt]=gv;       fade[*pt]=fadev[it];    state[*pt]=statev;
    x[*pt]=rnd(xl[it],xh[it]);          y[*pt]=rnd(yl[it],yh[it]);
    vel=rnd(vell[it],velh[it]);         angle=rnd(angl[it],angh[it]);
    xvel[*pt]=vel*sina[180+angle];      yvel[*pt]=-(vel*cosa[180+angle]);
    col[*pt]=rnd(coll[it],colh[it]);    size[*pt]=rnd(sizel[it],sizeh[it]);
    if ((alive[*pt]=rnd(alivel[it],aliveh[it]))>0) release(*pt);} /*End create*/
void move_points() /*Move all active points through 1 step*/
{   int i,j;
    num_active=0;    num_dormant=0;
    for (j=0;j<=scan;j++)
        if (alive[j]<=0) {
            if (j<sep) for (i=1;i<=slowdown;i++);    if (alive[j]<0) num_dormant++;
        } else {
            if (noise>0) if (rand()<noise) outportb(0x61,3);
            if (state[j]>0) show(x[j],y[j],col[j],size[j]);
            else if (state[j]==0) state[j]=1;
            num_active++;    alive[j]--;    yvel[j]+=g[j];    x[j]+=xvel[j];
            if ((y[j]+=yvel[j])>ymax) {y[j]-=yvel[j]; xvel[j]=0;}
            if (alive[j]==0)
                if (g[j]==0) {
                    g[j]=gv;    alive[j]=10;
                } else if (size[j]>1) {
                    size[j]--;    alive[j]=fade[j];
                } else {
                    col[j]=0;    if (j<sep) {next[j]=freep;    freep=j;}   }
        show(x[j],y[j],col[j],size[j]);    outportb(0x61,0);}
    while ((scan>=sep) && (alive[scan]<=0)) scan--;
    if ((noise=abs(noise))>0) noise-=300;} /*End move_points*/
void process(int t,int waiting) /*Process currently set devices for t intervals*/
{   int it,i,timer;
    for (timer=1;timer<=t;timer++) {
        for (it=0;it<NI;it++) {
            if (item_alive[it]>0) item_alive[it]--; else devicetype[it]=0;
            switch(devicetype[it]) {
            /*SPURT*/ case 1:   if (wait[it]>130) create(it,&newpt);
                else if (wait[it]==0) {
                    setrange(&coll[it],&colh[it],rnd(9,15),rnd(9,15));
                    wait[it]=NP+130;}    break;
            /*FLARE*/ case 2:   create(it,&newpt);
                if (wait[it]==0) {
                    if (++coll[it]>=14) coll[it]=9;
                    colh[it]=coll[it]+1;    wait[it]=50;}    break;
            /*BURST*/ case 3:   if (wait[it]>0) create(it,&master[it]);
                else if (wait[it]==0) {
                    for (i=0;i<TP;i++) if ((alive[i]<0) && (itemno[i]==it)) release(i);
                    noise=-3000;}    break;
            /*ROCKET*/ case 4:  if (wait[it]==0) {release(master[it]);
                    item_alive[it]=alive[master[it]]+fade[master[it]]*(size[master[it]]-1);}
                if (alive[master[it]]>0) {
                    create(it,&newpt);    x[newpt]=x[master[it]]+rnd(-64,64);
                    y[newpt]=y[master[it]]+rnd(-64,64);    release(newpt);}    break;
            /*ROMAN*/ case 5:   if ((wait[it]<=9) && (wait[it]>0)) {create(it,&newpt);
                    x[newpt]=x[master[it]]+(3<<sh)*sina[180+(360*(wait[it]-5)/9)];
                    y[newpt]=y[master[it]]-(3<<sh)*cosa[180+(360*(wait[it]-5)/9)];
                    xvel[newpt]=xvel[master[it]];      yvel[newpt]=yvel[master[it]];
                    alive[newpt]=alive[master[it]];    col[newpt]=col[master[it]];
                } else if (wait[it]==0) {
                    limits(it,0,0,0,0,0,0,0,0,-10,-5,col[master[it]],col[master[it]],1,1,0);
                    for (i=0;i<TP;i++) if ((alive[i]<0) && (itemno[i]==it)) release(i);
                    item_alive[it]=alive[master[it]]+fade[master[it]]*(size[master[it]]-1);}
                    if (alive[master[it]]>0) {create(it,&newpt);
                        x[newpt]=x[master[it]]+rnd(-256,256);    y[newpt]=y[master[it]]+rnd(-64,64);
                        release(newpt);}   } /*End switch*/
            if ((wait[it]>-1) && (it!=waiting)) wait[it]--;}
        if (kbhit()) terminate();
        move_points();}   } /*End process*/
void terminate() /*Terminate display*/
{   int i,j,k,l;
    if ((inkey=kbhit()? getch(): 0)==27) exit(0);
    for (j=1;(j<=800) && (num_active+num_dormant>0);j++) process(1,-1);
    gv=0;    statev=0;    for (j=0;j<28000;j++) pokeb(0xa000,j,0);
    for (i=0;i<=6;i++) {
        if (txt[i]!=' ') for (j=7;j>=0;j--) for (k=0;k<=7;k++) if ((peekb(0xf000,0xfa6e+j+8*txt[i]) & (0x80>>k))>0) {
        limits(0,68+72*i+8*k-1,68+72*i+8*k+2,150+8*j-1,150+8*j+2,0,0,0,0,20,40,13,13,3,3,65);
        create(0,&newpt);    for (l=1;l<=3000;l++);}
    process(4,-1);}
    gv=1;    for (j=1;(j<=800) && (num_active>0);j++) process(1,-1);
    inr.x.ax=0x0003;    int86(0x10,&inr,&outr);    exit(0);} /*End terminate*/
void calc_end() /*Calculate endpoint for burst*/
{   endpt=NP-wait[ci]+1;    if ((mastercol=col[master[ci]])==15) mastercol=14;
    alive[master[ci]]=-(endpt-(size[master[ci]]-1)*fade[master[ci]]);
    xend=x[master[ci]]+endpt*xvel[master[ci]];
    yend=y[master[ci]]+endpt*yvel[master[ci]]+(gv*endpt*endpt)/2;} /*End calc_end*/
void startup(int devtype,int xi,int yi,int life,int p1,int p2,int p3,int p4,int waiting) /*Initializes a device*/
{   ci=0;    while (item_alive[ci]>0) {process(1,waiting);    if (++ci>=NI) ci=0;}
    devicetype[ci]=devtype;    item_alive[ci]=life;
    switch(devicetype[ci]) {
    /*SPURT*/ case 1:   coll[ci]=rnd(9,15);
        limits(ci,xi-5,xi+5,340,340,3,8,-20,20,120,160,coll[ci],rnd(coll[ci],15),2,2,25);
        wait[ci]=NP+130;    break;
    /*FLARE*/ case 2:   coll[ci]=rnd(9,14);
        limits(ci,xi-5,xi+5,340,340,4,8,-20,20,20,30,coll[ci],coll[ci]+1,2,2,2);
        wait[ci]=50;    break;
    /*BURST*/ case 3:   if (waiting<0) coll[ci]=rnd(9,14); else coll[ci]=mastercol;
        limits(ci,xi-5,xi+5,yi-5,yi+5,rnd(p1,p2),rnd(p3,p4),-180,180,-2*burstlife,-burstlife,coll[ci],coll[ci]+1,2,2,rnd(burstlife,3*burstlife));
        wait[ci]=NP;    break;
    /*ROCKET*/ case 4:  limits(ci,xi,xi,340,340,5,10,p1,p2,-90,-80,9,15,3,4,3);
        wait[ci]=20;    create(ci,&master[ci]);
        limits(ci,xi,xi,340,340,-2,2,90,90,-6,-7,col[master[ci]],col[master[ci]],2,2,20);
        vell[ci]=vell[ci]>>1;    velh[ci]=velh[ci]>>1;    calc_end();    break;
    /*ROMAN*/ case 5:   limits(ci,xi,xi,340,340,6,11,-10,10,-70,-100,9,15,3,3,1);
        wait[ci]=30;    create(ci,&master[ci]);    calc_end();
    }   } /*End startup*/
void multiple(int typ,int n,int rep,int life,int gap,int pause) /*Multiple item display*/
{   int i,j;
    for (j=1;j<=rep;j++) for (i=1;i<=n;i++) {
        switch(typ) {
        /*ROCKET*/ case 4: startup(rocket,320+100*rnd(-1,1),340,100,-45,45,0,0,-1);
            if (rand()<25000) startup(burst,xend>>sh,yend>>sh,100,1,3,5,12,ci);    break;
        /*ROMAN*/ case 5: startup(roman,i*(640/(n+1)),340,100,0,0,0,0,-1);
            startup(burst,xend>>sh,yend>>sh,100,8,8,10,12,ci);    break;
        default: if (typ==burst) startup(burst,rnd(150,540),rnd(50,200),life,1,3,5,12,-1);
            else startup(typ,i*(640/(n+1)),340,life,0,0,0,0,-1);} /*End switch*/
        process(gap,-1);}
    process(pause,-1);}/*End multiple*/
main(int argc,char **argv)
{   inr.x.ax=0x0010;    int86(0x10,&inr,&outr);
    inr.x.ax=0x1000;    inr.x.bx=0;    int86(0x10,&inr,&outr);
    inr.x.ax=0x2c00;    int86(0x21,&inr,&outr);    srand(outr.x.dx);
    setrange(&xmin,&xmax,5<<sh,634<<sh);    setrange(&ymin,&ymax,5<<sh,344<<sh);
    for (im=0;im<NI;item_alive[im]=0,im++) /*Initialize items*/
    for (jm=0;jm<TP;alive[jm]=0,next[jm]=jm+1,jm++); /*List of free points*/
    freep=0;    next[sep-1]=-1; /*Restrict to first sep points mostly*/
    for (im=0;im<=90;im++) {
        sina[180+im]=sin(im/57.29578);     sina[180+-im]=-sina[180+im];
        sina[180+180-im]=sina[180+im];     sina[180+im-180]=-sina[180+im];
        cosa[180+im]=cos(im/57.29578);     cosa[180+-im]=cosa[180+im];
        cosa[180+180-im]=-cosa[180+im];    cosa[180+im-180]=-cosa[180+im];}
    do {multiple(flare,3,1,200,20,150);    multiple(spurt,1,1,450,20,500);
        multiple(burst,5,1,100,10,75);     multiple(rocket,5,3,100,10,0);
        multiple(burst,5,1,100,10,35);     multiple(spurt,2,1,450,20,500);
        multiple(flare,4,1,200,20,150);    multiple(burst,5,1,100,10,25);
        multiple(roman,5,3,100,10,60);
        statev=-1;    burstlife=20; /*Set up for finale*/
        startup(burst,150,200,100,1,3,3,5,-1);    process(30,-1);
        startup(burst,500,100,100,1,3,3,5,-1);    process(50,-1);
        startup(burst,250, 50,100,1,3,3,5,-1);    process(180,-1);
        statev=0;    burstlife=10;    for (im=0;im<28000;im++) pokeb(0xa000,im,0);} /*End of finale*/
    while ((argc>1) && ((argv[1][0]=='c') || (argv[1][0]=='C')));
    terminate();
} /*End main*/
