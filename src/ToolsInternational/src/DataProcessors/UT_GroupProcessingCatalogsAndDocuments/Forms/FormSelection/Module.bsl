&AtClient
Procedure ПолучитьОтбор(Command)
	Close(ПолучитьРезультат());
EndProcedure

&AtServer
Function ПолучитьРезультат()
	СтруктураРезультата = New Structure;
	СтруктураРезультата.Insert("QueryText", QueryText);
	СтруктураРезультата.Insert("ТекстПроизвольногоЗапроса", ТекстПроизвольногоЗапроса);
	СтруктураРезультата.Insert("SearchString", SearchString);
	СтруктураРезультата.Insert("Settings", ОтборДанных.GetSettings());
	СтруктураРезультата.Insert("SearchMode", РежимПоиска);
	СтруктураРезультата.Insert("QueryOptions", QueryOptions);

	Return СтруктураРезультата;
EndFunction

&AtServer
Procedure FillSettings()

	СхемаКомпоновки = ПолучитьСхемуКомпоновки();
	АдресСхемы = PutToTempStorage(СхемаКомпоновки, UUID);
	ИсточникНастроек = New DataCompositionAvailableSettingsSource(АдресСхемы);

	ОтборДанных.Initialize(ИсточникНастроек);

EndProcedure

&AtServer
Function ПолучитьСхемуКомпоновки()
	СхемаКомпоновки = New DataCompositionSchema;

	Src = СхемаКомпоновки.DataSources.Add();
	Src.Name = "Источник1";
	Src.ConnectionString="";
	Src.DataSourceType = "local";

	НаборДанных = СхемаКомпоновки.DataSets.Add(Type("DataCompositionSchemaDataSetQuery"));
	НаборДанных.Query = QueryText;
	НаборДанных.Name = "Query";
	НаборДанных.DataSource = "Источник1";

	For Each Item In СписокПредставлений Do
		Field=НаборДанных.Fields.Find(Item.Presentation);
		If Field = Undefined Then
			Field=НаборДанных.Fields.Add(Type("DataCompositionSchemaDataSetField"));
		EndIf;
		Field.Field=Item.Presentation;
		Field.DataPath=Item.Presentation;
		Field.Title=Item.Value;

	EndDo;

	Return СхемаКомпоновки;
EndFunction

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	QueryText = Parameters.QueryText;
	ТекстПроизвольногоЗапроса = Parameters.ТекстПроизвольногоЗапроса;
	SearchString = Parameters.SearchString;

	Items.SearchMode.ChoiceList.Add(0, "Filter по реквизитам");
	Items.SearchMode.ChoiceList.Add(1, "Произвольный запрос");

	РежимПоиска = Parameters.SearchMode;
	QueryOptions.Load(Parameters.QueryOptions.Unload());

	СписокПредставлений.Clear();
	For Each Item In Parameters.СписокПредставлений Do
		СписокПредставлений.Add(Item.Value, Item.Presentation);
	EndDo;
	
	//Title = Title + " [" + Parameters.ОбъектПоиска.Presentation + "]";
	FillSettings();

	Settings = Parameters.Settings;
	If Settings <> Undefined Then
		ОтборДанных.LoadSettings(Settings);
	EndIf;

	УстановитьВидимостьДоступность();
EndProcedure

&AtClient
Procedure QueryWizard(Command)
	#If Not MobileClient Then
	QueryWizard = New QueryWizard;

	If Not IsBlankString(QueryText) Then
		QueryWizard.Text = QueryText;
	EndIf;

	QueryWizard.Show(New NotifyDescription("КонструкторЗапросаЗавершение", ThisObject));
	#EndIf	
EndProcedure

&AtClient
Procedure КонструкторЗапросаЗавершение(Text, AdditionalParameters) Export
	If Text = Undefined Then
		Return;
	EndIf;

	QueryText = Text;
EndProcedure

&AtClient
Procedure ОбновитьПараметры(Command)
	Result = ЗаполнитьПараметрыЗапроса();
	If Result <> True Then
		ShowMessageBox( , Result, 60, "Error!");
	EndIf;
EndProcedure

&AtServer
Function ЗаполнитьПараметрыЗапроса()
	If IsBlankString(QueryText) Then
		Return "Отсутствует текст запроса.";
	EndIf;

	Query = New Query(ТекстПроизвольногоЗапроса);
	Try
		ПараметрыВЗапросе = Query.FindParameters();
	Except
		Return ErrorDescription();
	EndTry;

	For Each ПараметрЗапроса In ПараметрыВЗапросе Do
		ИмяПараметра =  ПараметрЗапроса.Name;
		СтрокаПараметров = QueryOptions.FindRows(New Structure("ИмяПараметра", ИмяПараметра));
		If СтрокаПараметров.Count() = 0 Then
			СтрокаПараметров = QueryOptions.Add();
			СтрокаПараметров.ИмяПараметра = ИмяПараметра;
		Else
			СтрокаПараметров = СтрокаПараметров[0];
		EndIf;

		СтрокаПараметров.ЗначениеПараметра = ПараметрЗапроса.ValueType.AdjustValue(
			СтрокаПараметров.ЗначениеПараметра);
	EndDo;

	Return True;
EndFunction

&AtClient
Procedure ПараметрыЗапросаЗначениеПараметраОчистка(Item, StandardProcessing)
	Item.ChooseType = True;
EndProcedure

&AtClient
Procedure РежимПоискаПриИзменении(Item)
	УстановитьВидимостьДоступность();
EndProcedure

&AtServer
Procedure УстановитьВидимостьДоступность()
	If РежимПоиска = 1 Then
		Items.ГруппаСтраницы.CurrentPage = Items.CustomQuery;
	Else
		Items.ГруппаСтраницы.CurrentPage = Items.ОтборПоЗначениямРеквизитов;
	EndIf;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
#If ТолстыйКлиентУправляемоеПриложение Then
	Items.КонтекстноеМенюТекстЗапросаКонструкторЗапроса.Enabled = True;
#EndIf
EndProcedure