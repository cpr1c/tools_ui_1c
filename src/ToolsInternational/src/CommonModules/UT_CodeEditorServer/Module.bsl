#Region Public

#Region FormItemsCreate

Procedure FormOnCreateAtServer(Form, EditorType = Undefined) Export
	If EditorType = Undefined Then
		EditorSettings = CodeEditorCurrentSettings();
		EditorType = EditorSettings.Variant;
	EndIf;
	EditorVariants = UT_CodeEditorClientServer.CodeEditorVariants();
	
	IsWindowsClient = False;
	IsWebClient = True;
	
	SessionParametersInStorage = UT_CommonServerCall.CommonSettingsStorageLoad(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(),
		UT_CommonClientServer.SessionParametersSettingsKey());
	If Type(SessionParametersInStorage) = Type("Structure") Then
		If SessionParametersInStorage.Property("HTMLFieldBasedOnWebkit") Then
			If Not SessionParametersInStorage.HTMLFieldBasedOnWebkit Then
				EditorType = EditorVariants.Text;
			EndIf;
		EndIf;
		If SessionParametersInStorage.Property("IsWindowsClient") Then
			IsWindowsClient = SessionParametersInStorage.IsWindowsClient;
		EndIf;
		If SessionParametersInStorage.Property("IsWebClient") Then
			IsWebClient = SessionParametersInStorage.IsWebClient;
		EndIf;
		
	EndIf;
	
	AttributeNameEditorType=UT_CodeEditorClientServer.AttributeNameCodeEditorTypeOfEditor();
	AttributeNameLibraryURL=UT_CodeEditorClientServer.AttributeNameCodeEditorLibraryURL();
	AttributeNameCodeEditorFormCodeEditors = UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors();
	
	AttributesArray=New Array;
	AttributesArray.Add(New FormAttribute(AttributeNameEditorType, New TypeDescription("String", , New StringQualifiers(20,
		AllowedLength.Variable)), "", "", True));
	AttributesArray.Add(New FormAttribute(AttributeNameLibraryURL, New TypeDescription("String", , New StringQualifiers(0,
		AllowedLength.Variable)), "", "", True));
	AttributesArray.Add(New FormAttribute(AttributeNameCodeEditorFormCodeEditors, New TypeDescription, "", "", True));
		
	Form.ChangeAttributes(AttributesArray);
	
	Form[AttributeNameEditorType]=EditorType;
	Form[AttributeNameLibraryURL] = PutLibraryToTempStorage(Form.UUID, IsWindowsClient, IsWebClient, EditorType);
	Form[AttributeNameCodeEditorFormCodeEditors] = New Structure;
EndProcedure

Procedure CreateCodeEditorItems(Form, EditorID, EditorField, EditorLanguage = "bsl") Export
	AttributeNameEditorType=UT_CodeEditorClientServer.AttributeNameCodeEditorTypeOfEditor();
	
	EditorType = Form[AttributeNameEditorType];
	
	EditorData = New Structure;

	If UT_CodeEditorClientServer.CodeEditorUsesHTMLField(EditorType) Then
		If EditorField.Type <> FormFieldType.HTMLDocumentField Then
			EditorField.Type = FormFieldType.HTMLDocumentField;
		EndIf;
		EditorField.SetAction("DocumentComplete", "Подключаемый_ПолеРедактораДокументСформирован");
		EditorField.SetAction("OnClick", "Подключаемый_ПолеРедактораПриНажатии");

		EditorData.Insert("Initialized", False);

	Else
		EditorField.Type = FormFieldType.TextDocumentField;
		EditorData.Insert("Initialized", True);
	EndIf;

	EditorData.Insert("EditorLanguage", EditorLanguage);
	EditorData.Insert("EditorField", EditorField.Name);
	EditorData.Insert("AttributeName", EditorField.DataPath);
	
	EditorVariants = UT_CodeEditorClientServer.CodeEditorVariants();

	EditorSettings = CodeEditorCurrentSettings();
	EditorData.Insert("EditorSettings", EditorSettings);

	If EditorType = EditorVariants.Monaco Then
		For Each KeyValue ИЗ EditorSettings.Monaco Do
			EditorData.EditorSettings.Insert(KeyValue.Key, KeyValue.Value);
		EndDo;
	EndIf;
	
	Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()].Insert(EditorID,  EditorData);	
