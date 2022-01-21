#If Server Or ThickClientOrdinaryApplication Or ExternalConnection Then

#Region Private

////////////////////////////////////////////////////////////////////////////////
// Interactive deletion of marked objects.

// Deletes marked objects. It is used upon deleting objects in a background job interactively.
//
// Parameters:
//   ExecutionParameters - Structure - parameters required for deletion.
//   StorageAddress - String - a temporary storage address.
//
Procedure DeleteMarkedObjectsInteractively(ExecutionParameters, StorageAddress) Export
	DeleteMarkedObjects(ExecutionParameters);
	PutToTempStorage(ExtractResult(ExecutionParameters), StorageAddress);
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Deletion of marked objects from a scheduled job.

// Deletes marked objects from a scheduled job.
Procedure DeleteMarkedObjectsFromScheduledJob() Export

	ExecutionParameters = New Structure;
	DeleteMarkedObjects(ExecutionParameters);

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Initialization and startup.

// The main mechanics of deleting marked objects.InitializeParameters
Procedure DeleteMarkedObjects(ExecutionParameters)
	
	If NOT UT_Users.IsFullUser() Then
		Raise NStr("ru = 'Недостаточно прав для выполнения операции.'; en = 'Insufficient rights to perform the operation.'");
	EndIf;
	
	InitializeParameters(ExecutionParameters);
	
	If ExecutionParameters.SearchMarked Then
		GetItemsMarkedForDeletion(ExecutionParameters);
	EndIf;
	
	If Not ExecutionParameters.DeleteMarked Then
		Return;
	EndIf;

	If ExecutionParameters.Interactive	AND ExecutionParameters.AllObjectsMarkedForDeletion.Count() = 0 Then
		Return; // Do not delete technological objects on interactive startup if there are no user objects.
	EndIf;

	If ExecutionParameters.Exclusive Then
		DeleteMarkedObjectsExclusively(ExecutionParameters);
	Else // Not exclusive.
		DeleteMarkedObjectsCompetitively(ExecutionParameters);
	EndIf;

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Competitive deletion of marked objects.

// Main mechanics.
Procedure DeleteMarkedObjectsCompetitively(ExecutionParameters)
	SetPrivilegedMode(True);
	
	// Deletion of technological objects (that are created and marked for deletion without user participation).
	If ExecutionParameters.TechnologicalObjects <> Undefined Then
		MarkCollectionTraversalStart(ExecutionParameters, "TechnologicalObjects");
		For Each Ref In ExecutionParameters.TechnologicalObjects Do
			DeleteReference(ExecutionParameters, Ref); // The result is not displayed for technological objects.
			MarkCollectionTraversalProgress(ExecutionParameters, "TechnologicalObjects");
		EndDo;
	EndIf;
	
	// Deletion of objects marked for deletion.
	MarkCollectionTraversalStart(ExecutionParameters, "UserObjects");
	For Each Ref In ExecutionParameters.UserObjects Do
		Result = DeleteReference(ExecutionParameters, Ref);
		RegisterDeletionResult(ExecutionParameters, Ref, Result, "UserObjects");
		MarkCollectionTraversalProgress(ExecutionParameters, "UserObjects");
	EndDo;
	
	// Deletion of chains (straight-line linked objects).
	MarkCollectionTraversalStart(ExecutionParameters, "ToRedelete");
	While ExecutionParameters.ToRedelete.Count() > 0 Do
		Ref = ExecutionParameters.ToRedelete[0];
		ExecutionParameters.ToRedelete.Delete(0);
		
		Result = DeleteReference(ExecutionParameters, Ref);
		RegisterDeletionResult(ExecutionParameters, Ref, Result, "ToRedelete");
		MarkCollectionTraversalProgress(ExecutionParameters, "ToRedelete");
	EndDo;
	
	// Deletion of cycles (ring object links).
	DeleteRemainingObjectsInOneTransaction(ExecutionParameters);
	
	// Clear from spam.
	ClearLinksFromReferenceSearchExceptions(ExecutionParameters);
	
EndProcedure

// Deletion of a single object with result control and transaction rollback in case of failure.
Function DeleteReference(ExecutionParameters, Ref)
	Result = New Structure; // Результат обрабатывается в ЗарегистрироватьРезультатУдаления().
	Result.Insert("Success", Undefined);
	Result.Insert("ErrorInfo", Undefined);
	Result.Insert("ItemsPreventingDeletion", Undefined);
	Result.Insert("NestedAndSubordinateObjects", New Array);
	Result.Insert("Count", 0);
	Result.Insert("Messages", Undefined);

	Information = GenerateTypesInformation(ExecutionParameters, TypeOf(Ref));

	BeginTransaction();
	Try
		TryToDeleteReference(ExecutionParameters, Ref, Information, Result);
		If Result.Success Then
			CommitTransaction();
		Else
			RollbackTransaction();
		EndIf;
	Except
		RollbackTransaction();
		Result.Success = False;
		Result.ErrorInfo = ErrorInfo();
	EndTry;;
	Result.Messages = UT_TimeConsumingOperations.UserMessages(True);

	If Not Result.Success Then
		WriteWarning(Ref, Result.ErrorInfo);
	EndIf;

	If TypeOf(Result.ItemsPreventingDeletion) = Type("ValueTable") Then
		Result.ItemsPreventingDeletion.Columns[0].Name = "ItemToDeleteRef";
		Result.ItemsPreventingDeletion.Columns[1].Name = "FoundItemReference";
		Result.ItemsPreventingDeletion.Columns[2].Name = "FoundMetadata";
		For Each FoundItemReference In Result.NestedAndSubordinateObjects Do
			TableRow = Result.ПреItemsPreventingDeletionбавить();
			TableRow.ItemToDeleteRef        = Ref;
			TableRow.FoundItemReference     = FoundItemReference;
		EndDo;
	EndIf;

	Return Result;
EndFunction

// Mechanics of deleting an object and finding links.
Procedure TryToDeleteReference(ExecutionParameters, Ref, Information, Result)
	Lock = New DataLock;
	LockItem = Lock.Add(Information.FullName);
	LockItem.SetValue("Ref", Ref);
	Lock.Lock();
	
	Object = Ref.GetObject();
	If Object = Undefined Then
		Result.Success = True; // Object has already been deleted.
		Return;
	EndIf;
	If Object.DeletionMark <> True Then
		Result.Success = False;
		Result.ErrorInfo = NStr("ru = 'Объект не помечен на удаление.'; en = 'The Object is not marked for deletion.'");
		Return;
	EndIf;

	FindChildAndSubordinateObjects(ExecutionParameters, Ref, Information, Result);

	Object.Delete();

	FindItemsPreventingDeletion(ExecutionParameters, Ref, Information, Result);

	If Result.Count = 0 Then
		Result.Success = True;
	Else
		Result.Success = False;
		Result.ErrorInfo = NStr("ru = 'Объект используется в других объектах программы.'; en = 'Object is in use by other application objects.'");
	EndIf;
