#Region Internal

Function GetParameters() Export
//	Parameters = Storage.Get();
//	If Parameters = Undefined OR TypeOf(Parameters) <> Type("Structure") Then 
//		Parameters =  New Structure;
//	EndIf;
//	Return Parameters;
EndFunction

Function GetParameter(ParameterName) Export
//	Parameters = Storage.Get();
//	If Parameters <> Undefined AND Parameters.Property(ParameterName) Then
//		Return Parameters[ParameterName];
//	Else 
//		Return Undefined;
//	EndIf;
EndFunction

Function RemoveParameter(Key) Export
//	Try
//		Parameters = GetParameters();
//		Parameters.Delete(Key);
//		Storage = New ValueStorage(Parameters);
//		Write();
//		Return True;	
//	Except
//		WriteToEventLog("Parameter deletion",ErrorDescription());
//		Return False;
//	EndTry;
EndFunction

Function RenameParameter(Key, NewName) Export
//	Try
//		Parameters = GetParameters();
//		Значение = Parameters[Key];
//		Parameters.Delete(Key);
//		Parameters.Insert(NewName,Value);
//		Storage = New ValueStorage(Parameters);
//		Write();
//		Return True;
//	Except
//		WriteToEventLog("Rename parameter error",ErrorDescription());
//		Return False;
//	EndTry;
EndFunction

#EndRegion