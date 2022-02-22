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
		AddConstantRegistrationInList();
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
		DeleteRegistrationInListFilter();
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
		AddConstantRegistrationInList();
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
		AddRegistrationInReferenceList();
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
		AddRegistrationInReferenceList(True);
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
		DeleteRegistrationInListFilter();
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
Procedure ДобавитьРегистрациюКонстантыВСписке()
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

	ReportRegistrationResults(Flase, DeleteRegistrationAtServer(True, ExchangeNodeRef,
		AdditionalParameters.NamesList));

	Items.ConstantsList.Refresh();
	FillRegistrationCountInTreeRows();
EndProcedure

&AtClient
Procedure AddRegistrationInReferenceList(IsPick = False)
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
Procedure AddRegistrationInListFilter()
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

	Result = AddRegistrationAtServer(AdditionalParameters.NoAutoRegistration, 
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
				SetUpEmptyPage(Data.Description, Data.MetaFullName);
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
Procedure ИзменениеПометки(Строка)
	ЭлементДанных = MetadataTree.НайтиПоИдентификатору(Строка);
	ЭтотОбъектОбработки().ИзменениеПометки(ЭлементДанных);
EndProcedure

&AtServer
Procedure ПрочитатьДеревоМетаданных()
	Данные = ЭтотОбъектОбработки().СформироватьСтруктуруМетаданных(ExchangeNodeRef);
	
	// Удаляем строки, которые нельзя редактировать
	МетаДерево = Данные.Дерево;
	Для Каждого ЭлементСписка Из NamesOfMetadataToHide Цикл
		УдалитьСтрокиДереваЗначенийМетаданных(ЭлементСписка.Значение, МетаДерево.Строки);
	КонецЦикла;

	ЗначениеВРеквизитФормы(МетаДерево, "MetadataTree");
	MetadataAutoRecordStructure = Данные.СтруктураАвторегистрации;
	MetadataPresentationsStructure   = Данные.СтруктураПредставлений;
	MetadataNamesStructure            = Данные.СтруктураИмен;
EndProcedure

&AtServer
Procedure УдалитьСтрокиДереваЗначенийМетаданных(Знач МетаПолноеИмя, СтрокиДерева)
	Если ПустаяСтрока(МетаПолноеИмя) Тогда
		Возврат;
	КонецЕсли;
	
	// В текущем наборе
	Фильтр = Новый Структура("МетаПолноеИмя", МетаПолноеИмя);
	Для Каждого СтрокаУдаления Из СтрокиДерева.НайтиСтроки(Фильтр, Ложь) Цикл
		СтрокиДерева.Удалить(СтрокаУдаления);
	КонецЦикла;
	
	// И из оставшихся иерархически
	Для Каждого СтрокаДерева Из СтрокиДерева Цикл
		УдалитьСтрокиДереваЗначенийМетаданных(МетаПолноеИмя, СтрокаДерева.Строки);
	КонецЦикла;
EndProcedure

&AtServer
Procedure ФорматироватьКоличествоИзменений(Строка)
	Строка.ChangeCountString = Формат(Строка.КоличествоИзменений, "ЧН=") + " / " + Формат(
		Строка.КоличествоНеВыгруженных, "ЧН=");
EndProcedure

&AtServer
Procedure ЗаполнитьКоличествоРегистрацийВДереве()

	Данные = ЭтотОбъектОбработки().ПолучитьКоличествоИзменений(MetadataNamesStructure, ExchangeNodeRef);
	
	// Проставляем в дерево
	Фильтр = Новый Структура("МетаПолноеИмя, УзелОбмена", Неопределено, ExchangeNodeRef);
	Нули   = Новый Структура("КоличествоИзменений, КоличествоВыгруженных, КоличествоНеВыгруженных", 0, 0, 0);

	Для Каждого Корень Из MetadataTree.ПолучитьЭлементы() Цикл
		СуммаКорень = Новый Структура("КоличествоИзменений, КоличествоВыгруженных, КоличествоНеВыгруженных", 0, 0, 0);

		Для Каждого Группа Из Корень.ПолучитьЭлементы() Цикл
			СуммаГруппа = Новый Структура("КоличествоИзменений, КоличествоВыгруженных, КоличествоНеВыгруженных", 0, 0,
				0);

			СписокУзлов = Группа.ПолучитьЭлементы();
			Если СписокУзлов.Количество() = 0 И MetadataNamesStructure.Свойство(Группа.МетаПолноеИмя) Тогда
				// Коллекция узлов без узлов, просуммируем руками, авторегистрацию возьмем из структуры
				Для Каждого МетаИмя Из MetadataNamesStructure[Группа.МетаПолноеИмя] Цикл
					Фильтр.МетаПолноеИмя = МетаИмя;
					Найдено = Данные.НайтиСтроки(Фильтр);
					Если Найдено.Количество() > 0 Тогда
						Строка = Найдено[0];
						СуммаГруппа.КоличествоИзменений     = СуммаГруппа.КоличествоИзменений
							+ Строка.КоличествоИзменений;
						СуммаГруппа.КоличествоВыгруженных   = СуммаГруппа.КоличествоВыгруженных
							+ Строка.КоличествоВыгруженных;
						СуммаГруппа.КоличествоНеВыгруженных = СуммаГруппа.КоличествоНеВыгруженных
							+ Строка.КоличествоНеВыгруженных;
					КонецЕсли;
				КонецЦикла;

			Иначе
				// Считаем по каждому узлу
				Для Каждого Узел Из СписокУзлов Цикл
					Фильтр.МетаПолноеИмя = Узел.МетаПолноеИмя;
					Найдено = Данные.НайтиСтроки(Фильтр);
					Если Найдено.Количество() > 0 Тогда
						Строка = Найдено[0];
						ЗаполнитьЗначенияСвойств(Узел, Строка,
							"КоличествоИзменений, КоличествоВыгруженных, КоличествоНеВыгруженных");
						СуммаГруппа.КоличествоИзменений     = СуммаГруппа.КоличествоИзменений
							+ Строка.КоличествоИзменений;
						СуммаГруппа.КоличествоВыгруженных   = СуммаГруппа.КоличествоВыгруженных
							+ Строка.КоличествоВыгруженных;
						СуммаГруппа.КоличествоНеВыгруженных = СуммаГруппа.КоличествоНеВыгруженных
							+ Строка.КоличествоНеВыгруженных;
					Иначе
						ЗаполнитьЗначенияСвойств(Узел, Нули);
					КонецЕсли;

					ФорматироватьКоличествоИзменений(Узел);
				КонецЦикла;

			КонецЕсли;
			ЗаполнитьЗначенияСвойств(Группа, СуммаГруппа);

			СуммаКорень.КоличествоИзменений     = СуммаКорень.КоличествоИзменений + Группа.КоличествоИзменений;
			СуммаКорень.КоличествоВыгруженных   = СуммаКорень.КоличествоВыгруженных + Группа.КоличествоВыгруженных;
			СуммаКорень.КоличествоНеВыгруженных = СуммаКорень.КоличествоНеВыгруженных + Группа.КоличествоНеВыгруженных;

			ФорматироватьКоличествоИзменений(Группа);
		КонецЦикла;

		ЗаполнитьЗначенияСвойств(Корень, СуммаКорень);

		ФорматироватьКоличествоИзменений(Корень);
	КонецЦикла;

EndProcedure

&AtServer
Функция ИзменитьРегистрациюРезультатаЗапросаСервер(Команда, Адрес)

	Результат = ПолучитьИзВременногоХранилища(Адрес);
	Результат= Результат[Результат.ВГраница()];
	Данные = Результат.Выгрузить().ВыгрузитьКолонку("Ссылка");

	Если Команда Тогда
		Возврат ДобавитьРегистрациюНаСервере(Истина, ExchangeNodeRef, Данные);
	КонецЕсли;

	Возврат УдалитьРегистрациюНаСервере(Истина, ExchangeNodeRef, Данные);
КонецФункции

&AtServer
Функция КонтрольСсылокДляВыбораЗапросом(Адрес)

	Результат = ?(Адрес = Неопределено, Неопределено, ПолучитьИзВременногоХранилища(Адрес));
	Если ТипЗнч(Результат) = Тип("Массив") Тогда
		Результат = Результат[Результат.ВГраница()];
		Если Результат.Колонки.Найти("Ссылка") = Неопределено Тогда
			Возврат НСтр("ru='В последнем результате запроса отсутствует колонка ""Ссылка""'");
		КонецЕсли;
	Иначе
		Возврат НСтр("ru='Ошибка получения данных результата запроса'");
	КонецЕсли;

	Возврат "";
КонецФункции

&AtServer
Procedure НастроитьРедактированиеИзмененийСервер(ТекущаяСтрока)

	Данные = MetadataTree.НайтиПоИдентификатору(ТекущаяСтрока);
	Если Данные = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ИмяТаблицы   = Данные.МетаПолноеИмя;
	Наименование = Данные.Description;
	ТекущийОбъект   = ЭтотОбъектОбработки();

	Если ПустаяСтрока(ИмяТаблицы) Тогда
		Мета = Неопределено;
	Иначе
		Мета = ТекущийОбъект.МетаданныеПоПолномуИмени(ИмяТаблицы);
	КонецЕсли;

	Если Мета = Неопределено Тогда
		НастроитьПустуюСтраницу(Наименование, ИмяТаблицы);
		НовСтраница = Элементы.BlankPage;

	ИначеЕсли Мета = Метаданные.Константы Тогда
		// Все константы системы
		НастроитьСписокКонстант();
		НовСтраница = Элементы.ConstantsPage;

	ИначеЕсли ТипЗнч(Мета) = Тип("КоллекцияОбъектовМетаданных") Тогда
		// Все справочники, документы, и т.п.
		НастроитьПустуюСтраницу(Наименование, ИмяТаблицы);
		НовСтраница = Элементы.BlankPage;

	ИначеЕсли Метаданные.Константы.Содержит(Мета) Тогда
		// Одиночная константа
		НастроитьСписокКонстант(ИмяТаблицы, Наименование);
		НовСтраница = Элементы.ConstantsPage;

	ИначеЕсли Метаданные.Справочники.Содержит(Мета) Или Метаданные.Документы.Содержит(Мета)
		Или Метаданные.ПланыВидовХарактеристик.Содержит(Мета) Или Метаданные.ПланыСчетов.Содержит(Мета)
		Или Метаданные.ПланыВидовРасчета.Содержит(Мета) Или Метаданные.БизнесПроцессы.Содержит(Мета)
		Или Метаданные.Задачи.Содержит(Мета) Тогда
		// Ссылочный тип
		НастроитьСписокСсылок(ИмяТаблицы, Наименование);
		НовСтраница = Элементы.ReferencesListPage;

	Иначе
		// Проверим на набор записей
		Измерения = ТекущийОбъект.ИзмеренияНабораЗаписей(ИмяТаблицы);
		Если Измерения <> Неопределено Тогда
			НастроитьНаборЗаписей(ИмяТаблицы, Измерения, Наименование);
			НовСтраница = Элементы.RecordSetPage;
		Иначе
			НастроитьПустуюСтраницу(Наименование, ИмяТаблицы);
			НовСтраница = Элементы.BlankPage;
		КонецЕсли;

	КонецЕсли;

	Элементы.ConstantsPage.Видимость    = Ложь;
	Элементы.ReferencesListPage.Видимость = Ложь;
	Элементы.RecordSetPage.Видимость = Ложь;
	Элементы.BlankPage.Видимость       = Ложь;

	Элементы.ObjectsListOptions.ТекущаяСтраница = НовСтраница;
	НовСтраница.Видимость = Истина;

	НастроитьВидимостьКомандОбщегоМеню();
EndProcedure

// Вывод изменений для ссылочного типа (cправочник, документ, план видов характеристик, 
// план счетов, вид расчета, бизнес-процессы, задачи)
//
&AtServer
Procedure НастроитьСписокСсылок(ИмяТаблицы, Наименование)

	RefsList.ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ТаблицаИзменений.НомерСообщения КАК НомерСообщения,
	|	ТаблицаИзменений.Ссылка КАК Ссылка,
	|	ВЫБОР
	|		КОГДА ТаблицаИзменений.НомерСообщения ЕСТЬ NULL
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК НеВыгружалось
	|ИЗ
	|	" + ИмяТаблицы + ".Изменения КАК ТаблицаИзменений
	|ГДЕ
	|	ТаблицаИзменений.Узел = &ВыбранныйУзел";	

	RefsList.Параметры.УстановитьЗначениеПараметра("ВыбранныйУзел", ExchangeNodeRef);
//	RefsList.ОсновнаяТаблица = ИмяТаблицы;
	RefsList.ДинамическоеСчитываниеДанных = Истина;
	
	// Представление объекта
	Мета = ЭтотОбъектОбработки().МетаданныеПоПолномуИмени(ИмяТаблицы);
	ТекЗаголовок = Мета.ПредставлениеОбъекта;
	Если ПустаяСтрока(ТекЗаголовок) Тогда
		ТекЗаголовок = Наименование;
	КонецЕсли;
	Элементы.RefsListRefPresentation.Заголовок = ТекЗаголовок;
EndProcedure

// Вывод изменений для констант
//
&AtServer
Procedure НастроитьСписокКонстант(ИмяТаблицы = Неопределено, Наименование = "")

	Если ИмяТаблицы = Неопределено Тогда
		// Все константы
		Имена = MetadataNamesStructure.Константы;
		Представления = MetadataPresentationsStructure.Константы;
		Авторегистрация = MetadataAutoRecordStructure.Константы;
	Иначе
		Имена = Новый Массив;
		Имена.Добавить(ИмяТаблицы);
		Представления = Новый Массив;
		Представления.Добавить(Наименование);
		Индекс = MetadataNamesStructure.Константы.Найти(ИмяТаблицы);
		Авторегистрация = Новый Массив;
		Авторегистрация.Добавить(MetadataAutoRecordStructure.Константы[Индекс]);
	КонецЕсли;
	
	// И помнить про ограничение на количество таблиц
	Текст = "";
	Для Индекс = 0 По Имена.ВГраница() Цикл
		Имя = Имена[Индекс];
		Текст = Текст + ?(Текст = "", "ВЫБРАТЬ", "ОБЪЕДИНИТЬ ВСЕ ВЫБРАТЬ") + "
																			 |	" + Формат(Авторегистрация[Индекс],
			"ЧН=; ЧГ=") + " КАК ИндексКартинкиАвторегистрация,
						  |	2                                                   КАК PictureIndex,
						  |
						  |	""" + ЗакавычитьСтроку(Представления[Индекс]) + """ КАК Description,
																			   |	""" + Имя
			+ """ КАК МетаПолноеИмя,
			  |
			  |	ТаблицаИзменений.НомерСообщения КАК НомерСообщения,
			  |	ВЫБОР 
			  |		КОГДА ТаблицаИзменений.НомерСообщения ЕСТЬ NULL ТОГДА ИСТИНА ИНАЧЕ ЛОЖЬ
			  |	КОНЕЦ КАК НеВыгружалось
			  |ИЗ
			  |	" + Имя + ".Изменения КАК ТаблицаИзменений
							 |ГДЕ
							 |	ТаблицаИзменений.Узел=&ВыбранныйУзел
							 |";
	КонецЦикла;

	ConstantsList.ТекстЗапроса = "
								  |ВЫБРАТЬ
								  |	ИндексКартинкиАвторегистрация, PictureIndex, МетаПолноеИмя, НеВыгружалось,
								  |	Description, НомерСообщения
								  |
								  |{ВЫБРАТЬ
								  |	ИндексКартинкиАвторегистрация, PictureIndex, 
								  |	Description, МетаПолноеИмя, 
								  |	НомерСообщения, НеВыгружалось
								  |}
								  |
								  |ИЗ (" + Текст + ") Данные
												   |
												   |{ГДЕ
												   |	Description, НомерСообщения, НеВыгружалось
												   |}
												   |";

	ЭлементыСписка = ConstantsList.Порядок.Элементы;
	Если ЭлементыСписка.Количество() = 0 Тогда
		Элемент = ЭлементыСписка.Добавить(Тип("ЭлементПорядкаКомпоновкиДанных"));
		Элемент.Поле = Новый ПолеКомпоновкиДанных("Description");
		Элемент.Использование = Истина;
	КонецЕсли;

	ConstantsList.Параметры.УстановитьЗначениеПараметра("ВыбранныйУзел", ExchangeNodeRef);
	ConstantsList.ДинамическоеСчитываниеДанных = Истина;
