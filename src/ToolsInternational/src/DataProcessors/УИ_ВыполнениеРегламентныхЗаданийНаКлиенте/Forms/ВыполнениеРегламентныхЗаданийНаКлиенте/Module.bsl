#Region FormEventHandlers

&AtServer	
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	SetConditionalAppearance();

	If Parameters.Property("AutoTest") Then // Return upon receipt of the form for analysis.
		Return;
	EndIf;

	UpdateScheduledJobsTable();
	ExecutionCheckTimeInterval = 5; // 5 seconds.

	SelectionParameters = New Structure;
	SelectionParameters.Insert("ToPerform", True);
	Included = TableOfScheduledJobs.FindRows(SelectionParameters).Count();

	If Included <> 0 Then
		Items.StatusBar.Title = SubstituteParametersIntoTheString(
			NStr("ru = 'Отмеченные регламентные задания выполняются на этом клиентском компьютере (%1)...';en = 'Marked scheduled jobs are running on this client computer (%1)...'"), Included);
	EndIf;

	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);

EndProcedure

&AtClient
Procedure OnOpen(Cancel)

#If Not ThickClientOrdinaryApplication Then

#EndIf

	RemainingBeforeExecutionStarts = ExecutionCheckTimeInterval + 1;
	CompleteScheduledJobs();

EndProcedure

#EndRegion

#Region FormElementEventHandlers

&AtClient
Procedure TableOfScheduledJobsToPerformOnChange(Item)
	CurrentData = Items.ScheduledJobs.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	EditUseScheduledJob(CurrentData.ID, CurrentData.ToPerform);

	SelectionParameters = New Structure;
	SelectionParameters.Insert("ToPerform", True);
	Included = TableOfScheduledJobs.FindRows(SelectionParameters).Count();

	If Included = 0 Then
		Items.StatusBar.Title = NStr(
			"ru = 'Отметьте регламентные задания для выполнения на клиентском компьютере...';en = 'Mark scheduled tasks to run on the client computer...'");
	Else
		Items.StatusBar.Title = SubstituteParametersIntoTheString(
			NStr("ru = 'Отмеченные регламентные задания выполняются на этом клиентском компьютере (%1)...';en = 'Marked scheduled jobs run on this client computer (%1)...'"), Included);
	EndIf;

EndProcedure

&AtServer
Procedure EditUseScheduledJob(ID, ToPerform)

	Properties = CommonSettingsStorage.Load("StateOfTheScheduledJob_" + String(ID), , , "");

	Properties = ?(TypeOf(Properties) = Type("ValueStorage"), Properties.Get(), Undefined);
	If Properties = Undefined Then
		Properties = EmptyPropertyTableBackgroundJobs().Add();
		Properties.ScheduledJobUUID = ID;
		Properties = RowTableValuesInStructure(Properties);
	EndIf;
	Properties.ToPerform = ToPerform;
	StoredValue = New ValueStorage(Properties);
	CommonSettingsStorage.Save("StateOfTheScheduledJob_" + String(ID), , StoredValue, ,
		"");

EndProcedure

#EndRegion

#Region CommandFormEventHandlers

&AtClient
Procedure StopExecution(Command)

	Close();

EndProcedure

&AtClient
Procedure ClearNumberOfRuns(Command)

	CurrentData = Items.ScheduledJobs.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	ClearQuantityOfRunsAtServer(CurrentData.ID);

EndProcedure

&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) Export
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure SetConditionalAppearance()

	ConditionalAppearance.Items.Clear();
	
	//
	Item = ConditionalAppearance.Items.Add();

	ItemField = Item.Fields.Items.Add();
	ItemField.Field = New DataCompositionField(Items.TableOfScheduledJobsDone.Name);

	SelectionItem = Item.Filter.Items.Add(Type("DataCompositionFilterItem"));
	SelectionItem.LeftValue  = New DataCompositionField("TableOfScheduledJobs.Changed");
	SelectionItem.ComparisonType   = DataCompositionComparisonType.Equal;
	SelectionItem.RightValue = True;

	Item.Appearance.SetParameterValue("Text", New Color(128, 122, 89));

EndProcedure

