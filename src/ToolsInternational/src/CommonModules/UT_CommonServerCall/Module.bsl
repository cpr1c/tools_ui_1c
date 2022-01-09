Function SessionStartParameters() export

	SessionStartParameters= New Structure;

	if Not UT_CommonClientServer.IsPortableDistribution() Then
		If AccessRight("Administration", Metadata) AND Not IsInRole("UT_UniversalTools")
			and InfoBaseUsers.GetUsers().Count() > 0 then
			CurrentUser = InfoBaseUsers.CurrentUser();
			CurrentUser.Roles.Add(Metadata.Roles.UT_UniversalTools);
			CurrentUser.Write();

			SessionStartParameters.Insert("ExtensionRightsAdded", True);
		else
			SessionStartParameters.Insert("ExtensionRightsAdded", False);
		endif;
	Иначе
		SessionStartParameters.Insert("ExtensionRightsAdded", False);	
	КонецЕсли;

	SessionStartParameters.Insert("SessionNumber", InfoBaseSessionNumber());
	SessionStartParameters.Insert("ConfigurationScriptVariant", UT_CodeEditorServer.ConfigurationScriptVariant());

	Return SessionStartParameters;
EndFunction

// Sets the bold font for form group titles so they are correctly displayed in the 8.2 interface.2.
// In the Taxi interface, group titles with standard highlight and without one are displayed in large font.
// In the 8.2 interface such titles are displayed as regular labels and are not associated with titles.
// This function is designed for visually highlighting (in bold) of group titles in the mode of the 8.2 interface.
//
// Parameters:
//  Form - ManagedForm - a form where group title fonts are changed.
//  GroupsNames - String - a list of the form group names separated with commas. If the group names 
//                        are not specified, the appearance will be applied to all groups on the form.
//
// Example:
//  Procedure OnCreateAtServer(Cancel, StandardProcessing)
//    StandardSubsystemsServer.SetGroupsTitlesRepresentation(ThisObject);
//
Procedure SetGroupTitleRepresentation(Form, GroupNames = "") Export
	
	If ClientApplication.CurrentInterfaceVariant() = ClientApplicationInterfaceVariant.Version8_2 Then
		BoldFont = New Font(,, True);
		If NOT ValueIsFilled(GroupNames) Then 
			For Each Item In Form.Items Do 
				If Type(Item) = Type("FormGroup")
					AND Item.Type = FormGroupType.UsualGroup
					AND Item.ShowTitle = True 
					AND (Item.Representation = UsualGroupRepresentation.NormalSeparation
					Or Item.Representation = UsualGroupRepresentation.None) Then 
						Item.TitleFont = BoldFont;
				EndIf;
			EndDo;
		Else
			TitleArray = UT_StringFunctionsClientServer.РазложитьСтрокуВМассивПодстрок(GroupNames,,, True);
			For Each TitleName In TitleArray Do
				Item = Form.Items[TitleName];
				If Item.Representation = UsualGroupRepresentation.NormalSeparation OR Item.Representation = UsualGroupRepresentation.None Then 
					Item.TitleFont = BoldFont;
				EndIf;
			EndDo;
		EndIf;
	EndIf;

EndProcedure

Function DefaultLanguageCode() Export
	Return UT_CommonServerCall.DefaultLanguageCode();
EndFunction

// See. StandardSubsystemsCached.RefsByPredefinedItemsNames
Function RefsByPredefinedItemsNames(FullMetadataObjectName) Export

	Return UT_CommonCached.RefsByPredefinedItemsNames(FullMetadataObjectName);

EndFunction

Function ObjectAttributesValues(Ref, Val Attributes, SelectAllowedItems = False) Export

	Return UT_Common.ObjectAttributesValues(Ref, Attributes, SelectAllowedItems);

EndFunction

