#Region Private

Function ActionsCompleted(Val JobsToCheck, JobsToCancel) Export

	Result = UT_TimeConsumingOperations.ActionsCompleted(JobsToCheck);
	For each JobID In JobsToCancel Do
		UT_TimeConsumingOperations.CancelJobExecution(JobID);
		Result.Insert(JobID, New Structure("Status", "Canceled"));
	EndDo;
	Return Result;
	
EndFunction

#EndRegion
