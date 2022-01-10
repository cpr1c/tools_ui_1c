// English Code Area 

#Region ItemsDescription 

Function ItemAttributeNewDescription() Export
	AttributeStructure = New Structure;

	AttributeStructure.Insert("CreateAttribute", True);
	AttributeStructure.Insert("Name", "");
	AttributeStructure.Insert("TypeDescription", New TypeDescription("String", , , , New StringQualifiers(10)));
	AttributeStructure.Insert("DataPath", "");
	AttributeStructure.Insert("Title", "");

	AttributeStructure.Insert("CreateItem", True);
	AttributeStructure.Insert("ItemParent", Undefined);
	AttributeStructure.Insert("BeforeItem", Undefined);
	AttributeStructure.Insert("MultiLine", Undefined);
	AttributeStructure.Insert("ExtendedEdit", Undefined);
	AttributeStructure.Insert("HorizontalStretch", Undefined);
	AttributeStructure.Insert("VerticalStretch", Неопределено);

	AttributeStructure.Insert("Properties", AttributePropertiesNew());

	AttributeStructure.Insert("Actions", New Structure);

	Return AttributeStructure;

EndFunction

Function AttributePropertiesNew()

	AttributeProperties = New Structure;

	AttributeProperties.Insert("FieldType", Type("FormField"));
	AttributeProperties.Insert("Default_Type", FormFieldType.InputField);

	Return AttributeProperties;

EndFunction

Function ButtonCommandNewDescription () export
	Structure = New Structure;

	Structure.Insert("CreateCommand", True);
	Structure.Insert("CreateButton", True);

	Structure.Insert("Name", "");
	Structure.Insert("Action", "");
	Structure.Insert("CommandName", "");
	Structure.Insert("IsHyperLink", False);
	Structure.Insert("ItemParent", Undefined);
	Structure.Insert("BeforeItem", Undefined);
	Structure.Insert("Title", "");
	Structure.Insert("ToolTip", "");
	Structure.Insert("Shortcut", Undefined);
	Structure.Insert("Picture", Undefined);
	Structure.Insert("Representation", Undefined);

	Возврат Structure;
EndFunction

Function FormGroupNewDescription() Export
	Parameters = New Structure;

	Parameters.Insert("Type", FormGroupType.UsualGroup);
	Parameters.Insert("Name", "");
	Parameters.Insert("Title", "");
	Parameters.Insert("Behavior", UsualGroupBehavior.Usual);
	Parameters.Insert("Representation", UsualGroupRepresentation.None);
	Parameters.Insert("GroupType", ChildFormItemsGroup.Vertical);
	Parameters.Insert("ShowTitle", False);
	Parameters.Insert("Parent", Undefined);

	Return Parameters;

EndFunction
#EndRegion

#Region FormItemsProgramingCreation  

Function CreateCommandByDescription(Form, CommandDescription) Export
	If Не CommandDescription.CreateCommand Then
		Return Undefined;
	EndIf;
	Command = Form.Commands.Add(CommandDescription.Name);
	Command.Title = CommandDescription.Title;
	Command.ToolTip = CommandDescription.ToolTip;
	Command.Action = CommandDescription.Action;
	If CommandDescription.Picture<>Undefined Then
		if not UT_CommonClientServer.IsPortableDistribution()
			or CommandDescription.Picture.Type = PictureType.FromLib
			or CommandDescription.Picture.Type = PictureType.Empty then
			Command.Picture = CommandDescription.Picture;
		endif;
	EndIf;
	If CommandDescription.Shortcut <> Undefined Then
		Command.Shortcut = CommandDescription.Shortcut;
	Endif;
	If CommandDescription.Representation<>Undefined Then
		Command.Representation=CommandDescription.Representation;
	EndIf;

	Return Command;
EndFunction

