VERSION 2.00
Begin Form StakMan 
   BackColor       =   &H00C0C0C0&
   Caption         =   "StakMan"
   ClientHeight    =   6195
   ClientLeft      =   810
   ClientTop       =   795
   ClientWidth     =   7425
   Height          =   6600
   Icon            =   STAKMAN.FRX:0000
   Left            =   750
   LinkTopic       =   "Form1"
   ScaleHeight     =   6195
   ScaleWidth      =   7425
   Top             =   450
   Width           =   7545
   Begin VBSTAK VBStak 
      Debug           =   0   'False
      Host            =   "haddock2"
      HostAddress     =   ""
      InputLen        =   0
      Left            =   3420
      LocalAddress    =   ""
      LocalPort       =   0
      Options         =   0
      Protocol        =   0
      ProtocolName    =   "tcp"
      RemotePort      =   0
      ServiceName     =   "ftp"
      Top             =   1650
   End
   Begin VBSTAK DataStak 
      Debug           =   0   'False
      Host            =   "none"
      HostAddress     =   "0.0.0.0"
      InputLen        =   0
      Left            =   2850
      LocalAddress    =   ""
      LocalPort       =   16000
      Options         =   0
      Protocol        =   0
      ProtocolName    =   "tcp"
      RemotePort      =   0
      ServiceName     =   "ftp-data"
      Top             =   1620
   End
   Begin Frame Frame3 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Status"
      FontBold        =   -1  'True
      FontItalic      =   -1  'True
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   1155
      Left            =   4170
      TabIndex        =   0
      Top             =   0
      Width           =   3225
      Begin CommandButton CloseFormButton 
         Caption         =   "Close"
         Height          =   315
         Left            =   2400
         TabIndex        =   8
         Top             =   150
         Width           =   795
      End
      Begin CheckBox AutoCloseCheckBox 
         BackColor       =   &H00C0C0C0&
         Caption         =   "AutoClose"
         Height          =   195
         Left            =   1860
         TabIndex        =   9
         Top             =   840
         Value           =   1  'Checked
         Width           =   1245
      End
      Begin CheckBox DebugMode 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Debug"
         Height          =   285
         Left            =   1860
         TabIndex        =   1
         Top             =   510
         Width           =   885
      End
      Begin TextBox ErrorBox 
         BackColor       =   &H00FFFFFF&
         Height          =   285
         Left            =   750
         TabIndex        =   2
         Top             =   840
         Width           =   660
      End
      Begin TextBox SocketBox 
         BackColor       =   &H00FFFFFF&
         Height          =   285
         Left            =   750
         TabIndex        =   3
         Top             =   240
         Width           =   405
      End
      Begin TextBox StatusBox 
         BackColor       =   &H00FFFFFF&
         Height          =   285
         Left            =   750
         TabIndex        =   4
         Top             =   540
         Width           =   405
      End
      Begin Label Label3 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Error"
         Height          =   225
         Index           =   0
         Left            =   180
         TabIndex        =   5
         Top             =   840
         Width           =   615
      End
      Begin Label Label3 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Socket"
         Height          =   225
         Index           =   1
         Left            =   60
         TabIndex        =   6
         Top             =   270
         Width           =   615
      End
      Begin Label Label4 
         BackColor       =   &H00C0C0C0&
         Caption         =   "State"
         Height          =   225
         Index           =   0
         Left            =   60
         TabIndex        =   7
         Top             =   540
         Width           =   585
      End
   End
   Begin Frame Frame2 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Host"
      FontBold        =   -1  'True
      FontItalic      =   -1  'True
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   2115
      Left            =   30
      TabIndex        =   17
      Top             =   0
      Width           =   4155
      Begin CommandButton MessageButton 
         Caption         =   "Connect"
         Height          =   315
         Left            =   2910
         TabIndex        =   11
         Top             =   1020
         Width           =   1095
      End
      Begin CommandButton ServiceButton 
         Caption         =   "GetService"
         Height          =   315
         Left            =   2910
         TabIndex        =   12
         Top             =   120
         Width           =   1095
      End
      Begin CommandButton GetHostButton 
         Caption         =   "Get Host"
         Height          =   315
         Left            =   2910
         TabIndex        =   32
         Top             =   720
         Width           =   1095
      End
      Begin CommandButton ProtocolButton 
         Caption         =   "GetProtocol"
         Height          =   315
         Left            =   2910
         TabIndex        =   31
         Top             =   420
         Width           =   1095
      End
      Begin TextBox RemotePortBox 
         BackColor       =   &H00FFFFFF&
         Height          =   315
         Left            =   1920
         TabIndex        =   29
         Top             =   330
         Width           =   555
      End
      Begin TextBox ProtocolBox 
         BackColor       =   &H00FFFFFF&
         Height          =   315
         Left            =   1920
         TabIndex        =   28
         Top             =   660
         Width           =   555
      End
      Begin TextBox ServiceNameBox 
         BackColor       =   &H00FFFFFF&
         Height          =   315
         Left            =   840
         TabIndex        =   21
         Top             =   330
         Width           =   1005
      End
      Begin TextBox ProtocolNameBox 
         BackColor       =   &H00FFFFFF&
         Height          =   315
         Left            =   840
         TabIndex        =   20
         Top             =   660
         Width           =   1005
      End
      Begin TextBox HostNameBox 
         BackColor       =   &H00FFFFFF&
         Height          =   315
         Left            =   840
         TabIndex        =   19
         Top             =   1050
         Width           =   1995
      End
      Begin TextBox HostAddressBox 
         BackColor       =   &H00FFFFFF&
         Height          =   315
         Left            =   840
         TabIndex        =   18
         Top             =   1410
         Width           =   1305
      End
      Begin Label Label2 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Name"
         Height          =   225
         Index           =   4
         Left            =   840
         TabIndex        =   46
         Top             =   120
         Width           =   525
      End
      Begin Label Label2 
         BackColor       =   &H00C0C0C0&
         Caption         =   "#"
         Height          =   225
         Index           =   3
         Left            =   1950
         TabIndex        =   47
         Top             =   120
         Width           =   525
      End
      Begin Label Label1 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Name"
         Height          =   225
         Index           =   0
         Left            =   90
         TabIndex        =   27
         Top             =   1110
         Width           =   645
      End
      Begin Label Label2 
         BackColor       =   &H00C0C0C0&
         Caption         =   "IP"
         Height          =   225
         Index           =   0
         Left            =   90
         TabIndex        =   26
         Top             =   1440
         Width           =   525
      End
      Begin Label Label1 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Service"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   24
         Top             =   330
         Width           =   705
      End
      Begin Label Label 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Protocol"
         Height          =   225
         Index           =   4
         Left            =   120
         TabIndex        =   23
         Top             =   690
         Width           =   825
      End
   End
   Begin Frame Frame1 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Data "
      FontBold        =   -1  'True
      FontItalic      =   -1  'True
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   1005
      Left            =   5730
      TabIndex        =   13
      Top             =   1110
      Width           =   1665
      Begin TextBox LocalDataPort 
         BackColor       =   &H00FFFFFF&
         Height          =   285
         Left            =   810
         TabIndex        =   16
         Top             =   630
         Width           =   765
      End
      Begin CommandButton ConnectDataButton 
         Caption         =   "Open"
         Height          =   315
         Left            =   870
         TabIndex        =   14
         Top             =   120
         Width           =   765
      End
      Begin Label Label2 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Port #"
         Height          =   225
         Index           =   2
         Left            =   60
         TabIndex        =   39
         Top             =   660
         Width           =   765
      End
   End
   Begin Frame Frame4 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Command"
      FontBold        =   -1  'True
      FontItalic      =   -1  'True
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   1005
      Left            =   4170
      TabIndex        =   33
      Top             =   1110
      Width           =   1575
      Begin TextBox LocalAddressBox 
         BackColor       =   &H00FFFFFF&
         Height          =   315
         Left            =   330
         TabIndex        =   35
         Top             =   270
         Width           =   1185
      End
      Begin TextBox LocalPort 
         BackColor       =   &H00FFFFFF&
         Height          =   315
         Left            =   750
         TabIndex        =   34
         Top             =   600
         Width           =   765
      End
      Begin Label Label2 
         BackColor       =   &H00C0C0C0&
         Caption         =   "IP"
         Height          =   225
         Index           =   1
         Left            =   60
         TabIndex        =   37
         Top             =   300
         Width           =   405
      End
      Begin Label Label3 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Port #"
         Height          =   225
         Index           =   2
         Left            =   30
         TabIndex        =   36
         Top             =   660
         Width           =   585
      End
   End
   Begin Frame Frame5 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Send"
      FontBold        =   -1  'True
      FontItalic      =   -1  'True
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   1995
      Left            =   30
      TabIndex        =   40
      Top             =   2100
      Width           =   5175
      Begin CommandButton SendDataButton 
         Caption         =   "Send Data"
         Height          =   315
         Left            =   3870
         TabIndex        =   10
         Top             =   210
         Width           =   1155
      End
      Begin TextBox OutputBuffer 
         BackColor       =   &H00FFFFFF&
         Height          =   1365
         Left            =   30
         MultiLine       =   -1  'True
         ScrollBars      =   3  'Both
         TabIndex        =   44
         Top             =   570
         Width           =   5085
      End
      Begin CheckBox LineModeCheck 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Line Mode"
         Height          =   195
         Left            =   150
         TabIndex        =   43
         Top             =   300
         Width           =   1215
      End
      Begin CommandButton ClearSend 
         Caption         =   "Clear"
         Height          =   315
         Left            =   1620
         TabIndex        =   42
         Top             =   210
         Width           =   705
      End
      Begin CommandButton SendButton 
         Caption         =   "Send Command"
         Height          =   315
         Left            =   2400
         TabIndex        =   41
         Top             =   210
         Width           =   1425
      End
   End
   Begin Frame Frame6 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Events"
      FontBold        =   -1  'True
      FontItalic      =   -1  'True
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   1995
      Left            =   5190
      TabIndex        =   15
      Top             =   2100
      Width           =   2205
      Begin TextBox EventBox 
         BackColor       =   &H00FFFFFF&
         Height          =   1365
         Left            =   30
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   22
         Top             =   570
         Width           =   2055
      End
      Begin CommandButton ClearButton 
         Caption         =   "Clear"
         Height          =   285
         Left            =   1320
         TabIndex        =   25
         Top             =   210
         Width           =   765
      End
   End
   Begin Frame Frame7 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Receive"
      FontBold        =   -1  'True
      FontItalic      =   -1  'True
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   2085
      Left            =   30
      TabIndex        =   30
      Top             =   4080
      Width           =   7365
      Begin TextBox InputBuffer 
         BackColor       =   &H00FFFFFF&
         Height          =   1635
         Left            =   0
         MultiLine       =   -1  'True
         ScrollBars      =   3  'Both
         TabIndex        =   38
         Top             =   450
         Width           =   7335
      End
      Begin CommandButton ClearReceive 
         Caption         =   "Clear"
         Height          =   285
         Left            =   6600
         TabIndex        =   45
         Top             =   150
         Width           =   675
      End
   End
