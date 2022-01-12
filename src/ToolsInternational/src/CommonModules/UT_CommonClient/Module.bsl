#Region ConfigurationMethodsEvents

Procedure OnStart() Export
	SessionStartParameters=UT_CommonServerCall.SessionStartParameters();

	If SessionStartParameters.ExtensionRightsAdded Then
		Exit(False, True);
	EndIf;

	UT_ApplicationParameters.Insert("SessionNumber", SessionStartParameters.SessionNumber);
	UT_ApplicationParameters.Insert("ConfigurationScriptVariant", SessionStartParameters.ConfigurationScriptVariant);

	UT_ApplicationParameters.Insert("IsLinuxClient", UT_CommonClientServer.IsLinux());
	UT_ApplicationParameters.Insert("IsWindowsClient", UT_CommonClientServer.IsWindows());
	UT_ApplicationParameters.Insert("IsWebClient", IsWebClient());
	UT_ApplicationParameters.Insert("IsPortableDistribution", UT_CommonClientServer.IsPortableDistribution());
	UT_ApplicationParameters.Insert("HTMLFieldBasedOnWebkit",UT_CommonClientServer.HTMLFieldBasedOnWebkit());
	UT_ApplicationParameters.Insert("AppVersion",
	UT_CommonClientServer.CurrentAppVersion());
	//UT_ApplicationParameters.Insert("ConfigurationMetadataDescriptionAdress", UT_CommonServerCall.ConfigurationMetadataDescriptionAdress());
	
	SessionParametersInStorage = New Structure;
	SessionParametersInStorage.Insert("IsLinuxClient", UT_ApplicationParameters["IsLinuxClient"]);
	SessionParametersInStorage.Insert("IsWebClient", UT_ApplicationParameters["IsWebClient"]);
	SessionParametersInStorage.Insert("IsWindowsClient", UT_ApplicationParameters["IsWindowsClient"]);
	SessionParametersInStorage.Insert("IsPortableDistribution", UT_ApplicationParameters["IsPortableDistribution"]);
	SessionParametersInStorage.Insert("HTMLFieldBasedOnWebkit", UT_ApplicationParameters["HTMLFieldBasedOnWebkit"]);
	SessionParametersInStorage.Insert("AppVersion", UT_ApplicationParameters["AppVersion"]);
	//SessionParametersInStorage.Insert("ConfigurationMetadataDescriptionAdress", UT_ApplicationParameters["ConfigurationMetadataDescriptionAdress"]);

	UT_CommonServerCall.CommonSettingsStorageSave(
	UT_CommonClientServer.ObjectKeyInSettingsStorage(),
	UT_CommonClientServer.SessionParametersSettingsKey(), SessionParametersInStorage);

EndProcedure

Procedure OnExit() Export
	UT_AdditionalLibrariesDirectory=UT_AdditionalLibrariesDirectory();
	Try
		BeginDeletingFiles(,UT_AdditionalLibrariesDirectory);
	Except

	EndTry;
EndProcedure

#EndRegion

// Displays the text, which users can copy.
//
// Parameters:
//   Handler - NotifyDescription - description of the procedure to be called after showing the message.
//       Returns a value like ShowQuestionToUser().
//   Text - String - an information text.
//   Title - String - Optional. window title. "Details" by default.
//
Procedure ShowDetailedInfo(Handler, Text, Title = Undefined) Export
	DialogSettings = New Structure;
	DialogSettings.Insert("SuggestDontAskAgain", False);
	DialogSettings.Insert("Picture", Undefined);
	DialogSettings.Insert("ShowPicture", False);
	DialogSettings.Insert("CanCopy", True);
	DialogSettings.Insert("DefaultButton", 0);
	DialogSettings.Insert("HighlightDefaultButton", False);
	DialogSettings.Insert("Title", Title);
	
	If Not ValueIsFilled(DialogSettings.Title) Then
		DialogSettings.Title = NStr("ru = 'Подробнее'; en = 'Details'");
	EndIf;
	
	Buttons = New ValueList;
	Buttons.Add(0, NStr("ru = 'Закрыть'; en = 'Close'"));
	
	ShowQuestionToUser(Handler, Text, Buttons, DialogSettings);
EndProcedure

// Show the question form.
//
// Parameters:
//   CompletionNotifyDescription - NotifyDescription - description of the procedures to be called 
//                                                        after the question window is closed with the following parameters:
//                                                          QuestionResult - Structure - a structure with the following properties:
//                                                            Value - a user selection result: a 
//                                                                       system enumeration value or 
//                                                                       a value associated with the clicked button. 
//                                                                       If the dialog is closed by a timeout - value
//                                                                       Timeout.
//                                                            DontAskAgain - Boolean - a user 
//                                                                                                  
//                                                                                                  selection result in the check box with the same name.
//                                                          AdditionalParameters - Structure
//   QuestionText - String - a question text.
//   Buttons                        - QuestionDialogMode, ValueList - a value list may be specified in which:
//                                       Value - contains the value connected to the button and 
//                                                  returned when the button is selected. You can 
//                                                  pass a value of the DialogReturnCode enumeration 
//                                                  or any value that can be XDTO serialized.
//                                                  
//                                       Presentation - sets the button text.
//
//   AdditionalParameters - Structure - see StandardSubsystemsClient.QuestionToUserParameters 
//
// Returns:
//   The user selection result is passed to the method specified in the NotifyDescriptionOnCompletion parameter.
//
Procedure ShowQuestionToUser(CompletionNotifyDescription, QuestionText, Buttons, AdditionalParameters = Undefined) Export

	If AdditionalParameters <> Undefined Then
		Parameters = AdditionalParameters;
	Else
		Parameters = New Structure;
	EndIf;

	UT_CommonClientServer.SupplementStructure(Parameters, QuestionToUserParameters(), False);

	ButtonsParameter = Buttons;

		If TypeOf(Parameters.DefaultButton) = Type("DialogReturnCode") Then
		Parameters.DefaultButton = DialogReturnCodeToString(Parameters.DefaultButton);
	EndIf;
	
	If TypeOf(Parameters.TimeoutButton) = Type("DialogReturnCode") Then
		Parameters.TimeoutButton = DialogReturnCodeToString(Parameters.TimeoutButton);
	EndIf;
	
	Parameters.Insert("Buttons",         ButtonsParameter);
	Parameters.Insert("MessageText", QuestionText);
	
	NotifyDescriptionForApplicationRun=CompletionNotifyDescription;
	If NotifyDescriptionForApplicationRun = Undefined Then
		NotifyDescriptionForApplicationRun=ApplicationRunEmptyNotifyDescription();
	EndIf;

	ShowQueryBox(NotifyDescriptionForApplicationRun, QuestionText, ButtonsParameter, , Parameters.DefaultButton, "",
		Parameters.TimeoutButton);

