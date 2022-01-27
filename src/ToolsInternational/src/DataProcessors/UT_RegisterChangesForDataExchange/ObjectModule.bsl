#If Server Or ThickClientOrdinaryApplication Or ExternalConnection Then

////////////////////////////////////////////////////////////////////////////////////////////////////
// PROGRAM INTERFACE
//

// Returns a value tree that contains data required to select a node. The tree has two levels:
// exchange plan -> exchange nodes. Internal nodes are not included in the tree. 
//
// Parameters:
//    DataObject - AnyRef, Structure - (optional) a reference or a structure that contains record set dimensions. 
//                   Data to analyze exchange nodes. If DataObject is not specified, all metadata objects are used.
//    TableName   - String - (optional) if DataObject is a structure, then the table name is for  records set.
//
// Return value:
//    ValueTree with the following columns:
//    	  * Description                 - String - presentation of exchange plan or exchange node.
//        * PictureIndex                - Number - 1 = exchange plan, 2 = node, 3 = node marked for deletion.
//        * AutoRecordPictureIndex 		- Number  - if the DataObject parameter is not specified, it is Undefined.
//                                                   Else: 0 = none, 1 = prohibited, 2 = enabled, 
//                                                   Undefined for the exchange plan.
//        * ExchangePlanName            - String - exchange plan node name.
//        * Ref                         - ExchangePlanRef - node reference, Undefined for the exchange plan.
//        * Code                        - Number, String - node code, Undefined for exchange plan.
//        * SentNo            			- Number - node data.
//        * ReceivedNo              	- Number - node data.
//        * MessageNo               	- Number, NULL - if an object is specified, then the object message number, else NULL.
//        * NotExported                 - Boolean, Null - if an object is specified, then it is an export flag, else NULL.
//        * Mark                        - Boolean - if an object is specified, then 0 = no registration, 1 = there is a registration, 
//                                                          else it is always 0.
//        * InitialMark                 - Boolean - similar to the Mark column.
//        * RowID           			- Number - index of the added row (the tree is iterated from top 
//                                                         to bottom from left to right).
//
Function GenerateNodeTree(DataObject = Undefined, TableName = Undefined) Export

	Tree = New ValueTree;
	Columns = Tree.Columns;
	Rows  = Tree.Rows;

	Columns.Add("Description");
	Columns.Add("PictureIndex");
	Columns.Add("AutoRecordPictureIndex");
	Columns.Add("ExchangePlanName");
	Columns.Add("Ref");
	Columns.Add("Code");
	Columns.Add("SentNo");
	Columns.Add("ReceivedNo");
	Columns.Add("MessageNo");
	Columns.Add("NotExported");
	Columns.Add("Mark");
	Columns.Add("InitialMark");
	Columns.Add("RowID");

	Query = New Query;
	If DataObject = Undefined Then
		MetaObject = Undefined;
		QueryText = "
					|SELECT
					|	REFPRESENTATION(Ref) AS Description,
					|	CASE 
					|		WHEN DeletionMark THEN 2 ELSE 1
					|	END 				AS PictureIndex,
					|
					|	""{0}""            	AS ExchangePlanName,
					|	Code               	AS Code,
					|	Ref             	AS Ref,
					|	SentNo 				AS SentNo,
					|	ReceivedNo     		AS ReceivedNo,
					|	NULL               	AS MessageNo,
					|	NULL               	AS NotExported,
					|	0                  	AS Mark,
					|	0                  	AS InitialMark
					|FROM
					|	ExchangePlan.{0} AS ExchangePlan
					|WHERE
					|	ExchangePlan.Ref<>&NodeFilter
					|";

	Else
		If TypeOf(DataObject) = Type("Structure") Then
			QueryText = "";
			For Each KeyValue In DataObject Do
				CurName = KeyValue.Key;
				QueryText = QueryText + "
					|AND ChangesTable." + CurName + "=&" + CurName;
				Query.SetParameter(CurName, DataObject[CurName]);
			EndDo;
			CurTableName = TableName;
			MetaObject    = MetadataByFullName(TableName);

		ElsIf TypeOf(DataObject) = Type("String") Then
			QueryText  = "";
			CurTableName = DataObject;
			MetaObject    = MetadataByFullName(DataObject);

		Else
			QueryText = "
				|AND ChangesTable.Ref = &RegistrationObject";
			Query.SetParameter("RegistrationObject", DataObject);
			
			MetaObject    = DataObject.Metadata();
			CurTableName = MetaObject.FullName();
		EndIf;

		QueryText = "
					|SELECT
					|	REFPRESENTATION(ExchangePlan.Ref) 	AS Description,
					|	CASE 
					|		WHEN ExchangePlan.DeletionMark THEN 2 ELSE 1
					|	END	AS PictureIndex,
					|
					|	""{0}""                         	AS ExchangePlanName,
					|	ExchangePlan.Code               	AS Code,
					|	ExchangePlan.Ref               		AS Ref,
					|	ExchangePlan.SentNo   				AS SentNo,
					|	ExchangePlan.ReceivedNo       		AS ReceivedNo,
					|	ChangesTable.MessageNo 				AS MessageNo,
					|	CASE 
					|		WHEN ChangesTable.MessageNo IS NULL
					|		THEN TRUE
					|		ELSE FALSE
					|	END AS NotExported,
					|	CASE
					|		WHEN COUNT(ChangesTable.Node)>0 THEN 1 
					|		ELSE 0
					|	END AS Mark,
					|	CASE 
					|		WHEN COUNT(ChangesTable.Node)>0 THEN 1 
					|		ELSE 0
					|	END AS InitialMark
					|FROM
					|	ExchangePlan.{0} AS ExchangePlan
					|LEFT JOIN
					|	" + CurTableName + ".Changes AS ChangesTable
											|ON
											|	ChangesTable.Node=ExchangePlan.Ref
											|	" + QueryText + "
																|WHERE
																|	ExchangePlan.Ref<>&NodeFilter
																|GROUP BY
																|	ExchangePlan.Ref, 
																|	ChangesTable.MessageNo
																|";
	EndIf;

	CurRowNumber = 0;
	For Each Meta In Metadata.ExchangePlans Do

		PlanName = Meta.Name;
		Try
			ExchangePlanThisNode = ExchangePlans[PlanName].ThisNode();
		Except
			// Skipping the node in the split mode
			Continue;
		EndTry;

		AutoRecord = Undefined;
		If MetaObject <> Undefined Then
			CompositionItem = Meta.Content.Find(MetaObject);
			If CompositionItem = Undefined Then
				// Not in the current exchange plan
				Continue;
			EndIf;
			AutoRecord = ?(CompositionItem.AutoRecord = AutoChangeRecord.Deny, 1, 2);
		EndIf;

		PlanName = Meta.Name;
		Query.Text = StrReplace(QueryText, "{0}", PlanName);
		Result = Query.Execute();
		
		If Not Result.IsEmpty() Then
			PlanRow = Rows.Add();
			PlanRow.Description   = Meta.Presentation();
			PlanRow.PictureIndex = 0;
			PlanRow.ExchangePlanName  = PlanName;
			
			PlanRow.RowID = CurRowNumber;
			CurRowNumber = CurRowNumber + 1;
			
			// Sorting by presentation cannot be applied in a query.
			TempTable = Result.Unload();
			TempTable.Sort("Description");
			For Each NodeRow In TempTable Do;
				NewRow = PlanRow.Rows.Add();
				FillPropertyValues(NewRow, NodeRow);
				
				NewRow.InitialMark = ?(NodeRow.NodeChangeCount > 0, 1, 0);
				NewRow.Check         = NewRow.InitialMark;
				
				NewRow.AutoRecordPictureIndex = AutoRecord;
				
				NewRow.RowID = CurRowNumber;
				CurRowNumber = CurRowNumber + 1;
			EndDo;
		EndIf;
		
	EndDo;
	
	Return Tree;
EndFunction

