////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

// Инициализировать новое дерево отчетов.
&AtClientAtServerNoContext
Procedure ИнициализироватьДеревоОтчетов(ДеревоОтчетов)

	Items = ДеревоОтчетов.GetItems();
	Items.Clear();
	КорневойЭлемент = Items.Add();
	КорневойЭлемент.ТипСтроки = 4;
	КорневойЭлемент.Name = NStr("ru='Reports'");

	ЭлементыВКоторыеДобавляем = КорневойЭлемент.GetItems();

	Name = "Report";
	Item = ЭлементыВКоторыеДобавляем.Add();
	Item.Name = Name;
	Item.ТипСтроки = 0;

EndProcedure

// Переключить страницу группировок на страницу с текстом недоступности.
&AtClient
Procedure GroupFieldsNotAvailable()

	Items.СтраницыПолейГруппировки.CurrentPage = Items.НедоступныеНастройкиПолейГруппировки;

EndProcedure

// Переключить страницу группировок на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure GroupFieldsNotAvailable1()

	Items.СтраницыПолейГруппировки1.CurrentPage = Items.НедоступныеНастройкиПолейГруппировки1;

EndProcedure

// Включить доступность выбранных полей.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure SelectedFieldsAvailable(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemSelection(ЭлементСтруктуры) Then

		ЛокальныеВыбранныеПоля = True;
		Items.СтраницыПолейВыбора.CurrentPage = Items.НастройкиВыбранныхПолей;

	Else

		ЛокальныеВыбранныеПоля = False;
		Items.СтраницыПолейВыбора.CurrentPage = Items.ОтключенныеНастройкиВыбранныхПолей;

	EndIf;

	Items.ЛокальныеВыбранныеПоля.ReadOnly = False;

EndProcedure

// Включить доступность выбранных полей для исполняемых настроек.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure SelectedFieldsAvailable1(ЭлементСтруктуры)

	If ИсполняемыйКомпоновщикНастроек.Settings.HasItemSelection(ЭлементСтруктуры) Then

		ЛокальныеВыбранныеПоля1 = True;
		Items.СтраницыПолейВыбора1.CurrentPage = Items.НастройкиВыбранныхПолей1;

	Else

		ЛокальныеВыбранныеПоля1 = False;
		Items.СтраницыПолейВыбора1.CurrentPage = Items.ОтключенныеНастройкиВыбранныхПолей1;

	EndIf;

	Items.ЛокальныеВыбранныеПоля1.ReadOnly = False;

EndProcedure

// Переключить страницу выбранных полей на страницу с текстом недоступности.
&AtClient
Procedure SelectedFieldsUnavailable()

	ЛокальныеВыбранныеПоля = False;
	Items.ЛокальныеВыбранныеПоля.ReadOnly = True;
	Items.СтраницыПолейВыбора.CurrentPage = Items.НедоступныеНастройкиВыбранныхПолей;

EndProcedure

// Переключить страницу выбранных полей на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure SelectedFieldsUnavailable1()

	ЛокальныеВыбранныеПоля1 = False;
	Items.ЛокальныеВыбранныеПоля1.ReadOnly = True;
	Items.СтраницыПолейВыбора1.CurrentPage = Items.НедоступныеНастройкиВыбранныхПолей1;

EndProcedure

// Включить доступность отбора.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure FilterAvailable(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemFilter(ЭлементСтруктуры) Then

		ЛокальныйОтбор = True;
		Items.СтраницыОтбора.CurrentPage = Items.НастройкиОтбора;

	Else

		ЛокальныйОтбор = False;
		Items.СтраницыОтбора.CurrentPage = Items.ОтключенныеНастройкиОтбора;

	EndIf;

	Items.ЛокальныйОтбор.ReadOnly = False;

EndProcedure

// Включить доступность отбора для исполняемых настроек.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure FilterAvailable1(ЭлементСтруктуры)

	If ИсполняемыйКомпоновщикНастроек.Settings.HasItemFilter(ЭлементСтруктуры) Then

		ЛокальныйОтбор1 = True;
		Items.СтраницыОтбора1.CurrentPage = Items.НастройкиОтбора1;

	Else

		ЛокальныйОтбор1 = False;
		Items.СтраницыОтбора1.CurrentPage = Items.ОтключенныеНастройкиОтбора1;

	EndIf;

	Items.ЛокальныйОтбор1.ReadOnly = False;

EndProcedure

// Переключить страницу отбора на страницу с текстом недоступности.
&AtClient
Procedure FilterUnavailable()

	ЛокальныйОтбор = False;
	Items.ЛокальныйОтбор.ReadOnly = True;
	Items.СтраницыОтбора.CurrentPage = Items.НедоступныеНастройкиОтбора;

EndProcedure

// Переключить страницу отбора на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure FilterUnavailable1()

	ЛокальныйОтбор1 = False;
	Items.ЛокальныйОтбор1.ReadOnly = True;
	Items.СтраницыОтбора1.CurrentPage = Items.НедоступныеНастройкиОтбора1;

EndProcedure

// Включить доступность порядка.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure OrderAvailable(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemOrder(ЭлементСтруктуры) Then

		ЛокальныйПорядок = True;
		Items.СтраницыПорядка.CurrentPage = Items.НастройкиПорядка;

	Else

		ЛокальныйПорядок = False;
		Items.СтраницыПорядка.CurrentPage = Items.ОтключенныеНастройкиПорядка;

	EndIf;

	Items.ЛокальныйПорядок.ReadOnly = False;

EndProcedure

// Включить доступность порядка для исполняемых настроек.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure OrderAvailable1(ЭлементСтруктуры)

	If ИсполняемыйКомпоновщикНастроек.Settings.HasItemOrder(ЭлементСтруктуры) Then

		ЛокальныйПорядок1 = True;
		Items.СтраницыПорядка1.CurrentPage = Items.НастройкиПорядка1;

	Else

		ЛокальныйПорядок1 = False;
		Items.СтраницыПорядка1.CurrentPage = Items.ОтключенныеНастройкиПорядка1;

	EndIf;

	Items.ЛокальныйПорядок1.ReadOnly = False;

EndProcedure

// Переключить страницу порядка на страницу с текстом недоступности.
&AtClient
Procedure OrderUnavailable()

	ЛокальныйПорядок = False;
	Items.ЛокальныйПорядок.ReadOnly = True;
	Items.СтраницыПорядка.CurrentPage = Items.НедоступныеНастройкиПорядка;

EndProcedure

// Переключить страницу порядка на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure OrderUnavailable1()

	ЛокальныйПорядок1 = False;
	Items.ЛокальныйПорядок1.ReadOnly = True;
	Items.СтраницыПорядка1.CurrentPage = Items.НедоступныеНастройкиПорядка1;

EndProcedure

// Включить доступность условного оформления.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure ConditionalAppearanceAvailable(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemConditionalAppearance(ЭлементСтруктуры) Then

		ЛокальноеУсловноеОформление = True;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.НастройкиУсловногоОформления;

	Else

		ЛокальноеУсловноеОформление = False;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.ОтключенныеНастройкиУсловногоОформления;

	EndIf;

	Items.ЛокальноеУсловноеОформление.ReadOnly = False;

EndProcedure

// Включить доступность условного оформления для исполняемых настроек.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure ConditionalAppearanceAvailable1(ЭлементСтруктуры)

	If ИсполняемыйКомпоновщикНастроек.Settings.HasItemConditionalAppearance(ЭлементСтруктуры) Then

		ЛокальноеУсловноеОформление1 = True;
		Items.СтраницыУсловногоОформления1.CurrentPage = Items.НастройкиУсловногоОформления1;

	Else

		ЛокальноеУсловноеОформление1 = False;
		Items.СтраницыУсловногоОформления1.CurrentPage = Items.ОтключенныеНастройкиУсловногоОформления1;

	EndIf;

	Items.ЛокальноеУсловноеОформление1.ReadOnly = False;

EndProcedure

// Переключить страницу условного оформления на страницу с текстом недоступности.
&AtClient
Procedure ConditionalAppearanceUnavailable()

	ЛокальноеУсловноеОформление = False;
	Items.ЛокальноеУсловноеОформление.ReadOnly = True;
	Items.СтраницыУсловногоОформления.CurrentPage = Items.НедоступныеНастройкиУсловногоОформления;

EndProcedure

// Переключить страницу условного оформления на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure ConditionalAppearanceUnavailable1()

	ЛокальноеУсловноеОформление1 = False;
	Items.ЛокальноеУсловноеОформление1.ReadOnly = True;
	Items.СтраницыУсловногоОформления1.CurrentPage = Items.НедоступныеНастройкиУсловногоОформления1;

EndProcedure

