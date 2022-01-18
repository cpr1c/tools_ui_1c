
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

		List = New ValueList();
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
		If NumberDeletedObjects = 0 Then
			Text = Nstr("ru = 'Не помечено на удаление ни одного объекта. Удаление объектов не выполнялось.'");
			UpdateMarkedTree = False;
		Else
			Text = StrTemplate(
			             Nstr("en = 'Deletion of marked objects has been completed successfully.' 
			               |Deleted objects: %1.'; 
			               |ru = 'Удаление помеченных объектов успешно завершено.
							  |Удалено объектов: %1.'"), NumberDeletedObjects);
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
	
	//Tring to find an exist branch in TreeRows whithout internal
	Branch = TreeRows.Find(Value, "Value", False);
	If Branch = Undefined Then
		// There is no such branch, we will create a new one
		Branch = TreeRows.Add();
		Branch.Value      = ValueByType(Value);
		Branch.Presentation = Presentation;
		Branch.НомерКартинки = PictureNumber;
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
			Break;
		EndIf;
	EndDo;
	Родитель.Mark = ПометкаРодителя;

EndProcedure

&AtServer
Function ПолучитьМассивПомеченныхОбъектовНаУдаление(MarkedForDeletionItemsTree, DeletionMode)

	Deleted = New Array;

	If DeletionMode = "Full" Then
		// При полном удалении получаем весь список помеченных на удаление
		Удаляемые = ПолучитьПомеченныеНаУдаление();
	Else
		// We fill the array with references to the selected items marked for deletion
		MetadataRowCollection = MarkedForDeletionItems.GetItems();
		For Each MetadataObjectRow In MetadataRowCollection Do
			ReferenceRowCollection = MetadataObjectRow.GetItems();
			For Each ReferenceRow In ReferenceRowCollection Do
				If ReferenceRow.Mark Then
					Deleted.Add(ReferenceRow.Value);
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
Procedure DeleteListedObjects(ListedObjects, Check, PreventingDeletion)
	If Check = True Then
		AllReferences= FindByRef(ListedObjects); //PreventingDeletion
		PreventingDeletion.Columns.Add("DeletionRef");
		PreventingDeletion.Columns.Add("DetectedRef");
		PreventingDeletion.Columns.Add("DetectedMetadata");

		For Each Ref In AllReferences Do
			DeletionRef =Ref[0];
			ObjectRef = Ref[1];
			MetadataObject=Ref[2];
			If DeletionRef = ObjectRef Then
				Continue;   // ссылается сам на себя
			Else
				Preventing=PreventingDeletion.Add();
				Preventing.DeletionRef=DeletionRef;
				Preventing.DetectedRef=ObjectRef;
				Preventing.DetectedMetadata=MetadataObject;
			EndIf;
		EndDo;
	Else
		DeleteObjects(ListedObjects, Check);//unconditional deletion
	EndIf;
EndProcedure
&AtServer
Function RunDocumentsDeletion(Знач DeletedArray, DeletedObjectsTypes)
	DeletionResult = New Structure("Status, Value", False, "");

	If Не UT_Users.IsFullUser() Then
		Raise NStr("en = 'Not enough permissions to perform the operation' ; ru = 'Недостаточно прав для выполнения операции.'");
	EndIf;

	DeletionObjectsTypes = New ValueTable;
	DeletionObjectsTypes.Colums.Add("Type", New TypeDescription("Type"));
	For Each DeletedObject In DeletedArray Do
		NewType = DeletionObjectsTypes.Add();
		NewType.Type = TypeOf(DeletedObject);
	EndDo;
	DeletionObjectsTypes.Groupby("Type");

	NotDeletedObjectsArray = New Array;

	Found = New ValueTable;
	Found.Colums.Add("DeletionRef");
	Found.Colums.Add("DetectedRef");
	Found.Colums.Add("DetectedMetadata");

	DeletedObjectsArray = New Array;
	For Each ObjectRef In DeletedArray Do
		DeletedObjectsArray.Add(ObjectRef);
	EndDo;

	MetadataInformationRegisters = Metadata.InformationRegisters;
	MetadataAccumulationRegisters = Metadata.AccumulationRegisters;
	MetadataAccountingRegisters = Metadata.AccountingRegisters;

	RefSearchExclusions = UT_Common.RefSearchExclusions();

	ExcludingMetadataObjectRules = New Map;

	While DeletedObjectsArray.Count() > 0 Do
		PreventingDeletion = New ValueTable;
		
		// Attempt to delete with reference integrity control.
		Try

			SetPrivilegedMode(True);
			DeleteListedObjects(DeletedObjectsArray, True, PreventingDeletion);
			SetPrivilegedMode(False);
		Except
//			SetPrivilegedMode(False);
			DeletionResult.Value = DetailErrorDescription(ИнформацияОбОшибке());
			Return DeletionResult;
		EndTry;

		NomberDeletedObjects = DeletedObjectsArray.Count();
		
		// Column names are set for the conflict tables that occurred during deletion.
		PreventingDeletion.Columns[0].Name = "DeletionRef";
		PreventingDeletion.Columns[1].Name = "DetectedRef";
		PreventingDeletion.Columns[2].Name = "DetectedMetadata";
		
		// We move deleted objects to the list  undeleted one 
		// and add found objects to the list by taking into account references
		// that were excluded
		For Each TableRow In PreventingDeletion Do
			ExcludedRefs = RefSearchExclusions[TableRow.DetectedMetadata];

			If ExcludedRefs = "*" Then
				Continue; // Can delete (a found metadata object does not interfere).
			EndIf;
			
			//	Looks for an excluding rule for a metadata object that interfere deletion
			//	For registers (so-called "non-object tables") - an array of attributes for search in a register record.
			// For reference types (so-called "object tables") - a ready-made query for search in attributes.  
			NameOfAttributesOrQuery = ExcludingMetadataObjectRules[TableRow.DetectedMetadata];
			If NameOfAttributesOrQuery = Undefined Then
				
				// We make an excluding rule
				ThisInformationRegister = MetadataInformationRegisters.Contains(TableRow.DetectedMetadata);
				If ThisInformationRegister Or MetadataAccountingRegisters.Contains(TableRow.DetectedMetadata) // IsAccountingRegister

					Or MetadataAccumulationRegisters.Contains(TableRow.DetectedMetadata) Then // IsAccumulationRegister

					NameOfAttributesOrQuery = New Array;
					If ThisInformationRegister Then
						For Each Dimension In TableRow.DetectedMetadata.Dimensions Do
							If Dimension.Master Then
								NameOfAttributesOrQuery.Add(Dimension.Name);
							EndIf;
						EndDo;
					Else
						For Each Dimension In TableRow.DetectedMetadata.Dimensions Do
							NameOfAttributesOrQuery.Add(Dimension.Name);
						EndDo;
					EndIf;

					If TypeOf(ExcludedRefs) = Type("Array") Then
						For Each AttributeName In ExcludedRefs Do
							If NameOfAttributesOrQuery.Find(AttributeName) = Undefined Then
								NameOfAttributesOrQuery.Add(AttributeName);
							EndIf;
						EndDo;
					EndIf;

				ElsIf TypeOf(ExcludedRefs) = Type("Array") Then

					QueryTexts = New Map;
					NameOfRootTable = TableRow.DetectedMetadata.FullName();

					For Each AttributeWay In ExcludedRefs Do
						PointPosition = Find(AttributeWay, ".");
						If PointPosition = 0 Then
							TableFullName = NameOfRootTable;
							AttributeName = AttributeWay;
						Else
							TableFullName = NameOfRootTable + "." + Left(AttributeWay, PointPosition - 1);
							AttributeName = Mid(AttributeWay, PointPosition + 1);
						EndIf;

						IncludedQueryText = QueryTexts.Получить(TableFullName);
						If IncludedQueryText = Undefined Then
							IncludedQueryText = "SELECT TOP 1
													 |	1
													 |FROM
													 |	" + TableFullName + " AS TABLE
																				 |WHERE
																				 |	Table.Ref = &DetectedRef
																				 |	And (";
						Else
							IncludedQueryText = IncludedQueryText + Chars.LF + Chars.Tab + Chars.Tab
								+ "OR ";
						EndIf;
						IncludedQueryText = IncludedQueryText + "Table." + AttributeName
							+ " = &DetectedRef";

						QueryTexts.Insert(TableFullName, IncludedQueryText);
					EndDo;

					QueryText = "";
					For Each KeyAndValue In QueryTexts Do
						If QueryText <> "" Then
							QueryText = QueryText + Chars.LF + Chars.LF + "UNION ALL" + Chars.LF
								+ Chars.LF;
						EndIf;
						QueryText = QueryText + KeyAndValue.Value + ")";
					EndDo;

					NameOfAttributesOrQuery = New Запрос;
					NameOfAttributesOrQuery.Text = QueryText;

				Else

					NameOfAttributesOrQuery = "";

				EndIf;

				ExcludingMetadataObjectRules.Insert(TableRow.DetectedMetadata,
					NameOfAttributesOrQuery);

			EndIf;
			
			// Checks an excluding rule.
			If TypeOf(NameOfAttributesOrQuery) = Type("Array") Then
				DeletedRefInExcludedAttribute = False;

				For Each AttributeName In NameOfAttributesOrQuery Do
					If TableRow.DetectedRef[AttributeName] = TableRow.DeletionRef Then
						DeletedRefInExcludedAttribute = True;
						Break;
					EndIf;
				EndDo;

				If DeletedRefInExcludedAttribute Then
					Continue; // Can delete (a found record does not interfere).
				EndIf;
			ElsIf TypeOf(NameOfAttributesOrQuery) = Type("Query") Then
				NameOfAttributesOrQuery.SetParameter("DeletionRef", TableRow.DeletionRef);
				NameOfAttributesOrQuery.SetParameter("DetectedRef", TableRow.DetectedRef);
				If Not NameOfAttributesOrQuery.Execute().IsEmpty() Then
					Continue; // Can delete (a found reference does not interfere).
				EndIf;
			EndIf;
			
			// All excluded rules were passed
			// Can not delete the object (The found reference or the register record interferes).
			// Removes deleted objects
			Index = DeletedObjectsArray.Find(TableRow.DeletionRef);
			If Index <> Undefined Then
				DeletedObjectsArray.Delete(Index);
			EndIf;
			
			// Adding undeleted objects.
			If NotDeletedObjectsArray.Find(TableRow.DeletionRef) = Undefined Then
				NotDeletedObjectsArray.Add(TableRow.DeletionRef);
			EndIf;
			
			// Adding found dependent objects
			NewRow = Found.Add();
			FillPropertyValues(NewRow, TableRow);

		EndDo;
		
		// Deletes without control, if the composition of the deleted objects has not been changed at this step of the cycle.
		If NomberDeletedObjects = DeletedObjectsArray.Count() Then
			Try
				//Delete objects without reference control
				SetPrivilegedMode(True);
				DeleteObjects(DeletedObjectsArray, False);
				SetPrivilegedMode(False);
			Except
				SetExclusiveMode(False);
				DeletionResult.Value = DetailErrorDescription(ErrorInfo());
				Возврат DeletionResult;
			Endtry;

			// Deleting everything that is possible was completed - exit the loop.
			Break;
		EndIf;
	EndDo;

	For Each NotDeletedObject In NotDeletedObjectsArray Do
		FoundRows = DeletionObjectsTypes.FindRows(New Structure("Type", TypeOf(NotDeletedObject)));
		If FoundRows.Count() > 0 Then
			DeletionObjectsTypes.Delete(FoundRows[0]);
		EndIf;
	EndDo;

	DeletedObjectsTypes = DeletionObjectsTypes.UnloadColumn("Type");

	SetExclusiveMode(False);

	Found.Columns.DeletionRef.Name        = "Ref";
	Found.Columns.DetectedRef.Name     = "Data";
	Found.Columns.DetectedMetadata.Name = "Metadata";

	DeletionResult.Status = True;
	DeletionResult.Value = New Structure("Found, NotDeleted", Found, NotDeletedObjectsArray);

	Возврат DeletionResult;
EndFunction
&AtServer
Procedure DeleteMarkedObjects(ПараметрыУдаления, StorageAddress) 
	
	// Extracting the parameters
	MarkedForDeletionList	= ПараметрыУдаления.MarkedForDeletionItems;
	DeletionMode				= ПараметрыУдаления.DeletionMode;
	DeletionObjectsTypes		= ПараметрыУдаления.DeletionObjectsTypes;

	DeletedItems = GetArrayMarkedForDeletion(MarkedForDeletionList, DeletionMode);
	NomberDeleted = DeletedItems.Count();
	
	// Do Deletion
	Result = RunDocumentsDeletion(DeletedItems, DeletionObjectsTypes);
	
	// Add parameters 
	If TypeOf(Result.Value) = Type("Structure") Then
		NomberNotDeletedObjects = Result.Value.NotDeleted.Count();
	Else
		NomberNotDeletedObjects = 0;
	EndIf;
	Result.Insetrt("NomberNotDeletedObjects", NomberNotDeletedObjects);
	Result.Insetrt("NomberDeleted", NomberDeleted);
	Result.Insetrt("DeletionObjectsTypes", DeletionObjectsTypes);

	PutToTempStorage(Result, StorageAddress);

EndProcedure
// Attempts to delete the selected objects.
// Not deleted objects are shown in another table
&AtServer
Function DeletionMarkedAtServer(DeletionObjectsTypes)

	DeletionParameters = New Structure("MarkedForDeletionItemsTree, DeletionMode, DeletionObjectsTypes, ",
		MarkedForDeletionItemsTree, DeletionMode, DeletionObjectsTypes);

	StorageAddress = PutToTempStorage(Undefined, UUID);
	DeleteMarkedObjects(DeletionParameters, StorageAddress);
	Result = New Structure("JobCompleted", True);

	If Result.JobCompleted Then
		Result = FillResults(StorageAddress, Result);
	EndIf;

	Возврат Result;

EndFunction

&AtServer
Function FillResults(StorageAddress, Result)

	DeletionResult = GetFromTempStorage(StorageAddress);
	If Не DeletionResult.Status Then
		Result.Insert("DeletionResult", DeletionResult);
		Result.Insert("ErrorMessage", DeletionResult.Value);
		Return Result;
	EndIf;

	Tree = FillTreeOfRemainingObjects(DeletionResult);
	ValueToFormAttribute(Tree, "NotDeletedItemsTree");

	NomberDeleted 			= DeletionResult.NomberDeleted;
	NomberNotDeletedObjects 	= DeletionResult.NomberNotDeletedObjects;
	FillRusultsLine(NomberDeleted);

	If TypeOf(DeletionResult.Value) = Type("Structure") Then
		DeletionResult.Delete("Value");
	EndIf;

	Result.Insert("DeletionResult", DeletionResult);
	Result.Insert("ErrorMessage", "");
	Возврат Result;

EndFunction

//@skip-warning
&AtClient
Procedure Attachable_CheckTaskCompletion()

	Try
		If Items.FormPages.CurrentPage = Items.TimeConsumingOperationPage Then
			If JobCompleted(ScheduledJobID) Then
				Result = FillResults(StorageAddress, New Structure);
				//@skip-warning
				DeletionObjectsTypes = Undefined;
				UpdateContent(Result.DeletionResult, Result.DeletionResult.Value,
					Result.DeletionResult.DeletionObjectsTypes);
			Else
				UT_TimeConsumingOperationsClient.UpdateIdleHandlerParameters(IdleHandlerParameters);
				AttachIdleHandler(
					"Attachable_CheckTaskCompletion", IdleHandlerParameters.CurrentInterval, True);
			EndIf;
		EndIf;
	Except
		Raise;
	EndTry;

EndProcedure

&AtServerNoContext
Function JobCompleted(ScheduledJobID)

	Возврат UT_TimeConsumingOperations.JobCompleted(ScheduledJobID);

EndFunction

&AtServer
Function ЗаполнитьДеревоОставшихсяОбъектов(Result)

	Found   = Result.Value.Found;
	UnDeleted = Result.Value.UnDeleted;

	NomberNotDeletedObjects = UnDeleted.Количество();
	
	// Creates a table not deleted ojects
	NotDeletedItemsTree.GetItems().Clear();

	Tree = FormAttributeToValue("NotDeletedItemsTree");

	For Each FoundItem In Found Do
		NotDeleted = FoundItem[0];
		Referencing = FoundItem[1];
		ReferencingMetadataObject = FoundItem[2].Presentation();
		ValueOfNotDeledetMetadataObject  = NotDeleted.Метаданные().FullName();
		PresentationOfNotDeledetMetadataObject = NotDeleted.Метаданные().Presentation();
		//a metadata branch
		MetadataObjectRow = FindOrAddTreeBranchWithPicture(Tree.Rows,
			ValueOfNotDeledetMetadataObject, PresentationOfNotDeledetMetadataObject, 0);
		//a non-deleted object branch
		ReferenceRowToNonDeletedDBObject = FindOrAddTreeBranchWithPicture(MetadataObjectRow.Rows,
			NotDeleted, String(NotDeleted), 2);
		//a branch of a reference non-deleted object
		FindOrAddTreeBranchWithPicture(ReferenceRowToNonDeletedDBObject.Rows, Referencing, String(
			Referencing) + " - " + ReferencingMetadataObject, 1);
	EndDo;

	Tree.Rows.Sort("Value", True);

	Возврат Tree;

EndFunction

&AtServer
Procedure FillRusultsLine(NomberDeleted)


	NumberDeletedObjects = NomberDeleted - NomberNotDeletedObjects;

	If NumberDeletedObjects = 0 Then
		ResultLine = Nstr(
			"en = 'None of the objects has been deleted, since there are references to the  deleted objects in the information databas'; 
			|ru = 'Не удален ни один из объектов, так как в информационной базе существуют ссылки на удаляемые объекты'");
	Else
		ResultLine = StrTemplate(
				Nstr("en = '';
				|ru = 'Удаление помеченных объектов завершено. Удалено объектов: %1.'"),
				 String(NumberDeletedObjects));
	EndIf;

	If NomberNotDeletedObjects > 0 Then
		ResultLine = ResultLine + Chars.LF + StrTemplate(
				Nstr("en = 'No objects deleted: %1.
					|The objects have not been deleted to preserve the integrity of the information base, because there are still references to them.
					|Click OK to view the list of remaining (not deleted) objects'
					|;
					|ru = 'Не удалено объектов: %1.
					 |Объекты не удалены для сохранения целостности информационной базы, т.к. на них еще имеются ссылки.
					 |Нажмите ОК для просмотра списка оставшихся (не удаленных) объектов.'"), String(
			NomberNotDeletedObjects));
	EndIf;

EndProcedure
