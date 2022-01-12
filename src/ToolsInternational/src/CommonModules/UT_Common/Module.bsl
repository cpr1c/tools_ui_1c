///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////
#Region ProgramInterface

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
		Module = Eval(Name); 
	ElsIf StrOccurrenceCount(Name, ".") = 1 Then
		Return ServerManagerModule(Name);
	Else
		Module = Undefined;
	EndIf;
	
//	If TypeOf(Module) <> Type("CommonModule") Then
//	Raise StrTemplate(
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
		Raise StrTemplate(
			NStr("ru = 'Объект метаданных ""%1"" не найден,
			           |либо для него не поддерживается получение модуля менеджера.'; 
			           |en = 'Metadata object ""%1"" is not found
			           |or it does not support getting manager modules.'"),
			Name);
	EndIf;

	Module = Eval(Name); 

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

// Executes the export procedure of Object by the name
// When enabling security profiles, to call the Execute() operator
// switching to safe mode with the security profile used for the information base
// is used (if no other safe mode was set higher up the stack).
// Parameters:
// 		Object - Arbitrary - object of the 1C Script:An object containing methods (for example, a processing object).
// 		MethodName - String - the name of the export procedure of the processing object module
//      Parameters - Array - parameters are passed to the procedure <Procedure Name>  in the order of the array elements.
		
Procedure ExecuteObjectMethod(Val Object, Val MethodName, Val Parameters = Undefined) Export
	
	// Check  that Method Name is Correct.
	Try
		//@skip-warning
		Test = New Structure(MethodName, MethodName);
	Except
		Raise StrTemplate(
			NStr("ru = 'Некорректное значение параметра MethodName (%1) в Common.ExecuteObjectMethod';en = 'Invalid parameter value MethodName (%1) In Common.ExecuteObjectMethod'"),
			MethodName);
	EndTry;
	
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

	Execute "Object." + MethodName + "(" + ParametersString + ")";

EndProcedure

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

// Checks whether the passed ProcedureName is the name of a configuration export procedure.
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
			NStr("ru = 'Неправильный формат параметра ProcedureName (передано значение: ""%1"") в Common.ExecuteConfigurationMethod'; 
				|en = 'Invalid format of ProcedureName parameter (passed value: ""%1"") in Common.ExecuteConfigurationMethod.'"),
				ProcedureName);
	EndIf;

	ObjectName = NameParts[0];
	If NameParts.Count() = 2 AND Metadata.CommonModules.Find(ObjectName) = Undefined Then
		Raise StrTemplate(
			NStr("ru = 'Неправильный формат параметра ProcedureName (передано значение: ""%1"") в Common.ExecuteConfigurationMethod:
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
				NStr("ru = 'Неправильный формат параметра ProcedureName (передано значение: ""%1"") в Common.ExecuteConfigurationMethod:
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
			NStr("ru = 'Неправильный формат параметра ProcedureName (передано значение: ""%1"") в Common.ExecuteConfigurationMethod:
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
//  String - String -  string of any number of characters.
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
			NStr("ru = 'Неверный первый параметр Ref в функции Common.ObjectAttributesValues:
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
			Raise NStr("ru = 'Неверный первый параметр Ref в функции Common.ObjectAttributesValues: 
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
						NStr("ru = 'Неверный второй параметр Attributes в функции Common.ObjectAttributesValues: %1'; en = 'Invalid value of the Attributes parameter, function Common.ObjectAttributesValues: %1.'"),
						Result.ErrorDescription);
				EndIf;
				
				// Cannot identify the error. Forwarding the original error.
				Raise;
			
			EndTry;
		EndDo;
	Else
		Raise СтрШаблон(
			NStr("ru = 'Неверный тип второго параметра Attributes в функции Common.ObjectAttributesValues: %1'; en = 'Invalid value type for the Attributes parameter, function Common.ObjectAttributesValues: %1.'"), 
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
				NStr("ru = 'Неверный второй параметр Attributes в функции Common.ObjectAttributesValues: %1'; en = 'Invalid value of the Attributes parameter, function Common.ObjectAttributesValues: %1.'"), 
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
			NStr("ru = 'Неверный второй параметр AttributeName в функции Common.ObjectAttributeValue: 
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
			StrTemplate(
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
			ErrorText = ErrorText + Chars.LF + StrTemplate(
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


#Region WorkWithUniversalToolsForm

Procedure AddToCommonCommandsCommandBar(Form, FormMainCommandBar)
	If Form.CommandBarLocation=FormItemCommandBarLabelLocation.None 
		And FormMainCommandBar=Undefined Then
		Return;
	Endif;

	If FormMainCommandBar=Undefined Then
		CommandBar= Form.CommandBar;
	Else
		CommandBar=FormMainCommandBar;
	EndIf;
	
	CommandDescription = UT_Forms.ButtonCommandNewDescription();
	CommandDescription.Name = "УИ_ОткрытьНовуюФормуИнструмента";
	CommandDescription.CommandName = CommandDescription.Name;
	CommandDescription.Action="Подключаемый_ВыполнитьОбщуюКомандуИнструментов";
	CommandDescription.ItemParent=CommandBar;
	CommandDescription.Picture = БиблиотекаКартинок.НовоеОкно;
	CommandDescription.Representation = ОтображениеКнопки.Картинка;
	CommandDescription.ToolTip = "Открывает еще одну пустую форму текущего инструмента";
	CommandDescription.Title = "Открыть новую форму";
	UT_Forms.CreateCommandByDescription(Form, CommandDescription);
	UT_Forms.CreateButtonByDescription(Form, CommandDescription);
EndProcedure

Procedure ToolFormOnCreateAtServer(Form, Cancel, StandardProcessing, FormMainCommandBar = Undefined) Export
	AddToCommonCommandsCommandBar(Form, FormMainCommandBar);
EndProcedure

#EndRegion

#Region UniversalToolsSettings


#EndRegion

#EndRegion

// Returns an exception when searching for object usage locations.
//
// Returns:
//   Map - reference search exceptions by metadata objects.
//       * Key - MetadataObject - the metadata object to apply exceptions to.
//       * Value - String, Array - descriptions of excluded attributes.
//           If "*", all the metadata object attributes are excluded.
//           If a string array, contains the relative names of the excluded attributes.
//
Function RefSearchExclusions() Export

	SearchExceptionsIntegration = New Array;

//	ModuleSSLSubsystemsIntegration=CommonModule("SSLSubsystemsIntegration");
//	If ModuleSSLSubsystemsIntegration <> Undefined Then
//		ModuleSSLSubsystemsIntegration.OnAddReferenceSearchExceptions(OnAddReferenceSearchExceptions);
//	Endif;

	SearchExceptions = New Array;
//	ModuleCommonOverridable=CommonModule("CommonOverridable");
//	If ModuleCommonOverridable <> Undefined Then
//		ModuleCommonOverridable.OnAddReferenceSearchExceptions(SearchExceptions);
//	EndIf;

	UT_CommonClientServer.SupplementArray(SearchExceptions, SearchExceptionsIntegration);

	Result = New Map;
	For Each SearchException In SearchExceptions Do
		// Defining the full name of the attribute and the metadata object that owns the attribute.
		If TypeOf(SearchException) = Type("String") Then
			FullName          = SearchException;
			SubstringsArray     = StrSplit(FullName, ".");
			SubstringCount = SubstringsArray.Count();
			MetadataObject   = Metadata.FindByFullName(SubstringsArray[0] + "." + SubstringsArray[1]);
		Else
			MetadataObject   = SearchException;
			FullName          = MetadataObject.FullName();
			SubstringsArray     = StrSplit(FullName, ".");
			SubstringCount = SubstringsArray.Count();
			If SubstringCount > 2 Then
				While True Do
					Parent = MetadataObject.Parent();
					If TypeOf(Parent) = Type("ConfigurationMetadataObject") Then
						Break;
					Else
						MetadataObject = Parent;
					EndIf;
				EndDo;
			EndIf;
		EndIf;
		// Registration.
		If SubstringCount < 4 Then
			Result.Insert(MetadataObject, "*");
		Else
			PathsToAttributes = Result.Get(MetadataObject);
			If PathsToAttributes = "*" Then
				Continue; // The whole metadata object is excluded.
			ElsIf PathsToAttributes = Undefined Then
				PathsToAttributes = New Array;
				Result.Insert(MetadataObject, PathsToAttributes);
			EndIf;
			// The attribute format:
			//   "<MOType>.<MOName>.<TabularSectionOrAttributeType>.<TabularPartOrAttributeName>[.<AttributeType>.<TabularPartName>]".
			//   Examples:
			//     "InformationRegister.ObjectVersions.Attribute.VersionAuthor",
			//     "Document._DemoSalesOrder.TabularPart.SalesProformaInvoice.Attribute.ProformaInvoice",
			//     "ChartOfCalculationTypes._DemoWages.StandardTabularSection.BaseCalculationTypes.StandardAttribute.CalculationType".
			// The relative path to an attribute must conform to query condition text format:
			//   "<TabularPartOrAttributeName>[.<TabularPartAttributeName>]".
			If SubstringCount = 4 Then
				RelativePathToAttribute = SubstringsArray[3];
			Else
				RelativePathToAttribute = SubstringsArray[3] + "." + SubstringsArray[5];
			EndIf;
			PathsToAttributes.Add(RelativePathToAttribute);
		EndIf;
	EndDo;
	Return Result;
	
EndFunction

// Connects an add-in based on Native API and COM technologies.
// The add-inn must be stored in the configuration template in as a ZIP file.
//
// Parameters:
//  ID - String - the add-in identification code.
//  FullTemplateName - String - full name of the configuration template that stores the ZIP file.
//
// Returns:
//  AddIn, Undefined - an instance of the add-in or Undefined if failed to create one.
//
// Example:
//
//  AttachableModule = Common.AttachAddInFromTemplate(
//      "CNameDecl",
//      "CommonTemplate.FullNameDeclensionComponent");
//
//  If AttachableModule <> Undefined Then
//            // AttachableModule contains the instance of the attached add-in.
//  EndIf.
//
//  AttachableModule = Undefined;
//
Function AttachAddInFromTemplate(ID, FullTemplateName) Export

	AttachableModule = Undefined;
	
	If Not TemplateExists(FullTemplateName) Then 
		Raise StrTemplate(
			NStr("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на сервере
			           |из %2
			           |по причине:
			           |Подключение на сервере не из макета запрещено'; 
			           |en = 'Cannot attach add-in ""%1"" on the server
			           |from %2.
			           |Reason:
			           |On the server, add-ins can only be attached from templates.'"),
			ID,
			FullTemplateName);
	EndIf;

		Location = FullTemplateName;
	SymbolicName = ID + "SymbolicName";
	
	If AttachAddIn(Location, SymbolicName) Then
		
		Try
			AttachableModule = New("AddIn." + SymbolicName + "." + ID);
			If AttachableModule = Undefined Then 
				Raise NStr("ru = 'Оператор Новый вернул Неопределено'; en = 'The New operator returned Undefined.'");
			EndIf;
		Except
			AttachableModule = Undefined;
			ErrorText = BriefErrorDescription(ErrorInfo());
		EndTry;

		If AttachableModule = Undefined Then

			ErrorText = StrTemplate(
					NStr("ru = 'Не удалось создать объект внешней компоненты ""%1"", подключенной на сервере
				           |из макета ""%2"",
				           |по причине:
				           |%3'; 
				           |en = 'Cannot create an object for add-in ""%1"" that was attached on the server
				           |from template ""%2.""
				           |Reason:
				           |%3'"),
				ID,
				Location,
				ErrorText);

			WriteLogEvent(
				NStr("ru = 'Подключение внешней компоненты на сервере'; en = 'Attaching add-in on the server'",					
				UT_CommonClientServer.DefaultLanguageCode()),EventLogLevel.Error,,,ErrorText);

		EndIf;

	Else

		ErrorText = StrTemplate(
			NStr("ru = 'Не удалось подключить внешнюю компоненту ""%1"" на сервере
			           |из макета ""%2""
			           |по причине:
			           |Метод ПодключитьВнешнююКомпоненту вернул Ложь.'; 
			           |en = 'Cannot attach add-in ""%1"" on the server
			           |from template ""%2.""
			           |Reason:
			           |Method AttachAddInSSL returned False.'"),
			ID,
			Location);

		WriteLogEvent(
			NStr("ru = 'Подключение внешней компоненты на сервере'; en = 'Attaching add-in on the server'",
			UT_CommonClientServer.DefaultLanguageCode()),
			EventLogLevel.Error,,,
			ErrorText);

	EndIf;
	
	Return AttachableModule;
	
EndFunction

// Returns subject details in the string format.
// 
// Parameters:
//  ReferenceToSubject - AnyRef - a reference object.
//
// Returns:
//   String - the subject presentation.
// 
Function SubjectString(ReferenceToSubject) Export

	Result = "";
	//@skip-warning
	If ReferenceToSubject = Undefined Or ReferenceToSubject.IsEmpty() Then
		Result = NStr("ru = 'не задан'; en = 'not specified'");
	ElsIf Metadata.Documents.Contains(ReferenceToSubject.Metadata()) Or Metadata.Enums.Contains(ReferenceToSubject.Metadata()) Then
		Result = String(ReferenceToSubject);
	Else
		//@skip-warning	
		ObjectPresentation = ReferenceToSubject.Metadata().ObjectPresentation;
		If IsBlankString(ObjectPresentation) Then
			//@skip-warning
			ObjectPresentation = ReferenceToSubject.Metadata().Presentation();
		EndIf;
			Result = StrTemplate("%1 (%2)", String(ReferenceToSubject), ObjectPresentation);
	EndIf;
	
	Return Result;
EndFunction

Procedure RegisterReplacementError(Result, Val Ref, Val ErrorDescription)
	
	Result.HasErrors = True;
	
	String = Result.Errors.Add();
	String.Ref = Ref;
	String.ErrorObjectPresentation = ErrorDescription.ErrorObjectPresentation;
	String.ErrorObject               = ErrorDescription.ErrorObject;
	String.ErrorText                = ErrorDescription.ErrorText;
	String.ErrorType                  = ErrorDescription.ErrorType;
	
EndProcedure

Function ReplacementErrorDescription(Val ErrorType, Val ErrorObject, Val ErrorObjectPresentation, Val ErrorText)
	Result = New Structure;
	
	Result.Insert("ErrorType",                  ErrorType);
	Result.Insert("ErrorObject",               ErrorObject);
	Result.Insert("ErrorObjectPresentation", ErrorObjectPresentation);
	Result.Insert("ErrorText",                ErrorText);
	
	Return Result;
EndFunction

// Returns a type description that includes all configuration reference types.
//
// Returns:
//  TypesDescription - all reference types in the configuration.

Function AllRefsTypeDescription() Export

	Return UT_CommonCached.AllRefsTypeDescription();

EndFunction

#Region ObjectsComparison

Procedure AddObjectToComparingObjectsArray(ObjectsArray, ObjectRef)
	If ObjectsArray.Find(ObjectRef) = Undefined Then
		ObjectsArray.Add(ObjectRef);
	EndIf;
EndProcedure

Function ObjectsToCompareSettingsKey() Export
	Return "ObjectsToCompare";
EndFunction

Procedure AddObjectsArrayToCompare(Objects) Export
	ObjectsArrayToCompare=ObjectsAddedToTheComparison();

	If TypeOf(Objects) = Type("Array") Then
		For Each Itm In Objects Do
			AddObjectToComparingObjectsArray(ObjectsArrayToCompare, Itm);
		EndDo;
	ElsIf TypeOf(Objects) = Type("ValueList") Then
		For Each Itm In Objects Do
			AddObjectToComparingObjectsArray(ObjectsArrayToCompare, Itm.Value);
		EndDo;
	Else
		AddObjectToComparingObjectsArray(ObjectsArrayToCompare, Objects);
	Endif;

	UT_Common.SystemSettingsStorageSave(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(), ObjectsToCompareSettingsKey(),
		ObjectsArrayToCompare);

EndProcedure

Function ObjectsAddedToTheComparison() Export
	ObjectKey=UT_CommonClientServer.ObjectKeyInSettingsStorage();
	SettingsKey=ObjectsToCompareSettingsKey();

	ObjectsArrayToCompare=SystemSettingsStorageLoad(ObjectKey, SettingsKey, , , UserName());
	If ObjectsArrayToCompare = Undefined Then
		ObjectsArrayToCompare=New Array;
	Endif;

	Return ObjectsArrayToCompare;
EndFunction

Procedure ClearObjectsAddedToTheComparison() Export
	UT_Common.SystemSettingsStorageSave(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(), ObjectsToCompareSettingsKey(), New Array);
EndProcedure

#EndRegion

#Region AdditionalReportsAndDataProcessorsDebugSettings

Function KeyOfAdditionalReportsAndDataProcessorsDebugSettings() Export
	Return "AdditionalReportsAndDataProcessorsDebugSettings";
EndFunction

Function NewStructureOfAdditionalDataProcessorDebugSettings ()  Export
	Structure=New Structure;
	Structure.Insert("DebugEnabled", False);
	Structure.Insert("FileNameOnServer", "");
	Structure.Insert("User", Undefined);
	Return Structure;
EndFunction

Function AdditionalDataProcessorDebugSettings(AdditionalDataProcessor) Экспорт
	ObjectKey=UT_CommonClientServer.ObjectKeyInSettingsStorage();
	SettingsKey=KeyOfAdditionalReportsAndDataProcessorsDebugSettings();

	SettingsMap=SystemSettingsStorageLoad(ObjectKey, SettingsKey);
	If SettingsMap = Undefined Then
		SettingsMap=New Map;
	EndIf;

	SettingsStructure=NewStructureOfAdditionalDataProcessorDebugSettings();
	SavedSetting = SettingsMap[AdditionalDataProcessor];
	If SavedSetting <> Undefined Then
		FillPropertyValues(SettingsStructure, SavedSetting);
	EndIf;

	Возврат SettingsStructure;
КонецФункции

Procedure SaveAdditionalDataProcessorDebugSettings(AdditionalDataProcessor, Settings) Export
	ObjectKey=UT_CommonClientServer.ObjectKeyInSettingsStorage();
	SettingsKey=KeyOfAdditionalReportsAndDataProcessorsDebugSettings();

	SettingsMap=SystemSettingsStorageLoad(ObjectKey, SettingsKey);
	If SettingsMap = Undefined Then
		SettingsMap=New Map;
	EndIf;

	SettingsMap.Insert(AdditionalDataProcessor, Settings);

	UT_Common.SystemSettingsStorageSave(
		ObjectKey, SettingsKey, SettingsMap);

EndProcedure

#EndRegion

#Region DataInDB

////////////////////////////////////////////////////////////////////////////////
// Common procedures and functions to manage infobase data.

// Replaces references in all data. There is an option to delete all unused references after the replacement.
// References are replaced in transactions by the object to be changed and its relations but not by the analyzing reference.
// When called in a shared session, does not find references in separated areas.
//
// Parameters:
//   ReplacementPairs - Map - replacement pairs.
//       * Key     - AnyRef - a reference to be replaced.
//       * Value - AnyRef - a reference to use as a replacement.
//       Self-references and empty search references are ignored.
//   
//   Parameters - Structure - Optional. Replacement parameters.
//       
//       * DeletionMethod - String - optional. What to do with the duplicate after a successful replacement.
//           ""                - default. Do nothing.
//           "Mark"         - mark for deletion.
//           "Directly" - delete directly.
//       
//       * ConsiderAppliedRules - Boolean - optional. ReplacementPairs parameter check mode.
//           True - default. Check each replacement pair by calling
//                    the CanReplaceItems function from the manager module.
//           False   - do not check the replacement pairs.
//       
//         * WriteParameters.WritingInLoadMode  - Булево - необязательный. Режим записи мест использования при замене дублей на оригиналы.
//           Истина - по умолчанию. Места использования дублей записываются в режиме ОбменДанными.Загрузка = Ложь.
//           Ложь   - запись ведется в режиме ОбменДанными.Загрузка = Истина.
//                
//       * ReplacePairsInTransaction - Boolean - optional. Defines transaction size.
//           True - default. Transaction covers all the instances of a duplicate. Can be very 
//                    resource-demanding in case of a large number of usage instances.
//           False   - use a separate transaction to replace each usage instance.
//       
//       * WriteParameters.WriteInPrivilegedMode - Boolean - optional. A flag that shows whether privileged mode must be set.
//           False   - default value. Write with the current rights.
//           True - write in privileged mode.
//
// Returns:
//   ValueTable - unsuccessful replacements (errors).
//       * Reference - AnyRef - a reference that was replaced.
//       * ErrorObject - Arbitrary - object that has caused an error.
//       * ErrorObjectPresentation - String - string representation of an error object.
//       * ErrorType - String - an error type:
//           "LockError" - some objects were locked during the reference processing.
//           "DataChanged" - data was changed by another user during the processing.
//           "WritingError"      - cannot write the object, or the CanReplaceItems method returned a failure.
//           "DeletionError"    - cannot delete the object.
//           "UnknownData" - unexpected data was found during the replacement process. The replacement failed.
//       * ErrorText - String - a detailed error description.
//
Function ReplaceReferences(Val ReplacementPairs, Val Parameters = Undefined) Export
	
	StringType = New TypeDescription("String");
	
	ReplacementErrors = New ValueTable;
	ReplacementErrors.Columns.Add("Ref");
	ReplacementErrors.Columns.Add("ErrorObject");
	ReplacementErrors.Columns.Add("ErrorObjectPresentation", StringType);
	ReplacementErrors.Columns.Add("ErrorType", StringType);
	ReplacementErrors.Columns.Add("ErrorText", StringType);
	
	ReplacementErrors.Indexes.Add("Ref");
	ReplacementErrors.Indexes.Add("Ref, ErrorObject, ErrorType");
	
	Result = New Structure;
	Result.Insert("HasErrors", False);
	Result.Insert("Errors", ReplacementErrors);
	
	ExecutionParameters = New Structure;
	ExecutionParameters.Insert("DeleteDirectly",     False);
	ExecutionParameters.Insert("MarkForDeletion",         False);
	ExecutionParameters.Insert("ConsiderAppliedRules", False);
	ReplacePairsInTransaction = True;

	WriteParameters=UT_CommonClientServer.WriteParametersStructureByDefaults();
	
	// Passed values.
	ParameterValue = UT_CommonClientServer.StructureProperty(Parameters, "DeletionMethod");
	If ParameterValue = "Directly" Then
		ExecutionParameters.DeleteDirectly = True;
		ExecutionParameters.MarkForDeletion     = False;
	ElsIf ParameterValue = "Check" Then
		ExecutionParameters.DeleteDirectly = False;
		ExecutionParameters.MarkForDeletion     = True;
	EndIf;

	ParameterValue = UT_CommonClientServer.StructureProperty(Parameters, "ReplacePairsInTransaction");
	If TypeOf(ParameterValue) = Type("Boolean") Then
		ReplacePairsInTransaction = ParameterValue;
	EndIf;;

	ParameterValue = UT_CommonClientServer.StructureProperty(Parameters, "ConsiderAppliedRules");
	If TypeOf(ParameterValue) = Type("Boolean") Then
		ExecutionParameters.ConsiderAppliedRules = ParameterValue;
	EndIf;

	ParameterValue = UT_CommonClientServer.StructureProperty(Parameters, "WriteParameters");
	If TypeOf(ParameterValue) = Type("Structure") then
		FillPropertyValues(WriteParameters, ParameterValue);
	EndIf;
	ExecutionParameters.Insert("WriteParameters", WriteParameters);
	If ReplacementPairs.Count() = 0 Then
		Return Result.Errors;
	EndIf;

	Duplicates = New Array;
	For Each KeyValue In ReplacementPairs Do
		Duplicate = KeyValue.Key;
		Original = KeyValue.Value;
		If Duplicate = Original Or Duplicate.IsEmpty() Then
			Continue; // Not replacing self-references and empty references.
		EndIf;
		Duplicates.Add(Duplicate);
	// Skipping intermediate replacements to avoid building a graph (if A->B and B->C, replacing A->C).
		OriginalOriginal = ReplacementPairs[Original];
		HasOriginalOriginal = (OriginalOriginal <> Undefined AND OriginalOriginal <> Duplicate AND OriginalOriginal <> Original);
		If HasOriginalOriginal Then
			While HasOriginalOriginal Do
				Original = OriginalOriginal;
				OriginalOriginal = ReplacementPairs[Original];
				HasOriginalOriginal = (OriginalOriginal <> Undefined AND OriginalOriginal <> Duplicate AND OriginalOriginal <> Original);
			EndDo;
			ReplacementPairs.Insert(Duplicate, Original);
		EndIf;
	EndDo;

//	If ExecutionParameters.TakeAppliedRulesIntoAccount AND SubsystemExists("StandardSubsystems.DuplicateObjectDetection") Then
//		ModuleDuplicateObjectsDetection = CommonModule("DuplicateObjectDetection");
//		Errors = ModuleDuplicateObjectsDetection.CheckCanReplaceItems(ReplacementPairs, Parameters);
//		For Each KeyValue In Errors Do
//			Duplicate = KeyValue.Key;
//			Original = ReplacementPairs[Duplicate];
//			ErrorText = KeyValue.Value;
//			Reason = ReplacementErrorDescription("WritingError", Original, SubjectString(Original), ErrorText);
//			RegisterReplacementError(Result, Duplicate, Reason);
//			
//			Index = Duplicates.Find(Duplicate);
//			If Index <> Undefined Then
//				Duplicates.Delete(Index); // skipping the problem item.
//			EndIf;
//		EndDo;
//	EndIf;

	SearchTable = UsageInstances(Duplicates);
	
	// Replacements for each object reference are executed in the following order: "Constant", "Object", "Set".
	// Blank row in this column is also a flag indicating that the replacement is not needed or already done.
	SearchTable.Columns.Add("ReplacementKey", StringType);
	SearchTable.Indexes.Add("Ref, ReplacementKey");
	SearchTable.Indexes.Add("Data, ReplacementKey");
	
	// Auxiliary data
	SearchTable.Columns.Add("DestinationRef");
	SearchTable.Columns.Add("Processed", New TypeDescription("Boolean"));
	
	// Defining the processing order and validating items that can be handled.
	Count = Duplicates.Count();
	For Number = 1 To Count Do
		ReverseIndex = Count - Number;
		Duplicate = Duplicates[ReverseIndex];
		MarkupResult = MarkUsageInstances(ExecutionParameters, Duplicate, ReplacementPairs[Duplicate], SearchTable);
		If Not MarkupResult.Success Then
			// Unknown replacement types are found, skipping the reference to prevent data incoherence.
			Duplicates.Delete(ReverseIndex);
			For Each Error In MarkupResult.MarkupErrors Do
				ErrorObjectPresentation = SubjectString(Error.Object);
				RegisterReplacementError(Result, Duplicate,
					ReplacementErrorDescription("UnknownData", Error.Object, ErrorObjectPresentation, Error.Text));
			EndDo;
		EndIf;
	EndDo;

	ExecutionParameters.Insert("ReplacementPairs",      ReplacementPairs);
	ExecutionParameters.Insert("SuccessfulReplacements", New Map);

//	If SubsystemExists("StandardSubsystems.AccessManagement") Then
//		ModuleAccessManagement = CommonModule("AccessManagement");
//		ModuleAccessManagement.DisableAccessKeysUpdate(True);
//	EndIf;

	Try
		If ReplacePairsInTransaction Then
			For Each Duplicate In Duplicates Do
				ReplaceRefUsingSingleTransaction(Result, Duplicate, ExecutionParameters, SearchTable);
			EndDo;
		Else
			ReplaceRefsUsingShortTransactions(Result, ExecutionParameters, Duplicates, SearchTable);
		EndIf;

		//If SubsystemExists("StandardSubsystems.AccessManagement") Then
		//			ModuleAccessManagement = CommonModule("AccessManagement");
		//			ModuleAccessManagement.DisableAccessKeysUpdate(False);
		//		EndIf;

	Except
		//If SubsystemExists("StandardSubsystems.AccessManagement") Then
		//			ModuleAccessManagement = CommonModule("AccessManagement");
		//			ModuleAccessManagement.DisableAccessKeysUpdate(False);
		//		EndIf;
		Raise;
	EndTry;
	
	Return Result.Errors;
EndFunction

// Retrieves all places where references are used.
// If any of the references is not used, it will not be presented in the result table.
// When called in a shared session, does not find references in separated areas.
//
// Parameters:
//     RefSet     - Array - references whose usage instances are to be found.
//     ResultAddress - String - an optional address in the temporary storage where the replacement 
//                                result copy will be stored.
// 
// Returns:
//     ValueTable - contains the following columns:
//       * Ref - AnyRef - the reference to analyze.
//       * Data - Arbitrary - the data that contains the reference to analyze.
//       * Metadata - MetadataObject - metadata for the found data.
//       * DataPresentation - String - presentation of the data containing the reference.
//       * RefType - Type - the type of reference to analyze.
//       * AuxiliaryData - Boolean - True if the data is used by the reference as auxiliary data 
//           (leading dimension, or covered by the OnAddReferenceSearchExceptions exception).
//       * IsInternalData - Boolean - the data is covered by the OnAddReferenceSearchExceptions exception.
//
Function UsageInstances(Val RefSet, Val ResultAddress = "") Export
	
	UsageInstances = New ValueTable;
	
	SetPrivilegedMode(True);
	UsageInstances = FindByRef(RefSet);
	SetPrivilegedMode(False);
	
		// UsageInstances - ValueTable - where:
	// * Ref - AnyRef - the reference to analyze.
	// * Data - Arbitrary - the data that contains the reference to analyze.
	// * Metadata - MetadataObject - metadata for the found data.
	
	UsageInstances.Columns.Add("DataPresentation", New TypeDescription("String"));
	UsageInstances.Columns.Add("RefType");
	UsageInstances.Columns.Add("UsageInstanceInfo");
	UsageInstances.Columns.Add("AuxiliaryData", New TypeDescription("Boolean"));
	UsageInstances.Columns.Add("IsInternalData", New TypeDescription("Boolean"));
	
	UsageInstances.Indexes.Add("Ref");
	UsageInstances.Indexes.Add("Data");
	UsageInstances.Indexes.Add("AuxiliaryData");
	UsageInstances.Indexes.Add("Ref, AuxiliaryData");

	RecordKeysType = RecordKeysTypeDetails();
	AllRefsType =   AllRefsTypeDescription();

	SequenceMetadata = Metadata.Sequences;
	ConstantMetadata = Metadata.Constants;
	DocumentMetadata = Metadata.Documents;
	
	RefSearchExclusions = RefSearchExclusions();

	RegisterDimensionCache = New Map;

	For Each UsageInstance In UsageInstances Do
		DataType = TypeOf(UsageInstance.Data);
		
		IsInternalData = IsInternalData(UsageInstance, RefSearchExclusions);
		IsAuxiliaryData = IsInternalData;

		If DocumentMetadata.Contains(UsageInstance.Metadata) Then
			Presentation = String(UsageInstance.Data);

		ElsIf ConstantMetadata.Contains(UsageInstance.Metadata) Then
			Presentation = UsageInstance.Metadata.Presentation() + " (" + NStr("ru = 'константа'; en = 'constant'") + ")";
			
		ElsIf SequenceMetadata.Contains(UsageInstance.Metadata) Then
			Presentation = UsageInstance.Metadata.Presentation() + " (" + NStr("ru = 'последовательность'; en = 'sequence'") + ")";
			
		ElsIf DataType = Undefined Then
			Presentation = String(UsageInstance.Data);

		ElsIf AllRefsType.ContainsType(DataType) Then
			ObjectMetaPresentation = New Structure("ObjectPresentation");
			FillPropertyValues(ObjectMetaPresentation, UsageInstance.Metadata);
			If IsBlankString(ObjectMetaPresentation.ObjectPresentation) Then
				MetaPresentation = UsageInstance.Metadata.Presentation();
			Else
				MetaPresentation = ObjectMetaPresentation.ObjectPresentation;
			EndIf;
			Presentation = String(UsageInstance.Data);
			If Not IsBlankString(MetaPresentation) Then
				Presentation = Presentation + " (" + MetaPresentation + ")";
			EndIf;

		ElsIf RecordKeysType.ContainsType(DataType) Then
			Presentation = UsageInstance.Metadata.RecordPresentation;
			If IsBlankString(Presentation) Then
				Presentation = UsageInstance.Metadata.Presentation();
			EndIf;

				DimensionsDetails = "";
			For Each KeyValue In RecordSetDimensionsDetails(UsageInstance.Metadata, RegisterDimensionCache) Do
				Value = UsageInstance.Data[KeyValue.Key];
				Details = KeyValue.Value;
				If UsageInstance.Ref = Value Then
					If Details.Master Then
						IsAuxiliaryData = True;
					EndIf;
				EndIf;
				ValueFormat = Details.Format; 
				DimensionsDetails = DimensionsDetails + ", " + Details.Presentation + " """ 
					+ ?(ValueFormat = Undefined, String(Value), Format(Value, ValueFormat)) + """";
			EndDo;

			DimensionsDetails = Mid(DimensionsDetails, 3);
			If Not IsBlankString(DimensionsDetails) Then
				Presentation = Presentation + " (" + DimensionsDetails + ")";
			EndIf;

		Else
			Presentation = String(UsageInstance.Data);
			
		EndIf;
		
		UsageInstance.DataPresentation = Presentation;
		UsageInstance.AuxiliaryData = IsAuxiliaryData;
		UsageInstance.IsInternalData = IsInternalData;
		UsageInstance.RefType = TypeOf(UsageInstance.Ref);
	EndDo;

	If Not IsBlankString(ResultAddress) Then
		PutToTempStorage(UsageInstances, ResultAddress);
	EndIf;
	
	Return UsageInstances;
EndFunction

#EndRegion
#Region AddIn

// Checking extension and configuration metadata for the template.
//
// Parameters:
//  FullTemplateName - String - template's full name.
//
// Returns:
//  Boolean - indicates whether the template exists.
//
Function TemplateExists(FullTemplateName)
	
	Template = Metadata.FindByFullName(FullTemplateName);
	If TypeOf(Template) = Type("MetadataObject") Then 
		
		Pattern = New Structure("TemplateType");
		FillPropertyValues(Pattern, Template);
		TemplateType = Undefined;
		If Pattern.Property("TemplateType", TemplateType) Then 
			Return TemplateType <> Undefined;
		EndIf;
		
	EndIf;
	
	Return False;
	
EndFunction

#EndRegion

#Region UsageInstances

Function RecordKeysTypeDetails()
	
	TypesToAdd = New Array;
	For Each Meta In Metadata.InformationRegisters Do
		TypesToAdd.Add(Type("InformationRegisterRecordKey." + Meta.Name));
	EndDo;
	For Each Meta In Metadata.AccumulationRegisters Do
		TypesToAdd.Add(Type("AccumulationRegisterRecordKey." + Meta.Name));
	EndDo;
	For Each Meta In Metadata.AccountingRegisters Do
		TypesToAdd.Add(Type("AccountingRegisterRecordKey." + Meta.Name));
	EndDo;
	For Each Meta In Metadata.CalculationRegisters Do
		TypesToAdd.Add(Type("CalculationRegisterRecordKey." + Meta.Name));
	EndDo;
	
	Return New TypeDescription(TypesToAdd); 
EndFunction

Function RecordSetDimensionsDetails(Val RegisterMetadata, RegisterDimensionCache)
	
	DimensionsDetails = RegisterDimensionCache[RegisterMetadata];
	If DimensionsDetails <> Undefined Then
		Return DimensionsDetails;
	EndIf;
	
	// Period and recorder, if any.
	DimensionsDetails = New Structure;
	
	DimensionData = New Structure("Master, Presentation, Format, Type", False);

	If Metadata.InformationRegisters.Contains(RegisterMetadata) Then
		// There might be a period.
		MetaPeriod = RegisterMetadata.InformationRegisterPeriodicity; 
		Periodicity = Metadata.ObjectProperties.InformationRegisterPeriodicity;
		
		If MetaPeriod = Periodicity.RecorderPosition Then
			DimensionData.Type           = Documents.AllRefsType();
			DimensionData.Presentation = NStr("ru='Регистратор'; en = 'Recorder'");
			DimensionData.Master       = True;
			DimensionsDetails.Insert("Recorder", DimensionData);

		ElsIf MetaPeriod = Periodicity.Year Then
			DimensionData.Type           = New TypeDescription("Date");
			DimensionData.Presentation = NStr("ru='Период'; en = 'Period'");
			DimensionData.Format        = NStr("ru = 'ДФ=''yyyy ""г.""''; ДП=''Дата не задана'''; en = 'DF=''yyyy''; DE=''No date set'''");
			DimensionsDetails.Insert("Period", DimensionData);
			
		ElsIf MetaPeriod = Periodicity.Day Then
			DimensionData.Type           = New TypeDescription("Date");
			DimensionData.Presentation = NStr("ru='Период'; en = 'Period'");
			DimensionData.Format        = NStr("ru = 'ДЛФ=D; ДП=''Дата не задана'''; en = 'DLF=D; DE=''No date set'''");
			DimensionsDetails.Insert("Period", DimensionData);
			
		ElsIf MetaPeriod = Periodicity.Quarter Then
			DimensionData.Type           = New TypeDescription("Date");
			DimensionData.Presentation = NStr("ru='Период'; en = 'Period'");
			DimensionData.Format        =  NStr("ru = 'ДФ=''к """"квартал """"yyyy """"г.""""''; ДП=''Дата не задана'''; en = 'DF=''""""Q""""q yyyy''; DE=''No date set'''");
			DimensionsDetails.Insert("Period", DimensionData);
			
		ElsIf MetaPeriod = Periodicity.Month Then
			DimensionData.Type           = New TypeDescription("Date");
			DimensionData.Presentation = NStr("ru='Период'; en = 'Period'");
			DimensionData.Format        = NStr("ru = 'ДФ=''ММММ yyyy """"г.""""''; ДП=''Дата не задана'''; en = 'DF=''MMMM yyyy''; DE=''No date set'''");
			DimensionsDetails.Insert("Period", DimensionData);
			
		ElsIf MetaPeriod = Periodicity.Second Then
			DimensionData.Type           = New TypeDescription("Date");
			DimensionData.Presentation = NStr("ru='Период'; en = 'Period'");
			DimensionData.Format        = NStr("ru = 'ДЛФ=DT; ДП=''Дата не задана'''; en = 'DLF=DT; DE=''No date set'''");
			DimensionsDetails.Insert("Period", DimensionData);
			
		EndIf;

	Else
		DimensionData.Type           = Documents.AllRefsType();
		DimensionData.Presentation = NStr("ru='Регистратор'; en = 'Recorder'");
		DimensionData.Master       = True;
		DimensionsDetails.Insert("Recorder", DimensionData);
		
	EndIf;
	
		// All dimensions.
	For Each MetaDimension In RegisterMetadata.Dimensions Do
		DimensionData = New Structure("Master, Presentation, Format, Type");
		DimensionData.Type           = MetaDimension.Type;
		DimensionData.Presentation = MetaDimension.Presentation();
		DimensionData.Master       = MetaDimension.Master;
		DimensionsDetails.Insert(MetaDimension.Name, DimensionData);
	EndDo;
	
	RegisterDimensionCache[RegisterMetadata] = DimensionsDetails;
	Return DimensionsDetails;
	
EndFunction

#EndRegion

#Region ReplaceReferences

Function MarkUsageInstances(Val ExecutionParameters, Val Ref, Val DestinationRef, Val SearchTable)
	SetPrivilegedMode(True);
	
	// Setting the order of known objects and checking whether there are unidentified ones.
	Result = New Structure;
	Result.Insert("UsageInstances", SearchTable.FindRows(New Structure("Ref", Ref)));
	Result.Insert("MarkupErrors",     New Array);
	Result.Insert("Success",              True);
	
	For Each UsageInstance In Result.UsageInstances Do
		If UsageInstance.IsInternalData Then
			Continue; // Skipping dependent data.
		EndIf;

		Information = TypeInformation(UsageInstance.Metadata, ExecutionParameters);
		If Information.Kind = "CONSTANT" Then
			UsageInstance.ReplacementKey = "Constant";
			UsageInstance.DestinationRef = DestinationRef;
			
		ElsIf Information.Kind = "SEQUENCE" Then
			UsageInstance.ReplacementKey = "Sequence";
			UsageInstance.DestinationRef = DestinationRef;
			
		ElsIf Information.Kind = "INFORMATIONREGISTER" Then
			UsageInstance.ReplacementKey = "InformationRegister";
			UsageInstance.DestinationRef = DestinationRef;
			
		ElsIf Information.Kind = "ACCOUNTINGREGISTER"
			Or Information.Kind = "ACCUMULATIONREGISTER"
			Or Information.Kind = "CALCULATIONREGISTER" Then
			UsageInstance.ReplacementKey = "RecordKey";
			UsageInstance.DestinationRef = DestinationRef;
			
		ElsIf Information.Reference Then
			UsageInstance.ReplacementKey = "Object";
			UsageInstance.DestinationRef = DestinationRef;
			
		Else
			// Unknown object for reference replacement.
			Result.Success = False;
			Text = StrTemplate(NStr("ru = 'Замена ссылок в ""%1"" не поддерживается.'; en = 'Replacement of references in ""%1"" is not supported.'"), Information.FullName);
			ErrorDescription = New Structure("Object, Text", UsageInstance.Data, Text);
			Result.MarkupErrors.Add(ErrorDescription);
		EndIf;
		
	EndDo;
	
	Return Result;
EndFunction

Procedure ReplaceRefsUsingShortTransactions(Result, Val ExecutionParameters, Val Duplicates, Val SearchTable)
	
	// Main data processor loop.
	RefFilter = New Structure("Ref, ReplacementKey");
	For Each Duplicate In Duplicates Do
		HadErrors = Result.HasErrors;
		Result.HasErrors = False;
		
		RefFilter.Ref = Duplicate;
		
		RefFilter.ReplacementKey = "Constant";
		UsageInstances = SearchTable.FindRows(RefFilter);
		For Each UsageInstance In UsageInstances Do
			ReplaceInConstant(Result, UsageInstance, ExecutionParameters, True);
		EndDo;
		
		RefFilter.ReplacementKey = "Object";
		UsageInstances = SearchTable.FindRows(RefFilter);
		For Each UsageInstance In UsageInstances Do
			ReplaceInObject(Result, UsageInstance, ExecutionParameters, True);
		EndDo;
		
		RefFilter.ReplacementKey = "RecordKey";
		UsageInstances = SearchTable.FindRows(RefFilter);
		For Each UsageInstance In UsageInstances Do
			ReplaceInSet(Result, UsageInstance, ExecutionParameters, True);
		EndDo;
		
		RefFilter.ReplacementKey = "Sequence";
		UsageInstances = SearchTable.FindRows(RefFilter);
		For Each UsageInstance In UsageInstances Do
			ReplaceInSet(Result, UsageInstance, ExecutionParameters, True);
		EndDo;
		
		RefFilter.ReplacementKey = "InformationRegister";
		UsageInstances = SearchTable.FindRows(RefFilter);
		For Each UsageInstance In UsageInstances Do
			ReplaceInInformationRegister(Result, UsageInstance, ExecutionParameters, True);
		EndDo;
		
		If Not Result.HasErrors Then
			ExecutionParameters.SuccessfulReplacements.Insert(Duplicate, ExecutionParameters.ReplacementPairs[Duplicate]);
		EndIf;
		Result.HasErrors = Result.HasErrors Or HadErrors;
		
	EndDo;
	
	// Final procedures.
	If ExecutionParameters.DeleteDirectly Then
		DeleteRefsNotExclusive(Result, Duplicates, ExecutionParameters, True);
		
	ElsIf ExecutionParameters.MarkForDeletion Then
		DeleteRefsNotExclusive(Result, Duplicates, ExecutionParameters, False);
		
	Else
		// Searching for new items.
		RepeatSearchTable = UsageInstances(Duplicates);
		AddModifiedObjectReplacementResults(Result, RepeatSearchTable);
	EndIf;
	
EndProcedure

Procedure ReplaceRefUsingSingleTransaction(Result, Val Duplicate, Val ExecutionParameters, Val SearchTable)
	SetPrivilegedMode(True);

	BeginTransaction();
	Try
		// 1. Locking all usage instances.
		ActionState = "LockError";
		Lock = New DataLock;
		
		UsageInstances = SearchTable.FindRows(New Structure("Ref", Duplicate));
		LockUsageInstances(ExecutionParameters, Lock, UsageInstances);
		Lock.Lock();
		ActionState = "";

		SetPrivilegedMode(False);

		// 2. Replacing everywhere till the first errors.
		Result.HasErrors = False;
		
		For Each UsageInstance In UsageInstances Do
			
			If UsageInstance.ReplacementKey = "Constant" Then
				ReplaceInConstant(Result, UsageInstance, ExecutionParameters, False);
			ElsIf UsageInstance.ReplacementKey = "Object" Then
				ReplaceInObject(Result, UsageInstance, ExecutionParameters, False);
			ElsIf UsageInstance.ReplacementKey = "Sequence" Then
				ReplaceInSet(Result, UsageInstance, ExecutionParameters, False);
			ElsIf UsageInstance.ReplacementKey = "RecordKey" Then
				ReplaceInSet(Result, UsageInstance, ExecutionParameters, False);
			ElsIf UsageInstance.ReplacementKey = "InformationRegister" Then
				ReplaceInInformationRegister(Result, UsageInstance, ExecutionParameters, False);
			EndIf;
			
			If Result.HasErrors Then
				RollbackTransaction();
				Return;
			EndIf;
			
		EndDo;
		
		// 3. Delete.
		ReplacementsToProcess = New Array;
		ReplacementsToProcess.Add(Duplicate);
		
		If ExecutionParameters.DeleteDirectly Then
			DeleteRefsNotExclusive(Result, ReplacementsToProcess, ExecutionParameters, True);
			
		ElsIf ExecutionParameters.MarkForDeletion Then
			DeleteRefsNotExclusive(Result, ReplacementsToProcess, ExecutionParameters, False);
			
		Else
			// Searching for new items.
			RepeatSearchTable = UsageInstances(ReplacementsToProcess);
			AddModifiedObjectReplacementResults(Result, RepeatSearchTable);
		EndIf;
		
		If Result.HasErrors Then
			RollbackTransaction();
			Return;
		EndIf;
		
		ExecutionParameters.SuccessfulReplacements.Insert(Duplicate, ExecutionParameters.ReplacementPairs[Duplicate]);
		CommitTransaction();

	Except
		RollbackTransaction();
		If ActionState = "LockError" Then
			ErrorPresentation = DetailErrorDescription(ErrorInfo());
			Error = StrTemplate(NStr("ru = 'Не удалось заблокировать все места использования %1:'; en = 'Cannot lock all usage instances of %1:'") 
				+ Chars.LF + ErrorPresentation, Duplicate);
			RegisterReplacementError(Result, Duplicate, 
				ReplacementErrorDescription("LockError", Undefined, Undefined, Error));
		Else
			Raise;	
		EndIf;
	EndTry
	
EndProcedure

Procedure ReplaceInConstant(Result, Val UsageInstance, Val WriteParameters, Val InnerTransaction = True)
	
	SetPrivilegedMode(True);
	
	Data = UsageInstance.Data;
	Meta   = UsageInstance.Metadata;
	
	DataPresentation = String(Data);
	
	// Performing all replacement of the data in the same time.
	Filter = New Structure("Data, ReplacementKey", Data, "Constant");
	RowsToProcess = UsageInstance.Owner().FindRows(Filter);
	// Marking as processed.
	For Each Row In RowsToProcess Do
		Row.ReplacementKey = "";
	EndDo;

	ActionState = "";
	Error = "";
	If InnerTransaction Then
		BeginTransaction();
	EndIf;

	Try
		If InnerTransaction Then
			Lock = New DataLock;
			Lock.Add(Meta.FullName());
			Try
				Lock.Lock();
			Except
				Error = StrTemplate(NStr("ru = 'Не удалось заблокировать константу %1'; en = 'Cannot lock the constant %1.'"), 
					DataPresentation);
				ActionState = "LockError";
				Raise;
			EndTry;
		EndIf;

		Manager = Constants[Meta.Name].CreateValueManager();
		Manager.Read();
		
		ReplacementPerformed = False;
		For Each Row In RowsToProcess Do
			If Manager.Value = Row.Ref Then
				Manager.Value = Row.DestinationRef;
				ReplacementPerformed = True;
			EndIf;
		EndDo;
		
		If Not ReplacementPerformed Then
			If InnerTransaction Then
				RollbackTransaction();
			EndIf;	
			Return;
		EndIf;	
		 
		// Attempting to save.
		If Not WriteParameters.WriteInPrivilegedMode Then
			SetPrivilegedMode(False);
		EndIf;

		Попытка
			WriteObjectOnRefsReplace(Manager, WriteParameters);
		Except
			ErrorDescription = BriefErrorDescription(ErrorInfo());
			Error = StrTemplate(NStr("ru = 'Не удалось записать %1 по причине: %2'; en = 'Cannot save %1. Reason: %2'"), 
				DataPresentation, ErrorDescription);
			ActionState = "WritingError";
			Raise;
		EndTry;
		
		If Not WriteParameters.WriteInPrivilegedMode Then
			SetPrivilegedMode(True);
		EndIf;
			
		If InnerTransaction Then
			CommitTransaction();
		EndIf;	
	Except
		If InnerTransaction Then
			RollbackTransaction();
		EndIf;
		WriteLogEvent(RefReplacementEventLogMessageText(), EventLogLevel.Error,
			Meta,, DetailErrorDescription(ErrorInfo()));
		If ActionState = "WritingError" Then
			For Each Row In RowsToProcess Do
				RegisterReplacementError(Result, Row.Ref, 
					ReplacementErrorDescription("WritingError", Data, DataPresentation, Error));
			EndDo;
		Else		
			RegisterReplacementError(Result, Row.Ref, 
				ReplacementErrorDescription(ActionState, Data, DataPresentation, Error));
		EndIf;		
	EndTry;
	
EndProcedure

Procedure ReplaceInObject(Result, Val UsageInstance, Val ExecutionParameters, Val InnerTransaction = True)
	
	SetPrivilegedMode(True);
	
	Data = UsageInstance.Data;
	
	// Performing all replacement of the data in the same time.
	Filter = New Structure("Data, ReplacementKey", Data, "Object");
	RowsToProcess = UsageInstance.Owner().FindRows(Filter);
	
	DataPresentation = SubjectString(Data);
	ActionState = "";
	ErrorText = "";
	If InnerTransaction Then
		BeginTransaction();
	EndIf;

	Try
		
		If InnerTransaction Then
			Lock = New DataLock;
			LockUsageInstance(ExecutionParameters, Lock, UsageInstance);
			Try
				Lock.Lock();
			Except
				ActionState = "LockError";
				ErrorText = StrTemplate(
					NStr("ru = 'Не удалось заблокировать объект ""%1"":
					|%2'; 
					|en = 'Cannot lock object %1:
					|%2'"),
					DataPresentation,
					BriefErrorDescription(ErrorInfo()));
				Raise;
			EndTry;
		EndIf;

		WritingObjects = ModifiedObjectsOnReplaceInObject(ExecutionParameters, UsageInstance, RowsToProcess);
		
		// Attempting to save. The object goes last.
		If Not ExecutionParameters.WriteInPrivilegedMode Then
			SetPrivilegedMode(False);
		EndIf;

		Try
			If ExecutionParameters.IncludeBusinessLogic Then
				// First writing iteration without the control to fix loop references.
				NewExecutionParameters = UT_CommonClientServer.CopyRecursively(ExecutionParameters);
				NewExecutionParameters.IncludeBusinessLogic = False;
				For Each KeyValue In WritingObjects Do
					WriteObjectOnRefsReplace(KeyValue.Key, NewExecutionParameters);
				EndDo;
				// Second writing iteration with the control.
				NewExecutionParameters.IncludeBusinessLogic = True;
				For Each KeyValue In WritingObjects Do
					WriteObjectOnRefsReplace(KeyValue.Key, NewExecutionParameters);
				EndDo;
			Else
				// Writing without the business logic control.
				For Each KeyValue In WritingObjects Do
					WriteObjectOnRefsReplace(KeyValue.Key, ExecutionParameters);
				EndDo;
			EndIf;
		Except
			ActionState = "WritingError";
			ErrorDescription = BriefErrorDescription(ErrorInfo());
			ErrorText = StrTemplate(NStr("ru = 'Не удалось записать %1 по причине: %2'; en = 'Cannot save %1. Reason: %2'"), 
				DataPresentation, ErrorDescription);
			Raise;
		EndTry;
		
		If InnerTransaction Then
			CommitTransaction();
		EndIf;

	Except
		If InnerTransaction Then
			RollbackTransaction();
		EndIf;
		Information = ErrorInfo();
		WriteLogEvent(RefReplacementEventLogMessageText(), EventLogLevel.Error,
			UsageInstance.Metadata,,	DetailErrorDescription(Information));
		Error = ReplacementErrorDescription(ActionState, Data, DataPresentation, ErrorText);
		If ActionState = "WritingError" Then
			For Each Row In RowsToProcess Do
				RegisterReplacementError(Result, Row.Ref, Error);
			EndDo;
		Else	
			RegisterReplacementError(Result, UsageInstance.Ref, Error);
		EndIf;
	EndTry;
	
	// Marking as processed.
	For Each Row In RowsToProcess Do
		Row.ReplacementKey = "";
	EndDo;
	
EndProcedure

Procedure ReplaceInSet(Result, Val UsageInstance, Val ExecutionParameters, Val InnerTransaction = True)
	SetPrivilegedMode(True);

	Data = UsageInstance.Data;
	Meta   = UsageInstance.Metadata;
	
	DataPresentation = String(Data);
	
	// Performing all replacement of the data in the same time.
	Filter = New Structure("Data, ReplacementKey");
	FillPropertyValues(Filter, UsageInstance);
	RowsToProcess = UsageInstance.Owner().FindRows(Filter);

	SetDetails = RecordKeyDetails(Meta);
	RecordSet = SetDetails.RecordSet;
	
	ReplacementPairs = New Map;
	For Each Row In RowsToProcess Do
		ReplacementPairs.Insert(Row.Ref, Row.DestinationRef);
	EndDo;
	
	// Marking as processed.
	For Each Row In RowsToProcess Do
		Row.ReplacementKey = "";
	EndDo;
	
	ActionState = "";
	Error = "";
	If InnerTransaction Then
		BeginTransaction();
	EndIf;

	Try
		
		If InnerTransaction Then
			// Locking and preparing the set.
			Lock = New DataLock;
			For Each KeyValue In SetDetails.MeasurementList Do
				DimensionType = KeyValue.Value;
				Name          = KeyValue.Key;
				Value     = Data[Name];
				
				For Each Row In RowsToProcess Do
					CurrentRef = Row.Ref;
					If DimensionType.ContainsType(TypeOf(CurrentRef)) Then
						Lock.Add(SetDetails.LockSpace).SetValue(Name, CurrentRef);
					EndIf;
				EndDo;
				
				RecordSet.Filter[Name].Set(Value);
			EndDo;

			Try
				Lock.Lock();
			Except
				Error = StrTemplate(NStr("ru = 'Не удалось заблокировать набор %1'; en = 'Cannot lock record set %1.'"), 
					DataPresentation);
				ActionState = "LockError";
				Raise;
			EndTry;
			
		EndIf;

		RecordSet.Read();
		ReplaceInRowCollection("RecordSet", "RecordSet", RecordSet, RecordSet, SetDetails.FieldList, ReplacementPairs);
		
		If RecordSet.Modified() Then
			If InnerTransaction Then
				RollbackTransaction();
			EndIf;
			Return;
		EndIf;

		If Not ExecutionParameters.WriteParameters.PrivilegedMode Then
			SetPrivilegedMode(False);
		EndIf;
		
		Try
			WriteObjectOnRefsReplace(RecordSet, ExecutionParameters);
		Except
			ErrorDescription = BriefErrorDescription(ErrorInfo());
			Error = StrTemplate(NStr("ru = 'Не удалось записать %1 по причине: %2'; en = 'Cannot save %1. Reason: %2'"), 
				DataPresentation, ErrorDescription);
			ActionState = "WritingError";
			Raise;
		EndTry;

		If Not ExecutionParameters.WriteParameters.PrivilegedMode Then
			SetPrivilegedMode(True);
		EndIf;
		
		If InnerTransaction Then
			CommitTransaction();
		EndIf;
		
	Except
		If InnerTransaction Then
			RollbackTransaction();
		EndIf;
		Information = ErrorInfo();
		WriteLogEvent(RefReplacementEventLogMessageText(), EventLogLevel.Error,
			Meta,, DetailErrorDescription(Information));
		Error = ReplacementErrorDescription(ActionState, Data, DataPresentation, Error);
		If ActionState = "WritingError" Then
			For Each Row In RowsToProcess Do
				RegisterReplacementError(Result, Row.Ref, Error);
			EndDo;
		Else	
			RegisterReplacementError(Result, UsageInstance.Ref, Error);
		EndIf;	
	EndTry;
	
EndProcedure

Procedure ReplaceInInformationRegister(Result, Val UsageInstance, Val ExecutionParameters, Val InnerTransaction = True)
	
	If UsageInstance.Processed Then
		Return;
	EndIf;
	UsageInstance.Processed = True;
	
		// If the duplicate is specified in set dimensions, two record sets are used:
	//     DuplicateRecordSet - reads old values (by old dimensions) and deletes old values.
	//     OriginalRecordSet - reads actual values (by new dimensions) and writes new values.
	//     Data of duplicates and originals are merged by the rules:
	//         Original object data has the priority.
	//         If the original has no data, the data is received from the duplicate.
	//     The original set is written and the duplicate set is deleted.
	//
	// If the duplicate is not specified in a set dimensions, one record sets is used:
	//     DuplicateRecordSet - reads old values and writes new values.
	//
	// In both cases, reference in resources and attributes are replaced.
	
	SetPrivilegedMode(True);
	
	Duplicate    = UsageInstance.Ref;
	Original = UsageInstance.DestinationRef;
	
	RegisterMetadata = UsageInstance.Metadata;
	RegisterRecordKey = UsageInstance.Data;

	Information = TypeInformation(RegisterMetadata, ExecutionParameters);
	
	TwoSetsRequired = False;
	For Each KeyValue In Information.Dimensions Do
		DuplicateDimensionValue = RegisterRecordKey[KeyValue.Key];
		If DuplicateDimensionValue = Duplicate
			Or ExecutionParameters.SuccessfulReplacements[DuplicateDimensionValue] = Duplicate Then
			TwoSetsRequired = True; // Duplicate is specified in dimensions.
			Break;
		EndIf;
	EndDo;

	Manager = ObjectManagerByFullName(Information.FullName);
	//@skip-warning
	DuplicateRecordSet = Manager.CreateRecordSet();
	
	If TwoSetsRequired Then
		OriginalDimensionValues = New Structure;
		//@skip-warning
		OriginalRecordSet = Manager.CreateRecordSet();
	EndIf;

	If InnerTransaction Then
		BeginTransaction();
	EndIf;
	
	Try
		If InnerTransaction Then
			Lock = New DataLock;
			DuplicateLock = Lock.Add(Information.FullName);
			If TwoSetsRequired Then
				OriginalLock = Lock.Add(Information.FullName);
			EndIf;
		EndIf;

		For Each KeyValue In Information.Dimensions Do
			DuplicateDimensionValue = RegisterRecordKey[KeyValue.Key];
			
			// To solve the problem of uniqueness, replacing old record key dimension values for new ones.
			//   
			//   Map of old and current provides SuccessfulReplacements.
			//   Map data is actual at the current point in time as it is updated only after processing a next 
			//   couple and committing the transaction.
			NewDuplicateDimensionValue = ExecutionParameters.SuccessfulReplacements[DuplicateDimensionValue];
			If NewDuplicateDimensionValue <> Undefined Then
				DuplicateDimensionValue = NewDuplicateDimensionValue;
			EndIf;

			DuplicateRecordSet.Filter[KeyValue.Key].Set(DuplicateDimensionValue);
			
			If InnerTransaction Then // Replacement in the pair and lock for the replacement.
				DuplicateLock.SetValue(KeyValue.Key, DuplicateDimensionValue);
			EndIf;

			If TwoSetsRequired Then
				If DuplicateDimensionValue = Duplicate Then
					OriginalDimensionValue = Original;
				Else
					OriginalDimensionValue = DuplicateDimensionValue;
				EndIf;
				
				OriginalRecordSet.Filter[KeyValue.Key].Set(OriginalDimensionValue);
				OriginalDimensionValues.Insert(KeyValue.Key, OriginalDimensionValue);
				
				If InnerTransaction Then // Replacement in the pair and lock for the replacement.
					OriginalLock.SetValue(KeyValue.Key, OriginalDimensionValue);
				EndIf;
			EndIf;
		EndDo;
		
		// Setting lock.
		If InnerTransaction Then
			Try
				Lock.Lock();
			Except
				// Error type: LockForRegister.
				Raise;
			EndTry;
		EndIf;
		
		// The source.
		DuplicateRecordSet.Read();
		If DuplicateRecordSet.Count() = 0 Then // Nothing to write.
			If InnerTransaction Then
				RollbackTransaction(); // Replacement is not required.
			EndIf;
			Return;
		EndIf;
		DuplicateRecord = DuplicateRecordSet[0];
		
		// The destination.
		If TwoSetsRequired Then
			// Writing to a set with other dimensions.
			OriginalRecordSet.Read();
			If OriginalRecordSet.Count() = 0 Then
				OriginalRecord = OriginalRecordSet.Add();
				FillPropertyValues(OriginalRecord, DuplicateRecord);
				FillPropertyValues(OriginalRecord, OriginalDimensionValues);
			Else
				OriginalRecord = OriginalRecordSet[0];
			EndIf;
		Else
			// Writing to the source.
			OriginalRecordSet = DuplicateRecordSet;
			OriginalRecord = DuplicateRecord; // The zero record set case is processed above.
		EndIf;
		
		// Substituting the original for duplicate in resource and attributes.
		For Each KeyValue In Information.Resources Do
			AttributeValueInOriginal = OriginalRecord[KeyValue.Key];
			If AttributeValueInOriginal = Duplicate Then
				OriginalRecord[KeyValue.Key] = Original;
			EndIf;
		EndDo;
		For Each KeyValue In Information.Attributes Do
			AttributeValueInOriginal = OriginalRecord[KeyValue.Key];
			If AttributeValueInOriginal = Duplicate Then
				OriginalRecord[KeyValue.Key] = Original;
			EndIf;
		EndDo;

		If Not ExecutionParameters.WriteParameters.PrivilegedMode Then
			SetPrivilegedMode(False);
		EndIf;
		
		// Deleting the duplicate data.
		If TwoSetsRequired Then
			DuplicateRecordSet.Clear();
			Try
				WriteObjectOnRefsReplace(DuplicateRecordSet, ExecutionParameters);
			Except
				// Error type: DeleteDuplicateSet.
				Raise;
			EndTry;
		EndIf;
		
		// Writing original object data.
		If OriginalRecordSet.Modified() Then
			Try
				WriteObjectOnRefsReplace(OriginalRecordSet, ExecutionParameters);
			Except
				// Error type: WriteOriginalSet.
				Raise;
			EndTry;
		EndIf;
		
		If InnerTransaction Then
			CommitTransaction();
		EndIf;
	Except
		If InnerTransaction Then
			RollbackTransaction();
		EndIf;
		RegisterErrorInTable(Result, Duplicate, Original, RegisterRecordKey, Information, 
			"LockForRegister", ErrorInfo());
	EndTry
	
EndProcedure

Function ModifiedObjectsOnReplaceInObject(ExecutionParameters, UsageInstance, RowsToProcess)
	Data = UsageInstance.Data;
	SequencesDetails = SequencesDetails(UsageInstance.Metadata);
	RegisterRecordsDetails            = RegisterRecordsDetails(UsageInstance.Metadata);
	
	SetPrivilegedMode(True);
	
	// Returning modified processed objects.
	Modified = New Map;
	
	// Reading
	Details = ObjectDetails(Data.Metadata());
	Try
		Object = Data.GetObject();
	Except
		// Has already been processed with errors.
		Object = Undefined;
	EndTry;
	
	If Object = Undefined Then
		Return Modified;
	EndIf;

		For Each RegisterRecordDetails In RegisterRecordsDetails Do
		RegisterRecordDetails.RecordSet.Filter.Recorder.Set(Data);
		RegisterRecordDetails.RecordSet.Read();
	EndDo;
	
	For Each SequenceDetails In SequencesDetails Do
		SequenceDetails.RecordSet.Filter.Recorder.Set(Data);
		SequenceDetails.RecordSet.Read();
	EndDo;
	
	// Replacing all at once.
	ReplacementPairs = New Map;
	For Each UsageInstance In RowsToProcess Do
		ReplacementPairs.Insert(UsageInstance.Ref, UsageInstance.DestinationRef);
	EndDo;
		// Attributes
	For Each KeyValue In Details.Attributes Do
		Name = KeyValue.Key;
		DestinationRef = ReplacementPairs[ Object[Name] ];
		If DestinationRef <> Undefined Then
			RegisterReplacement(Object, Object[Name], DestinationRef, "Attributes", Name);
			Object[Name] = DestinationRef;
		EndIf;
	EndDo;
	
	// Standard attributes.
	For Each KeyValue In Details.StandardAttributes Do
		Name = KeyValue.Key;
		DestinationRef = ReplacementPairs[ Object[Name] ];
		If DestinationRef <> Undefined Then
			RegisterReplacement(Object, Object[Name], DestinationRef, "StandardAttributes", Name);
			Object[Name] = DestinationRef;
		EndIf;
	EndDo;
		
	// Tabular sections
	For Each Item In Details.TabularSections Do
		ReplaceInRowCollection(
			"TabularSections",
			Item.Name,
			Object,
			Object[Item.Name],
			Item.FieldList,
			ReplacementPairs);
	EndDo;
	
	// Standard tabular section.
	For Each Item In Details.StandardTabularSections Do
		ReplaceInRowCollection(
			"StandardTabularSections",
			Item.Name,
			Object,
			Object[Item.Name],
			Item.FieldList,
			ReplacementPairs);
	EndDo;
		
	// RegisterRecords
	For Each RegisterRecordDetails In RegisterRecordsDetails Do
		ReplaceInRowCollection(
			"RegisterRecords",
			RegisterRecordDetails.LockSpace,
			RegisterRecordDetails.RecordSet,
			RegisterRecordDetails.RecordSet,
			RegisterRecordDetails.FieldList,
			ReplacementPairs);
	EndDo;
	
	// Sequences
	For Each SequenceDetails In SequencesDetails Do
		ReplaceInRowCollection(
			"Sequences",
			SequenceDetails.LockSpace,
			SequenceDetails.RecordSet,
			SequenceDetails.RecordSet,
			SequenceDetails.FieldList,
			ReplacementPairs);
	EndDo;
	
	For Each RegisterRecordDetails In RegisterRecordsDetails Do
		If RegisterRecordDetails.RecordSet.Modified() Then
			Modified.Insert(RegisterRecordDetails.RecordSet, False);
		EndIf;
	EndDo;
	
	For Each SequenceDetails In SequencesDetails Do
		If SequenceDetails.RecordSet.Modified() Then
			Modified.Insert(SequenceDetails.RecordSet, False);
		EndIf;
	EndDo;
	
	// The object goes last in case a reposting is required.
	If Object.Modified() Then
		Modified.Insert(Object, Details.CanBePosted);
	EndIf;
	
	Return Modified;
EndFunction

Procedure RegisterReplacement(Object, DuplicateRef, OriginalRef, AttributeKind, AttributeName, Index = Undefined, ColumnName = Undefined)
	Structure = New Structure("AdditionalProperties");
	FillPropertyValues(Structure, Object);
	If TypeOf(Structure.AdditionalProperties) <> Type("Structure") Then
		Return;
	EndIf;
AuxProperties = Object.AdditionalProperties;
	AuxProperties.Insert("ReferenceReplacement", True);
	CompletedReplacements = UT_CommonClientServer.StructureProperty(AuxProperties, "CompletedReplacements");
	If CompletedReplacements = Undefined Then
		CompletedReplacements = New Array;
		AuxProperties.Insert("CompletedReplacements", CompletedReplacements);
	EndIf;
	ReplacementDetails = New Structure;
	ReplacementDetails.Insert("DuplicateRef", DuplicateRef);
	ReplacementDetails.Insert("OriginalRef", OriginalRef);
	ReplacementDetails.Insert("AttributeKind", AttributeKind);
	ReplacementDetails.Insert("AttributeName", AttributeName);
	ReplacementDetails.Insert("IndexOf", Index);
	ReplacementDetails.Insert("ColumnName", ColumnName);
	CompletedReplacements.Add(ReplacementDetails);
EndProcedure

Procedure DeleteRefsNotExclusive(Result, Val RefsList, Val ExecutionParameters, Val DeleteDirectly)
	
	SetPrivilegedMode(True);
	
	ToDelete = New Array;
	
	LocalTransaction = Not TransactionActive();
	If LocalTransaction Then
		BeginTransaction();
	EndIf;

	Try
		For Each Ref In RefsList Do
			Information = TypeInformation(TypeOf(Ref), ExecutionParameters);
			Lock = New DataLock;
			Lock.Add(Information.FullName).SetValue("Ref", Ref);
			Try
				Lock.Lock();
				ToDelete.Add(Ref);
			Except
				RegisterErrorInTable(Result, Ref, Undefined, Ref, Information, 
					"DataLockForDuplicateDeletion", ErrorInfo());
			EndTry;
		EndDo;
		
		SearchTable = UsageInstances(ToDelete);
		Filter = New Structure("Ref");
		
		For Each Ref In ToDelete Do
			RefPresentation = SubjectString(Ref);
			
			Filter.Ref = Ref;
			UsageInstances = SearchTable.FindRows(Filter);
			
			Index = UsageInstances.UBound();
			While Index >= 0 Do
				If UsageInstances[Index].AuxiliaryData Then
					UsageInstances.Delete(Index);
				EndIf;
				Index = Index - 1;
			EndDo;
			
			If UsageInstances.Count() > 0 Then
				AddModifiedObjectReplacementResults(Result, UsageInstances);
				Continue; // Cannot delete the object because other objects refer to it.
			EndIf;
			
			Object = Ref.GetObject();
			If Object = Undefined Then
				Continue; // Has already been deleted.
			EndIf;

			If Not ExecutionParameters.WriteParameters.PrivilegedMode Then
				SetPrivilegedMode(False);
			EndIf;
			
			Try
				If DeleteDirectly Then
					ProcessObjectWithMessageInterceptionOnRefsReplace(Object, "DirectDeletion", Undefined, ExecutionParameters);
				Else
					ProcessObjectWithMessageInterceptionOnRefsReplace(Object, "DeletionMark", Undefined, ExecutionParameters);
				EndIf;
			Except
				ErrorText = NStr("ru = 'Ошибка удаления'; en = 'Deletion error.'")
					+ Chars.LF
					+ TrimAll(BriefErrorDescription(ErrorInfo()));
				ErrorDescription = ReplacementErrorDescription("DeletionError", Ref, RefPresentation, ErrorText);
				RegisterReplacementError(Result, Ref, ErrorDescription);
			EndTry;
			
			If Not ExecutionParameters.WriteParameters.PrivilegedMode Then
				SetPrivilegedMode(True);
			EndIf;
		EndDo;
		
		If LocalTransaction Then
			CommitTransaction();
		EndIf;
	Except
		If LocalTransaction Then
			RollbackTransaction();
		EndIf;
	EndTry;
	
EndProcedure

Procedure AddModifiedObjectReplacementResults(Result, RepeatSearchTable)
	
	Filter = New Structure("ErrorType, Ref, ErrorObject", "");
	For Each Row In RepeatSearchTable Do
		Test = New Structure("AuxiliaryData", False);
		FillPropertyValues(Test, Row);
		If Test.AuxiliaryData Then
			Continue;
		EndIf;
		
		Data = Row.Data;
		Ref = Row.Ref;
		
		DataPresentation = String(Data);
		
		Filter.ErrorObject = Data;
		Filter.Ref       = Ref;
		If Result.Errors.FindRows(Filter).Count() > 0 Then
			Continue; // Error on this issue has already been recorded.
		EndIf;
		RegisterReplacementError(Result, Ref, 
			ReplacementErrorDescription("DataChanged", Data, DataPresentation,
			NStr("ru = 'Заменены не все места использования. Возможно места использования были добавлены или изменены другим пользователем.'; en = 'Some of the instances were not replaced. Probably these instances were added or edited by other users.'")));
	EndDo;
	
EndProcedure

Procedure LockUsageInstances(ExecutionParameters, Lock, UsageInstances)
	
	For Each UsageInstance In UsageInstances Do
		
		LockUsageInstance(ExecutionParameters, Lock, UsageInstance);
		
	EndDo;
	
EndProcedure

Procedure LockUsageInstance(ExecutionParameters, Lock, UsageInstance)
	
	If UsageInstance.ReplacementKey = "Constant" Then
		
		Lock.Add(UsageInstance.Metadata.FullName());
		
	ElsIf UsageInstance.ReplacementKey = "Object" Then
		
		ObjectRef     = UsageInstance.Data;
		ObjectMetadata = UsageInstance.Metadata;
		
		// The object.
		Lock.Add(ObjectMetadata.FullName()).SetValue("Ref", ObjectRef);
		
		// Register records by recorder.
		RegisterRecordsDetails = RegisterRecordsDetails(ObjectMetadata);
		For Each Item In RegisterRecordsDetails Do
			Lock.Add(Item.LockSpace + ".RecordSet").SetValue("Recorder", ObjectRef);
		EndDo;
		
		/// Sequences.
		SequencesDetails = SequencesDetails(ObjectMetadata);
		For Each Item In SequencesDetails Do
			Lock.Add(Item.LockSpace).SetValue("Recorder", ObjectRef);
		EndDo;
		
	ElsIf UsageInstance.ReplacementKey = "Sequence" Then
		
		ObjectRef     = UsageInstance.Data;
		ObjectMetadata = UsageInstance.Metadata;
		
		SequencesDetails = SequencesDetails(ObjectMetadata);
		For Each Item In SequencesDetails Do
			Lock.Add(Item.LockSpace).SetValue("Recorder", ObjectRef);
		EndDo;

	ElsIf UsageInstance.ReplacementKey = "RecordKey"
		Or UsageInstance.ReplacementKey = "InformationRegister" Then
		
		Information = TypeInformation(UsageInstance.Metadata, ExecutionParameters);
		DuplicateType = UsageInstance.RefType;
		OriginalType = TypeOf(UsageInstance.DestinationRef);
		
		For Each KeyValue In Information.Dimensions Do
			DimensionType = KeyValue.Value.Type;
			If DimensionType.ContainsType(DuplicateType) Then
				DataLockByDimension = Lock.Add(Information.FullName);
				DataLockByDimension.SetValue(KeyValue.Key, UsageInstance.Ref);
			EndIf;
			If DimensionType.ContainsType(OriginalType) Then
				DataLockByDimension = Lock.Add(Information.FullName);
				DataLockByDimension.SetValue(KeyValue.Key, UsageInstance.DestinationRef);
			EndIf;
		EndDo;
		
	EndIf;
	
EndProcedure

Function RegisterRecordsDetails(Val Meta)
	// Can be cached by Meta.
	
	RegisterRecordsDetails = New Array;
	If Not Metadata.Documents.Contains(Meta) Then
		Return RegisterRecordsDetails;
	EndIf;
	
	For Each RegisterRecord In Meta.RegisterRecords Do
		
		If Metadata.AccumulationRegisters.Contains(RegisterRecord) Then
			RecordSet = AccumulationRegisters[RegisterRecord.Name].CreateRecordSet();
			ExcludeFields = "Active, LineNumber, Period, Recorder"; 
			
		ElsIf Metadata.InformationRegisters.Contains(RegisterRecord) Then
			RecordSet = InformationRegisters[RegisterRecord.Name].CreateRecordSet();
			ExcludeFields = "Active, RecordType, LineNumber, Period, Recorder"; 
			
		ElsIf Metadata.AccountingRegisters.Contains(RegisterRecord) Then
			RecordSet = AccountingRegisters[RegisterRecord.Name].CreateRecordSet();
			ExcludeFields = "Active, RecordType, LineNumber, Period, Recorder"; 
			
		ElsIf Metadata.CalculationRegisters.Contains(RegisterRecord) Then
			RecordSet = CalculationRegisters[RegisterRecord.Name].CreateRecordSet();
			ExcludeFields = "Active, EndOfBasePeriod, BegOfBasePeriod, LineNumber, ActionPeriod,
			                |EndOfActionPeriod, BegOfActionPeriod, RegistrationPeriod, Recorder, ReversingEntry,
			                |ActualActionPeriod";
		Else
			// Unknown type.
			Continue;
		EndIf;
		
		// Reference type fields and candidate dimensions.
		Details = FieldListsByType(RecordSet, RegisterRecord.Dimensions, ExcludeFields);
		If Details.FieldList.Count() = 0 Then
			// No need to process.
			Continue;
		EndIf;
		
		Details.Insert("RecordSet", RecordSet);
		Details.Insert("LockSpace", RegisterRecord.FullName() );
		
		RegisterRecordsDetails.Add(Details);
	EndDo;	// Register record metadata.
	
	Return RegisterRecordsDetails;
EndFunction

Function SequencesDetails(Val Meta)
	
	SequencesDetails = New Array;
	If Not Metadata.Documents.Contains(Meta) Then
		Return SequencesDetails;
	EndIf;
	
	For Each Sequence In Metadata.Sequences Do
		If Not Sequence.Documents.Contains(Meta) Then
			Continue;
		EndIf;
		
		TableName = Sequence.FullName();
		
		// List of fields and dimensions
		Details = FieldListsByType(TableName, Sequence.Dimensions, "Recorder");
		If Details.FieldList.Count() > 0 Then
			
			Details.Insert("RecordSet",           Sequences[Sequence.Name].CreateRecordSet());
			Details.Insert("LockSpace", TableName + ".Records");
			Details.Insert("Dimensions",              New Structure);
			
			SequencesDetails.Add(Details);
		EndIf;
		
	EndDo;
	
	Return SequencesDetails;
EndFunction

Function ObjectDetails(Val Meta)
	// Can be cached by Meta.
	
	AllRefsType = AllRefsTypeDescription();

	Candidates = New Structure("Attributes, StandardAttributes, TabularSections, StandardTabularSections");
	FillPropertyValues(Candidates, Meta);
	
	ObjectDetails = New Structure;
	
	ObjectDetails.Insert("Attributes", New Structure);
	If Candidates.Attributes <> Undefined Then
		For Each MetaAttribute In Candidates.Attributes Do
			If DescriptionTypesOverlap(MetaAttribute.Type, AllRefsType) Then
				ObjectDetails.Attributes.Insert(MetaAttribute.Name);
			EndIf;
		EndDo;
	EndIf;

	ObjectDetails.Insert("StandardAttributes", New Structure);
	If Candidates.StandardAttributes <> Undefined Then
		ToExclude = New Structure("Ref");
		
		For Each MetaAttribute In Candidates.StandardAttributes Do
			Name = MetaAttribute.Name;
			If Not ToExclude.Property(Name) AND DescriptionTypesOverlap(MetaAttribute.Type, AllRefsType) Then
				ObjectDetails.Attributes.Insert(MetaAttribute.Name);
			EndIf;
		EndDo;
	EndIf;
	
	ObjectDetails.Insert("TabularSections", New Array);
	If Candidates.TabularSections <> Undefined Then
		For Each MetaTable In Candidates.TabularSections Do
			
			FieldsList = New Structure;
			For Each MetaAttribute In MetaTable.Attributes Do
				If DescriptionTypesOverlap(MetaAttribute.Type, AllRefsType) Then
					FieldsList.Insert(MetaAttribute.Name);
				EndIf;
			EndDo;
			
			If FieldsList.Count() > 0 Then
				ObjectDetails.TabularSections.Add(New Structure("Name, FieldList", MetaTable.Name, FieldsList));
			EndIf;
		EndDo;
	EndIf;
	
	ObjectDetails.Insert("StandardTabularSections", New Array);
	If Candidates.StandardTabularSections <> Undefined Then
		For Each MetaTable In Candidates.StandardTabularSections Do
			
			FieldsList = New Structure;
			For Each MetaAttribute In MetaTable.StandardAttributes Do
				If DescriptionTypesOverlap(MetaAttribute.Type, AllRefsType) Then
					FieldsList.Insert(MetaAttribute.Name);
				EndIf;
			EndDo;
			
			If FieldsList.Count() > 0 Then
				ObjectDetails.StandardTabularSections.Add(New Structure("Name, FieldList", MetaTable.Name, FieldsList));
			EndIf;
		EndDo;
	EndIf;
	
	ObjectDetails.Insert("CanBePosted", Metadata.Documents.Contains(Meta));
	Return ObjectDetails;
EndFunction

Function RecordKeyDetails(Val Meta)
	// Can be cached by Meta.
	
	TableName = Meta.FullName();
	
	// Candidate reference type fields and a dimension set.
	KeyDetails = FieldListsByType(TableName, Meta.Dimensions, "Period, Recorder");
	
	If Metadata.InformationRegisters.Contains(Meta) Then
		RecordSet = InformationRegisters[Meta.Name].CreateRecordSet();
	
	ElsIf Metadata.AccumulationRegisters.Contains(Meta) Then
		RecordSet = AccumulationRegisters[Meta.Name].CreateRecordSet();
	
	ElsIf Metadata.AccountingRegisters.Contains(Meta) Then
		RecordSet = AccountingRegisters[Meta.Name].CreateRecordSet();
	
	ElsIf Metadata.CalculationRegisters.Contains(Meta) Then
		RecordSet = CalculationRegisters[Meta.Name].CreateRecordSet();
	
	ElsIf Metadata.Sequences.Contains(Meta) Then
		RecordSet = Sequences[Meta.Name].CreateRecordSet();
	
	Else
		RecordSet = Undefined;
	
	EndIf;
	
	KeyDetails.Insert("RecordSet", RecordSet);
	KeyDetails.Insert("LockSpace", TableName);
	
	Return KeyDetails;
EndFunction

Function DescriptionTypesOverlap(Val Details1, Val Details2)
	
	For Each Type In Details1.Types() Do
		If Details2.ContainsType(Type) Then
			Return True;
		EndIf;
	EndDo;
	
	Return False;
EndFunction

// Returns a description by the table name or by the record set.
Function FieldListsByType(Val DataSource, Val MetaDimensions, Val ExcludeFields)
	// Can be cached.
	
	Details = New Structure;
	Details.Insert("FieldList",     New Structure);
	Details.Insert("DimensionStructure", New Structure);
	Details.Insert("MasterDimentionList",   New Structure);
	

	ControlType = AllRefsTypeDescription();
	ToExclude = New Structure(ExcludeFields);
	
	DataSourceType = TypeOf(DataSource);
	
	If DataSourceType = Type("String") Then
		// The source is the table name. The fields are received with a query.
		Query = New Query("SELECT * FROM " + DataSource + " WHERE FALSE");
		FieldSource = Query.Execute();
	Else
		// The source is a record set.
		FieldSource = DataSource.UnloadColumns();
	EndIf;

	For Each Column In FieldSource.Columns Do
		Name = Column.Name;
		If Not ToExclude.Property(Name) AND DescriptionTypesOverlap(Column.ValueType, ControlType) Then
			Details.FieldList.Insert(Name);
			
			// Checking for a master dimension.
			Meta = MetaDimensions.Find(Name);
			If Meta <> Undefined Then
				Details.DimensionStructure.Insert(Name, Meta.Type);
				Test = New Structure("Master", False);
				FillPropertyValues(Test, Meta);
				If Test.Master Then
					Details.MasterDimentionList.Insert(Name, Meta.Type);
				EndIf;
			EndIf;
			
		EndIf;
		
	EndDo;
	
	Return Details;
EndFunction

Procedure ReplaceInRowCollection(CollectionKind, CollectionName, Object, Collection, Val FieldsList, Val ReplacementPairs)
	WorkingCollection = Collection.Unload();
	Modified = False;
	
	For Each Row In WorkingCollection Do
		
		For Each KeyValue In FieldsList Do
			Name = KeyValue.Key;
			DestinationRef = ReplacementPairs[ Row[Name] ];
			If DestinationRef <> Undefined Then
				RegisterReplacement(Object, Row[Name], DestinationRef, CollectionKind, CollectionName, WorkingCollection.IndexOf(Row), Name);
				Row[Name] = DestinationRef;
				Modified = True;
			EndIf;
		EndDo;
		
	EndDo;
	
	If Modified Then
		Collection.Load(WorkingCollection);
	EndIf;
EndProcedure

Процедура ProcessObjectWithMessageInterceptionOnRefsReplace(Val Object, Val Action, Val WriteMode, Val WriteParameters)
	
    // Saving the current messages before the exception.
	PreviousMessages = GetUserMessages(True);
	ReportAgain    = CurrentRunMode() <> Undefined;

	If Not WriteObjectToDB(Object, WriteParameters.WriteParameters, Action, WriteMode, True) Then
		// Intercepting all reported error messages and merging them into a single exception text.
		ExceptionText = "";
		For Each Message In GetUserMessages(False) Do
			ExceptionText = ExceptionText + Chars.LF + Message.Text;
		EndDo;
		
		// Reporting the previous message.
		If ReportAgain Then
			ReportDeferredMessages(PreviousMessages);
		EndIf;

		If ExceptionText = "" Then
			Raise "";
		Else
			Raise TrimAll(ExceptionText);
		EndIf;
	EndIf;

	If ReportAgain Then
		ReportDeferredMessages(PreviousMessages);
	EndIf;

EndProcedure

Procedure ReportDeferredMessages(Val Messages)
	
	For Each Message In Messages Do
		Message.Message();
	EndDo;
	
EndProcedure

Procedure WriteObjectOnRefsReplace (Val Object, Val WriteParameters)

	ObjectMetadata = Object.Metadata();
	
	If IsDocument(ObjectMetadata) Then
		ProcessObjectWithMessageInterceptionOnRefsReplace(Object, "Write", DocumentWriteMode.Write, WriteParameters);
		Return;
	EndIf;
	
	// Checking for loop references.
	ObjectProperties = New Structure("Hierarchical, ExtDimensionTypes, Owners", False, Undefined, New Array);
	FillPropertyValues(ObjectProperties, ObjectMetadata);
	
	// Checking the parent.
	If ObjectProperties.Hierarchical Or ObjectProperties.ExtDimensionTypes <> Undefined Then 
		
		If Object.Parent = Object.Ref Then
			Raise StrTemplate(
				NStr("ru = 'При записи ""%1"" возникает циклическая ссылка в иерархии.'; en = 'Writing ""%1"" causes an infinite loop in the hierarchy.'"),
				String(Object));
			EndIf;
			
	EndIf;
	
	// Checking the owner.
	If ObjectProperties.Owners.Count() > 1 AND Object.Owner = Object.Ref Then
		Raise StrTemplate(
			NStr("ru = 'При записи ""%1"" возникает циклическая ссылка в подчинении.'; en = 'Writing ""%1"" causes an infinite loop in the subordination.'"),
			String(Object));
	EndIf;
	
	// For sequences, the Update right can be absent even in the FullAdministrator role.
	If IsSequence(ObjectMetadata)
		AND Not AccessRight("Update", ObjectMetadata)
		AND Users.IsFullUser(,, False) Then
		
		SetPrivilegedMode(True);
	EndIf;
	
	// Only writing.
	ProcessObjectWithMessageInterceptionOnRefsReplace(Object, "Write", Undefined, WriteParameters);
EndProcedure

Function RefReplacementEventLogMessageText()
	
	Return NStr("ru='Поиск и удаление ссылок'; en = 'Searching for references and deleting them'",UT_CommonClientServer.DefaultLanguageCode());
	
EndFunction

Procedure RegisterErrorInTable(Result, Duplicate, Original, Data, Information, ErrorType, ErrorInformation)
	Result.HasErrors = True;
	
	WriteLogEvent(
		RefReplacementEventLogMessageText(),
		EventLogLevel.Error,
		,
		,
		DetailErrorDescription(ErrorInformation));
	
	FullDataPresentation = String(Data) + " (" + Information.ItemPresentation + ")";
	
	Error = Result.Errors.Add();
	Error.Ref       = Duplicate;
	Error.ErrorObject = Data;
	Error.ErrorObjectPresentation = FullDataPresentation;
	
	If ErrorType = "LockForRegister" Then
		NewTemplate = NStr("ru = 'Не удалось начать редактирование %1: %2'; en = 'Cannot start editing %1: %2'");
		Error.ErrorType = "LockError";
	ElsIf ErrorType = "DataLockForDuplicateDeletion" Then
		NewTemplate = NStr("ru = 'Не удалось начать удаление: %2'; en = 'Cannot start deletion: %2'");
		Error.ErrorType = "LockError";
	ElsIf ErrorType = "DeleteDuplicateSet" Then
		NewTemplate = NStr("ru = 'Не удалось очистить сведения о дубле в %1: %2'; en = 'Cannot clear duplicate''s details in %1: %2'");
		Error.ErrorType = "WritingError";
	ElsIf ErrorType = "WriteOriginalSet" Then
		NewTemplate = NStr("ru = 'Не удалось обновить сведения в %1: %2'; en = 'Cannot update additional data in %1: %2'");
		Error.ErrorType = "WritingError";
	Else
		NewTemplate = ErrorType + " (%1): %2";
		Error.ErrorType = ErrorType;
	EndIf;
	
	NewTemplate = NewTemplate + Chars.LF + Chars.LF + NStr("ru = 'Подробности в журнале регистрации.'; en = 'See the event log for details.'");
	
	BriefPresentation = BriefErrorDescription(ErrorInformation);
	Error.ErrorText = StrTemplate(NewTemplate, FullDataPresentation, BriefPresentation);
	
EndProcedure

// Generates details on the metadata object type: full name, presentations, kind, and so on.
Function TypeInformation(FullNameOrMetadataOrType, Cache)
	FirstParameterType = TypeOf(FullNameOrMetadataOrType);
	If FirstParameterType = Type("String") Then
		MetadataObject = Metadata.FindByFullName(FullNameOrMetadataOrType);
	Else
		If FirstParameterType = Type("Type") Then // Search for the metadata object.
			MetadataObject = Metadata.FindByType(FullNameOrMetadataOrType);
		Else
			MetadataObject = FullNameOrMetadataOrType;
		EndIf;
	EndIf;
	FullName = Upper(MetadataObject.FullName());

	TypesInformation = UT_CommonClientServer.StructureProperty(Cache, "TypesInformation");
	If TypesInformation = Undefined Then
		TypesInformation = New Map;
		Cache.Insert("TypesInformation", TypesInformation);
	Else
		Information = TypesInformation.Get(FullName);
		If Information <> Undefined Then
			Return Information;
		EndIf;
	EndIf;

	Information = New Structure("FullName, ItemPresentation, ListPresentation,
	|Kind, Reference, Technical, Separated,
	|Hierarchical,
	|HasSubordinate, SubordinateItemNames,
	|Dimensions, Attributes, Resources");
	TypesInformation.Insert(FullName, Information);
	
	// Fill in basic information.
	Information.FullName = FullName;
	
	// Item and list presentations.
	StandardProperties = New Structure("ObjectPresentation, ExtendedObjectPresentation, ListPresentation, ExtendedListPresentation");
	FillPropertyValues(StandardProperties, MetadataObject);
	If ValueIsFilled(StandardProperties.ObjectPresentation) Then
		Information.ItemPresentation = StandardProperties.ObjectPresentation;
	ElsIf ValueIsFilled(StandardProperties.ExtendedObjectPresentation) Then
		Information.ItemPresentation = StandardProperties.ExtendedObjectPresentation;
	Else
		Information.ItemPresentation = MetadataObject.Presentation();
	EndIf;
	If ValueIsFilled(StandardProperties.ListPresentation) Then
		Information.ListPresentation = StandardProperties.ListPresentation;
	ElsIf ValueIsFilled(StandardProperties.ExtendedListPresentation) Then
		Information.ListPresentation = StandardProperties.ExtendedListPresentation;
	Else
		Information.ListPresentation = MetadataObject.Presentation();
	EndIf;
	
		// Kind and its properties.
	Information.Kind = Left(Information.FullName, StrFind(Information.FullName, ".")-1);
	If Information.Kind = "CATALOG"
		Or Information.Kind = "DOCUMENT"
		Or Information.Kind = "ENUM"
		Or Information.Kind = "CHARTOFCHARACTERISTICTYPES"
		Or Information.Kind = "CHARTOFACCOUNTS"
		Or Information.Kind = "CHARTOFCALCULATIONTYPES"
		Or Information.Kind = "BUSINESSPROCESS"
		Or Information.Kind = "TASK"
		Or Information.Kind = "EXCHANGEPLAN" Then
		Information.Reference = True;
	Else
		Information.Reference = False;
	EndIf;

		If Information.Kind = "CATALOG"
		Or Information.Kind = "CHARTOFCHARACTERISTICTYPES" Then
		Information.Hierarchical = MetadataObject.Hierarchical;
	ElsIf Information.Kind = "CHARTOFACCOUNTS" Then
		Information.Hierarchical = True;
	Else
		Information.Hierarchical = False;
	EndIf;

		Information.HasSubordinate = False;
	If Information.Kind = "CATALOG"
		Or Information.Kind = "CHARTOFCHARACTERISTICTYPES"
		Or Information.Kind = "EXCHANGEPLAN"
		Or Information.Kind = "CHARTOFACCOUNTS"
		Or Information.Kind = "CHARTOFCALCULATIONTYPES" Then
		For Each Catalog In Metadata.Catalogs Do
			If Catalog.Owners.Contains(MetadataObject) Then
				If Information.HasSubordinate = False Then
					Information.HasSubordinate = True;
					Information.SubordinateItemNames = New Array;
				EndIf;
				Information.SubordinateItemNames.Add(Catalog.FullName());
			EndIf;
		EndDo;
	EndIf;

	If Information.FullName = "CATALOG.METADATAOBJECTIDS"
		Or Information.FullName = "CATALOG.PREDEFINEDREPORTSOPTIONS" Then
		Information.Technical = True;
		Information.Separated = False;
	Else
		Information.Technical = False;
		If Not Cache.Property("SaaSModel") Then
			Cache.Insert("SaaSModel", DataSeparationEnabled());
			If Cache.SaaSModel Then
//
//				If SubsystemExists("StandardSubsystems.SaaS") Then
//					ModuleSaaS = CommonModule("SaaS");
//					MainDataSeparator = ModuleSaaS.MainDataSeparator();
//					AuxiliaryDataSeparator = ModuleSaaS.AuxiliaryDataSeparator();
//				Else
					MainDataSeparator = Undefined;
					AuxiliaryDataSeparator = Undefined;
//				КонецЕсли;

				Cache.Insert("InDataArea", DataSeparationEnabled() AND SeparatedDataUsageAvailable());
				Cache.Insert("MainDataSeparator",        MainDataSeparator);
				Cache.Insert("AuxiliaryDataSeparator", AuxiliaryDataSeparator);
			EndIf;
		EndIf;
		If Cache.SaaSModel Then
//			If SubsystemExists("StandardSubsystems.SaaS") Then
//				ModuleSaaS = CommonModule("SaaS");
//				Try
//					IsSeparatedMetadataObject = ModuleSaaS.IsSeparatedMetadataObject(MetadataObject);
//				Except
//					IsSeparatedMetadataObject = True;
//				Endtry;
//			Else
				IsSeparatedMetadataObject = True;
//			EndIf;
			Information.Separated = IsSeparatedMetadataObject;
		EndIf;
	EndIf;

	Information.Dimensions = New Structure;
	Information.Attributes = New Structure;
	Information.Resources = New Structure;
	
	AttributesKinds = New Structure("StandardAttributes, Attributes, Dimensions, Resources");
	FillPropertyValues(AttributesKinds, MetadataObject);
	For Each KeyAndValue In AttributesKinds Do
		Collection = KeyAndValue.Value;
		If TypeOf(Collection) = Type("MetadataObjectCollection") Then
			WhereToWrite = ?(Information.Property(KeyAndValue.Key), Information[KeyAndValue.Key], Information.Attributes);
			For Each Attribute In Collection Do
				WhereToWrite.Insert(Attribute.Name, AttributeInformation(Attribute));
			EndDo;
		EndIf;
	EndDo;
	If Information.Kind = "INFORMATIONREGISTER"
		AND MetadataObject.InformationRegisterPeriodicity <> Metadata.ObjectProperties.InformationRegisterPeriodicity.Nonperiodical Then
		AttributeInformation = New Structure("Master, Presentation, Format, Type, DefaultValue, FillFromFillingValue");
		AttributeInformation.Master = False;
		AttributeInformation.FillFromFillingValue = False;
		If MetadataObject.InformationRegisterPeriodicity = Metadata.ObjectProperties.InformationRegisterPeriodicity.RecorderPosition Then
			AttributeInformation.Type = New TypeDescription("PointInTime");
		ElsIf MetadataObject.InformationRegisterPeriodicity = Metadata.ObjectProperties.InformationRegisterPeriodicity.Second Then
			AttributeInformation.Type = New TypeDescription("Date", , , New DateQualifiers(DateFractions.DateTime));
		Else
			AttributeInformation.Type = New TypeDescription("Date", , , New DateQualifiers(DateFractions.Date));
		EndIf;
		Information.Dimensions.Insert("Period", AttributeInformation);
	EndIf;
	
	Return Information;
EndFunction

Function AttributeInformation(AttributeMetadata)
	// StandardAttributeDetails
	// MetadataObject: Dimension
	// MetadataObject: Resource
	// MetadataObject: Attribute
	Information = New Structure("Master, Presentation, Format, Type, DefaultValue, FillFromFillingValue");
	FillPropertyValues(Information, AttributeMetadata);
	Information.Presentation = AttributeMetadata.Presentation();
	If Information.FillFromFillingValue = True Then
		Information.DefaultValue = AttributeMetadata.FillingValue;
	Else
		Information.DefaultValue = AttributeMetadata.Type.AdjustValue();
	EndIf;
	Return Information;
EndFunction

Function IsInternalData(UsageInstance, RefSearchExclusions)
	
	SearchException = RefSearchExclusions[UsageInstance.Metadata];
	
	// The data can be either a reference or a register record key.

	If SearchException = Undefined Then
		Return (UsageInstance.Ref = UsageInstance.Data); // Excluding self-reference.
	ElsIf SearchException = "*" Then
		Return True; // Excluding everything.
	Else
		For Each AttributePath In SearchException Do
			// If any exceptions are specified.
			
			// Relative path to the attribute:
			//   "<TabularPartOrAttributeName>[.<TabularPartAttributeName>]".
			
			If IsReference(TypeOf(UsageInstance.Data)) Then 
				
				// Checking whether the excluded path data contains the reference.
				
				FullMetadataObjectName = UsageInstance.Metadata.FullName();
				
				QueryText = 
					"SELECT
					|	TRUE
					|FROM
					|	&FullMetadataObjectName AS Table
					|WHERE
					|	&AttributePath = &RefToCheck
					|	AND Table.Ref = &Ref";
				
				QueryText = StrReplace(QueryText, "&FullMetadataObjectName", FullMetadataObjectName);
				QueryText = StrReplace(QueryText, "&AttributePath", AttributePath);
				
				Query = New Query;
				Query.Text = QueryText;
				Query.SetParameter("RefToCheck", UsageInstance.Ref);
				Query.SetParameter("Ref", UsageInstance.Data);
				
				Result = Query.Execute();
				
				If Not Result.IsEmpty() Then 
					Return True;
				EndIf;

			Else

				DataBuffer = New Structure(AttributePath);
				FillPropertyValues(DataBuffer, UsageInstance.Data);
				If DataBuffer[AttributePath] = UsageInstance.Ref Then 
					Return True;
				EndIf;

			EndIf;

		EndDo;
	EndIf;
	
	Return False;
	
EndFunction

#EndRegion

#Region Metadata

////////////////////////////////////////////////////////////////////////////////
// Metadata object type definition functions.

// Reference data types.

// Checks whether the metadata object belongs to the Document common  type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against Document type.
// 
// Returns:
//   Boolean - True if the object is a document.
//
Function IsDocument(MetadataObject) Export
	
	Return Metadata.Documents.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Catalog common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a catalog.
//
Function IsCatalog(MetadataObject) Export
	
	Return Metadata.Catalogs.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Enumeration common  type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is an enumeration.
//
Function IsEnum(MetadataObject) Export
	
	Return Metadata.Enums.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Exchange Plan common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is an exchange plan.
//
Function IsExchangePlan(MetadataObject) Export
	
	Return Metadata.ExchangePlans.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Chart of Characteristic Types common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a chart of characteristic types.
//
Function IsChartOfCharacteristicTypes(MetadataObject) Export
	
	Return Metadata.ChartsOfCharacteristicTypes.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Business Process common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a business process.
//
Function IsBusinessProcess(MetadataObject) Export
	
	Return Metadata.BusinessProcesses.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Task common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a task.
//
Function IsTask(MetadataObject) Export
	
	Return Metadata.Tasks.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Chart of Accounts common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a chart of accounts.
//
Function IsChartOfAccounts(MetadataObject) Export
	
	Return Metadata.ChartsOfAccounts.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Chart of Calculation Types common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a chart of calculation types.
//
Function IsChartOfCalculationTypes(MetadataObject) Export
	
	Return Metadata.ChartsOfCalculationTypes.Contains(MetadataObject);
	
EndFunction

// Registers

// Checks whether the metadata object belongs to the Information Register common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is an information register.
//
Function IsInformationRegister(MetadataObject) Export
	
	Return Metadata.InformationRegisters.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Accumulation Register common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is an accumulation register.
//
Function IsAccumulationRegister(MetadataObject) Export
	
	Return Metadata.AccumulationRegisters.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Accounting Register common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is an accounting register.
//
Function IsAccountingRegister(MetadataObject) Export
	
	Return Metadata.AccountingRegisters.Contains(MetadataObject);
	
EndFunction

// Checks whether the metadata object belongs to the Calculation Register common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a calculation register.
//
Function IsCalculationRegister(MetadataObject) Export
	
	Return Metadata.CalculationRegisters.Contains(MetadataObject);
	
EndFunction
// Constants

// Checks whether the metadata object belongs to the Constant common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a constant.
//
Function IsConstant(MetadataObject) Export
	
	Return Metadata.Constants.Contains(MetadataObject);
	
EndFunction

// Document journals

// Checks whether the metadata object belongs to the Document Journal common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a document journal.
//
Function IsDocumentJournal(MetadataObject) Export
	
	Return Metadata.DocumentJournals.Contains(MetadataObject);
	
EndFunction

// Sequences

// Checks whether the metadata object belongs to the Sequences common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a sequence.
//
Function IsSequence(MetadataObject) Export
	
	Return Metadata.Sequences.Contains(MetadataObject);
	
EndFunction

// ScheduledJobs

// Checks whether the metadata object belongs to the Scheduled Jobs common type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a scheduled job.
//
Function IsScheduledJob(MetadataObject) Export
	
	Return Metadata.ScheduledJobs.Contains(MetadataObject);
	
EndFunction

// Common

// Checks whether the metadata object belongs to the register type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//    Boolean - True if the object is a register.
//
Function IsRegister(MetadataObject) Export
	
	Return Metadata.AccountingRegisters.Contains(MetadataObject)
		Or Metadata.AccumulationRegisters.Contains(MetadataObject)
		Or Metadata.CalculationRegisters.Contains(MetadataObject)
		Or Metadata.InformationRegisters.Contains(MetadataObject);
		
EndFunction

// Checks whether the metadata object belongs to the reference type.
//
// Parameters:
//  MetadataObject - MetadataObject - object to compare against the specified type.
// 
// Returns:
//   Boolean - True if the object is a reference type object.
//
Function IsRefTypeObject(MetadataObject) Export
	
	MetadataObjectName = MetadataObject.FullName();
	Position = StrFind(MetadataObjectName, ".");
	If Position > 0 Then 
		BaseTypeName = Left(MetadataObjectName, Position - 1);
		Return BaseTypeName = "Catalog"
			Or BaseTypeName = "Document"
			Or BaseTypeName = "BusinessProcess"
			Or BaseTypeName = "Task"
			Or BaseTypeName = "ChartOfAccounts"
			Or BaseTypeName = "ExchangePlan"
			Or BaseTypeName = "ChartOfCharacteristicTypes"
			Or BaseTypeName = "ChartOfCalculationTypes";
	Else
		Return False;
	EndIf;
	
EndFunction

////////////////////////////////////////////////////////////////////////////////
// Procedures and functions for operations with types, metadata objects, and their string presentations.

// Returns names of attributes for an object of the specified type.
//
// Parameters:
//  Ref - AnyRef - a reference to a database item to use with the function.
//  Type - Type - attribute value type.
// 
// Returns:
//  String - a comma-separated string of configuration metadata object attributes.
//
// Example:
//  CompanyAttributes = Common.AttributeNamesByType (Document.Ref, Type("CatalogRef.Companies"));
//
Function AttributeNamesByType(Ref, Type) Export
	
	Result = "";
	//@skip-warning
	ObjectMetadata = Ref.Metadata();
	
	For Each Attribute In ObjectMetadata.Attributes Do
		If Attribute.Type.ContainsType(Type) Then
			Result = Result + ?(IsBlankString(Result), "", ", ") + Attribute.Name;
		EndIf;
	EndDo;
	
	Return Result;
EndFunction

// Returns a base type name by the passed metadata object value.
//
// Parameters:
//  MetadataObject - MetadataObject - a metadata object whose base type is to be determined.
// 
// Returns:
//  String - name of the base type for the passed metadata object value.
//
// Example:
//  BaseTypeName = Common.BaseTypeNameByMetadataObject(Metadata.Catalogs.Products); = "Catalogs".
//
Function BaseTypeNameByMetadataObject(MetadataObject) Export
	
	If Metadata.Documents.Contains(MetadataObject) Then
		Return "Documents";
		
	ElsIf Metadata.Catalogs.Contains(MetadataObject) Then
		Return "Catalogs";
		
	ElsIf Metadata.Enums.Contains(MetadataObject) Then
		Return "Enums";
		
	ElsIf Metadata.InformationRegisters.Contains(MetadataObject) Then
		Return "InformationRegisters";
		
	ElsIf Metadata.AccumulationRegisters.Contains(MetadataObject) Then
		Return "AccumulationRegisters";
		
	ElsIf Metadata.AccountingRegisters.Contains(MetadataObject) Then
		Return "AccountingRegisters";
		
	ElsIf Metadata.CalculationRegisters.Contains(MetadataObject) Then
		Return "CalculationRegisters";
		
	ElsIf Metadata.ExchangePlans.Contains(MetadataObject) Then
		Return "ExchangePlans";
		
	ElsIf Metadata.ChartsOfCharacteristicTypes.Contains(MetadataObject) Then
		Return "ChartsOfCharacteristicTypes";
		
	ElsIf Metadata.BusinessProcesses.Contains(MetadataObject) Then
		Return "BusinessProcesses";
		
	ElsIf Metadata.Tasks.Contains(MetadataObject) Then
		Return "Tasks";
		
	ElsIf Metadata.ChartsOfAccounts.Contains(MetadataObject) Then
		Return "ChartsOfAccounts";
		
	ElsIf Metadata.ChartsOfCalculationTypes.Contains(MetadataObject) Then
		Return "ChartsOfCalculationTypes";
		
	ElsIf Metadata.Constants.Contains(MetadataObject) Then
		Return "Constants";
		
	ElsIf Metadata.DocumentJournals.Contains(MetadataObject) Then
		Return "DocumentJournals";
		
	ElsIf Metadata.Sequences.Contains(MetadataObject) Then
		Return "Sequences";
		
	ElsIf Metadata.ScheduledJobs.Contains(MetadataObject) Then
		Return "ScheduledJobs";
		
	ElsIf Metadata.CalculationRegisters.Contains(MetadataObject.Parent())
		AND MetadataObject.Parent().Recalculations.Find(MetadataObject.Name) = MetadataObject Then
		Return "Recalculations";
		
	Else
		
		Return "";
		
	EndIf;
	
EndFunction

// Returns an object manager by the passed full name of a metadata object.
// Restriction: does not process business process route points.
//
// Parameters:
//  FullName - String - full name of a metadata object. Example: "Catalog.Company".
//
// Returns:
//  CatalogManager, DocumentManager, DataProcessorManager, InformationRegisterManager - an object manager.
// 
// Example:
//  CatalogManager= Common.ObjectManagerByFullName("Catalog.Companies");
//  EmptyRef = CatalogManager.EmptyRef();
//
Function ObjectManagerByFullName(FullName) Export
	Var MOClass, MetadataObjectName, Manager;
	
	NameParts = StrSplit(FullName, ".");
	
	If NameParts.Count() >= 2 Then
		MOClass = NameParts[0];
		MetadataObjectName  = NameParts[1];
	EndIf;
	
	If      Upper(MOClass) = "EXCHANGEPLAN" Then
		Manager = ExchangePlans;
		
	ElsIf Upper(MOClass) = "CATALOG" Then
		Manager = Catalogs;
		
	ElsIf Upper(MOClass) = "DOCUMENT" Then
		Manager = Documents;
		
	ElsIf Upper(MOClass) = "DOCUMENTJOURNAL" Then
		Manager = DocumentJournals;
		
	ElsIf Upper(MOClass) = "ENUM" Then
		Manager = Enums;
		
	ElsIf Upper(MOClass) = "REPORT" Then
		Manager = Reports;
		
	ElsIf Upper(MOClass) = "DATAPROCESSOR" Then
		Manager = DataProcessors;
		
	ElsIf Upper(MOClass) = "CHARTOFCHARACTERISTICTYPES" Then
		Manager = ChartsOfCharacteristicTypes;
		
	ElsIf Upper(MOClass) = "CHARTOFACCOUNTS" Then
		Manager = ChartsOfAccounts;
		
	ElsIf Upper(MOClass) = "CHARTOFCALCULATIONTYPES" Then
		Manager = ChartsOfCalculationTypes;
		
	ElsIf Upper(MOClass) = "INFORMATIONREGISTER" Then
		Manager = InformationRegisters;
		
	ElsIf Upper(MOClass) = "ACCUMULATIONREGISTER" Then
		Manager = AccumulationRegisters;
		
	ElsIf Upper(MOClass) = "ACCOUNTINGREGISTER" Then
		Manager = AccountingRegisters;
		
	ElsIf Upper(MOClass) = "CALCULATIONREGISTER" Then
		If NameParts.Count() = 2 Then
			// Calculation register
			Manager = CalculationRegisters;
		Else
			SubordinateMOClass = NameParts[2];
			SubordinateMOName = NameParts[3];
			If Upper(SubordinateMOClass) = "RECALCULATION" Then
				// Recalculation
				Try
					Manager = CalculationRegisters[MetadataObjectName].Recalculations;
					MetadataObjectName = SubordinateMOName;
				Except
					Manager = Undefined;
				EndTry;
			EndIf;
		EndIf;
		
	ElsIf Upper(MOClass) = "BUSINESSPROCESS" Then
		Manager = BusinessProcesses;
		
	ElsIf Upper(MOClass) = "TASK" Then
		Manager = Tasks;
		
	ElsIf Upper(MOClass) = "CONSTANT" Then
		Manager = Constants;
		
	ElsIf Upper(MOClass) = "SEQUENCE" Then
		Manager = Sequences;
	EndIf;
	
	If Manager <> Undefined Then
		Try
			Return Manager[MetadataObjectName];
		Except
			Manager = Undefined;
		EndTry;
	EndIf;

	Raise StrTemplate(NStr("ru = 'Неизвестный тип объекта метаданных ""%1""'; en = 'Invalid metadata object type: %1.'"), FullName);
EndFunction

// Returns an object manager by the passed object reference.
// Restriction: does not process business process route points.
// See also: Common.ObjectManagerByFullName.
//
// Parameters:
//  Ref - AnyRef - an object whose manager is sought.
//
// Returns:
//  CatalogManager, DocumentManager, DataProcessorManager, InformationRegisterManager - an object manager.
//
// Example:
//  CatalogManager = Common.ObjectManagerByRef(RefToCompany);
//  EmptyRef = CatalogManager.EmptyRef();
//
Function ObjectManagerByRef(Ref) Export
	
	ObjectName = Ref.Metadata().Name;
	RefType = TypeOf(Ref);
	
	If Catalogs.AllRefsType().ContainsType(RefType) Then
		Return Catalogs[ObjectName];
		
	ElsIf Documents.AllRefsType().ContainsType(RefType) Then
		Return Documents[ObjectName];
		
	ElsIf BusinessProcesses.AllRefsType().ContainsType(RefType) Then
		Return BusinessProcesses[ObjectName];
		
	ElsIf ChartsOfCharacteristicTypes.AllRefsType().ContainsType(RefType) Then
		Return ChartsOfCharacteristicTypes[ObjectName];
		
	ElsIf ChartsOfAccounts.AllRefsType().ContainsType(RefType) Then
		Return ChartsOfAccounts[ObjectName];
		
	ElsIf ChartsOfCalculationTypes.AllRefsType().ContainsType(RefType) Then
		Return ChartsOfCalculationTypes[ObjectName];
		
	ElsIf Tasks.AllRefsType().ContainsType(RefType) Then
		Return Tasks[ObjectName];
		
	ElsIf ExchangePlans.AllRefsType().ContainsType(RefType) Then
		Return ExchangePlans[ObjectName];
		
	ElsIf Enums.AllRefsType().ContainsType(RefType) Then
		Return Enums[ObjectName];
	Else
		Return Undefined;
	EndIf;
	
EndFunction

// Checking whether the passed type is a reference data type.
// Returns False for Undefined type.
//
// Parameters:
//  TypeToCheck - Type - a reference type to check.
//
// Returns:
//  Boolean - True if the type is a reference type.
//
Function IsReference(TypeToCheck) Export
	
	Return TypeToCheck <> Type("Undefined") AND AllRefsTypeDescription().ContainsType(TypeToCheck);
	
EndFunction

// Checks whether the infobase record exists by its reference.
//
// Parameters:
//  RefToCheck - AnyRef - a value of an infobase reference.
// 
// Returns:
//  Boolean - True if exists.
//
Function RefExists(RefToCheck) Export
	
	QueryText = "
	|SELECT TOP 1
	|	1
	|FROM
	|	[TableName]
	|WHERE
	|	Ref = &Ref
	|";
	
	QueryText = StrReplace(QueryText, "[TableName]", TableNameByRef(RefToCheck));
	
	Query = New Query;
	Query.Text = QueryText;
	Query.SetParameter("Ref", RefToCheck);
	
	SetPrivilegedMode(True);
	
	Return NOT Query.Execute().IsEmpty();
	
EndFunction

// Returns a metadata object kind name by the passed object reference.
// Restriction: does not process business process route points.
// See also: ObjectKindByType.
//
// Parameters:
//  Ref - AnyRef - an object of the kind to search for.
//
// Returns:
//  String - a metadata object kind name. For example: "Catalog", "Document".
// 
Function ObjectKindByRef(Ref) Export
	
	Return ObjectKindByType(TypeOf(Ref));
	
EndFunction 

// Returns a metadata object kind name by the passed object type.
// Restriction: does not process business process route points.
// See also: ObjectKindByRef.
//
// Parameters:
//  ObjectType - Type - an applied object type defined in the configuration.
//
// Returns:
//  String - a metadata object kind name. For example: "Catalog", "Document".
// 
Function ObjectKindByType(ObjectType) Export
	
	If Catalogs.AllRefsType().ContainsType(ObjectType) Then
		Return "Catalog";
	
	ElsIf Documents.AllRefsType().ContainsType(ObjectType) Then
		Return "Document";
	
	ElsIf BusinessProcesses.AllRefsType().ContainsType(ObjectType) Then
		Return "BusinessProcess";
	
	ElsIf ChartsOfCharacteristicTypes.AllRefsType().ContainsType(ObjectType) Then
		Return "ChartOfCharacteristicTypes";
	
	ElsIf ChartsOfAccounts.AllRefsType().ContainsType(ObjectType) Then
		Return "ChartOfAccounts";
	
	ElsIf ChartsOfCalculationTypes.AllRefsType().ContainsType(ObjectType) Then
		Return "ChartOfCalculationTypes";
	
	ElsIf Tasks.AllRefsType().ContainsType(ObjectType) Then
		Return "Task";
	
	ElsIf ExchangePlans.AllRefsType().ContainsType(ObjectType) Then
		Return "ExchangePlan";
	
	ElsIf Enums.AllRefsType().ContainsType(ObjectType) Then
		Return "Enum";
	
	Else
		
    Raise StrTemplate(NStr("ru='Неверный тип значения параметра (%1)'; en = 'Invalid parameter value type: %1.'"), String(ObjectType));
	
	EndIf;
	
EndFunction
// Returns full metadata object name by the passed reference value.
//
// Parameters:
//  Ref - AnyRef - an object whose infobase table name is sought.
// 
// Returns:
//  String - the full name of the metadata object for the specified object. For example, "Catalog.Products".
//
Function TableNameByRef(Ref) Export
	
	Return Ref.Metadata().FullName();
	
EndFunction

// Checks whether the value is a reference type value.
//
// Parameters:
//  Value - Arbitrary - a value to check.
//
// Returns:
//  Boolean - True if the value is a reference type value.
//
Function RefTypeValue(Value) Export
	
	Return IsReference(TypeOf(Value));
	
EndFunction

// Checks whether the object is an item group.
//
// Parameters:
//  Object - AnyRef, Object - an object to check.
//
// Returns:
//  Boolean - True if the object is an item group.
//
Function ObjectIsFolder(Object) Export
	
	If RefTypeValue(Object) Then
		Ref = Object;
	Else
		Ref = Object.Ref;
	EndIf;
	
	ObjectMetadata = Ref.Metadata();
	
	If IsCatalog(ObjectMetadata) Then
		
		If NOT ObjectMetadata.Hierarchical
		 OR ObjectMetadata.HierarchyType
		     <> Metadata.ObjectProperties.HierarchyType.HierarchyFoldersAndItems Then
			
			Return False;
		EndIf;
		
	ElsIf NOT IsChartOfCharacteristicTypes(ObjectMetadata) Then
		Return False;
		
	ElsIf NOT ObjectMetadata.Hierarchical Then
		Return False;
	EndIf;
	
	If Ref <> Object Then
		Return Object.IsFolder;
	EndIf;
	
	Return ObjectAttributeValue(Ref, "IsFolder") = True;
	
EndFunction

/// Returns a string presentation of the type.
// For reference types, returns a string in format "CatalogRef.ObjectName" or "DocumentRef.ObjectName".
// For any other types, converts the type to string. Example: "Number".
//
// Parameters:
//  Type - type - a type whose presentation is sought.
//
// Returns:
//  String - a type presentation.
//
Function TypePresentationString(Type) Export
	
	Presentation = "";
	
	If IsReference(Type) Then
	
		FullName = Metadata.FindByType(Type).FullName();
		ObjectName = StrSplit(FullName, ".")[1];
		
		If Catalogs.AllRefsType().ContainsType(Type) Then
			Presentation = "CatalogRef";
		
		ElsIf Documents.AllRefsType().ContainsType(Type) Then
			Presentation = "DocumentRef";
		
		ElsIf BusinessProcesses.AllRefsType().ContainsType(Type) Then
			Presentation = "BusinessProcessRef";
		
		ElsIf ChartsOfCharacteristicTypes.AllRefsType().ContainsType(Type) Then
			Presentation = "ChartOfCharacteristicTypesRef";
		
		ElsIf ChartsOfAccounts.AllRefsType().ContainsType(Type) Then
			Presentation = "ChartOfAccountsRef";
		
		ElsIf ChartsOfCalculationTypes.AllRefsType().ContainsType(Type) Then
			Presentation = "ChartOfCalculationTypesRef";
		
		ElsIf Tasks.AllRefsType().ContainsType(Type) Then
			Presentation = "TaskRef";
		
		ElsIf ExchangePlans.AllRefsType().ContainsType(Type) Then
			Presentation = "ExchangePlanRef";
		
		ElsIf Enums.AllRefsType().ContainsType(Type) Then
			Presentation = "EnumRef";
		
		EndIf;
		
		Result = ?(Presentation = "", Presentation, Presentation + "." + ObjectName);
		
	Else
		
		Result = String(Type);
		
	EndIf;
	
	Return Result;
	
EndFunction

//  Returns a value table with the required property information for all attributes of a metadata object.
// Gets property values of standard and custom attributes (custom attributes are the attributes created in Designer mode).
//
// Parameters:
//  MetadataObject  - MetadataObject - an object whose attribute property values are sought.
//                      Example: Metadata.Document.Invoice
//  Properties - String - comma-separated attribute properties whose values to be retrieved.
//                      Example: "Name, Type, Synonym, Tooltip".
//
// Returns:
//  ValueTable - required property information for all attributes of the metadata object.
//
Function ObjectPropertiesDetails(MetadataObject, Properties) Export
	
	PropertiesArray = StrSplit(Properties, ",");
	
	// Function return value.
	ObjectPropertyDetailsTable = New ValueTable;
	
	// Adding fields to the value table according to the names of the passed properties.
	For Each PropertyName In PropertiesArray Do
		ObjectPropertyDetailsTable.Columns.Add(TrimAll(PropertyName));
	EndDo;
	
	// Filling table rows with metadata object attribute values.
	For Each Attribute In MetadataObject.Attributes Do
		FillPropertyValues(ObjectPropertyDetailsTable.Add(), Attribute);
	EndDo;
	
	// Filling table rows with standard metadata object attribute properties.
	For Each Attribute In MetadataObject.StandardAttributes Do
		FillPropertyValues(ObjectPropertyDetailsTable.Add(), Attribute);
	EndDo;
	
	Return ObjectPropertyDetailsTable;
	
EndFunction

// Returns a flag indicating whether the attribute is a standard attribute.
//
// Parameters:
//  StandardAttributes - StandardAttributeDescriptions - the type and value describe a collection of 
//                                                         settings for various standard attributes;
//  AttributeName         - String - an attribute to check whether it is a standard attribute or not.
//                                  
// 
// Returns:
//   Boolean - True if the attribute is a standard attribute.
//
Function IsStandardAttribute(StandardAttributes, AttributeName) Export
	
	For Each Attribute In StandardAttributes Do
		If Attribute.Name = AttributeName Then
			Return True;
		EndIf;
	EndDo;
	Return False;
	
EndFunction

// Checks whether the attribute with the passed name exists among the object attributes.
//
// Parameters:
//  AttributeName - String - attribute name.
//  MetadataObject - MetadataObject - an object to search for the attribute.
//
// Returns:
//  Boolean - True if the attribute is found.
//
Function HasObjectAttribute(AttributeName, ObjectMetadata) Export

	Return NOT (ObjectMetadata.Attributes.Find(AttributeName) = Undefined);

EndFunction

// Checks whether the type description contains only one value type and it is equal to the specified 
// type.
//
// Parameters:
//   TypeDetails - TypesDetails - a type collection to check.
//   ValueType  - Type - a type to check.
//
// Returns:
//   Boolean - True if the types match.
//
// Example:
//  If Common.TypeDetailsContainsType(ValueTypeProperties, Type("Boolean") Then
//    // Displaying the field as a check box.
//  EndIf.
//
Function TypeDetailsContainsType(TypeDetails, ValueType) Export
	
	If TypeDetails.Types().Count() = 1
	   AND TypeDetails.Types().Get(0) = ValueType Then
		Return True;
	EndIf;
	
	Return False;
	
EndFunction

// Creates a TypesDetails object that contains the String type.
//
// Parameters:
//  StringLength - Number - string length.
//
// Returns:
//  TypesDetails - description of the String type.
//
Function StringTypeDetails(StringLength) Export

	Array = New Array;
	Array.Add(Type("String"));

	StringQualifier = New StringQualifiers(StringLength, AllowedLength.Variable);

	Return New TypeDescription(Array, , StringQualifier);

EndFunction

// Creates a TypesDetails object that contains the Number type.
//
// Parameters:
//  NumberOfDigits - Number - the total number of digits in a number (both in the integer part and 
//                        the fractional part).
//  DigitsInFractionalPart - Number - number of digits in the fractional part.
//  NumberSign - AllowedSign - allowed sign of the number.
//
// Returns:
//  TypesDetails - description of Number type.
Function TypeDescriptionNumber(NumberOfDigits, DigitsInFractionalPart = 0, NumberSign = Undefined) Export

	If NumberSign = Undefined Then
		NumberQualifier = New NumberQualifiers(NumberOfDigits, DigitsInFractionalPart);
	Else
		NumberQualifier = New NumberQualifiers(NumberOfDigits, DigitsInFractionalPart, NumberSign);
	EndIf;

	Return New TypeDescription("Number", NumberQualifier);

EndFunction

// Creates a TypesDetails object that contains the Date type.
//
// Parameters:
//  DateParts - DateParts - a set of Date type value usage options.
//
// Returns:
//  TypesDetails - description of Date type.
Function DateTypeDetails(DateParts) Export

	Array = New Array;
	Array.Add(Type("Date"));

	DateQualifier = New DateQualifiers(DateParts);

	Return New TypeDescription(Array, , , DateQualifier);

EndFunction

#EndRegion

#Region SettingsStorage

////////////////////////////////////////////////////////////////////////////////
// Saving, reading, and deleting settings from storages.

// Saves a setting to the common settings storage as the Save method of 
// StandardSettingsStorageManager or SettingsStorageManager.<Storage name> object. Setting keys 
// exceeding 128 characters are supported by hashing the key part that exceeds 96 characters.
// 
// If the SaveUserData right is not granted, data save fails and no error is raised.
//
// Parameters:
//   ObjectKey - String - see the Syntax Assistant.
//   SettingsKey - String - see the Syntax Assistant.
//   Settings - Arbitrary - see the Syntax Assistant.
//   SettingsDescription - SettingsDescription - see the Syntax Assistant.
//   UserName - String - see the Syntax Assistant.
//   UpdateCachedValues - Boolean - the flag that indicates whether to execute the method.
//
Procedure CommonSettingsStorageSave(ObjectKey, SettingsKey, Settings,
			SettingsDetails = Undefined,
			Username = Undefined,
			UpdateCachedValues = False) Export
	
	StorageSave(CommonSettingsStorage,
		ObjectKey,
		SettingsKey,
		Settings,
		SettingsDetails,
		Username,
		UpdateCachedValues);
	
EndProcedure

// Saves settings to the common settings storage as the Save method of 
// StandardSettingsStorageManager or SettingsStorageManager.<Storage name> object. Setting keys 
// exceeding 128 characters are supported by hashing the key part that exceeds 96 characters.
// 
// If the SaveUserData right is not granted, data save fails and no error is raised.
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
Procedure CommonSettingsStorageSaveArray(MultipleSettings,
			UpdateCachedValues = False) Export
	
	If Not AccessRight("SaveUserData", Metadata) Then
		Return;
	EndIf;
	
	For Each Item In MultipleSettings Do
		CommonSettingsStorage.Save(Item.Object, SettingsKey(Item.Settings), Item.Value);
	EndDo;
	
	If UpdateCachedValues Then
		RefreshReusableValues();
	EndIf;
	
EndProcedure

// Loads a setting from the general settings storage as the Load method, 
// StandardSettingsStorageManager objects, or SettingsStorageManager.<Storage name>. The setting key 
// supports more than 128 characters by hashing the part that exceeds 96 characters.
// 
// If no settings are found, returns the default value.
// If the SaveUserData right is not granted, the default value is returned and no error is raised.
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
	
	Return StorageLoad(CommonSettingsStorage,
		ObjectKey,
		SettingsKey,
		DefaultValue,
		SettingsDetails,
		Username);
	
EndFunction

// Removes a setting from the general settings storage as the Remove method, 
// StandardSettingsStorageManager objects, or SettingsStorageManager.<Storage name>. The setting key 
// supports more than 128 characters by hashing the part that exceeds 96 characters.
// 
// If the SaveUserData right is not granted, no data is deleted and no error is raised.
//
// Parameters:
//   ObjectKey - String, Undefined - see the Syntax Assistant.
//   SettingsKey - String, Undefined - see the Syntax Assistant.
//   UserName - String, Undefined - see the Syntax Assistant.
//
Procedure CommonSettingsStorageDelete(ObjectKey, SettingsKey, Username) Export
	
	StorageDelete(CommonSettingsStorage,
		ObjectKey,
		SettingsKey,
		Username);
	
EndProcedure

// Saves a setting to the system settings storage as the Save method of 
// StandardSettingsStorageManager object. Setting keys exceeding 128 characters are supported by 
// hashing the key part that exceeds 96 characters.
// If the SaveUserData right is not granted, data save fails and no error is raised.
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
	
	StorageSave(SystemSettingsStorage, 
		ObjectKey,
		SettingsKey,
		Settings,
		SettingsDetails,
		Username,
		UpdateCachedValues);
	
EndProcedure

// Loads a setting from the system settings storage as the Load method or the 
// StandardSettingsStorageManager object. The setting key supports more than 128 characters by 
// hashing the part that exceeds 96 characters.
// If no settings are found, returns the default value.
// If the SaveUserData right is not granted, the default value is returned and no error is raised.
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
	
	Return StorageLoad(SystemSettingsStorage,
		ObjectKey,
		SettingsKey,
		DefaultValue,
		SettingsDetails,
		Username);
	
EndFunction

// Removes a setting from the system settings storage as the Remove method or the 
// StandardSettingsStorageManager object. The setting key supports more than 128 characters by 
// hashing the part that exceeds 96 characters.
// If the SaveUserData right is not granted, no data is deleted and no error is raised.
//
// Parameters:
//   ObjectKey - String, Undefined - see the Syntax Assistant.
//   SettingsKey - String, Undefined - see the Syntax Assistant.
//   UserName - String, Undefined - see the Syntax Assistant.
//
Procedure SystemSettingsStorageDelete(ObjectKey, SettingsKey, Username) Export
	
	StorageDelete(SystemSettingsStorage,
		ObjectKey,
		SettingsKey,
		Username);
	
EndProcedure

// Saves a setting to the form data settings storage as the Save method of 
// StandardSettingsStorageManager or SettingsStorageManager.<Storage name> object. Setting keys 
// exceeding 128 characters are supported by hashing the key part that exceeds 96 characters.
// 
// If the SaveUserData right is not granted, data save fails and no error is raised.
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
			SettingsDetails = Undefined,
			Username = Undefined, 
			UpdateCachedValues = False) Export
	
	StorageSave(FormDataSettingsStorage,
		ObjectKey,
		SettingsKey,
		Settings,
		SettingsDetails,
		Username,
		UpdateCachedValues);
	
EndProcedure

// Retrieves the setting from the form data settings storage using the Load method for 
// StandardSettingsStorageManager or SettingsStorageManager.<Storage name> objects. Setting keys 
// exceeding 128 characters are supported by hashing the key part that exceeds 96 characters.
// 
// If no settings are found, returns the default value.
// If the SaveUserData right is not granted, the default value is returned and no error is raised.
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
	
	Return StorageLoad(FormDataSettingsStorage,
		ObjectKey,
		SettingsKey,
		DefaultValue,
		SettingsDetails, 
		Username);
	
EndFunction

// Deletes the setting from the form data settings storage using the Delete method for 
// StandardSettingsStorageManager or SettingsStorageManager.<Storage name> objects. Setting keys 
// exceeding 128 characters are supported by hashing the key part that exceeds 96 characters.
// 
// If the SaveUserData right is not granted, no data is deleted and no error is raised.
//
// Parameters:
//   ObjectKey - String, Undefined - see the Syntax Assistant.
//   SettingsKey - String, Undefined - see the Syntax Assistant.
//   UserName - String, Undefined - see the Syntax Assistant.
//
Procedure FormDataSettingsStorageDelete(ObjectKey, SettingsKey, Username) Export
	
	StorageDelete(FormDataSettingsStorage,
		ObjectKey,
		SettingsKey,
		Username);
	
EndProcedure

#EndRegion

#Region Algorithms

Function ExecuteAlgorithm(AlgorithmRef, IncomingParameters = Undefined, ExecutionError = False,
	ErrorMessage = "") Export
	Return UT_AlgorithmsClientServer.ExecuteAlgorithm(AlgorithmRef, IncomingParameters, ExecutionError,
		ErrorMessage)
EndFunction

Function GetRefCatalogAlgorithms(Algorithm) Export
	If TypeOf(Algorithm) = Type("CatalogRef.UT_Algorithms") Then
		Return Algorithm;
	ElsIf TypeOf(Algorithm) = Type("UUID") Then
		Return Catalogs.UT_Algorithms.GetRef(Algorithm);
	ElsIf TypeOf(Algorithm) = Type("String") Then
		If Left(Algorithm, 5) = "GUID_" Then // SSL Additional DataProcessor 
			UUIDString = Mid(Algorithm, 6);
			ref = Catalogs.UT_Algorithms.GetRef(New UUID(UUIDString));
			Return ?(IsBlankString(ref.Наименование), Undefined, ref);
		EndIf;
		FoundedByName = Catalogs.UT_Algorithms.FindByDescription(Algorithm, True);
		If FoundedByName = Undefined Then
			Try
				CodeNumber = Number(Right(Algorithm, 5));
				FoundedByCode = Catalogs.UT_Algorithms.FindByCode(CodeNumber);
				Если FoundedByCode = Undefined Then
					Return Undefined;
				Иначе
					Return FoundedByCode;
				КонецЕсли;
			Except
				Return Undefined;
			EndTry;
		Else
			Return FoundedByName;
		EndIf;
	Else
		Return Undefined;
	EndIf;
EndFunction

#EndRegion

#Region WriteObjects

Procedure  SetMarkOfWritingWithOutChangesAutoRecording (Object, WithOutAutoRecording = False)
	If Not WithOutAutoRecording Then
		Return;
	EndIf;

	Try
		Object.DataExchange.Recipients.AutoFill = Not WithOutAutoRecording;
	Except
				// It's item of  ExchangePlan at 8.3.5+ platform
	EndTry;
EndProcedure

Function ExecuteObjectBeforeWriteProcedure(Object, _BeforeWriteProcedureText)
	Result=True;

	If Not ValueIsFilled(_BeforeWriteProcedureText) Then
		Return Result;
	EndIf;

	Try
		Execute (_BeforeWriteProcedureText);
	Except
		UT_CommonClientServer.MessageToUser(StrTemplate(NSTR("ru = 'Объект: %1. Ошибка при выполнении процедуры ПередЗаписью: %2';en = 'Object: %1. Error when executing procedure BeforeWrite: %2'"), 
						Object, BriefErrorDescription(ErrorInfo())));
		Result=False;
		
	EndTry;
	Return Result;
EndFunction

Function WriteObjectToDB(Object, WriteSettings, Val Action = "Write", Val WriteMode = Undefined,
	ReplaceRefs = False) Export
	
	If WriteSettings.PrivilegedMode Then
		SetPrivilegedMode(True);
	EndIf;

	If WriteSettings.WritingInLoadMode Then
		Object.DataExchange.Load = True;
	EndIf;

	SetMarkOfWritingWithOutChangesAutoRecording(Object, WriteSettings.WithOutChangesAutoRecording);

	If WriteSettings.UseAdditionalProperties And WriteSettings.AdditionalProperties.Count() > 0 Then
		For Each KeyValue In WriteSettings.AdditionalProperties Do
			Object.AdditionalProperties.Insert(KeyValue.Key, KeyValue.Value);
		EndDo;
	EndIf;

	If WriteSettings.UseBeforeWriteProcedure Then
		If Not ExecuteObjectBeforeWriteProcedure(Object, WriteSettings.BeforeWriteProcedure) Then
			Return False;
		EndIf;
	EndIf;

	Result=True;
	Try
		If Action = "Write" Then

			If WriteMode <> Undefined Then
				Object.Write(WriteMode);
			Else
				Object.Write();
			EndIf;

		ElsIf Action = "SetDeletionMark" Then
			IncludingSubordinates=False;
			Если ReplaceRefs Then
				ObjectMetadata = Object.Metadata();
				If IsCatalog(ObjectMetadata) Or IsChartOfCharacteristicTypes(ObjectMetadata) Or IsChartOfAccounts(
				ObjectMetadata) Then
					IncludingSubordinates=False;
				EndIf;
			EndIf;
			Object.SetDeletionMark(True, IncludingSubordinates);

		ElsIf Action = "UnSetDeletionMark" Then
			Object.SetDeletionMark(False);
		ElsIf Action = "DirectDeletion" Then
			Object.Delete();
		EndIf;

	Except
		UT_CommonClientServer.MessageToUser(BriefErrorDescription(ErrorInfo()));
		Result=False;
	EndTry;

	If WriteSettings.PrivilegedMode Then
		SetPrivilegedMode(False);
	EndIf;

	Return Result;
EndFunction
#EndRegion