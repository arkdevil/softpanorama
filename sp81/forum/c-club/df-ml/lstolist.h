/* Copyright Marty Leisner (leisner@sdsp.mc.xerox.com), 1994 */

#ifndef _LIST_OF_LISTS
#define _LIST_OF_LISTS


typedef struct {
	void far *first_dpb;
	void far *first_sft;
	void far *clock_header;
	void far *con_header;
	short max_bytes_per_header;
	void far *disk_buffer_info;
	void far *cds_list;
	void far *fcb_tables;
	short protected_fcbs;
	unsigned char num_block;
	unsigned char available_block_dev;
	unsigned char nul_header[18];
	unsigned char num_joined_drives;
	short ibm_dos_ptr;
	void far *setver_list;
	short dos_high_fix;
	short most_recent_psp;
	char space[8];
} LIST_OF_LISTS;
		

LIST_OF_LISTS far *dos_list_of_lists(void);
#endif

