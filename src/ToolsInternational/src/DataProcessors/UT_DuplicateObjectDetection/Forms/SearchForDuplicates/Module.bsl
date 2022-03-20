///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, 1C-Soft LLC
// All Rights reserved. This application and supporting materials are provided under the terms of 
// Attribution 4.0 International license (CC BY 4.0)
// The license text is available at:
// https://creativecommons.org/licenses/by/4.0/legalcode
// Translated by Neti Company
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	SetColorsAndConditionalAppearance();

	Try
		FuzzySearch = UT_Common.AttachAddInFromTemplate("FuzzyStringMatchExtension",
			"CommonTemplate.UT_StringSearchComponent");
	Except
		FuzzySearch=Undefined;
	EndTry;
	If FuzzySearch <> Undefined Then 
		FuzzySearch1 = True;
	EndIf;

	FormSettings = Common.CommonSettingsStorageLoad(FormName, "");
	If FormSettings = Undefined Then
		FormSettings = New Structure;
		FormSettings.Insert("ConsiderAppliedRules", True);
		FormSettings.Insert("DuplicatesSearchArea",        "");
		FormSettings.Insert("DCSettings",                Undefined);
		FormSettings.Insert("SearchRules",              Undefined);
	EndIf;
	FillPropertyValues(FormSettings, Parameters);

	OnCreateAtServerDataInitialization(FormSettings);
	InitializeFilterComposerAndRules(FormSettings); 
	
	// Permanent Interface
	StatePresentation = Items.NoSearchPerformed.StatePresentation;
	StatePresentation.Visible = True;
	StatePresentation.Text = NStr("ru = 'Поиск дублей не выполнялся. 
	                                        |Задайте условия отбора и сравнения и нажмите ""Найти дубли"".'; 
	                                        |en = 'You did not run duplicate search yet.
	                                        |Set filter criteria and select Find duplicates.'");
	StatePresentation.Picture = Items.Warning32.Picture;
	
	StatePresentation = Items.PerformSearch.StatePresentation;
	StatePresentation.Visible = True;
	StatePresentation.Picture = Items.TimeConsumingOperation48.Picture;
	
	StatePresentation = Items.Deletion.StatePresentation;
	StatePresentation.Visible = True;
	StatePresentation.Picture = Items.TimeConsumingOperation48.Picture;
	
	StatePresentation = Items.DuplicatesNotFound.StatePresentation;
	StatePresentation.Visible = True;
	StatePresentation.Text = NStr("ru = 'Не обнаружено дублей по указанным параметрам.
	                                        |Измените условия отбора и сравнения, нажмите ""Найти дубли""'; 
	                                        |en = 'No duplicates found by the specified criteria.
	                                        |Edit the filter criteria and select Find duplicates.'");
	StatePresentation.Picture = Items.Warning32.Picture;
	
	// Autosaving settings
	SavedInSettingsDataModified = True;
	
	// Initialization of step-by-step wizard steps.
	InitializeStepByStepWizardSettings();
	
	// 1. No search executed.
	SearchStep = AddWizardStep(Items.NoSearchPerformedStep);
	SearchStep.BackButton.Visible = False;
	SearchStep.NextButton.Title = NStr("ru = 'Найти дубли >'; en = 'Find duplicates >'");
	SearchStep.NextButton.ToolTip = NStr("ru = 'Найти дубли по указанным критериям'; en = 'Find duplicates by the specified criteria.'");
	SearchStep.CancelButton.Title = NStr("ru = 'Закрыть'; en = 'Close'");
	SearchStep.CancelButton.ToolTip = NStr("ru = 'Отказаться от поиска и замены дублей'; en = 'Close the form without duplicate search.'");
	
	// 2. Time-consuming search.
	Step = AddWizardStep(Items.PerformSearchStep);
	Step.BackButton.Visible = False;
	Step.NextButton.Visible = False;
	Step.CancelButton.Title = NStr("ru = 'Прервать'; en = 'Cancel'");
	Step.CancelButton.ToolTip = NStr("ru = 'Прервать поиск дублей'; en = 'Cancel duplicate search.'");
	
	// 3. Processing search results and selecting main items.
	Step = AddWizardStep(Items.MainItemSelectionStep);
	Step.BackButton.Visible = False;
	Step.NextButton.Title = NStr("ru = 'Удалить дубли >'; en = 'Delete duplicates >'");
	Step.NextButton.ToolTip = NStr("ru = 'Удалить дубли'; en = 'Delete found duplicates.'");
	Step.CancelButton.Title = NStr("ru = 'Закрыть'; en = 'Close'");
	Step.CancelButton.ToolTip = NStr("ru = 'Отказаться от поиска и замены дублей'; en = 'Close the form without duplicate search.'");
	
	// 4. Time-consuming deletion of duplicates.
	Step = AddWizardStep(Items.DeletionStep);
	Step.BackButton.Visible = False;
	Step.NextButton.Visible = False;
	Step.CancelButton.Title = NStr("ru = 'Прервать'; en = 'Cancel'");
	Step.CancelButton.ToolTip = NStr("ru = 'Прервать удаление дублей'; en = 'Cancel duplicate deletion.'");
	
	// 5. Successful deletion.
	Step = AddWizardStep(Items.SuccessfulDeletionStep);
	Step.BackButton.Title = NStr("ru = '< Новый поиск'; en = '< New search'");
	Step.BackButton.ToolTip = NStr("ru = 'Начать новый поиск с другими параметрами'; en = 'Start a new duplicate search.'");
	Step.NextButton.Visible = False;
	Step.CancelButton.DefaultButton = True;
	Step.CancelButton.Title = NStr("ru = 'Закрыть'; en = 'Close'");
	
	// 6. Incomplete deletion.
	Step = AddWizardStep(Items.UnsuccessfulReplacementsStep);
	Step.BackButton.Visible = False;
	Step.NextButton.Title = NStr("ru = 'Повторить удаление >'; en = 'Delete again >'");
	Step.NextButton.ToolTip = NStr("ru = 'Удалить дубли'; en = 'Delete found duplicates.'");
	Step.CancelButton.Title = NStr("ru = 'Закрыть'; en = 'Close'");
	
	// 7. No duplicates found.
	Step = AddWizardStep(Items.DuplicatesNotFoundStep);
	Step.BackButton.Visible = False;
	Step.NextButton.Title = NStr("ru = 'Найти дубли >'; en = 'Find duplicates >'");
	Step.NextButton.ToolTip = NStr("ru = 'Найти дубли по указанным критериям'; en = 'Find duplicates by the specified criteria.'");
	Step.CancelButton.Title = NStr("ru = 'Закрыть'; en = 'Close'");
	
	// 8. Runtime errors.
	Step = AddWizardStep(Items.ErrorOccurredStep);
	Step.BackButton.Visible = False;
	Step.NextButton.Visible = False;
	Step.CancelButton.Title = NStr("ru = 'Закрыть'; en = 'Close'");
	
	// Updating form items.
	WizardSettings.CurrentStep = SearchStep;
	SetVisibilityAvailability(ThisObject);

	UT_Forms.CreateWriteParametersAttributesFormOnCreateAtServer(ThisObject,
		Items.WritingParametersGroup);
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.WizardActionsPanel);
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	// Running wizard.
	OnActivateWizardStep();
	
EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, WarningText, StandardProcessing)
	If Not WizardSettings.ShowDialogBeforeClose Then
		Return;
	EndIf;
	If Exit Then
		Return;
	EndIf;
	
	Cancel = True;
	CurrentPage = Items.WizardSteps.CurrentPage;
	If CurrentPage = Items.PerformSearchStep Then
		QuestionText = NStr("ru = 'Прервать поиск дублей и закрыть форму?'; en = 'Do you want to stop search and close the form?'");
	ElsIf CurrentPage = Items.DeletionStep Then
		QuestionText = NStr("ru = 'Прервать удаление дублей и закрыть форму?'; en = 'Do you want to stop deletion and close the form?'");
	EndIf;
	
	Buttons = New ValueList;
	Buttons.Add(DialogReturnCode.Abort, NStr("ru = 'Прервать'; en = 'Cancel operation'"));
	Buttons.Add(DialogReturnCode.No,      NStr("ru = 'Не прерывать'; en = 'Continue operation'"));
	
	Handler = New NotifyDescription("AfterConfirmCancelJob", ThisObject);
	
	ShowQueryBox(Handler, QuestionText, Buttons, , DialogReturnCode.No);
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure DuplicatesSearchAreaStartChoice(Item, ChoiceData, StandardProcessing)
	StandardProcessing = False;
	
	Name = FullFormName("DuplicatesSearchArea");
	
	FormParameters = New Structure;
	FormParameters.Insert("SettingsAddress", SettingsAddress);
	FormParameters.Insert("DuplicatesSearchArea", DuplicatesSearchArea);
	
	Handler = New NotifyDescription("DuplicatesSearchAreaSelectionCompletion", ThisObject);
	
	OpenForm(Name, FormParameters, ThisObject, , , , Handler);
EndProcedure

&AtClient
Procedure DuplicatesSearchAreaSelectionCompletion(Result, ExecutionParameters) Export
	If TypeOf(Result) <> Type("String") Then
		Return;
	EndIf;
	
	DuplicatesSearchArea = Result;
	InitializeFilterComposerAndRules(Undefined);
	GoToWizardStep(Items.NoSearchPerformedStep);
EndProcedure

&AtClient
Procedure DuplicatesSearchAreaOnChange(Item)
	InitializeFilterComposerAndRules(Undefined);
	GoToWizardStep(Items.NoSearchPerformedStep);
EndProcedure

&AtClient
Procedure DuplicatesSearchAreaClearing(Item, StandardProcessing)

	StandardProcessing = False;
	
EndProcedure

&AtClient
Procedure AllUnprocessedItemsUsageInstancesClick(Item)

	ShowUsageInstances(UnprocessedDuplicates);
	
