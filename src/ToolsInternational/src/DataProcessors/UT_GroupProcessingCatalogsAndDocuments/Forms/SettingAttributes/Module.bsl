//Sign of using settings
&AtClient
Var mUseSettings Export;

//Types of objects for which processing can be used.
//To default for everyone.
&AtClient
Var mTypesOfProcessedObjects Export;

&AtClient
Var mSetting;

&AtServer
Var ТЗНО;

////////////////////////////////////////////////////////////////////////////////
// AUXILIARY PROCEDURES AND FUNCTIONS

// Performs object processing.
//
// Parameters:
//  Object                 - processed object.
//  SequenceNumberObject - serial number of the processed object.
//
&AtServer
Procedure ОбработатьОбъект(Reference, SequenceNumberObject, ParametersWriteObjects)
	//СтрокаТЧ=
	//
	Object = Reference.GetObject();
	If ProcessTabularParts Then
		СтрокаТЧ=Object[FoundObjects[SequenceNumberObject].T_TP][FoundObjects[SequenceNumberObject].T_LineNumber
			- 1];
	EndIf;

	For Each Attribute In Attributes Do
		If Attribute.Choose Then
			If Attribute.AttributeTP Then
				СтрокаТЧ[Attribute.Attribute] = Attribute.Value;
			Else
				Object[Attribute.Attribute] = Attribute.Value;
			EndIf;
		EndIf;
	EndDo;

//		Object.Write();
	If UT_Common.WriteObjectToDB(Object, ParametersWriteObjects) Then
		UT_CommonClientServer.MessageToUser(StrTemplate("Object %1 УСПЕХ!!!", Object));
	EndIf;

EndProcedure // ОбработатьОбъект()


// Выполняет обработку объектов.
//
// Parameters:
//  None.
//
&AtClient
Function ExecuteProcessing(ParametersWriteObjects) Export

	Indicator = ПолучитьИндикаторПроцесса(FoundObjects.Count());
	For IndexOf = 0 To FoundObjects.Count() - 1 Do
		ОбработатьИндикатор(Indicator, IndexOf + 1);

		СтрокаНайденныхОбъектов=FoundObjects.Get(IndexOf);

		If СтрокаНайденныхОбъектов.Choose Then//

			ОбработатьОбъект(СтрокаНайденныхОбъектов.Object, IndexOf, ParametersWriteObjects);
		EndIf;
	EndDo;

	If IndexOf > 0 Then
		//NotifyChanged(Type(SearchObject.Type + "Reference." + SearchObject.Name));
	EndIf;

	Return IndexOf;
EndFunction // вВыполнитьОбработку()

// Сохраняет значения реквизитов формы.
//
// Parameters:
//  None.
//
&AtClient
Procedure SaveSetting() Export

	If IsBlankString(CurrentSettingRepresentation) Then
		ShowMessageBox( ,
			"Задайте имя новой настройки для сохранения или выберите существующую настройку для перезаписи.");
	EndIf;

	НоваяНастройка = New Structure;
	НоваяНастройка.Insert("Processing", CurrentSettingRepresentation);
	НоваяНастройка.Insert("Прочее", New Structure);
	
	//@skip-warning
	AttributesForSaving = ПолучитьМассивРеквизитов();

	For Each РеквизитНастройки In mSetting Do
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

	If CurrentSetting = Undefined Or Not CurrentSetting.Processing = CurrentSettingRepresentation Then
		If ТекущаяДоступнаяНастройка <> Undefined Then
			NewLine = ТекущаяДоступнаяНастройка.GetItems().Add();
			NewLine.Processing = CurrentSettingRepresentation;
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

	CurrentSetting = НоваяНастройка;
	ThisForm.Modified = False;
EndProcedure // SaveSetting()

&AtServer
Function ПолучитьМассивРеквизитов()
	МассивРеквизитов = New Array;
	For Each Стр In Attributes Do
		If Not Стр.Choose Then
			Continue;
		EndIf;

		СтруктураРеквизита = New Structure;
		СтруктураРеквизита.Insert("Choose", Стр.Choose);
		СтруктураРеквизита.Insert("Attribute", Стр.Attribute);
		СтруктураРеквизита.Insert("ID", Стр.ID);
		СтруктураРеквизита.Insert("Type", Стр.Type);
		СтруктураРеквизита.Insert("Value", Стр.Value);

		МассивРеквизитов.Add(СтруктураРеквизита);
	EndDo;

	Return МассивРеквизитов;
