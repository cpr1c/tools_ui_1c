
#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	SetChoiseListOfStructureItem(Items.EditorOf1CScript,
		UT_CodeEditorClientServer.CodeEditorVariants());
	
	SetChoiseListOfStructureItem(Items.MonacoEditorTheme,
		UT_CodeEditorClientServer.ВариантыТемыРедактораMonaco());
	
	SetChoiseListOfStructureItem(Items.MonacoEditorScriptVariant,
		UT_CodeEditorClientServer.ВариантыЯзыкаСинтаксисаРедактораMonaco());

	EditorSettings = UT_CodeEditorServer.CodeEditorCurrentSettings();	
	EditorOf1CScript = EditorSettings.Вариант;
	FontSize = EditorSettings.FontSize;	

	MonacoEditorTheme = EditorSettings.Monaco.Theme;
	MonacoEditorScriptVariant = EditorSettings.Monaco.ScriptVariant;
	UseScriptMap = EditorSettings.Monaco.UseScriptMap;
	HideLineNumbers = EditorSettings.Monaco.HideLineNumbers;
	LinesHeight = EditorSettings.Monaco.LinesHeight;

	ConfigurationSourceFilesDirectories.Clear();
	Items.ConfigurationSourceFilesDirectoriesSource.ChoiceList.Clear();
	SourceCodeSources = UT_CodeEditorServer.AvailableSourceCodeSources();
	
	For Each DirectoryDescription In EditorSettings.Monaco.SourceFilesDirectories Do
		NewRow = ConfigurationSourceFilesDirectories.Add();
		NewRow.Directory = DirectoryDescription.Directory;
		NewRow.Source = DirectoryDescription.Source;
	
		Items.ConfigurationSourceFilesDirectoriesSource.ChoiceList.Add(NewRow.Source);
	EndDo;

	For Each CurrentSource In SourceCodeSources Do
		SearchStructure = New Structure;
		SearchStructure.Insert("Source", CurrentSource.Value);
		
		FoundedRows = ConfigurationSourceFilesDirectories.FindRows(SearchStructure);
		If FoundedRows.Count()>0 Then
			Continue;
		EndIf;
		
		NewRow = ConfigurationSourceFilesDirectories.Add();
		NewRow.Source = CurrentSource.Value;
		
		Items.ConfigurationSourceFilesDirectoriesSource.ChoiceList.Add(CurrentSource.Value);
		
	EndDo;

	SetItemsVisibility();
EndProcedure

