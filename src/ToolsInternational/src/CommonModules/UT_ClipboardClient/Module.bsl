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
	Return New ("AddIn." + AddInID() + ".ClipboardControl");
EndFunction

#Region СинхронныеМетоды

// Используются синхронные вызовы
// Возвращает Object of  AddIn  to work with clipboard. При необходимости происходит подключение и установка компоненты
// 
// Возвращаемое значение:
// 	Add-in object - Object of  AddIn  to work with clipboard 
//  Неопределено - если не удалось подключить компоненту
Function ClipboardAddin() Export
	Try
		Addin= InitializeAddin(True);

		Return Addin;
	Except
		ErrorText = NStr(
			"ru = 'Не удалось подключить внешнюю компоненту для работы с буфером обмена. Подробности в журнале регистрации.';en = 'Failed to connect an Addin to work with the clipboard. Details in the event log.'");
		Message(ErrorText + ErrorDescription());
		Return Undefined;
	EndTry;
EndFunction

// Возвращает версию компоненты работы с буфером обмена
// 
// Параметры:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
// Возвращаемое значение:
// 	Строка - Версия используемой компоненты 
Function AddinVersion(AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);

	Version=AddInObject.Version;

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

	Return Version;
EndFunction

// Очищает содержимое буфера обмена
// 
// Параметры:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure EmptyClipboard(AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);
	AddInObject.Empty();

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

EndProcedure

