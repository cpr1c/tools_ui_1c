&Around("AttachExternalDataProcessor")
Function UT_AttachExternalDataProcessor(Ref) Export
	DebugSettings=UT_Common.AdditionalDataProcessorDebugSettings(Ref);

	HasDebug=False;
	If DebugSettings.DebugEnabled And ValueIsFilled(DebugSettings.FileNameOnServer) Then
		If DebugSettings.User=Undefined 
			Or Not ValueIsFilled(DebugSettings.User) Then
			HasDebug=True;
		ElsIf DebugSettings.User=Users.CurrentUser() Then
			HasDebug=True;
		EndIf;
	EndIf;

	If Not HasDebug Then
		Return ProceedWithCall(Ref);
	Else
		
		DataProcessorFile = New File(DebugSettings.FileNameOnServer);
		If Not DataProcessorFile.Exist() Then
		
			DataProcessorStorage = Common.ObjectAttributeValue(Ref, "DataProcessorStorage");
			BinaryData = DataProcessorStorage.Get();
			BinaryData.Write(DebugSettings.FileNameOnServer);
		
		EndIf; 
		
		Kind = Common.ObjectAttributeValue(Ref, "Kind");
		If Kind = Enums.AdditionalReportsAndDataProcessorsKinds.Report
			Or Kind = Enums.AdditionalReportsAndDataProcessorsKinds.AdditionalReport Then
			Manager = ExternalReports;
		Else
			Manager = ExternalDataProcessors;
		EndIf;

		DataProcessorObject = Manager.Create(DebugSettings.FileNameOnServer, False);
		
		Return TrimAll(DataProcessorObject.Metadata().Name);

		Return DebugSettings.FileNameOnServer;
	EndIf;
EndFunction