// Returns attribute values retrieved from the infobase using the object reference.
//
// To read attribute values regardless of current user rights, enable privileged mode.
//
// Parameters:
//  Ref - AnyRef - the object whose attribute values will be read.
//            - String - full name of the predefined item whose attribute values will be read.
//  AttributeName - String - the name of the attribute.
//  SelectAllowedItems - Boolean - if True, user rights are considered when executing the object query.
//                                If a record-level restriction is set, return Undefined.
//                                if the user has no rights to access the table, an exception is raised.
//                                if False, an exception is raised if the user has no rights to 
//                                access the table or any attribute.
//
// Returns:
//  Arbitrary - depends on the type of the read atrribute value.
//               - if a blank reference is passed to Ref, return Undefined.
//               - if a reference to a nonexisting object (invalid reference) is passed to Ref, 
//                 return Undefined.
//
Function ObjectAttributeValue(Ref, AttributeName, SelectAllowedItems = False) Export

	Return UT_Common.ObjectAttributeValue(Ref, AttributeName, SelectAllowedItems);

EndFunction

Function StoredIBUserPasswordData(Username) Export
	Return UT_Users.StoredIBUserPasswordData(Username);
EndFunction

Procedure SetIBUserPassword(Username, Password) Export
	UT_Users.SetIBUserPassword(Username, Password);
EndProcedure

Procedure RestoreUserDataAfterUserSessionStart(UserName,
	StoredIBUserPasswordData) Export
	UT_Users.RestoreUserDataAfterUserSessionStart(UserName,
		StoredIBUserPasswordData);
EndProcedure

Procedure AddObjectsArrayToCompare(Objects) Export
	UT_Common.AddObjectsArrayToCompare(Objects);
EndProcedure

Procedure UploadObjectsToXMLonServer(ObjectsArray, FileAdressInTempStorage, FormID=Undefined) Export
	UploadingDataProcessor = Обработки.УИ_ВыгрузкаЗагрузкаДанныхXMLСФильтрами.Создать();
	UploadingDataProcessor.Инициализация();
	UploadingDataProcessor.ВыгружатьСДокументомЕгоДвижения=Истина;
	UploadingDataProcessor.ИспользоватьФорматFastInfoSet=Ложь;
	
	For Each CurrentObject In ObjectsArray Do
		NR=UploadingDataProcessor.ДополнительныеОбъектыДляВыгрузки.Add();
		NR.Объект=CurrentObject;
		NR.ИмяОбъектаДляЗапроса=UT_Common.TableNameByRef(CurrentObject);
	EndDo;
		
	TempFileName = GetTempFileName(".xml");
	
	UploadingDataProcessor.ВыполнитьВыгрузку(TempFileName, , New ValueTable);
		
	File = New File(TempFileName);

	If File.Exist() Then

		BinaryData = New BinaryData(TempFileName);
		FileAdressInTempStorage = PutToTempStorage(BinaryData, FormID);
		DeleteFiles(TempFileName);

	EndIf;
	
EndProcedure

// Convert (serializes) any value to XML-string.
// Converted to may be only those objects for which the syntax helper indicate that they are serialized.
// См. также ValueFromStringXML.
//
// Parameters:
//  Value  - Arbitrary  - value that you want to serialize into an XML string..
//
//  Return value:
//  String - XML-string.
//
Function ValueToXMLString(Value) Export

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, Value, XMLTypeAssignment.Explicit);

	Return XMLWriter.Close();
EndFunction

// Converts (deserializes) an XML string into a value.
// See also ValueToXMLString.
//
// Parameters:
//  XMLString - String - an XML string with a serialized object.
//
// Returns:
//  Arbitrary - the value extracted from an XML string.
//
Function ValueFromXMLString(XMLString, Type = Undefined) Export

	XMLReader = New XMLReader;
	XMLReader.SetString(XMLString);

	If Type = Undefined Then
		Return XDTOSerializer.ReadXML(XMLReader);
	Else
		Return XDTOSerializer.ReadXML(XMLReader, Type);
	EndIf;
EndFunction

Function АдресОписанияМетаданныхКонфигурации() Export
	Возврат UT_Common.АдресОписанияМетаданныхКонфигурации();
EndFunction

#Region JSON

Function mReadJSON(Value) Export
	Return UT_CommonClientServer.mReadJSON(Value);
EndFunction // ReadJSON()

Function mWriteJSON(DataStructure) Export
	Return UT_CommonClientServer.mWriteJSON(DataStructure);
EndFunction // WriteJSON(
#EndRegion

