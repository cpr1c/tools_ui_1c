&AtClient
Procedure GroupFieldsNotAvailable()

	Items.GroupFieldsPages.CurrentPage = Items.UnavailableGroupFieldsSettings;

EndProcedure

&AtClient
Procedure SelectedFieldsAvailable(SettingsItem)

	If Report.SettingsComposer.Settings.HasItemSelection(SettingsItem) Then

		LocalSelectedFields = True;
		Items.SelectionFieldsPages.CurrentPage = Items.SelectedFieldsSettings;

	Else

		LocalSelectedFields = False;
		Items.SelectionFieldsPages.CurrentPage = Items.DisabledSelectedFieldsSettings;

	EndIf;

	Items.LocalSelectedFields.ReadOnly = False;

EndProcedure

&AtClient
Procedure SettingsOnActivateRow(Item)
	SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
		Items.Structure.CurrentLine);
	ItemType = TypeOf(SettingsItem);

	If ItemType = Undefined Or ItemType = Type("DataCompositionChartStructureItemCollection")
		Or ItemType = Type("DataCompositionTableStructureItemCollection") Then

		GroupFieldsNotAvailable();
		SelectedFieldsUnavailable();
		FilterUnavailable();
		OrderUnavailable();
		ConditionalAppearanceUnavailable();
		OutputParametersUnavailable();

	ElsIf ItemType = Type("DataCompositionSettings") Or ItemType = Type(
		"DataCompositionNestedObjectSettings") Then

		GroupFieldsNotAvailable();

		LocalSelectedFields = True;
		Items.LocalSelectedFields.ReadOnly = True;
		Items.SelectionFieldsPages.CurrentPage = Items.SelectedFieldsSettings;

		LocalFilter = True;
		Items.LocalFilter.ReadOnly = True;
		Items.FilterPages.CurrentPage = Items.FilterSettings;

		LocalOrder = True;
		Items.LocalOrder.ReadOnly = True;
		Items.OrderPages.CurrentPage = Items.OrderSettings;

		LocalConditionalAppearance = True;
		Items.LocalConditionalAppearance.ReadOnly = True;
		Items.ConditionalAppearancePages.CurrentPage = Items.ConditionalAppearanceSettings;

		LocalOutputParameters = True;
		Items.LocalOutputParameters.ReadOnly = True;
		Items.OutputParametersPages.CurrentPage = Items.OutputParametersSettings;

	ElsIf ItemType = Type("DataCompositionGroup") Or ItemType = Type(
		"DataCompositionTableGroup") Or ItemType = Type("DataCompositionChartGroup") Then

		Items.GroupFieldsPages.CurrentPage = Items.GroupFieldsSettings;

		SelectedFieldsAvailable(SettingsItem);
		FilterAvailable(SettingsItem);
		OrderAvailable(SettingsItem);
		ConditionalAppearanceAvailable(SettingsItem);
		OutputParametersAvailable(SettingsItem);

	ElsIf ItemType = Type("DataCompositionTable") Or ItemType = Type("DataCompositionChart") Then

		GroupFieldsNotAvailable();
		SelectedFieldsAvailable(SettingsItem);
		FilterUnavailable();
		OrderUnavailable();
		ConditionalAppearanceAvailable(SettingsItem);
		OutputParametersAvailable(SettingsItem);

	EndIf;
EndProcedure

&AtClient
Procedure SelectedFieldsUnavailable()

	LocalSelectedFields = False;
	Items.LocalSelectedFields.ReadOnly = True;
	Items.SelectionFieldsPages.CurrentPage = Items.UnavailableSelectedFieldsSettings;

EndProcedure

&AtClient
Procedure FilterAvailable(SettingsItem)

	If Report.SettingsComposer.Settings.HasItemFilter(SettingsItem) Then

		LocalFilter = True;
		Items.FilterPages.CurrentPage = Items.FilterSettings;

	Else

		LocalFilter = False;
		Items.FilterPages.CurrentPage = Items.DisabledFilterSettings;

	EndIf;

	Items.LocalFilter.ReadOnly = False;

EndProcedure

&AtClient
Procedure FilterUnavailable()

	LocalFilter = False;
	Items.LocalFilter.ReadOnly = True;
	Items.FilterPages.CurrentPage = Items.UnavailableFilterSettings;

EndProcedure

&AtClient
Procedure OrderAvailable(SettingsItem)

	If Report.SettingsComposer.Settings.HasItemOrder(SettingsItem) Then

		LocalOrder = True;
		Items.OrderPages.CurrentPage = Items.OrderSettings;

	Else

		LocalOrder = False;
		Items.OrderPages.CurrentPage = Items.DisabledOrderSettings;

	EndIf;

	Items.LocalOrder.ReadOnly = False;

EndProcedure

&AtClient
Procedure OrderUnavailable()

	LocalOrder = False;
	Items.LocalOrder.ReadOnly = True;
	Items.OrderPages.CurrentPage = Items.UnavailableOrderSettings;

EndProcedure