EndProcedure

&AtClient
Procedure AllUsageInstancesClick(Item)

	ShowUsageInstances(FoundDuplicates);

EndProcedure

&AtClient
Procedure FilterRulesPresentationStartChoice(Item, ChoiceData, StandardProcessing)
	StandardProcessing = False;
	
	AttachIdleHandler("OnStartSelectFilterRules", 0.1, True);
EndProcedure

&AtClient
Procedure OnStartSelectFilterRules()
	
	Name = FullFormName("FilterRules");
	
	ListItem = Items.DuplicatesSearchArea.ChoiceList.FindByValue(DuplicatesSearchArea);
	If ListItem = Undefined Then
		SearchForDuplicatesAreaPresentation = Undefined;
	Else
		SearchForDuplicatesAreaPresentation = ListItem.Presentation;
	EndIf;
	
	FormParameters = New Structure;
	FormParameters.Insert("CompositionSchemaAddress",            CompositionSchemaAddress);
	FormParameters.Insert("FilterComposerSettingsAddress", FilterComposerSettingsAddress());
	FormParameters.Insert("MasterFormID",      UUID);
	FormParameters.Insert("FilterAreaPresentation",      SearchForDuplicatesAreaPresentation);
	
	Handler = New NotifyDescription("FilterRulesSelectionCompletion", ThisObject);
	
	OpenForm(Name, FormParameters, ThisObject, , , , Handler);
	
EndProcedure

&AtClient
Procedure FilterRulesSelectionCompletion(ResultAddress, ExecutionParameters) Export
	If TypeOf(ResultAddress) <> Type("String") Or Not IsTempStorageURL(ResultAddress) Then
		Return;
	EndIf;
	UpdateFilterComposer(ResultAddress);
	GoToWizardStep(Items.NoSearchPerformedStep);
EndProcedure

&AtClient
Procedure FilterRulesPresentationClearing(Item, StandardProcessing)
	StandardProcessing = False;
	PrefilterComposer.Settings.Filter.Items.Clear();
	GoToWizardStep(Items.NoSearchPerformedStep);
	SaveUserSettingsSSL();
EndProcedure

&AtClient
Procedure SearchRulesPresentationClick(Item, StandardProcessing)
	StandardProcessing = False;
	
	Name = FullFormName("SearchRules");
	
	ListItem = Items.DuplicatesSearchArea.ChoiceList.FindByValue(DuplicatesSearchArea);
	If ListItem = Undefined Then
		SearchForDuplicatesAreaPresentation = Undefined;
	Else
		SearchForDuplicatesAreaPresentation = ListItem.Presentation;
	EndIf;
	
	FormParameters = New Structure;
	FormParameters.Insert("DuplicatesSearchArea",        DuplicatesSearchArea);
	FormParameters.Insert("AppliedRuleDetails",   AppliedRuleDetails);
	FormParameters.Insert("SettingsAddress",              SearchRulesSettingsAddress());
	FormParameters.Insert("FilterAreaPresentation", SearchForDuplicatesAreaPresentation);
	
	Handler = New NotifyDescription("SearchRulesSelectionCompletion", ThisObject);
	
	OpenForm(Name, FormParameters, ThisObject, , , , Handler);
EndProcedure

&AtClient
Procedure SearchRulesSelectionCompletion(ResultAddress, ExecutionParameters) Export
	If TypeOf(ResultAddress) <> Type("String") Or Not IsTempStorageURL(ResultAddress) Then
		Return;
	EndIf;
	UpdateSearchRules(ResultAddress);
	GoToWizardStep(Items.NoSearchPerformedStep);
EndProcedure

&AtClient
Procedure DetailsRefClick(Item)
	UT_CommonClient.ShowDetailedInfo(Undefined, Item.ToolTip);
EndProcedure

#EndRegion

#Region FoundDuplicatesFormTableItemsEventHandlers

&AtClient
Procedure FoundDuplicatesOnActivateRow(Item)
	
	AttachIdleHandler("DuplicatesRowActivationDeferredHandler", 0.1, True);
	
EndProcedure

&AtClient
Procedure DuplicatesRowActivationDeferredHandler()
	RowID = Items.FoundDuplicates.CurrentRow;
	If RowID = Undefined Or RowID = CurrentRowID Then
		Return;
	EndIf;
	CurrentRowID = RowID;
	
	UpdateCandidateUsageInstances(RowID);
EndProcedure

&AtServer
Procedure UpdateCandidateUsageInstances(Val RowID)
	RowData = FoundDuplicates.FindByID(RowID);
	
	If RowData.GetParent() = Undefined Then
		// Group details
		CandidateUsageInstances.Clear();

		OriginalDescription = Undefined;
		For Each Candidate In RowData.GetItems() Do
			If Candidate.Main Then
				OriginalDescription = Candidate.Description;
				Break;
			EndIf;
		EndDo;

		Items.CurrentDuplicatesGroupDetails.Title = StrTemplate(
			NStr("ru = 'Для элемента ""%1"" найдено дублей: %2'; en = 'Found %2 duplicates for %1.'"),
			OriginalDescription,
			RowData.Count);

		Items.UsageInstancesPages.CurrentPage = Items.GroupDetails;
		Return;
	EndIf;
	
	// List of usage instances.
	UsageTable = GetFromTempStorage(UsageInstancesAddress);
	Filter = New Structure("Ref", RowData.Ref);

	CandidateUsageInstances.Load(UsageTable.Copy(UsageTable.FindRows(Filter)));

	If RowData.Count = 0 Then
		Items.CurrentDuplicatesGroupDetails.Title = StrTemplate(
			NStr("ru = 'Элемент ""%1"" не используется'; en = 'No usage locations for %1.'"), 
			RowData.Description);

		Items.UsageInstancesPages.CurrentPage = Items.GroupDetails;
	Else
		Items.CandidateUsageInstances.Title = StrTemplate(
			NStr("ru = 'Места использования ""%1"" (%2)'; en = 'Found %2 usage locations for %1.'"), 
			RowData.Description,
			RowData.Count);

		Items.UsageInstancesPages.CurrentPage = Items.UsageInstances;
	EndIf;
	
EndProcedure

&AtClient
Procedure FoundDuplicatesSelection(Item, RowSelected, Field, StandardProcessing)
	
	OpenDuplicateForm(Item.CurrentData);
	
EndProcedure

&AtClient
Procedure FoundDuplicatesCheckOnChange(Item)

	RowData = Items.FoundDuplicates.CurrentData;
	RowData.Check = RowData.Check % 2;
	ChangeCandidatesMarksHierarchically(RowData);
	
	DuplicatesSearchErrorDescription = "";
	TotalFoundDuplicates = 0;
	For Each Duplicate In FoundDuplicates.GetItems() Do
		For Each Child In Duplicate.GetItems() Do
			If Not Child.Main And Child.Check Then
				TotalFoundDuplicates = TotalFoundDuplicates + 1;
			EndIf;
		EndDo;
	EndDo;
	
	UpdateFoundDuplicatesStateDetails(ThisObject);
	
EndProcedure

#EndRegion

#Region UnprocessedDuplicatesFormTableItemsEventHandlers

&AtClient
Procedure UnprocessedDuplicatesOnActivateRow(Item)
	
	AttachIdleHandler("UnprocessedDuplicatesRowActivationDeferredHandler", 0.1, True);
	
EndProcedure

&AtClient
Procedure UnprocessedDuplicatesRowActivationDeferredHandler()
	
	RowData = Items.UnprocessedDuplicates.CurrentData;
	If RowData = Undefined Then
		Return;
	EndIf;
	
	UpdateUnprocessedItemsUsageInstancesDuplicates( RowData.GetID() );
EndProcedure

&AtServer
Procedure UpdateUnprocessedItemsUsageInstancesDuplicates(Val DataString)
	RowData = UnprocessedDuplicates.FindByID(DataString);
	
	If RowData.GetParent() = Undefined Then
		// Group details
		UnprocessedItemsUsageInstances.Clear();
		
		Items.CurrentDuplicatesGroupDetails1.Title = NStr("ru = 'Для просмотра причин выберите проблемный элемент-дубль.'; en = 'To view details, select the duplicate that caused the issue.'");
		Items.UnprocessedItemsUsageInstancesPages.CurrentPage = Items.UnprocessedItemsGroupDetails;
		Return;
	EndIf;
	
	// List of error instances
	ErrorsTable = GetFromTempStorage(ReplacementResultAddress);
	Filter = New Structure("Ref", RowData.Ref);
	
	Data = ErrorsTable.Copy( ErrorsTable.FindRows(Filter) );
	Data.Columns.Add("Icon");
	Data.FillValues(True, "Icon");
	UnprocessedItemsUsageInstances.Load(Data);
	
	If RowData.Count = 0 Then
		Items.CurrentDuplicatesGroupDetails1.Title = StrTemplate(
			NStr("ru = 'Замена дубля ""%1"" возможна, но была отменена из-за невозможности замены в других местах.'; en = 'Replacement of %1 is possible, but was canceled. Cannot replace item in some of the usage locations.'"), 
			RowData.Description);
		
		Items.UnprocessedItemsUsageInstancesPages.CurrentPage = Items.UnprocessedItemsGroupDetails;
	Else
		Items.ProbableDuplicateUsageInstances.Title = StrTemplate(
			NStr("ru = 'Не удалось заменить дубли в некоторых местах (%1)'; en = 'Cannot replace duplicates in %1 usage locations.'"), 
			RowData.Count);
		
		Items.UnprocessedItemsUsageInstancesPages.CurrentPage = Items.UnprocessedItemsUsageInstanceDetails;
	EndIf;
	
EndProcedure

&AtClient
Procedure UnprocessedDuplicatesSelection(Item, RowSelected, Field, StandardProcessing)
	
	OpenDuplicateForm(Items.UnprocessedDuplicates.CurrentData);
	
