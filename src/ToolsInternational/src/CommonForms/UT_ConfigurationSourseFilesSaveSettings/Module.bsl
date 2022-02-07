#Region Variables

#EndRegion

#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	CodeSources = UT_CodeEditorServer.ДоступныеИсточникиИсходногоКода();
	
	For Each CurrentSource ИЗ CodeSources Do
		NewRow = SaveDirectories.Add();
		NewRow.Check = True;
		NewRow.Source = CurrentSource.Value;
		NewRow.OnlyModules = True;
		
		NewRow.Directory = Parameters.ТекущиеКаталоги[NewRow.Source];
	EndDo;

	ConnectionString = InfoBaseConnectionString();

	МассивПоказателейСтрокиСоединения = СтрРазделить(ConnectionString, ";");
	СоответствиеПоказателейСтрокиСоединения = New Structure;
	For Each СтрокаПоказателяСтрокиСоединения In МассивПоказателейСтрокиСоединения Do
		МассивПоказателя = СтрРазделить(СтрокаПоказателяСтрокиСоединения, "=");
		If МассивПоказателя.Количество() <> 2 Then
			Continue;
		EndIf;
		Показатель = НРег(МассивПоказателя[0]);
		ЗначениеПоказателя = МассивПоказателя[1];
		СоответствиеПоказателейСтрокиСоединения.Insert(Показатель, ЗначениеПоказателя);
	EndDo;

	If СоответствиеПоказателейСтрокиСоединения.Свойство("file") Then
		InfobasePlacement = 0;
		InfobaseDirectory = UT_StringFunctionsClientServer.PathWithoutQuotes(
			СоответствиеПоказателейСтрокиСоединения.File);
	ElsIf СоответствиеПоказателейСтрокиСоединения.Свойство("srvr") Then
		InfobasePlacement = 1;
		InfobaseServer = UT_StringFunctionsClientServer.PathWithoutQuotes(СоответствиеПоказателейСтрокиСоединения.srvr);
		InfoBaseName = UT_StringFunctionsClientServer.PathWithoutQuotes(СоответствиеПоказателейСтрокиСоединения.ref);
	EndIf;
	User = UserName();

	УстановитьВидимостьДоступность();
	
EndProcedure


&AtServer
Procedure FillCheckProcessingAtServer(Cancel, CheckedAttributes)
	For Each Стр In SaveDirectories Do
		If Not Стр.Check Then
			Continue;
		EndIf;
		
		If Not ValueIsFilled(Стр.Каталог) Then
			UT_CommonClientServer.MessageToUser("For источника "+Стр.Source+" не указан Directory сохранения", , , , Cancel);
		EndIf;
	EndDo;
	
	If InfobasePlacement = 0 Then
		CheckedAttributes.Add("InfobaseDirectory");
	Иначе
		CheckedAttributes.Add("InfobaseServer");
		CheckedAttributes.Add("InfoBaseName");
	EndIf;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	#If Not ВебКлиент And Not МобильныйКлиент Then
	PlatformLaunchFile = BinDir();
	If Right(PlatformLaunchFile, 1) <> GetPathSeparator() Then
		PlatformLaunchFile = PlatformLaunchFile + GetPathSeparator();
	EndIf;
	
	PlatformLaunchFile = PlatformLaunchFile + "1cv8";	
	If UT_CommonClientServer.IsWindows() Then
		PlatformLaunchFile = PlatformLaunchFile + ".exe";
	EndIf;
	
	#КонецЕсли
EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовШапкиФормы

&AtClient
Procedure InfobasePlacementOnChange(Item)
	УстановитьВидимостьДоступность();
EndProcedure

&AtClient
Procedure PlatformLaunchFileStartChoice(Item, ChoiceData, StandardProcessing)
	ОписаниеФайла = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	ОписаниеФайла.ИмяФайла = PlatformLaunchFile;

	ИмяФайла = "1cv8";
	
	If UT_CommonClientServer.IsWindows() Then
		ИмяФайла = ИмяФайла+".exe";
	EndIf;
	
	UT_CommonClient.AddFormatToSavingFileDescription(ОписаниеФайла, "Файл толстого клиента 1С("+ИмяФайла+")", "",ИмяФайла);
	
	UT_CommonClient.FormFieldFileNameStartChoice(ОписаниеФайла, Item, ChoiceData, StandardProcessing,
		FileDialogMode.Open,
		New NotifyDescription("ФайлЗапускаПлатформыНачалоВыбораЗавершение", ЭтотОбъект));
EndProcedure

&AtClient
Procedure SaveDirectoriesDirectoryStartChoice(Item, ChoiceData, StandardProcessing)
	ТекДанные = Items.SaveDirectories.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;
	
	ОписаниеФайла = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	ОписаниеФайла.ИмяФайла = ТекДанные.Directory;
	
	ДопПараметрыОповещения = New Structure;
	ДопПараметрыОповещения.Insert("ТекущаяСтрока", Items.SaveDirectories.CurrentRow);
	
	UT_CommonClient.FormFieldFileNameStartChoice(ОписаниеФайла, Item, ChoiceData, StandardProcessing,
		FileDialogMode.ChooseDirectory,
		New NotifyDescription("КаталогиСохраненияКаталогНачалоВыбораЗаверешение", ЭтотОбъект,
		ДопПараметрыОповещения));
