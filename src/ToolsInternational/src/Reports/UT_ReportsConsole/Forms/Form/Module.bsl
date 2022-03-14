////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

// Инициализировать новое дерево отчетов.
&AtClientAtServerNoContext
Procedure ИнициализироватьДеревоОтчетов(ReportsTree)

	Items = ReportsTree.GetItems();
	Items.Clear();
	КорневойЭлемент = Items.Add();
	КорневойЭлемент.RowType = 4;
	КорневойЭлемент.Name = NStr("ru='Reports'");

	ЭлементыВКоторыеДобавляем = КорневойЭлемент.GetItems();

	Name = "Report";
	Item = ЭлементыВКоторыеДобавляем.Add();
	Item.Name = Name;
	Item.RowType = 0;

EndProcedure

// Переключить страницу группировок на страницу с текстом недоступности.
&AtClient
Procedure GroupFieldsNotAvailable()

	Items.PagesGroupFields.CurrentPage = Items.UnavailableGroupFieldsSettings;

EndProcedure

// Переключить страницу группировок на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure GroupFieldsNotAvailable1()

	Items.GroupFieldsPages1.CurrentPage = Items.UnavailableGroupFieldsSettings1;

EndProcedure

// Включить доступность выбранных полей.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure SelectedFieldsAvailable(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemSelection(ЭлементСтруктуры) Then

		LocalSelectedFields = True;
		Items.PagesSelectedFields.CurrentPage = Items.SelectedFieldsSettings;

	Else

		LocalSelectedFields = False;
		Items.PagesSelectedFields.CurrentPage = Items.SelectedFieldsDisabledSettings;

	EndIf;

	Items.LocalSelectedFields.ReadOnly = False;

EndProcedure

// Включить доступность выбранных полей для исполняемых настроек.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure SelectedFieldsAvailable1(ЭлементСтруктуры)

	If ExecutedSettingsComposer.Settings.HasItemSelection(ЭлементСтруктуры) Then

		LocalSelectedFields1 = True;
		Items.PagesSelectedFields1.CurrentPage = Items.SelectedFieldsSettings1;

	Else

		LocalSelectedFields1 = False;
		Items.PagesSelectedFields1.CurrentPage = Items.DisabledSelectedFieldsSettings1;

	EndIf;

	Items.LocalSelectedFields1.ReadOnly = False;

EndProcedure

// Переключить страницу выбранных полей на страницу с текстом недоступности.
&AtClient
Procedure SelectedFieldsUnavailable()

	LocalSelectedFields = False;
	Items.LocalSelectedFields.ReadOnly = True;
	Items.PagesSelectedFields.CurrentPage = Items.UnavailableSelectedFieldsSettings;

EndProcedure

// Переключить страницу выбранных полей на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure SelectedFieldsUnavailable1()

	LocalSelectedFields1 = False;
	Items.LocalSelectedFields1.ReadOnly = True;
	Items.PagesSelectedFields1.CurrentPage = Items.UnavailableSelectedFieldsSettings1;

EndProcedure

// Включить доступность отбора.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure FilterAvailable(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemFilter(ЭлементСтруктуры) Then

		LocalFilter = True;
		Items.FilterPages.CurrentPage = Items.FilterSettings;

	Else

		LocalFilter = False;
		Items.FilterPages.CurrentPage = Items.DisabledFilterSettings;

	EndIf;

	Items.LocalFilter.ReadOnly = False;

EndProcedure

// Включить доступность отбора для исполняемых настроек.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure FilterAvailable1(ЭлементСтруктуры)

	If ExecutedSettingsComposer.Settings.HasItemFilter(ЭлементСтруктуры) Then

		LocalFilter1 = True;
		Items.FilterPages1.CurrentPage = Items.FilterSettings1;

	Else

		LocalFilter1 = False;
		Items.FilterPages1.CurrentPage = Items.DisabledFilterSettings1;

	EndIf;

	Items.LocalFilter1.ReadOnly = False;

EndProcedure

// Переключить страницу отбора на страницу с текстом недоступности.
&AtClient
Procedure FilterUnavailable()

	LocalFilter = False;
	Items.LocalFilter.ReadOnly = True;
	Items.FilterPages.CurrentPage = Items.UnavailableFilterSettings;

EndProcedure

// Переключить страницу отбора на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure FilterUnavailable1()

	LocalFilter1 = False;
	Items.LocalFilter1.ReadOnly = True;
	Items.FilterPages1.CurrentPage = Items.UnavailableFilterSettings1;

EndProcedure

// Включить доступность порядка.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure OrderAvailable(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemOrder(ЭлементСтруктуры) Then

		LocalOrder = True;
		Items.OrderPages.CurrentPage = Items.OrderSettings;

	Else

		LocalOrder = False;
		Items.OrderPages.CurrentPage = Items.DisabledOrderSettings;

	EndIf;

	Items.LocalOrder.ReadOnly = False;

EndProcedure

// Включить доступность порядка для исполняемых настроек.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure OrderAvailable1(ЭлементСтруктуры)

	If ExecutedSettingsComposer.Settings.HasItemOrder(ЭлементСтруктуры) Then

		LocalOrder1 = True;
		Items.OrderPages1.CurrentPage = Items.OrderSettings1;

	Else

		LocalOrder1 = False;
		Items.OrderPages1.CurrentPage = Items.DisabledOrderSettings1;

	EndIf;

	Items.LocalOrder1.ReadOnly = False;

EndProcedure

// Переключить страницу порядка на страницу с текстом недоступности.
&AtClient
Procedure OrderUnavailable()

	LocalOrder = False;
	Items.LocalOrder.ReadOnly = True;
	Items.OrderPages.CurrentPage = Items.UnavailableOrderSettings;

EndProcedure

// Переключить страницу порядка на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure OrderUnavailable1()

	LocalOrder1 = False;
	Items.LocalOrder1.ReadOnly = True;
	Items.OrderPages1.CurrentPage = Items.UnavailableOrderSettings1;

EndProcedure

// Включить доступность условного оформления.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure ConditionalAppearanceAvailable(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemConditionalAppearance(ЭлементСтруктуры) Then

		LocalConditionalAppearance = True;
		Items.ConditionalAppearancePages.CurrentPage = Items.ConditionalAppearanceSettings;

	Else

		LocalConditionalAppearance = False;
		Items.ConditionalAppearancePages.CurrentPage = Items.DisabledConditionalAppearanceSettings;

	EndIf;

	Items.LocalConditionalAppearance.ReadOnly = False;

EndProcedure

// Включить доступность условного оформления для исполняемых настроек.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure ConditionalAppearanceAvailable1(ЭлементСтруктуры)

	If ExecutedSettingsComposer.Settings.HasItemConditionalAppearance(ЭлементСтруктуры) Then

		LocalConditionalAppearance1 = True;
		Items.ConditionalAppearancePages1.CurrentPage = Items.ConditionalAppearanceSettings1;

	Else

		LocalConditionalAppearance1 = False;
		Items.ConditionalAppearancePages1.CurrentPage = Items.DisabledConditionalAppearanceSettings1;

	EndIf;

	Items.LocalConditionalAppearance1.ReadOnly = False;

EndProcedure

// Переключить страницу условного оформления на страницу с текстом недоступности.
&AtClient
Procedure ConditionalAppearanceUnavailable()

	LocalConditionalAppearance = False;
	Items.LocalConditionalAppearance.ReadOnly = True;
	Items.ConditionalAppearancePages.CurrentPage = Items.UnavailableConditionalAppearanceSettings;

EndProcedure

// Переключить страницу условного оформления на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure ConditionalAppearanceUnavailable1()

	LocalConditionalAppearance1 = False;
	Items.LocalConditionalAppearance1.ReadOnly = True;
	Items.ConditionalAppearancePages1.CurrentPage = Items.UnavailableConditionalAppearanceSettings1;

EndProcedure

// Включить доступность параметров вывода.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure OutputParametersAvailable(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemOutputParameters(ЭлементСтруктуры) Then

		LocalOutputParameters = True;
		Items.OutputParametersPages.CurrentPage = Items.OutputParametersSettings;

	Else

		LocalOutputParameters = False;
		Items.OutputParametersPages.CurrentPage = Items.DisabledOutputParametersSettings;

	EndIf;

	Items.LocalOutputParameters.ReadOnly = False;

EndProcedure

// Включить доступность параметров вывода для исполняемых настроек.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure OutputParametersAvailable1(ЭлементСтруктуры)

	If ExecutedSettingsComposer.Settings.HasItemOutputParameters(ЭлементСтруктуры) Then

		LocalOutputParameters1 = True;
		Items.OutputParametersPages1.CurrentPage = Items.OutputParametersSettings1;

	Else

		LocalOutputParameters1 = False;
		Items.OutputParametersPages1.CurrentPage = Items.DisabledOutputParametersSettings1;

	EndIf;

	Items.LocalOutputParameters1.ReadOnly = False;

EndProcedure

// Переключить страницу параметров вывода на страницу с текстом недоступности.
&AtClient
Procedure OutputParametersUnavailable()

	LocalOutputParameters = False;
	Items.LocalOutputParameters.ReadOnly = True;
	Items.OutputParametersPages.CurrentPage = Items.UnavailableOutputParametersSettings;

EndProcedure

// Переключить страницу параметров вывода на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure OutputParametersUnavailable1()

	LocalOutputParameters1 = False;
	Items.LocalOutputParameters1.ReadOnly = True;
	Items.OutputParametersPages1.CurrentPage = Items.UnavailableOutputParametersSettings1;

EndProcedure

// Сгенерировать имя от базовой части имени на сервере.
//
// Параметры:
//  RowType - тип строки, для которой генерируется имя.
//  БазоваяЧастьИмени - начальная часть имени.
//  КоллекцияЭлементов - коллекция элементов в рамках которой проверяется 
//						 уникальность имени.
//  Рекурсивно - необходимость рекурсивной проверки уникальности имен
//				 в коллекции КоллекцияЭлементов.
//
// Возвращаемое значение:
//   Строка - сгенерированное имя.
&AtServer
Function СгенерироватьИмяСервер(ТипСтроки, БазоваяЧастьИмени, КоллекцияЭлементов, Рекурсивно)

	УникальныеИмена = New Map;
	НайтиУникальныеИменаСервер(КоллекцияЭлементов, ТипСтроки, УникальныеИмена, Рекурсивно);
	ИндексИмени = 1;

	While True Do

		Name = БазоваяЧастьИмени + ?(ИндексИмени > 1, " " + String(ИндексИмени), "");

		If УникальныеИмена.Get(Name) <> True Then

			Return Name;

		EndIf;

		ИндексИмени = ИндексИмени + 1;

	EndDo;

EndFunction

// Сгенерировать имя от базовой части имени на клиенте.
//
// Параметры:
//  RowType - тип строки, для которой генерируется имя.
//  БазоваяЧастьИмени - начальная часть имени.
//  КоллекцияЭлементов - коллекция элементов в рамках которой проверяется
//						 уникальность имени.
//  Рекурсивно - необходимость рекурсивной проверки уникальности имен
//				 в коллекции КоллекцияЭлементов.
//
// Возвращаемое значение:
//   Строка - сгенерированное имя.
&AtClient
Function СгенерироватьИмя(ТипСтроки, БазоваяЧастьИмени, КоллекцияЭлементов, Рекурсивно)

	УникальныеИмена = New Map;
	НайтиУникальныеИмена(КоллекцияЭлементов, ТипСтроки, УникальныеИмена, Рекурсивно);
	ИндексИмени = 1;

	While True Do

		Name = БазоваяЧастьИмени + ?(ИндексИмени > 1, " " + String(ИндексИмени), "");
		If УникальныеИмена.Get(Name) <> True Then

			Return Name;

		EndIf;
		ИндексИмени = ИндексИмени + 1;

	EndDo;

EndFunction

// Найти строки с указанным типом строки в коллекции элементов. Рекурсивно.
//
// Параметры:
//  КоллекцияЭлементов - коллекция элементов, в которой нужно искать.
//  RowType - тип строки, который нужно найти.
//  НайденныеСтроки - массив найденных строк.
&AtClientAtServerNoContext
Procedure FindRows(КоллекцияЭлементов, ТипСтроки, НайденныеСтроки)

	For Each Item In КоллекцияЭлементов Do

		If Item.RowType = ТипСтроки Then

			НайденныеСтроки.Add(Item);

		EndIf;

		FindRows(Item.GetItems(), ТипСтроки, НайденныеСтроки);

	EndDo;

EndProcedure

// Сгенерировать имя для схемы компоновки данных.
//
// Возвращаемое значение:
//  Стока - сгенерированное имя схемы компоновки данных.
&AtClient
Function СгенерироватьИмяСхемыКомпоновкиДанных()

	Return СгенерироватьИмя(0, NStr("ru='Report'"), ReportsTree.GetItems(), True);

EndFunction

// Сгенерировать имя для варианта отчета.
//
// Параметры:
//  КоллекцияЭлементов - коллекция элементов, в которую добавляется вариант отчета.
//
// Возвращаемое значение:
//  Стока - сгенерированное имя варианта.
&AtClient
Function СгенерироватьИмяВариантаОтчета(КоллекцияЭлементов)

	Return СгенерироватьИмя(1, NStr("ru='Variant'"), КоллекцияЭлементов, False);

EndFunction

// Сгенерировать имя для пользовательской Settings.
//
// Параметры:
//  КоллекцияЭлементов - коллекция элементов, в которую добавляется пользовательская 
//						 настройка.
//
// Возвращаемое значение:
//  Стока - сгенерированное имя пользовательской Settings.
&AtClient
Function СгенерироватьИмяПользовательскойНастройки(КоллекцияЭлементов)

	Return СгенерироватьИмя(2, NStr("ru='Setting'"), КоллекцияЭлементов, False);

EndFunction

// Сгенерировать имя для папки.
//
// Параметры:
//  КоллекцияЭлементов - коллекция элементов, в которую добавляется папка.
//
// Возвращаемое значение:
//  Стока - сгенерированное имя папки.
&AtClient
Function СгенерироватьИмяПапки(КоллекцияЭлементов)

	Return СгенерироватьИмя(3, NStr("ru='Folder'"), КоллекцияЭлементов, False);