#Region SettingsStorage

////////////////////////////////////////////////////////////////////////////////
// Сохранение, чтение и удаление настроек из хранилищ.

// Saving, reading, and deleting settings from storages.

// Saves a setting to the common settings storage as the Save method of 
// StandardSettingsStorageManager or SettingsStorageManager.<Storage name> object. Setting keys 
// exceeding 128 characters are supported by hashing the key part that exceeds 96 characters.
// 
// If the SaveUserData right is not granted, data save fails and no error is raised.
//
// Parameters:
//   ObjectKey - String - see the Syntax Assistant.
//   SettingsKey - String - see the Syntax Assistant.
//   Settings - Arbitrary - see the Syntax Assistant.
//   SettingsDescription - SettingsDescription - see the Syntax Assistant.
//   UserName - String - see the Syntax Assistant.
//   UpdateCachedValues - Boolean - the flag that indicates whether to execute the method.

Procedure CommonSettingsStorageSave(ObjectKey, SettingsKey, Settings,
			SettingsDetails = Undefined,
			Username = Undefined,
			UpdateCachedValues = False) Export

	UT_Common.CommonSettingsStorageSave(ObjectKey, SettingsKey, Settings,SettingsDetails,Username,UpdateCachedValues = False);

EndProcedure

// Saves settings to the common settings storage as the Save method of 
// StandardSettingsStorageManager or SettingsStorageManager.<Storage name> object. Setting keys 
// exceeding 128 characters are supported by hashing the key part that exceeds 96 characters.
// 
// If the SaveUserData right is not granted, data save fails and no error is raised.
// 
// Parameters:
//   MultipleSettings - Array of the following values:
//     * Value - Structure - with the following properties:
//         * Object - String - see the ObjectKey parameter in the Syntax Assistant.
//         * Setting - String - see the SettingsKey parameter in the Syntax Assistant.
//         * Value - Arbitrary - see the Settings parameter in the Syntax Assistant.
//
//   UpdateCachedValues - Boolean - the flag that indicates whether to execute the method.
//

Procedure CommonSettingsStorageSaveArray(MultipleSettings, UpdateCachedValues = False) Export
	
	UT_Common.CommonSettingsStorageSaveArray(MultipleSettings, UpdateCachedValues);

EndProcedure

// Loads a setting from the general settings storage as the Load method, 
// StandardSettingsStorageManager objects, or SettingsStorageManager.<Storage name>. The setting key 
// supports more than 128 characters by hashing the part that exceeds 96 characters.
// 
// If no settings are found, returns the default value.
// If the SaveUserData right is not granted, the default value is returned and no error is raised.
//
// References to database objects that do not exist are cleared from the return value:
// - The returned reference is replaced by the default value.
// - The references are deleted from the data of Array type.
// - Key is not changed for the data of Structure or Map types, and value is set to Undefined.
// - Recursive analysis of values in the data of Array, Structure, Map types is performed.
//
// Parameters:
//   ObjectKey - String - see the Syntax Assistant.
//   SettingsKey - String - see the Syntax Assistant.
//   DefaultValue - Arbitrary - a value that is returned if no settings are found.
//                                             If not specified, returns Undefined.
//   SettingsDescription - SettingsDescription - see the Syntax Assistant.
//   UserName - String - see the Syntax Assistant.
//
// Returns:
//   Arbitrary - see the Syntax Assistant.
//
Function CommonSettingsStorageLoad(ObjectKey, SettingsKey, DefaultValue = Undefined, 
			SettingsDetails = Undefined, Username = Undefined) Export
	Return UT_Common.CommonSettingsStorageLoad(ObjectKey, SettingsKey, DefaultValue, 
			SettingsDetails, Username)

EndFunction

// Removes a setting from the general settings storage as the Remove method, 
// StandardSettingsStorageManager objects, or SettingsStorageManager.<Storage name>. The setting key 
// supports more than 128 characters by hashing the part that exceeds 96 characters.
// 
// If the SaveUserData right is not granted, no data is deleted and no error is raised.
//
// Parameters:
//   ObjectKey - String, Undefined - see the Syntax Assistant.
//   SettingsKey - String, Undefined - see the Syntax Assistant.
//   UserName - String, Undefined - see the Syntax Assistant.
//
Procedure CommonSettingsStorageDelete(ObjectKey, SettingsKey, Username) Export

	UT_Common.CommonSettingsStorageDelete(ObjectKey, SettingsKey, Username);

