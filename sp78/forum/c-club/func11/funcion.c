#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

enum e_tipo {tipo_nul, tipo_valor, tipo_variable, tipo_operador, tipo_funcion};

int inc=0;
char copia[1024];
int cursor;
double x;
int prioridad_global;
void (*f_error)(char *s, int cursor);

int equal(const char *s2)
{
	if (strncmp(copia+cursor,s2,strlen(s2))==0)
	{
		inc=strlen(s2);
		return (1);
	}
	else return(0);
}

void parsea(char *texto, enum e_tipo *tipo, double *valor, char *variable, char *operador, double (**funcion)(double x))
{
	if (texto!=NULL)
	{
		if (strlen(copia)>=1024) exit(-1);
		strcpy(copia, texto);
		cursor=0;
	}
	if (cursor>=strlen(copia))
	{
		*tipo=tipo_nul;
		return;
	}

	*tipo=tipo_operador;
	switch (copia[cursor])
	{
		case '(':
		{
			cursor++;
			*operador='(';
			return;
		}
		case ')':
		{
			cursor++;
			*operador=')';
			return;
		}
		case '+':
		{
			cursor++;
			*operador='+';
			return;
		}
		case '-':
		{
			cursor++;
			*operador='-';
			return;
		}
		case '*':
		{
			cursor++;
			*operador='*';
			return;
		}
		case '/':
		{
			cursor++;
			*operador='/';
			return;
		}
		case '^':
		{
			cursor++;
			*operador='^';
			return;
		}
	}

	*tipo=tipo_valor;
	{
		char *endptr;

		*valor=strtod(copia+cursor, &endptr);
		if ((endptr==NULL)||(strlen(copia+cursor)>strlen(endptr)))
		{
			int l;

			if (endptr==NULL) l=0;
			else l=strlen(endptr);
			cursor+=strlen(copia+cursor)-l;
			return;
		}
	}

	*tipo=tipo_funcion;
	if ((equal("sqrt"))||(equal("Sqrt"))||(equal("SQRT")))
	{
		*funcion=sqrt;
		cursor+=inc;
	}
	else if ((equal("abs"))||(equal("Abs"))||(equal("ABS")))
	{
		*funcion=fabs;
		cursor+=inc;
	}
	else if ((equal("log"))||(equal("Log"))||(equal("LOG")))
	{
		*funcion=log;
		cursor+=inc;
	}
	else if ((equal("log10"))||(equal("Log10"))||(equal("LOG10")))
	{
		*funcion=log10;
		cursor+=inc;
	}
	else if ((equal("exp"))||(equal("Exp"))||(equal("EXP")))
	{
		*funcion=exp;
		cursor+=inc;
	}
	else if ((equal("sinh"))||(equal("SinH"))||(equal("SINH"))||(equal("senh"))||(equal("SenH"))||(equal("SENH")))
	{
		*funcion=sinh;
		cursor+=inc;
	}
	else if ((equal("cosh"))||(equal("CosH"))||(equal("COSH")))
	{
		*funcion=cosh;
		cursor+=inc;
	}
	else if ((equal("tanh"))||(equal("TanH"))||(equal("TANH")))
	{
		*funcion=tanh;
		cursor+=inc;
	}
	else if ((equal("sin"))||(equal("Sin"))||(equal("SIN"))||(equal("sen"))||(equal("Sen"))||(equal("SEN")))
	{
		*funcion=sin;
		cursor+=inc;
	}
	else if ((equal("cos"))||(equal("Cos"))||(equal("COS")))
	{
		*funcion=cos;
		cursor+=inc;
	}
	else if ((equal("tan"))||(equal("Tan"))||(equal("TAN")))
	{
		*funcion=tan;
		cursor+=inc;
	}
	else if (equal("x"))
	{
		*variable='x';
		*tipo=tipo_variable;
		cursor+=inc;
	}
	else
	{
		*funcion=NULL;
		cursor++;
	}
}

