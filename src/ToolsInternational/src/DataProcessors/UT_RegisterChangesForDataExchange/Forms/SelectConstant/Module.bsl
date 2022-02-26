////////////////////////////////////////////////////////////////////////////////////////////////////
// EVENT HANDLERS
//

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	VerifyAccessRights("Administration", Metadata);

	If Parameters.Property("AutoTests") Then // Return when a form is received for analysis.
		Return;
	EndIf;

	ConstantsList.Clear();
	For CurIndex = 0 To Parameters.MetadataNamesArray.UBound() Do
		Row = ConstantsList.Add();
		Row.AutoRecordPictureIndex = Parameters.AutoRecordsArray[CurIndex];
		Row.PictureIndex                = 2;
		Row.MetaFullName                 = Parameters.MetadataNamesArray[CurIndex];
		Row.Description                  = Parameters.PresentationsArray[CurIndex];
	EndDo;
	
	AutoRecordTitle = NStr("ru = 'Авторегистрация для узла ""%1""'; en = 'Register changes for node %1 automatically'");
	
	Items.AutoRecordDecoration.Title = StrReplace(AutoRecordTitle, "%1", Parameters.ExchangeNode);
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	CurParameters = SetFormParameters();
	Items.ConstantsList.CurrentRow = CurParameters.CurrentRow;
EndProcedure

&AtClient
Procedure OnReopen()
	CurParameters = SetFormParameters();
	Items.ConstantsList.CurrentRow = CurParameters.CurrentRow;
EndProcedure


////////////////////////////////////////////////////////////////////////////////
// ConstantsList FORM TABLE ITEM EVENT HANDLERS
//

&AtClient
Procedure ConstantsListSelection(Item, RowSelected, Field, StandardProcessing)
	PerformConstantSelection();
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// FORM COMMAND HANDLERS
//

// Selects a constant.
//
&AtClient
Procedure SelectConstant(Command)
	PerformConstantSelection();
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// PRIVATE
//

// Performs the selection and notifies of it.
//
&AtClient
Procedure PerformConstantSelection()
	Data = New Array;
	For Each CurrentRowItem In Items.ConstantsList.SelectedRows Do
		curRow = ConstantsList.FindByID(CurrentRowItem);
		Data.Add(curRow.MetaFullName);
	EndDo;
	NotifyChoice(Data);
EndProcedure

&AtServer
Function SetFormParameters()
	Result = New Structure("CurrentRow");
	If Parameters.ChoiceInitialValue <> Undefined Then
		Result.CurrentRow = RowIDByMetaName(Parameters.ChoiceInitialValue);
	EndIf;
	Return Result;
EndFunction

&AtServer
Function RowIDByMetaName(FullMetadataName)
	Data = FormAttributeToValue("ConstantsList");
	curRow = Data.Find(FullMetadataName, "MetaFullName");
	If curRow <> Undefined Then
		Return curRow.GetID();
	EndIf;
	Return Undefined;
EndFunction