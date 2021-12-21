#Область ОписанияЭлементов

Функция НовыйОписаниеРеквизитаЭлемента() Экспорт
	СтруктураРеквизита = Новый Структура;

	СтруктураРеквизита.Вставить("СоздаватьРеквизит", Истина);
	СтруктураРеквизита.Вставить("Имя", "");
	СтруктураРеквизита.Вставить("ОписаниеТипов", Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(10)));
	СтруктураРеквизита.Вставить("ПутьКДанным", "");
	СтруктураРеквизита.Вставить("Заголовок", "");

	СтруктураРеквизита.Вставить("СоздаватьЭлемент", Истина);
	СтруктураРеквизита.Вставить("РодительЭлемента", Неопределено);
	СтруктураРеквизита.Вставить("ПередЭлементом", Неопределено);
	СтруктураРеквизита.Вставить("МногострочныйРежим", Неопределено);
	СтруктураРеквизита.Вставить("РасширенноеРедактирование", Неопределено);
	СтруктураРеквизита.Вставить("РастягиватьПоГоризонтали", Неопределено);
	СтруктураРеквизита.Вставить("РастягиватьПоВертикали", Неопределено);

	СтруктураРеквизита.Вставить("Параметры", НовыйПараметрыРеквизита());

	СтруктураРеквизита.Вставить("Действия", Новый Структура);

	Возврат СтруктураРеквизита;

КонецФункции

Функция НовыйПараметрыРеквизита()

	Параметры = Новый Структура;

	Параметры.Вставить("Тип", Тип("ПолеФормы"));
	Параметры.Вставить("Вид_ПоУмолчанию", ВидПоляФормы.ПолеВвода);

	Возврат Параметры;

КонецФункции

Функция НовыйОписаниеКомандыКнопки() Экспорт
	Структура = Новый Структура;

	Структура.Вставить("СоздаватьКоманду", Истина);
	Структура.Вставить("СоздаватьКнопку", Истина);

	Структура.Вставить("Имя", "");
	Структура.Вставить("Действие", "");
	Структура.Вставить("ИмяКоманды", "");
	Структура.Вставить("ЭтоГиперссылка", Ложь);
	Структура.Вставить("РодительЭлемента", Неопределено);
	Структура.Вставить("ПередЭлементом", Неопределено);
	Структура.Вставить("Заголовок", "");
	Структура.Вставить("Подсказка", "");
	Структура.Вставить("СочетаниеКлавиш", Неопределено);
	Структура.Вставить("Картинка", Неопределено);
	Структура.Вставить("Отображение", Неопределено);

	Возврат Структура;
КонецФункции

Функция НовыйОписаниеГруппыФормы() Экспорт
	Параметры = Новый Структура;

	Параметры.Вставить("Вид", ВидГруппыФормы.ОбычнаяГруппа);
	Параметры.Вставить("Имя", "");
	Параметры.Вставить("Заголовок", "");
	Параметры.Вставить("Поведение", ПоведениеОбычнойГруппы.Обычное);
	Параметры.Вставить("Отображение", ОтображениеОбычнойГруппы.Нет);
	Параметры.Вставить("Группировка", ГруппировкаПодчиненныхЭлементовФормы.Вертикальная);
	Параметры.Вставить("ОтображатьЗаголовок", Ложь);
	Параметры.Вставить("Родитель", Неопределено);

	Возврат Параметры;

КонецФункции


#КонецОбласти

#Область ПрограммноеСозданиеЭлементов

Функция СоздатьКомандуПоОписанию(Форма, ОписаниеКоманды) Экспорт
	Если Не ОписаниеКоманды.СоздаватьКоманду Тогда
		Возврат Неопределено;
	КонецЕсли;
	Команда = Форма.Команды.Добавить(ОписаниеКоманды.Имя);
	Команда.Заголовок = ОписаниеКоманды.Заголовок;
	Команда.Подсказка = ОписаниеКоманды.Подсказка;
	Команда.Действие = ОписаниеКоманды.Действие;
	Если ОписаниеКоманды.Картинка<>Неопределено Тогда
		Если Не UT_CommonClientServer.ЭтоПортативнаяПоставка()
			Или ОписаниеКоманды.Картинка.Вид = ВидКартинки.ИзБиблиотеки
			Или ОписаниеКоманды.Картинка.Вид = ВидКартинки.Пустая Тогда
			Команда.Картинка = ОписаниеКоманды.Картинка;
		КонецЕсли;
	КонецЕсли;
	Если ОписаниеКоманды.СочетаниеКлавиш <> Неопределено Тогда
		Команда.СочетаниеКлавиш = ОписаниеКоманды.СочетаниеКлавиш;
	КонецЕсли;
	Если ОписаниеКоманды.Отображение<>Неопределено Тогда
		Команда.Отображение=ОписаниеКоманды.Отображение;
	КонецЕсли;

	Возврат Команда;