// Включить доступность параметров вывода.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure OutputParametersAvailable(ЭлементСтруктуры)

	If Report.SettingsComposer.Settings.HasItemOutputParameters(ЭлементСтруктуры) Then

		ЛокальныеПараметрыВывода = True;
		Items.СтраницыПараметровВывода.CurrentPage = Items.НастройкиПараметровВывода;

	Else

		ЛокальныеПараметрыВывода = False;
		Items.СтраницыПараметровВывода.CurrentPage = Items.ОтключенныеНастройкиПараметровВывода;

	EndIf;

	Items.ЛокальныеПараметрыВывода.ReadOnly = False;

EndProcedure

// Включить доступность параметров вывода для исполняемых настроек.
//
// Параметры: 
//  ЭлементСтруктуры - элемент структуры, для которого изменяется доступность.
&AtClient
Procedure OutputParametersAvailable1(ЭлементСтруктуры)

	If ИсполняемыйКомпоновщикНастроек.Settings.HasItemOutputParameters(ЭлементСтруктуры) Then

		ЛокальныеПараметрыВывода1 = True;
		Items.СтраницыПараметровВывода1.CurrentPage = Items.НастройкиПараметровВывода1;

	Else

		ЛокальныеПараметрыВывода1 = False;
		Items.СтраницыПараметровВывода1.CurrentPage = Items.ОтключенныеНастройкиПараметровВывода1;

	EndIf;

	Items.ЛокальныеПараметрыВывода1.ReadOnly = False;

EndProcedure

// Переключить страницу параметров вывода на страницу с текстом недоступности.
&AtClient
Procedure OutputParametersUnavailable()

	ЛокальныеПараметрыВывода = False;
	Items.ЛокальныеПараметрыВывода.ReadOnly = True;
	Items.СтраницыПараметровВывода.CurrentPage = Items.НедоступныеНастройкиПараметровВывода;

EndProcedure

// Переключить страницу параметров вывода на страницу с текстом недоступности для исполняемых настроек.
&AtClient
Procedure OutputParametersUnavailable1()

	ЛокальныеПараметрыВывода1 = False;
	Items.ЛокальныеПараметрыВывода1.ReadOnly = True;
	Items.СтраницыПараметровВывода1.CurrentPage = Items.НедоступныеНастройкиПараметровВывода1;

EndProcedure

// Сгенерировать имя от базовой части имени на сервере.
//
// Параметры:
//  ТипСтроки - тип строки, для которой генерируется имя.
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
//  ТипСтроки - тип строки, для которой генерируется имя.
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
//  ТипСтроки - тип строки, который нужно найти.
//  НайденныеСтроки - массив найденных строк.
&AtClientAtServerNoContext
Procedure FindRows(КоллекцияЭлементов, ТипСтроки, НайденныеСтроки)

	For Each Item In КоллекцияЭлементов Do

		If Item.ТипСтроки = ТипСтроки Then

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

	Return СгенерироватьИмя(0, NStr("ru='Report'"), ДеревоОтчетов.GetItems(), True);

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

// Сгенерировать имя для пользовательской настройки.
//
// Параметры:
//  КоллекцияЭлементов - коллекция элементов, в которую добавляется пользовательская 
//						 настройка.
//
// Возвращаемое значение:
//  Стока - сгенерированное имя пользовательской настройки.
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
//  ТипСтроки - тип строк, имена которых нужно собрать.
//  УникальныеИмена - соответствие, в которое нужно поместить уникальные имена.
//  Рекурсивно - необходимость рекурсивного получения вложенных имен.
&AtServer
Procedure НайтиУникальныеИменаСервер(Items, ТипСтроки, УникальныеИмена, Рекурсивно)

	For Each Item In Items Do

		If Item.ТипСтроки = ТипСтроки Then

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
//  ТипСтроки - тип строк, имена которых нужно собрать.
//  УникальныеИмена - соответствие, в которое нужно поместить уникальные имена.
//  Рекурсивно - необходимость рекурсивного получения вложенных имен.
&AtClient
Procedure НайтиУникальныеИмена(Items, ТипСтроки, УникальныеИмена, Рекурсивно)

	For Each Item In Items Do

		If Item.ТипСтроки = ТипСтроки Then

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

		If ЭлементНеПапка.ТипСтроки <> 3 Then

			Return ЭлементНеПапка.ТипСтроки;

		Else

			ЭлементНеПапка = ЭлементНеПапка.GetParent();

		EndIf;

	EndDo;

	Return Undefined;

EndFunction

// Загрузить файл.
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

		ТекущиеЭлементы = ДеревоОтчетов.GetItems();

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

			Items.ДеревоОтчетов.CurrentLine = ТекущийЭлементДерева.GetID();

		EndIf;

	EndIf;

	CurrentNode = Undefined;
	ОбновитьЗаголовок();
//	ТекущаяСтрока = Неопределено;
	ЗагрузитьТекущуюСтрокуНаСервере();
	НастройкиТекущейСтрокиИзменены = False;
EndProcedure

// Загрузить файл консоли на сервере.
//
// Параметры:
//  Адрес - адрес хранилища, из которого нужно загрузить файл.
&AtServer
Procedure ЗагрузитьФайлКонсолиНаСервере(Address)

	ИмяВременногоФайла = GetTempFileName();
	Data = GetFromTempStorage(Address);
	Data.Write(ИмяВременногоФайла);
	ValueToFormAttribute(ValueFromFile(ИмяВременногоФайла), "ДеревоОтчетов");

EndProcedure

// Загрузить схему компоновки данных в компоновщик настроек.
//
// Параметры:
//  ЭлементДерева - элемент дерева отчетов, схему которого нужно загрузить в компоновщик настроек.
//  ЗагружатьНастройкиПоУмолчанию - Булево. Признак того, нужно ли загружать из схемы настройки по умолчанию.
&AtServer
Procedure ЗагрузитьСхемуКомпоновкиДанныхВКомпоновщикНастроек(ЭлементДерева, ЗагружатьНастройкиПоУмолчанию)
	If ЭлементДерева.ТипСтроки = 4 Then
		Return;
	EndIf;

	DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(ЭлементДерева.Data);
	АдресВременногоХранилищаСхемы = PutToTempStorage(DataCompositionSchema, ?(
		АдресВременногоХранилищаСхемы <> "", АдресВременногоХранилищаСхемы, UUID));
	Report.SettingsComposer.Initialize(
		New DataCompositionAvailableSettingsSource(АдресВременногоХранилищаСхемы));

	If ЗагружатьНастройкиПоУмолчанию And ValueIsFilled(ЭлементДерева.НастройкиСКД) Then
		XMLReader = New XMLReader;
		XMLReader.SetString(ЭлементДерева.НастройкиСКД);
		Settings = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionSettings"));

		Report.SettingsComposer.LoadSettings(Settings);

	EndIf;

EndProcedure

// Загрузить настройки варианта отчета в текущую строку дерева.
//
// Параметры:
//  ЭлементДерева - элемент дерева отчета, в который нужно загрузить настройки варианта отчета.
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

		If ЭлементДерева.ТипСтроки = 0 Then

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

	If CurrentLine <> Undefined Then

		ЭлементДерева = ДеревоОтчетов.FindByID(CurrentLine);

		If ЭлементДерева.ТипСтроки = 0 Then

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

			//		ElsIf ЭлементДерева.ТипСтроки = 2 Then
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

	If Items.ДеревоОтчетов.CurrentLine = Undefined Then
		Return;
	EndIf;

	ЭлементДерева = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

	//		If ЭлементДерева.ТипСтроки=0 Then
	//Scheme компоновки
	ЗагрузитьСхемуКомпоновкиДанныхВКомпоновщикНастроек(ЭлементДерева, True);

	//		ElsIf ЭлементДерева.ТипСтроки = 1 Then
	//			// Variant отчета.
	//			ЗагрузитьНастройкиВаниантаВТекущуюСтроку(ЭлементДерева);
	//			
	//		ElsIf ЭлементДерева.ТипСтроки = 2 Then
	//			// Пользовательские настройки.
	//			ЭлементВриантИлиОтчет = ЭлементДерева.GetParent();
	//			
	//			While ЭлементВриантИлиОтчет <> Undefined Do
	//				
	//				If ЭлементВриантИлиОтчет.ТипСтроки = 0 Then
	//					// Нашли отчет.
	//					ЗагрузитьСхемуКомпоновкиДанныхВКомпоновщикНастроек(ЭлементВриантИлиОтчет, True);
	//					Break;
	//					
	//				ElsIf ЭлементВриантИлиОтчет.ТипСтроки = 1 Then
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

// Сохраним настройки текущей строки в дерево.
	СохранитьДанныеТекущейСтрокиНаСервере();

	// Загрузим настройки в компоновщик настроек.
	ЗагрузитьТекущуюСтрокуНаСервере();

EndProcedure