EndProcedure

&AtClient
Procedure EditUnprocessedDuplicate(Command)
	CurrentData = Items.UnprocessedDuplicates.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(CurrentData.Ref);
EndProcedure
#EndRegion

#Region UnprocessedItemsUsageInstancesFormTableItemsEventHandlers

&AtClient
Procedure UnprocessedDuplicatesUsageInstancesOnActivateRow(Item)

	CurrentData = Item.CurrentData;
	If CurrentData = Undefined Then
		UnprocessedDuplicatesErrorDescription = "";
	Else
		UnprocessedDuplicatesErrorDescription = CurrentData.ErrorText;
	EndIf;
	
EndProcedure

&AtClient
Procedure UnprocessedDuplicatesUsageInstancesSelection(Item, RowSelected, Field, StandardProcessing)

	CurrentData = UnprocessedDuplicatesUsageInstances.FindByID(RowSelected);
	ShowValue(, CurrentData.ErrorObject);
	
EndProcedure
&AtClient
Procedure EditUnprocessedDuplicatesUsageInstance(Command)
	CurrentData = Items.UnprocessedDuplicatesUsageInstances.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(CurrentData.ErrorObject);
EndProcedure

#EndRegion

#Region CandidateUsageInstancesFormTableItemsEventHandlers

&AtClient
Procedure CandidateUsageInstancesSelection(Item, RowSelected, Field, StandardProcessing)

	CurrentData = CandidateUsageInstances.FindByID(RowSelected);
	ShowValue(, CurrentData.Data);
	
EndProcedure

&AtClient
Procedure EditCandidateUsageInstance(Command)
	CurrentData = Items.CandidateUsageInstances.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(CurrentData.Data);
EndProcedure
#EndRegion

#Region FormCommandHandlers

&AtClient
Procedure WizardButtonHandler(Command)
	
	If Command.Name = WizardSettings.NextButton Then
		
		WizardStepNext();
		
	ElsIf Command.Name = WizardSettings.BackButton Then
		
		WizardStepBack();
		
	ElsIf Command.Name = WizardSettings.CancelButton Then
		
		WizardStepCancel();
		
	EndIf;
	
EndProcedure

&AtClient
Procedure SelectMainItem(Command)
	
	RowData = Items.FoundDuplicates.CurrentData;
	If RowData = Undefined Or RowData.Main Then
		Return; // No data or the current item is the main one already.
	EndIf;
		
	Parent = RowData.GetParent();
	If Parent = Undefined Then
		Return;
	EndIf;
	
	ChangeMainItemHierarchically(RowData, Parent);
EndProcedure

&AtClient
Procedure OpenCandidate(Command)
	
	OpenDuplicateForm(Items.FoundDuplicates.CurrentData);
	
EndProcedure

&AtClient
Procedure OpenUnprocessedDuplicate(Command)
	
	OpenDuplicateForm(Items.UnprocessedDuplicates.CurrentData);
	
EndProcedure

&AtClient
Procedure ExpandDuplicatesGroups(Command)
	
	ExpandDuplicatesGroupHierarchically();
	
EndProcedure

&AtClient
Procedure CollapseDuplicatesGroups(Command)
	
	CollapseDuplicatesGroupHierarchically();
	
EndProcedure

&AtClient
Procedure RetrySearch(Command)
	
	GoToWizardStep(Items.PerformSearchStep);
	
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_SetWriteSettings(Command)
	UT_CommonClient.EditWriteSettings(ThisObject);
EndProcedure

&AtClient
Procedure EditFoundDuplicate(Command)
	CurData=Items.FoundDuplicates.CurrentData;
	If CurData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(CurData.Ref);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region Private

////////////////////////////////////////////////////////////////////////////////
// Wizard programming interface

// Initializes wizard structures.
// Value is written to the StepByStepWizardSettings form attribute:
//   Structure - description of wizard settings.
//     Public wizard settings:
//       * Steps - Array - description of wizard steps. Read only.
//           To add steps, use the AddWizardStep function.
//       * CurrentStep - Structure - current wizard step. Read only.
//       * ShowDialogBeforeClose - Boolean - If True, a warning will be displayed before closing the form.
//           For changing.
//     Internal wizard settings:
//       * PageGroup - String - a form item name that is passed to the PageGroup parameter.
//       * NextButton - String - a form item name that is passed to the NextButton parameter.
//       * BackButton - String - a form item name that is passed to the BackButton parameter.
//       * CancelButton - String - a form item name that is passed to the CancelButton parameter.
//
&AtServer
Procedure InitializeStepByStepWizardSettings()
	WizardSettings = New Structure;
	WizardSettings.Insert("Steps", New Array);
	WizardSettings.Insert("CurrentStep", Undefined);
	
	// Interface part IDs.
	WizardSettings.Insert("PagesGroup", Items.WizardSteps.Name);
	WizardSettings.Insert("NextButton",   Items.WizardStepNext.Name);
	WizardSettings.Insert("BackButton",   Items.WizardStepBack.Name);
	WizardSettings.Insert("CancelButton",  Items.WizardStepCancel.Name);
	
	// For processing time-consuming operations.
	WizardSettings.Insert("ShowDialogBeforeClose", False);
	
	// Everything is disabled by default.
	Items.WizardStepNext.Visible  = False;
	Items.WizardStepBack.Visible  = False;
	Items.WizardStepCancel.Visible = False;
EndProcedure

// Adds a wizard step. Navigation between pages is performed according to the order the pages are added.
//
// Parameters:
//   Page - FormGroup - a page that contains step items.
//
// Returns:
//   Structure - description of page settings.
//       * PageName - String - a page name.
//       * NextButton - Structure - description of "Next" button.
//           ** Title - String - a button title. The default value is "Next >".
//           ** Tooltip - String - button tooltip. Corresponds to the button title by default.
//           ** Visible - Boolean - If True, the button is visible. The default value is True.
//           ** Availability - Boolean - If True, the button is clickable. The default value is True.
//           ** DefaultButton - Boolean - if True, the button is the main button of the form. The default value is True.
//       * BackButton - Structure - description of the "Back" button.
//           ** Title - String - a button title. Default value: "< Back".
//           ** Tooltip - String - button tooltip. Corresponds to the button title by default.
//           ** Visible - Boolean - If True, the button is visible. The default value is True.
//           ** Availability - Boolean - If True, the button is clickable. The default value is True.
//           ** DefaultButton - Boolean - if True, the button is the main button of the form. Default value: False.
//       * CancelButton - Structure - description of the "Cancel" button.
//           ** Title - String - a button title. The default value is "Cancel".
//           ** Tooltip - String - button tooltip. Corresponds to the button title by default.
//           ** Visible - Boolean - If True, the button is visible. The default value is True.
//           ** Availability - Boolean - If True, the button is clickable. The default value is True.
//           ** DefaultButton - Boolean - if True, the button is the main button of the form. Default value: False.
//
&AtServer
Function AddWizardStep(Val Page)
	StepDescription = New Structure("IndexOf, PageName, BackButton, NextButton, CancelButton");
	StepDescription.PageName = Page.Name;
	StepDescription.BackButton = WizardButton();
	StepDescription.BackButton.Title = NStr("ru='< Назад'; en = '< Back'");
	StepDescription.NextButton = WizardButton();
	StepDescription.NextButton.DefaultButton = True;
	StepDescription.NextButton.Title = NStr("ru = 'Далее >'; en = 'Next >'");
	StepDescription.CancelButton = WizardButton();
	StepDescription.CancelButton.Title = NStr("ru = 'Отмена'; en = 'Cancel'");
	
	WizardSettings.Steps.Add(StepDescription);
	
	StepDescription.IndexOf = WizardSettings.Steps.UBound();
	Return StepDescription;
EndFunction

// Updates visibility and availability of form items according to the current wizard step.
&AtClientAtServerNoContext
Procedure SetVisibilityAvailability(Form)
	
	Items = Form.Items;
	WizardSettings = Form.WizardSettings;
	CurrentStep = WizardSettings.CurrentStep;
	
	// Navigating to the page.
	Items[WizardSettings.PagesGroup].CurrentPage = Items[CurrentStep.PageName];
	
	// Updating buttons.
	UpdateWizardButtonProperties(Items[WizardSettings.NextButton],  CurrentStep.NextButton);
	UpdateWizardButtonProperties(Items[WizardSettings.BackButton],  CurrentStep.BackButton);
	UpdateWizardButtonProperties(Items[WizardSettings.CancelButton], CurrentStep.CancelButton);
	
EndProcedure

// Navigates to the specified page.
//
// Parameters:
//   StepOrIndexOrFormGroup - Structure, Number, FormGroup - a page to navigate to.
//
&AtClient
Procedure GoToWizardStep(Val StepOrIndexOrFormGroup)
	
	// Searching for step.
	Type = TypeOf(StepOrIndexOrFormGroup);
	If Type = Type("Structure") Then
		StepDescription = StepOrIndexOrFormGroup;
	ElsIf Type = Type("Number") Then
		StepIndex = StepOrIndexOrFormGroup;
		If StepIndex < 0 Then
			Raise NStr("ru='Попытка выхода назад из первого шага мастера'; en = 'Attempt to go back from the first step.'");
		ElsIf StepIndex > WizardSettings.Steps.UBound() Then
			Raise NStr("ru='Попытка выхода за последний шаг мастера'; en = 'Attempt to go next from the last step.'");
		EndIf;
		StepDescription = WizardSettings.Steps[StepIndex];
	Else
		StepFound = False;
		RequiredPageName = StepOrIndexOrFormGroup.Name;
		For Each StepDescription In WizardSettings.Steps Do
			If StepDescription.PageName = RequiredPageName Then
				StepFound = True;
				Break;
			EndIf;
		EndDo;
		If Not StepFound Then
			Raise StrTemplate(
				NStr("ru = 'Не найден шаг ""%1"".'; en = 'Step %1 is not found.'"), RequiredPageName);
		EndIf;
	EndIf;
	
	// Step switch.
	WizardSettings.CurrentStep = StepDescription;
	
	// Updating visibility.
	SetVisibilityAvailability(ThisObject);
	OnActivateWizardStep();
	
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// События мастера

