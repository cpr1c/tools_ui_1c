&AtClient
Var DataSetsTypes;

&AtClient
Var DataSetFieldsTypes;

#Region FormEvents
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	InitializeForm();

	If Parameters.Property("DCS") Then
		ChoiceMode=True;
		If IsTempStorageURL(Parameters.DCS) Then
			DCS=GetFromTempStorage(Parameters.DCS);
		Else
			Try
				XMLReader = New XMLReader;
				XMLReader.SetString(Parameters.DCS);
				DCS= XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionSchema"));
			Except
				DCS=Undefined;
			EndTry;
		EndIf;

		If DCS <> Undefined Then
			ReadDCSToFormData(DCS);
		EndIf;
	EndIf;

	If Not ChoiceMode Then
		ThisForm.CommandBarLocation=FormCommandBarLabelLocation.None;
	EndIf;
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing,
		Items.GroupCommandsReadSaveDCS);

EndProcedure
&AtClient
Procedure OnOpen(Cancel)
	If IsTempStorageURL(InitialDataCompositionSchemaURL) Then
		FillResourcesAuxuliaryData();
	EndIf;
EndProcedure
#EndRegion

#Region FormItemsEvents

&AtClient
Procedure GroupEditorTabsOnCurrentPageChange(Item, CurrentPage)
	If CurrentPage = Items.GroupPageDataSetLinks Then
		FillDataSetLinksAuxuliaryData();
	ElsIf CurrentPage = Items.GroupPageResources Then
		FillResourcesAuxuliaryData();
	ElsIf CurrentPage = Items.GroupPageSettings Then
		AssembleDCSFromFormData();
	EndIf;
EndProcedure

#Region DataSets

&AtClient
Procedure DataSetsSelection(Item, RowSelected, Field, StandardProcessing)
	If RowSelected <> ZerothDataSetURL Then
		Return;
	EndIf;

	StandardProcessing=False;

	If Items.DataSets.Expanded(RowSelected) Then
		Items.DataSets.Collapse(RowSelected);
	Else
		Items.DataSets.Expand(RowSelected, True);
	EndIf;
	
EndProcedure

&AtClient
Procedure DataSetsBeforeDeleteRow(Item, Cancel)
	If Items.DataSets.CurrentRow = ZerothDataSetURL Then
		Cancel=True;
	EndIf;
EndProcedure

&AtClient
Procedure DataSetsBeforeRowChange(Item, Cancel)
	If Items.DataSets.CurrentRow = ZerothDataSetURL Then
		Cancel=True;
	EndIf;
EndProcedure

&AtClient
Procedure DataSetsBeforeAddRow(Item, Cancel, Clone, Parent, IsFolder, Parameter)
	Cancel=True;
EndProcedure

&AtClient
Procedure MoveDataSetsTreeRow(MovableRow, NewParent, Level = 0)

	If Level = 0 Then

		NewRow = NewParent.GetItems().Add();
		FillPropertyValues(NewRow, MovableRow, , "Fields");
		For Each FieldRow In MovableRow.Fields Do
			NewRow=NewRow.Fields.Add();
			FillPropertyValues(NewRow, FieldRow, , "DataCompositionOrderExpressions");

			For Each OrderRow In FieldRow.DataCompositionOrderExpressions Do
				NewOrder=NewRow.DataCompositionOrderExpressions.Add();
				FillPropertyValues(NewOrder, OrderRow);
			EndDo;
		EndDo;

		MoveDataSetsTreeRow(MovableRow, NewRow, Level + 1);

		If MovableRow.GetParent() = Undefined Then
			DataSets.GetItems().Delete(MovableRow);
		Else
			MovableRow.GetParent().GetItems().Delete(MovableRow);
		EndIf;

		Items.DataSets.CurrentRow=NewRow.GetID();
	Else

		For Each Row In MovableRow.GetItems() Do
			NewRow = NewParent.GetItems().Add();
			FillPropertyValues(NewRow, MovableRow, , "Fields");
			For Each FieldRow In MovableRow.Fields Do
				NewRow=NewRow.Fields.Add();
				FillPropertyValues(NewRow, FieldRow, , "DataCompositionOrderExpressions");

				For Each OrderRow In FieldRow.DataCompositionOrderExpressions Do
					NewOrder=NewRow.DataCompositionOrderExpressions.Add();
					FillPropertyValues(NewOrder, OrderRow);
				EndDo;
			EndDo;

			MoveDataSetsTreeRow(Row, NewRow, Level + 1);
		EndDo;

	EndIf;

EndProcedure

&AtClient
Procedure DataSetsDrag(Item, DragParameters, StandardProcessing, Row, Field)
	StandardProcessing=False;

	If DragParameters.Action <> DragAction.Move Then
		Return;
	EndIf;

	DestinationDataSetRow=DataSets.FindByID(Row);
	MovableRow=DataSets.FindByID(DragParameters.Value);
	ParentDataSet=MovableRow.GetParent();
	MoveDataSetsTreeRow(MovableRow, DestinationDataSetRow);
	
	If ParentDataSet.Type = DataSetsTypes.Union Then
		FillDataSetUnionFieldsByChildQuerys(ParentDataSet.GetID());
	EndIf;
	If DestinationDataSetRow.Type = DataSetsTypes.Union Then
		FillDataSetUnionFieldsByChildQuerys(DestinationDataSetRow.GetID());
	EndIf;
	
	//Now we need to refill fields in data sets - union	
EndProcedure

&AtClient
Procedure DataSetsDragCheck(Item, DragParameters, StandardProcessing, Row, Field)
	StandardProcessing=False;

	If DragParameters.Value = ZerothDataSetURL Then
		DragParameters.Action=DragAction.Cancel;
		Return;
	EndIf;

	MovableRow=DataSets.FindByID(DragParameters.Value);
	RowFrom=MovableRow.GetParent();
	If RowFrom.GetID() = Row Then
		DragParameters.Action=DragAction.Cancel;
	EndIf;

	RowWhere=DataSets.FindByID(Row);
	If RowWhere.Type <> DataSetsTypes.Root And RowWhere.Type <> DataSetsTypes.Union Then
		DragParameters.Action=DragAction.Cancel;
	EndIf;
EndProcedure

&AtClient
Procedure DataSetsOnActivateRow(Item)
	DataSetCurrentData=Items.DataSets.CurrentData;
	If DataSetCurrentData = Undefined Then
		Return;
	EndIf;
	If DataSetCurrentData.Type = DataSetsTypes.Root Then
		Items.GroupDataSetsRightPanel.CurrentPage=Items.GroupDataSetsRightPanelDataSources;
		Return;
	EndIf;

	Items.GroupDataSetsRightPanel.CurrentPage=Items.GroupDataSetsRightPanelDataSetData;

	DataSetCurrentData=Items.DataSets.CurrentData;
	Items.GroupDataSetSettingsEditingPanel.Visible=DataSetCurrentData.Type <> DataSetsTypes.Union;
	If DataSetCurrentData.Type = DataSetsTypes.Query Then
		Items.GroupDataSetSettingsEditingPanel.CurrentPage=Items.GroupPageDataSetQueryEditingPage;
	ElsIf DataSetCurrentData.Type = DataSetsTypes.Object Then
		Items.GroupDataSetSettingsEditingPanel.CurrentPage=Items.GroupPageDataSetObjectEditingPage;
	EndIf;

	Items.FieldsHierarchyCheckDataSet.ChoiceList.Clear();
	Items.FieldsHierarchyCheckDataSet.ChoiceList.Add("");

	For Each Set In TopLevelDataSets() Do
		If Set.Name = DataSetCurrentData.Name Then
			Continue;
		EndIf;

		Items.FieldsHierarchyCheckDataSet.ChoiceList.Add(Set.Name);
	EndDo;

	FillDatDataSetDataSourceChoiceList();
	SetAvailableOfAddDataSetFieldButtons();
EndProcedure
&AtClient
Procedure DataSetsFieldsOnActivateRow(Item)
	SetAvailableOfAddDataSetFieldButtons();
EndProcedure

&AtClient
Procedure DataSetsQueryOnChange(Item)
		FillDataSetFieldsOnQueryChange(Items.DataSets.CurrentRow);
EndProcedure

&AtClient
Procedure DataSetsFieldsRolePresentationStartChoice(Item, ChoiceData, StandardProcessing)
	StandardProcessing=False;

	CurrentData=Items.DataSetsFields.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	DataSetFieldsArray=New Array;
	DataSetRow=DataSets.FindByID(Items.DataSets.CurrentRow);
	For Each FieldRow In DataSetRow.Fields Do
		If FieldRow.DataPath = CurrentData.DataPath Then
			Continue;
		EndIf;

		DataSetFieldsArray.Add(FieldRow.DataPath);
	EndDo;

	FormParameters=New Structure;
	FormParameters.Insert("Role", CurrentData.Role);
	FormParameters.Insert("DataSetFieldsArray", DataSetFieldsArray);
	FormParameters.Insert("DataPath", CurrentData.DataPath);

	NotifyParameters=New Structure;
	NotifyParameters.Insert("RowID", Items.DataSetsFields.CurrentRow);
	NotifyParameters.Insert("DataSetRowID", Items.DataSets.CurrentRow);

	OpenForm("DataProcessor.UT_DCSEditor.Form.FormEditDataSetFieldRole", FormParameters, ThisObject, ,
		, , New NotifyDescription("DataSetsFieldsRolePresentationStartChoiceEND", ThisObject,
		NotifyParameters), FormWindowOpeningMode.LockOwnerWindow);
	
EndProcedure

&AtClient
Procedure FieldsAvailableValuesStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentData=Items.DataSetsFields.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	StandardProcessing=False;

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("RowID", CurrentData.GetID());
	AdditionalParameters.Insert("DataSetRowID", Items.DataSets.CurrentRow);

	UT_CommonClient.OpenValueListChoiceItemsForm(CurrentData.AvailableValues,
		New NotifyDescription("FieldsAvailableValuesStartChoiceEND", ThisObject, AdditionalParameters),
		NSTR("ru = 'Редактирование списка значений';en = 'Edit values list'"), CurrentData.ValueType, False, True, True, False,
		FormWindowOpeningMode.LockOwnerWindow);
	
EndProcedure