EndFunction

// Найти все уникальные имена в коллекции элементов на сервере.
//
// Параметры:
//  Элементы - коллекция элементов, имена которых нужно собрать.
//  RowType - тип строк, имена которых нужно собрать.
//  УникальныеИмена - соответствие, в которое нужно поместить уникальные имена.
//  Рекурсивно - необходимость рекурсивного получения вложенных имен.
&AtServer
Procedure НайтиУникальныеИменаСервер(Items, ТипСтроки, УникальныеИмена, Рекурсивно)

	For Each Item In Items Do

		If Item.RowType = ТипСтроки Then

			УникальныеИмена.Insert(Item.Name, True);

		EndIf;

		If Рекурсивно Then

			НайтиУникальныеИменаСервер(Item.GetItems(), ТипСтроки, УникальныеИмена, Рекурсивно);

		EndIf;

	EndDo;

EndProcedure

// Найти все уникальные имена в коллекции элементов на клиенте.
//
// Параметры:
//  Элементы - коллекция элементов, имена которых нужно собрать.
//  RowType - тип строк, имена которых нужно собрать.
//  УникальныеИмена - соответствие, в которое нужно поместить уникальные имена.
//  Рекурсивно - необходимость рекурсивного получения вложенных имен.
&AtClient
Procedure НайтиУникальныеИмена(Items, ТипСтроки, УникальныеИмена, Рекурсивно)

	For Each Item In Items Do

		If Item.RowType = ТипСтроки Then

			УникальныеИмена.Insert(Item.Name, True);

		EndIf;

		If Рекурсивно Then

			НайтиУникальныеИмена(Item.GetItems(), ТипСтроки, УникальныеИмена, Рекурсивно);

		EndIf;

	EndDo;

EndProcedure

// Определить тип папки.
//
// Параметры:
//  Элемент - элемент - папка, тип которой определяется.
//
// Возвращаемое значение:
//  Число - тип папки;
//  Неопределено в случае если тип папки определить не удалось.
&AtClient
Function ТипПапки(Item)

	ЭлементНеПапка = Item.GetParent();

	While ЭлементНеПапка <> Undefined Do

		If ЭлементНеПапка.RowType <> 3 Then

			Return ЭлементНеПапка.RowType;

		Else

			ЭлементНеПапка = ЭлементНеПапка.GetParent();

		EndIf;

	EndDo;

	Return Undefined;

EndFunction

// Загрузить File.
//
// Параметры:
//  ЗагружаемоеИмяФайла - имя файла, из которого нужно загрузить. Если имя файла
//						  пустое, то нужно запросить у пользователя имя файла.
&AtClient
Procedure ЗагрузитьФайлКонсоли(ЗагружаемоеИмяФайла)

	Var Address;

	BeginAttachingFileSystemExtension(
		New NotifyDescription("ЗагрузитьФайлКонсолиПослеПодключенияРасширения", ThisForm,
		New Structure("ЗагружаемоеИмяФайла", ЗагружаемоеИмяФайла)));

EndProcedure

// Обработчик подключения расширения при загрузке файла.
&AtClient
Procedure ЗагрузитьФайлКонсолиПослеПодключенияРасширения(Подключено, AdditionalParameters) Export

	ЗагружаемоеИмяФайла = AdditionalParameters.ЗагружаемоеИмяФайла;

	If Подключено Then

		If ЗагружаемоеИмяФайла = "" Then

			ВыборФайла = New FileDialog(FileDialogMode.Opening);
			ВыборФайла.Multiselect = False;
			ВыборФайла.FullFileName = FileName;
			Filter = NStr("ru = 'File консоли системы компоновки данных (*.dcr)|*.dcr|All файлы (*.*)|*.*'");
			ВыборФайла.Filter = Filter;
			ВыборФайла.Extension = "dcr";

			BeginPuttingFiles(
				New NotifyDescription("ЗагрузитьФайлКонсолиПослеПодключенияРасширенияПослеПомещенияФайлов",
				ThisForm), , ВыборФайла);

		Else

			ПомещаемыеФайлы = New Array;
			ПомещаемыеФайлы.Add(New TransferableFileDescription(ЗагружаемоеИмяФайла, ""));

			BeginPuttingFiles(
				New NotifyDescription("ЗагрузитьФайлКонсолиПослеПодключенияРасширенияПослеПомещенияФайлов",
				ThisForm), ПомещаемыеФайлы, , False);

		EndIf;

	Else

		BeginPutFile(
			New NotifyDescription("ЗагрузитьФайлКонсолиПослеПодключенияРасширенияПослеПомещенияФайла", ThisForm), ,
			ЗагружаемоеИмяФайла, , ЗагружаемоеИмяФайла = "");

	EndIf;

EndProcedure

// Продолжение загрузки файла после того, как выполнен выбор файла.
&AtClient
Procedure ЗагрузитьФайлКонсолиПослеПодключенияРасширенияПослеПомещенияФайлов(ПомещенныеФайлы, AdditionalParameters) Export

	If ПомещенныеФайлы <> Undefined Then

		ОтработкаЗагрузкиФайла(ПомещенныеФайлы);

	EndIf;

EndProcedure

// Продолжение загрузки файла после получения файла.
&AtClient
Procedure ЗагрузитьФайлКонсолиПослеПодключенияРасширенияПослеПомещенияФайла(Result, Address, ВыбранноеИмяФайла,
	AdditionalParameters) Export

	If Result Then

		FileName = ВыбранноеИмяФайла;
		ОтработкаЗагрузкиИзАдреса(Address);

	EndIf;

EndProcedure

// Непосредственная загузка файлов.
&AtClient
Procedure ОтработкаЗагрузкиФайла(ПомещенныеФайлы)

	For Each ПомещенныйФайл In ПомещенныеФайлы Do

		If ПомещенныйФайл.Location <> "" Then

			ВыбранноеИмяФайла = ПомещенныйФайл.Name;
			Address = ПомещенныйФайл.Location;
			FileName = ВыбранноеИмяФайла;
			Break;

		EndIf;

	EndDo;

	ОтработкаЗагрузкиИзАдреса(Address);

EndProcedure

// Отработка загрузки файла с отчетами из адреса.
&AtClient
Procedure ОтработкаЗагрузкиИзАдреса(Address)
	Try
		ЗагрузитьФайлКонсолиНаСервере(Address);
	Except
		Return;
	EndTry;
	ТекущийЭлементДерева = Undefined;

	If TypeOf(CurrentNode) = Type("ValueList") Then

		ТекущиеЭлементы = ReportsTree.GetItems();

		For Позиция = 0 To CurrentNode.Count() - 1 Do

			Name = CurrentNode[CurrentNode.Count() - Позиция - 1].Value;
			Найдено = False;

			For Each Item In ТекущиеЭлементы Do

				If Item.Name = Name Then

					ТекущийЭлементДерева = Item;
					ТекущиеЭлементы = ТекущийЭлементДерева.GetItems();

					Найдено = True;
					Break;

				EndIf;

			EndDo;

			If Not Найдено Then

				Break;

			EndIf;

		EndDo;

		If ТекущийЭлементДерева <> Undefined Then

			Items.ReportsTree.CurrentRow = ТекущийЭлементДерева.GetID();

		EndIf;

	EndIf;

	CurrentNode = Undefined;
	ОбновитьЗаголовок();
//	CurrentRow = Неопределено;
	ЗагрузитьТекущуюСтрокуНаСервере();
	CurrentRowSettingsIsChanged = False;
EndProcedure

// Загрузить File консоли на сервере.
//
// Параметры:
//  Адрес - адрес хранилища, из которого нужно загрузить File.
&AtServer
Procedure ЗагрузитьФайлКонсолиНаСервере(Address)

	ИмяВременногоФайла = GetTempFileName();
	Data = GetFromTempStorage(Address);
	Data.Write(ИмяВременногоФайла);
	ValueToFormAttribute(ValueFromFile(ИмяВременногоФайла), "ReportsTree");

EndProcedure

// Загрузить схему компоновки данных в компоновщик настроек.
//
// Параметры:
//  ЭлементДерева - элемент дерева отчетов, схему которого нужно загрузить в компоновщик настроек.
//  ЗагружатьНастройкиПоУмолчанию - Булево. Признак того, нужно ли загружать из схемы Settings по умолчанию.
&AtServer
Procedure ЗагрузитьСхемуКомпоновкиДанныхВКомпоновщикНастроек(ЭлементДерева, ЗагружатьНастройкиПоУмолчанию)
	If ЭлементДерева.RowType = 4 Then
		Return;
	EndIf;

	DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(ЭлементДерева.Data);
	SchemaTempStorageURL = PutToTempStorage(DataCompositionSchema, ?(
		SchemaTempStorageURL <> "", SchemaTempStorageURL, UUID));
	Report.SettingsComposer.Initialize(
		New DataCompositionAvailableSettingsSource(SchemaTempStorageURL));

	If ЗагружатьНастройкиПоУмолчанию And ValueIsFilled(ЭлементДерева.НастройкиСКД) Then
		XMLReader = New XMLReader;
		XMLReader.SetString(ЭлементДерева.НастройкиСКД);
		Settings = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionSettings"));

		Report.SettingsComposer.LoadSettings(Settings);

	EndIf;

EndProcedure

// Загрузить Settings варианта отчета в текущую строку дерева.
//
// Параметры:
//  ЭлементДерева - элемент дерева отчета, в который нужно загрузить Settings варианта отчета.
&AtServer
Procedure ЗагрузитьНастройкиВаниантаВТекущуюСтроку(ЭлементДерева)

	ЭлементОтчет = НайтиЭлементДереваОтчет(ЭлементДерева);

	If ЭлементОтчет <> Undefined Then

		ЗагрузитьСхемуКомпоновкиДанныхВКомпоновщикНастроек(ЭлементОтчет, False);

	EndIf;

	If ЭлементДерева.Data <> "" Then

		XMLReader = New XMLReader;
		XMLReader.SetString(ЭлементДерева.Data);
		Settings = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionSettings"));

	Else

		Settings = New DataCompositionSettings;

	EndIf;

	Report.SettingsComposer.LoadSettings(Settings);

EndProcedure

// Найти элемент дерева с отчетом.
//
// Параметры:
//  ЭлементДерева - элемент дерева, начиная от которого нужно найти элемент дерева с отчетом.
//
// Возвращаемое значение:
//   ДанныеФормыЭлементДерева - найденный элемент дерева - Report;
//   Неопреледено - отчет не найден.
&AtServer
Function НайтиЭлементДереваОтчет(Val ЭлементДерева)

	While ЭлементДерева <> Undefined Do

		If ЭлементДерева.RowType = 0 Then

			Return ЭлементДерева;

		Else

			ЭлементДерева = ЭлементДерева.GetParent();

		EndIf;

	EndDo;

	Return Undefined;

EndFunction

// Сохранить данные текущей строки на сервере.
//
// Возвращаемое значение:
//  Истина - текущая строка была изменена;
//  Ложь - текущая строка изменена не была.
&AtServer
Function СохранитьДанныеТекущейСтрокиНаСервере()

	If CurrentRow <> Undefined Then

		ЭлементДерева = ReportsTree.FindByID(CurrentRow);

		If ЭлементДерева.RowType = 0 Then

		// Variant отчета.
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.Settings, "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			НовыеДанные = XMLWriter.Close();

			If ЭлементДерева.НастройкиСКД <> НовыеДанные Then

				ЭлементДерева.НастройкиСКД = НовыеДанные;
				Return True;

			EndIf;

			//		ElsIf ЭлементДерева.RowType = 2 Then
			//			
			//			// Settings.
			//			XMLWriter = New XMLWriter;
			//			XMLWriter.SetString();
			//			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.UserSettings, "UserSettings", "http://v8.1c.ru/8.1/data-composition-system/settings");
			//			НовыеДанные = XMLWriter.Close();
			//			
			//			If ЭлементДерева.Data <> НовыеДанные Then
			//				
			//				ЭлементДерева.Data = НовыеДанные;
			//				Return True;
			//				
			//			EndIf;
			//			
		EndIf;

	EndIf;

	Return False;

EndFunction

// Загрузить текущую строку на сервере.
&AtServer
Procedure ЗагрузитьТекущуюСтрокуНаСервере()

	If Items.ReportsTree.CurrentRow = Undefined Then
		Return;
	EndIf;

	ЭлементДерева = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

	//		If ЭлементДерева.RowType=0 Then
	//Scheme компоновки
	ЗагрузитьСхемуКомпоновкиДанныхВКомпоновщикНастроек(ЭлементДерева, True);

	//		ElsIf ЭлементДерева.RowType = 1 Then
	//			// Variant отчета.
	//			ЗагрузитьНастройкиВаниантаВТекущуюСтроку(ЭлементДерева);
	//			
	//		ElsIf ЭлементДерева.RowType = 2 Then
	//			// Пользовательские Settings.
	//			ЭлементВриантИлиОтчет = ЭлементДерева.GetParent();
	//			
	//			While ЭлементВриантИлиОтчет <> Undefined Do
	//				
	//				If ЭлементВриантИлиОтчет.RowType = 0 Then
	//					// Нашли отчет.
	//					ЗагрузитьСхемуКомпоновкиДанныхВКомпоновщикНастроек(ЭлементВриантИлиОтчет, True);
	//					Break;
	//					
	//				ElsIf ЭлементВриантИлиОтчет.RowType = 1 Then
	//					// Нашли вариант отчета.
	//					ЗагрузитьНастройкиВаниантаВТекущуюСтроку(ЭлементВриантИлиОтчет);
	//					Break;
	//					
	//				EndIf;
	//				
	//				ЭлементВриантИлиОтчет = ЭлементВриантИлиОтчет.GetParent();
	//				
	//			EndDo;
	//			
	//			If ЭлементДерева.Data <> "" Then
	//				
	//				XMLReader = New XMLReader;
	//				XMLReader.SetString(ЭлементДерева.Data);
	//				UserSettings = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionUserSettings"));
	//				
	//			Else
	//
	//				UserSettings = New DataCompositionUserSettings;
	//
	//			EndIf;
	//			
	//			Report.SettingsComposer.LoadUserSettings(UserSettings);
	//			
	//		EndIf;
