&AtClient
Var mValueStorageType;

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ValueStorageData = Parameters.ValueStorageData;

	If TypeOf(ValueStorageData) = Type("String") Then
		If IsTempStorageURL(ValueStorageData) Then
			ValueStorageData = GetFromTempStorage(ValueStorageData);
		Else
			Try
				ValueStorageData=UT_CommonServerCall.ValueFromXMLString(ValueStorageData);
			Except
			EndTry;
		EndIf;
	EndIf;

	If TypeOf(ValueStorageData) = Type("SpreadsheetDocument") Then
		_DataForRepresentation = New Structure("Value, ValueType", ValueStorageData, "SpreadsheetDocument");
		Return;
	 ElsIf TypeOf(ValueStorageData) = Type("TextDocument") Then
		_DataForRepresentation = New Structure("Value, ValueType", ValueStorageData, "TextDocument");
		Return;
	 ElsIf TypeOf(ValueStorageData) <> Type("ValueStorage") Then
		Cancel = True;
		Return;
	EndIf;

	ValueStorageData = ValueStorageData.Get();
	If ValueStorageData = Undefined Then
		Cancel = True;
		Return;
	EndIf;

	ValueStorageDataType = TypeOf(ValueStorageData);

	If ValueStorageDataType = Type("Array") Then
		Title = "Array";
		Cancel = Not ShowArray(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("Structure") Then
		Title = "Structure";
		Cancel = Not ShowStructure(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("Map") Then
		Title = "Map";
		Cancel = Not ShowMap(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("ValueList") Then
		Title = "ValueList";
		Cancel = Not ShowValueList(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("ValueTable") Then
		Title = "ValueTable";
		Cancel = Not ShowValueTable(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("ValueTree") Then
		Title = "ValueTree";
		Items._ValueTable.Visible = False;
		Items._ValueTree.Visible = True;
		Cancel = Not ShowValueTree(ValueStorageData);
	 ElsIf ValueStorageDataType = Type("SpreadsheetDocument") Then
		_DataForRepresentation = New Structure("Value, ValueType", ValueStorageData, "SpreadsheetDocument");
	 ElsIf ValueStorageDataType = Type("TextDocument") Then
		_DataForRepresentation = New Structure("Value, ValueType", ValueStorageData, "TextDocument");
	Иначе
		Cancel = True;
	EndIf;
EndProcedure


&AtClient
Procedure OnOpen(Cancel)
	mValueStorageType = Type("ValueStorage");

	If _DataForRepresentation <> Undefined Then
		If _DataForRepresentation.ValueType = "SpreadsheetDocument" Then
			_DataForRepresentation.Value.Show(_DataForRepresentation.ValueType);
		 ElsIf _DataForRepresentation.ValueType = "TextDocument" Then
			_DataForRepresentation.Value.Show(_DataForRepresentation.ValueType);
		EndIf;

		Cancel = True;
	EndIf;
	
EndProcedure

&AtServer
Function ShowArray(ValueStorageData)
	If ValueStorageData.Count() = 0 Then
		Return False;
	EndIf;

	AttributesToAdding = New Array;
	AttributesToDeleting = New Array;

	AttributesToAdding.Add(New FormAttribute("Index", New TypeDescription("Number"), "_ValueTable",
		"Index", False));
	AttributesToAdding.Add(New FormAttribute("Value", New TypeDescription, "_ValueTable", "Value",
		False));
	AttributesToAdding.Add(New FormAttribute("ValueType", New TypeDescription("String"), "_ValueTable",
		"ValueType", False));

	ChangeAttributes(AttributesToAdding, AttributesToDeleting);

	For Index = 0 По ValueStorageData.UBound() Do
		Value = ValueStorageData[Index];
		NewRow = _ValueTable.Add();

		NewRow.Index = Index;
		NewRow.ValueType = String(TypeOf(Value));

		If NeedToConvertValue(Value) Then
			NewRow.Value = New ValueStorage(Value);
		Иначе
			NewRow.Value = Value;
		EndIf;
	EndDo;

	For Each Item In AttributesToAdding Do
		FormItemName = "_ValueTable_" + Item.Name;
		ThisForm.Items.Add(FormItemName, Type("FormField"), ThisForm.Items._ValueTable);
		ThisForm.Items[FormItemName].DataPath = "_ValueTable." + Item.Name;
		ThisForm.Items[FormItemName].Type = FormFieldType.InputField;
	EndDo;

	Return True;
EndFunction

&AtServer
Function ShowStructure(ValueStorageData)
	If ValueStorageData.Count() = 0 Then
		Return False;
	EndIf;

	AttributesToAdding = New Array;
	AttributesToDeleting = New Array;

	AttributesToAdding.Add(New FormAttribute("Key", New TypeDescription("String"), "_ValueTable",
		"Key", False));
	AttributesToAdding.Add(New FormAttribute("Value", New TypeDescription, "_ValueTable", "Value",
		False));
	AttributesToAdding.Add(New FormAttribute("ValueType", New TypeDescription("String"), "_ValueTable",
		"ValueType", False));

	ChangeAttributes(AttributesToAdding, AttributesToDeleting);

	For Each Item In ValueStorageData Do
		NewRow = _ValueTable.Add();

		FillPropertyValues(NewRow, Item, , "Value");
		NewRow.ValueType = String(TypeOf(Item.Value));

		If NeedToConvertValue(Item.Value) Then
			NewRow.Value = New ValueStorage(Item.Value);
		Else
			NewRow.Value = Item.Value;
		EndIf;
	EndDo;

	For Each Item In AttributesToAdding Do
		FormItemName = "_ValueTable_" + Item.Name;
		ThisForm.Items.Add(FormItemName, Type("FormField"), ThisForm.Items._ValueTable);
		ThisForm.Items[FormItemName].DataPath = "_ValueTable." + Item.Name;
		ThisForm.Items[FormItemName].Type = FormFieldType.FormFieldType;
	EndDo;

	Return True;
EndFunction

&AtServer
Function ShowMap(ValueStorageData)
	If ValueStorageData.Count() = 0 Then
		Return False;
	EndIf;

	AttributesToAdding = New Array;
	AttributesToDeleting = New Array;

	AttributesToAdding.Add(New FormAttribute("Key", New TypeDescription, "_ValueTable", "Key", False));
	AttributesToAdding.Add(New FormAttribute("Value", New TypeDescription, "_ValueTable", "Value",
		False));
	AttributesToAdding.Add(New FormAttribute("ValueType", New TypeDescription("String"), "_ValueTable",
		"ValueType", False));

	ChangeAttributes(AttributesToAdding, AttributesToDeleting);

	For Each Item In ValueStorageData Do
		NewRow = _ValueTable.Add();

		FillPropertyValues(NewRow, Item, , "Value");
		NewRow.ValueType = String(TypeOf(Item.Value));

		If NeedToConvertValue(Item.Value) Then
			NewRow.Value = New ValueStorage(Item.Value);
		Иначе
			NewRow.Value = Item.Value;
		EndIf;
	EndDo;

	For Each Item In AttributesToAdding Do
		FormItemName = "_ValueTable_" + Item.Name;
		ThisForm.Items.Add(FormItemName, Type("FormField"), ThisForm.Items._ValueTable);
		ThisForm.Items[FormItemName].DataPath = "_ValueTable." + Item.Name;
		ThisForm.Items[FormItemName].Type = FormFieldType.InputField;
	EndDo;

	Return True;
EndFunction

&AtServer
Function ShowValueList(ValueStorageData)
	If ValueStorageData.Count() = 0 Then
		Return False;
	EndIf;

	AttributesToAdding = New Array;
	AttributesToDeleting = New Array;

	AttributesToAdding.Add(New FormAttribute("Check", New TypeDescription("Boolean"), "_ValueTable",
		"Check", False));
	AttributesToAdding.Add(New FormAttribute("Presentation", New TypeDescription("String"),
		"_ValueTable", "Presentation", False));
	AttributesToAdding.Add(New FormAttribute("Value", New TypeDescription, "_ValueTable", "Value",
		False));
	AttributesToAdding.Add(New FormAttribute("ValueType", New TypeDescription("String"), "_ValueTable",
		"ValueType", False));

	ChangeAttributes(AttributesToAdding, AttributesToDeleting);

	For Each Item In ValueStorageData Do
		NewRow = _ValueTable.Add();

		FillPropertyValues(NewRow, Item, , "Value");
		NewRow.ValueType = String(TypeOf(Item.Value));

		If NeedToConvertValue(Item.Value) Then
			NewRow.Value = New ValueStorage(Item.Value);
		Иначе
			NewRow.Value = Item.Value;
		EndIf;
	EndDo;

	For Each Item In AttributesToAdding Do
		FormItemName = "_ValueTable_" + Item.Name;
		ThisForm.Items.Add(FormItemName, Type("FormField"), ThisForm.Items._ValueTable);
		ThisForm.Items[FormItemName].DataPath = "_ValueTable." + Item.Name;
		ThisForm.Items[FormItemName].Type = FormFieldType.InputField;
	EndDo;

	Return True;
EndFunction

&AtServer
Function ShowValueTable(ValueStorageData)
	AttributesToAdding = New Array;
	AttributesToDeleting = New Array;

	For Each Column In ValueStorageData.Columns Do
		AttributesToAdding.Add(New FormAttribute(Column.Name, New TypeDescription, "_ValueTable",
			Column.Title, False));
	EndDo;

	ChangeAttributes(AttributesToAdding, AttributesToDeleting);

	For Each Item In ValueStorageData Do
		NewRow = _ValueTable.Add();

		For Each Column In ValueStorageData.Columns Do
			Value = Item[Column.Name];

			If NeedToConvertValue(Value) Then
				Value = New ValueStorage(Value);
			EndIf;
			NewRow[Column.Name] = Value;
		EndDo;
	EndDo;

	For Each Item In AttributesToAdding Do
		FormItemName = "_ValueTable_" + Item.Name;
		ThisForm.Items.Add(FormItemName, Type("FormField"), ThisForm.Items._ValueTable);
		ThisForm.Items[FormItemName].DataPath = "_ValueTable." + Item.Name;
		ThisForm.Items[FormItemName].Type = FormFieldType.InputField;
	EndDo;

	Return True;
EndFunction

&AtServer
Function ShowValueTree(ValueStorageData)
	AttributesToAdding = New Array;
	AttributesToDeleting = New Array;

	For Each Column In ValueStorageData.Columns Do
		AttributesToAdding.Add(New FormAttribute(Column.Name, New TypeDescription, "_ValueTree",
			Column.Title, False));
	EndDo;

	ChangeAttributes(AttributesToAdding, AttributesToDeleting);

	FillValueTreeNode(_ValueTree, ValueStorageData, ValueStorageData.Columns);

	For Each Item In AttributesToAdding Do
		FormItemName = "_ValueTree_" + Item.Name;
		ThisForm.Items.Add(FormItemName, Type("FormField"), ThisForm.Items._ValueTree);
		ThisForm.Items[FormItemName].DataPath = "_ValueTree." + Item.Name;
		ThisForm.Items[FormItemName].Type = FormFieldType.InputField;
	EndDo;

	Return True;
EndFunction

&AtClient
Procedure _ValueTreeSelection(Item, RowSelected, Field, StandardProcessing)
	
	StandardProcessing = False;

	CurrentData = Item.CurrentData;
	If CurrentData <> Undefined Then
		ColumnName = Mid(Field.Name, StrLen(Item.Name) + 2);
		Value = CurrentData[ColumnName];

		If TypeOf(Value) = mValueStorageType Then
			ShowValueOfValueStorage(Value);
		Иначе
			ShowValue( , Value);
		EndIf;
	EndIf;
	
EndProcedure

&AtServer
Function FillValueTreeNode (Val Receiver, Val Source, Val ColumnCollection)
	For Each Item In Source.Rows Do
		NewRow = Receiver.GetItems().Add();

		For Each Column In ColumnCollection Do
			Value = Item[Column.Name];

			If NeedToConvertValue(Value) Then
				Value = New ValueStorage(Value);
			EndIf;
			NewRow[Column.Name] = Value;
		EndDo;

		FillValueTreeNode(NewRow, Item, ColumnCollection);
	EndDo;

	Return True;
EndFunction

&AtClient
Procedure OpenObject(Command)
	Value = Undefined;

	Name = GetCurrentItemDatapath();
	If Not ValueIsFilled(Name) Then
		Return;
	EndIf;

	FormItem = ThisForm.CurrentItem;
	If TypeOf(FormItem) = Type("FormField") Then
		Value = ThisForm[Name];
	 ElsIf TypeOf(FormItem) = Type("FormTable") Then
		CurrentData = FormItem.CurrentData;
		If CurrentData <> Undefined Then
			Value = CurrentData[Name];
		EndIf;
	EndIf;

	If ValueIsFilled(Value) Then
		If TypeOf(Value) = mValueStorageType Then
			ShowValueOfValueStorage(Value);

		 ElsIf IsMetadataObJect(TypeOf(Value)) Then
			ParametersStructure = New Structure("mObjectRef", Value);
			OpenForm("DataProcessor.UT_ObjectsAttributesEditor.Form.ObjectForm", ParametersStructure, , Value);

		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure ShowValueOfValueStorage(Value)
	ParametersStructure = New Structure("ValueStorageData", Value);
	OpenForm("CommonForm.UT_ValueStorageForm", ParametersStructure, , CurrentDate());
EndProcedure


&AtClient
Procedure _ValueTableSelection(Item, RowSelected, Field, StandardProcessing)

	StandardProcessing = False;

	CurrentData = Item.CurrentData;
	If CurrentData <> Undefined Then
		ColumnName = Mid(Field.Name, StrLen(Item.Name) + 2);
		Value = CurrentData[ColumnName];

		If TypeOf(Value) = mValueStorageType Then
			ShowValueOfValueStorage(Value);
		Иначе
			ShowValue( , Value);
		EndIf;
	EndIf;
EndProcedure

&AtServer
Function GetCurrentItemDatapath()
	FormItem = ThisForm.CurrentItem;
	If TypeOf(FormItem) = Type("FormTable") Then
		CurrentField = FormItem.CurrentItem;
		If TypeOf(CurrentField) = Type("FormField") Then
			Value = CurrentField.DataPath;
			Position = Find(Value, ".");
			If Position <> 0 Then
				Value = Mid(Value, Position + 1);
				If Find(Value, ".") = 0 Then
					Return Value;
				EndIf;
			EndIf;
		EndIf;
	 ElsIf TypeOf(FormItem) = Type("FormField") Then
		Return FormItem.DataPath;
	EndIf;

	Return "";
EndFunction

&AtServerNoContext
Function IsMetadataObJect(Val Type)
	ObjectOfMetadata = Metadata.FindByType(Type);
	Return (ObjectOfMetadata <> Undefined And Not Metadata.Enums.Contains(ObjectOfMetadata));
EndFunction

&AtServerNoContext
Function IsSimpleType(Val Type)
	Result = Type = Type("Number") Or Type = Type("String") Or Type = Type("Boolean") Or Type = Type("Date");

	Return Result;
EndFunction

&AtServerNoContext
Function NeedToConvertValue(Знач Value)
	If Value = Undefined Or Value = Null Then
		Return False;
	EndIf;

	ValueType = TypeOf(Value);

	If IsSimpleType(ValueType) Then
		Return False;
	EndIf;

	If IsMetadataObJect(ValueType) Then
		Return False;
	EndIf;

	Return (ValueType <> Type("ValueStorage"));
EndFunction