&AtClient
Procedure ConditionalAppearanceAvailable(SettingsItem)

	If Report.SettingsComposer.Settings.HasItemConditionalAppearance(SettingsItem) Then

		LocalConditionalAppearance = True;
		Items.ConditionalAppearancePages.CurrentPage = Items.ConditionalAppearanceSettings;

	Else

		LocalConditionalAppearance = False;
		Items.ConditionalAppearancePages.CurrentPage = Items.DisabledConditionalAppearanceSettings;

	EndIf;

	Items.LocalConditionalAppearance.ReadOnly = False;

EndProcedure

&AtClient
Procedure ConditionalAppearanceUnavailable()

	LocalConditionalAppearance = False;
	Items.LocalConditionalAppearance.ReadOnly = True;
	Items.ConditionalAppearancePages.CurrentPage = Items.UnavailableConditionalAppearanceSettings;

EndProcedure

&AtClient
Procedure OutputParametersAvailable(SettingsItem)

	If Report.SettingsComposer.Settings.HasItemOutputParameters(SettingsItem) Then

		LocalOutputParameters = True;
		Items.OutputParametersPages.CurrentPage = Items.OutputParametersSettings;

	Else

		LocalOutputParameters = False;
		Items.OutputParametersPages.CurrentPage = Items.DisabledOutputParametersSettings;

	EndIf;

	Items.LocalOutputParameters.ReadOnly = False;

EndProcedure

&AtClient
Procedure OutputParametersUnavailable()

	LocalOutputParameters = False;
	Items.LocalOutputParameters.ReadOnly = True;
	Items.OutputParametersPages.CurrentPage = Items.UnavailableOutputParametersSettings;

EndProcedure

&AtClient
Procedure LocalSelectedFieldsOnChange(Item)
	If LocalSelectedFields Then

		Items.SelectionFieldsPages.CurrentPage = Items.SelectedFieldsSettings;

	Else

		Items.SelectionFieldsPages.CurrentPage = Items.DisabledSelectedFieldsSettings;

		SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentLine);
		Report.SettingsComposer.Settings.ClearItemSelection(SettingsItem);

	EndIf;
EndProcedure

&AtClient
Procedure SettingsOnActivateField(Item)
	Var SelectedPage;

	If Items.Structure.CurrentItem.Name = "StructureHasSelection" Then

		SelectedPage = Items.SelectionFieldsPage;

	ElsIf Items.Structure.CurrentItem.Name = "StructureHasFilter" Then

		SelectedPage = Items.FilterPage;

	ElsIf Items.Structure.CurrentItem.Name = "StructureHasOrder" Then

		SelectedPage = Items.OrderPage;

	ElsIf Items.Structure.CurrentItem.Name = "StructureHasConditionalAppearance" Then

		SelectedPage = Items.ConditionalAppearancePage;

	ElsIf Items.Structure.CurrentItem.Name = "StructureHasOutputParameters" Then

		SelectedPage = Items.OutputParametersPage;

	EndIf;

	If SelectedPage <> Undefined Then

		Items.SettingsPages.CurrentPage = SelectedPage;

	EndIf;
EndProcedure

&AtClient
Procedure GoToReport(Item)

	SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
		Items.Structure.CurrentLine);
	ItemSettings =  Report.SettingsComposer.Settings.ItemSettings(SettingsItem);
	Items.Structure.CurrentLine = Report.SettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

&AtClient
Procedure LocalFilterOnChange(Item)
	If LocalFilter Then

		Items.FilterPages.CurrentPage = Items.FilterSettings;

	Else

		Items.FilterPages.CurrentPage = Items.DisabledFilterSettings;

		SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentLine);
		Report.SettingsComposer.Settings.ClearItemFilter(SettingsItem);

	EndIf;

EndProcedure

&AtClient
Procedure LocalOrderOnChange(Item)
	If LocalOrder Then

		Items.OrderPages.CurrentPage = Items.OrderSettings;

	Else

		Items.OrderPages.CurrentPage = Items.DisabledOrderSettings;

		SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentLine);
		Report.SettingsComposer.Settings.ClearItemOrder(SettingsItem);

	EndIf;
EndProcedure

&AtClient
Procedure LocalConditionalAppearanceOnChange(Item)
	If LocalConditionalAppearance Then

		Items.ConditionalAppearancePages.CurrentPage = Items.ConditionalAppearanceSettings;

	Else

		Items.ConditionalAppearancePages.CurrentPage = Items.DisabledConditionalAppearanceSettings;

		SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentLine);
		Report.SettingsComposer.Settings.ClearItemConditionalAppearance(SettingsItem);

	EndIf;
EndProcedure

&AtClient
Procedure LocalOutputParametersOnChange(Item)
		If LocalOutputParameters Then

		Items.OutputParametersPages.CurrentPage = Items.OutputParametersSettings;

	Else

		Items.OutputParametersPages.CurrentPage = Items.DisabledOutputParametersSettings;

		SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentLine);
		Report.SettingsComposer.Settings.ClearItemOutputParameters(SettingsItem);
	EndIf;
	
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	StandardProcessing = False;
	If Parameters.ExecutedReportSchemaURL <> "" Then
		Report.SettingsComposer.Initialize(
			New DataCompositionAvailableSettingsSource(Parameters.ExecutedReportSchemaURL));
		Report.SettingsComposer.LoadSettings(Parameters.Variant);
	EndIf;
EndProcedure