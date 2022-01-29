
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	Parameters.Property("ТипыДляКонсолиЗапросов", _QueryConsoleTypes);
	Parameters.Property("ПоказыватьПростыеТипы", _ShowSimpleTypes);
	Parameters.Property("ПоказыватьПеречисления", _ShowEnums);
	Parameters.Property("ПереченьРазделов", _MetadataGroups);

	Value = Undefined;
	If Parameters.Property("ТипыДляЗаполненияЗначений", Value) And Value = True Then
		_ShowSimpleTypes = True;
		_ShowEnums = True;
	EndIf;

	If _QueryConsoleTypes Then
		_ShowEnums = True;
	EndIf;
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	TreeLines = MetadataTree.GetItems();
	TreeLines.Clear();

	If _ShowSimpleTypes And _QueryConsoleTypes Then
		TreeRoot = TreeLines.Add();
		TreeRoot.Name = "SimpleTypes";

		Struct = New Structure("Number, String, Date, Boolean");
		If _QueryConsoleTypes Then
			Struct.Insert("ValueList"); 
			
		EndIf;

		TreeLines = TreeRoot.GetItems();

		For Each Item In Struct Do
			TreeLine = TreeLines.Add();
			TreeLine.Name = Item.Key;
			TreeLine.FullName = Item.Key;
		EndDo;

		Items.MetadataTree.Expand(TreeRoot.GetID(), False);
		TreeLines = MetadataTree.GetItems();
	EndIf;

	TreeRoot = TreeLines.Add();
	TreeRoot.Name = "Configuration";
	
	MetadataGroups = "ExchangePlans, Catalogs, Documents, ChartsOfCharacteristicTypes, ChartsOfCalculationTypes, ChartsOfAccounts, 
	|BusinessProcesses, Tasks";
	If _ShowEnums Then
		MetadataGroups = "ExchangePlans, Catalogs, Documents, Enums, ChartsOfCharacteristicTypes, 
		|ChartsOfCalculationTypes, ChartsOfAccounts, BusinessProcesses, Tasks";
	EndIf;

	If Not IsBlankString(_MetadataGroups) Then
		MetadataGroups = _MetadataGroups;
	EndIf;

	StructGroups = New Structure(MetadataGroups);
	TreeLines = TreeRoot.GetItems();
	For Each Iten In StructGroups Do
		TreeLine = TreeLines.Add();
		TreeLine.Name = Iten.Key;
		TreeLine.GetItems().Add();
	EndDo;

	Items.MetadataTree.Expand(TreeRoot.GetID(), False);
	
EndProcedure

&AtClient
Procedure SelectObject(Command)
	
	CurrentData = Items.MetadataTree.CurrentData;

	If CurrentData <> Undefined And Not IsBlankString(CurrentData.FullName) Then
		Value = Undefined;
		GroupName = CurrentData.GetParent().Name;

		If GroupName = "SimpleTypes" Then
			If CurrentData.Name = "Number" Then
				Value = 0;
			ElsIf CurrentData.Name = "String" Then
				Value = "";
			ElsIf CurrentData.Name = "Date" Then
				Value = '00010101';
			ElsIf CurrentData.Name = "Boolean" Then
				Value = False;
			ElsIf CurrentData.Name = "ValueList" Then
				Value = New ValueList();
			Else
				Value = Undefined;
			EndIf;
		Else
			GroupName = Left(GroupName, Find(GroupName, " ") - 1);
			Value = EvalExpressionServer(GroupName + "." + CurrentData.Name + ".EmptyRef()");
		EndIf;

		If Value <> Undefined Then
			NotifyChoice(Value);
		EndIf;
		
	EndIf;
	
EndProcedure

&AtClient
Procedure MetadataTreeBeforeExpand(Item, Row, Cancel)
	
	Node = MetadataTree.FindByID(Row);
	TreeLines = Node.GetItems();
	If TreeLines.Count() = 1 And IsBlankString(TreeLines[0].Name) Then
		
	//	Cancel = True;
		TreeLines.Clear();
		GroupContent = MetadataGroupContentServer(Node.Name);
		Node.Name = Node.Name + " (" + String(GroupContent.Count()) + ")";
		For Each Row In GroupContent Do
			NewNode = TreeLines.Add();
			FillPropertyValues(NewNode, Row);
		EndDo;
		
		//Items.MetadataTree.Expand(Row);
	EndIf;
	
EndProcedure

&AtServerNoContext
Function MetadataGroupContentServer(NodeName)
	
	StringType = New TypeDescription("String");

	Tab = New ValueTable;
	Tab.Columns.Add("Name", StringType);
	Tab.Columns.Add("Synonym", StringType);
	Tab.Columns.Add("FullName", StringType);

	For Each MetadataItem In Metadata[NodeName] Do
		NewNode = Tab.Add();
		NewNode.Name = MetadataItem.Name;
		NewNode.Synonym = MetadataItem.Presentation();
		NewNode.FullName = MetadataItem.FullName();
	EndDo;
	
	Tab.Sort("Name");
	
	GroupContent = New Array;
	
	For Each GroupItem In Tab Do
		ItemStruct = New Structure("Name, FullName, Synonym");
		FillPropertyValues(ItemStruct, GroupItem);
		GroupContent.Add(ItemStruct);
	EndDo;	
	
	Return GroupContent;
	
EndFunction	

&AtClient
Procedure MetadataTreeSelection(Item, SelectedRow, Field, StandardProcessing)
	
	CurrentData = MetadataTree.FindByID(SelectedRow);
	If CurrentData <> Undefined And Not IsBlankString(CurrentData.FullName) Then
		If Not IsBlankString(CurrentData.FullName) Then
			StandardProcessing = False;
			SelectObject(Undefined);
		EndIf;
	EndIf;
	
EndProcedure

&AtServerNoContext
Function EvalExpressionServer(Formula)
	
	Try
		Result = Eval(Formula);
	Except
		Result = Undefined;
	EndTry;

	Return Result;
	
EndFunction