&AtClient
Var ClosingFormConfirmed;
#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	SetLibraryAddressOnServer();

	If Parameters.Property("JSONString") Then
		EditLine=Parameters.JSONString;
		EditMode=True;
	EndIf;

	If Parameters.Property("ViewMode") Then
		EditMode=Not Parameters.ViewMode;
	EndIf;
	Items.FinishEditing.Visible=EditMode;

	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);

EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("OnOpenComplеtion", ThisObject));
EndProcedure

&AtClient
Procedure BeforeClose(Cancel, Exit, WarningText, StandardProcessing)
	If Not ClosingFormConfirmed Then
		Cancel = True;
		Return;
	EndIf;

	BeginDeletingFiles(New NotifyDescription("BeforeCloseDeletingFilesComplеtion", ThisForm), LibrarySavingDirectory);
EndProcedure

&AtClient
Procedure BeforeCloseDeletingFilesComplеtion(AdditionalParameters) Экспорт
	
	

EndProcedure

#EndRegion

#Region FormItemsEvents

&AtClient
Procedure ПолеРедактораДокументСформирован(Элемент)
	If ЗначениеЗаполнено(EditLine) Then
		ПодключитьОбработчикОжидания("ОбработчикОжиданияУстановитьРедактируемуюСтрокуВРедакторДерево", 0.5, True);
	EndIf;
EndProcedure

&AtClient
Procedure ПолеРедактораСтрокаДокументСформирован(Элемент)
	If ЗначениеЗаполнено(EditLine) Then
		ПодключитьОбработчикОжидания("ОбработчикОжиданияУстановитьРедактируемуюСтрокуВРедакторСтроки", 0.1, True);
	EndIf;
EndProcedure

&AtClient
Procedure CopyFromLineToTree(Command)
	JSONString=СтрокаJSONИзПоляРедактора(Items.LineEditField);
	СтрокаДерева=СтрокаJSONИзПоляРедактора(Items.TreeEditField);

	УстановитьJSONВHTML(Items.TreeEditField, JSONString);
	If Not ЗначениеЗаполнено(СтрокаДерева) Then
		РазвернутьСтрокиДереваJSON(Items.TreeEditField);
	EndIf;
EndProcedure

&AtClient
Procedure CopyFromTreeToLine(Command)
	JSONString=СтрокаJSONИзПоляРедактора(Items.TreeEditField);
	УстановитьJSONВHTML(Items.LineEditField, JSONString);
EndProcedure

&AtClient
Procedure FinishEditing(Command)
	ClosingFormConfirmed=True;
	Закрыть(СтрокаJSONИзПоляРедактора(Items.LineEditField));
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Команда);
EndProcedure



#EndRegion

#Region СлужебныеПроцедурыИФункции

&AtClient
Procedure OnOpenComplеtion(Result, AdditionalParameters) Экспорт
	СтруктураФайловыхПеременных=UT_CommonClient.SessionFileVariablesStructure();
	LibrarySavingDirectory=СтруктураФайловыхПеременных.TempFilesDirectory + "tools_ui_1c"
		+ GetPathSeparator() + Формат(UT_CommonClientServer.Version(), "ЧГ=0;") + GetPathSeparator() + "jsoneditor";
	ФайлРедактора=New Файл(LibrarySavingDirectory);
	ФайлРедактора.НачатьПроверкуСуществования(New NotifyDescription("ПриОткрытииЗавершениеПроверкиСуществованияБиблиотеки", ThisForm));

EndProcedure

&AtClient
Procedure ПриОткрытииЗавершениеПроверкиСуществованияБиблиотеки(Существует, AdditionalParameters1) Экспорт
	
	If Существует Then
		НачатьУдалениеФайлов(New NotifyDescription("ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеУдаленияФайлов", ThisForm,,"ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеОшибкаУдаленияФайлов", ThisObject), LibrarySavingDirectory);
	Else
		ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиФрагмент();
	EndIf;
	
EndProcedure

&AtClient
Procedure ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеУдаленияФайлов(AdditionalParameters) Экспорт
	ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиФрагмент();
