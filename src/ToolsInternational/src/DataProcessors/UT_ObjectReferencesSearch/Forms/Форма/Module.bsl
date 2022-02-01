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

	OpenForm("Обработка.UT_ObjectReferencesSearch.Форма", FormParameters, , New UUID);
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
	CompletionHandler = New NotifyDescription("ВводНавигационнойСсылкиЗавершение", ThisObject);
	ShowInputString(CompletionHandler, , "Нав. ссылка на объект (e1cib/data/...)");
EndProcedure

&AtClient
Procedure ВводНавигационнойСсылкиЗавершение(InputResult, AdditionalParameters) Export
	If InputResult = Undefined Then
		Return;
	EndIf;	
	
	FoundObject = вНайтиОбъектПоURL(InputResult);
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
		UT_CommonClientServer.MessageToUser("Не выбран объект, на который необходимо найти ссылки", ,
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
	MapOfPictures.Insert(1, PictureLib.Константа); // 1 Constant
	MapOfPictures.Insert(2, PictureLib.Справочник); // 2 Catalog
	MapOfPictures.Insert(3, PictureLib.Документ); // 3 Document
	MapOfPictures.Insert(4, PictureLib.РегистрНакопления); // 4 Accumulation register
	MapOfPictures.Insert(5, PictureLib.РегистрБухгалтерии); // 5 Accounting register
	MapOfPictures.Insert(6, PictureLib.РегистрРасчета); // 6 Calculation register
	MapOfPictures.Insert(7, PictureLib.РегистрСведений); // 7 Information register
	MapOfPictures.Insert(8, PictureLib.БизнесПроцесс); // 8 Business process
	MapOfPictures.Insert(9, PictureLib.Задача); // 9 Task
	MapOfPictures.Insert(10, PictureLib.ПланВидовХарактеристик); // 10 Chart of characteristic types
	MapOfPictures.Insert(11, PictureLib.ПланВидовРасчета); // 11 Chart of calculation types
	MapOfPictures.Insert(12, PictureLib.ПланСчетов); // 12 Chart of accounts
	MapOfPictures.Insert(13, PictureLib.ВнешнийИсточникДанныхТаблица); // 13 External data source set
	MapOfPictures.Insert(14, PictureLib.ВнешнийИсточникДанныхТаблица); // 14 External data source reference
	ArrayOfSearch = New Array;
	ArrayOfSearch.Add(Object.SourceObject);

	ReferencesTable = FindByRef(ArrayOfSearch);

	SearchResult.Clear();
	Object.FoundCount = ReferencesTable.Count();

	First = Истина;
	For Each СтрокаНайденнного In ReferencesTable Do
	// 0 - find object
	// 1 - found object
	// 2 - metadata object
		БазовыйТипЧислом = ТипМетаданныхЧислом(СтрокаНайденнного.Metadata);

		FoundPresentation = FoundObjectPresentation(БазовыйТипЧислом, СтрокаНайденнного.Metadata,
			СтрокаНайденнного.Data) + " (" + СтрокаНайденнного.Metadata.FullName() + ")";

		NewRow = SearchResult.Add();
		NewRow.Ref = СтрокаНайденнного.Ref;
		NewRow.ObjectPresentation = FoundPresentation;
		NewRow.FoundObject = СтрокаНайденнного.Data;
		NewRow.Picture = MapOfPictures[БазовыйТипЧислом];
		NewRow.CanBeOpened = MapCanBeOpened[БазовыйТипЧислом];
		NewRow.ReferenceType = MapReferenceType[БазовыйТипЧислом];
		If NewRow.ReferenceType Then
			NewRow.UUID = NewRow.FoundObject.UUID();
		EndIf;

		If First Then

			Items.SearchResult.CurrentRow = NewRow.GetID();
			First = Ложь;

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

	ПоказатьЗначение( , CurrentData.FoundObject);

EndProcedure

&AtClient
Procedure ExecuteReferencesSearch()
	If NOT ValueIsFilled(Object.SourceObject) Then
		UT_CommonClientServer.MessageToUser("Не выбран объект, на который необходимо найти ссылки", ,
			"Object.SourceObject");
		Return;
	EndIf;

	Status("Выполняется поиск ссылок на объект", , , PictureLib.УправлениеПоиском);
	ExecuteReferencesSearchAtServer();
	Status("Поиск ссылок на объект завершен", , , PictureLib.УправлениеПоиском);

	ThisObject.CurrentItem = Items.SearchResult;

EndProcedure

&AtServerNoContext
Function FoundObjectPresentation(БазовыйТипЧислом, МетаданныеОбъекта, FoundObject)

	Presentation = TrimAll(FoundObject);
	If БазовыйТипЧислом = 2 OR БазовыйТипЧислом = 3 OR БазовыйТипЧислом = 8 OR БазовыйТипЧислом = 9
		OR БазовыйТипЧислом = 10 OR БазовыйТипЧислом = 11 OR БазовыйТипЧислом = 12 OR БазовыйТипЧислом = 14 Then

	ElsIf БазовыйТипЧислом = 4 OR БазовыйТипЧислом = 5 OR БазовыйТипЧислом = 6 OR БазовыйТипЧислом = 7 Then

		Presentation = "";
		If МетаданныеОбъекта.InformationRegisterPeriodicity
			<> Metadata.ObjectProperties.InformationRegisterPeriodicity.Nonperiodical Then

			Presentation = String(FoundObject.Период);

		EndIf;

		If МетаданныеОбъекта.WriteMode = Metadata.ObjectProperties.RegisterWriteMode.RecorderSubordinate Then

			Presentation = ?(StrLen(Presentation) = 0, "", Presentation + "; ") + String(
				FoundObject.Регистратор);

		EndIf;

		For Each Измерение In МетаданныеОбъекта.Измерения Do

			Presentation = ?(StrLen(Presentation) = 0, "", Presentation + "; ") + String(
				FoundObject[Измерение.Имя]);

		EndDo;

	ElsIf БазовыйТипЧислом = 13 Then

		Presentation = "";
		For Each Измерение In МетаданныеОбъекта.KeyFields Do

			Presentation = ?(StrLen(Presentation) = 0, "", Presentation + "; ") + String(
				FoundObject[Измерение.Имя]);

		EndDo;
	EndIf;

	Return Presentation;

EndFunction

&AtServerNoContext
Function ТипМетаданныхЧислом(ObjectMetadata)

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
		For Each ВнешнийИсточник In Metadata.ExternalDataSources Do

			If ВнешнийИсточник.Tables.Contains(ObjectMetadata) Then

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

//TODO Необходимо перенести эту функцию в общий модуль. Сейчас она просто скопирована из УИ_РедакторРеквизитовОбъекта.ФормаОбъекта
&AtServerNoContext
Function вНайтиОбъектПоURL(Знач URL)
	Pos1 = Find(URL, "e1cib/data/");
	Pos2 = Find(URL, "?ref=");

	If Pos1 = 0 Или Pos2 = 0 Then
		Return Undefined;
	EndIf;

	Try
		TypeName = Mid(URL, Pos1 + 11, Pos2 - Pos1 - 11);
		ШаблонЗначения = ValueToStringInternal(PredefinedValue(TypeName + ".EmptyRef"));
		ЗначениеСсылки = StrReplace(ШаблонЗначения, "00000000000000000000000000000000", Mid(URL, Pos2 + 5));
		Ref = ValueFromStringInternal(ЗначениеСсылки);
	Except
		Return Undefined;
	EndTry;

	Return Ref;
EndFunction

#EndRegion