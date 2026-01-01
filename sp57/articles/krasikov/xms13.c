#include <xms.h>
#include <string.h>

const char * XMSerrorMSG(unsigned char Error)
{
    char * s;
    switch (Error) {
	case 0x00: s="successful"; break;
	case 0x80: s="function not implemented"; break;
	case 0x81: s="VDISK was detected"; break;
	case 0x82: s="an A20 error occurred"; break;
	case 0x8E: s="a general driver error"; break;
	case 0x8F: s="unrecoverable driver error"; break;
	case 0x90: s="HMA does not exist"; break;
	case 0x91: s="HMA is already in use"; break;
	case 0x92: s="DX is less then the /HMAMIN= parameter"; break;
	case 0x93: s="HMA is not allocated"; break;
	case 0x94: s="A20 line still enabled"; break;
	case 0xA0: s="all extended memory is allocated"; break;
	case 0xA1: s="all available extended memory handles are allocated"; break;
	case 0xA2: s="invalid handle"; break;
	case 0xA3: s="source handle is invalid"; break;
	case 0xA4: s="source offset is invalid"; break;
	case 0xA5: s="destination handle is invalid"; break;
	case 0xA6: s="destination offset is invalid"; break;
	case 0xA7: s="length is invalid"; break;
	case 0xA8: s="move has an invalid overlap"; break;
	case 0xA9: s="parity error occured"; break;
	case 0xAA: s="block is not locked"; break;
	case 0xAB: s="block is locked"; break;
	case 0xAC: s="block lock count overflowed"; break;
	case 0xAD: s="lock failed"; break;
	case 0xB0: s="only a smaller UMB is available"; break;
	case 0xB1: s="no UMB''s are available"; break;
	case 0xB2: s="UMB segment number is invalid"; break;
	default:  s="unknown error";
    }
    return s;
}