EndFunction

&AtServer
Procedure ЗагрузитьРеквизитыИзМассива(МассивРеквизитов)
	ТЗ = FormAttributeToValue("Attributes");
	
	//Перед установкой очистим существующие установки
	For Each СтрокаТаблицы In ТЗ Do
		СтрокаТаблицы.Choose=False;
		СтрокаТаблицы.Value=СтрокаТаблицы.Type.AdjustValue();
	EndDo;

	For Each Стр In МассивРеквизитов Do
		If Not Стр.Choose Then
			Continue;
		EndIf;

		СтруктураПоиска = New Structure;
		СтруктураПоиска.Insert("Attribute", Стр.Attribute);

		МассивСтрок = ТЗ.FindRows(СтруктураПоиска);
		If МассивСтрок.Count() = 0 Then
			Continue;
		EndIf;

		ТекСтр = МассивСтрок[0];
		FillPropertyValues(ТекСтр, Стр);
	EndDo;

	ValueToFormAttribute(ТЗ, "Attributes");
EndProcedure

// Восстанавливает сохраненные значения реквизитов формы.
//
// Parameters:
//  None.
//
&AtClient
Procedure DownloadSettings() Export

	If Items.CurrentSettingRepresentation.ChoiceList.Count() = 0 Then
		SetNameSettings("Новая настройка");
	Else
		If Not CurrentSetting.Прочее = Undefined Then
			mSetting = CurrentSetting.Прочее;
		EndIf;
	EndIf;

	AttributesForSaving = Undefined;

	For Each РеквизитНастройки In mSetting Do
		//@skip-warning
		Value = mSetting[РеквизитНастройки.Key];
		Execute (String(РеквизитНастройки.Key) + " = Value;");
	EndDo;

	If AttributesForSaving <> Undefined And AttributesForSaving.Count() Then
		ЗагрузитьРеквизитыИзМассива(AttributesForSaving);
	EndIf;

EndProcedure //вDownloadSettings()

// Устанавливает значение реквизита "CurrentSetting" по имени настройки или произвольно.
//
// Parameters:
//  ИмяНастройки   - произвольное имя настройки, которое необходимо установить.
//
&AtClient
Procedure SetNameSettings(ИмяНастройки = "") Export

	If IsBlankString(ИмяНастройки) Then
		If CurrentSetting = Undefined Then
			CurrentSettingRepresentation = "";
		Else
			CurrentSettingRepresentation = CurrentSetting.Processing;
		EndIf;
	Else
		CurrentSettingRepresentation = ИмяНастройки;
	EndIf;

EndProcedure // SetNameSettings()

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
//  Indicator   - Structure - индикатора, полученная методом ЛксПолучитьИндикаторПроцесса;
//  Счетчик     - Number - внешний счетчик цикла, используется при ВнутреннийСчетчик = False.
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

// Позволяет создать описание типов на основании строкового представления типа.
//
// Parameters: 
//  ТипСтрокой     - Строковое представление типа.
//
// Возвращаемое значение:
//  LongDesc типов.
//
&AtServer
Function ОписаниеТипа(ТипСтрокой) Export

	МассивТипов = New Array;
	МассивТипов.Add(Type(ТипСтрокой));
	TypeDescription = New TypeDescription(МассивТипов);

	Return TypeDescription;

EndFunction // вОписаниеТипа()

////////////////////////////////////////////////////////////////////////////////
// FORM EVENT HANDLERS

