////////////////////////////////////////////////////////////////////////////////////////////////////
// EVENT HANDLERS
//

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	VerifyAccessRights("Administration", Metadata);

	If Parameters.Property("AutoTests") Then // Return when a form is received for analysis.
		Return;
	EndIf;

	ExchangeNodeRef = Parameters.ExchangeNodeRef;

EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	ReadMessageNumbers();
	Title = ExchangeNodeRef;
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// FORM COMMAND HANDLERS
//

// Writes modified data and closes the form.
&AtClient
Procedure WriteNodeChanges(Command)
	WriteMessageNumbers();
	Notify("ExchangeNodeDataEdit", ExchangeNodeRef, ThisObject);
	Close();
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// PRIVATE
//

&AtServer
Function ThisObject(CurrentObject = Undefined)
	If CurrentObject = Undefined Then
		Return FormAttributeToValue("Object");
	EndIf;
	ValueToFormAttribute(CurrentObject, "Object");
	Return Undefined;
EndFunction

&AtServer
Procedure ReadMessageNumbers()
	Data = ThisObject().GetExchangeNodeParameters(ExchangeNodeRef,
		"SentNo, ReceivedNo, DataVersion");
	If Data = Undefined Then
		SentNo = Undefined;
		ReceivedNo     = Undefined;
		DataVersion       = Undefined;
	Иначе
		SentNo = Data.SentNo;
		ReceivedNo     = Data.ReceivedNo;
		DataVersion       = Data.DataVersion;
	EndIf;
EndProcedure

&AtServer
Procedure WriteMessageNumbers()
	Data = New Structure("SentNo, ReceivedNo", SentNo, ReceivedNo);
	ThisObject().SetExchangeNodeParameters(ExchangeNodeRef, Data);
EndProcedure