&AtClient
Var ClosingFormConfirmed;
#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	SetLibraryAddressOnServer();

	If Parameters.Property("JSONString") Then
		EditLine=Parameters.JSONString;
		EditMode=True;
	EndIf;

	If Parameters.Property("ViewMode") Then
		EditMode=Not Parameters.ViewMode;
	EndIf;
	Items.FinishEditing.Visible=EditMode;

	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);

EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("OnOpenComplеtion", ThisObject));
EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, WarningText, StandardProcessing)
	If Not ClosingFormConfirmed Then
		Cancel = True;
		Return;
	EndIf;

	BeginDeletingFiles(New NotifyDescription("BeforeCloseDeletingFilesComplеtion", ThisForm), LibrarySavingDirectory);
EndProcedure

&AtClient
Procedure BeforeCloseDeletingFilesComplеtion(AdditionalParameters) Export
	
	

EndProcedure

#EndRegion

#Region FormItemsEvents

&AtClient
Procedure TreeEditFieldDocumentGenerated(Item)
	If ValueIsFilled(EditLine) Then
		AttachIdleHandler("IdleHandlerSetEditingLineInTreeEditor", 0.5, True);
	EndIf;
EndProcedure

&AtClient
Procedure LineEditFieldDocumentGenerated(Item)
	If ValueIsFilled(EditLine) Then
		AttachIdleHandler("IdleHandlerSetEditingLineInLineEditor", 0.1, True);
	EndIf;
EndProcedure

&AtClient
Procedure CopyFromLineToTree(Command)
	JSONString=JSONLineFromEditorField(Items.LineEditField);
	TreeLine=JSONLineFromEditorField(Items.TreeEditField);

	SetJSONIntoHTML(Items.TreeEditField, JSONString);
	If Not ValueIsFilled(TreeLine) Then
		ExpandTreeLinesJSON(Items.TreeEditField);
	EndIf;
EndProcedure

&AtClient
Procedure CopyFromTreeToLine(Command)
	JSONString=JSONLineFromEditorField(Items.TreeEditField);
	SetJSONIntoHTML(Items.LineEditField, JSONString);
EndProcedure

&AtClient
Procedure FinishEditing(Command)
	ClosingFormConfirmed=True;
	Close(JSONLineFromEditorField(Items.LineEditField));
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonToolsCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure



#EndRegion

#Region Private

&AtClient
Procedure OnOpenComplеtion(Result, AdditionalParameters) Export
	FileVarsStructure=UT_CommonClient.SessionFileVariablesStructure();
	LibrarySavingDirectory=FileVarsStructure.TempFilesDirectory + "tools_ui_1c_international"
		+ GetPathSeparator() + Format(UT_CommonClientServer.Version(), "NG=0;") + GetPathSeparator() + "jsoneditor";
	EditorFile=New File(LibrarySavingDirectory);
	EditorFile.BeginCheckingExistence(New NotifyDescription("OnOpenCheckExistLibraryCompletion", ThisForm));

EndProcedure

&AtClient
Procedure OnOpenCheckExistLibraryCompletion(Exist, AdditionalParameters) Export
	
	If Exist Then
		BeginDeletingFiles(New NotifyDescription("OnOpenCheckExistLibraryDeletionFilesCompletion", ThisForm,,"OnOpenCheckExistLibraryDeletionFilesErrorCompletion", ThisObject), LibrarySavingDirectory);
	Else
		OnOpenCheckExistLibraryCompletionFragment();
	EndIf;
	
EndProcedure

&AtClient
Procedure OnOpenCheckExistLibraryDeletionFilesCompletion(AdditionalParameters) Export
	OnOpenCheckExistLibraryCompletionFragment();
EndProcedure  

&AtClient
Procedure OnOpenCheckExistLibraryDeletionFilesErrorCompletion(AdditionalParameters) Export
	LibrarySavingDirectory=LibrarySavingDirectory + "1";
	
	BeginDeletingFiles(New NotifyDescription("OnOpenCheckExistLibraryDeletionFilesCompletion", ThisForm,,"OnOpenCheckExistLibraryDeletionFilesErrorCompletion", ThisObject), LibrarySavingDirectory);
EndProcedure  



&AtClient
Procedure OnOpenCheckExistLibraryCompletionFragment()
	
	BeginCreatingDirectory(New NotifyDescription("OnOpenCreatingDirectoryLibraryCompletion", ThisForm), LibrarySavingDirectory);

EndProcedure

&AtClient
Procedure OnOpenCreatingDirectoryLibraryCompletion(DirectoryName, AdditionalParameters) Export
	
	SaveEditorLibraryToDisk();
	SetEditorFieldHTMLText();

EndProcedure

