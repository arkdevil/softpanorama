int CharDown(char ChIn){
  if((ChIn>='А')&&(ChIn<='П'))
	ChIn+=('а' - 'А');
    if((ChIn>='Р')&&(ChIn<='Я'))
	  ChIn+=('р' - 'Р');
	if(ChIn=='Ё')
	     ChIn+=('ё' - 'Ё');
	    if((ChIn>='A')&&(ChIn<='Z'))
		  ChIn+=('a' - 'A');
 return (ChIn);
}
int CharUp(char ChIn){
  if((ChIn>='а')&&(ChIn<='п'))
	ChIn-=('а' - 'А');
    if((ChIn>='р')&&(ChIn<='я'))
	  ChIn-=('р' - 'Р');
	if(ChIn=='ё')
	     ChIn-=('ё' - 'Ё');
	    if((ChIn>='a')&&(ChIn<='z'))
		  ChIn-=('a' - 'A');
 return (ChIn);
}