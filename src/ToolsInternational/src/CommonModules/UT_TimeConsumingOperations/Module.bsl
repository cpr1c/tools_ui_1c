// Starts the procedure execution in a background job if possible.
// A job runs in a main thread, not in a background, if any of the following conditions is met:
//  * The procedure is called in a file infobase through an external connection (this mode has no background job support).
//  * The application was started in debug mode using /C DebugMode command-line parameter (this is for configuration debug purposes).
//  * The file infobase already has active background jobs (this is to avoid slow application response to user actions).
//  * The procedure belongs to an external data processor module or external report module.
//
// Do not use this function if the background job must be started unconditionally.
// You can use it together with TimeConsumingOperationsClient.WaitForCompletion function.
// 
// Parameters:
//  ProcedureName           - String    - the name of the export procedure in a common module, 
//                                       object manager module, or data processor module that you want to start in a background job.
//                                       Examples: "MyCommonModule.MyProcedure", "Reports.ImportedData.Generate"
//                                       or "DataProcessors.DataImport.ObjectModule.Import".
//                                       The procedure must have two or three formal parameters:
//                                        * Parameters       - Structure - arbitrary parameters ProcedureParameters.
//                                        * ResultAddress - String    - the address of the temporary 
//                                          storage where the procedure puts its result. This parameter is mandatory.
//                                        * AdditionalResultAddress - String - if 
//                                          ExecutionParameters include the AdditionalResult 
//                                          parameter, this parameter contains the address of the additional temporary storage where the procedure puts its result. This parameter is optional.
//                                       If you need to run a function in background, it is 
//                                       recommended that you wrap it in a function and return its result in the second parameter ResultAddress.
//  ProcedureParameters     - Structure - arbitrary parameters used to call the ProcedureName procedure.
//  ExecutionParameters    - Structure - see function TimeConsumingOperations.BackgroundExecutionParameters.
//
// Returns:
//  Structure              - job execution parameters: 
//   * Status               - String - "Running" if the job is running.
//                                     "Completed " if the job has completed.
//                                     "Error" if the job has completed with error.
//                                     "Canceled" if the job is canceled by a user or by an administrator.
//   * JobID - UUID - contains the ID of the running background job if Status = "Running".
//                                     
//   * ResultAddress       - String  - the address of the temporary storage where the procedure 
//                                     result must be (or already is) stored.
//   * AdditionalResultAddress - String - if the AdditionalResult parameter is set, it contains the 
//                                     address of the additional temporary storage where the 
//                                     procedure result must be (or already is) stored.
//   * BriefErrorDescription   - String - contains brief description of the exception if Status = "Error".
//   * DetailErrorDescription - String - contains detailed description of the exception if Status = "Error".
//  
Function ExecuteInBackground(Val ProcedureName, Val ProcedureParameters, Val ExecutionParameters) Export

	UT_CommonClientServer.CheckParameter("UT_TimeConsumingOperations.ExecuteInBackground", "ExecutionParameters", 
		ExecutionParameters, Type("Structure")); 
	If ExecutionParameters.RunNotInBackground AND ExecutionParameters.RunInBackground Then
		Raise NStr("ru = 'Параметры ""ВсегдаНеВФоне"" и ""ВсегдаВФоне""
			|не могут одновременно принимать значение Истина в UT_TimeConsumingOperations.ExecuteInBackground.'; 
			|en = 'Parameters ""RunNotInBackground"" and ""RunInBackground""
			|cannot both be True at the same time in UT_TimeConsumingOperations.ExecuteInBackground.'");
	EndIf;

		ResultAddress = ?(ExecutionParameters.ResultAddress <> Undefined, 
	    ExecutionParameters.ResultAddress,
		PutToTempStorage(Undefined, ExecutionParameters.FormID));

	Result = New Structure;
	Result.Insert("Status",    "Running");
	Result.Insert("JobID", Undefined);
	Result.Insert("ResultAddress", ResultAddress);
	Result.Insert("AdditionalResultAddress", "");
	Result.Insert("BriefErrorPresentation", "");
	Result.Insert("DetailedErrorPresentation", "");
	Result.Insert("Messages", New FixedArray(New Array));
	
	If ExecutionParameters.NoExtensions Then
		//ExecutionParameters.NoExtensions = ValueIsFilled(SessionParameters.AttachedExtensions);
	EndIf;

	ExportProcedureParameters = New Array;
	ExportProcedureParameters.Add(ProcedureParameters);
	ExportProcedureParameters.Add(ResultAddress);
	
	If ExecutionParameters.AdditionalResult Then
		Result.AdditionalResultAddress = PutToTempStorage(Undefined, ExecutionParameters.FormID);
		ExportProcedureParameters.Add(Result.AdditionalResultAddress);
	EndIf;

	ExecuteWithoutBackgroundJob = Not ExecutionParameters.NoExtensions AND (ExecutionParameters.RunNotInBackground
		OR (BackgroundJobsExistInFileIB() AND Not ExecutionParameters.RunInBackground) Or Not CanRunInBackground(ProcedureName));

	// Executing in the main thread.
	If ExecuteWithoutBackgroundJob Then
		Try
			ExecuteProcedure(ProcedureName, ExportProcedureParameters);
			Result.Status = "Completed";
		Except
			Result.Status = "Error";
			Result.BriefErrorPresentation = BriefErrorDescription(ErrorInfo());
			Result.DetailedErrorPresentation = DetailErrorDescription(ErrorInfo());
			WriteLogEvent(
			NStr("ru = 'Ошибка выполнения'; en = 'Runtime error'", UT_CommonClientServer.DefaultLanguageCode()),
			EventLogLevel.Error, , , Result.DetailedErrorPresentation);
		EndTry;
		Return Result;
	EndIf;
	
	// Executing in background.
	Try
		Job = RunBackgroundJobWithClientContext(ProcedureName, ExecutionParameters, ExportProcedureParameters);
	Except
		Result.Status = "Error";
		If Job <> Undefined AND Job.ErrorInfo <> Undefined Then
			Result.BriefErrorPresentation = BriefErrorDescription(Job.ErrorInfo);
			Result.DetailedErrorPresentation = DetailErrorDescription(Job.ErrorInfo);
		Else
			Result.BriefErrorPresentation = BriefErrorDescription(ErrorInfo());
			Result.DetailedErrorPresentation = DetailErrorDescription(ErrorInfo());
		EndIf;
		Return Result;
	EndTry;

		If Job <> Undefined AND Job.ErrorInfo <> Undefined Then
		Result.Status = "Error";
		Result.BriefErrorPresentation = BriefErrorDescription(Job.ErrorInfo);
		Result.DetailedErrorPresentation = DetailErrorDescription(Job.ErrorInfo);
		Return Result;
	EndIf;
	
	Result.JobID = Job.UUID;
	JobCompleted = False;

	If ExecutionParameters.WaitForCompletion <> 0 Then
		Try
			Job.WaitForCompletion(ExecutionParameters.WaitForCompletion);
			JobCompleted = True;
		Except
			// No special processing is required. Perhaps the exception was raised because a timeout occurred.
		EndTry;
	EndIf;
	
	If JobCompleted Then
		ProgressAndMessages = ReadProgressAndMessages(Job.UUID, "ProgressAndMessages");
		Result.Messages = ProgressAndMessages.Messages;
	EndIf;
	
	FillPropertyValues(Result, ActionCompleted(Job.UUID), , "Messages");
	Return Result;
	
EndFunction

Function ActionCompleted(Val JobID, Val ExceptionOnError = False, Val OutputProgressBar = False, 
	Val OutputMessages = False) Export

	Result = New Structure;
	Result.Insert("Status", "Running");
	Result.Insert("BriefErrorPresentation", Undefined);
	Result.Insert("DetailedErrorPresentation", Undefined);
	Result.Insert("Progress", Undefined);
	Result.Insert("Messages", Undefined);

	Job = FindJobByID(JobID);
	If Job = Undefined Then
		WriteLogEvent(NStr("ru = 'Длительные операции'; en = 'Time-consuming operations'", UT_CommonClientServer.DefaultLanguageCode()),
			EventLogLevel.Error, , , NStr("ru = 'Фоновое задание не найдено:'; en = 'The background job is not found'") + " " + String(JobID));
			If ExceptionOnError Then
			Raise(NStr("ru = 'Не удалось выполнить данную операцию.'; en = 'Cannot perform the operation.'"));
		EndIf;
		Result.Status = "Error";
		Return Result;
	EndIf;

	If OutputProgressBar Then
		ProgressAndMessages = ReadProgressAndMessages(JobID, ?(OutputMessages, "ProgressAndMessages", "Progress"));
		Result.Progress = ProgressAndMessages.Progress;
		If OutputMessages Then
			Result.Messages = ProgressAndMessages.Messages;
		EndIf;
		ElsIf OutputMessages Then
		Result.Messages = Job.GetUserMessages(True);
	EndIf;

	If Job.State = BackgroundJobState.Active Then
		Return Result;
	EndIf;

	If Job.State = BackgroundJobState.Canceled Then
		SetPrivilegedMode(True);
		
		//TODO Change to work with ValueStorage
//		If SessionParameters.CanceledTimeConsumingOperations.Find(JobID) = Undefined Then
//			Result.Status = "Error";
//			If Job.ErrorInfo <> Undefined Then
//				Result.BriefErrorPresentation   = NStr("ru = 'Операция отменена администратором.'; en = 'Operation canceled by administrator.'");
//				Result.DetailedErrorPresentation = Result.BriefErrorPresentation;
//			EndIf;
//			If ExceptionOnError Then
//				If Not IsBlankString(Result.BriefErrorPresentation) Then
//					MessageText = Result.BriefErrorPresentation;
//				Else
//					MessageText = NStr("ru = 'Не удалось выполнить данную операцию.'; en = 'Cannot perform the operation.'");
//				EndIf;
//				Raise MessageText;
//			EndIf;
//		Else
		Result.Status = "Canceled";
//		EndIf;
		SetPrivilegedMode(False);
		Return Result;
	EndIf;

	If Job.State = BackgroundJobState.Failed 
		Or Job.State = BackgroundJobState.Canceled Then

		Result.Status = "Error";
		If Job.ErrorInfo <> Undefined Then
			Result.BriefErrorPresentation   = BriefErrorDescription(Job.ErrorInfo);
			Result.DetailedErrorPresentation = DetailErrorDescription(Job.ErrorInfo);
		EndIf;
		If ExceptionOnError Then
			If Not IsBlankString(Result.BriefErrorPresentation) Then
				MessageText = Result.BriefErrorPresentation;
			Else
				MessageText = NStr("ru = 'Не удалось выполнить данную операцию.'; en = 'Cannot perform the operation.'");
			EndIf;
			Raise MessageText;
		EndIf;
		Return Result;
	EndIf;
	
	Result.Status = "Completed";
	Return Result;
	
EndFunction

// Reads background job execution process details and messages that were generated.
//
// Parameters:
//   JobID - UUID - the background job ID.
//   Mode                - String - "ProgressAndMessages", "Progress", or "Messages".
//
// Returns:
//   Structure - with the following properties:
//    * Progress  - Undefined, Structure - background job progress information that was recorded by the ReportProgress function:
//     ** Percentage                 - Number  - optional. Progress percentage.
//     ** Text                   - String - optional. Details on the current action.
//     ** AdditionalParameters - Arbitrary - optional. Any additional information.
//    * Messages - FixedArray - the array of UserMessage objects that were generated in the background job.
//
Function ReadProgressAndMessages(Val JobID, Val Mode = "ProgressAndMessages")
	
	Messages = New FixedArray(New Array);
	Result = New Structure("Messages, Progress", Messages, Undefined);
	
	Job = BackgroundJobs.FindByUUID(JobID);
	If Job = Undefined Then
		Return Result;
	EndIf;

	MessagesArray = Job.GetUserMessages(True);
	If MessagesArray = Undefined Then
		Return Result;
	EndIf;

	Count = MessagesArray.Count();
	Messages = New Array;
	MustReadMessages = (Mode = "ProgressAndMessages" Or Mode = "Messages"); 
	MustReadProgress  = (Mode = "ProgressAndMessages" Or Mode = "Progress"); 
	
	If MustReadMessages AND Not MustReadProgress Then
		Result.Messages = New FixedArray(MessagesArray);
		Return Result;
	EndIf;

	For Number = 0 To Count - 1 Do
		Message = MessagesArray[Number];
		
		If MustReadProgress AND StrStartsWith(Message.Text, "{") Then
			Position = StrFind(Message.Text, "}");
			If Position > 2 Then
				MechanismID = Mid(Message.Text, 2, Position - 2);
				If MechanismID = ProgressMessage() Then
					ReceivedText = Mid(Message.Text, Position + 1);
					Result.Progress = UT_Common.ValueFromXMLString(ReceivedText);
					Continue;
				EndIf;
			EndIf;
		EndIf;
		If MustReadMessages Then
			Messages.Add(Message);
		EndIf;
	EndDo;
	
	Result.Messages = New FixedArray(Messages);
	Return Result;
	
EndFunction

Function BackgroundJobsExistInFileIB()
	
	JobsRunningInFileIB = 0;
	IF UT_Common.FileInfobase() Then
		Filter = New Structure;
		Filter.Insert("State", BackgroundJobState.Active);
		JobsRunningInFileIB = BackgroundJobs.GetBackgroundJobs(Filter).Count();
	EndIf;
	Return JobsRunningInFileIB > 0;

EndFunction

Function CanRunInBackground(ProcedureName)
	
	NameParts = StrSplit(ProcedureName, ".");
	If NameParts.Count() = 0 Then
		Return False;
	EndIf;
	
	IsExternalDataProcessor = (Upper(NameParts[0]) = "EXTERNALDATAPROCESSOR");
	IsExternalReport = (Upper(NameParts[0]) = "EXTERNALREPORT");
	Return Not (IsExternalDataProcessor Or IsExternalReport);

EndFunction
Procedure ExecuteProcedure(ProcedureName, ProcedureParameters)
	
	NameParts = StrSplit(ProcedureName, ".");
	IsDataProcessorModuleProcedure = (NameParts.Count() = 4) AND Upper(NameParts[2]) = "OBJECTMODULE";
	If Not IsDataProcessorModuleProcedure Then
		UT_Common.ExecuteConfigurationMethod(ProcedureName, ProcedureParameters);
		Return;
	EndIf;
	
	IsDataProcessor = Upper(NameParts[0]) = "DATAPROCESSOR";
	IsReport = Upper(NameParts[0]) = "REPORT";
	If IsDataProcessor Or IsReport Then
		ObjectManager = ?(IsReport, Reports, DataProcessors);
		DataProcessorReportObject = ObjectManager[NameParts[1]].Create();
		UT_Common.ExecuteObjectMethod(DataProcessorReportObject, NameParts[3], ProcedureParameters);
		Return;
	EndIf;
	
	IsExternalDataProcessor = Upper(NameParts[0]) = "EXTERNALDATAPROCESSOR";
	IsExternalReport = Upper(NameParts[0]) = "EXTERNALREPORT";
	If IsExternalDataProcessor Or IsExternalReport Then
		VerifyAccessRights("InteractiveOpenExtDataProcessors", Metadata);
		ObjectManager = ?(IsExternalReport, ExternalReports, ExternalDataProcessors);
		DataProcessorReportObject = ObjectManager.Create(NameParts[1], SafeMode());
		UT_Common.ExecuteObjectMethod(DataProcessorReportObject, NameParts[3], ProcedureParameters);
		Return;
	EndIf;

	Raise StrTemplate(
		NStr("ru = 'Неверный формат параметра ИмяПроцедуры (переданное значение: %1)'; 
		|	  en = 'Invalid format of ProcedureName parameter (passed value: %1)'"), ProcedureName);

EndProcedure

Function RunBackgroundJobWithClientContext(ProcedureName,
	ExecutionParameters, ProcedureParameters = Undefined) Export

	BackgroundJobKey = ExecutionParameters.BackgroundJobKey;
	BackgroundJobDescription = ?(IsBlankString(ExecutionParameters.BackgroundJobDescription),
		ProcedureName, ExecutionParameters.BackgroundJobDescription);

    AllParameters = New Structure;
	AllParameters.Insert("ProcedureName",       ProcedureName);
	AllParameters.Insert("ProcedureParameters", ProcedureParameters);
	//...AllParameters.Insert("ClientParametersAtServer", StandardSubsystemsServer.ClientParametersAtServer());

	BackgroundJobProcedureParameters = New Array;
	BackgroundJobProcedureParameters.Add(AllParameters);

	Return RunBackgroundJob(ExecutionParameters, "UT_TimeConsumingOperations.ExecuteWithClientContext",
		BackgroundJobProcedureParameters,BackgroundJobKey, BackgroundJobDescription);

КонецФункции

Function FindJobByID(Val JobID)
	
	If TypeOf(JobID) = Type("String") Then
		JobID = New UUID(JobID);
	EndIf;
	
	Job = BackgroundJobs.FindByUUID(JobID);
	Return Job;
	
EndFunction

Function ProgressMessage() Export
	Return "UT_UniversalTools.TimeConsumingOperations";
EndFunction
Function RunBackgroundJob(ExecutionParameters, MethodName, Parameters, varKey, Description)

	If CurrentRunMode() = Undefined AND UT_Common.FileInfobase() Then

		Session = GetCurrentInfoBaseSession();
		If ExecutionParameters.WaitForCompletion = Undefined AND Session.ApplicationName = "BackgroundJob" Then
			Raise NStr("ru = 'В файловой информационной базе невозможно одновременно выполнять более одного фонового задания'; en = 'In a file infobase, only one background job can run at a time.'");
		ElsIf Session.ApplicationName = "COMConnection" Then
			Raise NStr("ru = 'В файловой информационной базе можно запустить фоновое задание только из клиентского приложения'; en = 'In a file infobase, background jobs can only be started from the client application.'");
		EndIf;
		
	EndIf;

	If ExecutionParameters.NoExtensions Then
		Return ConfigurationExtensions.ExecuteBackgroundJobWithoutExtensions(MethodName, Parameters, varKey, Description);
	Else
		Return BackgroundJobs.Execute(MethodName, Parameters, varKey, Description);
	EndIf;
	
EndFunction

// Continuation of the RunBackgroundJobWithClientContext procedure.
Procedure ExecuteWithClientContext(AllParameters) Export
	
//	SetPrivilegedMode(True);
//	If AccessRight("Set", Metadata.SessionParameters.ClientParametersAtServer) Then
//		SessionParameters.ClientParametersAtServer = AllParameters.ClientParametersAtServer;
//	EndIf;
//	Catalogs.ExtensionsVersions.RegisterExtensionsVersionUsage();
//	SetPrivilegedMode(False);

	ExecuteProcedure(AllParameters.ProcedureName, AllParameters.ProcedureParameters);
	
EndProcedure

// Returns a new structure for the ExecutionParameters parameter of the ExecuteInBackground function.
//
// Parameters:
//   FormID - UUID - a UUID of the form containing the temporary storage where the procedure puts 
//                               its result.
//
// Returns:
//   Structure - with the following properties:
//     * FormID      - UUID - a UUID of the form containing the temporary storage where the 
//                               procedure puts its result.
//     * AdditionalResult - Boolean     - the flag indicates whether additional temporary storage is 
//                                 to be used to pass the result from the background job to the parent session. The default value is False.
//     * WaitForCompletion       - Number, Undefined - background job completion timeout, in seconds.
//                               Wait for completion if Undefined.
//                               If set to 0, means "do not wait for completion."
//                               The default value is 2 seconds (or 4 seconds for slow connections).
//     * BackgroundJobDescription - String - the description of the background job. The default value is the procedure name.
//     * BackgroundJobKey      - String    - the unique key for active background jobs that have the same procedure name.
//                                              Not set by default.
//     * ResultAddress          - String -  the address of the temporary storage where the procedure 
//                                           result must be stored. If the address is not set, it is generated automatically.
//     * RunInBackground           - Boolean - if True, the job always runs in background, unless in 
//                               debug mode.
//                               When in file mode, if any other jobs are running, the new job is 
//                               queued and does not start running until all previous jobs are completed.
//     * RunNotInBackground         - Boolean - if True, the job always runs naturally rather than 
//                               in background.
//     * NoExtensions            - Boolean - if True, no configuration extensions are attached to 
//                               run the background job.
//
Function BackgroundExecutionParameters(Val FormID) Export
	
	Result = New Structure;
	Result.Insert("FormID", FormID); 
	Result.Insert("AdditionalResult", False);
	Result.Insert("WaitForCompletion", ?(GetClientConnectionSpeed() = ClientConnectionSpeed.Low, 4, 0.8));
	Result.Insert("BackgroundJobDescription", "");
	Result.Insert("BackgroundJobKey", "");
	Result.Insert("ResultAddress", Undefined);
	Result.Insert("RunNotInBackground", False);
	Result.Insert("RunInBackground", False);
	Result.Insert("NoExtensions", False);
	Return Result;
	
EndFunction

// Cancels background job execution by the passed ID.
// 
// Parameters:
//  JobID - UUID - the background job ID
// 
Procedure CancelJobExecution(Val JobID) Export 
	
	If Not ValueIsFilled(JobID) Then
		Return;
	EndIf;
	
//	SetPrivilegedMode(True);
//	If SessionParameters.UT_CanceledTimeConsumingOperations.Find(JobID) = Undefined Then
//		CanceledTimeConsumingOperations = New Array(SessionParameters.UT_CanceledTimeConsumingOperations);
//		CanceledTimeConsumingOperations.Add(JobID);
//		SessionParameters.UT_CanceledTimeConsumingOperations = New FixedArray(CanceledTimeConsumingOperations);
//	EndIf;
//	SetPrivilegedMode(False);

	Job = FindJobByID(JobID);
	If Job = Undefined	Or Job.State <> BackgroundJobState.Active Then
		Return;
	EndIf;

	Try
		Job.Cancel();
	Except
		// It is possible that the job has completed at that moment and no error has occurred.
		WriteLogEvent(NStr("ru = 'Длительные операции.Отмена выполнения фонового задания';
		| en = 'Time-consuming operations.Cancel background job'",
			UT_CommonClientServer.DefaultLanguageCode()),EventLogLevel.Information, , , BriefErrorDescription(ErrorInfo()));
	EndTry;
	
EndProcedure
Function ActionsCompleted(Val Jobs) Export
	
	Result = New Map;
	For each Job In Jobs Do
		Result.Insert(Job.JobID, 
			ActionCompleted(Job.JobID, False, Job.OutputProgressBar, Job.OutputMessages));
	EndDo;
	Return Result;
	
EndFunction

// Records progress of a time-consuming operation.
// To read the recorded information, use the ReadProgress function.
//
// Parameters:
//  Percentage                 - Number        - completion percentage.
//  Text                   - String       - information about the current operation.
//  AdditionalParameters - Arbitrary - any additional information that must be passed to the client.
//                                           The value must be serialized into the XML string.
//
Процедура ReportProgress(Val Percent = Undefined, Val Text = Undefined, Val AdditionalParameters = Undefined) Export
	
	If GetCurrentInfoBaseSession().GetBackgroundJob() = Undefined Then
		Return;
	EndIf;
		
	ValueToPass = New Structure;
	If Percent <> Undefined Then
		ValueToPass.Insert("Percent", Percent);
	EndIf;
	If Text <> Undefined Then
		ValueToPass.Insert("Text", Text);
	EndIf;
	If AdditionalParameters <> Undefined Then
		ValueToPass.Insert("AdditionalParameters", AdditionalParameters);
	EndIf;
	
	TextToPass = UT_Common.ValueToXMLString(ValueToPass);
	
	Text = "{" + ProgressMessage() + "}" + TextToPass;
	UT_CommonClientServer.MessageToUser(Text);

EndProcedure

// Gets messages intended for the user, and blocks system messages regarding the time-consuming operation status.
// 
// Parameters:
//  DeleteReceived    - Boolean                  - the flag indicates whether the received messages need to be deleted.
//  JobID - UUID - the ID of the background job corresponding to a time-consuming operation that 
//                                                   generates messages intended for the user.
//                                                   If not set, the messages intended for the user 
//                                                   are returned from the current user session.
// 
// Returns:
//  FixedArray - UserMessage objects that were generated in the background job.
//
Function UserMessages(DeleteReceived = False, JobID = Undefined) Export
	
	If ValueIsFilled(JobID) Then
		BackgroundJob = BackgroundJobs.FindByUUID(JobID);
		If BackgroundJob <> Undefined Then
			AllMessages = BackgroundJob.GetUserMessages(DeleteReceived);
		EndIf;
	Else
		AllMessages = GetUserMessages(DeleteReceived);
	EndIf;
	
	Result = New Array;

		For Each Message In AllMessages Do
		If StrStartsWith(Message.Text, "{" + ProgressMessage() + "}") Then
			If DeleteReceived Then
				Message.Message();
			EndIf;
		Else
			Result.Add(Message);
		EndIf;
	EndDo;
	
	Return New FixedArray(Result);
	
EndFunction

// Checks background job state by the passed ID.
// If the job terminates abnormally, raises the exception that was generated or a common exception 
// "Cannot perform the operation. See the event log for details.
//
// Parameters:
//  JobID - UUID - the background job ID.
//
// Returns:
//  Boolean - job execution status.
// 
Function JobCompleted(Val JobID) Export
	
	Job = FindJobByID(JobID);
	
	If Job <> Undefined
		AND Job.State = BackgroundJobState.Active Then
		Return False;
	EndIf;
	
	ActionNotExecuted = True;
	ShowFullErrorText = False;
	If Job = Undefined Then
		WriteLogEvent(NStr("ru = 'Длительные операции.Фоновое задание не найдено'; 
		|en = 'Time-consuming operations.Background job not found'",
			UT_CommonClientServer.DefaultLanguageCode()), EventLogLevel.Error, , , String(JobID));
	Else
		If Job.State = BackgroundJobState.Failed Then
			JobError = Job.ErrorInfo;
			If JobError <> Undefined Then
				ShowFullErrorText = True;
			EndIf;
		ElsIf Job.State = BackgroundJobState.Canceled Then
			WriteLogEvent(
				NStr("ru = 'Длительные операции.Фоновое задание отменено администратором'; 
				|en = 'Time-consuming operations.Background job canceled by administrator'",
				UT_CommonClientServer.DefaultLanguageCode()), EventLogLevel.Error,
				,
				,
				NStr("ru = 'Задание завершилось с неизвестной ошибкой.'; en = 'The job completed with an unknown error.'"));
		Else
			Return True;
		EndIf;
	EndIf;

	If ShowFullErrorText Then
		ErrorText = BriefErrorDescription(Job.ErrorInfo);
		Raise(ErrorText);
	ElsIf ActionNotExecuted Then
		Raise(NStr("ru = 'Не удалось выполнить данную операцию. 
		                             |Подробности см. в Журнале регистрации.'; 
		                             |en = 'Cannot perform the operation. 
		                             |For more information, see the event log.'"));
	EndIf;
	
EndFunction