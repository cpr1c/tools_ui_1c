////////////////////////////////////////////////////////////////////////////////////////////////////
// EVENT HANDLERS
//

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	VerifyAccessRights("Administration", Metadata);

	If Parameters.Property("AutoTests") Then // Return when a form is received for analysis.
		Return;
	EndIf;

	CurrentObject = ThisObject();
	CurrentObject.ReadSettings();
	CurrentObject.ReadSSLSupportFlags();
	ThisObject(CurrentObject);
	
	RegistrationObject = Parameters.RegistrationObject;
	Details       = "";
	
	If TypeOf(RegistrationObject) = Type("Structure") Then
		RegistrationTable = Parameters.RegistrationTable;
		ObjectAsString = RegistrationTable;
		For Each KeyValue In RegistrationObject Do
			Details = Details + "," + KeyValue.Value;
		EndDo;
		Details = " (" + Mid(Details,2) + ")";
	Else		
		RegistrationTable = "";
		ObjectAsString = RegistrationObject;
	EndIf;
	Title = NStr("ru = 'Регистрация '; en = 'Registration'") + CurrentObject.RefPresentation(ObjectAsString) + Details;

	ReadExchangeNodes();
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	ExpandAllNodes();
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// ExchangeNodesTree FORM TABLE ITEM EVENT HANDLERS
//

&AtClient
Procedure ExchangeNodeTreeSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;
	If Field = Items.ExchangeNodesTreeDescription Or Field = Items.ExchangeNodesTreeCode Then
		OpenOtherObjectEditForm();
		Return;
	ElsIf Field <> Items.ExchangeNodesTreeMessageNumber Then
		Return;
	EndIf;
	
	CurrentData = Items.ExchangeNodesTree.CurrentData;
	Notification = New NotifyDescription("ExchangeNodeTreeChoiceCompletion", ThisObject, New Structure);
	Notification.AdditionalParameters.Insert("Node", CurrentData.Ref);
	
	Tooltip = NStr("ru = 'Номер отправленного'; en = 'Number of the last sent message'"); 
	ShowInputNumber(Notification, CurrentData.MessageNo, Tooltip);
EndProcedure

&НаКлиенте
Procedure ExchangeNodesTreeCheckMarkOnChange(Item)
	ChangeMark(Items.ExchangeNodesTree.CurrentRow);
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// FORM COMMAND HANDLERS
//

&AtClient
Procedure RereadNodeTree(Command)
	CurrentNode = CurrentSelectedNode();
	ReadExchangeNodes();
	ExpandAllNodes(CurrentNode);
EndProcedure

&AtClient
Procedure OpenEditFormFromNode(Command)
	OpenOtherObjectEditForm();
EndProcedure

&AtClient
Procedure MarkAllNodes(Command)
	For Each PlanRow In ExchangeNodesTree.GetItems() Do
		PlanRow.Check = True;
		ChangeMark(PlanRow.GetID())
	EndDo;
EndProcedure

&AtClient
Procedure UnmarkAllNodes(Command)
	For Each PlanRow In ExchangeNodesTree.GetItems() Do
		PlanRow.Check = False;
		ChangeMark(PlanRow.GetID())
	EndDo;
EndProcedure

&AtClient
Procedure InvertAllNodesChecks(Command)
	For Each PlanRow In ExchangeNodesTree.GetItems() Do
		For Each NodeRow In PlanRow.GetItems() Do
			NodeRow.Check = Not NodeRow.Check;
			ChangeMark(NodeRow.GetID())
		EndDo;
	EndDo;
EndProcedure

