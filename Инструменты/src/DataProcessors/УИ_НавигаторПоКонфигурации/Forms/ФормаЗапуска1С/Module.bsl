
#Область ПоддержкаСтарыхВерсийПлатформы

&НаКлиентеНаСервереБезКонтекста
Функция вСтрНайти(Строка, Подстрока, НаправлениеПоиска = 1, Знач НачальнаяПозиция = Неопределено, НомерВхождения = 1)
	Возврат Найти(Строка, Подстрока);
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция вСтрШаблон(Шаблон, П1 = Неопределено, П2 = Неопределено)
	Результат = Шаблон;
	Если П1 <> Неопределено Тогда
		Результат = СтрЗаменить(Результат, "%1", П1);
	КонецЕсли;
	Если П2 <> Неопределено Тогда
		Результат = СтрЗаменить(Результат, "%2", П2);
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

#КонецОбласти


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Сервер = "SRV:3541";
	БазаДанных = "TEST";
	
	РежимЗапуска = 4;
	
	Папка1С = КаталогПрограммы();
	
	Поз = СтрНайти(Папка1С, "\", НаправлениеПоиска.СКонца,, 3);
	Если Поз <> 0 Тогда
		Папка1С = Лев(Папка1С, Поз);
		Стартер1С = Папка1С + "common\1cestart.exe";
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Запустить1С(Команда)
	СтрокаКоманды = вСформироватьСтрокуКоманды();
	Если не ПустаяСтрока(СтрокаКоманды) Тогда
		Попытка
			НачатьЗапускПриложения(новый ОписаниеОповещения("вПослеЗапускаПриложения", ЭтаФорма), СтрокаКоманды);
		Исключение
			Сообщить(ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура вПослеЗапускаПриложения(КодВозврата, ДопПарам = Неопределено) Экспорт
	// фиктивная процедура для совместимости разных версий платформы
КонецПроцедуры

&НаКлиенте
Процедура Стартер1СНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = ложь;
	
	Диалог = новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
	Диалог.Заголовок = "Путь к стартеру 1С";
	Диалог.Фильтр = "Стартер 1С|1cestart.exe";
	Диалог.ПроверятьСуществованиеФайла = истина;
	Если ПустаяСтрока(Стартер1С) Тогда
		Диалог.Каталог = КаталогПрограммы();
	Иначе
		Диалог.Каталог = вКаталогФайла(Стартер1С);
		Диалог.ПолноеИмяФайла = Стартер1С;
	КонецЕсли;
	Диалог.Показать(новый ОписаниеОповещения("Стартер1СНачалоВыбораДалее", ЭтаФорма));
КонецПроцедуры

&НаКлиенте
Процедура Стартер1СНачалоВыбораДалее(ВыбранныеФайлы, ДопПараметры = Неопределено) Экспорт
	Если ВыбранныеФайлы <> Неопределено Тогда
		Стартер1С = ВыбранныеФайлы[0];
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция вКаталогФайла(ПолноеИмяФайла)
	Поз = СтрНайти(ПолноеИмяФайла, "\", НаправлениеПоиска.СКонца,, 1);
	Если Поз = 0 Тогда
		Возврат ПолноеИмяФайла;
	Иначе
		Возврат Лев(ПолноеИмяФайла, Поз);
	КонецЕсли;
КонецФункции

&НаКлиенте
Функция вСформироватьСтрокуКоманды()
	Если ПустаяСтрока(Стартер1С) Тогда
		Сообщить("Не задан Стратер1С");
		Возврат "";
	ИначеЕсли ПустаяСтрока(Сервер) Тогда
		Сообщить("Не задан сервер приложений 1С");
		Возврат "";
	ИначеЕсли ПустаяСтрока(БазаДанных) Тогда
		Сообщить("Не задана база данных на сервере приложений 1С");
		Возврат "";
	КонецЕсли;
	
	СтрокаЗапуска = Стартер1С;
	
	Если РежимЗапуска = 1 Тогда
		СтрокаЗапуска = СтрокаЗапуска + " DESIGNER";
	ИначеЕсли РежимЗапуска = 2 Тогда
		СтрокаЗапуска = СтрокаЗапуска + " ENTERPRISE /RunModeOrdinaryApplication";
	ИначеЕсли РежимЗапуска = 3 Тогда
		СтрокаЗапуска = СтрокаЗапуска + " ENTERPRISE /RunModeManagedApplication";
	ИначеЕсли РежимЗапуска = 4 Тогда
		СтрокаЗапуска = СтрокаЗапуска + " ENTERPRISE";
	КонецЕсли;
	
	СтрокаЗапуска = вСтрШаблон(СтрокаЗапуска + " /S %1\%2", Сервер, БазаДанных);
	Если не ПустаяСтрока(ДопПараметры) Тогда
		СтрокаЗапуска = СтрокаЗапуска + " " + ДопПараметры;
	КонецЕсли;
	
	Возврат СтрокаЗапуска;
КонецФункции

&НаКлиенте
Процедура СформироватьСтрокуКоманды(Команда)
	СтрокаКоманды = вСформироватьСтрокуКоманды();
КонецПроцедуры
