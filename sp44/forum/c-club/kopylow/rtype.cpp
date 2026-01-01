#include <string.h>
#include "rtype.h"
#include <stdio.h>
main(){

	for(int i=2;i<16;i++,i++){
		for(int j=0; j<32;j++){
			printf(" %c",tolower(i*16+j));
		}
		printf("\n");
	}
	printf("\n");
	for(i=2;i<16;i++,i++){
		for(int j=0; j<32;j++){
			printf(" %c",toupper(i*16+j));
		}
		printf("\n");
	}
	printf("\n");
	printf("%s\n",         "qwerpouadsflkjhzcxmnbQWERPOUIASDFLKJHZXCVMNB");
	printf("%s\n",  strlwr("qwerpouadsflkjhzcxmnbQWERPOUIASDFLKJHZXCVMNB"));
	printf("%s\n\n",strupr("qwerpouadsflkjhzcxmnbQWERPOUIASDFLKJHZXCVMNB"));
	printf("%s\n",         "йцукъхзшфваэджясчмюбьЙЦУКЪХЗЩФЫВАЭЖДЛЯЧСМЮБЬ");
	printf("%s\n",  strlwr("йцукъхзшфваэджясчмюбьЙЦУКЪХЗЩФЫВАЭЖДЛЯЧСМЮБЬ"));
	printf("%s",    strupr("йцукъхзшфваэджясчмюбьЙЦУКЪХЗЩФЫВАЭЖДЛЯЧСМЮБЬ"));
}