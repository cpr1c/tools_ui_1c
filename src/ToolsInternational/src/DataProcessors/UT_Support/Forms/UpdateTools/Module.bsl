&AtClient
Procedure Update(Command)
	If UpdateViaDownloadOfDistributionPackage Then
		UpdateViaFileDownload();
	Else
		UpdateViaExtensionUpdate();
	EndIf;
EndProcedure

&AtClient 
Procedure UpdateViaFileDownload()
	FileName=UT_CommonClientServer.DownloadFileName();
	FileNameArray=UT_StringFunctionsClientServer.SplitStringIntoSubstringsArray(FileName, ".");
	FileExtention=FileNameArray[FileNameArray.Count()-1];
	
	
	FileDialog=New FileDialog(FileDialogMode.Save);
	FileDialog.Extension=FileExtention;
	FileDialog.Filter=StrTemplate(NStr("ru = 'Файл новой версии универсальных инструментов|*.%1';
	|en = 'The file of the new version of universal tools|*.%1'"),FileExtention);
	FileDialog.Multiselect=False;
	FileDialog.FullFileName=FileName;
	FileDialog.Show(New NotifyDescription("UpdateViaFileDownloadEndFileNameChoose", ThisObject));
EndProcedure

&AtClient 
Procedure UpdateViaFileDownloadEndFileNameChoose(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles=Undefined Then
		Return;
	EndIf;
	
	BinaryData=DownloadedBinaryUpdateData();
	If BinaryData=Undefined Then
		Message(NStr("ru = 'Не удалось скачать обновление с сайта обновления';
		|en = 'Failed to download the update from the update site'"));
		Return;
	EndIf;
	
	If TypeOf(BinaryData)<>Type("BinaryData") Then
		Return;
	EndIf;
		
	BinaryData.BeginWriting(New NotifyDescription("UpdateViaFileDownloadEndFileWrite", ThisObject), SelectedFiles[0]);
	
EndProcedure	

&AtClient 
Procedure UpdateViaFileDownloadEndFileWrite(AdditionalParameters) Export
	ShowMessageBox(, Nstr("ru = 'Файл успешно скачан';en = 'File downloaded successfully'"));
EndProcedure

&AtClient
Procedure UpdateViaExtensionUpdate()
	UpdateResult=ResultUpdateViaExtensionAtServer();

	If UpdateResult = Undefined Then
		ShowQueryBox(New NotifyDescription("UpdateViaExtensionUpdateOnEnd", ThisObject),Nstr("ru = 'Обновление успешно применено. Для использования изменений нужно перезапустить сеанс. Перезапустить?';
		|en = 'The update was successfully applied. To use the changes, you need to restart the session. Restart?'"),
			QuestionDialogMode.YesNo);
	Else
		UT_CommonClientServer.MessageToUser(StrTemplate(Nstr("ru = 'Ошибка применения обновления %1';en = 'Update application error %1'"),UpdateResult));
	EndIf;
EndProcedure

&AtClient
Procedure UpdateViaExtensionUpdateOnEnd(Result, AdditionalParameters) Export
	If Result = DialogReturnCode.None Then
		Return;
	EndIf;

	Exit(False, True);
EndProcedure

&AtServer
Function DownloadedBinaryUpdateData()
	Response=UT_HTTPConnector.Get(ActualVersionURL);

	If Response.StatusCode > 300 Then
		Return Undefined;
	EndIf;

	Return Response.Body;
	
EndFunction

&AtServer
Function ResultUpdateViaExtensionAtServer()
	BinaryData=DownloadedBinaryUpdateData();
	
	If BinaryData=Undefined Then
		Return NStr("ru = 'He удалось скачать файл обновления с сервера';en = 'Failed to download the update file from the server'");
	EndIf;

	If TypeOf(BinaryData) <> Type("BinaryData") Then
		Return NStr("ru = 'Неправильный формат файла обновления';en = 'Incorrect update file format'");
	EndIf;

	Filter = New Structure;
	Filter.Insert("Name", "UniversalTools");

	FoundExtensions = ConfigurationExtensions.Get(Filter);

	If FoundExtensions.Count() = 0 Then
		Return Nstr("ru = 'Не обнаружено расширение Универсальные инструменты';en = 'Universal Tools extension not found'")
	EndIf;

	OurExtension = FoundExtensions[0];
	
	// Let's check the possibility of using the extension

	CheckResult=OurExtension.CheckCanApply(BinaryData, False);

	If CheckResult.Count() > 0 Then
		MessageAboutErrors="";
		For Each ConfigurationExtensionApplicationIssueInformation In CheckResult Do
			MessageAboutErrors=MessageAboutErrors + ?(ValueIsFilled(MessageAboutErrors), Chars.LF, "") + NSTR("ru = 'Ошибка применения расширения';
			|en = 'Extension apply error'") + ConfigurationExtensionApplicationIssueInformation.Description;
		EndDo;

		Return MessageAboutErrors;
	EndIf;

	UpdateResult=Undefined;
	Try
		OurExtension.Write(BinaryData);
	Except
		UpdateResult=ErrorDescription();
	EndTry;

	Return UpdateResult;

EndFunction

&AtServer
Procedure FillCurrentVersion()
	CurrentVersion = UT_CommonClientServer.Version();
	DistributionType=UT_CommonClientServer.DistributionType();
	DownloadFileName=UT_CommonClientServer.DownloadFileName();
	UpdateViaDownloadOfDistributionPackage=Not StrEndsWith(Lower(DownloadFileName), "cfe");
EndProcedure

&AtServer
Procedure FillActualVersionAndChangesDescription()
//Getting a list of all releases
	RequestUrl = "https://api.github.com/repos/i-neti/tools_ui_1c_international/releases";
	DownloadFileName=UT_CommonClientServer.DownloadFileName();
	
	ReleasesArray = UT_HTTPConnector.GetJson(RequestUrl);

	MaxRelease = "0.0.0";
	ReleasesDescriptionMap = New Map;

	For Each CurrentRelease In ReleasesArray Do
		CurrentReleaseVersion = StrReplace(CurrentRelease["tag_name"], "v", "");

		If UT_CommonClientServer.CompareVersionsWithoutBuildNumber(CurrentReleaseVersion, CurrentVersion) > 0 Then
			ReleasesDescriptionMap.Insert(CurrentReleaseVersion, CurrentRelease);
		EndIf;

		If UT_CommonClientServer.CompareVersionsWithoutBuildNumber(CurrentReleaseVersion, MaxRelease) <= 0 Then
			Continue;
		EndIf;

		MaxRelease = CurrentReleaseVersion;
		ReleaseAssets = CurrentRelease["assets"];
		If ReleaseAssets = Undefined Then
			ActualVersionURL = "";
		Else
			For Each CurrentAsset In ReleaseAssets Do
				ReleaseFileName = CurrentAsset["name"];

				If StrFind(Lower(ReleaseFileName), Lower(DownloadFileName)) = 0 Then
					Continue;
				EndIf;

				ActualVersionURL=CurrentAsset["browser_download_url"];
				Break;
			EndDo;
		EndIf;
	EndDo;

	ActualVersion = MaxRelease;

	ChangesDescription = "";
	For Each ReleaseDescription In ReleasesDescriptionMap Do
		ChangesDescription = ChangesDescription + ReleaseDescription.Key + Chars.LF;
		ChangesDescription = ChangesDescription + ReleaseDescription.Value["body"] + Chars.LF;
	EndDo;
EndProcedure

&AtServer
Procedure SetNeedForUpdate()
	If UT_CommonClientServer.CompareVersionsWithoutBuildNumber(ActualVersion, CurrentVersion) > 0 Then
		NeedForUpdate = True;
	EndIf;

	Items.FormUpdate.Visible = NeedForUpdate;
	Items.ChangesDescription.Visible = NeedForUpdate;
	
	If UpdateViaDownloadOfDistributionPackage Then
		Items.FormUpdate.Title=NStr("ru = 'Скачать';en = 'Download'");
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	FillCurrentVersion();
	FillActualVersionAndChangesDescription();
	SetNeedForUpdate();
EndProcedure