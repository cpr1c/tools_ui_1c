
#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	УстановитьСписокВыбораЭлементаИзСтруктуры(Items.EditorOf1CScript,
		UT_CodeEditorClientServer.ВариантыРедактораКода());
	
	УстановитьСписокВыбораЭлементаИзСтруктуры(Items.MonacoEditorTheme,
		UT_CodeEditorClientServer.ВариантыТемыРедактораMonaco());
	
	УстановитьСписокВыбораЭлементаИзСтруктуры(Items.MonacoEditorScriptVariant,
		UT_CodeEditorClientServer.ВариантыЯзыкаСинтаксисаРедактораMonaco());

	ПараметрыРедактора = UT_CodeEditorServer.ТекущиеПараметрыРедактораКода();	
	EditorOf1CScript = ПараметрыРедактора.Вариант;
	FontSize = ПараметрыРедактора.FontSize;	

	MonacoEditorTheme = ПараметрыРедактора.Monaco.Тема;
	MonacoEditorScriptVariant = ПараметрыРедактора.Monaco.ЯзыкСинтаксиса;
	UseScriptMap = ПараметрыРедактора.Monaco.UseScriptMap;
	HideLineNumbers = ПараметрыРедактора.Monaco.HideLineNumbers;
	ВысотаСтрок = ПараметрыРедактора.Monaco.LinesHeight;

	ConfigurationSourceFilesDirectories.Clear();
	Items.ConfigurationSourceFilesDirectoriesSource.СписокВыбора.Clear();
	ИсточникиИсходногоКода = UT_CodeEditorServer.ДоступныеИсточникиИсходногоКода();
	
	For Each ТекОписаниеКаталога In ПараметрыРедактора.Monaco.КаталогиИсходныхФайлов Do
		НС = ConfigurationSourceFilesDirectories.Add();
		НС.Directory = ТекОписаниеКаталога.Directory;
		НС.Source = ТекОписаниеКаталога.Source;
	
		Items.ConfigurationSourceFilesDirectoriesSource.СписокВыбора.Add(НС.Source);
	EndDo;

	For Each ТекИсточник In ИсточникиИсходногоКода Do
		СтруктураПоиска = New Structure;
		СтруктураПоиска.Insert("Source", ТекИсточник.Значение);
		
		НайденныеСтроки = ConfigurationSourceFilesDirectories.НайтиСтроки(СтруктураПоиска);
		If НайденныеСтроки.Количество()>0 Then
			Continue;
		EndIf;
		
		НС = ConfigurationSourceFilesDirectories.Add();
		НС.Source = ТекИсточник.Значение;
		
		Items.ConfigurationSourceFilesDirectoriesSource.СписокВыбора.Add(ТекИсточник.Значение);
		
	EndDo;

	УстановитьВидимостьЭлементов();
EndProcedure

&AtServer
Procedure FillCheckProcessingAtServer(Cancel, CheckedAttributes)
	ВариантыРедактораКода = UT_CodeEditorClientServer.ВариантыРедактораКода();
	
	If EditorOf1CScript = ВариантыРедактораКода.Monaco Then
		CheckedAttributes.Add("MonacoEditorTheme");
		CheckedAttributes.Add("MonacoEditorScriptVariant");
	EndIf;

	НомерСтроки = 1;
	For Each Стр In ConfigurationSourceFilesDirectories Do
		If Not ЗначениеЗаполнено(Стр.Source) 
			И ЗначениеЗаполнено(Стр.Каталог) Then
			UT_CommonClientServer.MessageToUser("В строке " + НомерСтроки
				+ " не заполнен Source исходного кода",,,, Отказ);
		EndIf;
		
		НомерСтроки = НомерСтроки +1;
	EndDo;

	ТЗИсточников = ConfigurationSourceFilesDirectories.Выгрузить(, "Source");
	ТЗИсточников.Свернуть("Source");
	
	For Each Стр ИЗ ТЗИсточников Do
		СтруктураПоиска = New Structure;
		СтруктураПоиска.Insert("Source", Стр.Источник);

		НайденныеСтроки = ConfigurationSourceFilesDirectories.НайтиСтроки(СтруктураПоиска);

		If НайденныеСтроки.Количество() > 1 Then
			UT_CommonClientServer.MessageToUser("С источником исходного кода " + Стр.Source
				+ " обнаружено более одной строки. Запись невозможна",,,, Отказ);
		EndIf;
	EndDo;
EndProcedure


#EndRegion

#Region ОбработчикиСобытийЭлементовШапкиФормы



&AtClient
Procedure EditorOf1CScriptOnChange(Item)
	УстановитьВидимостьЭлементов();
EndProcedure



&AtClient
Procedure КаталогиИсходныхФайловКонфигурацииКаталогНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ТекДанные = Items.ConfigurationSourceFilesDirectories.ТекущиеДанные;
	If ТекДанные = Undefined Then
		Return;
	EndIf;
	
	ОписаниеФайла = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	ОписаниеФайла.ИмяФайла = ТекДанные.Directory;
	
	ДопПараметрыОповещения = New Structure;
	ДопПараметрыОповещения.Insert("ТекущаяСтрока", Items.ConfigurationSourceFilesDirectories.ТекущаяСтрока);
	
	UT_CommonClient.FormFieldFileNameStartChoice(ОписаниеФайла, Элемент, ДанныеВыбора, СтандартнаяОбработка,
		РежимДиалогаВыбораФайла.ВыборКаталога,
		New NotifyDescription("КаталогиИсходныхФайловКонфигурацииКаталогНачалоВыбораЗаверешение", ЭтотОбъект,
		ДопПараметрыОповещения));
