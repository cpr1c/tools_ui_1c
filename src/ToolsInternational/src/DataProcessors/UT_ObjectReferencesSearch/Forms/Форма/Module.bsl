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
		ВыполнитьПоискСсылок();
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
			//TODO Убрать это кривое решение проблемы
		EndTry;
	EndIf;
EndProcedure

&AtClient
Procedure РезультатПоискаВыбор(Item, ВыбраннаяСтрока, Поле, StandardProcessing)
	StandardProcessing = False;
	ОткрытьОбъектТекущейСтроки();
EndProcedure

&AtClient
Procedure РезультатПоискаПриАктивизацииСтроки(Item)
	ТекДанные = Items.РезультатПоиска.CurrentData;
	If ТекДанные = Undefined Then
		ВидимостьКомандыОткрытия = False;
		ВидимостьКомандыПоиска = False;
	Else
		ВидимостьКомандыОткрытия = ТекДанные.МожноОткрыть;
		ВидимостьКомандыПоиска = ТекДанные.СсылочныйТип;
	EndIf;

	Items.ТаблицаКонтекстноеМенюОткрытьОбъект.Visible = ВидимостьКомандыОткрытия;
	Items.ТаблицаКонтекстноеМенюПоискДляОбъекта.Visible = ВидимостьКомандыПоиска;
EndProcedure

#EndRegion

#Region FormCommandHandlers

&AtClient
Procedure НайтиСсылки(Command)
	ВыполнитьПоискСсылок();
EndProcedure

&AtClient
Procedure ОткрытьОбъект(Command)
	ОткрытьОбъектТекущейСтроки();
EndProcedure

&AtClient
Procedure ПоискДляОбъекта(Command)
	ТекДанные = Items.РезультатПоиска.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;
	If NOT ТекДанные.СсылочныйТип Then
		Return;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("SearchObject", ТекДанные.НайденныйОбъект);

	OpenForm("Обработка.UT_ObjectReferencesSearch.Форма", FormParameters, , New UUID);
EndProcedure

&AtClient
Procedure РедактироватьОбъект(Command)
	ТекДанные = Items.РезультатПоиска.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.РедактироватьОбъект(ТекДанные.НайденныйОбъект);
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
	ОбработчикЗавершения = New NotifyDescription("ВводНавигационнойСсылкиЗавершение", ThisObject);
	ПоказатьВводСтроки(ОбработчикЗавершения, , "Нав. ссылка на объект (e1cib/data/...)");
EndProcedure

