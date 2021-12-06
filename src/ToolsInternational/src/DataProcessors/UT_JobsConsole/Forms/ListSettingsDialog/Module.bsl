#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ThisForm.AutoUpdate = ThisForm.Parameters.AutoUpdate;
	ThisForm.AutoUpdatePeriod = ThisForm.Parameters.AutoUpdatePeriod;
	IntervalSeconds = 5;
	If AutoUpdatePeriod < IntervalSeconds Then
		AutoUpdatePeriod = IntervalSeconds;
	EndIf;
EndProcedure

#EndRegion

#Region ItemsEventHandlers

&AtClient
Procedure OK(Command)
	IntervalSeconds = 5;
	If AutoUpdatePeriod < IntervalSeconds Then
		AutoUpdatePeriod = IntervalSeconds;
	EndIf;
	Result = New Structure("AutoUpdate, AutoUpdatePeriod", AutoUpdate, AutoUpdatePeriod);
	Close(Result);
EndProcedure

#EndRegion