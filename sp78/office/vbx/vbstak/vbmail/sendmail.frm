VERSION 2.00
Begin Form SendMailForm 
   BorderStyle     =   3  'Fixed Double
   Caption         =   "Mail"
   ClientHeight    =   4605
   ClientLeft      =   660
   ClientTop       =   1950
   ClientWidth     =   7395
   Height          =   5010
   Icon            =   0
   Left            =   600
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MDIChild        =   -1  'True
   MinButton       =   0   'False
   ScaleHeight     =   4605
   ScaleWidth      =   7395
   Top             =   1605
   Width           =   7515
   Begin SSFrame Frame3D1 
      Height          =   4605
      Left            =   30
      TabIndex        =   0
      Top             =   30
      Width           =   7365
      Begin VBSTAK MailStak 
         Debug           =   0   'False
         Host            =   "haddock2"
         HostAddress     =   ""
         InputLen        =   0
         Left            =   5550
         LocalAddress    =   ""
         LocalPort       =   0
         Options         =   0
         Protocol        =   0
         ProtocolName    =   "tcp"
         RemotePort      =   0
         ServiceName     =   "smtp"
         Top             =   270
      End
      Begin SSCheck TestModeCheck 
         Caption         =   "Test Mode"
         Height          =   315
         Left            =   4350
         TabIndex        =   6
         Top             =   420
         Width           =   1545
      End
      Begin SSPanel Panel3D1 
         BevelInner      =   1  'Inset
         Height          =   405
         Index           =   1
         Left            =   780
         TabIndex        =   15
         Top             =   120
         Width           =   3015
         Begin TextBox MyAddressBox 
            BorderStyle     =   0  'None
            Height          =   225
            Left            =   90
            TabIndex        =   1
            Top             =   90
            Width           =   2835
         End
      End
      Begin Timer LinkTimer 
         Enabled         =   0   'False
         Interval        =   10000
         Left            =   3840
         Top             =   210
      End
      Begin SSPanel StatusBox 
         BevelInner      =   1  'Inset
         Height          =   375
         Left            =   780
         TabIndex        =   9
         Top             =   1020
         Width           =   5445
      End
      Begin SSPanel Panel3D2 
         BevelInner      =   1  'Inset
         Height          =   2865
         Left            =   60
         TabIndex        =   8
         Top             =   1680
         Width           =   7245
         Begin TextBox MessageBox 
            Height          =   2715
            Left            =   60
            MultiLine       =   -1  'True
            ScrollBars      =   2  'Vertical
            TabIndex        =   3
            Top             =   60
            Width           =   7125
         End
      End
      Begin CommandButton CloseButton 
         Caption         =   "Close"
         Height          =   315
         Left            =   6270
         TabIndex        =   4
         Top             =   150
         Width           =   1035
      End
      Begin CommandButton SendButton 
         Caption         =   "Send"
         Enabled         =   0   'False
         Height          =   315
         Left            =   6270
         TabIndex        =   5
         Top             =   450
         Width           =   1035
      End
      Begin SSPanel Panel3D1 
         BevelInner      =   1  'Inset
         Height          =   405
         Index           =   0
         Left            =   780
         TabIndex        =   7
         Top             =   570
         Width           =   3015
         Begin TextBox AddressBox 
            BorderStyle     =   0  'None
            Height          =   225
            Left            =   90
            TabIndex        =   2
            Top             =   90
            Width           =   2835
         End
      End
      Begin Label Label6 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Message:"
         Height          =   195
         Left            =   90
         TabIndex        =   10
         Top             =   1470
         Width           =   825
      End
      Begin Label Label5 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Status:"
         Height          =   255
         Left            =   60
         TabIndex        =   11
         Top             =   1080
         Width           =   735
      End
      Begin Label Label2 
         BackColor       =   &H00C0C0C0&
         Caption         =   "From:"
         Height          =   315
         Left            =   60
         TabIndex        =   13
         Top             =   150
         Width           =   705
      End
      Begin Label Label1 
         BackColor       =   &H00C0C0C0&
         Caption         =   "To:"
         Height          =   285
         Left            =   150
         TabIndex        =   16
         Top             =   630
         Width           =   585
      End
      Begin Label Label4 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Link Timer"
         Height          =   255
         Left            =   4320
         TabIndex        =   14
         Top             =   180
         Visible         =   0   'False
         Width           =   1425
      End
   End
   Begin Label Label3 
      Caption         =   "Label3"
      Height          =   30
      Left            =   7440
      TabIndex        =   12
      Top             =   4650
      Width           =   135
   End
End
Dim HostResponded As Integer
Dim ServiceResponded As Integer
Dim ProtocolResponded As Integer
Dim LinkTime As Integer

Sub CloseButton_Click ()

' Close the socket and release VBX
  Unload Me

End Sub

Sub Form_Load ()
  
  MailStak.Host = GetIniField("Host", "HostName", "vbmail.ini")
  MailStak.ServiceName = GetIniField("Host", "SendService", "vbmail.ini")

End Sub

Sub LinkTimer_Timer ()
' Error on timeout
  LinkTime = LinkTime - 1
  If LinkTime = 0 Then
    result = MsgBox("Link timeout", MB_ICONSTOP + MB_OK)
    LinkTimer.Enabled = False
  End If
End Sub

