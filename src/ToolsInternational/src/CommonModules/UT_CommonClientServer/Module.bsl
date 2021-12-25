#Область DynamicList

////////////////////////////////////////////////////////////////////////////////
// Functions for works with dynamic list filters and parameters.
//

// Searches for the item and the group of the dynamic list filter by the passed field name or presentation.
//
// Parameters:
//  SearchArea - DataCompositionFilter, DataCompositionFilterItemCollection,DataCompositionFilterItemGroup - a container of items and filter groups. For 
//                  example, List.Filter or a group in a filer.
//  FieldName - String - a composition field name. Not applicable to groups.
//  Presentation - String - the composition field presentation.
//
// Returns:
//  Array - a collection of filters.
//
Function FindFilterItemsAndGroups(Val SearchArea,
									Val FieldName = Undefined,
									Val Presentation = Undefined) Export
	
	If ValueIsFilled(FieldName) Then
		SearchValue = New DataCompositionField(FieldName);
		SearchMethod = 1;
	Else
		SearchMethod = 2;
		SearchValue = Presentation;
	EndIf;
	
	ItemArray = New Array;

	НайтиРекурсивно(SearchArea.Items, ItemArray, SearchMethod, SearchValue);

	Return ItemArray;

EndFunction

// Adds filter groups to ItemCollection.
//
// Parameters:
//  ItemCollection - DataCompositionFilter, DataCompositionFilterItemCollection,
//                       DataCompositionFilterItemGroup - a container of items and filter groups. 
//                       For example, List.Filter or a group in a filer.
//  Presentation - String - the group presentation.
//  GroupType - DataCompositionFilterItemsGroupType - the group type.
//
// Returns:
//  DataCompositionFilterItemGroup - a filter group.
//
Function CreateFilterItemGroup(Val ItemCollection, Presentation, GroupType) Export
	
	If TypeOf(ItemCollection) = Type("DataCompositionFilterItemGroup") Then
		ItemCollection = ItemCollection.Items;
	EndIf;
	
	FilterItemsGroup = FindFilterItemByPresentation(ItemCollection, Presentation);
	If FilterItemsGroup = Undefined Then
		FilterItemsGroup = ItemCollection.Add(Type("DataCompositionFilterItemGroup"));
	Else
		FilterItemsGroup.Items.Clear();
	EndIf;
	
	FilterItemsGroup.Presentation    = Presentation;
	FilterItemsGroup.Application       = DataCompositionFilterApplicationType.Items;
	FilterItemsGroup.ViewMode = DataCompositionSettingsItemViewMode.Inaccessible;
	FilterItemsGroup.GroupType        = GroupType;
	FilterItemsGroup.Use    = True;
	
	Return FilterItemsGroup;
	
EndFunction

// Adds a composition item into a composition item container.
//
// Parameters:
//  AreaToAddTo - DataCompositionFilterItemCollection - a container with items and filter groups. 
//                                                                 For example, List.Filter or a group in a filter.
//  FieldName - String - a data composition field name. Required.
//  RightValue - Arbitrary - the value to compare to.
//  ComparisonType            - DataCompositionComparisonType - a comparison type.
//  Presentation           - String - presentation of the data composition item.
//  Usage - Boolean - the flag that indicates whether the item is used.
//  DisplayMode - DataCompositionSettingItemDisplayMode - the item display mode.
//  UserSettingID - String - see DataCompositionFilter.UserSettingID in Syntax Assistant. 
//                                                    
// Returns:
//  DataCompositionFilterItem - a composition item.
//
Function AddCompositionItem(AreaToAddTo,
									Val FieldName,
									Val ComparisonType,
									Val RightValue = Undefined,
									Val Presentation  = Undefined,
									Val Usage  = Undefined,
									val DisplayMode = Undefined,
									val UserSettingID = Undefined) Export
	
	Item = AreaToAddTo.Items.Add(Type("DataCompositionFilterItem"));
	Item.LeftValue = New DataCompositionField(FieldName);
	Item.ComparisonType = ComparisonType;
	
	If DisplayMode = Undefined Then
		Item.ViewMode = DataCompositionSettingsItemViewMode.Inaccessible;
	Else
		Item.ViewMode = DisplayMode;
	EndIf;
	
	If RightValue <> Undefined Then
		Item.RightValue = RightValue;
	EndIf;
	
	If Presentation <> Undefined Then
		Item.Presentation = Presentation;
	EndIf;
	
	If Usage <> Undefined Then
		Item.Use = Usage;
	EndIf;
	
	// Important: The ID must be set up in the final stage of the item customization or it will be 
	// copied to the user settings in a half-filled condition.
	// 
	If UserSettingID <> Undefined Then
		Item.UserSettingID = UserSettingID;
	ElsIf Item.ViewMode <> DataCompositionSettingsItemViewMode.Inaccessible Then
		Item.UserSettingID = FieldName;
	EndIf;
	
	Return Item;
	
EndFunction

// Changes the filter item with the specified field name or presentation.
//
// Parameters:
//  SearchArea - DataCompositionFilterItemCollection - a container with items and filter groups, for 
//                                                             example, List.Filter or a group in the filter.
//  FieldName - String - a data composition field name. Required.
//  Presentation           - String - presentation of the data composition item.
//  RightValue - Arbitrary - the value to compare to.
//  ComparisonType            - DataCompositionComparisonType - a comparison type.
//  Usage - Boolean - the flag that indicates whether the item is used.
//  DisplayMode - DataCompositionSettingItemDisplayMode - the item display mode.
//  UserSettingID - String - see DataCompositionFilter.UserSettingID in Syntax Assistant. 
//                                                    
//
// Returns:
//  Number - the changed item count.
//
Function ChangeFilterItems(SearchArea,
								Val FieldName = Undefined,
								Val Presentation = Undefined,
								Val RightValue = Undefined,
								Val ComparisonType = Undefined,
								Val Usage = Undefined,
								Val DisplayMode = Undefined,
								Val UserSettingID = Undefined) Export
	
	If ValueIsFilled(FieldName) Then
		SearchValue = New DataCompositionField(FieldName);
		SearchMethod = 1;
	Else
		SearchMethod = 2;
		SearchValue = Presentation;
	EndIf;
	
	ItemArray = New Array;
	
	FindRecursively(SearchArea.Items, ItemArray, SearchMethod, SearchValue);
	
	For Each Item In ItemArray Do
		If FieldName <> Undefined Then
			Item.LeftValue = New DataCompositionField(FieldName);
		EndIf;
		If Presentation <> Undefined Then
			Item.Presentation = Presentation;
		EndIf;
		If Usage <> Undefined Then
			Item.Use = Usage;
		EndIf;
		If ComparisonType <> Undefined Then
			Item.ComparisonType = ComparisonType;
		EndIf;
		If RightValue <> Undefined Then
			Item.RightValue = RightValue;
		EndIf;
		If DisplayMode <> Undefined Then
			Item.ViewMode = DisplayMode;
		EndIf;
		If UserSettingID <> Undefined Then
			Item.UserSettingID = UserSettingID;
		EndIf;
	EndDo;
	
	Return ItemArray.Count();
	
EndFunction

// Delete filter items that contain the given field name or presentation.
//
// Parameters:
//  AreaToDelete - DataCompositionFilterItemCollection - a container of items or filter groups. For 
//                                                               example, List.Filter or a group in the filter.
//  FieldName - String - the composition field name. Not applicable to groups.
//  Presentation   - String - the composition field presentation.
//
Procedure DeleteFilterItems(Val AreaToDelete, Val FieldName = Undefined, Val Presentation = Undefined) Export
	
	If ValueIsFilled(FieldName) Then
		SearchValue = New DataCompositionField(FieldName);
		SearchMethod = 1;
	Else
		SearchMethod = 2;
		SearchValue = Presentation;
	EndIf;
	
	ItemArray = New Array;
	
	FindRecursively(AreaToDelete.Items, ItemArray, SearchMethod, SearchValue);
	
	For Each Item In ItemArray Do
		If Item.Parent = Undefined Then
			AreaToDelete.Items.Delete(Item);
		Else
			Item.Parent.Items.Delete(Item);
		EndIf;
	EndDo;
	
EndProcedure

// Adds or replaces the existing filter item.
//
// Parameters:
//  WhereToAdd - DataCompositionFilterItemCollection - a container with items and filter groups, for 
//                                     example, List.Filter or a group in the filter.
//  FieldName - String - a data composition field name. Required.
//  RightValue - Arbitrary - the value to compare to.
//  ComparisonType            - DataCompositionComparisonType - a comparison type.
//  Presentation           - String - presentation of the data composition item.
//  Usage - Boolean - the flag that indicates whether the item is used.
//  DisplayMode - DataCompositionSettingItemDisplayMode - the item display mode.
//  UserSettingID - String - see DataCompositionFilter.UserSettingID in Syntax Assistant. 
//                                                    
//
Procedure SetFilterItem(WhereToAdd,
								Val FieldName,
								Val RightValue = Undefined,
								Val ComparisonType = Undefined,
								Val Presentation = Undefined,
								Val Usage = Undefined,
								Val DisplayMode = Undefined,
								Val UserSettingID = Undefined) Export
	
	ModifiedCount = ChangeFilterItems(WhereToAdd, FieldName, Presentation,
							RightValue, ComparisonType, Usage, DisplayMode, UserSettingID);
	
	If ModifiedCount = 0 Then
		If ComparisonType = Undefined Then
			If TypeOf(RightValue) = Type("Array")
				Or TypeOf(RightValue) = Type("FixedArray")
				Or TypeOf(RightValue) = Type("ValueList") Then
				ComparisonType = DataCompositionComparisonType.InList;
			Else
				ComparisonType = DataCompositionComparisonType.Equal;
			EndIf;
		EndIf;
		If DisplayMode = Undefined Then
			DisplayMode = DataCompositionSettingsItemViewMode.Inaccessible;
		EndIf;
		AddCompositionItem(WhereToAdd, FieldName, ComparisonType,
								RightValue, Presentation, Usage, DisplayMode, UserSettingID);
	EndIf;
	
