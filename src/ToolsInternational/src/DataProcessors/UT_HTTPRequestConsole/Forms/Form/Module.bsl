#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	StartHeader = Заголовок;

	InitializeForm();

	Элементы.RequestBodyEncoding.СписокВыбора.Добавить("Системная");
	Элементы.RequestBodyEncoding.СписокВыбора.Добавить("ANSI");
	Элементы.RequestBodyEncoding.СписокВыбора.Добавить("OEM");
	Элементы.RequestBodyEncoding.СписокВыбора.Добавить("UTF8");
	Элементы.RequestBodyEncoding.СписокВыбора.Добавить("UTF16");

	If Parameters.Property("DebugData") Then
		FillByDebugData(Parameters.DebugData);
	EndIf;

	УстановитьДоступностьТелаЗапроса(ThisObject);
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Элементы.ГруппаКоманднаяПанельФормы);
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	СформироватьЗаголовокНастроекПрокси();
EndProcedure

#EndRegion

#Region FormItemsEvents

&AtClient
Procedure RequestHistorySelection(Item, SelectedRow, Field, StandardProcessing)
	ЗаполнитьДанныеТекущегоЗапросаПоИстории(SelectedRow);
EndProcedure

&AtClient
Procedure RequestHistoryOnActivateRow(Item)
	
	CurrentRow = Items.RequestHistory.CurrentData;
	If CurrentRow = Undefined Then
		Return;
	EndIf;

	If CurrentRow.RequestBodyFormat = "String" Then
		NewPage = Items.RequestHistoryRequestBodyStringPageGroup;
	ElsIf CurrentRow.RequestBodyFormat = "BinaryData" Then
		NewPage = Items.RequestHistoryRequestBodyBinaryDataPageGroup;
	Else
		NewPage = Items.RequestHistoryRequestBodyFilePageGroup;
	EndIf;

	Items.RequestHistoryRequestBodyPagesGroup.CurrentPage = NewPage;

	If IsTempStorageURL(CurrentRow.ResponseBodyAddressString) Then
		ResponseBodyString = GetFromTempStorage(CurrentRow.ResponseBodyAddressString);
	Else
		ResponseBodyString = "";
	EndIf;

	ProxyInspectionOptionsHeader = ЗаголовокНастроекПроксиПоПараметрам(CurrentRow.UseProxy,
		CurrentRow.ProxyServer, CurrentRow.ProxyPort, CurrentRow.ProxyUser, CurrentRow.ProxyPassword,
		CurrentRow.OSAuthentificationProxy);
		
EndProcedure

&AtClient
Procedure RequestHistoryRequestBodyFileNameOpen(Item, StandardProcessing)
	
	StandardProcessing = False;

	CurrentData = Items.RequestHistory.CurrentData;
	If CurrentData = Undefined Then
		Return;
	Endif;

	BeginRunningApplication(UT_CommonClient.ApplicationRunEmptyNotifyDescription(),
		CurrentData.RequestBodyFileName);
		
EndProcedure

&AtClient
Procedure TableHeadersEditorOnChange(Item)
	
	УстановитьСтраницуРедактированияЗаголовковЗапроса();
	
EndProcedure

&AtClient
Procedure RequestHeadersTableKeyAutoComplete(Item, Text, ChoiceData, DataGetParameters, Waiting, StandardProcessing)

	StandardProcessing = False;

	If Not ValueIsFilled(Text) Then
		Return;
	КонецЕсли;

	ChoiceData = New ValueList;

	For Each ListElement In UsedHeadersList Do
	 	If StrFind(Lower(ListElement.Value), Lower(Text)) > 0 Then
			ChoiceData.Add(ListElement.Value);
		EndIf;
	EndDo;

EndProcedure

&AtClient
Procedure RequestBodyFormatOnChange(Item)
	
	StringBodyGroupParamsReadOnly = True;

	If RequestBodyFormat = "String" Then
		NewPage = Items.RequestBodyStringPageGroup;
		StringBodyGroupParamsReadOnly = False;
	ElsIf RequestBodyFormat = "BinaryData" Then
		NewPage = Элементы.RequestBodyBinaryDataPageGroup;
	Else
		NewPage = Элементы.RequestBodyFilePageGroup;
	EndIf;

	Items.RequestBodyPagesGroup.CurrentPage = NewPage;
	Items.RequestBodyStringPropertiesGroup.ReadOnly = StringBodyGroupParamsReadOnly;
	
EndProcedure

&AtClient
Procedure RequestBodyFileNameStartChoice(Item, ChoiceData, StandardProcessing)
	
	FileDialog = New FileDialog(FileDialogMode.Open);
	FileDialog.Multiselect = False;
	FileDialog.FullFileName = RequestBodyFileName;

	FileDialog.Show(New NotifyDescription("RequestBodyFileNameChoiceComplete", ThisObject));
	
EndProcedure

&НаКлиенте
Процедура ЗапросHTTPПриИзменении(Элемент)
	УстановитьДоступностьТелаЗапроса(ThisObject);
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьПроксиПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

