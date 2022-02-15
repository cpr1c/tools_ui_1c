
////////////////////////////////////////////////////////////////////////////////
// FORM EVENT HANDLERS
&AtClient
Procedure OnOpen(Cancel)

	BeginAttachingFileSystemExtension(New NotifyDescription("OnOpenEnd", ThisForm));

EndProcedure

&AtClient
Procedure OnOpenEnd(Connected, AdditionalParameters) Export

	FileSelectionCapability = Connected;

EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	If Parameters.Property("AutoTest") Then // Return If the form is got for analysis
		Return;
	EndIf;

	DeletionMode = "Full";
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.CommandBars);

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// TOP ELEMENT EVENT HANDLERS

&AtClient
Procedure DeleteModeOnChange(Item)
	
	UpdateAvailablButtons();
	
EndProcedure


////////////////////////////////////////////////////////////////////////////////
//FORM TABLE MarkedForDeletionItemsTree EVENT HANDLERS

&AtClient
Procedure MarkOnChange(Item)

	CurrentData = Items.MarkedForDeletionItemsTree.CurrentData;

	If CurrentData = Undefined Then
		Return;
	EndIf;

	SetMarkInList(CurrentData, CurrentData.Check, True);

EndProcedure



&AtClient
Procedure MarkedForDeletionItemsTreeSelection(Item, RowSelected, Field, StandardProcessing)

	StandardProcessing = False;

	If Item.CurrentData <> Undefined Then
		OpenValueByType(Item.CurrentData.Value);
	EndIf;

EndProcedure

////////////////////////////////////////////////////////////////////////////////
//FORM TABLE NotDeletedItemsTree EVENT HANDLERS

&AtClient
Procedure NotDeletedItemsTreeSelection(Item, RowSelected, Field, StandardProcessing)

	StandardProcessing = False;

	If Item.CurrentData <> Undefined Then
		OpenValueByType(Item.CurrentData.Value);
	EndIf;

EndProcedure

&AtClient
Procedure NotDeletedItemsTreeBeforeRowChange(Item, Cancel)

	Cancel = True;

	If Item.CurrentData <> Undefined Then
		OpenValueByType(Item.CurrentData.Value);
	EndIf;

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// FORM COMANDS EVENT HANDLERS

&AtClient
Procedure CommandSelectedListSetAll()

	ListItems = MarkedForDeletionItemsTree.GetItems();
		For Each Item In ListItems Do
		SetMarkInList(Item, True, True);
		Parent = Item.GetParent();
		If Parent = Undefined Then
			CheckParent(Item);
		EndIf;
	EndDo;

EndProcedure

&AtClient
Procedure CommandSelectedListClearAll()

	ListItems = MarkedForDeletionItemsTree.GetItems();
	For Each Item In ListItems Do
		SetMarkInList(Item, False, True);
		Parent = Item.GetParent();
		If Parent = Undefined Then
			CheckParent(Item);
		EndIf;
	EndDo;

EndProcedure

&AtClient
Procedure ChangeObject(Command)

	If CurrentItem = Undefined Then
		Return;
	EndIf;

	If CurrentItem <> Items.MarkedForDeletionItemsTree And CurrentItem <> Items.NotDeletedItemsTree Then
		Return;
	EndIf;

	If CurrentItem.CurrentData <> Undefined Then
		OpenValueByType(CurrentItem.CurrentData.Value);
	EndIf;

EndProcedure
&AtClient
Procedure EditObject(Command)
	If CurrentItem = Undefined Then
		Return;
	EndIf;

	If CurrentItem <> Items.MarkedForDeletionItemsTree And CurrentItem <> Items.NotDeletedItemsTree Then
		Return;
	EndIf;

	If CurrentItem.CurrentData <> Undefined Then
		UT_CommonClient.EditObject(CurrentItem.CurrentData.Value);
	EndIf;
EndProcedure
&AtClient
Procedure RunNext()

	CurrentPage = Items.FormPages.CurrentPage;

	If CurrentPage = Items.SelectDeleteMode Then

		UpdateDeleteMarkedList(Undefined);

		Items.FormPages.CurrentPage = Items.MarkedForDelete;
		UpdateAvailablButtons();

	EndIf;

