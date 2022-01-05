///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Область ПрограммныйИнтерфейс

// Returns the data separation mode flag (conditional separation).
// 
// 
// Returns False if the configuration does not support data separation mode (does not contain 
// attributes to share).
//
// Returns:
//  Boolean - True if separation is enabled,
//         - False is separation is disabled or not supported.
//
Function DataSeparationEnabled() Export
	
	//If SubsystemExists("StandardSubsystems.SaaS") Then
	//	ModuleSaaS = CommonModule("SaaS");
	//	Return ModuleSaaS.DataSeparationEnabled();
	//Else
		Return False;
	//EndIf;
	
EndFunction

// Returns True if the "functional" subsystem exists in the configuration.
// Intended for calling optional subsystems (conditional calls).
//
// A subsystem is considered functional if its "Include in command interface" check box is cleared.
//
// Parameters:
//  FullSubsystemName - String - the full name of the subsystem metadata object without the 
//                        "Subsystem." part, case-sensitive.
//                        Example: "StandardSubsystems.ReportOptions".
//
// Example:
//  If Common.SubsystemExists("StandardSubsystems.ReportOptions") Then
//  	ModuleReportOptions = Common.CommonModule("ReportOptions");
//  	ModuleReportOptions.<Method name>();
//  EndIf.
//
// Returns:
//  Boolean - True if exists.
//
Function SubsystemExists(FullSubsystemName) Export
	
	SubsystemsNames = UT_CommonCached.SubsystemsNames();
	Return SubsystemsNames.Get(FullSubsystemName) <> Undefined;
	
EndFunction

// Return ref to common module by name .
//
//  Parameters:
//  Name - String - name of a common module.
//                 "Common",
//                 "CommonClient".
//
// Returns:
//  CommonModule - a common module.
//
Function CommonModule(Name) Export

	If Metadata.CommonModules.Find(Name) <> Undefined Then
		Module = Eval(Name); // ВычислитьВБезопасномРежиме не требуется, т.к. проверка надежная.
	ElsIf StrOccurrenceCount(Name, ".") = 1 Then
		Return ServerManagerModule(Name);
	Else
		Module = Undefined;
	EndIf;
	
//	If TypeOf(Module) <> Type("CommonModule") Then
//	Raise StringFunctionsClientServer.SubstituteParametersToString(
//			NStr("ru = 'Общий модуль ""%1"" не найден.'; en = 'Common module %1 is not found.'"),
//			Name);
//	EndIf

	Return Module;
	
EndFunction