&НаКлиенте
Процедура ПроксиСерверПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

&НаКлиенте
Процедура ПроксиПортПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

&НаКлиенте
Процедура ПроксиПользовательПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

&НаКлиенте
Процедура ПроксиПарольПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

&НаКлиенте
Процедура ПроксиАутентификацияОСПриИзменении(Элемент)
	СформироватьЗаголовокНастроекПрокси();
КонецПроцедуры

#EndRegion

#Region FormCommandEvents

&НаКлиенте
Процедура ВыполнитьЗапрос(Команда)
	Если RequestBodyFormat = "Файл" Тогда
		RequestBodyFileAddress = ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(RequestBodyFileName),
			RequestBodyFileAddress);
	КонецЕсли;
	ВыполнитьЗапросНаСервере();
	
	//позиционируем историю запросов на текущую строку
	Если RequestHistory.Количество() > 0 Тогда
		Элементы.RequestHistory.ТекущаяСтрока=RequestHistory[RequestHistory.Количество()
			- 1].ПолучитьИдентификатор();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДвоичныеДанныеТелаИзФайла(Команда)
	НачатьПомещениеФайла(Новый ОписаниеОповещения("ЗаполнитьДвоичныеДанныеТелаИзФайлаЗавершение", ThisObject),
		RequestBodyBinaryDataAddress, "", Истина, УникальныйИдентификатор);
КонецПроцедуры

&НаКлиенте
Процедура СохранитьДвоичныеДанныеТелаЗапросаИзИстории(Команда)
	ТекДанныеИсторииЗапроса = Элементы.RequestHistory.ТекущиеДанные;
	Если ТекДанныеИсторииЗапроса = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если Не ЭтоАдресВременногоХранилища(ТекДанныеИсторииЗапроса.RequestBodyBinaryDataAddress) Тогда
		Возврат;
	КонецЕсли;

	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	ДВФ.МножественныйВыбор = Ложь;

	ПолучаемыеФайлы = Новый Массив;
	ПолучаемыеФайлы.Добавить(Новый ОписаниеПередаваемогоФайла(, ТекДанныеИсторииЗапроса.RequestBodyBinaryDataAddress));

	НачатьПолучениеФайлов(Новый ОписаниеОповещения("СохранитьДвоичныеДанныеТелаЗапросаИзИсторииПриЗавершении",
		ThisObject), ПолучаемыеФайлы, ДВФ, Истина);
КонецПроцедуры

&НаКлиенте
Процедура СохранитьТелоОтветаДвоичныеДанныеВФайл(Команда)
	ТекДанныеИсторииЗапроса = Элементы.RequestHistory.ТекущиеДанные;
	Если ТекДанныеИсторииЗапроса = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если Не ЭтоАдресВременногоХранилища(ТекДанныеИсторииЗапроса.ResponseBodyBinaryDataAddress) Тогда
		Возврат;
	КонецЕсли;

	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	ДВФ.МножественныйВыбор = Ложь;

	ПолучаемыеФайлы = Новый Массив;
	ПолучаемыеФайлы.Добавить(Новый ОписаниеПередаваемогоФайла(, ТекДанныеИсторииЗапроса.ResponseBodyBinaryDataAddress));

	НачатьПолучениеФайлов(Новый ОписаниеОповещения("СохранитьДвоичныеДанныеТелаЗапросаИзИсторииПриЗавершении",
		ThisObject), ПолучаемыеФайлы, ДВФ, Истина);
КонецПроцедуры

&НаКлиенте
Процедура НовыйФайлЗапросов(Команда)
	Если RequestHistory.Количество() = 0 Тогда
		ИнициализироватьКонсоль();
	Иначе
		ПоказатьВопрос(Новый ОписаниеОповещения("НовыйФайлЗапросовЗавершение", ThisObject),
			"История запросов непустая. Продолжить?", РежимДиалогаВопрос.ДаНет, 15, КодВозвратаДиалога.Нет);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФайлЗапросов(Команда)
	Если RequestHistory.Количество() = 0 Тогда
		ЗагрузитьФайлКонсоли();
	Иначе
		ПоказатьВопрос(Новый ОписаниеОповещения("ОткрытьФайлОтчетовЗавершение", ThisObject),
			"История запросов непустая. Продолжить?", РежимДиалогаВопрос.ДаНет, 15, КодВозвратаДиалога.Нет);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция СтруктураОписанияСохраняемогоФайла()
	Структура=UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	Структура.FileName = RequestsFileName;

	// Пока закоментим сохранение в JSON, т.к. библиотека ошибки выдает на двоичных данных
	UT_CommonClient.AddFormatToSavingFileDescription(Структура,
		"Файл запросов консоли HTPP в JSON (*.jhttp)", "jhttp");
	UT_CommonClient.AddFormatToSavingFileDescription(Структура, "Файл запросов консоли HTPP (*.xhttp)",
		"xhttp");

	Возврат Структура;
КонецФункции

