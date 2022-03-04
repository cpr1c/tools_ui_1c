// Работа с регулярными выражениями из 1С
//
//MIT License
//
//Copyright (c) 2021 Центр прикладных разработок
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//
// URL:    https://github.com/cpr1c/RegEx1C_cfe
// Модуль реализован с помощью компоненты https://github.com/alexkmbk/RegEx1CAddin
#Region Public

// Возвращает текущую версию подсистемы
// 
// Возвращаемое значение:
// 	Строка - Версия подсистемы работы с регулярными выражениями
Function SubsystemVersion() Export
	Return "1.2";
EndFunction

// Возвращает объект компоненты работы с регулярными выражениями. Компонента должна быть предвариательно подключена.
// При неподключенной компоненте вызовется исключение
// 
// Возвращаемое значение:
// 	ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями. 
Function AddInObject() Export
	Return New ("AddIn." + AddInID() + ".RegEx");
EndFunction

#Region СинхронныеМетоды

// Используются синхронные вызовы
// Возвращает объект компоненты работы с регулярными выражениями. При необходимости происходит подключение и установка компоненты
// 
// Возвращаемое значение:
// 	ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями 
//  Неопределено - если не удалось подключить компоненту
Function КомпонентаРаботыСРегулярнымиВыражениями() Export
	Try
		Компонента= ПроинициализироватьКомпоненту(True);
		Компонента.ВызыватьИсключения=True;

		Return Компонента;
	Except
		ТекстОшибки = NStr(
			"ru = 'Не удалось подключить внешнюю компоненту для работы с регулярными выражениями: '");
		Message(ТекстОшибки + ErrorDescription());
		Return Undefined;
	EndTry;
EndFunction


