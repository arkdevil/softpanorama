* Used by DF.R,  definitions of algebra functions
df(sqr(a)) = .5 / sqr(a) * dfa
df(sin(a)) = cos(a) * dfa
df(cos(a)) = - sin(a) * dfa
df(tan(a)) = 1 / cos(a)^2 * dfa
df(exp(a)) = exp(a) * dfa
df(ln(a)) = dfa / a
*
a+b = b+a
a*b = b*a
a*1 = a
1+1 = 2
a+0 = a
a+(b+c) = (a+b)+c
a*(b+c) = a*b+a*c