EndProcedure

&AtClient
Procedure InfobaseDirectoryStartChoice(Item, ChoiceData, StandardProcessing)
	ОписаниеФайла = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	ОписаниеФайла.ИмяФайла = InfobaseDirectory;
	
	UT_CommonClient.FormFieldFileNameStartChoice(ОписаниеФайла, Item, ChoiceData, StandardProcessing,
		РежимДиалогаВыбораФайла.ВыборКаталога,
		New NotifyDescription("КаталогиСохраненияКаталогНачалоВыбораЗаверешение", ЭтотОбъект));
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure SelectCommonSaveDirectory(Команда)
	ДВФ = New ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	ДВФ.МножественныйВыбор = False;
	ДВФ.Показать(New NotifyDescription("ВыбратьОбщийКаталогСохраненияЗавершение", ЭтотОбъект));
EndProcedure

&AtClient
Procedure SetChecks(Command)
	For Each Стр In SaveDirectories Do
		Стр.Check = True;
	EndDo;
EndProcedure

&AtClient
Procedure UnsetChecks(Command)
	For Each Стр In SaveDirectories Do
		Стр.Check = False;
	EndDo;	
EndProcedure

&AtClient
Procedure UnloadSourceModules(Command)
	If Not ПроверитьЗаполнение() Then
		Return;
	EndIf;
	
	КаталогиИсточников= New Array();
	
	For Each Стр In SaveDirectories Do
		If Not Стр.Check Then
			Continue;
		EndIf;
		
		ОписаниеИсточника = New Structure;
		ОписаниеИсточника.Insert("Source", Стр.Источник);
		ОписаниеИсточника.Insert("Directory", Стр.Каталог);
		ОписаниеИсточника.Insert("OnlyModules", Стр.OnlyModules);
		
		КаталогиИсточников.Add(ОписаниеИсточника);
	EndDo;
	
	НастройкиСохранения = New Structure;
	НастройкиСохранения.Insert("PlatformLaunchFile", PlatformLaunchFile);
	НастройкиСохранения.Insert("User", User);
	НастройкиСохранения.Insert("Password", Password);
	НастройкиСохранения.Insert("КаталогиИсточников", КаталогиИсточников);
	НастройкиСохранения.Insert("InfobasePlacement", InfobasePlacement);
	If InfobasePlacement = 0 Then
		НастройкиСохранения.Insert("InfobaseDirectory", InfobaseDirectory);
	Иначе
		НастройкиСохранения.Insert("InfobaseServer", InfobaseServer);
		НастройкиСохранения.Insert("InfoBaseName", InfoBaseName);
	EndIf;
	
	Закрыть(НастройкиСохранения);
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure УстановитьВидимостьДоступность()
	If InfobasePlacement = 0 Then
		НоваяСтраница = Items.GroupFileInfobase;
	Иначе
		НоваяСтраница = Items.GroupServerInfoBase;
	EndIf;
	
	Items.GroupPagesInfobasePlacement.ТекущаяСтраница = НоваяСтраница;
EndProcedure

&AtClient
Procedure ФайлЗапускаПлатформыНачалоВыбораЗавершение(Результат, ДополнительныеПараметры) Экспорт
	If Результат = Undefined Then
		Return;
	EndIf;
	
	If Результат.Количество() = 0  Then
		Return;
	EndIf;
	
	PlatformLaunchFile = Результат[0];
EndProcedure

&AtClient
Procedure ВыбратьОбщийКаталогСохраненияЗавершение(Результат, ДополнительныеПараметры) Экспорт
	If Результат = Undefined Then
		Return;
	EndIf;
	
	If Результат.Количество()=0 Then
		Return;
	EndIf;
	
	ОбщийКаталогСохранения = Результат[0];
	
	For Each ТекСТр In SaveDirectories Do
//		If ЗначениеЗаполнено(ТекСТр.Directory) Then
//			Continue;
//		EndIf;
//		
		ТекСТр.Directory = ОбщийКаталогСохранения + ПолучитьРазделительПути() + ТекСТр.Source;
	EndDo;
	
EndProcedure

&AtClient
Procedure КаталогиСохраненияКаталогНачалоВыбораЗаверешение(Результат, ДополнительныеПараметры) Экспорт
	If Результат = Undefined Then
		Return;
	EndIf;
	
	If Результат.Количество()=0 Then
		Return;
	EndIf;
	
	ТекДанные = SaveDirectories.НайтиПоИдентификатору(ДополнительныеПараметры.ТекущаяСтрока);
	ТекДанные.Directory = Результат[0];
	
	Модифицированность = True;
EndProcedure

&AtClient
Procedure КаталогИнформационнойБазыНачалоВыбораЗавершение(Результат, ДополнительныеПараметры) Экспорт
	If Результат = Undefined Then
		Return;
	EndIf;
	
	If Результат.Количество() = 0  Then
		Return;
	EndIf;
	
	InfobaseDirectory = Результат[0];
	
EndProcedure
#EndRegion