&НаКлиенте
Процедура СохранитьЗапросыВФайл(Команда)
	UT_CommonClient.SaveConsoleDataToFile("КонсольHTTPЗапросов", Ложь,
		СтруктураОписанияСохраняемогоФайла(), ПоместитьДанныеИсторииВоВременноеХранилище(),
		Новый ОписаниеОповещения("СохранениеВФайлЗавершение", ThisObject));
КонецПроцедуры

&НаКлиенте
Процедура СохранитьЗапросыВФайлКак(Команда)
	UT_CommonClient.SaveConsoleDataToFile("КонсольHTTPЗапросов", Истина,
		СтруктураОписанияСохраняемогоФайла(), ПоместитьДанныеИсторииВоВременноеХранилище(),
		Новый ОписаниеОповещения("СохранениеВФайлЗавершение", ThisObject));
КонецПроцедуры

&НаКлиенте
Процедура РедактироватьТелоЗапросаВРедактореJSON(Команда)
	UT_CommonClient.EditJSON(RequestBody, Ложь,
		Новый ОписаниеОповещения("РедактироватьТелоЗапросаВРедактореJSONЗавершение", ThisObject));
КонецПроцедуры

&НаКлиенте
Процедура РедактироватьТелоЗапросаВРедактореJSONАнализируемогоЗапроса(Команда)
	UT_CommonClient.EditJSON(Элементы.RequestHistory.ТекущиеДанные.ТелоЗапросаСтрока, Истина);
КонецПроцедуры

&НаКлиенте
Процедура РедактироватьТелоОтветаВРедактореJSONАнализируемогоЗапроса(Команда)
	UT_CommonClient.EditJSON(ResponseBodyString, Истина);
КонецПроцедуры

//@skip-warning
&НаКлиенте
Процедура Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Команда) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Команда);
КонецПроцедуры

#EndRegion

#Region RequestFiles

// Отработка загрузки файла с отчетами из адреса.
&НаКлиенте
Процедура ОтработкаЗагрузкиИзАдреса(Адрес)
	Попытка
		ЗагрузитьФайлКонсолиНаСервере(Адрес);
		InitializeRequest();
	Исключение
		RequestsFileName = "";
		Возврат;
	КонецПопытки;
	ОбновитьЗаголовок();
КонецПроцедуры

// Загрузить файл консоли на сервере.
//
// Параметры:
//  Адрес - адрес хранилища, из которого нужно загрузить файл.
&НаСервере
Процедура ЗагрузитьФайлКонсолиНаСервере(Адрес)

	ТаблицаИстории = Обработки.UT_HTTPRequestConsole.ДанныеСохраненияИзСериализованнойСтроки(Адрес, RequestsFileName);

	RequestHistory.Очистить();

	Для Каждого СтрокаТз Из ТаблицаИстории Цикл
		НС = RequestHistory.Добавить();
		ЗаполнитьЗначенияСвойств(НС, СтрокаТз);

		НС.RequestBodyBinaryDataAddress = ПоместитьВоВременноеХранилище(СтрокаТз.ТелоЗапросаДвоичныеДанные,
			УникальныйИдентификатор);
		НС.ResponseBodyBinaryDataAddress = ПоместитьВоВременноеХранилище(СтрокаТз.ТелоОтветаДвоичныеДанные,
			УникальныйИдентификатор);
		НС.АдресТелаОтветаСтрокой = ПоместитьВоВременноеХранилище(СтрокаТз.ТелоОтвета, УникальныйИдентификатор);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьФайлКонсолиПослеПомещенияФайла(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	RequestsFileName = Результат.ИмяФайла;
	ОтработкаЗагрузкиИзАдреса(Результат.Адрес);

КонецПроцедуры

// Загрузить файл.
//
// Параметры:
//  ЗагружаемоеИмяФайла - имя файла, из которого нужно загрузить. Если имя файла
//						  пустое, то нужно запросить у пользователя имя файла.
&НаКлиенте
Процедура ЗагрузитьФайлКонсоли()

	UT_CommonClient.ReadConsoleFromFile("КонсольHTTPЗапросов",
		СтруктураОписанияСохраняемогоФайла(), Новый ОписаниеОповещения("ЗагрузитьФайлКонсолиПослеПомещенияФайла",
		ThisObject));

КонецПроцедуры

// Завершение обработчика открытия файла.
&НаКлиенте
Процедура ОткрытьФайлОтчетовЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт

	Если РезультатВопроса = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	ЗагрузитьФайлКонсоли();

КонецПроцедуры

&НаКлиенте
Процедура ИнициализироватьКонсоль()
	RequestHistory.Очистить();
	InitializeRequest();
КонецПроцедуры

// Завершение обработчика создания нового файла запросов.
&НаКлиенте
Процедура НовыйФайлЗапросовЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт

	Если РезультатВопроса = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;

	ИнициализироватьКонсоль();

КонецПроцедуры

// Завершение обработчика открытия файла.
&НаКлиенте
Процедура СохранениеВФайлЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	RequestsFileName=Результат;
	Модифицированность = Ложь;
	ОбновитьЗаголовок();

КонецПроцедуры

// Поместить файл во временное хранилище.
&НаСервере
Функция ПоместитьДанныеИсторииВоВременноеХранилище()

	ТаблицаЗначенийИстории = РеквизитФормыВЗначение("RequestHistory");

	ТаблицаЗначенийИстории.Колонки.Добавить("RequestBodyBinaryData");
	ТаблицаЗначенийИстории.Колонки.Добавить("ResponseBodyBinaryData");
	ТаблицаЗначенийИстории.Колонки.Добавить("ResponseBody");
	Для Каждого СтрокаТЗ Из ТаблицаЗначенийИстории Цикл
		Если ЭтоАдресВременногоХранилища(СтрокаТЗ.RequestBodyBinaryDataAddress) Тогда
			СтрокаТЗ.RequestBodyBinaryData = ПолучитьИзВременногоХранилища(СтрокаТЗ.RequestBodyBinaryDataAddress);
		КонецЕсли;
		Если ЭтоАдресВременногоХранилища(СтрокаТЗ.ResponseBodyBinaryDataAddress) Тогда
			СтрокаТЗ.ResponseBodyBinaryData = ПолучитьИзВременногоХранилища(СтрокаТЗ.ResponseBodyBinaryDataAddress);
		КонецЕсли;
		Если ЭтоАдресВременногоХранилища(СтрокаТЗ.ResponseBodyAddressString) Тогда
			СтрокаТЗ.ResponseBody = ПолучитьИзВременногоХранилища(СтрокаТЗ.ResponseBodyAddressString);
		КонецЕсли;
	КонецЦикла;

	ТаблицаЗначенийИстории.Колонки.Удалить("RequestBodyBinaryDataAddress");
	ТаблицаЗначенийИстории.Колонки.Удалить("ResponseBodyBinaryDataAddress");
	ТаблицаЗначенийИстории.Колонки.Удалить("ResponseBodyAddressString");

	Результат = ПоместитьВоВременноеХранилище(ТаблицаЗначенийИстории, УникальныйИдентификатор);
	Возврат Результат;

	СериализаторJSON=Обработки.УИ_ПреобразованиеДанныхJSON.Создать();

	СтруктураИстории=СериализаторJSON.ЗначениеВСтруктуру(ТаблицаЗначенийИстории);
	JSONСтрокаИстории=СериализаторJSON.ЗаписатьОписаниеОбъектаВJSON(СтруктураИстории);
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла();

	ЗначениеВФайл(ИмяВременногоФайла, ТаблицаЗначенийИстории);
	Результат = ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(ИмяВременногоФайла));

	Попытка
		УдалитьФайлы(ИмяВременногоФайла);
	Исключение
	КонецПопытки;

	Возврат Результат;