// Вывести макет компоновки данных в табличный документ.
//
// Параметры:
//  МакетКомпоновкиДанных - макет компоновки данных, который нужно вывести.
//  ДанныеРасшифровкиОбъект - объект данных расшифровки, который нужно заполнить при выводе.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВТабличныйДокумент(DataCompositionTemplate, ДанныеРасшифровкиОбъект)

	РезультатТабличныйДокумент.Clear();
	DataCompositionProcessor = New DataCompositionProcessor;
	DataCompositionProcessor.Initialize(DataCompositionTemplate, СтруктураВнешнихНаборовДанных(), ДанныеРасшифровкиОбъект, True);
	ПроцессорВыводаРезультатаОтчета = New DataCompositionResultSpreadsheetDocumentOutputProcessor;
	ПроцессорВыводаРезультатаОтчета.SetDocument(РезультатТабличныйДокумент);
	ПроцессорВыводаРезультатаОтчета.BeginOutput();
	ПроцессорВыводаРезультатаОтчета.Put(DataCompositionProcessor);
	ПроцессорВыводаРезультатаОтчета.EndOutput();

	If ДанныеРасшифровкиОбъект <> Undefined Then

		АдресДанныхРасшифровки = PutToTempStorage(ДанныеРасшифровкиОбъект, UUID);

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

	ТекстРезультатаКомпоновкиДанных = ПолучитьТекстРезультатаКомпоновкиДанных(DataCompositionTemplate,
		ДанныеРасшифровкиОбъект);

EndProcedure

// Вывести макет компоновки данных в результат в виде XML для коллекции значений.
//
// Параметры:
//  МакетКомпоновкиДанных - макет, который нужно вывести.
&AtServer
Procedure ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate)

	ТекстРезультатаКомпоновкиДанныхДляКоллекции = ПолучитьТекстРезультатаКомпоновкиДанных(DataCompositionTemplate,
		Undefined);

EndProcedure

// Сформировать на сервере текущую строку в табличный документ.
//
// Возвращаемое значение:
//  Строка - текст ошибки, который нужно выдать пользователю.
&AtServer
Function СформироватьНаСервереВТабличныйДокумент()

	Var ДанныеРасшифровкиОбъект;

	ЗаполненРезультатТабличныйДокумент = True;

	If Items.ДеревоОтчетов.CurrentLine <> Undefined Then

		Item = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

		If Item.ТипСтроки = 0 Then
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
			//			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
			//			КомпоновщикМакета = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema, Report.SettingsComposer.Settings, ДанныеРасшифровкиОбъект);
			//			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			//			ВывестиМакетКомпоновкиДанныхВТабличныйДокумент(DataCompositionTemplate, ДанныеРасшифровкиОбъект);
			//			ОтобразитьПанельРезультатов();
			//			
			//		ElsIf Item.ТипСтроки = 2 Then
			//			// Settings отчета.
			//			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
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

		NewColumn = New FormAttribute(Column.Name, Column.ValueType, "РезультатДерево", Column.Title);
		НовыеРеквзиты.Add(NewColumn);

	EndDo;

	УдаляемыеРеквизиты = New Array;
	ТекущиеРеквизиты = GetAttributes("РезультатДерево");

	For Each Attribute In ТекущиеРеквизиты Do

		УдаляемыеРеквизиты.Add(Attribute.Path + "." + Attribute.Name);

	EndDo;

	ChangeAttributes(НовыеРеквзиты, УдаляемыеРеквизиты);

	While Items.РезультатДерево.ChildItems.Count() > 0 Do

		Items.Delete(Items.РезультатДерево.ChildItems[0]);

	EndDo;

	For Each Column In ВременноеДерево.Cols Do
		If Column.ValueType.ContainsType(Type("ValueStorage")) Then
			Continue;
		EndIf;

		Item = Items.Add(Column.Name, Type("FormField"), Items.РезультатДерево);
		Item.DataPath = "РезультатДерево." + Column.Name;

	EndDo;

	Items.ДекорацияКоллекции.Visible = НовыеРеквзиты.Count() = 0;

	ValueToFormAttribute(ВременноеДерево, "РезультатДерево");

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

// Сформировать на сервере результат и вывести его в коллекцию значений.
//
// Возвращаемое значение:
//  Строка - текст сообщения, которое нужно показать пользователю.
&AtServer
Function СформироватьНаСервереВКоллекцию()

	ЗаполненРезультатКоллекция = True;

	If Items.ДеревоОтчетов.CurrentLine <> Undefined Then

		Item = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

		If Item.ТипСтроки = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

			//		ElsIf Item.ТипСтроки = 1 Then
			//			// Variant отчета.
			//			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
			//			КомпоновщикМакета = New DataCompositionTemplateComposer;
			//			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema, Report.SettingsComposer.Settings , , , Type("DataCompositionValueCollectionTemplateGenerator"));
			//			ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
			//			ОтобразитьПанельРезультатов();
			//			
			//		ElsIf Item.ТипСтроки = 2 Then
			//			// Settings отчета.
			//			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
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

// Сформировать на сервере отчет и вывести его в виде XML.
//
// Возвращаемое значение:
//  Строка - текст сообщения, которое нужно показать пользователю.
&AtServer
Function СформироватьНаСервереВВидеXML()

	Var ДанныеРасшифровкиОбъект;

	ЗаполненРезультатXML = True;

	If Items.ДеревоОтчетов.CurrentLine <> Undefined Then

		Item = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

		If Item.ТипСтроки = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, ДанныеРасшифровкиОбъект);
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 1 Then
		// Variant отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, ДанныеРасшифровкиОбъект);
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 2 Then
		// Settings отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
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

// Сформировать результат отчета для коллекции и выдать его в виде текста XML.
//
// Возвращаемое значение:
//  Строка - текст сообщения, который нужно показать пользователю.
&AtServer
Function СформироватьНаСервереВВидеXMLКоллекция()

	ЗаполненРезультатКоллекцияXML = True;

	If Items.ДеревоОтчетов.CurrentLine <> Undefined Then

		Item = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

		If Item.ТипСтроки = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 1 Then
		// Variant отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 2 Then
		// Settings отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
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
	ТекстМакетаКомпоновкиДанных = XMLWriter.Close();

EndProcedure

