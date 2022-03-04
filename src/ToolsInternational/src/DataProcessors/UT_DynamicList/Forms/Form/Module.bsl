#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("ChoiceMode") Then
		ChoiceMode=Parameters.ChoiceMode;
	EndIf;
	If Parameters.Property("MetadataObjectName") Then
		MetadataObjectName=Parameters.MetadataObjectName;
	EndIf;

// Collect avalible object types to tree
	AddObjectTypeToTree(PictureLib.Catalog, "Catalogs", "Catalog", "Catalogs");
	AddObjectTypeToTree(PictureLib.Document, "Documents", "Document", "Documents");
	AddObjectTypeToTree(PictureLib.DocumentJournal, "DocumentJournals", "DocumentJournal", "Document journals");
	AddObjectTypeToTree(PictureLib.ChartOfCharacteristicTypes, "ChartsOfCharacteristicTypes",
		"ChartOfCharacteristicTypes", "Charts  of characteristic types");
	AddObjectTypeToTree(PictureLib.ChartOfAccounts, "ChartsOfAccounts", "ChartOfAccounts", "Charts of Accounts");
	AddObjectTypeToTree(PictureLib.ChartOfCalculationTypes, "ChartsOfCalculationTypes", "ChartOfCalculationTypes",
		"Charts of calculation types");
	AddObjectTypeToTree(PictureLib.ExchangePlan, "ExchangePlans", "ExchangePlan", "Планы обмена");
	AddObjectTypeToTree(PictureLib.InformationRegister, "InformationRegisters", "InformationRegister",
		"Information registers");
	AddObjectTypeToTree(PictureLib.AccumulationRegister, "AccumulationRegisters", "AccumulationRegister",
		"Accumulation registers");
	AddObjectTypeToTree(PictureLib.CalculationRegister, "CalculationRegisters", "CalculationRegister",
		"Calculation registers");
	AddObjectTypeToTree(PictureLib.AccountingRegister, "AccountingRegisters", "AccountingRegister",
		"Accounting registers");
	AddObjectTypeToTree(PictureLib.BusinessProcess, "BusinessProcesses", "BusinessProcess", "Business processes");
	AddObjectTypeToTree(PictureLib.Task, "Tasks", "Task", "Tasks");

	If ValueIsFilled(MetadataObjectName) Then
		Items.MetadataTree.Visible=False;
		SetDynamicListParametersAtServer(MetadataObjectRowID);
	EndIf;

	Items.Choose.Visible=ChoiceMode;
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);
	
EndProcedure
#EndRegion

#Region FormItemsEventHandlers

&AtClient
Procedure MetadataTreeSelection(Item, RowSelected, Field, StandardProcessing)
	SetDynamicListParametersAtServer(RowSelected);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_DynamicListSelection(Item, RowSelected, Field, StandardProcessing)

EndProcedure

&AtClient
Procedure EditObject(Command)
	If Items.GroupDynamicListChoosePages.CurrentPage <> Items.GroupDynamicList Then
		Return;
	EndIf;

	FormAttributeName = "DynamicList";

	CurrentRef=Items[FormAttributeName].CurrentRow;
	If CurrentRef = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(CurrentRef);
EndProcedure
#EndRegion

#Region FormCommandsHandlers

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure


#EndRegion

#Region OtherFunctions

&AtServer
Procedure DeleteDynamicList(AttributeName)
	DeletedAttributesArray = New Array;
	DeletedAttributesArray.Add(AttributeName);

	CurrentFormAttributes = GetAttributes();

	HaveAttribute = False;
	For Each Attribute In CurrentFormAttributes Do
		If Attribute.Name = AttributeName Then
			HaveAttribute = True;
			Break;
		EndIf;
	EndDo;

	If HaveAttribute Then
		ChangeAttributes( , DeletedAttributesArray);
	EndIf;

	DynList = ThisForm.Items.Find(AttributeName);
	If DynList <> Undefined Then
		Items.Delete(DynList);
	EndIf;
EndProcedure

