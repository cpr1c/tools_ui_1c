#Region Public

#Region СозданиеЭлементовФормы

Procedure FormOnCreateAtServer(Form, ВидРедактора = Undefined) Export
	If ВидРедактора = Undefined Then
		ПараметрыРедактора = CodeEditorCurrentSettings();
		ВидРедактора = ПараметрыРедактора.Variant;
	EndIf;
	ВариантыРедактора = UT_CodeEditorClientServer.CodeEditorVariants();
	
	ЭтоWindowsКлиент = False;
	ЭтоВебКлиент = True;
	
	ПараметрыСеансаВХранилище = UT_CommonServerCall.CommonSettingsStorageLoad(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(),
		UT_CommonClientServer.SessionParametersSettingsKey());
	If Type(ПараметрыСеансаВХранилище) = Type("Structure") Then
		If ПараметрыСеансаВХранилище.Property("HTMLFieldBasedOnWebkit") Then
			If Not ПараметрыСеансаВХранилище.HTMLFieldBasedOnWebkit Then
				ВидРедактора = ВариантыРедактора.Text;
			EndIf;
		EndIf;
		If ПараметрыСеансаВХранилище.Property("IsWindowsClient") Then
			ЭтоWindowsКлиент = ПараметрыСеансаВХранилище.IsWindowsClient;
		EndIf;
		If ПараметрыСеансаВХранилище.Property("IsWebClient") Then
			ЭтоВебКлиент = ПараметрыСеансаВХранилище.IsWebClient;
		EndIf;
		
	EndIf;
	
	ИмяРеквизитаВидРедактора=UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора();
	ИмяРеквизитаАдресБиблиотеки=UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаАдресБиблиотеки();
	ИмяРеквизитаРедактораКодаСписокРедакторовФормы = UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаСписокРедакторовФормы();
	
	МассивРеквизитов=New Array;
	МассивРеквизитов.Add(New FormAttribute(ИмяРеквизитаВидРедактора, New TypeDescription("String", , New StringQualifiers(20,
		AllowedLength.Variable)), "", "", True));
	МассивРеквизитов.Add(New FormAttribute(ИмяРеквизитаАдресБиблиотеки, New TypeDescription("String", , New StringQualifiers(0,
		AllowedLength.Variable)), "", "", True));
	МассивРеквизитов.Add(New FormAttribute(ИмяРеквизитаРедактораКодаСписокРедакторовФормы, New TypeDescription, "", "", True));
		
	Form.ChangeAttributes(МассивРеквизитов);
	
	Form[ИмяРеквизитаВидРедактора]=ВидРедактора;
	Form[ИмяРеквизитаАдресБиблиотеки] = ПоместитьБиблиотекуВоВременноеХранилище(Form.UUID, ЭтоWindowsКлиент, ЭтоВебКлиент, ВидРедактора);
	Form[ИмяРеквизитаРедактораКодаСписокРедакторовФормы] = New Structure;
EndProcedure

