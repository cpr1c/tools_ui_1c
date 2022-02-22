// Работа с буфером обмена из 1С
//
// Copyright 2020 ООО "Центр прикладных разработок"
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
//
// URL:    https://github.com/cpr1c/clipboard_1c
// Требования: платформа 1С версии 8.3.14 и выше
// С более ранними платформами могут быть проблемы с подключением компоненты, а также с работой некоторых методов
// clipboard
#Region Public

// Returns the current subsystem version
//
// Return value:
// 	String - Version of subsytem work with clipboard
Function SubsystemVersion() Export
	Return "1.0.2";
EndFunction

//Returns the clipboard components object. AddIn must be pre-connected.
// If the component is not connected, an exception will be thrown 
// 
// The return value:
// 	AddInObject -Object of  AddIn  to work with clipboard. 
Function AddInObject() Export
	Return New ("AddIn." + ИдентификаторКомпоненты() + ".ClipboardControl");
EndFunction

#Region СинхронныеМетоды

// Используются синхронные вызовы
// Возвращает Object of  AddIn  to work with clipboard. При необходимости происходит подключение и установка компоненты
// 
// Возвращаемое значение:
// 	Add-in object - Object of  AddIn  to work with clipboard 
//  Неопределено - если не удалось подключить компоненту
Function КомпонентаРаботыСБуферомОбмена() Export
	Try
		Компонента= ПроинициализироватьКомпоненту(True);

		Return Компонента;
	Except
		ТекстОшибки = NStr(
			"ru = 'Not удалось подключить внешнюю компоненту для работы с буфером обмена. Подробности в журнале регистрации.'");
		Message(ТекстОшибки + ErrorDescription());
		Return Undefined;
	EndTry;
EndFunction

// Возвращает версию компоненты работы с буфером обмена
// 
// Параметры:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
// Возвращаемое значение:
// 	Строка - Версия используемой компоненты 
Function ВерсияКомпоненты(AddInObject = Undefined) Export
	ОчищатьКомпоненту=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРаботыСБуферомОбмена(AddInObject);

	Version=AddInObject.Version;

	If ОчищатьКомпоненту Then
		AddInObject=Undefined;
	EndIf;

	Return Version;
EndFunction

// Очищает содержимое буфера обмена
// 
// Параметры:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure ОчиститьБуферОбмена(AddInObject = Undefined) Export
	ОчищатьКомпоненту=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРаботыСБуферомОбмена(AddInObject);
	AddInObject.Clear();

	If ОчищатьКомпоненту Then
		AddInObject=Undefined;
	EndIf;

EndProcedure

// Помещает переданную картинку в буфер обмена
// 
// Параметры:
// 	Картинка- Картинка, ДвоичныеДанные , АдресВоВременномХранилище
// 	Если передается как адресВоВременномХранилище тип во временном хоранилище должен быть или картинка или двоичные данные
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure КопироватьКартинкуВБуфер(Picture, AddInObject = Undefined) Export
	ОчищатьКомпоненту=AddInObject = Undefined;

	ТекКартинка=КартинкаДляКопированияВБуфер(Picture);
	If ТекКартинка = Undefined Then
		Return;
	EndIf;

	AddInObject=ОбъектКомпонентыРаботыСБуферомОбмена(AddInObject);
	AddInObject.ЗаписатьКартинку(ТекКартинка);

	If ОчищатьКомпоненту Then
		AddInObject=Undefined;
	EndIf;

EndProcedure

// получает картинку из буфера обмена в формате PNG
// 
// Параметры:
// 	ВариантПолучения - Строка
// 	Один из варинатов:
// 		ДвоичныеДанные- получение двоичных данных картинки
// 		Картинка- Преобразованное к типу "Картинка" содержание буфера
// 		Адрес- Адрес двоичных данных картинки во временном хранилище
// 	AddInObject - Add-in object -  Object of  AddIn  to work with clipboard (optional)
// Возвращаемое значение:
// 	ДвоичныеДанные,Картинка,Строка - картинка в запрощенном формате
//	Неопределено- если в буфере нет картинки
Function КартинкаИзБуфера(ВариантПолучения = "Picture", AddInObject = Undefined) Export
	ОчищатьКомпоненту=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРаботыСБуферомОбмена(AddInObject);
	ДанныеКартинкиВБуфере=AddInObject.Picture;

	If ОчищатьКомпоненту Then
		AddInObject=Undefined;
	EndIf;

	Return КартинкаВНужномФорматеИзБуфера(ДанныеКартинкиВБуфере, ВариантПолучения);