EndProcedure

&AtClient
Procedure RunBack()

	CurrentPage = Items.FormPages.CurrentPage;
	If CurrentPage = Items.MarkedForDelete Then
		Items.FormPages.CurrentPage = Items.SelectDeleteMode;
		UpdateAvailablButtons();
	ElsIf CurrentPage = Items.DeletionFailureReasonsPage Then
		If DeletionMode = "Full" Then
			Items.FormPages.CurrentPage = Items.SelectDeleteMode;
		Else
			Items.FormPages.CurrentPage = Items.MarkedForDelete;
		EndIf;
		UpdateAvailablButtons();
	EndIf;

EndProcedure

&AtClient
Procedure RunDelete()

	Перем DeletionObjectsTypes;
	

	If DeletionMode = "Full" Then
		Status(NStr("en = 'Find and deletion of marked objects ; ru = 'Выполняется поиск и удаление помеченных объектов'"));
	Else
		Status(NStr("en = 'Deletion of marked objects' ; ru = 'Выполняется удаление выбранных объектов'"));
	EndIf;

	Result = DeletionMarkedAtServer(DeletionObjectsTypes);
	If Не Result.JobCompleted Then
		ScheduledJobID 		  = Result.ScheduledJobID;
		StorageAddress       = Result.StorageAddress;

		UT_TimeConsumingOperationsClient.InitializeIdleHandlerParameters(IdleHandlerParameters);

		AttachIdleHandler("Attachable_CheckTaskCompletion", 1, True);
		Items.FormPages.CurrentPage = Items.TimeConsumingOperationPage;
	Else
		UpdateContent(Result.DeletionResult, Result.ErrorMessage,
			Result.DeletionResult.DeletionObjectsTypes);
		AttachIdleHandler("SwitchPage", 0.1, True);
	EndIf;

EndProcedure

&AtClient
Procedure UpdateDeleteMarkedList(Command)

	Status(NStr("en = 'Searching for objects marked for deletion' ; ru = 'Выполняется поиск помеченных на удаление объектов'"));

	FullMarkedForDeletionTree();

	If NumberOfLevelsMarkedForDeletion = 1 Then
		For Each Item In MarkedForDeletionItemsTree.GetItems() Do
			RowID = Item.GetID();
			Items.MarkedForDeletionItemsTree.Expand(RowID, False);
		EndDo;
	EndIf;

EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ConfigureRecordingParameters(Command)
	UT_CommonClient.EditWriteSettings(ThisObject);
EndProcedure

&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) Экспорт
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// SERVICE PROCEDURES AND FUNCTIONS

&AtServer
Function ValueByType(Value)

	MetadataObject = Metadata.FindByType(TypeOf(Value));

	If MetadataObject <> Undefined And UT_Common.IsRegister(MetadataObject) Then

		List = New ValueList();
		List.Add(Value, MetadataObject.FullName());
		Возврат List;
	EndIf;

	Возврат Value;

EndFunction

&AtClient
Procedure OpenValueByType(Value)

	If TypeOf(Value) = Type("ValueList") Then
		ValueDescripton = Value.Get(0);

		FormParametrs = New Structure;
		FormParametrs.Insert("Key", ValueDescripton.Value);

		OpenForm(ValueDescripton.Presentation + ".RecordForm", FormParametrs, ThisForm);
	Else
		ShowValue(Undefined, Value);
	EndIf;

EndProcedure

