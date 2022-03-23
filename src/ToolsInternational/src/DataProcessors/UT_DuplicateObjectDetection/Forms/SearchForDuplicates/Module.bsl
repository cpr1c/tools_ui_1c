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

	FormSettings = UT_Common.CommonSettingsStorageLoad(FormName, "");
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
	SaveUserSettings();
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
	FormParameters.Insert("AppliedRulesDetails",   AppliedRulesDetails);
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
		UnprocessedDuplicatesUsageInstances.Clear();
		
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
	UnprocessedDuplicatesUsageInstances.Load(Data);
	
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
// Wizard events

&AtClient
Procedure OnActivateWizardStep()
	
	CurrentPage = Items.WizardSteps.CurrentPage;
	
	If CurrentPage = Items.NoSearchPerformedStep Then
		
		Items.Header.Enabled = True;
		
		// Filter rule presentation.
		FilterRulesPresentation = String(PrefilterComposer.Settings.Filter);
		If IsBlankString(FilterRulesPresentation) Then
			FilterRulesPresentation = NStr("ru = 'Все элементы'; en = 'All items'");
		EndIf;
		
		// Search rule presentation.
		Conjunction = " " + NStr("ru = 'И'; en = 'AND'") + " ";
		RulesText = "";
		For Each Rule In SearchRules Do
			If Rule.Rule = "Equal" Then
				Comparison = Rule.AttributePresentation + " " + NStr("ru = 'совпадает'; en = 'match'");
			ElsIf Rule.Rule = "Like" Then
				Comparison = Rule.AttributePresentation + " " + NStr("ru = 'совпадает по похожим словам'; en = 'fuzzy match'");
			Else
				Continue;
			EndIf;
			RulesText = ?(RulesText = "", "", RulesText + Conjunction) + Comparison;
		EndDo;
		If ConsiderAppliedRules Then
			For Position = 1 To StrLineCount(AppliedRulesDetails) Do
				RuleRow = TrimAll(StrGetLine(AppliedRulesDetails, Position));
				If Not IsBlankString(RuleRow) Then
					RulesText = ?(RulesText = "", "", RulesText + Conjunction) + RuleRow;
				EndIf;
			EndDo;
		EndIf;
		If IsBlankString(RulesText) Then
			RulesText = NStr("ru = 'Правила не заданы'; en = 'No rules set'");
		EndIf;
		SearchRulesPresentation = RulesText;
		
		// Availability.
		Items.FilterRulesPresentation.Enabled = Not IsBlankString(DuplicatesSearchArea);
		Items.SearchRulesPresentation.Enabled = Not IsBlankString(DuplicatesSearchArea);

	ElsIf CurrentPage = Items.PerformSearchStep Then
		
		If Not IsTempStorageURL(CompositionSchemaAddress) Then
			Return; // Not initialized.
		EndIf;
		Items.Header.Enabled = False;
		WizardSettings.ShowDialogBeforeClose = True;
		FindAndDeleteDuplicatesClient();

	ElsIf CurrentPage = Items.MainItemSelectionStep Then
		
		Items.Header.Enabled = True;
		Items.RetrySearch.Visible = True;
		ExpandDuplicatesGroupHierarchically();

	ElsIf CurrentPage = Items.DeletionStep Then
		
		Items.Header.Enabled = False;
		WizardSettings.ShowDialogBeforeClose = True;
		FindAndDeleteDuplicatesClient();

	ElsIf CurrentPage = Items.SuccessfulDeletionStep Then
		
		Items.Header.Enabled = False;
		
	ElsIf CurrentPage = Items.UnsuccessfulReplacementsStep Then
		
		Items.Header.Enabled = False;
		
	ElsIf CurrentPage = Items.DuplicatesNotFoundStep Then
		
		Items.Header.Enabled = True;
		If IsBlankString(DuplicatesSearchErrorDescription) Then
			Message = NStr("ru = 'Не обнаружено дублей по указанным параметрам.'; en = 'No duplicates found by the specified parameters.'");
		Else	
			Message = DuplicatesSearchErrorDescription;
		EndIf;	
		Items.DuplicatesNotFound.StatePresentation.Text = Message + Chars.LF 
			+ NStr("ru = 'Измените условия и нажмите ""Найти дубли""'; en = 'Edit the criteria and click Find duplicates.'");
		
	ElsIf CurrentPage = Items.ErrorOccurredStep Then
		
		Items.Header.Enabled = True;
		Items.DetailsRef.Visible = ValueIsFilled(Items.DetailsRef.ToolTip);
		
	EndIf;
	
EndProcedure

&AtClient
Procedure WizardStepNext()
	
	ClearMessages();
	CurrentPage = Items.WizardSteps.CurrentPage;
	
	If CurrentPage = Items.NoSearchPerformedStep Then
		
		If IsBlankString(DuplicatesSearchArea) Then
			ShowMessageBox(, NStr("ru = 'Необходимо выбрать область поиска дублей'; en = 'Select search area'"));
			Return;
		EndIf;
		
		GoToWizardStep(WizardSettings.CurrentStep.IndexOf + 1);
		
	ElsIf CurrentPage = Items.MainItemSelectionStep Then
		
		Items.RetrySearch.Visible = False;
		GoToWizardStep(WizardSettings.CurrentStep.IndexOf + 1);
		
	ElsIf CurrentPage = Items.UnsuccessfulReplacementsStep Then
		
		GoToWizardStep(Items.DeletionStep);
		
	ElsIf CurrentPage = Items.DuplicatesNotFoundStep Then
		
		GoToWizardStep(Items.PerformSearchStep);
		
	Else
		
		GoToWizardStep(WizardSettings.CurrentStep.IndexOf + 1);
		
	EndIf;
	