&AtClient
Procedure DataSetsFieldsOnStartEdit(Item, NewRow, Clone)
	If Not Clone Then
		Return;
	EndIf;

	CurrentRow=Items.DataSetsFields.CurrentData;
	If CurrentRow = Undefined Then
		Return;
	EndIf;

	DataSetCurrentRow=Items.DataSets.CurrentData;

	NumberAtEnd=UT_StringFunctionsClientServer.NumberAtStringEnd(CurrentRow.DataPath);

	If NumberAtEnd = Undefined Then
		CurrentRow.DataPath=CurrentRow.DataPath + CurrentRow.GetID();
	Else
		Suffix=Format(NumberAtEnd, "NG=0;");
		NewDataPath=CurrentRow.DataPath;
		UT_StringFunctionsClientServer.DeleteLastCharInString(NewDataPath, StrLen(Suffix));

		DataPath=NewDataPath + Format(NumberAtEnd + 1, "NG=0;");
		SearchStructure=New Structure;
		SearchStructure.Insert("DataPath", DataPath);

		FoundRows=DataSetCurrentRow.Fields.FindRows(SearchStructure);
		While FoundRows.Count() > 0 Do
			NumberAtEnd=NumberAtEnd + 1;
			DataPath=NewDataPath + Format(NumberAtEnd + 1, "NG=0;");

			SearchStructure=New Structure;
			SearchStructure.Insert("DataPath", DataPath);
			FoundRows=DataSetCurrentRow.Fields.FindRows(SearchStructure);

		EndDo;

		CurrentRow.DataPath=DataPath;
	EndIf;

	CurrentRow.Title=UT_StringFunctionsClientServer.IdentifierPresentation(CurrentRow.DataPath);
	If CurrentRow.Type <> DataSetFieldsTypes.Folder Then
		CurrentRow.Field=CurrentRow.DataPath;
	EndIf;

	SetAvailableOfAddDataSetFieldButtons();
EndProcedure

&AtClient
Procedure DataSetsAutoFillAvailableFieldsOnChange(Item)
	SetAvailableOfAddDataSetFieldButtons();
	FillDataSetFieldsOnQueryChangeAtServer(Items.DataSets.CurrentRow);
EndProcedure

&AtClient
Procedure DataSetsFieldsBeforeAddRow(Item, Cancel, Clone, Parent, IsFolder, Parameter)
		If Not Clone Then
		Cancel=True;
	Else
		Cancel=Not DataSetFieldCloneDeleteIsAvalible(Items.DataSets.CurrentData,
			Items.DataSetsFields.CurrentData);
	EndIf;
EndProcedure

&AtClient
Procedure DataSetsFieldsBeforeDeleteRow(Item, Cancel)
	Cancel=Not DataSetFieldCloneDeleteIsAvalible(Items.DataSets.CurrentData,
		Items.DataSetsFields.CurrentData);
EndProcedure

&AtClient
Procedure FieldsDataPathOnChange(Item)
	CurrentData=Items.DataSetsFields.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	CurrentData.Title=UT_StringFunctionsClientServer.IdentifierPresentation(CurrentData.DataPath);
EndProcedure

&AtClient
Procedure DataSetsFieldsOnEditEnd(Item, NewRow, CancelEdit)
	If CancelEdit Then
		Return;
	EndIf;
	
	DataSetRow=Items.DataSets.CurrentRow;
	DataSetRowData=DataSets.FindByID(DataSetRow);
	DataSetRowParent=DataSetRowData.GetParent();
	If DataSetRowParent.Type=DataSetsTypes.Union Then
		FillDataSetUnionFieldsByChildQuerys(DataSetRowParent.GetID());
	EndIf;
	
EndProcedure

&AtClient
Procedure FieldsValueTypeStartChoice(Item, ChoiceData, StandardProcessing)
	
	CurrentData=Items.DataSetsFields.CurrentData;
	If CurrentData=Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditType(CurrentData.ValueType, 2,StandardProcessing,ThisObject, New NotifyDescription("FieldsValueTypeStartChoiceEND",ThisObject, New Structure("CurrentRow",Items.DataSetsFields.CurrentRow)));

EndProcedure

#EndRegion

#Region DataSetLinks

&AtClient
Procedure DataSetLinksSourceDataSetOnChange(Item)
	CurrentData=Items.DataSetLinks.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	FillDataSetLinkFieldChoiceList(CurrentData.SourceDataSet, Items.DataSetLinksSourceExpression);

EndProcedure

&AtClient
Procedure DataSetLinksDestinationDataSetOnChange(Item)
	CurrentData=Items.DataSetLinks.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	FillDataSetLinkFieldChoiceList(CurrentData.DestinationDataSet, Items.DataSetLinksDestinationExpression);

EndProcedure


&AtClient
Procedure DataSetLinksBeforeRowChange(Item, Cancel)
	CurrentData=Items.DataSetLinks.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	FillDataSetLinkFieldChoiceList(CurrentData.SourceDataSet, Items.DataSetLinksSourceExpression);
	FillDataSetLinkFieldChoiceList(CurrentData.DestinationDataSet, Items.DataSetLinksDestinationExpression);

EndProcedure

#EndRegion

#Region Resources

&AtClient
Procedure ResourceAvailableFieldSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing=False;

	AddResource(RowSelected);
EndProcedure

&AtClient
Procedure ResourcesBeforeRowChange(Item, Cancel)
	FillResourceExpressionChoiceList(Item.CurrentRow);
EndProcedure
&AtClient
Procedure ResourcesExpressionOpening(Item, StandardProcessing)
		StandardProcessing=False;
	CurrentData=Items.Resources.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("RowID", Items.Resources.CurrentRow);

	UT_CommonClient.OpenTextEditingForm(CurrentData.Expression,
		New NotifyDescription("ResourcesExpressionOpeningEND", ThisObject, AdditionalParameters),
		NSTR("ru = 'Редактирование выражения ресурса для';en = 'Edit resource expression for '") + CurrentData.DataPath);
EndProcedure

&AtClient
Procedure ResourcesGroupsStartChoice(Item, ChoiceData, StandardProcessing)
		StandardProcessing=False;
	CurrentData=Items.Resources.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	AvailableGroupsList=New ValueList;
	For Each Row In ResourceAvailableFields Do
		Check= CurrentData.Groups.FindByValue(Row.DataPath) <> Undefined;
		AvailableGroupsList.Add(Row.DataPath, , Check);
	EndDo;

	Check= CurrentData.Groups.FindByValue("Overall") <> Undefined;

	AvailableGroupsList.Add("Overall", NSTR("ru = 'Общий итог';en = 'Overall'"), Check);

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("RowID", Items.Resources.CurrentRow);

	UT_CommonClient.OpenValueListChoiceItemsForm(AvailableGroupsList,
		New NotifyDescription("ResourcesGroupsStartChoiceEND", ThisObject, AdditionalParameters),
		"Fields Groups", , True, False, False, , FormWindowOpeningMode.LockOwnerWindow);
	
EndProcedure

#EndRegion

#Region CalculatedFields

&AtClient
Procedure CalculatedFieldsOnEditEnd(Item, NewRow, CancelEdit)
	FillResourcesAuxuliaryData();
EndProcedure

&AtClient
Procedure CalculatedFieldsAfterDeleteRow(Item)
	FillResourcesAuxuliaryData();
EndProcedure

&AtClient
Procedure CalculatedFieldsOnStartEdit(Item, NewRow, Clone)
	CurrentData=Items.CalculatedFields.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	If NewRow Then
		CurrentData.DataPath="Field" + CurrentData.GetID();
		CurrentData.Title=CurrentData.DataPath;
	EndIf;
EndProcedure

&AtClient
Procedure CalculatedFieldsExpressionOpening(Item, StandardProcessing)
		StandardProcessing=False;
	CurrentData=Items.CalculatedFields.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("RowID", Items.CalculatedFields.CurrentRow);

	UT_CommonClient.OpenTextEditingForm(CurrentData.Expression,
		New NotifyDescription("CalculatedFieldsExpressionOpeningEND", ThisObject, AdditionalParameters),
		NSTR("ru = 'Редактирование выражения ресурса для ';en = 'Edit resource expression for '") + CurrentData.DataPath);
EndProcedure