// Сформировать макет компоновки данных.
// 
// Возвращаемое значение:
//  Строка - текст сообщения, который нужно выдать пользователю.
&AtServer
Function СформироватьНаСервереВМакетКомпоновкиДанных()

	Var ДанныеРасшифровкиОбъект;

	ЗаполненРезультатМакет = True;

	If Items.ДеревоОтчетов.CurrentLine <> Undefined Then

		Item = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

		If Item.ТипСтроки = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВТекст(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 1 Then
		// Variant отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, ДанныеРасшифровкиОбъект);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ВывестиМакетКомпоновкиДанныхВТекст(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 2 Then
		// Settings отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
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
	ТекстМакетаКомпоновкиДанныхДляКоллекции = XMLWriter.Close();

EndProcedure

// Сформировать макет компоновки данных для коллекции.
//
// Возвращаемое значение:
//  Строка - выводимая пользователю строка.
&AtServer
Function СформироватьНаСервереВМакетКомпоновкиДанныхДляКоллекции()

	Var ДанныеРасшифровкиОбъект;

	ЗаполненРезультатМакетДляКоллекции = True;

	If Items.ДеревоОтчетов.CurrentLine <> Undefined Then

		Item = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

		If Item.ТипСтроки = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				DataCompositionSchema.DefaultSettings, , , Type(
				"DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВТекстДляКоллекции(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 1 Then
		// Variant отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
			КомпоновщикМакета = New DataCompositionTemplateComposer;
			DataCompositionTemplate = КомпоновщикМакета.Execute(DataCompositionSchema,
				Report.SettingsComposer.Settings, , , Type("DataCompositionValueCollectionTemplateGenerator"));
			ВывестиМакетКомпоновкиДанныхВТекстДляКоллекции(DataCompositionTemplate);
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 2 Then
		// Settings отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
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

// Сформировать исполняемые настройки.
//
// Возвращаемое значение:
//  Строка - сообщение, которое нужно выдать пользователю.
&AtServer
Function СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанных()

	Var ДанныеРасшифровкиОбъект;

	ЗаполненРезультатНастройки = True;

	If Items.ДеревоОтчетов.CurrentLine <> Undefined Then

		Item = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

		If Item.ТипСтроки = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ИсполняемыйКомпоновщикНастроек.Initialize(
				New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
			ИсполняемыйКомпоновщикНастроек.LoadSettings(DataCompositionSchema.DefaultSettings);
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 1 Then

		// Variant отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ИсполняемыйКомпоновщикНастроек.Initialize(
				New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
			ИсполняемыйКомпоновщикНастроек.LoadSettings(Report.SettingsComposer.Settings);
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 2 Then

		// Settings отчета.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанных(НайтиЭлементДереваОтчет(
				ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine)).Data);
			ExecutedReportSchemaURL = PutToTempStorage(DataCompositionSchema, ?(
				ExecutedReportSchemaURL <> "", ExecutedReportSchemaURL, UUID));
			ИсполняемыйКомпоновщикНастроек.Initialize(
				New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
			ИсполняемыйКомпоновщикНастроек.LoadSettings(Report.SettingsComposer.GetSettings());
			ОтобразитьПанельРезультатов();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Сформировать исполняемые настройки и выдать их в виде XML.
//
// Возвращаемое значение:
//  Строка - текст, выдаваемый пользователю.
&AtServer
Function СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанныхXML()

	Var ДанныеРасшифровкиОбъект;

	ЗаполненРезультатНастройкиXML = True;

	If Items.ДеревоОтчетов.CurrentLine <> Undefined Then

		Item = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

		If Item.ТипСтроки = 0 Then
		// Report.
			DataCompositionSchema = ПолучитьСхемуКомпоновкиДанныхСервер();
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, DataCompositionSchema.DefaultSettings, "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ИсполняемыеНастройкиXML = XMLWriter.Close();
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 1 Then
		// Variant отчета.
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.Settings, "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ИсполняемыеНастройкиXML = XMLWriter.Close();
			ОтобразитьПанельРезультатов();

		ElsIf Item.ТипСтроки = 2 Then
		// Settings отчета.
			XMLWriter = New XMLWriter;
			XMLWriter.SetString();
			XDTOSerializer.WriteXML(XMLWriter, Report.SettingsComposer.GetSettings(), "Settings",
				"http://v8.1c.ru/8.1/data-composition-system/settings");
			ИсполняемыеНастройкиXML = XMLWriter.Close();
			ОтобразитьПанельРезультатов();

		Else

			Return NStr(
				"ru='Not понятно, какой отчет нужно формировать. Выберите отчет или вариант или настройку и повторите формирование отчета.'");

		EndIf;

	EndIf;

	Return Undefined;

EndFunction

// Сформировать отчет на сервере. Формирование идет в зависимости от текущей страницы панели результатов.
//
// Возвращаемое значение:
//  Строка - текст, выдаваемый пользователю.
&AtServer
Function СформироватьНаСервере()

	ОтчетНужноФормировать = True;
	ЗаполненРезультатМакет = False;
	ЗаполненРезультатНастройки = False;
	ЗаполненРезультатНастройкиXML = False;
	ЗаполненРезультатТабличныйДокумент = False;
	ЗаполненРезультатXML = False;
	ЗаполненРезультатКоллекция = False;
	ЗаполненРезультатМакетДляКоллекции = False;
	ЗаполненРезультатКоллекцияXML = False;

	If Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатТабличныйДокумент Then

		Return СформироватьНаСервереВТабличныйДокумент();

//	ИначеЕсли Элементы.ПанельРезультатов.ТекущаяСтраница = Элементы.СтраницаМакетКомпоновкиДанных Тогда
//
//		Возврат СформироватьНаСервереВМакетКомпоновкиДанных();
//
//	ИначеЕсли Элементы.ПанельРезультатов.ТекущаяСтраница = Элементы.СтраницаИсполняемыеНастройки Тогда
//
//		Возврат СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанных();
//
//	ИначеЕсли Элементы.ПанельРезультатов.ТекущаяСтраница = Элементы.СтраницаИсполняемыеНастройкиXML Тогда
//
//		Возврат СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанныхXML();
//
//	ИначеЕсли Элементы.ПанельРезультатов.ТекущаяСтраница = Элементы.СтраницаРезультатКомпоновкиДанныхXML Тогда
//
//		Возврат СформироватьНаСервереВВидеXML();

	ElsIf Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатКоллекция Then

		Return СформироватьНаСервереВКоллекцию();

//	ИначеЕсли Элементы.ПанельРезультатов.ТекущаяСтраница = Элементы.СтраницаМакетДляКоллекции Тогда
//
//		Возврат СформироватьНаСервереВМакетКомпоновкиДанныхДляКоллекции();
//
//	ИначеЕсли Элементы.ПанельРезультатов.ТекущаяСтраница = Элементы.СтраницаРезультатКоллекцияXML Тогда
//
//		Возврат СформироватьНаСервереВВидеXMLКоллекция();

	EndIf;
EndFunction

// Сформировать отчет на клиенте.
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

	Items.ПанельРезультатов.Visible = True;
	Items.ПанельРезультатовКнопка.Check = Items.ПанельРезультатов.Visible;

EndProcedure

// Отобразить панель результатов.
&AtServer
Procedure ОтобразитьПанельНастроек()
	ВидимостьНастроек = Not Items.ГруппаОтчетовИНастроек.Visible;
	Items.ГруппаОтчетовИНастроек.Visible = ВидимостьНастроек;
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

	Return ПолучитьСхемуКомпоновкиДанных(ДеревоОтчетов.FindByID(
		Items.ДеревоОтчетов.CurrentLine).Data);

EndFunction

// Получить схему компоновки данных для текущей строки на клиенте.
//
// Возвращаемое значение:
//  СхемаКомпоновкиДанных - схема компоновка данных для текущей строки.
&AtClient
Function ПолучитьСхемуКомпоновкиДанныхКлиент()

	#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	Return ПолучитьСхемуКомпоновкиДанных(ДеревоОтчетов.FindByID(
		Items.ДеревоОтчетов.CurrentLine).Data);
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

	CurrentLine = Items.ДеревоОтчетов.CurrentLine;
	ТекСтрокаДерева = ДеревоОтчетов.FindByID(CurrentLine);

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

	// Загрузим настройки в компоновщик настроек.
	ЗагрузитьТекущуюСтрокуНаСервере();	
EndProcedure

// Открыть конструктор схемы компоновки данных.
&AtClient
Procedure ОткрытьКонструкторСхемыКомпоновкиДанных()

#If ТолстыйКлиентОбычноеПриложение Or ТолстыйКлиентУправляемоеПриложение Then
	Конструктор = New DataCompositionSchemaWizard(ПолучитьСхемуКомпоновкиДанныхКлиент());
	Конструктор.Edit(ThisForm);
#Else
		ТекДанные=Items.ДеревоОтчетов.CurrentData;
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

	ТекСтрокаДерева = ДеревоОтчетов.FindByID(ИдентификаторСтроки);

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

	// Загрузим настройки в компоновщик настроек.
	ЗагрузитьТекущуюСтрокуНаСервере();

EndProcedure

// Обновить заголовок формы.
&AtClient
Procedure ОбновитьЗаголовок()

	Title = НачальныйЗаголовок + ?(FileName <> "", ": " + FileName, "");

EndProcedure

// Сохранить файл с отчетами.
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

// Поместить файл во временное хранилище.
&AtServer
Function ПоместитьФайлВоВременноеХранилище()

	ИмяВременногоФайла = GetTempFileName();
	ValueToFile(ИмяВременногоФайла, FormAttributeToValue("ДеревоОтчетов"));
	Result = PutToTempStorage(New BinaryData(ИмяВременногоФайла));
	Return Result;

EndFunction

// Если файл отчетов был изменен, то запросить пользователя, нужно ли его сохранять.
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

	If Items.ДеревоОтчетов.CurrentLine <> Undefined Then

		ТекущийЭлементДерева = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

	EndIf;

	While ТекущийЭлементДерева <> Undefined Do

		Result.Add(ТекущийЭлементДерева.Name);
		ТекущийЭлементДерева = ТекущийЭлементДерева.GetParent();

	EndDo;

	Return Result;

EndFunction

// Сохранить настройки консоли в хранилище настроек.
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
	КопируемыйЭлемент = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);
	НовоеИмя = КопируемыйЭлемент.Name;
	БазоваяЧастьИмени = "";

	//	If КопируемыйЭлемент.ТипСтроки = 0 Then 
	БазоваяЧастьИмени = НайтиБазовуюЧастьИмени(КопируемыйЭлемент.Name);

	If БазоваяЧастьИмени = "" Then

		БазоваяЧастьИмени = NStr("ru='Report'");

	EndIf;

	НовоеИмя = СгенерироватьИмяСервер(0, БазоваяЧастьИмени, ДеревоОтчетов.GetItems(), True);

	//	ElsIf КопируемыйЭлемент.ТипСтроки = 1 Then 
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
	//	ElsIf КопируемыйЭлемент.ТипСтроки = 2 Then
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
	//	ElsIf КопируемыйЭлемент.ТипСтроки = 3 Then 
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
	Items.ДеревоОтчетов.CurrentLine = НовыйЭлемент.GetID();
	ЗагрузитьТекущуюСтрокуНаСервере();
	CurrentLine = НовыйЭлемент.GetID();

EndProcedure

// Выполнить на сервере отчет на основании текста макета компоновки данных.
&AtServer
Procedure ВыполнитьНаСервереИзМакетаКомпоновкиДанных()

	ОтчетНужноФормировать = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(ТекстМакетаКомпоновкиДанных);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВТабличныйДокумент(DataCompositionTemplate, Undefined);
	ОтобразитьПанельРезультатов();
	Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатТабличныйДокумент;