КонецПроцедуры

// Returns a new structure with additional parameters for the ShowQuestionToUser procedure.
//
// Returns:
//  Structure - structure with the following properties:
//    * DefaultButton - Arbitrary - defines the default button by the button type or by the value 
//                                                     associated with it.
//    * Timeout - Number - a period of time in seconds in which the question window waits for user 
//                                                     to respond.
//    * TimeoutButton - Arbitrary - a button (by button type or value associated with it) on which 
//                                                     the timeout remaining seconds are displayed.
//                                                     
//    * Title - String - a question title.
//    * SuggestDontAskAgain - Boolean - if True, a check box with the same name is available in the window.
//    * DontAskAgain - Boolean - a value set by the user in the matching check box.
//                                                     
//    * LockWholeInterface - Boolean - if True, the question window opens locking all other opened 
//                                                     windows including the main one.
//    * Picture - Picture - a picture displayed in the question window.
//
Function QuestionToUserParameters() Export
	
	Parameters = New Structure;
	Parameters.Insert("DefaultButton", Undefined);
	Parameters.Insert("Timeout", 0);
	Parameters.Insert("TimeoutButton", Undefined);
	Parameters.Insert("Title", ClientApplication.GetCaption());
	Parameters.Insert("SuggestDontAskAgain", True);
	Parameters.Insert("DoNotAskAgain", False);
	Parameters.Insert("LockWholeInterface", False);
	Parameters.Insert("Picture", PictureLib.Question32);
	Return Parameters;
	
EndFunction

// Returns String Representation of type DialogReturnCode 
Function DialogReturnCodeToString(Value)

	Result = "DialogReturnCode." + String(Value);

	If Value = DialogReturnCode.Yes Then
		Result = "DialogReturnCode.Yes";
	ElsIf Value = DialogReturnCode.No Then
		Result = "DialogReturnCode.No";
	ElsIf Value = DialogReturnCode.OK Then
		Result = "DialogReturnCode.OK";
	ElsIf Value = DialogReturnCode.Cancel Then
		Result = "DialogReturnCode.Cancel";
	ElsIf Value = DialogReturnCode.Retry Then
		Result = "DialogReturnCode.Retry";
	ElsIf Value = DialogReturnCode.Abort Then
		Result = "DialogReturnCode.Abort";
	ElsIf Value = DialogReturnCode.Ignore Then
		Result = "DialogReturnCode.Ignore";
	EndIf;

	Return Result;

EndFunction

#Region ExecuteAlgorithms

Function ExecuteAlgorithm(AlgorithmRef, IncomingParameters = Undefined, ExecutionError = False,
	ErrorMessage = "") Export
	Return UT_AlgorithmsClientServer.ExecuteAlgorithm(AlgorithmRef, IncomingParameters, ExecutionError,
		ErrorMessage)
EndFunction

#EndRegion

#Region Debug

Procedure OpenDebuggingConsole(DebuggingObjectType, DebuggingData, ConsoleFormUnique = Undefined) Экспорт
	If Upper(DebuggingObjectType) = "QUERY" Then
		ConsoleFormName = "DataProcessor.UT_QueryConsole.Form";
	ElsIf Upper(DebuggingObjectType) = "DATACOMPOSITIONSCHEMA" Then
		ConsoleFormName = "Report.UT_ReportsConsole.Form";
	ElsIf Upper(DebuggingObjectType) = "DATABASEOBJECT" Then
		ConsoleFormName = "DataProcessor.UT_ObjectsAttributesEditor.ObjectForm";
	ElsIf Upper(DebuggingObjectType) = "HTTPREQUEST" Then
		ConsoleFormName = "DataProcessor.UT_HTTPRequestConsole.Form";
	Else
		Return;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("DebuggingData", DebuggingData);

	If ConsoleFormUnique = Undefined Then
		Uniqueness = New UUID;
	Else
		Uniqueness = ConsoleFormUnique;
	EndIf;

	OpenForm(ConsoleFormName, FormParameters, , Uniqueness);

EndProcedure

Procedure  RunDebugConsoleByDebugDataSettingsKey(DebugSettingsKey, FormID = Undefined) Export
	If Not ValueIsFilled(DebugSettingsKey) Then
		Return;
	EndIf;

	DebugData = UT_CommonServerCall.DebuggingObjectDataStructureFromSystemSettingsStorage(
		DebugSettingsKey, FormID);

	If DebugData = Undefined Then
		Return;
	EndIf;

	OpenDebuggingConsole(DebugData.DebuggingObjectType, DebugData.DebuggingObjectAddress);
EndProcedure

#EndRegion

Function IsWebClient() Export
	#Если WebClient Тогда
		Return True;
	#Иначе 
		Return False;
	#КонецЕсли
EndFunction

Function ApplicationRunEmptyNotifyDescription() Export
	Return New NotifyDescription("BeginRunningApplicationEndEmpty", ThisObject);
EndFunction

Procedure BeginRunningApplicationEndEmpty(ReturnCode, AdditionalParameters) Export
	If ReturnCode = Undefined Then
		Return;
	EndIf;
EndProcedure

Procedure OpenTextEditingForm(Text, OnCloseNotifyDescription, Title = "",
	WindowOpeningMode = Undefined) Export
	FormParameters = New Структура;
	FormParameters.Insert("Text", Text);
	FormParameters.Insert("Title", Title);

	If WindowOpeningMode = Undefined Then
		OpenForm("CommonForm.UT_TextEditingForm", FormParameters, , , , , OnCloseNotifyDescription);
	Else
		OpenForm("CommonForm.UT_TextEditingForm", FormParameters, , , , , OnCloseNotifyDescription,
			WindowOpeningMode);
	EndIf;
EndProcedure

