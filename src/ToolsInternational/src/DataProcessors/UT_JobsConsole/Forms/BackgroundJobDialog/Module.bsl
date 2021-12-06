#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	JobID = Parameters.JobID;
	BackgroundJob = GetBackgroundJobObject(JobID);
	If BackgroundJob <> Неопределено Then
		MethodName = BackgroundJob.MethodName;
		Description = BackgroundJob.Description;
		Key = BackgroundJob.Ключ;
	EndIf;
	
	If Parameters.Property("MethodName") Then
		MethodName = Parameters.MethodName;
		Description = Parameters.Description;
		Key = Parameters.Key;
	EndIf;
	
	For Each MetadataItem In Metadata.ScheduledJobs Do
		Items.MethodName.ChioceList.Add(MetadataItem.MethodName);
	EndDo;
	Items.MethodName.ChioceList.SortByValue();

EndProcedure

#EndRegion

#Region ItemsEventHandlers

&AtClient
Procedure OK(Command)
	JobID = Undefined;
	ExecuteBackgroundJob(JobID);
	Close(JobID);
EndProcedure

&AtServer
Procedure ExecuteBackgroundJob(JobID)
    BackgroundJob = BackgroundJobs.Execute(MethodName, , Key, Description);
	JobID = BackgroundJob.UUID;
EndProcedure

#EndRegion

#Region СлужебныеПроцедурыИФункции

&НаСервере
Function GetBackgroundJobObject(JobUniqueNumber) Export
	
	Try
		
		If Not ПустаяСтрока(JobUniqueNumber) Then
			JobUUID = New UUID(JobUniqueNumber);
			CurrentBackgroundJob = BackgroundJobs.FindByUUID(JobUUID);
		Else
			CurrentBackgroundJob = Undefined;
		EndIf;
		
	Except
		CurrentBackgroundJob = Undefined;
    EndTry;
	
	Return CurrentBackgroundJob;
	
EndFunction

#EndRegion