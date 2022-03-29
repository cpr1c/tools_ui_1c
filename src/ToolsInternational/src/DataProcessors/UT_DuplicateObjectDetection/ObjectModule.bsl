///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, 1C-Soft LLC
// All Rights reserved. This application and supporting materials are provided under the terms of 
// Attribution 4.0 International license (CC BY 4.0)
// The license text is available at:
// https://creativecommons.org/licenses/by/4.0/legalcode
// Translated by Neti Company
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Region Internal

// Defines the object manager to call applied rules.
//
// Parameters:
//   DataSearchAreaName - String - area name (full metadata name).
//
// Returns:
//   CatalogsManager, ChartsOfCharacteristicTypesManager,
//   ChartsOfAccountsManager, ChartsOfCalculationTypesManager - Object manager.
//
Function SearchForDuplicatesAreaManager(Val DataSearchAreaName) Export
	Meta = Metadata.FindByFullName(DataSearchAreaName);
	
	If Metadata.Catalogs.Contains(Meta) Then
		Return Catalogs[Meta.Name];
		
	ElsIf Metadata.ChartsOfCharacteristicTypes.Contains(Meta) Then
		Return ChartsOfCharacteristicTypes[Meta.Name];
		
	ElsIf Metadata.ChartsOfAccounts.Contains(Meta) Then
		Return ChartsOfAccounts[Meta.Name];
		
	ElsIf Metadata.ChartsOfCalculationTypes.Contains(Meta) Then
		Return ChartsOfCalculationTypes[Meta.Name];
		
	EndIf;

	Raise StrTemplate(NStr("ru = 'Неизвестный тип объекта метаданных ""%1""'; en = 'Invalid metadata object type: %1.'"), DataSearchAreaName);
EndFunction

// Subsystem presentation. It is used for writing to the event log and in other places.
Function SubsystemDescription(ForUser) Export
	LanguageCode = ?(ForUser, UT_CommonClientServer.DefaultLanguageCode(), "");
	Return NStr("ru = 'Поиск и удаление дублей'; en = 'Duplicate object detection'", LanguageCode);
EndFunction

// Search for duplicates.
//
// Parameters:
//     SearchParameters - Structure - describes search parameters.
//     SampleObject - Arbitrary - an object for which duplicates are searched.
//
// Returns:
//   Structure - Duplicates search results.
//       * DuplicateTable - ValueTable - found duplicates (displayed in the interface in 2 levels: Parents and Items).
//           ** Reference - Arbitrary - an item reference.
//           ** Code - Arbitrary - an item code.
//           ** Description - Arbitrary - item description.
//           ** Parent - Arbitrary - a parent of the duplicates group. If the Parent is empty, the 
//                                            item is parent for the duplicates group.
//           ** <Other fields> - Arbitrary - a value of the relevant filter fields and criteria for comparing duplicates.
//       * ErrorDescription - Undefined - no errors occurred.
//                        - Row - the description of the error that occurred during the search for duplicates.
//       * UsageInstances - Undefined, ValueTable - filled in if
//           SearchParameters.CalculateUsageInstances = True.
//           For the table column details, see Common.UsageInstances().
//
Function DuplicatesGroups(Val SearchParameters, Val SampleObject = Undefined) Export
	FullMetadataObjectName = SearchParameters.DuplicatesSearchArea;
	MetadataObject = Metadata.FindByFullName(FullMetadataObjectName);
	
	// 1. Determining parameters according to the applied code.
	ReturnedBatchSize = UT_CommonClientServer.StructureProperty(SearchParameters,
		"MaxDuplicates");
	If Not ValueIsFilled(ReturnedBatchSize) Then
		ReturnedBatchSize = 0; // Without restriction.
	EndIf;

	CalculateUsageInstances = UT_CommonClientServer.StructureProperty(SearchParameters,
		"CalculateUsageInstances");
	If TypeOf(CalculateUsageInstances) <> Type("Boolean") Then
		CalculateUsageInstances = False;
	EndIf;
	
	// For passing to the applied code.
	AdditionalParameters = UT_CommonClientServer.StructureProperty(SearchParameters,
		"AdditionalParameters");
	
	// Calling the applied rules
	UseAppliedRules = SearchParameters.ConsiderAppliedRules
		And DuplicatesSearchAreaAppliedRules(FullMetadataObjectName);

	EqualityCompareFields = ""; // Names of the attributes to be used for comparison by equality.
	LikeCompareFields   = ""; // Names of the attributes to be used for fuzzy comparison.
	AdditionalDataFields = ""; // Names of the additional attributes defined with the applied rules.
	AppliedBatchSize   = 0;  // Size of the data batch to be passed to the applied rules for calculation.

	If UseAppliedRules Then
		AppliedParameters = New Structure;
		AppliedParameters.Insert("SearchRules",        SearchParameters.SearchRules);
		AppliedParameters.Insert("ComparisonRestrictions", New Array);
		AppliedParameters.Insert("FilterComposer",    SearchParameters.PrefilterComposer);
		AppliedParameters.Insert("ItemsCountToCompare", 1000);

		SearchAreaManager = UT_Common.ObjectManagerByFullName(FullMetadataObjectName);
		SearchAreaManager.DuplicatesSearchParameters(AppliedParameters, AdditionalParameters);

		AllAdditionalFields = New Map;
		For Each Restriction In AppliedParameters.ComparisonRestrictions Do
			For Each KeyValue In New Structure(Restriction.AdditionalFields) Do
				FieldName = KeyValue.Key;
				If AllAdditionalFields[FieldName] = Undefined Then
					AdditionalDataFields = AdditionalDataFields + ", " + FieldName;
					AllAdditionalFields[FieldName] = True;
				EndIf;
			EndDo;
		EndDo;
		AdditionalDataFields = Mid(AdditionalDataFields, 2);
		
		// Size of the data batch to be passed to the applied rules for calculation.
		AppliedBatchSize = AppliedParameters.ItemsCountToCompare;
	EndIf;
	
	// List of fields modified by the applied code.
	For Each Row In SearchParameters.SearchRules Do
		If Row.Rule = "Equal" Then
			EqualityCompareFields = EqualityCompareFields + ", " + Row.Attribute;
		ElsIf Row.Rule = "Like" Then
			LikeCompareFields = LikeCompareFields + ", " + Row.Attribute;
		EndIf
	EndDo;
	EqualityCompareFields = Mid(EqualityCompareFields, 2);
	LikeCompareFields   = Mid(LikeCompareFields, 2);

	IdentityFieldsStructure   = New Structure(EqualityCompareFields);
	SimilarityFieldsStructure        = New Structure(LikeCompareFields);
	AdditionalFieldsStructure = New Structure(AdditionalDataFields);
	
	// 2. Constructing settings composer by modified filter.
	Characteristics = New Structure;
	Characteristics.Insert("CodeLength", 0);
	Characteristics.Insert("NumberLength", 0);
	Characteristics.Insert("DescriptionLength", 0);
	Characteristics.Insert("Hierarchical", False);
	Characteristics.Insert("HierarchyType", Undefined);

	FillPropertyValues(Characteristics, MetadataObject);

	DescriptionExists = Characteristics.DescriptionLength > 0;
	CodeExists          = Characteristics.CodeLength > 0;
	NumberExists        = Characteristics.NumberLength > 0;
	
	// Assignment of aliases for additional fields to avoid field names duplication.
	CandidatesTable = New ValueTable;
	CandidatesColumns = CandidatesTable.Columns;
	CandidatesColumns.Add("Ref1");
	CandidatesColumns.Add("Fields1");
	CandidatesColumns.Add("Ref2");
	CandidatesColumns.Add("Fields2");
	CandidatesColumns.Add("IsDuplicates", New TypeDescription("Boolean"));
	CandidatesTable.Indexes.Add("IsDuplicates");

	FieldsNamesInQuery = AvailableFilterAttributes(MetadataObject);
	If Not CodeExists Then
		If NumberExists Then
			FieldsNamesInQuery = FieldsNamesInQuery + ", Number AS Code";
		Else
			FieldsNamesInQuery = FieldsNamesInQuery + ", UNDEFINED AS Code";
		EndIf;
	EndIf;
	If Not DescriptionExists Then
		FieldsNamesInQuery = FieldsNamesInQuery + ", Ref AS Description";
	EndIf;
	FieldsNamesInChoice  = StrSplit(EqualityCompareFields + "," + LikeCompareFields, ",", False);

	AdditionalFieldsDetails = New Map;
	SequenceNumber = 0;
	For Each KeyValue In AdditionalFieldsStructure Do
		FieldName   = KeyValue.Key;
		Alias = "Addl" + Format(SequenceNumber, "NZ=; NG=") + "_" + FieldName;
		AdditionalFieldsDetails.Insert(Alias, FieldName);
		
		FieldsNamesInQuery = FieldsNamesInQuery + "," + FieldName + " AS " + Alias;
		FieldsNamesInChoice.Add(Alias);
		SequenceNumber = SequenceNumber + 1;
	EndDo;
	
	// Schema filling.
	DCSchema = New DataCompositionSchema;
	
	DCSchemaDataSource = DCSchema.DataSources.Add();
	DCSchemaDataSource.Name = "DataSource1";
	DCSchemaDataSource.DataSourceType = "Local";

	DataSet = DCSchema.DataSets.Add(Type("DataCompositionSchemaDataSetQuery"));
	DataSet.Name = "DataSet1";
	DataSet.DataSource = "DataSource1";
	DataSet.Query = "SELECT ALLOWED " + FieldsNamesInQuery + " FROM " + FullMetadataObjectName;
	DataSet.AutoFillAvailableFields = True;
	
	// Composer initialization.
	DCSettingsComposer = New DataCompositionSettingsComposer;
	DCSettingsComposer.Initialize(New DataCompositionAvailableSettingsSource(DCSchema));
	DCSettingsComposer.LoadSettings(SearchParameters.PrefilterComposer.Settings);
	DCSettings = DCSettingsComposer.Settings;
	
	// Fields.
	DCSettings.Selection.Items.Clear();
	For Each FieldName In FieldsNamesInChoice Do
		DCField = New DataCompositionField(TrimAll(FieldName));
		AvailableDCField = DCSettings.SelectionAvailableFields.FindField(DCField);
		If AvailableDCField = Undefined Then
			WriteLogEvent(SubsystemDescription(False), EventLogLevel.Warning,
				MetadataObject, SampleObject, StrTemplate(НСтр("ru = 'Поле ""%1"" не существует.'; en = 'Field %1 does not exist.'"), String(DCField)));
			Continue;
		EndIf;
		SelectedDCField = DCSettings.Selection.Items.Add(Type("DataCompositionSelectedField"));
		SelectedDCField.Field = DCField;
	EndDo;
	SelectedDCField = DCSettings.Selection.Items.Add(Type("DataCompositionSelectedField"));
	SelectedDCField.Field = New DataCompositionField("Ref");
	SelectedDCField = DCSettings.Selection.Items.Add(Type("DataCompositionSelectedField"));
	SelectedDCField.Field = New DataCompositionField("Code");
	SelectedDCField = DCSettings.Selection.Items.Add(Type("DataCompositionSelectedField"));
	SelectedDCField.Field = New DataCompositionField("Description");
	
	// Sorting.
	DCSettings.Order.Items.Clear();
	DCOrderItem = DCSettings.Order.Items.Add(Type("DataCompositionOrderItem"));
	DCOrderItem.Field = New DataCompositionField("Ref");
	
	// Filters.
	If Characteristics.Hierarchical And Characteristics.HierarchyType
		= Metadata.ObjectProperties.HierarchyType.HierarchyFoldersAndItems Then
		DCFilterItem = DCSettings.Filter.Items.Add(Type("DataCompositionFilterItem"));
		DCFilterItem.LeftValue = New DataCompositionField("IsFolder");
		DCFilterItem.ComparisonType = DataCompositionComparisonType.Equal;
		DCFilterItem.RightValue = False;
	EndIf;
	