End
Dim EventArray(1 To 9) As String
Dim AutoClose As Integer

Sub ClearButton_Click ()
' Clear the event log
  EventBox.Text = ""
End Sub

Sub ClearReceive_Click ()
  inputBuffer.Text = ""
End Sub

Sub ClearSend_Click ()
  OutputBuffer.Text = ""
End Sub

Sub CloseFormButton_Click ()
' Close the form

  If (MsgBox("Close all connections?", MB_ICONQUESTION + MB_YESNO) = IDYES) Then
    vbstak.Action = STAK_ACTION_CLOSE
    DataStak.Action = STAK_ACTION_CLOSE
    DataStak.Action = STAK_ACTION_CLOSE
    Unload Me
  End If
End Sub

Sub CloseSocket ()
    vbstak.Action = STAK_ACTION_CLOSE
    DataStak.Action = STAK_ACTION_CLOSE
    DataStak.Socket = DataStak.MasterSocket
    DataStak.Action = STAK_ACTION_CLOSE
    MessageButton.Caption = "Connect"
End Sub

Sub ConnectDataButton_Click ()
  'Set the DataStak up to listen
  If ConnectDataButton.Caption <> "Close" Then
    DataStak.Protocol = IPPROTO_TCP
    'DataStak.LocalAddress = VBStak.LocalAddress
    DataStak.LocalPort = 2048
    DataStak.Action = STAK_ACTION_LISTEN
    ConnectDataButton.Caption = "Close"
    LocalDataPort.Text = DataStak.LocalPort
  Else
    DataStak.Action = STAK_ACTION_CLOSE
    DataStak.Action = STAK_ACTION_CLOSE
    ConnectDataButton.Caption = "Open"
  End If
