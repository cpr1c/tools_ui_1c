&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Var DetailsDataObject;

	AttributeObject = FormAttributeToValue("Report");
	DetailsFormName = AttributeObject.Metadata().FullName() + ".Form.DetailsForm";

	StandardProcessing = False;
	If Parameters.Details <> Undefined Then
		DataCompositionSchema = GetFromTempStorage(Parameters.DataCompositionSchemaURL);
		ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, UUID);
		AvailableSettingsSource = New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL);
		Report.SettingsComposer.Initialize(AvailableSettingsSource);
		DetailsDataObject = GetFromTempStorage(Parameters.Details.Data);
		DetailProcessing = New DataCompositionDetailsProcess(DetailsDataObject,
			AvailableSettingsSource);
		UsedSettings = DetailProcessing.ApplySettings(Parameters.Details.ID,
			Parameters.Details.UsedSettings);
		If TypeOf(UsedSettings) = Type("DataCompositionSettings") Then
			Report.SettingsComposer.LoadSettings(UsedSettings);
		ElsIf TypeOf(UsedSettings) = Type("DataCompositionUserSettings") Then
			Report.SettingsComposer.LoadSettings(DetailsDataObject.Settings);
			Report.SettingsComposer.LoadUserSettings(UsedSettings);
		EndIf;

		ExecuteAtServer(DataCompositionSchema);
	EndIf;
EndProcedure

&AtServer
Procedure ExecuteAtServer(DataCompositionSchema_)
	Var DetailsDataObject;

	Result.Clear();

	DataCompositionSchema = DataCompositionSchema_;
	If DataCompositionSchema = Undefined Then
		DataCompositionSchema = GetFromTempStorage(ExecutedReportSchemaURL);
	EndIf;

	DataCompositionTemplateComposer = New DataCompositionTemplateComposer;
	DataCompositionTemplate = DataCompositionTemplateComposer.Execute(DataCompositionSchema,
		Report.SettingsComposer.GetSettings(), DetailsDataObject);

	DataCompositionProcessor = New DataCompositionProcessor;
	DataCompositionProcessor.Initialize(DataCompositionTemplate, , DetailsDataObject);

	ReportResultOutputProcessor = New DataCompositionResultSpreadsheetDocumentOutputProcessor;
	ReportResultOutputProcessor.SetDocument(Result);
	ReportResultOutputProcessor.BeginOutput();
	ReportResultOutputProcessor.Put(DataCompositionProcessor);
	ReportResultOutputProcessor.EndOutput();

	DetailsDataURL = PutToTempStorage(DetailsDataObject, UUID);
EndProcedure
&AtClient
Procedure ResultDetailProcessing(Item, Details, StandardProcessing, AdditionalParameters)
	       StandardProcessing = False;

	DetailProcessing = New DataCompositionDetailsProcess(DetailsDataURL,
		New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
	DetailProcessing.ShowActionChoice(New NotifyDescription("ResultDetailProcessingEnd1",
		ThisForm, New Structure("Details", Details)), Details, , , , );
EndProcedure
&AtClient
Procedure ResultDetailProcessingEnd1(ChosenAction, ChosenActionParameter,
	AdditionalParameters) Export

	Details = AdditionalParameters.Details;
	If ChosenAction = DataCompositionDetailsProcessingAction.None Then
	ElsIf ChosenAction = DataCompositionDetailsProcessingAction.OpenValue Then
		ShowValue( , ChosenActionParameter);
	Else
		OpenForm(DetailsFormName, New Structure("Details,DataCompositionSchemaURL",
			New DataCompositionDetailsProcessDescription(DetailsDataURL, Details,
			ChosenActionParameter), ExecutedReportSchemaURL), , True);
	EndIf;

EndProcedure

&AtClient
Procedure ChangeVariant(Command)
	ПараметрыФормы=New Structure("Variant, ExecutedReportSchemaURL", Report.SettingsComposer.Settings,
		ExecutedReportSchemaURL);

	OnCloseNotifyDescription=New NotifyDescription("ChangeVariantEnd", ThisObject);
	OpenForm("Report.UT_ReportsConsole.Form.VariantForm", ПараметрыФормы, ThisObject, , , ,
		OnCloseNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure ChangeVariantEnd(Result, AdditionalParameters) Export
	If Result <> True Then
		Return;
	EndIf;
	
//		UserSettings = Report.SettingsComposer.UserSettings;
//		Report.SettingsComposer.LoadSettings(FORM.Report.SettingsComposer.Settings);
//		Report.SettingsComposer.LoadUserSettings(UserSettings);
EndProcedure

&AtClient
Procedure Generate(Command)
	ExecuteAtServer(Undefined);
EndProcedure