&AtClient
Procedure ВводНавигационнойСсылкиЗавершение(РезультатВвода, ДопПараметры) Экспорт
	If РезультатВвода = Неопределено Then
		Return;
	EndIf;	
	
	НайденныйОбъект = вНайтиОбъектПоURL(РезультатВвода);
	If Объект.ИсходныйОбъект <> НайденныйОбъект Then
		Объект.ИсходныйОбъект = НайденныйОбъект;
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
Procedure ВыполнитьПоискСсылокНаСервере()
	If NOT ValueIsFilled(Объект.ИсходныйОбъект) Then
		UT_CommonClientServer.MessageToUser("Не выбран объект, на который необходимо найти ссылки", ,
			"Объект.ИсходныйОбъект");
		Return;
	EndIf;

	СоответствиеМожноЛиОткрывать = New Map;
	СоответствиеМожноЛиОткрывать.Insert(0, False); // 0
	СоответствиеМожноЛиОткрывать.Insert(1, True); // 1 Константа
	СоответствиеМожноЛиОткрывать.Insert(2, True); // 2 Справочник
	СоответствиеМожноЛиОткрывать.Insert(3, True); // 3 Документ
	СоответствиеМожноЛиОткрывать.Insert(4, False); // 4 Регистр накопления
	СоответствиеМожноЛиОткрывать.Insert(5, False); // 5 Регистр бухгалтерии
	СоответствиеМожноЛиОткрывать.Insert(6, False); // 6 Регистр расчета
	СоответствиеМожноЛиОткрывать.Insert(7, True); // 7 Регистр сведений
	СоответствиеМожноЛиОткрывать.Insert(8, True); // 8 Бизнес процесс
	СоответствиеМожноЛиОткрывать.Insert(9, True); // 9 Задача
	СоответствиеМожноЛиОткрывать.Insert(11, True); // 11 План видов расчета
	СоответствиеМожноЛиОткрывать.Insert(12, True); // 12 План счетов
	СоответствиеМожноЛиОткрывать.Insert(13, True); // 13 Внешний источник данных набор
	СоответствиеМожноЛиОткрывать.Insert(14, True); // 14 Внешний источник данных ссылка
	СоответствиеСсылочныйТип = New Map;
	СоответствиеСсылочныйТип.Insert(0, False); // 0
	СоответствиеСсылочныйТип.Insert(1, False); // 1 Константа
	СоответствиеСсылочныйТип.Insert(2, True); // 2 Справочник
	СоответствиеСсылочныйТип.Insert(3, True); // 3 Документ
	СоответствиеСсылочныйТип.Insert(4, False); // 4 Регистр накопления
	СоответствиеСсылочныйТип.Insert(5, False); // 5 Регистр бухгалтерии
	СоответствиеСсылочныйТип.Insert(6, False); // 6 Регистр расчета
	СоответствиеСсылочныйТип.Insert(7, False); // 7 Регистр сведений
	СоответствиеСсылочныйТип.Insert(8, True); // 8 Бизнес процесс
	СоответствиеСсылочныйТип.Insert(9, True); // 9 Задача
	СоответствиеСсылочныйТип.Insert(10, True); // 10 План видов характеристик
	СоответствиеСсылочныйТип.Insert(11, True); // 11 План видов расчета
	СоответствиеСсылочныйТип.Insert(12, True); // 12 План счетов
	СоответствиеСсылочныйТип.Insert(13, False); // 13 Внешний источник данных набор
	СоответствиеСсылочныйТип.Insert(14, True); // 14 Внешний источник данных ссылка
	СоответствиеКартинок = New Map;
	СоответствиеКартинок.Insert(0, New Картинка); // 0
	СоответствиеКартинок.Insert(1, БиблиотекаКартинок.Константа); // 1 Константа
	СоответствиеКартинок.Insert(2, БиблиотекаКартинок.Справочник); // 2 Справочник
	СоответствиеКартинок.Insert(3, БиблиотекаКартинок.Документ); // 3 Документ
	СоответствиеКартинок.Insert(4, БиблиотекаКартинок.РегистрНакопления); // 4 Регистр накопления
	СоответствиеКартинок.Insert(5, БиблиотекаКартинок.РегистрБухгалтерии); // 5 Регистр бухгалтерии
	СоответствиеКартинок.Insert(6, БиблиотекаКартинок.РегистрРасчета); // 6 Регистр расчета
	СоответствиеКартинок.Insert(7, БиблиотекаКартинок.РегистрСведений); // 7 Регистр сведений
	СоответствиеКартинок.Insert(8, БиблиотекаКартинок.БизнесПроцесс); // 8 Бизнес процесс
	СоответствиеКартинок.Insert(9, БиблиотекаКартинок.Задача); // 9 Задача
	СоответствиеКартинок.Insert(10, БиблиотекаКартинок.ПланВидовХарактеристик); // 10 План видов характеристик
	СоответствиеКартинок.Insert(11, БиблиотекаКартинок.ПланВидовРасчета); // 11 План видов расчета
	СоответствиеКартинок.Insert(12, БиблиотекаКартинок.ПланСчетов); // 12 План счетов
	СоответствиеКартинок.Insert(13, БиблиотекаКартинок.ВнешнийИсточникДанныхТаблица); // 13 Внешний источник данных набор
	СоответствиеКартинок.Insert(14, БиблиотекаКартинок.ВнешнийИсточникДанныхТаблица); // 14 Внешний источник данных ссылка
	МассивПоиска = New Array;
	МассивПоиска.Добавить(Объект.ИсходныйОбъект);

	ТаблицаСсылок = НайтиПоСсылкам(МассивПоиска);

	РезультатПоиска.Очистить();
	Объект.КоличествоНайденных = ТаблицаСсылок.Count();

	Первый = Истина;
	For Each СтрокаНайденнного In ТаблицаСсылок Do
	// 0 - find object
	// 1 - found object
	// 2 - metadata object
		БазовыйТипЧислом = ТипМетаданныхЧислом(СтрокаНайденнного.Metadata);

		ПредставлениеНайденного = ПредставлениеНайденногоОбъекта(БазовыйТипЧислом, СтрокаНайденнного.Metadata,
			СтрокаНайденнного.Data) + " (" + СтрокаНайденнного.Metadata.ПолноеИмя() + ")";

		НоваяСтрока = РезультатПоиска.Добавить();
		НоваяСтрока.Ссылка = СтрокаНайденнного.Ref;
		НоваяСтрока.ПредставлениеОбъекта = ПредставлениеНайденного;
		НоваяСтрока.НайденныйОбъект = СтрокаНайденнного.Data;
		НоваяСтрока.Картинка = СоответствиеКартинок[БазовыйТипЧислом];
		НоваяСтрока.МожноОткрыть = СоответствиеМожноЛиОткрывать[БазовыйТипЧислом];
		НоваяСтрока.СсылочныйТип = СоответствиеСсылочныйТип[БазовыйТипЧислом];
		If НоваяСтрока.СсылочныйТип Then
			НоваяСтрока.УникальныйИдентификатор = НоваяСтрока.НайденныйОбъект.UUID();
		EndIf;

		If Первый Then

			Items.РезультатПоиска.ТекущаяСтрока = НоваяСтрока.GetID();
			Первый = Ложь;

		EndIf;

	EndDo;