// Returns a structure that describes exchange plan metadata.
// Objects that are not included in an exchange plan, to be excluded.
//
// Parameters:
//    ExchangePlanName - String - (optional) name of the exchange plan metadata that is used to generate a configuration tree.
//                     - ExchangePlanRef - the configuration tree is generated for its exchange plan.
//                     - Undefined - the tree of all configuration is generated.
//
// Return value:
//    Structure - metadata details. Fields:
//         * NamesStructure - Structure - Key - metadata group (constants, catalogs and 
//                                        so on), value is an array of full names.
//         * PresentationsStructure - Structure - Key - metadata group (constants, catalogs and 
//                                                so on), value is an array of presentations.
//                                                Order of presentations is the same as in array of full names.   
//         * AutoRecordStructure - Structure - Key - metadata group (constants, catalogs and so 
//                                             on), value is an array of autorecord flags on the node.
//                                             Order of data is the same as in array of full names.
//                                             Only not included in tree groups are included. 
//
//         * Tree - ValueTree - 3 levels: configuration -> object kind -> object. Contains the following columns: 
//               ** Description - String - object metadata kind presentation.
//               ** MetaFullName - String - the full metadata object name.
//               ** PictureIndex - Number - depends on metadata.
//               ** Mark - Undefined - it is further used to store marks.
//               ** RowID - Number - index of the added row (the tree is iterated from top to bottom from left to right).
//               ** AutoRecord - Boolean - if ExchangePlanName is specified, the parameter can contain the following values (for leaves): 
//                                         1 - allowed, 2-prohibited. Else Undefined.
//
// 				 ** ChangesCount - Undefined - needed for further calculation.
//         		 ** ExportedCount - Undefined - needed for further calculation.
//         		 ** NotExportedCount - Undefined - needed for further calculation.
//         		 ** ChangesCountAsString - Undefined - needed for further calculation.
//
Function GenerateMetadataStructure(ExchangePlanName = Undefined) Export

	Tree = New ValueTree;
	Columns = Tree.Columns;
	Columns.Add("Description");
	Columns.Add("MetaFullName");
	Columns.Add("PictureIndex");
	Columns.Add("Mark");
	Columns.Add("RowID");
	
	Columns.Add("AutoRegistration");
	Columns.Add("ChangesCount");
	Columns.Add("ExportedCount");
	Columns.Add("NotExportedCount");
	Columns.Add("ChangesCountAsString");
	
	// Root
	RootRow = Tree.Rows.Add();
	RootRow.Description = Metadata.Synonym;
	RootRow.PictureIndex = 0;
	RootRow.RowID = 0;
	
	// Parameters:
	CurParameters = New Structure("NamesStructure, PresentationsStructure, AutoRecordStructure, Rows",
		New Structure, New Structure, New Structure, RootRow.Rows);

	If ExchangePlanName = Undefined Then
		ExchangePlan = Undefined;
	ElsIf TypeOf(ExchangePlanName) = Type("String") Then
		ExchangePlan = Metadata.ExchangePlans[ExchangePlanName];
	Else
		ExchangePlan = ExchangePlanName.Metadata();
	EndIf;
	CurParameters.Insert("ExchangePlan", ExchangePlan);

	Result = New Structure("Tree, NamesStructure, PresentationsStructure, AutoRecordStructure", Tree,
		CurParameters.NamesStructure, CurParameters.PresentationsStructure, CurParameters.AutoRecordStructure);

	CurRowNumber = 1;
	GenerateMetadataLevel(CurRowNumber, CurParameters, 1, 2, False, "Constants", NStr("ru='Константы'; en = 'Constants'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 3, 4, True, "Catalogs", NStr("ru='Справочники'; en = 'Catalogs'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 5, 6, True, "Sequences", NStr(
		"ru='Последовательности'; en = 'Sequences'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 7, 8, True, "Документы", NStr("ru='Документы'; en = 'Documents'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 9, 10, True, "ChartsOfCharacteristicTypes", NStr(
		"ru='Планы видов характеристик'; en = 'Charts of characteristic types'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 11, 12, True, "ChartsOfAccounts", NStr(
		"ru='Планы счетов'; en = 'Charts of accounts'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 13, 14, True, "ChartsOfCalculationTypes", NStr(
		"ru='Планы видов расчета'; en = 'Charts of calculation types'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 15, 16, True, "InformationRegisters", NStr(
		"ru='Регистры сведений'; en = 'Information registers'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 17, 18, True, "AccumulationRegisters", NStr(
		"ru='Регистры накопления'; en = 'Accumulation registers'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 19, 20, True, "AccountingRegisters", NStr(
		"ru='Регистры бухгалтерии'; en = 'Accounting registers'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 21, 22, True, "CalculationRegisters", NStr(
		"ru='Регистры расчета'; en = 'Calculation registers'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 23, 24, True, "BusinessProcesses", NStr(
		"ru='Бизнес-процессы'; en = 'Business processes'"));
	GenerateMetadataLevel(CurRowNumber, CurParameters, 25, 26, True, "Tasks", NStr("ru='Задачи'; en = 'Tasks'"));

	Return Result;
EndFunction

// Calculates the number of changes in metadata objects for an exchange nodes.
//
// Parameters:
//     TablesList - Array - names. Can be a key/value collection where values are name arrays.
//     NodesList  - ExchangePlanRef, Array - nodes.
//
// Return value:
//     ValueTable - columns:
//         * MetaFullName - String - a full name of metadata that needs the count calculated.
//         * ExchangeNode - ExchangePlanRef - a reference to an exchange node that needs the count calculated.
//         * ChangesCount - Number - contains the overall count of changes.
//         * ExportedCount - Number - contains the number of exported changes.
//         * NotExportedCount - Number - contains the number of not exported changes.
//
Function GetChangeCount(TablesList, NodesList) Export
	
	Result = New ValueTable;
	Columns = Result.Columns;
	Columns.Add("MetaFullName");
	Columns.Add("ExchangeNode");
	Columns.Add("ChangesCount");
	Columns.Add("ExportedCount");
	Columns.Add("NotExportedCount");
	
	Result.Indexes.Add("MetaFullName");
	Result.Indexes.Add("ExchangeNode");
	
	Query = New Query;
	Query.SetParameter("NodesList", NodesList);
	
	// TablesList can contain an array, structure, or map that contains multiple arrays.
	If TablesList = Undefined Then
		Return Result;
	ElsIf TypeOf(TablesList) = Type("Array") Then
		Source = New Structure("_", TablesList);
	Else
		Source = TablesList;
	EndIf;
	
	// Reading data in portions, each portion contains 200 tables processed in a query.
	Text = "";
	Number = 0;
	For Each KeyValue In Source Do
		If TypeOf(KeyValue.Value) <> Type("Array") Then
			Continue;
		EndIf;
		
		For Each Item In KeyValue.Value Do
			If IsBlankString(Item) Then
				Continue;
			EndIf;

			Text = Text + ?(Text = "", "", "UNION ALL") + " 
														  |ВЫБРАТЬ 
														  |	""" + Item + """ AS MetaFullName,
																		   |	Node                AS ExchangeNode,
																		   |	COUNT(*)              AS ChangesCount,
																		   |	COUNT(MessageNo) AS ExportedCount,
																		   |	COUNT(*) - COUNT(MessageNo) AS NotExportedCount
																		   |FROM
																		   |	" + Item + ".Changes
																						   |WHERE
																						   |	Node IN (&NodesList)
																						   |Group BY
																						   |	Node
																						   |";

			Number = Number + 1;
			If Number = 200	Then
				Query.Text = Text;
				Selection = Query.Execute().Select();
				While Selection.Next() Do
					FillPropertyValues(Result.Add(), Selection);
				EndDo;
				Text = "";
				Number = 0;
			EndIf;
			
		EndDo;
	EndDo;
	
	// Reading unread
	If Text <> "" Then
		Query.Text = Text;
		Selection = Query.Execute().Select();
		While Selection.Next() Do
			FillPropertyValues(Result.Add(), Selection);
		EndDo;
	EndIf;
	
	Return Result;
EndFunction

// Returns a metadata object by full name. An empty string means the whole configuration.
//
// Parameters:
//    MetadataName - String - a metadata object name, for example, "Catalog.Currencies" or "Constants".
//
// Return value:
//    MetadataObject - search result.
//
Function MetadataByFullName(MetadataName) Export
	
	If IsBlankString(MetadataName) Then
		// Whole configuration
		Return Metadata;
	EndIf;
		
	Value = Metadata.FindByFullName(MetadataName);
	If Value = Undefined Then
		Value = Metadata[MetadataName];
	EndIf;
	
	Return Value;
EndFunction

// Returns the object registration flag on the node.
//
// Parameters:
//    Node - ExchangePlanRef - an exchange plan node for which we receive information,
//    RegistrationObject - String, AnyRef, Structure - an object whose data is analyzed.
//                        The structure contains change values of record set dimensions.
//    TableName - String - (optional) if RegistrationObject is a structure, then contains a table name for dimensions set.
//
// Return value:
//    Boolean - the result of the registration.
//
Function ObjectRegisteredForNode(Node, RegistrationObject, TableName = Undefined) Export
	ParameterType = TypeOf(RegistrationObject);
	If ParameterType = Type("String") Then
		// Constant as a metadata
		Details = MetadataCharacteristics(RegistrationObject);
		CurrentObject = Details.Manager.CreateValueManager();
		
	ElsIf ParameterType = Type("Structure") Then
		Details = MetadataCharacteristics(TableName);
		CurrentObject = Details.Manager.CreateRecordSet();
		For Each KeyValue In RegistrationObject Do
			CurrentObject.Filter[KeyValue.Key].Set(KeyValue.Value);
		EndDo;
		
	Else
		CurrentObject = RegistrationObject;
	EndIf;
	
	Return ExchangePlans.IsChangeRecorded(Node, CurrentObject);
EndFunction

// Changes registration for an object.
//
// Parameters:
//     Command - Boolean - True if adding, False if deleting.
//     NoAutoRegistration - Boolean - True if no need to analyze the autorecord flag.
//     Node - ExchangePlanRef - a reference to the exchange plan node.
//     Data - AnyRef, String, Structure - data or data array.
//     TableName - String - (optional) if Data is a structure, then contains a table name.
//
// Return value:
//     Structure - an operation result:
//         * Total - Number - a total object count.
//         * Success - Number - a successfully processed objects count.
//
Function EditRegistrationAtServer(Command, NoAutoRegistration, Node, Data, TableName = Undefined) Export

	ReadSettings();
	Result = New Structure("Total, Success", 0, 0);
	
	// This flag is required only when adding registration results to the Result structure. The flag value can be True only if the configuration supports SSL.
	SSLFilterRequired = TypeOf(Command) = Type("Boolean") AND Command AND ConfigurationSupportsSSL AND ObjectExportControlSetting;

	If TypeOf(Data) = Type("Array") Then
		RegistrationData = Data;
	Else
		RegistrationData = New Array;
		RegistrationData.Add(Data);
	EndIf;

	For Each Item In RegistrationData Do
		
		Type = TypeOf(Item);
		Values = New Array;
		
		If Item = Undefined Then
			// Whole configuration
			
			If TypeOf(Command) = Type("Boolean") AND Command Then
				// Adding registration in parts.
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "Constants", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "Catalogs", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "Documents", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "Sequences", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "ChartsOfCharacteristicTypes", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "ChartsOfAccounts", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "ChartsOfCalculationTypes", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "InformationRegisters", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "AccumulationRegisters", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "AccountingRegisters", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "CalculationRegisters", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "BusinessProcesses", TableName) );
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, "Tasks", TableName) );
				Continue;
			EndIf;
			
			// Deleting registration with platform method.
			Values.Add(Undefined);

		ElsIf Type = Type("String") Then
			// Metadata, either collection or a certain kind.
			Details = MetadataCharacteristics(Item);
			If SSLFilterRequired Then
				AddResults(Result, SSL_MetadataChangesRegistration(Node, Details, NoAutoRegistration) );
				Continue;
				
			ElsIf NoAutoRegistration Then
				If Details.IsCollection Then
					For Each Meta In Details.Metadata Do
						AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, Meta.FullName(), TableName) );
					EndDo;
					Continue;
				Else
					Meta = Details.Metadata;
					CompositionItem = Node.Metadata().Content.Find(Meta);
					If CompositionItem = Undefined Then
						Continue;
					EndIf;
					// Constant?
					Values.Add(Details.Metadata);
				EndIf;

			Else
				// Excluding inappropriate objects.
				If Details.IsCollection Then
					// Registering metadata objects singly
					For Each Meta In Details.Metadata Do
						AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, Meta.FullName(), TableName) );
					EndDo;
					Continue;
				Else
					Meta = Details.Metadata;
					CompositionItem = Node.Metadata().Content.Find(Meta);
					If CompositionItem = Undefined Or CompositionItem.AutoRecord <> AutoChangeRecord.Allow Then
						Continue;
					EndIf;
					// Constant?
					Values.Add(Details.Metadata);
				EndIf;
			EndIf;
			
			// Adding additional registration objects, Values[0] - specific metadata with the Item name.
			For Each CurItem In GetAdditionalRegistrationObjects(Item, Node, NoAutoRegistration) Do
				Values.Add(CurItem);
			EndDo;

		ElsIf Type = Type("Structure") Then
			// It is either the specific record set or the result of selecting a reference type by filter.
			Details = MetadataCharacteristics(TableName);
			If Details.IsReference Then
				AddResults(Result, EditRegistrationAtServer(Command, NoAutoRegistration, Node, Item.Ref) );
				Continue;
			EndIf;
			// Specific record set, auto record settings does not matter.
			If SSLFilterRequired Then
				AddResults(Result, SSL_SetChangesRegistration(Node, Item, Details) );
				Continue;
			EndIf;
			
			Set = Details.Manager.CreateRecordSet();
			For Each KeyValue In Item Do
				Set.Filter[KeyValue.Key].Set(KeyValue.Value);
			EndDo;
			Values.Add(Set);
			// Adding additional registration objects.
			For Each CurItem In GetAdditionalRegistrationObjects(Item, Node, NoAutoRegistration, TableName) Do
				Values.Add(CurItem);
			EndDo;

		Else
			// Specific reference, auto record settings does not matter.
			If SSLFilterRequired Then
				AddResults(Result, SSL_RefChangesRegistration(Node, Item) );
				Continue;
				
			EndIf;
			Values.Add(Item);
			// Adding additional registration objects.
			For Each CurItem In GetAdditionalRegistrationObjects(Item, Node, NoAutoRegistration) Do
				Values.Add(CurItem);
			EndDo;
			
		EndIf;
		
		// Registering objects without using a filter.
		For Each CurValue In Values Do
			ExecuteObjectRegistrationCommand(Command, Node, CurValue);
			Result.Success = Result.Success + 1;
			Result.Total   = Result.Total   + 1;
		EndDo;

	EndDo; // Iterating objects in the data array for registration.

	Return Result;