КонецФункции

Функция СоздатьЭлементПоОписанию(Форма, ItemDescription) Экспорт
	Если Не ItemDescription.СоздаватьЭлемент Тогда
		Возврат Неопределено;
	КонецЕсли;

	ИмяЭлементаФормы = ИмяТаблицыПоляФормы(Форма, ItemDescription.РодительЭлемента) + ItemDescription.Имя;
	ЭлементФормы = Форма.Элементы.Найти(ИмяЭлементаФормы);
	Если ЭлементФормы <> Неопределено Тогда
		Возврат ЭлементФормы;
	КонецЕсли;

	Если ItemDescription.ПередЭлементом = Неопределено Тогда
		ЭлементФормы = Форма.Элементы.Добавить(ИмяТаблицыПоляФормы(Форма, ItemDescription.РодительЭлемента)
			+ ItemDescription.Имя, ItemDescription.Параметры.Тип, ЭлементФормы(Форма,
			ItemDescription.РодительЭлемента));
	Иначе
		ЭлементФормы = Форма.Элементы.Вставить(ИмяТаблицыПоляФормы(Форма, ItemDescription.РодительЭлемента)
			+ ItemDescription.Имя, ItemDescription.Параметры.Тип, ЭлементФормы(Форма,
			ItemDescription.РодительЭлемента), ЭлементФормы(Форма, ItemDescription.ПередЭлементом));
	КонецЕсли;

	ЭлементФормы.Заголовок = ItemDescription.Заголовок;

	Если Тип(ЭлементФормы) = Тип("ПолеФормы") Тогда
		ЭлементФормы.Вид = ItemDescription.Параметры.Вид_ПоУмолчанию;
		Попытка
			Если ТипЗнч(Реквизит(Форма, ItemDescription.Имя, ItemDescription.ПутьКРеквизиту)) = Тип("Булево") Тогда
				ЭлементФормы.Вид = ВидПоляФормы.ПолеФлажка;
			КонецЕсли;
		Исключение
		//			ОписаниеОшибки = ОписаниеОшибки();
		КонецПопытки;
	КонецЕсли;

	ЗаполнитьЗначенияСвойств(ЭлементФормы, ItemDescription.Параметры);

	Если Тип(ЭлементФормы) = Тип("ПолеФормы") Тогда
		Если ЗначениеЗаполнено(ItemDescription.ПутьКДанным) Тогда
			ЭлементФормы.ПутьКДанным = ItemDescription.ПутьКДанным;
		Иначе
			ЭлементФормы.ПутьКДанным = ItemDescription.Имя;
		КонецЕсли;

		Если ItemDescription.МногострочныйРежим <> Неопределено Тогда
			ЭлементФормы.МногострочныйРежим = ItemDescription.МногострочныйРежим;
		КонецЕсли;
		Если ItemDescription.РасширенноеРедактирование <> Неопределено Тогда
			ЭлементФормы.РасширенноеРедактирование = ItemDescription.РасширенноеРедактирование;
		КонецЕсли;

	КонецЕсли;
	Если ItemDescription.РастягиватьПоГоризонтали <> Неопределено Тогда
		ЭлементФормы.РастягиватьПоГоризонтали = ItemDescription.РастягиватьПоГоризонтали;
	КонецЕсли;
	Если ItemDescription.РастягиватьПоВертикали <> Неопределено Тогда
		ЭлементФормы.РастягиватьПоВертикали = ItemDescription.РастягиватьПоВертикали;
	КонецЕсли;

	Для Каждого Действие Из ItemDescription.Действия Цикл
		ЭлементФормы.УстановитьДействие(Действие.Ключ, Действие.Значение);
	КонецЦикла;
	Возврат ЭлементФормы;
КонецФункции

