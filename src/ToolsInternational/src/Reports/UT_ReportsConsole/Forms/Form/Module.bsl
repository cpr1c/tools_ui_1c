////////////////////////////////////////////////////////////////////////////////
// Common procedures and funtions 

// Initialize a new report tree.
&AtClientAtServerNoContext
Procedure InitializeReportTree(ReportsTree)

	Items = ReportsTree.GetItems();
	Items.Clear();
	RootItem = Items.Add();
	RootItem.RowType = 4;
	RootItem.Name = NStr("ru = 'Отчеты';en = 'Reports'");

	ElementsToWhichAdd = RootItem.GetItems();

	Name = NStr("ru = 'Отчет';en = 'Report'");
	Item = ElementsToWhichAdd.Add();
	Item.Name = Name;
	Item.RowType = 0;

EndProcedure

// Switch the page of groupings to the page with the text of unavailability.
&AtClient
Procedure GroupFieldsNotAvailable()

	Items.PagesGroupFields.CurrentPage = Items.UnavailableGroupFieldsSettings;

EndProcedure

//Switch the grouping page to a page with the text unavailable for executable settings.
&AtClient
Procedure GroupFieldsNotAvailable1()

	Items.GroupFieldsPages1.CurrentPage = Items.UnavailableGroupFieldsSettings1;

EndProcedure

// Enable availability of selected fields.
//
// Parameters: 
//  SettingsItem - the structure element for which availability is being changed.
&AtClient
Procedure SelectedFieldsAvailable(SettingsItem)

	If Report.SettingsComposer.Settings.HasItemSelection(SettingsItem) Then

		LocalSelectedFields = True;
		Items.PagesSelectedFields.CurrentPage = Items.SelectedFieldsSettings;

	Else

		LocalSelectedFields = False;
		Items.PagesSelectedFields.CurrentPage = Items.SelectedFieldsDisabledSettings;

	EndIf;

	Items.LocalSelectedFields.ReadOnly = False;

EndProcedure

// Enable the availability of selected fields for executable settings.
//
// Parameters: 
//  SettingsItem - the structure element for which availability is being changed.
&AtClient
Procedure SelectedFieldsAvailable1(SettingsItem)

	If ExecutedSettingsComposer.Settings.HasItemSelection(SettingsItem) Then

		LocalSelectedFields1 = True;
		Items.PagesSelectedFields1.CurrentPage = Items.SelectedFieldsSettings1;

	Else

		LocalSelectedFields1 = False;
		Items.PagesSelectedFields1.CurrentPage = Items.DisabledSelectedFieldsSettings1;

	EndIf;

	Items.LocalSelectedFields1.ReadOnly = False;

EndProcedure

// Switch the page of selected fields to the page with the text of unavailability.
&AtClient
Procedure SelectedFieldsUnavailable()

	LocalSelectedFields = False;
	Items.LocalSelectedFields.ReadOnly = True;
	Items.PagesSelectedFields.CurrentPage = Items.UnavailableSelectedFieldsSettings;

EndProcedure

// Switch the page of selected fields to the page with the text of unavailability for executable settings.
&AtClient
Procedure SelectedFieldsUnavailable1()

	LocalSelectedFields1 = False;
	Items.LocalSelectedFields1.ReadOnly = True;
	Items.PagesSelectedFields1.CurrentPage = Items.UnavailableSelectedFieldsSettings1;

EndProcedure

// Enable filter availability.
//
// Parameters: 
//  SettingsItem - the structure element for which availability is being changed.
&AtClient
Procedure FilterAvailable(SettingsItem)

	If Report.SettingsComposer.Settings.HasItemFilter(SettingsItem) Then

		LocalFilter = True;
		Items.FilterPages.CurrentPage = Items.FilterSettings;

	Else

		LocalFilter = False;
		Items.FilterPages.CurrentPage = Items.DisabledFilterSettings;

	EndIf;

	Items.LocalFilter.ReadOnly = False;

EndProcedure

// Enable filter availability for executable settings.
//
// Parameters: 
//  SettingsItem - the structure element for which availability is being changed.
&AtClient
Procedure FilterAvailable1(SettingsItem)

	If ExecutedSettingsComposer.Settings.HasItemFilter(SettingsItem) Then

		LocalFilter1 = True;
		Items.FilterPages1.CurrentPage = Items.FilterSettings1;

	Else

		LocalFilter1 = False;
		Items.FilterPages1.CurrentPage = Items.DisabledFilterSettings1;

	EndIf;

	Items.LocalFilter1.ReadOnly = False;

EndProcedure

// Switch the filter page to the page with the text of unavailability.
&AtClient
Procedure FilterUnavailable()

	LocalFilter = False;
	Items.LocalFilter.ReadOnly = True;
	Items.FilterPages.CurrentPage = Items.UnavailableFilterSettings;

EndProcedure

// Switch the filter page to the page with the text of unavailability for executable settings.
&AtClient
Procedure FilterUnavailable1()

	LocalFilter1 = False;
	Items.LocalFilter1.ReadOnly = True;
	Items.FilterPages1.CurrentPage = Items.UnavailableFilterSettings1;

EndProcedure

// Enable order availability.
//
// Parameters: 
//  SettingsItem - the structure element for which availability is being changed.
&AtClient
Procedure OrderAvailable(SettingsItem)

	If Report.SettingsComposer.Settings.HasItemOrder(SettingsItem) Then

		LocalOrder = True;
		Items.OrderPages.CurrentPage = Items.OrderSettings;

	Else

		LocalOrder = False;
		Items.OrderPages.CurrentPage = Items.DisabledOrderSettings;

	EndIf;

	Items.LocalOrder.ReadOnly = False;

EndProcedure

// Enable order availability for executable settings
//
// Parameters: 
//  SettingsItem - the structure element for which availability is being changed.
&AtClient
Procedure OrderAvailable1(SettingsItem)

	If ExecutedSettingsComposer.Settings.HasItemOrder(SettingsItem) Then

		LocalOrder1 = True;
		Items.OrderPages1.CurrentPage = Items.OrderSettings1;

	Else

		LocalOrder1 = False;
		Items.OrderPages1.CurrentPage = Items.DisabledOrderSettings1;

	EndIf;

	Items.LocalOrder1.ReadOnly = False;

EndProcedure

// Switch the order page to the page with the unavailability text.
&AtClient
Procedure OrderUnavailable()

	LocalOrder = False;
	Items.LocalOrder.ReadOnly = True;
	Items.OrderPages.CurrentPage = Items.UnavailableOrderSettings;

EndProcedure

// Switch the order page to the page with the text of unavailability for executable settings.
&AtClient
Procedure OrderUnavailable1()

	LocalOrder1 = False;
	Items.LocalOrder1.ReadOnly = True;
	Items.OrderPages1.CurrentPage = Items.UnavailableOrderSettings1;

EndProcedure

// Enable  availability Conditional Appearance.
//
// Parameters: 
//  SettingsItem - the structure element for which availability is being changed.
&AtClient
Procedure ConditionalAppearanceAvailable(SettingsItem)

	If Report.SettingsComposer.Settings.HasItemConditionalAppearance(SettingsItem) Then

		LocalConditionalAppearance = True;
		Items.ConditionalAppearancePages.CurrentPage = Items.ConditionalAppearanceSettings;

	Else

		LocalConditionalAppearance = False;
		Items.ConditionalAppearancePages.CurrentPage = Items.DisabledConditionalAppearanceSettings;

	EndIf;

	Items.LocalConditionalAppearance.ReadOnly = False;

EndProcedure

// Enable  availability conditional appearance. for executable settings.
//
// Parameters: 
//  SettingsItem - the structure element for which availability is being changed.
&AtClient
Procedure ConditionalAppearanceAvailable1(SettingsItem)

	If ExecutedSettingsComposer.Settings.HasItemConditionalAppearance(SettingsItem) Then

		LocalConditionalAppearance1 = True;
		Items.ConditionalAppearancePages1.CurrentPage = Items.ConditionalAppearanceSettings1;

	Else

		LocalConditionalAppearance1 = False;
		Items.ConditionalAppearancePages1.CurrentPage = Items.DisabledConditionalAppearanceSettings1;

	EndIf;

	Items.LocalConditionalAppearance1.ReadOnly = False;

EndProcedure

// Switch the conditional appearance page to the page with the text of unavailability..
&AtClient
Procedure ConditionalAppearanceUnavailable()

	LocalConditionalAppearance = False;
	Items.LocalConditionalAppearance.ReadOnly = True;
	Items.ConditionalAppearancePages.CurrentPage = Items.UnavailableConditionalAppearanceSettings;

EndProcedure

// Switch the conditional appearance page to the page with the text of unavailability. for executable settings.
&AtClient
Procedure ConditionalAppearanceUnavailable1()

	LocalConditionalAppearance1 = False;
	Items.LocalConditionalAppearance1.ReadOnly = True;
	Items.ConditionalAppearancePages1.CurrentPage = Items.UnavailableConditionalAppearanceSettings1;

EndProcedure

// Enable  availability of output parameters
//
// Parameters: 
//  SettingsItem - the structure element for which availability is being changed.
&AtClient
Procedure OutputParametersAvailable(SettingsItem)

	If Report.SettingsComposer.Settings.HasItemOutputParameters(SettingsItem) Then

		LocalOutputParameters = True;
		Items.OutputParametersPages.CurrentPage = Items.OutputParametersSettings;

	Else

		LocalOutputParameters = False;
		Items.OutputParametersPages.CurrentPage = Items.DisabledOutputParametersSettings;

	EndIf;

	Items.LocalOutputParameters.ReadOnly = False;

EndProcedure

// Enable  availability of output parameters for executable settings.
//
// Parameters: 
//  SettingsItem - the structure element for which availability is being changed.
&AtClient
Procedure OutputParametersAvailable1(SettingsItem)

	If ExecutedSettingsComposer.Settings.HasItemOutputParameters(SettingsItem) Then

		LocalOutputParameters1 = True;
		Items.OutputParametersPages1.CurrentPage = Items.OutputParametersSettings1;

	Else

		LocalOutputParameters1 = False;
		Items.OutputParametersPages1.CurrentPage = Items.DisabledOutputParametersSettings1;

	EndIf;

	Items.LocalOutputParameters1.ReadOnly = False;

EndProcedure

// Switch page to the of output parameters to the page with the text of unavailability.
&AtClient
Procedure OutputParametersUnavailable()

	LocalOutputParameters = False;
	Items.LocalOutputParameters.ReadOnly = True;
	Items.OutputParametersPages.CurrentPage = Items.UnavailableOutputParametersSettings;

EndProcedure

// Switch page to the of output parameters to the page with the text of unavailability for executable settings.
&AtClient
Procedure OutputParametersUnavailable1()

	LocalOutputParameters1 = False;
	Items.LocalOutputParameters1.ReadOnly = True;
	Items.OutputParametersPages1.CurrentPage = Items.UnavailableOutputParametersSettings1;

EndProcedure

// Generate a name from the base part of the name on the server.
//
// Parameters:
//  RowType - type of row, for which the name is generated.
//  NameBasePart - first part of the name.
//  ItemsCollection - a collection of elements within which
//						the uniqueness of the name is checked .
//  Recursively - the need for recursive verification of the uniqueness of names
//				 in collection ItemsCollection.
//
// Return value:
//   String - generated name.
&AtServer
Function GenerateNameAtServer(RowType, NameBasePart, ItemsCollection, Recursively)

	UniqueNames = New Map;
	FindUniqueNamesAtServer(ItemsCollection, RowType, UniqueNames, Recursively);
	NameIndex = 1;

	While True Do

		Name = NameBasePart + ?(NameIndex > 1, " " + String(NameIndex), "");

		If UniqueNames.Get(Name) <> True Then

			Return Name;

		EndIf;

		NameIndex = NameIndex + 1;

	EndDo;

EndFunction

// Generate a name from the base part of the name on the client.
//
// Parameters:
//  RowType - type of row, for which the name is generated..
//  NameBasePart - first part of the name.
//  ItemsCollection - a collection of elements within which
//						the uniqueness of the name is checked.
//  Recursively - the need for recursive verification of the uniqueness of names
//				 in collection ItemsCollection.
//
// Return value:
//   String - generated name.
&AtClient
Function GenerateName(RowType, NameBasePart, ItemsCollection, Recursively)

	UniqueNames = New Map;
	FindUniqueNames(ItemsCollection, RowType, UniqueNames, Recursively);
	NameIndex = 1;

	While True Do

		Name = NameBasePart + ?(NameIndex > 1, " " + String(NameIndex), "");
		If UniqueNames.Get(Name) <> True Then

			Return Name;

		EndIf;
		NameIndex = NameIndex + 1;

	EndDo;

EndFunction

// Find rows with the specified string type in collection элементов. Recursively.
//
// Parameters:
//  ItemsCollection - items collections in which search
//  RowType - type of row to find.
//  FoundRows - array of found rows.
&AtClientAtServerNoContext
Procedure FindRows(ItemsCollection, RowType, FoundRows)

	For Each Item In ItemsCollection Do

		If Item.RowType = RowType Then

			FoundRows.Add(Item);

		EndIf;

		FindRows(Item.GetItems(), RowType, FoundRows);

	EndDo;

EndProcedure