EndProcedure

&AtClient
Procedure WizardStepBack()
	
	CurrentPage = Items.WizardSteps.CurrentPage;
	
	If CurrentPage = Items.SuccessfulDeletionStep Then
		
		GoToWizardStep(Items.NoSearchPerformedStep);
		
	Else
		
		GoToWizardStep(WizardSettings.CurrentStep.IndexOf - 1);
		
	EndIf;
	
EndProcedure

&AtClient
Procedure WizardStepCancel()
	
	CurrentPage = Items.WizardSteps.CurrentPage;
	
	If CurrentPage = Items.PerformSearchStep Or CurrentPage = Items.DeletionStep Then
		
		WizardSettings.ShowDialogBeforeClose = False;
		
	EndIf;
	
	If IsOpen() Then
		Close();
	EndIf;
	
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Client

&AtClient
Function FullFormName(ShortFormName)
	Names = StrSplit(FormName, ".");
	Return Names[0] + "." + Names[1] + ".Form." + ShortFormName;
EndFunction

&AtClient
Procedure OpenDuplicateForm(Val CurrentData)
	If CurrentData = Undefined Or Not ValueIsFilled(CurrentData.Ref) Then
		Return;
	EndIf;
	
	ShowValue(,CurrentData.Ref);
EndProcedure
&AtClient
Procedure ShowUsageInstances(SourceTree)
	RefsArray = New Array;
	For Each DuplicatesGroup In SourceTree.GetItems() Do
		For Each TreeRow In DuplicatesGroup.GetItems() Do
			RefsArray.Add(TreeRow.Ref);
		EndDo;
	EndDo;
	
	ReportParameters = New Structure;
	ReportParameters.Insert("Filter", New Structure("RefSet", RefsArray));
	WindowMode = FormWindowOpeningMode.LockOwnerWindow;
	ОткрытьФорму("Отчет.МестаИспользованияСсылок.Форма", ПараметрыОтчета, ЭтотОбъект, , , , , РежимОкна);
EndProcedure

&AtClient
Procedure ExpandDuplicatesGroupHierarchically(Val DataString = Undefined)
	If DataString <> Undefined Then
		Items.FoundDuplicates.Expand(DataString, True);
	EndIf;
	
	// All items of the first level
	AllRows = Items.FoundDuplicates;
	For Each RowData In FoundDuplicates.GetItems() Do 
		AllRows.Expand(RowData.GetID(), True);
	EndDo;
EndProcedure

&AtClient
Procedure CollapseDuplicatesGroupHierarchically(Val DataString = Undefined)
	If DataString <> Undefined Then
		Items.FoundDuplicates.Collapse(DataString);
		Return;
	EndIf;
	
	// All items of the first level
	AllRows = Items.FoundDuplicates;
	For Each RowData In FoundDuplicates.GetItems() Do 
		AllRows.Collapse(RowData.GetID());
	EndDo;
EndProcedure

&AtClient
Procedure ChangeCandidatesMarksHierarchically(Val RowData)
	SetMarksDown(RowData);
	SetMarksUp(RowData);
EndProcedure

&AtClient
Procedure SetMarksDown(Val RowData)
	Value = RowData.Check;
	For Each Child In RowData.GetItems() Do
		Child.Check = Value;
		SetMarksDown(Child);
	EndDo;
EndProcedure

&AtClient
Procedure SetMarksUp(Val RowData)
	RowParent = RowData.GetParent();
	
	If RowParent <> Undefined Then
		AllTrue = True;
		NotAllFalse = False;
		
		For Each Child In RowParent.GetItems() Do
			AllTrue = AllTrue AND (Child.Check = 1);
			NotAllFalse = NotAllFalse Or (Child.Check > 0);
		EndDo;
		
		If AllTrue Then
			RowParent.Check = 1;
			
		ElsIf NotAllFalse Then
			RowParent.Check = 2;
			
		Else
			RowParent.Check = 0;
			
		EndIf;
		
		SetMarksUp(RowParent);
	EndIf;
	
EndProcedure

&AtClient
Procedure ChangeMainItemHierarchically(Val RowData, Val Parent)
	For Each Child In Parent.GetItems() Do
		Child.Main = False;
	EndDo;
	RowData.Main = True;
	
	// Selected item is always used.
	RowData.Check = 1;
	ChangeCandidatesMarksHierarchically(RowData);
	
	// Changing the group name
	Parent.Description = RowData.Description + " (" + Parent.Count + ")";
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Client, Server

&AtClientAtServerNoContext
Procedure UpdateFoundDuplicatesStateDetails(Form)
	
	If IsBlankString(Form.DuplicatesSearchErrorDescription) Then
		Details = StrTemplate(
			NStr("ru = 'Выбрано дублей: %1 из %2.'; en = 'Selected duplicates: %1 out of %2.'"),
			Form.TotalFoundDuplicates, Form.TotalItems);
	Else	
		Details = Form.DuplicatesSearchErrorDescription;
	EndIf;
	
	Form.FoundDuplicatesStateDetails = New FormattedString(Details + Chars.LF
		+ NStr("ru = 'Выбранные элементы будут помечены на удаление и заменены на оригиналы (отмечены стрелкой).'; en = 'The selected items will be marked for deletion and replaced by originals.'"),
		, Form.InformationTextColor);
	
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Server call, Server