&AtServer
Procedure SetDynamicListParametersAtServer(RowSelected)
	CurrentData = MetadataTree.FindByID(RowSelected);
	If CurrentData = Undefined Then
		Return;
	EndIf;
	Title=CurrentData.Presentation;

	FormAttributeName = "DynamicList";
	DeleteDynamicList(FormAttributeName);

	If Not ValueIsFilled(CurrentData.ObjectType) Then
		Items.GroupDynamicListChoosePages.CurrentPage = Items.GroupWithoutDynamicList;
		Return;
	EndIf;

	AddedAttributes = New Array;
	AddedAttributes.Add(New FormAttribute(FormAttributeName, New TypeDescription("DynamicList"), ,
		CurrentData.Presentation, False));

	ChangeAttributes(AddedAttributes);

	CurrentList = ThisObject[FormAttributeName];

	CurrentList.MainTable = CurrentData.ObjectsType + "." + CurrentData.ObjectType;
	CurrentList.CustomQuery = False;
	

	//Get attributes of our list
	ListAttributesArray = New Array;
	ListAttributes = GetAttributes(FormAttributeName);
	For Each CurrentAttribute In ListAttributes Do
		ListAttributesArray.Add(CurrentAttribute.Name);
	EndDo;

	// Create table (form item) for show data
	FormItem = Items.Add(FormAttributeName, Type("FormTable"), Items.GroupDynamicList);
	FormItem.DataPath = FormAttributeName;
	FormItem.ToolTip = CurrentData.Comment;
	FormItem.Title = CurrentData.Presentation;
	//	FormItem.SetAction("ValueChoice", "ChoiceList");
	//	FormItem.ChoiceMode = Not DataBaseViewMode;
	FormItem.ChoiceFoldersAndItems = FoldersAndItemsUse.FoldersAndItems;
	//	FormItem.SelectionMode = ?(DataBaseViewMode, TableSelectionMode.MultiRow, TableSelectionMode.SingleRow);
	//FormItem.CurrentItem.CurrentData = SelectedRef; //It's a pity it doesn't work. It would be good to set the current row.
	HaveDisplayedAttributes = False;
	// Create collums in displayed table
	For Each CurrentAttribute In CurrentData.Attributes Do
		If ListAttributesArray.Find(CurrentAttribute.Name) = Undefined Then
			Continue;
		EndIf;

		Try
			Column = Items.Add(FormAttributeName + CurrentAttribute.Name, Type("FormField"), FormItem);
			Column.Type = ?(CurrentAttribute.ValueType.Types().Count() = 1 And CurrentAttribute.ValueType.Types()[0] = Type(
				"Boolean"), FormFieldType.CheckBoxField, FormFieldType.InputField);
			Column.DataPath = FormAttributeName + "." + CurrentAttribute.Name;
			Column.ToolTip = CurrentAttribute.Presentation;
			HaveDisplayedAttributes = True;
		Except
			Message(NSTR("ru = 'Не удалось создать колонку списка для реквизита';en = 'Failed to create a list column for attribute'") + CurrentAttribute.Name);
		EndTry;
	EndDo;
	FormItem.ChoiceMode=ChoiceMode;
	
	//Need to add buttons to the command panel
	GroupCommandBar=Items[FormAttributeName + "CommandBar"];
	//OpenButton
	ButtonDescription=UT_Forms.ButtonCommandNewDescription();
	ButtonDescription.Name=FormAttributeName + "EditObject";
	ButtonDescription.ItemParent=GroupCommandBar;
	ButtonDescription.CreateButton=True;
	ButtonDescription.CommandName="EditObject";
	UT_Forms.CreateButtonByDescription(ThisObject, ButtonDescription);

	ButtonDescription=UT_Forms.ButtonCommandNewDescription();
	ButtonDescription.Name=FormAttributeName + "DeleteSelectedObjects";
	ButtonDescription.ItemParent=GroupCommandBar;
	ButtonDescription.CreateButton=True;
	ButtonDescription.CommandName="DeleteSelectedObjects";
	UT_Forms.CreateButtonByDescription(ThisObject, ButtonDescription);

	If HaveDisplayedAttributes Then
		Items.GroupDynamicListChoosePages.CurrentPage = Items.GroupDynamicList;
	Else
		Items.GroupDynamicListChoosePages.CurrentPage = Items.GroupNotAvalibleTable;
	EndIf;
EndProcedure

&AtServer
Function AttributesTablesArrayForMetaObject(MetadataObject)
	AttributesTablesArray = New Array;
	AttributesTablesArray.Add(MetadataObject.StandardAttributes);

	If UT_Common.IsInformationRegister(MetadataObject) Or UT_Common.IsAccumulationRegister(
		MetadataObject) Or UT_Common.IsCalculationRegister(MetadataObject)
		Or UT_Common.IsAccountingRegister(MetadataObject) Then
		AttributesTablesArray.Add(MetadataObject.Dimensions);
		AttributesTablesArray.Add(MetadataObject.Resources);
	EndIf;
	
	If UT_Common.IsDocumentJournal(MetadataObject) Then
		AttributesTablesArray.Add(MetadataObject.Columns);
	Else	
		AttributesTablesArray.Add(MetadataObject.Attributes);
	EndIf;
	If UT_Common.IsChartOfAccounts(MetadataObject) Then
		AttributesTablesArray.Add(MetadataObject.AccountingFlags);
	EndIf;

	Return AttributesTablesArray;
EndFunction

