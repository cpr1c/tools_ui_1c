// Storage of global variables.
//
// ApplicationParameters - Map - value storage, where:
//   * Key - String - a variable name in the format of  "LibraryName.VariableName";
//   * Value - Arbitrary - a variable value.
//
// Initialization (see the example of MessagesForEventLog):
//   ParameterName = "StandardSubsystems.MessagesForEventLog";
//   If ApplicationParameters[ParameterName] = Undefined Then
//     ApplicationParameters.Insert(ParameterName, New ValueList);
//   EndIf.
//  
// Usage (as illustrated by MessagesForEventLog):
//   ApplicationParameters["StandardSubsystems.MessagesForEventLog"].Add(...);
//   ApplicationParameters["StandardSubsystems.MessagesForEventLog"] = ...;
&AtClient
Var UT_ApplicationParameters_Portable Export;


&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	DataProcessorObject=FormAttributeToValue("Object");

	File=New File (DataProcessorObject.UsedFileName);
	ToolsDirectory=File.Path;
    CreateToolsOpenCommandsOnForm();

	Title=Version();

	AlgorithmForCallingDebuggingAtServer="ExternalDataProcessors.Create(""UT_"")._Debug(DebugSettings)";
	AlgorithmForCallingDebuggingAtClient="GetForm(""ExternalDataProcessor.UT_.Form"")._Debug(DebugSettings)";
	AlgorithmForCallingDebuggingThroughDataProcessor="ExternalDataProcessors.Create(""" + DataProcessorObject.UsedFileName
		+ """, False)._Debug(Query)";
EndProcedure


&AtClient
Procedure OnOpen(Cancel)
	ConnectExternalModules();
EndProcedure

&AtClient
Procedure OnClose(Exit)
		UT_CommonClient.OnExit();
EndProcedure

&AtClientAtServerNoContext
Function ToolItemTitle(Name, Synonym, SearchText = "")
	Title=Synonym;
	If Not ValueIsFilled(Title) Then
		Title=Name;
	EndIf;

	Если ValueIsFilled(SearchText) Then
		OriginalTitle=Title;
		SearchTitle=Lower(OriginalTitle);
		NewTitle="";
		SearchStringLength=StrLen(SearchText);

		CharPosition=StrFind(SearchTitle, SearchText);
		While CharPosition > 0 Do
			FormattedSearchString=New FormattedString(Mid(OriginalTitle, CharPosition,
				SearchStringLength), New Font(, , , True), WebColors.Red);
			NewTitle=New FormattedString(NewTitle, Left(OriginalTitle, CharPosition - 1),
				FormattedSearchString);

			OriginalTitle=Mid(OriginalTitle, CharPosition + SearchStringLength);
			SearchTitle=Lower(OriginalTitle);

			CharPosition=StrFind(SearchTitle, SearchText);

		EndDo;

		If ValueIsFilled(NewTitle) Then
			NewTitle=New FormattedString(NewTitle, OriginalTitle);
			Title=NewTitle;
		Endif;
	EndIf;
	Return Title;
EndFunction
&AtClient
Procedure ProcessSearch(InputSearchString)
	SortedLust=SortedModulesListToolsForButtons();

	Search=TrimAll(Lower(InputSearchString));

	For Each ToolsListItem In SortedLust Do
		ItemVisibility=True;
		If ValueIsFilled(Search) Then
			ItemVisibility=StrFind(Lower(ToolsListItem.Value), Search) > 0 Or StrFind(
				Lower(ToolsListItem.Presentation), Search) > 0;
		Endif;

		Items[ToolsListItem.Value].Visible=ItemVisibility;
		Items[ToolsListItem.Value].Title=ToolItemTitle(
			ToolsListItem.Value, ToolsListItem.Presentation, Search);
	EndDo;

EndProcedure
&AtClient
Procedure SeacrhStringClearing(Item, StandardProcessing)
	ProcessSearch("");
EndProcedure

&AtClient
Procedure SeacrhStringEditTextChange(Item, Text, StandardProcessing)
	SearchString = Text;
	ProcessSearch(Text);
EndProcedure

&AtClient
Procedure Attachable_OpenToolsCommand(Command)
	ModulesDescription=ToolsModulesDescriptionForConnect();
	ModuleDescription=ModulesDescription[Command.Name];

	If ModuleDescription.MetadataType = "Report" Then
		OpenForm("ExternalReport." + Command.Name + ".Form", , ThisForm);
	Else
		OpenForm("ExternalDataProcessor." + Command.Name + ".Form", , ThisForm);
	EndIf;
EndProcedure

&AtServer
Procedure CreateToolsOpenCommandsOnForm()
	ToolsDescription=SortedModulesListToolsForButtons();
	ModulesDescription=ToolsModulesDescriptionForConnect();

	Even=False;
	For each ListItem In ToolsDescription Do
		Description=ModulesDescription[ListItem.Value];

		If Description.NotShowInUserInterface Then
			Continue;
		EndIf;

		If Even Then
			Parent=Items.GroupToolsCommandsRigth;
		Else
			Parent=Items.GroupToolsCommandsLeft;
		Endif;

		Item=Items.Add(Description.Name, Type("FormDecoration"), Parent);
		//Item.CommandName=Description.Name;
		Item.Title=ToolItemTitle(Description.Name, Description.Synonym);
		Item.Type=FormDecorationType.Label;
		Item.Hyperlink=True;
		Item.ToolTip=Description.ToolTip;
		Item.ToolTipRepresentation=ToolTipRepresentation.ShowBottom;
		Item.SetAction("Click", "Attachable_OpenToolsCommand");

		Even=Not Even;
	EndDo;
EndProcedure

&AtClient
Procedure UT_Settings(Command)
	OpenForm("CommonForm.UT_Settings");
EndProcedure

&AtClient
Procedure AskQuestionToDeveloper(Command)
	UT_CommonClient.AskQuestionToDeveloper();
EndProcedure

&AtClient
Procedure OpenAboutPage(Command)
	UT_CommonClient.OpenAboutPage();
EndProcedure

&AtClient
Procedure PortableToolsDebugSpecificity(Command)
	UT_CommonClient.OpenPortableToolsDebugSpecificityPage();
EndProcedure

&AtClient
Procedure RunToolsUpdateCheck(Command)
	UT_CommonClient.RunToolsUpdateCheck();
EndProcedure

&AtClientAtServerNoContext
Function ModuleDesciptionNew() Export
	Desciption=New Structure;
	Desciption.Insert("Name", "");
	Desciption.Insert("Synonym", "");
	Desciption.Insert("FileName", "");
	Desciption.Insert("ToolTip", "");
	Desciption.Insert("NotShowInUserInterface", False);
	Desciption.Insert("Type", "Tool");
	Desciption.Insert("MetadataType", "DataProcessor");
	Desciption.Insert("Commands", Undefined);

	Return Desciption;
EndFunction

&AtClientAtServerNoContext
Function ToolsModulesDescriptionForConnect()
	Descriptions=New Structure;
	
// METHOD GENERATED IN BUILDING PROCESS
	
//	ToolDescription=ModuleDesciptionNew();
//	ToolDescription.Name="UT_DCSEditor";
//	Descriptions.Insert(ToolDescription.Name,ToolDescription);
//	
//	ToolDescription=ModuleDesciptionNew();
//	ToolDescription.Name="UT_ReportsConsole";
//	ToolDescription.MetadataType="Report";
//	Descriptions.Insert(ToolDescription.Name,ToolDescription);
//	
//	ToolDescription=ModuleDesciptionNew();
//	ToolDescription.Name="UT_ClipboardClient";
//	ToolDescription.Type="CommonModule";
//	Descriptions.Insert(ToolDescription.Name,ToolDescription);
//	
//	ToolDescription=ModuleDesciptionNew();
//	ToolDescription.Name="UT_CommonClient";
//	ToolDescription.Type="CommonModule";
//	Descriptions.Insert(ToolDescription.Name,ToolDescription);
//	
//	ToolDescription=ModuleDesciptionNew();
//	
//	ToolDescription.Name="UT_CommonClientServer";
//	ToolDescription.Type="CommonModule";
//	Descriptions.Insert(ToolDescription.Name,ToolDescription);
//	
//	ToolDescription=ModuleDesciptionNew();
//	ToolDescription.Name="UT_CommonClientServer";
//	ToolDescription.Type="CommonModule";
//	Descriptions.Insert(ToolDescription.Name,ToolDescription);

	Return Descriptions;
EndFunction

&AtClientAtServerNoContext
Function SortedModulesListToolsForButtons()
	ModulesDescription=ToolsModulesDescriptionForConnect();

	ModulesList=New ValueList;

	For Each KeyValue In ModulesDescription Do
		Description=KeyValue.Value;
		If Description.Type <> "Tool" Then
			Continue;
		EndIf;
		If Description.NotShowInUserInterface Then
			Continue;
		Endif;

		ModulesList.Add(Description.Name, Description.Synonym);
	EndDo;

	ModulesList.SortByPresentation();
	Return ModulesList;
EndFunction

&AtClient
Function ModuleFileName(ModuleDescription)
	If ModuleDescription.Type = "CommonModule" Then
		ModuleDirectory="CommonModules";
	ElsIf ModuleDescription.Type = "CommonPicture" Then
		Return ToolsDirectory + GetPathSeparator() + "Pictures" + GetPathSeparator()
			+ ModuleDescription.FileName;
	Else
		ModuleDirectory="Tools";
	EndIf;

	If ModuleDescription.MetadataType = "Report" Then
		Extension="erf";
	Else
		Extension="epf";
	EndIf;

	Return ToolsDirectory + GetPathSeparator() + ModuleDirectory + GetPathSeparator()
		+ ModuleDescription.Name + "." + Extension;
EndFunction

&AtClient
Procedure ConnectExternalModules()
	Description=ToolsModulesDescriptionForConnect();

	PuttedFiles=New Array;

	For Each KeyValue In Description Do
		CurrentToolDescription=KeyValue.Value;
		PuttedFiles.Добавить(New TransferableFileDescription(ModuleFileName(CurrentToolDescription)));
	EndDo;

	BeginPuttingFiles(New NotifyDescription("ConnectExternalModulesOnEnd", ThisForm,
		New Structure("ToolsDescription", Description)), PuttedFiles, , False, UUID);
EndProcedure

&AtClient
Procedure ConnectExternalModulesOnEnd(PuttedFiles, AdditionalParameters) Export
	If PuttedFiles = Undefined Then
		Return;
	EndIf;

	UT_PicturesLibrary=New Structure;

	ModulesForConnectAtServer=New Array;

	For each PuttedFile in PuttedFiles Do
		If PlatformVersionNotLess("8.3.13") Then
			FileName = PuttedFile.FullName;
		Else
			FileName = PuttedFile.Name;
		EndIf;

		File=New File(FileName);
		If Lower(File.Extension) = ".erf" Then
			ModulesForConnectAtServer.Add(New Structure("IsReport, Location", True, PuttedFile.Location));
		ElsIf Lower(File.Extension) = ".epf" Then
			ModulesForConnectAtServer.Add(New Structure("IsReport, Location", False, PuttedFile.Location));
		Else
			UT_PicturesLibrary.Insert(File.BaseName, New Picture(File.FullName));
			Continue;
		Endif;
	EndDo;

	ConnectExternalModulesAtServer(ModulesForConnectAtServer);
	//Now we can use common modules
	LocalPicturesLibraryURL=PutToTempStorage(UT_PicturesLibrary, UUID);
	WriteLocalPicturesLibraryURLToSettingsStorage(LocalPicturesLibraryURL);
	AttachIdleHandler("OnOpenRunHandlersOfToolsLaunch", 0.1, True);
EndProcedure

&AtServer
Procedure ConnectExternalModulesAtServer(ModulesForConnectAtServer)
	For Each ExternalModule In ModulesForConnectAtServer Do
		ConnectExternalDataProcessor(ExternalModule.Location, ExternalModule.IsReport);
	EndDo;
EndProcedure

&AtClient
Procedure OnOpenRunHandlersOfToolsLaunch()
	UT_CommonClient.OnStart();
	Items.GroupFormPages.CurrentPage=Items.GroupPageWorkWithTools;
EndProcedure

&AtServer
Function ConnectExternalDataProcessor(StorageURL, IsReport)

	UnsafeOperationProtectionDescription =New UnsafeOperationProtectionDescription;
	UnsafeOperationProtectionDescription.UnsafeOperationWarnings=False;
	If IsReport Then
		Return ExternalReports.Connect(StorageURL, , False, UnsafeOperationProtectionDescription);
	Else
		Return ExternalDataProcessors.Connect(StorageURL, , False, UnsafeOperationProtectionDescription);
	EndIf;
EndFunction

&AtServer
Procedure WriteLocalPicturesLibraryURLToSettingsStorage(URL)
	UT_Common.FormDataSettingsStorageSave(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(), "LocalPicturesLibraryURL", URL, ,
		UserName());
EndProcedure

&AtClient
Function PlatformVersionNotLess(ComparingVersion) Export
	VersionWithOutReleaseSubnumber=ConfigurationVersionWithoutBuildNumber(CurrentAppVersion());

	Return CompareVersionsWithoutBuildNumber(VersionWithOutReleaseSubnumber, ComparingVersion)>=0;
EndFunction

&AtClient
Function ConfigurationVersionWithoutBuildNumber(Val Version) Export

	Array = StrSplit(Version, ".");

	If Array.Count() < 3 Then
		Return Version;
	EndIf;

	Result = "[Edition].[Subedition].[Release]";
	Result = StrReplace(Result, "[Edition]",    Array[0]);
	Result = StrReplace(Result, "[Subedition]", Array[1]);
	Result = StrReplace(Result, "[Release]",       Array[2]);
	
	Return Result;
EndFunction

&AtClient
Function CurrentAppVersion() Export

	SystemInfo = New SystemInfo;
	Return SystemInfo.AppVersion;

EndFunction

// Compare two strings that contains version info
//
// Parameters:
//  Version1String  - String - number of version in  РР.{M|MM}.RR format
//  Version2String  - String - secound compared version number.
//
// Return Value значение:
//   Integer   - more than 0, if Version1String > Version2String; 0, if version values is equal.
//
&AtClient
Function CompareVersionsWithoutBuildNumber(Val Version1String, Val Version2String) Export

	String1 = ?(IsBlankString(Version1String), "0.0.0", Version1String);
	String2 = ?(IsBlankString(Version2String), "0.0.0", Version2String);
	Version1 = StrSplit(String1, ".");
	If Version1.Count() <> 3 Then
		Raise StrTemplate(NStr("ru = 'Неправильный формат параметра Version1String: %1'; en='Wrong format of parameter Version1String: %1'"), Version1String);
	EndIf;
	Version2 = StrSplit(String2, ".");
	If Version2.Count() <> 3 Then
		Raise StrTemplate(NStr("ru = 'Неправильный формат параметра Version2String: %1'; en='Wrong format of parameter Version2String: %1'"), Version2String);
	EndIf;

	Result = 0;
	For Digit = 0 to 2 do
		Result = Number(Version1[Digit]) - Number(Version2[Digit]);
		If Result <> 0 Then
			Return Result;
		EndIf;
	КонецЦикла;
	Return Result;

EndFunction

&AtClientAtServerNoContext
Function Version() Export

EndFunction

&AtClientAtServerNoContext
Function Vendor() Export

EndFunction



UT_ApplicationParameters_Portable = New Map;