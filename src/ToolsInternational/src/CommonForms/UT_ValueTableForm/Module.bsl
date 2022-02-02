&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Try
		Value = ValueFromStringInternal(Parameters.InterValue);
	Except
		Message(BriefErrorDescription(ErrorInfo()));
		Cancel = True;
		Return;
	EndTry;

	If TypeOf(Value) <> Type("ТаблицаЗначений") Then
		Cancel = True;
		Return;
	EndIf;

	_ЧислоЗаписей = Value.Количество();
	
	ТипХЗ = Тип("ХранилищеЗначения");
	ТипТЗ = Тип("ТаблицаЗначений");
	ТипТТ = Тип("Тип");
	ТипМВ = Тип("МоментВремени");

	РеквизитыКДобавлению = New Array;
	РеквизитыКУдалению = New Array;

	For each Колонка In Value.Колонки Do
		//Если не Колонка.ТипЗначения.СодержитТип(пТипТаблицаЗначений) Тогда
		//	РеквизитыКДобавлению.Добавить(новый РеквизитФормы(Колонка.Имя, Колонка.ТипЗначения, "DataTable", Колонка.Заголовок, ложь));
		//КонецЕсли;

		Если Колонка.ТипЗначения.СодержитТип(ТипХЗ) Тогда
			ТипЗначенияРеквизита = Новый ОписаниеТипов;
		ИначеЕсли Колонка.ТипЗначения.СодержитТип(ТипТЗ) Тогда
			ТипЗначенияРеквизита = Новый ОписаниеТипов;
		ИначеЕсли Колонка.ТипЗначения.СодержитТип(ТипТТ) Тогда
			ТипЗначенияРеквизита = Новый ОписаниеТипов;
		ИначеЕсли Колонка.ТипЗначения.СодержитТип(ТипМВ) Тогда
			ТипЗначенияРеквизита = Новый ОписаниеТипов;
		Иначе
			ТипЗначенияРеквизита = Колонка.ТипЗначения;
		КонецЕсли;

		РеквизитыКДобавлению.Добавить(Новый РеквизитФормы(Колонка.Имя, ТипЗначенияРеквизита, "DataTable",
			Колонка.Заголовок, Ложь));
	EndDo;

	ChangeAttributes(РеквизитыКДобавлению, РеквизитыКУдалению);
	ValueToFormAttribute(Value, "DataTable");

	For each Колонка In Value.Колонки Do
		//Если не Колонка.ТипЗначения.СодержитТип(пТипТаблицаЗначений) Тогда
		ThisForm.Элементы.Добавить(Колонка.Имя, Тип("ПолеФормы"), ThisForm.Элементы.DataTable);
		ThisForm.Элементы[Колонка.Имя].ПутьКДанным = "DataTable." + Колонка.Имя;
		ThisForm.Элементы[Колонка.Имя].Вид = ВидПоляФормы.ПолеВвода;
		ThisForm.Элементы[Колонка.Имя].ДоступныеТипы = Колонка.ТипЗначения;
		//КонецЕсли;
	EndDo;

	If Not IsBlankString(Parameters.Title) Then
		ThisForm.Title = Parameters.Title;
	EndIf;
EndProcedure

&AtClient
Procedure CommandOK(Command)
	Result = New Structure;
	Result.Insert("ТипЗначения", "ТаблицаЗначений");
	Result.Insert("СтрокаВнутр", вТаблицаДанныхКакСтрокаВнутр());
	Close(Result);
EndProcedure

&AtClient
Procedure CommandClose(Command)
	Close();
EndProcedure

&AtClient
Procedure CommandClearTable(Command)
	DataTable.Clear();
EndProcedure

&AtServer
Function вТаблицаДанныхКакСтрокаВнутр()
	Return ValueToStringInternal(FormAttributeToValue("DataTable"));
EndFunction