Procedure CreateCodeEditorItems(Form, ИдентификаторРедактора, ПолеРедактора, ЯзыкРедактора = "bsl") Export
	ИмяРеквизитаВидРедактора=UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора();
	
	ВидРедактора = Form[ИмяРеквизитаВидРедактора];
	
	ДанныеРедактора = New Structure;

	If UT_CodeEditorClientServer.РедакторКодаИспользуетПолеHTML(ВидРедактора) Then
		If ПолеРедактора.Type <> FormFieldType.HTMLDocumentField Then
			ПолеРедактора.Type = FormFieldType.HTMLDocumentField;
		EndIf;
		ПолеРедактора.SetAction("DocumentComplete", "Подключаемый_ПолеРедактораДокументСформирован");
		ПолеРедактора.SetAction("OnClick", "Подключаемый_ПолеРедактораПриНажатии");

		ДанныеРедактора.Insert("Инициализирован", False);

	Else
		ПолеРедактора.Type = FormFieldType.TextDocumentField;
		ДанныеРедактора.Insert("Инициализирован", True);
	EndIf;

	ДанныеРедактора.Insert("Lang", ЯзыкРедактора);
	ДанныеРедактора.Insert("ПолеРедактора", ПолеРедактора.Name);
	ДанныеРедактора.Insert("ИмяРеквизита", ПолеРедактора.DataPath);
	
	ВариантыРедактора = UT_CodeEditorClientServer.CodeEditorVariants();

	ПараметрыРедактора = CodeEditorCurrentSettings();
	ДанныеРедактора.Insert("ПараметрыРедактора", ПараметрыРедактора);

	If ВидРедактора = ВариантыРедактора.Monaco Then
		For Each KeyValue ИЗ ПараметрыРедактора.Monaco Do
			ДанныеРедактора.ПараметрыРедактора.Insert(KeyValue.Key, KeyValue.Value);
		EndDo;
	EndIf;
	
	Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()].Insert(ИдентификаторРедактора,  ДанныеРедактора);	
EndProcedure

#EndRegion

Function ПоместитьБиблиотекуВоВременноеХранилище(ИдентификаторФормы, ЭтоWindowsКлиент, ЭтоВебКлиент, ВидРедактора=Undefined) Export
	If ВидРедактора = Undefined Then
		ВидРедактора = ТекущийВариантРедактораКода1С();
	EndIf;
	ВариантыРедактора = UT_CodeEditorClientServer.CodeEditorVariants();
	
	If ВидРедактора = ВариантыРедактора.Monaco Then
		If ЭтоWindowsКлиент Then
			ДвоичныеДанныеБиблиотеки=GetCommonTemplate("UT_MonacoEditorWindows");
		Else
			ДвоичныеДанныеБиблиотеки=GetCommonTemplate("UT_MonacoEditor");
		EndIf;
	ElsIf ВидРедактора = ВариантыРедактора.Ace Then
		ДвоичныеДанныеБиблиотеки=GetCommonTemplate("UT_Ace");
	Else
		Return Undefined;
	EndIf;
	
	СтруктураБиблиотеки=New Map;

	If Not ЭтоВебКлиент Then
		СтруктураБиблиотеки.Insert("editor.zip",ДвоичныеДанныеБиблиотеки);

		Return PutToTempStorage(СтруктураБиблиотеки, ИдентификаторФормы);
	EndIf;
	
	КаталогНаСервере=GetTempFileName();
	CreateDirectory(КаталогНаСервере);

	Stream=ДвоичныеДанныеБиблиотеки.OpenStreamForRead();

	ЧтениеZIP=New ZipFileReader(Stream);
	ЧтениеZIP.ExtractAll(КаталогНаСервере, ZIPRestoreFilePathsMode.Restore);


	ФайлыАрхива=FindFiles(КаталогНаСервере, "*", True);
	For Each ФайлБиблиотеки In ФайлыАрхива Do
		КлючФайла=StrReplace(ФайлБиблиотеки.FullName, КаталогНаСервере + GetPathSeparator(), "");
		If ФайлБиблиотеки.IsDirectory() Then
			Continue;
		EndIf;

		СтруктураБиблиотеки.Insert(КлючФайла, New BinaryData(ФайлБиблиотеки.FullName));
	EndDo;

	АдресБиблиотеки=PutToTempStorage(СтруктураБиблиотеки, ИдентификаторФормы);

	Try
		DeleteFiles(КаталогНаСервере);
	Except
		// TODO:
	EndTry;

	Return АдресБиблиотеки;
EndFunction

#Region НастройкиИнструментов


