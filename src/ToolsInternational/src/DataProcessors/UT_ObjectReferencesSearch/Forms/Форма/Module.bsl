#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("SearchObject") Then
		Объект.ИсходныйОбъект = Parameters.SearchObject;
	EndIf;
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	If ValueIsFilled(Объект.ИсходныйОбъект) Then
		ИсходныйОбъектПриИзменении(Undefined);
		ExecuteReferencesSearch();
	EndIf;
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure ИсходныйОбъектПриИзменении(Item)
	If NOT ValueIsFilled(Объект.ИсходныйОбъект) Then
		УникальныйИдентификаторИсточника="";
	Else
		Try
			УникальныйИдентификаторИсточника = Объект.ИсходныйОбъект.UUID();
		Except
			//TODO Amend the implementation code
		EndTry;
	EndIf;
EndProcedure

&AtClient
Procedure РезультатПоискаВыбор(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;
	ОткрытьОбъектТекущейСтроки();
EndProcedure

&AtClient
Procedure РезультатПоискаПриАктивизацииСтроки(Item)
	CurrentData = Items.РезультатПоиска.CurrentData;
	If CurrentData = Undefined Then
		OpenCommandVisibility = False;
		SearchCommandVisibility = False;
	Else
		OpenCommandVisibility = CurrentData.МожноОткрыть;
		SearchCommandVisibility = CurrentData.СсылочныйТип;
	EndIf;

	Items.ТаблицаКонтекстноеМенюОткрытьОбъект.Visible = OpenCommandVisibility;
	Items.ТаблицаКонтекстноеМенюПоискДляОбъекта.Visible = SearchCommandVisibility;
EndProcedure

#EndRegion

#Region FormCommandHandlers

&AtClient
Procedure НайтиСсылки(Command)
	ExecuteReferencesSearch();
EndProcedure

&AtClient
Procedure ОткрытьОбъект(Command)
	ОткрытьОбъектТекущейСтроки();
EndProcedure

&AtClient
Procedure ПоискДляОбъекта(Command)
	CurrentData = Items.РезультатПоиска.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	If NOT CurrentData.СсылочныйТип Then
		Return;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("SearchObject", CurrentData.НайденныйОбъект);

	OpenForm("Обработка.UT_ObjectReferencesSearch.Форма", FormParameters, , New UUID);
EndProcedure

&AtClient
Procedure РедактироватьОбъект(Command)
	CurrentData = Items.РезультатПоиска.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.РедактироватьОбъект(CurrentData.НайденныйОбъект);
EndProcedure

&AtClient
Procedure РедактироватьИсходныйОбъект(Command)
	If NOT ValueIsFilled(Объект.ИсходныйОбъект) Then
		Return;
	EndIf;

	UT_CommonClient.РедактироватьОбъект(Объект.ИсходныйОбъект);
EndProcedure

&AtClient
Procedure ИсходныйОбъектПоСсылке(Command)
	CompletionHandler = New NotifyDescription("ВводНавигационнойСсылкиЗавершение", ThisObject);
	ShowInputString(CompletionHandler, , "Нав. ссылка на объект (e1cib/data/...)");
EndProcedure

&AtClient
Procedure ВводНавигационнойСсылкиЗавершение(InputResult, AdditionalParameters) Export
	If InputResult = Неопределено Then
		Return;
	EndIf;	
	
	FoundObject = вНайтиОбъектПоURL(InputResult);
	If Объект.ИсходныйОбъект <> FoundObject Then
		Объект.ИсходныйОбъект = FoundObject;
		ИсходныйОбъектПриИзменении(Undefined);
	EndIf;
	
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Command) 
	UT_CommonClient.Подключаемый_ВыполнитьОбщуюКомандуИнструментов(ThisObject, Command);
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure ExecuteReferencesSearchAtServer()
	If NOT ValueIsFilled(Объект.ИсходныйОбъект) Then
		UT_CommonClientServer.MessageToUser("Не выбран объект, на который необходимо найти ссылки", ,
			"Объект.ИсходныйОбъект");
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
	MapOfPictures.Insert(0, New Картинка); // 0
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
	ArrayOfSearch.Add(Объект.ИсходныйОбъект);

	ReferencesTable = FindByRef(ArrayOfSearch);

	РезультатПоиска.Clear();
	Объект.КоличествоНайденных = ReferencesTable.Count();

	First = Истина;
	For Each СтрокаНайденнного In ReferencesTable Do
	// 0 - find object
	// 1 - found object
	// 2 - metadata object
		БазовыйТипЧислом = ТипМетаданныхЧислом(СтрокаНайденнного.Metadata);

		ПредставлениеНайденного = ПредставлениеНайденногоОбъекта(БазовыйТипЧислом, СтрокаНайденнного.Metadata,
			СтрокаНайденнного.Data) + " (" + СтрокаНайденнного.Metadata.FullName() + ")";

		NewRow = РезультатПоиска.Add();
		NewRow.Ссылка = СтрокаНайденнного.Ref;
		NewRow.ПредставлениеОбъекта = ПредставлениеНайденного;
		NewRow.НайденныйОбъект = СтрокаНайденнного.Data;
		NewRow.Картинка = MapOfPictures[БазовыйТипЧислом];
		NewRow.МожноОткрыть = MapCanBeOpened[БазовыйТипЧислом];
		NewRow.СсылочныйТип = MapReferenceType[БазовыйТипЧислом];
		If NewRow.СсылочныйТип Then
			NewRow.УникальныйИдентификатор = NewRow.НайденныйОбъект.UUID();
		EndIf;

		If First Then

			Items.РезультатПоиска.CurrentRow = NewRow.GetID();
			First = Ложь;

		EndIf;

	EndDo;

