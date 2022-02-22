#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	FillParametersTable();

	If Not Parameters.Key.IsEmpty() Then

		AlgorithmTextSettings = CommonSettingsStorage.GetList(String(Parameters.Key) + "-n1");

		For Each ListItem In AlgorithmTextSettings Do

			AlgorithmTextSetting = CommonSettingsStorage.Load(String(Parameters.Key) + "-n1",
				ListItem.Value);
			Items.AlgorithmText[ListItem.Value] = AlgorithmTextSetting;
		EndDo;

	EndIf;

	FillFormFieldsChoiceLists();

	SetVisibleAndEnabled();
EndProcedure

&AtServer
Procedure BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)
	//TODO: Insert the handler content
EndProcedure

&AtServer
Procedure AfterWriteAtServer(CurrentObject, WriteParameters)
	SetVisibleAndEnabled();
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source)
		If EventName = "ParameterChanged" Then
		Read();
		FillParametersTable();
	ElsIf EventName = "Update" Then
		Read();
	ElsIf EventName = "UpdateCode" Then
		Read();
		Write();
	EndIf;
EndProcedure

#EndRegion

#Region FormHeadEventsHandlers

&AtClient
Procedure GroupPagesPanelOnCurrentPageChange(Item, CurrentPage)
		If Modified And CurrentPage.Name <> "GroupCode" Then
		Write();
	EndIf;
EndProcedure

&AtClient
Procedure AtClientOnChange(Item)
	SetVisibleAndEnabled();
EndProcedure
#EndRegion

#Region FormTableItemsEventHandlers_Parameters