Function ТекущийВариантРедактораКода1С() Export
	ПараметрыРедактораКода = CodeEditorCurrentSettings();
	
	РедакторКода = ПараметрыРедактораКода.Variant;
	
	УИ_ПараметрыСеанса = UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(),
		UT_CommonClientServer.SessionParametersSettingsKey());
		
	If Type(УИ_ПараметрыСеанса) = Type("Structure") Then
		If УИ_ПараметрыСеанса.HTMLFieldBasedOnWebkit<>True Then
			РедакторКода = UT_CodeEditorClientServer.CodeEditorVariants().Text;
		EndIf;
	EndIf;
	
	Return РедакторКода;
EndFunction

Procedure SetCodeEditorNewSettings(НовыеНастройки) Export
	UT_Common.CommonSettingsStorageSave(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "ПараметрыРедактораКода",
		НовыеНастройки);
EndProcedure

Function CodeEditorCurrentSettings() Export
	СохраненныеПараметрыРедактора = UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "ПараметрыРедактораКода");

	ПараметрыПоУмолчанию = UT_CodeEditorClientServer.ПараметрыРедактораКодаПоУмолчанию();
	If СохраненныеПараметрыРедактора = Undefined Then		
		MonacoEditorParameters = CurrentMonacoEditorParameters();
		
		FillPropertyValues(ПараметрыПоУмолчанию.Monaco, MonacoEditorParameters);
	Else
		FillPropertyValues(ПараметрыПоУмолчанию, СохраненныеПараметрыРедактора,,"Monaco");
		FillPropertyValues(ПараметрыПоУмолчанию.Monaco, СохраненныеПараметрыРедактора.Monaco);
	EndIf;
	
	Return ПараметрыПоУмолчанию;
	
EndFunction

#EndRegion

#Region WorkWithMetaData

Function ConfigurationScriptVariant() Export
	If Metadata.ScriptVariant = Metadata.ObjectProperties.ScriptVariant.English Then
		Return "English";
	Else
		Return "Russian";
	EndIf;
EndFunction

Function MetadataObjectHasPredefined(MetadataTypeName)
	
	Objects = New Array();
	Objects.Add("сatalog");
	Objects.Add("catalogs");
	Objects.Add("chartofaccounts");	
	Objects.Add("сhartsofaccounts");	
	Objects.Add("chartofcharacteristictypes");
	Objects.Add("chartsofcharacteristictypes");
	Objects.Add("chartofcalculationtypes");
	Objects.Add("chartsofcalculationtypes");
	
	Return Objects.Find(Lower(MetadataTypeName)) <> Undefined;
	
EndFunction

Function MetadataObjectHasVirtualTables(MetadataTypeName)
	
	Objects = New Array();
	Objects.Add("InformationRegisters");
	Objects.Add("AccumulationRegisters");	
	Objects.Add("CalculationRegisters");
	Objects.Add("AccountingRegisters");
	
	Return Objects.Find(MetadataTypeName) <> Undefined;
	
EndFunction


Function MetadataObjectAttributeDescription(Attribute,AllRefsType)
	Description = New Structure;
	Description.Insert("Name", Attribute.Name);
	Description.Insert("Synonym", Attribute.Synonym);
	Description.Insert("Comment", Attribute.Comment);
	
	RefTypes = New Array;
	For каждого CurrentType In Attribute.Type.Types() Do
		If AllRefsType.ContainsType(CurrentType) Then
			RefTypes.Add(CurrentType);
		EndIf;
	EndDo;
	Description.Insert("Type", New TypeDescription(RefTypes));
	
	Return Description;
EndFunction

Function ConfigurationMetadataObjectDescriptionByName(ObjectType, ObjectName) Export
	AllRefsType = UT_Common.AllRefsTypeDescription();

	Return ConfigurationMetadataObjectDescription(Metadata[ObjectType][ObjectName], ObjectType, AllRefsType);	
EndFunction