КонецФункции

#EndRegion

#Region RequestExecute

&НаСервере
Функция ПодготовленноеСоединение(СтруктураURL)
	Порт = Неопределено;
	Если ЗначениеЗаполнено(СтруктураURL.Порт) Тогда
		Порт = СтруктураURL.Порт;
	КонецЕсли;
	Если UseProxy Тогда
		НастройкаПрокси = Новый ИнтернетПрокси(Истина);
		НастройкаПрокси.Установить(СтруктураURL.Схема, ProxyServer, ProxyPort, ProxyUser, ProxyPassword,
			OSAuthentificationProxy);
	Иначе
		НастройкаПрокси = Неопределено;
	КонецЕсли;

	Если НРег(СтруктураURL.Схема) = "https" Тогда
		СоединениеHTTP = Новый HTTPСоединение(СтруктураURL.Сервер, Порт, , , НастройкаПрокси, Timeout,
			Новый ЗащищенноеСоединениеOpenSSL);
	Иначе
		СоединениеHTTP = Новый HTTPСоединение(СтруктураURL.Сервер, Порт, , , НастройкаПрокси, Timeout);
	КонецЕсли;

	Возврат СоединениеHTTP;
КонецФункции

&НаСервере
Функция ПодготовленныйЗапросHTTP(СтруктураURL)
	НовыйЗапрос = Новый HTTPЗапрос;

	СтрокаЗапроса = СтруктураURL.Путь;

	СтрокаПараметров = "";
	Для Каждого КлючЗначение Из СтруктураURL.ПараметрыЗапроса Цикл
		СтрокаПараметров = СтрокаПараметров + ?(ЗначениеЗаполнено(СтрокаПараметров), "?", "&") + КлючЗначение.Ключ + "="
			+ КлючЗначение.Значение;
	КонецЦикла;

	НовыйЗапрос.АдресРесурса = СтрокаЗапроса + СтрокаПараметров;
	Если Не ЗапросБезТелаЗапроса(HTTPMethod) Тогда
		Если RequestBodyFormat = "Строкой" Тогда
			Если ЗначениеЗаполнено(RequestBody) Тогда
				Если UseBOM = 0 Тогда
					БОМ = ИспользованиеByteOrderMark.Авто;
				ИначеЕсли (UseBOM = 1) Тогда
					БОМ = ИспользованиеByteOrderMark.Использовать;
				Иначе
					БОМ = ИспользованиеByteOrderMark.НеИспользовать;
				КонецЕсли;

				Если RequestBodyEncoding = "Авто" Тогда
					НовыйЗапрос.УстановитьТелоИзСтроки(RequestBody, , БОМ);
				Иначе

					НовыйЗапрос.УстановитьТелоИзСтроки(RequestBody, RequestBodyEncoding, БОМ);
				КонецЕсли;
			КонецЕсли;
		ИначеЕсли RequestBodyFormat = "ДвоичныеДанные" Тогда
			ДвоичныеДанныеТела = ПолучитьИзВременногоХранилища(RequestBodyBinaryDataAddress);
			Если ТипЗнч(ДвоичныеДанныеТела) = Тип("ДвоичныеДанные") Тогда
				НовыйЗапрос.УстановитьТелоИзДвоичныхДанных(ДвоичныеДанныеТела);
			КонецЕсли;
		Иначе
			ДвоичныеДанныеТела = ПолучитьИзВременногоХранилища(RequestBodyFileAddress);
			Если ТипЗнч(ДвоичныеДанныеТела) = Тип("ДвоичныеДанные") Тогда
				Файл = Новый Файл(RequestBodyFileName);
				ВременныйФайл = ПолучитьИмяВременногоФайла(Файл.Расширение);
				ДвоичныеДанныеТела.Записать(ВременныйФайл);

				НовыйЗапрос.УстановитьИмяФайлаТела(ВременныйФайл);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	//Теперь нужно установить заголовки запроса
	Если TableHeadersEditor Тогда
		Заголовки = Новый Соответствие;

		Для Каждого СтрокаЗаголовка Из RequestHeadersTable Цикл
			Заголовки.Вставить(СтрокаЗаголовка.Key, СтрокаЗаголовка.Value);
		КонецЦикла;
	Иначе
		Заголовки = UT_CommonClientServer.HTTPRequestHeadersFromString(HeadersString);
	КонецЕсли;

	НовыйЗапрос.Заголовки = Заголовки;

	Возврат НовыйЗапрос;