&AtServer
Function FilterComposerSettingsAddress()
	Return PutToTempStorage(PrefilterComposer.Settings, UUID);
EndFunction

&AtServer
Function SearchRulesSettingsAddress()
	Settings = New Structure;
	Settings.Insert("ConsiderAppliedRules", ConsiderAppliedRules);
	Settings.Insert("AllComparisonOptions", AllComparisonOptions);
	Settings.Insert("SearchRules", FormAttributeToValue("SearchRules"));
	Return PutToTempStorage(Settings);
EndFunction

&AtServer
Procedure UpdateFilterComposer(ResultAddress)
	Result = GetFromTempStorage(ResultAddress);
	DeleteFromTempStorage(ResultAddress);
	PrefilterComposer.LoadSettings(Result);
	PrefilterComposer.Refresh(DataCompositionSettingsRefreshMethod.Full);
	SaveUserSettings();
EndProcedure

&AtServer
Procedure UpdateSearchRules(ResultAddress)
	Result = GetFromTempStorage(ResultAddress);
	DeleteFromTempStorage(ResultAddress);
	TakeAppliedRulesIntoAccount = Result.TakeAppliedRulesIntoAccount;
	ValueToFormAttribute(Result.SearchRules, "SearchRules");
	SaveUserSettings();
EndProcedure

&AtServer
Procedure InitializeFilterComposerAndRules(FormSettings)
	// 1. Clearing and initializing information about the metadata object.
	FilterRulesPresentation = "";
	SearchRulesPresentation = "";
	
	SettingsTable = GetFromTempStorage(SettingsAddress);
	SettingsTableRow = SettingsTable.Find(DuplicatesSearchArea, "FullName");
	If SettingsTableRow = Undefined Then
		DuplicatesSearchArea = "";
		Return;
	EndIf;
	
	MetadataObject = Metadata.FindByFullName(DuplicatesSearchArea);
	
	// 2. Initializing a DCS used for filters.
	CompositionSchema = New DataCompositionSchema;
	DataSource = CompositionSchema.DataSources.Add();
	DataSource.DataSourceType = "Local";
	
	DataSet = CompositionSchema.DataSets.Add(Type("DataCompositionSchemaDataSetQuery"));
	DataSet.Query = "SELECT " + AvailableFilterAttributes(MetadataObject) + " FROM " + DuplicatesSearchArea;
	DataSet.AutoFillAvailableFields = True;
	
	CompositionSchemaAddress = PutToTempStorage(CompositionSchema, UUID);
	
	PrefilterComposer.Initialize(New DataCompositionAvailableSettingsSource(CompositionSchema));
	
	// 3. Filling in the SearchRules table.
	RulesTable = FormAttributeToValue("SearchRules");
	RulesTable.Clear();
	
	IgnoredAttributes = New Structure("DeletionMark, Ref, Predefined, PredefinedDataName, IsFolder");
	AddMetaAttributesRules(RulesTable, IgnoredAttributes, AllComparisonOptions, MetadataObject.StandardAttributes, FuzzySearch1);
	AddMetaAttributesRules(RulesTable, IgnoredAttributes, AllComparisonOptions, MetadataObject.Attributes, FuzzySearch1);
	
	// 4. Importing saved values.
	FiltersImported = False;
	DCSettings = UT_CommonClientServer.StructureProperty(FormSettings, "DCSettings");
	If TypeOf(DCSettings) = Type("DataCompositionSettings") Then
		PrefilterComposer.LoadSettings(DCSettings);
		FiltersImported = True;
	EndIf;

	RulesImported = False;
	SavedRules = UT_CommonClientServer.StructureProperty(FormSettings, "SearchRules");
	If TypeOf(SavedRules) = Type("ValueTable") Then
		RulesImported = True;
		For Each SavedRule In SavedRules Do
			Rule = RulesTable.Find(SavedRule.Attribute, "Attribute");
			If Rule <> Undefined
				And Rule.ComparisonOptions.FindByValue(SavedRule.Rule) <> Undefined Then
				Rule.Rule = SavedRule.Rule;
			EndIf;
		EndDo;
	EndIf;
	
	// 5. Setting defaults.
	// Filtering by deletion mark.
	If Not FiltersImported Then
		UT_CommonClientServer.SetFilterItem(
			PrefilterComposer.Settings.Filter, "DeletionMark", False,
			DataCompositionComparisonType.Equal, , False);
	EndIf;
	// Comparing by description.
	If Not RulesImported Then
		Rule = RulesTable.Find("Description", "Attribute");
		If Rule <> Undefined Then
			ValueToCompare = ?(FuzzySearch1, "Like", "Equal");
			If Rule.ComparisonOptions.FindByValue(ValueToCompare) <> Undefined Then
				Rule.Rule = ValueToCompare;
			EndIf;
		EndIf;
	EndIf;
	
	// 6. Extension functionality in applied rules.
	AppliedRuleDetails = Undefined;
	If SettingsTableRow.EventDuplicateSearchParameters Then
		DefaultParameters = New Structure;
		DefaultParameters.Insert("SearchRules",        RulesTable);
		DefaultParameters.Insert("ComparisonRestrictions", New Array);
		DefaultParameters.Insert("FilterComposer",    PrefilterComposer);
		DefaultParameters.Insert("ItemsCountToCompare", 1000);
		MetadataObjectManager = UT_Common.ObjectManagerByFullName(MetadataObject.FullName());
		//@skip-warning
		MetadataObjectManager.DuplicatesSearchParameters(DefaultParameters);
		
		// Presentation of applied rules.
		AppliedRuleDetails = "";
		For Each Details In DefaultParameters.ComparisonRestrictions Do
			AppliedRuleDetails = AppliedRuleDetails + Chars.LF + Details.Presentation;
		EndDo;
		AppliedRuleDetails = TrimAll(AppliedRuleDetails);
	EndIf;
	
	PrefilterComposer.Refresh(DataCompositionSettingsRefreshMethod.Full);
	
	RulesTable.Sort("AttributePresentation");
	ValueToFormAttribute(RulesTable, "SearchRules");
	
	If FormSettings = Undefined Then
		SaveUserSettings();
	EndIf;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Server

