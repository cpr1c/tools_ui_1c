&AtClient
Procedure WriteAndClose(Command)
	If Not Parameters.Rename Then
		ChangeParameter();
		Notify("ParameterChanged");
	EndIf;
	Close();
EndProcedure

&AtClient
Procedure SetParameterName(Command)
	ParameterName=TrimAll(ParameterName);
	If ParameterNameHasErrors(ParameterName) Then
		Message = New UserMessage;
		Message.Text = NSTR("ru = 'Введите наименование параметра';en = 'Input parameter name'");
		Message.Field = "ParameterName";
		Message.Message();
	Else
		If Parameters.Rename Then
			RenameParameter(Parameters.ParameterName, ParameterName);
			Notify("ParameterChanged");
			Close();
		Else
			ThisForm.Title= StrTemplate(NSTR("ru = 'Новый параметр';en = 'New parameter'"),ParameterName);
			FormItemsVisibilityManaging("SelectedType", False);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Function ParameterNameHasErrors(Name)
	If IsBlankString(Name) Then
		Return True;
	Else
		 //TODO  Check for avalible symbols
		Return False;
	EndIf;
EndFunction

&AtClient
Procedure ExternalFileStartChoice(Item, ChoiceData, StandardProcessing)
	StandardProcessing=False;
	Dialog = New FileDialog(FileDialogMode.Opening);
	Dialog.Title = NSTR("ru = 'Выберите файл';en = 'Choose file'");
	Dialog.FullFileName = "";
	Filter =NSTR("ru = 'Все файлы  (*.*)|*.*';en = 'All files (*.*)|*.*'");
	Dialog.Filter = Filter;
	Dialog.Multiselect = False;
	Dialog.Show(New NotifyDescription("ExternalFileStartChoiceOnEnd", ThisForm));
EndProcedure


&AtClient
Procedure ExternalFileStartChoiceOnEnd(SelectedFiles, AdditionalParameters) Export
	If (TypeOf(SelectedFiles) = Type("Array") And SelectedFiles.Count() > 0) Then
		ExternalFile = SelectedFiles[0];
		NotifyDescription = New NotifyDescription("PutFileEnd", ThisObject);
		BeginPutFile(NotifyDescription, , ExternalFile, False, ThisForm.UUID);
	Else
		_37583_AlgorithmsClient.PopUp(" No file ");
	EndIf;
EndProcedure

&AtClient
Procedure PutFileEnd(Result, Address, ВыбранноеИмяФайла, AdditionalParameters) Export
	StorageURL = Address;
EndProcedure

&AtServer
Procedure FormItemsVisibilityManaging(P = "", ButtonsVisibility = True)
	For Each Item In Items Do
		If TypeOf(Item) = Type("FormDecoration") Then
			Continue;
		EndIf;
		If Not IsBlankString(P) Then
			Item.Visible=?(Find(Item.Name, P) > 0, True, False);
		EndIf;
		If Find(Item.Name, "Close") > 0 Then
			Item.Visible=ButtonsVisibility;
			Item.Parent.Visible=True;
		EndIf;
	EndDo;
EndProcedure

&AtServer
Procedure CollectionVisibilityManaging(P = "Array")
	If Not IsBlankString(Parameters.ParameterName) Then
		Items.TypeCollection.Visible=False;
	EndIf;
	If P = "Array" Then
		AddColumnAtServer("Value", TypeDescription, "CollectionParameter");
	ElsIf P = "Structure" Then
		Items.TypeDescription.Visible=False;
		Items.AddColumn.Visible=False;
		TD= New TypeDescription("String", , New StringQualifiers(20, AllowedLength.Variable));
		AddColumnAtServer("Key", TD, "CollectionParameter");
		AddColumnAtServer("Value", TypeDescription, "CollectionParameter");
	ElsIf P = "Map" Then
		Items.TypeDescription.Visible=False;
		Items.AddColumn.Visible=False;
		AddColumnAtServer("Key", TypeDescription, "CollectionParameter");
		AddColumnAtServer("Value", TypeDescription, "CollectionParameter");
	Else
		Items.TypeDescription.Visible=True;
		Items.AddColumn.Visible=True;
		Items.DeleteColumn.Visible=True;
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If IsBlankString(Parameters.ParameterName) Then
		ThisForm.Title=NStr("ru = 'Новый параметр';en = 'New parameter'");
		FormItemsVisibilityManaging("Title", False);
	ElsIf Parameters.Rename Then
		
		ThisForm.Title=StrTemplate("%1 :%2",Parameters.ParameterName,NSTR("ru = 'Новое имя параметра';en = 'New parameter name'"));
		ParameterName=Parameters.ParameterName;
		FormItemsVisibilityManaging("Title");
	Else
		ParameterName=Parameters.ParameterName;
		ThisForm.Title=StrTemplate("%1 :%2",Parameters.ParameterName,NSTR("ru = 'Изменение параметра';en = 'Changing  parameter'"));;
		OnParameterChangeAction();
	EndIf;
