//Признак использования настроек
&AtClient
Var мИспользоватьНастройки Export;

//Types объектов, для которых может использоваться обработка.
//To умолчанию для всех.
&AtClient
Var мТипыОбрабатываемыхОбъектов Export;

&AtClient
Var мНастройка;

////////////////////////////////////////////////////////////////////////////////
// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ And ФУНКЦИИ

&AtServer
Function ИзменитьЗначениеСуммы(Val CurrentValue)
	//SetValue
	If ВидДействияНадСуммой = 0 Then
		Return ПараметрДействия;
		
		//Увеличить на сумму
	ElsIf ВидДействияНадСуммой = 1 Then
		Return CurrentValue + ПараметрДействия;
		
		//Увеличить на %
	ElsIf ВидДействияНадСуммой = 2 Then
		Return CurrentValue * (100 + ПараметрДействия) / 100;
		
		//Уменьшить на сумму
	ElsIf ВидДействияНадСуммой = 3 Then
		Return CurrentValue - ПараметрДействия;
		
		//Уменьшить на %
	ElsIf ВидДействияНадСуммой = 4 Then
		Return CurrentValue * (100 - ПараметрДействия) / 100;
	EndIf;
EndFunction

// Выполняет обработку объектов.
//
// Parameters:
//  Object                 - обрабатываемый объект.
//  ПорядковыйНомерОбъекта - порядковый номер обрабатываемого объекта.
//
&AtServer
Procedure ОбработатьОбъект(Reference, ПорядковыйНомерОбъекта, ПараметрыЗаписиОбъектов)

	Object = Reference.GetObject();
	If ОбрабатыватьТабличныеЧасти Then
		СтрокаТЧ=Object[НайденныеОбъектыТЧ[ПорядковыйНомерОбъекта].Т_ТЧ][НайденныеОбъектыТЧ[ПорядковыйНомерОбъекта].Т_НомерСтроки
			- 1];
	EndIf;

	For Each Attribute In Attributes Do
		If Attribute.Attribute = ТекущийРеквизит Then
			Object[Attribute.Attribute] = ИзменитьЗначениеСуммы(Object[Attribute.Attribute]);
		ElsIf Attribute.Attribute + "_ТЧ_12345" = ТекущийРеквизит Then
			СтрокаТЧ[Attribute.Attribute] = ИзменитьЗначениеСуммы(СтрокаТЧ[Attribute.Attribute]);
		EndIf;
	EndDo;
	
	
//	Object.Write();
	If UT_Common.WriteObjectToDB(Object, ПараметрыЗаписиОбъектов) Then
		UT_CommonClientServer.MessageToUser(StrTemplate("Object %1 УСПЕХ!!!", Object));
	EndIf;

EndProcedure // ОбработатьОбъект()

// Выполняет обработку объектов.
//
// Parameters:
//  None.
//
&AtClient
Function ExecuteProcessing(ПараметрыЗаписиОбъектов) Export

	Indicator = ПолучитьИндикаторПроцесса(НайденныеОбъекты.Count());
	For IndexOf = 0 To НайденныеОбъекты.Count() - 1 Do
		ОбработатьИндикатор(Indicator, IndexOf + 1);

		СтрокаНайденныхОбъектов=НайденныеОбъектыТЧ.Get(IndexOf);

		If СтрокаНайденныхОбъектов.StartChoosing Then//

			ОбработатьОбъект(СтрокаНайденныхОбъектов.Object, IndexOf, ПараметрыЗаписиОбъектов);
		EndIf;
	EndDo;

	If IndexOf > 0 Then
		//NotifyChanged(Type(ОбъектПоиска.Type + "Reference." + ОбъектПоиска.Name));
	EndIf;

	Return IndexOf;
EndFunction // вВыполнитьОбработку()

