// Query console 9000 v 1.1.10
// (C) Alexander Kuznetsov 2019-2020
// hal@hal9000.cc
//Minimum platform version 8.3.12, minimum compatibility mode 8.3.8
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
		Raise NSTR("ru = 'logcfg не найден'; en = 'logcfg not found'");
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
		
		//Unable to open directory. Probably, technological log is not disabled.
		//Using another directory for start control possibility.
		//Current log directory will be cleared at the next "normal" start.
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

Function TechnologicalLog_GetLogFragmentByIDAndTime(ID, QueryBeginTime,
	QueryEndTime) Export

	arLogs = FindFiles(TechLogFolder, "rphost*");

	arResult = New Array;
	fFragmentIsFound = False;
	For Each Log In arLogs Do

		SearchTime = QueryBeginTime;

		While Not fFragmentIsFound And SearchTime < QueryEndTime Do

			LogFileName = Format(SearchTime, "DF=yyMMddHH.log");
			SearchTime = SearchTime + 60 * 60;
			LogFullFileName = StrTemplate("%1%2%3", Log.FullName, GetServerPathSeparator(), LogFileName);

			File = New File(LogFullFileName);
			If Not File.Exists() Then
				Continue;
			EndIf;

			Reader = New DataReader(LogFullFileName);

			If Not fFragmentIsFound Then
				If Reader.SkipTo(ID + "_begin") = 0 Then
					fFragmentIsFound = True;
				EndIf;
			EndIf;

			If fFragmentIsFound Then

				LogReadResult = Reader.ReadTo(ID + "_end");
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

Function TechnologicalLog_GetInfoByQuery(ID, QueryBeginTime, QueryDuration) Export

	If Not ValueIsFilled(TechLogFolder) Then
		Return Undefined;
	EndIf;

	QueryEndTime = QueryBeginTime + QueryDuration;
	SearchTimeBegin = ToLocalTime('00010101' + QueryBeginTime / 1000);
	SearchTimeEnd = ToLocalTime('00010101' + QueryEndTime / 1000 + 1);

	LogFragment = TechnologicalLog_GetLogFragmentByIDAndTime(ID,
		SearchTimeBegin, SearchTimeEnd);

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

Function ТаблицаИзРеквизитовФормы(ТаблицаЗначенийРеквизит, ТаблицаЗначенийКолонкиКонтейнераРеквизит) Экспорт

	тзДанные = ТаблицаЗначенийРеквизит.Выгрузить();

	Если ТаблицаЗначенийКолонкиКонтейнераРеквизит.Количество() = 0 Тогда
		Возврат Container_SaveValue(тзДанные);
	EndIf;

	стИменаКолонокКонтейнеров = Новый Структура;
	Для Каждого кз Из ТаблицаЗначенийКолонкиКонтейнераРеквизит Цикл
		стИменаКолонокКонтейнеров.Вставить(кз.Ключ + ContainerAttributeSuffix());
	EndDo;

	тзВозвращаемаяТаблица = Новый ТаблицаЗначений;
	Для Каждого Колонка Из тзДанные.Колонки Цикл

		Если стИменаКолонокКонтейнеров.Свойство(Колонка.Имя) Тогда
			Продолжить;
		EndIf;

		ТипКолонки = Колонка.ТипЗначения;
		ТаблицаЗначенийКолонкиКонтейнераРеквизит.Свойство(Колонка.Имя, ТипКолонки);
		тзВозвращаемаяТаблица.Колонки.Добавить(Колонка.Имя, ТипКолонки);
		
	EndDo
	;

	чКоличествоСтрок = тзДанные.Количество();
	Для Каждого СтрокаТаблицыЗначенийРеквизита Из ТаблицаЗначенийРеквизит Цикл
		Строка = тзВозвращаемаяТаблица.Добавить();
		ЗаполнитьЗначенияСвойств(Строка, СтрокаТаблицыЗначенийРеквизита);
		Для Каждого кз Из ТаблицаЗначенийКолонкиКонтейнераРеквизит Цикл
			ИмяКолонки = кз.Ключ;
			Строка[ИмяКолонки] = Контейнер_ВосстановитьЗначение(СтрокаТаблицыЗначенийРеквизита[ИмяКолонки
				+ ContainerAttributeSuffix()]);
		EndDo;
	EndDo;

	Возврат Container_SaveValue(тзВозвращаемаяТаблица);

EndFunction

#EndRegion

#Region Контейнер

