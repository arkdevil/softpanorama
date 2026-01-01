
DDECommand(Message)		// Message("Message to display", bMessageBox)
DDECommand(Calendar)	// Calendar(1994, 10, 5)
DDECommand(PlayWave)	// PlayWave(foo.wav)
DDECommand(RunApp)		// RunApp("app parm")

DDECommand(TimerStart)	// TimerStart("timer name")
DDECommand(TimerStop)	// TimerStop("timer name")
DDECommand(TimerAdd)	// TimerAdd("timer name", type, dollar, cent, inc, stopval)
DDECommand(TimerInfo)	// TimerInfo("timer name", "message", sound.wav, "app param")
DDECommand(TimerDelete)	// TimerDelete("timer name")


DDECommand(AlarmAdd)	// AlarmAdd("alarm name", year, month, day,
					//					 hour, minute, repeat)
DDECommand(AlarmInfo)	// AlarmInfo("alarm name", "message", sound.wav, "app param")
DDECommand(AlarmDelete)	// AlarmDelete("alarm name")


DDECommand(ButtonAdd)	// ButtonAdd(hookSig, btnId, bLeft)
DDECommand(ButtonDelete)	// ButtonDelete(hookSig, btnId)

DDECommand(InstallHook)	// InstallHook("DLLName.DLL")

