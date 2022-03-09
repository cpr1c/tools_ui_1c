Var мМенеджеры Export;

Function ПолучитьВидСравнения(FieldName, ВидСравненияОтбора, ИмяПараметра) Export
	If Left(FieldName, 7) = "Object." Then
		FieldName = "Reference." + Mid(FieldName, 8);
	EndIf;

	If ВидСравненияОтбора = DataCompositionComparisonType.Equal Then
		Return "_Таблица." + FieldName + " = &" + ИмяПараметра;

	ElsIf ВидСравненияОтбора = DataCompositionComparisonType.Greater Then
		Return "_Таблица." + FieldName + " > &" + ИмяПараметра;

	ElsIf ВидСравненияОтбора = DataCompositionComparisonType.GreaterOrEqual Then
		Return "_Таблица." + FieldName + " >= &" + ИмяПараметра;

	ElsIf ВидСравненияОтбора = DataCompositionComparisonType.InHierarchy Or ВидСравненияОтбора
		= DataCompositionComparisonType.InListByHierarchy Then
		Return "_Таблица." + FieldName + " В ИЕРАРХИИ (&" + ИмяПараметра + ")";

	ElsIf ВидСравненияОтбора = DataCompositionComparisonType.InList Then
		Return "_Таблица." + FieldName + " В (&" + ИмяПараметра + ")";

	ElsIf ВидСравненияОтбора = DataCompositionComparisonType.Less Then
		Return "_Таблица." + FieldName + " < &" + ИмяПараметра;

	ElsIf ВидСравненияОтбора = DataCompositionComparisonType.LessOrEqual Then
		Return "_Таблица." + FieldName + " <= &" + ИмяПараметра;

	ElsIf ВидСравненияОтбора = DataCompositionComparisonType.NotInList Then
		Return "НЕ _Таблица." + FieldName + " В (&" + ИмяПараметра + ")";

	ElsIf ВидСравненияОтбора = DataCompositionComparisonType.NotInHierarchy Or ВидСравненияОтбора
		= DataCompositionComparisonType.NotInListByHierarchy Then
		Return "НЕ _Таблица." + FieldName + " В ИЕРАРХИИ (&" + ИмяПараметра + ")";

	ElsIf ВидСравненияОтбора = DataCompositionComparisonType.NotEqual Then
		Return "_Таблица." + FieldName + " <> &" + ИмяПараметра;

	EndIf;

EndFunction // ()

Function РазложитьСтрокуВМассивПодстрок(Val Стр, Splitter = ",") Export

	МассивСтрок = New Array;
	If Splitter = " " Then
		Стр = TrimAll(Стр);
		While True Do
			Поз = Find(Стр, Splitter);
			If Поз = 0 Then
				МассивСтрок.Add(Стр);
				Return МассивСтрок;
			EndIf;
			МассивСтрок.Add(Left(Стр, Поз - 1));
			Стр = TrimL(Mid(Стр, Поз));
		EndDo;
	Else
		ДлинаРазделителя = StrLen(Splitter);
		While True Do
			Поз = Find(Стр, Splitter);
			If Поз = 0 Then
				If (TrimAll(Стр) <> "") Then
					МассивСтрок.Add(Стр);
				EndIf;
				Return МассивСтрок;
			EndIf;
			МассивСтрок.Add(Left(Стр, Поз - 1));
			Стр = Mid(Стр, Поз + ДлинаРазделителя);
		EndDo;
	EndIf;

EndFunction

Function ПолучитьСтрокуИзМассиваПодстрок(Array, Splitter = ",") Export
	Result = "";
	For Each Item In Array Do
		Подстрока = ?(TypeOf(Item) = Type("String"), Item, String(Item));
		РазделительПодстрок = ?(IsBlankString(Result), "", Splitter);
		Result = Result + РазделительПодстрок + Подстрока;
	EndDo;

	Return Result;
EndFunction

Procedure ЗагрузитьОбработки(ТекФорма, ДоступныеОбработки2, ВыбранныеОбработки2) Export

	СоответствиеДоступностиНастроек=New Map;
	СоответствиеДоступностиНастроек.Insert("ПроизвольныйАлгоритм", True);
	СоответствиеДоступностиНастроек.Insert("ПеренумерацияОбъектов", True);
	СоответствиеДоступностиНастроек.Insert("MarkToDelete", False);
	СоответствиеДоступностиНастроек.Insert("ПровестиДокументы", False);
	СоответствиеДоступностиНастроек.Insert("ОтменитьПроведениеДокументов", False);
	СоответствиеДоступностиНастроек.Insert("СнятьПометкуУдаления", False);
	СоответствиеДоступностиНастроек.Insert("ИзменитьВремяДокументов", True);
	СоответствиеДоступностиНастроек.Insert("ИзменитьСуммуОперации", True);
	СоответствиеДоступностиНастроек.Insert("Delete", False);
	СоответствиеДоступностиНастроек.Insert("УстановкаРеквизитов", True);

	_ДоступныеОбработки = ТекФорма.FormAttributeToValue("ДоступныеОбработки");
	_ВыбранныеОбработки = ТекФорма.FormAttributeToValue("ВыбранныеОбработки");

	Forms = ThisObject.Metadata().Forms;

	For Each Form In Forms Do
		If Form.Name = "ПодборИОбработка" Or Form.Name = "ФормаНастроек" Or Form.Name = "ШаблонОбработки"
			Or Form.Name = "ФормаВыбораТаблиц" Or Form.Name = "ФормаОтбора" Then

			Continue;
		EndIf;
		НайденнаяСтрока = _ДоступныеОбработки.Rows.Find(Form.Name, "FormName");
		If Not НайденнаяСтрока = Undefined Then
			If Not НайденнаяСтрока.Processing = Form.Synonym Then
				НайденнаяСтрока.Processing = Form.Synonym;
			EndIf;
			//If НЕ ThisObject.GetForm(Form.Name).мИспользоватьНастройки Then
			If Not СоответствиеДоступностиНастроек[Form.Name] Then
				НайденнаяСтрока.Rows.Clear();
			EndIf;
			Continue;
		EndIf;

		НоваяОбработка = _ДоступныеОбработки.Rows.Add();
		НоваяОбработка.Processing = Form.Synonym;
		НоваяОбработка.FormName  = Form.Name;

		Setting = New Structure;
		Setting.Insert("Processing", Form.Synonym);
		Setting.Insert("Прочее", Undefined);
		НоваяОбработка.Setting.Add(Setting);
	EndDo;

	МассивДляУдаления = New Array;

	For Each ДоступнаяОбработка In _ДоступныеОбработки.Rows Do
		If Forms.Find(ДоступнаяОбработка.FormName) = Undefined Then
			МассивДляУдаления.Add(ДоступнаяОбработка);
		EndIf;
	EndDo;

	For IndexOf = 0 To МассивДляУдаления.Count() - 1 Do
		_ДоступныеОбработки.Rows.Delete(МассивДляУдаления[IndexOf]);
	EndDo;

	МассивДляУдаления.Clear();

	For Each ВыбраннаяОбработка In _ВыбранныеОбработки Do
		If ВыбраннаяОбработка.СтрокаДоступнойОбработки = Undefined Then
			МассивДляУдаления.Add(ВыбраннаяОбработка);
		Else
			If ВыбраннаяОбработка.СтрокаДоступнойОбработки.Parent = Undefined Then
				If _ДоступныеОбработки.Rows.Find(ВыбраннаяОбработка.СтрокаДоступнойОбработки.FormName, "FormName")
					= Undefined Then
					МассивДляУдаления.Add(ВыбраннаяОбработка);
				EndIf;
			Else
				If _ДоступныеОбработки.Rows.Find(ВыбраннаяОбработка.СтрокаДоступнойОбработки.Parent.FormName,
					"FormName") = Undefined Then
					МассивДляУдаления.Add(ВыбраннаяОбработка);
				EndIf;
			EndIf;
		EndIf;
	EndDo;

	For IndexOf = 0 To МассивДляУдаления.Count() - 1 Do
		_ВыбранныеОбработки.Delete(МассивДляУдаления[IndexOf]);
	EndDo;

	ТекФорма.ValueToFormAttribute(_ДоступныеОбработки, "ДоступныеОбработки");
	ТекФорма.ValueToFormAttribute(_ВыбранныеОбработки, "ВыбранныеОбработки");

EndProcedure

// Инициализирует переменную мМенеджеры, содержащую соответствия типов объектов их свойствам.
//
// Parameters:
//  None.
//
// Возвращаемое значение:
//  Map, содержащее соответствия типов объектов их свойствам.
// 
Function ИнициализацияМенеджеров() Export

	Менеджеры = New Map;

	TypeName = "Catalog";
	For Each ОбъектМД In Metadata.Catalogs Do
		Name              = ОбъектМД.Name;
		Менеджер         = Catalogs[Name];
		ТипСсылкиСтрокой = "СправочникСсылка." + Name;
		ТипСсылки        = Type(ТипСсылкиСтрокой);
		Structure = New Structure("Name,TypeName,ТипСсылкиСтрокой,Менеджер,ТипСсылки, ОбъектМД", Name, TypeName,
			ТипСсылкиСтрокой, Менеджер, ТипСсылки, ОбъектМД);
		Менеджеры.Insert(ОбъектМД, Structure);
	EndDo;

	TypeName = "Document";
	For Each ОбъектМД In Metadata.Documents Do
		Name              = ОбъектМД.Name;
		Менеджер         = Documents[Name];
		ТипСсылкиСтрокой = "ДокументСсылка." + Name;
		ТипСсылки        = Type(ТипСсылкиСтрокой);
		Structure = New Structure("Name,TypeName,ТипСсылкиСтрокой,Менеджер,ТипСсылки, ОбъектМД", Name, TypeName,
			ТипСсылкиСтрокой, Менеджер, ТипСсылки, ОбъектМД);
		Менеджеры.Insert(ОбъектМД, Structure);
	EndDo;

	Return Менеджеры;

EndFunction // вИнициализацияМенеджеров()

мМенеджеры = ИнициализацияМенеджеров();