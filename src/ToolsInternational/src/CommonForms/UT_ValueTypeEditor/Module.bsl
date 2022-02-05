#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	WorkMode=Parameters.StartMode;
	
	DataType=Parameters.DataType;
	If TypeOf(DataType)=Type("TypeDescription") Then
		InitialDataType=DataType;
	Иначе
		InitialDataType=New TypeDescription;
	EndIf;
	
	ЗаполнитьДанныеКвалификаторовПоПервоначальномуТипуДанных();
	
	ЗаполнитьДеревоТипов(True);
	
	УстановитьУсловноеОформление();
EndProcedure

#EndRegion

#Region FormItemsEvents


&AtClient
Procedure TypesTreeOnActivateRow(Item)
	CurrentData=Items.TypesTree.CurrentData;
	If CurrentData=Undefined Then
		Return;
	EndIf;
	
	Items.GroupNumberQualifier.Visible=CurrentData.Имя="Number";
	Items.GroupStringQualifier.Visible=CurrentData.Имя="String";
	Items.GroupDateQualifier.Visible=CurrentData.Имя="Date";
EndProcedure


&AtClient
Procedure UnlimitedStringLengthOnChange(Item)
	If UnlimitedStringLength Then
		StringLength=0;
		AcceptableFixedStringLength=False;
	EndIf;
	Items.AcceptableFixedStringLength.Enabled=Not UnlimitedStringLength;
EndProcedure

&AtClient
Procedure StringLengthOnChange(Item)
	If Not ValueIsFilled(StringLength) Then
		UnlimitedStringLength=True;
		AcceptableFixedStringLength=False;
	Иначе
		UnlimitedStringLength=False;
	EndIf;
	Items.AcceptableFixedStringLength.Enabled=Not UnlimitedStringLength;
EndProcedure

&AtClient
Procedure SearchStringOnChange(Item)
	ЗаполнитьДеревоТипов();
	РазвернутьЭлементыДерева();
EndProcedure

