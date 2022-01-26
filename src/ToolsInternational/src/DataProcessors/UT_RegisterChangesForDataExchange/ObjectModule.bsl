#If Server Or ThickClientOrdinaryApplication Or ExternalConnection Then

////////////////////////////////////////////////////////////////////////////////////////////////////
// PROGRAM INTERFACE
//

// Returns a value tree that contains data required to select a node. The tree has two levels:
// exchange plan -> exchange nodes. Internal nodes are not included in the tree. 
//
// Parameters:
//    DataObject - AnyRef, Structure - a reference or a structure that contains record set dimensions. 
//                   Data to analyze exchange nodes. If DataObject is not specified, all metadata objects are used.
//    TableName   - String - if DataObject is a structure, then the table name is for  records set.
//
// Returns:
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
//    ExchangePlanName - String - name of the exchange plan metadata that is used to generate a configuration tree.
//                     - ExchangePlanRef - the configuration tree is generated for its exchange plan.
//                     - Undefined - the tree of all configuration is generated.
//
// Returns:
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
// Returns:
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
// Returns:
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
//    TableName        - String - if RegistrationObject is a structure, then contains a table name for dimensions set.
//
// Returns:
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
//     TableName - String - if Data is a structure, then contains a table name.
//
// Returns:
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

// Returns the beginning of the full form name to open by the passed object.
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