//	If MetadataObject = Metadata.Catalogs.Users Then
//		DCFilterItem = DCSettings.Filter.Items.Add(Type("DataCompositionFilterItem"));
//		DCFilterItem.LeftValue  = New DataCompositionField("Internal");
//		DCFilterItem.ComparisonType   = DataCompositionComparisonType.Equal;
//		DCFilterItem.RightValue = False;
//	EndIf;
	
	// Structure.
	DCSettings.Structure.Clear();
	DCGroup = DCSettings.Structure.Add(Type("DataCompositionGroup"));
	DCGroup.Selection.Items.Add(Type("DataCompositionAutoSelectedField"));
	DCGroup.Order.Items.Add(Type("DataCompositionAutoOrderItem"));
	
	// Reading original data.
	If SampleObject = Undefined Then
		SampleObjectsSelection = InitializeDCSelection(DCSchema, DCSettingsComposer.GetSettings());
	Else
		ValueTable = ObjectIntoValueTable(SampleObject, AdditionalFieldsDetails);
		If Not CodeExists And Not NumberExists Then
			ValueTable.Columns.Add("Code", New TypeDescription("Undefined"));
		EndIf;
		SampleObjectsSelection = InitializeVTSelection(ValueTable);
	EndIf;
	
	// Preparing DCS to read the duplicate data.
	CandidatesFilters = New Map;
	FieldsNames = StrSplit(EqualityCompareFields, ",", False);
	For Each FieldName In FieldsNames Do
		FieldName = TrimAll(FieldName);
		DCFilterItem = DCSettings.Filter.Items.Add(Type("DataCompositionFilterItem"));
		DCFilterItem.LeftValue = New DataCompositionField(FieldName);
		DCFilterItem.ComparisonType = DataCompositionComparisonType.Equal;
		CandidatesFilters.Insert(FieldName, DCFilterItem);
	EndDo;
	DCFilterItem = DCSettings.Filter.Items.Add(Type("DataCompositionFilterItem"));
	DCFilterItem.LeftValue = New DataCompositionField("Ref");
	DCFilterItem.ComparisonType = ?(SampleObject = Undefined, DataCompositionComparisonType.Greater,
		DataCompositionComparisonType.NotEqual);
	CandidatesFilters.Insert("Ref", DCFilterItem);
	
	// Result and search cycle
	DuplicatesTable = New ValueTable;
	ResultColumns = DuplicatesTable.Columns;
	ResultColumns.Add("Ref");
	For Each KeyValue In IdentityFieldsStructure Do
		If ResultColumns.Find(KeyValue.Key) = Undefined Then
			ResultColumns.Add(KeyValue.Key);
		EndIf;
	EndDo;
	For Each KeyValue In SimilarityFieldsStructure Do
		If ResultColumns.Find(KeyValue.Key) = Undefined Then
			ResultColumns.Add(KeyValue.Key);
		EndIf;
	EndDo;
	If ResultColumns.Find("Code") = Undefined Then
		ResultColumns.Add("Code");
	EndIf;
	If ResultColumns.Find("Description") = Undefined Then
		ResultColumns.Add("Description");
	EndIf;
	If ResultColumns.Find("Parent") = Undefined Then
		ResultColumns.Add("Parent");
	EndIf;

	DuplicatesTable.Indexes.Add("Ref");
	DuplicatesTable.Indexes.Add("Parent");
	DuplicatesTable.Indexes.Add("Ref, Parent");

	Result = New Structure("DuplicatesTable, ErrorDescription, UsageInstances", DuplicatesTable);

	FieldsStructure = New Structure;
	FieldsStructure.Insert("AdditionalFieldsDetails", AdditionalFieldsDetails);
	FieldsStructure.Insert("IdentityFieldsStructure",     IdentityFieldsStructure);
	FieldsStructure.Insert("SimilarityFieldsStructure",          SimilarityFieldsStructure);
	FieldsStructure.Insert("IdentityFieldsList",        EqualityCompareFields);
	FieldsStructure.Insert("SimilarityFieldsList",             LikeCompareFields);

	While NextSelectionItem(SampleObjectsSelection) Do
		SampleItem = SampleObjectsSelection.CurrentItem;
		
		// Setting filters for candidate selection.
		For Each KeyAndValue In CandidatesFilters Do
			DCFilterItem = KeyAndValue.Value;
			DCFilterItem.RightValue = SampleItem[KeyAndValue.Key];
		EndDo;
		
		// Selection of data candidates from IB.
		CandidatesSelection = InitializeDCSelection(DCSchema, DCSettings);
		DuplicatesCandidates = CandidatesSelection.DCOutputProcessor.Output(CandidatesSelection.DCProcessor);

		If SimilarityFieldsStructure.Count() > 0 Then

			FuzzySearch = UT_Common.AttachAddInFromTemplate("FuzzyStringMatchExtension",
				"CommonTemplate.UT_StringSearchComponent");
			If FuzzySearch = Undefined Then
				Result.ErrorDescription = 
					NStr("ru = 'Не удалось подключить внешнюю компоненту FuzzyStringMatchExtension из макета ""ОбщийМакет.УИ_КомпонентаПоискаСтрок""
					           |Подробнее см. в журнале регистрации.'; 
					           |en = 'Cannot attach add-in FuzzyStringMatchExtension from template CommonTemplate.UT_StringSearchComponent.
					           |For more information, see the event log.'");
				Return Result;
			EndIf;
			For Each KeyValue In SimilarityFieldsStructure Do
				FieldName = KeyValue.Key;
				RequiredRows = StrConcat(DuplicatesCandidates.UnloadColumn(FieldName), "~");
				SearchRow = SampleItem[FieldName];
				RowIndexes = FuzzySearch.StringSearch(Lower(SearchRow), Lower(RequiredRows), "~", 10, 80, 90);
				If IsBlankString(RowIndexes) Then
					Continue;
				EndIf;
				For Each RowIndex In StrSplit(RowIndexes, ",") Do
					If IsBlankString(RowIndex) Then
						Continue;
					EndIf;
					DuplicateItem = DuplicatesCandidates.Get(RowIndex);
					If UseAppliedRules Then
						AddCandidatesRow(CandidatesTable, SampleItem, DuplicateItem, FieldsStructure);
						If CandidatesTable.Count() = AppliedBatchSize Then
							RegisterDuplicatesByAppliedRules(DuplicatesTable, SearchAreaManager, SampleItem, CandidatesTable, 
								FieldsStructure, AdditionalParameters);
							CandidatesTable.Clear();
						EndIf;
					Else
						RegisterDuplicate(DuplicatesTable, SampleItem, DuplicateItem, FieldsStructure);
					EndIf;
				EndDo;
			EndDo;
		Else
			For Each DuplicateItem In DuplicatesCandidates Do
				If UseAppliedRules Then
					AddCandidatesRow(CandidatesTable, SampleItem, DuplicateItem, FieldsStructure);
					If CandidatesTable.Count() = AppliedBatchSize Then
						RegisterDuplicatesByAppliedRules(DuplicatesTable, SearchAreaManager, SampleItem, CandidatesTable, 
							FieldsStructure, AdditionalParameters);
						CandidatesTable.Clear();
					EndIf;
				Else
					RegisterDuplicate(DuplicatesTable, SampleItem, DuplicateItem, FieldsStructure);
				EndIf;
			EndDo;
		EndIf;
		
		// Processing the rest of the applied rules table.
		If UseAppliedRules Then
			RegisterDuplicatesByAppliedRules(DuplicatesTable, SearchAreaManager, SampleItem, CandidatesTable, 
				FieldsStructure, AdditionalParameters);
			CandidatesTable.Clear();
		EndIf;
		
		// Consider restriction.
		If ReturnedBatchSize > 0 AND (DuplicatesTable.Count() > ReturnedBatchSize) Then
			Found = DuplicatesTable.Count();
			// Rolling back the last group.
			For Each Row In DuplicatesTable.FindRows( New Structure("Parent", SampleItem.Ref) ) Do
				DuplicatesTable.Delete(Row);
			EndDo;
			For Each Row In DuplicatesTable.FindRows( New Structure("Ref", SampleItem.Ref) ) Do
				DuplicatesTable.Delete(Row);
			EndDo;
			If Found > 0 AND DuplicatesTable.Count() = 0 Then
				Result.ErrorDescription = NStr("ru = 'Найдено слишком много дублей одного элемента.'; en = 'Too many duplicates of the item were found.'");
			Else
				Result.ErrorDescription = StrTemplate(
					NStr("ru = 'Найдено слишком много дублей. Показаны только первые %1.'; en = 'Too many duplicates were found. First %1 items are shown.'"), ReturnedBatchSize);
			EndIf;
			Break;
		EndIf;
	EndDo;
	
	// Calculating usage instances
	If CalculateUsageInstances Then

		UT_TimeConsumingOperations.ReportProgress(0, "CalculateUsageInstances");

		RefSet = New Array;
		For Each DuplicatesRow In DuplicatesTable Do
			If ValueIsFilled(DuplicatesRow.Ref) Then
				RefSet.Add(DuplicatesRow.Ref);
			EndIf;
		EndDo;
		
		UsageInstances = SearchForReferences(RefSet);
		UsageInstances = UsageInstances.Copy(
			UsageInstances.FindRows(New Structure("AuxiliaryData", False)));
		UsageInstances.Indexes.Add("Ref");
		
		Result.Insert("UsageInstances", UsageInstances);
	EndIf;
	
	Return Result;
EndFunction

// Determining whether the object has applied rules.
//
// Parameters:
//     AreaManager - CatalogManager - a manager of the object to be checked.
//
// Returns:
//     Boolean - True if applied rules are defined.
//
Function DuplicatesSearchAreaAppliedRules(Val ObjectName) Export

	ObjectsList = New Map;
//	DuplicateObjectsDetectionOverridable.OnDefineObjectsWithSearchForDuplicates(ObjectsList);

	ObjectInfo = ObjectsList[ObjectName];
	Return ObjectInfo <> Undefined And (ObjectInfo = "" Or StrFind(ObjectInfo, "DuplicatesSearchParameters") > 0);

EndFunction

// Background duplicate search handler.
//
// Parameters:
//     Parameters    - Structure - data to be analyzed.
//     ResultAddress - String    - a temporary storage address to save the result.
//
Procedure BackgroundSearchForDuplicates(Val Parameters, Val ResultAddress) Export
	
	// Rebuilding the composer from the schema and the settings.
	PrefilterComposer = New DataCompositionSettingsComposer;
	
	PrefilterComposer.Initialize( New DataCompositionAvailableSettingsSource(Parameters.CompositionSchema) );
	PrefilterComposer.LoadSettings(Parameters.PrefilterComposerSettings);
	
	Parameters.Insert("PrefilterComposer", PrefilterComposer);
	
	// Converting search rules to an indexed value table.
	SearchRules = New ValueTable;
	SearchRules.Columns.Add("Attribute", New TypeDescription("String") );
	SearchRules.Columns.Add("Rule",  New TypeDescription("String") );
	SearchRules.Indexes.Add("Attribute");
	
	For Each Rule In Parameters.SearchRules Do
		FillPropertyValues(SearchRules.Add(), Rule);
	EndDo;
	Parameters.Insert("SearchRules", SearchRules);
	
	Parameters.Insert("CalculateUsageInstances", True);
	
	// Starting the search
	Result = DuplicatesGroups(Parameters);
	
	PutToTempStorage(Result, ResultAddress);
	
EndProcedure

#EndRegion

#Region Private

// Background duplicate deletion handler.
//
// Parameters:
//     Parameters    - Structure - data to be analyzed.
//     ResultAddress - String    - a temporary storage address to save the result.
//
Procedure BackgroundDuplicateDeletion(Val Parameters, Val ResultAddress) Export
	
	ReplacementParameters = New Structure;
	ReplacementParameters.Insert("WriteParameters", Parameters.WriteParameters);
	ReplacementParameters.Insert("ConsiderAppliedRules", Parameters.ConsiderAppliedRules);
	ReplacementParameters.Insert("ReplacePairsInTransaction", Parameters.ReplacePairsInTransaction);
	ReplacementParameters.Insert("DeletionMethod", "Check");

	ReplaceReferences(Parameters.ReplacementPairs, ReplacementParameters, ResultAddress);

EndProcedure

// Converts an object to a table for add to a query.
Function ObjectIntoValueTable(Val DataObject, Val AdditionalFieldsDetails)
	Result = New ValueTable;
	DataString = Result.Add();
	
	MetaObject = DataObject.Metadata();
	
	For Each MetaAttribute In MetaObject.StandardAttributes  Do
		Name = MetaAttribute.Name;
		Result.Columns.Add(Name, MetaAttribute.Type);
		DataString[Name] = DataObject[Name];
	EndDo;
	
	For Each MetaAttribute In MetaObject.Attributes Do
		Name = MetaAttribute.Name;
		Result.Columns.Add(Name, MetaAttribute.Type);
		DataString[Name] = DataObject[Name];
	EndDo;
	
	For Each KeyAndValue In AdditionalFieldsDetails Do
		Name1 = KeyAndValue.Key;
		Name2 = KeyAndValue.Value;
		Result.Columns.Add(Name1, Result.Columns[Name2].ValueType);
		DataString[Name1] = DataString[Name2];
	EndDo;
	
	Return Result;
EndFunction

// Additional analysis of candidates for duplicates using the applied method.
//
Procedure RegisterDuplicatesByAppliedRules(ResultTreeRows, Val SearchAreaManager, Val MainData, Val CandidatesTable, Val FieldsStructure, Val AdditionalParameters)
	If CandidatesTable.Count() = 0 Then
		Return;
	EndIf;
	
	SearchAreaManager.OnSearchForDuplicates(CandidatesTable, AdditionalParameters);
	
	Data1 = New Structure;
	Data2 = New Structure;
	
	FoundItems = CandidatesTable.FindRows(New Structure("IsDuplicates", True));
	For Each CandidatesPair In FoundItems Do
		Data1.Insert("Ref",       CandidatesPair.Ref1);
		Data1.Insert("Code",          CandidatesPair.Fields1.Code);
		Data1.Insert("Description", CandidatesPair.Fields1.Description);
		
		Data2.Insert("Ref",       CandidatesPair.Ref2);
		Data2.Insert("Code",          CandidatesPair.Fields2.Code);
		Data2.Insert("Description", CandidatesPair.Fields2.Description);
		
		For Each KeyValue In FieldsStructure.IdentityFieldsStructure Do
			FieldName = KeyValue.Key;
			Data1.Insert(FieldName, CandidatesPair.Fields1[FieldName]);
			Data2.Insert(FieldName, CandidatesPair.Fields2[FieldName]);
		EndDo;
		For Each KeyValue In FieldsStructure.SimilarityFieldsStructure Do
			FieldName = KeyValue.Key;
			Data1.Insert(FieldName, CandidatesPair.Fields1[FieldName]);
			Data2.Insert(FieldName, CandidatesPair.Fields2[FieldName]);
		EndDo;
		
		RegisterDuplicate(ResultTreeRows, Data1, Data2, FieldsStructure);
	EndDo;
EndProcedure

// Adds a row to the candidate table for the applied method.
//
Function AddCandidatesRow(CandidatesTable, Val MainItemData, Val CandidateData, Val FieldsStructure)
	
	Row = CandidatesTable.Add();
	Row.IsDuplicates = False;
	Row.Ref1  = MainItemData.Ref;
	Row.Ref2  = CandidateData.Ref;
	
	Row.Fields1 = New Structure("Code, Description", MainItemData.Code, MainItemData.Description);
	Row.Fields2 = New Structure("Code, Description", CandidateData.Code, CandidateData.Description);
	
	For Each KeyValue In FieldsStructure.IdentityFieldsStructure Do
		FieldName = KeyValue.Key;
		Row.Fields1.Insert(FieldName, MainItemData[FieldName]);
		Row.Fields2.Insert(FieldName, CandidateData[FieldName]);
	EndDo;
	
	For Each KeyValue In FieldsStructure.SimilarityFieldsStructure Do
		FieldName = KeyValue.Key;
		Row.Fields1.Insert(FieldName, MainItemData[FieldName]);
		Row.Fields2.Insert(FieldName, CandidateData[FieldName]);
	EndDo;
	
	For Each KeyValue In FieldsStructure.AdditionalFieldsDetails Do
		ColumnName = KeyValue.Value;
		FieldName    = KeyValue.Key;
		
		Row.Fields1.Insert(ColumnName, MainItemData[FieldName]);
		Row.Fields2.Insert(ColumnName, CandidateData[FieldName]);
	EndDo;
	
	Return Row;
EndFunction

// Adds the found option to the result tree.
//
Procedure RegisterDuplicate(DuplicatesTable, Val Item1, Val Item2, Val FieldsStructure)
	// Defining which item is already added to duplicates.
	DuplicatesRow1 = DuplicatesTable.Find(Item1.Ref, "Ref");
	DuplicatesRow2 = DuplicatesTable.Find(Item2.Ref, "Ref");
	Duplicate1Registered = (DuplicatesRow1 <> Undefined);
	Duplicate2Registered = (DuplicatesRow2 <> Undefined);
	
	// If both items are added to duplicates, do nothing.
	If Duplicate1Registered AND Duplicate2Registered Then
		Return;
	EndIf;
	
	// Determining a duplicates group reference.
	If Duplicate1Registered Then
		DuplicatesGroupsRef = ?(ValueIsFilled(DuplicatesRow1.Parent), DuplicatesRow1.Parent, DuplicatesRow1.Ref);
	ElsIf Duplicate2Registered Then
		DuplicatesGroupsRef = ?(ValueIsFilled(DuplicatesRow2.Parent), DuplicatesRow2.Parent, DuplicatesRow2.Ref);
	Else // Registering a group of duplicates.
		DuplicatesGroup = DuplicatesTable.Add();
		DuplicatesGroup.Ref = Item1.Ref;
		DuplicatesGroupsRef = DuplicatesGroup.Ref;
	EndIf;
	
	PropertiesList = "Ref, Code, Description," + FieldsStructure.IdentityFieldsList + "," + FieldsStructure.SimilarityFieldsList;
	
	If Not Duplicate1Registered Then
		DuplicateInfo = DuplicatesTable.Add();
		FillPropertyValues(DuplicateInfo, Item1, PropertiesList);
		DuplicateInfo.Parent = DuplicatesGroupsRef;
	EndIf;
	
	If Not Duplicate2Registered Then
		DuplicateInfo = DuplicatesTable.Add();
		FillPropertyValues(DuplicateInfo, Item2, PropertiesList);
		DuplicateInfo.Parent = DuplicatesGroupsRef;
	EndIf;

	UT_TimeConsumingOperations.ReportProgress(DuplicatesTable.Count(), "RegisterDuplicate");

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// For offline work.

// [Common.UsageInstances]
Function SearchForReferences(Val RefSet, Val ResultAddress = "")

	Return UT_Common.UsageInstances(RefSet, ResultAddress);

EndFunction

// [Common.ReplaceReferences]
Procedure ReplaceReferences(Val ReplacementPairs, Val Parameters = Undefined, Val ResultAddress = "")

	Result = UT_Common.ReplaceReferences(ReplacementPairs, Parameters);

	If ResultAddress <> "" Then
		PutToTempStorage(Result, ResultAddress);
	EndIf;
	
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Other.

Function AvailableFilterAttributes(MetadataObject)
	AttributesArray = New Array;
	For Each AttributeMetadata In MetadataObject.StandardAttributes Do
		If AttributeMetadata.Type.ContainsType(Type("ValueStorage")) Then
			Continue;
		EndIf;
		AttributesArray.Add(AttributeMetadata.Name);
	EndDo;
	For Each AttributeMetadata In MetadataObject.Attributes Do
		If AttributeMetadata.Type.ContainsType(Type("ValueStorage")) Then
			Continue;
		EndIf;
		AttributesArray.Add(AttributeMetadata.Name);
	EndDo;
	Return StrConcat(AttributesArray, ",");
EndFunction

Function InitializeDCSelection(DCSchema, DCSettings)
	Selection = New Structure("Table, CurrentItem, IndexOf, UBound, DCProcessor, DCOutputProcessor");
	DCTemplateComposer = New DataCompositionTemplateComposer;
	DCTemplate = DCTemplateComposer.Execute(DCSchema, DCSettings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
	
	Selection.DCProcessor = New DataCompositionProcessor;
	Selection.DCProcessor.Initialize(DCTemplate);
	
	Selection.Table = New ValueTable;
	Selection.IndexOf = -1;
	Selection.UBound = -100;
	
	Selection.DCOutputProcessor = New DataCompositionResultValueCollectionOutputProcessor;
	Selection.DCOutputProcessor.SetObject(Selection.Table);
	
	Return Selection;
EndFunction

Function InitializeVTSelection(ValueTable)
	Selection = New Structure("Table, CurrentItem, IndexOf, UBound, DCProcessor, DCOutputProcessor");
	Selection.Table = ValueTable;
	Selection.IndexOf = -1;
	Selection.UBound = ValueTable.Count() - 1;
	Return Selection;
EndFunction

Function NextSelectionItem(Selection)
	If Selection.IndexOf >= Selection.UBound Then
		If Selection.DCProcessor = Undefined Then
			Return False;
		EndIf;
		If Selection.UBound = -100 Then
			Selection.DCOutputProcessor.BeginOutput();
		EndIf;
		Selection.Table.Clear();
		Selection.IndexOf = -1;
		Selection.UBound = -1;
		While Selection.UBound = -1 Do
			DCResultItem = Selection.DCProcessor.Next();
			If DCResultItem = Undefined Then
				Selection.DCOutputProcessor.EndOutput();
				Return False;
			EndIf;
			Selection.DCOutputProcessor.OutputItem(DCResultItem);
			Selection.UBound = Selection.Table.Count() - 1;
		EndDo;
	EndIf;
	Selection.IndexOf = Selection.IndexOf + 1;
	Selection.CurrentItem = Selection.Table[Selection.IndexOf];
	Return True;
EndFunction

#EndRegion