//generated name for  Data Composition Schema
//
// Return value:
//  String - generated name of Data Composition Schema.
&AtClient
Function GenerateDataCompositionSchemaName()

	Return GenerateName(0, NStr("ru = 'Отчет';en = 'Report'"), ReportsTree.GetItems(), True);

EndFunction

// Generate name for report variant.
//
// Parameters:
//  ItemsCollection - the collection of elements to which is added Report variant.
//
// Return value:
//  String - generated name of report variant.
&AtClient
Function GenerateReportVariantName(ItemsCollection)

	Return GenerateName(1, NStr("ru = 'Вариант';en = 'Variant'"), ItemsCollection, False);

EndFunction

// Generate name for user setting.
//
// Parameters:
//  ItemsCollection - the collection of elements to which is added user setting 
//
// Return value:
//  String - generated name of user setting.
&AtClient
Function GenerateUserSettingName(ItemsCollection)

	Return GenerateName(2, NStr("ru = 'Настройка';en = 'Setting'"), ItemsCollection, False);

EndFunction

// Generate folder name.
//
// Parameters:
//  ItemsCollection - the collection of elements to which is addedпапка.
//
// Return value:
//  String - generated folder name.
&AtClient
Function GenerateFolderName(ItemsCollection)

	Return GenerateName(3, NStr("ru = 'Папка';en = 'Folder'"), ItemsCollection, False);

EndFunction

// Find all unique names of in collection items at server.
//
// Parameters:
//  Items - a collection of elements whose names need to be collected.
//  RowType - the type of rows whose names need to be collected..
//  UniqueNames - a match in which to put unique names.
//  Recursively - the need for recursive retrieval of nested names.
&AtServer
Procedure FindUniqueNamesAtServer(Items, RowType, UniqueNames, Recursively)

	For Each Item In Items Do

		If Item.RowType = RowType Then

			UniqueNames.Insert(Item.Name, True);

		EndIf;

		If Recursively Then

			FindUniqueNamesAtServer(Item.GetItems(), RowType, UniqueNames, Recursively);

		EndIf;

	EndDo;

EndProcedure

// Find all unique names of in collection items at client.
//
// Parameters:
//  Items - a collection of elements whose names need to be collected.
//  RowType - the type of rows whose names need to be collected..
//  UniqueNames - a match in which to put unique names.
//  Recursively - the need for recursive retrieval of nested names.
&AtClient
Procedure FindUniqueNames(Items, RowType, UniqueNames, Recursively)

	For Each Item In Items Do

		If Item.RowType = RowType Then

			UniqueNames.Insert(Item.Name, True);

		EndIf;

		If Recursively Then

			FindUniqueNames(Item.GetItems(), RowType, UniqueNames, Recursively);

		EndIf;

	EndDo;

EndProcedure

// Define the folder type.
//
// Parameters:
//  Item - item - folder, the type of which is determined.
//
// Return value:
// Number - folder type;
// Undefined if the folder type could not be determined.
&AtClient
Function FolderType(Item)

	ItemNotFolder = Item.GetParent();

	While ItemNotFolder <> Undefined Do

		If ItemNotFolder.RowType <> 3 Then

			Return ItemNotFolder.RowType;

		Else

			ItemNotFolder = ItemNotFolder.GetParent();

		EndIf;

	EndDo;

	Return Undefined;

EndFunction

// load  File.
//
// Parameters:
//  DownloadableFileName -the name of the file to download from. If the file name
//						  is empty, then you need to ask the user for the file name.
&AtClient
Procedure DownloadConsoleFile(DownloadableFileName)

	Var Address;

	BeginAttachingFileSystemExtension(
		New NotifyDescription("DownloadConsoleFileAfterAttachExtension", ThisForm,
		New Structure("DownloadableFileName", DownloadableFileName)));

EndProcedure

// Handler for connecting an extension when downloading  a file.
&AtClient
Procedure DownloadConsoleFileAfterAttachExtension(Attached, AdditionalParameters) Export

	DownloadableFileName = AdditionalParameters.DownloadableFileName;

	If Attached Then

		If DownloadableFileName = "" Then

			FileChoose = New FileDialog(FileDialogMode.Opening);
			FileChoose.Multiselect = False;
			FileChoose.FullFileName = FileName;
			Filter = NStr("ru = 'Файл консоли системы компоновки данных (*.dcr)|*.dcr|Все файлы (*.*)|*.*';en = 'File of data composition system console (*.dcr)|*.dcr|All files (*.*)|*.*'");
			FileChoose.Filter = Filter;
			FileChoose.Extension = "dcr";

			BeginPuttingFiles(
				New NotifyDescription("DownloadConsoleFileAfterAttachExtensionAfterPutFiles",
				ThisForm), , FileChoose);

		Else

			PlacedFiles = New Array;
			PlacedFiles.Add(New TransferableFileDescription(DownloadableFileName, ""));

			BeginPuttingFiles(
				New NotifyDescription("DownloadConsoleFileAfterAttachExtensionAfterPutFiles",
				ThisForm), PlacedFiles, , False);

		EndIf;

	Else

		BeginPutFile(
			New NotifyDescription("DownloadConsoleFileAfterAttachExtensionAfterPutFile", ThisForm), ,
			DownloadableFileName, , DownloadableFileName = "");

	EndIf;

EndProcedure

// Continue downloading the file after the file selection is completed.
&AtClient
Procedure DownloadConsoleFileAfterAttachExtensionAfterPutFiles(PlacedFiles, AdditionalParameters) Export

	If PlacedFiles <> Undefined Then

		FileDownloadingHandler(PlacedFiles);

	EndIf;

EndProcedure

// Continue downloading the file after receiving the file.
&AtClient
Procedure DownloadConsoleFileAfterAttachExtensionAfterPutFile(Result, Address, SelectedFileName,
	AdditionalParameters) Export

	If Result Then

		FileName = SelectedFileName;
		DownloadFromAddressHandler(Address);

	EndIf;

EndProcedure

// Direct file download
&AtClient
Procedure FileDownloadingHandler(PlacedFiles)

	For Each PlacedFile In PlacedFiles Do

		If PlacedFile.Location <> "" Then

			SelectedFileName = PlacedFile.Name;
			Address = PlacedFile.Location;
			FileName = SelectedFileName;
			Break;

		EndIf;

	EndDo;

	DownloadFromAddressHandler(Address);

EndProcedure

// Working out downloading a file with reports from the Address.
&AtClient
Procedure DownloadFromAddressHandler(Address)
	Try
		DownloadConsoleFileAtServer(Address);
	Except
		Return;
	EndTry;
	CurrentTreeItem = Undefined;

	If TypeOf(CurrentNode) = Type("ValueList") Then

		CurrentItems = ReportsTree.GetItems();

		For Position = 0 To CurrentNode.Count() - 1 Do

			Name = CurrentNode[CurrentNode.Count() - Position - 1].Value;
			Found = False;

			For Each Item In CurrentItems Do

				If Item.Name = Name Then

					CurrentTreeItem = Item;
					CurrentItems = CurrentTreeItem.GetItems();

					Found = True;
					Break;

				EndIf;

			EndDo;

			If Not Found Then

				Break;

			EndIf;

		EndDo;

		If CurrentTreeItem <> Undefined Then

			Items.ReportsTree.CurrentRow = CurrentTreeItem.GetID();

		EndIf;

	EndIf;

	CurrentNode = Undefined;
	UpdateTitle();
//	CurrentRow = Undefined;
	LoadCurrentRowAtServer();
	CurrentRowSettingsIsChanged = False;
EndProcedure

// Download console file at server .
//
// Parameters:
//  Address - the address of the storage from which to download the File.
&AtServer
Procedure DownloadConsoleFileAtServer(Address)

	TempFileName = GetTempFileName();
	Data = GetFromTempStorage(Address);
	Data.Write(TempFileName);
	ValueToFormAttribute(ValueFromFile(TempFileName), "ReportsTree");

EndProcedure

// Load Data Composition Schema  to Settings composer
//
// Parameters:
//  TreeItem - an item  of the report tree whose schema needs to be loaded into the settings composer.
//  LoadSettingsByDefault -Boolean. Indicates whether to load from the default Settings schema.
&AtServer
Procedure LoadDataCompositionSchemaToSettingsComposer(TreeItem, LoadSettingsByDefault)
	If TreeItem.RowType = 4 Then
		Return;
	EndIf;

	DataCompositionSchema = GetDataCompositionSchema(TreeItem.Data);
	SchemaTempStorageURL = PutToTempStorage(DataCompositionSchema, ?(
		SchemaTempStorageURL <> "", SchemaTempStorageURL, UUID));
	Report.SettingsComposer.Initialize(
		New DataCompositionAvailableSettingsSource(SchemaTempStorageURL));

	If LoadSettingsByDefault And ValueIsFilled(TreeItem.DCSSettings) Then
		XMLReader = New XMLReader;
		XMLReader.SetString(TreeItem.DCSSettings);
		Settings = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionSettings"));

		Report.SettingsComposer.LoadSettings(Settings);

	EndIf;

EndProcedure

// Load the Settings of the report variant to the current row of the tree.
//
// Parameters:
//  TreeItem - the element of the report tree to which you want to load the Settings of the report variant.
&AtServer
Procedure LoadVariantSettingsToCurrentRow(TreeItem)

	ItemReport = FoundItemReportTree(TreeItem);

	If ItemReport <> Undefined Then

		LoadDataCompositionSchematoSettingsComposer(ItemReport, False);

	EndIf;

	If TreeItem.Data <> "" Then

		XMLReader = New XMLReader;
		XMLReader.SetString(TreeItem.Data);
		Settings = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionSettings"));

	Else

		Settings = New DataCompositionSettings;

	EndIf;

	Report.SettingsComposer.LoadSettings(Settings);

EndProcedure

// Find a tree item with a report.
//
// Parameters:
//  TreeItem - a tree item starting from which to find a tree item with a report.
//
// Return value:
//   FormDataTreeItem - founded tree item - Report;
//   UNdefined - report not found.
&AtServer
Function FoundItemReportTree(Val TreeItem)

	While TreeItem <> Undefined Do

		If TreeItem.RowType = 0 Then

			Return TreeItem;

		Else

			TreeItem = TreeItem.GetParent();

		EndIf;

	EndDo;

	Return Undefined;

EndFunction

// Save the data of the current row on the server.
//
// Return value:
//  True - current Row was changed;
//  False -  current Row was not changed.
&AtServer
Function SaveCurrentRowDataAtServer()

	If CurrentRow <> Undefined Then

		TreeItem = ReportsTree.FindByID(CurrentRow);

		If TreeItem.RowType = 0 Then

		// Report Variant .
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.Settings, "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			NewData = XMLWriter.Close();

			If TreeItem.DCSSettings <> NewData Then

				TreeItem.DCSSettings = NewData;
				Return True;

			EndIf;

			//		ElsIf TreeItem.RowType = 2 Then
			//			
			//			// Settings.
			//			XMLWriter = New XMLWriter;
			//			XMLWriter.SetString();
			//			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.UserSettings, "UserSettings", "http://v8.1c.ru/8.1/data-composition-system/settings");
			//			NewData = XMLWriter.Close();
			//			
			//			If TreeItem.Data <> NewData Then
			//				
			//				TreeItem.Data = NewData;
			//				Return True;
			//				
			//			EndIf;
			//			
		EndIf;

	EndIf;

	Return False;

EndFunction

// Load Current Row At Server.
&AtServer
Procedure LoadCurrentRowAtServer()

	If Items.ReportsTree.CurrentRow = Undefined Then
		Return;
	EndIf;

	TreeItem = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

	//		If TreeItem.RowType=0 Then
	//Composition Schema
	LoadDataCompositionSchematoSettingsComposer(TreeItem, True);

	//		ElsIf TreeItem.RowType = 1 Then
	//			// Report Variant.
	//			LoadVariantSettingsToCurrentRow(TreeItem);
	//			
	//		ElsIf TreeItem.RowType = 2 Then
	//			// User Settings.
	//			ItemVariantOrReport = TreeItem.GetParent();
	//			
	//			While ItemVariantOrReport <> Undefined Do
	//				
	//				If ItemVariantOrReport.RowType = 0 Then
	//					// Found report.
	//					LoadDataCompositionSchematoSettingsComposer(ItemVariantOrReport, True);
	//					Break;
	//					
	//				ElsIf ItemVariantOrReport.RowType = 1 Then
	//					// Found report variant.
	//					LoadVariantSettingsToCurrentRow(ItemVariantOrReport);
	//					Break;
	//					
	//				EndIf;
	//				
	//				ItemVariantOrReport = ItemVariantOrReport.GetParent();
	//				
	//			EndDo;
	//			
	//			If TreeItem.Data <> "" Then
	//				
	//				XMLReader = New XMLReader;
	//				XMLReader.SetString(TreeItem.Data);
	//				UserSettings = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionUserSettings"));
	//				
	//			Else
	//
	//				UserSettings = New DataCompositionUserSettings;
	//
	//			EndIf;
	//			
	//			Report.SettingsComposer.LoadUserSettings(UserSettings);
	//			
	//		EndIf;
EndProcedure

// Save the current row and load a new current row on the server.
&AtServer
Procedure SaveCurrentRowDataAndLoadCurrentRowAtServer()

