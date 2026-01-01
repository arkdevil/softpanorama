' Constants for the TSE TOOLS 1
Global Const INI_INPUT_MODE = 0
Global Const INI_OUTPUT_MODE = 1

'Declarations for initialization files
Declare Function GetPrivateProfileString% Lib "kernel" (ByVal lpAppName$, ByVal lpKeyName$, ByVal lpDefault$, ByVal lpReturnString$, ByVal nSize%, ByVal lpFileName$)
Declare Function GetProfileInt% Lib "Kernel" (ByVal lpAppName$, ByVal lpKeyName$, ByVal nDefault%)
Declare Function GetProfileString% Lib "Kernel" (ByVal lpAppName$, ByVal lpKeyName$, ByVal lpDefault$, ByVal lpReturnedString$, ByVal nSize%)
Declare Function WriteProfileString% Lib "Kernel" (ByVal lpAppName$, ByVal lpKeyName$, ByVal lpString$)
Declare Function GetPrivateProfileInt% Lib "Kernel" (ByVal lpAppName$, ByVal lpKeyName$, ByVal nDefault%, ByVal lpFileName$)
Declare Function WritePrivateProfileString% Lib "Kernel" (ByVal lpAppName$, ByVal lpKeyName$, ByVal lpString$, ByVal lpFileName$)


Function GetIniField (lpApplicationName As String, lpKeyName As String, lpFileName As String) As String
'
' Description: Return an value field within an ini aplication group
' Parameters: lpApplicationName - '[' bracketed application name to search for
'             lpKeyName - parameter to locate
'             lpFileName  - name of the .ini file to use
' Returns: field value string
' Side effects:
' Original: 01/21/94 - CHSM
'
  Dim plDefault As String, lpReturnString As String, Size As Integer, Valid As Integer
    lpReturnString = Space$(128)
    Size = Len(lpReturnString)


    
    ' Get the requested field
    Valid = GetPrivateProfileString(lpApplicationName, lpKeyName, lpDefault, lpReturnString, Size, lpFileName)


    '* Discard the trailing spaces and null character.
    
    ReturnValue = Left$(lpReturnString, Valid)

GetIniFieldExit:
  'If iniFile <> 0 Then Close iniFile
  GetIniField = ReturnValue
  Exit Function

GetIniFieldError:
  result = HandleError("Get .ini error ")
  ReturnValue = ""
  Resume GetIniFieldExit

End Function

Function HandleError (errorMessage As String)
' Default error handler
  HandleError = MsgBox(errorMessage & Error, MB_ABORTRETRYIGNORE + MB_ICONSTOP)
End Function

Sub SetIniField (lpApplicationName As String, lpKeyName As String, lpString As String, lpFileName As String)
'
' Description: Write a field to an ini file within an ini group
' Parameters: fileName  - name of the file to use
'             groupName - '[' bracketed group to search for
'             fieldName - parameter to locate
'             valueString - parameter setting
' Returns:
' Parameter: field value string
' Side effects:
' Original: 01/21/94 - CHSM
'
    Valid% = WritePrivateProfileString(lpApplicationName, lpKeyName, lpString, lpFileName)

  On Error GoTo SetIniFieldError
  ' Input the file string

SetIniFieldExit:
  Exit Sub

SetIniFieldError:
  result = HandleError("Get .ini error ")
  Resume SetIniFieldExit

End Sub