End Sub

Sub DataStak_Message (Message As Integer)

  EventBox.Text = "(Data)" & DecodeEvent(Message) + Chr(13) + Chr(10) + EventBox.Text
Select Case Message
  Case FD_ACCEPT
    
    ' Got here
  Case FD_READ
    dataString = DataStak.Input
    inputBuffer.SelStart = Len(inputBuffer.Text)
    inputBuffer.SelText = dataString
  Case FD_CONNECT
    LocalDataPort.Text = Str(DataStak.LocalPort \ 256) & "," & Str(DataStak.LocalPort Mod 256)
  Case FD_CLOSE
    DataStak.Action = STAK_ACTION_CLOSE
    ConnectDataButton.Caption = "Open Data Port"
  End Select
  statusBox.Text = vbstak.Status

End Sub

Sub DebugMode_Click ()
  ' Set the debug mode
  vbstak.Debug = DebugMode.Value

End Sub

Function DecodeEvent (event As Integer) As String

  Select Case event
  Case FD_READ
    DecodeEvent = "Read"
  Case FD_WRITE
    DecodeEvent = "Write"
  Case FD_OOB
    DecodeEvent = "Out Of Bound"
  Case FD_ACCEPT
    DecodeEvent = "Accept"
  Case FD_CONNECT
    DecodeEvent = "Connect"
  Case FD_CLOSE
    DecodeEvent = "Close"
  Case STAK_EVENT_SERVICE
    DecodeEvent = "Service"
  Case STAK_EVENT_HOST
    DecodeEvent = "Host"
  Case STAK_EVENT_PROTOCOL
    DecodeEvent = "Protocol"
  End Select