EndProcedure

// Search for references to nested and subordinate objects (hierarchy and link by an owner). Executed before deletion.
Procedure FindChildAndSubordinateObjects(ExecutionParameters, Ref, Information, Result)

	If Information.Hierarchical Then
		Query = New Query(Information.QueryTextByHierarchy);
		Query.SetParameter("ItemToDeleteRef", Ref);
		NestedObjects = Query.Execute().Unload();
		For Each TableRow In NestedObjects Do
			Result.NestedAndSubordinateObjects.Add(TableRow.Ref);
		EndDo;
		Result.Count = Result.Count + NestedObjects.Count();
	EndIf;

	If Information.HasSubordinate Then
		Query = New Query(Information.QueryTextBySubordinated);
		Query.SetParameter("ItemToDeleteRef", Ref);
		SubordinateObjects = Query.Execute().Unload();
		For Each TableRow In SubordinateObjects Do
			Result.NestedAndSubordinateObjects.Add(TableRow.Ref);
		EndDo;
		Result.Count = Result.Count + SubordinateObjects.Count();
	EndIf;

EndProcedure

// Search for references by scanning all tables. Executed after deletion.
Procedure FindItemsPreventingDeletion(ExecutionParameters, Ref, Information, Result)

	RefsSearch = New Array;
	RefsSearch.Add(Ref);

	ItemsPreventingDeletion = FindByRef(RefsSearch);
	
	// Skip references from sequence boundaries.
	Count = ItemsPreventingDeletion.Count();
	ColumnName = ItemsPreventingDeletion.Columns[1].Name;
	For Number = 1 To Count Do
		ReverseIndex = Count - Number;
		TableRow = ItemsPreventingDeletion[ReverseIndex];
		PreventingReference = TableRow[ColumnName];
		If PreventingReference = Ref Or DocumentAlreadyDeleted(ExecutionParameters, PreventingReference) Then
			ItemsPreventingDeletion.Delete(TableRow);
		EndIf;
	EndDo;
	
	// Registration of the result.
	Result.ItemsPreventingDeletion = ItemsPreventingDeletion;
	Result.Count = Result.Count + Result.ItemsPreventingDeletion.Count();

EndProcedure

// Search for reference to the document in the database.
Function DocumentAlreadyDeleted(ExecutionParameters, Ref)
	If Ref = Undefined Then
		Return False; // Not a document.
	EndIf;
	Information = GenerateTypesInformation(ExecutionParameters, TypeOf(Ref));
	If Information.Kind <> "DOCUMENT" Then
		Return False; // Not a document.
	EndIf;
	Query = New Query("SELECT TOP 1 1 FROM " + Information.FullName + " WHERE Ref = &Ref");
	Query.SetParameter("Ref", Ref);
	Return Query.Execute().IsEmpty();
EndFunction

// Deletion of cycles (ring object links).
Procedure DeleteRemainingObjectsInOneTransaction(ExecutionParameters)
	
	// 1. Objects that cannot be deleted are got by determining unresolvable links.
	ObjectsThatCannotBeDeleted = New Array;
	NestedUnresolvableLinks = New Array;
	
	For Each Preventing In ExecutionParameters.ItemsPreventingDeletion Do
			// 1.1. The fact that the object preventing deletion is not a register serves as a criterion for 
			// determining unresolvable links. In case of registers, we assume that register entries will be 
			// deleted automatically upon deleting an object in its leading dimension.
		If Preventing.FoundType <> Type("String") And Not UT_Common.IsRefTypeObject(
			Metadata.FindByType(Preventing.FoundType)) Then
			Continue;
		EndIf;
		// 1.2. We also assume that object preventing deletion is not marked for deletion.
		If ExecutionParameters.NotDeletedItems.Find(Preventing.FoundItemReference) = Undefined
			AND ObjectsThatCannotBeDeleted.Find(Preventing.ItemToDeleteRef) = Undefined Then
			ObjectsThatCannotBeDeleted.Add(Preventing.ItemToDeleteRef);
			FoundItems = ExecutionParameters.ItemsPreventingDeletion.FindRows(New Structure("FoundItemReference", Preventing.ItemToDeleteRef));
			NestedUnresolvableLinks.Add(FoundItems);
		EndIf;
	EndDo;
	
	// 1.3. Then, using the NestedUnresolvableLinks array, get unresolvable subordinate links - "links 
	// of links", "links of links of links", and so on ...
	Index = 0;
	While Index < NestedUnresolvableLinks.Count() Do
		FoundItems = NestedUnresolvableLinks[Index];
		Index = Index + 1;
		For Each Preventing In FoundItems Do
			If ObjectsThatCannotBeDeleted.Find(Preventing.ItemToDeleteRef) = Undefined Then
				ObjectsThatCannotBeDeleted.Add(Preventing.ItemToDeleteRef);
				FoundItems = ExecutionParameters.ItemsPreventingDeletion.FindRows(New Structure("FoundItemReference", Preventing.ItemToDeleteRef));
				NestedUnresolvableLinks.Add(FoundItems);
			EndIf;
		EndDo;
	EndDo;
	
	// 2. Objects that you can try to delete in one transaction.
	//    = Array of objects to delete - an array of objects that cannot be deleted.
	ObjectsToDelete = New Array;
	For Each NotDeletedObject In ExecutionParameters.NotDeletedItems Do
		If ObjectsThatCannotBeDeleted.Find(NotDeletedObject) = Undefined Then
			ObjectsToDelete.Add(NotDeletedObject);
		EndIf;
	EndDo;
	
	Count = ObjectsToDelete.Count();
	If Count = 0 Then
		Return; // There are no objects for deletion.
	EndIf;
	
	// 3. Include all objects in one transaction and try to delete them.
	Success = False;
	BeginTransaction();
	Try
		For Number = 1 To Count Do
			ReverseIndex = Count - Number;
			NotDeletedObject = ObjectsToDelete[ReverseIndex];
			
			Information = GenerateTypesInformation(ExecutionParameters, TypeOf(NotDeletedObject));
			
			Lock = New DataLock;
			LockItem = Lock.Add(Information.FullName);
			LockItem.SetValue("Ref", NotDeletedObject);
			Lock.Lock();
			
			Object = NotDeletedObject.GetObject();
			If Object = Undefined Then // Object has already been deleted.
				Continue;
			EndIf;
			If Object.DeletionMark <> True Then
				ObjectsToDelete.Delete(ReverseIndex); // Object is no longer marked for deletion.
				Continue;
			EndIf;
			
			Object.Delete();
		EndDo;
		NotDeletedObject = Undefined;

		If ObjectsToDelete.Count() > 0 Then
			ItemsPreventingDeletion = FindByRef(ObjectsToDelete);

			ColumnName = ItemsPreventingDeletion.Columns[1].Name;
			For Each NotDeletedObject In ObjectsToDelete Do
				SearchForNotPreventingItems = New Structure(ColumnName, NotDeletedObject);
				NotPreventingItems = ItemsPreventingDeletion.FindRows(SearchForNotPreventingItems);
				For Each Preventing In NotPreventingItems Do
					ItemsPreventingDeletion.Delete(Preventing);
				EndDo;
			EndDo;
			
			If ItemsPreventingDeletion.Count() = 0 Then
				Success = True;
			EndIf;
		EndIf;
		
		If Success Then
			CommitTransaction();
		Else
			RollbackTransaction();
		EndIf;
		
	Except
		RollbackTransaction();
		Success = False;
		WriteWarning(NotDeletedObject, ErrorInfo());
	EndTry;
	
	// 4. Register the result (if success).
	If Success Then
		For Each NotDeletedObject In ObjectsToDelete Do
			// Register the reference in the collection of deleted objects.
			If ExecutionParameters.DeletedItems.Find(NotDeletedObject) = Undefined Then
				ExecutionParameters.DeletedItems.Add(NotDeletedObject);
			EndIf;
			
			// Delete the reference from the collection of not deleted objects.
			Index = ExecutionParameters.NotDeletedItems.Find(NotDeletedObject);
			If Index <> Undefined Then
				ExecutionParameters.NotDeletedItems.Delete(Index);
			EndIf;
			
			// Clear information about links "from" deleted objects.
			FoundItems = ExecutionParameters.ItemsPreventingDeletion.FindRows(New Structure("ItemToDeleteRef", NotDeletedObject));
			For Each Preventing In FoundItems Do
				ExecutionParameters.ItemsPreventingDeletion.Delete(Preventing);
			EndDo;
			
			// Clear information about links "to" deleted objects.
			FoundItems = ExecutionParameters.ItemsPreventingDeletion.FindRows(New Structure("FoundItemReference", NotDeletedObject));
			For Each Preventing In FoundItems Do
				ExecutionParameters.ItemsPreventingDeletion.Delete(Preventing);
			EndDo;
		EndDo;
	EndIf;
