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
	ReportResultOutputProcessor.Put(DataCompositionProcessor);
	ReportResultOutputProcessor.EndOutput();

	If DetailsDataObject <> Undefined Then

		DetailsDataURL = PutToTempStorage(DetailsDataObject, UUID);

	EndIf;

EndProcedure

// Execute composition and get text of result data composition in XML view
//
// Парамерты:
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

// Вывести Data Composition Template в результат XML.
//
// Parameters:
//  DataCompositionTemplate - макет компоновки, который нужно вывести.
//  DetailsDataObject - данные расшифровки, которые нужно заполнить.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, DetailsDataObject)

	TextOfDataCompositionResult = GetTextOfDataCompositionResult(DataCompositionTemplate,
		DetailsDataObject);

EndProcedure

// Вывести Data Composition Template в результат в виде XML для коллекции значений.
//
// Parameters:
//  DataCompositionTemplate - макет, который нужно вывести.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate)

	TextOfDataCompositionResultForCollection = GetTextOfDataCompositionResult(DataCompositionTemplate,
		Undefined);

EndProcedure

// Generate на сервере текущую строку в табличный документ.
//
// Return value:
//  String - текст ошибки, который нужно выдать пользователю.
&AtServer
Function СформироватьНаСервереВТабличныйДокумент()

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
			//			// Variant отчета.
			//			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			TemplateComposer = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema, Report.SettingsComposer.Settings, DetailsDataObject);
			//			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			//			OutputDataCompositionTemplateToSpreadsheetDocument(DataCompositionTemplate, DetailsDataObject);
			//			DisplayResultsPanel();
			//			
			//		ElsIf Item.RowType = 2 Then
			//			// Settings отчета.
			//			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			TemplateComposer = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema, Report.SettingsComposer.GetSettings(), DetailsDataObject);
			//			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			//			OutputDataCompositionTemplateToSpreadsheetDocument(DataCompositionTemplate, DetailsDataObject);
			//			DisplayResultsPanel();
		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Вывести дерево значений в реквизит формы.
//
// Parameters:
//  ВременноеДерево - дерево, которое нужно вывести.
&AtServer
Procedure ВывестиДеревоРезультатВКоллекцию(ВременноеДерево)

	НовыеРеквзиты = New Array;

	For Each Column In ВременноеДерево.Cols Do
		If Column.ValueType.ContainsType(Type("ValueStorage")) Then
			Continue;
		EndIf;

		NewColumn = New FormAttribute(Column.Name, Column.ValueType, "TreeResult", Column.Title);
		НовыеРеквзиты.Add(NewColumn);

	EndDo;

	УдаляемыеРеквизиты = New Array;
	ТекущиеРеквизиты = GetAttributes("TreeResult");

	For Each Attribute In ТекущиеРеквизиты Do

		УдаляемыеРеквизиты.Add(Attribute.Path + "." + Attribute.Name);

	EndDo;

	ChangeAttributes(НовыеРеквзиты, УдаляемыеРеквизиты);

	While Items.TreeResult.ChildItems.Count() > 0 Do

		Items.Delete(Items.TreeResult.ChildItems[0]);

	EndDo;

	For Each Column In ВременноеДерево.Cols Do
		If Column.ValueType.ContainsType(Type("ValueStorage")) Then
			Continue;
		EndIf;

		Item = Items.Add(Column.Name, Type("FormField"), Items.TreeResult);
		Item.DataPath = "TreeResult." + Column.Name;

	EndDo;

	Items.DecorationCollection.Visible = НовыеРеквзиты.Count() = 0;

	ValueToFormAttribute(ВременноеДерево, "TreeResult");

EndProcedure

// Вывести Data Composition Template в виде коллекции в реквизит формы.
//
// Parameters:
//  DataCompositionTemplate - макет, который нужно вывести.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate)

	DataCompositionProcessor = New DataCompositionProcessor;
	DataCompositionProcessor.Initialize(DataCompositionTemplate, ExternalDataSetsStructure(), , True);
	ReportResultOutputProcessor = New DataCompositionResultValueCollectionOutputProcessor;
	ReportResultOutputProcessor.SetObject(New ValueTree);
	ReportResultOutputProcessor.BeginOutput();
	ReportResultOutputProcessor.Put(DataCompositionProcessor);
	ВывестиДеревоРезультатВКоллекцию(ReportResultOutputProcessor.EndOutput());

EndProcedure

// Generate на сервере результат и вывести его в коллекцию значений.
//
// Return value:
//  String - текст сообщения, которое нужно показать пользователю.
&AtServer
Function СформироватьНаСервереВКоллекцию()

	ResultFilledCollection = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = GetDataCompositionSchemaAtServer();
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
			DisplayResultsPanel();

			//		ElsIf Item.RowType = 1 Then
			//			// Variant отчета.
			//			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			TemplateComposer = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema, Report.SettingsComposer.Settings , , , Type("DataCompositionValueCollectionTemplateGenerator"));
			//			ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
			//			DisplayResultsPanel();
			//			
			//		ElsIf Item.RowType = 2 Then
			//			// Settings отчета.
			//			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			TemplateComposer = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema, Report.SettingsComposer.GetSettings() , , , Type("DataCompositionValueCollectionTemplateGenerator"));
			//			ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
			//			DisplayResultsPanel();
		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate на сервере отчет и вывести его в виде XML.
//
// Return value:
//  String - текст сообщения, которое нужно показать пользователю.
&AtServer
Function СформироватьНаСервереВВидеXML()

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
			ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, DetailsDataObject);
			DisplayResultsPanel();

		ElsIf Item.RowType = 1 Then
		// Variant отчета.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, DetailsDataObject);
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then
		// Settings отчета.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, DetailsDataObject);
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate результат отчета для коллекции и выдать его в виде текста XML.
//
// Return value:
//  String - текст сообщения, который нужно показать пользователю.
&AtServer
Function СформироватьНаСервереВВидеXMLКоллекция()

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
			ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 1 Then
		// Variant отчета.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then
		// Settings отчета.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Вывести Data Composition Template в виде текста.
//
// Parameters:
//  DataCompositionTemplate - выводимый макет.
//
// Return value:
//  String - текст макета компоновки данных в виде XML.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВТекст(DataCompositionTemplate)

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, DataCompositionTemplate, "dataComposition",
		"http://v8.1c.ru/8.1/data-composition-system/composition-template");
	TextOfDataCompositionTemplate = XMLWriter.Close();

EndProcedure

// Generate Data Composition Template.
// 
// Return value:
//  String - текст сообщения, который нужно выдать пользователю.
&AtServer
Function СформироватьНаСервереВМакетКомпоновкиДанных()

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
			ВывестиМакетКомпоновкиДанныхВТекст(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 1 Then
		// Variant отчета.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВТекст(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then
		// Settings отчета.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), DetailsDataObject);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВТекст(DataCompositionTemplate);
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Вывести Data Composition Template для коллекции значений в виде текста.
//
// Parameters:
// DataCompositionTemplate - Data Composition Template, который нужно вывести.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВТекстДляКоллекции(DataCompositionTemplate)

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, DataCompositionTemplate, "dataComposition",
		"http://v8.1c.ru/8.1/data-composition-system/composition-template");
	TextOfDataCompositionTemplateForCollection = XMLWriter.Close();

EndProcedure