&НаКлиенте
Процедура ПриАктивацииШагаМастера()

	ТекущаяСтраница = Элементы.WizardSteps.ТекущаяСтраница;

	Если ТекущаяСтраница = Элементы.NoSearchPerformedStep Тогда

		Элементы.Header.Доступность = Истина;
		
		// Представление правил отбора.
		SearchRulesPresentation = Строка(КомпоновщикПредварительногоОтбора.Настройки.Отбор);
		Если ПустаяСтрока(SearchRulesPresentation) Тогда
			SearchRulesPresentation = НСтр("ru = 'Все элементы'");
		КонецЕсли;
		
		// Представление правил поиска.
		Союз = " " + НСтр("ru = 'И'") + " ";
		ТекстПравил = "";
		Для Каждого Правило Из ПравилаПоиска Цикл
			Если Правило.Правило = "Равно" Тогда
				Сравнение = Правило.ПредставлениеРеквизита + " " + НСтр("ru = 'совпадает'");
			ИначеЕсли Правило.Правило = "Подобно" Тогда
				Сравнение = Правило.ПредставлениеРеквизита + " " + НСтр("ru = 'совпадает по похожим словам'");
			Иначе
				Продолжить;
			КонецЕсли;
			ТекстПравил = ?(ТекстПравил = "", "", ТекстПравил + Союз) + Сравнение;
		КонецЦикла;
		Если ConsiderAppliedRules Тогда
			Для Позиция = 1 По СтрЧислоСтрок(ОписаниеПрикладныхПравил) Цикл
				СтрокаПравила = СокрЛП(СтрПолучитьСтроку(ОписаниеПрикладныхПравил, Позиция));
				Если Не ПустаяСтрока(СтрокаПравила) Тогда
					ТекстПравил = ?(ТекстПравил = "", "", ТекстПравил + Союз) + СтрокаПравила;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		Если ПустаяСтрока(ТекстПравил) Тогда
			ТекстПравил = НСтр("ru = 'Правила не заданы'");
		КонецЕсли;
		ПредставлениеПравилПоиска = ТекстПравил;
		
		// Доступность.
		Элементы.FilterRulesPresentation.Доступность = Не ПустаяСтрока(ОбластьПоискаДублей);
		Элементы.SearchRulesPresentation.Доступность = Не ПустаяСтрока(ОбластьПоискаДублей);

	ИначеЕсли ТекущаяСтраница = Элементы.PerformSearchStep Тогда

		Если Не ЭтоАдресВременногоХранилища(АдресСхемыКомпоновки) Тогда
			Возврат; // Не инициализировано.
		КонецЕсли;
		Элементы.Header.Доступность = Ложь;
		НастройкиМастера.ПоказатьДиалогПередЗакрытием = Истина;
		НайтиИУдалитьДублиКлиент();

	ИначеЕсли ТекущаяСтраница = Элементы.MainItemSelectionStep Тогда

		Элементы.Header.Доступность = Истина;
		Элементы.RetrySearch.Видимость = Истина;
		РазвернутьГруппуДублейИерархически();

	ИначеЕсли ТекущаяСтраница = Элементы.DeletionStep Тогда

		Элементы.Header.Доступность = Ложь;
		НастройкиМастера.ПоказатьДиалогПередЗакрытием = Истина;
		НайтиИУдалитьДублиКлиент();

	ИначеЕсли ТекущаяСтраница = Элементы.SuccessfulDeletionStep Тогда

		Элементы.Header.Доступность = Ложь;

	ИначеЕсли ТекущаяСтраница = Элементы.UnsuccessfulReplacementsStep Тогда

		Элементы.Header.Доступность = Ложь;

	ИначеЕсли ТекущаяСтраница = Элементы.DuplicatesNotFoundStep Тогда

		Элементы.Header.Доступность = Истина;
		Если ПустаяСтрока(ОписаниеОшибкиПоискаДублей) Тогда
			Сообщение = НСтр("ru = 'Не обнаружено дублей по указанным параметрам.'");
		Иначе
			Сообщение = ОписаниеОшибкиПоискаДублей;
		КонецЕсли;
		Элементы.DuplicatesNotFound.ОтображениеСостояния.Текст = Сообщение + Символы.ПС + НСтр(
			"ru = 'Измените условия и нажмите ""Найти дубли""'");

	ИначеЕсли ТекущаяСтраница = Элементы.ErrorOccurredStep Тогда

		Элементы.Header.Доступность = Истина;
		Элементы.DetailsRef.Видимость = ЗначениеЗаполнено(Элементы.DetailsRef.Подсказка);

	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ШагМастераДалее()

	ОчиститьСообщения();
	ТекущаяСтраница = Элементы.WizardSteps.ТекущаяСтраница;

	Если ТекущаяСтраница = Элементы.NoSearchPerformedStep Тогда

		Если ПустаяСтрока(ОбластьПоискаДублей) Тогда
			ПоказатьПредупреждение( , НСтр("ru = 'Необходимо выбрать область поиска дублей'"));
			Возврат;
		КонецЕсли;

		ПерейтиНаШагМастера(НастройкиМастера.ТекущийШаг.Индекс + 1);

	ИначеЕсли ТекущаяСтраница = Элементы.MainItemSelectionStep Тогда

		Элементы.RetrySearch.Видимость = Ложь;
		ПерейтиНаШагМастера(НастройкиМастера.ТекущийШаг.Индекс + 1);

	ИначеЕсли ТекущаяСтраница = Элементы.UnsuccessfulReplacementsStep Тогда

		ПерейтиНаШагМастера(Элементы.DeletionStep);

	ИначеЕсли ТекущаяСтраница = Элементы.DuplicatesNotFoundStep Тогда

		ПерейтиНаШагМастера(Элементы.PerformSearchStep);

	Иначе

		ПерейтиНаШагМастера(НастройкиМастера.ТекущийШаг.Индекс + 1);

	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ШагМастераНазад()

	ТекущаяСтраница = Элементы.WizardSteps.ТекущаяСтраница;

	Если ТекущаяСтраница = Элементы.SuccessfulDeletionStep Тогда

		ПерейтиНаШагМастера(Элементы.NoSearchPerformedStep);

	Иначе

		ПерейтиНаШагМастера(НастройкиМастера.ТекущийШаг.Индекс - 1);

	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ШагМастераОтмена()

	ТекущаяСтраница = Элементы.WizardSteps.ТекущаяСтраница;

	Если ТекущаяСтраница = Элементы.PerformSearchStep Или ТекущаяСтраница = Элементы.DeletionStep Тогда

		НастройкиМастера.ПоказатьДиалогПередЗакрытием = Ложь;

	КонецЕсли;

	Если Открыта() Тогда
		Закрыть();
	КонецЕсли;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Клиент

&НаКлиенте
Функция ПолноеИмяФормы(КраткоеИмяФормы)
	Имена = СтрРазделить(ИмяФормы, ".");
	Возврат Имена[0] + "." + Имена[1] + ".Форма." + КраткоеИмяФормы;
КонецФункции

&НаКлиенте
Процедура ОткрытьФормуДубля(Знач ТекущиеДанные)
	Если ТекущиеДанные = Неопределено Или Не ЗначениеЗаполнено(ТекущиеДанные.Ссылка) Тогда
		Возврат;
	КонецЕсли;

	ПоказатьЗначение( , ТекущиеДанные.Ссылка);
КонецПроцедуры
&НаКлиенте
Процедура ПоказатьМестаИспользования(ДеревоИсточник)
	МассивСсылок = Новый Массив;
	Для Каждого ГруппаДублей Из ДеревоИсточник.ПолучитьЭлементы() Цикл
		Для Каждого СтрокаДерева Из ГруппаДублей.ПолучитьЭлементы() Цикл
			МассивСсылок.Добавить(СтрокаДерева.Ссылка);
		КонецЦикла;
	КонецЦикла;

	ПараметрыОтчета = Новый Структура;
	ПараметрыОтчета.Вставить("Отбор", Новый Структура("НаборСсылок", МассивСсылок));
	РежимОкна = РежимОткрытияОкнаФормы.БлокироватьОкноВладельца;
	ОткрытьФорму("Отчет.МестаИспользованияСсылок.Форма", ПараметрыОтчета, ЭтотОбъект, , , , , РежимОкна);
КонецПроцедуры

&НаКлиенте
Процедура РазвернутьГруппуДублейИерархически(Знач СтрокаДанных = Неопределено)
	Если СтрокаДанных <> Неопределено Тогда
		Элементы.FoundDuplicates.Развернуть(СтрокаДанных, Истина);
	КонецЕсли;
	
	// Все первого уровня
	ВсеСтроки = Элементы.FoundDuplicates;
	Для Каждого ДанныеСтроки Из FoundDuplicates.ПолучитьЭлементы() Цикл
		ВсеСтроки.Развернуть(ДанныеСтроки.ПолучитьИдентификатор(), Истина);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура СвернутьГруппуДублейИерархически(Знач СтрокаДанных = Неопределено)
	Если СтрокаДанных <> Неопределено Тогда
		Элементы.FoundDuplicates.Свернуть(СтрокаДанных);
		Возврат;
	КонецЕсли;
	
	// Все первого уровня
	ВсеСтроки = Элементы.FoundDuplicates;
	Для Каждого ДанныеСтроки Из FoundDuplicates.ПолучитьЭлементы() Цикл
		ВсеСтроки.Свернуть(ДанныеСтроки.ПолучитьИдентификатор());
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьПометкиКандидатовИерархически(Знач ДанныеСтроки)
	ПроставитьПометкиВниз(ДанныеСтроки);
	ПроставитьПометкиВверх(ДанныеСтроки);