// Returns a server manager module by object name.
Function ServerManagerModule(Name)
	ObjectFound = False;
	
	NameParts = StrSplit(Name, ".");
	If NameParts.Count() = 2 Then
		
		KindName = Upper(NameParts[0]);
		ObjectName = NameParts[1];
		
		If KindName = Upper("Constants") Then
			If Metadata.Constants.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("InformationRegisters") Then
			If Metadata.InformationRegisters.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("AccumulationRegisters") Then
			If Metadata.AccumulationRegisters.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("AccountingRegisters") Then
			If Metadata.AccountingRegisters.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("CalculationRegisters") Then
			If Metadata.CalculationRegisters.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("Catalogs") Then
			If Metadata.Catalogs.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("Documents") Then
			If Metadata.Documents.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("Reports") Then
			If Metadata.Reports.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("DataProcessors") Then
			If Metadata.DataProcessors.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("BusinessProcesses") Then
			If Metadata.BusinessProcesses.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("DocumentJournals") Then
			If Metadata.DocumentJournals.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("Tasks") Then
			If Metadata.Tasks.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("ChartsOfAccounts") Then
			If Metadata.ChartsOfAccounts.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("ExchangePlans") Then
			If Metadata.ExchangePlans.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("ChartsOfCharacteristicTypes") Then
			If Metadata.ChartsOfCharacteristicTypes.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		ElsIf KindName = Upper("ChartsOfCalculationTypes") Then
			If Metadata.ChartsOfCalculationTypes.Find(ObjectName) <> Undefined Then
				ObjectFound = True;
			EndIf;
		EndIf;
		
	EndIf;
	
	If Not ObjectFound Then
		Raise StringFunctionsClientServer.SubstituteParametersToString(
			NStr("ru = 'Объект метаданных ""%1"" не найден,
			           |либо для него не поддерживается получение модуля менеджера.'; 
			           |en = 'Metadata object ""%1"" is not found
			           |or it does not support getting manager modules.'"),
			Name);
	EndIf;

	Module = Eval(Name); // ВычислитьВБезопасномРежиме не требуется, т.к. проверка надежная.

	Return Module;
EndFunction

// Returns a flag indicating whether separated data (included in the separators) can be accessed.
// The flag is session-specific, but can change its value if data separation is enabled on the 
// session run. So, check the flag right before addressing the shared data.
// 
// Returns True if the configuration does not support data separation mode (does not contain 
// attributes to share).
//
// Returns:
//   Boolean - True if separation is not supported or disabled or separation is enabled and 
//                    separators are set.
//          - False if separation is enabled and separators are not set.
//
Function SeparatedDataUsageAvailable() Export

	//If SubsystemExists("StandardSubsystems.SaaS") Then
	//	ModuleSaaS = CommonModule("SaaS");
	//	Return ModuleSaaS.SeparatedDataUsageAvailable();
	//Else
		Return True;
	//EndIf;
	
EndFunction

// Determines whether this infobase is a subordinate node of a distributed infobase (DIB).
// 
//
// Returns:
//  Boolean - True if the infobase is a subordinate DIB node.
//
Function IsSubordinateDIBNode() Export
	
	SetPrivilegedMode(True);
	
	Return ExchangePlans.MasterNode() <> Undefined;
	
EndFunction

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

// Determines the infobase mode: file (True) or client/server (False).
// This function uses the InfobaseConnectionString parameter. You can specify this parameter explicitly.
//
// Parameters:
//  InfobaseConnectionString - String - the parameter is applied if you need to check a connection 
//                 string for another infobase.
//
// Returns:
//  Boolean - True if it is a file infobase.
//
Function FileInfobase(Val InfobaseConnectionString = "") Export
	
	If IsBlankString(InfobaseConnectionString) Then
		InfobaseConnectionString =  InfoBaseConnectionString();
	EndIf;
	Return StrFind(Upper(InfobaseConnectionString), "FILE=") = 1;
	
EndFunction

Procedure SetSafeModeSSL()
//	If SubsystemExists("StandardSubsystems.SecurityProfiles") Then
//		ModuleSafeModeManager = CommonModule("SafeModeManager");
//			If ModuleSafeModeManager.UseSecurityProfiles()
//			AND Not ModuleSafeModeManager.SafeModeSet() Then
//
//			InfobaseProfile = ModuleSafeModeManager.InfobaseSecurityProfile();
//			If ValueIsFilled(InfobaseProfile) Then
//				
//				SetSafeMode(InfobaseProfile);
//				If SafeMode() = True Then
//					SetSafeMode(False);
//				EndIf;
//				
//			EndIf;
//
//		EndIf;
//	EndIf;
EndProcedure

// Выполнить экспортную процедуру объекта встроенного языка по имени.
// При включении профилей безопасности для вызова оператора Выполнить() используется
// переход в безопасный режим с профилем безопасности, используемом для информационной базы
// (если выше по стеку не был установлен другой безопасный режим).
//
// Параметры:
//  Объект    - Произвольный - объект встроенного языка 1С:Предприятия, содержащий методы (например, ОбработкаОбъект).
//  ИмяМетода - Строка       - имя экспортной процедуры модуля объекта обработки.
//  Параметры - Массив       - параметры передаются в процедуру <ИмяПроцедуры>
//                             в порядке расположения элементов массива.
//
Процедура ВыполнитьМетодОбъекта(Знач Объект, Знач ИмяМетода, Знач Параметры = Неопределено) Экспорт
	
	// Проверка имени метода на корректность.
	Попытка
		//@skip-warning
		Тест = Новый Структура(ИмяМетода, ИмяМетода);
	Исключение
		ВызватьИсключение СтрШаблон(
			НСтр("ru='Некорректное значение параметра ИмяМетода (%1) в ОбщегоНазначения.ВыполнитьМетодОбъекта'"),
			ИмяМетода);
	КонецПопытки;
	
	Попытка
		SetSafeModeSSL();
	Исключение
	КонецПопытки;

	ПараметрыСтрока = "";
	Если Параметры <> Неопределено И Параметры.Количество() > 0 Тогда
		Для Индекс = 0 По Параметры.ВГраница() Цикл
			ПараметрыСтрока = ПараметрыСтрока + "Параметры[" + Индекс + "],";
		КонецЦикла;
		ПараметрыСтрока = Сред(ПараметрыСтрока, 1, СтрДлина(ПараметрыСтрока) - 1);
	КонецЕсли;

	Выполнить "Объект." + ИмяМетода + "(" + ПараметрыСтрока + ")";

КонецПроцедуры


// Executes the export procedure by the name with the configuration privilege level.
// To enable the security profile for calling the Execute() operator, the safe mode with the 
// security profile of the infobase is used (if no other safe mode was set in stack previously).
// 
//
// Parameters:
//  MethodName  - String - the name of the export procedure in format:
//                       <object name>.<procedure name>, where <object name> is a common module or 
//                       object manager module.
//  Parameters  - Array - the parameters are passed to <ExportProcedureName>
//                        according to the array item order.
// 
// Example:
//  Parameters = New Array();
//  Parameters.Add("1");
//  Common.ExecuteConfigurationMethod("MyCommonModule.MyProcedure", Parameters);

Procedure ExecuteConfigurationMethod(Val MethodName, Val Parameters = Undefined) Export
	
	CheckConfigurationProcedureName(MethodName);

	Try
		SetSafeModeSSL();
	Except
		
	EndTry;

	ParametersString = "";
	If Parameters <> Undefined AND Parameters.Count() > 0 Then
		For Index = 0 To Parameters.UBound() Do 
			ParametersString = ParametersString + "Parameters[" + Index + "],";
		EndDo;
		ParametersString = Mid(ParametersString, 1, StrLen(ParametersString) - 1);
	EndIf;
	
	Execute MethodName + "(" + ParametersString + ")";
	
EndProcedure


// Checks whether the passed ProcedureName is the name of a configuration export procedure.
// Can be used for checking whether the passed string does not contain an arbitrary algorithm in the 
// 1C:Enterprise in-built language before using it in the Execute and Evaluate operators upon the 
// dynamic call of the configuration code methods.
//
// If the passed string is not a procedure name, an exception is generated.
//
// It is intended to be called from ExecuteConfigurationMethod procedure.
//
// Parameters:
//   ProcedureName - String - the export procedure name to be checked.
//
Procedure CheckConfigurationProcedureName(Val ProcedureName)

	NameParts = StrSplit(ProcedureName, ".");
	If NameParts.Count() <> 2 AND NameParts.Count() <> 3 Then
		Raise StrTemplate(
			NStr("ru = 'Неправильный формат параметра ИмяПроцедуры (передано значение: ""%1"") в ОбщегоНазначения.ВыполнитьМетодКонфигурации'; 
				|en = 'Invalid format of ProcedureName parameter (passed value: ""%1"") in Common.ExecuteConfigurationMethod.'"),
				ProcedureName);
	EndIf;

	ObjectName = NameParts[0];
	If NameParts.Count() = 2 AND Metadata.CommonModules.Find(ObjectName) = Undefined Then
		Raise StrTemplate(
			NStr("ru = 'Неправильный формат параметра ИмяПроцедуры (передано значение: ""%1"") в ОбщегоНазначения.ВыполнитьМетодКонфигурации:
				|Не найден общий модуль ""%2"".'; 
				|en = 'Invalid format of ProcedureName parameter (passed value: ""%1"") in Common.ExecuteConfigurationMethod.
				|Common module ""%2"" is not found.'"),
			ProcedureName,
			ObjectName);
	КонецЕсли;

	If NameParts.Count() = 3 Then
		FullObjectName = NameParts[0] + "." + NameParts[1];
		Try
			Manager = ObjectManagerByName(FullObjectName);
		Except
			Manager = Undefined;
		EndTry;
		If Manager = Undefined Then
			Raise StrTemplate(
				NStr("ru = 'Неправильный формат параметра ИмяПроцедуры (передано значение: ""%1"") в ОбщегоНазначения.ВыполнитьМетодКонфигурации:
				           |Не найден менеджер объекта ""%2"".'; 
				           |en = 'Invalid format of ProcedureName parameter (passed value: ""%1"") in Common.ExecuteConfigurationMethod:
				           |Manager of ""%2"" object is not found.'"), 
					 ProcedureName,FullObjectName);
	   EndIf;
	EndIf;

	ObjectMethodName = NameParts[NameParts.UBound()];
	TempStructure = New Structure;
	Try
		// Checking whether the ProcedureName is a valid ID.
		// For example: MyProcedure.
		TempStructure.Insert(ObjectMethodName);
	Except
		WriteLogEvent(NStr("ru = 'Безопасное выполнение метода'; en = 'Executing method in safe mode'",UT_CommonClientServer.DefaultLanguageCode()),
			EventLogLevel.Error, , , DetailErrorDescription(ErrorInfo()));
		Raise StrTemplate(
			NStr("ru = 'Неправильный формат параметра ИмяПроцедуры (передано значение: ""%1"") в ОбщегоНазначения.ВыполнитьМетодКонфигурации:
			           |Имя метода ""%2"" не соответствует требованиям образования имен процедур и функций.'; 
			           |en = 'Invalid format of ProcedureName parameter (passed value: ""%1"") in Common.ExecuteConfigurationMethod.
			           |Method name %2 does not comply with the procedure and function naming convention.'"),
			ProcedureName, ObjectMethodName);
	EndTry;
	
EndProcedure

// Returns an object manager by name.
// Restriction: does not process business process route points.
//
// Parameters:
//  Name - String - name, for example Catalog, Catalogs, or Catalog.Companies.
//
// Returns:
//  CatalogsManager, CatalogManager, DocumentsManager, DocumentManager, ...
// 
Function ObjectManagerByName(Name)
	Var MOClass, MetadataObjectName, Manager;
	
	NameParts = StrSplit(Name, ".");
	
	If NameParts.Count() > 0 Then
		MOClass = Upper(NameParts[0]);
	EndIf;
	
	If NameParts.Count() > 1 Then
		MetadataObjectName = NameParts[1];
	EndIf;
	
	If      MOClass = "EXCHANGEPLAN"  Or      MOClass = "EXCHANGEPLANS" Then
		Manager = ExchangePlans;
		
	ElsIf MOClass = "CATALOG"       Or MOClass = "CATALOGS" Then
		Manager = Catalogs;
		
	ElsIf MOClass = "DOCUMENT"      Or MOClass = "DOCUMENTS" Then
		Manager = Documents;
		
	ElsIf MOClass = "DOCUMENTJOURNAL" Or MOClass = "DOCUMENTJOURNALS" Then
		Manager = DocumentJournals;
		
	ElsIf MOClass = "ENUM" Or MOClass = "ENUMS" Then
		Manager = Enums;
		
	ElsIf MOClass = "COMMONMODULE" Or MOClass = "COMMONMODULES" Then
		
		Return CommonModule(MetadataObjectName);
		
	ElsIf MOClass = "REPORT"   Or MOClass = "REPORTS" Then
		Manager = Reports;
		
	ElsIf MOClass = "DATAPROCESSOR" Or MOClass = "DATAPROCESSORS" Then
		Manager = DataProcessors;
		
	ElsIf MOClass = "CHARTOFCHARACTERISTICTYPES" Or MOClass = "CHARTSOFCHARACTERISTICTYPES" Then
		Manager = ChartsOfCharacteristicTypes;
		
	ElsIf MOClass = "CHARTOFACCOUNTS"      Or MOClass = "CHARTSOFACCOUNTS" Then
		Manager = ChartsOfAccounts;
		
	ElsIf MOClass = "CHARTOFCALCULATIONTYPES" Or MOClass = "CHARTSOFCALCULATIONTYPES" Then
		Manager = ChartsOfCalculationTypes;
		
	ElsIf MOClass = "INFORMATIONREGISTER"     Or MOClass = "INFORMATIONREGISTERS" Then
		Manager = InformationRegisters;
		
	ElsIf MOClass = "ACCUMULATIONREGISTER"    Or MOClass = "ACCUMULATIONREGISTERS" Then
		Manager = AccumulationRegisters;
		
	ElsIf MOClass = "ACCOUNTINGREGISTER"      Or MOClass = "ACCOUNTINGREGISTERS" Then
		Manager = AccountingRegisters;
		
	ElsIf MOClass = "CALCULATIONREGISTER"     Or MOClass = "CALCULATIONREGISTERS" Then
		
		If NameParts.Count() < 3 Then
			// Calculation register
			Manager = CalculationRegisters;
		Else
			SubordinateMOClass = Upper(NameParts[2]);
			If NameParts.Count() > 3 Then
				SubordinateMOName = NameParts[3];
			EndIf;
			If SubordinateMOClass = "RECALCULATION" Or SubordinateMOClass = "RECALCULATIONS" Then
				// Recalculation
				Try
					Manager = CalculationRegisters[MetadataObjectName].Recalculations;
					MetadataObjectName = SubordinateMOName;
				Except
					Manager = Undefined;
				EndTry;
			EndIf;
		EndIf;
		
	ElsIf MOClass = "BUSINESSPROCESS"    Or MOClass = "BUSINESSPROCESSES" Then
		Manager = BusinessProcesses;
		
	ElsIf MOClass = "TASK" 	      Or MOClass = "TASKS" Then
		Manager = Tasks;
		
	ElsIf MOClass = "CONSTANT"    Or MOClass = "CONSTANTS" Then
		Manager = Constants;
		
	ElsIf MOClass = "SEQUENCE"    Or MOClass = "SEQUENCES" Then
		Manager = Sequences;
	EndIf;
	
	If Manager <> Undefined Then
		If ValueIsFilled(MetadataObjectName) Then
			Try
				Return Manager[MetadataObjectName];
			Except
				Manager = Undefined;
			EndTry;
		Else
			Return Manager;
		EndIf;
	EndIf;

	Raise StrTemplate(NStr("ru = 'Не удалось получить менеджер для объекта ""%1""'; en = 'Cannot get a manager for object %1.'"), Name);

EndFunction

Procedure StorageSave(StorageManager, ObjectKey, SettingsKey, Settings,
			SettingsDetails, Username, UpdateCachedValues)
	
	If Not AccessRight("SaveUserData", Metadata) Then
		Return;
	EndIf;
	
	StorageManager.Save(ObjectKey, SettingsKey(SettingsKey), Settings,
		SettingsDetails, Username);
	
	If UpdateCachedValues Then
		RefreshReusableValues();
	EndIf;
	
EndProcedure

Function StorageLoad(StorageManager, ObjectKey, SettingsKey, DefaultValue,
			SettingsDetails, Username)
	
	Result = Undefined;
	
	If AccessRight("SaveUserData", Metadata) Then
		Result = StorageManager.Load(ObjectKey, SettingsKey(SettingsKey),
			SettingsDetails, Username);
	EndIf;
	
	If Result = Undefined Then
		Result = DefaultValue;
	Else
		SetPrivilegedMode(True);
		If DeleteInvalidRefs(Result) Then
			Result = DefaultValue;
		EndIf;
	EndIf;
	
	Return Result;
	
EndFunction

Procedure StorageDelete(StorageManager, ObjectKey, SettingsKey, Username)
	
	If AccessRight("SaveUserData", Metadata) Then
		StorageManager.Delete(ObjectKey, SettingsKey(SettingsKey), Username);
	EndIf;
	
EndProcedure


// Returns a settings key string with the length within 128 character limit.
// If the string exceeds 128 characters, the part after 96 characters is ignored and MD5 hash sum 
// (32 characters long) is returned instead.
//
// Parameters:
//  String - String -  string of any number of characters.
//
// Returns:
//  String - must not exceed 128 characters.
//
Function SettingsKey(Val Row)
	Return TrimStringUsingChecksum(Row, 128);
EndFunction

// Trims a string to the specified length. The trimmed part is hashed to ensure the result string is 
// unique. Checks an input string and, unless it fits the limit, converts its end into a unique 32 
// symbol string using MD5 algorithm.
// 
//
// Parameters:
//  String - String - the input string of arbitrary length.
//  MaxLength - Number - the maximum valid string length. The minimum value is 32.
//                               
// 
// Returns:
//   String - a string within the maximum length limit.
//
Function TrimStringUsingChecksum(String, MaxLength) Export
	UT_CommonClientServer.Validate(MaxLength >= 32, NStr("ru = 'Параметр МаксимальнаяДлина не может быть меньше 32'; en = 'The MaxLength parameter cannot be less than 32.'"),
		"Common.TrimStringUsingChecksum");

	Result = String;
	If StrLen(String) > MaxLength Then
		Result = Left(String, MaxLength - 32);
		DataHashing = New DataHashing(HashFunction.MD5);
		DataHashing.Append(Mid(String, MaxLength - 32 + 1));
		Result = Result + StrReplace(DataHashing.HashSum, " ", "");
	EndIf;
	Return Result;
EndFunction

// Deletes dead references from a variable.
//
// Parameters:
//   RefOrCollection - AnyReference, Arbitrary - An object or collection to be cleaned up.
//
// Returns:
//   Boolean:
//       * True - If the RefOrCollection of a reference type and the object are not found in the infobase.
//       * False - If the RefOrCollection of a reference type or the object are found in the infobase.
//
Function DeleteInvalidRefs(RefOrCollection)
	
	Type = TypeOf(RefOrCollection);

	If Type = Type("Undefined")
		Or Type = Type("Boolean")
		Or Type = Type("String")
		Or Type = Type("Number")
		Or Type = Type("Date") Then // Optimization - frequently used primitive types.
		
		Return False; // Not a reference.

		ElsIf Type = Type("Array") Then
		
		Count = RefOrCollection.Count();
		For Number = 1 To Count Do
			ReverseIndex = Count - Number;
			Value = RefOrCollection[ReverseIndex];
			If DeleteInvalidRefs(Value) Then
				RefOrCollection.Delete(ReverseIndex);
			EndIf;
		EndDo;
		
		Return False; // Not a reference.

	ElsIf Type = Type("Structure")
		Or Type = Type("Map") Then
		
		For Each KeyAndValue In RefOrCollection Do
			Value = KeyAndValue.Value;
			If DeleteInvalidRefs(Value) Then
				RefOrCollection.Insert(KeyAndValue.Key, Undefined);
			EndIf;
		EndDo;
		
		Return False; // Not a reference.
ElsIf Documents.AllRefsType().ContainsType(Type)
		Or Catalogs.AllRefsType().ContainsType(Type)
		Or Enums.AllRefsType().ContainsType(Type)
		Or ChartsOfCharacteristicTypes.AllRefsType().ContainsType(Type)
		Or ChartsOfAccounts.AllRefsType().ContainsType(Type)
		Or ChartsOfCalculationTypes.AllRefsType().ContainsType(Type)
		Or ExchangePlans.AllRefsType().ContainsType(Type)
		Or BusinessProcesses.AllRefsType().ContainsType(Type)
		Or Tasks.AllRefsType().ContainsType(Type) Then
		// Reference type except BusinessProcessRoutePointRef.
		
		If RefOrCollection.IsEmpty() Then
			Return False; // Blank reference.
		ElsIf ObjectAttributeValue(RefOrCollection, "Ref") = Undefined Then
			RefOrCollection = Undefined;
			Return True; // Dead reference.
		Else
			Return False; // The object is found.
		EndIf;
		
	Else
		
		Return False; // Not a reference.
		
	EndIf;
	
EndFunction

// Returns a structure containing attribute values retrieved from the infobase using the object reference.
// It is recommended that you use it instead of referring to object attributes via the point from 
// the reference to an object for quick reading of separate object attributes from the database.
//
// To read attribute values regardless of current user rights, enable privileged mode.
// 
//
// Parameters:
//  Ref - AnyRef - the object whose attribute values will be read.
//            - String - full name of the predefined item whose attribute values will be read.
//  Attributes - String - attribute names separated with commas, formatted according to structure 
//                       requirements.
//                       Example: "Code, Description, Parent".
//            - Structure - FixedStructure - keys are field aliases used for resulting structure 
//                       keys, values (optional) are field names. If a value is empty, it is 
//                       considered equal to the key.
//                       If key is defined but the value is not specified, the field name is retrieved from the key.
//            - Array - FixedArray - attribute names formatted according to structure property 
//                       requirements.
//  SelectAllowedItems - Boolean - if True, user rights are considered when executing the object query.
//                                if there is a restriction at the record level, all attributes will 
//                                return with the Undefined value. If there are insufficient rights to work with the table, an exception will appear.
//                                if False, an exception is raised if the user has no rights to 
//                                access the table or any attribute.
//
// Returns:
//  Structure - contains names (keys) and values of the requested attributes.
//            - if a blank string is passed to Attributes, a blank structure returns.
//            - if a blank reference is passed to Ref, a structure matching names of Undefined 
//              attributes returns.
//            - if a reference to nonexisting object (invalid reference) is passed to Ref, all 
//              attributes return as Undefined.
//
Function ObjectAttributesValues(Ref, Val Attributes, SelectAllowedItems = False) Export
	
	// If the name of a predefined item is passed.
	If TypeOf(Ref) = Type("String") Then 
		
		FullNameOfPredefinedItem = Ref;
		
		// Calculating reference from the predefined item name.
		// - Performs additional check of predefined item data. Must be executed in advance.
		Try
			Ref = UT_CommonClientServer.PredefinedItem(FullNameOfPredefinedItem);
		Except
			ErrorText = StrTemplate(
			NStr("ru = 'Неверный первый параметр Ссылка в функции ОбщегоНазначения.ЗначенияРеквизитовОбъекта:
			           |%1'; 
			           |en = 'Invalid value of the Ref parameter, function Common.ObjectAttributesValues:
			           |%1.'"), BriefErrorDescription(ErrorInfo()));
			Raise ErrorText;
		EndTry;
		
		// Parsing the full name of the predefined item.
		FullNameParts = StrSplit(FullNameOfPredefinedItem, ".");
		FullMetadataObjectName = FullNameParts[0] + "." + FullNameParts[1];
		
		// If the predefined item is not created in the infobase, check access to the object.
		// In other scenarios, access check is performed during the query.
		If Ref = Undefined Then 

			ObjectMetadata = Metadata.FindByFullName(FullMetadataObjectName);

			If Not AccessRight("Read", ObjectMetadata) Then
				Raise StrTemplate(
						NStr("ru = 'Недостаточно прав для работы с таблицей ""%1""'; en = 'Insufficient rights to access table %1.'"), FullMetadataObjectName);
			EndIf;
		EndIf;

	Else // If a reference is passed.
		
		Try
			FullMetadataObjectName = Ref.Metadata().FullName(); 
		Except
			Raise NStr("ru = 'Неверный первый параметр Ссылка в функции ОбщегоНазначения.ЗначенияРеквизитовОбъекта: 
				           |- Значение должно быть ссылкой или именем предопределенного элемента'; 
				           |en = 'Invalid value of the Ref parameter, function Common.ObjectAttributesValues:
				           |The value must contain predefined item name or reference.'");
		EndTry;
		
	EndIf;
	
// Parsing the attributes if the second parameter is String.
	If TypeOf(Attributes) = Type("String") Then
		If IsBlankString(Attributes) Then
			Return New Structure;
		EndIf;
		
		// Trimming whitespaces.
		Attributes = StrReplace(Attributes, " ", "");
		// Converting the parameter to a field array.
		Attributes = StrSplit(Attributes, ",");
	EndIf;
	
	// Converting the attributes to the unified format.
	FieldsStructure = New Structure;
	If TypeOf(Attributes) = Type("Structure")
		Or TypeOf(Attributes) = Type("FixedStructure") Then
		
		FieldsStructure = Attributes;

	ElsIf TypeOf(Attributes) = Type("Array") Or TypeOf(Attributes) = Type("FixedArray") Then
		
		For Each Attribute In Attributes Do

			Try
				FieldAlias = StrReplace(Attribute, ".", "");
				FieldsStructure.Insert(FieldAlias, Attribute);
			Except 
				// If the alias is not a key.
				
				// Searching for field availability error.
				Result = FindObjectAttirbuteAvailabilityError(FullMetadataObjectName, Attributes);
				If Result.Error Then 
					Raise СтрШаблон(
						NStr("ru = 'Неверный второй параметр Реквизиты в функции ОбщегоНазначения.ЗначенияРеквизитовОбъекта: %1'; en = 'Invalid value of the Attributes parameter, function Common.ObjectAttributesValues: %1.'"),
						Result.ErrorDescription);
				EndIf;
				
				// Cannot identify the error. Forwarding the original error.
				Raise;
			
			EndTry;
		EndDo;
	Else
		Raise СтрШаблон(
			NStr("ru = 'Неверный тип второго параметра Реквизиты в функции ОбщегоНазначения.ЗначенияРеквизитовОбъекта: %1'; en = 'Invalid value type for the Attributes parameter, function Common.ObjectAttributesValues: %1.'"), 
			String(TypeOf(Attributes)));
	EndIf;
	
	// Preparing the result (will be redefined after the query).
	Result = New Structure;
	
	// Generating the text of query for the selected fields.
	FieldQueryText = "";
	For each KeyAndValue In FieldsStructure Do

		FieldName = ?(ValueIsFilled(KeyAndValue.Value),
						KeyAndValue.Value,
						KeyAndValue.Key);
		FieldAlias = KeyAndValue.Key;
		FieldQueryText = 
			FieldQueryText + ?(IsBlankString(FieldQueryText), "", ",") + "
			|	" + FieldName + " AS " + FieldAlias;
		
		
		// Adding the field by its alias to the return value.
		Result.Insert(FieldAlias);
		
	EndDo;
	
	// If the predefined item is missing from the infobase.
	// - the result will reflect that the item is unavailable or pass an empty reference.
	If Ref = Undefined Then 
		Return Result;
	EndIf;

	QueryText = "SELECT " + ?(SelectAllowedItems, "ALLOWED", "") + "
																		   |" + FieldQueryText + "
																									|FROM
																									|	"
		+ FullMetadataObjectName + " AS Table
									   |WHERE
									   |	Table.Ref = &Ref";
	
	// Executing the query.
	Query = New Query;
	Query.SetParameter("Ref", Ref);
	Query.Text = QueryText;

	Try
		Selection = Query.Execute().Select();
	Except
		
	    // If the attributes were passed as a string, they are already converted to array.
		// If the attributes were passed as an array, no additional conversion is needed.
		// If the attributes were passed as a structure, conversion to array is needed.
		// Otherwise, an exception would be raised.
		If Type("Structure") = TypeOf(Attributes) Then
			Attributes = New Array;
			For each KeyAndValue In FieldsStructure Do
				FieldName = ?(ValueIsFilled(KeyAndValue.Value),
							KeyAndValue.Value,
							KeyAndValue.Key);
				Attributes.Add(FieldName);
			EndDo;
		EndIf;
		
// Searching for field availability error.
		Result = FindObjectAttirbuteAvailabilityError(FullMetadataObjectName, Attributes);
		If Result.Error Then 
			Raise СтрШаблон(
				NStr("ru = 'Неверный второй параметр Реквизиты в функции ОбщегоНазначения.ЗначенияРеквизитовОбъекта: %1'; en = 'Invalid value of the Attributes parameter, function Common.ObjectAttributesValues: %1.'"), 
				Result.ErrorDescription);
		EndIf;
		
		// Cannot identify the error. Forwarding the original error.
		Raise;
		
	EndTry;
	
	// Filling in attributes.
	If Selection.Next() Then
		FillPropertyValues(Result, Selection);
	EndIf;
	
	Return Result;
	
EndFunction

// Returns attribute values retrieved from the infobase using the object reference.
// It is recommended that you use it instead of referring to object attributes via the point from 
// the reference to an object for quick reading of separate object attributes from the database.
//
// To read attribute values regardless of current user rights, enable privileged mode.
// 
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
	
	If IsBlankString(AttributeName) Then 
		Raise 
			NStr("ru = 'Неверный второй параметр ИмяРеквизита в функции ОбщегоНазначения.ЗначениеРеквизитаОбъекта: 
			           |- Имя реквизита должно быть заполнено'; 
			           |en = 'Invalid value of the AttributeName parameter, function Common.ObjectAttributeValue:
			           |The parameter cannot be empty.'");
	EndIf;
	
	Result = ObjectAttributesValues(Ref, AttributeName, SelectAllowedItems);
	Return Result[StrReplace(AttributeName, ".", "")];
	
EndFunction 

// Searching for expressions to be checked in metadata object attributes.
// 
// Parameters:
//  MetadataObjectFullName - String - object full name.
//  ExpressionsToCheck - Array - field names or metadata object expressions to check.
// 
// Returns:
//  Structure - Check result.
//  * Error - Boolean - the flag indicating whether an error is found.
//  * ErrorDescription - String - the descriptions of errors that are found.
//
// Example:
//  
// Attributes = New Array;
// Attributes.Add("Number");
// Attributes.Add("Currency.FullDescription");
//
// Result = Common.FindObjectAttirbuteAvailabilityError("Document._DemoSalesOrder", Attributes);
//
// If Result.Error Then
//     CallException Result.ErrorDescription;
// EndIf.
//
Function FindObjectAttirbuteAvailabilityError(FullMetadataObjectName, ExpressionsToCheck)

	ObjectMetadata = Metadata.FindByFullName(FullMetadataObjectName);
	
	If ObjectMetadata = Undefined Then 
		Return New Structure("Error, ErrorDescription", True, 
			StringFunctionsClientServer.SubstituteParametersToString(
				NStr("ru = 'Ошибка получения метаданных ""%1""'; en = 'Cannot get metadata ""%1""'"), FullMetadataObjectName));
	EndIf;

	// Allowing calls from an external data processor or extension in safe mode.
	// On metadata check, the data on schema source fields availability is not classified.
	SetSafeModeDisabled(True);
	SetPrivilegedMode(True);

	Schema = New QuerySchema;
	Package = Schema.QueryBatch.Add(Type("QuerySchemaSelectQuery"));
	Operator = Package.Operators.Get(0);
	
	Source = Operator.Sources.Add(FullMetadataObjectName, "Table");
	ErrorText = "";

	For Each CurrentExpression In ExpressionsToCheck Do
		
		If Not QuerySchemaSourceFieldAvailable(Source, CurrentExpression) Then 
			ErrorText = ErrorText + Chars.LF + StringFunctionsClientServer.SubstituteParametersToString(
				NStr("ru = '- Поле объекта ""%1"" не найдено'; en = '- The ""%1"" object field not found.'"), CurrentExpression);
		EndIf;
		
	EndDo;
		
	Return New Structure("Error, ErrorDescription", Not IsBlankString(ErrorText), ErrorText);
	
EndFunction

// It is used in FindObjectAttirbuteAvailabilityError.
// It checks whether the field of the expression being checked is available in the source of the query schema operator.
//
Function QuerySchemaSourceFieldAvailable(OperatorSource, ExpressToCheck)
	
	FieldNameParts = StrSplit(ExpressToCheck, ".");
	AvailableFields = OperatorSource.Source.AvailableFields;
	
	CurrentFieldNamePart = 0;
	While CurrentFieldNamePart < FieldNameParts.Count() Do 
		
		CurrentField = AvailableFields.Find(FieldNameParts.Get(CurrentFieldNamePart)); 
		
		If CurrentField = Undefined Then 
			Return False;
		EndIf;
		
		// Incrementing the next part of the field name and the relevant field availability list.
		CurrentFieldNamePart = CurrentFieldNamePart + 1;
		AvailableFields = CurrentField.Fields;
		
	EndDo;
	
	Return True;
	
EndFunction

// Returns True if the infobase is connected to 1C:Fresh.
//
// Returns:
//  Boolean - indicates a standalone workstation.
//
Function IsStandaloneWorkplace() Export
	
//	If SubsystemExists("StandardSubsystems.DataExchange") Then
//		ModuleDataExchangeServer = CommonModule("DataExchangeServer");
//		Return ModuleDataExchangeServer.IsStandaloneWorkplace();
//	EndIf;
	
	Return False;
	
EndFunction

Function CanUseUniversalTools() Export
	Return AccessRight("View", Metadata.Subsystems.UT_UniversalTools);
EndFunction


#Область РаботаСФормамиИнструментов

Procedure AddToCommonCommandsCommandBar(Form, FormMainCommandBar)
	Если Form.ПоложениеКоманднойПанели=ПоложениеКоманднойПанелиФормы.Нет 
		И FormMainCommandBar=Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если FormMainCommandBar=Неопределено Тогда
		КоманднаяПанель= Form.КоманднаяПанель;
	Иначе
		КоманднаяПанель=FormMainCommandBar;
	КонецЕсли;
	
	ОписаниеКоманды = UT_Forms.ButtonCommandNewDescription();
	ОписаниеКоманды.Name = "УИ_ОткрытьНовуюФормуИнструмента";
	ОписаниеКоманды.CommandName = ОписаниеКоманды.Имя;
	ОписаниеКоманды.Action="Подключаемый_ВыполнитьОбщуюКомандуИнструментов";
	ОписаниеКоманды.ItemParent=КоманднаяПанель;
	ОписаниеКоманды.Picture = БиблиотекаКартинок.НовоеОкно;
	ОписаниеКоманды.Representation = ОтображениеКнопки.Картинка;
	ОписаниеКоманды.ToolTip = "Открывает еще одну пустую форму текущего инструмента";
	ОписаниеКоманды.Title = "Открыть новую форму";
	UT_Forms.CreateCommandByDescription(Form, ОписаниеКоманды);
	UT_Forms.CreateButtonByDescription(Form, ОписаниеКоманды);
EndProcedure

Procedure ToolFormOnCreateAtServer(Form, Cancel, StandardProcessing, FormMainCommandBar = Undefined) Export
	AddToCommonCommandsCommandBar(Form, FormMainCommandBar);
EndProcedure

#КонецОбласти

#Область НастройкиИнструментов


#КонецОбласти

#КонецОбласти

// Возвращает исключения при поиске мест использования объектов.
//
// Возвращаемое значение:
//   Соответствие - Исключения поиска ссылок в разрезе объектов метаданных:
//       * Ключ - ОбъектМетаданных - Объект метаданных, для которого применяются исключения.
//       * Значение - Строка, Массив - описание исключенных реквизитов.
//           Если "*", то исключены все реквизиты объекта метаданных.
//           Если массив строк, то содержит относительные имена исключенных реквизитов.
//
Функция ИсключенияПоискаСсылок() Экспорт

	ИсключенияПоискаИнтеграция = Новый Массив;

//	МодульИнтеграцияПодсистемБСП=ОбщийМодуль("ИнтеграцияПодсистемБСП");
//	Если МодульИнтеграцияПодсистемБСП <> Неопределено Тогда
//		МодульИнтеграцияПодсистемБСП.ПриДобавленииИсключенийПоискаСсылок(ИсключенияПоискаИнтеграция);
//	КонецЕсли;

	ИсключенияПоиска = Новый Массив;
//	МодульОбщегоНазначенияПереопределяемый=ОбщийМодуль("ОбщегоНазначенияПереопределяемый");
//	Если МодульОбщегоНазначенияПереопределяемый <> Неопределено Тогда
//		МодульОбщегоНазначенияПереопределяемый.ПриДобавленииИсключенийПоискаСсылок(ИсключенияПоиска);
//	КонецЕсли;

	UT_CommonClientServer.SupplementArray(ИсключенияПоиска, ИсключенияПоискаИнтеграция);

	Результат = Новый Соответствие;
	Для Каждого ИсключениеПоиска Из ИсключенияПоиска Цикл
		// Определение полного имени реквизита и объекта метаданных - носителя реквизита.
		Если ТипЗнч(ИсключениеПоиска) = Тип("Строка") Тогда
			ПолноеИмя          = ИсключениеПоиска;
			МассивПодстрок     = СтрРазделить(ПолноеИмя, ".");
			КоличествоПодстрок = МассивПодстрок.Количество();
			ОбъектМетаданных   = Метаданные.НайтиПоПолномуИмени(МассивПодстрок[0] + "." + МассивПодстрок[1]);
		Иначе
			ОбъектМетаданных   = ИсключениеПоиска;
			ПолноеИмя          = ОбъектМетаданных.ПолноеИмя();
			МассивПодстрок     = СтрРазделить(ПолноеИмя, ".");
			КоличествоПодстрок = МассивПодстрок.Количество();
			Если КоличествоПодстрок > 2 Тогда
				Пока Истина Цикл
					Родитель = ОбъектМетаданных.Родитель();
					Если ТипЗнч(Родитель) = Тип("ОбъектМетаданныхКонфигурация") Тогда
						Прервать;
					Иначе
						ОбъектМетаданных = Родитель;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
		// Регистрация.
		Если КоличествоПодстрок < 4 Тогда
			Результат.Вставить(ОбъектМетаданных, "*");
		Иначе
			ПутиКРеквизитам = Результат.Получить(ОбъектМетаданных);
			Если ПутиКРеквизитам = "*" Тогда
				Продолжить; // Весь объект метаданных уже исключен.
			ИначеЕсли ПутиКРеквизитам = Неопределено Тогда
				ПутиКРеквизитам = Новый Массив;
				Результат.Вставить(ОбъектМетаданных, ПутиКРеквизитам);
			КонецЕсли;
			// Формат реквизита:
			//   "<ВидОМ>.<ИмяОМ>.<ТипРеквизитаИлиТЧ>.<ИмяРеквизитаИлиТЧ>[.<ТипРеквизита>.<ИмяРеквизитаТЧ>]".
			//   Примеры:
			//     "РегистрСведений.ВерсииОбъектов.Реквизит.АвторВерсии",
			//     "Документ._ДемоЗаказПокупателя.ТабличнаяЧасть.СчетаНаОплату.Реквизит.Счет",
			//     "ПланВидовРасчета._ДемоОсновныеНачисления.СтандартнаяТабличнаяЧасть.БазовыеВидыРасчета.СтандартныйРеквизит.ВидРасчета".
			// Относительный путь к реквизиту должен получиться таким, чтобы его можно было использовать в условиях запроса:
			//   "<ИмяРеквизитаИлиТЧ>[.<ИмяРеквизитаТЧ>]".
			Если КоличествоПодстрок = 4 Тогда
				ОтносительныйПутьКРеквизиту = МассивПодстрок[3];
			Иначе
				ОтносительныйПутьКРеквизиту = МассивПодстрок[3] + "." + МассивПодстрок[5];
			КонецЕсли;
			ПутиКРеквизитам.Добавить(ОтносительныйПутьКРеквизиту);
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;

КонецФункции

// Подключает компоненту, выполненную по технологии Native API и COM.
// Компонента должна храниться в макете конфигурации в виде ZIP-архива.
//
// Параметры:
//  Идентификатор   - Строка - идентификатор объекта внешней компоненты.
//  ПолноеИмяМакета - Строка - полное имя макета конфигурации, хранящего ZIP-архив.
//
// Возвращаемое значение:
//  AddIn, Неопределено - экземпляр объекта внешней компоненты или Неопределено, если не удалось создать.
//
// Пример:
//
//  ПодключаемыйМодуль = ОбщегоНазначения.ПодключитьКомпонентуИзМакета(
//      "QRCodeExtension",
//      "ОбщийМакет.КомпонентаПечатиQRКода");
//
//  Если ПодключаемыйМодуль <> Неопределено Тогда 
//      // ПодключаемыйМодуль содержит созданный экземпляр подключенной компоненты.
//  КонецЕсли;
//
//  ПодключаемыйМодуль = Неопределено;
//
Функция ПодключитьКомпонентуИзМакета(Идентификатор, ПолноеИмяМакета) Экспорт

	ПодключаемыйМодуль = Неопределено;

	Если Не МакетСуществует(ПолноеИмяМакета) Тогда
		ВызватьИсключение СтрШаблон(
			НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на сервере
				 |из %2
				 |по причине:
				 |Подключение на сервере не из макета запрещено'"), Идентификатор, ПолноеИмяМакета);
	КонецЕсли;

	Местоположение = ПолноеИмяМакета;
	СимволическоеИмя = Идентификатор + "SymbolicName";

	Если ПодключитьВнешнююКомпоненту(Местоположение, СимволическоеИмя) Тогда

		Попытка
			ПодключаемыйМодуль = Новый ("AddIn." + СимволическоеИмя + "." + Идентификатор);
			Если ПодключаемыйМодуль = Неопределено Тогда
				ВызватьИсключение НСтр("ru = 'Оператор Новый вернул Неопределено'");
			КонецЕсли;
		Исключение
			ПодключаемыйМодуль = Неопределено;
			ТекстОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецПопытки;

		Если ПодключаемыйМодуль = Неопределено Тогда

			ТекстОшибки = СтрШаблон(
				НСтр("ru = 'Не удалось создать объект внешней компоненты ""%1"", подключенной на сервере
					 |из макета ""%2"",
					 |по причине:
					 |%3'"), Идентификатор, Местоположение, ТекстОшибки);

			ЗаписьЖурналаРегистрации(
				НСтр("ru = 'Подключение внешней компоненты на сервере'",
				UT_CommonClientServer.DefaultLanguageCode()), УровеньЖурналаРегистрации.Ошибка, , , ТекстОшибки);

		КонецЕсли;

	Иначе

		ТекстОшибки = СтрШаблон(
			НСтр("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на сервере
				 |из макета ""%2""
				 |по причине:
				 |Метод ПодключитьВнешнююКомпоненту вернул Ложь.'"), Идентификатор, Местоположение);

		ЗаписьЖурналаРегистрации(
			НСтр("ru = 'Подключение внешней компоненты на сервере'",
			UT_CommonClientServer.DefaultLanguageCode()), УровеньЖурналаРегистрации.Ошибка, , , ТекстОшибки);

	КонецЕсли;

	Возврат ПодключаемыйМодуль;

КонецФункции


// Возвращает описание предмета в виде текстовой строки.
// 
// Параметры:
//  СсылкаНаПредмет - ЛюбаяСсылка - объект ссылочного типа.
//
// Возвращаемое значение:
//   Строка - представление предмета.
// 
Функция ПредметСтрокой(СсылкаНаПредмет) Экспорт

	Результат = "";
	
	//@skip-warning
	Если СсылкаНаПредмет = Неопределено Или СсылкаНаПредмет.Пустая() Тогда
		Результат = НСтр("ru = 'не задан'");
	ИначеЕсли Метаданные.Документы.Содержит(СсылкаНаПредмет.Метаданные()) Или Метаданные.Перечисления.Содержит(
		СсылкаНаПредмет.Метаданные()) Тогда
		Результат = Строка(СсылкаНаПредмет);
	Иначе	
		//@skip-warning
		ПредставлениеОбъекта = СсылкаНаПредмет.Метаданные().ПредставлениеОбъекта;
		Если ПустаяСтрока(ПредставлениеОбъекта) Тогда
			//@skip-warning
			ПредставлениеОбъекта = СсылкаНаПредмет.Метаданные().Представление();
		КонецЕсли;
		Результат = СтрШаблон("%1 (%2)", Строка(СсылкаНаПредмет), ПредставлениеОбъекта);
	КонецЕсли;

	Возврат Результат;

КонецФункции

Процедура ЗарегистрироватьОшибкуЗамены(Результат, Знач Ссылка, Знач ОписаниеОшибки)

	Результат.ЕстьОшибки = Истина;

	Строка = Результат.Ошибки.Добавить();
	Строка.Ссылка = Ссылка;
	Строка.ПредставлениеОбъектаОшибки = ОписаниеОшибки.ПредставлениеОбъектаОшибки;
	Строка.ОбъектОшибки               = ОписаниеОшибки.ОбъектОшибки;
	Строка.ТекстОшибки                = ОписаниеОшибки.ТекстОшибки;
	Строка.ТипОшибки                  = ОписаниеОшибки.ТипОшибки;

КонецПроцедуры

Функция ОписаниеОшибкиЗамены(Знач ТипОшибки, Знач ОбъектОшибки, Знач ПредставлениеОбъектаОшибки, Знач ТекстОшибки)
	Результат = Новый Структура;

	Результат.Вставить("ТипОшибки", ТипОшибки);
	Результат.Вставить("ОбъектОшибки", ОбъектОшибки);
	Результат.Вставить("ПредставлениеОбъектаОшибки", ПредставлениеОбъектаОшибки);
	Результат.Вставить("ТекстОшибки", ТекстОшибки);

	Возврат Результат;
КонецФункции

// Возвращает описание типа, включающего в себя все возможные ссылочные типы конфигурации.
//
// Возвращаемое значение:
//  ОписаниеТипов - все ссылочные типы конфигурации.
//
Функция AllRefsTypeDescription() Экспорт

	Возврат UT_CommonCached.AllRefsTypeDescription();

КонецФункции

#Область СравнениеОбъектов

Процедура ДобавитьОбъектВМассивОбъектовКСравнению(МассивОБъектов, СсылкаНаОбъект)
	Если МассивОБъектов.Найти(СсылкаНаОбъект) = Неопределено Тогда
		МассивОБъектов.Добавить(СсылкаНаОбъект);
	КонецЕсли;
КонецПроцедуры

Функция КлючНастроекОбъектовКСравнению() Экспорт
	Возврат "ОбъектыКСравнению";
КонецФункции

Процедура AddObjectsArrayToCompare(Объекты) Экспорт
	МассивОбъектовКСравнению=ОбъектыДобавленныеКСравнению();

	Если ТипЗнч(Объекты) = Тип("Массив") Тогда
		Для Каждого Эл Из Объекты Цикл
			ДобавитьОбъектВМассивОбъектовКСравнению(МассивОбъектовКСравнению, Эл);
		КонецЦикла;
	ИначеЕсли ТипЗнч(Объекты) = Тип("СписокЗначений") Тогда
		Для Каждого Эл Из Объекты Цикл
			ДобавитьОбъектВМассивОбъектовКСравнению(МассивОбъектовКСравнению, Эл.Значение);
		КонецЦикла;
	Иначе
		ДобавитьОбъектВМассивОбъектовКСравнению(МассивОбъектовКСравнению, Объекты);
	КонецЕсли;

	UT_Common.ХранилищеСистемныхНастроекСохранить(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(), КлючНастроекОбъектовКСравнению(),
		МассивОбъектовКСравнению);

КонецПроцедуры

Функция ОбъектыДобавленныеКСравнению() Экспорт
	КлючОбъекта=UT_CommonClientServer.ObjectKeyInSettingsStorage();
	КлючНастроек=КлючНастроекОбъектовКСравнению();

	МассивОбъектовКСравнению=ХранилищеСистемныхНастроекЗагрузить(КлючОбъекта, КлючНастроек, , , ИмяПользователя());
	Если МассивОбъектовКСравнению = Неопределено Тогда
		МассивОбъектовКСравнению=Новый Массив;
	КонецЕсли;

	Возврат МассивОбъектовКСравнению;
КонецФункции

Процедура ОчиститьОбъектыДобавленныеКСравнению() Экспорт
	UT_Common.ХранилищеСистемныхНастроекСохранить(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(), КлючНастроекОбъектовКСравнению(), Новый Массив);
КонецПроцедуры

#КонецОбласти

#Область НастройкаОтладкаДополнительныхОтчетовИОбработок

Функция КлючНастроекОтладкиДополнительныхОтчетовИОбработок() Экспорт
	Возврат "НастройкиОтладкиДополнительныхОтчетовИОбработок";
КонецФункции

Функция НовыйСтруктураНастройкиОтладкиДополнительнойОбработки() Экспорт
	Структура=Новый Структура;
	Структура.Вставить("ОтладкаВключена", Ложь);
	Структура.Вставить("ИмяФайлаНаСервере", "");
	Структура.Вставить("Пользователь", Неопределено);

	Возврат Структура;
КонецФункции

Функция НастройкиОтладкиДополнительнойОбработки(ДополнительнаяОбработка) Экспорт
	КлючОбъекта=UT_CommonClientServer.ObjectKeyInSettingsStorage();
	КлючНастроек=КлючНастроекОтладкиДополнительныхОтчетовИОбработок();

	СоответствиеНастроек=ХранилищеСистемныхНастроекЗагрузить(КлючОбъекта, КлючНастроек);
	Если СоответствиеНастроек = Неопределено Тогда
		СоответствиеНастроек=Новый Соответствие;
	КонецЕсли;

	СтруктураНастройки=НовыйСтруктураНастройкиОтладкиДополнительнойОбработки();
	СохраненнаяНастройка=СоответствиеНастроек[ДополнительнаяОбработка];
	Если СохраненнаяНастройка <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(СтруктураНастройки, СохраненнаяНастройка);
	КонецЕсли;

	Возврат СтруктураНастройки;
КонецФункции

Процедура ЗаписатьНастройкиОтладкиДополнительнойОбработки(ДополнительнаяОбработка, Настройки) Экспорт
	КлючОбъекта=UT_CommonClientServer.ObjectKeyInSettingsStorage();
	КлючНастроек=КлючНастроекОтладкиДополнительныхОтчетовИОбработок();

	СоответствиеНастроек=ХранилищеСистемныхНастроекЗагрузить(КлючОбъекта, КлючНастроек);
	Если СоответствиеНастроек = Неопределено Тогда
		СоответствиеНастроек=Новый Соответствие;
	КонецЕсли;

	СоответствиеНастроек.Вставить(ДополнительнаяОбработка, Настройки);

	UT_Common.ХранилищеСистемныхНастроекСохранить(
		КлючОбъекта, КлючНастроек, СоответствиеНастроек);

КонецПроцедуры

#КонецОбласти

#Область ДанныеВБазе

////////////////////////////////////////////////////////////////////////////////
// Общие процедуры и функции для работы с данными в базе.

// Производит замену ссылок во всех данных. После замены неиспользуемые ссылки опционально удаляются.
// Замена ссылок происходит с транзакциями по изменяемому объекту и его связям, не по анализируемой ссылке.
// При вызове в неразделенном сеансе не выявляет ссылок в разделенных областях.
//
// Параметры:
//   ПарыЗамен - Соответствие - пары замен.
//       * Ключ     - ЛюбаяСсылка - что ищем (дубль).
//       * Значение - ЛюбаяСсылка - на что заменяем (оригинал).
//       Ссылки сами на себя и пустые ссылки для поиска будут проигнорированы.
//   
//   Параметры - Структура - Необязательный. Параметры замены.
//       
//       * СпособУдаления - Строка - необязательный. Что делать с дублем после успешной замены.
//           ""                - по умолчанию. Не предпринимать никаких действий.
//           "Пометка"         - помечать на удаление.
//           "Непосредственно" - удалять непосредственно.
//       
//       * УчитыватьПрикладныеПравила - Булево - необязательный. Режим проверки параметра ПарыЗамен.
//           Истина - по умолчанию. Проверять каждую пару "дубль-оригинал" (вызывается функция
//                    ВозможностьЗаменыЭлементов модуля менеджера).
//           Ложь   - отключить прикладные проверки пар.
//       
//       * ПараметрыЗаписи.ЗаписьВРежимеЗагрузки  - Булево - необязательный. Режим записи мест использования при замене дублей на оригиналы.
//           Истина - по умолчанию. Места использования дублей записываются в режиме ОбменДанными.Загрузка = Ложь.
//           Ложь   - запись ведется в режиме ОбменДанными.Загрузка = Истина.
//       
//       * ЗаменаПарыВТранзакции - Булево - необязательный. Определяет размер транзакции.
//           Истина - по умолчанию. Транзакция охватывает все места использования одного дубля. Может быть очень ресурсоемко 
//                    в случае большого количества мест использований.
//           Ложь   - замена каждого места использования выполняется в отдельной транзакции.
//       
//       * ПараметрыЗаписи.ПривелигированныйРежим - Булево - необязательный. Требуется ли устанавливать привилегированный режим перед запись.
//           Ложь   - по умолчанию. Записывать с текущими правами.
//           Истина - записывать в привилегированном режиме.
//
// Возвращаемое значение:
//   ТаблицаЗначений - неуспешные замены (ошибки).
//       * Ссылка - ЛюбаяСсылка - ссылка, которую заменяли.
//       * ОбъектОшибки - Произвольный - объект - причина ошибки.
//       * ПредставлениеОбъектаОшибки - Строка - строковое представление объекта ошибки.
//       * ТипОшибки - Строка - тип ошибки:
//           "ОшибкаБлокировки"  - при обработке ссылки некоторые объекты были заблокированы.
//           "ДанныеИзменены"    - в процессе обработки данные были изменены другим пользователем.
//           "ОшибкаЗаписи"      - не смогли записать объект, или метод ВозможностьЗаменыЭлементов вернул отказ.
//           "ОшибкаУдаления"    - не смогли удалить объект.
//           "НеизвестныеДанные" - при обработке были найдены данные, которые не планировались к анализу, замена не реализована.
//       * ТекстОшибки - Строка - подробное описание ошибки.
//
Функция ЗаменитьСсылки(Знач ПарыЗамен, Знач Параметры = Неопределено) Экспорт

	ТипСтрока = Новый ОписаниеТипов("Строка");

	ОшибкиЗамены = Новый ТаблицаЗначений;
	ОшибкиЗамены.Колонки.Добавить("Ссылка");
	ОшибкиЗамены.Колонки.Добавить("ОбъектОшибки");
	ОшибкиЗамены.Колонки.Добавить("ПредставлениеОбъектаОшибки", ТипСтрока);
	ОшибкиЗамены.Колонки.Добавить("ТипОшибки", ТипСтрока);
	ОшибкиЗамены.Колонки.Добавить("ТекстОшибки", ТипСтрока);

	ОшибкиЗамены.Индексы.Добавить("Ссылка");
	ОшибкиЗамены.Индексы.Добавить("Ссылка, ОбъектОшибки, ТипОшибки");

	Результат = Новый Структура;
	Результат.Вставить("ЕстьОшибки", Ложь);
	Результат.Вставить("Ошибки", ОшибкиЗамены);
	
	// Значения по умолчанию.
	ПараметрыВыполнения = Новый Структура;
	ПараметрыВыполнения.Вставить("УдалятьНепосредственно", Ложь);
	ПараметрыВыполнения.Вставить("ПомечатьНаУдаление", Ложь);
	ПараметрыВыполнения.Вставить("УчитыватьПрикладныеПравила", Ложь);
	ЗаменаПарыВТранзакции = Истина;

	ПараметрыЗаписи=UT_CommonClientServer.WriteParametersStructureByDefaults();
	
	// Переданные значения.
	ЗначениеПараметра = UT_CommonClientServer.StructureProperty(Параметры, "СпособУдаления");
	Если ЗначениеПараметра = "Непосредственно" Тогда
		ПараметрыВыполнения.УдалятьНепосредственно = Истина;
		ПараметрыВыполнения.ПомечатьНаУдаление     = Ложь;
	ИначеЕсли ЗначениеПараметра = "Пометка" Тогда
		ПараметрыВыполнения.УдалятьНепосредственно = Ложь;
		ПараметрыВыполнения.ПомечатьНаУдаление     = Истина;
	КонецЕсли;

	ЗначениеПараметра = UT_CommonClientServer.StructureProperty(Параметры, "ЗаменаПарыВТранзакции");
	Если ТипЗнч(ЗначениеПараметра) = Тип("Булево") Тогда
		ЗаменаПарыВТранзакции = ЗначениеПараметра;
	КонецЕсли;

	ЗначениеПараметра = UT_CommonClientServer.StructureProperty(Параметры, "УчитыватьПрикладныеПравила");
	Если ТипЗнч(ЗначениеПараметра) = Тип("Булево") Тогда
		ПараметрыВыполнения.УчитыватьПрикладныеПравила = ЗначениеПараметра;
	КонецЕсли;

	ЗначениеПараметра = UT_CommonClientServer.StructureProperty(Параметры, "ПараметрыЗаписи");
	Если ТипЗнч(ЗначениеПараметра) = Тип("Структура") Тогда
		ЗаполнитьЗначенияСвойств(ПараметрыЗаписи, ЗначениеПараметра);
	КонецЕсли;
	ПараметрыВыполнения.Вставить("ПараметрыЗаписи", ПараметрыЗаписи);
	Если ПарыЗамен.Количество() = 0 Тогда
		Возврат Результат.Ошибки;
	КонецЕсли;

	Дубли = Новый Массив;
	Для Каждого КлючЗначение Из ПарыЗамен Цикл
		Дубль = КлючЗначение.Ключ;
		Оригинал = КлючЗначение.Значение;
		Если Дубль = Оригинал Или Дубль.Пустая() Тогда
			Продолжить; // Самого на себя и пустые ссылки не заменяем.
		КонецЕсли;
		Дубли.Добавить(Дубль);
		// Пропускаем промежуточные замены, чтобы не строить граф (если A->B и B->C то вместо A->B производится замена A->C).
		ОригиналОригинала = ПарыЗамен[Оригинал];
		ЕстьОригиналОригинала = (ОригиналОригинала <> Неопределено И ОригиналОригинала <> Дубль И ОригиналОригинала
			<> Оригинал);
		Если ЕстьОригиналОригинала Тогда
			Пока ЕстьОригиналОригинала Цикл
				Оригинал = ОригиналОригинала;
				ОригиналОригинала = ПарыЗамен[Оригинал];
				ЕстьОригиналОригинала = (ОригиналОригинала <> Неопределено И ОригиналОригинала <> Дубль
					И ОригиналОригинала <> Оригинал);
			КонецЦикла;
			ПарыЗамен.Вставить(Дубль, Оригинал);
		КонецЕсли;
	КонецЦикла;

//	Если ПараметрыВыполнения.УчитыватьПрикладныеПравила И ПодсистемаСуществует(
//		"СтандартныеПодсистемы.ПоискИУдалениеДублей") Тогда
//		МодульПоискИУдалениеДублей = ОбщийМодуль("ПоискИУдалениеДублей");
//		Ошибки = МодульПоискИУдалениеДублей.ПроверитьВозможностьЗаменыЭлементов(ПарыЗамен, Параметры);
//		Для Каждого КлючЗначение Из Ошибки Цикл
//			Дубль = КлючЗначение.Ключ;
//			Оригинал = ПарыЗамен[Дубль];
//			ТекстОшибки = КлючЗначение.Значение;
//			Причина = ОписаниеОшибкиЗамены("ОшибкаЗаписи", Оригинал, ПредметСтрокой(Оригинал), ТекстОшибки);
//			ЗарегистрироватьОшибкуЗамены(Результат, Дубль, Причина);
//
//			Индекс = Дубли.Найти(Дубль);
//			Если Индекс <> Неопределено Тогда
//				Дубли.Удалить(Индекс); // пропускаем проблемный элемент.
//			КонецЕсли;
//		КонецЦикла;
//	КонецЕсли;

	ТаблицаПоиска = МестаИспользования(Дубли);
	
	// Для каждой ссылки объекта будем производить замены в порядке "Константа", "Объект", "Набор".
	// Одновременно пустая строка в этой колонке - флаг того, что эта замена не нужна или уже была произведена.
	ТаблицаПоиска.Колонки.Добавить("КлючЗамены", ТипСтрока);
	ТаблицаПоиска.Индексы.Добавить("Ссылка, КлючЗамены");
	ТаблицаПоиска.Индексы.Добавить("Данные, КлючЗамены");
	
	// Вспомогательные данные
	ТаблицаПоиска.Колонки.Добавить("ЦелеваяСсылка");
	ТаблицаПоиска.Колонки.Добавить("Обработано", Новый ОписаниеТипов("Булево"));
	
	// Определяем порядок обработки и проверяем то, что мы можем обработать.
	Количество = Дубли.Количество();
	Для Номер = 1 По Количество Цикл
		ОбратныйИндекс = Количество - Номер;
		Дубль = Дубли[ОбратныйИндекс];
		РезультатРазметки = РазметитьМестаИспользования(ПараметрыВыполнения, Дубль, ПарыЗамен[Дубль], ТаблицаПоиска);
		Если Не РезультатРазметки.Успех Тогда
			// Найдены неизвестные типы замены, не будем работать с этой ссылкой, возможно нарушение связности.
			Дубли.Удалить(ОбратныйИндекс);
			Для Каждого Ошибка Из РезультатРазметки.ОшибкиРазметки Цикл
				ПредставлениеОбъектаОшибки = ПредметСтрокой(Ошибка.Объект);
				ЗарегистрироватьОшибкуЗамены(Результат, Дубль, ОписаниеОшибкиЗамены("НеизвестныеДанные", Ошибка.Объект,
					ПредставлениеОбъектаОшибки, Ошибка.Текст));
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;

	ПараметрыВыполнения.Вставить("ПарыЗамен", ПарыЗамен);
	ПараметрыВыполнения.Вставить("УспешныеЗамены", Новый Соответствие);

//	Если ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
//		МодульУправлениеДоступом = ОбщийМодуль("УправлениеДоступом");
//		МодульУправлениеДоступом.ОтключитьОбновлениеКлючейДоступа(Истина);
//	КонецЕсли;

	Попытка
		Если ЗаменаПарыВТранзакции Тогда
			Для Каждого Дубль Из Дубли Цикл
				ЗаменитьСсылкуОднойТранзакцией(Результат, Дубль, ПараметрыВыполнения, ТаблицаПоиска);
			КонецЦикла;
		Иначе
			ЗаменитьСсылкиКороткимиТранзакциями(Результат, ПараметрыВыполнения, Дубли, ТаблицаПоиска);
		КонецЕсли;

//		Если ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
//			МодульУправлениеДоступом = ОбщийМодуль("УправлениеДоступом");
//			МодульУправлениеДоступом.ОтключитьОбновлениеКлючейДоступа(Ложь);
//		КонецЕсли;

	Исключение
//		Если ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
//			МодульУправлениеДоступом = ОбщийМодуль("УправлениеДоступом");
//			МодульУправлениеДоступом.ОтключитьОбновлениеКлючейДоступа(Ложь);
//		КонецЕсли;
		ВызватьИсключение;
	КонецПопытки;

	Возврат Результат.Ошибки;
КонецФункции

// Получает все места использования ссылок.
// Если какая-либо ссылка нигде не используется, то строк для нее в результирующей таблице не будет.
// При вызове в неразделенном сеансе не выявляет ссылок в разделенных областях.
//
// Параметры:
//     НаборСсылок     - Массив - ссылки, для которых ищем места использования.
//     АдресРезультата - Строка - необязательный адрес во временном хранилище, куда будет помещен копия результата
//                                замены.
// 
// Возвращаемое значение:
//     ТаблицаЗначений - состоит из колонок:
//       * Ссылка - ЛюбаяСсылка - ссылка, которая анализируется.
//       * Данные - Произвольный - данные, содержащие анализируемую ссылку.
//       * Метаданные - ОбъектМетаданных - метаданные найденных данных.
//       * ПредставлениеДанных - Строка - представление данных, содержащих анализируемую ссылку.
//       * ТипСсылки - Тип - тип анализируемой ссылки.
//       * ВспомогательныеДанные - Булево - Истина, если данные используются анализируемой ссылкой как
//           вспомогательные данные (ведущее измерение или попали в исключение ПриДобавленииИсключенийПоискаСсылок).
//       * ЭтоСлужебныеДанные - Булево - данные попали в исключение ПриДобавленииИсключенийПоискаСсылок
//
Функция МестаИспользования(Знач НаборСсылок, Знач АдресРезультата = "") Экспорт

	МестаИспользования = Новый ТаблицаЗначений;

	УстановитьПривилегированныйРежим(Истина);
	МестаИспользования = НайтиПоСсылкам(НаборСсылок);
	УстановитьПривилегированныйРежим(Ложь);
	
	// МестаИспользования - ТаблицаЗначений - где:
	// * Ссылка - ЛюбаяСсылка - Ссылка, которая анализируется.
	// * Данные - Произвольный - Данные, содержащие анализируемую ссылку.
	// * Метаданные - ОбъектМетаданных - Метаданные найденных данных.

	МестаИспользования.Колонки.Добавить("ПредставлениеДанных", Новый ОписаниеТипов("Строка"));
	МестаИспользования.Колонки.Добавить("ТипСсылки");
	МестаИспользования.Колонки.Добавить("ИнформацияОМестеИспользования");
	МестаИспользования.Колонки.Добавить("ВспомогательныеДанные", Новый ОписаниеТипов("Булево"));
	МестаИспользования.Колонки.Добавить("ЭтоСлужебныеДанные", Новый ОписаниеТипов("Булево"));

	МестаИспользования.Индексы.Добавить("Ссылка");
	МестаИспользования.Индексы.Добавить("Данные");
	МестаИспользования.Индексы.Добавить("ВспомогательныеДанные");
	МестаИспользования.Индексы.Добавить("Ссылка, ВспомогательныеДанные");

	ТипКлючиЗаписей = ОписаниеТипаКлючиЗаписей();
	ТипВсеСсылки = AllRefsTypeDescription();

	МетаданныеПоследовательностей = Метаданные.Последовательности;
	МетаданныеКонстант = Метаданные.Константы;
	МетаданныеДокументов = Метаданные.Документы;

	ИсключенияПоискаСсылок = ИсключенияПоискаСсылок();

	КэшИзмеренийРегистров = Новый Соответствие;

	Для Каждого МестоИспользования Из МестаИспользования Цикл
		ТипДанных = ТипЗнч(МестоИспользования.Данные);

		ЭтоСлужебныеДанные = ЭтоСлужебныеДанные(МестоИспользования, ИсключенияПоискаСсылок);
		ЭтоВспомогательныеДанные = ЭтоСлужебныеДанные;

		Если МетаданныеДокументов.Содержит(МестоИспользования.Метаданные) Тогда
			Представление = Строка(МестоИспользования.Данные);

		ИначеЕсли МетаданныеКонстант.Содержит(МестоИспользования.Метаданные) Тогда
			Представление = МестоИспользования.Метаданные.Представление() + " (" + НСтр("ru = 'константа'") + ")";

		ИначеЕсли МетаданныеПоследовательностей.Содержит(МестоИспользования.Метаданные) Тогда
			Представление = МестоИспользования.Метаданные.Представление() + " (" + НСтр("ru = 'последовательность'")
				+ ")";

		ИначеЕсли ТипДанных = Неопределено Тогда
			Представление = Строка(МестоИспользования.Данные);

		ИначеЕсли ТипВсеСсылки.СодержитТип(ТипДанных) Тогда
			МетаПредставлениеОбъекта = Новый Структура("ПредставлениеОбъекта");
			ЗаполнитьЗначенияСвойств(МетаПредставлениеОбъекта, МестоИспользования.Метаданные);
			Если ПустаяСтрока(МетаПредставлениеОбъекта.ПредставлениеОбъекта) Тогда
				МетаПредставление = МестоИспользования.Метаданные.Представление();
			Иначе
				МетаПредставление = МетаПредставлениеОбъекта.ПредставлениеОбъекта;
			КонецЕсли;
			Представление = Строка(МестоИспользования.Данные);
			Если Не ПустаяСтрока(МетаПредставление) Тогда
				Представление = Представление + " (" + МетаПредставление + ")";
			КонецЕсли;

		ИначеЕсли ТипКлючиЗаписей.СодержитТип(ТипДанных) Тогда
			Представление = МестоИспользования.Метаданные.ПредставлениеЗаписи;
			Если ПустаяСтрока(Представление) Тогда
				Представление = МестоИспользования.Метаданные.Представление();
			КонецЕсли;

			ОписаниеИзмерений = "";
			Для Каждого КлючЗначение Из ОписаниеИзмеренийНабора(МестоИспользования.Метаданные, КэшИзмеренийРегистров) Цикл
				Значение = МестоИспользования.Данные[КлючЗначение.Ключ];
				Описание = КлючЗначение.Значение;
				Если МестоИспользования.Ссылка = Значение Тогда
					Если Описание.Ведущее Тогда
						ЭтоВспомогательныеДанные = Истина;
					КонецЕсли;
				КонецЕсли;
				ФорматЗначения = Описание.Формат;
				ОписаниеИзмерений = ОписаниеИзмерений + ", " + Описание.Представление + " """ + ?(ФорматЗначения
					= Неопределено, Строка(Значение), Формат(Значение, ФорматЗначения)) + """";
			КонецЦикла;

			ОписаниеИзмерений = Сред(ОписаниеИзмерений, 3);
			Если Не ПустаяСтрока(ОписаниеИзмерений) Тогда
				Представление = Представление + " (" + ОписаниеИзмерений + ")";
			КонецЕсли;

		Иначе
			Представление = Строка(МестоИспользования.Данные);

		КонецЕсли;

		МестоИспользования.ПредставлениеДанных = Представление;
		МестоИспользования.ВспомогательныеДанные = ЭтоВспомогательныеДанные;
		МестоИспользования.ЭтоСлужебныеДанные = ЭтоСлужебныеДанные;
		МестоИспользования.ТипСсылки = ТипЗнч(МестоИспользования.Ссылка);
	КонецЦикла;

	Если Не ПустаяСтрока(АдресРезультата) Тогда
		ПоместитьВоВременноеХранилище(МестаИспользования, АдресРезультата);
	КонецЕсли;

	Возврат МестаИспользования;
КонецФункции

#КонецОбласти
#Область ВнешниеКомпоненты

// Проверка существования макета по метаданным конфигурации и расширений.
//
// Параметры:
//  ПолноеИмяМакета - Строка - полное имя макета.
//
// Возвращаемое значение:
//  Булево - признак существования макета.
//
Функция МакетСуществует(ПолноеИмяМакета)

	Макет = Метаданные.НайтиПоПолномуИмени(ПолноеИмяМакета);
	Если ТипЗнч(Макет) = Тип("ОбъектМетаданных") Тогда

		Шаблон = Новый Структура("ТипМакета");
		ЗаполнитьЗначенияСвойств(Шаблон, Макет);
		ТипМакета = Неопределено;
		Если Шаблон.Свойство("ТипМакета", ТипМакета) Тогда
			Возврат ТипМакета <> Неопределено;
		КонецЕсли;

	КонецЕсли;

	Возврат Ложь;

КонецФункции

#КонецОбласти

#Область МестаИспользования

Функция ОписаниеТипаКлючиЗаписей()

	ДобавляемыеТипы = Новый Массив;
	Для Каждого Мета Из Метаданные.РегистрыСведений Цикл
		ДобавляемыеТипы.Добавить(Тип("РегистрСведенийКлючЗаписи." + Мета.Имя));
	КонецЦикла;
	Для Каждого Мета Из Метаданные.РегистрыНакопления Цикл
		ДобавляемыеТипы.Добавить(Тип("РегистрНакопленияКлючЗаписи." + Мета.Имя));
	КонецЦикла;
	Для Каждого Мета Из Метаданные.РегистрыБухгалтерии Цикл
		ДобавляемыеТипы.Добавить(Тип("РегистрБухгалтерииКлючЗаписи." + Мета.Имя));
	КонецЦикла;
	Для Каждого Мета Из Метаданные.РегистрыРасчета Цикл
		ДобавляемыеТипы.Добавить(Тип("РегистрРасчетаКлючЗаписи." + Мета.Имя));
	КонецЦикла;

	Возврат Новый ОписаниеТипов(ДобавляемыеТипы);
КонецФункции

Функция ОписаниеИзмеренийНабора(Знач МетаданныеРегистра, КэшИзмеренийРегистров)

	ОписаниеИзмерений = КэшИзмеренийРегистров[МетаданныеРегистра];
	Если ОписаниеИзмерений <> Неопределено Тогда
		Возврат ОписаниеИзмерений;
	КонецЕсли;
	
	// Период и регистратор, если есть.
	ОписаниеИзмерений = Новый Структура;

	ДанныеИзмерения = Новый Структура("Ведущее, Представление, Формат, Тип", Ложь);

	Если Метаданные.РегистрыСведений.Содержит(МетаданныеРегистра) Тогда
		// Возможно есть период
		МетаПериод = МетаданныеРегистра.ПериодичностьРегистраСведений;
		Периодичность = Метаданные.СвойстваОбъектов.ПериодичностьРегистраСведений;

		Если МетаПериод = Периодичность.ПозицияРегистратора Тогда
			ДанныеИзмерения.Тип           = Документы.ТипВсеСсылки();
			ДанныеИзмерения.Представление = НСтр("ru='Регистратор'");
			ДанныеИзмерения.Ведущее       = Истина;
			ОписаниеИзмерений.Вставить("Регистратор", ДанныеИзмерения);

		ИначеЕсли МетаПериод = Периодичность.Год Тогда
			ДанныеИзмерения.Тип           = Новый ОписаниеТипов("Дата");
			ДанныеИзмерения.Представление = НСтр("ru='Период'");
			ДанныеИзмерения.Формат        = НСтр("ru = 'ДФ=''yyyy ""г.""''; ДП=''Дата не задана'''");
			ОписаниеИзмерений.Вставить("Период", ДанныеИзмерения);

		ИначеЕсли МетаПериод = Периодичность.День Тогда
			ДанныеИзмерения.Тип           = Новый ОписаниеТипов("Дата");
			ДанныеИзмерения.Представление = НСтр("ru='Период'");
			ДанныеИзмерения.Формат        = НСтр("ru = 'ДЛФ=D; ДП=''Дата не задана'''");
			ОписаниеИзмерений.Вставить("Период", ДанныеИзмерения);

		ИначеЕсли МетаПериод = Периодичность.Квартал Тогда
			ДанныеИзмерения.Тип           = Новый ОписаниеТипов("Дата");
			ДанныеИзмерения.Представление = НСтр("ru='Период'");
			ДанныеИзмерения.Формат        =  НСтр(
				"ru = 'ДФ=''к """"квартал """"yyyy """"г.""""''; ДП=''Дата не задана'''");
			ОписаниеИзмерений.Вставить("Период", ДанныеИзмерения);

		ИначеЕсли МетаПериод = Периодичность.Месяц Тогда
			ДанныеИзмерения.Тип           = Новый ОписаниеТипов("Дата");
			ДанныеИзмерения.Представление = НСтр("ru='Период'");
			ДанныеИзмерения.Формат        = НСтр("ru = 'ДФ=''ММММ yyyy """"г.""""''; ДП=''Дата не задана'''");
			ОписаниеИзмерений.Вставить("Период", ДанныеИзмерения);

		ИначеЕсли МетаПериод = Периодичность.Секунда Тогда
			ДанныеИзмерения.Тип           = Новый ОписаниеТипов("Дата");
			ДанныеИзмерения.Представление = НСтр("ru='Период'");
			ДанныеИзмерения.Формат        = НСтр("ru = 'ДЛФ=DT; ДП=''Дата не задана'''");
			ОписаниеИзмерений.Вставить("Период", ДанныеИзмерения);

		КонецЕсли;

	Иначе
		ДанныеИзмерения.Тип           = Документы.ТипВсеСсылки();
		ДанныеИзмерения.Представление = НСтр("ru='Регистратор'");
		ДанныеИзмерения.Ведущее       = Истина;
		ОписаниеИзмерений.Вставить("Регистратор", ДанныеИзмерения);

	КонецЕсли;
	
	// Все измерения
	Для Каждого МетаИзмерение Из МетаданныеРегистра.Измерения Цикл
		ДанныеИзмерения = Новый Структура("Ведущее, Представление, Формат, Тип");
		ДанныеИзмерения.Тип           = МетаИзмерение.Тип;
		ДанныеИзмерения.Представление = МетаИзмерение.Представление();
		ДанныеИзмерения.Ведущее       = МетаИзмерение.Ведущее;
		ОписаниеИзмерений.Вставить(МетаИзмерение.Имя, ДанныеИзмерения);
	КонецЦикла;

	КэшИзмеренийРегистров[МетаданныеРегистра] = ОписаниеИзмерений;
	Возврат ОписаниеИзмерений;

КонецФункции

#КонецОбласти

#Область ЗаменитьСсылки

Функция РазметитьМестаИспользования(Знач ПараметрыВыполнения, Знач Ссылка, Знач ЦелеваяСсылка, Знач ТаблицаПоиска)
	УстановитьПривилегированныйРежим(Истина);
	
	// Устанавливаем порядок известных и проверяем наличие неопознанных объектов.
	Результат = Новый Структура;
	Результат.Вставить("МестаИспользования", ТаблицаПоиска.НайтиСтроки(Новый Структура("Ссылка", Ссылка)));
	Результат.Вставить("ОшибкиРазметки", Новый Массив);
	Результат.Вставить("Успех", Истина);

	Для Каждого МестоИспользования Из Результат.МестаИспользования Цикл
		Если МестоИспользования.ЭтоСлужебныеДанные Тогда
			Продолжить; // Зависимые данные не обрабатываются.
		КонецЕсли;

		Информация = ИнформацияОТипе(МестоИспользования.Метаданные, ПараметрыВыполнения);
		Если Информация.Вид = "КОНСТАНТА" Тогда
			МестоИспользования.КлючЗамены = "Константа";
			МестоИспользования.ЦелеваяСсылка = ЦелеваяСсылка;

		ИначеЕсли Информация.Вид = "ПОСЛЕДОВАТЕЛЬНОСТЬ" Тогда
			МестоИспользования.КлючЗамены = "Последовательность";
			МестоИспользования.ЦелеваяСсылка = ЦелеваяСсылка;

		ИначеЕсли Информация.Вид = "РЕГИСТРСВЕДЕНИЙ" Тогда
			МестоИспользования.КлючЗамены = "РегистрСведений";
			МестоИспользования.ЦелеваяСсылка = ЦелеваяСсылка;

		ИначеЕсли Информация.Вид = "РЕГИСТРБУХГАЛТЕРИИ" Или Информация.Вид = "РЕГИСТРНАКОПЛЕНИЯ" Или Информация.Вид
			= "РЕГИСТРРАСЧЕТА" Тогда
			МестоИспользования.КлючЗамены = "КлючЗаписи";
			МестоИспользования.ЦелеваяСсылка = ЦелеваяСсылка;

		ИначеЕсли Информация.Ссылочный Тогда
			МестоИспользования.КлючЗамены = "Объект";
			МестоИспользования.ЦелеваяСсылка = ЦелеваяСсылка;

		Иначе
			// Неизвестный объект для замены ссылок.
			Результат.Успех = Ложь;
			Текст = СтрШаблон(НСтр("ru = 'Замена ссылок в ""%1"" не поддерживается.'"), Информация.ПолноеИмя);
			ОписаниеОшибки = Новый Структура("Объект, Текст", МестоИспользования.Данные, Текст);
			Результат.ОшибкиРазметки.Добавить(ОписаниеОшибки);
		КонецЕсли;

	КонецЦикла;

	Возврат Результат;
КонецФункции

Процедура ЗаменитьСсылкиКороткимиТранзакциями(Результат, Знач ПараметрыВыполнения, Знач Дубли, Знач ТаблицаПоиска)
	
	// Основной цикл обработки
	ФильтрСсылок = Новый Структура("Ссылка, КлючЗамены");
	Для Каждого Дубль Из Дубли Цикл
		БылиОшибки = Результат.ЕстьОшибки;
		Результат.ЕстьОшибки = Ложь;

		ФильтрСсылок.Ссылка = Дубль;

		ФильтрСсылок.КлючЗамены = "Константа";
		МестаИспользования = ТаблицаПоиска.НайтиСтроки(ФильтрСсылок);
		Для Каждого МестоИспользования Из МестаИспользования Цикл
			ПроизвестиЗаменуВКонстанте(Результат, МестоИспользования, ПараметрыВыполнения, Истина);
		КонецЦикла;

		ФильтрСсылок.КлючЗамены = "Объект";
		МестаИспользования = ТаблицаПоиска.НайтиСтроки(ФильтрСсылок);
		Для Каждого МестоИспользования Из МестаИспользования Цикл
			ПроизвестиЗаменуВОбъекте(Результат, МестоИспользования, ПараметрыВыполнения, Истина);
		КонецЦикла;

		ФильтрСсылок.КлючЗамены = "КлючЗаписи";
		МестаИспользования = ТаблицаПоиска.НайтиСтроки(ФильтрСсылок);
		Для Каждого МестоИспользования Из МестаИспользования Цикл
			ПроизвестиЗаменуВНаборе(Результат, МестоИспользования, ПараметрыВыполнения, Истина);
		КонецЦикла;

		ФильтрСсылок.КлючЗамены = "Последовательность";
		МестаИспользования = ТаблицаПоиска.НайтиСтроки(ФильтрСсылок);
		Для Каждого МестоИспользования Из МестаИспользования Цикл
			ПроизвестиЗаменуВНаборе(Результат, МестоИспользования, ПараметрыВыполнения, Истина);
		КонецЦикла;

		ФильтрСсылок.КлючЗамены = "РегистрСведений";
		МестаИспользования = ТаблицаПоиска.НайтиСтроки(ФильтрСсылок);
		Для Каждого МестоИспользования Из МестаИспользования Цикл
			ПроизвестиЗаменуВРегистреСведений(Результат, МестоИспользования, ПараметрыВыполнения, Истина);
		КонецЦикла;

		Если Не Результат.ЕстьОшибки Тогда
			ПараметрыВыполнения.УспешныеЗамены.Вставить(Дубль, ПараметрыВыполнения.ПарыЗамен[Дубль]);
		КонецЕсли;
		Результат.ЕстьОшибки = Результат.ЕстьОшибки Или БылиОшибки;

	КонецЦикла;
	
	// Окончательные действия
	Если ПараметрыВыполнения.УдалятьНепосредственно Тогда
		УдалитьСсылкиНемонопольно(Результат, Дубли, ПараметрыВыполнения, Истина);

	ИначеЕсли ПараметрыВыполнения.ПомечатьНаУдаление Тогда
		УдалитьСсылкиНемонопольно(Результат, Дубли, ПараметрыВыполнения, Ложь);

	Иначе
		// Поиск новых
		ТаблицаПовторногоПоиска = МестаИспользования(Дубли);
		ДобавитьРезультатыЗаменыИзмененныхОбъектов(Результат, ТаблицаПовторногоПоиска);
	КонецЕсли;

КонецПроцедуры

Процедура ЗаменитьСсылкуОднойТранзакцией(Результат, Знач Дубль, Знач ПараметрыВыполнения, Знач ТаблицаПоиска)
	УстановитьПривилегированныйРежим(Истина);

	НачатьТранзакцию();
	Попытка
		// 1. Блокирование всех мест использования.
		СостояниеОперации = "ОшибкаБлокировки";
		Блокировка = Новый БлокировкаДанных;

		МестаИспользования = ТаблицаПоиска.НайтиСтроки(Новый Структура("Ссылка", Дубль));
		ЗаблокироватьМестаИспользования(ПараметрыВыполнения, Блокировка, МестаИспользования);
		Блокировка.Заблокировать();
		СостояниеОперации = "";

		УстановитьПривилегированныйРежим(Ложь);
		
		// 2. Замена везде до первой ошибки.
		Результат.ЕстьОшибки = Ложь;

		Для Каждого МестоИспользования Из МестаИспользования Цикл

			Если МестоИспользования.КлючЗамены = "Константа" Тогда
				ПроизвестиЗаменуВКонстанте(Результат, МестоИспользования, ПараметрыВыполнения, Ложь);
			ИначеЕсли МестоИспользования.КлючЗамены = "Объект" Тогда
				ПроизвестиЗаменуВОбъекте(Результат, МестоИспользования, ПараметрыВыполнения, Ложь);
			ИначеЕсли МестоИспользования.КлючЗамены = "Последовательность" Тогда
				ПроизвестиЗаменуВНаборе(Результат, МестоИспользования, ПараметрыВыполнения, Ложь);
			ИначеЕсли МестоИспользования.КлючЗамены = "КлючЗаписи" Тогда
				ПроизвестиЗаменуВНаборе(Результат, МестоИспользования, ПараметрыВыполнения, Ложь);
			ИначеЕсли МестоИспользования.КлючЗамены = "РегистрСведений" Тогда
				ПроизвестиЗаменуВРегистреСведений(Результат, МестоИспользования, ПараметрыВыполнения, Ложь);
			КонецЕсли;

			Если Результат.ЕстьОшибки Тогда
				ОтменитьТранзакцию();
				Возврат;
			КонецЕсли;

		КонецЦикла;
		
		// 3. Удаление 
		ПроизводимыеЗамены = Новый Массив;
		ПроизводимыеЗамены.Добавить(Дубль);

		Если ПараметрыВыполнения.УдалятьНепосредственно Тогда
			УдалитьСсылкиНемонопольно(Результат, ПроизводимыеЗамены, ПараметрыВыполнения, Истина);

		ИначеЕсли ПараметрыВыполнения.ПомечатьНаУдаление Тогда
			УдалитьСсылкиНемонопольно(Результат, ПроизводимыеЗамены, ПараметрыВыполнения, Ложь);

		Иначе
			// Поиск новых
			ТаблицаПовторногоПоиска = МестаИспользования(ПроизводимыеЗамены);
			ДобавитьРезультатыЗаменыИзмененныхОбъектов(Результат, ТаблицаПовторногоПоиска);
		КонецЕсли;

		Если Результат.ЕстьОшибки Тогда
			ОтменитьТранзакцию();
			Возврат;
		КонецЕсли;

		ПараметрыВыполнения.УспешныеЗамены.Вставить(Дубль, ПараметрыВыполнения.ПарыЗамен[Дубль]);
		ЗафиксироватьТранзакцию();

	Исключение
		ОтменитьТранзакцию();
		Если СостояниеОперации = "ОшибкаБлокировки" Тогда
			ПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			Ошибка = СтрШаблон(НСтр("ru = 'Не удалось заблокировать все места использования %1:'") + Символы.ПС
				+ ПредставлениеОшибки, Дубль);
			ЗарегистрироватьОшибкуЗамены(Результат, Дубль, ОписаниеОшибкиЗамены("ОшибкаБлокировки", Неопределено,
				Неопределено, Ошибка));
		Иначе
			ВызватьИсключение;
		КонецЕсли;
	КонецПопытки;

КонецПроцедуры

Процедура ПроизвестиЗаменуВКонстанте(Результат, Знач МестоИспользования, Знач ПараметрыЗаписи,
	Знач ВнутренняяТранзакция = Истина)

	УстановитьПривилегированныйРежим(Истина);

	Данные = МестоИспользования.Данные;
	Мета   = МестоИспользования.Метаданные;

	ПредставлениеДанных = Строка(Данные);
	
	// Будем производить сразу все замены для этих данных.
	Фильтр = Новый Структура("Данные, КлючЗамены", Данные, "Константа");
	ОбрабатываемыеСтроки = МестоИспользования.Владелец().НайтиСтроки(Фильтр);
	// Помечаем как обработанные
	Для Каждого Строка Из ОбрабатываемыеСтроки Цикл
		Строка.КлючЗамены = "";
	КонецЦикла;

	СостояниеОперации = "";
	Ошибка = "";
	Если ВнутренняяТранзакция Тогда
		НачатьТранзакцию();
	КонецЕсли;

	Попытка
		Если ВнутренняяТранзакция Тогда
			Блокировка = Новый БлокировкаДанных;
			Блокировка.Добавить(Мета.ПолноеИмя());
			Попытка
				Блокировка.Заблокировать();
			Исключение
				Ошибка = СтрШаблон(НСтр("ru = 'Не удалось заблокировать константу %1'"), ПредставлениеДанных);
				СостояниеОперации = "ОшибкаБлокировки";
				ВызватьИсключение;
			КонецПопытки;
		КонецЕсли;

		Менеджер = Константы[Мета.Имя].СоздатьМенеджерЗначения();
		Менеджер.Прочитать();

		ЗаменаПроизведена = Ложь;
		Для Каждого Строка Из ОбрабатываемыеСтроки Цикл
			Если Менеджер.Значение = Строка.Ссылка Тогда
				Менеджер.Значение = Строка.ЦелеваяСсылка;
				ЗаменаПроизведена = Истина;
			КонецЕсли;
		КонецЦикла;

		Если Не ЗаменаПроизведена Тогда
			Если ВнутренняяТранзакция Тогда
				ОтменитьТранзакцию();
			КонецЕсли;
			Возврат;
		КонецЕсли;	
		 
		// Пытаемся сохранить
		Если Не ПараметрыЗаписи.ПараметрыЗаписи.ПривелигированныйРежим Тогда
			УстановитьПривилегированныйРежим(Ложь);
		КонецЕсли;

		Попытка
			ЗаписатьОбъектПриЗаменеСсылок(Менеджер, ПараметрыЗаписи);
		Исключение
			ОписаниеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			Ошибка = СтрШаблон(НСтр("ru = 'Не удалось записать %1 по причине: %2'"), ПредставлениеДанных,
				ОписаниеОшибки);
			СостояниеОперации = "ОшибкаЗаписи";
			ВызватьИсключение;
		КонецПопытки;

		Если Не ПараметрыЗаписи.ПараметрыЗаписи.ПривелигированныйРежим Тогда
			УстановитьПривилегированныйРежим(Истина);
		КонецЕсли;

		Если ВнутренняяТранзакция Тогда
			ЗафиксироватьТранзакцию();
		КонецЕсли;
	Исключение
		Если ВнутренняяТранзакция Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрацииЗаменыСсылок(), УровеньЖурналаРегистрации.Ошибка, Мета, ,
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Если СостояниеОперации = "ОшибкаЗаписи" Тогда
			Для Каждого Строка Из ОбрабатываемыеСтроки Цикл
				ЗарегистрироватьОшибкуЗамены(Результат, Строка.Ссылка, ОписаниеОшибкиЗамены("ОшибкаЗаписи", Данные,
					ПредставлениеДанных, Ошибка));
			КонецЦикла;
		Иначе
			ЗарегистрироватьОшибкуЗамены(Результат, Строка.Ссылка, ОписаниеОшибкиЗамены(СостояниеОперации, Данные,
				ПредставлениеДанных, Ошибка));
		КонецЕсли;
	КонецПопытки;

КонецПроцедуры

Процедура ПроизвестиЗаменуВОбъекте(Результат, Знач МестоИспользования, Знач ПараметрыВыполнения,
	Знач ВнутренняяТранзакция = Истина)

	УстановитьПривилегированныйРежим(Истина);

	Данные = МестоИспользования.Данные;
	
	// Будем производить сразу все замены для этих данных.
	Фильтр = Новый Структура("Данные, КлючЗамены", Данные, "Объект");
	ОбрабатываемыеСтроки = МестоИспользования.Владелец().НайтиСтроки(Фильтр);

	ПредставлениеДанных = ПредметСтрокой(Данные);
	СостояниеОперации = "";
	ТекстОшибки = "";
	Если ВнутренняяТранзакция Тогда
		НачатьТранзакцию();
	КонецЕсли;

	Попытка

		Если ВнутренняяТранзакция Тогда
			Блокировка = Новый БлокировкаДанных;
			ЗаблокироватьМестоИспользования(ПараметрыВыполнения, Блокировка, МестоИспользования);
			Попытка
				Блокировка.Заблокировать();
			Исключение
				СостояниеОперации = "ОшибкаБлокировки";
				ТекстОшибки = СтрШаблон(
					НСтр("ru = 'Не удалось заблокировать объект ""%1"":
						 |%2'"), ПредставлениеДанных, КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
				ВызватьИсключение;
			КонецПопытки;
		КонецЕсли;

		ОбъектыЗаписи = ИзмененныеОбъектыПриЗаменеВОбъекте(ПараметрыВыполнения, МестоИспользования,
			ОбрабатываемыеСтроки);
		
		// Пытаемся сохранить, сам объект идет последним.
		Если Не ПараметрыВыполнения.ПараметрыЗаписи.ПривелигированныйРежим Тогда
			УстановитьПривилегированныйРежим(Ложь);
		КонецЕсли;

		Попытка
			Если ПараметрыВыполнения.ПараметрыЗаписи.ЗаписьВРежимеЗагрузки Тогда
				// Первая запись без контроля, чтобы устранить циклические ссылки.
				НовыеПараметрыВыполнения = UT_CommonClientServer.CopyRecursively(ПараметрыВыполнения);
				НовыеПараметрыВыполнения.ПараметрыЗаписи.ЗаписьВРежимеЗагрузки  = Ложь;
				Для Каждого КлючЗначение Из ОбъектыЗаписи Цикл
					ЗаписатьОбъектПриЗаменеСсылок(КлючЗначение.Ключ, НовыеПараметрыВыполнения);
				КонецЦикла;
				// Вторая запись c контролем.
				НовыеПараметрыВыполнения.ПараметрыЗаписи.ЗаписьВРежимеЗагрузки  = Истина;
				Для Каждого КлючЗначение Из ОбъектыЗаписи Цикл
					ЗаписатьОбъектПриЗаменеСсылок(КлючЗначение.Ключ, НовыеПараметрыВыполнения);
				КонецЦикла;
			Иначе
				// Запись без контроля бизнес-логики.
				Для Каждого КлючЗначение Из ОбъектыЗаписи Цикл
					ЗаписатьОбъектПриЗаменеСсылок(КлючЗначение.Ключ, ПараметрыВыполнения);
				КонецЦикла;
			КонецЕсли;
		Исключение
			СостояниеОперации = "ОшибкаЗаписи";
			ОписаниеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			ТекстОшибки = СтрШаблон(НСтр("ru = 'Не удалось записать %1 по причине: %2'"), ПредставлениеДанных,
				ОписаниеОшибки);
			ВызватьИсключение;
		КонецПопытки;

		Если ВнутренняяТранзакция Тогда
			ЗафиксироватьТранзакцию();
		КонецЕсли;

	Исключение
		Если ВнутренняяТранзакция Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		Информация = ИнформацияОбОшибке();
		ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрацииЗаменыСсылок(), УровеньЖурналаРегистрации.Ошибка,
			МестоИспользования.Метаданные, , ПодробноеПредставлениеОшибки(Информация));
		Ошибка = ОписаниеОшибкиЗамены(СостояниеОперации, Данные, ПредставлениеДанных, ТекстОшибки);
		Если СостояниеОперации = "ОшибкаЗаписи" Тогда
			Для Каждого Строка Из ОбрабатываемыеСтроки Цикл
				ЗарегистрироватьОшибкуЗамены(Результат, Строка.Ссылка, Ошибка);
			КонецЦикла;
		Иначе
			ЗарегистрироватьОшибкуЗамены(Результат, МестоИспользования.Ссылка, Ошибка);
		КонецЕсли;
	КонецПопытки;
	
	// Помечаем как обработанные
	Для Каждого Строка Из ОбрабатываемыеСтроки Цикл
		Строка.КлючЗамены = "";
	КонецЦикла;

КонецПроцедуры

Процедура ПроизвестиЗаменуВНаборе(Результат, Знач МестоИспользования, Знач ПараметрыВыполнения,
	Знач ВнутренняяТранзакция = Истина)
	УстановитьПривилегированныйРежим(Истина);

	Данные = МестоИспользования.Данные;
	Мета   = МестоИспользования.Метаданные;

	ПредставлениеДанных = Строка(Данные);
	
	// Будем производить сразу все замены для этих данных.
	Фильтр = Новый Структура("Данные, КлючЗамены");
	ЗаполнитьЗначенияСвойств(Фильтр, МестоИспользования);
	ОбрабатываемыеСтроки = МестоИспользования.Владелец().НайтиСтроки(Фильтр);

	ОписаниеНабора = ОписаниеКлючаЗаписи(Мета);
	НаборЗаписей = ОписаниеНабора.НаборЗаписей;

	ПарыЗамен = Новый Соответствие;
	Для Каждого Строка Из ОбрабатываемыеСтроки Цикл
		ПарыЗамен.Вставить(Строка.Ссылка, Строка.ЦелеваяСсылка);
	КонецЦикла;
	
	// Помечаем как обработанные
	Для Каждого Строка Из ОбрабатываемыеСтроки Цикл
		Строка.КлючЗамены = "";
	КонецЦикла;

	СостояниеОперации = "";
	Ошибка = "";
	Если ВнутренняяТранзакция Тогда
		НачатьТранзакцию();
	КонецЕсли;

	Попытка

		Если ВнутренняяТранзакция Тогда
			// Блокировка и подготовка набора.
			Блокировка = Новый БлокировкаДанных;
			Для Каждого КлючЗначение Из ОписаниеНабора.СписокИзмерений Цикл
				ТипИзмерения = КлючЗначение.Значение;
				Имя          = КлючЗначение.Ключ;
				Значение     = Данные[Имя];

				Для Каждого Строка Из ОбрабатываемыеСтроки Цикл
					ТекущаяСсылка = Строка.Ссылка;
					Если ТипИзмерения.СодержитТип(ТипЗнч(ТекущаяСсылка)) Тогда
						Блокировка.Добавить(ОписаниеНабора.ПространствоБлокировки).УстановитьЗначение(Имя,
							ТекущаяСсылка);
					КонецЕсли;
				КонецЦикла;

				НаборЗаписей.Отбор[Имя].Установить(Значение);
			КонецЦикла;

			Попытка
				Блокировка.Заблокировать();
			Исключение
				Ошибка = СтрШаблон(НСтр("ru = 'Не удалось заблокировать набор %1'"), ПредставлениеДанных);
				СостояниеОперации = "ОшибкаБлокировки";
				ВызватьИсключение;
			КонецПопытки;

		КонецЕсли;

		НаборЗаписей.Прочитать();
		ЗаменитьВКоллекцииСтрок("НаборЗаписей", "НаборЗаписей", НаборЗаписей, НаборЗаписей, ОписаниеНабора.СписокПолей,
			ПарыЗамен);

		Если НаборЗаписей.Модифицированность() Тогда
			Если ВнутренняяТранзакция Тогда
				ОтменитьТранзакцию();
			КонецЕсли;
			Возврат;
		КонецЕсли;

		Если Не ПараметрыВыполнения.ПараметрыЗаписи.ПривелигированныйРежим Тогда
			УстановитьПривилегированныйРежим(Ложь);
		КонецЕсли;

		Попытка
			ЗаписатьОбъектПриЗаменеСсылок(НаборЗаписей, ПараметрыВыполнения);
		Исключение
			ОписаниеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			Ошибка = СтрШаблон(НСтр("ru = 'Не удалось записать %1 по причине: %2'"), ПредставлениеДанных,
				ОписаниеОшибки);
			СостояниеОперации = "ОшибкаЗаписи";
			ВызватьИсключение;
		КонецПопытки;

		Если Не ПараметрыВыполнения.ПараметрыЗаписи.ПривелигированныйРежим Тогда
			УстановитьПривилегированныйРежим(Истина);
		КонецЕсли;

		Если ВнутренняяТранзакция Тогда
			ЗафиксироватьТранзакцию();
		КонецЕсли;

	Исключение
		Если ВнутренняяТранзакция Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		Информация = ИнформацияОбОшибке();
		ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрацииЗаменыСсылок(), УровеньЖурналаРегистрации.Ошибка, Мета, ,
			ПодробноеПредставлениеОшибки(Информация));
		Ошибка = ОписаниеОшибкиЗамены(СостояниеОперации, Данные, ПредставлениеДанных, Ошибка);
		Если СостояниеОперации = "ОшибкаЗаписи" Тогда
			Для Каждого Строка Из ОбрабатываемыеСтроки Цикл
				ЗарегистрироватьОшибкуЗамены(Результат, Строка.Ссылка, Ошибка);
			КонецЦикла;
		Иначе
			ЗарегистрироватьОшибкуЗамены(Результат, МестоИспользования.Ссылка, Ошибка);
		КонецЕсли;
	КонецПопытки;

КонецПроцедуры

Процедура ПроизвестиЗаменуВРегистреСведений(Результат, Знач МестоИспользования, Знач ПараметрыВыполнения,
	Знач ВнутренняяТранзакция = Истина)

	Если МестоИспользования.Обработано Тогда
		Возврат;
	КонецЕсли;
	МестоИспользования.Обработано = Истина;
	
	// В случае, если дубль указан в измерениях набора, тогда используется 2 набора записей:
	//     НаборЗаписейДубля - чтение старых значений (по старым измерениям) и удаление старых значений.
	//     НаборЗаписейОригинала - чтение актуальных значений (по новым измерениям) и запись новых значений.
	//     Данные дублей и оригиналов объединяются по правилам:
	//         Приоритет у данных оригинала.
	//         Если в оригинале нет данных, то берутся данные из дубля.
	//     Набор оригинала записывается, а набор дубля удаляется.
	//
	// В случае, если дубль не указан в измерениях набора, тогда используется 1 набор записей:
	//     НаборЗаписейДубля - чтение старых значений и запись новых значений.
	//
	// Замена ссылок в ресурсах и реквизитах производится в обоих случаях.

	УстановитьПривилегированныйРежим(Истина);

	Дубль    = МестоИспользования.Ссылка;
	Оригинал = МестоИспользования.ЦелеваяСсылка;

	МетаданныеРегистра = МестоИспользования.Метаданные;
	КлючЗаписиРегистра = МестоИспользования.Данные;

	Информация = ИнформацияОТипе(МетаданныеРегистра, ПараметрыВыполнения);

	ТребуетсяДваНабора = Ложь;
	Для Каждого КлючЗначение Из Информация.Измерения Цикл
		ЗначениеИзмеренияДубля = КлючЗаписиРегистра[КлючЗначение.Ключ];
		Если ЗначениеИзмеренияДубля = Дубль Или ПараметрыВыполнения.УспешныеЗамены[ЗначениеИзмеренияДубля] = Дубль Тогда
			ТребуетсяДваНабора = Истина; // Дубль указан в измерениях.
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Менеджер = МенеджерОбъектаПоПолномуИмени(Информация.ПолноеИмя);
	//@skip-warning
	НаборЗаписейДубля = Менеджер.СоздатьНаборЗаписей();

	Если ТребуетсяДваНабора Тогда
		ЗначенияИзмеренийОригинала = Новый Структура;
		//@skip-warning
		НаборЗаписейОригинала = Менеджер.СоздатьНаборЗаписей();
	КонецЕсли;

	Если ВнутренняяТранзакция Тогда
		НачатьТранзакцию();
	КонецЕсли;

	Попытка
		Если ВнутренняяТранзакция Тогда
			Блокировка = Новый БлокировкаДанных;
			БлокировкаДубля = Блокировка.Добавить(Информация.ПолноеИмя);
			Если ТребуетсяДваНабора Тогда
				БлокировкаОригинала = Блокировка.Добавить(Информация.ПолноеИмя);
			КонецЕсли;
		КонецЕсли;

		Для Каждого КлючЗначение Из Информация.Измерения Цикл
			ЗначениеИзмеренияДубля = КлючЗаписиРегистра[КлючЗначение.Ключ];
			
			// Для решения проблемы уникальности
			//   выполняется замена старых значений измерений ключа записи на актуальные.
			//   Соответствие старых и актуальных обеспечивает соответствием УспешныеЗамены.
			//   Данные соответствия актуальны на текущий момент времени,
			//   т.к. пополняются только после успешной обработки очередной пары и фиксации транзакции.
			НовоеЗначениеИзмеренияДубля = ПараметрыВыполнения.УспешныеЗамены[ЗначениеИзмеренияДубля];
			Если НовоеЗначениеИзмеренияДубля <> Неопределено Тогда
				ЗначениеИзмеренияДубля = НовоеЗначениеИзмеренияДубля;
			КонецЕсли;

			НаборЗаписейДубля.Отбор[КлючЗначение.Ключ].Установить(ЗначениеИзмеренияДубля);

			Если ВнутренняяТранзакция Тогда // Замена в конкретной паре и блокировка на конкретную замену.
				БлокировкаДубля.УстановитьЗначение(КлючЗначение.Ключ, ЗначениеИзмеренияДубля);
			КонецЕсли;

			Если ТребуетсяДваНабора Тогда
				Если ЗначениеИзмеренияДубля = Дубль Тогда
					ЗначениеИзмеренияОригинала = Оригинал;
				Иначе
					ЗначениеИзмеренияОригинала = ЗначениеИзмеренияДубля;
				КонецЕсли;

				НаборЗаписейОригинала.Отбор[КлючЗначение.Ключ].Установить(ЗначениеИзмеренияОригинала);
				ЗначенияИзмеренийОригинала.Вставить(КлючЗначение.Ключ, ЗначениеИзмеренияОригинала);

				Если ВнутренняяТранзакция Тогда // Замена в конкретной паре и блокировка на конкретную замену.
					БлокировкаОригинала.УстановитьЗначение(КлючЗначение.Ключ, ЗначениеИзмеренияОригинала);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		// Установка блокировки.
		Если ВнутренняяТранзакция Тогда
			Попытка
				Блокировка.Заблокировать();
			Исключение
				// Вид ошибки "БлокировкаДляРегистра".
				ВызватьИсключение;
			КонецПопытки;
		КонецЕсли;
		
		// Откуда читаем?
		НаборЗаписейДубля.Прочитать();
		Если НаборЗаписейДубля.Количество() = 0 Тогда // Нечего писать.
			Если ВнутренняяТранзакция Тогда
				ОтменитьТранзакцию(); // Замена не требуется.
			КонецЕсли;
			Возврат;
		КонецЕсли;
		ЗаписьДубля = НаборЗаписейДубля[0];
		
		// Куда пишем?
		Если ТребуетсяДваНабора Тогда
			// Пишем в набор с другими измерениями.
			НаборЗаписейОригинала.Прочитать();
			Если НаборЗаписейОригинала.Количество() = 0 Тогда
				ЗаписьОригинала = НаборЗаписейОригинала.Добавить();
				ЗаполнитьЗначенияСвойств(ЗаписьОригинала, ЗаписьДубля);
				ЗаполнитьЗначенияСвойств(ЗаписьОригинала, ЗначенияИзмеренийОригинала);
			Иначе
				ЗаписьОригинала = НаборЗаписейОригинала[0];
			КонецЕсли;
		Иначе
			// Пишем туда-же, откуда и читаем.
			НаборЗаписейОригинала = НаборЗаписейДубля;
			ЗаписьОригинала = ЗаписьДубля; // Ситуация с нулевым количеством записей в наборе обработана выше.
		КонецЕсли;
		
		// Замена дубля на оригинал в ресурсах и реквизитах.
		Для Каждого КлючЗначение Из Информация.Ресурсы Цикл
			ЗначениеРеквизитаВОригинале = ЗаписьОригинала[КлючЗначение.Ключ];
			Если ЗначениеРеквизитаВОригинале = Дубль Тогда
				ЗаписьОригинала[КлючЗначение.Ключ] = Оригинал;
			КонецЕсли;
		КонецЦикла;
		Для Каждого КлючЗначение Из Информация.Реквизиты Цикл
			ЗначениеРеквизитаВОригинале = ЗаписьОригинала[КлючЗначение.Ключ];
			Если ЗначениеРеквизитаВОригинале = Дубль Тогда
				ЗаписьОригинала[КлючЗначение.Ключ] = Оригинал;
			КонецЕсли;
		КонецЦикла;

		Если Не ПараметрыВыполнения.ПараметрыЗаписи.ПривелигированныйРежим Тогда
			УстановитьПривилегированныйРежим(Ложь);
		КонецЕсли;
		
		// Удаление данных дубля.
		Если ТребуетсяДваНабора Тогда
			НаборЗаписейДубля.Очистить();
			Попытка
				ЗаписатьОбъектПриЗаменеСсылок(НаборЗаписейДубля, ПараметрыВыполнения);
			Исключение
				// Вид ошибки "УдалитьНаборДубля".
				ВызватьИсключение;
			КонецПопытки;
		КонецЕсли;
		
		// Запись данных оригинала.
		Если НаборЗаписейОригинала.Модифицированность() Тогда
			Попытка
				ЗаписатьОбъектПриЗаменеСсылок(НаборЗаписейОригинала, ПараметрыВыполнения);
			Исключение
				// Вид ошибки "ЗаписатьНаборОригинала".
				ВызватьИсключение;
			КонецПопытки;
		КонецЕсли;

		Если ВнутренняяТранзакция Тогда
			ЗафиксироватьТранзакцию();
		КонецЕсли;
	Исключение
		Если ВнутренняяТранзакция Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		ЗарегистрироватьОшибкуВТаблицу(Результат, Дубль, Оригинал, КлючЗаписиРегистра, Информация,
			"БлокировкаДляРегистра", ИнформацияОбОшибке());
	КонецПопытки;

КонецПроцедуры

Функция ИзмененныеОбъектыПриЗаменеВОбъекте(ПараметрыВыполнения, МестоИспользования, ОбрабатываемыеСтроки)
	Данные = МестоИспользования.Данные;
	ОписаниеПоследовательностей = ОписаниеПоследовательностей(МестоИспользования.Метаданные);
	ОписаниеДвижений            = ОписаниеДвижений(МестоИспользования.Метаданные);

	УстановитьПривилегированныйРежим(Истина);
	
	// Возвращаем измененные обработанные объекты.
	Измененные = Новый Соответствие;
	
	// Считываем
	Описание = ОписаниеОбъекта(Данные.Метаданные());
	Попытка
		Объект = Данные.ПолучитьОбъект();
	Исключение
		// Был уже обработан с ошибками.
		Объект = Неопределено;
	КонецПопытки;

	Если Объект = Неопределено Тогда
		Возврат Измененные;
	КонецЕсли;

	Для Каждого ОписаниеДвижения Из ОписаниеДвижений Цикл
		ОписаниеДвижения.НаборЗаписей.Отбор.Регистратор.Установить(Данные);
		ОписаниеДвижения.НаборЗаписей.Прочитать();
	КонецЦикла;

	Для Каждого ОписаниеПоследовательности Из ОписаниеПоследовательностей Цикл
		ОписаниеПоследовательности.НаборЗаписей.Отбор.Регистратор.Установить(Данные);
		ОписаниеПоследовательности.НаборЗаписей.Прочитать();
	КонецЦикла;
	
	// Заменяем сразу все варианты.
	ПарыЗамен = Новый Соответствие;
	Для Каждого МестоИспользования Из ОбрабатываемыеСтроки Цикл
		ПарыЗамен.Вставить(МестоИспользования.Ссылка, МестоИспользования.ЦелеваяСсылка);
	КонецЦикла;
	
	// Реквизиты
	Для Каждого КлючЗначение Из Описание.Реквизиты Цикл
		Имя = КлючЗначение.Ключ;
		ЦелеваяСсылка = ПарыЗамен[Объект[Имя]];
		Если ЦелеваяСсылка <> Неопределено Тогда
			ЗарегистрироватьФактЗамены(Объект, Объект[Имя], ЦелеваяСсылка, "Реквизиты", Имя);
			Объект[Имя] = ЦелеваяСсылка;
		КонецЕсли;
	КонецЦикла;
	
	// Стандартные реквизиты
	Для Каждого КлючЗначение Из Описание.СтандартныеРеквизиты Цикл
		Имя = КлючЗначение.Ключ;
		ЦелеваяСсылка = ПарыЗамен[Объект[Имя]];
		Если ЦелеваяСсылка <> Неопределено Тогда
			ЗарегистрироватьФактЗамены(Объект, Объект[Имя], ЦелеваяСсылка, "СтандартныеРеквизиты", Имя);
			Объект[Имя] = ЦелеваяСсылка;
		КонецЕсли;
	КонецЦикла;
		
	// Табличные части
	Для Каждого Элемент Из Описание.ТабличныеЧасти Цикл
		ЗаменитьВКоллекцииСтрок(
			"ТабличныеЧасти", Элемент.Имя, Объект, Объект[Элемент.Имя], Элемент.СписокПолей, ПарыЗамен);
	КонецЦикла;
	
	// Стандартные табличные части.
	Для Каждого Элемент Из Описание.СтандартныеТабличныеЧасти Цикл
		ЗаменитьВКоллекцииСтрок(
			"СтандартныеТабличныеЧасти", Элемент.Имя, Объект, Объект[Элемент.Имя], Элемент.СписокПолей, ПарыЗамен);
	КонецЦикла;
		
	// Движения
	Для Каждого ОписаниеДвижения Из ОписаниеДвижений Цикл
		ЗаменитьВКоллекцииСтрок(
			"Движения", ОписаниеДвижения.ПространствоБлокировки, ОписаниеДвижения.НаборЗаписей,
			ОписаниеДвижения.НаборЗаписей, ОписаниеДвижения.СписокПолей, ПарыЗамен);
	КонецЦикла;
	
	// Последовательности
	Для Каждого ОписаниеПоследовательности Из ОписаниеПоследовательностей Цикл
		ЗаменитьВКоллекцииСтрок(
			"Последовательности", ОписаниеПоследовательности.ПространствоБлокировки,
			ОписаниеПоследовательности.НаборЗаписей, ОписаниеПоследовательности.НаборЗаписей,
			ОписаниеПоследовательности.СписокПолей, ПарыЗамен);
	КонецЦикла;

	Для Каждого ОписаниеДвижения Из ОписаниеДвижений Цикл
		Если ОписаниеДвижения.НаборЗаписей.Модифицированность() Тогда
			Измененные.Вставить(ОписаниеДвижения.НаборЗаписей, Ложь);
		КонецЕсли;
	КонецЦикла;

	Для Каждого ОписаниеПоследовательности Из ОписаниеПоследовательностей Цикл
		Если ОписаниеПоследовательности.НаборЗаписей.Модифицированность() Тогда
			Измененные.Вставить(ОписаниеПоследовательности.НаборЗаписей, Ложь);
		КонецЕсли;
	КонецЦикла;
	
	// Сам объект последний - для возможного перепроведения.
	Если Объект.Модифицированность() Тогда
		Измененные.Вставить(Объект, Описание.МожетБытьПроведен);
	КонецЕсли;

	Возврат Измененные;
КонецФункции

Процедура ЗарегистрироватьФактЗамены(Объект, СсылкаДубля, СсылкаОригинала, ВидРеквизита, ИмяРеквизита,
	Индекс = Неопределено, ИмяКолонки = Неопределено)
	Структура = Новый Структура("ДополнительныеСвойства");
	ЗаполнитьЗначенияСвойств(Структура, Объект);
	Если ТипЗнч(Структура.ДополнительныеСвойства) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	ДопСвойства = Объект.ДополнительныеСвойства;
	ДопСвойства.Вставить("ЗаменаСсылок", Истина);
	ВыполненныеЗамены = UT_CommonClientServer.StructureProperty(ДопСвойства, "ВыполненныеЗамены");
	Если ВыполненныеЗамены = Неопределено Тогда
		ВыполненныеЗамены = Новый Массив;
		ДопСвойства.Вставить("ВыполненныеЗамены", ВыполненныеЗамены);
	КонецЕсли;
	ОписаниеЗамены = Новый Структура;
	ОписаниеЗамены.Вставить("СсылкаДубля", СсылкаДубля);
	ОписаниеЗамены.Вставить("СсылкаОригинала", СсылкаОригинала);
	ОписаниеЗамены.Вставить("ВидРеквизита", ВидРеквизита);
	ОписаниеЗамены.Вставить("ИмяРеквизита", ИмяРеквизита);
	ОписаниеЗамены.Вставить("Индекс", Индекс);
	ОписаниеЗамены.Вставить("ИмяКолонки", ИмяКолонки);
	ВыполненныеЗамены.Добавить(ОписаниеЗамены);
КонецПроцедуры

Процедура УдалитьСсылкиНемонопольно(Результат, Знач СписокСсылок, Знач ПараметрыВыполнения, Знач УдалятьНепосредственно)

	УстановитьПривилегированныйРежим(Истина);

	Удаляемые = Новый Массив;

	ЛокальнаяТранзакция = Не ТранзакцияАктивна();
	Если ЛокальнаяТранзакция Тогда
		НачатьТранзакцию();
	КонецЕсли;

	Попытка
		Для Каждого Ссылка Из СписокСсылок Цикл
			Информация = ИнформацияОТипе(ТипЗнч(Ссылка), ПараметрыВыполнения);
			Блокировка = Новый БлокировкаДанных;
			Блокировка.Добавить(Информация.ПолноеИмя).УстановитьЗначение("Ссылка", Ссылка);
			Попытка
				Блокировка.Заблокировать();
				Удаляемые.Добавить(Ссылка);
			Исключение
				ЗарегистрироватьОшибкуВТаблицу(Результат, Ссылка, Неопределено, Ссылка, Информация,
					"БлокировкаДляУдаленияДубля", ИнформацияОбОшибке());
			КонецПопытки;
		КонецЦикла;

		ТаблицаПоиска = МестаИспользования(Удаляемые);
		Фильтр = Новый Структура("Ссылка");

		Для Каждого Ссылка Из Удаляемые Цикл
			ПредставлениеСсылки = ПредметСтрокой(Ссылка);

			Фильтр.Ссылка = Ссылка;
			МестаИспользования = ТаблицаПоиска.НайтиСтроки(Фильтр);

			Индекс = МестаИспользования.ВГраница();
			Пока Индекс >= 0 Цикл
				Если МестаИспользования[Индекс].ВспомогательныеДанные Тогда
					МестаИспользования.Удалить(Индекс);
				КонецЕсли;
				Индекс = Индекс - 1;
			КонецЦикла;

			Если МестаИспользования.Количество() > 0 Тогда
				ДобавитьРезультатыЗаменыИзмененныхОбъектов(Результат, МестаИспользования);
				Продолжить; // Остались места использования, нельзя удалять.
			КонецЕсли;

			Объект = Ссылка.ПолучитьОбъект();
			Если Объект = Неопределено Тогда
				Продолжить; // Уже удален.
			КонецЕсли;

			Если Не ПараметрыВыполнения.ПараметрыЗаписи.ПривелигированныйРежим Тогда
				УстановитьПривилегированныйРежим(Ложь);
			КонецЕсли;

			Попытка
				Если УдалятьНепосредственно Тогда
					ОбработатьОбъектСПерехватомСообщенийПриЗаменеСсылок(Объект, "НепосредственноеУдаление", Неопределено,
						ПараметрыВыполнения);
				Иначе
					ОбработатьОбъектСПерехватомСообщенийПриЗаменеСсылок(Объект, "УстановитьПометкуУдаления",
						Неопределено, ПараметрыВыполнения);
				КонецЕсли;
			Исключение
				ТекстОшибки = НСтр("ru = 'Ошибка удаления'") + Символы.ПС + СокрЛП(КраткоеПредставлениеОшибки(
					ИнформацияОбОшибке()));
				ОписаниеОшибки = ОписаниеОшибкиЗамены("ОшибкаУдаления", Ссылка, ПредставлениеСсылки, ТекстОшибки);
				ЗарегистрироватьОшибкуЗамены(Результат, Ссылка, ОписаниеОшибки);
			КонецПопытки;

			Если Не ПараметрыВыполнения.ПараметрыЗаписи.ПривелигированныйРежим Тогда
				УстановитьПривилегированныйРежим(Истина);
			КонецЕсли;
		КонецЦикла;

		Если ЛокальнаяТранзакция Тогда
			ЗафиксироватьТранзакцию();
		КонецЕсли;
	Исключение
		Если ЛокальнаяТранзакция Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
	КонецПопытки;

КонецПроцедуры

Процедура ДобавитьРезультатыЗаменыИзмененныхОбъектов(Результат, ТаблицаПовторногоПоиска)

	Фильтр = Новый Структура("ТипОшибки, Ссылка, ОбъектОшибки", "");
	Для Каждого Строка Из ТаблицаПовторногоПоиска Цикл
		Тест = Новый Структура("ВспомогательныеДанные", Ложь);
		ЗаполнитьЗначенияСвойств(Тест, Строка);
		Если Тест.ВспомогательныеДанные Тогда
			Продолжить;
		КонецЕсли;

		Данные = Строка.Данные;
		Ссылка = Строка.Ссылка;

		ПредставлениеДанных = Строка(Данные);

		Фильтр.ОбъектОшибки = Данные;
		Фильтр.Ссылка       = Ссылка;
		Если Результат.Ошибки.НайтиСтроки(Фильтр).Количество() > 0 Тогда
			Продолжить; // По данной проблеме уже записана ошибка.
		КонецЕсли;
		ЗарегистрироватьОшибкуЗамены(Результат, Ссылка, ОписаниеОшибкиЗамены("ДанныеИзменены", Данные,
			ПредставлениеДанных, НСтр(
			"ru = 'Заменены не все места использования. Возможно места использования были добавлены или изменены другим пользователем.'")));
	КонецЦикла;

КонецПроцедуры

Процедура ЗаблокироватьМестаИспользования(ПараметрыВыполнения, Блокировка, МестаИспользования)

	Для Каждого МестоИспользования Из МестаИспользования Цикл

		ЗаблокироватьМестоИспользования(ПараметрыВыполнения, Блокировка, МестоИспользования);

	КонецЦикла;

КонецПроцедуры

Процедура ЗаблокироватьМестоИспользования(ПараметрыВыполнения, Блокировка, МестоИспользования)

	Если МестоИспользования.КлючЗамены = "Константа" Тогда

		Блокировка.Добавить(МестоИспользования.Метаданные.ПолноеИмя());

	ИначеЕсли МестоИспользования.КлючЗамены = "Объект" Тогда

		СсылкаОбъекта     = МестоИспользования.Данные;
		МетаданныеОбъекта = МестоИспользования.Метаданные;
		
		// Сам объект.
		Блокировка.Добавить(МетаданныеОбъекта.ПолноеИмя()).УстановитьЗначение("Ссылка", СсылкаОбъекта);
		
		// Движения по регистратору.
		ОписаниеДвижений = ОписаниеДвижений(МетаданныеОбъекта);
		Для Каждого Элемент Из ОписаниеДвижений Цикл
			Блокировка.Добавить(Элемент.ПространствоБлокировки + ".НаборЗаписей").УстановитьЗначение("Регистратор",
				СсылкаОбъекта);
		КонецЦикла;
		
		// Последовательности.
		ОписаниеПоследовательностей = ОписаниеПоследовательностей(МетаданныеОбъекта);
		Для Каждого Элемент Из ОписаниеПоследовательностей Цикл
			Блокировка.Добавить(Элемент.ПространствоБлокировки).УстановитьЗначение("Регистратор", СсылкаОбъекта);
		КонецЦикла;

	ИначеЕсли МестоИспользования.КлючЗамены = "Последовательность" Тогда

		СсылкаОбъекта     = МестоИспользования.Данные;
		МетаданныеОбъекта = МестоИспользования.Метаданные;

		ОписаниеПоследовательностей = ОписаниеПоследовательностей(МетаданныеОбъекта);
		Для Каждого Элемент Из ОписаниеПоследовательностей Цикл
			Блокировка.Добавить(Элемент.ПространствоБлокировки).УстановитьЗначение("Регистратор", СсылкаОбъекта);
		КонецЦикла;

	ИначеЕсли МестоИспользования.КлючЗамены = "КлючЗаписи" Или МестоИспользования.КлючЗамены = "РегистрСведений" Тогда

		Информация = ИнформацияОТипе(МестоИспользования.Метаданные, ПараметрыВыполнения);
		ТипДубля = МестоИспользования.ТипСсылки;
		ТипОригинала = ТипЗнч(МестоИспользования.ЦелеваяСсылка);

		Для Каждого КлючЗначение Из Информация.Измерения Цикл
			ТипИзмерения = КлючЗначение.Значение.Тип;
			Если ТипИзмерения.СодержитТип(ТипДубля) Тогда
				БлокировкаПоИзмерению = Блокировка.Добавить(Информация.ПолноеИмя);
				БлокировкаПоИзмерению.УстановитьЗначение(КлючЗначение.Ключ, МестоИспользования.Ссылка);
			КонецЕсли;
			Если ТипИзмерения.СодержитТип(ТипОригинала) Тогда
				БлокировкаПоИзмерению = Блокировка.Добавить(Информация.ПолноеИмя);
				БлокировкаПоИзмерению.УстановитьЗначение(КлючЗначение.Ключ, МестоИспользования.ЦелеваяСсылка);
			КонецЕсли;
		КонецЦикла;

	КонецЕсли;

КонецПроцедуры

Функция ОписаниеДвижений(Знач Мета)
	// можно закэшировать по Мета

	ОписаниеДвижений = Новый Массив;
	Если Не Метаданные.Документы.Содержит(Мета) Тогда
		Возврат ОписаниеДвижений;
	КонецЕсли;

	Для Каждого Движение Из Мета.Движения Цикл

		Если Метаданные.РегистрыНакопления.Содержит(Движение) Тогда
			НаборЗаписей = РегистрыНакопления[Движение.Имя].СоздатьНаборЗаписей();
			ИсключатьПоля = "Активность, НомерСтроки, Период, Регистратор";

		ИначеЕсли Метаданные.РегистрыСведений.Содержит(Движение) Тогда
			НаборЗаписей = РегистрыСведений[Движение.Имя].СоздатьНаборЗаписей();
			ИсключатьПоля = "Активность, ВидДвижения, НомерСтроки, Период, Регистратор";

		ИначеЕсли Метаданные.РегистрыБухгалтерии.Содержит(Движение) Тогда
			НаборЗаписей = РегистрыБухгалтерии[Движение.Имя].СоздатьНаборЗаписей();
			ИсключатьПоля = "Активность, ВидДвижения, НомерСтроки, Период, Регистратор";

		ИначеЕсли Метаданные.РегистрыРасчета.Содержит(Движение) Тогда
			НаборЗаписей = РегистрыРасчета[Движение.Имя].СоздатьНаборЗаписей();
			ИсключатьПоля = "Активность, БазовыйПериодКонец, БазовыйПериодНачало, НомерСтроки, ПериодДействия,
							|ПериодДействияКонец, ПериодДействияНачало, ПериодРегистрации, Регистратор, Сторно,
							|ФактическийПериодДействия";
		Иначе
			// Неизвестный тип
			Продолжить;
		КонецЕсли;
		
		// Поля ссылочного типа и измерения - кандидаты.
		Описание = СпискиПолейПоТипу(НаборЗаписей, Движение.Измерения, ИсключатьПоля);
		Если Описание.СписокПолей.Количество() = 0 Тогда
			// Незачем обрабатывать
			Продолжить;
		КонецЕсли;

		Описание.Вставить("НаборЗаписей", НаборЗаписей);
		Описание.Вставить("ПространствоБлокировки", Движение.ПолноеИмя());

		ОписаниеДвижений.Добавить(Описание);
	КонецЦикла;	// Метаданные движений

	Возврат ОписаниеДвижений;
КонецФункции

Функция ОписаниеПоследовательностей(Знач Мета)

	ОписаниеПоследовательностей = Новый Массив;
	Если Не Метаданные.Документы.Содержит(Мета) Тогда
		Возврат ОписаниеПоследовательностей;
	КонецЕсли;

	Для Каждого Последовательность Из Метаданные.Последовательности Цикл
		Если Не Последовательность.Документы.Содержит(Мета) Тогда
			Продолжить;
		КонецЕсли;

		ИмяТаблицы = Последовательность.ПолноеИмя();
		
		// Список полей и измерений
		Описание = СпискиПолейПоТипу(ИмяТаблицы, Последовательность.Измерения, "Регистратор");
		Если Описание.СписокПолей.Количество() > 0 Тогда

			Описание.Вставить("НаборЗаписей", Последовательности[Последовательность.Имя].СоздатьНаборЗаписей());
			Описание.Вставить("ПространствоБлокировки", ИмяТаблицы + ".Записи");
			Описание.Вставить("Измерения", Новый Структура);

			ОписаниеПоследовательностей.Добавить(Описание);
		КонецЕсли;

	КонецЦикла;

	Возврат ОписаниеПоследовательностей;
КонецФункции

Функция ОписаниеОбъекта(Знач Мета)
	// можно закэшировать по Мета

	ТипВсеСсылки = AllRefsTypeDescription();

	Кандидаты = Новый Структура("Реквизиты, СтандартныеРеквизиты, ТабличныеЧасти, СтандартныеТабличныеЧасти");
	ЗаполнитьЗначенияСвойств(Кандидаты, Мета);

	ОписаниеОбъекта = Новый Структура;

	ОписаниеОбъекта.Вставить("Реквизиты", Новый Структура);
	Если Кандидаты.Реквизиты <> Неопределено Тогда
		Для Каждого МетаРеквизит Из Кандидаты.Реквизиты Цикл
			Если ОписанияТиповПересекаются(МетаРеквизит.Тип, ТипВсеСсылки) Тогда
				ОписаниеОбъекта.Реквизиты.Вставить(МетаРеквизит.Имя);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	ОписаниеОбъекта.Вставить("СтандартныеРеквизиты", Новый Структура);
	Если Кандидаты.СтандартныеРеквизиты <> Неопределено Тогда
		Исключаемые = Новый Структура("Ссылка");

		Для Каждого МетаРеквизит Из Кандидаты.СтандартныеРеквизиты Цикл
			Имя = МетаРеквизит.Имя;
			Если Не Исключаемые.Свойство(Имя) И ОписанияТиповПересекаются(МетаРеквизит.Тип, ТипВсеСсылки) Тогда
				ОписаниеОбъекта.Реквизиты.Вставить(МетаРеквизит.Имя);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	ОписаниеОбъекта.Вставить("ТабличныеЧасти", Новый Массив);
	Если Кандидаты.ТабличныеЧасти <> Неопределено Тогда
		Для Каждого МетаТаблица Из Кандидаты.ТабличныеЧасти Цикл

			СписокПолей = Новый Структура;
			Для Каждого МетаРеквизит Из МетаТаблица.Реквизиты Цикл
				Если ОписанияТиповПересекаются(МетаРеквизит.Тип, ТипВсеСсылки) Тогда
					СписокПолей.Вставить(МетаРеквизит.Имя);
				КонецЕсли;
			КонецЦикла;

			Если СписокПолей.Количество() > 0 Тогда
				ОписаниеОбъекта.ТабличныеЧасти.Добавить(Новый Структура("Имя, СписокПолей", МетаТаблица.Имя,
					СписокПолей));
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	ОписаниеОбъекта.Вставить("СтандартныеТабличныеЧасти", Новый Массив);
	Если Кандидаты.СтандартныеТабличныеЧасти <> Неопределено Тогда
		Для Каждого МетаТаблица Из Кандидаты.СтандартныеТабличныеЧасти Цикл

			СписокПолей = Новый Структура;
			Для Каждого МетаРеквизит Из МетаТаблица.СтандартныеРеквизиты Цикл
				Если ОписанияТиповПересекаются(МетаРеквизит.Тип, ТипВсеСсылки) Тогда
					СписокПолей.Вставить(МетаРеквизит.Имя);
				КонецЕсли;
			КонецЦикла;

			Если СписокПолей.Количество() > 0 Тогда
				ОписаниеОбъекта.СтандартныеТабличныеЧасти.Добавить(Новый Структура("Имя, СписокПолей", МетаТаблица.Имя,
					СписокПолей));
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	ОписаниеОбъекта.Вставить("МожетБытьПроведен", Метаданные.Документы.Содержит(Мета));
	Возврат ОписаниеОбъекта;
КонецФункции

Функция ОписаниеКлючаЗаписи(Знач Мета)
	// можно закэшировать по Мета

	ИмяТаблицы = Мета.ПолноеИмя();
	
	// Поля ссылочного типа - кандидаты и набор измерений.
	ОписаниеКлюча = СпискиПолейПоТипу(ИмяТаблицы, Мета.Измерения, "Период, Регистратор");

	Если Метаданные.РегистрыСведений.Содержит(Мета) Тогда
		НаборЗаписей = РегистрыСведений[Мета.Имя].СоздатьНаборЗаписей();

	ИначеЕсли Метаданные.РегистрыНакопления.Содержит(Мета) Тогда
		НаборЗаписей = РегистрыНакопления[Мета.Имя].СоздатьНаборЗаписей();

	ИначеЕсли Метаданные.РегистрыБухгалтерии.Содержит(Мета) Тогда
		НаборЗаписей = РегистрыБухгалтерии[Мета.Имя].СоздатьНаборЗаписей();

	ИначеЕсли Метаданные.РегистрыРасчета.Содержит(Мета) Тогда
		НаборЗаписей = РегистрыРасчета[Мета.Имя].СоздатьНаборЗаписей();

	ИначеЕсли Метаданные.Последовательности.Содержит(Мета) Тогда
		НаборЗаписей = Последовательности[Мета.Имя].СоздатьНаборЗаписей();

	Иначе
		НаборЗаписей = Неопределено;

	КонецЕсли;

	ОписаниеКлюча.Вставить("НаборЗаписей", НаборЗаписей);
	ОписаниеКлюча.Вставить("ПространствоБлокировки", ИмяТаблицы);

	Возврат ОписаниеКлюча;
КонецФункции

Функция ОписанияТиповПересекаются(Знач Описание1, Знач Описание2)

	Для Каждого Тип Из Описание1.Типы() Цикл
		Если Описание2.СодержитТип(Тип) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;

	Возврат Ложь;
КонецФункции

// Возвращает описание по имени таблицы или по набору записей.
Функция СпискиПолейПоТипу(Знач ИсточникДанных, Знач МетаИзмерения, Знач ИсключатьПоля)
	// можно закэшировать

	Описание = Новый Структура;
	Описание.Вставить("СписокПолей", Новый Структура);
	Описание.Вставить("СтруктураИзмерений", Новый Структура);
	Описание.Вставить("СписокВедущих", Новый Структура);

	ТипКонтроля = AllRefsTypeDescription();
	Исключаемые = Новый Структура(ИсключатьПоля);

	ТипИсточникаДанных = ТипЗнч(ИсточникДанных);

	Если ТипИсточникаДанных = Тип("Строка") Тогда
		// Источник - имя таблицы, получаем поля запросом.
		Запрос = Новый Запрос("ВЫБРАТЬ * ИЗ " + ИсточникДанных + " ГДЕ ЛОЖЬ");
		ИсточникПолей = Запрос.Выполнить();
	Иначе
		// Источник - набор записей
		ИсточникПолей = ИсточникДанных.ВыгрузитьКолонки();
	КонецЕсли;

	Для Каждого Колонка Из ИсточникПолей.Колонки Цикл
		Имя = Колонка.Имя;
		Если Не Исключаемые.Свойство(Имя) И ОписанияТиповПересекаются(Колонка.ТипЗначения, ТипКонтроля) Тогда
			Описание.СписокПолей.Вставить(Имя);
			
			// И проверка на ведущее измерение.
			Мета = МетаИзмерения.Найти(Имя);
			Если Мета <> Неопределено Тогда
				Описание.СтруктураИзмерений.Вставить(Имя, Мета.Тип);
				Тест = Новый Структура("Ведущее", Ложь);
				ЗаполнитьЗначенияСвойств(Тест, Мета);
				Если Тест.Ведущее Тогда
					Описание.СписокВедущих.Вставить(Имя, Мета.Тип);
				КонецЕсли;
			КонецЕсли;

		КонецЕсли;

	КонецЦикла;

	Возврат Описание;
КонецФункции

Процедура ЗаменитьВКоллекцииСтрок(ВидКоллекции, ИмяКоллекции, Объект, Коллекция, Знач СписокПолей, Знач ПарыЗамен)
	РабочаяКоллекция = Коллекция.Выгрузить();
	Модифицировано = Ложь;

	Для Каждого Строка Из РабочаяКоллекция Цикл

		Для Каждого КлючЗначение Из СписокПолей Цикл
			Имя = КлючЗначение.Ключ;
			ЦелеваяСсылка = ПарыЗамен[Строка[Имя]];
			Если ЦелеваяСсылка <> Неопределено Тогда
				ЗарегистрироватьФактЗамены(Объект, Строка[Имя], ЦелеваяСсылка, ВидКоллекции, ИмяКоллекции,
					РабочаяКоллекция.Индекс(Строка), Имя);
				Строка[Имя] = ЦелеваяСсылка;
				Модифицировано = Истина;
			КонецЕсли;
		КонецЦикла;

	КонецЦикла;

	Если Модифицировано Тогда
		Коллекция.Загрузить(РабочаяКоллекция);
	КонецЕсли;
КонецПроцедуры

Процедура ОбработатьОбъектСПерехватомСообщенийПриЗаменеСсылок(Знач Объект, Знач Действие, Знач РежимЗаписи,
	Знач ПараметрыЗаписи)
	
	// Текущие сообщения до исключения запоминаем.
	ПредыдущиеСообщения = ПолучитьСообщенияПользователю(Истина);
	СообщатьПовторно    = ТекущийРежимЗапуска() <> Неопределено;

	Если Не ЗаписатьОбъектВБазу(Объект, ПараметрыЗаписи.ПараметрыЗаписи, Действие, РежимЗаписи, Истина) Тогда
		// Перехватываем все сообщенное при ошибке и добавляем их в одно исключение.
		ТекстИсключения = "";
		Для Каждого Сообщение Из ПолучитьСообщенияПользователю(Ложь) Цикл
			ТекстИсключения = ТекстИсключения + Символы.ПС + Сообщение.Текст;
		КонецЦикла;
		
		// Сообщаем предыдущие
		Если СообщатьПовторно Тогда
			СообщитьОтложенныеСообщения(ПредыдущиеСообщения);
		КонецЕсли;

		Если ТекстИсключения = "" Тогда
			ВызватьИсключение "";
		Иначе
			ВызватьИсключение СокрЛП(ТекстИсключения);
		КонецЕсли;
	КонецЕсли;

	Если СообщатьПовторно Тогда
		СообщитьОтложенныеСообщения(ПредыдущиеСообщения);
	КонецЕсли;

КонецПроцедуры

Процедура СообщитьОтложенныеСообщения(Знач Сообщения)

	Для Каждого Сообщение Из Сообщения Цикл
		Сообщение.Сообщить();
	КонецЦикла;

КонецПроцедуры

Процедура ЗаписатьОбъектПриЗаменеСсылок(Знач Объект, Знач ПараметрыЗаписи)

	МетаданныеОбъекта = Объект.Метаданные();

	Если ЭтоДокумент(МетаданныеОбъекта) Тогда
		ОбработатьОбъектСПерехватомСообщенийПриЗаменеСсылок(Объект, "Запись", РежимЗаписиДокумента.Запись,
			ПараметрыЗаписи);
		Возврат;
	КонецЕсли;
	
	// Проверка на возможные циклические ссылки.
	СвойстваОбъекта = Новый Структура("Иерархический, ВидыСубконто, Владельцы", Ложь, Неопределено, Новый Массив);
	ЗаполнитьЗначенияСвойств(СвойстваОбъекта, МетаданныеОбъекта);
	
	// По родителю
	Если СвойстваОбъекта.Иерархический Или СвойстваОбъекта.ВидыСубконто <> Неопределено Тогда

		Если Объект.Родитель = Объект.Ссылка Тогда
			ВызватьИсключение СтрШаблон(
				НСтр("ru = 'При записи ""%1"" возникает циклическая ссылка в иерархии.'"), Строка(Объект));
		КонецЕсли;

	КонецЕсли;
	
	// По владельцу
	Если СвойстваОбъекта.Владельцы.Количество() > 1 И Объект.Владелец = Объект.Ссылка Тогда
		ВызватьИсключение СтрШаблон(
			НСтр("ru = 'При записи ""%1"" возникает циклическая ссылка в подчинении.'"), Строка(Объект));
	КонецЕсли;
	
	// Для последовательностей право "Изменение" может отсутствовать даже у роли "АдминистраторСистемы".
	Если ЭтоПоследовательность(МетаданныеОбъекта) И Не ПравоДоступа("Изменение", МетаданныеОбъекта)
		И UT_Users.IsFullUser( , , Ложь) Тогда

		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;
	
	// Просто запись
	ОбработатьОбъектСПерехватомСообщенийПриЗаменеСсылок(Объект, "Запись", Неопределено, ПараметрыЗаписи);
КонецПроцедуры

Функция СобытиеЖурналаРегистрацииЗаменыСсылок()

	Возврат НСтр("ru='Поиск и удаление ссылок'", UT_CommonClientServer.DefaultLanguageCode());

КонецФункции

Процедура ЗарегистрироватьОшибкуВТаблицу(Результат, Дубль, Оригинал, Данные, Информация, ТипОшибки, ИнформацияОбОшибке)
	Результат.ЕстьОшибки = Истина;

	ЗаписьЖурналаРегистрации(
		СобытиеЖурналаРегистрацииЗаменыСсылок(), УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(
		ИнформацияОбОшибке));

	ПолноеПредставлениеДанных = Строка(Данные) + " (" + Информация.ПредставлениеЭлемента + ")";

	Ошибка = Результат.Ошибки.Добавить();
	Ошибка.Ссылка       = Дубль;
	Ошибка.ОбъектОшибки = Данные;
	Ошибка.ПредставлениеОбъектаОшибки = ПолноеПредставлениеДанных;

	Если ТипОшибки = "БлокировкаДляРегистра" Тогда
		НовыйШаблон = НСтр("ru = 'Не удалось начать редактирование %1: %2'");
		Ошибка.ТипОшибки = "ОшибкаБлокировки";
	ИначеЕсли ТипОшибки = "БлокировкаДляУдаленияДубля" Тогда
		НовыйШаблон = НСтр("ru = 'Не удалось начать удаление: %2'");
		Ошибка.ТипОшибки = "ОшибкаБлокировки";
	ИначеЕсли ТипОшибки = "УдалитьНаборДубля" Тогда
		НовыйШаблон = НСтр("ru = 'Не удалось очистить сведения о дубле в %1: %2'");
		Ошибка.ТипОшибки = "ОшибкаЗаписи";
	ИначеЕсли ТипОшибки = "ЗаписатьНаборОригинала" Тогда
		НовыйШаблон = НСтр("ru = 'Не удалось обновить сведения в %1: %2'");
		Ошибка.ТипОшибки = "ОшибкаЗаписи";
	Иначе
		НовыйШаблон = ТипОшибки + " (%1): %2";
		Ошибка.ТипОшибки = ТипОшибки;
	КонецЕсли;

	НовыйШаблон = НовыйШаблон + Символы.ПС + Символы.ПС + НСтр("ru = 'Подробности в журнале регистрации.'");

	КраткоеПредставление = КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
	Ошибка.ТекстОшибки = СтрШаблон(НовыйШаблон, ПолноеПредставлениеДанных, КраткоеПредставление);

КонецПроцедуры

// Формирует информацию о типе объекта метаданных: полное имя, представления, вид и т.п.
Функция ИнформацияОТипе(ПолноеИмяИлиМетаданныеИлиТип, Кэш)
	ТипПервогоПараметра = ТипЗнч(ПолноеИмяИлиМетаданныеИлиТип);
	Если ТипПервогоПараметра = Тип("Строка") Тогда
		ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ПолноеИмяИлиМетаданныеИлиТип);
	Иначе
		Если ТипПервогоПараметра = Тип("Тип") Тогда // Поиск объекта метаданных.
			ОбъектМетаданных = Метаданные.НайтиПоТипу(ПолноеИмяИлиМетаданныеИлиТип);
		Иначе
			ОбъектМетаданных = ПолноеИмяИлиМетаданныеИлиТип;
		КонецЕсли;
	КонецЕсли;
	ПолноеИмя = ВРег(ОбъектМетаданных.ПолноеИмя());

	ИнформацияОТипах = UT_CommonClientServer.StructureProperty(Кэш, "ИнформацияОТипах");
	Если ИнформацияОТипах = Неопределено Тогда
		ИнформацияОТипах = Новый Соответствие;
		Кэш.Вставить("ИнформацияОТипах", ИнформацияОТипах);
	Иначе
		Информация = ИнформацияОТипах.Получить(ПолноеИмя);
		Если Информация <> Неопределено Тогда
			Возврат Информация;
		КонецЕсли;
	КонецЕсли;

	Информация = Новый Структура("ПолноеИмя, ПредставлениеЭлемента, ПредставлениеСписка,
								 |Вид, Ссылочный, Технический, Разделенный,
								 |Иерархический,
								 |ЕстьПодчиненные, ИменаПодчиненных,
								 |Измерения, Реквизиты, Ресурсы");
	ИнформацияОТипах.Вставить(ПолноеИмя, Информация);
	
	// Заполнение базовой информации.
	Информация.ПолноеИмя = ПолноеИмя;
	
	// Представления: элемента и списка.
	СтандартныеСвойства = Новый Структура("ПредставлениеОбъекта, РасширенноеПредставлениеОбъекта, ПредставлениеСписка, РасширенноеПредставлениеСписка");
	ЗаполнитьЗначенияСвойств(СтандартныеСвойства, ОбъектМетаданных);
	Если ЗначениеЗаполнено(СтандартныеСвойства.ПредставлениеОбъекта) Тогда
		Информация.ПредставлениеЭлемента = СтандартныеСвойства.ПредставлениеОбъекта;
	ИначеЕсли ЗначениеЗаполнено(СтандартныеСвойства.РасширенноеПредставлениеОбъекта) Тогда
		Информация.ПредставлениеЭлемента = СтандартныеСвойства.РасширенноеПредставлениеОбъекта;
	Иначе
		Информация.ПредставлениеЭлемента = ОбъектМетаданных.Представление();
	КонецЕсли;
	Если ЗначениеЗаполнено(СтандартныеСвойства.ПредставлениеСписка) Тогда
		Информация.ПредставлениеСписка = СтандартныеСвойства.ПредставлениеСписка;
	ИначеЕсли ЗначениеЗаполнено(СтандартныеСвойства.РасширенноеПредставлениеСписка) Тогда
		Информация.ПредставлениеСписка = СтандартныеСвойства.РасширенноеПредставлениеСписка;
	Иначе
		Информация.ПредставлениеСписка = ОбъектМетаданных.Представление();
	КонецЕсли;
	
	// Вид и его свойства.
	Информация.Вид = Лев(Информация.ПолноеИмя, СтрНайти(Информация.ПолноеИмя, ".") - 1);
	Если Информация.Вид = "СПРАВОЧНИК" Или Информация.Вид = "ДОКУМЕНТ" Или Информация.Вид = "ПЕРЕЧИСЛЕНИЕ"
		Или Информация.Вид = "ПЛАНВИДОВХАРАКТЕРИСТИК" Или Информация.Вид = "ПЛАНСЧЕТОВ" Или Информация.Вид = "ПЛАНВИДОВРАСЧЕТА"
		Или Информация.Вид = "БИЗНЕСПРОЦЕСС" Или Информация.Вид = "ЗАДАЧА" Или Информация.Вид = "ПЛАНОБМЕНА" Тогда
		Информация.Ссылочный = Истина;
	Иначе
		Информация.Ссылочный = Ложь;
	КонецЕсли;

	Если Информация.Вид = "СПРАВОЧНИК" Или Информация.Вид = "ПЛАНВИДОВХАРАКТЕРИСТИК" Тогда
		Информация.Иерархический = ОбъектМетаданных.Иерархический;
	ИначеЕсли Информация.Вид = "ПЛАНСЧЕТОВ" Тогда
		Информация.Иерархический = Истина;
	Иначе
		Информация.Иерархический = Ложь;
	КонецЕсли;

	Информация.ЕстьПодчиненные = Ложь;
	Если Информация.Вид = "СПРАВОЧНИК" Или Информация.Вид = "ПЛАНВИДОВХАРАКТЕРИСТИК" Или Информация.Вид = "ПЛАНОБМЕНА"
		Или Информация.Вид = "ПЛАНСЧЕТОВ" Или Информация.Вид = "ПЛАНВИДОВРАСЧЕТА" Тогда
		Для Каждого Справочник Из Метаданные.Справочники Цикл
			Если Справочник.Владельцы.Содержит(ОбъектМетаданных) Тогда
				Если Информация.ЕстьПодчиненные = Ложь Тогда
					Информация.ЕстьПодчиненные = Истина;
					Информация.ИменаПодчиненных = Новый Массив;
				КонецЕсли;
				Информация.ИменаПодчиненных.Добавить(Справочник.ПолноеИмя());
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Если Информация.ПолноеИмя = "СПРАВОЧНИК.ИДЕНТИФИКАТОРЫОБЪЕКТОВМЕТАДАННЫХ" Или Информация.ПолноеИмя
		= "СПРАВОЧНИК.ПРЕДОПРЕДЕЛЕННЫЕВАРИАНТЫОТЧЕТОВ" Тогда
		Информация.Технический = Истина;
		Информация.Разделенный = Ложь;
	Иначе
		Информация.Технический = Ложь;
		Если Не Кэш.Свойство("МодельСервиса") Тогда
			Кэш.Вставить("МодельСервиса", DataSeparationEnabled());
			Если Кэш.МодельСервиса Тогда
//
//				Если ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
//					МодульРаботаВМоделиСервиса = ОбщийМодуль("РаботаВМоделиСервиса");
//					РазделительОсновныхДанных = МодульРаботаВМоделиСервиса.РазделительОсновныхДанных();
//					РазделительВспомогательныхДанных = МодульРаботаВМоделиСервиса.РазделительВспомогательныхДанных();
//				Иначе
					РазделительОсновныхДанных = Неопределено;
					РазделительВспомогательныхДанных = Неопределено;
//				КонецЕсли;

				Кэш.Вставить("ВОбластиДанных", DataSeparationEnabled() И SeparatedDataUsageAvailable());
				Кэш.Вставить("РазделительОсновныхДанных", РазделительОсновныхДанных);
				Кэш.Вставить("РазделительВспомогательныхДанных", РазделительВспомогательныхДанных);
			КонецЕсли;
		КонецЕсли;
		Если Кэш.МодельСервиса Тогда
//			Если ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
//				МодульРаботаВМоделиСервиса = ОбщийМодуль("РаботаВМоделиСервиса");
//				Попытка
//					ЭтоРазделенныйОбъектМетаданных = МодульРаботаВМоделиСервиса.ЭтоРазделенныйОбъектМетаданных(
//					ОбъектМетаданных);
//				Исключение
//					ЭтоРазделенныйОбъектМетаданных = Истина;
//				КонецПопытки;
//			Иначе
				ЭтоРазделенныйОбъектМетаданных = Истина;
//			КонецЕсли;
			Информация.Разделенный = ЭтоРазделенныйОбъектМетаданных;
		КонецЕсли;
	КонецЕсли;

	Информация.Измерения = Новый Структура;
	Информация.Реквизиты = Новый Структура;
	Информация.Ресурсы = Новый Структура;

	ВидыРеквизитов = Новый Структура("СтандартныеРеквизиты, Реквизиты, Измерения, Ресурсы");
	ЗаполнитьЗначенияСвойств(ВидыРеквизитов, ОбъектМетаданных);
	Для Каждого КлючИЗначение Из ВидыРеквизитов Цикл
		Коллекция = КлючИЗначение.Значение;
		Если ТипЗнч(Коллекция) = Тип("КоллекцияОбъектовМетаданных") Тогда
			КудаПишем = ?(Информация.Свойство(КлючИЗначение.Ключ), Информация[КлючИЗначение.Ключ], Информация.Реквизиты);
			Для Каждого Реквизит Из Коллекция Цикл
				КудаПишем.Вставить(Реквизит.Имя, ИнформацияПоРеквизиту(Реквизит));
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	Если Информация.Вид = "РЕГИСТРСВЕДЕНИЙ" И ОбъектМетаданных.ПериодичностьРегистраСведений
		<> Метаданные.СвойстваОбъектов.ПериодичностьРегистраСведений.Непериодический Тогда
		ИнформацияПоРеквизиту = Новый Структура("Ведущее, Представление, Формат, Тип, ЗначениеПоУмолчанию, ЗаполнятьИзДанныхЗаполнения");
		ИнформацияПоРеквизиту.Ведущее = Ложь;
		ИнформацияПоРеквизиту.ЗаполнятьИзДанныхЗаполнения = Ложь;
		Если ОбъектМетаданных.ПериодичностьРегистраСведений
			= Метаданные.СвойстваОбъектов.ПериодичностьРегистраСведений.ПозицияРегистратора Тогда
			ИнформацияПоРеквизиту.Тип = Новый ОписаниеТипов("МоментВремени");
		ИначеЕсли ОбъектМетаданных.ПериодичностьРегистраСведений
			= Метаданные.СвойстваОбъектов.ПериодичностьРегистраСведений.Секунда Тогда
			ИнформацияПоРеквизиту.Тип = Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты.ДатаВремя));
		Иначе
			ИнформацияПоРеквизиту.Тип = Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты.Дата));
		КонецЕсли;
		Информация.Измерения.Вставить("Период", ИнформацияПоРеквизиту);
	КонецЕсли;

	Возврат Информация;
КонецФункции

Функция ИнформацияПоРеквизиту(МетаданныеРеквизита)
	// ОписаниеСтандартногоРеквизита
	// ОбъектМетаданных: Измерение
	// ОбъектМетаданных: Ресурс
	// ОбъектМетаданных: Реквизит
	Информация = Новый Структура("Ведущее, Представление, Формат, Тип, ЗначениеПоУмолчанию, ЗаполнятьИзДанныхЗаполнения");
	ЗаполнитьЗначенияСвойств(Информация, МетаданныеРеквизита);
	Информация.Представление = МетаданныеРеквизита.Представление();
	Если Информация.ЗаполнятьИзДанныхЗаполнения = Истина Тогда
		Информация.ЗначениеПоУмолчанию = МетаданныеРеквизита.ЗначениеЗаполнения;
	Иначе
		Информация.ЗначениеПоУмолчанию = МетаданныеРеквизита.Тип.ПривестиЗначение();
	КонецЕсли;
	Возврат Информация;
КонецФункции

Функция ЭтоСлужебныеДанные(МестоИспользования, ИсключенияПоискаСсылок)

	ИсключениеПоиска = ИсключенияПоискаСсылок[МестоИспользования.Метаданные];
	
	// Данные может быть как ссылкой так и ключом записи регистра.

	Если ИсключениеПоиска = Неопределено Тогда
		Возврат (МестоИспользования.Ссылка = МестоИспользования.Данные); // Ссылку саму на себя исключаем.
	ИначеЕсли ИсключениеПоиска = "*" Тогда
		Возврат Истина; // Если указано исключить все - считаем все исключением.
	Иначе
		Для Каждого ПутьКРеквизиту Из ИсключениеПоиска Цикл
			// Если указаны исключения.
			
			// Относительный путь к реквизиту:
			//   "<ИмяРеквизитаИлиТЧ>[.<ИмяРеквизитаТЧ>]".

			Если ЭтоСсылка(ТипЗнч(МестоИспользования.Данные)) Тогда 
				
				// Проверка есть ли по исключаемому пути в указанных данных проверяемая ссылка

				ПолноеИмяОбъектаМетаданных = МестоИспользования.Метаданные.ПолноеИмя();

				ТекстЗапроса =
				"ВЫБРАТЬ
				|	ИСТИНА
				|ИЗ
				|	&ПолноеИмяОбъектаМетаданных КАК Таблица
				|ГДЕ
				|	&ПутьКРеквизиту = &ПроверяемаяСсылка
				|	И Таблица.Ссылка = &Ссылка";

				ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ПолноеИмяОбъектаМетаданных", ПолноеИмяОбъектаМетаданных);
				ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ПутьКРеквизиту", ПутьКРеквизиту);

				Запрос = Новый Запрос;
				Запрос.Текст = ТекстЗапроса;
				Запрос.УстановитьПараметр("ПроверяемаяСсылка", МестоИспользования.Ссылка);
				Запрос.УстановитьПараметр("Ссылка", МестоИспользования.Данные);

				Результат = Запрос.Выполнить();

				Если Не Результат.Пустой() Тогда
					Возврат Истина;
				КонецЕсли;

			Иначе

				БуферДанных = Новый Структура(ПутьКРеквизиту);
				ЗаполнитьЗначенияСвойств(БуферДанных, МестоИспользования.Данные);
				Если БуферДанных[ПутьКРеквизиту] = МестоИспользования.Ссылка Тогда
					Возврат Истина;
				КонецЕсли;

			КонецЕсли;

		КонецЦикла;
	КонецЕсли;

	Возврат Ложь;

КонецФункции

#КонецОбласти

#Область Метаданные

////////////////////////////////////////////////////////////////////////////////
// Функции определения типов объектов метаданных.

// Ссылочные типы данных

// Определяет принадлежность объекта метаданных к общему типу "Документ".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к документам.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является документом.
//
Функция ЭтоДокумент(ОбъектМетаданных) Экспорт

	Возврат Метаданные.Документы.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "Справочник".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является справочником.
//
Функция ЭтоСправочник(ОбъектМетаданных) Экспорт

	Возврат Метаданные.Справочники.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "Перечисление".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является перечислением.
//
Функция ЭтоПеречисление(ОбъектМетаданных) Экспорт

	Возврат Метаданные.Перечисления.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "План обмена".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является планом обмена.
//
Функция ЭтоПланОбмена(ОбъектМетаданных) Экспорт

	Возврат Метаданные.ПланыОбмена.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "План видов характеристик".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является планом видов характеристик.
//
Функция ЭтоПланВидовХарактеристик(ОбъектМетаданных) Экспорт

	Возврат Метаданные.ПланыВидовХарактеристик.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "Бизнес-процесс".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является бизнес-процессом.
//
Функция ЭтоБизнесПроцесс(ОбъектМетаданных) Экспорт

	Возврат Метаданные.БизнесПроцессы.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "Задача".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является задачей.
//
Функция ЭтоЗадача(ОбъектМетаданных) Экспорт

	Возврат Метаданные.Задачи.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "План счетов".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является планом счетов.
//
Функция ЭтоПланСчетов(ОбъектМетаданных) Экспорт

	Возврат Метаданные.ПланыСчетов.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "План видов расчета".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является планом видов расчета.
//
Функция ЭтоПланВидовРасчета(ОбъектМетаданных) Экспорт

	Возврат Метаданные.ПланыВидовРасчета.Содержит(ОбъектМетаданных);

КонецФункции

// Регистры

// Определяет принадлежность объекта метаданных к общему типу "Регистр сведений".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является регистром сведений.
//
Функция ЭтоРегистрСведений(ОбъектМетаданных) Экспорт

	Возврат Метаданные.РегистрыСведений.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "Регистр накопления".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является регистром накопления.
//
Функция ЭтоРегистрНакопления(ОбъектМетаданных) Экспорт

	Возврат Метаданные.РегистрыНакопления.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "Регистр бухгалтерии".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является регистром бухгалтерии.
//
Функция ЭтоРегистрБухгалтерии(ОбъектМетаданных) Экспорт

	Возврат Метаданные.РегистрыБухгалтерии.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к общему типу "Регистр расчета".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является регистром расчета.
//
Функция ЭтоРегистрРасчета(ОбъектМетаданных) Экспорт

	Возврат Метаданные.РегистрыРасчета.Содержит(ОбъектМетаданных);

КонецФункции

// Константы

// Определяет принадлежность объекта метаданных к общему типу "Константа".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является константой.
//
Функция ЭтоКонстанта(ОбъектМетаданных) Экспорт

	Возврат Метаданные.Константы.Содержит(ОбъектМетаданных);

КонецФункции

// Журналы документов

// Определяет принадлежность объекта метаданных к общему типу "Журнал документов".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является журналом документов.
//
Функция ЭтоЖурналДокументов(ОбъектМетаданных) Экспорт

	Возврат Метаданные.ЖурналыДокументов.Содержит(ОбъектМетаданных);

КонецФункции

// Последовательности

// Определяет принадлежность объекта метаданных к общему типу "Последовательности".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является последовательностью.
//
Функция ЭтоПоследовательность(ОбъектМетаданных) Экспорт

	Возврат Метаданные.Последовательности.Содержит(ОбъектМетаданных);

КонецФункции

// РегламентныеЗадания

// Определяет принадлежность объекта метаданных к общему типу "Регламентные задания".
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является регламентным заданием.
//
Функция ЭтоРегламентноеЗадание(ОбъектМетаданных) Экспорт

	Возврат Метаданные.РегламентныеЗадания.Содержит(ОбъектМетаданных);

КонецФункции

// Общие

// Определяет принадлежность объекта метаданных к типу регистр.
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект является каким-либо регистром.
//
Функция ЭтоРегистр(ОбъектМетаданных) Экспорт

	Возврат Метаданные.РегистрыБухгалтерии.Содержит(ОбъектМетаданных) Или Метаданные.РегистрыНакопления.Содержит(
		ОбъектМетаданных) Или Метаданные.РегистрыРасчета.Содержит(ОбъектМетаданных)
		Или Метаданные.РегистрыСведений.Содержит(ОбъектМетаданных);

КонецФункции

// Определяет принадлежность объекта метаданных к ссылочному типу.
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект, для которого необходимо определить принадлежность к заданному типу.
// 
// Возвращаемое значение:
//   Булево - Истина, если объект ссылочного типа.
//
Функция ЭтоОбъектСсылочногоТипа(ОбъектМетаданных) Экспорт

	ИмяОбъектаМетаданных = ОбъектМетаданных.ПолноеИмя();
	Позиция = СтрНайти(ИмяОбъектаМетаданных, ".");
	Если Позиция > 0 Тогда
		ИмяБазовогоТипа = Лев(ИмяОбъектаМетаданных, Позиция - 1);
		Возврат ИмяБазовогоТипа = "Справочник" Или ИмяБазовогоТипа = "Документ" Или ИмяБазовогоТипа = "БизнесПроцесс"
			Или ИмяБазовогоТипа = "Задача" Или ИмяБазовогоТипа = "ПланСчетов" Или ИмяБазовогоТипа = "ПланОбмена"
			Или ИмяБазовогоТипа = "ПланВидовХарактеристик" Или ИмяБазовогоТипа = "ПланВидовРасчета";
	Иначе
		Возврат Ложь;
	КонецЕсли;

КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции для работы с типами, объектами метаданных и их строковыми представлениями.

// Возвращает имена реквизитов объекта заданного типа.
//
// Параметры:
//  Ссылка - ЛюбаяСсылка - ссылка на элемент базы данных, для которого требуется получить результат функции;
//  Тип    - Тип - тип значения реквизита.
// 
// Возвращаемое значение:
//  Строка - строка реквизитов объекта метаданных конфигурации, разделенных символом ",".
//
// Пример:
//  РеквизитыОрганизации = ОбщегоНазначения.ИменаРеквизитовПоТипу(Документ.Ссылка, Тип("СправочникСсылка.Организации"));
//
Функция ИменаРеквизитовПоТипу(Ссылка, Тип) Экспорт

	Результат = "";
	//@skip-warning
	МетаданныеОбъекта = Ссылка.Метаданные();

	Для Каждого Реквизит Из МетаданныеОбъекта.Реквизиты Цикл
		Если Реквизит.Тип.СодержитТип(Тип) Тогда
			Результат = Результат + ?(ПустаяСтрока(Результат), "", ", ") + Реквизит.Имя;
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;
КонецФункции

// Возвращает имя базового типа по переданному значению объекта метаданных.
//
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - объект метаданных, по которому необходимо определить базовый тип.
// 
// Возвращаемое значение:
//  Строка - имя базового типа по переданному значению объекта метаданных.
//
// Пример:
//  ИмяБазовогоТипа = ОбщегоНазначения.ИмяБазовогоТипаПоОбъектуМетаданных(Метаданные.Справочники.Номенклатура); = "Справочники".
//
Функция ИмяБазовогоТипаПоОбъектуМетаданных(ОбъектМетаданных) Экспорт

	Если Метаданные.Документы.Содержит(ОбъектМетаданных) Тогда
		Возврат "Документы";

	ИначеЕсли Метаданные.Справочники.Содержит(ОбъектМетаданных) Тогда
		Возврат "Справочники";

	ИначеЕсли Метаданные.Перечисления.Содержит(ОбъектМетаданных) Тогда
		Возврат "Перечисления";

	ИначеЕсли Метаданные.РегистрыСведений.Содержит(ОбъектМетаданных) Тогда
		Возврат "РегистрыСведений";

	ИначеЕсли Метаданные.РегистрыНакопления.Содержит(ОбъектМетаданных) Тогда
		Возврат "РегистрыНакопления";

	ИначеЕсли Метаданные.РегистрыБухгалтерии.Содержит(ОбъектМетаданных) Тогда
		Возврат "РегистрыБухгалтерии";

	ИначеЕсли Метаданные.РегистрыРасчета.Содержит(ОбъектМетаданных) Тогда
		Возврат "РегистрыРасчета";

	ИначеЕсли Метаданные.ПланыОбмена.Содержит(ОбъектМетаданных) Тогда
		Возврат "ПланыОбмена";

	ИначеЕсли Метаданные.ПланыВидовХарактеристик.Содержит(ОбъектМетаданных) Тогда
		Возврат "ПланыВидовХарактеристик";

	ИначеЕсли Метаданные.БизнесПроцессы.Содержит(ОбъектМетаданных) Тогда
		Возврат "БизнесПроцессы";

	ИначеЕсли Метаданные.Задачи.Содержит(ОбъектМетаданных) Тогда
		Возврат "Задачи";

	ИначеЕсли Метаданные.ПланыСчетов.Содержит(ОбъектМетаданных) Тогда
		Возврат "ПланыСчетов";

	ИначеЕсли Метаданные.ПланыВидовРасчета.Содержит(ОбъектМетаданных) Тогда
		Возврат "ПланыВидовРасчета";

	ИначеЕсли Метаданные.Константы.Содержит(ОбъектМетаданных) Тогда
		Возврат "Константы";

	ИначеЕсли Метаданные.ЖурналыДокументов.Содержит(ОбъектМетаданных) Тогда
		Возврат "ЖурналыДокументов";

	ИначеЕсли Метаданные.Последовательности.Содержит(ОбъектМетаданных) Тогда
		Возврат "Последовательности";

	ИначеЕсли Метаданные.РегламентныеЗадания.Содержит(ОбъектМетаданных) Тогда
		Возврат "РегламентныеЗадания";

	ИначеЕсли Метаданные.РегистрыРасчета.Содержит(ОбъектМетаданных.Родитель())
		И ОбъектМетаданных.Родитель().Перерасчеты.Найти(ОбъектМетаданных.Имя) = ОбъектМетаданных Тогда
		Возврат "Перерасчеты";

	ИначеЕсли Метаданные.ВнешниеИсточникиДанных.Содержит(ОбъектМетаданных) Тогда
		Возврат "ВнешниеИсточникиДанных";

	Иначе

		Возврат "";

	КонецЕсли;

КонецФункции

// Возвращает менеджер объекта по полному имени объекта метаданных.
// Ограничение: не обрабатываются точки маршрутов бизнес-процессов.
//
// Параметры:
//  ПолноеИмя - Строка - полное имя объекта метаданных. Пример: "Справочник.Организации".
//
// Возвращаемое значение:
//  СправочникМенеджер, ДокументМенеджер, ОбработкаМенеджер, РегистрСведенийМенеджер - менеджер объекта.
// 
// Пример:
//  МенеджерСправочника = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени("Справочник.Организации");
//  ПустаяСсылка = МенеджерСправочника.ПустаяСсылка();
//
Функция МенеджерОбъектаПоПолномуИмени(ПолноеИмя) Экспорт
	Перем КлассОМ, ИмяОМ, Менеджер;

	ЧастиИмени = СтрРазделить(ПолноеИмя, ".");

	Если ЧастиИмени.Количество() >= 2 Тогда
		КлассОМ = ЧастиИмени[0];
		ИмяОМ  = ЧастиИмени[1];
	КонецЕсли;

	Если ВРег(КлассОМ) = "ПЛАНОБМЕНА" Тогда
		Менеджер = ПланыОбмена;

	ИначеЕсли ВРег(КлассОМ) = "СПРАВОЧНИК" Тогда
		Менеджер = Справочники;

	ИначеЕсли ВРег(КлассОМ) = "ДОКУМЕНТ" Тогда
		Менеджер = Документы;

	ИначеЕсли ВРег(КлассОМ) = "ЖУРНАЛДОКУМЕНТОВ" Тогда
		Менеджер = ЖурналыДокументов;

	ИначеЕсли ВРег(КлассОМ) = "ПЕРЕЧИСЛЕНИЕ" Тогда
		Менеджер = Перечисления;

	ИначеЕсли ВРег(КлассОМ) = "ОТЧЕТ" Тогда
		Менеджер = Отчеты;

	ИначеЕсли ВРег(КлассОМ) = "ОБРАБОТКА" Тогда
		Менеджер = Обработки;

	ИначеЕсли ВРег(КлассОМ) = "ПЛАНВИДОВХАРАКТЕРИСТИК" Тогда
		Менеджер = ПланыВидовХарактеристик;

	ИначеЕсли ВРег(КлассОМ) = "ПЛАНСЧЕТОВ" Тогда
		Менеджер = ПланыСчетов;

	ИначеЕсли ВРег(КлассОМ) = "ПЛАНВИДОВРАСЧЕТА" Тогда
		Менеджер = ПланыВидовРасчета;

	ИначеЕсли ВРег(КлассОМ) = "РЕГИСТРСВЕДЕНИЙ" Тогда
		Менеджер = РегистрыСведений;

	ИначеЕсли ВРег(КлассОМ) = "РЕГИСТРНАКОПЛЕНИЯ" Тогда
		Менеджер = РегистрыНакопления;

	ИначеЕсли ВРег(КлассОМ) = "РЕГИСТРБУХГАЛТЕРИИ" Тогда
		Менеджер = РегистрыБухгалтерии;

	ИначеЕсли ВРег(КлассОМ) = "РЕГИСТРРАСЧЕТА" Тогда
		Если ЧастиИмени.Количество() = 2 Тогда
			// Регистр расчета
			Менеджер = РегистрыРасчета;
		Иначе
			КлассПодчиненногоОМ = ЧастиИмени[2];
			ИмяПодчиненногоОМ = ЧастиИмени[3];
			Если ВРег(КлассПодчиненногоОМ) = "ПЕРЕРАСЧЕТ" Тогда
				// Перерасчет
				Попытка
					Менеджер = РегистрыРасчета[ИмяОМ].Перерасчеты;
					ИмяОм = ИмяПодчиненногоОМ;
				Исключение
					Менеджер = Неопределено;
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;

	ИначеЕсли ВРег(КлассОМ) = "БИЗНЕСПРОЦЕСС" Тогда
		Менеджер = БизнесПроцессы;

	ИначеЕсли ВРег(КлассОМ) = "ЗАДАЧА" Тогда
		Менеджер = Задачи;

	ИначеЕсли ВРег(КлассОМ) = "КОНСТАНТА" Тогда
		Менеджер = Константы;

	ИначеЕсли ВРег(КлассОМ) = "ПОСЛЕДОВАТЕЛЬНОСТЬ" Тогда
		Менеджер = Последовательности;
	КонецЕсли;

	Если Менеджер <> Неопределено Тогда
		Попытка
			Возврат Менеджер[ИмяОМ];
		Исключение
			Менеджер = Неопределено;
		КонецПопытки;
	КонецЕсли;

	ВызватьИсключение СтрШаблон(НСтр("ru = 'Неизвестный тип объекта метаданных ""%1""'"), ПолноеИмя);

КонецФункции

// Возвращает менеджер объекта по ссылке на объект.
// Ограничение: не обрабатываются точки маршрутов бизнес-процессов.
// См. также ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени.
//
// Параметры:
//  Ссылка - ЛюбаяСсылка - объект, менеджер которого требуется получить.
//
// Возвращаемое значение:
//  СправочникМенеджер, ДокументМенеджер, ОбработкаМенеджер, РегистрСведенийМенеджер - менеджер объекта.
//
// Пример:
//  МенеджерСправочника = ОбщегоНазначения.МенеджерОбъектаПоСсылке(СсылкаНаОрганизацию);
//  ПустаяСсылка = МенеджерСправочника.ПустаяСсылка();
//
Функция МенеджерОбъектаПоСсылке(Ссылка) Экспорт
	
	//@skip-warning
	ИмяОбъекта = Ссылка.Метаданные().Имя;
	ТипСсылки = ТипЗнч(Ссылка);

	Если Справочники.ТипВсеСсылки().СодержитТип(ТипСсылки) Тогда
		Возврат Справочники[ИмяОбъекта];

	ИначеЕсли Документы.ТипВсеСсылки().СодержитТип(ТипСсылки) Тогда
		Возврат Документы[ИмяОбъекта];

	ИначеЕсли БизнесПроцессы.ТипВсеСсылки().СодержитТип(ТипСсылки) Тогда
		Возврат БизнесПроцессы[ИмяОбъекта];

	ИначеЕсли ПланыВидовХарактеристик.ТипВсеСсылки().СодержитТип(ТипСсылки) Тогда
		Возврат ПланыВидовХарактеристик[ИмяОбъекта];

	ИначеЕсли ПланыСчетов.ТипВсеСсылки().СодержитТип(ТипСсылки) Тогда
		Возврат ПланыСчетов[ИмяОбъекта];

	ИначеЕсли ПланыВидовРасчета.ТипВсеСсылки().СодержитТип(ТипСсылки) Тогда
		Возврат ПланыВидовРасчета[ИмяОбъекта];

	ИначеЕсли Задачи.ТипВсеСсылки().СодержитТип(ТипСсылки) Тогда
		Возврат Задачи[ИмяОбъекта];

	ИначеЕсли ПланыОбмена.ТипВсеСсылки().СодержитТип(ТипСсылки) Тогда
		Возврат ПланыОбмена[ИмяОбъекта];

	ИначеЕсли Перечисления.ТипВсеСсылки().СодержитТип(ТипСсылки) Тогда
		Возврат Перечисления[ИмяОбъекта];
	Иначе
		Возврат Неопределено;
	КонецЕсли;

КонецФункции

// Проверка того, что переданный тип является ссылочным типом данных.
// Для типа "Неопределено" возвращается Ложь.
//
// Параметры:
//  ПроверяемыйТип - Тип - для проверки на ссылочный тип данных.
//
// Возвращаемое значение:
//  Булево - Истина, если это ссылка.
//
Функция ЭтоСсылка(ПроверяемыйТип) Экспорт

	Возврат ПроверяемыйТип <> Тип("Неопределено") И AllRefsTypeDescription().СодержитТип(ПроверяемыйТип);

КонецФункции

// Проверяет физическое наличие записи в информационной базе данных о переданном значении ссылки.
//
// Параметры:
//  ПроверяемаяСсылка - ЛюбаяСсылка - значение любой ссылки информационной базы данных.
// 
// Возвращаемое значение:
//  Булево - Истина, если существует.
//
Функция СсылкаСуществует(ПроверяемаяСсылка) Экспорт

	ТекстЗапроса = "
				   |ВЫБРАТЬ ПЕРВЫЕ 1
				   |	1
				   |ИЗ
				   |	[ИмяТаблицы]
				   |ГДЕ
				   |	Ссылка = &Ссылка
				   |";

	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "[ИмяТаблицы]", ИмяТаблицыПоСсылке(ПроверяемаяСсылка));

	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("Ссылка", ПроверяемаяСсылка);

	УстановитьПривилегированныйРежим(Истина);

	Возврат Не Запрос.Выполнить().Пустой();

КонецФункции

// Возвращает имя вида объектов метаданных по ссылке на объект.
// Ограничение: не обрабатываются точки маршрутов бизнес-процессов.
// См. так же ВидОбъектаПоТипу.
//
// Параметры:
//  Ссылка - ЛюбаяСсылка - объект, вид которого требуется получить.
//
// Возвращаемое значение:
//  Строка - имя вида объектов метаданных. Например: "Справочник", "Документ".
// 
Функция ВидОбъектаПоСсылке(Ссылка) Экспорт

	Возврат ВидОбъектаПоТипу(ТипЗнч(Ссылка));

КонецФункции 

// Возвращает имя вида объектов метаданных по типу объекта.
// Ограничение: не обрабатываются точки маршрутов бизнес-процессов.
// См. так же ВидОбъектаПоСсылке.
//
// Параметры:
//  ТипОбъекта - Тип - Тип прикладного объекта, определенный в конфигурации.
//
// Возвращаемое значение:
//  Строка - имя вида объектов метаданных. Например: "Справочник", "Документ".
// 
Функция ВидОбъектаПоТипу(ТипОбъекта) Экспорт

	Если Справочники.ТипВсеСсылки().СодержитТип(ТипОбъекта) Тогда
		Возврат "Справочник";

	ИначеЕсли Документы.ТипВсеСсылки().СодержитТип(ТипОбъекта) Тогда
		Возврат "Документ";

	ИначеЕсли БизнесПроцессы.ТипВсеСсылки().СодержитТип(ТипОбъекта) Тогда
		Возврат "БизнесПроцесс";

	ИначеЕсли ПланыВидовХарактеристик.ТипВсеСсылки().СодержитТип(ТипОбъекта) Тогда
		Возврат "ПланВидовХарактеристик";

	ИначеЕсли ПланыСчетов.ТипВсеСсылки().СодержитТип(ТипОбъекта) Тогда
		Возврат "ПланСчетов";

	ИначеЕсли ПланыВидовРасчета.ТипВсеСсылки().СодержитТип(ТипОбъекта) Тогда
		Возврат "ПланВидовРасчета";

	ИначеЕсли Задачи.ТипВсеСсылки().СодержитТип(ТипОбъекта) Тогда
		Возврат "Задача";

	ИначеЕсли ПланыОбмена.ТипВсеСсылки().СодержитТип(ТипОбъекта) Тогда
		Возврат "ПланОбмена";

	ИначеЕсли Перечисления.ТипВсеСсылки().СодержитТип(ТипОбъекта) Тогда
		Возврат "Перечисление";

	Иначе
		ВызватьИсключение СтрШаблон(НСтр("ru='Неверный тип значения параметра (%1)'"), Строка(ТипОбъекта));

	КонецЕсли;

КонецФункции

// Возвращает полное имя объекта метаданных по переданному значению ссылки.
//
// Параметры:
//  Ссылка - ЛюбаяСсылка - объект, для которого необходимо получить имя таблицы ИБ.
// 
// Возвращаемое значение:
//  Строка - полное имя объекта метаданных для указанного объекта. Например: "Справочник.Номенклатура".
//
Функция ИмяТаблицыПоСсылке(Ссылка) Экспорт
	
	//@skip-warning
	Возврат Ссылка.Метаданные().ПолноеИмя();

КонецФункции

// Проверяет, что переданное значение имеет ссылочный тип данных.
//
// Параметры:
//  Значение - Произвольный - проверяемое значение.
//
// Возвращаемое значение:
//  Булево - Истина, если тип значения ссылочный.
//
Функция ЗначениеСсылочногоТипа(Значение) Экспорт

	Возврат ЭтоСсылка(ТипЗнч(Значение));

КонецФункции

// Проверяет, является ли объект группой элементов.
//
// Параметры:
//  Объект - ЛюбаяСсылка, Объект - проверяемый объект.
//
// Возвращаемое значение:
//  Булево - Истина, если является.
//
Функция ОбъектЯвляетсяГруппой(Объект) Экспорт

	Если ЗначениеСсылочногоТипа(Объект) Тогда
		Ссылка = Объект;
	Иначе
		//@skip-warning
		Ссылка = Объект.Ссылка;
	КонецЕсли;
	
	//@skip-warning
	МетаданныеОбъекта = Ссылка.Метаданные();

	Если ЭтоСправочник(МетаданныеОбъекта) Тогда

		Если Не МетаданныеОбъекта.Иерархический Или МетаданныеОбъекта.ВидИерархии
			<> Метаданные.СвойстваОбъектов.ВидИерархии.ИерархияГруппИЭлементов Тогда

			Возврат Ложь;
		КонецЕсли;

	ИначеЕсли Не ЭтоПланВидовХарактеристик(МетаданныеОбъекта) Тогда
		Возврат Ложь;

	ИначеЕсли Не МетаданныеОбъекта.Иерархический Тогда
		Возврат Ложь;
	КонецЕсли;

	Если Ссылка <> Объект Тогда
		//@skip-warning
		Возврат Объект.ЭтоГруппа;
	КонецЕсли;

	Возврат ObjectAttributeValue(Ссылка, "ЭтоГруппа") = Истина;

КонецФункции

// Возвращает строковое представление типа. 
// Для ссылочных типов возвращает в формате "СправочникСсылка.ИмяОбъекта" или "ДокументСсылка.ИмяОбъекта".
// Для остальных типов приводит тип к строке, например "Число".
//
// Параметры:
//  Тип - тип - для которого надо получить представление.
//
// Возвращаемое значение:
//  Строка - представление типа.
//
Функция СтроковоеПредставлениеТипа(Тип) Экспорт

	Представление = "";

	Если ЭтоСсылка(Тип) Тогда

		ПолноеИмя = Метаданные.НайтиПоТипу(Тип).ПолноеИмя();
		ИмяОбъекта = СтрРазделить(ПолноеИмя, ".")[1];

		Если Справочники.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "СправочникСсылка";

		ИначеЕсли Документы.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ДокументСсылка";

		ИначеЕсли БизнесПроцессы.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "БизнесПроцессСсылка";

		ИначеЕсли ПланыВидовХарактеристик.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ПланВидовХарактеристикСсылка";

		ИначеЕсли ПланыСчетов.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ПланСчетовСсылка";

		ИначеЕсли ПланыВидовРасчета.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ПланВидовРасчетаСсылка";

		ИначеЕсли Задачи.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ЗадачаСсылка";

		ИначеЕсли ПланыОбмена.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ПланОбменаСсылка";

		ИначеЕсли Перечисления.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ПеречислениеСсылка";

		КонецЕсли;

		Результат = ?(Представление = "", Представление, Представление + "." + ИмяОбъекта);

	Иначе

		Результат = Строка(Тип);

	КонецЕсли;

	Возврат Результат;

КонецФункции

// Возвращает таблицу значений с описанием требуемых свойств всех реквизитов объекта метаданных.
// Получает значения свойств стандартных реквизитов и пользовательских реквизитов (созданных в режиме конфигуратора).
//
// Параметры:
//  ОбъектМетаданных  - ОбъектМетаданных - объект, для которого необходимо получить значение свойств реквизитов.
//                      Например: Метаданные.Документ.РеализацияТоваровИУслуг
//  Свойства - Строка - свойства реквизитов, перечисленные через запятую, значение которых необходимо получить.
//                      Например: "Имя, Тип, Синоним, Подсказка".
//
// Возвращаемое значение:
//  ТаблицаЗначений - описание требуемых свойств всех реквизитов объекта метаданных.
//
Функция ОписаниеСвойствОбъекта(ОбъектМетаданных, Свойства) Экспорт

	МассивСвойств = СтрРазделить(Свойства, ",");
	
	// Возвращаемое значение функции.
	ТаблицаОписанияСвойствОбъекта = Новый ТаблицаЗначений;
	
	// Добавляем в таблицу поля согласно именам переданных свойств.
	Для Каждого ИмяСвойства Из МассивСвойств Цикл
		ТаблицаОписанияСвойствОбъекта.Колонки.Добавить(СокрЛП(ИмяСвойства));
	КонецЦикла;
	
	// Заполняем строку таблицы свойствами реквизитов объекта метаданных.
	Для Каждого Реквизит Из ОбъектМетаданных.Реквизиты Цикл
		ЗаполнитьЗначенияСвойств(ТаблицаОписанияСвойствОбъекта.Добавить(), Реквизит);
	КонецЦикла;
	
	// Заполняем строку таблицы свойствами стандартных реквизитов объекта метаданных.
	Для Каждого Реквизит Из ОбъектМетаданных.СтандартныеРеквизиты Цикл
		ЗаполнитьЗначенияСвойств(ТаблицаОписанияСвойствОбъекта.Добавить(), Реквизит);
	КонецЦикла;

	Возврат ТаблицаОписанияСвойствОбъекта;

КонецФункции

// Возвращает признак того, что реквизит входит в подмножество стандартных реквизитов.
//
// Параметры:
//  СтандартныеРеквизиты - ОписанияСтандартныхРеквизитов - тип и значение, описывающие коллекцию настроек различных
//                                                         стандартных реквизитов;
//  ИмяРеквизита         - Строка - реквизит, который необходимо проверить на принадлежность множеству стандартных
//                                  реквизитов.
// 
// Возвращаемое значение:
//   Булево - Истина, если реквизит входит в подмножество стандартных реквизитов.
//
Функция ЭтоСтандартныйРеквизит(СтандартныеРеквизиты, ИмяРеквизита) Экспорт

	Для Каждого Реквизит Из СтандартныеРеквизиты Цикл
		Если Реквизит.Имя = ИмяРеквизита Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	Возврат Ложь;

КонецФункции

// Позволяет определить, есть ли среди реквизитов объекта реквизит с переданным именем.
//
// Параметры:
//  ИмяРеквизита - Строка - имя реквизита;
//  МетаданныеОбъекта - ОбъектМетаданных - объект, в котором требуется проверить наличие реквизита.
//
// Возвращаемое значение:
//  Булево - Истина, если есть.
//
Функция ЕстьРеквизитОбъекта(ИмяРеквизита, МетаданныеОбъекта) Экспорт

	Возврат Не (МетаданныеОбъекта.Реквизиты.Найти(ИмяРеквизита) = Неопределено);

КонецФункции

// Проверить, что описание типа состоит из единственного типа значения и 
// совпадает с нужным типом.
//
// Параметры:
//   ОписаниеТипа - ОписаниеТипов - проверяемая коллекция типов;
//   ТипЗначения  - Тип - проверяемый тип.
//
// Возвращаемое значение:
//   Булево - Истина, если совпадает.
//
// Пример:
//  Если ОбщегоНазначения.ОписаниеТипаСостоитИзТипа(ТипЗначенияСвойства, Тип("Булево") Тогда
//    // Выводим поле в виде флажка.
//  КонецЕсли;
//
Функция ОписаниеТипаСостоитИзТипа(ОписаниеТипа, ТипЗначения) Экспорт

	Если ОписаниеТипа.Типы().Количество() = 1 И ОписаниеТипа.Типы().Получить(0) = ТипЗначения Тогда
		Возврат Истина;
	КонецЕсли;

	Возврат Ложь;

КонецФункции

// Создает объект ОписаниеТипов, содержащий тип Строка.
//
// Параметры:
//  ДлинаСтроки - Число - длина строки.
//
// Возвращаемое значение:
//  ОписаниеТипов - описание типа Строка.
//
Функция ОписаниеТипаСтрока(ДлинаСтроки) Экспорт

	Массив = Новый Массив;
	Массив.Добавить(Тип("Строка"));

	КвалификаторСтроки = Новый КвалификаторыСтроки(ДлинаСтроки, ДопустимаяДлина.Переменная);

	Возврат Новый ОписаниеТипов(Массив, , КвалификаторСтроки);

КонецФункции

// Создает объект ОписаниеТипов, содержащий тип Число.
//
// Параметры:
//  Разрядность - Число - общее количество разрядов числа (количество разрядов
//                        целой части плюс количество разрядов дробной части).
//  РазрядностьДробнойЧасти - Число - число разрядов дробной части.
//  ЗнакЧисла - ДопустимыйЗнак - допустимый знак числа.
//
// Возвращаемое значение:
//  ОписаниеТипов - описание типа Число.
Функция ОписаниеТипаЧисло(Разрядность, РазрядностьДробнойЧасти = 0, ЗнакЧисла = Неопределено) Экспорт

	Если ЗнакЧисла = Неопределено Тогда
		КвалификаторЧисла = Новый КвалификаторыЧисла(Разрядность, РазрядностьДробнойЧасти);
	Иначе
		КвалификаторЧисла = Новый КвалификаторыЧисла(Разрядность, РазрядностьДробнойЧасти, ЗнакЧисла);
	КонецЕсли;

	Возврат Новый ОписаниеТипов("Число", КвалификаторЧисла);

КонецФункции

// Создает объект ОписаниеТипов, содержащий тип Дата.
//
// Параметры:
//  ЧастиДаты - ЧастиДаты - набор вариантов использования значений типа Дата.
//
// Возвращаемое значение:
//  ОписаниеТипов - описание типа Дата.
Функция ОписаниеТипаДата(ЧастиДаты) Экспорт

	Массив = Новый Массив;
	Массив.Добавить(Тип("Дата"));

	КвалификаторДаты = Новый КвалификаторыДаты(ЧастиДаты);

	Возврат Новый ОписаниеТипов(Массив, , , КвалификаторДаты);

КонецФункции
#КонецОбласти

#Область ХранилищеНастроек

////////////////////////////////////////////////////////////////////////////////
// Сохранение, чтение и удаление настроек из хранилищ.

// Сохраняет настройку в хранилище общих настроек, как метод платформы Сохранить,
// объектов СтандартноеХранилищеНастроекМенеджер или ХранилищеНастроекМенеджер.<Имя хранилища>,
// но с поддержкой длины ключа настроек более 128 символов путем хеширования части,
// которая превышает 96 символов.
// Если нет права СохранениеДанныхПользователя, сохранение пропускается без ошибки.
//
// Параметры:
//   КлючОбъекта       - Строка           - см. синтакс-помощник платформы.
//   КлючНастроек      - Строка           - см. синтакс-помощник платформы.
//   Настройки         - Произвольный     - см. синтакс-помощник платформы.
//   ОписаниеНастроек  - ОписаниеНастроек - см. синтакс-помощник платформы.
//   ИмяПользователя   - Строка           - см. синтакс-помощник платформы.
//   ОбновитьПовторноИспользуемыеЗначения - Булево - выполнить одноименный метод платформы.
//
Процедура ХранилищеОбщихНастроекСохранить(КлючОбъекта, КлючНастроек, Настройки, ОписаниеНастроек = Неопределено,
	ИмяПользователя = Неопределено, ОбновитьПовторноИспользуемыеЗначения = Ложь) Экспорт

	StorageSave(ХранилищеОбщихНастроек, КлючОбъекта, КлючНастроек, Настройки, ОписаниеНастроек, ИмяПользователя,
		ОбновитьПовторноИспользуемыеЗначения);

КонецПроцедуры

// Сохраняет несколько настроек в хранилище общих настроек, как метод платформы Сохранить,
// объектов СтандартноеХранилищеНастроекМенеджер или ХранилищеНастроекМенеджер.<Имя хранилища>,
// но с поддержкой длины ключа настроек более 128 символов путем хеширования части,
// которая превышает 96 символов.
// Если нет права СохранениеДанныхПользователя, сохранение пропускается без ошибки.
// 
// Параметры:
//   НесколькоНастроек - Массив - со значениями:
//     * Значение - Структура - со свойствами:
//         * Объект    - Строка       - см. параметр КлючОбъекта  в синтакс-помощнике платформы.
//         * Настройка - Строка       - см. параметр КлючНастроек в синтакс-помощнике платформы.
//         * Значение  - Произвольный - см. параметр Настройки    в синтакс-помощнике платформы.
//
//   ОбновитьПовторноИспользуемыеЗначения - Булево - выполнить одноименный метод платформы.
//
Процедура ХранилищеОбщихНастроекСохранитьМассив(НесколькоНастроек, ОбновитьПовторноИспользуемыеЗначения = Ложь) Экспорт

	Если Не ПравоДоступа("СохранениеДанныхПользователя", Метаданные) Тогда
		Возврат;
	КонецЕсли;

	Для Каждого Элемент Из НесколькоНастроек Цикл
		ХранилищеОбщихНастроек.Сохранить(Элемент.Объект, SettingsKey(Элемент.Настройка), Элемент.Значение);
	КонецЦикла;

	Если ОбновитьПовторноИспользуемыеЗначения Тогда
		ОбновитьПовторноИспользуемыеЗначения();
	КонецЕсли;

КонецПроцедуры

// Загружает настройку из хранилища общих настроек, как метод платформы Загрузить,
// объектов СтандартноеХранилищеНастроекМенеджер или ХранилищеНастроекМенеджер.<Имя хранилища>,
// но с поддержкой длины ключа настроек более 128 символов путем хеширования части,
// которая превышает 96 символов.
// Кроме того, возвращает указанное значение по умолчанию, если настройки не найдены.
// Если нет права СохранениеДанныхПользователя, возвращается значение по умолчанию без ошибки.
//
// В возвращаемом значении очищаются ссылки на несуществующий объект в базе данных, а именно
// - возвращаемая ссылка заменяется на указанное значение по умолчанию;
// - из данных типа Массив ссылки удаляются;
// - у данных типа Структура и Соответствие ключ не меняется, а значение устанавливается Неопределено;
// - анализ значений в данных типа Массив, Структура, Соответствие выполняется рекурсивно.
//
// Параметры:
//   КлючОбъекта          - Строка           - см. синтакс-помощник платформы.
//   КлючНастроек         - Строка           - см. синтакс-помощник платформы.
//   ЗначениеПоУмолчанию  - Произвольный     - значение, которое возвращается, если настройки не найдены.
//                                             Если не указано, возвращается значение Неопределено.
//   ОписаниеНастроек     - ОписаниеНастроек - см. синтакс-помощник платформы.
//   ИмяПользователя      - Строка           - см. синтакс-помощник платформы.
//
// Возвращаемое значение: 
//   Произвольный - см. синтакс-помощник платформы.
//
Функция ХранилищеОбщихНастроекЗагрузить(КлючОбъекта, КлючНастроек, ЗначениеПоУмолчанию = Неопределено,
	ОписаниеНастроек = Неопределено, ИмяПользователя = Неопределено) Экспорт

	Возврат StorageLoad(ХранилищеОбщихНастроек, КлючОбъекта, КлючНастроек, ЗначениеПоУмолчанию, ОписаниеНастроек,
		ИмяПользователя);

КонецФункции

// Удаляет настройку из хранилища общих настроек, как метод платформы Удалить,
// объектов СтандартноеХранилищеНастроекМенеджер или ХранилищеНастроекМенеджер.<Имя хранилища>,
// но с поддержкой длины ключа настроек более 128 символов путем хеширования части,
// которая превышает 96 символов.
// Если нет права СохранениеДанныхПользователя, удаление пропускается без ошибки.
//
// Параметры:
//   КлючОбъекта     - Строка, Неопределено - см. синтакс-помощник платформы.
//   КлючНастроек    - Строка, Неопределено - см. синтакс-помощник платформы.
//   ИмяПользователя - Строка, Неопределено - см. синтакс-помощник платформы.
//
Процедура ХранилищеОбщихНастроекУдалить(КлючОбъекта, КлючНастроек, ИмяПользователя) Экспорт

	StorageDelete(ХранилищеОбщихНастроек, КлючОбъекта, КлючНастроек, ИмяПользователя);

КонецПроцедуры

// Сохраняет настройку в хранилище системных настроек, как метод платформы Сохранить
// объекта СтандартноеХранилищеНастроекМенеджер, но с поддержкой длины ключа настроек
// более 128 символов путем хеширования части, которая превышает 96 символов.
// Если нет права СохранениеДанныхПользователя, сохранение пропускается без ошибки.
//
// Параметры:
//   КлючОбъекта       - Строка           - см. синтакс-помощник платформы.
//   КлючНастроек      - Строка           - см. синтакс-помощник платформы.
//   Настройки         - Произвольный     - см. синтакс-помощник платформы.
//   ОписаниеНастроек  - ОписаниеНастроек - см. синтакс-помощник платформы.
//   ИмяПользователя   - Строка           - см. синтакс-помощник платформы.
//   ОбновитьПовторноИспользуемыеЗначения - Булево - выполнить одноименный метод платформы.
//
Процедура ХранилищеСистемныхНастроекСохранить(КлючОбъекта, КлючНастроек, Настройки, ОписаниеНастроек = Неопределено,
	ИмяПользователя = Неопределено, ОбновитьПовторноИспользуемыеЗначения = Ложь) Экспорт

	StorageSave(ХранилищеСистемныхНастроек, КлючОбъекта, КлючНастроек, Настройки, ОписаниеНастроек,
		ИмяПользователя, ОбновитьПовторноИспользуемыеЗначения);

КонецПроцедуры

// Загружает настройку из хранилища системных настроек, как метод платформы Загрузить,
// объекта СтандартноеХранилищеНастроекМенеджер, но с поддержкой длины ключа настроек
// более 128 символов путем хеширования части, которая превышает 96 символов.
// Кроме того, возвращает указанное значение по умолчанию, если настройки не найдены.
// Если нет права СохранениеДанныхПользователя, возвращается значение по умолчанию без ошибки.
//
// В возвращаемом значении очищаются ссылки на несуществующий объект в базе данных, а именно:
// - возвращаемая ссылка заменяется на указанное значение по умолчанию;
// - из данных типа Массив ссылки удаляются;
// - у данных типа Структура и Соответствие ключ не меняется, а значение устанавливается Неопределено;
// - анализ значений в данных типа Массив, Структура, Соответствие выполняется рекурсивно.
//
// Параметры:
//   КлючОбъекта          - Строка           - см. синтакс-помощник платформы.
//   КлючНастроек         - Строка           - см. синтакс-помощник платформы.
//   ЗначениеПоУмолчанию  - Произвольный     - значение, которое возвращается, если настройки не найдены.
//                                             Если не указано, возвращается значение Неопределено.
//   ОписаниеНастроек     - ОписаниеНастроек - см. синтакс-помощник платформы.
//   ИмяПользователя      - Строка           - см. синтакс-помощник платформы.
//
// Возвращаемое значение: 
//   Произвольный - см. синтакс-помощник платформы.
//
Функция ХранилищеСистемныхНастроекЗагрузить(КлючОбъекта, КлючНастроек, ЗначениеПоУмолчанию = Неопределено,
	ОписаниеНастроек = Неопределено, ИмяПользователя = Неопределено) Экспорт

	Возврат StorageLoad(ХранилищеСистемныхНастроек, КлючОбъекта, КлючНастроек, ЗначениеПоУмолчанию,
		ОписаниеНастроек, ИмяПользователя);

КонецФункции

// Удаляет настройку из хранилища системных настроек, как метод платформы Удалить,
// объекта СтандартноеХранилищеНастроекМенеджер, но с поддержкой длины ключа настроек
// более 128 символов путем хеширования части, которая превышает 96 символов.
// Если нет права СохранениеДанныхПользователя, удаление пропускается без ошибки.
//
// Параметры:
//   КлючОбъекта     - Строка, Неопределено - см. синтакс-помощник платформы.
//   КлючНастроек    - Строка, Неопределено - см. синтакс-помощник платформы.
//   ИмяПользователя - Строка, Неопределено - см. синтакс-помощник платформы.
//
Процедура ХранилищеСистемныхНастроекУдалить(КлючОбъекта, КлючНастроек, ИмяПользователя) Экспорт

	StorageDelete(ХранилищеСистемныхНастроек, КлючОбъекта, КлючНастроек, ИмяПользователя);

КонецПроцедуры

// Сохраняет настройку в хранилище настроек данных форм, как метод платформы Сохранить,
// объектов СтандартноеХранилищеНастроекМенеджер или ХранилищеНастроекМенеджер.<Имя хранилища>,
// но с поддержкой длины ключа настроек более 128 символов путем хеширования части,
// которая превышает 96 символов.
// Если нет права СохранениеДанныхПользователя, сохранение пропускается без ошибки.
//
// Параметры:
//   КлючОбъекта       - Строка           - см. синтакс-помощник платформы.
//   КлючНастроек      - Строка           - см. синтакс-помощник платформы.
//   Настройки         - Произвольный     - см. синтакс-помощник платформы.
//   ОписаниеНастроек  - ОписаниеНастроек - см. синтакс-помощник платформы.
//   ИмяПользователя   - Строка           - см. синтакс-помощник платформы.
//   ОбновитьПовторноИспользуемыеЗначения - Булево - выполнить одноименный метод платформы.
//
Процедура ХранилищеНастроекДанныхФормСохранить(КлючОбъекта, КлючНастроек, Настройки, ОписаниеНастроек = Неопределено,
	ИмяПользователя = Неопределено, ОбновитьПовторноИспользуемыеЗначения = Ложь) Экспорт

	StorageSave(ХранилищеНастроекДанныхФорм, КлючОбъекта, КлючНастроек, Настройки, ОписаниеНастроек,
		ИмяПользователя, ОбновитьПовторноИспользуемыеЗначения);

КонецПроцедуры

// Загружает настройку из хранилища настроек данных форм, как метод платформы Загрузить,
// объектов СтандартноеХранилищеНастроекМенеджер или ХранилищеНастроекМенеджер.<Имя хранилища>,
// но с поддержкой длины ключа настроек более 128 символов путем хеширования части,
// которая превышает 96 символов.
// Кроме того, возвращает указанное значение по умолчанию, если настройки не найдены.
// Если нет права СохранениеДанныхПользователя, возвращается значение по умолчанию без ошибки.
//
// В возвращаемом значении очищаются ссылки на несуществующий объект в базе данных, а именно
// - возвращаемая ссылка заменяется на указанное значение по умолчанию;
// - из данных типа Массив ссылки удаляются;
// - у данных типа Структура и Соответствие ключ не меняется, а значение устанавливается Неопределено;
// - анализ значений в данных типа Массив, Структура, Соответствие выполняется рекурсивно.
//
// Параметры:
//   КлючОбъекта          - Строка           - см. синтакс-помощник платформы.
//   КлючНастроек         - Строка           - см. синтакс-помощник платформы.
//   ЗначениеПоУмолчанию  - Произвольный     - значение, которое возвращается, если настройки не найдены.
//                                             Если не указано, возвращается значение Неопределено.
//   ОписаниеНастроек     - ОписаниеНастроек - см. синтакс-помощник платформы.
//   ИмяПользователя      - Строка           - см. синтакс-помощник платформы.
//
// Возвращаемое значение: 
//   Произвольный - см. синтакс-помощник платформы.
//
Функция ХранилищеНастроекДанныхФормЗагрузить(КлючОбъекта, КлючНастроек, ЗначениеПоУмолчанию = Неопределено,
	ОписаниеНастроек = Неопределено, ИмяПользователя = Неопределено) Экспорт

	Возврат StorageLoad(ХранилищеНастроекДанныхФорм, КлючОбъекта, КлючНастроек, ЗначениеПоУмолчанию,
		ОписаниеНастроек, ИмяПользователя);

КонецФункции

// Удаляет настройку из хранилища настроек данных форм, как метод платформы Удалить,
// объектов СтандартноеХранилищеНастроекМенеджер или ХранилищеНастроекМенеджер.<Имя хранилища>,
// но с поддержкой длины ключа настроек более 128 символов путем хеширования части,
// которая превышает 96 символов.
// Если нет права СохранениеДанныхПользователя, удаление пропускается без ошибки.
//
// Параметры:
//   КлючОбъекта     - Строка, Неопределено - см. синтакс-помощник платформы.
//   КлючНастроек    - Строка, Неопределено - см. синтакс-помощник платформы.
//   ИмяПользователя - Строка, Неопределено - см. синтакс-помощник платформы.
//
Процедура ХранилищеНастроекДанныхФормУдалить(КлючОбъекта, КлючНастроек, ИмяПользователя) Экспорт

	StorageDelete(ХранилищеНастроекДанныхФорм, КлючОбъекта, КлючНастроек, ИмяПользователя);

КонецПроцедуры

#КонецОбласти

#Область Алгоритмы

Функция ВыполнитьАлгоритм(АлгоритмСсылка, ВходящиеПараметры = Неопределено, ОшибкаВыполнения = Ложь,
	СообщениеОбОшибке = "") Экспорт
	Возврат UT_AlgorithmsClientServer.ВыполнитьАлгоритм(АлгоритмСсылка, ВходящиеПараметры, ОшибкаВыполнения,
		СообщениеОбОшибке)
КонецФункции

Функция ПолучитьСсылкуСправочникАлгоритмы(Алгоритм) Экспорт
	Если ТипЗнч(Алгоритм) = Тип("СправочникСсылка.УИ_Алгоритмы") Тогда
		Возврат Алгоритм;
	ИначеЕсли ТипЗнч(Алгоритм) = Тип("УникальныйИдентификатор") Тогда
		Возврат Справочники.УИ_Алгоритмы.ПолучитьСсылку(Алгоритм);
	ИначеЕсли ТипЗнч(Алгоритм) = Тип("Строка") Тогда
		Если Лев(Алгоритм, 5) = "GUID_" Тогда // БСП внеш. обработка
			СтрокаУИД = Сред(Алгоритм, 6);
			ref = Справочники.УИ_Алгоритмы.ПолучитьСсылку(Новый УникальныйИдентификатор(СтрокаУИД));
			Возврат ?(ПустаяСтрока(ref.Наименование), Неопределено, ref);
		КонецЕсли;
		НайденПоНаименованию = Справочники.УИ_Алгоритмы.НайтиПоНаименованию(Алгоритм, Истина);
		Если НайденПоНаименованию = Неопределено Тогда
			Попытка
				ЧислоКод = Число(Прав(Алгоритм, 5));
				НайденПоКоду = Справочники.УИ_Алгоритмы.НайтиПоКоду(ЧислоКод);
				Если НайденПоКоду = Неопределено Тогда
					Возврат Неопределено;
				Иначе
					Возврат НайденПоКоду;
				КонецЕсли;
			Исключение
				Возврат Неопределено;
			КонецПопытки;
		Иначе
			Возврат НайденПоНаименованию;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции

#КонецОбласти

#Область ЗаписьОбъектов

Процедура УстановитьПризнакЗаписиБезАвторегистрацииИзменений(Объект, БезАвторегистрации = Ложь)
	Если Не БезАвторегистрации Тогда
		Возврат;
	КонецЕсли;

	Попытка
		Объект.ОбменДанными.Получатели.Автозаполнение= Не БезАвторегистрации;
	Исключение
				// Элемент плана обмена в 8.3.5+
	КонецПопытки;
КонецПроцедуры

Функция ВыполнитьПроцедуруПередЗаписьюОбъекта(Объект, _ТекстПроцедурыПередЗаписью)
	Результат=Истина;

	Если Не ЗначениеЗаполнено(_ТекстПроцедурыПередЗаписью) Тогда
		Возврат Результат;
	КонецЕсли;

	Попытка
		Выполнить (_ТекстПроцедурыПередЗаписью);
	Исключение
		UT_CommonClientServer.MessageToUser(СтрШаблон("Объект: %1. Ошибка при выполнении процедуры ПередЗаписью:
																	   |%2", Объект, КраткоеПредставлениеОшибки(
			ИнформацияОбОшибке())));
		Результат=Ложь;
		;
	КонецПопытки;

	Возврат Результат;
КонецФункции

Функция ЗаписатьОбъектВБазу(Объект, ПараметрыЗаписи, Знач Действие = "Запись", Знач РежимЗаписи = Неопределено,
	ЗаменаСсылок = Ложь) Экспорт

	Если ПараметрыЗаписи.ПривелигированныйРежим Тогда
		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;

	Если ПараметрыЗаписи.ЗаписьВРежимеЗагрузки Тогда
		Объект.ОбменДанными.Загрузка = Истина;
	КонецЕсли;

	УстановитьПризнакЗаписиБезАвторегистрацииИзменений(Объект, ПараметрыЗаписи.БезАвторегистрацииИзменений);

	Если ПараметрыЗаписи.ИспользоватьДопСвойства И ПараметрыЗаписи.ДополнительныеСвойства.Количество() > 0 Тогда
		Для Каждого КлючЗначение Из ПараметрыЗаписи.ДополнительныеСвойства Цикл
			Объект.ДополнительныеСвойства.Вставить(КлючЗначение.Ключ, КлючЗначение.Значение);
		КонецЦикла;
	КонецЕсли;

	Если ПараметрыЗаписи.ИспользоватьПроцедуруПередЗаписью Тогда
		Если Не ВыполнитьПроцедуруПередЗаписьюОбъекта(Объект, ПараметрыЗаписи.ПроцедураПередЗаписью) Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;

	Результат=Истина;
	Попытка
		Если Действие = "Запись" Тогда

			Если РежимЗаписи <> Неопределено Тогда
				Объект.Записать(РежимЗаписи);
			Иначе
				Объект.Записать();
			КонецЕсли;

		ИначеЕсли Действие = "УстановитьПометкуУдаления" Тогда
			ВключаяПодчиненные=Ложь;
			Если ЗаменаСсылок Тогда
				МетаданныеОбъекта = Объект.Метаданные();
				Если ЭтоСправочник(МетаданныеОбъекта) Или ЭтоПланВидовХарактеристик(МетаданныеОбъекта) Или ЭтоПланСчетов(
				МетаданныеОбъекта) Тогда
					ВключаяПодчиненные=Ложь;
				КонецЕсли;
			КонецЕсли;
			Объект.УстановитьПометкуУдаления(Истина, ВключаяПодчиненные);

		ИначеЕсли Действие = "СнятьПометкуУдаления" Тогда
			Объект.УстановитьПометкуУдаления(Ложь);
		ИначеЕсли Действие = "НепосредственноеУдаление" Тогда

			Объект.Удалить();

		КонецЕсли;

	Исключение
		UT_CommonClientServer.MessageToUser(КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		Результат=Ложь;
	КонецПопытки;

	Если ПараметрыЗаписи.ПривелигированныйРежим Тогда
		УстановитьПривилегированныйРежим(Ложь);
	КонецЕсли;

	Возврат Результат;
КонецФункции
#КонецОбласти

#Region EnglishCode
    #Region ProgramInterface
	Функция WriteObjectToDB(Object, WriterSettings, Val Action = "Write", Val WiteMode = Undefined,
	ReplaceRefs = False) Экспорт

    ЗаменаСсылок = 	ReplaceRefs;
 
	Result = ЗаписатьОбъектВБазу(Object, WriterSettings, , ,ЗаменаСсылок = Ложь);

	Возврат Result;
КонецФункции
		#EndRegion
#EndRegion