&AtServer
Procedure OnCreateAtServerDataInitialization(FormSettings)
	TakeAppliedRulesIntoAccount = UT_CommonClientServer.StructureProperty(FormSettings, "TakeAppliedRulesIntoAccount");
	DuplicatesSearchArea        = UT_CommonClientServer.StructureProperty(FormSettings, "DuplicatesSearchArea");

	SettingsTable = DataProcessors.UT_DuplicateObjectDetection.MetadataObjectSettings();
	SettingsAddress = PutToTempStorage(SettingsTable, UUID);
	
	ChoiceList = Items.DuplicatesSearchArea.ChoiceList;
	For Each TableRow In SettingsTable Do
		ChoiceList.Add(TableRow.FullName, TableRow.ListPresentation, , PictureLib[TableRow.Kind]);
	EndDo;
	
	AllComparisonOptions.Add("Equal",   NStr("ru = 'Совпадает'; en = 'Match'"));
	AllComparisonOptions.Add("Like", NStr("ru = 'Совпадает по похожим словам'; en = 'Fuzzy match'"));
EndProcedure

&AtServer
Procedure SaveUserSettings()
	FormSettings = New Structure;
	FormSettings.Insert("ConsiderAppliedRules", ConsiderAppliedRules);
	FormSettings.Insert("DuplicatesSearchArea", DuplicatesSearchArea);
	FormSettings.Insert("DCSettings", PrefilterComposer.Settings);
	FormSettings.Insert("SearchRules", SearchRules.Unload());
	UT_Common.CommonSettingsStorageSave(FormName, "", FormSettings);
EndProcedure

&AtServer
Procedure SetColorsAndConditionalAppearance()
	InformationTextColor       = StyleColorOrAuto("NoteText",       69,  81,  133);
	ErrorInformationTextColor = StyleColorOrAuto("ErrorNoteText", 255, 0,   0);
	InaccessibleDataColor     = StyleColorOrAuto("InaccessibleDataColor", 192, 192, 192);
	
	ConditionalAppearanceItems = ConditionalAppearance.Items;
	ConditionalAppearanceItems.Clear();
	
	// No usage instances of the group.
	AppearanceItem = ConditionalAppearanceItems.Add();
	
	AppearanceFilter = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	AppearanceFilter.LeftValue = New DataCompositionField("FoundDuplicates.Ref");
	AppearanceFilter.ComparisonType = DataCompositionComparisonType.NotFilled;
	AppearanceFilter.RightValue = True;
	
	AppearanceItem.Appearance.SetParameterValue("Text", "");
	
	AppearanceField = AppearanceItem.Fields.Items.Add();
	AppearanceField.Field = New DataCompositionField("FoundDuplicatesCount");
	
	// 1. Row with the current main group item:
	
	// Picture
	AppearanceItem = ConditionalAppearanceItems.Add();
	
	AppearanceFilter = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	AppearanceFilter.LeftValue = New DataCompositionField("FoundDuplicates.Main");
	AppearanceFilter.ComparisonType = DataCompositionComparisonType.Equal;
	AppearanceFilter.RightValue = True;
	
	AppearanceItem.Appearance.SetParameterValue("Visible", True);
	AppearanceItem.Appearance.SetParameterValue("Show", True);
	
	AppearanceField = AppearanceItem.Fields.Items.Add();
	AppearanceField.Field = New DataCompositionField("FoundDuplicatesMain");
	
	// Mark cleared
	AppearanceItem = ConditionalAppearanceItems.Add();
	
	AppearanceFilter = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	AppearanceFilter.LeftValue = New DataCompositionField("FoundDuplicates.Main");
	AppearanceFilter.ComparisonType = DataCompositionComparisonType.Equal;
	AppearanceFilter.RightValue = True;
	
	AppearanceItem.Appearance.SetParameterValue("Visible", False);
	AppearanceItem.Appearance.SetParameterValue("Show", False);
	
	AppearanceField = AppearanceItem.Fields.Items.Add();
	AppearanceField.Field = New DataCompositionField("FoundDuplicatesCheck");
	
	// 2. Row with a usual item.
	
	// Picture
	AppearanceItem = ConditionalAppearanceItems.Add();
	
	AppearanceFilter = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	AppearanceFilter.LeftValue = New DataCompositionField("FoundDuplicates.Main");
	AppearanceFilter.ComparisonType = DataCompositionComparisonType.Equal;
	AppearanceFilter.RightValue = False;
	
	AppearanceItem.Appearance.SetParameterValue("Visible", False);
	AppearanceItem.Appearance.SetParameterValue("Show", False);
	
	AppearanceField = AppearanceItem.Fields.Items.Add();
	AppearanceField.Field = New DataCompositionField("FoundDuplicatesMain");
	
	// Mark selected
	AppearanceItem = ConditionalAppearanceItems.Add();
	
	AppearanceFilter = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	AppearanceFilter.LeftValue = New DataCompositionField("FoundDuplicates.Main");
	AppearanceFilter.ComparisonType = DataCompositionComparisonType.Equal;
	AppearanceFilter.RightValue = False;
	
	AppearanceItem.Appearance.SetParameterValue("Visible", True);
	AppearanceItem.Appearance.SetParameterValue("Show", True);
	
	AppearanceField = AppearanceItem.Fields.Items.Add();
	AppearanceField.Field = New DataCompositionField("FoundDuplicatesCheck");
	
	// 3. Usage instances
	AppearanceItem = ConditionalAppearanceItems.Add();
	
	AppearanceFilter = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	AppearanceFilter.LeftValue = New DataCompositionField("FoundDuplicates.Ref");
	AppearanceFilter.ComparisonType = DataCompositionComparisonType.Filled;
	AppearanceFilter.RightValue = True;
	
	AppearanceFilter = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	AppearanceFilter.LeftValue = New DataCompositionField("FoundDuplicates.Count");
	AppearanceFilter.ComparisonType = DataCompositionComparisonType.Equal;
	AppearanceFilter.RightValue = 0;
	
	AppearanceItem.Appearance.SetParameterValue("Text", NStr("ru = '-'; en = '-'"));
	
	AppearanceField = AppearanceItem.Fields.Items.Add();
	AppearanceField.Field = New DataCompositionField("FoundDuplicatesCount");
	
	// 4. Inactive row
	AppearanceItem = ConditionalAppearanceItems.Add();
	
	AppearanceFilter = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	AppearanceFilter.LeftValue = New DataCompositionField("FoundDuplicates.Check");
	AppearanceFilter.ComparisonType = DataCompositionComparisonType.Equal;
	AppearanceFilter.RightValue = 0;
	
	AppearanceItem.Appearance.SetParameterValue("TextColor", InaccessibleDataColor);
	
	AppearanceField = AppearanceItem.Fields.Items.Add();
	AppearanceField.Field = New DataCompositionField("FoundDuplicates");

