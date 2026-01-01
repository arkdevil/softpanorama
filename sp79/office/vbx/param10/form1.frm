VERSION 2.00
Begin Form Form1 
   Caption         =   "Line Up"
   ClientHeight    =   3705
   ClientLeft      =   2310
   ClientTop       =   2175
   ClientWidth     =   4755
   Height          =   4110
   Left            =   2250
   LinkTopic       =   "Form1"
   ScaleHeight     =   3705
   ScaleWidth      =   4755
   Top             =   1830
   Width           =   4875
   Begin JmParamCtl Paramctl1 
      Left            =   3060
      Top             =   600
   End
   Begin CommandButton Command1 
      Caption         =   "&Edit"
      Height          =   495
      Left            =   2580
      TabIndex        =   18
      Top             =   2640
      Width           =   1215
   End
   Begin Label Label9 
      Caption         =   "RF"
      Height          =   255
      Left            =   120
      TabIndex        =   17
      Top             =   2880
      Width           =   315
   End
   Begin Label Label8 
      Caption         =   "CF"
      Height          =   255
      Left            =   120
      TabIndex        =   16
      Top             =   2565
      Width           =   315
   End
   Begin Label Label7 
      Caption         =   "LF"
      Height          =   255
      Left            =   120
      TabIndex        =   15
      Top             =   2250
      Width           =   315
   End
   Begin Label Label6 
      Caption         =   "SS"
      Height          =   255
      Left            =   120
      TabIndex        =   14
      Top             =   1935
      Width           =   315
   End
   Begin Label Label5 
      Caption         =   "3B"
      Height          =   255
      Left            =   120
      TabIndex        =   13
      Top             =   1620
      Width           =   315
   End
   Begin Label Label4 
      Caption         =   "2B"
      Height          =   255
      Left            =   120
      TabIndex        =   12
      Top             =   1305
      Width           =   315
   End
   Begin Label Label3 
      Caption         =   "1B"
      Height          =   255
      Left            =   120
      TabIndex        =   11
      Top             =   990
      Width           =   315
   End
   Begin Label Label2 
      Caption         =   "C"
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   675
      Width           =   315
   End
   Begin Label Label1 
      Caption         =   "P"
      Height          =   255
      Left            =   120
      TabIndex        =   9
      Top             =   360
      Width           =   315
   End
   Begin Label lblPlayer 
      Caption         =   "Beecham"
      Height          =   255
      Index           =   8
      Left            =   600
      TabIndex        =   8
      Top             =   2880
      Width           =   1215
   End
   Begin Label lblPlayer 
      Caption         =   "Klemperer"
      Height          =   255
      Index           =   7
      Left            =   600
      TabIndex        =   7
      Top             =   2565
      Width           =   1215
   End
   Begin Label lblPlayer 
      Caption         =   "Monteux"
      Height          =   255
      Index           =   6
      Left            =   600
      TabIndex        =   6
      Top             =   2250
      Width           =   1215
   End
   Begin Label lblPlayer 
      Caption         =   "Munch"
      Height          =   255
      Index           =   5
      Left            =   600
      TabIndex        =   5
      Top             =   1935
      Width           =   1215
   End
   Begin Label lblPlayer 
      Caption         =   "Riener"
      Height          =   255
      Index           =   4
      Left            =   600
      TabIndex        =   4
      Top             =   1620
      Width           =   1215
   End
   Begin Label lblPlayer 
      Caption         =   "Ormandy"
      Height          =   255
      Index           =   3
      Left            =   600
      TabIndex        =   3
      Top             =   1320
      Width           =   1215
   End
   Begin Label lblPlayer 
      Caption         =   "Szell"
      Height          =   255
      Index           =   2
      Left            =   600
      TabIndex        =   2
      Top             =   960
      Width           =   1215
   End
   Begin Label lblPlayer 
      Caption         =   "Nikisch"
      Height          =   255
      Index           =   1
      Left            =   600
      TabIndex        =   1
      Top             =   675
      Width           =   1215
   End
   Begin Label lblPlayer 
      Caption         =   "Von Bulow"
      Height          =   255
      Index           =   0
      Left            =   600
      TabIndex        =   0
      Top             =   360
      Width           =   1215
   End
End
Option Explicit

Sub Command1_Click ()
    ReDim args(0 To 8) As String
    Dim ii As Integer
    For ii = LBound(args) To UBound(args)
        args(ii) = lblPlayer(ii)
    Next ii

    Dim rvalue As Long
    rvalue = CallForm(Form2, 0, args())
    Form2.Show 1
End Sub

Sub Paramctl1_CallForm (CallType As Integer, ReturnValue As Long)
    If CallType <> 1 Then
        ' In this example 1 is the only call type.  You
        ' can use the CallType parameter to specify different
        ' functions to be performed in this event.
        Exit Sub
    End If

    Dim ii As Integer
    For ii = 1 To Paramctl1.ArgCount
        ' Don't let us get stuck with a black.
        If Trim$(Paramctl1.Argument(ii)) <> "" Then
            lblPlayer(ii - 1) = Paramctl1.Argument(ii)
        Else
            ' By updating the value of Argument () then
            ' new value is returned to the caller.  In
            ' this example the call gets told that the
            ' value that get passed is no good and a
            ' valid value is returned.
            Paramctl1.Argument(ii) = lblPlayer(ii - 1)
        End If
    Next ii
End Sub

