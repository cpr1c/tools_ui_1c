// Query console 9000 v 1.1.10
// (C) Alexander Kuznetsov 2019-2020
// hal@hal9000.cc
// Minimum platform version 8.3.12, minimum compatibility mode 8.3.8
// Translated by Neti Company

Procedure Initializing(Form = Undefined, cSessionID = Undefined) Export

	DataProcessorVersion = "1.1.10";
	BuildVersion = 1;

	Hashing = New DataHashing(HashFunction.CRC32);
	Hashing.Append(InfoBaseConnectionString());
	IBString = Format(Hashing.HashSum, "NG=0");

	If cSessionID = Undefined Then
		Hashing.Append(UserName());
		SessionID = Hashing.HashSum;
	Else
		SessionID = cSessionID;
	EndIf;

	LockedQueriesExtension = "9000_" + Format(SessionID, "NG=0");

	DataProcessorMetadata = Metadata();

	Try
		UsingDataProcessorFileName = Eval("UsingFileName");

		ExternalDataProcessorMode = True;

		MetadataPath = "ExternalDataProcessor." + DataProcessorMetadata.Name;

		If Mid(UsingDataProcessorFileName, 2, 2) = ":\" Or Left(UsingDataProcessorFileName, 1)
			= "/" Then
			DataProcessorFileName = UsingDataProcessorFileName;
		EndIf;

	Except
		DataProcessorName = DataProcessorMetadata.Name;
		MetadataPath = StrTemplate("DataProcessor.%1", DataProcessorName);
	EndTry;
	
	//Startup info.
	//If ExternalDataProcessorMode = False - run from configuration or extension.
	//
	//If ExternalDataProcessorMode = True, then:
	//	If DataProcessorFileName is not blank - this is external data processor from file, if blank - from binary data.

	If Form <> Undefined Then

		PicturesTemplate = GetTemplate("Pictures");
		stPictures = New Structure;
		For Each Area In PicturesTemplate.Areas Do
			If TypeOf(Area) = Type("SpreadsheetDocumentDrawing") Then
				stPictures.Insert(Area.Name, Area.Picture);
			EndIf;
		EndDo;

		Pictures = PutToTempStorage(stPictures, Form.UUID);

		IBStorageStructure = PutToTempStorage(Undefined, Form.UUID);

	EndIf;

EndProcedure

Function StringToValue(StringValue) Export
	Reader = New XMLReader;
	Reader.SetString(StringValue);
	Return XDTOSerializer.ReadXML(Reader);
EndFunction

Function ValueToString(Value) Export
	Writer = New XMLWriter;
	Writer.SetString();
	XDTOSerializer.WriteXML(Writer, Value);
	Return Writer.Close();
EndFunction

Function GetPictureByType(ValueType, PicturesStructure = Undefined) Export

	PictureName = Undefined;
	If TypeOf(ValueType) = Type("TypeDescription") Then

		arTypes = ValueType.Types();

		PictureName = Undefined;
		For Each Type In arTypes Do
			TypePictureName = GetTypePictureName(Type);
			If PictureName = Undefined Then
				PictureName = TypePictureName;
			ElsIf PictureName <> TypePictureName Then
				PictureName = "Type_Undefined";
				Break;
			EndIf;
		EndDo;

	ElsIf TypeOf(ValueType) = Type("String") Then
		PictureName = GetTypePictureName(ValueType);
	EndIf;

	If PicturesStructure = Undefined Then
		PicturesStructure = GetFromTempStorage(Pictures);
	EndIf;

	If PictureName = Undefined Then
		PictureName = "Type_Undefined";
	EndIf;

	Picture = Undefined;
	PicturesStructure.Property(PictureName, Picture);
	Return Picture;

EndFunction

Function NoEmptyType(TypeDescription) Export

	If TypeOf(TypeDescription) <> Type("TypeDescription") Then
		Return TypeDescription;
	EndIf;

	arEmptyTypes = New Array;
	arEmptyTypes.Add(Type("Null"));
	arEmptyTypes.Add(Type("Undefined"));

	Return New TypeDescription(TypeDescription, , arEmptyTypes);

EndFunction
			
//Value - Type or String - ValueType field content.
Function GetTypePictureName(Value) Export

	If Value = "Value table" Then
		Return "Type_ValueTable";
	ElsIf Value = Type("Array") Then
		Return "Type_Array";
	ElsIf Value = Type("ValueList") Then
		Return "Type_ValueList";
	ElsIf Value = Type("String") Then
		Return "Type_String";
	ElsIf Value = Type("Number") Then
		Return "Type_Number";
	ElsIf Value = Type("Boolean") Then
		Return "Type_Boolean";
	ElsIf Value = Type("Date") Then
		Return "Type_Date";
	ElsIf Value = Type("Boundary") Then
		Return "Type_Boundary";
	ElsIf Value = Type("PointInTime") Then
		Return "Type_PointInTime";
	ElsIf Value = Type("Type") Then
		Return "Type_Type";
	ElsIf Value = Type("UUID") Then
		Return "Type_UUID";
	ElsIf Value = Type("Undefined") Then
		Return "Type_Undefined";
	ElsIf Catalogs.AllRefsType().ContainsType(Value) Then
		Return "Type_CatalogRef";
		;
	ElsIf Documents.AllRefsType().ContainsType(Value) Then
		Return "Type_DocumentRef";
	ElsIf Enums.AllRefsType().ContainsType(Value) Then
		Return "Type_EnumRef";
	ElsIf ChartsOfCharacteristicTypes.AllRefsType().ContainsType(Value) Then
		Return "Type_ChartOfCharacteristicTypesRef";
	ElsIf ChartsOfAccounts.AllRefsType().ContainsType(Value) Then
		Return "Type_ChartOfAccountsRef";
	ElsIf ChartsOfCalculationTypes.AllRefsType().ContainsType(Value) Then
		Return "Type_ChartOfCalculationTypesRef";
	ElsIf BusinessProcesses.AllRefsType().ContainsType(Value) Then
		Return "Type_BusinessProcessRef";
	ElsIf Tasks.AllRefsType().ContainsType(Value) Then
		Return "Type_TaskRef";
	ElsIf ExchangePlans.AllRefsType().ContainsType(Value) Then
		Return "Type_ExchangePlanRef";
	ElsIf Value = Type("Null") Then
		Return "Type_Null";
	ElsIf Value = Type("AccountingRecordType") Then
		Return "Type_AccountingRecordType";
	ElsIf Value = Type("AccumulationRecordType") Then
		Return "Type_AccumulationRecordType";
	ElsIf Value = Type("AccountType") Then
		Return "Type_AccountType";
	Else
		Return "Type_Undefined";
	EndIf;

