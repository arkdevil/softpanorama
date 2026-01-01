void MarkMen(int PrMen,char *MenStr){
 if((PrMen==1)&&(MenStr[0]!='√')){
   *MenStr='√';
 }else{
   *MenStr=' ';
 }
}