//Таблица значений может быть как есть, либо уже сериализованная и положенная в структуру-контейнер.
//Контейнер для параметров и для таблиц имеет немного разное значение.
//Для параметра: там может лежать либо само значение, либо структура для списка значений, массива или специального типа.
//Для таблицы: всегда структура для специального типа.

Function ContainerAttributeSuffix() Экспорт
	Возврат "_31415926Контейнер";
EndFunction

Function Контейнер_Очистить(Контейнер) Экспорт

	Если Контейнер.Тип = "ТаблицаЗначений" Тогда
		Значение = Контейнер_ВосстановитьЗначение(Контейнер);
		Значение.Очистить();
	ИначеЕсли Контейнер.Тип = "СписокЗначений" Тогда
		Значение = Контейнер_ВосстановитьЗначение(Контейнер);
		Значение.Очистить();
	ИначеЕсли Контейнер.Тип = "Массив" Тогда
		Значение = Новый Массив;
	ИначеЕсли Контейнер.Тип = "Тип" Тогда
		Значение = Тип("Неопределено");
	ИначеЕсли Контейнер.Тип = "Граница" Тогда
		Значение = Новый Граница(, ВидГраницы.Включая);
	ИначеЕсли Контейнер.Тип = "МоментВремени" Тогда
		Значение = Новый МоментВремени('00010101');
	ИначеЕсли Контейнер.Тип = "ХранилищеЗначения" Тогда
		Значение = Новый ХранилищеЗначения(Неопределено);
	Иначе
		ВызватьИсключение "Неизвестный тип контейнера";
	EndIf;

	Container_SaveValue(Значение);

EndFunction

Function Container_SaveValue(Значение) Export

	ТипЗначения = ТипЗнч(Значение);
	Если ТипЗначения = Тип("Граница") Тогда
		Результат = Новый Структура("Тип, ВидГраницы, Значение, Представление", "Граница");
		ЗаполнитьЗначенияСвойств(Результат, Значение);
		Результат.ВидГраницы = Строка(Результат.ВидГраницы);
		Результат.Представление = Контейнер_ПолучитьПредставление(Результат);
	ИначеЕсли ТипЗначения = Тип("МоментВремени") Тогда
		Результат = Новый Структура("Тип, Дата, Ссылка, Представление", "МоментВремени");
		ЗаполнитьЗначенияСвойств(Результат, Значение);
		Результат.Представление = Контейнер_ПолучитьПредставление(Результат);
	ИначеЕсли ТипЗначения = Тип("Тип") Тогда
		Результат = Новый Структура("Тип, ИмяТипа, Представление", "Тип", GetTypeName(Значение));
		Результат.Представление = Контейнер_ПолучитьПредставление(Результат);
	ИначеЕсли ТипЗначения = Тип("ХранилищеЗначения") Тогда
		Результат = Новый Структура("Тип, Хранилище, Представление", "ХранилищеЗначения", ValueToString(Значение));
		Результат.Представление = Контейнер_ПолучитьПредставление(Результат);
	ИначеЕсли ТипЗначения = Тип("Массив") Тогда
		Результат = Новый Структура("Тип, СписокЗначений, Представление", "Массив", ValueListFromArray(Значение));
		Результат.Представление = Контейнер_ПолучитьПредставление(Результат);
	ИначеЕсли ТипЗначения = Тип("СписокЗначений") Тогда
		Результат = Новый Структура("Тип, СписокЗначений, Представление", "СписокЗначений", Значение);
		Результат.Представление = Контейнер_ПолучитьПредставление(Результат);
	ИначеЕсли ТипЗначения = Тип("ТаблицаЗначений") Тогда
		Результат = Новый Структура("Тип, КоличествоСтрок, Значение, Представление", "ТаблицаЗначений",
			Значение.Количество(), ValueToString(Значение));
		Результат.Представление = Контейнер_ПолучитьПредставление(Результат);
	Иначе
		Результат = Значение;
	EndIf;

	Возврат Результат;

EndFunction