EndProcedure

// Adds or replaces a filter item of a dynamic list.
//
// Parameters:
//   DynamicList - DynamicList - the list to be filtered.
//   FieldName            - String - the field the filter to apply to.
//   RightValue     - Arbitrary - the filter value.
//       Optional. The default value is Undefined.
//       Warning! If Undefined is passed, the value will not be changed.
//   ComparisonType  - DataCompositionComparisonType - a filter condition.
//   Presentation - String - presentation of the data composition item.
//       Optional. The default value is Undefined.
//       If another value is specified, only the presentation flag is shown, not the value.
//       To show the value, pass an empty string.
//   Usage - Boolean - the flag that indicates whether to apply the filter.
//       Optional. The default value is Undefined.
//   DisplayMode - DataCompositionSettingItemDisplayMode - the filter display mode.
//                                                                          
//       * DataCompositionSettingItemDisplayMode.QuickAccess - in the Quick Settings bar on top of the list.
//       * DataCompositionSettingItemDisplayMode.Normal - in the list settings (submenu More).
//       * DataCompositionSettingItemDisplayMode.Inaccessible - privent users from changing the filter.
//   UserSettingID - String - the filter UUID.
//       Used to link user settings.
//
Procedure SetDynamicListFilterItem(DynamicList, FieldName,
	RightValue = Undefined,
	ComparisonType = Undefined,
	Presentation = Undefined,
	Usage = Undefined,
	DisplayMode = Undefined,
	UserSettingID = Undefined) Export
	
	If DisplayMode = Undefined Then
		DisplayMode = DataCompositionSettingsItemViewMode.Inaccessible;
	EndIf;
	
	If DisplayMode = DataCompositionSettingsItemViewMode.Inaccessible Then
		DynamicListFilter = DynamicList.SettingsComposer.FixedSettings.Filter;
	Else
		DynamicListFilter = DynamicList.SettingsComposer.Settings.Filter;
	EndIf;
	
	SetFilterItem(
		DynamicListFilter,
		FieldName,
		RightValue,
		ComparisonType,
		Presentation,
		Usage,
		DisplayMode,
		UserSettingID);
	
EndProcedure

// Delete a filter group item of a dynamic list.
//
// Parameters:
//  DynamicList - DynamicList - the form attribute whose filter is to be modified.
//  FieldName - String - the composition field name. Not applicable to groups.
//  Presentation   - String - the composition field presentation.
//
Procedure DeleteDynamicListFilterGroupItems(DynamicList, FieldName = Undefined, Presentation = Undefined) Export
	
	DeleteFilterItems(
		DynamicList.SettingsComposer.FixedSettings.Filter,
		FieldName,
		Presentation);
	
	DeleteFilterItems(
		DynamicList.SettingsComposer.Settings.Filter,
		FieldName,
		Presentation);
	
EndProcedure

// Sets or modifies the ParameterName parameter of the List dynamic list.
//
// Parameters:
//  List          - DynamicList - the form attribute whose parameter is to be modified.
//  ParameterName    - String             - name of the dynamic list parameter.
//  Value        - Arbitrary        - new value of the parameter.
//  Usage   - Boolean             - flag indicating whether the parameter is used.
//
Procedure SetDynamicListParameter(List, ParameterName, Value, Usage = True) Export
	
	DataCompositionParameterValue = List.Parameters.FindParameterValue(New DataCompositionParameter(ParameterName));
	If DataCompositionParameterValue <> Undefined Then
		If Usage AND DataCompositionParameterValue.Value <> Value Then
			DataCompositionParameterValue.Value = Value;
		EndIf;
		If DataCompositionParameterValue.Use <> Usage Then
			DataCompositionParameterValue.Use = Usage;
		EndIf;
	EndIf;
	
EndProcedure

Function SetDCSParemetrValue(КомпоновщикНастроек, ИмяПараметра, ЗначениеПараметра,
	ИспользоватьНеЗаполненный = Истина) Export

	ПараметрУстановлен = Ложь;

	ПараметрКомпоновкиДанных = Новый ПараметрКомпоновкиДанных(ИмяПараметра);
	ЗначениеПараметраКомпоновкиДанных = КомпоновщикНастроек.Настройки.ПараметрыДанных.НайтиЗначениеПараметра(
		ПараметрКомпоновкиДанных);
	Если ЗначениеПараметраКомпоновкиДанных <> Неопределено Тогда

		ЗначениеПараметраКомпоновкиДанных.Значение = ЗначениеПараметра;
		ЗначениеПараметраКомпоновкиДанных.Использование = ?(ИспользоватьНеЗаполненный, Истина, ValueIsFilled(
			ЗначениеПараметраКомпоновкиДанных.Значение));

		ПараметрУстановлен = Истина;

	КонецЕсли;

	Return ПараметрУстановлен;

EndFunction

Процедура НайтиРекурсивно(КоллекцияЭлементов, МассивЭлементов, СпособПоиска, ЗначениеПоиска)

	Для Каждого ЭлементОтбора Из КоллекцияЭлементов Цикл

		Если ТипЗнч(ЭлементОтбора) = Тип("ЭлементОтбораКомпоновкиДанных") Тогда

			Если СпособПоиска = 1 Тогда
				Если ЭлементОтбора.ЛевоеЗначение = ЗначениеПоиска Тогда
					МассивЭлементов.Добавить(ЭлементОтбора);
				КонецЕсли;
			ИначеЕсли СпособПоиска = 2 Тогда
				Если ЭлементОтбора.Представление = ЗначениеПоиска Тогда
					МассивЭлементов.Добавить(ЭлементОтбора);
				КонецЕсли;
			КонецЕсли;
		Иначе

			НайтиРекурсивно(ЭлементОтбора.Элементы, МассивЭлементов, СпособПоиска, ЗначениеПоиска);

			Если СпособПоиска = 2 И ЭлементОтбора.Представление = ЗначениеПоиска Тогда
				МассивЭлементов.Добавить(ЭлементОтбора);
			КонецЕсли;

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

// Выполняет поиск элемента отбора в коллекции по заданному представлению.
//
// Параметры:
//  КоллекцияЭлементов - КоллекцияЭлементовОтбораКомпоновкиДанных - контейнер с элементами и группами отбора,
//                                                                  например, Список.Отбор.Элементы или группа в отборе.
//  Представление - Строка - представление группы.
// 
// Возвращаемое значение:
//  ЭлементОтбораКомпоновкиДанных - элемент отбора.
//
Function НайтиЭлементОтбораПоПредставлению(КоллекцияЭлементов, Представление) Export

	ВозвращаемоеЗначение = Неопределено;

	Для Каждого ЭлементОтбора Из КоллекцияЭлементов Цикл
		Если ЭлементОтбора.Представление = Представление Тогда
			ВозвращаемоеЗначение = ЭлементОтбора;
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Return ВозвращаемоеЗначение
EndFunction

Процедура СкопироватьЭлементы(ПриемникЗначения, ИсточникЗначения, ОчищатьПриемник = Истина) Export

	Если ТипЗнч(ИсточникЗначения) = Тип("УсловноеОформлениеКомпоновкиДанных") Или ТипЗнч(ИсточникЗначения) = Тип(
		"ВариантыПользовательскогоПоляВыборКомпоновкиДанных") Или ТипЗнч(ИсточникЗначения) = Тип(
		"ОформляемыеПоляКомпоновкиДанных") Или ТипЗнч(ИсточникЗначения) = Тип(
		"ЗначенияПараметровДанныхКомпоновкиДанных") Тогда
		СоздаватьПоТипу = Ложь;
	Иначе
		СоздаватьПоТипу = Истина;
	КонецЕсли;
	ПриемникЭлементов = ПриемникЗначения.Элементы;
	ИсточникЭлементов = ИсточникЗначения.Элементы;
	Если ОчищатьПриемник Тогда
		ПриемникЭлементов.Очистить();
	КонецЕсли;

	Для Каждого ЭлементИсточник Из ИсточникЭлементов Цикл

		Если ТипЗнч(ЭлементИсточник) = Тип("ЭлементПорядкаКомпоновкиДанных") Тогда
			// Элементы порядка добавляем в начало
			Индекс = ИсточникЭлементов.Индекс(ЭлементИсточник);
			ЭлементПриемник = ПриемникЭлементов.Вставить(Индекс, ТипЗнч(ЭлементИсточник));
		Иначе
			Если СоздаватьПоТипу Тогда
				ЭлементПриемник = ПриемникЭлементов.Добавить(ТипЗнч(ЭлементИсточник));
			Иначе
				ЭлементПриемник = ПриемникЭлементов.Добавить();
			КонецЕсли;
		КонецЕсли;

		ЗаполнитьЗначенияСвойств(ЭлементПриемник, ЭлементИсточник);
		// В некоторых коллекциях необходимо заполнить другие коллекции
		Если ТипЗнч(ИсточникЭлементов) = Тип("КоллекцияЭлементовУсловногоОформленияКомпоновкиДанных") Тогда
			СкопироватьЭлементы(ЭлементПриемник.Поля, ЭлементИсточник.Поля);
			СкопироватьЭлементы(ЭлементПриемник.Отбор, ЭлементИсточник.Отбор);
			ЗаполнитьЭлементы(ЭлементПриемник.Оформление, ЭлементИсточник.Оформление);
		ИначеЕсли ТипЗнч(ИсточникЭлементов) = Тип("КоллекцияВариантовПользовательскогоПоляВыборКомпоновкиДанных") Тогда
			СкопироватьЭлементы(ЭлементПриемник.Отбор, ЭлементИсточник.Отбор);
		КонецЕсли;
		
		// В некоторых элементах коллекции необходимо заполнить другие коллекции
		Если ТипЗнч(ЭлементИсточник) = Тип("ГруппаЭлементовОтбораКомпоновкиДанных") Тогда
			СкопироватьЭлементы(ЭлементПриемник, ЭлементИсточник);
		ИначеЕсли ТипЗнч(ЭлементИсточник) = Тип("ГруппаВыбранныхПолейКомпоновкиДанных") Тогда
			СкопироватьЭлементы(ЭлементПриемник, ЭлементИсточник);
		ИначеЕсли ТипЗнч(ЭлементИсточник) = Тип("ПользовательскоеПолеВыборКомпоновкиДанных") Тогда
			СкопироватьЭлементы(ЭлементПриемник.Варианты, ЭлементИсточник.Варианты);
		ИначеЕсли ТипЗнч(ЭлементИсточник) = Тип("ПользовательскоеПолеВыражениеКомпоновкиДанных") Тогда
			ЭлементПриемник.УстановитьВыражениеДетальныхЗаписей (ЭлементИсточник.ПолучитьВыражениеДетальныхЗаписей());
			ЭлементПриемник.УстановитьВыражениеИтоговыхЗаписей(ЭлементИсточник.ПолучитьВыражениеИтоговыхЗаписей());
			ЭлементПриемник.УстановитьПредставлениеВыраженияДетальныхЗаписей(
				ЭлементИсточник.ПолучитьПредставлениеВыраженияДетальныхЗаписей ());
			ЭлементПриемник.УстановитьПредставлениеВыраженияИтоговыхЗаписей(
				ЭлементИсточник.ПолучитьПредставлениеВыраженияИтоговыхЗаписей ());
		КонецЕсли;

	КонецЦикла;