&AtClient
Procedure OnOpen(Cancel)
	If mUseSettings Then
		SetNameSettings();
		DownloadSettings();
	Else
		Items.CurrentSettingRepresentation.Enabled = False;
		Items.SaveSettings.Enabled = False;
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("Setting") Then
		CurrentSetting = Parameters.Setting;
	EndIf;
	If Parameters.Property("FoundObjectsTP") Then

		ТЗНО=Parameters.FoundObjectsTP.Unload();

		FoundObjects.Load(ТЗНО);
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

	Items.CurrentSettingRepresentation.ChoiceList.Clear();
	If Parameters.Property("Settings") Then
		For Each String In Parameters.Settings Do
			Items.CurrentSettingRepresentation.ChoiceList.Add(String, String.Processing);
		EndDo;
	EndIf;
	If Parameters.Property("ProcessTabularParts") Then
		ProcessTabularParts=Parameters.ProcessTabularParts;
	EndIf;
	If Parameters.Property("ТаблицаРеквизитов") Then
		ТАбРеквизитов = Parameters.ТаблицаРеквизитов;
		ТАбРеквизитов.Sort("ЭтоТЧ");
		For Each Attribute In Parameters.ТаблицаРеквизитов Do
			NewLine = Attributes.Add();
			NewLine.Attribute      = Attribute.Name;//?(IsBlankString(Attribute.Synonym), Attribute.Name, Attribute.Synonym);
			NewLine.ID = Attribute.Presentation;
			NewLine.Type           = Attribute.Type;
			NewLine.Value      = NewLine.Type.AdjustValue();
			NewLine.AttributeTP	  = Attribute.ЭтоТЧ;
		EndDo;

	EndIf;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// EVENT HANDLERS CALLED FROM FORM ELEMENTS

&AtClient
Procedure ExecuteCommand(Command)
	ProcessedObjects = ExecuteProcessing(UT_CommonClientServer.FormWriteSettings(
		ThisObject.FormOwner));

	ShowMessageBox( , "Processing <" + TrimAll(ThisForm.Title) + "> завершена!
																		   |Обработано объектов: " + ProcessedObjects
		+ ".");
EndProcedure

&AtClient
Procedure SaveSettings(Command)
	SaveSetting();
EndProcedure

&AtClient
Procedure CurrentSettingChoiceProcessing(Item, SelectedValue, StandardProcessing)
	StandardProcessing = False;

	If Not CurrentSetting = SelectedValue Then

		If ThisForm.Modified Then
			ShowQueryBox(New NotifyDescription("CurrentSettingChoiceProcessingEnd", ThisForm,
				New Structure("SelectedValue", SelectedValue)), "Save текущую настройку?",
				QuestionDialogMode.YesNo, , DialogReturnCode.Yes);
			Return;
		EndIf;

		CurrentSettingChoiceProcessingFragment(SelectedValue);

	EndIf;
EndProcedure

&AtClient
Procedure CurrentSettingChoiceProcessingEnd(ResultQuestion, AdditionalParameters) Export

	SelectedValue = AdditionalParameters.SelectedValue;
	If ResultQuestion = DialogReturnCode.Yes Then
		SaveSetting();
	EndIf;

	CurrentSettingChoiceProcessingFragment(SelectedValue);

EndProcedure

&AtClient
Procedure CurrentSettingChoiceProcessingFragment(Val SelectedValue)

	CurrentSetting = SelectedValue;
	SetNameSettings();

	DownloadSettings();

EndProcedure

&AtClient
Procedure CurrentSettingOnChange(Item)
	ThisForm.Modified = True;
EndProcedure

&AtClient
Procedure CooseAll(Command)
	SelectItems(True);
EndProcedure

&AtClient
Procedure CancelChoice(Command)
	SelectItems(False);
EndProcedure

&AtServer
Procedure SelectItems(Selection)
	For Each Row In Attributes Do
		Row.Choose = Selection;
	EndDo;
EndProcedure

&AtClient
Procedure AttributesValueClearing(Item, StandardProcessing)
	Items.AttributesValue.ChooseType = True;
EndProcedure

&AtClient
Procedure AttributesValueOnChange(Item)
	Items.Attributes.CurrentData.Choose = True;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// INITIALIZING MODULAR VARIABLES

mUseSettings = True;

//Attributes settings and defaults.
mSetting = New Structure("AttributesForSaving");

//mSetting.<Name attribute> = <Value attribute>;

mTypesOfProcessedObjects = "Catalog,Document";