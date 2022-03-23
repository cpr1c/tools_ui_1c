//Sign of using settings
&AtClient
Var mUseSettings Export;

//Types of objects for which processing can be used.
//To default for everyone.
&AtClient
Var mTypesOfProcessedObjects Export;

&AtClient
Var mSetting;

////////////////////////////////////////////////////////////////////////////////
// AUXILIARY PROCEDURES AND FUNCTIONS

// Performs object processing.
//
// Parameters:
//  ProcessedObject                 - processed object.
//  SequenceNumberObject - serial number of the processed object.
//
&AtServer
Procedure ProcessObject(Reference, SequenceNumberObject, ParametersWriteObjects)

	ProcessedObject = Reference.GetObject();
	If UT_Common.WriteObjectToDB(ProcessedObject, ParametersWriteObjects, "SetDeletionMark") Then
		UT_CommonClientServer.MessageToUser(StrTemplate(Nstr("ru = 'Объект %1 УСПЕХ!!!';en = 'Object %1 SUCCESS!!!'"), ProcessedObject));
	EndIf;
//	ProcessedObject.SetDeletionMark(DeletionMark);

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

		RowFoundObjectValue = FoundObjects.Get(IndexOf).Value;
		ProcessObject(RowFoundObjectValue, IndexOf, ParametersWriteObjects);
	EndDo;

	If IndexOf > 0 Then
		//NotifyChanged(Type(SearchObject.Type + "Reference." + SearchObject.Name));
	EndIf;

	Return IndexOf;
EndFunction // ExecuteProcessing()

// Stores form attribute values.
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

	For Each AttributeSetting In mSetting Do
		Execute ("NewSetting.Other.Insert(String(AttributeSetting.Key), " + String(AttributeSetting.Key)
			+ ");");
	EndDo;

	AvailableDataProcessors = ThisForm.FormOwner.AvailableDataProcessors;
	CurrentAvailableSetting = Undefined;
	For Each CurrentAvailableSetting In AvailableDataProcessors.GetItems() Do
		If CurrentAvailableSetting.GetID() = Parent Then
			Break;
		EndIf;
	EndDo;

	If CurrentSetting = Undefined Or Not CurrentSetting.Processing = CurrentSettingRepresentation Then
		If CurrentAvailableSetting <> Undefined Then
			NewLine = CurrentAvailableSetting.GetItems().Add();
			NewLine.Processing = CurrentSettingRepresentation;
			NewLine.Setting.Add(NewSetting);

			ThisForm.FormOwner.Items.AvailableDataProcessors.CurrentLine = NewLine.GetID();
		EndIf;
	EndIf;

	If CurrentAvailableSetting <> Undefined And CurrentLine > -1 Then
		For Each CurrentSettingItem In CurrentAvailableSetting.GetItems() Do
			If CurrentSettingItem.GetID() = CurrentLine Then
				Break;
			EndIf;
		EndDo;

		If CurrentSettingItem.Setting.Count() = 0 Then
			CurrentSettingItem.Setting.Add(NewSetting);
		Else
			CurrentSettingItem.Setting[0].Value = NewSetting;
		EndIf;
	EndIf;

	CurrentSetting = NewSetting;
	ThisForm.Modified = False;
EndProcedure // SaveSetting()

// Restores saved form attribute values.
//
// Parameters:
//  None.
//
&AtClient
Procedure DownloadSettings() Export

	If Items.CurrentSetting.ChoiceList.Count() = 0 Then
		SetNameSettings(Nstr("ru = 'Новая настройка';en = 'New setting'"));
	Else
		If Not CurrentSetting.Other = Undefined Then
			mSetting = CurrentSetting.Other;
		EndIf;
	EndIf;

	For Each AttributeSetting In mSetting Do
		//@skip-warning
		Value = mSetting[AttributeSetting.Key];
		Execute (String(AttributeSetting.Key) + " = Value;");
	EndDo;

EndProcedure //DownloadSettings()

// Sets the value of the "CurrentSetting" attribute by the name of the setting or arbitrarily.
//
// Parameters:
//  NameSettings   - arbitrary setting name to be set.
//
&AtClient
Procedure SetNameSettings(NameSettings = "") Export

	If IsBlankString(NameSettings) Then
		If CurrentSetting = Undefined Then
			CurrentSettingRepresentation = "";
		Else
			CurrentSettingRepresentation = CurrentSetting.Processing;
		EndIf;
	Else
		CurrentSettingRepresentation = NameSettings;
	EndIf;