EndFunction

// Помещает переданную строку в буфер обмена
// 
// Параметры:
// 	СтрокаКопирования- Строка- Строка, которую необходимо поместить в буфер обмена
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure КопироватьСтрокуВБуфер(СтрокаКопирования, AddInObject = Undefined) Export
	ОчищатьКомпоненту=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРаботыСБуферомОбмена(AddInObject);
	AddInObject.WriteText(СтрокаКопирования);

	If ОчищатьКомпоненту Then
		AddInObject=Undefined;
	EndIf;

EndProcedure

// получает текущую строку из буфера обмена 
// 
// Параметры:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
// Возвращаемое значение:
// 	Строка - Текст, содержащийся в буфере обмена
Function ТекстИзБуфера(AddInObject = Undefined) Export
	ОчищатьКомпоненту=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРаботыСБуферомОбмена(AddInObject);

	ТекстБуфера=AddInObject.Text;

	If ОчищатьКомпоненту Then
		AddInObject=Undefined;
	EndIf;

	Return ТекстБуфера;

EndFunction

// получает формат текущего значения из буфера обмена 
// 
// Параметры:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
// Возвращаемое значение:
// 	Строка - Строка в формате JSON, содержащая описание формата содержимого буфера обмена
Function ФорматБуфераОбмена(AddInObject = Undefined) Export
	ОчищатьКомпоненту=AddInObject = Undefined;

	AddInObject=ОбъектКомпонентыРаботыСБуферомОбмена(AddInObject);

	ФорматБуфера=AddInObject.Format;

	If ОчищатьКомпоненту Then
		AddInObject=Undefined;
	EndIf;

	Return ФорматБуфера;
EndFunction

#EndRegion

#Region АсинхронныеМетоды

// Начинает получение объекта внешней компоненты работы с буфером обмена. При необходимости будет произведено подключение и установка компоненты
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//<AddInObject> – Object of  AddIn  to work with clipboard, Тип: Add-in object. Неопределено- если не удалось подключить компоненту
//<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
Procedure НачатьПолучениеКомпоненты(NotifyDescription) Export
	НачатьИнициализациюКомпоненты(NotifyDescription, True);
EndProcedure

// Начинает получение версии используемой компоненты работы с буфером обмена
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<ВерсияКомпоненты> – Версия используемой компоненты, Тип: Строка. Неопределено- если не удалось подключить компоненту
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure НачатьПолучениеВерсииКомпоненты(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		ДопПараметры=New Structure;
		ДопПараметры.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);

		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьПолучениеВерсииКомпонентыЗавершениеПолученияКомпоненты", ThisObject,
			ДопПараметры));
	Else
		AddInObject.НачатьПолучениеВерсия(NotifyDescription);
	EndIf;
EndProcedure

// Начинает очистку содержимого буфера обмена
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<РезультатОчистки> – Результат очистки, Тип: Булево. Неопределено- если не удалось подключить компоненту
//	<ПараметрыВызова> - Пустой массив
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure НачатьОчисткуБуфераОбмена(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		ДопПараметры=New Structure;
		ДопПараметры.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);

		НачатьПолучениеКомпоненты(New NotifyDescription("НачатьОчисткуБуфераОбменаЗавершениеПолученияКомпоненты",
			ThisObject, ДопПараметры));
	Else
		AddInObject.НачатьВызовОчистить(NotifyDescription);
	EndIf;
EndProcedure

// Начинает помещение картинку в буфер обмена
// 
// Параметры:
// 	Картинка
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<Результат> – Результат установки картинки в буфере обмена, Тип: Булево. Неопределено- если не удалось подключить компоненту
//	<ПараметрыВызова> - Массив параметров вызова метода компоненты
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure НачатьКопированиеКартинкиВБуфер(Picture, NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		ДопПараметры=New Structure;
		ДопПараметры.Insert("Picture", Picture);
		ДопПараметры.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);

		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьКопированиеКартинкиВБуферЗавершениеПолученияКомпоненты", ThisObject,
			ДопПараметры));
	Else
		ТекКартинка=КартинкаДляКопированияВБуфер(Picture);
		If ТекКартинка = Undefined Then
			Return;
		EndIf;
		AddInObject.НачатьВызовЗаписатьКартинку(NotifyDescription, ТекКартинка);
	EndIf;
EndProcedure

