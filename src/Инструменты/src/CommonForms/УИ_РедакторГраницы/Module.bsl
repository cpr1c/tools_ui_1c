
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Вид = "Включая";
	
	ХранилищеКонтейнераЗначения = Неопределено;
	Если Параметры.Свойство("ХранилищеКонтейнераЗначения") Тогда
		//@skip-check unknown-form-parameter-access
		ХранилищеКонтейнераЗначения = Параметры.ХранилищеКонтейнераЗначения; //см. УИ_ОбщегоНазначенияКлиентСервер.НовыйХранилищеЗначенияТипаГраница
	КонецЕсли;

	Если ХранилищеКонтейнераЗначения <> Неопределено Тогда
		Дата = ХранилищеКонтейнераЗначения.Дата;
		Вид = ХранилищеКонтейнераЗначения.ВидГраницы;
	КонецЕсли;

КонецПроцедуры



#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы


#КонецОбласти

#Область ОбработчикиКомандФормы


&НаКлиенте
Процедура Применить(Команда)
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;

	Закрыть(УИ_ОбщегоНазначенияКлиентСервер.ЗначениеХранилищаКонтейнераГраницыПоДатеИВидуСтрокой(Дата, Вид));
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Код процедур и функций

#КонецОбласти
