#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Scheduled_ = ScheduledJobs.GetScheduledJobs();
	ChoiceList = Items.Scheduled.ChoiceList;
	For Each ScheduledJob In Scheduled_ Do
		If ChoiceList.FindByValue(ScheduledJob.Metadata.Name) = Undefined Then
			ChoiceList.Добавить(ScheduledJob.Metadata.Name, ScheduledJob.Metadata.Presentation());
		EndIf;
	EndDo;
	
	Active = False;
	Completed = False;
	Failed = False;
	Canceled = False;
	
	FillAttributes();
	
EndProcedure

&AtServer
Procedure FillAttributes()
	If Parameters.Filter = Undefined Then
		Return;
	EndIf;
	
	Filter = Parameters.Filter.Get();
	For Each Property In Filter Do
		If Property.Key = "Begin" Then
			Begin = Property.Value;
		ElsIf Property.Key = "End" Then
			End = Property.Value;
		ElsIf Property.Key = "Key" Then
			Key = Property.Value;
		ElsIf Property.Key = "Description" Then
			Description = Property.Value;	
		ElsIf Property.Key = "MethodName" Then
			Method = Property.Value;	
		ElsIf Property.Key = "ScheduledJob" Then
			Scheduled = Property.Value.Metadata.Name;
		ElsIf Property.Key = "State" Then
			SetStateFlags(Property.Value);
		Else
			Continue;
		EndIf;		
	EndDo;
	
EndProcedure

Procedure SetStateFlags(StatesArray)
	For Each JobState In StatesArray Do
		If JobState = BackgroundJobState.Active Then
			Active = True;
		ElsIf JobState = BackgroundJobState.Completed Then
			Completed = True;	
		ElsIf JobState = BackgroundJobState.Failed Then
			Failed = True;		
		ElsIf JobState = BackgroundJobState.Canceled Then
			Canceled = True;	
		Else
			Raise NStr("ru = 'Неизвестное состояние задания: '; en = 'Unknown job state: '") + JobState;
		EndIf;
	EndDo;
EndProcedure

#EndRegion

#Region ItemsEventHandlers

&AtClient
Procedure OK(Command)
	Filter = GetFilter();
	
	Close(Filter);
EndProcedure

&AtServer
Function GetFilter()
	Filter = New Structure;
	
	If Not IsBlankDate(Begin) Then
		Filter.Insert("Begin", Begin);
	EndIf;
	
	If Not IsBlankDate(End) Then
		Filter.Insert("End", End);
	EndIf;
	
	If Not IsBlankString(Key) Then
		Filter.Insert("Key", Key);
	EndIf;
	
	If Not IsBlankString(Description) Then
		Filter.Insert("Description", Description);
	EndIf;
	
	If Not IsBlankString(Method) Then
		Filter.Insert("MethodName", Method);
	EndIf;
	
	If Scheduled <> "" Then
		ScheduledArray = ScheduledJobs.GetScheduledJobs(New Structure("Metadata", Scheduled));
		If ScheduledArray.Count() > 0 Then
			Filter.Insert("ScheduledJob", ScheduledArray[0]);
		EndIf;
	EndIf;
	
	Array = New Array;
	
	If Active Then
		Array.Add(BackgroundJobState.Active);
	EndIf;
	
	If Completed Then
		Array.Add(BackgroundJobState.Completed);
	EndIf;
	
	If Failed Then
		Array.Add(BackgroundJobState.Failed);
	EndIf;
	
	If Canceled Then
		Array.Add(BackgroundJobState.Canceled);
	EndIf;
	
	If Array.Count() > 0 Then
		Filter.Insert("State", Array);
	EndIf;
	
	Return New ValueStorage(Filter);
EndFunction

&AtServer
Function IsBlankDate(Date)
	If Date = '00010101' Then
		Return True;
	Else
		Return False;
	EndIf;
EndFunction

#EndRegion