EndProcedure

// Clearing reasons for not deleting objects from reference search exceptions.
//   It is applied upon real-time deletion of marked objects to delete duplicate links form the result.
Procedure ClearLinksFromReferenceSearchExceptions(ExecutionParameters)
	If Not ExecutionParameters.Property("RefSearchExclusions") Then
		ExecutionParameters.Insert("RefSearchExclusions", UT_Common.RefSearchExclusions());
	EndIf;
	If Not ExecutionParameters.Property("ExcludingRules") Then
		ExecutionParameters.Insert("ExcludingRules", New Map); // Cache of search exceptions rules.
	EndIf;
	
	ObjectsWithNonExceptions = New Map;
	ObjectsWithExceptionsOnly = New Map;
	
	// Define spam.
	ItemsPreventingDeletion = ExecutionParameters.ItemsPreventingDeletion;
	ItemsPreventingDeletion.Columns.Add("IsException", New TypeDescription("Boolean"));
	For Each Reason In ItemsPreventingDeletion Do
		If Reason.FoundType <> Type("String")Then
			FoundMetadata = Metadata.FindByType(Reason.FoundType);
			Reason.IsException = LinkInReferencesSearchExceptions(ExecutionParameters, FoundMetadata, Reason);
		EndIf;
		If Reason.IsException Then
			If ObjectsWithNonExceptions[Reason.ItemToDeleteRef] = Undefined Then
				ObjectsWithExceptionsOnly.Insert(Reason.ItemToDeleteRef, True);
			EndIf;
		Else
			ObjectsWithNonExceptions.Insert(Reason.ItemToDeleteRef, True);
			ObjectsWithExceptionsOnly.Delete(Reason.ItemToDeleteRef);
		EndIf;
	EndDo;
	
	// If nothing left, except for spam, this means that a developer forgot to add auto-clearing upon 
	// deleting an object.
	// In such rare cases, you can display "spam" instead of a blank list of reasons.
	For Each KeyAndValue In ObjectsWithExceptionsOnly Do
		FoundItems = ItemsPreventingDeletion.FindRows(New Structure("ItemToDeleteRef", KeyAndValue.Key));
		For Each Reason In FoundItems Do
			Reason.IsException = False;
		EndDo;
	EndDo;
	
	// Delete spam.
	FoundItems = ItemsPreventingDeletion.FindRows(New Structure("IsException", True));
	For Each Reason In FoundItems Do
		ItemsPreventingDeletion.Delete(Reason);
	EndDo;
// Exclude objects previously deleted in this transaction.	
	ItemsPreventingDeletion.Columns.Delete("IsException");
	ExecutionParameters.Delete("RefSearchExclusions");
	ExecutionParameters.Delete("ExcludingRules");
EndProcedure

