#ifndef LIST_INCL
#define LIST_INCL

/**************************************************************************
 *                         Windows List Manager API                       *
 *                                                                        *
 *                              by Dave Fassett                           * 
 *                                                                        * 
 *                              Aries Graphics                            * 
 *                           7835 Quebrada Circle                         * 
 *                            Carlsbad, CA 92009                          *
 *                 (619) 436-5511 VOICE   (619) 436-0265 FAX              *
 *                                                                        *
 *                                                                        *
 *   This list manager lets you deal with large sets of data in Windows   *
 * protected mode, while incurring very little overhead. It is            *
 * designed to handle very large lists of data, but there is one          *
 * catch: each element must be the same size, or at least have a known    *
 * maximum size. I have been using it for some time, and with all kinds   *
 * of different list types (even for large Windows bitmaps, which had to  *
 * be broken into less-than-32K bands).                                   *
 *                                                                        *
 **************************************************************************/

typedef struct _LINK {
	struct _LINK FAR *Prev;
	struct _LINK FAR *Next;
	unsigned char fPresent;
} LINK;

#define MAX_64KBLOCKS	32		// max list size == 2 megs
								// you may want to modify this aspect of the
								// manager, such that the hBlocks array is
								// allocated dynamically, and so there
								// wouldn't need to be a size limit

typedef LINK FAR *LPLINK;

typedef struct _LISTSTRUCT {
	GLOBALHANDLE hThis;		// Handle to the memory used for this structure
	HANDLE hBlocks[MAX_64KBLOCKS];	// Array of allocated block handles
	int ItemSize;			// Size of the individual items
	int nSegs;				// Number of 64K segments in use
	long CurSegLen;			// Length of current 64K segment
	long ArrayLen;			// Size of the array/heap for the list
	long ListLen;			// Length of the list (# of items)
	LPLINK Cur;				// Current item
	LPLINK Head;			// Start of list
	LPLINK Tail;			// Last item of list
	LPLINK FreeList;		// List of free items available for reuse
	} LISTSTRUCT;

typedef LISTSTRUCT FAR *HLIST;

HLIST FAR PASCAL CreateList(int ItemSize);
HLIST FAR PASCAL DeleteList(HLIST);
long FAR PASCAL ResetList(HLIST );
long FAR PASCAL ListSize(HLIST );
void FAR PASCAL SetCurItem(HLIST, LPVOID);
LPSTR FAR PASCAL GetCurItem(HLIST );
LPSTR FAR PASCAL GetListNext(HLIST );
LPSTR FAR PASCAL GetListPrev(HLIST );
LPSTR FAR PASCAL AppendList(HLIST , LPVOID );
void FAR PASCAL ClearList(HLIST );
LPSTR FAR PASCAL DeleteListItem(HLIST, LPVOID );
LPSTR FAR PASCAL UnlinkListItem(HLIST, LPVOID );
LPSTR FAR PASCAL LastListItem(HLIST );
LPSTR FAR PASCAL InsertListAfter(HLIST h, LPVOID pAfter, LPVOID pItem);
LPSTR FAR PASCAL InsertListBefore(HLIST h, LPVOID pBefore, LPVOID pItem);
LPSTR FAR PASCAL GetNextFrom(HLIST h, LPVOID pCur);
LPSTR FAR PASCAL GetPrevFrom(HLIST h, LPVOID pCur);
LPSTR FAR PASCAL MoveToEnd(HLIST h, LPVOID pItem);
LPSTR FAR PASCAL MoveToStart(HLIST h, LPVOID pItem);
long FAR PASCAL GetItemIndex(HLIST p, LPVOID pItem);
LPSTR FAR PASCAL InsertItemAt(HLIST p, LPVOID pItem, long iPos);
LPSTR FAR PASCAL GetItemAt(HLIST P, long iPos);
HLIST FAR PASCAL DupList(HLIST );
int FAR PASCAL IsItemDeleted(HLIST p, LPVOID pItem);
long FAR PASCAL RelinkItem(HLIST p, LPVOID pItem);
LPSTR FAR PASCAL GetNextDeleted(HLIST p);

#define ListItemSize(list)		(((list)->ItemSize)-sizeof(LINK))

#endif