&AtClient
Procedure CalculatedFieldsAvailableValuesStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentData=Items.CalculatedFields.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	StandardProcessing=False;

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("RowID", CurrentData.GetID());

	UT_CommonClient.OpenValueListChoiceItemsForm(CurrentData.AvailableValues,
		New NotifyDescription("CalculatedFieldsAvailableValuesStartChoiceEND", ThisObject, AdditionalParameters),
		NSTR("ru = 'Редактирование списка значений';en = 'Edit values list'"), CurrentData.ValueType, False, True, True, False,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure


&AtClient
Procedure CalculatedFieldsDataPathOnChange(Item)
	CurrentData=Items.CalculatedFields.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	CurrentData.Title=UT_StringFunctionsClientServer.IdentifierPresentation(CurrentData.DataPath);
	
EndProcedure

&AtClient
Procedure CalculatedFieldsValueTypeStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentData=Items.CalculatedFields.CurrentData;
	If CurrentData=Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditType(CurrentData.ValueType, 2,StandardProcessing,ThisObject, New NotifyDescription("CalculatedFieldsValueTypeStartChoiceEND",ThisObject, New Structure("CurrentRow",Items.CalculatedFields.CurrentRow)));

EndProcedure

#EndRegion

#Region Parameters

&AtClient
Procedure DCSParametersOnStartEdit(Item, NewRow, Clone)
		CurrentData=Items.DCSParameters.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	If NewRow Then
		CurrentData.Name="Parameter" + CurrentData.GetID();
		CurrentData.Title=CurrentData.Name;
		CurrentData.IncludeInAvailableFields=True;
		CurrentData.AddedAutomatically=False;
	EndIf;

	SetParameterValueFieldChoiceList(CurrentData);
	SetParameterValueFieldTypeRestriction(CurrentData);
	
EndProcedure

&AtClient
Procedure DCSParametersValueTypeOnChange(Item)
		CurrentData=Items.DCSParameters.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	If CurrentData.ValueListAllowed Then
		NewValue=New ValueList;

		For Each ListItem In CurrentData.Value Do
			If CurrentData.ValueType.ContainsType(TypeOf(ListItem.Value)) Then
				NewValue.Add(ListItem.Value);
			EndIf;
		EndDo;
		CurrentData.Value=NewValue;
	Else
		CurrentData.Value=CurrentData.ValueType.AdjustValue(CurrentData.Value);
	EndIf;

	SetParameterValueFieldTypeRestriction(CurrentData);
EndProcedure

&AtClient
Procedure DCSParametersAvailableValuesStartChoice(Item, ChoiceData, StandardProcessing)
	
		StandardProcessing=False;

	CurrentData=Items.DCSParameters.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	If CurrentData.ValueType = New TypeDescription Then
		Return;
	EndIf;

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("RowID", CurrentData.GetID());

	UT_CommonClient.OpenValueListChoiceItemsForm(CurrentData.AvailableValues,
		New NotifyDescription("DCSParametersAvailableValuesStartChoiceEND", ThisObject, AdditionalParameters),
		NSTR("ru = 'Редактирование списка значений';en = 'Edit values list'"), CurrentData.ValueType, False, True, True, False,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure DCSParametersValueStartChoice(Item, ChoiceData, StandardProcessing)
	
		CurrentData=Items.DCSParameters.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	If CurrentData.ValueType = New TypeDescription Then
		Return;
	EndIf;

	If Not CurrentData.ValueListAllowed Then
		Return;
	EndIf;

	StandardProcessing=False;

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("RowID", CurrentData.GetID());

	AvailableValues=Undefined;
	If CurrentData.AvailableValues.Count() > 0 Then
		AvailableValues=CurrentData.AvailableValues;
	EndIf;

	UT_CommonClient.OpenValueListChoiceItemsForm(CurrentData.Value,
		New NotifyDescription("DCSParametersValueStartChoiceEND", ThisObject, AdditionalParameters),
		NSTR("ru = 'Редактирование списка значений';en = 'Edit values list'"), CurrentData.ValueType, False, False, True, False,
		FormWindowOpeningMode.LockOwnerWindow, AvailableValues);
	
EndProcedure


&AtClient
Procedure DCSParametersValueListAllowedOnChange(Item)
		CurrentData=Items.DCSParameters.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	If CurrentData.ValueListAllowed Then
		NewValue=New ValueList;
		NewValue.Add(CurrentData.Value);
	Else
		If CurrentData.Value.Count() = 0 Then
			NewValue=Undefined;
		Else
			NewValue=CurrentData.Value[0].Value;
		EndIf;
	EndIf;

	CurrentData.Value=NewValue;

	SetParameterValueFieldTypeRestriction(CurrentData);
	
EndProcedure

&AtClient
Procedure DCSParametersExpressionOpening(Item, StandardProcessing)
		StandardProcessing=False;
	CurrentData=Items.DCSParameters.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("RowID", Items.DCSParameters.CurrentRow);

	UT_CommonClient.OpenTextEditingForm(CurrentData.Expression,
		New NotifyDescription("DCSParametersExpressionOpeningEND", ThisObject, AdditionalParameters),
		NSTR("ru = 'Редактирование выражения для';en = 'Edit expression for'") + CurrentData.Name);
EndProcedure


&AtClient
Procedure DCSParametersNameOnChange(Item)
		CurrentData=Items.DCSParameters.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	CurrentData.Title=UT_StringFunctionsClientServer.IdentifierPresentation(CurrentData.Name);
	
EndProcedure

&AtClient
Procedure DCSParametersBeforeDeleteRow(Item, Cancel)
		CurrentData=Items.DCSParameters.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	Cancel=CurrentData.AddedAutomatically;
EndProcedure

&AtClient
Procedure DCSParametersValueTypeStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentData=Items.DCSParameters.CurrentData;
	If CurrentData=Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditType(CurrentData.ValueType, 3,StandardProcessing,ThisObject, New NotifyDescription("DCSParametersValueTypeStartChoiceEND",ThisObject, New Structure("CurrentRow",Items.DCSParameters.CurrentRow)));

EndProcedure

#EndRegion

#Region CurrentVariantSettings

&AtClient
Procedure SettingsOnActivateField(Item)
	
		Var SelectedPage;

	If Items.Settings.CurrentItem.Name = "SettingsHasSelection" Then

		SelectedPage = Items.SelectionFieldsPage;

	ElsIf Items.Settings.CurrentItem.Name = "SettingsHasFilter" Then

		SelectedPage = Items.FilterPage;

	ElsIf Items.Settings.CurrentItem.Name = "SettingsHasOrder" Then

		SelectedPage = Items.OrderPage;

	ElsIf Items.Settings.CurrentItem.Name
		= "SettingsConditionalAppearance" Then

		SelectedPage = Items.ConditionalAppearancePage;

	ElsIf Items.Settings.CurrentItem.Name
		= "SettingsHasOutputParameters" Then

		SelectedPage = Items.OutputParametersPage;

	EndIf;

	If SelectedPage <> Undefined Then

		Items.SettingsPages.CurrentPage = SelectedPage;

	EndIf;
	
EndProcedure

&AtClient
Procedure SettingsOnActivateRow(Item)
	SettingsItem = CurrentSettingsComposer.Settings.GetObjectByID(
		Items.Settings.CurrentRow);
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
Procedure GoToReport(Item)

	SettingsItem = CurrentSettingsComposer.Settings.GetObjectByID(
		Items.Settings.CurrentRow);
	ItemSettings =  CurrentSettingsComposer.Settings.ItemSettings(SettingsItem);
	Items.Settings.CurrentRow = CurrentSettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

&AtClient
Procedure LocalSelectedFieldsOnChange(Item)
		If LocalSelectedFields Then

		Items.SelectionFieldsPages.CurrentPage = Items.SelectedFieldsSettings;

	Else

		Items.SelectionFieldsPages.CurrentPage = Items.DisabledSelectedFieldsSettings;

		SettingsItem = CurrentSettingsComposer.Settings.GetObjectByID(
			Items.Settings.CurrentRow);
		CurrentSettingsComposer.Settings.ClearItemSelection(SettingsItem);

	EndIf;
	
EndProcedure

&AtClient
Procedure LocalFilterOnChange(Item)
		If LocalFilter Then

		Items.FilterPages.CurrentPage = Items.FilterSettings;

	Else

		Items.FilterPages.CurrentPage = Items.DisabledFilterSettings;

		SettingsItem = CurrentSettingsComposer.Settings.GetObjectByID(
			Items.Settings.CurrentRow);
		CurrentSettingsComposer.Settings.ClearItemFilter(SettingsItem);

	EndIf;
	
EndProcedure

&AtClient
Procedure LocalOrderOnChange(Item)
		If LocalOrder Then

		Items.OrderPages.CurrentPage = Items.OrderSettings;

	Else

		Items.OrderPages.CurrentPage = Items.DisabledOrderSettings;

		SettingsItem = CurrentSettingsComposer.Settings.GetObjectByID(
			Items.Settings.CurrentRow);
		CurrentSettingsComposer.Settings.ClearItemOrder(SettingsItem);

	EndIf;
	
EndProcedure

&AtClient
Procedure LocalConditionalAppearanceOnChange(Item)
		If LocalConditionalAppearance Then

		Items.ConditionalAppearancePages.CurrentPage = Items.ConditionalAppearanceSettings;

	Else

		Items.ConditionalAppearancePages.CurrentPage = Items.DisabledConditionalAppearanceSettings;

		SettingsItem = CurrentSettingsComposer.Settings.GetObjectByID(
			Items.Settings.CurrentRow);
		CurrentSettingsComposer.Settings.ClearItemConditionalAppearance(SettingsItem);

	EndIf;
	
EndProcedure

&AtClient
Procedure LocalOutputParametersOnChange(Item)
		If LocalOutputParameters Then

		Items.OutputParametersPages.CurrentPage = Items.OutputParametersSettings;

	Else

		Items.OutputParametersPages.CurrentPage = Items.DisabledOutputParametersSettings;

		SettingsItem = CurrentSettingsComposer.Settings.GetObjectByID(
			Items.Settings.CurrentRow);
		CurrentSettingsComposer.Settings.ClearItemOutputParameters(SettingsItem);
	EndIf;
EndProcedure

#EndRegion

#Region SettingVariants
&AtClient
Procedure SettingVariantsOnActivateRow(Item)
	SettingVariantsOnActivateRowAtServer(Items.SettingVariants.CurrentRow);
EndProcedure

&AtClient
Procedure SettingVariantsBeforeDeleteRow(Item, Cancel)
	If SettingVariants.Count() = 1 Then
		Cancel=True;
	EndIf;
EndProcedure

&AtClient
Procedure SettingVariantsOnStartEdit(Item, NewRow, Clone)
		If Not NewRow Then
		Return;
	EndIf;
	CurrentData=Items.SettingVariants.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	CurrentData.Name="Variant" + CurrentData.GetID();
	CurrentData.Presentation=CurrentData.Name;
EndProcedure


#EndRegion

#EndRegion

#Region CommandFormEventHandlers

&AtClient
Procedure AddDataSetQuery(Command)
	AddDataSet(DataSetsTypes.Query);
EndProcedure

&AtClient
Procedure AddDataSetObject(Command)
	AddDataSet(DataSetsTypes.Object);
EndProcedure

&AtClient
Procedure AddDataSetUnion(Command)
	AddDataSet(DataSetsTypes.Union);
EndProcedure

&AtClient
Procedure DeleteDataSet(Command)
	CurrentRowID=Items.DataSets.CurrentRow;
	If CurrentRowID = ZerothDataSetURL Then
		Return;
	EndIf;

	DataSetRow=DataSets.FindByID(CurrentRowID);

	DataSetName=DataSetRow.Name;

	ParentRow=DataSetRow.GetParent();
	ParentRow.GetItems().Delete(DataSetRow);
	
	//Delete links with this dataset
	ArrayToDelete=New Array;
	For Each Row In DataSetLinks Do
		If Lower(Row.SourceDataSet) = Lower(DataSetName) Or Lower(Row.DestinationDataSet) = Lower(
			DataSetName) Then

			ArrayToDelete.Add(Row);
		EndIf;

	EndDo;

	For Each Row In ArrayToDelete Do
		DataSetLinks.Delete(Row);
	EndDo;

EndProcedure

&AtClient
Procedure OpenQueryWizard(Command)
	CurrentDataSet=Items.DataSets.CurrentData;
	If CurrentDataSet = Undefined Then
		Return;
	EndIf;

	Wizard=New QueryWizard;
	If UT_CommonClientServer.PlatformVersionNotLess_8_3_14() Then
		Wizard.DataCompositionMode=True;
	EndIf;

	If ValueIsFilled(TrimAll(CurrentDataSet.Query)) Then
		Wizard.Text=CurrentDataSet.Query;
	EndIf;

	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("CurrentRow", Items.DataSets.CurrentRow);

	Wizard.Show(New NotifyDescription("OpenQueryWizardEND", ThisObject,
		NotifyAdditionalParameters));
EndProcedure

&AtClient
Procedure AddResourceFromAvailable(Command)
	CurrentData=Items.ResourceAvailableField.CurrentRow;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	AddResource(CurrentData);
EndProcedure

&AtClient
Procedure AddNumericResourcesFromAvailable(Command)
	For Each Row In ResourceAvailableFields Do
		If Not Row.CalculatedField And Not Row.Numeric Then
			Continue;
		EndIf;

		AddResource(Row);
	EndDo;
EndProcedure

&AtClient
Procedure DeleteResource(Command)
	CurrentResourcesRow=Items.Resources.CurrentRow;
	If CurrentResourcesRow = Undefined Then
		Return;
	EndIf;

	Resources.Delete(Resources.FindByID(CurrentResourcesRow));
EndProcedure

&AtClient
Procedure DeleteAllResources(Command)
	Resources.Clear();
EndProcedure

&AtClient
Procedure SaveSchemaToFile(Command)
	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("SaveSchemaToFileEND", ThisObject));
EndProcedure
&AtClient
Procedure ReadSchemaFromFile(Command)
	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("ReadSchemaFromFileEND", ThisObject));
EndProcedure

&AtClient
Procedure FinishEdit(Command)
	AssembleDCSFromFormData(True);

	Close(DataCompositionSchemaURL);
EndProcedure

&AtClient
Procedure AddDataSetFieldFolder(Command)
	AddDataSetFieldManually(DataSetFieldsTypes.Folder);
EndProcedure

&AtClient
Procedure AddDataSetFieldField(Command)
	AddDataSetFieldManually(DataSetFieldsTypes.Field);
EndProcedure

&AtClient
Procedure AddDataSetFieldSet(Command)
	AddDataSetFieldManually(DataSetFieldsTypes.Set);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region Private

