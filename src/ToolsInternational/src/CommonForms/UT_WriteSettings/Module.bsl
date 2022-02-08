#Region VariablesDescription

&AtClient
Var mLastUUID;

#EndRegion

#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	UT_CommonClientServer.SetOnFormWriteParameters(ThisObject, Parameters.WriteSettings, "");
	
	UT_CodeEditorServer.FormOnCreateAtServer(ThisObject);
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "Editor", Items.FieldOfAlgorithmBeforeRecording);
	
	If Parameters.Property("ObjectType") Then
		ObjectType = Parameters.ObjectType;
	EndIf;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	UT_CodeEditorClient.FormOnOpen(ThisObject, New NotifyDescription("OnOpenEnd",ThisObject));
EndProcedure


&AtClient
Procedure OnOpenEnd(Result, AdditionalParameters) Export

EndProcedure


#EndRegion

#Region FormCommandsHandlers

&AtClient
Procedure Apply(Command)
	BeforeWriteProcedure = UT_CodeEditorClient.EditorCodeText(ThisObject, "Editor");
	Close(UT_CommonClientServer.FormWriteSettings(ThisObject, ""));
EndProcedure

&AtClient
Procedure InsertUUID(Command)
	CurrentData = Items.AdditionalProperties.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	NotificationAdditionalParameters=New Structure;
	NotificationAdditionalParameters.Insert("CurrentRow", Items.AdditionalProperties.CurrentRow);

	ShowInputString(New NotifyDescription("ProcessUUIDInput", ThisForm,
		NotificationAdditionalParameters), mLastUUID,NStr("ru = 'Введите уникальный идентификатор';en = 'Enter a unique identifier (UUID)'"), , False);
EndProcedure

#EndRegion

#Region Internal

&AtClient
Procedure ProcessUUIDInput(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	If Not ValueIsFilled(Result) Then
		Return;
	EndIf;

	Try
		pValue = New UUID(Result);
		mLastUUID = Result;
	Except
		ShowMessageBox( ,NStr("ru = 'Значение не может быть преобразовано в Уникальный идентификатор!';
		|en = 'The value cannot be converted to a Unique identifier (UUID)!'"), 20);
		Return;
	EndTry;

	CurrentData = AdditionalParameters.FindByID(AdditionalParameters.CurrentRow);
	If CurrentData <> Undefined Then
		CurrentData.Value = pValue;
	EndIf;
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ПолеРедактораДокументСформирован(Item)
	UT_CodeEditorClient.HTMLEditorFieldDocumentGenerated(ThisObject, Item);
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ПолеРедактораПриНажатии(Item, EventData, StandardProcessing)
	UT_CodeEditorClient.HTMLEditorFieldOnClick(ThisObject, Item, EventData, StandardProcessing);
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_РедакторКодаОтложеннаяИнициализацияРедакторов()
	UT_CodeEditorClient.CodeEditorDeferredInitializingEditors(ThisObject);
EndProcedure

//@skip-warning
&AtClient 
Procedure Подключаемый_РедакторКодаЗавершениеИнициализации() Export
	UT_CodeEditorClient.SetEditorText(ThisObject, "Editor", BeforeWriteProcedure);
	
	AddedContext = New Structure;
	If ObjectType <> New TypeDescription Then
		AddedContext.Insert("Object", ObjectType.Types()[0]);
	Else
		AddedContext.Insert("Object");
	EndIf;
	UT_CodeEditorClient.AddCodeEditorContext(ThisObject, "Editor", AddedContext);
EndProcedure

#EndRegion