EndProcedure // SetNameSettings()

// Gets a structure to indicate the progress of the loop.
//
// Parameters:
//  NumberOfPasses - Number - maximum counter value;
//  ProcessRepresentation - String, "Done" - the display name of the process;
//  InternalCounter - Boolean, *True - use internal counter with initial value 1,
//                    otherwise, you will need to pass the value of the counter each time you call to update the indicator;
//  NumberOfUpdates - Number, *100 - total number of indicator updates;
//  OutputTime - Boolean, *True - display approximate time until the end of the process;
//  AllowBreaking - Boolean, *True - allows the user to break the process.
//
// Return value:
//  Structure - which will then need to be passed to the method ProcessIndicator.
//
&AtClient
Function GetProcessIndicator(NumberOfPasses, ProcessRepresentation = "Done", InternalCounter = True,
	NumberOfUpdates = 100, OutputTime = True, AllowBreaking = True) Export

	Indicator = New Structure;
	Indicator.Insert("NumberOfPasses", NumberOfPasses);
	Indicator.Insert("ProcessStartDate", CurrentDate());
	Indicator.Insert("ProcessRepresentation", ProcessRepresentation);
	Indicator.Insert("OutputTime", OutputTime);
	Indicator.Insert("AllowBreaking", AllowBreaking);
	Indicator.Insert("InternalCounter", InternalCounter);
	Indicator.Insert("Step", NumberOfPasses / NumberOfUpdates);
	Indicator.Insert("NextCounter", 0);
	Indicator.Insert("Counter", 0);
	Return Indicator;

EndFunction // GetProcessIndicator()

// Checks and updates the indicator. Must be called on each pass of the indicated loop.
//
// Parameters:
//  Indicator   -Structure - indicator obtained by the method GetProcessIndicator;
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
		If Indicator.OutputTime Then
			TimePassed = CurrentDate() - Indicator.ProcessStartDate;
			Remaining = TimePassed * (Indicator.NumberOfPasses / Counter - 1);
			Hours = Int(Remaining / 3600);
			Remaining = Remaining - (Hours * 3600);
			Minutes = Int(Remaining / 60);
			Seconds = Int(Int(Remaining - (Minutes * 60)));
			TimeRemaining = Format(Hours, "ЧЦ=2; ЧН=00; ЧВН=") + ":" + Format(Minutes, "ЧЦ=2; ЧН=00; ЧВН=") + ":"
				+ Format(Seconds, "ЧЦ=2; ЧН=00; ЧВН=");
			TextRemaining = StrTemplate(Nstr("ru = 'Осталось: ~ %1';en = 'Remaining: ~ %1'"), TimeRemaining);
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

EndProcedure // ProcessIndicator()

////////////////////////////////////////////////////////////////////////////////
// FORM EVENT HANDLERS

&AtClient
Procedure OnOpen(Cancel)
	If mUseSettings Then
		SetNameSettings();
		DownloadSettings();
	Else
		Items.CurrentSetting.Enabled = False;
		Items.SaveSettings.Enabled = False;
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("Setting") Then
		CurrentSetting = Parameters.Setting;
	EndIf;
	If Parameters.Property("FoundObjects") Then
		FoundObjects.LoadValues(Parameters.FoundObjects);
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
	If Parameters.Property("SearchObject") Then
		SearchObject = Parameters.SearchObject;
	EndIf;

	Items.CurrentSetting.ChoiceList.Clear();
	If Parameters.Property("Settings") Then
		For Each String In Parameters.Settings Do
			Items.CurrentSetting.ChoiceList.Add(String, String.Processing);
		EndDo;
	EndIf;

	DeletionMark=True;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// EVENT HANDLERS CALLED FROM FORM ELEMENTS

&AtClient
Procedure ExecuteCommand(Command)
	ProcessedObjects = ExecuteProcessing(UT_CommonClientServer.FormWriteSettings(
		ThisObject.FormOwner));

	Message = StrTemplate(Nstr("ru = 'Обработка <%1> завершена! 
					 |Обработано объектов: %2.';en = 'Processing of <%1> completed!
					 |Objects processed: %2.'"), TrimAll(ThisForm.Title), ProcessedObjects);
	ShowMessageBox(, Message);
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

////////////////////////////////////////////////////////////////////////////////
// INITIALIZING MODULAR VARIABLES

mUseSettings = False;

//Attributes settings and defaults.
mSetting = New Structure("");

//mSetting.<Name attribute> = <Value attribute>;

mTypesOfProcessedObjects = "Catalog,Document";