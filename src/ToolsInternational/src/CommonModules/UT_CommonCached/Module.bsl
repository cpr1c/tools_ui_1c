#Region InternalProceduresAndFunctions

// Returns the correspondence of the names of the "functional" subsystems and the value True.
// The "Functional" subsystem has the "Include in command interface" checkbox unchecked.
//
Function SubsytemsNames() Export

	DisabledSubsystems = New Map;

	Names = New Map;
	InsertChildSybsystemsNames(Names, Metadata, DisabledSubsystems);

	Return New FixedMap(Names);

EndFunction

// Allows you to virtually disable subsystems for testing purposes.
// If the subsystem is disabled, then the function of SSL Common.SubsystemExists return False.
// SSL - Common.SubsystemExists function cannot be used in this procedure because this leads to recursion
// 
// Parameters:
//   DisabledSybsystems - Map - the key specifies the name of the subsystem to be disabled, 
//   and the value is must to set to True., 
//                                         
Procedure InsertChildSybsystemsNames(Names, ParentSubsystem, DisabledSubsystems,ParentSubsystemName = "")

	For Each CurrentSubSystem IN ParentSubsystem.Subsystems Do

		If CurrentSubSystem.IncludeInCommandInterface Then
			Continue;
		EndIf;

		CurrentSubSystemName = ParentSubsystemName + CurrentSubSystem.Name;
		If DisabledSubsystems.Get(CurrentSubSystemName) = True Then
			Continue;
		Else
			Names.Insert(CurrentSubSystemName, True);
		EndIf;

		If CurrentSubSystem.Subsystems.Count() = 0 Then
			Continue;
		Endif;

		InsertChildSybsystemsNames(Names, CurrentSubSystem, DisabledSubsystems, CurrentSubSystemName + ".");
	EndDo;

EndProcedure

Function DefaultLanguageCode() Export
	Return Metadata.DefaultLanguage.LanguageCode;
EndFunction

// Returns the correspondence of the names of predefined values to their references.
//
// Parameters:
//  FullMetadataObjectName - String, for example, "Catalog.ProductsKinds",
//                     Only tables with predefined elements are supported:
//                               - Catalogs,
//                               - Charts Of Characteristic Types,
//                               - Charts Of Accounts,
//                               - Charts Of Calculation Types.
// 
// Returned value:
//  FixedMap, Undefined, Where
//      * Key     - String - predefined item name,
//      * Value   - Ref, Null - ref of  predefined or Null, if object not exist in DataBase.
// If there is an error in the metadata name or an unsuitable metadata type, it is returned Undefined.
// If there are no predefined metadata, then an empty fixedmap is returned.
// If a predefined one is defined in the metadata, but not created in the DataBase, Null is returned for it fixedmap.

Function RefsByPredefinedItemsNames(FullMetadataObjectName) Export

	PredefinedValues = New Map;

	ObjectMetaData = Metadata.FindByFullName(FullMetadataObjectName);
	
	// If Metadata is not exist
	If ObjectMetaData = Undefined Then
		Return Undefined;
	EndIf;
	
	// If  unsuitable metadata type
	If not Metadata.Catalogs.Contains(ObjectMetaData) And Not Metadata.ChartsOfCharacteristicTypes.Contains(
		ObjectMetaData) and not Metadata.ChartsOfAccounts.Contains(ObjectMetaData)
		and Not Metadata.ChartsOfCalculationTypes.Contains(ObjectMetaData) Then

		Return Undefined;
	EndIf;

	PredefinedNames = ObjectMetaData.GetPredefinedNames();
	
	// If no predefined metadata.
	If PredefinedNames.Count() = 0 Then
		Return New FixedMap(PredefinedValues);
	EndIf;
	
	// Predefined one is defined in the metadata, but not created in the DataBase.
	For Each PredefinedName In PredefinedNames Do
		PredefinedValues.Insert(PredefinedName, Null);
	EndDo;

	Query = New Query;
	Query.Text =
	"SELECT
	|	CurrentTable.Ref AS Ref,
	|	CurrentTable.PredefinedDataName AS PredefinedDataName
	|FROM
	|	&CurrentTable AS CurrentTable
	|WHERE
	|	CurrentTable.Predefined";

	Query.Text = StrReplace(Query.Text, "&CurrentTable", FullMetadataObjectName);

	SetSafeModeDisabled(True);
	SetPrivilegedMode(True);

	Selection = Query.Execute().Select();

	SetPrivilegedMode(False);
	SetSafeModeDisabled(False);
	
	// Filing of items that is presened in DataBase.
	While Selection.Next() do
		PredefinedValues.Insert(Selection.PredefinedDataName, Selection.Ссылка);
	EndDo;

	Return New FixedMap (PredefinedValues);

EndFunction

Function AllRefsTypeDescription() Export

	TypesArray = BusinessProcesses.RoutePointsAllRefsType().Types();
	AddTypesByMetaDataObjectTypes(TypesArray, "Catalogs", "Catalog");
	AddTypesByMetaDataObjectTypes(TypesArray, "Documents", "Document");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfCharacteristicTypes", "ChartOfCharacteristicTypes");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfCalculationTypes", "ChartOfCalculationTypes");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfAccounts", "ChartOfAccounts");
	AddTypesByMetaDataObjectTypes(TypesArray, "BusinessProcesses", "BusinessProcess");
	AddTypesByMetaDataObjectTypes(TypesArray, "Tasks", "Task");
	AddTypesByMetaDataObjectTypes(TypesArray, "ExchangePlans", "ExchangePlan");
	AddTypesByMetaDataObjectTypes(TypesArray, "Enumerations", "Enumeration");
	Return New TypeDescription(TypesArray);

EndFunction

Function CommonModule(Name) Export
	Return UT_Common.CommonModule(Name);
EndFunction

Function DataBaseObjectEditorAvalibleObjectsTypes() Export
	//Avalible to editing 
	//Catalogs,Documents,ChartsOfCharacteristicTypes,ChartsOfAccounts,ChartsOfCalculationTypes, BusinessProcesses, Tasks, ExchangePlans

	TypesArray=New Array;
	AddTypesByMetaDataObjectTypes(TypesArray, "Catalogs", "Catalog");
	AddTypesByMetaDataObjectTypes(TypesArray, "Documents", "Document");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfCharacteristicTypes", "ChartOfCharacteristicTypes");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfCalculationTypes", "ChartOfCalculationTypes");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfAccounts", "ChartOfAccounts");
	AddTypesByMetaDataObjectTypes(TypesArray, "BusinessProcesses", "BusinessProcess");
	AddTypesByMetaDataObjectTypes(TypesArray, "Tasks", "Task");
	AddTypesByMetaDataObjectTypes(TypesArray, "ExchangePlans", "ExchangePlan");

	Return TypesArray;
EndFunction

Procedure AddTypesByMetaDataObjectTypes(TypesArray, MetadataJbjectTypeName, TypeName)
	For each MdObject in Metadata[MetadataJbjectTypeName] do
		TypesArray.Add(Type(StrTemplate("%1Ref.%2", TypeName, MdObject.Name)));
	enddo;
EndProcedure

Function HTMLFieldBasedOnWebkit() export
	UT_CommonClientServer.HTMLFieldBasedOnWebkit();
EndFunction

#EndRegion