#Region Public

#Region СозданиеЭлементовФормы

Procedure FormOnCreateAtServer(Form, ВидРедактора = Undefined) Export
	If ВидРедактора = Undefined Then
		ПараметрыРедактора = CodeEditorCurrentSettings();
		ВидРедактора = ПараметрыРедактора.Variant;
	EndIf;
	ВариантыРедактора = UT_CodeEditorClientServer.ВариантыРедактораКода();
	
	ЭтоWindowsКлиент = False;
	ЭтоВебКлиент = True;
	
	ПараметрыСеансаВХранилище = UT_CommonServerCall.CommonSettingsStorageLoad(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(),
		UT_CommonClientServer.SessionParametersSettingsKey());
	If Type(ПараметрыСеансаВХранилище) = Type("Structure") Then
		If ПараметрыСеансаВХранилище.Property("HTMLFieldBasedOnWebkit") Then
			If Not ПараметрыСеансаВХранилище.HTMLFieldBasedOnWebkit Then
				ВидРедактора = ВариантыРедактора.Text;
			EndIf;
		EndIf;
		If ПараметрыСеансаВХранилище.Property("IsWindowsClient") Then
			ЭтоWindowsКлиент = ПараметрыСеансаВХранилище.IsWindowsClient;
		EndIf;
		If ПараметрыСеансаВХранилище.Property("IsWebClient") Then
			ЭтоВебКлиент = ПараметрыСеансаВХранилище.IsWebClient;
		EndIf;
		
	EndIf;
	
	ИмяРеквизитаВидРедактора=UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора();
	ИмяРеквизитаАдресБиблиотеки=UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаАдресБиблиотеки();
	ИмяРеквизитаРедактораКодаСписокРедакторовФормы = UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаСписокРедакторовФормы();
	
	МассивРеквизитов=New Array;
	МассивРеквизитов.Add(New FormAttribute(ИмяРеквизитаВидРедактора, New TypeDescription("String", , New StringQualifiers(20,
		AllowedLength.Variable)), "", "", True));
	МассивРеквизитов.Add(New FormAttribute(ИмяРеквизитаАдресБиблиотеки, New TypeDescription("String", , New StringQualifiers(0,
		AllowedLength.Variable)), "", "", True));
	МассивРеквизитов.Add(New FormAttribute(ИмяРеквизитаРедактораКодаСписокРедакторовФормы, New TypeDescription, "", "", True));
		
	Form.ChangeAttributes(МассивРеквизитов);
	
	Form[ИмяРеквизитаВидРедактора]=ВидРедактора;
	Form[ИмяРеквизитаАдресБиблиотеки] = ПоместитьБиблиотекуВоВременноеХранилище(Form.UUID, ЭтоWindowsКлиент, ЭтоВебКлиент, ВидРедактора);
	Form[ИмяРеквизитаРедактораКодаСписокРедакторовФормы] = New Structure;
EndProcedure

Procedure CreateCodeEditorItems(Form, ИдентификаторРедактора, ПолеРедактора, ЯзыкРедактора = "bsl") Export
	ИмяРеквизитаВидРедактора=UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора();
	
	ВидРедактора = Form[ИмяРеквизитаВидРедактора];
	
	ДанныеРедактора = New Structure;

	If UT_CodeEditorClientServer.РедакторКодаИспользуетПолеHTML(ВидРедактора) Then
		If ПолеРедактора.Type <> FormFieldType.HTMLDocumentField Then
			ПолеРедактора.Type = FormFieldType.HTMLDocumentField;
		EndIf;
		ПолеРедактора.SetAction("DocumentComplete", "Подключаемый_ПолеРедактораДокументСформирован");
		ПолеРедактора.SetAction("OnClick", "Подключаемый_ПолеРедактораПриНажатии");

		ДанныеРедактора.Insert("Инициализирован", False);

	Else
		ПолеРедактора.Type = FormFieldType.TextDocumentField;
		ДанныеРедактора.Insert("Инициализирован", True);
	EndIf;

	ДанныеРедактора.Insert("Lang", ЯзыкРедактора);
	ДанныеРедактора.Insert("ПолеРедактора", ПолеРедактора.Name);
	ДанныеРедактора.Insert("ИмяРеквизита", ПолеРедактора.DataPath);
	
	ВариантыРедактора = UT_CodeEditorClientServer.ВариантыРедактораКода();

	ПараметрыРедактора = CodeEditorCurrentSettings();
	ДанныеРедактора.Insert("ПараметрыРедактора", ПараметрыРедактора);

	If ВидРедактора = ВариантыРедактора.Monaco Then
		For Each КлючЗначение ИЗ ПараметрыРедактора.Monaco Do
			ДанныеРедактора.ПараметрыРедактора.Insert(КлючЗначение.Key, КлючЗначение.Value);
		EndDo;
	EndIf;
	
	Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()].Insert(ИдентификаторРедактора,  ДанныеРедактора);	
