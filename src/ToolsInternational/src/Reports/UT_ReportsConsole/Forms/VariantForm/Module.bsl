&AtClient
Procedure ПоляГруппировкиНедоступны()

	Items.СтраницыПолейГруппировки.CurrentPage = Items.НедоступныеНастройкиПолейГруппировки;

EndProcedure

&AtClient
Procedure ВыбранныеПоляДоступны(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemSelection(ЭлементСтруктуры) Then

		LocalSelectedFields = True;
		Items.СтраницыПолейВыбора.CurrentPage = Items.НастройкиВыбранныхПолей;

	Else

		LocalSelectedFields = False;
		Items.СтраницыПолейВыбора.CurrentPage = Items.ОтключенныеНастройкиВыбранныхПолей;

	EndIf;

	Items.LocalSelectedFields.ReadOnly = False;

EndProcedure

&AtClient
Procedure ВыбранныеПоляНедоступны()

	LocalSelectedFields = False;
	Items.LocalSelectedFields.ReadOnly = True;
	Items.СтраницыПолейВыбора.CurrentPage = Items.НедоступныеНастройкиВыбранныхПолей;

EndProcedure

&AtClient
Procedure ОтборДоступен(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemFilter(ЭлементСтруктуры) Then

		LocalFilter = True;
		Items.СтраницыОтбора.CurrentPage = Items.НастройкиОтбора;

	Else

		LocalFilter = False;
		Items.СтраницыОтбора.CurrentPage = Items.ОтключенныеНастройкиОтбора;

	EndIf;

	Items.LocalFilter.ReadOnly = False;

EndProcedure

&AtClient
Procedure ОтборНедоступен()

	LocalFilter = False;
	Items.LocalFilter.ReadOnly = True;
	Items.СтраницыОтбора.CurrentPage = Items.НедоступныеНастройкиОтбора;

EndProcedure

&AtClient
Procedure ПорядокДоступен(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemOrder(ЭлементСтруктуры) Then

		LocalOrder = True;
		Items.СтраницыПорядка.CurrentPage = Items.НастройкиПорядка;

	Else

		LocalOrder = False;
		Items.СтраницыПорядка.CurrentPage = Items.ОтключенныеНастройкиПорядка;

	EndIf;

	Items.LocalOrder.ReadOnly = False;

EndProcedure

&AtClient
Procedure ПорядокНедоступен()

	LocalOrder = False;
	Items.LocalOrder.ReadOnly = True;
	Items.СтраницыПорядка.CurrentPage = Items.НедоступныеНастройкиПорядка;

EndProcedure

&AtClient
Procedure УсловноеОформлениеДоступно(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemConditionalAppearance(ЭлементСтруктуры) Then

		LocalConditionalAppearance = True;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.НастройкиУсловногоОформления;

	Else

		LocalConditionalAppearance = False;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.ОтключенныеНастройкиУсловногоОформления;

	EndIf;

	Items.LocalConditionalAppearance.ReadOnly = False;

EndProcedure

&AtClient
Procedure УсловноеОформлениеНедоступно()

	LocalConditionalAppearance = False;
	Items.LocalConditionalAppearance.ReadOnly = True;
	Items.СтраницыУсловногоОформления.CurrentPage = Items.НедоступныеНастройкиУсловногоОформления;

EndProcedure

&AtClient
Procedure ПараметрыВыводаДоступны(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemOutputParameters(ЭлементСтруктуры) Then

		LocalOutputParameters = True;
		Items.СтраницыПараметровВывода.CurrentPage = Items.OutputParametersSettings;

	Else

		LocalOutputParameters = False;
		Items.СтраницыПараметровВывода.CurrentPage = Items.DisabledOutputParametersSettings;

	EndIf;

	Items.LocalOutputParameters.ReadOnly = False;

EndProcedure

&AtClient
Procedure ПараметрыВыводаНедоступны()

	LocalOutputParameters = False;
	Items.LocalOutputParameters.ReadOnly = True;
	Items.СтраницыПараметровВывода.CurrentPage = Items.UnavailableOutputParametersSettings;

EndProcedure

&AtClient
Procedure СтруктураПриАктивизацииПоля(Item)

	Var ВыбраннаяСтраница;

	If Items.Structure.CurrentItem.Name = "СтруктураНаличиеВыбора" Then

		ВыбраннаяСтраница = Items.SelectionFieldsPage;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеОтбора" Then

		ВыбраннаяСтраница = Items.FilterPage;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеПорядка" Then

		ВыбраннаяСтраница = Items.OrderPage;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеУсловногоОформления" Then

		ВыбраннаяСтраница = Items.ConditionalAppearancePage;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеПараметровВывода" Then

		ВыбраннаяСтраница = Items.OutputParametersPage;

	EndIf;

	If ВыбраннаяСтраница <> Undefined Then

		Items.SettingsPages.CurrentPage = ВыбраннаяСтраница;

	EndIf;

EndProcedure

&AtClient
Procedure СтруктураПриАктивизацииСтроки(Item)

	ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
		Items.Structure.CurrentLine);
	ItemType = TypeOf(ЭлементСтруктуры);

	If ItemType = Undefined Or ItemType = Type("DataCompositionChartStructureItemCollection")
		Or ItemType = Type("DataCompositionTableStructureItemCollection") Then

		ПоляГруппировкиНедоступны();
		ВыбранныеПоляНедоступны();
		ОтборНедоступен();
		ПорядокНедоступен();
		УсловноеОформлениеНедоступно();
		ПараметрыВыводаНедоступны();

	ElsIf ItemType = Type("DataCompositionSettings") Or ItemType = Type(
		"DataCompositionNestedObjectSettings") Then

		ПоляГруппировкиНедоступны();

		LocalSelectedFields = True;
		Items.LocalSelectedFields.ReadOnly = True;
		Items.СтраницыПолейВыбора.CurrentPage = Items.НастройкиВыбранныхПолей;

		LocalFilter = True;
		Items.LocalFilter.ReadOnly = True;
		Items.СтраницыОтбора.CurrentPage = Items.НастройкиОтбора;

		LocalOrder = True;
		Items.LocalOrder.ReadOnly = True;
		Items.СтраницыПорядка.CurrentPage = Items.НастройкиПорядка;

		LocalConditionalAppearance = True;
		Items.LocalConditionalAppearance.ReadOnly = True;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.НастройкиУсловногоОформления;

		LocalOutputParameters = True;
		Items.LocalOutputParameters.ReadOnly = True;
		Items.СтраницыПараметровВывода.CurrentPage = Items.OutputParametersSettings;

	ElsIf ItemType = Type("DataCompositionGroup") Or ItemType = Type(
		"DataCompositionTableGroup") Or ItemType = Type("DataCompositionChartGroup") Then

		Items.СтраницыПолейГруппировки.CurrentPage = Items.НастройкиПолейГруппировки;

		ВыбранныеПоляДоступны(ЭлементСтруктуры);
		ОтборДоступен(ЭлементСтруктуры);
		ПорядокДоступен(ЭлементСтруктуры);
		УсловноеОформлениеДоступно(ЭлементСтруктуры);
		ПараметрыВыводаДоступны(ЭлементСтруктуры);

	ElsIf ItemType = Type("DataCompositionTable") Or ItemType = Type("DataCompositionChart") Then

		ПоляГруппировкиНедоступны();
		ВыбранныеПоляДоступны(ЭлементСтруктуры);
		ОтборНедоступен();
		ПорядокНедоступен();
		УсловноеОформлениеДоступно(ЭлементСтруктуры);
		ПараметрыВыводаДоступны(ЭлементСтруктуры);

	EndIf;

EndProcedure

&AtClient
Procedure ПерейтиКОтчету(Item)

	ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
		Items.Structure.CurrentLine);
	ItemSettings =  Report.SettingsComposer.Settings.ItemSettings(ЭлементСтруктуры);
	Items.Structure.CurrentLine = Report.SettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

&AtClient
Procedure ЛокальныеВыбранныеПоляПриИзменении(Item)

	If LocalSelectedFields Then

		Items.СтраницыПолейВыбора.CurrentPage = Items.НастройкиВыбранныхПолей;

	Else

		Items.СтраницыПолейВыбора.CurrentPage = Items.ОтключенныеНастройкиВыбранныхПолей;

		ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentLine);
		Report.SettingsComposer.Settings.ClearItemSelection(ЭлементСтруктуры);

	EndIf;

EndProcedure

&AtClient
Procedure ЛокальныйОтборПриИзменении(Item)

	If LocalFilter Then

		Items.СтраницыОтбора.CurrentPage = Items.НастройкиОтбора;

	Else

		Items.СтраницыОтбора.CurrentPage = Items.ОтключенныеНастройкиОтбора;

		ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentLine);
		Report.SettingsComposer.Settings.ClearItemFilter(ЭлементСтруктуры);

	EndIf;

EndProcedure

&AtClient
Procedure ЛокальныйПорядокПриИзменении(Item)

	If LocalOrder Then

		Items.СтраницыПорядка.CurrentPage = Items.НастройкиПорядка;

	Else

		Items.СтраницыПорядка.CurrentPage = Items.ОтключенныеНастройкиПорядка;

		ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentLine);
		Report.SettingsComposer.Settings.ClearItemOrder(ЭлементСтруктуры);

	EndIf;