КонецПроцедуры

&НаКлиенте
Процедура ПроставитьПометкиВниз(Знач ДанныеСтроки)
	Значение = ДанныеСтроки.Check;
	Для Каждого Потомок Из ДанныеСтроки.ПолучитьЭлементы() Цикл
		Потомок.Check = Значение;
		ПроставитьПометкиВниз(Потомок);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ПроставитьПометкиВверх(Знач ДанныеСтроки)
	РодительСтроки = ДанныеСтроки.ПолучитьРодителя();

	Если РодительСтроки <> Неопределено Тогда
		ВсеИстина = Истина;
		НеВсеЛожь = Ложь;

		Для Каждого Потомок Из РодительСтроки.ПолучитьЭлементы() Цикл
			ВсеИстина = ВсеИстина И (Потомок.Check = 1);
			НеВсеЛожь = НеВсеЛожь Или (Потомок.Check > 0);
		КонецЦикла;

		Если ВсеИстина Тогда
			РодительСтроки.Check = 1;

		ИначеЕсли НеВсеЛожь Тогда
			РодительСтроки.Check = 2;

		Иначе
			РодительСтроки.Check = 0;

		КонецЕсли;

		ПроставитьПометкиВверх(РодительСтроки);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ИзменитьОсновнойЭлементИерархически(Знач ДанныеСтроки, Знач Родитель)
	Для Каждого Потомок Из Родитель.ПолучитьЭлементы() Цикл
		Потомок.Main = Ложь;
	КонецЦикла;
	ДанныеСтроки.Main = Истина;
	
	// Выбранный всегда используем.
	ДанныеСтроки.Check = 1;
	ИзменитьПометкиКандидатовИерархически(ДанныеСтроки);
	
	// И изменяем название группы
	Родитель.Description = ДанныеСтроки.Description + " (" + Родитель.Count + ")";
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Клиент, Сервер

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьОписаниеСостоянияНайденныхДублей(Форма)

	Если ПустаяСтрока(Форма.ОписаниеОшибкиПоискаДублей) Тогда
		Описание = СтрШаблон(
			НСтр("ru = 'Выбрано дублей: %1 из %2.'"), Форма.ВсегоНайденоДублей, Форма.ВсегоЭлементов);
	Иначе
		Описание = Форма.ОписаниеОшибкиПоискаДублей;
	КонецЕсли;

	Форма.FoundDuplicatesStateDetails = Новый ФорматированнаяСтрока(Описание + Символы.ПС + НСтр(
		"ru = 'Выбранные элементы будут помечены на удаление и заменены на оригиналы (отмечены стрелкой).'"), ,
		Форма.ЦветПоясняющийТекст);

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Вызов сервера, Сервер

&НаСервере
Функция АдресНастроекКомпоновщикаОтбора()
	Возврат ПоместитьВоВременноеХранилище(КомпоновщикПредварительногоОтбора.Настройки, УникальныйИдентификатор);
КонецФункции

&НаСервере
Функция АдресНастроекПравилПоиска()
	Настройки = Новый Структура;
	Настройки.Вставить("ConsiderAppliedRules", ConsiderAppliedRules);
	Настройки.Вставить("AllComparisonOptions", AllComparisonOptions);
	Настройки.Вставить("ПравилаПоиска", РеквизитФормыВЗначение("ПравилаПоиска"));
	Возврат ПоместитьВоВременноеХранилище(Настройки);
КонецФункции

&НаСервере
Процедура ОбновитьКомпоновщикОтбора(АдресРезультата)
	Результат = ПолучитьИзВременногоХранилища(АдресРезультата);
	УдалитьИзВременногоХранилища(АдресРезультата);
	КомпоновщикПредварительногоОтбора.ЗагрузитьНастройки(Результат);
	КомпоновщикПредварительногоОтбора.Восстановить(СпособВосстановленияНастроекКомпоновкиДанных.Полное);
	СохранитьПользовательскиеНастройки();
КонецПроцедуры

&НаСервере
Процедура ОбновитьПравилаПоиска(АдресРезультата)
	Результат = ПолучитьИзВременногоХранилища(АдресРезультата);
	УдалитьИзВременногоХранилища(АдресРезультата);
	ConsiderAppliedRules = Результат.ConsiderAppliedRules;
	ЗначениеВРеквизитФормы(Результат.ПравилаПоиска, "ПравилаПоиска");
	СохранитьПользовательскиеНастройки();
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьКомпоновщикОтбораИПравила(НастройкиФормы)
	// 1. Очистка и инициализация сведений об объекте метаданных.
	SearchRulesPresentation = "";
	ПредставлениеПравилПоиска = "";

	ТаблицаНастроек = ПолучитьИзВременногоХранилища(АдресНастроек);
	СтрокаТаблицыНастроек = ТаблицаНастроек.Найти(ОбластьПоискаДублей, "ПолноеИмя");
	Если СтрокаТаблицыНастроек = Неопределено Тогда
		ОбластьПоискаДублей = "";
		Возврат;
	КонецЕсли;

	ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ОбластьПоискаДублей);
	
	// 2. Инициализация СКД, которая используется для отборов.
	СхемаКомпоновки = Новый СхемаКомпоновкиДанных;
	ИсточникДанных = СхемаКомпоновки.ИсточникиДанных.Добавить();
	ИсточникДанных.ТипИсточникаДанных = "Local";

	НаборДанных = СхемаКомпоновки.НаборыДанных.Добавить(Тип("НаборДанныхЗапросСхемыКомпоновкиДанных"));
	НаборДанных.Запрос = "ВЫБРАТЬ " + ДоступныеРеквизитыОтбора(ОбъектМетаданных) + " ИЗ " + ОбластьПоискаДублей;
	НаборДанных.АвтоЗаполнениеДоступныхПолей = Истина;

	АдресСхемыКомпоновки = ПоместитьВоВременноеХранилище(СхемаКомпоновки, УникальныйИдентификатор);

	КомпоновщикПредварительногоОтбора.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновки));
	
	// 3. Заполнение таблицы ПравилаПоиска.
	ТаблицаПравил = РеквизитФормыВЗначение("ПравилаПоиска");
	ТаблицаПравил.Очистить();

	ИгнорируемыеРеквизиты = Новый Структура("ПометкаУдаления, Ссылка, Предопределенный, ИмяПредопределенныхДанных, ЭтоГруппа");
	ДобавитьПравилаМетаРеквизитов(ТаблицаПравил, ИгнорируемыеРеквизиты, AllComparisonOptions,
		ОбъектМетаданных.СтандартныеРеквизиты, НечеткийПоиск);
	ДобавитьПравилаМетаРеквизитов(ТаблицаПравил, ИгнорируемыеРеквизиты, AllComparisonOptions,
		ОбъектМетаданных.Реквизиты, НечеткийПоиск);
	
	// 4. Загрузка сохраненных значений.
	ОтборыЗагружены = Ложь;
	НастройкиКД = UT_CommonClientServer.StructureProperty(НастройкиФормы, "НастройкиКД");
	Если ТипЗнч(НастройкиКД) = Тип("НастройкиКомпоновкиДанных") Тогда
		КомпоновщикПредварительногоОтбора.ЗагрузитьНастройки(НастройкиКД);
		ОтборыЗагружены = Истина;
	КонецЕсли;

	ПравилаЗагружены = Ложь;
	СохраненныеПравила = UT_CommonClientServer.StructureProperty(НастройкиФормы, "ПравилаПоиска");
	Если ТипЗнч(СохраненныеПравила) = Тип("ТаблицаЗначений") Тогда
		ПравилаЗагружены = Истина;
		Для Каждого СохраненноеПравило Из СохраненныеПравила Цикл
			Правило = ТаблицаПравил.Найти(СохраненноеПравило.Реквизит, "Реквизит");
			Если Правило <> Неопределено И Правило.ВариантыСравнения.НайтиПоЗначению(СохраненноеПравило.Правило)
				<> Неопределено Тогда
				Правило.Правило = СохраненноеПравило.Правило;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	// 5. Установка умолчаний.
	// Отбор по пометке удаления.
	Если Не ОтборыЗагружены Тогда
		UT_CommonClientServer.SetFilterItem(
			КомпоновщикПредварительногоОтбора.Настройки.Отбор, "ПометкаУдаления", Ложь,
			ВидСравненияКомпоновкиДанных.Равно, , Ложь);
	КонецЕсли;
	// Сравнение по наименованию.
	Если Не ПравилаЗагружены Тогда
		Правило = ТаблицаПравил.Найти("Description", "Реквизит");
		Если Правило <> Неопределено Тогда
			ЗначениеДляСравнения = ?(НечеткийПоиск, "Подобно", "Равно");
			Если Правило.ВариантыСравнения.НайтиПоЗначению(ЗначениеДляСравнения) <> Неопределено Тогда
				Правило.Правило = ЗначениеДляСравнения;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	// 6. Механизмы расширения в части прикладных правил.
	ОписаниеПрикладныхПравил = Неопределено;
	Если СтрокаТаблицыНастроек.СобытиеПараметрыПоискаДублей Тогда
		ПараметрыПоУмолчанию = Новый Структура;
		ПараметрыПоУмолчанию.Вставить("ПравилаПоиска", ТаблицаПравил);
		ПараметрыПоУмолчанию.Вставить("ОграниченияСравнения", Новый Массив);
		ПараметрыПоУмолчанию.Вставить("КомпоновщикОтбора", КомпоновщикПредварительногоОтбора);
		ПараметрыПоУмолчанию.Вставить("КоличествоЭлементовДляСравнения", 1000);
		МенеджерОбъектаМетаданных = UT_Common.ObjectManagerByFullName(ОбъектМетаданных.ПолноеИмя());
		//@skip-warning
		МенеджерОбъектаМетаданных.ПараметрыПоискаДублей(ПараметрыПоУмолчанию);
		
		// Представление прикладных правил.
		ОписаниеПрикладныхПравил = "";
		Для Каждого Описание Из ПараметрыПоУмолчанию.ОграниченияСравнения Цикл
			ОписаниеПрикладныхПравил = ОписаниеПрикладныхПравил + Символы.ПС + Описание.Представление;
		КонецЦикла;
		ОписаниеПрикладныхПравил = СокрЛП(ОписаниеПрикладныхПравил);
	КонецЕсли;

	КомпоновщикПредварительногоОтбора.Восстановить(СпособВосстановленияНастроекКомпоновкиДанных.Полное);

	ТаблицаПравил.Сортировать("ПредставлениеРеквизита");
	ЗначениеВРеквизитФормы(ТаблицаПравил, "ПравилаПоиска");

	Если НастройкиФормы = Неопределено Тогда
		СохранитьПользовательскиеНастройки();
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Сервер