EndProcedure

&AtServer
Function StyleColorOrAuto(Val Name, Val Red = Undefined, Green = Undefined, Blue = Undefined)
	StyleItem = Metadata.StyleItems.Find(Name);
	If StyleItem <> Undefined AND StyleItem.Type = Metadata.ObjectProperties.StyleElementType.Color Then
		Return StyleColors[Name];
	EndIf;
	
	Return ?(Red = Undefined, New Color, New Color(Red, Green, Blue));
EndFunction

&AtServer
Function DuplicatesReplacementPairs()
	ReplacementPairs = New Map;
	
	DuplicatesTree = FormAttributeToValue("FoundDuplicates");
	SearchFilter = New Structure("Main", True);
	
	For Each Parent In DuplicatesTree.Rows Do
		MainInGroup = Parent.Rows.FindRows(SearchFilter)[0].Ref;
		
		For Each Child In Parent.Rows Do
			If Child.Check = 1 Then 
				ReplacementPairs.Insert(Child.Ref, MainInGroup);
			EndIf;
		EndDo;
	EndDo;
	
	Return ReplacementPairs;
EndFunction

&AtServerNoContext
Function AvailableFilterAttributes(MetadataObject)
	AttributesArray = New Array;
	For Each AttributeMetadata In MetadataObject.StandardAttributes Do
		If Not AttributeMetadata.Type.ContainsType(Type("ValueStorage")) Then
			AttributesArray.Add(AttributeMetadata.Name);
		EndIf;
	EndDo;
	For Each AttributeMetadata In MetadataObject.Attributes Do
		If Not AttributeMetadata.Type.ContainsType(Type("ValueStorage")) Then
			AttributesArray.Add(AttributeMetadata.Name);
		EndIf;
	EndDo;
	Return StrConcat(AttributesArray, ",");
EndFunction

&AtServerNoContext
Procedure AddMetaAttributesRules(RulesTable, Val Ignore, Val AllComparisonOptions, Val MetaCollection, Val FuzzySearchAvailable)
	
	For Each MetaAttribute In MetaCollection Do
		If Not Ignore.Property(MetaAttribute.Name) Then
			ComparisonOptions = ComparisonOptionsForType(MetaAttribute.Type, AllComparisonOptions, FuzzySearchAvailable);
			If ComparisonOptions <> Undefined Then
				// Can be compared
				RulesRow = RulesTable.Add();
				RulesRow.Attribute          = MetaAttribute.Name;
				RulesRow.ComparisonOptions = ComparisonOptions;
				
				AttributePresentation = MetaAttribute.Synonym;
				RulesRow.AttributePresentation = ?(IsBlankString(AttributePresentation), MetaAttribute.Name, AttributePresentation);
			EndIf;
		EndIf;
	EndDo;
	
EndProcedure