// Generate Data Composition Template для коллекции.
//
// Return value:
//  String - выводимая пользователю String.
&AtServer
Function СформироватьНаСервереВМакетКомпоновкиДанныхДляКоллекции()

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
			ВывестиМакетКомпоновкиДанныхВТекстДляКоллекции(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 1 Then
		// Variant отчета.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВТекстДляКоллекции(DataCompositionTemplate);
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then
		// Settings отчета.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			TemplateComposer = New DataCompositionTemplateComposer;
			DataCompositionTemplate = TemplateComposer.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВТекстДляКоллекции(DataCompositionTemplate);
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate исполняемые Settings.
//
// Return value:
//  String - сообщение, которое нужно выдать пользователю.
&AtServer
Function СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанных()

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

		// Variant отчета.
			DataCompositionSchema = GetDataCompositionSchema(FoundItemReportTree(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ExecutedSettingsComposer.Initialize(
				New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
			ExecutedSettingsComposer.LoadSettings(Report.SettingsComposer.Settings);
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then

		// Settings отчета.
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
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate исполняемые Settings и выдать их в виде XML.
//
// Return value:
//  String - текст, выдаваемый пользователю.
&AtServer
Function СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанныхXML()

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
		// Variant отчета.
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.Settings, "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ExecutedSettingsXML = XMLWriter.Close();
			DisplayResultsPanel();

		ElsIf Item.RowType = 2 Then
		// Settings отчета.
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.GetSettings(), "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ExecutedSettingsXML = XMLWriter.Close();
			DisplayResultsPanel();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate отчет на сервере. Формирование идет в зависимости от текущей страницы панели результатов.
//
// Return value:
//  String - текст, выдаваемый пользователю.
&AtServer
Function СформироватьНаСервере()

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

		Return СформироватьНаСервереВТабличныйДокумент();

//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageDataCompositionTemplate Тогда
//
//		Возврат СформироватьНаСервереВМакетКомпоновкиДанных();
//
//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageExecutedSettings Тогда
//
//		Возврат СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанных();
//
//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageExecutedSettingsXML Тогда
//
//		Возврат СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанныхXML();
//
//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageDataCompositionResultXML Тогда
//
//		Возврат СформироватьНаСервереВВидеXML();

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageResultCollection Then

		Return СформироватьНаСервереВКоллекцию();

//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageTemplateForCollection Тогда
//
//		Возврат СформироватьНаСервереВМакетКомпоновкиДанныхДляКоллекции();
//
//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageResultCollectionXML Тогда
//
//		Возврат СформироватьНаСервереВВидеXMLКоллекция();

	EndIf;
EndFunction

// Generate отчет на клиенте.
&AtClient
Procedure СформироватьКлиент()

	Result = СформироватьНаСервере();

	If Result <> Undefined Then

		ShowMessageBox( , Result);

	EndIf;

EndProcedure

// Отобразить панель результатов.
&AtServer
Procedure DisplayResultsPanel()

	Items.ResultsPanel.Visible = True;
	Items.ButtonResultsPanel.Check = Items.ResultsPanel.Visible;

EndProcedure

// Отобразить панель результатов.
&AtServer
Procedure ОтобразитьПанельНастроек()
	ВидимостьНастроек = Not Items.GroupSettingsAndReports.Visible;
	Items.GroupSettingsAndReports.Visible = ВидимостьНастроек;
	Items.Settings.Check = ВидимостьНастроек;

EndProcedure

// Получить схему компоновки данных на основании текста схемы.
//
// Return value:
//  СхемаКомпоновкиДанных - схема, считанная из текста схемы.
&AtServerNoContext
Function GetDataCompositionSchema(ТекстСхемы)

	If ТекстСхемы <> "" Then

		XMLReader = New XMLReader;
		XMLReader.SetString(ТекстСхемы);
		Return XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionSchema"));

	Else

		Return New DataCompositionSchema;

	EndIf;

EndFunction

&AtServer
Function GetDataCompositionSchemaServerCall()
	Return GetDataCompositionSchemaAtServer();
EndFunction

// Получить схему компоновки данных для текущей строки на сервере.
//
// Return value:
//  СхемаКомпоновкиДанных - Схема компоновки данных для текущей строки.
&AtServer
Function GetDataCompositionSchemaAtServer()

	Return GetDataCompositionSchema(ReportsTree.FindByID(
		Items.ReportsTree.CurrentRow).Data);

EndFunction

// Получить схему компоновки данных для текущей строки на клиенте.
//
// Return value:
//  СхемаКомпоновкиДанных - схема компоновка данных для текущей строки.
&AtClient
Function GetDataCompositionSchemaКлиент()

	#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	Return GetDataCompositionSchema(ReportsTree.FindByID(
		Items.ReportsTree.CurrentRow).Data);
	#Else
		Return GetDataCompositionSchemaServerCall();
	#EndIf

EndFunction

// Установить схему компоновки данных для текущей строки.
//
// Parameters:
//  Схема - СхемаКомпоновкиДанных - схема, которую нужно установить текущей строке.
&AtClient
Procedure УстановитьСхемуКомпоновкиДанныхКлиент(Scheme)
	УстановитьСхемуКомпоновкиДанных(Scheme);
EndProcedure

&AtServer
Procedure УстановитьСхемуКомпоновкиДанных(Scheme)
	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, Scheme, "dataCompositionSchema",
		"http://v8.1c.ru/8.1/data-composition-system/schema");

	CurrentRow = Items.ReportsTree.CurrentRow;
	ТекСтрокаДерева = ReportsTree.FindByID(CurrentRow);

	If ТекСтрокаДерева = Undefined Then
		Return;
	EndIf;

	ТекСтрокаДерева.Data = XMLWriter.Close();

	If Not ValueIsFilled(ТекСтрокаДерева.DCSSettings) Then
		XMLWriter = New XMLWriter;
		XMLWriter.SetString();
		XDTOSerializer.WriteXML(XMLWriter, Scheme.DefaultSettings, "Settings",
			"http://v8.1c.ru/8.1/data-composition-system/settings");
		ТекСтрокаДерева.DCSSettings = XMLWriter.Close();
	EndIf;

	// Загрузим Settings в компоновщик настроек.
	LoadCurrentRowAtServer();	
EndProcedure

// Открыть конструктор схемы компоновки данных.
&AtClient
Procedure ОткрытьКонструкторСхемыКомпоновкиДанных()

#If ТолстыйКлиентОбычноеПриложение Or ТолстыйКлиентУправляемоеПриложение Then
	Конструктор = New DataCompositionSchemaWizard(GetDataCompositionSchemaКлиент());
	Конструктор.Edit(ThisForm);
#Else
		ТекДанные=Items.ReportsTree.CurrentData;
		If ТекДанные = Undefined Then
			Return;
		EndIf;

		EditorSettings=New Structure;
		EditorSettings.Insert("СКД", ТекДанные.Data);
		OpenForm("Processing.UT_DCSEditor.Form", EditorSettings, ThisForm, , , ,
			New NotifyDescription("ОткрытьКонструкторСхемыКомпоновкиДанныхЗавершение", ThisObject,
			New Structure("ИдентификаторСтроки", ТекДанные.GetID())), );
//		ShowMessageBox( , НСтр(
//			"ru='Конструктор схемы компоновки данных можно открыть только в толстом клиенте. В тонком клиенте и веб клиенте редактирование схемы компоновки данных возможно только в тексте схемы компоновки данных.'"));
#EndIf

EndProcedure

&AtClient
Procedure ОткрытьКонструкторСхемыКомпоновкиДанныхЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ОткрытьКонструкторСхемыКомпоновкиДанныхЗавершениеНаСервере(AdditionalParameters.ИдентификаторСтроки, Result);
EndProcedure

&AtServer
Procedure ОткрытьКонструкторСхемыКомпоновкиДанныхЗавершениеНаСервере(ИдентификаторСтроки, АдресСКД)
	Scheme=GetFromTempStorage(АдресСКД);

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, Scheme, "dataCompositionSchema",
		"http://v8.1c.ru/8.1/data-composition-system/schema");

	ТекСтрокаДерева = ReportsTree.FindByID(ИдентификаторСтроки);

	If ТекСтрокаДерева = Undefined Then
		Return;
	EndIf;

	ТекСтрокаДерева.Data = XMLWriter.Close();

	If Not ValueIsFilled(ТекСтрокаДерева.DCSSettings) Then
		XMLWriter = New XMLWriter;
		XMLWriter.SetString();
		XDTOSerializer.WriteXML(XMLWriter, Scheme.DefaultSettings, "Settings",
			"http://v8.1c.ru/8.1/data-composition-system/settings");
		ТекСтрокаДерева.DCSSettings = XMLWriter.Close();
	EndIf;

	// Загрузим Settings в компоновщик настроек.
	LoadCurrentRowAtServer();