&AtServer
Procedure ClearQuantityOfRunsAtServer(ID)

	Properties = CommonSettingsStorage.Load("StateOfTheScheduledJob_" + String(ID), , , "");

	Properties = ?(TypeOf(Properties) = Type("ValueStorage"), Properties.Get(), Undefined);
	If Properties = Undefined Then
		Return;
	EndIf;
	Properties.AttemptToRestart = 0;
	CommonSettingsStorage.Save("StateOfTheScheduledJob_" + String(ID), ,
		New ValueStorage(Properties), , "");

EndProcedure

&AtClient
Procedure CompleteScheduledJobs()

	RemainingBeforeExecutionStarts = RemainingBeforeExecutionStarts - 1;
	If RemainingBeforeExecutionStarts <= 0 Then

		RemainingBeforeExecutionStarts = ExecutionCheckTimeInterval;
		RefreshDataRepresentation();

		CompleteScheduledJobsAtServer(LaunchParameter);
	EndIf;

	AttachIdleHandler("CompleteScheduledJobs", 1, True);

EndProcedure

&AtServer
Procedure UpdateScheduledJobsTable()

	SetPrivilegedMode(True);
	CurrentJobs = ScheduledJobs.GetScheduledJobs();

	NewTableJobs = FormAttributeToValue("TableOfScheduledJobs");
	NewTableJobs.Clear();

	For Each Job In CurrentJobs Do
		RowJob = NewTableJobs.Add();

		RowJob.ScheduledJob = RepresentationScheduledJob(Job);
		RowJob.Done     = Date(1, 1, 1);
		RowJob.ID = Job.UUID;

		PropertiesLastBackgroundJob = PropertiesLastBackgroundJobRunningRegularJob(Job);

		If PropertiesLastBackgroundJob <> Undefined Then
			If ValueIsFilled(PropertiesLastBackgroundJob.End) Then
				RowJob.Done = PropertiesLastBackgroundJob.End;
				RowJob.Status = String(PropertiesLastBackgroundJob.Status);
			EndIf;

			RowJob.ToPerform = PropertiesLastBackgroundJob.ToPerform;
		EndIf;

		PropertiesJob = TableOfScheduledJobs.FindRows(
			New Structure("ID", RowJob.ID));

		RowJob.Changed = (PropertiesJob = Undefined) Or (PropertiesJob.Count() = 0)
			Or (PropertiesJob[0].Done <> RowJob.Done);
	EndDo;

	NewTableJobs.Sort("ScheduledJob");

	NumberJob = 1;
	For Each RowJob In NewTableJobs Do
		RowJob.Number = NumberJob;
		NumberJob = NumberJob + 1;
	EndDo;

	ValueToFormAttribute(NewTableJobs, "TableOfScheduledJobs");

EndProcedure

&AtClient
Procedure CompleteScheduledJobsAtServer(LaunchParameter)
#If ThickClientOrdinaryApplication Then 
	RunTheExectutionSheduledJobs(ThisObject.TableOfScheduledJobs);
	UpdateScheduledJobsTable();
#EndIf
EndProcedure

&AtClientAtServerNoContext
Procedure RunTheExectutionSheduledJobs(TableOfScheduledJobs)
#If Server Or ThickClientOrdinaryApplication Then
	CallExceptionIfNoAdministrativeRights();
	SetPrivilegedMode(True);

	Status = StateOfCompletionScheduledJobs();

	ExecutionTimestamp = ?(TypeOf(ExecutionTimestamp) = Type("Number"), ExecutionTimestamp, 0);

	Jobs                        = ScheduledJobs.GetScheduledJobs();
	ExecutionCompleted            = False; // Specifies that the ExecutionTimestamp has ended,
	                                       // or that all possible scheduled jobs have been completed.
	StartOf Execution               = CurrentSessionDate();
	NumberOfCompletedJobs   = 0;
	BackgroundJobRunning      = False;
	LastJobID = Status.IDNextJob;

	// Job Count is checked each time execution starts,
	// because jobs can be deleted in another session, and then there will be a loop.
	While Not ExecutionCompleted And Jobs.Count() > 0 Do
		FirstJobFound           = (LastJobID = Undefined);