&AtServerNoContext
Function ComparisonOptionsForType(Val AvailableTypes, Val AllComparisonOptions, Val FuzzySearchAvailable) 
	
	IsStorage = AvailableTypes.ContainsType(Type("ValueStorage"));
	If IsStorage Then 
		// Cannot be compared
		Return Undefined;
	EndIf;
	
	IsString = AvailableTypes.ContainsType(Type("String"));
	IsFixedString = IsString And AvailableTypes.StringQualifiers <> Undefined 
		And AvailableTypes.StringQualifiers.Length <> 0;
		
	If IsString And Not IsFixedString Then
		// Cannot be compared
		Return Undefined;
	EndIf;
	
	Result = New ValueList;
	FillPropertyValues(Result.Add(), AllComparisonOptions[0]);		// Matches
	
	If FuzzySearchAvailable And IsString Then
		FillPropertyValues(Result.Add(), AllComparisonOptions[1]);	// Similar
	EndIf;
		
	Return Result;
EndFunction

////////////////////////////////////////////////////////////////////////////////
// Time-consuming operations

&AtClient
Procedure FindAndDeleteDuplicatesClient()
	
	Job = FindAndDeleteDuplicates();
	
	WaitSettings = UT_TimeConsumingOperationsClient.IdleParameters(ThisObject);
	WaitSettings.OutputIdleWindow = False;
	WaitSettings.OutputProgressBar = True;
	WaitSettings.ExecutionProgressNotification = New NotifyDescription("FindAndRemoveDuplicatesProgress", ThisObject);
	Handler = New NotifyDescription("FindAndRemoveDuplicatesCompletion", ThisObject);
	UT_TimeConsumingOperationsClient.WaitForCompletion(Job, Handler, WaitSettings);
	
EndProcedure

&AtServer
Function FindAndDeleteDuplicates()
	
	ProcedureParameters = New Structure;
	ProcedureParameters.Insert("ConsiderAppliedRules", ConsiderAppliedRules);
	
	CurrentPage = Items.WizardSteps.CurrentPage;
	If CurrentPage = Items.PerformSearchStep Then
		
		Items.PerformSearch.StatePresentation.Text = NStr("ru = 'Поиск дублей...'; en = 'Searching for duplicates...'");

		ProcedureName = FormAttributeToValue("Object").Metadata().FullName() + ".ObjectModule.BackgroundSearchForDuplicates";
		MethodDescription = NStr("ru = 'Поиск и удаление дублей: Поиск дублей'; en = 'Duplicate purge: Search for duplicates'");
		ProcedureParameters.Insert("DuplicatesSearchArea",     DuplicatesSearchArea);
		ProcedureParameters.Insert("MaxDuplicates", 1500);
		SearchRulesArray = New Array;
		For Each Rule In SearchRules Do
			SearchRulesArray.Add(New Structure("Attribute, Rule", Rule.Attribute, Rule.Rule));
		EndDo;
		ProcedureParameters.Insert("SearchRules", SearchRulesArray);
		ProcedureParameters.Insert("CompositionSchema", GetFromTempStorage(CompositionSchemaAddress));
		ProcedureParameters.Insert("PrefilterComposerSettings", PrefilterComposer.Settings);

	ElsIf CurrentPage = Items.DeletionStep Then
		
		Items.Deletion.StatePresentation.Text = NStr("ru = 'Удаление дублей...'; en = 'Deleting duplicates...'");
		
		ProcedureName = FormAttributeToValue("Object").Metadata().FullName() + ".ObjectModule.BackgroundDuplicateDeletion";
		MethodDescription = NStr("ru = 'Поиск и удаление дублей: Удаление дублей'; en = 'Duplicate purge: Delete duplicates'");
		ProcedureParameters.Insert("ReplacementPairs", DuplicatesReplacementPairs());
		ProcedureParameters.Insert("WriteParameters", UT_CommonClientServer.FormWriteSettings(ThisObject));
		ProcedureParameters.Insert("ConsiderAppliedRules", ConsiderAppliedRules);
		ProcedureParameters.Insert("ReplaceInTransaction", ReplaceInTransaction);
	Else
		Raise NStr("ru = 'Некорректное состояние в НайтиИУдалитьДубли.'; en = 'Invalid status in FindAndDeleteDuplicates.'");
	EndIf;
	
	StartSettings = UT_TimeConsumingOperations.BackgroundExecutionParameters(UUID);
	StartSettings.BackgroundJobDescription = MethodDescription;
	
	Return UT_TimeConsumingOperations.ExecuteInBackground(ProcedureName, ProcedureParameters, StartSettings);
EndFunction

&AtClient
Procedure FindAndRemoveDuplicatesProgress(Progress, AdditionalParameters) Export
	
	If Progress = Undefined Or Progress.Progress = Undefined Then
		Return;
	EndIf;
	
	CurrentPage = Items.WizardSteps.CurrentPage;
	If CurrentPage = Items.PerformSearchStep Then
		
		Message = NStr("ru = 'Поиск дублей...'; en = 'Searching for duplicates...'");
		If Progress.Progress.Text = "CalculateUsageInstances" Then 
			Message = NStr("ru = 'Выполняется расчет мест использования дублей...'; en = 'Searching for duplicate locations...'");
		ElsIf Progress.Progress.Percent > 0 Then
			Message = Message + " " + StrTemplate(
					NStr("ru = '(найдено %1)'; en = '(%1 locations found)'"), Progress.Progress.Percent);
		EndIf;
		Items.PerformSearch.StatePresentation.Text = Message;

	ElsIf CurrentPage = Items.DeletionStep Then
		
		Message = NStr("ru = 'Удаление дублей...'; en = 'Deleting duplicates...'");
		If Progress.Progress.Percent > 0 Then
			Message = Message + " " + StrTemplate(
					NStr("ru = '(удалено %1 из %2)'; en = '(%1 out of %2 deleted)'"), Progress.Progress.Percent, TotalDuplicatesFound);
		EndIf;
		Items.Deletion.StatePresentation.Text = Message;
		
	EndIf;
	