EndProcedure

// Обновить заголовок формы.
&AtClient
Procedure UpdateTitle()

	Title = InitialTitle + ?(FileName <> "", ": " + FileName, "");

EndProcedure

// Сохранить File с отчетами.
//
// Parameters:
//  Как - булево. Необходимость запроса у пользователя имени файла.
//
// Return value:
//  Истина - сохранение прошло успешно;
//  Ложь - пользователь отменил сохранение.
&AtClient
Procedure Save(Как, NotificationProcessing)
	Var FileChoose;

	BeginAttachingFileSystemExtension(New NotifyDescription("СохранитьЗавершение", ThisForm,
		New Structure("Как, NotificationProcessing", Как, NotificationProcessing)));

EndProcedure

// Завершение процедуры сохранения.
&AtClient
Procedure СохранитьЗавершение(Attached, AdditionalParameters) Export

	Как = AdditionalParameters.Как;
	NotificationProcessing = AdditionalParameters.NotificationProcessing;

	If Attached Then

		If Как Or FileName = "" Then
			File = New File(FileName);
			СохраняемоеИмяФайла = File.Name;

			// Нужно запросить имя файла.
			FileChoose = New FileDialog(FileDialogMode.Save);
			FileChoose.Multiselect = False;
			FileChoose.FullFileName = FileName;
			FileChoose.Directory = File.Path;
			Filter = NStr("ru = 'File консоли системы компоновки данных (*.dcr)|*.dcr|All файлы (*.*)|*.*'");
			FileChoose.Filter = Filter;
			FileChoose.Extension = "dcr";

		Else
			FileChoose = FileName;
		EndIf;

		ПолучаемыеФайлы = New Array;
		ПолучаемыеФайлы.Add(New TransferableFileDescription(СохраняемоеИмяФайла,
			ПоместитьФайлВоВременноеХранилище()));
		BeginGettingFiles(New NotifyDescription("СохранитьЗавершениеПослеПолученияФайлов", ThisForm,
			New Structure("NotificationProcessing", NotificationProcessing)), ПолучаемыеФайлы, FileChoose, False);

	Else

		GetFile(ПоместитьФайлВоВременноеХранилище(), FileName, True);
		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	EndIf;

EndProcedure

// Завершение сохранения после получения файлов.
&AtClient
Procedure СохранитьЗавершениеПослеПолученияФайлов(ПолученныеФайлы, AdditionalParameters) Export

	NotificationProcessing = AdditionalParameters.NotificationProcessing;

	If ПолученныеФайлы = Undefined Then

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, False);

		EndIf;
	Else

		FileName = ПолученныеФайлы[0].Name;
		UpdateTitle();
		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	EndIf;

EndProcedure

// Поместить File во временное хранилище.
&AtServer
Function ПоместитьФайлВоВременноеХранилище()

	TempFileName = GetTempFileName();
	ValueToFile(TempFileName, FormAttributeToValue("ReportsTree"));
	Result = PutToTempStorage(New BinaryData(TempFileName));
	Return Result;

EndFunction

// Если File отчетов был изменен, то запросить пользователя, нужно ли его сохранять.
//
// Return value:
//  Истина - закрытие подтверждено;
//  Ложь - пользователь отменил закрытие.
&AtClient
Procedure ПодтвердитьЗакрытие(NotificationProcessing)

	If SaveCurrentRowDataAtServer() Then

		Modified = True;

	EndIf;

	If Modified Then

		ShowQueryBox(New NotifyDescription("ПодтвердитьЗакрытиеЗавершение", ThisForm,
			New Structure("NotificationProcessing", NotificationProcessing)), NStr(
			"ru='Reports модифицированы. Save изменения?'"), QuestionDialogMode.YesNoCancel, ,
			DialogReturnCode.Yes);

	Else

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	EndIf;

EndProcedure

// Завершение подтверждения закрытия.
&AtClient
Procedure ПодтвердитьЗакрытиеЗавершение(РезультатВопроса, AdditionalParameters) Export

	NotificationProcessing = AdditionalParameters.NotificationProcessing;

	Ответ = РезультатВопроса;

	If Ответ = DialogReturnCode.Yes Then

		Save(False, NotificationProcessing);

	ElsIf Ответ = DialogReturnCode.None Then

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	Else

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, False);

		EndIf;

	EndIf;

EndProcedure

// Получить текущий узел.
//
// Return value:
//  Текущий узел дерева отчетов.
&AtServer
Function ПолучитьТекущийУзел()

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

// Сохранить Settings консоли в хранилище настроек.
&AtServer
Procedure СохранитьНастройкиКонсоли()

	CommonSettingsStorage.Save("НастройкиКонсолиСистемыОтчетности5", , New Structure("FileName,CurrentNode",
		FileName, ПолучитьТекущийУзел()));

EndProcedure

// Выделить базовую часть имени.
//
// Parameters:
//  ПолноеИмя - Строка. Имя, из которого нужно получить базовую часть.
//
// Return value:
//  String - базовая часть имени. Получается путем отбрасывания числа, находящегося
//           в конце полного имени.
&AtServer
Function НайтиБазовуюЧастьИмени(FullName)
// Ищем числа до первого пробела с конца. Обрезаем до этого пробела.
	If StrLen(FullName) < 3 Then

		Return "";

	EndIf;

	Position = StrLen(FullName);
	ЦифрыБыли = False;

	While Position > 1 Do

		ТекущийСимвол = Mid(FullName, Position, 1);

		If ТекущийСимвол >= "0" And ТекущийСимвол <= "9" Then

			ЦифрыБыли = True;

		ElsIf ТекущийСимвол = " " Then

			Break;

		Else

			ЦифрыБыли = False;
			Break;

		EndIf;

		Position = Position - 1;

	EndDo;

	If ЦифрыБыли And Position > 1 Then

		Return Mid(FullName, 1, Position - 1);

	Else

		Return "";

	EndIf;

EndFunction

