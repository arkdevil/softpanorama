	 **************************************************************
         *******   MATHEMATICAL FUNCTIONS UTILITY IN C  (v 1.1)  ******
	 **************************************************************

	This code in C is a simple Parser and Evaluator(rather a Compilator)
of Mathematical Functions. I have compiled it in Turbo C and djgpp(gcc).

	The only needed routines you need to implement the functions parser
in your code are defined in funcion.h (Watch Out! FUNCION and not FUNCTION, Sorry)

	It is very easy to understand how they work. Nevertheless, you can
find an example program in testfunc.c. It is compiled with Turbo C in
testtc.exe, and with Djgpp int testdj.exe.

	If they doesn't work you can recompile it taking care with the
directories, and the Options in the Turbo C. For the turbodj.exe, if you
haven't a 387 coprocessor, you will have to set the environment variables
properly (consult djgpp's documentation).

        In this version (v 1.1) I have debug two problems:
                1. sinh, cosh, tanh couldn't be parsered in version 1.0
                2. The priority of operators +,-,*,/ was wrong in version 1.0
        This problems were found and solved by
                Thomas A. Early. e-mail: temprano@netheaven.com
        Thanks, Thomas...

	I'd like to know if this software is or not useful. Tell me your
results. Be nice, ok?.

	This software is absolutely free. Make good aplicattions with it!
Make Internet a freeware net!

	********************************
	** Juan I. Perez Sacristan    **
	** e-mail: jips@sol.unizar.es **
	** Spain.   Zaragoza          **
	********************************