// Возвращает версию компоненты работы с регулярными выражениями
// 
// Параметры:
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями (Необязательный)
// Возвращаемое значение:
// 	Строка - Версия используемой компоненты 
Function AddinVersion(AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРегулярныхВыражений(AddInObject);

	Version=AddInObject.Version();

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

	Return Version;
EndFunction


// Описание
// Метод выполняет поиск в переданном тексте по переданному регулярному выражению
// Параметры:
// 	СтрокаДляАнализа - Строка - Строка в которой необходимо выполнить поиск по регуляному выражению
// 	РегулярноеВыражение - Строка - Регулярное вырашение для выполнения поиска
// 	ИерархическийОбходРезультатов - Булево - Если установлено в Истина, то будет выполнен поиск с учетом подгрупп, в противном случае будет выведено единым списком(Необязательный)
// 	ВсеСовпадения - Булево - Если установлено в Истина, то поиск будет выполняться по всем совпадениям, а не только по первому.(Необязательный)
// 	ИгнорироватьРегистр - Булево - Если установлено в Истина, то поиск будет осуществляться без учета регистра (Необязательный)
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями (Необязательный)
// Возвращаемое значение:
// 	Соответствие - 	В ключах соответствия находятся найденные совпадения. 
//    				В значениях ключей массив, содержащий найденные подгруппы, если выполняется иерархический поиск, и неопределено, если поиск неиерархический.
Function НайтиСовпадения(СтрокаДляАнализа, РегулярноеВыражение, ИерархическийОбходРезультатов = False,
	ВсеСовпадения = False, ИгнорироватьРегистр = False, AddInObject = Undefined) Export

	EmptyAddin=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРегулярныхВыражений(AddInObject);
	AddInObject.ВсеСовпадения=ВсеСовпадения;
	AddInObject.ИгнорироватьРегистр=ИгнорироватьРегистр;

	Совпадения=New Map;

	AddInObject.НайтиСовпадения(СтрокаДляАнализа, РегулярноеВыражение, ИерархическийОбходРезультатов);

	While AddInObject.Next() Do
		Подгруппы=Undefined;
		If ИерархическийОбходРезультатов Then
			Подгруппы=New Array;

			КоличествоГрупп=AddInObject.КоличествоВложенныхГрупп();

			For НомерГруппы = 0 To КоличествоГрупп - 1 Do
				Подгруппы.Add(AddInObject.ПолучитьПодгруппу(НомерГруппы));
			EndDo;
		EndIf;

		Совпадения.Insert(AddInObject.CurrentValue, Подгруппы);
	EndDo;

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

	Return Совпадения;
EndFunction

// Описание
// Возвращает количество результатов поиска
// Параметры:
// 	СтрокаДляАнализа - Строка - Строка в которой необходимо выполнить поиск по регуляному выражению
// 	РегулярноеВыражение - Строка - Регулярное вырашение для выполнения поиска
// 	ВсеСовпадения - Булево - Если установлено в Истина, то поиск будет выполняться по всем совпадениям, а не только по первому.(Необязательный)
// 	ИгнорироватьРегистр - Булево - сли установлено в Истина, то поиск будет осуществляться без учета регистра (Необязательный)
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями (Необязательный)
// Возвращаемое значение:
// 	Число - Количество совпадений
Function КоличествоСовпадений(СтрокаДляАнализа, РегулярноеВыражение, ВсеСовпадения = False, ИгнорироватьРегистр = False,
	AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРегулярныхВыражений(AddInObject);
	AddInObject.ВсеСовпадения=ВсеСовпадения;
	AddInObject.ИгнорироватьРегистр=ИгнорироватьРегистр;

	AddInObject.НайтиСовпадения(СтрокаДляАнализа, РегулярноеВыражение);

	КоличествоСовпадений=AddInObject.Count();

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

	Return КоличествоСовпадений;
EndFunction

// Описание
// Возвращает ошибку, зафиксированную компонентой
// Параметры:
// 	AddInObject
// Возвращаемое значение:
// 	Строка - Описание ошибки, зафиксированной компонентой
Function ОписаниеОшибкиКомпоненты(AddInObject) Export
	Return AddInObject.ErrorDescription;
EndFunction

// Описание
// Делает проверку на соответствие текста регулярному выражению.
// Параметры:
// 	СтрокаДляАнализа - Строка - Строка в которой необходимо выполнить поиск по регуляному выражению
// 	РегулярноеВыражение - Строка - Регулярное вырашение для выполнения поиска
// 	ВсеСовпадения - Булево - Если установлено в Истина, то поиск будет выполняться по всем совпадениям, а не только по первому.(Необязательный)
// 	ИгнорироватьРегистр - Булево - Если установлено в Истина, то поиск будет осуществляться без учета регистра (Необязательный)
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями (Необязательный)
// Возвращаемое значение:
// Булево -	Возвращает значение Истина если текст соответствует регулярному выражению.
Function Совпадает(СтрокаДляАнализа, РегулярноеВыражение, ВсеСовпадения = False, ИгнорироватьРегистр = False,
	AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРегулярныхВыражений(AddInObject);
	AddInObject.ВсеСовпадения=ВсеСовпадения;
	AddInObject.ИгнорироватьРегистр=ИгнорироватьРегистр;

	Совпадает= AddInObject.Совпадает(СтрокаДляАнализа, РегулярноеВыражение);

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

	Return Совпадает;

EndFunction

// Описание
// 	Заменяет в переданном тексте часть, соответствующую регулярному выражению
// Параметры:
// 	ТекстДляАнализа - Строка - Строка в которой необходимо выполнить поиск по регуляному выражению
// 	РегулярноеВыражение - Строка - Регулярное вырашение для выполнения поиска
// 	ЗначениеДляЗамены - Строка - Строка, на которую необходимо заменить найденные совпадения
// 	ВсеСовпадения - Булево - Если установлено в Истина, то поиск будет выполняться по всем совпадениям, а не только по первому.(Необязательный)
// 	ИгнорироватьРегистр - Булево - Если установлено в Истина, то поиск будет осуществляться без учета регистра (Необязательный)
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями (Необязательный)
// Возвращаемое значение:
// 	Строка - результат замены.
Function Replace(СтрокаДляАнализа, РегулярноеВыражение, ЗначениеДляЗамены, ВсеСовпадения = False,
	ИгнорироватьРегистр = False, AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРегулярныхВыражений(AddInObject);
	AddInObject.ВсеСовпадения=ВсеСовпадения;
	AddInObject.ИгнорироватьРегистр=ИгнорироватьРегистр;

	Result= AddInObject.Replace(СтрокаДляАнализа, РегулярноеВыражение, ЗначениеДляЗамены);

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

	Return Result;
EndFunction
#EndRegion

#If Клиент Then
#Region АсинхронныеМетоды

// Начинает получение объекта внешней компоненты работы с регулярными выражениями. При необходимости будет произведено подключение и установка компоненты
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//<AddInObject> – Объект компоненты работы с регулярными выражениями, Тип: ВнешняяКомпонентаОбъект. Неопределено- если не удалось подключить компоненту
//<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
Procedure НачатьПолучениеКомпоненты(NotifyDescription) Export
	НачатьИнициализациюКомпоненты(NotifyDescription, True);
EndProcedure

// Начинает получение версии используемой компоненты работы с регулярными выражениями
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<AddinVersion> – Версия используемой компоненты, Тип: Строка. Неопределено- если не удалось подключить компоненту
//	<Параметры> - Параметры вызова метода компоненты.
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект компоненты работы с регулярными выражениями (Необязательный)
Procedure НачатьПолучениеВерсииКомпоненты(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		AdditionalParameters=New Structure;
		AdditionalParameters.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);

		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьПолучениеВерсииКомпонентыЗавершениеПолученияКомпоненты", ThisObject,
			AdditionalParameters));
	Else
		AddInObject.НачатьВызовВерсия(NotifyDescription);
	EndIf;
EndProcedure

// Описание
// 	начинает поиск в переданном тексте по переданному регулярному выражению
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<НайденныеСоответствия> – Соответствие - В ключах соответствия находятся найденные совпадения. 
//    				В значениях ключей массив, содержащий найденные подгруппы, если выполняется иерархический поиск, и неопределено, если поиск неиерархический.
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	СтрокаДляАнализа - Строка - Строка в которой необходимо выполнить поиск по регуляному выражению
// 	РегулярноеВыражение - Строка - Регулярное вырашение для выполнения поиска
// 	ИерархическийОбходРезультатов - Булево - Если установлено в Истина, то будет выполнен поиск с учетом подгрупп, в противном случае будет выведено единым списком(Необязательный)
// 	ВсеСовпадения - Булево - Если установлено в Истина, то поиск будет выполняться по всем совпадениям, а не только по первому.(Необязательный)
// 	ИгнорироватьРегистр - Булево - Если установлено в Истина, то поиск будет осуществляться без учета регистра (Необязательный)
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями (Необязательный)
Procedure НачатьНахождениеСовпадений(NotifyDescription, СтрокаДляАнализа, РегулярноеВыражение,
	ИерархическийОбходРезультатов = False, ВсеСовпадения = False, ИгнорироватьРегистр = False,
	AddInObject = Undefined) Export

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);
	AdditionalParameters.Insert("СтрокаДляАнализа", СтрокаДляАнализа);
	AdditionalParameters.Insert("РегулярноеВыражение", РегулярноеВыражение);
	AdditionalParameters.Insert("ИерархическийОбходРезультатов", ИерархическийОбходРезультатов);
	AdditionalParameters.Insert("ВсеСовпадения", ВсеСовпадения);
	AdditionalParameters.Insert("ИгнорироватьРегистр", ИгнорироватьРегистр);

	If AddInObject = Undefined Then
		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьНахождениеСовпаденийЗавершениеПолученияКомпоненты", ThisObject,
			AdditionalParameters));
	Else
		НачатьУстановкуСвойствКомпоненты(ВсеСовпадения, ИгнорироватьРегистр, AddInObject, NotifyDescription,
			New NotifyDescription("НачатьНахождениеСовпаденийЗавершениеУстановкиСвойств", ThisObject, AdditionalParameters));
	EndIf;