EndProcedure

// Сохранить текущую строку и загрузить новую текущую строку на сервере.
&AtServer
Procedure СохранитьДанныеТекущейСтрокиИЗагрузитьТекущуюСтрокуНаСервере()

// Сохраним Settings текущей строки в дерево.
	СохранитьДанныеТекущейСтрокиНаСервере();

	// Загрузим Settings в компоновщик настроек.
	ЗагрузитьТекущуюСтрокуНаСервере();

EndProcedure

// Вывести макет компоновки данных в табличный документ.
//
// Параметры:
//  МакетКомпоновкиДанных - макет компоновки данных, который нужно вывести.
//  ДанныеРасшифровкиОбъект - объект данных расшифровки, который нужно заполнить при выводе.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВТабличныйДокумент(DataCompositionTemplate, ДанныеРасшифровкиОбъект)

	ResultSpreadsheetDocument.Clear();
	DataCompositionProcessor = New DataCompositionProcessor;
	DataCompositionProcessor.Initialize(DataCompositionTemplate, СтруктураВнешнихНаборовДанных(), ДанныеРасшифровкиОбъект, True);
	ПроцессорВыводаРезультатаОтчета = New DataCompositionResultSpreadsheetDocumentOutputProcessor;
	ПроцессорВыводаРезультатаОтчета.SetDocument(ResultSpreadsheetDocument);
	ПроцессорВыводаРезультатаОтчета.BeginOutput();
	ПроцессорВыводаРезультатаОтчета.Put(DataCompositionProcessor);
	ПроцессорВыводаРезультатаОтчета.EndOutput();

	If ДанныеРасшифровкиОбъект <> Undefined Then

		DetailsDataURL = PutToTempStorage(ДанныеРасшифровкиОбъект, UUID);

	EndIf;

EndProcedure

// Выполнить компоновку и получить текст результата компоновки данных в виде XML.
//
// Парамерты:
//  МакетКомпоновкиДанных - макет компоновки данных, который нужно выполнить.
//  ДанныеРасшифровкиОбъект - объект данных расшифровки, который нужно заполнить.
//
// Возвращаемое значение:
//   Строка - XML текст результата компоновки данных и данных расшифровки.
&AtServer
Function ПолучитьТекстРезультатаКомпоновкиДанных(DataCompositionTemplate, ДанныеРасшифровкиОбъект)

	DataCompositionProcessor = New DataCompositionProcessor;
	DataCompositionProcessor.Initialize(DataCompositionTemplate, СтруктураВнешнихНаборовДанных(), ДанныеРасшифровкиОбъект, True);

	Result = "<resultAndDetailsInfo>";
	Result = Result + Chars.LF + Chars.Tab + "<result>";
	XMLWriter = New XMLWriter;
	УровеньВложенности = 3;

	While True Do

		DataCompositionResultItem = DataCompositionProcessor.Next();

		If DataCompositionResultItem = Undefined Then

			Break;

		EndIf;

		If DataCompositionResultItem.ItemType = DataCompositionResultItemType.End Then

			УровеньВложенности = УровеньВложенности - 1;

		EndIf;

		XMLWriter.SetString();
		XDTOSerializer.WriteXML(XMLWriter, DataCompositionResultItem, "item",
			"http://v8.1c.ru/8.1/data-composition-system/result");
		Стр = XMLWriter.Close();

		СтрокаЗамены = "";

		For ИИ = 1 To УровеньВложенности - 1 Do

			СтрокаЗамены = СтрокаЗамены + Chars.Tab;

		EndDo;

		Стр = StrReplace(Стр, Chars.LF, Chars.LF + СтрокаЗамены);
		Стр = СтрокаЗамены + Стр;
		Result = Result + Chars.LF + Стр;

		If DataCompositionResultItem.ItemType = DataCompositionResultItemType.Begin Then

			УровеньВложенности = УровеньВложенности + 1;

		EndIf;

	EndDo;

	Result = Result + Chars.LF + Chars.Tab + "</result>";

	If ДанныеРасшифровкиОбъект <> Undefined Then

		XMLWriter.SetString();
		XDTOSerializer.WriteXML(XMLWriter, ДанныеРасшифровкиОбъект, "detailsInfo",
			"http://v8.1c.ru/8.1/data-composition-system/details");
		Стр = XMLWriter.Close();
		Стр = StrReplace(Стр, Chars.LF, Chars.LF + Chars.Tab);
		Стр = Chars.Tab + Стр;
		Result = Result + Chars.LF + Стр;

	EndIf;

	Result = Result + Chars.LF + "</resultAndDetailsInfo>";

	Return Result;

EndFunction

// Вывести макет компоновки данных в результат XML.
//
// Параметры:
//  МакетКомпоновкиДанных - макет компоновки, который нужно вывести.
//  ДанныеРасшифровкиОбъект - данные расшифровки, которые нужно заполнить.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, ДанныеРасшифровкиОбъект)

	TextOfDataCompositionResult = ПолучитьТекстРезультатаКомпоновкиДанных(DataCompositionTemplate,
		ДанныеРасшифровкиОбъект);

EndProcedure

// Вывести макет компоновки данных в результат в виде XML для коллекции значений.
//
// Параметры:
//  МакетКомпоновкиДанных - макет, который нужно вывести.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate)

	TextOfDataCompositionResultForCollection = ПолучитьТекстРезультатаКомпоновкиДанных(DataCompositionTemplate,
		Undefined);

EndProcedure

// Generate на сервере текущую строку в табличный документ.
//
// Возвращаемое значение:
//  Строка - текст ошибки, который нужно выдать пользователю.
&AtServer
Function СформироватьНаСервереВТабличныйДокумент()

	Var ДанныеРасшифровкиОбъект;

	ResultFilledSpreadsheetDocument = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВТабличныйДокумент(DataCompositionTemplate, ДанныеРасшифровкиОбъект);
			ОтобразитьПанельРезультатов();

			//		ElsIf Item.s = 1 Then
			//			// Variant отчета.
			//			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			КомпоновщикМакета = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema, Report.SettingsComposer.Settings, ДанныеРасшифровкиОбъект);
			//			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			//			ВывестиМакетКомпоновкиДанныхВТабличныйДокумент(DataCompositionTemplate, ДанныеРасшифровкиОбъект);
			//			ОтобразитьПанельРезультатов();
			//			
			//		ElsIf Item.RowType = 2 Then
			//			// Settings отчета.
			//			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			КомпоновщикМакета = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema, Report.SettingsComposer.GetSettings(), ДанныеРасшифровкиОбъект);
			//			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			//			ВывестиМакетКомпоновкиДанныхВТабличныйДокумент(DataCompositionTemplate, ДанныеРасшифровкиОбъект);
			//			ОтобразитьПанельРезультатов();
		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Вывести дерево значений в реквизит формы.
//
// Параметры:
//  ВременноеДерево - дерево, которое нужно вывести.
&AtServer
Procedure ВывестиДеревоРезультатВКоллекцию(ВременноеДерево)

	НовыеРеквзиты = New Array;

	For Each Column In ВременноеДерево.Cols Do
		If Column.ValueType.ContainsType(Type("ValueStorage")) Then
			Continue;
		EndIf;

		NewColumn = New FormAttribute(Column.Name, Column.ValueType, "TreeResult", Column.Title);
		НовыеРеквзиты.Add(NewColumn);

	EndDo;

	УдаляемыеРеквизиты = New Array;
	ТекущиеРеквизиты = GetAttributes("TreeResult");

	For Each Attribute In ТекущиеРеквизиты Do

		УдаляемыеРеквизиты.Add(Attribute.Path + "." + Attribute.Name);

	EndDo;

	ChangeAttributes(НовыеРеквзиты, УдаляемыеРеквизиты);

	While Items.TreeResult.ChildItems.Count() > 0 Do

		Items.Delete(Items.TreeResult.ChildItems[0]);

	EndDo;

	For Each Column In ВременноеДерево.Cols Do
		If Column.ValueType.ContainsType(Type("ValueStorage")) Then
			Continue;
		EndIf;

		Item = Items.Add(Column.Name, Type("FormField"), Items.TreeResult);
		Item.DataPath = "TreeResult." + Column.Name;

	EndDo;

	Items.DecorationCollection.Visible = НовыеРеквзиты.Count() = 0;

	ValueToFormAttribute(ВременноеДерево, "TreeResult");

EndProcedure

// Вывести макет компоновки данных в виде коллекции в реквизит формы.
//
// Параметры:
//  МакетКомпоновкиДанных - макет, который нужно вывести.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate)

	DataCompositionProcessor = New DataCompositionProcessor;
	DataCompositionProcessor.Initialize(DataCompositionTemplate, СтруктураВнешнихНаборовДанных(), , True);
	ПроцессорВыводаРезультатаОтчета = New DataCompositionResultValueCollectionOutputProcessor;
	ПроцессорВыводаРезультатаОтчета.SetObject(New ValueTree);
	ПроцессорВыводаРезультатаОтчета.BeginOutput();
	ПроцессорВыводаРезультатаОтчета.Put(DataCompositionProcessor);
	ВывестиДеревоРезультатВКоллекцию(ПроцессорВыводаРезультатаОтчета.EndOutput());

EndProcedure

// Generate на сервере результат и вывести его в коллекцию значений.
//
// Возвращаемое значение:
//  Строка - текст сообщения, которое нужно показать пользователю.
&AtServer
Function СформироватьНаСервереВКоллекцию()

	ResultFilledCollection = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

			//		ElsIf Item.RowType = 1 Then
			//			// Variant отчета.
			//			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			КомпоновщикМакета = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema, Report.SettingsComposer.Settings , , , Type("DataCompositionValueCollectionTemplateGenerator"));
			//			ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
			//			ОтобразитьПанельРезультатов();
			//			
			//		ElsIf Item.RowType = 2 Then
			//			// Settings отчета.
			//			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			//			КомпоновщикМакета = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema, Report.SettingsComposer.GetSettings() , , , Type("DataCompositionValueCollectionTemplateGenerator"));
			//			ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
			//			ОтобразитьПанельРезультатов();
		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate на сервере отчет и вывести его в виде XML.
//
// Возвращаемое значение:
//  Строка - текст сообщения, которое нужно показать пользователю.
&AtServer
Function СформироватьНаСервереВВидеXML()

	Var ДанныеРасшифровкиОбъект;

	ResultFilledXML = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, ДанныеРасшифровкиОбъект);
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 1 Then
		// Variant отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, ДанныеРасшифровкиОбъект);
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 2 Then
		// Settings отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, ДанныеРасшифровкиОбъект);
			ОтобразитьПанельРезультатов();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate результат отчета для коллекции и выдать его в виде текста XML.
//
// Возвращаемое значение:
//  Строка - текст сообщения, который нужно показать пользователю.
&AtServer
Function СформироватьНаСервереВВидеXMLКоллекция()

	ResultFilledCollectionXML = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 1 Then
		// Variant отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 2 Then
		// Settings отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Вывести макет компоновки данных в виде текста.
//
// Параметры:
//  МакетКомпоновкиДанных - выводимый макет.
//
// Возвращаемое значение:
//  Строка - текст макета компоновки данных в виде XML.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВТекст(DataCompositionTemplate)

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, DataCompositionTemplate, "dataComposition",
		"http://v8.1c.ru/8.1/data-composition-system/composition-template");
	TextOfDataCompositionTemplate = XMLWriter.Close();

EndProcedure

// Generate макет компоновки данных.
// 
// Возвращаемое значение:
//  Строка - текст сообщения, который нужно выдать пользователю.
&AtServer
Function СформироватьНаСервереВМакетКомпоновкиДанных()

	Var ДанныеРасшифровкиОбъект;

	ResultFilledTemplate = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВТекст(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 1 Then
		// Variant отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВТекст(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 2 Then
		// Settings отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВТекст(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Вывести макет компоновки данных для коллекции значений в виде текста.
//
// Параметры:
// МакетКомпоновкиДанных - макет компоновки данных, который нужно вывести.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВТекстДляКоллекции(DataCompositionTemplate)

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, DataCompositionTemplate, "dataComposition",
		"http://v8.1c.ru/8.1/data-composition-system/composition-template");
	TextOfDataCompositionTemplateForCollection = XMLWriter.Close();

EndProcedure