EndFunction

// Returns the beginning of the full form name to open.
//
// Parameters:
//    CurrentObject - String, DynamicList - (optional) object whose form name returns.
//    
// Return value:
//    String - a full name of the form.
//
Function GetFormName(CurrentObject = Undefined) Export
	
	Type = TypeOf(CurrentObject);
	If Type = Type("DynamicList") Then
		Return CurrentObject.MainTable + ".";
	ElsIf Type = Type("String") Then
		Return CurrentObject + ".";
	EndIf;
	
	Meta = ?(CurrentObject = Undefined, Metadata(), CurrentObject.Metadata());
	Return Meta.FullName() + ".";
EndFunction	

// Recursive update of hierarchy marks, which can have 3 states, in a tree row.
//
// Parameters:
//    RowData - FormDataTreeItem - a mark is stored in the Mark numeric column.
//
Procedure ChangeMark(RowData) Export
	RowData.Mark = RowData.Mark % 2;
	SetMarksForChilds(RowData);
	SetMarksForParents(RowData);
EndProcedure

// Recursive update of hierarchy marks, which can have 3 states, in a tree row.
//
// Parameters:
//    RowData - FormDataTreeItem - a mark is stored in the Mark numeric column.
//
Procedure SetMarksForChilds(RowData) Export
	Value = RowData.Mark;
	For Each Child In RowData.GetItems() Do
		Child.Mark = Value;
		SetMarksForChilds(Child);
	EndDo;
EndProcedure

// Recursive update of hierarchy marks, which can have 3 states, in a tree row.
//
// Parameters:
//    RowData - FormDataTreeItem - a mark is stored in the Mark numeric column.
//
Procedure SetMarksForParents(RowData) Export
	RowParent = RowData.GetParent();
	If RowParent <> Undefined Then
		AllTrue = True;
		NotAllFalse = False;
		For Each Child In RowParent.GetItems() Do
			AllTrue = AllTrue AND (Child.Mark = 1);
			NotAllFalse = NotAllFalse Or Boolean(Child.Mark);
		EndDo;
		If AllTrue Then
			RowParent.Mark = 1;
		ElsIf NotAllFalse Then
			RowParent.Mark = 2;
		Else
			RowParent.Mark = 0;
		EndIf;
		SetMarksForParents(RowParent);
	EndIf;
EndProcedure