Function Контейнер_ВосстановитьЗначение(СохраненноеЗначение) Экспорт

	Если ТипЗнч(СохраненноеЗначение) = Тип("Структура") Тогда
		Если СохраненноеЗначение.Тип = "Граница" Тогда
			Результат = Новый Граница(СохраненноеЗначение.Значение, ВидГраницы[СохраненноеЗначение.ВидГраницы]);
		ИначеЕсли СохраненноеЗначение.Тип = "МоментВремени" Тогда
			Результат = Новый МоментВремени(СохраненноеЗначение.Дата, СохраненноеЗначение.Ссылка);
		ИначеЕсли СохраненноеЗначение.Тип = "МоментВремени" Тогда
			Результат = СохраненноеЗначение.УникальныйИдентификатор;
		ИначеЕсли СохраненноеЗначение.Тип = "Тип" Тогда
			Результат = Тип(СохраненноеЗначение.ИмяТипа);
		ИначеЕсли СохраненноеЗначение.Тип = "СписокЗначений" Тогда
			Результат = СохраненноеЗначение.СписокЗначений;
		ИначеЕсли СохраненноеЗначение.Тип = "Массив" Тогда
			Результат = СохраненноеЗначение.СписокЗначений.ВыгрузитьЗначения();
		ИначеЕсли СохраненноеЗначение.Тип = "ТаблицаЗначений" Тогда
			Результат = StringToValue(СохраненноеЗначение.Значение);
		EndIf;
	Иначе
		Результат = СохраненноеЗначение;
	EndIf;

	Возврат Результат;

EndFunction

Function Контейнер_ПолучитьПредставление(Контейнер) Экспорт

	чРазмерПредставления = 200;

	Если ТипЗнч(Контейнер) = Тип("Структура") Тогда
		Если Контейнер.Тип = "Граница" Тогда
			Возврат Строка(Контейнер.Значение) + " " + Контейнер.ВидГраницы;
		ИначеЕсли Контейнер.Тип = "Массив" Тогда
			Возврат Лев(СтрСоединить(Контейнер.СписокЗначений.ВыгрузитьЗначения(), "; "), чРазмерПредставления);
		ИначеЕсли Контейнер.Тип = "СписокЗначений" Тогда
			Возврат Лев(СтрСоединить(Контейнер.СписокЗначений.ВыгрузитьЗначения(), "; "), чРазмерПредставления);
		ИначеЕсли Контейнер.Тип = "ТаблицаЗначений" Тогда
			КоличествоСтрок = Неопределено;
			Если Контейнер.Свойство("КоличествоСтрок", КоличествоСтрок) Тогда
				Возврат "<строк: " + КоличествоСтрок + ">";
			Иначе
				Возврат "<строк: ?>";
			EndIf;
		ИначеЕсли Контейнер.Тип = "МоментВремени" Тогда
			Возврат Строка(Контейнер.Дата) + "; " + Контейнер.Ссылка;
		ИначеЕсли Контейнер.Тип = "Тип" Тогда
			Возврат "Тип: " + Тип(Контейнер.ИмяТипа);
		ИначеЕсли Контейнер.Тип = "ХранилищеЗначения" Тогда
			Возврат "<ХранилищеЗначения>";
		EndIf;
	Иначе
		Возврат "???";
	EndIf;

EndFunction

#EndRegion

Function СохранитьЗапрос(СеансИД, Запрос) Экспорт

	Если ТипЗнч(СеансИД) <> Тип("Число") Тогда
		Возврат "!Не верный тип параметра 1: " + ТипЗнч(СеансИД) + ". Должен быть тип ""Число""";
	EndIf;

	Если ТипЗнч(Запрос) <> Тип("Запрос") Тогда
		Возврат "!Не верный тип параметра 2: " + ТипЗнч(Запрос) + ". Должен быть тип ""Запрос""";
	EndIf;

	Initializing( , СеансИД);

	ИмяФайла = ПолучитьИмяВременногоФайла(LockedQueriesExtension);

	ВременныеТаблицы = Новый Массив;

	Если Запрос.МенеджерВременныхТаблиц <> Неопределено Тогда
		Для Каждого Таблица Из Запрос.МенеджерВременныхТаблиц.Таблицы Цикл

			ВременнаяТаблица = Новый ТаблицаЗначений;
			Для Каждого Колонка Из Таблица.Колонки Цикл
				ВременнаяТаблица.Колонки.Добавить(Колонка.Имя, Колонка.ТипЗначения);
			EndDo;

			выбТаблица = Таблица.ПолучитьДанные().Выбрать();
			Пока выбТаблица.Следующий() Цикл
				ЗаполнитьЗначенияСвойств(ВременнаяТаблица.Добавить(), выбТаблица);
			EndDo;

			ВременныеТаблицы.Добавить(
				Новый Структура("Имя, Таблица", Таблица.ПолноеИмя, ВременнаяТаблица));
		EndDo;
	EndIf;

	Структура = Новый Структура("Текст, Параметры, ВременныеТаблицы", , , ВременныеТаблицы);
	ЗаполнитьЗначенияСвойств(Структура, Запрос);
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ИмяФайла);
	СериализаторXDTO.ЗаписатьXML(ЗаписьXML, Структура, НазначениеТипаXML.Явное);

	ЗаписьXML.Закрыть();

	Возврат "ОК:";// + ИмяФайла;