&НаСервере
Процедура ПриСозданииНаСервереИнициализацияДанных(НастройкиФормы)
	ConsiderAppliedRules = UT_CommonClientServer.StructureProperty(НастройкиФормы,
		"ConsiderAppliedRules");
	ОбластьПоискаДублей        = UT_CommonClientServer.StructureProperty(НастройкиФормы,
		"DuplicatesSearchArea");

	ТаблицаНастроек = Обработки.UT_DuplicateObjectDetection.НастройкиОбъектовМетаданных();
	АдресНастроек = ПоместитьВоВременноеХранилище(ТаблицаНастроек, УникальныйИдентификатор);

	СписокВыбора = Элементы.DuplicatesSearchArea.СписокВыбора;
	Для Каждого СтрокаТаблицы Из ТаблицаНастроек Цикл
		СписокВыбора.Добавить(СтрокаТаблицы.ПолноеИмя, СтрокаТаблицы.ПредставлениеСписка, ,
			БиблиотекаКартинок[СтрокаТаблицы.Вид]);
	КонецЦикла;

	AllComparisonOptions.Добавить("Равно", НСтр("ru = 'Совпадает'"));
	AllComparisonOptions.Добавить("Подобно", НСтр("ru = 'Совпадает по похожим словам'"));
КонецПроцедуры

&НаСервере
Процедура СохранитьПользовательскиеНастройки()
	НастройкиФормы = Новый Структура;
	НастройкиФормы.Вставить("ConsiderAppliedRules", ConsiderAppliedRules);
	НастройкиФормы.Вставить("DuplicatesSearchArea", ОбластьПоискаДублей);
	НастройкиФормы.Вставить("НастройкиКД", КомпоновщикПредварительногоОтбора.Настройки);
	НастройкиФормы.Вставить("ПравилаПоиска", ПравилаПоиска.Выгрузить());
	UT_Common.CommonSettingsStorageSave(ИмяФормы, "", НастройкиФормы);
КонецПроцедуры

&НаСервере
Процедура УстановитьЦветаИУсловноеОформление()
	ЦветПоясняющийТекст       = ЦветСтиляИлиАвто("ПоясняющийТекст", 69, 81, 133);
	ЦветПоясняющийОшибкуТекст = ЦветСтиляИлиАвто("ПоясняющийОшибкуТекст", 255, 0, 0);
	ЦветНедоступныеДанные     = ЦветСтиляИлиАвто("ЦветНедоступныеДанные", 192, 192, 192);

	ЭлементыУсловногоОформления = УсловноеОформление.Элементы;
	ЭлементыУсловногоОформления.Очистить();
	
	// Отсутствие мест использования у группы.
	ЭлементОформления = ЭлементыУсловногоОформления.Добавить();

	ОтборОформления = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборОформления.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("FoundDuplicates.Ссылка");
	ОтборОформления.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
	ОтборОформления.ПравоеЗначение = Истина;

	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Текст", "");

	ПолеОформления = ЭлементОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("FoundDuplicatesCount");
	
	// 1. Строка с текущим основным элементом группы:
	
	// Картинка
	ЭлементОформления = ЭлементыУсловногоОформления.Добавить();

	ОтборОформления = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборОформления.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("FoundDuplicates.Main");
	ОтборОформления.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборОформления.ПравоеЗначение = Истина;

	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Видимость", Истина);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Истина);

	ПолеОформления = ЭлементОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("FoundDuplicatesMain");
	
	// Отсутствие пометки
	ЭлементОформления = ЭлементыУсловногоОформления.Добавить();

	ОтборОформления = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборОформления.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("FoundDuplicates.Main");
	ОтборОформления.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборОформления.ПравоеЗначение = Истина;

	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);

	ПолеОформления = ЭлементОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("FoundDuplicatesCheck");
	
	// 2. Строка с обычным элементом.
	
	// Картинка
	ЭлементОформления = ЭлементыУсловногоОформления.Добавить();

	ОтборОформления = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборОформления.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("FoundDuplicates.Main");
	ОтборОформления.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборОформления.ПравоеЗначение = Ложь;

	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Ложь);

	ПолеОформления = ЭлементОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("FoundDuplicatesMain");
	
	// Наличие пометки
	ЭлементОформления = ЭлементыУсловногоОформления.Добавить();

	ОтборОформления = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборОформления.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("FoundDuplicates.Main");
	ОтборОформления.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборОформления.ПравоеЗначение = Ложь;

	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Видимость", Истина);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Отображать", Истина);

	ПолеОформления = ЭлементОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("FoundDuplicatesCheck");
	
	// 3. Места использования
	ЭлементОформления = ЭлементыУсловногоОформления.Добавить();

	ОтборОформления = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборОформления.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("FoundDuplicates.Ссылка");
	ОтборОформления.ВидСравнения = ВидСравненияКомпоновкиДанных.Заполнено;
	ОтборОформления.ПравоеЗначение = Истина;

	ОтборОформления = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборОформления.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("FoundDuplicates.Count");
	ОтборОформления.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборОформления.ПравоеЗначение = 0;

	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Текст", НСтр("ru = '-'"));

	ПолеОформления = ЭлементОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("FoundDuplicatesCount");
	
	// 4. Неактивная строка
	ЭлементОформления = ЭлементыУсловногоОформления.Добавить();

	ОтборОформления = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборОформления.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("FoundDuplicates.Check");
	ОтборОформления.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборОформления.ПравоеЗначение = 0;

	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветНедоступныеДанные);

	ПолеОформления = ЭлементОформления.Поля.Элементы.Добавить();
	ПолеОформления.Поле = Новый ПолеКомпоновкиДанных("FoundDuplicates");

КонецПроцедуры

&НаСервере
Функция ЦветСтиляИлиАвто(Знач Имя, Знач Красный = Неопределено, Зеленый = Неопределено, Синий = Неопределено)
	ЭлементСтиля = Метаданные.ЭлементыСтиля.Найти(Имя);
	Если ЭлементСтиля <> Неопределено И ЭлементСтиля.Вид = Метаданные.СвойстваОбъектов.ВидЭлементаСтиля.Цвет Тогда
		Возврат ЦветаСтиля[Имя];
	КонецЕсли;

	Возврат ?(Красный = Неопределено, Новый Цвет, Новый Цвет(Красный, Зеленый, Синий));
КонецФункции

&НаСервере
Функция ПарыЗаменДублей()
	ПарыЗамен = Новый Соответствие;

	ДеревоДублей = РеквизитФормыВЗначение("FoundDuplicates");
	ФильтрПоиска = Новый Структура("Main", Истина);

	Для Каждого Родитель Из ДеревоДублей.Строки Цикл
		ОсновнойВГруппе = Родитель.Строки.НайтиСтроки(ФильтрПоиска)[0].Ссылка;

		Для Каждого Потомок Из Родитель.Строки Цикл
			Если Потомок.Check = 1 Тогда
				ПарыЗамен.Вставить(Потомок.Ссылка, ОсновнойВГруппе);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;

	Возврат ПарыЗамен;
КонецФункции

&НаСервереБезКонтекста
Функция ДоступныеРеквизитыОтбора(ОбъектМетаданных)
	МассивРеквизитов = Новый Массив;
	Для Каждого РеквизитМетаданные Из ОбъектМетаданных.СтандартныеРеквизиты Цикл
		Если Не РеквизитМетаданные.Тип.СодержитТип(Тип("ХранилищеЗначения")) Тогда
			МассивРеквизитов.Добавить(РеквизитМетаданные.Имя);
		КонецЕсли;
	КонецЦикла
	;
	Для Каждого РеквизитМетаданные Из ОбъектМетаданных.Реквизиты Цикл
		Если Не РеквизитМетаданные.Тип.СодержитТип(Тип("ХранилищеЗначения")) Тогда
			МассивРеквизитов.Добавить(РеквизитМетаданные.Имя);
		КонецЕсли;
	КонецЦикла
	;
	Возврат СтрСоединить(МассивРеквизитов, ",");
КонецФункции

