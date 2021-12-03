#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.ScheduledJobsList.CommandBar);
EndProcedure

&AtServer
Procedure FilterOnOpen()

	ThisForm.BackgroundJobsFilterEnabled = True;
	// Protective filter for intensive background startup.
	FilterInterval = 3600;
	ThisForm.BackgroundJobsFilter = New ValueStorage(New Structure("Begin", CurrentSessionDate() - FilterInterval));
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)

	UpdateOnCreate();
	
	If BackgroundJobsListAutoUpdate = True Then
		AttachIdleHandler("BackgroundJobsAutoUpdateHandler", BackgroundListAutoUpdatePeriod);	
	EndIf;
	
	If ScheduledJobsListAutoUpdate = True Then
		AttachIdleHandler("ScheduledJobsAutoUpdateHandler", ScheduledListAutoUpdatePeriod);	
	EndIf;
		
	#If ThickClientOrdinaryApplication Then
		Items.ScheduledJobsListEventLog1.Visible = False;
	#EndIf
	#If ThickClientOrdinaryApplication OR ThickClientManagedApplication Then
		Items.ScheduledJobsListExecuteManually.Title = "At client (thick client)";
	#EndIf
	Items.BackgroundJobsListSettings.Check = BackgroundJobsListAutoUpdate;
	Items.ScheduledJobsListSettings.Check = ScheduledJobsListAutoUpdate;

EndProcedure

&AtServer
Procedure UpdateOnCreate()
	
	Try
		FilterOnOpen();
		
		BackgroundJobsListRefresh();
		RefreshScheduledJobsList();
	Except	
		NotifyUser(ErrorInfo());
	EndTry;
	
	DataProcessorVersion = FormAttributeToValue("Object").DataProcessorVersion();
	ThisForm.Title = StrTemplate("Scheduled and background jobs v%1", DataProcessorVersion);
	
EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, MessageText, StandardProcessing)
	DetachIdleHandler("BackgroundJobsAutoUpdateHandler");
	DetachIdleHandler("ScheduledJobsAutoUpdateHandler");
EndProcedure

&AtClient
Procedure BackgroundJobsAutoUpdateHandler()
	BackgroundJobsListRefresh();
EndProcedure

&AtClient
Procedure ScheduledJobsAutoUpdateHandler()
	RefreshScheduledJobsList();
EndProcedure

#EndRegion

#Region ScheduledJobsListEventHandlers