&AtClient
Procedure ParametersTableBeforeDeleteRow(Item, Cancel)
	ShowQueryBox(New NotifyDescription("ParametersTableBeforeDeleteEnd", ThisObject,
		New Structure("String,Parameter", Item.CurrentLine, Item.CurrentData.Parameter)), Nstr("ru = 'Элемент структуры настроек будет удален без возможности  восстановления !';
		|en = 'The element of the settings structure will be deleted without the possibility of recovery !'")
		+ Chars.LF +Nstr("ru = 'Продолжить выполнение ?';en = 'Continue execution ?'"), QuestionDialogMode.YesNoCancel);
	Cancel = True;
EndProcedure
&AtClient
Procedure ParametersTableBeforeDeleteEnd(Result, AdditionalParameters) Export
	If Result = DialogReturnCode.Yes Then
		If DeleteParameterAtServer(AdditionalParameters.Parameter) Then
			Read();
			FillParametersTable();
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure ParametersTableParameterOpening(Item, StandardProcessing)
		StandardProcessing = False;
	If Item.Parent.CurrentData.TypeDescription = "Value Table"
		Or Item.Parent.CurrentData.TypeDescription = "Binary data" Then
		Return;
	EndIf;
	Try
		Value = GetParameterAtServer(Items.ParametersTable.CurrentData.Parameter);
		ShowValue( , Value);
	Except
		Message(ErrorDescription());
	EndTry;
EndProcedure

#EndRegion

#Region FormCommandsHandlers
///
&AtClient
Procedure AddParameter(Command)
	FormParameters = New Structure("Key", Object.Ref);
	OpenForm("Catalog.UT_Algorithms.Form.ParameterForm", FormParameters, ThisObject);
EndProcedure

&AtClient
Procedure EditName(Command)
	If Items.ParametersTable.CurrentData = Undefined Then
		Return;
	EndIf 	;
	FormParameters = New Structure("Key,ParameterName,Rename", Parameters.Key,
		Items.ParametersTable.CurrentData.Parameter, True);
	OpenForm("Catalog.UT_Algorithms.Form.ParameterForm", FormParameters, ThisObject);
EndProcedure

&AtClient
Procedure EditValue(Command)
	If Items.ParametersTable.CurrentData <> Undefined Then
		FormParameters = New Structure;
		FormParameters.Insert("Key", Parameters.Key);
		FormParameters.Insert("ParameterName", Items.ParametersTable.CurrentData.Parameter);
		FormParameters.Insert("ParameterType", Items.ParametersTable.CurrentData.ОписаниеТипа);
		OpenForm("Catalog.UT_Algorithms.Form.ParameterForm", FormParameters, ThisObject);
	EndIf;
EndProcedure

///
&AtClient
Procedure ExecuteProcedure(Command)

	If Modified Then
		Write();
	EndIf;

	StartTime = CurrentUniversalDateInMilliseconds();

	Error = False;
	ErrorMessage = "";

	If Object.AtClient Then
		UT_CommonClient.ExecuteAlgorithm(Object.Ref, , Error, ErrorMessage);
	Else
		UT_CommonServerCall.ExecuteAlgorithm(Object.Ref, , Error, ErrorMessage);
	EndIf;
	If Error Then
		UT_CommonClientServer.MessageToUser(ErrorMessage);

		Items.EventLog.Title = NSTR("ru = 'ПОСМОТРЕТЬ ОШИБКИ';en = 'VIEW ERRORS'");
		MarkError(ErrorMessage);
	Else
		Items.EventLog.Title = " ";
	EndIf;
		Items.ExecuteProcedure.Title = StrTemplate("ru = 'Выполнить процедуру %1 мс.';en = 'Execute procedure %1 ms.'", String(CurrentUniversalDateInMilliseconds()- StartTime));
EndProcedure

///
&AtClient
Procedure ShowQueryWizard(Command)
	Wizard = New QueryWizard;
	SelectedText = Items.AlgorithmText.SelectedText;
	WholeText = Items.AlgorithmText.EditText;
	FoundWholeTextInQuotationMarks(SelectedText, WholeText);
	Wizard.Text = StrReplace(SelectedText, "|", "");
	AdditionalParameters = New Structure("WizardFirstCall,WholeText,SelectedText", StrFind(
		SelectedText, "SELECT") = 0, WholeText, SelectedText);
	Notification = New NotifyDescription("GetQueryText", ThisObject, AdditionalParameters);
	Wizard.Show(Notification);
EndProcedure

&AtClient
Procedure FormatText(Command)
	Text = Object.AlgorithmText;
	Text = StrReplace(Text, Chars.LF, " \\ ");
	Text = StrReplace(Text, Chars.Tab, " ");
	Text = StrReplace(Text, "=", " = ");
	Text = StrReplace(Text, "< =", " <=");
	Text = StrReplace(Text, "> =", " >=");
	For А = 0 To Round(Sqrt(StrOccurrenceCount(Text, "  ")), 0) Do
		Text = StrReplace(Text, "  ", " ");
	EndDo;
	Text = StrReplace(Text, " ;", ";");
	WordsArray = StrSplit(Text, Char(32));
	FormattedText = "";
	TabulationString = "";
	WordsTypes = New Array;
	WordsTypes.Add(StrSplit("THEN,DO,\\", ",")); // right transfer
	WordsTypes.Add(StrSplit("IF,WHILE,FOR", ",")); // operator brackets open
	WordsTypes.Add(StrSplit("ENDDO;,ENDIF;", ",")); // operator brackets close
	WordsTypes.Add(StrSplit("ELSE,ELSIF", ",")); //operator brackets inside
	WasType = New Map;
	For Iterator = 0 To WordsArray.Count() - 1 Do
		FormatBefore = "";
		FormatAfter = "";

		WordType = WordType(WordsArray[Iterator], WordsTypes);

		If WordType["OpenBracket"] Then
			TabulationString = TabulationString + Chars.Tab;
		EndIf;

		If WordType["InsideBracket"] Then
			FormattedText = Left(FormattedText, StrLen(FormattedText) - 1);
		EndIf;

		If WordType["CloseBracket"] Then
			TabulationString = Left(TabulationString, StrLen(TabulationString) - 1);
			FormattedText = Left(FormattedText, StrLen(FormattedText) - 1);
		EndIf;

		If WordType["RightTransfer"] And Not WasType["RightTransfer"] Then
			FormatAfter = Chars.LF + TabulationString;
		EndIf;

		//If WordType["LeftTransfer"] And Not WasType["RightTransfer"]  Then 
		//	FormatBefore =  Chars.LF + TabulationString ;
		//EndIf;
		FormattedText = FormattedText + FormatBefore + WordsArray[Iterator] + Char(32) + FormatAfter;

		WasType = WordType;
	EndDo;

	FormattedText = StrReplace(FormattedText, "\\ ", "");
	FormattedText = StrReplace(FormattedText, "\\", "");
	Object.AlgorithmText = FormattedText;

EndProcedure

&AtClient
Procedure AddScheduledJob(Command)
	If Object.AtClient Then
		Message(Nstr("ru = 'это клиентская процедура';en = 'This is a client procedure'"));
		Return;
	EndIf;
	CreateScheduledJob();
EndProcedure

&AtClient
Procedure DeleteScheduledJob(Command)
	DeleteScheduledJobAtServer();
EndProcedure

&AtClient
Procedure EventLog(Command)
	ConnectExternalDataProcessorAtServer();
	OpenParameters = New Structure;
	OpenParameters.Insert("Data", Object.Ref);
	OpenParameters.Insert("ValidFrom", BegOfDay(CurrentDate()));
	OpenForm("ExternalDataProcessors.StandardEventLog.Form", OpenParameters);
EndProcedure

#EndRegion

#Region Private

#Region WorkWithParameters

&AtServer
Procedure FillParametersTable()
	SelectedObject = FormAttributeToValue("Object");
	TableOfParameters = FormAttributeToValue("ParametersTable");
	TableOfParameters.Clear();
	ParametersStructure = SelectedObject.Storage.Get();
	If Not ParametersStructure = Undefined Then
		For Each StructureItem In ParametersStructure Do
			NewRow = TableOfParameters.Add();
			NewRow.Parameter = StructureItem.Key;
			NewRow.TypeDescription = GetTypeDescriptionString(StructureItem.Value);
		EndDo;
		ValueToFormAttribute(TableOfParameters, "ParametersTable");
	EndIf;
EndProcedure

&AtServer
Function GetTypeDescriptionString(Value)
	If XMLTypeOf(Value) <> Undefined Then
		Return XMLType(TypeOf(Value)).TypeName;
	Else
		Return String(TypeOf(Value));
	EndIf;
EndFunction

&AtServer
Procedure AddNewParameterAtServer(ParameterStructure)
	ChangeParameter(ParameterStructure);
EndProcedure

&AtServer
Function DeleteParameterAtServer(Key)
	SelectedObject = FormAttributeToValue("Object");
	Return SelectedObject.RemoveParameter(Key);
EndFunction

&AtServer
Function GetParameterAtServer(ParameterName)
	SelectedObject = FormAttributeToValue("Object");
	Return SelectedObject.GetParameter(ParameterName);
EndFunction

&AtServer
Procedure ChangeParameter(NewData) Export
	ParameterName = NewData.ParameterName;
	If TypeOf(NewData.ParameterValue) = Type("String") Then
		If Left(NewData.ParameterValue, 1) = "{" Then
			Position = StrFind(NewData.ParameterValue, "}");
			If Position > 0 Then
				StorageURL = Mid(NewData.ParameterValue, Position + 1);
				ParameterValue = GetFromTempStorage(StorageURL);
				FileExtention = StrReplace(Mid(NewData.ParameterValue, 2, Position - 2), Char(32), "");
				ParameterName = "File" + Upper(FileExtention) + "_" + ParameterName;
			Else
				If Object.ThrowException Then
					Raise NSTR("ru = 'Ошибка при чтении файла из хранилища';en = 'Error when reading a file from storage'");
				EndIf;
			EndIf;
		Else
			ParameterValue = NewData.ParameterValue;
		EndIf;
	Else
		ParameterValue = NewData.ParameterValue;
	EndIf;
//	Parameters = Storage.Get();
//	If Parameters = Undefined ИЛИ Typeof(Parameters) <> Type("Structure") Then
//		Parameters = New Structure;
//	EndIf;
//	Parameters.Insert(ParameterName, ParameterValue);
//	Storage = New ValueStorage(Parameters);
//	Write();
EndProcedure

#EndRegion

#Region WorkWithScript

&AtClient
Procedure MarkError(ErrorText)
	ErrorPosition = StrFind(ErrorText, "{(");
	If ErrorPosition > 0 Then
		PositionBracketClosed = StrFind(ErrorText, ")}", , ErrorPosition);
		If PositionBracketClosed > 0 Then
			PositionComma = StrFind(Left(ErrorText, PositionBracketClosed), ",", , ErrorPosition);
			If PositionComma > 0 Then
				TextLineNumber = Mid(ErrorText, ErrorPosition + 2, StrLen(Left(ErrorText, PositionComma)) - StrLen(
					Left(ErrorText, ErrorPosition)) - 2);
			Else
				TextLineNumber = Mid(ErrorText, ErrorPosition + 2, StrLen(Left(ErrorText, PositionBracketClosed))
					- StrLen(Left(ErrorText, ErrorPosition)) - 2);
			EndIf;
			// nested error e.g. request
			ErrorPosition2 = StrFind(ErrorText, "{(", , , 2);
			If ErrorPosition2 > 0 Then
				PositionBracketClosed2 = StrFind(ErrorText, ")}", , ErrorPosition2);
				If PositionBracketClosed2 > 0 Then
					PositionComma2 = StrFind(Left(ErrorText, PositionBracketClosed2), ",", , ErrorPosition2);
					If PositionComma2 > 0 Then
						TextLineNumber2 = Mid(ErrorText, ErrorPosition2 + 2, StrLen(Left(ErrorText, PositionComma2))
							- StrLen(Left(ErrorText, ErrorPosition2)) - 2);
					Else
						TextLineNumber2 = Mid(ErrorText, ErrorPosition2 + 2, StrLen(Left(ErrorText,
							PositionBracketClosed2)) - StrLen(Left(ErrorText, ErrorPosition2)) - 2);
					EndIf;
				EndIf;
			EndIf;
			Try
				LineNumber = Number(TextLineNumber);
				StringsArray = StrSplit(Object.Text, Chars.LF, True);
				StringsArray[LineNumber - 1] = StringsArray[LineNumber - 1] + " <<<<<";
				If ErrorPosition2 > 0 Then
					LineNumber2 = Number(TextLineNumber2);
					Ъ = LineNumber - 1;
					While Ъ >= 0 Do
						If StrFind(StringsArray[Ъ], "SELECT") > 0 Or StrFind(StringsArray[Ъ], "Select") > 0 Or StrFind(
							StringsArray[Ъ], "select") > 0 Then
							StringsArray[Ъ + LineNumber2 - 1] = StringsArray[Ъ + LineNumber2 - 1] + " <<<<<";
						EndIf;
						Ъ = Ъ - 1;
					EndDo;
				EndIf;
				Object.Text = StrConcat(StringsArray, Chars.LF);
			Except
				Return;
			EndTry;
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure HighlightChangedCode()
      //Items.AlgorithmText.BorderColor=New Color(255,99,71);
	//Items.Write.BgColor=New Color(255,99,71);
	Modified = True;
EndProcedure

&AtClient
Procedure FoundWholeTextInQuotationMarks(SelectedText, WholeText)
	If StrLen(SelectedText) > 10 Then // we need a unique text , we need to check the number of inclusions in a good way
		SeachingHere = StrFind(WholeText, SelectedText);
		FoundQuotationMarkBefore = 0;
		For А = 1 To StrOccurrenceCount(WholeText, """") Do
			FoundQuotationMarkAfter = StrFind(WholeText, """", , , А);
			If FoundQuotationMarkAfter > SeachingHere Then
				SelectedText = Mid(WholeText, FoundQuotationMarkBefore + 1, StrLen(Left(WholeText, FoundQuotationMarkAfter))
					- StrLen(Left(WholeText, FoundQuotationMarkBefore)) - 1);
				Break;
			EndIf;
			FoundQuotationMarkBefore = FoundQuotationMarkAfter;
		EndDo;
	EndIf;
EndProcedure

&AtClient
Procedure GetQueryText(Text, AdditionalParameters) Export
	If Text = Undefined Then
		Return;
	EndIf;
	StringsArray = StrSplit(Text, Chars.LF);
	QueryText = StringsArray[0];
	For Iterator = 1 To StringsArray.Count() - 1 Do
		QueryText = QueryText + Chars.LF + "|" + TrimAll(StringsArray[Iterator]);
	EndDo;
	InsertionText = "";
	If AdditionalParameters.WizardFirstCall Then
		InsertionText = "
					   |Query = New Query;
					   |QueryText = """ + QueryText + """;
															|Query.Text = QueryText;";
		While Find(QueryText, "&") > 0 Do
			QueryParameter = UT_AlgorithmsClientServer.GetWordFirstOccurrenceWithOutPrefix(QueryText, "&");
			InsertionText = InsertionText + "
										  |Query.SetParameter(""" + QueryParameter + """,@" + QueryParameter
				+ " );";
			QueryText = StrReplace(QueryText, "&" + QueryParameter, "~" + QueryParameter);
		EndDo;
		Text = Text + "
						|Result = Query.Execute();
						|If Not Result.IsEmpty() Then
						|	Selection = Result.Select();
						|	While Selection.Next() Do
						|	 	// Message("");
						|	EndDo;
						|EndIf;";
	Else
		InsertionText = QueryText;
	EndIf;
	If IsBlankString(AdditionalParameters.SelectedText) Then
		Object.Text = Object.Text + InsertionText;
		Items.AlgorithmText.UpdateEditText();
	Else
		Object.Text = StrReplace(AdditionalParameters.WholeText, AdditionalParameters.SelectedText,
			InsertionText);
		Items.AlgorithmText.UpdateEditText();
	EndIf;
	HighlightChangedCode();

EndProcedure

&AtClient
Function WordType(Word, WordsTypes)
	WordType = New Map;

	WordType["RightTransfer"] = ?(WordsTypes[0].Find(Upper(TrimAll(Word))) = Undefined, False, True);
	WordType["OpenBracket"] = ?(WordsTypes[1].Find(Upper(TrimAll(Word))) = Undefined, False, True);
	WordType["CloseBracket"] = ?(WordsTypes[2].Find(Upper(TrimAll(Word))) = Undefined, False, True);
	WordType["InsideBracket"] = ?(WordsTypes[3].Find(Upper(TrimAll(Word))) = Undefined, False, True);
	Return WordType;

EndFunction

&AtServer
Procedure ExecuteProcedureAtServer(ExecutionError = False, ErrorMessage = "")
	SelectedObject = FormAttributeToValue("Object");
	AdditionalParameters = New Structure;
	SelectedObject.ExecuteProcedure(AdditionalParameters);
	ExecutionError = AdditionalParameters.Cancel;
	ErrorMessage = AdditionalParameters.ErrorMessage;
EndProcedure

#EndRegion //------------------------------------- WorkwithScript

&AtServer
Procedure FillFormFieldsChoiceLists()

       //ChoiceList MetadataObject  CommandInterface

	// ChoiceLists  Parameters
	Query = New Query;
	Query.Text = "SELECT DISTINCT
  					|UT_AlgorithmsParameters.ParameterType
 					|FROM
 					|	Catalog.UT_Algorithms.Parameters AS UT_AlgorithmsParameters";

    Selection = Query.Execute().StartChoosing();

	While Selection.Next() Do

		If Not IsBlankString(Selection.ParameterType) Then

			Items.ApiParameterType.ChoiceList.Add(TrimAll(Selection.ParameterType));
		EndIf;

	EndDo;

EndProcedure
&AtServer
Procedure SetVisibleAndEnabled()
	Items.GroupPagesPanel.Enabled = Not Parameters.Key.IsEmpty();

	Items.EventLog.Title = " ";

	Items.GroupServer.Visible=Not Object.AtClient;
EndProcedure
#Region ImportExport
//Import
&AtClient
Procedure ExternalFileStartChoiceEnd(SelectedFiles, AdditionalParameters) Export
	If (TypeOf(SelectedFiles) = Type("Array") And SelectedFiles.Count() > 0) Then
		ExternalFile = SelectedFiles[0];
		Directory = Left(ExternalFile, StrFind(ExternalFile, GetPathSeparator(), SearchDirection.FromEnd));
		NotifyDescription = New NotifyDescription("PutFileEnd", ThisObject, New Structure("Directory",
			Directory));
		BeginPutFile(NotifyDescription, , ExternalFile, False, ThisObject.UUID);
	Else
		UT_CommonClientServer.MessageToUser(NSTR("ru = 'Нет файла';en = 'No file'"));
	EndIf;
EndProcedure

&AtClient
Procedure PutFileEnd(Result, StorageURL, SelectedFileName, AdditionalParameters) Export
	If Result Then
		ReadAtServer(StorageURL, SelectedFileName, AdditionalParameters);
	Else
		UT_CommonClientServer.MessageToUser(Nstr("ru = 'Ошибка помещения файла в хранилище';en = 'Error putting a file to storage'"));
	EndIf;
EndProcedure

&AtServer
Procedure ReadAtServer(StorageURL, SelectedFileName, AdditionalParameters)
	ParameterName = StrReplace(StrReplace(StrReplace(StrReplace(Upper(SelectedFileName), Upper(
		AdditionalParameters.Directory), ""), ".", ""), "XML", ""), Char(32), "");
	Try
		BinaryData = GetFromTempStorage(StorageURL);
		Stream = BinaryData.OpenStreamForRead();
		XMLReader = New XMLReader;
		XMLReader.OpenStream(Stream);
		ParameterValue = XDTOSerializer.ReadXML(XMLReader);
		AddNewParameterAtServer(New Structure("ParameterName,ParameterValue",
			ParameterName, ParameterValue));
	Except
		Raise NSTR("ru = 'Ошибка записи файла XML';en = 'Error writing XML file'") + ErrorDescription();
	EndTry;
EndProcedure

// readatserver()

//Export
&AtClient
Procedure ChooseDirectoryEnd(SelectedFiles, AdditionalParameters) Export
	If (TypeOf(SelectedFiles) = Type("Array") And SelectedFiles.Count() > 0) Then
		Directory = SelectedFiles[0];
		Parameter = Items.ParametersTable.CurrentData.Parameter;
		FileExtention = "";
		FileName = TrimAll(Parameter);
		If TypeOf(AdditionalParameters) = Type("Structure") And AdditionalParameters.Property("UnloadXML") Then
			FileExtention = ".xml";
			StorageURL = GetFileAtServer(Parameter, True);
		Else
			If StrFind(Parameter, "File") > 0 Then
				Position = StrFind(FileName, "_");
				FileExtention = "." + Lower(Mid(FileName, 5, Position - 5));
				FileName = Mid(FileName, Position + 1);
			EndIf;
			StorageURL = GetFileAtServer(Parameter, False);
		EndIf;
		Notification = New NotifyDescription("AfterGetFile", ThisObject);
		FileDescription = New TransferableFileDescription;
		FileDescription.Location = StorageURL;
		FileDescription.Name = Directory + GetPathSeparator() + FileName + FileExtention;
		ObtainedFiles = New Array;
		ObtainedFiles.Add(FileDescription);
		BeginGettingFiles(Notification, ObtainedFiles, , False);
	EndIf;
EndProcedure

&AtServer
Function GetFileAtServer(Parameter, UnloadXML)
	SelectedParameter = GetParameterAtServer(Parameter);
	If UnloadXML Then
		XMLWriter = New XMLWriter;
		Stream = New MemoryStream;
		XMLWriter.OpenStream(Stream);
		XDTOSerializer.WriteXML(XMLWriter, SelectedParameter);
		XMLWriter.Close();
		BinaryData = Stream.CloseAndGetBinaryData();
		StorageURL = PutToTempStorage(BinaryData, ThisObject.UUID);
	Else
		StorageURL = PutToTempStorage(SelectedParameter, ThisObject.UUID);
	EndIf;
	Return StorageURL;
EndFunction

&AtClient
Procedure AfterGetFile(ObtainedFiles, AdditionalParameters) Export
	If TypeOf(ObtainedFiles) = Type("Array") Then
		UT_CommonClientServer.MessageToUser(StrTemplate(Nstr("ru = 'Файл %1 записан';en = 'File %1 writed'"),ObtainedFiles[0].Name));
	EndIf;
EndProcedure

&AtClient
Procedure ApiCheckParameters(Command)
	Object.Parameters.Clear();
	AlgorithmCode = Object.AlgorithmCode;
	mExcluding = UT_AlgorithmsClientServer.ExcludedSymbolsArray();
	Prefix = "Parameters.";
	FillType = New Structure;
	While Find(AlgorithmCode, Prefix) > 0 Do
		Word = UT_AlgorithmsClientServer.GetWordFirstOccurrenceWithOutPrefix(AlgorithmCode, Prefix, mExcluding);
		AlgorithmCode = StrReplace(AlgorithmCode, Prefix + Word, Word);
		Try
			FillType.Insert(Word, True);
		Except
		EndTry;
	EndDo;
	Text = Object.Text;
	Prefix = "$";
	While Find(AlgorithmCode, Prefix) > 0 Do
		Word = UT_AlgorithmsClientServer.GetWordFirstOccurrenceWithOutPrefix(Text, Prefix, mExcluding);
		Text = StrReplace(Text, Prefix + Word, Word);
		Try
			FillType.Insert(Word, False);
		Except
		EndTry;
	EndDo;
     
	StorageURL = UT_AlgorithmsClientServer.GetParameters(Object.Ref, True);

	StoredParameters = GetFromTempStorage(StorageURL);

	For Each Item In FillType Do
		NewRow = Object.Parameters.Add();
		NewRow.Entry = Item.Value;
		NewRow.Name = Item.Key;
		If NewRow.Entry And StoredParameters.Property(Item.Key) Then
			NewRow.ParameterType = GetTypeDescriptionString(StoredParameters[Item.Key]);
			NewRow.ByDefault = String(StoredParameters[Item.Key]);
		EndIf;
	EndDo;
EndProcedure

#EndRegion

&AtServer
Procedure ConnectExternalDataProcessorAtServer()
	ExternalDataProcessors.Connect("v8res://mngbase/StandardEventLog.epf", "StandardEventLog", False);
EndProcedure

&AtServer
Procedure CreateScheduledJob()
	If Parameters.Key.IsEmpty() Then
		Return;
	EndIf;
	ParametersArray = New Array;
	ParametersArray.Add(Object.Ref);
	Filter = New Structure;
	Filter.Insert("Key", Object.Ref.UUID());
	JobsArray = ScheduledJobs.GetScheduledJobs(Filter);
	If JobsArray.Count() >= 1 Then
		Message(NSTR("ru = 'Задание с ключом %1 уже существует';en = 'Scheduled job  with key %1  already exist'",Filter.Key));
	Else
		Job = ScheduledJobs.CreateScheduledJob("alg_UniversalScheduledJob");
		Job.Title = Object.Title;
		Job.Key = Filter.Key;
		Job.Use = False;
		Job.Parameters = ParametersArray;
		Job.Write();
		Message(StrTemplate(NSTR("ru = 'Создано регламентное задание %1 с  ключом %2';en = 'Created scheduled job %1 with key %2 '"), Object.Title,Filter.Key));
	EndIf;
EndProcedure

&AtServer
Procedure DeleteScheduledJobAtServer()
	If Parameters.Key.IsEmpty() Then
		Return;
	EndIf;
	ParametersArray = New Array;
	ParametersArray.Add(Object.Ref);
	Filter = New Structure;
	Filter.Insert("Key", Object.Ref.UUID());
	JobsArray = ScheduledJobs.GetScheduledJobs(Filter);
	If JobsArray.Count() >= 1 Then
		JobsArray[0].Delete();
		Message(Nstr("ru = 'Удалено регламентное задание';en = 'Deleted scheluded job'")+ Object.Title);
	EndIf;
EndProcedure

#EndRegion