// Exchange node attribute reading.
//
// Parameters:
//    Ref - ExchangePlanRef - a reference to the exchange node.
//    Data - String - a list of attribute names to read, separated by commas.
//
// Return value:
//    Structure    - read data.
//
Function GetExchangeNodeParameters(Ref, Data) Export
	Query = New Query("
					  |SELECT " + Data + " FROM " + Ref.Metadata().FullName() + "
																				|WHERE Ref=&Ref
																				|");
	Query.SetParameter("Ref", Ref);
	Temp = Query.Execute().Unload();
	If Temp.Count() = 0 Then
		Return Undefined;
	EndIf;

	Result = New Structure(Data);
	FillPropertyValues(Result, Temp[0]);
	Return Result;
EndFunction	

// Exchange node attribute writing.
//
// Parameters:
//    Ref - ExchangePlanRef - a reference to the exchange node.
//    Data - Structure - contains node attribute values.
//
Procedure SetExchangeNodeParameters(Ref, Data) Export
	
	NodeObject = Ref.GetObject();
	If NodeObject = Undefined Then
		// Reference on deleted object.
		Return;
	EndIf;

	Changed = False;
	For Each Item In Data Do
		If NodeObject[Item.Key] = Item.Value Then
			Changed = True;
			Break;
		EndIf;
	EndDo;

	If Changed Then
		FillPropertyValues(NodeObject, Data);
		NodeObject.Write();
	EndIf;
EndProcedure

// Returns data details by the full table name/full metadata name or metadata.
//
// Parameters:
//    - MetadataTableName - String - table name, for example "Catalog.Currencies".
//
// Return value:
//    Structure - data description as a value set. Contains the following data.
//      IsSequence - Boolean - a sequence flag.
//      IsCollection - Boolean - a value collection flag.
//      IsConstant - Boolean - a constant flag.
//      IsReference - Boolean - a flag indicating a reference data type.
//      IsSet - Boolean - a flag indicating a register record set.
//      Manager - ValueManager - table value manager.
//      Metadata - MetadataObject - metadata object.
//      TableName - String - a name of the table.
//
Function MetadataCharacteristics(MetadataTableName) Export
	
	IsSequence = False;
	IsCollection          = False;
	IsConstant          = False;
	IsRef             = False;
	IsSet              = False;
	Manager              = Undefined;
	TableName            = "";
	
	If TypeOf(MetadataTableName) = Type("String") Then
		Meta = MetadataByFullName(MetadataTableName);
		TableName = MetadataTableName;
	ElsIf TypeOf(MetadataTableName) = Type("Type") Then
		Meta = Metadata.FindByType(MetadataTableName);
		TableName = Meta.FullName();
	Else
		Meta = MetadataTableName;
		TableName = Meta.FullName();
	EndIf;
	
	If Meta = Metadata.Constants Then
		IsCollection = True;
		IsConstant = True;
		Manager     = Constants;
		
	ElsIf Meta = Metadata.Catalogs Then
		IsCollection = True;
		IsRef    = True;
		Manager      = Catalogs;
		
	ElsIf Meta = Metadata.Documents Then
		IsCollection = True;
		IsRef    = True;
		Manager     = Documents;
		
	ElsIf Meta = Metadata.Enums Then
		IsCollection = True;
		IsRef    = True;
		Manager     = Enums;
		
	ElsIf Meta = Metadata.ChartsOfCharacteristicTypes Then
		IsCollection = True;
		IsRef    = True;
		Manager     = ChartsOfCharacteristicTypes;
		
	ElsIf Meta = Metadata.ChartsOfAccounts Then
		IsCollection = True;
		IsRef    = True;
		Manager     = ChartsOfAccounts;
		
	ElsIf Meta = Metadata.ChartsOfCalculationTypes Then
		IsCollection = True;
		IsRef    = True;
		Manager     = ChartsOfCalculationTypes;
		
	ElsIf Meta = Metadata.BusinessProcesses Then
		IsCollection = True;
		IsRef    = True;
		Manager     = BusinessProcesses;
		
	ElsIf Meta = Metadata.Tasks Then
		IsCollection = True;
		IsRef    = True;
		Manager     = Tasks;
		
	ElsIf Meta = Metadata.Sequences Then
		IsSet              = True;
		IsSequence = True;
		IsCollection          = True;
		Manager              = Sequences;
		
	ElsIf Meta = Metadata.InformationRegisters Then
		IsCollection = True;
		IsSet     = True;
		Manager 	 = InformationRegisters;
		
	ElsIf Meta = Metadata.AccumulationRegisters Then
		IsCollection = True;
		IsSet     = True;
		Manager     = AccumulationRegisters;
		
	ElsIf Meta = Metadata.AccountingRegisters Then
		IsCollection = True;
		IsSet     = True;
		Manager     = AccountingRegisters;
		
	ElsIf Meta = Metadata.CalculationRegisters Then
		IsCollection = True;
		IsSet     = True;
		Manager     = CalculationRegisters;
		
	ElsIf Metadata.Constants.Contains(Meta) Then
		IsConstant = True;
		Manager     = Constants[Meta.Name];
		
	ElsIf Metadata.Catalogs.Contains(Meta) Then
		IsRef = True;
		Manager  = Catalogs[Meta.Name];
		
	ElsIf Metadata.Documents.Contains(Meta) Then
		IsRef = True;
		Manager  = Documents[Meta.Name];
		
	ElsIf Metadata.Sequences.Contains(Meta) Then
		IsSet              = True;
		IsSequence = True;
		Manager              = Sequences[Meta.Name];
		
	ElsIf Metadata.Enums.Contains(Meta) Then
		IsRef = True;
		Manager  = Enums[Meta.Name];
		
	ElsIf Metadata.ChartsOfCharacteristicTypes.Contains(Meta) Then
		IsRef = True;
		Manager  = ChartsOfCharacteristicTypes[Meta.Name];
		
	ElsIf Metadata.ChartsOfAccounts.Contains(Meta) Then
		IsRef = True;
		Manager = ChartsOfAccounts[Meta.Name];
		
	ElsIf Metadata.ChartsOfCalculationTypes.Contains(Meta) Then
		IsRef = True;
		Manager  = ChartsOfCalculationTypes[Meta.Name];
		
	ElsIf Metadata.InformationRegisters.Contains(Meta) Then
		IsSet = True;
		Manager = InformationRegisters[Meta.Name];
		
	ElsIf Metadata.AccumulationRegisters.Contains(Meta) Then
		IsSet = True;
		Manager = AccumulationRegisters[Meta.Name];
		
	ElsIf Metadata.AccountingRegisters.Contains(Meta) Then
		IsSet = True;
		Manager = AccountingRegisters[Meta.Name];
		
	ElsIf Metadata.CalculationRegisters.Contains(Meta) Then
		IsSet = True;
		Manager = CalculationRegisters[Meta.Name];
		
	ElsIf Metadata.BusinessProcesses.Contains(Meta) Then
		IsRef = True;
		Manager = BusinessProcesses[Meta.Name];
		
	ElsIf Metadata.Tasks.Contains(Meta) Then
		IsRef = True;
		Manager = Tasks[Meta.Name];
		
	Else
		MetaParent = Meta.Parent();
		If MetaParent <> Undefined AND Metadata.CalculationRegisters.Contains(MetaParent) Then
			// Recalculation
			IsSet = True;
			Manager = CalculationRegisters[MetaParent.Name].Recalculations[Meta.Name];
		EndIf;
		
	EndIf;

	Return New Structure("TableName, Metadata, Manager, IsSet, IsRef, IsConstant, IsSequence, IsCollection",
		TableName, Meta, Manager, IsSet, IsRef, IsConstant, IsSequence, IsCollection);

EndFunction

// Returns a table describing dimensions for data set change record.
//
// Parameters:
//    TableName   - String - Table name, for example "InformationRegister.CurrencyRates".
//    AllDimensions - Boolean - (optional) if true, all register dimensions selected,  
//                              		   if false, only basic and master dimensions selected.
//
// Return value:
//    ValueTable - columns:
//         * Name - String - a dimension name.
//         * ValueType - TypeDescription - types.
//         * Title - String - dimension presentation.
//
Function RecordSetDimensions(TableName, AllDimensions = False) Export
	
	If TypeOf(TableName) = Type("String") Then
		Meta = MetadataByFullName(TableName);
	Else
		Meta = TableName;
	EndIf;
	
	// Specifying key fields
	Dimensions = New ValueTable;
	Columns = Dimensions.Columns;
	Columns.Add("Name");
	Columns.Add("ValueType");
	Columns.Add("Title");
	
	If Not AllDimensions Then
		// Data to register
		DontConsider = "MessageNo, Node,";

		Query = New Query("SELECT * FROM " + Meta.FullName() + ".Changes WHERE FALSE");
		EmptyResult = Query.Execute();
		For Each ResultColumn In EmptyResult.Columns Do
			ColumnName = ResultColumn.Name;
			If StrFind(DontConsider, ColumnName + ",") = 0 Then
				Row = Dimensions.Add();
				Row.Name         = ColumnName;
				Row.ValueType = ResultColumn.ValueType;
				
				MetaDimension = Meta.Dimensions.Find(ColumnName);
				Row.Title = ?(MetaDimension = Undefined, ColumnName, MetaDimension.Presentation());
			EndIf;
		EndDo;
		
		Return Dimensions;
	EndIf;
	
	// All dimensions.
	
	IsInformationRegister = Metadata.InformationRegisters.Contains(Meta);
	
	// Recorder
	If Metadata.AccumulationRegisters.Contains(Meta) Or Metadata.AccountingRegisters.Contains(Meta)
		Or Metadata.CalculationRegisters.Contains(Meta) Or (IsInformationRegister And Meta.WriteMode
		= Metadata.ObjectProperties.RegisterWriteMode.RecorderSubordinate)
		Or Metadata.Sequences.Contains(Meta) Then
		Row = Dimensions.Add();
		Row.Name         = "Recorder";
		Row.ValueType = Documents.AllRefsType();
		Row.Title   = NStr("ru = 'Регистратор'; en = 'Recorder'");
	EndIf;
	
	// Period
	If IsInformationRegister AND Meta.MainFilterOnPeriod Then
		Row = Dimensions.Add();
		Row.Name         = "Period";
		Row.ValueType = New TypeDescription("Date");
		Row.Title   = NStr("ru = 'Период'; en = 'Period'");
	EndIf;
	
	// Dimensions
	If IsInformationRegister Then
		For Each MetaDimension In Meta.Dimensions Do
			Row = Dimensions.Add();
			Row.Name         = MetaDimension.Name;
			Row.ValueType = MetaDimension.Type;
			Row.Title   = MetaDimension.Presentation();
		EndDo;
	EndIf;
	
	// Recalculation
	If Metadata.CalculationRegisters.Contains(Meta.Parent()) Then
		Row = Dimensions.Add();
		Row.Name         = "RecalculationObject";
		Row.ValueType = Documents.AllRefsType();
		Row.Title   = NStr("ru = 'Объект перерасчета'; en = 'Recalculation object'");
	EndIf;
	
	Return Dimensions;
EndFunction

// Adds columns to the FormTable.
//
// Parameters:
//    FormTable   - FormItem - an item linked to an attribute. The data columns adds to this item.
//    Save - String - a list of column names, separated by commas.
//    Add - Array of Structure - contains structures that describe columns to add.
//    		* Name - new column name. 
//    		* ValueType - new column value type.
//    		* Title - new column title.
//    ColumnGroup - FormItem - (optional) a column group to add new columns.
//
Procedure AddColumnsToFormTable(FormTable, Save, Add, ColumnGroup = Undefined) Export
	
	Form = FormItemForm(FormTable);
	FormItems = Form.Items;
	TableAttributeName = FormTable.DataPath;
	
	ToSave = New Structure(Save);
	DataPathsToSave = New Map;
	For Each Item In ToSave Do
		DataPathsToSave.Insert(TableAttributeName + "." + Item.Key, True);
	EndDo;
	
	IsDynamicList = False;
	For Each Attribute In Form.GetAttributes() Do
		If Attribute.Name = TableAttributeName And Attribute.ValueType.ContainsType(Type("DynamicList")) Then
			IsDynamicList = True;
			Break;
		EndIf;
	EndDo;

	// If TableForm is not a dynamic list.
	If Not IsDynamicList Then
		ToDelete = New Array;
		
		// Deleting attributes not included in Save.
		For Each Attribute In Form.GetAttributes(TableAttributeName) Do
			CurName = Attribute.Name;
			If Not ToSave.Property(CurName) Then
				ToDelete.Add(Attribute.Path + "." + CurName);
			EndIf;
		EndDo;
		
		ToAdd = New Array;
		For Each Column In Add Do
			CurName = Column.Name;
			If Not ToSave.Property(CurName) Then
				ToAdd.Add( New FormAttribute(CurName, Column.ValueType, TableAttributeName, Column.Title) );
			EndIf;
		EndDo;
		
		Form.ChangeAttributes(ToAdd, ToDelete);
	EndIf;
	
	// Deleting form items
	Parent = ?(ColumnGroup = Undefined, FormTable, ColumnGroup);
	
	Delete = New Array;
	For Each Item In Parent.ChildItems Do
		Delete.Add(Item);
	EndDo;
	For Each Item In Delete Do
		If TypeOf(Item) <> Type("FormGroup") And DataPathsToSave[Item.DataPath] = Undefined Then
			FormItems.Delete(Item);
		EndIf;
	EndDo;
	
	// Creating form items
	Prefix = FormTable.Name;
	For Each Column In Add Do
		CurName = Column.Name;
		FormItem = FormItems.Insert(Prefix + CurName, Type("FormField"), Parent);
		FormItem.Type = FormFieldType.InputField;
		FormItem.DataPath = TableAttributeName + "." + CurName;
		FormItem.Title = Column.Title;
	EndDo;
	
EndProcedure	

// Returns a detailed object presentation.
//
// Parameters:
//    - PresentationObject - AnyRef - an object whose presentation is retrieved.
//
// Return value:
//      String - an object presentation.
//
Function RefPresentation(ObjectToGetPresentation) Export
	
	If TypeOf(ObjectToGetPresentation) = Type("String") Then
		// Metadata
		Meta = Metadata.FindByFullName(ObjectToGetPresentation);
		Result = Meta.Presentation();
		If Metadata.Constants.Contains(Meta) Then
			Result = Result + " (constant)";
		EndIf;
		Return Result;
	EndIf;
	
	// Ref
	Result = "";
	If Metadata.CommonModules.Find("Common") <> Undefined Then
		Try
			Result = Eval("UT_Common.SubjectString(ObjectToGetPresentation)");
		Except
		EndTry;
	EndIf;

	If IsBlankString(Result) AND ObjectToGetPresentation <> Undefined AND Not ObjectToGetPresentation.IsEmpty() Then
		Meta = ObjectToGetPresentation.Metadata();
		If Metadata.Documents.Contains(Meta) Then
			Result = String(ObjectToGetPresentation);
		Else
			Presentation = Meta.ObjectPresentation;
			If IsBlankString(Presentation) Then
				Presentation = Meta.Presentation();
			EndIf;
			Result = String(ObjectToGetPresentation);
			If Not IsBlankString(Presentation) Then
				Result = Result + " (" + Presentation + ")";
			EndIf;
		EndIf;
	EndIf;
	
	If IsBlankString(Result) Then
		Result = NStr("ru = 'не задано'; en = 'not specified'");
	EndIf;
	
	Return Result;
EndFunction

// Returns a flag specifying whether the infobase runs in file mode.
// 
// Return value:
//       Boolean - if true, then the infobase runs in file mode.

Function IsFileInfobase() Export
	Return StrFind(InfoBaseConnectionString(), "File=") > 0;
EndFunction

//  Reads current data from the dynamic list by its setting and returns it as a value table.
//
// Parameters:
//    - DataSource - DynamicList - a form attribute.
//
// Return value:
//      ValueTable - the current data of the dynamic list.
//
Function DynamicListCurrentData(DataSource) Export
	
	CompositionSchema = New DataCompositionSchema;
	
	Source = CompositionSchema.DataSources.Add();
	Source.Name = "Source";
	Source.DataSourceType = "local";
	
	Set = CompositionSchema.DataSets.Add(Type("DataCompositionSchemaDataSetQuery"));
	Set.Query = DataSource.QueryText;
	Set.AutoFillAvailableFields = True;
	Set.DataSource = Source.Name;
	Set.Name = Source.Name;
	
	SettingsSource = New DataCompositionAvailableSettingsSource(CompositionSchema);
	Composer = New DataCompositionSettingsComposer;
	Composer.Initialize(SettingsSource);
	
	CurSettings = Composer.Settings;
	
	// Selected fields
	For Each Item In CurSettings.Selection.SelectionAvailableFields.Items Do
		If Not Item.Folder Then
			Field = CurSettings.Selection.Items.Add(Type("DataCompositionSelectedField"));
			Field.Use = True;
			Field.Field = Item.Field;
		EndIf;
	EndDo;
	Folder = CurSettings.Structure.Add(Type("DataCompositionGroup"));
	Folder.Selection.Items.Add(Type("DataCompositionAutoSelectedField"));

	// Filter
	CopyDataCompositionFilter(CurSettings.Filter, DataSource.Filter);

	// Display
	TemplateComposer = New DataCompositionTemplateComposer;
	Template = TemplateComposer.Execute(CompositionSchema, CurSettings, , , Type(
		"DataCompositionValueCollectionTemplateGenerator"));
	Toller = New DataCompositionProcessor;
	Toller.Initialize(Template);
	Output  = New DataCompositionResultValueCollectionOutputProcessor;
	
	Result = New ValueTable;
	Output.SetObject(Result); 
	Output.Output(Toller);
	
	Return Result;
EndFunction

// Reading settings from the common storage.
// 
// Parameters:
//      SettingKey - String - (optional) a key for reading settings.
//
Procedure ReadSettings(SettingKey = "") Export
	
	ObjectKey = Metadata().FullName() + ".Form.Form";
	
	CurrentSettings = CommonSettingsStorage.Load(ObjectKey);
	If TypeOf(CurrentSettings) <> Type("Map") Then
		// Defaults
		CurrentSettings = New Map;
		CurrentSettings.Insert("RegisterRecordAutoRecordSetting", False);
		CurrentSettings.Insert("SequenceAutoRecordSetting", False);
		CurrentSettings.Insert("QueryExternalDataProcessorAddressSetting", "");
		CurrentSettings.Insert("ObjectExportControlSetting", True); // Check using SSL.
		CurrentSettings.Insert("MessageNumberOptionSetting", 0); // First exchange execution
	EndIf;
	
	RegisterRecordAutoRecordSetting = CurrentSettings["RegisterRecordAutoRecordSetting"];
	SequenceAutoRecordSetting = CurrentSettings["SequenceAutoRecordSetting"];
	QueryExternalDataProcessorAddressSetting = CurrentSettings["QueryExternalDataProcessorAddressSetting"];
	ObjectExportControlSetting = CurrentSettings["ObjectExportControlSetting"];
	MessageNumberOptionSetting = CurrentSettings["MessageNumberOptionSetting"];

	CheckSettingsCorrectness(SettingKey);
EndProcedure

// Sets SSL support flags.
//
Procedure ReadSSLSupportFlags() Export
	ConfigurationSupportsSSL = SSL_RequiredVersionAvailable();
	
	If ConfigurationSupportsSSL Then
		// Performing registration with an external registration interface.
		RegisterWithSSLMethodsAvailable  = SSL_RequiredVersionAvailable("2.1.5.11");
	Else
		RegisterWithSSLMethodsAvailable = False;
	EndIf;
EndProcedure

// Writing settings to the common storage.
//
// Parameters:
//      SettingKey - String - (optional) a key for saving settings.
//
Procedure SaveSettings(SettingKey = "") Export
	
	ObjectKey = Metadata().FullName() + ".Form.Form";
	
	CurrentSettings = New Map;
	CurrentSettings.Insert("RegisterRecordAutoRecordSetting",            RegisterRecordAutoRecordSetting);
	CurrentSettings.Insert("SequenceAutoRecordSetting", SequenceAutoRecordSetting);
	CurrentSettings.Insert("QueryExternalDataProcessorAddressSetting",      QueryExternalDataProcessorAddressSetting);
	CurrentSettings.Insert("ObjectExportControlSetting",           ObjectExportControlSetting);
	CurrentSettings.Insert("MessageNumberOptionSetting",             MessageNumberOptionSetting);
	
	CommonSettingsStorage.Save(ObjectKey, "", CurrentSettings)
EndProcedure	

// Checks settings. Resets incorrect settings.
//
// Parameters:
//      SettingKey - String - (optional) a key of setting to check.
// Returns:
//     Structure - Key - a setting name.
//                 Value - String, Undefined - error description.
//
Function CheckSettingsCorrectness(SettingKey = "") Export
	
	Result = New Structure("HasErrors,
		|RegisterRecordAutoRecordSetting, SequenceAutoRecordSetting, 
		|QueryExternalDataProcessorAddressSetting, ObjectExportControlSetting,
		|MessageNumberOptionSetting",
		False);
		
	// Checking whether an external data processor is available.
	If IsBlankString(QueryExternalDataProcessorAddressSetting) Then
		// Setting an empty string value to the QueryExternalDataProcessorAddressSetting.
		QueryExternalDataProcessorAddressSetting = "";
		
	ElsIf Lower(Right(TrimAll(QueryExternalDataProcessorAddressSetting), 4)) = ".epf" Then
		// External data processor file.
		File = New File(QueryExternalDataProcessorAddressSetting);
		If Not File.Exist() Then
			Text = NStr("ru = 'Файл ""%1"" не доступен %2'; en = 'File %1 is not available %2'");

			Text = StrReplace(Text, "%1", QueryExternalDataProcessorAddressSetting);
			If IsFileInfobase() Then
				FileLocatiion = "";
			Else
				FileLocatiion = NStr("ru='на сервере'; en = 'at server'");
			EndIf;

			Text = StrReplace(Text, "%2", FileLocatiion);
			Result.QueryExternalDataProcessorAddressSetting = Text;

			Result.HasErrors = True;
		EndIf;

	Else
		// Data processor is a part of the configuration
		If Metadata.DataProcessors.Find(QueryExternalDataProcessorAddressSetting) = Undefined Then
			Text = NStr("ru = 'Обработка ""%1"" не найдена в составе конфигурации'; en = 'Data processor %1 is not found in the configuration'");
			Result.QueryExternalDataProcessorAddressSetting = StrReplace(Text, "%1", QueryExternalDataProcessorAddressSetting);
			
			Result.HasErrors = True;
		EndIf;
		
	EndIf;
	
	Return Result;
EndFunction

// Служебное для регистрации в подключаемых обработках
//
Функция СведенияОВнешнейОбработке() Экспорт

	Инфо = Новый Структура("Вид, Команды, БезопасныйРежим, Назначение, Наименование, Версия, Информация, ВерсияБСП",
		"СозданиеСвязанныхОбъектов", Новый ТаблицаЗначений, Истина, Новый Массив);

	Инфо.Наименование = НСтр("ru='Регистрация изменений для обмена данными'");
	Инфо.Версия       = "0.1";
	Инфо.ВерсияБСП    = "1.2.1.4";
	Инфо.Информация   = НСтр("ru='"
		+ "Обработка для управления регистрацией объектов на узлах обмена до формирования выгрузки. "
		+ "При работе в составе конфигурации с БСП версии 2.1.2.0 и старше производит контроль "
		+ "ограничений миграции данных для узлов обмена." + "'");

	Инфо.Назначение.Добавить("ПланыОбмена.*");
	Инфо.Назначение.Добавить("Константы.*");
	Инфо.Назначение.Добавить("Справочники.*");
	Инфо.Назначение.Добавить("Документы.*");
	Инфо.Назначение.Добавить("Последовательности.*");
	Инфо.Назначение.Добавить("ПланыВидовХарактеристик.*");
	Инфо.Назначение.Добавить("ПланыСчетов.*");
	Инфо.Назначение.Добавить("ПланыВидовРасчета.*");
	Инфо.Назначение.Добавить("РегистрыСведений.*");
	Инфо.Назначение.Добавить("РегистрыНакопления.*");
	Инфо.Назначение.Добавить("РегистрыБухгалтерии.*");
	Инфо.Назначение.Добавить("РегистрыРасчета.*");
	Инфо.Назначение.Добавить("БизнесПроцессы.*");
	Инфо.Назначение.Добавить("Задачи.*");

	Колонки = Инфо.Команды.Колонки;
	ТипСтрока = Новый ОписаниеТипов("Строка");
	Колонки.Добавить("Представление", ТипСтрока);
	Колонки.Добавить("Идентификатор", ТипСтрока);
	Колонки.Добавить("Использование", ТипСтрока);
	Колонки.Добавить("Модификатор", ТипСтрока);
	Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));
	
	// Единственная команда, что делать - определяем по типу переданного
	Команда = Инфо.Команды.Добавить();
	Команда.Представление = НСтр("ru='Редактирование регистрации изменений объекта'");
	Команда.Идентификатор = "ОткрытьФормуРедактированияРегистрации";
	Команда.Использование = "ОткрытиеФормы";

	Возврат Инфо;
