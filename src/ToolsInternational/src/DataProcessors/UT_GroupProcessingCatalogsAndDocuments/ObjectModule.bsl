Var mManagers Export;

Function GetComparisonType(FieldName, ComparisonType, ParameterName) Export
	If Left(FieldName, 7) = "Object." Then
		FieldName = "Reference." + Mid(FieldName, 8);
	EndIf;

	If ComparisonType = DataCompositionComparisonType.Equal Then
		Return "_Table." + FieldName + " = &" + ParameterName;

	ElsIf ComparisonType = DataCompositionComparisonType.Greater Then
		Return "_Table." + FieldName + " > &" + ParameterName;

	ElsIf ComparisonType = DataCompositionComparisonType.GreaterOrEqual Then
		Return "_Table." + FieldName + " >= &" + ParameterName;

	ElsIf ComparisonType = DataCompositionComparisonType.InHierarchy Or ComparisonType
		= DataCompositionComparisonType.InListByHierarchy Then
		Return "_Table." + FieldName + " IN HIERARCHY (&" + ParameterName + ")";

	ElsIf ComparisonType = DataCompositionComparisonType.InList Then
		Return "_Table." + FieldName + " IN (&" + ParameterName + ")";

	ElsIf ComparisonType = DataCompositionComparisonType.Less Then
		Return "_Table." + FieldName + " < &" + ParameterName;

	ElsIf ComparisonType = DataCompositionComparisonType.LessOrEqual Then
		Return "_Table." + FieldName + " <= &" + ParameterName;

	ElsIf ComparisonType = DataCompositionComparisonType.NotInList Then
		Return "НЕ _Table." + FieldName + " В (&" + ParameterName + ")";

	ElsIf ComparisonType = DataCompositionComparisonType.NotInHierarchy Or ComparisonType
		= DataCompositionComparisonType.NotInListByHierarchy Then
		Return "НЕ _Table." + FieldName + " IN HIERARCHY (&" + ParameterName + ")";

	ElsIf ComparisonType = DataCompositionComparisonType.NotEqual Then
		Return "_Table." + FieldName + " <> &" + ParameterName;

	EndIf;

EndFunction // ()

Function ExpandStringIntoArraySubstrings(Val Стр, Splitter = ",") Export

	ArrayString = New Array;
	If Splitter = " " Then
		Str = TrimAll(Str);
		While True Do
			Position = Find(Str, Splitter);
			If Position = 0 Then
				ArrayString.Add(Str);
				Return ArrayString;
			EndIf;
			ArrayString.Add(Left(Str, Position - 1));
			Str = TrimL(Mid(Str, Position));
		EndDo;
	Else
		SplitterLength = StrLen(Splitter);
		While True Do
			Position = Find(Str, Splitter);
			If Position = 0 Then
				If (TrimAll(Str) <> "") Then
					ArrayString.Add(Str);
				EndIf;
				Return ArrayString;
			EndIf;
			ArrayString.Add(Left(Str, Position - 1));
			Str = Mid(Str, Position + SplitterLength);
		EndDo;
	EndIf;

EndFunction

Function GetStringFromArrayOfSubstrings(Array, Splitter = ",") Export
	Result = "";
	For Each Item In Array Do
		Substring = ?(TypeOf(Item) = Type("String"), Item, String(Item));
		SubstringSplitter = ?(IsBlankString(Result), "", Splitter);
		Result = Result + SubstringSplitter + Substring;
	EndDo;

	Return Result;
EndFunction

