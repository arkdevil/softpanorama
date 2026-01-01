' Parameter Control Definition File
'
'	Copyright (c) 1995 By VisualWare, Inc.
'
'	VisualWare, Inc.
'	1675 East Main St, Suite 218
'	Kent OH 44240
'
'
'	(216) 258-9012
'
'	visualware@interramp.com
'
'
'	CallForm
'
'	Invokes a Parameter Control on a Form
'
'	Frm:  The form you want to call.
'	CallType:	Integer value you want to pass to the control.  This is not
'			interpreted in any way.
'
'	Args:		Array of string arguments.
'
'
Declare Function CallForm Lib "PARAMCTL" (Frm As Form, ByVal CallType As Integer, Args() As String) As Long
