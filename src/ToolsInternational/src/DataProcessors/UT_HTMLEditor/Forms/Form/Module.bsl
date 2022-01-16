&AtClient
Var FormCloseConfirmed;

&AtClient
Var SavedEditorsValues;

#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	UT_CodeEditorServer.FormOnCreateAtServer(ThisObject, "Ace");
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "BODY", Items.BODYEditor, "html");
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "CSS", Items.CSSEditor, "css");
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "HEAD", Items.HEADEditor, "html");
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "JS", Items.JSEditor, "javascript");
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "HTML", Items.GeneratedHTMLEditor, "html");
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "LIBRARY", Items.LibraryEditor, "javascript");
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "COMPLETE", Items.DocumentCompleteEventEditor);
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "CLICK", Items.OnClickEventEditor);

	GeneratedHTMLConsoleOutput = GeneratedHTMLConsoleText();
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);
	
EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, WarningText, StandardProcessing)
	If Not FormCloseConfirmed Then
		Cancel = True;
	EndIf;
EndProcedure

&AtClient
Procedure GeneratedHTMLPagesGroupOnCurrentPageChange(Item, CurrentPage)
	
	If CurrentPage = Items.ConsolePageGroup Then
		UpdateResultConsoleOutput();
	EndIf;
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	SavedEditorsValues = New Structure;
	SavedEditorsValues.Insert("GeneratedHTMLEditor", "");
	SavedEditorsValues.Insert("BODYEditor", "");
	SavedEditorsValues.Insert("HEADEditor", "");
	SavedEditorsValues.Insert("CSSEditor", "");
	SavedEditorsValues.Insert("JSEditor", "");
	SavedEditorsValues.Insert("DocumentCompleteEventEditor", "");
	SavedEditorsValues.Insert("OnClickEventEditor", "");
	
	UT_CodeEditorClient.FormOnOpen(ThisObject, New NotifyDescription("OnOpenComplete", ThisObject));
	
EndProcedure

#EndRegion

#Region FormItemsEvents

&AtClient
Procedure BODYEditorDocumentComplete(Item)
	SetEditorTextFromSavedValues(Item);
EndProcedure

&AtClient
Procedure HEADEditorDocumentComplete(Item)
	SetEditorTextFromSavedValues(Item);
EndProcedure

&AtClient
Procedure CSSEditorDocumentComplete(Item)
	SetEditorTextFromSavedValues(Item);
EndProcedure

&AtClient
Procedure JSEditorDocumentComplete(Item)
	SetEditorTextFromSavedValues(Item);
EndProcedure

&AtClient
Procedure GeneratedHTMLEditorDocumentComplete(Item)
	SetEditorTextFromSavedValues(Item);
EndProcedure

&AtClient
Procedure EventHandlerDocumentCompleteDocumentComplete(Item)
	SetEditorTextFromSavedValues(Item);
EndProcedure

&AtClient
Procedure EventHandlerOnClickDocumentComplete(Item)
	SetEditorTextFromSavedValues(Item);
EndProcedure

&AtClient
Procedure GeneratedHTMLOnClick(Item, EventData, StandardProcessing)
	
	AlgoText = EditorItemText(Items.OnClickEventEditor);
	Try
		Execute (AlgoText);
	Except
		ErrorDesc = ErrorDescription();
		Message(ErrorDesc);
	EndTry;
	
EndProcedure

&AtClient
Procedure GeneratedHTMLDocumentComplete(Item)
	
	AlgoText = EditorItemText(Items.DocumentCompleteEventEditor);
	Try
		Execute (AlgoText);
	Except
		ErrorDesc = ErrorDescription();
		Message(ErrorDesc);
	EndTry;
	
EndProcedure


&AtClient
Procedure LinkedLibrariesOnActivateRow(Item)
	
	CurrentData = Items.LinkedLibraries.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	File = New File(CurrentData.Path);
	If Lower(File.Extension) <> ".css" Then
		LibraryEditor = UT_CodeEditorClient.ИмяФайлаРедактораAceДляЯзыка("css");
	Else
		LibraryEditor = UT_CodeEditorClient.ИмяФайлаРедактораAceДляЯзыка("javascript");
	EndIf;

	AttachIdleHandler("SetupLibraryEditorText", 1, True);
	