// Generate макет компоновки данных для коллекции.
//
// Возвращаемое значение:
//  Строка - выводимая пользователю строка.
&AtServer
Function СформироватьНаСервереВМакетКомпоновкиДанныхДляКоллекции()

	Var ДанныеРасшифровкиОбъект;

	ResultFilledTemplateForCollection = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВТекстДляКоллекции(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 1 Then
		// Variant отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВТекстДляКоллекции(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 2 Then
		// Settings отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.GetSettings(), , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВТекстДляКоллекции(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate исполняемые Settings.
//
// Возвращаемое значение:
//  Строка - сообщение, которое нужно выдать пользователю.
&AtServer
Function СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанных()

	Var ДанныеРасшифровкиОбъект;

	ResultFilledSettings = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ExecutedSettingsComposer.Initialize(
				New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
			ExecutedSettingsComposer.LoadSettings(DataCompositionSchema.DefaultSettings);
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 1 Then

		// Variant отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ExecutedSettingsComposer.Initialize(
				New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
			ExecutedSettingsComposer.LoadSettings(Report.SettingsComposer.Settings);
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 2 Then

		// Settings отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ReportsTree.FindByID(Items.ReportsTree.CurrentRow)).Data);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ExecutedSettingsComposer.Initialize(
				New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
			ExecutedSettingsComposer.LoadSettings(Report.SettingsComposer.GetSettings());
			ОтобразитьПанельРезультатов();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate исполняемые Settings и выдать их в виде XML.
//
// Возвращаемое значение:
//  Строка - текст, выдаваемый пользователю.
&AtServer
Function СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанныхXML()

	Var ДанныеРасшифровкиОбъект;

	ResultFilledSettingsXML = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		Item = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

		If Item.RowType = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, DataCompositionSchema.DefaultSettings, "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ExecutedSettingsXML = XMLWriter.Close();
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 1 Then
		// Variant отчета.
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.Settings, "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ExecutedSettingsXML = XMLWriter.Close();
			ОтобразитьПанельРезультатов();

		ElsIf Item.RowType = 2 Then
		// Settings отчета.
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.GetSettings(), "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ExecutedSettingsXML = XMLWriter.Close();
			ОтобразитьПанельРезультатов();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Generate отчет на сервере. Формирование идет в зависимости от текущей страницы панели результатов.
//
// Возвращаемое значение:
//  Строка - текст, выдаваемый пользователю.
&AtServer
Function СформироватьНаСервере()

	ReportNeedsToGenerate = True;
	ResultFilledTemplate = False;
	ResultFilledSettings = False;
	ResultFilledSettingsXML = False;
	ResultFilledSpreadsheetDocument = False;
	ResultFilledXML = False;
	ResultFilledCollection = False;
	ResultFilledTemplateForCollection = False;
	ResultFilledCollectionXML = False;

	If Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument Then

		Return СформироватьНаСервереВТабличныйДокумент();

//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageDataCompositionTemplate Тогда
//
//		Возврат СформироватьНаСервереВМакетКомпоновкиДанных();
//
//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageExecutedSettings Тогда
//
//		Возврат СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанных();
//
//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageExecutedSettingsXML Тогда
//
//		Возврат СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанныхXML();
//
//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageDataCompositionResultXML Тогда
//
//		Возврат СформироватьНаСервереВВидеXML();

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageResultCollection Then

		Return СформироватьНаСервереВКоллекцию();

//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageTemplateForCollection Тогда
//
//		Возврат СформироватьНаСервереВМакетКомпоновкиДанныхДляКоллекции();
//
//	ИначеЕсли Элементы.ResultsPanel.ТекущаяСтраница = Элементы.PageResultCollectionXML Тогда
//
//		Возврат СформироватьНаСервереВВидеXMLКоллекция();

	EndIf;
EndFunction

// Generate отчет на клиенте.
&AtClient
Procedure СформироватьКлиент()

	Result = СформироватьНаСервере();

	If Result <> Undefined Then

		ShowMessageBox( , Result);

	EndIf;

EndProcedure

// Отобразить панель результатов.
&AtServer
Procedure ОтобразитьПанельРезультатов()

	Items.ResultsPanel.Visible = True;
	Items.ButtonResultsPanel.Check = Items.ResultsPanel.Visible;

EndProcedure

// Отобразить панель результатов.
&AtServer
Procedure ОтобразитьПанельНастроек()
	ВидимостьНастроек = Not Items.GroupSettingsAndReports.Visible;
	Items.GroupSettingsAndReports.Visible = ВидимостьНастроек;
	Items.Settings.Check = ВидимостьНастроек;

EndProcedure

// Получить схему компоновки данных на основании текста схемы.
//
// Возвращаемое значение:
//  СхемаКомпоновкиДанных - схема, считанная из текста схемы.
&AtServerNoContext
Function ПолучитьСхемуКомпоновкиДанных(ТекстСхемы)

	If ТекстСхемы <> "" Then

		XMLReader = New XMLReader;
		XMLReader.SetString(ТекстСхемы);
		Return XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionSchema"));

	Else

		Return New DataCompositionSchema;

	EndIf;

EndFunction

&AtServer
Function ПолучитьСхемуКомпоновкиДанныхВызовСервера()
	Return ПолучитьСхемуКомпоновкиДанныхСервер();
EndFunction

// Получить схему компоновки данных для текущей строки на сервере.
//
// Возвращаемое значение:
//  СхемаКомпоновкиДанных - Схема компоновки данных для текущей строки.
&AtServer
Function ПолучитьСхемуКомпоновкиДанныхСервер()

	Return ПолучитьСхемуКомпоновкиДанных(ReportsTree.FindByID(
		Items.ReportsTree.CurrentRow).Data);

EndFunction

// Получить схему компоновки данных для текущей строки на клиенте.
//
// Возвращаемое значение:
//  СхемаКомпоновкиДанных - схема компоновка данных для текущей строки.
&AtClient
Function ПолучитьСхемуКомпоновкиДанныхКлиент()

	#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	Return ПолучитьСхемуКомпоновкиДанных(ReportsTree.FindByID(
		Items.ReportsTree.CurrentRow).Data);
	#Else
		Return ПолучитьСхемуКомпоновкиДанныхВызовСервера();
	#EndIf

EndFunction

// Установить схему компоновки данных для текущей строки.
//
// Параметры:
//  Схема - СхемаКомпоновкиДанных - схема, которую нужно установить текущей строке.
&AtClient
Procedure УстановитьСхемуКомпоновкиДанныхКлиент(Scheme)
	УстановитьСхемуКомпоновкиДанных(Scheme);
EndProcedure

&AtServer
Procedure УстановитьСхемуКомпоновкиДанных(Scheme)
	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, Scheme, "dataCompositionSchema",
		"http://v8.1c.ru/8.1/data-composition-system/schema");

	CurrentRow = Items.ReportsTree.CurrentRow;
	ТекСтрокаДерева = ReportsTree.FindByID(CurrentRow);

	If ТекСтрокаДерева = Undefined Then
		Return;
	EndIf;

	ТекСтрокаДерева.Data = XMLWriter.Close();

	If Not ValueIsFilled(ТекСтрокаДерева.НастройкиСКД) Then
		XMLWriter = New XMLWriter;
		XMLWriter.SetString();
		XDTOSerializer.WriteXML(XMLWriter, Scheme.DefaultSettings, "Settings",
			"http://v8.1c.ru/8.1/data-composition-system/settings");
		ТекСтрокаДерева.НастройкиСКД = XMLWriter.Close();
	EndIf;

	// Загрузим Settings в компоновщик настроек.
	ЗагрузитьТекущуюСтрокуНаСервере();	
EndProcedure

// Открыть конструктор схемы компоновки данных.
&AtClient
Procedure ОткрытьКонструкторСхемыКомпоновкиДанных()

#If ТолстыйКлиентОбычноеПриложение Or ТолстыйКлиентУправляемоеПриложение Then
	Конструктор = New DataCompositionSchemaWizard(ПолучитьСхемуКомпоновкиДанныхКлиент());
	Конструктор.Edit(ThisForm);
#Else
		ТекДанные=Items.ReportsTree.CurrentData;
		If ТекДанные = Undefined Then
			Return;
		EndIf;

		EditorSettings=New Structure;
		EditorSettings.Insert("СКД", ТекДанные.Data);
		OpenForm("Processing.UT_DCSEditor.Form", EditorSettings, ThisForm, , , ,
			New NotifyDescription("ОткрытьКонструкторСхемыКомпоновкиДанныхЗавершение", ThisObject,
			New Structure("ИдентификаторСтроки", ТекДанные.GetID())), );
//		ShowMessageBox( , НСтр(
//			"ru='Конструктор схемы компоновки данных можно открыть только в толстом клиенте. В тонком клиенте и веб клиенте редактирование схемы компоновки данных возможно только в тексте схемы компоновки данных.'"));
#EndIf

EndProcedure

&AtClient
Procedure ОткрытьКонструкторСхемыКомпоновкиДанныхЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ОткрытьКонструкторСхемыКомпоновкиДанныхЗавершениеНаСервере(AdditionalParameters.ИдентификаторСтроки, Result);
EndProcedure

&AtServer
Procedure ОткрытьКонструкторСхемыКомпоновкиДанныхЗавершениеНаСервере(ИдентификаторСтроки, АдресСКД)
	Scheme=GetFromTempStorage(АдресСКД);

	XMLWriter = New XMLWriter;
	XMLWriter.SetString();
	XDTOSerializer.WriteXML(XMLWriter, Scheme, "dataCompositionSchema",
		"http://v8.1c.ru/8.1/data-composition-system/schema");

	ТекСтрокаДерева = ReportsTree.FindByID(ИдентификаторСтроки);

	If ТекСтрокаДерева = Undefined Then
		Return;
	EndIf;

	ТекСтрокаДерева.Data = XMLWriter.Close();

	If Not ValueIsFilled(ТекСтрокаДерева.НастройкиСКД) Then
		XMLWriter = New XMLWriter;
		XMLWriter.SetString();
		XDTOSerializer.WriteXML(XMLWriter, Scheme.DefaultSettings, "Settings",
			"http://v8.1c.ru/8.1/data-composition-system/settings");
		ТекСтрокаДерева.НастройкиСКД = XMLWriter.Close();
	EndIf;

	// Загрузим Settings в компоновщик настроек.
	ЗагрузитьТекущуюСтрокуНаСервере();

EndProcedure

// Обновить заголовок формы.
&AtClient
Procedure ОбновитьЗаголовок()

	Title = InitialTitle + ?(FileName <> "", ": " + FileName, "");

EndProcedure

// Сохранить File с отчетами.
//
// Параметры:
//  Как - булево. Необходимость запроса у пользователя имени файла.
//
// Возвращаемое значение:
//  Истина - сохранение прошло успешно;
//  Ложь - пользователь отменил сохранение.
&AtClient
Procedure Save(Как, NotificationProcessing)
	Var ВыборФайла;

	BeginAttachingFileSystemExtension(New NotifyDescription("СохранитьЗавершение", ThisForm,
		New Structure("Как, NotificationProcessing", Как, NotificationProcessing)));

EndProcedure

// Завершение процедуры сохранения.
&AtClient
Procedure СохранитьЗавершение(Подключено, AdditionalParameters) Export

	Как = AdditionalParameters.Как;
	NotificationProcessing = AdditionalParameters.NotificationProcessing;

	If Подключено Then

		If Как Or FileName = "" Then
			File = New File(FileName);
			СохраняемоеИмяФайла = File.Name;

			// Нужно запросить имя файла.
			ВыборФайла = New FileDialog(FileDialogMode.Save);
			ВыборФайла.Multiselect = False;
			ВыборФайла.FullFileName = FileName;
			ВыборФайла.Directory = File.Path;
			Filter = NStr("ru = 'File консоли системы компоновки данных (*.dcr)|*.dcr|All файлы (*.*)|*.*'");
			ВыборФайла.Filter = Filter;
			ВыборФайла.Extension = "dcr";

		Else
			ВыборФайла = FileName;
		EndIf;

		ПолучаемыеФайлы = New Array;
		ПолучаемыеФайлы.Add(New TransferableFileDescription(СохраняемоеИмяФайла,
			ПоместитьФайлВоВременноеХранилище()));
		BeginGettingFiles(New NotifyDescription("СохранитьЗавершениеПослеПолученияФайлов", ThisForm,
			New Structure("NotificationProcessing", NotificationProcessing)), ПолучаемыеФайлы, ВыборФайла, False);

	Else

		GetFile(ПоместитьФайлВоВременноеХранилище(), FileName, True);
		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	EndIf;

EndProcedure

// Завершение сохранения после получения файлов.
&AtClient
Procedure СохранитьЗавершениеПослеПолученияФайлов(ПолученныеФайлы, AdditionalParameters) Export

	NotificationProcessing = AdditionalParameters.NotificationProcessing;

	If ПолученныеФайлы = Undefined Then

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, False);

		EndIf;
	Else

		FileName = ПолученныеФайлы[0].Name;
		ОбновитьЗаголовок();
		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	EndIf;

EndProcedure

// Поместить File во временное хранилище.
&AtServer
Function ПоместитьФайлВоВременноеХранилище()

	ИмяВременногоФайла = GetTempFileName();
	ValueToFile(ИмяВременногоФайла, FormAttributeToValue("ReportsTree"));
	Result = PutToTempStorage(New BinaryData(ИмяВременногоФайла));
	Return Result;

EndFunction

// Если File отчетов был изменен, то запросить пользователя, нужно ли его сохранять.
//
// Возвращаемое значение:
//  Истина - закрытие подтверждено;
//  Ложь - пользователь отменил закрытие.
&AtClient
Procedure ПодтвердитьЗакрытие(NotificationProcessing)

	If СохранитьДанныеТекущейСтрокиНаСервере() Then

		Modified = True;

	EndIf;

	If Modified Then

		ShowQueryBox(New NotifyDescription("ПодтвердитьЗакрытиеЗавершение", ThisForm,
			New Structure("NotificationProcessing", NotificationProcessing)), NStr(
			"ru='Reports модифицированы. Save изменения?'"), QuestionDialogMode.YesNoCancel, ,
			DialogReturnCode.Yes);

	Else

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	EndIf;

EndProcedure

// Завершение подтверждения закрытия.
&AtClient
Procedure ПодтвердитьЗакрытиеЗавершение(РезультатВопроса, AdditionalParameters) Export

	NotificationProcessing = AdditionalParameters.NotificationProcessing;

	Ответ = РезультатВопроса;

	If Ответ = DialogReturnCode.Yes Then

		Save(False, NotificationProcessing);

	ElsIf Ответ = DialogReturnCode.None Then

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, True);

		EndIf;

	Else

		If NotificationProcessing <> Undefined Then

			ExecuteNotifyProcessing(NotificationProcessing, False);

		EndIf;

	EndIf;

EndProcedure

// Получить текущий узел.
//
// Возвращаемое значение:
//  Текущий узел дерева отчетов.
&AtServer
Function ПолучитьТекущийУзел()

	Var Result, ТекущийЭлементДерева;
	Result = New ValueList;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		ТекущийЭлементДерева = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

	EndIf;

	While ТекущийЭлементДерева <> Undefined Do

		Result.Add(ТекущийЭлементДерева.Name);
		ТекущийЭлементДерева = ТекущийЭлементДерева.GetParent();

	EndDo;

	Return Result;

EndFunction

// Сохранить Settings консоли в хранилище настроек.
&AtServer
Procedure СохранитьНастройкиКонсоли()

	CommonSettingsStorage.Save("НастройкиКонсолиСистемыОтчетности5", , New Structure("FileName,CurrentNode",
		FileName, ПолучитьТекущийУзел()));

