&AtClient
Var mValueStorageType;

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ValueStorageData = Parameters.ValueStorageData;

	If TypeOf(ValueStorageData) = Type("String") Then
		If IsTempStorageURL(ValueStorageData) Then
			ValueStorageData = GetFromTempStorage(ValueStorageData);
		Else
			Try
				ValueStorageData=UT_CommonServerCall.ValueFromXMLString(ValueStorageData);
			Except
			EndTry;
		EndIf;
	EndIf;

	If TypeOf(ValueStorageData) = Type("ТабличныйДокумент") Then
		_DataForRepresentation = New Structure("Значение, ТипЗначения", ValueStorageData, "ТабличныйДокумент");
		Return;
	 ElsIf TypeOf(ValueStorageData) = Type("ТекстовыйДокумент") Then
		_DataForRepresentation = New Structure("Значение, ТипЗначения", ValueStorageData, "ТекстовыйДокумент");
		Return;
	 ElsIf TypeOf(ValueStorageData) <> Type("ХранилищеЗначения") Then
		Cancel = True;
		Return;
	EndIf;

	ValueStorageData = ValueStorageData.Получить();
	If ValueStorageData = Undefined Then
		Cancel = True;
		Return;
	EndIf;

	ТипДанныхХЗ = TypeOf(ValueStorageData);

	If ТипДанныхХЗ = Type("Массив") Then
		Заголовок = "Массив";
		Cancel = Not вПоказатьМассив(ValueStorageData);
	 ElsIf ТипДанныхХЗ = Type("Структура") Then
		Заголовок = "Структура";
		Cancel = Not вПоказатьСтруктуру(ValueStorageData);
	 ElsIf ТипДанныхХЗ = Type("Соответствие") Then
		Заголовок = "Соответствие";
		Cancel = Not вПоказатьСоответствие(ValueStorageData);
	 ElsIf ТипДанныхХЗ = Type("СписокЗначений") Then
		Заголовок = "СписокЗначений";
		Cancel = Not вПоказатьСписокЗначений(ValueStorageData);
	 ElsIf ТипДанныхХЗ = Type("ТаблицаЗначений") Then
		Заголовок = "ТаблицаЗначений";
		Cancel = Not вПоказатьТаблицуЗначений(ValueStorageData);
	 ElsIf ТипДанныхХЗ = Type("ДеревоЗначений") Then
		Заголовок = "ДеревоЗначений";
		Items._ValueTable.Видимость = False;
		Items._ValueTree.Видимость = True;
		Cancel = Not вПоказатьДеревоЗначений(ValueStorageData);
	 ElsIf ТипДанныхХЗ = Type("ТабличныйДокумент") Then
		_DataForRepresentation = New Structure("Значение, ТипЗначения", ValueStorageData, "ТабличныйДокумент");
	 ElsIf ТипДанныхХЗ = Type("ТекстовыйДокумент") Then
		_DataForRepresentation = New Structure("Значение, ТипЗначения", ValueStorageData, "ТекстовыйДокумент");
	Иначе
		Cancel = True;
	EndIf;
EndProcedure


&AtClient
Procedure OnOpen(Cancel)
	mValueStorageType = Type("ХранилищеЗначения");

	If _DataForRepresentation <> Undefined Then
		If _DataForRepresentation.ТипЗначения = "ТабличныйДокумент" Then
			_DataForRepresentation.Значение.Показать(_DataForRepresentation.ТипЗначения);
		 ElsIf _DataForRepresentation.ТипЗначения = "ТекстовыйДокумент" Then
			_DataForRepresentation.Значение.Показать(_DataForRepresentation.ТипЗначения);
		EndIf;

		Cancel = True;
	EndIf;
	
EndProcedure

