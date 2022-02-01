&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	NewAttributesArray=New Array;
	NewAttributesArray.Add(New FormAttribute("User", New TypeDescription("CatalogRef.Users"), "", NStr("ru = 'Пользователь';en = 'User'"), True));
	NewAttributesArray.Add(New FormAttribute("AdditionalDataProcessor", New TypeDescription("CatalogRef.AdditionalReportsAndDataProcessors"), "", Nstr("ru = 'Дополнительная обработка';en = 'Additional dataprocessor'"), True));
	
	ChangeAttributes(NewAttributesArray,);

	AdditionalDataProcessor=Parameters.AdditionalDataProcessor;
	
	ThisObject.AdditionalDataProcessor = AdditionalDataProcessor;

	Kind = UT_Common.ObjectAttributeValue(AdditionalDataProcessor, "Kind");
	If Kind = Enums.AdditionalReportsAndDataProcessorsKinds.Report Or Kind
		= Enums.AdditionalReportsAndDataProcessorsKinds.AdditionalReport Then
		IsReport=True;
	EndIf;
	
	
	ItemDescription=UT_Forms.ItemAttributeNewDescription();
	ItemDescription.Name="User";
	ItemDescription.DataPath="User";
	UT_Forms.CreateItemByDescription(ThisObject, ItemDescription);
	
	
	SavedSettings=UT_Common.AdditionalDataProcessorDebugSettings(AdditionalDataProcessor);
	FillPropertyValues(ThisObject, SavedSettings);
EndProcedure

&AtServer
Procedure ApplyAtServer()
	SettingsStructure=UT_Common.NewStructureOfAdditionalDataProcessorDebugSettings();
	FillPropertyValues(SettingsStructure, ThisObject);
	
	UT_Common.SaveAdditionalDataProcessorDebugSettings(ThisObject.AdditionalDataProcessor, SettingsStructure);	
EndProcedure

&AtClient
Procedure Apply(Command)
	ApplyAtServer();
	Close();
EndProcedure

&AtClient
Procedure FileNameAtServerStartChoice(Item, ChoiceData, StandardProcessing)
				DescriptionStructureOfSelectedFile=UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	DescriptionStructureOfSelectedFile.FileName=FileNameAtServer;

	If IsReport Then
		UT_CommonClient.AddFormatToSavingFileDescription(DescriptionStructureOfSelectedFile,
			"Report (*.erf)", "erf");
	Else
		UT_CommonClient.AddFormatToSavingFileDescription(DescriptionStructureOfSelectedFile,
			"Data processor (*.epf)", "epf");
	EndIf;

	UT_CommonClient.FormFieldFileNameStartChoice(DescriptionStructureOfSelectedFile, Item, ChoiceData,
		StandardProcessing, FileDialogMode.Open,
		New NotifyDescription("FileNameAtServerStartChoiceEnd", ThisObject));
EndProcedure


&AtClient
Procedure FileNameAtServerStartChoiceEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	If Result.Count()=0 Then
		Return;
	EndIf;

	FileNameAtServer=Result[0];
EndProcedure