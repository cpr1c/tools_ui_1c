#Region VariablesDescription

&AtClient
Var WaitInterval;
&AtClient
Var FormClosing;

#EndRegion

#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	MessageText = NStr("ru = 'Пожалуйста, подождите...';en = 'Wait please'");
	If Not IsBlankString(Parameters.MessageText) Then
		MessageText = Parameters.MessageText + Chars.LF + MessageText;
		Items.DecorationConsumingOperationExplanatoryText.Title = MessageText;
	EndIf;

	If ValueIsFilled(Parameters.JobID) Then
		JobID = Parameters.JobID;
	EndIf;

EndProcedure

&AtClient
Procedure OnOpen(Cancel)

	If Parameters.ShowWaitWindow Then
		WaitInterval = ?(Parameters.Interval <> 0, Parameters.Interval, 1);
		AttachIdleHandler("Attachable_CheckJobExecution", WaitInterval, True);
	EndIf;

EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, WarningText, StandardProcessing)
	If Status <> "Running" Then
		Return;
	EndIf;

	Cancel = True;
	If Exit Then
		Return;
	EndIf;

	AttachIdleHandler("Attachable_CancelJob", 0.1, True);
EndProcedure

&AtClient
Procedure OnClose(Exit)
	If Exit Then
		Return;
	EndIf;

	If Status <> "Running" Then
		Return;
	EndIf;

	CancelJobExecution();
			
EndProcedure

#EndRegion

#Region Commands

&AtClient
Procedure Cancel(Command)

	FormClosing = True;
	Attachable_CheckJobExecution(); // what if the job has already been completed.
	If Status = "Canceled" Then
		Status = Undefined;
		Close(ExecutionResult(Undefined));
	EndIf;

EndProcedure

#EndRegion

#Region Internal

&AtClient
Procedure Attachable_CheckJobExecution()

	Job = CheckJobIsCompleted(FormClosing);
	Status = Job.Status;

	If Job.Progress <> Undefined Then
		ProgressAsString = ProgressAsString(Job.Progress);
		If Not IsBlankString(ProgressAsString) Then
			Items.DecorationConsumingOperationExplanatoryText.Title = MessageText + " " + ProgressAsString;
		EndIf;
	EndIf;
	If Job.Messages <> Undefined And FormOwner <> Undefined Then
		TargetID = FormOwner.UUID;
		For Each UserMessage In Job.Messages Do
			UserMessage.TargetID = TargetID;
			UserMessage.Message();
		EndDo;
	EndIf;

	If Status = "Completed" Then

		ShowNotification();
		If ReturnResultToChoiceProcessing() Then
			NotifyChoice(Job.Result);
			Return;
		EndIf;
		Close(ExecutionResult(Job));
		Return;

	ElsIf Status = "Error" Then

		Close(ExecutionResult(Job));
		If ReturnResultToChoiceProcessing() Then
			Raise Job.BriefErrorDescription;
		EndIf;
		Return;

	EndIf;

	If Parameters.ShowWaitWindow Then
		If Parameters.Interval = 0 Then
			WaitInterval = WaitInterval * 1.4;
			If WaitInterval > 15 Then
				WaitInterval = 15;
			EndIf;
		EndIf;
		AttachIdleHandler("Attachable_CheckJobExecution", WaitInterval, True);
	EndIf;

КонецПроцедуры

&AtClient
Procedure Attachable_CancelJob()

	Cancel(Undefined);

EndProcedure

&AtClient
Procedure ShowNotification()

	If Parameters.UserNotification = Undefined Or Not Parameters.UserNotification.Show Then
		Return;
	EndIf;

	Notification = Parameters.UserNotification;

	NotificationURL = Notification.URL;
	If NotificationURL = Undefined And FormOwner <> Undefined And FormOwner.Window
		<> Undefined Then
		NotificationURL = FormOwner.Window.ClientApplicationWindow();
	EndIf;
	NotificationExplanation = Notification.Explanation;
	If NotificationExplanation = Undefined And FormOwner <> Undefined And FormOwner.Window <> Undefined Then
		NotificationExplanation = FormOwner.Window.Caption;
	EndIf;

	ShowUserNotification(?(Notification.Текст <> Undefined, Notification.Текст, NStr(
		"ru = 'Действие выполнено';en = 'Action completed'")), NotificationURL, NotificationExplanation);

EndProcedure

&AtServer
Function CheckJobIsCompleted(FormClosing)

	Job = UT_TimeConsumingOperations.ActionCompleted(JobID, False, Parameters.DisplayExecutionProgress,
		Parameters.OutputMessages);

	If Parameters.GetResult Then
		If Job.Status = "Completed" Then
			Job.Insert("Result", GetFromTempStorage(Parameters.ResultAddress));
		Иначе
			Job.Insert("Result", Undefined);
		EndIf;
	EndIf;

	If FormClosing = True Then
		CancelJobExecution();
		Job.Status = "Canceled";
	EndIf;

	Return Job;

EndFunction

&AtClient
Function ProgressAsString(Progress)

	Result = "";
	If Progress = Undefined Then
		Return Result;
	EndIf;

	Percent = 0;
	If Progress.Property("Percent", Percent) Then
		Result = String(Percent) + "%";
	EndIf;
	Text = 0;
	If Progress.Property("Text", Text) Then
		If Not IsBlankString(Result) Then
			Result = Result + " (" + Text + ")";
		Else
			Result = Text;
		EndIf;
	EndIf;

	Return Result;

EndFunction

&AtClient
Function ExecutionResult(Job)

	If Job = Undefined Then
		Return Undefined;
	EndIf;

	Result = New Structure;
	Result.Insert("Status", Job.Status);
	Result.Insert("ResultURL", Parameters.ResultAddress);
	Result.Insert("AdditionalResultURL", Parameters.AdditionalResultAddress);
	Result.Insert("BriefErrorPresentation", Job.BriefErrorPresentation);
	Result.Insert("DetailedErrorPresentation", Job.DetailedErrorPresentation);
	Result.Insert("Messages", Job.Messages);

	If Parameters.GetResult Then
		Result.Insert("Result", Job.Result);
	EndIf;

	Return Result;

EndFunction

&AtClient
Function ReturnResultToChoiceProcessing()
	Return OnCloseNotifyDescription = Undefined And Parameters.GetResult And TypeOf(FormOwner) = UT_CommonClientServer.ManagedFormType();
EndFunction

&AtServer
Procedure CancelJobExecution()

	UT_TimeConsumingOperations.CancelJobExecution(JobID);

EndProcedure

#EndRegion