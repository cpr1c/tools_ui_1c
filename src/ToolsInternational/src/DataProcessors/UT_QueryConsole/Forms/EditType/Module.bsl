
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	CopyFormData(Parameters.Object, Object);
	
	Parameters.Property("EnabledInQuery", EnabledInQuery);
	Parameters.Property("ParameterName", ParameterName);
	
	vtTypeTree = Undefined;
	
	ValueType = Parameters.ValueType;
	
	Parameters.Property("AllowedList", AllowedList);
	
	If Not Parameters.Property("ToParameter", ToParameterMode) Then
		ToParameterMode = False;
	EndIf;
	
	If ToParameterMode Then
		StringMode = NStr("ru = 'В параметр'; en = 'To parameter'");
		Items.OKCommand.Title = StringMode;
	Else
		StringMode = NStr("ru = 'Редактирование типа'; en = 'Edit type'");
	EndIf;
	
	If Parameters.Property("Name", ParameterName) Then
		Title = StrTemplate("%1 (%2)", ParameterName, Lower(StringMode));
	Else
		Title = StringMode;
		ParameterName = "ValueTable";
	EndIf;
	
	If TypeOf(ValueType) = Type("Structure") And ValueType.Type = "Type" Then

		Try
			arTypes = New Array;
			arTypes.Add(FormAttributeToValue("Object").Container_RestoreValue(ValueType));
			ValueType = New TypeDescription(arTypes);
		Except
			ValueType = New TypeDescription;
		EndTry;
		
		fSimpleMode = True;
		fEditType = True;
		Items.CompositeType.Visible = False;
		Items.Container.Visible = False;
		Items.DateQualifiersGroup.Visible = False;
		Items.NumberQualifiersGroup.Visible = False;
		Items.StringQualifiersGroup.Visible = False;
		
	ElsIf TypeOf(ValueType) = Type("Type") Then
		
		arTypes = New Array;
		arTypes.Add(ValueType);
		ValueType = New TypeDescription(arTypes);
			
		fSimpleMode = True;
		fEditType = True;
		Items.CompositeType.Visible = False;
		Items.Container.Visible = False;
		Items.DateQualifiersGroup.Visible = False;
		Items.NumberQualifiersGroup.Visible = False;
		Items.StringQualifiersGroup.Visible = False;
		
	Else
	
		If Not ValueIsFilled(ValueType) Then
			ValueType = New TypeDescription;
		EndIf;
		
		ContainerType = Undefined;
		fSimpleMode = Not Parameters.Property("ContainerType", ContainerType);
		
		If fSimpleMode Then
			ContainerType = 0;
			Items.Container.Visible = False;
		EndIf;
		
		If ContainerType = 3 Then
			
			//Table structure edit mode. If the table contains data, data will be saved.
			Table = FormAttributeToValue("Object").StringToValue(ValueType.Value);
			
			//Don't send data to client.
			TableAddress = PutToTempStorage(Table, UUID);
			
			FillTableStructure(Table);
			ValueType = New TypeDescription;
			
		EndIf;
		
	EndIf;
		
	CompositeType = ValueType.Types().Count() > 1;
	
	DateQualifiersContent = ValueType.DateQualifiers.DateFractions;
	StringQualifiersLength = ValueType.StringQualifiers.Length;
	StringQualifiersFixed = ValueType.StringQualifiers.AllowedLength = AllowedLength.Fixed;
	NumberQualifiersLength = ValueType.NumberQualifiers.Digits;
	NumberQualifiersNonnegative = ValueType.NumberQualifiers.AllowedSign = AllowedSign.Nonnegative;
	NumberQualifiersPrecision = ValueType.NumberQualifiers.FractionDigits;
	
	vtTypeTree = GetTypeTree(ValueType, AllowedList);
	If Not CompositeType And ContainerType = 0 Then
		AddPointInTimeBoundaryToTree(vtTypeTree, ValueType);
	EndIf;
	
	TypeTree = PutToTempStorage(vtTypeTree, UUID);
	RefreshTypeContentAtServer();
	
	SetItemsVisible();
	
	CurrentItem = Items.SearchString;

EndProcedure