&AtServer
Function вПоказатьМассив(ValueStorageData)
	If ValueStorageData.Количество() = 0 Then
		Return False;
	EndIf;

	РеквизитыКДобавлению = New Array;
	РеквизитыКУдалению = New Array;

	РеквизитыКДобавлению.Add(New РеквизитФормы("Индекс", New TypeDescription("Число"), "_ValueTable",
		"Индекс", False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("Значение", New TypeDescription, "_ValueTable", "Значение",
		False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("ТипЗначения", New TypeDescription("Строка"), "_ValueTable",
		"ТипЗначения", False));

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	For Инд = 0 По ValueStorageData.ВГраница() Do
		Значение = ValueStorageData[Инд];
		НС = _ValueTable.Add();

		НС.Индекс = Инд;
		НС.ТипЗначения = Строка(TypeOf(Значение));

		If вНадоПреобразоватьЗначение(Значение) Then
			НС.Значение = New ХранилищеЗначения(Значение);
		Иначе
			НС.Значение = Значение;
		EndIf;
	EndDo;

	For Each Элем In РеквизитыКДобавлению Do
		ИмяЭФ = "_ТаблицаЗначений_" + Элем.Имя;
		ЭтаФорма.Items.Add(ИмяЭФ, Type("ПолеФормы"), ЭтаФорма.Items._ТаблицаЗначений);
		ЭтаФорма.Элементы[ИмяЭФ].ПутьКДанным = "_ValueTable." + Элем.Имя;
		ЭтаФорма.Элементы[ИмяЭФ].Вид = ВидПоляФормы.ПолеВвода;
	EndDo;

	Return True;
EndFunction

&AtServer
Function вПоказатьСтруктуру(ValueStorageData)
	If ValueStorageData.Количество() = 0 Then
		Return False;
	EndIf;

	РеквизитыКДобавлению = New Array;
	РеквизитыКУдалению = New Array;

	РеквизитыКДобавлению.Add(New РеквизитФормы("Ключ", New TypeDescription("Строка"), "_ValueTable",
		"Ключ", False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("Значение", New TypeDescription, "_ValueTable", "Значение",
		False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("ТипЗначения", New TypeDescription("Строка"), "_ValueTable",
		"ТипЗначения", False));

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	For Each Элем In ValueStorageData Do
		НС = _ValueTable.Add();

		FillPropertyValues(НС, Элем, , "Значение");
		НС.ТипЗначения = Строка(TypeOf(Элем.Значение));

		If вНадоПреобразоватьЗначение(Элем.Значение) Then
			НС.Значение = New ХранилищеЗначения(Элем.Значение);
		Иначе
			НС.Значение = Элем.Значение;
		EndIf;
	EndDo;

	For Each Элем In РеквизитыКДобавлению Do
		ИмяЭФ = "_ТаблицаЗначений_" + Элем.Имя;
		ЭтаФорма.Items.Add(ИмяЭФ, Type("ПолеФормы"), ЭтаФорма.Items._ТаблицаЗначений);
		ЭтаФорма.Элементы[ИмяЭФ].ПутьКДанным = "_ValueTable." + Элем.Имя;
		ЭтаФорма.Элементы[ИмяЭФ].Вид = ВидПоляФормы.ПолеВвода;
	EndDo;

	Return True;
EndFunction

&AtServer
Function вПоказатьСоответствие(ValueStorageData)
	If ValueStorageData.Количество() = 0 Then
		Return False;
	EndIf;

	РеквизитыКДобавлению = New Array;
	РеквизитыКУдалению = New Array;

	РеквизитыКДобавлению.Add(New РеквизитФормы("Ключ", New TypeDescription, "_ValueTable", "Ключ", False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("Значение", New TypeDescription, "_ValueTable", "Значение",
		False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("ТипЗначения", New TypeDescription("Строка"), "_ValueTable",
		"ТипЗначения", False));

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	For Each Элем In ValueStorageData Do
		НС = _ValueTable.Add();

		FillPropertyValues(НС, Элем, , "Значение");
		НС.ТипЗначения = Строка(TypeOf(Элем.Значение));

		If вНадоПреобразоватьЗначение(Элем.Значение) Then
			НС.Значение = New ХранилищеЗначения(Элем.Значение);
		Иначе
			НС.Значение = Элем.Значение;
		EndIf;
	EndDo;

	For Each Элем In РеквизитыКДобавлению Do
		ИмяЭФ = "_ТаблицаЗначений_" + Элем.Имя;
		ЭтаФорма.Items.Add(ИмяЭФ, Type("ПолеФормы"), ЭтаФорма.Items._ТаблицаЗначений);
		ЭтаФорма.Элементы[ИмяЭФ].ПутьКДанным = "_ValueTable." + Элем.Имя;
		ЭтаФорма.Элементы[ИмяЭФ].Вид = ВидПоляФормы.ПолеВвода;
	EndDo;

	Return True;
EndFunction

&AtServer
Function вПоказатьСписокЗначений(ValueStorageData)
	If ValueStorageData.Количество() = 0 Then
		Return False;
	EndIf;

	РеквизитыКДобавлению = New Array;
	РеквизитыКУдалению = New Array;

	РеквизитыКДобавлению.Add(New РеквизитФормы("Пометка", New TypeDescription("Булево"), "_ValueTable",
		"Пометка", False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("Представление", New TypeDescription("Строка"),
		"_ValueTable", "Представление", False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("Значение", New TypeDescription, "_ValueTable", "Значение",
		False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("ТипЗначения", New TypeDescription("Строка"), "_ValueTable",
		"ТипЗначения", False));

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	For Each Элем In ValueStorageData Do
		НС = _ValueTable.Add();

		FillPropertyValues(НС, Элем, , "Значение");
		НС.ТипЗначения = Строка(TypeOf(Элем.Значение));

		If вНадоПреобразоватьЗначение(Элем.Значение) Then
			НС.Значение = New ХранилищеЗначения(Элем.Значение);
		Иначе
			НС.Значение = Элем.Значение;
		EndIf;
	EndDo;

	For Each Элем In РеквизитыКДобавлению Do
		ИмяЭФ = "_ТаблицаЗначений_" + Элем.Имя;
		ЭтаФорма.Items.Add(ИмяЭФ, Type("ПолеФормы"), ЭтаФорма.Items._ТаблицаЗначений);
		ЭтаФорма.Элементы[ИмяЭФ].ПутьКДанным = "_ValueTable." + Элем.Имя;
		ЭтаФорма.Элементы[ИмяЭФ].Вид = ВидПоляФормы.ПолеВвода;
	EndDo;

	Return True;
EndFunction

&AtServer
Function вПоказатьТаблицуЗначений(ValueStorageData)
	РеквизитыКДобавлению = New Array;
	РеквизитыКУдалению = New Array;

	For Each Колонка In ValueStorageData.Колонки Do
		РеквизитыКДобавлению.Add(New РеквизитФормы(Колонка.Имя, New TypeDescription, "_ValueTable",
			Колонка.Заголовок, False));
	EndDo;

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	For Each Элем In ValueStorageData Do
		НС = _ValueTable.Add();

		For Each Колонка In ValueStorageData.Колонки Do
			Значение = Элем[Колонка.Имя];

			If вНадоПреобразоватьЗначение(Значение) Then
				Значение = New ХранилищеЗначения(Значение);
			EndIf;
			НС[Колонка.Имя] = Значение;
		EndDo;
	EndDo;

	For Each Элем In РеквизитыКДобавлению Do
		ИмяЭФ = "_ТаблицаЗначений_" + Элем.Имя;
		ЭтаФорма.Items.Add(ИмяЭФ, Type("ПолеФормы"), ЭтаФорма.Items._ТаблицаЗначений);
		ЭтаФорма.Элементы[ИмяЭФ].ПутьКДанным = "_ValueTable." + Элем.Имя;
		ЭтаФорма.Элементы[ИмяЭФ].Вид = ВидПоляФормы.ПолеВвода;
	EndDo;

	Return True;
EndFunction

&AtServer
Function вПоказатьДеревоЗначений(ValueStorageData)
	РеквизитыКДобавлению = New Array;
	РеквизитыКУдалению = New Array;

	For Each Колонка In ValueStorageData.Колонки Do
		РеквизитыКДобавлению.Add(New РеквизитФормы(Колонка.Имя, New TypeDescription, "_ValueTree",
			Колонка.Заголовок, False));
	EndDo;

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	вЗаполнитьУзелДЗ(_ValueTree, ValueStorageData, ValueStorageData.Колонки);

	For Each Элем In РеквизитыКДобавлению Do
		ИмяЭФ = "_ДеревоЗначений_" + Элем.Имя;
		ЭтаФорма.Items.Add(ИмяЭФ, Type("ПолеФормы"), ЭтаФорма.Items._ValueTree);
		ЭтаФорма.Элементы[ИмяЭФ].ПутьКДанным = "_ValueTree." + Элем.Имя;
		ЭтаФорма.Элементы[ИмяЭФ].Вид = ВидПоляФормы.ПолеВвода;
	EndDo;

	Return True;
EndFunction

&AtServer
Function вЗаполнитьУзелДЗ(Знач Приемник, Знач Источник, Знач КоллекцияКолонок)
	For Each Элем In Источник.Строки Do
		НС = Приемник.ПолучитьЭлементы().Add();

		For Each Колонка In КоллекцияКолонок Do
			Значение = Элем[Колонка.Имя];

			If вНадоПреобразоватьЗначение(Значение) Then
				Значение = New ХранилищеЗначения(Значение);
			EndIf;
			НС[Колонка.Имя] = Значение;
		EndDo;

		вЗаполнитьУзелДЗ(НС, Элем, КоллекцияКолонок);
	EndDo;

	Return True;
EndFunction

&AtClient
Procedure OpenObject(Command)
	Значение = Undefined;

	Имя = вПолучитьПутьКДаннымТекущегоЭлемента();
	If Not ЗначениеЗаполнено(Имя) Then
		Return;
	EndIf;

	ЭФ = ЭтаФорма.ТекущийЭлемент;
	If TypeOf(ЭФ) = Type("ПолеФормы") Then
		Значение = ЭтаФорма[Имя];
	 ElsIf TypeOf(ЭФ) = Type("ТаблицаФормы") Then
		ТекДанные = ЭФ.ТекущиеДанные;
		If ТекДанные <> Undefined Then
			Значение = ТекДанные[Имя];
		EndIf;
	EndIf;

	If ЗначениеЗаполнено(Значение) Then
		If TypeOf(Значение) = mValueStorageType Then
			вПоказатьЗначениеХЗ(Значение);

		 ElsIf вЭтоОбъектМетаданных(TypeOf(Значение)) Then
			СтрукПарам = New Structure("мОбъектСсылка", Значение);
			ОткрытьФорму("Обработка.UT_ObjectsAttributesEditor.Форма.ObjectForm", СтрукПарам, , Значение);

		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure вПоказатьЗначениеХЗ(Значение)
	СтрукПарам = New Structure("ValueStorageData", Значение);
	ОткрытьФорму("ОбщаяФорма.UT_ValueStorageForm", СтрукПарам, , ТекущаяДата());
EndProcedure

&AtClient
Procedure _ТаблицаЗначенийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = False;

	ТекДанные = Элемент.ТекущиеДанные;
	If ТекДанные <> Undefined Then
		ИмяКолонки = Сред(Поле.Имя, СтрДлина(Элемент.Имя) + 2);
		Значение = ТекДанные[ИмяКолонки];

		If TypeOf(Значение) = mValueStorageType Then
			вПоказатьЗначениеХЗ(Значение);
		Иначе
			ПоказатьЗначение( , Значение);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure _ДеревоЗначенийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = False;

	ТекДанные = Элемент.ТекущиеДанные;
	If ТекДанные <> Undefined Then
		ИмяКолонки = Сред(Поле.Имя, СтрДлина(Элемент.Имя) + 2);
		Значение = ТекДанные[ИмяКолонки];

		If TypeOf(Значение) = mValueStorageType Then
			вПоказатьЗначениеХЗ(Значение);
		Иначе
			ПоказатьЗначение( , Значение);
		EndIf;
	EndIf;
EndProcedure

&AtServer
Function вПолучитьПутьКДаннымТекущегоЭлемента()
	ЭФ = ЭтаФорма.ТекущийЭлемент;
	If TypeOf(ЭФ) = Type("ТаблицаФормы") Then
		ТекПоле = ЭФ.ТекущийЭлемент;
		If TypeOf(ТекПоле) = Type("ПолеФормы") Then
			Значение = ТекПоле.ПутьКДанным;
			Поз = Найти(Значение, ".");
			If Поз <> 0 Then
				Значение = Сред(Значение, Поз + 1);
				If Найти(Значение, ".") = 0 Then
					Return Значение;
				EndIf;
			EndIf;
		EndIf;
	 ElsIf TypeOf(ЭФ) = Type("ПолеФормы") Then
		Return ЭФ.ПутьКДанным;
	EndIf;

	Return "";
EndFunction

&НаСервереБезКонтекста
Function вЭтоОбъектМетаданных(Знач Тип)
	ОбъектМД = Metadata.FindByType(Тип);
	Return (ОбъектМД <> Undefined And Not Metadata.Перечисления.Содержит(ОбъектМД));
EndFunction

&НаСервереБезКонтекста
Function вЭтоПростойType(Знач Тип)
	Результат = Тип = Type("Число") Or Тип = Type("Строка") Or Тип = Type("Булево") Or Тип = Type("Дата");

	Return Результат;
EndFunction

&НаСервереБезКонтекста
Function вНадоПреобразоватьЗначение(Знач Значение)
	If Значение = Undefined Or Значение = Null Then
		Return False;
	EndIf;

	ТипЗначения = TypeOf(Значение);

	If вЭтоПростойType(ТипЗначения) Then
		Return False;
	EndIf;

	If вЭтоОбъектМетаданных(ТипЗначения) Then
		Return False;
	EndIf;

	Return (ТипЗначения <> Type("ХранилищеЗначения"));
EndFunction