EndFunction

Function GetTypeName(Value) Export

	ar = New Array;
	ar.Add(Value);
	ValueTypesDescription = New TypeDescription(ar);
	TypeValue = ValueTypesDescription.AdjustValue(Undefined);

	If Value = Type("Undefined") Then
		Return "Undefined";
	ElsIf Catalogs.AllRefsType().ContainsType(Value) Then
		Return "CatalogRef." + TypeValue.Metadata().Name;
	ElsIf Documents.AllRefsType().ContainsType(Value) Then
		Return "DocumentRef." + TypeValue.Metadata().Name;
	ElsIf Enums.AllRefsType().ContainsType(Value) Then
		Return "EnumRef." + TypeValue.Metadata().Name;
	ElsIf ChartsOfCharacteristicTypes.AllRefsType().ContainsType(Value) Then
		Return "ChartOfCharacteristicTypesRef." + TypeValue.Metadata().Name;
	ElsIf ChartsOfAccounts.AllRefsType().ContainsType(Value) Then
		Return "ChartOfAccountsRef." + TypeValue.Metadata().Name;
	ElsIf ChartsOfCalculationTypes.AllRefsType().ContainsType(Value) Then
		Return "ChartOfCalculationTypesRef." + TypeValue.Metadata().Name;
	ElsIf BusinessProcesses.AllRefsType().ContainsType(Value) Then
		Return "BusinessProcessRef." + TypeValue.Metadata().Name;
	ElsIf Tasks.AllRefsType().ContainsType(Value) Then
		Return "TaskRef." + TypeValue.Metadata().Name;
	ElsIf ExchangePlans.AllRefsType().ContainsType(Value) Then
		Return "ExchangePlanRef." + TypeValue.Metadata().Name;
	ElsIf Value = Type("Null") Then
		Return "Null";
	ElsIf Value = Type("AccountingRecordType") Then
		Return "AccountingRecordType";
	ElsIf Value = Type("AccumulationRecordType") Then
		Return "AccumulationRecordType";
	ElsIf Value = Type("AccountType") Then
		Return "AccountType";
	Else
		Return String(Value);
	EndIf;

EndFunction

Function GetTypesUndisplayableAtClient()
	arTypes = New Array;
	arTypes.Add(Type("Type"));
	arTypes.Add(Type("PointInTime"));
	arTypes.Add(Type("Boundary"));
	arTypes.Add(Type("ValueStorage"));
	arTypes.Add(Type("QueryResult"));
	Return arTypes;
EndFunction

Function ValueListFromArray(arArray)
	vlList = New ValueList;
	vlList.LoadValues(arArray);
	Return vlList;
EndFunction

Procedure ChangeValueTableColumnType(vtData, ColumnName, NewColumnType) Export
	TempColumnName = ColumnName + "_Tmp31415926";
	arColumnData = vtData.UnloadColumn(ColumnName);
	vtData.Columns.Add(TempColumnName, NewColumnType);
	vtData.LoadColumn(arColumnData, TempColumnName);
	vtData.Columns.Delete(ColumnName);
	vtData.Columns[TempColumnName].Name = ColumnName;
EndProcedure

//Delets NULL from column types, if no NULL values contains in data
Procedure ValueTable_DeleteNullType(vtTable) Export

	arRemovedTypes = New Array;
	arRemovedTypes.Add(Type("Null"));

	stProcessedColumns = New Structure;
	vtNewTable = New ValueTable;
	For Each Column In vtTable.Columns Do

		If Column.ТипЗначения.СодержитТип(Тип("Null")) Then
			arRowsWithNull = vtTable.FindRows(New Structure(Column.Name, Null));
			If arRowsWithNull.Count() = 0 Then
				stProcessedColumns.Insert(Column.Name);
				vtNewTable.Columns.Add(Column.Name, New TypeDescription(Column.ValueType, ,
					arRemovedTypes));
				Continue;
			EndIf;
		EndIf;

		vtNewTable.Columns.Add(Column.Name, Column.ValueType);

	EndDo;

	If stProcessedColumns.Количество() = 0 Then
		Return;
	EndIf;

	For Each Row In vtTable Do
		FillPropertyValues(vtNewTable.Add(), Row);
	EndDo;

	vtTable = vtNewTable;

EndProcedure

Procedure ProcessMacrocolumns(QueryResultString, selSelection, stMacrocolumns) Export
	For Each kv In stMacrocolumns Do
		If kv.Value.Type = "UUID" Then
			Value = QueryResultString[kv.Value.SourceColumn];
			If ValueIsFilled(Value) Then
				QueryResultString[kv.Key] = Value.UUID();
			EndIf;
		EndIf;
	EndDo;
EndProcedure

#Region RegexpMatchChecking

