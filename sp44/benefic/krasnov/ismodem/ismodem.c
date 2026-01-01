#include <dos.h>
#include <stdio.h>
#include <string.h>

#include "serial.h"

char OK [] = "OK";
char NO_CARRIER [] = "NO CARRIER";
char ppp [] = "+++\r";
char init_modem [] = "\rats0=0s7=20e0q0v1\r";
char hangUp [] = "\rath0\r";

int base_address [4] = { 0x3F8, 0x2F8, 0x3E8, 0x2E8 };

#define BUFSIZE	80
char buffer [4][BUFSIZE];
int bufptr [4] = { 0, 0, 0, 0 };

int was_irq [4] = { 0, 0, 0, 0 };

int is_OK [4] = { 0, 0, 0, 0 };
int is_NO_CARRIER [4] = { 0, 0, 0, 0 };

int modem_found [4] = { 0, 0, 0, 0 };

int vptr = 0;

void irq (int irqn){
    register port;
    int base;
    char status, c;

    for (base = base_address [port = 0]; port < 4; base = base_address [++port]){
	while (!((status = inp (base + IID) & 7) & NOIA)){
	    was_irq [port] = irqn;
	    switch (status){
		case MSI: inp (base + MSR); break;
		case TRI: inp (base + LSR); break;
		case LSI: inp (base + LSR); break;
		case RDRI:
		    c = inp (base + DATA);
		    pokeb (0xB800, vptr++ * 2, c);
		    if (vptr == 60) vptr = 0;
		    if (c == '\r'){
			buffer [port] [bufptr [port]] = '\0';
			bufptr [port] = 0;
			is_OK [port] = !strcmp (buffer [port], OK);
			is_NO_CARRIER [port] = !strcmp (buffer [port], NO_CARRIER);
			if (is_OK [port] || is_NO_CARRIER [port]) modem_found [port] = irqn;
		    } else if (c != '\n'){
			buffer [port] [bufptr [port]++] = c;
			if (bufptr [port] == BUFSIZE) bufptr [port] = 0;
		    }
		    break;
	    }
	}
    }
    outp (0x20, 0x20);
}

void interrupt irq3 (void){ irq (3); }
void interrupt irq4 (void){ irq (4); }
void interrupt irq5 (void){ irq (5); }
void interrupt irq7 (void){ irq (7); }

unsigned tout = 0;

void interrupt (*old_timer)(void);
void interrupt timer (void){
    old_timer ();
    if (tout > 0) tout--;
}

void time_delay (int t){
    tout = t;
    enable ();
    while (tout > 0);
}

void send_byte (char byte){
    int port, base;

    for (base = base_address [port = 0]; port < 4; base = base_address [++port]){
	while (!(inp (base + LSR) & THRE));
	outp (base + DATA, byte);
    }
}

void send_string (const char *str){
    while (*str) send_byte (*str++);
}

char save_21;

void init_ports (void){
    int port, base;

    for (base = base_address [port = 0]; port < 4; base = base_address [++port]){
	outp (base + LCR, DLAB1);	/* enable Divisor Latch */
	outp (base + BAUD0, 48);	/* set divisor to 2400 bps */
	outp (base + BAUD1, 0);		/* high byte of divisor */
	outp (base + LCR, DLAB0 + NO_PARITY + XSTOP1 + WD8);
	outp (base + IER, ERDRI);	/* enable Reseive Data Ready int in 8250 */
	outp (base + MCR, OUT2 + RTS + DTR);
	do {
	    inp (base + LSR); inp (base + DATA);
	    inp (base + MSR); inp (base + IID);
	} while (!(inp (base + IID) & NOIA));
    }
    outp (0x21, (save_21 = inp (0x21)) & ~0xF8);
}

void term_ports (void){
    int port, base;

    outp (0x21, save_21);
    for (base = base_address [port = 0]; port < 4; base = base_address [++port]){
	outp (base + IER, 0);	/* disable all ints in 8250 */
    }
}

void main (){
    register port;

    void interrupt (*old_irq3)() = getvect (0x0B);
    void interrupt (*old_irq4)() = getvect (0x0C);
    void interrupt (*old_irq5)() = getvect (0x0D);
    void interrupt (*old_irq7)() = getvect (0x0F);

    printf ("ISMODEM - определение наличия модема и его параметров (если модем есть)\n\n");
    setvect (0x0B, irq3);
    setvect (0x0C, irq4);
    setvect (0x0D, irq5);
    setvect (0x0F, irq7);
    old_timer = getvect (0x08);
    setvect (0x08, timer);

    init_ports ();
    time_delay (9); send_string (ppp);
    time_delay (9); send_string (init_modem);
    time_delay (9); send_string (hangUp);
    time_delay (18);
    for (port = 0; port < 4; port++){
	if (was_irq [port]){
	    printf ("Порт COM%d, было прерывание от IRQ %d\n",
		1 + port, was_irq [port]);
	    was_irq [port] = 0;
	}
	if (modem_found [port]){
	    printf ("Найден модем, порт COM%d, IRQ %d\n",
		1 + port, modem_found [port]);
	    goto ret;
	}
    }
    printf ("Модем не найден\n");
    ret:
    term_ports ();
    setvect (0x08, old_timer);
    setvect (0x0B, old_irq3);
    setvect (0x0C, old_irq4);
    setvect (0x0D, old_irq5);
    setvect (0x0F, old_irq7);
}
