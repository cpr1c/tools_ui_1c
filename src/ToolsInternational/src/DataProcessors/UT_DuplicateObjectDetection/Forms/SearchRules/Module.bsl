///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, 1C-Soft LLC
// All Rights reserved. This application and supporting materials are provided under the terms of 
// Attribution 4.0 International license (CC BY 4.0)
// The license text is available at:
// https://creativecommons.org/licenses/by/4.0/legalcode
// Translated by Neti Company
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Parameters:
//
//     DuplicatesSearchArea        - String               - a full name of the table metadata of the area selected for search.
//     FilterAreaPresentation - String - a presentation for title generation.
//     AppliedRulesDetails   - String, Undefined - a text of applied rules. If it is not specified,
//                                   there are no applied rules.
//
//     АдресНастроек - String - an address of the temporary settings storage. Structure with the following fields is expected:
//         ConsiderAppliedRules - Boolean - a previous settings flag is True by default.
//         SearchRules              - ValueTable - editable settings.
//             Attribute - String  - an attribute name to compare.
//             AttributePresentation - String - an attribute presentation to compare.
//             Rule - String - a selected comparison option: "Equal" is an equality match, "Like" is 
//                                 a similarity match, and "" means "ignore".
//             ComparisonOptions - ValueList - available comparison options, whose value is one of 
//                                                  the rule options.
//
// Return value:
// 
//	   Undefined - edit was cancelled.
//     String       - an address of the temporary storage of new settings. A structure similar to the SettingsAddress parameter.
//
#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	Parameters.Property("AppliedRulesDetails", AppliedRulesDetails);
	DuplicatesSearchArea = Parameters.DuplicatesSearchArea;

	Title = StrTemplate(NStr("ru = 'Правила поиска дублей ""%1""'; en = 'Duplicate search rule: %1'"), Parameters.FilterAreaPresentation);

	InitialSettings = GetFromTempStorage(Parameters.SettingsAddress);
	DeleteFromTempStorage(Parameters.SettingsAddress);
	InitialSettings.Property("ConsiderAppliedRules", ConsiderAppliedRules);

	If AppliedRulesDetails = Undefined Then
		Items.AppliedRestrictionsGroup.Visible = False;
		WindowOptionsKey = "NoAppliedRestrictionsGroup";
	Else
		Items.ConsiderAppliedRules.Visible = CanCancelAppliedRules();
	EndIf;
	
	// Filling and adjusting rules.
	SearchRules.Load(InitialSettings.SearchRules);
	For Each RuleRow In SearchRules Do
		RuleRow.Use = Not IsBlankString(RuleRow.Rule);
	EndDo;
	
	For Each Item In InitialSettings.AllComparisonOptions Do
		If Not IsBlankString(Item.Value) Then
			FillPropertyValues(AllSearchRulesComparisonTypes.Add(), Item);
		EndIf;
	EndDo;
	
	SetColorsAndConditionalAppearance();
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	ThisObject.RefreshDataRepresentation();
	
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure ConsiderAppliedRulesOnChange(Item)

	If ConsiderAppliedRules Then
		Return;
	EndIf;

	Details = New NotifyDescription("ClearingAppliedRulesUsageCompletion", ThisObject);
	
	TitleText = NStr("ru = 'Предупреждение'; en = 'Warning'");
	QuestionText   = NStr("ru = 'Внимание: поиск и удаление дублей элементов без учета поставляемых ограничений
	                            |может привести к рассогласованию данных в программе.
	                            |
	                            |Отключить использование поставляемых ограничений?'; 
	                            |en = 'Warning: deleting duplicates with the default restrictions
	                            |turned off might result in data inconsistency.
	                            |
	                            |Do you still want to turn off the default restrictions?'");
	
	ShowQueryBox(Details, QuestionText, QuestionDialogMode.YesNo,,DialogReturnCode.No, TitleText);
EndProcedure

#EndRegion

#Region FormTableItemsEventHandlersSearchRules

&AtClient
Procedure SearchRulesSelection(Item, RowSelected, Field, StandardProcessing)
	ColumnName = Field.Name;
	If ColumnName = "SearchRulesComparisonType" Then
		StandardProcessing = False;
		SelectComparisonType();
	EndIf;
EndProcedure

&AtClient
Procedure SearchRulesUseOnChange(Item)
	TableRow = Items.SearchRules.CurrentData;
	If TableRow.Use Then
		If IsBlankString(TableRow.Rule) And TableRow.ComparisonOptions.Count() > 0 Then
			TableRow.Rule = TableRow.ComparisonOptions[0].Value
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure SearchRulesComparisonTypeStartChoice(Item, ChoiceData, StandardProcessing)
	StandardProcessing = False;
	SelectComparisonType();
EndProcedure

#EndRegion

#Region FormCommandHandlers

&AtClient
Procedure CompleteEditing(Command)
	SelectionErrorsText = SelectionErrors();
	If SelectionErrorsText <> Undefined Then
		ShowMessageBox(, SelectionErrorsText);
		Return;
	EndIf;
	
	NotifyChoice(SelectionResult());
EndProcedure

#EndRegion

#Область СлужебныеПроцедурыИФункции

&AtClient
Procedure SelectComparisonType()
	TableRow = Items.SearchRules.CurrentData;
	If TableRow = Undefined Then
		Return;
	EndIf;
	
	ChoiceList = TableRow.ComparisonOptions;
	Count = ChoiceList.Count();
	If Count = 0 Then
		Return;
	EndIf;
	
	Context = New Structure("IDRow", TableRow.GetID());
	Handler = New NotifyDescription("ComparisonTypeSelectionCompletion", ThisObject, Context);
	If Count = 1 And Not TableRow.Use Then
		ExecuteNotifyProcessing(Handler, ChoiceList[0]);
		Return;
	EndIf;
	
	ShowChooseFromMenu(Handler, ChoiceList);
EndProcedure

&AtClient
Procedure ComparisonTypeSelectionCompletion(Result, Context) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	TableRow = SearchRules.FindByID(Context.IDRow);
	If TableRow = Undefined Then
		Return;
	EndIf;
	
	TableRow.Rule      = Result.Value;
	TableRow.Use = True;
EndProcedure

&AtClient
Function SelectionErrors()
	
	If AppliedRulesDetails <> Undefined And ConsiderAppliedRules Then
		// There are application rules and they are used. There are no errors.
		Return Undefined;
	EndIf;
	
	For Each RulesRow In SearchRules Do
		If RulesRow.Use Then
			// User rule is specified. There are no errors.
			Return Undefined;
		EndIf;
	EndDo;
	
	Return NStr("ru ='Необходимо указать хотя бы одно правило поиска дублей.'; en = 'Specify at least one duplicate search rule.'");
EndFunction

&AtClient
Procedure ClearingAppliedRulesUsageCompletion(Val Response, Val AdditionalParameters) Export
	If Response = DialogReturnCode.Yes Then
		Return; 
	EndIf;

	ConsiderAppliedRules = True;
EndProcedure

&AtServerNoContext
Function CanCancelAppliedRules()
	
	Result = AccessRight("DataAdministration", Metadata);
	Return Result;
	
EndFunction

&AtServer
Function SelectionResult()
	
	Result = New Structure;
	Result.Insert("ConsiderAppliedRules", ConsiderAppliedRules);

	SelectedRules = SearchRules.Unload();
	For Each RulesRow In SelectedRules  Do
		If Not RulesRow.Use Then
			RulesRow.Rule = "";
		EndIf;
	EndDo;
	SelectedRules.Columns.Delete("Use");
	
	Result.Insert("SearchRules", SelectedRules);
	
	Return PutToTempStorage(Result);
EndFunction

&AtServer
Procedure SetColorsAndConditionalAppearance()
	ConditionalAppearanceItems = ConditionalAppearance.Items;
	ConditionalAppearanceItems.Clear();
	
	InaccessibleDataColor = StyleColorOrAuto("InaccessibleDataColor", 192, 192, 192);
	
	For Each ListItem In AllSearchRulesComparisonTypes Do
		AppearanceItem = ConditionalAppearanceItems.Add();
		
		AppearanceFilter = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
		AppearanceFilter.LeftValue = New DataCompositionField("SearchRules.Rule");
		AppearanceFilter.ComparisonType = DataCompositionComparisonType.Equal;
		AppearanceFilter.RightValue = ListItem.Value;
		
		AppearanceField = AppearanceItem.Fields.Items.Add();
		AppearanceField.Field = New DataCompositionField("SearchRulesComparisonType");
		
		AppearanceItem.Appearance.SetParameterValue("Text", ListItem.Presentation);
	EndDo;
	
	// Do not use
	AppearanceItem = ConditionalAppearanceItems.Add();
	
	AppearanceFilter = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	AppearanceFilter.LeftValue = New DataCompositionField("SearchRules.Use");
	AppearanceFilter.ComparisonType = DataCompositionComparisonType.Equal;
	AppearanceFilter.RightValue = False;
	
	AppearanceField = AppearanceItem.Fields.Items.Add();
	AppearanceField.Field = New DataCompositionField("SearchRulesComparisonType");
	
	AppearanceItem.Appearance.SetParameterValue("TextColor", InaccessibleDataColor);
EndProcedure

&AtServerNoContext
Function StyleColorOrAuto(Val Name, Val Red = Undefined, Green = Undefined, Blue = Undefined)

	StyleItem = Metadata.StyleItems.Find(Name);
	If StyleItem <> Undefined And StyleItem.Type = Metadata.ObjectProperties.StyleElementType.Color Then
		Return StyleColors[Name];
	EndIf;
	
	Return ?(Red = Undefined, New Color, New Color(Red, Green, Blue));
EndFunction

#EndRegion