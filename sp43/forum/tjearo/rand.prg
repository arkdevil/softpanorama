* pseudo-random number generator for dbase
* adapted from the FORTRAN version in 
* "Software Manual for the Elementary Functions"
* by W.J. Cody, Jr., and William Waite.
*
public r_iy
public r_rand

* if r_iy has not yet been assigned, it's still a logical var
if type('r_iy') = 'L'
    r_iy = 100001
endif
r_iy = r_iy * 125
r_iy = r_iy - int(r_iy/2796203) * 2796203
r_rand = r_iy/2796203.0
Return(R_Rand)