&AtClient
Procedure TypesTreeSelectedOnChange(Item)
		CurrentRow=Items.TypesTree.CurrentData;
	If CurrentRow=Undefined Then
		Return;
	EndIf;
	
	If CurrentRow.Selected Then
		If Not CompositeDataType Then
			SelectedTypes.Clear();
		 ElsIf CurrentRow.НедоступенДляСоставногоТипа Then
			If SelectedTypes.Количество()>0 Then
				ПоказатьВопрос(New NotifyDescription("ДеревоТиповВыбранПриИзмененииЗавершение", ЭтаФорма, New Structure("CurrentRow",CurrentRow)), "Selected тип, который не может быть включен в составной тип данных.
				|Будут исключены остальные типы данных.
				|Продолжить?",РежимДиалогаВопрос.ДаНет);
	        	Return;
			EndIf;
		Иначе
			ЕстьНедоступныйДляСоставногоТипа=False;
			For Each Эл In SelectedTypes Do
				If Эл.Пометка Then
					ЕстьНедоступныйДляСоставногоТипа=True;
					Break;
				EndIf;
			EndDo;
			
			If ЕстьНедоступныйДляСоставногоТипа Then
				ПоказатьВопрос(New NotifyDescription("ДеревоТиповВыбранПриИзмененииЗавершениеБылЗапрещенныйДляСоставногоТип", ЭтаФорма, New Structure("CurrentRow",CurrentRow)), "Ранее был Selected тип, который не может быть 
				|включен в составной тип данных и будет исключен.
				|Продолжить?",РежимДиалогаВопрос.ДаНет);
				Return;
			EndIf;
		EndIf;
	Иначе
		Элемент=SelectedTypes.НайтиПоЗначению(CurrentRow.Имя);
		If Элемент<>Undefined Then
			SelectedTypes.Удалить(Элемент);
		EndIf;
		
	EndIf;
	ДеревоТиповВыбранПриИзмененииФрагмент(CurrentRow);

EndProcedure


&AtClient
Procedure CompositeDataTypeOnChange(Item)
	If Not CompositeDataType Then
		If SelectedTypes.Количество()=0 Then
			ДобавитьВыбранныйType("Строка");
		EndIf;
		Тип=SelectedTypes[SelectedTypes.Количество()-1];
		SelectedTypes.Clear();
		ДобавитьВыбранныйType(Тип);
		
		УстановитьВыбранныеТипыВДереве(TypesTree,SelectedTypes);
	EndIf;
EndProcedure


#EndRegion

#Region ОбработчикиКомандФормы

&AtClient
Procedure Apply(Command)
	TypesArray=МассивВыбранныхТипов();
	
	ТипыСтрокой=New Array;
	ТипыТипом=New Array;
	
	For Each Тип ИЗ TypesArray Do
		If TypeOf(Тип) = Type("Тип") Then
			ТипыТипом.Add(Тип);
		Иначе
			ТипыСтрокой.Add(Тип);
		EndIf;
	EndDo;
	
	If NonnegativeNumber Then
		Знак=ДопустимыйЗнак.Неотрицательный;
	Иначе
		Знак=ДопустимыйЗнак.Любой;
	EndIf;
		
	КвалификаторЧисла=New NumberQualifiers(NumberLength,NumberPrecision,Знак);
	КвалификаторСтроки=New StringQualifiers(StringLength, ?(AcceptableFixedStringLength,ДопустимаяДлина.Фиксированная, ДопустимаяДлина.Переменная));
	
	If DateFormat=1 Then
		ЧастьДаты=ЧастиДаты.Время;
	 ElsIf DateFormat=2 Then
		ЧастьДаты=ЧастиДаты.ДатаВремя;
	Иначе
		ЧастьДаты=ЧастиДаты.Дата;
	EndIf;
	
	КвалификаторДаты=New DateQualifiers(ЧастьДаты);
	
	Описание=New TypeDescription;
	If ТипыТипом.Количество()>0 Then 
		Описание=New TypeDescription(Описание, ТипыТипом,,КвалификаторЧисла,КвалификаторСтроки,КвалификаторДаты);
	EndIf;
	If ТипыСтрокой.Количество()>0 Then 
		Описание=New TypeDescription(Описание, СтрСоединить(ТипыСтрокой,","),,КвалификаторЧисла,КвалификаторСтроки,КвалификаторДаты);
	EndIf;
	
	Закрыть(Описание);
EndProcedure

#EndRegion

#Region СлужебныеПроцедурыИФункции

&AtServer
Function ДоступноХранилищеЗначений()
	Return True;	
EndFunction
&AtServer
Function ДоступноNull()
	Return WorkMode<>0;	
EndFunction
&AtServer
Function ТипыДляЗапроса()
	Return WorkMode=1;	
EndFunction

&AtServer
Function ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,ИмяТипа, Картинка, Представление = "", СтрокаДерева = Undefined, ЭтоГруппа = False, Групповой=False, НедоступенДляСоставногоТипа=False)
	
	If ЗначениеЗаполнено(Представление) Then
		ПредставлениеТипа=Представление;
	Иначе
		ПредставлениеТипа=ИмяТипа;
	EndIf;

	If ЗначениеЗаполнено(SearchString) и Not Групповой Then
		If СтрНайти(НРег(ПредставлениеТипа), НРег(SearchString))=0 Then
			Return Undefined;
		EndIf;
	EndIf;
	
	If СтрокаДерева = Undefined Then
		ЭлементДобавления=TypesTree;
	Иначе
		ЭлементДобавления=СтрокаДерева;
	EndIf;

	НоваяСтрока=ЭлементДобавления.ПолучитьЭлементы().Add();
	НоваяСтрока.Имя=ИмяТипа;
	НоваяСтрока.Presentation=ПредставлениеТипа;
	НоваяСтрока.Picture=Картинка;
	НоваяСтрока.ЭтоГруппа=ЭтоГруппа;
	НоваяСтрока.НедоступенДляСоставногоТипа=НедоступенДляСоставногоТипа;
	
	If ЗаполнятьВыбранныеТипы Then
		Try
			ТекТип=Type(ИмяТипа);
		Except
			ТекТип=Undefined;
		EndTry;
		If ТекТип<>Undefined Then
			If InitialDataType.СодержитType(ТекТип) Then
				SelectedTypes.Add(НоваяСтрока.Имя,,НоваяСтрока.НедоступенДляСоставногоТипа);
			EndIf;
		EndIf;
	EndIf;

	
	Return НоваяСтрока;
EndFunction

&AtServer
Procedure ЗаполнитьТипыПоВидуОбъекта(ВидОбъектовМетаданных, TypePrefix, Картинка,ЗаполнятьВыбранныеТипы)
	КоллекцияОбъектов=Metadata[ВидОбъектовМетаданных];
	
	СтрокаКоллекции=ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,TypePrefix,Картинка,TypePrefix,,,True);
	
	For Each ОбъектМетаданных In КоллекцияОбъектов Do
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,TypePrefix+"."+ОбъектМетаданных.Имя, Картинка,ОбъектМетаданных.Имя,СтрокаКоллекции);
	EndDo;
	
	УдалитьСтрокуДереваЕслиНетПодчиненныхПриПоиске(СтрокаКоллекции);
