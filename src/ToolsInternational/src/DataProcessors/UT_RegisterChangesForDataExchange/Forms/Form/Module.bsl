&AtClient
Var MetadataCurrentRow;

////////////////////////////////////////////////////////////////////////////////////////////////////
// FORM EVENT HANDLERS
//

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	VerifyAccessRights("Administration", Metadata);

	If Parameters.Property("AutoTests") Then // Return when a form is received for analysis.
		Return;
	EndIf;

	RegistrationTableParameter = Undefined;
	RegistrationObjectParameter  = Undefined;
	
//	OpenWithNodeParameter = False;
	CurrentObject = ThisObject();
	
	// Analyzing form parameters.
	If Parameters.CommandID = Undefined Then
		// Starting the data processor in standalone mode.
		ExchangeNodeRef = Parameters.УзелОбмена;
		Parameters.Property("SelectExchangeNodeProhibited", SelectExchangeNodeProhibited);
//		OpenWithNodeParameter = True;

	ElsIf Parameters.CommandID = "OpenRegistrationEditingForm" Then
		If TypeOf(Parameters.RelatedObjects) = Type("Array") And Parameters.RelatedObjects.Count() > 0 Then
			// The form is opened with the specified object.
			RelatedObject = Parameters.RelatedObjects[0];
			Type = TypeOf(RelatedObject);
			If ExchangePlans.AllRefsType().ContainsType(Type) Then
				ExchangeNodeRef = RelatedObject;
//				OpenWithNodeParameter = True;
			Else
				// Filling internal attributes.
				Details = CurrentObject.MetadataCharacteristics(RelatedObject.Metadata());
				If Details.IsReference Then
					RegistrationObjectParameter = RelatedObject;
				ElsIf Details.IsSet Then
					// Structure and table name
					RegistrationTableParameter = Details.TableName;
					RegistrationObjectParameter  = New Structure;
					For Each Dimension In CurrentObject.RecordSetDimensions(RegistrationTableParameter) Do
						CurName = Dimension.Name;
						RegistrationObjectParameter.Insert(CurName, RelatedObject.Filter[CurName].Value);
					EndDo;
				EndIf;
			EndIf;

		Else
			Raise StrReplace(
				NStr("ru='Неверные параметры команды открытия ""%1""'; en = 'Incorrect parameters for the %1 command'"), "%1", Parameters.CommandID);

		EndIf;

	Else
		Raise StrReplace(
			NStr("ru='Undefined command ""%1""'"), "%1", Parameters.CommandID);
	КонецЕсли;
	
	// Initializing object settings.
	CurrentObject.ReadSettings();
	CurrentObject.ReadSSLSupportFlags();
	ThisObject(CurrentObject);
	
	// Initializing other parameters only if this form will be opened.
	If RegistrationObjectParameter <> Undefined Then
		Return;
	EndIf;
	
	// Filling the list of prohibited metadata objects based on form parameters.
	Parameters.Property("NamesOfMetadataToHide", NamesOfMetadataToHide);
	
	//@skip-warning
	MetadataCurrentRow = Undefined;
	Items.ObjectsListOptions.CurrentPage = Items.BlankPage;
	Parameters.Property("SelectExchangeNodeProhibited", SelectExchangeNodeProhibited);

	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing,
		Items.CommonCommandBar);

EndProcedure

&AtClient
Procedure OnOpen(Cancel)

	If RegistrationObjectParameter <> Undefined Then
		// Opening another form
		Cancel = True;
		OpenForm(
			GetFormName() + "Form.ObjectRegistrationNodes",
			New Structure("RegistrationObject, RegistrationTable", RegistrationObjectParameter,
			RegistrationTableParameter));
	EndIf;

EndProcedure

&AtClient
Procedure OnClose(Exit)
	// Auto saving settings
	SavedInSettingsDataModified = Истина;
EndProcedure

