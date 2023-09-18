
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Элементы.КаталогХраненияДанныхИнстументовНаСервере.ПодсказкаВвода = УИ_ОбщегоНазначения.КаталогДанныхИнструментовНаСервереПоУмолчанию();

	ПрочитатьНастройкиИнструментов();
	УстановитьВидимостьЭлементов();
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)

	ВариантыРедактораКода = УИ_РедакторКодаКлиентСервер.ВариантыРедактораКода();
	
	Если РедакторКода1С = ВариантыРедактораКода.Monaco Тогда
		ПроверяемыеРеквизиты.Добавить("ТемаРедактораMonaco");
		ПроверяемыеРеквизиты.Добавить("ЯзыкСинтаксисаРедактораMonaco");
	КонецЕсли;

	НомерСтроки = 1;
	Для Каждого Стр Из КаталогиИсходныхФайловКонфигурации Цикл
		Если Не ЗначениеЗаполнено(Стр.Источник) 
			И ЗначениеЗаполнено(Стр.Каталог) Тогда
			УИ_ОбщегоНазначенияКлиентСервер.СообщитьПользователю("В строке " + НомерСтроки
				+ " не заполнен источник исходного кода",,,, Отказ);
		КонецЕсли;
		
		НомерСтроки = НомерСтроки +1;
	КонецЦикла;

	ТЗИсточников = КаталогиИсходныхФайловКонфигурации.Выгрузить(, "Источник");
	ТЗИсточников.Свернуть("Источник");
	
	Для Каждого Стр ИЗ ТЗИсточников Цикл
		СтруктураПоиска = Новый Структура;
		СтруктураПоиска.Вставить("Источник", Стр.Источник);

		НайденныеСтроки = КаталогиИсходныхФайловКонфигурации.НайтиСтроки(СтруктураПоиска);

		Если НайденныеСтроки.Количество() > 1 Тогда
			УИ_ОбщегоНазначенияКлиентСервер.СообщитьПользователю("С источником исходного кода " + Стр.Источник
				+ " обнаружено более одной строки. Запись невозможна",,,, Отказ);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура РедакторКода1СПриИзменении(Элемент)
	УстановитьВидимостьЭлементов();
КонецПроцедуры

&НаКлиенте
Процедура КаталогиИсходныхФайловКонфигурацииКаталогНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ТекДанные = Элементы.КаталогиИсходныхФайловКонфигурации.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОписаниеФайла = УИ_ОбщегоНазначенияКлиент.ПустаяСтруктураОписанияВыбираемогоФайла();
	ОписаниеФайла.ИмяФайла = ТекДанные.Каталог;
	
	ДопПараметрыОповещения = Новый Структура;
	ДопПараметрыОповещения.Вставить("ТекущаяСтрока", Элементы.КаталогиИсходныхФайловКонфигурации.ТекущаяСтрока);
	
	УИ_ОбщегоНазначенияКлиент.ПолеФормыИмяФайлаНачалоВыбора(ОписаниеФайла, Элемент, ДанныеВыбора, СтандартнаяОбработка,
		РежимДиалогаВыбораФайла.ВыборКаталога,
		Новый ОписаниеОповещения("КаталогиИсходныхФайловКонфигурацииКаталогНачалоВыбораЗаверешение", ЭтотОбъект,
		ДопПараметрыОповещения));
КонецПроцедуры

&НаКлиенте
Процедура ШаблоныКодаИмяФайлаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ТекДанные = Элементы.ШаблоныКода.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОписаниеФайла = УИ_ОбщегоНазначенияКлиент.ПустаяСтруктураОписанияВыбираемогоФайла();
	ОписаниеФайла.ИмяФайла = ТекДанные.ИмяФайла;
	УИ_ОбщегоНазначенияКлиент.ДобавитьФорматВОписаниеФайлаСохранения(ОписаниеФайла, "Файл шаблона кода(*.st)", "st");
	
	ДопПараметрыОповещения = Новый Структура;
	ДопПараметрыОповещения.Вставить("ТекущаяСтрока", Элементы.ШаблоныКода.ТекущаяСтрока);
	
	УИ_ОбщегоНазначенияКлиент.ПолеФормыИмяФайлаНачалоВыбора(ОписаниеФайла, Элемент, ДанныеВыбора, СтандартнаяОбработка,
		РежимДиалогаВыбораФайла.Открытие,
		Новый ОписаниеОповещения("ШаблоныКодаИмяФайлаНачалоВыбораЗаверешение", ЭтотОбъект,
		ДопПараметрыОповещения));
КонецПроцедуры

#КонецОбласти