#Region ReadSaveToFile
&AtClient
Procedure SaveSchemaToFileEND(Result, AdditionalParameters) Export
	FD=New FileDialog(FileDialogMode.Save);
	FD.Extension="xml";
	FD.Filter="File XML(*.xml)|*.xml";
	FD.Multiselect=False;
	FD.Show(New NotifyDescription("SaveSchemaToFileFileNameChoiceEND", ThisObject));
EndProcedure

&AtClient
Procedure SaveSchemaToFileFileNameChoiceEND(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles = Undefined Then
		Return;
	EndIf;

	If SelectedFiles.Count() = 0 Then
		Return;
	EndIf;

	TextURL=PrepareDSCForSaveFile();

	Text=New TextDocument;
	Text.SetText(GetFromTempStorage(TextURL));
	Text.BeginWriting( , SelectedFiles[0], "utf-8");
EndProcedure

&AtServer
Function PrepareDSCForSaveFile()
	SaveToFormTableCurrentSettingsVariantSetting();
	AssembleDCSFromFormData(True);

	DCSText=UT_Common.ValueToXMLString(GetFromTempStorage(DataCompositionSchemaURL));

	Return PutToTempStorage(DCSText, UUID);
EndFunction

&AtClient
Procedure ReadSchemaFromFileEND(Result, AdditionalParameters) Export
	FD=New FileDialog(FileDialogMode.Opening);
	FD.Extension="xml";
	FD.Filter="File XML(*.xml)|*.xml";
	FD.Multiselect=False;

	BeginPutFile(New NotifyDescription("ReadSchemaFromFileEndPutFile", ThisObject), , FD,
		True, UUID);
EndProcedure

&AtClient
Procedure ReadSchemaFromFileEndPutFile(Result, Address, SelectedFileName, AdditionalParameters) Export
	If Not Result Then
		Return;
	EndIf;

	ReadSchemaFromFileAtServer(Address);
	FillResourcesAuxuliaryData();
EndProcedure

&AtServer
Procedure ReadSchemaFromFileAtServer(FileAddress)

	BinaryData=GetFromTempStorage(FileAddress);

	Text=New TextDocument;
	Text.Read(BinaryData.OpenStreamForRead());

	Try
		DCS=UT_Common.ValueFromXMLString(Text.GetText());
	Except
		Message(StrTemplate(NSTR("ru = 'Не удалось прочитать СКД из файла: %1';en = 'Could not read the DCS from the file: %1'"), ErrorDescription()));
		Return;
	EndTry;

	ReadDCSToFormData(DCS);
EndProcedure

#EndRegion

#Region DataSets
&AtClient
Function DataSetByName(DataSetName, DataSetsRow = Undefined)
	If DataSetsRow = Undefined Then
		DataSetSearchRow=DataSets.FindByID(ZerothDataSetURL);
	Else
		DataSetSearchRow=DataSetsRow;
	EndIf;

	FoundDataSet=Undefined;
	For Each Row In DataSetSearchRow.GetItems() Do
		If Lower(Row.Name) = Lower(DataSetName) Then
			FoundDataSet=Row;
			Break;
		EndIf;
	EndDo;

	Return FoundDataSet;
EndFunction

&AtClient
Procedure FillDataSetFieldsOnQueryChange(DataSetRowID)
	FillDataSetFieldsOnQueryChangeAtServer(DataSetRowID);
	FillDCSParametersOnDataSetQueryChange(DataSetRowID);
	FillResourcesAuxuliaryData();
EndProcedure

&AtServer
Procedure FillDCSParametersOnDataSetQueryChange(DataSetRowID)
	DataSetRow=DataSets.FindByID(DataSetRowID);

	If Not ValueIsFilled(DataSetRow.Query) Then
		Return;
	EndIf;

	Query=New Query;
	Query.Text=DataSetRow.Query;
	QueryOptions=Query.FindParameters();

	For Each ParameterDescription In QueryOptions Do
		SearchStructure=New Structure;
		SearchStructure.Insert("Name", ParameterDescription.Name);

		ParametersFoundRows=DCSParameters.FindRows(SearchStructure);
		If ParametersFoundRows.Count() = 0 Then
			ParameterRow=DCSParameters.Add();
			ParameterRow.Name=ParameterDescription.Name;
			ParameterRow.Title=ParameterDescription.Name;
			ParameterRow.ValueType=ParameterDescription.ValueType;
			ParameterRow.IncludeInAvailableFields=True;
		Else
			ParameterRow=ParametersFoundRows[0];
		EndIf;
		ParameterRow.AddedAutomatically=True;
	EndDo;
EndProcedure
&AtServer
Procedure AddDataSetField(DataSetRow, Column, DataSetFieldsTypes, FieldsArray, ParentColumn = Undefined)
	RestrictionField=False;
	RestrictionCondition=False;
	RestrictionGroup=False;
	RestrictionOrder=False;
	FillRestriction=False;
	If TypeOf(Column) = Type("QuerySchemaNestedTableColumn") Then
		Type=DataSetFieldsTypes.Set;
		ColumnName=Column.Alias;
	ElsIf TypeOf(Column) = Type("QuerySchemaColumn") Then
		Type=DataSetFieldsTypes.Field;
		ColumnName=Column.Alias;
	ElsIf TypeOf(Column) = Type("CustomField") Then
		If Column.ValueType = New TypeDescription("ValueTable") Then
			Type=DataSetFieldsTypes.Set;
			ColumnName=Column.Name;
		Else
			Type=DataSetFieldsTypes.Field;
			ColumnName=Column.Name;
		EndIf;
		FillRestriction=True;

		RestrictionField=Not Column.Field;
		RestrictionCondition=Not Column.Filter;
		RestrictionGroup=Not Column.Dimension;
		RestrictionOrder=Not Column.Order;
	EndIf;

	If ParentColumn = Undefined Then
		Field=ColumnName;
	Else
		Field=ParentColumn.Alias + "." + ColumnName;
	EndIf;

	SearchStructure=New Structure;
	SearchStructure.Insert("Field", Field);

	RowsArray=DataSetRow.Fields.FindRows(SearchStructure);
	If RowsArray.Count() = 0 Then
		NewField=DataSetRow.Fields.Add();
		NewField.Field=Field;
		NewField.DataPath=Field;
	Else
		NewField=RowsArray[0];
	EndIf;
	NewField.Type=Type;
	NewField.Picture=DataSetFieldTypePicture(NewField.Type, DataSetFieldsTypes);

	If TypeOf(Column) = Type("QuerySchemaNestedTableColumn") Then
		For Each CurrentColumn In Column.Columns Do
			AddDataSetField(DataSetRow, CurrentColumn, DataSetFieldsTypes, FieldsArray, Column);
		EndDo;
	ElsIf Type = DataSetFieldsTypes.Field Then
		NewField.QueryValueType=Column.ValueType;
	EndIf;

	If FillRestriction Then
		NewField.UseRestrictionGroup=RestrictionGroup;
		NewField.UseRestrictionField=RestrictionField;
		NewField.UseRestrictionOrder=RestrictionOrder;
		NewField.UseRestrictionCondition=RestrictionCondition;

		NewField.AttributeUseRestrictionGroup=RestrictionGroup;
		NewField.AttributeUseRestrictionField=RestrictionField;
		NewField.AttributeUseRestrictionOrder=RestrictionOrder;
		NewField.AttributeUseRestrictionCondition=RestrictionCondition;
	EndIf;

	FieldsArray.Add(Field);
EndProcedure
&AtServer
Procedure FillDataSetFieldsOnQueryChangeAtServer(DataSetRowID)
	DataSetRow=DataSets.FindByID(DataSetRowID);

	FieldsArray=New Array;
	DataSetFieldsTypes=DataSetFieldsTypes();
	DataSetsTypes=DataSetsTypes();

	If Not DataSetRow.AutoFillAvailableFields Then
		QueryBuilder=New QueryBuilder(DataSetRow.Query);

		For Each AvailableField In QueryBuilder.AvailableFields Do
			AddDataSetField(DataSetRow, AvailableField, DataSetFieldsTypes, FieldsArray);
		EndDo;

	Else

		QuerySchema=New QuerySchema;
		If UT_CommonClientServer.PlatformVersionNotLess_8_3_14() Then
			QuerySchema.DataCompositionMode=True;
		EndIf;
		QuerySchema.SetQueryText(DataSetRow.Query);

		BatchIndex=QuerySchema.QueryBatch.Count() - 1;
		NeedBatch=QuerySchema.QueryBatch[BatchIndex];
		While TypeOf(NeedBatch) <> Type("QuerySchemaSelectQuery") Do
			If BatchIndex < 0 Then
				Break;
			EndIf;
			BatchIndex=BatchIndex - 1;
			NeedBatch=QuerySchema.QueryBatch[BatchIndex];
		EndDo;

		If TypeOf(NeedBatch) <> Type("QuerySchemaSelectQuery") Then
			Return;
		EndIf;
		If DataSetRow.AutoFillAvailableFields Then
			For Each Column In NeedBatch.Columns Do
				AddDataSetField(DataSetRow, Column, DataSetFieldsTypes, FieldsArray);
			EndDo;
		EndIf;
	EndIf;

	DeleteDataSetExtraFieldsAfterFilling(DataSetRow, FieldsArray);

	ParentDataSet=DataSetRow.GetParent();
	If ParentDataSet.Type = DataSetsTypes.Union Then
		FillDataSetUnionFieldsByChildQuerys(ParentDataSet.GetID());
	EndIf;
EndProcedure

&AtServer
Procedure DeleteDataSetExtraFieldsAfterFilling(DataSetRow, AddedFieldsArray)
	DataSetFieldsTypes=DataSetFieldsTypes();

	FieldsArrayToDelete=New Array;
	For Each FieldRow In DataSetRow.Fields Do
		If AddedFieldsArray.Find(FieldRow.Field) = Undefined And FieldRow.Type
			<> DataSetFieldsTypes.Folder Then
			FieldsArrayToDelete.Add(FieldRow);
		EndIf;
	EndDo;

	For Each Row In FieldsArrayToDelete Do
		DataSetRow.Fields.Delete(Row);
	EndDo;
EndProcedure

&AtServer
Procedure FillDataSetUnionFieldsByChildQuerys(DataSetRowID)
	DataSetRow=DataSets.FindByID(DataSetRowID);

	DataSetsFiledsTypes=DataSetFieldsTypes();

	FieldsOfSetType=New Array;
	FieldsArray=New Array;
	For Each CurrentDataSet In DataSetRow.GetItems() Do
		For Each CurrentField In CurrentDataSet.Fields Do
			If CurrentField.Type = DataSetsFiledsTypes.Set Then
				FieldsOfSetType.Add(CurrentField.DataPath);
			EndIf;

			SearchStructure=New Structure;
			SearchStructure.Insert("DataPath", CurrentField.DataPath);

			FoundRows=DataSetRow.Fields.FindRows(SearchStructure);
			If FoundRows.Count() = 0 Then
				NewField=DataSetRow.Fields.Add();
				NewField.Type=CurrentField.Type;
				NewField.DataPath=CurrentField.DataPath;
				NewField.Title=UT_StringFunctionsClientServer.IdentifierPresentation(NewField.DataPath);
				NewField.Field=NewField.DataPath;
			Else
				NewField=FoundRows[0];
			EndIf;

			FieldsArray.Add(NewField.DataPath);

		EndDo;
	EndDo;

	NewFieldsArray=New Array;
	For Each Field In FieldsArray Do
		If FieldsOfSetType.Find(Field) = Undefined Then
			NewFieldsArray.Add(Field);
		EndIf;
	EndDo;

	DeleteDataSetExtraFieldsAfterFilling(DataSetRow, NewFieldsArray);

	DataSetsTypes=DataSetsTypes();
	ParentDataSet=DataSetRow.GetParent();
	If ParentDataSet.Type = DataSetsTypes.Union Then
		FillDataSetUnionFieldsByChildQuerys(ParentDataSet.GetID());
	EndIf;
EndProcedure

&AtClient
Procedure OpenQueryWizardEND(Text, AdditionalParameters) Export
	If Text = Undefined Then
		Return;
	EndIf;

	RowID=AdditionalParameters.CurrentRow;
	DataSetRow=DataSets.FindByID(RowID);

	DataSetRow.Query=Text;

	FillDataSetFieldsOnQueryChange(RowID);
EndProcedure
&AtClient
Procedure AddDataSet(Type)
	CurrentData=Items.DataSets.CurrentData;
	If CurrentData.Type = DataSetsTypes.Union Then
		TreeRowToAdd=DataSets.FindByID(Items.DataSets.CurrentRow);
	Else
		TreeRowToAdd=DataSets.FindByID(ZerothDataSetURL);
	EndIf;

	DataSet=TreeRowToAdd.GetItems().Add();
	DataSet.Name="DataSet" + DataSet.GetID();
	DataSet.Type=Type;

	If Type = DataSetsTypes.Query Then
		DataSet.Picture=PictureLib.UT_DataSetDCSQuery;
		DataSet.AutoFillAvailableFields=True;
		DataSet.UseQueryGroupIfPossible=True;
	ElsIf Type = DataSetsTypes.Object Then
		DataSet.Picture=PictureLib.UT_DataSetDCSObject;
	ElsIf Type = DataSetsTypes.Union Then
		DataSet.Picture=PictureLib.UT_DataSetDCSUnion;
	EndIf;

	Items.DataSets.CurrentRow=DataSet.GetID();

	If DataSources.Count() > 0 Then
		DataSet.DataSource=DataSources[0].Name;
	EndIf;
EndProcedure
&AtClientAtServerNoContext
Function DataSetsTypes()
	Structure=New Structure;
	Structure.Insert("Root", "Root");
	Structure.Insert("Query", "DataCompositionSchemaDataSetQuery");
	Structure.Insert("Object", "DataCompositionSchemaDataSetObject");
	Structure.Insert("Union", "DataCompositionSchemaDataSetUnion");

	Return Structure;
EndFunction

&AtClientAtServerNoContext
Function DataSetFieldsTypes()
	Structure=New Structure;
	Structure.Insert("Field", "DataCompositionSchemaDataSetField");
	Structure.Insert("Folder", "DataCompositionSchemaDataSetFieldFolder");
	Structure.Insert("Set", "DataCompositionSchemaNestedDataSet");

	Return Structure;

EndFunction

&AtClient
Function TopLevelDataSets()
	DataSetsArray=New Array;

	ZerothDataSet=DataSets.FindByID(ZerothDataSetURL);
	For Each Set In ZerothDataSet.GetItems() Do
		DataSetsArray.Add(Set);
	EndDo;

	Return DataSetsArray;
EndFunction

&AtClient
Procedure FillDatDataSetDataSourceChoiceList()
	Items.DataSetsDataSource.ChoiceList.Clear();

	For Each Row In DataSources Do
		Items.DataSetsDataSource.ChoiceList.Add(Row.Name);
	EndDo;
EndProcedure

&AtClient
Procedure GroupDataSetsRightPanelOnCurrentPageChange(Item, CurrentPage)
	FillDatDataSetDataSourceChoiceList();
EndProcedure


&AtClientAtServerNoContext
Function DataSetFieldRolePresentation(Role)
	If Role = Undefined Then
		Return "";
	EndIf;

	PresentationArray=New Array;

	If Role.Period Then
		PresentationArray.Add("Period");
		PresentationArray.Add(Role.PeriodNumber);
		If Role.PeriodAdditional Then
			PresentationArray.Add("Add");
		EndIf;
	EndIf;

	If Role.Dimension Then
		PresentationArray.Add("Dimension");
		If ValueIsFilled(Role.ParentDimension) Then
			PresentationArray.Add(Role.ParentDimension);
		EndIf;
	EndIf;

	If Role.Account Then
		PresentationArray.Add("Account");
		PresentationArray.Add(Role.AccountTypeExpression);
	EndIf;

	If Role.Balance Then
		If Lower(Role.BalanceType) = "openingbalance" Then
			PresentationArray.Add("OpeningBal");
		ElsIf Lower(Role.BalanceType) = "сlosingbalance" Then
			PresentationArray.Add("ClosingBal");
		EndIf;
		If Lower(Role.AccountingBalanceType) = "debit" Then
			PresentationArray.Add("Dr");
		ElsIf Lower(Role.AccountingBalanceType) = "credit" Then
			PresentationArray.Add("Cr");
		EndIf;

		If ValueIsFilled(Role.BalanceGroup) Then
			PresentationArray.Add(Role.BalanceGroup);
		EndIf;
		If ValueIsFilled(Role.AccountField) Then
			PresentationArray.Add(Role.AccountField);
		EndIf;
	EndIf;

	If Role.IgnoreNULLValues Then
		PresentationArray.Add("NULL");
	EndIf;

	If Role.Required Then
		PresentationArray.Add("Required");
	EndIf;

	Return StrConcat(PresentationArray, ", ");
EndFunction

&AtClient
Procedure DataSetsFieldsRolePresentationStartChoiceEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	DataSetRow=DataSets.FindByID(AdditionalParameters.DataSetRowID);

	FieldRow=DataSetRow.Fields.FindByID(AdditionalParameters.RowID);
	FieldRow.Role=Result;

	FieldRow.RolePresentation=DataSetFieldRolePresentation(FieldRow.Role);
EndProcedure

&AtClient
Procedure FieldsAvailableValuesStartChoiceEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	DataSetRow=DataSets.FindByID(AdditionalParameters.DataSetRowID);

	FieldRow=DataSetRow.Fields.FindByID(AdditionalParameters.RowID);
	FieldRow.AvailableValues=Result;
EndProcedure

&AtClient
Procedure AddDataSetFieldManually(FieldType)
	DataSetRow=Items.DataSets.CurrentData;
	If DataSetRow = Undefined Then
		Return;
	EndIf;

	NewField=DataSetRow.Fields.Add();
	NewField.Type=FieldType;
	NewField.Picture=DataSetFieldTypePicture(FieldType, DataSetFieldsTypes);
	NewField.DataPath="Field" + NewField.GetID();
	NewField.Title=UT_StringFunctionsClientServer.IdentifierPresentation(NewField.DataPath);
	If FieldType <> DataSetFieldsTypes.Folder Then
		NewField.Field=NewField.DataPath;
	EndIf;

	Items.DataSetsFields.CurrentRow=NewField.GetID();
	
	ParentDataSet=DataSetRow.GetParent();
	If ParentDataSet.Type=DataSetsTypes.Union Then
		FillDataSetUnionFieldsByChildQuerys(ParentDataSet.GetID());
	EndIf;
EndProcedure

&AtClientAtServerNoContext
Function DataSetFieldTypePicture(Type, DatasetFieldsTypes)
	If Type = DatasetFieldsTypes.Field Then
		Picture=PictureLib.Attribute;
	ElsIf Type = DatasetFieldsTypes.Set Then
		Picture=PictureLib.NestedTable;
	Else
		Picture=PictureLib.Folder;
	EndIf;

	Return Picture;
EndFunction

&AtClient
Function AvailableToAddDataSetFieldField(DataSetCurrentRow)
	Return DataSetCurrentRow.Type = DataSetsTypes.Object;
EndFunction

&AtClient
Function AvailableToAddDataSetFieldSet(DataSetCurrentRow)
	Return DataSetCurrentRow.Type = DataSetsTypes.Object;
EndFunction

&AtClient
Function DataSetFieldCloneDeleteIsAvalible(DataSetCurrentRow, CurrentFieldRow)
	If CurrentFieldRow = Undefined Then
		Return False;
	EndIf;

	Return CurrentFieldRow.Type = DataSetFieldsTypes.Folder Or (AvailableToAddDataSetFieldField(DataSetCurrentRow)
		And CurrentFieldRow.Type = DataSetFieldsTypes.Field) Or (AvailableToAddDataSetFieldSet(DataSetCurrentRow)
		And CurrentFieldRow.Type = DataSetFieldsTypes.Set);
EndFunction

&AtClient
Procedure SetAvailableOfAddDataSetFieldButtons()
	CurrentDataSet=Items.DataSets.CurrentData;
	If CurrentDataSet = Undefined Then
		Return;
	EndIf;
	If CurrentDataSet.GetID() = ZerothDataSetURL Then
		Return;
	EndIf;

	AddFieldAvailable=AvailableToAddDataSetFieldField(CurrentDataSet);
	AddSetAvailable=AvailableToAddDataSetFieldSet(CurrentDataSet);
	CloneAvailable=DataSetFieldCloneDeleteIsAvalible(CurrentDataSet, Items.DataSetsFields.CurrentData);
	DeleteAvailable=CloneAvailable;

	Items.DataSetsFieldsAddDataSetFieldField.Enabled=AddFieldAvailable;
	Items.DataSetsFieldsAddDataSetFieldField1.Visible=AddFieldAvailable;

	Items.DataSetsFieldsAddDataSetFieldSet.Enabled=AddSetAvailable;
	Items.DataSetsFieldsAddDataSetFieldSet1.Visible=AddSetAvailable;

	Items.DataSetsFieldsCopy.Enabled=CloneAvailable;
	Items.DataSetsFieldsCopy1.Visible=CloneAvailable;

	Items.DataSetsFieldsDelete.Enabled=CloneAvailable;
	Items.DataSetsFieldsDelete1.Visible=DeleteAvailable;

EndProcedure

&AtClient
Procedure FieldsValueTypeStartChoiceEND(Result, AdditionalParameters) Export
	If Result=Undefined Then
		Return;
	EndIf;
	DataSetRow=Items.DataSets.CurrentData;
	If DataSetRow = Undefined Then
		Return;
	EndIf;
	
	CurrentRowData=DataSetRow.Fields.FindByID(AdditionalParameters.CurrentRow);
	CurrentRowData.ValueType=Result;
EndProcedure
#EndRegion

#Region DataSetLinks
&AtClient
Procedure FillDataSetLinkFieldChoiceList(DataSetName, FieldItem)
	FieldItem.ChoiceList.Clear();

	DataSet=DataSetByName(DataSetName);
	If DataSet = Undefined Then
		Return;
	EndIf;

	For Each Field In DataSet.Fields Do
		FieldItem.ChoiceList.Add(Field.DataPath);
	EndDo;

EndProcedure

&AtClient
Procedure FillDataSetLinksAuxuliaryData()
	Sets=TopLevelDataSets();

	Items.DataSetLinksSourceDataSet.ChoiceList.Clear();
	Items.DataSetLinksDestinationDataSet.ChoiceList.Clear();

	For Each Set In Sets Do
		Items.DataSetLinksSourceDataSet.ChoiceList.Add(Set.Name);
		Items.DataSetLinksDestinationDataSet.ChoiceList.Add(Set.Name);
	EndDo;
EndProcedure
#EndRegion

#Region CalculatedFields
&AtClient
Procedure CalculatedFieldsExpressionOpeningEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ResourceRow=CalculatedFields.FindByID(AdditionalParameters.RowID);
	ResourceRow.Expression=Result;
EndProcedure

&AtClient
Procedure CalculatedFieldsAvailableValuesStartChoiceEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	FieldRow=CalculatedFields.FindByID(AdditionalParameters.RowID);
	FieldRow.AvailableValues=Result;
EndProcedure

&AtClient
Procedure CalculatedFieldsValueTypeStartChoiceEND(Result, AdditionalParameters) Export
	If Result=Undefined Then
		Return;
	EndIf;
	
	CurrentRowData=CalculatedFields.FindByID(AdditionalParameters.CurrentRow);
	CurrentRowData.ValueType=Result;
EndProcedure

#EndRegion

#Region Resources
&AtClient
Procedure ResourcesGroupsStartChoiceEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ResourceRow=Resources.FindByID(AdditionalParameters.RowID);
	ResourceRow.Groups=Result;
EndProcedure

&AtClient
Procedure ResourcesExpressionOpeningEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ResourceRow=Resources.FindByID(AdditionalParameters.RowID);
	ResourceRow.Expression=Result;
EndProcedure

&AtClient
Procedure AddResource(AvailableFieldRow)
	If TypeOf(AvailableFieldRow) = Type("Number") Then
		AvailableField=ResourceAvailableFields.FindByID(AvailableFieldRow);
	Else
		AvailableField=AvailableFieldRow;
	EndIf;

	NewRow=Resources.Add();
	NewRow.DataPath=AvailableField.DataPath;

	If AvailableField.CalculatedField Or AvailableField.Numeric Then
		NewRow.Expression=StrTemplate("Sum(%1)", NewRow.DataPath);
	Else
		NewRow.Expression=StrTemplate("Count(%1)", NewRow.DataPath);
	EndIf;
EndProcedure

&AtClient
Procedure FillResourcesAvailableFields()
	ResourceAvailableFields.Clear();

	TopLevelDataSets=TopLevelDataSets();

	PictureAttribute=PictureLib.Attribute;
	PictureCustomExpression=PictureLib.CustomExpression;

	DataPathsArray=New Array;

	For Each Set In TopLevelDataSets Do
		For Each Field In Set.Fields Do
			If DataPathsArray.Find(Field.DataPath) <> Undefined Then
				Continue;
			EndIf;

			If Field.Type <> DataSetFieldsTypes.Field Then
				Continue;
			EndIf;

			NewRow=ResourceAvailableFields.Add();
			NewRow.DataPath=Field.DataPath;
			NewRow.Picture=PictureAttribute;

			NewRow.Numeric= Field.QueryValueType.ContainsType(Type("Number"));

			DataPathsArray.Add(Field.DataPath);
		EndDo;
	EndDo;

	For Each Field In CalculatedFields Do
		If DataPathsArray.Find(Field.DataPath) <> Undefined Then
			Continue;
		EndIf;
		NewRow=ResourceAvailableFields.Add();
		NewRow.DataPath=Field.DataPath;
		NewRow.CalculatedField=True;
		NewRow.Picture=PictureCustomExpression;

		DataPathsArray.Add(Field.DataPath);

	EndDo;

	ResourceAvailableFields.Sort("DataPath ASC");
EndProcedure

&AtClient
Procedure DeleteNotMatchResourcesByAvailableFields()
	DeletedRowsArray=New Array;
	For Each Row In Resources Do
		SearchStructure=New Structure;
		SearchStructure.Insert("DataPath", Row.DataPath);

		FoundRows=ResourceAvailableFields.FindRows(SearchStructure);
		If FoundRows.Count() = 0 Then
			DeletedRowsArray.Add(Row);
		EndIf;
	EndDo;

	For Each Row In DeletedRowsArray Do
		Resources.Delete(Row);
	EndDo;
EndProcedure

&AtClient
Procedure FillResourcesAuxuliaryData()
	FillResourcesAvailableFields();
	DeleteNotMatchResourcesByAvailableFields();
EndProcedure

&AtClient
Procedure FillResourceExpressionChoiceList(ResourceRowID)
	Items.ResourcesExpression.ChoiceList.Clear();

	ResourceRow=Resources.FindByID(ResourceRowID);

	SearchStructure=New Structure;
	SearchStructure.Insert("DataPath", ResourceRow.DataPath);

	AvailableFieldsList=ResourceAvailableFields.FindRows(SearchStructure);
	If AvailableFieldsList.Count() = 0 Then
		Return;
	EndIf;

	AvailableFieldRow=AvailableFieldsList[0];

	If AvailableFieldRow.CalculatedField Or AvailableFieldRow.Numeric Then
		Items.ResourcesExpression.ChoiceList.Add(StrTemplate("Sum(%1)", ResourceRow.DataPath));
		Items.ResourcesExpression.ChoiceList.Add(StrTemplate("Avg(%1)", ResourceRow.DataPath));
	EndIf;
	Items.ResourcesExpression.ChoiceList.Add(StrTemplate("Max(%1)", ResourceRow.DataPath));
	Items.ResourcesExpression.ChoiceList.Add(StrTemplate("Min(%1)", ResourceRow.DataPath));
	Items.ResourcesExpression.ChoiceList.Add(StrTemplate("Count(%1)", ResourceRow.DataPath));
	Items.ResourcesExpression.ChoiceList.Add(StrTemplate("Count(Distinct %1)", ResourceRow.DataPath));

EndProcedure
#EndRegion

#Region Parameters

&AtClient
Procedure DCSParametersValueStartChoiceEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ResourceRow=DCSParameters.FindByID(AdditionalParameters.RowID);
	ResourceRow.Value=Result;
EndProcedure

&AtClient
Procedure DCSParametersAvailableValuesStartChoiceEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ResourceRow=DCSParameters.FindByID(AdditionalParameters.RowID);
	ResourceRow.AvailableValues=Result;

	SetParameterValueFieldChoiceList(ResourceRow);
EndProcedure

&AtClient
Procedure SetParameterValueFieldChoiceList(ParametersString )
	Items.DCSParametersValue.ListChoiceMode=ParametersString .AvailableValues.Count() > 0
		And Not ParametersString .ValueListAllowed;

	Items.DCSParametersValue.ChoiceList.Clear();

	For Each ListItem In ParametersString .AvailableValues Do
		Items.DCSParametersValue.ChoiceList.Add(ListItem.Value, ListItem.Presentation);
	EndDo;
EndProcedure

&AtClient
Procedure SetParameterValueFieldTypeRestriction(ParametersString )
	If ParametersString .ValueType = New TypeDescription Then
		Return;
	EndIf;

	If ParametersString .ValueListAllowed Then
		Items.DCSParametersValue.TypeRestriction=New TypeDescription("ValueList");
	Else
		Items.DCSParametersValue.TypeRestriction=ParametersString .ValueType;
	EndIf;
EndProcedure
&AtClient
Procedure DCSParametersExpressionOpeningEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ResourceRow=DCSParameters.FindByID(AdditionalParameters.RowID);
	ResourceRow.Expression=Result;
EndProcedure

&AtClient
Procedure DCSParametersValueTypeStartChoiceEND(Result, AdditionalParameters) Export
	If Result=Undefined Then
		Return;
	EndIf;
	
	CurrentRowData=DCSParameters.FindByID(AdditionalParameters.CurrentRow);
	CurrentRowData.ValueType=Result;
	
	If CurrentRowData.ValueListAllowed Then
		NewValue=New ValueList;

		For Each ListItem In CurrentRowData.Value Do
			If CurrentRowData.ValueType.ContainsType(TypeOf(ListItem.Value)) Then
				NewValue.Add(ListItem.Value);
			EndIf;
		EndDo;
		CurrentRowData.Value=NewValue;
	Else
		CurrentRowData.Value=CurrentRowData.ValueType.AdjustValue(CurrentRowData.Value);
	EndIf;

	SetParameterValueFieldTypeRestriction(CurrentRowData);

EndProcedure

#EndRegion

#Region CompositionSettings
&AtClient
Procedure GroupFieldsNotAvailable()

	Items.GroupFieldsPages.CurrentPage = Items.UnavailableGroupFieldsSettings;

EndProcedure

&AtClient
Procedure SelectedFieldsAvailable(SettingsItem)

	If CurrentSettingsComposer.Settings.HasItemSelection(SettingsItem) Then

		LocalSelectedFields = True;
		Items.SelectionFieldsPages.CurrentPage = Items.SelectedFieldsSettings;

	Else

		LocalSelectedFields = False;
		Items.SelectionFieldsPages.CurrentPage = Items.DisabledSelectedFieldsSettings;

	EndIf;

	Items.LocalSelectedFields.ReadOnly = False;

EndProcedure

&AtClient
Procedure SelectedFieldsUnavailable()

	LocalSelectedFields = False;
	Items.LocalSelectedFields.ReadOnly = True;
	Items.SelectionFieldsPages.CurrentPage = Items.UnavailableSelectedFieldsSettings;

EndProcedure

&AtClient
Procedure FilterAvailable(SettingsItem)

	If CurrentSettingsComposer.Settings.HasItemFilter(SettingsItem) Then

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

	If CurrentSettingsComposer.Settings.HasItemOrder(SettingsItem) Then

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

	If CurrentSettingsComposer.Settings.HasItemConditionalAppearance(SettingsItem) Then

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

	If CurrentSettingsComposer.Settings.HasItemOutputParameters(SettingsItem) Then

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
#EndRegion

#Region SettingVariants

&AtServer
Procedure InitializeSettingsComposerByAssembledDCS()

	CurrentSettingsComposer.Initialize(
			New DataCompositionAvailableSettingsSource(DataCompositionSchemaURL));
	CurrentSettingsComposer.Refresh();
EndProcedure

&AtServer
Procedure SaveToFormTableCurrentSettingsVariantSetting()
	PreviousVariantID=SettingVariants.FindByID(CurrentSettingsVariantID);
	PreviousVariantID.Settings=UT_Common.ValueToXMLString(
		CurrentSettingsComposer.GetSettings());
EndProcedure

&AtServer
Procedure SettingVariantsOnActivateRowAtServer(RowID)
	If RowID = CurrentSettingsVariantID Then
		Return;
	EndIf;

	CurrentData=SettingVariants.FindByID(RowID);
	If CurrentData = Undefined Then
		Return;
	EndIf;

	SaveToFormTableCurrentSettingsVariantSetting();

	CurrentSettingsVariantID=RowID;

	If ValueIsFilled(CurrentData.Settings) Then
		Settings=UT_Common.ValueFromXMLString(CurrentData.Settings);
	Else
		Settings=New DataCompositionSettings;
	EndIf;

	CurrentSettingsComposer.LoadSettings(Settings);
	CurrentSettingsComposer.Refresh();
EndProcedure

#EndRegion

&AtServer
Procedure InitializeForm()
	SetsTypes=DataSetsTypes();

	LocalDataSource=DataSources.Add();
	LocalDataSource.Name="DataSource1";
	LocalDataSource.DataSourceType="Local";

	ZerothDataSet=DataSets.GetItems().Add();
	ZerothDataSet.Name="Data sets";
	ZerothDataSet.Type=SetsTypes.Root;

	SettingsVariantByDefault=SettingVariants.Add();
	SettingsVariantByDefault.Name="Main";
	SettingsVariantByDefault.Presentation="Main";

	ZerothDataSetURL=ZerothDataSet.GetID();
	CurrentSettingsVariantID=SettingsVariantByDefault.GetID();

	SetFormConditionalAppearance();
EndProcedure

&AtServer
Procedure SetFormConditionalAppearance()
	DataSetsFiledsTypes=DataSetFieldsTypes();
	SetsTypes=DataSetsTypes();
	
	//1. For the set field, the folder forbid editing the "Field" column
	NewCA=ConditionalAppearance.Items.Add();
	NewCA.Use=True;
	UT_CommonClientServer.SetFilterItem(NewCA.Filter,
		"Items.DataSets.CurrentData.Fields.Type", DataSetsFiledsTypes.Folder);
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("DataSetsFieldsField");

	Appearance=NewCA.Appearance.FindParameterValue(New DataCompositionParameter("ReadOnly"));
	Appearance.Use=True;
	Appearance.Value=True;
	
	//1.1 For Fields data set  forbid to edit column "Use Restriction
	NewCA=ConditionalAppearance.Items.Add();
	NewCA.Use=True;
	UT_CommonClientServer.SetFilterItem(NewCA.Filter,
		"Items.DataSets.CurrentData.Fields.Type", DataSetsFiledsTypes.Set);
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsUseRestrictionField");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsUseRestrictionCondition");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsUseRestrictionGroup");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsUseRestrictionOrder");

	Appearance=NewCA.Appearance.FindParameterValue(New DataCompositionParameter("ReadOnly"));
	Appearance.Use=True;
	Appearance.Value=True;
	
	//2. For fields of set not  Fields block columns for editing
	NewCA=ConditionalAppearance.Items.Add();
	NewCA.Use=True;
	UT_CommonClientServer.SetFilterItem(NewCA.Filter,
		"Items.DataSets.CurrentData.Fields.Type", DataSetsFiledsTypes.Field, DataCompositionComparisonType.NotEqual);
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsUseRestrictionsAttributesField");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsUseRestrictionsAttributesCondition");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsUseRestrictionsAttributesGroup");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsUseRestrictionsAttributesOrder");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("DataSetsFieldsRolePresentation");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsPresentationExpression");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsHierarchyCheckDataSet");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsHierarchyCheckDataSetParameter");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsValueType");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsAvailableValues");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsAppearance");
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("FieldsEditParameters");

	Appearance=NewCA.Appearance.FindParameterValue(New DataCompositionParameter("ReadOnly"));
	Appearance.Use=True;
	Appearance.Value=True;
	
	//3. Name of parameter added automattically forbiden editing
	NewCA=ConditionalAppearance.Items.Add();
	NewCA.Use=True;
	UT_CommonClientServer.SetFilterItem(NewCA.Filter,
		"Items.DCSParameters.CurrentData.AddedAutomatically", True);
	Field=NewCA.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("DCSParametersName");

	Appearance=NewCA.Appearance.FindParameterValue(New DataCompositionParameter("ReadOnly"));
	Appearance.Use=True;
	Appearance.Value=True;