//save the Settings of the current row to the tree.
	SaveCurrentRowDataAtServer();

	//  load Settings into the settings composer.
	LoadCurrentRowAtServer();

EndProcedure

// Output Data Composition Template To Spreadsheet Document.
//
// Parameters:
//  DataCompositionTemplate - Data Composition Template, which should be output.
//  DetailsDataObject - details data object , that need filled during output.
&AtServer
Procedure OutputDataCompositionTemplateToSpreadsheetDocument(DataCompositionTemplate, DetailsDataObject)

	ResultSpreadsheetDocument.Clear();
	DataCompositionProcessor = New DataCompositionProcessor;
	DataCompositionProcessor.Initialize(DataCompositionTemplate, ExternalDataSetsStructure(), DetailsDataObject, True);
	ReportResultOutputProcessor = New DataCompositionResultSpreadsheetDocumentOutputProcessor;
	ReportResultOutputProcessor.SetDocument(ResultSpreadsheetDocument);
	ReportResultOutputProcessor.BeginOutput();
	ReportResultOutputProcessor.OutPut(DataCompositionProcessor);
	ReportResultOutputProcessor.EndOutput();

	If DetailsDataObject <> Undefined Then

		DetailsDataURL = PutToTempStorage(DetailsDataObject, UUID);

	EndIf;

EndProcedure

// Execute composition and get text of result data composition in XML view
//
// Parameters:
//  DataCompositionTemplate - Data Composition Template, which needs to be executed
//  DetailsDataObject -details data object, which needs to be filled in.
//
// Return value:
//   String - XML  text of result data composition and details data.
&AtServer
Function GetTextOfDataCompositionResult(DataCompositionTemplate, DetailsDataObject)

	DataCompositionProcessor = New DataCompositionProcessor;
	DataCompositionProcessor.Initialize(DataCompositionTemplate, ExternalDataSetsStructure(), DetailsDataObject, True);

	Result = "<resultAndDetailsInfo>";
	Result = Result + Chars.LF + Chars.Tab + "<result>";
	XMLWriter = New XMLWriter;
	NestedLevel = 3;

	While True Do

		DataCompositionResultItem = DataCompositionProcessor.Next();

		If DataCompositionResultItem = Undefined Then

			Break;

		EndIf;

		If DataCompositionResultItem.ItemType = DataCompositionResultItemType.End Then

			NestedLevel = NestedLevel - 1;

		EndIf;

		XMLWriter.SetString();
		XDTOSerializer.WriteXML(XMLWriter, DataCompositionResultItem, "item",
			"http://v8.1c.ru/8.1/data-composition-system/result");
		Str = XMLWriter.Close();

		ReplacementString = "";

		For ii = 1 To NestedLevel - 1 Do

			ReplacementString = ReplacementString + Chars.Tab;

		EndDo;

		Str = StrReplace(Str, Chars.LF, Chars.LF + ReplacementString);
		Str = ReplacementString + Str;
		Result = Result + Chars.LF + Str;

		If DataCompositionResultItem.ItemType = DataCompositionResultItemType.Begin Then

			NestedLevel = NestedLevel + 1;

		EndIf;

	EndDo;

	Result = Result + Chars.LF + Chars.Tab + "</result>";

	If DetailsDataObject <> Undefined Then

		XMLWriter.SetString();
		XDTOSerializer.WriteXML(XMLWriter, DetailsDataObject, "detailsInfo",
			"http://v8.1c.ru/8.1/data-composition-system/details");
		Str = XMLWriter.Close();
		Str = StrReplace(Str, Chars.LF, Chars.LF + Chars.Tab);
		Str = Chars.Tab + Str;
		Result = Result + Chars.LF + Str;

	EndIf;

	Result = Result + Chars.LF + "</resultAndDetailsInfo>";

	Return Result;

EndFunction

// Output Data Composition Template to XML result
//
// Parameters:
//  DataCompositionTemplate - composition template,which needs to output.
//  DetailsDataObject - details data , which need to be filled.
&AtServer
Procedure OutputDataCompositionTemplateToXMLResult(DataCompositionTemplate, DetailsDataObject)

	TextOfDataCompositionResult = GetTextOfDataCompositionResult(DataCompositionTemplate,
		DetailsDataObject);

EndProcedure

// Output Data Composition Template to result in  XML  view for values collection 
//
// Parameters:
//  DataCompositionTemplate - template,which needs to output.
&AtServer
Procedure OutputDataCompositionTemplateToXMLResultForCollection(DataCompositionTemplate)

	TextOfDataCompositionResultForCollection = GetTextOfDataCompositionResult(DataCompositionTemplate,
		Undefined);

EndProcedure