КонецПроцедуры
Процедура ЗаполнитьЭлементы(ПриемникЗначения, ИсточникЗначения, ПервыйУровень = Неопределено) Export

	Если ТипЗнч(ПриемникЗначения) = Тип("КоллекцияЗначенийПараметровКомпоновкиДанных") Тогда
		КоллекцияЗначений = ИсточникЗначения;
	Иначе
		КоллекцияЗначений = ИсточникЗначения.Элементы;
	КонецЕсли;

	Для Каждого ЭлементИсточник Из КоллекцияЗначений Цикл
		Если ПервыйУровень = Неопределено Тогда
			ЭлементПриемник = ПриемникЗначения.НайтиЗначениеПараметра(ЭлементИсточник.Параметр);
		Иначе
			ЭлементПриемник = ПервыйУровень.НайтиЗначениеПараметра(ЭлементИсточник.Параметр);
		КонецЕсли;
		Если ЭлементПриемник = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ЗаполнитьЗначенияСвойств(ЭлементПриемник, ЭлементИсточник);
		Если ТипЗнч(ЭлементИсточник) = Тип("ЗначениеПараметраКомпоновкиДанных") Тогда
			Если ЭлементИсточник.ЗначенияВложенныхПараметров.Количество() <> 0 Тогда
				ЗаполнитьЭлементы(ЭлементПриемник.ЗначенияВложенныхПараметров,
					ЭлементИсточник.ЗначенияВложенныхПараметров, ПриемникЗначения);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры


// Копирует настройки компоновки данных
//
// Параметры:
//	НастройкиПриемник	- НастройкиКомпоновкиДанных, НастройкиВложенногоОбъектаКомпоновкиДанных
//		ГруппировкаКомпоновкиДанных, ГруппировкаТаблицыКомпоновкиДанных, ГруппировкаДиаграммыКомпоновкиДанных,
//		ТаблицаКомпоновкиДанных, ДиаграммаКомпоновкиДанных - коллекция настроек КД, куда копируются настройки
//	НастройкиИсточник	- НастройкиКомпоновкиДанных, НастройкиВложенногоОбъектаКомпоновкиДанных
//		ГруппировкаКомпоновкиДанных, ГруппировкаТаблицыКомпоновкиДанных, ГруппировкаДиаграммыКомпоновкиДанных,
//		ТаблицаКомпоновкиДанных, ДиаграммаКомпоновкиДанных - коллекция настроек КД, откуда копируются настройки.
//
Процедура СкопироватьНастройкиКомпоновкиДанных(НастройкиПриемник, НастройкиИсточник) Export
	
	Если НастройкиИсточник = Неопределено Тогда
		Return;
	КонецЕсли;
	
	Если ТипЗнч(НастройкиПриемник) = Тип("НастройкиКомпоновкиДанных") Тогда
		Для каждого Параметр Из НастройкиИсточник.ПараметрыДанных.Элементы Цикл
			ЗначениеПараметра = НастройкиПриемник.ПараметрыДанных.НайтиЗначениеПараметра(Параметр.Параметр);
			Если ЗначениеПараметра <> Неопределено Тогда
				ЗаполнитьЗначенияСвойств(ЗначениеПараметра, Параметр);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Если ТипЗнч(НастройкиИсточник) = Тип("НастройкиВложенногоОбъектаКомпоновкиДанных") Тогда
		ЗаполнитьЗначенияСвойств(НастройкиПриемник, НастройкиИсточник);
		СкопироватьНастройкиКомпоновкиДанных(НастройкиПриемник.Настройки, НастройкиИсточник.Настройки);
		Return;
	КонецЕсли;
	
	// Копирование настроек
	Если ТипЗнч(НастройкиИсточник) = Тип("НастройкиКомпоновкиДанных") Тогда
		
		СкопироватьЭлементы(НастройкиПриемник.ПараметрыДанных,		НастройкиИсточник.ПараметрыДанных);
		СкопироватьЭлементы(НастройкиПриемник.ПользовательскиеПоля,	НастройкиИсточник.ПользовательскиеПоля);
		СкопироватьЭлементы(НастройкиПриемник.Отбор,				НастройкиИсточник.Отбор);
		СкопироватьЭлементы(НастройкиПриемник.Порядок,				НастройкиИсточник.Порядок);
		
	КонецЕсли;
	
	Если ТипЗнч(НастройкиИсточник) = Тип("ГруппировкаКомпоновкиДанных")
	 ИЛИ ТипЗнч(НастройкиИсточник) = Тип("ГруппировкаТаблицыКомпоновкиДанных")
	 ИЛИ ТипЗнч(НастройкиИсточник) = Тип("ГруппировкаДиаграммыКомпоновкиДанных") Тогда
		
		СкопироватьЭлементы(НастройкиПриемник.ПоляГруппировки,	НастройкиИсточник.ПоляГруппировки);
		СкопироватьЭлементы(НастройкиПриемник.Отбор,			НастройкиИсточник.Отбор);
		СкопироватьЭлементы(НастройкиПриемник.Порядок,			НастройкиИсточник.Порядок);
		ЗаполнитьЗначенияСвойств(НастройкиПриемник,				НастройкиИсточник);
		
	КонецЕсли;
	
	СкопироватьЭлементы(НастройкиПриемник.Выбор,				НастройкиИсточник.Выбор);
	СкопироватьЭлементы(НастройкиПриемник.УсловноеОформление,	НастройкиИсточник.УсловноеОформление);
	ЗаполнитьЭлементы(НастройкиПриемник.ПараметрыВывода,		НастройкиИсточник.ПараметрыВывода);
	
	// Копирование структуры
	Если ТипЗнч(НастройкиИсточник) = Тип("НастройкиКомпоновкиДанных")
	 ИЛИ ТипЗнч(НастройкиИсточник) = Тип("ГруппировкаКомпоновкиДанных") Тогда
		
		Для каждого ЭлементСтруктурыИсточник Из НастройкиИсточник.Structure Цикл
			ЭлементСтруктурыПриемник = НастройкиПриемник.Structure.Добавить(ТипЗнч(ЭлементСтруктурыИсточник));
			СкопироватьНастройкиКомпоновкиДанных(ЭлементСтруктурыПриемник, ЭлементСтруктурыИсточник);
		КонецЦикла;
		
	КонецЕсли;
	
	Если ТипЗнч(НастройкиИсточник) = Тип("ГруппировкаТаблицыКомпоновкиДанных")
	 ИЛИ ТипЗнч(НастройкиИсточник) = Тип("ГруппировкаДиаграммыКомпоновкиДанных") Тогда
		
		Для каждого ЭлементСтруктурыИсточник Из НастройкиИсточник.Structure Цикл
			ЭлементСтруктурыПриемник = НастройкиПриемник.Structure.Добавить();
			СкопироватьНастройкиКомпоновкиДанных(ЭлементСтруктурыПриемник, ЭлементСтруктурыИсточник);
		КонецЦикла;
		
	КонецЕсли;
	
	Если ТипЗнч(НастройкиИсточник) = Тип("ТаблицаКомпоновкиДанных") Тогда
		
		Для каждого ЭлементСтруктурыИсточник Из НастройкиИсточник.Строки Цикл
			ЭлементСтруктурыПриемник = НастройкиПриемник.Строки.Добавить();
			СкопироватьНастройкиКомпоновкиДанных(ЭлементСтруктурыПриемник, ЭлементСтруктурыИсточник);
		КонецЦикла;
		
		Для каждого ЭлементСтруктурыИсточник Из НастройкиИсточник.Колонки Цикл
			ЭлементСтруктурыПриемник = НастройкиПриемник.Колонки.Добавить();
			СкопироватьНастройкиКомпоновкиДанных(ЭлементСтруктурыПриемник, ЭлементСтруктурыИсточник);
		КонецЦикла;
		
	КонецЕсли;
	
	Если ТипЗнч(НастройкиИсточник) = Тип("ДиаграммаКомпоновкиДанных") Тогда
		
		Для каждого ЭлементСтруктурыИсточник Из НастройкиИсточник.Серии Цикл
			ЭлементСтруктурыПриемник = НастройкиПриемник.Серии.Добавить();
			СкопироватьНастройкиКомпоновкиДанных(ЭлементСтруктурыПриемник, ЭлементСтруктурыИсточник);
		КонецЦикла;
		
		Для каждого ЭлементСтруктурыИсточник Из НастройкиИсточник.Точки Цикл
			ЭлементСтруктурыПриемник = НастройкиПриемник.Точки.Добавить();
			СкопироватьНастройкиКомпоновкиДанных(ЭлементСтруктурыПриемник, ЭлементСтруктурыИсточник);
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры



#КонецОбласти

#Область Отладка

Function СериализоватьЗапросДляОтладки(ОбъектОтладки)
	StructureОбъекта = Новый Structure;

	StructureОбъекта.Вставить("Текст", ОбъектОтладки.Текст);

	StructureОбъекта.Вставить("Параметры", CopyRecursively(ОбъектОтладки.Параметры));

	Если ОбъектОтладки.МенеджерВременныхТаблиц <> Неопределено Тогда
		StructureВременныхТаблиц = UT_CommonServerCall.StructureВременныхТаблицМенеджераВременныхТаблиц(
			ОбъектОтладки.МенеджерВременныхТаблиц);
		StructureОбъекта.Вставить("ВременныеТаблицы", StructureВременныхТаблиц);
	КонецЕсли;

	Return StructureОбъекта;
EndFunction

Function СериализоватьСКДДляОтладки(СКД, НастройкиСКД, ВнешниеНаборыДанных)
	Return UT_CommonServerCall.СериализоватьОбъектСКДДляОтладки(СКД, НастройкиСКД, ВнешниеНаборыДанных);
EndFunction

Function СериализоватьОбъектБДДляОтладки(ОбъектОтладки)
	StructureОбъекта = Новый Structure;
	StructureОбъекта.Вставить("Объект", ОбъектОтладки);

	Return StructureОбъекта;
EndFunction

Function СериализоватьHTTPЗапросДляОтладки(ЗапросHTTP, СоединениеHTTP)
	StructureОбъекта = Новый Structure;
	StructureОбъекта.Вставить("АдресСервера", СоединениеHTTP.Сервер);
	StructureОбъекта.Вставить("Порт", СоединениеHTTP.Порт);
	StructureОбъекта.Вставить("ИспользоватьHTPPS", СоединениеHTTP.ЗащищенноеСоединение <> Неопределено);
	Если СоединениеHTTP.ЗащищенноеСоединение = Неопределено Тогда
		StructureОбъекта.Вставить("Протокол", "http");
	Иначе
		StructureОбъекта.Вставить("Протокол", "https");
	КонецЕсли;

	StructureОбъекта.Вставить("ПроксиСервер", СоединениеHTTP.Прокси.Сервер(StructureОбъекта.Протокол));
	StructureОбъекта.Вставить("ПроксиПорт", СоединениеHTTP.Прокси.Порт(StructureОбъекта.Протокол));
	StructureОбъекта.Вставить("ПроксиПользователь", СоединениеHTTP.Прокси.Пользователь(StructureОбъекта.Протокол));
	StructureОбъекта.Вставить("ПроксиПароль", СоединениеHTTP.Прокси.Пароль(StructureОбъекта.Протокол));
	StructureОбъекта.Вставить("ИспользоватьАутентификациюОС", СоединениеHTTP.Прокси.ИспользоватьАутентификациюОС(
		StructureОбъекта.Протокол));

	StructureОбъекта.Вставить("Запрос", ЗапросHTTP.АдресРесурса);
	StructureОбъекта.Вставить("ТелоЗапроса", ЗапросHTTP.ПолучитьТелоКакСтроку());
	StructureОбъекта.Вставить("Заголовки", UT_CommonClientServer.ПолучитьСтрокуЗаголовковHTTP(
		ЗапросHTTP.Заголовки));

	ДвоичныеДанныеТела = ЗапросHTTP.ПолучитьТелоКакДвоичныеДанные();
	StructureОбъекта.Вставить("ДвоичныеДанныеТела", ДвоичныеДанныеТела);
	StructureОбъекта.Вставить("ДвоичныеДанныеТелаСтрокой", Строка(ДвоичныеДанныеТела));

	StructureОбъекта.Вставить("ИмяФайлаЗапроса", ЗапросHTTP.ПолучитьИмяФайлаТела());

	Return StructureОбъекта;

EndFunction

Function СериализоватьОбъектДляОтладкиВСтруктуру(ОбъектОтладки, НастройкиСКДИлиСоединениеHTTP, ВнешниеНаборыДанных)
	ТипВсеСсылки = UT_CommonCached.AllRefsTypeDescription();

	StructureОбъекта = Новый Structure;
	Если ТипВсеСсылки.СодержитТип(ТипЗнч(ОбъектОтладки)) Тогда
		StructureОбъекта = СериализоватьОбъектБДДляОтладки(ОбъектОтладки);
	ИначеЕсли ТипЗнч(ОбъектОтладки) = Тип("HTTPЗапрос") Тогда
		StructureОбъекта = СериализоватьHTTPЗапросДляОтладки(ОбъектОтладки, НастройкиСКДИлиСоединениеHTTP);
	ИначеЕсли ТипЗнч(ОбъектОтладки) = Тип("Запрос") Тогда
		StructureОбъекта = СериализоватьЗапросДляОтладки(ОбъектОтладки);
	ИначеЕсли ТипЗнч(ОбъектОтладки) = Тип("СхемаКомпоновкиДанных") Тогда
		StructureОбъекта = СериализоватьСКДДляОтладки(ОбъектОтладки, НастройкиСКДИлиСоединениеHTTP, ВнешниеНаборыДанных);
	КонецЕсли;

	Return StructureОбъекта;
EndFunction

Function ОтладитьОбъект(ОбъектДляОтладки, НастройкиСКДИлиСоединениеHTTP = Неопределено, ВнешниеНаборыДанных=Неопределено) Export
	ОткрыватьСразуКонсоль = Ложь;

#Если ТолстыйКлиентОбычноеПриложение Или ТолстыйКлиентУправляемоеПриложение Тогда
	ОткрыватьСразуКонсоль = Истина;
#КонецЕсли

	ТипВсеСсылки = UT_CommonCached.AllRefsTypeDescription();
	СериализованныйОбъект = СериализоватьОбъектДляОтладкиВСтруктуру(ОбъектДляОтладки, НастройкиСКДИлиСоединениеHTTP, ВнешниеНаборыДанных);
	Если ТипВсеСсылки.СодержитТип(ТипЗнч(ОбъектДляОтладки)) Тогда
		ТипОбъектаОтладки = "ОбъектБазыДанных";
	ИначеЕсли ТипЗнч(ОбъектДляОтладки) = Тип("HTTPЗапрос") Тогда
		ТипОбъектаОтладки = "HTTPЗапрос";
	ИначеЕсли ТипЗнч(ОбъектДляОтладки) = Тип("Запрос") Тогда
		ТипОбъектаОтладки = "ЗАПРОС";
	ИначеЕсли ТипЗнч(ОбъектДляОтладки) = Тип("СхемаКомпоновкиДанных") Тогда
		ТипОбъектаОтладки = "СхемаКомпоновкиДанных";
	КонецЕсли;

	Если ОткрыватьСразуКонсоль Тогда
		ДанныеДляОтладки = ПоместитьВоВременноеХранилище(СериализованныйОбъект);
#Если Клиент Тогда

		UT_CommonClient.ОткрытьКонсольОтладки(ТипОбъектаОтладки, ДанныеДляОтладки);

#КонецЕсли
		Return Неопределено;
	Иначе
		Return UT_CommonServerCall.ЗаписатьДанныеДляОтладкиВСправочник(ТипОбъектаОтладки,
			СериализованныйОбъект);
	КонецЕсли;
EndFunction

Function КлючДанныхОбъектаДанныхОтладкиВХранилищеНастроек() Export
	Return "УИ_УниверсальныеИнструменты_ДанныеДляОтладки";
EndFunction

Function КлючОбъектаВХранилищеНастроек() Export
	Return "УИ_УниверсальныеИнструменты";
EndFunction

#КонецОбласти

#Область HTTPЗапросы

Function ЗаголовкиHTTPЗапросаИзСтроки(СтрокаЗаголовков) Export
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст(СтрокаЗаголовков);

	Заголовки = Новый Соответствие;

	Для НомерСтроки = 1 По ТекстовыйДокумент.КоличествоСтрок() Цикл
		ЗаголовокСтр = ТекстовыйДокумент.ПолучитьСтроку(НомерСтроки);

		Если Не ValueIsFilled(ЗаголовокСтр) Тогда
			Продолжить;
		КонецЕсли;

		МассивЗаголовка = StrSplit(ЗаголовокСтр, ":");
		Если МассивЗаголовка.Количество() <> 2 Тогда
			Продолжить;
		КонецЕсли;

		Заголовки.Вставить(МассивЗаголовка[0], МассивЗаголовка[1]);

	КонецЦикла;

	Return Заголовки;
EndFunction

Function ПолучитьСтрокуЗаголовковHTTP(Заголовки) Export
	СтрокаЗаголовков = "";

	Для Каждого КлючЗначение Из Заголовки Цикл
		СтрокаЗаголовков = СтрокаЗаголовков + ?(ValueIsFilled(СтрокаЗаголовков), Символы.ПС, "") + КлючЗначение.Ключ
			+ ":" + КлючЗначение.Значение;
	КонецЦикла;

	Return СтрокаЗаголовков;
