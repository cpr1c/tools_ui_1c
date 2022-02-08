&AtClient
Procedure Update(Command)
	If ОбновлениеЧерезСкачиваниеФайлаПоставки Then
		ОбновитьЧерезСкачиваниеФайла();
	Else
		ОбновитьЧерезОбновлениеРасширения();
	EndIf;
EndProcedure

&AtClient 
Procedure ОбновитьЧерезСкачиваниеФайла()
	FileName=UT_CommonClientServer.DownloadFileName();
	МассивИмениФайла=UT_StringFunctionsClientServer.SplitStringIntoSubstringsArray(FileName, ".");
	FileExtention=МассивИмениФайла[МассивИмениФайла.Count()-1];
	
	
	FileDialog=New FileDialog(FileDialogMode.Save);
	FileDialog.Extension=FileExtention;
	FileDialog.Filter="File новой версии универсальных инструментов|*."+FileExtention;
	FileDialog.Multiselect=False;
	FileDialog.FullFileName=FileName;
	FileDialog.Show(New NotifyDescription("ОбновитьЧерезСкачиваниеФайлаЗаверешениеВыбораИмениФайла", ThisObject));
EndProcedure

&AtClient 
Procedure ОбновитьЧерезСкачиваниеФайлаЗаверешениеВыбораИмениФайла(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles=Undefined Then
		Return;
	EndIf;
	
	BinaryData=СкачанныеДвоичныеДанныеОбновления();
	If BinaryData=Undefined Then
		Message("Not удалось скачать обновление с сайта обновления");
		Return;
	EndIf;
	
	If TypeOf(BinaryData)<>Type("BinaryData") Then
		Return;
	EndIf;
		
	BinaryData.BeginWriting(New NotifyDescription("ОбновитьЧерезСкачиваниеФайлаЗаверешениеЗаписиФайла", ThisObject), SelectedFiles[0]);
	
EndProcedure	

&AtClient 
Procedure ОбновитьЧерезСкачиваниеФайлаЗаверешениеЗаписиФайла(AdditionalParameters) Export
	ShowMessageBox(, "File успешно скачан");
EndProcedure

&AtClient
Procedure ОбновитьЧерезОбновлениеРасширения()
	РезультатьОбновления=РезультатОбновленияЧерезРасширениеНаСервере();

	If РезультатьОбновления = Undefined Then
		ShowQueryBox(New NotifyDescription("ОбновитьЧерезОбновлениеРасширенияЗавершение", ThisObject),
			"Update успешно применено. For использования изменений нужно перезапустить сеанс. Перезапустить?",
			QuestionDialogMode.YesNo);
	Else
		UT_CommonClientServer.MessageToUser("Error применения обновления " + РезультатьОбновления);
	EndIf;
EndProcedure

&AtClient
Procedure ОбновитьЧерезОбновлениеРасширенияЗавершение(Result, AdditionalParameters) Export
	If Result = DialogReturnCode.None Then
		Return;
	EndIf;

	Exit(False, True);
EndProcedure

&AtServer
Function СкачанныеДвоичныеДанныеОбновления()
	Ответ=UT_HTTPConnector.Get(URLАктуальногоРелиза);

	If Ответ.StatusCode > 300 Then
		Return Undefined;
	EndIf;

	Return Ответ.Body;
	
EndFunction

&AtServer
Function РезультатОбновленияЧерезРасширениеНаСервере()
	BinaryData=СкачанныеДвоичныеДанныеОбновления();
	
	If BinaryData=Undefined Then
		Return "Not удалось скачать файл обновления с сервера";
	EndIf;

	If TypeOf(BinaryData) <> Type("BinaryData") Then
		Return "Неправильный формат файла облновления";
	EndIf;

	Filter = New Structure;
	Filter.Insert("Name", "УниверсальныеИнструменты");

	НайденныеРасширения = ConfigurationExtensions.Get(Filter);

	If НайденныеРасширения.Count() = 0 Then
		Return "Not обнаружено расширение Универсальные инструменты";
	EndIf;

	НашеРасширение = НайденныеРасширения[0];
	
	// Проверим возможность применения расширения

	РезультатПроверки=НашеРасширение.CheckCanApply(BinaryData, False);

	If РезультатПроверки.Count() > 0 Then
		СообщениеОбОшибках="";
		For Each ConfigurationExtensionApplicationIssueInformation In РезультатПроверки Do
			СообщениеОбОшибках=СообщениеОбОшибках + ?(ValueIsFilled(СообщениеОбОшибках), Chars.LF, "") + "Error применения расширения "
				+ ConfigurationExtensionApplicationIssueInformation.LongDesc;
		EndDo;

		Return СообщениеОбОшибках;
	EndIf;

	РезультатОбновления=Undefined;
	Try
		НашеРасширение.Write(BinaryData);
	Except
		РезультатОбновления=ErrorDescription();
	EndTry;

	Return РезультатОбновления;

EndFunction

&AtServer
Procedure ЗаполнитьТекущуюВерсию()
	CurrentVersion = UT_CommonClientServer.Version();
	DistributionType=UT_CommonClientServer.DistributionType();
	ИмяФайлаСкачки=UT_CommonClientServer.DownloadFileName();
	ОбновлениеЧерезСкачиваниеФайлаПоставки=Not StrEndsWith(Lower(ИмяФайлаСкачки), "cfe");
EndProcedure

&AtServer
Procedure ЗаполнитьАктуальнуюВерсиюИОписаниеИзменений()
//Получаем список всех релизов
	АдресЗапроса = "https://api.github.com/repos/cpr1c/tools_ui_1c/releases";
	ИмяФайлаСкачки=UT_CommonClientServer.DownloadFileName();
	
	МассивРелизов = UT_HTTPConnector.GetJson(АдресЗапроса);

	МаксимальныйРелиз = "0.0.0";
	СоответствиеОписанияРелизов = New Map;

	For Each ТекРелиз In МассивРелизов Do
		ВерсияТекРелиза = StrReplace(ТекРелиз["tag_name"], "v", "");

		If UT_CommonClientServer.CompareVersionsWithoutBuildNumber(ВерсияТекРелиза, CurrentVersion) > 0 Then
			СоответствиеОписанияРелизов.Insert(ВерсияТекРелиза, ТекРелиз);
		EndIf;

		If UT_CommonClientServer.CompareVersionsWithoutBuildNumber(ВерсияТекРелиза, МаксимальныйРелиз) <= 0 Then
			Continue;
		EndIf;

		МаксимальныйРелиз = ВерсияТекРелиза;
		ВложенияРелиза = ТекРелиз["assets"];
		If ВложенияРелиза = Undefined Then
			URLАктуальногоРелиза = "";
		Else
			For Each ТекВложение In ВложенияРелиза Do
				ИмяФайлаРелиза = ТекВложение["name"];

				If StrFind(Lower(ИмяФайлаРелиза), Lower(ИмяФайлаСкачки)) = 0 Then
					Continue;
				EndIf;

				URLАктуальногоРелиза=ТекВложение["browser_download_url"];
				Abort;
			EndDo;
		EndIf;
	EndDo;

	ActualVersion = МаксимальныйРелиз;

	ChangesDescription = "";
	For Each РелизОписания In СоответствиеОписанияРелизов Do
		ChangesDescription = ChangesDescription + РелизОписания.Key + Chars.LF;
		ChangesDescription = ChangesDescription + РелизОписания.Value["body"] + Chars.LF;
	EndDo;
EndProcedure

&AtServer
Procedure УстановитьНеобходимостьОбновления()
	If UT_CommonClientServer.CompareVersionsWithoutBuildNumber(ActualVersion, CurrentVersion) > 0 Then
		НеобходимостьОбновления = True;
	EndIf;

	Items.FormUpdate.Visible = НеобходимостьОбновления;
	Items.ChangesDescription.Visible = НеобходимостьОбновления;
	
	If ОбновлениеЧерезСкачиваниеФайлаПоставки Then
		Items.FormUpdate.Title="Скачать";
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, СтандартнаяОбработка)
	ЗаполнитьТекущуюВерсию();
	ЗаполнитьАктуальнуюВерсиюИОписаниеИзменений();
	УстановитьНеобходимостьОбновления();
EndProcedure