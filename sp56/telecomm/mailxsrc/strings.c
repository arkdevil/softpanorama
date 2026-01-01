/*
 * Mail -- a mail program
 *
 * String allocation routines.
 * Strings handed out here are reclaimed at the top of the command
 * loop each time, so they need not be freed.
 *
 * $Log:	strings.c,v $
 * Revision 1.6  92/08/24  02:22:42  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.8  1990/12/26  23:37:32  ache
 * Проверка вынесена на #define
 *
 * Revision 1.7  90/12/25  03:53:55  ache
 * Правлена древняя ошибка с затиранием памяти
 * 
 * Revision 1.6  90/12/22  22:53:45  ache
 * Сортировка + выдача ФИО
 * 
 * Revision 1.5  90/12/03  03:21:19  ache
 * Исправлено под 16-битн. тачки
 * 
 * Revision 1.4  90/09/21  22:00:39  ache
 * MS-DOS extends + some new stuff
 * 
 * Revision 1.3  88/07/23  20:38:37  ache
 * Русские диагностики
 * 
 * Revision 1.2  88/01/11  12:45:52  avg
 * Добавлен NOXSTR у rcsid.
 * 
 * Revision 1.1  87/12/25  16:00:56  avg
 * Initial revision
 * 
 */

#include "rcv.h"

/*NOXSTR*/
static char rcsid[] = "$Header: strings.c,v 1.6 92/08/24 02:22:42 ache Exp $";
/*YESXSTR*/
extern char *malloc();

/*
 * The pointers for the string allocation routines,
 * there are NSPACE independent areas.
 * The first holds STRINGSIZE bytes, the next
 * twice as much, and so on.
 */

#define STRINGSIZE      128             /* Dynamic allocation units */

#if defined(M_XENIX) && !defined(M_I386) || defined(MSDOS)
#define NSPACE  (16 - 7)                /* Total number of string spaces */
#else
#define NSPACE  (32 - 7)                /* Total number of string spaces */
#endif
static struct strings {
	char    *s_topFree;             /* Beginning of this area */
	char    *s_nextFree;            /* Next alloctable place here */
	unsigned s_nleft;               /* Number of bytes left here */
} stringdope[NSPACE];

#ifdef  DEBUG_ALLOC
#define KLUDGE 10
void check_salloc();
#else
#define KLUDGE 0
#endif
/*
 * Allocate size more bytes of space and return the address of the
 * first byte to the caller.  An even number of bytes are always
 * allocated so that the space will always be on a word boundary.
 * The string spaces are of exponentially increasing size, to satisfy
 * the occasional user with enormous string size requests.
 */

char *
salloc(size)
unsigned size;
{
	register char *t;
	register unsigned s;
	register struct strings *sp;
	unsigned need, index;

	if ((s = size) == 0)
		panic("Zero salloc size");
	s += sizeof(int) - 1;
	s &= ~(sizeof(int) - 1);
#ifdef  DEBUG_ALLOC
	check_salloc(0x200);
#endif
	for (sp = stringdope, index = 0; index < NSPACE; sp++, index++) {
		need = STRINGSIZE << index;
		if (sp->s_topFree == NOSTR && need >= s)
			break;  /* Found first free space */
		if (sp->s_nleft >= s)
			break;  /* Found tail free space */
	}
	if (index >= NSPACE)    /* Not found any space */
		panic(ediag("String too large","Слишком большая строка"));
	if (sp->s_topFree == NOSTR) {   /* First free */
		if ((sp->s_topFree = malloc(need + KLUDGE, sizeof(char))) == NOSTR) {
			fprintf(stderr, ediag(
"No room for space %u bytes\n",
"Нет памяти для %u байт\n"),
need*sizeof(char));
			panic(ediag("Internal error","Внутренняя ошибка"));
		}
#ifdef  DEBUG_ALLOC
		for (t = &sp->s_topFree[need]; t < &sp->s_topFree[need + KLUDGE]; t++)
			*t = '\200';
#endif
		sp->s_nextFree = sp->s_topFree;
		sp->s_nleft = need;
	}
	sp->s_nleft -= s;
	t = sp->s_nextFree;
	sp->s_nextFree += s;
	return(t);
}

char *scalloc(size)
unsigned size;
{
	register char *s;
	register unsigned i;
	char *ret = salloc(size);

	s = ret;
	for (i = 0; i < size; i++)
		*s++ = '\0';
	return ret;
}

/*
 * Reset the string area to be empty.
 * Called to free all strings allocated
 * since last reset.
 */
void
sreset()
{
	register struct strings *sp;
	register unsigned index, need;
	char *t;

	if (noreset)
		return;
	minit();
#ifdef  DEBUG_ALLOC
	check_salloc(0x201);
#endif
	for (sp = stringdope, index = 0; index < NSPACE; sp++, index++) {
		need = STRINGSIZE << index;
		if (sp->s_topFree == NOSTR)     /* Already free */
			continue;
		sp->s_nextFree = sp->s_topFree;
		sp->s_nleft = need;
	}
}

#ifdef  DEBUG_ALLOC
void
check_salloc(num)
{
	char *str;
	unsigned need, index;
	register struct strings *sp;
	char *t;

	for (sp = stringdope, index = 0; index < NSPACE; sp++, index++)
		if ((str = sp->s_topFree) != NOSTR) {
			need = STRINGSIZE << index;
			for (t = &str[need]; t < &str[need + KLUDGE]; t++)
				if (*t != '\200') {
					fprintf(stderr,"Bound %x alloc error: tail=\"", num);
					for (t = str; t < &str[need + KLUDGE]; t++)
						if ((*t&0377) <  ' ') {
							fputc('^', stderr);
							fputc(*t|0100, stderr);
						}
						else
							fputc(*t, stderr);
					fprintf(stderr, "\"\n");
					panic(ediag("Internal error","Внутренняя ошибка"));
				}
		}
}
#endif