EndProcedure

// Выполнить отчет в коллекцию значений на основании текста макета компоновки данных.
&AtServer
Procedure ВыполнитьНаСервереИзМакетаКомпоновкиДанныхВКоллекцию()

	ОтчетНужноФормировать = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(ТекстМакетаКомпоновкиДанныхДляКоллекции);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВКоллекцию(DataCompositionTemplate);
	ОтобразитьПанельРезультатов();
	Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатКоллекция;

EndProcedure

// Выполнить отчет в виде XML на основании текста макета компоновки данных.
&AtServer
Procedure ВыполнитьВРезультатНаСервереИзМакетаКомпоновкиДанных()

	ОтчетНужноФормировать = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(ТекстМакетаКомпоновкиДанных);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВРезультатXML(DataCompositionTemplate, Undefined);
	ОтобразитьПанельРезультатов();
	Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатКомпоновкиДанныхXML;

EndProcedure

// Выполнить отчет в виде XML в коллекцию значений для макета компоновки данных.
&AtServer
Procedure ВыполнитьВРезультатКоллекцияНаСервереИзМакетаКомпоновкиДанных()

	ОтчетНужноФормировать = False;

	XMLReader = New XMLReader;
	XMLReader.SetString(ТекстМакетаКомпоновкиДанныхДляКоллекции);
	DataCompositionTemplate = XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionTemplate"));
	ВывестиМакетКомпоновкиДанныхВРезультатXMLДляКоллекции(DataCompositionTemplate);
	ОтобразитьПанельРезультатов();
	Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатКоллекцияXML;

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

	FileName = NStr("ru='Исполняемые настройки.xml'");

	If FileName = "" Then

		FileName = "Исполняемые настройки.xml";

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

	ОтчетНужноФормировать = False;
	РезультатТабличныйДокумент.Clear();
	ПроцессорВыводаРезультатаОтчета = New DataCompositionResultSpreadsheetDocumentOutputProcessor;
	ПроцессорВыводаРезультатаОтчета.SetDocument(РезультатТабличныйДокумент);
	ПроцессорВыводаРезультатаОтчета.BeginOutput();

	XMLReader = New XMLReader;
	XMLReader.SetString(ТекстРезультатаКомпоновкиДанных);
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
	Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатТабличныйДокумент;

EndProcedure

// Вывести результат из текста результата в коллекцию.
&AtServer
Procedure ВывестиРезультатИзТекстаРезультатаВКоллекцию()

	ОтчетНужноФормировать = False;
	ПроцессорВыводаРезультатаОтчета = New DataCompositionResultValueCollectionOutputProcessor;
	ПроцессорВыводаРезультатаОтчета.SetObject(New ValueTree);
	ПроцессорВыводаРезультатаОтчета.BeginOutput();

	XMLReader = New XMLReader;
	XMLReader.SetString(ТекстРезультатаКомпоновкиДанныхДляКоллекции);
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
	Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатКоллекция;

EndProcedure

// Загрузить схему компоновки данных из временного хранилища в текущую строку
&AtServer
Procedure ЗагрузитьФайлСхемыКомпоновкиДанныхНаСервере(Address)

	ИмяВременногоФайла = GetTempFileName();
	Data = GetFromTempStorage(Address);
	Data.Write(ИмяВременногоФайла);
	TextReader = New TextReader(ИмяВременногоФайла);
	Modified = True;
	ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine).Data = TextReader.Read();

EndProcedure

// Загрузить схему компоновки данных из временного хранилища в текущую строку
&AtServer
Function ПоместитьСхемуКомпоновкиДанныхВоВременноеХранилище()

	ИмяВременногоФайла = GetTempFileName();
	TextWriter = New TextWriter(ИмяВременногоФайла);
	TextWriter.Write(ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine).Data);
	TextWriter.Close();
	Result = PutToTempStorage(New BinaryData(ИмяВременногоФайла));
	Return Result;

EndFunction

&AtServer
Procedure ЗаполнитьСКДДляОтладки(АдресДанныхОтладки)
	ДанныеДляОтладки = GetFromTempStorage(АдресДанныхОтладки);
	ЭлементыДерева = ДеревоОтчетов.GetItems();
	ЭлементыДерева.Clear();

	КорневойЭлемент = ЭлементыДерева.Add();
	КорневойЭлемент.ТипСтроки = 4;
	КорневойЭлемент.Name = NStr("ru='Reports'");

	ЭлементыВКоторыеДобавляем = КорневойЭлемент.GetItems();

	Name = "Report для отладки";
	Item = ЭлементыВКоторыеДобавляем.Add();
	Item.Name = Name;
	Item.ТипСтроки = 0;

	Item.Data = ДанныеДляОтладки.ТекстСКД;
	Item.НастройкиСКД = ДанныеДляОтладки.DcsSettingsText;

	If ДанныеДляОтладки.Property("ВнешниеНаборыДанных") Then
		For Each КлючЗначение ИЗ ДанныеДляОтладки.ВнешниеНаборыДанных Do
			НС=Item.ВнешниеНаборыДанных.Add();
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

	НачальныйЗаголовок = Title;
	ИнициализироватьДеревоОтчетов(ДеревоОтчетов);
	НастройкиКонсоли = CommonSettingsStorage.Load("НастройкиКонсолиСистемыОтчетности5");

	If НастройкиКонсоли <> Undefined Then

		НастройкиКонсоли.Property("FileName", FileName);
		НастройкиКонсоли.Property("CurrentNode", ВременныйУзел);

		If TypeOf(ВременныйУзел) = Type("ValueList") Then

			CurrentNode = ВременныйУзел;

		EndIf;

	EndIf;

	ИмяФормыРасшифровки = "Report.UT_ReportsConsole.Form.DetailsForm";

	Items.Settings.Check = True;
	Items.ПанельРезультатовКнопка.Check = True;

	If Parameters.Property("ДанныеОтладки") Then
		ЗаполнитьСКДДляОтладки(Parameters.ДанныеОтладки);
		Return;
	EndIf;
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.ГлавнаяКоманднаяПанель);

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

// Обработчик команды ДобавитьСхемуКомпоновкиДанных.
&AtClient
Procedure ДобавитьСхемуКомпоновкиДанных(Command)

	Var ЭлементыВКоторыеДобавляем;
	Var ТекущийЭлементДерева;

	Modified = True;

	If Items.ДеревоОтчетов.CurrentLine <> Undefined Then

		ТекущийЭлементДерева = ДеревоОтчетов.FindByID(Items.ДеревоОтчетов.CurrentLine);

	EndIf;

	While ТекущийЭлементДерева <> Undefined Do

		If ТекущийЭлементДерева.ТипСтроки = 0 Or (ТекущийЭлементДерева.ТипСтроки = 3 And ТипПапки(
			ТекущийЭлементДерева) = 4) Or ТекущийЭлементДерева.ТипСтроки = 4 Then

			Break;

		Else

			ТекущийЭлементДерева = ТекущийЭлементДерева.GetParent();

		EndIf;

	EndDo;

	If ТекущийЭлементДерева <> Undefined Then

		If ТекущийЭлементДерева.ТипСтроки = 3 Or ТекущийЭлементДерева.ТипСтроки = 4 Then

				// Folder или корень.
			ЭлементыВКоторыеДобавляем = ТекущийЭлементДерева.GetItems();

		ElsIf ТекущийЭлементДерева.GetParent() <> Undefined Then

			ЭлементыВКоторыеДобавляем = ТекущийЭлементДерева.GetParent().GetItems();

		Else

			ЭлементыВКоторыеДобавляем = ДеревоОтчетов.GetItems();

		EndIf;

	Else

		ЭлементыВКоторыеДобавляем = ДеревоОтчетов.GetItems();

	EndIf;

	Name = СгенерироватьИмяСхемыКомпоновкиДанных();
	Item = ЭлементыВКоторыеДобавляем.Add();
	Item.Name = Name;
	Item.ТипСтроки = 0;

	Items.ДеревоОтчетов.CurrentLine = Item.GetID();

EndProcedure

// Обработчик команды Сформировать.
&AtClient
Procedure Сформировать(Command)

	СформироватьКлиент();

EndProcedure

// Обработчик команды ПанельРезультатов.
&AtClient
Procedure ПанельРезультатов(Command)

	Items.ПанельРезультатов.Visible = Not Items.ПанельРезультатов.Visible;
	Items.ПанельРезультатовКнопка.Check = Items.ПанельРезультатов.Visible;

EndProcedure

// Обработчик команды КонструкторСхемыКомпоновкиДанных.
&AtClient
Procedure DataCompositionSchemaWizard(Command)

	ОткрытьКонструкторСхемыКомпоновкиДанных();

EndProcedure