Функция СоздатьКнопкуПоОписанию(Форма, ОписаниеКнопки) Экспорт
	Если Не ОписаниеКнопки.СоздаватьКнопку Тогда
		Возврат Неопределено;
	КонецЕсли;

	Кнопка = Форма.Элементы.Вставить(ОписаниеКнопки.Имя, Тип("КнопкаФормы"), ЭлементФормы(Форма,
		ОписаниеКнопки.РодительЭлемента), ЭлементФормы(Форма, ОписаниеКнопки.ПередЭлементом));
	Если Не ОписаниеКнопки.СоздаватьКоманду Тогда
		Кнопка.Заголовок = ОписаниеКнопки.Заголовок;
	КонецЕсли;
	Если ОписаниеКнопки.ЭтоГиперссылка = Ложь Тогда
		Если ЭтоКнопкаКоманднойПанели(Форма, ОписаниеКнопки.РодительЭлемента) Тогда
			Кнопка.Вид = ВидКнопкиФормы.ОбычнаяКнопка;
		Иначе
			Кнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
		КонецЕсли;
	Иначе
		Если ЭтоКнопкаКоманднойПанели(Форма, ОписаниеКнопки.РодительЭлемента) Тогда
			Кнопка.Вид = ВидКнопкиФормы.Гиперссылка;
		Иначе
			Кнопка.Вид = ВидКнопкиФормы.ГиперссылкаКоманднойПанели;
		КонецЕсли;
	КонецЕсли;
	Кнопка.ИмяКоманды = ОписаниеКнопки.ИмяКоманды;
КонецФункции

Функция СоздатьГруппуПоОписанию(Форма, Описание) Экспорт

	ИмяЭлементаФормы = ИмяТаблицыПоляФормы(Форма, Описание.Родитель) + Описание.Имя;
	ГруппаФормы = Форма.Элементы.Найти(ИмяЭлементаФормы);
	Если ГруппаФормы <> Неопределено Тогда
		Возврат ГруппаФормы;
	КонецЕсли;
	ГруппаФормы = Форма.Элементы.Добавить(ИмяЭлементаФормы, Тип("ГруппаФормы"), ЭлементФормы(Форма, Описание.Родитель));

	ГруппаФормы.Вид = Описание.Вид;

	ГруппаФормы.Заголовок = Описание.Заголовок;

	ЗаполнитьЗначенияСвойств(ГруппаФормы, Описание, "Группировка,ОтображатьЗаголовок");

	Если ГруппаФормы.вид = ВидГруппыФормы.ОбычнаяГруппа Тогда
		ЗаполнитьЗначенияСвойств(ГруппаФормы, Описание, "Поведение,Отображение");
	КонецЕсли;
	//	Если Описание.РастягиватьПоГоризонтали<>Неопределено Тогда
	//		ГруппаФормы.РастягиватьПоГоризонтали=Описание.РастягиватьПоГоризонтали;
	//	КонецЕсли;
	//	Если Описание.РастягиватьПоВертикали<>Неопределено Тогда
	//		ГруппаФормы.РастягиватьПоВертикали=Описание.РастягиватьПоВертикали;
	//	КонецЕсли;
	Возврат ГруппаФормы;
КонецФункции


Функция ЭтоКнопкаКоманднойПанели(Форма, Знач РодительКнопки)
//@skip-warning
	Если РодительКнопки = Неопределено Тогда
		Возврат Ложь;
	ИначеЕсли РодительКнопки = Форма.КоманднаяПанель Тогда
		Возврат Истина;
	ИначеЕсли ТипЗнч(РодительКнопки) = UT_CommonClientServer.ManagedFormType() Тогда
		Возврат Ложь;
	Иначе
		РодительКнопки = ЭлементФормы(Форма, РодительКнопки);
		Возврат ЭтоКнопкаКоманднойПанели(Форма, РодительКнопки.Родитель);
	КонецЕсли;
КонецФункции

//@skip-warning
Функция ИмяТаблицыПоляФормы(Форма, Знач РодительЭлемента)
//@skip-warning
	Если РодительЭлемента = Неопределено Тогда
		Возврат "";
	ИначеЕсли ТипЗнч(РодительЭлемента) = Тип("ТаблицаФормы") Тогда
		Возврат РодительЭлемента.Имя;
	ИначеЕсли ТипЗнч(РодительЭлемента) = UT_CommonClientServer.ManagedFormType() Тогда
		Возврат "";
	Иначе
	//		РодительКнопки = ЭлементФормы(Форма, РодительЭлемента);
		Возврат ИмяТаблицыПоляФормы(Форма, РодительЭлемента.Родитель);
	КонецЕсли;
КонецФункции

Функция ЭлементФормы(Форма, Идентификатор) Экспорт
	Если ТипЗнч(Идентификатор) = Тип("Строка") Тогда
		Возврат Форма.Элементы.Найти(Идентификатор);
	Иначе
		Возврат Идентификатор;
	КонецЕсли;
КонецФункции