EndProcedure

// Описание
// 	Начинает получение количество совпадений в строке по регулярному выражению
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<Количество совпадений> – Число - Количество совпадений в строке регулярному выражению
//	<Параметры> - Массив - Массив параметров вызова метода компоненты.
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	СтрокаДляАнализа - Строка - Строка в которой необходимо выполнить поиск по регуляному выражению
// 	РегулярноеВыражение - Строка - Регулярное вырашение для выполнения поиска
// 	ВсеСовпадения - Булево - Если установлено в Истина, то поиск будет выполняться по всем совпадениям, а не только по первому.(Необязательный)
// 	ИгнорироватьРегистр - Булево - Если установлено в Истина, то поиск будет осуществляться без учета регистра (Необязательный)
// 	ИерархическийОбходРезультатов - Булево - Если установлено в Истина, то будет выполнен поиск с учетом подгрупп, в противном случае будет выведено единым списком(Необязательный)
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями (Необязательный)
Procedure НачатьПолучениеКоличестваСовпадений(NotifyDescription, СтрокаДляАнализа, РегулярноеВыражение,
	ВсеСовпадения = False, ИгнорироватьРегистр = False, ИерархическийОбходРезультатов = False,
	AddInObject = Undefined) Export

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);
	AdditionalParameters.Insert("СтрокаДляАнализа", СтрокаДляАнализа);
	AdditionalParameters.Insert("РегулярноеВыражение", РегулярноеВыражение);
	AdditionalParameters.Insert("ИерархическийОбходРезультатов", ИерархическийОбходРезультатов);
	AdditionalParameters.Insert("ВсеСовпадения", ВсеСовпадения);
	AdditionalParameters.Insert("ИгнорироватьРегистр", ИгнорироватьРегистр);

	If AddInObject = Undefined Then
		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьПолучениеКоличестваСовпаденийЗавершениеПолученияКомпоненты", ThisObject,
			AdditionalParameters));
	Else
		НачатьУстановкуСвойствКомпоненты(ВсеСовпадения, ИгнорироватьРегистр, AddInObject, NotifyDescription,
			New NotifyDescription("НачатьПолучениеКоличестваЗавершениеУстановкиСвойств", ThisObject, AdditionalParameters));
	EndIf;
