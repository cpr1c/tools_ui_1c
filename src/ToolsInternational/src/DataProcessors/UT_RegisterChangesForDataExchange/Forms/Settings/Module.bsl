////////////////////////////////////////////////////////////////////////////////////////////////////
// EVENT HANDLERS
//

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	VerifyAccessRights("Administration", Metadata);

	If Parameters.Property("AutoTests") Then // Return when a form is received for analysis.
		Return;
	EndIf;

	QueryConsoleID = "UT_QueryConsole";

	CurrentObject = ThisObject();
	CurrentObject.ReadSettings();
	CurrentObject.ReadSSLSupportFlags();
	
	Row = TrimAll(CurrentObject.QueryExternalDataProcessorAddressSetting);
	If Lower(Right(Row, 4)) = ".epf" Then
		QueryConsoleUsageOption = 2;
	ElsIf Metadata.DataProcessors.Find(Row) <> Undefined Then
		QueryConsoleUsageOption = 1;
		Row = "";
	Else
		QueryConsoleUsageOption = 0;
		Row = "";
	EndIf;
	CurrentObject.QueryExternalDataProcessorAddressSetting = Row;
	
	ThisObject(CurrentObject);
	
	ChoiceList = Items.ExternalQueryDataProcessor.ChoiceList;
	
	// The data processor is included in the metadata if it is a predefined part of the configuration.
	If Metadata.DataProcessors.Find(QueryConsoleID) = Undefined Then
		CurItem = ChoiceList.FindByValue(1);
		If CurItem <> Undefined Then
			ChoiceList.Delete(CurItem);
		EndIf;
	EndIf;
	
	// Option string from the file
	If CurrentObject.IsFileInfobase() Then
		CurItem = ChoiceList.FindByValue(2);
		If CurItem <> Undefined Then
			CurItem.Presentation = NStr("ru = 'В каталоге:'; en = 'In directory:'");
		EndIf;
	EndIf;

	// SSLGroup form item is visible if this SSL version is supported.
	Items.SLGroup.Visible = CurrentObject.ConfigurationSupportsSSL
	
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// FORM ITEM EVENT HANDLERS
//

&AtClient
Procedure QueryDataProcessorPathOnChange(Item)
	QueryConsoleUsageOption = 2;
EndProcedure

&AtClient
Procedure QueryDataProcessorPathStartChoice(Item, ChioceData, StandardProcessing)
	StandardProcessing = False;
	Dialog = New FileDialog(FileDialogMode.Open);
	Dialog.CheckFileExistence = True;
	Dialog.Filter = NStr("ru='Внешние обработки (*.epf)|*.epf'; en='External data processor (*.epf)|*.epf'");
	Dialog.Show(New NotifyDescription("QueryDataProcessorPathStartChoiceCompletion", ThisForm,
		New Structure("Dialog", Dialog)));
EndProcedure

&AtClient
Procedure QueryDataProcessorPathStartChoiceCompletion(SelectedFiles, AdditionalParameters) Export

	Dialog = AdditionalParameters.Dialog;
	If (SelectedFiles <> Undefined) Then
		QueryConsoleUsageOption = 2;
		SetQueryExternalDataProcessorAddressSetting(Dialog.FullFileName);
	EndIf;

EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// FORM COMMAND HANDLERS
//

&AtClient
Procedure ConfirmSelection(Command)
	
	CheckSSL = CheckSettings();
	If CheckSSL.HasErrors Then
		// Reporting errors
		If CheckSSL.QueryExternalDataProcessorAddressSetting <> Undefined Then
			ReportError(CheckSSL.QueryExternalDataProcessorAddressSetting, "Object.QueryExternalDataProcessorAddressSetting");
			Return;
		EndIf;
	EndIf;
	
	// Success
	SaveSettings();
	Close();
EndProcedure

////////////////////////////////////////////////////////////////////////////////////////////////////
// PRIVATE
//

&AtClient
Procedure ReportError(Text, AttributeName = Undefined)
	
	If AttributeName = Undefined Then
		ErrorTitle = NStr("ru = 'Ошибка'; en = 'Error'");
		ShowMessageBox(, Text, , ErrorTitle);
		Return;
	EndIf;
	
	Message = New UserMessage();
	Message.Text = Text;
	Message.Field  = AttributeName;
	Message.SetData(ThisObject);
	Message.Message();
EndProcedure

&AtServer
Function ThisObject(CurrentObject = Undefined) 
	If CurrentObject = Undefined Then
		Return FormAttributeToValue("Object");
	EndIf;
	ValueToFormAttribute(CurrentObject, "Object");
	Return Undefined;
EndFunction

&AtServer
Function CheckSettings()
	CurrentObject = ThisObject();
	
	If QueryConsoleUsageOption = 2 Then
		If Lower(Right(TrimAll(CurrentObject.QueryExternalDataProcessorAddressSetting), 4)) <> ".epf" Then
			CurrentObject.QueryExternalDataProcessorAddressSetting = TrimAll(
				CurrentObject.QueryExternalDataProcessorAddressSetting) + ".epf";
		EndIf;
	ElsIf QueryConsoleUsageOption = 0 Then
		CurrentObject.QueryExternalDataProcessorAddressSetting = "";
	EndIf;
	Result = CurrentObject.CheckSettingsCorrectness();
	ThisObject(CurrentObject);

	Return Result;
EndFunction

&AtServer
Procedure SaveSettings()
	CurrentObject = ThisObject();
	If QueryConsoleUsageOption = 0 Then
		CurrentObject.QueryExternalDataProcessorAddressSetting = "";
	ElsIf QueryConsoleUsageOption = 1 Then
		CurrentObject.QueryExternalDataProcessorAddressSetting = QueryConsoleID;
	EndIf;
	CurrentObject.SaveSettings();
	ThisObject(CurrentObject);
EndProcedure

&НаСервере
Procedure SetQueryExternalDataProcessorAddressSetting(FilePath)
	CurrentObject = ThisObject();
	CurrentObject.QueryExternalDataProcessorAddressSetting = FilePath;
	ThisObject(CurrentObject);
EndProcedure