Function ConfigurationMetadataObjectDescription(ObjectOfMetadata, ObjectType, AllRefsType, IncludeAttributesDescription = True) Export
	ItemDescription = New Structure;
	ItemDescription.Insert("ObjectType", ObjectType);
	ItemDescription.Insert("Name", ObjectOfMetadata.Name);
	ItemDescription.Insert("Synonym", ObjectOfMetadata.Synonym);
	ItemDescription.Insert("Comment", ObjectOfMetadata.Comment);
	
	Extension = ObjectOfMetadata.ConfigurationExtension();
	If Extension <> Undefined Then
		ItemDescription.Insert("Extension", Extension.Name);
	Else
		ItemDescription.Insert("Extension", Undefined);
	EndIf;
	If Lower(ObjectType) = "constant"
		Or Lower(ObjectType) = "constants" Then
		ItemDescription.Insert("Type", ObjectOfMetadata.Type);
	ElsIf Lower(ObjectType) = "enum"
		Or Lower(ObjectType) = "enums"Then
		EnumValues = New Structure;

		For Each CurrentValue In ObjectOfMetadata.EnumValues Do
			EnumValues.Insert(CurrentValue.Name, CurrentValue.Synonym);
		EndDo;

		ItemDescription.Insert("EnumValues", EnumValues);
	EndIf;

	If Not IncludeAttributesDescription Then
		Return ItemDescription;
	EndIf;
	
	AttributesCollections = New Structure("Attributes, StandardAttributes, Dimensions, Resources, AddressingAttributes, AccountingFlags");
	TabularSectionsCollections = New Structure("TabularSections, StandardTabularSections");
	FillPropertyValues(AttributesCollections, ObjectOfMetadata);
	FillPropertyValues(TabularSectionsCollections, ObjectOfMetadata);

	For Each KeyValue In AttributesCollections Do
		If KeyValue.Value = Undefined Then
			Continue;
		EndIf;

		AttributesCollectionDescription= New Structure;

		For Each CurrentAttribute In KeyValue.Value Do
			AttributesCollectionDescription.Insert(CurrentAttribute.Name, MetadataObjectAttributeDescription(CurrentAttribute,
				AllRefsType));
		EndDo;

		ItemDescription.Insert(KeyValue.Key, AttributesCollectionDescription);
	EndDo;

	For Each KeyValue In TabularSectionsCollections Do
		If KeyValue.Value = Undefined Then
			Continue;
		EndIf;

		TabularSectionCollectionDescription = New Structure;

		For Each TabularSection In KeyValue.Value Do
			TabularSectionDescription = New Structure;
			TabularSectionDescription.Insert("Name", TabularSection.Name);
			TabularSectionDescription.Insert("Synonym", TabularSection.Synonym);
			TabularSectionDescription.Insert("Comment", TabularSection.Comment);

			TabularSectionAttributesCollection = New Structure("Attributes, StandardAttributes");
			FillPropertyValues(TabularSectionAttributesCollection, TabularSection);
			For Each CurrentTabularSectionAttributesCollection In TabularSectionAttributesCollection Do
				If CurrentTabularSectionAttributesCollection.Value = Undefined Then
					Continue;
				EndIf;

				TabularSectionAttributesCollectionDescription = New Structure;

				For Each CurrentAttribute In CurrentTabularSectionAttributesCollection.Value Do
					TabularSectionAttributesCollectionDescription.Insert(CurrentAttribute.Name, MetadataObjectAttributeDescription(
						CurrentAttribute, AllRefsType));
				EndDo;

				TabularSectionDescription.Insert(CurrentTabularSectionAttributesCollection.Key, TabularSectionAttributesCollectionDescription);
			EndDo;
			TabularSectionCollectionDescription.Insert(TabularSection.Name, TabularSectionDescription);
		EndDo;

		ItemDescription.Insert(KeyValue.Key, TabularSectionCollectionDescription);
	EndDo;


	If MetadataObjectHasPredefined(ObjectType) Then

		Predefined = ObjectOfMetadata.GetPredefinedNames();

		PredefinedDescription = New Structure;
		For Each Name In Predefined Do
			PredefinedDescription.Insert(Name, "");
		EndDo;

		ItemDescription.Insert("Predefined", PredefinedDescription);
	EndIf;
	
	Return ItemDescription;