EndProcedure

&AtClient
Procedure ОткрытьОбъектТекущейСтроки()
	CurrentData = Items.РезультатПоиска.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	If NOT CurrentData.МожноОткрыть Then
		Return;
	EndIf;

	ПоказатьЗначение( , CurrentData.НайденныйОбъект);

EndProcedure

&AtClient
Procedure ExecuteReferencesSearch()
	If NOT ValueIsFilled(Объект.ИсходныйОбъект) Then
		UT_CommonClientServer.MessageToUser("Не выбран объект, на который необходимо найти ссылки", ,
			"Объект.ИсходныйОбъект");
		Return;
	EndIf;

	Status("Выполняется поиск ссылок на объект", , , PictureLib.УправлениеПоиском);
	ExecuteReferencesSearchAtServer();
	Status("Поиск ссылок на объект завершен", , , PictureLib.УправлениеПоиском);

	ThisObject.CurrentItem = Items.РезультатПоиска;

EndProcedure

&AtServerNoContext
Function ПредставлениеНайденногоОбъекта(БазовыйТипЧислом, МетаданныеОбъекта, FoundObject)

	Представление = TrimAll(FoundObject);
	If БазовыйТипЧислом = 2 OR БазовыйТипЧислом = 3 OR БазовыйТипЧислом = 8 OR БазовыйТипЧислом = 9
		OR БазовыйТипЧислом = 10 OR БазовыйТипЧислом = 11 OR БазовыйТипЧислом = 12 OR БазовыйТипЧислом = 14 Then

	ElsIf БазовыйТипЧислом = 4 OR БазовыйТипЧислом = 5 OR БазовыйТипЧислом = 6 OR БазовыйТипЧислом = 7 Then

		Представление = "";
		If МетаданныеОбъекта.InformationRegisterPeriodicity
			<> Metadata.ObjectProperties.InformationRegisterPeriodicity.Nonperiodical Then

			Представление = String(FoundObject.Период);

		EndIf;

		If МетаданныеОбъекта.WriteMode = Metadata.ObjectProperties.RegisterWriteMode.RecorderSubordinate Then

			Представление = ?(StrLen(Представление) = 0, "", Представление + "; ") + String(
				FoundObject.Регистратор);

		EndIf;

		For Each Измерение In МетаданныеОбъекта.Измерения Do

			Представление = ?(StrLen(Представление) = 0, "", Представление + "; ") + String(
				FoundObject[Измерение.Имя]);

		EndDo;

	ElsIf БазовыйТипЧислом = 13 Then

		Представление = "";
		For Each Измерение In МетаданныеОбъекта.KeyFields Do

			Представление = ?(StrLen(Представление) = 0, "", Представление + "; ") + String(
				FoundObject[Измерение.Имя]);

		EndDo;
	EndIf;

	Return Представление;

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
		Ссылка = ValueFromStringInternal(ЗначениеСсылки);
	Except
		Return Undefined;
	EndTry;

	Return Ссылка;
EndFunction

#EndRegion