КонецФункции

&НаСервере
Процедура ВыполнитьЗапросНаСервере()
	СтруктураURL = UT_HTTPConnector.ParseURL(RequestURL);

	СоединениеHTTP = ПодготовленноеСоединение(СтруктураURL);

	НачалоВыполнения = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Запрос = ПодготовленныйЗапросHTTP(СтруктураURL);
	ДатаНачала = ТекущаяДата();
	Попытка
		Если HTTPMethod = "GET" Тогда
			Ответ = СоединениеHTTP.Получить(Запрос);
		ИначеЕсли HTTPMethod = "POST" Тогда
			Ответ = СоединениеHTTP.ОтправитьДляОбработки(Запрос);
		ИначеЕсли HTTPMethod = "DELETE" Тогда
			Ответ = СоединениеHTTP.Удалить(Запрос);
		ИначеЕсли HTTPMethod = "PUT" Тогда
			Ответ = СоединениеHTTP.Записать(Запрос);
		ИначеЕсли HTTPMethod = "PATCH" Тогда
			Ответ = СоединениеHTTP.Изменить(Запрос);
		Иначе
			Возврат;
		КонецЕсли;
	Исключение

	КонецПопытки;
	ОкончаниеВыполнения = ТекущаяУниверсальнаяДатаВМиллисекундах();

	ДлительностьВМилисекундах = ОкончаниеВыполнения - НачалоВыполнения;

	ЗафиксироватьЛогЗапроса(СтруктураURL.Сервер, СтруктураURL.Схема, Запрос, Ответ, ДатаНачала,
		ДлительностьВМилисекундах);

	ДополнитьСписокИспользованныхРанееЗаголовков(Запрос.Заголовки);
КонецПроцедуры