EndProcedure

&AtServer
Procedure ЗаполнитьПримитивныеТипы(ЗаполнятьВыбранныеТипы)
	//ДобавитьТипВДеревоТипов("Произвольный", БиблиотекаКартинок.УИ_ПроизвольныйТип);
	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"Число", БиблиотекаКартинок.UT_Number);
	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"Строка", БиблиотекаКартинок.UT_String);
	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"Дата", БиблиотекаКартинок.UT_Date);
	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"Булево", БиблиотекаКартинок.UT_Boolean);
	If ДоступноХранилищеЗначений() Then      
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"ХранилищеЗначения", New Картинка);
	EndIf;
	If ТипыДляЗапроса() Then
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"ТаблицаЗначений", БиблиотекаКартинок.UT_ValueTable);
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"СписокЗначений", БиблиотекаКартинок.UT_ValueList);
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"Массив", БиблиотекаКартинок.UT_Array);
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"Тип", БиблиотекаКартинок.ВыбратьТип);
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"МоментВремени", БиблиотекаКартинок.UT_PointInTime);
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"Граница", БиблиотекаКартинок.UT_Boundary);
	EndIf;
	
	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"УникальныйИдентификатор", БиблиотекаКартинок.UT_UUID);
	If ДоступноNull() Then
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"Null", БиблиотекаКартинок.UT_Null);
	EndIf;
EndProcedure

&AtServer
Procedure ЗаполнитьТипыХарактеристик(ЗаполнятьВыбранныеТипы)
	//Характеристики
	ПланыВидов=Metadata.ПланыВидовХарактеристик;
	If ПланыВидов.Количество()=0 Then
		Return;
	EndIf;
	
	СтрокаХарактеристик=ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"Характеристики", БиблиотекаКартинок.Папка,,,True,True);
	
	For Each План In ПланыВидов Do
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"Характеристика."+План.Имя,New Картинка,План.Имя,СтрокаХарактеристик,,,True);
	EndDo;
	
	УдалитьСтрокуДереваЕслиНетПодчиненныхПриПоиске(СтрокаХарактеристик);

EndProcedure

&AtServer
Procedure ЗаполнитьОпределяемыеТипы(ЗаполнятьВыбранныеТипы)
	//Характеристики
	Типы=Metadata.ОпределяемыеТипы;
	If Типы.Количество()=0 Then
		Return;
	EndIf;
	
	СтрокаТипа=ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"ОпределяемыйТип", БиблиотекаКартинок.Папка,,,True, True);
	
	For Each ОпределяемыйТип In Типы Do
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"ОпределяемыйТип."+ОпределяемыйТип.Имя,New Картинка,ОпределяемыйТип.Имя,СтрокаТипа,,,True);
	EndDo;
	УдалитьСтрокуДереваЕслиНетПодчиненныхПриПоиске(СтрокаТипа);
EndProcedure

&AtServer
Procedure ЗаполнитьТипыСистемныеПеречисления(ЗаполнятьВыбранныеТипы)
	СтрокаТипа=ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"СистемныеПеречисления", БиблиотекаКартинок.Папка,"Системные перечисления",,True, True);

	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"ВидДвиженияНакопления",БиблиотекаКартинок.UT_AccumulationRecordType,,СтрокаТипа);
	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"ВидСчета",БиблиотекаКартинок.ПланСчетовОбъект,,СтрокаТипа);
	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"ВидДвиженияБухгалтерии",БиблиотекаКартинок.ПланСчетов,,СтрокаТипа);
	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"ИспользованиеАгрегатаРегистраНакопления",New Картинка,,СтрокаТипа);
	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"ПериодичностьАгрегатаРегистраНакопления",New Картинка,,СтрокаТипа);
	
	УдалитьСтрокуДереваЕслиНетПодчиненныхПриПоиске(СтрокаТипа);
EndProcedure

