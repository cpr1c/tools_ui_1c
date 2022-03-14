// Generates metadata objects table with common settings
//
// Return value:
//   ValueTable - Table with columns:
//   	 * Type								- String  - Object metadata type.
//       * FullName             			- String  - Object mefatada full name.
//       * ItemPresentation 				- String  - Item presentation for user.
//       * ListPresentation					- String  - List presentation for user.
//       * Delete                			- Boolean - True, if metadata object has Delete prefix.
//       * DuplicatesSearchParametersEvent	- Boolean - True, if metadata object has DuplicatesSearchParameters event subscription.
//       * OnDuplicatesSearchEvent 			- Boolean - True, if metadata object has OnDuplicatesSearch event subscription.
//       * ItemsReplaceCapabilityEvent		- Boolean - True, if metadata object has ItemsReplaceCapability event subscription.
//
Function MetadataObjectSettings() Export
	Settings = New ValueTable;
	Settings.Columns.Add("Type", New TypeDescription("String"));
	Settings.Columns.Add("FullName", New TypeDescription("String"));
	Settings.Columns.Add("ItemPresentation", New TypeDescription("String"));
	Settings.Columns.Add("ListPresentation", New TypeDescription("String"));
	Settings.Columns.Add("Delete", New TypeDescription("Boolean"));
	Settings.Columns.Add("DuplicatesSearchParametersEvent", New TypeDescription("Boolean"));
	Settings.Columns.Add("OnDuplicatesSearchEvent", New TypeDescription("Boolean"));
	Settings.Columns.Add("ItemsReplaceCapabilityEvent", New TypeDescription("Boolean"));

	AllAttachedEvents = New Map;
//	DuplicateObjectsDetectionOverridable.OnDefineObjectsWithSearchForDuplicates(AllAttachedEvents);

	RegisterMetadataCollection(Settings, AllAttachedEvents, Metadata.Catalogs, "Catalog");
	RegisterMetadataCollection(Settings, AllAttachedEvents, Metadata.Documents, "Document");
	RegisterMetadataCollection(Settings, AllAttachedEvents, Metadata.ChartsOfAccounts, "ChartOfAccounts");
	RegisterMetadataCollection(Settings, AllAttachedEvents, Metadata.ChartsOfCalculationTypes,
		"ChartOfCalculationTypes");

	Result = Settings.Copy(New Structure("Delete", False));
	Result.Sort("ListPresentation");

	Return Result;
EndFunction

Procedure RegisterMetadataCollection(Settings, AllAttachedEvents, MetadataCollection, Type)
	StandardProperties = New Structure("ObjectPresentation, ExtendedObjectPresentation, ListPresentation, ExtendedListPresentation");

	For Each MetadataObject In MetadataCollection Do
//		If Not AccessRight("View", MetadataObject)
//			Or Not Common.MetadataObjectAvailableByFunctionalOptions(MetadataObject) Then
//			Continue; // Access denied.
//		EndIf;

		TableRow = Settings.Add();
		TableRow.Type = Type;
		TableRow.FullName = MetadataObject.FullName();
		TableRow.Delete = StrStartsWith(MetadataObject.Name, "Delete");

		FillPropertyValues(StandardProperties, MetadataObject);
		If ValueIsFilled(StandardProperties.ObjectPresentation) Then
			TableRow.ItemPresentation = StandardProperties.ObjectPresentation;
		ElsIf ValueIsFilled(StandardProperties.ExtendedObjectPresentation) Then
			TableRow.ItemPresentation = StandardProperties.ExtendedObjectPresentation;
		Else
			TableRow.ItemPresentation = MetadataObject.Presentation();
		EndIf;
		If ValueIsFilled(StandardProperties.ListPresentation) Then
			TableRow.ListPresentation = StandardProperties.ListPresentation;
		ElsIf ValueIsFilled(StandardProperties.ExtendedListPresentation) Then
			TableRow.ListPresentation = StandardProperties.ExtendedListPresentation;
		Else
			TableRow.ListPresentation = MetadataObject.Presentation();
		EndIf;

		Events = AllAttachedEvents[TableRow.FullName];
		If TypeOf(Events) = Type("String") Then
			If IsBlankString(Events) Then
				TableRow.DuplicatesSearchParametersEvent    = True;
				TableRow.OnDuplicatesSearchEvent            = True;
				TableRow.ItemsReplaceCapabilityEvent 		= True;
			Else
				TableRow.DuplicatesSearchParametersEvent    = StrFind(Events, "DuplicatesSearchParameters") > 0;
				TableRow.OnDuplicatesSearchEvent            = StrFind(Events, "OnDuplicatesSearch") > 0;
				TableRow.ItemsReplaceCapabilityEvent 		= StrFind(Events, "ItemsReplaceCapability") > 0;
			EndIf;
		EndIf;
	EndDo;
EndProcedure