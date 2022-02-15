// Query console 9000 v 1.1.11
// (C) Alexander Kuznetsov 2019-2020
// hal@hal9000.cc
// Minimum platform version 8.3.12, minimum compatibility mode 8.3.8
// Translated by Neti Company

&AtClient
Var ConsoleSignature;
&AtClient
Var FormatVersion;
&AtClient
Var FilesExtension;
&AtClient
Var SaveFilter;
&AtClient
Var AutoSaveExtension;
&AtClient
Var AutoSaveFileDeletedFlag;//used in LoadQueryBatchAfterQuestion
&AtClient
Var StatusFileDeletedFlag;//used in LoadQueryBatchAfterQuestion

//Container types in QueryParameters: 0 - none, 1 - value list, 2 - array, 3 - value table.

&AtClient
Function GetAutoSaveFileName(FileName)
	File = New File(FileName);
	Return File.Path + File.BaseName + "." + AutoSaveExtension;
EndFunction

&AtClient
Function TimeFromSeconds(Seconds)
	TimeSecondsString = Format(Seconds % 60, "ND=2; NZ=; NLZ=");
	Minutes = Int(Seconds / 60);
	TimeMinutesString = Format(Minutes % 60, "ND=2; NZ=; NLZ=");
	Hours = Int(Minutes / 60);
	TimeHoursString = Format(Hours, "NZ=00; NG=");
	Return StrTemplate("%1:%2:%3", TimeHoursString, TimeMinutesString, TimeSecondsString);
EndFunction

&AtServer
Function SetDataProcessorToServer(Address)

	File = New File(Object.DataProcessorFileName);
	DataProcessorServerFileNameString = TempFilesDir() + File.BaseName + "_" + Object.DataProcessorVersion
		+ File.Extension;
	BinaryData = GetFromTempStorage(Address);
	BinaryData.Wrtite(DataProcessorServerFileNameString);

	Return DataProcessorServerFileNameString;

EndFunction

&AtClient
Function GetDataProcessorServerFileName()

	If ValueIsFilled(DataProcessorServerFileName) Then
		Return DataProcessorServerFileName;
	EndIf;

	Try

		If ValueIsFilled(Object.DataProcessorFileName) Then
			Address = "";
			BeginPutFile(New NotifyDescription("PutDataProcessorToServerContinue", ThisForm), Address,
				Object.DataProcessorFileName, False);
		EndIf;

	Except
	EndTry;

	Return Undefined;

EndFunction

&AtClient
Procedure AllowHooking()
	Items.QueryBatchHookingSubmenu.Enabled = True;
EndProcedure

&AtClient
Procedure AllowBackgroundExecution()
	Items.CodeExecutionMethod.ChoiceList.Add(3, NStr("ru = 'простое в фоне (БСП 2.3)'; en = 'simple in background (SSL 2.3)'"));
	Items.CodeExecutionMethod.ChoiceList.Add(4, NStr("ru = 'построчно в фоне с индикацией (БСП 2.3)'; en = 'line by line in background with indication (SSL 2.3)'"));
EndProcedure

&AtClient
Procedure PutDataProcessorToServerContinue(Result, Address, FileName, AdditionalParameters) Export

	DataProcessorServerFileName = SetDataProcessorToServer(Address);
	
	// Data processor is putting to server. You can hook the query and execute it in background.
	AllowHooking();
	AllowBackgroundExecution();

EndProcedure

&AtClient
Function FormFullName(FormName)
	Return StrTemplate("%1.Form.%2", Object.MetadataPath, FormName);
EndFunction

&AtClient
Procedure ShowConsoleMessageBox(MessageText) Export
	ShowMessageBox( , MessageText, , Object.Title);
EndProcedure

&AtClient
Function FindInTree(TreeItem, AttributeName, Value, ExceptionRowID = Undefined)

	For Each Item In TreeItem.GetItems() Do

		Row = FindInTree(Item, AttributeName, Value, ExceptionRowID);
		If Row <> Undefined Then
			Return Row;
		EndIf;

		If Item[AttributeName] = Value Then
			RowID = Item.GetID();
			If RowID <> ExceptionRowID Then
				Return RowID;
			EndIf;
		EndIf;

	EndDo;

	Return Undefined;

EndFunction

&AtServerNoContext
Function FormatDuration(DurationInMilliseconds)

	Return StrTemplate("%1.%2", Format('00010101' + Int((DurationInMilliseconds) / 1000), "DLF=T; DE=12:00:00 AM"),
		Format(DurationInMilliseconds - Int((DurationInMilliseconds) / 1000) * 1000, "ND=3; NZ=; NLZ="));

EndFunction

&AtServerNoContext
Function TypeDescriptionByType(Type)
	arTypes = New Array;
	arTypes.Add(Type);
	Return New TypeDescription(arTypes);
EndFunction

&AtClientAtServerNoContext
Function NameIsCorrect(VerifyingName)

	If Not ValueIsFilled(VerifyingName) Then
		Return False;
	EndIf;

	Try
		//@skip-warning
		st = New Structure(VerifyingName);
	Except
		Return False;
	EndTry;

	Return True;

EndFunction

&AtServerNoContext
Function GetValueFormCode(Val Value)

	ValueType = TypeOf(Value);
	If ValueType = Type("Array") Then
		Return 2;
	ElsIf ValueType = Type("ValueList") Then
		Return 1;
	ElsIf ValueType = Type("ValueTable") Then
		Return 3;
	EndIf;

	Return 0;

EndFunction

&AtServerNoContext
Procedure DisassembleQueryError(ErrorString, LineNumber, ColumnNumber)

	arParts = StrSplit(ErrorString, ":");
	arCoordinates = Undefined;
	If arParts.Count() > 2 Then
		ErrorCoordinatesString = TrimAll(arParts[2]);
		If arParts.Count() > 2 And StrLen(ErrorCoordinatesString) > 5 And Left(ErrorCoordinatesString, 2) = "{(" Then
			arCoordinates = StrSplit(Mid(ErrorCoordinatesString, 3, StrLen(ErrorCoordinatesString) - 4), ",");
			arParts[0] = "";
			arParts[1] = "";
		Else
			arParts[0] = "";
		EndIf;
	EndIf;

	Splitter = ": ";
	ErrorString = StrConcat(arParts, Splitter);
	While Left(ErrorString, StrLen(Splitter)) = Splitter Do
		ErrorString = Right(ErrorString, StrLen(ErrorString) - StrLen(Splitter));
	EndDo;

	LineNumber = Undefined;
	ColumnNumber = Undefined;
	If arCoordinates <> Undefined Then
		LineNumber = Number(arCoordinates[0]);
		ColumnNumber = Number(arCoordinates[1]);
	EndIf;

EndProcedure

// Specifies the error location in the query text when trying to execute it.
// Parameters:
//	ErrorString - String - error description string.
//	Query - Query - query with parameters.
//	OriginalQueryText - String - original query text.
//	LineNumber - Number - number of error location line.
//	ColumnNumber - Number - number of error location column.
//
&AtServerNoContext
Procedure DisassembleSpecifiedQueryError(ErrorString, Query, OriginalQueryText, LineNumber, ColumnNumber)

	DisassembleQueryError(ErrorString, LineNumber, ColumnNumber);
	RealErrorString = ErrorString;
	RealLineNumber = LineNumber;
	RealColumnNumber = ColumnNumber;

	Query.Text = OriginalQueryText;
	Try
		Query.FindParameters();
		Query.Execute();
	Except
		ErrorString = ErrorDescription();
	EndTry;

	DisassembleQueryError(ErrorString, LineNumber, ColumnNumber);

	arRealStringParts = StrSplit(RealErrorString, ":");
	arSpecifiedStringParts = StrSplit(ErrorString, ":");
	If arRealStringParts.Count() = arSpecifiedStringParts.Count() And arRealStringParts.Count() > 1
		And arRealStringParts[1] = arSpecifiedStringParts[1] Then
		 	// The error is reproduced on the original query, messages and locattion are correct.
		Return;
	EndIf;

	ErrorString = RealErrorString;
	LineNumber = RealLineNumber;
	ColumnNumber = RealColumnNumber;

EndProcedure

&AtServerNoContext
Function FormatQueryTextAtServer(QueryText)
	Var LineNumber, ColumnNumber;

	QuerySchema = New QuerySchema;

	Try
		QuerySchema.SetQueryText(QueryText);
	Except

		ErrorString = ErrorDescription();
		DisassembleQueryError(ErrorString, LineNumber, ColumnNumber);
		Return New Structure("ErrorDescription, Row, Column", ErrorString, LineNumber, ColumnNumber);

	EndTry;

	Return QuerySchema.GetQueryText();

EndFunction

&AtServerNoContext
Function GetFileListAtServerFromTempFilesDir(Mask)

	arQueryFiles = FindFiles(TempFilesDir(), Mask);

	arFileNames = New Array;
	For Each File In arQueryFiles Do
		arFileNames.Add(File.FullName);
	EndDo;

	Return arFileNames;

EndFunction

&AtServerNoContext
Procedure DeleteFilesAtServer(arFiles)
	For Each FileName In arFiles Do
		DeleteFiles(FileName);
	EndDo;
EndProcedure

&AtClientAtServerNoContext
Function ValueChoiceButtonEnabled(Value)

	arNoChoiceButtonTypes = New Array;
	arNoChoiceButtonTypes.Add(Type("String"));
	arNoChoiceButtonTypes.Add(Type("Number"));
	arNoChoiceButtonTypes.Add(Type("Boolean"));
	arNoChoiceButtonTypes.Add(Type("AccumulationRecordType"));
	arNoChoiceButtonTypes.Add(Type("AccountingRecordType"));
	arNoChoiceButtonTypes.Add(Type("AccountType"));
	NoChoiceButtonTypes = New TypeDescription(arNoChoiceButtonTypes);

	Return Not NoChoiceButtonTypes.ContainsType(TypeOf(Value));

EndFunction

&AtServerNoContext
Function GetErrorInfoPresentation(ErrorInfo)

	If ValueIsFilled(ErrorInfo.ModuleName) And ValueIsFilled(ErrorInfo.LineNumber) Then
		ErrorInfoPresentation = ErrorInfo.ModuleName + StrTemplate(NStr("ru = ' строка %1'; en = ' line %1'"),
			ErrorInfo.LineNumber) + "
									|";
	ElsIf ValueIsFilled(ErrorInfo.LineNumber) Then
		ErrorInfoPresentation = StrTemplate(NStr("ru = 'Строка %1'; en = 'Line %1'"), ErrorInfo.LineNumber) + "
																								   			  |";
	Else
		ErrorInfoPresentation = "";
	EndIf;

	ErrorInfoPresentation = ErrorInfoPresentation + ErrorInfo.Description + ":
																			|"
		+ ErrorInfo.SourceLine;

	If ErrorInfo.Cause <> Undefined Then
		ErrorInfoPresentation = ErrorInfoPresentation + "
														|"
			+ GetErrorInfoPresentation(ErrorInfo.Cause);
	EndIf;

	Return ErrorInfoPresentation;

EndFunction

&AtServer
Function QueryParametersFormOnChangeVLFromVT(Container)

	DataProcessor = FormAttributeToValue("Object");

	vtTable = DataProcessor.Container_RestoreValue(Container);
	vlList = New ValueList;
	If vtTable.Columns.Count() > 0 Then
		vlList.LoadValues(vtTable.UnloadColumn(0));
	EndIf;

	Return DataProcessor.Container_SaveValue(vlList);

EndFunction

