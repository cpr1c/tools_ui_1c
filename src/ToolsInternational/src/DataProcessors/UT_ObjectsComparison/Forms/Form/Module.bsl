&AtServerNoContext
Procedure AddToTree(VT, ObjectRef)
	MD = ObjectRef.Metadata();
	UUID = ObjectRef.UUID();
	GUUID = "id_" + StrReplace(UUID, "-", "_");
	
	VT.Columns.Add(GUUID, New TypeDescription());

	//Attributes
	Rows = VT.Rows;
	Row = Rows.Find(" Attributes", "Attribute");
	If Row = Undefined Then
		Row = Rows.Add();
		Row.Attribute = " Attributes";
	EndIf;
	Row[GUUID] = ObjectRef;

	Rows = Row.Rows;
	Attributes = MD.Attributes;
	For Each Attribute in Attributes Do
		AttributeName = Attribute.Name; 
		
		Row = Rows.Find(AttributeName, "Attribute");
		If Row = Undefined Then
			Row = Rows.Add();
			Row.Attribute = AttributeName;
		EndIf;
		Row[GUUID] = ObjectRef[AttributeName]; 
	EndDo;
		

	//Tabular section
	For Each TS In MD.TabularSections Do
		IF ObjectRef[TS.Name].Count() = 0 Then Continue; Endif;
		AttributeName = TS.Name; 
		
		Rows = TS.Rows;
		Row = Rows.Find(AttributeName, "Attribute");
		If Row = Undefined Then
			Row = Rows.Add();
			Row.Attribute = AttributeName;
		EndIf;

		//Rows tabular section
		RowsSet = Row.Rows;
		For Each RowTS In ObjectRef[TS.Name] Do
			NumberRow = "Row # " + Format(RowTS.NumberRow, "ND=4; NLZ=; NG=");
			RowSet = RowsSet.Find(NumberRow, "Attribute");
			If RowSet = Undefined Then 
				RowSet = RowsSet.Add();
				RowSet.Attribute = NumberRow;
			EndIf;
			
			//Values of the rows tabular section
			RowsRS = RowSet.Rows;
			For Each Attribute In MD.TabularSections[MD.Name].Attribute Do
				AttributeName = Attribute.Name; 

				RowRS = RowsRS.Find(AttributeName, "Attribute");
				If RowRS = Undefined Then
					RowRS = RowsRS.Add();
					RowRS.Name = AttributeName;
				EndIf;
				Value = RowRS[AttributeName];
				RowRS[GUUID] = ?(ValueIsFilled(Value), Value, Undefined);
			EndDo;

		EndDo;
	EndDo;
	
	Rows = VT.Rows;
	Rows.Sort("Attribute", True);
EndProcedure

&AtServerNoContext
Procedure ClearTree(VT, Rows = Undefined) 
	
	Columns = New Array;
	For Each Column In VT.Columns Цикл
		Если Column.Name = "Attribute" Then Continue; EndIF;
		Columns.Add(Column.Name);
	EndDo;
	CountCol = Columns.Count() - 1;
	If CountCol = 0 Then Return EndIf;

	If Rows = Undefined Then
		Rows = VT.Rows;
	EndIF;

	DeletedRows = New Array;
	For Each Row In Rows Do
		HaveSubordinates = Row.Rows.Count() > 0; 
		
		IF HaveSubordinates Then
			ClearTree(VT, Row.Rows);
		Else counter = 0;
			For Col = 1 to CountCol Do
				counter = counter + ?(Row[Columns[0]] = Row[Columns[Col]], 1, 0);
			EndDo;
			If counter = CountCol Then DeletedRows.Add(Row); EndIf;
		EndIf;
	EndDo;
	
	For Each Row In DeletedRows Do
		Rows.Delete(Row);
	EndDo;

EndProcedure

