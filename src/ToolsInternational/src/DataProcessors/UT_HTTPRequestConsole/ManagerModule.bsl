Function SerializedDataForSave(Format, SavedData) Export
	
	If Format = "xhttp" Or Format = ".xhttp" Then

		SerializedString = ValueToStringInternal(SavedData);

	Else
		JSONSerializer = DataProcessors.UT_JSONDataConversion.Create();

		HistoryStruct = JSONSerializer.ЗначениеВСтруктуру(SavedData);
		SerializedString=JSONSerializer.ЗаписатьОписаниеОбъектаВJSON(HistoryStruct);

	EndIf;

	Return SerializedString;

EndFunction

Function SavedDataFromSerializedString(TempStorageAddress, RequestsFileName) Export
	
	File = New File(RequestsFileName);

	If File.Extension = "xhttp" Or File.Extension = ".xhttp" Then
		TempFileName = GetTempFileName();
		TempData = GetFromTempStorage(TempStorageAddress);
		TempData.Write(TempFileName);

		Return ValueFromFile(TempFileName);
	Else
		FileData = GetFromTempStorage(TempStorageAddress);

		TextDocument = New TextDocument;
		TextDocument.Read(FileData.OpenStreamForRead());

		JSONSerialize = DataProcessors.UT_JSONDataConversion.Create();
		TableStruct = JSONSerialize.ПрочитатьОписаниеОбъектаИзJSON(TextDocument.GetText());
		Return JSONSerialize.ЗначениеИзСтруктуры(TableStruct, True);
	EndIf;
	
EndFunction