EndProcedure

#EndRegion


#Region ОбработчикиКомандФормы
&AtClient
Procedure Apply(Команда)
	If Not ПроверитьЗаполнение() Then
		Return;
	EndIf;
	
	ПрименитьНаСервере();
	Закрыть();
EndProcedure

&AtClient
Procedure СохранитьМодулиКонфигурацииВФайлы(Команда)
	
	ТекущиеКаталоги = New Map;
	For Each ТекСтрока In ConfigurationSourceFilesDirectories Do
		If Not ЗначениеЗаполнено(ТекСтрока.Source) 
			Или Not ЗначениеЗаполнено(ТекСтрока.Каталог) Then
				Continue;
		EndIf;

		ТекущиеКаталоги.Insert(ТекСтрока.Source, ТекСтрока.Каталог);
	EndDo;
	
	UT_CodeEditorClient.СохранитьМодулиКонфигурацииВФайлы(
		New NotifyDescription("СохранитьМодулиКонфигурацииВФайлыЗавершение", ЭтотОбъект), ТекущиеКаталоги);
EndProcedure

#EndRegion

#Region СлужебныеПроцедурыИФункции

&AtClient
Procedure СохранитьМодулиКонфигурацииВФайлыЗавершение(Результат, ДополнительныеПараметры) Экспорт
	If Результат = Undefined Then
		Return;
	EndIf;
	
	For Each ТекКаталог ИЗ Результат Do
		СтруктураПоиска = New Structure;
		СтруктураПоиска.Insert("Source", ТекКаталог.Источник);
		
		НайденныеСтроки = ConfigurationSourceFilesDirectories.НайтиСтроки(СтруктураПоиска);
		If НайденныеСтроки.Количество() = 0 Then
			НС = ConfigurationSourceFilesDirectories.Add();
			НС.Source = ТекКаталог.Source;
		Else
			НС = НайденныеСтроки[0];
		EndIf;
		
		НС.Directory = ТекКаталог.Directory;
	EndDo;
	
	Модифицированность = True;
EndProcedure


&AtClient
Procedure КаталогиИсходныхФайловКонфигурацииКаталогНачалоВыбораЗаверешение(Результат, ДополнительныеПараметры) Экспорт
	If Результат = Undefined Then
		Return;
	EndIf;
	
	If Результат.Количество()=0 Then
		Return;
	EndIf;
	
	ТекДанные = ConfigurationSourceFilesDirectories.НайтиПоИдентификатору(ДополнительныеПараметры.ТекущаяСтрока);
	ТекДанные.Directory = Результат[0];
	
	Модифицированность = True;
EndProcedure

&AtServer
Procedure УстановитьВидимостьЭлементов()
	Варианты = UT_CodeEditorClientServer.ВариантыРедактораКода();
	
	ЭтоМонако = EditorOf1CScript = Варианты.Monaco;
	
	Items.GroupMonacoCodeEditor.Видимость = ЭтоМонако;
EndProcedure

&AtServer
Procedure УстановитьСписокВыбораЭлементаИзСтруктуры(Элемент, СтруктураДанных)
	Элемент.СписокВыбора.Clear();
	For Each КлючЗначение ИЗ СтруктураДанных Do
		Элемент.СписокВыбора.Add(КлючЗначение.Ключ, КлючЗначение.Значение);
	EndDo;		
	
EndProcedure

&AtServer
Procedure ПрименитьНаСервере()
	ПараметрыРедактораКода = UT_CodeEditorClientServer.ПараметрыРедактораКодаПоУмолчанию();
	ПараметрыРедактораКода.FontSize = FontSize;
	ПараметрыРедактораКода.Вариант = EditorOf1CScript;
	
	ПараметрыРедактораКода.Monaco.Тема = MonacoEditorTheme;
	ПараметрыРедактораКода.Monaco.ЯзыкСинтаксиса = MonacoEditorScriptVariant;
	ПараметрыРедактораКода.Monaco.UseScriptMap = UseScriptMap;
	ПараметрыРедактораКода.Monaco.HideLineNumbers = HideLineNumbers;
	ПараметрыРедактораКода.Monaco.LinesHeight = ВысотаСтрок;
	
	For Each ТекСтрока In ConfigurationSourceFilesDirectories Do
		If Not ЗначениеЗаполнено(ТекСтрока.Каталог) Then
			Continue;
		EndIf;
	
		ОписаниеКаталога = UT_CodeEditorClientServer.НовыйОписаниеКаталогаИсходныхФайловКонфигурации();
		ОписаниеКаталога.Source = ТекСтрока.Source;
		ОписаниеКаталога.Directory = ТекСтрока.Directory;
		
		ПараметрыРедактораКода.Monaco.КаталогиИсходныхФайлов.Add(ОписаниеКаталога);
	EndDo;
	
	UT_CodeEditorServer.УстановитьНовыеНастройкиРедактораКода(ПараметрыРедактораКода);
	
EndProcedure
#EndRegion