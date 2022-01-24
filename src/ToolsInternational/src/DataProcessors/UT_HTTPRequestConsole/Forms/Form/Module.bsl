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

	EnableOrDisableRequestBody(ThisObject);
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.FormCommandPanelGroup);
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	BuildProxyOptionsHeader();
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

	ProxyInspectionOptionsHeader = ProxyOptionsHeaderByParams(CurrentRow.UseProxy,
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
		NewPage = Items.RequestBodyBinaryDataPageGroup;
	Else
		NewPage = Items.RequestBodyFilePageGroup;
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

&AtClient
Procedure HTTPRequestOnChange(Item)
	EnableOrDisableRequestBody(ThisObject);
EndProcedure

&AtClient
Procedure UseProxyOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

&AtClient
Procedure ProxyServerOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

&AtClient
Procedure ProxyPortOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

&AtClient
Procedure ProxyUserOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

&AtClient
Procedure ProxyPasswordOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

&AtClient
Procedure ProxyOSAuthOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

#EndRegion

#Region FormCommandEvents

&AtClient
Procedure ExecuteRequest(Command)
	
	If RequestBodyFormat = "File" Then
		RequestBodyFileAddress = PutToTempStorage(New BinaryData(RequestBodyFileName),
			RequestBodyFileAddress);
	EndIf;
	ExecuteRequestServer();
	
	//place request history to current row
	If RequestHistory.Count() > 0 Then
		Items.RequestHistory.CurrentRow = RequestHistory[RequestHistory.Count() - 1].GetID();
	EndIf;
	
EndProcedure


&AtClient
Procedure FillRequestBinaryDataFromFile(Command)
	НачатьПомещениеФайла(Новый ОписаниеОповещения("ЗаполнитьДвоичныеДанныеТелаИзФайлаЗавершение", ThisObject),
		RequestBodyBinaryDataAddress, "", Истина, УникальныйИдентификатор);
EndProcedure

&AtClient
Procedure SaveRequestBodyBinaryDataFromHistory(Command)
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
EndProcedure

&AtClient
Procedure SaveResponseBodyBinaryDataToFile(Command)
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
EndProcedure

&AtClient
Procedure NewRequestsFile(Command)
	
	Если RequestHistory.Количество() = 0 Тогда
		ИнициализироватьКонсоль();
	Иначе
		ПоказатьВопрос(Новый ОписаниеОповещения("НовыйФайлЗапросовЗавершение", ThisObject),
			"История запросов непустая. Продолжить?", РежимДиалогаВопрос.ДаНет, 15, КодВозвратаДиалога.Нет);
	КонецЕсли;
	
EndProcedure

&AtClient
Procedure OpenRequestsFile(Command)	
	Если RequestHistory.Количество() = 0 Тогда
		ЗагрузитьФайлКонсоли();
	Иначе
		ПоказатьВопрос(Новый ОписаниеОповещения("ОткрытьФайлОтчетовЗавершение", ThisObject),
			"История запросов непустая. Продолжить?", РежимДиалогаВопрос.ДаНет, 15, КодВозвратаДиалога.Нет);
	КонецЕсли;
EndProcedure

&AtClient
Function СтруктураОписанияСохраняемогоФайла()
	Структура=UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	Структура.FileName = RequestsFileName;

	// Пока закоментим сохранение в JSON, т.к. библиотека ошибки выдает на двоичных данных
	UT_CommonClient.AddFormatToSavingFileDescription(Структура,
		"Файл запросов консоли HTPP в JSON (*.jhttp)", "jhttp");
	UT_CommonClient.AddFormatToSavingFileDescription(Структура, "Файл запросов консоли HTPP (*.xhttp)",
		"xhttp");

	Возврат Структура;
EndFunction

&AtClient
Procedure SaveRequestsToFile(Command)
	UT_CommonClient.SaveConsoleDataToFile("КонсольHTTPЗапросов", Ложь,
		СтруктураОписанияСохраняемогоФайла(), ПоместитьДанныеИсторииВоВременноеХранилище(),
		Новый ОписаниеОповещения("СохранениеВФайлЗавершение", ThisObject));
EndProcedure

&AtClient
Procedure SaveAsRequestsToFile(Command)
	UT_CommonClient.SaveConsoleDataToFile("КонсольHTTPЗапросов", Истина,
		СтруктураОписанияСохраняемогоФайла(), ПоместитьДанныеИсторииВоВременноеХранилище(),
		Новый ОписаниеОповещения("СохранениеВФайлЗавершение", ThisObject));
EndProcedure

&AtClient
Procedure EditRequestBodyInJSONEditor(Command)
	UT_CommonClient.EditJSON(RequestBody, Ложь,
		Новый ОписаниеОповещения("РедактироватьТелоЗапросаВРедактореJSONЗавершение", ThisObject));
EndProcedure

&AtClient
Procedure EditRequestBodyInJSONEditorAnalyzedRequest(Command)
	UT_CommonClient.EditJSON(Элементы.RequestHistory.ТекущиеДанные.ТелоЗапросаСтрока, Истина);
EndProcedure

&AtClient
Procedure EditResponseBodyInJSONEditorAnalyzedRequest(Command)
	UT_CommonClient.EditJSON(ResponseBodyString, Истина);
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Команда) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Команда);
EndProcedure