Function CreateItemByDescription(Form, ItemDescription) Export
	If  NOT ItemDescription.CreateItem Then
		Return Undefined;
	EndIf;

	FormItemName = FormFieldTableName(Form, ItemDescription.ItemParent) + ItemDescription.Name;
	FormItem = Form.Items.Find(FormItemName);
	If FormItem <> Undefined Then
		Return FormItem;
	EndIf;

	If ItemDescription.BeforeItem = Undefined Then
		FormItem = Form.Items.Add (FormFieldTableName(Form, ItemDescription.ItemParent)	+ ItemDescription.Name, ItemDescription.Properties.FieldType, FormItem(Form,
			ItemDescription.ItemParent));
	Else
		FormItem = Form.Items.Insert(FormFieldTableName(Form, ItemDescription.ItemParent)
			+ ItemDescription.Name, ItemDescription.Properties.FormItemType, FormItem(Form,
			ItemDescription.ItemParent), FormItem(Form, ItemDescription.BeforeItem));
	EndIf;

	FormItem.Title = ItemDescription.Title;

	If Type(FormItem) = Type("FormField") Then
		FormItem.Type = ItemDescription.Properties.Default_Type;
		Try
			If TypeOf(Attribute(Form, ItemDescription.Name, ItemDescription.AttributePath)) = Type("Boolean") Then
				FormItem.Type = FormFieldType.CheckBoxField;
			EndIf;
		Except
		//			ErrorDescription = ErrorDescription();
		EndTry;
	EndIf;

	FillPropertyValues(FormItem, ItemDescription.Properties);

	If Тип(FormItem) = Тип("FormField") Then
		If ValueIsFilled(ItemDescription.DataPath) Then
			FormItem.DataPath = ItemDescription.DataPath;
		Else
			FormItem.DataPath = ItemDescription.Name;
		EndIf;

		If ItemDescription.MultiLine <> Undefined Then
			FormItem.MultiLine = ItemDescription.MultiLine;
		EndIf;
		If ItemDescription.ExtendedEdit <> Undefined Then
			FormItem.ExtendedEdit = ItemDescription.ExtendedEdit;
		EndIf;

	EndIf;
	If ItemDescription.HorizontalStretch <> Undefined Then
		FormItem.HorizontalStretch = ItemDescription.HorizontalStretch;
	EndIf;
	If ItemDescription.VerticalStretch <> Undefined Then
		FormItem.VerticalStretch = ItemDescription.VerticalStretch;
	EndIf;

	For Each Action In ItemDescription.Actions Do
		FormItem.SetAction(Action.Key, Action.Value);
	EndDo;
	Return FormItem;
EndFunction

Function CreateButtonByDescription(Form, ButtonDescription) Export
	If Not ButtonDescription.CreateButton Then
		Return Undefined;
	EndIf;

	Button = Form.Items.Insert(ButtonDescription.Name, Type("FormButton"), FormItem(Form,
		ButtonDescription.ItemParent), FormItem(Form, ButtonDescription.BeforeItem));
	IF Not ButtonDescription.CreateCommand Then
		Button.Title = ButtonDescription.Title;
	EndIf;
	If ButtonDescription.IsHyperlink = False Then
		If IsCommandBarButton(Form, ButtonDescription.ItemParent) Then
			Button.Type = FormButtonType.UsualButton;
		Else
			Button.Type = FormButtonType.CommandBarButton;
		EndIf;
	Else
		If IsCommandBarButton(Form, ButtonDescription.ItemParent) Then
			Button.Type = FormButtonType.Hyperlink;
		Else
			Button.Type = FormButtonType.CommandBarHyperlink;
		EndIf;
	EndIf;
	Button.CommandName = ButtonDescription.CommandName;
EndFunction

Function CreateGroupByDescription(Form, Description) Export

	FormItemName = FormFieldTableName(Form, Description.Parent) + Description.Name;
	FormGroup = Form.Items.Find(FormItemName);
	If FormGroup <> Undefined Then
		Return FormGroup;
	EndIf;
	FormGroup = Form.Items.Add(FormItemName, Type("FormGroup"), FormItem(Form, Description.Parent));

	FormGroup.Type = Description.Type;

	FormGroup.Title = Description.Title;

	FillPropertyValues(FormGroup, Description, "Type,ShowTitle");

	If FormGroup.Type = FormGroupType.UsualGroup Then
		FillPropertyValues(FormGroup, Description, "Behavior,Representation");
	EndIf;
	//	If Description.HorizontalStretch<>Undefined Then
	//		FormGroup.HorizontalStretch=Description.HorizontalStretch;
	//	EndIf;
	//	If Description.VerticalStretch<>Undefined Then
	//		FormGroup.VerticalStretch=Description.VerticalStretch;
	//	Endif;
	Return FormGroup;
EndFunction

Function IsCommandBarButton(Form, Val ButtonParent)
//@skip-warning
	if ButtonParent = Undefined then
		Return Ложь;
	ElsIf ButtonParent = Form.CommandBar then
		Return True;
	ElsIf TypeOf(ButtonParent) = UT_CommonClientServer.ManagedFormType() then
		Return False;
	Else
		ButtonParent = FormItem(Form, ButtonParent);
		Return IsCommandBarButton(Form, ButtonParent.Parent);
	EndIf;
EndFunction
  
Function FormFieldTableName(Form, Val ItemParent)
//@skip-warning
	If ItemParent = Undefined Then
		Return "";
	ElsIf TypeOf(ItemParent) = Type("FormTable") Then
		Return ItemParent.Name;
	ElsIf TypeOf(ItemParent) = UT_CommonClientServer.ManagedFormType() Then
		Return "";
	Else
	//		ButtonParent = FormItem(Form, ItemParent);
		Return FormFieldTableName(Form, ItemParent.Parent);
	Endif;
EndFunction

Function FormItem(Form, ID) Export
	If TypeOf(ID) = Type("String") Then
		Return Form.Items.Find(ID);
	Else
		Return ID;
	Endif;