&AtClient
Procedure IdleHandlerSetEditingLineInTreeEditor()
	Try
		SetJSONIntoHTML(Items.TreeEditField, EditLine);
		ExpandTreeLinesJSON(Items.TreeEditField);
	Except
		AttachIdleHandler("IdleHandlerSetEditingLineInTreeEditor", 0.5, True);
	EndTry;
EndProcedure

&AtClient
Procedure IdleHandlerSetEditingLineInLineEditor()
	Try
		SetJSONIntoHTML(Items.LineEditField, EditLine);
		//Formats JSON line by editor format
		SetJSONIntoHTML(Items.LineEditField, JSONLineFromEditorField(Items.LineEditField));

	Except
		AttachIdleHandler("IdleHandlerSetEditingLineInLineEditor", 0.5, True);
	EndTry;
EndProcedure

&AtClient
Procedure SetJSONIntoHTML(EditorFormField, JSONString)
	HTMLDocument=EditorFormField.Document;
	If HTMLDocument.parentWindow = Undefined Then
		DocumentSructureDOM = HTMLDocument.defaultView;
	Else
		DocumentSructureDOM = HTMLDocument.parentWindow;
	EndIf;
	DocumentSructureDOM.editor.setText(JSONString);

EndProcedure

&AtClient
Procedure ExpandTreeLinesJSON(EditorFormField)
	HTMLDocument=EditorFormField.Document;
	If HTMLDocument.parentWindow = Undefined Then
		DocumentStructureDOM = HTMLDocument.defaultView;
	Else
		DocumentStructureDOM = HTMLDocument.parentWindow;
	EndIf;
	DocumentStructureDOM.editor.expandAll();

EndProcedure

&AtClient
Function JSONLineFromEditorField(EditorFormField)
	DocumentHTML=EditorFormField.Document;
	If DocumentHTML.parentWindow = Undefined Then
		DocumentStructureDOM = DocumentHTML.defaultView;
	Else
		DocumentStructureDOM = DocumentHTML.parentWindow;
	EndIf;
//	Return DocumentStructureDOM.editor.getText();
	Return DocumentStructureDOM.getJSON();

EndFunction

&AtClient
Procedure SetEditorFieldHTMLText()
	CSSText=LibrarySavingDirectory + GetPathSeparator() + "jsoneditor.css";
	JSText=LibrarySavingDirectory + GetPathSeparator() + "jsoneditor.js";

	Template= "<!DOCTYPE HTML>
			|<html>
			|<head>
			|  <title>JSONEditor | Synchronize two editors</title>
			|
			|	<link href=""" + CSSText + """ rel=""stylesheet"" type=""text/css"">
											 |  <script src=""" + JSText + """></script>
																			|
																			|  <style type=""text/css"">
																			|    body {
																			|      font-family: sans-serif;
																			|    }
																			|
																			|   .jsoneditor {
																			|      width: 100%;
																			|      height: 100%;
																			|    }
																			|  </style>
																			|</head>
																			|<body>
																			|	<div class=""jsoneditor"" id=""jsoneditor""></div>
																			|
																			|<script>
																			|
																			|  var container = document.getElementById('jsoneditor')
																			|  var options = {
																			|    // switch between pt-BR or en for testing forcing a language
																			|    // leave blank to get language
																			|   'language': 'en',
																			|   mode: '###EditorMode###'
																			|  }
																			|  var editor = new JSONEditor(container, options)
																			|
																			|	function getJSON(){
																			|		return JSON.stringify(editor.get(), null, 2);
																			|	}
																			|
																			|
																			|</script>
																			|	<div id=""footer""></div>
																			|
																			|</body>
																			|</html>";

	SaveFileEditorHTMLFild(StrReplace(Template, "###EditorMode###", "tree"), LibrarySavingDirectory + GetPathSeparator() + "tree.html" ,"TreeEditField");
	SaveFileEditorHTMLFild(StrReplace(Template, "###EditorMode###", "code"), LibrarySavingDirectory + GetPathSeparator() + "code.html","LineEditField");
EndProcedure

&AtClient
Procedure SaveFileEditorHTMLFild(HTMLText, FileName, EditorFieldName)
	Text=New TextDocument;
	Text.SetText(HTMLText);
	
	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("HTMLText", EditorFieldName);
	AdditionalParameters.Insert("FileName", FileName);
	
	Text.BeginWriting(New NotifyDescription("SaveFileEditorHTMLFildCompletion", ThisObject, AdditionalParameters), FileName);
EndProcedure

&AtClient
Procedure SaveFileEditorHTMLFildCompletion(Result, AdditionalParameters) Export
	ThisObject[AdditionalParameters.HTMLText] = AdditionalParameters.FileName;
EndProcedure

