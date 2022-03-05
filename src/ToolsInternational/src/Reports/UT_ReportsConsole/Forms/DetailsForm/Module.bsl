&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Var ДанныеРасшифровкиОбъект;

	РеквизитОбъект = FormAttributeToValue("Report");
	ИмяФормыРасшифровки = РеквизитОбъект.Metadata().FullName() + ".Form.ФормаРасшифровки";

	StandardProcessing = False;
	If Parameters.Details <> Undefined Then
		DataCompositionSchema = GetFromTempStorage(Parameters.АдресСхемыКомпоновкиДанных);
		АдресСхемыИсполненногоОтчета = PutToTempStorage(DataCompositionSchema, UUID);
		AvailableSettingsSource = New DataCompositionAvailableSettingsSource(АдресСхемыИсполненногоОтчета);
		Report.SettingsComposer.Initialize(AvailableSettingsSource);
		ДанныеРасшифровкиОбъект = GetFromTempStorage(Parameters.Details.Data);
		DetailProcessing = New DataCompositionDetailsProcess(ДанныеРасшифровкиОбъект,
			AvailableSettingsSource);
		UsedSettings = DetailProcessing.ApplySettings(Parameters.Details.ID,
			Parameters.Details.UsedSettings);
		If TypeOf(UsedSettings) = Type("DataCompositionSettings") Then
			Report.SettingsComposer.LoadSettings(UsedSettings);
		ElsIf TypeOf(UsedSettings) = Type("DataCompositionUserSettings") Then
			Report.SettingsComposer.LoadSettings(ДанныеРасшифровкиОбъект.Settings);
			Report.SettingsComposer.LoadUserSettings(UsedSettings);
		EndIf;

		ВыполнитьНаСервере(DataCompositionSchema);
	EndIf;
EndProcedure

&AtServer
Procedure ВыполнитьНаСервере(СхемаКомпоновкиДанных_)
	Var ДанныеРасшифровкиОбъект;

	Result.Clear();

	DataCompositionSchema = СхемаКомпоновкиДанных_;
	If DataCompositionSchema = Undefined Then
		DataCompositionSchema = GetFromTempStorage(АдресСхемыИсполненногоОтчета);
	EndIf;

	DataCompositionTemplateComposer = New DataCompositionTemplateComposer;
	DataCompositionTemplate = DataCompositionTemplateComposer.Execute(DataCompositionSchema,
		Report.SettingsComposer.GetSettings(), ДанныеРасшифровкиОбъект);

	DataCompositionProcessor = New DataCompositionProcessor;
	DataCompositionProcessor.Initialize(DataCompositionTemplate, , ДанныеРасшифровкиОбъект);

	ПроцессорВыводаРезультатаОтчета = New DataCompositionResultSpreadsheetDocumentOutputProcessor;
	ПроцессорВыводаРезультатаОтчета.SetDocument(Result);
	ПроцессорВыводаРезультатаОтчета.BeginOutput();
	ПроцессорВыводаРезультатаОтчета.Put(DataCompositionProcessor);
	ПроцессорВыводаРезультатаОтчета.EndOutput();

	АдресДанныхРасшифровки = PutToTempStorage(ДанныеРасшифровкиОбъект, UUID);
EndProcedure

&AtClient
Procedure РезультатОбработкаРасшифровки(Item, Details, StandardProcessing)
	StandardProcessing = False;

	DetailProcessing = New DataCompositionDetailsProcess(АдресДанныхРасшифровки,
		New DataCompositionAvailableSettingsSource(АдресСхемыИсполненногоОтчета));
	DetailProcessing.ShowActionChoice(New NotifyDescription("РезультатОбработкаРасшифровкиЗавершение1",
		ThisForm, New Structure("Details", Details)), Details, , , , );
EndProcedure

&AtClient
Procedure РезультатОбработкаРасшифровкиЗавершение1(ChosenAction, ПараметрВыполненногоДействия,
	AdditionalParameters) Export

	Details = AdditionalParameters.Details;
	If ChosenAction = DataCompositionDetailsProcessingAction.None Then
	ElsIf ChosenAction = DataCompositionDetailsProcessingAction.OpenValue Then
		ShowValue( , ПараметрВыполненногоДействия);
	Else
		OpenForm(ИмяФормыРасшифровки, New Structure("Details,АдресСхемыКомпоновкиДанных",
			New DataCompositionDetailsProcessDescription(АдресДанныхРасшифровки, Details,
			ПараметрВыполненногоДействия), АдресСхемыИсполненногоОтчета), , True);
	EndIf;

EndProcedure

&AtClient
Procedure ИзменитьВариант(Command)
	ПараметрыФормы=New Structure("Variant, АдресСхемыИсполненногоОтчета", Report.SettingsComposer.Settings,
		АдресСхемыИсполненногоОтчета);

	OnCloseNotifyDescription=New NotifyDescription("ИзменитьВариантЗавершение", ThisObject);
	OpenForm("Report.UT_ReportsConsole.Form.VariantForm", ПараметрыФормы, ThisObject, , , ,
		OnCloseNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure ИзменитьВариантЗавершение(Result, AdditionalParameters) Export
	If Result <> True Then
		Return;
	EndIf;
	
//		ПользовательскиеНастройки = Отчет.КомпоновщикНастроек.ПользовательскиеНастройки;
//		Отчет.КомпоновщикНастроек.ЗагрузитьНастройки(Форма.Отчет.КомпоновщикНастроек.Настройки);
//		Отчет.КомпоновщикНастроек.ЗагрузитьПользовательскиеНастройки(ПользовательскиеНастройки);
EndProcedure

&AtClient
Procedure Сформировать(Command)
	ВыполнитьНаСервере(Undefined);
EndProcedure