Procedure  OpenValueListChoiceItemsForm(List, OnCloseNotifyDescription, Title = "",
	ItemsType = Undefined, MarkVisibility = True, ResresentationVisibility = True, SelectionMode = True,
	ReturnOnlySelectedValues = True, WindowOpeningMode = Undefined, AvailableValues = Undefined) Export
	FormParameters = New Structure;
	FormParameters.Insert("List", List);
	FormParameters.Insert("Title", Title);
	FormParameters.Insert("ReturnOnlySelectedValues", ReturnOnlySelectedValues);
	FormParameters.Insert("MarkVisibility", MarkVisibility);
	FormParameters.Insert("ResresentationVisibility", ResresentationVisibility);
	FormParameters.Insert("SelectionMode", SelectionMode);
	If ItemsType <> Undefined Then
		FormParameters.Insert("ItemsType", ItemsType);
	EndIf;
	If AvailableValues <> Undefined Then
		FormParameters.Insert("AvailableValues", AvailableValues);
	Endif;

	If WindowOpeningMode = Undefined Then
		OpenForm("CommonForm.UT_ValueListChoiceItemsForm", FormParameters, , , , ,
			OnCloseNotifyDescription);
	Else
		OpenForm("CommonForm.UT_ValueListChoiceItemsForm", FormParameters, , , , ,
			OnCloseNotifyDescription, WindowOpeningMode);
	EndIf;
EndProcedure

Procedure EditObject(ObjectRef) Export
	AvalibleForEditingObjectsArray=UT_CommonClientCached.DataBaseObjectEditorAvalibleObjectsTypes();
	If AvalibleForEditingObjectsArray.Find(TypeOf(ObjectRef)) = Undefined Then
		Return;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("mObjectRef", ObjectRef);

	OpenForm("DataProcessor.UT_ObjectsAttributesEditor.Form", FormParameters);
EndProcedure

Procedure EditJSON(JSONString, ViewMode, OnEndNotifyDescription = Undefined) Export
	Parameters=New Structure;
	Parameters.Insert("JSONString", JSONString);
	Parameters.Insert("ViewMode", ViewMode);

	If OnEndNotifyDescription = Undefined then
		OpenForm("DataProcessor.UT_JSONEditor.Form", Parameters);
	else
		OpenForm("DataProcessor.UT_JSONEditor.Form", Parameters, , , , , OnEndNotifyDescription);
	Endif;
EndProcedure

Процедура ОткрытьДинамическийСписок(ИмяОбъектаМетаданных, OnEndNotifyDescription = Неопределено) Экспорт
	СтрукПараметры = Новый Структура("ИмяОбъектаМетаданных", ИмяОбъектаМетаданных);

	Если OnEndNotifyDescription = Неопределено Тогда
		OpenForm("Обработка.УИ_ДинамическийСписок.Форма", СтрукПараметры, , ИмяОбъектаМетаданных);
	Иначе
		OpenForm("Обработка.УИ_ДинамическийСписок.Форма", СтрукПараметры, , ИмяОбъектаМетаданных, , ,
			OnEndNotifyDescription);
	КонецЕсли;

КонецПроцедуры

Procedure НайтиСсылкиНаОбъект(ObjectRef) Export
	FormParameters=New Structure;
	FormParameters.Insert("SearchObject", ObjectRef);

	OpenForm("Обработка.UT_ObjectReferencesSearch.Form", FormParameters);

EndProcedure

Процедура ЗадатьВопросРазработчику() Экспорт
	НачатьЗапускПриложения(ApplicationRunEmptyNotifyDescription(),
		"https://github.com/cpr1c/tools_ui_1c/issues");

КонецПроцедуры

Процедура ОткрытьСтраницуРазработки() Экспорт
	НачатьЗапускПриложения(ApplicationRunEmptyNotifyDescription(), "https://github.com/cpr1c/tools_ui_1c");

КонецПроцедуры

Процедура ОткрытьСтраницуОсобенностейОтладкиПортативныхИнструметов() Экспорт
	НачатьЗапускПриложения(ApplicationRunEmptyNotifyDescription(),
		"https://github.com/cpr1c/tools_ui_1c/wiki/Особенности-использования-отладки-в-портативном-варианте");

КонецПроцедуры

Процедура ЗапуститьПроверкуОбновленияИнструментов() Экспорт
	ПараметрыФормы = Новый Структура;
	ОткрытьФорму("Обработка.UT_Support.Форма.ОбновлениеИнструментов", ПараметрыФормы);
КонецПроцедуры

Процедура ОткрытьНовуюФормуИнструмента(ФормаНачальная)
	ОткрытьФорму(ФормаНачальная.ИмяФормы, , , Новый УникальныйИдентификатор, , , , РежимОткрытияОкнаФормы.Независимый);
КонецПроцедуры

#Область ПодключаемыеМетодыКомандИнструментов

Процедура Attachable_ExecuteToolsCommonCommand(Форма, Команда) Экспорт
	Если Команда.Имя = "УИ_ОткрытьНовуюФормуИнструмента" Тогда
		ОткрытьНовуюФормуИнструмента(Форма);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область КомандыБСП

Процедура ДобавитьОбъектыКСравнению(МассивОбъектов, Контекст) Экспорт
	UT_CommonClientServer.AddObjectsArrayToCompare(МассивОбъектов);
КонецПроцедуры

Процедура ВыгрузитьОбъектыВXML(МассивОбъектов, Контекст) Экспорт
	АдресФайлаВоВременномХранилище="";
	UT_CommonServerCall.UploadObjectsToXMLonServer(МассивОбъектов, АдресФайлаВоВременномХранилище,
		Контекст.Форма.УникальныйИдентификатор);

	Если ЭтоАдресВременногоХранилища(АдресФайлаВоВременномХранилище) Тогда
		ИмяФайла="Файл выгрузки.xml";
		ПолучитьФайл(АдресФайлаВоВременномХранилище, ИмяФайла);
	КонецЕсли;

КонецПроцедуры

Процедура ОбработчикКомандыРедактироватьОбъект(СсылкаНаОбъект, Контекст) Экспорт
	EditObject(СсылкаНаОбъект);
КонецПроцедуры

Процедура ОбработчикКомандыНайтиСсылкиНаОбъект(СсылкаНаОбъект, Контекст) Экспорт
	НайтиСсылкиНаОбъект(СсылкаНаОбъект);
КонецПроцедуры

Процедура ОткрытьНастройкиОтладкиДополнительнойОбработки(СсылкаНаОбъект) Экспорт
	ПараметрыФормы=Новый Структура;
	ПараметрыФормы.Вставить("ДополнительнаяОбработка", СсылкаНаОбъект);

	ОткрытьФорму("ОбщаяФорма.УИ_НастройкиОтладкиДополнительныхОбработок", ПараметрыФормы);
