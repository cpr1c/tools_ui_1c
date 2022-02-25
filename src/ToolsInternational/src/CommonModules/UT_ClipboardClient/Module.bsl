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

// Work with clipboard from 1C Enterprise 
// Translated to english variant of script by Neti company (https://erpdev.i-neti.com/)
//  Requirements: 1C platform version 8.3.14 and higher
// With earlier platforms, there may be problems with connecting components, as well as with the operation of some methods


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

#Region SyncMetods

// Synchronous calls are used
// Returns Object of  AddIn  to work with clipboard. If necessary, the addin will be  attached and installed
// 
// Return value:
// 	Add-in object - Object of  AddIn  to work with clipboard 
//  Undefined - if the component failed to attach
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

// Returns version of clipboard addin 
// 
// Parameters:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
// Returned value:
// 	String - Addin version 
Function AddinVersion(AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);

	Version=AddInObject.Version;

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

	Return Version;
EndFunction

// Empty clipboard 
// 
// Parameters:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure EmptyClipboard(AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);
	AddInObject.Empty();

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

EndProcedure

// Put the transferred image to the clipboard
// 
// Parameters:
// 	Picture- Picture, BinaryData , Address in Temp Storage
// 	If transmitted type of Address in Temp Storage  in temp storage must be picture or binary data
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

// Get image form clipboard in PNG format
// 
// Parameters:
// 	ReturnDataType - String
// 	One of the options::
// 		BinaryData- getting binary image data
// 		Picture- Converted to type "Picture" clipboard data
// 		Adress-The address of the binary data of the image in the temporary storage
// 	AddInObject - Add-in object -  Object of  AddIn  to work with clipboard (optional)
// Returned value:
// 	BinaryData,Picture,String - picture in requested format
//	Undefined- if there is no picture in the buffer
Function ImageFromClipboard(ReturnDataType = "Picture", AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);
	ImageDataInClipboard=AddInObject.Image;

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;
    	Return ImageInCorrectFormatFromClipboard(ImageDataInClipboard, ReturnDataType);
EndFunction

// Places the passed string in the clipboard
// 
// Parameters:
// 	CopiedText- String- Text  to be placed in the clipboard
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure CopyTextToClipboard(CopiedText, AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);
	AddInObject.SetText(CopiedText);

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

EndProcedure

//retrieves the current text from the clipboard
// 
// Parameters:
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
// Returned value:
// 	String - Text contained in the clipboard
Function TextFromClipboard(AddInObject = Undefined) Export
	EmptyAddin=AddInObject = Undefined;

	AddInObject=ClipboardAddinObject(AddInObject);

	ClipboardText=AddInObject.Text;

	If EmptyAddin Then
		AddInObject=Undefined;
	EndIf;

	Return ClipboardText;

EndFunction

// gets the format of the current value from the clipboard
//
// Parameters:
//  AddInObject - Add-in object - Object of Adding to work with clipboard (optional)
// Returned value:
// String - A string in JSON format containing a description of the format of the clipboard contents
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

// Starts receiving the object of the  clipboard addin.
// If necessary, the components will be attached and installed
//
// Parameters:
// 	NotifyDescription - NotifyDescription -Contains a description of the procedure that will be called after completion with the following parameters:
//<AddInObject> – Object of  AddIn  to work with clipboard, Тип: Add-in object. Undefined- if failed to attach addin
//<AdditionalParameters> -the value that was specified when creating the object NotifyDescription.
Procedure BeginGettingAddIn(NotifyDescription) Export
	BeginInitializeAddin(NotifyDescription, True);
EndProcedure

// Starts getting the version of the clipboard addin used
// 
// Parameters:
// 	NotifyDescription - NotifyDescription -Contains a description of the procedure that will be called after completion with the following parameters:
//	<AddinVersion> – Version of the addin used, Type: Строка. Undefined- if failed to attach addin
//	<AdditionalParameters> -the value that was specified when creating the object NotifyDescription.
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

// Starts clearing the clipboard contents
// 
// Parameters:
// 	NotifyDescription - NotifyDescription -Contains a description of the procedure that will be called after completion with the following parameters:
//	<CleaningType> – Cleaning result, Type: Тип: Булево. Undefined- if failed to attach addin
//	<CallParameters> - Empty array
//	<AdditionalParameters> -the value that was specified when creating the object NotifyDescription.
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

// Starts placing the image to the clipboard
// 
// Parameters:
// 	Картинка
// 	NotifyDescription - NotifyDescription -Contains a description of the procedure that will be called after completion with the following parameters:
//	<Result> – The result of installing the image in the clipboard, Type: Boolean.Undefined- if failed to attach addin
//	<CallParameters> - Array of parameters for calling the component method
//	<AdditionalParameters> -the value that was specified when creating the object NotifyDescription.
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

// Starts receiving an image from the clipboard
// 
// Parameters:
// 	NotifyDescription - NotifyDescription -Contains a description of the procedure that will be called after completion with the following parameters:
//	<ImageData> – Image data in the requested format, Type: String,BinaryData, Picture. Undefined- if failed to attach addin or there is no picture in the buffer
//	<AdditionalParameters> -the value that was specified when creating the object NotifyDescription.
// 	ReturnDataType - String
// 	One of the options:
// 		BinaryData- getting binary image data
// 		Picture- Clipboard  content converted to the "Picture" type
// 		Adress- The address of the binary data of the image in the temporary storage
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