EndProcedure

/// Saves a setting to the system settings storage as the Save method of 
// StandardSettingsStorageManager object. Setting keys exceeding 128 characters are supported by 
// hashing the key part that exceeds 96 characters.
// If the SaveUserData right is not granted, data save fails and no error is raised.
//
// Parameters:
//   ObjectKey - String - see the Syntax Assistant.
//   SettingsKey - String - see the Syntax Assistant.
//   Settings - Arbitrary - see the Syntax Assistant.
//   SettingsDescription - SettingsDescription - see the Syntax Assistant.
//   UserName - String - see the Syntax Assistant.
//   UpdateCachedValues - Boolean - the flag that indicates whether to execute the method.
//
Procedure SystemSettingsStorageSave(ObjectKey, SettingsKey, Settings,
			SettingsDetails = Undefined,
			Username = Undefined,
			UpdateCachedValues = False) Export

	UT_Common.SystemSettingsStorageSave(ObjectKey, SettingsKey, Settings,
			SettingsDetails,Username,UpdateCachedValues);

EndProcedure


// Loads a setting from the system settings storage as the Load method or the 
// StandardSettingsStorageManager object. The setting key supports more than 128 characters by 
// hashing the part that exceeds 96 characters.
// If no settings are found, returns the default value.
// If the SaveUserData right is not granted, the default value is returned and no error is raised.
//
// The return value clears references to a non-existent object in the database, namely:
// - The returned reference is replaced by the default value.
// - The references are deleted from the data of Array type.
// - Key is not changed for the data of Structure or Map types, and value is set to Undefined.
// - Recursive analysis of values in the data of Array, Structure, Map types is performed.
//
// Parameters:
//   ObjectKey - String - see the Syntax Assistant.
//   SettingsKey - String - see the Syntax Assistant.
//   DefaultValue - Arbitrary - a value that is returned if no settings are found.
//                                             If not specified, returns Undefined.
//   SettingsDescription - SettingsDescription - see the Syntax Assistant.
//   UserName - String - see the Syntax Assistant.
//
// Returns:
//   Arbitrary - see the Syntax Assistant.
//
Function SystemSettingsStorageLoad(ObjectKey, SettingsKey, DefaultValue = Undefined, 
			SettingsDetails = Undefined, Username = Undefined) Export

	Return UT_Common.SystemSettingsStorageLoad(ObjectKey, SettingsKey, DefaultValue, 
			SettingsDetails , Username );

EndFunction

// Removes a setting from the system settings storage as the Remove method or the 
// StandardSettingsStorageManager object. The setting key supports more than 128 characters by 
// hashing the part that exceeds 96 characters.
// If the SaveUserData right is not granted, no data is deleted and no error is raised.
//
// Parameters:
//   ObjectKey - String, Undefined - see the Syntax Assistant.
//   SettingsKey - String, Undefined - see the Syntax Assistant.
//   UserName - String, Undefined - see the Syntax Assistant.
//
Procedure SystemSettingsStorageDelete(ObjectKey, SettingsKey, Username) Export

	UT_Common.SystemSettingsStorageDelete(ObjectKey, SettingsKey, Username);

EndProcedure

// Saves a setting to the form data settings storage as the Save method of 
// StandardSettingsStorageManager or SettingsStorageManager.<Storage name> object. Setting keys 
// exceeding 128 characters are supported by hashing the key part that exceeds 96 characters.
// 
// If the SaveUserData right is not granted, data save fails and no error is raised.
//
// Parameters:
//   ObjectKey - String - see the Syntax Assistant.
//   SettingsKey - String - see the Syntax Assistant.
//   Settings - Arbitrary - see the Syntax Assistant.
//   SettingsDescription - SettingsDescription - see the Syntax Assistant.
//   UserName - String - see the Syntax Assistant.
//   UpdateCachedValues - Boolean - the flag that indicates whether to execute the method.
//
Procedure FormDataSettingsStorageSave(ObjectKey, SettingsKey, Settings,
			SettingsDetails = Undefined,Username = Undefined, 
			UpdateCachedValues = False) Export

	UT_Common.FormDataSettingsStorageSave(ObjectKey, SettingsKey, Settings, SettingsDetails,
		Username, UpdateCachedValues);

