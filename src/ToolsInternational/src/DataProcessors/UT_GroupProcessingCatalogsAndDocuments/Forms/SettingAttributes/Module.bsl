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
Procedure ProcessObject(Reference, SequenceNumberObject, ParametersWriteObjects)
	//RowTP=
	//
	Object = Reference.GetObject();
	If ProcessTabularParts Then
		RowTP=Object[FoundObjects[SequenceNumberObject].T_TP][FoundObjects[SequenceNumberObject].T_LineNumber
			- 1];
	EndIf;

	For Each Attribute In Attributes Do
		If Attribute.Choose Then
			If Attribute.AttributeTP Then
				RowTP[Attribute.Attribute] = Attribute.Value;
			Else
				Object[Attribute.Attribute] = Attribute.Value;
			EndIf;
		EndIf;
	EndDo;

//		Object.Write();
	If UT_Common.WriteObjectToDB(Object, ParametersWriteObjects) Then
		UT_CommonClientServer.MessageToUser(StrTemplate(Nstr("ru = 'Объект %1 УСПЕХ!!!';en = 'Object %1 SUCCESS!!!'"), Object));
	EndIf;

EndProcedure // ProcessObject()


// Performs object processing.
//
// Parameters:
//  None.
//
&AtClient
Function ExecuteProcessing(ParametersWriteObjects) Export

	Indicator = GetProcessIndicator(FoundObjects.Count());
	For IndexOf = 0 To FoundObjects.Count() - 1 Do
		ProcessIndicator(Indicator, IndexOf + 1);

		СтрокаНайденныхОбъектов=FoundObjects.Get(IndexOf);

		If СтрокаНайденныхОбъектов.Choose Then//

			ProcessObject(СтрокаНайденныхОбъектов.Object, IndexOf, ParametersWriteObjects);
		EndIf;
	EndDo;

	If IndexOf > 0 Then
		//NotifyChanged(Type(SearchObject.Type + "Reference." + SearchObject.Name));
	EndIf;

	Return IndexOf;
EndFunction // ExecuteProcessing()