EndProcedure

&AtClient
Procedure LinkedLibrariesPathStartChoice(Item, ChoiceData, StandardProcessing)
	
	StandardProcessing = False;

	CurrentData = Items.LinkedLibraries.CurrentData;

	FileChooseDialog = New FileDialog(FileDialogMode.Open);
	FileChooseDialog.Filter = "*.*|*.*";
	FileChooseDialog.Preview = False; 
	FileChooseDialog.CheckFileExist = True;
	FileChooseDialog.Show(New NotifyDescription("LinkedLibrarySelection", ThisForm,
		New Structure("CurrentData", CurrentData)));
		
EndProcedure

&AtClient
Procedure HEADEditorTitleCollapseClick(Item)
	ToggleEditorVisibility(Items.HEADEditor);
EndProcedure

&AtClient
Procedure BODYEditorTitleCollapseClick(Item)
	ToggleEditorVisibility(Items.BODYEditor);
EndProcedure

&AtClient
Procedure CSSEditorTitleCollapseClick(Item)
	ToggleEditorVisibility(Items.CSSEditor);
EndProcedure

&AtClient
Procedure JSEditorTitleCollapseClick(Item)
	ToggleEditorVisibility(Items.JSEditor);
EndProcedure

#EndRegion

#Region FormCommandsEvents

&AtClient
Procedure UpdateGeneratedHTML(Command)
	
	If Items.HTMLEditorPagesGroup.CurrentPage
		= Items.EditorModeAllPagesGroup Then

		CSSText = EditorItemText(Items.CSSEditor);
		If ValueIsFilled(CSSText) Then
			CSSText="
					 |<style type=""text/css"">
					 |" + CSSText + "
									 |</style>";
		EndIf;

		JSText = EditorItemText(Items.JSEditor);
		If ValueIsFilled(JSText) Then
			JSText="
					|<script>
					| " + JSText + "
									|</script>";
		EndIf;

		HTML=
		"<!DOCTYPE html>
		|<html lang=""ru"">";

		HEADText = EditorItemText(Items.HEADEditor);
		HEADText = StrReplace(HEADText, "<head>", "");
		HEADText = StrReplace(HEADText, "</head>", "");

		If StrFind(Lower(HEADText), "<head") = 0 Then
			HTML = HTML + "
						  |<head>";
		EndIf;

		If ValueIsFilled(HEADText) Then
			HTML = HTML + "
						  |
						  |" + TrimAll(HEADText);
		EndIf;
		
		For Each LibraryRow In LinkedLibraries Do
			File = New File(LibraryRow.Path);
			If Lower(File.Extension) = ".css" Then
				HTML = HTML + "
							|<link rel=""stylesheet"" href=""" + LibraryRow.Path + """ "
					+ LibraryRow.AdditionalParameters + " >";
			Else
				HTML = HTML + "
							|<script src=""" + LibraryRow.Path + """ type=""text/javascript"" charset=""utf-8"" "
					+ LibraryRow.AdditionalParameters + "></script>";
			EndIf;
		EndDo;

		If Not BodyIncludesCSSText Then
			HTML=HTML + CSSText;
		EndIf;
		If Not BodyIncludesJSText Then
			HTML=HTML + JSText;
		EndIf;

		If StrFind(Lower(HEADText), "</head") = 0 Then
			HTML = HTML + "
						  |
						  |</head>";
		EndIf;

		BODYText = EditorItemText(Items.BODYEditor);
		BODYText = StrReplace(BODYText, "<body>", "");
		BODYText = StrReplace(BODYText, "</body>", "");

		If StrFind(Lower(BODYText), "<body") = 0 Then
			HTML = HTML + "
						  |
						  |<body>";
		EndIf;

		If ValueIsFilled(BODYText) Then
			HTML = HTML + "
						| " + BODYText;
		EndIf;

		If BodyIncludesCSSText Then
			HTML = HTML + CSSText;
		EndIf;
		If BodyIncludesJSText Then
			HTML = HTML + JSText;
		EndIf;
		If StrFind(Lower(BODYText), "</body") = 0 Then
			HTML = HTML + "
						  |</body>";
		EndIf;
		HTML = HTML + "
					|</html>";

		GeneratedHTML=HTML;
		SetEditorText(Items.GeneratedHTMLEditor, GeneratedHTML);
		SetupConsoleSupportIntoHTML(GeneratedHTML);

	Else
		HTML=EditorItemText(Items.GeneratedHTMLEditor);

		SetupConsoleSupportIntoHTML(HTML);
		GeneratedHTML=HTML;
	EndIf;
	
EndProcedure

&AtClient
Procedure LibrarySampleBootstrap4(Command)
	AddLinkedLibrary("https://stackpath.bootstrapcdn.com/bootstrap/latest/css/bootstrap.min.css",
		"integrity=""sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh"" crossorigin=""anonymous""");
	AddLinkedLibrary("https://code.jquery.com/jquery-latest.min.js",
		"integrity=""sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n"" crossorigin=""anonymous""");
	AddLinkedLibrary("https://cdn.jsdelivr.net/npm/popper.js/dist/umd/popper.min.js",
		"integrity=""sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo"" crossorigin=""anonymous""");
	AddLinkedLibrary("https://stackpath.bootstrapcdn.com/bootstrap/latest/js/bootstrap.min.js",
		"integrity=""sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6"" crossorigin=""anonymous""");
EndProcedure

&AtClient
Procedure LibrarySampleJQuery(Command)
	AddLinkedLibrary("https://code.jquery.com/jquery-latest.min.js",
		"integrity=""sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n"" crossorigin=""anonymous""");
EndProcedure

&AtClient
Procedure LibrarySampleFontAwesome(Command)
	AddLinkedLibrary(
		"https://stackpath.bootstrapcdn.com/font-awesome/latest/css/font-awesome.min.css", "");
EndProcedure

&AtClient
Procedure LibrarySamplePoperJS(Command)
	AddLinkedLibrary("https://unpkg.com/@popperjs/core@2", "");
EndProcedure

&AtClient
Procedure LibrarySampleResetCSS(Command)
	AddLinkedLibrary("https://unpkg.com/reset-css/reset.css", "");
EndProcedure

&AtClient
Procedure LibrarySampleAnimateCSS(Command)
	AddLinkedLibrary("https://cdn.jsdelivr.net/npm/animate.css/animate.min.css", "");
EndProcedure

&AtClient
Procedure LibrarySampleSocketIO(Command)
	AddLinkedLibrary("https://cdn.jsdelivr.net/npm/socket.io-client/dist/socket.io.js", "");
EndProcedure

&AtClient
Procedure UpdateConsoleOutput(Command)
	UpdateResultConsoleOutput();
EndProcedure

&AtClient
Procedure CollapseExpandViewportToForm(Command)
	
	ViewportScaledToForm = Not ViewportScaledToForm;

	If ViewportScaledToForm Then
		Items.GeneratedHTMLPagesGroup.CurrentPage = Items.GeneratedHTMLPresentationGroup;
		Items.GeneratedHTMLPagesGroup.PagesRepresentation = FormPagesRepresentation.None;

		SavedEditorsValues.GeneratedHTMLEditor= EditorItemText(
			Items.GeneratedHTMLEditor);
		SavedEditorsValues.BODYEditor=EditorItemText(Items.BODYEditor);
		SavedEditorsValues.HEADEditor= EditorItemText(Items.HEADEditor);
		SavedEditorsValues.CSSEditor= EditorItemText(Items.CSSEditor);
		SavedEditorsValues.JSEditor= EditorItemText(Items.JSEditor);
		SavedEditorsValues.DocumentCompleteEventEditor= EditorItemText(
			Items.DocumentCompleteEventEditor);
		SavedEditorsValues.OnClickEventEditor= EditorItemText(
			Items.OnClickEventEditor);
	Else
		Items.GeneratedHTMLPagesGroup.PagesRepresentation = FormPagesRepresentation.TabsOnTop;
		AttachIdleHandler("SetupEditorsTexts", 0.1, True);
	EndIf;

	Items.HTMLEditorPagesGroup.Visible = Not ViewportScaledToForm;

EndProcedure

&AtClient
Procedure SaveLibrary(Command)
	
	CurrentData = Items.LinkedLibraries.CurrentData;
	
	TextWriter = New TextWriter(CurrentData.Path);
	TextWriter.Write(EditorItemText(Items.LibraryEditor));
	TextWriter.Close();
	
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region ToolsStandardProcedures

&AtClient
Procedure SetupConsoleSupportIntoHTML(HTML)
	
	If Not UseConsole Then
		Return;
	EndIf;
	
	HeaderStartPosition = StrFind(Lower(HTML), "<head>");
	If HeaderStartPosition = 0 Then
		Return;
	EndIf;
	
	NewText = Left(HTML, HeaderStartPosition + 5);
	NewText = NewText + ConsoleSupportJSScript();
	NewText = NewText + Mid(HTML, HeaderStartPosition + 6);

	HTML = NewText;
	
EndProcedure

&AtClient
Function ConsoleSupportJSScript()
	
	Text =
	"<script type=""text/javascript"" charset=""utf-8"">
	|	console.output = []; // Take what U want 
	|	console.log = (function(log) {
	|		return function() {
	|			log.apply(console, arguments);
	|			console.output.push(arguments);
	|		}
	|	}(console.log));
	|
	|	function my__consoleOutput__string(){
	|		return JSON.stringify(console.output);
	|	}
	|</script>";
	
	Return Text;
	
EndFunction

&AtClient
Function SavedFileDescriptionStructure()
	
	Structure = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	Structure.ИмяФайла=ToolDataFileName;
	
//	UT_CommonClient.AddFormatToSavingFileDescription(Structure, "Данные редактора HTML(*.bslhtml)", "bslhtml");
	UT_CommonClient.AddFormatToSavingFileDescription(Structure, "Файл HTML(*.html)", "html");
	Return Structure;
	
EndFunction

&AtClient
Procedure OpenFile(Command)
	
	UT_CommonClient.ReadConsoleFromFile("РедактовHTML", SavedFileDescriptionStructure(),
		New NotifyDescription("OpenFileComplete", ThisObject));
		
EndProcedure

&AtClient
Procedure OpenFileComplete(Result, AdditionalParams) Export
	
	If Result = Undefined Then
		Return;
	EndIf;

	Modified = False;
	ToolDataFileName = Result.ИмяФайла;

	FileData = GetFromTempStorage(Result.Адрес);

	Text = New TextDocument;
	Text.BeginReading(New NotifyDescription("OpenFileTextReadingComplete", ThisForm, 
		New Structure("Text", Text)), FileData.OpenStreamForRead());
	 
EndProcedure

&AtClient
Procedure OpenFileTextReadingComplete(AdditionalParams) Export
	
	Text = AdditionalParams.Text;
	
	
	SetEditorText(Items.CSSEditor, "");
	SetEditorText(Items.BODYEditor, "");
	SetEditorText(Items.HEADEditor, "");
	SetEditorText(Items.JSEditor, "");
	SetEditorText(Items.GeneratedHTMLEditor, Text.GetText());
	
	GeneratedHTML="";
	
	SetupTitle();
	
	Items.HTMLEditorPagesGroup.CurrentPage = Items.GeneratedHTMLTextGroup; 
	UpdateGeneratedHTML(Undefined);

EndProcedure

&AtClient
Procedure SaveFile(Command)
	
	SaveFileOnDisk();
	
EndProcedure

&AtClient
Procedure SaveFileAs(Command)
	
	SaveFileOnDisk(True);
	
EndProcedure

&AtClient
Procedure SaveFileOnDisk(SaveAs = False)
	
	UT_CommonClient.SaveConsoleDataToFile("РедакторHTML", SaveAs,
		SavedFileDescriptionStructure(), EditorItemText(Items.GeneratedHTMLEditor),
		New NotifyDescription("SaveFileComplete", ThisObject));
		
EndProcedure

&AtClient
Procedure SaveFileComplete(SaveFileName, AdditionalParams) Export
	
	If SaveFileName = Undefined Then
		Return;
	EndIf;

	If Not ValueIsFilled(SaveFileName) Тогда
		Return;
	EndIf;

	Modified = False;
	ToolDataFileName = SaveFileName;
	SetupTitle();
	
EndProcedure

&AtClient
Procedure CreateNewFile(Command)
	
	ToolDataFileName="";

	SetEditorText(Items.CSSEditor, "");
	SetEditorText(Items.HEADEditor, "");
	SetEditorText(Items.BODYEditor, "");
	SetEditorText(Items.JSEditor, "");
	SetEditorText(Items.GeneratedHTMLEditor, "");

	LinkedLibraries.Очистить();

	SetupTitle();
	
EndProcedure

&AtClient
Procedure CloseTool(Command)
	
	ShowQueryBox(New NotifyDescription("CloseToolComplete", ThisForm), NStr("ru = 'Выйти из редактора?'; en = 'Exit editor?'"),
		QuestionDialogMode.YesNo);
		
EndProcedure

&AtClient
Procedure CloseToolComplete(Result, AdditionalParams) Export

	If Result = DialogReturnCode.Yes Then
		FormCloseConfirmed = True;
		ThisForm.Close();
	EndIf;

EndProcedure

&AtClient
Procedure SetupTitle()
	
	ThisObject.Title = ToolDataFileName;
	
EndProcedure

#EndRegion

#Region UtilizationProceduresAndFunctions

&AtClient
Procedure Подключаемый_ПолеРедактораДокументСформирован(Item)
	UT_CodeEditorClient.HTMLEditorFieldDocumentGenerated(ThisObject, Item);
EndProcedure

&AtClient
Procedure Подключаемый_ПолеРедактораПриНажатии(Item, EventData, StandardProcessing)
	UT_CodeEditorClient.HTMLEditorFieldOnClick(ThisObject, Item, EventData, StandardProcessing);
EndProcedure

//@skip-warning
&AtClient
Procedure Attached_CodeEditorDeferredInitializingEditors()
	UT_CodeEditorClient.CodeEditorDeferredInitializingEditors(ThisObject);
EndProcedure

&AtClient 
Procedure Attachable_CodeEditorInitializingCompletion() Export
	
EndProcedure


&AtClient
Procedure OnOpenComplete(Result, AdditionalParams) Export

EndProcedure

&AtClient
Procedure UpdateResultConsoleOutput()
	
	Try
		DocumentResultView=Items.GeneratedHTML.Document.defaultView;

		DocView=Items.GeneratedHTMLConsoleOutput.Document.defaultView;
		DocView.clearConsole();
		DocView.outputInfo(DocumentResultView.my__consoleOutput__string());
	Except
	EndTry;
	
EndProcedure

&AtServer
Function GeneratedHTMLConsoleText()
	
	Text =
	"<!DOCTYPE html>
	|<html>
	|    <head>
	|        <meta http-equiv=""content-type"" content=""text/html; charset=utf-8"" />
	|        <script type=""text/javascript"" src=""https://unpkg.com/html-console-output""></script>    
	|    </head>
	|    <body>
	|        <script type=""text/javascript"" charset=""utf-8"">
	|        	function clearConsole(){
	|				//document.body.innerHTML = "";
	|				var elems=document.getElementsByClassName('console-block');
	|				if (elems.length>0){
	|					elems[0].innerHTML='';
	|				}
	|			}
	|
	|			function outputInfo(info) {
	|				var objectInfo=JSON.parse(info);
	|				objectInfo.forEach(function(item, i, arr) {
	|					if (typeof item =='object') {
	|						var args=[]
	|						
	|						for (var key in item) {
	|							args.push(item[key]);
	|						}
	|						console.log.apply(console, args)
	|					} else {
	|						console.log(item)
	|					}
	|				});
	|			}
	|        </script>
	|    </body>
	|</html>";

	Return Text;
	
EndFunction

&AtClient
Function EditorItemText(EditorItemField)
	
	If Not EditorItemField.Visible Then
		Return SavedEditorsValues[EditorItemField.Name];
	Else
		Return UT_CodeEditorClient.ТекстКодаРедактораЭлементаФормы(ThisObject, EditorItemField);
	EndIf;
	
EndFunction

&AtClient
Procedure SetEditorText(EditorItem, SetupText)
	
	UT_CodeEditorClient.УстановитьТекстРедактораЭлементаФормы(ThisObject, EditorItem, SetupText);
	
EndProcedure

&AtClient
Procedure AddLinkedLibrary(Path, AdditionalParameters)
	
	Rec 						= LinkedLibraries.Add();
	Rec.Path					= Path;
	Rec.AdditionalParameters	= AdditionalParameters;
	
EndProcedure

&AtClient
Procedure SetEditorTextFromSavedValues(EditorItem)
	
	If TypeOf(SavedEditorsValues) <> Type("Structure") Then
		Return;
	EndIf;

	If Not SavedEditorsValues.Property(EditorItem.Name) Then
		Return;
	Endif;
	
	If Not ValueIsFilled(SavedEditorsValues[EditorItem.Name]) Then
		Return;
	EndIf;

	SetEditorText(EditorItem, SavedEditorsValues[EditorItem.Name]);
	
EndProcedure

&AtClient
Procedure SetupLibraryEditorText()
	
	CurrentData = Items.LinkedLibraries.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	If Not ValueIsFilled(CurrentData.Path) Then
		Return;
	EndIf;
	
	FileReading = New TextReader(CurrentData.Path);
	LibraryEditorText = FileReading.Read();
	FileReading.Close();
	
	SetEditorText(Items.LibraryEditor, LibraryEditorText);
	
EndProcedure

&AtClient
Procedure LinkedLibrarySelection(SelectedFiles, AdditionalParams) Export
	
	If SelectedFiles = Undefined Then
		Return;
	EndIf;
	AdditionalParams.CurrentData.Path = SelectedFiles[0];
	
EndProcedure

&AtClient
Procedure ToggleEditorVisibility(EditorItem)
	
	If EditorItem.Visible Then
		SavedEditorsValues[EditorItem.Name] = EditorItemText(EditorItem);
	Else
		SavedEditorText = EditorItemText(EditorItem);		
	EndIf;

	EditorItem.Visible = Not EditorItem.Visible;
	
	If EditorItem.Visible Then
		CurrentEditorName = EditorItem.Name;
		AttachIdleHandler("SetupEditorTextForCurrentEditor", 0.1, True);
	EndIf;	
	
EndProcedure

&AtClient 
Procedure SetupEditorTextForCurrentEditor()
	
	If ValueIsFilled(CurrentEditorName) And ValueIsFilled(SavedEditorText) Then
		SetEditorText(Items[CurrentEditorName], SavedEditorText);
		CurrentEditorName = "";
		SavedEditorText = "";
		DetachIdleHandler("SetupEditorTextForCurrentEditor");
	EndIf;	
		
EndProcedure

//append
&AtClient
Procedure SetupEditorsTexts()
	
	SetEditorText(Items.GeneratedHTMLEditor, 			SavedEditorsValues.GeneratedHTMLEditor);	
	SetEditorText(Items.BODYEditor, 					SavedEditorsValues.BODYEditor);	
	SetEditorText(Items.HEADEditor, 					SavedEditorsValues.HEADEditor);	
	SetEditorText(Items.CSSEditor, 						SavedEditorsValues.CSSEditor);	
	SetEditorText(Items.JSEditor, 						SavedEditorsValues.JSEditor);	
	SetEditorText(Items.DocumentCompleteEventEditor, 	SavedEditorsValues.DocumentCompleteEventEditor);	
	SetEditorText(Items.OnClickEventEditor, 			SavedEditorsValues.OnClickEventEditor);	
	DetachIdleHandler("SetupEditorsTexts");	
		
EndProcedure	
	

#EndRegion

FormCloseConfirmed = False;