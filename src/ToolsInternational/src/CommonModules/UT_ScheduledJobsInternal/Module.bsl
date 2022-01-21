#Region Internal

// Returns a new background job property table.
//
// Returns:
//  ValueTable.
//
Function NewBackgroundJobsProperties()
	
	NewTable = New ValueTable;
	NewTable.Columns.Add("ID",                     New TypeDescription("String"));
	NewTable.Columns.Add("Description",                      New TypeDescription("String"));
	NewTable.Columns.Add("Key",                              New TypeDescription("String"));
	NewTable.Columns.Add("Begin",                            New TypeDescription("Date"));
	NewTable.Columns.Add("End",                             New TypeDescription("Date"));
	NewTable.Columns.Add("ScheduledJobID", New TypeDescription("String"));
	NewTable.Columns.Add("State",                         New TypeDescription("BackgroundJobState"));
	NewTable.Columns.Add("MethodName",                         New TypeDescription("String"));
	NewTable.Columns.Add("Location",                      New TypeDescription("String"));
	NewTable.Columns.Add("ErrorDescription",        New TypeDescription("String"));
	NewTable.Columns.Add("StartAttempt",                    New TypeDescription("Number"));
	NewTable.Columns.Add("UserMessages",             New TypeDescription("Array"));
	NewTable.Columns.Add("SessionNumber",                       New TypeDescription("Number"));
	NewTable.Columns.Add("SessionStarted",                      New TypeDescription("Date"));
	NewTable.Indexes.Add("ID, Begin");
	
	Return NewTable;
	
EndFunction

Function LastBackgroundJobInArray(BackgroundJobArray, LastBackgroundJob = Undefined)
	
	For each CurrentBackgroundJob In BackgroundJobArray Do
		If LastBackgroundJob = Undefined Then
			LastBackgroundJob = CurrentBackgroundJob;
			Continue;
		EndIf;
		If ValueIsFilled(LastBackgroundJob.End) Then
			If NOT ValueIsFilled(CurrentBackgroundJob.End)
			 OR LastBackgroundJob.End < CurrentBackgroundJob.End Then
				LastBackgroundJob = CurrentBackgroundJob;
			EndIf;
		Else
			If NOT ValueIsFilled(CurrentBackgroundJob.End)
			   AND LastBackgroundJob.Begin < CurrentBackgroundJob.Begin Then
				LastBackgroundJob = CurrentBackgroundJob;
			EndIf;
		EndIf;
	EndDo;
	
	Return LastBackgroundJob;
	
EndFunction

Procedure AddBackgroundJobProperties(Val BackgroundJobArray, Val BackgroundJobPropertyTable)
	
	Index = BackgroundJobArray.Count() - 1;
	While Index >= 0 Do
		BackgroundJob = BackgroundJobArray[Index];
		Row = BackgroundJobPropertyTable.Add();
		FillPropertyValues(Row, BackgroundJob);
		Row.ID = BackgroundJob.UUID;
		ScheduledJob = BackgroundJob.ScheduledJob;
		
		If ScheduledJob = Undefined AND UT_StringFunctionsClientServer.IsUUID(
			BackgroundJob.Key) Then
			
			ScheduledJob = ScheduledJobs.FindByUUID(New UUID(BackgroundJob.Key));
		EndIf;
		Row.ScheduledJobID = ?(
			ScheduledJob = Undefined,
			"",
			ScheduledJob.UUID);
		
		Row.ErrorDescription = ?(
			BackgroundJob.ErrorInfo = Undefined,
			"",
			DetailErrorDescription(BackgroundJob.ErrorInfo));
		
		Index = Index - 1;
	EndDo;
	
EndProcedure

