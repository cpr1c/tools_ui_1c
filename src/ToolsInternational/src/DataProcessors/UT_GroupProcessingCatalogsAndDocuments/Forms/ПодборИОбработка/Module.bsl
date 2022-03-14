&AtClient
Var ОбработкаПеретаскивание;

&AtServer
Function ОписаниеТипа(ТипСтрокой) Export

	МассивТипов = New Array;
	МассивТипов.Add(Type(ТипСтрокой));
	TypeDescription = New TypeDescription(МассивТипов);

	Return TypeDescription;

EndFunction

// вОписаниеТипа()
&AtServer
Function ПолучитьСписокВидовОбъектов()
	ТЗ = FormDataToValue(ТабличноеПолеВидыОбъектов, Type("ValueTable"));

	ListOfSelected = New ValueList;
	ListOfSelected.LoadValues(ТЗ.UnloadColumn("TableName"));

	Return ListOfSelected;
EndFunction

&AtClient
Procedure ОткрытьФормуВыбораТаблицы()
	СтруктураПараметров = New Structure;
	СтруктураПараметров.Insert("ObjectType", Object.ТипОбъекта);
	СтруктураПараметров.Insert("ProcessTabularParts", Object.ОбрабатыватьТабличныеЧасти);
	СтруктураПараметров.Insert("ListOfSelected", ПолучитьСписокВидовОбъектов());

	OpenForm(ПолучитьПолноеИмяФормы("ФормаВыбораТаблиц"), СтруктураПараметров, ThisObject, , , ,
		New NotifyDescription("ОткрытьФормуВыбораТаблицыЗавершение", ThisObject),
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure ОткрытьФормуВыбораТаблицыЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ТабличноеПолеВидыОбъектов.Clear();
	For Each Value In Result Do

		String = ТабличноеПолеВидыОбъектов.Add();
		String.TableName = Value.Value;
		String.ПредставлениеТаблицы = Value.Presentation;

	EndDo;
	ИнициализацияЗапроса();

EndProcedure

// () 
&AtClient
Procedure ТабличноеПолеВидыОбъектовПередНачаломДобавления(Item, Cancel, Copy, Parent, Group)
	ОткрытьФормуВыбораТаблицы();
	Cancel = True;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
//	ОбработкаПеретаскивание = False;
	ChoiceList = Items.ОбъектПоиска.ChoiceList;
	Items.ОбъектПоиска.ChoiceListHeight = 15;

	For Each Catalog In Metadata.Catalogs Do
		If AccessRight("Browse", Catalog) Then
			ИмяСправочника = Catalog.Synonym;
			If ИмяСправочника = "" Then
				ИмяСправочника = Catalog.Name;
			EndIf;

			Structure = New Structure;
			Structure.Insert("Type", "Catalog");
			Structure.Insert("Name", Catalog.Name);
			Structure.Insert("Presentation", ИмяСправочника);

			ChoiceList.Add(Structure, ИмяСправочника, , PictureLib.Catalog);
		EndIf;
	EndDo;

	For Each Document In Metadata.Documents Do
		If AccessRight("Browse", Document) Then
			ИмяДокумента = Document.Synonym;
			If ИмяДокумента = "" Then
				ИмяДокумента = Document.Name;
			EndIf;

			Structure = New Structure;
			Structure.Insert("Type", "Document");
			Structure.Insert("Name", Document.Name);
			Structure.Insert("Presentation", ИмяДокумента);

			ChoiceList.Add(Structure, ИмяДокумента, , PictureLib.Document);
		EndIf;
	EndDo;

	FormAttributeToValue("Object").DownloadDataProcessors(ThisForm, AvailableDataProcessors, SelectedDataProcessors);

	ВКонфигурацииЕстьКатегории = Metadata.Catalogs.Find("КатегорииОбъектов") <> Undefined;
	ВКонфигурацииЕстьСвойства = Metadata.ChartsOfCharacteristicTypes.Find("ObjectProperties") <> Undefined;
	ВКонфигурацииЕстьУправлениеЗаказами = Metadata.InformationRegisters.Find(
		"НоменклатураНеиспользуемаяВВебУправленииЗаказами") <> Undefined;

	UT_Forms.CreateWriteParametersAttributesFormOnCreateAtServer(ThisObject,
		Items.ГруппаПараметрыЗаписи);
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);
	
EndProcedure

&AtClient
Procedure ОбъектПоискаПриИзменении(Item)
	ПриИзмененииОбъектаПоиска();
EndProcedure

&AtServer
Procedure ПриИзмененииОбъектаПоиска()
//	УстановитьВидимостьДоступность();
	QueryText = GetQueryText();
	ТекстПроизвольногоЗапроса = QueryText;
	ОтборДанных = Undefined;
	QueryOptions.Clear();
EndProcedure