Функция Реквизит(Форма, ИмяРеквизита, ПутьКРеквизиту = "") Экспорт
	Если ПутьКРеквизиту <> "" Тогда
		Разделитель = СтрНайти(ПутьКРеквизиту, ".");
		Если Разделитель = 0 Тогда
			ИмяШага = ПутьКРеквизиту;
			ОстатокПути = "";
		Иначе
			ИмяШага = Лев(ПутьКРеквизиту, Разделитель - 1);
			ОстатокПути = Сред(ПутьКРеквизиту, Разделитель + 1);
		КонецЕсли;
		Возврат Реквизит(Форма[ИмяШага], ИмяРеквизита, ОстатокПути);
	Иначе
		НесуществующееЗначение = Неопределено;
		Структура = Новый Структура(ИмяРеквизита, НесуществующееЗначение);
		ЗаполнитьЗначенияСвойств(Структура, Форма);
		Если Структура[ИмяРеквизита] = НесуществующееЗначение Тогда
			Возврат НесуществующееЗначение;
		КонецЕсли;
		Возврат Форма[ИмяРеквизита];
	КонецЕсли;
КонецФункции

#КонецОбласти

#Область ПараметрыЗаписи

Процедура ФормаПриСозданииНаСервереСоздатьРеквизитыПараметровЗаписи(Форма, ГруппаФормы) Экспорт
	ПараметрыЗаписи=Новый Структура;
	ПараметрыЗаписи.Вставить("БезАвторегистрацииИзменений", Новый Структура("Значение,Заголовок", Ложь,
		"Без авторегистрации изменений"));
	ПараметрыЗаписи.Вставить("ЗаписьВРежимеЗагрузки", Новый Структура("Значение,Заголовок", Ложь,
		"Запись в режиме загрузки(Без проверок)"));
	ПараметрыЗаписи.Вставить("ПривелигированныйРежим", Новый Структура("Значение,Заголовок", Ложь,
		"Привелигированный режим"));
	ПараметрыЗаписи.Вставить("ИспользоватьДопСвойства", Новый Структура("Значение,Заголовок", Ложь,
		"Использовать доп. свойства"));
	ПараметрыЗаписи.Вставить("ДополнительныеСвойства", Новый Структура("Значение,Заголовок", Новый Структура,
		"Дополнительные свойства"));
	ПараметрыЗаписи.Вставить("ИспользоватьПроцедуруПередЗаписью", Новый Структура("Значение,Заголовок", Ложь,
		"Без авторегистрации изменений"));
	ПараметрыЗаписи.Вставить("ПроцедураПередЗаписью", Новый Структура("Значение,Заголовок", "",
		"Без авторегистрации изменений"));

	ПрефиксПараметра="ПараметрЗаписи_";

	МассивДобавляемыхРеквизитов=Новый Массив;

	Для Каждого КлючЗначение Из ПараметрыЗаписи Цикл
		ТипРеквизита=ТипЗнч(КлючЗначение.Значение.Значение);

		Если ТипРеквизита = Тип("Структура") Тогда
			ТипРеквизита=Тип("ТаблицаЗначений");