// Сохраняет значения реквизитов формы.
//
// Parameters:
//  None.
//
&AtClient
Procedure SaveSetting() Export

	If IsBlankString(CurrentSettingRepresentation) Then
		ShowMessageBox( ,
			Nstr("ru = 'Задайте имя новой настройки для сохранения или выберите существующую настройку для перезаписи.';en = 'Specify a name for the new setting to save, or select an existing setting to overwrite.'"));
	EndIf;

	NewSetting = New Structure;
	NewSetting.Insert("Processing", CurrentSettingRepresentation);
	NewSetting.Insert("Other", New Structure);
	
	//@skip-warning
	AttributesForSaving = GetArrayOfAttributes();

	For Each AttributeSetting In mSetting Do
		Execute ("NewSetting.Other.Insert(String(AttributeSetting.Key), " + String(AttributeSetting.Key)
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
			NewLine.Setting.Add(NewSetting);

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
			ТекНастройка.Setting.Add(NewSetting);
		Else
			ТекНастройка.Setting[0].Value = NewSetting;
		EndIf;
	EndIf;

	CurrentSetting = NewSetting;
	ThisForm.Modified = False;
EndProcedure // SaveSetting()

&AtServer
Function GetArrayOfAttributes()
	ArrayAttributes = New Array;
	For Each Row In Attributes Do
		If Not Row.Choose Then
			Continue;
		EndIf;

		StructureAttribute = New Structure;
		StructureAttribute.Insert("Choose", Row.Choose);
		StructureAttribute.Insert("Attribute", Row.Attribute);
		StructureAttribute.Insert("ID", Row.ID);
		StructureAttribute.Insert("Type", Row.Type);
		StructureAttribute.Insert("Value", Row.Value);

		ArrayAttributes.Add(StructureAttribute);
	EndDo;

	Return ArrayAttributes;
EndFunction

&AtServer
Procedure LoadAttributesFromArray(ArrayAttributes)
	TableAttributes = FormAttributeToValue("Attributes");
	
	//Перед установкой очистим существующие установки
	For Each СтрокаТаблицы In TableAttributes Do
		СтрокаТаблицы.Choose = False;
		СтрокаТаблицы.Value = СтрокаТаблицы.Type.AdjustValue();
	EndDo;

	For Each Стр In ArrayAttributes Do
		If Not Стр.Choose Then
			Continue;
		EndIf;

		СтруктураПоиска = New Structure;
		СтруктураПоиска.Insert("Attribute", Стр.Attribute);

		МассивСтрок = TableAttributes.FindRows(СтруктураПоиска);
		If МассивСтрок.Count() = 0 Then
			Continue;
		EndIf;

		ТекСтр = МассивСтрок[0];
		FillPropertyValues(ТекСтр, Стр);
	EndDo;

	ValueToFormAttribute(TableAttributes, "Attributes");
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
		If Not CurrentSetting.Other = Undefined Then
			mSetting = CurrentSetting.Other;
		EndIf;
	EndIf;

	AttributesForSaving = Undefined;

	For Each AttributeSetting In mSetting Do
		//@skip-warning
		Value = mSetting[AttributeSetting.Key];
		Execute (String(AttributeSetting.Key) + " = Value;");
	EndDo;

	If AttributesForSaving <> Undefined And AttributesForSaving.Count() Then
		LoadAttributesFromArray(AttributesForSaving);
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
//  NumberOfPasses - Number - максимальное значение счетчика;
//  ProcessRepresentation - String, "Выполнено" - отображаемое название процесса;
//  InternalCounter - Boolean, *True - использовать внутренний счетчик с начальным значением 1,
//                    иначе нужно будет передавать значение счетчика при каждом вызове обновления индикатора;
//  NumberOfUpdates - Number, *100 - всего количество обновлений индикатора;
//  ЛиВыводитьВремя - Boolean, *True - выводить приблизительное время до окончания процесса;
//  AllowBreaking - Boolean, *True - разрешает пользователю прерывать процесс.
//
// Возвращаемое значение:
//  Structure - которую потом нужно будет передавать в метод ЛксProcessIndicator.
//
&AtClient
Function GetProcessIndicator(NumberOfPasses, ProcessRepresentation = "Выполнено", InternalCounter = True,
	NumberOfUpdates = 100, ЛиВыводитьВремя = True, AllowBreaking = True) Export

	Indicator = New Structure;
	Indicator.Insert("NumberOfPasses", NumberOfPasses);
	Indicator.Insert("ProcessStartDate", CurrentDate());
	Indicator.Insert("ProcessRepresentation", ProcessRepresentation);
	Indicator.Insert("ЛиВыводитьВремя", ЛиВыводитьВремя);
	Indicator.Insert("AllowBreaking", AllowBreaking);
	Indicator.Insert("InternalCounter", InternalCounter);
	Indicator.Insert("Step", NumberOfPasses / NumberOfUpdates);
	Indicator.Insert("NextCounter", 0);
	Indicator.Insert("Counter", 0);
	Return Indicator;

EndFunction // ЛксGetProcessIndicator()

// Checks and updates the indicator. Must be called on each pass of the indicated loop.
//
// Parameters:
//  Indicator   -Structure - indicator obtained by the method ЛксGetProcessIndicator;
//  Counter     - Number - external loop counter, used when InternalCounter = False.
//
&AtClient
Procedure ProcessIndicator(Indicator, Counter = 0) Export

	If Indicator.InternalCounter Then
		Indicator.Counter = Indicator.Counter + 1;
		Counter = Indicator.Counter;
	EndIf;
	If Indicator.AllowBreaking Then
		UserInterruptProcessing();
	EndIf;

	If Counter > Indicator.NextCounter Then
		Indicator.NextCounter = Int(Counter + Indicator.Step);
		If Indicator.ЛиВыводитьВремя Then
			TimePassed = CurrentDate() - Indicator.ProcessStartDate;
			Remaining = TimePassed * (Indicator.NumberOfPasses / Counter - 1);
			Часов = Int(Remaining / 3600);
			Remaining = Remaining - (Часов * 3600);
			Minutes = Int(Remaining / 60);
			Seconds = Int(Int(Remaining - (Minutes * 60)));
			TimeRemaining = Format(Часов, "ЧЦ=2; ЧН=00; ЧВН=") + ":" + Format(Minutes, "ЧЦ=2; ЧН=00; ЧВН=") + ":"
				+ Format(Seconds, "ЧЦ=2; ЧН=00; ЧВН=");
			TextRemaining = "Осталось: ~" + TimeRemaining;
		Else
			TextRemaining = "";
		EndIf;

		If Indicator.NumberOfPasses > 0 Then
			TextStates = TextRemaining;
		Else
			TextStates = "";
		EndIf;

		Status(Indicator.ProcessRepresentation, Counter / Indicator.NumberOfPasses * 100, TextStates);
	EndIf;

	If Counter = Indicator.NumberOfPasses Then
		Status(Indicator.ProcessRepresentation, 100, TextStates);
	EndIf;

EndProcedure // ЛксProcessIndicator()

// Allows you to create a description of types based on the string representation of the type.
//
// Parameters: 
//  TypeString     - String representation of type.
//
// Return value:
//  LongDesc types.
//
&AtServer
Function DescriptionType(TypeString) Export

	ArrayTypes = New Array;
	ArrayTypes.Add(Type(TypeString));
	TypeDescription = New TypeDescription(ArrayTypes);

	Return TypeDescription;

EndFunction // вDescriptionType()

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
		ProcessTabularParts = Parameters.ProcessTabularParts;
	EndIf;
	If Parameters.Property("TableAttributes") Then
		TableAttributes = Parameters.TableAttributes;
		TableAttributes.Sort("ThisTP");
		For Each Attribute In Parameters.TableAttributes Do
			NewLine = Attributes.Add();
			NewLine.Attribute = Attribute.Name;//?(IsBlankString(Attribute.Synonym), Attribute.Name, Attribute.Synonym);
			NewLine.ID = Attribute.Presentation;
			NewLine.Type = Attribute.Type;
			NewLine.Value = NewLine.Type.AdjustValue();
			NewLine.AttributeTP = Attribute.ThisTP;
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
				New Structure("SelectedValue", SelectedValue)), Nstr("ru = 'Сохранить текущую настройку?';en = 'Save current setting?'"),
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