&AtClient
Procedure EditRegistration(Command)
	
	QuestionTitle = NStr("ru = 'Подтверждение'; en = 'Confirm operation'");
	Text = NStr("ru = 'Изменить регистрацию ""%1""
	             |на узлах?'; 
	             |en = 'Do you want to change %1 registration
	             |at all nodes?'");
	
	Text = StrReplace(Text, "%1", RegistrationObject);
	
	Notification = New NotifyDescription("EditRegistrationCompletion", ThisObject);
	
	ShowQueryBox(Notification, Text, QuestionDialogMode.YesNo, , ,QuestionTitle);
EndProcedure

&AtClient
Procedure EditRegistrationCompletion(Val QuestionResult, Val AdditionalParameters) Export
	If QuestionResult <> DialogReturnCode.Yes Then
		Return;
	EndIf;
	
	Count = NodeRegistrationEdit(ExchangeNodesTree);
	If Count > 0 Then
		Text = NStr("ru = 'Регистрация %1 была изменена на %2 узлах'; en = 'Registration of %1 changed at %2 nodes.'");
		NotificationTitle = NStr("ru = 'Изменение регистрации:'; en = 'Registration changed:'");
		
		Text = StrReplace(Text, "%1", RegistrationObject);
		Text = StrReplace(Text, "%2", Count);
		
		ShowUserNotification(NotificationTitle,
			GetURL(RegistrationObject),
			Text,
			Items.HiddenPictureInformation32.Picture);
		
		If Parameters.NotifyAboutChanges Then
			Notify("ObjectDataExchangeRegistrationEdit",
				New Structure("RegistrationObject, RegistrationTable", RegistrationObject, RegistrationTable),
				ThisObject);
		EndIf;
	EndIf;
	
	CurrentNode = CurrentSelectedNode();
	ReadExchangeNodes(True);
	ExpandAllNodes(CurrentNode);
EndProcedure

&AtClient
Procedure OpenSettingsForm(Command)
	OpenDataProcessorSettingsForm();
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// PRIVATE
//

&AtClient
Procedure ExchangeNodeTreeChoiceCompletion(Val Number, Val AdditionalParameters) Export
	If Number = Undefined Then 
		// Canceling input.
		Return;
	EndIf;
	
	EditMessageNumberAtServer(AdditionalParameters.Node, Number, RegistrationObject, RegistrationTable);
	
	CurrentNode = CurrentSelectedNode();
	ReadExchangeNodes(True);
	ExpandAllNodes(CurrentNode);
	
	If Parameters.NotifyAboutChanges Then
		Notify("ObjectDataExchangeRegistrationEdit",
			New Structure("RegistrationObject, RegistrationTable", RegistrationObject, RegistrationTable),
			ThisObject);
	EndIf;
EndProcedure

&AtClient
Function CurrentSelectedNode()
	CurrentData = Items.ExchangeNodesTree.CurrentData;
	If CurrentData = Undefined Then
		Return Undefined;
	EndIf;
	Return New Structure("Description, Ref", CurrentData.Description, CurrentData.Ref);
EndFunction

&AtClient
Procedure OpenDataProcessorSettingsForm()
	CurFormName = GetFormName() + "Form.Settings";
	OpenForm(CurFormName, , ThisObject);
EndProcedure

&AtClient
Procedure OpenOtherObjectEditForm()
	CurFormName = GetFormName() + "Form.Form";
	Data = Items.ExchangeNodesTree.CurrentData;
	If Data <> Undefined AND Data.Ref <> Undefined Then
		CurParameters = New Structure("ExchangeNode, CommandID, RelatedObjects", Data.Ref);
		OpenForm(CurFormName, CurParameters, ThisObject);
	EndIf;
EndProcedure

&AtClient
Procedure ExpandAllNodes(FocusNode = Undefined)
	FoundNode = Undefined;
	
	For Each Row In ExchangeNodesTree.GetItems() Do
		ID = Row.GetID();
		Items.ExchangeNodesTree.Expand(ID, True);
		
		If FocusNode <> Undefined And FoundNode = Undefined Then
			If Row.Description = FocusNode.Description And Row.Ref = FocusNode.Ref Then
				FoundNode = ID;
			Else
				For Each ChildRow In Row.GetItems() Do
					If ChildRow.Description = FocusNode.Description And ChildRow.Ref = FocusNode.Ref Then
						FoundNode = ChildRow.GetID();
					EndIf;
				EndDo;
			EndIf;
		EndIf;
		
	EndDo;
	
	If FocusNode <> Undefined And FoundNode <> Undefined Then
		Items.ExchangeNodesTree.CurrentRow = FoundNode;
	EndIf;
	
EndProcedure

&AtServer
Function NodeRegistrationEdit(Val Data)
	CurrentObject = ThisObject();
	NodeCount = 0;
	For Each Row In Data.GetItems() Do
		If Row.Ref <> Undefined Then
			AlreadyRegistered = CurrentObject.ObjectRegisteredForNode(Row.Ref, RegistrationObject, RegistrationTable);
			If Row.Check = 0 AND AlreadyRegistered Then
				Result = CurrentObject.EditRegistrationAtServer(False, True, Row.Ref, RegistrationObject, RegistrationTable);
				NodeCount = NodeCount + Result.Success;
			ElsIf Row.Check = 1 AND (Not AlreadyRegistered) Then
				Result = CurrentObject.EditRegistrationAtServer(True, True, Row.Ref, RegistrationObject, RegistrationTable);
				NodeCount = NodeCount + Result.Success;
			EndIf;
		EndIf;
		NodeCount = NodeCount + NodeRegistrationEdit(Row);
	EndDo;
	Return NodeCount;
EndFunction

&AtServer
Function EditMessageNumberAtServer(Node, MessageNumber, Data, TableName = Undefined)
	Return ThisObject().EditRegistrationAtServer(MessageNumber, True, Node, Data, TableName);
EndFunction

&AtServer
Function ThisObject(CurrentObject = Undefined) 
	If CurrentObject = Undefined Then
		Return FormAttributeToValue("Object");
	EndIf;
	ValueToFormAttribute(CurrentObject, "Object");
	Return Undefined;
EndFunction

&AtServer
Function GetFormName(CurrentObject = Undefined)
	Return ThisObject().GetFormName(CurrentObject);
EndFunction

&AtServer
Procedure ChangeMark(Row)
	DataItem = ExchangeNodesTree.FindByID(Row);
	ThisObject().ChangeMark(DataItem);
EndProcedure

&AtServer
Procedure ReadExchangeNodes(OnlyUpdate = False)
	CurrentObject = ThisObject();
	Tree = CurrentObject.GenerateNodeTree(RegistrationObject, RegistrationTable);
	
	If OnlyUpdate Then
		// Updating  fields using the current tree values.
		For Each PlanRow In ExchangeNodesTree.GetItems() Do
			For Each NodeRow In PlanRow.GetItems() Do
				TreeRow = Tree.Rows.Find(NodeRow.Ref, "Ref", True);
				If TreeRow <> Undefined Then
					FillPropertyValues(NodeRow, TreeRow, "Check, InitialMark, MessageNo, NotExported");
				EndIf;
			EndDo;
		EndDo;
	Else
		// Assigning a new value to the ExchangeNodeTree form attribute
		ValueToFormAttribute(Tree, "ExchangeNodesTree");
	EndIf;
	
	For Each PlanRow In ExchangeNodesTree.GetItems() Do
		For Each NodeRow In PlanRow.GetItems() Do
			CurrentObject.ChangeMark(NodeRow);
		EndDo;
	EndDo;
	
EndProcedure