EndProcedure

// Описание
// 	Начинает получение ошибки при выполнении метода компоненты
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<ОписаниеОшибки> – Строка - Ошибка зафиксированная компонентой
//	<Параметры> - Массив - Массив параметров вызова метода компоненты.
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями (Необязательный)
Procedure НачатьПолучениеОписанияОшибкиКомпоненты(NotifyDescription, AddInObject) Export
	AddInObject.НачатьПолучениеОписаниеОшибки(NotifyDescription);
EndProcedure

// Описание
// Начинает выполнение проверки на соответствие текста регулярному выражению.
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<Соответствует> – Булево - Признак соответствия строки регулярному выражению
//	<Параметры> - Массив - Массив параметров вызова метода компоненты.
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	СтрокаДляАнализа - Строка - Строка в которой необходимо выполнить поиск по регуляному выражению
// 	РегулярноеВыражение - Строка - Регулярное вырашение для выполнения поиска
// 	ВсеСовпадения - Булево - Если установлено в Истина, то поиск будет выполняться по всем совпадениям, а не только по первому.(Необязательный)
// 	ИгнорироватьРегистр - Булево - Если установлено в Истина, то поиск будет осуществляться без учета регистра (Необязательный)
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями (Необязательный)
Procedure НачатьПолучениеПризнакаСовпадает(NotifyDescription, СтрокаДляАнализа, РегулярноеВыражение,
	ВсеСовпадения = False, ИгнорироватьРегистр = False, AddInObject = Undefined) Export

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);
	AdditionalParameters.Insert("СтрокаДляАнализа", СтрокаДляАнализа);
	AdditionalParameters.Insert("РегулярноеВыражение", РегулярноеВыражение);
	AdditionalParameters.Insert("ВсеСовпадения", ВсеСовпадения);
	AdditionalParameters.Insert("ИгнорироватьРегистр", ИгнорироватьРегистр);

	If AddInObject = Undefined Then
		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьПолучениеПризнакаСовпадаетЗавершениеПолученияКомпоненты", ThisObject,
			AdditionalParameters));
	Else
		НачатьУстановкуСвойствКомпоненты(ВсеСовпадения, ИгнорироватьРегистр, AddInObject, NotifyDescription,
			New NotifyDescription("НачатьПолучениеПризнакаСовпадаетЗавершениеУстановкиСвойств", ThisObject,
			AdditionalParameters));
	EndIf;
EndProcedure

