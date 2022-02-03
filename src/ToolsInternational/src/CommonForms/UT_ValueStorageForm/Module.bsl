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

	If TypeOf(ValueStorageData) = Type("SpreadsheetDocument") Then
		_DataForRepresentation = New Structure("Value, ValueType", ValueStorageData, "SpreadsheetDocument");
		Return;
	 ElsIf TypeOf(ValueStorageData) = Type("TextDocument") Then
		_DataForRepresentation = New Structure("Value, ValueType", ValueStorageData, "TextDocument");
		Return;
	 ElsIf TypeOf(ValueStorageData) <> Type("ValueStorage") Then
		Cancel = True;
		Return;
	EndIf;

	ValueStorageData = ValueStorageData.Get();
	If ValueStorageData = Undefined Then
		Cancel = True;
		Return;
	EndIf;

	ValueStorageDataType = TypeOf(ValueStorageData);

	If ValueStorageDataType = Type("Array") Then
		Title = "Array";
		Cancel = Not вПоказатьМассив(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("Structure") Then
		Title = "Structure";
		Cancel = Not вПоказатьСтруктуру(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("Map") Then
		Title = "Map";
		Cancel = Not вПоказатьСоответствие(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("ValueList") Then
		Title = "ValueList";
		Cancel = Not вПоказатьСписокЗначений(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("ValueTable") Then
		Title = "ValueTable";
		Cancel = Not вПоказатьТаблицуЗначений(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("ValueTree") Then
		Title = "ValueTree";
		Items._ValueTable.Visible = False;
		Items._ValueTree.Visible = True;
		Cancel = Not вПоказатьДеревоЗначений(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("SpreadsheetDocument") Then
		_DataForRepresentation = New Structure("Value, ValueType", ValueStorageData, "SpreadsheetDocument");
	 ElsIf ValueStorageDataType = Type("TextDocument") Then
		_DataForRepresentation = New Structure("Value, ValueType", ValueStorageData, "TextDocument");
	Иначе
		Cancel = True;
	EndIf;
EndProcedure


&AtClient
Procedure OnOpen(Cancel)
	mValueStorageType = Type("ValueStorage");

	If _DataForRepresentation <> Undefined Then
		If _DataForRepresentation.ValueType = "SpreadsheetDocument" Then
			_DataForRepresentation.Value.Show(_DataForRepresentation.ValueType);
		 ElsIf _DataForRepresentation.ValueType = "TextDocument" Then
			_DataForRepresentation.Value.Show(_DataForRepresentation.ValueType);
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
	РеквизитыКДобавлению.Add(New РеквизитФормы("Value", New TypeDescription, "_ValueTable", "Value",
		False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("ValueType", New TypeDescription("Строка"), "_ValueTable",
		"ValueType", False));

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	For Инд = 0 По ValueStorageData.ВГраница() Do
		Value = ValueStorageData[Инд];
		НС = _ValueTable.Add();

		НС.Индекс = Инд;
		НС.ValueType = Строка(TypeOf(Value));

		If NeedToConvertValue(Value) Then
			НС.Value = New ValueStorage(Value);
		Иначе
			НС.Value = Value;
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
	РеквизитыКДобавлению.Add(New РеквизитФормы("Value", New TypeDescription, "_ValueTable", "Value",
		False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("ValueType", New TypeDescription("Строка"), "_ValueTable",
		"ValueType", False));

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	For Each Элем In ValueStorageData Do
		НС = _ValueTable.Add();

		FillPropertyValues(НС, Элем, , "Value");
		НС.ValueType = Строка(TypeOf(Элем.Value));

		If NeedToConvertValue(Элем.Value) Then
			НС.Value = New ValueStorage(Элем.Value);
		Иначе
			НС.Value = Элем.Value;
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
	РеквизитыКДобавлению.Add(New РеквизитФормы("Value", New TypeDescription, "_ValueTable", "Value",
		False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("ValueType", New TypeDescription("Строка"), "_ValueTable",
		"ValueType", False));

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	For Each Элем In ValueStorageData Do
		НС = _ValueTable.Add();

		FillPropertyValues(НС, Элем, , "Value");
		НС.ValueType = Строка(TypeOf(Элем.Value));

		If NeedToConvertValue(Элем.Value) Then
			НС.Value = New ValueStorage(Элем.Value);
		Иначе
			НС.Value = Элем.Value;
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
	РеквизитыКДобавлению.Add(New РеквизитФормы("Value", New TypeDescription, "_ValueTable", "Value",
		False));
	РеквизитыКДобавлению.Add(New РеквизитФормы("ValueType", New TypeDescription("Строка"), "_ValueTable",
		"ValueType", False));

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	For Each Элем In ValueStorageData Do
		НС = _ValueTable.Add();

		FillPropertyValues(НС, Элем, , "Value");
		НС.ValueType = Строка(TypeOf(Элем.Value));

		If NeedToConvertValue(Элем.Value) Then
			НС.Value = New ValueStorage(Элем.Value);
		Иначе
			НС.Value = Элем.Value;
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
			Колонка.Title, False));
	EndDo;

	ИзменитьРеквизиты(РеквизитыКДобавлению, РеквизитыКУдалению);

	For Each Элем In ValueStorageData Do
		НС = _ValueTable.Add();

		For Each Колонка In ValueStorageData.Колонки Do
			Value = Элем[Колонка.Имя];

			If NeedToConvertValue(Value) Then
				Value = New ValueStorage(Value);
			EndIf;
			НС[Колонка.Имя] = Value;
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
			Колонка.Title, False));
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
			Value = Элем[Колонка.Имя];

			If NeedToConvertValue(Value) Then
				Value = New ValueStorage(Value);
			EndIf;
			НС[Колонка.Имя] = Value;
		EndDo;

		вЗаполнитьУзелДЗ(НС, Элем, КоллекцияКолонок);
	EndDo;

	Return True;
EndFunction

&AtClient
Procedure OpenObject(Command)
	Value = Undefined;

	Имя = вПолучитьПутьКДаннымТекущегоЭлемента();
	If Not ЗначениеЗаполнено(Имя) Then
		Return;
	EndIf;

	ЭФ = ЭтаФорма.ТекущийЭлемент;
	If TypeOf(ЭФ) = Type("ПолеФормы") Then
		Value = ЭтаФорма[Имя];
	 ElsIf TypeOf(ЭФ) = Type("ТаблицаФормы") Then
		ТекДанные = ЭФ.ТекущиеДанные;
		If ТекДанные <> Undefined Then
			Value = ТекДанные[Имя];
		EndIf;
	EndIf;

	If ЗначениеЗаполнено(Value) Then
		If TypeOf(Value) = mValueStorageType Then
			вПоказатьЗначениеХЗ(Value);

		 ElsIf IsMetadataObJect(TypeOf(Value)) Then
			СтрукПарам = New Structure("мОбъектСсылка", Value);
			ОткрытьФорму("Обработка.UT_ObjectsAttributesEditor.Форма.ObjectForm", СтрукПарам, , Value);

		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure вПоказатьЗначениеХЗ(Value)
	СтрукПарам = New Structure("ValueStorageData", Value);
	ОткрытьФорму("ОбщаяФорма.UT_ValueStorageForm", СтрукПарам, , ТекущаяДата());
EndProcedure

&AtClient
Procedure _ТаблицаЗначенийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = False;

	ТекДанные = Элемент.ТекущиеДанные;
	If ТекДанные <> Undefined Then
		ИмяКолонки = Сред(Поле.Имя, СтрДлина(Элемент.Имя) + 2);
		Value = ТекДанные[ИмяКолонки];

		If TypeOf(Value) = mValueStorageType Then
			вПоказатьЗначениеХЗ(Value);
		Иначе
			ПоказатьЗначение( , Value);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure _ДеревоЗначенийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = False;

	ТекДанные = Элемент.ТекущиеДанные;
	If ТекДанные <> Undefined Then
		ИмяКолонки = Сред(Поле.Имя, СтрДлина(Элемент.Имя) + 2);
		Value = ТекДанные[ИмяКолонки];

		If TypeOf(Value) = mValueStorageType Then
			вПоказатьЗначениеХЗ(Value);
		Иначе
			ПоказатьЗначение( , Value);
		EndIf;
	EndIf;
EndProcedure

&AtServer
Function вПолучитьПутьКДаннымТекущегоЭлемента()
	ЭФ = ЭтаФорма.ТекущийЭлемент;
	If TypeOf(ЭФ) = Type("ТаблицаФормы") Then
		ТекПоле = ЭФ.ТекущийЭлемент;
		If TypeOf(ТекПоле) = Type("ПолеФормы") Then
			Value = ТекПоле.ПутьКДанным;
			Поз = Найти(Value, ".");
			If Поз <> 0 Then
				Value = Сред(Value, Поз + 1);
				If Найти(Value, ".") = 0 Then
					Return Value;
				EndIf;
			EndIf;
		EndIf;
	 ElsIf TypeOf(ЭФ) = Type("ПолеФормы") Then
		Return ЭФ.ПутьКДанным;
	EndIf;

	Return "";
EndFunction

&AtServerNoContext
Function IsMetadataObJect(Val Type)
	ObjectOfMetadata = Metadata.FindByType(Type);
	Return (ObjectOfMetadata <> Undefined And Not Metadata.Enums.Contains(ObjectOfMetadata));
EndFunction

&AtServerNoContext
Function IsSimpleType(Val Type)
	Result = Type = Type("Number") Or Type = Type("String") Or Type = Type("Boolean") Or Type = Type("Date");

	Return Result;
EndFunction

&AtServerNoContext
Function NeedToConvertValue(Знач Value)
	If Value = Undefined Or Value = Null Then
		Return False;
	EndIf;

	ValueType = TypeOf(Value);

	If IsSimpleType(ValueType) Then
		Return False;
	EndIf;

	If IsMetadataObJect(ValueType) Then
		Return False;
	EndIf;

	Return (ValueType <> Type("ValueStorage"));
EndFunction