&AtClient
Procedure UpdateContent(Result, ErrorMessage, DeletionObjectsTypes)

	If Result.Status Then
		For Each DeletionObjectType In DeletionObjectsTypes Do
			NotifyChanged(DeletionObjectType);
		EndDo;
	Else
		PageName = "SelectDeleteMode";
		ShowMessageBox( , ErrorMessage);
		Return;
	EndIf;

	UpdateMarkedTree = True;
	If NumberNotDeletedObjects = 0 Then
		If NumberDeletedObjects = 0 Then
			Text = Nstr("en = 'Not a single object is marked for deletion. Objects were not deleted.' ; 
							|ru = 'Не помечено на удаление ни одного объекта. Удаление объектов не выполнялось.'");
			UpdateMarkedTree = False;
		Else
			Text = StrTemplate(
			             Nstr("en = 'Deletion of marked objects has been completed successfully.Deleted objects: %1.'; 
			               |ru = 'Удаление помеченных объектов успешно завершено.
							  |Удалено объектов: %1.'"), NumberDeletedObjects);
		EndIf;
		PageName = "SelectDeleteMode";
		ShowMessageBox( , Text);
	Else
		PageName = "DeletionFailureReasonsPage";
		For Each Item In NotDeletedItemsTree.GetItems() Do
			RowId = Item.GetId();
			Items.NotDeletedItemsTree.Expand(RowId, False);
		EndDo;
		ShowMessageBox( , ResultLine);
	EndIf;

	If UpdateMarkedTree Then
		UpdateDeleteMarkedList(Undefined);
	EndIf;

EndProcedure

&AtClient
Procedure SwitchPage()
	If PageName <> "" Then
		Page = Items.Find(PageName);
		If Page <> Undefined Then
			Items.FormPages.CurrentPage = Page;
			UpdateAvailablButtons();
		EndIf;
		PageName = "";
	EndIf;
EndProcedure

&AtClient
Procedure UpdateAvailablButtons()

	CurrentPage = Items.FormPages.CurrentPage;

	If CurrentPage = Items.SelectDeleteMode Then
		Items.CommandBack.Enabled   = False;
		If DeletionMode = "Full" Then
			Items.CommandNext.Enabled   = False;
			Items.CommandDelete.Enabled = True;
		ElsIf DeletionMode = "Selective" Then
			Items.CommandNext.Enabled 	= True;
			Items.CommandDelete.Enabled = False;
		EndIf;
	ElsIf CurrentPage = Items.MarkedForDelete Then
		Items.CommandBack.Enabled   = True;
		Items.CommandNext.Enabled   = False;
		Items.CommandDelete.Enabled = True;
	ElsIf CurrentPage = Items.DeletionFailureReasonsPage Then
		Items.CommandBack.Enabled   = True;
		Items.CommandNext.Enabled   = False;
		Items.CommandDelete.Enabled = False;
	EndIf;

EndProcedure

// Returns the tree branch to the TreeRow branches by Value.
// If the branch is not found, a new one is created.
&AtServer
Function FindOrAddTreeBranch(TreeRows, Value, Presentation, Check)
	
	// Tring to find an exist branch in TreeRows whithout internal 
	Branch = TreeRows.Find(Value, "Value", False);

	If Branch = Undefined Then
		// There is no such branch, we will create a new one
		Branch = TreeRows.Add();
		Branch.Value      = ValueByType(Value);
		Branch.Presentation = Presentation;
		Branch.Check       = Check;
	EndIf;

	Возврат Branch;

EndFunction

&AtServer
Function FindOrAddTreeBranchWithPicture(TreeRows, Value, Presentation, PictureNumber)
	
	//Tring to find an exist branch in TreeRows whithout internal
	Branch = TreeRows.Find(Value, "Value", False);
	If Branch = Undefined Then
		// There is no such branch, we will create a new one
		Branch = TreeRows.Add();
		Branch.Value      = ValueByType(Value);
		Branch.Presentation = Presentation;
		Branch.PictureNumber = PictureNumber;
	EndIf;

	Возврат Branch;

EndFunction

// Returns marked for deletion objects. Select by filter is possible.
&AtServer
Function GetMarkedForDeletion()

	SetPrivilegedMode(True);
	MarkedArray = FindMarkedForDeletion();
	SetPrivilegedMode(False);

	Result = New Array;
	For Each MarkedItem In MarkedArray Do
		If AccessRight("InteractiveDeleteMarked", MarkedItem.Metadata()) Then
			Result.Add(MarkedItem);
		EndIf;
	EndDo;

	Возврат Result;

EndFunction
&AtServer
Procedure FullMarkedForDeletionTree()
	
	// Fulling a marked for deletion tree
	MarkedTree = FormAttributeToValue("MarkedForDeletionItemsTree");

	MarkedTree.Rows.Clear();
	
	// Processing marked
	MarkedArray = FindMarkedForDeletion();

	For Each MarkedArrayItem In MarkedArray Do
		MetadataObjectValue = MarkedArrayItem.Metadata().FullName();
		MetadataObjectPresentation = MarkedArrayItem.Metadata().Presentation();
		MetadataObjectRow = FindOrAddTreeBranch(MarkedTree.Rows, MetadataObjectValue,
			MetadataObjectPresentation, True);
		FindOrAddTreeBranch(MetadataObjectRow.Rows, MarkedArrayItem, String(
			MarkedArrayItem), True);
	EndDo;

	MarkedTree.Rows.Sort("Value", True);

	For Each MetadataObjectRow In MarkedTree.Rows Do
		// create a Presentation for rows displaying a branch of a metadata object
		MetadataObjectRow.Presentation = MetadataObjectRow.Presentation + " ("
			+ MetadataObjectRow.Rows.Count() + ")";
	EndDo;

	NumberOfLevelsMarkedForDeletion = MarkedTree.Rows.Count();

	ValueToFormAttribute(MarkedTree, "MarkedForDeletionItemsTree");

EndProcedure

&AtClient
Procedure SetMarkInList(Data, Check, CheckParent)
	
	// Install subordinate items
	RowItems = Data.GetItems();

	For Each Item In RowItems Do
		Item.Check = Check;
		SetMarkInList(Item, Check, False);
	EndDo;
	
	// Cheking the parent
	Parent = Data.GetParent();

	If CheckParent And Parent <> Undefined Then
		CheckParent(Parent);
	EndIf;

EndProcedure

&AtClient
Procedure CheckParent(Parent)

	ParentCheck = True;
	RowItems = Parent.GetItems();
	For Each Item In RowItems Do
		If Не Item.check Then
			Parentcheck = False;
			Break;
		EndIf;
	EndDo;
	Parent.check = Parentcheck;

EndProcedure

&AtServer
Function GetArrayMarkedForDeletion(MarkedForDeletionItems, DeletionMode)

	Deleted = New Array;

	If DeletionMode = "Full" Then
		// If deletion was completed, we get all a marked for deletion list
		Deleted = GetMarkedForDeletion();
	Else
		// We fill the array with references to the selected items marked for deletion
		MetadataRowCollection = MarkedForDeletionItems.GetItems();
		For Each MetadataObjectRow In MetadataRowCollection Do
			ReferenceRowCollection = MetadataObjectRow.GetItems();
			For Each ReferenceRow In ReferenceRowCollection Do
				If ReferenceRow.check Then
					Deleted.Add(ReferenceRow.Value);
				EndIf;
			EndDo;
		EndDo;
	EndIf;

	Возврат Deleted;

EndFunction
&AtServer
Procedure DeleteListedObjects(ListedObjects, Check, PreventingDeletion)
	If Check = True Then
		AllReferences= FindByRef(ListedObjects); //PreventingDeletion
		PreventingDeletion.Columns.Add("DeletionRef");
		PreventingDeletion.Columns.Add("DetectedRef");
		PreventingDeletion.Columns.Add("DetectedMetadata");

		For Each Ref In AllReferences Do
			DeletionRef =Ref[0];
			ObjectRef = Ref[1];
			MetadataObject=Ref[2];
			If DeletionRef = ObjectRef Then
				Continue;   // ссылается сам на себя
			Else
				Preventing=PreventingDeletion.Add();
				Preventing.DeletionRef=DeletionRef;
				Preventing.DetectedRef=ObjectRef;
				Preventing.DetectedMetadata=MetadataObject;
			EndIf;
		EndDo;
	Else
		DeleteObjects(ListedObjects, Check);//unconditional deletion
	EndIf;
EndProcedure
&AtServer
Function RunDocumentsDeletion(Знач DeletedArray, DeletedObjectsTypes)
	DeletionResult = New Structure("Status, Value", False, "");

	If Не UT_Users.IsFullUser() Then
		Raise NStr("en = 'Not enough permissions to perform the operation' ; ru = 'Недостаточно прав для выполнения операции.'");
	EndIf;

	DeletionObjectsTypes = New ValueTable;
	DeletionObjectsTypes.Columns.Add("Type", New TypeDescription("Type"));
	For Each DeletedObject In DeletedArray Do
		NewType = DeletionObjectsTypes.Add();
		NewType.Type = TypeOf(DeletedObject);
	EndDo;
	DeletionObjectsTypes.Groupby("Type");

	NotDeletedObjectsArray = New Array;

	Found = New ValueTable;
	Found.Columns.Add("DeletionRef");
	Found.Columns.Add("DetectedRef");
	Found.Columns.Add("DetectedMetadata");

	DeletedObjectsArray = New Array;
	For Each ObjectRef In DeletedArray Do
		DeletedObjectsArray.Add(ObjectRef);
	EndDo;

	MetadataInformationRegisters = Metadata.InformationRegisters;
	MetadataAccumulationRegisters = Metadata.AccumulationRegisters;
	MetadataAccountingRegisters = Metadata.AccountingRegisters;

	RefSearchExclusions = UT_Common.RefSearchExclusions();

	ExcludingMetadataObjectRules = New Map;

	While DeletedObjectsArray.Count() > 0 Do
		PreventingDeletion = New ValueTable;
		
		// Attempt to delete with reference integrity control.
		Try

			SetPrivilegedMode(True);
			DeleteListedObjects(DeletedObjectsArray, True, PreventingDeletion);
			SetPrivilegedMode(False);
		Except
//			SetPrivilegedMode(False);
			DeletionResult.Value = DetailErrorDescription(ИнформацияОбОшибке());
			Return DeletionResult;
		EndTry;

		NumberDeletedObjects = DeletedObjectsArray.Count();
		
		// Column names are set for the conflict tables that occurred during deletion.
		PreventingDeletion.Columns[0].Name = "DeletionRef";
		PreventingDeletion.Columns[1].Name = "DetectedRef";
		PreventingDeletion.Columns[2].Name = "DetectedMetadata";
		
		// We move deleted objects to the list  undeleted one 
		// and add found objects to the list by taking into account references
		// that were excluded
		For Each TableRow In PreventingDeletion Do
			ExcludedRefs = RefSearchExclusions[TableRow.DetectedMetadata];

			If ExcludedRefs = "*" Then
				Continue; // Can delete (a found metadata object does not interfere).
			EndIf;
			
			//	Looks for an excluding rule for a metadata object that interfere deletion
			//	For registers (so-called "non-object tables") - an array of attributes for search in a register record.
			// For reference types (so-called "object tables") - a ready-made query for search in attributes.  
			NameOfAttributesOrQuery = ExcludingMetadataObjectRules[TableRow.DetectedMetadata];
			If NameOfAttributesOrQuery = Undefined Then
				
				// We make an excluding rule
				ThisInformationRegister = MetadataInformationRegisters.Contains(TableRow.DetectedMetadata);
				If ThisInformationRegister Or MetadataAccountingRegisters.Contains(TableRow.DetectedMetadata) // IsAccountingRegister

					Or MetadataAccumulationRegisters.Contains(TableRow.DetectedMetadata) Then // IsAccumulationRegister

					NameOfAttributesOrQuery = New Array;
					If ThisInformationRegister Then
						For Each Dimension In TableRow.DetectedMetadata.Dimensions Do
							If Dimension.Master Then
								NameOfAttributesOrQuery.Add(Dimension.Name);
							EndIf;
						EndDo;
					Else
						For Each Dimension In TableRow.DetectedMetadata.Dimensions Do
							NameOfAttributesOrQuery.Add(Dimension.Name);
						EndDo;
					EndIf;

					If TypeOf(ExcludedRefs) = Type("Array") Then
						For Each AttributeName In ExcludedRefs Do
							If NameOfAttributesOrQuery.Find(AttributeName) = Undefined Then
								NameOfAttributesOrQuery.Add(AttributeName);
							EndIf;
						EndDo;
					EndIf;

				ElsIf TypeOf(ExcludedRefs) = Type("Array") Then

					QueryTexts = New Map;
					NameOfRootTable = TableRow.DetectedMetadata.FullName();

					For Each AttributeWay In ExcludedRefs Do
						PointPosition = Find(AttributeWay, ".");
						If PointPosition = 0 Then
							TableFullName = NameOfRootTable;
							AttributeName = AttributeWay;
						Else
							TableFullName = NameOfRootTable + "." + Left(AttributeWay, PointPosition - 1);
							AttributeName = Mid(AttributeWay, PointPosition + 1);
						EndIf;

						IncludedQueryText = QueryTexts.Получить(TableFullName);
						If IncludedQueryText = Undefined Then
							IncludedQueryText = "SELECT TOP 1
													 |	1
													 |FROM
													 |	" + TableFullName + " AS TABLE
																				 |WHERE
																				 |	Table.Ref = &DetectedRef
																				 |	And (";
						Else
							IncludedQueryText = IncludedQueryText + Chars.LF + Chars.Tab + Chars.Tab
								+ "OR ";
						EndIf;
						IncludedQueryText = IncludedQueryText + "Table." + AttributeName
							+ " = &DetectedRef";

						QueryTexts.Insert(TableFullName, IncludedQueryText);
					EndDo;

					QueryText = "";
					For Each KeyAndValue In QueryTexts Do
						If QueryText <> "" Then
							QueryText = QueryText + Chars.LF + Chars.LF + "UNION ALL" + Chars.LF
								+ Chars.LF;
						EndIf;
						QueryText = QueryText + KeyAndValue.Value + ")";
					EndDo;

					NameOfAttributesOrQuery = New Запрос;
					NameOfAttributesOrQuery.Text = QueryText;

				Else

					NameOfAttributesOrQuery = "";

				EndIf;

				ExcludingMetadataObjectRules.Insert(TableRow.DetectedMetadata,
					NameOfAttributesOrQuery);

			EndIf;
			
			// Checks an excluding rule.
			If TypeOf(NameOfAttributesOrQuery) = Type("Array") Then
				DeletedRefInExcludedAttribute = False;

				For Each AttributeName In NameOfAttributesOrQuery Do
					If TableRow.DetectedRef[AttributeName] = TableRow.DeletionRef Then
						DeletedRefInExcludedAttribute = True;
						Break;
					EndIf;
				EndDo;

				If DeletedRefInExcludedAttribute Then
					Continue; // Can delete (a found record does not interfere).
				EndIf;
			ElsIf TypeOf(NameOfAttributesOrQuery) = Type("Query") Then
				NameOfAttributesOrQuery.SetParameter("DeletionRef", TableRow.DeletionRef);
				NameOfAttributesOrQuery.SetParameter("DetectedRef", TableRow.DetectedRef);
				If Not NameOfAttributesOrQuery.Execute().IsEmpty() Then
					Continue; // Can delete (a found reference does not interfere).
				EndIf;
			EndIf;
			
			// All excluded rules were passed
			// Can not delete the object (The found reference or the register record interferes).
			// Removes deleted objects
			Index = DeletedObjectsArray.Find(TableRow.DeletionRef);
			If Index <> Undefined Then
				DeletedObjectsArray.Delete(Index);
			EndIf;
			
			// Adding undeleted objects.
			If NotDeletedObjectsArray.Find(TableRow.DeletionRef) = Undefined Then
				NotDeletedObjectsArray.Add(TableRow.DeletionRef);
			EndIf;
			
			// Adding found dependent objects
			NewRow = Found.Add();
			FillPropertyValues(NewRow, TableRow);

		EndDo;
		
		// Deletes without control, if the composition of the deleted objects has not been changed at this step of the cycle.
		If NumberDeletedObjects = DeletedObjectsArray.Count() Then
			Try
				//Delete objects without reference control
				SetPrivilegedMode(True);
				DeleteObjects(DeletedObjectsArray, False);
				SetPrivilegedMode(False);
			Except
				SetExclusiveMode(False);
				DeletionResult.Value = DetailErrorDescription(ErrorInfo());
				Возврат DeletionResult;
			Endtry;

			// Deleting everything that is possible was completed - exit the loop.
			Break;
		EndIf;
	EndDo;

	For Each NotDeletedObject In NotDeletedObjectsArray Do
		FoundRows = DeletionObjectsTypes.FindRows(New Structure("Type", TypeOf(NotDeletedObject)));
		If FoundRows.Count() > 0 Then
			DeletionObjectsTypes.Delete(FoundRows[0]);
		EndIf;
	EndDo;

	DeletedObjectsTypes = DeletionObjectsTypes.UnloadColumn("Type");

	SetExclusiveMode(False);

	Found.Columns.DeletionRef.Name        = "Ref";
	Found.Columns.DetectedRef.Name     = "Data";
	Found.Columns.DetectedMetadata.Name = "Metadata";

	DeletionResult.Status = True;
	DeletionResult.Value = New Structure("Found, NotDeleted", Found, NotDeletedObjectsArray);

	Возврат DeletionResult;
EndFunction
&AtServer
Procedure DeleteMarkedObjects(DeletionParameters, StorageAddress) 
	
	// Extracting the parameters
	MarkedForDeletionList	= DeletionParameters.MarkedForDeletionItemsTree;
	DeletionMode				= DeletionParameters.DeletionMode;
	DeletionObjectsTypes		= DeletionParameters.DeletionObjectsTypes;

	DeletedItems = GetArrayMarkedForDeletion(MarkedForDeletionList, DeletionMode);
	NumberDeleted = DeletedItems.Count();
	
	// Do Deletion
	Result = RunDocumentsDeletion(DeletedItems, DeletionObjectsTypes);
	
	// Add parameters 
	If TypeOf(Result.Value) = Type("Structure") Then
		NumberNotDeletedObjects = Result.Value.NotDeleted.Count();
	Else
		NumberNotDeletedObjects = 0;
	EndIf;
	Result.Insert("NumberNotDeletedObjects", NumberNotDeletedObjects);
	Result.Insert("NumberDeleted", NumberDeleted);
	Result.Insert("DeletionObjectsTypes", DeletionObjectsTypes);

	PutToTempStorage(Result, StorageAddress);

EndProcedure
// Attempts to delete the selected objects.
// Not deleted objects are shown in another table
&AtServer
Function DeletionMarkedAtServer(DeletionObjectsTypes)

	DeletionParameters = New Structure("MarkedForDeletionItemsTree, DeletionMode, DeletionObjectsTypes, ",
		MarkedForDeletionItemsTree, DeletionMode, DeletionObjectsTypes);

	StorageAddress = PutToTempStorage(Undefined, UUID);
	DeleteMarkedObjects(DeletionParameters, StorageAddress);
	Result = New Structure("JobCompleted", True);

	If Result.JobCompleted Then
		Result = FillResults(StorageAddress, Result);
	EndIf;

	Возврат Result;

EndFunction

&AtServer
Function FillResults(StorageAddress, Result)

	DeletionResult = GetFromTempStorage(StorageAddress);
	If Не DeletionResult.Status Then
		Result.Insert("DeletionResult", DeletionResult);
		Result.Insert("ErrorMessage", DeletionResult.Value);
		Return Result;
	EndIf;

	Tree = FillTreeOfRemainingObjects(DeletionResult);
	ValueToFormAttribute(Tree, "NotDeletedItemsTree");

	NumberDeleted 			= DeletionResult.NumberDeleted;
	NumberNotDeletedObjects 	= DeletionResult.NumberNotDeletedObjects;
	FillResultsLine(NumberDeleted);

	If TypeOf(DeletionResult.Value) = Type("Structure") Then
		DeletionResult.Delete("Value");
	EndIf;

	Result.Insert("DeletionResult", DeletionResult);
	Result.Insert("ErrorMessage", "");
	Возврат Result;

EndFunction

//@skip-warning
&AtClient
Procedure Attachable_CheckTaskCompletion()

	Try
		If Items.FormPages.CurrentPage = Items.TimeConsumingOperationPage Then
			If JobCompleted(ScheduledJobID) Then
				Result = FillResults(StorageAddress, New Structure);
				//@skip-warning
				DeletionObjectsTypes = Undefined;
				UpdateContent(Result.DeletionResult, Result.DeletionResult.Value,
					Result.DeletionResult.DeletionObjectsTypes);
			Else
				UT_TimeConsumingOperationsClient.UpdateIdleHandlerParameters(IdleHandlerParameters);
				AttachIdleHandler(
					"Attachable_CheckTaskCompletion", IdleHandlerParameters.CurrentInterval, True);
			EndIf;
		EndIf;
	Except
		Raise;
	EndTry;

EndProcedure

&AtServerNoContext
Function JobCompleted(ScheduledJobID)

	Возврат UT_TimeConsumingOperations.JobCompleted(ScheduledJobID);

EndFunction

&AtServer
Function FillTreeOfRemainingObjects(Result)

	Found   = Result.Value.Found;
	NotDeleted = Result.Value.NotDeleted;

	NumberNotDeletedObjects = NotDeleted.Count();
	
	// Creates a table not deleted ojects
	NotDeletedItemsTree.GetItems().Clear();

	Tree = FormAttributeToValue("NotDeletedItemsTree");

	For Each FoundItem In Found Do
		NotDeleted = FoundItem[0];
		Referencing = FoundItem[1];
		ReferencingMetadataObject = FoundItem[2].Presentation();
		ValueOfNotDeledetMetadataObject  = NotDeleted.Metadata().FullName();
		PresentationOfNotDeledetMetadataObject = NotDeleted.Metadata().Presentation();
		//a metadata branch
		MetadataObjectRow = FindOrAddTreeBranchWithPicture(Tree.Rows,
			ValueOfNotDeledetMetadataObject, PresentationOfNotDeledetMetadataObject, 0);
		//a non-deleted object branch
		ReferenceRowToNonDeletedDBObject = FindOrAddTreeBranchWithPicture(MetadataObjectRow.Rows,
			NotDeleted, String(NotDeleted), 2);
		//a branch of a reference non-deleted object
		FindOrAddTreeBranchWithPicture(ReferenceRowToNonDeletedDBObject.Rows, Referencing, String(
			Referencing) + " - " + ReferencingMetadataObject, 1);
	EndDo;

	Tree.Rows.Sort("Value", True);

	Возврат Tree;

EndFunction

&AtServer
Procedure FillResultsLine(NumberDeleted)


	NumberDeletedObjects = NumberDeleted - NumberNotDeletedObjects;

	If NumberDeletedObjects = 0 Then
		ResultLine = Nstr(
			"en = 'None of the objects has been deleted, since there are references to the  deleted objects in the information databas'; 
			|ru = 'Не удален ни один из объектов, так как в информационной базе существуют ссылки на удаляемые объекты'");
	Else
		ResultLine = StrTemplate(
				Nstr("en = 'The removal of the marked objects is completed. Deleted objects: %1.';
				|ru = 'Удаление помеченных объектов завершено. Удалено объектов: %1.'"),
				 String(NumberDeletedObjects));
	EndIf;

	If NumberNotDeletedObjects > 0 Then
		ResultLine = ResultLine + Chars.LF + StrTemplate(
				Nstr("en = 'No objects deleted: %1.
					|The objects have not been deleted to preserve the integrity of the information base, because there are still references to them.
					|Click OK to view the list of remaining (not deleted) objects'
					|;
					|ru = 'Не удалено объектов: %1.
					 |Объекты не удалены для сохранения целостности информационной базы, т.к. на них еще имеются ссылки.
					 |Нажмите ОК для просмотра списка оставшихся (не удаленных) объектов.'"), String(
			NumberNotDeletedObjects));
	EndIf;

EndProcedure