&AtServer
Procedure FillCheckProcessingAtServer(Cancel, CheckedAttributes)
	CodeEditorVariants = UT_CodeEditorClientServer.CodeEditorVariants();
	
	If EditorOf1CScript = CodeEditorVariants.Monaco Then
		CheckedAttributes.Add("MonacoEditorTheme");
		CheckedAttributes.Add("MonacoEditorScriptVariant");
	EndIf;

	RowNumber = 1;
	For Each Row In ConfigurationSourceFilesDirectories Do
		If Not ValueIsFilled(Row.Source) 
			And ValueIsFilled(Row.Directory) Then
			UT_CommonClientServer.MessageToUser(StrTemplate(NStr("ru = 'В строке %1 не заполнен источник исходного кода';
			|en = 'Source code source is not filled in row %1'"),RowNumber),,,, Cancel);
		EndIf;
		
		RowNumber = RowNumber +1;
	EndDo;

	SourceValueTable = ConfigurationSourceFilesDirectories.Unload(, "Source");
	SourceValueTable.GroupBy("Source");
	
	For Each Row ИЗ SourceValueTable Do
		SearchStructure = New Structure;
		SearchStructure.Insert("Source", Row.Source);

		FoundedRows = ConfigurationSourceFilesDirectories.FindRows(SearchStructure);

		If FoundedRows.Count() > 1 Then
			
			UT_CommonClientServer.MessageToUser(StrTemplate(NStr("ru = 'С источником исходного кода %1 обнаружено более одной строки. Запись невозможна';
			|en = 'More than one line was detected with the source code source %1. Recording is not possible'"),Row.Source),,,, Cancel)
			
		EndIf;
	EndDo;
EndProcedure


#EndRegion

#Region FormHeaderEventsHandlers

&AtClient
Procedure EditorOf1CScriptOnChange(Item)
	SetItemsVisibility();
EndProcedure

&AtClient
Procedure ConfigurationSourceFilesDirectoriesDirectoryStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentData = Items.ConfigurationSourceFilesDirectories.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	FileDescription = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	FileDescription.FileName = CurrentData.Directory;
	
	NotificationAdditionalParameters = New Structure;
	NotificationAdditionalParameters.Insert("CurrentRow", Items.ConfigurationSourceFilesDirectories.CurrentRow);
	
	UT_CommonClient.FormFieldFileNameStartChoice(FileDescription, Item, ChoiceData, StandardProcessing,
		FileDialogMode.ChooseDirectory,
		New NotifyDescription("ConfigurationSourceFilesDirectoriesDirectoryStartChoiceEnd", ThisObject,
		NotificationAdditionalParameters));
EndProcedure

#EndRegion


#Region FormCommandsHandlers
&AtClient
Procedure Apply(Command)
	If Not CheckFilling() Then
		Return;
	EndIf;
	
	ApplyAtServer();
	Close();
EndProcedure

&AtClient
Procedure SaveConfigurationModulesToFiles(Command)
	
	CurrentDirectories = New Map;
	For Each CurrentRow In ConfigurationSourceFilesDirectories Do
		If Not ValueIsFilled(CurrentRow.Source) 
			Или Not ValueIsFilled(CurrentRow.Directory) Then
				Continue;
		EndIf;

		CurrentDirectories.Insert(CurrentRow.Source, CurrentRow.Directory);
	EndDo;
	
	UT_CodeEditorClient.СохранитьМодулиКонфигурацииВФайлы(
		New NotifyDescription("SaveConfigurationModulesToFilesEnd", ThisObject), CurrentDirectories);
EndProcedure

#EndRegion

#Region Internal

&AtClient
Procedure SaveConfigurationModulesToFilesEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	For Each CurrentDirectory In Result Do
		SearchStructure = New Structure;
		SearchStructure.Insert("Source", CurrentDirectory.Source);
		
		FoundedRows = ConfigurationSourceFilesDirectories.FindRows(SearchStructure);
		If FoundedRows.Count() = 0 Then
			NewRow = ConfigurationSourceFilesDirectories.Add();
			NewRow.Source = CurrentDirectory.Source;
		Else
			NewRow = FoundedRows[0];
		EndIf;
		
		NewRow.Directory = CurrentDirectory.Directory;
	EndDo;
	
	Modified = True;
EndProcedure


&AtClient
Procedure ConfigurationSourceFilesDirectoriesDirectoryStartChoiceEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	If Result.Count()=0 Then
		Return;
	EndIf;
	
	CurrentData = ConfigurationSourceFilesDirectories.FindByID(AdditionalParameters.CurrentRow);
	CurrentData.Directory = Result[0];
	
	Modified = True;
EndProcedure

&AtServer
Procedure SetItemsVisibility()
	Variants = UT_CodeEditorClientServer.CodeEditorVariants();
	
	IsMonaco = EditorOf1CScript = Variants.Monaco;
	
	Items.GroupMonacoCodeEditor.Visible = IsMonaco;
EndProcedure

&AtServer
Procedure SetChoiseListOfStructureItem(Item, DataStructure)
	Item.ChoiceList.Clear();
	For Each KeyValue In DataStructure Do
		Item.ChoiceList.Add(KeyValue.Key, KeyValue.Value);
	EndDo;		
EndProcedure

&AtServer
Procedure ApplyAtServer()
	CodeEditorParameters = UT_CodeEditorClientServer.ПараметрыРедактораКодаПоУмолчанию();
	CodeEditorParameters.FontSize = FontSize;
	CodeEditorParameters.Вариант = EditorOf1CScript;
	
	CodeEditorParameters.Monaco.Theme = MonacoEditorTheme;
	CodeEditorParameters.Monaco.ScriptVariant = MonacoEditorScriptVariant;
	CodeEditorParameters.Monaco.UseScriptMap = UseScriptMap;
	CodeEditorParameters.Monaco.HideLineNumbers = HideLineNumbers;
	CodeEditorParameters.Monaco.LinesHeight = LinesHeight;
	
	For Each CurrentRow In ConfigurationSourceFilesDirectories Do
		If Not ValueIsFilled(CurrentRow.Directory) Then
			Continue;
		EndIf;
	
		DirectoryDescription = UT_CodeEditorClientServer.НовыйОписаниеКаталогаИсходныхФайловКонфигурации();
		DirectoryDescription.Источник = CurrentRow.Source;
		DirectoryDescription.Каталог = CurrentRow.Directory;
		
		CodeEditorParameters.Monaco.SourceFilesDirectories.Add(DirectoryDescription);
	EndDo;
	
	UT_CodeEditorServer.SetCodeEditorNewSettings(CodeEditorParameters);
	
EndProcedure
#EndRegion