typedef long EMS_Handle;
extern  int Total_EXT;
extern  int Block_Lock_Count;
extern  int Num_Free_Hand_Left;
extern  int Num_Free_Hand_Left;
extern  int Internal_Rever;
extern  int HMA_Exist;
extern  long Addres_Line;
extern  int Block_Size;

extern struct _EMS_STRUCT {
					long Numb_Byt;
					int  Sour_Handle;
					long Offs_Sour_Block;
					int  Dest_Handle;
					long Offs_Dest_Block;
					}
EMM_Struct;

extern int EMS_Open(void);
extern int EMS_Close(void);
extern int Send_To_Ext(EMS_Handle Handle, char *Arrary,
									 unsigned long Byte);
extern int Send_To_Mem(EMS_Handle Handle, char *Arrary,
									 unsigned long Byte);
extern long EMS_Alloc(int Kbyte);
extern int EMS_Realloc(EMS_Handle Handle, unsigned int Kbyte);
extern int EMS_Free(EMS_Handle Handle);
extern int EMS_Lock(EMS_Handle Handle);
extern int EMS_Unlock(EMS_Handle Handle);
extern int Get_Free_Size(void);
extern int Get_XMS_Ver(void);
extern int Check_XMS(void);
extern int Check_Dos(void);
extern int Enable_A20(void);
extern int Get_Handle_Info(EMS_Handle Handle);