EndProcedure

// Retrieves the setting from the form data settings storage using the Load method for 
// StandardSettingsStorageManager or SettingsStorageManager.<Storage name> objects. Setting keys 
// exceeding 128 characters are supported by hashing the key part that exceeds 96 characters.
// 
// If no settings are found, returns the default value.
// If the SaveUserData right is not granted, the default value is returned and no error is raised.
//
// References to database objects that do not exist are cleared from the return value:
// - The returned reference is replaced by the default value.
// - The references are deleted from the data of Array type.
// - Key is not changed for the data of Structure or Map types, and value is set to Undefined.
// - Recursive analysis of values in the data of Array, Structure, Map types is performed.
//
// Parameters:
//   ObjectKey - String - see the Syntax Assistant.
//   SettingsKey - String - see the Syntax Assistant.
//   DefaultValue - Arbitrary - a value that is returned if no settings are found.
//                                             If not specified, returns Undefined.
//   SettingsDescription - SettingsDescription - see the Syntax Assistant.
//   UserName - String - see the Syntax Assistant.
//
// Returns:
//   Arbitrary - see the Syntax Assistant.
//
Function FormDataSettingsStorageLoad(ObjectKey, SettingsKey, DefaultValue = Undefined, 
			SettingsDetails = Undefined, Username = Undefined) Export

	Return UT_Common.FormDataSettingsStorageLoad(ObjectKey, SettingsKey, DefaultValue,
		SettingsDetails, Username);

EndFunction

// Deletes the setting from the form data settings storage using the Delete method for 
// StandardSettingsStorageManager or SettingsStorageManager.<Storage name> objects. Setting keys 
// exceeding 128 characters are supported by hashing the key part that exceeds 96 characters.
// 
// If the SaveUserData right is not granted, no data is deleted and no error is raised.
//
// Parameters:
//   ObjectKey - String, Undefined - see the Syntax Assistant.
//   SettingsKey - String, Undefined - see the Syntax Assistant.
//   UserName - String, Undefined - see the Syntax Assistant.
//
Procedure FormDataSettingsStorageDelete(ObjectKey, SettingsKey, Username) Export
	UT_Common.FormDataSettingsStorageDelete(ObjectKey, SettingsKey, Username);
EndProcedure

#EndRegion

#Region Algorithms

Function GetRefCatalogAlgorithms(Algorithm) Export
	Return UT_Common.GetRefCatalogAlgorithms(Algorithm);
EndFunction

Function ExecuteAlgorithm(AlgorithmRef, IncomingParameters = Undefined, ExecutionError = False,
	ErrorMessage = "") Export
	Return UT_Common.ExecuteAlgorithm(AlgorithmRef, IncomingParameters, ExecutionError,
		ErrorMessage);
EndFunction

#EndRegion

#Region Отладка

Function SaveDebuggingDataToStorage(ТипОбъектаОтладки, ДанныеДляОтладки) Export
	КлючНастроек=ТипОбъектаОтладки + "/" + ИмяПользователя() + "/" + Формат(ТекущаяДата(), "ДФ=yyyyMMddHHmmss;");
	КлючОбъектаДанныхОтладки=UT_CommonClientServer.DebuggingDataObjectDataKeyInSettingsStorage();

	UT_Common.SystemSettingsStorageSave(КлючОбъектаДанныхОтладки, КлючНастроек, ДанныеДляОтладки);

	Возврат "Запись выполнена успешно. Ключ настроек " + КлючНастроек;
EndFunction

Функция СтруктураДанныхОбъектаОтладкиИзСправочникаДанныхОтладки(СсылкаНаДанные) Export
	Результат = Новый Структура;
	Результат.Вставить("ТипОбъектаОтладки", СсылкаНаДанные.ТипОбъектаОтладки);
	Результат.Вставить("АдресОбъектаОтладки", ПоместитьВоВременноеХранилище(
		СсылкаНаДанные.ХранилищеОбъектаОтладки.Получить()));

	Возврат Результат;
