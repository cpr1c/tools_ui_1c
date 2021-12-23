#Region InternalProceduresAndFunctions

// Возвращает соответствие имен "функциональных" подсистем и значения Истина.
// У "функциональной" подсистемы снят флажок "Включать в командный интерфейс".
//
Функция ИменаПодсистем() Экспорт

	ОтключенныеПодсистемы = Новый Соответствие;

	Имена = Новый Соответствие;
	InsertChildSybsystemsNames(Имена, Метаданные, ОтключенныеПодсистемы);

	Возврат Новый ФиксированноеСоответствие(Имена);

КонецФункции

// Позволяет виртуально отключать подсистемы для целей тестирования.
// Если подсистема отключена, то функция ОбщегоНазначения.ПодсистемаСуществует вернет Ложь.
// В этой процедуре нельзя использовать функцию ОбщегоНазначения.ПодсистемСуществует, т.к. это приводит к рекурсии.
//
// Параметры:
//   ОтключенныеПодсистемы - Соответствие - в ключе указывается имя отключаемой подсистемы, 
//                                          в значении - установить в Истина.
//
Процедура InsertChildSybsystemsNames(Имена, РодительскаяПодсистема, ОтключенныеПодсистемы,
	ИмяРодительскойПодсистемы = "")

	Для Каждого ТекущаяПодсистема Из РодительскаяПодсистема.Подсистемы Цикл

		Если ТекущаяПодсистема.ВключатьВКомандныйИнтерфейс Тогда
			Продолжить;
		КонецЕсли;

		ИмяТекущейПодсистемы = ИмяРодительскойПодсистемы + ТекущаяПодсистема.Имя;
		Если ОтключенныеПодсистемы.Получить(ИмяТекущейПодсистемы) = Истина Тогда
			Продолжить;
		Иначе
			Имена.Вставить(ИмяТекущейПодсистемы, Истина);
		КонецЕсли;

		Если ТекущаяПодсистема.Подсистемы.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;

		InsertChildSybsystemsNames(Имена, ТекущаяПодсистема, ОтключенныеПодсистемы, ИмяТекущейПодсистемы + ".");
	КонецЦикла;

КонецПроцедуры

Function DefaultLanguageCode() Export
	Return Metadata.DefaultLanguage.LanguageCode;
EndFunction

// Возвращает соответствие имен предопределенных значений ссылкам на них.
//
// Параметры:
//  ПолноеИмяОбъектаМетаданных - Строка, например, "Справочник.ВидыНоменклатуры",
//                               Поддерживаются только таблицы
//                               с предопределенными элементами:
//                               - Справочники,
//                               - Планы видов характеристик,
//                               - Планы счетов,
//                               - Планы видов расчета.
// 
// Возвращаемое значение:
//  ФиксированноеСоответствие, Неопределено, где
//      * Ключ     - Строка - имя предопределенного,
//      * Значение - Ссылка, Null - ссылка предопределенного или Null, если объекта нет в ИБ.
//
//  Если ошибка в имени метаданных или неподходящий тип метаданного, то возвращается Неопределено.
//  Если предопределенных у метаданного нет, то возвращается пустое фиксированное соответствие.
//  Если предопределенный определен в метаданных, но не создан в ИБ, то для него в соответствии возвращается Null.
//
Function RefsByPredefinedItemsNames(FullMetadataObjectName) Export

	PredefinedValues = New Map;

	ObjectMetaData = Metadata.FindByFullName(FullMetadataObjectName);
	
	// If Metadata is not exist
	If ObjectMetaData = Undefined Then
		Return Undefined;
	EndIf;
	
	// Если не подходящий тип метаданных.
	If not Metadata.Catalogs.Contains(ObjectMetaData) And Not Metadata.ChartsOfCharacteristicTypes.Contains(
		ObjectMetaData) and not Metadata.ChartsOfAccounts.Contains(ObjectMetaData)
		and Not Metadata.ChartsOfCalculationTypes.Contains(ObjectMetaData) Then

		Return Undefined;
	EndIf;

	PredefinedNames = ObjectMetaData.GetPredefinedNames();
	
	// Если предопределенных у метаданного нет.
	If PredefinedNames.Count() = 0 Then
		Return New FixedMap(PredefinedValues);
	EndIf;
	
	// Заполнение по умолчанию признаком отсутствия в ИБ (присутствующие переопределятся).
	For Each PredefinedName In PredefinedNames Do
		PredefinedValues.Insert(PredefinedName, Null);
	EndDo;

	Query = New Query;
	Query.Text =
	"SELECT
	|	CurrentTable.Ref AS Ref,
	|	CurrentTable.PredefinedDataName AS PredefinedDataName
	|FROM
	|	&CurrentTable AS CurrentTable
	|WHERE
	|	CurrentTable.Predefined";

	Query.Text = StrReplace(Query.Text, "&CurrentTable", FullMetadataObjectName);

	SetSafeModeDisabled(True);
	SetPrivilegedMode(True);

	Selection = Query.Execute().Select();

	SetPrivilegedMode(False);
	SetSafeModeDisabled(False);
	
	// Заполнение присутствующих в ИБ.
	While Selection.Next() do
		PredefinedValues.Insert(Selection.PredefinedDataName, Selection.Ссылка);
	EndDo;

	Return New FixedMap (PredefinedValues);