//			Продолжить;
		КонецЕсли;

		МассивТипов=Новый Массив;
		МассивТипов.Добавить(ТипРеквизита);
		НовыйРеквизит=Новый РеквизитФормы(ПрефиксПараметра + КлючЗначение.Ключ, Новый ОписаниеТипов(МассивТипов), "",
			КлючЗначение.Значение.Заголовок, Ложь);
		МассивДобавляемыхРеквизитов.Добавить(НовыйРеквизит);
	КонецЦикла;

	Форма.ИзменитьРеквизиты(МассивДобавляемыхРеквизитов);

	МассивДобавляемыхРеквизитов.Очистить();
	МассивДобавляемыхРеквизитов.Добавить(Новый РеквизитФормы("Ключ", Новый ОписаниеТипов("Строка"), ПрефиксПараметра
		+ "ДополнительныеСвойства", "Ключ", Ложь));

	МассивТиповЗначения=Новый Массив;
	МассивТиповЗначения.Добавить("Булево");
	МассивТиповЗначения.Добавить("Строка");
	МассивТиповЗначения.Добавить("Число");
	МассивТиповЗначения.Добавить("Дата");
	МассивТиповЗначения.Добавить("УникальныйИдентификатор");
	МассивТиповЗначения.Добавить("ЛюбаяСсылка");
	МассивДобавляемыхРеквизитов.Добавить(Новый РеквизитФормы("Значение", Новый ОписаниеТипов(МассивТиповЗначения),
		ПрефиксПараметра + "ДополнительныеСвойства", "Значение", Ложь));
	Форма.ИзменитьРеквизиты(МассивДобавляемыхРеквизитов);

	МассивДляСозданияЭлементов=UT_CommonClientServer.ПараметрыЗаписиДляВыводаНаФормуИнструмента();

	Для Каждого ИмяСоздаваемогоЭлемента Из МассивДляСозданияЭлементов Цикл
		ОписаниеЭлемента=НовыйОписаниеРеквизитаЭлемента();
		ОписаниеЭлемента.СоздаватьЭлемент = Истина;
		ОписаниеЭлемента.Имя=ПрефиксПараметра + ИмяСоздаваемогоЭлемента;
		ОписаниеЭлемента.РодительЭлемента = ГруппаФормы;
		ОписаниеЭлемента.Параметры.Вставить("Вид", ВидПоляФормы.ПолеФлажка);

		UT_Forms.СоздатьЭлементПоОписанию(Форма, ОписаниеЭлемента);
	КонецЦикла;
	
	//Добавляем кнопку редактирования настроек
	ОписаниеКнопки=НовыйОписаниеКомандыКнопки();
	ОписаниеКнопки.Имя=ПрефиксПараметра + "РедактироватьПараметрыЗаписи";
	ОписаниеКнопки.ИмяКоманды=ОписаниеКнопки.Имя;
	ОписаниеКнопки.РодительЭлемента=ГруппаФормы;
	ОписаниеКнопки.Заголовок="Другие параметры записи";
	ОписаниеКнопки.Картинка=БиблиотекаКартинок.ПараметрыВыводаКомпоновкиДанных;
	ОписаниеКнопки.ЭтоГиперссылка=Истина;
	ОписаниеКнопки.Действие="Подключаемый_НастроитьПараметрыЗаписи";

	UT_Forms.СоздатьКомандуПоОписанию(Форма, ОписаниеКнопки);
	UT_Forms.СоздатьКнопкуПоОписанию(Форма, ОписаниеКнопки);
КонецПроцедуры

#КонецОбласти

// English Code Area 

#Region ItemsDescription 
//Функция НовыйОписаниеРеквизитаЭлемента(
Function ItemAttributeNewDescription() Export
	AttributeStructure = New Structure;

	AttributeStructure.Insert("CreateAttribute", True);
	AttributeStructure.Insert("Name", "");
	AttributeStructure.Insert("TypeDescription", New TypeDescription("String", , , , New StringQualifiers(10)));
	AttributeStructure.Insert("DataPath", "");
	AttributeStructure.Insert("Title", "");

	AttributeStructure.Insert("CreateItem", True);
	AttributeStructure.Insert("ItemParent", Undefined);
	AttributeStructure.Insert("BeforeItem", Undefined);
	AttributeStructure.Insert("MultiLine", Undefined);
	AttributeStructure.Insert("ExtendedEdit", Undefined);
	AttributeStructure.Insert("HorizontalStretch", Undefined);
	AttributeStructure.Insert("VerticalStretch", Неопределено);

	AttributeStructure.Insert("Properties", AttributePropertiesNew());

	AttributeStructure.Insert("Actions", New Structure);

	Return AttributeStructure;

EndFunction
//Original Функция НовыйПараметрыРеквизита()
Function AttributePropertiesNew()

	AttributeProperties = New Structure;

	AttributeProperties.Insert("FormItemType", Тип("FormField"));
	AttributeProperties.Insert("Default_Type", FormFieldType.InputField);

	Return AttributeProperties;

EndFunction
// Original НовыйОписаниеКомандыКнопки
Function ButtonCommandNewDescription () export
	Structure = New Structure;

	Structure.Insert("CreateCommand", True);
	Structure.Insert("CreateButton", True);

	Structure.Insert("Name", "");
	Structure.Insert("Action", "");
	Structure.Insert("CommandName", "");
	Structure.Insert("IsHyperLink", False);
	Structure.Insert("ItemParent", Undefined);
	Structure.Insert("BeforeItem", Undefined);
	Structure.Insert("Title", "");
	Structure.Insert("ToolTip", "");
	Structure.Insert("Shortcut", Undefined);
	Structure.Insert("Pictire", Undefined);
	Structure.Insert("Representation", Undefined);

	Возврат Structure;
EndFunction
//Original НовыйОписаниеГруппыФормы
Function FormGroupNewDescription() Export
	Parameters = New Structure;

	Parameters.Insert("Type", FormGroupType.UsualGroup);
	Parameters.Insert("Name", "");
	Parameters.Insert("Title", "");
	Parameters.Insert("Behavior", UsualGroupBehavior.Usual);
	Parameters.Insert("Representation", UsualGroupRepresentation.None);
	Parameters.Insert("GroupType", ChildFormItemsGroup.Vertical);
	Parameters.Insert("ShowTitle", False);
	Parameters.Insert("Parent", Undefined);

	Return Parameters;