КонецФункции

Функция СтруктураДанныхОбъектаОтладкиИзСистемногоХранилищаНастроек(КлючНастроек, ИдентификаторФормы=Неопределено) Export
	КлючОбъектаДанныхОтладки=UT_CommonClientServer.DebuggingDataObjectDataKeyInSettingsStorage();
	НастройкиОтладки=UT_Common.SystemSettingsStorageLoad(КлючОбъектаДанныхОтладки, КлючНастроек);

	Если НастройкиОтладки = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	МассивПодСтрокКлюча=СтрРазделить(КлючНастроек, "/");

	Если ИдентификаторФормы=Неопределено Тогда
		АдресОбъектаОтладки=ПоместитьВоВременноеХранилище(НастройкиОтладки);
	Иначе
		АдресОбъектаОтладки=ПоместитьВоВременноеХранилище(НастройкиОтладки, ИдентификаторФормы);
	КонецЕсли;

	Результат = Новый Структура;
	Результат.Вставить("ТипОбъектаОтладки", МассивПодСтрокКлюча[0]);
	Результат.Вставить("АдресОбъектаОтладки", АдресОбъектаОтладки);

	Возврат Результат;
КонецФункции

Function SerializeDCSForDebug(DCS, DcsSettings, ExternalDataSets) Export
	ObjectStructure = New Structure;

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, DCS, "dataCompositionSchema",
		"http://v8.1c.ru/8.1/data-composition-system/schema");

	ObjectStructure.Insert("DCSText", XMLWriter.Close());

	If DcsSettings = Undefined Then
		Settings=DCS.DefaultSettings;
	Else
		Settings=DcsSettings;
	EndIf;

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, Settings, "Settings",
		"http://v8.1c.ru/8.1/data-composition-system/settings");
	ObjectStructure.Insert("DcsSettingsText", XMLWriter.Close());

	If TypeOf(ExternalDataSets) = Type("Structure") Then
		Sets = New Structure;

		For Each KeyValue In ExternalDataSets Do
			If TypeOf(KeyValue.Value) <> Type("ValueTable") Then
				Continue;
			EndIf;

			Sets.Insert(KeyValue.Key, ValueToStringInternal(KeyValue.Value));
		EndDo;

		If Sets.Count() > 0 Then
			ObjectStructure.Insert("ExternalDataSets", Sets);
		EndIf;
	EndIf;

	Return ObjectStructure;

EndFunction

Function TempTablesManagerTempTablesStructure(TempTablesManager) Export
	TempTablesStructure = New Structure;
	For each TempTable In TempTablesManager.Tables Do
		TempTablesStructure.Insert(TempTable.FullName, TempTable.GetData().Unload());
	EndDo;

	Return TempTablesStructure;
EndFunction