EndProcedure

#Region DCS

&AtServer
Procedure ReadDCSDataSourcesToFormData(DCS)
	DataSources.Clear();

	For Each CurrentSource In DCS.DataSources Do
		NewSource=DataSources.Add();
		FillPropertyValues(NewSource, CurrentSource);
	EndDo;
EndProcedure

&AtServer
Procedure ReadRoleOfDataSetFieldsToFormData(EditorRole, DataSetRole)
	EditorRole=NewStructureOfDataSetFieldRoleEditing();

	FillPropertyValues(EditorRole, DataSetRole, , "AccountingBalanceType,BalanceType");

	EditorRole.AccountingBalanceType=String(DataSetRole.AccountingBalanceType);
	EditorRole.AccountingBalanceType=String(DataSetRole.BalanceType);

	EditorRole.PeriodAdditional=DataSetRole.PeriodType = DataCompositionPeriodType.Additional;

	EditorRole.Period=DataSetRole.PeriodNumber <> 0;
EndProcedure

&AtServer
Procedure ReadDCSDataSetFieldsToFormData(NewSet, DataSetRow)
	NewSet.Fields.Clear();

	DCSDataSetFieldsTypes=DataSetFieldsTypes();

	For Each FieldRow In DataSetRow.Fields Do
		NewField=NewSet.Fields.Add();
		If TypeOf(FieldRow) = Type(DCSDataSetFieldsTypes.Field) Then
			NewField.Type=DCSDataSetFieldsTypes.Field;

			FillPropertyValues(NewField, FieldRow, , "Appearance,EditParameters,Role");

			ReadDataCompositionSchemaFieldUseRestrictionToFormData(
			FieldRow.AttributeUseRestriction, NewField.AttributeUseRestrictionField,
				NewField.AttributeUseRestrictionCondition,
				NewField.AttributeUseRestrictionGroup,
				NewField.AttributeUseRestrictionOrder);

			ReadDataCompositionSchemaFieldUseRestrictionToFormData(FieldRow.UseRestriction,
				NewField.UseRestrictionField, NewField.UseRestrictionCondition,
				NewField.UseRestrictionGroup, NewField.UseRestrictionOrder);
				
			
		//Appearance
			CopyAppearance(NewField.Appearance, FieldRow.Appearance);

			ReadRoleOfDataSetFieldsToFormData(NewField.Role, FieldRow.Role);
			NewField.RolePresentation=DataSetFieldRolePresentation(NewField.Role);

			NewField.AvailableValues=FieldRow.GetAvailableValues();
		ElsIf TypeOf(FieldRow) = Type(DCSDataSetFieldsTypes.Folder) Then
			NewField.Type=DCSDataSetFieldsTypes.Folder;

			FillPropertyValues(NewField, FieldRow);

			ReadDataCompositionSchemaFieldUseRestrictionToFormData(FieldRow.UseRestriction,
				NewField.UseRestrictionField, NewField.UseRestrictionCondition,
				NewField.UseRestrictionGroup, NewField.UseRestrictionOrder);

		Else
			NewField.Type=DCSDataSetFieldsTypes.Set;

			FillPropertyValues(NewField, FieldRow);
		EndIf;
		NewField.Picture=DataSetFieldTypePicture(NewField.Type, DCSDataSetFieldsTypes);
	EndDo;