EndFunction

Function ConfigurationMetadataCollectionDescription(Collection, ObjectType, TypesMap, AllRefsType, IncludeAttributesDescription) 
	CollectionDescription = New Structure();

	For Each ObjectOfMetadata In Collection Do
		ItemDescription = ConfigurationMetadataObjectDescription(ObjectOfMetadata, ObjectType, AllRefsType, IncludeAttributesDescription);
			
		CollectionDescription.Insert(ObjectOfMetadata.Name, ItemDescription);
		
		If UT_Common.IsRefTypeObject(ObjectOfMetadata) Then
			TypesMap.Insert(Type(ObjectType+"Ref."+ItemDescription.Name), ItemDescription);
		EndIf;
		
	EndDo;
	
	Return CollectionDescription;
EndFunction

Function ConfigurationCommonModulesDescription() Export
	CollectionDescription = New Structure();

	For Each ObjectOfMetadata In Metadata.CommonModules Do
			
		CollectionDescription.Insert(ObjectOfMetadata.Name, New Structure);
		
	EndDo;
	
	Return CollectionDescription;
EndFunction

Function MetaDataDescriptionForMonacoEditorInitialize() Export
	TypesMap = New Map;
	AllRefsType = UT_Common.AllRefsTypeDescription();

	MetadataDescription = New Structure;
	MetadataDescription.Insert("CommonModules", ConfigurationCommonModulesDescription());
	//	MetadataDescription.Insert("Roles", ConfigurationMetadataCollectionDescription(Metadata.Roles, "Role", TypesMap, AllRefsType));
	//	MetadataDescription.Insert("CommonForms", ConfigurationMetadataCollectionDescription(Metadata.CommonForms, "CommonForm", TypesMap, AllRefsType));

	Return MetadataDescription;	
EndFunction

