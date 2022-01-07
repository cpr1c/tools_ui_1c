
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	CopyFormData(Parameters.Object, Object);
	
	DataProcessor = FormAttributeToValue("Object");
	
	Title = Parameters.Title + NStr("ru = ' (таблица значений)'; en = ' (value table)'");
	
	Table = DataProcessor.StringToValue(Parameters.Value.Value);
	
	DataProcessor.CreateTableAttributesByColumns(ThisForm, "ValueTable", "ValueTableColumnMap", "ValueTableContainerColumns", Table.Columns, True);

	DataProcessor.TableToFormAttribute(Table, ValueTable, ValueTableContainerColumns);
	
	fReadOnly = False;
	If Parameters.Property("ReadOnly", fReadOnly) And fReadOnly = True Then
		Items.ValueTable.ReadOnly = True;
		Items.OKCommand.Visible = False;
	EndIf;

	ContainerAttributeSuffix=DataProcessor.ContainerAttributeSuffix();
EndProcedure

&AtServer
Function GetReturnTable()
	DataProcessor = FormAttributeToValue("Object");
	vtReturnTable = DataProcessor.TableFromFormAttributes(ValueTable, ValueTableContainerColumns);
	Return DataProcessor.Container_SaveValue(vtReturnTable);
EndFunction

&AtServer
Procedure InitializeRowContainersByTypes(nRow, ValueTableContainerColumns)
	FormAttributeToValue("Object").InitializeRowContainersByTypes(ValueTable.FindByID(nRow), ValueTableContainerColumns);
EndProcedure

&AtClient
Function FormFullName(FormName)
	Return StrTemplate("%1.Form.%2", Object.MetadataPath, FormName);
EndFunction


//@skip-warning
&AtClient
Procedure TableFieldStartChoice(Item, ChoiceData, StandardProcessing)
	Var Container;
	
	ColumnName = ValueTableColumnMap[Item.Name];
	ContainerColumnName = ColumnName + ContainerAttributeSuffix;
	
	If ValueTableContainerColumns.Property(ColumnName) Then
		
		TableRow = ValueTable.FindByID(Items.ValueTable.CurrentRow);
		Container = TableRow[ContainerColumnName];
		
		If Not ValueIsFilled(Container) Then
			InitializeRowContainersByTypes(Items.ValueTable.CurrentRow, ValueTableContainerColumns);
			Container = TableRow[ContainerColumnName];
		EndIf;
		
		If ValueIsFilled(Container.Type) Then
			
			If Container.Type = "Type" Then
				StandardProcessing = False;
				NotifyParameters = New Structure("Table, Row, Field", "ValueTable", Items.ValueTable.CurrentRow, ColumnName);
				CloseFormNotifyDescription = New NotifyDescription("RowEditEnd", ThisForm, NotifyParameters);
				OpeningParameters = New Structure("Object, ValueType", Object, Container);
				OpenForm(FormFullName("EditType"), OpeningParameters, ThisForm, True, , , CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
			ElsIf Container.Type = "PointInTime" Then
				StandardProcessing = False;
				NotifyParameters = New Structure("Table, Row, Field", "ValueTable", Items.ValueTable.CurrentRow, ColumnName);
				CloseFormNotifyDescription = New NotifyDescription("RowEditEnd", ThisForm, NotifyParameters);
				OpeningParameters = New Structure("Object, Value", Object, Container);
				OpenForm(FormFullName("EditPointInTimeBoundary"), OpeningParameters, ThisForm, False, , , CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
			EndIf;
			
		EndIf;
		
	EndIf;
	
EndProcedure

&AtClient
Procedure RowEditEnd(Result, AdditionalParameters) Export
	
	If Result <> Undefined Then
		
		nRowID = AdditionalParameters.Row;
		Value = Undefined;
		If Result.Property("Value", Value) Then
			ValueTable[nRowID][AdditionalParameters.Field + ContainerAttributeSuffix] = Value;
			ValueTable[nRowID][AdditionalParameters.Field] = Value.Presentation;
		Else
			ValueTable[nRowID][AdditionalParameters.Field + ContainerAttributeSuffix] = Result.ContainerDescription;
			ValueTable[nRowID][AdditionalParameters.Field] = Result.ContainerDescription.Presentation;
		EndIf;
		
	EndIf;
	
EndProcedure

&AtClient
Procedure ClearCommand(Command)
	ValueTable.Clear();
EndProcedure

&AtClient
Procedure OKCommand(Command)
	ReturnValue = New Structure("Value", GetReturnTable());
	Close(ReturnValue);
EndProcedure