#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура Применить(Команда)
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	ПрименитьНаСервере();
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура СохранитьМодулиКонфигурацииВФайлы(Команда)
	
	ТекущиеКаталоги = Новый Соответствие;
	Для Каждого ТекСтрока Из КаталогиИсходныхФайловКонфигурации Цикл
		Если Не ЗначениеЗаполнено(ТекСтрока.Источник) 
			Или Не ЗначениеЗаполнено(ТекСтрока.Каталог) Тогда
				Продолжить;
		КонецЕсли;

		ТекущиеКаталоги.Вставить(ТекСтрока.Источник, ТекСтрока.Каталог);
	КонецЦикла;
	
	УИ_РедакторКодаКлиент.СохранитьМодулиКонфигурацииВФайлы(
		Новый ОписаниеОповещения("СохранитьМодулиКонфигурацииВФайлыЗавершение", ЭтотОбъект), ТекущиеКаталоги);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ПрочитатьНастройкиИнструментов()
	ПрочитатьПараметрыРедактораКода();
	
	КаталогХраненияДанныхИнстументовНаСервере = УИ_ОбщегоНазначения.КаталогДанныхИнструментовНаСервереИзНастроек(); 
КонецПроцедуры

&НаСервере
Процедура ПрочитатьПараметрыРедактораКода()
	УстановитьСписокВыбораЭлементаИзСтруктуры(Элементы.РедакторКода1С,
		УИ_РедакторКодаКлиентСервер.ВариантыРедактораКода());
	
	УстановитьСписокВыбораЭлементаИзСтруктуры(Элементы.ТемаРедактораMonaco,
		УИ_РедакторКодаКлиентСервер.ВариантыТемыРедактораMonaco());
	
	УстановитьСписокВыбораЭлементаИзСтруктуры(Элементы.ЯзыкСинтаксисаРедактораMonaco,
		УИ_РедакторКодаКлиентСервер.ВариантыЯзыкаСинтаксисаРедактораMonaco());

	ПараметрыРедактора = УИ_РедакторКодаСервер.ТекущиеПараметрыРедактораКода();	
	РедакторКода1С = ПараметрыРедактора.Вариант;
	РазмерШрифта = ПараметрыРедактора.РазмерШрифта;	

	ТемаРедактораMonaco = ПараметрыРедактора.Monaco.Тема;
	ЯзыкСинтаксисаРедактораMonaco = ПараметрыРедактора.Monaco.ЯзыкСинтаксиса;
	ИспользоватьКартуКода = ПараметрыРедактора.Monaco.ИспользоватьКартуКода;
	СкрытьНомераСтрок = ПараметрыРедактора.Monaco.СкрытьНомераСтрок;
	ВысотаСтрок = ПараметрыРедактора.Monaco.ВысотаСтрок;
	ОтображатьПробелыИТабуляции = ПараметрыРедактора.Monaco.ОтображатьПробелыИТабуляции;
	ИспользоватьСтандартныеШаблоныКода = ПараметрыРедактора.Monaco.ИспользоватьСтандартныеШаблоныКода;

	КаталогиИсходныхФайловКонфигурации.Очистить();
	Элементы.КаталогиИсходныхФайловКонфигурацииИсточник.СписокВыбора.Очистить();
	ИсточникиИсходногоКода = УИ_РедакторКодаСервер.ДоступныеИсточникиИсходногоКода();
	
	Для Каждого ТекОписаниеКаталога Из ПараметрыРедактора.Monaco.КаталогиИсходныхФайлов Цикл
		НС = КаталогиИсходныхФайловКонфигурации.Добавить();
		НС.Каталог = ТекОписаниеКаталога.Каталог;
		НС.Источник = ТекОписаниеКаталога.Источник;
	
		Элементы.КаталогиИсходныхФайловКонфигурацииИсточник.СписокВыбора.Добавить(НС.Источник);
	КонецЦикла;

	ШаблоныКода.Очистить();
	Для Каждого ТекИмяФайла Из ПараметрыРедактора.Monaco.ФайлыШаблоновКода Цикл
		НС = ШаблоныКода.Добавить();
		НС.ИмяФайла = ТекИмяФайла;
	КонецЦикла;

	Для Каждого ТекИсточник Из ИсточникиИсходногоКода Цикл
		СтруктураПоиска = Новый Структура;
		СтруктураПоиска.Вставить("Источник", ТекИсточник.Значение);
		
		НайденныеСтроки = КаталогиИсходныхФайловКонфигурации.НайтиСтроки(СтруктураПоиска);
		Если НайденныеСтроки.Количество()>0 Тогда
			Продолжить;
		КонецЕсли;
		
		НС = КаталогиИсходныхФайловКонфигурации.Добавить();
		НС.Источник = ТекИсточник.Значение;
		
		Элементы.КаталогиИсходныхФайловКонфигурацииИсточник.СписокВыбора.Добавить(ТекИсточник.Значение);
		
	КонецЦикла;
КонецПроцедуры



