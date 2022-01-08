
////////////////////////////////////////////////////////////////////////////////
// FORM EVENT HANDLERS
&AtClient
Procedure OnOpen(Cancel)

	BeginAttachingFileSystemExtension(New NotifyDescription("OnOpenEnd", ThisForm));

EndProcedure

&AtClient
Procedure OnOpenEnd(Connected, AdditionalParameters) Export

	FileSelectionCapability = Connected;

EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	If Parameters.Property("AutoTest") Then // Возврат при получении формы для анализа.
		Return;
	EndIf;

	DeletionMode = "Full";
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.CommandBars);

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// TOP ELEMENT EVENT HANDLERS

&AtClient
Procedure DeleteModeOnChange(Item)
	
	UpdateAvailablButtons();
	
EndProcedure


////////////////////////////////////////////////////////////////////////////////
//FORM TABLE MarkedForDeletionItemsTree EVENT HANDLERS

&AtClient
Procedure MarkOnChange(Item)

	CurrentData = Items.MarkedForDeletionItemsTree.CurrentData;

	If CurrentData = Undefined Then
		Return;
	EndIf;

	SetMarkInList(CurrentData, CurrentData.Mark, True);

EndProcedure



&AtClient
Procedure MarkedForDeletionItemsTreeSelection(Item, RowSelected, Field, StandardProcessing)

	StandardProcessing = False;

	If Item.CurrentData <> Undefined Then
		OpenValueByType(Item.CurrentData.Value);
	EndIf;

EndProcedure

////////////////////////////////////////////////////////////////////////////////
//FORM TABLE NotDeletedItemsTree EVENT HANDLERS

&AtClient
Procedure NotDeletedItemsTreeSelection(Item, RowSelected, Field, StandardProcessing)

	StandardProcessing = False;

	If Item.CurrentData <> Undefined Then
		OpenValueByType(Item.CurrentData.Value);
	EndIf;

EndProcedure

&AtClient
Procedure NotDeletedItemsTreeBeforeRowChange(Item, Cancel)

	Cancel = True;

	If Item.CurrentData <> Undefined Then
		OpenValueByType(Item.CurrentData.Value);
	EndIf;

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// FORM COMANDS EVENT HANDLERS

&AtClient
Procedure CommandSelectedListSetAll()

	ListItems = MarkedForDeletionItemsTree.GetItems();
		For Each Item In ListItems Do
		SetMarkInList(Item, True, True);
		Parent = Item.GetParent();
		If Parent = Undefined Then
			CheckParent(Item);
		EndIf;
	EndDo;

EndProcedure

&AtClient
Procedure CommandSelectedListClearAll()

	ListItems = MarkedForDeletionItemsTree.GetItems();
	For Each Item In ListItems Do
		SetMarkInList(Item, False, True);
		Parent = Item.GetParent();
		If Parent = Undefined Then
			CheckParent(Item);
		EndIf;
	EndDo;

EndProcedure

&AtClient
Procedure ChangeObject(Command)

	If CurrentItem = Undefined Then
		Return;
	EndIf;

	If CurrentItem <> Items.MarkedForDeletionItemsTree And CurrentItem <> Items.NotDeletedItems Then
		Return;
	EndIf;

	If CurrentItem.CurrentData <> Undefined Then
		OpenValueByType(CurrentItem.CurrentData.Value);
	EndIf;

EndProcedure
&AtClient
Procedure EditObject(Command)
	If CurrentItem = Undefined Then
		Return;
	EndIf;

	If CurrentItem <> Items.MarkedForDeletionItemsTree And CurrentItem <> Items.NotDeletedItems Then
		Return;
	EndIf;

	If CurrentItem.CurrentData <> Undefined Then
		UT_CommonClient.EditObject(CurrentItem.CurrentData.Value);
	EndIf;
EndProcedure
&AtClient
Procedure RunNext()

	CurrentPage = Items.FormPages.CurrentPage;

	If CurrentPage = Items.SelectDeleteMode Then

		UpdateDeleteMarkedList(Undefined);

		Items.FormPages.CurrentPage = Items.MarkedForDelete;
		UpdateAvailablButtons();

	EndIf;

EndProcedure

&AtClient
Procedure RunBack()

	CurrentPage = Items.FormPages.CurrentPage;
	If CurrentPage = Items.MarkedForDelete Then
		Items.FormPages.CurrentPage = Items.SelectDeleteMode;
		UpdateAvailablButtons();
	ElsIf CurrentPage = Items.DeletionFailureReasonsPage Then
		If DeletionMode = "Full" Then
			Items.FormPages.CurrentPage = Items.SelectDeleteMode;
		Else
			Items.FormPages.CurrentPage = Items.MarkedForDelete;
		EndIf;
		UpdateAvailablButtons();
	EndIf;