&НаСервереБезКонтекста
Процедура ДобавитьПравилаМетаРеквизитов(ТаблицаПравил, Знач Игнорировать, Знач ВсеВариантыСравнения,
	Знач МетаКоллекция, Знач ДоступенНечеткийПоиск)

	Для Каждого МетаРеквизит Из МетаКоллекция Цикл
		Если Не Игнорировать.Свойство(МетаРеквизит.Имя) Тогда
			ВариантыСравнения = ВариантыСравненияДляТипа(МетаРеквизит.Тип, ВсеВариантыСравнения, ДоступенНечеткийПоиск);
			Если ВариантыСравнения <> Неопределено Тогда
				// Можно сравнивать
				СтрокаПравил = ТаблицаПравил.Добавить();
				СтрокаПравил.Реквизит          = МетаРеквизит.Имя;
				СтрокаПравил.ВариантыСравнения = ВариантыСравнения;

				ПредставлениеРеквизита = МетаРеквизит.Синоним;
				СтрокаПравил.ПредставлениеРеквизита = ?(ПустаяСтрока(ПредставлениеРеквизита), МетаРеквизит.Имя,
					ПредставлениеРеквизита);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ВариантыСравненияДляТипа(Знач ДоступныеТипы, Знач ВсеВариантыСравнения, Знач ДоступенНечеткийПоиск)

	ЭтоХранилище = ДоступныеТипы.СодержитТип(Тип("ХранилищеЗначения"));
	Если ЭтоХранилище Тогда 
		// Нельзя сравнивать
		Возврат Неопределено;
	КонецЕсли;

	ЭтоСтрока = ДоступныеТипы.СодержитТип(Тип("Строка"));
	ЭтоФиксированнаяСтрока = ЭтоСтрока И ДоступныеТипы.КвалификаторыСтроки <> Неопределено
		И ДоступныеТипы.КвалификаторыСтроки.Длина <> 0;

	Если ЭтоСтрока И Не ЭтоФиксированнаяСтрока Тогда
		// Нельзя сравнивать
		Возврат Неопределено;
	КонецЕсли;

	Результат = Новый СписокЗначений;
	ЗаполнитьЗначенияСвойств(Результат.Добавить(), ВсеВариантыСравнения[0]);		// Совпадает

	Если ДоступенНечеткийПоиск И ЭтоСтрока Тогда
		ЗаполнитьЗначенияСвойств(Результат.Добавить(), ВсеВариантыСравнения[1]);	// Похоже
	КонецЕсли;

	Возврат Результат;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Работа с длительными операциями

&НаКлиенте
Процедура НайтиИУдалитьДублиКлиент()

	Задание = НайтиИУдалитьДубли();

	НастройкиОжидания = UT_TimeConsumingOperationsClient.ПараметрыОжидания(ЭтотОбъект);
	НастройкиОжидания.ВыводитьОкноОжидания = Ложь;
	НастройкиОжидания.ВыводитьПрогрессВыполнения = Истина;
	НастройкиОжидания.ОповещениеОПрогрессеВыполнения = Новый ОписаниеОповещения("НайтиИУдалитьДублиПрогресс",
		ЭтотОбъект);
	;
	Обработчик = Новый ОписаниеОповещения("НайтиИУдалитьДублиЗавершение", ЭтотОбъект);
	UT_TimeConsumingOperationsClient.WaitForCompletion(Задание, Обработчик, НастройкиОжидания);

КонецПроцедуры

&НаСервере
Функция НайтиИУдалитьДубли()

	ПараметрыПроцедуры = Новый Структура;
	ПараметрыПроцедуры.Вставить("ConsiderAppliedRules", ConsiderAppliedRules);

	ТекущаяСтраница = Элементы.WizardSteps.ТекущаяСтраница;
	Если ТекущаяСтраница = Элементы.PerformSearchStep Тогда

		Элементы.PerformSearch.ОтображениеСостояния.Текст = НСтр("ru = 'Поиск дублей...'");

		ИмяПроцедуры = РеквизитФормыВЗначение("Объект").Метаданные().ПолноеИмя() + ".МодульОбъекта.ФоновыйПоискДублей";
		НаименованиеМетода = НСтр("ru = 'Поиск и удаление дублей: Поиск дублей'");
		ПараметрыПроцедуры.Вставить("DuplicatesSearchArea", ОбластьПоискаДублей);
		ПараметрыПроцедуры.Вставить("МаксимальноеЧислоДублей", 1500);
		МассивПравилПоиска = Новый Массив;
		Для Каждого Правило Из ПравилаПоиска Цикл
			МассивПравилПоиска.Добавить(Новый Структура("Реквизит, Правило", Правило.Реквизит, Правило.Правило));
		КонецЦикла;
		ПараметрыПроцедуры.Вставить("ПравилаПоиска", МассивПравилПоиска);
		ПараметрыПроцедуры.Вставить("СхемаКомпоновки", ПолучитьИзВременногоХранилища(АдресСхемыКомпоновки));
		ПараметрыПроцедуры.Вставить("НастройкиКомпоновщикаПредварительногоОтбора",
			КомпоновщикПредварительногоОтбора.Настройки);

	ИначеЕсли ТекущаяСтраница = Элементы.DeletionStep Тогда

		Элементы.Deletion.ОтображениеСостояния.Текст = НСтр("ru = 'Удаление дублей...'");

		ИмяПроцедуры = РеквизитФормыВЗначение("Объект").Метаданные().ПолноеИмя()
			+ ".МодульОбъекта.ФоновоеУдалениеДублей";
		НаименованиеМетода = НСтр("ru = 'Поиск и удаление дублей: Удаление дублей'");
		ПараметрыПроцедуры.Вставить("ПарыЗамен", ПарыЗаменДублей());
		ПараметрыПроцедуры.Вставить("ПараметрыЗаписи", UT_CommonClientServer.FormWriteSettings(ЭтотОбъект));
		ПараметрыПроцедуры.Вставить("ConsiderAppliedRules", ConsiderAppliedRules);
		ПараметрыПроцедуры.Вставить("ReplaceInTransaction", ReplaceInTransaction);
	Иначе
		ВызватьИсключение НСтр("ru = 'Некорректное состояние в НайтиИУдалитьДубли.'");
	КонецЕсли;

	НастройкиЗапуска = UT_TimeConsumingOperations.BackgroundExecutionParameters(УникальныйИдентификатор);
	НастройкиЗапуска.НаименованиеФоновогоЗадания = НаименованиеМетода;

	Возврат UT_TimeConsumingOperations.ExecuteInBackground(ИмяПроцедуры, ПараметрыПроцедуры, НастройкиЗапуска);
КонецФункции

&НаКлиенте
Процедура НайтиИУдалитьДублиПрогресс(Прогресс, ДополнительныеПараметры) Экспорт

	Если Прогресс = Неопределено Или Прогресс.Прогресс = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ТекущаяСтраница = Элементы.WizardSteps.ТекущаяСтраница;
	Если ТекущаяСтраница = Элементы.PerformSearchStep Тогда

		Сообщение = НСтр("ru = 'Поиск дублей...'");
		Если Прогресс.Прогресс.Текст = "РассчитыватьМестаИспользования" Тогда
			Сообщение = НСтр("ru = 'Выполняется расчет мест использования дублей...'");
		ИначеЕсли Прогресс.Прогресс.Процент > 0 Тогда
			Сообщение = Сообщение + " " + СтрШаблон(
					НСтр("ru = '(найдено %1)'"), Прогресс.Прогресс.Процент);
		КонецЕсли;
		Элементы.PerformSearch.ОтображениеСостояния.Текст = Сообщение;

	ИначеЕсли ТекущаяСтраница = Элементы.DeletionStep Тогда

		Сообщение = НСтр("ru = 'Удаление дублей...'");
		Если Прогресс.Прогресс.Процент > 0 Тогда
			Сообщение = Сообщение + " " + СтрШаблон(
					НСтр("ru = '(удалено %1 из %2)'"), Прогресс.Прогресс.Процент, ВсегоНайденоДублей);
		КонецЕсли;
		Элементы.Deletion.ОтображениеСостояния.Текст = Сообщение;

	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура НайтиИУдалитьДублиЗавершение(Задание, ДополнительныеПараметры) Экспорт
	НастройкиМастера.ПоказатьДиалогПередЗакрытием = Ложь;
	Активизировать();
	ТекущаяСтраница = Элементы.WizardSteps.ТекущаяСтраница;
	
	// задание было отменено.
	Если Задание = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если Задание.Статус <> "Выполнено" Тогда
		// Фоновое задание завершено с ошибкой.
		Если ТекущаяСтраница = Элементы.PerformSearchStep Тогда
			Кратко = НСтр("ru = 'При поиске дублей возникла ошибка:'");
		ИначеЕсли ТекущаяСтраница = Элементы.DeletionStep Тогда
			Кратко = НСтр("ru = 'При удалении дублей возникла ошибка:'");
		КонецЕсли;
		Кратко = Кратко + Символы.ПС + Задание.КраткоеПредставлениеОшибки;
		Подробно = Кратко + Символы.ПС + Символы.ПС + Задание.ПодробноеПредставлениеОшибки;
		Элементы.ErrorTextLabel.Заголовок = Кратко;
		Элементы.DetailsRef.Подсказка    = Подробно;
		ПерейтиНаШагМастера(Элементы.ErrorOccurredStep);
		Возврат;
	КонецЕсли;

	Если ТекущаяСтраница = Элементы.PerformSearchStep Тогда
		ВсегоНайденоДублей = ЗаполнитьРезультатыПоискаДублей(Задание.АдресРезультата);
		ВсегоЭлементов = ВсегоНайденоДублей;
		Если ВсегоНайденоДублей > 0 Тогда
			ОбновитьОписаниеСостоянияНайденныхДублей(ЭтотОбъект);
			ПерейтиНаШагМастера(НастройкиМастера.ТекущийШаг.Индекс + 1);
		Иначе
			ПерейтиНаШагМастера(Элементы.ШагДублейНеНайдено);
		КонецЕсли;
	ИначеЕсли ТекущаяСтраница = Элементы.DeletionStep Тогда
		Успех = ЗаполнитьРезультатыУдаленияДублей(Задание.АдресРезультата);
		Если Успех = Истина Тогда
			// Заменены все группы дублей.
			ПерейтиНаШагМастера(НастройкиМастера.ТекущийШаг.Индекс + 1);
		Иначе
			// Не все места использования удалось заменить.
			ПерейтиНаШагМастера(Элементы.UnsuccessfulReplacementsStep);
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Функция ЗаполнитьРезультатыПоискаДублей(Знач АдресРезультата)
	
	// Получаем результат функции ГруппыДублей модуля обработки.
	Данные = ПолучитьИзВременногоХранилища(АдресРезультата);
	ОписаниеОшибкиПоискаДублей = Данные.ОписаниеОшибки;

	ЭлементыДерева = FoundDuplicates.ПолучитьЭлементы();
	ЭлементыДерева.Очистить();

	МестаИспользования = Данные.UsageInstances;
	ТаблицаДублей      = Данные.ТаблицаДублей;

	ФильтрСтрок = Новый Структура("Родитель");
	ФильтрМест  = Новый Структура("Ссылка");

	ВсегоНайденоДублей = 0;

	ВсеГруппы = ТаблицаДублей.НайтиСтроки(ФильтрСтрок);
	Для Каждого Группа Из ВсеГруппы Цикл
		ФильтрСтрок.Родитель = Группа.Ссылка;
		ЭлементыГруппы = ТаблицаДублей.НайтиСтроки(ФильтрСтрок);

		ГруппаДерева = ЭлементыДерева.Добавить();
		ГруппаДерева.Count = ЭлементыГруппы.Количество();
		ГруппаДерева.Check = 1;

		МаксСтрока = Неопределено;
		МаксМест   = -1;
		Для Каждого Элемент Из ЭлементыГруппы Цикл
			СтрокаДерева = ГруппаДерева.ПолучитьЭлементы().Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаДерева, Элемент, "Ссылка, Code, Description");
			СтрокаДерева.Check = 1;

			ФильтрМест.Ссылка = Элемент.Ссылка;
			СтрокаДерева.Count = МестаИспользования.НайтиСтроки(ФильтрМест).Количество();

			Если МаксМест < СтрокаДерева.Count Тогда
				Если МаксСтрока <> Неопределено Тогда
					МаксСтрока.Main = Ложь;
				КонецЕсли;
				МаксСтрока = СтрокаДерева;
				МаксМест   = СтрокаДерева.Count;
				МаксСтрока.Main = Истина;
			КонецЕсли;

			ВсегоНайденоДублей = ВсегоНайденоДублей + 1;
		КонецЦикла;
		
		// Устанавливаем кандидата по максимальной ссылке.
		ГруппаДерева.Description = МаксСтрока.Description + " (" + ГруппаДерева.Count + ")";
	КонецЦикла;
	
	// Места использования сохраняем для дальнейшего фильтра.
	CandidateUsageInstances.Очистить();
	Элементы.CurrentDuplicatesGroupDetails.Заголовок = НСтр("ru = 'Дублей не найдено'");

	Если ЭтоАдресВременногоХранилища(АдресМестИспользования) Тогда
		УдалитьИзВременногоХранилища(АдресМестИспользования);
	КонецЕсли;
	АдресМестИспользования = ПоместитьВоВременноеХранилище(МестаИспользования, УникальныйИдентификатор);
	Возврат ВсегоНайденоДублей;

