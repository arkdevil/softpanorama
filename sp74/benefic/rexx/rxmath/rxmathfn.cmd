/*------------------------------------------------------------------
 *
 *      (C) Copyright IBM Corp. 1992
 *
 *      rxmathfn.cmd :
 *------------------------------------------------------------------
 * 07-29-92 originally by Patrick J. Mueller
 * 08-12-92 changed by Patrick J. Mueller "nan" and "infinity" added
 *------------------------------------------------------------------*/

parse source os .

rc = RxFuncAdd("MathLoadFuncs","RxMathFn","MathLoadFuncs")
rc = MathLoadFuncs()

say "pi =" pi()
say "e  =" e()
say

nums = "1 0.9 0.8 1.1 1e1000 infinity -infinity nan -nan"

do numInd = 1 to words(nums)
   i = word(nums,numInd)

   say "acos " || "("i") =" acos(  i )
   say "asin " || "("i") =" asin(  i )
   say "atan " || "("i") =" atan(  i )
   say "cos  " || "("i") =" cos(   i )
   say "exp  " || "("i") =" exp(   i )
   say "log10" || "("i") =" log10( i )
   say "sin  " || "("i") =" sin(   i )
   say "sqrt " || "("i") =" sqrt(  i )
   say "tan  " || "("i") =" tan(   i )

   if (os = "CMS") then
      do
      say "ytox("i","i") =" ytox(i,i)
      say "ln   " || "("i") =" ln(    i )
      end

   else
      do
      say "ceil " || "("i") =" ceil(  i )
      say "floor" || "("i") =" floor( i )
      say "cosh " || "("i") =" cosh(  i )
      say "sinh " || "("i") =" sinh(  i )
      say "tanh " || "("i") =" tanh(  i )
      say "pow("i","i") =" pow(i,i)
      say "log  " || "("i") =" log(   i )
      end

   say
end

exit