// Generate at server current row to spreadsheet document.
//
// Return value:
//  String - error text Which should be shown to the user
&AtServer
Function GenerateAtServerToSpreadsheetDocument()

	Var DetailsDataObject;

	ResultFilledSpreadsheetDocument = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = GetDataCompositionSchemaAtServer();
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			OutputDataCompositionTemplateToSpreadsheetDocument(DataCompositionTemplate, DetailsDataObject);
			DisplayResultsPanel();

			//		ElsIf Item.s = 1 Then
			//			// Report Variant .
			//			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			TemplateComposer = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema, Report.SettingsComposer.Settings, DetailsDataObject);
			//			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			//			OutputDataCompositionTemplateToSpreadsheetDocument(DataCompositionTemplate, DetailsDataObject);
			//			DisplayResultsPanel();
			//			
			//		ElsIf Item.RowType = 2 Then
			//			// Report Settings .
			//			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			TemplateComposer = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema, Report.SettingsComposer.GetSettings(), DetailsDataObject);
			//			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			//			OutputDataCompositionTemplateToSpreadsheetDocument(DataCompositionTemplate, DetailsDataObject);
			//			DisplayResultsPanel();
		Else

			Return NStr(
				"ru = 'He понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.';
				|en = 'It is not clear which report needs to be generated. Select a report or an variant or a setting and re-generate the report.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

//Show value tree to form attribute
//
// Parameters:
//  TempTree - tree, which need to show.
&AtServer
Procedure OutputTreeResultToCollection(TempTree)

	NewAttributes = New Array;

	For Each Column In TempTree.Cols Do
		If Column.ValueType.ContainsType(Type("ValueStorage")) Then
			Continue;
		EndIf;

		NewColumn = New FormAttribute(Column.Name, Column.ValueType, "TreeResult", Column.Title);
		NewAttributes.Add(NewColumn);

	EndDo;

	DeletedAttributes = New Array;
	CurrentAttributes = GetAttributes("TreeResult");

	For Each Attribute In CurrentAttributes Do

		DeletedAttributes.Add(Attribute.Path + "." + Attribute.Name);

	EndDo;

	ChangeAttributes(NewAttributes, DeletedAttributes);

	While Items.TreeResult.ChildItems.Count() > 0 Do

		Items.Delete(Items.TreeResult.ChildItems[0]);

	EndDo;

	For Each Column In TempTree.Cols Do
		If Column.ValueType.ContainsType(Type("ValueStorage")) Then
			Continue;
		EndIf;

		Item = Items.Add(Column.Name, Type("FormField"), Items.TreeResult);
		Item.DataPath = "TreeResult." + Column.Name;

	EndDo;

	Items.DecorationCollection.Visible = NewAttributes.Count() = 0;

	ValueToFormAttribute(TempTree, "TreeResult");

EndProcedure

// Output Data Composition Template as collection to form attribute
//
// Parameters:
//  DataCompositionTemplate - template, that need to output.
&AtServer
Procedure OutputDataCompositionTemplateToTemplate(DataCompositionTemplate)

	DataCompositionProcessor = New DataCompositionProcessor;
	DataCompositionProcessor.Initialize(DataCompositionTemplate, ExternalDataSetsStructure(), , True);
	ReportResultOutputProcessor = New DataCompositionResultValueCollectionOutputProcessor;
	ReportResultOutputProcessor.SetObject(New ValueTree);
	ReportResultOutputProcessor.BeginOutput();
	ReportResultOutputProcessor.Put(DataCompositionProcessor);
	OutputTreeResultToCollection(ReportResultOutputProcessor.EndOutput());

EndProcedure

// Generate at server result and output it's to values collection.
//
// Return value:
//  String - message text to show to user
&AtServer
Function GenerateAtServerToCollection()

	ResultFilledCollection = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = GetDataCompositionSchemaAtServer();
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			OutputDataCompositionTemplateToTemplate(DataCompositionTemplate);
			DisplayResultsPanel();

			//		ElsIf Item.RowType = 1 Then
			//			// Report Variant .
			//			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			TemplateComposer = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema, Report.SettingsComposer.Settings , , , Type("DataCompositionValueCollectionTemplateGenerator"));
			//			OutputDataCompositionTemplateToTemplate(DataCompositionTemplate);
			//			DisplayResultsPanel();
			//			
			//		ElsIf Item.RowType = 2 Then
			//			// report Settings.
			//			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			TemplateComposer = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema, Report.SettingsComposer.GetSettings() , , , Type("DataCompositionValueCollectionTemplateGenerator"));
			//			OutputDataCompositionTemplateToTemplate(DataCompositionTemplate);
			//			DisplayResultsPanel();
		Else

			Return NStr(
				"ru = 'Не понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.';
				|en = 'It is not clear which report needs to be generated. Select a report or an variant or a setting and re-generate the report.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate at server report and output it's as XML.
//
// Return value:
//  String - message text to show to user
&AtServer
Function GenerateAtServerAsXML()

	Var DetailsDataObject;

	ResultFilledXML = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = GetDataCompositionSchemaAtServer();
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			OutputDataCompositionTemplateToXMLResult(DataCompositionTemplate, DetailsDataObject);
			DisplayResultsPanel();

		ElsIf Item.RowType = 1 Then
		// Report Variant .
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			OutputDataCompositionTemplateToXMLResult(DataCompositionTemplate, DetailsDataObject);
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then
		// report settings
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			OutputDataCompositionTemplateToXMLResult(DataCompositionTemplate, DetailsDataObject);
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru = 'Не понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.';
				|en = 'It is not clear which report needs to be generated. Select a report or an variant or a setting and re-generate the report.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate report result for collection and output as XML text .
//
// Return value:
//  String - message text to show to user
&AtServer
Function GenerateAtServerAsXMLCollection()

	ResultFilledCollectionXML = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = GetDataCompositionSchemaAtServer();
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			OutputDataCompositionTemplateToXMLResultForCollection(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 1 Then
		// Report Variant .
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			OutputDataCompositionTemplateToXMLResultForCollection(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then
		// report settings
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			OutputDataCompositionTemplateToXMLResultForCollection(DataCompositionTemplate);
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru = 'Не понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.';
				|en = 'It is not clear which report needs to be generated. Select a report or an variant or a setting and re-generate the report.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Output Data Composition Template as text.
//
// Parameters:
//  DataCompositionTemplate - outputed template.
//
// Return value:
//  String - Data Composition Template  text as XML.
&AtServer
Procedure OutputDataCompositionTemplateToText(DataCompositionTemplate)

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, DataCompositionTemplate, "dataComposition",
		"http://v8.1c.ru/8.1/data-composition-system/composition-template");
	TextOfDataCompositionTemplate = XMLWriter.Close();

EndProcedure

// Generate Data Composition Template.
// 
// Return value:
//  String - message text for show to user.
&AtServer
Function GenerateAtServerToDataCompositionTemplate()

	Var DetailsDataObject;

	ResultFilledTemplate = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = GetDataCompositionSchemaAtServer();
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			OutputDataCompositionTemplateToText(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 1 Then
		// Report variant.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			OutputDataCompositionTemplateToText(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then
		// report settings
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			OutputDataCompositionTemplateToText(DataCompositionTemplate);
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru = 'Не понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.';
				|en = 'It is not clear which report needs to be generated. Select a report or an variant or a setting and re-generate the report.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// output Data Composition Template for values collection as text.
//
// Parameters:
// DataCompositionTemplate - Data Composition Template, which need output.
&AtServer
Procedure OutputDataCompositionTemplateToTextForCollection(DataCompositionTemplate)

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, DataCompositionTemplate, "dataComposition",
		"http://v8.1c.ru/8.1/data-composition-system/composition-template");
	TextOfDataCompositionTemplateForCollection = XMLWriter.Close();

EndProcedure

// Generate Data Composition Template for collection.
//
// Return value:
//  String - showed to user String.
&AtServer
Function GenerateAtServerToDataCompositionTemplateForCollection()

	Var DetailsDataObject;

	ResultFilledTemplateForCollection = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = GetDataCompositionSchemaAtServer();
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			OutputDataCompositionTemplateToTextForCollection(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 1 Then
		// Report variant.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			OutputDataCompositionTemplateToTextForCollection(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then
		// report settings
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			OutputDataCompositionTemplateToTextForCollection(DataCompositionTemplate);
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru = 'Не понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.';
				|en = 'It is not clear which report needs to be generated. Select a report or an variant or a setting and re-generate the report.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate executed Settings.
//
// Return value:
//  String - message for show to user.
&AtServer
Function GenerateAtServerToExecutedDataCompositionSettings()

	Var DetailsDataObject;

	ResultFilledSettings = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = GetDataCompositionSchemaAtServer();
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ExecutedSettingsComposer.Initialize(
				New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
			ExecutedSettingsComposer.LoadSettings(DataCompositionSchema.DefaultSettings);
			DisplayResultsPanel();

		ElsIf Item.RowType = 1 Then

		// Report variant.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ExecutedSettingsComposer.Initialize(
				New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
			ExecutedSettingsComposer.LoadSettings(Report.SettingsComposer.Settings);
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then

		// report settings
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ExecutedSettingsComposer.Initialize(
				New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
			ExecutedSettingsComposer.LoadSettings(Report.SettingsComposer.GetSettings());
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru = 'Не понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.';
				|en = 'It is not clear which report needs to be generated. Select a report or an variant or a setting and re-generate the report.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate executed Settings as XML.
//
// Return value:
//  String - text for user.
&AtServer
Function GenerateAtServerToExecutedDataCompositionSettingsXML()

	Var DetailsDataObject;

	ResultFilledSettingsXML = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = GetDataCompositionSchemaAtServer();
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, DataCompositionSchema.DefaultSettings, "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ExecutedSettingsXML = XMLWriter.Close();
			DisplayResultsPanel();

		ElsIf Item.RowType = 1 Then
		// Report variant.
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.Settings, "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ExecutedSettingsXML = XMLWriter.Close();
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then
		// report settings
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.GetSettings(), "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ExecutedSettingsXML = XMLWriter.Close();
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru = 'Не понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.';
				|en = 'It is not clear which report needs to be generated. Select a report or an variant or a setting and re-generate the report.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate отчет at server. The generation  is based on the current page of the results panel.
//
// Return value:
//  String - text for user.
&AtServer
Function GenerateAtServer()

	ReportNeedsToGenerate = True;
	ResultFilledTemplate = False;
	ResultFilledSettings = False;
	ResultFilledSettingsXML = False;
	ResultFilledSpreadsheetDocument = False;
	ResultFilledXML = False;
	ResultFilledCollection = False;
	ResultFilledTemplateForCollection = False;
	ResultFilledCollectionXML = False;

	If Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument Then

		Return GenerateAtServerToSpreadsheetDocument();

//	ElsIf Items.ResultsPanel.CurrentPage = Items.PageDataCompositionTemplate Then
//
//		Return GenerateAtServerToDataCompositionTemplate();
//
//	ElsIf Items.ResultsPanel.CurrentPage = Items.PageExecutedSettings Then
//
//		Return GenerateAtServerToExecutedDataCompositionSettings();
//
//	ElsIf Items.ResultsPanel.CurrentPage = Items.PageExecutedSettingsXML Then
//
//		Return GenerateAtServerToExecutedDataCompositionSettingsXML();
//
//	ElsIf Items.ResultsPanel.CurrentPage = Items.PageDataCompositionResultXML Then
//
//		Return GenerateAtServerAsXML();

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageResultCollection Then

		Return GenerateAtServerToCollection();

//	ElsIf Items.ResultsPanel.CurrentPage = Items.PageTemplateForCollection Then
//
//		Return GenerateAtServerToDataCompositionTemplateForCollection();
//
//	ElsIf Items.ResultsPanel.CurrentPage = Items.PageResultCollectionXML Then
//
//		Return GenerateAtServerAsXMLCollection();

	EndIf;
EndFunction

// Generate report at client.
&AtClient
Procedure GenerateAtClient()

	Result = GenerateAtServer();

	If Result <> Undefined Then

		ShowMessageBox( , Result);

	EndIf;

EndProcedure

// Display results panel.
&AtServer
Procedure DisplayResultsPanel()

	Items.ResultsPanel.Visible = True;
	Items.ButtonResultsPanel.Check = Items.ResultsPanel.Visible;

EndProcedure

// Display results panel.
&AtServer
Procedure DisplaySettingsPanel()
	SettingsVisibility = Not Items.GroupSettingsAndReports.Visible;
	Items.GroupSettingsAndReports.Visible = SettingsVisibility;
	Items.Settings.Check = SettingsVisibility;

EndProcedure

// Get Data Composition Schema based on the schema text.
//
// Return value:
//  DataCompositionSchema - schema, read from the schema text.
&AtServerNoContext
Function GetDataCompositionSchema(SchemaText)

	If SchemaText <> "" Then

		XMLReader = New XMLReader;
		XMLReader.SetString(SchemaText);
		Return XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionSchema"));

	Else

		Return New DataCompositionSchema;

	EndIf;

EndFunction

&AtServer
Function GetDataCompositionSchemaServerCall()
	Return GetDataCompositionSchemaAtServer();
EndFunction

// Get data composition schema for current row at server.
//
// Return value:
//  DataCompositionSchema - data composition schema for current row.
&AtServer
Function GetDataCompositionSchemaAtServer()

	Return GetDataCompositionSchema(ReportsTree.FindByID(
		Items.ReportsTree.CurrentRow).Data);

EndFunction

// Get data composition schema for current row at client.
//
// Return value:
//  DataCompositionSchema - data composition schema for current row.
&AtClient
Function GetDataCompositionSchemaAtClient()

	#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	Return GetDataCompositionSchema(ReportsTree.FindByID(
		Items.ReportsTree.CurrentRow).Data);
	#Else
		Return GetDataCompositionSchemaServerCall();
	#EndIf

EndFunction

// Set data composition schema for current row.
//
// Parameters:
//  Scheme - DataCompositionSchema - scheme, to set for current row.
&AtClient
Procedure SetDataCompositionSchemaAtClient(Scheme)
	SetDataCompositionSchema(Scheme);
EndProcedure

&AtServer
Procedure SetDataCompositionSchema(Scheme)
	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, Scheme, "dataCompositionSchema",
		"http://v8.1c.ru/8.1/data-composition-system/schema");

	CurrentRow = Items.ReportsTree.CurrentRow;
	TreeCurrentRow = ReportsTree.FindByID(CurrentRow);

	If TreeCurrentRow = Undefined Then
		Return;
	EndIf;

	TreeCurrentRow.Data = XMLWriter.Close();

	If Not ValueIsFilled(TreeCurrentRow.DCSSettings) Then
		XMLWriter = New XMLWriter;
		XMLWriter.SetString();
		XDTOSerializer.WriteXML(XMLWriter, Scheme.DefaultSettings, "Settings",
			"http://v8.1c.ru/8.1/data-composition-system/settings");
		TreeCurrentRow.DCSSettings = XMLWriter.Close();
	EndIf;

	// Load Settings to settings composer
	LoadCurrentRowAtServer();	
EndProcedure

//Open Data Composition Schema Wizard.
&AtClient
Procedure OpenDataCompositionSchemaWizard()

#If ThickClientOrdinaryApplication Or ThickClientManagedApplication Then
	Wizard = New DataCompositionSchemaWizard(GetDataCompositionSchemaAtClient());
	Wizard.Edit(ThisForm);
#Else
		CurrentData=Items.ReportsTree.CurrentData;
		If CurrentData = Undefined Then
			Return;
		EndIf;

		EditorSettings=New Structure;
		EditorSettings.Insert("СКД", CurrentData.Data);
		OpenForm("DataProcessor.UT_DCSEditor.Form", EditorSettings, ThisForm, , , ,
			New NotifyDescription("OpenDataCompositionSchemaWizardOnEnd", ThisObject,
			New Structure("RowID", CurrentData.GetID())), );
	//	ShowMessageBox( , Nstr(
	//		"ru = 'Конструктор схемы компоновки данных можно открыть только в толстом клиенте. В тонком клиенте и веб клиенте редактирование схемы компоновки данных возможно только в тексте схемы компоновки данных.';
	//		|en = 'Data composition wizard can be opened only in thick client. In thin and webclient editing of data composition schema is possible only in the text of  data composition schema.'"));
#EndIf

EndProcedure

&AtClient
Procedure OpenDataCompositionSchemaWizardOnEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	OpenDataCompositionSchemaWizardOnEndAtServer(AdditionalParameters.RowID, Result);
EndProcedure

&AtServer
Procedure OpenDataCompositionSchemaWizardOnEndAtServer(RowID, АдресСКД)
	Scheme=GetFromTempStorage(АдресСКД);

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, Scheme, "dataCompositionSchema",
		"http://v8.1c.ru/8.1/data-composition-system/schema");

	TreeCurrentRow = ReportsTree.FindByID(RowID);

	If TreeCurrentRow = Undefined Then
		Return;
	EndIf;

	TreeCurrentRow.Data = XMLWriter.Close();

	If Not ValueIsFilled(TreeCurrentRow.DCSSettings) Then
		XMLWriter = New XMLWriter;
		XMLWriter.SetString();
		XDTOSerializer.WriteXML(XMLWriter, Scheme.DefaultSettings, "Settings",
			"http://v8.1c.ru/8.1/data-composition-system/settings");
		TreeCurrentRow.DCSSettings = XMLWriter.Close();
	EndIf;

	// Load Settings to settings composer.
	LoadCurrentRowAtServer();

EndProcedure

// Update form title.
&AtClient
Procedure UpdateTitle()

	Title = InitialTitle + ?(FileName <> "", ": " + FileName, "");

EndProcedure

// Save file with reports.
//
// Parameters:
//  As - boolean. The need to request a file name from the user
//
// Return value:
//  True  - saving was successful;
//  False - the user canceled the save.
&AtClient
Procedure Save(As, NotificationProcessing)
	Var FileChoose;

	BeginAttachingFileSystemExtension(New NotifyDescription("SaveOnEnd", ThisForm,
		New Structure("As, NotificationProcessing", As, NotificationProcessing)));

EndProcedure

// End of saving procedure.
&AtClient
Procedure SaveOnEnd(Attached, AdditionalParameters) Export

	As = AdditionalParameters.As;
	NotificationProcessing = AdditionalParameters.NotificationProcessing;

	If Attached Then

		If As Or FileName = "" Then
			File = New File(FileName);
			SavedFileName = File.Name;

			// Need to ask filename.
			FileChoose = New FileDialog(FileDialogMode.Save);
			FileChoose.Multiselect = False;
			FileChoose.FullFileName = FileName;
			FileChoose.Directory = File.Path;
			Filter = NStr("ru = 'Файл консоли системы компоновки данных (*.dcr)|*.dcr|Все файлы (*.*)|*.*';en = 'Console of Data composition system file (*.dcr)|*.dcr|All files(*.*)|*.*'");
			FileChoose.Filter = Filter;
			FileChoose.Extension = "dcr";

		Else
			FileChoose = FileName;
		EndIf;

		FilesToBeObtained = New Array;
		FilesToBeObtained.Add(New TransferableFileDescription(SavedFileName,
			PutFileToTempStorage()));
		BeginGettingFiles(New NotifyDescription("SaveOnEndAfterGettingFiles", ThisForm,
			New Structure("NotificationProcessing", NotificationProcessing)), FilesToBeObtained, FileChoose, False);

	Else

		GetFile(PutFileToTempStorage(), FileName, True);
		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	EndIf;

EndProcedure

// Completion of saving after receiving files.
&AtClient
Procedure SaveOnEndAfterGettingFiles(ReceivedFiles, AdditionalParameters) Export

	NotificationProcessing = AdditionalParameters.NotificationProcessing;

	If ReceivedFiles = Undefined Then

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, False);

		EndIf;
	Else

		FileName = ReceivedFiles[0].Name;
		UpdateTitle();
		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	EndIf;

EndProcedure

// Put file to temp storage
&AtServer
Function PutFileToTempStorage()

	TempFileName = GetTempFileName();
	ValueToFile(TempFileName, FormAttributeToValue("ReportsTree"));
	Result = PutToTempStorage(New BinaryData(TempFileName));
	Return Result;

EndFunction

// If file of reports was changed, then ask the user if it needs to be saved.
//
// Return value:
//  True - closing confirmed;
//  False - the user canceled the Close.
&AtClient
Procedure ConfirmClose(NotificationProcessing)

	If SaveCurrentRowDataAtServer() Then

		Modified = True;

	EndIf;

	If Modified Then

		ShowQueryBox(New NotifyDescription("ConfirmCloseOnEnd", ThisForm,
			New Structure("NotificationProcessing", NotificationProcessing)), NStr(
			"ru = 'Отчет модифицированы. Сохранить изменения?';en = 'The report is modified. Save changes?'"), QuestionDialogMode.YesNoCancel, ,
			DialogReturnCode.Yes);

	Else

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	EndIf;

EndProcedure

//Completion of closing confirmation.
&AtClient
Procedure ConfirmCloseOnEnd(QuestionResult, AdditionalParameters) Export

	NotificationProcessing = AdditionalParameters.NotificationProcessing;

	Answer = QuestionResult;

	If Answer = DialogReturnCode.Yes Then

		Save(False, NotificationProcessing);

	ElsIf Answer = DialogReturnCode.None Then

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	Else

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, False);

		EndIf;

	EndIf;

EndProcedure

// Get current node
//
// Return value:
//  Reports tree current node.
&AtServer
Function GetCurrentNode()

	Var Result, CurrentTreeItem;
	Result = New ValueList;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		CurrentTreeItem = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

	EndIf;

	While CurrentTreeItem <> Undefined Do

		Result.Add(CurrentTreeItem.Name);
		CurrentTreeItem = CurrentTreeItem.GetParent();

	EndDo;

	Return Result;