// Скопировать текущую строку на сервере.
&AtServer
Procedure СкопироватьНаСервере()

	SaveCurrentRowDataAtServer();
	КопируемыйЭлемент = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);
	НовоеИмя = КопируемыйЭлемент.Name;
	NameBasePart = "";

	//	If КопируемыйЭлемент.RowType = 0 Then 
	NameBasePart = НайтиБазовуюЧастьИмени(КопируемыйЭлемент.Name);

	If NameBasePart = "" Then

		NameBasePart = NStr("ru='Report'");

	EndIf;

	НовоеИмя = GenerateNameAtServer(0, NameBasePart, ReportsTree.GetItems(), True);

	//	ElsIf КопируемыйЭлемент.RowType = 1 Then 
	//		
	//		NameBasePart = НайтиБазовуюЧастьИмени(КопируемыйЭлемент.Name);
	//		
	//		If NameBasePart = "" Then
	//			
	//			NameBasePart = NStr("ru='Variant'");
	//			
	//		EndIf;
	//		
	//		НовоеИмя = GenerateNameAtServer(1, NameBasePart, КопируемыйЭлемент.GetParent().GetItems(), False)
	//		
	//	ElsIf КопируемыйЭлемент.RowType = 2 Then
	//		
	//		NameBasePart = НайтиБазовуюЧастьИмени(КопируемыйЭлемент.Name);
	//		
	//		If NameBasePart = "" Then
	//			
	//			NameBasePart = NStr("ru='Setting'");
	//			
	//		EndIf;
	//		
	//		НовоеИмя = GenerateNameAtServer(2, NameBasePart, КопируемыйЭлемент.GetParent().GetItems(), False);
	//		
	//	ElsIf КопируемыйЭлемент.RowType = 3 Then 
	//		
	//		NameBasePart = НайтиБазовуюЧастьИмени(КопируемыйЭлемент.Name);
	//		
	//		If NameBasePart = "" Then
	//			
	//			NameBasePart = NStr("ru='Folder'");
	//			
	//		EndIf;
	//		
	//		НовоеИмя = GenerateNameAtServer(3, NameBasePart, КопируемыйЭлемент.GetParent().GetItems(), False);
	//		
	//	EndIf;
	НовыйЭлемент = КопируемыйЭлемент.GetParent().GetItems().Add();
	FillPropertyValues(НовыйЭлемент, КопируемыйЭлемент);
	НовыйЭлемент.Name = НовоеИмя;
	Items.ReportsTree.CurrentRow = НовыйЭлемент.GetID();
	LoadCurrentRowAtServer();
	CurrentRow = НовыйЭлемент.GetID();

EndProcedure

// Выполнить на сервере отчет на основании текста макета компоновки данных.
&AtServer
Procedure ВыполнитьНаСервереИзМакетаКомпоновкиДанных()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplate);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	OutputDataCompositionTemplateToSpreadsheetDocument(DataCompositionTemplate, Undefined);
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument;

EndProcedure

// Выполнить отчет в коллекцию значений на основании текста макета компоновки данных.
&AtServer
Procedure ВыполнитьНаСервереИзМакетаКомпоновкиДанныхВКоллекцию()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplateForCollection);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageResultCollection;

EndProcedure

// Выполнить отчет в виде XML на основании текста макета компоновки данных.
&AtServer
Procedure ВыполнитьВРезультатНаСервереИзМакетаКомпоновкиДанных()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplate);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, Undefined);
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageDataCompositionResultXML;

EndProcedure

// Выполнить отчет в виде XML в коллекцию значений для макета компоновки данных.
&AtServer
Procedure ВыполнитьВРезультатКоллекцияНаСервереИзМакетаКомпоновкиДанных()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplateForCollection);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageResultCollectionXML;

EndProcedure

// Получить имя файла эталона табличного документа.
//
// Return value:
//  String - имя файла эталона табличного документа.
&AtClient
Function ИмяФайлаЭталонаТабличногоДокумента()

	Var FileName;

	FileName = NStr("ru='Эталон табличного документа.mxl'");

	If FileName = "" Then

		FileName = "Эталон табличного документа.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла табличного документа.
//
// Return value:
//  String - имя файла табличного документа.
&AtClient
Function ИмяФайлаТабличногоДокумента()

	Var FileName;

	FileName = NStr("ru='Табличный документ.xml'");

	If FileName = "" Then

		FileName = "Табличный документ.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла эталона макета.
//
// Return value:
//  String - имя файла эталона макета
&AtClient
Function ИмяФайлаЭталонаМакета()

	Var FileName;

	FileName = NStr("ru='Эталон макета.xml'");

	If FileName = "" Then

		FileName = "Эталон макета.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла макета.
//
// Return value
//  String - имя файла макета.
&AtClient
Function ИмяФайлаМакета()

	Var FileName;

	FileName = NStr("ru='Template.xml'");

	If FileName = "" Then

		FileName = "Template.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя	файла эталона исполняемых настроек.
//
// Return value:
//  String - имя файла эталона исполняемых настроек.
&AtClient
Function ИмяФайлаЭталонаИсполняемыхНастроек()

	Var FileName;

	FileName = NStr("ru='Эталон исполняемых настроек.xml'");

	If FileName = "" Then

		FileName = "Эталон исполняемых настроек.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла исполняемых настроек.
//
// Return value:
//  String - имя файла исполняемых настроек.
&AtClient
Function ИмяФайлаИсполняемыхНастроек()

	Var FileName;

	FileName = NStr("ru='Исполняемые Settings.xml'");

	If FileName = "" Then

		FileName = "Исполняемые Settings.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла эталона результата XML.
// 
// Return value:
//  String - имя файла эталона результата XML.
&AtClient
Function ИмяФайлаЭталонаРезультатаXML()

	Var FileName;

	FileName = NStr("ru='Эталон результата.xml'");

	If FileName = "" Then

		FileName = "Эталон результата.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла результата XML.
//
// Return value:
//  String - имя файла результата XML.
&AtClient
Function ИмяФайлаРезультатаXML()

	Var FileName;

	FileName = NStr("ru='Result.xml'");

	If FileName = "" Then

		FileName = "Result.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла эталона макета для коллекции.
//
// Return value:
//  String - имя файла эталона макета для коллекции.
&AtClient
Function ИмяФайлаЭталонаМакетаДляКоллекции()

	Var FileName;

	FileName = NStr("ru='Эталон макета для коллекции.xml'");

	If FileName = "" Then

		FileName = "Эталон макета для коллекции.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла макета для коллекции.
//
// Return value:
//  String - имя файла макета для коллекции.
&AtClient
Function ИмяФайлаМакетаДляКоллекции()

	Var FileName;

	FileName = NStr("ru='Template для коллекции.xml'");

	If FileName = "" Then

		FileName = "Template для коллекции.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла эталона результата XML для коллекции.
//
// Return value:
//  String - имя файла эталона результата XML для коллекции.
&AtClient
Function ИмяФайлаЭталонаРезультатаXMLДляКоллекции()

	Var FileName;

	FileName = NStr("ru='Эталон результата для коллекции.xml'");

	If FileName = "" Then

		FileName = "Эталон результата для коллекции.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла результата XML для коллекции.
//
// Return value:
//  String - имя файла результата XML для коллекции.
&AtClient
Function ИмяФайлаРезультатаXMLДляКоллекции()

	Var FileName;

	FileName = NStr("ru='Result для коллекции.xml'");

	If FileName = "" Then

		FileName = "Result для коллекции.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Вывести результат из текста результата в табличный документ.
&AtServer
Procedure ВывестиРезультатИзТекстаРезультатаВТабличныйДокумент()

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
			ЭлементРезультата = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionResultItem"));
			ReportResultOutputProcessor.OutputItem(ЭлементРезультата);

		Else

			Break;

		EndIf;

	EndDo;

	ReportResultOutputProcessor.EndOutput();
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument;

EndProcedure

// Вывести результат из текста результата в коллекцию.
&AtServer
Procedure ВывестиРезультатИзТекстаРезультатаВКоллекцию()

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
			ЭлементРезультата = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionResultItem"));
			ReportResultOutputProcessor.OutputItem(ЭлементРезультата);

		Else

			Break;

		EndIf;

	EndDo;

	ВывестиДеревоРезультатВКоллекцию(ReportResultOutputProcessor.EndOutput());
	DisplayResultsPanel();
	Items.ResultsPanel.CurrentPage = Items.PageResultCollection;

