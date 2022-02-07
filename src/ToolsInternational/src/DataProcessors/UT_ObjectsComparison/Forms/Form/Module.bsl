&AtServerNoContext
Procedure AddToTree(VT, ObjectRef)
	MD = ObjectRef.Metadata();
	UUID = ObjectRef.UUID();
	GUUID = "id_" + StrReplace(UUID, "-", "_");
	
	VT.Rows.Add(GUUID, New TypeDescription());

	//Attributes
	Rows = VT.Rows;
	Row = Rows.Find(" Attributes", "Attributes");
	If Row = Undefined Then
		Row = Rows.Add();
		Row.Attribute = " Attributes";
	EndIf;
	Row[GUUID] = ObjectRef;

	Rows = Row.Rows;
	Attributes = MD.Attributes;
	For Each Attribute in Attributes Do
		AttributeName = Attribute.Name; 
		
		Row = Rows.Find(AttributeName, "Attribute");
		If Row = Undefined Then
			Row = Rows.Add();
			Row.Attribute = AttributeName;
		EndIf;
		Row[GUUID] = ObjectRef[AttributeName]; 
	EndDo;
		

	//Tabulars section
	For Each TS In MD.TabularsSection Do
		IF ObjectRef[TS.Name].Count() = 0 Then Continue; Endif;
		AttributeName = TS.Name; 
		
		Rows = TS.Rows;
		Row = Rows.Find(AttributeName, "Attribute");
		If Row = Undefined Then
			Row = Rows.Add();
			Row.Attribute = AttributeName;
		EndIf;

		//Rows tabular section
		RowsSet = Row.Rows;
		For Each RowTS In ObjectRef[TS.Name] Do
			NumberRow = "Row № " + Format(RowTS.NumberRow, "ND=4; NLZ=; NG=");
			RowSet = RowsSet.Find(NumberRow, "Attribute");
			If RowSet = Undefined Then 
				RowSet = RowsSet.Add();
				RowSet.Attribute = NumberRow;
			EndIf;
			
			//Values of the rows tabular section
			RowsRS = RowSet.Rows;
			For Each Attribute In MD.ТабличныеЧасти[MD.Имя].Attribute Do
				AttributeName = Attribute.Name; 

				RowRS = RowsRS.Find(AttributeName, "Attribute");
				If RowRS = Undefined Then
					RowRS = RowsRS.Add();
					RowRS.Name = AttributeName;
				EndIf;
				Value = RowRS[AttributeName];
				RowRS[GUUID] = ?(ValueIsFilled(Value), Value, Undefined);
			EndDo;

		EndDo;
	EndDo;
	
	Rows = VT.Rows;
	Rows.Sort("Attribute", True);
EndProcedure

&AtServerNoContext
Procedure ClearTree(ДЗ, Строки = Неопределено) 
	
	Колонки = New Array;
	Для Каждого Колонка Из ДЗ.Колонки Цикл
		Если Колонка.Имя = "Реквизит" Тогда Продолжить; КонецЕсли;
		Колонки.Добавить(Колонка.Имя);
	КонецЦикла;
	Колонок = Колонки.Количество() - 1;
	Если Колонок = 0 Тогда Возврат КонецЕсли;

	Если Строки = Неопределено Тогда
		Строки = ДЗ.Строки;
	КонецЕсли;

	УдаляемыеСтроки = Новый Массив;
	Для Каждого Строка Из Строки Цикл
		ЕстьПодчиненные = Строка.Строки.Количество() > 0;
		
		Если ЕстьПодчиненные Тогда
			ClearTree(ДЗ, Строка.Строки);
		Иначе Сч = 0;
			Для Кол = 1 По Колонок Цикл
				Сч = Сч + ?(Строка[Колонки[0]] = Строка[Колонки[Кол]], 1, 0);
			КонецЦикла;
			Если Сч = Колонок Тогда УдаляемыеСтроки.Добавить(Строка); КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого Строка Из УдаляемыеСтроки Цикл
		Строки.Удалить(Строка);
	КонецЦикла;

EndProcedure

&AtServer
Procedure СформироватьПечатнуюФормуСравненияОбъектов() Экспорт

	ДЗ = Новый ДеревоЗначений;
	ДЗ.Колонки.Добавить("Реквизит", Новый ОписаниеТипов());

	Для Каждого ОбъектЭлемент Из Objects Цикл
		СсылкаНаОбъект = ОбъектЭлемент.Значение;
		ДобавитьВДерево(ДЗ, СсылкаНаОбъект);
	КонецЦикла;

	ClearTree(ДЗ);

	SpreadsheetDocument = Новый ТабличныйДокумент;
	SpreadsheetDocument.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_Обработка_СравнениеОбъектов";
	Макет = Обработки.UT_ObjectsComparison.ПолучитьМакет("PF_MXL_ComparisonObjects");
	
	SpreadsheetDocument.НачатьАвтогруппировкуСтрок();
	Уровень = 1;
	Для Каждого Строка Из ДЗ.Строки Цикл
		ВывестиСтроку(Строка, ДЗ.Колонки, SpreadsheetDocument, Макет, Уровень);
	КонецЦикла;
	SpreadsheetDocument.ЗакончитьАвтогруппировкуСтрок();
	
	ОбластьШапка = SpreadsheetDocument.Область(1,,1);
	SpreadsheetDocument.ПовторятьПриПечатиСтроки = ОбластьШапка;
	SpreadsheetDocument.ТолькоПросмотр = Истина;
	SpreadsheetDocument.АвтоМасштаб = Истина;
	SpreadsheetDocument.ФиксацияСверху = 1;
	SpreadsheetDocument.ФиксацияСлева = 1;
	