КонецФункции

////////////////////////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ
//

//
// Копирует отбор компоновки данных
//
Процедура СкопироватьОтборКомпоновкиДанных(ГруппаПриемник, ГруппаИсточник)

	КоллекцияИсточник = ГруппаИсточник.Элементы;
	КоллекцияПриемник = ГруппаПриемник.Элементы;
	Для Каждого Элемент Из КоллекцияИсточник Цикл
		ТипЭлемента  = ТипЗнч(Элемент);
		НовыйЭлемент = КоллекцияПриемник.Добавить(ТипЭлемента);

		ЗаполнитьЗначенияСвойств(НовыйЭлемент, Элемент);
		Если ТипЭлемента = Тип("ГруппаЭлементовОтбораКомпоновкиДанных") Тогда
			СкопироватьОтборКомпоновкиДанных(НовыйЭлемент, Элемент);
		КонецЕсли
		;

	КонецЦикла;

КонецПроцедуры

// Выполняет непосредственное действие с конечным объектом
//
Процедура ВыполнитьКомандуРегистрацииОбъекта(Знач Команда, Знач Узел, Знач ОбъектРегистрации)

	Если ТипЗнч(Команда) = Тип("Булево") Тогда
		Если Команда Тогда
			// Регистрация
			Если НастройкаВариантНомераСообщения = 1 Тогда
				// Как отправленного
				Команда = 1 + Узел.НомерОтправленного;
			Иначе
				// Как нового
				ЗарегистрироватьИзменения(Узел, ОбъектРегистрации);
			КонецЕсли;
		Иначе
			// Отмена регистрации
			ПланыОбмена.УдалитьРегистрациюИзменений(Узел, ОбъектРегистрации);
		КонецЕсли;
	КонецЕсли;

	Если ТипЗнч(Команда) = Тип("Число") Тогда
		// Одиночная регистрация с указанным номером сообщения
		Если Команда = 0 Тогда
			// Аналогично регистрации нового
			ЗарегистрироватьИзменения(Узел, ОбъектРегистрации);
		Иначе
			// Изменение номера регистрации, БСП не проверяем
			ПланыОбмена.ЗарегистрироватьИзменения(Узел, ОбъектРегистрации);
			Выборка = ПланыОбмена.ВыбратьИзменения(Узел, Команда, ОбъектРегистрации);
			Пока Выборка.Следующий() Цикл
				// Выбираем изменения для простановки номера сообщения обмена данными
			КонецЦикла;
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