&AtServerNoContext
Function PointInTimeSearchSubqueryText(MetadataName, RegisterName, ColumnName, TempTableName,
	TextINTO)
	Return StrTemplate(
		"SELECT
		|	%1%2.Period AS Date,
		|	%1%2.Recorder AS Ref,
		|	%1%2.PointInTime AS PointInTime %4
		|FROM
		|	%1.%2 AS %1%2 INNER JOIN %5_PointsInTimeData_%3 ON %1%2.Recorder = %5_PointsInTimeData_%3.Ref AND %1%2.Period = %5_PointsInTimeData_%3.Date
		|", MetadataName, RegisterName, ColumnName, TextINTO, TempTableName);

EndFunction

&AtServer
Procedure PrepareMomentInTimeColumnsSelection(vtData, TempTableName, stNewFieldExpressions,
	AdditionalSources, AdditionalQueries)
	
	//DataProcessor = FormAttributeToValue("Объект");

	arPointInTimeColumnNames = New Array;
	//arPointColumnNamesFields = New Array;
	arDateColumnNames = New Array;
	arRefColumnNames = New Array;
	arPointInTimeSearchQueries = New Array;

	For Each Column In vtData.Columns Do

		If Column.ValueType.ContainsType(Type("PointInTime")) Then

			ColumnName = Column.Name;
			DateColumnName = ColumnName + "_Date31415926";
			RefColumnName = ColumnName + "_Ref31415926";
			TempColumnName = ColumnName + "_Tmp31415926";

			arPointInTimeColumnNames.Add(ColumnName);
			arDateColumnNames.Add(DateColumnName);
			arRefColumnNames.Add(RefColumnName);

			arRemovedTypes = New Array;
			arRemovedTypes.Add(Type("PointInTime"));
			arAddedTypes = New Array;
			arAddedTypes.Add(Type("Null"));
			NoPointInTimeType = New TypeDescription(Column.ValueType, arAddedTypes, arRemovedTypes);
			// Column contains only the PointInTime type.
			// Hard to imagine a situation when there might be some type else in the column with a PointInTime. 
			PointInTimeOnly = NoPointInTimeType = New TypeDescription("Null");			                                                               	   

			vtData.Columns.Add(DateColumnName, New TypeDescription("Date", , ,
				New DateQualifiers(DateFractions.DateTime)));
			vtData.Columns.Add(RefColumnName, Documents.AllRefsType());

			If Not PointInTimeOnly Then
				vtData.Coolumns.Add(TempColumnName, NoPointInTimeType);
			EndIf;

			arPointInTimeRefTypes = New Array;

			If PointInTimeOnly Then

				For Each DataRow In vtData Do
					Value = DataRow[ColumnName];
					DataRow[DateColumnName] = Value.Date;
					DataRow[RefColumnName] = Value.Ref;
					arPointInTimeRefTypes.Add(TypeOf(Value.Ref));
				EndDo;

			Else

				For Each DataRow In vtData Do
					Value = DataRow[ColumnName];
					If TypeOf(Value) = Type("PointInTime") Then
						DataRow[TempColumnName] = Null;
						DataRow[DateColumnName] = Value.Date;
						DataRow[RefColumnName] = Value.Ref;
						arPointInTimeRefTypes.Add(TypeOf(Value.Ref));
					Else
						DataRow[TempColumnName] = Value;
					EndIf;
				EndDo;

			EndIf;

			vtData.Columns.Delete(ColumnName);
			If Not PointInTimeOnly Then
				vtData.Columns[TempColumnName].Name = ColumnName;
			EndIf;

			PointsInTimeTableNameFields = TempTableName + "_PointsInTimeTable_" + ColumnName;
			TextINTO = "INTO " + PointsInTimeTableNameFields;

			If PointInTimeOnly Then
				stNewFieldExpressions.Insert(ColumnName, StrTemplate("%1.PointInTime AS %2", PointsInTimeTableNameFields,
					ColumnName));
			Else
				stNewFieldExpressions.Insert(ColumnName, StrTemplate("ISNULL(Table.%1, %2.PointInTime) AS %3",
					ColumnName, PointsInTimeTableNameFields, ColumnName));
			EndIf;

			AdditionalSources = AdditionalSources + StrTemplate(
				" LEFT JOIN %1 AS %1 ON Table.%2 = %1.Date AND Table.%3 = %1.Ref", PointsInTimeTableNameFields,
				DateColumnName, RefColumnName);

			arPointsInTimeSearchSubqueries = New Array;

			arPointInTimeSearchMetadata = New Array;
			arPointInTimeSearchMetadata.Add(Metadata.AccumulationRegisters);
			arPointInTimeSearchMetadata.Add(Metadata.AccountingRegisters);

			PointInTimeRefTypes = New TypeDescription(arPointInTimeRefTypes);
			arPointInTimeRefTypes = PointInTimeRefTypes.Types();

			For Each Registers In arPointInTimeSearchMetadata Do

				If Registers = Metadata.AccumulationRegisters Then
					MetadataNameForQuery = "AccumulationRegister";
				ElsIf Registers = Metadata.AccountingRegisters Then
					MetadataNameForQuery = "AccountingRegister";
				Else
					MetadataNameForQuery = "?E001?";
				EndIf;

				For Each Register In Registers Do

					RecorderType = Register.StandardAttributes.Recorder.Type;
					For Each RefType In arPointInTimeRefTypes Do

						If RecorderType.ContainsType(RefType) Then

							arPointsInTimeSearchSubqueries.Add(PointInTimeSearchSubqueryText(
								MetadataNameForQuery, Register.Name, ColumnName, TempTableName,
								TextINTO));
							TextINTO = "";
							Break;

						EndIf;

					EndDo;

				EndDo;

			EndDo;

			If arPointsInTimeSearchSubqueries.Count() = 0 Then
				arPointsInTimeSearchSubqueries.Add(PointInTimeSearchSubqueryText(
					MetadataNameForQuery, Register.Name, ColumnName, TempTableName, TextINTO));
			EndIf;

			PointsInTimeSearchQueryText = StrConcat(arPointsInTimeSearchSubqueries, "
																				   |UNION
																				   |");

			If ValueIsFilled(PointsInTimeSearchQueryText) Then
				arPointInTimeSearchQueries.Add(PointsInTimeSearchQueryText);
			EndIf;

		EndIf;

	EndDo;

	If arDateColumnNames.Count() > 0 Then

		PointsInTimeSearchQueryTexts = StrConcat(arPointInTimeSearchQueries, ";
																			 |");

		arPointsInTimeDataQueries = New Array;

		For j = 0 To arDateColumnNames.UBound() Do
			arPointsInTimeDataQueries.Add(StrTemplate(
				"SELECT
				|	Table.%1 AS Date,
				|	Table.%2 AS Ref
				|INTO %4_PointsInTimeData_%3
				|FROM
				|	%4 AS Table", arDateColumnNames[j], arRefColumnNames[j], arPointInTimeColumnNames[j],
				TempTableName));
		EndDo;

		PointsInTimeDataQueryText = StrConcat(arPointsInTimeDataQueries, ";
																		   |
																		   |");

		AdditionalQueries = PointsInTimeDataQueryText + "; 
															 |
															 |" + PointsInTimeSearchQueryTexts;

	EndIf;

EndProcedure

&AtServer
Procedure PrepareTypeTypeColumnsSelection(vtData, TempTableName, stNewFieldExpressions,
	AdditionalSources, AdditionalQueries)

	DataProcessor = FormAttributeToValue("Object");

	For Each Column In vtData.Columns Do

		If Column.ValueType.ContainsType(Type("Type")) Then

			ColumnName = Column.Name;
			TypeColumnName = ColumnName + "_Type31415926";
			TempColumnName = ColumnName + "_Tmp31415926";

			arRemovedType = New Array;
			arRemovedType.Add(Type("Type"));
			arAddedType = New Array;
			arAddedType.Add(Type("Null"));
			NoTypeType = New TypeDescription(Column.ValueType, arAddedType, arRemovedType);
			// Column contains only the Type type.
			// Hard to imagine a situation when there might be some type else in the column with a Type.
			TypeOnly = NoTypeType = New TypeDescription("Null");

			vtData.Column.Add(TypeColumnName);
			If Not TypeOnly Then
				vtData.Columns.Add(TempColumnName, NoTypeType);
			EndIf;

			arTypes = New Array;

			If TypeOnly Then

				For Each DataRow In vtData Do
					arTypes.Add(DataRow[ColumnName]);
					TypeDescription = TypeDescriptionByType(DataRow[ColumnName]);
					Value = TypeDescription.AdjustValue(Undefined);
					DataRow[TypeColumnName] = Value;
				EndDo;

			Else

				For Each DataRow In vtData Do
					If TypeOf(DataRow[ColumnName]) = Type("Type") Then
						arTypes.Add(DataRow[ColumnName]);
						TypeDescription = TypeDescriptionByType(DataRow[ColumnName]);
						Value = TypeDescription.AdjustValue(Undefined);
						DataRow[TypeColumnName] = Value;
						DataRow[TempColumnName] = Null;
					Else
						DataRow[TempColumnName] = DataRow[ColumnName];
					EndIf;
				EndDo;

			EndIf;

			vtData.Columns.Delete(ColumnName);
			If Not TypeOnly Then
				vtData.Columns[TempColumnName].Name = ColumnName;
			EndIf;

			TypeColumnType = New TypeDescription(arTypes);
			DataProcessor.ChangeValueTableColumnType(vtData, TypeColumnName, TypeColumnType);
			
			//stFieldsExpression.Insert(stFieldsExpression

			If TypeOnly Then
				stNewFieldExpressions.Insert(ColumnName, "ValueType(Table." + TypeColumnName + ") AS "
					+ ColumnName);
			Else
				stNewFieldExpressions.Insert(ColumnName, "ISNULL(Table." + ColumnName + ", ValueType(Table."
					+ TypeColumnName + ")) AS " + ColumnName);
			EndIf;

		EndIf;

	EndDo;

EndProcedure

&AtServer
Procedure SetTypeToNoTypeColumns(vtData)

	DataProcessor = FormAttributeToValue("Object");
	EmptyType = New TypeDescription;
	arNoValueTypes = New Array;
	arNoValueTypes.Add("Undefined");
	arNoValueTypes.Add("Null");

	arProcessedColumns = New Array;
	arColumnsTypes = New Array;
	For Each Column In vtData.Columns Do
		//arTypes = Column.ValueType.Types();
		If Column.ValueType = EmptyType Then
			arProcessedColumns.Add(Column.Name);
			arColumnsTypes.Add(New Array);
		EndIf;
	EndDo;

	If arProcessedColumns.Count() > 0 Then

		For Each Row In vtData Do
			For j = 0 To arProcessedColumns.Count() - 1 Do
				ColumnName = arProcessedColumns[j];
				arColumnsTypes[j].Add(TypeOf(Row[ColumnName]));
			EndDo;
		EndDo;

		For j = 0 To arProcessedColumns.Count() - 1 Do

			ColumnName = arProcessedColumns[j];
			//TempColumnName = ColumnName + "_Tmp31415926";

			OldValueType = vtData.Columns[ColumnName].ValueType;
			NewColumnType = New TypeDescription(arColumnsTypes[j], OldValueType.NumberQualifiers,
				OldValueType.StringQualifiers, OldValueType.DateQualifiers,
				OldValueType.BinaryDataQualifiers);

			ValueTypes = New TypeDescription(NewColumnType, , arNoValueTypes);
			If ValueTypes = EmptyType Then
				NewColumnType = New TypeDescription(NewColumnType, "Number"); // You must to specify an any type for a capability to load in query.
				//Message(String(ColumnName) + " - column type is undefined, the Number type was specified.");//debug
			EndIf;

			DataProcessor.ChangeValueTableColumnType(vtData, ColumnName, NewColumnType);

		EndDo;

	EndIf;

EndProcedure

&AtServer
Procedure LoadTempTable(TableName, vtData, arLoadQueries, TablesLoadQuery)

	SetTypeToNoTypeColumns(vtData);

	arTableFields = New Array;
	For Each Column Из vtData.Columns Do
		arTableFields.Add(Column.Имя);
	EndDo;

	stNewFieldExpressions = New Structure;
	AdditionalSources = "";
	AdditionalQueries = "";
	TempTableName = TableName + "_Tmp31415926";
	PrepareTypeTypeColumnsSelection(vtData, TempTableName, stNewFieldExpressions,
		AdditionalSources, AdditionalQueries);
	PrepareMomentInTimeColumnsSelection(vtData, TempTableName, stNewFieldExpressions,
		AdditionalSources, AdditionalQueries);
	If stNewFieldExpressions.Count() > 0 Then

		arFieldExpressions = New Array;
		For Each Column In vtData.Columns Do
			Expression = "Table." + Column.Name + " AS " + Column.Name;
			arFieldExpressions.Add(Expression);
		EndDo;
		FieldExpressions = StrConcat(arFieldExpressions, ",
														 |");

		arLoadQueries.Add("
							 |SELECT
							 |" + FieldExpressions + "
													 |INTO " + TempTableName + "
																			   |FROM &" + TableName
			+ " AS Table");

		If ValueIsFilled(AdditionalQueries) Then
			arLoadQueries.Add(AdditionalQueries);
		EndIf;

		Source = TempTableName;

	Else
		Source = "&" + TableName;
	EndIf;

	Expression = Undefined;
	arFieldExpressions = New Array;
	For Each ColumnName In arTableFields Do
		If Not stNewFieldExpressions.Property(ColumnName, Expression) Then
			Expression = "Table." + ColumnName + " AS " + ColumnName;
		EndIf;
		arFieldExpressions.Add(Expression);
	EndDo;
	FieldExpressions = StrConcat(arFieldExpressions, ",
													 |");

	arLoadQueries.Add("
						 |SELECT
						 |" + FieldExpressions + "
												 |INTO " + TableName + "
																	   |FROM " + Source + " AS Table"
		+ " " + AdditionalSources);

	TablesLoadQuery.SetParameter(TableName, vtData);

EndProcedure

&AtServer
Function LoadTempTables()

	If TempTables.Count() = 0 Then
		Return New TempTablesManager;
	EndIf;

	TablesLoadQuery = New Query;
	TablesLoadQuery.TempTablesManager = New TempTablesManager;

	arLoadQueries = New Array;
	For Each TempTableRow In TempTables Do

		TableName = TempTableRow.Name;
		vtData = FormAttributeToValue("Object").Container_RestoreValue(TempTableRow.Container);
		LoadTempTable(TableName, vtData, arLoadQueries, TablesLoadQuery);

	EndDo;

	TablesLoadQuery.Text = StrConcat(arLoadQueries, ";
													|");

	TablesLoadQuery.Execute();

	Return TablesLoadQuery.TempTablesManager;

EndFunction

&AtServer
Procedure SelectionToTree(selSelection, Node, j, fContainersExists, DataProcessor, fMacrocolumnsExists, stMacrocolumns)

	NodeItems = Node.GetItems();

	While selSelection.Next() Do

		j = j + 1;

		If OutputLinesLimit > 0 And j > OutputLinesLimit Then
			Break;
		EndIf;

		QueryResultString = NodeItems.Add();
		FillPropertyValues(QueryResultString, selSelection);

		If fContainersExists Then
			DataProcessor.AddContainers(QueryResultString, selSelection, QueryResultContainerColumns);
		EndIf;

		If fMacrocolumnsExists Then
			DataProcessor.ProcessMacrocolumns(QueryResultString, selSelection, stMacrocolumns);
		EndIf;

		selChild = selSelection.Select(QueryResultIteration.ByGroups);
		If selChild.Count() > 0 Then
			SelectionToTree(selChild, QueryResultString, j, fContainersExists, DataProcessor, fMacrocolumnsExists,
				stMacrocolumns);
		EndIf;

	EndDo;

EndProcedure

&AtServer
Function ExtractResultAsValueTable()

	DataProcessor = FormAttributeToValue("Object");

	stQueryResult = GetFromTempStorage(QueryResultAddress);
	arQueryResult = stQueryResult.Result;
	stBatchResult = arQueryResult[Number(ResultInBatch) - 1];
	qrSelection = stBatchResult.Result;
	stMacrocolumns = stBatchResult.Macrocolumns;
	fMacrocolumnsExists = stMacrocolumns.Count() > 0;

	If fMacrocolumnsExists Then

		vtResult = New ValueTable;

		For Each Column In qrSelection.Columns Do
			vtResult.Columns.Add(Column.Name, Column.ValueType);
		EndDo;

		selSelection = qrSelection.Select();
		While selSelection.Next() Do
			Row = vtResult.Add();
			FillPropertyValues(Row, selSelection);
			DataProcessor.ProcessMacrocolumns(Row, selSelection, stMacrocolumns);
		EndDo;

	Else
		vtResult = qrSelection.Select();
	EndIf;

	Return vtResult;

EndFunction

&AtServer
Function ExtractResultAsContainer(fDeleteNullType = True)

	DataProcessor = FormAttributeToValue("Object");

	vt = ExtractResultAsValueTable();
	DataProcessor.ValueTable_DeleteNullType(vt);

	Return DataProcessor.Container_SaveValue(vt);

EndFunction

&AtServer
Procedure ResultRecordStructure_ExpandChildNodes(Row)
	Var Pictures;

	DataProcessor = FormAttributeToValue("Object");

	TreeRow = ResultRecordStructure.FiindByID(Row);

	For Each StructureItem In TreeRow.GetItems() Do

		If TypeOf(StructureItem.Type) = Type("TypeDescription") Then

			mapCounters = New Map;
			mapTypes = New Map;

			NoEmptyTypes = DataProcessor.NoEmptyType(StructureItem.Type);
			arTypes = NoEmptyTypes.Types();
			For Each Type In arTypes Do

				ItemMetadata = Undefined;
				If Catalogs.AllRefsType().ContainsType(Type) Or Documents.AllRefsType().ContainsType(Type)
					Or ChartsOfCharacteristicTypes.AllRefsType().ContainsType(Type)
					Or ChartsOfAccounts.AllRefsType().ContainsType(Type) Or ChartsOfCalculationTypes.AllRefsType().ContainsType(Type)
					Or BusinessProcesses.AllRefsType().ContainsType(Type) Or Tasks.AllRefsType().ContainsType(Type)
					Or ExchangePlans.AllRefsType().ContainsType(Type) Then
					ItemMetadata = TypeDescriptionByType(Type).AdjustValue(Undefined).Metadata();
				EndIf;

				If ItemMetadata <> Undefined Then

					arAttributeCollections = New Array;
					arAttributeCollections.Add(ItemMetadata.StandardAttributes);
					arAttributeCollections.Add(ItemMetadata.Attributes);

					For Each AttributeCollection In arAttributeCollections Do
						For Each Attribute In AttributeCollection Do

							K = mapCounters[Attribute.Name];
							K = ?(K = Undefined, 0, K);
							mapCounters[Attribute.Name] = K + 1;

							Types = mapTypes[Attribute.Name];
							If Types = Undefined Then
								Types = New Array;
							EndIf;

							For Each Type In Attribute.Type.Types() Do
								Types.Add(Type);
							EndDo;

							mapTypes[Attribute.Name] = Types;

						EndDo;
					EndDo;

				EndIf;

			EndDo;

			For Each kv In mapCounters Do

				If kv.Value = mapTypes.Count() Then // Adding only the attributes included into all types of the composite type.

					strName = kv.Key;
					arTypes = mapTypes[strName];
					NewStructureItem = StructureItem.GetItems().Add();
					NewStructureItem.Name = strName;
					NewStructureItem.Type = New TypeDescription(arTypes);

					NewStructureItem.Picture = DataProcessor.GetPictureByType(NewStructureItem.Type,
						Pictures);

				EndIf;

			EndDo;

		EndIf;

	EndDo;

	TreeRow.ChildNodesExpanded = True;

EndProcedure

&AtClient
Procedure ResultRecordStructure_Expand()
	TreeItems = ResultRecordStructure.GetItems();
	Items.ResultRecordStructure.Expand(TreeItems[0].GetID());
	Items.ResultRecordStructure.Expand(TreeItems[1].GetID());
	
	#Region UT_AfterResultRecordStructureRefresh
	
	UT_AddResultStructureContextAlgorithm();
	#EndRegion
EndProcedure

&AtServer
// Fills in the record structure using on the code execution page
Procedure ResultRecordStructure_FillRecordStructure(qrSelection = Undefined)
	Var Pictures;

	ResultRecordStructure.GetItems().Clear();

	If qrSelection = Undefined Then
		Return;
	EndIf;

	DataProcessor = FormAttributeToValue("Object");
	
	// All the data reqiured must be chosen in the query, not by expanding the properties in the selection.
	fExpandPropertiesInSelection = False;
	
	// Expanding properties in the parameters is not so bad.
	fExpandPropertiesInParameters = True;

	StructureItemSelection = ResultRecordStructure.GetItems().Add();
	StructureItemSelection.Name = "Selection";
	StructureItemSelection.ChildNodesExpanded = Not fExpandPropertiesInSelection;

	For Each Column In qrSelection.Columns Do
		StructureItem = StructureItemSelection.GetItems().Add();
		StructureItem.Name = Column.Name;
		StructureItem.Type = Column.ValueType;
		StructureItem.Picture = DataProcessor.GetPictureByType(DataProcessor.NoEmptyType(Column.ValueType),
			Pictures);
		StructureItem.ChildNodesExpanded = Not fExpandPropertiesInSelection;
	EndDo;

	StructureItemParameters = ResultRecordStructure.GetItems().Add();
	StructureItemParameters.Name = "Parameters";
	StructureItemParameters.ChildNodesExpanded = Not fExpandPropertiesInParameters;

	For Each ParameterRow In QueryParameters Do

		StructureItem = StructureItemParameters.GetItems().Add();
		StructureItem.Name = ParameterRow.Name;

		If ParameterRow.ContainerType = 1 Then
			ValueType = New TypeDescription("ValueList");
		ElsIf ParameterRow.ContainerType = 2 Then
			ValueType = New TypeDescription("Array");
		Else
			ValueType = ParameterRow.ValueType;
		EndIf;

		StructureItem.Type = ValueType;
		StructureItem.Picture = DataProcessor.GetPictureByType(DataProcessor.NoEmptyType(ValueType), Pictures);
		StructureItem.ChildNodesExpanded = Not fExpandPropertiesInParameters;

	EndDo;

EndProcedure

&AtServer
Function ExtractResult(nResult = Undefined)

	If nResult = ResultInForm Then
		Return 0;
	EndIf;

	If nResult <> Undefined Then
		ResultInForm = nResult;
	EndIf;

	ResultRecordsCount = ExtractResultToFormData(ResultInForm);

	ResultInBatch = ResultInForm;

	Items.QueryResultBatch.CurrentRow = QueryResultBatch[ResultInForm - 1].GetID();

	For Each Row In QueryResultBatch Do
		Row.Current = False;
	EndDo;
	QueryResultBatch[ResultInForm - 1].Current = True;

	Return ResultRecordsCount;

EndFunction

&AtServer
Function ExtractResultToFormData(ResultInBatch)

	DataProcessor = FormAttributeToValue("Object");

	fTree = ResultKind = "tree";
	If fTree Then
		ResultAttributeName = "QueryResultTree";
	Else
		ResultAttributeName = "QueryResult";
	EndIf;

	Items.RefreshResult.Enabled = True;
	Items.QueryResult.Visible = Not fTree;
	Items.ResultCommandBar.Visible = Not fTree;
	Items.ResultCommandBar.Enabled = Not fTree;
	Items.QueryResultTree.Visible = fTree;
	Items.ResultCommandBarTree.Visible = fTree;
	Items.ResultCommandBarTreeLeft.Visible = fTree;

	If Not ValueIsFilled(QueryResultAddress) Then
		ResultRecordStructure_FillRecordStructure();
		Return 0;
	EndIf;

	If Number(ResultInBatch) <= 0 Then
		FormAttributeToValue("Object").CreateTableAttributesByColumns(ThisForm, ResultAttributeName,
			"QueryResultColumnsMap", "QueryResultContainerColumns", Undefined);
		ResultRecordStructure_FillRecordStructure();
		Return 0;
	EndIf;

	Items.QueryResultControlGroup.Enabled = True;

	stQueryResult = GetFromTempStorage(QueryResultAddress);
	arQueryResult = stQueryResult.Result;
	stResult = arQueryResult[Number(ResultInBatch) - 1];
	qrSelection = stResult.Result;
	stMacrocolumns = stResult.Macrocolumns;
	MacrocolumnsExists = stMacrocolumns.Count() > 0;

	QueryResult.Clear();
	QueryResultTree.GetItems().Clear();
	DataProcessor.CreateTableAttributesByColumns(ThisForm, ResultAttributeName,
		"QueryResultColumnsMap", "QueryResultContainerColumns", ?(qrSelection = Undefined,
		Undefined, qrSelection.Columns), False, stMacrocolumns);

	If qrSelection = Undefined Then
		ResultRecordStructure_FillRecordStructure();
		Return 0;
	EndIf;

	arColumnList = New Array;
	For Each kvColumn In QueryResultColumnsMap Do
		arColumnList.Add(kvColumn.Value);
	EndDo;
	ColumnListString = StrConcat(arColumnList, ",");

	ContainersExists = QueryResultContainerColumns.Count() > 0;
	If Not MacrocolumnsExists And Not ContainersExists And (Not OutputLinesLimitEnabled Or OutputLinesLimit = 0) Then

		If fTree Then

			vtResult = qrSelection.Unload(QueryResultIteration.ByGroups);
			ValueToFormData(vtResult, QueryResultTree);
			ResultReturningRowsCount = qrSelection.Select().Count();

		Else

			vtResult = qrSelection.Unload();
			ValueToFormData(vtResult, QueryResult);

			ResultReturningRowsCount = vtResult.Count();

			If vtResult.Count() > 0 Then
				vtResult.GroupBy("", ColumnListString);
				FillPropertyValues(QueryResultTotals[0], vtResult[0]);
			EndIf;

		EndIf;

	Else

		If fTree Then

			selQuery = qrSelection.Select(QueryResultIteration.ByGroups);

			j = 0;
			SelectionToTree(selQuery, QueryResultTree, j, ContainersExists, DataProcessor, MacrocolumnsExists,
				stMacrocolumns);

			ResultReturningRowsCount = selQuery.Count();

		Else

			j = 0;
			selQuery = qrSelection.Select();
			While selQuery.Next() Do

				j = j + 1;

				If OutputLinesLimitEnabled And OutputLinesLimit > 0 And j > OutputLinesLimit Then
					Break;
				EndIf;

				QueryResultRow = QueryResult.Add();
				FillPropertyValues(QueryResultRow, selQuery);
				If ContainersExists Then
					DataProcessor.AddContainers(QueryResultRow, selQuery, QueryResultContainerColumns);
				EndIf;

				If MacrocolumnsExists Then
					DataProcessor.ProcessMacrocolumns(QueryResultRow, selQuery, stMacrocolumns);
				EndIf;

			EndDo;

			If OutputLinesLimitEnabled And OutputLinesLimit > 0 Then
				vtResult = FormDataToValue(QueryResult, Type("ValueTable"));
			Else
				vtResult = qrSelection.Unload();
			EndIf;

			If vtResult.Count() > 0 Then
				vtResult.GroupBy("", ColumnListString);
				FillPropertyValues(QueryResultTotals[0], vtResult[0]);
			EndIf;

			ResultReturningRowsCount = qrSelection.Select().Count();

		EndIf;

	EndIf;

	Items.QueryPlan.Visible = ValueIsFilled(stResult.QueryID);

	Items.QueryResultBatchInfo.CellHyperlink = Items.QueryPlan.Visible;

	ResultRecordStructure_FillRecordStructure(qrSelection);

	Return ResultReturningRowsCount;

EndFunction

#Region SavedStates

// Saved states - a structure for storing values not included into options (form flags states, 
// different values, etc.). Written to a file. Reading from the file only at the first opening.
// This is a duplication of object module code to avoid unnecessary server calls.
//
&AtClient
Procedure SavedStates_Save(ValueName, Value) Export

	If Not ValueIsFilled(Object.SavedStates) Then
		Object.SavedStates = New Structure;
	EndIf;

	Object.SavedStates.Insert(ValueName, Value);

EndProcedure

&AtClient
Function SavedStates_Get(ValueName, DefaultValue) Export
	Var Value;

	If Not ValueIsFilled(Object.SavedStates) Or Not Object.SavedStates.Property(ValueName,
		Value) Then
		Return DefaultValue;
	EndIf;

	Return Value;

EndFunction

&AtServer
Procedure SavedStates_SaveAtServer(ValueName, Value) Export

	If Not ValueIsFilled(Object.SavedStates) Then
		Object.SavedStates = New Structure;
	EndIf;

	Object.SavedStates.Insert(ValueName, Value);

EndProcedure

&AtServer
Function SavedStates_GetAtServer(ValueName, DefaultValue) Export
	Var Value;

	If Not ValueIsFilled(Object.SavedStates) Or Not Object.SavedStates.Property(ValueName,
		Value) Then
		Return DefaultValue;
	EndIf;

	Return Value;

EndFunction

#EndRegion

#Region QueryExecution

&AtServer
Function DisassembleMacrocolumnExpression(MacroExpressionString)

	stMacrocolumn = Undefined;

	arSubstrings = StrSplit(MacroExpressionString, "_");
	If arSubstrings.Count() > 1 Then

		strMacroType = arSubstrings[0];
		стрSourceColumn = Right(MacroExpressionString, StrLen(MacroExpressionString) - StrLen(strMacroType) - 1);

		ValueType = Undefined;
		If strMacroType = "UID" Then
			ValueType = New TypeDescription("UUID");
		EndIf;

		If ValueType <> Undefined Then
			stMacrocolumn = New Structure("Type, ValueType, SourceColumn", strMacroType, ValueType,
				стрSourceColumn);
		EndIf;

	EndIf;

	Return stMacrocolumn;

EndFunction

&AtServer
Function GetMacrocolumns(SchemaQuery)

	stMacrocolumns = New Structure;
	If Not Object.OptionProcessing__ Then
		Return stMacrocolumns;
	EndIf;

	MacroBeginString = "&" + MacroParameter;
	For Each Column In SchemaQuery.Columns Do

		If Column.Fields.Count() > 0 Then

			Expression = Column.Fields[0];
			If StrStartsWith(Expression, MacroBeginString) Then

				strMacroExpression = Right(Expression, StrLen(Expression) - StrLen(MacroBeginString));
				stMacrocolumn = DisassembleMacrocolumnExpression(strMacroExpression);
				If stMacrocolumn <> Undefined Then
					stMacrocolumns.Insert(Column.Pseudonym, stMacrocolumn);
				EndIf;

			EndIf;

		EndIf;

	EndDo;

	Return stMacrocolumns;

EndFunction

&AtServer
// Executes query by schema. Extracts info about every batch subquery (subquery type, temp table names, result rows count, etc.)
//
Function ExecuteBatch(Query, QuerySchema)
	
	//DataProcessor = FormAttributeToValue("Объект");

	arBatchResult = New Array;
	For Each SchemaQuery In QuerySchema.QueryBatch Do

		If TypeOf(SchemaQuery) = Type("QuerySchemaSelectQuery") Then

			If TechLogEnabledAndRunning Then
				QueryID = "i" + StrReplace(New UUID, "-", "");
				Query.Text = StrTemplate(
					"SELECT ""%2_begin"" INTO %2_begin; %1; SELECT ""%2_end"" INTO %2_end",
					SchemaQuery.GetQueryText(), QueryID);
			Else
				QueryID = Undefined;
				Query.Text = SchemaQuery.GetQueryText();
			EndIf;

			stMacrocolumns = GetMacrocolumns(SchemaQuery);
			QueryStartTime = CurrentUniversalDateInMilliseconds();
			arQueryResult = Query.ExecuteBatch(); //6345bb7034de4ad1b14249d2d7ac26dd
			QueryFinishTime = CurrentUniversalDateInMilliseconds();
			DurationInMilliseconds = QueryFinishTime - QueryStartTime;

			If Object.TechLogEnabled Then
				qrResult = arQueryResult[1];
			Else
				qrResult = arQueryResult[0];
			EndIf;

			If ValueIsFilled(SchemaQuery.PlacementTable) Then

				nRecordsCount = Undefined;
				selResult = qrResult.Select();
				If selResult.Next() Then
					nRecordsCount = selResult.Count;
				EndIf;

				Query.Text = "SELECT * FROM " + SchemaQuery.PlacementTable;
				qrTableResult = Query.Execute();
				stResult = New Structure("Result, TableName, ResultName, RecordCount, Macrocolumns, QueryStartTime, DurationInMilliseconds, TempTableCreation, QueryID",
					qrTableResult, SchemaQuery.PlacementTable, SchemaQuery.PlacementTable,
					nRecordsCount, stMacrocolumns, QueryStartTime, DurationInMilliseconds, True,
					QueryID);
				arBatchResult.Add(stResult);

			Else

				stResult = New Structure("Result, TableName, ResultName, RecordCount, Macrocolumns, QueryStartTime, DurationInMilliseconds, TempTableCreation, QueryID",
					qrResult, , "Result" + QuerySchema.QueryBatch.IndexOf(SchemaQuery),
					qrResult.Выбрать().Количество(), stMacrocolumns, QueryStartTime, DurationInMilliseconds,
					False, QueryID);
				arBatchResult.Add(stResult);

			EndIf;

		ElsIf TypeOf(SchemaQuery) = Type("QuerySchemaTableDropQuery") Then
			Query.Text = "DROP " + SchemaQuery.TableName;
			Query.Execute();
		Else
			Return NStr("ru = 'Неизвестный тип запроса схемы'; en = 'Unknown type of schema query'");
		EndIf;

	EndDo;

	Return arBatchResult;

EndFunction

&AtServer
Procedure SetQueryMacrocolumnParameters(Query)

	If Object.OptionProcessing__ Then

		ParametersCollection = Query.FindParameters();
		For Each QueryParameter In ParametersCollection Do

			If StrStartsWith(QueryParameter.Name, MacroParameter) Then
				Query.SetParameter(QueryParameter.Name, Null);
			EndIf;

		EndDo;

	EndIf;

EndProcedure

&AtServer
Function ExecuteQueryAtServer(QueryText)
	Var RowNumber, ColumnNumber;

	ExecutingQuery = New Query;
	ExecutingQuery.TempTablesManager = LoadTempTables();

	For Each ParameterRow In QueryParameters Do

		If Object.OptionProcessing__ And StrStartsWith(ParameterRow.Name, MacroParameter) Then
			Continue;
		EndIf;

		Value = QueryParameters_GetValue(ParameterRow.GetID());
		ExecutingQuery.SetParameter(ParameterRow.Name, Value);

	EndDo;

	QuerySchema = New QuerySchema;

	Try
		ExecutingQuery.Text = QueryText;
		SetQueryMacrocolumnParameters(ExecutingQuery);
		QuerySchema.SetQueryText(QueryText);
	Except
		ErrorString = ErrorDescription();
		DisassembleSpecifiedQueryError(ErrorString, ExecutingQuery, QueryText, RowNumber, ColumnNumber);
		Return New Structure("ErrorDescription, Row, Column, StartTime, FinishTime", ErrorString,
			RowNumber, ColumnNumber);
	EndTry;

	If OutputLinesLimitTopEnabled And OutputLinesLimitTop > 0 Then

		For Each SchemaQuery In QuerySchema.QueryBatch Do
			If TypeOf(SchemaQuery) = Type("QuerySchemaSelectQuery") And Not ValueIsFilled(
				SchemaQuery.PlacementTable) Then
				For Each Operator In SchemaQuery.Operators Do
					If Not ValueIsFilled(Operator.RetrievedRecordsCount) Then
						Operator.RetrievedRecordsCount = OutputLinesLimitTop;
					EndIf;
				EndDo;
			EndIf;
		EndDo;

	EndIf;

	StartTime = CurrentUniversalDateInMilliseconds();
	Try
		arQueryResult = ExecuteBatch(ExecutingQuery, QuerySchema);
		FinishTime = CurrentUniversalDateInMilliseconds();
		If TypeOf(arQueryResult) <> Type("Array") Then
			Raise arQueryResult;
		EndIf;
	Except
		FinishTime = CurrentUniversalDateInMilliseconds();
		ExecutingQuery.TempTablesManager = LoadTempTables();
		ErrorString = ErrorDescription();
		DisassembleSpecifiedQueryError(ErrorString, ExecutingQuery, QueryText, RowNumber, ColumnNumber);
		Return New Structure("ErrorDescription, Row, Column, StartTime, FinishTime", ErrorString,
			RowNumber, ColumnNumber, StartTime, FinishTime);
	EndTry;

	stResult = New Structure("Result, Parameters", arQueryResult, ExecutingQuery.Parameters);
	If ValueIsFilled(QueryResultAddress) Then
		QueryResultAddress = PutToTempStorage(stResult, QueryResultAddress);
	Else
		QueryResultAddress = PutToTempStorage(stResult, UUID);
	EndIf;

	Items.ResultInBatch.ChoiceList.Clear();
	QueryResultBatch.Clear();
	For j = 1 To arQueryResult.Count() Do

		stResult = arQueryResult[j - 1];
		Items.ResultInBatch.ChoiceList.Add(String(j), stResult.ResultName + " ("
			+ stResult.RecordCount + ")");

		BatchRow = QueryResultBatch.Add();
		BatchRow.Name = stResult.ResultName;
		BatchRow.ResultKind = ?(stResult.TempTableCreation, 0, 1);
		BatchRow.Info = StrTemplate("%1 / %2", stResult.RecordCount, FormatDuration(
			stResult.DurationInMilliseconds));

	EndDo;

	Return New Structure("ErrorDescription, Row, Column, StartTime, FinishTime, ResultCount", , ,
		, StartTime, FinishTime, arQueryResult.Count());

EndFunction

#EndRegion

&AtClient
Function MoveTreeRow(Tree, MovingRow, InsertIndex, NewParent, Level = 0)

	If Level = 0 Then

		If NewParent = Undefined Then
			NewRow = Tree.GetItems().Insert(InsertIndex);
		Else
			NewRow = NewParent.GetItems().Insert(InsertIndex);
		EndIf;

		FillPropertyValues(NewRow, MovingRow);
		MoveTreeRow(Tree, MovingRow, InsertIndex, NewRow, Level + 1);

		MovingRowParent = MovingRow.GetParent();
		If MovingRowParent = Undefined Then
			Tree.GetItems().Delete(MovingRow);
		Else
			MovingRowParent.GetItems().Delete(MovingRow);
		EndIf;

	Else

		For Each Row In MovingRow.GetItems() Do
			NewRow = NewParent.GetItems().Add();
			FillPropertyValues(NewRow, MovingRow);
			MoveTreeRow(Tree, Row, NewRow, InsertIndex, Level + 1);
		EndDo;

	EndIf;

	Return NewRow;

EndFunction

&AtClient
Procedure ConsoleError(ErrorString)
	Raise ErrorString;
EndProcedure

&AtClient
Procedure SetQueriesFileName(strFullName = "")

	QueriesFileName = strFullName;
	If ValueIsFilled(QueriesFileName) Then
		File = New File(strFullName);
		QueryBatch_DisplayingName = File.Name;
		QueryBatch_NameForToolTip = File.FullName;
	Else
		QueryBatch_DisplayingName = "Name";
		QueryBatch_NameForToolTip = "Name";
	EndIf;

	Items.QueryBatch.ChildItems.QueryListQuery.Title = QueryBatch_DisplayingName;
	Items.QueryBatch.ChildItems.QueryListQuery.ToolTip = QueryBatch_NameForToolTip;
	
EndProcedure

&AtClient
Function SaveWithQuestion(AdditionalParameters)

	If Modified Then
		ShowQueryBox(
			New NotifyDescription("AfterSaveQuestion", ThisForm, AdditionalParameters),
			NStr("ru = 'Имеется не сохраненный пакет запросов. Сохранить?'; en = 'Unsaved query batch exists. Do you want to save?'"), QuestionDialogMode.YesNoCancel, ,
			DialogReturnCode.Yes);
		Return False;
	EndIf;

	Return True;

EndFunction

&AtClient
Procedure CompletionAfterQuestion(QuestionResult, AdditionalParameters)

	If QuestionResult = DialogReturnCode.Yes Then
		SaveQueryBatch(New Structure("Completion", True));
	ElsIf QuestionResult = DialogReturnCode.No Then
		If ValueIsFilled(QueriesFileName) Then
			NotifyDescription = New NotifyDescription("CompletionAfterDeleting", ThisForm);
			BeginDeletingFiles(NotifyDescription, GetAutoSaveFileName(QueriesFileName));
		Else
			NotifyDescription = New NotifyDescription("CompletionAfterDeleting", ThisForm);
			BeginDeletingFiles(NotifyDescription, StateAutoSaveFileName);
		EndIf;
	ElsIf QuestionResult = DialogReturnCode.Cancel Then
	EndIf;

EndProcedure

&AtClient
Procedure CompletionAfterDeleting(AdditionalParameters) Export
	Modified = False;
	Close();
EndProcedure

&AtClient
Procedure Autosave(Notification = Undefined)

	PutEditingQuery();

	If ValueIsFilled(QueriesFileName) Then
		QueryBatch_Save(Notification, GetAutoSaveFileName(QueriesFileName));
		QueryBatch_Save( , StateAutoSaveFileName, True);
	Else
		QueryBatch_Save(Notification, StateAutoSaveFileName);
	EndIf;

EndProcedure

&AtClient
Function QueryParametersToValueList(ParametersFormDataCollection)

	vlQueryParameters = New ValueList;
	For Each ParameterRow In ParametersFormDataCollection Do
		stParameter = New Structure("Name, ValueType, Value, ContainerType, Container");
		FillPropertyValues(stParameter, ParameterRow);
		vlQueryParameters.Add(stParameter);
	EndDo;

	Return vlQueryParameters;

EndFunction

&AtClient
Function TempTablesToValueList(TempTablesFormDataCollection)

	vlTempTables = New ValueList;
	For Each TableRow In TempTablesFormDataCollection Do
		stTable = New Structure("Name, Container, Value");
		FillPropertyValues(stTable, TableRow);
		vlTempTables.Add(stTable);
	EndDo;

	Return vlTempTables;

EndFunction

&AtClient
Procedure QueryParametersFromValueList(vlParameters, ParametersFormDataCollection)

	ParametersFormDataCollection.Clear();

	If vlParameters <> Undefined Then

		For Each kvParameter In vlParameters Do
			FillPropertyValues(ParametersFormDataCollection.Add(), kvParameter.Value);
		EndDo;

	EndIf;

EndProcedure

&AtClient
Procedure TempTablesFromValueList(vlTempTables, TempTablesFormDataCollection)

	TempTablesFormDataCollection.Clear();

	If vlTempTables <> Undefined Then

		For Each kvTable In vlTempTables Do
			FillPropertyValues(TempTablesFormDataCollection.Add(), kvTable.Value);
		EndDo;

	EndIf;

EndProcedure

&AtClient
Procedure RefreshAlgorithmFormItems()
	
	// If BackgroundJobID is filled, code executes in the background job.
	// In this case, items will be refreshed in the progress refresh procedures.
	If Not ValueIsFilled(BackgroundJobID) Then

		If Items.QueryBatch.CurrentData <> Undefined И ResultQueryName
			= Items.QueryBatch.CurrentData.Name Then
			Items.ExecuteDataProcessor.Enabled = True;
			ExecutionStatus = "";
			Items.ResultRecordStructure.Enabled = True;
		Else
			Items.ExecuteDataProcessor.Enabled = False;
			ExecutionStatus = NStr("ru = '(запрос не выполнен)'; en = 'query was not executed'");
			Items.ResultRecordStructure.Enabled = False;
		EndIf;
	EndIf;

EndProcedure

&AtClientAtServerNoContext
Function ConsoleDataProcessorName(Form)
	FormNameArray=StrSplit(Form.FormName, ".");
	Return FormNameArray[1];
EndFunction

#Region QueryParameters

// Processing of query parameter storing as a table QueryParameters row.
// RowID - this table row ID.

&AtServer
Function QueryParameters_GetValue(RowID)

	ParameterRow = QueryParameters.FindByID(RowID);

	If ParameterRow.ContainerType = 0 Or ParameterRow.ContainerType = 1 Or ParameterRow.ContainerType = 2
		Or ParameterRow.ContainerType = 3 Then
		Return FormAttributeToValue("Object").Container_RestoreValue(ParameterRow.Container);
	Else
		Raise NStr("ru = 'Ошибка в типе контейнера параметра'; en = 'Parameter container type error.'");
	EndIf;

EndFunction

&AtServer
Procedure QueryParameters_SaveValue(RowID, Val Value)

	ParameterRow = QueryParameters.НайтиПоИдентификатору(RowID);

	If ParameterRow.ContainerType = 0 Then
		ParameterRow.Container = FormAttributeToValue("Object").Container_SaveValue(Value);
		If TypeOf(ParameterRow.Container) = Type("Structure") Then
			ParameterRow.Value = ParameterRow.Container.Presentation;
		Else
			ParameterRow.Value = Value;
		EndIf;
	ElsIf ParameterRow.ContainerType = 1 Then
		ParameterRow.Container = FormAttributeToValue("Object").Container_SaveValue(Value);
		ParameterRow.Value = ParameterRow.Container.Presentation;
	ElsIf ParameterRow.ContainerType = 2 Then
		ParameterRow.Container = FormAttributeToValue("Object").Container_SaveValue(Value);
		ParameterRow.Value = ParameterRow.Container.Presentation;
	ElsIf ParameterRow.ContainerType = 3 Then
		ParameterRow.ValueType = NStr("ru = 'Таблица значений'; en = 'Value table'");
		ParameterRow.Container = FormAttributeToValue("Object").Container_SaveValue(Value);
		ParameterRow.Value = ParameterRow.Container.Presentation;
	Else
		Raise NStr("ru = 'Ошибка в типе контейнера параметра'; en = 'Parameter container type error.'");
	EndIf;

	Modified = True;

EndProcedure

&AtServer
// Type 1 and 2 containers (value list and array) returns as array.
Function Container12ToArray(Container)

	Value = FormAttributeToValue("Object").Container_RestoreValue(Container);

	If TypeOf(Value) = Type("ValueList") Then
		Return Value.UnloadValues();
	ElsIf TypeOf(Value) = Type("Array") Then
		Return Value;
	EndIf;

	Return Undefined;

EndFunction

&AtServer
Procedure QueryParameters_SetType(RowID, ContainerType, ValueType)

	ParameterRow = QueryParameters.FindByID(RowID);
	Container = ParameterRow.Container;

	If ContainerType = 1 Or ContainerType = 2 Then

		If ParameterRow.ContainerType = 1 Or ParameterRow.ContainerType = 2 Then
			ContainerArray = Container12ToArray(Container);
		ElsIf ParameterRow.ContainerType = 3 Then
			Table = FormAttributeToValue("Object").Container_RestoreValue(Container);
			ContainerArray = Table.UnloadColumn(0);
		ElsIf ParameterRow.ContainerType = 0 Then

			ContainerArray = New Array;

			ContainerArray.Add(FormAttributeToValue("Object").Container_RestoreValue(Container));
			//If ValueIsFilled(ParameterRow.Value) Then
			//	ContainerArray.Add(ParameterRow.Value);
			//EndIf;

			ParameterRow.Value = Undefined;

		EndIf;

		If ContainerType = 1 Then
			NewList = New ValueList;
			NewList.LoadValues(ContainerArray);
			NewList.ValueType = ValueType;
			ParameterRow.Container = FormAttributeToValue("Object").Container_SaveValue(NewList);
		ElsIf ContainerType = 2 Then
			NewList = New ValueList;
			NewList.LoadValues(ContainerArray);
			NewList.ValueType = ValueType;
			ContainerArray = NewList.UnloadValues();
			ParameterRow.Container = FormAttributeToValue("Object").Container_SaveValue(ContainerArray);
		EndIf;

	ElsIf ContainerType = 3 Then

		If ParameterRow.ContainerType = 1 Or ParameterRow.ContainerType = 2 Then
			Table = FormAttributeToValue("Object").Container_RestoreValue(ValueType);
			Value = FormAttributeToValue("Object").Container_RestoreValue(Container);
			If TypeOf(Value) = Type("ValueList") Then
				Value = Value.UnloadValues();
			EndIf;
			For Each j In Value Do
				Table.Add()[0] = j;
			EndDo;
			NewContainer = FormAttributeToValue("Object").Container_SaveValue(Table);
		ElsIf ParameterRow.ContainerType = 3 Then
			Container = ValueType;
			// CopyType3ContainerData(Container, ParameterRow.Container);
			NewContainer = Container;
		ElsIf ParameterRow.ContainerType = 0 Then
			Table = FormAttributeToValue("Object").Container_RestoreValue(ValueType);
			Table.Add()[0] = ParameterRow.Value;
			NewContainer = FormAttributeToValue("Object").Container_SaveValue(Table);
		EndIf;

		ParameterRow.Container = NewContainer;

	ElsIf ContainerType = 0 Then

		If ParameterRow.ContainerType = 1 Or ParameterRow.ContainerType = 2 Then
			ContainerArray = Container12ToArray(Container);
			If ContainerArray.Count() > 0 Then
				ParameterRow.Container = FormAttributeToValue("Object").Container_SaveValue(
					ValueType.AdjustValue(ContainerArray[0]));
			EndIf;
		ElsIf ParameterRow.ContainerType = 3 Then
			vl = QueryParametersFormOnChangeVLFromVT(Container);
			If vl.Count() > 0 Then
				ParameterRow.Container = FormAttributeToValue("Object").Container_SaveValue(
					ValueType.AdjustValue(vl.ValueList[0].Value));
			EndIf;
		ElsIf ParameterRow.ContainerType = 0 Then
			ParameterRow.Container = FormAttributeToValue("Object").Container_SaveValue(
				ValueType.AdjustValue(FormAttributeToValue("Object").Container_RestoreValue(
				ParameterRow.Container)));
		EndIf;

	EndIf;

	ParameterRow.ContainerType = ContainerType;
	If ParameterRow.ContainerType = 3 Then
		ParameterRow.ValueType = NStr("ru = 'Таблица значений'; en = 'Value table'");
	Else
		ParameterRow.ValueType = ValueType;
	EndIf;

	Modified = True;

	If TypeOf(ParameterRow.Container) = Type("Structure") Then
		ParameterRow.Value = ParameterRow.Container.Presentation;
	Else
		ParameterRow.Value = ParameterRow.Container;
	EndIf;

EndProcedure

//@skip-warning
&AtServer
Procedure CopyType3ContainerData(ContainerNew, ContainerOld)

	DataProcessor = FormAttributeToValue("Object");
	TableNew = DataProcessor.StringToValue(ContainerNew.Значение);
	TableOld = DataProcessor.StringToValue(ContainerOld.Значение);

	TableNew.Clear();
	
	// If there is no identical columns, there is nothing to copy.
	fIdenticalExists = False;
	For Each ColumnNew In TableNew.Columns Do
		If TableOld.Columns.Find(ColumnNew.Name) <> Undefined Then
			fIdenticalExists = True;
			Break;
		EndIf;
	EndDo;

	If fIdenticalExists Then
		For Each RowOld In TableOld Do
			RowNew = TableNew.Add();
			FillPropertyValues(RowNew, RowOld);
		EndDo;
		ContainerNew.RowCount = ContainerOld.RowCount;
	Else
		ContainerNew.RowCount = 0;
	EndIf;

	ContainerNew.Value = DataProcessor.ValueToString(TableNew);
	ContainerNew.Presentation = DataProcessor.Container_GetPresentation(ContainerNew);

EndProcedure

&AtServer
Function QueryParameters_GetAsString()

	vtParameters = New ValueTable;
	vtParameters.Columns.Add("Name", New TypeDescription("String"));
	vtParameters.Columns.Add("Value");
	For Each ParameterRow In QueryParameters Do
		TableRow = vtParameters.Add();
		TableRow.Name = ParameterRow.Name;
		TableRow.Value = QueryParameters_GetValue(ParameterRow.GetID());
	EndDo;

	Return FormAttributeToValue("Object").ValueToString(vtParameters);

EndFunction

#EndRegion //QueryParameters

#Region QueryBatch

&AtClient
Procedure InitializeQuery(CurrentRow)

	If Not ValueIsFilled(CurrentRow.Name) Then
		QueryCount = QueryCount + 1;
		CurrentRow.Name = "Query" + QueryCount;
	EndIf;

	CurrentRow.Initialized = True;

EndProcedure

&AtClient
Procedure PutEditingQuery()
	If EditingQuery >= 0 Then
		strQueryText = QueryText;
		strAlgorithmText = CurrentAlgorithmText();
		
		AlgorithmSelectionBoundaries = AlgorithmSelectionBoundaries();	
		QuerySelectionBoundaries = QuerySelectionBoundaries();	
			
		Query_PutQueryData(EditingQuery, strQueryText, strAlgorithmText, CodeExecutionMethod,
			QueryParametersToValueList(QueryParameters), TempTablesToValueList(TempTables),
			QuerySelectionBoundaries.RowBeginning, QuerySelectionBoundaries.ColumnBeginning,
			QuerySelectionBoundaries.RowEnd, QuerySelectionBoundaries.ColumnEnd,
			AlgorithmSelectionBoundaries.RowBeginning, AlgorithmSelectionBoundaries.ColumnBeginning,
			AlgorithmSelectionBoundaries.RowEnd, AlgorithmSelectionBoundaries.ColumnEnd);
	EndIf;

EndProcedure

&AtClient
Procedure SetQueryEditingAvailability(Enabled)
	Items.QueryText.ReadOnly = Not Enabled;
	Items.QueryCommandBarGroup.Enabled = Enabled;
EndProcedure

&AtClient
Procedure ExtractEditingQuery(BesidesThisQuery = Undefined, RestoreEditingPosition = True)
	CurrentRow = Items.QueryBatch.CurrentRow;

	If EditingQuery <> BesidesThisQuery Then
		PutEditingQuery();
	EndIf;

	If CurrentRow = Undefined Then
		QueryText = "";
		SetAlgorithmText("");
		SetQueryEditingAvailability(False);
		Items.QueryGroupPages.ChildItems.QueryPage.Title = NStr("ru = 'Запрос'; en = 'Query'");
		QueryParameters.Clear();
		TempTables.Clear();
		Return;
	EndIf;

	stQueryData = Query_GetQueryData(CurrentRow);

	QueryText = stQueryData.Query;

	SetAlgorithmText(stQueryData.CodeText);
	CodeExecutionMethod = stQueryData.CodeExecutionMethod;

	QueryParametersFromValueList(stQueryData.Parameters, QueryParameters);
	TempTablesFromValueList(stQueryData.TempTables, TempTables);

	If stQueryData.InWizard Then
		SetQueryEditingAvailability(False);
		Items.QueryGroupPages.ChildItems.QueryPage.Title = NStr("ru = 'Запрос (в конструкторе)'; en = 'Query (in wizard)'");
	Else
		SetQueryEditingAvailability(True);
		Items.QueryGroupPages.ChildItems.QueryPage.Title = NStr("ru = 'Запрос'; en = 'Query'");
	EndIf;

	EditingQuery = Items.QueryBatch.CurrentRow;

	RefreshAlgorithmFormItems();

	If RestoreEditingPosition Then
		AttachIdleHandler("EditingPositionRestoring", 0.01, True);
	EndIf;

EndProcedure

&AtClient
Procedure EditingPositionRestoring()

	CurrentRow = Items.QueryBatch.CurrentRow;
	stQueryData = Query_GetQueryData(CurrentRow);

	SetQuerySelectionBounds(stQueryData.CursorBeginRow, stQueryData.CursorBeginColumn,
		stQueryData.CursorEndRow, stQueryData.CursorEndColumn);

	SetAlgorithmSelectionBounds(stQueryData.CodeCursorBeginRow, stQueryData.CodeCursorBeginColumn,
		stQueryData.CodeCursorEndRow, stQueryData.CodeCursorEndColumn);

	If Items.QueryGroupPages.CurrentPage = Items.QueryPage Then
		CurrentItem = Items.QueryText;
	ElsIf Items.QueryGroupPages.CurrentPage = Items.AlgorithmPage Then
		CurrentItem = Items.AlgorithmText;
	EndIf;

EndProcedure

&AtClient
Procedure QueryBatch_Initialize(Item = Undefined)

	If Item = Undefined Then
		Item = QueryBatch;
	EndIf;

	For Each ChildItem In Item.GetItems() Do
		ChildItem.InWizard = False;
		QueryBatch_Initialize(ChildItem);
	EndDo;

EndProcedure

&AtClient
Procedure QueryBatch_New()

	QueryBatch.GetItems().Clear();
	QueryCount = 0;
	InitializeQuery(QueryBatch.GetItems().Add());
	QueryBatch_Initialize();
	Modified = False;
	SetQueriesFileName();
	EditingQuery = -1;

	AutoSaveIntervalOption = 60;
	SaveCommentsOption = True;
	AutoSaveBeforeQueryExecutionOption = True;
	//AlgorithmExecutionUpdateIntervalOption = 1000;
	TechLogSwitchingPollingPeriodOption = 3;
	Object.OptionProcessing__ = True;
	Object.AlgorithmExecutionUpdateIntervalOption = 1000;

EndProcedure

&AtClient
Function QueryBatch_RowsToArray(Rows)

	arRows = New Array;

	For Each Item In Rows.GetItems() Do
		stItem = New Structure("Name, QueryText, CodeText, CodeExecutionMethod, QueryParameters, TempTables, Rows, Info,
									|CursorBeginRow, CursorBeginColumn, CursorEndRow, CursorEndColumn,
									|CodeCursorBeginRow, CodeCursorBeginColumn, CodeCursorEndRow, CodeCursorEndColumn");
		FillPropertyValues(stItem, Item);
		stItem.Rows = QueryBatch_RowsToArray(Item);
		arRows.Add(stItem);
	EndDo;

	Return arRows;

EndFunction

&AtServerNoContext
Function QueryBatch_SaveAtServer(Val stWritingData)
	Writer = New XMLWriter;
	Writer.SetString();
	XDTOSerializer.WriteXML(Writer, stWritingData, XMLTypeAssignment.Explicit);
	Return Writer.Close();
EndFunction

&AtClient
Procedure QueryBatch_Save(Notification, strFileName, fTitleOnly = False)

	CurrentRow = Items.QueryBatch.CurrentRow;

	BatchCurrentRow = Undefined;
	If CurrentRow <> Undefined Then
		BatchCurrentRow = QueryBatch.НайтиПоИдентификатору(CurrentRow);
	EndIf;
	
	//saved states ++
	SavedStates_Save("ResultKind", ResultKind);
	SavedStates_Save("OutputLinesLimit", OutputLinesLimit);
	SavedStates_Save("OutputLinesLimitEnabled", OutputLinesLimitEnabled);
	SavedStates_Save("OutputLinesLimitTop", OutputLinesLimitTop);
	SavedStates_Save("OutputLinesLimitTopEnabled", OutputLinesLimitTopEnabled);
	//saved states --
	
	//stQueryBatch = New Array;

	stOptions = New Structure("
							  |SaveCommentsOption,
							  |AutoSaveBeforeQueryExecutionOption,
							  |TechLogSwitchingPollingPeriodOption,
							  |OptionProcessing__,
							  |AlgorithmExecutionUpdateIntervalOption,
							  |AutoSaveIntervalOption", SaveCommentsOption,
		AutoSaveBeforeQueryExecutionOption, TechLogSwitchingPollingPeriodOption,
		Object.OptionProcessing__, Object.AlgorithmExecutionUpdateIntervalOption, AutoSaveIntervalOption);

	stWritingData = New Structure("
										|Format,      
										|Version,
										|QueryCount,
										|FileName,
										|SavedStates,
										|CurrentQuery,
										|Options", ConsoleSignature, FormatVersion, QueryCount, QueriesFileName,
		Object.SavedStates, ?(BatchCurrentRow <> Undefined, BatchCurrentRow.Name, Undefined),
		stOptions);

	If Not fTitleOnly Then
		stWritingData.Insert("QueryBatch", QueryBatch_RowsToArray(QueryBatch));
	EndIf;

	WritingData = QueryBatch_SaveAtServer(stWritingData);

	WritingDocument = New TextDocument;
	WritingDocument.SetText(WritingData);
	WritingDocument.BeginWriting(Notification, strFileName);

EndProcedure

&AtClient
Procedure QueryBatch_AddRowsFromArray(Row, arItems)

	RowItems = Row.GetItems();

	For Each stItem In arItems Do
		Item = RowItems.Add();
		FillPropertyValues(Item, stItem);
		QueryBatch_AddRowsFromArray(Item, stItem.Rows);
	EndDo;

EndProcedure

&AtServerNoContext
Function QueryBatch_LoadAtServer(Val strLoadedData)

	Reader = New XMLReader;
	Reader.SetString(strLoadedData);
	stLoadedData = XDTOSerializer.ReadXML(Reader);
	Reader.Close();

	Return stLoadedData;

EndFunction

&AtClient
Function QueryBatch_CurrentQuery()
	Return Items.QueryBatch.CurrentRow;
EndFunction

// Loads query batch.
// If file contains title only, returns title (except the saved states, if they are empty).
&AtClient
Procedure QueryBatch_Load(AdditionalParameters)
	ReadingDocument = New TextDocument;
	AdditionalParameters.Insert("Reading", ReadingDocument);
	Notification = New NotifyDescription("QueryBatch_LoadCompletion", ThisForm, AdditionalParameters,
		"QueryBatch_LoadError", ThisForm);
	ReadingDocument.BeginReading(Notification, AdditionalParameters.FileName);
EndProcedure

&AtClient
Procedure QueryBatch_LoadError(ErrorInfo, StandardProcessing, AdditionalParameters) Export
	AdditionalParameters.Insert("LoadedData");
	AdditionalParameters.Insert("ErrorInfo", ErrorInfo);
	ExecuteContinuation(AdditionalParameters);
EndProcedure

&AtClient
Procedure QueryBatch_LoadCompletion(AdditionalParameters) Export

	strLoadedData = AdditionalParameters.Reading.GetText();

	stLoadedData = QueryBatch_LoadAtServer(strLoadedData);

	fOK = True;
	fOK = fOK And stLoadedData.Property("Format");
	fOK = fOK And stLoadedData.Format = ConsoleSignature;
	fOK = fOK And stLoadedData.Property("Version");

	If Not fOK Then
		ConsoleError(NStr("ru = 'Не верный формат файла!'; en = 'File format is incorrect.'"));
	EndIf;

	If stLoadedData.Version > FormatVersion Then
		ConsoleError(NStr("ru = 'Используется более новая версия формата. Обновите консоль запросов!'; en = 'A newer format version is required. Please update the query console.'"));
	EndIf;
	
	// Saved states - a structure for storing values not included into options (form flags states, 
	// different values, etc.). Written to a file. Reading from the file only at the first opening.
	If Not ValueIsFilled(Object.SavedStates) Then
		If stLoadedData.Version >= 11 Then
			Object.SavedStates = stLoadedData.SavedStates;
		Else
			Object.SavedStates = New Structure;
		EndIf;
	EndIf;

	If Not stLoadedData.Property("QueryBatch") Then
		AdditionalParameters.Insert("LoadedData", stLoadedData);
		ExecuteContinuation(AdditionalParameters);
		Return;
	EndIf;

	If stLoadedData.Version >= 2 Then
		stOptions = stLoadedData.Options;
		SaveCommentsOption = stOptions.SaveCommentsOption;
	Else
		SaveCommentsOption = True;
	EndIf;

	If stLoadedData.Version >= 3 Then
		AutoSaveIntervalOption = stOptions.AutoSaveIntervalOption;
	Else
		AutoSaveIntervalOption = 60;
	EndIf;

	If stLoadedData.Version >= 6 Then
		AutoSaveBeforeQueryExecutionOption = stOptions.AutoSaveBeforeQueryExecutionOption;
	Else
		AutoSaveBeforeQueryExecutionOption = True;
	EndIf;

	If stLoadedData.Version >= 8 Then
		Object.OptionProcessing__ = stOptions.OptionProcessing__;
	Else
		Object.OptionProcessing__ = True;
	EndIf;

	If stLoadedData.Version >= 10 Then
		Object.AlgorithmExecutionUpdateIntervalOption = stOptions.AlgorithmExecutionUpdateIntervalOption;
	Else
		Object.AlgorithmExecutionUpdateIntervalOption = 1000;
	EndIf;

	If stLoadedData.Version >= 12 Then
		TechLogSwitchingPollingPeriodOption = stOptions.TechLogSwitchingPollingPeriodOption;
	Else
		TechLogSwitchingPollingPeriodOption = 3;
	EndIf;

	If stLoadedData.Version >= 13 Then
		CurrentQueryName = stLoadedData.CurrentQuery;
	Else
		CurrentQueryName = Undefined;
	EndIf;

	QueryCount = stLoadedData.QueryCount;

	QueryBatch.GetItems().Clear();
	QueryBatch_AddRowsFromArray(QueryBatch, stLoadedData.QueryBatch);

	For Each BatchItem In QueryBatch.GetItems() Do
		Items.QueryBatch.Expand(BatchItem.GetID(), True);
	EndDo;

	QueryBatch_Initialize();

	CurrentRow = QueryBatch_FindByName(CurrentQueryName);
	If CurrentRow <> Undefined
		And Items.QueryBatch.CurrentRow <> CurrentRow Then
		Items.QueryBatch.CurrentRow = CurrentRow;
	EndIf;

	Modified = False;

	EditingPositionRestoring();

	AdditionalParameters.Insert("LoadedData", stLoadedData);
	ExecuteContinuation(AdditionalParameters);

EndProcedure

Function QueryBatch_FindByName(QueryName, Val Node = Undefined)

	If Node = Undefined Then
		Node = QueryBatch;
	EndIf;

	For Each Row In Node.GetItems() Do

		If Row.Name = QueryName Then
			Return Row.GetID();
		EndIf;

		j = QueryBatch_FindByName(QueryName, Row);
		If j <> Undefined Then
			Return j;
		EndIf;

	EndDo;

	Return Undefined;

EndFunction

#EndRegion

#Region Query

&AtClient
Function Query_GetQueryData(QueryID)

	If QueryID = Undefined Then
		Return New Structure("Name, Query, CodeText, CodeExecutionMethod, Parameters, InWizard, CursorBeginRow, CursorBeginColumn, CursorEndRow, CursorEndColumn, CodeCursorBeginRow, CodeCursorBeginColumn, CodeCursorEndRow, CodeCursorEndColumn",
			"", "", "", 2, Undefined, False, 1, 1, 1, 1, 1, 1, 1, 1);
	EndIf;

	QueryRow = QueryBatch.FindByID(QueryID);
	Return New Structure("Name, Query, CodeText, CodeExecutionMethod, Parameters, TempTables, InWizard, CursorBeginRow, CursorBeginColumn, CursorEndRow, CursorEndColumn, CodeCursorBeginRow, CodeCursorBeginColumn, CodeCursorEndRow, CodeCursorEndColumn",
		QueryRow.Name, QueryRow.QueryText, QueryRow.CodeText, QueryRow.CodeExecutionMethod,
		QueryRow.QueryParameters, QueryRow.TempTables, QueryRow.InWizard,
		QueryRow.CursorBeginRow + 1, QueryRow.CursorBeginColumn + 1, QueryRow.CursorEndRow
		+ 1, QueryRow.CursorEndColumn + 1, QueryRow.CodeCursorBeginRow + 1,
		QueryRow.CodeCursorBeginColumn + 1, QueryRow.CodeCursorEndRow + 1,
		QueryRow.CodeCursorEndColumn + 1);

EndFunction

&AtClient
Procedure Query_PutQueryData(QueryID, strQueryText, strCodeText = Undefined,
	CodeExecutionMethod = Undefined, vlQueryParameters = Undefined, vlTempTables = Undefined,
	CursorBeginRow = Undefined, CursorBeginColumn = Undefined, CursorEndRow = Undefined,
	CursorEndColumn = Undefined, CodeCursorBeginRow = Undefined, CodeCursorBeginColumn = Undefined,
	CodeCursorEndRow = Undefined, CodeCursorEndColumn = Undefined)

	QueryRow = QueryBatch.FindByID(QueryID);
	If QueryRow = Undefined Then
		Return;
	EndIf;

	QueryRow.QueryText = strQueryText;

	If strCodeText <> Undefined Then
		QueryRow.CodeText = strCodeText;
	EndIf;

	If vlQueryParameters <> Undefined Then
		QueryRow.QueryParameters = vlQueryParameters;
	EndIf;

	If vlTempTables <> Undefined Then
		QueryRow.TempTables = vlTempTables;
	EndIf;

	If CodeExecutionMethod <> Undefined Then
		QueryRow.CodeExecutionMethod = CodeExecutionMethod;
	EndIf;

	If CursorBeginRow <> Undefined Then
		QueryRow.CursorBeginRow = CursorBeginRow - 1;
	EndIf;

	If CursorBeginColumn <> Undefined Then
		QueryRow.CursorBeginColumn = CursorBeginColumn - 1;
	EndIf;

	If CursorEndRow <> Undefined Then
		QueryRow.CursorEndRow = CursorEndRow - 1;
	EndIf;

	If CursorEndColumn <> Undefined Then
		QueryRow.CursorEndColumn = CursorEndColumn - 1;
	EndIf;

	If CodeCursorBeginRow <> Undefined Then
		QueryRow.CodeCursorBeginRow = CodeCursorBeginRow - 1;
	EndIf;

	If CodeCursorBeginColumn <> Undefined Then
		QueryRow.CodeCursorBeginColumn = CodeCursorBeginColumn - 1;
	EndIf;

	If CodeCursorEndRow <> Undefined Then
		QueryRow.CodeCursorEndRow = CodeCursorEndRow - 1;
	EndIf;

	If CodeCursorEndColumn <> Undefined Then
		QueryRow.CodeCursorEndColumn = CodeCursorEndColumn - 1;
	EndIf;

EndProcedure

&AtClient
Procedure Query_SetInWizard(QueryID, fInWizard)
	QueryBatch.FindByID(QueryID).InWizard = fInWizard;
EndProcedure

&AtClient
Function Query_GetInWizard(QueryID)
	Return QueryBatch.FindByID(QueryID).InWizard;
EndFunction

#EndRegion

#Region ProcessingQueryComments

&AtClient
Procedure QueryComments_SaveSourceQueryData(strQueryText)

	If Not SaveCommentsOption Then
		Return;
	EndIf;

	CommentsData = strQueryText;

EndProcedure

&AtClient
Function QueryComments_LineWithoutComments(Line)

	nCommentLocation = Find(Line, "//");

	If nCommentLocation = 0 Then
		Return Line;
	EndIf;

	Return Left(Line, nCommentLocation - 1);

EndFunction

&AtClient
Function QueryComments_LineComment(Line)

	nCommentLocation = Find(Line, "//");

	If nCommentLocation = 0 Then
		Return "";
	EndIf;

	Return Right(Line, StrLen(Line) - nCommentLocation + 1);

EndFunction

&AtClient
Procedure QueryComments_Restore(strQueryText)

	If Not SaveCommentsOption Then
		Return;
	EndIf;

	nSearchDepth = 50;

	SourceQuery = New TextDocument;
	SourceQuerySmp = New Array;
	NewQuery = New TextDocument;
	ResultQuery = New TextDocument;
	SourceQuery.SetText(CommentsData);
	NewQuery.SetText(strQueryText);
	nNewQueryLineCount = NewQuery.LineCount();
	nSourceQueryLineCount = SourceQuery.LineCount();

	For j = 1 To nSourceQueryLineCount Do
		SourceQuerySmp.Add(Upper(TrimAll(QueryComments_LineWithoutComments(SourceQuery.GetLine(
			j)))));
	EndDo;

	nSourceLine = 1;
	nNewLine = 1;
	
	// Moving opening comments before search
	While nSourceLine <= nSourceQueryLineCount Do
		strSource = SourceQuery.GetLine(nSourceLine);
		If Left(TrimAll(strSource), 2) = "//" Then
			ResultQuery.AddLine(strSource);
		Else
			Break;
		EndIf;
		nSourceLine = nSourceLine + 1;
	EndDo;

	While nNewLine <= nNewQueryLineCount Do

		strNew = NewQuery.GetLine(nNewLine);

		nFoundSourceLine = 0;
		If ValueIsFilled(strNew) Then
			nLinesToSearch = ?(nSourceLine + nSearchDepth < nSourceQueryLineCount, nSearchDepth,
				nSourceQueryLineCount - nSourceLine);
			strNewSmp = Upper(TrimAll(strNew));
			For j = nSourceLine To nSourceLine + nLinesToSearch Do
				If strNewSmp = SourceQuerySmp[j - 1] Then
					nFoundSourceLine = j;
					Break;
				EndIf;
			EndDo;
		EndIf;

		If nFoundSourceLine > 0 Then

			For j = 0 To nFoundSourceLine - nSourceLine - 1 Do

				strSource = SourceQuery.GetLine(nSourceLine + j);

				If Left(TrimL(strSource), 2) = "//" Then
					If Not IsBlankString(StrReplace(strSource, "/", "")) Then
						ResultQuery.AddLine(strSource);
					EndIf;
					Continue;
				EndIf;

				If ValueIsFilled(QueryComments_LineComment(strSource)) Then
					If Left(TrimAll(strSource), 2) = "//" Then
						ResultQuery.AddLine(strSource);
					Else
						ResultQuery.AddLine("//" + strSource);
					EndIf;
				EndIf;

			EndDo;

			strComment = QueryComments_LineComment(SourceQuery.GetLine(
				nFoundSourceLine));
			ResultQuery.AddLine(strNew + strComment);
			nSourceLine = nFoundSourceLine + 1;

		Else
			ResultQuery.AddLine(strNew);
		EndIf;

		nNewLine = nNewLine + 1;

	EndDo;
	
	For j = nSourceLine To nSourceQueryLineCount Do
		strSource = SourceQuery.GetLine(j);
		If ValueIsFilled(QueryComments_LineComment(strSource)) Then
			If Left(TrimAll(strSource), 2) = "//" Then
				ResultQuery.AddLine(strSource);
			Else
				ResultQuery.AddLine("//" + strSource);
			EndIf;
		EndIf;
	EndDo;

	strQueryText = ResultQuery.GetText();

EndProcedure

#EndRegion

#Region ProcessingParametersInQuerytext

&AtClient
Function GetParameterEndChars()
	Return ",+-*/<>=) " + Chars.LF + Chars.CR + Chars.Tab;
EndFunction

&AtClient
Function ParameterExists(strQueryText, strParameterName)

	strParameterEndChars = GetParameterEndChars();
	nParameterLength = StrLen(strParameterName);
	nTextLength = StrLen(strQueryText);
	p = 1;
	While p <= nTextLength Do
		p = StrFind(strQueryText, strParameterName, , p);
		If p = 0 Then
			Break;
		EndIf;
		s = Mid(strQueryText, p + nParameterLength, 1);
		If s = "" Or Find(strParameterEndChars, s) > 0 Then
			Return True;
		EndIf;
		p = p + nParameterLength;
	EndDo;

	Return False;

EndFunction

&AtClient
Function ReplaceParameter(strQueryText, strOldParameterName, strNewParameterName)

	strParameterEndChars = GetParameterEndChars();
	nParameterLength = StrLen(strOldParameterName);
	nTextLength = StrLen(strQueryText);
	arParts = New Array;
	p = 1;
	While p <= nTextLength Do
		p1 = StrFind(strQueryText, strOldParameterName, , p);
		If p1 = 0 Then
			arParts.Add(Mid(strQueryText, p));
			Break;
		EndIf;
		s = Mid(strQueryText, p1 + nParameterLength, 1);
		If s = "" Or Find(strParameterEndChars, s) > 0 Then
			arParts.Add(Mid(strQueryText, p, p1 - p));
			arParts.Add(strNewParameterName);
		Else
			arParts.Add(Mid(strQueryText, p, p1 - p + nParameterLength));
		EndIf;
		p = p1 + nParameterLength;
	EndDo;

	Return StrConcat(arParts);

EndFunction

#EndRegion

#Region FormEvents

&AtClient
Procedure AttachAutoSaveHandler()
	If AutoSaveIntervalOption > 0 Then
		AttachIdleHandler("AutoSaveHandler", AutoSaveIntervalOption);
	Else
		DetachIdleHandler("AutoSaveHandler");
	EndIf;
EndProcedure

&AtClient
Procedure FinishGettingUserDataWorkDir(UserDataDirectory, AdditionalParameters) Export
	AdditionalParameters.Insert("UserDataDirectory", UserDataDirectory);
	ExecuteContinuation(AdditionalParameters);
EndProcedure

&AtClient
Procedure FinishCheckingExistence(Exists, AdditionalParameters) Export
	AdditionalParameters.Insert("Exists", Exists);
	ExecuteContinuation(AdditionalParameters);
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	Enabled = False;

#If WebClient Then

	Notification = New NotifyDescription("AfterAttachingFileSystemExtension", ThisObject);
	BeginAttachingFileSystemExtension(Notification);

	ShowAlgorithmExecutionStatus();

#Else

		ShowAlgorithmExecutionStatus();
		OnOpenFollowUp();

#EndIf

EndProcedure

&AtClient
Procedure AfterAttachingFileSystemExtension(Attached, AdditionalParameters) Export

	FileExtensionConnected = Attached;

	If Not FileExtensionConnected Then
		ShowConsoleMessageBox(NStr("ru = 'Для работы консоли необходимо установить расширение работы с файлами.'; en = 'The file system extension must be installed.'"));
		BeginInstallFileSystemExtension();
		Close();
		Return;
	EndIf;

	OnOpenFollowUp();

EndProcedure

&AtClient
Procedure OnOpenFollowUp(AdditionalParameters = Undefined) Export

	If Not ValueIsFilled(AdditionalParameters) Then

		AdditionalParameters = New Structure("FollowUp, FollowUpPoint", "OnOpenFollowUp",
			"AfterGettingWorkDir");
		NotifyDescription = New NotifyDescription("FinishGettingUserDataWorkDir", ThisForm,
			AdditionalParameters);
		BeginGettingUserDataWorkDir(NotifyDescription);
		Return;

	ElsIf AdditionalParameters.FollowUpPoint = "AfterGettingWorkDir" Then

		UserDataDirectory = AdditionalParameters.UserDataDirectory;
		StateAutoSaveFileName = UserDataDirectory + ConsoleSignature + "." + AutoSaveExtension;

		strAutoSaveFileNameTemp = StateAutoSaveFileName;
		File = New File(strAutoSaveFileNameTemp);
		AdditionalParameters = New Structure("FollowUp, FollowUpPoint", "OnOpenFollowUp",
			"AfterCheckingExistenceSaving");
		NotifyDescription = New NotifyDescription("FinishCheckingExistence", ThisForm,
			AdditionalParameters);
		File.BeginCheckingExistence(NotifyDescription);
		Return;

	ElsIf AdditionalParameters.FollowUpPoint = "AfterCheckingExistenceSaving" Then
		If UT_Debug Then
			SetQueriesFileName();
			OnOpenCompletion();
			Return;
		EndIf;

		If Not AdditionalParameters.Exists Then
			QueryBatch_New();
			OnOpenCompletion();
			Return;
		EndIf;

		strAutoSaveFileNameTemp = StateAutoSaveFileName;
		Try
			AdditionalParameters = New Structure("FollowUp, FollowUpPoint, FileName",
				"OnOpenFollowUp", "AfterLoadingTitle", strAutoSaveFileNameTemp);
			QueryBatch_Load(AdditionalParameters);
		Except
			// The file is corrupted.
			QueryBatch_New();
			OnOpenCompletion();
		EndTry;

		Return;

	ElsIf AdditionalParameters.FollowUpPoint = "AfterLoadingTitle" Then

		stTitle = AdditionalParameters.LoadedData;
		If stTitle = Undefined Then
			// The file is corrupted.
			QueryBatch_New();
			OnOpenCompletion();
			Return;
		EndIf;

		If stTitle.Property("QueryBatch") Then

			Modified = True;
			OnOpenCompletion(); // AutoSaving is loaded from temp, query list was not loaded to file.
			Return;

		Else

			QueriesFileName = stTitle.FileName;
			SetQueriesFileName(QueriesFileName);
			strAutoSaveFileName = GetAutoSaveFileName(QueriesFileName);

			File = New File(strAutoSaveFileName);
			AdditionalParameters = New Structure("FollowUp, FollowUpPoint, AutoSaveFileName",
				"OnOpenFollowUp", "AfterCheckingExistenceAutoSaving", strAutoSaveFileName);
			NotifyDescription = New NotifyDescription("FinishCheckingExistence", ThisForm,
				AdditionalParameters);
			File.BeginCheckingExistence(NotifyDescription);
			Return;

		EndIf;

	ElsIf AdditionalParameters.FollowUpPoint = "AfterCheckingExistenceAutoSaving" Then

		Try
			If AdditionalParameters.Exists Then
				strAutoSaveFileName = AdditionalParameters.AutoSaveFileName;
				AdditionalParameters = New Structure("FollowUp, FollowUpPoint, FileName",
					"OnOpenFollowUp", "AfterLoadAutoSaving", strAutoSaveFileName);
				QueryBatch_Load(AdditionalParameters);
				Return;
			EndIf;
		Except
			// The file is corrupted. Loading the main file.
		EndTry;

		AdditionalParameters = New Structure("FollowUp, FollowUpPoint, LoadedData",
			"OnOpenFollowUp", "AfterLoadAutoSaving");
		ExecuteContinuation(AdditionalParameters);
		Return;

	ElsIf AdditionalParameters.FollowUpPoint = "AfterLoadAutoSaving" Then

		If AdditionalParameters.LoadedData <> Undefined Then
			Modified = True;
			OnOpenCompletion(); // Loaded from changed file autosaving.
			Return;
		EndIf;

		File = New File(QueriesFileName);
		AdditionalParameters = New Structure("FollowUp, FollowUpPoint", "OnOpenFollowUp",
			"AfterCheckingExistenceFile");
		NotifyDescription = New NotifyDescription("FinishCheckingExistence", ThisForm,
			AdditionalParameters);
		File.BeginCheckingExistence(NotifyDescription);

	ElsIf AdditionalParameters.FollowUpPoint = "AfterCheckingExistenceFile" Then

		If AdditionalParameters.Exists Then
			AdditionalParameters = New Structure("FollowUp, FollowUpPoint, FileName",
				"OnOpenFollowUp", "AfterLoadingMainFile", QueriesFileName);
			QueryBatch_Load(AdditionalParameters);
			Return;
		Else
			QueryBatch_New();
			OnOpenCompletion();
			Return;
		EndIf;

	ElsIf AdditionalParameters.FollowUp = "AfterLoadingMainFile" Then

		If AdditionalParameters.LoadedData = Undefined Then
			QueryBatch_New();
		EndIf;

		OnOpenCompletion(); // Loaded from main file.
		Return;

	EndIf;

EndProcedure

&AtServer
Procedure OnOpenCompletionAtServer()

	DataProcessor = FormAttributeToValue("Object");
	
	//Saved states +++

	ResultKind = SavedStates_GetAtServer("ResultKind", "table");
	OutputLinesLimit = SavedStates_GetAtServer("OutputLinesLimit", "1000");
	OutputLinesLimitEnabled = SavedStates_GetAtServer("OutputLinesLimitEnabled", True);
	OutputLinesLimitTop = SavedStates_GetAtServer("OutputLinesLimitTop", 1000);
	OutputLinesLimitTopEnabled = SavedStates_GetAtServer("OutputLinesLimitTopEnabled",
		False);

	fQueryResultBatchVisible = SavedStates_GetAtServer("QueryResultBatchVisible", False);
	If Items.ShowHideQueryResultBatch.Check <> fQueryResultBatchVisible Then
		Items.ShowHideQueryResultBatch.Check = fQueryResultBatchVisible;
		Items.QueryResultBatch.Visible = fQueryResultBatchVisible;
		Items.ResultInBatchGroup.Visible = Not fQueryResultBatchVisible;
	EndIf;

	fQueryParametersNextToText = SavedStates_GetAtServer("QueryParametersNextToText", True);
	If Items.QueryParametersNextToText.Check <> fQueryParametersNextToText Then
		Items.QueryParametersNextToText.Check = fQueryParametersNextToText;
		QueryParametersNextToTextAtServer();
	EndIf;
	
	//Saved states ---
	
	//Masking all exceptions while checking technological log.
	Try
		If DataProcessor.TechnologicalLog_ConsoleLogExists() Then
			Items.TechnologicalLog.Check = True;
		EndIf;
	Except
	EndTry;

	ValueToFormAttribute(DataProcessor, "Object");

EndProcedure

&AtClient
Procedure OnOpenCompletion()

	OnOpenCompletionAtServer();
	GetDataProcessorServerFileName();
	AttachAutoSaveHandler();
	SetItemsStates();

	If Items.TechnologicalLog.Check Then
		TechLogBeginEndTime = CurrentUniversalDateInMilliseconds();
		TechnologicalLog_Enabled(); // For executing the test query and checking the result.
		AttachIdleHandler("TechnologicalLog_WaitingForEnable", 1, True);
	EndIf;
	
	// 8.3.17 platform with disabled compatibility mode does not set current row.
	If Items.QueryBatch.CurrentRow = Undefined And QueryBatch.GetItems().Count() > 0 Then
		Items.QueryBatch.CurrentRow = QueryBatch.GetItems()[0].GetID();
	EndIf;

	If Not Object.ExternalDataProcessorMode Then
		AllowHooking();
		AllowBackgroundExecution();
	EndIf;

	Enabled = True;

#Region UT_OnOpen
	If UT_CommonClientServer.HTMLFieldBasedOnWebkit() Then
		Items.CodeCommandBarGroup.Visible = False;
	EndIf;
	UT_CodeEditorClient.FormOnOpen(ThisObject);
#EndRegion

EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	DataProcessorObject = FormAttributeToValue("Object");
	DataProcessorObject.Initializing(ThisForm);
	ValueToFormAttribute(DataProcessorObject, "Object");

	QueryInWizard = -1;
	EditingQuery = -1;
	
	//UsedFileName = FormAttributeToValue("Object").UsedFileName;

	Items.TempTablesValue.ChoiceButtonPicture = PictureLib.Change;

	Object.Title = NStr("ru = 'Консоль запросов 9000 v'; en = 'Query console 9000 v'") + Object.DataProcessorVersion;

	MacroParameter = "__";
	
	// For the correct displaying the query result area before execution.
	arAttributesToBeAdded = New Array;
	Attribute = New FormAttribute("Empty", New TypeDescription, "QueryResult");
	arAttributesToBeAdded.Add(Attribute);
	ChangeAttributes(arAttributesToBeAdded);
	Item = Items.Add("Empty", Type("FormField"), Items.QueryResult);
	Item.DataPath = "QueryResult.Empty";
	Item.ShowInHeader = False;

	ContainerAttributeSuffix=DataProcessorObject.ContainerAttributeSuffix();

#Region UT_OnCreateAtServer
	UT_IsPartOfUniversalTools = DataProcessorObject.DataProcessorIsPartOfUniversalTools();
	If UT_IsPartOfUniversalTools Then
		UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing,
			Items.FormCommandBarRight);

		Object.Title="";
		Title="";
		AutoTitle=True;
		Items.QueryBatchHookingSubmenu.Visible=False;
		Items.QueryCommandBarGroupRightHooking.Visible=False;
		Items.ResultKindCommandBar.BackColor=New Color;

		Items.UT_EditValue.Visible=True;
		Items.QueryResultContextMenuUT_EditValue.Visible=True;
		Items.QueryResultTreeContextMenuUT_EditValue.Visible=True;

		UT_FillWithDebugData();

		UT_CodeEditorServer.FormOnCreateAtServer(ThisObject);
		UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "Algorithm", Items.AlgorithmText);
	EndIf;
#EndRegion

EndProcedure

&AtClient
Procedure AutoSaveHandler() Export

	If Modified Then
		Autosave();
	EndIf;

EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, WarningText, StandardProcessing)

#If WebClient Then
	If Not FileExtensionConnected Then
		Return;
	EndIf;
#EndIf

	If Exit = True Then
		
		// Server calls are not allowed.

		WarningText = "";
		If Modified Then
			WarningText = NStr("ru = 'В консоли запросов 9000 имеется не сохраненный пакет запросов! '; en = 'Query console 9000 contains an unsaved query batch.'");
			Cancel = True;
		EndIf;

		If Items.TechnologicalLog.Check Then
			WarningText = WarningText + NStr("ru = 'Технологический журнал не выключен! '; en = 'technological log is not disabled.'");
			Cancel = True;
		EndIf;

		If Not ValueIsFilled(WarningText) Then
			WarningText = NStr("ru = 'Для сохранения состояний консоль запросов 9000 рекомендуется закрывать вручную.'; en = 'For saving states it is recommended to close query console 9000 manually'");
			Cancel = True;
		EndIf;

	Else
		
		QueryBatch_Save( , StateAutoSaveFileName, True);

		If Not SaveWithQuestion("Completion") Then
			Cancel = True;
		EndIf;

		If Not Cancel And Items.TechnologicalLog.Check Then
			TechnologicalLog_Command(Undefined);
		EndIf;

	EndIf;

EndProcedure

#EndRegion

#Region FormItemsEvents

&AtClient
Procedure ChangeParameterNameInQueryText(Result, AdditionalParameters) Export
	If Result = DialogReturnCode.Yes Then
		QueryText = ReplaceParameter(QueryText, "&" + AdditionalParameters.PreviousValueParameterName, "&"
			+ AdditionalParameters.ParameterName);
	EndIf;
EndProcedure

&AtClient
Procedure ProcessParameterNameChange(NewRow, CancelEditing, Cancel)

	If CancelEditing Then
		Return;
	EndIf;

	strParameterName = Items.QueryParameters.CurrentData.Name;
	If ValueIsFilled(strParameterName) And strParameterName = PreviousValueParameterName Then
		Return;
	EndIf;

	If Not NameIsCorrect(strParameterName) Then
		ShowConsoleMessageBox(
			NStr("ru = 'Неверное имя параметра! Имя должно состоять из одного слова, начинаться с буквы и не содержать специальных символов кроме ""_"".'; en = 'Parameter name is incorrect. The name must consist of one word, start with a letter and contain no special characters except ""_"".'"));
		Cancel = True;
		Return;
	EndIf;

	arNameRows = QueryParameters.FindRows(New Structure("Name", strParameterName));
	If arNameRows.Count() > 1 Then
		ShowConsoleMessageBox(NStr("ru = 'Параметр с таким именем уже есть! Введите другое имя.'; en = 'This parameter name already exists. Please enter another name.'"));
		Cancel = True;
		Return;
	EndIf;

	If Not NewRow And ValueIsFilled(PreviousValueParameterName) Then
		strQueryText = QueryText;
		If ParameterExists(strQueryText, "&" + PreviousValueParameterName) Then
			AdditionalParameters = New Structure("PreviousValueParameterName, ParameterName",
				PreviousValueParameterName, strParameterName);
			ShowQueryBox(
				New NotifyDescription("ChangeParameterNameInQueryText", ThisForm, AdditionalParameters),
				NStr("ru = 'Запрос содержит изменяемое мия параметра. Изменить имя параметра в тексте запроса?'; en = 'Query contains a variable parameter name. Do you want to change parameter name in the query text?'"),
				QuestionDialogMode.YesNo, , DialogReturnCode.Yes);
		EndIf;
	EndIf;

EndProcedure

&AtClient
Procedure QueryParametersBeforeEditEnd(Item, NewRow, CancelEdit, Cancel)

	ProcessParameterNameChange(NewRow, CancelEdit, Cancel);

EndProcedure

//&AtClient
//Procedure QueryParametersOnStartEdit(Item, NewRow, Clone)
//EndProcedure

&AtClient
Procedure QueryBatchOnEditEnd(Item, NewRow, CancelEdit)
	PreviousValueParameterName = "";
EndProcedure

&AtClient
Procedure QueryBatchBeforeEditEnd(Item, NewRow, CancelEdit, Cancel)

	QueryName = Item.CurrentData.Name;

	Row = FindInTree(QueryBatch, "Name", QueryName, Item.CurrentRow);
	If Row <> Undefined Then
		ShowConsoleMessageBox(NStr("ru = 'Запрос с таким именем уже есть! Введите другое имя.'; en = 'This query name already exists. Please enter another name.'"));
		Cancel = True;
		Return;
	EndIf;

EndProcedure

&AtClient
Procedure QueryBatchOnActivateRow(Item)

	CurrentData = Items.QueryBatch.CurrentData;

	If Items.QueryBatch.CurrentRow = EditingQuery Then
		Return;
	EndIf;

	If CurrentData <> Undefined And Not CurrentData.Initialized Then
		InitializeQuery(Items.QueryBatch.CurrentData);
		ExtractEditingQuery( , False);
	Else
		ExtractEditingQuery();
	EndIf;

EndProcedure

&AtClient
Procedure QueryBatchSelection(Item, SelectedRow, Field, StandardProcessing)
	ExecuteQuery(False);
	StandardProcessing = False;
EndProcedure

&AtClient
Procedure QueryTextOnChange(Item)
	PutEditingQuery();
EndProcedure

&AtClient
Procedure QueryParametersOnChange(Item)
	PutEditingQuery();
EndProcedure

&AtClient
Procedure QueryParametersValueStartChoice(Item, ChoiceData, StandardProcessing)

	CurrentData = Item.Parent.CurrentData;

	If CurrentData.ContainerType > 0 Then

		StandardProcessing = False;
		NotifyParameters = New Structure("Table, Row, Field", "QueryParameters",
			Item.Parent.CurrentRow, "Container");
		CloseFormNotifyDescription = New NotifyDescription("RowEditEnd",
			ThisForm, NotifyParameters);
		OpeningParameters = New Structure("Object, ValueType, Title, Value, ContainerType", Object,
			CurrentData.ValueType, CurrentData.Name, CurrentData.Container, CurrentData.ContainerType);

		If CurrentData.ContainerType = 3 Then
			EditingFormName = "EditTable";
		Else
			EditingFormName = "PickupToList";
		EndIf;

		OpenForm(FormFullName(EditingFormName), OpeningParameters, ThisForm, False, , ,
			CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);

	ElsIf TypeOf(CurrentData.Container) = Type("Structure") Then

		If CurrentData.Container.Type = "PointInTime" Or CurrentData.Container.Type = "Boundary" Then
			StandardProcessing = False;
			NotifyParameters = New Structure("Table, Row, Field", "QueryParameters",
				Item.Parent.CurrentRow, "Container");
			CloseFormNotifyDescription = New NotifyDescription("RowEditEnd",
				ThisForm, NotifyParameters);
			OpeningParameters = New Structure("Object, Value", Object, CurrentData.Container);
			OpenForm(FormFullName("EditPointInTimeBoundary"), OpeningParameters, ThisForm, False, , ,
				CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
		ElsIf CurrentData.Container.Type = "Type" Then
			StandardProcessing = False;
			NotifyParameters = New Structure("Table, Row, Field", "QueryParameters",
				Item.Parent.CurrentRow, "ContainerAsType");
			CloseFormNotifyDescription = New NotifyDescription("RowEditEnd",
				ThisForm, NotifyParameters);
			OpeningParameters = New Structure("Object, ValueType, ContainerType", Object, CurrentData.Container,
				CurrentData.ContainerType);
			OpenForm(FormFullName("EditType"), OpeningParameters, ThisForm, True, , ,
				CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
		EndIf;

	Else
		If TypeOf(CurrentData.Value) = Тип("UUID") Then
			StandardProcessing = False;
			NotifyParameters = New Structure("Table, Row, Field", "QueryParameters",
				Item.Parent.CurrentRow, "Value");
			CloseFormNotifyDescription = New NotifyDescription("RowEditEnd",
				ThisForm, NotifyParameters);
			OpeningParameters = New Structure("Object, Value", Object, CurrentData.Value);
			OpenForm(FormFullName("EditUUID"), OpeningParameters, ThisForm,
				True, , , CloseFormNotifyDescription,
				FormWindowOpeningMode.LockOwnerWindow);
		EndIf;
	EndIf;

EndProcedure

&AtClient
Procedure SetValueInputParameters()

	CurrentData = Items.QueryParameters.CurrentData;

	If CurrentData <> Undefined Then

		Items.QueryParametersValue.ChoiceButtonPicture = New Picture;

		If ValueIsFilled(CurrentData.ContainerType) Then

			Items.QueryParametersValue.ClearButton = False;
			Items.QueryParametersValue.ChoiceButton = True;
			Items.QueryParametersValue.ChooseType = False;
			Items.QueryParametersValue.TextEdit = False;
			Items.QueryParametersValue.TypeRestriction = New TypeDescription("String");
			Items.QueryParametersValue.ChoiceButtonPicture = PictureLib.Change;

		ElsIf TypeOf(CurrentData.Container) = Тип("Structure") Then

			Items.QueryParametersValue.ClearButton = False;
			Items.QueryParametersValue.ChoiceButton = True;
			Items.QueryParametersValue.ChooseType = False;
			Items.QueryParametersValue.ChoiceButtonPicture = PictureLib.Change;
			Items.QueryParametersValue.TextEdit = False;
			Items.QueryParametersValue.TypeRestriction = New TypeDescription("Строка");

		Else

			Items.QueryParametersValue.TextEdit = True;
			If ValueIsFilled(CurrentData.ValueType) Then
				Items.QueryParametersValue.TypeRestriction = CurrentData.ValueType;
			Else
				Items.QueryParametersValue.TypeRestriction = New TypeDescription;
			EndIf;

			If CurrentData.Value = Undefined
				And Items.QueryParametersValue.TypeRestriction.Types().Count() > 1 Then

				Items.QueryParametersValue.ChooseType = True;
				Items.QueryParametersValue.ChoiceButton = True;
				Items.QueryParametersValue.ClearButton = False;
				Items.QueryParametersValue.ChoiceButtonPicture = Items.Picture_ChooseType.Picture;

			Else

				Items.QueryParametersValue.ChooseType = False;
				Items.QueryParametersValue.ClearButton = True;
				Items.QueryParametersValue.ChoiceButton = ValueChoiceButtonEnabled(CurrentData.Value);

			EndIf;

		EndIf;

	EndIf;

EndProcedure

&AtClient
Procedure QueryParametersOnActivateRow(Item)
	SetValueInputParameters();
EndProcedure

&AtClient
Function AddParameterWithNameCheck(ParameterName)

	strParameterName = ParameterName;
	j = 1;
	While True Do

		arParameters = QueryParameters.FindRows(New Structure("Name", strParameterName));
		If arParameters.Count() = 0 Then
			Break;
		EndIf;

		strParameterName = ParameterName + j;
		j = j + 1;

	EndDo;

	NewRow = QueryParameters.Add();
	NewRow.Name = strParameterName;

	Return NewRow;

EndFunction

&AtClient
Procedure RowEditEnd(Result, AdditionalParameters) Export

	If Result <> Undefined Then

		If AdditionalParameters.Field = "Container" Then
			If AdditionalParameters.Table = "QueryParameters" Then
				QueryParameters_SaveValue(AdditionalParameters.Row, Result.Value);
			ElsIf AdditionalParameters.Table = "TempTables" Then
				TableRow = TempTables.FindByID(AdditionalParameters.Row);
				TableRow.Container = Result.Value;
				TableRow.Value = TableRow.Container.Presentation;
				Modified = True;
			EndIf;
		ElsIf AdditionalParameters.Field = "ContainerAsType" Then
			QueryParameters_SaveValue(AdditionalParameters.Row, Result.ContainerDescription);
		ElsIf AdditionalParameters.Field = "ValueType" Then

			ContainerDescription = Result.ContainerDescription;

			idParameterRow = AdditionalParameters.Row;
			If idParameterRow = Undefined Then
				//adding new parameter
				ParameterRow = AddParameterWithNameCheck(Result.ParameterName);
				ParameterRow.ContainerType = Result.ContainerType;
				idParameterRow = ParameterRow.GetID();
			EndIf;

			QueryParameters_SetType(idParameterRow, Result.ContainerType, ContainerDescription);

			strQueryText = Undefined;
			If Result.Property("QueryText", strQueryText) Then

				If ParameterRow <> Undefined And ParameterRow.Name <> Result.ParameterName Then
					strQueryText = StrReplace(strQueryText, "&" + Result.ParameterName, "&"
						+ ParameterRow.Name);
				EndIf;

				nTextSize = StrLen(QueryText);
				Items.QueryText.SetTextSelectionBounds(nTextSize + 1, nTextSize + 1);
				Items.QueryText.SelectedText = strQueryText;

				Items.QueryGroupPages.CurrentPage = Items.QueryPage;
				CurrentItem = Items.QueryText;

			EndIf;

			SetValueInputParameters();

		ElsIf AdditionalParameters.Field = "Value" Then
			Items.QueryParameters.CurrentData.Value = Result.Value;
			Items.QueryParameters.CurrentData.Container = Result.Value;
			Modified = True;
		EndIf;

	EndIf;

EndProcedure

&AtClient
Procedure QueryParametersParameterTypeStartChoice(Item, ChoiceData, StandardProcessing)

	StandardProcessing = False;
	CurrentData = Items.QueryParameters.CurrentData;

	If CurrentData.ContainerType < 3 Then
		ValueType = CurrentData.ValueType;
	Else
		ValueType = CurrentData.Containet;
	EndIf;

	NotifyParameters = New Structure("Table, Row, Field", "QueryParameters",
		Items.QueryParameters.CurrentRow, "ValueType");
	CloseFormNotifyDescription = New NotifyDescription("RowEditEnd", ThisForm,
		NotifyParameters);
	OpeningParameters = New Structure("Object, ValueType, ContainerType, Name, EnabledInQuery", Object,
		ValueType, CurrentData.ContainerType, CurrentData.Name, True);
	OpenForm(FormFullName("EditType"), OpeningParameters, ThisForm, True, , ,
		CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);

EndProcedure

&AtClient
Procedure QueryParametersValueOnChange(Item)

	CurrentData = Items.QueryParameters.CurrentData;

	If CurrentData.ContainerType = 0 Then

		CurrentData.Container = CurrentData.Value;
		If Not ValueIsFilled(CurrentData.ValueType) Then
			CurrentData.ValueType = TypeDescriptionByType(TypeOf(CurrentData.Value));
		EndIf;

	EndIf;

EndProcedure

&AtClient
Procedure TempTablesValueStartChoice(Item, ChoiceData, StandardProcessing)

	StandardProcessing = False;

	CurrentData = Items.TempTables.CurrentData;

	NotifyParameters = New Structure("Table, Row, Field", "TempTables",
		Items.TempTables.CurrentRow, "Container");
	CloseFormNotifyDescription = New NotifyDescription("RowEditEnd", ThisForm,
		NotifyParameters);
	OpeningParameters = New Structure("Object, ValueType, Title, Value, ContainerType", Object, ,
		CurrentData.Name, CurrentData.Container, 3);

	OpenForm(FormFullName("EditType"), OpeningParameters, ThisForm, False, , ,
		CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);

EndProcedure

&AtClient
Procedure QueryBatchBeforeAddRow(Item, Cancel, Clone, Parent, Folder, Parameter)

	If Clone Then

		Cancel = True;

		CurrentRow = QueryBatch.FindByID(Items.QueryBatch.CurrentRow);
		Parent = CurrentRow.GetParent();
		If Parent = Undefined Then
			Parent = CurrentRow;
		EndIf;

		NewRow = Parent.GetItems().Add();
		FillPropertyValues(NewRow, CurrentRow);
		Items.QueryBatch.CurrentRow = NewRow.GetID();

	EndIf;

EndProcedure

&AtClient
Procedure SaveCommentsOptionOnChange(Item)
	Modified = True;
EndProcedure

&AtClient
Procedure AutoSaveIntervalOptionOnChange(Item)
	AttachAutoSaveHandler();
	Modified = True;
EndProcedure

&AtClient
Procedure QueryResultSelection(Item, SelectedRow, Field, StandardProcessing)

	ColumnName = QueryResultColumnsMap[Field.Name];

	Value = Item.CurrentData[ColumnName];

	If QueryResultContainerColumns.Property(ColumnName) Then

		Container = ThisForm[Item.Name].FindByID(Item.CurrentRow)[ColumnName
			+ ContainerAttributeSuffix];

		If Container.Type = "ValueTable" Then
			OpeningParameters = New Structure("Object, Title, Value, ReadOnly", Object, ColumnName,
				Container, True);
			OpenForm(FormFullName("EditTable"), OpeningParameters, ThisForm, False, , , ,
				FormWindowOpeningMode.LockOwnerWindow);
		ElsIf Container.Type = Undefined Then
			//Container is empty. Value is contained in the main field.
			ShowValue( , Value);
		Else
			ShowValue( , Value.Presentation);
		EndIf;

	Else
		ShowValue( , Value);
	EndIf;

EndProcedure

&AtClient
Procedure ResultInBatchOnChange(Item)
	If ExtractResult(ResultInBatch) > 0 Then
		ResultRecordStructure_Expand();
	EndIf;
EndProcedure

&AtClient
Procedure SetItemsStates()

	Items.OutputLinesLimitTopOption.Enabled = OutputLinesLimitTopEnabled;
	Items.OutputLinesLimitOption.Enabled = OutputLinesLimitEnabled;

EndProcedure

&AtClient
Procedure OutputLinesLimitTopEnabledOptionOnChange(Item)
	SetItemsStates();
EndProcedure

&AtClient
Procedure OutputLinesLimitEnabledOptionOnChange(Item)
	SetItemsStates();
EndProcedure

&AtClient
Procedure QueryParametersValueChoiceProcessing(Item, SelectedValue, StandardProcessing)

	If TypeOf(SelectedValue) = Type("Type") Then
		TypeRestriction = Items.QueryParametersValue.TypeRestriction;
		arTypes = New Array;
		arTypes.Add(SelectedValue);
		ValueType = New TypeDescription(arTypes, TypeRestriction.NumberQualifiers,
			TypeRestriction.StringQualifiers, TypeRestriction.DateQualifiers);
		Value = ValueType.AdjustValue(Items.QueryParameters.CurrentData.Value);
		Items.QueryParameters.CurrentData.Value = Value;
		StandardProcessing = False;
	EndIf;

	SetValueInputParameters();

EndProcedure

&AtClient
Procedure QueryParametersValueTextEditEnd(Item, Text, ChoiceData, DataGetParameters,
	StandardProcessing)
	CurrentData = Items.QueryParameters.CurrentData;
	If TypeOf(CurrentData.Container) = Type("Structure") And CurrentData.Container.Type = "UUID" Then
		Try
			Value = New UUID(Text);
		Except
			Raise NStr("ru = 'Не корректное значение уникального идентификатора'; en = 'UUID is incorrect.'");
		EndTry;
		QueryParameters_SaveValue(Items.QueryParameters.CurrentRow, Value);
		StandardProcessing = False;
	EndIf;
EndProcedure

&AtClient
Procedure QueryParametersValueClearing(Item, StandardProcessing)

	CurrentData = Items.QueryParameters.CurrentData;

	If CurrentData.ContainerType = 0 Then
		nTypeCount = CurrentData.ValueType.Types().Count();
		If nTypeCount = 0 Or nTypeCount > 1 Then
			CurrentData.Value = Undefined;
		Else
			CurrentData.Value = CurrentData.ValueType.AdjustValue(Undefined);
		EndIf;
	ElsIf CurrentData.ContainerType = 3 Then
	EndIf;

	SetValueInputParameters();

EndProcedure

&AtClient
Procedure OptionProcessing__OnChange(Item)
	Modified = True;
EndProcedure

&AtClient
Procedure AlgorithmExecutionUpdateIntervalOptionOnChange(Item)
	Modified = True;
EndProcedure

&AtClient
Procedure QueryResultBatchOnActivateRow(Item)
	AttachIdleHandler("QueryResultBatchIdleHandlerOnActivateRow", 0.01, True);
EndProcedure

&AtClient
Procedure ResultRecordStructureBeforeExpand(Item, Row, Cancel)

	TreeRow = ResultRecordStructure.FindByID(Row);

	If Not TreeRow.ChildNodesExpanded Then
		ResultRecordStructure_ExpandChildNodes(Row);
	EndIf;

EndProcedure

&AtClient
Function ResultRecordStructureGetInsertText(Row)

	arValueText = New Array;

	Row = ResultRecordStructure.FindByID(Row);
	While Row <> Undefined Do
		arValueText.Insert(0, Row.Name);
		Row = Row.GetParent();
	EndDo;

	Return StrConcat(arValueText, ".");

EndFunction

&AtClient
Procedure ResultRecordStructureDragStart(Item, DragParameters, Perform)

	arParts = New Array;
	For Each Value In DragParameters.Value Do
		arParts.Add(ResultRecordStructureGetInsertText(Value));
	EndDo;

	DragParameters.Value = StrConcat(arParts, ";");

EndProcedure

&AtClient
Procedure ResultRecordStructureSelection(Item, SelectedRow, Field, StandardProcessing)
	InsertTextInAlgorithmCursorPosition (ResultRecordStructureGetInsertText(SelectedRow));
EndProcedure

&AtClient
Procedure QueryResultBatchSelection(Item, SelectedRow, Field, StandardProcessing)

	If Item.CurrentItem.Name = "QueryResultBatchInfo" Then

		DetachIdleHandler("QueryResultBatchIdleHandlerOnActivateRow");
		CurrentRow = Items.QueryResultBatch.CurrentRow;
		If CurrentRow <> Undefined Then
			If ExtractResult(QueryResultBatch.IndexOf(QueryResultBatch.FindByID(
				CurrentRow)) + 1) > 0 Then
				ResultRecordStructure_Expand();
			EndIf;
		EndIf;

		QueryPlan_Command(Undefined);

	ElsIf Item.CurrentItem.Name = "QueryResultBatchName" Then

		DetachIdleHandler("QueryResultBatchIdleHandlerOnActivateRow");
		CurrentRow = Items.QueryResultBatch.CurrentRow;
		If CurrentRow <> Undefined Then
			If ExtractResult(QueryResultBatch.IndexOf(QueryResultBatch.FindByID(
				CurrentRow)) + 1) > 0 Then
				ResultRecordStructure_Expand();
			EndIf;
		EndIf;

	EndIf;

EndProcedure

&AtClient
Procedure QueryResultBatchIdleHandlerOnActivateRow()
	CurrentRow = Items.QueryResultBatch.CurrentRow;
	If CurrentRow <> Undefined Then
		If ExtractResult(QueryResultBatch.IndexOf(QueryResultBatch.FindByID(
			CurrentRow)) + 1) > 0 Then
			ResultRecordStructure_Expand();
		EndIf;
	EndIf;
EndProcedure

#EndRegion

#Region FillingFromHookedQuery

&AtServer
Function FillFromXMLReader(XMLReader)
	Var strError, strQueryText, stQueryParameters;

	DataProcessor = FormAttributeToValue("Object");

	Try

		ParametersStructure = XDTOSerializer.ReadXML(XMLReader);
		If ParametersStructure.Count() >= 2 Then
			strQueryText = Undefined;
			If Not ParametersStructure.Property("Text", strQueryText) Or Not ParametersStructure.Property(
				"Parameters", stQueryParameters) Then
				strError = NStr("ru = 'Ошибка структуры.'; en = 'Structure error.'");
			EndIf;
		Else
			strError = NStr("ru = 'Ошибка структуры.'; en = 'Structure error.'");
		EndIf;

	Except
		strError = BriefErrorDescription(ErrorInfo());
	EndTry;

	XMLReader.Close();

	If ValueIsFilled(strError) Then
		Return NStr("ru = 'Не возможно сформировать запрос - ошибка структуры введенного XML.
					|Техническая информация: '; 
					|en = 'Unable to generate a query. XML structure error.
					|Details: '") + strError;
	EndIf;
	
	//Reading query parameters
	QueryText = strQueryText;
	stError = ParametersFillFromQueryAtServer();
	If ValueIsFilled(stError) Then
		Message(
			NStr("ru = 'Не удалось получить параметры из текста запроса. Параметры будут заполнены только по объекту запроса('; en = 'Cannot get the parameters from the query text. Parameters will be filled up only by query object.'")
			+ stError.ErrorDescription + ").", MessageStatus.Information);
	EndIf;

	For Each kvParameter In stQueryParameters Do

		arParameterRows = QueryParameters.FindRows(New Structure("Name", kvParameter.Key));
		If arParameterRows.Count() > 0 Then
			ParameterRow = arParameterRows[0];
		Else
			ParameterRow = QueryParameters.Add();
		EndIf;

		ParameterRow.Name = kvParameter.Key;
		ParameterRow.ContainerType = GetValueFormCode(kvParameter.Value);

		ValueTypeFromQuery = ParameterRow.ValueType;

		If ParameterRow.ContainerType = 0 Then
			ValueType = TypeOf(kvParameter.Value);
		ElsIf ParameterRow.ContainerType = 1 Then
			ValueType = kvParameter.Value.ValueType;
		ElsIf ParameterRow.ContainerType = 2 And kvParameter.Value.Count() > 0 Then
			ValueType = TypeOf(kvParameter.Value[0]);
		Else
			ValueType = Undefined;
		EndIf;

		If ValueIsFilled(ValueType) And (Not ValueIsFilled(ValueTypeFromQuery) Or (TypeOf(ValueType)
			= Type("Type") And Not ValueTypeFromQuery.ContainsType(ValueType))) Then
			If TypeOf(ValueType) = Type("Type") Then
				ParameterRow.ValueType = TypeDescriptionByType(ValueType);
			Else
				ParameterRow.ValueType = ValueType;
			EndIf;
		EndIf;

		QueryParameters_SaveValue(ParameterRow.GetID(), kvParameter.Value);

	EndDo;
	
	//Reading temp tables.
	arTables = Undefined;
	If ParametersStructure.Property("TempTables", arTables) Then

		For Each stTable In arTables Do

			vtTable = stTable.Table;

			stNewColumnTypes = New Structure;
			For Each Column Из vtTable.Columns Do

				arTypes = Column.ValueType.Types();
				arNewColumnTypes = New Array;
				fUnknownObjectExists = False;
				For Each Type In arTypes Do
					If String(Type) <> "UnknownObject" Then
						arNewColumnTypes.Add(Type);
					Else
						fUnknownObjectExists = True;
					EndIf;
				EndDo;

				If fUnknownObjectExists Then

					NewColumnType = New TypeDescription(arNewColumnTypes, Column.ValueType.NumberQualifiers,
						Column.ValueType.StringQualifiers, Column.ValueType.DateQualifiers,
						Column.ValueType.BinaryDataQualifiers);

					stNewColumnTypes.Insert(Column.Name, NewColumnType);

				EndIf;

			EndDo;

			For Each kv In stNewColumnTypes Do
				DataProcessor.ChangeValueTableColumnType(vtTable, kv.Key, kv.Value);
			EndDo;

			TableRow = TempTables.Add();
			TableRow.Name = stTable.Name;
			TableRow.Container = FormAttributeToValue("Object").Container_SaveValue(vtTable);
			TableRow.Value = TableRow.Container.Presentation;

		EndDo;

	EndIf;

EndFunction

&AtServer
Procedure FillFromFile(strFileName)
	XMLReader = New XMLReader;
	XMLReader.OpenFile(strFileName);
	FillFromXMLReader(XMLReader);
EndProcedure

&AtServer
Function FillFromXMLAtServer()

	strQuerySignatureString = "<Structure xmlns=""http://v8.1c.ru/8.1/data/core""";
	strQueryWindowText = QueryText;
	If Left(strQueryWindowText, StrLen(strQuerySignatureString)) <> strQuerySignatureString Then
		Return NStr("ru = 'В поле текста запроса должна быть строка, кодирующая запрос с параметрами. Подробности на закладке ""Информация"".'; en = 'Query text field must contain a string that encodes a query with a parameters. Details on the Info tab.'");
	EndIf;

	XMLReader = New XMLReader;
	XMLReader.SetString(strQueryWindowText);

	FillFromXMLReader(XMLReader);

EndFunction

#EndRegion

#Region InteractiveCommands

&AtClient
Procedure LoadQueryBatch(AdditionalParameters = Undefined) Export

	Dialog = New FileDialog(FileDialogMode.Open);
	Dialog.Filter = SaveFilter;

	NotifyDescription = New NotifyDescription("AfterChoosingFileForLoadingQueryBatch", ThisForm);
	Dialog.Show(NotifyDescription);

EndProcedure

&AtClient
Procedure AfterChoosingFileForLoadingQueryBatch(Files, AdditionalParameters) Export

	If Files = Undefined Then
		Return;
	EndIf;

	strFileName = Files[0];

	AdditionalParameters = New Structure("FollowUp, FileName",
		"AfterChoosingFileForLoadingQueryBatchCompletion", strFileName);
	QueryBatch_Load(AdditionalParameters);

EndProcedure

&AtClient
Procedure AfterSaveQuestion(Result, AdditionalParameters) Export

	If AdditionalParameters = "Load" Then
		LoadQueryBatchAfterQuestion(Result, AdditionalParameters);
	ElsIf AdditionalParameters = "Completion" Then
		CompletionAfterQuestion(Result, AdditionalParameters);
	ElsIf AdditionalParameters = "New" Then
		NewQueryBatchAfterQuestion(Result, AdditionalParameters);
	EndIf;

EndProcedure

&AtClient
Procedure LoadQueryBatchAfterQuestion(Result, AdditionalParameters)

	If Result = DialogReturnCode.Yea Then
		SaveQueryBatch(New Structure);
		LoadQueryBatch();
	ElsIf Result = DialogReturnCode.No Then

		AutoSaveFileDeletedFlag = False;
		StatusFileDeletedFlag = False;

		AdditionalParameters = New Structure("FileType, FollowUp", "AutoSave", "LoadQueryBatch");
		NotifyDescription = New NotifyDescription("Finish_AfterDelete", ThisForm, AdditionalParameters);
		BeginDeletingFiles(NotifyDescription, GetAutoSaveFileName(QueriesFileName));

		AdditionalParameters = New Structure("FileType, FollowUp", "Status", "LoadQueryBatch");
		NotifyDescription = New NotifyDescription("Finish_AfterDelete", ThisForm, AdditionalParameters);
		BeginDeletingFiles(NotifyDescription, StateAutoSaveFileName);

	ElsIf Result = DialogReturnCode.Cancel Then
	EndIf;

EndProcedure

&AtClient
Procedure Finish_AfterDelete(AdditionalParameters) Export

	If AdditionalParameters.FileType = "AutoSave" Then
		AutoSaveFileDeletedFlag = True;
	ElsIf AdditionalParameters.FileType = "Status" Then
		StatusFileDeletedFlag = True;
	EndIf;

	If AutoSaveFileDeletedFlag And StatusFileDeletedFlag Then
		ExecuteContinuation(AdditionalParameters);
	EndIf;

EndProcedure

&AtClient
Procedure NewQueryBatchAfterQuestion(Result, AdditionalParameters)

	If Result = DialogReturnCode.Yes Then
		SaveQueryBatch(New Structure("New", True));
	ElsIf Result = DialogReturnCode.Not Then

		AutoSaveFileDeletedFlag = False;
		StatusFileDeletedFlag = False;

		AdditionalParameters = New Structure("FileType, FollowUp", "AutoSave",
			"ContinueQueryBatch_New");
		NotifyDescription = New NotifyDescription("Finish_AfterDelete", ThisForm, AdditionalParameters);
		BeginDeletingFiles(NotifyDescription, GetAutoSaveFileName(QueriesFileName));

		AdditionalParameters = New Structure("FileType, FollowUp", "Status",
			"ContinueQueryBatch_New");
		NotifyDescription = New NotifyDescription("Finish_AfterDelete", ThisForm, AdditionalParameters);
		BeginDeletingFiles(NotifyDescription, StateAutoSaveFileName);

	ElsIf Result = DialogReturnCode.Cancel Then
	EndIf;

EndProcedure

&AtClient
Procedure SetSelectionBoundsForRowProcessing(TextItem, RowBeginning, ColumnBeginning, RowEnd,
	ColumnEnd)

	TextItem.GetTextSelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);

	If RowBeginning = RowEnd And ColumnBeginning = ColumnEnd Then
		TextItem.SetTextSelectionBounds(1, 1, 1000000000, 1);
	Else

		If ColumnBeginning > 1 Then
			ColumnBeginning = 1;
		EndIf;

		If ColumnEnd > 1 Then
			RowEnd = RowEnd + 1;
			ColumnEnd = 1;
		EndIf;

		TextItem.SetTextSelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);

	EndIf;

EndProcedure

&AtClient
Procedure QueryBatchNew_Command(Command)

	If Not SaveWithQuestion("New") Then
		Return;
	EndIf;

	QueryBatch_New();

EndProcedure

&AtClient
Procedure LoadQueryBatch_Command(Command)

	If Not SaveWithQuestion("Load") Then
		Return;
	EndIf;

	LoadQueryBatch();

EndProcedure

&AtClient
Procedure SaveQueryBatch(Context)

	If Not ValueIsFilled(QueriesFileName) Then
		NotifyDescription = New NotifyDescription("SaveQueryBatchContinue", ThisForm, Context);
		AutoSave(NotifyDescription);
		Return;
	EndIf;

	Context.Insert("SaveCompletionNotification", "AfterSaveQueryBatch");
	Context.Insert("SavingFileName", GetAutoSaveFileName(QueriesFileName));
	Context.Insert("QueriesFileName", QueriesFileName);
	NotifyDescription = New NotifyDescription("FinishSavingFile", ThisForm, Context);
	AutoSave(NotifyDescription);

EndProcedure

&AtClient
Procedure SaveQueryBatchContinue(Result, Context) Export
	QueryBatchSaveAs(Context);
EndProcedure

&AtClient
Procedure QueryBatchSave_Command(Command)
	SaveQueryBatch(New Structure);
EndProcedure

&AtClient
Procedure QueryBatchSaveAs(Context)

	PutEditingQuery();

	Dialog = New FileDialog(FileDialogMode.Save);
	Dialog.Filter = SaveFilter;

	NotifyDescription = New NotifyDescription("QueryBatchSaveAs_AfterChoosingFile", ThisForm, Context);
	Dialog.Show(NotifyDescription);

EndProcedure

&AtClient
Procedure QueryBatchSaveAs_Command(Command)
	QueryBatchSaveAs(New Structure);
EndProcedure

&AtClient
Procedure QueryBatchSaveAs_AfterChoosingFile(Files, AdditionalParameters) Export

	If Files = Undefined Then
		Return;
	EndIf;

	strFileName = Files[0];
	
	//At WebClient, in browser running by Linux, after Save File dialog, file extension disappears.
	File = New File(strFileName);
	If Upper(File.Extension) <> "." + Upper(FilesExtension) Then
		Message(File.Extension);
		strFileName = StrTemplate("%1.%2", strFileName, FilesExtension);
	EndIf;

	SetQueriesFileName(strFileName);

	AdditionalParameters = New Structure("SaveCompletionNotification, SavingFileName, QueriesFileName",
		"AfterSaveQueryBatch", GetAutoSaveFileName(QueriesFileName), QueriesFileName);
	NotifyDescription = New NotifyDescription("FinishSavingFile", ThisForm, AdditionalParameters);
	AutoSave(NotifyDescription);

EndProcedure
&AtClient
Procedure FinishSavingFile(Result, AdditionalParameters) Export
	NotifyDescription = New NotifyDescription(AdditionalParameters.SaveCompletionNotification,
		ThisForm, AdditionalParameters);
	BeginMovingFile(NotifyDescription, AdditionalParameters.SavingFileName,
		AdditionalParameters.QueriesFileName);
EndProcedure

&AtClient
Procedure AfterSaveQueryBatch(FileToMove, AdditionalParameters) Export

	Modified = False;

	If AdditionalParameters.Property("Completion") Then
		Закрыть();
	ElsIf AdditionalParameters.Property("New") Then
		QueryBatch_New();
	EndIf;

EndProcedure

#Region QueryWizard_Command

&AtClient
Function GetQueryWizard(strQueryText)
	Var ErrorString, RowNumber, ColumnNumber;

	Try
		QueryWizard = New QueryWizard(strQueryText);
	Except

		ErrorString = ErrorDescription();
		DisassembleQueryError(ErrorString, RowNumber, ColumnNumber);

		ShowConsoleMessageBox(ErrorString);
		If ValueIsFilled(RowNumber) Then
			Items.QueryText.SetTextSelectionBounds(RowNumber, ColumnNumber, RowNumber, ColumnNumber);
		EndIf;

		Return Undefined;

	EndTry;

	Return QueryWizard;

EndFunction

&AtClient
Procedure QueryWizard_Command(Command)

	strQueryText = QueryText;
	QueryComments_SaveSourceQueryData(strQueryText);

	If ValueIsFilled(strQueryText) Then
		QueryWizard = GetQueryWizard(strQueryText);
		If QueryWizard = Undefined Then
			Return;
		EndIf;
	Else
		QueryWizard = New QueryWizard;
	EndIf;

#If ThickClientManagedApplication Then
	If QueryWizard.DoModal() Then
		strQueryText = QueryWizard.Text;
		QueryComments_Restore(strQueryText);
		QueryText = strQueryText;
		PutEditingQuery();
		Modified = True;
	EndIf;
#Else

		If QueryInWizard > 0 Then
			Query_SetInWizard(QueryInWizard, False);
			QueryInWizard = -1;
		EndIf;

		CurrentQuery = QueryBatch_CurrentQuery();
		Query_SetInWizard(CurrentQuery, True);
		ExtractEditingQuery();
		QueryWizard.Show(
			New NotifyDescription("QueryWizard_CloseWizardNotification_Command", ThisForm,
			CurrentQuery));

#EndIf

EndProcedure

&AtClient
Procedure QueryWizard_CloseWizardNotification_Command(strQueryText, CurrentQuery) Экспорт

	If Not Query_GetInWizard(CurrentQuery) Then
		Return;
	EndIf;

	Query_SetInWizard(CurrentQuery, False);
	QueryInWizard = -1;

	If strQueryText <> Undefined Then
		QueryComments_Restore(strQueryText);
		Query_PutQueryData(EditingQuery, strQueryText);
		Modified = True;
	EndIf;

	ExtractEditingQuery(CurrentQuery);

EndProcedure

#EndRegion

&AtClient
Procedure ExecuteQuery(fUseSelection)

	Var RowBeginning, ColumnBeginning, RowEnd, ColumnEnd;

	Items.QueryText.GetTextSelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);
	fEntireText = Not fUseSelection Or (RowBeginning = RowEnd And ColumnBeginning = ColumnEnd);
	If fEntireText Then
		strQueryText = QueryText;
	Else
		strQueryText = Items.QueryText.SelectedText;
	EndIf;

	If AutoSaveBeforeQueryExecutionOption And Modified Then
		AutoSave();
	EndIf;

	stResult = ExecuteQueryAtServer(strQueryText);
	If ValueIsFilled(stResult.ErrorDescription) Then
		ShowConsoleMessageBox(stResult.ErrorDescription);
		CurrentItem = Items.QueryText;
		If ValueIsFilled(stResult.Row) Then
			If fEntireText Then
				Items.QueryText.SetTextSelectionBounds(stResult.Row, stResult.Column,
					stResult.Row, stResult.Column);
			Else
			EndIf;
		EndIf;
	Else

		ResultInForm = -1;
		ResultReturningRowsCount = ExtractResult(stResult.ResultCount);
		ResultRecordStructure_Expand();

		CurrentBatchRow = QueryBatch.FindByID(Items.QueryBatch.CurrentRow);
		CurrentBatchRow.ResultRowCount = QueryResult.Count();
		Duration = FormatDuration(stResult.FinishTime - stResult.StartTime);
		Items.QueryBatch.CurrentData.Info = String(ResultReturningRowsCount) + " / "
			+ Duration;

	EndIf;

	ResultQueryName = Items.QueryBatch.CurrentData.Name;
	RefreshAlgorithmFormItems();

EndProcedure

&AtClient
Procedure ExecuteQuery_Command(Command)
	If Items.QueryBatch.CurrentRow <> Undefined Then
		ExecuteQuery(True);
	EndIf;
EndProcedure

&AtServer
Function ParametersFillFromQueryAtServer()
	Var RowNumber, ColumnNumber;

	Query = New Query(QueryText);
	Try
		Query.TempTablesManager = LoadTempTables();
		ParametersFound = Query.FindParameters();
	Except
		ErrorString = ErrorDescription();
		DisassembleQueryError(ErrorString, RowNumber, ColumnNumber);
		Return New Structure("ErrorDescription, Row, Column", ErrorString, RowNumber, ColumnNumber);
	EndTry;

	For Each Parameter Из ParametersFound Do

		If Object.OptionProcessing__ И StrStartsWith(Parameter.Name, MacroParameter) Then
			Continue;
		EndIf;

		arParameterRows = QueryParameters.FindRows(New Structure("Name", Parameter.Name));
		If arParameterRows.Count() > 0 Then
			ParameterRow = arParameterRows[0];
		Else
			ParameterRow = QueryParameters.Add();
			ParameterRow.Name = Parameter.Name;
			QueryParameters_SaveValue(ParameterRow.GetID(),
				Parameter.ValueType.AdjustValue(Undefined));
		EndIf;

		If Not ValueIsFilled(ParameterRow.ValueType) Then
			ParameterRow.ValueType = Parameter.ValueType;
		EndIf;

	EndDo;

	Return Undefined;

EndFunction

&AtClient
Procedure FillParametersFromQuery_Command(Command)

	stError = ParametersFillFromQueryAtServer();

	If ValueIsFilled(stError) Then

		ShowConsoleMessageBox(stError.ErrorDescription);
		CurrentItem = Items.QueryText;

		If ValueIsFilled(stError.Row) Then
			Items.QueryText.SetTextSelectionBounds(stError.Row, stError.Column, stError.Row,
				stError.Column);
		EndIf;

	EndIf;

EndProcedure

&AtClient
Procedure FillFromXML_Command(Command)

	strError = FillFromXMLAtServer();
	If ValueIsFilled(strError) Then
		ShowConsoleMessageBox(strError);
	EndIf;

EndProcedure

&AtClient
Procedure ClearParameters_Command(Command)
	QueryParameters.Clear();
EndProcedure

&AtClient
Procedure AddLineFeedsToText(TextItem)
	Var RowBeginning, ColumnBeginning, RowEnd, ColumnEnd;

	SetSelectionBoundsForRowProcessing(TextItem, RowBeginning, ColumnBeginning, RowEnd,
		ColumnEnd);

	ProcessingText = New TextDocument;
	ProcessingText.SetText(TextItem.SelectedText);

	For j = 1 To ProcessingText.LineCount() Do
		ProcessingText.ReplaceLine(j, "|" + ProcessingText.GetLine(j));
	EndDo;

	TextItem.SelectedText = ProcessingText.GetText();
	TextItem.SetTextSelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);

EndProcedure

&AtClient
Procedure AddLineFeedsToText_Command(Command)
	If Items.QueryGroupPages.CurrentPage = Items.QueryPage Then
		AddLineFeedsToText(Items.QueryText);
	ElsIf Items.QueryGroupPages.CurrentPage = Items.AlgorithmPage Then
		AddLineFeedsToText(Items.AlgorithmText);
	EndIf;
EndProcedure

&AtClient
Procedure RemoveLineFeedsFromText(TextItem)
	Var RowBeginning, ColumnBeginning, RowEnd, ColumnEnd;

	SetSelectionBoundsForRowProcessing(TextItem, RowBeginning, ColumnBeginning, RowEnd,
		ColumnEnd);

	ProcessingText = New TextDocument;
	ProcessingText.SetText(TextItem.SelectedText);

	For j = 1 To ProcessingText.LineCount() Do
		str = ProcessingText.GetLine(j);
		If Left(TrimL(str), 1) = "|" Then
			x = Find(str, "|");
			ProcessingText.ReplaceLine(j, Left(str, x - 1) + Right(str, StrLen(str) - x));
		EndIf;
	EndDo;

	TextItem.SelectedText = ProcessingText.GetText();
	TextItem.SetTextSelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);

EndProcedure

&AtClient
Procedure RemoveLineFeedsFromText_Command(Command)
	If Items.QueryGroupPages.CurrentPage = Items.QueryPage Then
		RemoveLineFeedsFromText(Items.QueryText);
	ElsIf Items.QueryGroupPages.CurrentPage = Items.AlgorithmPage Then
		RemoveLineFeedsFromText(Items.AlgorithmText);
	EndIf;
EndProcedure

&AtClient
Procedure AddCommentsToText(TextItem)
	Var RowBeginning, ColumnBeginning, RowEnd, ColumnEnd;

	SetSelectionBoundsForRowProcessing(TextItem, RowBeginning, ColumnBeginning, RowEnd,
		ColumnEnd);

	ProcessingText = New TextDocument;
	ProcessingText.SetText(TextItem.SelectedText);

	For j = 1 To ProcessingText.LineCount() Do
		ProcessingText.ReplaceLine(j, "//" + ProcessingText.GetLine(j));
	EndDo;

	TextItem.SelectedText = ProcessingText.GetText();
	TextItem.SetTextSelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);

EndProcedure

&AtClient
Procedure AddCommentsToText_Command(Command)
	If Items.QueryGroupPages.CurrentPage = Items.QueryPage Then
		AddCommentsToText(Items.QueryText);
	ElsIf Items.QueryGroupPages.CurrentPage = Items.AlgorithmPage Then
		AddCommentsToText(Items.AlgorithmText);
	EndIf;
EndProcedure

&AtClient
Procedure RemoveCommentsFromText(TextItem)
	Var RowBeginning, ColumnBeginning, RowEnd, ColumnEnd;

	SetSelectionBoundsForRowProcessing(TextItem, RowBeginning, ColumnBeginning, RowEnd,
		ColumnEnd);

	ProcessingText = New TextDocument;
	ProcessingText.SetText(TextItem.SelectedText);

	For j = 1 To ProcessingText.LineCount() Do
		str = ProcessingText.GetLine(j);
		If Left(TrimL(str), 2) = "//" Then
			x = Find(str, "//");
			ProcessingText.ReplaceLine(j, Left(str, x - 1) + Right(str, StrLen(str) - x - 1));
		EndIf;
	EndDo;

	TextItem.SelectedText = ProcessingText.GetText();
	TextItem.SetTextSelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);

EndProcedure

&AtClient
Procedure RemoveCommentsFromText_Command(Command)
	If Items.QueryGroupPages.CurrentPage = Items.QueryPage Then
		RemoveCommentsFromText(Items.QueryText);
	ElsIf Items.QueryGroupPages.CurrentPage = Items.AlgorithmPage Then
		RemoveCommentsFromText(Items.AlgorithmText);
	EndIf;
EndProcedure

&AtClient
Procedure QuerySyntaxCheck_Command(Command)

	If Items.QueryGroupPages.CurrentPage <> Items.QueryPage Then
		Return;
	EndIf;

	Result = FormatQueryTextAtServer(QueryText);

	If TypeOf(Result) <> Type("String") Then
		ShowConsoleMessageBox(Result.ErrorDescription);
		CurrentItem = Items.QueryText;
		If ValueIsFilled(Result.Row) Then
			Items.QueryText.SetTextSelectionBounds(Result.Row, Result.Column, Result.Row,
				Result.Column);
		EndIf;
	EndIf;

EndProcedure

&AtClient
Procedure FormatQueryText_Command(Command)

	If Items.QueryGroupPages.CurrentPage <> Items.QueryPage Then
		Return;
	EndIf;

	strQueryText = QueryText;
	QueryComments_SaveSourceQueryData(strQueryText);
	Result = FormatQueryTextAtServer(strQueryText);

	If TypeOf(Result) <> Type("String") Then

		ShowConsoleMessageBox(Result.ErrorDescription);
		CurrentItem = Items.QueryText;
		If ValueIsFilled(Result.Row) Then
			Items.QueryText.SetTextSelectionBounds(Result.Row, Result.Column, Result.Row,
				Result.Column);
		EndIf;

		Return;

	EndIf;

	QueryComments_Restore(Result);

	CountText = New TextDocument;
	CountText.SetText(QueryText);
	Items.QueryText.SetTextSelectionBounds(1, 1, CountText.LineCount() + 1, 1);
	Items.QueryText.SelectedText = Result;
	PutEditingQuery();
	Modified = True;

EndProcedure

&AtClient
Procedure GetCodeForTrace_Command(Command)

	If Object.ExternalDataProcessorMode Then

		strDataProcessorServerFileName = GetDataProcessorServerFileName();
		//"ExternalDataProcessors.Create(""" + стрDataProcessorServerFileName + """, False).SaveQuery(" + Format(Object.SessionID, "NG=0") + ", Query)";
		strCode = StrTemplate("ExternalDataProcessors.Create(""%1"", False).SaveQuery(%2, Query)",
			strDataProcessorServerFileName, Format(Object.SessionID, "NG=0"));
	Else

		strCode = StrTemplate("DataProcessors.%1.Create().SaveQuery(%2, Query)", Object.DataProcessorName, Format(
			Object.SessionID, "NG=0"));

	EndIf;

	OpeningParameters = New Structure("
									  |Object,
									  |Title,
									  |CodeToCopy,
									  |Info", Object, NStr("ru = 'Код для перехвата запроса в отладчике'; en = 'Code to hook the query in the debugger.'"), strCode, NStr("ru = 'Для перехвата запроса в отладчике скопируйте и выполните по Shift+F9 указанный код.
																											   |Консоль запросов должна быть запущена в той же информационной базе под тем же пользователем.
																											   |Для получения запросов в консоль используйте команду на закладке текста запроса ""Перехват | Получить перехваченные запросы (Ctrl+F9)""
																											   |В настройках пользователя должна быть отключена защита от опасных действий.'; 
																											   |en = 'To hook the query in the debugger, copy and execute this code by Shift + F9.
																											   |Query console must be launched in the same infobase under the same login.
																											   |To receive queries to the console, use the ""Hooking | Get hooked queries (Ctrl+F9)"" command.
																											   |""Unsafe operation protection"" user setting must be switched off.'"));

	OpenForm(FormFullName("Info"), OpeningParameters, ThisForm, False, , , ,
		FormWindowOpeningMode.LockOwnerWindow);

EndProcedure

&AtClient
Procedure GetHookedQueries_Command(Command)

	strExplanation = NStr("ru = 'Загрузка перехваченных запросов'; en = 'Loading hooked queries'");

	PutEditingQuery();

	arQueryFiles = GetFileListAtServerFromTempFilesDir("*." + Object.LockedQueriesExtension);

	j = 1;
	For Each strFile In arQueryFiles Do
		Status(NStr("ru = 'Загрузка перехваченного запроса: '; en = Loading hooked query: ") + j + NStr("ru = ' из '; en = ' out of '") + arQueryFiles.Count(), (j - 1) * 100
			/ arQueryFiles.Count(), strExplanation);
		NewQuery = QueryBatch.GetItems().Add();
		Items.QueryBatch.CurrentRow = NewQuery.GetID();
		FillFromFile(strFile);
		PutEditingQuery();
		j = j + 1;
	EndDo;

	Status(NStr("ru = 'Удаление временных файлов...'; en = 'Deleting temporary files...'"), 100, strExplanation);
	DeleteFilesAtServer(arQueryFiles);
	ShowConsoleMessageBox(NStr("ru = 'Загружено перехваченных запросов: '; en = 'Hooked queries loaded: '") + arQueryFiles.Count());
	Modified = Modified Or arQueryFiles.Count() > 0;

EndProcedure

&AtClient
Procedure DeleteHookedQueries_Command(Command)

	PutEditingQuery();

	arQueryFiles = GetFileListAtServerFromTempFilesDir("*." + Object.LockedQueriesExtension);

	Status(NStr("ru = 'Удаление временных файлов...'; en = 'Deleting temporary files...'"), 100);
	DeleteFilesAtServer(arQueryFiles);
	ShowConsoleMessageBox(NStr("ru = 'Удалено перехваченных запросов: '; en = 'Hooked queries deleted: '") + arQueryFiles.Count());

EndProcedure

&AtClient
Procedure QueryBatchAdd_Command(Command)
	Items.QueryBatch.CurrentRow = QueryBatch.GetItems().Add().GetID();
	Items.QueryBatch.CurrentItem = Items.QueryListQuery;
	Items.QueryBatch.ChangeRow();
	Modified = True;
EndProcedure

&AtClient
Procedure QueryBatchLevelUp_Command(Command)

	Row = QueryBatch.FindByID(Items.QueryBatch.CurrentRow);
	Parent = Row.GetParent();

	If Parent <> Undefined Then
		ParentParent = Parent.GetParent();
		If ParentParent = Undefined Then
			InsertIndex = QueryBatch.GetItems().IndexOf(Parent) + 1;
		Else
			InsertIndex = ParentParent.GetItems().IndexOf(Parent) + 1;
		EndIf;
		NewRow = MoveTreeRow(QueryBatch, Row, InsertIndex, ParentParent);
		Items.QueryBatch.CurrentRow = NewRow.GetID();
	EndIf;

	Modified = True;

EndProcedure

&AtClient
Procedure QueryBatchCopy_Command(Command)

	Row = QueryBatch.FindByID(Items.QueryBatch.CurrentRow);
	NewRow = Row.GetItems().Add();
	FillPropertyValues(NewRow, Row, ,
		"InWizard, Info, ResultReturningRowsCount, ResultRowCount, RowCountDifference");
	NewRow.Name = NStr("ru = 'Копия '; en = 'Copy '") + NewRow.Name;
	Items.QueryBatch.CurrentRow = NewRow.GetID();
	Items.QueryBatch.CurrentItem = Items.QueryListQuery;
	Items.QueryBatch.ChangeRow();

	Modified = True;

EndProcedure

&AtClient
Procedure RefreshResult_Command(Command)
	If ExtractResult() > 0 Then
		ResultRecordStructure_Expand();
	EndIf;
EndProcedure

&AtClient
Procedure QueryResultTreeExpandAll_Command(Command)
	For Each TreeItem In QueryResultTree.GetItems() Do
		Items.QueryResultTree.Expand(TreeItem.GetID(), True);
	EndDo;
EndProcedure

&AtClient
Procedure QueryResultTreeCollapseAll_Command(Command)
	For Each TreeItem In QueryResultTree.GetItems() Do
		Items.QueryResultTree.Collapse(TreeItem.GetID());
	EndDo;
EndProcedure

&AtClient
Procedure ResultToSpreadsheetDocument_Command(Command)

	OpeningParameters = New Structure("Object, QueryResultAddress, ResultInBatch, QueryName, ResultKind",
		Object, QueryResultAddress, ResultInBatch, ResultQueryName, ResultKind);
	SpreadsheetDocumentForm = OpenForm(FormFullName("SpreadsheetDocumentForm"), OpeningParameters, ThisForm,
		False);

	If Not SpreadsheetDocumentForm.Initialized Then
		//Refresh opened form
		Notify("Refresh", OpeningParameters);
	EndIf;

EndProcedure

&AtClient
Procedure ShowHideResultPanelTotals_Command(Command)
	fShowTotals = Not Items.ShowHideResultPanelTotals.Check;
	Items.ShowHideResultPanelTotals.Check = fShowTotals;
	Items.QueryResult.Footer = fShowTotals;
EndProcedure

#Region ExecuteDataProcessor_Command

&AtServer
Function RunDataProcessorAtServer(Algorithm, fLineByLine = True)

	TimeConsumingOperationsModuleName = "TimeConsumingOperations";
	StandardSubsystemsServerModuleName = "StandardSubsystemsServer";
	If Metadata.CommonModules.Find(TimeConsumingOperationsModuleName) = Undefined Or Metadata.CommonModules.Find(
		StandardSubsystemsServerModuleName) = Undefined Then
		Return New Structure("Success, ErrorDescription", False, NStr("ru = 'Модули БСП не найдены'; en = 'SSL modules not found.'"));
	EndIf;

	StandardSubsystemsServerModule = Eval(StandardSubsystemsServerModuleName);
	Try
		Version = StandardSubsystemsServerModule.LibraryVersion();
	Except
		Return New Structure("Success, ErrorDescription", False, NStr("ru = 'Модули БСП не найдены'; en = 'SSL modules not found.'"));
	EndTry;

	arVersion = StrSplit(Version, ".");
	If Number(arVersion[0]) <= 2 And Not (Number(arVersion[0]) = 2 And Number(arVersion[1]) >= 3) Then
		Return New Structure("Success, ErrorDescription", False, StrTemplate(
			NStr("ru = 'Необходима БСП версии не ниже 2.3 (версия БСП текущей конфигурации %1)'; en = 'SSL version 2.3 or later is required (current SSL version is %1)'"), Version));
	EndIf;

	BackgroundJobResultAddress = PutToTempStorage(Undefined, UUID);

	stQueryResult = GetFromTempStorage(QueryResultAddress);

	ExecutionParameters = New Array;
	ExecutionParameters.Add(stQueryResult);
	ExecutionParameters.Add(ResultInBatch);
	ExecutionParameters.Add(Algorithm);
	ExecutionParameters.Add(fLineByLine);
	ExecutionParameters.Add(Object.AlgorithmExecutionUpdateIntervalOption);

	If Object.ExternalDataProcessorMode Then
		MethodParameters = New Structure("
										  |IsExternalDataProcessor,
										  |ExternalDataProcessorRef,
										  |DataProcessorName,
										  |MethodName,
										  |ExecutionParameters", True, Undefined, DataProcessorServerFileName,
			"ExecuteUserAlgorithm", ExecutionParameters);
	Else
		MethodParameters = New Structure("
										  |IsExternalDataProcessor,
										  |ExternalDataProcessorRef,
										  |DataProcessorName,
										  |MethodName,
										  |ExecutionParameters", False, Undefined, Object.DataProcessorName,
			"ExecuteUserAlgorithm", ExecutionParameters);
	EndIf;

	BackgroundJobProgressState = Undefined;
	BackgroundJobParameters = New Array;
	BackgroundJobParameters.Add(MethodParameters);
	BackgroundJobParameters.Add(BackgroundJobResultAddress);
	Job = BackgroundJobs.Execute("TimeConsumingOperations.RunDataProcessorObjectModuleProcedure",
		BackgroundJobParameters, , Object.Title);
	BackgroundJobID = Job.UUID;

	Return New Structure("Success", True);

EndFunction

&AtServer
Function GetBackgroundJobState()

	BackgroundJob = BackgroundJobs.FindByUUID(
		New UUID(BackgroundJobID));
	JobState = New Structure("ProgressState, Begin, State, ErrorInfo, UserMessages");
	FillPropertyValues(JobState, BackgroundJob, "Begin, State, ErrorInfo");

	If CodeExecutionMethod = 2 Or CodeExecutionMethod = 4 Then
		JobState.ProgressState = BackgroundJobProgressState;
	EndIf;

	UserMessages = BackgroundJob.GetUserMessages(True);
	JobState.UserMessages = New Array;
	For Each Message In UserMessages Do
		If StrStartsWith(Message.Text, BackgroundJobResultAddress) Then
			StateFromMessage = FormAttributeToValue("Object").StringToValue(Right(Message.Text, StrLen(
				Message.Text) - StrLen(BackgroundJobResultAddress)));
			JobState.ProgressState = StateFromMessage;
			BackgroundJobProgressState = StateFromMessage;
		Else
			JobState.UserMessages.Add(Message);
		EndIf;
	EndDo;

	If BackgroundJob.State = BackgroundJobState.Active Then
		JobState.State = 0;
	ElsIf BackgroundJob.State = BackgroundJobState.Completed Then
		JobState.State = 1;
	ElsIf BackgroundJob.State = BackgroundJobState.Failed Then
		JobState.State = 2;
	ElsIf BackgroundJob.State = BackgroundJobState.Canceled Then
		JobState.State = 3;
	EndIf;

	If BackgroundJob.ErrorInfo <> Undefined Then
		JobState.ErrorInfo = GetErrorInfoPresentation(BackgroundJob.ErrorInfo);
	EndIf;

	Return JobState;

EndFunction

&AtClient
Procedure ShowAlgorithmExecutionStatus(ProgressState = Undefined, Seconds = Undefined,
	fInStatus = False)

	If Seconds = Undefined Then
		ExecutionStatus = "";
		Items.ExecuteDataProcessor.Title = "Execute";
		Items.ExecuteDataProcessor.Picture = PictureLib.GenerateReport;
		RefreshAlgorithmFormItems();
	Else

		strDuration = TimeFromSeconds(Seconds);

		If ProgressState <> Undefined Then
			strProgress = Format(ProgressState.Progress, "ND=3; NFD=0; NZ=") + "%";
			If ProgressState.Progress > 0 And ProgressState.DurationAtProgressTime > 1000 Then
				strTimeLeft = StrTemplate(NStr("ru = 'осталось примерно %1'; en = 'about %1 left'"), TimeFromSeconds(Round(
					ProgressState.DurationAtProgressTime / ProgressState.Progress * (100
					- ProgressState.Progress) / 1000)));
			Else
				strTimeLeft = "";
			EndIf;
			strExplanation = StrTemplate(NStr("ru = '%1 прошло %2 %3'; en = '%1 passed %2 %3'"), strProgress, strDuration, strTimeLeft);
		Else
			strProgress = "";
			strExplanation = StrTemplate(NStr("ru = '%1 прошло %2'; en = '%1 passed %2'"), strProgress, strDuration);
		EndIf;

		If fInStatus Then
			Status(NStr("ru = 'Выполнение алгоритма'; en = 'Algorithm execution'"), ProgressState.Progress, strExplanation);
		Else
			ExecutionStatus = strExplanation;
		EndIf;

	EndIf;

EndProcedure

&AtClient
Procedure ShowBackgroundJobState() Export

	If Not ValueIsFilled(BackgroundJobID) Then
		ShowAlgorithmExecutionStatus();
		Return;
	EndIf;

	JobState = GetBackgroundJobState();

	If JobState.UserMessages <> Undefined Then
		For Each UserMessage In JobState.UserMessages Do
			UserMessage.Message();
		EndDo;
	EndIf;

	If JobState.State = 0 Then
		ShowAlgorithmExecutionStatus(JobState.ProgressState, CurrentDate()
			- JobState.Begin);
		AttachIdleHandler("ShowBackgroundJobState",
			Object.AlgorithmExecutionUpdateIntervalOption / 1000 / 2, True);
	ElsIf JobState.State = 2 Then
		ShowConsoleMessageBox(JobState.ErrorInfo);
		BackgroundJobID = "";
		ShowAlgorithmExecutionStatus();
	Else
		BackgroundJobID = "";
		ShowAlgorithmExecutionStatus();
	EndIf;

EndProcedure

&AtServerNoContext
Procedure ExecuteCode(ThisCode, Selection, Parameters)
	Execute (ThisCode);
EndProcedure

&AtServer
Function ExecuteAlgorithm(Algorithm)

	stQueryResult = GetFromTempStorage(QueryResultAddress);
	arQueryResult = stQueryResult.Результат;
	stResult = arQueryResult[Number(ResultInBatch) - 1];
	qrSelection = stResult.Result;
	selSelection = qrSelection.Select();

	Try
		ExecuteCode(Algorithm, selSelection, stQueryResult.Parameters);
	Except
		strErrorMessage = ErrorDescription();
		Return New Structure("Success, Continue, ErrorDescription", False, False, strErrorMessage);
	EndTry;

	Return New Structure("Success, Continue, ErrorDescription", True);

EndFunction

&AtServerNoContext
Function ExecuteAlgorithmLineByLine(QueryResultAddress, ResultInBatch, AlgorithmText)

	stQueryResult = GetFromTempStorage(QueryResultAddress);
	arQueryResult = stQueryResult.Result;
	stResult = arQueryResult[Number(ResultInBatch) - 1];
	qrSelection = stResult.Result;
	selSelection = qrSelection.Select();

	Try
		While selSelection.Next() Do
			ExecuteCode(AlgorithmText, selSelection, stQueryResult.Parameters);
		EndDo;
	Except
		strErrorMessage = ErrorDescription();
		Return New Structure("Success, Continue, ErrorDescription", False, False, strErrorMessage);
	EndTry;

	Return New Structure("Success, Continue, ErrorDescription, Progress", True, False, Undefined, 100);

EndFunction

&AtServerNoContext
Function ExecuteAlgorithmAtServerLineByLine(StateAddress, QueryResultAddress, ResultInBatch, AlgorithmText,
	AlgorithmExecutionUpdateIntervalOption)

	stStatus = GetFromTempStorage(StateAddress);

	If stStatus = Undefined Then
		stQueryResult = GetFromTempStorage(QueryResultAddress);
		arQueryResult = stQueryResult.Result;
		stResult = arQueryResult[Number(ResultInBatch) - 1];
		qrSelection = stResult.Result;
		selSelection = qrSelection.Select();
		stStatus = New Structure("Selection, Parameters, CountTotal, CountDone, Start, StartInMilliseconds",
			selSelection, stQueryResult.Parameters, selSelection.Count(), 0, CurrentDate(),
			CurrentUniversalDateInMilliseconds());
	EndIf;

	selSelection = stStatus.Selection;
	nCountDone = stStatus.CountDone;
	nPortionFinishMoment = CurrentUniversalDateInMilliseconds() + AlgorithmExecutionUpdateIntervalOption;

	Try

		fContinue = False;
		While selSelection.Next() Do

			ExecuteCode(AlgorithmText, selSelection, stStatus.Parameters);
			nCountDone = nCountDone + 1;

			If CurrentUniversalDateInMilliseconds() >= nPortionFinishMoment Then
				fContinue = True;
				Break;
			EndIf;

		EndDo;

		stStatus.CountDone = nCountDone;

	Except
		strErrorMessage = ErrorDescription();
		Return New Structure("Success, Continue, ErrorDescription", False, False, strErrorMessage);
	EndTry;

	If fContinue Then
		stStatus.Selection = selSelection;
		PutToTempStorage(stStatus, StateAddress);
	Else
		PutToTempStorage(Undefined, StateAddress);
	EndIf;

	Return New Structure("Success, Continue, ErrorDescription, Progress, Start, DurationAtProgressTime",
		True, fContinue, Undefined, stStatus.CountDone * 100 / stStatus.CountTotal,
		stStatus.Start, CurrentUniversalDateInMilliseconds() - stStatus.StartInMilliseconds);

EndFunction

&AtClient
Function ExecuteAlgorithmLineByLineIndication()

	If Not ValueIsFilled(StateAddress) Then
		StateAddress = PutToTempStorage(Undefined, UUID);
	Else
		PutToTempStorage(Undefined, StateAddress);
	EndIf;

	While True Do

		stResult = ExecuteAlgorithmAtServerLineByLine(StateAddress, QueryResultAddress, ResultInBatch,
			CurrentAlgorithmText(), Object.AlgorithmExecutionUpdateIntervalOption);

		If Not stResult.Success Then
			Break;
		EndIf;

		ShowAlgorithmExecutionStatus(stResult, CurrentDate() - stResult.Start, True);
		UserInterruptProcessing();

		If Not stResult.Continue Then
			Break;
		EndIf;

	EndDo;

	ShowAlgorithmExecutionStatus();

	Return stResult;

EndFunction

&AtServer
Procedure InterruptBackgroundJob()
	BackgroundJob = BackgroundJobs.FindByUUID(
		New UUID(BackgroundJobID));
	BackgroundJob.Cancel();
	BackgroundJobID = "";
EndProcedure

&AtClient
Procedure ExecuteDataProcessor_Command(Command)

	If Not ValueIsFilled(ResultInBatch) Or Number(ResultInBatch) <= 0 Then
		ShowConsoleMessageBox(NStr("ru = 'Выполнение невозможно - результат запроса отсутствует'; en = 'Query result not found.'"));
		Return;
	EndIf;

	If Not IsBlankString(BackgroundJobID) Then
		//Interrupting
		InterruptBackgroundJob();
		ShowBackgroundJobState();
		ShowConsoleMessageBox(NStr("ru = 'Выполнение прервано пользователем!'; en = 'Execution was interrupted by user.'"));
		Return;
	EndIf;

	If CodeExecutionMethod = 0 Then
		stResult = ExecuteAlgorithm(CurrentAlgorithmText());
	ElsIf CodeExecutionMethod = 1 Then
		stResult = ExecuteAlgorithmLineByLine(QueryResultAddress, ResultInBatch, CurrentAlgorithmText());
	ElsIf CodeExecutionMethod = 2 Then
		stResult = ExecuteAlgorithmLineByLineIndication();
	ElsIf CodeExecutionMethod = 3 Then
		//execution in background
		stResult = RunDataProcessorAtServer(CurrentAlgorithmText(), False);
	ElsIf CodeExecutionMethod = 4 Then
		//line-by-line execution in background with indication
		stResult = RunDataProcessorAtServer(CurrentAlgorithmText(), True);
	Else
		stResult = New Structure("Success, ErrorDescription", False, NStr("ru = 'Неверный метод исполнения кода'; en = 'Code execution method is incorrect.'"));
	EndIf;

	If CodeExecutionMethod = 3 Or CodeExecutionMethod = 4 Then
		If stResult.Success Then
			Items.ExecuteDataProcessor.Title = "Interrupt";
			//Pictures = GetFromTempStorage(Object.Pictures);
			//Items.ExecuteDataProcessor.Picture = Pictures.ExecutionPogress;
			Items.ExecuteDataProcessor.Picture = PictureLib.Stop;
			ShowBackgroundJobState();
		EndIf;
	EndIf;

	If Not stResult.Success Then
		ShowConsoleMessageBox(stResult.ErrorDescription);
	EndIf;

EndProcedure

#EndRegion

&AtClient
Procedure ChoicePredefinedCompletion(Result, AdditionalParameters) Export
	If ValueIsFilled(Result) Then
		FormDataChoicePredefined = Result.FormData;
		Items.QueryText.SelectedText = Result.Result;
	EndIf;
EndProcedure

&AtClient
Procedure InsertPredefinedValue_Command(Command)
	Var BeginLine, BeginColumn, EndLine, EndColumn;

	Items.QueryText.GetTextSelectionBounds(BeginLine, BeginColumn, EndLine, EndColumn);
	NotifyParameters = New Structure("BeginLine, BeginColumn, EndLine, EndColumn",
		BeginLine, BeginColumn, EndLine, EndColumn);
	CloseFormNotifyDescription = New NotifyDescription("ChoicePredefinedCompletion",
		ThisForm, NotifyParameters);
	OpeningParameters = New Structure("Object, FormData, QueryText, BeginLine, BeginColumn, EndLine, EndColumn",
		Object, FormDataChoicePredefined, QueryText, BeginLine, BeginColumn, EndLine,
		EndColumn);

	OpenForm(FormFullName("ChoicePredefined"), OpeningParameters, ThisForm, True, , ,
		CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);

EndProcedure

//&AtServer
//Procedure GetResultValueTable(Command)
//EndProcedure

&AtClient
Procedure ResultToParameter_Command(Command)

	vtTable = ExtractResultAsContainer();

	NotifyParameters = New Structure("Table, Row, Field", "QueryParameters", Undefined, "ValueType");
	CloseFormNotifyDescription = New NotifyDescription("RowEditEnd", ThisForm,
		NotifyParameters);
	OpeningParameters = New Structure("Object, ValueType, ContainerType, Name, EnabledInQuery, ToParameter", Object,
		vtTable, 3, ResultQueryName, False, True);
	OpenForm(FormFullName("EditType"), OpeningParameters, ThisForm, True, , ,
		CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);

EndProcedure

&AtClient
Procedure AlgorithmHelp_Command(Command)
	CurrentLanguage = Upper(CurrentSystemLanguage());
	OpeningParameters = New Structure("TemplateName, Title", "AlgorithmHelp_"+CurrentLanguage, NStr("ru = 'Обработка результата запроса кодом'; en = 'Query result processing by code'"));
	OpenForm(FormFullName("Help"), OpeningParameters, ThisForm);
EndProcedure

#Region GetCodeWithParameters_Command

&AtClient
Procedure GetCodeWithParameters_Command(Command)

	If Items.QueryBatch.CurrentData = Undefined Then
		Return;
	EndIf;
	
	//Trying to use query name. If it is incorrect, name will be "Query".
	QueryName = Items.QueryBatch.CurrentData.Name;
	If Not NameIsCorrect(QueryName) Then
		QueryName = "Query";
	EndIf;

	OpeningParameters = New Structure("
										|Object,
										|QueryName,
										|QueryText,
										|QueryParameters,
										|Title,
										|Content", Object, QueryName, QueryText,
		QueryParameters_GetAsString(), NStr("ru = 'Код для выполнения запроса на встроенном языке 1С'; en = 'Code for executing the query by 1C:Enterprise language'"));

	OpenForm(FormFullName("CodeForm"), OpeningParameters, ThisForm, False, , , ,
		FormWindowOpeningMode.LockOwnerWindow);

EndProcedure

#EndRegion //GetCodeWithParameters_Command

&AtClient
Procedure ShowHideQueryResultBatch_Command(Command)
	fQueryResultBatchVisible = Not Items.ShowHideQueryResultBatch.Check;
	Items.ShowHideQueryResultBatch.Check = fQueryResultBatchVisible;
	Items.QueryResultBatch.Visible = fQueryResultBatchVisible;
	Items.ResultInBatchGroup.Visible = Not fQueryResultBatchVisible;
	Object.SavedStates.Insert("QueryResultBatchVisible", fQueryResultBatchVisible);
EndProcedure

&AtServer
Procedure QueryParametersNextToTextAtServer()
	If Items.QueryParametersNextToText.Check Then
		Items.Move(Items.QueryParameters, Items.ParametersGroup);
	Else
		Items.Move(Items.QueryParameters, Items.ParametersPage);
	EndIf;
EndProcedure

&AtClient
Procedure QueryParametersNextToText_Command(Command)
	Items.QueryParametersNextToText.Check = Not Items.QueryParametersNextToText.Check;
	SavedStates_Save("QueryParametersNextToText", Items.QueryParametersNextToText.Check);
	QueryParametersNextToTextAtServer();
EndProcedure

#Region TechnologicalLog_Command

&AtServer
Procedure TechnologicalLog_Disable()
	DataProcessor = FormAttributeToValue("Object");
	DataProcessor.TechnologicalLog_Disable();
	ValueToFormAttribute(DataProcessor, "Object");
EndProcedure

&AtServer
Procedure TechnologicalLog_Enable()
	DataProcessor = FormAttributeToValue("Object");
	DataProcessor.TechnologicalLog_Enable();
	ValueToFormAttribute(DataProcessor, "Object");
EndProcedure

&AtServer
Function TechnologicalLog_Enabled()
	DataProcessor = FormAttributeToValue("Object");
	fResult = DataProcessor.TechnologicalLog_Enabled();
	ValueToFormAttribute(DataProcessor, "Object");
	Return fResult;
EndFunction

&AtServer
Function TechnologicalLog_Disabled()
	DataProcessor = FormAttributeToValue("Object");
	fResult = DataProcessor.TechnologicalLog_Disabled();
	ValueToFormAttribute(DataProcessor, "Object");
	Return fResult;
EndFunction

&AtClient
Procedure TechnologicalLog_WaitingForEnable() Export

	If Not Items.TechnologicalLog.Check Then
		Return;
	EndIf;

	If TechnologicalLog_Enabled() Then
		TechnologicalLog_EnablingIndication(True);
	Else
		If CurrentUniversalDateInMilliseconds() - TechLogBeginEndTime < 60 * 1000 Then
			AttachIdleHandler("TechnologicalLog_WaitingForEnable",
				TechLogSwitchingPollingPeriodOption, True);
		Else
			//Cannot enable technological log
			TechnologicalLog_Disable();
			Items.TechnologicalLog.Check = False;
		EndIf;
	EndIf;

EndProcedure

&AtServer
Procedure TechnologicalLog_EnablingIndication(fEnable)
	If fEnable Then
		Items.TechnologicalLog.BackColor = New Color(220, 0, 0);
		Items.TechnologicalLog.TextColor = New Color(255, 255, 255);
		TechLogEnabledAndRunning = Object.TechLogEnabled
			И Items.TechnologicalLog.Check;
	Else
		Items.TechnologicalLog.BackColor = New Color;
		Items.TechnologicalLog.TextColor = New Color;
		TechLogEnabledAndRunning = False;
	EndIf;
EndProcedure

&AtClient
Procedure TechnologicalLog_WaitingForDisable() Export

	If Items.TechnologicalLog.Check Then
		Return;
	EndIf;

	If TechnologicalLog_Disabled() Then
		TechnologicalLog_EnablingIndication(False);
	Else
		If CurrentUniversalDateInMilliseconds() - TechLogBeginEndTime < 60 * 1000 Then
			AttachIdleHandler("TechnologicalLog_WaitingForDisable",
				TechLogSwitchingPollingPeriodOption, True);
		Else
			//Cannot delete technological log directory.
			//Assume that technological log is disabled.
			TechnologicalLog_EnablingIndication(False);
		EndIf;
	EndIf;

EndProcedure

&AtClient
Procedure TechnologicalLog_Command(Command)
	If Items.TechnologicalLog.Check Then
		TechnologicalLog_Disable();
		Items.TechnologicalLog.Check = False;
		Items.QueryPlan.Visible = False;
		Items.QueryResultBatchInfo.CellHyperlink = False;
		TechLogBeginEndTime = CurrentUniversalDateInMilliseconds();
		AttachIdleHandler("TechnologicalLog_WaitingForDisable",
			TechLogSwitchingPollingPeriodOption, True);
	Else
		TechnologicalLog_Enable();
		TechLogEnabledAndRunning = False;
		Items.TechnologicalLog.Check = True;
		TechnologicalLog_EnablingIndication(False);
		TechLogBeginEndTime = CurrentUniversalDateInMilliseconds();
		AttachIdleHandler("TechnologicalLog_WaitingForEnable",
			TechLogSwitchingPollingPeriodOption, True);
	EndIf;
EndProcedure

&AtClient
Procedure QueryPlan_Command(Command)

	CurrentRow = Items.QueryResultBatch.CurrentRow;
	If CurrentRow = Undefined Then
		Return;
	EndIf;

	OpeningParameters = New Structure("Object, QueryResultAddress, ResultInBatch", Object,
		QueryResultAddress, QueryResultBatch.IndexOf(QueryResultBatch.FindByID(
		CurrentRow)) + 1);
	Form = OpenForm(FormFullName("QueryPlanForm"), OpeningParameters, ThisForm, False, , , ,
		FormWindowOpeningMode.LockOwnerWindow);

	If Form = Undefined Then
		ShowConsoleMessageBox(NStr("ru = 'Не удалось получить информацию о запросе'; en  ='Cannot get query info.'"));
	EndIf;

EndProcedure

#EndRegion //TechnologicalLog_Command

&AtClient
Procedure ExecuteContinuation(AdditionalParameters)

	If AdditionalParameters.FollowUp = "OnOpenFollowUp" Then
		OnOpenFollowUp(AdditionalParameters);
		Return;
	ElsIf AdditionalParameters.FollowUp = "LoadQueryBatch" Then
		LoadQueryBatch(AdditionalParameters);
		Return;
	ElsIf AdditionalParameters.FollowUp = "ContinueQueryBatch_New" Then
		ContinueQueryBatch_New(AdditionalParameters);
		Return;
	ElsIf AdditionalParameters.FollowUp = "AfterChoosingFileForLoadingQueryBatchCompletion" Then
		AfterChoosingFileForLoadingQueryBatchCompletion(AdditionalParameters);
		Return;
	EndIf;
	
	//This operator works anywhere except web-client:
	Execute (AdditionalParameters.FollowUp + "(AdditionalParameters);");
	//This procedure lets the Execute operator work at web-client.
	//If there is an error at web-client at this line, it means something else required in the condition above.

EndProcedure

&AtClient
Procedure AfterChoosingFileForLoadingQueryBatchCompletion(AdditionalParameters) Export
	SetQueriesFileName(AdditionalParameters.FileName);
	EditingQuery = -1;
	QueryBatch_Save( , StateAutoSaveFileName, True);
EndProcedure

&AtClient
Procedure ContinueQueryBatch_New(AdditionalParameters)
	QueryBatch_New();
EndProcedure

#EndRegion //InteractiveCommands

#Region GetConsoleTechLogFiles

&AtClient
Procedure GetConsoleTechLogFiles(Directory)

	arLogs = GetLogFilesList();
	For Each LogFile Из arLogs Do
		Message(LogFile.FullName);
	EndDo;

EndProcedure

&AtServer
Function GetLogFilesList()
	arLogs = FindFiles(Object.TechLogFolder, "*.log", True);
	Return arLogs;
EndFunction

#EndRegion //GetConsoleTechLogFiles_Command

#Region Algorithms

&AtClient
Procedure SetAlgorithmText(NewText)
	If UT_IsPartOfUniversalTools Then
		UT_CodeEditorClient.SetEditorText(ThisObject, "Algorithm", NewText);
	Else
		AlgorithmText = NewText;
	EndIf;
EndProcedure

&AtClient
Function CurrentAlgorithmText()
	If UT_IsPartOfUniversalTools Then
		Return UT_CodeEditorClient.EditorCodeText(ThisObject, "Algorithm");
	Else
		Return AlgorithmText;
	EndIf;
EndFunction

&AtClient
Function CurrentQueryText()
	Return QueryText;
EndFunction

&AtClient
Function ItemSelectionBounds(Item)
	Bounds = New Structure;
	Bounds.Insert("RowBeginning", 0);
	Bounds.Insert("ColumnBeginning", 0);
	Bounds.Insert("RowEnd", 0);
	Bounds.Insert("ColumnEnd", 0);

	Item.GetTextSelectionBounds(Bounds.RowBeginning, Bounds.ColumnBeginning, Bounds.RowEnd,
		Bounds.ColumnEnd);

	Return Bounds;
EndFunction

&AtClient
Procedure SetAlgorithmSelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd)
	If UT_IsPartOfUniversalTools Then
		UT_CodeEditorClient.SetTextSelectionBorders(ThisObject, "Algorithm", RowBeginning, ColumnBeginning,
			RowEnd, ColumnEnd);
	Else
		Items.AlgorithmText.SetTextSelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);
	EndIf;
