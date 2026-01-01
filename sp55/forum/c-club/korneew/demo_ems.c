/*

Эта программа демонстрирует использование библиотеки функций свопинга
данных в Extended память на примере сохранения нижней половины экрана
в Extended памяти и, после нажатия клавши, восстановления, сохраненной
части, в верней части экрана.

*/
#include <stdio.h>
#include <conio.h>
#include "EMS_LIB.h"

int main(void){
	int USING = 2;
	char *Arrary = 0xB8000000, *Arrary_1 = 0xB8000780;
	long Byte = 2048;
	int Block_EXT = 0, retcod = 0;
	EMS_Handle Handle;

	if(!(retcod = EMS_Open())){
		Block_EXT = Get_Free_Size();
		printf("Доступно Extended памяти всего: %d К, наибольший блок: %d К, запрошено: %d K.\n\n",
			Total_EXT, Block_EXT, USING);
		if(Handle = EMS_Alloc(USING)){
			if(!(retcod = Send_To_Ext(Handle, Arrary_1, Byte))){
				printf("Нижняя часть экрана сохранена.\n");
				Block_EXT = Get_Free_Size();
				printf("Доступно Extended памяти всего: %d К, наибольший блок: %d К\n",
					Total_EXT, Block_EXT);
				printf("Strike any key for continue ...\n");
				getch();
				if(!(retcod = Send_To_Mem(Handle, Arrary, Byte))){
					printf("А теперь она сверху.\n");
				}
			}
		}
	}
	if(retcod = EMS_Free(Handle)) printf("Ошибка при освобождении памяти, код: %X", retcod);
	retcod = EMS_Close();
	Block_EXT = Get_Free_Size();
	printf("Доступно Extended памяти всего: %d К, наибольший блок: %d К\n",
		Total_EXT, Block_EXT);
	return 0;
}