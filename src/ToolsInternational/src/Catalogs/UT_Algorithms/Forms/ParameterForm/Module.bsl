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
		ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
	ElsIf P = "Structure" Then
		Items.TypeDescription.Visible=False;
		Items.AddColumn.Visible=False;
		ОТ= New TypeDescription("String", , New StringQualifiers(20, AllowedLength.Variable));
		ДобавитьКолонкуНС("Key", ОТ, "CollectionParameter");
		ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
	ElsIf P = "Map" Then
		Items.TypeDescription.Visible=False;
		Items.AddColumn.Visible=False;
		ДобавитьКолонкуНС("Key", TypeDescription, "CollectionParameter");
		ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
	Else
		Items.TypeDescription.Visible=True;
		Items.AddColumn.Visible=True;
		Items.DeleteColumn.Visible=True;
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If IsBlankString(Parameters.ParameterName) Then
		ThisForm.Title="New параметр";
		FormItemsVisibilityManaging("Title", False);
	ElsIf Parameters.Rename Then
		ThisForm.Title=Parameters.ParameterName + ":New имя параметра";
		ParameterName=Parameters.ParameterName;
		FormItemsVisibilityManaging("Title");
	Else
		ParameterName=Parameters.ParameterName;
		ThisForm.Title=Parameters.ParameterName + ":Update параметра";
		ДействияПриИзменениеПараметра();
	EndIf;
EndProcedure

&AtServer
Procedure ДействияПриИзменениеПараметра()
	Parameter=GetParameter(Parameters.ParameterName);
	C = New Map;
	C.Insert("Array", "Коллекция");
	C.Insert("Structure", "Коллекция");
	C.Insert("Map", "Коллекция");
	C.Insert("Table значений", "Коллекция");
	C.Insert("Двоичные данные", "ExternalFile");
	C.Insert(Undefined, "AvailableTypes");
	ParameterType=C.Get(Parameters.ParameterType);
	If ParameterType = Undefined Then
		FormItemsVisibilityManaging("AvailableTypes");
		AvailableTypes=Parameter;
		Items.AvailableTypes.Title=Parameters.ParameterType;
		Items.AvailableTypes.ChooseType=False;
		Parameters.ParameterType="AvailableTypes";
	ElsIf ParameterType = "Коллекция" Then
		FormItemsVisibilityManaging("Коллекция");
		Items.TypeCollection.Visible=False;
		For Each ЭлементКоллекции In Items.CollectionParameter.ChildItems Do
			ЭлементКоллекции.Visible=True;
		EndDo;
		If Parameters.ParameterType = "Array" Then
			ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
			Т=КоллекцияВТЗ(Parameter);
			CollectionParameter.Load(Т);
			TypeCollection="Array";
		ElsIf Parameters.ParameterType = "Structure" Then
			Items.TypeDescription.Visible=False;
			Items.AddColumn.Visible=False;
			ОТ= New TypeDescription("String", , New StringQualifiers(20, AllowedLength.Variable));
			ДобавитьКолонкуНС("Key", ОТ, "CollectionParameter");
			ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
			Т=КоллекцияВТЗ(Parameter);
			CollectionParameter.Load(Т);
			TypeCollection="Structure";
		ElsIf Parameters.ParameterType = "Map" Then
			Items.TypeDescription.Visible=False;
			Items.AddColumn.Visible=False;
			ДобавитьКолонкуНС("Key", TypeDescription, "CollectionParameter");
			ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
			Т=КоллекцияВТЗ(Parameter);
			CollectionParameter.Load(Т);
			TypeCollection="Map";
		Else
			Items.TypeDescription.Visible=True;
			Items.AddColumn.Visible=True;
			Items.DeleteColumn.Visible=True;
			For Each Column In Parameter.Cols Do
				ДобавитьКолонкуНС(Column.Name, Column.ValueType, "CollectionParameter");
			EndDo;
			CollectionParameter.Load(Parameter);
		EndIf;
	Else
		Parameters.ParameterType="ExternalFile";
		FormItemsVisibilityManaging("ExternalFile");
	EndIf;
EndProcedure

&AtServer
Function КоллекцияВТЗ(Коллекция)
	ТЗ = New ValueTable;
	ТЗ.Cols.Add("Value");
	If Not TypeOf(Коллекция) = Type("Array") Then
		ТЗ.Cols.Add("Key");
		For Each ТекЭлем In Коллекция Do
			НС=ТЗ.Add();
			FillPropertyValues(НС, ТекЭлем);
		EndDo;
	Else
		For I = 0 To Коллекция.UBound() Do
			ТЗ.Add();
		EndDo;
		ТЗ.LoadColumn(Коллекция, 0);
	EndIf;
	Return ТЗ;
EndFunction

&AtServer
Procedure RenameParameter(Key, НовоеИмя)
	SelectedObject=FormAttributeToValue("Object");
	SelectedObject.RenameParameter(Key, НовоеИмя);
EndProcedure

/// Интерф

&AtClient
Procedure AddColumn(Command)
	ColumnName="";
	ShowInputValue(New NotifyDescription("ДобавитьКолонкуЗавершение", ThisForm, New Structure("ColumnName",
		ColumnName)), ColumnName, "Введите имя новой колонки", "String");
EndProcedure

&AtClient
Procedure ДобавитьКолонкуЗавершение(Value, AdditionalParameters) Export

	ColumnName = ?(Value = Undefined, AdditionalParameters.ColumnName, Value);
	If Not IsBlankString(ColumnName) Then
		ДобавитьКолонкуНС(TrimAll(ColumnName), TypeDescription, "CollectionParameter");
		TypeDescription="";
	Else
		Return;
	EndIf;

EndProcedure

&AtClient
Procedure DeleteColumn(Command)
	ColumnName=Items.CollectionParameter.CurrentItem.Name;
	If Items.CollectionParameter.CurrentItem <> Undefined Then
		ShowQueryBox(New NotifyDescription("УдалитьКолонкуЗавершение", ThisForm, New Structure("ColumnName",
			ColumnName)), "Вы уверены что хотите изменить удалить колонку  """ + ColumnName + """ ?",
			QuestionDialogMode.YesNo);
	Else
		ShowMessageBox(Undefined, "Нужно выбрать колонку таблицы !");
	EndIf;
EndProcedure

&AtClient
Procedure УдалитьКолонкуЗавершение(РезультатВопроса, AdditionalParameters) Export

	ColumnName = AdditionalParameters.ColumnName;

	If РезультатВопроса = DialogReturnCode.Yes Then
		УдалитьКолонкуНС(ColumnName, "CollectionParameter");
	EndIf
	;

EndProcedure

&AtServer
Procedure ДобавитьКолонкуНС(Val ColumnName, ColumnTypeDescription, FormTable)
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
Procedure УдалитьКолонкуНС(ColumnName, FormTable)
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
			С=New Structure;
			For Each Стр In Table Do
				С.Insert(Стр.Key, Стр.Value);EndDo
			;
			Return С;
		ElsIf TypeCollection = "Map" Then
			С=New Map;
			For Each Стр In Table Do
				С.Insert(Стр.Key, Стр.Value);EndDo
			;
			Return С;
		Else
			Return Table;
		EndIf;
	EndIf;
EndFunction

&AtServer
Function GetParameter(НаименованиеПараметра)
	SelectedObject=FormAttributeToValue("Object");
	Return SelectedObject.GetParameter(НаименованиеПараметра);
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