// Register the deletion result and fill the ToRedelete collection.
Procedure RegisterDeletionResult(ExecutionParameters, Ref, Result, CollectionName)
	// The result is generated as DeleteReference(). 
	If Result.Success Then
		// Register the reference in the collection of deleted objects.
		ExecutionParameters.DeletedItems.Add(Ref);
		
		// Exclude the deleted object from reasons for not deleting other objects. Search.
		IrrelevantReasons = ExecutionParameters.ItemsPreventingDeletion.FindRows(New Structure("FoundItemReference", Ref));
		For Each Reason In IrrelevantReasons Do
			// Delete a reason for not deleting another object.
			ItemToDeleteRef = Reason.ItemToDeleteRef;
			ExecutionParameters.ItemsPreventingDeletion.Delete(Reason);
			// Search for other reasons for not deleting another object.
			If ExecutionParameters.ItemsPreventingDeletion.Find(ItemToDeleteRef, "ItemToDeleteRef") = Undefined Then
				// All reasons for not deleting another object are eliminated.
				// Register another object for redeletion.
				ExecutionParameters.ToRedelete.Add(ItemToDeleteRef);
				If CollectionName = "ToRedelete" AND ExecutionParameters.Interactive Then
					ExecutionParameters.Total = ExecutionParameters.Total + 1;
				EndIf;
				// Clear a record about another object from the NotDeletedItems collection.
				Index = ExecutionParameters.NotDeletedItems.Find(ItemToDeleteRef);
				If Index <> Undefined Then
					ExecutionParameters.NotDeletedItems.Delete(Index);
				EndIf;
			EndIf;
		EndDo;

	Else // Unsuccessful.

		ExecutionParameters.NotDeletedItems.Add(Ref);

		If TypeOf(Result.ErrorInfo) = Type("ErrorInfo")
			Or Result.ItemsPreventingDeletion = Undefined Then // Error text
			If TypeOf(Result.ErrorInfo) = Type("ErrorInfo") Then
				ErrorText = BriefErrorDescription(Result.ErrorInfo);
				More    = DetailErrorDescription(Result.ErrorInfo);
			Else
				ErrorText = Result.ErrorInfo;
				More    = "";
			EndIf;
			For Each MessageFromObject In Result.Messages Do
				ErrorText = TrimR(ErrorText + Chars.LF + Chars.LF + TrimL(MessageFromObject.Text));
				More    = TrimR(More + Chars.LF + Chars.LF + TrimL(MessageFromObject.Text));
			EndDo;
			Reason = ExecutionParameters.ItemsPreventingDeletion.Add();
			Reason.ItemToDeleteRef    = Ref;
			Reason.TypeToDelete       = TypeOf(Reason.ItemToDeleteRef);
			Reason.FoundItemReference = ErrorText;
			Reason.FoundType    = Type("String");
			Reason.More           = More;
			GenerateTypesInformation(ExecutionParameters, Reason.TypeToDelete);
		Else // Register links (reasons for not deleting) to display them to the user.
			For Each TableRow In Result.ItemsPreventingDeletion Do
				WriteReasonToResult(ExecutionParameters, TableRow);
			EndDo;
		EndIf;

	EndIf; // Result.Success.
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Exclusive deletion of marked objects.

// The main mechanics of deleting marked objects.
Procedure DeleteMarkedObjectsExclusively(ExecutionParameters)
	
	If Not ExecutionParameters.Property("RefSearchExclusions") Then
		ExecutionParameters.Insert("RefSearchExclusions", UT_Common.RefSearchExclusions());
	EndIf;
	If Not ExecutionParameters.Property("ExcludingRules") Then
		ExecutionParameters.Insert("ExcludingRules", New Map); // Cache of search exceptions rules.
	EndIf;
	
	ObjectsToDelete = ExecutionParameters.AllObjectsMarkedForDeletion;
	
	While ObjectsToDelete.Count() > 0 Do
		
		MarkCollectionTraversalStart(ExecutionParameters, "ExclusiveDeletion");
		
		ItemsPreventingDeletion = New ValueTable;
		
		// Attempt to delete objects with reference integrity control.
		SetPrivilegedMode(True);
		DeleteObjects(ObjectsToDelete, True, ItemsPreventingDeletion);
		SetPrivilegedMode(False);
		
		If ItemsPreventingDeletion.Columns.Count() < 3 Then
			Raise NStr("ru = 'Не удалось выполнить удаление объектов.'; en = 'Cannot delete objects.'");
		EndIf;
		
		// Assign column names to the table of conflicts occurred upon deletion.
		ItemsPreventingDeletion.Columns[0].Name = "ItemToDeleteRef";
		ItemsPreventingDeletion.Columns[1].Name = "FoundItemReference";
		ItemsPreventingDeletion.Columns[2].Name = "FoundMetadata";
		
		AllLinksInExceptions = True;
		
		// Analyze reasons for non-deletion (locations where objects marked for deletion are used).
		MarkCollectionTraversalStart(ExecutionParameters, "ItemsPreventingDeletion", ItemsPreventingDeletion);
		For Each TableRow In ItemsPreventingDeletion Do
			MarkCollectionTraversalProgress(ExecutionParameters, "ItemsPreventingDeletion");
			
			// Check excluding rights.
			If LinkInReferencesSearchExceptions(ExecutionParameters, TableRow.FoundMetadata,
				TableRow) Then
				Continue; // The link does not prevent deletion.
			EndIf;
			
			// Cannot delete the object (a detected reference or register record prevents deletion).
			AllLinksInExceptions = False;
			
			// Reduce objects to be deleted.
			Index = ObjectsToDelete.Find(TableRow.ItemToDeleteRef);
			If Index <> Undefined Then
				ObjectsToDelete.Delete(Index);
			EndIf;
			
			// Register the link to display it to the user.
			WriteReasonToResult(ExecutionParameters, TableRow);
		EndDo;
		
		// Delete objects without control if all the links are in reference search exceptions.
		If AllLinksInExceptions Then
			SetPrivilegedMode(True);
			DeleteObjects(ObjectsToDelete, False);
			SetPrivilegedMode(False);
			Break; // Exit the loop.
		EndIf;
	EndDo;
	
	ExecutionParameters.Insert("DeletedItems", ObjectsToDelete);
	ExecutionParameters.Delete("RefSearchExclusions");
	ExecutionParameters.Delete("ExcludingRules");

EndProcedure

// Checks whether the link is in exceptions.
Function LinkInReferencesSearchExceptions(ExecutionParameters, FoundMetadata, TableRow)
	// Define an excluding rule for a metadata object that prevents deletion:
	// For registers (the so-called non-object tables) - attributes array for search in a register record. 
	// For reference types (the so-called object tables) - a ready-to-use query for search in attributes.
	Rule = ExecutionParameters.ExcludingRules[FoundMetadata]; // Cache.
	If Rule = Undefined Then
		Rule = GenerateExcludingRule(ExecutionParameters, FoundMetadata);
		ExecutionParameters.ExcludingRules.Insert(FoundMetadata, Rule);
	EndIf;
	
	// Check the excluding rule.
	If Rule = "*" Then
		Return True; // The object can be deleted (a detected metadata object does not prevent deletion).
	ElsIf TypeOf(Rule) = Type("Array") Then // Register dimensions names.
		For Each AttributeName In Rule Do
			If TableRow.FoundItemReference[AttributeName] = TableRow.ItemToDeleteRef Then
				Return True; // The object can be deleted (a detected register record does not prevent deletion).
			EndIf;
		EndDo;
	ElsIf TypeOf(Rule) = Type("Query") Then // Query to a reference object.
		Rule.SetParameter("ItemToDeleteRef", TableRow.ItemToDeleteRef);
		Rule.SetParameter("FoundItemReference", TableRow.FoundItemReference);
		If Not Rule.Execute().IsEmpty() Then
			Return True; // The object can be deleted (a detected reference does not prevent deletion).
		EndIf;
	EndIf;
	
	Return False;
