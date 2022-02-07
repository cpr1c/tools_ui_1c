

#Область ОписаниеПеременных

#КонецОбласти

#Область EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ИсточникиКода = UT_CodeEditorServer.ДоступныеИсточникиИсходногоКода();
	
	Для Каждого ТекИсточник ИЗ ИсточникиКода Цикл
		НС = SaveDirectories.Добавить();
		НС.Check = Истина;
		НС.Source = ТекИсточник.Значение;
		НС.OnlyModules = Истина;
		
		НС.Directory = Параметры.ТекущиеКаталоги[НС.Source];
	КонецЦикла;

	СтрокаСоединения = СтрокаСоединенияИнформационнойБазы();

	МассивПоказателейСтрокиСоединения = СтрРазделить(СтрокаСоединения, ";");
	СоответствиеПоказателейСтрокиСоединения = Новый Структура;
	Для Каждого СтрокаПоказателяСтрокиСоединения Из МассивПоказателейСтрокиСоединения Цикл
		МассивПоказателя = СтрРазделить(СтрокаПоказателяСтрокиСоединения, "=");
		Если МассивПоказателя.Количество() <> 2 Тогда
			Продолжить;
		КонецЕсли;
		Показатель = НРег(МассивПоказателя[0]);
		ЗначениеПоказателя = МассивПоказателя[1];
		СоответствиеПоказателейСтрокиСоединения.Вставить(Показатель, ЗначениеПоказателя);
	КонецЦикла;

	Если СоответствиеПоказателейСтрокиСоединения.Свойство("file") Тогда
		InfobasePlacement = 0;
		InfobaseDirectory = UT_StringFunctionsClientServer.PathWithoutQuotes(
			СоответствиеПоказателейСтрокиСоединения.File);
	ИначеЕсли СоответствиеПоказателейСтрокиСоединения.Свойство("srvr") Тогда
		InfobasePlacement = 1;
		InfobaseServer = UT_StringFunctionsClientServer.PathWithoutQuotes(СоответствиеПоказателейСтрокиСоединения.srvr);
		DataBaseName = UT_StringFunctionsClientServer.PathWithoutQuotes(СоответствиеПоказателейСтрокиСоединения.ref);
	КонецЕсли;
	User = ИмяПользователя();

	УстановитьВидимостьДоступность();
	
EndProcedure


&AtServer
Procedure FillCheckProcessingAtServer(Cancel, CheckedAttributes)
	Для Каждого Стр Из SaveDirectories Цикл
		Если Не Стр.Check Тогда
			Продолжить;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(Стр.Каталог) Тогда
			UT_CommonClientServer.MessageToUser("Для источника "+Стр.Source+" не указан Directory сохранения", , , , Cancel);
		КонецЕсли;
	КонецЦикла;
	
	Если InfobasePlacement = 0 Тогда
		CheckedAttributes.Добавить("InfobaseDirectory");
	Иначе
		CheckedAttributes.Добавить("InfobaseServer");
		CheckedAttributes.Добавить("InfoBaseName");
	КонецЕсли;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	#Если Не ВебКлиент И Не МобильныйКлиент Тогда
	PlatformLaunchFile = КаталогПрограммы();
	Если Прав(PlatformLaunchFile, 1) <> ПолучитьРазделительПути() Тогда
		PlatformLaunchFile = PlatformLaunchFile + ПолучитьРазделительПути();
	КонецЕсли;
	
	PlatformLaunchFile = PlatformLaunchFile + "1cv8";	
	Если UT_CommonClientServer.IsWindows() Тогда
		PlatformLaunchFile = PlatformLaunchFile + ".exe";
	КонецЕсли;
	
	#КонецЕсли
EndProcedure

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&AtClient
Procedure InfobasePlacementOnChange(Item)
	УстановитьВидимостьДоступность();
EndProcedure

&AtClient
Procedure PlatformLaunchFileStartChoice(Item, ChoiceData, StandardProcessing)
	ОписаниеФайла = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	ОписаниеФайла.ИмяФайла = PlatformLaunchFile;

	ИмяФайла = "1cv8";
	
	Если UT_CommonClientServer.IsWindows() Тогда
		ИмяФайла = ИмяФайла+".exe";
	КонецЕсли;
	
	UT_CommonClient.AddFormatToSavingFileDescription(ОписаниеФайла, "Файл толстого клиента 1С("+ИмяФайла+")", "",ИмяФайла);
	
	UT_CommonClient.FormFieldFileNameStartChoice(ОписаниеФайла, Item, ChoiceData, StandardProcessing,
		РежимДиалогаВыбораФайла.Открытие,
		Новый ОписаниеОповещения("ФайлЗапускаПлатформыНачалоВыбораЗавершение", ЭтотОбъект));
EndProcedure

&AtClient
Procedure SaveDirectoriesDirectoryStartChoice(Item, ChoiceData, StandardProcessing)
	ТекДанные = Элементы.SaveDirectories.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОписаниеФайла = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	ОписаниеФайла.ИмяФайла = ТекДанные.Directory;
	
	ДопПараметрыОповещения = Новый Структура;
	ДопПараметрыОповещения.Вставить("ТекущаяСтрока", Элементы.SaveDirectories.ТекущаяСтрока);
	
	UT_CommonClient.FormFieldFileNameStartChoice(ОписаниеФайла, Item, ChoiceData, StandardProcessing,
		РежимДиалогаВыбораФайла.ВыборКаталога,
		Новый ОписаниеОповещения("КаталогиСохраненияКаталогНачалоВыбораЗаверешение", ЭтотОбъект,
		ДопПараметрыОповещения));
EndProcedure

&AtClient
Procedure InfobaseDirectoryStartChoice(Item, ChoiceData, StandardProcessing)
	ОписаниеФайла = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	ОписаниеФайла.ИмяФайла = InfobaseDirectory;
	
	UT_CommonClient.FormFieldFileNameStartChoice(ОписаниеФайла, Item, ChoiceData, StandardProcessing,
		РежимДиалогаВыбораФайла.ВыборКаталога,
		Новый ОписаниеОповещения("КаталогиСохраненияКаталогНачалоВыбораЗаверешение", ЭтотОбъект));
EndProcedure

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура SelectCommonSaveDirectory(Команда)
	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	ДВФ.МножественныйВыбор = Ложь;
	ДВФ.Показать(Новый ОписаниеОповещения("ВыбратьОбщийКаталогСохраненияЗавершение", ЭтотОбъект));
КонецПроцедуры

&НаКлиенте
Процедура SetChecks(Command)
	Для Каждого Стр Из SaveDirectories Цикл
		Стр.Check = Истина;
	КонецЦикла;
КонецПроцедуры

&AtClient
Procedure UnsetChecks(Command)
	Для Каждого Стр Из SaveDirectories Цикл
		Стр.Check = Ложь;
	КонецЦикла;	
EndProcedure

&НаКлиенте
Процедура UnloadSourceModules(Command)
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	КаталогиИсточников= Новый Массив();
	
	Для Каждого Стр Из SaveDirectories Цикл
		Если Не Стр.Check Тогда
			Продолжить;
		КонецЕсли;
		
		ОписаниеИсточника = Новый Структура;
		ОписаниеИсточника.Вставить("Source", Стр.Источник);
		ОписаниеИсточника.Вставить("Directory", Стр.Каталог);
		ОписаниеИсточника.Вставить("OnlyModules", Стр.OnlyModules);
		
		КаталогиИсточников.Добавить(ОписаниеИсточника);
	КонецЦикла;
	
	НастройкиСохранения = Новый Структура;
	НастройкиСохранения.Вставить("PlatformLaunchFile", PlatformLaunchFile);
	НастройкиСохранения.Вставить("User", User);
	НастройкиСохранения.Вставить("Password", Password);
	НастройкиСохранения.Вставить("КаталогиИсточников", КаталогиИсточников);
	НастройкиСохранения.Вставить("InfobasePlacement", InfobasePlacement);
	Если InfobasePlacement = 0 Тогда
		НастройкиСохранения.Вставить("InfobaseDirectory", InfobaseDirectory);
	Иначе
		НастройкиСохранения.Вставить("InfobaseServer", InfobaseServer);
		НастройкиСохранения.Вставить("InfoBaseName", InfoBaseName);
	КонецЕсли;
	
	Закрыть(НастройкиСохранения);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьВидимостьДоступность()
	Если InfobasePlacement = 0 Тогда
		НоваяСтраница = Элементы.GroupFileInfobase;
	Иначе
		НоваяСтраница = Элементы.GroupServerInfoBase;
	КонецЕсли;
	
	Элементы.GroupPagesInfobasePlacement.ТекущаяСтраница = НоваяСтраница;
КонецПроцедуры

&НаКлиенте
Процедура ФайлЗапускаПлатформыНачалоВыбораЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Количество() = 0  Тогда
		Возврат;
	КонецЕсли;
	
	PlatformLaunchFile = Результат[0];
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьОбщийКаталогСохраненияЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Количество()=0 Тогда
		Возврат;
	КонецЕсли;
	
	ОбщийКаталогСохранения = Результат[0];
	
	Для Каждого ТекСТр Из SaveDirectories Цикл
//		Если ЗначениеЗаполнено(ТекСТр.Directory) Тогда
//			Продолжить;
//		КонецЕсли;
//		
		ТекСТр.Directory = ОбщийКаталогСохранения + ПолучитьРазделительПути() + ТекСТр.Source;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура КаталогиСохраненияКаталогНачалоВыбораЗаверешение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Количество()=0 Тогда
		Возврат;
	КонецЕсли;
	
	ТекДанные = SaveDirectories.НайтиПоИдентификатору(ДополнительныеПараметры.ТекущаяСтрока);
	ТекДанные.Directory = Результат[0];
	
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура КаталогИнформационнойБазыНачалоВыбораЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Количество() = 0  Тогда
		Возврат;
	КонецЕсли;
	
	InfobaseDirectory = Результат[0];
	
КонецПроцедуры
#КонецОбласти