// Описание
// Начинает выполнение замены в переданном тексте часть, соответствующую регулярному выражению
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<РезультатЗамены> – Строка - Строка, получившаяся в результате замены
//	<Параметры> - Массив - Массив параметров вызова метода компоненты.
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	СтрокаДляАнализа - Строка - Строка в которой необходимо выполнить поиск по регуляному выражению
// 	РегулярноеВыражение - Строка - Регулярное вырашение для выполнения поиска
// 	ЗначениеДляЗамены - Строка - Строка, на которую необходимо заменить найденные совпадения
// 	ВсеСовпадения - Булево - Если установлено в Истина, то поиск будет выполняться по всем совпадениям, а не только по первому.(Необязательный)
// 	ИгнорироватьРегистр - Булево - Если установлено в Истина, то поиск будет осуществляться без учета регистра (Необязательный)
// 	AddInObject - ВнешняяКомпонентаОбъект - Объект внешней компоненты работы с регулярными выражениями (Необязательный)
Procedure НачатьЗамену(NotifyDescription, СтрокаДляАнализа, РегулярноеВыражение, ЗначениеДляЗамены,
	ВсеСовпадения = False, ИгнорироватьРегистр = False, AddInObject = Undefined) Export

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);
	AdditionalParameters.Insert("СтрокаДляАнализа", СтрокаДляАнализа);
	AdditionalParameters.Insert("РегулярноеВыражение", РегулярноеВыражение);
	AdditionalParameters.Insert("ЗначениеДляЗамены", ЗначениеДляЗамены);
	AdditionalParameters.Insert("ВсеСовпадения", ВсеСовпадения);
	AdditionalParameters.Insert("ИгнорироватьРегистр", ИгнорироватьРегистр);

	If AddInObject = Undefined Then
		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьЗаменуЗавершениеПолученияКомпоненты", ThisObject, AdditionalParameters));
	Else
		НачатьУстановкуСвойствКомпоненты(ВсеСовпадения, ИгнорироватьРегистр, AddInObject, NotifyDescription,
			New NotifyDescription("НачатьЗаменуЗавершениеУстановкиСвойств", ThisObject, AdditionalParameters));
	EndIf;
EndProcedure
#EndRegion
#EndIf

#EndRegion

#Region Internal

#If Клиент Then

Procedure НачатьИнициализациюКомпоненты(NotifyDescription, ПопытатьсяУстановитьКомпоненту = True) Export

	ДополнительныеПараметрыОповещения=New Structure;
	ДополнительныеПараметрыОповещения.Insert("ОповещениеОЗавершении", NotifyDescription);
	ДополнительныеПараметрыОповещения.Insert("ПопытатьсяУстановитьКомпоненту", ПопытатьсяУстановитьКомпоненту);

	BeginAttachingAddIn(
		New NotifyDescription("НачатьПолучениеКомпонентыЗавершениеПодключенияКомпоненты", ThisObject,
		ДополнительныеПараметрыОповещения), AddinTemplateName(), AddInID(),
		AddInType.Native);

EndProcedure

Procedure НачатьПолучениеКомпонентыЗавершениеПодключенияКомпоненты(Подключено, AdditionalParameters) Export
	If Подключено Then
		ОповещениеОЗавершении=AdditionalParameters.ОповещениеОЗавершении;
		ExecuteNotifyProcessing(ОповещениеОЗавершении, AddInObject());
	ElsIf AdditionalParameters.ПопытатьсяУстановитьКомпоненту Then
		BeginInstallAddIn(
			New NotifyDescription("НачатьПолучениеКомпонентыЗавершениеУстановкиКомпоненты", ThisObject,
			AdditionalParameters), AddinTemplateName());
	Else
		ОповещениеОЗавершении=AdditionalParameters.ОповещениеОЗавершении;
		ExecuteNotifyProcessing(ОповещениеОЗавершении, Undefined);
	EndIf;
EndProcedure

Procedure НачатьПолучениеКомпонентыЗавершениеУстановкиКомпоненты(AdditionalParameters) Export
	НачатьИнициализациюКомпоненты(AdditionalParameters.ОповещениеОЗавершении, False);
EndProcedure