// Обработчик команды СохранитьОтчетыВФайл.
&AtClient
Procedure СохранитьОтчетыВФайл(Command)

//	СохранитьДанныеТекущейСтрокиИЗагрузитьТекущуюСтрокуНаСервере();
	СохранитьДанныеТекущейСтрокиНаСервере();
	Save(False, New NotifyDescription("СохранениеВФайлЗавершение", ThisForm));

EndProcedure

// Обработчик команды СохранитьОтчетыВФайлКак.
&AtClient
Procedure СохранитьОтчетыВФайлКак(Command)

	Save(True, New NotifyDescription("СохранениеВФайлЗавершение", ThisForm));

EndProcedure

// Завершение обработчика открытия файла.
&AtClient
Procedure СохранениеВФайлЗавершение(Result, AdditionalParameters) Export

	If Result Then
		Modified = False;
	EndIf;

EndProcedure

// Обработчик команды ОткрытьФайлОтчетов.
&AtClient
Procedure ОткрытьФайлОтчетов(Command)

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

// Обработчик команды НовыйФайлОтчетов.
&AtClient
Procedure НовыйФайлОтчетов(Command)

	ПодтвердитьЗакрытие(New NotifyDescription("НовыйФайлОтчетовЗавершение", ThisForm));

EndProcedure

// Завершение обработчика создания нового файла отчетов.
&AtClient
Procedure НовыйФайлОтчетовЗавершение(Result, AdditionalParameters) Export

	If Result Then

		Modified = False;
		ИнициализироватьДеревоОтчетов(ДеревоОтчетов);
		FileName = "";
		ОбновитьЗаголовок();
		CurrentLine = Undefined;
		НастройкиТекущейСтрокиИзменены = False;

	EndIf;

EndProcedure

// Обработчик команды ВывестиВТабличныйДокументДляТекущегоМакета.
&AtClient
Procedure ВывестиВТабличныйДокументДляТекущегоМакета(Command)

	ВыполнитьНаСервереИзМакетаКомпоновкиДанных();

EndProcedure