&AtClient
Procedure SaveEditorLibraryToDisk()
	LibraryFilesMap=GetFromTempStorage(LibraryAddress);
	For Each KeyValue In LibraryFilesMap Do
		FileName=LibrarySavingDirectory + GetPathSeparator() + KeyValue.Key;

		KeyValue.Value.Write(FileName);
	EndDo;
EndProcedure

&AtServer
Procedure SetLibraryAddressOnServer()
	ObjectOfDataProcessors=FormAttributeToValue("Object");

	BinaryLibraryData=ObjectOfDataProcessors.GetTemplate("jsoneditor");

	FolderOnServer=GetTempFileName();
	CreateDirectory(FolderOnServer);

	Stream=BinaryLibraryData.OpenStreamForRead();

	ZIPReader=New ZipFileReader(Stream);
	ZIPReader.ExtractAll(FolderOnServer, ZIPRestoreFilePathsMode.Restore);

	LibraryMap =New Map;

	ArhiveFiles=FindFiles(FolderOnServer, "*", True);
	For Each LibraryFile In ArhiveFiles Do
		FileKey=StrReplace(LibraryFile.FullName, FolderOnServer + GetPathSeparator(), "");
		If LibraryFile.IsDirectory() Then
			Continue;
		EndIf;

		LibraryMap.Insert(FileKey, New BinaryData(LibraryFile.FullName));
	EndDo;

	LibraryAddress=PutToTempStorage(LibraryMap, UUID);

	Try
		DeleteFiles(FolderOnServer);
	Except
		// TODO:
	EndTry;

EndProcedure

#EndRegion

#Region StandartFunctions

&AtClient
Function StructureDescriptionSaveFile()
	Structure=UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	Structure.FileName=ToolDataFileName;

	UT_CommonClient.AddFormatToSavingFileDescription(Structure, "File JSOM(*.json)", "json");
	Return Structure;
EndFunction
&AtClient
Procedure OpenFile(Command)
	UT_CommonClient.ReadConsoleFromFile("JSONEditor", StructureDescriptionSaveFile(),
		New NotifyDescription("OpenFileComplеtion", ThisObject));
EndProcedure

&AtClient
Procedure OpenFileComplеtion(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	Modified=False;
	ToolDataFileName = Result.FileName;

	FileData=GetFromTempStorage(Result.Url);

	Text=New TextDocument;
	Text.BeginReading(New NotifyDescription("OpenFileReadingTextCopletion", ThisForm, New Structure("Text", Text)), FileData.OpenStreamForRead());
EndProcedure

&AtClient
Procedure OpenFileReadingTextCopletion(AdditionalParameters1) Export
	
	Text = AdditionalParameters1.Text;
	
	SetJSONIntoHTML(Items.LineEditField, Text.GetText());
	SetJSONIntoHTML(Items.TreeEditField, Text.GetText());
	SetTitle();

EndProcedure

&AtClient
Procedure SaveFile(Command)
	SaveFileToDisk();
EndProcedure

&AtClient
Procedure SaveFileAs(Command)
	SaveFileToDisk(True);
EndProcedure

&AtClient
Procedure SaveFileToDisk(SaveAs = False)
	UT_CommonClient.SaveConsoleDataToFile("HTMLEditor", SaveAs,
		StructureDescriptionSaveFile(), JSONLineFromEditorField(Items.LineEditField),
		New NotifyDescription("SaveFileCompletion", ThisObject));
EndProcedure

&AtClient
Procedure SaveFileCompletion(SaveFileName, AdditionalParameters) Export
	If SaveFileName = Undefined Then
		Return;
	EndIf;

	If Not ValueIsFilled(SaveFileName) Then
		Return;
	EndIf;

	Modified=False;
	ToolDataFileName=SaveFileName;
	SetTitle();
EndProcedure

&AtClient
Procedure NewFile(Command)
	ToolDataFileName="";

	SetJSONIntoHTML(Items.LineEditField, "");
	SetJSONIntoHTML(Items.TreeEditField, "");

	SetTitle();
EndProcedure

&AtClient
Procedure SetTitle()
	Title=ToolDataFileName;
EndProcedure

&AtClient
Procedure CloseTool(Command)
	ShowQueryBox(New NotifyDescription("CloseToolComplеtion", ThisForm), 
		NStr("en='Do you want to exit editor?' ; ru='Выйти из редактора?'"),
		QuestionDialogMode.YesNo);
EndProcedure

&AtClient
Procedure CloseToolComplеtion(Result, AdditionalParameters) Export

	If Result = DialogReturnCode.Yes Then
		ClosingFormConfirmed = True;
		Close();
	EndIf;

EndProcedure

#EndRegion

ClosingFormConfirmed=False;