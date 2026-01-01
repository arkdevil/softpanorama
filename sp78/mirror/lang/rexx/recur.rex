From: sandy@mantissa.com
Newsgroups: comp.lang.rexx
Subject: Re: lost in recursion
Date: 12 Oct 1995 00:47:31 GMT

In <45h93q$i4o@sun.sirius.com>, rgomez@sirius.com writes:
>I'm still learning REXX and came upon a section that has me really puzzled,
>a recursive function.  Here's the program
>
>say 'Enter a number:'
>pull number || '! is' Factorial(number)
>exit
>
>factorial:  procedure
> num = arg(1)
> if num = 1 then
>   return num
> return factorial(num - 1) * num
>
>I know how to calculate a factorial, but this program doesn't show me how.
>The reason I'm puzzled is that while the first loop of this gives me the
>answer (say an entry of 5) gives me 20, the arg(1) for the next loop should
>be 4.

Perhaps this clarification will help...
This isn't a loop.
It's all done on a stack; so, all intermediate values are stored on the
stack.

For all practical purposes it looks more like this with your example of
Factorial(5):

   Factorial(5) = Factorial(4) * 5  = 120
      Factorial(4) = Factorial(3) * 4 = 24
         Factorial(3) = Factorial(2) * 3 = 6
            Factorial(2) = Factorial(1) * 2 = 2
               Factorial(1) = 1


Also, I would imagine that your test program should be something like:
say 'Enter a number:'
pull number
say number || '! is' Factorial(number)
exit

>While I see this using Interactive Trace in PMREXX, where does the
>loop store the value of 20?  It seems that (num-1) is fine, but if you
>also using num to multiply,  shouldn't that be 4 also?  So the next answer
>should be 12, which is wrong.
>I wrote this program from a book and know  it works, but I just don't know
>how 20 is stored and the next value of 60, etc....

>Also, if you break out of the loop with return num, should
>Factorial(number) = 1?  HELP   :(

Yes. Factorial(1) = 1