EndProcedure

#EndRegion

Function PutLibraryToTempStorage(FormID, IsWindowsClient, IsWebClient, EditorType=Undefined) Export
	If EditorType = Undefined Then
		EditorType = CodeEditor1CCurrentVariant();
	EndIf;
	EditorVariants = UT_CodeEditorClientServer.CodeEditorVariants();
	
	If EditorType = EditorVariants.Monaco Then
		If IsWindowsClient Then
			LibraryBinaryData=GetCommonTemplate("UT_MonacoEditorWindows");
		Else
			LibraryBinaryData=GetCommonTemplate("UT_MonacoEditor");
		EndIf;
	ElsIf EditorType = EditorVariants.Ace Then
		LibraryBinaryData=GetCommonTemplate("UT_Ace");
	Else
		Return Undefined;
	EndIf;
	
	LibraryStructure=New Map;

	If Not IsWebClient Then
		LibraryStructure.Insert("editor.zip",LibraryBinaryData);

		Return PutToTempStorage(LibraryStructure, FormID);
	EndIf;
	
	DirectoryAtServer=GetTempFileName();
	CreateDirectory(DirectoryAtServer);

	Stream=LibraryBinaryData.OpenStreamForRead();

	ZipReader=New ZipFileReader(Stream);
	ZipReader.ExtractAll(DirectoryAtServer, ZIPRestoreFilePathsMode.Restore);


	ArchiveFiles=FindFiles(DirectoryAtServer, "*", True);
	For Each LibraryFile In ArchiveFiles Do
		FileKey=StrReplace(LibraryFile.FullName, DirectoryAtServer + GetPathSeparator(), "");
		If LibraryFile.IsDirectory() Then
			Continue;
		EndIf;

		LibraryStructure.Insert(FileKey, New BinaryData(LibraryFile.FullName));
	EndDo;

	LibraryUrl=PutToTempStorage(LibraryStructure, FormID);

	Try
		DeleteFiles(DirectoryAtServer);
	Except
		// TODO:
	EndTry;

	Return LibraryUrl;
EndFunction

#Region ToolsSettings

Function CodeEditor1CCurrentVariant() Export
	CodeEditorSettings = CodeEditorCurrentSettings();
	
	CodeEditor = CodeEditorSettings.Variant;
	
	UT_SessionParameters = UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(),
		UT_CommonClientServer.SessionParametersSettingsKey());
		
	If Type(UT_SessionParameters) = Type("Structure") Then
		If UT_SessionParameters.HTMLFieldBasedOnWebkit<>True Then
			CodeEditor = UT_CodeEditorClientServer.CodeEditorVariants().Text;
		EndIf;
	EndIf;
	
	Return CodeEditor;
EndFunction

Procedure SetCodeEditorNewSettings(NewSettings) Export
	UT_Common.CommonSettingsStorageSave(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "CodeEditorSettings",
		NewSettings);
EndProcedure

Function CodeEditorCurrentSettings() Export
	EditorSavedSettings = UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "CodeEditorSettings");

	DefaultSettings = UT_CodeEditorClientServer.CodeEditorCurrentSettingsByDefault();
	If EditorSavedSettings = Undefined Then		
		MonacoEditorParameters = CurrentMonacoEditorParameters();
		
		FillPropertyValues(DefaultSettings.Monaco, MonacoEditorParameters);
	Else
		FillPropertyValues(DefaultSettings, EditorSavedSettings,,"Monaco");
		FillPropertyValues(DefaultSettings.Monaco, EditorSavedSettings.Monaco);
	EndIf;
	
	Return DefaultSettings;
	
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

Function ConfigurationMetadataDescriptionAdress() Export
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