Procedure НачатьПолучениеВерсииКомпонентыЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьПолучениеВерсииКомпоненты(AdditionalParameters.ОписаниеОповещенияОЗавершении, Result);
	EndIf;
EndProcedure

Procedure НачатьУстановкуСвойстваВсеСовпаденияЗавершение(AdditionalParameters) Export
	НачатьУстановкуСвойстваИгнорироватьРегистр(AdditionalParameters.ИгнорироватьРегистр,
		AdditionalParameters.AddInObject,
		New NotifyDescription("НачатьУстановкуСвойствКомпонентыЗавершение", ThisObject, AdditionalParameters));
EndProcedure

Procedure НачатьУстановкуСвойствКомпонентыЗавершение(AdditionalParameters) Export
	ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершенииУстановкиСвойств,
		AdditionalParameters.AddInObject);
EndProcedure

Procedure НачатьНахождениеСовпаденийЗавершениеУстановкиСвойств(AddInObject, AdditionalParameters) Export
	AdditionalParameters.Insert("AddInObject", AddInObject);
	AddInObject.НачатьВызовНайтиСовпадения(
		New NotifyDescription("НачатьНахождениеСовпаденийЗавершениеВызоваНайтиСовпадения", ThisObject,
		AdditionalParameters), AdditionalParameters.СтрокаДляАнализа, AdditionalParameters.РегулярноеВыражение,
		AdditionalParameters.ИерархическийОбходРезультатов);

EndProcedure

Procedure НачатьНахождениеСовпаденийЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьНахождениеСовпадений(AdditionalParameters.ОписаниеОповещенияОЗавершении,
			AdditionalParameters.СтрокаДляАнализа, AdditionalParameters.РегулярноеВыражение,
			AdditionalParameters.ИерархическийОбходРезультатов, AdditionalParameters.ВсеСовпадения,
			AdditionalParameters.ИгнорироватьРегистр, Result);
	EndIf;
EndProcedure

Procedure НачатьНахождениеСовпаденийЗавершениеВызоваНайтиСовпадения(РезультатВызова, Parameters,
	AdditionalParameters) Export

	AdditionalParameters.Insert("Совпадения", New Map);
	НачатьНахождениеСовпаденийВызовСледующейЗаписи(AdditionalParameters);
EndProcedure

Procedure НачатьНахождениеСовпаденийВызовСледующейЗаписи(AdditionalParameters)
	AdditionalParameters.AddInObject.НачатьВызовСледующий(
		New NotifyDescription("НачатьНахождениеСовпаденийЗавершениеВызоваСледующейЗаписи", ThisObject,
		AdditionalParameters));
EndProcedure

Procedure НачатьНахождениеСовпаденийЗавершениеВызоваСледующейЗаписи(Result, Parameters, AdditionalParameters) Export
	If Not Result Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении,
			AdditionalParameters.Совпадения);
		Return;
	EndIf;

	AdditionalParameters.AddInObject.НачатьПолучениеТекущееЗначение(
		New NotifyDescription("НачатьНахождениеСовпаденийЗавершениеПолученияТекущегоЗначения", ThisObject,
		AdditionalParameters));
EndProcedure

Procedure НачатьНахождениеСовпаденийЗавершениеПолученияТекущегоЗначения(Result, AdditionalParameters) Export
	If AdditionalParameters.ИерархическийОбходРезультатов Then
		Подгруппы=New Array;
		AdditionalParameters.Совпадения.Insert(Result, Подгруппы);
		НачатьНахождениеСовпаденийНачалоПолученияПодгрупп(Подгруппы, AdditionalParameters);
	Else
		AdditionalParameters.Совпадения.Insert(Result, Undefined);
		НачатьНахождениеСовпаденийВызовСледующейЗаписи(AdditionalParameters);
	EndIf;
EndProcedure

Procedure НачатьНахождениеСовпаденийНачалоПолученияПодгрупп(Подгруппы, AdditionalParameters)

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("Подгруппы", Подгруппы);
	AdditionalParameters.Insert("AddInObject", AdditionalParameters.AddInObject);
	AdditionalParameters.Insert("ОписаниеОповещенияОЗавершении",
		New NotifyDescription("НачатьНахождениеСовпаденийЗавершениеПолученияПодгрупп", ThisObject,
		AdditionalParameters));

	AdditionalParameters.AddInObject.НачатьВызовКоличествоВложенныхГрупп(
		New NotifyDescription("НачатьНахождениеСовпаденийЗавершениеПолученияКоличестваПодгрупп", ThisObject,
		AdditionalParameters));