&AtServer
Procedure TypeTreeToFormData(Node, AttributeNode, CurrentRow = Undefined, SelectedChild = False)
	
	NodeItems = AttributeNode.GetItems();
	
	For Each Row In Node.Rows Do
		
		If Row.Rows.Count() > 0 Then
			
			AttributeRow = NodeItems.Add();
			FillPropertyValues(AttributeRow, Row);
			AttributeRow.SelectedChild = False;
			TypeTreeToFormData(Row, AttributeRow, CurrentRow, AttributeRow.SelectedChild);
			
			If AttributeRow.GetItems().Count() = 0 Then
				NodeItems.Delete(AttributeRow);
			EndIf;
			
		Else
			
			If Not ValueIsFilled(SearchString)
					Or Find(Upper(Row.Presentation), Upper(SearchString)) > 0
					//Or Find(Upper(Row.Name), Upper(SearchString)) > 0
						Then
				AttributeRow = NodeItems.Add();
				FillPropertyValues(AttributeRow, Row);
				SelectedChild = SelectedChild Or Row.Selected;
			EndIf;
			
		EndIf;
		
		If CurrentRow = Undefined And AttributeRow <> Undefined And Row.Selected Then
			CurrentRow = AttributeRow.GetID();
		EndIf;
		
	EndDo;
	
EndProcedure

&AtServer
Procedure RefreshTreeChecks(TreeNode, TypeContentNode)
	Var NodeItems;
	
	If TypeContentNode <> Undefined Then
		NodeItems = TypeContentNode.GetItems();
	EndIf;
	
	j = 0;
	For Each TreeRow In TreeNode.Rows Do
		
		If NodeItems = Undefined Or NodeItems.Count() <= j Then
			If ResetAll Then
				TreeRow.Selected = False;
				If TreeRow.Row.Count() > 0 Then
					RefreshTreeChecks(TreeRow, Undefined);
				EndIf;
				Continue;
			Else
				Break;
			EndIf;
		EndIf;
		
		If ResetAll Then
			TreeRow.Selected = False;
		EndIf;
		
		If NodeItems[j].Name = TreeRow.Name Then
			
			TreeRow.Selected = NodeItems[j].Selected;
			
			If TreeRow.Rows.Count() > 0 Then
				RefreshTreeChecks(TreeRow, NodeItems[j]);
			EndIf;
			
			j = j + 1;
			
		EndIf;
		
	EndDo;
	
	ResetAll = False;
	
EndProcedure

&AtServer
Procedure RefreshTypeContentAtServer()
	
	vtTree = GetFromTempStorage(TypeTree);
	RefreshTreeChecks(vtTree, TypeContent);
	PutToTempStorage(vtTree, TypeTree);
	
	CurrentRow = Undefined;
	TypeContent.GetItems().Clear();
	TypeTreeToFormData(vtTree, TypeContent, CurrentRow);
	Items.TypeContent.CurrentRow = CurrentRow;
	
EndProcedure

&AtClient
Procedure SetTypeTreeState()
	If ValueIsFilled(SearchString) Then
		For Each Item In TypeContent.GetItems() Do
			Items.TypeContent.Expand(Item.GetID(), True);
		EndDo;
	EndIf;
EndProcedure

&AtClient
Procedure RefreshTypeContent() Export
	RefreshTypeContentAtServer();
	SetTypeTreeState();
EndProcedure

&AtServer
Function GetTypeQualifiersPresentation(ValueType)

	arQualifiers = New Array;
	
	If ValueType.ContainsType(Type("String")) Then
		StringQualifiersPresentation = NStr("ru  = 'Длина '; en = 'Length '") + ValueType.StringQualifiers.Length;
		arQualifiers.Add(New Structure("Type", "String", StringQualifiersPresentation));
	EndIf;
		
	If ValueType.ContainsType(Type("Date")) Then
		DateQualifiersPresentation = ValueType.DateQualifiers.DateFractions;
		arQualifiers.Add(New Structure("Type, Qualifiers", "Date", DateQualifiersPresentation));
	EndIf;
	
	If ValueType.ContainsType(Type("Number")) Then
		NumberQualifiersPresentation =
			NStr("ru = 'Знак '; en = 'Sign '") + ValueType.NumberQualifiers.AllowedSign + " " +
			ValueType.NumberQualifiers.Digits + "." + ValueType.NumberQualifiers.FractionDigits;
		arQualifiers.Add(New Structure("Type, Qualifiers", "Number", NumberQualifiersPresentation));
	EndIf;
	
	TitleRequiredFlag = arQualifiers.Count() > 1;
	
	TypeQualifiersPresentation = "";
	For Each stQualifiers In arQualifiers Do
		TypeQualifiersPresentation = TypeQualifiersPresentation + ?(TitleRequiredFlag, stQualifiers.Type + ": ", "") + stQualifiers.Qualifiers + "; ";
	EndDo;
	
	Return TypeQualifiersPresentation;
	