EndProcedure

// Загрузить схему компоновки данных из временного хранилища в текущую строку
&AtServer
Procedure ЗагрузитьФайлСхемыКомпоновкиДанныхНаСервере(Address)

	TempFileName = GetTempFileName();
	Data = GetFromTempStorage(Address);
	Data.Write(TempFileName);
	TextReader = New TextReader(TempFileName);
	Modified = True;
	ReportsTree.FindByID(Items.ReportsTree.CurrentRow).Data = TextReader.Read();

EndProcedure

// Загрузить схему компоновки данных из временного хранилища в текущую строку
&AtServer
Function ПоместитьСхемуКомпоновкиДанныхВоВременноеХранилище()

	TempFileName = GetTempFileName();
	TextWriter = New TextWriter(TempFileName);
	TextWriter.Write(ReportsTree.FindByID(Items.ReportsTree.CurrentRow).Data);
	TextWriter.Close();
	Result = PutToTempStorage(New BinaryData(TempFileName));
	Return Result;

EndFunction

&AtServer
Procedure ЗаполнитьСКДДляОтладки(АдресДанныхОтладки)
	ДанныеДляОтладки = GetFromTempStorage(АдресДанныхОтладки);
	ЭлементыДерева = ReportsTree.GetItems();
	ЭлементыДерева.Clear();

	RootItem = ЭлементыДерева.Add();
	RootItem.RowType = 4;
	RootItem.Name = NStr("ru='Reports'");

	ElementsToWhichAdd = RootItem.GetItems();

	Name = "Report для отладки";
	Item = ElementsToWhichAdd.Add();
	Item.Name = Name;
	Item.RowType = 0;

	Item.Data = ДанныеДляОтладки.ТекстСКД;
	Item.DCSSettings = ДанныеДляОтладки.DcsSettingsText;

	If ДанныеДляОтладки.Property("ExternalDataSets") Then
		For Each КлючЗначение ИЗ ДанныеДляОтладки.ExternalDataSets Do
			НС=Item.ExternalDataSets.Add();
			НС.Name=КлючЗначение.Key;
			НС.Value=КлючЗначение.Value;
			ТЗ=ValueFromStringInternal(НС.Value);
			НС.Presentation=StrTemplate("Строк: %1 Колонок: %2", ТЗ.Count(), ТЗ.Cols.Count());
		EndDo;
	EndIf;
	
	FileName = "";

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

// Обработчик события формы OnCreateAtServer.
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	Var ВременныйУзел;

	InitialTitle = Title;
	InitializeReportTree(ReportsTree);
	НастройкиКонсоли = CommonSettingsStorage.Load("НастройкиКонсолиСистемыОтчетности5");

	If НастройкиКонсоли <> Undefined Then

		НастройкиКонсоли.Property("FileName", FileName);
		НастройкиКонсоли.Property("CurrentNode", ВременныйУзел);

		If TypeOf(ВременныйУзел) = Type("ValueList") Then

			CurrentNode = ВременныйУзел;

		EndIf;

	EndIf;

	DetailsFormName = "Report.UT_ReportsConsole.Form.DetailsForm";

	Items.Settings.Check = True;
	Items.ButtonResultsPanel.Check = True;

	If Parameters.Property("ДанныеОтладки") Then
		ЗаполнитьСКДДляОтладки(Parameters.ДанныеОтладки);
		Return;
	EndIf;
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.MainCommandBar);

EndProcedure

// Обработка события Выбор. Вызывается из конструктора схемы компоновки данных.
&AtClient
Procedure ChoiceProcessing(ВыбранноеЗначение, ИсточникВыбора)

	Modified = True;
	УстановитьСхемуКомпоновкиДанныхКлиент(ВыбранноеЗначение);
EndProcedure

// Обработка события ПередЗакрытием.
&AtClient
Procedure BeforeClose(Cancel, StandardProcessing)

	If Modified Then
		Cancel = True;
		ПодтвердитьЗакрытие(New NotifyDescription("ПередЗакрытиемЗавершение", ThisForm));
	EndIf;

EndProcedure

// Завершение обработки закрытия.
&AtClient
Procedure ПередЗакрытиемЗавершение(Result, AdditionalParameters) Export
	If Result Then
		Modified = False;
		Close();
	EndIf;
EndProcedure

// Обработчик события ПриЗакрытии.
&AtClient
Procedure OnClose()

	СохранитьНастройкиКонсоли();

EndProcedure

// Обработчик события OnOpen.
&AtClient
Procedure OnOpen(Cancel)

	If FileName <> "" Then

		DownloadableFileName = FileName;
		FileName = "";
		Try
			DownloadConsoleFile(DownloadableFileName);
		Except
			UT_CommonClientServer.MessageToUser("Error загрузки отчетов из файла");
		EndTry;
	EndIf;

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ КОМАНД

// Обработчик команды AddDataCompositionSchema.
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

				// Folder или корень.
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

// Обработчик команды Generate.
&AtClient
Procedure Generate(Command)

	СформироватьКлиент();

EndProcedure

// Обработчик команды ResultsPanel.
&AtClient
Procedure ResultsPanel(Command)

	Items.ResultsPanel.Visible = Not Items.ResultsPanel.Visible;
	Items.ButtonResultsPanel.Check = Items.ResultsPanel.Visible;

EndProcedure

// Обработчик команды DataCompositionSchemaWizard.
&AtClient
Procedure DataCompositionSchemaWizard(Command)

	ОткрытьКонструкторСхемыКомпоновкиДанных();

EndProcedure

// Обработчик команды SaveReportsToFile.
&AtClient
Procedure SaveReportsToFile(Command)

//	SaveCurrentRowDataAndLoadCurrentRowAtServer();
	SaveCurrentRowDataAtServer();
	Save(False, New NotifyDescription("СохранениеВФайлЗавершение", ThisForm));

EndProcedure

// Обработчик команды SaveReportsToFileAS.
&AtClient
Procedure SaveReportsToFileAS(Command)

	Save(True, New NotifyDescription("СохранениеВФайлЗавершение", ThisForm));

EndProcedure

// Завершение обработчика открытия файла.
&AtClient
Procedure СохранениеВФайлЗавершение(Result, AdditionalParameters) Export

	If Result Then
		Modified = False;
	EndIf;

EndProcedure

// Обработчик команды OpenReportsFile.
&AtClient
Procedure OpenReportsFile(Command)

	ПодтвердитьЗакрытие(New NotifyDescription("ОткрытьФайлОтчетовЗавершение", ThisForm));

EndProcedure

// Завершение обработчика открытия файла.
&AtClient
Procedure ОткрытьФайлОтчетовЗавершение(Result, AdditionalParameters) Export

	If Result Then
		Modified = False;
		DownloadConsoleFile("");
	EndIf;

EndProcedure

// Обработчик команды NewReportsFile.
&AtClient
Procedure NewReportsFile(Command)

	ПодтвердитьЗакрытие(New NotifyDescription("НовыйФайлОтчетовЗавершение", ThisForm));

EndProcedure

// Завершение обработчика создания нового файла отчетов.
&AtClient
Procedure НовыйФайлОтчетовЗавершение(Result, AdditionalParameters) Export

	If Result Then

		Modified = False;
		InitializeReportTree(ReportsTree);
		FileName = "";
		UpdateTitle();
		CurrentRow = Undefined;
		CurrentRowSettingsIsChanged = False;

	EndIf;

EndProcedure

// Обработчик команды OutputToSpreadsheetDocumentForCurrentTemplate.
&AtClient
Procedure OutputToSpreadsheetDocumentForCurrentTemplate(Command)

	ВыполнитьНаСервереИзМакетаКомпоновкиДанных();