EndFunction

 Function Attribute(Form, AttributeName, AttributeDataPath = "") Export
	If AttributeDataPath <> "" Then
		Separator = StrFind(AttributeDataPath, ".");
		If Separator = 0 Then
			StepName = AttributeDataPath;
			DataPathRest= "";
		Else
			StepName = Left(AttributeDataPath, Separator - 1);
			DataPathRest = Mid(AttributeDataPath, Separator + 1);
		EndIf;
		Return Attribute(Form[StepName], AttributeName, DataPathRest);
	Else
		NonExistValue = Undefined;
		Structure = New Structure(AttributeName, NonExistValue);
		FillPropertyValues(Structure, Form);
		If Structure[AttributeName] = NonExistValue Then
			Return NonExistValue;
		EndIf;
		Return Form[AttributeName];
	EndIf;
EndFunction
#EndRegion

#Region PostingSettings  
 
  Procedure CreateWriteParametersAttributesFormOnCreateAtServer(Form, FormGroup) Export
	WriteSettings=New Structure;
	WriteSettings.Insert("WithOutChangesAutoRecording", New Structure("Value,Title", Ложь,
		"Без авторегистрации изменений"));
	WriteSettings.Insert("WritingInLoadMode", New Structure("Value,Title", Ложь,
		"Запись в режиме загрузки(Без проверок)"));
	WriteSettings.Insert("PrivilegedMode", New Structure("Value,Title", Ложь,
		"Привелигированный режим"));
	WriteSettings.Insert("UseAdditionalProperties", New Structure("Value,Title", Ложь,
		"Использовать доп. свойства"));
	WriteSettings.Insert("AdditionalProperties", New Structure("Value,Title", New Structure,
		"Дополнительные свойства"));
	WriteSettings.Insert("UseBeforeWriteProcedure", New Structure("Value,Title", Ложь,
		"Без авторегистрации изменений"));
	WriteSettings.Insert("BeforeWriteProcedure", New Structure("Value,Title", "",
		"Без авторегистрации изменений"));

	ParameterPrefix="WriteParameter_";

	AddedAtributesArray=New Array;

	For Each KeyValue In WriteSettings Do
		AttributeType=TypeOf(KeyValue.Value.Value);

		If AttributeType = Type ("Structure") Then
			AttributeType= Type ("ValueTable");
//			Continue;
		EndIf;

		TypesArray=New Array;
		TypesArray.Add(AttributeType);
		NewAttribute=New FormAttribute(ParameterPrefix + KeyValue.Key, New TypeDescription(TypesArray), "",
			KeyValue.Value.Title, False);
		AddedAtributesArray.Add(NewAttribute);
	EndDo;

	Form.ChangeAttributes(AddedAtributesArray);

	AddedAtributesArray.Clear();
	AddedAtributesArray.Add(New FormAttribute("Key", New TypeDescription("String"), ParameterPrefix
		+ "AdditionalProperties", "Key", False));

	ValueTypesArray=New Массив;
	ValueTypesArray.Add("Булево");
	ValueTypesArray.Add("Строка");
	ValueTypesArray.Add("Число");
	ValueTypesArray.Add("Дата");
	ValueTypesArray.Add("УникальныйИдентификатор");
	ValueTypesArray.Add("ЛюбаяСсылка");
	AddedAtributesArray.Add(New FormAttribute("Value", New TypeDescription(ValueTypesArray),
		ParameterPrefix + "AdditionalProperties", "Value", False));
	Form.ChangeAttributes(AddedAtributesArray);

	CreatingAttributesArray=UT_CommonClientServer.ToolsFormOutputWriteSettings();

	Для Каждого CreatingAttributeName Из CreatingAttributesArray Цикл
		ItemDescription=ItemAttributeNewDescription();
		ItemDescription.CreateItem = Истина;
		ItemDescription.Name=ParameterPrefix + CreatingAttributeName;
		ItemDescription.ItemParent = FormGroup;
		ItemDescription.Properties.Insert("FormItemType", FormFieldType.CheckBoxField);

		UT_Forms.CreateItemByDescription(Form, ItemDescription);
	КонецЦикла;
	
	//Add кнопку редактирования настроек
	ButtonDescription=ButtonCommandNewDescription();
	ButtonDescription.Name=ParameterPrefix + "РедактироватьПараметрыЗаписи";
	ButtonDescription.CommandName=ButtonDescription.Name;
	ButtonDescription.ItemParent=FormGroup;
	ButtonDescription.Title="Другие параметры записи";
	ButtonDescription.Picture=PictureLib.DataCompositionOutputParameters;
	ButtonDescription.IsHyperLink=Истина;
	ButtonDescription.Action="Attachable_SetWriteSettings";

	UT_Forms.CreateCommandByDescription(Form, ButtonDescription);
	UT_Forms.CreateButtonByDescription(Form, ButtonDescription);
EndProcedure
#EndRegion