Sub MailStak_Message (message As Integer)
' Receive socket messages
  
  Dim responseString As String

  Select Case message
  Case STAK_EVENT_HOST
    HostResponded = True
    processRequest ("Host")

  Case STAK_EVENT_SERVICE
    ServiceResponded = True
    Call processRequest("Service")

  Case STAK_EVENT_PROTOCOL
    ProtocolResponded = True
    Call processRequest("Protocol")

  Case FD_READ
    responseString = MailStak.Input
    Call processMail(responseString)
  
  Case FD_CONNECT
  ' Connected to server
    If MailStak.Error = 0 Then
      Connected = True
      closeButton.Enabled = False
      StatusBox.Caption = "Connected to " & MailStak.Host
    Else
      StatusBox.Caption = "Cannot connect to host " & HostName
    End If
  Case FD_CLOSE
  ' Remote Disconect
    Connected = False
    MailStak.Action = STAK_ACTION_CLOSE
    closeButton.Enabled = True
  End Select

End Sub

Sub MessageBox_Change ()
  
  SendButton.Enabled = MyAddressBox.DataChanged And AddressBox.DataChanged

End Sub

Sub MyAddressBox_LostFocus ()
' Set my Address
    MyAddress = MyAddressBox.Text

End Sub

Sub processMail (responseString As String)
' Process the mail response and update based on state

  On Error GoTo ProcessMailError
  
  LinkTimer.Enabled = False
  
  If MailState <> SMTP_END Then
    StatusBox.Caption = responseString
  End If

  ' If test node display and step
  If TestMode Then
    result = MsgBox("Mail State: " & Str(MailState), MB_OK)
  End If
  
  ' State machine for mail States
  Select Case MailState
  Case SMTP_IDLE
    Exit Sub

  Case SMTP_LOCATE_SERVICE
    MailState = SMTP_LOCATING_SERVICE
    Call StartTimer(STAK_WAIT_INTERVAL)
    MailStak.Action = STAK_ACTION_GET_SERVICE

  Case SMTP_LOCATING_SERVICE
    'MailStak.ProtocolName = MailStak.ProtocolName & Chr(0)
    MailState = SMTP_LOCATING_PROTOCOL
    Call StartTimer(STAK_WAIT_INTERVAL)
    MailStak.Action = STAK_ACTION_GET_PROTOCOL
    
  Case SMTP_LOCATING_PROTOCOL
    StatusBox.Caption = "Locating Host"
    MailState = SMTP_LOCATING_HOST
    MailStak.Action = STAK_ACTION_GET_HOST
    StartTimer (STAK_SERVICE_INTERVAL)

  Case SMTP_LOCATING_HOST
      closeButton.Enabled = False
      MailState = SMTP_CONNECT
      StartTimer (STAK_WAIT_INTERVAL)
      MailStak.Action = STAK_ACTION_OPEN

  Case SMTP_CONNECT
    If InStr(1, responseString, "220 ") <> 0 Then
      MailState = SMTP_HELO
      Call SendData("HELO " & MyAddress & Chr(10))
    Else
      'Error SMTP_ERROR
    End If
  Case SMTP_HELO
    If InStr(1, responseString, "250 ") <> 0 Then
      MailState = SMTP_MAIL_FROM
      Call SendData("mail from:<" & MyAddress & ">" & Chr(10))
    Else
      ' Error SMTP_ERROR
    End If
  Case SMTP_MAIL_FROM
    If InStr(1, responseString, "250 ") > 0 Then
      MailState = SMTP_RCPT_TO
      Call SendData("RCPT TO:<" & AddressBox.Text & ">" & Chr(10))
    Else
      Error SMTP_ERROR
    End If
  Case SMTP_RCPT_TO
    If InStr(1, responseString, "250 ") Then
      MailState = SMTP_DATA
      Call SendData("DATA" & Chr(10))
    Else
      Error SMTP_ERROR
    End If

  Case SMTP_DATA
    If InStr(1, responseString, "354 ") Then
      MailState = SMTP_CLOSE
      Call SendData(MessageBox.Text & Chr(10) & "." & Chr(10))
    Else
      Error SMTP_ERROR
    End If
  Case SMTP_CLOSE

    If InStr(1, responseString, "250 ") Then
      MailState = SMTP_END
      Call SendData("QUIT" & Chr(10))
    Else
      Error SMTP_ERROR
    End If

  Case SMTP_END
    Exit Sub
  End Select
  
ProcessMailExit:
  Exit Sub

ProcessMailError:
  If Err = SMTP_ERROR Then
    MailState = SMTP_IDLE
    Resume ProcessMailExit
  Else
    result = MsgBox(" Error " & Error, MB_ICONSTOP + MB_OK)
    Resume ProcessMailExit
  End If
End Sub

Sub processRequest (requestType As String)
' Process the response to a host,service or protocol request
    If MailStak.Error <> NO_ERROR Then
      MailState = SMTP_IDLE
      StatusBox.Caption = requestType & " Error " & Str(MailStak.Error)
    Else
      Call processMail("")
    End If

End Sub

Sub SendButton_Click ()
' Query smail and wait for responses
  
  MailState = SMTP_LOCATE_SERVICE
  processMail ("")

End Sub

Sub SendData (dataBuffer As String)
' Send the buffer to the socket
  StartTimer (STAK_WAIT_INTERVAL)
  MailStak.Output = dataBuffer '& Chr(0)
  MailStak.Action = STAK_ACTION_SEND

End Sub

Sub StartTimer (Interval As Integer)
    LinkTime = Interval
    LinkTimer.Interval = 1000
    LinkTimer.Enabled = True

End Sub

Sub TestModeCheck_Click (Value As Integer)
  ' Set the test mode
  TestMode = TestModeCheck.Value

End Sub