EndFunction

#КонецОбласти

#Область JSON

Function мПрочитатьJSON(Значение, ПрочитатьВСоответствие = Ложь) Export
#Если ВебКлиент Тогда
	Return UT_CommonServerCall.мПрочитатьJSON(Значение);
#Иначе
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Значение);

		ДанныеДокументаJSON =ПрочитатьJSON(ЧтениеJSON,ПрочитатьВСоответствие);
		ЧтениеJSON.Закрыть();

		Return ДанныеДокументаJSON;
#КонецЕсли
EndFunction // ПрочитатьJSON()

Function мЗаписатьJSON(StructureДанных) Export
#Если ВебКлиент Тогда
	Return UT_CommonServerCall.мЗаписатьJSON(StructureДанных);
#Иначе

		ЗаписьJSON = Новый ЗаписьJSON;
		ЗаписьJSON.УстановитьСтроку();
		ЗаписатьJSON(ЗаписьJSON, StructureДанных);
		СериализованнаяСтрока = ЗаписьJSON.Закрыть();
		Return СериализованнаяСтрока;
#КонецЕсли

EndFunction // ЗаписатьJSON(
#КонецОбласти

#Область ПараметрыЗаписи

Function StructureПараметровЗаписиПоУмолчанию() Export
	ПараметрыЗаписи=Новый Structure;
	ПараметрыЗаписи.Вставить("БезАвторегистрацииИзменений", Ложь);
	ПараметрыЗаписи.Вставить("ЗаписьВРежимеЗагрузки", Ложь);
	ПараметрыЗаписи.Вставить("ПривелигированныйРежим", Ложь);
	ПараметрыЗаписи.Вставить("ИспользоватьДопСвойства", Ложь);
	ПараметрыЗаписи.Вставить("ДополнительныеСвойства", Новый Structure);
	ПараметрыЗаписи.Вставить("ИспользоватьПроцедуруПередЗаписью", Ложь);
	ПараметрыЗаписи.Вставить("ПроцедураПередЗаписью", "");

	Return ПараметрыЗаписи;
EndFunction

Function ПараметрыЗаписиДляВыводаНаФормуИнструмента() Export
	Массив=Новый Массив;
	Массив.Добавить("ЗаписьВРежимеЗагрузки");
	Массив.Добавить("ПривелигированныйРежим");
	Массив.Добавить("БезАвторегистрацииИзменений");

	Return Массив;
EndFunction

Function ПараметрыЗаписиФормы(Форма, ПрефиксРеквизитаФормы = "ПараметрЗаписи_") Export
	ПараметрыЗаписи=StructureПараметровЗаписиПоУмолчанию();

	Для Каждого КлючЗначение Из ПараметрыЗаписи Цикл
		Если ТипЗнч(КлючЗначение.Значение) = Тип("Structure") Тогда
			Для Каждого Стр Из Форма[ПрефиксРеквизитаФормы + КлючЗначение.Ключ] Цикл
				ПараметрыЗаписи[КлючЗначение.Ключ].Вставить(Стр.Ключ, Стр.Значение);
			КонецЦикла;
		Иначе
			ПараметрыЗаписи[КлючЗначение.Ключ]=Форма[ПрефиксРеквизитаФормы + КлючЗначение.Ключ];
		КонецЕсли;
	КонецЦикла;
//	ЗаполнитьЗначенияСвойств(ПараметрыЗаписи, Форма);

	Return ПараметрыЗаписи;
EndFunction

Процедура УстановитьПараметрыЗаписиНаФорму(Форма, ПараметрыЗаписи, ПрефиксРеквизитаФормы = "ПараметрЗаписи_") Export
	Для Каждого КлючЗначение Из ПараметрыЗаписи Цикл
		Если ТипЗнч(КлючЗначение.Значение) = Тип("Structure") Тогда
			Для Каждого КЗ Из КлючЗначение.Значение Цикл
				НС=Форма[ПрефиксРеквизитаФормы + КлючЗначение.Ключ].Добавить();
				НС.Ключ=КЗ.Ключ;
				НС.Значение=КЗ.Значение;
			КонецЦикла;
		Иначе
			Форма[ПрефиксРеквизитаФормы + КлючЗначение.Ключ]=КлючЗначение.Значение;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

////////////////////////////////////////////////////////////////////////
// English Code Area 

// Create copy of value type of Structure, Recursively, according of types of properties. 
// If  structure properties contains values of object types  (catalogref, DocumentRef,etc),
//  their contents are not copied, but references to the source object are returned..
//
// Parameters:
//  SourceStructure - Structure - copied Structure.
// 
// Return value:
//  Structure - copy of the original structure.
//
Function CopyStructure(SourceStructure) Export

	ResultStructure = New Structure;

	For Each  KeyAndValue Из SourceStructure Do
		ResultStructure.Insert(KeyAndValue.Key, CopyRecursively(KeyAndValue.Vakue));
	EndDo;

	Return ResultStructure;

EndFunction

// Supplement structure values from secound srtucture.
//
// Parameters:
//   Receiver - Structure - Collection,to which new values will be added..
//   Source - Structure - Collection, which be used for reading Key and Value for fili
//   Replace - Boolean, Undefined - what action choose when parts of Source and Receiver are equal
//   							True  - replace values of receiver (the fastest method)
//   							False - NOT replace value of receiver (skip)
//   							Undefined - (default setting) - raise exception 
//   
Procedure SupplementStructure(Receiver, Source, Replace = Undefined) Export

	For each  Element in Source do
		if Replace <> True and Receiver.Property(Element.Key) then
			if Replace = False then
				Continue;
			else
				Raise StrTemplate(Nstr("ru = 'Пересечение ключей источника и приемника: ""%1"".'; en='Intersection of source and receiver keys: ""%1"".'"),
					Element.Key);
			Endif;
		EndIf;
		Receiver.Insert(Element.Key, Element.Value);
	EndDo;

EndProcedure

// Create full copy of structure, map, array, list or value table, Recursively, 
//  taking into account the types of child elements. Object types values (CatalogObject,DocumentObject, etc) not copied and returns links to the source object.
//
// Parameters:
//  Source - Structure, Map, Array, ValueList, ValueTable - object that you want  to copy.
//
// Return value:
//  Structure, Map, Array, ValueList, ValueTable- copy of the object passed as a parameter to the Source..
//
Function CopyRecursively(Source) Export

	Var Receiver;
	SourceType = TypeOf(Source);

#Если Server Or ThickClientOrdinaryApplication Or ExternalConnection Then
	If SourceType = Type("ValueTable") Then
		Return Source.Copy();
	EndIf;
#EndIf
	If SourceType = Type("Structure") Then
		Receiver = CopyStructure(Source);
	Elsif SourceType = Type("Map") Then
		Receiver = CopyMap(Source);
	Elsif SourceType = Type("Array") Тогда
		Receiver = CopyArray(Source);
	Elsif SourceType = Type("ValueList") Then
		Receiver = CopyValueList(Source);
	Else
		Receiver = Source;
	EndIf;

	Return Receiver;

EndFunction

// Creates a copy of value type of  Map, recursively, based on the types of values.
// If elements of Map contains object  types values (CatalogObject,DocumentObject, etc).
//  their contents are not copied, and returns a reference to the original object.
//
// Parameters:
//  SourceMap - Map - map, that need to be copied.
// 
// Return value:
//  Map - copy of Source Map.
//
Function CopyMap(SourceMap) Export

	ResultMap = New Map;

	For Each KeyAndValue in SourceMap Do
		ResultMap.Insert(KeyAndValue.Key, CopyRecursively(KeyAndValue.Value));
	EndDo;

	Return ResultMap;

EndFunction

// Creates a copy of value type of  Array, recursively, based on the types of values.
// If elements of Array contains object  types values (CatalogObject,DocumentObject, etc).
//  their contents are not copied, and returns a reference to the original object.
//  
// Parameters:
//  SourceArray - Array - array, that need to be copied.
// 
// Return value:
//  Array - copy of source array.
//
Function CopyArray(SourceArray) Export

	ResultArray = New Array;

	For Each  Item In SourceArray Do
		ResultArray.Add(CopyRecursively(Item));
	EndDo;

	Return ResultArray;

EndFunction

// Creates a copy of value type of  ValueList, recursively, based on the types of values.
// If elements of ValueList contains object  types values (CatalogObject,DocumentObject, etc).
//  their contents are not copied, and returns a reference to the original object.
//
// Parameters:
//  SourceValueList - ValueList - ValueList that need to be copied.
// 
// Return value:
//  ValueList - copy of source ValueList.
//
Function CopyValueList(SourceValueList) Export

	ValueListResult = New ValueList;

	For each  ListItem In SourceValueList Do
		ValueListResult.Add(CopyRecursively(ListItem.Value), ListItem.Presentation,
			ListItem.Check, ListItem.Picture);
	EndDo;

	Return ValueListResult;

EndFunction

// Converts  JobSchedule to Structure.
//
// Parameters:
//  Schedule - JobSchedule - original schedule.
// 
// Return value:
//  Structure - schedule as structure.
//
Function ScheduleToStructure (Val Schedule) Export

	ScheduleValue = Schedule;
	If ScheduleValue = Undefined Then
		ScheduleValue = New JobSchedule;
	EndIf;
	KeysList = "CompletionTime,EndTime,BeginTime,EndDate,BeginDate,DayInMonth,WeekDayInMonth,"
		+ "WeekDays,CompletionInterval,Months,RepeatPause,WeeksPeriod,RepeatPeriodInDay,DaysRepeatPeriod";
	Result = New Structure(KeysList);
	FillPropertyValues(Result, ScheduleValue, KeysList);
	DetailedDailySchedules = New Array;
	For Each DailySchedule In Schedule.DetailedDailySchedules Do
		DetailedDailySchedules.Add(ScheduleToStructure(DailySchedule));
	EndDo;
	Result.Вставить("DetailedDailySchedules", DetailedDailySchedules);
	Return Result;