EndFunction

//&НаСервереБезКонтекста
Function ВыполнитьКод(ЭтотКод, Выборка, Параметры, ПризнакПрогресса)
	Выполнить (ЭтотКод);
EndFunction

//Этот метод можно использовать в коде для отображения прогресса.
//Параметры:
//	Обработано - число, количество обработанных записей.
//	КоличествоВсего - число, количество записей в выборке всего.
//	ДатаНачалаВМиллисекундах - число, дата начала обработки, полученное с помощью ТекущаяУниверсальнаяДатаВМиллисекундах()
//		в момент начала обработки. Это значение необходимо корректного расчета оставшегося времени.
//	ПризнакПрогресса - строка, специальное значение, необходимое для передачи значений прогресса на клиент.
//		Это значение необходимо просто передать в параметр без изменений.
Function СообщитьПрогресс(Обработано, КоличествоВсего, ДатаНачалаВМиллисекундах, ПризнакПрогресса)
	ДатаВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Сообщить(ПризнакПрогресса + ValueToString(Новый Структура("Прогресс, ДлительностьНаМоментПрогресса", Обработано
		* 100 / КоличествоВсего, ДатаВМиллисекундах - ДатаНачалаВМиллисекундах)));
	Возврат ДатаВМиллисекундах;
EndFunction

Procedure ВыполнитьАлгоритмПользователя(ПараметрыВыполнения, АдресРезультата) Экспорт

	стРезультатЗапроса = ПараметрыВыполнения[0];
	маРезультатЗапроса = стРезультатЗапроса.Результат;
	ПараметрыЗапроса = стРезультатЗапроса.Параметры;
	РезультатВПакете = ПараметрыВыполнения[1];
	Код = ПараметрыВыполнения[2];
	ФлагПострочно = ПараметрыВыполнения[3];
	ИнтервалОбновленияВыполненияАлгоритма = ПараметрыВыполнения[4];

	стРезультат = маРезультатЗапроса[Число(РезультатВПакете) - 1];
	рзВыборка = стРезультат.Результат;
	Выборка = рзВыборка.Выбрать();
	ДатаНачалаВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах();

	Если ФлагПострочно Тогда

		КоличествоВсего = Выборка.Количество();
		чМоментОкончанияПорции = 0;
		й = 0;
		Пока Выборка.Следующий() Цикл

			ВыполнитьКод(Код, Выборка, ПараметрыЗапроса, АдресРезультата);

			й = й + 1;
			Если ТекущаяУниверсальнаяДатаВМиллисекундах() >= чМоментОкончанияПорции Тогда
				//Будем использовать АдресРезультата в качестве метки сообщения состояния - это очень уникальное значение.
				ДатаВМиллисекундах = СообщитьПрогресс(й, КоличествоВсего, ДатаНачалаВМиллисекундах, АдресРезультата);
				чМоментОкончанияПорции = ДатаВМиллисекундах + ИнтервалОбновленияВыполненияАлгоритма;
			EndIf;

		EndDo;

	Иначе
		ВыполнитьКод(Код, Выборка, ПараметрыЗапроса, АдресРезультата);
	EndIf;

EndProcedure

#Region ПланЗапроса

Function СтруктураХранения()

	тзСтруктура = ПолучитьИзВременногоХранилища(IBStorageStructure);

	Если тзСтруктура = Неопределено Тогда
		тзСтруктура = ПолучитьСтруктуруХраненияБазыДанных( , Истина);
		тзСтруктура.Индексы.Добавить("Метаданные");
		ПоместитьВоВременноеХранилище(тзСтруктура, IBStorageStructure);
	EndIf;

	Возврат тзСтруктура;

EndFunction

Procedure SQLЗапросВТермины1С_ДобавитьТермин(ДанныеТерминов, ИмяБД, Имя1С)
	Если Не ПустаяСтрока(Имя1С) Тогда
		СтрокаДанныхТерминов = ДанныеТерминов.Добавить();
		СтрокаДанныхТерминов.ИмяБД = ИмяБД;
		СтрокаДанныхТерминов.Имя1С = Имя1С;
		СтрокаДанныхТерминов.ДлиннаИмениБД = СтрДлина(СтрокаДанныхТерминов.ИмяБД);
	EndIf;
EndProcedure