// Помещает переданную картинку в буфер обмена
// 
// Параметры:
// 	Картинка- Картинка, ДвоичныеДанные , АдресВоВременномХранилище
// 	Если передается как адресВоВременномХранилище тип во временном хоранилище должен быть или картинка или двоичные данные
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure CopyImageToClipboard(Picture, AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	CurrentImage=ImageForCopyToClipboard(Picture);
	If CurrentImage = Undefined Then
		Return;
	EndIf;

	AddInObject=ClipboardAddinObject(AddInObject);
	AddInObject.SetImage(CurrentImage);

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

EndProcedure

// получает картинку из буфера обмена в формате PNG
// 
// Параметры:
// 	ReturnDataType - Строка
// 	Один из варинатов:
// 		ДвоичныеДанные- получение двоичных данных картинки
// 		Картинка- Преобразованное к типу "Картинка" содержание буфера
// 		Адрес- Адрес двоичных данных картинки во временном хранилище
// 	AddInObject - Add-in object -  Object of  AddIn  to work with clipboard (optional)
// Возвращаемое значение:
// 	ДвоичныеДанные,Картинка,Строка - картинка в запрощенном формате
//	Неопределено- если в буфере нет картинки
Function ImageFromClipboard(ReturnDataType = "Picture", AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);
	ImageDataInClipboard=AddInObject.Image;

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;
    	Return ImageInCorrectFormatFromClipboard(ImageDataInClipboard, ReturnDataType);
EndFunction

// Помещает переданную строку в буфер обмена
// 
// Параметры:
// 	CopiedText- Строка- Строка, которую необходимо поместить в буфер обмена
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure CopyTextToClipboard(CopiedText, AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);
	AddInObject.SetText(CopiedText);

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

EndProcedure

// получает текущую строку из буфера обмена 
// 
// Параметры:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
// Возвращаемое значение:
// 	Строка - Текст, содержащийся в буфере обмена
Function TextFromClipboard(AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);

	ClipboardText=AddInObject.Text;

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

	Return ClipboardText;

EndFunction

// получает формат текущего значения из буфера обмена 
// 
// Параметры:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
// Возвращаемое значение:
// 	Строка - Строка в формате JSON, содержащая описание формата содержимого буфера обмена
Function ClipboardFormat(AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);

	Format=AddInObject.Format;

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

	Return Format;
EndFunction

#EndRegion

#Region АсинхронныеМетоды

// Начинает получение объекта внешней компоненты работы с буфером обмена. При необходимости будет произведено подключение и установка компоненты
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//<AddInObject> – Object of  AddIn  to work with clipboard, Тип: Add-in object. Неопределено- если не удалось подключить компоненту
//<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
Procedure BeginGettingAddIn(NotifyDescription) Export
	НачатьИнициализациюКомпоненты(NotifyDescription, True);
EndProcedure

// Начинает получение версии используемой компоненты работы с буфером обмена
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<AddinVersion> – Версия используемой компоненты, Тип: Строка. Неопределено- если не удалось подключить компоненту
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure BeginGettingAddinVersion(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		AdditionalParameters=New Structure;
		AdditionalParameters.Insert("NotifyDescriptionOnCompletion", NotifyDescription);

		BeginGettingAddIn(
			New NotifyDescription("BeginGettingAddinVersionEndGettingAddin", ThisObject,
			AdditionalParameters));
	Else
		AddInObject.BeginGettingVersion(NotifyDescription);
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
Procedure BeginClipBoardEmptying(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		AdditionalParameters=New Structure;
		AdditionalParameters.Insert("NotifyDescriptionOnCompletion", NotifyDescription);

		BeginGettingAddIn(New NotifyDescription("BeginClipBoardEmptyingEndGettingAddin",
			ThisObject, AdditionalParameters));
	Else
		AddInObject.BeginCallingEmpty(NotifyDescription);
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
Procedure BeginCopyingImageToClipboard(Picture, NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		AdditionalParameters=New Structure;
		AdditionalParameters.Insert("Picture", Picture);
		AdditionalParameters.Insert("NotifyDescriptionOnCompletion", NotifyDescription);

		BeginGettingAddIn(
			New NotifyDescription("BeginCopyingImageToClipboardEndGettingAddin", ThisObject,
			AdditionalParameters));
	Else
		CurrentImage=ImageForCopyToClipboard(Picture);
		If CurrentImage = Undefined Then
			Return;
		EndIf;
		AddInObject.BeginCallingSetImage(NotifyDescription, CurrentImage);
	EndIf;
EndProcedure

// Начинает получение картинки из буфера обмена
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<ДанныеКартинки> – Данные картинки в запрошенном формате, Тип: Строка, ДвоичныеДанные, Картинка. Неопределено- если не удалось подключить компоненту или в буфере нет картинки
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	ReturnDataType - Строка
// 	Один из варинатов:
// 		ДвоичныеДанные- получение двоичных данных картинки
// 		Картинка- Преобразованное к типу "Картинка" содержание буфера
// 		Адрес- Адрес двоичных данных картинки во временном хранилище
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure BeginGettingImageFromClipboard(NotifyDescription, ReturnDataType = "Picture",
	AddInObject = Undefined) Export
	AdditionalParameters=New Structure;
	AdditionalParameters.Insert("ReturnDataType", ReturnDataType);
	AdditionalParameters.Insert("NotifyDescriptionOnCompletion", NotifyDescription);

	If AddInObject = Undefined Then

		BeginGettingAddIn(
			New NotifyDescription("BeginGettingImageFromClipboardEndGettingAddin", ThisObject,
			AdditionalParameters));
	Else
		AddInObject.BeginGettingImage(New NotifyDescription("PictureInCorrectFormatFromClipboardOnEnd",
			ThisObject, AdditionalParameters));
	EndIf;
EndProcedure

// Начинает помещение текста в буфер обмена
// 
// Параметры:
// 	CopiedText- Строка- Строка, которую необходимо поместить в буфер обмена
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<Результат> – Результат установки текста в буфере обмена, Тип: Булево. Неопределено- если не удалось подключить компоненту
//	<ПараметрыВызова> - Массив параметров вызова метода компоненты
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure НачатьКопированиеСтрокиВБуфер(CopiedText, NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		AdditionalParameters=New Structure;
		AdditionalParameters.Insert("CopiedText", CopiedText);
		AdditionalParameters.Insert("NotifyDescriptionOnCompletion", NotifyDescription);

		BeginGettingAddIn(
			New NotifyDescription("НачатьКопированиеСтрокиВБуферEndGettingAddin", ThisObject,
			AdditionalParameters));
	Else
		AddInObject.BeginCallingSetText(NotifyDescription, CopiedText);
	EndIf;
EndProcedure


// Начинает получение текста из буфера обмена
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<Результат> – Текст из буфера обмена, Тип: Строка. Неопределено- если не удалось подключить компоненту
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure BeginGettingTextFormClipboard(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		AdditionalParameters=New Structure;
		AdditionalParameters.Insert("NotifyDescriptionOnCompletion", NotifyDescription);

		BeginGettingAddIn(
			New NotifyDescription("BeginGettingСтрокиИзБуфераEndGettingAddin", ThisObject,
			AdditionalParameters));
	Else
		AddInObject.BeginGettingText(NotifyDescription);
	EndIf;
EndProcedure


// Начинает получение формата текущего значения в буфере обмена
// 
// Параметры:
// 	ОписаниеОповещения - ОписаниеОповещения - Содержит описание процедуры, которая будет вызвана после завершения со следующими параметрами:
//	<Результат> – Строка в формате JSON, содержащая описание формата содержимого буфера обмена, Тип: Строка. Неопределено- если не удалось подключить компоненту
//	<ДополнительныеПараметры> - значение, которое было указано при создании объекта ОписаниеОповещения.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure BeginGettingClipboardFormat(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		AdditionalParameters=New Structure;
		AdditionalParameters.Insert("NotifyDescriptionOnCompletion", NotifyDescription);

		BeginGettingAddIn(
			New NotifyDescription("BeginGettingФорматаБуфераОбменаEndGettingAddin", ThisObject,
			AdditionalParameters));
	Else
		AddInObject.BeginGettingFormat(NotifyDescription);
	EndIf;
EndProcedure

#EndRegion

#EndRegion

#Region Internal

Procedure НачатьИнициализациюКомпоненты(NotifyDescription, TryToSetAddin = True) Export

	ДополнительныеПараметрыОповещения=New Structure;
	ДополнительныеПараметрыОповещения.Insert("ОповещениеОЗавершении", NotifyDescription);
	ДополнительныеПараметрыОповещения.Insert("TryToSetAddin", TryToSetAddin);

	BeginAttachingAddIn(
		New NotifyDescription("BeginGettingAddInЗавершениеПодключенияКомпоненты", ThisObject,
		ДополнительныеПараметрыОповещения), AddinTemplateName(), AddInID(),
		AddInType.Native);

EndProcedure

Procedure BeginGettingAddInЗавершениеПодключенияКомпоненты(Подключено, AdditionalParameters) Export
	If Подключено Then
		ОповещениеОЗавершении=AdditionalParameters.ОповещениеОЗавершении;
		ExecuteNotifyProcessing(ОповещениеОЗавершении, AddInObject());
	ElsIf AdditionalParameters.TryToSetAddin Then
		BeginInstallAddIn(
			New NotifyDescription("BeginGettingAddInЗавершениеУстановкиКомпоненты", ThisObject,
			AdditionalParameters), AddinTemplateName());
	Else
		ОповещениеОЗавершении=AdditionalParameters.ОповещениеОЗавершении;
		ExecuteNotifyProcessing(ОповещениеОЗавершении, Undefined);
	EndIf;
EndProcedure

Procedure BeginGettingAddInЗавершениеУстановкиКомпоненты(AdditionalParameters) Export
	НачатьИнициализациюКомпоненты(AdditionalParameters.ОповещениеОЗавершении, False);
EndProcedure

Procedure BeginGettingAddinVersionEndGettingAddin(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, Undefined);
	Else
		BeginGettingAddinVersion(AdditionalParameters.NotifyDescriptionOnCompletion, Result);
	EndIf;
EndProcedure

Procedure BeginClipBoardEmptyingEndGettingAddin(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, Undefined);
	Else
		BeginClipBoardEmptying(AdditionalParameters.NotifyDescriptionOnCompletion, Result);
	EndIf;
EndProcedure

Procedure BeginCopyingImageToClipboardEndGettingAddin(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, Undefined);
	Else
		BeginCopyingImageToClipboard(AdditionalParameters.Picture,
			AdditionalParameters.NotifyDescriptionOnCompletion, Result);
	EndIf;
EndProcedure

Procedure BeginGettingImageFromClipboardEndGettingAddin(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, Undefined);
	Else
		BeginGettingImageFromClipboard(AdditionalParameters.NotifyDescriptionOnCompletion,
			AdditionalParameters.ReturnDataType, Result);
	EndIf;
EndProcedure

Procedure PictureInCorrectFormatFromClipboardOnEnd(Result, AdditionalParameters) Export
	ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, ImageInCorrectFormatFromClipboard(
		Result, AdditionalParameters.ReturnDataType));
EndProcedure

Procedure НачатьКопированиеСтрокиВБуферEndGettingAddin(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, Undefined);
	Else
		НачатьКопированиеСтрокиВБуфер(AdditionalParameters.CopiedText,
			AdditionalParameters.NotifyDescriptionOnCompletion, Result);
	EndIf;
EndProcedure

Procedure BeginGettingСтрокиИзБуфераEndGettingAddin(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, Undefined);
	Else
		BeginGettingTextFormClipboard(AdditionalParameters.NotifyDescriptionOnCompletion, Result);
	EndIf;
EndProcedure

Procedure BeginGettingФорматаБуфераОбменаEndGettingAddin(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, Undefined);
	Else
		BeginGettingClipboardFormat(AdditionalParameters.NotifyDescriptionOnCompletion, Result);
	EndIf;
EndProcedure

#EndRegion

#Region Private

Function AddinTemplateName()
	Return "CommonTemplates.UT_ClipboardComponent";
EndFunction

Function ImageForCopyToClipboard(Picture)
	If TypeOf(Picture) = Type("String") And IsTempStorageURL(Picture) Then

		CurrentImage=GetFromTempStorage(Picture);
	Else
		CurrentImage=Picture;
	EndIf;

	If TypeOf(CurrentImage) = Type("Picture") Then
		BinaryData = CurrentImage.GetBinaryData();
	ElsIf TypeOf(CurrentImage) = Type("BinaryData") Then
		BinaryData=CurrentImage;
	Else
		Message(NSTR("ru = 'Неверный тип картинки';en = 'Incorrect image type'"));
		BinaryData=Undefined;
	EndIf;

	Return BinaryData;
EndFunction

Function ImageInCorrectFormatFromClipboard(ClipboardData, ReturnDataType)
	If TypeOf(ClipboardData) <> Type("BinaryData") Then
		Return Undefined;
	EndIf;

	If Lower(ReturnDataType) = "binanydata" Then
		Return ClipboardData;
	ElsIf Lower(ReturnDataType) = "address" Then
		Return PutToTempStorage(ClipboardData);
	Else
		Return New Picture(ClipboardData);
	EndIf;
EndFunction

Function AddInID()
	Return "clipboard1c";
EndFunction

Function ClipboardAddinObject(AddInObject = Undefined)
	If AddInObject = Undefined Then
		Return ClipboardAddin();
	Else
		Return AddInObject;
	EndIf;
EndFunction

Function InitializeAddin(TryToSetAddin = True)

	AddinTemplateName=AddinTemplateName();
	ReturnCode = AttachAddIn(AddinTemplateName, AddInID(),
		AddInType.Native);

	If Not ReturnCode Then

		If Not TryToSetAddin Then
			Return False;
		EndIf;

		InstallAddIn(AddinTemplateName);

		Return InitializeAddin(False); // Recursively.

	EndIf;

	Return AddInObject();
EndFunction
#EndRegion