// Starts putting text to the clipboard
// 
// Parameters:
// 	CopiedText- String- A string to be placed in the clipboard
// 	NotifyDescription - NotifyDescription -Contains a description of the procedure that will be called after completion with the following parameters:
//	<Result> – The result of setting the text in the clipboard, Type: Boolean.. Undefined- if failed to attach addin
//	<CallParameters> -Array of parameters for calling the component method
//	<AdditionalParameters> -the value that was specified when creating the object NotifyDescription.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure BeginCopyTextToClipboard(CopiedText, NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		AdditionalParameters=New Structure;
		AdditionalParameters.Insert("CopiedText", CopiedText);
		AdditionalParameters.Insert("NotifyDescriptionOnCompletion", NotifyDescription);

		BeginGettingAddIn(
			New NotifyDescription("BeginCopyTextToClipboardEndGettingAddin", ThisObject,
			AdditionalParameters));
	Else
		AddInObject.BeginCallingSetText(NotifyDescription, CopiedText);
	EndIf;
EndProcedure


// Starts receiving text from the clipboard
// 
// Parameters:
// 	NotifyDescription - NotifyDescription -Contains a description of the procedure that will be called after completion with the following parameters:
//	<Result> – Clipboard text, Type: String. Undefined- if failed to attach addin
//	<AdditionalParameters> -the value that was specified when creating the object NotifyDescription.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure BeginGettingTextFormClipboard(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		AdditionalParameters=New Structure;
		AdditionalParameters.Insert("NotifyDescriptionOnCompletion", NotifyDescription);

		BeginGettingAddIn(
			New NotifyDescription("BeginGettingTextFormClipboardEndGettingAddin", ThisObject,
			AdditionalParameters));
	Else
		AddInObject.BeginGettingText(NotifyDescription);
	EndIf;
EndProcedure


// Starts receiving the format of the current value in the clipboard
// 
// Parameters:
// 	NotifyDescription - NotifyDescription -Contains a description of the procedure that will be called after completion with the following parameters:
//	<Result> – A string in JSON format containing a description of the clipboard content format, Type: String. Undefined- if failed to attach addin
//	<AdditionalParameters> -the value that was specified when creating the object NotifyDescription.
// 	AddInObject - Add-in object - Object of  AddIn  to work with clipboard (optional)
Procedure BeginGettingClipboardFormat(NotifyDescription, AddInObject = Undefined) Export
	If AddInObject = Undefined Then
		AdditionalParameters=New Structure;
		AdditionalParameters.Insert("NotifyDescriptionOnCompletion", NotifyDescription);

		BeginGettingAddIn(
			New NotifyDescription("BeginGettingClipboardFormatEndGettingAddin", ThisObject,
			AdditionalParameters));
	Else
		AddInObject.BeginGettingFormat(NotifyDescription);
	EndIf;
EndProcedure

#EndRegion

#EndRegion

#Region Internal

Procedure BeginInitializeAddin(NotifyDescription, TryToSetAddin = True) Export

	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("OnCompletionNotify", NotifyDescription);
	NotifyAdditionalParameters.Insert("TryToSetAddin", TryToSetAddin);

	BeginAttachingAddIn(
		New NotifyDescription("BeginGettingAddInEndAttachingAddin", ThisObject,
		NotifyAdditionalParameters), AddinTemplateName(), AddInID(),
		AddInType.Native);

EndProcedure

Procedure BeginGettingAddInEndAttachingAddin(Attached, AdditionalParameters) Export
	If Attached Then
		OnCompletionNotify=AdditionalParameters.OnCompletionNotify;
		ExecuteNotifyProcessing(OnCompletionNotify, AddInObject());
	ElsIf AdditionalParameters.TryToSetAddin Then
		BeginInstallAddIn(
			New NotifyDescription("BeginGettingAddInEndInstallAddin", ThisObject,
			AdditionalParameters), AddinTemplateName());
	Else
		OnCompletionNotify=AdditionalParameters.OnCompletionNotify;
		ExecuteNotifyProcessing(OnCompletionNotify, Undefined);
	EndIf;
EndProcedure

Procedure BeginGettingAddInEndInstallAddin(AdditionalParameters) Export
	BeginInitializeAddin(AdditionalParameters.OnCompletionNotify, False);
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

Procedure BeginCopyTextToClipboardEndGettingAddin(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, Undefined);
	Else
		BeginCopyTextToClipboard(AdditionalParameters.CopiedText,
			AdditionalParameters.NotifyDescriptionOnCompletion, Result);
	EndIf;
EndProcedure

Procedure BeginGettingTextFormClipboardEndGettingAddin(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, Undefined);
	Else
		BeginGettingTextFormClipboard(AdditionalParameters.NotifyDescriptionOnCompletion, Result);
	EndIf;
EndProcedure

Procedure BeginGettingClipboardFormatEndGettingAddin(Result, AdditionalParameters) Export
	If Result = Undefined Then
		ExecuteNotifyProcessing(AdditionalParameters.NotifyDescriptionOnCompletion, Undefined);
	Else
		BeginGettingClipboardFormat(AdditionalParameters.NotifyDescriptionOnCompletion, Result);
	EndIf;
EndProcedure

#EndRegion

#Region Private

Function AddinTemplateName()
	Return "CommonTemplate.UT_ClipboardAddin";
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