&AtClient
Procedure ScheduledJobsListBeforeAddRow(Item, Cancel, Clone, Parent, Folder)
	Cancel = True;
	ParametersStructure = New Structure;
	ParametersStructure.Insert("JobID", "");
	
	OnCloseNotifyHandler = New NotifyDescription("ScheduledJobsListRowAddOnClose", ThisForm);
	
	OpenForm(GetFullFormName("ScheduledJobDialog"), ParametersStructure, ThisForm, , , , OnCloseNotifyHandler, FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure ScheduledJobsListRowAddOnClose(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	RefreshScheduledJobsList();
		
	ScheduledJobID = New UUID(Result);
	Rows = ScheduledJobsList.FindRows(New Structure("ID", ScheduledJobID));
	If Rows.Count() > 0 Then
		Items.ScheduledJobsList.CurrentRow = Rows[0].GetID();		
	EndIf;
		
EndProcedure

&AtClient
Procedure ScheduledJobsListBeforeRowChange(Item, Cancel)
	Cancel = True;
	SelectedRows = Items.ScheduledJobsList.SelectedRows;
	If SelectedRows.Count() > 0 Then
		
		Row = ScheduledJobsList.FindByID(SelectedRows.Get(0));
		
		ParametersStructure = New Structure;
		ID = Row.ID;
		ParametersStructure.Insert("JobID", ID);
	
		OnCloseNotifyHandler = New NotifyDescription("ScheduledJobsListRowChangeOnClose", ThisForm);
		
		OpenForm(GetFullFormName("ScheduledJobDialog"), ParametersStructure, ThisForm, , , , OnCloseNotifyHandler, FormWindowOpeningMode.LockOwnerWindow);

	EndIf;
EndProcedure

&AtClient
Procedure ScheduledJobsListRowChangeOnClose(Result, AdditionalParameters) Export
	If Result <> Undefined Then
		RefreshScheduledJobsList();
	EndIf;
EndProcedure

&AtClient
Procedure ScheduledJobsListBeforeDelete(Item, Cancel)
	Try
		Cancel = Истина;
		DeleteScheduledJob();
		
		RefreshScheduledJobsList();
	Except
		NotifyUser(ErrorInfo());
	EndTry;
EndProcedure

&AtServer
Procedure DeleteScheduledJob()
	SelectedRows = Items.ScheduledJobsList.SelectedRows;
	For Each Row In SelectedRows Do
		ScheduledJobRow = ScheduledJobsList.FindByID(Row);
		
		ScheduledJob = ScheduledJobs.FindByUUID(ScheduledJobRow.ID);
		If ScheduledJob.Predefined Then
			Raise("Unable to delete predefined job: " + ScheduledJob.Description);
		EndIf;
	EndDo;
	
	For Each Row In SelectedRows Do
		ScheduledJobRow = ScheduledJobsList.FindByID(Row);
		ScheduledJob = ScheduledJobs.FindByUUID(ScheduledJobRow.ID);
		ScheduledJob.Delete();
	EndDo;
EndProcedure

&AtClient
Procedure ScheduledJobsListOnActivateRow(Item)
	AttachIdleHandler("UpdateCurrentScheduledJobState", 1, True);
EndProcedure

&AtClient
Procedure UpdateCurrentScheduledJobState()
	CurrentRow = Items.ScheduledJobsList.CurrentRow;
	If CurrentRow = Undefined Then
		Return;
	EndIf;
		
	CurrentData = ThisForm.ScheduledJobsList.FindByID(CurrentRow);
	If CurrentData <> Undefined Then
		LastExecutedJobAttributes = GetLastExecutedJobAttributes(CurrentData.ID);
		CurrentData.State = LastExecutedJobAttributes.State;
		CurrentData.Executed = LastExecutedJobAttributes.Executed;
	EndIf;
EndProcedure

#EndRegion

#Region Private

&AtClient 
Function GetFullFormName(FormName) 
	NameLength = 5;
	Return Left(ThisForm.FormName, StrFind(ThisForm.FormName, ".Form.") + NameLength) + FormName; 
EndFunction

&AtServerNoContext
Function GetLastExecutedJobAttributes(ScheduledJobID, Scheduled_ = Undefined)
	Result = New Structure("Executed, State");
	If Scheduled_ = Undefined Then
		Scheduled = ScheduledJobs.FindByUUID(ScheduledJobID);
	Else
		Scheduled = Scheduled_;
	EndIf;
	If Scheduled <> Undefined Then
		Try
			// Causes application slowdown, if scheduled job was executed a long time ago and there were a lot of background jobs.
			LastJob = Scheduled.LastJob;
		Except
			LastJob = Undefined;
			ErrorText = ErrorDescription();
			NotifyUser(ErrorText);
			Return Result;
		EndTry;
		
		If LastJob <> Undefined Then
			Result.Executed = String(LastJob.Begin);
			Result.State = String(LastJob.State);
		EndIf;

	EndIf;
	Return Result;
EndFunction

&AtClientAtServerNoContext
Procedure NotifyUser(MessageText)
	Message = New UserMessage();
	Message.Text = MessageText;
	Message.Message();
EndProcedure

#EndRegion

#Region ScheduledJobsListCommandHandlers

&AtClient
Procedure SetScheduledJobsFilter(Command)
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Filter", ScheduledJobsFilter);
	
	OnCloseNotifyHandler = New NotifyDescription("SetScheduledJobsFilterOnClose", ThisForm);
	
	OpenForm(GetFullFormName("ScheduledJobFilterDialog"), ParametersStructure, ThisForm, , , , OnCloseNotifyHandler, FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure SetScheduledJobsFilterOnClose(Result, AdditionalParameters) Export
	If TypeOf(Result) = Тип("Structure") Then
		ScheduledJobsFilter = Result;
		ScheduledJobsFilterEnabled = True;
		RefreshScheduledJobsList();
	EndIf;
EndProcedure

&AtClient
Procedure DisableScheduledJobsFilter(Command)
	ScheduledJobsFilterEnabled = False;
	RefreshScheduledJobsList();
EndProcedure

&AtClient
Procedure RefreshScheduledJobs(Command)
	RefreshScheduledJobsList(True);
EndProcedure

&AtServer
Procedure RefreshScheduledJobsList(GetAllStates = False)
	Var CurrentID;

	CurrentRow = Items.ScheduledJobsList.CurrentRow;
	If CurrentRow <> Undefined Then
		CurRow = ScheduledJobsList.FindByID(CurrentRow);
		CurrentID = CurRow.ID;
	EndIf;

	IDs = New Array;
	
	SelectedRows = Items.ScheduledJobsList.SelectedRows;
	For Each SelectedRow In SelectedRows Do
		CurRow = ScheduledJobsList.FindByID(SelectedRow);
		IDs.Add(CurRow.ID);
	EndDo;
	
	ScheduledJobsList.Clear();
	
	PutScheduledJobs(GetAllStates);
	
	ScheduledJobsList.Sort("Metadata");
	
	If CurrentID <> Undefined Then
		Rows = ScheduledJobsList.FindRows(New Structure("ID", CurrentID));
		If Rows.Count() > 0 Then
			Items.ScheduledJobsList.CurrentRow = Rows[0].GetID();
		EndIf;
	EndIf;

	If IDs.Count() > 0 Then
		SelectedRows.Clear();
	EndIf;
	
	For Each ID In IDs Do
		Rows = ScheduledJobsList.FindRows(New Structure("ID", ID));
		If Rows.Count() > 0 Then
			SelectedRows.Add(Rows[0].GetID());
		EndIf;
	EndDo;
	
EndProcedure

&AtServer
Function GetScheduledJobsFilter()
	Filter = Undefined;
	FilterRow = "";
	If ScheduledJobsFilterEnabled = True Then
		Filter = ScheduledJobsFilter;
		For Each Item In Filter Do
			If FilterRow <> "" Then
				 FilterRow = FilterRow + ";";
			EndIf;
			FilterRow = FilterRow + Item.Key + ": " + Item.Value;
		EndDo;
		If FilterRow <> "" Then
			FilterRow = " (" + FilterRow + ")";
		EndIf;
	EndIf;
	Items.ScheduledJobs.Title = "Scheduled jobs" + FilterRow;
	Return Filter;
EndFunction
	
&AtServer
Procedure PutScheduledJobs(GetAllStates = False)
	
	Filter = GetScheduledJobsFilter();
	Try
		Scheduled_ = ScheduledJobs.GetScheduledJobs(Filter);
	Except
		ErrorText = ErrorDescription();
		NotifyUser(ErrorText);
		Return;
	EndTry;
	
	Timeout = False;
	MeteringStart = CurrentUniversalDateInMilliseconds();
	Counter = 0;
	Count = Scheduled_.Count();
	For Each Scheduled In Scheduled_ Do
		NewRow = ScheduledJobsList.Add();
		NewRow.Metadata = Scheduled.Metadata.Presentation();
		NewRow.Description = Scheduled.Description;
		NewRow.Key = Scheduled.Key;
		NewRow.Schedule = Scheduled.Schedule;
		NewRow.User = Scheduled.UserName;
		NewRow.Predefined = Scheduled.Predefined;
		NewRow.Use = Scheduled.Use;
		NewRow.ID = Scheduled.UUID;
		NewRow.Method = Scheduled.Metadata.MethodName;
		
		OutputTimeoutMilliseconds = 200;
		OutputDuration = CurrentUniversalDateInMilliseconds() - MeteringStart;
		If Not Timeout And OutputDuration < OutputTimeoutMilliseconds Or GetAllStates Then
			Counter = Counter + 1;
			// Runs slow on large databases.
			LastExecutedJobAttributes = GetLastExecutedJobAttributes(NewRow.ID, Scheduled);
			NewRow.State = LastExecutedJobAttributes.State;
			NewRow.Executed = LastExecutedJobAttributes.Executed;
		EndIf;
		If Not Timeout And OutputDuration > OutputTimeoutMilliseconds Then
			Timeout = True;
		EndIf; 
		
		ScheduledJobName = NewRow.Metadata + ?(ValueIsFilled(NewRow.Description), ":" + NewRow.Description, "");
		Rows = BackgroundJobsList.FindRows(New Structure("Method, Description", NewRow.Method, NewRow.Description));
		For Each Background In Rows Do
			Background.Scheduled = ScheduledJobName;
		EndDo;
	EndDo;	
	
	ScheduledJobsFillingTime = CurrentUniversalDateInMilliseconds() - MeteringStart;
	
	OptimizationExplanationText = StrTemplate("In %1 msec, the states %2 of %3 scheduled jobs were received,"
		+ " but refreshing also occurs when the row is activated.", ScheduledJobsFillingTime, Counter, Count)
		+ " To display the states of all jobs, use Refresh scheduled jobs command.";
		
	Items.ScheduledJobsListExecuted.ToolTip = OptimizationExplanationText;
	Items.ScheduledJobsListExecuted.Title = "Executed" + ?(Counter = Count, "", "*");
	Items.ScheduledJobsListState.ToolTip = OptimizationExplanationText;
	Items.ScheduledJobsListState.Title = "State" + ?(Counter = Count, "", "*");
	
EndProcedure

&AtClient
Procedure Schedule(Command)
	SelectedRows = Items.ScheduledJobsList.SelectedRows;
	If SelectedRows.Count() > 0 Then
		
		Row = ScheduledJobsList.FindByID(SelectedRows.Get(0));
		Schedule = GetScheduledJobSchedule(Row.ID);
		Dialog = New ScheduledJobDialog(Schedule);
		OnCloseNotifyHandler = New NotifyDescription("ScheduledJobDialogOnClose", ThisForm);
		
		Dialog.Show(OnCloseNotifyHandler);

	EndIf;
EndProcedure

&AtServer
Function GetScheduledJobSchedule(UniqueJobNumber)
	JobObject = ScheduledJobs.FindByUUID(UniqueJobNumber);
	If JobObject = Undefined Then
		Return New JobSchedule;
	EndIf;
	
	Return JobObject.Schedule;
EndFunction

&AtClient
Procedure ScheduledJobDialogOnClose(Schedule, AdditionalParameters) Export
	If Schedule <> Undefined Then
		SelectedRows = Items.ScheduledJobsList.SelectedRows;
		If SelectedRows.Количество() > 0 Then
			Row = ScheduledJobsList.FindByID(SelectedRows.Get(0));
			SetScheduledJobSchedule(Row.ID, Row.Description, Schedule, Row.Metadata);
			Row.Schedule = Schedule;
		EndIf;
	EndIf;
EndProcedure

&AtServer
Function SetScheduledJobSchedule(ID, Description, Schedule, JobName)
	JobObject = ScheduledJobs.FindByUUID(ID);
	If JobObject = Undefined Then
		EditedJobObject = ScheduledJobs.CreateScheduledJob(JobName);
		EditedJobObject.Description = Description;
		EditedJobObject.Use = True;
	Else
		EditedJobObject = JobObject;
	EndIf;
	
	EditedJobObject.Schedule = Schedule;
	Try
		EditedJobObject.Write();
	Except
		Raise "Schedule saving error. Perhaps the schedule data has been changed. Close settings form and try again.
		|Detailed error description : " + ErrorDescription();
	EndTry;
	
	Return True;
EndFunction

&AtClient
Procedure ScheduledJobsListSettings(Command)
	ParametersStructure = New Structure;
	ParametersStructure.Insert("AutoUpdate", ScheduledJobsListAutoUpdate);
	ParametersStructure.Insert("AutoUpdatePeriod", ScheduledListAutoUpdatePeriod);
	
	OnCloseNotifyHandler = New NotifyDescription("ScheduledJobsListSettingsOnClose", ThisForm);
	
	OpenForm(GetFullFormName("ListSettingsDialog"), ParametersStructure, ThisForm, , , , OnCloseNotifyHandler, FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure ScheduledJobsListSettingsOnClose(Result, AdditionalParameters) Export
	If TypeOf(Result) = Type("Structure") Then
		ScheduledJobsListAutoUpdate = Result.AutoUpdate;
		ScheduledListAutoUpdatePeriod = Result.AutoUpdatePeriod;
		
		DetachIdleHandler("ScheduledJobsAutoUpdateHandler");
		If ScheduledJobsListAutoUpdate = True Then
			AttachIdleHandler("ScheduledJobsAutoUpdateHandler", ScheduledListAutoUpdatePeriod);	
		EndIf;
		Items.ScheduledJobsListSettings.Check = ScheduledJobsListAutoUpdate;
	EndIf;
EndProcedure

&AtClient
Procedure ExecuteManually(Command)
	CurrentRow = Items.ScheduledJobsList.CurrentData;
	If CurrentRow <> Undefined Then
		ExecuteManuallyAtServer(CurrentRow.ID);
	EndIf;
EndProcedure

&AtServer
Procedure ExecuteManuallyAtServer(UUID)
	ID = New UUID(UUID);
	Job = ScheduledJobs.FindByUUID(ID);
	
	MethodName = Job.Metadata.MethodName;
		
	// Preparing a command to run a method instead of a background job.
	ParametersString = "";
	Index = 0;
	While Index < Job.Parameters.Count() Do
		ParametersString = ParametersString + "Job.Parameters[" + Index + "]";
		If Index < (Job.Parameters.Количество() - 1) Then
			ParametersString = ParametersString + ",";
		EndIf;
		Index = Index + 1;
	EndDo;
	
	Execute("" + MethodName + "(" + ParametersString + ");");

EndProcedure

&AtClient
Procedure Run(Command)
	CurrentRow = Items.ScheduledJobsList.CurrentData;
	If CurrentRow <> Undefined Then
		RunAtServer(CurrentRow.ID);
	EndIf;
EndProcedure

&AtServer
Procedure RunAtServer(UUID)
	
	ID = New UUID(UUID);
	Job = ScheduledJobs.FindByUUID(ID);
		
	// Cheching for current execution.
	Filter = New Structure;
	Filter.Insert("Key", String(Job.UUID));
	Filter.Insert("State ", BackgroundJobState.Active);		
	JobsArray = BackgroundJobs.GetBackgroundJobs(Filter);
	
	NewJobID = Undefined;
	
	If JobsArray.Count() = 0 Then 
		BackgroundJobDescription = "Run manually: " + Job.Metadata.Synonym;
		BackgroundJob = BackgroundJobs.Execute(Job.Metadata.MethodName, Job.Parameters, String(Job.UUID), BackgroundJobDescription);
		NewJobID = BackgroundJob.UUID;
	Else
		NotifyUser("The job has already started.");
	EndIf;
		
	RefreshScheduledJobsList();
	BackgroundJobsListRefresh(NewJobID);
EndProcedure

&AtClient
Procedure EventLog(Command)
    EventLogFormName = "ExternalDataProcessor.StandardEventLog.Form";
    ConnectExternalDataProcessorAtServer();
    OpenForm(EventLogFormName);
EndProcedure

&AtServer
Procedure ConnectExternalDataProcessorAtServer()
	// BSLLS:UsingExternalCodeTools-off
	// https://github.com/1c-syntax/bsl-language-server/issues/1283
    ExternalDataProcessors.Connect("v8res://mngbase/StandardEventLog.epf", "StandardEventLog", True);
	// BSLLS:UsingExternalCodeTools-on
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region BackgroundJobsListEventHandlers

&AtClient
Procedure BackgroundJobsListBeforeAddRow(Item, Cancel, Clone, Parent, Folder)
	Cancel = True;
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("JobID", "");
	If Clone Then
		CurrentData = Items.BackgroundJobsList.CurrentData;
		If CurrentData <> Undefined Then
			ParametersStructure.Вставить("MethodName", CurrentData.Method);
			ParametersStructure.Вставить("Description", CurrentData.Description);
			ParametersStructure.Вставить("Key", CurrentData.Key);
		EndIf;
	EndIf;

	OnCloseNotifyHandler = New NotifyDescription("BackgroundJobsListRowAddOnClose", ThisForm);
	
	OpenForm(GetFullFormName("BackgroundJobDialog"), ParametersStructure, ThisForm, , , , OnCloseNotifyHandler, FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure BackgroundJobsListRowAddOnClose(Result, AdditionalParameters) Export
	Если Result <> Undefined Then
	    BackgroundJobsListRefresh();			
	EndIf;
EndProcedure

&AtClient
Procedure BackgroundJobsListBeforeRowChange(Item, Cancel)
	Cancel = True;
EndProcedure

&AtClient
Procedure BackgroundJobsListBeforeDelete(Item, Cancel)
	Cancel = True;
EndProcedure

&AtClient
Procedure BackgroundJobsListSelection(Item, SelectedRow, Field, StandardProcessing)
	If Field.Name = "BackgroundJobsListMessages" Then
		BackgroundJobsListMessagesSelectionAtServer(SelectedRow);
	EndIf;
EndProcedure

&AtServer
Procedure BackgroundJobsListMessagesSelectionAtServer(RowID)
	CurrentRow = BackgroundJobsList.FindByID(RowID);
	Background = BackgroundJobs.FindByUUID(CurrentRow.ID);
	If Background <> Undefined Then
		UserMessages = Background.GetUserMessages();
		For Each Message In UserMessages Do
			NotifyUser(Message.Text);
		EndDo;
	EndIf;
EndProcedure

#EndRegion

#Region ScheduledJobsListCommandHandlers

&AtClient
Procedure CancelBackgroundJob(Command)
	Try
		CancelBackgroundJobs();
		BackgroundJobsListRefresh();
	Except	
		ErrorText = ErrorDescription();
		NotifyUser(ErrorText);
	EndTry;
EndProcedure

&AtServer
Procedure CancelBackgroundJobs()
	SelectedRows = Items.BackgroundJobsList.SelectedRows;
	For Each Row In SelectedRows Do
		SelectedRow = BackgroundJobsList.FindByID(Row);
		CurrentID = New UUID(SelectedRow.ID);
		BackgroundJob = BackgroundJobs.FindByUUID(CurrentID);
		BackgroundJob.Cancel();
	EndDo;
EndProcedure

&AtClient
Procedure SetBackgroundJobsFilter(Command)
	ParametersStructure = New Structure;
	ParametersStructure.Insert("Filter", BackgroundJobsFilter);
	
	OnCloseNotifyHandler = New NotifyDescription("SetBackgroundJobsFilterOnClose", ThisForm);
	
	OpenForm(GetFullFormName("BackgroundJobFilterDialog"), ParametersStructure, ThisForm, , , , OnCloseNotifyHandler, FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure SetBackgroundJobsFilterOnClose(Result, AdditionalParameters) Export
	If TypeOf(Result) = Type("ValueStorage") Then
		BackgroundJobsFilter = Result;
		BackgroundJobsFilterEnabled = True;
		BackgroundJobsListRefresh();
	EndIf;
EndProcedure

&AtClient
Procedure FilterByCurrent(Command)
	CurrentRowID = Items.ScheduledJobsList.CurrentRow;
	If CurrentRowID <> Undefined Then
		FilterByCurrentAtServer(CurrentRowID);
	EndIf;
EndProcedure

&AtServer
Procedure FilterByCurrentAtServer(CurrentRowID)
	CurrentJob = ScheduledJobsList.FindByID(CurrentRowID);
	
	CurrentFilter = New Structure;
	
	Scheduled = ScheduledJobs.FindByUUID(CurrentJob.ID);
	CurrentFilter.Insert("ScheduledJob", Scheduled);

	BackgroundJobsFilter = New ValueStorage(CurrentFilter);
	BackgroundJobsFilterEnabled = True;
	BackgroundJobsListRefresh();

EndProcedure

&AtClient
Procedure DisableBackgroundJobsFilter(Command)
	FilterOnOpen();
	BackgroundJobsListRefresh();
EndProcedure

&AtClient
Procedure RefreshBackgroundJobs(Command)
	BackgroundJobsListRefresh();
EndProcedure

&AtServer
Procedure BackgroundJobsListRefresh(NewJobID = Undefined)
	Var CurrentID;

	CurrentRow = Items.BackgroundJobsList.CurrentRow;
	If CurrentRow <> Undefined Then
		CurRow = BackgroundJobsList.FindByID(CurrentRow);
		CurrentID = CurRow.ID;
	EndIf;
	
	If ValueIsFilled(NewJobID) Then
		CurrentID = NewJobID;
	EndIf;
	
	IDs = New Array;
	
	SelectedRows = Items.BackgroundJobsList.SelectedRows;
	For Each SelectedRow In SelectedRows Do
		CurRow = BackgroundJobsList.FindByID(SelectedRow);
		IDs.Add(CurRow.ID);
	EndDo;

	BackgroundJobsList.Clear();
	
	PutBackgroundJobs();
	
	If CurrentID <> Undefined Then
		Rows = BackgroundJobsList.FindRows(New Structure("ID", CurrentID));
		If Rows.Count() > 0 Then
			Items.BackgroundJobsList.CurrentRow = Rows[0].GetID();
		EndIf;
	EndIf;

	If IDs.Count() > 0 Then
		SelectedRows.Clear();
	EndIf;
	
	For Each ID Из IDs Do
		Rows = BackgroundJobsList.FindRows(New Structure("ID", ID));
		If Rows.Count() > 0 Then
			SelectedRows.Add(Rows[0].GetID());
		EndIf;
	EndDo;
	
EndProcedure

&AtServer
Procedure PutBackgroundJobs()
	
	Filter = GetBackgroundJobsFilter();
	
	Try
		Background_ = BackgroundJobs.GetBackgroundJobs(Filter);
	Except
		ErrorText = ErrorDescription();
		NotifyUser(ErrorText);
		Return;
	EndTry;
	
	For Each Background In Background_ Do
		NewRow = BackgroundJobsList.Add();
		
		NewRow.Messages = Background.GetUserMessages().Count();
		Rows = ScheduledJobsList.FindRows(New Structure("Method, Description", Background.MethodName, Background.Description));
		If Rows.Count() > 0 Then
			If BackgroundJobsList.IndexOf(NewRow) = 0 Then
				Rows[0].Executed = Background.Begin;
				Rows[0].State = Background.State;
			EndIf;
			ScheduledJobName = Rows[0].Metadata + ":" + Rows[0].Description;
			NewRow.Scheduled = ScheduledJobName;
		Else
			NewRow.Scheduled = Background.UUID;
		EndIf;
			
		NewRow.Description = Background.Description;
		NewRow.Key = Background.Key;
		NewRow.Method = Background.MethodName;
		NewRow.State = Background.State;
		NewRow.Begin = Background.Begin;
		NewRow.End = Background.End;
		NewRow.Server = Background.Location;
		
		If Background.ErrorInfo <> Undefined Then
			NewRow.Errors = Background.ErrorInfo.Description;
		EndIf;
		
		NewRow.ID = Background.UUID;
		NewRow.JobState = Background.State;
	EndDo;
		
EndProcedure

&AtServer
Function GetBackgroundJobsFilter()
	Filter = Undefined;
	FilterRow = "";
	If BackgroundJobsFilterEnabled = True Then
		Filter = BackgroundJobsFilter.Get();
		For Each Item In Filter Do
			If FilterRow <> "" Then
				 FilterRow = FilterRow + ";";
			EndIf;
			FilterRow = FilterRow + Item.Key + ": " + Item.Value;
		EndDo;
		If FilterRow <> "" Then
			FilterRow = " (" + FilterRow + ")";
		EndIf;
	EndIf;
	Items.BackgroundJobs.Title = "Background jobs" + FilterRow;
	Return Filter;
EndFunction

&AtClient
Procedure BackgroundJobsListSettings(Command)
	
	ParametersStructure = New Structure;
	ParametersStructure.Insert("AutoUpdate", BackgroundJobsListAutoUpdate);
	ParametersStructure.Insert("AutoUpdatePeriod", BackgroundListAutoUpdatePeriod);
	
	OnCloseNotifyHandler = New NotifyDescription("BackgroundJobsListSettingsOnClose", ThisForm);
	
	OpenForm(GetFullFormName("ListSettingsDialog"), ParametersStructure, ThisForm, , , , OnCloseNotifyHandler, FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure BackgroundJobsListSettingsOnClose(Result, AdditionalParameters) Export
	If TypeOf(Result) = Type("Structure") Then
		BackgroundJobsListAutoUpdate = Result.AutoUpdate;
		BackgroundListAutoUpdatePeriod = Result.AutoUpdatePeriod;
		
		DetachIdleHandler("BackgroundJobsAutoUpdateHandler");
		If BackgroundJobsListAutoUpdate = True Then
			AttachIdleHandler("BackgroundJobsAutoUpdateHandler", BackgroundListAutoUpdatePeriod);	
		EndIf;
		
		Items.BackgroundJobsListSettings.Check = BackgroundJobsListAutoUpdate;
	EndIf;
EndProcedure

#EndRegion