EndProcedure

// Выделить базовую часть имени.
//
// Параметры:
//  ПолноеИмя - Строка. Имя, из которого нужно получить базовую часть.
//
// Возвращаемое значение:
//  Строка - базовая часть имени. Получается путем отбрасывания числа, находящегося
//           в конце полного имени.
&AtServer
Function НайтиБазовуюЧастьИмени(FullName)
// Ищем числа до первого пробела с конца. Обрезаем до этого пробела.
	If StrLen(FullName) < 3 Then

		Return "";

	EndIf;

	Позиция = StrLen(FullName);
	ЦифрыБыли = False;

	While Позиция > 1 Do

		ТекущийСимвол = Mid(FullName, Позиция, 1);

		If ТекущийСимвол >= "0" And ТекущийСимвол <= "9" Then

			ЦифрыБыли = True;

		ElsIf ТекущийСимвол = " " Then

			Break;

		Else

			ЦифрыБыли = False;
			Break;

		EndIf;

		Позиция = Позиция - 1;

	EndDo;

	If ЦифрыБыли And Позиция > 1 Then

		Return Mid(FullName, 1, Позиция - 1);

	Else

		Return "";

	EndIf;

EndFunction

// Скопировать текущую строку на сервере.
&AtServer
Procedure СкопироватьНаСервере()

	СохранитьДанныеТекущейСтрокиНаСервере();
	КопируемыйЭлемент = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);
	НовоеИмя = КопируемыйЭлемент.Name;
	БазоваяЧастьИмени = "";

	//	If КопируемыйЭлемент.RowType = 0 Then 
	БазоваяЧастьИмени = НайтиБазовуюЧастьИмени(КопируемыйЭлемент.Name);

	If БазоваяЧастьИмени = "" Then

		БазоваяЧастьИмени = NStr("ru='Report'");

	EndIf;

	НовоеИмя = СгенерироватьИмяСервер(0, БазоваяЧастьИмени, ReportsTree.GetItems(), True);

	//	ElsIf КопируемыйЭлемент.RowType = 1 Then 
	//		
	//		БазоваяЧастьИмени = НайтиБазовуюЧастьИмени(КопируемыйЭлемент.Name);
	//		
	//		If БазоваяЧастьИмени = "" Then
	//			
	//			БазоваяЧастьИмени = NStr("ru='Variant'");
	//			
	//		EndIf;
	//		
	//		НовоеИмя = СгенерироватьИмяСервер(1, БазоваяЧастьИмени, КопируемыйЭлемент.GetParent().GetItems(), False)
	//		
	//	ElsIf КопируемыйЭлемент.RowType = 2 Then
	//		
	//		БазоваяЧастьИмени = НайтиБазовуюЧастьИмени(КопируемыйЭлемент.Name);
	//		
	//		If БазоваяЧастьИмени = "" Then
	//			
	//			БазоваяЧастьИмени = NStr("ru='Setting'");
	//			
	//		EndIf;
	//		
	//		НовоеИмя = СгенерироватьИмяСервер(2, БазоваяЧастьИмени, КопируемыйЭлемент.GetParent().GetItems(), False);
	//		
	//	ElsIf КопируемыйЭлемент.RowType = 3 Then 
	//		
	//		БазоваяЧастьИмени = НайтиБазовуюЧастьИмени(КопируемыйЭлемент.Name);
	//		
	//		If БазоваяЧастьИмени = "" Then
	//			
	//			БазоваяЧастьИмени = NStr("ru='Folder'");
	//			
	//		EndIf;
	//		
	//		НовоеИмя = СгенерироватьИмяСервер(3, БазоваяЧастьИмени, КопируемыйЭлемент.GetParent().GetItems(), False);
	//		
	//	EndIf;
	НовыйЭлемент = КопируемыйЭлемент.GetParent().GetItems().Add();
	FillPropertyValues(НовыйЭлемент, КопируемыйЭлемент);
	НовыйЭлемент.Name = НовоеИмя;
	Items.ReportsTree.CurrentRow = НовыйЭлемент.GetID();
	ЗагрузитьТекущуюСтрокуНаСервере();
	CurrentRow = НовыйЭлемент.GetID();

EndProcedure

// Выполнить на сервере отчет на основании текста макета компоновки данных.
&AtServer
Procedure ВыполнитьНаСервереИзМакетаКомпоновкиДанных()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplate);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВТабличныйДокумент(DataCompositionTemplate, Undefined);
	ОтобразитьПанельРезультатов();
	Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument;

EndProcedure

// Выполнить отчет в коллекцию значений на основании текста макета компоновки данных.
&AtServer
Procedure ВыполнитьНаСервереИзМакетаКомпоновкиДанныхВКоллекцию()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplateForCollection);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
	ОтобразитьПанельРезультатов();
	Items.ResultsPanel.CurrentPage = Items.PageResultCollection;

EndProcedure

// Выполнить отчет в виде XML на основании текста макета компоновки данных.
&AtServer
Procedure ВыполнитьВРезультатНаСервереИзМакетаКомпоновкиДанных()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplate);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, Undefined);
	ОтобразитьПанельРезультатов();
	Items.ResultsPanel.CurrentPage = Items.PageDataCompositionResultXML;

EndProcedure

// Выполнить отчет в виде XML в коллекцию значений для макета компоновки данных.
&AtServer
Procedure ВыполнитьВРезультатКоллекцияНаСервереИзМакетаКомпоновкиДанных()

	ReportNeedsToGenerate = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionTemplateForCollection);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
	ОтобразитьПанельРезультатов();
	Items.ResultsPanel.CurrentPage = Items.PageResultCollectionXML;

EndProcedure

// Получить имя файла эталона табличного документа.
//
// Возвращаемое значение:
//  Строка - имя файла эталона табличного документа.
&AtClient
Function ИмяФайлаЭталонаТабличногоДокумента()

	Var FileName;

	FileName = NStr("ru='Эталон табличного документа.mxl'");

	If FileName = "" Then

		FileName = "Эталон табличного документа.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла табличного документа.
//
// Возвращаемое значение:
//  Строка - имя файла табличного документа.
&AtClient
Function ИмяФайлаТабличногоДокумента()

	Var FileName;

	FileName = NStr("ru='Табличный документ.xml'");

	If FileName = "" Then

		FileName = "Табличный документ.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла эталона макета.
//
// Возвращаемое значение:
//  Строка - имя файла эталона макета
&AtClient
Function ИмяФайлаЭталонаМакета()

	Var FileName;

	FileName = NStr("ru='Эталон макета.xml'");

	If FileName = "" Then

		FileName = "Эталон макета.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла макета.
//
// Возвращаемое значение
//  Строка - имя файла макета.
&AtClient
Function ИмяФайлаМакета()

	Var FileName;

	FileName = NStr("ru='Template.xml'");

	If FileName = "" Then

		FileName = "Template.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя	файла эталона исполняемых настроек.
//
// Возвращаемое значение:
//  Строка - имя файла эталона исполняемых настроек.
&AtClient
Function ИмяФайлаЭталонаИсполняемыхНастроек()

	Var FileName;

	FileName = NStr("ru='Эталон исполняемых настроек.xml'");

	If FileName = "" Then

		FileName = "Эталон исполняемых настроек.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла исполняемых настроек.
//
// Возвращаемое значение:
//  Строка - имя файла исполняемых настроек.
&AtClient
Function ИмяФайлаИсполняемыхНастроек()

	Var FileName;

	FileName = NStr("ru='Исполняемые Settings.xml'");

	If FileName = "" Then

		FileName = "Исполняемые Settings.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла эталона результата XML.
// 
// Возвращаемое значение:
//  Строка - имя файла эталона результата XML.
&AtClient
Function ИмяФайлаЭталонаРезультатаXML()

	Var FileName;

	FileName = NStr("ru='Эталон результата.xml'");

	If FileName = "" Then

		FileName = "Эталон результата.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла результата XML.
//
// Возвращаемое значение:
//  Строка - имя файла результата XML.
&AtClient
Function ИмяФайлаРезультатаXML()

	Var FileName;

	FileName = NStr("ru='Result.xml'");

	If FileName = "" Then

		FileName = "Result.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла эталона макета для коллекции.
//
// Возвращаемое значение:
//  Строка - имя файла эталона макета для коллекции.
&AtClient
Function ИмяФайлаЭталонаМакетаДляКоллекции()

	Var FileName;

	FileName = NStr("ru='Эталон макета для коллекции.xml'");

	If FileName = "" Then

		FileName = "Эталон макета для коллекции.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла макета для коллекции.
//
// Возвращаемое значение:
//  Строка - имя файла макета для коллекции.
&AtClient
Function ИмяФайлаМакетаДляКоллекции()

	Var FileName;

	FileName = NStr("ru='Template для коллекции.xml'");

	If FileName = "" Then

		FileName = "Template для коллекции.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла эталона результата XML для коллекции.
//
// Возвращаемое значение:
//  Строка - имя файла эталона результата XML для коллекции.
&AtClient
Function ИмяФайлаЭталонаРезультатаXMLДляКоллекции()

	Var FileName;

	FileName = NStr("ru='Эталон результата для коллекции.xml'");

	If FileName = "" Then

		FileName = "Эталон результата для коллекции.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Получить имя файла результата XML для коллекции.
//
// Возвращаемое значение:
//  Строка - имя файла результата XML для коллекции.
&AtClient
Function ИмяФайлаРезультатаXMLДляКоллекции()

	Var FileName;

	FileName = NStr("ru='Result для коллекции.xml'");

	If FileName = "" Then

		FileName = "Result для коллекции.xml";

	EndIf;

	Return TempFilesDir() + FileName;

EndFunction

// Вывести результат из текста результата в табличный документ.
&AtServer
Procedure ВывестиРезультатИзТекстаРезультатаВТабличныйДокумент()

	ReportNeedsToGenerate = False;
	ResultSpreadsheetDocument.Clear();
	ПроцессорВыводаРезультатаОтчета = New DataCompositionResultSpreadsheetDocumentOutputProcessor;
	ПроцессорВыводаРезультатаОтчета.SetDocument(ResultSpreadsheetDocument);
	ПроцессорВыводаРезультатаОтчета.BeginOutput();

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionResult);
	XMLReader.Read(); // resultAndDetailsInfo
	XMLReader.Read(); // result
	XMLReader.Read(); // item
	While XMLReader.NodeType = XMLNodeType.StartElement And XMLReader.Name = "item" Do

		If XMLReader.NodeType = XMLNodeType.StartElement Then // item
			ЭлементРезультата = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionResultItem"));
			ПроцессорВыводаРезультатаОтчета.OutputItem(ЭлементРезультата);

		Else

			Break;

		EndIf;

	EndDo;

	ПроцессорВыводаРезультатаОтчета.EndOutput();
	ОтобразитьПанельРезультатов();
	Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument;

EndProcedure

// Вывести результат из текста результата в коллекцию.
&AtServer
Procedure ВывестиРезультатИзТекстаРезультатаВКоллекцию()

	ReportNeedsToGenerate = False;
	ПроцессорВыводаРезультатаОтчета = New DataCompositionResultValueCollectionOutputProcessor;
	ПроцессорВыводаРезультатаОтчета.SetObject(New ValueTree);
	ПроцессорВыводаРезультатаОтчета.BeginOutput();

	XMLReader = New XMLReader;
	XMLReader.SetString(TextOfDataCompositionResultForCollection);
	XMLReader.Read(); // resultAndDetailsInfo
	XMLReader.Read(); // result
	XMLReader.Read(); // item
	While XMLReader.NodeType = XMLNodeType.StartElement And XMLReader.Name = "item" Do

		If XMLReader.NodeType = XMLNodeType.StartElement Then // item
			ЭлементРезультата = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionResultItem"));
			ПроцессорВыводаРезультатаОтчета.OutputItem(ЭлементРезультата);

		Else

			Break;

		EndIf;

	EndDo;

	ВывестиДеревоРезультатВКоллекцию(ПроцессорВыводаРезультатаОтчета.EndOutput());
	ОтобразитьПанельРезультатов();
	Items.ResultsPanel.CurrentPage = Items.PageResultCollection;

EndProcedure

// Загрузить схему компоновки данных из временного хранилища в текущую строку
&AtServer
Procedure ЗагрузитьФайлСхемыКомпоновкиДанныхНаСервере(Address)

	ИмяВременногоФайла = GetTempFileName();
	Data = GetFromTempStorage(Address);
	Data.Write(ИмяВременногоФайла);
	TextReader = New TextReader(ИмяВременногоФайла);
	Modified = True;
	ReportsTree.FindByID(Items.ReportsTree.CurrentRow).Data = TextReader.Read();

EndProcedure

// Загрузить схему компоновки данных из временного хранилища в текущую строку
&AtServer
Function ПоместитьСхемуКомпоновкиДанныхВоВременноеХранилище()

	ИмяВременногоФайла = GetTempFileName();
	TextWriter = New TextWriter(ИмяВременногоФайла);
	TextWriter.Write(ReportsTree.FindByID(Items.ReportsTree.CurrentRow).Data);
	TextWriter.Close();
	Result = PutToTempStorage(New BinaryData(ИмяВременногоФайла));
	Return Result;

EndFunction

&AtServer
Procedure ЗаполнитьСКДДляОтладки(АдресДанныхОтладки)
	ДанныеДляОтладки = GetFromTempStorage(АдресДанныхОтладки);
	ЭлементыДерева = ReportsTree.GetItems();
	ЭлементыДерева.Clear();

	КорневойЭлемент = ЭлементыДерева.Add();
	КорневойЭлемент.RowType = 4;
	КорневойЭлемент.Name = NStr("ru='Reports'");

	ЭлементыВКоторыеДобавляем = КорневойЭлемент.GetItems();

	Name = "Report для отладки";
	Item = ЭлементыВКоторыеДобавляем.Add();
	Item.Name = Name;
	Item.RowType = 0;

	Item.Data = ДанныеДляОтладки.ТекстСКД;
	Item.НастройкиСКД = ДанныеДляОтладки.DcsSettingsText;

	If ДанныеДляОтладки.Property("ExternalDataSets") Then
		For Each КлючЗначение ИЗ ДанныеДляОтладки.ExternalDataSets Do
			НС=Item.ExternalDataSets.Add();
			НС.Name=КлючЗначение.Key;
			НС.Value=КлючЗначение.Value;
			ТЗ=ValueFromStringInternal(НС.Value);
			НС.Presentation=StrTemplate("Строк: %1 Колонок: %2", ТЗ.Count(), ТЗ.Cols.Count());
		EndDo;
	EndIf;
	
	FileName = "";

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