&НаКлиенте
Процедура СохранитьМодулиКонфигурацииВФайлыЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого ТекКаталог ИЗ Результат Цикл
		СтруктураПоиска = Новый Структура;
		СтруктураПоиска.Вставить("Источник", ТекКаталог.Источник);
		
		НайденныеСтроки = КаталогиИсходныхФайловКонфигурации.НайтиСтроки(СтруктураПоиска);
		Если НайденныеСтроки.Количество() = 0 Тогда
			НС = КаталогиИсходныхФайловКонфигурации.Добавить();
			НС.Источник = ТекКаталог.Источник;
		Иначе
			НС = НайденныеСтроки[0];
		КонецЕсли;
		
		НС.Каталог = ТекКаталог.Каталог;
	КонецЦикла;
	
	Модифицированность = Истина;
КонецПроцедуры


&НаКлиенте
Процедура КаталогиИсходныхФайловКонфигурацииКаталогНачалоВыбораЗаверешение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Количество()=0 Тогда
		Возврат;
	КонецЕсли;
	
	ТекДанные = КаталогиИсходныхФайловКонфигурации.НайтиПоИдентификатору(ДополнительныеПараметры.ТекущаяСтрока);
	ТекДанные.Каталог = Результат[0];
	
	Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ШаблоныКодаИмяФайлаНачалоВыбораЗаверешение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Количество()=0 Тогда
		Возврат;
	КонецЕсли;
	
	ТекДанные = ШаблоныКода.НайтиПоИдентификатору(ДополнительныеПараметры.ТекущаяСтрока);
	ТекДанные.ИмяФайла = Результат[0];
	
	Модифицированность = Истина;
КонецПроцедуры


&НаСервере
Процедура УстановитьВидимостьЭлементов()
	Варианты = УИ_РедакторКодаКлиентСервер.ВариантыРедактораКода();
	
	ЭтоМонако = РедакторКода1С = Варианты.Monaco;
	
	Элементы.ГруппаРедакторКодаMonaco.Видимость = ЭтоМонако;
КонецПроцедуры

&НаСервере
Процедура УстановитьСписокВыбораЭлементаИзСтруктуры(Элемент, СтруктураДанных)
	Элемент.СписокВыбора.Очистить();
	Для Каждого КлючЗначение ИЗ СтруктураДанных Цикл
		Элемент.СписокВыбора.Добавить(КлючЗначение.Ключ, КлючЗначение.Значение);
	КонецЦикла;		
	
КонецПроцедуры

&НаСервере
Процедура ПрименитьНаСервере()
	ПараметрыРедактораКода = УИ_РедакторКодаКлиентСервер.ПараметрыРедактораКодаПоУмолчанию();
	ПараметрыРедактораКода.РазмерШрифта = РазмерШрифта;
	ПараметрыРедактораКода.Вариант = РедакторКода1С;
	
	ПараметрыРедактораКода.Monaco.Тема = ТемаРедактораMonaco;
	ПараметрыРедактораКода.Monaco.ЯзыкСинтаксиса = ЯзыкСинтаксисаРедактораMonaco;
	ПараметрыРедактораКода.Monaco.ИспользоватьКартуКода = ИспользоватьКартуКода;
	ПараметрыРедактораКода.Monaco.СкрытьНомераСтрок = СкрытьНомераСтрок;
	ПараметрыРедактораКода.Monaco.ВысотаСтрок = ВысотаСтрок;
	ПараметрыРедактораКода.Monaco.ОтображатьПробелыИТабуляции = ОтображатьПробелыИТабуляции;
	ПараметрыРедактораКода.Monaco.ИспользоватьСтандартныеШаблоныКода = ИспользоватьСтандартныеШаблоныКода;
	
	Для Каждого ТекСтрока Из КаталогиИсходныхФайловКонфигурации Цикл
		Если Не ЗначениеЗаполнено(ТекСтрока.Каталог) Тогда
			Продолжить;
		КонецЕсли;
	
		ОписаниеКаталога = УИ_РедакторКодаКлиентСервер.НовыйОписаниеКаталогаИсходныхФайловКонфигурации();
		ОписаниеКаталога.Источник = ТекСтрока.Источник;
		ОписаниеКаталога.Каталог = ТекСтрока.Каталог;
		
		ПараметрыРедактораКода.Monaco.КаталогиИсходныхФайлов.Добавить(ОписаниеКаталога);
	КонецЦикла;
	
	Для Каждого ТекСтрока Из ШаблоныКода Цикл
		ПараметрыРедактораКода.Monaco.ФайлыШаблоновКода.Добавить(ТекСтрока.ИмяФайла);
	КонецЦикла;
	
	УИ_РедакторКодаСервер.УстановитьНовыеНастройкиРедактораКода(ПараметрыРедактораКода);
	
	УИ_ОбщегоНазначения.СохранитьКаталогДанныхИнструментовНаСервереВНастройки(КаталогХраненияДанныхИнстументовНаСервере);
КонецПроцедуры
#КонецОбласти