EndFunction

&AtServer
Procedure FillTableStructure(Table)
	
	For Each Column In Table.Columns Do
		StructureRow = TableStructure.Add();
		FillPropertyValues(StructureRow, Column, "Name, ValueType");
		StructureRow.OldName = Column.Name;
		StructureRow.Qualifiers = GetTypeQualifiersPresentation(Column.ValueType);
	EndDo;
	
EndProcedure

&AtServer
Function GetFirstSelected(TypeContent)
	
	For Each TypeRow In TypeContent.GetItems() Do
		If TypeRow.IsFolder Then
			Result = GetFirstSelected(TypeRow);
			If Result <> Undefined Then
				Return Result;
			EndIf;
		Else
			If TypeRow.Selected Then
				Return TypeRow.Name;
			EndIf;
		EndIf;
	EndDo;
	
	Return Undefined;
	
EndFunction

&AtServer
Function CollectTypes(TypeContent, arTypes = Undefined)
	
	If arTypes = Undefined Then
		arTypes = New Array;
	EndIf;
	
	For Each TypeRow Из TypeContent.Rows Do
		If TypeRow.IsFolder Then
			arTypes = CollectTypes(TypeRow, arTypes);
		Else
			If TypeRow.Selected Then
				arTypes.Add(Type(TypeRow.Name));
			EndIf;
		EndIf;
	EndDo;
	
	Return arTypes;
	
EndFunction

&AtServer
Function GetTypeDescription()
	
	vtTree = GetFromTempStorage(TypeTree);
	RefreshTreeChecks(vtTree, TypeContent);
	arTypes = CollectTypes(vtTree);
	
	NumberQualifiers = New NumberQualifiers(NumberQualifiersLength, NumberQualifiersPrecision, ?(NumberQualifiersNonnegative, AllowedSign.Nonnegative, AllowedSign.Any));
	StringQualifiers = New StringQualifiers(StringQualifiersLength, ?(StringQualifiersFixed, AllowedLength.Fixed, AllowedLength.Variable));
	DateQualifiers = New DateQualifiers(?(DateQualifiersContent = "Date and time", DateFractions.DateTme, DateFractions[DateQualifiersContent]));
	
	Return New TypeDescription(arTypes, NumberQualifiers, StringQualifiers, DateQualifiers);
	
EndFunction

&AtServer
Function GetTypeContainer(TypeDescription)
	
	DataProcessor = FormAttributeToValue("Object");
	ReturnType = Type("Undefined");
	
	arTypes = TypeDescription.Types();
	If arTypes.Count() > 0 Then
		ReturnType = arTypes[0];
	EndIf;
	
	Return DataProcessor.Container_SaveValue(ReturnType);
	
EndFunction