EndProcedure  

&AtClient
Procedure ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеОшибкаУдаленияФайлов(AdditionalParameters) Экспорт
	LibrarySavingDirectory=LibrarySavingDirectory + "1";
	
	НачатьУдалениеФайлов(New NotifyDescription("ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеУдаленияФайлов", ThisForm,,"ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеОшибкаУдаленияФайлов", ThisObject), LibrarySavingDirectory);
EndProcedure  



&AtClient
Procedure ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиФрагмент()
	
	НачатьСозданиеКаталога(New NotifyDescription("ПриОткрытииЗавершениеСозданияКаталогаБиблиотеки", ThisForm), LibrarySavingDirectory);

EndProcedure

&AtClient
Procedure ПриОткрытииЗавершениеСозданияКаталогаБиблиотеки(ИмяКаталога, AdditionalParameters) Экспорт
	
	СохранитьБиблиотекуРедактораНаДиск();
	УстановитьТекстHTMLПоляРедактора();

EndProcedure

&AtClient
Procedure ОбработчикОжиданияУстановитьРедактируемуюСтрокуВРедакторДерево()
	Try
		УстановитьJSONВHTML(Items.TreeEditField, EditLine);
		РазвернутьСтрокиДереваJSON(Items.TreeEditField);
	Except
		ПодключитьОбработчикОжидания("ОбработчикОжиданияУстановитьРедактируемуюСтрокуВРедакторДерево", 0.5, True);
	EndTry;
EndProcedure

&AtClient
Procedure ОбработчикОжиданияУстановитьРедактируемуюСтрокуВРедакторСтроки()
	Try
		УстановитьJSONВHTML(Items.LineEditField, EditLine);
		//Форматируем строку JSON по формату редактора
		УстановитьJSONВHTML(Items.LineEditField, СтрокаJSONИзПоляРедактора(Items.LineEditField));

	Except
		ПодключитьОбработчикОжидания("ОбработчикОжиданияУстановитьРедактируемуюСтрокуВРедакторСтроки", 0.5, True);
	EndTry;
EndProcedure

&AtClient
Procedure УстановитьJSONВHTML(ЭлементПоляРедактора, JSONString)
	ДокументHTML=ЭлементПоляРедактора.Документ;
	If ДокументHTML.parentWindow = Undefined Then
		СтруктураДокументаДОМ = ДокументHTML.defaultView;
	Else
		СтруктураДокументаДОМ = ДокументHTML.parentWindow;
	EndIf;
	СтруктураДокументаДОМ.editor.setText(JSONString);

EndProcedure

&AtClient
Procedure РазвернутьСтрокиДереваJSON(ЭлементПоляРедактора)
	ДокументHTML=ЭлементПоляРедактора.Документ;
	If ДокументHTML.parentWindow = Undefined Then
		СтруктураДокументаДОМ = ДокументHTML.defaultView;
	Else
		СтруктураДокументаДОМ = ДокументHTML.parentWindow;
	EndIf;
	СтруктураДокументаДОМ.editor.expandAll();

EndProcedure

&AtClient
Function СтрокаJSONИзПоляРедактора(ЭлементПоляРедактора)
	ДокументHTML=ЭлементПоляРедактора.Документ;
	If ДокументHTML.parentWindow = Undefined Then
		СтруктураДокументаДОМ = ДокументHTML.defaultView;
	Else
		СтруктураДокументаДОМ = ДокументHTML.parentWindow;
	EndIf;
//	Возврат СтруктураДокументаДОМ.editor.getText();
	Return СтруктураДокументаДОМ.getJSON();

EndFunction