// Returns a background job property table.
//  See the table structure in the EmptyBackgroundJobPropertyTable() function.
// 
// Parameters:
//  Filter - Structure - valid fields:
//                 ID, Key, State, Beginning, End,
//                 Description, MethodName, and ScheduledJob.
//
// Returns:
//  ValueTable returns a table after filter.
//
Function BackgroundJobsProperties(Filter = Undefined) Export
	
	RaiseIfNoAdministrationRights();
	SetPrivilegedMode(True);
	
	Table = NewBackgroundJobsProperties();
	
	If ValueIsFilled(Filter) AND Filter.Property("GetLastScheduledJobBackgroundJob") Then
		Filter.Delete("GetLastScheduledJobBackgroundJob");
		GetLast = True;
	Else
		GetLast = False;
	EndIf;
	
	ScheduledJob = Undefined;
	
	// Adding the history of background jobs received from the server.
	If ValueIsFilled(Filter) AND Filter.Property("ScheduledJobID") Then
		If Filter.ScheduledJobID <> "" Then
			ScheduledJob = ScheduledJobs.FindByUUID(
				New UUID(Filter.ScheduledJobID));
			CurrentFilter = New Structure("Key", Filter.ScheduledJobID);
			BackgroundJobsStartedManually = BackgroundJobs.GetBackgroundJobs(CurrentFilter);
			If ScheduledJob <> Undefined Then
				LastBackgroundJob = ScheduledJob.LastJob;
			EndIf;
			If NOT GetLast OR LastBackgroundJob = Undefined Then
				CurrentFilter = New Structure("ScheduledJob", ScheduledJob);
				AutomaticBackgroundJobs = BackgroundJobs.GetBackgroundJobs(CurrentFilter);
			EndIf;
			If GetLast Then
				If LastBackgroundJob = Undefined Then
					LastBackgroundJob = LastBackgroundJobInArray(AutomaticBackgroundJobs);
				EndIf;
				
				LastBackgroundJob = LastBackgroundJobInArray(
					BackgroundJobsStartedManually, LastBackgroundJob);
				
				If LastBackgroundJob <> Undefined Then
					BackgroundJobArray = New Array;
					BackgroundJobArray.Add(LastBackgroundJob);
					AddBackgroundJobProperties(BackgroundJobArray, Table);
				EndIf;
				Return Table;
			EndIf;
			AddBackgroundJobProperties(BackgroundJobsStartedManually, Table);
			AddBackgroundJobProperties(AutomaticBackgroundJobs, Table);
		Else
			BackgroundJobArray = New Array;
			AllScheduledJobIDs = New Map;
			For each CurrentJob In ScheduledJobs.GetScheduledJobs() Do
				AllScheduledJobIDs.Insert(
					String(CurrentJob.UUID), True);
			EndDo;
			AllBackgroundJobs = BackgroundJobs.GetBackgroundJobs();
			For each CurrentJob In AllBackgroundJobs Do
				If CurrentJob.ScheduledJob = Undefined
				   AND AllScheduledJobIDs[CurrentJob.Key] = Undefined Then
				
					BackgroundJobArray.Add(CurrentJob);
				EndIf;
			EndDo;
			AddBackgroundJobProperties(BackgroundJobArray, Table);
		EndIf;
	Else
		If NOT ValueIsFilled(Filter) Then
			BackgroundJobArray = BackgroundJobs.GetBackgroundJobs();
		Else
			If Filter.Property("ID") Then
				Filter.Insert("UUID", New UUID(Filter.ID));
				Filter.Delete("ID");
			EndIf;
			BackgroundJobArray = BackgroundJobs.GetBackgroundJobs(Filter);
			If Filter.Property("UUID") Then
				Filter.Insert("ID", String(Filter.UUID));
				Filter.Delete("UUID");
			EndIf;
		EndIf;
		AddBackgroundJobProperties(BackgroundJobArray, Table);
	EndIf;
	
	If ValueIsFilled(Filter) AND Filter.Property("ScheduledJobID") Then
		ScheduledJobsForProcessing = New Array;
		If Filter.ScheduledJobID <> "" Then
			If ScheduledJob = Undefined Then
				ScheduledJob = ScheduledJobs.FindByUUID(
					New UUID(Filter.ScheduledJobID));
			EndIf;
			If ScheduledJob <> Undefined Then
				ScheduledJobsForProcessing.Add(ScheduledJob);
			EndIf;
		EndIf;
	Else
		ScheduledJobsForProcessing = ScheduledJobs.GetScheduledJobs();
	EndIf;
	
	Table.Sort("Begin Desc, End Desc");
	
	// Filtering background jobs.
	If ValueIsFilled(Filter) Then
		Start    = Undefined;
		End     = Undefined;
		State = Undefined;
		If Filter.Property("Begin") Then
			Start = ?(ValueIsFilled(Filter.Begin), Filter.Begin, Undefined);
			Filter.Delete("Begin");
		EndIf;
		If Filter.Property("End") Then
			End = ?(ValueIsFilled(Filter.End), Filter.End, Undefined);
			Filter.Delete("End");
		EndIf;
		If Filter.Property("State") Then
			If TypeOf(Filter.State) = Type("Array") Then
				State = Filter.State;
				Filter.Delete("State");
			EndIf;
		EndIf;
		
		If Filter.Count() <> 0 Then
			Rows = Table.FindRows(Filter);
		Else
			Rows = Table;
		EndIf;
		// Performing additional filter by period and state (if the filter is defined).
		ItemNumber = Rows.Count() - 1;
		While ItemNumber >= 0 Do
			If Start    <> Undefined AND Start > Rows[ItemNumber].Begin
				Or End     <> Undefined AND End  < ?(ValueIsFilled(Rows[ItemNumber].End), Rows[ItemNumber].End, CurrentSessionDate())
				Or State <> Undefined AND State.Find(Rows[ItemNumber].State) = Undefined Then
				Rows.Delete(ItemNumber);
			EndIf;
			ItemNumber = ItemNumber - 1;
		EndDo;
		// Deleting unnecessary rows from the table.
		If TypeOf(Rows) = Type("Array") Then
			RowNumber = Table.Count() - 1;
			While RowNumber >= 0 Do
				If Rows.Find(Table[RowNumber]) = Undefined Then
					Table.Delete(Table[RowNumber]);
				EndIf;
				RowNumber = RowNumber - 1;
			EndDo;
		EndIf;
	EndIf;
	
	Return Table;
	