End Function

Sub DisplayStatus ()
  
  HostAddressBox.Text = vbstak.HostAddress
  HostNameBox.Text = vbstak.Host
  ErrorBox.Text = vbstak.Error
  SocketBox.Text = vbstak.Socket
  LocalPort.Text = vbstak.LocalPort
  ProtocolNameBox.Text = vbstak.ProtocolName
  ServiceNameBox.Text = vbstak.ServiceName
  statusBox.Text = vbstak.Status
  LocalDataPort.Text = DataStak.LocalPort

End Sub

Sub Form_Load ()

  Call DisplayStatus

End Sub

Sub Form_Unload (Cancel As Integer)

  vbstak.Action = STAK_ACTION_CLOSE

End Sub

Sub GetHostButton_Click ()

  vbstak.Host = vbstak.Host & Chr(0)
  vbstak.Action = STAK_ACTION_GET_HOST

End Sub

Sub HostAddressBox_LostFocus ()

  ' Set the host address
  vbstak.HostAddress = HostAddressBox.Text

End Sub

Sub HostNameBox_LostFocus ()

  vbstak.Host = HostNameBox.Text

End Sub

Sub MessageButton_Click ()
  
  If MessageButton.Caption = "Connect" Then
    'VBStak.LocalAddress = "0.0.0.0"
    vbstak.LocalPort = 2048
    vbstak.Action = STAK_ACTION_OPEN
  Else
    Call CloseSocket
  End If