&AtClient
Procedure УстановитьТекстHTMLПоляРедактора()
	ТекстCSS=LibrarySavingDirectory + GetPathSeparator() + "jsoneditor.css";
	ТекстJS=LibrarySavingDirectory + GetPathSeparator() + "jsoneditor.js";

	Шаблон= "<!DOCTYPE HTML>
			|<html>
			|<head>
			|  <title>JSONEditor | Synchronize two editors</title>
			|
			|	<link href=""" + ТекстCSS + """ rel=""stylesheet"" type=""text/css"">
											 |  <script src=""" + ТекстJS + """></script>
																			|
																			|  <style type=""text/css"">
																			|    body {
																			|      font-family: sans-serif;
																			|    }
																			|
																			|   .jsoneditor {
																			|      width: 100%;
																			|      height: 100%;
																			|    }
																			|  </style>
																			|</head>
																			|<body>
																			|	<div class=""jsoneditor"" id=""jsoneditor""></div>
																			|
																			|<script>
																			|
																			|  var container = document.getElementById('jsoneditor')
																			|  var options = {
																			|    // switch between pt-BR or en for testing forcing a language
																			|    // leave blank to get language
																			|   'language': 'ru-RU',
																			|   mode: '###РежимРедактора###'
																			|  }
																			|  var editor = new JSONEditor(container, options)
																			|
																			|	function getJSON(){
																			|		return JSON.stringify(editor.get(), null, 2);
																			|	}
																			|
																			|
																			|</script>
																			|	<div id=""footer""></div>
																			|
																			|</body>
																			|</html>";

	СохранитьФайлHTMLПоляРедатора(StrReplace(Шаблон, "###РежимРедактора###", "tree"), LibrarySavingDirectory + GetPathSeparator() + "tree.html" ,"TreeEditField");
	СохранитьФайлHTMLПоляРедатора(StrReplace(Шаблон, "###РежимРедактора###", "code"), LibrarySavingDirectory + GetPathSeparator() + "code.html","LineEditField");
EndProcedure

&AtClient
Procedure СохранитьФайлHTMLПоляРедатора(ТекстHTML, ИмяФайла, ИмяПоляРедактора)
	Текст=New ТекстовыйДокумент;
	Текст.УстановитьТекст(ТекстHTML);
	
	ДопПараметры=New Structure;
	ДопПараметры.Insert("ИмяПоляРедактора", ИмяПоляРедактора);
	ДопПараметры.Insert("ИмяФайла", ИмяФайла);
	
	Текст.НачатьЗапись(New NotifyDescription("СохранитьФайлHTMLПоляРедатораЗаверешение", ThisObject, ДопПараметры), ИмяФайла);
EndProcedure

&AtClient
Procedure СохранитьФайлHTMLПоляРедатораЗаверешение(Result, AdditionalParameters) Экспорт
	ThisObject[AdditionalParameters.ИмяПоляРедактора] = AdditionalParameters.ИмяФайла;
EndProcedure

&AtClient
Procedure СохранитьБиблиотекуРедактораНаДиск()
	СоответствиеФайловБиблиотеки=GetFromTempStorage(LibraryAddress);
	For Each КлючЗначение In СоответствиеФайловБиблиотеки Do
		ИмяФайла=LibrarySavingDirectory + GetPathSeparator() + КлючЗначение.Ключ;

		КлючЗначение.Значение.Записать(ИмяФайла);
	EndDo;
EndProcedure

&AtServer
Procedure SetLibraryAddressOnServer()
	ObjectOfDataProcessors=FormAttributeToValue("Object");

	BinaryLibraryData=ObjectOfDataProcessors.GetTemplate("jsoneditor");

	FolderOnServer=GetTempFileName();
	CreateDirectory(FolderOnServer);

	Stream=BinaryLibraryData.OpenStreamForRead();

	ЧтениеZIP=New ZipFileReader(Stream);
	ЧтениеZIP.ExtractAll(FolderOnServer, ZIPRestoreFilePathsMode.Restore);

	LibraryMap =New Map;

	ArhiveFiles=FindFiles(FolderOnServer, "*", True);
	For Each LibraryFile In ArhiveFiles Do
		FileKey=StrReplace(LibraryFile.FullName, FolderOnServer + GetPathSeparator(), "");
		If LibraryFile.IsDirectory() Then
			Continue;
		EndIf;

		LibraryMap.Insert(FileKey, New BinaryData(LibraryFile.FullName));
	EndDo;

	LibraryAddress=PutToTempStorage(LibraryMap, UUID);

	Try
		DeleteFiles(FolderOnServer);
	Except
		// TODO:
	EndTry;

