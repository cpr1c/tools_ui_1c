&AtClient
Перем ЗакрытиеФормыПодтверждено;
#Region СобытияФормы

&AtServer
Procedure ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	УстановитьАдресБиблиотекиНаСервере();

	If Параметры.Свойство("СтрокаJSON") Then
		EditLine=Параметры.СтрокаJSON;
		EditMode=True;
	EndIf;

	If Параметры.Свойство("РежимПросмотра") Then
		EditMode=Not Параметры.РежимПросмотра;
	EndIf;
	Items.FinishEditing.Видимость=EditMode;

	UT_Common.ToolFormOnCreateAtServer(ЭтотОбъект, Отказ, СтандартнаяОбработка);

EndProcedure

&AtClient
Procedure ПриОткрытии(Отказ)
	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("ПриОткрытииЗавершение", ЭтотОбъект));
EndProcedure
&AtClient
Procedure ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	If Not ЗакрытиеФормыПодтверждено Then
		Отказ = True;
		Return;
	EndIf;

	НачатьУдалениеФайлов(New NotifyDescription("ПередЗакрытиемЗавершениеУдаленияФайлов", ЭтаФорма), LibrarySavingDirectory);
EndProcedure

&AtClient
Procedure ПередЗакрытиемЗавершениеУдаленияФайлов(ДополнительныеПараметры) Экспорт
	
	

EndProcedure

#EndRegion

#Region СобытияЭлементовФормы

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
Procedure CopyFromLineToTree(Команда)
	СтрокаJSON=СтрокаJSONИзПоляРедактора(Items.LineEditField);
	СтрокаДерева=СтрокаJSONИзПоляРедактора(Items.TreeEditField);

	УстановитьJSONВHTML(Items.TreeEditField, СтрокаJSON);
	If Not ЗначениеЗаполнено(СтрокаДерева) Then
		РазвернутьСтрокиДереваJSON(Items.TreeEditField);
	EndIf;
EndProcedure

&AtClient
Procedure CopyFromTreeToLine(Команда)
	СтрокаJSON=СтрокаJSONИзПоляРедактора(Items.TreeEditField);
	УстановитьJSONВHTML(Items.LineEditField, СтрокаJSON);
EndProcedure

&AtClient
Procedure FinishEditing(Команда)
	ЗакрытиеФормыПодтверждено=True;
	Закрыть(СтрокаJSONИзПоляРедактора(Items.LineEditField));
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Команда) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ЭтотОбъект, Команда);
EndProcedure



#EndRegion

#Region СлужебныеПроцедурыИФункции

&AtClient
Procedure ПриОткрытииЗавершение(Результат, ДополнительныеПараметры) Экспорт
	СтруктураФайловыхПеременных=UT_CommonClient.SessionFileVariablesStructure();
	LibrarySavingDirectory=СтруктураФайловыхПеременных.TempFilesDirectory + "tools_ui_1c"
		+ ПолучитьРазделительПути() + Формат(UT_CommonClientServer.Version(), "ЧГ=0;") + ПолучитьРазделительПути() + "jsoneditor";
	ФайлРедактора=New Файл(LibrarySavingDirectory);
	ФайлРедактора.НачатьПроверкуСуществования(New NotifyDescription("ПриОткрытииЗавершениеПроверкиСуществованияБиблиотеки", ЭтаФорма));

EndProcedure

&AtClient
Procedure ПриОткрытииЗавершениеПроверкиСуществованияБиблиотеки(Существует, ДополнительныеПараметры1) Экспорт
	
	If Существует Then
		НачатьУдалениеФайлов(New NotifyDescription("ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеУдаленияФайлов", ЭтаФорма,,"ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеОшибкаУдаленияФайлов", ЭтотОбъект), LibrarySavingDirectory);
	Else
		ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиФрагмент();
	EndIf;
	
EndProcedure

&AtClient
Procedure ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеУдаленияФайлов(ДополнительныеПараметры) Экспорт
	ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиФрагмент();
EndProcedure  

