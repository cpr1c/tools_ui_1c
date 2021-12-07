#Region EventHandlers

// Scheduled job schedule 
&AtClient
Var Schedule;

&AtClient
Procedure OnOpen(Cancel)
	Schedule = GetScheduledJobSchedule(ScheduledJobID);
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	For Each Job In Metadata.ScheduledJobs Do
		JobPresentation = StrTemplate("%1 (%2)", Job.Name, Job.Synonym);
		Items.MetadataChoice.ChoiceList.Add(Job.Name, JobPresentation);
	EndDo;
	Items.MetadataChoice.ChoiceList.SortByValue();
	
	Try
		IBUsers = InfoBaseUsers.GetUsers();
	Except
		Message = New UserMessage();
		Message.Text = NStr("ru = 'Ошибка при получении списка пользователей информационной базы: '; en = 'Infobase users getting error: '") + ErrorDescription();
		Message.Message();
		IBUsers = Undefined;
	EndTry;
	
	If IBUsers <> Undefined Then
		
		For Each User In IBUsers Do
			Items.UsersChoice.ChoiceList.Add(User.Name, User.FullName);
		EndDo;
	
	EndIf;

	ScheduledJobID = Parameters.JobID;
	ScheduledJob = GetScheduledJobObject(ScheduledJobID); 
	If ScheduledJob <> Undefined Then
		
		MetadataChioce = ScheduledJob.Metadata.Name;
		
		Method = ScheduledJob.Metadata.MethodName;
		
		Description = ScheduledJob.Description;
		Key = ScheduledJob.Key;
		Use = ScheduledJob.Use;
		UsersChoice = ScheduledJob.UserName;
		RestartCountOnFailure = ScheduledJob.RestartCountOnFailure;
		RestartIntervalOnFailure = ScheduledJob.RestartIntervalOnFailure;
		
		Schedule = ScheduledJob.Schedule;
		
		// Adding parameters
		For Each Parameter In ScheduledJob.Parameters Do
			NewRow = JobParameters.Add();
			NewRow.LineNumber = JobParameters.IndexOf(NewRow) + 1;
			NewRow.Value = Parameter;
			TypesArray = New Array;
			TypesArray.Add(TypeOf(Parameter));
			NewRow.Type = New TypeDescription(TypesArray);
		EndDo;
		
	Else
		Schedule = New JobSchedule;
	EndIf;
	
	Items.ScheduleLabel.Title = NStr("ru = 'Выполнять: '; en = 'Execute: '") + String(Schedule);

EndProcedure

#EndRegion

#Region ItemsEventHandlers

&AtClient
Procedure OK(Command)
	If WriteScheduledJob(Schedule) Then
		ThisForm.Close(ScheduledJobID);
	EndIf;
EndProcedure

&AtClient
Procedure ChangeScheduleClick(Item)
	ChangeSchedule();
EndProcedure

&AtClient
Procedure ScheduleLabelClick(Item)
	ChangeSchedule();
EndProcedure

&AtClient
Procedure ChangeSchedule()
	Dialog = New ScheduledJobDialog(Schedule);
	NotifyDescription = Новый NotifyDescription("ScheduledJobDialogOnClose", ThisForm);
	Dialog.Show(NotifyDescription);
EndProcedure

&AtClient
Procedure ScheduledJobDialogOnClose(ScheduleResult, AdditionalParameters) Export
	If ScheduleResult <> Undefined Then
		Schedule = ScheduleResult;
		Items.ScheduleLabel.Title = NStr("ru = 'Выполнять: '; en = 'Execute: '") + String(Schedule);
	EndIf;
EndProcedure

&AtClient
Procedure JobParametersValueOnChange(Item)
	UpdateParameters();
EndProcedure

&НаСервере
Procedure UpdateParameters()
	For Each CurrentRow In JobParameters Do
		CurrentRow.LineNumber = JobParameters.IndexOf(CurrentRow) + 1;
		TypesArray = New Array;
		TypesArray.Add(TypeOf(CurrentRow.Value));
		CurrentRow.Type = New TypeDescription(TypesArray);
	EndDo;
EndProcedure

#EndRegion

#Region Private

&AtServer
Function WriteScheduledJob(Schedule)
	Try
		
		If MetadataChioce = Undefined Or MetadataChioce = "" Then
			Raise(NStr("ru = 'Не выбраны метаданные регламентного задания.'; en = 'Scheduled job metadata not selected.'"));
		КонецЕсли;
		
		ScheduledJob = GetScheduledJobObject(ScheduledJobID);
		
		If ScheduledJob = Undefined Then
			ScheduledJob = ScheduledJobs.CreateScheduledJob(MetadataChioce);
			ScheduledJobID = ScheduledJob.UUID;
		EndIf;
		
		ScheduledJob.Description = Description;
		ScheduledJob.Key = Key;
		ScheduledJob.Use = Use;
		ScheduledJob.UserName = UsersChoice;
		ScheduledJob.RestartCountOnFailure = RestartCountOnFailure;
		ScheduledJob.RestartIntervalOnFailure = RestartIntervalOnFailure;
		ScheduledJob.Schedule = Schedule;
		
		// Adding scheduled job parameters
		If JobParameters.Count() Then
			ScheduledJob.Parameters = JobParameters.Unload().UnloadColumn("Value");
		Else
			ScheduledJob.Parameters = New Array;
		EndIf;
		
		ScheduledJob.Записать();
	Except	
		Message = New UserMessage();
		Message.Текст = NStr("ru = 'Ошибка: '; en = 'Error: '") + ErrorDescription();
		Message.Message();

		Return False;
	EndTry;
	
	Return True;
EndFunction

&AtServer
Function GetScheduledJobSchedule(JobUniqueNumber) Export
	JobObject = GetScheduledJobObject(JobUniqueNumber);
	If JobObject = Undefined Then
		Return New JobSchedule;
	EndIf;
	
	Return JobObject.Schedule;
EndFunction

&AtClient
Procedure MetadataChoiceChoiceProcessing(Item, SelectedValue, StandardProcessing)
	JobProperties = GetJobProperties(SelectedValue);
	Description = JobProperties.Presentation;
	Method = JobProperties.MethodName;
EndProcedure

&AtServerNoContext
Function GetJobProperties(MetadataName)
	Result = New Structure("MethodName, Presentation");
	JobMetadata = Metadata.ScheduledJobs.Find(MetadataName);
	If JobMetadata <> Undefined Then
		Result.MethodName = JobMetadata.MethodName;
		Result.Presentation = JobMetadata.Presentation();
	EndIf;
	Return Result;
EndFunction

&AtServer
Function GetScheduledJobObject(JobUniqueNumber) Export
	
	Try
		
		If Not IsBlankString(JobUniqueNumber) Then
			JobUUID = New UUID(JobUniqueNumber);
			CurrentScheduledJob = ScheduledJobs.FindByUUID(JobUUID);
		Else
			CurrentScheduledJob = Undefined;
		EndIf;
		
	Except
		CurrentScheduledJob = Undefined;
    EndTry;
	
	Return CurrentScheduledJob;
	
EndFunction

#EndRegion