&НаСервере
Процедура ДополнитьСписокИспользованныхРанееЗаголовков(Заголовки)
	Для Каждого КлючЗначение Из Заголовки Цикл
		Если UsedHeadersList.НайтиПоЗначению(КлючЗначение.Ключ) = Неопределено Тогда
			UsedHeadersList.Добавить(КлючЗначение.Ключ);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура ЗафиксироватьЛогЗапроса(АдресСервера, Протокол, HTTPЗапрос, HTTPОтвет, ДатаНачала, Длительность)

		//	Если HTTPОтвет = Неопределено Тогда 
	//		Ошибка = Истина;
	//	Иначе 
	//		Ошибка=Не ПроверитьУспешностьВыполненияЗапроса(HTTPОтвет);//.HTTPStatusCode<>КодУспешногоЗапроса;
	//	КонецЕсли;
	ЗаписьЛога = RequestHistory.Добавить();
	ЗаписьЛога.URL = RequestURL;

	ЗаписьЛога.HTTPMethod = HTTPMethod;
	ЗаписьЛога.ServerAddress = АдресСервера;
	ЗаписьЛога.Date = ДатаНачала;
	ЗаписьЛога.RequestTiming = Длительность;
	ЗаписьЛога.Request = HTTPЗапрос.АдресРесурса;
	ЗаписьЛога.RequestHeaders = UT_CommonClientServer.GetHTTPHeadersString(HTTPЗапрос.Заголовки);
	ЗаписьЛога.BOM = UseBOM;
	ЗаписьЛога.RequestBodyEncoding = RequestBodyEncoding;
	ЗаписьЛога.RequestBodyFormat = RequestBodyFormat;
	ЗаписьЛога.Timeout = Timeout;

	ЗаписьЛога.RequestBodyString = HTTPЗапрос.ПолучитьТелоКакСтроку();

	ДвоичныеДанныеТела = HTTPЗапрос.ПолучитьТелоКакДвоичныеДанные();
	ЗаписьЛога.RequestBodyBinaryDataAddress = ПоместитьВоВременноеХранилище(ДвоичныеДанныеТела,
		УникальныйИдентификатор);
	ЗаписьЛога.RequestBodyBinaryDataString = Строка(ДвоичныеДанныеТела);
	ЗаписьЛога.RequestBodyFileName = RequestBodyFileName;
	ЗаписьЛога.Protocol = Протокол;

	// Прокси
	ЗаписьЛога.UseProxy = UseProxy;
	ЗаписьЛога.ProxyServer = ProxyServer;
	ЗаписьЛога.ProxyPort = ProxyPort;
	ЗаписьЛога.ProxyUser = ProxyUser;
	ЗаписьЛога.ProxyPassword = ProxyPassword;
	ЗаписьЛога.OSAuthentificationProxy = OSAuthentificationProxy;

	ЗаписьЛога.HTTPStatusCode = ?(HTTPОтвет = Неопределено, 500, HTTPОтвет.КодСостояния);

	Если HTTPОтвет = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ЗаписьЛога.ResponseHeaders = UT_CommonClientServer.GetHTTPHeadersString(HTTPОтвет.Заголовки);

	ТелоОтветаСтрокойЛог = HTTPОтвет.ПолучитьТелоКакСтроку();
	Если ЗначениеЗаполнено(ТелоОтветаСтрокойЛог) Тогда
		Если НайтиНедопустимыеСимволыXML(ТелоОтветаСтрокойЛог) = 0 Тогда
			ЗаписьЛога.АдресТелаОтветаСтрокой = ПоместитьВоВременноеХранилище(ТелоОтветаСтрокойЛог,
				УникальныйИдентификатор);
		Иначе
			ЗаписьЛога.АдресТелаОтветаСтрокой = ПоместитьВоВременноеХранилище("Содержит недопустимые символы XML",
				УникальныйИдентификатор);
		КонецЕсли;
	КонецЕсли;
	ДвоичныеДанныеОтвета = HTTPОтвет.ПолучитьТелоКакДвоичныеДанные();
	Если ДвоичныеДанныеОтвета <> Неопределено Тогда
		ЗаписьЛога.ResponseBodyBinaryDataAddress = ПоместитьВоВременноеХранилище(ДвоичныеДанныеОтвета,
			УникальныйИдентификатор);
		ЗаписьЛога.ResponseBodyBinaryDataString = Строка(ДвоичныеДанныеОтвета);
	КонецЕсли;

	ИмяФайлаОтвета = HTTPОтвет.ПолучитьИмяФайлаТела();
	Если ИмяФайлаОтвета <> Неопределено Тогда
		Файл = Новый Файл(ИмяФайлаОтвета);
		Если Файл.Существует() Тогда
			ДвоичныеДанныеОтвета = Новый ДвоичныеДанные(ИмяФайлаОтвета);
			ЗаписьЛога.ResponseBodyBinaryDataAddress = ПоместитьВоВременноеХранилище(ДвоичныеДанныеОтвета,
				УникальныйИдентификатор);
			ЗаписьЛога.ResponseBodyBinaryDataString = Строка(ДвоичныеДанныеОтвета);

		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

#EndRegion

#Region UtilizationProceduresAndFunctions

// Обновить заголовок формы.
&НаКлиенте
Процедура ОбновитьЗаголовок()

	Заголовок = StartHeader + ?(RequestsFileName <> "", ": " + RequestsFileName, "");

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ЗаголовокНастроекПроксиПоПараметрам(ИспользоватьПрокси, Сервер, Порт, Пользователь, Пароль, АутентификацияОС)

	ПрефиксЗаголовка = "";

	Если ИспользоватьПрокси Тогда
		ЗаголовокГруппыПрокси = ПрефиксЗаголовка + Сервер;
		Если ЗначениеЗаполнено(Порт) Тогда
			ЗаголовокГруппыПрокси = ЗаголовокГруппыПрокси + ":" + Формат(Порт, "ЧГ=0;");
		КонецЕсли;

		Если АутентификацияОС Тогда
			ЗаголовокГруппыПрокси = ЗаголовокГруппыПрокси + "; Аутентификация ОС";
		ИначеЕсли ЗначениеЗаполнено(Пользователь) Тогда
			ЗаголовокГруппыПрокси = ЗаголовокГруппыПрокси + ";" + Пользователь;
		КонецЕсли;

	Иначе
		ЗаголовокГруппыПрокси = ПрефиксЗаголовка + " Не используется";
	КонецЕсли;

	Возврат ЗаголовокГруппыПрокси;