End Sub

Sub OutputBuffer_KeyPress (KeyAscii As Integer)
  Static LineBuffer As String
  If KeyAscii = 13 And LineModeCheck Then
    lineEndPosition = 1
    lineStartPosition = 1
    lineOffset = 0
    Do While lineEndPosition <= OutputBuffer.SelStart
      lineEndPosition = InStr(lineStartPosition + 1, OutputBuffer.Text, Chr(13))
      If lineEndPosition = 0 Then lineEndPosition = Len(OutputBuffer.Text) + 1
      If lineEndPosition >= OutputBuffer.SelStart Then
        Exit Do
      End If
      lineOffset = 2
      lineStartPosition = lineEndPosition
    Loop
    'Return key - process line command
    outputString = Mid(OutputBuffer.Text, lineStartPosition + lineOffset, lineEndPosition - lineStartPosition - lineOffset) & Chr(10)
    vbstak.Output = outputString
    vbstak.Action = STAK_ACTION_SEND
  Else
    LineBuffer = LineBuffer & Chr(KeyAscii)
  End If
End Sub

Sub ProtocolButton_Click ()
  vbstak.ProtocolName = ProtocolNameBox.Text & Chr(0)
  vbstak.Action = STAK_ACTION_GET_PROTOCOL

End Sub

Sub RemotePortBox_LostFocus ()

  ' Set the service manually
  vbstak.RemotePort = Val(RemotePortBox.Text)

End Sub

Sub SendButton_Click ()

' Send the text
  ' inputBuffer.Text = ""
  vbstak.Output = OutputBuffer.Text
  vbstak.Action = STAK_ACTION_SEND

End Sub

Sub SendDataButton_Click ()
'  Send the data to the Data port
  DataStak.Output = OutputBuffer.Text
  DataStak.Action = STAK_ACTION_SEND

End Sub

Sub ServiceButton_Click ()

  vbstak.ServiceName = ServiceNameBox.Text & Chr(0)
  vbstak.ProtocolName = ProtocolNameBox.Text & Chr(0)
  vbstak.Action = STAK_ACTION_GET_SERVICE

End Sub

Sub ServiceNameBox_LostFocus ()

  vbstak.ServiceName = ServiceNameBox.Text

End Sub

Sub StatusButton_Click ()
  
  Call DisplayStatus

End Sub

Sub VBStak_Message (Message As Integer)
  ' Get the message
  
  EventBox.Text = "(Com)" & DecodeEvent(Message) + Chr(13) + Chr(10) + EventBox.Text
  Select Case Message
  Case FD_CONNECT
    If vbstak.Error = 0 Then
      MessageButton.Caption = "Close Socket"
      LocalAddressBox.Text = vbstak.LocalAddress
    End If
  Case FD_READ
  
'    inputBuffer.Text = inputBuffer.Text & VBStak.Input & Chr(13) & Chr(10)
    inputBuffer.SelStart = Len(inputBuffer.Text)
    inputBuffer.SelText = vbstak.Input
  Case FD_CLOSE
    If AutoCloseCheckBox.Value = 1 Then
      Call CloseSocket
    End If
  Case STAK_EVENT_SERVICE
    ' The port has been loaded
    'MsgBox ("Got the service request")
    RemotePortBox.Text = vbstak.RemotePort
  Case STAK_EVENT_PROTOCOL
    ' The protocol has been loaded
    'MsgBox ("Got the protocol request")
    ProtocolBox.Text = vbstak.Protocol

  Case STAK_EVENT_HOST
    ' The host has been loaded
    If vbstak.Error <> 0 Then
      MsgBox ("Could not locate host " & HostNameBox.Text)
    End If
  End Select
  Call DisplayStatus

End Sub