&AtServer
Procedure ЗаполнитьДеревоТипов(ЗаполнятьВыбранныеТипы=False)
	TypesTree.ПолучитьЭлементы().Clear();
	ЗаполнитьПримитивныеТипы(ЗаполнятьВыбранныеТипы);
	ЗаполнитьТипыПоВидуОбъекта("Справочники", "СправочникСсылка",БиблиотекаКартинок.Справочник,ЗаполнятьВыбранныеТипы);
	ЗаполнитьТипыПоВидуОбъекта("Документы", "ДокументСсылка",БиблиотекаКартинок.Документ,ЗаполнятьВыбранныеТипы);
	ЗаполнитьТипыПоВидуОбъекта("ПланыВидовХарактеристик", "ПланВидовХарактеристикСсылка", БиблиотекаКартинок.ПланВидовХарактеристик,ЗаполнятьВыбранныеТипы);
	ЗаполнитьТипыПоВидуОбъекта("ПланыСчетов", "ПланСчетовСсылка", БиблиотекаКартинок.ПланСчетов,ЗаполнятьВыбранныеТипы);
	ЗаполнитьТипыПоВидуОбъекта("ПланыВидовРасчета", "ПланВидовРасчетаСсылка", БиблиотекаКартинок.ПланВидовРасчета,ЗаполнятьВыбранныеТипы);
	ЗаполнитьТипыПоВидуОбъекта("ПланыОбмена", "ПланОбменаСсылка", БиблиотекаКартинок.ПланОбмена,ЗаполнятьВыбранныеТипы);
	ЗаполнитьТипыПоВидуОбъекта("Перечисления", "ПеречислениеСсылка", БиблиотекаКартинок.Перечисление,ЗаполнятьВыбранныеТипы);
	ЗаполнитьТипыПоВидуОбъекта("БизнесПроцессы", "БизнесПроцессСсылка", БиблиотекаКартинок.БизнесПроцесс,ЗаполнятьВыбранныеТипы);
	ЗаполнитьТипыПоВидуОбъекта("Задачи", "ЗадачаСсылка", БиблиотекаКартинок.Задача,ЗаполнятьВыбранныеТипы);
	//ЗаполнитьТипыПоВидуОбъекта("ТочкиМаршрутаБизнесПроцессаСсылка", "ТочкаМаршрутаБизнесПроцессаСсылка");
	
	ЗаполнитьТипыХарактеристик(ЗаполнятьВыбранныеТипы);
	Try
		ЗаполнитьОпределяемыеТипы(ЗаполнятьВыбранныеТипы);
	Except
	EndTry;
	ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"ЛюбаяСсылка", New Картинка, "Любая ссылка");

	
	If WorkMode=3 Then
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"СтандартнаяДатаНачала", New Картинка, "Стандартный дата начала");
		ДобавитьТипВДеревоТипов(ЗаполнятьВыбранныеТипы,"СтандартныйПериод", New Картинка, "Стандартный период");
		ЗаполнитьТипыСистемныеПеречисления(ЗаполнятьВыбранныеТипы);
	EndIf;
	
	УстановитьВыбранныеТипыВДереве(TypesTree,SelectedTypes);
EndProcedure

&AtServer
Procedure УстановитьУсловноеОформление()
	// Группы нелья выбирать
	НовоеУО=УсловноеОформление.Items.Add();
	НовоеУО.Использование=True;
	UT_CommonClientServer.SetFilterItem(НовоеУО.Отбор,
		"Items.TypesTree.ТекущиеДанные.ЭтоГруппа", True);
	Поле=НовоеУО.Поля.Items.Add();
	Поле.Использование=True;
	Поле.Поле=New ПолеКомпоновкиДанных("ДеревоТиповВыбран");

	Оформление=НовоеУО.Оформление.НайтиЗначениеПараметра(New ПараметрКомпоновкиДанных("Отображать"));
	Оформление.Использование=True;
	Оформление.Значение=False;
	
	// If строка неограниченная то нельзя менять допустимую длину строки
	НовоеУО=УсловноеОформление.Items.Add();
	НовоеУО.Использование=True;
	UT_CommonClientServer.SetFilterItem(НовоеУО.Отбор,
		"StringLength", 0);
	Поле=НовоеУО.Поля.Items.Add();
	Поле.Использование=True;
	Поле.Поле=New ПолеКомпоновкиДанных("AcceptableFixedStringLength");

	Оформление=НовоеУО.Оформление.НайтиЗначениеПараметра(New ПараметрКомпоновкиДанных("ТолькоПросмотр"));
	Оформление.Использование=True;
	Оформление.Значение=True;
	
	