// Сохраняет значения реквизитов формы.
//
// Parameters:
//  None.
//
&AtClient
Procedure СохранитьНастройку() Export

	If IsBlankString(ТекущаяНастройкаПредставление) Then
		ShowMessageBox( ,
			"Задайте имя новой настройки для сохранения или выберите существующую настройку для перезаписи.");
	EndIf;

	НоваяНастройка = New Structure;
	НоваяНастройка.Insert("Processing", ТекущаяНастройкаПредставление);
	НоваяНастройка.Insert("Прочее", New Structure);

	For Each РеквизитНастройки In мНастройка Do
		Execute ("НоваяНастройка.Прочее.Insert(String(РеквизитНастройки.Key), " + String(РеквизитНастройки.Key)
			+ ");");
	EndDo;

	ДоступныеОбработки = ThisForm.FormOwner.ДоступныеОбработки;
	ТекущаяДоступнаяНастройка = Undefined;
	For Each ТекущаяДоступнаяНастройка In ДоступныеОбработки.GetItems() Do
		If ТекущаяДоступнаяНастройка.GetID() = Parent Then
			Break;
		EndIf;
	EndDo;

	If ТекущаяНастройка = Undefined Or Not ТекущаяНастройка.Processing = ТекущаяНастройкаПредставление Then
		If ТекущаяДоступнаяНастройка <> Undefined Then
			NewLine = ТекущаяДоступнаяНастройка.GetItems().Add();
			NewLine.Processing = ТекущаяНастройкаПредставление;
			NewLine.Setting.Add(НоваяНастройка);

			ThisForm.FormOwner.Items.ДоступныеОбработки.CurrentLine = NewLine.GetID();
		EndIf;
	EndIf;

	If ТекущаяДоступнаяНастройка <> Undefined And CurrentLine > -1 Then
		For Each ТекНастройка In ТекущаяДоступнаяНастройка.GetItems() Do
			If ТекНастройка.GetID() = CurrentLine Then
				Break;
			EndIf;
		EndDo;

		If ТекНастройка.Setting.Count() = 0 Then
			ТекНастройка.Setting.Add(НоваяНастройка);
		Else
			ТекНастройка.Setting[0].Value = НоваяНастройка;
		EndIf;
	EndIf;

	ТекущаяНастройка = НоваяНастройка;
	ThisForm.Modified = False;
EndProcedure // вСохранитьНастройку()

// Восстанавливает сохраненные значения реквизитов формы.
//
// Parameters:
//  None.
//
&AtClient
Procedure ЗагрузитьНастройку() Export

	If Items.ТекущаяНастройка.ChoiceList.Count() = 0 Then
		УстановитьИмяНастройки("Новая настройка");
	Else
		If Not ТекущаяНастройка.Прочее = Undefined Then
			мНастройка = ТекущаяНастройка.Прочее;
		EndIf;
	EndIf;

	For Each РеквизитНастройки In мНастройка Do
		//@skip-warning
		Value = мНастройка[РеквизитНастройки.Key];
		Execute (String(РеквизитНастройки.Key) + " = Value;");
	EndDo;

EndProcedure //вЗагрузитьНастройку()

// Устанавливает значение реквизита "ТекущаяНастройка" по имени настройки или произвольно.
//
// Parameters:
//  ИмяНастройки   - произвольное имя настройки, которое необходимо установить.
//
&AtClient
Procedure УстановитьИмяНастройки(ИмяНастройки = "") Export

	If IsBlankString(ИмяНастройки) Then
		If ТекущаяНастройка = Undefined Then
			ТекущаяНастройкаПредставление = "";
		Else
			ТекущаяНастройкаПредставление = ТекущаяНастройка.Processing;
		EndIf;
	Else
		ТекущаяНастройкаПредставление = ИмяНастройки;
	EndIf;

EndProcedure // вУстановитьИмяНастройки()

// Получает структуру для индикации прогресса цикла.
//
// Parameters:
//  КоличествоПроходов - Number - максимальное значение счетчика;
//  ПредставлениеПроцесса - String, "Выполнено" - отображаемое название процесса;
//  ВнутреннийСчетчик - Boolean, *True - использовать внутренний счетчик с начальным значением 1,
//                    иначе нужно будет передавать значение счетчика при каждом вызове обновления индикатора;
//  КоличествоОбновлений - Number, *100 - всего количество обновлений индикатора;
//  ЛиВыводитьВремя - Boolean, *True - выводить приблизительное время до окончания процесса;
//  РазрешитьПрерывание - Boolean, *True - разрешает пользователю прерывать процесс.
//
// Возвращаемое значение:
//  Structure - которую потом нужно будет передавать в метод ЛксОбработатьИндикатор.
//
&AtClient
Function ПолучитьИндикаторПроцесса(КоличествоПроходов, ПредставлениеПроцесса = "Выполнено", ВнутреннийСчетчик = True,
	КоличествоОбновлений = 100, ЛиВыводитьВремя = True, РазрешитьПрерывание = True) Export

	Indicator = New Structure;
	Indicator.Insert("КоличествоПроходов", КоличествоПроходов);
	Indicator.Insert("ДатаНачалаПроцесса", CurrentDate());
	Indicator.Insert("ПредставлениеПроцесса", ПредставлениеПроцесса);
	Indicator.Insert("ЛиВыводитьВремя", ЛиВыводитьВремя);
	Indicator.Insert("РазрешитьПрерывание", РазрешитьПрерывание);
	Indicator.Insert("ВнутреннийСчетчик", ВнутреннийСчетчик);
	Indicator.Insert("Step", КоличествоПроходов / КоличествоОбновлений);
	Indicator.Insert("СледующийСчетчик", 0);
	Indicator.Insert("Счетчик", 0);
	Return Indicator;