EndFunction

// Returns BackgroundJob properties by a UUID string.
//
// Parameters:
//  ID - String - BackgroundJob UUID.
//  PropertyNames - string, if filled, returns a structure with the specified properties.
// 
// Returns:
//  ValueTableRow, Structure - BackgroundJob properties.
//
Function GetBackgroundJobProperties(ID, PropertiesNames = "") Export
	
	RaiseIfNoAdministrationRights();
	SetPrivilegedMode(True);
	
	Filter = New Structure("ID", ID);
	BackgroundJobPropertyTable = BackgroundJobsProperties(Filter);
	
	If BackgroundJobPropertyTable.Count() > 0 Then
		If ValueIsFilled(PropertiesNames) Then
			Result = New Structure(PropertiesNames);
			FillPropertyValues(Result, BackgroundJobPropertyTable[0]);
		Else
			Result = BackgroundJobPropertyTable[0];
		EndIf;
	Else
		Result = Undefined;
	EndIf;
	
	Return Result;
	
EndFunction

// Throws an exception if the user does not have the administration right.
Procedure RaiseIfNoAdministrationRights() Export

	If UT_Common.DataSeparationEnabled() And UT_Common.SeparatedDataUsageAvailable() Then
		If Not UT_Users.IsFullUser() Then
			Raise NStr("ru = 'Нарушение прав доступа.'; en = 'Access rights violation.'");
		EndIf;
	Else
		If NOT PrivilegedMode() Then
			VerifyAccessRights("Administration", Metadata);
		EndIf;
	EndIf;
	
