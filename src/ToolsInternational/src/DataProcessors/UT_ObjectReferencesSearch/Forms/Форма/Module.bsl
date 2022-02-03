#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("SearchObject") Then
		Object.SourceObject = Parameters.SearchObject;
	EndIf;
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	If ValueIsFilled(Object.SourceObject) Then
		SourceObjectOnChange(Undefined);
		ExecuteReferencesSearch();
	EndIf;
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure SourceObjectOnChange(Item)
	If NOT ValueIsFilled(Object.SourceObject) Then
		SourceUUID="";
	Else
		Try
			SourceUUID = Object.SourceObject.UUID();
		Except
			//TODO Amend the implementation code
		EndTry;
	EndIf;
EndProcedure

&AtClient
Procedure SearchResultSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;
	OpenCurrentRowObject();
EndProcedure

&AtClient
Procedure SearchResultOnRowActivation(Item)
	CurrentData = Items.SearchResult.CurrentData;
	If CurrentData = Undefined Then
		OpenCommandVisibility = False;
		SearchCommandVisibility = False;
	Else
		OpenCommandVisibility = CurrentData.CanBeOpened;
		SearchCommandVisibility = CurrentData.ReferenceType;
	EndIf;

	Items.TableContextMenuOpenObject.Visible = OpenCommandVisibility;
	Items.TableContextMenuSearchForObject.Visible = SearchCommandVisibility;
EndProcedure

#EndRegion

#Region FormCommandHandlers

&AtClient
Procedure FindReferences(Command)
	ExecuteReferencesSearch();
EndProcedure

&AtClient
Procedure OpenObject(Command)
	OpenCurrentRowObject();
EndProcedure

&AtClient
Procedure SearchForObject(Command)
	CurrentData = Items.SearchResult.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	If NOT CurrentData.ReferenceType Then
		Return;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("SearchObject", CurrentData.FoundObject);

	OpenForm("DataProcessor.UT_ObjectReferencesSearch.Form", FormParameters, , New UUID);
EndProcedure

&AtClient
Procedure EditObject(Command)
	CurrentData = Items.SearchResult.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(CurrentData.FoundObject);
EndProcedure

&AtClient
Procedure EditSourceObject(Command)
	If NOT ValueIsFilled(Object.SourceObject) Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(Object.SourceObject);
EndProcedure

&AtClient
Procedure SourceObjectByReference(Command)
	CompletionHandler = New NotifyDescription("InputURLCompletion", ThisObject);
	ShowInputString(CompletionHandler, , NStr("ru = 'Нав. ссылка на объект (e1cib/data/...)'; en = 'Object URL (e1cib/data/...)'"));
EndProcedure