Function RegTemplate_GetTemplateObject(Template) Export

	Reader = New XMLReader;
	Reader.SetString(
                "<Model xmlns=""http://v8.1c.ru/8.1/xdto"" xmlns:xs=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:type=""Model"">
				|<package targetNamespace=""sample-my-package"">
				|<valueType name=""testtypes"" base=""xs:string"">
				|<pattern>" + Template + "</pattern>
									   |</valueType>
									   |<objectType name=""TestObj"">
									   |<property xmlns:d4p1=""sample-my-package"" name=""TestItem"" type=""d4p1:testtypes""/>
									   |</objectType>
									   |</package>
									   |</Model>");

	Model = XDTOFactory.ReadXML(Reader);
	MyXDTOFactory = New XDTOFactory(Model);
	Package = MyXDTOFactory.Packages.Get("sample-my-package");
	XDTOTemplate = MyXDTOFactory.Create(Package.Get("TestObj"));

	Return XDTOTemplate;

EndFunction

Function RegTemplate_Match(Row, Template) Экспорт

	If TypeOf(Template) = Type("String") Then
		TemplateObject = RegTemplate_GetTemplateObject(Template);
	Else
		TemplateObject = Template;
	EndIf;

	Try
		TemplateObject.TestItem = Row;
		Return True;
	Except
		Return False;
	EndTry;

EndFunction

#EndRegion

#Region TechnologicalLog


Function TechnologicalLog_GetAppConfigurationFolder()
	
	//SystemInfo = New SystemInfo();
	//If Not ((SystemInfo.PlatformType = PlatformType.Windows_x86) Or (SystemInfo.PlatformType = PlatformType.Windows_x86_64)) Then
	//	Return Undefined;
	//EndIf;

	CommonConfigurationFilesFolder = BinDir() + "conf";
	PointerFile = New File(CommonConfigurationFilesFolder + GetServerPathSeparator() + "conf.cfg");
	If PointerFile.Exists() Then
		ConfigurationFile = New TextReader(PointerFile.FullName);
		Line = ConfigurationFile.ReadLine();
		While Line <> Undefined Do
			Position = StrFind(Line, "ConfLocation=");
			If Position > 0 Then
				AppConfigurationFolder = TrimAll(Mid(Line, Position + 13));
				Break;
			EndIf;
			Line = ConfigurationFile.ReadLine();
		EndDo;
	EndIf;

	Return AppConfigurationFolder;

EndFunction

Function TechnologicalLog_ConsoleLabel()
	Return StrTemplate("QueryConsole9000_%1", Format(SessionID, "ЧГ=0"));
EndFunction

Function TechnologicalLog_DOM_TLConfig(Document) Export
	Return Document.FirstChild.NamespaceURI = "http://v8.1c.ru/v8/tech-log"
		And Document.FirstChild.NodeName = "config";
EndFunction

Function TechnologicalLog_RemoveConsloleLogFromDOM(Document) Export

	Label = TechnologicalLog_ConsoleLabel();

	arDeletingNodes = New Array;

	DeletingMode = False;
	For Each Node In Document.FirstChild.ChildNodes Do

		If Node.NodeName = "#comment" And TrimAll(Node.NodeValue) = Label Тогда

			If DeletingMode Then
				arDeletingNodes.Добавить(Node);
				DeletingMode = False;
			Else
				DeletingMode = True;
			EndIf;

		EndIf;

		If DeletingMode Then
			arDeletingNodes.Add(Node);
		EndIf;

	EndDo;

	For Each Node In arDeletingNodes Do
		Document.FirstChild.RemoveChild(Node);
	EndDo;

	Return arDeletingNodes.Count() > 0;

EndFunction

Procedure TechnologicalLog_WriteDOM(Document, FileName) Export

	DOMWriter = New DOMWriter;

	TempFile = FileName + ".tmp";

	XMLWriter = New XMLWriter;
	XMLWriter.OpenFile(TempFile);
	DOMWriter.Write(Document, XMLWriter);
	XMLWriter.Close();

	MoveFile(TempFile, FileName);

EndProcedure

Function TechnologicalLog_ConsoleLogExists() Export

	TLConfigFile = TechnologicalLog_GetAppConfigurationFolder()
		+ GetServerPathSeparator() + "logcfg.xml";
	ConfigFile = New File(TLConfigFile);

	If ConfigFile.Exists() Then

		Document = TechnologicalLog_ReadDOM(TLConfigFile);

		If TechnologicalLog_DOM_TLConfig(Document) Then

			Label = TechnologicalLog_ConsoleLabel();
			LabelExists = False;
			For Each Node In Document.FirstChild.ChildNodes Do

				If LabelExists Then
					LogLocationAttribute = Node.Attributes.GetNamedItem("location");
					If LogLocationAttribute <> Undefined Then
						TechLogFolder = LogLocationAttribute.Value;
						Return True;
					EndIf;
				EndIf;

				Если Node.NodeName = "#comment" And TrimAll(Node.NodeValue) = Label Then
					LabelExists = True;
				EndIf;

			EndDo;

		EndIf;

	EndIf;

	Return False;

EndFunction

Procedure TechnologicalLog_AppendConsoleLog(TLPath) Export

	TLConfigFile = TechnologicalLog_GetAppConfigurationFolder()
		+ GetServerPathSeparator() + "logcfg.xml";
	ConfigFile = New File(TLConfigFile);

	If ConfigFile.Exists() Then

		Document = TechnologicalLog_ReadDOM(TLConfigFile);

		If TechnologicalLog_DOM_TLConfig(Document) Then

			TechnologicalLog_RemoveConsloleLogFromDOM(Document);

			TLConfigTemplate = GetTemplate("TLConfigTemplate");
			Reader = New XMLReader;
			Reader.SetString(StrTemplate(TLConfigTemplate.GetText(), TechnologicalLog_ConsoleLabel(),
				TLPath, UserName()));
			Builder = New DOMBuilder;
			logcfg = Builder.Read(Reader);

			For Each SourceNode In logcfg.FirstChild.ChildNodes Do
				Node = Document.ImportNode(SourceNode, True);
				Document.FirstChild.AppendChild(Node);
			EndDo;

			TechnologicalLog_WriteDOM(Document, TLConfigFile);
			TechLogFolder = TLPath;

		EndIf;

	Else
		Raise NStr("ru = 'logcfg не найден'; en = 'logcfg not found'");
	EndIf;

EndProcedure

Function TechnologicalLog_ReadDOM(FileName) Export
	Reader = New XMLReader;
	Reader.OpenFile(FileName);
	Builder = New DOMBuilder;
	Return Builder.Read(Reader);
EndFunction

Procedure TechnologicalLog_RemoveConsloleLog() Export

	TLConfigFile = TechnologicalLog_GetAppConfigurationFolder()
		+ GetServerPathSeparator() + "logcfg.xml";
	ConfigFile = New File(TLConfigFile);

	If ConfigFile.Exists() Then

		Document = TechnologicalLog_ReadDOM(TLConfigFile);

		If TechnologicalLog_DOM_TLConfig(Document) Then

			TechnologicalLog_RemoveConsloleLogFromDOM(Document);

			TechnologicalLog_WriteDOM(Document, TLConfigFile);

		EndIf;

	EndIf;

EndProcedure

Function ExecuteTestQuery()

	If Not ValueIsFilled(SessionLabel) Then
		SessionLabel = String(New UUID);
	EndIf;

	TestQuery = New Query("SELECT """ + SessionLabel + """");
	TestQuery.Execute(); //6345bb7034de4ad1b14249d2d7ac26dd

EndFunction

Function TechnologicalLog_Enabled() Export

	ExecuteTestQuery();

	arFiles = FindFiles(TechLogFolder, "*.log", True);
	If arFiles.Count() > 0 Then

		For Each LogFile In arFiles Do

			If Find(LogFile.Path, "rphost_") = 0 Then
				Continue;
			EndIf;

			Reader = New DataReader(LogFile.FullName);

			If Reader.SkipTo(SessionLabel) = 0 Then
				TechLogEnabled = True;
				Return True;
			EndIf;

		EndDo;

	EndIf;

	ExecuteTestQuery();

	Return False;

EndFunction

Function TechnologicalLog_Disabled() Export

	Try
		DeleteFiles(TechLogFolder);
	Except
		Return False;
	EndTry;

	TechLogEnabled = False;
	Return True;

EndFunction

Procedure TechnologicalLog_Enable() Export

	TLPath = TempFilesDir() + LockedQueriesExtension;

	j = 1;
	While True Do

		File = New File(TLPath);

		If File.Exists() Then
			Try
				DeleteFiles(File.FullName);
			Except
			EndTry;
		EndIf;

		If Not File.Exists() Then
			Break;
		EndIf;
		
		// Unable to open directory. Probably, technological log is not disabled.
		// Using another directory for start control capability.
		// Current log directory will be cleared at the next "normal" start.
		TLPath = TempFilesDir() + LockedQueriesExtension + j;
		j = j + 1;

	EndDo;

	TechnologicalLog_AppendConsoleLog(TLPath);

	SessionLabel = String(New UUID);
	ExecuteTestQuery();

EndProcedure

Procedure TechnologicalLog_Disable() Export
	TechnologicalLog_RemoveConsloleLog();
EndProcedure

Function TechnologicalLog_GetLogFragmentByIDAndTime(ID, QueryStartTime,
	QueryFinishTime) Export

	arLogs = FindFiles(TechLogFolder, "rphost*");

	arResult = New Array;
	fFragmentIsFound = False;
	For Each Log In arLogs Do

		SearchTime = QueryStartTime;

		While Not fFragmentIsFound And SearchTime < QueryFinishTime Do

			LogFileName = Format(SearchTime, "DF=yyMMddHH.log");
			SearchTime = SearchTime + 60 * 60;
			LogFullFileName = StrTemplate("%1%2%3", Log.FullName, GetServerPathSeparator(), LogFileName);

			File = New File(LogFullFileName);
			If Not File.Exists() Then
				Continue;
			EndIf;

			Reader = New DataReader(LogFullFileName);

			If Not fFragmentIsFound Then
				If Reader.SkipTo(ID + "_start") = 0 Then
					fFragmentIsFound = True;
				EndIf;
			EndIf;

			If fFragmentIsFound Then

				LogReadResult = Reader.ReadTo(ID + "_finish");
				arResult.Add(LogReadResult);

				If LogReadResult.MarkerFound Then
					Break;
				EndIf;

			EndIf;

		EndDo;

		If fFragmentIsFound Then
			Break;
		EndIf;

	EndDo;

	If arResult.Count() = 0 Then
		Return Undefined;
	EndIf;

	arResultLines = New Array;
	For Each ReadResult In arResult Do
		Reader = New TextReader(ReadResult.OpenStreamForRead(), TextEncoding.UTF8);
		arResultLines.Add(Reader.Read());
	EndDo;

	Return StrConcat(arResultLines, "
									|");

EndFunction

Function TechnologicalLog_GetInfoByQuery(ID, QueryStartTime, QueryDuration) Export

	If Not ValueIsFilled(TechLogFolder) Then
		Return Undefined;
	EndIf;

	QueryFinishTime = QueryStartTime + QueryDuration;
	SearchTimeStart = ToLocalTime('00010101' + QueryStartTime / 1000);
	SearchTimeFinish = ToLocalTime('00010101' + QueryFinishTime / 1000 + 1);

	LogFragment = TechnologicalLog_GetLogFragmentByIDAndTime(ID,
		SearchTimeStart, SearchTimeFinish);

	Return LogFragment;

EndFunction

#EndRegion

#Region SavedStates

// Saved states - a structure for storing values not included into options (form flags states, 
// different values, etc.). Written to a file. Reading from the file only at the first opening.
//
Procedure SavedStates_Save(ValueName, Value) Export
	SavedStates.Insert(ValueName, Value);
EndProcedure

Function SavedStates_Get(ValueName, DefaultValue) Export
	Var Value;

	If Not SavedStates.Property(ValueName, Value) Then
		Return DefaultValue;
	EndIf;

	Return Value;

EndFunction

#EndRegion

#Region ValueTableInterface

// Recreates type description.
// 
// Type description contains more than available from 1C:Enterprise language.
// For example, it can contain info received from query fields defined types.
// It can cause incorrect work.
//
Function NormalizeType(SomeTypeDescription)

	Types = SomeTypeDescription.Types();
	NewTypeDescription = New TypeDescription(Types, SomeTypeDescription.NumberQualifiers,
		SomeTypeDescription.StringQualifiers, SomeTypeDescription.DateQualifiers);

	Return NewTypeDescription;

EndFunction

Procedure CreateTableAttributesByColumns(Form, FormTableAttributeName, ColumnMapAttributeName,
	ContainerColumnAttributeName, Columns, fForEditing = False, stMacrocolumns = Undefined) Export

	arUndisplayableTypes = GetTypesUndisplayableAtClient();

	FormTableAttributeNameTotals = FormTableAttributeName + "Totals";
	TotalsExists = False;
	For Each Attribute In Form.ПолучитьРеквизиты() Do
		If Attribute.Name = FormTableAttributeNameTotals Then
			TotalsExists = True;
			Break;
		EndIf;
	EndDo;

	arAttributesToDelete = New Array;

	If TypeOf(Form[FormTableAttributeName]) = Type("FormDataCollection") Then
		Form[FormTableAttributeName].Clear();
	EndIf;

	For Each Attribute In Form.GetAttributes(FormTableAttributeName) Do
		arAttributesToDelete.Add(Attribute.Path + "." + Attribute.Name);
	EndDo;

	If TotalsExists Then
		Form[FormTableAttributeNameTotals].Clear();
		For Each Attribute In Form.GetAttributes(FormTableAttributeNameTotals) Do
			arAttributesToDelete.Add(Attribute.Path + "." + Attribute.Name);
		EndDo;
	EndIf;

	stContainerColumns = New Structure;
	arAttributesToAdd = New Array;
	If Columns <> Undefined Then

		For Each Column In Columns Do

			stMacrocolumn = Undefined;
			If stMacrocolumns <> Undefined And stMacrocolumns.Property(Column.Name, stMacrocolumn) Then
				ColumnType = stMacrocolumn.ValueType;
			Else
				ColumnType = Column.ValueType;
			EndIf;

			UndisplayableTypesExists = False;
			For Each UndisplayableType In arUndisplayableTypes Do
				If ColumnType.ContainsType(UndisplayableType) Then
					UndisplayableTypesExists = True;
					Break;
				EndIf;
			EndDo;

			If UndisplayableTypesExists Then

				ContainerColumnName = Column.Name + ContainerAttributeSuffix();
				Attribute = New FormAttribute(ContainerColumnName, New TypeDescription, FormTableAttributeName,
					ContainerColumnName);
				arAttributesToAdd.Add(Attribute);
				stContainerColumns.Insert(Column.Name, ColumnType);

				TableColumnType = New TypeDescription(ColumnType, "String", arUndisplayableTypes);

			Else
				TableColumnType = NormalizeType(ColumnType);
			EndIf;

			If TableColumnType.ContainsType(Type("Number")) Then
				TotalsColumnType = New TypeDescription("Number", TableColumnType.NumberQualifiers);
			Else
				TotalsColumnType = New TypeDescription("Null");
			EndIf;

			Attribute = New FormAttribute(Column.Name, TableColumnType, FormTableAttributeName, Column.Name);
			arAttributesToAdd.Add(Attribute);

			If TotalsExists Then
				Attribute = New FormAttribute(Column.Name, TotalsColumnType, FormTableAttributeNameTotals,
					Column.Name);
				arAttributesToAdd.Add(Attribute);
			EndIf;

		EndDo;

	EndIf;

	Form.ChangeAttributes(arAttributesToAdd, arAttributesToDelete);

	If TotalsExists Then
		Form[FormTableAttributeNameTotals].Add();
	EndIf;

	While Form.Items[FormTableAttributeName].ChildItems.Count() > 0 Do
		Form.Items.Delete(Form.Items[FormTableAttributeName].ChildItems[0]);
	EndDo;

	stResultColumns = New Structure;
	If Columns <> Undefined Then

		For Each Column In Columns Do

			ColumnName = FormTableAttributeName + Column.Name;
			stResultColumns.Insert(ColumnName, Column.Name);
			TableColumn = Form.Items.Add(ColumnName, Type("FormField"),
				Form.Items[FormTableAttributeName]);
			TableColumn.DataPath = FormTableAttributeName + "." + Column.Name;

			If TotalsExists Then
				TableColumn.FooterDataPath = FormTableAttributeNameTotals + "[0]." + Column.Name;
			EndIf;

			If fForEditing Then

				TableColumn.Type = FormFieldType.InputField;
				TableColumn.EditMode = ColumnEditMode.Directly;
				TableColumn.ClearButton = True;

				If stContainerColumns.Property(Column.Name) Then
					TableColumn.ChoiceButton = True;
					TableColumn.TextEdit = False;
					TableColumn.SetAction("StartChoice", "TableFieldStartChoice");
				EndIf;

			EndIf;

		EndDo;

	EndIf;

	Form[ColumnMapAttributeName] = stResultColumns;
	Form[ContainerColumnAttributeName] = stContainerColumns;

EndProcedure

Procedure InitializeRowContainersByTypes(TableRow, ContainerColumnValueTable) Export

	For Each kv In ContainerColumnValueTable Do

		ColumnName = kv.Key;
		ValueType = kv.Value;
		arValueTypes = ValueType.Types();

		Container = Undefined;
		If arValueTypes.Count() = 1 Then

			If ValueType.ContainsType(Type("Type")) Then
				Container = Container_SaveValue(Type("Undefined"));
			ElsIf ValueType.ContainsType(Type("PointInTime")) Then
				Container = Container_SaveValue(New PointInTime('00010101', Undefined));
			EndIf;

		EndIf;

		If Not ValueIsFilled(Container) Then
			Container = EmptyContainer();
		EndIf;

		TableRow[ColumnName + ContainerAttributeSuffix()] = Container;

	EndDo;

EndProcedure

Function EmptyContainer()
	Return New Structure("Type, Presentation", , "???");
EndFunction

// Adds an empty container, if the value stores in the main field
// 
Procedure AddContainers(AttributeValueTableRow, SourceRow, ContainerColumns) Export

	For Each kv In ContainerColumns Do

		ColumnName = kv.Key;
		ContainerColumnName = ColumnName + ContainerAttributeSuffix();

		If TypeOf(SourceRow[ColumnName]) = Type("QueryResult") Then
			Container = Container_SaveValue(SourceRow[kv.Key].Unload());
		Else
			Container = Container_SaveValue(SourceRow[kv.Key]);
		EndIf;

		If TypeOf(Container) <> Type("Structure") Then
			Container = EmptyContainer();
		Else
			AttributeValueTableRow[ColumnName] = Container.Presentation;
		EndIf;

		AttributeValueTableRow[ContainerColumnName] = Container;

	EndDo;

EndProcedure

Function TableToFormAttribute(ValueTable, ValueTableAttribute, ValueTableContainerColumnsAttribute) Export

	fContainersExists = ValueTableContainerColumnsAttribute.Count() > 0;
	If Not fContainersExists Then
		ValueTableAttribute.Load(ValueTable);
	Else

		For Each Row In ValueTable Do
			AttributeValueTableRow = ValueTableAttribute.Add();
			FillPropertyValues(AttributeValueTableRow, Row);
			If fContainersExists Then
				AddContainers(AttributeValueTableRow, Row, ValueTableContainerColumnsAttribute);
			EndIf;
		EndDo;

	EndIf;

EndFunction

Function TableFromFormAttributes(ValueTableAttribute, ValueTableContainerColumnsAttribute) Export

	vtData = ValueTableAttribute.Unload();

	If ValueTableContainerColumnsAttribute.Count() = 0 Then
		Return Container_SaveValue(vtData);
	EndIf;

	stContainersColumnNames = New Structure;
	For Each kv In ValueTableContainerColumnsAttribute Do
		stContainersColumnNames.Insert(kv.Key + ContainerAttributeSuffix());
	EndDo;

	vtReturningTable = New ValueTable;
	For Each Column In vtData.Columns Do

		If stContainersColumnNames.Property(Column.Name) Then
			Continue;
		EndIf;

		ColumnType = Column.ValueType;
		ValueTableContainerColumnsAttribute.Property(Column.Name, ColumnType);
		vtReturningTable.Columns.Add(Column.Name, ColumnType);
		
	EndDo
	;

	nRowCount = vtData.Count();
	For Each AttributeValueTableRow In ValueTableAttribute Do
		Row = vtReturningTable.Add();
		FillPropertyValues(Row, AttributeValueTableRow);
		For Each kv In ValueTableContainerColumnsAttribute Do
			ColumnName = kv.Key;
			Row[ColumnName] = Container_RestoreValue(AttributeValueTableRow[ColumnName
				+ ContainerAttributeSuffix()]);
		EndDo;
	EndDo;

	Return Container_SaveValue(vtReturningTable);

EndFunction

#EndRegion

#Region Container

//Value table can be as a table, or can be serialized into container structure.
//There are different containers for parameters and for tables.
//For parameter container can contain a value, or a structure for array, value list or dedicated type).
//For table - always structure for dedicated type.
//
Function ContainerAttributeSuffix() Export
	Return "_31415926Container";
EndFunction

Function Container_Clear(Container) Export

	If Container.Type = "ValueTable" Then
		Value = Container_RestoreValue(Container);
		Value.Clear();
	ElsIf Container.Type = "ValueList" Then
		Value = Container_RestoreValue(Container);
		Value.Clear();
	ElsIf Container.Type = "Array" Then
		Value = New Array;
	ElsIf Container.Type = "Type" Then
		Value = Type("Undefined");
	ElsIf Container.Type = "Boundary" Then
		Value = New Boundary(, BoundaryType.Including);
	ElsIf Container.Type = "PointInTime" Then
		Value = New PointInTime('00010101');
	ElsIf Container.Type = "ValueStorage" Then
		Value = New ValueStorage(Undefined);
	Else
		Raise NStr("ru = 'Неизвестный тип контейнера'; en = 'Unknown container type'");
	EndIf;

	Container_SaveValue(Value);

EndFunction

Function Container_SaveValue(Value) Export

	ValueType = TypeOf(Value);
	If ValueType = TypeOf("Boundary") Then
		Result = New Structure("Type, BoundaryType, Value, Presentation", "Boundary");
		FillPropertyValues(Result, Value);
		Result.BoundaryType = String(Result.BoundaryType);
		Result.Presentation = Container_GetPresentation(Result);
	ElsIf ValueType = TypeOf("PointInTime") Then
		Result = New Structure("Type, Date, Ref, Presentation", "PointInTime");
		FillPropertyValues(Result, Value);
		Result.Presentation = Container_GetPresentation(Result);
	ElsIf ValueType = TypeOf("Type") Then
		Result = New Structure("Type, TypeName, Presentation", "Type", GetTypeName(Value));
		Result.Presentation = Container_GetPresentation(Result);
	ElsIf ValueType = TypeOf("ValueStorage") Then
		Result = New Structure("Type, Storage, Presentation", "ValueStorage", ValueToString(Value));
		Result.Presentation = Container_GetPresentation(Result);
	ElsIf ValueType = TypeOf("Array") Then
		Result = New Structure("Type, ValueList, Presentation", "Array", ValueListFromArray(Value));
		Result.Presentation = Container_GetPresentation(Result);
	ElsIf ValueType = TypeOf("ValueList") Then
		Result = New Structure("Type, ValueList, Presentation", "ValueList", Value);
		Result.Presentation = Container_GetPresentation(Result);
	ElsIf ValueType = TypeOf("ValueTable") Then
		Result = New Structure("Type, RowCount, Value, Presentation", "ValueTable",
			Value.Count(), ValueToString(Value));
		Result.Presentation = Container_GetPresentation(Result);
	Else
		Result = Value;
	EndIf;

	Return Result;

EndFunction

Function Container_RestoreValue(SavedValue) Export

	If TypeOf(SavedValue) = Type("Structure") Then
		If SavedValue.Type = "Boundary" Then
			Result = New Boundary(SavedValue.Value, BoundaryType[SavedValue.BoundaryType]);
		ElsIf SavedValue.Type = "PointInTime" Then
			Result = New PointInTime(SavedValue.Date, SavedValue.Ref);
		ElsIf SavedValue.Type = "PointInTime" Then
			Result = SavedValue.UUID;
		ElsIf SavedValue.Type = "Type" Then
			Result = Type(SavedValue.TypeName);
		ElsIf SavedValue.Type = "ValueList" Then
			Result = SavedValue.ValueList;
		ElsIf SavedValue.Type = "Array" Then
			Result = SavedValue.ValueList.UnloadValues();
		ElsIf SavedValue.Type = "ValueTable" Then
			Result = StringToValue(SavedValue.Value);
		EndIf;
	Else
		Result = SavedValue;
	EndIf;

	Return Result;

EndFunction

Function Container_GetPresentation(Container) Export

	nPresentationSize = 200;

	If TypeOf(Container) = Type("Structure") Then
		If Container.Type = "Boundary" Then
			Return String(Container.Value) + " " + Container.BoundaryType;
		ElsIf Container.Type = "Array" Then
			Return Left(StrConcat(Container.ValueList.UnloadValues(), "; "), nPresentationSize);
		ElsIf Container.Type = "ValueList" Then
			Return Left(StrConcat(Container.ValueList.UnloadValues(), "; "), nPresentationSize);
		ElsIf Container.Type = "ValueTable" Then
			RowCount = Undefined;
			If Container.Property("RowCount", RowCount) Then
				Return NStr("ru = 'строк'; en = '<rows: '") + RowCount + ">";
			Else
				Return NStr("ru = '<строк: ?>'; en = '<rows: ?>'");
			EndIf;
		ElsIf Container.Type = "PointInTime" Then
			Return String(Container.Date) + "; " + Container.Ref;
		ElsIf Container.Type = "Type" Then
			Return "Type: " + Type(Container.TypeName);
		ElsIf Container.Type = "ValueStorage" Then
			Return "<ValueStorage>";
		EndIf;
	Else
		Return "???";
	EndIf;

EndFunction

#EndRegion

Function SaveQuery(SessionID, Query) Export

	If TypeOf(SessionID) <> Type("Number") Then
		Return NStr("ru = '!Не верный тип параметра 1: '; en = '!Incorrect parameter #1 type: '") + TypeOf(SessionID) + NStr("ru = '. Должен быть тип ""Число""'; en = '. Type must be ""Number""'");
	EndIf;

	If TypeOf(Query) <> Type("Query") Then
		Return NStr("ru = '!Не верный тип параметра 2: '; en = '!Incorrect parameter #2 type: '") + TypeOf(Query) + NStr("ru = '. Должен быть тип ""Запрос""'; en = '. Type must be ""Query""'");
	EndIf;

	Initializing( , SessionID);

	FileName = GetTempFileName(LockedQueriesExtension);

	TempTables = New Array;

	If Query.TempTablesManager <> Undefined Then
		For Each Table In Query.TempTablesManager.Tables Do

			TempTable = New ValueTable;
			For Each Column In Table.Columns Do
				TempTable.Columns.Add(Column.name, Column.ValueType);
			EndDo;

			selTable = Table.GetData().Select();
			While selTable.Next() Do
				FillPropertyValues(TempTable.Add(), selTable);
			EndDo;

			TempTables.Add(
				New Structure("Name, Table", Table.FullName, TempTable));
		EndDo;
	EndIf;

	Structure = New Structure("Text, Parameters, TempTables", , , TempTables);
	FillPropertyValues(Structure, Query);
	XMLWriter = New XMLWriter;
	XMLWriter.OpenFile(FileName);
	XDTOSerializer.WriteXML(XMLWriter, Structure, XMLTypeAssignment.Explicit);

	XMLWriter.Close();

	Return "ОК:";// + FileName;

EndFunction

//&AtServerNoContext
Function ExecuteCode(ThisCode, Selection, Parameters, ProgressSign)
	Execute (ThisCode);
EndFunction

// Displays progress.
// Parameters:
//	Processed - Number - count of records processed.
//	CountTotal - Number - total count of records.
//	StartDateInMilliseconds - Number - processing start date received from CurrentUniversalDateInMilliseconds(). 
//		It is needed to calculate the remaining time.
//	ProgressSign - String - special value to send progress values to client.
//
Function MessageProgress(Processed, CountTotal, StartDateInMilliseconds, ProgressSign)
	DateInMilliseconds = CurrentUniversalDateInMilliseconds();
	Message(ProgressSign + ValueToString(New Structure("Progress, DurationAtProgressMoment", Processed
		* 100 / CountTotal, DateInMilliseconds - StartDateInMilliseconds)));
	Return DateInMilliseconds;
EndFunction

Procedure ExecuteUserAlgorithm(ExecutionParameters, ResultAddress) Export

	stQueryResult = ExecutionParameters[0];
	arQueryResult = stQueryResult.Result;
	QueryParameters = stQueryResult.Parameters;
	ResultInBatch = ExecutionParameters[1];
	Code = ExecutionParameters[2];
	FlagLineByLine = ExecutionParameters[3];
	AlgorithmExecutionRefreshInterval = ExecutionParameters[4];

	stResult = arQueryResult[Number(ResultInBatch) - 1];
	qrSelection = stResult.Result;
	Selection = qrSelection.Select();
	StartDateInMilliseconds = CurrentUniversalDateInMilliseconds();

	If FlagLineByLine Then

		CountTotal = Selection.Count();
		nPortionFinishMoment = 0;
		j = 0;
		While Selection.Next() Do

			ExecuteCode(Code, Selection, QueryParameters, ResultAddress);

			j = j + 1;
			If CurrentUniversalDateInMilliseconds() >= nPortionFinishMoment Then
				// Using ResultAddress as state message label, because this is the unique value.
				DateInMilliseconds = MessageProgress(j, CountTotal, StartDateInMilliseconds, ResultAddress);
				nPortionFinishMoment = DateInMilliseconds + AlgorithmExecutionRefreshInterval;
			EndIf;

		EndDo;

	Else
		ExecuteCode(Code, Selection, QueryParameters, ResultAddress);
	EndIf;

EndProcedure

#Region QueryPlan

Function StoringStructure()

	vtStructure = GetFromTempStorage(IBStorageStructure);

	If vtStructure = Undefined Then
		vtStructure = GetDBStorageStructureInfo( , True);
		vtStructure.Indexes.Add("Metadata");
		PutToTempStorage(vtStructure, IBStorageStructure);
	EndIf;

	Return vtStructure;

EndFunction

Procedure SQLQueryTo1CTerms_AddTerm(TermsData, IBName, Name1С)
	If Not IsBlankString(Name1С) Then
		TermsDataRow = TermsData.Add();
		TermsDataRow.IBName = IBName;
		TermsDataRow.Name1С = Name1С;
		TermsDataRow.IBNameLength = StrLen(TermsDataRow.IBName);
	EndIf;
EndProcedure

Function SQLQueryTo1CTerms(SQLQueryText, TermsData = Undefined) Export

	vtStructure = StoringStructure();

	If TermsData = Undefined Then

		StringType = New TypeDescription("Строка");
		TermsData = New ValueTable;
		TermsData.Columns.Add("IBName", StringType);
		TermsData.Columns.Add("Name1С", StringType);
		TermsData.Columns.Add("IBNameLength", New TypeDescription("Number"));

		For Each Row In vtStructure Do

			j = Find(SQLQueryText, Row.StorageTableName);
			If j > 0 Then

				SQLQueryTo1CTerms_AddTerm(TermsData, Row.StorageTableName, Row.TableName);

				For Each FieldRow In Row.Fields Do
					SQLQueryTo1CTerms_AddTerm(TermsData, FieldRow.StorageFieldName, FieldRow.FieldName);
				EndDo;

			EndIf;

		EndDo;

		TermsData.Sort("IBNameLength Desc");

	EndIf;

	QueryTextIn1CTerms = SQLQueryText;

	For Each Row In TermsData Do
		QueryTextIn1CTerms = StrReplace(QueryTextIn1CTerms, Row.IBName, Row.Name1С);
	EndDo;

	Return QueryTextIn1CTerms;

EndFunction

//	TermsRegister - Terms register conversion:
//		0 - do not convert terms data,
//		1 - convert terms data to lower register (for POSTGRS)
//
Function SQLPlanTo1CTerms(QueryPlan, TermsData, TermsRegister = 0) Export

	QueryPlanIn1CTerms = QueryPlan;

	If TermsRegister = 1 Then
		For Each Row In TermsData Do
			QueryPlanIn1CTerms = StrReplace(QueryPlanIn1CTerms, Lower(Row.IBName), Row.Name1C);
		EndDo;
	Else
		For Each Row In TermsData Do
			QueryPlanIn1CTerms = StrReplace(QueryPlanIn1CTerms, Row.IBName, Row.Name1C);
		EndDo;
	EndIf;

	Return QueryPlanIn1CTerms;

EndFunction

#EndRegion

#Region ExternalDataProcessorInfo

Function ExternalDataProcessorInfo() Export

	Initializing();

	RegistrationParameters = New Structure;
	RegistrationParameters.Insert("Kind", "AdditionalDataProcessor");
	RegistrationParameters.Insert("Description", NStr("ru = 'Консоль запросов 9000'; en = 'Query console 9000'"));
	RegistrationParameters.Insert("Version", DataProcessorVersion + "." + BuildVersion);
	RegistrationParameters.Insert("SafeMode", False);
	RegistrationParameters.Insert("Information", NStr("ru = 'Консоль запросов 9000'; en = 'Query console 9000'"));

	CommandTable = GetCommandTable();

	AddCommand(CommandTable, NStr("ru = 'Консоль запросов 9000'; en = 'Query console 9000'"), NStr("ru = 'КонсольЗапросов9000'; en = 'QueryConsole9000'"), "OpeningForm", True);

	RegistrationParameters.Insert("Commands", CommandTable);

	Return RegistrationParameters;

EndFunction

Function GetCommandTable()

	Commands = New ValueTable;
	Commands.Coluumns.Add("Presentation", New TypeDescription("String"));
	Commands.Coluumns.Add("ID", New TypeDescription("String"));
	Commands.Coluumns.Add("StartupOption", New TypeDescription("String"));
	Commands.Coluumns.Add("ShowNotification", New TypeDescription("Boolean"));
	Commands.Coluumns.Add("Modificator", New TypeDescription("String"));

	Return Commands;

EndFunction

Procedure AddCommand(CommandTable, Presentation, ID, StartupOption, ShowNotification = False,
	Modificator = "")
	NewCommand = CommandTable.Add();
	NewCommand.Presentation = Presentation;
	NewCommand.ID = ID;
	NewCommand.StartupOption = StartupOption;
	NewCommand.ShowNotification = ShowNotification;
	NewCommand.Modificator = Modificator;
EndProcedure

#EndRegion

#Region UT

Function DataProcessorIsPartOfUniversalTools() Export
	Return Metadata().Name = NStr("ru = 'УИ_КонсольЗапросов'; en = 'UT_QueryConsole'");
EndFunction

#EndRegion