EndProcedure

&AtClient
Procedure FindAndRemoveDuplicatesCompletion(Job, AdditionalParameters) Export
	WizardSettings.ShowDialogBeforeClose = False;
	Activate();
	CurrentPage = Items.WizardSteps.CurrentPage;
	
	// The job is canceled.
	If Job = Undefined Then 
		Return;
	EndIf;
	
	If Job.Status <> "Completed" Then
		// Background job is completed with error.
		If CurrentPage = Items.PerformSearchStep Then
			Brief = NStr("ru = 'При поиске дублей возникла ошибка:'; en = 'Error occurred searching for duplicates:'");
		ElsIf CurrentPage = Items.DeletionStep Then
			Brief = NStr("ru = 'При удалении дублей возникла ошибка:'; en = 'Error occurred deleting duplicates:'");
		EndIf;
		Brief = Brief + Chars.LF + Job.BriefErrorPresentation;
		More = Brief + Chars.LF + Chars.LF + Job.DetailedErrorPresentation;
		Items.ErrorTextLabel.Title = Brief;
		Items.DetailsRef.ToolTip    = More;
		GoToWizardStep(Items.ErrorOccurredStep);
		Return;
	EndIf;

	If CurrentPage = Items.PerformSearchStep Then
		TotalFoundDuplicates = FillDuplicatesSearchResults(Job.ResultAddress);
		TotalItems = TotalFoundDuplicates;
		If TotalFoundDuplicates > 0 Then
			UpdateFoundDuplicatesStateDetails(ThisObject);
			GoToWizardStep(WizardSettings.CurrentStep.IndexOf + 1);
		Else
			GoToWizardStep(Items.DuplicatesNotFoundStep);
		EndIf;
	ElsIf CurrentPage = Items.DeletionStep Then
		Success = FillDuplicatesDeletionResults(Job.ResultAddress);
		If Success = True Then
			// All duplicate groups are replaced.
			GoToWizardStep(WizardSettings.CurrentStep.IndexOf + 1);
		Else
			// Cannot replace all usage instances.
			GoToWizardStep(Items.UnsuccessfulReplacementsStep);
		EndIf;
	EndIf;
	
EndProcedure

&AtServer
Function FillDuplicatesSearchResults(Val ResultAddress)
	
	// Getting the result of the DuplicatesGroups function of the data processor module.
	Data = GetFromTempStorage(ResultAddress);
	DuplicatesSearchErrorDescription = Data.ErrorDescription;
	
	TreeItems = FoundDuplicates.GetItems();
	TreeItems.Clear();
	
	UsageInstances = Data.UsageInstances;
	DuplicatesTable      = Data.DuplicatesTable;
	
	RowsFilter = New Structure("Parent");
	InstancesFilter  = New Structure("Ref");
	
	TotalFoundDuplicates = 0;

	AllGroups = DuplicatesTable.FindRows(RowsFilter);
	For Each Folder In AllGroups Do
		RowsFilter.Parent = Folder.Ref;
		GroupItems = DuplicatesTable.FindRows(RowsFilter);
		
		TreeGroup = TreeItems.Add();
		TreeGroup.Count = GroupItems.Count();
		TreeGroup.Check = 1;
		
		MaxRow = Undefined;
		MaxInstances   = -1;
		For Each Item In GroupItems Do
			TreeRow = TreeGroup.GetItems().Add();
			FillPropertyValues(TreeRow, Item, "Ref, Code, Description");
			TreeRow.Check = 1;
			
			InstancesFilter.Ref = Item.Ref;
			TreeRow.Count = UsageInstances.FindRows(InstancesFilter).Count();
			
			If MaxInstances < TreeRow.Count Then
				If MaxRow <> Undefined Then
					MaxRow.Main = False;
				EndIf;
				MaxRow = TreeRow;
				MaxInstances   = TreeRow.Count;
				MaxRow.Main = True;
			EndIf;
			
			TotalFoundDuplicates = TotalFoundDuplicates + 1;
		EndDo;
		
		// Setting a candidate by the maximum reference.
		TreeGroup.Description = MaxRow.Description + " (" + TreeGroup.Count + ")";
	EndDo;
	
	// Saving usage instances for further filter.
	CandidateUsageInstances.Clear();
	Items.CurrentDuplicatesGroupDetails.Title = NStr("ru = 'Дублей не найдено'; en = 'No duplicates found'");
	
	If IsTempStorageURL(UsageInstancesAddress) Then
		DeleteFromTempStorage(UsageInstancesAddress);
	EndIf;
	UsageInstancesAddress = PutToTempStorage(UsageInstances, UUID);
	Return TotalFoundDuplicates;
	
EndFunction