EndProcedure

&AtClient
Procedure RunDelete()

	Перем DeletionObjectsTypes;
	

	If DeletionMode = "Full" Then
		Status(NStr("en = 'Find and deletion of marked objects ; ru = 'Выполняется поиск и удаление помеченных объектов'"));
	Else
		Status(NStr("en = 'Deletion of marked objects' ; ru = 'Выполняется удаление выбранных объектов'"));
	EndIf;

	Result = DeletionMarkedAtServer(DeletionObjectsTypes);
	If Не Result.JobCompleted Then
		ScheduledJobID 		  = Result.ScheduledJobID;
		StorageAddress       = Result.StorageAddress;

		UT_TimeConsumingOperationsClient.InitializeIdleHandlerParameters(IdleHandlerParameters);

		AttachIdleHandler("Attachable_CheckTaskCompletion", 1, True);
		Items.FormPages.CurrentPage = Items.TimeConsumingOperationPage;
	Else
		UpdateContent(Result.DeletionResult, Result.ErrorMessage,
			Result.DeletionResult.DeletionObjectsTypes);
		AttachIdleHandler("SwitchPage", 0.1, True);
	EndIf;

EndProcedure

&AtClient
Procedure UpdateDeleteMarkedList(Command)

	Status(NStr("en = 'Searching for objects marked for deletion' ; ru = 'Выполняется поиск помеченных на удаление объектов'"));

	FullMarkedForDeletionTree();

	If NomberOfLevelsMarkedForDeletion = 1 Then
		For Each Item In MarkedForDeletionItemsTree.GetItems() Do
			RowID = Item.GetID();
			Items.MarkedForDeletionItemsTree.Expand(RowID, False);
		EndDo;
	EndIf;

EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ConfigureRecordingParameters(Command)
	UT_CommonClient.EditRecordingParameters(ThisObject);
EndProcedure

&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) Экспорт
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// SERVICE PROCEDURES AND FUNCTIONS

&AtServer
Function ValueByType(Value)

	MetadataObject = Metadata.FindByType(TypeOf(Value));

	If MetadataObject <> Undefined And UT_Common.IsRegister(MetadataObject) Then

		List = Новый ValueList();
		List.Add(Value, MetadataObject.FullName());
		Возврат List;
	EndIf;

	Возврат Value;

EndFunction

&AtClient
Procedure OpenValueByType(Value)

	If TypeOf(Value) = Type("ValueList") Then
		ValueDescripton = Value.Get(0);

		FormParametrs = New Структура;
		FormParametrs.Вставить("Key", ValueDescripton.Value);

		OpenForm(ValueDescripton.Presentation + ".RecordForm", FormParametrs, ThisForm);
	Else
		ShowValue(Undefined, Value);
	EndIf;

EndProcedure

