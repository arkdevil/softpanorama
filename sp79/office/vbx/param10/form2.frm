VERSION 2.00
Begin Form Form2 
   Caption         =   "Edit Lineup"
   ClientHeight    =   5820
   ClientLeft      =   3405
   ClientTop       =   2685
   ClientWidth     =   7365
   Height          =   6225
   Left            =   3345
   LinkTopic       =   "Form2"
   ScaleHeight     =   5820
   ScaleWidth      =   7365
   Top             =   2340
   Width           =   7485
   Begin CommandButton Command3 
      Caption         =   "&Update"
      Height          =   495
      Left            =   3060
      TabIndex        =   20
      Top             =   4080
      Width           =   1215
   End
   Begin CommandButton Command2 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   495
      Left            =   3060
      TabIndex        =   10
      Top             =   3420
      Width           =   1215
   End
   Begin CommandButton Command1 
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   495
      Left            =   3060
      TabIndex        =   9
      Top             =   2700
      Width           =   1215
   End
   Begin TextBox txtPlayer 
      Height          =   495
      Index           =   5
      Left            =   840
      TabIndex        =   5
      Text            =   "Text1"
      Top             =   3075
      Width           =   1215
   End
   Begin TextBox txtPlayer 
      Height          =   495
      Index           =   3
      Left            =   840
      TabIndex        =   3
      Text            =   "Text1"
      Top             =   1965
      Width           =   1215
   End
   Begin TextBox txtPlayer 
      Height          =   495
      Index           =   8
      Left            =   840
      TabIndex        =   8
      Text            =   "Text1"
      Top             =   4740
      Width           =   1215
   End
   Begin TextBox txtPlayer 
      Height          =   495
      Index           =   7
      Left            =   840
      TabIndex        =   7
      Text            =   "Text1"
      Top             =   4185
      Width           =   1215
   End
   Begin TextBox txtPlayer 
      Height          =   495
      Index           =   6
      Left            =   840
      TabIndex        =   6
      Text            =   "Text1"
      Top             =   3630
      Width           =   1215
   End
   Begin TextBox txtPlayer 
      Height          =   495
      Index           =   4
      Left            =   840
      TabIndex        =   4
      Text            =   "Text1"
      Top             =   2520
      Width           =   1215
   End
   Begin TextBox txtPlayer 
      Height          =   495
      Index           =   2
      Left            =   840
      TabIndex        =   2
      Text            =   "Text1"
      Top             =   1410
      Width           =   1215
   End
   Begin TextBox txtPlayer 
      Height          =   495
      Index           =   1
      Left            =   840
      TabIndex        =   1
      Text            =   "Text1"
      Top             =   840
      Width           =   1215
   End
   Begin TextBox txtPlayer 
      Height          =   495
      Index           =   0
      Left            =   840
      TabIndex        =   0
      Text            =   "Text1"
      Top             =   300
      Width           =   1215
   End
   Begin JmParamCtl Paramctl1 
      Left            =   2400
      Top             =   300
   End
   Begin Label Label1 
      Caption         =   "P"
      Height          =   255
      Left            =   240
      TabIndex        =   19
      Top             =   300
      Width           =   315
   End
   Begin Label Label2 
      Caption         =   "C"
      Height          =   255
      Left            =   240
      TabIndex        =   18
      Top             =   840
      Width           =   315
   End
   Begin Label Label3 
      Caption         =   "1B"
      Height          =   255
      Left            =   240
      TabIndex        =   17
      Top             =   1410
      Width           =   315
   End
   Begin Label Label4 
      Caption         =   "2B"
      Height          =   255
      Left            =   240
      TabIndex        =   16
      Top             =   1965
      Width           =   315
   End
   Begin Label Label5 
      Caption         =   "3B"
      Height          =   255
      Left            =   240
      TabIndex        =   15
      Top             =   2520
      Width           =   315
   End
   Begin Label Label6 
      Caption         =   "SS"
      Height          =   255
      Left            =   240
      TabIndex        =   14
      Top             =   3075
      Width           =   315
   End
   Begin Label Label7 
      Caption         =   "LF"
      Height          =   255
      Left            =   240
      TabIndex        =   13
      Top             =   3630
      Width           =   315
   End
   Begin Label Label8 
      Caption         =   "CF"
      Height          =   255
      Left            =   240
      TabIndex        =   12
      Top             =   4185
      Width           =   315
   End
   Begin Label Label9 
      Caption         =   "RF"
      Height          =   255
      Left            =   240
      TabIndex        =   11
      Top             =   4740
      Width           =   315
   End
End
Option Explicit
Declare Function CallForm Lib "PARAMCTL" (Ctl As Form, ByVal CallType As Integer, args() As String) As Long

Sub Command1_Click ()
    UpdateValues
    Unload Me
End Sub

Sub Command2_Click ()
    Unload Me
End Sub

Sub Command3_Click ()
    UpdateValues
End Sub

Sub Paramctl1_CallForm (CallType As Integer, ReturnValue As Long)
    Dim ii As Integer
    For ii = 1 To Paramctl1.ArgCount
        txtPlayer(ii - 1) = Paramctl1.Argument(ii)
    Next ii
End Sub

Sub UpdateValues ()
    ReDim args(0 To 8)  As String
    Dim ii As Integer
    For ii = LBound(args) To UBound(args)
        args(ii) = txtPlayer(ii)
    Next ii
    Dim rvalue As Long

    rvalue = CallForm(Form1, 1, args())

    ' The form that gets call can return a value to us
    ' so we use the return values.

    For ii = LBound(args) To UBound(args)
        txtPlayer(ii) = args(ii)
    Next ii
End Sub