EndProcedure	

// Вывод заглушки с пустой страницей.
&AtServer
Procedure НастроитьПустуюСтраницу(Наименование, ИмяТаблицы = Неопределено)

	Если ИмяТаблицы = Неопределено Тогда
		ТекстКоличеств = "";
	Иначе
		Дерево = РеквизитФормыВЗначение("MetadataTree");
		Строка = Дерево.Строки.Найти(ИмяТаблицы, "МетаПолноеИмя", Истина);
		Если Строка <> Неопределено Тогда
			ТекстКоличеств = НСтр("ru='Зарегистрировано объектов: %1
								  |Выгружено объектов: %2
								  |Не выгружено объектов: %3
								  |'");

			ТекстКоличеств = СтрЗаменить(ТекстКоличеств, "%1", Формат(Строка.КоличествоИзменений, "ЧДЦ=0; ЧН="));
			ТекстКоличеств = СтрЗаменить(ТекстКоличеств, "%2", Формат(Строка.КоличествоВыгруженных, "ЧДЦ=0; ЧН="));
			ТекстКоличеств = СтрЗаменить(ТекстКоличеств, "%3", Формат(Строка.КоличествоНевыгруженных, "ЧДЦ=0; ЧН="));
		КонецЕсли;
	КонецЕсли;

	Текст = НСтр("ru='%1.
				 |
				 |%2
				 |Для регистрации или отмены регистрации обмена данными на узле
				 |""%3""
				 |выберите тип объекта слева в дереве метаданных и воспользуйтесь
				 |командами ""Зарегистрировать"" или ""Отменить регистрацию""'");

	Текст = СтрЗаменить(Текст, "%1", Наименование);
	Текст = СтрЗаменить(Текст, "%2", ТекстКоличеств);
	Текст = СтрЗаменить(Текст, "%3", ExchangeNodeRef);
	Элементы.BlankPageDecoration.Заголовок = Текст;
EndProcedure

// Вывод изменений для наборов записей
//
&AtServer
Procedure НастроитьНаборЗаписей(ИмяТаблицы, Измерения, Наименование)

	ТекстВыбора = "";
	Префикс     = "RecordSetsList";
	Для Каждого Строка Из Измерения Цикл
		Имя = Строка.Имя;
		ТекстВыбора = ТекстВыбора + ",ТаблицаИзменений." + Имя + " КАК " + Префикс + Имя + Символы.ПС;
		// Чтобы не наступить на измерение "НомерСообщения" или "НеВыгружалось"
		Строка.Имя = Префикс + Имя;
	КонецЦикла;

	RecordSetsList.ТекстЗапроса = "
										|ВЫБРАТЬ
										|	ТаблицаИзменений.НомерСообщения КАК НомерСообщения,
										|	ВЫБОР 
										|		КОГДА ТаблицаИзменений.НомерСообщения ЕСТЬ NULL ТОГДА ИСТИНА ИНАЧЕ ЛОЖЬ
										|	КОНЕЦ КАК НеВыгружалось
										|
										|	" + ТекстВыбора + "
															   |ИЗ
															   |	" + ИмяТаблицы + ".Изменения КАК ТаблицаИзменений
																					 |ГДЕ
																					 |	ТаблицаИзменений.Узел = &ВыбранныйУзел
																					 |";
	RecordSetsList.Параметры.УстановитьЗначениеПараметра("ВыбранныйУзел", ExchangeNodeRef);
	
	// Добавляем в группу измерений
	ЭтотОбъектОбработки().ДобавитьКолонкиВТаблицуФормы(
		Элементы.RecordSetsList, "НомерСообщения, НеВыгружалось, 
									   |Порядок, Отбор, Группировка, СтандартнаяКартинка, Параметры, УсловноеОформление",
		Измерения, Элементы.RecordSetsListDimensionsGroup);
	RecordSetsList.ДинамическоеСчитываниеДанных = Истина;
	RecordSetsListTableName = ИмяТаблицы;
EndProcedure

// Общий отбор по полю "НомерСообщения"
//
&AtServer
Procedure SetFilterByMessageNumber(ДинамоСписок, Вариант)

	Поле = Новый ПолеКомпоновкиДанных("НеВыгружалось");
	// Ищем свое поле, попутно отключаем все по нему
	ЭлементыСписка = ДинамоСписок.Отбор.Элементы;
	Индекс = ЭлементыСписка.Количество();
	Пока Индекс > 0 Цикл
		Индекс = Индекс - 1;
		Элемент = ЭлементыСписка[Индекс];
		Если Элемент.ЛевоеЗначение = Поле Тогда
			ЭлементыСписка.Удалить(Элемент);
		КонецЕсли;
	КонецЦикла;

	ЭлементОтбора = ЭлементыСписка.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Поле;
	ЭлементОтбора.ВидСравнения  = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.Использование = Ложь;
	ЭлементОтбора.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный;

	Если Вариант = 1 Тогда 		// Выгруженные
		ЭлементОтбора.ПравоеЗначение = Ложь;
		ЭлементОтбора.Использование  = Истина;

	ИначеЕсли Вариант = 2 Тогда	// Не выгруженные
		ЭлементОтбора.ПравоеЗначение = Истина;
		ЭлементОтбора.Использование  = Истина;

	КонецЕсли;

EndProcedure

&AtServer
Procedure НастроитьВидимостьКомандОбщегоМеню()

	ТекСтр = Элементы.ObjectsListOptions.ТекущаяСтраница;

	Если ТекСтр = Элементы.ConstantsPage Тогда
		Элементы.FormAddRegistrationForSingleObject.Доступность = Истина;
		Элементы.FormAddRegistrationFilter.Доступность         = Ложь;
		Элементы.FormDeleteRegistrationForSingleObject.Доступность  = Истина;
		Элементы.FormDeleteRegistrationFilter.Доступность          = Ложь;

	ИначеЕсли ТекСтр = Элементы.ReferencesListPage Тогда
		Элементы.FormAddRegistrationForSingleObject.Доступность = Истина;
		Элементы.FormAddRegistrationFilter.Доступность         = Истина;
		Элементы.FormDeleteRegistrationForSingleObject.Доступность  = Истина;
		Элементы.FormDeleteRegistrationFilter.Доступность          = Истина;

	ИначеЕсли ТекСтр = Элементы.RecordSetPage Тогда
		Элементы.FormAddRegistrationForSingleObject.Доступность = Истина;
		Элементы.FormAddRegistrationFilter.Доступность         = Ложь;
		Элементы.FormDeleteRegistrationForSingleObject.Доступность  = Истина;
		Элементы.FormDeleteRegistrationFilter.Доступность          = Ложь;

	Иначе
		Элементы.FormAddRegistrationForSingleObject.Доступность = Ложь;
		Элементы.FormAddRegistrationFilter.Доступность         = Ложь;
		Элементы.FormDeleteRegistrationForSingleObject.Доступность  = Ложь;
		Элементы.FormDeleteRegistrationFilter.Доступность          = Ложь;

	КонецЕсли;
EndProcedure

&AtServer
Функция МассивИменКлючейНабораЗаписей(ИмяТаблицы, ПрефиксИмен = "")
	Результат = Новый Массив;
	Измерения = ЭтотОбъектОбработки().ИзмеренияНабораЗаписей(ИмяТаблицы);
	Если Измерения <> Неопределено Тогда
		Для Каждого Строка Из Измерения Цикл
			Результат.Добавить(ПрефиксИмен + Строка.Имя);
		КонецЦикла;
	КонецЕсли;
	Возврат Результат;
КонецФункции

&AtServer
Функция МенеджерПоМетаданным(ИмяТаблицы)
	Описание = ЭтотОбъектОбработки().ХарактеристикиПоМетаданным(ИмяТаблицы);
	Если Описание <> Неопределено Тогда
		Возврат Описание.Менеджер;
	КонецЕсли;
	Возврат Неопределено;
КонецФункции

&AtServer
Функция ТекстСериализации(Сериализация)

	Текст = Новый ТекстовыйДокумент;

	Запись = Новый ЗаписьXML;
	Для Каждого Элемент Из Сериализация Цикл
		Запись.УстановитьСтроку("UTF-16");
		Значение = Неопределено;

		Если Элемент.ФлагТипа = 1 Тогда
			// Метаданные
			Менеджер = МенеджерПоМетаданным(Элемент.Данные);
			Значение = Менеджер.СоздатьМенеджерЗначения();

		ИначеЕсли Элемент.ФлагТипа = 2 Тогда
			// Набор данных с отбором
			Менеджер = МенеджерПоМетаданным(RecordSetsListTableName);
			Значение = Менеджер.СоздатьНаборЗаписей();
			Отбор = Значение.Отбор;
			Для Каждого ИмяЗначение Из Элемент.Данные Цикл
				Отбор[ИмяЗначение.Ключ].Установить(ИмяЗначение.Значение);
			КонецЦикла;
			Значение.Прочитать();

		ИначеЕсли Элемент.ФлагТипа = 3 Тогда
			// Ссылка
			Значение = Элемент.Данные.ПолучитьОбъект();
			Если Значение = Неопределено Тогда
				Значение = Новый УдалениеОбъекта(Элемент.Данные);
			КонецЕсли;
		КонецЕсли;

		ЗаписатьXML(Запись, Значение);
		Текст.ДобавитьСтроку(Запись.Закрыть());
	КонецЦикла;

	Возврат Текст;
КонецФункции

&AtServer
Функция УдалитьРегистрациюНаСервере(БезУчетаАвторегистрации, Узел, Удаляемые, ИмяТаблицы = Неопределено)
	Возврат ЭтотОбъектОбработки().ИзменитьРегистрациюНаСервере(Ложь, БезУчетаАвторегистрации, Узел, Удаляемые, ИмяТаблицы);
КонецФункции

&AtServer
Функция ДобавитьРегистрациюНаСервере(БезУчетаАвторегистрации, Узел, Добавляемые, ИмяТаблицы = Неопределено)
	Возврат ЭтотОбъектОбработки().ИзменитьРегистрациюНаСервере(Истина, БезУчетаАвторегистрации, Узел, Добавляемые, ИмяТаблицы);
КонецФункции

&AtServer
Функция ИзменитьНомерСообщенияНаСервере(Узел, НомерСообщения, Данные, ИмяТаблицы = Неопределено)
	Возврат ЭтотОбъектОбработки().ИзменитьРегистрациюНаСервере(НомерСообщения, Истина, Узел, Данные, ИмяТаблицы);
КонецФункции

&AtServer
Функция ПолучитьОписаниеВыбранныхМетаданных(БезУчетаАвторегистрации, МетаИмяГруппа = Неопределено,
	МетаИмяУзел = Неопределено)

	Если МетаИмяГруппа = Неопределено И МетаИмяУзел = Неопределено Тогда
		// Не указано ничего
		Текст = НСтр("ru='все объекты %1 по выбранной иерархии вида'");

	ИначеЕсли МетаИмяГруппа <> Неопределено И МетаИмяУзел = Неопределено Тогда
		// Указана только группа, рассматриваем ее как Description группы
		Текст = "%2 %1";

	ИначеЕсли МетаИмяГруппа = Неопределено И МетаИмяУзел <> Неопределено Тогда
		// Указан только узел, рассматриваем как много выделенных объектов
		Текст = НСтр("ru='все объекты %1 по выбранной иерархии вида'");

	Иначе
		// Указаны и группа и узел, рассматриваем как имена метаданных
		Текст = НСтр("ru='все объекты типа ""%3"" %1'");

	КонецЕсли;

	Если БезУчетаАвторегистрации Тогда
		ТекстФлага = "";
	Иначе
		ТекстФлага = НСтр("ru='с признаком авторегистрации'");
	КонецЕсли;

	Представление = "";
	Для Каждого КлючЗначение Из MetadataPresentationsStructure Цикл
		Если КлючЗначение.Ключ = МетаИмяГруппа Тогда
			Индекс = MetadataNamesStructure[МетаИмяГруппа].Найти(МетаИмяУзел);
			Представление = ?(Индекс = Неопределено, "", КлючЗначение.Значение[Индекс]);
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Текст = СтрЗаменить(Текст, "%1", ТекстФлага);
	Текст = СтрЗаменить(Текст, "%2", НРег(МетаИмяГруппа));
	Текст = СтрЗаменить(Текст, "%3", Представление);

	Возврат СокрЛП(Текст);
КонецФункции

&AtServer
Функция ПолучитьИменаМетаданныхТекущейСтроки(БезУчетаАвторегистрации)

	Строка = MetadataTree.НайтиПоИдентификатору(Элементы.MetadataTree.ТекущаяСтрока);
	Если Строка = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	Результат = Новый Структура("МетаИмена, Описание", Новый Массив, ПолучитьОписаниеВыбранныхМетаданных(
		БезУчетаАвторегистрации));
	МетаИмя = Строка.МетаПолноеИмя;
	Если ПустаяСтрока(МетаИмя) Тогда
		Результат.МетаИмена.Добавить(Неопределено);
	Иначе
		Результат.МетаИмена.Добавить(МетаИмя);

		Родитель = Строка.ПолучитьРодителя();
		МетаРодительИмя = Родитель.МетаПолноеИмя;
		Если ПустаяСтрока(МетаРодительИмя) Тогда
			Результат.Описание = ПолучитьОписаниеВыбранныхМетаданных(БезУчетаАвторегистрации, Строка.Description);
		Иначе
			Результат.Описание = ПолучитьОписаниеВыбранныхМетаданных(БезУчетаАвторегистрации, МетаРодительИмя, МетаИмя);
		КонецЕсли;
	КонецЕсли;

	Возврат Результат;
КонецФункции

&AtServer
Функция ПолучитьВыбранныеИменаМетаданных(БезУчетаАвторегистрации)

	Результат = Новый Структура("МетаИмена, Описание", Новый Массив, ПолучитьОписаниеВыбранныхМетаданных(
		БезУчетаАвторегистрации));

	Для Каждого Корень Из MetadataTree.ПолучитьЭлементы() Цикл

		Если Корень.Check = 1 Тогда
			Результат.МетаИмена.Добавить(Неопределено);
			Возврат Результат;
		КонецЕсли;

		КолвоЧастичных = 0;
		КолвоГрупп     = 0;
		КолвоУзлов     = 0;
		Для Каждого Группа Из Корень.ПолучитьЭлементы() Цикл

			Если Группа.Check = 0 Тогда
				Продолжить;
			ИначеЕсли Группа.Check = 1 Тогда
				//	Весь группа целиком, смотрим откуда выбирать значения
				КолвоГрупп = КолвоГрупп + 1;
				ОписаниеГруппы = ПолучитьОписаниеВыбранныхМетаданных(БезУчетаАвторегистрации, Группа.Наименование);

				Если Группа.ПолучитьЭлементы().Количество() = 0 Тогда
					// Пробуем из структуры имен метаданных, считаем все отмеченными
					//@skip-warning
					МассивПредставлений = MetadataPresentationsStructure[Группа.МетаПолноеИмя];
					МассивАвто          = MetadataAutoRecordStructure[Группа.МетаПолноеИмя];
					МассивИмен          = MetadataNamesStructure[Группа.МетаПолноеИмя];
					Для Индекс = 0 По МассивИмен.ВГраница() Цикл
						Если БезУчетаАвторегистрации Или МассивАвто[Индекс] = 2 Тогда
							Результат.МетаИмена.Добавить(МассивИмен[Индекс]);
							ОписаниеУзла = ПолучитьОписаниеВыбранныхМетаданных(БезУчетаАвторегистрации,
								Группа.МетаПолноеИмя, МассивИмен[Индекс]);
						КонецЕсли;
					КонецЦикла;

					Продолжить;
				КонецЕсли;

			Иначе
				КолвоЧастичных = КолвоЧастичных + 1;
			КонецЕсли;

			Для Каждого Узел Из Группа.ПолучитьЭлементы() Цикл
				Если Узел.Check = 1 Тогда
					// Узел.AutoRegistration=2 -> разрешена
					Если БезУчетаАвторегистрации Или Узел.AutoRegistration = 2 Тогда
						Результат.МетаИмена.Добавить(Узел.МетаПолноеИмя);
						ОписаниеУзла = ПолучитьОписаниеВыбранныхМетаданных(БезУчетаАвторегистрации,
							Группа.МетаПолноеИмя, Узел.МетаПолноеИмя);
						КолвоУзлов = КолвоУзлов + 1;
					КонецЕсли;
				КонецЕсли;
			КонецЦикла
			;

		КонецЦикла;

		Если КолвоГрупп = 1 И КолвоЧастичных = 0 Тогда
			Результат.Описание = ОписаниеГруппы;
		ИначеЕсли КолвоГрупп = 0 И КолвоУзлов = 1 Тогда
			Результат.Описание = ОписаниеУзла;
		КонецЕсли;

	КонецЦикла;

	Возврат Результат;
КонецФункции

&AtServer
Функция ПрочитатьНомераСообщений()
	РеквизитыЗапроса = "НомерОтправленного, НомерПринятого";
	Данные = ЭтотОбъектОбработки().ПолучитьПараметрыУзлаОбмена(ExchangeNodeRef, РеквизитыЗапроса);
	Если Данные = Неопределено Тогда
		Возврат Новый Структура(РеквизитыЗапроса)
	КонецЕсли
	;
	Возврат Данные;
КонецФункции

&AtServer
Procedure ОбработатьЗапретИзмененияУзла()
	ОперацииРазрешены = Не SelectExchangeNodeProhibited;

	Если ОперацииРазрешены Тогда
		Элементы.ExchangeNodeRef.Видимость = Истина;
		Заголовок = НСтр("ru='Регистрация изменений для обмена данными'");
	Иначе
		Элементы.ExchangeNodeRef.Видимость = Ложь;
		Заголовок = СтрЗаменить(НСтр("ru='Регистрация изменений для обмена с  ""%1""'"), "%1", Строка(ExchangeNodeRef));
	КонецЕсли;

	Элементы.FormOpenNodeRegistrationForm.Видимость = ОперацииРазрешены;

	Элементы.ConstantsListContextMenuOpenNodeRegistrationForm.Видимость       = ОперацииРазрешены;
	Элементы.RefsListContextMenuOpenNodeRegistrationForm.Видимость         = ОперацииРазрешены;
	Элементы.RecordSetsListContextMenuOpenNodeRegistrationForm.Видимость = ОперацииРазрешены;
EndProcedure

&AtServer
Функция ПроконтролироватьНастройки()
	Результат = Истина;
	
	// Проверим на допустимость узла пришедшего из параметра или настроек
	ТекущийОбъект = ЭтотОбъектОбработки();
	Если ExchangeNodeRef <> Неопределено И ПланыОбмена.ТипВсеСсылки().СодержитТип(ТипЗнч(ExchangeNodeRef)) Тогда
		ДопустимыеУзлыОбмена = ТекущийОбъект.СформироватьДеревоУзлов();
		//@skip-warning
		ИмяПлана = ExchangeNodeRef.Метаданные().Имя;
		Если ДопустимыеУзлыОбмена.Строки.Найти(ИмяПлана, "ПланОбменаИмя", Истина) = Неопределено Тогда
			// Узел неверного плана обмена
			ExchangeNodeRef = Неопределено;
			Результат = Ложь;
		ИначеЕсли ExchangeNodeRef = ПланыОбмена[ИмяПлана].ЭтотУзел() Тогда
			// Этот узел
			ExchangeNodeRef = Неопределено;
			Результат = Ложь;
		КонецЕсли;
	КонецЕсли;

	Если ЗначениеЗаполнено(ExchangeNodeRef) Тогда
		ОбработкаВыбораУзлаОбмена();
	КонецЕсли;
	ОбработатьЗапретИзмененияУзла();
	
	// Зависимость настроек
	SetFilterByMessageNumber(ConstantsList, FilterByMessageNumberOption);
	SetFilterByMessageNumber(RefsList, FilterByMessageNumberOption);
	SetFilterByMessageNumber(RecordSetsList, FilterByMessageNumberOption);

	Возврат Результат;
КонецФункции

&AtServer
Функция СтруктураКлючаНабораЗаписей(Знач ТекущиеДанные)
	Описание  = ЭтотОбъектОбработки().ХарактеристикиПоМетаданным(RecordSetsListTableName);

	Если Описание = Неопределено Тогда
		// Неизвестный источник
		Возврат Неопределено;
	КонецЕсли;

	Результат = Новый Структура("Ключ, ИмяФормы");

	Измерения = Новый Структура;
	ИменаКлючей = МассивИменКлючейНабораЗаписей(RecordSetsListTableName);
	Для Каждого Имя Из ИменаКлючей Цикл
		Измерения.Вставить(Имя, ТекущиеДанные["RecordSetsList" + Имя]);
	КонецЦикла;

	Если Измерения.Свойство("Регистратор") Тогда
		МетаРегистратора = Метаданные.НайтиПоТипу(ТипЗнч(Измерения.Регистратор));
		Если МетаРегистратора = Неопределено Тогда
			Результат = Неопределено;
		Иначе
			Результат.ИмяФормы = МетаРегистратора.ПолноеИмя() + ".ФормаОбъекта";
			Результат.Ключ     = Измерения.Регистратор;
		КонецЕсли;
	ИначеЕсли Измерения.Количество() = 0 Тогда
		// Вырожденный набор записей
		Результат.ИмяФормы = RecordSetsListTableName + ".ФормаСписка";
	Иначе
		Результат.ИмяФормы = RecordSetsListTableName + ".ФормаЗаписи";
		Результат.Ключ     = Описание.Менеджер.СоздатьКлючЗаписи(Измерения);
	КонецЕсли;

	Возврат Результат;
КонецФункции