&AtServer
Function GetTable(QueryText = Undefined)
	
	DataProcessor = FormAttributeToValue("Object");
	
	fColumnsChanged = False;
	stColumnMap = New Structure;
	arColumnExpressions  = New Array;
	Table = New ValueTable;
	For Each StructureRow In TableStructure Do
		
		Column = Table.Columns.Add(StructureRow.Name, StructureRow.ValueType);
		
		arColumnExpressions.Add(StrTemplate(NStr("	%1.%2 AS %2"), ParameterName, Column.Name));
		
		If ValueIsFilled(StructureRow.OldName) Then
			stColumnMap.Insert(StructureRow.Name, StructureRow.OldName);
			fColumnsChanged = fColumnsChanged Or StructureRow.OldName <> StructureRow.Name;
		EndIf;
			
	EndDo;
	
	If stColumnMap.Count() > 0 Then
		
		OldTable = GetFromTempStorage(TableAddress);
		
		If fColumnsChanged Then
			
			For Each Row In OldTable Do
				NewRow = Table.Add();
				For Each kv In stColumnMap Do
					NewRow[kv.Key] = Row[kv.Value];
				EndDo;
			EndDo;
			
		Else
			For Each Row In OldTable Do
				FillPropertyValues(Table.Add(), Row);
			EndDo;
		EndIf;
		
	EndIf;

	ColumnExpressions = StrConcat(arColumnExpressions, ",
		|");
	QueryText = StrTemplate("
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		| %1
		|INTO %2
		|FROM &%2 AS %2;",
		ColumnExpressions,
		ParameterName);
		
	Return DataProcessor.Container_SaveValue(Table);
		
EndFunction

&AtClient
Function FullFormName(FormName)
	Return StrTemplate("%1.Form.%2", Object.MetadataPath, FormName);
EndFunction

&AtClient
Procedure OKCommand(Command)
	
	ReturnValue = New Structure("ParameterName, ContainerType, ContainerDescription", ParameterName, ContainerType, GetTypeDescription());
	
	If ContainerType < 3 Then
		
		If fEditType Then
			ReturnValue.ContainerDescription = GetTypeContainer(ReturnValue.ContainerDescription);
		ElsIf ReturnValue.ContainerDescription.ContainsType(Type("Boundary")) Or ReturnValue.ContainerDescription.ContainsType(Type("PointInTime")) Then
			ReturnValue.ContainerType = 0;
		EndIf;
		
	Else
		
		ReturnValue.ContainerDescription = GetTable();
		
	EndIf;
	
	Close(ReturnValue);
	
EndProcedure

&AtClient
Procedure ToQueryCommand(Command)
	Var QueryText;
	
	ReturnValue = New Structure("ParameterName, ContainerType, ContainerDescription, QueryText", ParameterName, ContainerType, GetTypeDescription());
	ReturnValue.ContainerDescription = GetTable(QueryText);
	ReturnValue.QueryText = QueryText;
	
	Close(ReturnValue);
	
EndProcedure

&AtServer
Procedure AddPointInTimeBoundaryToTree(vtTree, CurrentValueType = Undefined)
	Var Pictures;
	
	If CurrentValueType = Undefined Then
		CurrentValueType = New TypeDescription;
	EndIf;
	
	AddType(vtTree, CurrentValueType, "Boundary", Pictures, "Boundary", 4);
	AddType(vtTree, CurrentValueType, "PointInTime", Pictures, "Point in time", 5);
	
	fPointInTimeBoundary = True;
	
EndProcedure

&AtServer
Procedure AddPointInTimeBoundary()
	
	vtTree = GetFromTempStorage(TypeTree);
	AddPointInTimeBoundaryToTree(vtTree);
	PutToTempStorage(vtTree, TypeTree);
	
	RefreshTypeContentAtServer();
	
EndProcedure

&AtServer
Procedure RemovePointInTimeBoundaryFromTree(vtTree)
	
	If vtTree.Rows[4].Name = "Boundary" Then
		vtTree.Rows.Delete(vtTree.Rpws[4]);
	EndIf;
	
	If vtTree.Rows[4].Name = "PointInTime" Then
		vtTree.Rows.Delete(vtTree.Rows[4]);
	EndIf;
	
	fPointInTimeBoundary = False;
	
EndProcedure

&AtServer
Procedure RemovePointInTimeBoundary()
	
	vtTree = GetFromTempStorage(TypeTree);
	RefreshTreeChecks(vtTree, TypeContent);
	RemovePointInTimeBoundaryFromTree(vtTree);
	PutToTempStorage(vtTree, TypeTree);
	
	CurrentRow = Undefined;
	TypeContent.GetItems().Clear();
	TypeTreeToFormData(vtTree, TypeContent, CurrentRow);
	Items.TypeContent.CurrentRow = CurrentRow;
	
EndProcedure

&AtServer
Procedure StePointInTimeBoundaryVisible()
	
	If ContainerType = 0 And Not CompositeType And (Not fSimpleMode Or fEditType) Then
		If Not fPointInTimeBoundary Then
			AddPointInTimeBoundary();
		EndIf;
	Else
		If fPointInTimeBoundary Then
			RemovePointInTimeBoundary();
		EndIf;
	EndIf;
	
EndProcedure

&AtServer
Procedure AddType(vtTree, CurrentValueType, strTypeName, Pictures, strTypePresentation = Undefined, nInsertIndex = Undefined)
	
	If Pictures = Undefined Then
		Pictures = GetFromTempStorage(Object.Pictures);
	EndIf;
	
	If nInsertIndex = Undefined Then
		Row = vtTree.Rows.Add();
	Else
		Row = vtTree.Rows.Insert(nInsertIndex);
	EndIf;
	
	Row.Name = strTypeName;
	If TypeOf(Pictures) = Type("Picture") Then
		Row.Picture = Pictures;
	Else
		Picture = Undefined;
		If Find(strTypeName, ".") = 0 Then
			If Pictures.Property("Type_" + strTypeName, Picture) Then
				Row.Picture = Picture;
			EndIf;
		EndIf;
	EndIf;
	
	If strTypePresentation = Undefined Then
		Row.Presentation = strTypeName;
	Else
		Row.Presentation = strTypePresentation;
	EndIf;
	
	If CurrentValueType.ContainsType(Type(strTypeName)) Then
		Row.Selected = True;
		If Row.Parent <> Undefined Then
			Row.Parent.SelectedChild = True;
		EndIf;
	EndIf;
	
EndProcedure

&AtServer
Procedure AddRefTypes(Types, CurrentValueType, Manager, strNamePrefix, Pictures)
	Var RefPicture;
	
	Pictures.Property("Type_" + strNamePrefix, RefPicture);
	
//	arTypes = Manager.AllRefsType().Types();
	
	TypeBranch = Types.Rows.Add();
	TypeBranch.Name = strNamePrefix;
	TypeBranch.Presentation = strNamePrefix + " (" + Format(Manager.Count(), "NG=0") + ")";
	TypeBranch.IsFolder = True;
	TypeBranch.Picture = RefPicture;
	
	For Each tType In Manager Do
		strTypeName = tType.Имя;
		strType = strNamePrefix + "." + strTypeName;
		Ref = New(Type(strType));
		
		AddType(TypeBranch, CurrentValueType, strType, RefPicture, strTypeName);
		//AddType(TypeBranch, CurrentValueType, strType, RefPicture, String(tType));
	EndDo;
	
	TypeBranch.Rows.Sort("Presentation");
	
EndProcedure

&AtServer
Function GetTypeTree(CurrentValueType, AllowedList)
	Var Pictures;
	
	Types = New ValueTree;
	Types.Columns.Add("Selected", New TypeDescription("Boolean"));
	Types.Columns.Add("SelectedChild", New TypeDescription("Boolean"));
	Types.Columns.Add("Name", New TypeDescription("String"));
	Types.Columns.Add("Picture", New TypeDescription("Picture"));
	Types.Columns.Add("Presentation", New TypeDescription("String"));
	Types.Columns.Add("IsFolder", New TypeDescription("Boolean"));
	
	AddType(Types, CurrentValueType, "Boolean", Pictures);
	AddType(Types, CurrentValueType, "Date", Pictures);
	AddType(Types, CurrentValueType, "String", Pictures);
	AddType(Types, CurrentValueType, "Number", Pictures);
	AddType(Types, CurrentValueType, "Null", Pictures);
	//AddType(Types, CurrentValueType, "Undefined", Pictures);
	AddType(Types, CurrentValueType, "AccumulationRecordType", Pictures, NStr("ru = 'Вид движения накопления'; en = 'Accumulation record type'"));
	AddType(Types, CurrentValueType, "AccountingRecordType", Pictures,  NStr("ru = 'Вид движения бухгалтерии'; en = 'Accounting record type'"));
	AddType(Types, CurrentValueType, "AccountType", Pictures, NStr("ru = 'Вид счета'; en = 'Account type'"));
	AddType(Types, CurrentValueType, "Type", Pictures);
	AddType(Types, CurrentValueType, "UUID", Pictures, NStr("ru = 'Уникальный идентификатор'; en = 'UUID'"));

	AddRefTypes(Types, CurrentValueType, Metadata.Catalogs, "CatalogRef", Pictures);
	AddRefTypes(Types, CurrentValueType, Metadata.Documents, "DocumentRef", Pictures);
	AddRefTypes(Types, CurrentValueType, Metadata.Enums, "EnumRef", Pictures);
	AddRefTypes(Types, CurrentValueType, Metadata.ChartsOfCharacteristicTypes, "ChartOfCharacteristicTypesRef", Pictures);
	AddRefTypes(Types, CurrentValueType, Metadata.ChartsOfAccounts, "ChartOfAccountsRef", Pictures);
	AddRefTypes(Types, CurrentValueType, Metadata.ChartsOfCalculationTypes, "ChartOfCalculationTypesRef", Pictures);
	AddRefTypes(Types, CurrentValueType, Metadata.BusinessProcesses, "BusinessProcessRef", Pictures);
	AddRefTypes(Types, CurrentValueType, Metadata.Tasks, "TaskRef", Pictures);
	AddRefTypes(Types, CurrentValueType, Metadata.ExchangePlans, "ExchangePlanRef", Pictures);
	
	Return Types;

EndFunction

&AtClient
Procedure TypeContentResetAllExceptThis(Node, strExceptName)
	
	RowExcept = Undefined;
	For Each Row In Node.GetItems() Do
		
		If Row.Name <> strExceptName Then
			Row.Selected = False;
			Row.SelectedChild = False;
			TypeContentResetAllExceptThis(Row, strExceptName);
		Else
			RowExcept = Row;
		EndIf;
		
	EndDo;
	
	If RowExcept <> Undefined And RowExcept.Selected Then
		Parent = Row.GetParent();
		If Parent <> Undefined Then
			Parent.SelectedChild = True;
		EndIf;
	EndIf;
	
	//Resetting all the checks in small tree at client. Checks in session data are still available but invalid.
	//They will be dropped at server before checks refresh. This flag controls it.
	ResetAll = True;
		
EndProcedure
	
&AtClient
Procedure TypeContentSelectedOnChange(Item)
	
	If Not CompositeType Then
		TypeContentResetAllExceptThis(TypeContent, Items.TypeContent.CurrentData.Name);
	EndIf;
	
	If Items.TypeContent.CurrentData.Selected Then
		Parent = Items.TypeContent.CurrentData.GetParent();
		If Parent <> Undefined Then
			Parent.SelectedChild = True;
		EndIf;
	EndIf;
	
	RefreshQualifiersView();

EndProcedure

&AtServer
Function CompositeTypeOnChangeAtServer()
	
	strCurrentName = Undefined;
	
	If CompositeType Then
		SetItemsVisible();
	Else
		strCurrentName = GetFirstSelected(TypeContent);
		SetItemsVisible();
	EndIf;
	
	Return strCurrentName;
	
EndFunction

&AtClient
Procedure CompositeTypeOnChange(Item)
	
	strCurrentName = CompositeTypeOnChangeAtServer();
	
	If Not CompositeType Then
		TypeContentResetAllExceptThis(TypeContent, strCurrentName);
	EndIf;
	
	SetTypeTreeState();
	
EndProcedure

&AtClient
Procedure RefreshQualifiersView() Export
	
	If Not fEditType Then
		
		fNumberQualifiersVisible = Items.TypeContent.CurrentData <> Undefined And Items.TypeContent.CurrentData.Selected And Items.TypeContent.CurrentData.Name = "Number";
		fStringQualifiersVisible = Items.TypeContent.CurrentData <> Undefined And Items.TypeContent.CurrentData.Selected And Items.TypeContent.CurrentData.Name = "String";
		fDateQualifiersVisible = Items.TypeContent.CurrentData <> Undefined And Items.TypeContent.CurrentData.Selected And Items.TypeContent.CurrentData.Name = "Date";
		
		Items.NumberQualifiersGroup.Visible = fNumberQualifiersVisible;
		Items.StringQualifiersGroup.Visible = fStringQualifiersVisible;
		Items.DateQualifiersGroup.Visible = fDateQualifiersVisible;
		
		If fStringQualifiersVisible Then
			If StringQualifiersLength = 0 Then
				StringQualifiersComment = NStr("ru = '(неограниченная)'; en = '(open-ended)'");
				Items.StringQualifiersFixed.Visible = False;
			Else
				StringQualifiersComment = "";
				Items.StringQualifiersFixed.Visible = True;
			EndIf;
		EndIf;
		
	EndIf;
	
EndProcedure

&AtClient
Procedure TypeContentOnActivateRow(Item)
	AttachIdleHandler("RefreshQualifiersView", 0.1, True);
EndProcedure

&AtClient
Procedure StringQualifiersLengthOnChange(Item)
	RefreshQualifiersView();
EndProcedure

&AtServer
Procedure SetItemsVisible()
	
	fTable = ContainerType = 3;
	Items.ValueTypeGroup.Visible = Not fTable;
	Items.TableEditGroup.Visible = fTable;
	Items.ToQueryCommand.Visible = fTable И EnabledInQuery;
	
	If Not fTable Then
		StePointInTimeBoundaryVisible();
	EndIf;
	
EndProcedure

&AtClient
Procedure ContainerOnChange(Item)
	SetItemsVisible();
	SetTypeTreeState();
EndProcedure

&AtClient
Procedure TypeEditFinish(Result, AdditionalParameters) Export
	
	If Result <> Undefined Then
		
		StructureRow = AdditionalParameters.Table.FindByID(AdditionalParameters.Row);
		StructureRow.ValueType = Result.ContainerDescription;
		StructureRow.Qualifiers = GetTypeQualifiersPresentation(Result.ContainerDescription);
		
	EndIf;
		
EndProcedure

&AtClient
Procedure TableStructureValueTypeStartChoice(Item, ChoiceData, StandardProcessing)
	
	ValueType = Items.TableStructure.CurrentData.ValueType;
	
	NotifyParameters = New Structure("Table, Row, Field", TableStructure, Items.TableStructure.CurrentRow, "ValueType");
	CloseFormNotifyDescription = New NotifyDescription("TypeEditFinish", ThisForm, NotifyParameters);
	OpeningParameters = New Structure("Object, ValueType", Object, ValueType);
	OpenForm(FullFormName("EditType"), OpeningParameters, ThisForm, True, , , CloseFormNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
	
	StandardProcessing = False;
	
EndProcedure

&AtClient
Procedure TypeContentOnChange(Item)
	
	If Items.TypeContent.CurrentData.IsFolder Then
		
		If CompositeType Then
			
			GroupItems = TypeContent.FindByID(Items.TypeContent.CurrentRow).GetItems();
			fParentSelected = Items.TypeContent.CurrentData.Selected;
			For Each Item In GroupItems Do
				Item.Selected = fParentSelected;
			EndDo;
			
			Items.TypeContent.CurrentData.SelectedChild = fParentSelected;
			
		Else
			Items.TypeContent.CurrentData.Selected = False;
			Items.TypeContent.Expand(Items.TypeContent.CurrentRow);
		EndIf;
		
	Else
		
		Parent = TypeContent.FindByID(Items.TypeContent.CurrentRow).GetParent();
		If Parent <> Undefined Then
			
			If Items.TypeContent.CurrentData.Selected Then
				Parent.SelectedChild = True;
			Else
				Parent.SelectedChild = False;
				GroupItems = Parent.GetItems();
				For Each Item In GroupItems Do
					If Item.Selected Then
						Parent.SelectedChild = True;
						Break;
					EndIf;
				EndDo;
			EndIf;
			
		EndIf;
		
	EndIf;
	
EndProcedure

&AtClient
Procedure SearchStringEditTextChange(Item, Text, StandardProcessing)
	SearchString = Text;
	StandardProcessing = False;
	RefreshTypeContent();
EndProcedure

&AtClient
Procedure ProcessColumnNameChange(NewRow, CancelEdit, Cancel)
	
	strColumnName = Items.TableStructure.CurrentData.Name;
	
	fNameIsCorrect = False;
	Try
		//@skip-warning
		st = New Structure(strColumnName);
		fNameIsCorrect = ValueIsFilled(strColumnName);
	Except
	EndTry;
	
	If Not fNameIsCorrect Then
		ShowMessageBox(, NStr("ru = 'Неверное имя колонки! Имя должно состоять из одного слова, начинаться с буквы и не содержать специальных символов кроме ""_"".'; en = 'Column name is incorrect. The name must consist of one word, start with a letter and contain no special characters except ""_"".'"), , Title);
		Cancel = True;
		Return;
	EndIf;
	
	arNameRows = TableStructure.FindRows(New Structure("Name", strColumnName));
	If arNameRows.Count() > 1 Then
		ShowMessageBox(, NStr("ru = 'Колонка с таким именем уже есть! Введите другое имя.'; en = 'Column with this name already exists. Please enter another name.'"), , Title);
		Cancel = True;
		Return;
	EndIf;
	
EndProcedure

&AtClient
Procedure TableStructureBeforeEditEnd(Item, NewRow, CancelEdit, Cancel)
	ProcessColumnNameChange(NewRow, CancelEdit, Cancel);
EndProcedure