// Обработчик события формы OnCreateAtServer.
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	Var ВременныйУзел;

	InitialTitle = Title;
	ИнициализироватьДеревоОтчетов(ReportsTree);
	НастройкиКонсоли = CommonSettingsStorage.Load("НастройкиКонсолиСистемыОтчетности5");

	If НастройкиКонсоли <> Undefined Then

		НастройкиКонсоли.Property("FileName", FileName);
		НастройкиКонсоли.Property("CurrentNode", ВременныйУзел);

		If TypeOf(ВременныйУзел) = Type("ValueList") Then

			CurrentNode = ВременныйУзел;

		EndIf;

	EndIf;

	DetailsFormName = "Report.UT_ReportsConsole.Form.DetailsForm";

	Items.Settings.Check = True;
	Items.ButtonResultsPanel.Check = True;

	If Parameters.Property("ДанныеОтладки") Then
		ЗаполнитьСКДДляОтладки(Parameters.ДанныеОтладки);
		Return;
	EndIf;
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.MainCommandBar);

EndProcedure

// Обработка события Выбор. Вызывается из конструктора схемы компоновки данных.
&AtClient
Procedure ChoiceProcessing(ВыбранноеЗначение, ИсточникВыбора)

	Modified = True;
	УстановитьСхемуКомпоновкиДанныхКлиент(ВыбранноеЗначение);
EndProcedure

// Обработка события ПередЗакрытием.
&AtClient
Procedure BeforeClose(Cancel, StandardProcessing)

	If Modified Then
		Cancel = True;
		ПодтвердитьЗакрытие(New NotifyDescription("ПередЗакрытиемЗавершение", ThisForm));
	EndIf;

EndProcedure

// Завершение обработки закрытия.
&AtClient
Procedure ПередЗакрытиемЗавершение(Result, AdditionalParameters) Export
	If Result Then
		Modified = False;
		Close();
	EndIf;
EndProcedure

// Обработчик события ПриЗакрытии.
&AtClient
Procedure OnClose()

	СохранитьНастройкиКонсоли();

EndProcedure

// Обработчик события OnOpen.
&AtClient
Procedure OnOpen(Cancel)

	If FileName <> "" Then

		ЗагружаемоеИмяФайла = FileName;
		FileName = "";
		Try
			ЗагрузитьФайлКонсоли(ЗагружаемоеИмяФайла);
		Except
			UT_CommonClientServer.MessageToUser("Error загрузки отчетов из файла");
		EndTry;
	EndIf;

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ КОМАНД

// Обработчик команды AddDataCompositionSchema.
&AtClient
Procedure AddDataCompositionSchema(Command)

	Var ЭлементыВКоторыеДобавляем;
	Var ТекущийЭлементДерева;

	Modified = True;

	If Items.ReportsTree.CurrentRow <> Undefined Then

		ТекущийЭлементДерева = ReportsTree.FindByID(Items.ReportsTree.CurrentRow);

	EndIf;

	While ТекущийЭлементДерева <> Undefined Do

		If ТекущийЭлементДерева.RowType = 0 Or (ТекущийЭлементДерева.RowType = 3 And ТипПапки(
			ТекущийЭлементДерева) = 4) Or ТекущийЭлементДерева.RowType = 4 Then

			Break;

		Else

			ТекущийЭлементДерева = ТекущийЭлементДерева.GetParent();

		EndIf;

	EndDo;

	If ТекущийЭлементДерева <> Undefined Then

		If ТекущийЭлементДерева.RowType = 3 Or ТекущийЭлементДерева.RowType = 4 Then

				// Folder или корень.
			ЭлементыВКоторыеДобавляем = ТекущийЭлементДерева.GetItems();

		ElsIf ТекущийЭлементДерева.GetParent() <> Undefined Then

			ЭлементыВКоторыеДобавляем = ТекущийЭлементДерева.GetParent().GetItems();

		Else

			ЭлементыВКоторыеДобавляем = ReportsTree.GetItems();

		EndIf;

	Else

		ЭлементыВКоторыеДобавляем = ReportsTree.GetItems();

	EndIf;

	Name = СгенерироватьИмяСхемыКомпоновкиДанных();
	Item = ЭлементыВКоторыеДобавляем.Add();
	Item.Name = Name;
	Item.RowType = 0;

	Items.ReportsTree.CurrentRow = Item.GetID();

EndProcedure

// Обработчик команды Generate.
&AtClient
Procedure Generate(Command)

	СформироватьКлиент();

EndProcedure

// Обработчик команды ResultsPanel.
&AtClient
Procedure ResultsPanel(Command)

	Items.ResultsPanel.Visible = Not Items.ResultsPanel.Visible;
	Items.ButtonResultsPanel.Check = Items.ResultsPanel.Visible;

EndProcedure

// Обработчик команды DataCompositionSchemaWizard.
&AtClient
Procedure DataCompositionSchemaWizard(Command)

	ОткрытьКонструкторСхемыКомпоновкиДанных();

EndProcedure

// Обработчик команды SaveReportsToFile.
&AtClient
Procedure SaveReportsToFile(Command)

//	СохранитьДанныеТекущейСтрокиИЗагрузитьТекущуюСтрокуНаСервере();
	СохранитьДанныеТекущейСтрокиНаСервере();
	Save(False, New NotifyDescription("СохранениеВФайлЗавершение", ThisForm));

EndProcedure

// Обработчик команды SaveReportsToFileAS.
&AtClient
Procedure SaveReportsToFileAS(Command)

	Save(True, New NotifyDescription("СохранениеВФайлЗавершение", ThisForm));

EndProcedure

// Завершение обработчика открытия файла.
&AtClient
Procedure СохранениеВФайлЗавершение(Result, AdditionalParameters) Export

	If Result Then
		Modified = False;
	EndIf;

EndProcedure

// Обработчик команды OpenReportsFile.
&AtClient
Procedure OpenReportsFile(Command)

	ПодтвердитьЗакрытие(New NotifyDescription("ОткрытьФайлОтчетовЗавершение", ThisForm));

EndProcedure

// Завершение обработчика открытия файла.
&AtClient
Procedure ОткрытьФайлОтчетовЗавершение(Result, AdditionalParameters) Export

	If Result Then
		Modified = False;
		ЗагрузитьФайлКонсоли("");
	EndIf;

EndProcedure

// Обработчик команды NewReportsFile.
&AtClient
Procedure NewReportsFile(Command)

	ПодтвердитьЗакрытие(New NotifyDescription("НовыйФайлОтчетовЗавершение", ThisForm));

EndProcedure

// Завершение обработчика создания нового файла отчетов.
&AtClient
Procedure НовыйФайлОтчетовЗавершение(Result, AdditionalParameters) Export

	If Result Then

		Modified = False;
		ИнициализироватьДеревоОтчетов(ReportsTree);
		FileName = "";
		ОбновитьЗаголовок();
		CurrentRow = Undefined;
		CurrentRowSettingsIsChanged = False;

	EndIf;

EndProcedure

// Обработчик команды OutputToSpreadsheetDocumentForCurrentTemplate.
&AtClient
Procedure OutputToSpreadsheetDocumentForCurrentTemplate(Command)

	ВыполнитьНаСервереИзМакетаКомпоновкиДанных();

EndProcedure