// Обработчик команды СохранитьЭталонТабличногоДокумента.
&AtClient
Procedure СохранитьЭталонТабличногоДокумента(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	РезультатТабличныйДокумент.BeginWriting(Undefined, ИмяФайлаЭталонаТабличногоДокумента());
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды СравнитьСЭталономТабличныйДокумент.
&AtClient
Procedure СравнитьСЭталономТабличныйДокумент(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	РезультатТабличныйДокумент.BeginWriting(New NotifyDescription("СравнитьСЭталономТабличныйДокументЗавершение",
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

// Обработчик команды СохранитьЭталонМакетаКомпоновкиДанных.
&AtClient
Procedure СохранитьЭталонМакетаКомпоновкиДанных(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаМакета(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ТекстМакетаКомпоновкиДанных);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды СравнитьСЭталономМакетКомпоновкиДанных.
&AtClient
Procedure СравнитьСЭталономМакетКомпоновкиДанных(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаМакета(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ТекстМакетаКомпоновкиДанных);
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

// Обработчик команды СохранитьЭталонИсполняемыхНастроек.
&AtClient
Procedure СохранитьЭталонИсполняемыхНастроек(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаИсполняемыхНастроек(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ИсполняемыеНастройкиXML);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды СравнитьСЭталономИсполняемыхНастроек.
&AtClient
Procedure СравнитьСЭталономИсполняемыхНастроек(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаИсполняемыхНастроек(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ИсполняемыеНастройкиXML);
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

// Обработчик команды СохранитьЭталонРезультатаXML.
&AtClient
Procedure СохранитьЭталонРезультатаXML(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаРезультатаXML(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ТекстРезультатаКомпоновкиДанных);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды СравнитьСЭталономРезультатXML.
&AtClient
Procedure СравнитьСЭталономРезультатXML(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаРезультатаXML(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ТекстРезультатаКомпоновкиДанных);
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

// Обработчик команды СохранитьЭталонМакетаКомпоновкиДанныхДляКоллекции.
&AtClient
Procedure СохранитьЭталонМакетаКомпоновкиДанныхДляКоллекции(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаМакетаДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ТекстМакетаКомпоновкиДанныхДляКоллекции);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды СравнитьСЭталономМакетКомпоновкиДанныхДляКоллекции.
&AtClient
Procedure СравнитьСЭталономМакетКомпоновкиДанныхДляКоллекции(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаМакетаДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ТекстМакетаКомпоновкиДанныхДляКоллекции);
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

// Обработчик команды СохранитьЭталонРезультатаXMLДляКоллекции.
&AtClient
Procedure СохранитьЭталонРезультатаXMLДляКоллекции(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаЭталонаРезультатаXMLДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ТекстРезультатаКомпоновкиДанныхДляКоллекции);
	TextWriter.Close();
#Else
		ShowMessageBox( , NStr("ru='Сравнение файлов возможно только в толстом клиенте'"));
#EndIf

EndProcedure

// Обработчик команды СравнитьСЭталономРезультатXMLДляКоллекции.
&AtClient
Procedure СравнитьСЭталономРезультатXMLДляКоллекции(Command)

#If ТолстыйКлиентУправляемоеПриложение Or ТолстыйКлиентОбычноеПриложение Then
	TextWriter = New TextWriter(ИмяФайлаРезультатаXMLДляКоллекции(), , Chars.CR + Chars.LF, , "");
	TextWriter.WriteLine(ТекстРезультатаКомпоновкиДанныхДляКоллекции);
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

// Обработчик команды ВывестиВРезультатДляТекущегоМакета.
&AtClient
Procedure ВывестиВРезультатДляТекущегоМакета(Command)

	ВыполнитьВРезультатНаСервереИзМакетаКомпоновкиДанных();

EndProcedure

// Обработчик команды ВывестиРезультатВТабличныйДокумент.
&AtClient
Procedure ВывестиРезультатВТабличныйДокумент(Command)

	ВывестиРезультатИзТекстаРезультатаВТабличныйДокумент();

EndProcedure

// Обработчик команды ВывестиВКоллекциюДляТекущегоМакета.
&AtClient
Procedure ВывестиВКоллекциюДляТекущегоМакета(Command)

	ВыполнитьНаСервереИзМакетаКомпоновкиДанныхВКоллекцию();

EndProcedure

// Обработчик команды ВывестиВРезультатКоллекцииДляТекущегоМакета.
&AtClient
Procedure ВывестиВРезультатКоллекцииДляТекущегоМакета(Command)

	ВыполнитьВРезультатКоллекцияНаСервереИзМакетаКомпоновкиДанных();

EndProcedure

// Обработчик команды ВывестиРезультатВКоллекцию.
&AtClient
Procedure ВывестиРезультатВКоллекцию(Command)

	ВывестиРезультатИзТекстаРезультатаВКоллекцию();

EndProcedure

// Обработчик команды СохранитьСхемуВФайл
&AtClient
Procedure СохранитьСхемуВФайл(Command)

	BeginAttachingFileSystemExtension(New NotifyDescription("СохранитьСхемуВФайлПослеПодключенияРасширения",
		ThisForm));

EndProcedure

// Обработчик сохранения схемы в файл после подключения расширения работы с файлами.
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

// Обработчик сохранния схемы в файл после выбора файла сохранения.
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

// Обработчик команды ЗагрузитьСхемуИзФайла
&AtClient
Procedure ЗагрузитьСхемуИзФайла(Command)

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

// Обработчик события ПриАктивизацииПоля таблицы Структура.
// Активизирует страницу настроек в зависимости от того, какую колонку
// активировал пользователь.
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

// Обработчик события ПриАктивизацииПоля таблицы Структура1.
// Активизирует страницу настроек в зависимости от того, какую колонку
// активировал пользователь.
&AtClient
Procedure СтруктураПриАктивизацииПоля1(Item)

	Var ВыбраннаяСтраница;

	If Items.Структура1.CurrentItem.Name = "Структура1НаличиеВыбора" Then

		ВыбраннаяСтраница = Items.СтраницаПолейВыбора1;

	ElsIf Items.Структура1.CurrentItem.Name = "Структура1НаличиеОтбора" Then

		ВыбраннаяСтраница = Items.СтраницаОтбора1;

	ElsIf Items.Структура1.CurrentItem.Name = "Структура1НаличиеПорядка" Then

		ВыбраннаяСтраница = Items.СтраницаПорядка1;

	ElsIf Items.Структура1.CurrentItem.Name = "Структура1НаличиеУсловногоОформления" Then

		ВыбраннаяСтраница = Items.СтраницаУсловногоОформления1;

	ElsIf Items.Структура1.CurrentItem.Name = "Структура1НаличиеПараметровВывода" Then

		ВыбраннаяСтраница = Items.СтраницаПараметровВывода1;

	EndIf;

	If ВыбраннаяСтраница <> Undefined Then

		Items.СтраницыНастроек1.CurrentPage = ВыбраннаяСтраница;

	EndIf;

EndProcedure

// Обработчик СтруктураПриАктивизацииСтроки элемента Структура.
// Приводит закладки с настройками в актуальное состояние
&AtClient
Procedure СтруктураПриАктивизацииСтроки(Item)
	ТекСтрокаДерева = Items.Structure.CurrentLine;
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

// Обработчик СтруктураПриАктивизацииСтроки элемента Структура1.
// Приводит закладки с настройками в актуальное состояние
&AtClient
Procedure СтруктураПриАктивизацииСтроки1(Item)

	ЭлементСтруктуры = ИсполняемыйКомпоновщикНастроек.Settings.GetObjectByID(
		Items.Структура1.CurrentLine);
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

		ЛокальныеВыбранныеПоля1 = True;
		Items.ЛокальныеВыбранныеПоля1.ReadOnly = True;
		Items.СтраницыПолейВыбора1.CurrentPage = Items.НастройкиВыбранныхПолей1;

		ЛокальныйОтбор1 = True;
		Items.ЛокальныйОтбор1.ReadOnly = True;
		Items.СтраницыОтбора1.CurrentPage = Items.НастройкиОтбора1;

		ЛокальныйПорядок1 = True;
		Items.ЛокальныйПорядок1.ReadOnly = True;
		Items.СтраницыПорядка1.CurrentPage = Items.НастройкиПорядка1;

		ЛокальноеУсловноеОформление1 = True;
		Items.ЛокальноеУсловноеОформление1.ReadOnly = True;
		Items.СтраницыУсловногоОформления1.CurrentPage = Items.НастройкиУсловногоОформления1;

		ЛокальныеПараметрыВывода1 = True;
		Items.ЛокальныеПараметрыВывода1.ReadOnly = True;
		Items.СтраницыПараметровВывода1.CurrentPage = Items.НастройкиПараметровВывода1;

	ElsIf ItemType = Type("DataCompositionGroup") Or ItemType = Type(
		"DataCompositionTableGroup") Or ItemType = Type("DataCompositionChartGroup") Then

		Items.СтраницыПолейГруппировки1.CurrentPage = Items.НастройкиПолейГруппировки1;

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
		Items.Structure.CurrentLine);
	ItemSettings = Report.SettingsComposer.Settings.ItemSettings(ЭлементСтруктуры);
	Items.Structure.CurrentLine = Report.SettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

// Обработчик события Нажатие декораций для исполняемых настроек.
&AtClient
Procedure GoToReport1(Item)

	ЭлементСтруктуры = ИсполняемыйКомпоновщикНастроек.Settings.GetObjectByID(
		Items.Структура1.CurrentLine);
	ItemSettings = ИсполняемыйКомпоновщикНастроек.Settings.ItemSettings(ЭлементСтруктуры);
	Items.Структура1.CurrentLine = ИсполняемыйКомпоновщикНастроек.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

// Обработчик события ПриИзменении флажка ЛокальныеВыбранныеПоля.
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

// Обработчик события ПриИзменении флажка ЛокальныеВыбранныеПоля1.
&AtClient
Procedure ЛокальныеВыбранныеПоляПриИзменении1(Item)

	If ЛокальныеВыбранныеПоля1 Then

		Items.СтраницыПолейВыбора1.CurrentPage = Items.НастройкиВыбранныхПолей1;

	Else

		Items.СтраницыПолейВыбора1.CurrentPage = Items.ОтключенныеНастройкиВыбранныхПолей1;

		ЭлементСтруктуры = ИсполняемыйКомпоновщикНастроек.Settings.GetObjectByID(
			Items.Структура1.CurrentLine);
		ИсполняемыйКомпоновщикНастроек.Settings.ClearItemSelection(ЭлементСтруктуры);

	EndIf;

EndProcedure

// Обработчик события ПриИзменении флажка ЛокальныйОтбор.
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

// Обработчик события ПриИзменении флажка ЛокальныйОтбор1.
&AtClient
Procedure ЛокальныйОтборПриИзменении1(Item)

	If ЛокальныйОтбор1 Then

		Items.СтраницыОтбора1.CurrentPage = Items.НастройкиОтбора1;

	Else

		Items.СтраницыОтбора1.CurrentPage = Items.ОтключенныеНастройкиОтбора1;

		ЭлементСтруктуры = ИсполняемыйКомпоновщикНастроек.Settings.GetObjectByID(
			Items.Структура1.CurrentLine);
		ИсполняемыйКомпоновщикНастроек.Settings.ClearItemFilter(ЭлементСтруктуры);

	EndIf;

EndProcedure

// Обработчик события ПриИзменении флажка ЛокальныйПорядок.
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

// Обработчик события ПриИзменении флажка ЛокальныйПорядок1.
&AtClient
Procedure ЛокальныйПорядокПриИзменении1(Item)

	If ЛокальныйПорядок1 Then

		Items.СтраницыПорядка1.CurrentPage = Items.НастройкиПорядка1;

	Else

		Items.СтраницыПорядка1.CurrentPage = Items.ОтключенныеНастройкиПорядка1;

		ЭлементСтруктуры = ИсполняемыйКомпоновщикНастроек.Settings.GetObjectByID(
			Items.Структура1.CurrentLine);
		ИсполняемыйКомпоновщикНастроек.Settings.ClearItemOrder(ЭлементСтруктуры);

	EndIf;

EndProcedure

// Обработчик события ПриИзменении флажка ЛокальноеУсловноеОформление.
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

// Обработчик события ПриИзменении флажка ЛокальноеУсловноеОформление1.
&AtClient
Procedure ЛокальноеУсловноеОформлениеПриИзменении1(Item)

	If ЛокальноеУсловноеОформление1 Then

		Items.СтраницыУсловногоОформления1.CurrentPage = Items.НастройкиУсловногоОформления1;

	Else

		Items.СтраницыУсловногоОформления1.CurrentPage = Items.ОтключенныеНастройкиУсловногоОформления1;

		ЭлементСтруктуры = ИсполняемыйКомпоновщикНастроек.Settings.GetObjectByID(
			Items.Структура1.CurrentLine);
		ИсполняемыйКомпоновщикНастроек.Settings.ClearItemConditionalAppearance(ЭлементСтруктуры);

	EndIf;

EndProcedure

// Обработчик события ПриИзменении флажка ЛокальныеПараметрыВывода.
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

// Обработчик события ПриИзменении флажка ЛокальныеПараметрыВывода1.
&AtClient
Procedure ЛокальныеПараметрыВыводаПриИзменении1(Item)

	If ЛокальныеПараметрыВывода1 Then

		Items.СтраницыПараметровВывода1.CurrentPage = Items.НастройкиПараметровВывода1;

	Else

		Items.СтраницыПараметровВывода1.CurrentPage = Items.ОтключенныеНастройкиПараметровВывода1;

		ЭлементСтруктуры = ИсполняемыйКомпоновщикНастроек.Settings.GetObjectByID(
			Items.Структура1.CurrentLine);
		ИсполняемыйКомпоновщикНастроек.Settings.ClearItemOutputParameters(ЭлементСтруктуры);
	EndIf;

EndProcedure

// Обработчик события ПриАктивизацииСтроки элемента ДеревоОтчетов.
// Отображает соответствующую закладку - схему, вариант, пользовательские настройки и т.п.
&AtClient
Procedure ДеревоОтчетовПриАктивизацииСтроки(Item)

	If Not ИдетАктивацияСтроки And CurrentLine <> Item.CurrentLine Then

		ИдетАктивацияСтроки = True;

		If Item.CurrentLine <> Undefined Then

			ЭлементДерева = ДеревоОтчетов.FindByID(Item.CurrentLine);

			If ЭлементДерева.ТипСтроки = 0 Then
			// Scheme компоновки данных.
				If Items.ГруппаНастроек.CurrentPage <> Items.ГруппаВарианта Then

					Items.ГруппаНастроек.CurrentPage = Items.ГруппаВарианта;

				EndIf;
				//				
				//			ElsIf ЭлементДерева.ТипСтроки = 1 Then
				//				// Variant отчета.
				//				If Items.ГруппаНастроек.CurrentPage <> Items.ГруппаВарианта Then
				//					
				//					Items.ГруппаНастроек.CurrentPage = Items.ГруппаВарианта;
				//					
				//				EndIf;
				//				
				//			ElsIf ЭлементДерева.ТипСтроки = 2 Then
				//				// Пользовательские настройки.
				//				If Items.ГруппаНастроек.CurrentPage <> Items.ГруппаПользовательскихНастроек Then
				//					
				//					Items.ГруппаНастроек.CurrentPage = Items.ГруппаПользовательскихНастроек;
				//					
				//				EndIf;
				//				
				//			Else
				// Неизвестный тип.
				//				If Items.ГруппаНастроек.CurrentPage <> Items.ГруппаПустая Then
				//					
				//					Items.ГруппаНастроек.CurrentPage = Items.ГруппаПустая;
				//					
				//				EndIf;
			EndIf;

		EndIf;

		Try

			СохранитьДанныеТекущейСтрокиИЗагрузитьТекущуюСтрокуНаСервере();
			CurrentLine = Item.CurrentLine;
			ИдетАктивацияСтроки = False;

		Except

			CurrentLine = Undefined; // For того, чтобы не испортить настройки в дереве.
			ИдетАктивацияСтроки = False;

		EndTry;

	EndIf;

EndProcedure

&AtClient
Procedure Settings(Command)
	ОтобразитьПанельНастроек();
EndProcedure

// Обработчик события ПриИзменении элементов, связанных с настройками.
&AtClient
Procedure ПриИзмененииНастроек(Item)

	НастройкиТекущейСтрокиИзменены = True;
	Modified = True;

EndProcedure

&AtClient
Procedure НастройкиОкончаниеПеретаскивания(Item, DragParameters, StandardProcessing)
	НастройкиТекущейСтрокиИзменены = True;
	Modified = True;
EndProcedure

&AtClient
Procedure НастройкиПеретаскивание(Item, DragParameters, StandardProcessing, String, Field)
	НастройкиТекущейСтрокиИзменены = True;
	Modified = True;
EndProcedure



// Обработчик события ПередНачаломДобавления элемента ДеревоОтчетов.
&AtClient
Procedure ДеревоОтчетовПередНачаломДобавления(Item, Cancel, Copy, Parent, Group)

	If Copy Then

		Cancel = True;

		If ДеревоОтчетов.FindByID(Item.CurrentLine).ТипСтроки <> 4 Then
		// Not корень.
			СкопироватьНаСервере();

		EndIf;

	EndIf;

EndProcedure

// Обработчик события ПередУдалением элемента ДеревоОтчетов.
&AtClient
Procedure ДеревоОтчетовПередУдалением(Item, Cancel)

	CurrentLine = Undefined;

EndProcedure

// Обработчик события Выбор элемента ДеревоОтчетов.
&AtClient
Procedure ДеревоОтчетовВыбор(Item, SelectedRow, Field, StandardProcessing)

	StandardProcessing = False;
	СформироватьКлиент();

EndProcedure

// Обработчик события ОбработкаДополнительнойРасшифровки табличного документа РезультатТабличныйДокумент.
&AtClient
Procedure РезультатТабличныйДокументОбработкаДополнительнойРасшифровки(Item, Details, StandardProcessing)

	StandardProcessing = False;
	DetailProcessing = New DataCompositionDetailsProcess(АдресДанныхРасшифровки,
		New DataCompositionAvailableSettingsSource(ExecutedReportSchemaURL));
	DetailProcessing.ShowActionChoice(
		New NotifyDescription("РезультатТабличныйДокументОбработкаРасшифровкиЗавершение", ThisForm,
		New Structure("Details", Details)), Details, , , , Items.РезультатТабличныйДокумент);

EndProcedure

// Обработчик события ОбработкаРасшифровки табличного документа РезультатТабличныйДокумент.
&AtClient
Procedure РезультатТабличныйДокументОбработкаРасшифровки(Item, Details, StandardProcessing)

	StandardProcessing = False;
	DetailProcessing = New DataCompositionDetailsProcess(АдресДанныхРасшифровки,
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

		OpenForm(ИмяФормыРасшифровки, New Structure("Details,DataCompositionSchemaURL",
			New DataCompositionDetailsProcessDescription(АдресДанныхРасшифровки, Details,
			ПараметрВыполненногоДействия), ExecutedReportSchemaURL), , True);

	EndIf;

EndProcedure

// Обработчик события ПриСменеСтраницы панели ПанельРезультатов.
&AtClient
Procedure ПанельРезультатовПриСменеСтраницы(Item, CurrentPage)

	If Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатТабличныйДокумент Then

		If ОтчетНужноФормировать And Not ЗаполненРезультатТабличныйДокумент Then

			Result = СформироватьНаСервереВТабличныйДокумент();

		EndIf;

	ElsIf Items.ПанельРезультатов.CurrentPage = Items.СтраницаМакетКомпоновкиДанных Then

		If ОтчетНужноФормировать And Not ЗаполненРезультатМакет Then

			Result = СформироватьНаСервереВМакетКомпоновкиДанных();

		EndIf;

	ElsIf Items.ПанельРезультатов.CurrentPage = Items.СтраницаИсполняемыеНастройки Then

		If ОтчетНужноФормировать And Not ЗаполненРезультатНастройки Then

			Result = СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанных();

		EndIf;

	ElsIf Items.ПанельРезультатов.CurrentPage = Items.СтраницаИсполняемыеНастройкиXML Then

		If ОтчетНужноФормировать And Not ЗаполненРезультатНастройкиXML Then

			Result = СформироватьНаСервереВИсполняемыеНастройкиКомпоновкиДанныхXML();

		EndIf;

	ElsIf Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатКомпоновкиДанныхXML Then

		If ОтчетНужноФормировать And Not ЗаполненРезультатXML Then

			Result = СформироватьНаСервереВВидеXML();

		EndIf;

	ElsIf Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатКоллекция Then

		If ОтчетНужноФормировать And Not ЗаполненРезультатКоллекция Then

			Result = СформироватьНаСервереВКоллекцию();

		EndIf;

	ElsIf Items.ПанельРезультатов.CurrentPage = Items.СтраницаМакетДляКоллекции Then

		If ОтчетНужноФормировать And Not ЗаполненРезультатМакетДляКоллекции Then

			Result = СформироватьНаСервереВМакетКомпоновкиДанныхДляКоллекции();

		EndIf;

	ElsIf Items.ПанельРезультатов.CurrentPage = Items.СтраницаРезультатКоллекцияXML Then

		If ОтчетНужноФормировать And Not ЗаполненРезультатКоллекцияXML Then

			Result = СформироватьНаСервереВВидеXMLКоллекция();

		EndIf;

	EndIf;

	If Result <> Undefined Then

		ShowMessageBox( , Result);

	EndIf;

EndProcedure

// Обработчик события Выбор таблицы РезультатДерево.
&AtClient
Procedure РезультатДеревоВыбор(Item, SelectedRow, Field, StandardProcessing)

	Var Value;

	StandardProcessing = False;

	If Items.РезультатДерево.CurrentData.Property(Items.РезультатДерево.CurrentItem.Name, Value) Then

		ShowValue( , Value);

	EndIf;

EndProcedure

&AtClient
Procedure ВнешниеНаборыДанныхПредставлениеНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	StandardProcessing=False;
	ТекДанные=Items.ВнешниеНаборыДанных.CurrentData;
	If ТекДанные=Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditValueTable(ТекДанные.Value, ThisObject,
		New NotifyDescription("ВнешниеНаборыДанныхПредставлениеНачалоВыбораЗавершение", ThisObject,New Structure("ТекСтрока",Items.ВнешниеНаборыДанных.CurrentLine)));
EndProcedure
&AtClient
Procedure ВнешниеНаборыДанныхПредставлениеНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result=Undefined Then
		Return;
	EndIf;
	ТекСтрокаДерева=ДеревоОтчетов.FindByID(CurrentLine);
	If ТекСтрокаДерева=Undefined Then
		Return;
	EndIf;
	ТекДанныеСтроки=ТекСтрокаДерева.ВнешниеНаборыДанных.FindByID(AdditionalParameters.ТекСтрока);
	ТекДанныеСтроки.Value=Result.Value;
	ТекДанныеСтроки.Presentation=Result.Presentation;
EndProcedure

&AtClient
Procedure ВнешниеНаборыДанныхПередОкончаниемРедактирования(Item, NewLine, ОтменаРедактирования, Cancel)
	If ОтменаРедактирования Then
		Return;
	EndIf;	
		
	ТекДанные=Items.ВнешниеНаборыДанных.CurrentData;
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
	
	ТекСтрокаДерева=ДеревоОтчетов.FindByID(CurrentLine);
	If ТекСтрокаДерева=Undefined Then
		Return;
	EndIf;

	
	маСтрокиИмени = ТекСтрокаДерева.ВнешниеНаборыДанных.FindRows(New Structure("Name", ТекДанные.Name));
	If маСтрокиИмени.Count() > 1 Then
		ShowMessageBox( , "Column с таким именем уже есть! Введите другое имя.", , Title);
		Cancel = True;
		Return;
	EndIf;
EndProcedure

&AtServer
Function СтруктураВнешнихНаборовДанных()
	ВнешниеНаборы=New Structure;
	
	ТекСтрокаДерева=ДеревоОтчетов.FindByID(CurrentLine);
	If ТекСтрокаДерева=Undefined Then
		Return ВнешниеНаборы;
	EndIf;
		
	For Each Set ИЗ ТекСтрокаДерева.ВнешниеНаборыДанных Do
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