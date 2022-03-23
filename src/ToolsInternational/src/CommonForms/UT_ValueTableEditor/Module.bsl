#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If ValueIsFilled(Parameters.ValueTableAsString) Then
		Try
			VT=ValueFromStringInternal(Parameters.ValueTableAsString);
		Except
			VT=New ValueTable;
		EndTry;
	Else
		VT=New ValueTable;
	EndIf;

	FillValueTableColumns(VT);
	CreateFormValueTableColumns();
	FillFormValueTableByTable(VT);
EndProcedure

#EndRegion

#Region FormItemsEvents

&AtClient
Procedure TableColumnsBeforeEditEnd(Item, NewRow, CancelEdit, Cancel)
	ProcessColumnNameChange(NewRow, CancelEdit, Cancel);
	
EndProcedure

&AtClient
Procedure TableColumnsValueTypeStartChoice(Item, ChoiceData, StandardProcessing)
	
		CurrentData=Items.TableColumns.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	CurrentRow=Items.TableColumns.CurrentLine;

	UT_CommonClient.EditType(CurrentData.ValueType, 1, StandardProcessing, ThisObject,
		New NotifyDescription("TableColumnsValueTypeStartChoiceEND", ThisObject,
		New Structure("CurrentRow", CurrentRow)));
	
EndProcedure


&AtClient
Procedure TableColumnsAfterDeleteRow(Item)
	CreateFormValueTableColumns();
EndProcedure


&AtClient
Procedure TableColumnsOnEditEnd(Item, NewRow, CancelEdit)
	CreateFormValueTableColumns();
EndProcedure


#EndRegion

#Region CommandFormEventHandlers
&AtClient
Procedure Apply(Command)
	ResultStructure=ResultValueTableToString();
	
	Close(ResultStructure);	
EndProcedure
#EndRegion

#Region Private

&AtServer
Procedure FillValueTableColumns(VT)
	TableColumns.Clear();

	For Each Column In VT.Cols Do
		NewRow=TableColumns.Add();
		NewRow.Name=Column.Name;
		NewRow.ValueType=Column.ValueType;
	EndDo;
EndProcedure

&AtServer
Function GetNotDisplayedTypesAtClient()
	TypesArray = New Array;
	TypesArray.Add(Type("Type"));
	TypesArray.Add(Type("PointInTime"));
	TypesArray.Add(Type("Border"));
	TypesArray.Add(Type("ValueStorage"));
	TypesArray.Add(Type("QueryResult"));
	Return TypesArray;
EndFunction

&AtServer
Procedure CreateFormValueTableColumns()

	ArrayNotDisplayedTypes = GetNotDisplayedTypesAtClient();

	CurrentTableColumnsArray=GetAttributes("ValueTable");
	AlreadyCreatedColumns=New Map;

	For Each CurrentAttribute In CurrentTableColumnsArray Do
		AlreadyCreatedColumns.Insert(Lower(CurrentAttribute.Name), CurrentAttribute);
	EndDo;

	DeletedAttributesArray=New Array;
	AddedAttributesArray=New Array;
	ColumnsForTypesAdjust=New Array;
	For Each CurrentColumn In TableColumns Do
		AlreadyCreatedAttribute=AlreadyCreatedColumns[Lower(CurrentColumn.Name)];
		If AlreadyCreatedAttribute = Undefined Then
			AddedAttributesArray.Add(New FormAttribute(CurrentColumn.Name, CurrentColumn.ValueType,
				"ValueTable", , True));
		Else
			If CurrentColumn.ValueType <> AlreadyCreatedAttribute.ValueType Then
				ColumnsForTypesAdjust.Add(CurrentColumn);
			EndIf;
			AlreadyCreatedColumns.Delete(Lower(CurrentColumn.Name));
		EndIf;
	EndDo;

	For Each KeyValue In AlreadyCreatedColumns Do
		DeletedAttributesArray.Add(KeyValue.Key);
	EndDo;

	ChangeAttributes(AddedAttributesArray, DeletedAttributesArray);

	For Each ColumnForAdjust In ColumnsForTypesAdjust Do
		AdjustValueTableColumnType(ThisObject, ColumnForAdjust);
	EndDo;

	For Each CurrentColumn In TableColumns Do
		ItemDescription=UT_Forms.ItemAttributeNewDescription();
		ItemDescription.Insert("Name", CurrentColumn.Name);
		ItemDescription.Insert("DataPath", "ValueTable." + CurrentColumn.Name);
		ItemDescription.Insert("ItemParent", Items.ValueTable);
		UT_Forms.CreateItemByDescription(ThisObject, ItemDescription);
	EndDo;