// Начинает получение картинки из буфера обмена
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<ДанныеКартинки> – Данные картинки в запрошенном формате, Тип: Строка, ДвоичныеДанные, Картинка. Неопределено- если не удалось подключить компоненту или в буфере нет картинки
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	ВариантПолучения - Строка
// 	Один из варинатов:
// 		ДвоичныеДанные- получение двоичных данных картинки
// 		Картинка- Преобразованное к типу "Картинка" содержание буфера
// 		Адрес- Адрес двоичных данных картинки во временном хранилище
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure НачатьПолучениеКартинкиИзБуфера(NotifyDescription, ВариантПолучения = "Picture",
	AddInObject = Undefined) Export
	ДопПараметры=New Structure;
	ДопПараметры.Insert("ВариантПолучения", ВариантПолучения);
	ДопПараметры.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);

	If AddInObject = Undefined Then

		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьПолучениеКартинкиИзБуфераЗавершениеПолученияКомпоненты", ThisObject,
			ДопПараметры));
	Else
		AddInObject.НачатьПолучениеКартинка(New NotifyDescription("НачатьПолучениеКартинкиИзБуфераЗавершение",
			ThisObject, ДопПараметры));
	EndIf;
EndProcedure

// Начинает помещение текста в буфер обмена
// 
// Параметры:
// 	СтрокаКопирования- Строка- Строка, которую необходимо поместить в буфер обмена
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<Результат> – Результат установки текста в буфере обмена, Тип: Булево. Неопределено- если не удалось подключить компоненту
//	<ПараметрыВызова> - Массив параметров вызова метода компоненты
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure НачатьКопированиеСтрокиВБуфер(СтрокаКопирования, NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		ДопПараметры=New Structure;
		ДопПараметры.Insert("СтрокаКопирования", СтрокаКопирования);
		ДопПараметры.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);

		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьКопированиеСтрокиВБуферЗавершениеПолученияКомпоненты", ThisObject,
			ДопПараметры));
	Else
		AddInObject.НачатьВызовЗаписатьТекст(NotifyDescription, СтрокаКопирования);
	EndIf;
EndProcedure


// Начинает получение текста из буфера обмена
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<Результат> – Текст из буфера обмена, Тип: Строка. Неопределено- если не удалось подключить компоненту
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure НачатьПолучениеСтрокиИзБуфера(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		ДопПараметры=New Structure;
		ДопПараметры.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);

		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьПолучениеСтрокиИзБуфераЗавершениеПолученияКомпоненты", ThisObject,
			ДопПараметры));
	Else
		AddInObject.НачатьПолучениеТекст(NotifyDescription);
	EndIf;
EndProcedure


// Начинает получение формата текущего значения в буфере обмена
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<Результат> – Строка в формате JSON, содержащая описание формата содержимого буфера обмена, Тип: Строка. Неопределено- если не удалось подключить компоненту
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure НачатьПолучениеФорматаБуфераОбмена(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		ДопПараметры=New Structure;
		ДопПараметры.Insert("ОписаниеОповещенияОЗавершении", NotifyDescription);

		НачатьПолучениеКомпоненты(
			New NotifyDescription("НачатьПолучениеФорматаБуфераОбменаЗавершениеПолученияКомпоненты", ThisObject,
			ДопПараметры));
	Else
		AddInObject.НачатьПолучениеФормат(NotifyDescription);
	EndIf;
EndProcedure

#EndRegion

#EndRegion

#Region Internal

Procedure НачатьИнициализациюКомпоненты(NotifyDescription, ПопытатьсяУстановитьКомпоненту = True) Export

	ДополнительныеПараметрыОповещения=New Structure;
	ДополнительныеПараметрыОповещения.Insert("ОповещениеОЗавершении", NotifyDescription);
	ДополнительныеПараметрыОповещения.Insert("ПопытатьсяУстановитьКомпоненту", ПопытатьсяУстановитьКомпоненту);

	BeginAttachingAddIn(
		New NotifyDescription("НачатьПолучениеКомпонентыЗавершениеПодключенияКомпоненты", ThisObject,
		ДополнительныеПараметрыОповещения), ИмяМакетаКомпоненты(), ИдентификаторКомпоненты(),
		AddInType.Native);

EndProcedure

Procedure НачатьПолучениеКомпонентыЗавершениеПодключенияКомпоненты(Подключено, AdditionalParameters) Export
	If Подключено Then
		ОповещениеОЗавершении=AdditionalParameters.ОповещениеОЗавершении;
		ExecuteNotifyProcessing(ОповещениеОЗавершении, AddInObject());
	ElsIf AdditionalParameters.ПопытатьсяУстановитьКомпоненту Then
		BeginInstallAddIn(
			New NotifyDescription("НачатьПолучениеКомпонентыЗавершениеУстановкиКомпоненты", ThisObject,
			AdditionalParameters), ИмяМакетаКомпоненты());
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

Procedure НачатьОчисткуБуфераОбменаЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьОчисткуБуфераОбмена(AdditionalParameters.ОписаниеОповещенияОЗавершении, Result);
	EndIf;
EndProcedure

Procedure НачатьКопированиеКартинкиВБуферЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьКопированиеКартинкиВБуфер(AdditionalParameters.Picture,
			AdditionalParameters.ОписаниеОповещенияОЗавершении, Result);
	EndIf;
EndProcedure

Procedure НачатьПолучениеКартинкиИзБуфераЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьПолучениеКартинкиИзБуфера(AdditionalParameters.ОписаниеОповещенияОЗавершении,
			AdditionalParameters.ВариантПолучения, Result);
	EndIf;
EndProcedure

Procedure НачатьПолучениеКартинкиИзБуфераЗавершение(Result, AdditionalParameters) Export
	ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, КартинкаВНужномФорматеИзБуфера(
		Result, AdditionalParameters.ВариантПолучения));