EndProcedure

#EndRegion

#Region СтандартныеПроцедурыИнструментов

&AtClient
Function СтруктураОписанияСохраняемогоФайла()
	Структура=UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	Структура.ИмяФайла=ToolDataFileName;

	UT_CommonClient.AddFormatToSavingFileDescription(Структура, "Файл JSOM(*.json)", "json");
	Return Структура;
EndFunction
&AtClient
Procedure OpenFile(Command)
	UT_CommonClient.ReadConsoleFromFile("РедактовJSON", СтруктураОписанияСохраняемогоФайла(),
		New NotifyDescription("OpenFileComplеtion", ThisObject));
EndProcedure

&AtClient
Procedure OpenFileComplеtion(Result, AdditionalParameters) Экспорт
	If Result = Undefined Then
		Return;
	EndIf;

	Модифицированность=False;
	ToolDataFileName = Result.ИмяФайла;

	ДанныеФайла=GetFromTempStorage(Result.Адрес);

	Текст=New ТекстовыйДокумент;
	Текст.НачатьЧтение(New NotifyDescription("ОткрытьФайлЗавершениеЧтенияТекста", ThisForm, New Structure("Текст", Текст)), ДанныеФайла.OpenStreamForRead());
EndProcedure

&AtClient
Procedure ОткрытьФайлЗавершениеЧтенияТекста(AdditionalParameters1) Экспорт
	
	Текст = AdditionalParameters1.Текст;
	
	УстановитьJSONВHTML(Items.LineEditField, Текст.ПолучитьТекст());
	УстановитьJSONВHTML(Items.TreeEditField, Текст.ПолучитьТекст());
	УстановитьЗаголовок();

EndProcedure

&AtClient
Procedure SaveFile(Command)
	СохранитьФайлНаДиск();
EndProcedure

&AtClient
Procedure SaveFileAs(Command)
	СохранитьФайлНаДиск(True);
EndProcedure

&AtClient
Procedure СохранитьФайлНаДиск(СохранитьКак = False)
	UT_CommonClient.SaveConsoleDataToFile("РедактовHTML", СохранитьКак,
		СтруктураОписанияСохраняемогоФайла(), СтрокаJSONИзПоляРедактора(Items.LineEditField),
		New NotifyDescription("СохранитьФайлЗавершение", ThisObject));
EndProcedure

&AtClient
Procedure СохранитьФайлЗавершение(ИмяФайлаСохранения, AdditionalParameters) Экспорт
	If ИмяФайлаСохранения = Undefined Then
		Return;
	EndIf;

	If Not ЗначениеЗаполнено(ИмяФайлаСохранения) Then
		Return;
	EndIf;

	Модифицированность=False;
	ToolDataFileName=ИмяФайлаСохранения;
	УстановитьЗаголовок();
EndProcedure

&AtClient
Procedure NewFile(Command)
	ToolDataFileName="";

	УстановитьJSONВHTML(Items.LineEditField, "");
	УстановитьJSONВHTML(Items.TreeEditField, "");

	УстановитьЗаголовок();
EndProcedure

&AtClient
Procedure УстановитьЗаголовок()
	Заголовок=ToolDataFileName;
EndProcedure

&AtClient
Procedure CloseTool(Command)
	ShowQueryBox(New NotifyDescription("CloseToolComplеtion", ThisForm), 
		Nstr("en='Do you want to exit editor?' : ru='Выйти из редактора?'"),
		QuestionDialogMode.YesNo);
EndProcedure

&AtClient
Procedure CloseToolComplеtion(Result, AdditionalParameters) Экспорт

	If Result = КодВозвратаДиалога.Да Then
		ClosingFormConfirmed = True;
		Закрыть();
	EndIf;

EndProcedure

#EndRegion

ClosingFormConfirmed=False;