Function SQLЗапросВТермины1С(ТекстЗапросаSQL, ДанныеТерминов = Неопределено) Экспорт

	тзСтруктура = СтруктураХранения();

	Если ДанныеТерминов = Неопределено Тогда

		ТипСтрока = Новый ОписаниеТипов("Строка");
		ДанныеТерминов = Новый ТаблицаЗначений;
		ДанныеТерминов.Колонки.Добавить("ИмяБД", ТипСтрока);
		ДанныеТерминов.Колонки.Добавить("Имя1С", ТипСтрока);
		ДанныеТерминов.Колонки.Добавить("ДлиннаИмениБД", Новый ОписаниеТипов("Число"));

		Для Каждого Строка Из тзСтруктура Цикл

			ъ = Найти(ТекстЗапросаSQL, Строка.ИмяТаблицыХранения);
			Если ъ > 0 Тогда

				SQLЗапросВТермины1С_ДобавитьТермин(ДанныеТерминов, Строка.ИмяТаблицыХранения, Строка.ИмяТаблицы);

				Для Каждого СтрокаПоля Из Строка.Поля Цикл
					SQLЗапросВТермины1С_ДобавитьТермин(ДанныеТерминов, СтрокаПоля.ИмяПоляХранения, СтрокаПоля.ИмяПоля);
				EndDo;

			EndIf;

		EndDo;

		ДанныеТерминов.Сортировать("ДлиннаИмениБД Убыв");

	EndIf;

	ТекстЗапросаВТерминах1С = ТекстЗапросаSQL;

	Для Каждого Строка Из ДанныеТерминов Цикл
		ТекстЗапросаВТерминах1С = СтрЗаменить(ТекстЗапросаВТерминах1С, Строка.ИмяБД, Строка.Имя1С);
	EndDo;

	Возврат ТекстЗапросаВТерминах1С;

EndFunction

//	РегистрТерминов - преобразование регистра терминов:
//		0 - не преобразовывать данные терминов
//		1 - данные терминов преобразовать в нижний регистр (для POSTGRS)
Function SQLПланВТермины1С(ПланЗапроса, ДанныеТерминов, РегистрТерминов = 0) Экспорт

	ПланЗапросаВТерминах1С = ПланЗапроса;

	Если РегистрТерминов = 1 Тогда
		Для Каждого Строка Из ДанныеТерминов Цикл
			ПланЗапросаВТерминах1С = СтрЗаменить(ПланЗапросаВТерминах1С, НРег(Строка.ИмяБД), Строка.Имя1С);
		EndDo;
	Иначе
		Для Каждого Строка Из ДанныеТерминов Цикл
			ПланЗапросаВТерминах1С = СтрЗаменить(ПланЗапросаВТерминах1С, Строка.ИмяБД, Строка.Имя1С);
		EndDo;
	EndIf;

	Возврат ПланЗапросаВТерминах1С;

EndFunction

#EndRegion

#Region СведенияОВнешнейОбработке

Function СведенияОВнешнейОбработке() Экспорт

	Initializing();

	ПараметрыРегистрации = Новый Структура;
	ПараметрыРегистрации.Вставить("Вид", "ДополнительнаяОбработка");
	ПараметрыРегистрации.Вставить("Наименование", "Консоль запросов 9000");
	ПараметрыРегистрации.Вставить("Версия", DataProcessorVersion + "." + BuildVersion);
	ПараметрыРегистрации.Вставить("БезопасныйРежим", Ложь);
	ПараметрыРегистрации.Вставить("Информация", "Консоль запросов 9000");

	ТаблицаКоманд = ПолучитьТаблицуКоманд();

	ДобавитьКоманду(ТаблицаКоманд, "Консоль запросов 9000", "КонсольЗапросов9000", "ОткрытиеФормы", Истина);

	ПараметрыРегистрации.Вставить("Команды", ТаблицаКоманд);

	Возврат ПараметрыРегистрации;

EndFunction

Function ПолучитьТаблицуКоманд()

	Команды = Новый ТаблицаЗначений;
	Команды.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("Использование", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));
	Команды.Колонки.Добавить("Модификатор", Новый ОписаниеТипов("Строка"));

	Возврат Команды;

EndFunction

Procedure ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование, ПоказыватьОповещение = Ложь,
	Модификатор = "")
	НоваяКоманда = ТаблицаКоманд.Добавить();
	НоваяКоманда.Представление = Представление;
	НоваяКоманда.Идентификатор = Идентификатор;
	НоваяКоманда.Использование = Использование;
	НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
	НоваяКоманда.Модификатор = Модификатор;
EndProcedure

#EndRegion

#Region УИ

Function ОбработкаВходитВСоставУниверсальныхИнструментов() Экспорт
	Возврат Метаданные().Имя = "УИ_КонсольЗапросов";
EndFunction

#EndRegion