EndProcedure

Procedure НачатьКопированиеСтрокиВБуферЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьКопированиеСтрокиВБуфер(AdditionalParameters.СтрокаКопирования,
			AdditionalParameters.ОписаниеОповещенияОЗавершении, Result);
	EndIf;
EndProcedure

Procedure НачатьПолучениеСтрокиИзБуфераЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьПолучениеСтрокиИзБуфера(AdditionalParameters.ОписаниеОповещенияОЗавершении, Result);
	EndIf;
EndProcedure

Procedure НачатьПолучениеФорматаБуфераОбменаЗавершениеПолученияКомпоненты(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.ОписаниеОповещенияОЗавершении, Undefined);
	Else
		НачатьПолучениеФорматаБуфераОбмена(AdditionalParameters.ОписаниеОповещенияОЗавершении, Result);
	EndIf;
EndProcedure

#EndRegion

#Region Private

Function ИмяМакетаКомпоненты()
	Return "ОбщийМакет.УИ_КомпонентаДляРаботыСБуферомОбмена";
EndFunction

Function КартинкаДляКопированияВБуфер(Picture)
	If TypeOf(Picture) = Type("String") And IsTempStorageURL(Picture) Then

		ТекКартинка=GetFromTempStorage(Picture);
	Else
		ТекКартинка=Picture;
	EndIf;

	If TypeOf(ТекКартинка) = Type("Picture") Then
		BinaryData = ТекКартинка.GetBinaryData();
	ElsIf TypeOf(ТекКартинка) = Type("BinaryData") Then
		BinaryData=ТекКартинка;
	Else
		Message("Неверный тип картинки");
		BinaryData=Undefined;
	EndIf;

	Return BinaryData;
EndFunction

Function КартинкаВНужномФорматеИзБуфера(ДанныеБуфера, ВариантПолучения)
	If TypeOf(ДанныеБуфера) <> Type("BinaryData") Then
		Return Undefined;
	EndIf;

	If Lower(ВариантПолучения) = "двоичныеданные" Then
		Return ДанныеБуфера;
	ElsIf Lower(ВариантПолучения) = "адрес" Then
		Return PutToTempStorage(ДанныеБуфера);
	Else
		Return New Picture(ДанныеБуфера);
	EndIf;
EndFunction

Function ИдентификаторКомпоненты()
	Return "clipboard1c";
EndFunction

Function ОбъектКомпонентыРаботыСБуферомОбмена(AddInObject = Undefined)
	If AddInObject = Undefined Then
		Return КомпонентаРаботыСБуферомОбмена();
	Else
		Return AddInObject;
	EndIf;
EndFunction

Function ПроинициализироватьКомпоненту(ПопытатьсяУстановитьКомпоненту = True)

	ИмяМакетаКомпоненты=ИмяМакетаКомпоненты();
	КодВозврата = AttachAddIn(ИмяМакетаКомпоненты, ИдентификаторКомпоненты(),
		AddInType.Native);

	If Not КодВозврата Then

		If Not ПопытатьсяУстановитьКомпоненту Then
			Return False;
		EndIf;

		InstallAddIn(ИмяМакетаКомпоненты);

		Return ПроинициализироватьКомпоненту(False); // Рекурсивно.

	EndIf;

	Return AddInObject();
EndFunction
#EndRegion