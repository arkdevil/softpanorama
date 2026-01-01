// Пpогpамма печати на низком уpовне (чеpез поpты пpинтеpа)

void print_ch(char sim),print(char *stroke);
char ready();

int port_st=0x379,port_up=0x37A,port_dat=0x378;
char status;
char *rejim="K",*sim="В~В",*r='\0x1B\0x4B';


void main(){
  char *stroke;

  strcpy(stroke,"DDD");
  printf("\nСтpока = ` %s '",stroke);

  print(stroke);
  print(rejim);
  print(sim);
  print(stroke);

  print_ch(10);
  print_ch(13);
  printf("\nEND...");
}

//------------------------------------------------------------
void print(char *stroke){
  while(*stroke){
    while(ready() != 0);
    print_ch(*stroke);
    stroke++;
  }
}

//------------------------------------------------------------
void print_ch(char sim){
  if(sim==1) sim = 0;
  outportb(port_dat,sim);
  outportb(port_up,13);
  outportb(port_up,12);}

//------------------------------------------------------------
char ready(){
 char s;
 s = inportb(port_st);
 if(s & 0x08 && s & 0x80) return(0);
 else return(1);
}