// Add to value tree row of description SetDynamicListParametersAtServer objects.
&AtServer
Procedure AddObjectTypeToTree(Picture, MetadataTypeName, ObjectTypeName, Presentation)

	TreeItems = MetadataTree.GetItems();

	TypeRow = TreeItems.Add();
	TypeRow.Picture = Picture;
	TypeRow.Presentation = Presentation;
	TypeRow.ObjectsType = ObjectTypeName;

	TreeRowItems = TypeRow.GetItems();

	NonDospalyedAttribute = New Array;
	NonDospalyedAttribute.Add("REF");
	NonDospalyedAttribute.Add("PREDEFINEDDATANAME"); 
	NonDospalyedAttribute.Add("ISFOLDER");
	NonDospalyedAttribute.Add("POSTED");
	NonDospalyedAttribute.Add("DELETIONMARK");
	NonDospalyedAttribute.Add("THISNODE");
	NonDospalyedAttribute.Add("PREDEFINED");
	NonDospalyedAttribute.Add("PARENT");

	For Each ObjectMD In Metadata[MetadataTypeName] Do
		MetadaObjectSynonym = ?(IsBlankString(ObjectMD.Synonym), "", " (" + ObjectMD.Synonym + ")");
		IsDocumentJournal=UT_Common.IsDocumentJournal(ObjectMD);

		RowOfType = TreeRowItems.Add();
		RowOfType.Picture = Picture;
		RowOfType.Presentation = ObjectMD.Name + MetadaObjectSynonym;
		RowOfType.ObjectsType = ObjectTypeName;
		RowOfType.ObjectType = ObjectMD.Name;
		RowOfType.Comment = ObjectMD.Comment;
		RowOfType.FullName=ObjectMD.FullName();

		If Lower(RowOfType.FullName) = Lower(MetadataObjectName) And ValueIsFilled(MetadataObjectName) Then
			MetadataObjectRowID=RowOfType.GetID();
		EndIf;

		AttributesTablesArray = AttributesTablesArrayForMetaObject(ObjectMD);

		For Each AttributesTable In AttributesTablesArray Do
			For Each Attribute In AttributesTable Do
				If NonDospalyedAttribute.Find(Upper(Attribute.Name)) <> Undefined Then
					Continue;
				EndIf;

				NewAttribute = RowOfType.Attributes.Add();
				NewAttribute.Name = Attribute.Name;
				NewAttribute.Presentation = Attribute.Synonym;
				If NOT IsDocumentJournal Then
					NewAttribute.ValueType = Attribute.Type;
				EndIf;
			EndDo;
		EndDo;
	EndDo;

EndProcedure
&AtClient
Procedure Choose(Command)
	If Items.Find("DynamicList") = Undefined Then
		Return;
	EndIf;

	CurrentData = Items.MetadataTree.CurrentData;
	If ValueIsFilled(MetadataObjectName) Then
//		Return;
	ElsIf CurrentData = Undefined Then
		Return;
	ElsIf Not ValueIsFilled(CurrentData.ObjectType) Then
		Return;
	EndIf;

	NotifyChoice(Items.DynamicList.CurrentRow);
	Close(Items.DynamicList.CurrentRow);
EndProcedure

&AtClient
Procedure DeleteSelectedObjects(Command)
	If Items.GroupDynamicListChoosePages.CurrentPage <> Items.GroupDynamicList Then
		Return;
	EndIf;

	FormAttributeName = "DynamicList";

	RefsArray = New Array;

	For Each Item In Items[FormAttributeName].SelectedRows Do
		RefsArray.Add(Item);
	EndDo;

	ItemsCount = RefsArray.Count();

	If ItemsCount = 0 Then
		Return;
	EndIf;
	ТекстВопроса = "Objects (" + ItemsCount + " шт) будут удалены из базы!
												  |Никакие проверки производиться не будут (возможно появление битых ссылок)!
												  |
												  |Продолжить?";

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("RefsArray", RefsArray);
	AdditionalParameters.Insert("FormAttributeName", FormAttributeName);

	ShowQueryBox(New NotifyDescription("DeleteSelectedObjectsEnd", ThisForm, AdditionalParameters), ТекстВопроса,
		QuestionDialogMode.YesNo, 20, , "ВНИМАНИЕ");
EndProcedure

&AtClient
Procedure DeleteSelectedObjectsEnd(QuestionResult, AdditionalParameters) Export
	If QuestionResult <> DialogReturnCode.Yes Then
		Return;
	EndIf;
	DeleteSelectedObjectsAtServer(AdditionalParameters.RefsArray);
	Items[AdditionalParameters.FormAttributeName].Update();
EndProcedure

&AtServerNoContext
Procedure DeleteSelectedObjectsAtServer(RefsArray)
	For Each Reference In RefsArray Do
		Try
			pObject = Reference.GetObject();
			If pObject = Undefined Then
				Return;
			EndIf;
			pObject.Delete();
		Except
			Message("Ошибка при удалении объекта:" + Chars.LF + ErrorDescription());
		EndTry;
	EndDo;
EndProcedure

#EndRegion