&AtClient
Procedure ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеОшибкаУдаленияФайлов(ДополнительныеПараметры) Экспорт
	LibrarySavingDirectory=LibrarySavingDirectory + "1";
	
	НачатьУдалениеФайлов(New NotifyDescription("ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеУдаленияФайлов", ЭтаФорма,,"ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиЗавершениеОшибкаУдаленияФайлов", ЭтотОбъект), LibrarySavingDirectory);
EndProcedure  



&AtClient
Procedure ПриОткрытииЗавершениеПроверкиСуществованияБиблиотекиФрагмент()
	
	НачатьСозданиеКаталога(New NotifyDescription("ПриОткрытииЗавершениеСозданияКаталогаБиблиотеки", ЭтаФорма), LibrarySavingDirectory);

EndProcedure

&AtClient
Procedure ПриОткрытииЗавершениеСозданияКаталогаБиблиотеки(ИмяКаталога, ДополнительныеПараметры) Экспорт
	
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
		УстановитьJSONВHTML(Items.LineEditField, СтрокаJSONИзПоляРедактора(Элементы.LineEditField));

	Except
		ПодключитьОбработчикОжидания("ОбработчикОжиданияУстановитьРедактируемуюСтрокуВРедакторСтроки", 0.5, True);
	EndTry;
EndProcedure

&AtClient
Procedure УстановитьJSONВHTML(ЭлементПоляРедактора, СтрокаJSON)
	ДокументHTML=ЭлементПоляРедактора.Документ;
	If ДокументHTML.parentWindow = Undefined Then
		СтруктураДокументаДОМ = ДокументHTML.defaultView;
	Else
		СтруктураДокументаДОМ = ДокументHTML.parentWindow;
	EndIf;
	СтруктураДокументаДОМ.editor.setText(СтрокаJSON);

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
	ТекстCSS=LibrarySavingDirectory + ПолучитьРазделительПути() + "jsoneditor.css";
	ТекстJS=LibrarySavingDirectory + ПолучитьРазделительПути() + "jsoneditor.js";

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

	СохранитьФайлHTMLПоляРедатора(СтрЗаменить(Шаблон, "###РежимРедактора###", "tree"), LibrarySavingDirectory + ПолучитьРазделительПути() + "tree.html" ,"TreeEditField");
	СохранитьФайлHTMLПоляРедатора(СтрЗаменить(Шаблон, "###РежимРедактора###", "code"), LibrarySavingDirectory + ПолучитьРазделительПути() + "code.html","LineEditField");
EndProcedure

&AtClient
Procedure СохранитьФайлHTMLПоляРедатора(ТекстHTML, ИмяФайла, ИмяПоляРедактора)
	Текст=New ТекстовыйДокумент;
	Текст.УстановитьТекст(ТекстHTML);
	
	ДопПараметры=New Structure;
	ДопПараметры.Insert("ИмяПоляРедактора", ИмяПоляРедактора);
	ДопПараметры.Insert("ИмяФайла", ИмяФайла);
	
	Текст.НачатьЗапись(New NotifyDescription("СохранитьФайлHTMLПоляРедатораЗаверешение", ЭтотОбъект, ДопПараметры), ИмяФайла);
EndProcedure

&AtClient
Procedure СохранитьФайлHTMLПоляРедатораЗаверешение(Результат, ДополнительныеПараметры) Экспорт
	ЭтотОбъект[ДополнительныеПараметры.ИмяПоляРедактора] = ДополнительныеПараметры.ИмяФайла;
EndProcedure

&AtClient
Procedure СохранитьБиблиотекуРедактораНаДиск()
	СоответствиеФайловБиблиотеки=ПолучитьИзВременногоХранилища(LibraryAddress);
	For Each КлючЗначение In СоответствиеФайловБиблиотеки Do
		ИмяФайла=LibrarySavingDirectory + ПолучитьРазделительПути() + КлючЗначение.Ключ;

		КлючЗначение.Значение.Записать(ИмяФайла);
	EndDo;
EndProcedure