// Обработчик команды SaveStandartSpreadsheetDocument.
&AtClient
Procedure SaveStandartSpreadsheetDocument(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	ResultSpreadsheetDocument.BeginWriting(Undefined, ИмяФайлаЭталонаТабличногоДокумента());
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartSpreadsheetDocument.
&AtClient
Procedure CompareWithStandartSpreadsheetDocument(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	ResultSpreadsheetDocument.BeginWriting(New NotifyDescription("СравнитьСЭталономТабличныйДокументЗавершение",
		ThisForm), ИмяФайлаТабличногоДокумента());
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

&AtClient
Procedure СравнитьСЭталономТабличныйДокументЗавершение(Result, AdditionalParameters) Export
#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаТабличногоДокумента();
	FileCompare.SecondFile = ИмяФайлаТабличногоДокумента();
	FileCompare.CompareMethod = FileCompareMethod.SpreadsheetDocument;
	FileCompare.ShowDifferences();
#Else
	Message(NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));

#EndIf
EndProcedure

// Обработчик команды SaveStandartOfDataCompositionTemplate.
&AtClient
Procedure SaveStandartOfDataCompositionTemplate(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаМакета(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplate);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartDataCompositionTemplate.
&AtClient
Procedure CompareWithStandartDataCompositionTemplate(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаМакета(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplate);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаМакета();
	FileCompare.SecondFile = ИмяФайлаМакета();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды SaveStandartExecutableSettings.
&AtClient
Procedure SaveStandartExecutableSettings(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаИсполняемыхНастроек(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ExecutedSettingsXML);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartExecutableSettings.
&AtClient
Procedure CompareWithStandartExecutableSettings(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаИсполняемыхНастроек(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ExecutedSettingsXML);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаИсполняемыхНастроек();
	FileCompare.SecondFile = ИмяФайлаИсполняемыхНастроек();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды SaveStandartXMLResult.
&AtClient
Procedure SaveStandartXMLResult(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаРезультатаXML(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResult);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartXMLResult.
&AtClient
Procedure CompareWithStandartXMLResult(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаРезультатаXML(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResult);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаРезультатаXML();
	FileCompare.SecondFile = ИмяФайлаРезультатаXML();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды SaveStandartDataCompositionTemplateForTemplate.
&AtClient
Procedure SaveStandartDataCompositionTemplateForTemplate(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаМакетаДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplateForCollection);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartDataCompositionTemplateForCollection.
&AtClient
Procedure CompareWithStandartDataCompositionTemplateForCollection(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаМакетаДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionTemplateForCollection);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаМакетаДляКоллекции();
	FileCompare.SecondFile = ИмяФайлаМакетаДляКоллекции();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды SaveStandartXMLResultForCollection.
&AtClient
Procedure SaveStandartXMLResultForCollection(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаРезультатаXMLДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResultForCollection);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды CompareWithStandartXMLResultForCollection.
&AtClient
Procedure CompareWithStandartXMLResultForCollection(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаРезультатаXMLДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(TextOfDataCompositionResultForCollection);
	TextWriter.Close();

	FileCompare = New FileCompare;
	FileCompare.FirstFile = ИмяФайлаЭталонаРезультатаXMLДляКоллекции();
	FileCompare.SecondFile = ИмяФайлаРезультатаXMLДляКоллекции();
	FileCompare.CompareMethod = FileCompareMethod.TextDocument;
	FileCompare.ShowDifferences();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды OutputToResultForCurrentTemplate.
&AtClient
Procedure OutputToResultForCurrentTemplate(Command)

	ВыполнитьВРезультатНаСервереИзМакетаКомпоновкиДанных();

EndProcedure

// Обработчик команды OutputResultToSpreadsheetDocument.
&AtClient
Procedure OutputResultToSpreadsheetDocument(Command)

	ВывестиРезультатИзТекстаРезультатаВТабличныйДокумент();

EndProcedure

// Обработчик команды OutputToCollectionForCurrentTemplate.
&AtClient
Procedure OutputToCollectionForCurrentTemplate(Command)

	ВыполнитьНаСервереИзМакетаКомпоновкиДанныхВКоллекцию();

EndProcedure

// Обработчик команды OutputToCollectionResultForCurrentTemplate.
&AtClient
Procedure OutputToCollectionResultForCurrentTemplate(Command)

	ВыполнитьВРезультатКоллекцияНаСервереИзМакетаКомпоновкиДанных();

EndProcedure

// Обработчик команды OutputResultToCollection.
&AtClient
Procedure OutputResultToCollection(Command)

	ВывестиРезультатИзТекстаРезультатаВКоллекцию();

EndProcedure

// Обработчик команды SaveSchemaToFile
&AtClient
Procedure SaveSchemaToFile(Command)

	BeginAttachingFileSystemExtension(New NotifyDescription("СохранитьСхемуВФайлПослеПодключенияРасширения",
		ThisForm));

EndProcedure

// Обработчик сохранения схемы в File после подключения расширения работы с файлами.
&AtClient
Procedure СохранитьСхемуВФайлПослеПодключенияРасширения(Подключено, AdditionalParameters) Export

	If Подключено Then

	// Нужно запросить имя файла.
		ВыборФайла = New FileDialog(FileDialogMode.Save);
		ВыборФайла.Multiselect = False;
		Filter = NStr("ru = 'File схемы компоновки данных (*.xml)|*.xml|All файлы (*.*)|*.*'");
		ВыборФайла.Filter = Filter;
		ВыборФайла.Extension = "xml";

		ВыборФайла.Show(New NotifyDescription("СохранитьСхемуВФайлПослеВыбораФайла", ThisForm,
			New Structure("ВыборФайла", ВыборФайла)));

	Else

		GetFile(ПоместитьСхемуКомпоновкиДанныхВоВременноеХранилище(), , True);

	EndIf;

EndProcedure

// Обработчик сохранния схемы в File после выбора файла сохранения.
&AtClient
Procedure СохранитьСхемуВФайлПослеВыбораФайла(SelectedFiles, AdditionalParameters) Export

	ВыборФайла = AdditionalParameters.ВыборФайла;

	If SelectedFiles = Undefined Then

		Return;

	EndIf;

	ПолучаемыеФайлы = New Array;
	ПолучаемыеФайлы.Add(New TransferableFileDescription(ВыборФайла.FullFileName,
		ПоместитьСхемуКомпоновкиДанныхВоВременноеХранилище()));
	BeginGettingFiles(New NotifyDescription("СохранитьСхемуВФайлЗавершение", ThisForm), ПолучаемыеФайлы, "",
		False);

EndProcedure

&AtClient
Procedure СохранитьСхемуВФайлЗавершение(ПолученныеФайлы, AdditionalParameters) Export

	ОбновитьЗаголовок();

EndProcedure

// Обработчик команды LoadSchemaFromFile
&AtClient
Procedure LoadSchemaFromFile(Command)

	Var Address;

	BeginAttachingFileSystemExtension(
		New NotifyDescription("ЗагрузитьСхемуИзФайлаПослеПодключенияРасширения", ThisForm, New Structure("Address",
		Address)));
EndProcedure

// Обработчик загрузки схемы из файла после подключения расширения.
&AtClient
Procedure ЗагрузитьСхемуИзФайлаПослеПодключенияРасширения(Подключено, AdditionalParameters) Export

	Address = AdditionalParameters.Address;

	If Подключено Then

		ВыборФайла = New FileDialog(FileDialogMode.Opening);
		ВыборФайла.Multiselect = False;
		Filter = NStr("ru = 'File схемы компоновки данных (*.xml)|*.xml|All файлы (*.*)|*.*'");
		ВыборФайла.Filter = Filter;
		ВыборФайла.Extension = "xml";

		BeginPuttingFiles(New NotifyDescription("ЗагрузитьСхемуИзФайлаПослеПомещенияФайлов", ThisForm), ,
			ВыборФайла);

	Else

		BeginPutFile(New NotifyDescription("ЗагрузитьСхемуИзФайлаПослеПомещенияФайла", ThisForm,
			New Structure("Address", Address)), Address, , True);

	EndIf;

EndProcedure

// Обработчик загрузки схемы из файла после помещения файлов.
&AtClient
Procedure ЗагрузитьСхемуИзФайлаПослеПомещенияФайлов(ПомещенныеФайлы, AdditionalParameters) Export

	If ПомещенныеФайлы = Undefined Then

		Return;

	EndIf;

	For Each ПомещенныйФайл In ПомещенныеФайлы Do

		If ПомещенныйФайл.Location <> "" Then

			Address = ПомещенныйФайл.Location;
			Break;

		EndIf;

	EndDo;

	ЗагрузитьФайлСхемыКомпоновкиДанныхНаСервере(Address);

EndProcedure

// Обработчик загрузки схемы из файла после помещения файла.
&AtClient
Procedure ЗагрузитьСхемуИзФайлаПослеПомещенияФайла(Result, Address, ВыбранноеИмяФайла, AdditionalParameters) Export

	Address = AdditionalParameters.Address;

	If Not Result Then

		Return;

	EndIf;

	ЗагрузитьФайлСхемыКомпоновкиДанныхНаСервере(Address);

EndProcedure

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ РЕКВИЗИТОВ ФОРМЫ

// Обработчик события ПриАктивизацииПоля таблицы Structure.
// Активизирует страницу настроек в зависимости от того, какую колонку
// активировал пользователь.
&AtClient
Procedure StructureOnActivateField(Item)
	
	Var ВыбраннаяСтраница;

	If Items.Structure.CurrentItem.Name = "СтруктураНаличиеВыбора" Then

		ВыбраннаяСтраница = Items.PageSelectedFields;

	ElsIf Items.Structure.CurrentItem.Name = "СтруктураНаличиеОтбора" Then

		ВыбраннаяСтраница = Items.PageFilter;

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


// Обработчик события ПриАктивизацииПоля таблицы Structure1.
// Активизирует страницу настроек в зависимости от того, какую колонку
// активировал пользователь.
&AtClient
Procedure СтруктураПриАктивизацииПоля1(Item)

	Var ВыбраннаяСтраница;

	If Items.Settings1.CurrentItem.Name = "Structure1НаличиеВыбора" Then

		ВыбраннаяСтраница = Items.СтраницаПолейВыбора1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1НаличиеОтбора" Then

		ВыбраннаяСтраница = Items.FilterPage1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1НаличиеПорядка" Then

		ВыбраннаяСтраница = Items.OrderPage1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1НаличиеУсловногоОформления" Then

		ВыбраннаяСтраница = Items.ConditionalAppearancePage1;

	ElsIf Items.Settings1.CurrentItem.Name = "Structure1НаличиеПараметровВывода" Then

		ВыбраннаяСтраница = Items.OutputParametersPage1;

	EndIf;

	If ВыбраннаяСтраница <> Undefined Then

		Items.PagesSettings1.CurrentPage = ВыбраннаяСтраница;

	EndIf;

EndProcedure

// Обработчик СтруктураПриАктивизацииСтроки элемента Structure.
// Приводит закладки с настройками в актуальное состояние
&AtClient
Procedure StructureOnActivateRow(Item)
	//TODO: Insert the handler content
	ТекСтрокаДерева = Items.Structure.CurrentRow;
	If ТекСтрокаДерева = Undefined Then
		Return;
	EndIf;

	ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(ТекСтрокаДерева);
	ItemType = TypeOf(ЭлементСтруктуры);

	If ItemType = Undefined Or ItemType = Type("DataCompositionChartStructureItemCollection")
		Or ItemType = Type("DataCompositionTableStructureItemCollection") Then

		GroupFieldsNotAvailable();
		SelectedFieldsUnavailable();
		FilterUnavailable();
		OrderUnavailable();
		ConditionalAppearanceUnavailable();
		OutputParametersUnavailable();

	ElsIf ItemType = Type("DataCompositionSettings") Or ItemType = Type(
		"DataCompositionNestedObjectSettings") Then

		GroupFieldsNotAvailable();

		LocalSelectedFields = True;
		Items.LocalSelectedFields.ReadOnly = True;
		Items.PagesSelectedFields.CurrentPage = Items.SelectedFieldsSettings;

		LocalFilter = True;
		Items.LocalFilter.ReadOnly = True;
		Items.FilterPages.CurrentPage = Items.FilterSettings;

		LocalOrder = True;
		Items.LocalOrder.ReadOnly = True;
		Items.OrderPages.CurrentPage = Items.OrderSettings;

		LocalConditionalAppearance = True;
		Items.LocalConditionalAppearance.ReadOnly = True;
		Items.ConditionalAppearancePages.CurrentPage = Items.ConditionalAppearanceSettings;

		LocalOutputParameters = True;
		Items.LocalOutputParameters.ReadOnly = True;
		Items.OutputParametersPages.CurrentPage = Items.OutputParametersSettings;

	ElsIf ItemType = Type("DataCompositionGroup") Or ItemType = Type(
		"DataCompositionTableGroup") Or ItemType = Type("DataCompositionChartGroup") Then

		Items.PagesGroupFields.CurrentPage = Items.GroupFieldsSettings;

		SelectedFieldsAvailable(ЭлементСтруктуры);
		FilterAvailable(ЭлементСтруктуры);
		OrderAvailable(ЭлементСтруктуры);
		ConditionalAppearanceAvailable(ЭлементСтруктуры);
		OutputParametersAvailable(ЭлементСтруктуры);

	ElsIf ItemType = Type("DataCompositionTable") Or ItemType = Type("DataCompositionChart") Then

		GroupFieldsNotAvailable();
		SelectedFieldsAvailable(ЭлементСтруктуры);
		FilterUnavailable();
		OrderUnavailable();
		ConditionalAppearanceAvailable(ЭлементСтруктуры);
		OutputParametersAvailable(ЭлементСтруктуры);

	EndIf;
EndProcedure


// Обработчик СтруктураПриАктивизацииСтроки элемента Structure1.
// Приводит закладки с настройками в актуальное состояние
&AtClient
Procedure СтруктураПриАктивизацииСтроки1(Item)

	ЭлементСтруктуры = ExecutedSettingsComposer.Settings.GetObjectByID(
		Items.Settings1.CurrentRow);
	ItemType = TypeOf(ЭлементСтруктуры);

	If ItemType = Undefined Or ItemType = Type("DataCompositionChartStructureItemCollection")
		Or ItemType = Type("DataCompositionTableStructureItemCollection") Then

		GroupFieldsNotAvailable1();
		SelectedFieldsUnavailable1();
		FilterUnavailable1();
		OrderUnavailable1();
		ConditionalAppearanceUnavailable1();
		OutputParametersUnavailable1();

	ElsIf ItemType = Type("DataCompositionSettings") Or ItemType = Type(
		"DataCompositionNestedObjectSettings") Then

		GroupFieldsNotAvailable1();

		LocalSelectedFields1 = True;
		Items.LocalSelectedFields1.ReadOnly = True;
		Items.PagesSelectedFields1.CurrentPage = Items.SelectedFieldsSettings1;

		LocalFilter1 = True;
		Items.LocalFilter1.ReadOnly = True;
		Items.FilterPages1.CurrentPage = Items.FilterSettings1;

		LocalOrder1 = True;
		Items.LocalOrder1.ReadOnly = True;
		Items.OrderPages1.CurrentPage = Items.OrderSettings1;

		LocalConditionalAppearance1 = True;
		Items.LocalConditionalAppearance1.ReadOnly = True;
		Items.ConditionalAppearancePages1.CurrentPage = Items.ConditionalAppearanceSettings1;

		LocalOutputParameters1 = True;
		Items.LocalOutputParameters1.ReadOnly = True;
		Items.OutputParametersPages1.CurrentPage = Items.OutputParametersSettings1;

	ElsIf ItemType = Type("DataCompositionGroup") Or ItemType = Type(
		"DataCompositionTableGroup") Or ItemType = Type("DataCompositionChartGroup") Then

		Items.GroupFieldsPages1.CurrentPage = Items.GroupFieldsSettings1;

		SelectedFieldsAvailable1(ЭлементСтруктуры);
		FilterAvailable1(ЭлементСтруктуры);
		OrderAvailable1(ЭлементСтруктуры);
		ConditionalAppearanceAvailable1(ЭлементСтруктуры);
		OutputParametersAvailable1(ЭлементСтруктуры);

	ElsIf ItemType = Type("DataCompositionTable") Or ItemType = Type("DataCompositionChart") Then

		GroupFieldsNotAvailable1();
		SelectedFieldsAvailable1(ЭлементСтруктуры);
		FilterUnavailable1();
		OrderUnavailable1();
		ConditionalAppearanceAvailable1(ЭлементСтруктуры);
		OutputParametersAvailable1(ЭлементСтруктуры);

	EndIf;

EndProcedure

// Обработчик события Нажатие декораций.
&AtClient
Procedure GoToReport(Item)

	ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
		Items.Structure.CurrentRow);
	ItemSettings = Report.SettingsComposer.Settings.ItemSettings(ЭлементСтруктуры);
	Items.Structure.CurrentRow = Report.SettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

// Обработчик события Нажатие декораций для исполняемых настроек.
&AtClient
Procedure GoToReport1(Item)

	ЭлементСтруктуры = ExecutedSettingsComposer.Settings.GetObjectByID(
		Items.Settings1.CurrentRow);
	ItemSettings = ExecutedSettingsComposer.Settings.ItemSettings(ЭлементСтруктуры);
	Items.Settings1.CurrentRow = ExecutedSettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

// Обработчик события ПриИзменении флажка LocalSelectedFields.
&AtClient
Procedure LocalSelectedFieldsOnChange(Item)
		If LocalSelectedFields Then

		Items.PagesSelectedFields.CurrentPage = Items.SelectedFieldsSettings;

	Else

		Items.PagesSelectedFields.CurrentPage = Items.SelectedFieldsDisabledSettings;

		ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentRow);
		Report.SettingsComposer.Settings.ClearItemSelection(ЭлементСтруктуры);

	EndIf;
EndProcedure

// Обработчик события ПриИзменении флажка LocalSelectedFields1.
&AtClient
Procedure ЛокальныеВыбранныеПоляПриИзменении1(Item)

	If LocalSelectedFields1 Then

		Items.PagesSelectedFields1.CurrentPage = Items.SelectedFieldsSettings1;

	Else

		Items.PagesSelectedFields1.CurrentPage = Items.DisabledSelectedFieldsSettings1;

		ЭлементСтруктуры = ExecutedSettingsComposer.Settings.GetObjectByID(
			Items.Settings1.CurrentRow);
		ExecutedSettingsComposer.Settings.ClearItemSelection(ЭлементСтруктуры);

	EndIf;

EndProcedure

// Обработчик события ПриИзменении флажка LocalFilter.
&AtClient
Procedure LocalFilterOnChange(Item)
		If LocalFilter Then

		Items.FilterPages.CurrentPage = Items.FilterSettings;

	Else

		Items.FilterPages.CurrentPage = Items.DisabledFilterSettings;

		ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentRow);
		Report.SettingsComposer.Settings.ClearItemFilter(ЭлементСтруктуры);

	EndIf;
EndProcedure

// Обработчик события ПриИзменении флажка LocalFilter1.
&AtClient
Procedure ЛокальныйОтборПриИзменении1(Item)

	If LocalFilter1 Then

		Items.FilterPages1.CurrentPage = Items.FilterSettings1;

	Else

		Items.FilterPages1.CurrentPage = Items.DisabledFilterSettings1;

		ЭлементСтруктуры = ExecutedSettingsComposer.Settings.GetObjectByID(
			Items.Settings1.CurrentRow);
		ExecutedSettingsComposer.Settings.ClearItemFilter(ЭлементСтруктуры);

	EndIf;

EndProcedure

// Обработчик события ПриИзменении флажка LocalOrder.
&AtClient
Procedure LocalOrderOnChange(Item)
	
	If LocalOrder Then

		Items.OrderPages.CurrentPage = Items.OrderSettings;

	Else

		Items.OrderPages.CurrentPage = Items.DisabledOrderSettings;

		ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentRow);
		Report.SettingsComposer.Settings.ClearItemOrder(ЭлементСтруктуры);

	EndIf;
EndProcedure

// Обработчик события ПриИзменении флажка LocalOrder1.
&AtClient
Procedure ЛокальныйПорядокПриИзменении1(Item)

	If LocalOrder1 Then

		Items.OrderPages1.CurrentPage = Items.OrderSettings1;

	Else

		Items.OrderPages1.CurrentPage = Items.DisabledOrderSettings1;

		ЭлементСтруктуры = ExecutedSettingsComposer.Settings.GetObjectByID(
			Items.Settings1.CurrentRow);
		ExecutedSettingsComposer.Settings.ClearItemOrder(ЭлементСтруктуры);

	EndIf;

EndProcedure

// Обработчик события ПриИзменении флажка LocalConditionalAppearance.
&AtClient
Procedure LocalConditionalAppearanceOnChange(Item)
		If LocalConditionalAppearance Then

		Items.ConditionalAppearancePages.CurrentPage = Items.ConditionalAppearanceSettings;

	Else

		Items.ConditionalAppearancePages.CurrentPage = Items.DisabledConditionalAppearanceSettings;

		ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentRow);
		Report.SettingsComposer.Settings.ClearItemConditionalAppearance(ЭлементСтруктуры);

	EndIf;
EndProcedure

// Обработчик события ПриИзменении флажка LocalConditionalAppearance1.
&AtClient
Procedure ЛокальноеУсловноеОформлениеПриИзменении1(Item)

	If LocalConditionalAppearance1 Then

		Items.ConditionalAppearancePages1.CurrentPage = Items.ConditionalAppearanceSettings1;

	Else

		Items.ConditionalAppearancePages1.CurrentPage = Items.DisabledConditionalAppearanceSettings1;

		ЭлементСтруктуры = ExecutedSettingsComposer.Settings.GetObjectByID(
			Items.Settings1.CurrentRow);
		ExecutedSettingsComposer.Settings.ClearItemConditionalAppearance(ЭлементСтруктуры);

	EndIf;

EndProcedure

// Обработчик события ПриИзменении флажка LocalOutputParameters.
&AtClient
Procedure LocalOutputParametersOnChange(Item)
		If LocalOutputParameters Then

		Items.OutputParametersPages.CurrentPage = Items.OutputParametersSettings;

	Else

		Items.OutputParametersPages.CurrentPage = Items.DisabledOutputParametersSettings;

		ЭлементСтруктуры = Report.SettingsComposer.Settings.GetObjectByID(
			Items.Structure.CurrentRow);
		Report.SettingsComposer.Settings.ClearItemOutputParameters(ЭлементСтруктуры);
	EndIf;
EndProcedure

// Обработчик события ПриИзменении флажка LocalOutputParameters1.
&AtClient
Procedure ЛокальныеПараметрыВыводаПриИзменении1(Item)

	If LocalOutputParameters1 Then

		Items.OutputParametersPages1.CurrentPage = Items.OutputParametersSettings1;

	Else

		Items.OutputParametersPages1.CurrentPage = Items.DisabledOutputParametersSettings1;

		ЭлементСтруктуры = ExecutedSettingsComposer.Settings.GetObjectByID(
			Items.Settings1.CurrentRow);
		ExecutedSettingsComposer.Settings.ClearItemOutputParameters(ЭлементСтруктуры);
	EndIf;

EndProcedure

// Обработчик события ПриАктивизацииСтроки элемента ReportsTree.
// Отображает соответствующую закладку - схему, вариант, пользовательские Settings и т.п.
&AtClient
Procedure ReportsTreeOnActivateRow(Item)
	//TODO: Insert the handler content
	If Not RowIsBeingActivated And CurrentRow <> Item.CurrentRow Then

		RowIsBeingActivated = True;

		If Item.CurrentRow <> Undefined Then

			ЭлементДерева = ReportsTree.FindByID(Item.CurrentRow);

			If ЭлементДерева.RowType = 0 Then
			// Scheme компоновки данных.
				If Items.GroupSettings.CurrentPage <> Items.GroupVariant Then

					Items.GroupSettings.CurrentPage = Items.GroupVariant;

				EndIf;
				//				
				//			ElsIf ЭлементДерева.RowType = 1 Then
				//				// Variant отчета.
				//				If Items.GroupSettings.CurrentPage <> Items.GroupVariant Then
				//					
				//					Items.GroupSettings.CurrentPage = Items.GroupVariant;
				//					
				//				EndIf;
				//				
				//			ElsIf ЭлементДерева.RowType = 2 Then
				//				// Пользовательские Settings.
				//				If Items.GroupSettings.CurrentPage <> Items.GroupUserSettings Then
				//					
				//					Items.GroupSettings.CurrentPage = Items.GroupUserSettings;
				//					
				//				EndIf;
				//				
				//			Else
				// Неизвестный тип.
				//				If Items.GroupSettings.CurrentPage <> Items.ГруппаПустая Then
				//					
				//					Items.GroupSettings.CurrentPage = Items.ГруппаПустая;
				//					
				//				EndIf;
			EndIf;

		EndIf;

		Try

			СохранитьДанныеТекущейСтрокиИЗагрузитьТекущуюСтрокуНаСервере();
			CurrentRow = Item.CurrentRow;
			RowIsBeingActivated = False;

		Except

			CurrentRow = Undefined; // For того, чтобы не испортить Settings в дереве.
			RowIsBeingActivated = False;

		EndTry;

	EndIf;
EndProcedure

&AtClient
Procedure Settings(Command)
	ОтобразитьПанельНастроек();
EndProcedure

// Обработчик события ПриИзменении элементов, связанных с настройками.
&AtClient
Procedure SettingsOnChange(Item)
	CurrentRowSettingsIsChanged = True;
	Modified = True;
EndProcedure

&AtClient
Procedure SettingsDragEnd(Item, DragParameters, StandardProcessing)
	CurrentRowSettingsIsChanged = True;
	Modified = True;
EndProcedure

&AtClient
Procedure SettingsDrag(Item, DragParameters, StandardProcessing, Row, Field)
	CurrentRowSettingsIsChanged = True;
	Modified = True;
EndProcedure


// Обработчик события ПередНачаломДобавления элемента ReportsTree.
&AtClient
Procedure ReportsTreeBeforeAddRow(Item, Cancel, Clone, Parent, IsFolder, Parameter)
	
		If Clone Then

		Cancel = True;

		If ReportsTree.FindByID(Item.CurrentRow).RowType <> 4 Then
		// Not корень.
			СкопироватьНаСервере();

		EndIf;

	EndIf;
EndProcedure

// Обработчик события ПередУдалением элемента ReportsTree.
&AtClient
Procedure ДеревоОтчетовПередУдалением(Item, Cancel)

	CurrentRow = Undefined;

EndProcedure


&AtClient
Procedure ReportsTreeBeforeDeleteRow(Item, Cancel)
	CurrentRow = Undefined;
EndProcedure

// Обработчик события Выбор элемента ReportsTree.
&AtClient
Procedure ReportsTreeSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;
	СформироватьКлиент();
EndProcedure


// Обработчик события ОбработкаДополнительнойРасшифровки табличного документа ResultSpreadsheetDocument.
&AtClient
Procedure РезультатТабличныйДокументОбработкаДополнительнойРасшифровки(Item, Details, StandardProcessing)

	StandardProcessing = False;
	DetailProcessing = New DataCompositionDetailsProcess(DetailsDataURL,
		New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
	DetailProcessing.ShowActionChoice(
		New NotifyDescription("РезультатТабличныйДокументОбработкаРасшифровкиЗавершение", ThisForm,
		New Structure("Details", Details)), Details, , , , Items.ResultSpreadsheetDocument);

EndProcedure

// Обработчик события ОбработкаРасшифровки табличного документа ResultSpreadsheetDocument.
&AtClient
Procedure РезультатТабличныйДокументОбработкаРасшифровки(Item, Details, StandardProcessing)

	StandardProcessing = False;
	DetailProcessing = New DataCompositionDetailsProcess(DetailsDataURL,
		New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
	DetailProcessing.ShowActionChoice(
		New NotifyDescription("РезультатТабличныйДокументОбработкаРасшифровкиЗавершение", ThisForm,
		New Structure("Details", Details)), Details, , , True, );

EndProcedure

// Отработка выбора действия расшифровки.
&AtClient
Procedure РезультатТабличныйДокументОбработкаРасшифровкиЗавершение(ВыполненноеДействие, ПараметрВыполненногоДействия,
	AdditionalParameters) Export

	Details = AdditionalParameters.Details;

	If ВыполненноеДействие = DataCompositionDetailsProcessingAction.None Then

	ElsIf ВыполненноеДействие = DataCompositionDetailsProcessingAction.OpenValue Then

		ShowValue( , ПараметрВыполненногоДействия);

	ElsIf ВыполненноеДействие <> Undefined Then

		OpenForm(DetailsFormName, New Structure("Details,DataCompositionSchemaURL",
			New DataCompositionDetailsProcessDescription(DetailsDataURL, Details,
			ПараметрВыполненногоДействия), ExecutedReportSchemaURL), , True);

	EndIf;

EndProcedure

// Обработчик события ПриСменеСтраницы панели ResultsPanel.
&AtClient
Procedure ResultsPanelOnCurrentPageChange(Item, CurrentPage)
    If Items.ResultsPanel.CurrentPage = Items.PageResultSpreadsheetDocument Then

		If ReportNeedsToGenerate And Not ResultFilledSpreadsheetDocument Then

			Result = СформироватьНаСервереВТабличныйДокумент();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageDataCompositionTemplate Then

		If ReportNeedsToGenerate And Not ResultFilledTemplate Then

			Result = СформироватьНаСервереВМакетКомпоновкиДанных();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageExecutedSettings Then

		If ReportNeedsToGenerate And Not ResultFilledSettings Then

			Result = СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанных();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageExecutedSettingsXML Then

		If ReportNeedsToGenerate And Not ResultFilledSettingsXML Then

			Result = СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанныхXML();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageDataCompositionResultXML Then

		If ReportNeedsToGenerate And Not ResultFilledXML Then

			Result = СформироватьНаСервереВВидеXML();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageResultCollection Then

		If ReportNeedsToGenerate And Not ResultFilledCollection Then

			Result = СформироватьНаСервереВКоллекцию();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageTemplateForCollection Then

		If ReportNeedsToGenerate And Not ResultFilledTemplateForCollection Then

			Result = СформироватьНаСервереВМакетКомпоновкиДанныхДляКоллекции();

		EndIf;

	ElsIf Items.ResultsPanel.CurrentPage = Items.PageResultCollectionXML Then

		If ReportNeedsToGenerate And Not ResultFilledCollectionXML Then

			Result = СформироватьНаСервереВВидеXMLКоллекция();

		EndIf;

	EndIf;

	If Result <> Undefined Then

		ShowMessageBox( , Result);

	EndIf;
EndProcedure

// Обработчик события Выбор таблицы TreeResult.
&AtClient
Procedure РезультатДеревоВыбор(Item, SelectedRow, Field, StandardProcessing)

	Var Value;

	StandardProcessing = False;

	If Items.TreeResult.CurrentData.Property(Items.TreeResult.CurrentItem.Name, Value) Then

		ShowValue( , Value);

	EndIf;

EndProcedure

&AtClient
Procedure ExternalDataSetsPresentationStartChoice(Item, ChoiceData, StandardProcessing)
		StandardProcessing=False;
	ТекДанные=Items.ExternalDataSets.CurrentData;
	If ТекДанные=Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditValueTable(ТекДанные.Value, ThisObject,
		New NotifyDescription("ВнешниеНаборыДанныхПредставлениеНачалоВыбораЗавершение", ThisObject,New Structure("ТекСтрока",Items.ExternalDataSets.CurrentRow)));
EndProcedure

&AtClient
Procedure ВнешниеНаборыДанныхПредставлениеНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result=Undefined Then
		Return;
	EndIf;
	ТекСтрокаДерева=ReportsTree.FindByID(CurrentRow);
	If ТекСтрокаДерева=Undefined Then
		Return;
	EndIf;
	ТекДанныеСтроки=ТекСтрокаДерева.ExternalDataSets.FindByID(AdditionalParameters.ТекСтрока);
	ТекДанныеСтроки.Value=Result.Value;
	ТекДанныеСтроки.Presentation=Result.Presentation;
EndProcedure

&AtClient
Procedure ExternalDataSetsBeforeEditEnd(Item, NewRow, CancelEdit, Cancel)
	If CancelEdit Then
		Return;
	EndIf;	
		
	ТекДанные=Items.ExternalDataSets.CurrentData;
	If ТекДанные=Undefined Then
		Return;
	EndIf;
	ТекДанные.Name=TrimAll(ТекДанные.Name);
	
	If Not UT_CommonClientServer.IsCorrectVariableName(ТекДанные.Name) Then
		ShowMessageBox( ,
			UT_CommonClientServer.WrongVariableNameWarningText(),
			, Title);
		Cancel = True;
		Return;
	EndIf;
	
	ТекСтрокаДерева=ReportsTree.FindByID(CurrentRow);
	If ТекСтрокаДерева=Undefined Then
		Return;
	EndIf;

	
	маСтрокиИмени = ТекСтрокаДерева.ExternalDataSets.FindRows(New Structure("Name", ТекДанные.Name));
	If маСтрокиИмени.Count() > 1 Then
		ShowMessageBox( , "Column с таким именем уже есть! Введите другое имя.", , Title);
		Cancel = True;
		Return;
	EndIf;
EndProcedure

&AtServer
Function СтруктураВнешнихНаборовДанных()
	ВнешниеНаборы=New Structure;
	
	ТекСтрокаДерева=ReportsTree.FindByID(CurrentRow);
	If ТекСтрокаДерева=Undefined Then
		Return ВнешниеНаборы;
	EndIf;
		
	For Each Set ИЗ ТекСтрокаДерева.ExternalDataSets Do
		If ValueIsFilled(Set.Value) Then
			Try
				ТЗ=ValueFromStringInternal(Set.Value);
			Except
				ТЗ=New ValueTable;
			EndTry;
		Else
			ТЗ=New ValueTable;
		EndIf;
		ВнешниеНаборы.Insert(Set.Name, ТЗ);
	EndDo;
	Return ВнешниеНаборы;
EndFunction

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

////////////////////////////////////////////////////////////////////////////////