EndProcedure

// Generates a table of dependencies of scheduled jobs on functional options.
//
// Returns:
//  Dependencies - ValueTable - a table of values with the following columns:
//    * ScheduledJob - MetadataObject:ScheduledJob - scheduled job.
//    * FunctionalOption - MetadataObject:FunctionalOption - functional option the scheduled job 
//        depends on.
//    * DependenceByT - Boolean - if the scheduled job depends on more than one functional option 
//        and you want to enable it only when all functional options are enabled, specify True for 
//        each dependency.
//        
//        The default value is False - if one or more functional options are enabled, the scheduled 
//        job is also enabled.
//    * EnableOnEnableFunctionalOption - Boolean, Undefined - if False, the scheduled job will not 
//        be enabled if the functional option is enabled. Value
//        Undefined corresponds to True.
//        The default value is Undefined.
//    * AvailableInSubordinateDIBNode - Boolean, Undefined - True or Undefined if the scheduled job 
//        is available in the DIB node.
//        The default value is Undefined.
//    * AvailableInSaaS - Boolean, Undefined - True or Undefined if the scheduled job is available 
//        in the SaaS.
//        The default value is Undefined.
//    * UseExternalResources - Boolean - True if the scheduled job is operating with external 
//        resources (receiving emails, synchronizing data, etc.).
//        The default value is False.
//
Function ScheduledJobsDependentOnFunctionalOptions() Export
	
	Dependencies = New ValueTable;
	Dependencies.Columns.Add("ScheduledJob");
	Dependencies.Columns.Add("FunctionalOption");
	Dependencies.Columns.Add("DependenceByT", New TypeDescription("Boolean"));
	Dependencies.Columns.Add("AvailableSaaS");
	Dependencies.Columns.Add("AvailableInSubordinateDIBNode");
	Dependencies.Columns.Add("EnableOnEnableFunctionalOption");
	Dependencies.Columns.Add("AvailableAtStandaloneWorkstation");
	Dependencies.Columns.Add("UseExternalResources",  New TypeDescription("Boolean"));
	Dependencies.Columns.Add("IsParameterized",  New TypeDescription("Boolean"));

	//МодульИнтеграцииПодсистемБСП=УИ_ОбщегоНазначения.ОбщийМодуль("ИнтеграцияПодсистемБСП");
	//Если МодульИнтеграцииПодсистемБСП <> Неопределено Тогда
	//	МодульИнтеграцииПодсистемБСП.ПриОпределенииНастроекРегламентныхЗаданий(Зависимости);
	//КонецЕсли;
	//МодульРегламентныеЗаданияПереопределяемый=УИ_ОбщегоНазначения.ОбщийМодуль("РегламентныеЗаданияПереопределяемый");
	//Если МодульРегламентныеЗаданияПереопределяемый <> Неопределено Тогда
	//	МодульРегламентныеЗаданияПереопределяемый.ПриОпределенииНастроекРегламентныхЗаданий(Зависимости);
	//КонецЕсли;

	Dependencies.Sort("ScheduledJob");
	
	Return Dependencies;
	
EndFunction

// Returns a multiline String containing Messages and ErrorDescription, the last background job is 
// found by the scheduled job ID and there are messages/errors.
// 
//
// Parameters:
//  Job - ScheduledJob, String - UUID
//                 ScheduledJob string.
//
// Returns:
//  String.
//
Function ScheduledJobMessagesAndErrorDescriptions(Val Job) Export
	
	RaiseIfNoAdministrationRights();
	SetPrivilegedMode(True);

	ScheduledJobID = ?(TypeOf(Job) = Type("ScheduledJob"), String(Job.UUID), Job);
	LastBackgroundJobProperties = LastBackgroundJobScheduledJobExecutionProperties(ScheduledJobID);
	Return ?(LastBackgroundJobProperties = Undefined,
	          "",
	          BackgroundJobMessagesAndErrorDescriptions(LastBackgroundJobProperties.ID) );
	