&AtServer
Procedure УстановитьАдресБиблиотекиНаСервере()
	ОбработкаОбъект=РеквизитФормыВЗначение("Object");

	ДвоичныеДанныеБиблиотеки=ОбработкаОбъект.ПолучитьМакет("jsoneditor");

	КаталогНаСервере=ПолучитьИмяВременногоФайла();
	СоздатьКаталог(КаталогНаСервере);

	Поток=ДвоичныеДанныеБиблиотеки.ОткрытьПотокДляЧтения();

	ЧтениеZIP=New ЧтениеZipФайла(Поток);
	ЧтениеZIP.ИзвлечьВсе(КаталогНаСервере, РежимВосстановленияПутейФайловZIP.Восстанавливать);

	СтруктураБиблиотеки=New Map;

	ФайлыАрхива=НайтиФайлы(КаталогНаСервере, "*", True);
	For Each ФайлБиблиотеки In ФайлыАрхива Do
		КлючФайла=СтрЗаменить(ФайлБиблиотеки.ПолноеИмя, КаталогНаСервере + ПолучитьРазделительПути(), "");
		If ФайлБиблиотеки.ЭтоКаталог() Then
			Continue;
		EndIf;

		СтруктураБиблиотеки.Insert(КлючФайла, New ДвоичныеДанные(ФайлБиблиотеки.ПолноеИмя));
	EndDo;

	LibraryAddress=ПоместитьВоВременноеХранилище(СтруктураБиблиотеки, УникальныйИдентификатор);

	Try
		УдалитьФайлы(КаталогНаСервере);
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
Procedure OpenFile(Команда)
	UT_CommonClient.ReadConsoleFromFile("РедактовJSON", СтруктураОписанияСохраняемогоФайла(),
		New NotifyDescription("OpenFileComplеtion", ЭтотОбъект));
EndProcedure

&AtClient
Procedure OpenFileComplеtion(Результат, ДополнительныеПараметры) Экспорт
	If Результат = Undefined Then
		Return;
	EndIf;

	Модифицированность=False;
	ToolDataFileName = Результат.ИмяФайла;

	ДанныеФайла=ПолучитьИзВременногоХранилища(Результат.Адрес);

	Текст=New ТекстовыйДокумент;
	Текст.НачатьЧтение(New NotifyDescription("ОткрытьФайлЗавершениеЧтенияТекста", ЭтаФорма, New Structure("Текст", Текст)), ДанныеФайла.ОткрытьПотокДляЧтения());
EndProcedure

&AtClient
Procedure ОткрытьФайлЗавершениеЧтенияТекста(ДополнительныеПараметры1) Экспорт
	
	Текст = ДополнительныеПараметры1.Текст;
	
	УстановитьJSONВHTML(Items.LineEditField, Текст.ПолучитьТекст());
	УстановитьJSONВHTML(Items.TreeEditField, Текст.ПолучитьТекст());
	УстановитьЗаголовок();

EndProcedure

&AtClient
Procedure SaveFile(Команда)
	СохранитьФайлНаДиск();
EndProcedure

&AtClient
Procedure SaveFileAs(Команда)
	СохранитьФайлНаДиск(True);
EndProcedure

&AtClient
Procedure СохранитьФайлНаДиск(СохранитьКак = False)
	UT_CommonClient.SaveConsoleDataToFile("РедактовHTML", СохранитьКак,
		СтруктураОписанияСохраняемогоФайла(), СтрокаJSONИзПоляРедактора(Items.LineEditField),
		New NotifyDescription("СохранитьФайлЗавершение", ЭтотОбъект));
EndProcedure

&AtClient
Procedure СохранитьФайлЗавершение(ИмяФайлаСохранения, ДополнительныеПараметры) Экспорт
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
Procedure NewFile(Команда)
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
Procedure CloseTool(Команда)
	ПоказатьВопрос(New NotifyDescription("CloseToolComplеtion", ЭтаФорма), "Выйти из редактора?",
		РежимДиалогаВопрос.ДаНет);
EndProcedure

&AtClient
Procedure CloseToolComplеtion(Результат, ДополнительныеПараметры) Экспорт

	If Результат = КодВозвратаДиалога.Да Then
		ЗакрытиеФормыПодтверждено = True;
		Закрыть();
	EndIf;

EndProcedure

#EndRegion

ЗакрытиеФормыПодтверждено=False;