EndProcedure

Procedure НачатьНахождениеСовпаденийЗавершениеПолученияКоличестваПодгрупп(Result, Parameters,
	AdditionalParameters) Export

	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("Подгруппы", AdditionalParameters.Подгруппы);
	AdditionalParameters.Insert("КоличествоПодгрупп", Result);
	AdditionalParameters.Insert("ТекущаяПодгруппа", 0);
	AdditionalParameters.Insert("AddInObject", AdditionalParameters.AddInObject);
	AdditionalParameters.Insert("ОписаниеОповещенияОЗавершении", AdditionalParameters.ОписаниеОповещенияОЗавершении);

	НачатьНахождениеСовпаденийНачатьПолучениеПодгруппы(AdditionalParameters);
EndProcedure

Procedure НачатьНахождениеСовпаденийНачатьПолучениеПодгруппы(AdditionalParameters) Export

	AdditionalParameters.AddInObject.НачатьВызовПолучитьПодгруппу(
		New NotifyDescription("НачатьНахождениеСовпаденийЗавершениеПолучениеПодгруппы", ThisObject,
		AdditionalParameters), AdditionalParameters.ТекущаяПодгруппа);

EndProcedure

Procedure НачатьНахождениеСовпаденийЗавершениеПолучениеПодгруппы(Result, Parameters, AdditionalParameters) Export

	AdditionalParameters.ТекущаяПодгруппа=AdditionalParameters.ТекущаяПодгруппа + 1;
	AdditionalParameters.Подгруппы.Add(Result);

	If AdditionalParameters.ТекущаяПодгруппа >= AdditionalParameters.КоличествоПодгрупп Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении,
			AdditionalParameters.Подгруппы);
	Else
		НачатьНахождениеСовпаденийНачатьПолучениеПодгруппы(AdditionalParameters);
	EndIf;
EndProcedure

Procedure НачатьНахождениеСовпаденийЗавершениеПолученияПодгрупп(Result, AdditionalParameters) Export
	НачатьНахождениеСовпаденийВызовСледующейЗаписи(AdditionalParameters);
EndProcedure

Procedure НачатьПолучениеКоличестваСовпаденийЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьПолучениеКоличестваСовпадений(AdditionalParameters.ОписаниеОповещенияОЗавершении,
			AdditionalParameters.СтрокаДляАнализа, AdditionalParameters.РегулярноеВыражение,
			AdditionalParameters.ВсеСовпадения, AdditionalParameters.ИгнорироватьРегистр,
			AdditionalParameters.ИерархическийОбходРезультатов, Result);
	EndIf;
EndProcedure

Procedure НачатьПолучениеКоличестваЗавершениеУстановкиСвойств(AddInObject, AdditionalParameters) Export
	AdditionalParameters.Insert("AddInObject", AddInObject);

	AddInObject.НачатьВызовНайтиСовпадения(
		New NotifyDescription("НачатьПолучениеКоличестваЗавершениеВызоваНайтиСовпадения", ThisObject,
		AdditionalParameters), AdditionalParameters.СтрокаДляАнализа, AdditionalParameters.РегулярноеВыражение,
		AdditionalParameters.ИерархическийОбходРезультатов);
EndProcedure

Procedure НачатьПолучениеКоличестваЗавершениеВызоваНайтиСовпадения(РезультатВызова, Parameters, AdditionalParameters) Export

	AdditionalParameters.AddInObject.НачатьВызовКоличество(
		AdditionalParameters.ОписаниеОповещенияОЗавершении);
EndProcedure

Procedure НачатьПолучениеПризнакаСовпадаетЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьПолучениеПризнакаСовпадает(AdditionalParameters.ОписаниеОповещенияОЗавершении,
			AdditionalParameters.СтрокаДляАнализа, AdditionalParameters.РегулярноеВыражение,
			AdditionalParameters.ВсеСовпадения, AdditionalParameters.ИгнорироватьРегистр, Result);
	EndIf;
EndProcedure

Procedure НачатьПолучениеПризнакаСовпадаетЗавершениеУстановкиСвойств(AddInObject, AdditionalParameters) Export
	AddInObject.НачатьВызовСовпадает(AdditionalParameters.ОписаниеОповещенияОЗавершении,
		AdditionalParameters.СтрокаДляАнализа, AdditionalParameters.РегулярноеВыражение);
EndProcedure

Procedure НачатьЗаменуЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьЗамену(AdditionalParameters.ОписаниеОповещенияОЗавершении, AdditionalParameters.СтрокаДляАнализа,
			AdditionalParameters.РегулярноеВыражение, AdditionalParameters.ЗначениеДляЗамены,
			AdditionalParameters.ВсеСовпадения, AdditionalParameters.ИгнорироватьРегистр, Result);
	EndIf;
EndProcedure

Procedure НачатьЗаменуЗавершениеУстановкиСвойств(AddInObject, AdditionalParameters) Export
	AddInObject.НачатьВызовЗаменить(AdditionalParameters.ОписаниеОповещенияОЗавершении,
		AdditionalParameters.СтрокаДляАнализа, AdditionalParameters.РегулярноеВыражение,
		AdditionalParameters.ЗначениеДляЗамены);
EndProcedure
#EndIf

#EndRegion

#Region Private

Function AddinTemplateName()
#If WebClient Then
	AddinTemplateName="CommonTemplate.UT_RegularExpressionsAddInRegExBrowsers";
#Else
		AddinTemplateName="CommonTemplate.UT_RegularExpressionsAddinRegEx";
#EndIf

	Return AddinTemplateName;
EndFunction

Function ОбъектКомпонентыРегулярныхВыражений(AddInObject = Undefined)
	If AddInObject = Undefined Then
		Return КомпонентаРаботыСРегулярнымиВыражениями();
	Else
		Return AddInObject;
	EndIf;
EndFunction

Function AddInID()
	Return "regex1c";
EndFunction

Function ПроинициализироватьКомпоненту(ПопытатьсяУстановитьКомпоненту = True)

	AddinTemplateName=AddinTemplateName();
	КодВозврата = AttachAddIn(AddinTemplateName, AddInID(),
		AddInType.Native);

#If Клиент Then
	If Not КодВозврата Then

		If Not ПопытатьсяУстановитьКомпоненту Then
			Return False;
		EndIf;

		InstallAddIn(AddinTemplateName);

		Return ПроинициализироватьКомпоненту(False); // Рекурсивно.

	EndIf;
#EndIf

	Return AddInObject();
EndFunction

#If Клиент Then

Procedure НачатьУстановкуСвойстваВсеСовпадения(Value, AddInObject, NotifyDescription)
	AddInObject.НачатьУстановкуВсеСовпадения(NotifyDescription, Value);
EndProcedure

Procedure НачатьУстановкуСвойстваИгнорироватьРегистр(Value, AddInObject, NotifyDescription)
	AddInObject.НачатьУстановкуИгнорироватьРегистр(NotifyDescription, Value);
EndProcedure

Procedure НачатьУстановкуСвойствКомпоненты(ВсеСовпадения, ИгнорироватьРегистр, AddInObject,
	ОписаниеОповещенияОЗавершении, ОписаниеОповещенияОЗавершенииУстановкиСвойств)
	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("AddInObject", AddInObject);
	AdditionalParameters.Insert("ОписаниеОповещенияОЗавершении", ОписаниеОповещенияОЗавершении);
	AdditionalParameters.Insert("ОписаниеОповещенияОЗавершенииУстановкиСвойств",
		ОписаниеОповещенияОЗавершенииУстановкиСвойств);
	AdditionalParameters.Insert("ИгнорироватьРегистр", ИгнорироватьРегистр);

	НачатьУстановкуСвойстваВсеСовпадения(ВсеСовпадения, AddInObject,
		New NotifyDescription("НачатьУстановкуСвойстваВсеСовпаденияЗавершение", ThisObject, AdditionalParameters));
EndProcedure

#EndIf

#EndRegion