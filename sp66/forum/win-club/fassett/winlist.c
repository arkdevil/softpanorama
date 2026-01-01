/**************************************************************************
 *                         Windows List Manager API                       *
 *                                                                        *
 *                              by Dave Fassett                           * 
 *                                                                        * 
 *                              Aries Graphics                            * 
 *                           7835 Quebrada Circle                         * 
 *                            Carlsbad, CA 92009                          *
 *                 (619) 436-5511 VOICE   (619) 436-0265 FAX              *
 **************************************************************************/

#include <windows.h>
#include <winmem.h>

#include "winlist.h"

#define SEGMENT_SIZE	65500L
#define IfPresent(item, dir)	( ((item) && (item)->fPresent) ? \
								(LPSTR)((item) + 1) : ((item) ? \
								GetList##dir(p) : NULL) )


static int NEAR ExpandList(HLIST p);

/*
 * CreateList()
 *
 * This is the function that is called to create the list, which is itself
 * an allocated object (not just a struct). The HLIST data type so named
 * so as to (sort of) hide from the programmer any knowledge of or concern
 * for the actual type of the list (LPxxx, WORD, etc).  It might be better
 * to actually make HLIST be a WORD handle, as in the Windows API.
 *
 * 'ItemSize' specifies the size in bytes of the list elements
 *
 * Returns: the new HLIST object
 */

HLIST FAR PASCAL CreateList(int ItemSize)
{
	GLOBALHANDLE hThis = GlobalAlloc(GHND, (long)sizeof(LISTSTRUCT));
	HLIST p;

	if (!hThis)  return NULL;
	p = (HLIST)GlobalLock(hThis);
	if (!p)  return NULL;
	p->ItemSize = sizeof(LINK) + ItemSize;
	p->hThis = hThis;
	p->Head = p->Tail = p->Cur = NULL;
	p->ArrayLen = 0;
	p->ListLen = 0;
	p->CurSegLen = 0;
	p->nSegs = 0;
	p->hBlocks[0] = NULL;

	return p;
}

/*
 * ValidList()
 *
 * Verifies that a given HLIST is valid (not NULL)
 *
 * Returns: TRUE if 'p' is valid, otherwise FALSE
 */

static int NEAR ValidList(HLIST p)
{
	if (p != NULL)
	 	return TRUE;
	else
		{
		/**** Handle this case in any way you see fit *****/
		OutputDebugString("Invalid LIST access - handle 0000\r\n");
		return FALSE;
		}
}

/*
 * ExpandList()
 *
 * Expands the size of the list. This is only called when 
 * 'p->FreeList == NULL' - that is, we've run out of free slots to put new
 * item into.
 *
 * Returns: TRUE if it successfully expanded the list, otherwise FALSE
 */

static int NEAR ExpandList(HLIST p)
{
	int by = p->ItemSize > 400 ? 1 : 10;	// allocate large items slowly
	LPSTR pMem = NULL;		// pointer to the current memory segment base
	WORD os = 0;			// offset (in items) into the current segment

	if (!ValidList(p))  return FALSE;

	 // About to cross segment bounds? (or are there no segments allocated?)
	if (!p->nSegs || (p->CurSegLen + by) * p->ItemSize > SEGMENT_SIZE)
		{								// Yes: allocate new segment
		if (p->nSegs >= MAX_64KBLOCKS-1)
			{
			OutputDebugString("LIST - too many segments\r\n");
			return FALSE;		// Too many segments allocated
			}
		p->hBlocks[p->nSegs] = GlobalAlloc(GMEM_MOVEABLE, (long)p->ItemSize * by);
		if (p->hBlocks[p->nSegs] == NULL)  goto Failed;
		pMem = GlobalLock(p->hBlocks[p->nSegs]);
		p->nSegs++;
		p->CurSegLen = by;
		os = 0;
		}
	else
		{
		int nSeg = p->nSegs-1;
		GlobalUnlock(p->hBlocks[nSeg]);
		p->hBlocks[nSeg] = GlobalReAlloc(p->hBlocks[nSeg],
			(long)p->ItemSize * (p->CurSegLen + by), GMEM_MOVEABLE);
		if (p->hBlocks[nSeg] == NULL)  goto Failed;
		pMem = GlobalLock(p->hBlocks[nSeg]);
		os = p->CurSegLen;
		p->CurSegLen += by;
		}

	if (pMem)
		{
		// Initialize these new items
		LPLINK pLink = NULL;
		p->FreeList = (LPLINK) (pMem + p->ItemSize * os);
		while (by--)
			{
			pLink = (LPLINK) (pMem + (p->ItemSize * os));
			os++;
			pLink->Prev = NULL;
			pLink->Next = (LPLINK) (pMem + (p->ItemSize * os));
			pLink->fPresent = FALSE;
			p->ArrayLen++;
			}
		pLink->Next = NULL;
		return TRUE;
		}
Failed:
	if (pMem)
		OutputDebugString("LIST - memory allocation failed (Alloc)\r\n");
	else
		OutputDebugString("LIST - memory allocation failed (Lock)\r\n");

	return FALSE;
}

/*
 * DeleteList()
 *
 * Deletes the specified list. First frees all the global memory blocks
 * that were allocated for this list, then frees the memory used for the
 * list itself (p->hThis).
 *
 * Returns: always NULL so you can say "hList = DeleteList(hList)"
 */

HLIST FAR PASCAL DeleteList(HLIST p)
{
	if (ValidList(p))
		{
		GLOBALHANDLE hThis = p->hThis;
		
		// Delete all the memory blocks used
		while (p->nSegs > 0)
			{
			p->nSegs--;
			if (p->hBlocks[p->nSegs])
				{
				GlobalUnlock(p->hBlocks[p->nSegs]);
				GlobalFree(p->hBlocks[p->nSegs]);
				}
			}
		
		GlobalUnlock(hThis);
		GlobalFree(hThis);
		}

	return NULL;
}

/*
 * ClearList()
 *
 * Clears the list of all it's data without getting rid of the list object
 * itself.
 *
 * Returns: void
 */

void FAR PASCAL ClearList(HLIST p)
{
	if (ValidList(p))
		{
		// Delete all the memory blocks used
		while (p->nSegs > 0)
			{
			p->nSegs--;
			if (p->hBlocks[p->nSegs])
				{
				GlobalUnlock(p->hBlocks[p->nSegs]);
				GlobalFree(p->hBlocks[p->nSegs]);
				}
			}

		p->CurSegLen = 0;
		p->Head = p->Tail = p->Cur = NULL;
		p->ListLen = p->ArrayLen = 0L;
		p->FreeList = NULL;
		}
}

/*
 * ResetList()
 *
 * This function prepares the list for enumerating. It's like calling
 * rewind() or lseek(fh,0,0). After calling this, you can use GetListNext()
 * to retrieve the list items in sequence. The list's state is set such that
 * the very next call to GetListNext() will return the FIRST list element.
 *
 * Returns: the size of the list
 */

long FAR PASCAL ResetList(HLIST p)
{
	if (!ValidList(p)) return FALSE;
	p->Cur = NULL;
	
	return p->ListLen;
}

/*
 * ListSize()
 *
 * Returns the size of the list in elements. This count does not include
 * any items that were unlinked with UnlinkListItem().
 */

long FAR PASCAL ListSize(HLIST p)
{
	if (ValidList(p))
		return p->ListLen;
	else
		return 0L;
}

/*
 * GetCurItem()
 *
 * Returns a pointer to the current element in the list. May be an unlinked
 * element.
 */

LPSTR FAR PASCAL GetCurItem(HLIST p)
{
	if (ValidList(p) && p->Cur)
		return (LPSTR)(p->Cur + 1);

	return (LPSTR)NULL;
}

/*
 * InsertListAfter()
 *
 * Allows you to insert an item after another item already in the list. If
 * 'pAfter' item is NULL, the item is simply appended to the list.
 * 
 * Returns: a pointer to the item as inserted in the list.
 */

LPSTR FAR PASCAL InsertListAfter(HLIST p, LPVOID pAfter, LPVOID pItem)
{
	if (ValidList(p) && pAfter)
		{
		LPSTR pDest;
		LPLINK pPrev = ((LPLINK)pAfter - 1);
		LPLINK pNext = pPrev->Next;
		LPLINK pNextFree;

		if (p->FreeList == NULL)
			{
			if (!ExpandList(p)) // Expand failed?
				return NULL;
			}
		
		pNextFree = p->FreeList->Next;
		pPrev->Next = p->Cur = p->FreeList;

		if (pNext)
			pNext->Prev = p->Cur;
		else
			p->Tail = p->Cur;

		p->Cur->Prev = pPrev;
		p->Cur->Next = pNext;
		p->Cur->fPresent = TRUE;
		
		p->FreeList = pNextFree;
		p->ListLen++;

		pDest = (LPSTR)(p->Cur + 1);
		lmemcpy(pDest, pItem, p->ItemSize-sizeof(LINK));

		return pDest;
		}
	else if (!pAfter)
		return AppendList(p, pItem);
	else
		return NULL;
}

/*
 * InsertListBefore()
 *
 * Inserts an item into a list before another item. If 'pBefore' is NULL,
 * the item is simply appended to the list.
 * 
 * Returns: a pointer to the item as inserted into the list.
 */

LPSTR FAR PASCAL InsertListBefore(HLIST p, LPVOID pBefore, LPVOID pItem)
{
	if (ValidList(p) && pBefore)
		{
		LPSTR pDest;
		LPLINK pNext = ((LPLINK)pBefore - 1);
		LPLINK pPrev = pNext->Prev;
		LPLINK pNextFree;

		if (p->FreeList == NULL)
			{
			if (!ExpandList(p))		// Expand failed?
				return NULL;
			}
		
		pNextFree = p->FreeList->Next;
		pNext->Prev = p->Cur = p->FreeList;

		if (pPrev)
			pPrev->Next = p->Cur;
		else
			p->Tail = p->Cur;

		p->Cur->Prev = pPrev;
		p->Cur->Next = pNext;
		p->Cur->fPresent = TRUE;
		
		p->FreeList = pNextFree;
		p->ListLen++;

		pDest = (LPSTR)(p->Cur + 1);
		lmemcpy(pDest, pItem, p->ItemSize-sizeof(LINK));

		return pDest;
		}
	else if (!pBefore)
		return AppendList(p, pItem);
	else
		return NULL;
}

/*
 * GetListNext()
 *
 * One of the core routines in this API.  Retrieves the next item in the 
 * list, when enumerating over the list.  Will skip any items that were 
 * unlinked. Use the sister function GetNextDeleted() to retrieve all the
 * items in the list, if every item that is added needs to be destroyed.
 *
 * Returns: the next item in the list.
 */

LPSTR FAR PASCAL GetListNext(HLIST p)
{
	if (ValidList(p))
		{
		if (p->Cur == NULL && p->Head)		 // Was list reset?
		 	{
		 	p->Cur = p->Head;
		 	return IfPresent(p->Cur, Next);
		 	}
		else if (p->Cur && p->Cur->Next)		// Do we have a next item?
			{
			p->Cur = p->Cur->Next;
		 	return IfPresent(p->Cur, Next);
			}
		}

	return (LPSTR)NULL;
}

/*
 * GetListPrev()
 *
 * Allows searching background through the list from the current position.
 * Will skip and unlinked items.
 *
 * Returns: the previous item in the list.
 */

LPSTR FAR PASCAL GetListPrev(HLIST p)
{
	if (ValidList(p) && p->Cur && p->Cur->Prev)
		{
		p->Cur = p->Cur->Prev;
		return IfPresent(p->Cur, Prev);
		}
	return (LPSTR)NULL;
}

/*
 * AppendList()
 *
 * Another core routine. This is almost always used to initially construct
 * the list. 
 *
 * Returns: a pointer to the 'pItem' as inserted into the list. Never the
 *          same as 'pItem'.
 */

LPSTR FAR PASCAL AppendList(HLIST p, LPVOID pItem)
{
	if (ValidList(p))
		{
		LPSTR pDest;
		LPLINK pCur = p->Cur;
		LPLINK pTail;
		LPLINK pNextFree;

		if (p->FreeList == NULL)
			{
			if (!ExpandList(p))		// Expand failed?
				return NULL;
			}

		pTail = p->Tail ? p->Tail : p->FreeList;
		pNextFree = p->FreeList->Next;

		p->Cur = pTail->Next = p->FreeList;
		p->Cur->Prev = p->Tail;
		p->Cur->Next = NULL;
		p->Cur->fPresent = TRUE;
		p->Tail = p->Cur;
		if (p->Cur->Prev == NULL)  p->Head = p->Cur;
		p->FreeList = pNextFree;
		p->ListLen++;
		pDest = (LPSTR)(p->Cur + 1);
		if (pItem)
			lmemcpy(pDest, pItem, p->ItemSize-sizeof(LINK));
		else
			lmemset(pDest, 0, p->ItemSize-sizeof(LINK));
		return pDest;
		}

	return NULL;
}

/*
 * SetCurItem()
 *
 * Sets the current item pointer to an arbitrary item. The programmer is
 * completely responsible for ensuring that 'pItem' points to an existing
 * item in the list 'p'.
 *
 * Returns: void
 */

void FAR PASCAL SetCurItem(HLIST p, LPVOID pItem)
{
	if (ValidList(p))
		{
	/*	long Index = (((HPSTR)pItem - (HPSTR)p->pMem) / (long)p->ItemSize);
		if (Index < 0 || Index > p->ListLen)
			{
		//	err("List Error - SetCurItem(%p, %lp) - "
		//			"item not in valid range for list", p, (LPSTR)pItem);
			return;
			}	*/

		p->Cur = ((LPLINK)pItem) - 1;
		}
}

/*
 * DeleteListItem()
 *
 * Removes an item from a list.  The programmer is responsible for ensuring
 * that 'Item' points to an existing item in list 'p'.
 *
 * Returns: the item after 'Item'
 */

LPSTR FAR PASCAL DeleteListItem(HLIST p, LPVOID Item)
{
	if (ValidList(p) && Item)
		{
		LPLINK pThisItem = ((LPLINK)Item) - 1;
		LINK ThisItem;
		LPLINK pPrev = pThisItem->Prev;
		LPLINK pNext = pThisItem->Next;

		ThisItem = *pThisItem;
		if (pPrev)
			pPrev->Next = ThisItem.Next;
		else
			p->Head = ThisItem.Next;		// we're deleting the first item

		if (pNext)
			pNext->Prev = ThisItem.Prev;
		else
			p->Tail = ThisItem.Prev;		// we're deleting the last item

		p->ListLen--;
		
		p->Cur = pNext;
		pThisItem->Next = p->FreeList;	// put this at the top of the
		p->FreeList = pThisItem;		// ...free list and stitch it in
		
		return (LPSTR)(pNext + 1);
		}
	else
		return NULL;
}

/*
 * UnlinkListItem()
 *
 * Removes the specified item from the list as far as most of the other
 * list functions are concerned. GetNextDeleted(), ClearList(), and 
 * DeleteList() still find items that have been unlinked, but most of the 
 * other functions, such as GetListNext() and GetListPrev(), skip items
 * that have been unlinked.  This is great when implementing unlimited undo
 * in an program, because you just need to unlink the item from the list, and
 * save a pointer to it in your undo stack, and when it comes time to undo
 * the deletion, just call RelinkItem() to add it back into the list.
 * 
 * Returns: the next item in the list.
 */

LPSTR FAR PASCAL UnlinkListItem(HLIST p, LPVOID Item)
{
	if (ValidList(p) && Item)
		{
		LPLINK pThisItem = ((LPLINK)Item) - 1;
		LPLINK pPrev = pThisItem->Prev;
		LPLINK pNext = pThisItem->Next;
		
		if (!pPrev)  p->Head = pThisItem;
		if (!pNext)  p->Tail = pThisItem;
		
		pThisItem->fPresent = FALSE;
		p->ListLen--;
		p->Cur = pNext;
		
		return pNext ? IfPresent(pNext, Prev) : NULL;
		}
	else
		return NULL;
}

/*
 * LastListItem()
 *
 * Returns a pointer to the last item in the list.
 */

LPSTR FAR PASCAL LastListItem(HLIST p)
{
	if (ValidList(p) && p->Tail)
		{
		p->Cur = p->Tail;
		return IfPresent(p->Cur, Prev);
		}
	else
		return NULL;
}

/*
 * GetNextFrom()
 *
 * Returns the item after 'pItem'. This function doens't use the current
 * list position, which is sometimes necessary if there are two enumerations
 * going on simultaneously.
 */

LPSTR FAR PASCAL GetNextFrom(HLIST p, LPVOID pItem)
{
	if (ValidList(p))
		{
		if (pItem)
			p->Cur = ((LPLINK)pItem) - 1;
		
		if (p->Cur == NULL && p->Head)		 // Was list reset?
		 	{
		 	p->Cur = p->Head;
		 	return IfPresent(p->Cur, Next);
		 	}
		else if (p->Cur && p->Cur->Next)		// Do we have a next item?
			{
			p->Cur = p->Cur->Next;
			return IfPresent(p->Cur, Next);
			}
		}

	return (LPSTR)NULL;
}

/*
 * GetPrevFrom()
 *
 * Returns the item before 'pItem'. This function doens't use the current
 * list position, which is sometimes necessary if there are two enumerations
 * going on simultaneously.
 */

LPSTR FAR PASCAL GetPrevFrom(HLIST p, LPVOID pItem)
{
	if (ValidList(p))
		{
		if (pItem)
			p->Cur = ((LPLINK)pItem) - 1;
		
		if (p->Cur && p->Cur->Prev)
			{
			p->Cur = p->Cur->Prev;
			return IfPresent(p->Cur, Prev);
			}
		}

	return (LPSTR)NULL;
}

/*
 * DupList()
 *
 * Duplicates the entire list.
 * 
 * Returns a new HLIST, which is an exact duplicate of the given list, except
 * it uses different memory.
 */

HLIST FAR PASCAL DupList(HLIST p)
{
	if (p)
		{
		long Len = ListSize(p);
		int ItemSize = p->ItemSize + sizeof(LINK);
		HLIST New = CreateList(p->ItemSize - sizeof(LINK));
		LPSTR pEnum;

		ResetList(p);
		while ((pEnum = GetListNext(p)))
			AppendList(New, pEnum);

		return New;
		}
	else
		return NULL;
}

/*
 * MoveToEnd()
 *
 * Moves the specified item 'pItem' to the end (tail) of the list.
 *
 * Returns: 'pItem'
 */

LPSTR FAR PASCAL MoveToEnd(HLIST p, LPVOID pItem)
{
	LPLINK pLink = ((LPLINK)pItem)-1;
	if (p->Tail != pLink)
		{
		DeleteListItem(p, pItem);
		// 'pLink' should now equal 'p->FreeList'
		p->Tail->Next = pLink;
		pLink->Prev = p->Tail;
		pLink->Next = NULL;
		p->Cur = p->Tail = pLink;
		p->ListLen++;
		p->FreeList = p->FreeList->Next;
		}
	return pItem;
}

/*
 * MoveToStart()
 *
 * Moves the specified item to the start (head) of the list.
 *
 * Returns: 'pItem'
 */

LPSTR FAR PASCAL MoveToStart(HLIST p, LPVOID pItem)
{
	LPLINK pLink = ((LPLINK)pItem)-1;
	if (p->Head != pLink)
		{
		DeleteListItem(p, pItem);
		// 'pLink' should now equal 'p->FreeList'
		p->Head->Prev = pLink;
		pLink->Prev = NULL;
		pLink->Next = p->Head;
		p->Cur = p->Head = pLink;
		p->ListLen++;
		p->FreeList = p->FreeList->Next;
		}
	return pItem;
}

/*
 * GetItemIndex()
 *
 * Returns the sequential index of the specified item in the list.
 */

long FAR PASCAL GetItemIndex(HLIST p, LPVOID pItem)
{
	LPLINK pLink = ((LPLINK)pItem)-1;
	long i = 0;

	while (pLink->Prev)
		{
		pLink = pLink->Prev;
		i++;
		}

	return i;
}

/*
 * InsertItemAt()
 *
 * Inserts an item a given list index position. If the index 'iPos' is out
 * range for the list, the item is appended to the list.
 *
 * Returns: a pointer to the item as inserted into the list.
 */

LPSTR FAR PASCAL InsertItemAt(HLIST p, LPVOID pItem, long iPos)
{
	LPLINK pLink = p->Head;
	long i = 0;

	for (; i < iPos && pLink; i++)
		pLink = pLink->Next;

	return InsertListAfter(p, pLink ? (LPVOID)(pLink+1) : NULL, pItem);
}

/*
 * GetItemAt()
 *
 * Returns a pointer to the item as index 'iPos'
 */

LPSTR FAR PASCAL GetItemAt(HLIST p, long iPos)
{
	LPLINK pLink = p->Head;
	long i = 0;

	for (; i < iPos && pLink; i++)
		pLink = pLink->Next;

	if (pLink && pLink->fPresent)
		{
		p->Cur = pLink;
		return (LPSTR)(p->Cur+1);
		}
	else
		return NULL;
}

/*
 * IsItemDeleted()
 *
 * Returns whether or not an item has been unlinked, and therefore 
 * 'invisible' to GetListNext(), etc.
 */

int FAR PASCAL IsItemDeleted(HLIST p, LPVOID pItem)
{
	if (ValidList(p) && pItem)
		{
		LPLINK pLink = ((LPLINK)pItem) - 1;
		return !pLink->fPresent;
		}
	return FALSE;
}

/*
 * RelinkItem()
 *
 * Stitches the given item back into the list 'p'.  The item 'pItem' is
 * assumed to have been unlinked with the UnlinkItem() function.
 *
 * Returns: the new list size (in items)
 */

long FAR PASCAL RelinkItem(HLIST p, LPVOID pItem)
{
	if (ValidList(p) && pItem)
		{
		LPLINK pLink = ((LPLINK)pItem) - 1;
		LPLINK pPrev = pLink->Prev;
		LPLINK pNext = pLink->Next;
		if (pPrev)		pPrev->Next = pLink;
		else			p->Head = pLink;
		if (pNext)		pNext->Prev = pLink;
		else			p->Tail = pLink;
		p->Cur = pLink;
		pLink->fPresent = TRUE;
		p->ListLen++;
		return p->ListLen;
		}
	else
		return 0L;
}

/*
 * GetNextDeleted
 *
 * Get the next list item, even if it's been unlinked
 *
 * Returns: the next list item
 */

LPSTR FAR PASCAL GetNextDeleted(HLIST p)
{
	if (ValidList(p))
		{
		if (p->Cur == NULL && p->Head)		 // Was list reset?
		 	{
		 	p->Cur = p->Head;
		 	return (LPSTR)(p->Cur + 1);
		 	}
		else if (p->Cur && p->Cur->Next)		// Do we have a next item?
			{
			p->Cur = p->Cur->Next;
		 	return (LPSTR)(p->Cur + 1);
			}
		}

	return (LPSTR)NULL;
}