EndProcedure

&AtClient
Procedure SetQuerySelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd)
	
	Items.QueryText.SetTextSelectionBounds(RowBeginning, ColumnBeginning, RowEnd, ColumnEnd);
	
EndProcedure

&AtClient 
Function AlgorithmSelectionBoundaries()
	If UT_IsPartOfUniversalTools Then
		Return UT_CodeEditorClient.EditorSelectionBorders(ThisObject, "Algorithm");
	Else
		Return ItemSelectionBounds(Items.AlgorithmText);	
	EndIf;
EndFunction

&AtClient 
Function QuerySelectionBoundaries()
//	If UT_IsPartOfUniversalTools Then
//		Return UT_CodeEditorClient.EditorSelectionBorders(ThisObject, "Algorithm");
//	Else
		Return ItemSelectionBounds(Items.QueryText);	
//	EndIf;
EndFunction

&AtClient
Procedure InsertTextInAlgorithmCursorPosition (Text)
	If UT_IsPartOfUniversalTools Then
		UT_CodeEditorClient.InsertTextInCursorLocation(ThisObject, "Algorithm", Text);
	Else
		InsertTextInItemCursorLocation(Items.AlgorithmText, Text);	
	EndIf;
	
EndProcedure

&AtClient
Procedure InsertTextInItemCursorLocation(Item, Text)
	Item.SelectedText = Text;