&AtClient
Procedure UpdateContent(Result, ErrorMessage, DeletionObjectsTypes)

	If Result.Статус Then
		For Each DeletionObjectType In DeletionObjectsTypes Do
			NotifyChanged(DeletionObjectType);
		EndDo;
	Else
		PageName = "SelectDeleteMode";
		ShowMessageBox( , ErrorMessage);
		Return;
	EndIf;

	UpdateMarkedTree = True;
	If NomberNotDeletedObjects = 0 Then
		If DeletedObjects = 0 Then
			Text = Nstr("ru = 'Не помечено на удаление ни одного объекта. Удаление объектов не выполнялось.'");
			UpdateMarkedTree = False;
		Else
			Текст = СтрШаблон(
			             НСтр("ru = 'Удаление помеченных объектов успешно завершено.
							  |Удалено объектов: %1.'"), DeletedObjects);
		EndIf;
		PageName = "SelectDeleteMode";
		ПоказатьПредупреждение( , Текст);
	Else
		PageName = "DeletionFailureReasonsPage";
		For Each Элемент In NotDeletedItemsTree.ПолучитьЭлементы() Do
			Идентификатор = Элемент.ПолучитьИдентификатор();
			Items.NotDeletedItems.Развернуть(Идентификатор, False);
		EndDo;
		ПоказатьПредупреждение( , ResultLine);
	EndIf;

	If UpdateMarkedTree Then
		UpdateDeleteMarkedList(Undefined);
	EndIf;

EndProcedure

&AtClient
Procedure SwitchPage()
	If PageName <> "" Then
		Страница = Items.Найти(PageName);
		If Страница <> Undefined Then
			Items.FormPages.ТекущаяСтраница = Страница;
			UpdateAvailablButtons();
		EndIf;
		PageName = "";
	EndIf;
EndProcedure

&AtClient
Procedure UpdateAvailablButtons()

	ТекущаяСтраница = Items.FormPages.ТекущаяСтраница;

	If ТекущаяСтраница = Items.SelectDeleteMode Then
		Items.CommandBack.Доступность   = False;
		If DeletionMode = "Full" Then
			Items.CommandNext.Доступность   = False;
			Items.CommandDelete.Доступность = True;
		ElsIf DeletionMode = "Выборочный" Then
			Items.CommandNext.Доступность 	= True;
			Items.CommandDelete.Доступность = False;
		EndIf;
	ElsIf ТекущаяСтраница = Items.MarkedForDelete Then
		Items.CommandBack.Доступность   = True;
		Items.CommandNext.Доступность   = False;
		Items.CommandDelete.Доступность = True;
	ElsIf ТекущаяСтраница = Items.DeletionFailureReasonsPage Then
		Items.CommandBack.Доступность   = True;
		Items.CommandNext.Доступность   = False;
		Items.CommandDelete.Доступность = False;
	EndIf;

EndProcedure

// Возвращает ветвь дерева в ветви СтрокиДерева по значению Value.
// Если ветвь не найдена - создается новая.
&AtServer
Function НайтиИлиДобавитьВетвьДерева(СтрокиДерева, Value, Представление, Пометка)
	
	// Попытка найти существующую ветвь в СтрокиДерева без вложенных
	Ветвь = СтрокиДерева.Найти(Value, "Value", False);

	If Ветвь = Undefined Then
		// Такой ветки нет, создадим новую
		Ветвь = СтрокиДерева.Добавить();
		Ветвь.Value      = ValueByType(Value);
		Ветвь.Presentation = Представление;
		Ветвь.Mark       = Пометка;
	EndIf;

	Возврат Ветвь;

EndFunction

&AtServer
Function НайтиИлиДобавитьВетвьДереваСКартинкой(СтрокиДерева, Value, Представление, НомерКартинки)
	
	// Попытка найти существующую ветвь в СтрокиДерева без вложенных
	Ветвь = СтрокиДерева.Найти(Value, "Value", False);
	If Ветвь = Undefined Then
		// Такой ветки нет, создадим новую
		Ветвь = СтрокиДерева.Добавить();
		Ветвь.Value      = ValueByType(Value);
		Ветвь.Presentation = Представление;
		Ветвь.НомерКартинки = НомерКартинки;
	EndIf;

	Возврат Ветвь;

EndFunction
// Возвращает помеченные на удаление объекты. Возможен отбор по фильтру.//
&AtServer
Function ПолучитьПомеченныеНаУдаление()

	УстановитьПривилегированныйРежим(True);
	МассивПомеченные = НайтиПомеченныеНаУдаление();
	УстановитьПривилегированныйРежим(False);

	Результат = Новый Массив;
	For Each ЭлементПомеченный In МассивПомеченные Do
		If ПравоДоступа("ИнтерактивноеУдалениеПомеченных", ЭлементПомеченный.Метаданные()) Then
			Результат.Добавить(ЭлементПомеченный);
		EndIf;
	EndDo;

	Возврат Результат;

EndFunction
&AtServer
Procedure FullMarkedForDeletionTree()
	
	// Заполнение дерева помеченных на удаление
	ДеревоПомеченных = РеквизитФормыВЗначение("MarkedForDeletionItemsTree");

	ДеревоПомеченных.Строки.Очистить();
	
	// обработка помеченных
	МассивПомеченных = ПолучитьПомеченныеНаУдаление();

	For Each МассивПомеченныхЭлемент In МассивПомеченных Do
		ОбъектМетаданныхЗначение = МассивПомеченныхЭлемент.Метаданные().ПолноеИмя();
		ОбъектМетаданныхПредставление = МассивПомеченныхЭлемент.Метаданные().Представление();
		СтрокаОбъектаМетаданных = НайтиИлиДобавитьВетвьДерева(ДеревоПомеченных.Строки, ОбъектМетаданныхЗначение,
			ОбъектМетаданныхПредставление, True);
		НайтиИлиДобавитьВетвьДерева(СтрокаОбъектаМетаданных.Строки, МассивПомеченныхЭлемент, Строка(
			МассивПомеченныхЭлемент), True);
	EndDo;

	ДеревоПомеченных.Строки.Сортировать("Value", True);

	For Each СтрокаОбъектаМетаданных In ДеревоПомеченных.Строки Do
		// создать Presentation для строк, отображающих ветвь объекта метаданных
		СтрокаОбъектаМетаданных.Presentation = СтрокаОбъектаМетаданных.Presentation + " ("
			+ СтрокаОбъектаМетаданных.Строки.Количество() + ")";
	EndDo;

	NomberOfLevelsMarkedForDeletion = ДеревоПомеченных.Строки.Количество();

	ЗначениеВРеквизитФормы(ДеревоПомеченных, "MarkedForDeletionItemsTree");

EndProcedure

&AtClient
Procedure SetMarkInList(Данные, Пометка, ПроверятьРодителя)
	
	// Устанавливаем подчиненным
	ЭлементыСтроки = Данные.ПолучитьЭлементы();

	For Each Элемент In ЭлементыСтроки Do
		Элемент.Mark = Пометка;
		SetMarkInList(Элемент, Пометка, False);
	EndDo;
	
	// Проверяем родителя
	Родитель = Данные.ПолучитьРодителя();

	If ПроверятьРодителя And Родитель <> Undefined Then
		CheckParent(Родитель);
	EndIf;

EndProcedure

&AtClient
Procedure CheckParent(Родитель)

	ПометкаРодителя = True;
	ЭлементыСтроки = Родитель.ПолучитьЭлементы();
	For Each Элемент In ЭлементыСтроки Do
		If Не Элемент.Mark Then
			ПометкаРодителя = False;
			Прервать;
		EndIf;
	EndDo;
	Родитель.Mark = ПометкаРодителя;

EndProcedure

&AtServer
Function ПолучитьМассивПомеченныхОбъектовНаУдаление(MarkedForDeletionItemsTree, DeletionMode)

	Удаляемые = Новый Массив;

	If DeletionMode = "Full" Then
		// При полном удалении получаем весь список помеченных на удаление
		Удаляемые = ПолучитьПомеченныеНаУдаление();
	Else
		// Заполняем массив ссылками на выбранные элементы, помеченные на удаление
		КоллекцияСтрокМетаданных = MarkedForDeletionItemsTree.ПолучитьЭлементы();
		For Each СтрокаОбъектаМетаданных In КоллекцияСтрокМетаданных Do
			КоллекцияСтрокСсылок = СтрокаОбъектаМетаданных.ПолучитьЭлементы();
			For Each СтрокаСсылки In КоллекцияСтрокСсылок Do
				If СтрокаСсылки.Mark Then
					Удаляемые.Добавить(СтрокаСсылки.Value);
				EndIf;
			EndDo;
		EndDo;
	EndIf;

	Возврат Удаляемые;

EndFunction
&AtServer
Procedure УдалитьОбъектыНМ(УдаляемыеОбъекты, РежимНМ, ПрепятствуюшиеУдалению)
	If РежимНМ = True Then
		ВсеСсылки = НайтиПоСсылкам(УдаляемыеОбъекты); //ПрепятствуюшиеУдалению
		ПрепятствуюшиеУдалению.Колонки.Добавить("УдаляемыйСсылка");
		ПрепятствуюшиеУдалению.Колонки.Добавить("ОбнаруженныйСсылка");
		ПрепятствуюшиеУдалению.Колонки.Добавить("ОбнаруженныйМетаданные");

		For Each ССылка In ВсеСсылки Do
			УдаляемыйСсылка =ССылка[0];
			ССылкаНаобъект = ССылка[1];
			ОбъектМетаданных=ССылка[2];
			If УдаляемыйСсылка = ССылкаНаобъект Then
				Продолжить;   // ссылается сам на себя
			Else
				Мешает=ПрепятствуюшиеУдалению.Добавить();
				Мешает.УдаляемыйСсылка=УдаляемыйСсылка;
				Мешает.ОбнаруженныйСсылка=ССылкаНаобъект;
				Мешает.ОбнаруженныйМетаданные=ОбъектМетаданных;
			EndIf;
		EndDo;
	Else
		УдалитьОбъекты(УдаляемыеОбъекты, РежимНМ);//безусловное удаление
	EndIf;
EndProcedure
&AtServer
Function ВыполнитьУдалениеДок(Знач Удаляемые, ТипыУдаленныхОбъектовМассив)
	РезультатУдаления = Новый Структура("Статус, Value", False, "");

	If Не UT_Users.ЭтоПолноправныйПользователь() Then
		ВызватьИсключение НСтр("ru = 'Недостаточно прав для выполнения операции.'");
	EndIf;

	DeletionObjectsTypes = Новый ТаблицаЗначений;
	DeletionObjectsTypes.Колонки.Добавить("Тип", Новый ОписаниеТипов("Тип"));
	For Each УдаляемыйОбъект In Удаляемые Do
		НовыйТип = DeletionObjectsTypes.Добавить();
		НовыйТип.Тип = ТипЗнч(УдаляемыйОбъект);
	EndDo;
	DeletionObjectsTypes.Свернуть("Тип");

	НеУдаленные = Новый Массив;

	Найденные = Новый ТаблицаЗначений;
	Найденные.Колонки.Добавить("УдаляемыйСсылка");
	Найденные.Колонки.Добавить("ОбнаруженныйСсылка");
	Найденные.Колонки.Добавить("ОбнаруженныйМетаданные");

	УдаляемыеОбъекты = Новый Массив;
	For Each СсылкаНаОбъект In Удаляемые Do
		УдаляемыеОбъекты.Добавить(СсылкаНаОбъект);
	EndDo;

	МетаданныеРегистрыСведений = Метаданные.РегистрыСведений;
	МетаданныеРегистрыНакопления = Метаданные.РегистрыНакопления;
	МетаданныеРегистрыБухгалтерии = Метаданные.РегистрыБухгалтерии;

	ИсключенияПоискаСсылок = UT_Common.RefSearchExclusions();

	ИсключающиеПравилаОбъектаМетаданных = Новый Соответствие;

	Пока УдаляемыеОбъекты.Количество() > 0 Do
		ПрепятствуюшиеУдалению = Новый ТаблицаЗначений;
		
		// Попытка удалить с контролем ссылочной целостности.
		Попытка
			УстановитьПривилегированныйРежим(True);
			УдалитьОбъектыНМ(УдаляемыеОбъекты, True, ПрепятствуюшиеУдалению);
			УстановитьПривилегированныйРежим(False);
		Исключение
//			УстановитьМонопольныйРежим(False);
			РезультатУдаления.Value = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			Возврат РезультатУдаления;
		КонецПопытки;

		КоличествоУдаляемыхОбъектов = УдаляемыеОбъекты.Количество();
		
		// Назначение имен колонок для таблицы конфликтов, возникших при удалении.
		ПрепятствуюшиеУдалению.Колонки[0].Имя = "УдаляемыйСсылка";
		ПрепятствуюшиеУдалению.Колонки[1].Имя = "ОбнаруженныйСсылка";
		ПрепятствуюшиеУдалению.Колонки[2].Имя = "ОбнаруженныйМетаданные";
		
		// Перемещение удаляемых объектов в список не удаленных
		// и добавление в список найденных зависимых объектов
		// с учетом исключения поиска ссылок.
		For Each СтрокаТаблицы In ПрепятствуюшиеУдалению Do
			ИсключениеПоиска = ИсключенияПоискаСсылок[СтрокаТаблицы.ОбнаруженныйМетаданные];

			If ИсключениеПоиска = "*" Then
				Продолжить; // Можно удалять (обнаруженный объект метаданных не мешает).
			EndIf;
			
			// Определение исключащего правила для объекта метаданных, препятствующего удалению:
			// Для регистров (т.н. "необъектных таблиц") - массива реквизитов для поиска в записи регистра.
			// Для ссылочных типов (т.н. "объектных таблиц") - готового запроса для поиска в реквизитах.
			ИменаРеквизитовИлиЗапрос = ИсключающиеПравилаОбъектаМетаданных[СтрокаТаблицы.ОбнаруженныйМетаданные];
			If ИменаРеквизитовИлиЗапрос = Undefined Then
				
				// Формирование исключащего правила.
				ЭтоРегистрСведений = МетаданныеРегистрыСведений.Содержит(СтрокаТаблицы.ОбнаруженныйМетаданные);
				If ЭтоРегистрСведений Или МетаданныеРегистрыБухгалтерии.Содержит(СтрокаТаблицы.ОбнаруженныйМетаданные) // IsAccountingRegister

					Или МетаданныеРегистрыНакопления.Содержит(СтрокаТаблицы.ОбнаруженныйМетаданные) Then // IsAccumulationRegister

					ИменаРеквизитовИлиЗапрос = Новый Массив;
					If ЭтоРегистрСведений Then
						For Each Измерение In СтрокаТаблицы.ОбнаруженныйМетаданные.Измерения Do
							If Измерение.Ведущее Then
								ИменаРеквизитовИлиЗапрос.Добавить(Измерение.Имя);
							EndIf;
						EndDo;
					Else
						For Each Измерение In СтрокаТаблицы.ОбнаруженныйМетаданные.Измерения Do
							ИменаРеквизитовИлиЗапрос.Добавить(Измерение.Имя);
						EndDo;
					EndIf;

					If ТипЗнч(ИсключениеПоиска) = Тип("Массив") Then
						For Each ИмяРеквизита In ИсключениеПоиска Do
							If ИменаРеквизитовИлиЗапрос.Найти(ИмяРеквизита) = Undefined Then
								ИменаРеквизитовИлиЗапрос.Добавить(ИмяРеквизита);
							EndIf;
						EndDo;
					EndIf;

				ElsIf ТипЗнч(ИсключениеПоиска) = Тип("Массив") Then

					ТекстыЗапросов = Новый Соответствие;
					ИмяКорневойТаблицы = СтрокаТаблицы.ОбнаруженныйМетаданные.ПолноеИмя();

					For Each ПутьКРеквизиту In ИсключениеПоиска Do
						ПозицияТочки = Найти(ПутьКРеквизиту, ".");
						If ПозицияТочки = 0 Then
							ПолноеИмяТаблицы = ИмяКорневойТаблицы;
							ИмяРеквизита = ПутьКРеквизиту;
						Else
							ПолноеИмяТаблицы = ИмяКорневойТаблицы + "." + Лев(ПутьКРеквизиту, ПозицияТочки - 1);
							ИмяРеквизита = Сред(ПутьКРеквизиту, ПозицияТочки + 1);
						EndIf;

						ТекстВложенногоЗапроса = ТекстыЗапросов.Получить(ПолноеИмяТаблицы);
						If ТекстВложенногоЗапроса = Undefined Then
							ТекстВложенногоЗапроса = "ВЫБРАТЬ ПЕРВЫЕ 1
													 |	1
													 |ИЗ
													 |	" + ПолноеИмяТаблицы + " КАК Таблица
																				 |ГДЕ
																				 |	Таблица.Ссылка = &ОбнаруженныйСсылка
																				 |	And (";
						Else
							ТекстВложенногоЗапроса = ТекстВложенногоЗапроса + Символы.ПС + Символы.Таб + Символы.Таб
								+ "ИЛИ ";
						EndIf;
						ТекстВложенногоЗапроса = ТекстВложенногоЗапроса + "Таблица." + ИмяРеквизита
							+ " = &УдаляемыйСсылка";

						ТекстыЗапросов.Вставить(ПолноеИмяТаблицы, ТекстВложенногоЗапроса);
					EndDo;

					ТекстЗапроса = "";
					For Each КлючИЗначение In ТекстыЗапросов Do
						If ТекстЗапроса <> "" Then
							ТекстЗапроса = ТекстЗапроса + Символы.ПС + Символы.ПС + "ОБЪЕДИНИТЬ ВСЕ" + Символы.ПС
								+ Символы.ПС;
						EndIf;
						ТекстЗапроса = ТекстЗапроса + КлючИЗначение.Value + ")";
					EndDo;

					ИменаРеквизитовИлиЗапрос = Новый Запрос;
					ИменаРеквизитовИлиЗапрос.Текст = ТекстЗапроса;

				Else

					ИменаРеквизитовИлиЗапрос = "";

				EndIf;

				ИсключающиеПравилаОбъектаМетаданных.Вставить(СтрокаТаблицы.ОбнаруженныйМетаданные,
					ИменаРеквизитовИлиЗапрос);

			EndIf;
			
			// Проверка исключащего правила.
			If ТипЗнч(ИменаРеквизитовИлиЗапрос) = Тип("Массив") Then
				УдаляемаяСсылкаВИсключаемомРеквизите = False;

				For Each ИмяРеквизита In ИменаРеквизитовИлиЗапрос Do
					If СтрокаТаблицы.ОбнаруженныйСсылка[ИмяРеквизита] = СтрокаТаблицы.УдаляемыйСсылка Then
						УдаляемаяСсылкаВИсключаемомРеквизите = True;
						Прервать;
					EndIf;
				EndDo;

				If УдаляемаяСсылкаВИсключаемомРеквизите Then
					Продолжить; // Можно удалять (обнаруженная запись регистра не мешает).
				EndIf;
			ElsIf ТипЗнч(ИменаРеквизитовИлиЗапрос) = Тип("Запрос") Then
				ИменаРеквизитовИлиЗапрос.УстановитьПараметр("УдаляемыйСсылка", СтрокаТаблицы.УдаляемыйСсылка);
				ИменаРеквизитовИлиЗапрос.УстановитьПараметр("ОбнаруженныйСсылка", СтрокаТаблицы.ОбнаруженныйСсылка);
				If Не ИменаРеквизитовИлиЗапрос.Выполнить().Пустой() Then
					Продолжить; // Можно удалять (обнаруженная ссылка не мешает).
				EndIf;
			EndIf;
			
			// Все исключающие правила пройдены.
			// Невозможно удалить объект (мешает обнаруженная ссылка или запись регистра).
			// Сокращение удаляемых объектов.
			Индекс = УдаляемыеОбъекты.Найти(СтрокаТаблицы.УдаляемыйСсылка);
			If Индекс <> Undefined Then
				УдаляемыеОбъекты.Удалить(Индекс);
			EndIf;
			
			// Добавление не удаленных объектов.
			If НеУдаленные.Найти(СтрокаТаблицы.УдаляемыйСсылка) = Undefined Then
				НеУдаленные.Добавить(СтрокаТаблицы.УдаляемыйСсылка);
			EndIf;
			
			// Добавление найденных зависимых объектов.
			НоваяСтрока = Найденные.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТаблицы);

		EndDo;
		
		// Удаление без контроля, If состав удаляемых объектов не был изменён на этом шаге Doа.
		If КоличествоУдаляемыхОбъектов = УдаляемыеОбъекты.Количество() Then
			Попытка
				// Удаление без контроля ссылочной целостности.
				УстановитьПривилегированныйРежим(True);
				УдалитьОбъекты(УдаляемыеОбъекты, False);
				УстановитьПривилегированныйРежим(False);
			Исключение
				УстановитьМонопольныйРежим(False);
				;
				РезультатУдаления.Value = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
				Возврат РезультатУдаления;
			КонецПопытки;
			
			// Удаление всего, что возможно, завершено - выход из цикла.
			Прервать;
		EndIf;
	EndDo;

	For Each НеУдаленныйОбъект In НеУдаленные Do
		НайденныеСтроки = DeletionObjectsTypes.НайтиСтроки(Новый Структура("Тип", ТипЗнч(НеУдаленныйОбъект)));
		If НайденныеСтроки.Количество() > 0 Then
			DeletionObjectsTypes.Удалить(НайденныеСтроки[0]);
		EndIf;
	EndDo;

	ТипыУдаленныхОбъектовМассив = DeletionObjectsTypes.ВыгрузитьКолонку("Тип");

	УстановитьМонопольныйРежим(False);

	Найденные.Колонки.УдаляемыйСсылка.Имя        = "Ссылка";
	Найденные.Колонки.ОбнаруженныйСсылка.Имя     = "Данные";
	Найденные.Колонки.ОбнаруженныйМетаданные.Имя = "Метаданные";

	РезультатУдаления.Статус = True;
	РезультатУдаления.Value = Новый Структура("Найденные, НеУдаленные", Найденные, НеУдаленные);

	Возврат РезультатУдаления;
EndFunction
&AtServer
Procedure УдалитьПомеченныеОбъекты(ПараметрыУдаления, StorageAddress) 
	
	// Извлекаем параметры
	СписокПомеченныхНаУдал	= ПараметрыУдаления.MarkedForDeletionItemsTree;
	DeletionMode				= ПараметрыУдаления.DeletionMode;
	DeletionObjectsTypes		= ПараметрыУдаления.DeletionObjectsTypes;

	Удаляемые = ПолучитьМассивПомеченныхОбъектовНаУдаление(СписокПомеченныхНаУдал, DeletionMode);
	NomberDeleted = Удаляемые.Количество();
	
	// Выполняем удаление
	Result = ВыполнитьУдалениеДок(Удаляемые, DeletionObjectsTypes);
	
	// Добавляем параметры 
	If ТипЗнч(Result.Value) = Тип("Структура") Then
		NomberNotDeletedObjects = Result.Value.НеУдаленные.Количество();
	Else
		NomberNotDeletedObjects = 0;
	EndIf;
	Result.Вставить("NomberNotDeletedObjects", NomberNotDeletedObjects);
	Result.Вставить("NomberDeleted", NomberDeleted);
	Result.Вставить("DeletionObjectsTypes", DeletionObjectsTypes);

	ПоместитьВоВременноеХранилище(Result, StorageAddress);

EndProcedure
// Производит попытку удаления выбранных объектов.
// Объекты, которые не были удалены показываются в отдельной таблице.
&AtServer
Function DeletionMarkedAtServer(DeletionObjectsTypes)

	ПараметрыУдаления = Новый Структура("MarkedForDeletionItemsTree, DeletionMode, DeletionObjectsTypes, ",
		MarkedForDeletionItemsTree, DeletionMode, DeletionObjectsTypes);

	StorageAddress = ПоместитьВоВременноеХранилище(Undefined, УникальныйИдентификатор);
	УдалитьПомеченныеОбъекты(ПараметрыУдаления, StorageAddress);
	Result = Новый Структура("JobCompleted", True);

	If Result.JobCompleted Then
		Result = ЗаполнитьРезультаты(StorageAddress, Result);
	EndIf;

	Возврат Result;

EndFunction

&AtServer
Function ЗаполнитьРезультаты(StorageAddress, Result)

	DeletionResult = ПолучитьИзВременногоХранилища(StorageAddress);
	If Не DeletionResult.Статус Then
		Result.Вставить("DeletionResult", DeletionResult);
		Result.Вставить("ErrorMessage", DeletionResult.Value);
		Возврат Result;
	EndIf;

	Дерево = ЗаполнитьДеревоОставшихсяОбъектов(DeletionResult);
	ЗначениеВРеквизитФормы(Дерево, "NotDeletedItems");

	NomberDeleted 			= DeletionResult.NomberDeleted;
	NomberNotDeletedObjects 	= DeletionResult.NomberNotDeletedObjects;
	ЗаполнитьСтрокуРезультатов(NomberDeleted);

	If ТипЗнч(DeletionResult.Value) = Тип("Структура") Then
		DeletionResult.Удалить("Value");
	EndIf;

	Result.Вставить("DeletionResult", DeletionResult);
	Result.Вставить("ErrorMessage", "");
	Возврат Result;

EndFunction

//@skip-warning
&AtClient
Procedure Attachable_CheckTaskCompletion()

	Попытка
		If Items.FormPages.ТекущаяСтраница = Items.TimeConsumingOperationPage Then
			If ЗаданиеВыполнено(ScheduledJobID) Then
				Result = ЗаполнитьРезультаты(StorageAddress, Новый Структура);
				//@skip-warning
				DeletionObjectsTypes = Undefined;
				UpdateContent(Result.РезультатУдаления, Result.РезультатУдаления.Value,
					Result.РезультатУдаления.DeletionObjectsTypes);
			Else
				UT_TimeConsumingOperationsClient.ОбновитьIdleHandlerParametrs(IdleHandlerParameters);
				ПодключитьОбработчикОжидания(
					"Attachable_CheckTaskCompletion", IdleHandlerParameters.ТекущийИнтервал, True);
			EndIf;
		EndIf;
	Исключение
		ВызватьИсключение;
	КонецПопытки;

EndProcedure

&AtServerNoContext
Function ЗаданиеВыполнено(ScheduledJobID)

	Возврат UT_TimeConsumingOperations.ЗаданиеВыполнено(ScheduledJobID);

EndFunction

&AtServer
Function ЗаполнитьДеревоОставшихсяОбъектов(Result)

	Найденные   = Result.Value.Найденные;
	НеУдаленные = Result.Value.НеУдаленные;

	NomberNotDeletedObjects = НеУдаленные.Количество();
	
	// Создадим таблицу оставшихся (не удаленных) объектов
	NotDeletedItemsTree.ПолучитьЭлементы().Очистить();

	Дерево = РеквизитФормыВЗначение("NotDeletedItems");

	For Each Найденный In Найденные Do
		НеУдаленный = Найденный[0];
		Ссылающийся = Найденный[1];
		ОбъектМетаданныхСсылающегося = Найденный[2].Представление();
		ОбъектМетаданныхНеУдаленногоЗначение = НеУдаленный.Метаданные().ПолноеИмя();
		ОбъектМетаданныхНеУдаленногоПредставление = НеУдаленный.Метаданные().Представление();
		//ветвь метаданного
		СтрокаОбъектаМетаданных = НайтиИлиДобавитьВетвьДереваСКартинкой(Дерево.Строки,
			ОбъектМетаданныхНеУдаленногоЗначение, ОбъектМетаданныхНеУдаленногоПредставление, 0);
		//ветвь не удаленного объекта
		СтрокаСсылкиНаНеУдаленныйОбъектБД = НайтиИлиДобавитьВетвьДереваСКартинкой(СтрокаОбъектаМетаданных.Строки,
			НеУдаленный, Строка(НеУдаленный), 2);
		//ветвь ссылки на не удаленный объект
		НайтиИлиДобавитьВетвьДереваСКартинкой(СтрокаСсылкиНаНеУдаленныйОбъектБД.Строки, Ссылающийся, Строка(
			Ссылающийся) + " - " + ОбъектМетаданныхСсылающегося, 1);
	EndDo;

	Дерево.Строки.Сортировать("Value", True);

	Возврат Дерево;

EndFunction

&AtServer
Procedure ЗаполнитьСтрокуРезультатов(NomberDeleted)


	DeletedObjects = NomberDeleted - NomberNotDeletedObjects;

	If DeletedObjects = 0 Then
		ResultLine = НСтр(
			"ru = 'Не удален ни один из объектов, так как в информационной базе существуют ссылки на удаляемые объекты'");
	Else
		ResultLine = СтрШаблон(
				НСтр("ru = 'Удаление помеченных объектов завершено.
					 |Удалено объектов: %1.'"), Строка(DeletedObjects));
	EndIf;

	If NomberNotDeletedObjects > 0 Then
		ResultLine = ResultLine + Символы.ПС + СтрШаблон(
				НСтр("ru = 'Не удалено объектов: %1.
					 |Объекты не удалены для сохранения целостности информационной базы, т.к. на них еще имеются ссылки.
					 |Нажмите ОК для просмотра списка оставшихся (не удаленных) объектов.'"), Строка(
			NomberNotDeletedObjects));
	EndIf;

EndProcedure