EndFunction

Function AllRefsTypeDescription() Export

	TypesArray = BusinessProcesses.RoutePointsAllRefsType().Types();
	AddTypesByMetaDataObjectTypes(TypesArray, "Catalogs", "Catalog");
	AddTypesByMetaDataObjectTypes(TypesArray, "Documents", "Document");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfCharacteristicTypes", "ChartOfCharacteristicTypes");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfCalculationTypes", "ChartOfCalculationTypes");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfAccounts", "ChartOfAccounts");
	AddTypesByMetaDataObjectTypes(TypesArray, "BusinessProcesses", "BusinessProcess");
	AddTypesByMetaDataObjectTypes(TypesArray, "Tasks", "Task");
	AddTypesByMetaDataObjectTypes(TypesArray, "ExchangePlans", "ExchangePlan");
	AddTypesByMetaDataObjectTypes(TypesArray, "Enumerations", "Enumeration");
	Return New TypeDescription(TypesArray);

EndFunction

Function CommonModule(Name) Export
	Return UT_Common.CommonModule(Name);
EndFunction

Function DataBaseObjectEditorAvalibleObjectsTypes() Export
	//Avalible to editing 
	//Catalogs,Documents,ChartsOfCharacteristicTypes,ChartsOfAccounts,ChartsOfCalculationTypes, BusinessProcesses, Tasks, ExchangePlans

	TypesArray=New Array;
	AddTypesByMetaDataObjectTypes(TypesArray, "Catalogs", "Catalog");
	AddTypesByMetaDataObjectTypes(TypesArray, "Documents", "Document");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfCharacteristicTypes", "ChartOfCharacteristicTypes");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfCalculationTypes", "ChartOfCalculationTypes");
	AddTypesByMetaDataObjectTypes(TypesArray, "ChartsOfAccounts", "ChartOfAccounts");
	AddTypesByMetaDataObjectTypes(TypesArray, "BusinessProcesses", "BusinessProcess");
	AddTypesByMetaDataObjectTypes(TypesArray, "Tasks", "Task");
	AddTypesByMetaDataObjectTypes(TypesArray, "ExchangePlans", "ExchangePlan");

	Return TypesArray;
EndFunction

Procedure AddTypesByMetaDataObjectTypes(TypesArray, MetadataJbjectTypeName, TypeName)
	For each MdObject in Metadata[MetadataJbjectTypeName] do
		TypesArray.Add(Type(StrTemplate("%1Ref.%2", TypeName, MdObject.Name)));
	enddo;
EndProcedure

Function HTMLFieldBasedOnWebkit() export
	UT_CommonClientServer.HTMLFieldBasedOnWebkit();
EndFunction

#EndRegion