EndProcedure

// Обработчик команды SaveStandartSpreadsheetDocument.
&AtClient
Procedure SaveStandartSpreadsheetDocument(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	ResultSpreadsheetDocument.BeginWriting(Undefined, ИмяФайлаЭталонаТабличногоДокумента());
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartSpreadsheetDocument.
&AtClient
Procedure CompareWithStandartSpreadsheetDocument(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	ResultSpreadsheetDocument.BeginWriting(New NotifyDescription("СравнитьСЭталономТабличныйДокументЗавершение",
		ThisForm), ИмяФайлаТабличногоДокумента());
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

&AtClient
Procedure СравнитьСЭталономТабличныйДокументЗавершение(Result, AdditionalParameters) Export
#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаТабличногоДокумента();
	FileCompare.SecondFile = ИмяФайлаТабличногоДокумента();
	FileCompare.CompareMethod = FileCompareMethod.SpreadsheetDocument;
	FileCompare.ShowDifferences();
#Else
	Message(NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));

#EndIf
EndProcedure

// Обработчик команды SaveStandartOfDataCompositionTemplate.
&AtClient
Procedure SaveStandartOfDataCompositionTemplate(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаМакета(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplate);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartDataCompositionTemplate.
&AtClient
Procedure CompareWithStandartDataCompositionTemplate(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаМакета(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplate);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаМакета();
	FileCompare.SecondFile = ИмяФайлаМакета();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды SaveStandartExecutableSettings.
&AtClient
Procedure SaveStandartExecutableSettings(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаИсполняемыхНастроек(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ExecutedSettingsXML);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartExecutableSettings.
&AtClient
Procedure CompareWithStandartExecutableSettings(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаИсполняемыхНастроек(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ExecutedSettingsXML);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаИсполняемыхНастроек();
	FileCompare.SecondFile = ИмяФайлаИсполняемыхНастроек();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды SaveStandartXMLResult.
&AtClient
Procedure SaveStandartXMLResult(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаРезультатаXML(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResult);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartXMLResult.
&AtClient
Procedure CompareWithStandartXMLResult(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаРезультатаXML(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResult);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаРезультатаXML();
	FileCompare.SecondFile = ИмяФайлаРезультатаXML();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды SaveStandartDataCompositionTemplateForTemplate.
&AtClient
Procedure SaveStandartDataCompositionTemplateForTemplate(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаМакетаДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplateForCollection);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartDataCompositionTemplateForCollection.
&AtClient
Procedure CompareWithStandartDataCompositionTemplateForCollection(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаМакетаДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplateForCollection);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаМакетаДляКоллекции();
	FileCompare.SecondFile = ИмяФайлаМакетаДляКоллекции();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды SaveStandartXMLResultForCollection.
&AtClient
Procedure SaveStandartXMLResultForCollection(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаРезультатаXMLДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResultForCollection);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartXMLResultForCollection.
&AtClient
Procedure CompareWithStandartXMLResultForCollection(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаРезультатаXMLДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResultForCollection);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаРезультатаXMLДляКоллекции();
	FileCompare.SecondFile = ИмяФайлаРезультатаXMLДляКоллекции();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды OutputToResultForCurrentTemplate.
&AtClient
Procedure OutputToResultForCurrentTemplate(Command)

	ВыполнитьВРезультатНаСервереИзМакетаКомпоновкиДанных();

EndProcedure

// Обработчик команды OutputResultToSpreadsheetDocument.
&AtClient
Procedure OutputResultToSpreadsheetDocument(Command)

	ВывестиРезультатИзТекстаРезультатаВТабличныйДокумент();

EndProcedure

// Обработчик команды OutputToCollectionForCurrentTemplate.
&AtClient
Procedure OutputToCollectionForCurrentTemplate(Command)

	ВыполнитьНаСервереИзМакетаКомпоновкиДанныхВКоллекцию();

EndProcedure

// Обработчик команды OutputToCollectionResultForCurrentTemplate.
&AtClient
Procedure OutputToCollectionResultForCurrentTemplate(Command)

	ВыполнитьВРезультатКоллекцияНаСервереИзМакетаКомпоновкиДанных();

EndProcedure

// Обработчик команды OutputResultToCollection.
&AtClient
Procedure OutputResultToCollection(Command)

	ВывестиРезультатИзТекстаРезультатаВКоллекцию();

EndProcedure

// Обработчик команды SaveSchemaToFile
&AtClient
Procedure SaveSchemaToFile(Command)

	BeginAttachingFileSystemExtension(New NotifyDescription("СохранитьСхемуВФайлПослеПодключенияРасширения",
		ThisForm));

EndProcedure

// Обработчик сохранения схемы в File после подключения расширения работы с файлами.
&AtClient
Procedure СохранитьСхемуВФайлПослеПодключенияРасширения(Attached, AdditionalParameters) Export

	If Attached Then

	// Нужно запросить имя файла.
		FileChoose = New FileDialog(FileDialogMode.Save);
		FileChoose.Multiselect = False;
		Filter = NStr("ru = 'File схемы компоновки данных (*.xml)|*.xml|All файлы (*.*)|*.*'");
		FileChoose.Filter = Filter;
		FileChoose.Extension = "xml";

		FileChoose.Show(New NotifyDescription("СохранитьСхемуВФайлПослеВыбораФайла", ThisForm,
			New Structure("FileChoose", FileChoose)));

	Else

		GetFile(ПоместитьСхемуКомпоновкиДанныхВоВременноеХранилище(), , True);

	EndIf;

EndProcedure

// Обработчик сохранния схемы в File после выбора файла сохранения.
&AtClient
Procedure СохранитьСхемуВФайлПослеВыбораФайла(SelectedFiles, AdditionalParameters) Export

	FileChoose = AdditionalParameters.FileChoose;

	If SelectedFiles = Undefined Then

		Return;

	EndIf;

	ПолучаемыеФайлы = New Array;
	ПолучаемыеФайлы.Add(New TransferableFileDescription(FileChoose.FullFileName,
		ПоместитьСхемуКомпоновкиДанныхВоВременноеХранилище()));
	BeginGettingFiles(New NotifyDescription("СохранитьСхемуВФайлЗавершение", ThisForm), ПолучаемыеФайлы, "",
		False);

EndProcedure

&AtClient
Procedure СохранитьСхемуВФайлЗавершение(ПолученныеФайлы, AdditionalParameters) Export

	UpdateTitle();

EndProcedure

// Обработчик команды LoadSchemaFromFile
&AtClient
Procedure LoadSchemaFromFile(Command)

	Var Address;

	BeginAttachingFileSystemExtension(
		New NotifyDescription("ЗагрузитьСхемуИзФайлаПослеПодключенияРасширения", ThisForm, New Structure("Address",
		Address)));
EndProcedure

// Обработчик загрузки схемы из файла после подключения расширения.
&AtClient
Procedure ЗагрузитьСхемуИзФайлаПослеПодключенияРасширения(Attached, AdditionalParameters) Export

	Address = AdditionalParameters.Address;

	If Attached Then

		FileChoose = New FileDialog(FileDialogMode.Opening);
		FileChoose.Multiselect = False;
		Filter = NStr("ru = 'File схемы компоновки данных (*.xml)|*.xml|All файлы (*.*)|*.*'");
		FileChoose.Filter = Filter;
		FileChoose.Extension = "xml";

		BeginPuttingFiles(New NotifyDescription("ЗагрузитьСхемуИзФайлаПослеПомещенияФайлов", ThisForm), ,
			FileChoose);

	Else

		BeginPutFile(New NotifyDescription("ЗагрузитьСхемуИзФайлаПослеПомещенияФайла", ThisForm,
			New Structure("Address", Address)), Address, , True);

	EndIf;

EndProcedure

// Обработчик загрузки схемы из файла после помещения файлов.
&AtClient
Procedure ЗагрузитьСхемуИзФайлаПослеПомещенияФайлов(PlacedFiles, AdditionalParameters) Export

	If PlacedFiles = Undefined Then

		Return;

	EndIf;

	For Each PlacedFile In PlacedFiles Do

		If PlacedFile.Location <> "" Then

			Address = PlacedFile.Location;
			Break;

		EndIf;

	EndDo;

	ЗагрузитьФайлСхемыКомпоновкиДанныхНаСервере(Address);

EndProcedure

// Обработчик загрузки схемы из файла после помещения файла.
&AtClient
Procedure ЗагрузитьСхемуИзФайлаПослеПомещенияФайла(Result, Address, SelectedFileName, AdditionalParameters) Export

	Address = AdditionalParameters.Address;

	If Not Result Then

		Return;

	EndIf;

	ЗагрузитьФайлСхемыКомпоновкиДанныхНаСервере(Address);

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ РЕКВИЗИТОВ ФОРМЫ

// Обработчик события ПриАктивизацииПоля таблицы Structure.
// Активизирует страницу настроек в зависимости от того, какую колонку
// активировал пользователь.
&AtClient
Procedure StructureOnActivateField(Item)
	
	Var ВыбраннаяСтраница;

	If Items.Structure.CurrentItem.Name = "СтруктураНаличиеВыбора" Then

		ВыбраннаяСтраница = Items.PageSelectedFields;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеОтбора" Then

		ВыбраннаяСтраница = Items.PageFilter;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеПорядка" Then

		ВыбраннаяСтраница = Items.OrderPage;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеУсловногоОформления" Then

		ВыбраннаяСтраница = Items.ConditionalAppearancePage;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеПараметровВывода" Then

		ВыбраннаяСтраница = Items.OutputParametersPage;

	EndIf;

	If ВыбраннаяСтраница <> Undefined Then

		Items.SettingsPages.CurrentPage = ВыбраннаяСтраница;

	EndIf;
EndProcedure


// Обработчик события ПриАктивизацииПоля таблицы Structure1.
// Активизирует страницу настроек в зависимости от того, какую колонку
// активировал пользователь.
&AtClient
Procedure Settings1OnActivateField(Item)
	Var ВыбраннаяСтраница;

	If Items.Settings1.CurrentItem.Name = "Structure1НаличиеВыбора" Then

		ВыбраннаяСтраница = Items.СтраницаПолейВыбора1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1НаличиеОтбора" Then

		ВыбраннаяСтраница = Items.FilterPage1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1НаличиеПорядка" Then

		ВыбраннаяСтраница = Items.OrderPage1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1НаличиеУсловногоОформления" Then

		ВыбраннаяСтраница = Items.ConditionalAppearancePage1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1НаличиеПараметровВывода" Then

		ВыбраннаяСтраница = Items.OutputParametersPage1;

	EndIf;

	If ВыбраннаяСтраница <> Undefined Then

		Items.PagesSettings1.CurrentPage = ВыбраннаяСтраница;

	EndIf;
EndProcedure

// Обработчик СтруктураПриАктивизацииСтроки элемента Structure.
// Приводит закладки с настройками в актуальное состояние
&AtClient
Procedure StructureOnActivateRow(Item)
	
	ТекСтрокаДерева = Items.Structure.CurrentRow;
	If ТекСтрокаДерева = Undefined Then
		Return;
	EndIf;

	SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(ТекСтрокаДерева);
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


// Обработчик СтруктураПриАктивизацииСтроки элемента Structure1.
// Приводит закладки с настройками в актуальное состояние
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

// Обработчик события Нажатие декораций.
&AtClient
Procedure GoToReport(Item)

	SettingsItem = Report.SettingsComposer.Settings.GetObjectByID(
		Items.Structure.CurrentRow);
	ItemSettings = Report.SettingsComposer.Settings.ItemSettings(SettingsItem);
	Items.Structure.CurrentRow = Report.SettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

// Обработчик события Нажатие декораций for executable settings.
&AtClient
Procedure GoToReport1(Item)

	SettingsItem = ExecutedSettingsComposer.Settings.GetObjectByID(
		Items.Settings1.CurrentRow);
	ItemSettings = ExecutedSettingsComposer.Settings.ItemSettings(SettingsItem);
	Items.Settings1.CurrentRow = ExecutedSettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

// Обработчик события ПриИзменении флажка LocalSelectedFields.
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

// Обработчик события ПриИзменении флажка LocalSelectedFields1.
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

// Обработчик события ПриИзменении флажка LocalFilter.
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

// Обработчик события ПриИзменении флажка LocalFilter1.
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

// Обработчик события ПриИзменении флажка LocalOrder.
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

// Обработчик события ПриИзменении флажка LocalOrder1.
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

// Обработчик события ПриИзменении флажка LocalConditionalAppearance.
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

// Обработчик события ПриИзменении флажка LocalConditionalAppearance1.
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

// Обработчик события ПриИзменении флажка LocalOutputParameters.
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

// Обработчик события ПриИзменении флажка LocalOutputParameters1.
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

// Обработчик события ПриАктивизацииСтроки элемента ReportsTree.
// Отображает соответствующую закладку - схему, вариант, пользовательские Settings и т.п.
&AtClient
Procedure ReportsTreeOnActivateRow(Item)
	
	If Not RowIsBeingActivated And CurrentRow <> Item.CurrentRow Then

		RowIsBeingActivated = True;

		If Item.CurrentRow <> Undefined Then

			TreeItem = ReportsTree.FindByID(Item.CurrentRow);

			If TreeItem.RowType = 0 Then
			// Scheme компоновки данных.
				If Items.GroupSettings.CurrentPage <> Items.GroupVariant Then

					Items.GroupSettings.CurrentPage = Items.GroupVariant;

				EndIf;
				//				
				//			ElsIf TreeItem.RowType = 1 Then
				//				// Variant отчета.
				//				If Items.GroupSettings.CurrentPage <> Items.GroupVariant Then
				//					
				//					Items.GroupSettings.CurrentPage = Items.GroupVariant;
				//					
				//				EndIf;
				//				
				//			ElsIf TreeItem.RowType = 2 Then
				//				// Пользовательские Settings.
				//				If Items.GroupSettings.CurrentPage <> Items.GroupUserSettings Then
				//					
				//					Items.GroupSettings.CurrentPage = Items.GroupUserSettings;
				//					
				//				EndIf;
				//				
				//			Else
				// Неизвестный тип.
				//				If Items.GroupSettings.CurrentPage <> Items.ГруппаПустая Then
				//					
				//					Items.GroupSettings.CurrentPage = Items.ГруппаПустая;
				//					
				//				EndIf;
			EndIf;

		EndIf;

		Try

			SaveCurrentRowDataAndLoadCurrentRowAtServer();
			CurrentRow = Item.CurrentRow;
			RowIsBeingActivated = False;

		Except

			CurrentRow = Undefined; // For того, чтобы не испортить Settings в дереве.
			RowIsBeingActivated = False;

		EndTry;

	EndIf;
EndProcedure

&AtClient
Procedure Settings(Command)
	ОтобразитьПанельНастроек();
EndProcedure

// Обработчик события ПриИзменении элементов, связанных с настройками.
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


// Обработчик события ПередНачаломДобавления элемента ReportsTree.
&AtClient
Procedure ReportsTreeBeforeAddRow(Item, Cancel, Clone, Parent, IsFolder, Parameter)
	
		If Clone Then

		Cancel = True;

		If ReportsTree.FindByID(Item.CurrentRow).RowType <> 4 Then
		// Not корень.
			СкопироватьНаСервере();

		EndIf;

	EndIf;
EndProcedure

// Обработчик события ПередУдалением элемента ReportsTree.
&AtClient
Procedure ДеревоОтчетовПередУдалением(Item, Cancel)

	CurrentRow = Undefined;

EndProcedure


&AtClient
Procedure ReportsTreeBeforeDeleteRow(Item, Cancel)
	CurrentRow = Undefined;
EndProcedure

// Обработчик события Выбор элемента ReportsTree.
&AtClient
Procedure ReportsTreeSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;
	СформироватьКлиент();
EndProcedure


// Обработчик события ОбработкаДополнительнойРасшифровки табличного документа ResultSpreadsheetDocument.
&AtClient
Procedure ResultSpreadsheetDocumentAdditionalDetailProcessing(Item, Details, StandardProcessing, AdditionalParameters)
	StandardProcessing = False;
	DetailProcessing = New DataCompositionDetailsProcess(DetailsDataURL,
		New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
	DetailProcessing.ShowActionChoice(
		New NotifyDescription("РезультатТабличныйДокументОбработкаРасшифровкиЗавершение", ThisForm,
		New Structure("Details", Details)), Details, , , , Items.ResultSpreadsheetDocument);
EndProcedure

// Обработчик события ОбработкаРасшифровки табличного документа ResultSpreadsheetDocument.
&AtClient
Procedure ResultSpreadsheetDocumentDetailProcessing(Item, Details, StandardProcessing, AdditionalParameters)
		StandardProcessing = False;
	DetailProcessing = New DataCompositionDetailsProcess(DetailsDataURL,
		New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
	DetailProcessing.ShowActionChoice(
		New NotifyDescription("РезультатТабличныйДокументОбработкаРасшифровкиЗавершение", ThisForm,
		New Structure("Details", Details)), Details, , , True, );
EndProcedure

// Отработка выбора действия расшифровки.
&AtClient
Procedure РезультатТабличныйДокументОбработкаРасшифровкиЗавершение(ВыполненноеДействие, ПараметрВыполненногоДействия,
	AdditionalParameters) Export

	Details = AdditionalParameters.Details;

	If ВыполненноеДействие = DataCompositionDetailsProcessingAction.None Then

	ElsIf ВыполненноеДействие = DataCompositionDetailsProcessingAction.OpenValue Then

		ShowValue( , ПараметрВыполненногоДействия);

	ElsIf ВыполненноеДействие <> Undefined Then

		OpenForm(DetailsFormName, New Structure("Details,DataCompositionSchemaURL",
			New DataCompositionDetailsProcessDescription(DetailsDataURL, Details,
			ПараметрВыполненногоДействия), ExecutedReportSchemaURL), , True);

	EndIf;

EndProcedure

// Обработчик события ПриСменеСтраницы панели ResultsPanel.
&AtClient
Procedure ResultsPanelOnCurrentPageChange(Item, CurrentPage)
    If Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument Then

		If ReportNeedsToGenerate And Not ResultFilledSpreadsheetDocument Then

			Result = СформироватьНаСервереВТабличныйДокумент();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageDataCompositionTemplate Then

		If ReportNeedsToGenerate And Not ResultFilledTemplate Then

			Result = СформироватьНаСервереВМакетКомпоновкиДанных();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageExecutedSettings Then

		If ReportNeedsToGenerate And Not ResultFilledSettings Then

			Result = СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанных();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageExecutedSettingsXML Then

		If ReportNeedsToGenerate And Not ResultFilledSettingsXML Then

			Result = СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанныхXML();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageDataCompositionResultXML Then

		If ReportNeedsToGenerate And Not ResultFilledXML Then

			Result = СформироватьНаСервереВВидеXML();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageResultCollection Then

		If ReportNeedsToGenerate And Not ResultFilledCollection Then

			Result = СформироватьНаСервереВКоллекцию();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageTemplateForCollection Then

		If ReportNeedsToGenerate And Not ResultFilledTemplateForCollection Then

			Result = СформироватьНаСервереВМакетКомпоновкиДанныхДляКоллекции();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageResultCollectionXML Then

		If ReportNeedsToGenerate And Not ResultFilledCollectionXML Then

			Result = СформироватьНаСервереВВидеXMLКоллекция();

		EndIf;

	EndIf;

	If Result <> Undefined Then

		ShowMessageBox( , Result);

	EndIf;
EndProcedure

// Обработчик события Выбор таблицы TreeResult.
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
	ТекДанные=Items.ExternalDataSets.CurrentData;
	If ТекДанные=Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditValueTable(ТекДанные.Value, ThisObject,
		New NotifyDescription("ВнешниеНаборыДанныхПредставлениеНачалоВыбораЗавершение", ThisObject,New Structure("ТекСтрока",Items.ExternalDataSets.CurrentRow)));
EndProcedure

&AtClient
Procedure ВнешниеНаборыДанныхПредставлениеНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result=Undefined Then
		Return;
	EndIf;
	ТекСтрокаДерева=ReportsTree.FindByID(CurrentRow);
	If ТекСтрокаДерева=Undefined Then
		Return;
	EndIf;
	ТекДанныеСтроки=ТекСтрокаДерева.ExternalDataSets.FindByID(AdditionalParameters.ТекСтрока);
	ТекДанныеСтроки.Value=Result.Value;
	ТекДанныеСтроки.Presentation=Result.Presentation;
EndProcedure

&AtClient
Procedure ExternalDataSetsBeforeEditEnd(Item, NewRow, CancelEdit, Cancel)
	If CancelEdit Then
		Return;
	EndIf;	
		
	ТекДанные=Items.ExternalDataSets.CurrentData;
	If ТекДанные=Undefined Then
		Return;
	EndIf;
	ТекДанные.Name=TrimAll(ТекДанные.Name);
	
	If Not UT_CommonClientServer.IsCorrectVariableName(ТекДанные.Name) Then
		ShowMessageBox( ,
			UT_CommonClientServer.WrongVariableNameWarningText(),
			, Title);
		Cancel = True;
		Return;
	EndIf;
	
	ТекСтрокаДерева=ReportsTree.FindByID(CurrentRow);
	If ТекСтрокаДерева=Undefined Then
		Return;
	EndIf;

	
	маСтрокиИмени = ТекСтрокаДерева.ExternalDataSets.FindRows(New Structure("Name", ТекДанные.Name));
	If маСтрокиИмени.Count() > 1 Then
		ShowMessageBox( , "Column с таким именем уже есть! Введите другое имя.", , Title);
		Cancel = True;
		Return;
	EndIf;
EndProcedure

&AtServer
Function ExternalDataSetsStructure()
	ВнешниеНаборы=New Structure;
	
	ТекСтрокаДерева=ReportsTree.FindByID(CurrentRow);
	If ТекСтрокаДерева=Undefined Then
		Return ВнешниеНаборы;
	EndIf;
		
	For Each Set ИЗ ТекСтрокаДерева.ExternalDataSets Do
		If ValueIsFilled(Set.Value) Then
			Try
				ТЗ=ValueFromStringInternal(Set.Value);
			Except
				ТЗ=New ValueTable;
			EndTry;
		Else
			ТЗ=New ValueTable;
		EndIf;
		ВнешниеНаборы.Insert(Set.Name, ТЗ);
	EndDo;
	Return ВнешниеНаборы;
EndFunction

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

////////////////////////////////////////////////////////////////////////////////