EndFunction
#EndRegion

#Region FormItemsProgramingCreation  
//Функция СоздатьКомандуПоОписанию(Форма, ОписаниеКоманды) Экспорт,
Function CreateCommandByDescription(Form, CommandDescription) Export
	If Не CommandDescription.CreateCommand Then
		Return Undefined;
	EndIf;
	Command = Form.Commands.Add(CommandDescription.Name);
	Command.Title = CommandDescription.Title;
	Command.ToolTip = CommandDescription.ToolTip;
	Command.Action = CommandDescription.Action;
	If CommandDescription.Picture<>Undefined Then
		if not UT_CommonClientServer.ЭтоПортативнаяПоставка()
			or CommandDescription.Picture.Type = PictureType.FromLib
			or CommandDescription.Picture.Type = PictureType.Empty then
			Command.Picture = CommandDescription.Picture;
		endif;
	EndIf;
	If CommandDescription.Shortcut <> Undefined Then
		Command.Shortcut = CommandDescription.Shortcut;
	Endif;
	If CommandDescription.Representation<>Undefined Then
		Command.Representation=CommandDescription.Representation;
	EndIf;

	Return Command;
EndFunction
// Функция СоздатьЭлементПоОписанию(Форма, ItemDescription) Экспорт
Function CreateItemByDescription(Form, ItemDescription) Export
	If  NOT ItemDescription.CreateItem Then
		Return Undefined;
	EndIf;

	FormItemName = FormFieldTableName(Form, ItemDescription.ItemParent) + ItemDescription.Name;
	FormItem = Form.Items.Find(FormItemName);
	If FormItem <> Undefined Then
		Return FormItem;
	EndIf;

	If ItemDescription.BeforeItem = Undefined Then
		FormItem = Form.Items.Add (FormFieldTableName(Form, ItemDescription.ItemParent)	+ ItemDescription.Name, ItemDescription.Properties.FormItemType, FormItem(Form,
			ItemDescription.ItemParent));
	Else
		FormItem = Form.Items.Insert(FormFieldTableName(Form, ItemDescription.ItemParent)
			+ ItemDescription.Name, ItemDescription.Properties.FormItemType, FormItem(Form,
			ItemDescription.ItemParent), FormItem(Form, ItemDescription.BeforeItem));
	EndIf;

	FormItem.Title = ItemDescription.Title;

	If Type(FormItem) = Type("FormField") Then
		FormItem.Type = ItemDescription.Properties.Default_Type;
		Try
			If TypeOf(Attribute(Form, ItemDescription.Name, ItemDescription.AttributePath)) = Type("Boolean") Then
				FormItem.Type = FormFieldType.CheckBoxField;
			EndIf;
		Except
		//			ErrorDescription = ErrorDescription();
		EndTry;
	EndIf;

	FillPropertyValues(FormItem, ItemDescription.Properties);

	If Тип(FormItem) = Тип("FormField") Then
		If ValueIsFilled(ItemDescription.DataPath) Then
			FormItem.DataPath = ItemDescription.DataPath;
		Else
			FormItem.DataPath = ItemDescription.Name;
		EndIf;

		If ItemDescription.MultiLine <> Undefined Then
			FormItem.MultiLine = ItemDescription.MultiLine;
		EndIf;
		If ItemDescription.ExtendedEdit <> Undefined Then
			FormItem.ExtendedEdit = ItemDescription.ExtendedEdit;
		EndIf;

	EndIf;
	If ItemDescription.HorizontalStretch <> Undefined Then
		FormItem.HorizontalStretch = ItemDescription.HorizontalStretch;
	EndIf;
	If ItemDescription.VerticalStretch <> Undefined Then
		FormItem.VerticalStretch = ItemDescription.VerticalStretch;
	EndIf;

	For Each Action In ItemDescription.Actions Do
		FormItem.SetAction(Action.Key, Action.Value);
	EndDo;
	Return FormItem;
