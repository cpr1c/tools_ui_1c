#Region Variables

#EndRegion

#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	CodeSources = UT_CodeEditorServer.ДоступныеИсточникиИсходногоКода();
	
	For Each CurrentSource ИЗ CodeSources Do
		NewRow = SaveDirectories.Add();
		NewRow.Check = True;
		NewRow.Source = CurrentSource.Value;
		NewRow.OnlyModules = True;
		
		NewRow.Directory = Parameters.CurrentDirectories[NewRow.Source];
	EndDo;

	ConnectionString = InfoBaseConnectionString();

	ConnectionStringParametersArray = StrSplit(ConnectionString, ";");
	ConnectionStringParametersCompliance = New Structure;
	For Each ConnectionStringParameterString In ConnectionStringParametersArray Do
		ParameterArray = StrSplit(ConnectionStringParameterString, "=");
		If ParameterArray.Count() <> 2 Then
			Continue;
		EndIf;
		Parameter = Lower(ParameterArray[0]);
		ParameterValue = ParameterArray[1];
		ConnectionStringParametersCompliance.Insert(Parameter, ParameterValue);
	EndDo;

	If ConnectionStringParametersCompliance.Property("file") Then
		InfobasePlacement = 0;
		InfobaseDirectory = UT_StringFunctionsClientServer.PathWithoutQuotes(
			ConnectionStringParametersCompliance.File);
	ElsIf ConnectionStringParametersCompliance.Property("srvr") Then
		InfobasePlacement = 1;
		InfobaseServer = UT_StringFunctionsClientServer.PathWithoutQuotes(ConnectionStringParametersCompliance.srvr);
		InfoBaseName = UT_StringFunctionsClientServer.PathWithoutQuotes(ConnectionStringParametersCompliance.ref);
	EndIf;
	User = UserName();

	SetVisibleAndEnabled();
	
EndProcedure


