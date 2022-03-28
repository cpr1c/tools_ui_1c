&AtClient
Var mOrdinaryApplicationObjects;

&AtClient
Var mCurrentTreeObject;

&AtClient
Var mDescriptionAccessRights;

&AtClient
Var mFavoriteID;

&AtClient
Var mClusterParameters;
&AtServer
Function vGetProcessor()
	Return FormAttributeToValue("Object");
EndFunction
&AtClient
Procedure vShowMessageBox(Text)
	ShowMessageBox( , Text, 20);
EndProcedure

&AtClient
Procedure vShowQueryBox(QueryText, ProcedureName, AdditionalParameters = Undefined)
	ShowQueryBox(New NotifyDescription(ProcedureName, ThisForm, AdditionalParameters), QueryText,
		QuestionDialogMode.YesNoCancel, 20);
EndProcedure

&AtClient
Procedure vOperationNotSupportedForWebClient()
	vShowMessageBox("ru = 'Для Web-клиента данная операция не поддерживается!';en = 'The operation is not supported for a web-client!'");
EndProcedure

&AtServerNoContext
Procedure vFillInFormContext(_FormContext)
	_FormContext.Insert("SubsystemVersions", (Metadata.InformationRegisters.Find("SubsystemVersions") <> Undefined));
	_FormContext.Insert("ExclusiveMode", ExclusiveMode());
EndProcedure

&AtServerNoContext
Function vIsAdministratorRights()
	Return AccessRight("Administration", Metadata);
EndFunction

&AtServerNoContext
Function vGetUserId(Val Name)
	vUser = InfoBaseUsers.FindByName(Name);

	Return ?(vUser = Undefined, "", String(vUser.UUID));
EndFunction

&AtClientAtServerNoContext
Function vValueToArray(Val Value)
	Array = New Array;
	Array.Add(Value);

	Return Array;
EndFunction

&AtServer
Procedure SetConditionalAppearance()
	ThisForm.ConditionalAppearance.Items.Clear();

	AppearanceItem = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("ObjectsTree.FullName");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = "Configuration";
	AppearanceItem.Appearance.SetParameterValue("Font", New Font(Items.ServiceTree.Font, , , True));
	AppearanceItem.Fields.Items.Add().Field = New DataCompositionField("ObjectsTreeName");

	AppearanceItem = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("ObjectsTree.NodeType");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = 1;
	AppearanceItem.Appearance.SetParameterValue("Text", WebColors.DarkBlue);
	AppearanceItem.Fields.Items.Add().Field = New DataCompositionField("ObjectsTreeName");

	AppearanceItem = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("ServiceTree.IsGroup");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = True;
	AppearanceItem.Appearance.SetParameterValue("Font", New Font(Items.ServiceTree.Font, , , True));
	AppearanceItem.Fields.Items.Add().Field = New DataCompositionField("ServiceTreePresentation");

	AppearanceItem = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("ServiceTree.Enabled");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = False;
	AppearanceItem.Appearance.SetParameterValue("Text", New Color(83, 106, 194));
	AppearanceItem.Fields.Items.Add().Field = New DataCompositionField("ServiceTreePresentation");

	AppearanceItem = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("VerifiableRightsTable.Mark");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = True;
	AppearanceItem.Appearance.SetParameterValue("Font", New Font(Items.VerifiableRightsTable.Font, , ,
		True));
	AppearanceItem.Fields.Items.Add().Field = New DataCompositionField("VerifiableRightsTableMetadataObject");
	AppearanceItem.Fields.Items.Add().Field = New DataCompositionField("VerifiableRightsTableRight");

	AppearanceItem = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("_SessionList.CurrentSession");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = True;
	AppearanceItem.Appearance.SetParameterValue("Text", WebColors.Blue);
	AppearanceItem.Fields.Items.Add().Field = New DataCompositionField("_SessionList");

	AppearanceItem = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = AppearanceItem.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("_ConnectionsList.ТекущееСоединение");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = True;
	AppearanceItem.Appearance.SetParameterValue("Text", WebColors.Blue);
	AppearanceItem.Fields.Items.Add().Field = New DataCompositionField("_ConnectionsList");

EndProcedure

&AtClient
Function vFormStructureOfObjectPropertiesFormSettings()
	_Structure = New Structure("_ShowObjectSubscribtion, _ShowObjectSubsystems, _ShowCommonObjectCommands, _ShowExternalObjectCommands, _ShowStorageStructureInTermsOf1C");
	FillPropertyValues(_Structure, ThisForm);

	Return _Structure;
EndFunction

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	PathToForms = vGetProcessor().Metadata().FullName() + ".Form.";

	pIsAdministratorRights = vIsAdministratorRights();
	WaitingTimeBeforePasswordRecovery=20;
	
	//Items.SettingsPage.Visible = ложь;
	Items.StorageStructurePage.Visible = False;
	Items.ObjectRightPages.Visible = False;
	Items._DisplayObjectsRights.Enabled = pIsAdministratorRights;
	Items.ObjectsTreeForAdministrators.Enabled = pIsAdministratorRights;
	Items.DBUsers.Visible = pIsAdministratorRights;
	Items._SessionList_FinishSessions.Enabled = pIsAdministratorRights;
	Items.SessionsPage.Visible = AccessRight("ActiveUsers", Metadata);
	Items._SessionList_FinishSessions.Enabled = pIsAdministratorRights;

	Items.ConfigurationExtensions.Visible = False;
	//Items.ConfigurationExtensions.Visible = vCheckType("ConfigurationExtension");

	_FormContext = New Structure;
	vFillInFormContext(_FormContext);
	vFillServiceTree();

	_FavoritesContent = New Structure("Version, Data", 1, New Array);

	SetConditionalAppearance();

	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing,
		Items.ObjectsTree.CommandBar);

EndProcedure

&AtServer
Procedure OnLoadDataFromSettingsAtServer(Settings)
	If _ShowStandardSettings Then
		Items.DefaultSettingsPage.Visible = True;
	EndIf;

	If _ShowTablesAndIndexesDB Then
		Items.StorageStructurePage.Visible = True;
	EndIf;

	Value = Settings["_FavoritesContent"];
	If Value <> Undefined Then
		If Not Value.Property("Version") Then
			Value.Insert("Version", 1);
		EndIf;
		_FavoritesContent = Value;

		TreeLines = ObjectsTree.GetItems();
		If TreeLines.Count() <> 0 Then
			// re-fill favorites
			For Each TreeSection In TreeLines Do
				If TreeSection.FullName = "Favorites" Then
					TreeSection.GetItems().Clear();
					For Each Item In _FavoritesContent.Data Do
						FillPropertyValues(TreeSection.GetItems().Add(), Item);
					EndDo;
				EndIf;
			EndDo;
		EndIf;
	EndIf;

	Items._DBUserListListOfRoles.Visible = _ShowUserRolesList;
EndProcedure

