&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("Title") Then
		Title  = Parameters.Title;
	EndIf;

	Text=Parameters.Text;
EndProcedure

&AtClient
Procedure ОК(Command)
	Close(Text);
EndProcedure