EndProcedure

#EndRegion

Function ПоместитьБиблиотекуВоВременноеХранилище(ИдентификаторФормы, ЭтоWindowsКлиент, ЭтоВебКлиент, ВидРедактора=Undefined) Export
	If ВидРедактора = Undefined Then
		ВидРедактора = ТекущийВариантРедактораКода1С();
	EndIf;
	ВариантыРедактора = UT_CodeEditorClientServer.ВариантыРедактораКода();
	
	If ВидРедактора = ВариантыРедактора.Monaco Then
		If ЭтоWindowsКлиент Then
			ДвоичныеДанныеБиблиотеки=GetCommonTemplate("UT_MonacoEditorWindows");
		Else
			ДвоичныеДанныеБиблиотеки=GetCommonTemplate("UT_MonacoEditor");
		EndIf;
	ElsIf ВидРедактора = ВариантыРедактора.Ace Then
		ДвоичныеДанныеБиблиотеки=GetCommonTemplate("UT_Ace");
	Else
		Return Undefined;
	EndIf;
	
	СтруктураБиблиотеки=New Map;

	If Not ЭтоВебКлиент Then
		СтруктураБиблиотеки.Insert("editor.zip",ДвоичныеДанныеБиблиотеки);

		Return PutToTempStorage(СтруктураБиблиотеки, ИдентификаторФормы);
	EndIf;
	
	КаталогНаСервере=GetTempFileName();
	CreateDirectory(КаталогНаСервере);

	Stream=ДвоичныеДанныеБиблиотеки.OpenStreamForRead();

	ЧтениеZIP=New ZipFileReader(Stream);
	ЧтениеZIP.ExtractAll(КаталогНаСервере, ZIPRestoreFilePathsMode.Restore);


	ФайлыАрхива=FindFiles(КаталогНаСервере, "*", True);
	For Each ФайлБиблиотеки In ФайлыАрхива Do
		КлючФайла=StrReplace(ФайлБиблиотеки.FullName, КаталогНаСервере + GetPathSeparator(), "");
		If ФайлБиблиотеки.IsDirectory() Then
			Continue;
		EndIf;

		СтруктураБиблиотеки.Insert(КлючФайла, New BinaryData(ФайлБиблиотеки.FullName));
	EndDo;

	АдресБиблиотеки=PutToTempStorage(СтруктураБиблиотеки, ИдентификаторФормы);

	Try
		DeleteFiles(КаталогНаСервере);
	Except
		// TODO:
	EndTry;

	Return АдресБиблиотеки;
EndFunction

#Region НастройкиИнструментов


Function ТекущийВариантРедактораКода1С() Export
	ПараметрыРедактораКода = CodeEditorCurrentSettings();
	
	РедакторКода = ПараметрыРедактораКода.Variant;
	
	УИ_ПараметрыСеанса = UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.ObjectKeyInSettingsStorage(),
		UT_CommonClientServer.SessionParametersSettingsKey());
		
	If Type(УИ_ПараметрыСеанса) = Type("Structure") Then
		If УИ_ПараметрыСеанса.HTMLFieldBasedOnWebkit<>True Then
			РедакторКода = UT_CodeEditorClientServer.ВариантыРедактораКода().Text;
		EndIf;
	EndIf;
	
	Return РедакторКода;
EndFunction

Procedure УстановитьНовыеНастройкиРедактораКода(НовыеНастройки) Export
	UT_Common.CommonSettingsStorageSave(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "ПараметрыРедактораКода",
		НовыеНастройки);
EndProcedure

Function CodeEditorCurrentSettings() Export
	СохраненныеПараметрыРедактора = UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "ПараметрыРедактораКода");

	ПараметрыПоУмолчанию = UT_CodeEditorClientServer.ПараметрыРедактораКодаПоУмолчанию();
	If СохраненныеПараметрыРедактора = Undefined Then		
		ПараметрыРедактораMonaco = ТекущиеПараметрыРедактораMonaco();
		
		FillPropertyValues(ПараметрыПоУмолчанию.Monaco, ПараметрыРедактораMonaco);
	Else
		FillPropertyValues(ПараметрыПоУмолчанию, СохраненныеПараметрыРедактора,,"Monaco");
		FillPropertyValues(ПараметрыПоУмолчанию.Monaco, СохраненныеПараметрыРедактора.Monaco);
	EndIf;
	
	Return ПараметрыПоУмолчанию;
	
EndFunction

#EndRegion

#Region WorkWithMetaData

Function ConfigurationScriptVariant() Export
	If Metadata.ScriptVariant = Metadata.ObjectProperties.ScriptVariant.English Then
		Return "English";
	Else
		Return "Russian";
	EndIf;
EndFunction

Function ОбъектМетаданныхИмеетПредопределенные(ИмяТипаМетаданного)
	
	Objects = New Array();
	Objects.Add("справочник");
	Objects.Add("справочники");
	Objects.Add("плансчетов");	
	Objects.Add("планысчетов");	
	Objects.Add("планвидовхарактеристик");
	Objects.Add("планывидовхарактеристик");
	Objects.Add("планвидоврасчета");
	Objects.Add("планывидоврасчета");
	
	Return Objects.Find(Lower(ИмяТипаМетаданного)) <> Undefined;
	
EndFunction

Function ОбъектМетаданныхИмеетВиртуальныеТаблицы(ИмяТипаМетаданного)
	
	Objects = New Array();
	Objects.Add("InformationRegisters");
	Objects.Add("AccumulationRegisters");	
	Objects.Add("CalculationRegisters");
	Objects.Add("AccountingRegisters");
	
	Return Objects.Find(ИмяТипаМетаданного) <> Undefined;
	
EndFunction


Function ОписаниеРеквизитаОбъектаМетаданных(Attribute,AllRefsType)
	LongDesc = New Structure;
	LongDesc.Insert("Name", Attribute.Name);
	LongDesc.Insert("Synonym", Attribute.Synonym);
	LongDesc.Insert("Comment", Attribute.Comment);
	
	СсылочныеТипы = New Array;
	For каждого ТекТ In Attribute.Type.Types() Do
		If AllRefsType.ContainsType(ТекТ) Then
			СсылочныеТипы.Add(ТекТ);
		EndIf;
	EndDo;
	LongDesc.Insert("Type", New TypeDescription(СсылочныеТипы));
	
	Return LongDesc;
EndFunction

Function ОписаниеОбъектаМетаданныхКонфигурацииПоИмени(ВидОбъекта, ObjectName) Export
	AllRefsType = UT_Common.AllRefsTypeDescription();

	Return ОписаниеОбъектаМетаданныхКонфигурации(Metadata[ВидОбъекта][ObjectName], ВидОбъекта, AllRefsType);	
EndFunction

Function ОписаниеОбъектаМетаданныхКонфигурации(ОбъектМетаданных, ВидОбъекта, AllRefsType, ВключатьОписаниеРеквизитов = True) Export
	ОписаниеЭлемента = New Structure;
	ОписаниеЭлемента.Insert("ВидОбъекта", ВидОбъекта);
	ОписаниеЭлемента.Insert("Name", ОбъектМетаданных.Name);
	ОписаниеЭлемента.Insert("Synonym", ОбъектМетаданных.Synonym);
	ОписаниеЭлемента.Insert("Comment", ОбъектМетаданных.Comment);
	
	Extension = ОбъектМетаданных.ConfigurationExtension();
	If Extension <> Undefined Then
		ОписаниеЭлемента.Insert("Extension", Extension.Name);
	Else
		ОписаниеЭлемента.Insert("Extension", Undefined);
	EndIf;
	If Lower(ВидОбъекта) = "константа"
		Or Lower(ВидОбъекта) = "константы" Then
		ОписаниеЭлемента.Insert("Type", ОбъектМетаданных.Type);
	ElsIf Lower(ВидОбъекта) = "перечисление"
		Or Lower(ВидОбъекта) = "перечисления"Then
		EnumValues = New Structure;

		For Each ТекЗнч In ОбъектМетаданных.EnumValues Do
			EnumValues.Insert(ТекЗнч.Name, ТекЗнч.Synonym);
		EndDo;

		ОписаниеЭлемента.Insert("EnumValues", EnumValues);
	EndIf;

	If Not ВключатьОписаниеРеквизитов Then
		Return ОписаниеЭлемента;
	EndIf;
	
	КоллекцииРеквизитов = New Structure("Attributes, StandardAttributes, Dimensions, Resources, AddressingAttributes, AccountingFlags");
	КоллекцииТЧ = New Structure("TabularSections, StandardTabularSections");
	FillPropertyValues(КоллекцииРеквизитов, ОбъектМетаданных);
	FillPropertyValues(КоллекцииТЧ, ОбъектМетаданных);

	For Each КлючЗначение In КоллекцииРеквизитов Do
		If КлючЗначение.Value = Undefined Then
			Continue;
		EndIf;

		ОписаниеКоллекцииРеквизитов= New Structure;

		For Each ТекРеквизит In КлючЗначение.Value Do
			ОписаниеКоллекцииРеквизитов.Insert(ТекРеквизит.Name, ОписаниеРеквизитаОбъектаМетаданных(ТекРеквизит,
				AllRefsType));
		EndDo;

		ОписаниеЭлемента.Insert(КлючЗначение.Key, ОписаниеКоллекцииРеквизитов);
	EndDo;

	For Each КлючЗначение In КоллекцииТЧ Do
		If КлючЗначение.Value = Undefined Then
			Continue;
		EndIf;

		ОписаниеКоллекцииТЧ = New Structure;

		For Each ТЧ In КлючЗначение.Value Do
			ОписаниеТЧ = New Structure;
			ОписаниеТЧ.Insert("Name", ТЧ.Name);
			ОписаниеТЧ.Insert("Synonym", ТЧ.Synonym);
			ОписаниеТЧ.Insert("Comment", ТЧ.Comment);

			КоллекцииРеквизитовТЧ = New Structure("Attributes, StandardAttributes");
			FillPropertyValues(КоллекцииРеквизитовТЧ, ТЧ);
			For Each ТекКоллекцияРеквизитовТЧ In КоллекцииРеквизитовТЧ Do
				If ТекКоллекцияРеквизитовТЧ.Value = Undefined Then
					Continue;
				EndIf;

				ОписаниеКоллекцииРеквизитовТЧ = New Structure;

				For Each ТекРеквизит In ТекКоллекцияРеквизитовТЧ.Value Do
					ОписаниеКоллекцииРеквизитовТЧ.Insert(ТекРеквизит.Name, ОписаниеРеквизитаОбъектаМетаданных(
						ТекРеквизит, AllRefsType));
				EndDo;

				ОписаниеТЧ.Insert(ТекКоллекцияРеквизитовТЧ.Key, ОписаниеКоллекцииРеквизитовТЧ);
			EndDo;
			ОписаниеКоллекцииТЧ.Insert(ТЧ.Name, ОписаниеТЧ);
		EndDo;

		ОписаниеЭлемента.Insert(КлючЗначение.Key, ОписаниеКоллекцииТЧ);
	EndDo;


	If ОбъектМетаданныхИмеетПредопределенные(ВидОбъекта) Then

		Predefined = ОбъектМетаданных.GetPredefinedNames();

		ОписаниеПредопределенных = New Structure;
		For Each Name In Predefined Do
			ОписаниеПредопределенных.Insert(Name, "");
		EndDo;

		ОписаниеЭлемента.Insert("Predefined", ОписаниеПредопределенных);
	EndIf;
	
	Return ОписаниеЭлемента;
