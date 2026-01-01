' ITab <-> Formula One:
Declare Sub ITabCopyToVTSS Lib "VBITVTSS.DLL" (ByVal table&, ByVal ssHandle&)
Declare Sub ITabCopyDataToVTSS Lib "VBITVTSS.DLL" (ByVal table&, ByVal ssHandle&)
Declare Function ITabCopyFromVTSS& Lib "VBITVTSS.DLL" (ByVal ssHandle&)
Declare Sub ITabSetMaxDecimalsFromVTSS Lib "VBITVTSS.DLL" (ByVal maxDec%)
Declare Function VTSSget$ Lib "VBITVTSS.DLL" (ByVal ssHandle&, ByVal row%, ByVal col%)
Declare Sub VTSSput Lib "VBITVTSS.DLL" (ByVal ssHandle&, ByVal row%, ByVal col%, ByVal dataStr$)

