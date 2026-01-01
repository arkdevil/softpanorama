	.model tiny
	.code

	in  al,97
	and al,0fch
	out 97,al

	retf

	end