EndProcedure

&AtServer
Procedure УдалитьСтрокуДереваЕслиНетПодчиненныхПриПоиске(СтрокаДерева)
	If Not ЗначениеЗаполнено(SearchString) Then
		Return;
	EndIf;
	If СтрокаДерева.ПолучитьЭлементы().Количество()=0 Then
		TypesTree.ПолучитьЭлементы().Удалить(СтрокаДерева);
	EndIf;
EndProcedure

&AtClient
Procedure РазвернутьЭлементыДерева()
	For каждого СтрокаДерева In TypesTree.ПолучитьЭлементы() Do 
		Items.TypesTree.Развернуть(СтрокаДерева.ПолучитьИдентификатор());
	EndDo;
EndProcedure

&НаКлиентеНаСервереБезКонтекста
Procedure УстановитьВыбранныеТипыВДереве(СтрокаДерева,ВыбранныеТипы)
	For Each Стр ИЗ СтрокаДерева.ПолучитьЭлементы() Do
		Стр.Selected=ВыбранныеТипы.НайтиПоЗначению(Стр.Имя)<>Undefined;
		
		УстановитьВыбранныеТипыВДереве(Стр, ВыбранныеТипы);
	EndDo;
EndProcedure

&AtClient
Procedure ДобавитьВыбранныйType(СтрокаДереваИлиТип)
	If TypeOf(СтрокаДереваИлиТип)=Type("Строка") Then
		ИмяТипа=СтрокаДереваИлиТип;
		НедоступенДляСоставногоТипа=False;
	 ElsIf TypeOf(СтрокаДереваИлиТип)=Type("ЭлементСпискаЗначений") Then
		ИмяТипа=СтрокаДереваИлиТип.Значение;
		НедоступенДляСоставногоТипа=СтрокаДереваИлиТип.Пометка;
	Иначе
		ИмяТипа=СтрокаДереваИлиТип.Имя;
		НедоступенДляСоставногоТипа=СтрокаДереваИлиТип.НедоступенДляСоставногоТипа;
	EndIf;
	
	If SelectedTypes.НайтиПоЗначению(ИмяТипа)=Undefined Then
		SelectedTypes.Add(ИмяТипа,,НедоступенДляСоставногоТипа);
	EndIf;
EndProcedure
&AtClient
Procedure ДеревоТиповВыбранПриИзмененииЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Ответ=РезультатВопроса;
	
	If Ответ=КодВозвратаДиалога.Нет Then
		ДополнительныеПараметры.CurrentRow.Selected=False;
		Return;
	КОнецЕсли;

	SelectedTypes.Clear();
	ДеревоТиповВыбранПриИзмененииФрагмент(ДополнительныеПараметры.CurrentRow);