КонецФункции

&AtClient
Procedure СформироватьЗаголовокНастроекПрокси()
	ProxyOptionsHeader = ЗаголовокНастроекПроксиПоПараметрам(UseProxy, ProxyServer, ProxyPort,
		ProxyUser, ProxyPassword, OSAuthentificationProxy);
КонецПроцедуры

&НаКлиенте
Процедура СохранитьДвоичныеДанныеТелаЗапросаИзИсторииПриЗавершении(ПолученныеФайлы, ДополнительныеПараметры) Экспорт
	Если ПолученныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ЗапросБезТелаЗапроса(ВидЗапросаHTTP)
	МассивЗапросовБезТела = Новый Массив;
	МассивЗапросовБезТела.Добавить("GET");
	МассивЗапросовБезТела.Добавить("DELETE");

	Возврат МассивЗапросовБезТела.Найти(ВРег(ВидЗапросаHTTP)) <> Неопределено;

КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьТелаЗапроса(Форма)
	Форма.Элементы.ГруппаТелоЗапроса.ТолькоПросмотр = ЗапросБезТелаЗапроса(Форма.HTTPMethod);
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДвоичныеДанныеТелаИзФайлаЗавершение(Результат, Адрес, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт
	Если Не Результат Тогда
		Возврат;
	КонецЕсли;

	RequestBodyBinaryDataAddress = Адрес;

	RequestBodyBinaryDataString = Строка(ПолучитьИзВременногоХранилища(Адрес));
КонецПроцедуры

&AtClient
Procedure RequestBodyFileNameChoiceComplete(SelectedFiles, AdditionalParameters) Export

	If SelectedFiles = Undefined Then
		Return;
	EndIf;

	If SelectedFiles.Count() = 0 Then
		Return;
	EndIf;

	RequestBodyFileName = SelectedFiles[0];
	
EndProcedure

&НаСервере
Процедура ЗаполнитьТаблицуЗаголовковПоСтроке(СтрокаЗаголовков)
	ЗаголовкиПоСтроке = UT_CommonClientServer.HTTPRequestHeadersFromString(СтрокаЗаголовков);

	RequestHeadersTable.Очистить();

	Для Каждого КлючЗначение Из ЗаголовкиПоСтроке Цикл
		НС = RequestHeadersTable.Добавить();
		НС.Key = КлючЗначение.Key;
		НС.Value = КлючЗначение.Value;
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтраницуРедактированияЗаголовковЗапроса()
	Если TableHeadersEditor Тогда
		НоваяСтраница = Элементы.ГруппаСтраницаРедактированияЗаголовковЗапросаТаблицей;
	Иначе
		НоваяСтраница = Элементы.ГруппаСтраницаРедактированияЗаголовковЗапросаТекстом;
	КонецЕсли;

	Элементы.ГруппаСраницыРедактированияЗаголовковЗапроса.ТекущаяСтраница = НоваяСтраница;

	//Теперь нужно заполнить заголовки на новой странице по старой странице
	Если TableHeadersEditor Тогда
		ЗаполнитьТаблицуЗаголовковПоСтроке(HeadersString);
	Иначе
		HeadersString = UT_CommonClientServer.GetHTTPHeadersString(RequestHeadersTable);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДанныеТекущегоЗапросаПоИстории(ВыбраннаяСтрока)

//Нужно установить текущую строку в параметры выполнения запроса
	ТекДанные = RequestHistory.НайтиПоИдентификатору(ВыбраннаяСтрока);

	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;

	HTTPMethod = ТекДанные.HTTPMethod;
	RequestURL = ТекДанные.URL;
	HeadersString = ТекДанные.RequestHeaders;
	RequestBody = ТекДанные.RequestBodyString;
	RequestBodyEncoding = ТекДанные.RequestBodyEncoding;
	UseBOM = ТекДанные.BOM;
	RequestBodyFormat = ТекДанные.RequestBodyFormat;
	RequestBodyFormatOnChange(Элементы.RequestBodyFormat);
	RequestBodyFileName = ТекДанные.RequestBodyFileName;
	Timeout=ТекДанные.Timeout;

	UseProxy = ТекДанные.UseProxy;
	ProxyServer = ТекДанные.ProxyServer;
	ProxyPort = ТекДанные.ProxyPort;
	ProxyUser = ТекДанные.ProxyUser;
	ProxyPassword = ТекДанные.ProxyPassword;
	OSAuthentificationProxy = ТекДанные.OSAuthentificationProxy;

	Если ЭтоАдресВременногоХранилища(ТекДанные.RequestBodyBinaryDataAddress) Тогда
		ДвоичныеДанныеТелаЗапроса = ПолучитьИзВременногоХранилища(ТекДанные.RequestBodyBinaryDataAddress);
		RequestBodyBinaryDataString = Строка(ДвоичныеДанныеТелаЗапроса);
		Если ТипЗнч(ДвоичныеДанныеТелаЗапроса) = Тип("ДвоичныеДанные") Тогда
			RequestBodyBinaryDataAddress = ПоместитьВоВременноеХранилище(ДвоичныеДанныеТелаЗапроса,
				RequestBodyBinaryDataAddress);
		КонецЕсли;
	КонецЕсли;

	RequestHeadersTable.Очистить();
	Если TableHeadersEditor Тогда
		ЗаполнитьТаблицуЗаголовковПоСтроке(HeadersString);
	КонецЕсли;

	Элементы.ГруппаСтраницыЗапроса.ТекущаяСтраница = Элементы.ГруппаЗапрос;
КонецПроцедуры

&AtServer
Procedure FillByDebugData(DebugDataAddress)
	
	DebugData = GetFromTempStorage(DebugDataAddress);

	RequestURL = "";
	If Not ValueIsFilled(DebugData.Protocol) Then
		RequestURL = "http";
	Else
		RequestURL = DebugData.Protocol;
	EndIf;

	RequestURL = RequestURL + "://" + DebugData.ServerAddress;

	If ValueIsFilled(DebugData.Port) Then
		RequestURL = RequestURL + ":" + Format(DebugData.Port, "ЧГ=0;");
	EndIf;

	If Not StrStartsWith(DebugData.Request, "/") Then
		RequestURL = RequestURL + "/";
	EndIf;

	RequestURL = RequestURL + DebugData.Request;
	TableHeadersEditor = True;

	Items.ГруппаСраницыРедактированияЗаголовковЗапроса.CurrentPage = Элементы.ГруппаСтраницаРедактированияЗаголовковЗапросаТаблицей;

	RequestHeaders = DebugData.RequestHeaders;

	//Удаляем неиспользуемые символы из строки заголовков
	SymPos = НайтиНедопустимыеСимволыXML(RequestHeaders);
	While (SymPos > 0) do
		If SymPos = 1 Then
			RequestHeaders = Mid(RequestHeaders, 2);
		ElsIf SymPos = StrLen(RequestHeaders) Then
			RequestHeaders = Left(RequestHeaders, StrLen(RequestHeaders) - 1);
		Else
			NewHeaders = Left(RequestHeaders, SymPos - 1) + Mid(RequestHeaders, SymPos + 1);
			RequestHeaders = NewHeaders;
		EndIf;


		SymPos = НайтиНедопустимыеСимволыXML(RequestHeaders);
	EndDo;

	ЗаполнитьТаблицуЗаголовковПоСтроке(RequestHeaders);

	If DebugData.RequestBody = Undefined Then
		RequestBody = "";
	Иначе
		RequestBody = DebugData.RequestBody;
	КонецЕсли;

	If DebugData.Property("RequestBodyBinaryData") Then
		If TypeOf(DebugData.RequestBodyBinaryData) = Type("BinaryData") Тогда
			RequestBodyBinaryDataAddress = PutToTempStorage(DebugData.RequestBodyBinaryData,
				RequestBodyBinaryDataAddress);
			RequestBodyBinaryDataString = DebugData.RequestBodyBinaryDataString;
		EndIf;
	EndIf;
	
	If DebugData.Property("RequestBodyFileName") Then
		RequestBodyFileName = DebugData.RequestBodyFileName;
	EndIf;

	If ValueIsFilled(DebugData.ProxyServer) Then
		UseProxy = True;

		ProxyServer = DebugData.ProxyServer;
		ProxyPort = DebugData.ProxyPort;
		ProxyUser = DebugData.ProxyUser;
		ProxyPassword = DebugData.ProxyPassword;
		OSAuthentificationProxy = DebugData.OSAuthentificationProxy;
	Else
		UseProxy = False;
	EndIf;
	
EndProcedure

&AtServer
Procedure InitializeForm()
	
	HTTPMethod = "GET";
	RequestBodyEncoding = "Auto";
	RequestBodyFormat = "String";
	Timeout=30;
	RequestBodyFileAddress = PutToTempStorage(New Structure, UUID);
	RequestBodyBinaryDataAddress = PutToTempStorage(Undefined, UUID);
	
EndProcedure

&AtClient
Procedure InitializeRequest()
	
	HTTPMethod = "GET";
	RequestBodyEncoding = "Auto";
	RequestBodyFormat = "String";
	RequestBodyFileAddress = PutToTempStorage(New Structure, UUID);
	RequestBodyBinaryDataAddress = PutToTempStorage(Undefined, UUID);
	RequestURL = "";
	UseBOM = 0;

	//proxy
	UseProxy = False;
	ProxyServer = "";
	ProxyPort = 0;
	ProxyUser = "";
	ProxyPassword = "";
	OSAuthentificationProxy = False;

	HeadersString = "";
	RequestHeadersTable.Clear();

	RequestBody = "";
	RequestBodyBinaryDataString = "";
	RequestBodyFileName = "";
	
EndProcedure

&AtClient
Procedure РедактироватьТелоЗапросаВРедактореJSONЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	RequestBody=Результат;
EndProcedure

#EndRegion