Procedure UT_TimeConsumingOperationMonitor() Export

	TimeConsumingOperationsInProgress = UT_TimeConsumingOperationsClient.TimeConsumingOperationsInProgress();
	If TimeConsumingOperationsInProgress.DataProcessor Then
		Return;
	EndIf;
	
	TimeConsumingOperationsInProgress.DataProcessor = True;
	Try
		MonitorTimeConsumingOperations(TimeConsumingOperationsInProgress.List);
		
		TimeConsumingOperationsInProgress.DataProcessor = False;
	Except
		TimeConsumingOperationsInProgress.DataProcessor = False;
		Raise;
	EndTry;
	
EndProcedure

Procedure MonitorTimeConsumingOperations(TimeConsumingOperationsInProgress)
	
	CurrentDate = CurrentDate(); // The session date is ignored.
	
	ActionsUnderControl = New Map;
	JobsToCheck = New Array;
	JobsToCancel = New Array;
	
	For each TimeConsumingOperation In TimeConsumingOperationsInProgress Do

	TimeConsumingOperation = TimeConsumingOperation.Value;
		
		ActionCancelled = False;
		If TimeConsumingOperation.OwnerForm <> Undefined AND Not TimeConsumingOperation.OwnerForm.IsOpen() Then
			ActionCancelled = True;
		EndIf;
		If TimeConsumingOperation.CompletionNotification <> Undefined AND TypeOf(TimeConsumingOperation.CompletionNotification.Module) = UT_CommonClientServer.ManagedFormType()
			AND Not TimeConsumingOperation.CompletionNotification.Module.IsOpen() Then
			ActionCancelled = True;
		EndIf;
		
		If ActionCancelled Then

			ActionsUnderControl.Insert(TimeConsumingOperation.JobID, TimeConsumingOperation);
			JobsToCancel.Add(TimeConsumingOperation.JobID);
			
		ElsIf TimeConsumingOperation.Control <= CurrentDate Then
			
			ActionsUnderControl.Insert(TimeConsumingOperation.JobID, TimeConsumingOperation);
			
			JobToCheck = New Structure("JobID,OutputProgressBar,OutputMessages");
			FillPropertyValues(JobToCheck, TimeConsumingOperation);
			JobsToCheck.Add(JobToCheck);
			
		EndIf;
		
	EndDo;

	Statuses = New Map;
	Statuses = UT_TimeConsumingOperationsServerCall.ActionsCompleted(JobsToCheck, JobsToCancel);
	For each OperationStatus In Statuses Do
		Operation = ActionsUnderControl[OperationStatus.Key];
		Status = OperationStatus.Value;
		Try
			If MonitorTimeConsumingOperation(Operation, Status) Then
				TimeConsumingOperationsInProgress.Delete(OperationStatus.Key);
			EndIf;
		Except
			// do not track any longer
			TimeConsumingOperationsInProgress.Delete(OperationStatus.Key);
			Raise;
		EndTry;
	EndDo;

	If TimeConsumingOperationsInProgress.Count() = 0 Then
		Return;
	EndIf;
	
	CurrentDate = CurrentDate(); // The session date is ignored.
	Interval = 120; 
	For each Operation In TimeConsumingOperationsInProgress Do
		Interval = Max(Min(Interval, Operation.Value.Control - CurrentDate), 1);
	EndDo;

	AttachIdleHandler("UT_TimeConsumingOperationMonitor", Interval, True);

EndProcedure

Function MonitorTimeConsumingOperation(TimeConsumingOperation, Status)
	
	If Status.Status <> "Canceled" AND TimeConsumingOperation.ExecutionProgressNotification <> Undefined Then
		Progress = New Structure;
		Progress.Insert("Status", Status.Status);
		Progress.Insert("JobID", TimeConsumingOperation.JobID);
		Progress.Insert("Progress", Status.Progress);
		Progress.Insert("Messages", Status.Messages);
		ExecuteNotifyProcessing(TimeConsumingOperation.ExecutionProgressNotification, Progress);
	EndIf;

	If Status.Status = "Completed" Then

		UT_TimeConsumingOperationsClient.ShowNotification(TimeConsumingOperation.UserNotification);
		ExecuteNotification(TimeConsumingOperation, Status);
		Return True;
		
	ElsIf Status.Status = "Error" Then
		
		ExecuteNotification(TimeConsumingOperation, Status);
		Return True;
		
	ElsIf Status.Status = "Canceled" Then
		
		ExecuteNotification(TimeConsumingOperation, Status);
		Return True;
		
	EndIf;

	IdleInterval = TimeConsumingOperation.CurrentInterval;
	If TimeConsumingOperation.Interval = 0 Then
		IdleInterval = IdleInterval * 1.4;
		If IdleInterval > 15 Then
			IdleInterval = 15;
		EndIf;
		TimeConsumingOperation.CurrentInterval = IdleInterval;
	EndIf;
	TimeConsumingOperation.Control = CurrentDate() + IdleInterval;  // The session date is ignored.
	Return False;
		
EndFunction
Procedure ExecuteNotification(Val TimeConsumingOperation, Val Status)
	
	If TimeConsumingOperation.CompletionNotification = Undefined Then
		Return;
	EndIf;
	
	If Status.Status = "Canceled" Then
		Result = Undefined;
	Else
		Result = New Structure;
		Result.Insert("Status",    Status.Status);
		Result.Insert("ResultAddress", TimeConsumingOperation.ResultAddress);
		Result.Insert("AdditionalResultAddress", TimeConsumingOperation.AdditionalResultAddress);
		Result.Insert("BriefErrorPresentation", Status.BriefErrorPresentation);
		Result.Insert("DetailedErrorPresentation", Status.DetailedErrorPresentation);
		Result.Insert("Messages", Status.Messages);
	EndIf;
	
	ExecuteNotifyProcessing(TimeConsumingOperation.CompletionNotification, Result);

EndProcedure