КонецФункции

&НаСервере
Функция ЗаполнитьРезультатыУдаленияДублей(Знач АдресРезультата)
	// ТаблицаОшибок - результат функции ЗаменитьСсылки модуля.
	ТаблицаОшибок = ПолучитьИзВременногоХранилища(АдресРезультата);

	Если ЭтоАдресВременногоХранилища(АдресРезультатаЗамены) Тогда
		УдалитьИзВременногоХранилища(АдресРезультатаЗамены);
	КонецЕсли;

	ЗавершеноБезОшибок = ТаблицаОшибок.Количество() = 0;
	ПоследнийКандидат  = Неопределено;

	Если ЗавершеноБезОшибок Тогда
		ВсегоОбработано = 0;
		ВсегоОсновных   = 0;
		Для Каждого ГруппаДублей Из FoundDuplicates.ПолучитьЭлементы() Цикл
			Если ГруппаДублей.Check Тогда
				Для Каждого Кандидат Из ГруппаДублей.ПолучитьЭлементы() Цикл
					Если Кандидат.Main Тогда
						ПоследнийКандидат = Кандидат.Ссылка;
						ВсегоОбработано   = ВсегоОбработано + 1;
						ВсегоОсновных     = ВсегоОсновных + 1;
					ИначеЕсли Кандидат.Check Тогда
						ВсегоОбработано = ВсегоОбработано + 1;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;

		Если ВсегоОсновных = 1 Тогда
			// Много дублей в один элемент.
			Если ПоследнийКандидат = Неопределено Тогда
				FoundDuplicatesStateDetails = Новый ФорматированнаяСтрока(СтрШаблон(
						НСтр("ru = 'Все найденные дубли (%1) успешно объединены'"), ВсегоОбработано));
			Иначе
				ПоследнийКандидатСтрокой = UT_Common.SubjectString(ПоследнийКандидат);
				FoundDuplicatesStateDetails = Новый ФорматированнаяСтрока(СтрШаблон(
						НСтр("ru = 'Все найденные дубли (%1) успешно объединены
							 |в ""%2""'"), ВсегоОбработано, ПоследнийКандидатСтрокой));
			КонецЕсли;
		Иначе
			// Много дублей во много групп.
			FoundDuplicatesStateDetails = Новый ФорматированнаяСтрока(СтрШаблон(
					НСтр("ru = 'Все найденные дубли (%1) успешно объединены.
						 |Оставлено элементов (%2).'"), ВсегоОбработано, ВсегоОсновных));
		КонецЕсли;
	КонецЕсли;

	UnprocessedDuplicates.ПолучитьЭлементы().Очистить();
	UnprocessedDuplicatesUsageInstances.Очистить();
	CandidateUsageInstances.Очистить();

	Если ЗавершеноБезОшибок Тогда
		FoundDuplicates.ПолучитьЭлементы().Очистить();
		Возврат Истина;
	КонецЕсли;
	
	// Сохраняем для последующего доступа при анализе ссылок.
	АдресРезультатаЗамены = ПоместитьВоВременноеХранилище(ТаблицаОшибок, УникальныйИдентификатор);
	
	// Формируем дерево дублей по ошибкам.
	ЗначениеВРеквизитФормы(РеквизитФормыВЗначение("FoundDuplicates"), "UnprocessedDuplicates");
	
	// Анализируем оставшихся
	Фильтр = Новый Структура("Ссылка");
	Родители = UnprocessedDuplicates.ПолучитьЭлементы();
	ПозицияРодителя = Родители.Количество() - 1;
	Пока ПозицияРодителя >= 0 Цикл
		Родитель = Родители[ПозицияРодителя];

		Потомки = Родитель.ПолучитьЭлементы();
		ПозицияПотомка = Потомки.Количество() - 1;
		ОсновнойПотомок = Потомки[0];	// Там есть минимум один

		Пока ПозицияПотомка >= 0 Цикл
			Потомок = Потомки[ПозицияПотомка];

			Если Потомок.Main Тогда
				ОсновнойПотомок = Потомок;
				Фильтр.Ссылка = Потомок.Ссылка;
				Потомок.Count = ТаблицаОшибок.НайтиСтроки(Фильтр).Количество();

			ИначеЕсли ТаблицаОшибок.Найти(Потомок.Ссылка, "Ссылка") = Неопределено Тогда
				// Был успешно удален, нет ошибок.
				Потомки.Удалить(Потомок);

			Иначе
				Фильтр.Ссылка = Потомок.Ссылка;
				Потомок.Count = ТаблицаОшибок.НайтиСтроки(Фильтр).Количество();

			КонецЕсли;

			ПозицияПотомка = ПозицияПотомка - 1;
		КонецЦикла;

		КоличествоПотомков = Потомки.Количество();
		Если КоличествоПотомков = 1 И Потомки[0].Main Тогда
			Родители.Удалить(Родитель);
		Иначе
			Родитель.Count = КоличествоПотомков - 1;
			Родитель.Description = ОсновнойПотомок.Description + " (" + КоличествоПотомков + ")";
		КонецЕсли;

		ПозицияРодителя = ПозицияРодителя - 1;
	КонецЦикла;

	Возврат Ложь;
КонецФункции

&НаКлиенте
Процедура AfterConfirmCancelJob(Ответ, ПараметрыВыполнения) Экспорт
	Если Ответ = КодВозвратаДиалога.Прервать Тогда
		НастройкиМастера.ПоказатьДиалогПередЗакрытием = Ложь;
		Закрыть();
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Служебные процедуры и функции мастера

&НаКлиентеНаСервереБезКонтекста
Функция КнопкаМастера()
	// Описание настроек кнопки мастера.
	//
	// Возвращаемое значение:
	//   Структура - Настройки кнопки формы.
	//       * Заголовок         - Строка - Заголовок кнопки.
	//       * Подсказка         - Строка - Подсказка для кнопки.
	//       * Видимость         - Булево - Когда Истина то кнопка видна. Значение по умолчанию: Истина.
	//       * Доступность       - Булево - Когда Истина то кнопку можно нажимать. Значение по умолчанию: Истина.
	//       * КнопкаПоУмолчанию - Булево - Когда Истина то кнопка будет Main кнопкой формы. Значение по умолчанию:
	//                                      Ложь.
	//
	// См. также:
	//   "КнопкаФормы" в синтакс-помощнике.
	//
	Результат = Новый Структура;
	Результат.Вставить("Заголовок", "");
	Результат.Вставить("Подсказка", "");

	Результат.Вставить("Доступность", Истина);
	Результат.Вставить("Видимость", Истина);
	Результат.Вставить("КнопкаПоУмолчанию", Ложь);

	Возврат Результат;
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьСвойстваКнопкиМастера(КнопкаМастера, Описание)

	ЗаполнитьЗначенияСвойств(КнопкаМастера, Описание);
	КнопкаМастера.РасширеннаяПодсказка.Заголовок = Описание.Подсказка;

КонецПроцедуры

#КонецОбласти