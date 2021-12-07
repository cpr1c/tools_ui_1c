&AtServer
Procedure GetStructure()

	InfobaseStructure = GetFromTempStorage(DataBaseStructureAddress);

	If InfobaseStructure = Undefined Then

		InfobaseStructure = GetDBStorageStructureInfo();
		PutToTempStorage(InfobaseStructure, DataBaseStructureAddress);

	EndIf;

	FillResultTable(InfobaseStructure);
EndProcedure

&AtServer
Procedure FillResultTable(InfobaseStructure, FoundRows = Undefined)
	Result.Clear();

	If FoundRows = Undefined Then
		ResultRows=InfobaseStructure;
	Else
		ResultRows=FoundRows;
	EndIf;

	For Each Row In ResultRows Do
		NewRow = Result.Add();
		NewRow.TableName = Row.TableName;
		NewRow.Metadata = Row.Metadata;
		NewRow.Purpose = Row.Purpose;
		NewRow.StorageTableName = Row.StorageTableName;

		For Each Field In Row.Fields Do
			NewFieldsRow = NewRow.Fields.Add();
			NewFieldsRow.StorageFieldName = Field.StorageFieldName;
			NewFieldsRow.FieldName = Field.FieldName;
			NewFieldsRow.Metadata = Field.Metadata;
		EndDo;

		For Each Index In Row.Indexes Do
			NewIndexesRow = NewRow.Indexes.Add();
			NewIndexesRow.StorageIndexName = Index.StorageIndexName;

			// Index fields
			For Each Field In Index.Fields Do
				NewIndexFieldsRow = NewIndexesRow.IndexFields.Add();
				NewIndexFieldsRow.StorageFieldName = Field.StorageFieldName;
				NewIndexFieldsRow.FieldName = Field.FieldName;
				NewIndexFieldsRow.Metadata = Field.Metadata;
			EndDo;

		EndDo;

	EndDo;

	Result.Sort("Metadata ASC,TableName ASC");
EndProcedure

&AtServer
Procedure FindByStorageTableName()

	InfobaseStructure = GetFromTempStorage(DataBaseStructureAddress);

	SearchName = Upper(TrimAll(Filter));
	If Not ExactMap And Left(SearchName, 1) = "_" Then
		SearchName = Mid(SearchName, 2);
	EndIf;
	FoundRows = New Array;

	If IsBlankString(SearchName) Then
		Return;
	EndIf;

	For Each Row In InfobaseStructure Do

		If IncludingFields Then
			For Each RowField In Row.Fields Do
				If ExactMap Then
					If Upper(RowField.StorageFieldName) = SearchName Or Upper(RowField.FieldName) = SearchName Then
						FoundRows.Add(Row);
					EndIf;
				Else

					If Find(Upper(RowField.StorageFieldName), SearchName) > 0 Or Find(Upper(RowField.FieldName),
						SearchName) Then
						FoundRows.Add(Row);
					EndIf;
				EndIf;
			EndDo;
		EndIf;

		If ExactMap Then
			If Upper(Row.StorageTableName) = SearchName Or Upper(Row.TableName) = SearchName Or Upper(
				Row.Metadata) = SearchName Or Upper(Row.Purpose) = SearchName Then
				FoundRows.Add(Row);
			EndIf;
		Else
			If Find(Upper(Row.StorageTableName), SearchName) > 0 Or Find(Upper(Row.TableName),
				SearchName) Or Find(Upper(Row.Metadata), SearchName) Or Find(Upper(Row.Purpose),
				SearchName) Then
				FoundRows.Add(Row);
			EndIf;
		EndIf;
	EndDo;

	FillResultTable(FoundRows);
EndProcedure

&AtClient
Procedure SetFilter(Command)

	FindByStorageTableName();

EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	DataBaseStructureAddress = PutToTempStorage(Undefined, UUID);
	GetStructure();

	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);

EndProcedure

&AtClient
Procedure FilterTextEditEnd(Item, Text, ChoiceData, DataGetParameters, StandardProcessing)

	ChoiceData = New ValueList;
	ChoiceData.Add(Text);
	StandardProcessing = False;
	Filter = Text;
	FindByStorageTableName();

EndProcedure

&AtClient
Procedure IncludingFieldsOnChange(Item)
	FindByStorageTableName();
EndProcedure

&AtClient
Procedure ExactMapOnChange(Item)
	FindByStorageTableName();
EndProcedure

&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) Export
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure