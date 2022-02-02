&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("Title") Then
		Title  = Parameters.Title;
	EndIf;

	If Parameters.Property("ReturnOnlySelectedValues") Then
		ReturnOnlySelectedValues=Parameters.ReturnOnlySelectedValues;
	EndIf;

	ValueList=Parameters.List;
	If Parameters.Property("ТипЭлементов") Then
		If Parameters.ТипЭлементов <> Undefined И Parameters.ТипЭлементов <> Новый ОписаниеТипов Then
			ValueList.ТипЗначения=Parameters.ТипЭлементов;
		EndIf;
	EndIf;

	If Parameters.Property("ВидимостьПометки") Then
		Элементы.СписокЗначенийПометка.Видимость=Parameters.ВидимостьПометки;
	EndIf;
	If Parameters.Property("ВидимостьПредставления") Then
		Элементы.СписокЗначенийПредставление.Видимость=Parameters.ВидимостьПредставления;
	EndIf;

	If Parameters.Property("РежимПодбора") Then
		РежимПодбора=Parameters.РежимПодбора;
	Else
		РежимПодбора=Ложь;
	EndIf;

	Элементы.ValueList.ИзменятьПорядокСтрок=РежимПодбора;
	Элементы.ValueList.ИзменятьСоставСтрок=РежимПодбора;
	Элементы.СписокЗначенийЗначение.ТолькоПросмотр=Не РежимПодбора;
	Если Не РежимПодбора Then
		Элементы.ValueList.ПоложениеКоманднойПанели=ПоложениеКоманднойПанелиЭлементаФормы.Нет;
	EndIf;

	Если Parameters.Property("ДоступныеЗначения") Then
		Элементы.СписокЗначенийЗначение.РежимВыбораИзСписка=Истина;
		Элементы.СписокЗначенийЗначение.СписокВыбора.Очистить();

		Для Каждого ЭлементСписка Из Parameters.ДоступныеЗначения Цикл
			Элементы.СписокЗначенийЗначение.СписокВыбора.Добавить(ЭлементСписка.Значение, ЭлементСписка.Представление,
				ЭлементСписка.Пометка, ЭлементСписка.Картинка);
		КонецЦикла;
	EndIf;
	
EndProcedure

&AtClient
Procedure Apply(Command)
	Если Не ReturnOnlySelectedValues Then
		СписокВозврата=ValueList;
	Иначе
		СписокВозврата=Новый СписокЗначений;

		Для Каждого Элемент Из ValueList Цикл
			Если Не Элемент.Пометка Then
				Продолжить;
			EndIf;
			СписокВозврата.Добавить(Элемент.Значение, Элемент.Представление, Элемент.Пометка, Элемент.Картинка);
		КонецЦикла;
	EndIf;

	Закрыть(СписокВозврата);
EndProcedure