EndProcedure
&AtServer
Procedure ReadDCSDataSetsToFormData(DCSDataSets, ParentDataSetRow = Undefined)
	If ParentDataSetRow = Undefined Then

		DataSetRowForFilling=DataSets.FindByID(ZerothDataSetURL);
	Else
		DataSetRowForFilling=ParentDataSetRow;
	EndIf;

	DataSetRowForFilling.GetItems().Clear();

	SetsTypes=DataSetsTypes();

	For Each DataSetRow In DCSDataSets Do
		NewSet=DataSetRowForFilling.GetItems().Add();
		If TypeOf(DataSetRow) = Type("DataCompositionSchemaDataSetQuery") Then
			NewSet.Type=SetsTypes.Query;
			NewSet.Picture=PictureLib.UT_DataSetDCSQuery;
		ElsIf TypeOf(DataSetRow) = Type("DataCompositionSchemaDataSetObject") Then
			NewSet.Type=SetsTypes.Object;
			NewSet.Picture=PictureLib.UT_DataSetDCSObject;
		Else
			NewSet.Type=SetsTypes.Union;
			NewSet.Picture=PictureLib.UT_DataSetDCSUnion;
		EndIf;
		FillPropertyValues(NewSet, DataSetRow, , "Fields");

		ReadDCSDataSetFieldsToFormData(NewSet, DataSetRow);

		If NewSet.Type = SetsTypes.Union Then
			ReadDCSDataSetsToFormData(DataSetRow.Items, NewSet);
		ElsIf NewSet.Type = SetsTypes.Query Then
			FillDataSetFieldsOnQueryChangeAtServer(NewSet.GetID());
			FillDCSParametersOnDataSetQueryChange(NewSet.GetID());
		ElsIf NewSet.Type = SetsTypes.Object Then
			ParentDataSet=NewSet.GetParent();
			If ParentDataSet.Type = SetsTypes.Union Then
				FillDataSetUnionFieldsByChildQuerys(ParentDataSet.GetID());
			EndIf;
		EndIf;
	EndDo;
