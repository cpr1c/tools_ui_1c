&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Try
		Value = ValueFromStringInternal(Parameters.InterValue);
	Except
		Message(BriefErrorDescription(ErrorInfo()));
		Cancel = True;
		Return;
	EndTry;

	If TypeOf(Value) <> Type("ValueTable") Then
		Cancel = True;
		Return;
	EndIf;

	_RecordsCount = Value.Count();
	
	ValueStorageType = Type("ValueStorage");
	ValueTableType = Type("ValueTable");
	TypeType = Type("Type");
	PointInTimeType = Type("PointInTime");

	AttributesToAdding = New Array;
	AttributesToDeleting = New Array;

	For each Column In Value.Columns Do
		//If Not Column.ValueType.ContainsType(varValueTableType) Then
		//	AttributesToAdding.Add(New FormAttribute(Column.Name, Column.ValueType, "DataTable", Column.Title, False));
		//EndIf;

		If Column.ValueType.ContainsType(ValueStorageType) Then
			AttributeValueType = New TypeDescription;
		ElsIf Column.ValueType.ContainsType(ValueTableType) Then
			AttributeValueType = New TypeDescription;
		ElsIf Column.ValueType.ContainsType(TypeType) Then
			AttributeValueType = New TypeDescription;
		ElsIf Column.ValueType.ContainsType(PointInTimeType) Then
			AttributeValueType = New TypeDescription;
		Else
			AttributeValueType = Column.ValueType;
		EndIf;

		AttributesToAdding.Add(New FormAttribute(Column.Name, AttributeValueType, "DataTable",
			Column.Title, False));
	EndDo;

	ChangeAttributes(AttributesToAdding, AttributesToDeleting);
	ValueToFormAttribute(Value, "DataTable");

	For each Column In Value.Columns Do
		//If Not Column.ValueType.ContainsType(varValueTableType) Then
		ThisForm.Items.Add(Column.Name, Type("FormField"), ThisForm.Items.DataTable);
		ThisForm.Items[Column.Name].DataPath = "DataTable." + Column.Name;
		ThisForm.Items[Column.Name].Type = FormFieldType.InputField;
		ThisForm.Items[Column.Name].AvailableTypes = Column.ValueType;
		//EndIf;
	EndDo;

	If Not IsBlankString(Parameters.Title) Then
		ThisForm.Title = Parameters.Title;
	EndIf;
EndProcedure

&AtClient
Procedure CommandOK(Command)
	Result = New Structure;
	Result.Insert("ValueType", "ValueTable");
	Result.Insert("StringInternal", DataTableAsStringInternal());
	Close(Result);
EndProcedure

&AtClient
Procedure CommandClose(Command)
	Close();
EndProcedure

&AtClient
Procedure CommandClearTable(Command)
	DataTable.Clear();
EndProcedure

&AtServer
Function DataTableAsStringInternal()
	Return ValueToStringInternal(FormAttributeToValue("DataTable"));
EndFunction