
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	CopyFormData(Parameters.Object, Object);
	
	ItemListReceived = FormAttributeToValue("Object").Container_RestoreValue(Parameters.Value);
	ContainerType = Parameters.ContainerType;
	
	If ContainerType = 2 Then
		Title = Parameters.Title + NStr("ru = ' (массив)'; en = ' (array)'");
		ItemList.LoadValues(ItemListReceived);
	Else
		Title = Parameters.Title + NStr("ru = ' (список значений)'; en = ' (value list)'");
		ItemList = ItemListReceived;
	EndIf;
	
	ItemList.ValueType = Parameters.ValueType;
	
	arNoPickupTypes = New Array;
	arNoPickupTypes.Add(Type("Number"));
	arNoPickupTypes.Add(Type("String"));
	arNoPickupTypes.Add(Type("Date"));
	arNoPickupTypes.Add(Type("Undefined"));
	arNoPickupTypes.Add(Type("Type"));
	arNoPickupTypes.Add(Type("AccumulationRecordType"));
	arNoPickupTypes.Add(Type("AccountingRecordType"));
	arNoPickupTypes.Add(Type("AccountType"));
	arNoPickupTypes.Add(Type("UUID"));
	arNoPickupTypes.Add(Type("NULL"));
	NoPickupTypes = New TypeDescription(arNoPickupTypes);
	
	arTypes = Parameters.ValueType.Types();
	Items.ItemListPickup.Visible = True;
	For Each Type In arTypes Do
		If NoPickupTypes.ContainsType(Type) Then
			Items.ItemListPickup.Visible = False;
			Break;
		EndIf;
	EndDo;
	
EndProcedure

&AtClient
Function FullFormName(FormName)
	Return StrTemplate("%1.Form.%2", Object.MetadataPath, FormName);
EndFunction

&AtServer
Function GetReturnValue()
	
	If ContainerType = 2 Then
		Return FormAttributeToValue("Object").Container_SaveValue(ItemList.UnloadValues());
	EndIf;
	
	Return FormAttributeToValue("Object").Container_SaveValue(ItemList);
	
EndFunction

&AtClient
Procedure OKCommand(Command)

	ReturnValue = New Structure("Value", GetReturnValue());
	
	Close(ReturnValue);
	
EndProcedure

&AtClient
Procedure ClearCommand(Command)
	ItemList.Clear();
EndProcedure

&AtClient
Procedure EditValue()
	
	Value = Items.ItemList.CurrentData.Value;
	If TypeOf(Value) = Type("Type") Then

		NotifyParameters = New Structure("Row", Items.ItemList.CurrentRow);
		//@skip-warning
		CloseFormNotifyDescription = New NotifyDescription("TypeEditFinish", ThisForm, NotifyParameters);
		
		If TypeOf(Value) <> Type("Type") Then
			Value = Type("Undefined");
		EndIf;
		
		OpeningParameters = New Structure("Object, ValueType", Object, Value);
		OpenForm(FullFormName("TypeEdit"), OpeningParameters, ThisForm, True, , , CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
		
	ElsIf TypeOf(Value) = Type("UUID") Then

		NotifyParameters = New Structure("Row", Items.ItemList.CurrentRow);
		//@skip-warning
		CloseFormNotifyDescription = New NotifyDescription("TypeEditFinish", ThisForm, NotifyParameters);
		
		OpeningParameters = New Structure("Object, Value", Object, Value);
		OpenForm(FullFormName("UUIDEdit"), OpeningParameters, ThisForm, True, , , CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
		
	EndIf;
	
EndProcedure

&AtClient
Procedure ItemListValueStartChoice(Item, ChoiceData, StandardProcessing)
	
	Value = Items.ItemList.CurretData.Value;
	
	EditingValueType = TypeOf(Value);
	
	If EditingValueType = Type("Type") Or EditingValueType = Type("UUID") Then
		EditValue();
		StandardProcessing = False;
	EndIf;
	
EndProcedure

&AtClient
Procedure ItemListValueChoiceProcessing(Item, ValueSelected, StandardProcessing)
	
	If ValueSelected = Type("Type") Then
		ItemList.FindByID(Items.ItemList.CurrentRow).Value = Type("Undefined");
		EditValue();
	ElsIf ValueSelected = Type("UUID") Then
		ItemList.FindByID(Items.ItemList.CurrentRow).Value = New UUID;
		EditValue();
	EndIf;
	
EndProcedure

Procedure TypeEditFinish(Result, NotifyParameters) Export
	Var Value;
	
	If Result <> Undefined Then
		
		If Result.Property("Value", Value) Then
			
			ItemList.FindByID(NotifyParameters.Row).Value = Value;
			
		Else
		
			ItemList.FindByID(NotifyParameters.Row).Value = Type(Result.ContainerDescription.TypeName);
			
		EndIf;
		
	EndIf;
	
EndProcedure