&AtServer
Function СформироватьУсловиеПоискаПоСтроке()
	УсловиеПоискаПоСтроке = "";

	If SearchString <> "" Then
		ИскомыйОбъект = ОбъектПоиска;
		ОбъектМетаданных = Metadata.FindByFullName(ИскомыйОбъект.Type + "." + ИскомыйОбъект.Name);

		УсловиеПоискаПоСтроке = "";

		СтрокаДляПоиска = StrReplace(SearchString, """", """""");

		If ИскомыйОбъект.Type = "Catalog" Then
			If ОбъектМетаданных.DescriptionLength <> 0 Then
				If УсловиеПоискаПоСтроке <> "" Then
					УсловиеПоискаПоСтроке = УсловиеПоискаПоСтроке + " ИЛИ ";
				EndIf;
				УсловиеПоискаПоСтроке = УсловиеПоискаПоСтроке + " Title ПОДОБНО ""%" + СтрокаДляПоиска + "%""";
			EndIf;

			If ОбъектМетаданных.CodeLength <> 0 And ОбъектМетаданных.CodeType
				= Metadata.ObjectProperties.CatalogCodeType.String Then
				If УсловиеПоискаПоСтроке <> "" Then
					УсловиеПоискаПоСтроке = УсловиеПоискаПоСтроке + " ИЛИ ";
				EndIf;
				УсловиеПоискаПоСтроке = УсловиеПоискаПоСтроке + " Code ПОДОБНО ""%" + СтрокаДляПоиска + "%""";
			EndIf;
		ElsIf ИскомыйОбъект.Type = "Document" Then
			If ОбъектМетаданных.NumberType = Metadata.ObjectProperties.DocumentNumberType.String Then
				If УсловиеПоискаПоСтроке <> "" Then
					УсловиеПоискаПоСтроке = УсловиеПоискаПоСтроке + " ИЛИ ";
				EndIf;
				УсловиеПоискаПоСтроке = УсловиеПоискаПоСтроке + " Number ПОДОБНО ""%" + СтрокаДляПоиска + "%""";
			EndIf;
		EndIf;

		For Each Attribute In ОбъектМетаданных.Attributes Do
			If Attribute.Type.ContainsType(Type("String")) Then
				If УсловиеПоискаПоСтроке <> "" Then
					УсловиеПоискаПоСтроке = УсловиеПоискаПоСтроке + " ИЛИ ";
				EndIf;
				УсловиеПоискаПоСтроке = УсловиеПоискаПоСтроке + Attribute.Name + " ПОДОБНО ""%" + СтрокаДляПоиска + "%""";
			EndIf;
		EndDo;
	EndIf;

	Return УсловиеПоискаПоСтроке;
EndFunction

&AtServer
Function GetQueryText()

	ИскомыйОбъект = ОбъектПоиска;
	ОбъектМетаданных = Metadata.FindByFullName(ИскомыйОбъект.Type + "." + ИскомыйОбъект.Name);
	Condition = "";

	QueryText = "ВЫБРАТЬ 
				   |	Reference КАК Object, 
				   |	Presentation";

	If ИскомыйОбъект.Type = "Catalog" Then
		If ОбъектМетаданных.DefaultPresentation
			<> Metadata.ObjectProperties.CatalogMainPresentation.AsDescription Then
			If ОбъектМетаданных.DescriptionLength <> 0 Then
				QueryText = QueryText + ", 
											  |	Title";
			EndIf;
			If ОбъектМетаданных.CodeLength <> 0 Then
				Condition = "Code";
			EndIf;
		EndIf;
		If ОбъектМетаданных.DefaultPresentation
			<> Metadata.ObjectProperties.CatalogMainPresentation.AsCode Then
			If ОбъектМетаданных.CodeLength <> 0 Then
				QueryText = QueryText + ",
											  |	Code";
			EndIf;
			If ОбъектМетаданных.DescriptionLength <> 0 Then
				Condition = "Title";
			EndIf;
		EndIf;
	ElsIf ИскомыйОбъект.Type = "Document" Then
		Condition = "Date, Number";
	EndIf;

	For Each Attribute In ОбъектМетаданных.Attributes Do
		QueryText = QueryText + ",
									  |	" + Attribute.Name;
	EndDo;

	QueryText = QueryText + Chars.LF + "ИЗ" + Chars.LF;
	QueryText = QueryText + "	" + ИскомыйОбъект.Type + "." + ОбъектМетаданных.Name + " КАК _Таблица" + Chars.LF;

	For Each ТЧ In ОбъектМетаданных.TabularSections Do
		For Each ТЧР In ТЧ.Attributes Do
			If Condition <> "" Then
				Condition = Condition + ",";
			EndIf;
			Condition = Condition + ТЧ.Name + "." + ТЧР.Name + ".* КАК " + ТЧ.Name + ТЧР.Name;
		EndDo;
	EndDo;

	//If Condition <> "" Then
	//	QueryText = QueryText + "{ГДЕ " + Condition + "}" + Chars.LF;
	//EndIf;

	//If УсловиеПоискаПоСтроке <> "" Then
	//	QueryText = QueryText + "ГДЕ " + УсловиеПоискаПоСтроке + Chars.LF;
	//EndIf;
	Return QueryText;
EndFunction

&AtClient
Procedure ОбъектПоискаОбработкаВыбора(Item, ВыбранноеЗначение, StandardProcessing)
	StandardProcessing = False;

	If ValueIsFilled(ВыбранноеЗначение) Then
		ОбъектПоискаПредставление = ВыбранноеЗначение.Presentation;
		ОбъектПоиска = ВыбранноеЗначение;
	Else
		ОбъектПоискаПредставление = "";
		ОбъектПоиска = Undefined;
	EndIf;

	ПриИзмененииОбъектаПоиска();
EndProcedure

&AtClient
Procedure НайтиСсылки(Command)
	Status("Поиск ссылок...");
	НайтиСсылкиПоОтбору();
	Items.ГруппаСтраницы.CurrentPage = Items.ГруппаНаденныеОбъекты;
EndProcedure

&AtServer
Procedure НайтиСсылкиПоОтбору()

	ОбработкаОбъект = FormAttributeToValue("Object");

	Query = New Query;

	If Object.SearchMode = 1 Then
		Query.Text = ТекстПроизвольногоЗапроса;
		For Each СтрокаПараметров In QueryOptions Do
			If СтрокаПараметров.ЭтоВыражение Then
				Query.SetParameter(СтрокаПараметров.ИмяПараметра, Eval(СтрокаПараметров.ЗначениеПараметра));
			Else
				Query.SetParameter(СтрокаПараметров.ИмяПараметра, СтрокаПараметров.ЗначениеПараметра);
			EndIf;
		EndDo;
	Else
		Query.Text = QueryText;
		УсловиеПоискаПоСтроке = СформироватьУсловиеПоискаПоСтроке();
		СписокУсловий = УсловиеПоискаПоСтроке;

		If ОтборДанных <> Undefined Then
			For Each FilterItem In ОтборДанных.Filter.Items Do
				If Not FilterItem.Use Then
					Continue;
				EndIf;

				IndexOf = ОтборДанных.Filter.Items.IndexOf(FilterItem);
				ИмяПараметра = StrReplace(String(FilterItem.LeftValue) + IndexOf, ".", "");

				СписокУсловий = СписокУсловий + ?(СписокУсловий = "", "", "
																		  |	And ")
					+ ОбработкаОбъект.ПолучитьВидСравнения(FilterItem.LeftValue, FilterItem.ComparisonType,
					ИмяПараметра);

				If TypeOf(FilterItem.RightValue) = Type("StandardBeginningDate") Then
					Query.SetParameter(ИмяПараметра, FilterItem.RightValue.Date);
				Else
					Query.SetParameter(ИмяПараметра, FilterItem.RightValue);
				EndIf;
			EndDo;
		EndIf;

		If СписокУсловий <> "" Then
			Query.Text = Query.Text + "
										  |ГДЕ 
										  |	" + СписокУсловий;
		EndIf;

		ТекстЗапросаОкончание = "";

		If Object.ObjectType = 1 Then

			ТекстЗапросаОкончание = ТекстЗапросаОкончание + "
															|УПОРЯДОЧИТЬ ПО
															|	Ш_Дата,
															|	Object";
			ПоляСортировки = "Ш_Дата,Object";

		Else

			ТекстЗапросаОкончание = ТекстЗапросаОкончание + "
															|УПОРЯДОЧИТЬ ПО
															|	Ш_Вид,
															|	Object";
			ПоляСортировки = "Ш_Вид,Object";

		EndIf;

		If Object.ProcessTabularParts Then
			ТекстЗапросаОкончание = ТекстЗапросаОкончание + ",
															|	Т_ТЧ,
															|	Т_НомерСтроки";
			ПоляСортировки = ПоляСортировки + ",Т_ТЧ,Т_НомерСтроки";
		EndIf;

		Query.Text = Query.Text + ТекстЗапросаОкончание;

	EndIf;

	Try
		ТЗ = Query.Execute().Unload();
	Except
		Message(ErrorDescription());
		Return;
	EndTry;

	МассивРеквизитов = New Array;
	МассивРеквизитов.Add("Object");
	МассивРеквизитов.Add("Picture");
	МассивРеквизитов.Add("StartChoosing");

	CreateColumns(ТЗ, МассивРеквизитов);

EndProcedure

&AtClient
Procedure ВыбратьВсе(Command)
	ВыбратьЭлементы(True);
EndProcedure

&AtClient
Procedure ОтменитьВыборВсех(Command)
	ВыбратьЭлементы(False);
EndProcedure

&AtServer
Procedure ВыбратьЭлементы(Selection)
	For Each Стр In НайденныеОбъекты Do
		Стр.StartChoosing = Selection;
	EndDo;
EndProcedure

&AtClient
Procedure ExecuteProcessing(Command)
	For Each String In SelectedDataProcessors Do
		UserInterruptProcessing();

		If Not String.StartChoosing Then
			Continue;
		EndIf;

		Стр = AvailableDataProcessors.FindByID(String.RowAvailableDataProcessor);
		Parent = Стр.GetParent();

		СтруктураПараметров = СформироватьСтруктуруПараметров();
		СтруктураПараметров.Setting = Стр.Setting[0].Value;

		If Parent = Undefined Then
			ИмяФормыОбработки = Стр.FormName;

			СтруктураПараметров.Settings = СформироватьНастройки(Стр);
			СтруктураПараметров.Insert("Parent", Стр.GetID());
			СтруктураПараметров.Insert("CurrentLine", Undefined);
		Else
			ИмяФормыОбработки = Parent.FormName;

			СтруктураПараметров.Settings = СформироватьНастройки(Parent);
			СтруктураПараметров.Insert("Parent", Parent.GetID());
			СтруктураПараметров.Insert("CurrentLine", String.RowAvailableDataProcessor);
		EndIf;

		If Not ОбработкаДоступна(?(Object.ObjectType = 0, "Catalog", "Document"), ИмяФормыОбработки) Then
			Message("Processing " + FormName + " недоступна для типа <" + ОбъектПоиска.Type + ">");
			Continue;
		EndIf;

		Processing = GetForm(ПолучитьПолноеИмяФормы(ИмяФормыОбработки), СтруктураПараметров, ThisForm);
		Processing.ЗагрузитьНастройку();
		Processing.ExecuteProcessing();
	EndDo;
EndProcedure

&AtServer
Procedure CreateColumns(ТЗ, МассивРеквизитовПоУмолчанию = Undefined) Export
	ТаблицаЭлемент = Items.НайденныеОбъекты;

	//очистка
	For Each ДобавленныйЭлемент In ДобавленныеЭлементы Do
		Items.Delete(Items[ДобавленныйЭлемент.Value]);
	EndDo;
	ДобавленныеЭлементы.Clear();

	//добавляем реквизиты
	МассивРеквизитов = New Array;
	For Each Column In ТЗ.Cols Do
		If МассивРеквизитовПоУмолчанию <> Undefined And МассивРеквизитовПоУмолчанию.Find(Column.Name)
			<> Undefined Then
			Continue;
		EndIf;

		ColumnType = String(Column.ValueType);
		If Column.Name = "Presentation" Or Find(ColumnType, "Хранилище значения") > 0 Then
			Continue;
		EndIf;

		FormAttribute = New FormAttribute(Column.Name, Column.ValueType, ТаблицаЭлемент.Name);

		Presentation = "";

		For Each Item In СписокПредставлений Do
			If Item.Presentation = Column.Name Then
				Presentation = Item.Value;
				Break;
			EndIf;
		EndDo;

		FormAttribute.Title = Presentation;
		МассивРеквизитов.Add(FormAttribute);
	EndDo;

	ChangeAttributes(МассивРеквизитов, ДобавленныеРеквизиты.UnloadValues());
	ДобавленныеРеквизиты.Clear();

	//добавляем элементы управления
	For Each Attribute In МассивРеквизитов Do
		ДобавленныеРеквизиты.Add(Attribute.Path + "." + Attribute.Name);

		Item = Items.Add(ТаблицаЭлемент.Name + Attribute.Name, Type("FormField"), ТаблицаЭлемент);
		Item.Type = FormFieldType.TextBox;
		Item.DataPath = ТаблицаЭлемент.Name + "." + Attribute.Name;
		Item.ReadOnly = True;

		ДобавленныеЭлементы.Add(Item.Name);
	EndDo;

	//заполнение данными
	РедТЗ = FormAttributeToValue(ТаблицаЭлемент.Name);
	РедТЗ.Clear();
	For Each Стр In ТЗ Do
		НовСтр = РедТЗ.Add();
		FillPropertyValues(НовСтр, Стр);

		НовСтр.StartChoosing = True;

		//If ОбъектПоиска = Undefined Then
		//	Continue;
		//EndIf;
		If Object.ObjectType = 0 Then //"Catalog" Then
			If Стр.Object.IsFolder Then
				If Стр.Object.DeletionMark Then
					НовСтр.Picture = 3;
				Else
					НовСтр.Picture = 0;
				EndIf;
			Else
				If Стр.Object.DeletionMark Then
					НовСтр.Picture = 4;
				Else
					НовСтр.Picture = 1;
				EndIf;
			EndIf;
		Else
			If Стр.Object.Posted Then
				НовСтр.Picture = 7;
			ElsIf Стр.Object.DeletionMark Then
				НовСтр.Picture = 8;
			Else
				НовСтр.Picture = 6;
			EndIf;
		EndIf;
	EndDo;

	ValueToFormAttribute(РедТЗ, ТаблицаЭлемент.Name);
EndProcedure

&AtServer
Function ПолучитьПолноеИмяФормы(ИмяНужнойФормы)
	МассивСтрок = StrSplit(ThisForm.FormName, ".");
	МассивСтрок[МассивСтрок.Count() - 1] = ИмяНужнойФормы;

	Return StrConcat(МассивСтрок, ".");
EndFunction

&AtClient
Procedure Filter(Command)
	If ТабличноеПолеВидыОбъектов.Count() = 0 Then
		Return;
	EndIf;

	СтруктураПараметров = New Structure;
	СтруктураПараметров.Insert("QueryText", QueryText);
	СтруктураПараметров.Insert("ТекстПроизвольногоЗапроса", ТекстПроизвольногоЗапроса);
	СтруктураПараметров.Insert("SearchString", SearchString);
	СтруктураПараметров.Insert("Settings", ОтборДанных);
	СтруктураПараметров.Insert("ListOfSelected", ПолучитьСписокВидовОбъектов());
	СтруктураПараметров.Insert("SearchMode", Object.РежимПоиска);
	СтруктураПараметров.Insert("QueryOptions", QueryOptions);
	СтруктураПараметров.Insert("СписокПредставлений", СписокПредставлений);

	OpenForm(ПолучитьПолноеИмяФормы("ФормаОтбора"), СтруктураПараметров, ThisObject, , , ,
		New NotifyDescription("ОтборЗавершение", ThisObject), FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure ОтборЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ОбработатьРезультатОтбора(Result);
EndProcedure

&AtServer
Procedure ОбработатьРезультатОтбора(РезультатОтбора)
	ОтборДанных = РезультатОтбора.Settings;
	SearchString = РезультатОтбора.SearchString;
	QueryOptions.Load(РезультатОтбора.QueryOptions.Unload());

	QueryText = РезультатОтбора.QueryText;
	ТекстПроизвольногоЗапроса = РезультатОтбора.ТекстПроизвольногоЗапроса;
	Object.SearchMode = РезультатОтбора.SearchMode;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
//	УстановитьВидимостьДоступность();
	УстановитьКартинкиОбработок();
EndProcedure

&AtClient
Procedure ДоступныеОбработкиВыбор(Item, SelectedRow, Field, StandardProcessing)
	If ТабличноеПолеВидыОбъектов.Count() = 0 Then
		Return;
	EndIf;

	StandardProcessing = False;

	RowIndex = Items.AvailableDataProcessors.CurrentLine;
	CurrentLine = AvailableDataProcessors.FindByID(RowIndex);

	СтруктураПараметров = СформироватьСтруктуруПараметров();
	СтруктураПараметров.Setting = CurrentLine.Setting[0].Value;

	Parent = CurrentLine.GetParent();
	If Parent = Undefined Then
		If Not ОбработкаДоступна(?(Object.ObjectType = 0, "Catalog", "Document"), CurrentLine.FormName) Then
			ShowMessageBox( , "Данная обработка недоступна для типа <" + ?(Object.ObjectType = 0, "Catalog",
				"Document") + ">");
			Return;
		EndIf;

		СтруктураПараметров.Settings = СформироватьНастройки(Item.CurrentData);
		СтруктураПараметров.Insert("Parent", CurrentLine.GetID());
		СтруктураПараметров.Insert("CurrentLine", Undefined);

		ИмяФормыДляОткрытия=ПолучитьПолноеИмяФормы(CurrentLine.FormName);
	Else
		If Not ОбработкаДоступна(?(Object.ObjectType = 0, "Catalog", "Document"), Parent.FormName) Then
			ShowMessageBox( , "Данная обработка недоступна для типа <" + ?(Object.ObjectType = 0, "Catalog",
				"Document") + ">");
			Return;
		EndIf;

		СтруктураПараметров.Settings = СформироватьНастройки(Parent);
		СтруктураПараметров.Insert("Parent", Parent.GetID());
		СтруктураПараметров.Insert("CurrentLine", RowIndex);

		ИмяФормыДляОткрытия=ПолучитьПолноеИмяФормы(Parent.FormName);
	EndIf;

	OpenForm(ИмяФормыДляОткрытия, СтруктураПараметров, ThisObject, , , ,
		New NotifyDescription("ДоступныеОбработкиВыборЗавершение", ThisObject),
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure ДоступныеОбработкиВыборЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
EndProcedure

&AtServer
Function СформироватьСтруктуруПараметров()
	СтруктураПараметров = New Structure;
	СтруктураПараметров.Insert("Setting", Undefined);
	СтруктураПараметров.Insert("Settings", New Array);
	СтруктураПараметров.Insert("ObjectType", Object.ТипОбъекта);
	СтруктураПараметров.Insert("ТаблицаРеквизитов", ТаблицаРеквизитов);
	СтруктураПараметров.Insert("ProcessTabularParts", Object.ОбрабатыватьТабличныеЧасти);
	СтруктураПараметров.Insert("ListOfSelected", ПолучитьСписокВидовОбъектов());
	СтруктураПараметров.Insert("ТабличноеПолеВидыОбъектов", ТабличноеПолеВидыОбъектов);

	СтруктураПараметров.Insert("НайденныеОбъектыТЧ", НайденныеОбъекты);

	СтруктураОтбора = New Structure;
	СтруктураОтбора.Insert("StartChoosing", True);
	СтруктураПараметров.Insert("НайденныеОбъекты", НайденныеОбъекты.Unload(СтруктураОтбора,
		"Object").UnloadColumn("Object"));

	Return СтруктураПараметров;
EndFunction

&AtClient
Procedure ДоступныеОбработкиПередНачаломДобавления(Item, Cancel, Copy, Parent, Group)
	If ТабличноеПолеВидыОбъектов.Count() = 0 Then
		Return;
	EndIf;

	If Item.CurrentData = Undefined Then
		Cancel = True;
	EndIf;

	If Item.CurrentData.GetParent() = Undefined Then
		If Copy Then
			Cancel = True;
		Else
			If Not ОбработкаДоступна(?(Object.ObjectType = 0, "Catalog", "Document"),
				Item.CurrentData.FormName) Then
				ShowMessageBox( , "Данная обработка недоступна для типа <" + ?(Object.ObjectType = 0,
					"Catalog", "Document") + ">");
				Cancel = True;
				Return;
			EndIf;

			Cancel = Not GetForm(ПолучитьПолноеИмяФормы(Item.CurrentData.FormName)).мИспользоватьНастройки;
			If Not Cancel Then
			//свое добавление
				Cancel = True;
				AddRow(Item.CurrentData);
			EndIf;
		EndIf;
	Else
		If Not ОбработкаДоступна(?(Object.ObjectType = 0, "Catalog", "Document"),
			Item.CurrentData.GetParent().FormName) Then
			ShowMessageBox( , "Данная обработка недоступна для типа <" + ?(Object.ObjectType = 0, "Catalog",
				"Document") + ">");
			Cancel = True;
			Return;
		EndIf;
		Cancel = True;
		If Not Copy Then
			If GetForm(ПолучитьПолноеИмяФормы(
				Item.CurrentData.GetParent().FormName)).мИспользоватьНастройки Then
				AddRow(Item.CurrentData.GetParent());
			EndIf;
		Else
			ТекСтрока = Item.CurrentData;
			Parent = Item.CurrentData.GetParent();
			NewLine = AddRow(Parent);

			If Not ТекСтрока.Setting[0].Value = Undefined Then
				НоваяНастройка = New Structure;
				For Each РеквизитНастройки In ТекСтрока.Setting[0].Value Do
				//@skip-warning
					Value = РеквизитНастройки.Value;
					Execute ("НоваяНастройка.Insert(String(РеквизитНастройки.Key), Value);");
				EndDo;

				NewLine.Setting[0].Value = НоваяНастройка;
			EndIf;
		EndIf;
	EndIf;
EndProcedure

&AtClient
Function AddRow(ТекСтрока)

	NewLine = ТекСтрока.GetItems().Add();

	Setting = New Structure;
	Setting.Insert("Processing", ТекСтрока.Processing);
	Setting.Insert("Прочее", Undefined);

	NewLine.Setting.Add(Setting);

	Items.AvailableDataProcessors.CurrentLine = NewLine.GetID();
	Items.AvailableDataProcessors.ChangeRow();

	Return NewLine;
EndFunction

&AtClient
Function СформироватьНастройки(ТекСтрока)

	МассивНастроек = New Array;
	For Each Стр In ТекСтрока.GetItems() Do
		If Стр.Setting[0].Value = Undefined Then
			Continue;
		EndIf;

		МассивНастроек.Add(Стр.Setting[0].Value);
	EndDo;

	Return МассивНастроек;
EndFunction

&AtClient
Procedure ДоступныеОбработкиПередНачаломИзменения(Item, Cancel)
	If ТабличноеПолеВидыОбъектов.Count() = 0 Then
		Return;
	EndIf;

	If Item.CurrentData.GetParent() = Undefined Then
		Cancel = True;
	EndIf;
EndProcedure

&AtClient
Procedure ДоступныеОбработкиПередУдалением(Item, Cancel)
	If Item.CurrentData.GetParent() = Undefined Then
		Return;
	EndIf;

	Cancel=True;

	ShowQueryBox(New NotifyDescription("ДоступныеОбработкиПередУдалениемЗавершение", ThisForm,
		New Structure("CurrentLine", Item.CurrentLine)), "Delete настройку?", QuestionDialogMode.OKCancel, ,
		DialogReturnCode.OK);
EndProcedure

&AtClient
Procedure ДоступныеОбработкиПередУдалениемЗавершение(РезультатВопроса, AdditionalParameters) Export

	CurrentLine = AdditionalParameters.CurrentLine;
	If РезультатВопроса = DialogReturnCode.OK Then
		ПараметрыОтбора = New Structure;
		ПараметрыОтбора.Insert("RowAvailableDataProcessor", CurrentLine);

		МассивДляУдаления = SelectedDataProcessors.FindRows(ПараметрыОтбора);
		For IndexOf = 0 To МассивДляУдаления.Count() - 1 Do
			SelectedDataProcessors.Delete(МассивДляУдаления[IndexOf]);
		EndDo;
	EndIf;

EndProcedure

&AtClient
Procedure ДоступныеОбработкиНачалоПеретаскивания(Item, DragParameters, StandardProcessing)
	If Not ПроверитьДоступностьОбработки() Then
		StandardProcessing = False;
		ShowMessageBox( , "Данная обработка недоступна для типа <" + ?(Object.ObjectType = 0, "Catalog",
			"Document") + ">");
		Return;
	EndIf;

	ОбработкаПеретаскивание = True;
EndProcedure

&AtClient
Function ПроверитьДоступностьОбработки()
	RowIndex = Items.AvailableDataProcessors.CurrentLine;
	CurrentLine = AvailableDataProcessors.FindByID(RowIndex);

	Parent = CurrentLine.GetParent();
	If Parent = Undefined Then
		Return ОбработкаДоступна(?(Object.ObjectType = 0, "Catalog", "Document"), CurrentLine.FormName);
	EndIf;

	Return ОбработкаДоступна(?(Object.ObjectType = 0, "Catalog", "Document"), Parent.FormName);
EndFunction

&AtClient
Procedure ВыбранныеОбработкиПеретаскивание(Item, DragParameters, StandardProcessing, String, Field)
	If Not ОбработкаПеретаскивание Then
		Return;
	EndIf;

	For Each СтрВыбранных In DragParameters.Value Do
		СтрДоступных = AvailableDataProcessors.FindByID(СтрВыбранных.GetID());

		НовСтр = SelectedDataProcessors.Add();
		НовСтр.ОбработкаНастройка = СтрДоступных.Processing;
		НовСтр.RowAvailableDataProcessor = СтрДоступных.GetID();
		НовСтр.StartChoosing = True;
		НовСтр.Setting = СтрДоступных.Setting;
	EndDo;

	ОбработкаПеретаскивание = False;
EndProcedure

&AtClient
Procedure ВыбратьВсеОбработки(Command)
	ВыбратьОбработки(True);
EndProcedure

&AtClient
Procedure ОтменитьВыборВсехОбработок(Command)
	ВыбратьОбработки(False);
EndProcedure

&AtServer
Procedure ВыбратьОбработки(Selection)
	For Each Стр In SelectedDataProcessors Do
		Стр.StartChoosing = Selection;
	EndDo;
EndProcedure

&AtClient
Function ОбработкаДоступна(ПроверяемыйТипОбъекта = "", ИмяОбработки)

	If IsBlankString(ПроверяемыйТипОбъекта) Then
		Return False;
	EndIf;

	Try
		ТипыОбрабатываемыхОбъектов = GetForm(ПолучитьПолноеИмяФормы(ИмяОбработки)).мТипыОбрабатываемыхОбъектов;
	Except
		ShowMessageBox( , ErrorDescription());
		Return False;
	EndTry;

	If ИмяОбработки = "ПеренумерацияОбъектов" Then
		If ТабличноеПолеВидыОбъектов.Count() > 1 Then
			Message("Выбрано более одного вида объектов. Перенумерация невозможна");
			Return False;
		EndIf;

		If Object.ProcessTabularParts Then
			Message("Перенумерация при обработке табличных частей запрещена");
			Return False;
		EndIf;
	EndIf;

	If ТипыОбрабатываемыхОбъектов = Undefined Then
		Return True;
	Else
		If Find(ТипыОбрабатываемыхОбъектов, ПроверяемыйТипОбъекта) Then
			Return True;
		Else
			Return False;
		EndIf;
	EndIf;
EndFunction

&AtClient
Procedure ДоступныеОбработкиПриОкончанииРедактирования(Item, NewLine, ОтменаРедактирования)
	If Item.CurrentData.GetParent() = Undefined Then
		Return;
	EndIf;

	Setting = Item.CurrentData.Setting[0].Value;
	Setting.Processing = Item.CurrentData.Processing;
EndProcedure

&AtClient
Procedure УстановитьКартинкиОбработок()
	For Each Стр In AvailableDataProcessors.GetItems() Do
		Стр.Picture = PictureLib.Processing;
	EndDo;
EndProcedure

&AtClient
Procedure ТабличноеПолеВидыОбъектовПередНачаломИзменения(Item, Cancel)
	ОткрытьФормуВыбораТаблицы();
	Cancel = True;
EndProcedure

&AtClient
Procedure ТабличноеПолеВидыОбъектовПередУдалением(Item, Cancel)
	
	Cancel=True;
	
	CurrentLine = Items.ТабличноеПолеВидыОбъектов.CurrentData.GetID();
	ДопПараметрыОповещения = New Structure("CurrentLine", CurrentLine);
	ПроверкаНеобходимостиОчищатьРезультаты(
			New NotifyDescription("ТабличноеПолеВидыОбъектовПередУдалениемЗавершение", 
										ThisObject, 
										ДопПараметрыОповещения
									)
	);
	
EndProcedure

&AtClient
Procedure ТабличноеПолеВидыОбъектовПередУдалениемЗавершение(Result, AdditionalParameters) Export
	If Not Result Then
		Return;
	EndIf;

	ТекСтрока=AdditionalParameters.CurrentLine;
	ТабличноеПолеВидыОбъектов.Delete(ТабличноеПолеВидыОбъектов.FindByID(ТекСтрока));

	Items.ТабличноеПолеВидыОбъектов.Update();
EndProcedure
Function УсечьМассив(Array, Массив2)
	Мас = New Array;

	For Each ТекЭлемент In Array Do
		If Массив2.Find(ТекЭлемент) = Undefined Then
			Continue;
		EndIf;

		Мас.Add(ТекЭлемент);
	EndDo;

	Return Мас;
EndFunction

&AtServer
Procedure ИнициализацияЗапроса()

	масЗапросовПоОбъектам = New Array;

	ВсегоСтрок = ТабличноеПолеВидыОбъектов.Count();
	//If ВсегоСтрок = 0 Then
	//	If Not QueryBuilder = Undefined And Not QueryBuilder.Filter = Undefined Then
	//		КоличествоОтборов = QueryBuilder.Filter.Count();
	//		For IndexOf = 1 To КоличествоОтборов Do
	//			QueryBuilder.Filter.Delete(КоличествоОтборов - IndexOf);
	//		EndDo; 
	//	EndIf; 
	//	QueryBuilder = Undefined;
	//	Return;
	//EndIf;	
	//If QueryBuilder = Undefined Then
	//	QueryBuilder = New QueryBuilder;
	//EndIf; 


	///============================= ИНИЦИАЛИЦАЗИЯ ПЕРЕМЕННЫХ
	МетаданныеОбъектов = Metadata[?(Object.ObjectType = 1, "Documents", "Catalogs")];
	ИмяТипаТаблицы = ?(Object.ObjectType = 1, "Document", "Catalog");
	Prefix = ?(Object.ОбрабатыватьТабличныеЧасти, "Reference.", "");

	МассивТипов = New Array;
	МассивТипов.Add(Type("ValueStorage"));
	ОписаниеТипаХранилище = New TypeDescription(МассивТипов);

	МассивТипов = New Array;
	СписокПредставлений.Clear(); //      = New ValueList;
	СтруктураРеквизитовШапки = New Structure;
	СтруктураРеквизитовТЧ = New Structure;
	СтруктураТиповОбъектов = New Structure;
	СтруктураКатегорий = New Structure;
	СтруктураСвойств = New Structure;
	//	МассивНастроекОтбора     = New Array;
	ТаблицаРеквизитов.Clear();

	ИмяВидаОдногоТипа = Undefined;
	ПрошлоеЗначение = Undefined;
	///============================= ПОДСЧЕТ ОДОИМЕННЫХ РЕКВИЗИТОВ
	For Each String In ТабличноеПолеВидыОбъектов Do

		If Not Object.ProcessTabularParts Then
			ИмяВида = String.TableName;
			ИмяТЧ="";
		Else
			ПозТЧК = Find(String.TableName, ".");
			ИмяВида = Left(String.TableName, ПозТЧК - 1);
			ИмяТЧ = Mid(String.TableName, ПозТЧК + 1);
		EndIf;

		If МетаданныеОбъектов.Find(ИмяВида) = Undefined Then
			Continue;
		EndIf;

		МетаданныеСтрокиОбъектов=МетаданныеОбъектов[ИмяВида];

		МетаданныеРеквизитов = МетаданныеСтрокиОбъектов.Attributes;

		If Object.ProcessTabularParts Then
			МетаданныеРеквизитовТЧ = МетаданныеСтрокиОбъектов.TabularSections[ИмяТЧ].Attributes;
		EndIf;

		If Object.ObjectType = 1 Then
			If МетаданныеСтрокиОбъектов.NumberLength > 0 Then
				СтруктураРеквизитовШапки.Insert("Number", ?(СтруктураРеквизитовШапки.Property("Number",
					ПрошлоеЗначение), ПрошлоеЗначение + 1, 1));
			EndIf;

			Filter = New Structure;
			Filter.Insert("Name", "Number");
			Filter.Insert("ЭтоТЧ", False);
			МассивСтрок = ТаблицаРеквизитов.FindRows(Filter);
			If МетаданныеСтрокиОбъектов.NumberType = Metadata.ObjectProperties.DocumentNumberType.String Then
				ТекТип = ОписаниеТипа("String");
			Else
				ТекТип = ОписаниеТипа("Number");
			EndIf;

			If МассивСтрок.Count() > 0 Then
				СтрокаРеквизитов = МассивСтрок[0];
			Else
				СтрокаРеквизитов = ТаблицаРеквизитов.Add();
				СтрокаРеквизитов.Name = "Number";
				СтрокаРеквизитов.Presentation = "Number";
				СтрокаРеквизитов.Type = ТекТип;
				СтрокаРеквизитов.ЭтоТЧ = False;
			EndIf;

			СтрокаРеквизитов.Type = New TypeDescription(УсечьМассив(СтрокаРеквизитов.Type.Types(), ТекТип.Types()));

			СтруктураРеквизитовШапки.Insert("Date", ?(СтруктураРеквизитовШапки.Property("Date", ПрошлоеЗначение), ПрошлоеЗначение
				+ 1, 1));

			Filter = New Structure;
			Filter.Insert("Name", "Date");
			Filter.Insert("ЭтоТЧ", False);
			МассивСтрок = ТаблицаРеквизитов.FindRows(Filter);
			ТекТип = ОписаниеТипа("Date");

			If МассивСтрок.Count() > 0 Then
				СтрокаРеквизитов = МассивСтрок[0];
			Else
				СтрокаРеквизитов = ТаблицаРеквизитов.Add();
				СтрокаРеквизитов.Name = "Date";
				СтрокаРеквизитов.Presentation = "Date";
				СтрокаРеквизитов.Type = ТекТип;
				СтрокаРеквизитов.ЭтоТЧ = False;
			EndIf;
			СтрокаРеквизитов.Type = New TypeDescription(УсечьМассив(СтрокаРеквизитов.Type.Types(), ТекТип.Types()));

			СтруктураРеквизитовШапки.Insert("Posted", ?(СтруктураРеквизитовШапки.Property("Posted",
				ПрошлоеЗначение), ПрошлоеЗначение + 1, 1));

			Filter = New Structure;
			Filter.Insert("Name", "Posted");
			Filter.Insert("ЭтоТЧ", False);
			МассивСтрок = ТаблицаРеквизитов.FindRows(Filter);
			ТекТип = ОписаниеТипа("Boolean");

			If МассивСтрок.Count() > 0 Then
				СтрокаРеквизитов = МассивСтрок[0];
			Else
				СтрокаРеквизитов = ТаблицаРеквизитов.Add();
				СтрокаРеквизитов.Name = "Posted";
				СтрокаРеквизитов.Presentation = "Posted";
				СтрокаРеквизитов.Type = ТекТип;
				СтрокаРеквизитов.ЭтоТЧ = False;
			EndIf;
			СтрокаРеквизитов.Type = New TypeDescription(УсечьМассив(СтрокаРеквизитов.Type.Types(), ТекТип.Types()));
		Else
			If МетаданныеСтрокиОбъектов.CodeLength > 0 Then
				СтруктураРеквизитовШапки.Insert("Code", ?(СтруктураРеквизитовШапки.Property("Code", ПрошлоеЗначение), ПрошлоеЗначение
					+ 1, 1));

				Filter = New Structure;
				Filter.Insert("Name", "Code");
				Filter.Insert("ЭтоТЧ", False);
				МассивСтрок = ТаблицаРеквизитов.FindRows(Filter);
				If МетаданныеСтрокиОбъектов.CodeType = Metadata.ObjectProperties.CatalogCodeType.String Then
					ТекТип = ОписаниеТипа("String");
				Else
					ТекТип = ОписаниеТипа("Number");
				EndIf;

				If МассивСтрок.Count() > 0 Then
					СтрокаРеквизитов = МассивСтрок[0];
				Else
					СтрокаРеквизитов = ТаблицаРеквизитов.Add();
					СтрокаРеквизитов.Name = "Code";
					СтрокаРеквизитов.Presentation = "Code";
					СтрокаРеквизитов.Type = ТекТип;
					СтрокаРеквизитов.ЭтоТЧ = False;
				EndIf;
				СтрокаРеквизитов.Type = New TypeDescription(УсечьМассив(СтрокаРеквизитов.Type.Types(), ТекТип.Types()));
			EndIf;

			If МетаданныеСтрокиОбъектов.DescriptionLength > 0 Then
				СтруктураРеквизитовШапки.Insert("Title", ?(СтруктураРеквизитовШапки.Property("Title",
					ПрошлоеЗначение), ПрошлоеЗначение + 1, 1));

				Filter = New Structure;
				Filter.Insert("Name", "Title");
				Filter.Insert("ЭтоТЧ", False);
				МассивСтрок = ТаблицаРеквизитов.FindRows(Filter);
				ТекТип = ОписаниеТипа("String");

				If МассивСтрок.Count() > 0 Then
					СтрокаРеквизитов = МассивСтрок[0];
				Else
					СтрокаРеквизитов = ТаблицаРеквизитов.Add();
					СтрокаРеквизитов.Name = "Title";
					СтрокаРеквизитов.Presentation = "Title";
					СтрокаРеквизитов.Type = ТекТип;
					СтрокаРеквизитов.ЭтоТЧ = False;
				EndIf;
				СтрокаРеквизитов.Type = New TypeDescription(УсечьМассив(СтрокаРеквизитов.Type.Types(), ТекТип.Types()));
			EndIf;
		EndIf;

		If ИмяВидаОдногоТипа = Undefined Then
			ИмяВидаОдногоТипа = ИмяВида;
		ElsIf ИмяВидаОдногоТипа <> ИмяВида Then
			ИмяВидаОдногоТипа = False;
		EndIf;

		For Each РеквизитМетаданного In МетаданныеОбъектов[ИмяВида].Attributes Do

			If РеквизитМетаданного.Type = ОписаниеТипаХранилище Then
				Continue;
			ElsIf РеквизитМетаданного.Name = "Type" Then
				Continue;
			EndIf;

			СтруктураРеквизитовШапки.Insert(РеквизитМетаданного.Name, ?(СтруктураРеквизитовШапки.Property(
				РеквизитМетаданного.Name, ПрошлоеЗначение), ПрошлоеЗначение + 1, 1));

			Filter = New Structure;
			Filter.Insert("Name", РеквизитМетаданного.Name);
			Filter.Insert("ЭтоТЧ", False);
			МассивСтрок = ТаблицаРеквизитов.FindRows(Filter);

			If МассивСтрок.Count() > 0 Then
				СтрокаРеквизитов = МассивСтрок[0];
			Else
				СтрокаРеквизитов = ТаблицаРеквизитов.Add();
				СтрокаРеквизитов.Name = РеквизитМетаданного.Name;
				СтрокаРеквизитов.Presentation = РеквизитМетаданного.Synonym;
				СтрокаРеквизитов.Type = РеквизитМетаданного.Type;
				СтрокаРеквизитов.ЭтоТЧ = False;
			EndIf;

			СтрокаРеквизитов.Type = New TypeDescription(УсечьМассив(СтрокаРеквизитов.Type.Types(),
				РеквизитМетаданного.Type.Types()));

		EndDo;

		If Object.ProcessTabularParts Then

			For Each РеквизитМетаданного In МетаданныеРеквизитовТЧ Do

				If РеквизитМетаданного.Type = ОписаниеТипаХранилище Then
					Continue;
				EndIf;

				СтруктураРеквизитовТЧ.Insert(РеквизитМетаданного.Name, ?(СтруктураРеквизитовТЧ.Property(
					РеквизитМетаданного.Name, ПрошлоеЗначение), ПрошлоеЗначение + 1, 1));

				Filter = New Structure;
				Filter.Insert("Name", РеквизитМетаданного.Name);
				Filter.Insert("ЭтоТЧ", True);
				МассивСтрок = ТаблицаРеквизитов.FindRows(Filter);

				If МассивСтрок.Count() > 0 Then
					СтрокаРеквизитов = МассивСтрок[0];
				Else
					СтрокаРеквизитов = ТаблицаРеквизитов.Add();
					СтрокаРеквизитов.Name = РеквизитМетаданного.Name;
					СтрокаРеквизитов.Presentation = РеквизитМетаданного.Synonym;
					СтрокаРеквизитов.Type = РеквизитМетаданного.Type;
					СтрокаРеквизитов.ЭтоТЧ = True;
				EndIf;

				СтрокаРеквизитов.Type = New TypeDescription(УсечьМассив(СтрокаРеквизитов.Type.Types(),
					РеквизитМетаданного.Type.Types()));
			EndDo;
		EndIf;
		СтруктураТиповОбъектов.Insert(МетаданныеОбъектов[ИмяВида].Name, Type(ИмяТипаТаблицы + "Reference." + ИмяВида));
	EndDo;
	If ИмяВидаОдногоТипа = False Then
		ИмяВидаОдногоТипа = Undefined;
	EndIf;
	ВКонфигурацииЕстьОстаткиНоменклатуры = Not Metadata.AccumulationRegisters.Find("ТоварыНаСкладах") = Undefined;
	КонтрольОстатковНоменклатуры = (Object.ObjectType = 0) And (ИмяВидаОдногоТипа = "Номенклатура")
		And ВКонфигурацииЕстьОстаткиНоменклатуры;
		//
	ДоступностьВВебПриложенииНоменклатуры = ВКонфигурацииЕстьУправлениеЗаказами And (ОБъект.ObjectType = 0)
		And (ИмяВидаОдногоТипа = "Номенклатура");

		///============================= ОПРЕДЕЛЕНИЕ ОБЩИХ СВОЙСТВ And КАТЕГОРИЙ
	For Each KeyAndValue In СтруктураТиповОбъектов Do
		МассивТипов.Add(KeyAndValue.Value);
	EndDo;
	//	ОписаниеВсехТипов = New TypeDescription(МассивТипов);


	///============================= ОПРЕДЕЛЕНИЕ СОСТАВА РЕКВИЗИТОВ
	Счетчик = 0;
	For Each KeyAndValue In СтруктураРеквизитовТЧ Do

		If Not KeyAndValue.Value = ВсегоСтрок Then

			СтруктураРеквизитовТЧ.Delete(KeyAndValue.Key);

		Else
			Счетчик = Счетчик + 1;
			СтруктураРеквизитовТЧ.Insert(KeyAndValue.Key, "Т_" + KeyAndValue.Key);

		EndIf;

	EndDo;

	Счетчик = 0;
	For Each KeyAndValue In СтруктураРеквизитовШапки Do

		If Not KeyAndValue.Value = ВсегоСтрок Then

			СтруктураРеквизитовШапки.Delete(KeyAndValue.Key);

		Else
			Счетчик = Счетчик + 1;
			СтруктураРеквизитовШапки.Insert(KeyAndValue.Key, "Ш_" + KeyAndValue.Key);
		EndIf;

	EndDo;

	///============================= ОПРЕДЕЛЕНИЕ ПОРЯДКА And ПРЕДСТАВЛЕНИЯ РЕКВИЗИТОВ
	СписокПредставлений.Add("Type " + ИмяТипаТаблицы + "а", "Ш_Вид");
	СписокПредставлений.Add("Type " + ИмяТипаТаблицы + "а", "Ш_ВидПредставление");
	СписокПредставлений.Add("Reference", "Object");

	If Object.ProcessTabularParts Then

		СписокПредставлений.Add("Name ТЧ", "Т_ТЧ");
		СписокПредставлений.Add("Name ТЧ", "Т_ТЧПредставление");
		СписокПредставлений.Add("№ строки", "Т_НомерСтроки");

		For Each KeyAndValue In СтруктураРеквизитовТЧ Do
			СписокПредставлений.Add(МетаданныеРеквизитовТЧ[KeyAndValue.Key].Presentation(),
				KeyAndValue.Value);
		EndDo;

	EndIf;

	СписокПредставлений.Add(Prefix + "Check удаления", "Ш_ПометкаУдаления");

	If Object.ObjectType = 0 And Not ИмяВидаОдногоТипа = Undefined Then

		If МетаданныеОбъектов[ИмяВидаОдногоТипа].Owners.Count() > 0 Then

			СтруктураРеквизитовШапки.Insert("Owner", "Ш_Владелец");

		EndIf;

		If МетаданныеОбъектов[ИмяВидаОдногоТипа].Hierarchical Then

			СтруктураРеквизитовШапки.Insert("Parent", "Ш_Родитель");

		EndIf;

	EndIf;

	//If КонтрольОстатковНоменклатуры Then
	//	
	//	СписокПредставлений.Add(Prefix+"Balance товара","Р_Остаток");
	//	СписокПредставлений.Add(Prefix+"Balance-Резерв товара","Р_Резерв");
	//	
	//EndIf;

	//If ДоступностьВВебПриложенииНоменклатуры Then
	//	
	//	СписокПредставлений.Add(Prefix+"Доступна в веб-приложении ""Управление заказами""","П_ДоступнаВВебПриложенииУпрЗаказами");
	//	
	//EndIf;
	For Each KeyAndValue In СтруктураРеквизитовШапки Do
		МетаданныеРеквизита = МетаданныеРеквизитов.Find(KeyAndValue.Key);
		If Not МетаданныеРеквизита = Undefined Then
			СписокПредставлений.Add(Prefix + МетаданныеРеквизита.Presentation(), KeyAndValue.Value);
		Else
			СписокПредставлений.Add(Prefix + KeyAndValue.Key, KeyAndValue.Value);
		EndIf;

	EndDo;

	For Each KeyAndValue In СтруктураКатегорий Do
		СписокПредставлений.Add(KeyAndValue.Value, KeyAndValue.Key);
	EndDo;

	For Each KeyAndValue In СтруктураСвойств Do
		СписокПредставлений.Add(KeyAndValue.Value, KeyAndValue.Key);
	EndDo;

	///============================= ДОБАВЛЕНИЕ ОБЩИХ РЕКВИЗИТОВ
	СтруктураРеквизитовШапки.Insert("DeletionMark", "Ш_ПометкаУдаления");

	If Object.ProcessTabularParts Then
		СтруктураРеквизитовТЧ.Insert("LineNumber", "Т_НомерСтроки");
	EndIf;

	///============================= ФОРМИРОВАНИЕ ТЕКСТА ЗАПРОСА
	ТекстЗапросаОкончание = "";

	//If Object.ObjectType = 1 Then
	//	
	//	ТекстЗапросаОкончание = ТекстЗапросаОкончание + "
	//	|УПОРЯДОЧИТЬ ПО
	//	|	Ш_Дата,
	//	|	Object";
	//	ПоляСортировки = "Ш_Дата,Object";
	//	
	//Else
	//	
	//	ТекстЗапросаОкончание = ТекстЗапросаОкончание + "
	//	|УПОРЯДОЧИТЬ ПО
	//	|	Ш_Вид,
	//	|	Object";
	//	ПоляСортировки = "Ш_Вид,Object";
	//	
	//EndIf;
	//
	//If Object.ProcessTabularParts Then
	//	ТекстЗапросаОкончание = ТекстЗапросаОкончание + ",
	//	|	Т_ТЧ,
	//	|	Т_НомерСтроки";
	//	ПоляСортировки = ПоляСортировки + ",Т_ТЧ,Т_НомерСтроки";
	//EndIf;
	QueryText = "";

	For Each String In ТабличноеПолеВидыОбъектов Do

		If Not Object.ProcessTabularParts Then
			ИмяВида = String.TableName;
		Else
			ПозТЧК = Find(String.TableName, ".");
			ИмяВида = Left(String.TableName, ПозТЧК - 1);
			ИмяТЧ = Mid(String.TableName, ПозТЧК + 1);
		EndIf;

		If МетаданныеОбъектов.Find(ИмяВида) = Undefined Then
			Continue;
		EndIf;

		МетаданныеСтрокиОбъектов=МетаданныеОбъектов[ИмяВида];

		МетаданныеРеквизитов = МетаданныеСтрокиОбъектов.Attributes;

		If Object.ProcessTabularParts Then
			МетаданныеРеквизитовТЧ = МетаданныеСтрокиОбъектов.TabularSections[ИмяТЧ].Attributes;
		EndIf;

		TableName = ИмяТипаТаблицы + "." + String.TableName;
		ПсевдонимТаблицы = StrReplace(TableName, ".", "_");

		///============================= ФОРМИРОВАНИЕ ТЕКСТА ЗАПРОСА ПО РЕКВИЗИТАМ
		ТекстЗапросаОбъект = "";
		ТекстЗапросаОбъект = ТекстЗапросаОбъект + "" + Chars.LF + "	""" + ИмяВида + """ КАК Ш_Вид";
		ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + Chars.LF + "	""" + StrReplace(
			МетаданныеОбъектов[ИмяВида].Presentation(), """", "") + """ КАК Ш_ВидПредставление";
		ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + Chars.LF + "	" + ПсевдонимТаблицы + "." + Prefix
			+ "Reference КАК Object";

		For Each KeyAndValue In СтруктураРеквизитовШапки Do
			МетаданноеРеквизита = МетаданныеРеквизитов.Find(KeyAndValue.Key);
			If Not МетаданноеРеквизита = Undefined And МетаданноеРеквизита.Type.ContainsType(Type("String"))
				And МетаданноеРеквизита.Type.StringQualifiers.Length = 0 Then
				ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + Chars.LF + "	ПОДСТРОКА(" + ПсевдонимТаблицы + "."
					+ Prefix + KeyAndValue.Key + ",1," + ОграничениеНаСтрокиНеограниченнойДлины + ")";
			Else
				ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + Chars.LF + "	" + ПсевдонимТаблицы + "." + Prefix
					+ KeyAndValue.Key;
			EndIf;
			ТекстЗапросаОбъект = ТекстЗапросаОбъект + " КАК " + KeyAndValue.Value;
		EndDo;

		If Object.ProcessTabularParts Then

			ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + Chars.LF + "	""" + ИмяТЧ + """ КАК Т_ТЧ";
			ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + Chars.LF + "	"""
				+ МетаданныеСтрокиОбъектов.TabularSections[ИмяТЧ].Presentation() + """ КАК Т_ТЧПредставление";

			For Each KeyAndValue In СтруктураРеквизитовТЧ Do

				МетаданноеРеквизита = МетаданныеРеквизитовТЧ.Find(KeyAndValue.Key);

				If Not МетаданноеРеквизита = Undefined And МетаданноеРеквизита.Type.ContainsType(Type("String"))
					And МетаданноеРеквизита.Type.StringQualifiers.Length = 0 Then

					ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + Chars.LF + "	ПОДСТРОКА(" + ПсевдонимТаблицы
						+ "." + KeyAndValue.Key + ",1," + ОграничениеНаСтрокиНеограниченнойДлины + ")";

				Else

					ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + Chars.LF + "	" + ПсевдонимТаблицы + "."
						+ KeyAndValue.Key;

				EndIf;

				ТекстЗапросаОбъект = ТекстЗапросаОбъект + " КАК " + KeyAndValue.Value;

			EndDo;
		EndIf;

		///============================= ФОРМИРОВАНИЕ ТЕКСТА ЗАПРОСА ПО СВОЙСТВАМ And КАТЕГОРИЯМ
		If ОтборПоКатегориям Then
		//
			//For каждого KeyAndValue In СтруктураКатегорий Do
			//	
			//	ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + Chars.LF + 
			//	"	ВЫБОР КОГДА Таблица_"+KeyAndValue.Key+".Category ЕСТЬ NULL ТОГДА ЛОЖЬ ИНАЧЕ ИСТИНА КОНЕЦ КАК " + KeyAndValue.Key;
			//	
			//EndDo; 
		EndIf;

		If ОтборПоСвойствам Then

		//For каждого KeyAndValue In СтруктураСвойств Do
			//	
			//	ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + Chars.LF + "	Таблица_"+KeyAndValue.Key+".Value КАК "+KeyAndValue.Key;
			//	
			//EndDo; 
		EndIf;

		///============================= ФОРМИРОВАНИЕ ТЕКСТА ЗАПРОСА ПО ОСТАТКАМ НОМЕНКЛАТУРЫ
		If КонтрольОстатковНоменклатуры Then

		//ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + "
			//|	ЕСТЬNULL(Таблица_Р_Остаток.КоличествоОстаток,0) Как Р_Остаток,
			//|	ЕСТЬNULL(Таблица_Р_Остаток.КоличествоОстаток, 0) - ЕСТЬNULL(Таблица_Р_Резерв.КоличествоОстаток, 0) КАК Р_Резерв";
		EndIf;

		If ДоступностьВВебПриложенииНоменклатуры Then

		//ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + "
			//|	ВЫБОР
			//|		КОГДА Таблица_П_Веб.Номенклатура ЕСТЬ NULL ТОГДА True
			//|		ИНАЧЕ False
			//|	КОНЕЦ КАК П_ДоступнаВВебПриложенииУпрЗаказами";
		EndIf;

		///============================= ФОРМИРОВАНИЕ ТЕКСТА ЗАПРОСА ПО "ИЗ" And "СОЕДИНЕНИЕ"
		ТекстЗапросаОбъект = ТекстЗапросаОбъект + Chars.LF + "ИЗ" + Chars.LF + "	" + TableName + " КАК "
			+ ПсевдонимТаблицы;
		If ОтборПоКатегориям Then
		//
			//For каждого KeyAndValue In СтруктураКатегорий Do
			//	
			//	ТекстЗапросаОбъект = ТекстЗапросаОбъект + "
			//	|	ЛЕВОЕ СОЕДИНЕНИЕ InformationRegister.КатегорииОбъектов КАК Таблица_"+KeyAndValue.Key+"
			//	|		ПО " + ПсевдонимТаблицы + ".Reference = Таблица_"+KeyAndValue.Key+".Object
			//	|		And (Таблица_"+KeyAndValue.Key+".Category = &"+KeyAndValue.Key+")";
			//	
			//	
			//EndDo;
		EndIf;

		If ОтборПоСвойствам Then

		//For каждого KeyAndValue In СтруктураСвойств Do
			//	
			//	ТекстЗапросаОбъект = ТекстЗапросаОбъект + "
			//	|	ЛЕВОЕ СОЕДИНЕНИЕ InformationRegister.ЗначенияСвойствОбъектов КАК Таблица_"+KeyAndValue.Key+"
			//	|		ПО " + ПсевдонимТаблицы + ".Reference = Таблица_"+KeyAndValue.Key+".Object
			//	|		And (Таблица_"+KeyAndValue.Key+".Property = &"+KeyAndValue.Key+")";
			//	
			//EndDo;
		EndIf;

		If КонтрольОстатковНоменклатуры Then

		//ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + "
			//|	ЛЕВОЕ СОЕДИНЕНИЕ AccumulationRegister.ТоварыНаСкладах.Balance КАК Таблица_Р_Остаток
			//|		ПО " + ПсевдонимТаблицы + ".Reference = Таблица_Р_Остаток.Номенклатура
			//|	ЛЕВОЕ СОЕДИНЕНИЕ AccumulationRegister.ТоварыВРезервеНаСкладах.Balance КАК Таблица_Р_Резерв
			//|		ПО " + ПсевдонимТаблицы + ".Reference = Таблица_Р_Резерв.Номенклатура";
			//
		EndIf;

		If ДоступностьВВебПриложенииНоменклатуры Then

		//ТекстЗапросаОбъект = ТекстЗапросаОбъект + "," + "
			//|	ЛЕВОЕ СОЕДИНЕНИЕ InformationRegister.НоменклатураНеиспользуемаяВВебУправленииЗаказами КАК Таблица_П_Веб
			//|	ПО " + ПсевдонимТаблицы + ".Reference = Таблица_П_Веб.Номенклатура";
			//
		EndIf;

		If Object.ObjectType = 0 And МетаданныеСтрокиОбъектов.Hierarchical And МетаданныеСтрокиОбъектов.HierarchyType
			= Metadata.ObjectProperties.HierarchyType.HierarchyFoldersAndItems Then

			ТекстЗапросаОбъект = ТекстЗапросаОбъект + "
													  |ГДЕ
													  |	" + ПсевдонимТаблицы + ".Reference.IsFolder = ЛОЖЬ";

		EndIf;

		QueryText = ?(QueryText = "", "StartChoosing ", QueryText + Chars.LF + Chars.LF + "ОБЪЕДИНИТЬ ВСЕ"
			+ Chars.LF + Chars.LF + "ВЫБРАТЬ") + ТекстЗапросаОбъект;

		ТекстЗапросаОбъект = "StartChoosing " + ТекстЗапросаОбъект + ТекстЗапросаОкончание;
		масЗапросовПоОбъектам.Add(ТекстЗапросаОбъект);

	EndDo;

	QueryText = QueryText + ТекстЗапросаОкончание;

	НовыйТекстЗапроса = "StartChoosing РАЗРЕШЕННЫЕ * ИЗ (" + QueryText + ") КАК _Таблица";

		///============================= СОХРАНЕНИЕ НАСТРОЕК ОТБОРА ПРЕДЫДУЩЕГО ЗАПРОСА
	//For IndexOf = 0 To ПостроительЗапроса_Отбор.Count() - 1 Do
	//	МассивНастроекОтбора.Add(ПостроительЗапроса_Отбор.Get(IndexOf));
	//EndDo; 

	///============================= ИНИЦИАЛИЗАЦИЯ ТЕКСТА And ПОЛЕЙ ЗАПРОСА


	//QueryText = GetQueryText();
	QueryText = НовыйТекстЗапроса;
	ТекстПроизвольногоЗапроса = QueryText;
	ОтборДанных = Undefined;
	QueryOptions.Clear();

	//QueryBuilder.Text = QueryText;
	//QueryBuilder.FillSettings();
	//
	//КоличествоПолей = QueryBuilder.AvailableFields.Count();
	//For к = 0 To КоличествоПолей - 1 Do
	//	ДоступноеПоле = QueryBuilder.AvailableFields[КоличествоПолей - к - 1];
	//	
	//	If QueryBuilder.SelectedFields.Find(ДоступноеПоле.Name) = Undefined Then
	//		QueryBuilder.AvailableFields.Delete(ДоступноеПоле);
	//	EndIf;
	//EndDo;
	//
	//КоличествоПолей = QueryBuilder.SelectedFields.Count();
	//For к = 0 To КоличествоПолей - 1 Do
	//	FieldName = QueryBuilder.SelectedFields[КоличествоПолей - к - 1].Name;
	//	ДоступноеПоле = QueryBuilder.AvailableFields.Find(FieldName);
	//	QueryBuilder.AvailableFields.Move(ДоступноеПоле,-1000);
	//	
	//EndDo;
	// 
	//
	//For каждого ЭлементПредставления In СписокПредставлений Do
	//	ДоступноеПоле = QueryBuilder.AvailableFields.Find(ЭлементПредставления.Presentation);
	//	If Not ДоступноеПоле = Undefined Then
	//		
	//		ДоступноеПоле.Presentation = ПолучитьПредставление(ЭлементПредставления);
	//		If Left(ДоступноеПоле.Name , 2) = "С_" Then
	//			ДоступноеПоле.ValueType = СтруктураСвойств[ДоступноеПоле.Name].ValueType;
	//		EndIf; 
	//		
	//	EndIf;
	//	 
	//EndDo; 
	//
	//FilterAvailableFields = QueryBuilder.Filter.GetAvailableFields();
	//FilterAvailableFields.Delete(FilterAvailableFields.Ш_ВидПредставление);
	//FilterAvailableFields.Ш_Ссылка.Fields.Clear();
	////FilterAvailableFields.Delete(FilterAvailableFields.Ш_Ссылка);
	//If Object.ProcessTabularParts Then
	//	FilterAvailableFields.Delete(FilterAvailableFields.Т_ТЧПредставление);
	//	FilterAvailableFields.Delete(FilterAvailableFields.Т_ТЧ);
	//EndIf; 
	//
	/////============================= ВОССТАНОВЛЕНИЕ НАСТРОЕК ОТБОРА ПРЕДЫДУЩЕГО ЗАПРОСА
	//For каждого FilterItem In МассивНастроекОтбора Do
	//	ДоступноеПоле = FilterAvailableFields.Find(FilterItem.DataPath);
	//	Try
	//		НовыйЭлементОтбора = QueryBuilder.Filter.Add(FilterItem.DataPath);
	//		НовыйЭлементОтбора.Use = FilterItem.Use;
	//		НовыйЭлементОтбора.ComparisonType = FilterItem.ComparisonType;
	//		НовыйЭлементОтбора.Value = FilterItem.Value;
	//		НовыйЭлементОтбора.ValueFrom = FilterItem.ValueFrom;
	//		НовыйЭлементОтбора.ValueTo = FilterItem.ValueTo;
	//	Except
	//	EndTry; 
	//EndDo; 
	//
	//
	ПредопределенныеРеквизиты = New ValueList;
	//Template = GetTemplate("ПредопределенныеРеквизиты");
	//Region = Template.Areas[?(Object.ObjectType = 0,"Catalogs","Documents")];
	//Счетчик = 0;
	//ВидОбъекта = "*";
	//For к =  Region.Top To Region.Bottom Do
	//	
	//	ТекВидОбъекта = TrimAll(Template.Region("R"+к+"C1").Text);
	//	
	//	If  ТекВидОбъекта <> "" Then
	//		If ТекВидОбъекта = "*" Then
	//			ВидОбъекта = ТекВидОбъекта;
	//		Else
	//			ВидОбъекта = ТекВидОбъекта;
	//		EndIf; 
	//		
	//	EndIf;
	//	
	//	If ИмяВидаОдногоТипа = ВидОбъекта ИЛИ ВидОбъекта = "*" Then
	//		
	//		ПолноеИмяРеквизита = TrimAll(Template.Region("R"+к+"C2").Text);
	//		LongDesc = TrimAll(Template.Region("R"+к+"C3").Text);
	//		ЧерезТочку = False;
	//		ПозТЧК = Find(ПолноеИмяРеквизита,".");
	//		ЭтоСоставнойРеквизит = Not(ПозТЧК = 0);
	//		ИмяКорня = "Ш_"+?(ПозТЧК = 0,ПолноеИмяРеквизита,Left(ПолноеИмяРеквизита,ПозТЧК-1));
	//		//CustomField = QueryBuilder.AvailableFields.Find(ИмяКорня);
	//		//While Not ПозТЧК = 0 And Not CustomField = Undefined Do
	//		//	ПолноеИмяРеквизита = Mid(ПолноеИмяРеквизита,ПозТЧК+1);
	//		//	ПозТЧК = Find(ПолноеИмяРеквизита,".");
	//		//	CustomField = CustomField.Fields.Find(?(ПозТЧК = 0,ПолноеИмяРеквизита,Left(ПолноеИмяРеквизита,ПозТЧК-1)));
	//		//	ЧерезТочку = True;
	//		//EndDo; 
	//		//If Not CustomField = Undefined Then
	//			If ЭтоСоставнойРеквизит Then
	//				Счетчик = Счетчик+1;
	//				//QueryBuilder.SelectedFields.Add(CustomField.DataPath,"Д_"+Счетчик);
	//				СписокПредставлений.Add(LongDesc,"Д_"+Счетчик);
	//				ПредопределенныеРеквизиты.Add(New Structure("Name,CustomField","Д_"+Счетчик,CustomField),LongDesc);
	//			Else
	//				ПредопределенныеРеквизиты.Add(New Structure("Name,CustomField",CustomField.Name,CustomField),LongDesc);
	//			EndIf; 
	//			
	//		//EndIf; 
	//		
	//	EndIf; 
	//EndDo; 
	////
	/////============================= 
	//ПостроительЗапроса_Отбор = QueryBuilder.Filter;
	//QueryBuilder.PresentationAdding = PresentationAdditionType.DontAdd;
	ОтображаемыеКолонки = New Structure("Ш_ВидПредставление,Ш_Ссылка");
	If Object.ProcessTabularParts Then
		ОтображаемыеКолонки.Insert("Т_ТЧПредставление");
		ОтображаемыеКолонки.Insert("Т_НомерСтроки");
	EndIf;
	мСформированныйРежим = New Structure("СписокПредставлений,ДанныеОтобраны,ИмяВидаОдногоТипа,ПредопределенныеРеквизиты,ОтображаемыеКолонки,СтруктураСвойств,СтруктураКатегорий",
		СписокПредставлений, False, ИмяВидаОдногоТипа, ПредопределенныеРеквизиты, ОтображаемыеКолонки, СтруктураСвойств,
		СтруктураКатегорий);

EndProcedure

// ИнициализацияЗапроса() 
&AtClient
Procedure ПроверкаНеобходимостиОчищатьРезультаты(ОписаниеОповещенияОЗавершении)

	ДополнительныеПараметрыОповщения=New Structure;
	ДополнительныеПараметрыОповщения.Insert("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении);

	If Not мСформированныйРежим = Undefined And мСформированныйРежим.ДанныеОтобраны Then
		ВопросОбОчисткеРезультатаОтбора(New NotifyDescription("ПроверкаНеобходимостиОчищатьРезультатыЗавершение",
			ThisObject, ДополнительныеПараметрыОповщения));
	EndIf;

	ПроверкаНеобходимостиОчищатьРезультатыЗавершение(True, ДополнительныеПараметрыОповщения);
EndProcedure

&AtClient
Procedure ПроверкаНеобходимостиОчищатьРезультатыЗавершение(Result, AdditionalParameters) Export
	ОповщениеОЗавершении=AdditionalParameters.ОписаниеОповещенияОЗавершении;
	If Result Then
		ОчиститьРезультаты();
		мСформированныйРежим = Undefined;
	EndIf;

	ExecuteNotifyProcessing(ОповщениеОЗавершении, Result);
EndProcedure
&AtClient
Procedure ВопросОбОчисткеРезультатаОтбора(ОписаниеОповещенияОЗавершении) Export
	Ответ = Undefined;

	ShowQueryBox(New NotifyDescription("ВопросОбОчисткеРезультатаОтбораЗавершение", ThisForm,
		New Structure("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении)),
		"Result отбора будет очищен. Continue?", QuestionDialogMode.OKCancel);
EndProcedure

&AtClient
Procedure ВопросОбОчисткеРезультатаОтбораЗавершение(РезультатВопроса, AdditionalParameters) Export

	ОписаниеОповещенияОЗавершении = AdditionalParameters.ОписаниеОповещенияОЗавершении;
	Result=РезультатВопроса = DialogReturnCode.Cancel;
	ExecuteNotifyProcessing(ОписаниеОповещенияОЗавершении, Result);

EndProcedure

// () 
&AtClient
Procedure ТабличноеПолеВидыОбъектовПослеУдаления(Item)
	ПроверкаНеобходимостиОчищатьРезультаты(New NotifyDescription("ТабличноеПолеВидыОбъектовПослеУдаленияЗавершение",
		ThisObject));
EndProcedure

&AtClient
Procedure ТабличноеПолеВидыОбъектовПослеУдаленияЗавершение(Result, AdditionalParameters) Export
	If Result Then
		ИнициализацияЗапроса();
	EndIf;
EndProcedure
Procedure ОчиститьРезультаты()
	НайденныеОбъекты.Clear();
EndProcedure

// () 
&AtServer
Procedure OnLoadDataFromSettingsAtServer(Settings)
	МассивСтрокКУдалению=New Array;
	МетаданныеОбъектов=Metadata[?(Object.ObjectType = 1, "Documents", "Catalogs")];

	For Each СтрокаТаблицы In ТабличноеПолеВидыОбъектов Do
		МассивИмени=StrSplit(СтрокаТаблицы.TableName, ".");

		ИмяВида=МассивИмени[0];
		If МетаданныеОбъектов.Find(ИмяВида) = Undefined Then
			МассивСтрокКУдалению.Add(СтрокаТаблицы);
		EndIf;
	EndDo;
	
	//Удаляем того что сейчас не можем обработать
	For Each УдаляемаяСтрока In МассивСтрокКУдалению Do
		ТабличноеПолеВидыОбъектов.Delete(УдаляемаяСтрока);
	EndDo;

	ИнициализацияЗапроса();
	FormAttributeToValue("Object").DownloadDataProcessors(ThisForm, AvailableDataProcessors, SelectedDataProcessors);

EndProcedure

&AtClient
Procedure ОбрабатыватьТабличныеЧастиПриИзменении(Item)
	ПроверкаНеобходимостиОчищатьРезультаты(New NotifyDescription("ОбрабатыватьТабличныеЧастиПриИзмененииЗавершение",
		ThisObject, New Structure("Item", Item)));
EndProcedure

&AtClient
Procedure ОбрабатыватьТабличныеЧастиПриИзмененииЗавершение(Result, AdditionalParameters) Export
	Item=AdditionalParameters.Item;
	If Result Then
		ТабличноеПолеВидыОбъектов.Clear();
		ИнициализацияЗапроса();
	Else
		Item.Value = Not Item.Value;
	EndIf;
EndProcedure

&AtClient
Procedure ТипОбъектаПриИзменении(Item)
	ТабличноеПолеВидыОбъектов.Clear();
	ИнициализацияЗапроса();
EndProcedure

&AtClient
Procedure НайденныеОбъектыВыбор(Item, SelectedRow, Field, StandardProcessing)
	ДанныеТекущейСтроки=НайденныеОбъекты.FindByID(SelectedRow);
	ShowValue(Undefined, ДанныеТекущейСтроки.Object);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_SetWriteSettings(Command)
	UT_CommonClient.EditWriteSettings(ThisObject);
EndProcedure

&AtClient
Procedure РедактироватьОбъект(Command)
	ТекДанные=Items.НайденныеОбъекты.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	UT_CommonClient.EditObject(ТекДанные.Object);
EndProcedure

&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) Export
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