&AtServer
Function FillDuplicatesDeletionResults(Val ResultAddress)
	// ErrorsTable - a result of the ReplaceReferences object module function.
	ErrorsTable = GetFromTempStorage(ResultAddress);
	
	If IsTempStorageURL(ReplacementResultAddress) Then
		DeleteFromTempStorage(ReplacementResultAddress);
	EndIf;
	
	CompletedWithoutErrors = ErrorsTable.Count() = 0;
	LastCandidate  = Undefined;
	
	If CompletedWithoutErrors Then
		ProcessedItemsTotal = 0; 
		MainItemsTotal   = 0;
		For Each DuplicatesGroup In FoundDuplicates.GetItems() Do
			If DuplicatesGroup.Check Then
				For Each Candidate In DuplicatesGroup.GetItems() Do
					If Candidate.Main Then
						LastCandidate = Candidate.Ref;
						ProcessedItemsTotal   = ProcessedItemsTotal + 1;
						MainItemsTotal     = MainItemsTotal + 1;
					ElsIf Candidate.Check Then 
						ProcessedItemsTotal = ProcessedItemsTotal + 1;
					EndIf;
				EndDo;
			EndIf;
		EndDo;

		If MainItemsTotal = 1 Then
			// Multiple duplicates to one item.
			If LastCandidate = Undefined Then
				FoundDuplicatesStateDetails = New FormattedString(StrTemplate(
						NStr("ru = 'Все найденные дубли (%1) успешно объединены'; en = 'All %1 duplicates have been merged.'"),
						ProcessedItemsTotal));
			Else
				LastCandidateAsString = UT_Common.SubjectString(LastCandidate);
				FoundDuplicatesStateDetails = New FormattedString(StrTemplate(
						NStr("ru = 'Все найденные дубли (%1) успешно объединены
							|в ""%2""'; 
							|en = 'All %1 duplicates have been merged
							|into %2.'"),
						ProcessedItemsTotal, LastCandidateAsString));
			КонецЕсли;
		Else
			// Multiple duplicates to multiple groups.
			FoundDuplicatesStateDetails = New FormattedString(StrTemplate(
					NStr("ru = 'Все найденные дубли (%1) успешно объединены.
						|Оставлено элементов (%2).'; 
						|en = 'All %1 duplicates have been merged.
						|Number of resulted items: %2.'"),
					ProcessedItemsTotal,
					MainItemsTotal));
		EndIf;
	EndIf;

	UnprocessedDuplicates.GetItems().Clear();
	UnprocessedDuplicatesUsageInstances.Clear();
	CandidateUsageInstances.Clear();

	If CompletedWithoutErrors Then
		FoundDuplicates.GetItems().Clear();
		Return True;
	EndIf;
	
	// Saving for further access when analyzing references.
	ReplacementResultAddress = PutToTempStorage(ErrorsTable, UUID);
	
	// Generating a duplicate tree by errors.
	ValueToFormAttribute(FormAttributeToValue("FoundDuplicates"), "UnprocessedDuplicates");
	
	// Analyzing the remains
	Filter = New Structure("Ref");
	Parents = UnprocessedDuplicates.GetItems();
	ParentPosition = Parents.Count() - 1;
	While ParentPosition >= 0 Do
		Parent = Parents[ParentPosition];
		
		Children = Parent.GetItems();
		ChildPosition = Children.Count() - 1;
		MainChild = Children[0];	// There is at least one
		
		While ChildPosition >= 0 Do
			Child = Children[ChildPosition];
			
			If Child.Main Then
				MainChild = Child;
				Filter.Ref = Child.Ref;
				Child.Count = ErrorsTable.FindRows(Filter).Count();
				
			ElsIf ErrorsTable.Find(Child.Ref, "Ref") = Undefined Then
				// Successfully deleted, no errors.
				Children.Delete(Child);
				
			Else
				Filter.Ref = Child.Ref;
				Child.Count = ErrorsTable.FindRows(Filter).Count();
				
			EndIf;
			
			ChildPosition = ChildPosition - 1;
		EndDo;
		
		ChildrenCount = Children.Count();
		If ChildrenCount = 1 AND Children[0].Main Then
			Parents.Delete(Parent);
		Else
			Parent.Count = ChildrenCount - 1;
			Parent.Description = MainChild.Description + " (" + ChildrenCount + ")";
		EndIf;
		
		ParentPosition = ParentPosition - 1;
	EndDo;

	Return False;
EndFunction

&AtClient
Procedure AfterConfirmCancelJob(Response, ExecutionParameters) Export
	If Response = DialogReturnCode.Abort Then
		WizardSettings.ShowDialogBeforeClose = False;
		Close();
	EndIf;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Internal wizard procedures and functions

&AtClientAtServerNoContext
Function WizardButton()
	// Description of wizard button settings.
	//
	// Returns:
	//   Structure - Form button settings.
	//       * Title         - String - a button title.
	//       * Tooltip - String - a tooltip for the button.
	//       * Visible - Boolean - if True, the button is visible. The default value is True.
	//       * Availability - Boolean - if True, you can click the button. The default value is True.
	//       * DefaultButton - Boolean - if True, the button is the main button of the form. Default value:
	//                                      False.
	//
	// See also:
	//   "FormButton" in Syntax Assistant.
	//
	Result = New Structure;
	Result.Insert("Title", "");
	Result.Insert("ToolTip", "");
	
	Result.Insert("Enabled", True);
	Result.Insert("Visible", True);
	Result.Insert("DefaultButton", False);
	
	Return Result;
EndFunction

&AtClientAtServerNoContext
Procedure UpdateWizardButtonProperties(WizardButton, Details)
	
	FillPropertyValues(WizardButton, Details);
	WizardButton.ExtendedTooltip.Title = Details.ToolTip;
	
EndProcedure

#EndRegion