EndProcedure

&AtServer
Procedure OnParameterChangeAction()
	Parameter=GetParameter(Parameters.ParameterName);
	M = New Map;
	M.Insert("Array", "Collection");
	M.Insert("Structure", "Collection");
	M.Insert("Map", "Collection");
	M.Insert("Table значений", "Collection");
	M.Insert("Binary data", "ExternalFile");
	M.Insert(Undefined, "AvailableTypes");
	ParameterType=M.Get(Parameters.ParameterType);
	If ParameterType = Undefined Then
		FormItemsVisibilityManaging("AvailableTypes");
		AvailableTypes=Parameter;
		Items.AvailableTypes.Title=Parameters.ParameterType;
		Items.AvailableTypes.ChooseType=False;
		Parameters.ParameterType="AvailableTypes";
	ElsIf ParameterType = "Collection" Then
		FormItemsVisibilityManaging("Collection");
		Items.TypeCollection.Visible=False;
		For Each CollectionItem In Items.CollectionParameter.ChildItems Do
			CollectionItem.Visible=True;
		EndDo;
		If Parameters.ParameterType = "Array" Then
			AddColumnAtServer("Value", TypeDescription, "CollectionParameter");
			Т=CollectionToValueTable(Parameter);
			CollectionParameter.Load(Т);
			TypeCollection="Array";
		ElsIf Parameters.ParameterType = "Structure" Then
			Items.TypeDescription.Visible=False;
			Items.AddColumn.Visible=False;
			TD= New TypeDescription("String", , New StringQualifiers(20, AllowedLength.Variable));
			AddColumnAtServer("Key", TD, "CollectionParameter");
			AddColumnAtServer("Value", TypeDescription, "CollectionParameter");
			Т=CollectionToValueTable(Parameter);
			CollectionParameter.Load(Т);
			TypeCollection="Structure";
		ElsIf Parameters.ParameterType = "Map" Then
			Items.TypeDescription.Visible=False;
			Items.AddColumn.Visible=False;
			AddColumnAtServer("Key", TypeDescription, "CollectionParameter");
			AddColumnAtServer("Value", TypeDescription, "CollectionParameter");
			Т=CollectionToValueTable(Parameter);
			CollectionParameter.Load(Т);
			TypeCollection="Map";
		Else
			Items.TypeDescription.Visible=True;
			Items.AddColumn.Visible=True;
			Items.DeleteColumn.Visible=True;
			For Each Column In Parameter.Columns Do
				AddColumnAtServer(Column.Name, Column.ValueType, "CollectionParameter");
			EndDo;
			CollectionParameter.Load(Parameter);
		EndIf;
	Else
		Parameters.ParameterType="ExternalFile";
		FormItemsVisibilityManaging("ExternalFile");
	EndIf;
EndProcedure

&AtServer
Function CollectionToValueTable(Collection)
	VT = New ValueTable;
	VT.Columns.Add("Value");
	If Not TypeOf(Collection) = Type("Array") Then
		VT.Columns.Add("Key");
		For Each ТекЭлем In Collection Do
			НС=VT.Add();
			FillPropertyValues(НС, ТекЭлем);
		EndDo;
	Else
		For I = 0 To Collection.UBound() Do
			VT.Add();
		EndDo;
		VT.LoadColumn(Collection, 0);
	EndIf;
	Return VT;
EndFunction

&AtServer
Procedure RenameParameter(Key, NewName)
	SelectedObject=FormAttributeToValue("Object");
	SelectedObject.RenameParameter(Key, NewName);
EndProcedure

/// Интерф

&AtClient
Procedure AddColumn(Command)
	ColumnName="";
	ShowInputValue(New NotifyDescription("AddColumnEnd", ThisForm, New Structure("ColumnName",
		ColumnName)), ColumnName, Nstr("ru = 'Введите имя новой колонки';en = 'Input name of new column'"), "String");
EndProcedure

&AtClient
Procedure AddColumnEnd(Value, AdditionalParameters) Export

	ColumnName = ?(Value = Undefined, AdditionalParameters.ColumnName, Value);
	If Not IsBlankString(ColumnName) Then
		AddColumnAtServer(TrimAll(ColumnName), TypeDescription, "CollectionParameter");
		TypeDescription="";
	Else
		Return;
	EndIf;

EndProcedure