EndFunction

// Returns the properties of the last background job executed with the scheduled job, if there is one.
// The procedure works both in file mode and client/server mode.
//
// Parameters:
//  ScheduledJob - ScheduledJob, String - ScheduledJob UUID string.
//
// Returns:
//  ValueTableRow, Undefined.
//
Function LastBackgroundJobScheduledJobExecutionProperties(ScheduledJob)
	
	RaiseIfNoAdministrationRights();
	SetPrivilegedMode(True);

	ScheduledJobID = ?(TypeOf(ScheduledJob) = Type("ScheduledJob"), String(ScheduledJob.UUID), ScheduledJob);
	Filter = New Structure;
	Filter.Insert("ScheduledJobID", ScheduledJobID);
	Filter.Insert("GetLastScheduledJobBackgroundJob");
	BackgroundJobPropertyTable = BackgroundJobsProperties(Filter);
	BackgroundJobPropertyTable.Sort("End Asc");
	
	If BackgroundJobPropertyTable.Count() = 0 Then
		BackgroundJobProperties = Undefined;
	ElsIf NOT ValueIsFilled(BackgroundJobPropertyTable[0].End) Then
		BackgroundJobProperties = BackgroundJobPropertyTable[0];
	Else
		BackgroundJobProperties = BackgroundJobPropertyTable[BackgroundJobPropertyTable.Count()-1];
	EndIf;
	
	Return BackgroundJobProperties;
	
EndFunction