&AtServer
Procedure GeneratePrintFormObjectsComparison() Export 

	VT = New ValueTree;
	VT.Columns.Add("Attribute", New TypeDescription());

	For Each ObjectItem In Objects Do
		RefOnObject = ObjectItem.value;
		AddToTree(VT, RefOnObject);
	EndDo;

	ClearTree(VT);

	SpreadsheetDocument = New SpreadsheetDocument;
	SpreadsheetDocument.PrintParametersName = "Print_Parameters_Processing_ObjectsComparison";
	Template = DataProcessors.UT_ObjectsComparison.GetTemplate("PF_MXL_ComparisonObjects");
	
	SpreadsheetDocument.StartRowAutoGrouping();
	Level = 1;
	For Each Row In VT.Rows Do
		PrintRow(Row, VT.Columns, SpreadsheetDocument, Template, Level);// print row
	EndDo;
	SpreadsheetDocument.EndRowAutoGrouping();
	
	HeadArea = SpreadsheetDocument.Area(1,,1);
	SpreadsheetDocument.RepeatOnRowPrint = HeadArea;
	SpreadsheetDocument.ReadOnly = True;
	SpreadsheetDocument.FitToPage = True;
	SpreadsheetDocument.FixedTop = 1;
	SpreadsheetDocument.FixedLeft = 1;
	
EndProcedure

&AtServerNoContext
Procedure PrintRow(Row, Columns, SpreadsheetDocument, Template, Level)
	HaveNestedRows = Row.Rows.Count() > 0;//HaveNestedRows
	
	AttributeArea = Template.GetArea("Attribute");
	AttributeArea.Parameters.Attribute = TrimAll(Row.Attribute);
	If HaveNestedRows Then CheckoutArea(AttributeArea); EndIf;
	SpreadsheetDocument.Put(AttributeArea, Level);
	
	ColumnArea = Template.GetArea("Value");
	For Each Column In Columns Do
		If Column.Name = "Attribute" Then Continue; EndIf;
		Value = Row[Column.Name];
		ColumnArea.Parameters.Value = Value;
		If HaveNestedRows Then CheckoutArea(ColumnArea); EndIf;
		SpreadsheetDocument.Join(ColumnArea, Level);
	EndDo;
	

	If HaveNestedRows Then
		For Each SubString In Row.Rows Do
			PrintRow(SubString, Columns, SpreadsheetDocument, Template, Level + 1);
		EndDo;
	EndIf;
EndProcedure

&AtServerNoContext
Procedure CheckoutArea(Area)
	Font = Area.CurrentArea.Font;
	Area.CurrentArea.Font = New Font(Font,,,True);
	Area.CurrentArea.BackColor = StyleColors.ReportHeaderBackColor;
EndProcedure

&AtServer
Procedure GenerateAtServer()
	GeneratePrintFormObjectsComparison();
EndProcedure

&НаКлиенте
Procedure Generate(Command)
	If Objects.Count() = 0 Then
		Items.FormParameters.Check = True;
		Items.GroupParameters.Visible = True;
		CurrentItem = Items.Objects;
		Return;
	EndIf;
	GenerateAtServer();
	
EndProcedure

&НаКлиенте
Procedure Parameters(Command)
	Check = NOT Items.FormParameters.Check;
	Items.FormParameters.Check = Check;
	Items.GroupParameters.Visible = Check;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Objects.Clear();
	If Parameters.Property("ObjectsComparison") Then
		Objects.LoadValues(Parameters.ObjectsComparison);
	EndIF;
	GenerateAtServer();
	
	//UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);
	
EndProcedure


&AtServer
Procedure AddObjectsAddedToComparisonEarlyAtServer()
	ObjectsComparisonArray=UT_Common.ObjectsAddedToTheComparison();
	
	For Each CurrObject In ObjectsComparisonArray Do
		If Objects.FindByValue(CurrObject)<>Undefined Then
			Continue;
		EndIf;
		
		Objects.Add(CurrObject);
	EndDo;
EndProcedure


&НаКлиенте
Procedure AddObjectsAddedToComparisonEarly(Comand)
	AddObjectsAddedToComparisonEarlyAtServer();
EndProcedure


&AtServer
Procedure ClearObjectsAddedToTheComparisonAtServer()
	UT_Common.ClearObjectsAddedToTheComparison();
EndProcedure


&НаКлиенте
Procedure ClearObjectsAddedToTheComparison(Comand)
	ClearObjectsAddedToTheComparisonAtServer();
EndProcedure

//@skip-warning
&НаКлиенте
Procedure Attachable_ExecuteToolsCommonCommand(Comand) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Comand);
EndProcedure