Процедура ЗарегистрироватьИзменения(Знач Узел, Знач ОбъектРегистрации)

	Если Не ДоступнаРегистрацияСредствамиБСП Тогда
		ПланыОбмена.ЗарегистрироватьИзменения(Узел, ОбъектРегистрации);
	КонецЕсли;
		
	// Заводим на регистрацию в БСП всегда, необходимы дополнительные действия
	МодульБСП = Вычислить("ОбменДаннымиСобытия");
	
	// На входе или объект метаданных или непосредственно объект
	Если ТипЗнч(ОбъектРегистрации) = Тип("ОбъектМетаданных") Тогда
		Характеристики = ХарактеристикиПоМетаданным(ОбъектРегистрации);
		Если Характеристики.ЭтоСсылка Тогда
			Выборка = Характеристики.Менеджер.Выбрать();
			Пока Выборка.Следующий() Цикл
				МодульБСП.ЗарегистрироватьИзмененияДанных(Узел, Выборка.Ссылка,
					ЭтотОбъект.НастройкаКонтрольВыгрузкиОбъектов);
			КонецЦикла;
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	// Обычный объект
	МодульБСП.ЗарегистрироватьИзмененияДанных(Узел, ОбъектРегистрации, ЭтотОбъект.НастройкаКонтрольВыгрузкиОбъектов);
КонецПроцедуры

// Возвращает управляемую форму, которой принадлежит элемент
//
Функция ФормаЭлементаФормы(ЭлементФормы)
	Результат = ЭлементФормы;
	//@skip-warning
	ТипыФормы = Новый ОписаниеТипов("УправляемаяФорма");
	Пока Не ТипыФормы.СодержитТип(ТипЗнч(Результат)) Цикл
		Результат = Результат.Родитель;
	КонецЦикла;
	Возврат Результат;
КонецФункции

// Внутренняя для формирования группы метаданных (например справочников) в дереве метаданных
//
Процедура СформироватьУровеньМетаданных(ТекущийНомерСтроки, Параметры, ИндексКартинки, ИндексКартинкиУзлов,
	ДобавлятьПодчиненные, ИмяМета, ПредставлениеМета)

	ПредставленияУровня = Новый Массив;
	Авторегистрации     = Новый Массив;
	ИменаУровня         = Новый Массив;

	ВсеСтроки = Параметры.Строки;
	МетаПлан  = Параметры.ПланОбмена;

	СтрокаГруппа = ВсеСтроки.Добавить();
	СтрокаГруппа.ИдентификаторСтроки = ТекущийНомерСтроки;

	СтрокаГруппа.МетаПолноеИмя  = ИмяМета;
	СтрокаГруппа.Наименование   = ПредставлениеМета;
	СтрокаГруппа.ИндексКартинки = ИндексКартинки;

	Строки = СтрокаГруппа.Строки;
	БылиПодчиненные = Ложь;

	Для Каждого Мета Из Метаданные[ИмяМета] Цикл

		Если МетаПлан = Неопределено Тогда
			// Без учета плана обмена
			БылиПодчиненные = Истина;
			МетаПолноеИмя   = Мета.ПолноеИмя();
			Наименование    = Мета.Представление();
			Если ДобавлятьПодчиненные Тогда
				НовСтрока = Строки.Добавить();
				НовСтрока.МетаПолноеИмя  = МетаПолноеИмя;
				НовСтрока.Наименование   = Наименование;
				НовСтрока.ИндексКартинки = ИндексКартинкиУзлов;

				ТекущийНомерСтроки = ТекущийНомерСтроки + 1;
				НовСтрока.ИдентификаторСтроки = ТекущийНомерСтроки;
			КонецЕсли;
			ИменаУровня.Добавить(МетаПолноеИмя);
			ПредставленияУровня.Добавить(Наименование);

		Иначе
			Элемент = МетаПлан.Состав.Найти(Мета);
			Если Элемент <> Неопределено Тогда
				БылиПодчиненные = Истина;
				МетаПолноеИмя   = Мета.ПолноеИмя();
				Наименование    = Мета.Представление();
				Авторегистрация = ?(Элемент.Авторегистрация = АвтоРегистрацияИзменений.Запретить, 1, 2);
				Если ДобавлятьПодчиненные Тогда
					НовСтрока = Строки.Добавить();
					НовСтрока.МетаПолноеИмя   = МетаПолноеИмя;
					НовСтрока.Наименование    = Наименование;
					НовСтрока.ИндексКартинки  = ИндексКартинкиУзлов;
					НовСтрока.Авторегистрация = Авторегистрация;

					ТекущийНомерСтроки = ТекущийНомерСтроки + 1;
					НовСтрока.ИдентификаторСтроки = ТекущийНомерСтроки;
				КонецЕсли;
				ИменаУровня.Добавить(МетаПолноеИмя);
				ПредставленияУровня.Добавить(Наименование);
				Авторегистрации.Добавить(Авторегистрация);
			КонецЕсли;
		КонецЕсли;

	КонецЦикла;

	Если БылиПодчиненные Тогда
		Строки.Сортировать("Наименование");
		Параметры.СтруктураИмен.Вставить(ИмяМета, ИменаУровня);
		Параметры.СтруктураПредставлений.Вставить(ИмяМета, ПредставленияУровня);
		Если Не ДобавлятьПодчиненные Тогда
			Параметры.СтруктураАвторегистрации.Вставить(ИмяМета, Авторегистрации);
		КонецЕсли;
	Иначе
		// Виды объектов без регистрации не вставляем
		ВсеСтроки.Удалить(СтрокаГруппа);
	КонецЕсли;

