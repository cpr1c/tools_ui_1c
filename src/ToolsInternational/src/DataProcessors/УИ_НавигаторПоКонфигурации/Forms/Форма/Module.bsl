&AtClient
Var мОбычныеПрикладныеОбъекты;

&AtClient
Var мТекущийОбъектДерева;

&AtClient
Var мОписаниеПравДоступа;

&AtClient
Var мИдентификаторИзбранного;

&AtClient
Var мПараметрыКластера1С;
&AtServer
Function вПолучитьОбработку()
	Return FormAttributeToValue("Object");
EndFunction
&AtClient
Procedure вПоказатьПредупреждение(Text)
	ShowMessageBox( , Text, 20);
EndProcedure

&AtClient
Procedure вПоказатьВопрос(ТекстВопроса, ProcedureName, ДопПараметры = Undefined)
	ShowQueryBox(New NotifyDescription(ProcedureName, ThisForm, ДопПараметры), ТекстВопроса,
		QuestionDialogMode.YesNoCancel, 20);
EndProcedure

&AtClient
Procedure вОперацияНеПоддерживаетсяДляВебКлиента()
	вПоказатьПредупреждение("For Web-клиента данная операция не поддерживается!");
EndProcedure

&AtServerNoContext
Procedure вЗаполнитьКонтекстФормы(_FormContext)
	_FormContext.Insert("SubsystemVersions", (Metadata.InformationRegisters.Find("SubsystemVersions") <> Undefined));
	_FormContext.Insert("ExclusiveMode", ExclusiveMode());
EndProcedure

&AtServerNoContext
Function вЕстьПраваАдминистратора()
	Return AccessRight("Администрирование", Metadata);
EndFunction

&AtServerNoContext
Function вПолучитьИдентификаторПользователя(Val Name)
	пПользователь = InfoBaseUsers.FindByName(Name);

	Return ?(пПользователь = Undefined, "", String(пПользователь.UUID));
EndFunction

&AtClientAtServerNoContext
Function вЗначениеВМассив(Val Value)
	Array = New Array;
	Array.Add(Value);

	Return Array;
EndFunction

&AtServer
Procedure УстановитьУсловноеОформление()
	ThisForm.ConditionalAppearance.Items.Clear();

	ЭлементУО = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = ЭлементУО.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("ObjectsTree.FullName");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = "Конфигурация";
	ЭлементУО.Appearance.SetParameterValue("Font", New Font(Items.ServiceTree.Font, , , True));
	ЭлементУО.Fields.Items.Add().Field = New DataCompositionField("ObjectsTreeName");

	ЭлементУО = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = ЭлементУО.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("ObjectsTree.NodeType");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = 1;
	ЭлементУО.Appearance.SetParameterValue("Text", WebColors.DarkBlue);
	ЭлементУО.Fields.Items.Add().Field = New DataCompositionField("ObjectsTreeName");

	ЭлементУО = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = ЭлементУО.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("ServiceTree.IsGroup");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = True;
	ЭлементУО.Appearance.SetParameterValue("Font", New Font(Items.ServiceTree.Font, , , True));
	ЭлементУО.Fields.Items.Add().Field = New DataCompositionField("ServiceTreePresentation");

	ЭлементУО = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = ЭлементУО.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("ServiceTree.Enabled");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = False;
	ЭлементУО.Appearance.SetParameterValue("Text", New Color(83, 106, 194));
	ЭлементУО.Fields.Items.Add().Field = New DataCompositionField("ServiceTreePresentation");

	ЭлементУО = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = ЭлементУО.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("VerifiableRightsTable.Mark");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = True;
	ЭлементУО.Appearance.SetParameterValue("Font", New Font(Items.VerifiableRightsTable.Font, , ,
		True));
	ЭлементУО.Fields.Items.Add().Field = New DataCompositionField("VerifiableRightsTableMetadataObject");
	ЭлементУО.Fields.Items.Add().Field = New DataCompositionField("VerifiableRightsTableRight");

	ЭлементУО = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = ЭлементУО.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("_SessionList.CurrentSession");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = True;
	ЭлементУО.Appearance.SetParameterValue("Text", WebColors.Blue);
	ЭлементУО.Fields.Items.Add().Field = New DataCompositionField("_SessionList");

	ЭлементУО = ThisForm.ConditionalAppearance.Items.Add();
	FilterItem = ЭлементУО.Filter.Items.Add(Type("DataCompositionFilterItem"));
	FilterItem.LeftValue = New DataCompositionField("_ConnectionsList.ТекущееСоединение");
	FilterItem.ComparisonType = DataCompositionComparisonType.Equal;
	FilterItem.RightValue = True;
	ЭлементУО.Appearance.SetParameterValue("Text", WebColors.Blue);
	ЭлементУО.Fields.Items.Add().Field = New DataCompositionField("_ConnectionsList");

EndProcedure

&AtClient
Function вСформироватьСтруктуруНастроекФормыСвойствОбъекта()
	Струк = New Structure("_ShowObjectSubscribtion, _ShowObjectSubsystems, _ShowCommonObjectCommands, _ShowExternalObjectCommands, _ShowStorageStructureInTermsOf1C");
	FillPropertyValues(Струк, ThisForm);

	Return Струк;
EndFunction

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	PathToForms = вПолучитьОбработку().Metadata().FullName() + ".Form.";

	пЕстьПраваАдминистратора = вЕстьПраваАдминистратора();
	WaitingTimeBeforePasswordRecovery=20;
	
	//Items.SettingsPage.Visible = ложь;
	Items.StorageStructurePage.Visible = False;
	Items.ObjectRightPages.Visible = False;
	Items._DisplayObjectsRights.Enabled = пЕстьПраваАдминистратора;
	Items.ObjectsTreeForAdministrators.Enabled = пЕстьПраваАдминистратора;
	Items.DBUsers.Visible = пЕстьПраваАдминистратора;
	Items._SessionList_FinishSessions.Enabled = пЕстьПраваАдминистратора;
	Items.SessionsPage.Visible = AccessRight("ActiveUsers", Metadata);
	Items._SessionList_FinishSessions.Enabled = пЕстьПраваАдминистратора;

	Items.ConfigurationExtensions.Visible = False;
	//Items.ConfigurationExtensions.Visible = вПроверитьНаличиеТипа("ConfigurationExtension");

	_FormContext = New Structure;
	вЗаполнитьКонтекстФормы(_FormContext);
	вЗаполнитьДеревоСервис();

	_FavoritesContent = New Structure("Version, Data", 1, New Array);

	УстановитьУсловноеОформление();

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

		СтрокиДЗ = ObjectsTree.GetItems();
		If СтрокиДЗ.Count() <> 0 Then
			// перезаполним избранное
			For Each РазделДЗ In СтрокиДЗ Do
				If РазделДЗ.FullName = "Favorites" Then
					РазделДЗ.GetItems().Clear();
					For Each Элем In _FavoritesContent.Data Do
						FillPropertyValues(РазделДЗ.GetItems().Add(), Элем);
					EndDo;
				EndIf;
			EndDo;
		EndIf;
	EndIf;

	Items._DBUserListListOfRoles.Visible = _ShowUserRolesList;
EndProcedure