EndFunction // ЛксПолучитьИндикаторПроцесса()

// Проверяет и обновляет индикатор. Нужно вызывать на каждом проходе индицируемого цикла.
//
// Parameters:
//  Indicator    - Structure - индикатора, полученная методом ЛксПолучитьИндикаторПроцесса;
//  Счетчик      - Number - внешний счетчик цикла, используется при ВнутреннийСчетчик = False.
//
&AtClient
Procedure ОбработатьИндикатор(Indicator, Счетчик = 0) Export

	If Indicator.ВнутреннийСчетчик Then
		Indicator.Счетчик = Indicator.Счетчик + 1;
		Счетчик = Indicator.Счетчик;
	EndIf;
	If Indicator.РазрешитьПрерывание Then
		UserInterruptProcessing();
	EndIf;

	If Счетчик > Indicator.СледующийСчетчик Then
		Indicator.СледующийСчетчик = Int(Счетчик + Indicator.Step);
		If Indicator.ЛиВыводитьВремя Then
			ПрошлоВремени = CurrentDate() - Indicator.ДатаНачалаПроцесса;
			Осталось = ПрошлоВремени * (Indicator.КоличествоПроходов / Счетчик - 1);
			Часов = Int(Осталось / 3600);
			Осталось = Осталось - (Часов * 3600);
			Минут = Int(Осталось / 60);
			Секунд = Int(Int(Осталось - (Минут * 60)));
			ОсталосьВремени = Format(Часов, "ЧЦ=2; ЧН=00; ЧВН=") + ":" + Format(Минут, "ЧЦ=2; ЧН=00; ЧВН=") + ":"
				+ Format(Секунд, "ЧЦ=2; ЧН=00; ЧВН=");
			ТекстОсталось = "Осталось: ~" + ОсталосьВремени;
		Else
			ТекстОсталось = "";
		EndIf;

		If Indicator.КоличествоПроходов > 0 Then
			ТекстСостояния = ТекстОсталось;
		Else
			ТекстСостояния = "";
		EndIf;

		Status(Indicator.ПредставлениеПроцесса, Счетчик / Indicator.КоличествоПроходов * 100, ТекстСостояния);
	EndIf;

	If Счетчик = Indicator.КоличествоПроходов Then
		Status(Indicator.ПредставлениеПроцесса, 100, ТекстСостояния);
	EndIf;

EndProcedure // ЛксОбработатьИндикатор()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&AtClient
Procedure OnOpen(Cancel)
	If мИспользоватьНастройки Then
		УстановитьИмяНастройки();
		ЗагрузитьНастройку();
	Else
		Items.ТекущаяНастройка.Enabled = False;
		Items.СохранитьНастройки.Enabled = False;
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("Setting") Then
		ТекущаяНастройка = Parameters.Setting;
	EndIf;
	If Parameters.Property("НайденныеОбъекты") Then
		НайденныеОбъекты.LoadValues(Parameters.НайденныеОбъекты);
	EndIf;

	If Parameters.Property("НайденныеОбъектыТЧ") Then

		ТЗНО=Parameters.НайденныеОбъектыТЧ.Unload();

		НайденныеОбъектыТЧ.Load(ТЗНО);
	EndIf;
	CurrentLine = -1;
	If Parameters.Property("CurrentLine") Then
		If Parameters.CurrentLine <> Undefined Then
			CurrentLine = Parameters.CurrentLine;
		EndIf;
	EndIf;
	If Parameters.Property("Parent") Then
		Parent = Parameters.Parent;
	EndIf;
	//If Parameters.Property("ОбъектПоиска") Then
	//	ОбъектПоиска = Parameters.ОбъектПоиска;
	//EndIf;

	Items.ТекущаяНастройка.ChoiceList.Clear();
	If Parameters.Property("Settings") Then
		For Each String In Parameters.Settings Do
			Items.ТекущаяНастройка.ChoiceList.Add(String, String.Processing);
		EndDo;
	EndIf;

	If Parameters.Property("TableAttributes") Then
		ТАбРеквизитов=Parameters.TableAttributes;
		ТАбРеквизитов.Sort("ЭтоТЧ");
		For Each Attribute In Parameters.TableAttributes Do
			NewLine = Attributes.Add();
			NewLine.Attribute      = Attribute.Name;//?(IsBlankString(Attribute.Synonym), Attribute.Name, Attribute.Synonym);
			NewLine.ID = Attribute.Presentation;
			NewLine.Type           = Attribute.Type;
			NewLine.Value      = NewLine.Type.AdjustValue();
			NewLine.РеквизитТЧ	  = Attribute.ЭтоТЧ;
			If Attribute.Type = ОписаниеТипа("Number") Then
				Items.ТекущийРеквизит.ChoiceList.Add(Attribute.Name + ?(Attribute.ЭтоТЧ, "_ТЧ_12345", ""),
					Attribute.Presentation + ?(Attribute.ЭтоТЧ, " [ТЧ]", ""));
			EndIf;
		EndDo;
		If Items.ТекущийРеквизит.ChoiceList.Count() > 0 Then
			ТекущийРеквизит= Items.ТекущийРеквизит.ChoiceList[0].Value;
		EndIf;

	EndIf;
	If Parameters.Property("ProcessTabularParts") Then
		ОбрабатыватьТабличныеЧасти=Parameters.ProcessTabularParts;
	EndIf;