EndProcedure
&AtServer
Procedure ReadDCSDataSetLinksToFormData(DCS)
	DataSetLinks.Clear();

	For Each CurrentData In DCS.DataSetLinks Do
		NewData=DataSetLinks.Add();
		FillPropertyValues(NewData, CurrentData);
	EndDo;
EndProcedure

&AtServer
Procedure ReadDataCompositionSchemaFieldUseRestrictionToFormData(UseRestriction, Field,
	Condition, Group, Order)

	Field=UseRestriction.Field;
	Condition=UseRestriction.Condition;
	Group=UseRestriction.Group;
	Order=UseRestriction.Order;
EndProcedure

&AtServer
Procedure ReadDCSCalculatedFieldsToFormData(DCS)
	CalculatedFields.Clear();

	For Each CurrentData In DCS.CalculatedFields Do
		NewData=CalculatedFields.Add();
		FillPropertyValues(NewData, CurrentData, , "OrderExpressions,Appearance,EditParameters");

		ReadDataCompositionSchemaFieldUseRestrictionToFormData(CurrentData.UseRestriction,
			NewData.UseRestrictionField, NewData.UseRestrictionCondition,
			NewData.UseRestrictionGroup, NewData.UseRestrictionOrder);
			
		//Appearance
		CopyAppearance(NewData.Appearance, CurrentData.Appearance);

		NewData.AvailableValues=CurrentData.GetAvailableValues();
	EndDo;
EndProcedure

&AtServer
Procedure ReadDCSTotalFieldsToFormData(DCS)
	Resources.Clear();

	For Each CurrentData In DCS.TotalFields Do
		NewData=Resources.Add();
		FillPropertyValues(NewData, CurrentData, , "Groups");

		For Each Item In CurrentData.Groups Do
			NewData.Groups.Add(Item);
		EndDo;
	EndDo;
EndProcedure
&AtServer
Procedure ReadDCSParametersToFormData(DCS)
	DCSParameters.Clear();

	For Each CurrentData In DCS.Parameters Do
		NewData=DCSParameters.Add();
		FillPropertyValues(NewData, CurrentData, , "EditParameters");

		NewData.UseAlways=CurrentData.Use = DataCompositionParameterUse.Always;

		NewData.AvailableValues=CurrentData.GetAvailableValues();
	EndDo;