EndProcedure

&AtServer
Procedure FillFormValueTableByTable(VT)
	ValueTable.Clear();

	For Each Row In VT Do
		NewRow=ValueTable.Add();
		FillPropertyValues(NewRow, Row);
	EndDo;
EndProcedure

&AtClient
Procedure ProcessColumnNameChange(NewRow, CancelEdit, Cancel)

	strColumnName = Items.TableColumns.CurrentData.Name;

	If Not UT_CommonClientServer.IsCorrectVariableName(strColumnName) Then
		ShowMessageBox( ,
			UT_CommonClientServer.WrongVariableNameWarningText(),
			, Title);
		Cancel = True;
		Return;
	EndIf;

	NameStringsArray = TableColumns.FindRows(New Structure("Name", strColumnName));
	If NameStringsArray.Count() > 1 Then
		ShowMessageBox( , NSTR("ru = 'Колонка с таким именем уже есть! Введите другое имя.';en = 'There is already a column with that name! Enter a different name.'"), , Title);
		Cancel = True;
		Return;
	EndIf;

EndProcedure
&AtClientAtServerNoContext
Function GetTypeModifiers(ValueType)

	QualifiersArray = New Array;

	If ValueType.ContainsType(Type("String")) Then
		strStringQualifiers = "Length " + ValueType.StringQualifiers.Length;
		QualifiersArray.Add(New Structure("Type, Qualifiers", "String", strStringQualifiers));
	EndIf;

	If ValueType.ContainsType(Type("Date")) Then
		strDateQualifiers = ValueType.DateQualifiers.DateFractions;
		QualifiersArray.Add(New Structure("Type, Qualifiers", "Date", strDateQualifiers));
	EndIf;

	If ValueType.ContainsType(Type("Number")) Then
		strDateQualifiers = "Sign " + ValueType.NumberQualifiers.AllowedSign + " "
			+ ValueType.NumberQualifiers.Digits + "." + ValueType.NumberQualifiers.FractionDigits;
		QualifiersArray.Add(New Structure("Type, Qualifiers", "Number", strDateQualifiers));
	EndIf;

	fNeedTitle = QualifiersArray.Count() > 1;

	strQualifiers = "";
	For Each stQualifiers In QualifiersArray Do
		strQualifiers = ?(fNeedTitle, stQualifiers.Type + ": ", "") + stQualifiers.Qualifiers + "; ";
	EndDo;

	Return strQualifiers;

EndFunction

&AtClient
Procedure TableColumnsValueTypeStartChoiceEND(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	CurrentData=TableColumns.FindByID(AdditionalParameters.CurrentRow);
	CurrentData.ValueType=Result;
	CurrentData.Qualifiers=GetTypeModifiers(CurrentData.ValueType);

	AdjustValueTableColumnType(ThisObject, CurrentData);
EndProcedure

&AtClientAtServerNoContext
Procedure AdjustValueTableColumnType(Form, ColumnForAdjust)
	For каждого Row In Form.ValueTable Do
		Row[ColumnForAdjust.Name]=ColumnForAdjust.ValueType.AdjustValue(Row[ColumnForAdjust.Name]);
	EndDo;
EndProcedure

&AtServer
Function ResultValueTableToString()
	VT=FormAttributeToValue("ValueTable");
	
	ResultStructure=New Structure;
	ResultStructure.Insert("Value", ValueToStringInternal(VT));
	ResultStructure.Insert("Presentation", StrTemplate(NSTR("ru = 'Строк: %1 Колонок: %2';en = 'Rows: %1 Columns: %2'"), VT.Count(), VT.Cols.Count()));
	ResultStructure.Insert("LineCount", VT.Count());
	ResultStructure.Insert("ColumnsCount", VT.Cols.Count());
	Return ResultStructure;
EndFunction

#EndRegion