EndFunction
//Original Функция СоздатьКнопкуПоОписанию(Форма, ОписаниеКнопки) Экспорт
Function CreateButtonByDescription(Form, ButtonDescription) Export
	If Not ButtonDescription.CreateButton Then
		Return Undefined;
	EndIf;

	Button = Form.Items.Insert(ButtonDescription.Name, Type("FormButton"), FormItem(Form,
		ButtonDescription.ItemParent), FormItem(Form, ButtonDescription.BeforeItem));
	IF Not ButtonDescription.CreateCommand Then
		Button.Title = ButtonDescription.Title;
	EndIf;
	If ButtonDescription.IsHyperlink = False Then
		If IsCommandBarButton(Form, ButtonDescription.ItemParent) Then
			Button.Type = FormButtonType.UsualButton;
		Else
			Button.Type = FormButtonType.CommandBarButton;
		EndIf;
	Else
		If IsCommandBarButton(Form, ButtonDescription.ItemParent) Then
			Button.Type = FormButtonType.Hyperlink;
		Else
			Button.Type = FormButtonType.CommandBarHyperlink;
		EndIf;
	EndIf;
	Button.CommandName = ButtonDescription.CommandName;
EndFunction
// Original СоздатьГруппуПоОписанию
Function CreateGroupByDescription(Form, Description) Export

	FormItemName = FormFieldTableName(Form, Description.Parent) + Description.Name;
	FormGroup = Form.Items.Find(FormItemName);
	If FormGroup <> Undefined Then
		Return FormGroup;
	EndIf;
	FormGroup = Form.Items.Add(FormItemName, Type("FormGroup"), FormItem(Form, Description.Parent));

	FormGroup.Type = Description.Type;

	FormGroup.Title = Description.Title;

	FillPropertyValues(FormGroup, Description, "Type,ShowTitle");

	If FormGroup.Type = FormGroupType.UsualGroup Then
		FillPropertyValues(FormGroup, Description, "Behavior,Representation");
	EndIf;
	//	If Description.HorizontalStretch<>Undefined Then
	//		FormGroup.HorizontalStretch=Description.HorizontalStretch;
	//	EndIf;
	//	If Description.VerticalStretch<>Undefined Then
	//		FormGroup.VerticalStretch=Description.VerticalStretch;
	//	Endif;
	Return FormGroup;
EndFunction
//TODO Функция ЭтоКнопкаКоманднойПанели(Форма, Знач РодительКнопки)
Function IsCommandBarButton(Form, Val ButtonParent)
//@skip-warning
	if ButtonParent = Undefined then
		Return Ложь;
	ElsIf ButtonParent = Form.CommandBar then
		Return True;
	ElsIf TypeOf(ButtonParent) = UT_CommonClientServer.ManagedFormType() then
		Return False;
	Else
		ButtonParent = FormItem(Form, ButtonParent);
		Return IsCommandBarButton(Form, ButtonParent.Parent);
	EndIf;
EndFunction
// Original ИмяТаблицыПоляФормы
//@skip-warning  
Function FormFieldTableName(Form, Val ItemParent)
//@skip-warning
	If ItemParent = Undefined Then
		Return "";
	ElsIf TypeOf(ItemParent) = Type("FormTable") Then
		Return ItemParent.Name;
	ElsIf TypeOf(ItemParent) = UT_CommonClientServer.ManagedFormType() Then
		Return "";
	Else
	//		ButtonParent = FormItem(Form, ItemParent);
		Return FormFieldTableName(Form, ItemParent.Parent);
	Endif;
EndFunction

// Original ЭлементФормы
Function FormItem(Form, ID) Export
	If TypeOf(ID) = Type("String") Then
		Return Form.Items.Find(ID);
	Else
		Return ID;
	Endif;
EndFunction
//Функция Реквизит(Форма, ИмяРеквизита, ПутьКРеквизиту = "") Экспорт
 Function Attribute(Form, AttributeName, AttributeDataPath = "") Export
	If AttributeDataPath <> "" Then
		Separator = StrFind(AttributeDataPath, ".");
		If Separator = 0 Then
			StepName = AttributeDataPath;
			DataPathRest= "";
		Else
			StepName = Left(AttributeDataPath, Separator - 1);
			DataPathRest = Mid(AttributeDataPath, Separator + 1);
		EndIf;
		Return Attribute(Form[StepName], AttributeName, DataPathRest);
	Else
		NonExistValue = Undefined;
		Structure = New Structure(AttributeName, NonExistValue);
		FillPropertyValues(Structure, Form);
		If Structure[AttributeName] = NonExistValue Then
			Return NonExistValue;
		EndIf;
		Return Form[AttributeName];
	EndIf;
EndFunction
#EndRegion