EndFunction

// Save Settings of console to  settings Storage.
&AtServer
Procedure SaveConsoleSettings()

	CommonSettingsStorage.Save("ReportSystemConsoleSettings5", , New Structure("FileName,CurrentNode",
		FileName, GetCurrentNode()));

EndProcedure

// Get name base part.
//
// Parameters:
//  FullName - String. The name from which to get the base part.
//
// Return value:
//  String - the base part of the name. It is obtained by dropping the number located
//           at the end of the full name.
&AtServer
Function FindNameBasePart(FullName)
// We are looking for digits up to the first space from the end. Cut to this gap.
	If StrLen(FullName) < 3 Then

		Return "";

	EndIf;

	Position = StrLen(FullName);
	WereNumbers = False;

	While Position > 1 Do

		CurrentChar = Mid(FullName, Position, 1);

		If CurrentChar >= "0" And CurrentChar <= "9" Then

			WereNumbers = True;

		ElsIf CurrentChar = " " Then

			Break;

		Else

			WereNumbers = False;
			Break;

		EndIf;

		Position = Position - 1;

	EndDo;

	If WereNumbers And Position > 1 Then

		Return Mid(FullName, 1, Position - 1);

	Else

		Return "";

	EndIf;

EndFunction

// Copy current row at server.
&AtServer
Procedure CopyAtServer()

	SaveCurrentRowDataAtServer();
	CopiedItem = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);
	NewName = CopiedItem.Name;
	NameBasePart = "";

	//	If CopiedItem.RowType = 0 Then 
	NameBasePart = FindNameBasePart(CopiedItem.Name);

	If NameBasePart = "" Then

		NameBasePart = NStr("ru = 'Отчет';en = 'Report'");

	EndIf;

	NewName = GenerateNameAtServer(0, NameBasePart, ReportsTree.GetItems(), True);

	//	ElsIf CopiedItem.RowType = 1 Then 
	//		
	//		NameBasePart = FindNameBasePart(CopiedItem.Name);
	//		
	//		If NameBasePart = "" Then
	//			
	//			NameBasePart = NStr("ru = 'Вариант';en = 'Variant'");
	//			
	//		EndIf;
	//		
	//		NewName = GenerateNameAtServer(1, NameBasePart, CopiedItem.GetParent().GetItems(), False)
	//		
	//	ElsIf CopiedItem.RowType = 2 Then
	//		
	//		NameBasePart = FindNameBasePart(CopiedItem.Name);
	//		
	//		If NameBasePart = "" Then
	//			
	//			NameBasePart = NStr("ru = 'Настройки';en = 'Setting'");
	//			
	//		EndIf;
	//		
	//		NewName = GenerateNameAtServer(2, NameBasePart, CopiedItem.GetParent().GetItems(), False);
	//		
	//	ElsIf CopiedItem.RowType = 3 Then 
	//		
	//		NameBasePart = FindNameBasePart(CopiedItem.Name);
	//		
	//		If NameBasePart = "" Then
	//			
	//			NameBasePart = NStr("ru = 'Папка';en = 'Folder'");
	//			
	//		EndIf;
	//		
	//		NewName = GenerateNameAtServer(3, NameBasePart, CopiedItem.GetParent().GetItems(), False);
	//		
	//	EndIf;
	NewItem = CopiedItem.GetParent().GetItems().Add();
	FillPropertyValues(NewItem, CopiedItem);
	NewItem.Name = NewName;
	Items.ReportsTree.CurrentRow = NewItem.GetID();
	LoadCurrentRowAtServer();
	CurrentRow = NewItem.GetID();

EndProcedure

// Execute at server report  base at  text of data composition template.
&AtServer
Procedure ExecuteAtServerFromDataCompositionTemplate()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplate);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	OutputDataCompositionTemplateToSpreadsheetDocument(DataCompositionTemplate, Undefined);
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument;

EndProcedure

//  Execute at server report  to value collection based at  text of data composition template.
&AtServer
Procedure ExecuteAtServerFromDataCompositionTemplateToCollection()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplateForCollection);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	OutputDataCompositionTemplateToTemplate(DataCompositionTemplate);
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageResultCollection;

EndProcedure

// Execute report as XML based at  text of data composition template.
&AtServer
Procedure ExecuteToResultAtServerFromDataCompositionTemplate()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplate);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	OutputDataCompositionTemplateToXMLResult(DataCompositionTemplate, Undefined);
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageDataCompositionResultXML;

EndProcedure

//  Execute report as XML to collection based at  text of data composition template..
&AtServer
Procedure ExecuteToResultCollectionAtServerFromDataCompositionTemplate()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplateForCollection);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	OutputDataCompositionTemplateToXMLResultForCollection(DataCompositionTemplate);
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageResultCollectionXML;

EndProcedure

// Get name of  Spreadsheet document standart.
//
// Return value:
//  String - spreadsheet  document standart file name.
&AtClient
Function StandartFileNameOfSpreadsheetDocument()

	Var FileName;

	FileName = NStr("ru = 'Эталон табличного документа.mxl';en = 'Spreadsheet Document Standart.mxl'");

	If FileName = "" Then

		FileName = NSTR("ru = 'Эталон табличного документа.xml';en = 'Spreadsheet document standart.xml'");

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get Spreadsheet Document file name
//
// Return value:
//  String - Spreadsheet Document File name
&AtClient
Function SpreadsheetDocumentFileName()

	Var FileName;

	FileName = NStr("ru = 'Табличный документ.xml';en = 'Spreadsheet document.xml'");

	If FileName = "" Then

		FileName = NStr("ru = 'Табличный документ.xml';en = 'Spreadsheet document.xml'");;

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get template standart file name.
//
// Return value:
//  String - template standart file name
&AtClient
Function TemplateStandartFileName()

	Var FileName;

	FileName = NStr("ru = 'Эталон макета.xml';en = 'Template standart.xml'");

	If FileName = "" Then

		FileName = NStr("ru = 'Эталон макета.xml';en = 'Template standart.xml'");

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get template  file name.
//
// Return value
//  String - template  file name.
&AtClient
Function TemplateFileName()

	Var FileName;

	FileName = NStr("ru = 'Макет.xml';en = 'Template.xml'");

	If FileName = "" Then

		FileName = NStr("ru = 'Макет.xml';en = 'Template.xml'");

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get executable settings file name.
//
// Return value:
//  String -  executable settings file name.
&AtClient
Function ExecutableSettingsStandartFileName()

	Var FileName;

	FileName = NStr("ru = 'Эталон исполняемых настроек.xml';en = 'Executable settings standart.xml'");

	If FileName = "" Then

		FileName = NStr("ru = 'Эталон исполняемых настроек.xml';en = 'Executable settings standart.xml'");

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get executable settings file name.
//
// Return value:
//  String - executable settings file name.
&AtClient
Function ExecutableSettingsFileName()

	Var FileName;

	FileName = NStr("ru = 'Исполняемые настройки.xml';en = 'Executable settings.xml'");

	If FileName = "" Then

		FileName = NStr("ru = 'Исполняемые настройки.xml';en = 'Executable settings.xml'");

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get name of XML result standart file.
// 
// Return value:
//  String - Get name of XML result standart file..
&AtClient
Function XMLResultStandartFileName()

	Var FileName;

	FileName = NStr("ru = 'Эталон результата.xml';en = 'Result standart.xml'");

	If FileName = "" Then

		FileName = NStr("ru = 'Эталон результата.xml';en = 'Result standart.xml'");;

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get name of XML result  file..
//
// Return value:
//  String - name of XML result  file.
&AtClient
Function XMLResultFileName()

	Var FileName;

	FileName = NStr("ru = 'Результат.xml';en = 'Result.xml'");

	If FileName = "" Then

		FileName = NStr("ru = 'Результат.xml';en = 'Result.xml'");

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get file name of template standart for collection.
//
// Return value:
//  String - file name of template standart for collection.
&AtClient
Function TemplateStandartFileNameForCollection()

	Var FileName;

	FileName = NStr("ru = 'Эталон макета для коллекции.xml';en = 'Template standart for collection.xml'");

	If FileName = "" Then

		FileName = NStr("ru = 'Эталон макета для коллекции.xml';en = 'Template standart for collection.xml'");

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get template file name for  collection.
//
// Return value:
//  String - template file name for  collection
&AtClient
Function TemplateFileNameForCollection()

	Var FileName;

	FileName = NStr("ru = 'Макет для коллекции.xml';en = 'Template  for collection.xml'");

	If FileName = "" Then

		FileName = NStr("ru = 'Макет для коллекции.xml';en = 'Template  for collection.xml'");

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get name file  of XML Result Standart for collection.
//
// Return value:
//  String - name file  of XML Result Standart for collection.
&AtClient
Function XMLResultStandartFileNameForCollection()

	Var FileName;

	FileName = NStr("ru = 'Эталон результата для коллекции.xml';en = 'Result standart for collection.xml'");

	If FileName = "" Then

		FileName = NStr("ru = 'Эталон результата для коллекции.xml';en = 'Result standart for collection.xml'");

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Get file name of  XML result  for collection.
//
// Return value:
//  String - file name of  XML result  for collection.
&AtClient
Function XMLResultFileNameForCollection()

	Var FileName;

	FileName = NStr("ru = 'Результат для коллекции.xml';en = 'Result for collection.xml'");

	If FileName = "" Then

		FileName =  NStr("ru = 'Результат для коллекции.xml';en = 'Result for collection.xml'");

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Output result from text to spreadsheet document.
&AtServer
Procedure OutputResultFromResultTextToSpreadsheetDocument()

	ReportNeedsToGenerate = False;
	ResultSpreadsheetDocument.Clear();
	ReportResultOutputProcessor = New DataCompositionResultSpreadsheetDocumentOutputProcessor;
	ReportResultOutputProcessor.SetDocument(ResultSpreadsheetDocument);
	ReportResultOutputProcessor.BeginOutput();

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionResult);
	XMLReader.Read(); // resultAndDetailsInfo
	XMLReader.Read(); // result
	XMLReader.Read(); // item
	While XMLReader.NodeType = XMLNodeType.StartElement And XMLReader.Name = "item" Do

		If XMLReader.NodeType = XMLNodeType.StartElement Then // item
			ResultItem = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionResultItem"));
			ReportResultOutputProcessor.OutputItem(ResultItem);

		Else

			Break;

		EndIf;

	EndDo;

	ReportResultOutputProcessor.EndOutput();
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument;

EndProcedure

// Output Result From Result Text To collection .
&AtServer
Procedure OutputResultFromResultTextToCollection()

	ReportNeedsToGenerate = False;
	ReportResultOutputProcessor = New DataCompositionResultValueCollectionOutputProcessor;
	ReportResultOutputProcessor.SetObject(New ValueTree);
	ReportResultOutputProcessor.BeginOutput();

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionResultForCollection);
	XMLReader.Read(); // resultAndDetailsInfo
	XMLReader.Read(); // result
	XMLReader.Read(); // item
	While XMLReader.NodeType = XMLNodeType.StartElement And XMLReader.Name = "item" Do

		If XMLReader.NodeType = XMLNodeType.StartElement Then // item
			ResultItem = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionResultItem"));
			ReportResultOutputProcessor.OutputItem(ResultItem);

		Else

			Break;

		EndIf;

	EndDo;

	OutputTreeResultToCollection(ReportResultOutputProcessor.EndOutput());
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageResultCollection;

EndProcedure

// Load data composition schema from temp storage to current row
&AtServer
Procedure LoadDataCompositionSchemaFileAtServer(Address)

	TempFileName = GetTempFileName();
	Data = GetFromTempStorage(Address);
	Data.Write(TempFileName);
	TextReader = New TextReader(TempFileName);
	Modified = True;
	ReportsTree.FindByID(Items.ReportsTree.CurrentRow).Data = TextReader.Read();

EndProcedure

// Load data composition schema from temp storage to current row
&AtServer
Function PutDataCompositionSchemaToTempStorage()

	TempFileName = GetTempFileName();
	TextWriter = New TextWriter(TempFileName);
	TextWriter.Write(ReportsTree.FindByID(Items.ReportsTree.CurrentRow).Data);
	TextWriter.Close();
	Result = PutToTempStorage(New BinaryData(TempFileName));
	Return Result;

EndFunction

&AtServer
Procedure FillDCSForDebug(DebugDataURL)
	DataForDebug = GetFromTempStorage(DebugDataURL);
	TreeItems = ReportsTree.GetItems();
	TreeItems.Clear();

	RootItem = TreeItems.Add();
	RootItem.RowType = 4;
	RootItem.Name = NStr("ru = 'Отчеты';en = 'Reports'");

	ElementsToWhichAdd = RootItem.GetItems();

	Name =NSTR("ru = 'Отчет для отладки';en = 'Report for debug'");
	Item = ElementsToWhichAdd.Add();
	Item.Name = Name;
	Item.RowType = 0;

	Item.Data = DataForDebug.DCSText;
	Item.DCSSettings = DataForDebug.DcsSettingsText;

	If DataForDebug.Property("ExternalDataSets") Then
		For Each KeyValue ИЗ DataForDebug.ExternalDataSets Do
			NewRow=Item.ExternalDataSets.Add();
			NewRow.Name=KeyValue.Key;
			NewRow.Value=KeyValue.Value;
			ValueTable=ValueFromStringInternal(NewRow.Value);
			NewRow.Presentation=StrTemplate("Rows: %1 Columns: %2", ValueTable.Count(), ValueTable.Cols.Count());
		EndDo;
	EndIf;
	
	FileName = "";

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Procedures - Form Event Handlers