&AtClient
Procedure ChoiceProcessing(SelectedValue, ChoiceSource)
	
	// Analyzing selected value, it must be a structure.
	If TypeOf(SelectedValue) <> Type("Structure") Or (Not SelectedValue.Property("ChoiceAction"))
		Or (Not SelectedValue.Property("ChoiceData")) Or TypeOf(SelectedValue.ChoiceAction) <> Type("Boolean")
		Or TypeOf(SelectedValue.ChoiceData) <> Type("String") Then
		Error = NStr("ru = 'Неожиданный результат выбора из консоли запросов'; en = 'Unexpected selection result received from the query console.'");
	Else
		Error = RefControlForQuerySelection(SelectedValue.ChoiceData);
	EndIf;

	If Error <> "" Then 
		ShowMessageBox(,Error);
		Return;
	EndIf;

	If SelectedValue.ChoiceAction Then
		Text = NStr("ru = 'Зарегистрировать результат запроса
		                 |на узле ""%1""?'; 
		                 |en = 'Do you want to register the query result
		                 |at node ""%1""?'"); 
	Else
		Text = NStr("ru = 'Отменить регистрацию результата запроса
		                 |на узле ""%1""?'; 
		                 |en = 'Do you want to cancel registration of the query result
		                 |at node ""%1""?'");
	EndIf;
	Text = StrReplace(Text, "%1", String(ExchangeNodeRef));
					 
	QuestionTitle = NStr("ru = 'Подтверждение'; en = 'Confirm operation'");
	
	Notification = New NotifyDescription("ChoiceProcessingCompletion", ThisObject, New Structure);
	Notification.AdditionalParameters.Insert("SelectedValue", SelectedValue);
	ShowQueryBox(Notification, Text, QuestionDialogMode.YesNo, , , QuestionTitle);

EndProcedure

Procedure NotificationProcessing(EventName, Parameter, Source)
	
	If EventName = "ObjectDataExchangeRegistrationEdit" Then
		FillRegistrationCountInTreeRows();
		UpdatePageContent();
	ElsIf EventName = "ExchangeNodeDataEdit" And ExchangeNodeRef = Parameter Then
		SetMessageNumberTitle();		
	EndIf;
	
EndProcedure

&AtServer
Procedure OnSaveDataInSettingsAtServer(Settings)
	// Automatic settings
	CurrentObject = ThisObject();
	CurrentObject.SaveSettings();
	ThisObject(CurrentObject);
EndProcedure

&AtServer
Procedure OnLoadDataFromSettingsAtServer(Settings)
	
	If RegistrationObjectParameter <> Undefined Then
		// Another form will be used.
		Return;
	EndIf;
	
	If ValueIsFilled(Parameters.ExchangeNode) Then
		ExchangeNodeRef = Parameters.ExchangeNode;
	Else
		ExchangeNodeRef = Settings["ExchangeNodeRef"];
		/// If restored exchange node is deleted, clearing the ExchangeNodeRef value.
		//@skip-warning
		If ExchangeNodeRef <> Undefined And ExchangePlans.AllRefsType().ContainsType(TypeOf(ExchangeNodeRef))
		    And IsBlankString(ExchangeNodeRef.DataVersion) Then
			ExchangeNodeRef = Undefined;
		EndIf;
	EndIf;
	
	ControlSettings();
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// FORM HEADER ITEMS EVENT HANDLERS
//

&AtClient
Procedure ExchangeNodeRefStartChoice(Item, ChoiceData, StandardProcessing)
	StandardProcessing = False;
	CurFormName = GetFormName() + "Form.SelectExchangePlanNode";
	CurParameters = New Structure("MultipleChoice, ChoiceInitialValue", False, ExchangeNodeRef);
	OpenForm(CurFormName, CurParameters, Item);
EndProcedure

&AtClient
Procedure ExchangeNodeRefChoiceProcessing(Item, ValueSelected, StandardProcessing)
	If ExchangeNodeRef <> ValueSelected Then
		ExchangeNodeRef = ValueSelected;
		ExchangeNodeChoiceProcessing();
	EndIf;
EndProcedure

&AtClient
Procedure ExchangeNodeRefOnChange(Item)
	ExchangeNodeChoiceProcessing();
	ExpandMetadataTree();
	UpdatePageContent();
EndProcedure

&AtClient
Procedure ExchangeNodeRefClear(Item, StandardProcessing)
	StandardProcessing = False;
EndProcedure

&AtClient
Procedure FilterByMessageNumberOptionOnChange(Item)
	SetFilterByMessageNumber(ConstantsList, FilterByMessageNumberOption);
	SetFilterByMessageNumber(RefsList, FilterByMessageNumberOption);
	SetFilterByMessageNumber(RecordSetsList, FilterByMessageNumberOption);
	UpdatePageContent();
EndProcedure

&AtClient
Procedure ObjectsListOptionsOnCurrentPageChange(Item, CurrentPage)
	UpdatePageContent(CurrentPage);
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// MetadataTree FORM TABLE ITEMS EVENT HANDLERS
//

&AtClient
Procedure MetadataTreeCheckOnChange(Item)
	ChangeMark(Items.MetadataTree.CurrentRow);
EndProcedure

&AtClient
Procedure MetadataTreeOnActivateRow(Item)
	If Items.MetadataTree.CurrentRow <> MetadataCurrentRow Then
		MetadataCurrentRow  = Items.MetadataTree.CurrentRow;
		AttachIdleHandler("SetUpChangeEditing", 0.0000001, True);
	EndIf;
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// ConstantsList FORM TABLE ITEMS EVENT HANDLERS
//

&AtClient
Procedure ConstantListChoiceProcessing(Item, ValueSelected, StandardProcessing)
	
	Result = AddRegistrationAtServer(True, ExchangeNodeRef, ValueSelected);
	Items.ConstantsList.Refresh();
	FillRegistrationCountInTreeRows();
	ReportRegistrationResults(True, Result);

	If TypeOf(ValueSelected) = Type("Array") And ValueSelected.Count() > 0 Then
		Item.CurrentRow = ValueSelected[0];
	Else
		Item.CurrentRow = ValueSelected;
	EndIf;

EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// RefsList FORM TABLE ITEMS EVENT HANDLERS
//

&AtClient
Procedure ReferenceListChoiceProcessing(Item, ValueSelected, StandardProcessing)
	DataChoiceProcessing(Item, ValueSelected);
EndProcedure
&AtClient
Procedure EditReference(Command)
	CurData=Items.RefsList.CurrentData;
	If CurData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(CurData.Ref);
EndProcedure


////////////////////////////////////////////////////////////////////////////////////////////////////
// RecordSetsList FORM TABLE ITEMS EVENT HANDLERS
//

&AtClient
Procedure RecordSetListSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;
	
	WriteParameters = RecordSetKeyStructure(Item.CurrentData);
	If WriteParameters <> Undefined Then
		OpenForm(WriteParameters.FormName, New Structure("Key", WriteParameters.Key));
	EndIf;

EndProcedure

&AtClient
Procedure RecordSetListChoiceProcessing(Item, ValueSelected, StandardProcessing)
	DataChoiceProcessing(Item, ValueSelected);
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// FORM COMMAND HANDLERS
//

&AtClient
Procedure AddRegistrationForSingleObject(Command)
	
	If Not ValueIsFilled(ExchangeNodeRef) Then
		Return;
	EndIf;
	
	CurrPage = Items.ObjectsListOptions.CurrentPage;
	If CurrPage = Items.ConstantsPage Then
		AddConstantRegistrationToList();
	ElsIf CurrPage = Items.ReferencesListPage Then
		AddRegistrationToReferenceList();		
	ElsIf CurrPage = Items.RecordSetPage Then
		AddRegistrationToRecordSetFilter();
	EndIf;
	
EndProcedure

&AtClient
Procedure DeleteRegistrationForSingleObject(Command)
	
	If Not ValueIsFilled(ExchangeNodeRef) Then
		Return;
	EndIf;
	
	CurrPage = Items.ObjectsListOptions.CurrentPage;
	If CurrPage = Items.ConstantsPage Then
		DeleteConstantRegistrationInList();
	ElsIf CurrPage = Items.ReferencesListPage Then
		DeleteRegistrationFromReferenceList();
	ElsIf CurrPage = Items.RecordSetPage Then
		DeleteRegistrationInRecordSet();
	EndIf;
	
EndProcedure

&AtClient
Procedure AddRegistrationFilter(Command)
	
	If Not ValueIsFilled(ExchangeNodeRef) Then
		Return;
	EndIf;
	
	CurrPage = Items.ObjectsListOptions.CurrentPage;
	If CurrPage = Items.ReferencesListPage Then
		AddRegistrationInListFilter();
	ElsIf CurrPage = Items.RecordSetPage Then
		AddRegistrationToRecordSetFilter();
	EndIf;
	
EndProcedure

&AtClient
Procedure DeleteRegistrationFilter(Command)
	
	If Not ValueIsFilled(ExchangeNodeRef) Then
		Return;
	EndIf;
	
	CurrPage = Items.ObjectsListOptions.CurrentPage;
	If CurrPage = Items.ReferencesListPage Then
		DeleteRegistrationFromListFilter();
	ElsIf CurrPage = Items.RecordSetPage Then
		DeleteRegistrationInRecordSetFilter();
	EndIf;
	
EndProcedure

&AtClient
Procedure OpenNodeRegistrationForm(Command)
	
	If SelectExchangeNodeProhibited Then
		Return;
	EndIf;
		
	Data = GetCurrentObjectToEdit();
	If Data <> Undefined Then
		RegistrationTable = ?(TypeOf(Data) = Type("Structure"), RecordSetsListTableName, "");
		OpenForm(GetFormName() + "Form.ObjectRegistrationNodes",
			New Structure("RegistrationObject, RegistrationTable, NotifyAboutChanges", Data, RegistrationTable, 
			True), ThisObject);
	EndIf;
	
EndProcedure

&AtClient
Procedure ShowExportResult(Command)
	
	CurPage = Items.ObjectsListOptions.CurrentPage;
	Serialization = New Array;
	
	If CurPage = Items.ConstantsPage Then 
		FormItem = Items.ConstantsList;
		For Each Row In FormItem.SelectedRows Do
			curData = FormItem.RowData(Row);
			Serialization.Add(New Structure("TypeFlag, Data", 1, curData.MetaFullName));
		EndDo;
		
	ElsIf CurPage = Items.RecordSetPage Then
		DimensionList = RecordSetKeyNameArray(RecordSetsListTableName);
		FormItem = Items.RecordSetsList;
		Prefix = "RecordSetsList";
		For Each Item In FormItem.SelectedRows Do
			curData = New Structure();
			Data = FormItem.RowData(Item);
			For Each Name In DimensionList Do
				curData.Insert(Name, Data[Prefix + Name]);
			EndDo;
			Serialization.Add(New Structure("TypeFlag, Data", 2, curData));
		EndDo;
		
	ElsIf CurPage = Items.ReferencesListPage Then
		FormItem = Items.RefsList;
		For Each Item In FormItem.SelectedRows Do
			curData = FormItem.RowData(Item);
			Serialization.Add(New Structure("TypeFlag, Data", 3, curData.Ref));
		EndDo;
		
	Else
		Return;
		
	EndIf;
	
	If Serialization.Count() > 0 Then
		Text = SerializationText(Serialization);
		TextTitle = NStr("ru = 'Результат стандартной выгрузки (РИБ)'; en = 'Standard export result (DIB)'");
		Text.Show(TextTitle);
	EndIf;
	
EndProcedure

&AtClient
Procedure EditMessagesNumbers(Command)
	
	If ValueIsFilled(ExchangeNodeRef) Then
		CurFormName = GetFormName() + "Form.ExchangePlanNodeMessageNumbers";
		CurParameters = New Structure("ExchangeNodeRef", ExchangeNodeRef);
		OpenForm(CurFormName, CurParameters);
	EndIf;
EndProcedure

&AtClient
Procedure AddConstantRegistration(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		AddConstantRegistrationToList();
	EndIf;
EndProcedure

&AtClient
Procedure DeleteConstantRegistration(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		DeleteConstantRegistrationInList();
	EndIf;
EndProcedure

&AtClient
Procedure AddRefRegistration(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		AddRegistrationToReferenceList();
	EndIf;
EndProcedure

&AtClient
Procedure AddObjectDeletionRegistration(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		AddObjectDeletionRegistrationInReferenceList();
	EndIf;
EndProcedure

&AtClient
Procedure DeleteRefRegistration(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		DeleteRegistrationFromReferenceList();
	EndIf;
EndProcedure

&AtClient
Procedure AddRefRegistrationPickup(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		AddRegistrationToReferenceList(True);
	EndIf;
EndProcedure

&AtClient
Procedure AddRefRegistrationFilter(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		AddRegistrationInListFilter();
	EndIf;
EndProcedure

&AtClient
Procedure DeleteRefRegistrationFilter(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		DeleteRegistrationFromListFilter();
	EndIf;
EndProcedure

&AtClient
Procedure AddRegistrationForAutoObjects(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		AddSelectedObjectRegistration(False);
	EndIf;
EndProcedure

&AtClient
Procedure DeleteRegistrationForAutoObjects(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		DeleteSelectedObjectRegistration(False);
	EndIf;
EndProcedure

&AtClient
Procedure AddRegistrationForAllObjects(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		AddSelectedObjectRegistration();
	EndIf;
EndProcedure

&AtClient
Procedure DeleteRegistrationForAllObjects(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		DeleteSelectedObjectRegistration();
	EndIf;
EndProcedure

&AtClient
Procedure AddRecordSetRegistrationFilter(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		AddRegistrationToRecordSetFilter();
	EndIf;
EndProcedure

&AtClient
Procedure DeleteRecordSetRegistration(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		DeleteRegistrationInRecordSet();
	EndIf;
EndProcedure

&AtClient
Procedure DeleteRecordSetRegistrationFilter(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		DeleteRegistrationInRecordSetFilter();
	EndIf;
EndProcedure

&AtClient
Procedure RefreshAllData(Command)
	FillRegistrationCountInTreeRows();
	UpdatePageContent();
EndProcedure

&AtClient
Procedure AddQueryResultRegistration(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		ActionWithQueryResult(True);
	EndIf;
EndProcedure

&AtClient
Procedure DeleteQueryResultRegistration(Command)
	If ValueIsFilled(ExchangeNodeRef) Then
		ActionWithQueryResult(False);
	EndIf;
EndProcedure

&AtClient
Procedure OpenSettingsForm(Command)
	OpenDataProcessorSettingsForm();
EndProcedure

&AtClient
Procedure EditObjectMessageNumber(Command)
	
	If Items.ObjectsListOptions.CurrentPage = Items.ConstantsPage Then
		EditConstantMessageNo();
		
	ElsIf Items.ObjectsListOptions.CurrentPage = Items.ReferencesListPage Then
		EditRefMessageNo();
		
	ElsIf Items.ObjectsListOptions.CurrentPage = Items.RecordSetPage Then
		EditMessageNoSetList()
		
	EndIf;
	
EndProcedure

//@skip-warning
&AtClient

Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure


////////////////////////////////////////////////////////////////////////////////////////////////////
// PRIVATE
//

&AtClient
Procedure ChoiceProcessingCompletion(Val QuestionResult, Val AdditionalParameters) Export
	If QuestionResult <> DialogReturnCode.Yes Then
		Return
	EndIf;
	SelectedValue = AdditionalParameters.SelectedValue;

	ReportRegistrationResults(SelectedValue.ChoiceAction, ChangeQueryResultRegistrationServer(
		SelectedValue.ChoiceAction, SelectedValue.ChoiceData));

	FillRegistrationCountInTreeRows();
	UpdatePageContent();
EndProcedure

&AtClient
Procedure EditConstantMessageNo()
	curData = Items.ConstantsList.CurrentData;
	If curData = Undefined Then
		Return;
	EndIf;
	
	Notification = New NotifyDescription("EditConstantMessageNoCompletion", ThisObject, New Structure);
	Notification.AdditionalParameters.Insert("MetaFullName", curData.MetaFullName);
	
	MessageNumber = curData.MessageNo;
	Tooltip = NStr("ru = 'Номер отправленного'; en = 'Number of the last sent message'"); 
	
	ShowInputNumber(Notification, MessageNumber, Tooltip);
EndProcedure

&AtClient
Procedure EditConstantMessageNoCompletion(Val MessageNumber, Val AdditionalParameters) Export
	If MessageNumber = Undefined Then
		// Canceling input.
		Return;
	EndIf;

	ReportRegistrationResults(MessageNumber, EditMessageNumberAtServer(ExchangeNodeRef, MessageNumber,
		AdditionalParameters.MetaFullName));

	Items.ConstantsList.Refresh();
	FillRegistrationCountInTreeRows();
EndProcedure

&AtClient
Procedure EditRefMessageNo()
	curData = Items.RefsList.CurrentData;
	If curData = Undefined Then
		Return;
	EndIf;
	
	Notification = New NotifyDescription("EditRefMessageNoCompletion", ThisObject, New Structure);
	Notification.AdditionalParameters.Insert("Ref", curData.Ref);
	
	MessageNumber = curData.MessageNo;
	Tooltip = NStr("ru = 'Номер отправленного'; en = 'Number of the last sent message'"); 
	
	ShowInputNumber(Notification, MessageNumber, Tooltip);
EndProcedure

&AtClient
Procedure EditRefMessageNoCompletion(Val MessageNumber, Val AdditionalParameters) Export
	If MessageNumber = Undefined Then
		// Canceling input.
		Return;
	EndIf;
	
	ReportRegistrationResults(MessageNumber, EditMessageNumberAtServer(ExchangeNodeRef, MessageNumber,
		AdditionalParameters.Ref));

	Items.RefsList.Refresh();
	FillRegistrationCountInTreeRows();
EndProcedure

&AtClient
Procedure EditMessageNoSetList()
	curData = Items.RecordSetsList.CurrentData;
	If curData = Undefined Then
		Return;
	EndIf;
	
	Notification = New NotifyDescription("EditMessageNoSetListCompletion", ThisObject, New Structure);
	
	RowData = New Structure;
	KeysNames = RecordSetKeyNameArray(RecordSetsListTableName);
	For Each Name In KeysNames Do
		RowData.Insert(Name, curData["RecordSetsList" + Name]);
	EndDo;
	
	Notification.AdditionalParameters.Insert("RowData", RowData);
	
	MessageNumber = curData.MessageNo;
	Tooltip = NStr("ru = 'Номер отправленного'; en = 'Number of the last sent message'"); 
	
	ShowInputNumber(Notification, MessageNumber, Tooltip);
EndProcedure

&AtClient
Procedure EditMessageNoSetListCompletion(Val MessageNumber, Val AdditionalParameters) Export
	If MessageNumber = Undefined Then
		// Canceling input.
		Return;
	EndIf;
	
	ReportRegistrationResults(MessageNumber, EditMessageNumberAtServer(
		ExchangeNodeRef, MessageNumber, AdditionalParameters.RowData, RecordSetsListTableName));

	Items.RecordSetsList.Refresh();
	FillRegistrationCountInTreeRows();
EndProcedure

&AtClient
Procedure SetUpChangeEditing()
	SetUpChangeEditingServer(MetadataCurrentRow);
EndProcedure

&AtClient
Procedure ExpandMetadataTree()
	For Each Row In MetadataTree.GetItems() Do
		Items.MetadataTree.Expand( Row.GetID() );
	EndDo;
EndProcedure

&AtServer
Procedure SetMessageNumberTitle()
	
	Text = NStr("ru = '№ отправленного %1, № принятого %2'; en = 'Sent message # %1, received message # %2'");
	
	Data = ReadMessageNumbers();
	Text = StrReplace(Text, "%1", Format(Data.SentNo, "NFD=0; NZ="));
	Text = StrReplace(Text, "%2", Format(Data.ReceivedNo, "NFD=0; NZ="));
	
	Items.FormEditMessagesNumbers.Title = Text;
EndProcedure

&AtServer
Procedure ExchangeNodeChoiceProcessing()
	
	// Modifying node numbers in the FormEditMessageNumbers title.
	SetMessageNumberTitle();
	
	// Updating metadata tree.
	ReadMetadataTree();
	FillRegistrationCountInTreeRows();
	
	// Updating active page.
	//@skip-warning
	LastActiveMetadataColumn = Undefined;
	//@skip-warning
	LastActiveMetadataRow  = Undefined;
	Items.ObjectsListOptions.CurrentPage = Items.BlankPage;

EndProcedure

&AtClient
Procedure ReportRegistrationResults(Command, Results)

	If TypeOf(Command) = Type("Boolean") Then
		If Command Then
			WarningTitle = NStr("ru = 'Регистрация изменений:'; en = 'Register changes:'");
			WarningText = NStr("ru = 'Зарегистрировано %1 изменений из %2
			                           |на узле ""%0""'; 
			                           |en = '%1 out of %2 changes are registered
			                           |at node ""%0.""'");
		Else
			WarningTitle = NStr("ru = 'Отмена регистрации:'; en = 'Cancel registration:'");
			WarningText = NStr("ru = 'Отменена регистрация %1 изменений 
			                           |на узле ""%0"".'; 
			                           |en = 'Registration of %1 changes
			                           |at node ""%0"" is canceled.'");
		EndIf;
	Else
		WarningTitle = NStr("ru = 'Изменение номера сообщения:'; en = 'Change message number:'");
		WarningText = NStr("ru = 'Номер сообщения изменен на %3
		                           |у %1 объекта(ов)'; 
		                           |en = 'Message number is changed to %3
		                           |for %1 objects.'");
	EndIf;
	
	WarningText = StrReplace(WarningText, "%0", ExchangeNodeRef);
	WarningText = StrReplace(WarningText, "%1", Format(Results.Success, "NZ="));
	WarningText = StrReplace(WarningText, "%2", Format(Results.Total, "NZ="));
	WarningText = StrReplace(WarningText, "%3", Command);
	
	WarningRequired = Results.Total <> Results.Success;
	If WarningRequired Then
		RefreshDataRepresentation();
		ShowMessageBox(, WarningText, , WarningTitle);
	Else
		ShowUserNotification(WarningTitle, GetURL(ExchangeNodeRef),
			WarningText,Items.HiddenPictureInformation32.Picture);
	EndIf;
EndProcedure

&AtServer
Function GetQueryResultChoiceForm()
	
	CurrentObject = ThisObject();
	CurrentObject.ReadSettings();
	ThisObject(CurrentObject);
	
	CheckSSL = CurrentObject.CheckSettingsCorrectness();
	ThisObject(CurrentObject);
	If CheckSSL.QueryExternalDataProcessorAddressSetting <> Undefined Then
		Return Undefined;
	ElsIf IsBlankString(CurrentObject.QueryExternalDataProcessorAddressSetting) Then
		Return Undefined;
	ElsIf Lower(Right(TrimAll(CurrentObject.QueryExternalDataProcessorAddressSetting), 4)) = ".epf" Then
		DataProcessor = ExternalDataProcessors.Create(CurrentObject.QueryExternalDataProcessorAddressSetting);
		FormID = ".ObjectForm";
	Else
		DataProcessor = DataProcessors[CurrentObject.QueryExternalDataProcessorAddressSetting].Create();
		FormID = ".Form";
	Endif;

	Return DataProcessor.Metadata().FullName() + FormID;
EndFunction

&AtClient
Procedure AddConstantRegistrationToList()
	CurFormName = GetFormName() + "Form.SelectConstant";
	CurParameters = New Structure("ExchangeNode, MetadataNamesArray, PresentationsArray, AutoRecordsArray",
		ExchangeNodeRef, MetadataNamesStructure.Constants, MetadataPresentationsStructure.Constants,
		MetadataAutoRecordStructure.Constants);
	OpenForm(CurFormName, CurParameters, Items.ConstantsList);
EndProcedure

&AtClient
Procedure DeleteConstantRegistrationInList()
	
	Item = Items.ConstantsList;
	
	PresentationsList = New Array;
	NamesList          = New Array;
	For Each Row In Item.SelectedRows Do
		Data = Item.RowData(Row);
		PresentationsList.Add(Data.Description);
		NamesList.Add(Data.MetaFullName);
	EndDo;
	
	Count = NamesList.Count();
	If Count = 0 Then
		Return;
	ElsIf Count = 1 Then
		Text = NStr("ru = 'Отменить регистрацию ""%2""
		                 |на узле ""%1""?'; 
		                 |en = 'Do you want to cancel registration of ""%2""
		                 |at node ""%1""?'"); 
	Else
		Text = NStr("ru = 'Отменить регистрацию выбранных констант
		                 |на узле ""%1""?'; 
		                 |en = 'Do you want to cancel registration of the selected constants
		                 |at node ""%1""?'"); 
	EndIf;
	Text = StrReplace(Text, "%1", ExchangeNodeRef);
	Text = StrReplace(Text, "%2", PresentationsList[0]);
	
	QuestionTitle = NStr("ru = 'Подтверждение'; en = 'Confirm operation'");
	
	Notification = New NotifyDescription("DeleteConstantRegistrationInListCompletion", ThisObject, New Structure);
	Notification.AdditionalParameters.Insert("NamesList", NamesList);
	
	ShowQueryBox(Notification, Text, QuestionDialogMode.YesNo, , ,QuestionTitle);
EndProcedure

&AtClient
Procedure DeleteConstantRegistrationInListCompletion(Val QuestionResult, Val AdditionalParameters) Export
	If QuestionResult <> DialogReturnCode.Yes Then
		Return;
	EndIf;

	ReportRegistrationResults(False, DeleteRegistrationAtServer(True, ExchangeNodeRef,
		AdditionalParameters.NamesList));

	Items.ConstantsList.Refresh();
	FillRegistrationCountInTreeRows();
EndProcedure

&AtClient
Procedure AddRegistrationToReferenceList(IsPick = False)
	CurFormName = GetFormName(RefsList) + "ChoiceForm";
	CurParameters = New Structure("ChoiceMode, MultipleChoice, CloseOnChoice, ChoiceFoldersAndItems", True,
		True, IsPick, FoldersAndItemsUse.FoldersAndItems);
	OpenForm(CurFormName, CurParameters, Items.RefsList);
EndProcedure

&AtClient
Procedure AddObjectDeletionRegistrationInReferenceList()
	Ref = ObjectRefToDelete();
	DataChoiceProcessing(Items.RefsList, Ref);
EndProcedure

&AtServer
Function ObjectRefToDelete(Val UUID = Undefined)
	Details = ThisObject().MetadataCharacteristics(RefsList.MainTable);
	If UUID = Undefined Then
		Return Details.Manager.GetRef();
	EndIf;
	Return Details.Manager.GetRef(UUID);
EndFunction

&AtClient
Procedure AddRegistrationInListFilter()
	CurFormName = GetFormName() + "Form.SelectObjectsUsingFilter";
	CurParameters = New Structure("ChoiceAction, TableName", True, DynamicListMainTable(
		RefsList));
	OpenForm(CurFormName, CurParameters, Items.RefsList);
EndProcedure

&AtClient
Procedure DeleteRegistrationFromListFilter()
	CurFormName = GetFormName() + "Form.SelectObjectsUsingFilter";
	CurParameters = New Structure("ChoiceAction, TableName", False, DynamicListMainTable(RefsList));
	OpenForm(CurFormName, CurParameters, Items.RefsList);
EndProcedure

&AtClient
Procedure DeleteRegistrationFromReferenceList()
	
	Item = Items.RefsList;
	
	DeletionList = New Array;
	For Each Row In Item.SelectedRows Do
		Data = Item.RowData(Row);
		DeletionList.Add(Data.Ref);
	EndDo;
	
	Count = DeletionList.Count();
	If Count = 0 Then
		Return;
	ElsIf Count = 1 Then
		Text = NStr("ru = 'Отменить регистрацию ""%2""
		                 |на узле ""%1""?'; 
		                 |en = 'Do you want to cancel registration of ""%2""
		                 |at node ""%1""?'"); 
	Else
		Text = NStr("ru = 'Отменить регистрацию выбранных объектов
		                 |на узле ""%1""?'; 
		                 |en = 'Cancel registration of the selected objects
		                 |on node ""%1""?'"); 
	EndIf;
	Text = StrReplace(Text, "%1", ExchangeNodeRef);
	Text = StrReplace(Text, "%2", DeletionList[0]);
	
	QuestionTitle = NStr("ru = 'Подтверждение'; en = 'Confirm operation'");
	
	Notification = New NotifyDescription("DeleteRegistrationFromReferenceListCompletion", ThisObject, New Structure);
	Notification.AdditionalParameters.Insert("DeletionList", DeletionList);
	
	ShowQueryBox(Notification, Text, QuestionDialogMode.YesNo, , , QuestionTitle);
EndProcedure

&AtClient
Procedure DeleteRegistrationFromReferenceListCompletion(Val QuestionResult, Val AdditionalParameters) Export
	If QuestionResult <> DialogReturnCode.Yes Then
		Return;
	EndIf;

	ReportRegistrationResults(False, DeleteRegistrationAtServer(True, ExchangeNodeRef,
		AdditionalParameters.DeletionList));

	Items.RefsList.Refresh();
	FillRegistrationCountInTreeRows();
EndProcedure

&AtClient
Procedure AddRegistrationToRecordSetFilter()
	CurFormName = GetFormName() + "Form.SelectObjectsUsingFilter";
	CurParameters = New Structure("ChoiceAction, TableName", True, RecordSetsListTableName);
	OpenForm(CurFormName, CurParameters, Items.RecordSetsList);
EndProcedure

&AtClient
Procedure DeleteRegistrationInRecordSet()
	
	DataStructure = "";
	KeysNames = RecordSetKeyNameArray(RecordSetsListTableName);
	For Each Name In KeysNames Do
		DataStructure = DataStructure +  "," + Name;
	EndDo;
	DataStructure = Mid(DataStructure, 2);
	
	Data = New Array;
	Item = Items.RecordSetsList;
	For Each Row In Item.SelectedRows Do
		curData = Item.RowData(Row);
		RowData = New Structure;
		For Each Name In KeysNames Do
			RowData.Insert(Name, curData["RecordSetsList" + Name]);
		EndDo;
		Data.Add(RowData);
	EndDo;
	
	If Data.Count() = 0 Then
		Return;
	EndIf;

	Choice = New Structure("TableName, ChoiceData, ChoiceAction, FieldsStructure", RecordSetsListTableName,
		Data, False, DataStructure);

	DataChoiceProcessing(Items.RecordSetsList, Choice);
EndProcedure

&AtClient
Procedure DeleteRegistrationInRecordSetFilter()
	CurFormName = GetFormName() + "Form.SelectObjectsUsingFilter";
	CurParameters = New Structure("ChoiceAction, TableName", False, RecordSetsListTableName);
	OpenForm(CurFormName, CurParameters, Items.RecordSetsList);
EndProcedure

&AtClient
Procedure AddSelectedObjectRegistration(NoAutoRegistration = True)
	
	Data = GetSelectedMetadataNames(NoAutoRegistration);
	Count = Data.MetaNames.Count();
	If Count = 0 Then
		// Current row
		Data = GetCurrentRowMetadataNames(NoAutoRegistration);
	EndIf;
	
	Text = NStr("ru = 'Зарегистрировать %1 для выгрузки на узле ""%2""?
	                 |
	                 |Изменение регистрации большого количества объектов может занять продолжительное время.'; 
	                 |en = 'Register %1 for exporting on the ""%2"" node?
	                 |
	                 |Changing registration of a amount number of objects can take a long time.'");
					 
	Text = StrReplace(Text, "%1", Data.Details);
	Text = StrReplace(Text, "%2", ExchangeNodeRef);
	
	QuestionTitle = NStr("ru = 'Подтверждение'; en = 'Confirm operation'");
	
	Notification = New NotifyDescription("AddSelectedObjectRegistrationCompletion", ThisObject, New Structure);
	Notification.AdditionalParameters.Insert("MetaNames", Data.MetaNames);
	Notification.AdditionalParameters.Insert("NoAutoRegistration", NoAutoRegistration);
	
	ShowQueryBox(Notification, Text, QuestionDialogMode.YesNo, , , QuestionTitle);
EndProcedure

&AtClient
Procedure AddSelectedObjectRegistrationCompletion(Val QuestionResult, Val AdditionalParameters) Export
	If QuestionResult <> DialogReturnCode.Yes Then
		Return;
	EndIf;

	Result = AddRegistrationAtServer(AdditionalParameters.NoAutoRegistration, ExchangeNodeRef,
		AdditionalParameters.MetaNames);
		
	FillRegistrationCountInTreeRows();
	UpdatePageContent();
	ReportRegistrationResults(True, Result);
EndProcedure

&AtClient
Procedure DeleteSelectedObjectRegistration(NoAutoRegistration = True)
	
	Data = GetSelectedMetadataNames(NoAutoRegistration);
	Count = Data.MetaNames.Count();
	If Count = 0 Then
		Data = GetCurrentRowMetadataNames(NoAutoRegistration);
	EndIf;
	
	Text = NStr("ru = 'Отменить регистрацию %1 для выгрузки на узле ""%2""?
	                 |
	                 |Изменение регистрации большого количества объектов может занять продолжительное время.'; 
	                 |en = 'Cancel %1 registration for export on the ""%2"" node? 
	                 |
	                 |Changing registration of a large amount of objects can take a long time.'");
	
	QuestionTitle = NStr("ru = 'Подтверждение'; en = 'Confirm operation'");
	
	Text = StrReplace(Text, "%1", Data.Details);
	Text = StrReplace(Text, "%2", ExchangeNodeRef);
	
	Notification = New NotifyDescription("DeleteSelectedObjectRegistrationCompletion", ThisObject, New Structure);
	Notification.AdditionalParameters.Insert("MetaNames", Data.MetaNames);
	Notification.AdditionalParameters.Insert("NoAutoRegistration", NoAutoRegistration);
	
	ShowQueryBox(Notification, Text, QuestionDialogMode.YesNo, , , QuestionTitle);
EndProcedure

&AtClient
Procedure DeleteSelectedObjectRegistrationCompletion(Val QuestionResult, Val AdditionalParameters) Export
	If QuestionResult <> DialogReturnCode.Yes Then
		Return;
	EndIf;

	ReportRegistrationResults(False, DeleteRegistrationAtServer(AdditionalParameters.NoAutoRegistration,
		ExchangeNodeRef, AdditionalParameters.MetaNames));

	FillRegistrationCountInTreeRows();
		UpdatePageContent();
EndProcedure

&AtClient
Procedure DataChoiceProcessing(FormTable, SelectedValue)
	
	Ref = Undefined;
	Type    = TypeOf(SelectedValue);
	
	If Type = Type("Structure") Then
		TableName = SelectedValue.TableName;
		Action   = SelectedValue.ChoiceAction;
		Data     = SelectedValue.ChoiceData;
	Else
		TableName = Undefined;
		Action = True;
		If Type = Type("Array") Then
			Data = SelectedValue;
		Else		
			Data = New Array;
			Data.Add(SelectedValue);
		EndIf;
		
		If Data.Count() = 1 Then
			Ref = Data[0];
		EndIf;
	EndIf;
	
	If Action Then
		Result = AddRegistrationAtServer(True, ExchangeNodeRef, Data, TableName);

		FormTable.Refresh();
		FillRegistrationCountInTreeRows();
		ReportRegistrationResults(Action, Result);

		FormTable.CurrentRow = Ref;
		Return;
	EndIf;

	If Ref = Undefined Then
		Text = NStr("ru = 'Отменить регистрацию выбранных объектов
		                 |на узле ""%1?'; 
		                 |en = 'Cancel registration of the selected objects
		                 |on node ""%1""?'"); 
	Else
		Text = NStr("ru = 'Отменить регистрацию ""%2""
		                 |на узле ""%1?'; 
		                 |en = 'Cancel registration of ""%2""
		                 |on node ""%1?'"); 
	EndIf;
		
	Text = StrReplace(Text, "%1", ExchangeNodeRef);
	Text = StrReplace(Text, "%2", Ref);
	
	QuestionTitle = NStr("ru = 'Подтверждение'; en = 'Confirm operation'");
		
	Notification = New NotifyDescription("DataChoiceProcessingCompletion", ThisObject, New Structure);
	Notification.AdditionalParameters.Insert("Action",     Action);
	Notification.AdditionalParameters.Insert("FormTable", FormTable);
	Notification.AdditionalParameters.Insert("Data",       Data);
	Notification.AdditionalParameters.Insert("TableName",   TableName);
	Notification.AdditionalParameters.Insert("Ref",       Ref);
	
	ShowQueryBox(Notification, Text, QuestionDialogMode.YesNo, , ,QuestionTitle);
EndProcedure

&AtClient
Procedure DataChoiceProcessingCompletion(Val QuestionResult, Val AdditionalParameters) Export
	If QuestionResult <> DialogReturnCode.Yes Then
		Return;
	EndIf;

	Result = DeleteRegistrationAtServer(True, ExchangeNodeRef, AdditionalParameters.Data,
		AdditionalParameters.TableName);

	AdditionalParameters.FormTable.Refresh();
	FillRegistrationCountInTreeRows();
	ReportRegistrationResults(AdditionalParameters.Action, Result);

	AdditionalParameters.FormTable.CurrentRow = AdditionalParameters.Ref;
EndProcedure

&AtServer
Procedure UpdatePageContent(Page = Undefined)
	CurrPage = ?(Page = Undefined, Items.ObjectsListOptions.CurrentPage, Page);
	
	If CurrPage = Items.ReferencesListPage Then
		Items.RefsList.Refresh();
		
	ElsIf CurrPage = Items.ConstantsPage Then
		Items.ConstantsList.Refresh();
		
	ElsIf CurrPage = Items.RecordSetPage Then
		Items.RecordSetsList.Refresh();
		
	ElsIf CurrPage = Items.BlankPage Then
		Row = Items.MetadataTree.CurrentRow;
		If Row <> Undefined Then
			Data = MetadataTree.FindByID(Row);
			If Data <> Undefined Then
				SetUpBlankPage(Data.Description, Data.MetaFullName);
			EndIf;
		EndIf;
	EndIf;
EndProcedure

&AtClient
Function GetCurrentObjectToEdit()
	
	CurrPage = Items.ObjectsListOptions.CurrentPage;
	
	If CurrPage = Items.ReferencesListPage Then
		Data = Items.RefsList.CurrentData;
		If Data <> Undefined Then
			Return Data.Ref; 
		EndIf;
		
	ElsIf CurrPage = Items.ConstantsPage Then
		Data = Items.ConstantsList.CurrentData;
		If Data <> Undefined Then
			Return Data.MetaFullName; 
		EndIf;
		
	ElsIf CurrPage = Items.RecordSetPage Then
		Data = Items.RecordSetsList.CurrentData;
		If Data <> Undefined Then
			Result = New Structure;
			Dimensions = RecordSetKeyNameArray(RecordSetsListTableName);
			For Each Name In Dimensions  Do
				Result.Insert(Name, Data["RecordSetsList" + Name]);
			EndDo;
		EndIf;
		Return Result;
		
	EndIf;
	
	Return Undefined;
	
EndFunction

&AtClient
Procedure OpenDataProcessorSettingsForm()
	CurFormName = GetFormName() + "Form.Settings";
	OpenForm(CurFormName, , ThisObject);
EndProcedure

&AtClient
Procedure ActionWithQueryResult(ActionCommand)
	
	CurFormName = GetQueryResultChoiceForm();
	If CurFormName <> Undefined Then
		// Opening form
		If ActionCommand Then
			Text = NStr("ru = 'Регистрация изменений результата запроса'; en = 'Registering query result changes'");
		Else
			Text = NStr("ru = 'Отмена регистрации изменений результата запроса'; en = 'Unregistering query result changes'");
		EndIf;
		OpenForm(CurFormName, New Structure("Title, ChoiceAction, ChoiceMode, CloseOnChoice, ",
			Text, ActionCommand, True, False), ThisObject);
		Return;
	EndIf;
	
	// If the query execution handler is not specified, prompting the user to specify it.
	Text = NStr("ru = 'В настройках не указана обработка для выполнения запросов.
	                        |Настроить сейчас?'; 
	                        |en = 'Data processor for queries is not specified in settings.
	                        |Do you want to set it now?'");
	
	QuestionTitle = NStr("ru = 'Настройки'; en = 'Settings'");

	Notification = New NotifyDescription("ActionWithQueryResultsCompletion", ThisObject);
	ShowQueryBox(Notification, Text, QuestionDialogMode.YesNo, , , QuestionTitle);
EndProcedure

&AtClient
Procedure ActionWithQueryResultsCompletion(Val QuestionResult, Val AdditionalParameters) Export
	If QuestionResult <> DialogReturnCode.Yes Then
		Return;
	EndIf;
	
	OpenDataProcessorSettingsForm();
EndProcedure

&AtServer
Function ProcessQuotationMarksInRow(Row)
	Return StrReplace(Row, """", """""");
EndFunction

&AtServer
Function ThisObject(CurrentObject = Undefined) 
	If CurrentObject = Undefined Then
		Return FormAttributeToValue("Object");
	EndIf;
	ValueToFormAttribute(CurrentObject, "Object");
	Return Undefined;
EndFunction

&AtServer
Function GetFormName(CurrentObject = Undefined)
	Return ThisObject().GetFormName(CurrentObject);
EndFunction

&AtServer
Function DynamicListMainTable(FormAttribute)
	Return FormAttribute.MainTable;
EndFunction

&AtServer
Procedure ChangeMark(Row)
	DataItem = MetadataTree.FindByID(Row);
	ThisObject().ChangeMark(DataItem);
EndProcedure

&AtServer
Procedure ReadMetadataTree()
	Data = ThisObject().GenerateMetadataStructure(ExchangeNodeRef);
	
	// Deleting rows that cannot be edited.
	MetaTree = Data.Tree;
	For Each ListItem In NamesOfMetadataToHide Do
		DeleteMetadataValueTreeRows(ListItem.Value, MetaTree.Rows);
	EndDo;
	
	ValueToFormAttribute(MetaTree, "MetadataTree");
	MetadataAutoRecordStructure = Data.AutoRecordStructure;
	MetadataPresentationsStructure   = Data.PresentationsStructure;
	MetadataNamesStructure            = Data.NamesStructure;
EndProcedure

&AtServer
Procedure DeleteMetadataValueTreeRows(Val MetaFullName, TreeRows)
	If IsBlankString(MetaFullName) Then
		Return;
	EndIf;
	
	// In the current set
	Filter = New Structure("MetaFullName", MetaFullName);
	For Each DeletionRow In TreeRows.FindRows(Filter, False) Do
		TreeRows.Delete(DeletionRow);
	EndDo;
	
	// Deleting subordinate row recursively.
	For Each TreeRow In TreeRows Do
		DeleteMetadataValueTreeRows(MetaFullName, TreeRow.Rows);
	EndDo;
EndProcedure

&AtServer
Procedure FormatChangeCount(Row)
	Row.ChangeCountString = Format(Row.ChangeCount, "NZ=") + " / " + Format(Row.NotExportedCount, "NZ=");
EndProcedure

&AtServer
Procedure FillRegistrationCountInTreeRows()
	
	Data = ThisObject().GetChangeCount(MetadataNamesStructure, ExchangeNodeRef);
	
	// Calculating and filling the number of changes, the number of exported items, and the number of items that are not exported
	Filter = New Structure("MetaFullName, ExchangeNode", Undefined, ExchangeNodeRef);
	Zeros   = New Structure("ChangeCount, ExportedCount, NotExportedCount", 0,0,0);
	
	For Each Root In MetadataTree.GetItems() Do
		RootSum = New Structure("ChangeCount, ExportedCount, NotExportedCount", 0,0,0);
		
		For Each Folder In Root.GetItems() Do
			FolderSum = New Structure("ChangeCount, ExportedCount, NotExportedCount", 0,0,0);
			
			NodesList = Folder.GetItems();
			If NodesList.Count() = 0 And MetadataNamesStructure.Property(Folder.MetaFullName) Then
				// Node collection contains no nodes, sum manually and take auto record from structure.
				For Each MetaName In MetadataNamesStructure[Folder.MetaFullName] Do
					Filter.MetaFullName = MetaName;
					Found = Data.FindRows(Filter);
					If Found.Count() > 0 Then
						Row = Found[0];
						FolderSum.ChangeCount     = FolderSum.ChangeCount     + Row.ChangeCount;
						FolderSum.ExportedCount   = FolderSum.ExportedCount   + Row.ExportedCount;
						FolderSum.NotExportedCount = FolderSum.NotExportedCount + Row.NotExportedCount;
					EndIf;
				EndDo;

			Else
				// Calculating count values for each node
				For Each Node In NodesList Do
					Filter.MetaFullName = Node.MetaFullName;
					Found = Data.FindRows(Filter);
					If Found.Count() > 0 Then
						Row = Found[0];
						FillPropertyValues(Node, Row, "ChangeCount, ExportedCount, NotExportedCount");
						FolderSum.ChangeCount     = FolderSum.ChangeCount     + Row.ChangeCount;
						FolderSum.ExportedCount   = FolderSum.ExportedCount   + Row.ExportedCount;
						FolderSum.NotExportedCount = FolderSum.NotExportedCount + Row.NotExportedCount;
					Else
						FillPropertyValues(Node, Zeros);
					EndIf;
					
					FormatChangeCount(Node);
				EndDo;
				
			EndIf;
			FillPropertyValues(Folder, FolderSum);

			RootSum.ChangeCount     = RootSum.ChangeCount     + Folder.ChangeCount;
			RootSum.ExportedCount   = RootSum.ExportedCount   + Folder.ExportedCount;
			RootSum.NotExportedCount = RootSum.NotExportedCount + Folder.NotExportedCount;
			
			FormatChangeCount(Folder);
		EndDo;
		
		FillPropertyValues(Root, RootSum);
		
		FormatChangeCount(Root);
	EndDo;
	
EndProcedure

&AtServer
Function ChangeQueryResultRegistrationServer(Command, Address)
	
	Result = GetFromTempStorage(Address);
	Result= Result[Result.UBound()];
	Data = Result.Unload().UnloadColumn("Ref");
	
	If Command Then
		Return AddRegistrationAtServer(True, ExchangeNodeRef, Data);
	EndIf;
		
	Return DeleteRegistrationAtServer(True, ExchangeNodeRef, Data);
EndFunction

&AtServer
Function RefControlForQuerySelection(Address)
	
	Result = ?(Address = Undefined, Undefined, GetFromTempStorage(Address));
	If TypeOf(Result) = Type("Array") Then 
		Result = Result[Result.UBound()];	
		If Result.Columns.Find("Ref") = Undefined Then
			Return NStr("ru = 'В последнем результате запроса отсутствует колонка ""Ссылка""'; en = 'There is no column Ref in a last query result'");
		EndIf;
	Else		
		Return NStr("ru = 'Ошибка получения данных результата запроса'; en = 'Error getting query result data'");
	EndIf;
	
	Return "";
EndFunction

&AtServer
Procedure SetUpChangeEditingServer(CurrentRow)
	
	Data = MetadataTree.FindByID(CurrentRow);
	If Data = Undefined Then
		Return;
	EndIf;
	
	TableName   = Data.MetaFullName;
	Description = Data.Description;
	CurrentObject   = ThisObject();
	
	If IsBlankString(TableName) Then
		Meta = Undefined;
	Else		
		Meta = CurrentObject.MetadataByFullName(TableName);
	EndIf;
	
	If Meta = Undefined Then
		SetUpBlankPage(Description, TableName);
		NewPage = Items.BlankPage;

	ElsIf Meta = Metadata.Constants Then
		// All constants are included in the list
		SetUpConstantList();
		NewPage = Items.ConstantsPage;
		
	ElsIf TypeOf(Meta) = Type("MetadataObjectCollection") Then
		// All catalogs, all documents, and so on
		SetUpBlankPage(Description, TableName);
		NewPage = Items.BlankPage;
		
	ElsIf Metadata.Constants.Contains(Meta) Then
		// Single constant
		SetUpConstantList(TableName, Description);
		NewPage = Items.ConstantsPage;
		
	ElsIf Metadata.Catalogs.Contains(Meta) Or Metadata.Documents.Contains(Meta)
		Or Metadata.ChartsOfCharacteristicTypes.Contains(Meta) Or Metadata.ChartsOfAccounts.Contains(Meta)
		Or Metadata.ChartsOfCalculationTypes.Contains(Meta) Or Metadata.BusinessProcesses.Contains(Meta)
		Or Metadata.Tasks.Contains(Meta) Then
		// Reference type
		SetUpRefList(TableName, Description);
		NewPage = Items.ReferencesListPage;
		
	Else
		// Checking whether a record set is passed
		Dimensions = CurrentObject.RecordSetDimensions(TableName);
		If Dimensions <> Undefined Then
			SetUpRecordSet(TableName, Dimensions, Description);
			NewPage = Items.RecordSetPage;
		Else
			SetUpBlankPage(Description, TableName);
			NewPage = Items.BlankPage;
		EndIf;

	EndIf;

	Items.ConstantsPage.Visible    = False;
	Items.ReferencesListPage.Visible = False;
	Items.RecordSetPage.Visible = False;
	Items.BlankPage.Visible       = False;
	
	Items.ObjectsListOptions.CurrentPage = NewPage;
	NewPage.Visible = True;
	
	SetUpGeneralMenuCommandVisibility();
EndProcedure

// // Displayed changes for a reference type (catalog, document, chart of characteristic types, chart 
// of accounts, calculation type, business processes, tasks.)
//
&AtServer
Procedure SetUpRefList(TableName, Description)

	RefsList.QueryText = 
	"SELECT
	|	ChangesTable.MessageNo AS MessageNo,
	|	ChangesTable.Ref AS Ref,
	|	CASE
	|		WHEN ChangesTable.MessageNo IS NULL
	|			THEN TRUE
	|		ELSE FALSE
	|	END AS NotExported
	|FROMЗ
	|	" + TableName + ".Changes AS ChangesTable
	|WHERE
	|	ChangesTable.Node = &SelectedNode";	

	RefsList.Parameters.SetParameterValue("SelectedNode", ExchangeNodeRef);
//	RefsList.MainTable = TableName;
	RefsList.DynamicDataRead = True;
	
	// Object presentation
	Meta = ThisObject().MetadataByFullName(TableName);
	CurTitle = Meta.ObjectPresentation;
	If IsBlankString(CurTitle) Then
		CurTitle = Description;
	EndIf;
	Items.RefsListRefPresentation.Title = CurTitle;
EndProcedure

// Вывод изменений для констант
//
&AtServer
Procedure SetUpConstantList(TableName = Undefined, Description = "")
	
	If TableName = Undefined Then
		// All constants
		Names = MetadataNamesStructure.Constants;
		Presentations = MetadataPresentationsStructure.Constants;
		AutoRegistration = MetadataAutoRecordStructure.Constants;
	Else
		Names = New Array;
		Names.Add(TableName);
		Presentations = New Array;
		Presentations.Add(Description);
		Index = MetadataNamesStructure.Constants.Find(TableName);
		AutoRegistration = New Array;
		AutoRegistration.Add(MetadataAutoRecordStructure.Constants[Index]);
	EndIf;
	
	Text = "";
	For Index = 0 To Names.UBound() Do
		Name = Names[Index];
		Text = Text + ?(Text = "", "SELECT", "UNION ALL SELECT") + "
		|	" + Format(AutoRegistration[Index], "NZ=; NG=") + " AS AutoRecordPictureIndex,
		|	2                                                   AS PictureIndex,
		|
		|	""" + ProcessQuotationMarksInRow(Presentations[Index]) + """ AS Description,
		|	""" + Name +                                     """ AS MetaFullName,
		|
		|	ChangesTable.MessageNo AS MessageNo,
		|	CASE 
		|		WHEN ChangesTable.MessageNo IS NULL THEN TRUE ELSE FALSE
		|	END AS NotExported
		|FROM
		|	" + Name + ".Changes AS ChangesTable
		|WHERE
		|	ChangesTable.Node = &SelectedNode
		|";
	EndDo;

	ConstantsList.QueryText = "
							  |SELECT
							  |	AutoRecordPictureIndex, PictureIndex, MetaFullName, NotExported,
							  |	Description, MessageNo
							  |
							  |{SELECT
							  |	AutoRecordPictureIndex, PictureIndex, 
							  |	Description, MetaFullName, 
							  |	MessageNo, NotExported
							  |}
							  |
							  |FROM (" + Text + ") Data
											   |
											   |{WHERE
											   |	Description, MessageNo, NotExported
											   |}
											   |";

	ListItems = ConstantsList.Order.Items;
	If ListItems.Count() = 0 Then
		Item = ListItems.Add(Type("DataCompositionOrderItem"));
		Item.Field = New DataCompositionField("Description");
		Item.Use = True;
	EndIf;

	ConstantsList.Parameters.SetParameterValue("SelectedNode", ExchangeNodeRef);
	ConstantsList.DynamicDataRead = True;
EndProcedure	

// Displayed cap with a blank page.
&AtServer
Procedure SetUpBlankPage(Description, TableName = Undefined)

	If TableName = Undefined Then
		CountsText = "";
	Else
		Tree = FormAttributeToValue("MetadataTree");
		Row = Tree.Rows.Find(TableName, "MetaFullName", True);
		If Row <> Undefined Then
			CountsText = NStr("ru = 'Зарегистрировано объектов: %1
			                          |Выгружено объектов: %2
			                          |Не выгружено объектов: %3'; 
			                          |en = 'Objects registered: %1
			                          |Objects exported: %2
			                          |Objects not exported: %3'");
	
			CountsText = StrReplace(CountsText, "%1", Format(Row.ChangeCount, "NFD=0; NZ="));
			CountsText = StrReplace(CountsText, "%2", Format(Row.ExportedCount, "NFD=0; NZ="));
			CountsText = StrReplace(CountsText, "%3", Format(Row.NotExportedCount, "NFD=0; NZ="));
		EndIf;
	EndIf;

	Text = NStr("ru = '%1.
	                 |
	                 |%2
	                 |Для регистрации или отмены регистрации обмена данными на узле
	                 |""%3""
	                 |выберите тип объекта слева в дереве метаданных и воспользуйтесь
	                 |командами ""Зарегистрировать"" или ""Отменить регистрацию""'; 
	                 |en = '%1.
	                 |
	                 |%2
	                 |To register or unregister of data exchange on node
	                 |""%3"",
	                 |select an object type in the metadata tree on the left and click
	                 |""Register"" or ""Unregister""'");
		
	Text = StrReplace(Text, "%1", Description);
	Text = StrReplace(Text, "%2", CountsText);
	Text = StrReplace(Text, "%3", ExchangeNodeRef);
	Items.BlankPageDecoration.Title = Text;
EndProcedure

// Displayed changes for record sets.
//
&AtServer
Procedure SetUpRecordSet(TableName, Dimensions, Description)
	
	ChoiceText = "";
	Prefix     = "RecordSetsList";
	For Each Row In Dimensions Do
		Name = Row.Name;
		ChoiceText = ChoiceText + ",ChangesTable." + Name + " AS " + Prefix + Name + Chars.LF;
		// Adding the prefix to exclude the MessageNo and NotExported dimensions.
		Row.Name = Prefix + Name;
	EndDo;

	RecordSetsList.QueryText = "
							   |SELECT
							   |	ChangesTable.MessageNo AS MessageNo,
							   |	CASE 
							   |		WHEN ChangesTable.MessageNo IS NULL THEN TRUE ELSE FALSE
							   |	END AS NotExported
							   |
							   |	" + ChoiceText + "
													 |FROM
													 |	" + TableName + ".Changes AS ChangesTable
																		|WHERE
																		|	ChangesTable.Node = &SelectedNode
																		|";
	RecordSetsList.Parameters.SetParameterValue("SelectedNode", ExchangeNodeRef);
	
	// Adding columns to the appropriate group.
	ThisObject().AddColumnsToFormTable(
		Items.RecordSetsList, "MessageNo, NotExported, 
			|Order, Filter, Group, StandardPicture, Parameters, ConditionalAppearance",
		Dimensions, Items.RecordSetsListDimensionsGroup);
	RecordSetsList.DynamicDataRead = True;
	RecordSetsListTableName = TableName;
EndProcedure

// Common filter by the MessageNumber field.
//
&AtServer
Procedure SetFilterByMessageNumber(DynamicList, Option)
	
	Field = New DataCompositionField("NotExported");
	// Iterating through the filter item list to delete a specific item.
	ListItems = DynamicList.Filter.Items;
	Index = ListItems.Count();
	While Index > 0 Do
		Index = Index - 1;
		Item = ListItems[Index];
		If Item.LeftValue = Field Then 
			ListItems.Delete(Item);
		EndIf;
	EndDo;
	
	FilterItem = ListItems.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = Field;
	FilterItem.ComparisonType  = DataCompositionComparisonType.Equal;
	FilterItem.Use = False;
	FilterItem.ViewMode = DataCompositionSettingsItemViewMode.Inaccessible;
	
	If Option = 1 Then 		// Exported
		FilterItem.RightValue = False;
		FilterItem.Use  = True;
		
	ElsIf Option = 2 Then	// Not exported
		FilterItem.RightValue = True;
		FilterItem.Use  = True;
		
	EndIf;
	
EndProcedure

&AtServer
Procedure SetUpGeneralMenuCommandVisibility()
	
	CurrPage = Items.ObjectsListOptions.CurrentPage;
	
	If CurrPage = Items.ConstantsPage Then
		Items.FormAddRegistrationForSingleObject.Enabled = True;
		Items.FormAddRegistrationFilter.Enabled         = False;
		Items.FormDeleteRegistrationForSingleObject.Enabled  = True;
		Items.FormDeleteRegistrationFilter.Enabled          = False;
		
	ElsIf CurrPage = Items.ReferencesListPage Then
		Items.FormAddRegistrationForSingleObject.Enabled = True;
		Items.FormAddRegistrationFilter.Enabled         = True;
		Items.FormDeleteRegistrationForSingleObject.Enabled  = True;
		Items.FormDeleteRegistrationFilter.Enabled          = True;
		
	ElsIf CurrPage = Items.RecordSetPage Then
		Items.FormAddRegistrationForSingleObject.Enabled = True;
		Items.FormAddRegistrationFilter.Enabled         = False;
		Items.FormDeleteRegistrationForSingleObject.Enabled  = True;
		Items.FormDeleteRegistrationFilter.Enabled          = False;
		
	Else
		Items.FormAddRegistrationForSingleObject.Enabled = False;
		Items.FormAddRegistrationFilter.Enabled         = False;
		Items.FormDeleteRegistrationForSingleObject.Enabled  = False;
		Items.FormDeleteRegistrationFilter.Enabled          = False;
		
	EndIf;
EndProcedure

&AtServer
Function RecordSetKeyNameArray(TableName, NamesPrefix = "")
	Result = New Array;
	Dimensions = ThisObject().RecordSetDimensions(TableName);
	If Dimensions <> Undefined Then
		For Each Row In Dimensions Do
			Result.Add(NamesPrefix + Row.Name);
		EndDo;
	EndIf;
	Return Result;
EndFunction

&AtServer
Function GetManagerByMetadata(TableName) 
	Details = ThisObject().MetadataCharacteristics(TableName);
	If Details <> Undefined Then
		Return Details.Manager;
	EndIf;
	Return Undefined;
EndFunction

&AtServer
Function SerializationText(Serialization)
	
	Text = New TextDocument;
	
	Record = New XMLWriter;
	For Each Item In Serialization Do
		Record.SetString("UTF-16");	
		Value = Undefined;
		
		If Item.TypeFlag = 1 Then
			// Metadata
			Manager = GetManagerByMetadata(Item.Data);
			Value = Manager.CreateValueManager();
			
		ElsIf Item.TypeFlag = 2 Then
			// Creating record set with a filter
			Manager = GetManagerByMetadata(RecordSetsListTableName);
			Value = Manager.CreateRecordSet();
			Filter = Value.Filter;
			For Each NameValue In Item.Data Do
				Filter[NameValue.Key].Set(NameValue.Value);
			EndDo;
			Value.Read();
			
		ElsIf Item.TypeFlag = 3 Then
			// Ref
			Value = Item.Data.GetObject();
			If Value = Undefined Then
				Value = New ObjectDeletion(Item.Data);
			EndIf;
		EndIf;
		
		WriteXML(Record, Value); 
		Text.AddLine(Record.Close());
	EndDo;
	
	Return Text;
EndFunction

&AtServer
Function DeleteRegistrationAtServer(NoAutoRegistration, Node, Deleted, TableName = Undefined)
	Return ThisObject().EditRegistrationAtServer(False, NoAutoRegistration, Node, Deleted, TableName);
EndFunction

&AtServer
Function AddRegistrationAtServer(NoAutoRegistration, Node, Deleted, TableName = Undefined)
	Return ThisObject().EditRegistrationAtServer(True, NoAutoRegistration, Node, Deleted, TableName);
EndFunction

&AtServer
Function EditMessageNumberAtServer(Node, MessageNo, Data, TableName = Undefined)
	Return ThisObject().EditRegistrationAtServer(MessageNo, True, Node, Data, TableName);
EndFunction

&AtServer
Function GetSelectedMetadataDetails(NoAutoRegistration, MetaGroupName = Undefined, MetaNodeName = Undefined)
    
	If MetaGroupName = Undefined And MetaNodeName = Undefined Then
		// No item selected
		Text = NStr("ru = 'все объекты %1 по выбранной иерархии вида'; en = 'all objects %1 according to the selected type hierarchy'");
		
	ElsIf MetaGroupName <> Undefined And MetaNodeName = Undefined Then
		// Only a group is specified.
		Text = "%2 %1";
		
	ElsIf MetaGroupName = Undefined And MetaNodeName <> Undefined Then
		// Only a node is specified.
		Text = NStr("ru = 'все объекты %1 по выбранной иерархии вида'; en = 'all objects %1 according to the selected type hierarchy'");
		
	Else
		// A group and a node are specified, using these values to obtain a metadata presentation.
		Text = NStr("ru = 'все объекты типа ""%3"" %1'; en = 'all objects of type %3 %1'");
		
	EndIf;

	If NoAutoRegistration Then
		FlagText = "";
	Else
		FlagText = NStr("ru = 'с признаком авторегистрации'; en = 'with autoregistration flag'");
	EndIf;
	
	Presentation = "";
	For Each KeyValue In MetadataPresentationsStructure Do
		If KeyValue.Key = MetaGroupName Then
			Index = MetadataNamesStructure[MetaGroupName].Find(MetaNodeName);
			Presentation = ?(Index = Undefined, "", KeyValue.Value[Index]);
			Break;
		EndIf;
	EndDo;
	
	Text = StrReplace(Text, "%1", FlagText);
	Text = StrReplace(Text, "%2", Lower(MetaGroupName));
	Text = StrReplace(Text, "%3", Presentation);
	
	Return TrimAll(Text);
EndFunction

&AtServer
Function GetCurrentRowMetadataNames(NoAutoRegistration) 
	
	Row = MetadataTree.FindByID(Items.MetadataTree.CurrentRow);
	If Row = Undefined Then
		Return Undefined;
	EndIf;
	
	Result = New Structure("MetaNames, Details", 
		New Array, GetSelectedMetadataDetails(NoAutoRegistration));
	MetaName = Row.MetaFullName;
	If IsBlankString(MetaName) Then
		Result.MetaNames.Add(Undefined);	
	Else
		Result.MetaNames.Add(MetaName);	
		
		Parent = Row.GetParent();
		MetaParentName = Parent.MetaFullName;
		If IsBlankString(MetaParentName) Then
			Result.Details = GetSelectedMetadataDetails(NoAutoRegistration, Row.Description);
		Else
			Result.Details = GetSelectedMetadataDetails(NoAutoRegistration, MetaParentName, MetaName);
		EndIf;
	EndIf;
	
	Return Result;
EndFunction

&AtServer
Function GetSelectedMetadataNames(NoAutoRegistration)
	
	Result = New Structure("MetaNames, Details", 
		New Array, GetSelectedMetadataDetails(NoAutoRegistration));
	
	For Each Root In MetadataTree.GetItems() Do
		
		If Root.Check = 1 Then
			Result.MetaNames.Add(Undefined);
			Return Result;
		EndIf;
		
		PartialSelectedCount = 0;
		FolderCount     = 0;
		NodeCount     = 0;
		For Each Folder In Root.GetItems() Do
			
			If Folder.Check = 0 Then
				Continue;
			ElsIf Folder.Check = 1 Then
				//	Getting data of the selected folder.
				FolderCount = FolderCount + 1;
				FolderDetails = GetSelectedMetadataDetails(NoAutoRegistration, Folder.Description);

				If Folder.GetItems().Count() = 0 Then
					// Reading marked data from the metadata names structure.
					//@skip-warning
					PresentationArray = MetadataPresentationsStructure[Folder.MetaFullName];
					AutoArray = MetadataAutoRecordStructure[Folder.MetaFullName];
					NamesArray = MetadataNamesStructure[Folder.MetaFullName];
					For Index = 0 To NamesArray.UBound() Do
						If NoAutoRegistration Or AutoArray[Index] = 2 Then
							Result.MetaNames.Add(NamesArray[Index]);
							NodeDetails = GetSelectedMetadataDetails(NoAutoRegistration, Folder.MetaFullName, NamesArray[Index]);
						EndIf;
					EndDo;
					
					Continue;
				EndIf;

			Else
				PartialSelectedCount = PartialSelectedCount + 1;
			EndIf;

			For Each Node In Folder.GetItems() Do
				If Node.Check = 1 Then
					// Node.AutoRegistration = 2 -> allowed
					If NoAutoRegistration Or Node.AutoRegistration = 2 Then
						Result.MetaNames.Add(Node.MetaFullName);
						NodeDetails = GetSelectedMetadataDetails(NoAutoRegistration, Folder.MetaFullName, Node.MetaFullName);
						NodeCount = NodeCount + 1;
					EndIf;
				EndIf
			EndDo;

		КонецЦикла;

		If FolderCount = 1 And PartialSelectedCount = 0 Then
			Result.Details = FolderDetails;
		ElsIf FolderCount = 0 And NodeCount = 1 Then
			Result.Details = NodeDetails;
		EndIf;
		
	EndDo;
	
	Return Result;
EndFunction

&AtServer
Function ReadMessageNumbers()
	QueryAttributes = "SentNo, ReceivedNo";
	Data = ThisObject().GetExchangeNodeParameters(ExchangeNodeRef, QueryAttributes);
	If Data = Undefined Then
		Return New Structure(QueryAttributes)
	EndIf;
	Return Data;
EndFunction

&AtServer
Procedure ProcessNodeChangeProhibition()
	OperationsAllowed = Not SelectExchangeNodeProhibited;
	
	If OperationsAllowed Then
		Items.ExchangeNodeRef.Visible = True;
		Title = NStr("ru = 'Регистрация изменений для обмена данными'; en = 'Register changes for data exchange'");
	Else
		Items.ExchangeNodeRef.Visible = False;
		Title = StrReplace(NStr("ru = 'Регистрация изменений для обмена с  ""%1""'; en = 'Register changes for exchange with %1'"), "%1", String(ExchangeNodeRef));
	EndIf;
	
	Items.FormOpenNodeRegistrationForm.Visible = OperationsAllowed;
	
	Items.ConstantsListContextMenuOpenNodeRegistrationForm.Visible       = OperationsAllowed;
	Items.RefsListContextMenuOpenNodeRegistrationForm.Visible         = OperationsAllowed;
	Items.RecordSetsListContextMenuOpenNodeRegistrationForm.Visible = OperationsAllowed;
EndProcedure

&AtServer
Function ControlSettings()
	Result = True;
	
	// Checking a specified exchange node.
	CurrentObject = ThisObject();
	If ExchangeNodeRef <> Undefined AND ExchangePlans.AllRefsType().ContainsType(TypeOf(ExchangeNodeRef)) Then
		AllowedExchangeNodes = CurrentObject.GenerateNodeTree();
		//@skip-warning
		PlanName = ExchangeNodeRef.Metadata().Name;
		If AllowedExchangeNodes.Rows.Find(PlanName, "ExchangePlanName", True) = Undefined Then
			// A node with an invalid exchange plan.
			ExchangeNodeRef = Undefined;
			Result = False;
		ElsIf ExchangeNodeRef = ExchangePlans[PlanName].ThisNode() Then
			// This node
			ExchangeNodeRef = Undefined;
			Result = False;
		EndIf;
	EndIf;
	
	If ValueIsFilled(ExchangeNodeRef) Then
		ExchangeNodeChoiceProcessing();
	EndIf;
	ProcessNodeChangeProhibition();
	
	// Settings relation
	SetFilterByMessageNumber(ConstantsList, FilterByMessageNumberOption);
	SetFilterByMessageNumber(RefsList, FilterByMessageNumberOption);
	SetFilterByMessageNumber(RecordSetsList, FilterByMessageNumberOption);

	Return Result ;
EndFunction

&AtServer
Function RecordSetKeyStructure(Val CurrentData)
	
	Details = ThisObject().MetadataCharacteristics(RecordSetsListTableName);
	
	If Details = Undefined Then
		// Unknown source
		Return Undefined;
	EndIf;
	
	Result = New Structure("Key, FormName");

	Dimensions = New Structure;
	KeysNames = RecordSetKeyNameArray(RecordSetsListTableName);
	For Each Name In KeysNames Do
		Dimensions.Insert(Name, CurrentData["RecordSetsList" + Name]);
	EndDo;

	If Dimensions.Property("Recorder") Then
		MetaRecorder = Metadata.FindByType(TypeOf(Dimensions.Recorder));
		If MetaRecorder = Undefined Then
			Result = Undefined;
		Else
			Result.FormName = MetaRecorder.FullName() + ".ObjectForm";
			Result.Key     = Dimensions.Recorder;
		EndIf;
	ElsIf Dimensions.Count() = 0 Then
		Result.FormName = RecordSetsListTableName + ".ListForm";
	Else
		Result.FormName = RecordSetsListTableName + ".RecordForm";
		Result.Key     = Details.Manager.CreateRecordKey(Dimensions);
	EndIf;

	Return Result;
EndFunction