&AtClient
Procedure DeleteColumn(Command)
	ColumnName=Items.CollectionParameter.CurrentItem.Name;
	If Items.CollectionParameter.CurrentItem <> Undefined Then
		ShowQueryBox(New NotifyDescription("DeleteColumnEnd", ThisForm, New Structure("ColumnName",
			ColumnName)),StrTemplate("%1 %2 ?",NStr("ru = 'Вы уверены , что хотите изменить удалить колонку ';en = 'Are you sure you want to change delete column'"),ColumnName) ,
			QuestionDialogMode.YesNo);
	Else
		ShowMessageBox(Undefined, NSTR("ru = 'Нужно выбрать колонку таблицы !';en = 'You need to select a table column !'"));
	EndIf;
EndProcedure

&AtClient
Procedure DeleteColumnEnd(QuestionResult, AdditionalParameters) Export

	ColumnName = AdditionalParameters.ColumnName;

	If QuestionResult = DialogReturnCode.Yes Then
		DeleteColumnAtServer(ColumnName, "CollectionParameter");
	EndIf
	;

EndProcedure

&AtServer
Procedure AddColumnAtServer(Val ColumnName, ColumnTypeDescription, FormTable)
	AddedAttributesArray = New Array;
	AddedAttributesArray.Add(
	New FormAttribute(ColumnName, ColumnTypeDescription, FormTable, ColumnName));
	ChangeAttributes(AddedAttributesArray);
	NewItem = Items.Add(ColumnName, Type("FormField"), Items[FormTable]);
	NewItem.Title=ColumnName;
	NewItem.Type = FormFieldType.TextBox;
	NewItem.DataPath = FormTable + "." + ColumnName;
EndProcedure

&AtServer
Procedure DeleteColumnAtServer(ColumnName, FormTable)
	Items.Delete(Items.Find(ColumnName));
	DeletedAttributesArray = New Array;
	DeletedAttributesArray.Add(FormTable + "." + ColumnName);
	ChangeAttributes( , DeletedAttributesArray);
EndProcedure

&AtClient
Procedure TypeCollectionOnChange(Item)
		CollectionVisibilityManaging(TypeCollection);
	Item.Visible=False;
EndProcedure

&AtServer
Procedure ChangeParameter()
	NewValue=GetNewValue();
	If Not NewValue = Undefined Then
		SelectedObject=FormAttributeToValue("Object");
		SelectedObject.ChangeParameter(New Structure("ParameterName,ParameterValue", ParameterName,
			NewValue));
	EndIf;
EndProcedure

&AtServer
Function GetNewValue()
	If Parameters.ParameterType = "AvailableTypes" Then
		Return AvailableTypes;
	ElsIf Parameters.ParameterType = "ExternalFile" Then
		Pos = StrFind(ExternalFile, ".", SearchDirection.FromEnd);
		Return "{" + ?(Pos > 0, Mid(ExternalFile, Pos + 1) + "}", "}") + StorageURL;
	ElsIf Parameters.ParameterType = "DefinedType" Then
		Try
			Result=Undefined;
			Execute (DefinedType);
			Return Result;
		Except
			Message(ErrorDescription());
			Return Undefined;
		EndTry;
	Else
		Table=FormAttributeToValue("CollectionParameter");
		If TypeCollection = "Array" Then
			Return Table.UnloadColumn(0);
		ElsIf TypeCollection = "Structure" Then
			S=New Structure;
			For Each Row In Table Do
				S.Insert(Row.Key, Row.Value);EndDo
			;
			Return S;
		ElsIf TypeCollection = "Map" Then
			S=New Map;
			For Each Row In Table Do
				S.Insert(Row.Key, Row.Value);EndDo
			;
			Return S;
		Else
			Return Table;
		EndIf;
	EndIf;
EndFunction

&AtServer
Function GetParameter(ParameterName)
	SelectedObject=FormAttributeToValue("Object");
	Return SelectedObject.GetParameter(ParameterName);
EndFunction // GetParameter()

&AtClient
Procedure SelectedTypeOnChange(Item)
	Parameters.ParameterType=SelectedType;
	FormItemsVisibilityManaging(SelectedType);
EndProcedure

&AtClient
Procedure ParameterNameOnChange(Item)
	If Not Parameters.Rename Then
		Parameters.ParameterName=TrimAll(ParameterName);
	EndIf;
EndProcedure

&AtClient
Procedure AvailableTypesOnChange(Item)
	Item.Title=TypeOf(AvailableTypes);
EndProcedure

&AtClient
Procedure DefinedTypeTextEditEnd(Item, Text, ChoiceData, DataGetParameters, StandardProcessing)
	Parameters.ParameterType="DefinedType";
EndProcedure