&AtServer
Procedure OnSaveDataInSettingsAtServer(Settings)
	// let's form favorites
	For Each TreeSection In ObjectsTree.GetItems() Do
		If TreeSection.FullName = "Favorites" Then
			ListOfTreeFields = vListOfTreeFields();
			_FavoritesContent.Data.Clear();
			For Each TreeLine In TreeSection.GetItems() Do
				_Structure = New Structure(ListOfTreeFields);
				FillPropertyValues(_Structure, TreeLine);
				_FavoritesContent.Data.Add(_Structure);
			EndDo;
			Break;
		EndIf;
	EndDo;

	Settings.Insert("_FavoritesContent", _FavoritesContent);
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	mCurrentTreeObject = "";

	vFormDescriptionOfAccessRights();
	vFillAccessRights();

	mOrdinaryApplicationObjects = New Structure("Constant, Catalog, Document, DocumentJournal, ChartOfCharacteristicTypes, ChartOfCalculationTypes, ChartOfAccounts
												|, Processing, Report, InformationRegister, AccumulationRegister, AccountingRegister, CalculationRegister, BusinessProcess, Task
												|, ExchangePlan");

	TreeLines = ObjectsTree.GetItems();
	TreeLines.Clear();

	TreeLine = TreeLines.Add();
	FillPropertyValues(TreeLine, vFormConfigurationNode());
	TreeLine.NodeType = 1;
	
	
	// избранное
	TreeLine = TreeLines.Add();
	TreeLine.Name = "Favorites...";
	TreeLine.NodeType = "Favorites";
	TreeLine.NodeType = 1;
	TreeLine.FullName = "Favorites";
	mFavoriteID = TreeLine.GetID();

	For Each Item In _FavoritesContent.Data Do
		НС = TreeLine.GetItems().Add();
		FillPropertyValues(НС, Item);
	EndDo;
	TreeLine = TreeLines.Add();
	TreeLine.Name = "Common";
	TreeLine.NodeType = "SectionGroupMD";
	TreeLine.NodeType = 1;
	TreeLine.GetItems().Add();

	SectionStructure = New Structure("Constants, Catalogs, Documents, DocumentJournals, Enums, ChartsOfCharacteristicTypes, ChartsOfCalculationTypes, ChartsOfAccounts
								   |, DataProcessors, Reports, InformationRegisters, AccumulationRegisters, AccountingRegisters, CalculationRegisters, BusinessProcesses, Tasks");

	vCalculateNumberOfObjectsMD(SectionStructure);

	For Each Item In SectionStructure Do
		TreeLine = TreeLines.Add();
		TreeLine.Name = Item.Key;
		TreeLine.Name = Item.Key + " (" + Item.Value + ")";
		TreeLine.NodeType = "SectionMD";
		TreeLine.NodeType = 1;
		TreeLine.GetItems().Add();
	EndDo;

	_StorageAddresses = New Structure("RegisterRecords, Subscriptions, Commands, CommonCommands, Subsystems, RolesAndUsers");
	_StorageAddresses.RegisterRecords = PutToTempStorage(-1, UUID);
	_StorageAddresses.Subscriptions = PutToTempStorage(-1, UUID);
	_StorageAddresses.Commands  = PutToTempStorage(-1, UUID);
	_StorageAddresses.CommonCommands = PutToTempStorage(-1, UUID);
	_StorageAddresses.Subsystems = PutToTempStorage(-1, UUID);
	_StorageAddresses.RolesAndUsers = "";
	
	// Settings Storages
	TreeLines = SettingsTree.GetItems();
	TreeLines.Clear();

	ГруппаДЗ = TreeLines.Add();
	ГруппаДЗ.Presentation = "ru = 'Стандартные хранилища настроек';en = 'Standart settings storages'";

	SectionStructure = New Structure("ReportsVariantsStorage, FormDataSettingsStorage, CommonSettingsStorage
								   |, DynamicListsUserSettingsStorage, ReportsUserSettingsStorage, SystemSettingsStorage");

	For Each Item In SectionStructure Do
		TreeLine = ГруппаДЗ.GetItems().Add();
		TreeLine.Name = Item.Key;
		TreeLine.Presentation = Item.Key;
		TreeLine.NodeType = "Х";
	EndDo;
EndProcedure

&AtClient
Procedure kOpenInNewWindow(Command)
	OpenForm(PathToForms, , , CurrentDate(), , , , FormWindowOpeningMode.Independent);
EndProcedure

&AtClient
Procedure _CollapseAllNodes(Command)
	For Each TreeNode In ObjectsTree.GetItems() Do
		Items.ObjectsTree.Collapse(TreeNode.GetID());
	EndDo;
EndProcedure

&AtClient
Procedure _UpdateDBUsersList(Command)
	For Each Стр In ObjectsTree.GetItems() Do
		If Стр.Name = "Common" Then
			For Each TreeNode In Стр.GetItems() Do
				If TreeNode.NodeType = "SectionMD" And StrFind(TreeNode.Name, "Users") = 1 Then
					TreeLines = TreeNode.GetItems();
					TreeLines.Clear();

					_Structure = вПолучитьСоставРазделаМД("Users");
					For Each Item In _Structure.МассивОбъектов Do
						TreeLine = TreeLines.Add();
						FillPropertyValues(TreeLine, Item);
					EndDo;
					TreeNode.Name = "Users (" + _Structure.NumberOfObjects + ")";

					Break;
				EndIf;
			EndDo;

			Break;
		EndIf;
	EndDo;
EndProcedure

&AtClient
Procedure _CreateDBUser(Command)
	СтрукПараметры = New Structure("РежимРаботы", 1);
	OpenForm(PathToForms + "ФормаПользовательИБ", СтрукПараметры, , , , , ,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure _CopyDBUser(Command)
	CurrentData = Items.ObjectsTree.CurrentData;
	If CurrentData <> Undefined And StrFind(CurrentData.FullName, "User.") = 1 Then
		СтрукПараметры = New Structure("РежимРаботы, DBUserID", 2, CurrentData.ObjectPresentation);
		OpenForm(PathToForms + "ФормаПользовательИБ", СтрукПараметры, , , , , ,
			FormWindowOpeningMode.LockOwnerWindow);
	EndIf;
EndProcedure

&AtClient
Procedure _DeleteDBUser(Command)
	CurrentData = Items.ObjectsTree.CurrentData;
	If CurrentData <> Undefined And StrFind(CurrentData.FullName, "User.") = 1 Then
		пТекст = StrTemplate("User ""%1"" будет удален из информационной базы!
						   |Continue?", CurrentData.Name);
		ShowQueryBox(New NotifyDescription("вУдалитьПользователяОтвет", ThisForm, CurrentData), пТекст,
			QuestionDialogMode.YesNoCancel, 20);
	EndIf;
EndProcedure

&AtClient
Procedure вУдалитьПользователяОтвет(Ответ, CurrentData) Export
	If Ответ = DialogReturnCode.Yes Then
		pResult = вУдалитьПользователяИБ(CurrentData.ObjectPresentation);
		If pResult.Cancel Then
			vShowMessageBox(pResult.ПричинаОтказа);
		Else
			CurrentData.GetParent().GetItems().Delete(CurrentData);
		EndIf;
	EndIf;
EndProcedure

&AtServerNoContext
Function вУдалитьПользователяИБ(ID)
	pResult = New Structure("Cancel, ПричинаОтказа", False, "");

	Try
		пUUID = New UUID(ID);

		vUser = InfoBaseUsers.FindByUUID(пUUID);
		If vUser = Undefined Then
			pResult.Cancel = True;
			pResult.ПричинаОтказа = "Указанный User не найден!";
			Return pResult;
		EndIf;

		пТекПользователь = InfoBaseUsers.CurrentUser();

		If пТекПользователь.UUID = пUUID Then
			pResult.Cancel = True;
			pResult.ПричинаОтказа = "Нельзя удалить текущего пользоватля!";
			Return pResult;
		EndIf;

		vUser.Delete();
	Except
		pResult.Cancel = True;
		pResult.ПричинаОтказа = ErrorDescription();
	EndTry;

	Return pResult;
EndFunction
&AtClient
Procedure kShowObjectProperties(Command)
	If Items.PagesGroup.CurrentPage.Name = "StorageStructurePage" Then
		CurrentData = Undefined;
		If Items.TableAndIndexesGrpip.CurrentPage.Name = "_IndexesPage" Then
			CurrentData = Items._Indexes.CurrentData;
		ElsIf Items.TableAndIndexesGrpip.CurrentPage.Name = "TablePage" Then
			CurrentData = Items._Tables.CurrentData;
		EndIf;

		If CurrentData <> Undefined Then
			пПолноеИмя = CurrentData.Metadata;
			If пПолноеИмя = "<не задано>" Then
				Return;
			EndIf;

			Поз = StrFind(пПолноеИмя, ".", , , 2);
			If Поз <> 0 Then
				пПолноеИмя = Left(пПолноеИмя, Поз - 1);
			EndIf;

			СтрукПараметры = New Structure("FullName, PathToForms, _StorageAddresses, ОписаниеПравДоступа",
				пПолноеИмя, PathToForms, _StorageAddresses, mDescriptionAccessRights);
			СтрукПараметры.Insert("НастройкиОбработки", vFormStructureOfObjectPropertiesFormSettings());
			OpenForm(PathToForms + "ФормаСвойств", СтрукПараметры, , пПолноеИмя, , , ,
				FormWindowOpeningMode.Independent);
		EndIf;

		Return;
	EndIf;

	CurrentData = Items.ObjectsTree.CurrentData;
	If CurrentData <> Undefined Then
		If CurrentData.NodeType = "MetadataObject" Then
			If StrFind(CurrentData.FullName, "User.") = 1 Then
				СтрукПараметры = New Structure("DBUserID", CurrentData.ObjectPresentation);
				OpenForm(PathToForms + "ФормаПользовательИБ", СтрукПараметры, , CurrentData.FullName, , , ,
					FormWindowOpeningMode.LockOwnerWindow);
			Else
				СтрукПараметры = New Structure("FullName, PathToForms, _StorageAddresses, ОписаниеПравДоступа",
					CurrentData.FullName, PathToForms, _StorageAddresses, mDescriptionAccessRights);
				СтрукПараметры.Insert("НастройкиОбработки", vFormStructureOfObjectPropertiesFormSettings());
				OpenForm(PathToForms + "ФормаСвойств", СтрукПараметры, , CurrentData.FullName, , , ,
					FormWindowOpeningMode.Independent);
			EndIf;
		ElsIf CurrentData.NodeType = "Configuration" Then
			СтрукПараметры = New Structure("FullName, PathToForms, _StorageAddresses, ОписаниеПравДоступа",
				"Configuration", PathToForms, _StorageAddresses, mDescriptionAccessRights);
			СтрукПараметры.Insert("НастройкиОбработки", vFormStructureOfObjectPropertiesFormSettings());
			OpenForm(PathToForms + "ФормаСвойств", СтрукПараметры, , CurrentData.FullName, , , ,
				FormWindowOpeningMode.Independent);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure kOpenListForm(Command)
	CurrentData = Items.ObjectsTree.CurrentData;
	If CurrentData <> Undefined Then
		If CurrentData.NodeType = "MetadataObject" And Not вЭтоПрочаяКоманда(CurrentData.FullName) Then
			Try
				ВидОбъектМД = Left(CurrentData.FullName, StrFind(CurrentData.FullName, ".") - 1);

				If ВидОбъектМД = "User" Then
					StandardProcessing = False;
					СтрукПараметры = New Structure("DBUserID", CurrentData.ObjectPresentation);
					OpenForm(PathToForms + "ФормаПользовательИБ", СтрукПараметры, , CurrentData.FullName, , , ,
						FormWindowOpeningMode.LockOwnerWindow);
					Return;
				EndIf;

				If Not mOrdinaryApplicationObjects.Property(ВидОбъектМД) Then
					Return;
				EndIf;

				If ВидОбъектМД = "Processing" Then
					ИмяФормыМД = ".Form";
				ElsIf ВидОбъектМД = "Report" Then
					ИмяФормыМД = ".Form";
				ElsIf ВидОбъектМД = "Constant" Then
					ИмяФормыМД = ".ФормаКонстант";
				ElsIf ВидОбъектМД = "ОбщаяФорма" Then
					ИмяФормыМД = "";
				ElsIf ВидОбъектМД = "Enum" Then
					StandardProcessing = True;
					Return;
				Else
					ИмяФормыМД = ".ФормаСписка";
				EndIf;

				StandardProcessing = False;
				OpenForm(CurrentData.FullName + ИмяФормыМД);
			Except
				Message(BriefErrorDescription(ErrorInfo()));
			EndTry;
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure kCollapseTreeSection(Command)
	CurrentData = Items.ObjectsTree.CurrentData;
	If CurrentData <> Undefined Then
		TreeNode = CurrentData.GetParent();
		If TreeNode <> Undefined Then
			String = TreeNode.GetID();
			Items.ObjectsTree.CurrentLine = String;
			Items.ObjectsTree.Collapse(String);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure kRunConfigurator(Command)
	вЗапуститьСеанс1С(1);
EndProcedure

&AtClient
Procedure kRunOrdinaryClient(Command)
	вЗапуститьСеанс1С(2);
EndProcedure

&AtClient
Procedure kRunThickClient(Command)
	вЗапуститьСеанс1С(3);
EndProcedure

&AtClient
Procedure kRunThinClient(Command)
	вЗапуститьСеанс1С(4);
EndProcedure

&AtClient
Procedure kRun1CForAnyBase(Command)
#If WebClient Then
	vOperationNotSupportedForWebClient();
#Else
		OpenForm(PathToForms + "ФормаЗапуска1С", , ThisForm, , , , ,
			FormWindowOpeningMode.LockOwnerWindow);
#EndIf
EndProcedure

&AtClient
Procedure ДеревоОбъектовПередРазворачиванием(Item, String, Cancel)
	If Not _DisplayObjectsRights Then
		Items.ObjectsTree.CurrentLine = String; // полезно при раскрытии узлов, которые находятся выше
	EndIf;

	TreeNode = ObjectsTree.FindByID(String);
	TreeLines = TreeNode.GetItems();
	If TreeLines.Count() = 1 And IsBlankString(TreeLines[0].NodeType) Then
		Cancel = True;
		TreeLines.Clear();

		ИмяУзлаДЗ = TreeNode.Name;
		Поз = StrFind(ИмяУзлаДЗ, " (");
		If Поз <> 0 Then
			ИмяУзлаДЗ = Left(ИмяУзлаДЗ, Поз - 1);
		EndIf;

		If TreeNode.NodeType = "SectionMD" Then
			TreeNode = ObjectsTree.FindByID(String);
			TreeLines = TreeNode.GetItems();
			TreeLines.Clear();

			If ИмяУзлаДЗ = "Documents" Then
				_Structure = New Structure("DocumentNumerators, Sequences");
				vCalculateNumberOfObjectsMD(_Structure);
				For Each Item In _Structure Do
					TreeLine = TreeLines.Add();
					TreeLine.NodeType = "SectionMD";
					TreeLine.Name = Item.Key + " (" + Item.Value + ")";
					TreeLine.GetItems().Add();
				EndDo;
				
				//TreeLine = TreeLines.Add();
				//TreeLine.NodeType = "SectionMD";
				//TreeLine.Name = "DocumentNumerators";
				//TreeLine.GetItems().Add();
				//
				//TreeLine = TreeLines.Add();
				//TreeLine.NodeType = "SectionMD";
				//TreeLine.Name = "Sequences";
				//TreeLine.GetItems().Add();
			EndIf;

			_Structure = вПолучитьСоставРазделаМД(ИмяУзлаДЗ);
			For Each Item In _Structure.МассивОбъектов Do
				TreeLine = TreeLines.Add();
				FillPropertyValues(TreeLine, Item);
				If StrFind(TreeLine.FullName, "Enum.") = 1 Then
					TreeLine.GetItems().Add();
				ElsIf StrFind(TreeLine.FullName, "Подсистема.") = 1 Then
					If Item.ЕстьДети Then
						TreeLine.GetItems().Add();
					EndIf;
				ElsIf StrFind(TreeLine.FullName, "WebСервис.") = 1 Then
					TreeLine.GetItems().Add();
				ElsIf StrFind(TreeLine.FullName, "HTTPСервис.") = 1 Then
					TreeLine.GetItems().Add();
				EndIf;
			EndDo;
			TreeNode.Name = ИмяУзлаДЗ + " (" + _Structure.NumberOfObjects + ")";

		ElsIf TreeNode.NodeType = "SectionGroupMD" Then
			SectionStructure = New Structure("Subsystems, CommonModules, SessionParameters, Users, Roles, CommonAttributes, ExchangePlans, EventSubscriptions, ScheduledJobs
										   |, FunctionalOptions, FunctionalOptionsParameters, DefinedTypes, SettingsStorages, CommonForms, CommonCommands, CommandGroups, ПрочиеКоманды, CommonTemplates, XDTOPackages, WebServices, HTTPServices");

			vCalculateNumberOfObjectsMD(SectionStructure);

			For Each Item In SectionStructure Do
				If Item.Key = "Users" And Not vIsAdministratorRights() Then
					Continue;
				EndIf;
				TreeLine = TreeLines.Add();
				TreeLine.Name = Item.Key;
				TreeLine.Name = Item.Key + " (" + Item.Value + ")";
				TreeLine.NodeType = "SectionMD";
				TreeLine.NodeType = 1;
				TreeLine.GetItems().Add();
			EndDo;

		ElsIf TreeNode.NodeType = "MetadataObject" Then
			ВидОбъектМД = Left(TreeNode.FullName, StrFind(TreeNode.FullName, ".") - 1);

			TreeNode = ObjectsTree.FindByID(String);
			TreeLines = TreeNode.GetItems();
			TreeLines.Clear();

			If ВидОбъектМД = "Enum" Then
				МассивОбъектов = вПолучитьСоставПеречисления(TreeNode.FullName);
				For Each Item In МассивОбъектов Do
					TreeLine = TreeLines.Add();
					FillPropertyValues(TreeLine, Item);
				EndDo;
			ElsIf ВидОбъектМД = "Подсистема" Then
				МассивОбъектов = вПолучитьСоставПодсистемы(TreeNode.FullName);
				For Each Item In МассивОбъектов Do
					TreeLine = TreeLines.Add();
					FillPropertyValues(TreeLine, Item);
					If Item.ЕстьДети Then
						TreeLine.GetItems().Add();
					EndIf;
				EndDo;
			ElsIf ВидОбъектМД = "WebСервис" Then
				МассивОбъектов = вПолучитьОперацииWebСервиса(TreeNode.FullName);
				For Each Item In МассивОбъектов Do
					TreeLine = TreeLines.Add();
					FillPropertyValues(TreeLine, Item);
				EndDo;
			ElsIf ВидОбъектМД = "HTTPСервис" Then
				МассивОбъектов = вПолучитьМетодыHTTPСервиса(TreeNode.FullName);
				For Each Item In МассивОбъектов Do
					TreeLine = TreeLines.Add();
					FillPropertyValues(TreeLine, Item);
					For Each ЭлемХ In Item.Methods Do
						FillPropertyValues(TreeLine.GetItems().Add(), ЭлемХ);
					EndDo;
				EndDo;
			EndIf;
		EndIf;
		Items.ObjectsTree.Expand(String);
	EndIf;
EndProcedure

&AtClient
Procedure вЗапуститьСеанс1С(ТипЗапуска)
	UT_CommonClient.Run1CSession(ТипЗапуска, UserName());
EndProcedure

&AtClient
Procedure вВыполнитьКомандуОС(пКоманда)
	Try
		BeginRunningApplication(New NotifyDescription("вПослеЗапускаПриложения", ThisForm), пКоманда);
	Except
		Message(BriefErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

&AtClient
Procedure вПослеЗапускаПриложения(КодВозврата, ДопПарам = Undefined) Export
	// фиктивная процедура для совместимости разных версий платыормы
EndProcedure
&AtClientAtServerNoContext
Function vListOfTreeFields()
	Return "Name, Synonym, ОсновнаяТаблицаSQL, FullName, NodeType, NodeType, ObjectPresentation, NumberOfObjects";
EndFunction

&AtServerNoContext
Function вСформироватьСтруктуруУзлаДЗ(NodeType = "", Name = "", FullName = "", Synonym = "", ЕстьДети = False,
	ObjectPresentation = "")
	_Structure = New Structure("NodeType, Name, FullName, Synonym, ObjectPresentation, ЕстьДети, ОсновнаяТаблицаSQL",
		NodeType, Name, FullName, Synonym, ObjectPresentation, ЕстьДети, "");
	Return _Structure;
EndFunction

&AtServerNoContext
Function vFormConfigurationNode()
	_Structure = New Structure("Name, Synonym, Version", "", "", "");
	FillPropertyValues(_Structure, Metadata);

	If IsBlankString(_Structure.Synonym) Then
		_Structure.Synonym = _Structure.Name;
	EndIf;
	If Not IsBlankString(_Structure.Version) Then
		_Structure.Synonym = _Structure.Synonym + " (" + _Structure.Version + ")";
	EndIf;

	Return вСформироватьСтруктуруУзлаДЗ("Configuration", _Structure.Name, "Configuration", _Structure.Synonym);
EndFunction

&AtServerNoContext
Function вПроверитьНаличиеСвойства(Object, PropertyName)
	_Structure = New Structure(PropertyName);
	FillPropertyValues(_Structure, Object);

	Return (_Structure[PropertyName] <> Undefined);
EndFunction

&AtServerNoContext
Function vGetCompositionSectionMD(Val ИмяРаздела)
	Поз = StrFind(ИмяРаздела, " ");
	If Поз <> 0 Then
		ИмяРаздела = Left(ИмяРаздела, Поз - 1);
	EndIf;

	СтрукРезультат = New Structure("NumberOfObjects, МассивОбъектов", 0, New Array);
	
	// для упорядочивания по именам объектов
	пОбъектыСДопПредставлением = New Structure("ExchangePlans, Catalogs, Documents, ChartsOfCharacteristicTypes, ChartsOfCalculationTypes, ChartsOfAccounts, BusinessProcesses, Tasks");
	ЕстьДопПредставление = пОбъектыСДопПредставлением.Property(ИмяРаздела);

	ТипСтрока = New TypeDescription("String");

	Table = New ValueTable;
	Table.Cols.Add("MetadataObject");
	Table.Cols.Add("Name", ТипСтрока);
	Table.Cols.Add("Synonym", ТипСтрока);
	Table.Cols.Add("ObjectPresentation", ТипСтрока);
	Table.Cols.Add("ОсновнаяТаблицаSQL", ТипСтрока);
	Table.Cols.Add("FullName", ТипСтрока);
	Table.Cols.Add("NodeType", ТипСтрока);
	Table.Cols.Add("ЕстьДети", New TypeDescription("Boolean"));

	If ИмяРаздела = "Users" Then
		If vIsAdministratorRights() Then
			For Each Item In InfoBaseUsers.GetUsers() Do
				Стр = Table.Add();
				Стр.Name = Item.Name;
				Стр.Synonym = Item.FullName;
				Стр.ObjectPresentation = Item.UUID;
				Стр.FullName = "User." + Item.Name;
				Стр.NodeType = "MetadataObject";
			EndDo;
		EndIf;
	ElsIf ИмяРаздела = "ПрочиеКоманды" Then
		ПереченьРазделов = "Catalogs, DocumentJournals, Documents, Enums, DataProcessors, Reports,
						   |ChartsOfAccounts, ChartsOfCharacteristicTypes, ChartsOfCalculationTypes, ExchangePlans,
						   |InformationRegisters, AccumulationRegisters, CalculationRegisters, AccountingRegisters,
						   |BusinessProcesses, Tasks, FilterCriteria";

		SectionStructure = New Structure(ПереченьРазделов);

		For Each Item In SectionStructure Do
			For Each ОбъектХХХ In Metadata[Item.Key] Do
				ИмяТипаХХХ = ОбъектХХХ.FullName();

				If вПроверитьНаличиеСвойства(ОбъектХХХ, "Commands") Then
					For Each Item In ОбъектХХХ.Commands Do
						Стр = Table.Add();
						Стр.MetadataObject = Item;
						Стр.Name = Item.Name;
						Стр.Synonym = Item.Presentation();
						Стр.FullName = Item.FullName();
						Стр.NodeType = "MetadataObject";
					EndDo;
				EndIf;
			EndDo;
		EndDo;

	Else
		For Each Item In Metadata[ИмяРаздела] Do
			Стр = Table.Add();
			Стр.MetadataObject = Item;
			Стр.Name = Item.Name;
			Стр.Synonym = Item.Presentation();
			Стр.ObjectPresentation = ?(ЕстьДопПредставление, Item.ObjectPresentation, "");
			Стр.FullName = Item.FullName();
			Стр.NodeType = "MetadataObject";

			If ИмяРаздела = "Subsystems" Then
				Стр.ЕстьДети = (Item.Subsystems.Count() <> 0);
			EndIf;
		EndDo;
	EndIf;

	If ИмяРаздела = "ПрочиеКоманды" Then
		Table.Sort("FullName");
	Else
		Table.Sort("Name");
	EndIf;

	For Each Стр In Table Do
		_Structure = вСформироватьСтруктуруУзлаДЗ();
		FillPropertyValues(_Structure, Стр);
		СтрукРезультат.МассивОбъектов.Add(_Structure);
	EndDo;

	If ИмяРаздела = "Subsystems" Then
		СтрукРезультат.NumberOfObjects = vGetNumberOfSubSytems();
	Else
		СтрукРезультат.NumberOfObjects = СтрукРезультат.МассивОбъектов.Count();
	EndIf;

	Return СтрукРезультат;
EndFunction

&AtServerNoContext
Function вПолучитьСоставПеречисления(Val FullName)
	МассивОбъектов = New Array;

	ОбъектМД = Metadata.FindByFullName(FullName);
	If ОбъектМД <> Undefined Then
		For Each ЭлемХ In ОбъектМД.EnumValues Do
			_Structure = вСформироватьСтруктуруУзлаДЗ("ЗначениеПеречисления", ЭлемХ.Name, "", ЭлемХ.Presentation());
			МассивОбъектов.Add(_Structure);
		EndDo;
	EndIf;

	Return МассивОбъектов;
EndFunction

&AtServerNoContext
Function вПолучитьОперацииWebСервиса(Val FullName)
	МассивОбъектов = New Array;

	ОбъектМД = Metadata.FindByFullName(FullName);
	If ОбъектМД <> Undefined Then
		For Each ЭлемХ In ОбъектМД.Operations Do
			_Structure = вСформироватьСтруктуруУзлаДЗ("MetadataObject", ЭлемХ.Name, ЭлемХ.FullName(), ЭлемХ.Presentation());
			МассивОбъектов.Add(_Structure);
		EndDo;
	EndIf;

	Return МассивОбъектов;
EndFunction

&AtServerNoContext
Function вПолучитьМетодыHTTPСервиса(Val FullName)
	МассивОбъектов = New Array;

	ОбъектМД = Metadata.FindByFullName(FullName);
	If ОбъектМД <> Undefined Then
		For Each ЭлемХ In ОбъектМД.URLTemplates Do
			_Structure = вСформироватьСтруктуруУзлаДЗ("MetadataObject", ЭлемХ.Name, ЭлемХ.FullName(), ЭлемХ.Presentation());
			МассивОбъектов.Add(_Structure);
			_Structure.Insert("Methods", New Array);
			For Each ЭлемХХХ In ЭлемХ.Methods Do
				СтрукХХХ = вСформироватьСтруктуруУзлаДЗ("MetadataObject", ЭлемХХХ.Name, ЭлемХХХ.FullName(),
					ЭлемХХХ.Presentation());
				_Structure.Methods.Add(СтрукХХХ);
			EndDo;
		EndDo;
	EndIf;

	Return МассивОбъектов;
EndFunction

&AtServerNoContext
Function вПолучитьСоставПодсистемы(Val FullName)
	ТипСтрока = New TypeDescription("String");

	Table = New ValueTable;
	Table.Cols.Add("MetadataObject");
	Table.Cols.Add("Name", ТипСтрока);
	Table.Cols.Add("Synonym", ТипСтрока);
	Table.Cols.Add("ObjectPresentation", ТипСтрока);
	Table.Cols.Add("FullName", ТипСтрока);
	Table.Cols.Add("NodeType", ТипСтрока);
	Table.Cols.Add("ЕстьДети", New TypeDescription("Boolean"));

	ОбъектМД = Metadata.FindByFullName(FullName);
	If ОбъектМД <> Undefined Then
		For Each Item In ОбъектМД.Subsystems Do
			Стр = Table.Add();
			Стр.MetadataObject = Item;
			Стр.Name = Item.Name;
			Стр.Synonym = Item.Presentation();
			Стр.FullName = Item.FullName();
			Стр.NodeType = "MetadataObject";
			Стр.ЕстьДети = (Item.Subsystems.Count() <> 0);
		EndDo;
	EndIf;
	Table.Sort("Name");

	МассивОбъектов = New Array;

	For Each Стр In Table Do
		_Structure = вСформироватьСтруктуруУзлаДЗ();
		FillPropertyValues(_Structure, Стр);
		МассивОбъектов.Add(_Structure);
	EndDo;

	Return МассивОбъектов;
EndFunction

&AtServerNoContext
Procedure vCalculateNumberOfObjectsMD(SectionStructure)
	SetPrivilegedMode(True);

	For Each Item In SectionStructure Do
		NumberOfObjects = 0;
		If Item.Key = "Users" Then
			If vIsAdministratorRights() Then
				NumberOfObjects = InfoBaseUsers.GetUsers().Count();
			EndIf;
		ElsIf Item.Key = "Subsystems" Then
			NumberOfObjects = vGetNumberOfSubSytems();
		ElsIf Item.Key = "ПрочиеКоманды" Then
			NumberOfObjects = "???"; //vGetNumberOfSubSytems();
		Else
			NumberOfObjects = Metadata[Item.Key].Count();
		EndIf;
		SectionStructure.Insert(Item.Key, NumberOfObjects);
	EndDo;
EndProcedure

&AtServerNoContext
Function vGetNumberOfSubSytems(Val ЭтоПервыйВызов = True, ПодсистемаМД = Undefined, Соотв = Undefined)
	If ЭтоПервыйВызов Then
		Соотв = New Map;

		For Each Item In Metadata.Subsystems Do
			vGetNumberOfSubSytems(False, Item, Соотв);
		EndDo;

		Return Соотв.Count();
	Else
		Соотв.Insert(ПодсистемаМД, 1);
		For Each Item In ПодсистемаМД.Subsystems Do
			Соотв.Insert(Item, 1);
			vGetNumberOfSubSytems(False, Item, Соотв);
		EndDo;

		Return 0;
	EndIf;
EndFunction
&AtClient
Function вЭтоПрочаяКоманда(FullName)
	Return (StrFind(FullName, "Подсистема.") <> 1 And StrFind(FullName, ".Command.") <> 0);
EndFunction

&AtClient
Procedure ДеревоОбъектовВыбор(Item, SelectedRow, Field, StandardProcessing)
	CurrentData = Items.ObjectsTree.CurrentData;

	If CurrentData <> Undefined Then
		If CurrentData.NodeType = "MetadataObject" Then
			If вЭтоПрочаяКоманда(CurrentData.FullName) Then
				kShowObjectProperties(Undefined);
				Return;
			EndIf;

			СпецПеречень = "Processing, Report";
			_Structure = New Structure(СпецПеречень);

			ВидОбъектМД = Left(CurrentData.FullName, StrFind(CurrentData.FullName, ".") - 1);
			If _Structure.Property(ВидОбъектМД) Then
				kOpenListForm(Undefined);
			Else
				kShowObjectProperties(Undefined);
			EndIf;
		ElsIf CurrentData.NodeType = "Configuration" Then
			kShowObjectProperties(Undefined);
		EndIf;
	EndIf;

EndProcedure

&AtClient
Procedure ДеревоОбъектовПриИзменении(Item)
	вВключитьФлагИзмененияНастроек();
EndProcedure

&AtClient
Procedure kChangeScaleOfForm(Command)
	OpenForm(PathToForms + "ФормаВыбораМасштабаОтображения", , ThisForm, , , , ,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure kOpenDynamicList(Command)
	CurrentData = Items.ObjectsTree.CurrentData;
	If CurrentData <> Undefined Then
		If CurrentData.NodeType = "MetadataObject" And Not вЭтоПрочаяКоманда(CurrentData.FullName) Then
			СтрукКатегории = New Structure("Catalog, Document, DocumentJournal,ChartOfCharacteristicTypes, ChartOfCalculationTypes, ChartOfAccounts
											 |, InformationRegister, AccumulationRegister, AccountingRegister, CalculationRegister, BusinessProcess, Task");

			НадоОбработать = False;
			For Each Item In СтрукКатегории Do
				If StrFind(CurrentData.FullName, Item.Key) = 1 Then
					НадоОбработать = True;
					Break;
				EndIf;
			EndDo;

			If НадоОбработать Then
				UT_CommonClient.ОpenDynamicList(CurrentData.FullName);
			EndIf;
		EndIf;
	EndIf;
EndProcedure
&AtServer
Function вОбновитьТабНастройки(Val NodeType, Val Name)
	SetPrivilegedMode(True);

	If NodeType = "Х" Then
		МенеджерХН = Eval(Name);
	Else
		Return False;
	EndIf;

	If TypeOf(МенеджерХН) <> Type("StandardSettingsStorageManager") Then
		Return False;
	EndIf;

	If Not vIsAdministratorRights() Then
		ТекПользователь = InfoBaseUsers.CurrentUser();
		Filter = New Structure("User", ТекПользователь.Name);
	Else
		Filter = Undefined;
	EndIf;

	Try
		Выборка = МенеджерХН.StartChoosing(Filter);
		While Выборка.Next() Do
			НС = SettingsTable.Add();
			НС.SettingsKey = Выборка.SettingsKey;
			НС.ObjectKey = Выборка.ObjectKey;
			НС.User = Выборка.User;
			НС.Presentation = Выборка.Presentation;
		EndDo;
	Except
		Message(BriefErrorDescription(ErrorInfo()));
	EndTry;

	Return True;
EndFunction

&AtServer
Procedure вУдалитьМассивНастроек(Val Name, Val МассивСтрок)
	SetPrivilegedMode(True);

	Try
		МенеджерХН = Eval(Name);

		For Each Item In МассивСтрок Do
			Стр = SettingsTable.FindByID(Item);
			If Стр <> Undefined Then
				МенеджерХН.Delete(Стр.ObjectKey, Стр.SettingsKey, Стр.User);
				SettingsTable.Delete(Стр);
			EndIf;
		EndDo;
	Except
		Message(BriefErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

&AtClient
Procedure ТабНастройкиПередНачаломДобавления(Item, Cancel, Copy, Parent, Group, Parameter)
	Cancel = True;
EndProcedure

&AtClient
Procedure ТабНастройкиПередУдалением(Item, Cancel)
	Cancel = True;
	If Not IsBlankString(_NameOfSettingsManager) Then
		СтрукПараметры = New Structure;
		СтрукПараметры.Insert("МассивСтрок", New FixedArray(Item.SelectedRows));
		vShowQueryBox("Отмеченные настройки будут удалены. Continue?", "ТабНастройкиПередУдалениемДалее",
			СтрукПараметры);
	EndIf;
EndProcedure

&AtClient
Procedure ТабНастройкиПередУдалениемДалее(Result, Parameters) Export
	If Result = DialogReturnCode.Yes Then
		вУдалитьМассивНастроек(_NameOfSettingsManager, Parameters.МассивСтрок);
		вОбновитьЗаголовкиНастройки();
	EndIf;
EndProcedure

&AtClient
Procedure kUpdateSettingsTable(Command)
	CurrentData = Items.SettingsTree.CurrentData;

	If CurrentData <> Undefined And CurrentData.NodeType = "Х" Then
		SettingsTable.Clear();

		If Not вОбновитьТабНастройки(CurrentData.NodeType, CurrentData.Name) Then
			CurrentData.NodeType = "-";
			CurrentData.Presentation = CurrentData.Name + " (не поддерживается)";
		EndIf;

		_NameOfSettingsManager = CurrentData.Name;

		вОбновитьЗаголовкиНастройки();
	EndIf;
EndProcedure

&AtClient
Procedure вОбновитьЗаголовкиНастройки()
	Items.DecorationSettings.Title = _NameOfSettingsManager + " (" + SettingsTable.Count() + " шт.)";
EndProcedure



// страница Service

&AtServer
Procedure vFillServiceTree()
	Template = vGetProcessor().GetTemplate("МакетСервис");
	If Template = Undefined Then
		Template = New SpreadsheetDocument;
	EndIf;

	СтрукСвойства = New Structure("Enabled, Presentation, NodeType, Name, Comment, AvailabilityExpression",
		True);

	КореньДЗ = ServiceTree;
	TreeNode = ServiceTree;

	For LineNumber = 2 To Template.TableHeight Do
		СтрукСвойства.Presentation = TrimAll(Template.Region(LineNumber, 1).Text);

		If Not IsBlankString(СтрукСвойства.Presentation) Then
			СтрукСвойства.NodeType = TrimAll(Template.Region(LineNumber, 2).Text);
			СтрукСвойства.Name = TrimAll(Template.Region(LineNumber, 3).Text);
			СтрукСвойства.AvailabilityExpression = TrimAll(Template.Region(LineNumber, 4).Text);
			СтрукСвойства.Comment = TrimAll(Template.Region(LineNumber, 5).Text);

			If СтрукСвойства.NodeType = "Г" Then
				TreeNode = КореньДЗ.GetItems().Add();
				FillPropertyValues(TreeNode, СтрукСвойства);
				TreeNode.IsGroup = True;
				TreeNode.Picture = -1;
			Else
				TreeLine = TreeNode.GetItems().Add();
				FillPropertyValues(TreeLine, СтрукСвойства);
				If Not IsBlankString(СтрукСвойства.AvailabilityExpression) Then
					TreeLine.Enabled = Eval(СтрукСвойства.AvailabilityExpression);
				EndIf;
				If Not TreeLine.Enabled Then
					TreeLine.Presentation = TreeLine.Presentation + " (не доступно)";
				EndIf;

				If TreeLine.Name = "ПереключитьМонопольныйРежим" Then
					TreeLine.Presentation = ?(_FormContext.ExclusiveMode, "Отключить монопольный режим",
						"Set монопольный режим");
				EndIf;
			EndIf;
		EndIf;
	EndDo;
EndProcedure

&AtClient
Procedure ДеревоСервисВыбор(Item, SelectedRow, Field, StandardProcessing)
	TreeLine = ServiceTree.FindByID(SelectedRow);
	If TreeLine <> Undefined Then
		If Not TreeLine.IsGroup Then
			StandardProcessing = False;
			If TreeLine.Enabled Then
				Try
					вОбработатьКомандуСервис(TreeLine);
				Except
				EndTry;
			EndIf;
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure вОбработатьКомандуСервис(TreeLine)
	If TreeLine.Name = "SubsystemVersions" Then
		OpenForm("InformationRegister.ВерсииПодсистем.ФормаСписка");
	ElsIf TreeLine.Name = "RefreshReusableValues" Then
		RefreshReusableValues();
	ElsIf TreeLine.Name = "ClearFavorites" Then
		vShowQueryBox("Favorites будет очищено. Continue?", "вОчиститьИзбранное");
	ElsIf TreeLine.Name = "DisplayScale" Then
		kChangeScaleOfForm(Undefined);
	ElsIf TreeLine.Name = "SetSessionsLock" Then
		OpenForm(PathToForms + "ФормаБлокировкиСеансов", , ThisForm, , , , ,
			FormWindowOpeningMode.LockOwnerWindow);
	ElsIf TreeLine.Name = "ExclusiveMode" Then
		вПерключитьМонопольныйРежим(_FormContext);
		TreeLine.Presentation = ?(_FormContext.ExclusiveMode, "Отключить монопольный режим",
			"Set монопольный режим");
	ElsIf TreeLine.Name = "Run1C" Then
#If WebClient Then
		vOperationNotSupportedForWebClient();
#Else
			OpenForm(PathToForms + "ФормаЗапуска1С", , ThisForm, , , , ,
				FormWindowOpeningMode.LockOwnerWindow);
#EndIf
	ElsIf
	TreeLine.Name = "1CConfigurator" Then
		вЗапуститьСеанс1С(1);
	ElsIf TreeLine.Name = "OrdinaryСlient" Then
		вЗапуститьСеанс1С(2);
	ElsIf TreeLine.Name = "ThickСlient" Then
		вЗапуститьСеанс1С(3);
	ElsIf TreeLine.Name = "ThinСlient" Then
		вЗапуститьСеанс1С(4);
	ElsIf TreeLine.Name = "WinStartMenu" Then
		вВыполнитьКомандуОС("%ProgramData%\Microsoft\Windows\Start Menu\Programs");
	ElsIf TreeLine.Name = "WinAppData" Then
		вВыполнитьКомандуОС("%AppData%");
	EndIf;
EndProcedure

&AtClient
Procedure вОчиститьИзбранное(Result, AdditionalParameters = Undefined) Export
	If Result = DialogReturnCode.Yes Then
		вОчиститьИзбранноеСервер();
	EndIf;
EndProcedure

&AtServerNoContext
Procedure вОчиститьИзбранноеСервер()
	Favorites = SystemSettingsStorage.Load("Общее/UserWorkFavorites");
	Favorites.Clear();
	SystemSettingsStorage.Save("Общее/UserWorkFavorites", "", Favorites);
EndProcedure

&AtServerNoContext
Procedure вПерключитьМонопольныйРежим(_FormContext)
	Try
		SetExclusiveMode(Not ExclusiveMode());
		_FormContext.ExclusiveMode = ExclusiveMode();
	Except
		Message(BriefErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

&AtClient
Procedure kRunServiceCommand(Command)
	CurrentData = Items.ServiceTree.CurrentData;
	ДеревоСервисВыбор(Items.ДеревоСервис, Items.ServiceTree.CurrentLine, Undefined, False);
EndProcedure

&AtClient
Procedure _ОтображатьПраваНаОбъектыПриИзменении(Item)
	Items.ObjectRightPages.Visible = _DisplayObjectsRights;

	If Not _DisplayObjectsRights And Not IsBlankString(_StorageAddresses.RolesAndUsers) Then
		DeleteFromTempStorage(_StorageAddresses.RolesAndUsers);
		_StorageAddresses.RolesAndUsers = "";
	EndIf;
EndProcedure

&AtClient
Procedure ДеревоОбъектовПриАктивизацииСтроки(Item)
	If _DisplayObjectsRights Then
		AttachIdleHandler("ОбработкаАктивизацииСтрокиНавигатора", 0.1, True);
	EndIf;
EndProcedure

&AtClient
Procedure ОбработкаАктивизацииСтрокиНавигатора()
	CurrentData = Items.ObjectsTree.CurrentData;
	ТипМД = "";
	If CurrentData <> Undefined And CurrentData.NodeType = "MetadataObject" Then
		If CurrentData.FullName = mCurrentTreeObject Then
			Return;
		EndIf;

		mCurrentTreeObject = CurrentData.FullName;

		For Each Стр In VerifiableRightsTable.FindRows(New Structure("Mark", True)) Do
			Стр.Mark = False;
		EndDo;

		If StrFind(CurrentData.FullName, ".Command.") <> 0 Then
			ТипМД = "ОбщаяКоманда";
		Else
			ТипМД = Left(CurrentData.FullName, StrFind(CurrentData.FullName, ".") - 1);
		EndIf;

		If ТипМД = "WebСервис" And StrFind(CurrentData.FullName, ".Операция.") <> 0 Then
			ТипМД = "WebСервис.Property";
		ElsIf ТипМД = "HTTPСервис" And StrFind(CurrentData.FullName, ".ШаблонURL.") <> 0 And StrFind(
			CurrentData.FullName, ".Method.") <> 0 Then
			ТипМД = "HTTPСервис.Property";
		EndIf;

		For Each Стр In VerifiableRightsTable.FindRows(New Structure("MetadataObject", ТипМД)) Do
			Стр.Mark = True;
		EndDo;
	Else
		mCurrentTreeObject = "";

		For Each Стр In VerifiableRightsTable.FindRows(New Structure("Mark", True)) Do
			Стр.Mark = False;
		EndDo;
	EndIf;

	RolesWithAccessTable.Clear();
	UsersWithAccessTable.Clear();

	If CurrentData <> Undefined And CurrentData.NodeType = "MetadataObject" Then

		If StrFind(CurrentData.FullName, "Role.") = 1 Then
			If Items.ObjectRightPages.CurrentPage <> Items.UsersLine Then
				Items.ObjectRightPages.CurrentPage = Items.UsersLine;
			EndIf;
			ИмяПрава = "Х";
		ElsIf StrFind(CurrentData.FullName, "User.") = 1 Then
			If Items.ObjectRightPages.CurrentPage <> Items.RolesLine Then
				Items.ObjectRightPages.CurrentPage = Items.RolesLine;
			EndIf;
			ИмяПрава = "Х";
		Else
			If ТипМД = "" Then
				ТипМД = Left(CurrentData.FullName, StrFind(CurrentData.FullName, ".") - 1);
			EndIf;
			НайденныеСтроки = VerifiableRightsTable.FindRows(New Structure("MetadataObject", ТипМД));
			If НайденныеСтроки.Count() = 0 Then
				вУстановитьЗаголовкиТаблицПрав();
				Return;
			EndIf;
			ИмяПрава = НайденныеСтроки[0].Right;
			If ИмяПрава = "" Then
				вУстановитьЗаголовкиТаблицПрав();
				Return;
			EndIf;
		EndIf;

		_Structure = вПолучитьПраваДоступаКОбъекту(ИмяПрава, CurrentData.FullName, _StorageAddresses.RolesAndUsers,
			UUID);
		If _Structure.ЕстьДанные Then
			For Each Item In _Structure.Roles Do
				FillPropertyValues(RolesWithAccessTable.Add(), Item);
			EndDo;

			For Each Item In _Structure.Users Do
				FillPropertyValues(UsersWithAccessTable.Add(), Item);
			EndDo;
		EndIf;
	EndIf;

	вУстановитьЗаголовкиТаблицПрав();
EndProcedure

&AtClient
Procedure вУстановитьЗаголовкиТаблицПрав()
	НайденныеСтроки = VerifiableRightsTable.FindRows(New Structure("Mark", True));
	If НайденныеСтроки.Count() = 0 Then
		ИмяПрава = "";
	Else
		ИмяПрава = НайденныеСтроки[0].Right + ": ";
	EndIf;

	ЗаголовокРоли = ИмяПрава + "Roles, имеющие доступ (";
	ЗаголовокПользователи = ИмяПрава + "Users, имеющие доступ (";

	CurrentData = Items.ObjectsTree.CurrentData;
	If CurrentData <> Undefined And CurrentData.NodeType = "MetadataObject" Then
		If StrFind(CurrentData.FullName, "Role.") = 1 Then
			ЗаголовокРоли = "";
			ЗаголовокПользователи = "Users, имеющие данную роль (";
		ElsIf StrFind(CurrentData.FullName, "User.") = 1 Then
			ЗаголовокРоли = "Roles данного пользователя (";
			ЗаголовокПользователи = "";
		EndIf;
	EndIf;

	If IsBlankString(ЗаголовокРоли) Then
		Items.RolesDecoration.Title = "For заданного объекта не используются";
	Else
		Items.RolesDecoration.Title = ЗаголовокРоли + RolesWithAccessTable.Count() + " шт.)";
	EndIf;

	If IsBlankString(ЗаголовокПользователи) Then
		Items.UsersDecoration.Title = "For заданного объекта не используются";
	Else
		Items.UsersDecoration.Title = ЗаголовокПользователи + UsersWithAccessTable.Count()
			+ " шт.)";
	EndIf;

EndProcedure

&AtServerNoContext
Function вПолучитьПраваДоступаКОбъекту(Val ИмяПрава, Val FullName, АдресТаблицыРолиИПользователи,
	Val UUID)
	СтрукРезультат = New Structure("ЕстьДанные, Roles, Users", False);

	ТабРоли = New ValueTable;
	ТабРоли.Cols.Add("Name", New TypeDescription("String"));
	ТабРоли.Cols.Add("Synonym", New TypeDescription("String"));

	ТабПользователи = New ValueTable;
	ТабПользователи.Cols.Add("Name", New TypeDescription("String"));
	ТабПользователи.Cols.Add("FullName", New TypeDescription("String"));
	If StrFind(FullName, ".Command.") <> 0 Then
		ТипМД = "ОбщаяКоманда";
	Else
		ТипМД = Left(FullName, StrFind(FullName, ".") - 1);
	EndIf;

	If ТипМД <> "User" Then
		ОбъектМД = Metadata.FindByFullName(FullName);

		If ОбъектМД = Undefined Then
			Return СтрукРезультат;
		EndIf;
	EndIf;

	ЭтоОбычныйРежим = (ИмяПрава <> "Х");

	If ЭтоОбычныйРежим And IsBlankString(ИмяПрава) Then
		Return СтрукРезультат;
	EndIf;
	If ЭтоОбычныйРежим Then
		For Each Item In Metadata.Roles Do
			If AccessRight(ИмяПрава, ОбъектМД, Item) Then
				FillPropertyValues(ТабРоли.Add(), Item);
			EndIf;
		EndDo;

		ТабРоли.Sort("Name");
	EndIf;
	If IsBlankString(АдресТаблицыРолиИПользователи) Then
		__ТабРолиИПользователи = New ValueTable;
		__ТабРолиИПользователи.Cols.Add("ИмяР", New TypeDescription("String"));
		__ТабРолиИПользователи.Cols.Add("ИмяП", New TypeDescription("String"));
		__ТабРолиИПользователи.Cols.Add("ПолноеИмяП", New TypeDescription("String"));

		For Each П In InfoBaseUsers.GetUsers() Do
			For Each Р In П.Roles Do
				НС = __ТабРолиИПользователи.Add();
				НС.ИмяР = Р.Name;
				НС.ИмяП = П.Name;
				НС.ПолноеИмяП = П.FullName;
			EndDo;
		EndDo;

		__ТабРолиИПользователи.Indexes.Add("ИмяР");
		__ТабРолиИПользователи.Indexes.Add("ИмяП");
		АдресТаблицыРолиИПользователи = PutToTempStorage(__ТабРолиИПользователи, UUID);
	Else
		__ТабРолиИПользователи = GetFromTempStorage(АдресТаблицыРолиИПользователи);
	EndIf;
	If ЭтоОбычныйРежим Then
		СтрукР = New Structure("ИмяР");
		СтрукП = New Structure("Name");

		For Each Стр In ТабРоли Do
			СтрукР.ИмяР = Стр.Name;
			For Each СтрХ In __ТабРолиИПользователи.FindRows(СтрукР) Do
				СтрукП.Name = СтрХ.ИмяП;
				If ТабПользователи.FindRows(СтрукП).Count() = 0 Then
					НС = ТабПользователи.Add();
					НС.Name = СтрХ.ИмяП;
					НС.FullName = СтрХ.ПолноеИмяП;
				EndIf;
			EndDo;
		EndDo;

		ТабПользователи.Sort("Name");
	EndIf;

	If Not ЭтоОбычныйРежим Then
		If ТипМД = "Role" Then
			ИмяР = Mid(FullName, StrFind(FullName, ".") + 1);
			For Each Стр In __ТабРолиИПользователи.FindRows(New Structure("ИмяР", ИмяР)) Do
				НС = ТабПользователи.Add();
				НС.Name = Стр.ИмяП;
				НС.FullName = Стр.ПолноеИмяП;
			EndDo;
			ТабПользователи.Sort("Name");

		ElsIf ТипМД = "User" Then
			ИмяП = Mid(FullName, StrFind(FullName, ".") + 1);
			For Each Стр In __ТабРолиИПользователи.FindRows(New Structure("ИмяП", ИмяП)) Do
				НС = ТабРоли.Add();
				НС.Name = Стр.ИмяР;
			EndDo;
			ТабРоли.Sort("Name");
		EndIf;
	EndIf;

	СтрукРезультат.ЕстьДанные = True;
	СтрукРезультат.Roles = New Array;
	СтрукРезультат.Users = New Array;

	For Each Стр In ТабРоли Do
		_Structure = New Structure("Name, Synonym");
		FillPropertyValues(_Structure, Стр);
		СтрукРезультат.Roles.Add(_Structure);
	EndDo;

	For Each Стр In ТабПользователи Do
		_Structure = New Structure("Name, FullName");
		FillPropertyValues(_Structure, Стр);
		СтрукРезультат.Users.Add(_Structure);
	EndDo;

	Return СтрукРезультат;
EndFunction

&AtClient
Procedure vFillAccessRights()
	For Each Item In mDescriptionAccessRights Do
		НС = VerifiableRightsTable.Add();
		НС.MetadataObject = Item.Key;
		Поз = StrFind(Item.Value, ",");
		НС.Right = ?(Поз = 0, Item.Value, Left(Item.Value, Поз - 1));
	EndDo;

	VerifiableRightsTable.Sort("MetadataObject");
EndProcedure

&AtClient
Procedure ТабПроверяемыеПраваПриНачалеРедактирования(Item, NewLine, Copy)
	CurrentData = Item.CurrentData;
	_Structure = New Structure(mDescriptionAccessRights[CurrentData.MetadataObject]);

	ЭФ = Items.VerifiableRightsTableRight;
	ЭФ.ChoiceList.Clear();
	For Each Item In _Structure Do
		ЭФ.ChoiceList.Add(Item.Key);
	EndDo;
EndProcedure

&AtClient
Procedure ТабРолиСДоступомВыбор(Item, SelectedRow, Field, StandardProcessing)
	StandardProcessing = False;

	CurrentData = Items.RolesWithAccessTable.CurrentData;
	If CurrentData <> Undefined Then
		пПолноеИмя = "Role." + CurrentData.Name;
		СтрукПараметры = New Structure("FullName, PathToForms, _StorageAddresses, ОписаниеПравДоступа", пПолноеИмя,
			PathToForms, _StorageAddresses, mDescriptionAccessRights);
		СтрукПараметры.Insert("НастройкиОбработки", vFormStructureOfObjectPropertiesFormSettings());
		OpenForm(PathToForms + "ФормаСвойств", СтрукПараметры, , пПолноеИмя, , , ,
			FormWindowOpeningMode.Independent);
	EndIf;
EndProcedure

&AtClient
Procedure ТабПользователиСДоступомВыбор(Item, SelectedRow, Field, StandardProcessing)
	StandardProcessing = False;

	CurrentData = Items.UsersWithAccessTable.CurrentData;
	If CurrentData <> Undefined Then
		пИдентификаторПользователя = vGetUserId(CurrentData.Name);

		If Not IsBlankString(пИдентификаторПользователя) Then
			pStructure = New Structure("РежимРаботы, DBUserID", 0, пИдентификаторПользователя);
			OpenForm(PathToForms + "ФормаПользовательИБ", pStructure, , , , , ,
				FormWindowOpeningMode.LockOwnerWindow);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure vFormDescriptionOfAccessRights()
	ПереченьА = "Read, Create, Update, Delete, Browse, Edit";
	ПереченьБ = "Read, Update, Browse, Edit, УправлениеИтогами";

	mDescriptionAccessRights = New Map;
	mDescriptionAccessRights.Insert("Подсистема", "Browse");
	mDescriptionAccessRights.Insert("ПараметрСеанса", "Receive, Установка");
	mDescriptionAccessRights.Insert("ОбщийРеквизит", "Browse, Edit");
	mDescriptionAccessRights.Insert("ExchangePlan", ПереченьА);
	mDescriptionAccessRights.Insert("FilterCriterion", "Browse");
	mDescriptionAccessRights.Insert("ОбщаяФорма", "Browse");
	mDescriptionAccessRights.Insert("ОбщаяКоманда", "Browse");
	mDescriptionAccessRights.Insert("ЧужаяКоманда", "Browse");
	mDescriptionAccessRights.Insert("WebСервис.Property", "Use");
	mDescriptionAccessRights.Insert("HTTPСервис.Property", "Use");
	mDescriptionAccessRights.Insert("Constant", "Read, Update, Browse, Edit");
	mDescriptionAccessRights.Insert("Catalog", ПереченьА);
	mDescriptionAccessRights.Insert("Document", ПереченьА + ", Posting, UndoPosting");
	mDescriptionAccessRights.Insert("Sequence", "Read, Update");
	mDescriptionAccessRights.Insert("DocumentJournal", "Read, Browse");
	mDescriptionAccessRights.Insert("Report", "Use, Browse");
	mDescriptionAccessRights.Insert("Processing", "Use, Browse");
	mDescriptionAccessRights.Insert("ChartOfCharacteristicTypes", ПереченьА);
	mDescriptionAccessRights.Insert("ChartOfCalculationTypes", ПереченьА);
	mDescriptionAccessRights.Insert("ChartOfAccounts", ПереченьА);
	mDescriptionAccessRights.Insert("InformationRegister", ПереченьБ);
	mDescriptionAccessRights.Insert("AccumulationRegister", ПереченьБ);
	mDescriptionAccessRights.Insert("AccountingRegister", ПереченьБ);
	mDescriptionAccessRights.Insert("CalculationRegister", "Read, Update, Browse, Edit");
	mDescriptionAccessRights.Insert("BusinessProcess", ПереченьА + ", Start");
	mDescriptionAccessRights.Insert("Task", ПереченьА + ", Выполнение");

EndProcedure

&AtClient
Procedure kCalculateObjectsNumber(Command)
	CurrentData = Items.ObjectsTree.CurrentData;

	If CurrentData <> Undefined Then
		If CurrentData.NodeType = "MetadataObject" Then
			Перечень = "Sequence, ExchangePlan, Catalog, Document, DocumentJournal, ChartOfCharacteristicTypes
					   |, ChartOfCalculationTypes, ChartOfAccounts, InformationRegister, AccumulationRegister, AccountingRegister, CalculationRegister, BusinessProcess, Task";

			_Structure = New Structure(Перечень);
			ТипМД = Left(CurrentData.FullName, StrFind(CurrentData.FullName, ".") - 1);

			If Not _Structure.Property(ТипМД) Then
				Return;
			EndIf;

			МассивОбъектов = New Array;

			_Structure = New Structure("FullName, NumberOfObjects", CurrentData.FullName);
			МассивОбъектов.Add(_Structure);

			РодительДЗ = CurrentData.GetParent();

			РодительДЗ.NumberOfObjects = РодительДЗ.NumberOfObjects - CurrentData.NumberOfObjects;

			вРассчитатьКоличествоОбъектов(МассивОбъектов);
			CurrentData.NumberOfObjects = МассивОбъектов[0].NumberOfObjects;

			РодительДЗ.NumberOfObjects = РодительДЗ.NumberOfObjects + CurrentData.NumberOfObjects;

		ElsIf CurrentData.NodeType = "SectionMD" Then
			TreeLines = CurrentData.GetItems();
			If TreeLines.Count() = 1 And IsBlankString(TreeLines[0].NodeType) Then
				Return;
			EndIf;

			Перечень = "Sequences, ExchangePlans, Catalogs, Documents, DocumentJournals, ChartsOfCharacteristicTypes
					   |, ChartsOfCalculationTypes, ChartsOfAccounts, InformationRegisters, AccumulationRegisters, AccountingRegisters, CalculationRegisters, BusinessProcesses, Tasks";

			_Structure = New Structure(Перечень);
			Поз = StrFind(CurrentData.Name, " ");
			If Поз = 0 Then
				ИмяРаздела = CurrentData.Name;
			Else
				ИмяРаздела = Left(CurrentData.Name, Поз - 1);
			EndIf;

			If Not _Structure.Property(ИмяРаздела) Then
				Return;
			EndIf;

			МассивОбъектов = New Array;

			For Each Стр In TreeLines Do
				If Стр.NodeType = "MetadataObject" Then
					_Structure = New Structure("ID, FullName, NumberOfObjects",
						Стр.GetID(), Стр.FullName);
					МассивОбъектов.Add(_Structure);
				EndIf;
			EndDo;

			вРассчитатьКоличествоОбъектов(МассивОбъектов);

			ObjectCount = 0;
			For Each Стр In МассивОбъектов Do
				TreeLine = ObjectsTree.FindByID(Стр.ID);
				If TreeLine <> Undefined Then
					ObjectCount= ObjectCount + Стр.NumberOfObjects;
					TreeLine.NumberOfObjects = Стр.NumberOfObjects;
				EndIf;
			EndDo;
			CurrentData.NumberOfObjects = ObjectCount;

		EndIf;
	EndIf;
EndProcedure

&AtServerNoContext
Function вРассчитатьКоличествоОбъектов(МассивОбъектов)
	SetPrivilegedMode(True);

	пИспользоватьПопытку = Not PrivilegedMode() And Not vIsAdministratorRights();

	For Each Item In МассивОбъектов Do
		Query = New Query;
		Query.Text = "ВЫБРАТЬ
					   |	КОЛИЧЕСТВО(*) КАК NumberOfObjects
					   |ИЗ
					   |	" + Item.FullName + " КАК ТаблицаБД";

		If пИспользоватьПопытку Then
			Try
				Выборка = Query.Execute().StartChoosing();
				Item.NumberOfObjects = ?(Выборка.Next(), Выборка.ObjectCount, 0);
			Except
				Item.NumberOfObjects = 0;
			EndTry;
		Else
			Выборка = Query.Execute().StartChoosing();
			Item.NumberOfObjects = ?(Выборка.Next(), Выборка.ObjectCount, 0);
		EndIf;

	EndDo;

	Return True;
EndFunction
&AtClient
Procedure _ПоказыватьСтандартныеНастройкиПриИзменении(Item)
	Items.DefaultSettingsPage.Visible = _ShowStandardSettings;
EndProcedure

&AtClient
Procedure _ПоказыватьТаблицыИИндексыБДПриИзменении(Item)
	Items.StorageStructurePage.Visible = _ShowTablesAndIndexesDB;
EndProcedure


// работа с разделом "Favorites..."
&AtClient
Procedure _AddToFavorites(Command)
	CurrentData = Items.ObjectsTree.CurrentData;
	If CurrentData <> Undefined Then
		If CurrentData.NodeType = "MetadataObject" Then
			TreeLine = ObjectsTree.FindByID(mFavoriteID).GetItems().Add();
			FillPropertyValues(TreeLine, CurrentData);
			вВключитьФлагИзмененияНастроек();
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure _DeleteFromFavorites(Command)
	CurrentData = Items.ObjectsTree.CurrentData;
	If CurrentData <> Undefined Then
		If Not IsBlankString(CurrentData.FullName) Then
			TreeLines = ObjectsTree.FindByID(mFavoriteID).GetItems();
			For Each TreeLine In TreeLines Do
				If TreeLine.FullName = CurrentData.FullName Then
					TreeLines.Delete(TreeLine);
					вВключитьФлагИзмененияНастроек();
					Break;
				EndIf;
			EndDo;
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure вВключитьФлагИзмененияНастроек()
	_DateOfSettingsChange = CurrentDate();
EndProcedure

&AtClient
Procedure _ClearFavorites(Command)
	ObjectsTree.FindByID(mFavoriteID).GetItems().Clear();
	вВключитьФлагИзмененияНастроек();
EndProcedure

&AtClient
Procedure _OderFavorites(Command)
	вУпорядочитьИзбранное(); // плохой способ

	For Each TreeLine In ObjectsTree.GetItems() Do
		If TreeLine.FullName = "Favorites" Then
			mFavoriteID = TreeLine.GetID();
			Break;
		EndIf;
	EndDo;

	вВключитьФлагИзмененияНастроек();
EndProcedure

&AtServer
Procedure вУпорядочитьИзбранное()
	пДерево = FormAttributeToValue("ObjectsTree");
	пДерево.Rows.Find("Favorites", "FullName", False).Rows.Sort("FullName");
	ValueToFormAttribute(пДерево, "ObjectsTree");
EndProcedure
&AtClient
Procedure _OpenObjectsEditor(Command)
	СтрукПарам = New Structure;
	СтрукПарам.Insert("мОбъектСсылка", Undefined);
	OpenForm("Processing.UT_ObjectsAttributesEditor.Form", СтрукПарам, , CurrentDate());
EndProcedure

&AtClient
Procedure _UpdateNumberingOfObjects(Command)
	CurrentData = Items.ObjectsTree.CurrentData;
	If CurrentData <> Undefined Then
		If CurrentData.NodeType = "MetadataObject" Or CurrentData.NodeType = "Configuration" Then
			If Not vIsAdministratorRights() Then
				vShowMessageBox("None прав на выполнение операции!");
				Return;
			EndIf;

			пТекст = ?(CurrentData.NodeType = "Configuration", "Нумерация всех объектов будет обновлена. Continue?",
				"Нумерация обекта будет обновлена. Continue?");
			ShowQueryBox(New NotifyDescription("вОбновитьНумерациюОбъектовОтвет", ThisForm, CurrentData.FullName),
				пТекст, QuestionDialogMode.YesNoCancel, 20);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure _UpdateNumberingOfAllObjects(Command)
	пТекст = "Нумерация всех объектов будет обновлена. Continue?";
	ShowQueryBox(New NotifyDescription("вОбновитьНумерациюОбъектовОтвет", ThisForm, "Configuration"), пТекст,
		QuestionDialogMode.YesNoCancel, 20);
EndProcedure

&AtClient
Procedure вОбновитьНумерациюОбъектовОтвет(РезультатВопроса, ДопПарам = Undefined) Export
	If РезультатВопроса = DialogReturnCode.Yes Then
		вОбновитьНумерациюОбъектов(ДопПарам);
	EndIf;
EndProcedure

&AtServerNoContext
Function вОбновитьНумерациюОбъектов(Val FullName)
	If FullName = "Configuration" Then
		Try
			RefreshObjectsNumbering();
		Except
			Message(BriefErrorDescription(ErrorInfo()));
		EndTry;

	ElsIf StrFind(FullName, ".") <> 0 Then
		ОбъектМД = Metadata.FindByFullName(FullName);

		If ОбъектМД <> Undefined Then
			Try
				RefreshObjectsNumbering(ОбъектМД);
			Except
				Message(BriefErrorDescription(ErrorInfo()));
			EndTry;
		EndIf;
	EndIf;

	Return True;
EndFunction

// работа со структурой хранения базы данных (таблицы и индексы)
&AtClient
Procedure _FillInSchema(Command)
	_Indexes.Clear();
	_Tables.Clear();

	вЗаполнитьСХ();

	Items._IndexesPage.Title = "All индексы БД (" + _Indexes.Count() + ")";
	Items.TablePage.Title = "All таблицы БД (" + _Tables.Count() + ")";
EndProcedure

&AtServer
Procedure вЗаполнитьСХ()
	ТабРезультат = GetDBStorageStructureInfo( , Not _ShowStorageStructureInTermsOf1C);

	For Each Стр In ТабРезультат Do
		НС = _Tables.Add();
		FillPropertyValues(НС, Стр);

		If НС.TableName = "" Then
			НС.TableName = "<не задано>";
		EndIf;
		If НС.Metadata = "" Then
			НС.Metadata = "<не задано>";
		EndIf;

		For Each СтрХ In Стр.Indexes Do
			НС = _Indexes.Add();
			НС.IndexName = СтрХ.IndexName;
			FillPropertyValues(НС, Стр, "TableName, Metadata");
			If НС.Metadata = "" Then
				НС.Metadata = "<не задано>";
			EndIf;
		EndDo;
	EndDo;

EndProcedure

&AtClient
Procedure _СХТаблицыВыбор(Item, SelectedRow, Field, StandardProcessing)
	StandardProcessing = False;
	kShowObjectProperties(Undefined);
EndProcedure

&AtClient
Procedure _СХИндексыВыбор(Item, SelectedRow, Field, StandardProcessing)
	StandardProcessing = False;
	kShowObjectProperties(Undefined);
EndProcedure

&AtClient
Procedure _MoveToTableFromIndex(Command)
	CurrentData = Items._Indexes.CurrentData;
	If CurrentData <> Undefined Then
		Array = _Tables.FindRows(New Structure("TableName", CurrentData.TableName));
		If Array.Count() <> 0 Then
			String = Array[0].GetID();
			ТекСтрока = _Tables.FindByID(String);
			If ТекСтрока <> Undefined Then
				Items._Tables.CurrentLine = String;
				Items.TableAndIndexesGrpip.CurrentPage = Items.TablePage;
			EndIf;
		EndIf;
	EndIf;
EndProcedure


// работа с пользователями ИБ
&AtClient
Procedure _FillInDBUsersList(Command)
	_DBUserList.Clear();

	пПереченьПолей = "OpenIDAuthentication, AuthenticationOS, StandartAuthentication, Name, PasswordIsSet,
					 |StandartAuthentication, FullName, OSUser, LaunchMode, UUID,
					 |ListOfRoles";

	pArray = вПолучитьПользователейИБ(пПереченьПолей, _ShowUserRolesList);
	For Each Item In pArray Do
		FillPropertyValues(_DBUserList.Add(), Item);
	EndDo;

	_DBUserList.Sort("Name");

	If Items._DBUserListListOfRoles.Visible <> _ShowUserRolesList Then
		Items._DBUserListListOfRoles.Visible = _ShowUserRolesList;
	EndIf;

	Items.DBUsers.Title = "Users (" + pArray.Count() + ")";
EndProcedure

&AtServerNoContext
Function вПолучитьПользователейИБ(Val пПереченьПолей, Val пЗаполнятьПереченьРолнй = False)
	pResult = New Array;

	For Each Item In InfoBaseUsers.GetUsers() Do
		pStructure = New Structure(пПереченьПолей);
		FillPropertyValues(pStructure, Item);

		If пЗаполнятьПереченьРолнй Then
			пСписокРолей = New ValueList;
			For Each пРоль In Item.Roles Do
				пСписокРолей.Add(пРоль.Name);
			EndDo;
			пСписокРолей.SortByValue();

			пПереченьРолей = "";
			For Each пРоль In пСписокРолей Do
				пПереченьРолей = пПереченьРолей + ", " + пРоль.Value;
			EndDo;
			pStructure.ListOfRoles = Mid(пПереченьРолей, 2);
		EndIf;

		pResult.Add(pStructure);
	EndDo;

	Return pResult;
EndFunction

&AtClient
Procedure _СписокПользователейИБВыбор(Item, SelectedRow, Field, StandardProcessing)
	StandardProcessing = False;

	CurrentData = _DBUserList.FindByID(SelectedRow);
	If CurrentData <> Undefined Then
		pStructure = New Structure("РежимРаботы, DBUserID", 0, CurrentData.UUID);
		OpenForm(PathToForms + "ФормаПользовательИБ", pStructure, , , , , ,
			FormWindowOpeningMode.LockOwnerWindow);
	EndIf;
EndProcedure

&AtClient
Procedure _СписокПользователейИБПередНачаломДобавления(Item, Cancel, Copy, Parent, Group, Parameter)
	Cancel = True;

	If Copy Then
		CurrentData = Item.CurrentData;
		If CurrentData <> Undefined Then
			pStructure = New Structure("РежимРаботы, DBUserID", 2, CurrentData.UUID);
			OpenForm(PathToForms + "ФормаПользовательИБ", pStructure, , , , , ,
				FormWindowOpeningMode.LockOwnerWindow);
		EndIf;
	Else
		pStructure = New Structure("РежимРаботы", 1);
		OpenForm(PathToForms + "ФормаПользовательИБ", pStructure, , , , , ,
			FormWindowOpeningMode.LockOwnerWindow);
	EndIf;
EndProcedure

&AtClient
Procedure _СписокПользователейИБПередУдалением(Item, Cancel)
	Cancel = True;

	пВыделенныеСтроки = Item.SelectedRows;
	пЧисло = пВыделенныеСтроки.Count();

	If пЧисло = 0 Then
		Return;
	ElsIf пЧисло = 1 Then
		пТекст = StrTemplate("User ""%1"" будет удален из информационной базы!
						   |Continue?", _DBUserList.FindByID(пВыделенныеСтроки[0]).Name);
	Else
		пТекст = StrTemplate("Отмеченные пользователи (%1 шт) будут удалены из информационной базы!
						   |Continue?", пЧисло);
	EndIf;

	vShowQueryBox(пТекст, "вУдалитьПользователейИБОтвет", пВыделенныеСтроки);
EndProcedure

&AtClient
Procedure вУдалитьПользователейИБОтвет(Ответ, пВыделенныеСтроки) Export
	If Ответ = DialogReturnCode.Yes Then
		pArray = New Array;
		For Each Стр In пВыделенныеСтроки Do
			CurrentData = _DBUserList.FindByID(Стр);
			If CurrentData <> Undefined Then
				pArray.Add(CurrentData.UUID);
			EndIf;
		EndDo;

		If pArray.Count() <> 0 Then
			пМассивУдаленных = вУдалитьПользователейИБ(pArray);
			For Each Item In пМассивУдаленных Do
				For Each СтрХ In _DBUserList.FindRows(New Structure("UUID",
					Item)) Do
					_DBUserList.Delete(СтрХ);
				EndDo;
			EndDo;
		EndIf;
	EndIf;
EndProcedure

&AtServerNoContext
Function вУдалитьПользователейИБ(Val пМассивИдентификаторов)
	pResult = New Array;

	пТекПользователь = InfoBaseUsers.CurrentUser();

	For Each Item In пМассивИдентификаторов Do
		Try
			пUUID = New UUID(Item);

			vUser = InfoBaseUsers.FindByUUID(пUUID);
			If vUser = Undefined Or (пТекПользователь <> Undefined
				And пТекПользователь.UUID = пUUID) Then
				Continue;
			EndIf;

			vUser.Delete();
			pResult.Add(Item);
		Except
			Message(BriefErrorDescription(ErrorInfo()));
		EndTry;
	EndDo;

	Return pResult;
EndFunction


// работа с сеансами
&AtClient
Procedure _SetSessionsLock(Command)
	OpenForm(PathToForms + "ФормаБлокировкиСеансов", , ThisForm, , , , ,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure _FillInSessionsList(Command)
	_SessionList.Clear();

	пПереченьПолей = "CurrentSession, ComputerName, ApplicationName, ApplicationPresentation, SessionStart, SessionNumber, ConnectionNumber, User, DBUserID,
					 |MethodName, Key, Start, End, Name, Placement, ScheduledJob, State, BackgroundJobID";

	pArray = вПолучитьСенансы(пПереченьПолей);

	For Each Item In pArray Do
		FillPropertyValues(_SessionList.Add(), Item);
	EndDo;

	_SessionList.Sort("SessionStart");

	Items.SessionsGroup.Title = "Сеансы информационной базы (" + pArray.Count() + ")";
EndProcedure

&AtServerNoContext
Function вПолучитьСенансы(Val пПереченьПолей)
	SetPrivilegedMode(True);

	пТекНомерСеанса = InfoBaseSessionNumber();

	pResult = New Array;

	For Each Item In GetInfoBaseSessions() Do
		pStructure = New Structure(пПереченьПолей);
		FillPropertyValues(pStructure, Item);

		pStructure.CurrentSession = (Item.SessionNumber = пТекНомерСеанса);

		pStructure.ApplicationPresentation = ApplicationPresentation(pStructure.ApplicationName);

		pStructure.User = String(pStructure.User);

		If Item.User <> Undefined Then
			pStructure.DBUserID = String(Item.User.UUID);
		EndIf;

		пФоновоеЗадание = Item.GetBackgroundJob();
		If пФоновоеЗадание <> Undefined Then
			FillPropertyValues(pStructure, пФоновоеЗадание);
			pStructure.State = String(пФоновоеЗадание.Status);
			pStructure.ScheduledJob = String(пФоновоеЗадание.ScheduledJob);
			pStructure.BackgroundJobID = String(пФоновоеЗадание.UUID);
		EndIf;

		pResult.Add(pStructure);
	EndDo;

	Return pResult;
EndFunction

&AtClient
Procedure _FillInConnectionsList(Command)
	_ConnectionsList.Clear();

	пПереченьПолей = "ТекущееСоединение, Active, ComputerName, ApplicationName, ApplicationPresentation, SessionStart, SessionNumber, ConnectionNumber, User, DBUserID";

	pArray = вПолучитьСоединения(пПереченьПолей);

	For Each Item In pArray Do
		FillPropertyValues(_ConnectionsList.Add(), Item);
	EndDo;

	_ConnectionsList.Sort("SessionStart");

	Items.ConnectionsGroup.Title = "Joins информационной базы (" + pArray.Count() + ")";
EndProcedure

&AtServerNoContext
Function вПолучитьСоединения(Val пПереченьПолей)
	SetPrivilegedMode(True);

	пТекНомерСоединения = InfoBaseConnectionNumber();

	pResult = New Array;

	For Each Item In GetInfoBaseConnections() Do
		pStructure = New Structure(пПереченьПолей);
		FillPropertyValues(pStructure, Item);

		pStructure.ТекущееСоединение = (Item.ConnectionNumber = пТекНомерСоединения);

		pStructure.Active = ValueIsFilled(Item.SessionNumber);

		pStructure.ApplicationPresentation = ApplicationPresentation(pStructure.ApplicationName);

		pStructure.User = String(pStructure.User);

		If Item.User <> Undefined Then
			pStructure.DBUserID = String(Item.User.UUID);
		EndIf;

		pResult.Add(pStructure);
	EndDo;

	Return pResult;
EndFunction
&AtClient
Procedure _FinishSessions(Command)
	пВыделенныеСтроки = Items._SessionList.SelectedRows;
	If пВыделенныеСтроки.Count() = 0 Then
		Return;
	EndIf;

	пМассивСеансов = New Array;
	For Each Item In пВыделенныеСтроки Do
		Стр = _SessionList.FindByID(Item);
		If Not Стр.CurrentSession Then
			пМассивСеансов.Add(Стр.SessionNumber);
		EndIf;
	EndDo;

	If пМассивСеансов.Count() = 0 Then
		vShowMessageBox("Невозможно завершить текущий сеанс!
								|For выхода из программы можно закрыть главное окно программы.");
		Return;
	EndIf;

	пТекст = StrTemplate("Отмеченные сеансы (%1 шт) будут завершены.
					   |Continue?", пМассивСеансов.Count());

	vShowQueryBox(пТекст, "вЗавершитьСеансыОтвет", пМассивСеансов);
EndProcedure

&AtClient
Procedure вЗавершитьСеансыОтвет(Ответ, пМассивСеансов) Export
	If Ответ = DialogReturnCode.Yes Then
		If mClusterParameters = Undefined Then
			mClusterParameters = вПолучитьПараметрыКластера1С();
		EndIf;

		If mClusterParameters.ФайловыйВариантИБ Then
			Items._SessionList_FinishSessions.Enabled = False;
			Items.ClusterAdministratorGroup.ReadOnly = True;
			vShowMessageBox("End сеансов реализовано только для клиент-серверного варианта!");
			Return;
		EndIf;

		Try
			вЗавершитьСеансы(пМассивСеансов);
		Except
			Message(вСформироватьОписаниеОшибки(ErrorInfo()));
		EndTry;

		_FillInSessionsList(Undefined);
	EndIf;
EndProcedure

&AtClientAtServerNoContext
Function вСформироватьОписаниеОшибки(Val пИнфоОбОшибке)
	пТекст = пИнфоОбОшибке.LongDesc;

	While True Do
		If пИнфоОбОшибке.Reason <> Undefined Then
			пТекст = пТекст + "
							  |" + пИнфоОбОшибке.Reason.LongDesc;
			пИнфоОбОшибке = пИнфоОбОшибке.Reason;
		Else
			Break;
		EndIf;
	EndDo;

	Return пТекст;
EndFunction
&AtClient
Procedure вЗавершитьСеансы(пМассивСеансов)
	COMСоединитель = New COMObject(mClusterParameters.ИмяCOMСоединителя, mClusterParameters.СерверCOMСоединителя);

	пСоединениеСАгентомСервера = вСоединениеСАгентомСервера(
		COMСоединитель, mClusterParameters.АдресАгентаСервера, mClusterParameters.ПортАгентаСервера);

	пКластер = вПолучитьКластер(
		пСоединениеСАгентомСервера, mClusterParameters.ПортКластера, _ClusterAdministratorName, ?(IsBlankString(
		_ClusterAdministratorName), "", _ClusterAdministratorPassword));

	пСеансыКУдалению = New Array;

	For Each Сеанс In пСоединениеСАгентомСервера.GetSessions(пКластер).Unload() Do
		If пМассивСеансов.Find(Сеанс.SessionID) <> Undefined Then
			пСеансыКУдалению.Add(Сеанс);
		EndIf;
	EndDo;

	For Each Сеанс In пСеансыКУдалению Do
		UserInterruptProcessing();

		Try
			пСоединениеСАгентомСервера.TerminateSession(пКластер, Сеанс);
		Except
		EndTry;
	EndDo;
EndProcedure

&AtClient
Function вСоединениеСАгентомСервера(COMСоединитель, Val АдресАгентаСервера, Val ПортАгентаСервера)

	пСтрокаСоединенияСАгентомСервера = "tcp://" + АдресАгентаСервера + ":" + Format(ПортАгентаСервера, "ЧГ=0");
	пСоединениеСАгентомСервера = COMСоединитель.ConnectAgent(пСтрокаСоединенияСАгентомСервера);

	Return пСоединениеСАгентомСервера;

EndFunction

&AtClient
Function вПолучитьКластер(СоединениеСАгентомСервера, Val ПортКластера, Val ИмяАдминистратораКластера,
	Val ПарольАдминистратораКластера)

	For Each Кластер In СоединениеСАгентомСервера.GetClusters() Do

		If Кластер.MainPort = ПортКластера Then

			СоединениеСАгентомСервера.Authenticate(Кластер, ИмяАдминистратораКластера, ПарольАдминистратораКластера);

			Return Кластер;

		EndIf;

	EndDo;

	Raise StrTemplate("На рабочем сервере %1 не найден кластер %2", СоединениеСАгентомСервера.ConnectionString,
		ПортКластера);

EndFunction

&AtServerNoContext
Function вПолучитьПараметрыКластера1С()
	pResult = New Structure;

	пСистемнаяИнфо = New SystemInfo;
	пСтрокаСоединения = InfoBaseConnectionString();

	pResult.Insert("ФайловыйВариантИБ", (Find(Врег(пСтрокаСоединения), "FILE=") = 1));
	pResult.Insert("СерверCOMСоединителя", "");
	pResult.Insert("ПортАгентаСервера", 1540);
	pResult.Insert("ПортКластера", 1541);
	pResult.Insert("АдресАгентаСервера", "LocalHost");
	pResult.Insert("ИмяАдминистратораКластера", "");
	pResult.Insert("ПарольАдминистратораКластера", "");
	pResult.Insert("ИмяВКластере", "");
	pResult.Insert("ТипПодключения", "COM");
	pResult.Insert("ИмяCOMСоединителя", "V83.COMConnector");
	pResult.Insert("ИмяАдминистратораИнформационнойБазы", InfoBaseUsers.CurrentUser().Name);
	pResult.Insert("ПарольАдминистратораИнформационнойБазы", "");
	pResult.Insert("Платформа1С", "83");

	пМассивСтр = StrSplit(пСтрокаСоединения, ";", False);

	пЗначение = StrReplace(вЗначениеКлючаСтроки(пМассивСтр, "Srvr"), """", "");
	Поз = Find(пЗначение, ":");
	If Поз <> 0 Then
		pResult.Insert("АдресАгентаСервера", TrimAll(Mid(пЗначение, 1, Поз - 1)));
		pResult.Insert("ПортКластера", Number(Mid(пЗначение, Поз + 1)));
	Else
		pResult.Insert("АдресАгентаСервера", пЗначение);
		pResult.Insert("ПортКластера", 1541);
	EndIf;
	pResult.ПортАгентаСервера = pResult.ПортКластера - 1;

	pResult.Insert("ИмяВКластере", StrReplace(вЗначениеКлючаСтроки(пМассивСтр, "Ref"), """", ""));

	pResult.Insert("AppVersion", пСистемнаяИнфо.AppVersion);
	pResult.Insert("BinDir", BinDir());

	If Find(pResult.AppVersion, "8.4.") = 1 Then
		pResult.Insert("ИмяCOMСоединителя", "V84.COMConnector");
		pResult.Insert("Платформа1С", "84");
	EndIf;

	Return pResult;
EndFunction

&AtServerNoContext
Function вЗначениеКлючаСтроки(МассивСтрок, Key, DefaultValue = "") Export
	КлючВР = Upper(Key) + "=";
	For Each Стр In МассивСтрок Do
		пЗначение = TrimAll(Стр);
		If Find(Upper(пЗначение), КлючВР) = 1 Then
			Return Mid(пЗначение, StrLen(КлючВР) + 1);
		EndIf;
	EndDo;

	Return DefaultValue;
EndFunction


// РАСШИРЕНИЯ КОНФИГУРАЦИИ
&AtClient
Procedure _FillInExtensionList(Command)
	_ExtensionsList.Clear();

	pArray = вПолучитьСписокРасширений();

	For Each Item In pArray Do
		FillPropertyValues(_ExtensionsList.Add(), Item);
	EndDo;
	
	//вЗаполнитьСписокРасширений();

	_ExtensionsList.Sort("Name");

	Items.ConfigurationExtensions.Title = "Расширения конфигурации (" + _ExtensionsList.Count() + ")";
EndProcedure

&AtServer
Procedure вЗаполнитьСписокРасширений()
	_ExtensionsList.Clear();

	pArray = ConfigurationExtensions.Get();

	For Each Item In pArray Do
		НС = _ExtensionsList.Add();
		FillPropertyValues(НС, Item);
	EndDo;
EndProcedure

&AtClientAtServerNoContext
Function вСформироватьСтруктуруСвойствРасширения(пРежим = 0)
	pStructure = New Structure("Active, SafeMode, Version, UnsafeOperationProtection, Name, Purpose, Scope, Synonym, UUID, HashSum");

	If пРежим = 1 Then
		For Each Item In pStructure Do
			pStructure[Item.Key] = -1;
		EndDo;
	EndIf;

	Return pStructure;
EndFunction

&AtServerNoContext
Function vCheckType(Val pTypeName)
	Try
		pType = Type(pTypeName);
	Except
		Return False;
	EndTry;

	Return True;
EndFunction
&AtServerNoContext
Function вПолучитьСписокРасширений()
	pResult = New Array;

	pArray = ConfigurationExtensions.Get();

	For Each Item In pArray Do
		pStructure = вСформироватьСтруктуруСвойствРасширения(1);
		FillPropertyValues(pStructure, Item);

		If pStructure.UnsafeOperationProtection = -1 Then
			pStructure.UnsafeOperationProtection = Undefined;
		Else
			pStructure.UnsafeOperationProtection = pStructure.UnsafeOperationProtection.UnsafeOperationWarnings;
		EndIf;

		If pStructure.Scope = -1 Then
			pStructure.Scope = Undefined;
		Else
			pStructure.Scope = String(pStructure.Scope);
		EndIf;

		If pStructure.Purpose = -1 Then
			pStructure.Purpose = Undefined;
		Else
			pStructure.Purpose = String(pStructure.Purpose);
		EndIf;

		pResult.Add(pStructure);
	EndDo;

	Return pResult;
EndFunction

&AtClient
Procedure RunConfiguratorUnderUser(Command)
	CurrentData=Items._DBUserList.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.Run1CSession(1, CurrentData.Name, True,
		WaitingTimeBeforePasswordRecovery);
EndProcedure

&AtClient
Procedure RunOrdinaryClientUnderUser(Command)
	CurrentData=Items._DBUserList.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.Run1CSession(2, CurrentData.Name, True,
		WaitingTimeBeforePasswordRecovery);
EndProcedure

&AtClient
Procedure RunThickClientUnderUser(Command)
	CurrentData=Items._DBUserList.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.Run1CSession(3, CurrentData.Name, True,
		WaitingTimeBeforePasswordRecovery);
EndProcedure

&AtClient
Procedure RunThinClientUnderUser(Command)
	CurrentData=Items._DBUserList.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.Run1CSession(4, CurrentData.Name, True,
		WaitingTimeBeforePasswordRecovery);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure





