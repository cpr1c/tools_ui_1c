&AtClient
Procedure GetSelection(Command)
	Close(GetResult());
EndProcedure

&AtServer
Function GetResult()
	StructureResult = New Structure;
	StructureResult.Insert("QueryText", QueryText);
	StructureResult.Insert("ArbitraryQueryText", ArbitraryQueryText);
	StructureResult.Insert("SearchString", SearchString);
	StructureResult.Insert("Settings", DataSelection.GetSettings());
	StructureResult.Insert("SearchMode", SearchMode);
	StructureResult.Insert("QueryParameters", QueryParameters);

	Return StructureResult;
EndFunction

&AtServer
Procedure FillSettings()

	CompositionScheme = GetCompositionScheme();
	AddressScheme = PutToTempStorage(CompositionScheme, UUID);
	SourceSettings = New DataCompositionAvailableSettingsSource(AddressScheme);

	DataSelection.Initialize(SourceSettings);

EndProcedure

&AtServer
Function GetCompositionScheme()
	CompositionScheme = New DataCompositionSchema;

	Src = CompositionScheme.DataSources.Add();
	Src.Name = "Источник1";
	Src.ConnectionString = "";
	Src.DataSourceType = "local";

	DataSet = CompositionScheme.DataSets.Add(Type("DataCompositionSchemaDataSetQuery"));
	DataSet.Query = QueryText;
	DataSet.Name = "Query";
	DataSet.DataSource = "Источник1";

	For Each Item In ViewList Do
		Field = DataSet.Fields.Find(Item.Presentation);
		If Field = Undefined Then
			Field = DataSet.Fields.Add(Type("DataCompositionSchemaDataSetField"));
		EndIf;
		Field.Field = Item.Presentation;
		Field.DataPath = Item.Presentation;
		Field.Title = Item.Value;

	EndDo;

	Return CompositionScheme;
EndFunction

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	QueryText = Parameters.QueryText;
	ArbitraryQueryText = Parameters.ArbitraryQueryText;
	SearchString = Parameters.SearchString;

	Items.SearchMode.ChoiceList.Add(0, Nstr("ru = 'Фильтр по реквизитам';en = 'Filter by attributes'"));
	Items.SearchMode.ChoiceList.Add(1, Nstr("ru = 'Произвольный запрос';en = 'Arbitrary query'"));

	SearchMode = Parameters.SearchMode;
	QueryParameters.Load(Parameters.QueryParameters.Unload());

	ViewList.Clear();
	For Each Item In Parameters.ViewList Do
		ViewList.Add(Item.Value, Item.Presentation);
	EndDo;
	
	//Title = Title + " [" + Parameters.ОбъектПоиска.Presentation + "]";
	FillSettings();

	Settings = Parameters.Settings;
	If Settings <> Undefined Then
		DataSelection.LoadSettings(Settings);
	EndIf;

	SetVisibilityAccessibility();
EndProcedure

&AtClient
Procedure QueryWizard(Command)
	#If Not MobileClient Then
	QueryWizard = New QueryWizard;

	If Not IsBlankString(QueryText) Then
		QueryWizard.Text = QueryText;
	EndIf;

	QueryWizard.Show(New NotifyDescription("QueryWizardEnd", ThisObject));
	#EndIf	
EndProcedure

&AtClient
Procedure QueryWizardEnd(Text, AdditionalParameters) Export
	If Text = Undefined Then
		Return;
	EndIf;

	QueryText = Text;
EndProcedure

&AtClient
Procedure UpdateParameters(Command)
	Result = FillQueryParameters();
	If Result <> True Then
		ShowMessageBox( , Result, 60, Nstr("ru = 'Ошибка!';en = 'Error!'"));
	EndIf;
EndProcedure

&AtServer
Function FillQueryParameters()
	If IsBlankString(QueryText) Then
		Return Nstr("ru = 'Отсутствует текст запроса.';en = 'Missing query text.'");
	EndIf;

	Query = New Query(ArbitraryQueryText);
	Try
		ParametersInQuery = Query.FindParameters();
	Except
		Return ErrorDescription();
	EndTry;

	For Each QueryParameter In ParametersInQuery Do
		ParameterName =  QueryParameter.Name;
		RowParameters = QueryParameters.FindRows(New Structure("ParameterName", ParameterName));
		If RowParameters.Count() = 0 Then
			RowParameters = QueryParameters.Add();
			RowParameters.ParameterName = ParameterName;
		Else
			RowParameters = RowParameters[0];
		EndIf;

		RowParameters.ParameterValue = QueryParameter.ValueType.AdjustValue(
			RowParameters.ParameterValue);
	EndDo;

	Return True;
EndFunction

&AtClient
Procedure QueryParametersParameterValueClear(Item, StandardProcessing)
	Item.ChooseType = True;
EndProcedure

&AtClient
Procedure SearchModeOnChange(Item)
	SetVisibilityAccessibility();
EndProcedure

&AtServer
Procedure SetVisibilityAccessibility()
	If SearchMode = 1 Then
		Items.GroupPages.CurrentPage = Items.CustomQuery;
	Else
		Items.GroupPages.CurrentPage = Items.SelectionByValuesAttributes;
	EndIf;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
#If ThickClientManagedApplication Then
	Items.ContextMenuQueryText.Enabled = True;
#EndIf
EndProcedure