Function ConfigurationMetadataDescription(IncludeAttributesDescription = True) Export
	AllRefsType = UT_Common.AllRefsTypeDescription();
	
	MetadataDescription = New Structure;
	
	TypesMap = New Map;
	
	MetadataDescription.Insert("Name", Metadata.Name);
	MetadataDescription.Insert("Version", Metadata.Version);
	MetadataDescription.Insert("AllRefsType", AllRefsType);
	
	MetadataDescription.Insert("Catalogs", ConfigurationMetadataCollectionDescription(Metadata.Catalogs, "Catalog", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("Documents", ConfigurationMetadataCollectionDescription(Metadata.Documents, "Document", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("InformationRegisters", ConfigurationMetadataCollectionDescription(Metadata.InformationRegisters, "InformationRegister", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("AccumulationRegisters", ConfigurationMetadataCollectionDescription(Metadata.AccumulationRegisters, "AccumulationRegister", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("AccountingRegisters", ConfigurationMetadataCollectionDescription(Metadata.AccountingRegisters, "AccountingRegister", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("CalculationRegisters", ConfigurationMetadataCollectionDescription(Metadata.CalculationRegisters, "CalculationRegister", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("DataProcessors", ConfigurationMetadataCollectionDescription(Metadata.DataProcessors, "Processing", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("Reports", ConfigurationMetadataCollectionDescription(Metadata.Reports, "Report", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("Enums", ConfigurationMetadataCollectionDescription(Metadata.Enums, "Enum", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("CommonModules", ConfigurationMetadataCollectionDescription(Metadata.CommonModules, "CommonModule", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("ChartsOfAccounts", ConfigurationMetadataCollectionDescription(Metadata.ChartsOfAccounts, "ChartOfAccounts", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("BusinessProcesses", ConfigurationMetadataCollectionDescription(Metadata.BusinessProcesses, "BusinessProcess", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("Tasks", ConfigurationMetadataCollectionDescription(Metadata.Tasks, "Task", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("ChartsOfAccounts", ConfigurationMetadataCollectionDescription(Metadata.ChartsOfAccounts, "ChartOfAccounts", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("ExchangePlans", ConfigurationMetadataCollectionDescription(Metadata.ExchangePlans, "ExchangePlan", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("ChartsOfCharacteristicTypes", ConfigurationMetadataCollectionDescription(Metadata.ChartsOfCharacteristicTypes, "ChartOfCharacteristicTypes", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("ChartsOfCalculationTypes", ConfigurationMetadataCollectionDescription(Metadata.ChartsOfCalculationTypes, "ChartOfCalculationTypes", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("Constants", ConfigurationMetadataCollectionDescription(Metadata.Constants, "Constant", TypesMap, AllRefsType, IncludeAttributesDescription));
	MetadataDescription.Insert("SessionParameters", ConfigurationMetadataCollectionDescription(Metadata.SessionParameters, "SessionParameter", TypesMap, AllRefsType, IncludeAttributesDescription));
	
	MetadataDescription.Insert("ReferenceTypesMap", TypesMap);
	
	Return MetadataDescription;
EndFunction

Function ConfigurationMetadataDescriptionURL() Export
	Description = ConfigurationMetadataDescription();
	
	Return PutToTempStorage(Description, New UUID);
EndFunction

Function MetadataListByType(MetadataType) Export
	MetadataCollection = Metadata[MetadataType];
	
	NamesArray = New Array;
	For Each ObjectOfMetadata In MetadataCollection Do
		NamesArray.Add(ObjectOfMetadata.Name);
	EndDo;
	
	Return NamesArray;
EndFunction

Procedure AddMetadataCollectionToReferenceTypesMap(TypesMap, Collection, ObjectType)
	For Each ObjectOfMetadata In Collection Do
		ItemDescription = New Structure;
		ItemDescription.Insert("Name", ObjectOfMetadata.Name);
		ItemDescription.Insert("ObjectType", ObjectType);
			
		TypesMap.Insert(Type(ObjectType+"Ref."+ObjectOfMetadata.Name), ItemDescription);
	EndDo;
	
EndProcedure

Function ReferenceTypesMap() Export
	Map = New Map;
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.Catalogs, "Catalog");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.Documents, "Document");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.Enums, "Enum");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.ChartsOfAccounts, "ChartOfAccounts");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.BusinessProcesses, "BusinessProcess");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.Tasks, "Task");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.ChartsOfAccounts, "ChartOfAccounts");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.ExchangePlans, "ExchangePlan");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.ChartsOfCharacteristicTypes, "ChartOfCharacteristicTypes");
	AddMetadataCollectionToReferenceTypesMap(Map, Metadata.ChartsOfCalculationTypes, "ChartOfCalculationTypes");

	Return Map;
EndFunction

#EndRegion


#EndRegion

#Region Internal

Function CurrentMonacoEditorParameters() Export
	ParametersFromStorage =  UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "MonacoEditorParameters",
		UT_CodeEditorClientServer.MonacoEditorParametersByDefault());

	ParametersByDefault = UT_CodeEditorClientServer.MonacoEditorParametersByDefault();
	FillPropertyValues(ParametersByDefault, ParametersFromStorage);

	Return ParametersByDefault;
EndFunction

Function AvailableSourceCodeSources() Export
	Array = New ValueList();
	
	Array.Add("MainConfiguration", "Main configuration");
	
	ExtensionsArray = ConfigurationExtensions.Get();
	For Each CurrentExtension In ExtensionsArray Do
		Array.Add(CurrentExtension.Name, CurrentExtension.Synonym);
	EndDo;
	
	Return Array;
EndFunction

#EndRegion

#Region Private

#EndRegion