// Чтение реквизитов узла обмена.
//
// Параметры:
//    - Ссылка - Ссылка на узел обмена
//    - Данные - Список имен реквизитов для чтения через запятую
//
// Возвращает структуру с данными или Неопределено, если нет данных по переданной ссылке
//
Функция ПолучитьПараметрыУзлаОбмена(Ссылка, Данные) Экспорт
	Запрос = Новый Запрос("
						  |ВЫБРАТЬ " + Данные + " ИЗ " + Ссылка.Метаданные().ПолноеИмя() + "
																						   |ГДЕ Ссылка=&Ссылка
																						   |");
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Времянка = Запрос.Выполнить().Выгрузить();
	Если Времянка.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;

	Результат = Новый Структура(Данные);
	ЗаполнитьЗначенияСвойств(Результат, Времянка[0]);
	Возврат Результат;
КонецФункции	

// Запись реквизитов узла обмена.
//
// Параметры:
//    - Ссылка - Ссылка на узел обмена
//    - Данные - Список имен реквизитов для чтения через запятую
//
Процедура УстановитьПараметрыУзлаОбмена(Ссылка, Данные) Экспорт

	ОбъектУзла = Ссылка.ПолучитьОбъект();
	Если ОбъектУзла = Неопределено Тогда
		// Ссылка на удаленный объект
		Возврат;
	КонецЕсли;

	Изменен = Ложь;
	Для Каждого Элемент Из Данные Цикл
		Если ОбъектУзла[Элемент.Ключ] <> Элемент.Значение Тогда
			Изменен = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Если Изменен Тогда
		ЗаполнитьЗначенияСвойств(ОбъектУзла, Данные);
		ОбъектУзла.Записать();
	КонецЕсли;
КонецПроцедуры

// Возвращает описание данных по имени таблицы/полному имени метаданных или метаданным
//
// Параметры:
//    - ИмяТаблицы - Имя таблицы, например "Справочник.Валюты"
//
Функция ХарактеристикиПоМетаданным(ИмяТаблицыМетаданных) Экспорт

	ЭтоПоследовательность = Ложь;
	ЭтоКоллекция          = Ложь;
	ЭтоКонстанта          = Ложь;
	ЭтоСсылка             = Ложь;
	ЭтоНабор              = Ложь;
	Менеджер              = Неопределено;
	ИмяТаблицы            = "";

	Если ТипЗнч(ИмяТаблицыМетаданных) = Тип("Строка") Тогда
		Мета = МетаданныеПоПолномуИмени(ИмяТаблицыМетаданных);
		ИмяТаблицы = ИмяТаблицыМетаданных;
	ИначеЕсли ТипЗнч(ИмяТаблицыМетаданных) = Тип("Тип") Тогда
		Мета = Метаданные.НайтиПоТипу(ИмяТаблицыМетаданных);
		ИмяТаблицы = Мета.ПолноеИмя();
	Иначе
		Мета = ИмяТаблицыМетаданных;
		ИмяТаблицы = Мета.ПолноеИмя();
	КонецЕсли;

	Если Мета = Метаданные.Константы Тогда
		ЭтоКоллекция = Истина;
		ЭтоКонстанта = Истина;
		Менеджер     = Константы;

	ИначеЕсли Мета = Метаданные.Справочники Тогда
		ЭтоКоллекция = Истина;
		ЭтоСсылка    = Истина;
		Менеджер      = Справочники;

	ИначеЕсли Мета = Метаданные.Документы Тогда
		ЭтоКоллекция = Истина;
		ЭтоСсылка    = Истина;
		Менеджер     = Документы;

	ИначеЕсли Мета = Метаданные.Перечисления Тогда
		ЭтоКоллекция = Истина;
		ЭтоСсылка    = Истина;
		Менеджер     = Перечисления;

	ИначеЕсли Мета = Метаданные.ПланыВидовХарактеристик Тогда
		ЭтоКоллекция = Истина;
		ЭтоСсылка    = Истина;
		Менеджер     = ПланыВидовХарактеристик;

	ИначеЕсли Мета = Метаданные.ПланыСчетов Тогда
		ЭтоКоллекция = Истина;
		ЭтоСсылка    = Истина;
		Менеджер     = ПланыСчетов;

	ИначеЕсли Мета = Метаданные.ПланыВидовРасчета Тогда
		ЭтоКоллекция = Истина;
		ЭтоСсылка    = Истина;
		Менеджер     = ПланыВидовРасчета;

	ИначеЕсли Мета = Метаданные.БизнесПроцессы Тогда
		ЭтоКоллекция = Истина;
		ЭтоСсылка    = Истина;
		Менеджер     = БизнесПроцессы;

	ИначеЕсли Мета = Метаданные.Задачи Тогда
		ЭтоКоллекция = Истина;
		ЭтоСсылка    = Истина;
		Менеджер     = Задачи;

	ИначеЕсли Мета = Метаданные.Последовательности Тогда
		ЭтоНабор              = Истина;
		ЭтоПоследовательность = Истина;
		ЭтоКоллекция          = Истина;
		Менеджер              = Последовательности;

	ИначеЕсли Мета = Метаданные.РегистрыСведений Тогда
		ЭтоКоллекция = Истина;
		ЭтоНабор     = Истина;
		Менеджер 	 = РегистрыСведений;

	ИначеЕсли Мета = Метаданные.РегистрыНакопления Тогда
		ЭтоКоллекция = Истина;
		ЭтоНабор     = Истина;
		Менеджер     = РегистрыНакопления;

	ИначеЕсли Мета = Метаданные.РегистрыБухгалтерии Тогда
		ЭтоКоллекция = Истина;
		ЭтоНабор     = Истина;
		Менеджер     = РегистрыБухгалтерии;

	ИначеЕсли Мета = Метаданные.РегистрыРасчета Тогда
		ЭтоКоллекция = Истина;
		ЭтоНабор     = Истина;
		Менеджер     = РегистрыРасчета;

	ИначеЕсли Метаданные.Константы.Содержит(Мета) Тогда
		ЭтоКонстанта = Истина;
		Менеджер     = Константы[Мета.Имя];

	ИначеЕсли Метаданные.Справочники.Содержит(Мета) Тогда
		ЭтоСсылка = Истина;
		Менеджер  = Справочники[Мета.Имя];

	ИначеЕсли Метаданные.Документы.Содержит(Мета) Тогда
		ЭтоСсылка = Истина;
		Менеджер  = Документы[Мета.Имя];

	ИначеЕсли Метаданные.Последовательности.Содержит(Мета) Тогда
		ЭтоНабор              = Истина;
		ЭтоПоследовательность = Истина;
		Менеджер              = Последовательности[Мета.Имя];

	ИначеЕсли Метаданные.Перечисления.Содержит(Мета) Тогда
		ЭтоСсылка = Истина;
		Менеджер  = Перечисления[Мета.Имя];

	ИначеЕсли Метаданные.ПланыВидовХарактеристик.Содержит(Мета) Тогда
		ЭтоСсылка = Истина;
		Менеджер  = ПланыВидовХарактеристик[Мета.Имя];

	ИначеЕсли Метаданные.ПланыСчетов.Содержит(Мета) Тогда
		ЭтоСсылка = Истина;
		Менеджер = ПланыСчетов[Мета.Имя];

	ИначеЕсли Метаданные.ПланыВидовРасчета.Содержит(Мета) Тогда
		ЭтоСсылка = Истина;
		Менеджер  = ПланыВидовРасчета[Мета.Имя];

	ИначеЕсли Метаданные.РегистрыСведений.Содержит(Мета) Тогда
		ЭтоНабор = Истина;
		Менеджер = РегистрыСведений[Мета.Имя];

	ИначеЕсли Метаданные.РегистрыНакопления.Содержит(Мета) Тогда
		ЭтоНабор = Истина;
		Менеджер = РегистрыНакопления[Мета.Имя];

	ИначеЕсли Метаданные.РегистрыБухгалтерии.Содержит(Мета) Тогда
		ЭтоНабор = Истина;
		Менеджер = РегистрыБухгалтерии[Мета.Имя];

	ИначеЕсли Метаданные.РегистрыРасчета.Содержит(Мета) Тогда
		ЭтоНабор = Истина;
		Менеджер = РегистрыРасчета[Мета.Имя];

	ИначеЕсли Метаданные.БизнесПроцессы.Содержит(Мета) Тогда
		ЭтоСсылка = Истина;
		Менеджер = БизнесПроцессы[Мета.Имя];

	ИначеЕсли Метаданные.Задачи.Содержит(Мета) Тогда
		ЭтоСсылка = Истина;
		Менеджер = Задачи[Мета.Имя];

	Иначе
		МетаРодитель = Мета.Родитель();
		Если МетаРодитель <> Неопределено И Метаданные.РегистрыРасчета.Содержит(МетаРодитель) Тогда
			// Перерасчет
			ЭтоНабор = Истина;
			Менеджер = РегистрыРасчета[МетаРодитель.Имя].Перерасчеты[Мета.Имя];
		КонецЕсли;

	КонецЕсли;

	Возврат Новый Структура("ИмяТаблицы, Метаданные, Менеджер, ЭтоНабор, ЭтоСсылка, ЭтоКонстанта, ЭтоПоследовательность, ЭтоКоллекция",
		ИмяТаблицы, Мета, Менеджер, ЭтоНабор, ЭтоСсылка, ЭтоКонстанта, ЭтоПоследовательность, ЭтоКоллекция);

КонецФункции

// Возвращает таблицу, описывающую измерения для регистрации изменений набора данных
//
// Параметры:
//    - ИмяТаблицы   - Имя таблицы, например "РегистрСведений.КурсыВалют"
//    - ВсеИзмерения - Флаг того, что для регистра сведений получаем все измерения, а не 
//                     только основные и ведущие
//
// Возвращает таблицу с колонками:
//    - Имя         - Строка имени измерения
//    - ТипЗначения - ОписаниеТипов
//    - Заголовок   - Представление для измерения
//
Функция ИзмеренияНабораЗаписей(ИмяТаблицы, ВсеИзмерения = Ложь) Экспорт

	Если ТипЗнч(ИмяТаблицы) = Тип("Строка") Тогда
		Мета = МетаданныеПоПолномуИмени(ИмяТаблицы);
	Иначе
		Мета = ИмяТаблицы;
	КонецЕсли;
	
	// Определяем ключевые поля
	Измерения = Новый ТаблицаЗначений;
	Колонки = Измерения.Колонки;
	Колонки.Добавить("Имя");
	Колонки.Добавить("ТипЗначения");
	Колонки.Добавить("Заголовок");

	Если Не ВсеИзмерения Тогда
		// Что-то регистрируемое
		НеУчитывать = "НомерСообщения, Узел,";

		Запрос = Новый Запрос("ВЫБРАТЬ * ИЗ " + Мета.ПолноеИмя() + ".Изменения ГДЕ ЛОЖЬ");
		ПустойРезультат = Запрос.Выполнить();
		Для Каждого КолонкаРезультата Из ПустойРезультат.Колонки Цикл
			ИмяКолонки = КолонкаРезультата.Имя;
			Если Найти(НеУчитывать, ИмяКолонки + ",") = 0 Тогда
				Строка = Измерения.Добавить();
				Строка.Имя         = ИмяКолонки;
				Строка.ТипЗначения = КолонкаРезультата.ТипЗначения;

				МетаИзм = Мета.Измерения.Найти(ИмяКолонки);
				Строка.Заголовок = ?(МетаИзм = Неопределено, ИмяКолонки, МетаИзм.Представление());
			КонецЕсли;
		КонецЦикла;

		Возврат Измерения;
	КонецЕсли;
	
	// Все измерения

	ЭтоРегистрСведений = Метаданные.РегистрыСведений.Содержит(Мета);
	
	// Регистратор
	Если Метаданные.РегистрыНакопления.Содержит(Мета) Или Метаданные.РегистрыБухгалтерии.Содержит(Мета)
		Или Метаданные.РегистрыРасчета.Содержит(Мета) Или (ЭтоРегистрСведений И Мета.РежимЗаписи
		= Метаданные.СвойстваОбъектов.РежимЗаписиРегистра.ПодчинениеРегистратору)
		Или Метаданные.Последовательности.Содержит(Мета) Тогда
		Строка = Измерения.Добавить();
		Строка.Имя         = "Регистратор";
		Строка.ТипЗначения = Документы.ТипВсеСсылки();
		Строка.Заголовок   = "Регистратор";
	КонецЕсли;
	
	// Период
	Если ЭтоРегистрСведений И Мета.ОсновнойОтборПоПериоду Тогда
		Строка = Измерения.Добавить();
		Строка.Имя         = "Период";
		Строка.ТипЗначения = Новый ОписаниеТипов("Дата");
		Строка.Заголовок   = "Период";
	КонецЕсли;
	
	// Измерения
	Если ЭтоРегистрСведений Тогда
		Для Каждого МетаИзм Из Мета.Измерения Цикл
			Строка = Измерения.Добавить();
			Строка.Имя         = МетаИзм.Имя;
			Строка.ТипЗначения = МетаИзм.Тип;
			Строка.Заголовок   = МетаИзм.Представление();
		КонецЦикла;
	КонецЕсли;
	
	// Перерасчет
	Если Метаданные.РегистрыРасчета.Содержит(Мета.Родитель()) Тогда
		Строка = Измерения.Добавить();
		Строка.Имя         = "ОбъектПерерасчета";
		Строка.ТипЗначения = Документы.ТипВсеСсылки();
		Строка.Заголовок   = "Объект перерасчета";
	КонецЕсли;

	Возврат Измерения;
КонецФункции

// Модифицирует таблицу формы, добавляя туда колонки
//
// Параметры:
//    - ТаблицаФормы   - Элемент, связанный с данными, в который будут добавлены колонки данных
//    - СохранятьИмена - Список имен колонок, которые будут сохранены, через запятую.
//    - Добавлять      - Коллекция добавляемых колонок  или перечислимое с атрибутами Имя, ТипЗначения, Заголовок
//    - ГруппаКолонок  - Группа колонок, в которую происходит добавление
//
Процедура ДобавитьКолонкиВТаблицуФормы(ТаблицаФормы, СохранятьИмена, Добавлять, ГруппаКолонок = Неопределено) Экспорт

	Форма = ФормаЭлементаФормы(ТаблицаФормы);
	ЭлементыФормы = Форма.Элементы;
	ИмяРеквизитаТаблицы = ТаблицаФормы.ПутьКДанным;

	Сохраняемые = Новый Структура(СохранятьИмена);
	СохраняемыеПутиДанных = Новый Соответствие;
	Для Каждого Элемент Из Сохраняемые Цикл
		СохраняемыеПутиДанных.Вставить(ИмяРеквизитаТаблицы + "." + Элемент.Ключ, Истина);
	КонецЦикла;

	ЭтоДинамическийСписок = Ложь;
	Для Каждого Реквизит Из Форма.ПолучитьРеквизиты() Цикл
		Если Реквизит.Имя = ИмяРеквизитаТаблицы И Реквизит.ТипЗначения.СодержитТип(Тип("ДинамическийСписок")) Тогда
			ЭтоДинамическийСписок = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;

	// Динамический пересоздает реквизиты сам
	Если Не ЭтоДинамическийСписок Тогда
		УдаляемыеИмена = Новый Массив;
		
		// Удаляем все реквизиты, которые не перечислены в СохранятьИмена
		Для Каждого Реквизит Из Форма.ПолучитьРеквизиты(ИмяРеквизитаТаблицы) Цикл
			ТекИмя = Реквизит.Имя;
			Если Не Сохраняемые.Свойство(ТекИмя) Тогда
				УдаляемыеИмена.Добавить(Реквизит.Путь + "." + ТекИмя);
			КонецЕсли;
		КонецЦикла;

		Добавляемые = Новый Массив;
		Для Каждого Колонка Из Добавлять Цикл
			ТекИмя = Колонка.Имя;
			Если Не Сохраняемые.Свойство(ТекИмя) Тогда
				Добавляемые.Добавить( Новый РеквизитФормы(ТекИмя, Колонка.ТипЗначения, ИмяРеквизитаТаблицы,
					Колонка.Заголовок));
			КонецЕсли;
		КонецЦикла;

		Форма.ИзменитьРеквизиты(Добавляемые, УдаляемыеИмена);
	КонецЕсли;
	
	// Удаляем элементы
	Родитель = ?(ГруппаКолонок = Неопределено, ТаблицаФормы, ГруппаКолонок);

	Удалять = Новый Массив;
	Для Каждого Элемент Из Родитель.ПодчиненныеЭлементы Цикл
		Удалять.Добавить(Элемент);
	КонецЦикла;
	Для Каждого Элемент Из Удалять Цикл
		Если ТипЗнч(Элемент) <> Тип("ГруппаФормы") И СохраняемыеПутиДанных[Элемент.ПутьКДанным] = Неопределено Тогда
			ЭлементыФормы.Удалить(Элемент);
		КонецЕсли;
	КонецЦикла;
	
	// Создаем элементы
	Префикс = ТаблицаФормы.Имя;
	Для Каждого Колонка Из Добавлять Цикл
		ТекИмя = Колонка.Имя;
		ЭлФормы = ЭлементыФормы.Вставить(Префикс + ТекИмя, Тип("ПолеФормы"), Родитель);
		ЭлФормы.Вид = ВидПоляФормы.ПолеВвода;
		ЭлФормы.ПутьКДанным = ИмяРеквизитаТаблицы + "." + ТекИмя;
		ЭлФормы.Заголовок = Колонка.Заголовок;
	КонецЦикла;

КонецПроцедуры	

// Возвращает подробное представление объекта.
//
// Параметры:
//    - ОбъектПредставления - Объект, представление которого получаем
//
Функция ПредставлениеСсылки(ОбъектПредставления) Экспорт

	Если ТипЗнч(ОбъектПредставления) = Тип("Строка") Тогда
		// Метаданные 
		Мета = Метаданные.НайтиПоПолномуИмени(ОбъектПредставления);
		Результат = Мета.Представление();
		Если Метаданные.Константы.Содержит(Мета) Тогда
			Результат = Результат + " (константа)";
		КонецЕсли;
		Возврат Результат;
	КонецЕсли;
	
	// Ссылка
	Результат = "";
	Если Метаданные.ОбщиеМодули.Найти("ОбщегоНазначения") <> Неопределено Тогда
		Попытка
			Результат = Вычислить("UT_Common.SubjectString(ОбъектПредставления)");
		Исключение
		КонецПопытки;
	КонецЕсли;

	Если ПустаяСтрока(Результат) И ОбъектПредставления <> Неопределено И Не ОбъектПредставления.Пустая() Тогда
		Мета = ОбъектПредставления.Метаданные();
		Если Метаданные.Документы.Содержит(Мета) Тогда
			Результат = Строка(ОбъектПредставления);
		Иначе
			Представление = Мета.ПредставлениеОбъекта;
			Если ПустаяСтрока(Представление) Тогда
				Представление = Мета.Представление();
			КонецЕсли;
			Результат = Строка(ОбъектПредставления);
			Если Не ПустаяСтрока(Представление) Тогда
				Результат = Результат + " (" + Представление + ")";
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	Если ПустаяСтрока(Результат) Тогда
		Результат = НСтр("ru = 'не задано'");
	КонецЕсли;

	Возврат Результат;
КонецФункции

// Возвращает флаг того, что работа происходит в файловой базе
//
Функция ЭтоФайловаяБаза() Экспорт
	Возврат Найти(СтрокаСоединенияИнформационнойБазы(), "File=") > 0;
КонецФункции

//  Читает текущие данные из динамического списка по его настройкам и возвращает в виде таблицы значений
//
// Параметры:
//    - ИсточникДанных - ДинамическийСписок, реквизит формы
//
Функция ТекущиеДанныеДинамическогоСписка(ИсточникДанных) Экспорт

	СхемаКомпоновки = Новый СхемаКомпоновкиДанных;

	Источник = СхемаКомпоновки.ИсточникиДанных.Добавить();
	Источник.Имя = "Источник";
	Источник.ТипИсточникаДанных = "local";

	Набор = СхемаКомпоновки.НаборыДанных.Добавить(Тип("НаборДанныхЗапросСхемыКомпоновкиДанных"));
	Набор.Запрос = ИсточникДанных.ТекстЗапроса;
	Набор.АвтоЗаполнениеДоступныхПолей = Истина;
	Набор.ИсточникДанных = Источник.Имя;
	Набор.Имя = Источник.Имя;

	ИсточникНастроек = Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновки);
	Компоновщик = Новый КомпоновщикНастроекКомпоновкиДанных;
	Компоновщик.Инициализировать(ИсточникНастроек);

	ТекНастройки = Компоновщик.Настройки;
	
	// Выбранные поля
	Для Каждого Элемент Из ТекНастройки.Выбор.ДоступныеПоляВыбора.Элементы Цикл
		Если Не Элемент.Папка Тогда
			Поле = ТекНастройки.Выбор.Элементы.Добавить(Тип("ВыбранноеПолеКомпоновкиДанных"));
			Поле.Использование = Истина;
			Поле.Поле = Элемент.Поле;
		КонецЕсли;
	КонецЦикла;
	Группа = ТекНастройки.Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
	Группа.Выбор.Элементы.Добавить(Тип("АвтоВыбранноеПолеКомпоновкиДанных"));

	// Отбор
	СкопироватьОтборКомпоновкиДанных(ТекНастройки.Отбор, ИсточникДанных.Отбор);

	// Выводим
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	Макет = КомпоновщикМакета.Выполнить(СхемаКомпоновки, ТекНастройки, , , Тип(
		"ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	Процессор = Новый ПроцессорКомпоновкиДанных;
	Процессор.Инициализировать(Макет);
	Вывод  = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;

	Результат = Новый ТаблицаЗначений;
	Вывод.УстановитьОбъект(Результат);
	Вывод.Вывести(Процессор);

	Возврат Результат;
КонецФункции

// Читаем настройки из общего хранилища
//
Процедура ПрочитатьНастройки(КлючНастройки = "") Экспорт

	КлючОбъекта = Метаданные().ПолноеИмя() + ".Форма.Форма";

	ТекущиеНастройки = ХранилищеОбщихНастроек.Загрузить(КлючОбъекта);
	Если ТипЗнч(ТекущиеНастройки) <> Тип("Соответствие") Тогда
		// Умолчания
		ТекущиеНастройки = Новый Соответствие;
		ТекущиеНастройки.Вставить("RegisterRecordAutoRecordSetting", Ложь);
		ТекущиеНастройки.Вставить("SequenceAutoRecordSetting", Ложь);
		ТекущиеНастройки.Вставить("QueryExternalDataProcessorAddressSetting", "");
		ТекущиеНастройки.Вставить("ObjectExportControlSetting", Истина); // Проверять через БСП
		ТекущиеНастройки.Вставить("MessageNumberOptionSetting", 0);     // Регистрировать как новое
	КонецЕсли;

	НастройкаАвторегистрацияДвижений            = ТекущиеНастройки["RegisterRecordAutoRecordSetting"];
	SequenceAutoRecordSetting = ТекущиеНастройки["SequenceAutoRecordSetting"];
	НастройкаАдресВнешнейОбработкиЗапросов      = ТекущиеНастройки["QueryExternalDataProcessorAddressSetting"];
	НастройкаКонтрольВыгрузкиОбъектов           = ТекущиеНастройки["ObjectExportControlSetting"];
	НастройкаВариантНомераСообщения             = ТекущиеНастройки["MessageNumberOptionSetting"];

	ПроверитьКорректностьНастроек(КлючНастройки);
КонецПроцедуры

// Устанавливаем флаги поддержки БСП
//
Процедура ПрочитатьПризнакПоддержкиБСП() Экспорт
	КонфигурацияПоддерживаетБСП = БСП_ДоступнаТребуемаяВерсия();

	Если КонфигурацияПоддерживаетБСП Тогда
		// Используем внешний интерфейс регистрации
		ДоступнаРегистрацияСредствамиБСП  = БСП_ДоступнаТребуемаяВерсия("2.1.5.11");
	Иначе
		ДоступнаРегистрацияСредствамиБСП = Ложь;
	КонецЕсли;
КонецПроцедуры

// Пишем настройки в общее хранилище
//
Процедура СохранитьНастройки(КлючНастройки = "") Экспорт

	КлючОбъекта = Метаданные().ПолноеИмя() + ".Форма.Форма";

	ТекущиеНастройки = Новый Соответствие;
	ТекущиеНастройки.Вставить("RegisterRecordAutoRecordSetting", НастройкаАвторегистрацияДвижений);
	ТекущиеНастройки.Вставить("SequenceAutoRecordSetting",
		SequenceAutoRecordSetting);
	ТекущиеНастройки.Вставить("QueryExternalDataProcessorAddressSetting", НастройкаАдресВнешнейОбработкиЗапросов);
	ТекущиеНастройки.Вставить("ObjectExportControlSetting", НастройкаКонтрольВыгрузкиОбъектов);
	ТекущиеНастройки.Вставить("MessageNumberOptionSetting", НастройкаВариантНомераСообщения);

	ХранилищеОбщихНастроек.Сохранить(КлючОбъекта, "", ТекущиеНастройки);
КонецПроцедуры	

// Проверяем настройки на корректность, сбрасываем в случае нарушения.
//    Возвращает структуру с ключом - именем настройки, значением содержит описанием ошибки или Неопределено
// при отсутствии ошибки для данного параметра
//
Функция ПроверитьКорректностьНастроек(КлючНастройки = "") Экспорт

	Результат = Новый Структура("ЕстьОшибки,
								|RegisterRecordAutoRecordSetting, SequenceAutoRecordSetting, 
								|QueryExternalDataProcessorAddressSetting, ObjectExportControlSetting,
								|MessageNumberOptionSetting", Ложь);
		
	// Доступность внешней обработки
	Если ПустаяСтрока(НастройкаАдресВнешнейОбработкиЗапросов) Тогда
		// Убираем возможные пробелы, вариант отключен
		НастройкаАдресВнешнейОбработкиЗапросов = "";

	ИначеЕсли НРег(Прав(СокрЛП(НастройкаАдресВнешнейОбработкиЗапросов), 4)) = ".epf" Тогда
		// Файл обработки
		Файл = Новый Файл(НастройкаАдресВнешнейОбработкиЗапросов);
		Если Не Файл.Существует() Тогда
			Текст = НСтр("ru='Файл ""%1"" не доступен %2'");

			Текст = СтрЗаменить(Текст, "%1", НастройкаАдресВнешнейОбработкиЗапросов);
			Если ЭтоФайловаяБаза() Тогда
				РасположениеФайла = "";
			Иначе
				РасположениеФайла = НСтр("ru='на сервере'");
			КонецЕсли;

			Текст = СтрЗаменить(Текст, "%2", РасположениеФайла);
			Результат.QueryExternalDataProcessorAddressSetting = Текст;

			Результат.ЕстьОшибки = Истина;
		КонецЕсли;

	Иначе
		// В составе конфигурации
		Если Метаданные.Обработки.Найти(НастройкаАдресВнешнейОбработкиЗапросов) = Неопределено Тогда
			Текст = НСтр("ru='Обработка ""%1"" не найдена в составе конфигурации'");
			Результат.QueryExternalDataProcessorAddressSetting = СтрЗаменить(Текст, "%1",
				НастройкаАдресВнешнейОбработкиЗапросов);

			Результат.ЕстьОшибки = Истина;
		КонецЕсли;

	КонецЕсли;

	Возврат Результат;
КонецФункции

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