EndProcedure

&AtServer
Procedure ReadDCSSettingVariantsToFormData(DCS)
	SettingVariants.Clear();

	For Each VariantRow In DCS.SettingVariants Do
		NewData=SettingVariants.Add();
		NewData.Name=VariantRow.Name;
		NewData.Presentation=VariantRow.Presentation;
		NewData.Settings=UT_Common.ValueToXMLString(VariantRow.Settings);
	EndDo;

	CurrentSettingsVariantID=SettingVariants[0].GetID();

	CurrentSettingsComposer.LoadSettings(VariantRow.Settings);
EndProcedure

&AtServer
Procedure ReadDCSToFormData(DCS)
	If IsTempStorageURL(InitialDataCompositionSchemaURL) Then
		InitialDataCompositionSchemaURL=PutToTempStorage(DCS,
			InitialDataCompositionSchemaURL);
	Else
		InitialDataCompositionSchemaURL=PutToTempStorage(DCS, UUID);
	EndIf;

	ReadDCSParametersToFormData(DCS);
	ReadDCSDataSourcesToFormData(DCS);
	ReadDCSDataSetsToFormData(DCS.DataSets);
	ReadDCSDataSetLinksToFormData(DCS);

	ReadDCSCalculatedFieldsToFormData(DCS);
	ReadDCSTotalFieldsToFormData(DCS);

	ReadDCSSettingVariantsToFormData(DCS);

EndProcedure

&AtServer
Procedure FillDCSDataSourcesByFormData(DCS)
	DCS.DataSources.Clear();

	For Each CurrentSource In DataSources Do
		NewSource=DCS.DataSources.Add();
		FillPropertyValues(NewSource, CurrentSource);
	EndDo;
EndProcedure

&AtServer
Procedure FillDataCompositionSchemaFieldUseRestriction(UseRestriction, Field, Condition, Group,
	Order)

	UseRestriction.Field=Field;
	UseRestriction.Condition=Condition;
	UseRestriction.Group=Group;
	UseRestriction.Order=Order;
EndProcedure

&AtServer
Procedure CopyAppearance(AppearanceReceiver, AppearanceSource)
	For Each CurrentAppearanceParameter In AppearanceSource.Items Do
		ParameterValue=AppearanceReceiver.FindParameterValue(CurrentAppearanceParameter.Parameter);
		If ParameterValue = Undefined Then
			Continue;
		EndIf;

		FillPropertyValues(ParameterValue, CurrentAppearanceParameter);
	EndDo;

EndProcedure

&AtServer
Function NewStructureOfDataSetFieldRoleEditing()
	Role=New Structure;
	Role.Insert("AccountTypeExpression", "");
	Role.Insert("BalanceGroup", "");
	Role.Insert("IgnoreNULLValues", False);
	Role.Insert("Dimension", False);
	Role.Insert("Period", False);
	Role.Insert("PeriodNumber", 0);
	Role.Insert("Required", False);
	Role.Insert("Balance", False);
	Role.Insert("AccountField", "");
	Role.Insert("ParentDimension", "");
	Role.Insert("Account", False);
	Role.Insert("AccountingBalanceType", "None");
	Role.Insert("BalanceType", "None");
	Role.Insert("PeriodAdditional", False);

	Return Role;
EndFunction

&AtServer
Procedure FillDataSetFieldRoleByFormData(DataSetRole, EditorRole)
	If EditorRole = Undefined Then
		EditorRole=NewStructureOfDataSetFieldRoleEditing();
	EndIf;

	FillPropertyValues(DataSetRole, EditorRole, , "AccountingBalanceType,BalanceType");
	DataSetRole.AccountingBalanceType=DataCompositionAccountingBalanceType[EditorRole.AccountingBalanceType];
	DataSetRole.BalanceType=DataCompositionBalanceType[EditorRole.BalanceType];

	If EditorRole.PeriodAdditional Then
		DataSetRole.PeriodType=DataCompositionPeriodType.Additional;
	Else
		DataSetRole.PeriodType=DataCompositionPeriodType.Main;
	EndIf;

	If Not EditorRole.Period Then
		DataSetRole.PeriodNumber=0;
	EndIf;
EndProcedure

&AtServer
Procedure FillDCSDataSetFieldsByFormData(NewSet, DataSetRow)
	NewSet.Fields.Clear();
	FieldsTypes=DataSetFieldsTypes();

	For Each FieldRow In DataSetRow.Fields Do
		NewField=NewSet.Fields.Add(Type(FieldRow.Type));
		If FieldRow.Type = FieldsTypes.Field Then
			FillPropertyValues(NewField, FieldRow, , "Appearance,EditParameters,Role");
			
			//Appearance
			CopyAppearance(NewField.Appearance, FieldRow.Appearance);

			FillDataSetFieldRoleByFormData(NewField.Role, FieldRow.Role);
			SetAvailableValuesForDCSItem(NewField, FieldRow.AvailableValues);

			FillDataCompositionSchemaFieldUseRestriction(NewField.AttributeUseRestriction,
				FieldRow.AttributeUseRestrictionField, FieldRow.AttributeUseRestrictionCondition,
				FieldRow.AttributeUseRestrictionGroup,
				FieldRow.AttributeUseRestrictionOrder);

		Else
			FillPropertyValues(NewField, FieldRow);
		EndIf;

		If FieldRow.Type <> FieldsTypes.Set Then
			FillDataCompositionSchemaFieldUseRestriction(NewField.UseRestriction,
				FieldRow.UseRestrictionField, FieldRow.UseRestrictionCondition,
				FieldRow.UseRestrictionGroup, FieldRow.UseRestrictionOrder);
		EndIf;
	EndDo;
EndProcedure
&AtServer
Procedure FillDCSDataSetsByFormData(DCSDataSets, ParentDataSetRow = Undefined)
//	DCS=New DataCompositionSchema;
	If ParentDataSetRow = Undefined Then

		DataSetRowForCopy=DataSets.FindByID(ZerothDataSetURL);
	Else
		DataSetRowForCopy=ParentDataSetRow;
	EndIf;

	DCSDataSets.Clear();

	For Each DataSetRow In DataSetRowForCopy.GetItems() Do
		NewSet=DCSDataSets.Add(Type(DataSetRow.Type));
		FillPropertyValues(NewSet, DataSetRow, , "Fields");

		FillDCSDataSetFieldsByFormData(NewSet, DataSetRow);

		If TypeOf(NewSet) = Type("DataCompositionSchemaDataSetUnion") Then
			FillDCSDataSetsByFormData(NewSet.Items, DataSetRow);
		EndIf;

	EndDo;
EndProcedure

&AtServer
Procedure FillDCSDataSetLinksByFormData(DCS)
	DCS.DataSetLinks.Clear();

	For Each CurrentData In DataSetLinks Do
		NewData=DCS.DataSetLinks.Add();
		FillPropertyValues(NewData, CurrentData);
	EndDo;
EndProcedure

&AtServer
Procedure FillDCSCalculatedFieldsByFormData(DCS)
	DCS.CalculatedFields.Clear();

	For Each CurrentData In CalculatedFields Do
		NewData=DCS.CalculatedFields.Add();
		FillPropertyValues(NewData, CurrentData, , "OrderExpressions,Appearance,EditParameters");

		FillDataCompositionSchemaFieldUseRestriction(NewData.UseRestriction,
			CurrentData.UseRestrictionField, CurrentData.UseRestrictionCondition,
			CurrentData.UseRestrictionGroup, CurrentData.UseRestrictionOrder);
			
		//Appearance
		CopyAppearance(NewData.Appearance, CurrentData.Appearance);

		SetAvailableValuesForDCSItem(NewData, CurrentData.AvailableValues);
	EndDo;
EndProcedure
&AtServer
Procedure FillDCSTotalFieldsByFormData(DCS)
	DCS.TotalFields.Clear();

	For Each CurrentData In Resources Do
		NewData=DCS.TotalFields.Add();
		FillPropertyValues(NewData, CurrentData, , "Groups");

		For Each Item In CurrentData.Groups Do
			NewData.Groups.Add(Item.Value);
		EndDo;
	EndDo;
EndProcedure
&AtServer
Procedure FillDCSParametersByFormData(DCS)
	DCS.Parameters.Clear();

	For Each CurrentData In DCSParameters Do
		NewData=DCS.Parameters.Add();
		FillPropertyValues(NewData, CurrentData, , "EditParameters");

		If CurrentData.UseAlways Then
			NewData.Use=DataCompositionParameterUse.Always;
		Else
			NewData.Use=DataCompositionParameterUse.Auto;
		EndIf;

		SetAvailableValuesForDCSItem(NewData, CurrentData.AvailableValues);
	EndDo;
EndProcedure

&AtServer
Procedure SetAvailableValuesForDCSItem(Item, AvailableValues)
	If AvailableValues.Count() = 0 Then
//		Item.SetAvailableValues(AvailableValues);
//	Else
		Item.SetAvailableValues(AvailableValues);
	EndIf;

EndProcedure

&AtServer
Procedure FillDCSSettingVariantsByFormData(DCS)
	DCS.SettingVariants.Clear();

	For Each VariantRow In SettingVariants Do
		NewData=DCS.SettingVariants.Add();
		NewData.Name=VariantRow.Name;
		NewData.Presentation=VariantRow.Presentation;
		If ValueIsFilled(VariantRow.Settings) Then
			UT_CommonClientServer.CopyDataCompositionSettings(NewData.Settings,
				UT_Common.ValueFromXMLString(VariantRow.Settings));
		EndIf;
	EndDo;
EndProcedure
&AtServer
Procedure AssembleDCSFromFormData(EnableSettingsVariants = False)
	If IsTempStorageURL(InitialDataCompositionSchemaURL) Then
		DCS=GetFromTempStorage(InitialDataCompositionSchemaURL);
		If TypeOf(DCS) <> Type("DataCompositionSchema") Then
			DCS=New DataCompositionSchema;
		EndIf;
	Else
		DCS=New DataCompositionSchema;
	EndIf;
	FillDCSDataSourcesByFormData(DCS);
	FillDCSDataSetsByFormData(DCS.DataSets);
	FillDCSDataSetLinksByFormData(DCS);
	FillDCSCalculatedFieldsByFormData(DCS);
	FillDCSTotalFieldsByFormData(DCS);
	FillDCSParametersByFormData(DCS);

	If EnableSettingsVariants Then
		SaveToFormTableCurrentSettingsVariantSetting();
		FillDCSSettingVariantsByFormData(DCS);
	EndIf;

	If IsTempStorageURL(DataCompositionSchemaURL) Then
		DataCompositionSchemaURL=PutToTempStorage(DCS, DataCompositionSchemaURL);
	Else
		DataCompositionSchemaURL=PutToTempStorage(DCS, UUID);
	EndIf;

	InitializeSettingsComposerByAssembledDCS();
EndProcedure

#EndRegion

#EndRegion
DataSetsTypes=DataSetsTypes();
DataSetFieldsTypes=DataSetFieldsTypes();