EndFunction

// Composes the rule optimally for checking.
Function GenerateExcludingRule(ExecutionParameters, FoundMetadata)
	SearchException = ExecutionParameters.RefSearchExclusions[FoundMetadata];
	If SearchException = "*" Then
		Return "*"; // The object can be deleted (a detected metadata object does not prevent deletion).
	EndIf;
	
	// Generate an excluding rule.
	IsInformationRegister = Metadata.InformationRegisters.Contains(FoundMetadata);
	If IsInformationRegister
		Or Metadata.AccountingRegisters.Contains(FoundMetadata) // IsAccountingRegister
		Or Metadata.AccumulationRegisters.Contains(FoundMetadata) Then // IsAccumulationRegister
		
		Rule = New Array;
		If IsInformationRegister Then
			For Each Dimension In FoundMetadata.Dimensions Do
				If Dimension.Master Then
					Rule.Add(Dimension.Name);
				EndIf;
			EndDo;
		Else
			For Each Dimension In FoundMetadata.Dimensions Do
				Rule.Add(Dimension.Name);
			EndDo;
		EndIf;
		
		If TypeOf(SearchException) = Type("Array") Then
			For Each AttributeName In SearchException Do
				If Rule.Find(AttributeName) = Undefined Then
					Rule.Add(AttributeName);
				EndIf;
			EndDo;
		EndIf;
		
	ElsIf TypeOf(SearchException) = Type("Array") Then
		
		QueriesTexts = New Map;
		RootTableName = FoundMetadata.FullName();
		
		For Each AttributePath In SearchException Do
			PointPosition = StrFind(AttributePath, ".");
			If PointPosition = 0 Then
				FullTableName = RootTableName;
				AttributeName = AttributePath;
			Else
				FullTableName = RootTableName + "." + Left(AttributePath, PointPosition - 1);
				AttributeName = Mid(AttributePath, PointPosition + 1);
			EndIf;
			
			NestedQueryText = QueriesTexts.Get(FullTableName);
			If NestedQueryText = Undefined Then
				NestedQueryText = "SELECT TOP 1
										 |	1
										 |FROM
										 |	" + FullTableName + " AS Table
										 							|WHERE
																	|	Table.Ref = &FoundItemReference
																	|	AND (";
			Else
				NestedQueryText = NestedQueryText + Chars.LF + Chars.Tab + Chars.Tab + "OR ";
			EndIf;
			NestedQueryText = NestedQueryText + "Table." + AttributeName + " = &ItemToDeleteRef";
			
			QueriesTexts.Insert(FullTableName, NestedQueryText);
		EndDo;
		
		QueryText = "";
		For Each KeyAndValue In QueriesTexts Do
			If QueryText <> "" Then
				QueryText = QueryText + Chars.LF + Chars.LF + "UNION ALL" + Chars.LF + Chars.LF;
			EndIf;
			QueryText = QueryText + KeyAndValue.Value + ")";
		EndDo;
		
		Rule = New Query;
		Rule.Text = QueryText;
		
	Else
		
		Rule = "";
		
	EndIf;
	
	Return Rule;
EndFunction

////////////////////////////////////////////////////////////////////////////////
// Common mechanics.

// Initializes the structure of parameters necessary to execute other service methods.
Procedure InitializeParameters(ExecutionParameters)
	// Define application work parameters.
	If Not ExecutionParameters.Property("SearchMarked") Then
		ExecutionParameters.Insert("SearchMarked", True);
	EndIf;
	If Not ExecutionParameters.Property("DeleteMarked") Then
		ExecutionParameters.Insert("DeleteMarked", True);
	EndIf;
	If Not ExecutionParameters.Property("Exclusive") Then
		ExecutionParameters.Insert("Exclusive", False);
	EndIf;
	If Not ExecutionParameters.Property("TechnologicalObjects") Then
		ExecutionParameters.Insert("TechnologicalObjects", New Array);
	EndIf;
	If Not ExecutionParameters.Property("UserObjects") Then
		ExecutionParameters.Insert("UserObjects", New Array);
	EndIf;
	If Not ExecutionParameters.Property("AllObjectsMarkedForDeletion") Then
		ExecutionParameters.Insert("AllObjectsMarkedForDeletion", New Array);
		UT_CommonClientServer.SupplementArray(ExecutionParameters.AllObjectsMarkedForDeletion, ExecutionParameters.TechnologicalObjects);
		UT_CommonClientServer.SupplementArray(ExecutionParameters.AllObjectsMarkedForDeletion, ExecutionParameters.UserObjects);
	EndIf;
	If Not ExecutionParameters.Property("SaaSModel") Then
		ExecutionParameters.Insert("SaaSModel", UT_Common.DataSeparationEnabled());
		If ExecutionParameters.SaaSModel Then
//			If UT_Common.SubsystemExists("StandardSubsystems.SaaS") Then
//				ModuleSaaS = UT_Common.CommonModule("SaaS");
//				MainDataSeparator = ModuleSaaS.MainDataSeparator();
//				AuxiliaryDataSeparator = ModuleSaaS.AuxiliaryDataSeparator();
//			Else
				MainDataSeparator = Undefined;
				AuxiliaryDataSeparator = Undefined;
//			EndIf;
			
			ExecutionParameters.Insert("InDataArea",UT_Common.SeparatedDataUsageAvailable());
			ExecutionParameters.Insert("MainDataSeparator", MainDataSeparator);
			ExecutionParameters.Insert("AuxiliaryDataSeparator", AuxiliaryDataSeparator);
		EndIf;
	EndIf;
	If Not ExecutionParameters.Property("TypesInformation") Then
		ExecutionParameters.Insert("TypesInformation", New Map);
	EndIf;
	
	ItemsPreventingDeletion = New ValueTable;
	ItemsPreventingDeletion.Columns.Add("ItemToDeleteRef");
	ItemsPreventingDeletion.Columns.Add("TypeToDelete", New TypeDescription("Type"));
	ItemsPreventingDeletion.Columns.Add("FoundItemReference");
	ItemsPreventingDeletion.Columns.Add("FoundType", New TypeDescription("Type"));
	ItemsPreventingDeletion.Columns.Add("FoundDeletionMark", New TypeDescription("Boolean"));
	ItemsPreventingDeletion.Columns.Add("More", New TypeDescription("String"));
	
	ItemsPreventingDeletion.Indexes.Add("ItemToDeleteRef");
	ItemsPreventingDeletion.Indexes.Add("FoundItemReference");
	
	ExecutionParameters.Insert("DeletedItems",              New Array);
	ExecutionParameters.Insert("NotDeletedItems",            New Array);
	ExecutionParameters.Insert("ItemsPreventingDeletion", ItemsPreventingDeletion);
	ExecutionParameters.Insert("ToRedelete",      New Array);
	ExecutionParameters.Insert("Interactive",          ExecutionParameters.Property("RecordPeriod"));
	
	InitializeParametersToRegisterProgress(ExecutionParameters);
EndProcedure

// Generates an array of objects marked for deletion considering separation.
Procedure GetItemsMarkedForDeletion(ExecutionParameters)

	MarkCollectionTraversalStart(ExecutionParameters, "BeforeSearchForItemsMarkedForDeletion");
//	DeleteMarkedObjectsRedefinedModule=UT_Common.CommonModule(
//		"DeleteMarkedObjectsRedefined");
//	If DeleteMarkedObjectsRedefinedModule <> Undefined Then
//		DeleteMarkedObjectsRedefinedModule.BeforeSearchForItemsMarkedForDeletion(ExecutionParameters);
//	EndIf;

	SetPrivilegedMode(True);
	
	// Get the list of objects marked for deletion.
	MarkCollectionTraversalStart(ExecutionParameters, "SearchForItemsmarkedForDeletion");
	ExecutionParameters.AllObjectsMarkedForDeletion = FindMarkedForDeletion();
	
	// Distribute objects marked for deletion to collections.
	MarkCollectionTraversalStart(ExecutionParameters, "AllObjectsMarkedForDeletion");
	Count = ExecutionParameters.AllObjectsMarkedForDeletion.Count();
	For Number = 1 To Count Do
		Index = Count - Number;
		Ref = ExecutionParameters.AllObjectsMarkedForDeletion[Index];
		
		Information = GenerateTypesInformation(ExecutionParameters, TypeOf(Ref));
		MarkCollectionTraversalProgress(ExecutionParameters, "AllObjectsMarkedForDeletion");
		
		If ExecutionParameters.SaaSModel
			AND ExecutionParameters.InDataArea
			AND Not Information.Separated Then
			ExecutionParameters.AllObjectsMarkedForDeletion.Delete(Index);
			Continue; // You cannot change shared objects from a data area.
		EndIf;
		
		If Information.HasPredefined AND Information.Predefined.Find(Ref) <> Undefined Then
			ExecutionParameters.AllObjectsMarkedForDeletion.Delete(Index);
			Continue; // Predefined items are created and deleted only automatically.
		EndIf;
		
		If Information.Technical = True Then
			ExecutionParameters.TechnologicalObjects.Add(Ref);
		Else
			ExecutionParameters.UserObjects.Add(Ref);
		EndIf;
	EndDo;
EndProcedure

// Generates information on the metadata object type: full name, presentation, kind, and so on.
Function GenerateTypesInformation(ExecutionParameters, Type) Export
	Information = ExecutionParameters.TypesInformation.Get(Type); // Cache.
	If Information <> Undefined Then
		Return Information;
	EndIf;
	
	Information = New Structure("FullName, ItemPresentation, ListPresentation,
	|Kind, Reference, Technical, Separated,
	|Hierarchical, QueryTextByHierarchy,
	|HasSubordinate, QueryTextBySubordinated, 
	|HasPredefined, Predefined");
	
	// Search for the metadata object.
	MetadataObject = Metadata.FindByType(Type);
	
	// Fill in basic information.
	Information.FullName = Upper(MetadataObject.FullName());
	
	// Item and list presentations.
	StandardProperties = New Structure("ObjectPresentation, ExtendedObjectPresentation, ListPresentation, ExtendedListPresentation");
	FillPropertyValues(StandardProperties, MetadataObject);
	If ValueIsFilled(StandardProperties.ObjectPresentation) Then
		Information.ItemPresentation = StandardProperties.ObjectPresentation;
	ElsIf ValueIsFilled(StandardProperties.ExtendedObjectPresentation) Then
		Information.ItemPresentation = StandardProperties.ExtendedObjectPresentation;
	Else
		Information.ItemPresentation = MetadataObject.Presentation();
	EndIf;
	If ValueIsFilled(StandardProperties.ListPresentation) Then
		Information.ListPresentation = StandardProperties.ListPresentation;
	ElsIf ValueIsFilled(StandardProperties.ExtendedListPresentation) Then
		Information.ListPresentation = StandardProperties.ExtendedListPresentation;
	Else
		Information.ListPresentation = MetadataObject.Presentation();
	EndIf;
	
	// Kind and its properties.
	Information.Kind = Left(Information.FullName, StrFind(Information.FullName, ".") - 1);
	If Information.Kind = "CATALOG" Or Information.Kind = "DOCUMENT" Or Information.Kind = "ENUM"
		Or Information.Kind = "CHARTOFCHARACTERISTICTYPES" Or Information.Kind = "CHARTOFACCOUNTS" Or Information.Kind = "CHARTOFCALCULATIONTYPES"
		Or Information.Kind = "BUSINESSPROCESS" Or Information.Kind = "TASK" Or Information.Kind = "EXCHANGEPLAN" Then
		Information.Reference = True;
	Else
		Information.Reference = False;
	EndIf;

	If Information.Kind = "CATALOG" Or Information.Kind = "CHARTOFCHARACTERISTICTYPES" Then
		Information.Hierarchical = MetadataObject.Hierarchical;
	ElsIf Information.Kind = "CHARTOFACCOUNTS" Then
		Information.Hierarchical = True;
	Else
		Information.Hierarchical = False;
	EndIf;
	If Information.Hierarchical Then
		QueryTemplate = "SELECT Ref FROM &FullName WHERE Parent = &ItemToDeleteRef";
		Information.QueryTextByHierarchy = StrReplace(QueryTemplate, "&FullName", Information.FullName);
	EndIf;

	Information.HasSubordinate = False;
	Information.QueryTextBySubordinated = "";
	If Information.Kind = "CATALOG" Or Information.Kind = "CHARTOFCHARACTERISTICTYPES" Or Information.Kind = "EXCHANGEPLAN"
		Or Information.Kind = "CHARTOFACCOUNTS" Or Information.Kind = "CHARTOFCALCULATIONTYPES" Then

		QueryTemplate = "SELECT Ref FROM Catalog.&Name WHERE Owner = &ItemToDeleteRef";
		QueryText = "";

		For Each Catalog In Metadata.Catalogs Do
			If Catalog.Owners.Contains(MetadataObject) Then
				If Information.HasSubordinate = False Then
					Information.HasSubordinate = True;
				Else
					QueryText = QueryText + Chars.LF + "UNION ALL" + Chars.LF;
				EndIf;
				QueryText = QueryText + StrReplace(QueryTemplate, "&Name", Catalog.Name);
			EndIf;
		EndDo;

		Information.QueryTextBySubordinated = QueryText;
	EndIf;

	Information.Technical = IsTechnicalObject(Information.FullName);
	If ExecutionParameters.SaaSModel Then
		
//		If UT_Common.SubsystemExists("StandardSubsystems.SaaS") Then
//			ModuleSaaS = UT_Common.CommonModule("SaaS");
//			IsSeparatedMetadataObject = ModuleSaaS.IsSeparatedMetadataObject(MetadataObject);
//		Else
			IsSeparatedMetadataObject = False;
//		EndIf;
		Information.Separated = IsSeparatedMetadataObject;
		
	EndIf;

	If Information.Kind = "CATALOG" Or Information.Kind = "CHARTOFCHARACTERISTICTYPES" Or Information.Kind = "CHARTOFACCOUNTS"
		Or Information.Kind = "CHARTOFCALCULATIONTYPES" Then
		Query = New Query("SELECT Ref FROM " + Information.FullName + " WHERE Predefined AND DeletionMark");
		Information.Predefined = Query.Execute().Unload().UnloadColumn("Ref");
		Information.HasPredefined = Information.Predefined.Count() > 0;
	Else
		Information.HasPredefined = False;
	EndIf;

	ExecutionParameters.TypesInformation.Insert(Type, Information);

	Return Information;
EndFunction

Function IsTechnicalObject(Знач FullObjectName)
	Return FullObjectName = "CATALOG.METADATAOBJECTIDS" Or FullObjectName = "CATALOG.PREDEFINEDREPORTSOPTIONS"
		Or FullObjectName = "CATALOG.EXTENSIONOBJECTIDS" Or FullObjectName
		= "CATALOG.PREDEFINEDEXTENSIONSREPORTSOPTIONS";
EndFunction

// Registers a warning in the event log.
Procedure WriteWarning(Ref, ErrorInformation)
	If TypeOf(ErrorInformation) = Type("ErrorInfo") Then
		TextForLog = DetailErrorDescription(ErrorInformation);
	Else
		TextForLog = ErrorInformation;
	EndIf;

	WriteLogEvent(
		NStr("ru = 'Удаление помеченных'; en = 'Deletion of marked objects'", UT_CommonClientServer.DefaultLanguageCode()),
		EventLogLevel.Warning, , Ref, TextForLog);
EndProcedure

// Register a reason for non-deletion.
Procedure WriteReasonToResult(ExecutionParameters, TableRow)
	TypeToDelete        = TypeOf(TableRow.ItemToDeleteRef);
	ItemToDeleteInfo = GenerateTypesInformation(ExecutionParameters, TypeToDelete);
	If ItemToDeleteInfo.Technical Then
		Return;
	EndIf;
	
	// Add non-deleted objects.
	If ExecutionParameters.NotDeletedItems.Find(TableRow.ItemToDeleteRef) = Undefined Then
		ExecutionParameters.NotDeletedItems.Add(TableRow.ItemToDeleteRef);
	EndIf;
	
	Reason = ExecutionParameters.ItemsPreventingDeletion.Add();
	FillPropertyValues(Reason, TableRow);
	Reason.TypeToDelete    = TypeToDelete;
	Reason.FoundType = TypeOf(Reason.FoundItemReference);
	
	If TableRow.FoundItemReference = Undefined Then
		If Metadata.Constants.Contains(TableRow.FoundMetadata) Then
			Reason.FoundType = Type("ConstantValueManager." + TableRow.FoundMetadata.Name);
		Else
			Reason.FoundItemReference = StrTemplate(
				NStr("ru = 'Обнаружены неразрешимые ссылки (%1)';en = 'Incorrect references are detected (%1)'"),
				TableRow.FoundItemReference.Presentation());
			Reason.FoundType = Type("String");
			Return;
		EndIf;
	EndIf;
	
	// Register information on metadata objects (if necessary).
	FoundItemInfo = GenerateTypesInformation(ExecutionParameters, Reason.FoundType);
	
	// Fill in subordinate fields.
	If FoundItemInfo.Reference Then
		Reason.FoundDeletionMark = UT_Common.ObjectAttributeValue(Reason.FoundItemReference, "DeletionMark");
	Else
		Reason.FoundDeletionMark = False;
	EndIf;
EndProcedure

// The basic mechanics of deleting marked objects.
Function ExtractResult(ExecutionParameters)
	DeletionResult = ExecutionParameters;
	DeletionResult.Delete("AllObjectsMarkedForDeletion");
	DeletionResult.Delete("AllObjectsMarkedForDeletion");
	Return DeletionResult;
EndFunction

////////////////////////////////////////////////////////////////////////////////
// Transfer information to the client.

// Initializes the structure of parameters required to transfer data to the client.
Procedure InitializeParametersToRegisterProgress(ExecutionParameters)
	If Not ExecutionParameters.Interactive Then
		Return;
	EndIf;
	
	ExecutionParameters.Insert("PercentAchieved", 0);
	ExecutionParameters.Insert("Range", 0);
	ExecutionParameters.Insert("NextControlNumber", 0);
	ExecutionParameters.Insert("Number", 0);
	ExecutionParameters.Insert("Total", 0);
	ExecutionParameters.Insert("Time", CurrentSessionDate() - 0.1);
	
	ExecutionParameters.Insert("Ranges", New Map);
	
	TotalWeight = 0;
	If ExecutionParameters.SearchMarked Then
		ExecutionParameters.Ranges.Insert("BeforeSearchForItemsMarkedForDeletion", 5);
		ExecutionParameters.Ranges.Insert("SearchForItemsmarkedForDeletion", 4);
		ExecutionParameters.Ranges.Insert("AllObjectsMarkedForDeletion", 1);
		TotalWeight = TotalWeight + 10;
	EndIf;
	If ExecutionParameters.DeleteMarked Then
		If ExecutionParameters.Exclusive Then
			ExecutionParameters.Ranges.Insert("ExclusiveDeletion", 80);
			ExecutionParameters.Ranges.Insert("ItemsPreventingDeletion", 10);
		Else // Not exclusive.
			ExecutionParameters.Ranges.Insert("TechnologicalObjects", 10);
			ExecutionParameters.Ranges.Insert("UserObjects", 70);
			ExecutionParameters.Ranges.Insert("ToRedelete", 10);
		EndIf;
		TotalWeight = TotalWeight + 90;
	EndIf;
	If TotalWeight <> 0 AND TotalWeight <> 100 Then
		Coefficient = 100/TotalWeight;
		For Each KeyAndValue In ExecutionParameters.Ranges Do
			ExecutionParameters.Ranges.Insert(KeyAndValue.Key, Round(KeyAndValue.Value*Coefficient, 0));
		EndDo;
	EndIf;
	
EndProcedure

// Registers the process start.
Procedure MarkCollectionTraversalStart(ExecutionParameters, CollectionName, Collection = Undefined)
	If Not ExecutionParameters.Interactive Then
		Return;
	EndIf;
	ExecutionParameters.PercentAchieved = ExecutionParameters.PercentAchieved + ExecutionParameters.Range;
	ExecutionParameters.Range = ExecutionParameters.Ranges[CollectionName];
	ExecutionParameters.NextControlNumber = 0;
	ExecutionParameters.Number = 0;

	If Collection <> Undefined Or ExecutionParameters.Property(CollectionName, Collection) Then
		ExecutionParameters.Total = Collection.Count();
	Else
		ExecutionParameters.Total = 1;
		MarkCollectionTraversalProgress(ExecutionParameters, CollectionName);
	EndIf;
EndProcedure


Procedure MarkCollectionTraversalProgress(ExecutionParameters, CollectionName)
	If Not ExecutionParameters.Interactive Then
		Return;
	EndIf;
	
	// Check whether it is reasonable to transfer information to the client.
	If ExecutionParameters.SearchMarked Then 
		Return; // If the current step is calculation of marked objects, notification of the client is not required.
	EndIf;
	
	// Check whether it is reasonable to transfer information to the client.
	If ExecutionParameters.Total < 10 Then 
		Return; // If less than 10 objects are processed, notification of the client is not required.
	EndIf;
	
	// Progress registration.
	ExecutionParameters.Number = ExecutionParameters.Number + 1;
	
	// Check that it is time to transfer information to the client.
	If CurrentSessionDate() < ExecutionParameters.Time Then
		Return; // No more often than once every 3 seconds.
	EndIf;
	
	// Set the next time of transferring information to the client.
	ExecutionParameters.Time = ExecutionParameters.Time + ExecutionParameters.RecordPeriod;
	
	// Check if there are enough changes to send information to the client.
	If ExecutionParameters.Number < ExecutionParameters.NextControlNumber Then 
		Return; // No more often than changed objects are gathered to change the progress by 1 step .
	EndIf;
	NotificationStep = Int(ExecutionParameters.Total / 100) + 1;
	ExecutionParameters.NextControlNumber = ExecutionParameters.Number + NotificationStep;
	
	// Calculate information to transfer it to the client.
	
	Percent = ExecutionParameters.PercentAchieved
		+ ExecutionParameters.Range * ExecutionParameters.Number / ExecutionParameters.Total;
	
	// Prepare parameters to be passed.
	If CollectionName = "BeforeSearchForItemsMarkedForDeletion" Then
		
		Text = NStr("ru = 'Подготовка к поиску объектов, помеченных на удаление.'; en = 'Preparing to search for objects marked for deletion.'");
		
	ElsIf CollectionName = "FindMarkedForDeletion" Then
		
		Text = NStr("ru = 'Поиск объектов, помеченных на удаление.'; en = 'Search for objects marked for deletion.'");
		
	ElsIf CollectionName = "AllObjectsMarkedForDeletion" Then
		
		Text = NStr("ru = 'Анализ помеченных на удаление.'; en = 'Analysis of objects marked for deletion.'");
		
	ElsIf CollectionName = "TechnologicalObjects" Then
		
		Text = NStr("ru = 'Подготовка к удалению.'; en = 'Prepare for deletion.'");
		
	ElsIf CollectionName = "ExclusiveDeletion" Then
		
		Text = NStr("ru = 'Выполняется удаление объектов.'; en = 'Deleting objects.'");
		
	ElsIf CollectionName = "UserObjects" Then
		
		NotDeleted = ExecutionParameters.NotDeletedItems.Count();
		PresentationNumber     = Format(ExecutionParameters.Number, "NZ=0; NG=");
		PresentationTotal     = Format(ExecutionParameters.Total, "NZ=0; NG=");
		PresentationNotDeleted = Format(NotDeleted, "NZ=0; NG=");
		If NotDeleted = 0 Then // Cannot go to the StrTemplate.
			Text = NStr("ru = 'Удалено: %1 из %2 объектов.'; en = 'Deleted: %1 of %2 objects.'");
			Text = StrTemplate(Text, PresentationNumber, PresentationTotal);
		Else
			Text = NStr("ru = 'Обработано: %1 из %2 объектов, из них не удалено: %3.'; en = 'Processed: %1 out of %2 objects; not deleted: %3.'");
			Text = StrTemplate(Text, PresentationNumber, PresentationTotal, PresentationNotDeleted);
		EndIf;
		
	ElsIf CollectionName = "ToRedelete" Then
		
		Text = StrTemplate(
			NStr("ru = 'Повторная проверка не удаленных объектов: %1 из %2.'; en = 'Recheck not deleted objects: %1 out of %2.'"),
			Format(ExecutionParameters.Number, "NZ=0; NG="),
			Format(ExecutionParameters.Total, "NZ=0; NG="));
		
	ElsIf CollectionName = "ItemsPreventingDeletion" Then
		
		Text = StrTemplate(
			NStr("ru = 'Анализ объектов, препятствующих удалению: %1 из %2.'; en = 'Analysis of objects that prevent from deletion: %1 out of %2.'"),
			Format(ExecutionParameters.Number, "NZ=0; NG="),
			Format(ExecutionParameters.Total, "NZ=0; NG="));
		
	Else
		
		Return;
		
	EndIf;
	
	// Register a message to read it from the client session.
	UT_TimeConsumingOperations.ReportProgress(Percent, Text);
EndProcedure

#EndRegion

#EndIf