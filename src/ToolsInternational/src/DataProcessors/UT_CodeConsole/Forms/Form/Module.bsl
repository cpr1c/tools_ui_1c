&AtClient
Var ЗакрытиеФормыПодтверждено;

#Region СобытияФормы

&AtServer
Procedure OnCreateAtServer(Cancel, СтандартнаяОбработка)
	UT_CodeEditorServer.FormOnCreateAtServer(ThisObject);
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "Server", Items.ПолеАлгоритмаСервер);
	UT_CodeEditorServer.CreateCodeEditorItems(ThisObject, "Клиент", Items.ПолеАлгоритмаКлиент);
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, СтандартнаяОбработка, Items.ОсновнаяКоманднаяПанель);
	
EndProcedure

&AtClient
Procedure BeforeClose(Cancel, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	If Not ЗакрытиеФормыПодтверждено Then
		Cancel = True;
	EndIf;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	UT_CodeEditorClient.FormOnOpen(ThisObject, New NotifyDescription("ПриОткрытииЗавершение",ThisObject));
EndProcedure

&AtClient
Procedure ПеременныеСерверПриОкончанииРедактирования(Item, НоваяСтрока, ОтменаРедактирования)
	ДобавитьДополнительныйКонтекстВРедакторКода("Server");
EndProcedure

&AtClient
Procedure ПеременныеКлиентПриОкончанииРедактирования(Item, НоваяСтрока, ОтменаРедактирования)
	ДобавитьДополнительныйКонтекстВРедакторКода("Клиент");
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_EditorFieldDocumentGenerated(Item)
	UT_CodeEditorClient.HTMLEditorFieldDocumentGenerated(ThisObject, Item);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_EditorFieldOnClick(Item, ДанныеСобытия, СтандартнаяОбработка)
	UT_CodeEditorClient.HTMLEditorFieldOnClick(ThisObject, Item, ДанныеСобытия, СтандартнаяОбработка);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_CodeEditorDeferredInitializingEditors()
	UT_CodeEditorClient.CodeEditorDeferredInitializingEditors(ThisObject);
EndProcedure

&AtClient 
Procedure Attachable_CodeEditorInitializingCompletion() Export
	If ValueIsFilled(AlgorithmFileName) Then
		UT_CommonClient.ReadConsoleFromFile("КонсольКода", СтруктураОписанияСохраняемогоФайла(),
			New NotifyDescription("ОткрытьФайлЗавершение", ThisObject), True);
	Else
		УстановитьТекстРедактора("Клиент", ТекстАлгоритмаКлиент);
		УстановитьТекстРедактора("Server", ТекстАлгоритмаСервер);
	EndIf;
EndProcedure


#EndRegion

#Region СобытияКомандФормы
&AtClient
Procedure CloseConsole(Command)
	ShowQueryBox(New NotifyDescription("ЗакрытьКонсольЗавершение", ThisForm), "Выйти из консоли кода?",
		QuestionDialogMode.YesNo);
EndProcedure

&AtClient
Procedure ExecuteCode(Command)
	//.1 Нужно обновить значения данных алгоритмов
	ОбновитьЗначениеПеременныхАлгоритмовИзРедактора();

	СтруктураПередачи = New Structure;
	ВыполнитьАлгоритмНаКлиенте(СтруктураПередачи);
	ВыполнитьАлгоритмНаСервере(СтруктураПередачи);
EndProcedure

&AtClient
Procedure EditClientVariableValue(Command)
	РедактироватьЗначениеПеременной(Items.ПеременныеКлиент);
EndProcedure

&AtClient
Procedure EditServerVariableValue(Command)
	РедактироватьЗначениеПеременной(Items.ПеременныеСервер);
EndProcedure

&AtClient
Procedure NewAlgorithm(Command)
	AlgorithmFileName="";

	ТекстАлгоритмаКлиент="";
	ТекстАлгоритмаСервер="";

	УстановитьТекстРедактора("Клиент",ТекстАлгоритмаКлиент);
	УстановитьТекстРедактора("Server",ТекстАлгоритмаСервер);

	SetCaption();
EndProcedure

&AtClient
Procedure OpenFile(Command)
	UT_CommonClient.ReadConsoleFromFile("КонсольКода", СтруктураОписанияСохраняемогоФайла(),
		New NotifyDescription("ОткрытьФайлЗавершение", ThisObject));
EndProcedure

&AtClient
Procedure SaveFile(Command)
	СохранитьФайлНаДиск();
EndProcedure

&AtClient
Procedure SaveFileAs(Command)
	СохранитьФайлНаДиск(True);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region ПрочиеФункции

&AtClient
Function ПеременныеКонтекста(ТЧПеременных)
	МассивПеременных=New Array;
	For Each ТекПеременная In ТЧПеременных Do
		СтруктураПеременной=New Structure;
		СтруктураПеременной.Insert("Name", ТекПеременная.Name);
		СтруктураПеременной.Insert("Type", TypeOf(ТекПеременная.Value));

		МассивПеременных.Add(СтруктураПеременной);
	EndDo;
	
	Return МассивПеременных;
EndFunction

&AtClient
Procedure ДобавитьДополнительныйКонтекстВРедакторКода(ИдентификаторРедактора)
	СтруктураДополнительногоКонтекста = New Structure;
	СтруктураДополнительногоКонтекста.Insert("СтруктураПередачи", "Structure");
	
	If ИдентификаторРедактора = "Клиент" Then
		ТЧПеременных = ClientVariables;
	Else
		ТЧПеременных = ServerVariables;
	EndIf;
	
	ПеременныеКонтекста =ПеременныеКонтекста(ТЧПеременных); 
	For Each Пер In ПеременныеКонтекста Do
		If Not UT_CommonClientServer.IsCorrectVariableName(Пер.Name) Then
			Continue;
		EndIf;
		
		СтруктураДополнительногоКонтекста.Insert(Пер.Name, Пер.Type);
	EndDo;
	
	UT_CodeEditorClient.AddCodeEditorContext(ThisObject, ИдентификаторРедактора, СтруктураДополнительногоКонтекста);
EndProcedure

&AtClient
Procedure ПриОткрытииЗавершение(Result, AdditionalParameters) Export

EndProcedure

&AtClient
Function СтруктураОписанияСохраняемогоФайла()
	Structure=UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	Structure.FileName=AlgorithmFileName;

	UT_CommonClient.AddFormatToSavingFileDescription(Structure, "File алгоритма(*.xbsl)", "xbsl");
	Return Structure;
EndFunction

&AtClient
Procedure СохранитьФайлНаДиск(СохранитьКак = False)
	ОбновитьЗначениеПеременныхАлгоритмовИзРедактора();

	UT_CommonClient.SaveConsoleDataToFile("КонсольКода", СохранитьКак,
		СтруктураОписанияСохраняемогоФайла(), ПолучитьСтрокуСохранения(),
		New NotifyDescription("СохранитьФайлЗавершение", ThisObject));
EndProcedure

&AtClient
Procedure СохранитьФайлЗавершение(ИмяФайлаСохранения, AdditionalParameters) Export
	If ИмяФайлаСохранения = Undefined Then
		Return;
	EndIf;

	If Not ValueIsFilled(ИмяФайлаСохранения) Then
		Return;
	EndIf;

	Modified=False;
	AlgorithmFileName=ИмяФайлаСохранения;
	SetCaption();
	
//	Сообщить("Алгоритм успешно сохранен");

EndProcedure

&AtClient
Procedure ОткрытьФайлЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	Modified=False;
	AlgorithmFileName = Result.FileName;

	ОткрытьАлгоритмНаСервере(Result.Address);

	УстановитьТекстРедактора("Клиент",ТекстАлгоритмаКлиент);
	УстановитьТекстРедактора("Server",ТекстАлгоритмаСервер);

	SetCaption();
EndProcedure

&AtClient
Procedure ЗакрытьКонсольЗавершение(Result, AdditionalParameters) Export

	If Result = DialogReturnCode.Yes Then
		ЗакрытиеФормыПодтверждено = True;
		Close();
	EndIf;

EndProcedure

&AtClient
Procedure ОбработчикОжиданияУстановитьТекстКодаВРедактореТекстаКлиент()
	Try
		УстановитьТекстРедактора("Клиент",ТекстАлгоритмаКлиент);
	Except
		AttachIdleHandler("ОбработчикОжиданияУстановитьТекстКодаВРедактореТекстаКлиент", 0.5, True);
	EndTry;
EndProcedure

&AtClient
Procedure ОбработчикОжиданияУстановитьТекстКодаВРедактореТекстаСервер()
	Try
		УстановитьТекстРедактора("Server",ТекстАлгоритмаСервер);
	Except
		AttachIdleHandler("ОбработчикОжиданияУстановитьТекстКодаВРедактореТекстаСервер", 0.5, True);
	EndTry;
EndProcedure

&AtClient
Procedure ОбновитьЗначениеПеременныхАлгоритмовИзРедактора()
	ТекстАлгоритмаКлиент=UT_CodeEditorClient.EditorCodeText(ThisObject, "Клиент");
	ТекстАлгоритмаСервер=UT_CodeEditorClient.EditorCodeText(ThisObject, "Server");
EndProcedure

&AtClient
Procedure УстановитьТекстРедактора(ИдентификаторРедактора, ТекстАлгоритма)
	UT_CodeEditorClient.SetEditorText(ThisObject, ИдентификаторРедактора, ТекстАлгоритма);
	ДобавитьДополнительныйКонтекстВРедакторКода(ИдентификаторРедактора);	
EndProcedure

&AtClientAtServerNoContext
Function КонтекстВыполненияАлгоритма(Переменные, СтруктураПередачи)
	КонтекстВыполнения = New Structure;
	КонтекстВыполнения.Insert("СтруктураПередачи", СтруктураПередачи);

	For Each СтрокаТЧ ИЗ Переменные Do
		КонтекстВыполнения.Insert(СтрокаТЧ.Name, СтрокаТЧ.Value);
	EndDo;

	Return КонтекстВыполнения;	
EndFunction

&AtClientAtServerNoContext
Function ПодготовленныйКодАлгоритма(ТекстКода, Переменные)
	ПодготовленныйКод="";

	For НомерПеременной = 0 To Переменные.Count() - 1 Do
		ТекПеременная=Переменные[НомерПеременной];
		ПодготовленныйКод=ПодготовленныйКод + Chars.LF + ТекПеременная.Name + "=Переменные[" + Format(НомерПеременной,
			"ЧН=0; ЧГ=0;") + "].Value;";
	EndDo;

	ПодготовленныйКод=ПодготовленныйКод + Chars.LF + ТекстКода;

	Return ПодготовленныйКод;
EndFunction

&AtClientAtServerNoContext
Function ВыполнитьАлгоритм(ТекстАлготима, Переменные, СтруктураПередачи)
	Успешно = True;
	ErrorDescription = "";

	НачалоВыполнения = CurrentUniversalDateInMilliseconds();
	Try
		Execute (ТекстАлготима);
	Except
		Успешно = False;
		ErrorDescription = ErrorDescription();
		Message(ErrorDescription);
	EndTry;
	ОкончаниеВыполнения = CurrentUniversalDateInMilliseconds();

	РезультатВыполнения = New Structure;
	РезультатВыполнения.Insert("Успешно", Успешно);
	РезультатВыполнения.Insert("ВремяВыполнения", ОкончаниеВыполнения - НачалоВыполнения);
	РезультатВыполнения.Insert("ErrorDescription", ErrorDescription);

	Return РезультатВыполнения;
EndFunction

&AtClient
Procedure ВыполнитьАлгоритмНаКлиенте(СтруктураПередачи)
	If Not ValueIsFilled(TrimAll(ТекстАлгоритмаКлиент)) Then
		Return;
	EndIf;

	КонтекстВыполнения = КонтекстВыполненияАлгоритма(ClientVariables, СтруктураПередачи);

	РезультатВыполнения = UT_CodeEditorClientServer.ExecuteAlgorithm(ТекстАлгоритмаКлиент, КонтекстВыполнения);

	If РезультатВыполнения.Успешно Then
		ЗаголовокЭлемента = "&&AtClient (Time выполнения кода: " + String((РезультатВыполнения.ВремяВыполнения)
			/ 1000) + " сек.)";
	Else
		ЗаголовокЭлемента = "&&AtClient";
	EndIf;
	Items.ГруппаКлиент.Title = ЗаголовокЭлемента;

EndProcedure

&AtServer
Procedure ВыполнитьАлгоритмНаСервере(СтруктураПередачи)
	If Not ValueIsFilled(TrimAll(ТекстАлгоритмаСервер)) Then
		Return;
	EndIf;
	
	КонтекстВыполнения = КонтекстВыполненияАлгоритма(ServerVariables, СтруктураПередачи);

	РезультатВыполнения = UT_CodeEditorClientServer.ExecuteAlgorithm(ТекстАлгоритмаСервер, КонтекстВыполнения);

	If РезультатВыполнения.Успешно Then
		ЗаголовокЭлемента = "&&AtServer (Time выполнения кода: " + String((РезультатВыполнения.ВремяВыполнения)
			/ 1000) + " сек.)";
	Else
		ЗаголовокЭлемента = "&&AtServer";
	EndIf;
	Items.ГруппаСервер.Title = ЗаголовокЭлемента;

EndProcedure

&AtServer
Function ПолучитьСтрокуСохранения()

	StoredData = New Structure;
	StoredData.Insert("ТекстАлгоритмаКлиент", ТекстАлгоритмаКлиент);
	StoredData.Insert("ТекстАлгоритмаСервер", ТекстАлгоритмаСервер);

	МассивПеременных=New Array;
	For Each ТекПеременная In ClientVariables Do
		СтруктураПеременной=New Structure;
		СтруктураПеременной.Insert("Name", ТекПеременная.Name);
		СтруктураПеременной.Insert("Value", ValueToStringInternal(ТекПеременная.Value));

		МассивПеременных.Add(СтруктураПеременной);
	EndDo;
	StoredData.Insert("ClientVariables", МассивПеременных);

	МассивПеременных=New Array;
	For Each ТекПеременная In ServerVariables Do
		СтруктураПеременной=New Structure;
		СтруктураПеременной.Insert("Name", ТекПеременная.Name);
		СтруктураПеременной.Insert("Value", ValueToStringInternal(ТекПеременная.Value));

		МассивПеременных.Add(СтруктураПеременной);
	EndDo;
	StoredData.Insert("ServerVariables", МассивПеременных);

	JSONWriter=New JSONWriter;
	JSONWriter.SetString();

	WriteJSON(JSONWriter, StoredData);

	Return JSONWriter.Close();

EndFunction
&AtServer
Procedure ОткрытьАлгоритмНаСервере(АдресФайлаВоВременномХранилище)
	ДанныеФайла=GetFromTempStorage(АдресФайлаВоВременномХранилище);

	JSONReader=New JSONReader;
	JSONReader.OpenStream(ДанныеФайла.OpenStreamForRead());

	СтруктураФайла=ReadJSON(JSONReader);
	JSONReader.Close();

	ТекстАлгоритмаКлиент=СтруктураФайла.ТекстАлгоритмаКлиент;
	ТекстАлгоритмаСервер=СтруктураФайла.ТекстАлгоритмаСервер;

	ClientVariables.Clear();
	For Each Variable In СтруктураФайла.ClientVariables Do
		НС=ClientVariables.Add();
		НС.Name=Variable.Name;
		НС.Value=ValueFromStringInternal(Variable.Value);
	EndDo;

	ServerVariables.Clear();
	For Each Variable In СтруктураФайла.ServerVariables Do
		НС=ServerVariables.Add();
		НС.Name=Variable.Name;
		НС.Value=ValueFromStringInternal(Variable.Value);
	EndDo;

EndProcedure
&AtClient
Procedure РедактироватьЗначениеПеременной(FormTable)
	ТекДанные=FormTable.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(ТекДанные.Value);
EndProcedure

&AtClient
Procedure SetCaption()
	Title=AlgorithmFileName;
EndProcedure

&AtClient
Procedure ПолеАлгоритмаСерверПриНажатии(Item, ДанныеСобытия, СтандартнаяОбработка)
	// Insert содержимое обработчика.
EndProcedure



#EndRegion

ЗакрытиеФормыПодтверждено=False;