Procedure DownloadDataProcessors(CurrentForm, AvailableDataProcessors2, SelectedDataProcessors2) Export

	MapAccessibilitySettings=New Map;
	MapAccessibilitySettings.Insert("ArbitraryAlgorithm", True);
	MapAccessibilitySettings.Insert("RenumberingObjects", True);
	MapAccessibilitySettings.Insert("MarkToDelete", False);
	MapAccessibilitySettings.Insert("PostTheDocuments", False);
	MapAccessibilitySettings.Insert("CancelPostingDocuments", False);
	MapAccessibilitySettings.Insert("UnmarkDeletion", False);
	MapAccessibilitySettings.Insert("ChangeTimeDocuments", True);
	MapAccessibilitySettings.Insert("ChangeAmountOperation", True);
	MapAccessibilitySettings.Insert("Delete", False);
	MapAccessibilitySettings.Insert("SettingAttributes", True);

	_AvailableDataProcessors = CurrentForm.FormAttributeToValue("AvailableDataProcessors");
	_SelectedDataProcessors = CurrentForm.FormAttributeToValue("SelectedDataProcessors");

	Forms = ThisObject.Metadata().Forms;

	For Each Form In Forms Do
		If Form.Name = "SelectionAndProcessing" Or Form.Name = "ФормаНастроек" Or Form.Name = "TemplateProcessing"
			Or Form.Name = "FormSelectionTables" Or Form.Name = "FormSelection" Then

			Continue;
		EndIf;
		FoundRow = _AvailableDataProcessors.Rows.Find(Form.Name, "FormName");
		If Not FoundRow = Undefined Then
			If Not FoundRow.Processing = Form.Synonym Then
				FoundRow.Processing = Form.Synonym;
			EndIf;			
			If Not MapAccessibilitySettings[Form.Name] Then
				FoundRow.Rows.Clear();
			EndIf;
			Continue;
		EndIf;

		NewDataProcessor = _AvailableDataProcessors.Rows.Add();
		NewDataProcessor.Processing = Form.Synonym;
		NewDataProcessor.FormName  = Form.Name;

		Setting = New Structure;
		Setting.Insert("Processing", Form.Synonym);
		Setting.Insert("Прочее", Undefined);
		NewDataProcessor.Setting.Add(Setting);
	EndDo;

	ArrayToDelete = New Array;

	For Each AvailableDataProcessor In _AvailableDataProcessors.Rows Do
		If Forms.Find(AvailableDataProcessor.FormName) = Undefined Then
			ArrayToDelete.Add(AvailableDataProcessor);
		EndIf;
	EndDo;

	For IndexOf = 0 To ArrayToDelete.Count() - 1 Do
		_AvailableDataProcessors.Rows.Delete(ArrayToDelete[IndexOf]);
	EndDo;

	ArrayToDelete.Clear();

	For Each SelectedDataProcessor In _SelectedDataProcessors Do
		If SelectedDataProcessor.RowAvailableDataProcessor = Undefined Then
			ArrayToDelete.Add(SelectedDataProcessor);
		Else
			If SelectedDataProcessor.RowAvailableDataProcessor.Parent = Undefined Then
				If _AvailableDataProcessors.Rows.Find(SelectedDataProcessor.RowAvailableDataProcessor.FormName, "FormName")
					= Undefined Then
					ArrayToDelete.Add(SelectedDataProcessor);
				EndIf;
			Else
				If _AvailableDataProcessors.Rows.Find(SelectedDataProcessor.RowAvailableDataProcessor.Parent.FormName,
					"FormName") = Undefined Then
					ArrayToDelete.Add(SelectedDataProcessor);
				EndIf;
			EndIf;
		EndIf;
	EndDo;

	For IndexOf = 0 To ArrayToDelete.Count() - 1 Do
		_SelectedDataProcessors.Delete(ArrayToDelete[IndexOf]);
	EndDo;

	CurrentForm.ValueToFormAttribute(_AvailableDataProcessors, "AvailableDataProcessors");
	CurrentForm.ValueToFormAttribute(_SelectedDataProcessors, "SelectedDataProcessors");

EndProcedure

// Initializes the mManagers variable containing the mappings of object types to their properties.
//
// Parameters:
//  None.
//
// Return value:
//  Map containing mappings of object types to their properties.
// 
Function InitializationManagers() Export

	Managers = New Map;

	TypeName = "Catalog";
	For Each MetadataObject In Metadata.Catalogs Do
		Name 			= MetadataObject.Name;
		Manager 		= Catalogs[Name];
		TypeRefString 	= "CatalogRef." + Name;
		TypeRef        	= Type(TypeRefString);
		Structure = New Structure("Name, TypeName, TypeRefString, Manager, TypeRef, MetadataObject", Name, TypeName,
			TypeRefString, Manager, TypeRef, MetadataObject);
		Managers.Insert(MetadataObject, Structure);
	EndDo;

	TypeName = "Document";
	For Each MetadataObject In Metadata.Documents Do
		Name 			= MetadataObject.Name;
		Manager 		= Documents[Name];
		TypeRefString 	= "DocumentRef." + Name;
		TypeRef        	= Type(TypeRefString);
		Structure = New Structure("Name, TypeName, TypeRefString, Manager, TypeRef, MetadataObject", Name, TypeName,
			TypeRefString, Manager, TypeRef, MetadataObject);
		Managers.Insert(MetadataObject, Structure);
	EndDo;

	Return Managers;

EndFunction // вInitializationManagers()

mManagers = InitializationManagers();