// Form event handler OnCreateAtServer.
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	Var TempNode;

	InitialTitle = Title;
	InitializeReportTree(ReportsTree);
	ConsoleSettings = CommonSettingsStorage.Load("ReportSystemConsoleSettings5");

	If ConsoleSettings <> Undefined Then

		ConsoleSettings.Property("FileName", FileName);
		ConsoleSettings.Property("CurrentNode", TempNode);

		If TypeOf(TempNode) = Type("ValueList") Then

			CurrentNode = TempNode;

		EndIf;

	EndIf;

	DetailsFormName = "Report.UT_ReportsConsole.Form.DetailsForm";

	Items.Settings.Check = True;
	Items.ButtonResultsPanel.Check = True;

	If Parameters.Property("DebugData") Then
		FillDCSForDebug(Parameters.DebugData);
		Return;
	EndIf;
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.MainCommandBar);

EndProcedure

//Event handler Choice. Calls from  Data Composition Schema Wizard.
&AtClient
Procedure ChoiceProcessing(SelectedValue, ChoiceSource)

	Modified = True;
	SetDataCompositionSchemaAtClient(SelectedValue);
EndProcedure

//Event handler BeforeClose.
&AtClient
Procedure BeforeClose(Cancel, StandardProcessing)

	If Modified Then
		Cancel = True;
		ConfirmClose(New NotifyDescription("BeforeCloseOnEnd", ThisForm));
	EndIf;

EndProcedure

// end of  beforeclose handler.
&AtClient
Procedure BeforeCloseOnEnd(Result, AdditionalParameters) Export
	If Result Then
		Modified = False;
		Close();
	EndIf;
EndProcedure

// Event handler OnClose.
&AtClient
Procedure OnClose()

	SaveConsoleSettings();

EndProcedure

// Event handler OnOpen.
&AtClient
Procedure OnOpen(Cancel)

	If FileName <> "" Then

		DownloadableFileName = FileName;
		FileName = "";
		Try
			DownloadConsoleFile(DownloadableFileName);
		Except
			
			UT_CommonClientServer.MessageToUser(NSTR("ru = 'Ошибка загрузки отчетов из файла';en = 'Error loading reports from file'"));
		EndTry;
	EndIf;

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Procedures - Command Handlers

// command handler AddDataCompositionSchema.
&AtClient
Procedure AddDataCompositionSchema(Command)

	Var ElementsToWhichAdd;
	Var CurrentTreeItem;

	Modified = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		CurrentTreeItem = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

	EndIf;

	While CurrentTreeItem <> Undefined Do

		If CurrentTreeItem.RowType = 0 Or (CurrentTreeItem.RowType = 3 And FolderType(
			CurrentTreeItem) = 4) Or CurrentTreeItem.RowType = 4 Then

			Break;

		Else

			CurrentTreeItem = CurrentTreeItem.GetParent();

		EndIf;

	EndDo;

	If CurrentTreeItem <> Undefined Then

		If CurrentTreeItem.RowType = 3 Or CurrentTreeItem.RowType = 4 Then

				// Folder or root.
			ElementsToWhichAdd = CurrentTreeItem.GetItems();

		ElsIf CurrentTreeItem.GetParent() <> Undefined Then

			ElementsToWhichAdd = CurrentTreeItem.GetParent().GetItems();

		Else

			ElementsToWhichAdd = ReportsTree.GetItems();

		EndIf;

	Else

		ElementsToWhichAdd = ReportsTree.GetItems();

	EndIf;

	Name = GenerateDataCompositionSchemaName();
	Item = ElementsToWhichAdd.Add();
	Item.Name = Name;
	Item.RowType = 0;

	Items.ReportsTree.CurrentRow = Item.GetID();

EndProcedure

// command handler Generate.
&AtClient
Procedure Generate(Command)

	GenerateAtClient();

EndProcedure

// command handler ResultsPanel.
&AtClient
Procedure ResultsPanel(Command)

	Items.ResultsPanel.Visible = Not Items.ResultsPanel.Visible;
	Items.ButtonResultsPanel.Check = Items.ResultsPanel.Visible;

EndProcedure

// command handler DataCompositionSchemaWizard.
&AtClient
Procedure DataCompositionSchemaWizard(Command)

	OpenDataCompositionSchemaWizard();

EndProcedure

// command handler SaveReportsToFile.
&AtClient
Procedure SaveReportsToFile(Command)

//	SaveCurrentRowDataAndLoadCurrentRowAtServer();
	SaveCurrentRowDataAtServer();
	Save(False, New NotifyDescription("SaveToFileOnEnd", ThisForm));

EndProcedure

// command handler SaveReportsToFileAS.
&AtClient
Procedure SaveReportsToFileAS(Command)

	Save(True, New NotifyDescription("SaveToFileOnEnd", ThisForm));

EndProcedure

// End Of handler of file opening.
&AtClient
Procedure SaveToFileOnEnd(Result, AdditionalParameters) Export

	If Result Then
		Modified = False;
	EndIf;

EndProcedure

// command handler OpenReportsFile.
&AtClient
Procedure OpenReportsFile(Command)

	ConfirmClose(New NotifyDescription("OpenReportsFileOnEnd", ThisForm));

EndProcedure

// End of handler Open File.
&AtClient
Procedure OpenReportsFileOnEnd(Result, AdditionalParameters) Export

	If Result Then
		Modified = False;
		DownloadConsoleFile("");
	EndIf;

EndProcedure

// command handler NewReportsFile.
&AtClient
Procedure NewReportsFile(Command)

	ConfirmClose(New NotifyDescription("NewReportsFileOnEnd", ThisForm));

EndProcedure

//End of handler - create new reports file.
&AtClient
Procedure NewReportsFileOnEnd(Result, AdditionalParameters) Export

	If Result Then

		Modified = False;
		InitializeReportTree(ReportsTree);
		FileName = "";
		UpdateTitle();
		CurrentRow = Undefined;
		CurrentRowSettingsIsChanged = False;

	EndIf;

EndProcedure

// command handler OutputToSpreadsheetDocumentForCurrentTemplate.
&AtClient
Procedure OutputToSpreadsheetDocumentForCurrentTemplate(Command)

	ExecuteAtServerFromDataCompositionTemplate();

EndProcedure