EndProcedure

&AtClient
Procedure ЛокальноеУсловноеОформлениеПриИзменении(Item)

	If LocalConditionalAppearance Then

		Items.СтраницыУсловногоОформления.CurrentPage = Items.НастройкиУсловногоОформления;

	Else

		Items.СтраницыУсловногоОформления.CurrentPage = Items.ОтключенныеНастройкиУсловногоОформления;

		ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentLine);
		Report.SettingsComposer.Settings.ClearItemConditionalAppearance(ЭлементСтруктуры);

	EndIf;

EndProcedure

&AtClient
Procedure ЛокальныеПараметрыВыводаПриИзменении(Item)

	If LocalOutputParameters Then

		Items.СтраницыПараметровВывода.CurrentPage = Items.OutputParametersSettings;

	Else

		Items.СтраницыПараметровВывода.CurrentPage = Items.DisabledOutputParametersSettings;

		ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentLine);
		Report.SettingsComposer.Settings.ClearItemOutputParameters(ЭлементСтруктуры);
	EndIf;

EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	StandardProcessing = False;
	If Parameters.АдресСхемыИсполненногоОтчета <> "" Then
		Report.SettingsComposer.Initialize(
			New DataCompositionAvailableSettingsSource(Parameters.АдресСхемыИсполненногоОтчета));
		Report.SettingsComposer.LoadSettings(Parameters.Variant);
	EndIf;
EndProcedure