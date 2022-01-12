
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	CopyFormData(Parameters.Object, Object);
	
	UUIDString = Parameters.Value;
	
EndProcedure

&AtClient
Procedure OKCommand(Command)
	
	If ValueIsFilled(UUIDString) Then
		Value = New UUID(UUIDString);
	Else
		Value = New UUID;
	EndIf;
	
	ReturnValue = New Structure("Value", Value);

	Close(ReturnValue);
		
EndProcedure

&AtClient
Procedure UUIDTextEditEnd(Item, Text, ChoiceData, DataGetParameters, StandardProcessing)
	//StandardProcessing = False;
	If ValueIsFilled(Text) Then
		Try
			//@skip-warning
			j = New UUID(Text);
		Except
			Raise NStr("ru = 'Некорректный уникальный идентификатор!'; en = 'UUID is incorrect.'");
		EndTry;
	EndIf;
EndProcedure

&AtClient
Procedure UUIDOnChange(Item)
	//@skip-warning
	If ValueIsFilled(Ref) And String(Ref.UUID()) <> UUIDString Then
		Ref = Undefined;
	EndIf;
EndProcedure

&AtClient
Procedure RefOnChange(Item)
	If Ref <> Undefined Then
		//@skip-warning
		UUIDString = Ref.UUID();
	EndIf;
EndProcedure

&AtServerNoContext
Procedure AddQuery(arSearchQuery, SearchQuery, RefClass, Manager, UUIDString)
	
	Ref = Manager.GetRef(New UUID(UUIDString));
	MetadataName = Ref.Metadata().Name;
	IBTable = RefClass + "." + MetadataName;
	ParameterName = RefClass + MetadataName;;
	
	arSearchQuery.Добавить(
		"SELCT TOP 1
		|	Table.Ref AS Ref
		|FROM
		|	" + IBTable + " AS Table
		|WHERE
		|	Table.Ref = &" + ParameterName);
	SearchQuery.SetParameter(ParameterName, Ref);
		
EndProcedure

&AtServerNoContext
Function FindCommandAtServer(UUIDString)
	
	SearchQuery = New Query;
	arSearchQuery = New Array;
	
	For Each Manager In Catalogs Do
		AddQuery(arSearchQuery, SearchQuery, "Catalog", Manager, UUIDString);
	EndDo;
	
	For Each Manager In Documents Do
		AddQuery(arSearchQuery, SearchQuery, "Document", Manager, UUIDString);
	EndDo;
	
	For Each Manager In ChartsOfAccounts Do
		AddQuery(arSearchQuery, SearchQuery, "ChartOfAccounts", Manager, UUIDString);
	EndDo;
	                                                         
	For Each Manager In ChartsOfCharacteristicTypes Do
		AddQuery(arSearchQuery, SearchQuery, "ChartOfCharacteristicTypes", Manager, UUIDString);
	EndDo;
	
	For Each Manager In ChartsOfCalculationTypes Do
		AddQuery(arSearchQuery, SearchQuery, "ChartOfCalculationTypes", Manager, UUIDString);
	EndDo;
	
	For Each Manager In BusinessProcesses Do
		AddQuery(arSearchQuery, SearchQuery, "BusinessProcess", Manager, UUIDString);
	EndDo;
	
	For Each Manager In Tasks Do
		AddQuery(arSearchQuery, SearchQuery, "Task", Manager, UUIDString);
	EndDo;
	
	For Each Manager In ExchangePlans Do
		AddQuery(arSearchQuery, SearchQuery, "ExchangePlan", Manager, UUIDString);
	EndDo;
	
	QueryText = StrConcat(arSearchQuery, "
		|UNION ALL
		|");
	
	SearchQuery.Text = QueryText;
	Selection = SearchQuery.Execute().Select();
	If Selection.Next() Then
		Return Selection.Ref;
	EndIf;
	
	Return Undefined;
	
EndFunction

&AtClient
Procedure FindCommand(Command)
	Ref = FindCommandAtServer(UUIDString);
EndProcedure