EndFunction

Function ОписаниеКоллекцииМетаданныхКонфигурации(Коллекция, ВидОбъекта, СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов) 
	ОписаниеКоллекции = New Structure();

	For Each ОбъектМетаданных In Коллекция Do
		ОписаниеЭлемента = ОписаниеОбъектаМетаданныхКонфигурации(ОбъектМетаданных, ВидОбъекта, AllRefsType, ВключатьОписаниеРеквизитов);
			
		ОписаниеКоллекции.Insert(ОбъектМетаданных.Name, ОписаниеЭлемента);
		
		If UT_Common.IsRefTypeObject(ОбъектМетаданных) Then
			СоответствиеТипов.Insert(Type(ВидОбъекта+"Reference."+ОписаниеЭлемента.Name), ОписаниеЭлемента);
		EndIf;
		
	EndDo;
	
	Return ОписаниеКоллекции;
EndFunction

Function ОписаниеОбщихМодулейКонфигурации() Export
	ОписаниеКоллекции = New Structure();

	For Each ОбъектМетаданных In Metadata.CommonModules Do
			
		ОписаниеКоллекции.Insert(ОбъектМетаданных.Name, New Structure);
		
	EndDo;
	
	Return ОписаниеКоллекции;
EndFunction

Function ОписнаиеМетаданныйДляИнициализацииРедактораMonaco() Export
	СоответствиеТипов = New Map;
	AllRefsType = UT_Common.AllRefsTypeDescription();

	ОписаниеМетаданных = New Structure;
	ОписаниеМетаданных.Insert("CommonModules", ОписаниеОбщихМодулейКонфигурации());
//	ОписаниеМетаданных.Вставить("Роли", ОписаниеКоллекцииМетаданныхКонфигурации(Метаданные.Роли, "Роль", СоответствиеТипов, ТипВсеСсылки));
//	ОписаниеМетаданных.Вставить("ОбщиеФормы", ОписаниеКоллекцииМетаданныхКонфигурации(Метаданные.ОбщиеФормы, "ОбщаяФорма", СоответствиеТипов, ТипВсеСсылки));

	Return ОписаниеМетаданных;	
EndFunction

Function ОписаниеМетаданныхКонфигурации(ВключатьОписаниеРеквизитов = True) Export
	AllRefsType = UT_Common.AllRefsTypeDescription();
	
	ОписаниеМетаданных = New Structure;
	
	СоответствиеТипов = New Map;
	
	ОписаниеМетаданных.Insert("Name", Metadata.Name);
	ОписаниеМетаданных.Insert("Version", Metadata.Version);
	ОписаниеМетаданных.Insert("AllRefsType", AllRefsType);
	
	ОписаниеМетаданных.Insert("Catalogs", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.Catalogs, "Catalog", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("Documents", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.Documents, "Document", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("InformationRegisters", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.InformationRegisters, "InformationRegister", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("AccumulationRegisters", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.AccumulationRegisters, "AccumulationRegister", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("AccountingRegisters", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.AccountingRegisters, "AccountingRegister", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("CalculationRegisters", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.CalculationRegisters, "CalculationRegister", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("DataProcessors", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.DataProcessors, "Processing", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("Reports", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.Reports, "Report", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("Enums", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.Enums, "Enum", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("CommonModules", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.CommonModules, "CommonModule", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("ChartsOfAccounts", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.ChartsOfAccounts, "ChartOfAccounts", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("BusinessProcesses", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.BusinessProcesses, "BusinessProcess", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("Tasks", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.Tasks, "Task", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("ChartsOfAccounts", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.ChartsOfAccounts, "ChartOfAccounts", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("ExchangePlans", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.ExchangePlans, "ExchangePlan", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("ChartsOfCharacteristicTypes", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.ChartsOfCharacteristicTypes, "ChartOfCharacteristicTypes", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("ChartsOfCalculationTypes", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.ChartsOfCalculationTypes, "ChartOfCalculationTypes", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("Constants", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.Constants, "Constant", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	ОписаниеМетаданных.Insert("SessionParameters", ОписаниеКоллекцииМетаданныхКонфигурации(Metadata.SessionParameters, "ПараметрСеанса", СоответствиеТипов, AllRefsType, ВключатьОписаниеРеквизитов));
	
	ОписаниеМетаданных.Insert("СоответствиеСсылочныхТипов", СоответствиеТипов);
	
	Return ОписаниеМетаданных;
EndFunction

Function АдресОписанияМетаданныхКонфигурации() Export
	ОПисание = ОписаниеМетаданныхКонфигурации();
	
	Return PutToTempStorage(ОПисание, New UUID);
EndFunction

Function СписокМетаданныхПоВиду(ВидМетаданных) Export
	КоллекцияМетаданных = Metadata[ВидМетаданных];
	
	МассивИмен = New Array;
	For Each ОбъектМетаданных In КоллекцияМетаданных Do
		МассивИмен.Add(ОбъектМетаданных.Name);
	EndDo;
	
	Return МассивИмен;
EndFunction

Procedure ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(СоответствиеТипов, Коллекция, ВидОбъекта)
	For Each ОбъектМетаданных In Коллекция Do
		ОписаниеЭлемента = New Structure;
		ОписаниеЭлемента.Insert("Name", ОбъектМетаданных.Name);
		ОписаниеЭлемента.Insert("ВидОбъекта", ВидОбъекта);
			
		СоответствиеТипов.Insert(Type(ВидОбъекта+"Reference."+ОбъектМетаданных.Name), ОписаниеЭлемента);
	EndDo;
	
EndProcedure

Function СоответствиеСсылочныхТипов() Export
	Map = New Map;
	ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(Map, Metadata.Catalogs, "Catalog");
	ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(Map, Metadata.Documents, "Document");
	ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(Map, Metadata.Enums, "Enum");
	ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(Map, Metadata.ChartsOfAccounts, "ChartOfAccounts");
	ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(Map, Metadata.BusinessProcesses, "BusinessProcess");
	ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(Map, Metadata.Tasks, "Task");
	ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(Map, Metadata.ChartsOfAccounts, "ChartOfAccounts");
	ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(Map, Metadata.ExchangePlans, "ExchangePlan");
	ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(Map, Metadata.ChartsOfCharacteristicTypes, "ChartOfCharacteristicTypes");
	ДобавитьКоллекциюМетаданныхВСоответствиеСсылочныхТипов(Map, Metadata.ChartsOfCalculationTypes, "ChartOfCalculationTypes");

	Return Map;
EndFunction

#EndRegion


#EndRegion

#Region Internal

Function ТекущиеПараметрыРедактораMonaco() Export
	ПараметрыИзХранилища =  UT_Common.CommonSettingsStorageLoad(
		UT_CommonClientServer.SettingsDataKeyInSettingsStorage(), "ПараметрыРедактораMonaco",
		UT_CodeEditorClientServer.ПараметрыРедактораMonacoПоУмолчанию());

	ПараметрыПоУмолчанию = UT_CodeEditorClientServer.ПараметрыРедактораMonacoПоУмолчанию();
	FillPropertyValues(ПараметрыПоУмолчанию, ПараметрыИзХранилища);

	Return ПараметрыПоУмолчанию;
EndFunction

Function ДоступныеИсточникиИсходногоКода() Export
	Array = New ValueList();
	
	Array.Add("ОсновнаяКонфигурация", "Main конфигурация");
	
	МассивРасширений = ConfigurationExtensions.Get();
	For Each ТекРасширение In МассивРасширений Do
		Array.Add(ТекРасширение.Name, ТекРасширение.Synonym);
	EndDo;
	
	Return Array;
EndFunction

#EndRegion

#Region Internal

#EndRegion