&AtClient
Procedure InputURLCompletion(InputResult, AdditionalParameters) Export
	If InputResult = Undefined Then
		Return;
	EndIf;	
	
	FoundObject = FindObjectByURL(InputResult);
	If Object.SourceObject <> FoundObject Then
		Object.SourceObject = FoundObject;
		SourceObjectOnChange(Undefined);
	EndIf;
	
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure ExecuteReferencesSearchAtServer()
	If NOT ValueIsFilled(Object.SourceObject) Then
		Msg = NStr("ru = 'Не выбран объект, на который необходимо найти ссылки'; en = 'Object to find references is not selected'");
		UT_CommonClientServer.MessageToUser(Msg, ,
			"Object.SourceObject");
		Return;
	EndIf;

	MapCanBeOpened = New Map;
	MapCanBeOpened.Insert(0, False); // 0
	MapCanBeOpened.Insert(1, True); // 1 Constant
	MapCanBeOpened.Insert(2, True); // 2 Catalog
	MapCanBeOpened.Insert(3, True); // 3 Document
	MapCanBeOpened.Insert(4, False); // 4 Accumulation register
	MapCanBeOpened.Insert(5, False); // 5 Accounting register
	MapCanBeOpened.Insert(6, False); // 6 Calculation register
	MapCanBeOpened.Insert(7, True); // 7 Information register
	MapCanBeOpened.Insert(8, True); // 8 Business process
	MapCanBeOpened.Insert(9, True); // 9 Task
	MapCanBeOpened.Insert(11, True); // 11 Chart of calculation types
	MapCanBeOpened.Insert(12, True); // 12 Chart of accounts
	MapCanBeOpened.Insert(13, True); // 13 External data source set
	MapCanBeOpened.Insert(14, True); // 14 External data source reference
	MapReferenceType = New Map;
	MapReferenceType.Insert(0, False); // 0
	MapReferenceType.Insert(1, False); // 1 Constant
	MapReferenceType.Insert(2, True); // 2 Catalog
	MapReferenceType.Insert(3, True); // 3 Document
	MapReferenceType.Insert(4, False); // 4 Accumulation register
	MapReferenceType.Insert(5, False); // 5 Accounting register
	MapReferenceType.Insert(6, False); // 6 Calculation register
	MapReferenceType.Insert(7, False); // 7 Information register
	MapReferenceType.Insert(8, True); // 8 Business process
	MapReferenceType.Insert(9, True); // 9 Task
	MapReferenceType.Insert(10, True); // 10 Chart of characteristic types
	MapReferenceType.Insert(11, True); // 11 Chart of calculation types
	MapReferenceType.Insert(12, True); // 12 Chart of accounts
	MapReferenceType.Insert(13, False); // 13 External data source set
	MapReferenceType.Insert(14, True); // 14 External data source reference
	MapOfPictures = New Map;
	MapOfPictures.Insert(0, New Picture); // 0
	MapOfPictures.Insert(1, PictureLib.Constant); // 1 Constant
	MapOfPictures.Insert(2, PictureLib.Catalog); // 2 Catalog
	MapOfPictures.Insert(3, PictureLib.Document); // 3 Document
	MapOfPictures.Insert(4, PictureLib.AccumulationRegister); // 4 Accumulation register
	MapOfPictures.Insert(5, PictureLib.AccountingRegister); // 5 Accounting register
	MapOfPictures.Insert(6, PictureLib.CalculationRegister); // 6 Calculation register
	MapOfPictures.Insert(7, PictureLib.InformationRegister); // 7 Information register
	MapOfPictures.Insert(8, PictureLib.BusinessProcess); // 8 Business process
	MapOfPictures.Insert(9, PictureLib.Task); // 9 Task
	MapOfPictures.Insert(10, PictureLib.ChartOfCharacteristicTypes); // 10 Chart of characteristic types
	MapOfPictures.Insert(11, PictureLib.ChartOfCalculationTypes); // 11 Chart of calculation types
	MapOfPictures.Insert(12, PictureLib.ChartOfAccounts); // 12 Chart of accounts
	MapOfPictures.Insert(13, PictureLib.ExternalDataSourceTable); // 13 External data source set
	MapOfPictures.Insert(14, PictureLib.ExternalDataSourceTable); // 14 External data source reference
	ArrayOfSearch = New Array;
	ArrayOfSearch.Add(Object.SourceObject);

	ReferencesTable = FindByRef(ArrayOfSearch);

	SearchResult.Clear();
	Object.FoundCount = ReferencesTable.Count();

	First = True;
	For Each FoundRow In ReferencesTable Do
	// 0 - find object
	// 1 - found object
	// 2 - metadata object
		BaseTypeByNumber = MetadataTypyByNumber(FoundRow.Metadata);

		FoundPresentation = FoundObjectPresentation(BaseTypeByNumber, FoundRow.Metadata,
			FoundRow.Data) + " (" + FoundRow.Metadata.FullName() + ")";

		NewRow = SearchResult.Add();
		NewRow.Ref = FoundRow.Ref;
		NewRow.ObjectPresentation = FoundPresentation;
		NewRow.FoundObject = FoundRow.Data;
		NewRow.Picture = MapOfPictures[BaseTypeByNumber];
		NewRow.CanBeOpened = MapCanBeOpened[BaseTypeByNumber];
		NewRow.ReferenceType = MapReferenceType[BaseTypeByNumber];
		If NewRow.ReferenceType Then
			NewRow.UUID = NewRow.FoundObject.UUID();
		EndIf;

		If First Then
			Items.SearchResult.CurrentRow = NewRow.GetID();
			First = False;
		EndIf;
	EndDo;

EndProcedure

&AtClient
Procedure OpenCurrentRowObject()
	CurrentData = Items.SearchResult.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	If NOT CurrentData.CanBeOpened Then
		Return;
	EndIf;

	ShowValue( , CurrentData.FoundObject);

EndProcedure

&AtClient
Procedure ExecuteReferencesSearch()
	If NOT ValueIsFilled(Object.SourceObject) Then
		Msg = NStr("ru = 'Не выбран объект, на который необходимо найти ссылки'; en = 'Object to find references is not selected'");
		UT_CommonClientServer.MessageToUser(Msg, ,
			"Object.SourceObject");
		Return;
	EndIf;

	Msg = NStr("ru = 'Выполняется поиск ссылок на объект'; en = 'Object references search in progress'");
	Status(Msg, , , PictureLib.SearchControl);
	
	ExecuteReferencesSearchAtServer();
	
	Msg = NStr("ru = 'Поиск ссылок на объект завершен'; en = 'Object references search has been completed'");
	Status(Msg, , , PictureLib.SearchControl);

	ThisObject.CurrentItem = Items.SearchResult;

