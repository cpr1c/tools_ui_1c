
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	CopyFormData(Parameters.Object, Object);
	
	Title = Parameters.Title;
	QueryName = Parameters.QueryName;
	QueryParameters = Parameters.QueryParameters;
	QueryText.SetText(Parameters.QueryText);
	
	SetParameterValues = FormAttributeToValue("Object").SavedStates_Get("SetParameterValues", True);
	
	GenerateCodeWithParameters();
	
EndProcedure

&AtServerNoContext
Function GetRefLiteral(ManagerName, NameInQuery, Value)
	
	MetadataName = Value.Metadata().Name;
	
	If ManagerName <> "Documents" And ManagerName <> "BusinessProcesses" And ManagerName <> "Tasks"
		And ManagerName <> "ExchangePlans" Then
		
		qPredefined = New Query(StrTemplate(
			"SELECT
			|	Table.PredefinedDataName AS PredefinedDataName
			|FROM
			|	%1.%2 AS Table
			|WHERE
			|	Table.Ref = &Value
			|	AND Table.Predefined", NameInQuery, MetadataName));
		qPredefined.SetParameter("Value", Value);
		
		qrPredefined = qPredefined.Execute();
		If Not qrPredefined.IsEmpty() Then
			selPredefined = qrPredefined.Select();
			selPredefined.Next();
			Return StrTemplate("%1.%2.%3", ManagerName, MetadataName, selPredefined.PredefinedDataName); 
		EndIf;
		
	EndIf;
	
	Return StrTemplate(
		"%1.%2.GetRef(New UUID(""%3""))",
		ManagerName,
		MetadataName,
		Value.UUID());
	
EndFunction

&AtServer
Procedure GetValueListCode(Value, ParameterName, Literal, Comment, CreationCode)
	
	Comment = Undefined;
	
	arAddRows = New Array;
	For Each vli In Value Do
		arAddRows.Add(StrTemplate("	%1.Add(%2);", ParameterName, GetValueLiteral(vli.Value).Literal));
	EndDo;
	
	CreationCode = StrTemplate(
		"	%1 = New ValueList;
		|%2",
		ParameterName,
		StrConcat(arAddRows, "
		|"));
	
	Literal = ParameterName;
	
EndProcedure

&AtServer
Procedure GetArrayCode(Value, ParameterName, Literal, Comment = Undefined, CreationCode = Undefined)
	
	Comment = Undefined;
	
	arAddRows = New Array;
	For Each ArrayValue In Value Do
		arAddRows.Add(StrTemplate("	%1.Add(%2);", ParameterName, GetValueLiteral(ArrayValue).Literal));
	EndDo;
	
	CreationCode = StrTemplate(
		"	%1 = New Array;
		|%2",
		ParameterName,
		StrConcat(arAddRows, "
		|"));
	
	Literal = ParameterName;
	
EndProcedure

&AtServerNoContext
Function GetDateFractionLiteral(DateFractionValue)
	If DateFractionValue = DateFractions.Time Then
		Return "DateFractions.Time";
	ElsIf DateFractionValue = DateFractions.Date Then
		Return "DateFractions.Date";
	ElsIf DateFractionValue = DateFractions.DateTime Then
		Return "DateFractions.DateTime";
	EndIf;
EndFunction

&AtServerNoContext
Function GetAllowedLengthLiteral(AllowedLengthValue)
	If AllowedLengthValue = AllowedLength.Variable Then
		Return "AllowedLength.Variable";
	ElsIf AllowedLengthValue = AllowedLength.Fixed Then
		Return "AllowedLength.Fixed";
	EndIf;
EndFunction

&AtServerNoContext
Function GetAllowedSignLiteral(AllowedSignValue)
	If AllowedSignValue = AllowedSign.Any Then
		Return "AllowedSign.Any";
	ElsIf AllowedSignValue = AllowedSign.Nonnegative Then
		Return "AllowedSign.Nonnegative";
	EndIf;
EndFunction

&AtServer
Procedure GetTypeDescriptionLiteral(ValueTypeDescription, Literal, CreationCode)
	
	Literal = Undefined;
	CreationCode = Undefined;
	
	arTypes = ValueTypeDescription.Types();
	If arTypes.Count() = 0 Then
		Literal = "New TypeDescription()";
		Return;
	EndIf;
	
	DataProcessor = FormAttributeToValue("Object");
	
	If ValueTypeDescription.ContainsType(Type("Date")) Then
		QualifiersCode = StrTemplate(
			", New DateQualifiers(%1)",
			GetDateFractionLiteral(ValueTypeDescription.DateQualifiers.DateFractions));
	Else
		QualifiersCode = "";
	EndIf;
		
	If ValueTypeDescription.ContainsType(Type("String")) Then
		QualifiersCode = StrTemplate(
			", New StringQualifiers(%1, %2)%3",
			ValueTypeDescription.StringQualifiers.Length,
			GetAllowedLengthLiteral(ValueTypeDescription.StringQualifiers.AllowedLength),
			QualifiersCode);
	Else
		If ValueIsFilled(QualifiersCode) Then
			QualifiersCode = ", " + QualifiersCode;
		EndIf;
	EndIf;
		
	If ValueTypeDescription.ContainsType(Type("Number")) Then
		QualifiersCode = StrTemplate(
			", New NumberQualifiers(%1, %2, %3)%4",
			ValueTypeDescription.NumberQualifiers.Digits,
			ValueTypeDescription.NumberQualifiers.FractionDigits,
			GetAllowedSignLiteral(ValueTypeDescription.NumberQualifiers.AllowedSign),
			QualifiersCode);
	Else
		If ValueIsFilled(QualifiersCode) Then
			QualifiersCode = ", " + QualifiersCode;
		EndIf;
	EndIf;
	
	If arTypes.Count() = 1 Then
		Literal = StrTemplate(
			"New TypeDescription(""%1""%2)",
			DataProcessor.GetTypeName(arTypes[0]),
			QualifiersCode);
		Return;
	EndIf;

	arTypeCreation = New Array;
	arTypeCreation.Add("	ColumnTypes = New Array;");
	For Each T In arTypes Do
		arTypeCreation.Add(StrTemplate("	ColumnTypes.Add(Type(""%1""));", DataProcessor.GetTypeName(T)));
	EndDo;
	
	Literal = StrTemplate(
		"New TypeDescription(ColumnTypes%1)",
		QualifiersCode);
		
	CreationCode = StrConcat(arTypeCreation, "
	|");
		
EndProcedure

&AtServer
Procedure AddColumnCreationCode(arCreationCode, ParameterName, Column)
	Var TypeLiteral, CreationCode;
	
	GetTypeDescriptionLiteral(Column.ValueType, TypeLiteral, CreationCode);
	
	If ValueIsFilled(CreationCode) Then
		arCreationCode.Add(CreationCode);
	EndIf;
	
	arCreationCode.Add(StrTemplate("	%1.Columns.Add(""%2"", %3);", ParameterName, Column.Name, TypeLiteral));
		
EndProcedure

&AtServer
Procedure GetValueTableCode(Value, ParameterName, Literal, Comment, CreationCode)
	
	Comment = Undefined;
	
	arAddRows = New Array;
	For Each ArrayValue In Value Do
		arAddRows.Add(StrTemplate("	%1.Add(%2);", ParameterName, GetValueLiteral(ArrayValue).Literal));
	EndDo;
	
	arCreationCode = New Array;
	arCreationCode.Add(StrTemplate("	%1 = New ValueTable;", ParameterName));
	For Each Column In Value.Columns Do
		AddColumnCreationCode(arCreationCode, ParameterName, Column);
	EndDo;
	
	For Each Row In Value Do
		
		arCreationCode.Add(StrTemplate("	TableRow = %1.Add();", ParameterName));
		
		For Each Column In Value.Columns Do
			
			stLiteral = GetValueLiteral(Row[Column.Name]);
			AssignCode = StrTemplate("	TableRow.%1 = %2;", Column.Name, stLiteral.Literal);
			
			If ValueIsFilled(stLiteral.Comment) Then
				AssignCode = StrTemplate("%1 // %2", AssignCode, stLiteral.Comment);
			EndIf;
			
			arCreationCode.Add(AssignCode);
			
		EndDo;
		
	EndDo;
	
	CreationCode = StrConcat(arCreationCode, "
	|");
	
	Literal = ParameterName;
	
EndProcedure
		
&AtServer
Function GetValueLiteral(Value, ParameterName = Undefined)
	
	Literal = Undefined;
	Comment = Undefined;
	CreationCode = Undefined;
	
	ValueType = TypeOf(Value);
	If ValueType = Type("String") Then
		Literal = StrTemplate("""%1""", Value);
	ElsIf ValueType = Type("Number") Then
		Literal = Format(Value, "NG=");
	ElsIf ValueType = Type("Date") Then
		
		Y = Year(Value);
		M = Month(Value);
		D = Day(Value);
		H = Hour(Value);
		Min = Minute(Value);
		Sec = Second(Value);
		
		ValueCode = Format(Y, "ND=4; NLZ=; NG=") + Format(M, "ND=2; NLZ=; NG=") + Format(D, "ND=2; NLZ=; NG=");
		If H <> 0 Or Min <> 0 And Sec <> 0 Then
			ValueCode = ValueCode + Format(H, "ND=2; NLZ=; NG=") + Format(Min, "ND=2; NLZ=; NG=") + Format(Sec, "ND=2; NLZ=; NG=");
		EndIf;
		
		Literal = StrTemplate("'%1'", ValueCode);
		
	ElsIf ValueType = Type("Null") Then
		Literal = "Null";
	ElsIf ValueType = Type("Undefined") Then
		Literal = "Undefined";
	ElsIf ValueType = Type("UUID") Then
		Literal = StrTemplate("New UUID(""%1"")", String(Value));
	ElsIf ValueType = Type("Boolean") Then
		Literal = ?(Value, "True", "False");
	ElsIf ValueType = Type("Boundary") Then
		stBoundaryValueLiteral = GetValueLiteral(Value.Value);
		Literal = StrTemplate("New Boundary(%1, %2)",
			stBoundaryValueLiteral.Literal,
			StrTemplate("BoundaryType.%1", Value.ВидГраницы));
	ElsIf ValueType = Type("PointInTime") Then
		stDateLiteral = GetValueLiteral(Value.Date);
		stRefLiteral = GetValueLiteral(Value.Ref);
		Literal = StrTemplate("New PointInTime(%1, %2)",
			stDateLiteral.Literal, stRefLiteral.Literal);
			Comment = stRefLiteral.Comment;
	ElsIf ValueType = Type("AccumulationRecordType") Then
		Literal = StrTemplate("AccumulationRecordType.%1", Value);
	ElsIf ValueType = Type("AccountingRecordType") Then
		Literal = StrTemplate("AccountingRecordType.%1", Value);
	ElsIf ValueType = Type("AccountType") Then
		Literal = StrTemplate("AccountType.%1", Value);
	ElsIf ValueType = Type("Type") Then
		Literal = StrTemplate("Type(""%1"")", FormAttributeToValue("Object").GetTypeName(Value));
	ElsIf Catalogs.AllRefsType().ContainsType(ValueType) Then
		Literal = GetRefLiteral("Catalogs", "Catalog", Value);
		Comment = StrTemplate("%1 %2", Value.Code, Value.Description);
	ElsIf Documents.AllRefsType().ContainsType(ValueType) Then
		Literal = GetRefLiteral("Documents", "Document", Value);
		Comment = String(Value);
	ElsIf Enums.AllRefsType().ContainsType(ValueType) Then
		EnumMetadata = Value.Metadata();
		Manager = Enums[EnumMetadata.Name];
		EnumID = EnumMetadata.EnumValues.Get(Manager.IndexOf(Value)).Name;
		Literal = StrTemplate("Enums.%1.%2", Value.Metadata().Name, EnumID);
	ElsIf ChartsOfCharacteristicTypes.AllRefsType().ContainsType(ValueType) Then
		Literal = GetRefLiteral("ChartsOfCharacteristicTypes", "ChartOfCharacteristicTypes", Value);
		Comment = StrTemplate("%1 %2", Value.Code, Value.Description);
	ElsIf ChartsOfCalculationTypes.AllRefsType().ContainsType(ValueType) Then
		Literal = GetRefLiteral("ChartsOfCalculationTypes", "ChartOfCalculationTypes", Value);
		Comment = StrTemplate("%1 %2", Value.Code, Value.Description);
	ElsIf ChartsOfAccounts.AllRefsType().ContainsType(ValueType) Then
		Literal = GetRefLiteral("ChartsOfAccounts", "ChartOfAccounts", Value);
		Comment = Value.Code;
	ElsIf BusinessProcesses.AllRefsType().ContainsType(ValueType) Then
		Literal = GetRefLiteral("BusinessProcesses", "BusinessProcess", Value);
		Comment = String(Value);
	ElsIf Tasks.AllRefsType().ContainsType(ValueType) Then
		Literal = GetRefLiteral("Tasks", "Task", Value);
		Comment = String(Value);
	ElsIf ExchangePlans.AllRefsType().ContainsType(ValueType) Then
		Literal = GetRefLiteral("ExchangePlans", "ExchangePlan", Value);
		Comment = StrTemplate("%1 %2", Value.Code, Value.Description);
	ElsIf ValueType = Type("ValueList") Then
		GetValueListCode(Value, ParameterName, Literal, Comment, CreationCode);
	ElsIf ValueType = Type("Array") Then
		GetArrayCode(Value, ParameterName, Literal, Comment, CreationCode);
	ElsIf ValueType = Type("ValueTable") Then
		GetValueTableCode(Value, ParameterName, Literal, Comment, CreationCode);
	EndIf;
	
	If Literal = Undefined Then
		Return New Structure("Literal, Comment, CreationCode", "???");
	EndIf;
	
	Return New Структура("Literal, Comment, CreationCode", Literal, Comment, CreationCode);
	
EndFunction

&AtServer
Procedure GenerateCodeWithParameters()
	
	Text = New TextDocument;
	Text.AddLine(StrTemplate("	%1 = New Query(""", QueryName));
	
	For j = 1 To QueryText.LineCount() Do
		Line = QueryText.GetLine(j);
		Text.AddLine(StrTemplate("		|%1", Line));
	EndDo;
	
	Text.ReplaceLine(Text.LineCount(), Text.GetLine(Text.LineCount()) + """);
	|");
	
	vtQueryParameters = FormAttributeToValue("Object").StringToValue(QueryParameters);
	
	For Each ParameterRow In vtQueryParameters Do
		
		ParameterName = ParameterRow.Name;
		Value = ParameterRow.Value;
		
		If SetParameterValues Then
			
			stLiteral = GetValueLiteral(Value, ParameterName);
			
			If ValueIsFilled(stLiteral.CreationCode) Then
				If ValueIsFilled(Text.GetLine(Text.LineCount())) Then
					Text.AddLine("");
				EndIf;
				Text.AddLine(stLiteral.CreationCode);
			EndIf;
			
			SetParameterCode = StrTemplate("	%1.SetParameter(""%2"", %3);", QueryName, ParameterName, stLiteral.Literal);
			
			If ValueIsFilled(stLiteral.Comment) Then
				SetParameterCode = StrTemplate("%1 //%2", SetParameterCode, stLiteral.Comment);
			EndIf;
			
			Text.AddLine(SetParameterCode);
			
			If ValueIsFilled(stLiteral.CreationCode) Then
				Text.AddLine("");
			EndIf;
			
		Else
			Text.AddLine(StrTemplate("	%1.SetParameter(""%2"", );", QueryName, ParameterName));
		EndIf;
		
	EndDo;
	
	Text.AddLine("");
	Text.AddLine(StrTemplate("	QueryResult = %1.Execute();", QueryName));
	Text.AddLine("	Selection = QueryResult.Select();");
	Text.AddLine("	While Selection.Next() Do");
	Text.AddLine("		");
	Text.AddLine("	EndDo;");
	
EndProcedure

&AtServer
Procedure RefreshAtServer()
	GenerateCodeWithParameters();
EndProcedure

&AtClient
Procedure Refresh_Command(Command)
	RefreshAtServer();
EndProcedure

&AtClient
Procedure OnClose(Exit)
	FormOwner.SavedStates_Save("SetParameterValues", SetParameterValues);
EndProcedure