&AtServer
Procedure FillCheckProcessingAtServer(Cancel, CheckedAttributes)
	For Each Row In SaveDirectories Do
		If Not Row.Check Then
			Continue;
		EndIf;
		
		If Not ValueIsFilled(Row.Directory) Then
			UT_CommonClientServer.MessageToUser(StrTemplate(NStr("ru = 'Для источника %1 не указан каталог сохранения';
			|en = 'No save directory is specified for source %1'"),Row.Source), , , , Cancel);
		EndIf;
	EndDo;
	
	If InfobasePlacement = 0 Then
		CheckedAttributes.Add("InfobaseDirectory");
	Else
		CheckedAttributes.Add("InfobaseServer");
		CheckedAttributes.Add("InfoBaseName");
	EndIf;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	#If Not WebClient And Not MobileClient Then
	PlatformLaunchFile = BinDir();
	If Right(PlatformLaunchFile, 1) <> GetPathSeparator() Then
		PlatformLaunchFile = PlatformLaunchFile + GetPathSeparator();
	EndIf;
	
	PlatformLaunchFile = PlatformLaunchFile + "1cv8";	
	If UT_CommonClientServer.IsWindows() Then
		PlatformLaunchFile = PlatformLaunchFile + ".exe";
	EndIf;
	
	#EndIf
EndProcedure

#EndRegion

#Region FormHeaderItemsEventsHandlers

&AtClient
Procedure InfobasePlacementOnChange(Item)
	SetVisibleAndEnabled();
EndProcedure

&AtClient
Procedure PlatformLaunchFileStartChoice(Item, ChoiceData, StandardProcessing)
	FileDescription = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	FileDescription.FileName = PlatformLaunchFile;

	FileName = "1cv8";
	
	If UT_CommonClientServer.IsWindows() Then
		FileName = FileName+".exe";
	EndIf;
	
	UT_CommonClient.AddFormatToSavingFileDescription(FileDescription, StrTemplate(NStr("ru = 'Файл толстого клиента 1С(%1)';
	|en = '1C thick client file (%1)'"),FileName), "",FileName);
	
	UT_CommonClient.FormFieldFileNameStartChoice(FileDescription, Item, ChoiceData, StandardProcessing,
		FileDialogMode.Open,
		New NotifyDescription("PlatformLaunchFileStartChoiceOnEnd", ThisObject));
EndProcedure

&AtClient
Procedure SaveDirectoriesDirectoryStartChoice(Item, ChoiceData, StandardProcessing)
	CurrentData = Items.SaveDirectories.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	FileDescription = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	FileDescription.FileName = CurrentData.Directory;
	
	NotificationAdditionalParameters = New Structure;
	NotificationAdditionalParameters.Insert("CurrentLine", Items.SaveDirectories.CurrentRow);
	
	UT_CommonClient.FormFieldFileNameStartChoice(FileDescription, Item, ChoiceData, StandardProcessing,
		FileDialogMode.ChooseDirectory,
		New NotifyDescription("SaveDirectoriesDirectoryStartChoiceOnEnd", ThisObject,
		NotificationAdditionalParameters));
EndProcedure

&AtClient
Procedure InfobaseDirectoryStartChoice(Item, ChoiceData, StandardProcessing)
	FileDescription = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	FileDescription.FileName = InfobaseDirectory;
	
	UT_CommonClient.FormFieldFileNameStartChoice(FileDescription, Item, ChoiceData, StandardProcessing,
		FileDialogMode.ChooseDirectory,
		New NotifyDescription("SaveDirectoriesDirectoryStartChoiceOnEnd", ThisObject));
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure SelectCommonSaveDirectory(Command)
	FD = New FileDialog(FileDialogMode.ChooseDirectory);
	FD.Multiselect = False;
	FD.Show(New NotifyDescription("SelectCommonSaveDirectoryOnEnd", ThisObject));
EndProcedure

&AtClient
Procedure SetChecks(Command)
	For Each Row In SaveDirectories Do
		Row.Check = True;
	EndDo;
EndProcedure

&AtClient
Procedure UnsetChecks(Command)
	For Each Row In SaveDirectories Do
		Row.Check = False;
	EndDo;	
EndProcedure

&AtClient
Procedure UnloadSourceModules(Command)
	If Not CheckFilling() Then
		Return;
	EndIf;
	
	SourceDirectories= New Array();
	
	For Each Row In SaveDirectories Do
		If Not Row.Check Then
			Continue;
		EndIf;
		
		SourceDescription = New Structure;
		SourceDescription.Insert("Source", Row.Src);
		SourceDescription.Insert("Directory", Row.Directory);
		SourceDescription.Insert("OnlyModules", Row.OnlyModules);
		
		SourceDirectories.Add(SourceDescription);
	EndDo;
	
	SaveSettings = New Structure;
	SaveSettings.Insert("PlatformLaunchFile", PlatformLaunchFile);
	SaveSettings.Insert("User", User);
	SaveSettings.Insert("Password", Password);
	SaveSettings.Insert("SourceDirectories", SourceDirectories);
	SaveSettings.Insert("InfobasePlacement", InfobasePlacement);
	If InfobasePlacement = 0 Then
		SaveSettings.Insert("InfobaseDirectory", InfobaseDirectory);
	Else
		SaveSettings.Insert("InfobaseServer", InfobaseServer);
		SaveSettings.Insert("InfoBaseName", InfoBaseName);
	EndIf;
	
	Close(SaveSettings);
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure SetVisibleAndEnabled()
	If InfobasePlacement = 0 Then
		NewPage = Items.GroupFileInfobase;
	Else
		NewPage = Items.GroupServerInfoBase;
	EndIf;
	
	Items.GroupPagesInfobasePlacement.CurrentPage = NewPage;
EndProcedure

&AtClient
Procedure PlatformLaunchFileStartChoiceOnEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	If Result.Count() = 0  Then
		Return;
	EndIf;
	
	PlatformLaunchFile = Result[0];
EndProcedure

&AtClient
Procedure SelectCommonSaveDirectoryOnEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	If Result.Count()=0 Then
		Return;
	EndIf;
	
	CommonSaveDirectory = Result[0];
	
	For Each CurrentRow In SaveDirectories Do
//		If ValueIsFilled(CurrentRow.Directory) Then
//			Continue;
//		EndIf;
//		
		CurrentRow.Directory = CommonSaveDirectory + GetPathSeparator() + CurrentRow.Source;
	EndDo;
	
EndProcedure

&AtClient
Procedure SaveDirectoriesDirectoryStartChoiceOnEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	If Result.Count()=0 Then
		Return;
	EndIf;
	
	CurrentData = SaveDirectories.FindByID(AdditionalParameters.CurrentLine);
	CurrentData.Directory = Result[0];
	
	Modified = True;
EndProcedure

&AtClient
Procedure InfobaseDirectoryStartChoiceOnEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	
	If Result.Count() = 0  Then
		Return;
	EndIf;
	
	InfobaseDirectory = Result[0];
	
EndProcedure
#EndRegion