EndProcedure
&AtClient
Procedure ДеревоТиповВыбранПриИзмененииЗавершениеБылЗапрещенныйДляСоставногоType(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Ответ=РезультатВопроса;
	
	If Ответ=КодВозвратаДиалога.Нет Then
		ДополнительныеПараметры.CurrentRow.Selected=False;
		Return;
	КОнецЕсли;

	МассивУдаляемыхЭлементов=New Array;
	For Each Эл In SelectedTypes Do 
		If Эл.Пометка Then
			МассивУдаляемыхЭлементов.Add(Эл);
		EndIf;
	EndDo;
	
	For Each Эл In  МассивУдаляемыхЭлементов Do
		SelectedTypes.Удалить(Эл);
	EndDo;
	
	ДеревоТиповВыбранПриИзмененииФрагмент(ДополнительныеПараметры.CurrentRow);
EndProcedure

&AtClient
Procedure ДеревоТиповВыбранПриИзмененииФрагмент(CurrentRow) Экспорт
		
	If CurrentRow.Selected Then
		ДобавитьВыбранныйType(CurrentRow);
	EndIf;

	If SelectedTypes.Количество()=0 Then
		ДобавитьВыбранныйType("Строка");
	EndIf;
	
	УстановитьВыбранныеТипыВДереве(TypesTree,SelectedTypes);
EndProcedure

&AtServer
Procedure AddTypesToArrayByMetadataCollection(TypesArray, Collection, TypePrefix)
	For each MetadataObject in Collection do
		TypesArray.Add(Type(TypePrefix+MetadataObject.Name));
	Enddo;
EndProcedure

&AtServer
Function МассивВыбранныхТипов()
	TypesArray=New Array;
	
	For Each ЭлементТипа In SelectedTypes Do
		СтрокаТипа=ЭлементТипа.Значение;
		
		If НРег(СтрокаТипа)="любаяссылка" Then
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Справочники,"СправочникСсылка.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Документы,"ДокументСсылка.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ПланыВидовХарактеристик,"ПланВидовХарактеристикСсылка.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ПланыСчетов,"ПланСчетовСсылка.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ПланыВидовРасчета,"ПланВидовРасчетаСсылка.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ПланыОбмена,"ПланОбменаСсылка.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Перечисления,"ПеречислениеСсылка.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.БизнесПроцессы,"БизнесПроцессСсылка.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Задачи,"ЗадачаСсылка.");
		 ElsIf СтрНайти(НРег(СтрокаТипа),"ссылка")>0 And СтрНайти(СтрокаТипа,".")=0 Then
			If НРег(СтрокаТипа)="справочникссылка" Then
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Справочники,"СправочникСсылка.");
			 ElsIf НРег(СтрокаТипа)="документссылка" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Документы,"ДокументСсылка.");
			 ElsIf НРег(СтрокаТипа)="планвидовхарактеристикссылка" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ПланыВидовХарактеристик,"ПланВидовХарактеристикСсылка.");
			 ElsIf НРег(СтрокаТипа)="плансчетовссылка" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ПланыСчетов,"ПланСчетовСсылка.");
			 ElsIf НРег(СтрокаТипа)="планвидоврасчетассылка" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ПланыВидовРасчета,"ПланВидовРасчетаСсылка.");
			 ElsIf НРег(СтрокаТипа)="планобменассылка" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ПланыОбмена,"ПланОбменаСсылка.");
			 ElsIf НРег(СтрокаТипа)="перечислениессылка" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Перечисления,"ПеречислениеСсылка.");
			 ElsIf НРег(СтрокаТипа)="бизнеспроцессссылка" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.БизнесПроцессы,"БизнесПроцессСсылка.");
			 ElsIf НРег(СтрокаТипа)="задачассылка" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Задачи,"ЗадачаСсылка.");
			EndIf;
		 ElsIf ЭлементТипа.Пометка Then
			МассивИмени=СтрРазделить(СтрокаТипа,".");
			If МассивИмени.Количество()<>2 Then
				Continue;
			EndIf;
			ИмяОбъекта=МассивИмени[1];
			If СтрНайти(НРег(СтрокаТипа),"характеристика")>0 Then
				ОбъектМД=Metadata.ПланыВидовХарактеристик[ИмяОбъекта];
			 ElsIf СтрНайти(НРег(СтрокаТипа),"определяемыйтип")>0 Then
				ОбъектМД=Metadata.ОпределяемыеТипы[ИмяОбъекта];
			Иначе
				Continue;
			EndIf;
			ОписаниеТипа=ОбъектМД.Тип;
			
			For Each ТекТип ИЗ ОписаниеТипа.Типы() Do
				TypesArray.Add(ТекТип);
			EndDo;
			
		Иначе
			TypesArray.Add(ЭлементТипа.Значение);
		EndIf;
	EndDo;
	
	Return TypesArray;
	
EndFunction

&AtServer
Procedure ЗаполнитьДанныеКвалификаторовПоПервоначальномуТипуДанных()
	NumberLength=InitialDataType.NumberQualifiers.Digits;
	NumberPrecision=InitialDataType.NumberQualifiers.FractionDigits;
	NonnegativeNumber= InitialDataType.NumberQualifiers.AllowedSign=AllowedSign.Nonnegative;
	
	StringLength=InitialDataType.StringQualifiers.Length;
	UnlimitedStringLength=Not ValueIsFilled(StringLength);
	AcceptableFixedStringLength=InitialDataType.StringQualifiers.AllowedLength=AllowedLength.Fixed;

	If InitialDataType.DateQualifiers.DateFractions=DateFractions.Time Then
		DateFormat= 1;
	 ElsIf InitialDataType.DateQualifiers.DateFractions=DateFractions.DateTime Then
		DateFormat=2;
	EndIf;
EndProcedure

#EndRegion