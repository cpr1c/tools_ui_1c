////////////////////////////////////////////////////////////////////////////////////////////////////
// EVENT HANDLERS
//

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	VerifyAccessRights("Administration", Metadata);

	If Parameters.Property("AutoTests") Then // Return when a form is received for analysis.
		Return;
	EndIf;

	DataTableName = Parameters.TableName;
	CurrentObject = ThisObject();
	TableHeader  = "";
	
	// Determining what kind of table is passed to the procedure.
	Details = CurrentObject.MetadataCharacteristics(DataTableName);
	MetaInfo = Details.Metadata;
	Title = MetaInfo.Presentation();
	
	// List and columns
	DataStructure = "";
	If Details.IsReference Then
		TableHeader = MetaInfo.ObjectPresentation;
		If IsBlankString(TableHeader) Then
			TableHeader = Title;
		EndIf;
		
		DataList.CustomQuery = False;
		DataList.MainTable = DataTableName;

		Field = DataList.Filter.FilterAvailableFields.Items.Find(New DataCompositionField("Ref"));
		ColumnsTable = New ValueTable;
		Columns = ColumnsTable.Columns;
		Columns.Add("Ref", Field.ValueType, TableHeader);
		DataStructure = "Ref";
		
		DataFormKey = "Ref";

	ElsIf Details.IsSet Then
		Columns = CurrentObject.RecordSetDimensions(MetaInfo);
		For Each CurrentColumnItem In Columns Do
			DataStructure = DataStructure + "," + CurrentColumnItem.Name;
		EndDo;
		DataStructure = Mid(DataStructure, 2);
		
		DataList.CustomQuery = True;
		DataList.QueryText = "SELECT DISTINCT " + DataStructure + " FROM " + DataTableName;

		If Details.IsSequence Then
			DataFormKey = "Recorder";
		Else
			DataFormKey = New Structure(DataStructure);
		EndIf;

	Else
		// No columns
		Return;
	EndIf;
	DataList.DynamicDataRead = True;

	CurrentObject.AddColumnsToFormTable(
		Items.DataList, 
		"Order, Filter, Group, StandardPicture, Parameters, ConditionalAppearance",
		Columns);
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// FORM HEADER ITEMS EVENT HANDLERS
//

&AtClient
Procedure FilterOnChange(Item)
	Items.DataList.Refresh();
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// DataList FORM TABLE ITEMS EVENT HANDLERS
//

&AtClient
Procedure DataListSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;
	OpenCurrentObjectForm();
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// FORM COMMAND HANDLERS
//

&AtClient
Procedure OpenCurrentObject(Command)
	OpenCurrentObjectForm();
EndProcedure

&AtClient
Procedure SelectFilteredValues(Command)
	MakeChoice(True);
EndProcedure

&AtClient
Procedure SelectCurrentRow(Command)
	MakeChoice(False);
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// PRIVATE
//

&AtClient
Procedure OpenCurrentObjectForm()
	CurParameters = CurrentObjectFormParameters(Items.DataList.CurrentData);
	If CurParameters <> Undefined Then
		OpenForm(CurParameters.FormName, CurParameters.Key);
	EndIf;
EndProcedure

&AtClient
Procedure MakeChoice(WholeFilterResult = True)
	
	If WholeFilterResult Then
		Data = AllSelectedItems();
	Else
		Data = New Array;
		For Each curRow In Items.DataList.SelectedRows Do
			Item = New Structure(DataStructure);
			FillPropertyValues(Item, Items.DataList.RowData(curRow));
			Data.Add(Item);
		EndDo;
	EndIf;

	NotifyChoice(New Structure("TableName, ChoiceData, ChoiceAction, FieldStructure", Parameters.TableName,
		Data, Parameters.ChoiceAction, DataStructure));
EndProcedure

&AtServer
Function ThisObject(CurrentObject = Undefined) 
	If CurrentObject = Undefined Then
		Return FormAttributeToValue("Object");
	EndIf;
	ValueToFormAttribute(CurrentObject, "Object");
	Return Undefined;
EndFunction

&AtServer
Function CurrentObjectFormParameters(Val Data)
	
	If Data = Undefined Then
		Return Undefined;
	EndIf;
	
	If TypeOf(DataFormKey) = Type("String") Then
		Value = Data[DataFormKey];
		CurFormName = ThisObject().GetFormName(Value) + ".ObjectForm";
	Else
		// The structure contains dimension names.
		CurFormName = "";
		FillPropertyValues(DataFormKey, Data);
		CurParameters = New Array;
		CurParameters.Add(DataFormKey);
		Try
			Value = New (StrReplace(Parameters.TableName, ".", "RecordKey."), CurParameters);
			CurFormName = Parameters.TableName + ".RecordForm";
		Except
			// no processing
		EndTry;

		If IsBlankString(CurFormName) Then
			// Record set without keys, for example turnovers accumulation register
			If Data.Property("Recorder") Then
				Value = Data.Recorder;
			Else
				For Each KeyValue In DataFormKey Do
					Value = Data[KeyValue.Key];
					Break;
				EndDo;
			EndIf;
			CurFormName = ThisObject().GetFormName(Value) + ".ObjectForm";
		Endif;
	EndIf;

	Return New Structure("FormName, Key", CurFormName, New Structure("Key", Value));
EndFunction

&AtServer
Function AllSelectedItems()
	
	Data = ThisObject().DynamicListCurrentData(DataList);
	
	Result = New Array();
	For Each curRow In Data Do
		Item = New Structure(DataStructure);
		FillPropertyValues(Item, curRow);
		Result.Add(Item);
	EndDo;
	
	Return Result;
EndFunction