//		NextJobFound        = False;
		For Each Job In Jobs Do
			SelectionParameters = New Structure;
			SelectionParameters.Insert("ID", Job.UUID);
			Result = TableOfScheduledJobs.FindRows(SelectionParameters);
			JobEnabled = Result[0].ToPerform;
			
			// End of execution if:
			// а) time is set and out;
			// б) time is not set and at least one sheduled job is executed;
			// в) time is not set and all scheduled job are completed in quantity.
			If (ExecutionTimestamp = 0 And (BackgroundJobRunning Or NumberOfCompletedJobs
				>= Jobs.Count())) Or (ExecutionTimestamp <> 0 And StartOf Execution + ExecutionTimestamp
				<= CurrentSessionDate()) Then
				ExecutionCompleted = True;
				Break;
			EndIf;
			If Not FirstJobFound Then
				If String(Job.UUID) = LastJobID Then
				   // The last executed scheduled task was found, which means that the next scheduled job
				   // needs to be checked for the need to execute a background job.
					FirstJobFound = True;
				EndIf;
				// If the first scheduled task to be checked for the need to execute a background job
				// has not yet been found, then the current job is skipped.
				Continue;
			EndIf;
//			NextJobFound = True;
			NumberOfCompletedJobs = NumberOfCompletedJobs + 1;
			Status.IDNextJob       = String(Job.UUID);
			Status.BeginningOfTheNextJob    = CurrentSessionDate();
			Status.FinishingTheNextJob = '00010101';
			SaveStateOfCompletionScheduledJobs(Status, "IDNextJob,
																	   |BeginningOfTheNextJob,
																	   |FinishingTheNextJob");
			If JobEnabled Then
				ExecuteScheduledJob = False;
				PropertiesLastBackgroundJob = PropertiesLastBackgroundJobRunningRegularJob(
					Job);

				If PropertiesLastBackgroundJob <> Undefined And PropertiesLastBackgroundJob.Status
					= BackgroundJobState.Failed Then
					// Checking the emergency schedule.
					If PropertiesLastBackgroundJob.AttemptToRestart
						<= Job.RestartCountOnFailure Then
						If PropertiesLastBackgroundJob.End + Job.RestartIntervalOnFailure
							<= CurrentSessionDate() Then
						    // Restarting a background job by a scheduled job.
							ExecuteScheduledJob = True;
						EndIf;
					EndIf;
				Else
					// Checking the standard schedule.
					ExecuteScheduledJob = Job.Schedule.ExecutionRequired(
						CurrentSessionDate(), ?(PropertiesLastBackgroundJob = Undefined, '00010101',
						PropertiesLastBackgroundJob.Begin), ?(PropertiesLastBackgroundJob = Undefined,
						'00010101', PropertiesLastBackgroundJob.End));
				EndIf;
				If ExecuteScheduledJob Then
					BackgroundJobRunning = ExecuteScheduledJob(Job);
				EndIf;
			EndIf;
			Status.FinishingTheNextJob = CurrentSessionDate();
			SaveStateOfCompletionScheduledJobs(Status, "FinishingTheNextJob");
		EndDo;
		// If the last executed task could not be found, then
		// its ID is reset,
		// to start checking scheduled tasks starting from the first.
		LastJobID = Undefined;
	EndDo;

#EndIf
EndProcedure

&AtServerNoContext
Function ExecuteScheduledJob(Val Job)
	RunManually = False;
	StartUpMoment = Undefined;
	MomentOfTheEnd = Undefined;
	//@skip-warning
	SessionNumber = Undefined;
	//@skip-warning
	SessionStarted = Undefined;
//	
	PropertiesLastBackgroundJob = PropertiesLastBackgroundJobRunningRegularJob(Job);

	If PropertiesLastBackgroundJob <> Undefined And PropertiesLastBackgroundJob.Status
		= BackgroundJobState.Active Then

		SessionNumber  = PropertiesLastBackgroundJob.SessionNumber;
		SessionStarted = PropertiesLastBackgroundJob.SessionStarted;
		Return False;
	EndIf;

	MethodName = Job.Metadata.MethodName;
	DescriptionSheduledJob = SubstituteParametersIntoTheString(
		?(RunManually, NStr("ru = 'Запуск вручную: %1';en = 'Manual start: %1'"), NStr("ru = 'Автозапуск: %1';en = 'Autostart: %1'")),
		RepresentationScheduledJob(Job));

	StartUpMoment = ?(TypeOf(StartUpMoment) <> Type("Date") Or Not ValueIsFilled(StartUpMoment),
		CurrentSessionDate(), StartUpMoment);
	
	// Creating properties of a new background pseudo-job.
	BackgroundJobProperties = EmptyPropertyTableBackgroundJobs().Add();
	BackgroundJobProperties.ToPerform = PropertiesLastBackgroundJob.ToPerform;
	BackgroundJobProperties.ID  = String(New UUID);
	BackgroundJobProperties.AttemptToRestart = ?(
		PropertiesLastBackgroundJob <> Undefined And PropertiesLastBackgroundJob.Status
		= BackgroundJobState.Failed, PropertiesLastBackgroundJob.AttemptToRestart + 1, 1);
	BackgroundJobProperties.Title                      = DescriptionSheduledJob;
	BackgroundJobProperties.ScheduledJobUUID = String(Job.UUID);
	BackgroundJobProperties.Placement                      = "\\" + ComputerName();
	BackgroundJobProperties.MethodName                         = MethodName;
	BackgroundJobProperties.Status                         = BackgroundJobState.Active;
	BackgroundJobProperties.Begin                            = StartUpMoment;
	BackgroundJobProperties.SessionNumber                       = InfoBaseSessionNumber();

	For Each Session In GetInfoBaseSessions() Do
		If Session.SessionNumber = BackgroundJobProperties.SessionNumber Then
			BackgroundJobProperties.SessionStarted = Session.SessionStarted;
			Break;
		EndIf;
	EndDo;
	
	// Save startup information.
	StoredValue = New ValueStorage(RowTableValuesInStructure(BackgroundJobProperties));
	CommonSettingsStorage.Save("StateOfTheScheduledJob_" + String(Job.UUID), ,
		StoredValue, , "");

	GetUserMessages(True);
	Try
		// There is no possibility of executing arbitrary code here, because the method is taken from the metadata of the scheduled job.
		ExecuteMethodConfiguration(MethodName, Job.Parameters);
		BackgroundJobProperties.Status = BackgroundJobState.Finished;
	Except
		BackgroundJobProperties.Status = BackgroundJobState.Failed;
		BackgroundJobProperties.DescriptionErrorInformation = DetailErrorDescription(ErrorInfo());
	EndTry;
	
	// Fixing the end of method execution.
	MomentOfTheEnd = CurrentSessionDate();
	BackgroundJobProperties.End = MomentOfTheEnd;
	BackgroundJobProperties.MessagesToUser = New Array;
	For Each Message In GetUserMessages() Do
		BackgroundJobProperties.MessagesToUser.Add(Message);
	EndDo;
	GetUserMessages(True);

	Properties = CommonSettingsStorage.Load("StateOfTheScheduledJob_" + String(
		Job.UUID), , , "");
	Properties = ?(TypeOf(Properties) = Type("ValueStorage"), Properties.Get(), Undefined);

	If TypeOf(Properties) <> Type("Structure") Or Not Properties.Property("SessionNumber") Or Not Properties.Property(
		"SessionStarted") Or (Properties.SessionNumber = BackgroundJobProperties.SessionNumber And Properties.SessionStarted
		= BackgroundJobProperties.SessionStarted) Then
		// The unlikely overwrite due to lack of a lock did not occur, so properties can be written.
		StoredValue = New ValueStorage(RowTableValuesInStructure(BackgroundJobProperties));
		CommonSettingsStorage.Save("StateOfTheScheduledJob_" + String(Job.UUID), ,
			StoredValue, , "");
	EndIf;

	Return True;
EndFunction

&AtServerNoContext
Function StateOfCompletionScheduledJobs()
	// Preparing data for validation or initial setting of read state properties.
	NewStructure = New Structure;
	// Location of scheduled job execution history.
	NewStructure.Insert("SessionNumber", 0);
	NewStructure.Insert("SessionStarted", '00010101');
	NewStructure.Insert("ComputerName", "");
	NewStructure.Insert("ApplicationName", "");
	NewStructure.Insert("UserName", "");
	NewStructure.Insert("IDNextJob", "");
	NewStructure.Insert("BeginningOfTheNextJob", '00010101');
	NewStructure.Insert("FinishingTheNextJob", '00010101');

	Status = CommonSettingsStorage.Load("StateOfCompletionScheduledJobs", , , "");
	Status = ?(TypeOf(Status) = Type("ValueStorage"), Status.Get(), Undefined);
	
	// Copy existing properties.
	If TypeOf(Status) = Type(NewStructure) Then
		For Each KeyAndValue In NewStructure Do
			If Status.Property(KeyAndValue.Key) Then
				If TypeOf(NewStructure[KeyAndValue.Key]) = TypeOf(Status[KeyAndValue.Key]) Then
					NewStructure[KeyAndValue.Key] = Status[KeyAndValue.Key];
				EndIf;
			EndIf;
		EndDo;
	EndIf;

	Return NewStructure;
EndFunction

&AtClientAtServerNoContext
Procedure SaveStateOfCompletionScheduledJobs(Status, Val ChangedProperties = Undefined)
#If Server Or ThickClientOrdinaryApplication Then
	If ChangedProperties <> Undefined Then
		CurrentState = StateOfCompletionScheduledJobs();
		FillPropertyValues(CurrentState, Status, ChangedProperties);
		Status = CurrentState;
	EndIf;

	CommonSettingsStorage.Save("StateOfCompletionScheduledJobs", , New ValueStorage(Status), ,
		"");
#EndIf
EndProcedure

&AtServerNoContext
Function PropertiesLastBackgroundJobRunningRegularJob(ScheduledJob)
	CallExceptionIfNoAdministrativeRights();
	SetPrivilegedMode(True);

	ScheduledJobID = ?(TypeOf(ScheduledJob) = Type("ScheduledJob"), String(
		ScheduledJob.UUID), ScheduledJob);
	Filter = New Structure;
	Filter.Insert("ScheduledJobUUID", ScheduledJobID);
	Filter.Insert("GetLastBackgroundJobScheduledJob");
	PropertyTableSheduledJobs = GetSheduledJobsPropertyTable(Filter);
	PropertyTableSheduledJobs.Sort("End Asc");

	If PropertyTableSheduledJobs.Count() = 0 Then
		BackgroundJobProperties = Undefined;
	ElsIf Not ValueIsFilled(PropertyTableSheduledJobs[0].End) Then
		BackgroundJobProperties = PropertyTableSheduledJobs[0];
	Else
		BackgroundJobProperties = PropertyTableSheduledJobs[PropertyTableSheduledJobs.Count() - 1];
	EndIf;

	StoredValue = New ValueStorage(?(BackgroundJobProperties = Undefined, Undefined,
		RowTableValuesInStructure(BackgroundJobProperties)));
	CommonSettingsStorage.Save("StateOfTheScheduledJob_" + ScheduledJobID, ,
		StoredValue, , "");

	Return BackgroundJobProperties;
EndFunction

&AtServerNoContext
Function GetSheduledJobsPropertyTable(Filter = Undefined)
	CallExceptionIfNoAdministrativeRights();
	SetPrivilegedMode(True);

	Table = EmptyPropertyTableBackgroundJobs();

	If Filter <> Undefined And Filter.Property("GetLastBackgroundJobScheduledJob") Then
		Filter.Delete("GetLastBackgroundJobScheduledJob");
		//@skip-warning
		GetLast = True;
	Else
		GetLast = False;
	EndIf;

	ScheduledJob = Undefined;

	If Filter <> Undefined And Filter.Property("ScheduledJobUUID") Then
		ScheduledJobsForProcessingArray = New Array;
		If Filter.ScheduledJobUUID <> "" Then
			If ScheduledJob = Undefined Then
				ScheduledJob = ScheduledJobs.FindByUUID(
					New UUID(Filter.ScheduledJobUUID));
			EndIf;
			If ScheduledJob <> Undefined Then
				ScheduledJobsForProcessingArray.Add(ScheduledJob);
			EndIf;
		EndIf;
	Else
		ScheduledJobsForProcessingArray = ScheduledJobs.GetScheduledJobs();
	EndIf;
	
	// Create and save scheduled job states
	For Each ScheduledJob In ScheduledJobsForProcessingArray Do
		ScheduledJobID = String(ScheduledJob.UUID);
		Properties = CommonSettingsStorage.Load("StateOfTheScheduledJob_"
			+ ScheduledJobID, , , "");
		Properties = ?(TypeOf(Properties) = Type("ValueStorage"), Properties.Get(), Undefined);

		If TypeOf(Properties) = Type("Structure") And Properties.ScheduledJobUUID = ScheduledJobID
			And Table.FindRows(New Structure("ID, AtServer", Properties.ID,
			Properties.AtServer)).Count() = 0 Then

			If Properties.AtServer Then
				CommonSettingsStorage.Save("StateOfTheScheduledJob_" + ScheduledJobID,
					, Undefined, , "");
			Else
				If Properties.Status = BackgroundJobState.Active Then
					FoundSessionPerformingJobs = False;
					For Each Session In GetInfoBaseSessions() Do
						If Session.SessionNumber = Properties.SessionNumber And Session.SessionStarted = Properties.SessionStarted Then
							FoundSessionPerformingJobs = InfoBaseSessionNumber() <> Session.SessionNumber;
							Break;
						EndIf;
					EndDo;
					If Not FoundSessionPerformingJobs Then
						Properties.End = CurrentSessionDate();
						Properties.Status = BackgroundJobState.Failed;
						Properties.DescriptionErrorInformation = NStr(
							"ru = 'Не найден сеанс, выполняющий процедуру регламентного задания.';en = 'A session performing the routine task procedure was not found.'");
					EndIf;
				EndIf;
				FillPropertyValues(Table.Add(), Properties);
			EndIf;
		EndIf;
	EndDo;
	Table.Sort("Begin Desc, End Desc");
	
	// Filter background jobs.
	If Filter <> Undefined Then
		Begin    = Undefined;
		End     = Undefined;
		Status = Undefined;
		If Filter.Property("Begin") Then
			Begin = ?(ValueIsFilled(Filter.Begin), Filter.Begin, Undefined);
			Filter.Delete("Begin");
		EndIf;
		If Filter.Property("End") Then
			End = ?(ValueIsFilled(Filter.End), Filter.End, Undefined);
			Filter.Delete("End");
		EndIf;
		If Filter.Property("Status") Then
			If TypeOf(Filter.Status) = Type("Array") Then
				Status = Filter.Status;
				Filter.Delete("Status");
			EndIf;
		EndIf;

		If Filter.Count() <> 0 Then
			Rows = Table.FindRows(Filter);
		Else
			Rows = Table;
		EndIf;
		// Performing additional filtering by period and state (if selection is defined).
		ElementNumber = Rows.Count() - 1;
		While ElementNumber >= 0 Do
			If Begin <> Undefined And Begin > Rows[ElementNumber].Begin Or End <> Undefined And End < ?(
				ValueIsFilled(Rows[ElementNumber].End), Rows[ElementNumber].End, CurrentSessionDate())
				Or Status <> Undefined And Status.Find(Rows[ElementNumber].Status) = Undefined Then
				Rows.Delete(ElementNumber);
			EndIf;
			ElementNumber = ElementNumber - 1;
		EndDo;
		// Delete extra rows from the table.
		If TypeOf(Rows) = Type("Array") Then
			LineNumber = Table.Count() - 1;
			While LineNumber >= 0 Do
				If Rows.Find(Table[LineNumber]) = Undefined Then
					Table.Delete(Table[LineNumber]);
				EndIf;
				LineNumber = LineNumber - 1;
			EndDo;
		EndIf;
	EndIf;

	Return Table;
EndFunction

&AtServerNoContext
Function EmptyPropertyTableBackgroundJobs()
	NewTable = New ValueTable;
	NewTable.Cols.Add("AtServer", New TypeDescription("Boolean"));
	NewTable.Cols.Add("ID", New TypeDescription("String"));
	NewTable.Cols.Add("Title", New TypeDescription("String"));
	NewTable.Cols.Add("Key", New TypeDescription("String"));
	NewTable.Cols.Add("Begin", New TypeDescription("Date"));
	NewTable.Cols.Add("End", New TypeDescription("Date"));
	NewTable.Cols.Add("ScheduledJobUUID", New TypeDescription("String"));
	NewTable.Cols.Add("Status", New TypeDescription("BackgroundJobState"));
	NewTable.Cols.Add("MethodName", New TypeDescription("String"));
	NewTable.Cols.Add("Placement", New TypeDescription("String"));
	NewTable.Cols.Add("DescriptionErrorInformation", New TypeDescription("String"));
	NewTable.Cols.Add("AttemptToRestart", New TypeDescription("Number"));
	NewTable.Cols.Add("MessagesToUser", New TypeDescription("Array"));
	NewTable.Cols.Add("SessionNumber", New TypeDescription("Number"));
	NewTable.Cols.Add("SessionStarted", New TypeDescription("Date"));
	NewTable.Cols.Add("ToPerform", New TypeDescription("Boolean"));
	NewTable.Indexes.Add("ID, Begin");

	Return NewTable;
EndFunction

&AtServerNoContext
Function RepresentationScheduledJob(Val Job) Export
	CallExceptionIfNoAdministrativeRights();

	If TypeOf(Job) = Type("ScheduledJob") Then
		ScheduledJob = Job;
	Else
		ScheduledJob = ScheduledJobs.FindByUUID(
			New UUID(Job));
	EndIf;

	If ScheduledJob <> Undefined Then
		Presentation = ScheduledJob.Title;

		If IsBlankString(ScheduledJob.Title) Then
			Presentation = ScheduledJob.Metadata.Synonym;

			If IsBlankString(Presentation) Then
				Presentation = ScheduledJob.Metadata.Name;
			EndIf;
		EndIf
		;
	Else
		Presentation = NStr("ru = '<не определено>';en = '<undefined>'");
	EndIf;

	Return Presentation;
EndFunction

&AtServerNoContext
Procedure CallExceptionIfNoAdministrativeRights() Export

	If Not PrivilegedMode() Then
		VerifyAccessRights("Administration", Metadata);
	EndIf;

EndProcedure

&AtClientAtServerNoContext
Function SubstituteParametersIntoTheString(Val SubstitutionString, Val Parameter1, Val Parameter2 = Undefined,
	Val Parameter3 = Undefined, Val Parameter4 = Undefined, Val Parameter5 = Undefined,
	Val Parameter6 = Undefined, Val Parameter7 = Undefined, Val Parameter8 = Undefined,
	Val Parameter9 = Undefined) Export

	SubstitutionString = StrReplace(SubstitutionString, "%1", Parameter1);
	SubstitutionString = StrReplace(SubstitutionString, "%2", Parameter2);
	SubstitutionString = StrReplace(SubstitutionString, "%3", Parameter3);
	SubstitutionString = StrReplace(SubstitutionString, "%4", Parameter4);
	SubstitutionString = StrReplace(SubstitutionString, "%5", Parameter5);
	SubstitutionString = StrReplace(SubstitutionString, "%6", Parameter6);
	SubstitutionString = StrReplace(SubstitutionString, "%7", Parameter7);
	SubstitutionString = StrReplace(SubstitutionString, "%8", Parameter8);
	SubstitutionString = StrReplace(SubstitutionString, "%9", Parameter9);

	Return SubstitutionString;
EndFunction

&AtClientAtServerNoContext
Procedure ExecuteMethodConfiguration(Val MethodName, Val Parameters = Undefined)

	ParametersString = "";
	If Parameters <> Undefined And Parameters.Count() > 0 Then
		For IndexOf = 0 To Parameters.UBound() Do
			ParametersString = ParametersString + "Parameters[" + IndexOf + "],";
		EndDo;
		ParametersString = Mid(ParametersString, 1, StrLen(ParametersString) - 1);
	EndIf;

	Execute MethodName + "(" + ParametersString + ")";

EndProcedure

&AtClientAtServerNoContext
Function RowTableValuesInStructure(ValueTableRow)

	Structure = New Structure;
	For Each Column In ValueTableRow.Owner().Cols Do
		Structure.Insert(Column.Name, ValueTableRow[Column.Name]);
	EndDo;

	Return Structure;

EndFunction

#EndRegion