EndProcedure

&AtServerNoContext
Function FoundObjectPresentation(BaseTypeByNumber, ObjectMetadata, FoundObject)

	Presentation = TrimAll(FoundObject);
	If BaseTypeByNumber = 2 OR BaseTypeByNumber = 3 OR BaseTypeByNumber = 8 OR BaseTypeByNumber = 9
		OR BaseTypeByNumber = 10 OR BaseTypeByNumber = 11 OR BaseTypeByNumber = 12 OR BaseTypeByNumber = 14 Then

	ElsIf BaseTypeByNumber = 4 OR BaseTypeByNumber = 5 OR BaseTypeByNumber = 6 OR BaseTypeByNumber = 7 Then

		Presentation = "";
		If ObjectMetadata.InformationRegisterPeriodicity
			<> Metadata.ObjectProperties.InformationRegisterPeriodicity.Nonperiodical Then

			Presentation = String(FoundObject.Period);

		EndIf;

		If ObjectMetadata.WriteMode = Metadata.ObjectProperties.RegisterWriteMode.RecorderSubordinate Then

			Presentation = ?(StrLen(Presentation) = 0, "", Presentation + "; ") + String(
				FoundObject.Recorder);

		EndIf;

		For Each Dimension In ObjectMetadata.Dimensions Do

			Presentation = ?(StrLen(Presentation) = 0, "", Presentation + "; ") + String(
				FoundObject[Dimension.Name]);

		EndDo;

	ElsIf BaseTypeByNumber = 13 Then

		Presentation = "";
		For Each Dimension In ObjectMetadata.KeyFields Do

			Presentation = ?(StrLen(Presentation) = 0, "", Presentation + "; ") + String(
				FoundObject[Dimension.Name]);

		EndDo;
	EndIf;

	Return Presentation;

EndFunction

&AtServerNoContext
Function MetadataTypyByNumber(ObjectMetadata)

	MetadataType = 0;
	If Metadata.Constants.Contains(ObjectMetadata) Then

		MetadataType = 1;
	ElsIf Metadata.Catalogs.Contains(ObjectMetadata) Then

		MetadataType = 2;
	ElsIf Metadata.Documents.Contains(ObjectMetadata) Then

		MetadataType = 3;
	ElsIf Metadata.AccumulationRegisters.Contains(ObjectMetadata) Then

		MetadataType = 4;
	ElsIf Metadata.AccountingRegisters.Contains(ObjectMetadata) Then

		MetadataType = 5;
	ElsIf Metadata.CalculationRegisters.Contains(ObjectMetadata) Then

		MetadataType = 6;
	ElsIf Metadata.InformationRegisters.Contains(ObjectMetadata) Then

		MetadataType = 7;
	ElsIf Metadata.BusinessProcesses.Contains(ObjectMetadata) Then

		MetadataType = 8;
	ElsIf Metadata.Tasks.Contains(ObjectMetadata) Then

		MetadataType = 9;
	ElsIf Metadata.ChartsOfCharacteristicTypes.Contains(ObjectMetadata) Then

		MetadataType = 10;
	ElsIf Metadata.ChartsOfCalculationTypes.Contains(ObjectMetadata) Then

		MetadataType = 11;
	ElsIf Metadata.ChartsOfAccounts.Contains(ObjectMetadata) Then

		MetadataType = 12;
	Else
		For Each ExternalSource In Metadata.ExternalDataSources Do

			If ExternalSource.Tables.Contains(ObjectMetadata) Then

				If ObjectMetadata.TableDataType
					= Metadata.ObjectProperties.ExternalDataSourceTableDataType.ObjectData Then

					MetadataType = 14; // object table
				Else

					MetadataType = 13; // non-object table
				EndIf;
				Break;
			EndIf;
		EndDo;
	EndIf;

	Return MetadataType;

EndFunction

//TODO This function has to be moved to common modules. It is copied from UT_ObjectsAttributesEditor.ObjectForm
&AtServerNoContext
Function FindObjectByURL(Val URL)
	Pos1 = Find(URL, "e1cib/data/");
	Pos2 = Find(URL, "?ref=");

	If Pos1 = 0 Or Pos2 = 0 Then
		Return Undefined;
	EndIf;

	Try
		TypeName = Mid(URL, Pos1 + 11, Pos2 - Pos1 - 11);
		ValueTemplate = ValueToStringInternal(PredefinedValue(TypeName + ".EmptyRef"));
		RefValue = StrReplace(ValueTemplate, "00000000000000000000000000000000", Mid(URL, Pos2 + 5));
		Ref = ValueFromStringInternal(RefValue);
	Except
		Return Undefined;
	EndTry;

	Return Ref;
EndFunction

#EndRegion