#EndRegion

#Region RequestFiles

// Отработка загрузки файла с отчетами из адреса.
&AtClient
Procedure ОтработкаЗагрузкиИзАдреса(Адрес)
	Попытка
		ЗагрузитьФайлКонсолиНаСервере(Адрес);
		InitializeRequest();
	Исключение
		RequestsFileName = "";
		Возврат;
	КонецПопытки;
	ОбновитьЗаголовок();
EndProcedure

// Загрузить файл консоли на сервере.
//
// Параметры:
//  Адрес - адрес хранилища, из которого нужно загрузить файл.
&AtServer
Procedure ЗагрузитьФайлКонсолиНаСервере(Адрес)

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
EndProcedure

&AtClient
Procedure ЗагрузитьФайлКонсолиПослеПомещенияФайла(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	RequestsFileName = Результат.ИмяФайла;
	ОтработкаЗагрузкиИзАдреса(Результат.Адрес);

EndProcedure

// Загрузить файл.
//
// Параметры:
//  ЗагружаемоеИмяФайла - имя файла, из которого нужно загрузить. Если имя файла
//						  пустое, то нужно запросить у пользователя имя файла.
&AtClient
Procedure ЗагрузитьФайлКонсоли()

	UT_CommonClient.ReadConsoleFromFile("КонсольHTTPЗапросов",
		СтруктураОписанияСохраняемогоФайла(), Новый ОписаниеОповещения("ЗагрузитьФайлКонсолиПослеПомещенияФайла",
		ThisObject));

EndProcedure

// Завершение обработчика открытия файла.
&AtClient
Procedure ОткрытьФайлОтчетовЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт

	Если РезультатВопроса = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	ЗагрузитьФайлКонсоли();

EndProcedure

&AtClient
Procedure ИнициализироватьКонсоль()
	RequestHistory.Очистить();
	InitializeRequest();
EndProcedure

// Завершение обработчика создания нового файла запросов.
&AtClient
Procedure НовыйФайлЗапросовЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт

	Если РезультатВопроса = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;

	ИнициализироватьКонсоль();

EndProcedure

// Завершение обработчика открытия файла.
&AtClient
Procedure СохранениеВФайлЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	RequestsFileName=Результат;
	Модифицированность = Ложь;
	ОбновитьЗаголовок();

EndProcedure

// Поместить файл во временное хранилище.
&AtServer
Function ПоместитьДанныеИсторииВоВременноеХранилище()

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

EndFunction

#EndRegion

#Region RequestExecute

&AtServer
Function PreparedConnection(URLStructure)
	
	Port = Undefined;
	If ValueIsFilled(URLStructure.Port) Then
		Port = URLStructure.Port;
	EndIf;
	
	If UseProxy Then
		ProxyOptions = New InternetProxy(True);
		ProxyOptions.Set(URLStructure.Scheme, ProxyServer, ProxyPort, ProxyUser, ProxyPassword,
			OSAuthentificationProxy);
	Else
		ProxyOptions = Undefined;
	EndIf;

	If Lower(URLStructure.Scheme) = "https" Then
		HTTPConnection = New HTTPConnection(URLStructure.Host, Port, , , ProxyOptions, Timeout,
			New OpenSSLSecureConnection);
	Else
		HTTPConnection = New HTTPConnection(URLStructure.Host, Port, , , ProxyOptions, Timeout);
	EndIf;

	Return HTTPConnection;
	
EndFunction

&AtServer
Function PreparedHTTPRequest(URLStructure)
	
	NewRequest = New HTTPRequest;

	RequestString = URLStructure.Path;

	ParamsString = "";
	For Each KeyAndValue Из URLStructure.RequestParameters Do
		ParamsString = ParamsString + ?(ValueIsFilled(ParamsString), "?", "&") + KeyAndValue.Key + "="
			+ KeyAndValue.Value;
	EndDo;

	NewRequest.ResourceAddress = RequestString + ParamsString;
	If Not RequestWithoutBody(HTTPMethod) Then
		If RequestBodyFormat = "String" Then
			If ValueIsFilled(RequestBody) Then
				If (UseBOM = 0) Then
					BOM = ByteOrderMarkUsage.Auto;
				ElsIf (UseBOM = 1) Then
					BOM = ByteOrderMarkUsage.Use;
				Else
					BOM = ByteOrderMarkUsage.DontUse;
				EndIf;

				If RequestBodyEncoding = "Auto" Then
					NewRequest.SetBodyFromString(RequestBody, , BOM);
				Else
					NewRequest.SetBodyFromString(RequestBody, RequestBodyEncoding, BOM);
				EndIf;
			EndIf;
		ElsIf RequestBodyFormat = "BinaryData" Then
			BodyBinaryData = GetFromTempStorage(RequestBodyBinaryDataAddress);
			If TypeOf(BodyBinaryData) = Тип("BinaryData") Then
				NewRequest.SetBodyFromBinaryData(BodyBinaryData);
			EndIf;
		Else
			BodyBinaryData = GetFromTempStorage(RequestBodyFileAddress);
			If TypeOf(BodyBinaryData) = Тип("BinaryData") Then
				File = New File(RequestBodyFileName);
				TempFile = GetTempFileName(File.Extension);
				BodyBinaryData.Write(TempFile);

				NewRequest.SetBodyFileName(TempFile);
			EndIf;
		EndIf;
	EndIf;

	//Now we should set request headers
	If TableHeadersEditor Then
		Headers = New Map();

		For Each HeaderString In RequestHeadersTable Do
			Headers.Insert(HeaderString.Key, HeaderString.Value);
		EndDo;
	Else
		Headers = UT_CommonClientServer.HTTPRequestHeadersFromString(HeadersString);
	EndIf;

	NewRequest.Headers = Headers;

	Return NewRequest;
	
EndFunction

&AtServer
Procedure ExecuteRequestServer()
	
	URLStructure = UT_HTTPConnector.ParseURL(RequestURL);

	HTTPConnection = PreparedConnection(URLStructure);

	ExecutionStart = CurrentUniversalDateInMilliseconds();
	Request = PreparedHTTPRequest(URLStructure);
	DateStart = CurrentDate();
	Try
		If HTTPMethod = "GET" Then
			Response = HTTPConnection.Get(Request);
		ElsIf HTTPMethod = "POST" Then
			Response = HTTPConnection.ОтправитьДляОбработки(Request);
		ElsIf HTTPMethod = "DELETE" Then
			Response = HTTPConnection.Удалить(Request);
		ElsIf HTTPMethod = "PUT" Then
			Response = HTTPConnection.Записать(Request);
		ElsIf HTTPMethod = "PATCH" Then
			Response = HTTPConnection.Изменить(Request);
		Else
			Return;
		EndIf;
	Except

	EndTry;
	ExecutionEnd = CurrentUniversalDateInMilliseconds();

	MillisecondsDuration = ExecutionEnd - ExecutionStart;

	ЗафиксироватьЛогЗапроса(URLStructure.Host, URLStructure.Scheme, Request, Response, DateStart,
		MillisecondsDuration);

	ДополнитьСписокИспользованныхРанееЗаголовков(Request.Headers);
	
EndProcedure

&AtServer
Procedure ДополнитьСписокИспользованныхРанееЗаголовков(Заголовки)
	Для Каждого КлючЗначение Из Заголовки Цикл
		Если UsedHeadersList.НайтиПоЗначению(КлючЗначение.Ключ) = Неопределено Тогда
			UsedHeadersList.Добавить(КлючЗначение.Ключ);
		КонецЕсли;
	КонецЦикла;
EndProcedure

&AtServer
Procedure ЗафиксироватьЛогЗапроса(АдресСервера, Протокол, HTTPЗапрос, HTTPОтвет, ДатаНачала, Длительность)

		//	Если HTTPОтвет = Неопределено Тогда 
	//		Ошибка = Истина;
	//	Иначе 
	//		Ошибка=Не ПроверитьУспешностьВыполненияЗапроса(HTTPОтвет);//.HTTPStatusCode<>КодУспешногоЗапроса;
	//	КонецЕсли;
	ЗаписьЛога = RequestHistory.Добавить();
	ЗаписьЛога.URL = RequestURL;

	ЗаписьЛога.HTTPMethod = HTTPMethod;
	ЗаписьЛога.Host = АдресСервера;
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
	ЗаписьЛога.Scheme = Протокол;

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
EndProcedure

#EndRegion

#Region UtilizationProceduresAndFunctions

// Обновить заголовок формы.
&AtClient
Procedure ОбновитьЗаголовок()

	Заголовок = StartHeader + ?(RequestsFileName <> "", ": " + RequestsFileName, "");

EndProcedure

&AtClientAtServerNoContext
Function ProxyOptionsHeaderByParams(ParamUseProxy, ParamServer, ParamPort, ParamUser, ParamPassword, ParamOSAuth)

	HeaderPrefix = "";

	If ParamUseProxy Then
		
		HeaderGroupProxy = HeaderPrefix + ParamServer;
		If ValueIsFilled(ParamPort) Then
			HeaderGroupProxy = HeaderGroupProxy + ":" + Format(ParamPort, "NG=0;");
		EndIf;

		If ParamOSAuth Then
			HeaderGroupProxy = HeaderGroupProxy + "; OS authentification";
		ElsIf ValueIsFilled(ParamUser) Then
			HeaderGroupProxy = HeaderGroupProxy + ";" + ParamUser;
		EndIf;

	Else
		HeaderGroupProxy = HeaderPrefix + " Не используется";
	EndIf;

	Return HeaderGroupProxy;
	
EndFunction

&AtClient
Procedure BuildProxyOptionsHeader()
	
	ProxyOptionsHeader = ProxyOptionsHeaderByParams(UseProxy, ProxyServer, ProxyPort,
		ProxyUser, ProxyPassword, OSAuthentificationProxy);
		
EndProcedure

&AtClient
Procedure СохранитьДвоичныеДанныеТелаЗапросаИзИсторииПриЗавершении(ПолученныеФайлы, ДополнительныеПараметры) Экспорт
	Если ПолученныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;

EndProcedure

&AtClientAtServerNoContext
Function RequestWithoutBody(HTTPMethodType)
	
	MethodList = New Array;
	MethodList.Add("GET");
	MethodList.Add("DELETE");

	Return MethodList.Find(Upper(HTTPMethodType)) <> Undefined;

EndFunction

&AtClientAtServerNoContext
Procedure EnableOrDisableRequestBody(Form)
	
	Form.Items.RequestBodyGroup.ReadOnly = RequestWithoutBody(Form.HTTPMethod);
	
EndProcedure

&AtClient
Procedure ЗаполнитьДвоичныеДанныеТелаИзФайлаЗавершение(Результат, Адрес, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт
	Если Не Результат Тогда
		Возврат;
	КонецЕсли;

	RequestBodyBinaryDataAddress = Адрес;

	RequestBodyBinaryDataString = Строка(ПолучитьИзВременногоХранилища(Адрес));
EndProcedure

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

&AtServer
Procedure ЗаполнитьТаблицуЗаголовковПоСтроке(СтрокаЗаголовков)
	ЗаголовкиПоСтроке = UT_CommonClientServer.HTTPRequestHeadersFromString(СтрокаЗаголовков);

	RequestHeadersTable.Очистить();

	Для Каждого КлючЗначение Из ЗаголовкиПоСтроке Цикл
		НС = RequestHeadersTable.Добавить();
		НС.Key = КлючЗначение.Key;
		НС.Value = КлючЗначение.Value;
	КонецЦикла;

EndProcedure

&AtClient
Procedure УстановитьСтраницуРедактированияЗаголовковЗапроса()
	Если TableHeadersEditor Тогда
		НоваяСтраница = Элементы.RequestHeadersTableEditPageGroup;
	Иначе
		НоваяСтраница = Элементы.RequestHeadersTextEditPageGroup;
	КонецЕсли;

	Элементы.RequestHeadersEditPagesGroup.ТекущаяСтраница = НоваяСтраница;

	//Теперь нужно заполнить заголовки на новой странице по старой странице
	Если TableHeadersEditor Тогда
		ЗаполнитьТаблицуЗаголовковПоСтроке(HeadersString);
	Иначе
		HeadersString = UT_CommonClientServer.GetHTTPHeadersString(RequestHeadersTable);
	КонецЕсли;
EndProcedure

&AtClient
Procedure ЗаполнитьДанныеТекущегоЗапросаПоИстории(ВыбраннаяСтрока)

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

	Элементы.RequestPagesGroup.ТекущаяСтраница = Элементы.RequestGroup;
EndProcedure

&AtServer
Procedure FillByDebugData(DebugDataAddress)
	
	DebugData = GetFromTempStorage(DebugDataAddress);

	RequestURL = "";
	If Not ValueIsFilled(DebugData.Scheme) Then
		RequestURL = "http";
	Else
		RequestURL = DebugData.Scheme;
	EndIf;

	RequestURL = RequestURL + "://" + DebugData.Host;

	If ValueIsFilled(DebugData.Port) Then
		RequestURL = RequestURL + ":" + Format(DebugData.Port, "ЧГ=0;");
	EndIf;

	If Not StrStartsWith(DebugData.Request, "/") Then
		RequestURL = RequestURL + "/";
	EndIf;

	RequestURL = RequestURL + DebugData.Request;
	TableHeadersEditor = True;

	Items.RequestHeadersEditPagesGroup.CurrentPage = Элементы.RequestHeadersTableEditPageGroup;

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