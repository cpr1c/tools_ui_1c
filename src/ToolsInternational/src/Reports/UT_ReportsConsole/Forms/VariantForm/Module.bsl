&AtClient
Procedure ПоляГруппировкиНедоступны()

	Items.СтраницыПолейГруппировки.CurrentPage = Items.НедоступныеНастройкиПолейГруппировки;

EndProcedure

&AtClient
Procedure ВыбранныеПоляДоступны(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemSelection(ЭлементСтруктуры) Then

		ЛокальныеВыбранныеПоля = True;
		Items.СтраницыПолейВыбора.CurrentPage = Items.НастройкиВыбранныхПолей;

	Else

		ЛокальныеВыбранныеПоля = False;
		Items.СтраницыПолейВыбора.CurrentPage = Items.ОтключенныеНастройкиВыбранныхПолей;

	EndIf;

	Items.ЛокальныеВыбранныеПоля.ReadOnly = False;

EndProcedure

&AtClient
Procedure ВыбранныеПоляНедоступны()

	ЛокальныеВыбранныеПоля = False;
	Items.ЛокальныеВыбранныеПоля.ReadOnly = True;
	Items.СтраницыПолейВыбора.CurrentPage = Items.НедоступныеНастройкиВыбранныхПолей;

EndProcedure

&AtClient
Procedure ОтборДоступен(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemFilter(ЭлементСтруктуры) Then

		ЛокальныйОтбор = True;
		Items.СтраницыОтбора.CurrentPage = Items.НастройкиОтбора;

	Else

		ЛокальныйОтбор = False;
		Items.СтраницыОтбора.CurrentPage = Items.ОтключенныеНастройкиОтбора;

	EndIf;

	Items.ЛокальныйОтбор.ReadOnly = False;

EndProcedure

&AtClient
Procedure ОтборНедоступен()

	ЛокальныйОтбор = False;
	Items.ЛокальныйОтбор.ReadOnly = True;
	Items.СтраницыОтбора.CurrentPage = Items.НедоступныеНастройкиОтбора;

EndProcedure

&AtClient
Procedure ПорядокДоступен(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemOrder(ЭлементСтруктуры) Then

		ЛокальныйПорядок = True;
		Items.СтраницыПорядка.CurrentPage = Items.НастройкиПорядка;

	Else

		ЛокальныйПорядок = False;
		Items.СтраницыПорядка.CurrentPage = Items.ОтключенныеНастройкиПорядка;

	EndIf;

	Items.ЛокальныйПорядок.ReadOnly = False;

EndProcedure

&AtClient
Procedure ПорядокНедоступен()

	ЛокальныйПорядок = False;
	Items.ЛокальныйПорядок.ReadOnly = True;
	Items.СтраницыПорядка.CurrentPage = Items.НедоступныеНастройкиПорядка;

EndProcedure

&AtClient
Procedure УсловноеОформлениеДоступно(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemConditionalAppearance(ЭлементСтруктуры) Then

		ЛокальноеУсловноеОформление = True;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.НастройкиУсловногоОформления;

	Else

		ЛокальноеУсловноеОформление = False;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.ОтключенныеНастройкиУсловногоОформления;

	EndIf;

	Items.ЛокальноеУсловноеОформление.ReadOnly = False;

EndProcedure

&AtClient
Procedure УсловноеОформлениеНедоступно()

	ЛокальноеУсловноеОформление = False;
	Items.ЛокальноеУсловноеОформление.ReadOnly = True;
	Items.СтраницыУсловногоОформления.CurrentPage = Items.НедоступныеНастройкиУсловногоОформления;

EndProcedure

&AtClient
Procedure ПараметрыВыводаДоступны(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemOutputParameters(ЭлементСтруктуры) Then

		ЛокальныеПараметрыВывода = True;
		Items.СтраницыПараметровВывода.CurrentPage = Items.НастройкиПараметровВывода;

	Else

		ЛокальныеПараметрыВывода = False;
		Items.СтраницыПараметровВывода.CurrentPage = Items.ОтключенныеНастройкиПараметровВывода;

	EndIf;

	Items.ЛокальныеПараметрыВывода.ReadOnly = False;

EndProcedure

&AtClient
Procedure ПараметрыВыводаНедоступны()

	ЛокальныеПараметрыВывода = False;
	Items.ЛокальныеПараметрыВывода.ReadOnly = True;
	Items.СтраницыПараметровВывода.CurrentPage = Items.НедоступныеНастройкиПараметровВывода;

EndProcedure

&AtClient
Procedure СтруктураПриАктивизацииПоля(Item)

	Var ВыбраннаяСтраница;

	If Items.Structure.CurrentItem.Name = "СтруктураНаличиеВыбора" Then

		ВыбраннаяСтраница = Items.СтраницаПолейВыбора;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеОтбора" Then

		ВыбраннаяСтраница = Items.СтраницаОтбора;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеПорядка" Then

		ВыбраннаяСтраница = Items.СтраницаПорядка;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеУсловногоОформления" Then

		ВыбраннаяСтраница = Items.СтраницаУсловногоОформления;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеПараметровВывода" Then

		ВыбраннаяСтраница = Items.СтраницаПараметровВывода;

	EndIf;

	If ВыбраннаяСтраница <> Undefined Then

		Items.СтраницыНастроек.CurrentPage = ВыбраннаяСтраница;

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

		ЛокальныеВыбранныеПоля = True;
		Items.ЛокальныеВыбранныеПоля.ReadOnly = True;
		Items.СтраницыПолейВыбора.CurrentPage = Items.НастройкиВыбранныхПолей;

		ЛокальныйОтбор = True;
		Items.ЛокальныйОтбор.ReadOnly = True;
		Items.СтраницыОтбора.CurrentPage = Items.НастройкиОтбора;

		ЛокальныйПорядок = True;
		Items.ЛокальныйПорядок.ReadOnly = True;
		Items.СтраницыПорядка.CurrentPage = Items.НастройкиПорядка;

		ЛокальноеУсловноеОформление = True;
		Items.ЛокальноеУсловноеОформление.ReadOnly = True;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.НастройкиУсловногоОформления;

		ЛокальныеПараметрыВывода = True;
		Items.ЛокальныеПараметрыВывода.ReadOnly = True;
		Items.СтраницыПараметровВывода.CurrentPage = Items.НастройкиПараметровВывода;

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

	If ЛокальныеВыбранныеПоля Then

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

	If ЛокальныйОтбор Then

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

	If ЛокальныйПорядок Then

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

	If ЛокальноеУсловноеОформление Then

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

	If ЛокальныеПараметрыВывода Then

		Items.СтраницыПараметровВывода.CurrentPage = Items.НастройкиПараметровВывода;

	Else

		Items.СтраницыПараметровВывода.CurrentPage = Items.ОтключенныеНастройкиПараметровВывода;

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