КонецПроцедуры

// Накапливаем результаты регистраций
//
Процедура ДобавитьРезультаты(Приемник, Источник)
	Приемник.Успешно = Приемник.Успешно + Источник.Успешно;
	Приемник.Всего   = Приемник.Всего + Источник.Всего;
КонецПроцедуры	

// Возвращает массив дополнительно регистрируемых объектов согласно флагам
//
Функция ПолучитьДополнительныеОбъектыРегистрации(ОбъектРегистрации, УзелКонтроляАвторегистрации, БезАвторегистрации,
	ИмяТаблицы = Неопределено)
	Результат = Новый Массив;
	
	// Смотрим на глобальные параметры
	Если (Не НастройкаАвторегистрацияДвижений) И (Не SequenceAutoRecordSetting) Тогда
		Возврат Результат;
	КонецЕсли;

	ТипЗначения = ТипЗнч(ОбъектРегистрации);
	НаВходеИмя = ТипЗначения = Тип("Строка");
	Если НаВходеИмя Тогда
		Описание = ХарактеристикиПоМетаданным(ОбъектРегистрации);
	ИначеЕсли ТипЗначения = Тип("Структура") Тогда
		Описание = ХарактеристикиПоМетаданным(ИмяТаблицы);
		Если Описание.ЭтоПоследовательность Тогда
			Возврат Результат;
		КонецЕсли;
	Иначе
		Описание = ХарактеристикиПоМетаданным(ОбъектРегистрации.Метаданные());
	КонецЕсли;

	МетаОбъект = Описание.Метаданные;
	
	// Коллекцию рекурсивно	
	Если Описание.ЭтоКоллекция Тогда
		Для Каждого Мета Из МетаОбъект Цикл
			ДополнительныйНабор = ПолучитьДополнительныеОбъектыРегистрации(Мета.ПолноеИмя(),
				УзелКонтроляАвторегистрации, БезАвторегистрации, ИмяТаблицы);
			Для Каждого Элемент Из ДополнительныйНабор Цикл
				Результат.Добавить(Элемент);
			КонецЦикла;
		КонецЦикла;
		Возврат Результат;
	КонецЕсли;
	
	// Одиночное
	СоставУзла = УзелКонтроляАвторегистрации.Метаданные().Состав;
	
	// Документы. Могут влиять на последовательности и движения
	Если Метаданные.Документы.Содержит(МетаОбъект) Тогда

		Если НастройкаАвторегистрацияДвижений Тогда
			Для Каждого Мета Из МетаОбъект.Движения Цикл

				ЭлементСостава = СоставУзла.Найти(Мета);
				Если ЭлементСостава <> Неопределено И (БезАвторегистрации Или ЭлементСостава.Авторегистрация
					= АвтоРегистрацияИзменений.Разрешить) Тогда
					Если НаВходеИмя Тогда
						Результат.Добавить(Мета);
					Иначе
						Описание = ХарактеристикиПоМетаданным(Мета);
						Набор = Описание.Менеджер.СоздатьНаборЗаписей();
						Набор.Отбор.Регистратор.Установить(ОбъектРегистрации);
						Набор.Прочитать();
						Результат.Добавить(Набор);
						// И проверим полученный набор рекурсивно
						ДополнительныйНабор = ПолучитьДополнительныеОбъектыРегистрации(Набор,
							УзелКонтроляАвторегистрации, БезАвторегистрации, ИмяТаблицы);
						Для Каждого Элемент Из ДополнительныйНабор Цикл
							Результат.Добавить(Элемент);
						КонецЦикла;
					КонецЕсли;
				КонецЕсли;

			КонецЦикла;
		КонецЕсли;

		Если SequenceAutoRecordSetting Тогда
			Для Каждого Мета Из Метаданные.Последовательности Цикл

				Описание = ХарактеристикиПоМетаданным(Мета);
				Если Мета.Документы.Содержит(МетаОбъект) Тогда
					// Последовательность регистрируется для данного документа
					ЭлементСостава = СоставУзла.Найти(Мета);
					Если ЭлементСостава <> Неопределено И (БезАвторегистрации Или ЭлементСостава.Авторегистрация
						= АвтоРегистрацияИзменений.Разрешить) Тогда
						// Регистрируется на этом узле
						Если НаВходеИмя Тогда
							Результат.Добавить(Мета);
						Иначе
							Набор = Описание.Менеджер.СоздатьНаборЗаписей();
							Набор.Отбор.Регистратор.Установить(ОбъектРегистрации);
							Набор.Прочитать();
							Результат.Добавить(Набор);
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;

			КонецЦикла;

		КонецЕсли;
		
	// Записи регистров. Могут влиять на последовательности
	ИначеЕсли SequenceAutoRecordSetting И (Метаданные.РегистрыСведений.Содержит(МетаОбъект)
		Или Метаданные.РегистрыНакопления.Содержит(МетаОбъект) Или Метаданные.РегистрыБухгалтерии.Содержит(МетаОбъект)
		Или Метаданные.РегистрыРасчета.Содержит(МетаОбъект)) Тогда
		Для Каждого Мета Из Метаданные.Последовательности Цикл
			Если Мета.Движения.Содержит(МетаОбъект) Тогда
				// Последовательность регистрируется для набора записей
				ЭлементСостава = СоставУзла.Найти(Мета);
				Если ЭлементСостава <> Неопределено И (БезАвторегистрации Или ЭлементСостава.Авторегистрация
					= АвтоРегистрацияИзменений.Разрешить) Тогда
					Результат.Добавить(Мета);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;

	КонецЕсли;

	Возврат Результат;
КонецФункции

// Преобразует строку в число
//
// Параметры:
//     Текст - Строка - строковое представление числа
// 
// Возвращаемое значение:
//     Число        - преобразованная строка
//     Неопределено - если строка не может быть преобразована
//
Функция СтрокаВЧисло(Знач Текст)
	ТекстЧисла = СокрЛП(СтрЗаменить(Текст, Символы.НПП, ""));

	Если ПустаяСтрока(ТекстЧисла) Тогда
		Возврат 0;
	КонецЕсли;
	
	// Ведущие нули
	Позиция = 1;
	Пока Сред(ТекстЧисла, Позиция, 1) = "0" Цикл
		Позиция = Позиция + 1;
	КонецЦикла;
	ТекстЧисла = Сред(ТекстЧисла, Позиция);
	
	// Проверяем на результат по умолчанию
	Если ТекстЧисла = "0" Тогда
		Результат = 0;
	Иначе
		ТипЧисло = Новый ОписаниеТипов("Число");
		Результат = ТипЧисло.ПривестиЗначение(ТекстЧисла);
		Если Результат = 0 Тогда
			// Результат по умолчанию обработан выше, это ошибка преобразования
			Результат = Неопределено;
		КонецЕсли;
	КонецЕсли;

	Возврат Результат;
КонецФункции

// Возвращает флаг того, что БСП в текущей конфигурации обеспечивает функционал
//
Функция БСП_ДоступнаТребуемаяВерсия(Знач Версия = Неопределено) Экспорт

	НужнаяВерсия = СтрЗаменить(?(Версия = Неопределено, "2.1.2", Версия), ".", Символы.ПС);

	Попытка
		ТекущаяВерсия = Вычислить("СтандартныеПодсистемыСервер.ВерсияБиблиотеки()");
	Исключение
		// Отсутствует или поломан метод определения версии, считаем БСП недоступной
		Возврат Ложь;
	КонецПопытки;

	ТекущаяВерсия = СтрЗаменить(ТекущаяВерсия, ".", Символы.ПС);

	Для Индекс = 1 По СтрЧислоСтрок(НужнаяВерсия) Цикл

		ЧастьТекущейВерсии = СтрокаВЧисло(СтрПолучитьСтроку(ТекущаяВерсия, Индекс));
		ЧастьНужнойВерсии  = СтрокаВЧисло(СтрПолучитьСтроку(НужнаяВерсия, Индекс));

		Если ЧастьТекущейВерсии = Неопределено Тогда
			Возврат Ложь;
		ИначеЕсли ЧастьТекущейВерсии > ЧастьНужнойВерсии Тогда
			Возврат Истина;
		ИначеЕсли ЧастьТекущейВерсии < ЧастьНужнойВерсии Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;

	Возврат Истина;