#Region PostingSettings  
  // Процедура ФормаПриСозданииНаСервереСоздатьРеквизитыПараметровЗаписи(Форма, ГруппаФормы) Экспорт
  Procedure CreateWriteParametersAttributesFormOnCreateAtServer(Form, FormGroup) Export
  		 ФормаПриСозданииНаСервереСоздатьРеквизитыПараметровЗаписи(Form, FormGroup) 
  EndProcedure	
  
  Procedure CreateWriteParametersAttributesFormOnCreateAtServer_InTest(Form, FormGroup) Export
	WriteSettings=New Structure;
	WriteSettings.Insert("БезАвторегистрацииИзменений", New Structure("Значение,Заголовок", Ложь,
		"Без авторегистрации изменений"));
	WriteSettings.Insert("ЗаписьВРежимеЗагрузки", New Structure("Значение,Заголовок", Ложь,
		"Запись в режиме загрузки(Без проверок)"));
	WriteSettings.Insert("ПривелигированныйРежим", New Structure("Значение,Заголовок", Ложь,
		"Привелигированный режим"));
	WriteSettings.Insert("ИспользоватьДопСвойства", New Structure("Значение,Заголовок", Ложь,
		"Использовать доп. свойства"));
	WriteSettings.Insert("ДополнительныеСвойства", New Structure("Значение,Заголовок", New Structure,
		"Дополнительные свойства"));
	WriteSettings.Insert("ИспользоватьПроцедуруПередЗаписью", New Structure("Значение,Заголовок", Ложь,
		"Без авторегистрации изменений"));
	WriteSettings.Insert("ПроцедураПередЗаписью", New Structure("Значение,Заголовок", "",
		"Без авторегистрации изменений"));

	ParameterPrefix="ПараметрЗаписи_";

	AddedAtributesArray=New Array;

	For Each KeyValue In WriteSettings Do
		AttributeType=ТипЗнч(KeyValue.Value.Value);

		If AttributeType = Type ("Structure") Then
			AttributeType= Type ("ValueTable");
//			Продолжить;
		EndIf;

		TypesArray=New Array;
		TypesArray.Add(AttributeType);
		NewAttribute=New FormAttribute(ParameterPrefix + KeyValue.Key, New TypeDescription(TypesArray), "",
			KeyValue.Value.Title, False);
		AddedAtributesArray.Add(NewAttribute);
	EndDo;

	Form.ChangeAttributes(AddedAtributesArray);

	AddedAtributesArray.Clear();
	AddedAtributesArray.Add(New FormAttribute("Ключ", New TypeDescription("Строка"), ParameterPrefix
		+ "ДополнительныеСвойства", "Ключ", False));

	ValueTypesArray=New Массив;
	ValueTypesArray.Add("Булево");
	ValueTypesArray.Add("Строка");
	ValueTypesArray.Add("Число");
	ValueTypesArray.Add("Дата");
	ValueTypesArray.Add("УникальныйИдентификатор");
	ValueTypesArray.Add("ЛюбаяСсылка");
	AddedAtributesArray.Add(New FormAttribute("Значение", New TypeDescription(ValueTypesArray),
		ParameterPrefix + "ДополнительныеСвойства", "Значение", False));
	Form.ChangeAttributes(AddedAtributesArray);

	CreatingAttributesArray=UT_CommonClientServer.ПараметрыЗаписиДляВыводаНаФормуИнструмента();

	Для Каждого CreatingAttributeName Из CreatingAttributesArray Цикл
		ItemDescription=ItemAttributeNewDescription();
		ItemDescription.CreateItem = Истина;
		ItemDescription.Name=ParameterPrefix + CreatingAttributeName;
		ItemDescription.ItemParent = FormGroup;
		ItemDescription.Parameters.Insert("FormItemType", ВидПоляФормы.ПолеФлажка);

		UT_Forms.CreateItemByDescription(Form, ItemDescription);
	КонецЦикла;
	
	//Добавляем кнопку редактирования настроек
	ButtonDescription=ButtonCommandNewDescription();
	ButtonDescription.Имя=ParameterPrefix + "РедактироватьПараметрыЗаписи";
	ButtonDescription.ИмяКоманды=ButtonDescription.Имя;
	ButtonDescription.РодительЭлемента=FormGroup;
	ButtonDescription.Title="Другие параметры записи";
	ButtonDescription.Картинка=БиблиотекаКартинок.ПараметрыВыводаКомпоновкиДанных;
	ButtonDescription.IsHyperLink=Истина;
	ButtonDescription.Action="Attachable_SetWriteSettings";

	UT_Forms.CreateCommandByDescription(FormGroup, ButtonDescription);
	UT_Forms.CreateButtonByDescription(FormGroup, ButtonDescription);
EndProcedure
  
#EndRegion