EndProcedure
&AtServer
Function ОписаниеТипа(ТипСтрокой) Export

	МассивТипов = New Array;
	МассивТипов.Add(Type(ТипСтрокой));
	TypeDescription = New TypeDescription(МассивТипов);

	Return TypeDescription;

EndFunction // вОписаниеТипа()


////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ, ВЫЗЫВАЕМЫЕ ИЗ ЭЛЕМЕНТОВ ФОРМЫ

&AtClient
Procedure ВыполнитьОбработкуКоманда(Command)
	ОбработаноОбъектов = ExecuteProcessing(UT_CommonClientServer.FormWriteSettings(
		ThisObject.FormOwner));

	ShowMessageBox( , "Processing <" + TrimAll(ThisForm.Title) + "> завершена!
																		   |Обработано объектов: " + ОбработаноОбъектов
		+ ".");
EndProcedure

&AtClient
Procedure СохранитьНастройкиКоманда(Command)
	СохранитьНастройку();
EndProcedure

&AtClient
Procedure ТекущаяНастройкаОбработкаВыбора(Item, ВыбранноеЗначение, StandardProcessing)
	StandardProcessing = False;

	If Not ТекущаяНастройка = ВыбранноеЗначение Then

		If ThisForm.Modified Then
			ShowQueryBox(New NotifyDescription("ТекущаяНастройкаОбработкаВыбораЗавершение", ThisForm,
				New Structure("ВыбранноеЗначение", ВыбранноеЗначение)), "Save текущую настройку?",
				QuestionDialogMode.YesNo, , DialogReturnCode.Yes);
			Return;
		EndIf;

		ТекущаяНастройкаОбработкаВыбораФрагмент(ВыбранноеЗначение);

	EndIf;
EndProcedure

&AtClient
Procedure ТекущаяНастройкаОбработкаВыбораЗавершение(РезультатВопроса, AdditionalParameters) Export

	ВыбранноеЗначение = AdditionalParameters.ВыбранноеЗначение;
	If РезультатВопроса = DialogReturnCode.Yes Then
		СохранитьНастройку();
	EndIf;

	ТекущаяНастройкаОбработкаВыбораФрагмент(ВыбранноеЗначение);

EndProcedure

&AtClient
Procedure ТекущаяНастройкаОбработкаВыбораФрагмент(Val ВыбранноеЗначение)

	ТекущаяНастройка = ВыбранноеЗначение;
	УстановитьИмяНастройки();

	ЗагрузитьНастройку();

EndProcedure

&AtClient
Procedure ТекущаяНастройкаПриИзменении(Item)
	ThisForm.Modified = True;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// ИНИЦИАЛИЗАЦИЯ МОДУЛЬНЫХ ПЕРЕМЕННЫХ

мИспользоватьНастройки = True;

//Attributes настройки и значения по умолчанию.
мНастройка = New Structure("");

//мНастройка.<Name реквизита> = <Value реквизита>;

мТипыОбрабатываемыхОбъектов = "Document";