// Returns a multiline String containing Messages and ErrorDescription if the background job is 
// found by the ID and there are messages/errors.
//
// Parameters:
//  Job - String - a BackgroundJob UUID string.
//
// Returns:
//  String.
//
Function BackgroundJobMessagesAndErrorDescriptions(ID, BackgroundJobProperties = Undefined) Export
	
	RaiseIfNoAdministrationRights();
	SetPrivilegedMode(True);
	
	If BackgroundJobProperties = Undefined Then
		BackgroundJobProperties = GetBackgroundJobProperties(ID);
	EndIf;
	
	Row = "";
	If BackgroundJobProperties <> Undefined Then
		For each Message In BackgroundJobProperties.UserMessages Do
			Row = Row + ?(Row = "",
			                    "",
			                    "
			                    |
			                    |") + Message.Text;
		EndDo;
		If ValueIsFilled(BackgroundJobProperties.ErrorDescription) Then
			Row = Row + ?(Row = "",
			                    BackgroundJobProperties.ErrorDescription,
			                    "
			                    |
			                    |" + BackgroundJobProperties.ErrorDescription);
		EndIf;
	EndIf;
	
	Return Row;
	
EndFunction

// Returns the scheduled job presentation, according to the blank details exception order:
// 
// Description, Metadata.Synonym, and Metadata.Name.
//
// Parameters:
//  Job - ScheduledJob, String - if a string, a UUID string.
//
// Returns:
//  String.
//
Function ScheduledJobPresentation(Val Job) Export
	
	RaiseIfNoAdministrationRights();
	SetPrivilegedMode(True);
	
	If TypeOf(Job) = Type("ScheduledJob") Then
		ScheduledJob = Job;
	Else
		ScheduledJob = ScheduledJobs.FindByUUID(New UUID(Job));
	EndIf;
	
	If ScheduledJob <> Undefined Then
		Presentation = ScheduledJob.Description;
		
		If IsBlankString(ScheduledJob.Description) Then
			Presentation = ScheduledJob.Metadata.Synonym;
			
			If IsBlankString(Presentation) Then
				Presentation = ScheduledJob.Metadata.Name;
			EndIf
		EndIf;
	Else
		Presentation = TextUndefined();
	EndIf;
	
	Return Presentation;
	
EndFunction

// Returns the text "<not defined>".
Function TextUndefined() Export
	
	Return NStr("ru = '<не определено>'; en = '<not defined>'");
	
EndFunction

// Cancels the background job if possible, i.e. if it is running on the server and is active.
//
// Parameters:
//  ID - a string UUID of a BackgroundJob.
//
Procedure CancelBackgroundJob(ID) Export

	RaiseIfNoAdministrationRights();
	SetPrivilegedMode(True);

	NewUUID = New UUID(ID);
	Filter = New Structure;
	Filter.Insert("UUID", NewUUID);
	BackgroundJobArray = BackgroundJobs.GetBackgroundJobs(Filter);
	If BackgroundJobArray.Count() = 1 Then
		BackgroundJob = BackgroundJobArray[0];
	Else
		Raise NStr("ru = 'Фоновое задание не найдено на сервере.'; en = 'The background job is not found on the server.'");
	EndIf;

	If BackgroundJob.State <> BackgroundJobState.Active Then
		Raise NStr("ru = 'Задание не выполняется, его нельзя отменить.'; en = 'The job is not being executed, it cannot be canceled.'");
	EndIf;
	
	BackgroundJob.Cancel();
	
EndProcedure

// It is intended for "manual" immediate execution of the scheduled job procedure either in the 
// client session (in the file infobase) or in the background job on the server (in the server infobase).
// It is used in any connection mode.
// The "manual" run mode does not affect the scheduled job execution according to the emergency and 
// main schedules, as the background job has no reference to the scheduled job.
// The BackgroundJob type does not allow such a reference, so the same rule is applied to file mode.
// 
// 
// Parameters:
//  Job - ScheduledJob, String - ScheduledJob UUID string.
//
// Returns:
//  Structure with the following properties:
//    * StartTime - Undefined, Date - for the file infobase, sets the passed time as the scheduled 
//                        job method start time.
//                        For the server infobase returns the background job start time upon completion.
//    * BackgroundJobID - String - for the server infobase, returns the running background job ID.
//
Function ExecuteScheduledJobManually(Val Job) Export

	RaiseIfNoAdministrationRights();
	SetPrivilegedMode(True);

	ExecutionParameters = ScheduledJobExecutionParameters();
	ExecutionParameters.ProcedureAlreadyExecuting = False;
	Job =  UT_ScheduledJobsServer.GetScheduledJob(Job);

	ExecutionParameters.Started = False;
	LastBackgroundJobProperties = LastBackgroundJobScheduledJobExecutionProperties(Job);
	
	If LastBackgroundJobProperties <> Undefined
	   AND LastBackgroundJobProperties.State = BackgroundJobState.Active Then

		ExecutionParameters.StartedAt  = LastBackgroundJobProperties.Begin;
		If ValueIsFilled(LastBackgroundJobProperties.Description) Then
			ExecutionParameters.BackgroundJobPresentation = LastBackgroundJobProperties.Description;
		Else
			ExecutionParameters.BackgroundJobPresentation = ScheduledJobPresentation(Job);
		EndIf;
	Else
		BackgroundJobDescription = StringFunctionsClientServer.SubstituteParametersToString(NStr("ru = 'Запуск вручную: %1'; en = 'Manual start: %1'"), ScheduledJobPresentation(Job));
		// Time-consuming operations are not used, because the method of the scheduled job is called.
		BackgroundJob = BackgroundJobs.Execute(Job.Metadata.MethodName, Job.Parameters, String(Job.UUID), BackgroundJobDescription);
		ExecutionParameters.BackgroundJobID = String(BackgroundJob.UUID);
		ExecutionParameters.StartedAt = BackgroundJobs.FindByUUID(BackgroundJob.UUID).Begin;
		ExecutionParameters.Started = True;
	EndIf;

	ExecutionParameters.ProcedureAlreadyExecuting = NOT ExecutionParameters.Started;
	Return ExecutionParameters;
	
EndFunction

Function ScheduledJobExecutionParameters() 
	
	Result = New Structure;
	Result.Insert("StartedAt");
	Result.Insert("BackgroundJobID");
	Result.Insert("BackgroundJobPresentation");
	Result.Insert("ProcedureAlreadyExecuting");
	Result.Insert("Started");
	Return Result;
	
EndFunction

Procedure UpdatedScheduledJobsTable(Parameters, StorageURL) Export

	ScheduledJobID 					  = Parameters.JobID;
	Table                             = Parameters.Table;
	DisabledJobs                	  = Parameters.DisabledJobs;
	
	// Update table ScheduledJobs and list ChoiceList of scheduled jobs for filter.
	CurrentJobs = ScheduledJobs.GetScheduledJobs();
	DisabledJobs.Clear();

	ScheduledJobsParameters = ScheduledJobsDependentOnFunctionalOptions();
	FilterParameters        = New Structure;
	ParametrizableJobs = New Array;
	FilterParameters.Insert("Parameterized", True);
	SearchResult = ScheduledJobsParameters.FindRows(FilterParameters);
	For each ResultItem In SearchResult Do
		ParametrizableJobs.Add(ResultItem.ScheduledJob);
	EndDo;

	JobsSaaS = New Map;
	SaaSSubSystemExists = UT_Common.SubsystemExists(
		"StandardSubsystems.SaaS");
	SaaSSubsystem=Undefined;
	If SaaSSubSystemExists Then
		//@skip-warning
		SaaSSubsystem=Metadata.Subsystems.StandardSubsystems.Subsystems.SaaS;
	EndIf;
	For each MetadataObject In Metadata.ScheduledJobs Do
		If Not ScheduledJobAvailableByFunctionalOptions(MetadataObject, ScheduledJobsParameters) Then
			DisabledJobs.Add(MetadataObject.Name);
			Continue;
		EndIf;
		If Not UT_Common.DataSeparationEnabled() and SaaSSubSystemExists Then
			If SaaSSubsystem.Content.Contains(MetadataObject) Then
				JobsSaaS.Insert(MetadataObject.Name, True);
				Continue;
			EndIf;
			For each SubSystem in SaaSSubsystem.Subsystems Do
				If SubSystem.Content.Contains(MetadataObject) Then
					JobsSaaS.Insert(MetadataObject.Name, True);
					Continue;
				EndIf;
			EndDo;
		EndIf;
	EndDo;

	If ScheduledJobID = Undefined Then

		Index = 0;
		For each Job In CurrentJobs Do
			If Not UT_Common.DataSeparationEnabled() And JobsSaaS[Job.Metadata.Name]
				<> Undefined Then
				Continue;
			EndIf;

			ID = String(Job.UUID);

			If Index >= Table.Count() Or Table[Index].ID <> ID Then
				
				// Inserting a new job.
				Updated = Table.Insert(Index);
				
				// Setting a unique identifier.
				Updated.ID = ID;
			Else
				Updated = Table[Index];
			EndIF;

			If ParametrizableJobs.Find(Job.Metadata) <> Undefined Then
				Updated.Parameterizable = True;
			EndIF;

			UpdateRowOfScheduledJobsTable(Updated, Job);
			Index = Index + 1;
		EndDo;
	
		// Deleting extra lines..
		While Index < Table.Count() Do
			Table.Delete(Index);
		EndDo;
	Else
		Job = ScheduledJobs.FindByUUID(
			New UUID(ScheduledJobID));

		Rows = Table.FindRows(
			New Structure("ID", ScheduledJobID));

		If Job <> Undefined And Rows.Count() > 0 Then

			JobRow = Rows[0];
			If ParametrizableJobs.Find(Job.Metadata) <> Undefined Then
				JobRow.Parameterizable = True;
			EndIf;
			UpdateRowOfScheduledJobsTable(JobRow, Job);
		EndIf;
	EndIf;

	Result = New Structure;
	Result.Insert("Table", Table);
	Result.Insert("DisabledJobs", DisabledJobs);

	PutToTempStorage(Result, StorageURL);

EndProcedure

// Checks whether the scheduled job is enabled according to functional options.
//
// Parameters:
//  Job - MetadataObject:ScheduledJob - scheduled job.
//  JobDependencies - ValueTable - table of scheduled jobs dependencies returned by the 
//    ScheduledJobsInternal.ScheduledJobsDependentOnFunctionalOptions method.
//    If it is not specified, it is generated automatically.
//
// Returns:
//  Usage - Boolean - True if the scheduled job is used.
//
Function ScheduledJobAvailableByFunctionalOptions(Job, JobDependencies = Undefined) Export
	
	If JobDependencies = Undefined Then
		JobDependencies = ScheduledJobsDependentOnFunctionalOptions();
	EndIf;

	DisableInSubordinateDIBNode = False;
	DisableInStandaloneWorkplace = False;
	Usage                = Undefined;
	IsSubordinateDIBNode        = UT_Common.IsSubordinateDIBNode();
	IsSeparatedMode          = UT_Common.DataSeparationEnabled();
	IsStandaloneWorkplace 	 = UT_Common.IsStandaloneWorkplace();

	FoundRows = JobDependencies.FindRows(New Structure("ScheduledJob", Job));
	
	For Each DependencyString In FoundRows Do
		If IsSeparatedMode AND DependencyString.AvailableSaaS = False Then
			Return False;
		EndIf;
		
		DisableInSubordinateDIBNode = (DependencyString.AvailableInSubordinateDIBNode = False) AND IsSubordinateDIBNode;
		DisableInStandaloneWorkplace = (DependencyString.AvailableAtStandaloneWorkstation = False) AND IsStandaloneWorkplace;
		
		If DisableInSubordinateDIBNode Or DisableInStandaloneWorkplace Then
			Return False;
		EndIf;
		
		If DependencyString.FunctionalOption = Undefined Then
			Continue;
		EndIf;
		
		FOValue = GetFunctionalOption(DependencyString.FunctionalOption.Name);
		
		If Usage = Undefined Then
			Usage = FOValue;
		ElsIf DependencyString.DependenceByT Then
			Usage = Usage AND FOValue;
		Else
			Usage = Usage Or FOValue;
		EndIf;
	EndDo;
	
	If Usage = Undefined Then
		Return True;
	Else
		Return Usage;
	EndIf;
	
EndFunction

Procedure UpdateRowOfScheduledJobsTable(Row, Job)

	FillPropertyValues(Row, Job);
	
	// Clarification of the name
	Row.Name = ScheduledJobPresentation(Job);
	
	// Setting the Completion Date and Completion Status for the last background procedure.
	LastBackgroundJobProperties = UT_ScheduledJobsInternal.LastBackgroundJobScheduledJobExecutionProperties(
		Job);

	Row.JobName = Job.Metadata.Name;
	If LastBackgroundJobProperties = Undefined Then
		Row.BeginDate          = TextUndefined();
		Row.EndDate       = TextUndefined();
		Row.ExecutionStatus = TextUndefined();
	Else
		Row.BeginDate          = ?(ValueIsFilled(LastBackgroundJobProperties.Begin),
			LastBackgroundJobProperties.Begin, "<>");
		Row.EndDate       = ?(ValueIsFilled(LastBackgroundJobProperties.End),
			LastBackgroundJobProperties.End, "<>");
		Row.ExecutionStatus = LastBackgroundJobProperties.State;
	EndIf;

EndProcedure

// Only for internal use.
//BackgroundJobsPropertiesTableInBackground
Procedure BackgroundJobsPropertiesTableInBackground(Parameters, StorageURL) Export

	PropertiesTable = BackgroundJobsProperties(Parameters.Filter);

	Result = New Structure;
	Result.Insert("PropertiesTable", PropertiesTable);

	PutToTempStorage(Result, StorageURL);

EndProcedure

#EndRegion