КонецПроцедуры

#КонецОбласти
#Область РедактированиеТиповИПеременные

// Процедура - Редактировать тип
//
// Параметры:
//  ТипДанных						 - 	 - Текущий тип значения
//  РежимЗапуска					 - Число - режим запуска редактора типа
// 0- Выбор хранимых типов
// 1- типы для запроса
// 2- типы для поля СКД
// 3- типы для параметра СКД
//  СтандартнаяОбработка			 - Булево - Стандартная обработка события начало выбора
//  ВладелецФормы					 - 	 - 
//  ОписаниеОповещенияОЗавершении	 - 	 - 
//
Процедура РедактироватьТип(ТипДанных, РежимЗапуска, СтандартнаяОбработка, ВладелецФормы, ОписаниеОповещенияОЗавершении) Экспорт
	СтандартнаяОбработка=Ложь;

	ПараметрыФормы=Новый Структура;
	ПараметрыФормы.Вставить("ТипДанных", ТипДанных);
	ПараметрыФормы.Вставить("РежимЗапуска", РежимЗапуска);
	ОткрытьФорму("ОбщаяФорма.UT_ValueTypeEditor", ПараметрыФормы, ВладелецФормы, , , ,
		ОписаниеОповещенияОЗавершении, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

Процедура РедактироватьТаблицуЗначений(ТаблицаЗначенийСтрокой, ВладелецФормы, ОписаниеОповещенияОЗавершении) Экспорт
	ПараметрыФормы=Новый Структура;
	ПараметрыФормы.Вставить("ТаблицаЗначенийСтрокой", ТаблицаЗначенийСтрокой);

	ОткрытьФорму("ОбщаяФорма.UT_ValueTableEditor", ПараметрыФормы, ВладелецФормы, , , ,
		ОписаниеОповещенияОЗавершении);
КонецПроцедуры

#КонецОбласти

#Область СобытияЭлементовФормы

Процедура ПолеФормыНачалоВыбораЗначения(Значение, СтандартнаяОбработка, ОписаниеОповещенияОЗавершении,
	ТипЗначения = Неопределено, ДоступныеЗначения = Неопределено) Экспорт
	ТипТекущегоЗначения=ТипЗнч(Значение);

	Если ТипТекущегоЗначения = Тип("СписокЗначений") Тогда
		СтандартнаяОбработка=Ложь;

	КонецЕсли;
КонецПроцедуры

Процедура ПолеФормыИмяФайлаНачалоВыбора(СтруктураОписанияФайла, Элемент, ДанныеВыбора, СтандартнаяОбработка,
	РежимДиалога, ОписаниеОповещенияОЗавершении) Экспорт
	СтандартнаяОбработка=Ложь;

	ДополнительныеПараметрыОповещения=Новый Структура;
	ДополнительныеПараметрыОповещения.Вставить("Элемент", Элемент);
	ДополнительныеПараметрыОповещения.Вставить("СтруктураОписанияФайла", СтруктураОписанияФайла);
	ДополнительныеПараметрыОповещения.Вставить("РежимДиалога", РежимДиалога);
	ДополнительныеПараметрыОповещения.Вставить("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении);

	ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкой(
		Новый ОписаниеОповещения("ПолеФормыИмяФайлаНачалоВыбораЗавершениеПодключенияРасширенияРаботыСФайлами",
		ЭтотОбъект, ДополнительныеПараметрыОповещения));
КонецПроцедуры

Процедура ПолеФормыИмяФайлаНачалоВыбораЗавершениеПодключенияРасширенияРаботыСФайлами(Подключено,
	ДополнительныеПараметры) Экспорт
	ВыборФайла = ДиалогВыбораФайлаПоСтруктуреОписанияВыбираемогоФайла(ДополнительныеПараметры.РежимДиалога,
		ДополнительныеПараметры.СтруктураОписанияФайла);
	ВыборФайла.Показать(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении);
КонецПроцедуры

#КонецОбласти

#Область ВспомогательныеБиблиотекиИнструментов

Процедура СохранитьВспомогательныеБиблиотекиНаКлиентеПриНачалеРаботыСистемы() Экспорт
	КаталогБиблиотек=UT_AdditionalLibrariesDirectory();
	
	//1. очищаем наш каталог. Под каждую базу он свой
	Сообщить(КаталогБиблиотек);
КонецПроцедуры

Function UT_AdditionalLibrariesDirectory() Export
	FileVariablesStructure=SessionFileVariablesStructure();
	If Not FileVariablesStructure.Property("TempFilesDirectory") Then
		Return "";
	EndIf;
	
	Return FileVariablesStructure.TempFilesDirectory + GetPathSeparator() + "tools_ui_1c" + GetPathSeparator()
EndFunction
#КонецОбласти

#Область ХранилищеЗначения

Процедура EditValueStorage(Форма, АдресВременногоХранилищаЗначенияИлиЗначение,
	ОписаниеОповещения = Неопределено) Экспорт

	Если ОписаниеОповещения = Неопределено Тогда
		ПараметрыОписанияОповещения = Новый Структура;
		ПараметрыОписанияОповещения.Вставить("Форма", Форма);
		ПараметрыОписанияОповещения.Вставить("АдресВременногоХранилищаЗначенияИлиЗначение",
			АдресВременногоХранилищаЗначенияИлиЗначение);
		ОписаниеОповещенияОЗакрытии = Новый ОписаниеОповещения("РедактироватьПараметрыЗаписиЗавершение", ЭтотОбъект,
			ПараметрыОписанияОповещения);
	Иначе
		ОписаниеОповещенияОЗакрытии = ОписаниеОповещения;
	КонецЕсли;

	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ДанныеХЗ", АдресВременногоХранилищаЗначенияИлиЗначение);

	ОткрытьФорму("ОбщаяФорма.УИ_ФормаХранилищаЗначения", ПараметрыФормы, Форма, Форма.УникальныйИдентификатор, , ,
		ОписаниеОповещенияОЗакрытии, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);

КонецПроцедуры

Процедура РедактироватьХранилищеЗначенияЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	//	Форма=ДополнительныеПараметры.Форма;
КонецПроцедуры

#КонецОбласти

#Область ПараметрыЗаписи

Процедура РедактироватьПараметрыЗаписи(Форма) Экспорт
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПараметрыЗаписи", UT_CommonClientServer.FormWriteSettings(Форма));
	
	Если Форма.ИмяФормы = "Обработка.УИ_РедакторРеквизитовОбъекта.Форма.ФормаОбъекта" Тогда
		МассивТипа = Новый Массив;
		МассивТипа.Добавить(ТипЗнч(Форма.мОбъектСсылка));
		
		ПараметрыФормы.Вставить("ТипОбъекта", Новый ОписаниеТипов(МассивТипа));
	КонецЕсли;

	ПараметрыОписанияОповещения = Новый Структура;
	ПараметрыОписанияОповещения.Вставить("Форма", Форма);
	ОписаниеОповещенияОЗакрытии = Новый ОписаниеОповещения("РедактироватьПараметрыЗаписиЗавершение", ЭтотОбъект,
		ПараметрыОписанияОповещения);

	ОткрытьФорму("ОбщаяФорма.UT_WriteSettings", ПараметрыФормы, Форма, , , , ОписаниеОповещенияОЗакрытии,
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

Процедура РедактироватьПараметрыЗаписиЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Форма = ДополнительныеПараметры.Форма;

	UT_CommonClientServer.SetOnFormWriteParameters(Форма, Результат);
КонецПроцедуры

#КонецОбласти

#Область СохранениеЧтениеДанныхКонсолей

Функция ПустоеОписаниеФорматаВыбираемогоФайла() Экспорт
	Описание=Новый Структура;
	Описание.Вставить("Расширение", "");
	ОПисание.Вставить("Имя", "");
	ОПисание.Вставить("Фильтр", "");

	Возврат Описание;
КонецФункции

Процедура ДобавитьФорматВОписаниеФайлаСохранения(СтруктураОписанияВыбираемогоФайла, ИмяФормата, РасширениеФайла, Фильтр = "") Экспорт
	Формат=ПустоеОписаниеФорматаВыбираемогоФайла();
	Формат.Имя=ИмяФормата;
	Формат.Расширение=РасширениеФайла;
	Формат.Фильтр = Фильтр;
	СтруктураОписанияВыбираемогоФайла.Форматы.Добавить(Формат);
КонецПроцедуры

Функция ПустаяСтруктураОписанияВыбираемогоФайла() Экспорт
	СтруктураОписания=Новый Структура;
	СтруктураОписания.Вставить("ИмяФайла", "");
	СтруктураОписания.Вставить("СериализуемыеФорматыФайлов", Новый Массив);
	СтруктураОписания.Вставить("Форматы", Новый Массив);

	Возврат СтруктураОписания;
КонецФункции

Функция ДиалогВыбораФайлаПоСтруктуреОписанияВыбираемогоФайла(Режим, СтруктураОписанияВыбираемогоФайла) Экспорт
			// Нужно запросить имя файла.
	ВыборФайла = Новый ДиалогВыбораФайла(Режим);
	ВыборФайла.МножественныйВыбор = Ложь;
	
	//В линуксе есть проблемы с выбором файла, если в существующем есть тире
	Если Не (UT_CommonClientServer.IsLinix() И Найти(СтруктураОписанияВыбираемогоФайла.ИмяФайла, "-") > 0) Тогда
		ВыборФайла.ПолноеИмяФайла = СтруктураОписанияВыбираемогоФайла.ИмяФайла;
	КонецЕсли;

	Фильтр="";
	Для Каждого ТекФорматФайла Из СтруктураОписанияВыбираемогоФайла.Форматы Цикл
		РасширениеФормата=ТекФорматФайла.Расширение;
		Если ЗначениеЗаполнено(РасширениеФормата) Тогда
			ФильтрФормата="*." + РасширениеФормата;
		Иначе
			ФильтрФормата="*.*";
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ТекФорматФайла.Фильтр) Тогда
			ФильтрФормата = ТекФорматФайла.Фильтр;
		КонецЕсли;

		Фильтр=Фильтр + ?(ЗначениеЗаполнено(Фильтр), "|", "") + СтрШаблон("%1|%2", ТекФорматФайла.Имя, ФильтрФормата);
	КонецЦикла;

	ВыборФайла.Фильтр = Фильтр;

	Если СтруктураОписанияВыбираемогоФайла.СериализуемыеФорматыФайлов.Количество() > 0 Тогда
		ВыборФайла.Расширение=СтруктураОписанияВыбираемогоФайла.СериализуемыеФорматыФайлов[0];
	ИначеЕсли СтруктураОписанияВыбираемогоФайла.Форматы.Количество() > 0 Тогда
		ВыборФайла.Расширение=СтруктураОписанияВыбираемогоФайла.Форматы[0].Расширение;
	КонецЕсли;

	Возврат ВыборФайла;
КонецФункции

#Область СохранениеДанныхКонсолей

// Описание
// 
// Параметры:
// 	СохранитьКак - Булево - Включен ли режим сохранения файла КАК. Т.е. всегда запрашивать куда сохранять, даже если уже есть имяфайла
// 	СтруктураОписанияСохраняемогоФайла -Структура - Содержит информацию, необходимую для идентификации файла, куда сохранять
// 		Содержит поля:
// 			ИмяФайла- Строка - Имя сохраняемого файла. Если не указано покажется диалог для сохранения
// 			Расширение- Строка- Расширение сохраняемого файла
// 			ИмяСохраняемогоФормата- Строка- описание формата сохраняемого файла
// 	АдресДанныхСохранения - Строка- Адрес во временном хранилище с сохраняемым значением. Сохраняемые данные будут дополнительно сериализованы с использованием сериализатора JSON
// 	ОписаниеОповещенияОЗавершении- ОписаниеОповещения- Описание оповещения после сохранения данных в файл
Процедура СохранитьДанныеКонсолиВФайл(ИмяКонсоли, СохранитьКак, СтруктураОписанияСохраняемогоФайла,
	АдресДанныхСохранения, ОписаниеОповещенияОЗавершении) Экспорт

	ДополнительныеПараметрыОповещения=Новый Структура;
	ДополнительныеПараметрыОповещения.Вставить("СохранитьКак", СохранитьКак);
	ДополнительныеПараметрыОповещения.Вставить("СтруктураОписанияСохраняемогоФайла", СтруктураОписанияСохраняемогоФайла);
	ДополнительныеПараметрыОповещения.Вставить("АдресДанныхСохранения", АдресДанныхСохранения);
	ДополнительныеПараметрыОповещения.Вставить("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении);
	ДополнительныеПараметрыОповещения.Вставить("ИмяКонсоли", ИмяКонсоли);

	ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкой(
		Новый ОписаниеОповещения("СохранитьДанныеКонсолиВФайлПослеПодключенияРасширенияРаботыСФайлами", ЭтотОбъект,
		ДополнительныеПараметрыОповещения));

КонецПроцедуры

Процедура СохранитьДанныеКонсолиВФайлПослеПодключенияРасширенияРаботыСФайлами(Подключено, ДополнительныеПараметры) Экспорт
	СохранитьКак = ДополнительныеПараметры.СохранитьКак;
	СтруктураОписанияСохраняемогоФайла=ДополнительныеПараметры.СтруктураОписанияСохраняемогоФайла;

	Если СохранитьКак Или СтруктураОписанияСохраняемогоФайла.ИмяФайла = "" Тогда
		ВыборФайла = ДиалогВыбораФайлаПоСтруктуреОписанияВыбираемогоФайла(РежимДиалогаВыбораФайла.Сохранение,
			СтруктураОписанияСохраняемогоФайла);
		ВыборФайла.Показать(Новый ОписаниеОповещения("СохранитьДанныеКонсолиВФайлПослеВыбораИмениФайла", ЭтотОбъект,
			ДополнительныеПараметры));
	Иначе
		СохранитьДанныеКонсолиВФайлНачатьПолучениеФайла(СтруктураОписанияСохраняемогоФайла.ИмяФайла,
			ДополнительныеПараметры);
	КонецЕсли;

КонецПроцедуры

Процедура СохранитьДанныеКонсолиВФайлПослеВыбораИмениФайла(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если ВыбранныеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	СохранитьДанныеКонсолиВФайлНачатьПолучениеФайла(ВыбранныеФайлы[0], ДополнительныеПараметры);
КонецПроцедуры

Процедура СохранитьДанныеКонсолиВФайлНачатьПолучениеФайла(ИмяФайла, ДополнительныеПараметры) Экспорт

	ПодготовленныеДанныеДляЗаписи=UT_CommonServerCall.ConsolePreparedDataForFileWriting(
		ДополнительныеПараметры.ИмяКонсоли, ИмяФайла, ДополнительныеПараметры.АдресДанныхСохранения,
		ДополнительныеПараметры.СтруктураОписанияСохраняемогоФайла);
	ПолучаемыеФайлы = Новый Массив;
	ПолучаемыеФайлы.Добавить(Новый ОписаниеПередаваемогоФайла(ИмяФайла, ПодготовленныеДанныеДляЗаписи));
	НачатьПолучениеФайлов(Новый ОписаниеОповещения("СохранитьДанныеКонсолиВФайлПослеПолученияФайлов", ЭтотОбъект,
		ДополнительныеПараметры), ПолучаемыеФайлы, ИмяФайла, Ложь);
КонецПроцедуры

Процедура СохранитьДанныеКонсолиВФайлПослеПолученияФайлов(ПолученныеФайлы, ДополнительныеПараметры) Экспорт

	ОбработкаОповещения = ДополнительныеПараметры.ОписаниеОповещенияОЗавершении;

	Если ПолученныеФайлы = Неопределено Тогда

		Если ОбработкаОповещения <> Неопределено Тогда
			ВыполнитьОбработкуОповещения(ОбработкаОповещения, Неопределено);
		КонецЕсли;
	Иначе
		Если UT_CommonClientServer.PlatformVersionNotLess("8.3.13") Тогда
			ИмяФайла = ПолученныеФайлы[0].ПолноеИмя;
		Иначе
			ИмяФайла = ПолученныеФайлы[0].Имя;
		КонецЕсли;
		Если ОбработкаОповещения <> Неопределено Тогда
			ВыполнитьОбработкуОповещения(ОбработкаОповещения, ИмяФайла);
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ЧтениеДанныхКонсолей

Процедура ПрочитатьДанныеКонсолиИзФайла(ИмяКонсоли, СтруктураОписанияЧитаемогоФайла, ОписаниеОповещенияОЗавершении, БезВыбораФайла = Ложь) Экспорт

	ДополнительныеПараметрыОповещения=Новый Структура;
	ДополнительныеПараметрыОповещения.Вставить("СтруктураОписанияЧитаемогоФайла", СтруктураОписанияЧитаемогоФайла);
	ДополнительныеПараметрыОповещения.Вставить("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении);
	ДополнительныеПараметрыОповещения.Вставить("ИмяКонсоли", ИмяКонсоли);
	ДополнительныеПараметрыОповещения.Вставить("БезВыбораФайла", БезВыбораФайла);

	ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкой(
		Новый ОписаниеОповещения("ПрочитатьДанныеКонсолиИзФайлаПослеПодключенияРасширения", ЭтотОбъект,
		ДополнительныеПараметрыОповещения));

КонецПроцедуры

Процедура ПрочитатьДанныеКонсолиИзФайлаПослеПодключенияРасширения(Подключено, ДополнительныеПараметры) Экспорт

	ЗагружаемоеИмяФайла = ДополнительныеПараметры.СтруктураОписанияЧитаемогоФайла.ИмяФайла;
	БезВыбораФайла = ДополнительныеПараметры.БезВыбораФайла;

	Если Подключено Тогда

		Если БезВыбораФайла Тогда
			Если ЗначениеЗаполнено(ЗагружаемоеИмяФайла) Тогда
				ПомещаемыеФайлы=Новый Массив;
				ПомещаемыеФайлы.Добавить(Новый ОписаниеПередаваемогоФайла(ЗагружаемоеИмяФайла));

				НачатьПомещениеФайлов(
					Новый ОписаниеОповещения("ПрочитатьДанныеКонсолиИзФайлаПослеПомещенияФайлов", ЭтотОбъект,
					ДополнительныеПараметры), ПомещаемыеФайлы, , Ложь);
			КонецЕсли;
		Иначе
			ВыборФайла = ДиалогВыбораФайлаПоСтруктуреОписанияВыбираемогоФайла(РежимДиалогаВыбораФайла.Открытие,
				ДополнительныеПараметры.СтруктураОписанияЧитаемогоФайла);

			ВыборФайла.Показать(Новый ОписаниеОповещения("ПрочитатьДанныеКонсолиИзФайлаПослеВыбораФайла", ЭтотОбъект,
				ДополнительныеПараметры));
		КонецЕсли;
	Иначе
		ПомещаемыеФайлы=Новый Массив;
		ПомещаемыеФайлы.Добавить(Новый ОписаниеПередаваемогоФайла(ЗагружаемоеИмяФайла));

		НачатьПомещениеФайлов(
			Новый ОписаниеОповещения("ПрочитатьДанныеКонсолиИзФайлаПослеПомещенияФайлов", ЭтотОбъект,
			ДополнительныеПараметры), ПомещаемыеФайлы, , ЗагружаемоеИмяФайла = "");

	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьДанныеКонсолиИзФайлаПослеВыбораФайла(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт

	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если ВыбранныеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	ПомещаемыеФайлы=Новый Массив;
	ПомещаемыеФайлы.Добавить(Новый ОписаниеПередаваемогоФайла(ВыбранныеФайлы[0]));

	НачатьПомещениеФайлов(
				Новый ОписаниеОповещения("ПрочитатьДанныеКонсолиИзФайлаПослеПомещенияФайлов", ЭтотОбъект,
		ДополнительныеПараметры), ПомещаемыеФайлы, , Ложь);
КонецПроцедуры

Процедура ПрочитатьДанныеКонсолиИзФайлаПослеПомещенияФайлов(ПомещенныеФайлы, ДополнительныеПараметры) Экспорт

	Если ПомещенныеФайлы = Неопределено Тогда
		Возврат;

	КонецЕсли;

	ПрочитатьДанныеКонсолиИзФайлаОтработкаЗагрузкиФайла(ПомещенныеФайлы, ДополнительныеПараметры);
КонецПроцедуры

Процедура ПрочитатьДанныеКонсолиИзФайлаОтработкаЗагрузкиФайла(ПомещенныеФайлы, ДополнительныеПараметры)

	СтруктураРезультата=Неопределено;

	Для Каждого ПомещенныйФайл Из ПомещенныеФайлы Цикл

		Если ПомещенныйФайл.Хранение <> "" Тогда

			СтруктураРезультата=Новый Структура;
			СтруктураРезультата.Вставить("Адрес", ПомещенныйФайл.Хранение);
			Если UT_CommonClientServer.PlatformVersionNotLess("8.3.13") Тогда
				СтруктураРезультата.Вставить("ИмяФайла", ПомещенныйФайл.ПолноеИмя);
			Иначе
				СтруктураРезультата.Вставить("ИмяФайла", ПомещенныйФайл.Имя);
			КонецЕсли;

			Прервать;

		КонецЕсли;

	КонецЦикла;

	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении, СтруктураРезультата);

КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область ПодключениеИУстановкаРасширенияРаботыСФайлами

Процедура ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкой(ОписаниеОповещенияОЗавершении, ПослеУстановки = Ложь) Экспорт
	ДополнительныеПараметрыОповещения=Новый Структура;
	ДополнительныеПараметрыОповещения.Вставить("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении);
	ДополнительныеПараметрыОповещения.Вставить("ПослеУстановки", ПослеУстановки);

	НачатьПодключениеРасширенияРаботыСФайлами(
		Новый ОписаниеОповещения("ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкойЗавершениеПодключенияРасширения",
		ЭтотОбъект, ДополнительныеПараметрыОповещения));

КонецПроцедуры

Процедура ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкойЗавершениеПодключенияРасширения(Подключено,
	ДополнительныеПараметры) Экспорт

	Если Подключено Тогда
		SessionFileVariablesStructure=UT_ApplicationParameters[SessionFileVariablesParameterName()];
		Если SessionFileVariablesStructure = Неопределено Тогда
			ПрочитатьОсновныеФайловыеПеременныеСеансаВПараметрыПриложения(
				Новый ОписаниеОповещения("ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкойЗавершениеЧтенияФайловыхПеременныхСеанса",
				ЭтотОбъект, ДополнительныеПараметры));
		Иначе
			ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении, Истина);
		КонецЕсли;
	ИначеЕсли Не ДополнительныеПараметры.ПослеУстановки Тогда
		НачатьУстановкуРасширенияРаботыСФайлами(
			Новый ОписаниеОповещения("ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкойЗавершениеУстановкиРасширения",
			ЭтотОбъект, ДополнительныеПараметры));
	Иначе
		ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении, Ложь);
	КонецЕсли;

КонецПроцедуры

Процедура ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкойЗавершениеЧтенияФайловыхПеременныхСеанса(Результат,
	ДополнительныеПараметры) Экспорт

	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении, Истина);

КонецПроцедуры

Процедура ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкойЗавершениеУстановкиРасширения(ДополнительныеПараметры) Экспорт
	ПодключитьРасширениеРаботыСФайламиСВозможнойУстановкой(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении,
		Истина);
КонецПроцедуры

#КонецОбласти

#Область ПараметрыПриложения

Функция НомерСеанса() Экспорт
	Возврат UT_ApplicationParameters["НомерСеанса"];
КонецФункции

#КонецОбласти

#Область ЧтениеФайловыхПараметровСеансаВПараметрыПриложения

Function SessionFileVariablesParameterName () Export	
	Return "FILE_VARIABLES";
EndFunction

Function SessionFileVariablesStructure() Export
	CurrentApplicationParameters=UT_ApplicationParameters;

	FileVariablesStructure=CurrentApplicationParameters[SessionFileVariablesParameterName()];
	If FileVariablesStructure = Undefined Then
		CurrentApplicationParameters[SessionFileVariablesParameterName()]=New Structure;
		FileVariablesStructure=CurrentApplicationParameters[SessionFileVariablesParameterName()];
	EndIf;

	Return FileVariablesStructure;
EndFunction

Процедура ПрочитатьОсновныеФайловыеПеременныеСеансаВПараметрыПриложения(ОписаниеОповещенияОЗавершении) Экспорт
	ДополнительныеПараметрыОповещения=Новый Структура;
	ДополнительныеПараметрыОповещения.Вставить("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении);

	//1. каталог временных файлов
	НачатьПолучениеКаталогаВременныхФайлов(
		Новый ОписаниеОповещения("ПрочитатьОсновныеФайловыеПеременныеСеансаВПараметрыПриложенияПолучениеКаталогаВременныхФайловЗавершение",
		ЭтотОбъект, ДополнительныеПараметрыОповещения));
КонецПроцедуры

Процедура ПрочитатьОсновныеФайловыеПеременныеСеансаВПараметрыПриложенияПолучениеКаталогаВременныхФайловЗавершение(ИмяКаталога,
	ДополнительныеПараметры) Экспорт
	СтруктураФайловыхПеременных=SessionFileVariablesStructure();
	СтруктураФайловыхПеременных.Вставить("TempFilesDirectory", ИмяКаталога);

	НачатьПолучениеРабочегоКаталогаДанныхПользователя(
		Новый ОписаниеОповещения("ПрочитатьОсновныеФайловыеПеременныеСеансаВПараметрыПриложенияПолучениеРабочегоКаталогаДанныхПользователяЗавершение",
		ЭтотОбъект, ДополнительныеПараметры));
КонецПроцедуры

Процедура ПрочитатьОсновныеФайловыеПеременныеСеансаВПараметрыПриложенияПолучениеРабочегоКаталогаДанныхПользователяЗавершение(ИмяКаталога,
	ДополнительныеПараметры) Экспорт
	СтруктураФайловыхПеременных=SessionFileVariablesStructure();
	СтруктураФайловыхПеременных.Вставить("РабочийКаталогДанныхПользователя", ИмяКаталога);

	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОписаниеОповещенияОЗавершении, Истина);
КонецПроцедуры

#КонецОбласти
#Область ЗапускПриложения1С


// Описание
// 
// Параметры:
// 	ТипКлиента - Число - Код режима запуска
// 		1 - Конфигуратор
// 		2 - Толстый клиент обычное приложение
// 		3 - Толстый клиент управляемое приложение
// 		4 - Тонкий клиент
// 	Пользователь - Строка - Имя пользователя БД, под которым нужно выполнить запуск
// 	РежимЗапускаПодПользователем - Булево - Определяет, будет ли изменен пароль пользователя перед запуском. После запуска пароль вернется назад
// Возвращаемое значение:
// 	
Функция ЗапуститьСеанс1С(ТипКлиента, Пользователь, РежимЗапускаПодПользователем = Ложь,
	ПаузаПередВосстановлениемПароля = 20) Экспорт
#Если ВебКлиент Тогда

#Иначе
		Папка1С = КаталогПрограммы();

		СтрокаЗапуска = Папка1С;

		РасширениеФайлаЗапуска = "";
		Если UT_CommonClientServer.IsWindows() Тогда
			РасширениеФайлаЗапуска=".EXE";
		КонецЕсли;

		Если ТипКлиента = 1 Тогда
			СтрокаЗапуска = СтрокаЗапуска + "1cv8" + РасширениеФайлаЗапуска + " DESIGNER";
		ИначеЕсли ТипКлиента = 2 Тогда
			СтрокаЗапуска = СтрокаЗапуска + "1cv8" + РасширениеФайлаЗапуска + " ENTERPRISE /RunModeOrdinaryApplication";
		ИначеЕсли ТипКлиента = 3 Тогда
			СтрокаЗапуска = СтрокаЗапуска + "1cv8" + РасширениеФайлаЗапуска + " ENTERPRISE /RunModeManagedApplication";
		Иначе
			СтрокаЗапуска = СтрокаЗапуска + "1cv8c" + РасширениеФайлаЗапуска + " ENTERPRISE";
		КонецЕсли;

		СтрокаСоединения=СтрокаСоединенияИнформационнойБазы();
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
			СтрокаЗапуска = СтрокаЗапуска + " /F" + СоответствиеПоказателейСтрокиСоединения.File;
		ИначеЕсли СоответствиеПоказателейСтрокиСоединения.Свойство("srvr") Тогда
			ПутьКБазе = UT_StringFunctionsClientServer.ПутьБезКавычек(СоответствиеПоказателейСтрокиСоединения.srvr) + "\"
				+ UT_StringFunctionsClientServer.ПутьБезКавычек(СоответствиеПоказателейСтрокиСоединения.ref);
			ПутьКБазе = UT_StringFunctionsClientServer.ОбернутьВКавычки(ПутьКБазе);
			СтрокаЗапуска = СтрокаЗапуска + " /S " + ПутьКБазе;
		ИначеЕсли СоответствиеПоказателейСтрокиСоединения.Свойство("ws") Тогда
			СтрокаЗапуска = СтрокаЗапуска + " /WS " + СоответствиеПоказателейСтрокиСоединения.ws;
		Иначе
			Сообщить(СтрокаСоединения);
		КонецЕсли;

		СтрокаЗапуска = СтрокаЗапуска + " /N""" + Пользователь + """";

		ДанныеСохраненногоПароляПользователяИБ = Неопределено;
		Если РежимЗапускаПодПользователем Тогда
			ВременныйПароль = "qwerty123456";
			ДанныеСохраненногоПароляПользователяИБ = UT_CommonServerCall.StoredIBUserPasswordData(
				Пользователь);
			UT_CommonServerCall.SetIBUserPassword(Пользователь, ВременныйПароль);

			СтрокаЗапуска = СтрокаЗапуска + " /P" + ВременныйПароль;
		КонецЕсли;

		ДополнительныеПараметрыОповещения = Новый Структура;
		ДополнительныеПараметрыОповещения.Вставить("РежимЗапускаПодПользователем", РежимЗапускаПодПользователем);
		ДополнительныеПараметрыОповещения.Вставить("ДанныеСохраненногоПароляПользователяИБ",
			ДанныеСохраненногоПароляПользователяИБ);
		ДополнительныеПараметрыОповещения.Вставить("Пользователь", Пользователь);
		ДополнительныеПараметрыОповещения.Вставить("ПаузаПередВосстановлениемПароля", ПаузаПередВосстановлениемПароля);

		Попытка
			BeginRunningApplication(Новый ОписаниеОповещения("ЗапуститьСеанс1СЗавершениеЗапуска", ЭтотОбъект,
				ДополнительныеПараметрыОповещения), СтрокаЗапуска);
		Исключение
			Сообщить(КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецПопытки;
#КонецЕсли
КонецФункции

Процедура ЗапуститьСеанс1СЗавершениеЗапуска(КодВозврата, ДополнительныеПараметры) Экспорт
	Если Не ДополнительныеПараметры.РежимЗапускаПодПользователем Тогда
		Возврат;
	КонецЕсли;

	ВремяЗапуска = ТекущаяДата();
	Пока (ТекущаяДата() - ВремяЗапуска) < ДополнительныеПараметры.ПаузаПередВосстановлениемПароля Цикл
		ОбработкаПрерыванияПользователя();
	КонецЦикла;

	UT_CommonServerCall.RestoreUserDataAfterUserSessionStart(
		ДополнительныеПараметры.Пользователь, ДополнительныеПараметры.ДанныеСохраненногоПароляПользователяИБ);
КонецПроцедуры

#КонецОбласти
