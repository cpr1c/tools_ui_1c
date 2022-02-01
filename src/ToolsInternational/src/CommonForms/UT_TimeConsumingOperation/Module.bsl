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
		AttachIdleHandler("Подключаемый_ПроверитьВыполнениеЗадания", WaitInterval, True);
	EndIf;

EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, WarningText, StandardProcessing)
	If State <> "Running" Then
		Return;
	EndIf;

	Cancel = True;
	If Exit Then
		Return;
	EndIf;

	AttachIdleHandler("Подключаемый_ОтменитьЗадание", 0.1, True);
EndProcedure

&AtClient
Procedure OnClose(Exit)
	If Exit Then
		Return;
	EndIf;

	If State <> "Running" Then
		Return;
	EndIf;

	CancelJobExecution();
			
EndProcedure

#EndRegion

#Region Commands

&AtClient
Procedure Cancel(Command)

	FormClosing = True;
	Подключаемый_ПроверитьВыполнениеЗадания(); // а вдруг задание уже выполнилось.
	If State = "Canceled" Then
		State = Undefined;
		Close(ExecutionResult(Undefined));
	EndIf;

EndProcedure

#EndRegion

#Region Internal

&AtClient
Процедура Подключаемый_ПроверитьВыполнениеЗадания()

	Задание = ПроверитьЗаданиеВыполнено(FormClosing);
	Статус = Задание.Статус;

	Если Задание.Прогресс <> Неопределено Тогда
		ПрогрессСтрокой = ПрогрессСтрокой(Задание.Прогресс);
		Если Не ПустаяСтрока(ПрогрессСтрокой) Тогда
			Элементы.ДекорацияПоясняющийТекстДлительнойОперации.Заголовок = MessageText + " " + ПрогрессСтрокой;
		КонецЕсли;
	КонецЕсли;
	Если Задание.Сообщения <> Неопределено И ВладелецФормы <> Неопределено Тогда
		ИдентификаторНазначения = ВладелецФормы.УникальныйИдентификатор;
		Для Каждого СообщениеПользователю Из Задание.Сообщения Цикл
			СообщениеПользователю.ИдентификаторНазначения = ИдентификаторНазначения;
			СообщениеПользователю.Сообщить();
		КонецЦикла;
	КонецЕсли;

	Если Статус = "Выполнено" Тогда

		ShowNotification();
		Если ReturnResultToChoiceProcessing() Тогда
			ОповеститьОВыборе(Задание.Результат);
			Возврат;
		КонецЕсли;
		Закрыть(ExecutionResult(Задание));
		Возврат;

	ИначеЕсли Статус = "Ошибка" Тогда

		Закрыть(ExecutionResult(Задание));
		Если ReturnResultToChoiceProcessing() Тогда
			ВызватьИсключение Задание.КраткоеПредставлениеОшибки;
		КонецЕсли;
		Возврат;

	КонецЕсли;

	Если Параметры.ВыводитьОкноОжидания Тогда
		Если Параметры.Интервал = 0 Тогда
			ИнтервалОжидания = ИнтервалОжидания * 1.4;
			Если ИнтервалОжидания > 15 Тогда
				ИнтервалОжидания = 15;
			КонецЕсли;
		КонецЕсли;
		ПодключитьОбработчикОжидания("Подключаемый_ПроверитьВыполнениеЗадания", ИнтервалОжидания, Истина);
	КонецЕсли;

КонецПроцедуры

&AtClient
Procedure Подключаемый_ОтменитьЗадание()

	Cancel(Undefined);

EndProcedure

&AtClient
Procedure ShowNotification()

	If Parameters.ОповещениеПользователя = Undefined Or Not Parameters.ОповещениеПользователя.Показать Then
		Return;
	EndIf;

	Оповещение = Parameters.ОповещениеПользователя;

	НавигационнаяСсылкаОповещения = Оповещение.НавигационнаяСсылка;
	If НавигационнаяСсылкаОповещения = Undefined And ВладелецФормы <> Undefined And ВладелецФормы.Окно
		<> Undefined Then
		НавигационнаяСсылкаОповещения = ВладелецФормы.Окно.ПолучитьНавигационнуюСсылку();
	EndIf;
	ПояснениеОповещения = Оповещение.Пояснение;
	If ПояснениеОповещения = Undefined And ВладелецФормы <> Undefined And ВладелецФормы.Окно <> Undefined Then
		ПояснениеОповещения = ВладелецФормы.Окно.Заголовок;
	EndIf;

	ShowUserNotification(?(Оповещение.Текст <> Undefined, Оповещение.Текст, NStr(
		"ru = 'Действие выполнено'")), НавигационнаяСсылкаОповещения, ПояснениеОповещения);

EndProcedure

&AtServer
Function ПроверитьЗаданиеВыполнено(FormClosing)

	Задание = UT_TimeConsumingOperations.ActionCompleted(JobID, False, Parameters.ВыводитьПрогрессВыполнения,
		Parameters.ВыводитьСообщения);

	If Parameters.GetResult Then
		If Задание.Статус = "Completed" Then
			Задание.Insert("Результат", ПолучитьИзВременногоХранилища(Parameters.АдресРезультата));
		Иначе
			Задание.Insert("Результат", Undefined);
		EndIf;
	EndIf;

	If FormClosing = True Then
		CancelJobExecution();
		Задание.Статус = "Canceled";
	EndIf;

	Return Задание;

EndFunction

&AtClient
Function ПрогрессСтрокой(Прогресс)

	Результат = "";
	If Прогресс = Undefined Then
		Return Результат;
	EndIf;

	Процент = 0;
	If Прогресс.Свойство("Процент", Процент) Then
		Результат = Строка(Процент) + "%";
	EndIf;
	Текст = 0;
	If Прогресс.Свойство("Текст", Текст) Then
		If Not ПустаяСтрока(Результат) Then
			Результат = Результат + " (" + Текст + ")";
		Иначе
			Результат = Текст;
		EndIf;
	EndIf;

	Return Результат;

EndFunction

&AtClient
Function ExecutionResult(Job)

	If Job = Undefined Then
		Return Undefined;
	EndIf;

	Result = New Structure;
	Result.Insert("Status", Job.Status);
	Result.Insert("ResultURL", Parameters.ResultURL);
	Result.Insert("AdditionalResultURL", Parameters.AdditionalResultURL);
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