//https://infostart.ru/public/1207287/
Функция ВыполнитьСравнениеДвухТаблицЗначений(ТаблицаБазовая, ТаблицаСравнения, СписокКолонокСравнения) Export
	СписокКолонок = UT_StringFunctionsClientServer.РазложитьСтрокуВМассивПодстрок(СписокКолонокСравнения, ",", Истина);
	//Результирующая таблица
	ВременнаяТаблица = Новый ТаблицаЗначений;
	Для Каждого Колонка Из СписокКолонок Цикл
		ВременнаяТаблица.Колонки.Добавить(Колонка);
		ВременнаяТаблица.Колонки.Добавить(Колонка + "Сравнение");
	КонецЦикла;
	ВременнаяТаблица.Колонки.Добавить("НомерСтр");
	ВременнаяТаблица.Колонки.Добавить("НомерСтр" + "Сравнение");
	//---------
	СравниваемаяТаблица = ТаблицаСравнения.Скопировать();
	СравниваемаяТаблица.Колонки.Добавить("УжеИспользуем", Новый ОписаниеТипов("Булево"));

	Для Каждого Строка Из ТаблицаБазовая Цикл
		НоваяСтрока = ВременнаяТаблица.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
		НоваяСтрока.НомерСтр = Строка.НомерСтроки;
		//формируем структуру для поиска по заданному сопоставлению
		ОтборДляПоискаСтрок = Новый Структура("УжеИспользуем", Ложь);
		Для Каждого Колонка Из СписокКолонок Цикл
			ОтборДляПоискаСтрок.Вставить(Колонка, Строка[Колонка]);
		КонецЦикла;

		НайдемСтроки = СравниваемаяТаблица.НайтиСтроки(ОтборДляПоискаСтрок);
		Если НайдемСтроки.Количество() > 0 Тогда
			СтрокаСопоставления = НайдемСтроки[0];
			НоваяСтрока.НомерСтрСравнение = СтрокаСопоставления.НомерСтроки;
			Для Каждого Колонка Из СписокКолонок Цикл
				Реквизит = Колонка + "Сравнение";
				НоваяСтрока[Реквизит] = СтрокаСопоставления[Колонка];
			КонецЦикла;
			СтрокаСопоставления.УжеИспользуем = Истина;
		КонецЕсли;
	КонецЦикла;
	//Смотрим что осталось +++
	ОтборДляПоискаСтрок = Новый Структура("УжеИспользуем", Ложь);
	НайдемСтроки = СравниваемаяТаблица.НайтиСтроки(ОтборДляПоискаСтрок);
	Для Каждого Строка Из НайдемСтроки Цикл
		НоваяСтрока = ВременнаяТаблица.Добавить();
		НоваяСтрока.НомерСтрСравнение = Строка.НомерСтроки;
		Для Каждого Колонка Из СписокКолонок Цикл
			Реквизит = Колонка + "Сравнение";
			НоваяСтрока[Реквизит] = Строка[Колонка];
		КонецЦикла;
	КонецЦикла;
	//Проверяем что получилось
	ТаблицыИдентичны = Истина;
	Для Каждого Строка Из ВременнаяТаблица Цикл
		Для Каждого Колонка Из СписокКолонок Цикл
			Если (Не ЗначениеЗаполнено(Строка[Колонка])) Или (Не ЗначениеЗаполнено(Строка[Колонка + "Сравнение"])) Тогда
				ТаблицыИдентичны = Ложь;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если Не ТаблицыИдентичны Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Возврат Новый Структура("ИдентичныеТаблицы,ТаблицаРасхождений", ТаблицыИдентичны, ВременнаяТаблица);
КонецФункции

#EndRegion

#Region ConsolesDataSaveRead

Function ConsolePreparedDataForFileWriting(ConsoleName, ИмяФайла, АдресДанныхСохранения,
	СтруктураОписанияСохраняемогоФайла) Export
	Файл=Новый Файл(ИмяФайла);

	If  IsTempStorageURL(АдресДанныхСохранения) Then
		ДанныеСохранения=GetFromTempStorage(АдресДанныхСохранения);
	Else
		ДанныеСохранения=АдресДанныхСохранения;
	EndIf;

	If Upper(ConsoleName) = "HTTPREQUESTCONSOLE" Then
		МенеджерКонсоли=Обработки.UT_HttpRequestConsole;
	Else
		МенеджерКонсоли=Undefined;
	EndIf;

	If МенеджерКонсоли = Undefined Then
		Если TypeOf(ДанныеСохранения) = Type("Строка") Then
			НовыеДанныеСохранения=ДанныеСохранения;
		Else
			НовыеДанныеСохранения=ValueToStringInternal(ДанныеСохранения);
		EndIf;
	Else
		Попытка
			НовыеДанныеСохранения=МенеджерКонсоли.СериализованныеДанныеСохранения(Файл.Расширение, ДанныеСохранения);
		Исключение
			НовыеДанныеСохранения=ValueToStringInternal(ДанныеСохранения);
		КонецПопытки;
	EndIf;

	Stream=New MemoryStream;
	TextWriter=New DataWriter(Stream);
	TextWriter.WriteLine(НовыеДанныеСохранения);

	Return PutToTempStorage(Stream.CloseAndGetBinaryData());
	
//	Return НовыеДанныеСохранения;	

EndFunction

#EndRegion