; New font header		;BFN,LFN,SFN
BFN_SignatureTEXT	textequ	<VPK BFN >
BFN_Signature	equ	0
BFN_FontType	equ	8
BFN_CharW	equ	9
BFN_LoadB	equ	0Ah
BFN_CharH	equ	0Bh
BFN_StartC	equ	0Ch
BFN_EndC	equ	0Dh
BFN_CharN	equ	0Eh
BFN_Reserved	equ	0Fh
BFN_HDR_Size	equ	10h
;--------------------------------------------------------
@BFN_Header	MACRO	CharH,Cstart,Cend,Block
LOCAL	$$$Block,$$$Cstart,$$$Cend
	db	'VPK BFN '	;;signature
	db	0			;;font type
	db	8			;;char width
	IFNB	<Block>
		$$$Block	= Block
	ELSE
		$$$Block	= 0
	ENDIf
	db	$$$Block		;;load block #
	db	CharH			;;char height
	IFNB	<Cstart>
		$$$Cstart	= Cstart
	ELSE
		$$$Cstart	= 0
	ENDIf
	db	$$$Cstart		;;start char code
	IFNB	<Cend>
		$$$Cend	= Cend
	ELSE
		$$$Cend	= 0FFh
	ENDIf
	db	$$$Cend			;;end char code
	db	$$$Cend-$$$Cstart	;;# chars - 1
	db	0			;;reserved byte
ENDM