EndProcedure

&AtServerNoContext
Procedure ВывестиСтроку(Строка, Колонки, ТабличныйДокумент, Макет, Уровень)
	ЕстьВложенныеСтроки = Строка.Строки.Количество() > 0;
	
	ОбластьРеквизит = Макет.ПолучитьОбласть("Реквизит");
	ОбластьРеквизит.Параметры.Реквизит = СокрЛП(Строка.Реквизит);
	Если ЕстьВложенныеСтроки Тогда ОформитьОбласть(ОбластьРеквизит); КонецЕсли;
	ТабличныйДокумент.Вывести(ОбластьРеквизит, Уровень);
	
	ОбластьКолонка = Макет.ПолучитьОбласть("Значение");
	Для Каждого Колонка Из Колонки Цикл
		Если Колонка.Имя = "Реквизит" Тогда Продолжить; КонецЕсли;
		Значение = Строка[Колонка.Имя];
		ОбластьКолонка.Параметры.Значение = Значение;
		Если ЕстьВложенныеСтроки Тогда ОформитьОбласть(ОбластьКолонка); КонецЕсли;
		ТабличныйДокумент.Присоединить(ОбластьКолонка, Уровень);
	КонецЦикла;
	

	Если ЕстьВложенныеСтроки Тогда
		Для Каждого ПодСтрока Из Строка.Строки Цикл
			ВывестиСтроку(ПодСтрока, Колонки, ТабличныйДокумент, Макет, Уровень + 1);
		КонецЦикла;
	КонецЕсли;
EndProcedure

&AtServerNoContext
Procedure ОформитьОбласть(Область)
	Шрифт = Область.ТекущаяОбласть.Шрифт;
	Область.ТекущаяОбласть.Шрифт = Новый Шрифт(Шрифт,,,Истина);
	Область.ТекущаяОбласть.ЦветФона = ЦветаСтиля.ЦветФонаШапкиОтчета;
EndProcedure


&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	//TODO: Insert the handler content
EndProcedure

&AtServer
Procedure СформироватьAtServer()
	СформироватьПечатнуюФормуСравненияОбъектов();
EndProcedure

&НаКлиенте
Procedure Generate(Команда)
	Если Objects.Количество() = 0 Тогда
		Элементы.FormParameters.Пометка = Истина;
		Элементы.GroupParameters.Видимость = Истина;
		ТекущийЭлемент = Элементы.Objects;
		Возврат;
	КонецЕсли;
	СформироватьAtServer();
EndProcedure

&НаКлиенте
Procedure Parameters(Команда)
	Пометка = Не Элементы.FormParameters.Пометка;
	Элементы.FormParameters.Пометка = Пометка;
	Элементы.GroupParameters.Видимость = Пометка;
EndProcedure

&AtServer
Procedure ПриСозданииAtServer(Отказ, СтандартнаяОбработка)
	Objects.Очистить();
	Если Параметры.Свойство("СравниваемыеОбъекты") Тогда
		Objects.ЗагрузитьЗначения(Параметры.СравниваемыеОбъекты);
	КонецЕсли;
	СформироватьAtServer();
	
	//UT_Common.ФормаИнструментаПриСозданииAtServer(ЭтотОбъект, Отказ, СтандартнаяОбработка);
	
EndProcedure


&AtServer
Procedure ДобавитьРанееДобавленныеКСравнениюAtServer()
	МассивОбъектовКСравнению=UT_Common.ObjectsAddedToTheComparison();
	
	Для Каждого ТекОбъект ИЗ МассивОбъектовКСравнению Цикл
		Если Objects.НайтиПоЗначению(ТекОбъект)<>Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Objects.Добавить(ТекОбъект);
	КонецЦикла;
EndProcedure


&НаКлиенте
Procedure AddObjectsAddedToComparisonEarly(Команда)
	ДобавитьРанееДобавленныеКСравнениюAtServer();
EndProcedure


&AtServer
Procedure ОчиститьРанееДобавленныеКСравнениюAtServer()
	UT_Common.ClearObjectsAddedToTheComparison();
EndProcedure


&НаКлиенте
Procedure ОчиститьРанееДобавленныеКСравнению(Команда)
	ОчиститьРанееДобавленныеКСравнениюAtServer();
EndProcedure

//@skip-warning
&НаКлиенте
Procedure Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Команда) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ЭтотОбъект, Команда);
EndProcedure