// command handler SaveStandartSpreadsheetDocument.
&AtClient
Procedure SaveStandartSpreadsheetDocument(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	ResultSpreadsheetDocument.BeginWriting(Undefined, StandartFileNameOfSpreadsheetDocument());
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler CompareWithStandartSpreadsheetDocument.
&AtClient
Procedure CompareWithStandartSpreadsheetDocument(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	ResultSpreadsheetDocument.BeginWriting(New NotifyDescription("CompareWithStandartSpreadsheetDocumentOnEnd",
		ThisForm), SpreadsheetDocumentFileName());
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

&AtClient
Procedure CompareWithStandartSpreadsheetDocumentOnEnd(Result, AdditionalParameters) Export
#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then

	FileCompare = New FileCompare;
	FileCompare.FirstFile = StandartFileNameOfSpreadsheetDocument();
	FileCompare.SecondFile = SpreadsheetDocumentFileName();
	FileCompare.CompareMethod = FileCompareMethod.SpreadsheetDocument;
	FileCompare.ShowDifferences();
#Else
	Message(NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
	|en = 'File comparison is only possible in a thick client'"));

#EndIf
EndProcedure

// command handler SaveStandartOfDataCompositionTemplate.
&AtClient
Procedure SaveStandartOfDataCompositionTemplate(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	TextWriter = New TextWriter(TemplateStandartFileName(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplate);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler CompareWithStandartDataCompositionTemplate.
&AtClient
Procedure CompareWithStandartDataCompositionTemplate(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	TextWriter = New TextWriter(TemplateFileName(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplate);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = TemplateStandartFileName();
	FileCompare.SecondFile = TemplateFileName();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler SaveStandartExecutableSettings.
&AtClient
Procedure SaveStandartExecutableSettings(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	TextWriter = New TextWriter(ExecutableSettingsStandartFileName(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ExecutedSettingsXML);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler CompareWithStandartExecutableSettings.
&AtClient
Procedure CompareWithStandartExecutableSettings(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	TextWriter = New TextWriter(ExecutableSettingsFileName(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ExecutedSettingsXML);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ExecutableSettingsStandartFileName();
	FileCompare.SecondFile = ExecutableSettingsFileName();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler SaveStandartXMLResult.
&AtClient
Procedure SaveStandartXMLResult(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	TextWriter = New TextWriter(XMLResultStandartFileName(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResult);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler CompareWithStandartXMLResult.
&AtClient
Procedure CompareWithStandartXMLResult(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	TextWriter = New TextWriter(XMLResultFileName(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResult);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = XMLResultStandartFileName();
	FileCompare.SecondFile = XMLResultFileName();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler SaveStandartDataCompositionTemplateForTemplate.
&AtClient
Procedure SaveStandartDataCompositionTemplateForTemplate(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	TextWriter = New TextWriter(TemplateStandartFileNameForCollection(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplateForCollection);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler CompareWithStandartDataCompositionTemplateForCollection.
&AtClient
Procedure CompareWithStandartDataCompositionTemplateForCollection(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	TextWriter = New TextWriter(TemplateFileNameForCollection(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplateForCollection);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = TemplateStandartFileNameForCollection();
	FileCompare.SecondFile = TemplateFileNameForCollection();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler SaveStandartXMLResultForCollection.
&AtClient
Procedure SaveStandartXMLResultForCollection(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	TextWriter = New TextWriter(XMLResultStandartFileNameForCollection(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResultForCollection);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler CompareWithStandartXMLResultForCollection.
&AtClient
Procedure CompareWithStandartXMLResultForCollection(Command)

#If ThickClientManagedApplication Or ThickClientOrdinaryApplication Then
	TextWriter = New TextWriter(XMLResultFileNameForCollection(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResultForCollection);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = XMLResultStandartFileNameForCollection();
	FileCompare.SecondFile = XMLResultFileNameForCollection();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru = 'Сравнение файлов возможно только в толстом клиенте';
		|en = 'File comparison is only possible in a thick client'"));
#EndIf

EndProcedure

// command handler OutputToResultForCurrentTemplate.
&AtClient
Procedure OutputToResultForCurrentTemplate(Command)

	ExecuteToResultAtServerFromDataCompositionTemplate();

EndProcedure

// command handler OutputResultToSpreadsheetDocument.
&AtClient
Procedure OutputResultToSpreadsheetDocument(Command)

	OutputResultFromResultTextToSpreadsheetDocument();

EndProcedure

// command handler OutputToCollectionForCurrentTemplate.
&AtClient
Procedure OutputToCollectionForCurrentTemplate(Command)

	ExecuteAtServerFromDataCompositionTemplateToCollection();

EndProcedure

// command handler OutputToCollectionResultForCurrentTemplate.
&AtClient
Procedure OutputToCollectionResultForCurrentTemplate(Command)

	ExecuteToResultCollectionAtServerFromDataCompositionTemplate();

EndProcedure

// command handler OutputResultToCollection.
&AtClient
Procedure OutputResultToCollection(Command)

	OutputResultFromResultTextToCollection();

EndProcedure

// command handler SaveSchemaToFile
&AtClient
Procedure SaveSchemaToFile(Command)

	BeginAttachingFileSystemExtension(New NotifyDescription("SaveSchemaToFileAfterAttachFileExtension",
		ThisForm));

EndProcedure

// Schema saving Event handler  to File after attach file extension .
&AtClient
Procedure SaveSchemaToFileAfterAttachFileExtension(Attached, AdditionalParameters) Export

	If Attached Then

	// Need to ask filename.
		FileChoose = New FileDialog(FileDialogMode.Save);
		FileChoose.Multiselect = False;
		Filter = NStr("ru = 'Файл схемы компоновки данных (*.xml)|*.xml|Все файлы (*.*)|*.*';
		|en = 'File of data composition schema (*.xml)|*.xml|All files (*.*)|*.*'");
		FileChoose.Filter = Filter;
		FileChoose.Extension = "xml";

		FileChoose.Show(New NotifyDescription("SaveSchemaToFileAfterFileSelection", ThisForm,
			New Structure("FileChoose", FileChoose)));

	Else

		GetFile(PutDataCompositionSchemaToTempStorage(), , True);

	EndIf;

EndProcedure

// Schema saving Event handler  to File after file saving dialog.
&AtClient
Procedure SaveSchemaToFileAfterFileSelection(SelectedFiles, AdditionalParameters) Export

	FileChoose = AdditionalParameters.FileChoose;

	If SelectedFiles = Undefined Then

		Return;

	EndIf;

	FilesToBeObtained = New Array;
	FilesToBeObtained.Add(New TransferableFileDescription(FileChoose.FullFileName,
		PutDataCompositionSchemaToTempStorage()));
	BeginGettingFiles(New NotifyDescription("SaveSchemaToFileOnEnd", ThisForm), FilesToBeObtained, "",
		False);

EndProcedure

&AtClient
Procedure SaveSchemaToFileOnEnd(ReceivedFiles, AdditionalParameters) Export

	UpdateTitle();

EndProcedure

// command handler LoadSchemaFromFile
&AtClient
Procedure LoadSchemaFromFile(Command)

	Var Address;

	BeginAttachingFileSystemExtension(
		New NotifyDescription("LoadSchemaFromFileAfterAttachExtension", ThisForm, New Structure("Address",
		Address)));
EndProcedure

//  Handler  of loading schema from file after attach extension.
&AtClient
Procedure LoadSchemaFromFileAfterAttachExtension(Attached, AdditionalParameters) Export

	Address = AdditionalParameters.Address;

	If Attached Then

		FileChoose = New FileDialog(FileDialogMode.Opening);
		FileChoose.Multiselect = False;
		Filter = NStr("ru = 'Файл схемы компоновки данных (*.xml)|*.xml|Все файлы (*.*)|*.*';
		|en = 'File of data composition schema  (*.xml)|*.xml|All files (*.*)|*.*'");
		FileChoose.Filter = Filter;
		FileChoose.Extension = "xml";

		BeginPuttingFiles(New NotifyDescription("LoadSchemaFromFileAfterPutFiles", ThisForm), ,
			FileChoose);

	Else

		BeginPutFile(New NotifyDescription("LoadSchemaFromFileAfterPutFile", ThisForm,
			New Structure("Address", Address)), Address, , True);

	EndIf;

EndProcedure

// Handler of schema loading from file after put files 
&AtClient
Procedure LoadSchemaFromFileAfterPutFiles(PlacedFiles, AdditionalParameters) Export

	If PlacedFiles = Undefined Then

		Return;

	EndIf;

	For Each PlacedFile In PlacedFiles Do

		If PlacedFile.Location <> "" Then

			Address = PlacedFile.Location;
			Break;

		EndIf;

	EndDo;

	LoadDataCompositionSchemaFileAtServer(Address);

EndProcedure

// Handler of schema loading from file after put file
&AtClient
Procedure LoadSchemaFromFileAfterPutFile(Result, Address, SelectedFileName, AdditionalParameters) Export

	Address = AdditionalParameters.Address;

	If Not Result Then

		Return;

	EndIf;

	LoadDataCompositionSchemaFileAtServer(Address);

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// Procedures  - Form Attributes event Handlers 
// 
// Event handler OnActivateField of Structure table.
// Activate settings page linked with column that user activated
&AtClient
Procedure StructureOnActivateField(Item)
	
	Var SelectedPage;

	If Items.Structure.CurrentItem.Name = "StructureHasSelection" Then

		SelectedPage = Items.PageSelectedFields;

	ElsIf Items.Structure.CurrentItem.Name = "StructureHasFilter" Then

		SelectedPage = Items.PageFilter;

	ElsIf Items.Structure.CurrentItem.Name = "StructureHasOrder" Then

		SelectedPage = Items.OrderPage;

	ElsIf Items.Structure.CurrentItem.Name = "StructureHasConditionalAppearance" Then

		SelectedPage = Items.ConditionalAppearancePage;

	ElsIf Items.Structure.CurrentItem.Name = "StructureHasOutputParameters" Then

		SelectedPage = Items.OutputParametersPage;

	EndIf;

	If SelectedPage <> Undefined Then

		Items.SettingsPages.CurrentPage = SelectedPage;

	EndIf;
EndProcedure


// Event handler OnActivateField of Structure1 table.
// Activate settings page linked with column that user activated
&AtClient
Procedure Settings1OnActivateField(Item)
	Var SelectedPage;

	If Items.Settings1.CurrentItem.Name = "Structure1HasSelection" Then

		SelectedPage = Items.PageSelectedFields1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1HasFilter" Then

		SelectedPage = Items.FilterPage1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1HasOrder" Then

		SelectedPage = Items.OrderPage1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1HasConditionalAppearance" Then

		SelectedPage = Items.ConditionalAppearancePage1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1HasOutputParameters" Then

		SelectedPage = Items.OutputParametersPage1;

	EndIf;

	If SelectedPage <> Undefined Then

		Items.PagesSettings1.CurrentPage = SelectedPage;

	EndIf;
EndProcedure

// Handler StructureOnActivateRow of  Structure form item
// Sets pages  with settings up to date
&AtClient
Procedure StructureOnActivateRow(Item)
	
	TreeCurrentRow = Items.Structure.CurrentRow;
	If TreeCurrentRow = Undefined Then
		Return;
	EndIf;

	SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(TreeCurrentRow);
	ItemType = TypeOf(SettingsItem);

	If ItemType = Undefined Or ItemType = Type("DataCompositionChartStructureItemCollection")
		Or ItemType = Type("DataCompositionTableStructureItemCollection") Then

		GroupFieldsNotAvailable();
		SelectedFieldsUnavailable();
		FilterUnavailable();
		OrderUnavailable();
		ConditionalAppearanceUnavailable();
		OutputParametersUnavailable();

	ElsIf ItemType = Type("DataCompositionSettings") Or ItemType = Type(
		"DataCompositionNestedObjectSettings") Then

		GroupFieldsNotAvailable();

		LocalSelectedFields = True;
		Items.LocalSelectedFields.ReadOnly = True;
		Items.PagesSelectedFields.CurrentPage = Items.SelectedFieldsSettings;

		LocalFilter = True;
		Items.LocalFilter.ReadOnly = True;
		Items.FilterPages.CurrentPage = Items.FilterSettings;

		LocalOrder = True;
		Items.LocalOrder.ReadOnly = True;
		Items.OrderPages.CurrentPage = Items.OrderSettings;

		LocalConditionalAppearance = True;
		Items.LocalConditionalAppearance.ReadOnly = True;
		Items.ConditionalAppearancePages.CurrentPage = Items.ConditionalAppearanceSettings;

		LocalOutputParameters = True;
		Items.LocalOutputParameters.ReadOnly = True;
		Items.OutputParametersPages.CurrentPage = Items.OutputParametersSettings;

	ElsIf ItemType = Type("DataCompositionGroup") Or ItemType = Type(
		"DataCompositionTableGroup") Or ItemType = Type("DataCompositionChartGroup") Then

		Items.PagesGroupFields.CurrentPage = Items.GroupFieldsSettings;

		SelectedFieldsAvailable(SettingsItem);
		FilterAvailable(SettingsItem);
		OrderAvailable(SettingsItem);
		ConditionalAppearanceAvailable(SettingsItem);
		OutputParametersAvailable(SettingsItem);

	ElsIf ItemType = Type("DataCompositionTable") Or ItemType = Type("DataCompositionChart") Then

		GroupFieldsNotAvailable();
		SelectedFieldsAvailable(SettingsItem);
		FilterUnavailable();
		OrderUnavailable();
		ConditionalAppearanceAvailable(SettingsItem);
		OutputParametersAvailable(SettingsItem);

	EndIf;
EndProcedure


// Handler StructureOnActivateRow of  Structure1 form item
// Sets pages  with settings up to date
&AtClient
Procedure Settings1OnActivateRow(Item)
	SettingsItem = ExecutedSettingsComposer.Settings.GetObjectByID(
		Items.Settings1.CurrentRow);
	ItemType = TypeOf(SettingsItem);

	If ItemType = Undefined Or ItemType = Type("DataCompositionChartStructureItemCollection")
		Or ItemType = Type("DataCompositionTableStructureItemCollection") Then

		GroupFieldsNotAvailable1();
		SelectedFieldsUnavailable1();
		FilterUnavailable1();
		OrderUnavailable1();
		ConditionalAppearanceUnavailable1();
		OutputParametersUnavailable1();

	ElsIf ItemType = Type("DataCompositionSettings") Or ItemType = Type(
		"DataCompositionNestedObjectSettings") Then

		GroupFieldsNotAvailable1();

		LocalSelectedFields1 = True;
		Items.LocalSelectedFields1.ReadOnly = True;
		Items.PagesSelectedFields1.CurrentPage = Items.SelectedFieldsSettings1;

		LocalFilter1 = True;
		Items.LocalFilter1.ReadOnly = True;
		Items.FilterPages1.CurrentPage = Items.FilterSettings1;

		LocalOrder1 = True;
		Items.LocalOrder1.ReadOnly = True;
		Items.OrderPages1.CurrentPage = Items.OrderSettings1;

		LocalConditionalAppearance1 = True;
		Items.LocalConditionalAppearance1.ReadOnly = True;
		Items.ConditionalAppearancePages1.CurrentPage = Items.ConditionalAppearanceSettings1;

		LocalOutputParameters1 = True;
		Items.LocalOutputParameters1.ReadOnly = True;
		Items.OutputParametersPages1.CurrentPage = Items.OutputParametersSettings1;

	ElsIf ItemType = Type("DataCompositionGroup") Or ItemType = Type(
		"DataCompositionTableGroup") Or ItemType = Type("DataCompositionChartGroup") Then

		Items.GroupFieldsPages1.CurrentPage = Items.GroupFieldsSettings1;

		SelectedFieldsAvailable1(SettingsItem);
		FilterAvailable1(SettingsItem);
		OrderAvailable1(SettingsItem);
		ConditionalAppearanceAvailable1(SettingsItem);
		OutputParametersAvailable1(SettingsItem);

	ElsIf ItemType = Type("DataCompositionTable") Or ItemType = Type("DataCompositionChart") Then

		GroupFieldsNotAvailable1();
		SelectedFieldsAvailable1(SettingsItem);
		FilterUnavailable1();
		OrderUnavailable1();
		ConditionalAppearanceAvailable1(SettingsItem);
		OutputParametersAvailable1(SettingsItem);

	EndIf;
EndProcedure

// Event handler OnClick for Decorations.
&AtClient
Procedure GoToReport(Item)

	SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
		Items.Structure.CurrentRow);
	ItemSettings = Report.SettingsComposer.Settings.ItemSettings(SettingsItem);
	Items.Structure.CurrentRow = Report.SettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

// Event handler OnClick for Decorations. for executable settings.
&AtClient
Procedure GoToReport1(Item)

	SettingsItem = ExecutedSettingsComposer.Settings.GetObjectByID(
		Items.Settings1.CurrentRow);
	ItemSettings = ExecutedSettingsComposer.Settings.ItemSettings(SettingsItem);
	Items.Settings1.CurrentRow = ExecutedSettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

// Event handler OnChange of checkbox LocalSelectedFields.
&AtClient
Procedure LocalSelectedFieldsOnChange(Item)
		If LocalSelectedFields Then

		Items.PagesSelectedFields.CurrentPage = Items.SelectedFieldsSettings;

	Else

		Items.PagesSelectedFields.CurrentPage = Items.SelectedFieldsDisabledSettings;

		SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentRow);
		Report.SettingsComposer.Settings.ClearItemSelection(SettingsItem);

	EndIf;
EndProcedure

// Event handler OnChange of checkbox LocalSelectedFields1.
&AtClient
Procedure LocalSelectedFields1OnChange(Item)
	If LocalSelectedFields1 Then

		Items.PagesSelectedFields1.CurrentPage = Items.SelectedFieldsSettings1;

	Else

		Items.PagesSelectedFields1.CurrentPage = Items.DisabledSelectedFieldsSettings1;

		SettingsItem = ExecutedSettingsComposer.Settings.GetObjectByID(
			Items.Settings1.CurrentRow);
		ExecutedSettingsComposer.Settings.ClearItemSelection(SettingsItem);

	EndIf;
EndProcedure

// Event handler OnChange of checkbox LocalFilter.
&AtClient
Procedure LocalFilterOnChange(Item)
		If LocalFilter Then

		Items.FilterPages.CurrentPage = Items.FilterSettings;

	Else

		Items.FilterPages.CurrentPage = Items.DisabledFilterSettings;

		SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentRow);
		Report.SettingsComposer.Settings.ClearItemFilter(SettingsItem);

	EndIf;
EndProcedure

// Event handler OnChange of checkbox LocalFilter1.
&AtClient
Procedure LocalFilter1OnChange(Item)
		If LocalFilter1 Then

		Items.FilterPages1.CurrentPage = Items.FilterSettings1;

	Else

		Items.FilterPages1.CurrentPage = Items.DisabledFilterSettings1;

		SettingsItem = ExecutedSettingsComposer.Settings.GetObjectByID(
			Items.Settings1.CurrentRow);
		ExecutedSettingsComposer.Settings.ClearItemFilter(SettingsItem);

	EndIf;
EndProcedure

// Event handler OnChange of checkbox LocalOrder.
&AtClient
Procedure LocalOrderOnChange(Item)
	
	If LocalOrder Then

		Items.OrderPages.CurrentPage = Items.OrderSettings;

	Else

		Items.OrderPages.CurrentPage = Items.DisabledOrderSettings;

		SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentRow);
		Report.SettingsComposer.Settings.ClearItemOrder(SettingsItem);

	EndIf;
EndProcedure

// Event handler OnChange of checkbox LocalOrder1.
&AtClient
Procedure LocalOrder1OnChange(Item)
	If LocalOrder1 Then

		Items.OrderPages1.CurrentPage = Items.OrderSettings1;

	Else

		Items.OrderPages1.CurrentPage = Items.DisabledOrderSettings1;

		SettingsItem = ExecutedSettingsComposer.Settings.GetObjectByID(
			Items.Settings1.CurrentRow);
		ExecutedSettingsComposer.Settings.ClearItemOrder(SettingsItem);

	EndIf;
EndProcedure

// Event handler OnChange of checkbox LocalConditionalAppearance.
&AtClient
Procedure LocalConditionalAppearanceOnChange(Item)
		If LocalConditionalAppearance Then

		Items.ConditionalAppearancePages.CurrentPage = Items.ConditionalAppearanceSettings;

	Else

		Items.ConditionalAppearancePages.CurrentPage = Items.DisabledConditionalAppearanceSettings;

		SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentRow);
		Report.SettingsComposer.Settings.ClearItemConditionalAppearance(SettingsItem);

	EndIf;
EndProcedure

// Event handler OnChange of checkbox LocalConditionalAppearance1.
&AtClient
Procedure LocalConditionalAppearance1OnChange(Item)
	If LocalConditionalAppearance1 Then

		Items.ConditionalAppearancePages1.CurrentPage = Items.ConditionalAppearanceSettings1;

	Else

		Items.ConditionalAppearancePages1.CurrentPage = Items.DisabledConditionalAppearanceSettings1;

		SettingsItem = ExecutedSettingsComposer.Settings.GetObjectByID(
			Items.Settings1.CurrentRow);
		ExecutedSettingsComposer.Settings.ClearItemConditionalAppearance(SettingsItem);

	EndIf;
EndProcedure

// Event handler OnChange of checkbox LocalOutputParameters.
&AtClient
Procedure LocalOutputParametersOnChange(Item)
		If LocalOutputParameters Then

		Items.OutputParametersPages.CurrentPage = Items.OutputParametersSettings;

	Else

		Items.OutputParametersPages.CurrentPage = Items.DisabledOutputParametersSettings;

		SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentRow);
		Report.SettingsComposer.Settings.ClearItemOutputParameters(SettingsItem);
	EndIf;
EndProcedure

// Event handler OnChange of checkbox LocalOutputParameters1.
&AtClient
Procedure LocalOutputParameters1OnChange(Item)
	If LocalOutputParameters1 Then

		Items.OutputParametersPages1.CurrentPage = Items.OutputParametersSettings1;

	Else

		Items.OutputParametersPages1.CurrentPage = Items.DisabledOutputParametersSettings1;

		SettingsItem = ExecutedSettingsComposer.Settings.GetObjectByID(
			Items.Settings1.CurrentRow);
		ExecutedSettingsComposer.Settings.ClearItemOutputParameters(SettingsItem);
	EndIf;
EndProcedure

// Event handler OnActivateRow of item  ReportsTree.
//Displays the corresponding tab - scheme, option, Custom Settings, etc.
&AtClient
Procedure ReportsTreeOnActivateRow(Item)
	
	If Not RowIsBeingActivated And CurrentRow <> Item.CurrentRow Then

		RowIsBeingActivated = True;

		If Item.CurrentRow <> Undefined Then

			TreeItem = ReportsTree.FindByID(Item.CurrentRow);

			If TreeItem.RowType = 0 Then
			// Data composition scheme
				If Items.GroupSettings.CurrentPage <> Items.GroupVariant Then

					Items.GroupSettings.CurrentPage = Items.GroupVariant;

				EndIf;
				//				
				//			ElsIf TreeItem.RowType = 1 Then
				//				// Report variant.
				//				If Items.GroupSettings.CurrentPage <> Items.GroupVariant Then
				//					
				//					Items.GroupSettings.CurrentPage = Items.GroupVariant;
				//					
				//				EndIf;
				//				
				//			ElsIf TreeItem.RowType = 2 Then
				//				// User Settings.
				//				If Items.GroupSettings.CurrentPage <> Items.GroupUserSettings Then
				//					
				//					Items.GroupSettings.CurrentPage = Items.GroupUserSettings;
				//					
				//				EndIf;
				//				
				//			Else
				// Unknown type.
				//				If Items.GroupSettings.CurrentPage <> Items.EmptyGroup Then
				//					
				//					Items.GroupSettings.CurrentPage = Items.EmptyGroup;
				//					
				//				EndIf;
			EndIf;

		EndIf;

		Try

			SaveCurrentRowDataAndLoadCurrentRowAtServer();
			CurrentRow = Item.CurrentRow;
			RowIsBeingActivated = False;

		Except

			CurrentRow = Undefined; // It's for not damage settings in tree.
			RowIsBeingActivated = False;

		EndTry;

	EndIf;
EndProcedure

&AtClient
Procedure Settings(Command)
	DisplaySettingsPanel();
EndProcedure

// Event handler OnChange items linked with settings.
&AtClient
Procedure SettingsOnChange(Item)
	CurrentRowSettingsIsChanged = True;
	Modified = True;
EndProcedure

&AtClient
Procedure SettingsDragEnd(Item, DragParameters, StandardProcessing)
	CurrentRowSettingsIsChanged = True;
	Modified = True;
EndProcedure

&AtClient
Procedure SettingsDrag(Item, DragParameters, StandardProcessing, Row, Field)
	CurrentRowSettingsIsChanged = True;
	Modified = True;
EndProcedure


// Event handler BeforeAddRow of Item ReportsTree.
&AtClient
Procedure ReportsTreeBeforeAddRow(Item, Cancel, Clone, Parent, IsFolder, Parameter)
	
		If Clone Then

		Cancel = True;

		If ReportsTree.FindByID(Item.CurrentRow).RowType <> 4 Then
		// Not root.
			CopyAtServer();

		EndIf;

	EndIf;
EndProcedure

// Event handler BeforeDeleteRow of item ReportsTree.
&AtClient
Procedure ReportsTreeBeforeDeleteRow(Item, Cancel)
	CurrentRow = Undefined;
EndProcedure

// Event handler Selection of item ReportsTree.
&AtClient
Procedure ReportsTreeSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;
	GenerateAtClient();
EndProcedure


// Event handler AdditionalDetailProcessing of  Spreadsheet Document ResultSpreadsheetDocument.
&AtClient
Procedure ResultSpreadsheetDocumentAdditionalDetailProcessing(Item, Details, StandardProcessing, AdditionalParameters)
	StandardProcessing = False;
	DetailProcessing = New DataCompositionDetailsProcess(DetailsDataURL,
		New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
	DetailProcessing.ShowActionChoice(
		New NotifyDescription("ResultSpreadsheetDocumentDetailProcessingOnEnd", ThisForm,
		New Structure("Details", Details)), Details, , , , Items.ResultSpreadsheetDocument);
EndProcedure

// Event handler DetailProcessing Spreadsheet Document ResultSpreadsheetDocument.
&AtClient
Procedure ResultSpreadsheetDocumentDetailProcessing(Item, Details, StandardProcessing, AdditionalParameters)
		StandardProcessing = False;
	DetailProcessing = New DataCompositionDetailsProcess(DetailsDataURL,
		New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
	DetailProcessing.ShowActionChoice(
		New NotifyDescription("ResultSpreadsheetDocumentDetailProcessingOnEnd", ThisForm,
		New Structure("Details", Details)), Details, , , True, );
EndProcedure

// Details action choose event handler.
&AtClient
Procedure  ResultSpreadsheetDocumentDetailProcessingOnEnd(ChosenAction, ChosenActionParameter,
	AdditionalParameters) Export

	Details = AdditionalParameters.Details;

	If ChosenAction = DataCompositionDetailsProcessingAction.None Then

	ElsIf ChosenAction = DataCompositionDetailsProcessingAction.OpenValue Then

		ShowValue( , ChosenActionParameter);

	ElsIf ChosenAction <> Undefined Then

		OpenForm(DetailsFormName, New Structure("Details,DataCompositionSchemaURL",
			New DataCompositionDetailsProcessDescription(DetailsDataURL, Details,
			ChosenActionParameter), ExecutedReportSchemaURL), , True);

	EndIf;

EndProcedure

// Event handler OnPageChange of panel ResultsPanel.
&AtClient
Procedure ResultsPanelOnCurrentPageChange(Item, CurrentPage)
    If Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument Then

		If ReportNeedsToGenerate And Not ResultFilledSpreadsheetDocument Then

			Result = GenerateAtServerToSpreadsheetDocument();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageDataCompositionTemplate Then

		If ReportNeedsToGenerate And Not ResultFilledTemplate Then

			Result = GenerateAtServerToDataCompositionTemplate();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageExecutedSettings Then

		If ReportNeedsToGenerate And Not ResultFilledSettings Then

			Result = GenerateAtServerToExecutedDataCompositionSettings();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageExecutedSettingsXML Then

		If ReportNeedsToGenerate And Not ResultFilledSettingsXML Then

			Result = GenerateAtServerToExecutedDataCompositionSettingsXML();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageDataCompositionResultXML Then

		If ReportNeedsToGenerate And Not ResultFilledXML Then

			Result = GenerateAtServerAsXML();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageResultCollection Then

		If ReportNeedsToGenerate And Not ResultFilledCollection Then

			Result = GenerateAtServerToCollection();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageTemplateForCollection Then

		If ReportNeedsToGenerate And Not ResultFilledTemplateForCollection Then

			Result = GenerateAtServerToDataCompositionTemplateForCollection();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageResultCollectionXML Then

		If ReportNeedsToGenerate And Not ResultFilledCollectionXML Then

			Result = GenerateAtServerAsXMLCollection();

		EndIf;

	EndIf;

	If Result <> Undefined Then

		ShowMessageBox( , Result);

	EndIf;
EndProcedure

// Event handler selection of  TreeResult table.
&AtClient
Procedure TreeResultSelection(Item, RowSelected, Field, StandardProcessing)
		Var Value;

	StandardProcessing = False;

	If Items.TreeResult.CurrentData.Property(Items.TreeResult.CurrentItem.Name, Value) Then

		ShowValue( , Value);

	EndIf;

EndProcedure

&AtClient
Procedure ExternalDataSetsPresentationStartChoice(Item, ChoiceData, StandardProcessing)
		StandardProcessing=False;
	CurrentData=Items.ExternalDataSets.CurrentData;
	If CurrentData=Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditValueTable(CurrentData.Value, ThisObject,
		New NotifyDescription("ExternalDataSetsPresentationStartChoiceOnEnd", ThisObject,New Structure("CurrentRow",Items.ExternalDataSets.CurrentRow)));
EndProcedure

&AtClient
Procedure ExternalDataSetsPresentationStartChoiceOnEnd(Result, AdditionalParameters) Export
	If Result=Undefined Then
		Return;
	EndIf;
	TreeCurrentRow=ReportsTree.FindByID(CurrentRow);
	If TreeCurrentRow=Undefined Then
		Return;
	EndIf;
	RowCurrentData=TreeCurrentRow.ExternalDataSets.FindByID(AdditionalParameters.CurrentRow);
	RowCurrentData.Value=Result.Value;
	RowCurrentData.Presentation=Result.Presentation;
EndProcedure

&AtClient
Procedure ExternalDataSetsBeforeEditEnd(Item, NewRow, CancelEdit, Cancel)
	If CancelEdit Then
		Return;
	EndIf;	
		
	CurrentData=Items.ExternalDataSets.CurrentData;
	If CurrentData=Undefined Then
		Return;
	EndIf;
	CurrentData.Name=TrimAll(CurrentData.Name);
	
	If Not UT_CommonClientServer.IsCorrectVariableName(CurrentData.Name) Then
		ShowMessageBox( ,
			UT_CommonClientServer.WrongVariableNameWarningText(),
			, Title);
		Cancel = True;
		Return;
	EndIf;
	
	TreeCurrentRow=ReportsTree.FindByID(CurrentRow);
	If TreeCurrentRow=Undefined Then
		Return;
	EndIf;
	
	ArrayOfNameString = TreeCurrentRow.ExternalDataSets.FindRows(New Structure("Name", CurrentData.Name));
	If ArrayOfNameString.Count() > 1 Then
		ShowMessageBox( , NSTR("ru = 'Колонка с таким именем уже есть! Введите другое имя';
		|en = 'There is already a column with that name! Enter a different name'"), , Title);
		Cancel = True;
		Return;
	EndIf;
EndProcedure

&AtServer
Function ExternalDataSetsStructure()
	ExternalSets=New Structure;
	
	TreeCurrentRow=ReportsTree.FindByID(CurrentRow);
	If TreeCurrentRow=Undefined Then
		Return ExternalSets;
	EndIf;
		
	For Each Set in TreeCurrentRow.ExternalDataSets Do
		If ValueIsFilled(Set.Value) Then
			Try
				ValueTable=ValueFromStringInternal(Set.Value);
			Except
				ValueTable=New ValueTable;
			EndTry;
		Else
			ValueTable=New ValueTable;
		EndIf;
		ExternalSets.Insert(Set.Name, ValueTable);
	EndDo;
	Return ExternalSets;
EndFunction

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

////////////////////////////////////////////////////////////////////////////////