EndProcedure

&AtClient
Procedure ОткрытьОбъектТекущейСтроки()
	ТекДанные = Items.РезультатПоиска.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;
	If NOT ТекДанные.МожноОткрыть Then
		Return;
	EndIf;

	ПоказатьЗначение( , ТекДанные.НайденныйОбъект);

EndProcedure

&AtClient
Procedure ВыполнитьПоискСсылок()
	If NOT ValueIsFilled(Объект.ИсходныйОбъект) Then
		UT_CommonClientServer.MessageToUser("Не выбран объект, на который необходимо найти ссылки", ,
			"Объект.ИсходныйОбъект");
		Return;
	EndIf;

	Состояние("Выполняется поиск ссылок на объект", , , БиблиотекаКартинок.УправлениеПоиском);
	ВыполнитьПоискСсылокНаСервере();
	Состояние("Поиск ссылок на объект завершен", , , БиблиотекаКартинок.УправлениеПоиском);

	ThisObject.CurrentItem = Items.РезультатПоиска;

EndProcedure

&AtServerNoContext
Function ПредставлениеНайденногоОбъекта(БазовыйТипЧислом, МетаданныеОбъекта, НайденныйОбъект)

	Представление = TrimAll(НайденныйОбъект);
	If БазовыйТипЧислом = 2 OR БазовыйТипЧислом = 3 OR БазовыйТипЧислом = 8 OR БазовыйТипЧислом = 9
		OR БазовыйТипЧислом = 10 OR БазовыйТипЧислом = 11 OR БазовыйТипЧислом = 12 OR БазовыйТипЧислом = 14 Then

	ElsIf БазовыйТипЧислом = 4 OR БазовыйТипЧислом = 5 OR БазовыйТипЧислом = 6 OR БазовыйТипЧислом = 7 Then

		Представление = "";
		If МетаданныеОбъекта.InformationRegisterPeriodicity
			<> Метаданные.СвойстваОбъектов.ПериодичностьРегистраСведений.Непериодический Then

			Представление = Строка(НайденныйОбъект.Период);

		EndIf;

		If МетаданныеОбъекта.WriteMode = Метаданные.СвойстваОбъектов.РежимЗаписиРегистра.ПодчинениеРегистратору Then

			Представление = ?(СтрДлина(Представление) = 0, "", Представление + "; ") + Строка(
				НайденныйОбъект.Регистратор);

		EndIf;

		For Each Измерение In МетаданныеОбъекта.Измерения Do

			Представление = ?(СтрДлина(Представление) = 0, "", Представление + "; ") + Строка(
				НайденныйОбъект[Измерение.Имя]);

		EndDo;

	ElsIf БазовыйТипЧислом = 13 Then

		Представление = "";
		For Each Измерение In МетаданныеОбъекта.KeyFields Do

			Представление = ?(СтрДлина(Представление) = 0, "", Представление + "; ") + Строка(
				НайденныйОбъект[Измерение.Имя]);

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
				Прервать;
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
		ИмяТипа = Mid(URL, Pos1 + 11, Pos2 - Pos1 - 11);
		ШаблонЗначения = ValueToStringInternal(PredefinedValue(ИмяТипа + ".EmptyRef"));
		ЗначениеСсылки = StrReplace(ШаблонЗначения, "00000000000000000000000000000000", Mid(URL, Pos2 + 5));
		Ссылка = ValueFromStringInternal(ЗначениеСсылки);
	Except
		Return Undefined;
	EndTry;

	Return Ссылка;
EndFunction

#EndRegion