&AtServer
Procedure OnSaveDataInSettingsAtServer(Settings)
	// сформируем избранное
	For Each РазделДЗ In ObjectsTree.GetItems() Do
		If РазделДЗ.FullName = "Favorites" Then
			ПереченьПолейУзлаДЗ = вПереченьПолейУзлаДЗ();
			_FavoritesContent.Data.Clear();
			For Each СтрДЗ In РазделДЗ.GetItems() Do
				Струк = New Structure(ПереченьПолейУзлаДЗ);
				FillPropertyValues(Струк, СтрДЗ);
				_FavoritesContent.Data.Add(Струк);
			EndDo;
			Break;
		EndIf;
	EndDo;

	Settings.Insert("_FavoritesContent", _FavoritesContent);
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	мТекущийОбъектДерева = "";

	вСформироватьОписаниеПравДоступа();
	вЗаполнитьПроверяемыеПраваДоступа();

	мОбычныеПрикладныеОбъекты = New Structure("Constant, Catalog, Document, DocumentJournal, ChartOfCharacteristicTypes, ChartOfCalculationTypes, ChartOfAccounts
												|, Processing, Report, InformationRegister, AccumulationRegister, AccountingRegister, CalculationRegister, BusinessProcess, Task
												|, ExchangePlan");

	СтрокиДЗ = ObjectsTree.GetItems();
	СтрокиДЗ.Clear();

	СтрДЗ = СтрокиДЗ.Add();
	FillPropertyValues(СтрДЗ, вСформироватьУзелКонфигурация());
	СтрДЗ.NodeType = 1;
	
	
	// избранное
	СтрДЗ = СтрокиДЗ.Add();
	СтрДЗ.Name = "Favorites...";
	СтрДЗ.NodeType = "Favorites";
	СтрДЗ.NodeType = 1;
	СтрДЗ.FullName = "Favorites";
	мИдентификаторИзбранного = СтрДЗ.GetID();

	For Each Элем In _FavoritesContent.Data Do
		НС = СтрДЗ.GetItems().Add();
		FillPropertyValues(НС, Элем);
	EndDo;
	СтрДЗ = СтрокиДЗ.Add();
	СтрДЗ.Name = "Общие";
	СтрДЗ.NodeType = "ГруппаРазделовМД";
	СтрДЗ.NodeType = 1;
	СтрДЗ.GetItems().Add();

	СтрукРазделы = New Structure("Constants, Catalogs, Documents, DocumentJournals, Enums, ChartsOfCharacteristicTypes, ChartsOfCalculationTypes, ChartsOfAccounts
								   |, DataProcessors, Reports, InformationRegisters, AccumulationRegisters, AccountingRegisters, CalculationRegisters, BusinessProcesses, Tasks");

	вРассчитатьКоличествоОбъектовМД(СтрукРазделы);

	For Each Элем In СтрукРазделы Do
		СтрДЗ = СтрокиДЗ.Add();
		СтрДЗ.Name = Элем.Key;
		СтрДЗ.Name = Элем.Key + " (" + Элем.Value + ")";
		СтрДЗ.NodeType = "РазделМД";
		СтрДЗ.NodeType = 1;
		СтрДЗ.GetItems().Add();
	EndDo;

	_StorageAddresses = New Structure("RegisterRecords, Подписки, Commands, CommonCommands, Subsystems, РолиИПользователи");
	_StorageAddresses.RegisterRecords = PutToTempStorage(-1, UUID);
	_StorageAddresses.Подписки = PutToTempStorage(-1, UUID);
	_StorageAddresses.Commands  = PutToTempStorage(-1, UUID);
	_StorageAddresses.CommonCommands = PutToTempStorage(-1, UUID);
	_StorageAddresses.Subsystems = PutToTempStorage(-1, UUID);
	_StorageAddresses.РолиИПользователи = "";
	
	// хранилища настроек
	СтрокиДЗ = SettingsTree.GetItems();
	СтрокиДЗ.Clear();

	ГруппаДЗ = СтрокиДЗ.Add();
	ГруппаДЗ.Presentation = "Стандартные хранилища настроек";

	СтрукРазделы = New Structure("ReportsVariantsStorage, FormDataSettingsStorage, CommonSettingsStorage
								   |, DynamicListsUserSettingsStorage, ReportsUserSettingsStorage, SystemSettingsStorage");

	For Each Элем In СтрукРазделы Do
		СтрДЗ = ГруппаДЗ.GetItems().Add();
		СтрДЗ.Name = Элем.Key;
		СтрДЗ.Presentation = Элем.Key;
		СтрДЗ.NodeType = "Х";
	EndDo;
EndProcedure

&AtClient
Procedure kOpenInNewWindow(Command)
	OpenForm(PathToForms, , , CurrentDate(), , , , FormWindowOpeningMode.Independent);
EndProcedure

&AtClient
Procedure _CollapseAllNodes(Command)
	For Each УзелДЗ In ObjectsTree.GetItems() Do
		Items.ObjectsTree.Collapse(УзелДЗ.GetID());
	EndDo;
EndProcedure

&AtClient
Procedure _UpdateDBUsersList(Command)
	For Each Стр In ObjectsTree.GetItems() Do
		If Стр.Name = "Общие" Then
			For Each УзелДЗ In Стр.GetItems() Do
				If УзелДЗ.NodeType = "РазделМД" And StrFind(УзелДЗ.Name, "Users") = 1 Then
					СтрокиДЗ = УзелДЗ.GetItems();
					СтрокиДЗ.Clear();

					Струк = вПолучитьСоставРазделаМД("Users");
					For Each Элем In Струк.МассивОбъектов Do
						СтрДЗ = СтрокиДЗ.Add();
						FillPropertyValues(СтрДЗ, Элем);
					EndDo;
					УзелДЗ.Name = "Users (" + Струк.ЧислоОбъектов + ")";

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
	ТекДанные = Items.ObjectsTree.CurrentData;
	If ТекДанные <> Undefined And StrFind(ТекДанные.FullName, "User.") = 1 Then
		СтрукПараметры = New Structure("РежимРаботы, DBUserID", 2, ТекДанные.ObjectPresentation);
		OpenForm(PathToForms + "ФормаПользовательИБ", СтрукПараметры, , , , , ,
			FormWindowOpeningMode.LockOwnerWindow);
	EndIf;
EndProcedure

&AtClient
Procedure _DeleteDBUser(Command)
	ТекДанные = Items.ObjectsTree.CurrentData;
	If ТекДанные <> Undefined And StrFind(ТекДанные.FullName, "User.") = 1 Then
		пТекст = StrTemplate("User ""%1"" будет удален из информационной базы!
						   |Continue?", ТекДанные.Name);
		ShowQueryBox(New NotifyDescription("вУдалитьПользователяОтвет", ThisForm, ТекДанные), пТекст,
			QuestionDialogMode.YesNoCancel, 20);
	EndIf;
EndProcedure

&AtClient
Procedure вУдалитьПользователяОтвет(Ответ, ТекДанные) Export
	If Ответ = DialogReturnCode.Yes Then
		пРезультат = вУдалитьПользователяИБ(ТекДанные.ObjectPresentation);
		If пРезультат.Cancel Then
			вПоказатьПредупреждение(пРезультат.ПричинаОтказа);
		Else
			ТекДанные.GetParent().GetItems().Delete(ТекДанные);
		EndIf;
	EndIf;
EndProcedure

&AtServerNoContext
Function вУдалитьПользователяИБ(ID)
	пРезультат = New Structure("Cancel, ПричинаОтказа", False, "");

	Try
		пUUID = New UUID(ID);

		пПользователь = InfoBaseUsers.FindByUUID(пUUID);
		If пПользователь = Undefined Then
			пРезультат.Cancel = True;
			пРезультат.ПричинаОтказа = "Указанный User не найден!";
			Return пРезультат;
		EndIf;

		пТекПользователь = InfoBaseUsers.CurrentUser();

		If пТекПользователь.UUID = пUUID Then
			пРезультат.Cancel = True;
			пРезультат.ПричинаОтказа = "Нельзя удалить текущего пользоватля!";
			Return пРезультат;
		EndIf;

		пПользователь.Delete();
	Except
		пРезультат.Cancel = True;
		пРезультат.ПричинаОтказа = ErrorDescription();
	EndTry;

	Return пРезультат;
EndFunction
&AtClient
Procedure kShowObjectProperties(Command)
	If Items.PagesGroup.CurrentPage.Name = "StorageStructurePage" Then
		ТекДанные = Undefined;
		If Items.TableAndIndexesGrpip.CurrentPage.Name = "_IndexesPage" Then
			ТекДанные = Items._Indexes.CurrentData;
		ElsIf Items.TableAndIndexesGrpip.CurrentPage.Name = "TablePage" Then
			ТекДанные = Items._Tables.CurrentData;
		EndIf;

		If ТекДанные <> Undefined Then
			пПолноеИмя = ТекДанные.Metadata;
			If пПолноеИмя = "<не задано>" Then
				Return;
			EndIf;

			Поз = StrFind(пПолноеИмя, ".", , , 2);
			If Поз <> 0 Then
				пПолноеИмя = Left(пПолноеИмя, Поз - 1);
			EndIf;

			СтрукПараметры = New Structure("FullName, PathToForms, _StorageAddresses, ОписаниеПравДоступа",
				пПолноеИмя, PathToForms, _StorageAddresses, мОписаниеПравДоступа);
			СтрукПараметры.Insert("НастройкиОбработки", вСформироватьСтруктуруНастроекФормыСвойствОбъекта());
			OpenForm(PathToForms + "ФормаСвойств", СтрукПараметры, , пПолноеИмя, , , ,
				FormWindowOpeningMode.Independent);
		EndIf;

		Return;
	EndIf;

	ТекДанные = Items.ObjectsTree.CurrentData;
	If ТекДанные <> Undefined Then
		If ТекДанные.NodeType = "MetadataObject" Then
			If StrFind(ТекДанные.FullName, "User.") = 1 Then
				СтрукПараметры = New Structure("DBUserID", ТекДанные.ObjectPresentation);
				OpenForm(PathToForms + "ФормаПользовательИБ", СтрукПараметры, , ТекДанные.FullName, , , ,
					FormWindowOpeningMode.LockOwnerWindow);
			Else
				СтрукПараметры = New Structure("FullName, PathToForms, _StorageAddresses, ОписаниеПравДоступа",
					ТекДанные.FullName, PathToForms, _StorageAddresses, мОписаниеПравДоступа);
				СтрукПараметры.Insert("НастройкиОбработки", вСформироватьСтруктуруНастроекФормыСвойствОбъекта());
				OpenForm(PathToForms + "ФормаСвойств", СтрукПараметры, , ТекДанные.FullName, , , ,
					FormWindowOpeningMode.Independent);
			EndIf;
		ElsIf ТекДанные.NodeType = "Конфигурация" Then
			СтрукПараметры = New Structure("FullName, PathToForms, _StorageAddresses, ОписаниеПравДоступа",
				"Конфигурация", PathToForms, _StorageAddresses, мОписаниеПравДоступа);
			СтрукПараметры.Insert("НастройкиОбработки", вСформироватьСтруктуруНастроекФормыСвойствОбъекта());
			OpenForm(PathToForms + "ФормаСвойств", СтрукПараметры, , ТекДанные.FullName, , , ,
				FormWindowOpeningMode.Independent);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure kOpenListForm(Command)
	ТекДанные = Items.ObjectsTree.CurrentData;
	If ТекДанные <> Undefined Then
		If ТекДанные.NodeType = "MetadataObject" And Not вЭтоПрочаяКоманда(ТекДанные.FullName) Then
			Try
				ВидОбъектМД = Left(ТекДанные.FullName, StrFind(ТекДанные.FullName, ".") - 1);

				If ВидОбъектМД = "User" Then
					StandardProcessing = False;
					СтрукПараметры = New Structure("DBUserID", ТекДанные.ObjectPresentation);
					OpenForm(PathToForms + "ФормаПользовательИБ", СтрукПараметры, , ТекДанные.FullName, , , ,
						FormWindowOpeningMode.LockOwnerWindow);
					Return;
				EndIf;

				If Not мОбычныеПрикладныеОбъекты.Property(ВидОбъектМД) Then
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
				OpenForm(ТекДанные.FullName + ИмяФормыМД);
			Except
				Message(BriefErrorDescription(ErrorInfo()));
			EndTry;
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure kCollapseTreeSection(Command)
	ТекДанные = Items.ObjectsTree.CurrentData;
	If ТекДанные <> Undefined Then
		УзелДЗ = ТекДанные.GetParent();
		If УзелДЗ <> Undefined Then
			String = УзелДЗ.GetID();
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
	вОперацияНеПоддерживаетсяДляВебКлиента();
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

	УзелДЗ = ObjectsTree.FindByID(String);
	СтрокиДЗ = УзелДЗ.GetItems();
	If СтрокиДЗ.Count() = 1 And IsBlankString(СтрокиДЗ[0].NodeType) Then
		Cancel = True;
		СтрокиДЗ.Clear();

		ИмяУзлаДЗ = УзелДЗ.Name;
		Поз = StrFind(ИмяУзлаДЗ, " (");
		If Поз <> 0 Then
			ИмяУзлаДЗ = Left(ИмяУзлаДЗ, Поз - 1);
		EndIf;

		If УзелДЗ.NodeType = "РазделМД" Then
			УзелДЗ = ObjectsTree.FindByID(String);
			СтрокиДЗ = УзелДЗ.GetItems();
			СтрокиДЗ.Clear();

			If ИмяУзлаДЗ = "Documents" Then
				Струк = New Structure("DocumentNumerators, Sequences");
				вРассчитатьКоличествоОбъектовМД(Струк);
				For Each Элем In Струк Do
					СтрДЗ = СтрокиДЗ.Add();
					СтрДЗ.NodeType = "РазделМД";
					СтрДЗ.Name = Элем.Key + " (" + Элем.Value + ")";
					СтрДЗ.GetItems().Add();
				EndDo;
				
				//СтрДЗ = СтрокиДЗ.Add();
				//СтрДЗ.NodeType = "РазделМД";
				//СтрДЗ.Name = "DocumentNumerators";
				//СтрДЗ.GetItems().Add();
				//
				//СтрДЗ = СтрокиДЗ.Add();
				//СтрДЗ.NodeType = "РазделМД";
				//СтрДЗ.Name = "Sequences";
				//СтрДЗ.GetItems().Add();
			EndIf;

			Струк = вПолучитьСоставРазделаМД(ИмяУзлаДЗ);
			For Each Элем In Струк.МассивОбъектов Do
				СтрДЗ = СтрокиДЗ.Add();
				FillPropertyValues(СтрДЗ, Элем);
				If StrFind(СтрДЗ.FullName, "Enum.") = 1 Then
					СтрДЗ.GetItems().Add();
				ElsIf StrFind(СтрДЗ.FullName, "Подсистема.") = 1 Then
					If Элем.ЕстьДети Then
						СтрДЗ.GetItems().Add();
					EndIf;
				ElsIf StrFind(СтрДЗ.FullName, "WebСервис.") = 1 Then
					СтрДЗ.GetItems().Add();
				ElsIf StrFind(СтрДЗ.FullName, "HTTPСервис.") = 1 Then
					СтрДЗ.GetItems().Add();
				EndIf;
			EndDo;
			УзелДЗ.Name = ИмяУзлаДЗ + " (" + Струк.ЧислоОбъектов + ")";

		ElsIf УзелДЗ.NodeType = "ГруппаРазделовМД" Then
			СтрукРазделы = New Structure("Subsystems, CommonModules, SessionParameters, Users, Roles, CommonAttributes, ExchangePlans, EventSubscriptions, ScheduledJobs
										   |, FunctionalOptions, FunctionalOptionsParameters, DefinedTypes, SettingsStorages, CommonForms, CommonCommands, CommandGroups, ПрочиеКоманды, CommonTemplates, XDTOPackages, WebServices, HTTPServices");

			вРассчитатьКоличествоОбъектовМД(СтрукРазделы);

			For Each Элем In СтрукРазделы Do
				If Элем.Key = "Users" And Not вЕстьПраваАдминистратора() Then
					Continue;
				EndIf;
				СтрДЗ = СтрокиДЗ.Add();
				СтрДЗ.Name = Элем.Key;
				СтрДЗ.Name = Элем.Key + " (" + Элем.Value + ")";
				СтрДЗ.NodeType = "РазделМД";
				СтрДЗ.NodeType = 1;
				СтрДЗ.GetItems().Add();
			EndDo;

		ElsIf УзелДЗ.NodeType = "MetadataObject" Then
			ВидОбъектМД = Left(УзелДЗ.FullName, StrFind(УзелДЗ.FullName, ".") - 1);

			УзелДЗ = ObjectsTree.FindByID(String);
			СтрокиДЗ = УзелДЗ.GetItems();
			СтрокиДЗ.Clear();

			If ВидОбъектМД = "Enum" Then
				МассивОбъектов = вПолучитьСоставПеречисления(УзелДЗ.FullName);
				For Each Элем In МассивОбъектов Do
					СтрДЗ = СтрокиДЗ.Add();
					FillPropertyValues(СтрДЗ, Элем);
				EndDo;
			ElsIf ВидОбъектМД = "Подсистема" Then
				МассивОбъектов = вПолучитьСоставПодсистемы(УзелДЗ.FullName);
				For Each Элем In МассивОбъектов Do
					СтрДЗ = СтрокиДЗ.Add();
					FillPropertyValues(СтрДЗ, Элем);
					If Элем.ЕстьДети Then
						СтрДЗ.GetItems().Add();
					EndIf;
				EndDo;
			ElsIf ВидОбъектМД = "WebСервис" Then
				МассивОбъектов = вПолучитьОперацииWebСервиса(УзелДЗ.FullName);
				For Each Элем In МассивОбъектов Do
					СтрДЗ = СтрокиДЗ.Add();
					FillPropertyValues(СтрДЗ, Элем);
				EndDo;
			ElsIf ВидОбъектМД = "HTTPСервис" Then
				МассивОбъектов = вПолучитьМетодыHTTPСервиса(УзелДЗ.FullName);
				For Each Элем In МассивОбъектов Do
					СтрДЗ = СтрокиДЗ.Add();
					FillPropertyValues(СтрДЗ, Элем);
					For Each ЭлемХ In Элем.Methods Do
						FillPropertyValues(СтрДЗ.GetItems().Add(), ЭлемХ);
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
Function вПереченьПолейУзлаДЗ()
	Return "Name, Synonym, ОсновнаяТаблицаSQL, FullName, NodeType, NodeType, ObjectPresentation, NumberOfObjects";
EndFunction

&AtServerNoContext
Function вСформироватьСтруктуруУзлаДЗ(NodeType = "", Name = "", FullName = "", Synonym = "", ЕстьДети = False,
	ObjectPresentation = "")
	Струк = New Structure("NodeType, Name, FullName, Synonym, ObjectPresentation, ЕстьДети, ОсновнаяТаблицаSQL",
		NodeType, Name, FullName, Synonym, ObjectPresentation, ЕстьДети, "");
	Return Струк;
EndFunction

&AtServerNoContext
Function вСформироватьУзелКонфигурация()
	Струк = New Structure("Name, Synonym, Version", "", "", "");
	FillPropertyValues(Струк, Metadata);

	If IsBlankString(Струк.Synonym) Then
		Струк.Synonym = Струк.Name;
	EndIf;
	If Not IsBlankString(Струк.Version) Then
		Струк.Synonym = Струк.Synonym + " (" + Струк.Version + ")";
	EndIf;

	Return вСформироватьСтруктуруУзлаДЗ("Конфигурация", Струк.Name, "Конфигурация", Струк.Synonym);
EndFunction

&AtServerNoContext
Function вПроверитьНаличиеСвойства(Object, PropertyName)
	Струк = New Structure(PropertyName);
	FillPropertyValues(Струк, Object);

	Return (Струк[PropertyName] <> Undefined);
EndFunction

&AtServerNoContext
Function вПолучитьСоставРазделаМД(Val ИмяРаздела)
	Поз = StrFind(ИмяРаздела, " ");
	If Поз <> 0 Then
		ИмяРаздела = Left(ИмяРаздела, Поз - 1);
	EndIf;

	СтрукРезультат = New Structure("ЧислоОбъектов, МассивОбъектов", 0, New Array);
	
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
		If вЕстьПраваАдминистратора() Then
			For Each Элем In InfoBaseUsers.GetUsers() Do
				Стр = Table.Add();
				Стр.Name = Элем.Name;
				Стр.Synonym = Элем.FullName;
				Стр.ObjectPresentation = Элем.UUID;
				Стр.FullName = "User." + Элем.Name;
				Стр.NodeType = "MetadataObject";
			EndDo;
		EndIf;
	ElsIf ИмяРаздела = "ПрочиеКоманды" Then
		ПереченьРазделов = "Catalogs, DocumentJournals, Documents, Enums, DataProcessors, Reports,
						   |ChartsOfAccounts, ChartsOfCharacteristicTypes, ChartsOfCalculationTypes, ExchangePlans,
						   |InformationRegisters, AccumulationRegisters, CalculationRegisters, AccountingRegisters,
						   |BusinessProcesses, Tasks, FilterCriteria";

		СтрукРазделы = New Structure(ПереченьРазделов);

		For Each Элем In СтрукРазделы Do
			For Each ОбъектХХХ In Metadata[Элем.Key] Do
				ИмяТипаХХХ = ОбъектХХХ.FullName();

				If вПроверитьНаличиеСвойства(ОбъектХХХ, "Commands") Then
					For Each Элем In ОбъектХХХ.Commands Do
						Стр = Table.Add();
						Стр.MetadataObject = Элем;
						Стр.Name = Элем.Name;
						Стр.Synonym = Элем.Presentation();
						Стр.FullName = Элем.FullName();
						Стр.NodeType = "MetadataObject";
					EndDo;
				EndIf;
			EndDo;
		EndDo;

	Else
		For Each Элем In Metadata[ИмяРаздела] Do
			Стр = Table.Add();
			Стр.MetadataObject = Элем;
			Стр.Name = Элем.Name;
			Стр.Synonym = Элем.Presentation();
			Стр.ObjectPresentation = ?(ЕстьДопПредставление, Элем.ObjectPresentation, "");
			Стр.FullName = Элем.FullName();
			Стр.NodeType = "MetadataObject";

			If ИмяРаздела = "Subsystems" Then
				Стр.ЕстьДети = (Элем.Subsystems.Count() <> 0);
			EndIf;
		EndDo;
	EndIf;

	If ИмяРаздела = "ПрочиеКоманды" Then
		Table.Sort("FullName");
	Else
		Table.Sort("Name");
	EndIf;

	For Each Стр In Table Do
		Струк = вСформироватьСтруктуруУзлаДЗ();
		FillPropertyValues(Струк, Стр);
		СтрукРезультат.МассивОбъектов.Add(Струк);
	EndDo;

	If ИмяРаздела = "Subsystems" Then
		СтрукРезультат.ЧислоОбъектов = вПолучитьКоличествоПодсистем();
	Else
		СтрукРезультат.ЧислоОбъектов = СтрукРезультат.МассивОбъектов.Count();
	EndIf;

	Return СтрукРезультат;
EndFunction

&AtServerNoContext
Function вПолучитьСоставПеречисления(Val FullName)
	МассивОбъектов = New Array;

	ОбъектМД = Metadata.FindByFullName(FullName);
	If ОбъектМД <> Undefined Then
		For Each ЭлемХ In ОбъектМД.EnumValues Do
			Струк = вСформироватьСтруктуруУзлаДЗ("ЗначениеПеречисления", ЭлемХ.Name, "", ЭлемХ.Presentation());
			МассивОбъектов.Add(Струк);
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
			Струк = вСформироватьСтруктуруУзлаДЗ("MetadataObject", ЭлемХ.Name, ЭлемХ.FullName(), ЭлемХ.Presentation());
			МассивОбъектов.Add(Струк);
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
			Струк = вСформироватьСтруктуруУзлаДЗ("MetadataObject", ЭлемХ.Name, ЭлемХ.FullName(), ЭлемХ.Presentation());
			МассивОбъектов.Add(Струк);
			Струк.Insert("Methods", New Array);
			For Each ЭлемХХХ In ЭлемХ.Methods Do
				СтрукХХХ = вСформироватьСтруктуруУзлаДЗ("MetadataObject", ЭлемХХХ.Name, ЭлемХХХ.FullName(),
					ЭлемХХХ.Presentation());
				Струк.Methods.Add(СтрукХХХ);
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
		For Each Элем In ОбъектМД.Subsystems Do
			Стр = Table.Add();
			Стр.MetadataObject = Элем;
			Стр.Name = Элем.Name;
			Стр.Synonym = Элем.Presentation();
			Стр.FullName = Элем.FullName();
			Стр.NodeType = "MetadataObject";
			Стр.ЕстьДети = (Элем.Subsystems.Count() <> 0);
		EndDo;
	EndIf;
	Table.Sort("Name");

	МассивОбъектов = New Array;

	For Each Стр In Table Do
		Струк = вСформироватьСтруктуруУзлаДЗ();
		FillPropertyValues(Струк, Стр);
		МассивОбъектов.Add(Струк);
	EndDo;

	Return МассивОбъектов;
EndFunction

&AtServerNoContext
Procedure вРассчитатьКоличествоОбъектовМД(СтрукРазделы)
	SetPrivilegedMode(True);

	For Each Элем In СтрукРазделы Do
		ЧислоОбъектов = 0;
		If Элем.Key = "Users" Then
			If вЕстьПраваАдминистратора() Then
				ЧислоОбъектов = InfoBaseUsers.GetUsers().Count();
			EndIf;
		ElsIf Элем.Key = "Subsystems" Then
			ЧислоОбъектов = вПолучитьКоличествоПодсистем();
		ElsIf Элем.Key = "ПрочиеКоманды" Then
			ЧислоОбъектов = "???"; //вПолучитьКоличествоПодсистем();
		Else
			ЧислоОбъектов = Metadata[Элем.Key].Count();
		EndIf;
		СтрукРазделы.Insert(Элем.Key, ЧислоОбъектов);
	EndDo;
EndProcedure

&AtServerNoContext
Function вПолучитьКоличествоПодсистем(Val ЭтоПервыйВызов = True, ПодсистемаМД = Undefined, Соотв = Undefined)
	If ЭтоПервыйВызов Then
		Соотв = New Map;

		For Each Элем In Metadata.Subsystems Do
			вПолучитьКоличествоПодсистем(False, Элем, Соотв);
		EndDo;

		Return Соотв.Count();
	Else
		Соотв.Insert(ПодсистемаМД, 1);
		For Each Элем In ПодсистемаМД.Subsystems Do
			Соотв.Insert(Элем, 1);
			вПолучитьКоличествоПодсистем(False, Элем, Соотв);
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
	ТекДанные = Items.ObjectsTree.CurrentData;

	If ТекДанные <> Undefined Then
		If ТекДанные.NodeType = "MetadataObject" Then
			If вЭтоПрочаяКоманда(ТекДанные.FullName) Then
				kShowObjectProperties(Undefined);
				Return;
			EndIf;

			СпецПеречень = "Processing, Report";
			Струк = New Structure(СпецПеречень);

			ВидОбъектМД = Left(ТекДанные.FullName, StrFind(ТекДанные.FullName, ".") - 1);
			If Струк.Property(ВидОбъектМД) Then
				kOpenListForm(Undefined);
			Else
				kShowObjectProperties(Undefined);
			EndIf;
		ElsIf ТекДанные.NodeType = "Конфигурация" Then
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
	ТекДанные = Items.ObjectsTree.CurrentData;
	If ТекДанные <> Undefined Then
		If ТекДанные.NodeType = "MetadataObject" And Not вЭтоПрочаяКоманда(ТекДанные.FullName) Then
			СтрукКатегории = New Structure("Catalog, Document, DocumentJournal,ChartOfCharacteristicTypes, ChartOfCalculationTypes, ChartOfAccounts
											 |, InformationRegister, AccumulationRegister, AccountingRegister, CalculationRegister, BusinessProcess, Task");

			НадоОбработать = False;
			For Each Элем In СтрукКатегории Do
				If StrFind(ТекДанные.FullName, Элем.Key) = 1 Then
					НадоОбработать = True;
					Break;
				EndIf;
			EndDo;

			If НадоОбработать Then
				UT_CommonClient.ОpenDynamicList(ТекДанные.FullName);
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

	If Not вЕстьПраваАдминистратора() Then
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

		For Each Элем In МассивСтрок Do
			Стр = SettingsTable.FindByID(Элем);
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
		вПоказатьВопрос("Отмеченные настройки будут удалены. Continue?", "ТабНастройкиПередУдалениемДалее",
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
	ТекДанные = Items.SettingsTree.CurrentData;

	If ТекДанные <> Undefined And ТекДанные.NodeType = "Х" Then
		SettingsTable.Clear();

		If Not вОбновитьТабНастройки(ТекДанные.NodeType, ТекДанные.Name) Then
			ТекДанные.NodeType = "-";
			ТекДанные.Presentation = ТекДанные.Name + " (не поддерживается)";
		EndIf;

		_NameOfSettingsManager = ТекДанные.Name;

		вОбновитьЗаголовкиНастройки();
	EndIf;
EndProcedure

&AtClient
Procedure вОбновитьЗаголовкиНастройки()
	Items.DecorationSettings.Title = _NameOfSettingsManager + " (" + SettingsTable.Count() + " шт.)";
EndProcedure



// страница Service

&AtServer
Procedure вЗаполнитьДеревоСервис()
	Template = вПолучитьОбработку().GetTemplate("МакетСервис");
	If Template = Undefined Then
		Template = New SpreadsheetDocument;
	EndIf;

	СтрукСвойства = New Structure("Enabled, Presentation, NodeType, Name, Comment, AvailabilityExpression",
		True);

	КореньДЗ = ServiceTree;
	УзелДЗ = ServiceTree;

	For LineNumber = 2 To Template.TableHeight Do
		СтрукСвойства.Presentation = TrimAll(Template.Region(LineNumber, 1).Text);

		If Not IsBlankString(СтрукСвойства.Presentation) Then
			СтрукСвойства.NodeType = TrimAll(Template.Region(LineNumber, 2).Text);
			СтрукСвойства.Name = TrimAll(Template.Region(LineNumber, 3).Text);
			СтрукСвойства.AvailabilityExpression = TrimAll(Template.Region(LineNumber, 4).Text);
			СтрукСвойства.Comment = TrimAll(Template.Region(LineNumber, 5).Text);

			If СтрукСвойства.NodeType = "Г" Then
				УзелДЗ = КореньДЗ.GetItems().Add();
				FillPropertyValues(УзелДЗ, СтрукСвойства);
				УзелДЗ.IsGroup = True;
				УзелДЗ.Picture = -1;
			Else
				СтрДЗ = УзелДЗ.GetItems().Add();
				FillPropertyValues(СтрДЗ, СтрукСвойства);
				If Not IsBlankString(СтрукСвойства.AvailabilityExpression) Then
					СтрДЗ.Enabled = Eval(СтрукСвойства.AvailabilityExpression);
				EndIf;
				If Not СтрДЗ.Enabled Then
					СтрДЗ.Presentation = СтрДЗ.Presentation + " (не доступно)";
				EndIf;

				If СтрДЗ.Name = "ПереключитьМонопольныйРежим" Then
					СтрДЗ.Presentation = ?(_FormContext.ExclusiveMode, "Отключить монопольный режим",
						"Set монопольный режим");
				EndIf;
			EndIf;
		EndIf;
	EndDo;
EndProcedure

&AtClient
Procedure ДеревоСервисВыбор(Item, SelectedRow, Field, StandardProcessing)
	СтрДЗ = ServiceTree.FindByID(SelectedRow);
	If СтрДЗ <> Undefined Then
		If Not СтрДЗ.IsGroup Then
			StandardProcessing = False;
			If СтрДЗ.Enabled Then
				Try
					вОбработатьКомандуСервис(СтрДЗ);
				Except
				EndTry;
			EndIf;
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure вОбработатьКомандуСервис(СтрДЗ)
	If СтрДЗ.Name = "SubsystemVersions" Then
		OpenForm("InformationRegister.ВерсииПодсистем.ФормаСписка");
	ElsIf СтрДЗ.Name = "RefreshReusableValues" Then
		RefreshReusableValues();
	ElsIf СтрДЗ.Name = "ClearFavorites" Then
		вПоказатьВопрос("Favorites будет очищено. Continue?", "вОчиститьИзбранное");
	ElsIf СтрДЗ.Name = "DisplayScale" Then
		kChangeScaleOfForm(Undefined);
	ElsIf СтрДЗ.Name = "SetSessionsLock" Then
		OpenForm(PathToForms + "ФормаБлокировкиСеансов", , ThisForm, , , , ,
			FormWindowOpeningMode.LockOwnerWindow);
	ElsIf СтрДЗ.Name = "ExclusiveMode" Then
		вПерключитьМонопольныйРежим(_FormContext);
		СтрДЗ.Presentation = ?(_FormContext.ExclusiveMode, "Отключить монопольный режим",
			"Set монопольный режим");
	ElsIf СтрДЗ.Name = "Run1C" Then
#If WebClient Then
		вОперацияНеПоддерживаетсяДляВебКлиента();
#Else
			OpenForm(PathToForms + "ФормаЗапуска1С", , ThisForm, , , , ,
				FormWindowOpeningMode.LockOwnerWindow);
#EndIf
	ElsIf
	СтрДЗ.Name = "1CConfigurator" Then
		вЗапуститьСеанс1С(1);
	ElsIf СтрДЗ.Name = "OrdinaryСlient" Then
		вЗапуститьСеанс1С(2);
	ElsIf СтрДЗ.Name = "ThickСlient" Then
		вЗапуститьСеанс1С(3);
	ElsIf СтрДЗ.Name = "ThinСlient" Then
		вЗапуститьСеанс1С(4);
	ElsIf СтрДЗ.Name = "WinStartMenu" Then
		вВыполнитьКомандуОС("%ProgramData%\Microsoft\Windows\Start Menu\Programs");
	ElsIf СтрДЗ.Name = "WinAppData" Then
		вВыполнитьКомандуОС("%AppData%");
	EndIf;
EndProcedure

&AtClient
Procedure вОчиститьИзбранное(Result, ДопПараметры = Undefined) Export
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
	ТекДанные = Items.ServiceTree.CurrentData;
	ДеревоСервисВыбор(Items.ДеревоСервис, Items.ServiceTree.CurrentLine, Undefined, False);
EndProcedure

&AtClient
Procedure _ОтображатьПраваНаОбъектыПриИзменении(Item)
	Items.ObjectRightPages.Visible = _DisplayObjectsRights;

	If Not _DisplayObjectsRights And Not IsBlankString(_StorageAddresses.РолиИПользователи) Then
		DeleteFromTempStorage(_StorageAddresses.РолиИПользователи);
		_StorageAddresses.РолиИПользователи = "";
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
	ТекДанные = Items.ObjectsTree.CurrentData;
	ТипМД = "";
	If ТекДанные <> Undefined And ТекДанные.NodeType = "MetadataObject" Then
		If ТекДанные.FullName = мТекущийОбъектДерева Then
			Return;
		EndIf;

		мТекущийОбъектДерева = ТекДанные.FullName;

		For Each Стр In VerifiableRightsTable.FindRows(New Structure("Mark", True)) Do
			Стр.Mark = False;
		EndDo;

		If StrFind(ТекДанные.FullName, ".Command.") <> 0 Then
			ТипМД = "ОбщаяКоманда";
		Else
			ТипМД = Left(ТекДанные.FullName, StrFind(ТекДанные.FullName, ".") - 1);
		EndIf;

		If ТипМД = "WebСервис" And StrFind(ТекДанные.FullName, ".Операция.") <> 0 Then
			ТипМД = "WebСервис.Property";
		ElsIf ТипМД = "HTTPСервис" And StrFind(ТекДанные.FullName, ".ШаблонURL.") <> 0 And StrFind(
			ТекДанные.FullName, ".Method.") <> 0 Then
			ТипМД = "HTTPСервис.Property";
		EndIf;

		For Each Стр In VerifiableRightsTable.FindRows(New Structure("MetadataObject", ТипМД)) Do
			Стр.Mark = True;
		EndDo;
	Else
		мТекущийОбъектДерева = "";

		For Each Стр In VerifiableRightsTable.FindRows(New Structure("Mark", True)) Do
			Стр.Mark = False;
		EndDo;
	EndIf;

	RolesWithAccessTable.Clear();
	UsersWithAccessTable.Clear();

	If ТекДанные <> Undefined And ТекДанные.NodeType = "MetadataObject" Then

		If StrFind(ТекДанные.FullName, "Role.") = 1 Then
			If Items.ObjectRightPages.CurrentPage <> Items.UsersLine Then
				Items.ObjectRightPages.CurrentPage = Items.UsersLine;
			EndIf;
			ИмяПрава = "Х";
		ElsIf StrFind(ТекДанные.FullName, "User.") = 1 Then
			If Items.ObjectRightPages.CurrentPage <> Items.RolesLine Then
				Items.ObjectRightPages.CurrentPage = Items.RolesLine;
			EndIf;
			ИмяПрава = "Х";
		Else
			If ТипМД = "" Then
				ТипМД = Left(ТекДанные.FullName, StrFind(ТекДанные.FullName, ".") - 1);
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

		Струк = вПолучитьПраваДоступаКОбъекту(ИмяПрава, ТекДанные.FullName, _StorageAddresses.РолиИПользователи,
			UUID);
		If Струк.ЕстьДанные Then
			For Each Элем In Струк.Roles Do
				FillPropertyValues(RolesWithAccessTable.Add(), Элем);
			EndDo;

			For Each Элем In Струк.Users Do
				FillPropertyValues(UsersWithAccessTable.Add(), Элем);
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

	ТекДанные = Items.ObjectsTree.CurrentData;
	If ТекДанные <> Undefined And ТекДанные.NodeType = "MetadataObject" Then
		If StrFind(ТекДанные.FullName, "Role.") = 1 Then
			ЗаголовокРоли = "";
			ЗаголовокПользователи = "Users, имеющие данную роль (";
		ElsIf StrFind(ТекДанные.FullName, "User.") = 1 Then
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
		For Each Элем In Metadata.Roles Do
			If AccessRight(ИмяПрава, ОбъектМД, Элем) Then
				FillPropertyValues(ТабРоли.Add(), Элем);
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
		Струк = New Structure("Name, Synonym");
		FillPropertyValues(Струк, Стр);
		СтрукРезультат.Roles.Add(Струк);
	EndDo;

	For Each Стр In ТабПользователи Do
		Струк = New Structure("Name, FullName");
		FillPropertyValues(Струк, Стр);
		СтрукРезультат.Users.Add(Струк);
	EndDo;

	Return СтрукРезультат;
EndFunction

&AtClient
Procedure вЗаполнитьПроверяемыеПраваДоступа()
	For Each Элем In мОписаниеПравДоступа Do
		НС = VerifiableRightsTable.Add();
		НС.MetadataObject = Элем.Key;
		Поз = StrFind(Элем.Value, ",");
		НС.Right = ?(Поз = 0, Элем.Value, Left(Элем.Value, Поз - 1));
	EndDo;

	VerifiableRightsTable.Sort("MetadataObject");
EndProcedure

&AtClient
Procedure ТабПроверяемыеПраваПриНачалеРедактирования(Item, NewLine, Copy)
	ТекДанные = Item.CurrentData;
	Струк = New Structure(мОписаниеПравДоступа[ТекДанные.MetadataObject]);

	ЭФ = Items.VerifiableRightsTableRight;
	ЭФ.ChoiceList.Clear();
	For Each Элем In Струк Do
		ЭФ.ChoiceList.Add(Элем.Key);
	EndDo;
EndProcedure

&AtClient
Procedure ТабРолиСДоступомВыбор(Item, SelectedRow, Field, StandardProcessing)
	StandardProcessing = False;

	ТекДанные = Items.RolesWithAccessTable.CurrentData;
	If ТекДанные <> Undefined Then
		пПолноеИмя = "Role." + ТекДанные.Name;
		СтрукПараметры = New Structure("FullName, PathToForms, _StorageAddresses, ОписаниеПравДоступа", пПолноеИмя,
			PathToForms, _StorageAddresses, мОписаниеПравДоступа);
		СтрукПараметры.Insert("НастройкиОбработки", вСформироватьСтруктуруНастроекФормыСвойствОбъекта());
		OpenForm(PathToForms + "ФормаСвойств", СтрукПараметры, , пПолноеИмя, , , ,
			FormWindowOpeningMode.Independent);
	EndIf;
EndProcedure

&AtClient
Procedure ТабПользователиСДоступомВыбор(Item, SelectedRow, Field, StandardProcessing)
	StandardProcessing = False;

	ТекДанные = Items.UsersWithAccessTable.CurrentData;
	If ТекДанные <> Undefined Then
		пИдентификаторПользователя = вПолучитьИдентификаторПользователя(ТекДанные.Name);

		If Not IsBlankString(пИдентификаторПользователя) Then
			пСтрук = New Structure("РежимРаботы, DBUserID", 0, пИдентификаторПользователя);
			OpenForm(PathToForms + "ФормаПользовательИБ", пСтрук, , , , , ,
				FormWindowOpeningMode.LockOwnerWindow);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure вСформироватьОписаниеПравДоступа()
	ПереченьА = "Read, Create, Update, Delete, Browse, Edit";
	ПереченьБ = "Read, Update, Browse, Edit, УправлениеИтогами";

	мОписаниеПравДоступа = New Map;
	мОписаниеПравДоступа.Insert("Подсистема", "Browse");
	мОписаниеПравДоступа.Insert("ПараметрСеанса", "Receive, Установка");
	мОписаниеПравДоступа.Insert("ОбщийРеквизит", "Browse, Edit");
	мОписаниеПравДоступа.Insert("ExchangePlan", ПереченьА);
	мОписаниеПравДоступа.Insert("FilterCriterion", "Browse");
	мОписаниеПравДоступа.Insert("ОбщаяФорма", "Browse");
	мОписаниеПравДоступа.Insert("ОбщаяКоманда", "Browse");
	мОписаниеПравДоступа.Insert("ЧужаяКоманда", "Browse");
	мОписаниеПравДоступа.Insert("WebСервис.Property", "Use");
	мОписаниеПравДоступа.Insert("HTTPСервис.Property", "Use");
	мОписаниеПравДоступа.Insert("Constant", "Read, Update, Browse, Edit");
	мОписаниеПравДоступа.Insert("Catalog", ПереченьА);
	мОписаниеПравДоступа.Insert("Document", ПереченьА + ", Posting, UndoPosting");
	мОписаниеПравДоступа.Insert("Sequence", "Read, Update");
	мОписаниеПравДоступа.Insert("DocumentJournal", "Read, Browse");
	мОписаниеПравДоступа.Insert("Report", "Use, Browse");
	мОписаниеПравДоступа.Insert("Processing", "Use, Browse");
	мОписаниеПравДоступа.Insert("ChartOfCharacteristicTypes", ПереченьА);
	мОписаниеПравДоступа.Insert("ChartOfCalculationTypes", ПереченьА);
	мОписаниеПравДоступа.Insert("ChartOfAccounts", ПереченьА);
	мОписаниеПравДоступа.Insert("InformationRegister", ПереченьБ);
	мОписаниеПравДоступа.Insert("AccumulationRegister", ПереченьБ);
	мОписаниеПравДоступа.Insert("AccountingRegister", ПереченьБ);
	мОписаниеПравДоступа.Insert("CalculationRegister", "Read, Update, Browse, Edit");
	мОписаниеПравДоступа.Insert("BusinessProcess", ПереченьА + ", Start");
	мОписаниеПравДоступа.Insert("Task", ПереченьА + ", Выполнение");

EndProcedure

&AtClient
Procedure kCalculateObjectsNumber(Command)
	ТекДанные = Items.ObjectsTree.CurrentData;

	If ТекДанные <> Undefined Then
		If ТекДанные.NodeType = "MetadataObject" Then
			Перечень = "Sequence, ExchangePlan, Catalog, Document, DocumentJournal, ChartOfCharacteristicTypes
					   |, ChartOfCalculationTypes, ChartOfAccounts, InformationRegister, AccumulationRegister, AccountingRegister, CalculationRegister, BusinessProcess, Task";

			Струк = New Structure(Перечень);
			ТипМД = Left(ТекДанные.FullName, StrFind(ТекДанные.FullName, ".") - 1);

			If Not Струк.Property(ТипМД) Then
				Return;
			EndIf;

			МассивОбъектов = New Array;

			Струк = New Structure("FullName, NumberOfObjects", ТекДанные.FullName);
			МассивОбъектов.Add(Струк);

			РодительДЗ = ТекДанные.GetParent();

			РодительДЗ.NumberOfObjects = РодительДЗ.NumberOfObjects - ТекДанные.NumberOfObjects;

			вРассчитатьКоличествоОбъектов(МассивОбъектов);
			ТекДанные.NumberOfObjects = МассивОбъектов[0].NumberOfObjects;

			РодительДЗ.NumberOfObjects = РодительДЗ.NumberOfObjects + ТекДанные.NumberOfObjects;

		ElsIf ТекДанные.NodeType = "РазделМД" Then
			СтрокиДЗ = ТекДанные.GetItems();
			If СтрокиДЗ.Count() = 1 And IsBlankString(СтрокиДЗ[0].NodeType) Then
				Return;
			EndIf;

			Перечень = "Sequences, ExchangePlans, Catalogs, Documents, DocumentJournals, ChartsOfCharacteristicTypes
					   |, ChartsOfCalculationTypes, ChartsOfAccounts, InformationRegisters, AccumulationRegisters, AccountingRegisters, CalculationRegisters, BusinessProcesses, Tasks";

			Струк = New Structure(Перечень);
			Поз = StrFind(ТекДанные.Name, " ");
			If Поз = 0 Then
				ИмяРаздела = ТекДанные.Name;
			Else
				ИмяРаздела = Left(ТекДанные.Name, Поз - 1);
			EndIf;

			If Not Струк.Property(ИмяРаздела) Then
				Return;
			EndIf;

			МассивОбъектов = New Array;

			For Each Стр In СтрокиДЗ Do
				If Стр.NodeType = "MetadataObject" Then
					Струк = New Structure("ID, FullName, NumberOfObjects",
						Стр.GetID(), Стр.FullName);
					МассивОбъектов.Add(Струк);
				EndIf;
			EndDo;

			вРассчитатьКоличествоОбъектов(МассивОбъектов);

			ObjectCount = 0;
			For Each Стр In МассивОбъектов Do
				СтрДЗ = ObjectsTree.FindByID(Стр.ID);
				If СтрДЗ <> Undefined Then
					ObjectCount= ObjectCount + Стр.NumberOfObjects;
					СтрДЗ.NumberOfObjects = Стр.NumberOfObjects;
				EndIf;
			EndDo;
			ТекДанные.NumberOfObjects = ObjectCount;

		EndIf;
	EndIf;
EndProcedure

&AtServerNoContext
Function вРассчитатьКоличествоОбъектов(МассивОбъектов)
	SetPrivilegedMode(True);

	пИспользоватьПопытку = Not PrivilegedMode() And Not вЕстьПраваАдминистратора();

	For Each Элем In МассивОбъектов Do
		Query = New Query;
		Query.Text = "ВЫБРАТЬ
					   |	КОЛИЧЕСТВО(*) КАК NumberOfObjects
					   |ИЗ
					   |	" + Элем.FullName + " КАК ТаблицаБД";

		If пИспользоватьПопытку Then
			Try
				Выборка = Query.Execute().StartChoosing();
				Элем.NumberOfObjects = ?(Выборка.Next(), Выборка.ObjectCount, 0);
			Except
				Элем.NumberOfObjects = 0;
			EndTry;
		Else
			Выборка = Query.Execute().StartChoosing();
			Элем.NumberOfObjects = ?(Выборка.Next(), Выборка.ObjectCount, 0);
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
	ТекДанные = Items.ObjectsTree.CurrentData;
	If ТекДанные <> Undefined Then
		If ТекДанные.NodeType = "MetadataObject" Then
			СтрДЗ = ObjectsTree.FindByID(мИдентификаторИзбранного).GetItems().Add();
			FillPropertyValues(СтрДЗ, ТекДанные);
			вВключитьФлагИзмененияНастроек();
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure _DeleteFromFavorites(Command)
	ТекДанные = Items.ObjectsTree.CurrentData;
	If ТекДанные <> Undefined Then
		If Not IsBlankString(ТекДанные.FullName) Then
			СтрокиДЗ = ObjectsTree.FindByID(мИдентификаторИзбранного).GetItems();
			For Each СтрДЗ In СтрокиДЗ Do
				If СтрДЗ.FullName = ТекДанные.FullName Then
					СтрокиДЗ.Delete(СтрДЗ);
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
	ObjectsTree.FindByID(мИдентификаторИзбранного).GetItems().Clear();
	вВключитьФлагИзмененияНастроек();
EndProcedure

&AtClient
Procedure _OderFavorites(Command)
	вУпорядочитьИзбранное(); // плохой способ

	For Each СтрДЗ In ObjectsTree.GetItems() Do
		If СтрДЗ.FullName = "Favorites" Then
			мИдентификаторИзбранного = СтрДЗ.GetID();
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
	ТекДанные = Items.ObjectsTree.CurrentData;
	If ТекДанные <> Undefined Then
		If ТекДанные.NodeType = "MetadataObject" Or ТекДанные.NodeType = "Конфигурация" Then
			If Not вЕстьПраваАдминистратора() Then
				вПоказатьПредупреждение("None прав на выполнение операции!");
				Return;
			EndIf;

			пТекст = ?(ТекДанные.NodeType = "Конфигурация", "Нумерация всех объектов будет обновлена. Continue?",
				"Нумерация обекта будет обновлена. Continue?");
			ShowQueryBox(New NotifyDescription("вОбновитьНумерациюОбъектовОтвет", ThisForm, ТекДанные.FullName),
				пТекст, QuestionDialogMode.YesNoCancel, 20);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure _UpdateNumberingOfAllObjects(Command)
	пТекст = "Нумерация всех объектов будет обновлена. Continue?";
	ShowQueryBox(New NotifyDescription("вОбновитьНумерациюОбъектовОтвет", ThisForm, "Конфигурация"), пТекст,
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
	If FullName = "Конфигурация" Then
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
	ТекДанные = Items._Indexes.CurrentData;
	If ТекДанные <> Undefined Then
		Array = _Tables.FindRows(New Structure("TableName", ТекДанные.TableName));
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

	пМассив = вПолучитьПользователейИБ(пПереченьПолей, _ShowUserRolesList);
	For Each Элем In пМассив Do
		FillPropertyValues(_DBUserList.Add(), Элем);
	EndDo;

	_DBUserList.Sort("Name");

	If Items._DBUserListListOfRoles.Visible <> _ShowUserRolesList Then
		Items._DBUserListListOfRoles.Visible = _ShowUserRolesList;
	EndIf;

	Items.DBUsers.Title = "Users (" + пМассив.Count() + ")";
EndProcedure

&AtServerNoContext
Function вПолучитьПользователейИБ(Val пПереченьПолей, Val пЗаполнятьПереченьРолнй = False)
	пРезультат = New Array;

	For Each Элем In InfoBaseUsers.GetUsers() Do
		пСтрук = New Structure(пПереченьПолей);
		FillPropertyValues(пСтрук, Элем);

		If пЗаполнятьПереченьРолнй Then
			пСписокРолей = New ValueList;
			For Each пРоль In Элем.Roles Do
				пСписокРолей.Add(пРоль.Name);
			EndDo;
			пСписокРолей.SortByValue();

			пПереченьРолей = "";
			For Each пРоль In пСписокРолей Do
				пПереченьРолей = пПереченьРолей + ", " + пРоль.Value;
			EndDo;
			пСтрук.ListOfRoles = Mid(пПереченьРолей, 2);
		EndIf;

		пРезультат.Add(пСтрук);
	EndDo;

	Return пРезультат;
EndFunction

&AtClient
Procedure _СписокПользователейИБВыбор(Item, SelectedRow, Field, StandardProcessing)
	StandardProcessing = False;

	ТекДанные = _DBUserList.FindByID(SelectedRow);
	If ТекДанные <> Undefined Then
		пСтрук = New Structure("РежимРаботы, DBUserID", 0, ТекДанные.UUID);
		OpenForm(PathToForms + "ФормаПользовательИБ", пСтрук, , , , , ,
			FormWindowOpeningMode.LockOwnerWindow);
	EndIf;
EndProcedure

&AtClient
Procedure _СписокПользователейИБПередНачаломДобавления(Item, Cancel, Copy, Parent, Group, Parameter)
	Cancel = True;

	If Copy Then
		ТекДанные = Item.CurrentData;
		If ТекДанные <> Undefined Then
			пСтрук = New Structure("РежимРаботы, DBUserID", 2, ТекДанные.UUID);
			OpenForm(PathToForms + "ФормаПользовательИБ", пСтрук, , , , , ,
				FormWindowOpeningMode.LockOwnerWindow);
		EndIf;
	Else
		пСтрук = New Structure("РежимРаботы", 1);
		OpenForm(PathToForms + "ФормаПользовательИБ", пСтрук, , , , , ,
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

	вПоказатьВопрос(пТекст, "вУдалитьПользователейИБОтвет", пВыделенныеСтроки);
EndProcedure

&AtClient
Procedure вУдалитьПользователейИБОтвет(Ответ, пВыделенныеСтроки) Export
	If Ответ = DialogReturnCode.Yes Then
		пМассив = New Array;
		For Each Стр In пВыделенныеСтроки Do
			ТекДанные = _DBUserList.FindByID(Стр);
			If ТекДанные <> Undefined Then
				пМассив.Add(ТекДанные.UUID);
			EndIf;
		EndDo;

		If пМассив.Count() <> 0 Then
			пМассивУдаленных = вУдалитьПользователейИБ(пМассив);
			For Each Элем In пМассивУдаленных Do
				For Each СтрХ In _DBUserList.FindRows(New Structure("UUID",
					Элем)) Do
					_DBUserList.Delete(СтрХ);
				EndDo;
			EndDo;
		EndIf;
	EndIf;
EndProcedure

&AtServerNoContext
Function вУдалитьПользователейИБ(Val пМассивИдентификаторов)
	пРезультат = New Array;

	пТекПользователь = InfoBaseUsers.CurrentUser();

	For Each Элем In пМассивИдентификаторов Do
		Try
			пUUID = New UUID(Элем);

			пПользователь = InfoBaseUsers.FindByUUID(пUUID);
			If пПользователь = Undefined Or (пТекПользователь <> Undefined
				And пТекПользователь.UUID = пUUID) Then
				Continue;
			EndIf;

			пПользователь.Delete();
			пРезультат.Add(Элем);
		Except
			Message(BriefErrorDescription(ErrorInfo()));
		EndTry;
	EndDo;

	Return пРезультат;
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

	пМассив = вПолучитьСенансы(пПереченьПолей);

	For Each Элем In пМассив Do
		FillPropertyValues(_SessionList.Add(), Элем);
	EndDo;

	_SessionList.Sort("SessionStart");

	Items.SessionsGroup.Title = "Сеансы информационной базы (" + пМассив.Count() + ")";
EndProcedure

&AtServerNoContext
Function вПолучитьСенансы(Val пПереченьПолей)
	SetPrivilegedMode(True);

	пТекНомерСеанса = InfoBaseSessionNumber();

	пРезультат = New Array;

	For Each Элем In GetInfoBaseSessions() Do
		пСтрук = New Structure(пПереченьПолей);
		FillPropertyValues(пСтрук, Элем);

		пСтрук.CurrentSession = (Элем.SessionNumber = пТекНомерСеанса);

		пСтрук.ApplicationPresentation = ApplicationPresentation(пСтрук.ApplicationName);

		пСтрук.User = String(пСтрук.User);

		If Элем.User <> Undefined Then
			пСтрук.DBUserID = String(Элем.User.UUID);
		EndIf;

		пФоновоеЗадание = Элем.GetBackgroundJob();
		If пФоновоеЗадание <> Undefined Then
			FillPropertyValues(пСтрук, пФоновоеЗадание);
			пСтрук.State = String(пФоновоеЗадание.Status);
			пСтрук.ScheduledJob = String(пФоновоеЗадание.ScheduledJob);
			пСтрук.BackgroundJobID = String(пФоновоеЗадание.UUID);
		EndIf;

		пРезультат.Add(пСтрук);
	EndDo;

	Return пРезультат;
EndFunction

&AtClient
Procedure _FillInConnectionsList(Command)
	_ConnectionsList.Clear();

	пПереченьПолей = "ТекущееСоединение, Active, ComputerName, ApplicationName, ApplicationPresentation, SessionStart, SessionNumber, ConnectionNumber, User, DBUserID";

	пМассив = вПолучитьСоединения(пПереченьПолей);

	For Each Элем In пМассив Do
		FillPropertyValues(_ConnectionsList.Add(), Элем);
	EndDo;

	_ConnectionsList.Sort("SessionStart");

	Items.ConnectionsGroup.Title = "Joins информационной базы (" + пМассив.Count() + ")";
EndProcedure

&AtServerNoContext
Function вПолучитьСоединения(Val пПереченьПолей)
	SetPrivilegedMode(True);

	пТекНомерСоединения = InfoBaseConnectionNumber();

	пРезультат = New Array;

	For Each Элем In GetInfoBaseConnections() Do
		пСтрук = New Structure(пПереченьПолей);
		FillPropertyValues(пСтрук, Элем);

		пСтрук.ТекущееСоединение = (Элем.ConnectionNumber = пТекНомерСоединения);

		пСтрук.Active = ValueIsFilled(Элем.SessionNumber);

		пСтрук.ApplicationPresentation = ApplicationPresentation(пСтрук.ApplicationName);

		пСтрук.User = String(пСтрук.User);

		If Элем.User <> Undefined Then
			пСтрук.DBUserID = String(Элем.User.UUID);
		EndIf;

		пРезультат.Add(пСтрук);
	EndDo;

	Return пРезультат;
EndFunction
&AtClient
Procedure _FinishSessions(Command)
	пВыделенныеСтроки = Items._SessionList.SelectedRows;
	If пВыделенныеСтроки.Count() = 0 Then
		Return;
	EndIf;

	пМассивСеансов = New Array;
	For Each Элем In пВыделенныеСтроки Do
		Стр = _SessionList.FindByID(Элем);
		If Not Стр.CurrentSession Then
			пМассивСеансов.Add(Стр.SessionNumber);
		EndIf;
	EndDo;

	If пМассивСеансов.Count() = 0 Then
		вПоказатьПредупреждение("Невозможно завершить текущий сеанс!
								|For выхода из программы можно закрыть главное окно программы.");
		Return;
	EndIf;

	пТекст = StrTemplate("Отмеченные сеансы (%1 шт) будут завершены.
					   |Continue?", пМассивСеансов.Count());

	вПоказатьВопрос(пТекст, "вЗавершитьСеансыОтвет", пМассивСеансов);
EndProcedure

&AtClient
Procedure вЗавершитьСеансыОтвет(Ответ, пМассивСеансов) Export
	If Ответ = DialogReturnCode.Yes Then
		If мПараметрыКластера1С = Undefined Then
			мПараметрыКластера1С = вПолучитьПараметрыКластера1С();
		EndIf;

		If мПараметрыКластера1С.ФайловыйВариантИБ Then
			Items._SessionList_FinishSessions.Enabled = False;
			Items.ClusterAdministratorGroup.ReadOnly = True;
			вПоказатьПредупреждение("End сеансов реализовано только для клиент-серверного варианта!");
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
	COMСоединитель = New COMObject(мПараметрыКластера1С.ИмяCOMСоединителя, мПараметрыКластера1С.СерверCOMСоединителя);

	пСоединениеСАгентомСервера = вСоединениеСАгентомСервера(
		COMСоединитель, мПараметрыКластера1С.АдресАгентаСервера, мПараметрыКластера1С.ПортАгентаСервера);

	пКластер = вПолучитьКластер(
		пСоединениеСАгентомСервера, мПараметрыКластера1С.ПортКластера, _ClusterAdministratorName, ?(IsBlankString(
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
	пРезультат = New Structure;

	пСистемнаяИнфо = New SystemInfo;
	пСтрокаСоединения = InfoBaseConnectionString();

	пРезультат.Insert("ФайловыйВариантИБ", (Find(Врег(пСтрокаСоединения), "FILE=") = 1));
	пРезультат.Insert("СерверCOMСоединителя", "");
	пРезультат.Insert("ПортАгентаСервера", 1540);
	пРезультат.Insert("ПортКластера", 1541);
	пРезультат.Insert("АдресАгентаСервера", "LocalHost");
	пРезультат.Insert("ИмяАдминистратораКластера", "");
	пРезультат.Insert("ПарольАдминистратораКластера", "");
	пРезультат.Insert("ИмяВКластере", "");
	пРезультат.Insert("ТипПодключения", "COM");
	пРезультат.Insert("ИмяCOMСоединителя", "V83.COMConnector");
	пРезультат.Insert("ИмяАдминистратораИнформационнойБазы", InfoBaseUsers.CurrentUser().Name);
	пРезультат.Insert("ПарольАдминистратораИнформационнойБазы", "");
	пРезультат.Insert("Платформа1С", "83");

	пМассивСтр = StrSplit(пСтрокаСоединения, ";", False);

	пЗначение = StrReplace(вЗначениеКлючаСтроки(пМассивСтр, "Srvr"), """", "");
	Поз = Find(пЗначение, ":");
	If Поз <> 0 Then
		пРезультат.Insert("АдресАгентаСервера", TrimAll(Mid(пЗначение, 1, Поз - 1)));
		пРезультат.Insert("ПортКластера", Number(Mid(пЗначение, Поз + 1)));
	Else
		пРезультат.Insert("АдресАгентаСервера", пЗначение);
		пРезультат.Insert("ПортКластера", 1541);
	EndIf;
	пРезультат.ПортАгентаСервера = пРезультат.ПортКластера - 1;

	пРезультат.Insert("ИмяВКластере", StrReplace(вЗначениеКлючаСтроки(пМассивСтр, "Ref"), """", ""));

	пРезультат.Insert("AppVersion", пСистемнаяИнфо.AppVersion);
	пРезультат.Insert("BinDir", BinDir());

	If Find(пРезультат.AppVersion, "8.4.") = 1 Then
		пРезультат.Insert("ИмяCOMСоединителя", "V84.COMConnector");
		пРезультат.Insert("Платформа1С", "84");
	EndIf;

	Return пРезультат;
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

	пМассив = вПолучитьСписокРасширений();

	For Each Элем In пМассив Do
		FillPropertyValues(_ExtensionsList.Add(), Элем);
	EndDo;
	
	//вЗаполнитьСписокРасширений();

	_ExtensionsList.Sort("Name");

	Items.ConfigurationExtensions.Title = "Расширения конфигурации (" + _ExtensionsList.Count() + ")";
EndProcedure

&AtServer
Procedure вЗаполнитьСписокРасширений()
	_ExtensionsList.Clear();

	пМассив = ConfigurationExtensions.Get();

	For Each Элем In пМассив Do
		НС = _ExtensionsList.Add();
		FillPropertyValues(НС, Элем);
	EndDo;
EndProcedure

&AtClientAtServerNoContext
Function вСформироватьСтруктуруСвойствРасширения(пРежим = 0)
	пСтрук = New Structure("Active, SafeMode, Version, UnsafeOperationProtection, Name, Purpose, Scope, Synonym, UUID, HashSum");

	If пРежим = 1 Then
		For Each Элем In пСтрук Do
			пСтрук[Элем.Key] = -1;
		EndDo;
	EndIf;

	Return пСтрук;
EndFunction

&AtServerNoContext
Function вПроверитьНаличиеТипа(Val пИмяТипа)
	Try
		пТип = Type(пИмяТипа);
	Except
		Return False;
	EndTry;

	Return True;
EndFunction
&AtServerNoContext
Function вПолучитьСписокРасширений()
	пРезультат = New Array;

	пМассив = ConfigurationExtensions.Get();

	For Each Элем In пМассив Do
		пСтрук = вСформироватьСтруктуруСвойствРасширения(1);
		FillPropertyValues(пСтрук, Элем);

		If пСтрук.UnsafeOperationProtection = -1 Then
			пСтрук.UnsafeOperationProtection = Undefined;
		Else
			пСтрук.UnsafeOperationProtection = пСтрук.UnsafeOperationProtection.UnsafeOperationWarnings;
		EndIf;

		If пСтрук.Scope = -1 Then
			пСтрук.Scope = Undefined;
		Else
			пСтрук.Scope = String(пСтрук.Scope);
		EndIf;

		If пСтрук.Purpose = -1 Then
			пСтрук.Purpose = Undefined;
		Else
			пСтрук.Purpose = String(пСтрук.Purpose);
		EndIf;

		пРезультат.Add(пСтрук);
	EndDo;

	Return пРезультат;
EndFunction

&AtClient
Procedure RunConfiguratorUnderUser(Command)
	ТекДанные=Items._DBUserList.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.Run1CSession(1, ТекДанные.Name, True,
		WaitingTimeBeforePasswordRecovery);
EndProcedure

&AtClient
Procedure RunOrdinaryClientUnderUser(Command)
	ТекДанные=Items._DBUserList.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.Run1CSession(2, ТекДанные.Name, True,
		WaitingTimeBeforePasswordRecovery);
EndProcedure

&AtClient
Procedure RunThickClientUnderUser(Command)
	ТекДанные=Items._DBUserList.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.Run1CSession(3, ТекДанные.Name, True,
		WaitingTimeBeforePasswordRecovery);
EndProcedure

&AtClient
Procedure RunThinClientUnderUser(Command)
	ТекДанные=Items._DBUserList.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.Run1CSession(4, ТекДанные.Name, True,
		WaitingTimeBeforePasswordRecovery);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure


