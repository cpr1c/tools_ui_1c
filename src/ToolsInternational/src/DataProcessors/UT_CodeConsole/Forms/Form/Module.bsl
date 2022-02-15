&AtClient
Var FormCloseConfirmed;

#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	UT_CodeEditorServer.FormOnCreateAtServer(ThisObject);
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "Server", Items.FieldAlgorithmServer);
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "Client", Items.FieldAlgorithmClient);
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.MainCommandBar);
	
EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, WarningText, StandardProcessing)
	If Not FormCloseConfirmed Then
		Cancel = True;
	EndIf;
EndProcedure


&AtClient
Procedure OnOpen(Cancel)
	UT_CodeEditorClient.FormOnOpen(ThisObject, New NotifyDescription("OnOpenEnd",ThisObject));
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_EditorFieldDocumentGenerated(Item)
	UT_CodeEditorClient.HTMLEditorFieldDocumentGenerated(ThisObject, Item);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_EditorFieldOnClick(Item, EventData, StandardProcessing)
	UT_CodeEditorClient.HTMLEditorFieldOnClick(ThisObject, Item, EventData, StandardProcessing);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_CodeEditorDeferredInitializingEditors()
	UT_CodeEditorClient.CodeEditorDeferredInitializingEditors(ThisObject);
EndProcedure

&AtClient 
Procedure Attachable_CodeEditorInitializingCompletion() Export
	If ValueIsFilled(AlgorithmFileName) Then
		UT_CommonClient.ReadConsoleFromFile("CodeConsole", SavedFilesDescriptionStructure(),
			New NotifyDescription("OpenFileEnd", ThisObject), True);
	Else
		SetEditorText("Client", TextAlgorithmClient);
		SetEditorText("Server", TextAlgorithmServer);
	EndIf;
EndProcedure


#EndRegion

#Region FormCommandsEvents
&AtClient
Procedure CloseConsole(Command)
	ShowQueryBox(New NotifyDescription("CloseConsoleEnd", ThisForm),NStr("ru = 'Выйти из консоли кода?';en = 'Exit code console ?'"),
		QuestionDialogMode.YesNo);
EndProcedure

&AtClient
Procedure ExecuteCode(Command)
	//.1 Need to update the values of these algorithms
	UpdateAlgorithmVariablesValueFromEditor();

	TransmittedStructure = New Structure;
	ExecuteAlgorithmAtClient(TransmittedStructure);
	ExecuteAlgorithmAtServer(TransmittedStructure);
EndProcedure

&AtClient
Procedure EditClientVariableValue(Command)
	EditVariableValue(Items.ClientVariables);
EndProcedure

&AtClient
Procedure EditServerVariableValue(Command)
	EditVariableValue(Items.ServerVariables);
EndProcedure

&AtClient
Procedure NewAlgorithm(Command)
	AlgorithmFileName="";

	TextAlgorithmClient="";
	TextAlgorithmServer="";

	SetEditorText("Client",TextAlgorithmClient);
	SetEditorText("Server",TextAlgorithmServer);

	SetTitle();
EndProcedure

&AtClient
Procedure OpenFile(Command)
	UT_CommonClient.ReadConsoleFromFile("CodeConsole", SavedFilesDescriptionStructure(),
		New NotifyDescription("OpenFileEnd", ThisObject));
EndProcedure

&AtClient
Procedure SaveFile(Command)
	SaveFileToDisk();
EndProcedure

&AtClient
Procedure SaveFileAs(Command)
	SaveFileToDisk(True);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region OtherFunctions

&AtClient
Function ContextVariables(VariablesTabularSection)
	VariablesArray=New Array;
	For Each CurrentVariable In VariablesTabularSection Do
		VariableStructure=New Structure;
		VariableStructure.Insert("Name", CurrentVariable.Name);
		VariableStructure.Insert("Type", TypeOf(CurrentVariable.Value));

		VariablesArray.Add(VariableStructure);
	EndDo;
	
	Return VariablesArray;
EndFunction

&AtClient
Procedure AddAdditionalContextToCodeEditor(EditorID)
	AdditionalContextStructure = New Structure;
	AdditionalContextStructure.Insert("TransmittedStructure", "Structure");
	
	If EditorID = "Client" Then
		VariablesTabularSection = ClientVariables;
	Else
		VariablesTabularSection = ServerVariables;
	EndIf;
	
	ContextVariables =ContextVariables(VariablesTabularSection); 
	For Each Variable In ContextVariables Do
		If Not UT_CommonClientServer.IsCorrectVariableName(Variable.Name) Then
			Continue;
		EndIf;
		
		AdditionalContextStructure.Insert(Variable.Name, Variable.Type);
	EndDo;
	
	UT_CodeEditorClient.AddCodeEditorContext(ThisObject, EditorID, AdditionalContextStructure);
EndProcedure

&AtClient
Procedure OnOpenEnd(Result, AdditionalParameters) Export

EndProcedure

&AtClient
Function SavedFilesDescriptionStructure()
	Structure=UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	Structure.FileName=AlgorithmFileName;

	UT_CommonClient.AddFormatToSavingFileDescription(Structure,NStr("ru = 'Файл алгоритма(*.xbsl)';en = 'Algorithm file (*.xbsl)'"), "xbsl");
	Return Structure;
EndFunction

&AtClient
Procedure SaveFileToDisk(SaveAs = False)
	UpdateAlgorithmVariablesValueFromEditor();

	UT_CommonClient.SaveConsoleDataToFile("CodeConsole", SaveAs,
		SavedFilesDescriptionStructure(), GetSaveString(),
		New NotifyDescription("SaveFileEnd", ThisObject));
EndProcedure

&AtClient
Procedure SaveFileEnd(SaveFileName, AdditionalParameters) Export
	If SaveFileName = Undefined Then
		Return;
	EndIf;

	If Not ValueIsFilled(SaveFileName) Then
		Return;
	EndIf;

	Modified=False;
	AlgorithmFileName=SaveFileName;
	SetTitle();
	
//	Message("The algorithm has been successfully saved");

EndProcedure

&AtClient
Procedure OpenFileEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	Modified=False;
	AlgorithmFileName = Result.FileName;

	OpenAlgorithmAtServer(Result.Address);

	SetEditorText("Client",TextAlgorithmClient);
	SetEditorText("Server",TextAlgorithmServer);

	SetTitle();
EndProcedure

&AtClient
Procedure CloseConsoleEnd(Result, AdditionalParameters) Export

	If Result = DialogReturnCode.Yes Then
		FormCloseConfirmed = True;
		Close();
	EndIf;

EndProcedure

&AtClient
Procedure IdleHandlerSetCodeTextInTextEditorClient()
	Try
		SetEditorText("Client",TextAlgorithmClient);
	Except
		AttachIdleHandler("IdleHandlerSetCodeTextInTextEditorClient", 0.5, True);
	EndTry;
EndProcedure

&AtClient
Procedure IdleHandlerSetCodeTextInTextEditorServer()
	Try
		SetEditorText("Server",TextAlgorithmServer);
	Except
		AttachIdleHandler("IdleHandlerSetCodeTextInTextEditorServer", 0.5, True);
	EndTry;
EndProcedure

&AtClient
Procedure UpdateAlgorithmVariablesValueFromEditor()
	TextAlgorithmClient=UT_CodeEditorClient.EditorCodeText(ThisObject, "Client");
	TextAlgorithmServer=UT_CodeEditorClient.EditorCodeText(ThisObject, "Server");
EndProcedure

&AtClient
Procedure SetEditorText(EditorID, AlgorithmText)
	UT_CodeEditorClient.SetEditorText(ThisObject, EditorID, AlgorithmText);
	AddAdditionalContextToCodeEditor(EditorID);	
EndProcedure

&AtClientAtServerNoContext
Function AlgorithmExecutionContext(Variables, TransmittedStructure)
	ExecutionContext = New Structure;
	ExecutionContext.Insert("TransmittedStructure", TransmittedStructure);

	For Each TabularSectionRow ИЗ Variables Do
		ExecutionContext.Insert(TabularSectionRow.Name, TabularSectionRow.Value);
	EndDo;

	Return ExecutionContext;	
EndFunction

&AtClientAtServerNoContext
Function PreparedAlgorithmCode(CodeText, Variables)
	PreparedCode="";

	For VariableNumber = 0 To Variables.Count() - 1 Do
		CurrentVariable=Variables[VariableNumber];
		PreparedCode=PreparedCode + Chars.LF + CurrentVariable.Name + "=Variables[" + Format(VariableNumber,
			"NZ=0; NG=0;") + "].Value;";
	EndDo;

	PreparedCode=PreparedCode + Chars.LF + CodeText;

	Return PreparedCode;
EndFunction

&AtClientAtServerNoContext
Function ExecuteAlgorithm(AlgorithmText, Variables, TransmittedStructure)
	Successfully = True;
	ErrorDescription = "";

	BeginExecution = CurrentUniversalDateInMilliseconds();
	Try
		Execute (AlgorithmText);
	Except
		Successfully = False;
		ErrorDescription = ErrorDescription();
		Message(ErrorDescription);
	EndTry;
	EndExecution = CurrentUniversalDateInMilliseconds();

	ExecutionResult = New Structure;
	ExecutionResult.Insert("Successfully", Successfully);
	ExecutionResult.Insert("ExecutionTime", EndExecution - BeginExecution);
	ExecutionResult.Insert("ErrorDescription", ErrorDescription);

	Return ExecutionResult;
EndFunction

