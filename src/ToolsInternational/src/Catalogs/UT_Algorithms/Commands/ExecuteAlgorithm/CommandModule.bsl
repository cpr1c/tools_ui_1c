&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)

	For Each Algorithm In  CommandParameter Do
		Error = False;
		ErrorMessage = "";

		If AlgorithmExecutedAtClient(Algorithm) Then
			UT_CommonClient.ExecuteAlgorithm(Algorithm, , Error, ErrorMessage);
		Else
			UT_CommonServerCall.ExecuteAlgorithm(Algorithm, , Error, ErrorMessage);
		EndIf;
		If Error Then
			UT_CommonClientServer.MessageToUser(ErrorMessage);
		EndIf;
	EndDo;

EndProcedure

&AtServer
Function AlgorithmExecutedAtClient(Algorithm)

	Return Algorithm.AtClient;

EndFunction