EndProcedure

#EndRegion

#Region UT

&AtClient
Procedure UT_EditValue(Command)
	FormItem=Items.QueryResult;
	If ResultKind = "tree" Then
		FormItem=Items.QueryResultTree;
	EndIf;

	CurData=FormItem.CurrentData;
	CurColumn=FormItem.CurrentItem;

	ColumnName=StrReplace(CurColumn.Name, FormItem.Name, "");

	ColumnValue=CurData[ColumnName];

	Try
		CommonClientModule=Eval("UT_CommonClient");
	Except
		CommonClientModule=Undefined;
	EndTry;

	If CommonClientModule = Undefined Then
		Return;
	EndIf;

	If ColumnValue = "<ValueStorage>" Then
		CommonClientModule.EditValueStorage(ЭтотОбъект, CurData[ColumnName
			+ ContainerAttributeSuffix].Хранилище);
	Else
		CommonClientModule.EditObject(ColumnValue);
	EndIf;

EndProcedure

&AtServer
Procedure UT_FillWithDebugData()
	If Not Parameters.Property("DebugData") Then
		Return;
	EndIf;

	If Object.SavedStates = Undefined Then
		Object.SavedStates = New Structure;
	EndIf;

	Modified = False;

	AutoSaveIntervalOption = 60;
	SaveCommentsOption = True;
	AutoSaveBeforeQueryExecutionOption = True;
	AlgorithmExecutionUpdateIntervalOption = 1000;
	Object.OptionProcessing__ = True;
	Object.AlgorithmExecutionUpdateIntervalOption = 1000;

	DataProcessorObject=FormAttributeToValue("Object");

	UT_Debug=True;

	DebugData=GetFromTempStorage(Parameters.DebugData);

	TreeRows=QueryBatch.GetItems();

	NewRow=TreeRows.Add();
	NewRow.Name=NStr("ru = 'Отладка'; en = 'Debug'");
	NewRow.QueryText=DebugData.Text;
	NewRow.QueryParameters=New ValueList;

	If DebugData.Property("Parameters") Then
		For Each CurParameter In DebugData.Parameters Do

			NewParameter=New Structure;
			NewParameter.Insert("Name", CurParameter.Key);
			NewParameter.Insert("ContainerType", GetValueFormCode(CurParameter.Value));

			NewParameter.Insert("Container", DataProcessorObject.Container_SaveValue(CurParameter.Value));

			If NewParameter.ContainerType = 2 Then
				TypeArray=New Array;

				For Each ArrayValue In CurParameter.Value Do
					CurType=TypeOf(ArrayValue);
					If TypeArray.Find(CurType) = Undefined Then
						TypeArray.Add(CurType);
					EndIf;
				EndDo;

				NewParameter.Insert("ValueType", New TypeDescription(TypeArray));
				NewParameter.Insert("Value", NewParameter.Container.Presentation);
			ElsIf NewParameter.ContainerType = 1 Then
				TypeArray=New Array;

				For Each ListItem In CurParameter.Value Do
					CurType=TypeOf(ListItem.Value);
					If TypeArray.Find(CurType) = Undefined Then
						TypeArray.Add(CurType);
					EndIf;
				EndDo;

				NewParameter.Insert("ValueType", New TypeDescription(TypeArray));
				NewParameter.Insert("Value", NewParameter.Container.Presentation);
			ElsIf NewParameter.ContainerType = 3 Then
				NewParameter.Insert("ValueType", NStr("ru = 'Талица значений'; en = 'Value table'"));
				NewParameter.Insert("Value", NewParameter.Container.Presentation);
			Else
				NewParameter.Insert("ValueType", TypeDescriptionByType(TypeOf(CurParameter.Value)));
				NewParameter.Insert("Value", NewParameter.Container);

			EndIf;
			NewRow.QueryParameters.Add(NewParameter);
		EndDo;
	EndIf;

	If DebugData.Property("TempTables") Then
		NewRow.TempTables=New ValueList;

		For Each KeyValue In DebugData.TempTables Do
			TempTable=New Structure;
			TempTable.Вставить("Name", KeyValue.Key);
			TempTable.Вставить("Container", DataProcessorObject.Container_SaveValue(KeyValue.Value));
			TempTable.Вставить("Value", TempTable.Container.Presentation);

			NewRow.TempTables.Add(TempTable);
		EndDo;
	EndIf;

EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command)
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

//@skip-warning
&AtClient
Procedure EditorFieldDocumentGenerated(Item)
	UT_CodeEditorClient.HTMLEditorFieldDocumentGenerated(ThisObject, Item);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_EditorFieldOnClick(Item, EventData, StandardProcessing)
	UT_CodeEditorClient.HTMLEditorFieldOnClick(ThisObject, Item, EventData, StandardProcessing);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_CodeEditorDeferredInitializingEditors()
	UT_CodeEditorClient.CodeEditorDeferredInitializingEditors(ThisObject);
EndProcedure

&AtClient
Procedure Attachable_CodeEditorInitializingCompletion() Export
	CurrentRow = Items.QueryBatch.CurrentRow;
	If CurrentRow = Undefined Then
		Return;
	EndIf;

	stQueryData = Query_GetQueryData(CurrentRow);

	SetAlgorithmText(stQueryData.CodeText);
	
	
EndProcedure

&AtClient
Procedure UT_AddResultStructureContextAlgorithm()
	AdditionalContextStructure = New Structure;
	
	For Each Variable In ResultRecordStructure.GetItems() Do
		VariableStructure = New Structure;
		If Variable.Name=NStr("ru = 'Выборка'; en = 'Selection'") Then
			VariableStructure.Insert("Type", "QueryResultSelection");
		Else
			VariableStructure.Insert("Type", "Structure");
		EndIf;
		
		VariableStructure.Insert("ChildProperties", New Array);
		
		For Each CurVariableAttribute In Variable.GetItems() Do
			NewProperty = New Structure;
			NewProperty.Insert("Name", CurVariableAttribute.Name);
			NewProperty.Insert("Type", CurVariableAttribute.Type);
			
			VariableStructure.ChildProperties.Add(NewProperty);
		EndDo;
		
		AdditionalContextStructure.Insert(Variable.Name, VariableStructure);
	EndDo;
	
	UT_CodeEditorClient.AddCodeEditorContext(ThisObject, "Algorithm", AdditionalContextStructure);


EndProcedure
#EndRegion

#If Client Then

FilesExtension = "q9";
ConsoleSignature = ConsoleDataProcessorName(ThisObject);
SaveFilter = NStr("ru = 'Файл запросов (*.'; en = 'Query file (*.'") + FilesExtension + ")|*." + FilesExtension;
AutoSaveExtension = "q9save";
FormatVersion = 13;

#EndIf