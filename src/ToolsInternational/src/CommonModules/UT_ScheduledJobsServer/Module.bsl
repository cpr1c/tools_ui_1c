// Throws an exception if the user does not have the administration right.
Procedure RaiseIfNoAdministrationRights()
	
	CheckSystemAdministrationRights = True;
	If UT_Common.DataSeparationEnabled() And UT_Common.SeparatedDataUsageAvailable() Then
		CheckSystemAdministrationRights = False;
	EndIf;
	
	If NOT UT_Users.IsFullUser(, CheckSystemAdministrationRights) Then
		Raise NStr("ru = 'Нарушение прав доступа.'; en = 'Access right violation.'");
	EndIf;
	
EndProcedure

// Returns ScheduledJob from the infobase.
// Cannot be used in SaaS mode.
//
// Parameters:
//  ID - MetadataObject - metadata object of a scheduled job to search the predefined scheduled job.
//                  
//                - UUID - an ID of the scheduled job.
//                - String - a scheduled job UUID string.
//                - ScheduledJob - a scheduled job from which you need to get the UUID for getting a 
//                  fresh copy of the scheduled job.
// 
// Returns:
//  ScheduledJob - read from the database.
//
Function GetScheduledJob(Val ID) Export
	
	RaiseIfNoAdministrationRights();
	
	If TypeOf(ID) = Type("ScheduledJob") Then
		ID = ID.UUID;
	EndIf;
	
	If TypeOf(ID) = Type("String") Then
		ID = New UUID(ID);
	EndIf;
	
	If TypeOf(ID) = Type("MetadataObject") Then
		ScheduledJob = ScheduledJobs.FindPredefined(ID);
	Else
		ScheduledJob = ScheduledJobs.FindByUUID(ID);
	EndIf;
	
	If ScheduledJob = Undefined Then
		Raise( NStr("ru = 'Регламентное задание не найдено.
		                              |Возможно, оно удалено другим пользователем.'; 
		                              |en = 'The scheduled job is not found.
		                              |Probably it was deleted by another user.'") );
	EndIf;
	
	Return ScheduledJob;
	
EndFunction

// Adds a new job to a queue or as a scheduled one.
// 
// Parameters:
//  Parameters - Structure - parameters of the job to be added. The following keys can be used:
//   * Usage
//   * Metadata - mandatory
//   * Parameters
//   * Key
//   * RestartIntervalOnFailure
//   * Schedule
//   * RestartCountOnFailure
//
// Returns:
//  ScheduledJob, CatalogRef.JobQueue, CatalogRef.DataAreaJobQueue - an added job ID.
//  
// 
Function AddJob(Parameters) Export

	RaiseIfNoAdministrationRights();
	
	JobParameters = Common.CopyRecursive(Parameters);

	//if UT_Common.DataSeparationEnabled() Then

	//	If UT_Common.SubsystemExists("StandardSubsystems.SaaS.JobQueue") Then
	//		ModuleSaaS = UT_Common.CommonModule("SaaS");

	//		If UT_Common.SeparatedDataUsageAvailable() Then
	//				DataArea = ModuleSaaS.SessionSeparatorValue();
	//				JobParameters.Insert("DataArea", DataArea);
	//			EndIf;

	//		JobMetadata = JobParameters.Metadata;
	//			MethodName = JobMetadata.MethodName;
	//			JobParameters.Insert("MethodName", MethodName);
	//			
	//			JobParameters.Delete("Metadata");
	//			JobParameters.Delete("Description");
	//			
	//			ModuleJobQueue = UT_Common.CommonModule("JobQueue");
	//			Job = ModuleJobQueue.AddJob(JobParameters);
	//			JobsList = ModuleJobQueue.GetJobs(New Structure("ID", Job));
	//			For Each Job In JobsList Do
	//				Return Job;
	//			EndDo;
	//			
	//		EndIf;

	//Else

		JobMetadata = JobParameters.Metadata;
		Job = ScheduledJobs.CreateScheduledJob(JobMetadata);
		
		If JobParameters.Property("Description") Then
			Job.Description = JobParameters.Description;
		Else
			Job.Description = JobMetadata.Description;
		EndIf;
		

	If JobParameters.Property("Use") Then
			Job.Use = JobParameters.Use;
		Else
			Job.Use = JobMetadata.Use;
		EndIf;
		
		If JobParameters.Property("Key") Then
			Job.Key = JobParameters.Key;
		Else
			Job.Key = JobMetadata.Key;
		EndIf;
		
		If JobParameters.Property("UserName") Then
			Job.UserName = JobParameters.UserName;
		EndIf;
		
		If JobParameters.Property("RestartIntervalOnFailure") Then
			Job.RestartIntervalOnFailure = JobParameters.RestartIntervalOnFailure;
		Else
			Job.RestartIntervalOnFailure = JobMetadata.RestartIntervalOnFailure;
		EndIf;

		If JobParameters.Property("RestartCountOnFailure") Then
			Job.RestartCountOnFailure = JobParameters.RestartCountOnFailure;
		Else
			Job.RestartCountOnFailure = JobMetadata.RestartCountOnFailure;
		EndIf;
		
		If JobParameters.Property("Parameters") Then
			Job.Parameters = JobParameters.Parameters;
		EndIf;
		
		If JobParameters.Property("Schedule") Then
			Job.Schedule = JobParameters.Schedule;
		EndIf;
		
		Job.Write();

	//EndIf;

	Return Job;

EndFunction
// Returns the scheduled job schedule.
// Before calling, it is required to have the administrator rights or SetPrivilegedMode.
// Cannot be used in SaaS mode.
//
// Parameters:
//  ID - MetadataObject - metadata object of a scheduled job to search the predefined scheduled job.
//                  
//                - UUID - an ID of the scheduled job.
//                - String - a scheduled job UUID string.
//                - ScheduledJob - a scheduled job.
//
//  InStructure - Boolean - if True, the schedule will be transformed into a structure that you can 
//                  pass to the client.
// 
// Returns:
//  JobSchedule, Structure - the structure contains the same properties as the schedule.
// 
Function JobSchedule(Val ID, Val InStructure = False) Export
	
	RaiseIfNoAdministrationRights();
	
	Job = GetScheduledJob(ID);
	
	If InStructure Then
		Return UT_CommonClientServer.ScheduleToStructure(Job.Schedule);
	EndIf;
	
	Return Job.Schedule;
	
EndFunction

// Sets the scheduled job schedule.
// Before calling, it is required to have the administrator rights or SetPrivilegedMode.
// Cannot be used in SaaS mode.
//
// Parameters:
//  ID - MetadataObject - metadata object of a scheduled job to search the predefined scheduled job.
//                  
//                - UUID - an ID of the scheduled job.
//                - String - a scheduled job UUID string.
//                - ScheduledJob - a scheduled job.
//
//  Schedule    - JobSchedule - a schedule.
//                - Structure - the value returned by the ScheduleToStructure function of the 
//                  CommonClientServer common module.
//  
Procedure SetJobSchedule(Val ID, Val Schedule) Export
	
	RaiseIfNoAdministrationRights();
	
	Job = GetScheduledJob(ID);
	
	If TypeOf(Schedule) = Type("JobSchedule") Then
		Job.Schedule = Schedule;
	Else
		Job.Schedule = UT_CommonClientServer.StructureToSchedule(Schedule);
EndIf;
	
	Job.Write();
	
EndProcedure

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

Function GetBackgroundJobObject(JobUniqueNumber) Export
	
	Try
		
		If Not IsBlankString(JobUniqueNumber) Then
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