&AtClient
Procedure ExecuteAlgorithmAtClient(TransmittedStructure)
	If Not ValueIsFilled(TrimAll(TextAlgorithmClient)) Then
		Return;
	EndIf;

	ExecutionContext = AlgorithmExecutionContext(ClientVariables, TransmittedStructure);

	ExecutionResult = UT_CodeEditorClientServer.ExecuteAlgorithm(TextAlgorithmClient, ExecutionContext);

	If ExecutionResult.Successfully Then
		ItemTitle =StrTemplate(Nstr("ru = '&&НаКлиенте (Время выполнения кода: %1 сек.)';en = '&&AtClient (Code execution time: %1 seconds)'"),String((ExecutionResult.ExecutionTime)
			/ 1000)); 
	Else
		ItemTitle = NSTR("ru = '&&НаКлиенте';en = '&&AtClient'");
	EndIf;
	Items.GroupClient.Title = ItemTitle;

EndProcedure

&AtServer
Procedure ExecuteAlgorithmAtServer(TransmittedStructure)
	If Not ValueIsFilled(TrimAll(TextAlgorithmServer)) Then
		Return;
	EndIf;
	
	ExecutionContext = AlgorithmExecutionContext(ServerVariables, TransmittedStructure);

	ExecutionResult = UT_CodeEditorClientServer.ExecuteAlgorithm(TextAlgorithmServer, ExecutionContext);

	If ExecutionResult.Successfully Then
		
		ItemTitle =StrTemplate(Nstr("ru = '&&НаСервере (Время выполнения кода: %1 сек.)';en = '&&AtServer (Code execution time: %1 seconds)'"),String((ExecutionResult.ExecutionTime)
			/ 1000));
	Else
		ItemTitle =NSTR("ru = '&&НаСервере';en = '&&AtServer'");
	EndIf;
	Items.GroupServer.Title = ItemTitle;

EndProcedure

&AtServer
Function GetSaveString()

	StoredData = New Structure;
	StoredData.Insert("TextAlgorithmClient", TextAlgorithmClient);
	StoredData.Insert("TextAlgorithmServer", TextAlgorithmServer);

	VariablesArray=New Array;
	For Each CurrentVariable In ClientVariables Do
		VariableStructure=New Structure;
		VariableStructure.Insert("Name", CurrentVariable.Name);
		VariableStructure.Insert("Value", ValueToStringInternal(CurrentVariable.Value));

		VariablesArray.Add(VariableStructure);
	EndDo;
	StoredData.Insert("ClientVariables", VariablesArray);

	VariablesArray=New Array;
	For Each CurrentVariable In ServerVariables Do
		VariableStructure=New Structure;
		VariableStructure.Insert("Name", CurrentVariable.Name);
		VariableStructure.Insert("Value", ValueToStringInternal(CurrentVariable.Value));

		VariablesArray.Add(VariableStructure);
	EndDo;
	StoredData.Insert("ServerVariables", VariablesArray);

	JSONWriter=New JSONWriter;
	JSONWriter.SetString();

	WriteJSON(JSONWriter, StoredData);

	Return JSONWriter.Close();

EndFunction
&AtServer
Procedure OpenAlgorithmAtServer(FileURLInTempStorage)
	FileData=GetFromTempStorage(FileURLInTempStorage);

	JSONReader=New JSONReader;
	JSONReader.OpenStream(FileData.OpenStreamForRead());

	FileStructure=ReadJSON(JSONReader);
	JSONReader.Close();

	TextAlgorithmClient=FileStructure.TextAlgorithmClient;
	TextAlgorithmServer=FileStructure.TextAlgorithmServer;

	ClientVariables.Clear();
	For Each Variable In FileStructure.ClientVariables Do
		NewRow=ClientVariables.Add();
		NewRow.Name=Variable.Name;
		NewRow.Value=ValueFromStringInternal(Variable.Value);
	EndDo;

	ServerVariables.Clear();
	For Each Variable In FileStructure.ServerVariables Do
		NewRow=ServerVariables.Add();
		NewRow.Name=Variable.Name;
		NewRow.Value=ValueFromStringInternal(Variable.Value);
	EndDo;

EndProcedure
&AtClient
Procedure EditVariableValue(FormTable)
	CurrentData=FormTable.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(CurrentData.Value);
EndProcedure

&AtClient
Procedure SetTitle()
	Title=AlgorithmFileName;
EndProcedure

&AtClient
Procedure FieldAlgorithmClientOnClick(Item, EventData, StandardProcessing)
	
EndProcedure


&AtClient
Procedure ServerVariablesOnEditEnd(Item, NewRow, CancelEdit)
	AddAdditionalContextToCodeEditor("Server");
EndProcedure

&AtClient
Procedure ClientVariablesOnEditEnd(Item, NewRow, CancelEdit)
	AddAdditionalContextToCodeEditor("Client");
EndProcedure

#EndRegion

FormCloseConfirmed=False;