struct s_arbol
{
	enum e_tipo tipo;
	char operador;
	int prioridad;
	double valor;
	char variable;
	double (*funcion)(double x);
	struct s_arbol *hoja1, *hoja2;
	int cursor;
};

struct s_arbol *arbol_crea(void);
void arbol_mete(struct s_arbol *arbol, struct s_arbol *a);
double arbol_calcula(struct s_arbol *arbol);
void arbol_comprueba(struct s_arbol *arbol);

struct s_arbol *arbol_crea(void)
{
	struct s_arbol *arbol;

	arbol=(struct s_arbol *)malloc(sizeof(struct s_arbol));
	arbol->tipo=tipo_nul;
	arbol->operador='\0';
	arbol->prioridad=0;
	arbol->valor=0;
	arbol->variable='\0';
	arbol->funcion=NULL;
	arbol->hoja1=arbol->hoja2=NULL;
	arbol->cursor=0;
	return(arbol);
}

void arbol_mete(struct s_arbol *arbol, struct s_arbol *a)
{
	if (arbol->tipo==tipo_nul)
	{
		arbol->tipo=a->tipo;
		arbol->operador=a->operador;
		arbol->prioridad=a->prioridad;
		arbol->valor=a->valor;
		arbol->variable=a->variable;
		arbol->funcion=a->funcion;
		arbol->hoja1=a->hoja1;
		arbol->hoja2=a->hoja2;
		if (arbol->hoja1!=NULL) exit(-1);
		if (arbol->hoja2!=NULL) exit(-1);
		arbol->cursor=a->cursor;
		free(a);
	}
	else
	{
		struct s_arbol *p, *p_old;

		p_old=NULL;
		p=arbol;
		while ((p->prioridad>a->prioridad)&&(p!=NULL))
		{
			p_old=p;
			p=p->hoja2;
		}
		if (p==NULL)
		{
			if (p_old==NULL) exit(-1);
			p_old->hoja2=a;
		}
		else
		{
			struct s_arbol *copia;

			if (a->hoja1!=NULL) exit(-1);
			if (a->hoja2!=NULL) exit(-1);
			copia=arbol_crea();
			copia->tipo=p->tipo;
			copia->operador=p->operador;
			copia->prioridad=p->prioridad;
			copia->valor=p->valor;
			copia->variable=p->variable;
			copia->funcion=p->funcion;
			copia->hoja1=p->hoja1;
			copia->hoja2=p->hoja2;
			copia->cursor=p->cursor;
			a->hoja1=copia;
			if (p_old!=NULL)
			{
				p_old->hoja2=a;
				free(p);
			}
			else
			{
				arbol->tipo=a->tipo;
				arbol->operador=a->operador;
				arbol->prioridad=a->prioridad;
				arbol->valor=a->valor;
				arbol->variable=a->variable;
				arbol->funcion=a->funcion;
				arbol->hoja1=a->hoja1;
				arbol->hoja2=a->hoja2;
				arbol->cursor=a->cursor;
				free(a);
			}
		}
	}
}

double arbol_calcula(struct s_arbol *arbol)
{
	switch (arbol->tipo)
	{
		case tipo_nul: exit(-1);
		case tipo_valor:return(arbol->valor);
		case tipo_variable:return(x);
		case tipo_operador:
		{
			if (arbol->hoja2==NULL) exit(-1);
			switch (arbol->operador)
			{
				case '^':return(pow(arbol_calcula(arbol->hoja1),arbol_calcula(arbol->hoja2)));
				case '*':return(arbol_calcula(arbol->hoja1)*arbol_calcula(arbol->hoja2));
				case '/':return(arbol_calcula(arbol->hoja1)/arbol_calcula(arbol->hoja2));
				case '+':
				{
					if (arbol->hoja1==NULL) return(arbol_calcula(arbol->hoja2));
					else return(arbol_calcula(arbol->hoja1)+arbol_calcula(arbol->hoja2));
				}
				case '-':
				{
					if (arbol->hoja1==NULL) return(-(arbol_calcula(arbol->hoja2)));
					else return(arbol_calcula(arbol->hoja1)-arbol_calcula(arbol->hoja2));
				}
			}
		}
		case tipo_funcion:
		{
			if (arbol->hoja1!=NULL) exit(-1);
			if (arbol->hoja2==NULL) exit(-1);
			return((*arbol->funcion)(arbol_calcula(arbol->hoja2)));
		}
	}
	return(-1);
}