КонецФункции

// Возвращает флаг контроля объекта в БСП
//
Функция БСП_КонтрольВыгрузкиОбъекта(Узлы, ОбъектРегистрации)
	Отправка = ОтправкаЭлементаДанных.Авто;
	Выполнить ("ОбменДаннымиСобытия.ПриОтправкеДанныхКорреспонденту(ОбъектРегистрации, Отправка, , Узлы)");
	Возврат Отправка <> ОтправкаЭлементаДанных.Удалить;
КонецФункции

// Проверяет ссылку на возможность регистрации изменения в БСП.
// Возвращает структуру с полями "Всего" и "Успешно", описывающей количества регистраций
//
Функция БСП_РегистрацияИзмененийСсылки(Узел, Ссылка, БезУчетаАвторегистрации = Истина)

	Результат = Новый Структура("Всего, Успешно", 0, 0);

	Если БезУчетаАвторегистрации Тогда
		СоставУзла = Неопределено;
	Иначе
		СоставУзла = Узел.Метаданные().Состав;
	КонецЕсли;

	ЭлементСостава = ?(СоставУзла = Неопределено, Неопределено, СоставУзла.Найти(Ссылка.Метаданные()));
	Если ЭлементСостава = Неопределено Или ЭлементСостава.Авторегистрация = АвтоРегистрацияИзменений.Разрешить Тогда
		// Сам объект
		Результат.Всего = 1;
		ОбъектРегистрации = Ссылка.ПолучитьОбъект();
		// Для битых ссылок ОбъектРегистрации будет Неопределено
		Если ОбъектРегистрации = Неопределено Или БСП_КонтрольВыгрузкиОбъекта(Узел, ОбъектРегистрации) Тогда
			ВыполнитьКомандуРегистрацииОбъекта(Истина, Узел, Ссылка);
			Результат.Успешно = 1;
		КонецЕсли;
		ОбъектРегистрации = Неопределено;
	КонецЕсли;	
	
	// Смотрим опциональные варианты
	Если Результат.Успешно > 0 Тогда
		Для Каждого Элемент Из ПолучитьДополнительныеОбъектыРегистрации(Ссылка, Узел, БезУчетаАвторегистрации) Цикл
			Результат.Всего = Результат.Всего + 1;
			Если БСП_КонтрольВыгрузкиОбъекта(Узел, Элемент) Тогда
				ВыполнитьКомандуРегистрацииОбъекта(Истина, Узел, Элемент);
				Результат.Успешно = Результат.Успешно + 1;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Возврат Результат;
КонецФункции

// Проверяет набор значений на возможность регистрации изменения в БСП.
// Возвращает структуру с полями "Всего" и "Успешно", описывающей количества регистраций
//
Функция БСП_РегистрацияИзмененийНабора(Узел, СтруктураПолей, Описание, БезУчетаАвторегистрации = Истина)

	Результат = Новый Структура("Всего, Успешно", 0, 0);

	Если БезУчетаАвторегистрации Тогда
		СоставУзла = Неопределено;
	Иначе
		СоставУзла = Узел.Метаданные().Состав;
	КонецЕсли;

	ЭлементСостава = ?(СоставУзла = Неопределено, Неопределено, СоставУзла.Найти(Описание.Метаданные));
	Если ЭлементСостава = Неопределено Или ЭлементСостава.Авторегистрация = АвтоРегистрацияИзменений.Разрешить Тогда
		Результат.Всего = 1;

		Набор = Описание.Менеджер.СоздатьНаборЗаписей();
		Для Каждого КлючЗначение Из СтруктураПолей Цикл
			Набор.Отбор[КлючЗначение.Ключ].Установить(КлючЗначение.Значение);
		КонецЦикла;
		Набор.Прочитать();

		Если БСП_КонтрольВыгрузкиОбъекта(Узел, Набор) Тогда
			ВыполнитьКомандуРегистрацииОбъекта(Истина, Узел, Набор);
			Результат.Успешно = 1;
		КонецЕсли;

	КонецЕсли;
	
	// Смотрим опциональные варианты
	Если Результат.Успешно > 0 Тогда
		Для Каждого Элемент Из ПолучитьДополнительныеОбъектыРегистрации(Набор, Узел, БезУчетаАвторегистрации) Цикл
			Результат.Всего = Результат.Всего + 1;
			Если БСП_КонтрольВыгрузкиОбъекта(Узел, Элемент) Тогда
				ВыполнитьКомандуРегистрацииОбъекта(Истина, Узел, Элемент);
				Результат.Успешно = Результат.Успешно + 1;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Возврат Результат;
КонецФункции

// Проверяет константу на возможность регистрации изменения в БСП.
// Возвращает структуру с полями "Всего" и "Успешно", описывающей количества регистраций
//
Функция БСП_РегистрацияИзмененийКонстанты(Узел, Описание, БезУчетаАвторегистрации = Истина)

	Результат = Новый Структура("Всего, Успешно", 0, 0);

	Если БезУчетаАвторегистрации Тогда
		СоставУзла = Неопределено;
	Иначе
		СоставУзла = Узел.Метаданные().Состав;
	КонецЕсли;

	ЭлементСостава = ?(СоставУзла = Неопределено, Неопределено, СоставУзла.Найти(Описание.Метаданные));
	Если ЭлементСостава = Неопределено Или ЭлементСостава.Авторегистрация = АвтоРегистрацияИзменений.Разрешить Тогда
		Результат.Всего = 1;
		ОбъектРегистрации = Описание.Менеджер.СоздатьМенеджерЗначения();
		Если БСП_КонтрольВыгрузкиОбъекта(Узел, ОбъектРегистрации) Тогда
			ВыполнитьКомандуРегистрацииОбъекта(Истина, Узел, ОбъектРегистрации);
			Результат.Успешно = 1;
		КонецЕсли;

	КонецЕсли;

	Возврат Результат;
КонецФункции

// Проверяет набор метаданных на возможность регистрации изменения в БСП.
// Возвращает структуру с полями "Всего" и "Успешно", описывающей количества регистраций
//
Функция БСП_РегистрацияИзмененийМетаданных(Узел, Описание, БезУчетаАвторегистрации)

	Результат = Новый Структура("Всего, Успешно", 0, 0);

	Если Описание.ЭтоКоллекция Тогда
		Для Каждого МетаВид Из Описание.Метаданные Цикл
			ТекОписание = ХарактеристикиПоМетаданным(МетаВид);
			ДобавитьРезультаты(Результат, БСП_РегистрацияИзмененийМетаданных(Узел, ТекОписание,
				БезУчетаАвторегистрации));
		КонецЦикла;
	Иначе
		;
		ДобавитьРезультаты(Результат, БСП_РегистрацияИзмененийОбъектаМетаданных(Узел, Описание,
			БезУчетаАвторегистрации));
	КонецЕсли;

	Возврат Результат;
КонецФункции

// Проверяет объект метаданных на возможность регистрации изменения в БСП.
// Возвращает структуру с полями "Всего" и "Успешно", описывающей количества регистраций
//
Функция БСП_РегистрацияИзмененийОбъектаМетаданных(Узел, Описание, БезУчетаАвторегистрации)

	Результат = Новый Структура("Всего, Успешно", 0, 0);

	ЭлементСостава = Узел.Метаданные().Состав.Найти(Описание.Метаданные);
	Если ЭлементСостава = Неопределено Тогда
		// Вообще не регистрируется
		Возврат Результат;
	КонецЕсли;

	Если (Не БезУчетаАвторегистрации) И ЭлементСостава.Авторегистрация <> АвтоРегистрацияИзменений.Разрешить Тогда
		// Отсечение по авторегистрации
		Возврат Результат;
	КонецЕсли;

	ТекИмяТаблицы = Описание.ИмяТаблицы;
	Если Описание.ЭтоКонстанта Тогда
		ДобавитьРезультаты(Результат, БСП_РегистрацияИзмененийКонстанты(Узел, Описание));
		Возврат Результат;

	ИначеЕсли Описание.ЭтоСсылка Тогда
		ПоляИзмерений = "Ссылка";

	ИначеЕсли Описание.ЭтоНабор Тогда
		ПоляИзмерений = "";
		Для Каждого Строка Из ИзмеренияНабораЗаписей(ТекИмяТаблицы) Цикл
			ПоляИзмерений = ПоляИзмерений + "," + Строка.Имя;
		КонецЦикла
		;
		ПоляИзмерений = Сред(ПоляИзмерений, 2);

	Иначе
		Возврат Результат;
	КонецЕсли;

	Запрос = Новый Запрос("
						  |ВЫБРАТЬ РАЗЛИЧНЫЕ 
						  |	" + ?(ПустаяСтрока(ПоляИзмерений), "*", ПоляИзмерений) + "
																						|ИЗ 
																						|	" + ТекИмяТаблицы + "
																												 |");
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Если Описание.ЭтоНабор Тогда
			Данные = Новый Структура(ПоляИзмерений);
			ЗаполнитьЗначенияСвойств(Данные, Выборка);
			ДобавитьРезультаты(Результат, БСП_РегистрацияИзмененийНабора(Узел, Данные, Описание));
		ИначеЕсли Описание.ЭтоСсылка Тогда
			ДобавитьРезультаты(Результат, БСП_РегистрацияИзмененийСсылки(Узел, Выборка.Ссылка, БезУчетаАвторегистрации));
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;
КонецФункции

#КонецЕсли