EndFunction

// Converts  Structure to JobSchedule  .
// Parameters:
//  ScheduleStructure - Structure - Schedule in Structure form.
// 
// Return value:
//  JobSchedule - Schedule.
//
Function StructureToSchedule(Знач ScheduleStructure) Export

	If ScheduleStructure = UNdefined Then
		Return New JobSchedule;
	EndIf;
	KeysList = "CompletionTime,EndTime,BeginTime,EndDate,BeginDate,DayInMonth,WeekDayInMonth,"
		+ "WeekDays,CompletionInterval,Months,RepeatPause,WeeksPeriod,RepeatPeriodInDay,DaysRepeatPeriod";
	Result = New JobSchedule;
	FillPropertyValues(Result, ScheduleStructure, KeysList);

	DetailedDailySchedules = New Array;
	For Each Schedule In ScheduleStructure.DetailedDailySchedules Do
		DetailedDailySchedules.Add(StructureToSchedule(Schedule));
	EndDo;
	Result.DetailedDailySchedules = DetailedDailySchedules;
	Return Result;

EndFunction

// Raises an exception if the ParameterName parameter value type of the ProcedureOrFunctionName 
// procedure or function does not match the excepted one.
// For validating types of parameters passed to the interface procedures and functions.
//
// Parameters:
//   ProcedureOrFunctionName - String          - name of the procedure or function that contains the parameter to check.
//   ParameterName           - String          - name of the parameter of procedure or function to check.
//   ParameterValue          - Arbitrary       - actual value of the parameter.
//   ExpectedTypes  - TypesDescription, Type, Array - type(s) of the parameter of procedure or function..
//   PropertiesTypesToExpect   - Structure     -if the expected type is a structure, this parameter can be used to specify its properties.
//
Procedure CheckParameter(Val ProcedureOrFunctionName, Val ParameterName, Val ParameterValue, Val ExpectedTypes,
	Val PropertiesTypesToExpect = Undefined) Export

	Context = "CommonClientServer.CheckParameter";
	Validate(
		TypeOf(ProcedureOrFunctionName) = Type("String"),
		NStr("ru = 'Недопустимое значение параметра ИмяПроцедурыИлиФункции'; en = 'Invalid value of ProcedureOrFunctionName parameter.'"), 
		Context);
		
	Validate(
		TypeOf(ParameterName) = Type("String"), 
		NStr("ru = 'Недопустимое значение параметра ИмяПараметра'; en = 'Invalid value of ParameterName parameter.'"),
		Context);

	IsCorrectType = ExpectedTypeValue(ParameterValue, ExpectedTypes);
	
	Validate(
		IsCorrectType <> Undefined, 
		NStr("ru = 'Недопустимое значение параметра ОжидаемыеТипы'; en = 'Invalid value of ExpectedTypes parameter.'"), 
		Context);

	InvalidParameter = NStr("ru = 'Недопустимое значение параметра %1 в %2. 
			           |Ожидалось: %3; передано значение: %4 (тип %5).'; 
			           |en = 'Invalid value of the %1 parameter in %2.
			           |Expected value: %3, passed value: %4 (type: %5).'");
								
								
	Validate(IsCorrectType, StrTemplate(InvalidParameter, ParameterName, ProcedureOrFunctionName,
		TypesPresentation(ExpectedTypes), ?(ParameterValue <> Undefined, ParameterValue, NStr(
		"ru = 'Неопределено'; en = 'Undefined'")), TypeOf(ParameterValue)));

	If TypeOf(ParameterValue) = Type("Structure") AND PropertiesTypesToExpect <> Undefined Then

		Validate(
			TypeOf(PropertiesTypesToExpect) = Type("Structure"),
			 NStr("ru = 'Недопустимое значение параметра ИмяПроцедурыИлиФункции';
				 | en = 'Invalid value of ProcedureOrFunctionName parameter.'"), 
			Context);

		NoProperty = NStr("ru = 'Недопустимое значение параметра %1 (Структура) в %2. 
					           |В структуре ожидалось свойство %3 (тип %4).'; 
					           |en = 'Invalid value of parameter %1 (Structure) in %2.
					           |Expected value: %3 (type: %4).'");
						   
		InvalidProperty = NStr("ru = 'Недопустимое значение свойства %1 в параметре %2 (Структура) в %3. 
					           |Ожидалось: %4; передано значение: %5 (тип %6).'; 
					           |en = 'Invalid value of property %1 in parameter %2 (Structure) in %3.
					           |Expected value: %4; passed value: %5 (type: %6).'");
					           
		For Each Property In PropertiesTypesToExpect Do

			ExpectedPropertyName = Property.Key;
			ExpectedPropertyType = Property.Value;
			PropertyValue = Undefined;

			Validate(
				ParameterValue.Свойство(ExpectedPropertyName, PropertyValue), 
				StrTemplate(NoProperty,ParameterName, ProcedureOrFunctionName, ExpectedPropertyName, ExpectedPropertyType));

			IsCorrectType = ExpectedTypeValue(PropertyValue, ExpectedPropertyType);
			Validate(IsCorrectType, StrTemplate(InvalidProperty, ExpectedPropertyName, ParameterName,
				ProcedureOrFunctionName, TypesPresentation(ExpectedTypes), ?(PropertyValue <> Undefined,
				PropertyValue, NStr("ru = 'Неопределено'; en = 'Undefined'")), TypeOf(PropertyValue)));
		EndDo;
	EndIf;

EndProcedure

// Raise exeption with text Message when Condition not equal True.
// It is used for self-diagnosis of the code.
//
// Parameters:
//   Condition            - Boolean - if not True - raise Exeption
//   CheckContext     	  - String - for example, name of procedure or function where the check is performed.
//   Message              - String - text of message.If not set up , would exeption with default text                                     умолчанию.
//
Procedure Validate(Val Condition, Val Message = "", Val CheckContext = "") Export

	If Condition <> True Then
		If IsBlankString(Message) Then
			RaiseText = Nstr("ru = 'Недопустимая операция';en='Invalid operation'"); // Assertion failed
		Else
			RaiseText = Message;
		Endif;
		If Not IsBlankString(CheckContext) Then
			RaiseText = RaiseText + " " + StrTemplate(Nstr("ru = 'в %1';en='at %1'"), CheckContext);
		EndIf;
		Raise RaiseText;
	EndIf;

КонецПроцедуры

Function TypesPresentation(ExpectedTypes)
	If Typeof(ExpectedTypes) = Type("Array") Then
		Result = "";
		Index = 0;
		For Each Type In ExpectedTypes Do
			If Not IsBlankString(Result) Then
				Result = Result + ", ";
			EndIf;
			Result = Result + TypePresentation(Type);
			Index = Index + 1;
			If Index > 10 Then
				Result = Result + ",... " + StrTemplate(Nstr("ru = '(всего %1 типов)';en = '(total %1 of types)'"), ExpectedTypes.Count());
				Break;
			EndIf;
		EndDo;
		Return Result;
	Else
		Return TypePresentation(ExpectedTypes);
	EndIf;
EndFunction

Function TypePresentation(Type)
	If Type = Undefined Then
		Return "Undefined";
	ElsIf TypeOf(Type) = Type("TypeDescription") Then
		TypeString = String(Type);
		Return ?(StrLen(TypeString) > 150, Left(TypeString, 150) + "..." + StrTemplate(NStr("ru = '(всего %1 типов)';en = '(total %1 types'"),
			Type.Типы().Количество()), TypeString);
	    Else
		TypeString = String(Type);
		Return ?(СтрДлина(TypeString) > 150, Лев(TypeString, 150) + "...", TypeString);
	EndIf;
	
EndFunction

Function ExpectedTypeValue(Value, ExpectedTypes)
	ValueType = TypeOf(Value);
	If TypeOf(ExpectedTypes) = Type("TypeDescription") Then
		Return ExpectedTypes.Types().Find(ValueType) <> Undefined;
	ElsIf TypeOf(ExpectedTypes) = Type("Type") Then
		Return ValueType = ExpectedTypes;
	ElsIf TypeOf(ExpectedTypes) = Type("Array") Or TypeOf(ExpectedTypes) = Type("FixedArray") Then
		Return ExpectedTypes.Find(ValueType) <> Undefined;
	ElsIf TypeOf(ExpectedTypes) = Type("Map") 	Or TypeOf(ExpectedTypes) = Type("FixedMap") Then
		Return ExpectedTypes.Get(ValueType) <> Undefined;
	EndIf;
	
	Return Undefined;
EndFunction

Procedure AddObjectsArrayToCompare(Objects) Export
	UT_CommonServerCall.AddObjectsArrayToCompare(Objects);
EndProcedure

// Return code of configuration default language , for example "ru".
//
// Return:
// String - language code.
//
Function DefaultLanguageCode() Export
#If Not  ThinClient And Not WebClient And Not MobileClient Then
	Return Metadata.DefaultLanguage.LanguageCode;
#Else
	Return UT_CommonCached.DefaultLanguageCode();
#EndIf
EndFunction

// Return a reference to the predefined item by its full name.
// Only the following objects can contain predefined objects:
//   - Catalogs,
//   - Charts of characteristic types,
//   - Charts of accounts,
//   - Charts of calculation types.
//
//  Parameters:
//   PredefinedItemFullName - String - full path to the predefined item including the name.
//     The format is identical to the PredefinedValue() global context function.
//     Example:
//       "Catalog.ContactInformationKinds.UserEmail"
//
// Returns:
//   AnyRef - reference to the predefined item;
//   Undefined - if the predefined item exists in metadata but not in the infobase.
//
Function PredefinedItem(FullPredefinedItemName) Export

// Using a standard function to get:
	//  - blank references
	//  - enumeration values
	//  - business process route points
	If ".EMPTYREF" = Upper(Right(FullPredefinedItemName, 13))
		Or "ENUM." = Upper(Left(FullPredefinedItemName, 13)) 
		Or "BUSINESSPROCESS." = Upper(Left(FullPredefinedItemName, 14)) Then
		
		Return PredefinedValue(FullPredefinedItemName);
	EndIf;
	

	// Parsing the full name of the predefined item.
	FullNameParts = StrSplit(FullPredefinedItemName, ".");
	If FullNameParts.Count() <> 3 Then 
		Raise CommonInternalClientServer.PredefinedValueNotFoundErrorText(
			FullPredefinedItemName);
	EndIf;

	FullMetadataObjectName = Upper(FullNameParts[0] + "." + FullNameParts[1]);
	PredefinedItemName = FullNameParts[2];
	
	// Cache to be called is determined by context.
	
#If Server Or ThickClientOrdinaryApplication Or ExternalConnection Then
	PredefinedValues = UT_CommonCached.RefsByPredefinedItemsNames(FullMetadataObjectName);
#Else
	PredefinedValues = UT_CommonClientCached.RefsByPredefinedItemsNames(FullMetadataObjectName);
#EndIf

	// In case of error in metadata name.
	If PredefinedValues = Undefined Then
		Raise PredefinedValueNotFoundErrorText(FullPredefinedItemName);
	EndIf;

	// Getting result from cache.
	Result = PredefinedValues.Get(PredefinedItemName);

    // If the predefined item does not exist in metadata.
	If Result = Undefined Then 
		Raise PredefinedValueNotFoundErrorText(FullPredefinedItemName);
	EndIf;

// If the predefined item exists in metadata but not in the infobase.
	If Result = Null Then 
		Return Undefined;
	EndIf;
	
	Return Result;

EndFunction

Function PredefinedValueNotFoundErrorText(PredefinedItemFullName) Export
	
	Return StrTemplate(NStr("ru = 'Предопределенное значение ""%1"" не найдено.'; en = 'Predefined value ""%1"" is not found.'"), PredefinedItemFullName);
	
EndFunction

Function СancelledTimeConsumingOperationsParametrName(Parameters) Export
	Return "UT_СancelledTimeConsumingOperations";
EndFunction

// Returns the structure property value.
//
// Parameters:
//   Structure - Structure, FixedStructure - an object to read key value from.
//   Key - String - the structure property whose value to read.
//   DefaultValue - Arbitrary - Optional. Returned when the structure contains no value for the 
//                                        given key.
//       To keep the system performance, it is recommended to pass only easy-to-calculate values 
//       (for example, primitive types). Pass performance-demanding values only after ensuring that 
//       the value is required.
//
// Returns:
//   Arbitrary - the property value. If the structure missing the property, returns DefaultValue.
//
Function StructureProperty(Structure, varKey, DefaultValue = Undefined) Export
	
	If Structure = Undefined Then
		Return DefaultValue;
	EndIf;
	
	Result = DefaultValue;
	If Structure.Property(varKey, Result) Then
		Return Result;
	Else
		Return DefaultValue;
	EndIf;
	
EndFunction

// Generates and show the message that can relate to a form item..
//
// Parameters:
//  UserMessageText - String - a mesage text.
//  DataKey - AnyRef - the infobase record key or object that message refers to.
//  Field                       - String - a form attribute description.
//  DataPath - String - a data path (a path to a form attribute).
//  Cancel - Boolean - an output parameter. Always True.
//
// Example:
//
//  1. Showing the message associated with the object attribute near the managed form field
//  CommonClientServer.MessageToUser(
//   NStr("en = 'Error message.'"), ,
//   "FieldInFormAttributeObject",
//   "Object");
//
//  An alternative variant of using in the object form module
//  CommonClientServer.MessageToUser(
//   NStr("en = 'Error message.'"), ,
//   "Object.FieldInFormAttributeObject");
//
//  2. Showing a message for the form attribute, next to the managed form field:
//  CommonClientServer.MessageToUser(
//   NStr("en = 'Error message.'"), ,
//   "FormAttributeName");
//
//  3. To display a message associated with an infobase object:
//  CommonClientServer.MessageToUser(
//   NStr("en = 'Error message.'"), InfobaseObject, "Responsible person",,Cancel);
//
//  4. To display a message from a link to an infobase object:
//  CommonClientServer.MessageToUser(
//   NStr("en = 'Error message.'"), Reference, , , Cancel);
//
//  Scenarios of incorrect using:
//   1. Passing DataKey and DataPath parameters at the same time.
//   2. Passing a value of an illegal type to the DataKey parameter.
//   3. Specifying a reference without specifying a field (and/or a data path).
//
Процедура MessageToUser(Val MessageToUserText,Val DataKey = Undefined,Val Field = "",Val DataPath = "",
		Cancel = False) Export
		
	Message = New UserMessage;
	Message.Text = MessageToUserText;
	Message.Field = Field;
	
	IsObject = False;

#If NOT ThinClient AND NOT WebClient AND NOT MobileClient Then
	If DataKey <> Undefined
	   AND XMLTypeOf(DataKey) <> Undefined Then
		ValueTypeAsString = XMLTypeOf(DataKey).TypeName;
		IsObject = StrFind(ValueTypeAsString, "Object.") > 0;
	EndIf;
#EndIf

	If IsObject Then
		Message.SetData(DataKey);
	Else
		Message.DataKey = DataKey;
	EndIf;
	
	If NOT IsBlankString(DataPath) Then
		Message.DataPath = DataPath;
	EndIf;
		
	Message.Message();
	
	Cancel = True;

КонецПроцедуры

// Supplements the DestinationArray array with values from the SourceArray array.
//
// Parameters:
//  DestinationArray - Array - the array that receives values.
//  SourceArray - Array - the array that provides values.
//  UniqueValuesOnly - Boolean - if True, the array keeps only unique values.
Procedure SupplementArray(DestinationArray, SourceArray, UniqueValuesOnly = False) Export

	If UniqueValuesOnly Then
		UniqueValues = New Map;
		For Each Value In DestinationArray Do
			UniqueValues.Insert(Value, True);
		EndDo;
		For Each Value In SourceArray Do
			If UniqueValues[Value] = Undefined Then
				DestinationArray.Add(Value);
				UniqueValues.Insert(Value, True);
			EndIf;
		EndDo;
	Else
		For Each Value In SourceArray Do
			DestinationArray.Add(Value);
		EndDo;
	EndIf;
EndProcedure

Function IsWindows() Export
	SystemInfo = Новый SystemInfo;
	Return SystemInfo.PlatformType = PlatformType.Windows_x86 Или SystemInfo.PlatformType
		= PlatformType.Windows_x86_64;
EndFunction

Function IsLinux() Export
	SystemInfo = New SystemInfo;
	Return SystemInfo.PlatformType = PlatformType.Linux_x86 Или SystemInfo.PlatformType
		= PlatformType.Linux_x86_64;
EndFunction

Function PlatformVersionNotLess_8_3_14() Export
	Return PlatformVersionNotLess("8.3.14");
EndFunction

Function PlatformVersionNotLess(ComparingVersion) Export
	VersionWithOutReleaseSubnumber=ConfigurationVersionWithOutReleaseSubnumber(CurrentAppVersion());

	Return CompareVersionsWithOutReleaseSubnumber(VersionWithOutReleaseSubnumber, ComparingVersion)>=0;
EndFunction

Function HTMLFieldBasedOnWebkit() Export
	Return PlatformVersionNotLess_8_3_14() OR IsLinux()
EndFunction

#Region Variables
Function IsCorrectVariableName(Name) Export
	If Not ValueIsFilled(Name) Then
		Return False;
	EndIf;
	IsCorrectName = False;
	//@skip-warning
	Try
		//@skip-warning
		TempVar = New Structure(Name);
		IsCorrectName=True;
	Except
		
	EndTry;
	
	Return IsCorrectName;
EndFunction

Function WrongVariableNameWarningText() Export
	Return NStr("ru = 'Неверное имя колонки! Имя должно состоять из одного слова, начинаться с буквы и не содержать специальных символов кроме """"_"""".""';en = 'en=''Invalid column name! The name must consist of a single word, start with a letter and contain no special characters other than """"_"""".""'");
EndFunction

#EndRegion
#Region DynamicList

#EndRegion
#Region Debug
#EndRegion
#Region HTTPRequests
#EndRegion
#Region JSON
#EndRegion

// Returns 1C:Enterprise current version.
//
Function CurrentAppVersion() Export

	SystemInfo = New SystemInfo;
	Return SystemInfo.AppVersion;

EndFunction

// Get configuration version number without build number (Release subnumber).
//
// Params:
//  Version - String - configuration version as PV.MV.R.RS,
//                    where RS - Release subnumber, that will be deleted.
//                    PV - <primary version>, MV - <minor version>, R - <release>
// 
// Return Value:
//  String - configuration version number without  Release subnumber -  PV.MV.R
//
Function ConfigurationVersionWithOutReleaseSubnumber(Val Version) Export

	Array = StrSplit(Version, ".");

	If Array.Count() < 3 Then
		Return Version;
	EndIf;

	Result = "[Primary].[Minor].[Release]";
	Result = StrReplace(Result, "[Primary]", Array[0]);
	Result = StrReplace(Result, "[Minor]", Array[1]);
	Result = StrReplace(Result, "[Release]", Array[2]);

	Return Result;
EndFunction

// Compare two strings that contains version info
//
// Parameters:
//  Version1String  - String - number of version in  РР.{M|MM}.RR.RS format
//  Version2String  - String - secound compared version number.
//
// Return Value значение:
//   Integer   - more than 0, if Version1String > Version2String; 0, if version values is equal.
//
Function CompareVersions(Val Version1String, Val Version2String) Export

	String1 = ?(IsBlankString(Version1String), "0.0.0.0", Version1String);
	String2 = ?(IsBlankString(Version2String), "0.0.0.0", Version2String);
	Version1 = StrSplit(String1, ".");
	If Version1.Count() <> 4 Then
		Raise StrTemplate(NStr("ru = 'Неправильный формат параметра Version1String: %1'; en='Wrong format of parameter Version1String: %1'"), Version1String);
	EndIf;
	Version2 = StrSplit(String2, ".");
	If Version2.Count() <> 4 Then
		Raise StrTemplate(NStr("ru = 'Неправильный формат параметра Version2String: %1'; en='Wrong format of parameter Version2String: %1'"), Version2String);
	EndIf;

	Result = 0;
	For Digit = 0 to 3 do
		Result = Number(Version2[Digit]) - Number(Version2[Digit]);
		If Result <> 0 Then
			Return Result;
		EndIf;
	EndDo;
	Return Result;

EndFunction

// Compare two strings that contains version info
//
// Parameters:
//  Version1String  - String - number of version in  РР.{M|MM}.RR format
//  Version2String  - String - secound compared version number.
//
// Return Value значение:
//   Integer   - more than 0, if Version1String > Version2String; 0, if version values is equal.
//
Function CompareVersionsWithOutReleaseSubnumber(Val Version1String, Val Version2String) Export

	String1 = ?(IsBlankString(Version1String), "0.0.0", Version1String);
	String2 = ?(IsBlankString(Version2String), "0.0.0", Version2String);
	Version1 = StrSplit(String1, ".");
	If Version1.Count() <> 3 Then
		Raise StrTemplate(NStr("ru = 'Неправильный формат параметра Version1String: %1'; en='Wrong format of parameter Version1String: %1'"), Version1String);
	EndIf;
	Version2 = StrSplit(String2, ".");
	If Version2.Count() <> 3 Then
		Raise StrTemplate(NStr("ru = 'Неправильный формат параметра Version2String: %1'; en='Wrong format of parameter Version2String: %1'"), Version2String);
	EndIf;

	Result = 0;
	For Digit = 0 to 2 do
		Result = Number(Version1[Digit]) - Number(Version2[Digit]);
		If Result <> 0 Then
			Return Result;
		EndIf;
	КонецЦикла;
	Return Result;

EndFunction

#Region WriteParams

#EndRegion

#Region FileFunctions

#EndRegion

// The index of the file icon is being received. It is the index in the FilesIconsCollection picture.
Function GetFileIconIndex(val FileExtention) Export

	If TypeOf(FileExtention) <> Type("String") Or IsBlankString(FileExtention) Then

		Return 0;
	EndIf;

	FileExtention = ExtensionWithoutDot(FileExtention);

	Extension = "." + Lower(FileExtention) + ";";
	
	If StrFind(".dt;.1cd;.cf;.cfu;", Extension) <> 0 Then
		Return 6; // 1C files.
		
	ElsIf Extension = ".mxl;" Then
		Return 8; // Spreadsheet File.
		
	ElsIf StrFind(".txt;.log;.ini;", Extension) <> 0 Then
		Return 10; // Text File.
		
	ElsIf Extension = ".epf;" Then
		Return 12; // External data processors.
		
	ElsIf StrFind(".ico;.wmf;.emf;",Extension) <> 0 Then
		Return 14; // Pictures.
		
	ElsIf StrFind(".htm;.html;.url;.mht;.mhtml;",Extension) <> 0 Then
		Return 16; // HTML.
		
	ElsIf StrFind(".doc;.dot;.rtf;",Extension) <> 0 Then
		Return 18; // Microsoft Word file.
		
	ElsIf StrFind(".xls;.xlw;",Extension) <> 0 Then
		Return 20; // Microsoft Excel file.
		
	ElsIf StrFind(".ppt;.pps;",Extension) <> 0 Then
		Return 22; // Microsoft PowerPoint file.
		
	ElsIf StrFind(".vsd;",Extension) <> 0 Then
		Return 24; // Microsoft Visio file.
		
	ElsIf StrFind(".mpp;",Extension) <> 0 Then
		Return 26; // Microsoft Visio file.
		
	ElsIf StrFind(".mdb;.adp;.mda;.mde;.ade;",Extension) <> 0 Then
		Return 28; // Microsoft Access database.
		
	ElsIf StrFind(".xml;",Extension) <> 0 Then
		Return 30; // xml.
		
	ElsIf StrFind(".msg;.eml;",Extension) <> 0 Then
		Return 32; // Email.
		
	ElsIf StrFind(".zip;.rar;.arj;.cab;.lzh;.ace;",Extension) <> 0 Then
		Return 34; // Archives.
		
	ElsIf StrFind(".exe;.com;.bat;.cmd;",Extension) <> 0 Then
		Return 36; // Files being executed.
		
	ElsIf StrFind(".grs;",Extension) <> 0 Then
		Return 38; // Graphical schema.
		
	ElsIf StrFind(".geo;",Extension) <> 0 Then
		Return 40; // Geographical schema.
		
	ElsIf StrFind(".jpg;.jpeg;.jp2;.jpe;",Extension) <> 0 Then
		Return 42; // jpg.
		
	ElsIf StrFind(".bmp;.dib;",Extension) <> 0 Then
		Return 44; // bmp.
		
	ElsIf StrFind(".tif;.tiff;",Extension) <> 0 Then
		Return 46; // tif.
		
	ElsIf StrFind(".gif;",Extension) <> 0 Then
		Return 48; // gif.
		
	ElsIf StrFind(".png;",Extension) <> 0 Then
		Return 50; // png.
		
	ElsIf StrFind(".pdf;",Extension) <> 0 Then
		Return 52; // pdf.
		
	ElsIf StrFind(".odt;",Extension) <> 0 Then
		Return 54; // Open Office writer.
		
	ElsIf StrFind(".odf;",Extension) <> 0 Then
		Return 56; // Open Office math.
		
	ElsIf StrFind(".odp;",Extension) <> 0 Then
		Return 58; // Open Office Impress.
		
	ElsIf StrFind(".odg;",Extension) <> 0 Then
		Return 60; // Open Office draw.
		
	ElsIf StrFind(".ods;",Extension) <> 0 Then
		Return 62; // Open Office calc.
		
	ElsIf StrFind(".mp3;",Extension) <> 0 Then
		Return 64;
		
	ElsIf StrFind(".erf;",Extension) <> 0 Then
		Return 66; // External reports.
		
	ElsIf StrFind(".docx;",Extension) <> 0 Then
		Return 68; // Microsoft Word docx file.
		
	ElsIf StrFind(".xlsx;",Extension) <> 0 Then
		Return 70; // Microsoft Excel xlsx file.
		
	ElsIf StrFind(".pptx;",Extension) <> 0 Then
		Return 72; // Microsoft PowerPoint pptx file.
		
	ElsIf StrFind(".p7s;",Extension) <> 0 Then
		Return 74; // Signature file
		
	ElsIf StrFind(".p7m;",Extension) <> 0 Then
		Return 76; // encrypted message.
	Else
		Return 4;
	EndIf;
EndFunction

// Convert File Extension to lower case without Dot character
//
// Parameters:
//  FileExtension - String - extension for converting.
//
// Return value:
//  String.
//
Function ExtensionWithoutDot(Val FileExtension) Export

	FileExtension = Lower(TrimAll(FileExtension));

	If Mid(FileExtension, 1, 1) = "." Then
		FileExtension = Mid(FileExtension, 2);
	EndIf;

	Return FileExtension;

EndFunction

#Region ToolsSettings
	
Function SettingsDataKeyInSettingsStorage() Export
	Return "UT_UniversalTools_Settings";
EndFunction

Function SessionParametersSettingsKey() Export
	Return "SessionParameters";
EndFunction
	
#EndRegion

#Region DistributionSettings
Function DownloadFileName() Export
	Return "UT_International.cfe";
EndFunction

Function DistributionType() Export
	Return "Extension";
EndFunction

Function PortableDistributionType() Export
	Return "Portable";
EndFunction

Function Version() Export
	Return "1.4.6";	
EndFunction

Function IsPortableDistribution() Export
	Return DistributionType() = PortableDistributionType();	
EndFunction
#EndRegion

Function ManagedFormType() Export
	If PlatformVersionNotLess_8_3_14() Then
		Return Type("ClientApplicationForm")
	Else
		Return Type("ManagedForm");
	EndIf;
EndFunction

Function ToolsFormOutputWriteSettings() Export
	Array=New Array;
	Array.Add("WritingInLoadMode");    
	Array.Add("PrivilegedMode");     
	Array.Add("WithOutChangeRecording");
	Return Array;
EndFunction

Function FormWriteSettings(Форма, ПрефиксРеквизитаФормы = "ПараметрЗаписи_") Export
	WriteSettings=StructureПараметровЗаписиПоУмолчанию();

	For each КлючЗначение In WriteSettings Do
		If ТипЗнч(КлючЗначение.Значение) = Type("Structure") Then
			For Each Стр In Форма[ПрефиксРеквизитаФормы + КлючЗначение.Ключ] Do
				WriteSettings[КлючЗначение.Ключ].Вставить(Стр.Ключ, Стр.Значение);
			EndDo;
		Else
			WriteSettings[КлючЗначение.Ключ]=Форма[ПрефиксРеквизитаФормы + КлючЗначение.Ключ];
		EndIf;
	EndDo;
//	ЗаполнитьЗначенияСвойств(ПараметрыЗаписи, Форма);
	Return WriteSettings;
EndFunction