void arbol_comprueba(struct s_arbol *arbol)
{
	switch (arbol->tipo)
	{
		case tipo_nul: (*f_error)("Bad Tree",cursor);
		case tipo_valor:
		case tipo_variable:
		{
			if (arbol->hoja1!=NULL)
			{
				(*f_error)("Missing Operator",arbol->cursor);
				arbol_comprueba(arbol->hoja1);
			}
			if (arbol->hoja2!=NULL)
			{
				(*f_error)("Missing Operator",arbol->cursor);
				arbol_comprueba(arbol->hoja2);
			}
			break;
		}
		case tipo_operador:
		{
			if (arbol->hoja2==NULL) (*f_error)("Missing Second Operator",arbol->cursor);
			else arbol_comprueba(arbol->hoja2);
			switch (arbol->operador)
			{
				case '^':
				case '*':
				case '/':
				{
					if (arbol->hoja1==NULL) (*f_error)("Missing First Operator",arbol->cursor);
					else arbol_comprueba(arbol->hoja1);
					break;
				}
				case '+':
				case '-':
				{
					arbol_comprueba(arbol->hoja1);
					break;
				}
			}
			break;
		}
		case tipo_funcion:
		{
			if (arbol->funcion==NULL) (*f_error)("Unknow Function",arbol->cursor);
			if (arbol->hoja1!=NULL) (*f_error)("Missing Operator",arbol->cursor);
			if (arbol->hoja2==NULL) (*f_error)("Missing Argument",arbol->cursor);
			else arbol_comprueba(arbol->hoja2);
			break;
		}
	}
}

void arbol_destruye(struct s_arbol *arbol)
{
	if (arbol->hoja1!=NULL) arbol_destruye(arbol->hoja1);
	if (arbol->hoja2!=NULL) arbol_destruye(arbol->hoja2);
	free(arbol);
}


int prioridad_de(char c)
{
	switch(c)
	{
		case '^':return(1);
		case '*':return(2);
		case '/':return(2);
		case '+':return(4);
		case '-':return(4);
	}
	return(-1);
}

void *function_create(char *function_string)
{
	enum e_tipo tipo;
	double valor;
	char variable, operador;
	double (*funcion)(double x);
	struct s_arbol *raiz, *a;
	int cursor_old=0;

	prioridad_global=0;
	raiz = arbol_crea();
	parsea(function_string, &tipo, &valor, &variable, &operador, &funcion);
	while (tipo!=tipo_nul)
	{
		if ((tipo==tipo_operador)&&((operador=='(')||(operador==')')))
		{
			if (operador=='(') prioridad_global-=10;
			else prioridad_global+=10;
		}
		else
		{
			a=arbol_crea();
			a->tipo=tipo;
			a->valor=valor;
			a->variable=variable;
			a->operador=operador;
			if (tipo==tipo_operador) a->prioridad=prioridad_de(operador);
			else a->prioridad=0;
			a->prioridad+=prioridad_global;
			a->funcion=funcion;
			a->cursor=cursor_old;
			arbol_mete(raiz,a);
		}
		cursor_old=cursor;
		parsea(NULL, &tipo, &valor, &variable, &operador, &funcion);
	}
	return((void *)raiz);
}

void function_syntax_check(void *funcion, void (*n_error)(char *s, int cursor))
{
	f_error=n_error;
	arbol_comprueba((struct s_arbol *)funcion);
}

double function_calculate(double nx, void *funcion)
{
	x=nx;
	return(arbol_calcula((struct s_arbol *)funcion));
}

void function_destroy(void *funcion)
{
	arbol_destruye((struct s_arbol *)funcion);
}