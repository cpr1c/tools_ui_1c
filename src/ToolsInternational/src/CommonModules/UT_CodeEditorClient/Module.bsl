#Region Public

Procedure FormOnOpen(Form, CompletionNotifyDescription = Undefined) Export
	AdditionalParameters = New Structure;
	AdditionalParameters.Insert("CompletionNotifyDescription", CompletionNotifyDescription);
	AdditionalParameters.Insert("Form", Form);

	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
			New NotifyDescription("FormOnOpenEndAttachFileSystemExtension", ThisObject,
		AdditionalParameters));
EndProcedure

Function ВсеРедакторыФормыИнициализированы(РедакторыФормы)
	Result = True;
	For Each КлючЗначение In РедакторыФормы Do
		If Not КлючЗначение.Value.Initialized Then
			Result = False;
			Break;
		EndIf;
	EndDo;

	Return Result;
EndFunction

Procedure ИнициализироватьРедаторыФормыПослеФормированияПолей(Form, РедакторыФормы, ВидРедактора, ВидыРедактора)
	For Each КлючЗначение In РедакторыФормы Do
		EditorSettings = КлючЗначение.Value;
		ЭлементФормыРедактора = Form.Items[EditorSettings.ПолеРедактора];
		If Not ЭлементФормыРедактора.Visible Then
			Continue;
		EndIf;
			
		If ВидРедактора = ВидыРедактора.Text Then
			If ValueIsFilled(EditorSettings.EditorSettings.FontSize) Then
				ЭлементФормыРедактора.Font = New Font(, EditorSettings.EditorSettings.FontSize);
			EndIf;
		ElsIf ВидРедактора = ВидыРедактора.Ace Then 
			ДокументView = ЭлементФормыРедактора.Document.defaultView;
			If ValueIsFilled(EditorSettings.EditorSettings.FontSize) Then
				ДокументView.editor.setFontSize(EditorSettings.EditorSettings.FontSize);		
			EndIf;
		ElsIf ВидРедактора = ВидыРедактора.Monaco Then
			ДокументView = ЭлементФормыРедактора.Document.defaultView;
			ДокументView.setOption("autoResizeEditorLayout", True);

			Инфо = New SystemInfo;
			ДокументView.init(Инфо.AppVersion);
			ДокументView.hideScrollX();
			ДокументView.hideScrollY();
			ДокументView.showStatusBar();
			ДокументView.enableQuickSuggestions();
			If ValueIsFilled(EditorSettings.EditorSettings.FontSize) Then
				ДокументView.setFontSize(EditorSettings.EditorSettings.FontSize);
			EndIf;
			If ValueIsFilled(EditorSettings.EditorSettings.LinesHeight) Then
				ДокументView.setLineHeight(EditorSettings.EditorSettings.LinesHeight);
			EndIf;

			ДокументView.disableKeyBinding(9);
			ДокументView.setOption("dragAndDrop", True);

			ТемыРедактора = UT_CodeEditorClientServer.ВариантыТемыРедактораMonaco();
			If EditorSettings.EditorSettings.Subject = ТемыРедактора.Темная Then
				ДокументView.setTheme("bsl-dark");
			Else
				ДокументView.setTheme("bsl-white");
			EndIf;

			ЯзыкиРедактора = UT_CodeEditorClientServer.ВариантыЯзыкаСинтаксисаРедактораMonaco();
			If EditorSettings.EditorSettings.ScriptVariant = ЯзыкиРедактора.English Then
				ДокументView.switchLang();
			ElsIf EditorSettings.EditorSettings.ScriptVariant = ЯзыкиРедактора.Auto Then
				ScriptVariant = UT_ApplicationParameters["ConfigurationScriptVariant"];
				If ScriptVariant = "English" Then
					ДокументView.switchLang();
				EndIf;
			EndIf;

			ДокументView.minimap(EditorSettings.EditorSettings.UseScriptMap);

			If EditorSettings.EditorSettings.HideLineNumbers Then
				ДокументView.hideLineNumbers();
			EndIf;

			ДокументView.clearMetadata();

			ОписаниеКонфигурацииДляИнициализации = ОписаниеМетаданныйДляИнициализацииРедактораMonaco();

	//		МетаданныеКонфигурации = ОписаниеМетаданныхКонфигурацииДляРедактораMonaco();
			ДокументView.updateMetadata(UT_CommonClientServer.mWriteJSON(
				ПолучитьСписокОбъектовМетаданныхИзКоллекцииДляРедактораMonaco(
				ОписаниеКонфигурацииДляИнициализации.CommonModules)), "commonModules.items");
		EndIf;
	EndDo;
EndProcedure

Procedure CodeEditorDeferredInitializingEditors(Form) Export
	ВидРедактора = Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора()];
	ВидыРедактора = UT_CodeEditorClientServer.CodeEditorVariants();
	РедакторыФормы = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];

	ИнициализироватьРедаторыФормыПослеФормированияПолей(Form, РедакторыФормы, ВидРедактора, ВидыРедактора);
	Form.Attachable_CodeEditorInitializingCompletion();
//	Форма.Attachable_CodeEditorInitializingCompletion(УИ_РедакторКодаКлиентСервер.ИдентификаторРедактораПоЭлементуФормы(Форма, Элемент));
EndProcedure

Procedure HTMLEditorFieldDocumentGenerated(Form, Item) Export
	ИдентификаторРедактора = UT_CodeEditorClientServer.ИдентификаторРедактораПоЭлементуФормы(Form, Item);
	РедакторыФормы = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];

	EditorSettings = РедакторыФормы[ИдентификаторРедактора];
	EditorSettings.Insert("Initialized", True);

	If Not ВсеРедакторыФормыИнициализированы(РедакторыФормы) Then
		Return;
	EndIf;
	Form.AttachIdleHandler("Attached_CodeEditorDeferredInitializingEditors", 0.1, True);
EndProcedure

Procedure HTMLEditorFieldOnClick(Form, Item, ДанныеСобытия, СтандартнаяОбработка) Export
	ВидРедактора = Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора()];
	ВидыРедактора = UT_CodeEditorClientServer.CodeEditorVariants();

	If ВидРедактора = ВидыРедактора.Monaco Then
		ПолеРедактораHTMLПриНажатииMonaco(Form, Item, ДанныеСобытия, СтандартнаяОбработка);
	EndIf;
EndProcedure

Procedure УстановитьТекстРедактораЭлементаФормы(Form, Item, Text) Export
	ИдентификаторРедактора = UT_CodeEditorClientServer.ИдентификаторРедактораПоЭлементуФормы(Form, Item);
	If ИдентификаторРедактора = Undefined Then
		Return;
	EndIf;

	SetEditorText(Form, ИдентификаторРедактора, Text);
EndProcedure

Procedure SetEditorText(Form, ИдентификаторРедактора, Text) Export
	ВидыРедакторов = UT_CodeEditorClientServer.CodeEditorVariants();
	ВидРедактора = Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора()];

	РедакторыФормы = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not ВсеРедакторыФормыИнициализированы(РедакторыФормы) Then
		Return;
	EndIf;

	EditorSettings = РедакторыФормы[ИдентификаторРедактора];
	If ВидРедактора = ВидыРедакторов.Text Then
		Form[EditorSettings.ИмяРеквизита] = Text;
	ElsIf ВидРедактора = ВидыРедакторов.Ace Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;
		HTMLDocument.editor.setValue(Text, -1);
	ElsIf ВидРедактора = ВидыРедакторов.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;
		HTMLDocument.updateText(Text);
	EndIf;
EndProcedure

Function EditorCodeText(Form, ИдентификаторРедактора) Export
	ВидыРедакторов = UT_CodeEditorClientServer.CodeEditorVariants();
	ВидРедактора = Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора()];

	РедакторыФормы = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not ВсеРедакторыФормыИнициализированы(РедакторыФормы) Then
		Return "";
	EndIf;
	EditorSettings = РедакторыФормы[ИдентификаторРедактора];

	ТекстКода="";

	If ВидРедактора = ВидыРедакторов.Text Then
		ТекстКода = Form[EditorSettings.ИмяРеквизита];
	ElsIf ВидРедактора = ВидыРедакторов.Ace Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;
		ТекстКода = HTMLDocument.editor.getValue();
	ElsIf ВидРедактора = ВидыРедакторов.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;
		ТекстКода = HTMLDocument.getText();
	EndIf;

	Return TrimAll(ТекстКода);
EndFunction

Function ТекстКодаРедактораЭлементаФормы(Form, Item) Export
	ИдентификаторРедактора = UT_CodeEditorClientServer.ИдентификаторРедактораПоЭлементуФормы(Form, Item);
	If ИдентификаторРедактора = Undefined Then
		Return "";
	EndIf;

	Return EditorCodeText(Form, ИдентификаторРедактора);
EndFunction

Function EditorSelectionBounds(Form, ИдентификаторРедактора) Export
	ВидыРедакторов = UT_CodeEditorClientServer.CodeEditorVariants();
	ВидРедактора = Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора()];

	РедакторыФормы = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not ВсеРедакторыФормыИнициализированы(РедакторыФормы) Then
		Return НовыйГраницыВыделения();
	EndIf;

	EditorSettings = РедакторыФормы[ИдентификаторРедактора];

	ГраницыВыделения = НовыйГраницыВыделения();

	If ВидРедактора = ВидыРедакторов.Text Then
		ЭлементРедактора = Form.Items[EditorSettings.ПолеРедактора];
			
		ЭлементРедактора.GetTextSelectionBounds(ГраницыВыделения.НачалоСтроки, ГраницыВыделения.НачалоКолонки,
			ГраницыВыделения.КонецСтроки, ГраницыВыделения.КонецКолонки);		
	ElsIf ВидРедактора = ВидыРедакторов.Ace Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;
		ВыделеннаяОбласть = HTMLDocument.editor.getSelectionRange();
		
		ГраницыВыделения.НачалоСтроки = ВыделеннаяОбласть.start.row;
		ГраницыВыделения.НачалоКолонки = ВыделеннаяОбласть.start.column;
		ГраницыВыделения.КонецСтроки = ВыделеннаяОбласть.end.row;
		ГраницыВыделения.КонецКолонки = ВыделеннаяОбласть.end.column;
	ElsIf ВидРедактора = ВидыРедакторов.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;
		
		Select = HTMLDocument.getSelection();
		ГраницыВыделения.НачалоСтроки = Select.startLineNumber;
		ГраницыВыделения.НачалоКолонки = Select.startColumn;
		ГраницыВыделения.КонецСтроки = Select.endLineNumber;
		ГраницыВыделения.КонецКолонки = Select.endColumn;
	EndIf;

	Return ГраницыВыделения;
	
EndFunction

Function ГраницыВыделенияРедактораЭлементаФормы(Form, Item) Export
	ИдентификаторРедактора = UT_CodeEditorClientServer.ИдентификаторРедактораПоЭлементуФормы(Form, Item);
	If ИдентификаторРедактора = Undefined Then
		Return НовыйГраницыВыделения();
	EndIf;
	
	Return EditorSelectionBounds(Form, ИдентификаторРедактора);	
EndFunction

Procedure SetTextSelectionBounds(Form, ИдентификаторРедактора, НачалоСтроки, НачалоКолонки, КонецСтроки,
	КонецКолонки) Export

	ВидыРедакторов = UT_CodeEditorClientServer.CodeEditorVariants();
	ВидРедактора = Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора()];

	РедакторыФормы = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not ВсеРедакторыФормыИнициализированы(РедакторыФормы) Then
		Return;
	EndIf;
	
	EditorSettings = РедакторыФормы[ИдентификаторРедактора];

	If ВидРедактора = ВидыРедакторов.Text Then
		ЭлементРедактора = Form.Items[EditorSettings.ПолеРедактора];
			
		ЭлементРедактора.SetTextSelectionBounds(НачалоСтроки, НачалоКолонки, КонецСтроки, КонецКолонки);		
	ElsIf ВидРедактора = ВидыРедакторов.Ace Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;
		HTMLDocument.setSelection(НачалоСтроки, НачалоКолонки, КонецСтроки, КонецКолонки);
	ElsIf ВидРедактора = ВидыРедакторов.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;
		HTMLDocument.setSelection(НачалоСтроки, НачалоКолонки, КонецСтроки, КонецКолонки);
	EndIf;

EndProcedure

Procedure УстановитьГраницыВыделенияЭлементаФормы(Form, Item, НачалоСтроки, НачалоКолонки, КонецСтроки,
	КонецКолонки) Export

	ИдентификаторРедактора = UT_CodeEditorClientServer.ИдентификаторРедактораПоЭлементуФормы(Form, Item);
	If ИдентификаторРедактора = Undefined Then
		Return;
	EndIf;

	SetTextSelectionBounds(Form, ИдентификаторРедактора, НачалоСтроки, НачалоКолонки, КонецСтроки, КонецКолонки);

EndProcedure

Procedure InsertTextInCursorLocation(Form, ИдентификаторРедактора, Text) Export
	ВидыРедакторов = UT_CodeEditorClientServer.CodeEditorVariants();
	ВидРедактора = Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора()];

	РедакторыФормы = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not ВсеРедакторыФормыИнициализированы(РедакторыФормы) Then
		Return;
	EndIf;
	
	EditorSettings = РедакторыФормы[ИдентификаторРедактора];

	If ВидРедактора = ВидыРедакторов.Text Then
		ЭлементРедактора = Form.Items[EditorSettings.ПолеРедактора];
		ЭлементРедактора.SelectedText = Text;	
	ElsIf ВидРедактора = ВидыРедакторов.Ace Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;
		HTMLDocument.editor.insert(Text);
	ElsIf ВидРедактора = ВидыРедакторов.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;
		HTMLDocument.selectedText(Text);
	EndIf;
EndProcedure

Procedure ВставитьТекстПоПозицииКурсораЭлементаФормы(Form, Item, Text) Export
	ИдентификаторРедактора = UT_CodeEditorClientServer.ИдентификаторРедактораПоЭлементуФормы(Form, Item);
	If ИдентификаторРедактора = Undefined Then
		Return;
	EndIf;

	InsertTextInCursorLocation(Form, ИдентификаторРедактора, Text);
	
EndProcedure

Procedure AddCodeEditorContext(Form, ИдентификаторРедактора, ДобавляемыйКонтекст) Export
	ВидыРедакторов = UT_CodeEditorClientServer.CodeEditorVariants();
	ВидРедактора = Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора()];

	РедакторыФормы = Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	If Not ВсеРедакторыФормыИнициализированы(РедакторыФормы) Then
		Return;
	EndIf;
	
	EditorSettings = РедакторыФормы[ИдентификаторРедактора];

	If ВидРедактора = ВидыРедакторов.Monaco Then
		HTMLDocument=Form.Items[EditorSettings.ПолеРедактора].Document.defaultView;

		СоответствиеТипов = СоответствиеСсылочныхТиповКонфигурации();

		ОбъектыДобавления = New Structure;

		For Each КлючЗначение In ДобавляемыйКонтекст Do
			ОбъектДобавляемый = New Structure("ref");
			If TypeOf(КлючЗначение.Value) = Type("Structure") Then
				TypeName = КлючЗначение.Value.Type;
			
				ОбъектДобавляемый.Insert("properties", New Structure);

				For Each Property In КлючЗначение.Value.ПодчиненныеСвойства Do
					ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОбъектДобавляемый.properties, Property, True,
						СоответствиеТипов);
				EndDo;
				
			Else
				TypeName = КлючЗначение.Value;
			EndIf;
			ОбъектДобавляемый.ref = ТипРедактораМонакоПоСтрокеТипа1С(TypeName, СоответствиеТипов);
			ОбъектыДобавления.Insert(КлючЗначение.Key, ОбъектДобавляемый);
		EndDo;

		HTMLDocument.updateMetadata(UT_CommonClientServer.mWriteJSON(New Structure("customObjects",
			ОбъектыДобавления)));
	EndIf;
EndProcedure

Procedure ОткрытьКонструкторЗапроса(QueryText, CompletionNotifyDescription, РежимКомпоновки = False) Export
#If Not MobileClient Then
	Конструктор=New QueryWizard;
	If UT_CommonClientServer.PlatformVersionNotLess_8_3_14() Then
		Конструктор.DataCompositionMode=РежимКомпоновки;
	EndIf;

	If ValueIsFilled(TrimAll(QueryText)) Then
		Конструктор.Text=QueryText;
	EndIf;

	Конструктор.Show(CompletionNotifyDescription);
#EndIf
EndProcedure

Procedure ОткрытьКонструкторФорматнойСтроки(ФорматнаяСтрока, CompletionNotifyDescription) Export
	Конструктор = New FormatStringWizard;
	Try
		Конструктор.Text = ФорматнаяСтрока;
	Except
		Инфо = ErrorInfo();
		ShowMessageBox( , "Error в тексте форматной строки:" + Chars.LF + Инфо.Reason.Description);
		Return;
	EndTry;
	Конструктор.Show(CompletionNotifyDescription);
EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлы(CompletionNotifyDescription, ТекущиеКаталоги) Export
	ДопПараметрыОповещения = New Structure;
	ДопПараметрыОповещения.Insert("CompletionNotifyDescription", CompletionNotifyDescription);
	ДопПараметрыОповещения.Insert("ТекущиеКаталоги", ТекущиеКаталоги);

	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("СохранитьМодулиКонфигурацииВФайлыЗавершениеПодключенияРасширенияРаботыСФайлами",
		ThisObject, ДопПараметрыОповещения));

EndProcedure

#EndRegion

#Region Internal

Procedure FormOnOpenEndAttachFileSystemExtension(Result, AdditionalParameters) Export
	АдресБиблиотеки =  AdditionalParameters.Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаАдресБиблиотеки()];
	If АдресБиблиотеки = Undefined Or Not ValueIsFilled(АдресБиблиотеки) Then
		ФормаПриОткрытииЗавершениеСохраненияБиблиотекиРедактора(True, AdditionalParameters);
	Else
		ВидРедактора = AdditionalParameters.Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора()];

		СохранитьБиблиотекуРедактораНаДиск(АдресБиблиотеки, ВидРедактора,
			New NotifyDescription("ФормаПриОткрытииЗавершениеСохраненияБиблиотекиРедактора", ThisObject,
			AdditionalParameters));
	EndIf;
EndProcedure

Procedure ФормаПриОткрытииЗавершениеСохраненияБиблиотекиРедактора(Result, AdditionalParameters) Export
	Form = AdditionalParameters.Form;
	ВидРедактора = Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаВидРедактора()];
	ВидыРедакторов = UT_CodeEditorClientServer.CodeEditorVariants();

	If UT_CodeEditorClientServer.РедакторКодаИспользуетПолеHTML(ВидРедактора) Then
		For Each КлючЗначение In Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()] Do
			//ИмяРеквизитаРедактора = УИ_РедакторКодаКлиентСервер.ИмяРеквизитаРедактораКода(КлючЗначение.Value.ИмяРеквизита);	

			If ВидРедактора = ВидыРедакторов.Monaco Then
				Form[КлючЗначение.Value.ИмяРеквизита] = КаталогСохраненияРедактора(ВидРедактора)
					+ GetPathSeparator() + "index.html";
			ElsIf ВидРедактора = ВидыРедакторов.Ace Then
				Form[КлючЗначение.Value.ИмяРеквизита] = ИмяФайлаРедактораAceДляЯзыка(КлючЗначение.Value.Lang);
			EndIf;
		EndDo;
	Else
		CodeEditorDeferredInitializingEditors(Form);
	EndIf;
	
	// Оповестим о завершении обработки инициализации редакторов при открытии формы
	CompletionNotifyDescription= AdditionalParameters.CompletionNotifyDescription;
	If CompletionNotifyDescription = Undefined Then
		Return;
	EndIf;

	ExecuteNotifyProcessing(CompletionNotifyDescription, True);
EndProcedure

Procedure СохранитьБиблиотекуРедактораНаДискЗавершениеСозданияКаталогаБиблиотеки(ИмяКаталога, AdditionalParameters) Export

	АдресБиблиотеки = AdditionalParameters.АдресБиблиотеки;
	КаталогСохраненияБибилиотеки = AdditionalParameters.КаталогСохраненияБибилиотеки;

	МассивСохраненныхФайлов = New Array;
	СоответствиеФайловБиблиотеки=GetFromTempStorage(АдресБиблиотеки);

	If AdditionalParameters.ВидРедактора = "Ace" Then
		ДобавитьКСохранениюТекстовыйДокументДляЯзыкаРедактораКодаAce(СоответствиеФайловБиблиотеки,
			КаталогСохраненияБибилиотеки, "bsl");
		ДобавитьКСохранениюТекстовыйДокументДляЯзыкаРедактораКодаAce(СоответствиеФайловБиблиотеки,
			КаталогСохраненияБибилиотеки, "css");
		ДобавитьКСохранениюТекстовыйДокументДляЯзыкаРедактораКодаAce(СоответствиеФайловБиблиотеки,
			КаталогСохраненияБибилиотеки, "javascript");
		ДобавитьКСохранениюТекстовыйДокументДляЯзыкаРедактораКодаAce(СоответствиеФайловБиблиотеки,
			КаталогСохраненияБибилиотеки, "html");
	EndIf;

	AdditionalParameters.Insert("МассивСохраненныхФайлов", МассивСохраненныхФайлов);
	AdditionalParameters.Insert("СоответствиеФайловБиблиотеки", СоответствиеФайловБиблиотеки);

	СохранитьБиблиотекуРедактораЗаписатьНачатьЗаписьОчередногоФайла(AdditionalParameters);
EndProcedure

Procedure СохранитьБиблиотекуРедактораРаспаковатьБиблиотекуРедактораВКаталог(AdditionalParameters,
	ОписаниеОповещенияОЗаверешнии) Export
#If Not WebClient And Not MobileClient Then
	Stream=AdditionalParameters.СоответствиеФайловБиблиотеки[AdditionalParameters.ТекКлючФайла].OpenStreamForRead();

	ЧтениеZIP=New ZipFileReader(Stream);
	ЧтениеZIP.ExtractAll(AdditionalParameters.КаталогСохраненияБибилиотеки,
		ZIPRestoreFilePathsMode.Restore);

#EndIf

EndProcedure

Procedure СохранитьБиблиотекуРедактораРаспаковатьБиблиотекуРедактораВКаталогЗавершение(Result,
	AdditionalParameters) Export

EndProcedure

Procedure СохранитьБиблиотекуРедактораЗаписатьНачатьЗаписьОчередногоФайлаЗавершение(AdditionalParameters) Export
	МассивСохраненныхФайлов = AdditionalParameters.МассивСохраненныхФайлов;
	МассивСохраненныхФайлов.Add(AdditionalParameters.ТекКлючФайла);

	File = New File(AdditionalParameters.ТекКлючФайла);

	If File.Extension = ".zip" Then
		СохранитьБиблиотекуРедактораРаспаковатьБиблиотекуРедактораВКаталог(AdditionalParameters,
			New NotifyDescription("СохранитьБиблиотекуРедактораРаспаковатьБиблиотекуРедактораВКаталогЗавершение",
			ThisObject, AdditionalParameters));
	EndIf;	
		//Else
	СохранитьБиблиотекуРедактораЗаписатьНачатьЗаписьОчередногоФайла(AdditionalParameters);
	//EndIf;
EndProcedure

Procedure СохранитьБиблиотекуРедактораЗаписатьНачатьЗаписьОчередногоФайлаТекстовогоДокументаЗавершение(Result,
	AdditionalParameters) Export
	МассивСохраненныхФайлов = AdditionalParameters.МассивСохраненныхФайлов;
	МассивСохраненныхФайлов.Add(AdditionalParameters.ТекКлючФайла);

	СохранитьБиблиотекуРедактораЗаписатьНачатьЗаписьОчередногоФайла(AdditionalParameters);
EndProcedure

Procedure СохранитьБиблиотекуРедактораНаДискЗавершениеПроверкиСуществованияБиблиотекиНаДиске(Exists,
	AdditionalParameters) Export
	If Exists Then
		ExecuteNotifyProcessing(AdditionalParameters.CompletionNotifyDescription);
		Return;
	EndIf;

	КаталогСохраненияБибилиотеки = AdditionalParameters.КаталогСохраненияБибилиотеки;

	BeginCreatingDirectory(
		New NotifyDescription("СохранитьБиблиотекуРедактораНаДискЗавершениеСозданияКаталогаБиблиотеки", ThisObject,
		AdditionalParameters), КаталогСохраненияБибилиотеки);

EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлыЗавершениеПодключенияРасширенияРаботыСФайлами(Result,
	AdditionalParameters) Export
	ПараметрыФормы = New Structure;
	ПараметрыФормы.Insert("CurrentDirectories", AdditionalParameters.ТекущиеКаталоги);

	ДополнительныеПараметрыОповещения = New Structure;
	ДополнительныеПараметрыОповещения.Insert("CompletionNotifyDescription",
		AdditionalParameters.CompletionNotifyDescription);

	OpenForm("ОбщаяФорма.UT_ConfigurationSourseFilesSaveSettings", ПараметрыФормы, , , , ,
		New NotifyDescription("СохранитьМодулиКонфигурацииВФайлыЗавершениеНастроек", ThisObject,
		ДополнительныеПараметрыОповещения), FormWindowOpeningMode.Independent);

EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлыЗавершениеНастроек(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	ОписаниеМетаданныхКонфигурации = UT_CodeEditorServerCall.ОписаниеМетаданныхКонфигурации(False);

	ПараметрыСохраненияИсходныхФайлов = New Structure;
	ПараметрыСохраненияИсходныхФайлов.Insert("ОписаниеМетаданныхКонфигурации", ОписаниеМетаданныхКонфигурации);
	ПараметрыСохраненияИсходныхФайлов.Insert("Parameters", Result);
	ПараметрыСохраненияИсходныхФайлов.Insert("AdditionalParameters", AdditionalParameters);
	ПараметрыСохраненияИсходныхФайлов.Insert("ИндексКаталога", 0);

	СохранитьМодулиКонфигурацииВФайлыНачалоОбработкиКаталогаИсточника(ПараметрыСохраненияИсходныхФайлов);

EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлыНачалоОбработкиКаталогаИсточника(ПараметрыСохранения)
	If ПараметрыСохранения.ИндексКаталога >= ПараметрыСохранения.Parameters.КаталогиИсточников.Count() Then
		СохранитьМодулиКонфигурацииВФайлыЗавершение(ПараметрыСохранения);
		Return;
	EndIf;

	ОписаниеКаталогаИсточника = ПараметрыСохранения.Parameters.КаталогиИсточников[ПараметрыСохранения.ИндексКаталога];

	ПараметрыСохранения.Insert("ОписаниеКаталогаИсточника", ОписаниеКаталогаИсточника);
	
	//Сначала нужно очистить каталог
	BeginDeletingFiles(New NotifyDescription("СохранитьМодулиКонфигурацииВФайлыЗавершениеУдалениеФайловКаталога",
		ThisObject, ПараметрыСохранения), ОписаниеКаталогаИсточника.Directory, "*");

EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлыЗавершениеУдалениеФайловКаталога(ПараметрыСохранения) Export
	If ПараметрыСохранения.ОписаниеКаталогаИсточника.ТолькоМодули Then
		СохранитьМодулиКонфигурацииВФайлыСохранитьСписокМетаданныхСМодулями(ПараметрыСохранения);
	Else
		СохранитьМодулиКонфигурацииВФайлыЗАпуститьКонфигуратовДляВыгрузкиМетаданных(ПараметрыСохранения);
	EndIf;
EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлыСохранитьСписокМетаданныхСМодулями(ПараметрыСохранения) Export
	ТекстМетаданных = New TextDocument;

	If ПараметрыСохранения.ОписаниеКаталогаИсточника.Src <> "MainConfiguration" Then
		ИмяРасширения = ПараметрыСохранения.ОписаниеКаталогаИсточника.Src;
	Else
		ИмяРасширения = Undefined;
	EndIf;
	
	For Each ТекКоллекция In ПараметрыСохранения.ОписаниеМетаданныхКонфигурации Do
		If TypeOf(ТекКоллекция.Value)<> Type("Structure") Then
			Continue;
		EndIf;
		
		If ТекКоллекция.Key = "Catalogs" Then
			ИмяКоллекцииДляФайла = "Catalog";
		ElsIf ТекКоллекция.Key = "Documents" Then
			ИмяКоллекцииДляФайла = "Document";
		ElsIf ТекКоллекция.Key = "InformationRegisters" Then
			ИмяКоллекцииДляФайла = "InformationRegister";
		ElsIf ТекКоллекция.Key = "AccumulationRegisters" Then
			ИмяКоллекцииДляФайла = "AccumulationRegister";
		ElsIf ТекКоллекция.Key = "AccountingRegisters" Then
			ИмяКоллекцииДляФайла = "AccountingRegister";
		ElsIf ТекКоллекция.Key = "CalculationRegisters" Then
			ИмяКоллекцииДляФайла = "CalculationRegister";
		ElsIf ТекКоллекция.Key = "DataProcessors" Then
			ИмяКоллекцииДляФайла = "DataProcessor";
		ElsIf ТекКоллекция.Key = "Reports" Then
			ИмяКоллекцииДляФайла = "Report";
		ElsIf ТекКоллекция.Key = "Enums" Then
			ИмяКоллекцииДляФайла = "Enum";
		ElsIf ТекКоллекция.Key = "CommonModules" Then
			ИмяКоллекцииДляФайла = "CommonModule";
		ElsIf ТекКоллекция.Key = "ChartsOfAccounts" Then
			ИмяКоллекцииДляФайла = "ChartOfAccounts";
		ElsIf ТекКоллекция.Key = "BusinessProcesses" Then
			ИмяКоллекцииДляФайла = "BusinessProcess";
		ElsIf ТекКоллекция.Key = "Tasks" Then
			ИмяКоллекцииДляФайла = "Task";
		ElsIf ТекКоллекция.Key = "ExchangePlans" Then
			ИмяКоллекцииДляФайла = "ExchangePlan";
		ElsIf ТекКоллекция.Key = "ChartsOfCharacteristicTypes" Then
			ИмяКоллекцииДляФайла = "ChartOfCharacteristicTypes";
		ElsIf ТекКоллекция.Key = "ChartsOfCalculationTypes" Then
			ИмяКоллекцииДляФайла = "ChartOfCalculationTypes";
		ElsIf ТекКоллекция.Key = "Constants" Then
			ИмяКоллекцииДляФайла = "Constant";
		Else
			Continue;
		EndIf;
		
		For Each КлючЗначениеМетаданных In ТекКоллекция.Value Do
			If КлючЗначениеМетаданных.Value.Extension<>ИмяРасширения Then
				Continue;
			EndIf;
			ТекстМетаданных.AddRow(ИмяКоллекцииДляФайла+"."+КлючЗначениеМетаданных.Key);
		EndDo;
	EndDo;
	
	SessionFileVariablesStructure = UT_CommonClient.SessionFileVariablesStructure();
	ИмяФайлаСохранения = SessionFileVariablesStructure.TempFilesDirectory + GetPathSeparator() + "tools_ui_1c_list_metadata.txt";
	ПараметрыСохранения.Insert("ИмяФайлаСпискаМетаданных", ИмяФайлаСохранения);
	ТекстМетаданных.BeginWriting(
		New NotifyDescription("СохранитьМодулиКонфигурацииВФайлыСохранитьСписокМетаданныхСМодулямиЗавершение",
		ThisObject, ПараметрыСохранения), ИмяФайлаСохранения);

EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлыСохранитьСписокМетаданныхСМодулямиЗавершение(Result, ПараметрыСохранения) Export
	If Result<>True Then
		Message("Not удалось сохранить список метаданных с модулями в файл для источника "
			+ ПараметрыСохранения.ОписаниеКаталогаИсточника.Src);

		ПараметрыСохранения.ИндексКаталога = ПараметрыСохранения.ИндексКаталога + 1;
		СохранитьМодулиКонфигурацииВФайлыНачалоОбработкиКаталогаИсточника(ПараметрыСохранения);
		Return;
	EndIf;	
	
	СохранитьМодулиКонфигурацииВФайлыЗАпуститьКонфигуратовДляВыгрузкиМетаданных(ПараметрыСохранения);

EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлыЗАпуститьКонфигуратовДляВыгрузкиМетаданных(ПараметрыСохранения) Export
	СтрокаЗапускаПриложения = UT_StringFunctionsClientServer.WrapInOuotationMarks(
		ПараметрыСохранения.Parameters.ФайлЗапускаПлатформы) + " DESIGNER";

	If ПараметрыСохранения.Parameters.РасположениеБазы = 0 Then
		СтрокаЗапускаПриложения = СтрокаЗапускаПриложения + " /F " + UT_StringFunctionsClientServer.WrapInOuotationMarks(
			ПараметрыСохранения.Parameters.КаталогИнформационнойБазы);
	Else
		ПутьКБазе = ПараметрыСохранения.Parameters.СерверИБ + "\" + ПараметрыСохранения.Parameters.ИмяБазы;
		СтрокаЗапускаПриложения = СтрокаЗапускаПриложения + " /S " + UT_StringFunctionsClientServer.WrapInOuotationMarks(
			ПутьКБазе);
	EndIf;
	СтрокаЗапускаПриложения = СтрокаЗапускаПриложения + " /N" + UT_StringFunctionsClientServer.WrapInOuotationMarks(
		ПараметрыСохранения.Parameters.User);

	If ValueIsFilled(ПараметрыСохранения.Parameters.Password) Then
		СтрокаЗапускаПриложения = СтрокаЗапускаПриложения + " /P" + UT_StringFunctionsClientServer.WrapInOuotationMarks(
			ПараметрыСохранения.Parameters.Password);
	EndIf;
	СтрокаЗапускаПриложения = СтрокаЗапускаПриложения +" /DisableStartupMessages /DisableStartupDialogs";

	СтрокаЗапускаПриложения = СтрокаЗапускаПриложения + " /DumpConfigToFiles "
		+ UT_StringFunctionsClientServer.WrapInOuotationMarks(ПараметрыСохранения.ОписаниеКаталогаИсточника.Directory)
		+ " -format Hierarchical";
		
	If ПараметрыСохранения.ОписаниеКаталогаИсточника.Src <> "MainConfiguration" Then
		СтрокаЗапускаПриложения = СтрокаЗапускаПриложения + " -Extension "
			+ ПараметрыСохранения.ОписаниеКаталогаИсточника.Src;
	EndIf;
	If ПараметрыСохранения.ОписаниеКаталогаИсточника.ТолькоМодули Then
		СтрокаЗапускаПриложения = СтрокаЗапускаПриложения + " -listFile "
			+ UT_StringFunctionsClientServer.WrapInOuotationMarks(ПараметрыСохранения.ИмяФайлаСпискаМетаданных);

	EndIf;
	SessionFileVariablesStructure = UT_CommonClient.SessionFileVariablesStructure();
	
	ПараметрыСохранения.Insert("ИмяФайлаЛогаЗапускаКонфигуратора",
		SessionFileVariablesStructure.TempFilesDirectory + GetPathSeparator()
		+ "tools_ui_1c_list_metadata_out.txt");

	СтрокаЗапускаПриложения = СтрокаЗапускаПриложения + " /Out " + UT_StringFunctionsClientServer.WrapInOuotationMarks(
		ПараметрыСохранения.ИмяФайлаЛогаЗапускаКонфигуратора);

	BeginRunningApplication(
		New NotifyDescription("СохранитьМодулиКонфигурацииВФайлыЗавершениеВыгрузкиИсходниковМетаданныхВКаталог",
		ThisObject, ПараметрыСохранения), СтрокаЗапускаПриложения, , True);
EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлыЗавершениеВыгрузкиИсходниковМетаданныхВКаталог(КодЗавершения,
	ПараметрыСохранения) Export
	If КодЗавершения <> 0 Then
		TextDocument = New TextDocument;

		ДополнительныеПараметрыОповещения = New Structure;
		ДополнительныеПараметрыОповещения.Insert("TextDocument", TextDocument);
		ДополнительныеПараметрыОповещения.Insert("ПараметрыСохранения", ПараметрыСохранения);

		TextDocument.BeginReading(
			New NotifyDescription("СохранитьМодулиКонфигурацииВФайлыЗавершениеВыгрузкиИсходниковМетаданныхВКаталогЗавершениеЧтенияЛога",
			ThisObject, ДополнительныеПараметрыОповещения), ПараметрыСохранения.ИмяФайлаЛогаЗапускаКонфигуратора);
		Return;
	EndIf;
	ПараметрыСохранения.ИндексКаталога = ПараметрыСохранения.ИндексКаталога + 1;
	СохранитьМодулиКонфигурацииВФайлыНачалоОбработкиКаталогаИсточника(ПараметрыСохранения);
EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлыЗавершениеВыгрузкиИсходниковМетаданныхВКаталогЗавершениеЧтенияЛога(AdditionalParameters) Export
	ПараметрыСохранения = AdditionalParameters.ПараметрыСохранения;
	TextDocument = AdditionalParameters.TextDocument;
	Message("Not удалось сохранить исходные файлы для источника "
		+ ПараметрыСохранения.ОписаниеКаталогаИсточника.Src + ":" + Chars.LF + TextDocument.GetText());
		
	ПараметрыСохранения.ИндексКаталога = ПараметрыСохранения.ИндексКаталога + 1;
	СохранитьМодулиКонфигурацииВФайлыНачалоОбработкиКаталогаИсточника(ПараметрыСохранения);

EndProcedure

Procedure СохранитьМодулиКонфигурацииВФайлыЗавершение(ПараметрыСохранения)
	ExecuteNotifyProcessing(ПараметрыСохранения.AdditionalParameters.CompletionNotifyDescription,
		ПараметрыСохранения.Parameters.КаталогиИсточников);
EndProcedure

#Region Monaco

Procedure ПриЗавершенииРедактированияФорматнойСтрокиMonaco(Text, AdditionalParameters) Export
	If Text = Undefined Then
		Return;
	EndIf;

	ФорматнаяСтрока = StrReplace(Text, "'", "");
	ФорматнаяСтрока = """" + ФорматнаяСтрока + """";

	ДокументView = AdditionalParameters.Form.Items[AdditionalParameters.Item.Name].Document.defaultView;

	If AdditionalParameters.Property("Позиция") Then
		УстановитьТекстMonaco(ДокументView, ФорматнаяСтрока, UT_CommonClientServer.mWriteJSON(
			AdditionalParameters.Позиция), True);
	Else
		УстановитьТекстMonaco(ДокументView, ФорматнаяСтрока, , True);
	EndIf;
EndProcedure

Procedure ПриЗавершенииРедактированияЗапросаMonaco(Text, AdditionalParameters) Export
	If Text = Undefined Then
		Return;
	EndIf;

	QueryText = StrReplace(Text, Chars.LF, Chars.LF + "|");
	QueryText = StrReplace(QueryText, """", """""");
	QueryText = """" + QueryText + """";

	ДокументView = AdditionalParameters.Form.Items[AdditionalParameters.Item.Name].Document.defaultView;

	If AdditionalParameters.Property("Позиция") Then
		УстановитьТекстMonaco(ДокументView, QueryText, UT_CommonClientServer.mWriteJSON(
			AdditionalParameters.Позиция), True);
	Else
		УстановитьТекстMonaco(ДокументView, QueryText, , True);
	EndIf;
EndProcedure

Procedure ОткрытьКонструкторЗапросаMonacoЗавершениеВопроса(Result, AdditionalParameters) Export
	If Result <> DialogReturnCode.Yes Then
		Return;
	EndIf;
	ОткрытьКонструкторЗапроса("", New NotifyDescription("ПриЗавершенииРедактированияЗапросаMonaco", ThisObject,
		AdditionalParameters));

EndProcedure

Procedure ОткрытьКонструкторФорматнойСтрокиMonacoЗавершениеВопроса(Result, AdditionalParameters) Export
	If Result <> DialogReturnCode.Yes Then
		Return;
	EndIf;
	ОткрытьКонструкторФорматнойСтроки("", New NotifyDescription("ПриЗавершенииРедактированияФорматнойСтрокиMonaco",
		ThisObject, AdditionalParameters));

EndProcedure
#EndRegion
#EndRegion

#Region Private

Function ПодготовитьТекстЗапросаДляКонструктора(Text)

	QueryText = StrReplace(Text, "|", "");
	QueryText = StrReplace(QueryText, """""", "$");
	QueryText = StrReplace(QueryText, """", "");
	QueryText = StrReplace(QueryText, "$", """");

	Return QueryText;
EndFunction

Function НовыйГраницыВыделения()
	Границы = New Structure;
	Границы.Insert("НачалоСтроки", 1);
	Границы.Insert("НачалоКолонки", 1);
	Границы.Insert("КонецСтроки", 1);
	Границы.Insert("КонецКолонки", 1);
	
	Return Границы;
EndFunction

#Region Monaco

Function ОписаниеМетаданныйДляИнициализацииРедактораMonaco()
	Description = UT_ApplicationParameters["ОписаниеМетаданныйДляИнициализацииРедактораMonaco"];
	If Description <> Undefined Then
		Return Description;
	EndIf;

	ОписаниеКонфигурацииДляИнициализации = UT_CodeEditorServerCall.ОписнаиеМетаданныйДляИнициализацииРедактораMonaco();
	UT_ApplicationParameters.Insert("ОписаниеМетаданныйДляИнициализацииРедактораMonaco",
		ОписаниеКонфигурацииДляИнициализации);

	Return ОписаниеКонфигурацииДляИнициализации;

EndFunction

Procedure УстановитьТекстMonaco(ДокументView, Text, Позиция = Undefined, УчитыватьОтступПервойСтроки = True)
	ДокументView.setText(Text, Позиция);
EndProcedure

Procedure ОткрытьКонструкторФорматнойСтрокиMonaco(ПараметрыСобытия, AdditionalParameters)
	If ПараметрыСобытия = Undefined Then
		UT_CommonClient.ShowQuestionToUser(
			New NotifyDescription("ОткрытьКонструкторФорматнойСтрокиMonacoЗавершениеВопроса", ThisObject,
			AdditionalParameters), "Форматная строка не найдена." + Chars.LF + "Create новую форматную строку?",
			QuestionDialogMode.YesNo);
	Else
		ФорматнаяСтрока = StrReplace(StrReplace(ПараметрыСобытия.text, "|", ""), """", "");

		ПараметрыОповещения = AdditionalParameters;

		Позиция = New Structure;
		Позиция.Insert("startLineNumber", ПараметрыСобытия.range.startLineNumber);
		Позиция.Insert("startColumn", ПараметрыСобытия.range.startColumn);
		Позиция.Insert("endLineNumber", ПараметрыСобытия.range.endLineNumber);
		Позиция.Insert("endColumn", ПараметрыСобытия.range.endColumn);

		ПараметрыОповещения.Insert("Позиция", Позиция);

		ОткрытьКонструкторФорматнойСтроки(ФорматнаяСтрока,
			New NotifyDescription("ПриЗавершенииРедактированияФорматнойСтрокиMonaco", ThisObject,
			ПараметрыОповещения));
	EndIf;
EndProcedure

Procedure ОткрытьКонструкторЗапросаMonaco(ПараметрыСобытия, AdditionalParameters)
	If ПараметрыСобытия = Undefined Then
		UT_CommonClient.ShowQuestionToUser(
			New NotifyDescription("ОткрытьКонструкторЗапросаMonacoЗавершениеВопроса", ThisObject,
			AdditionalParameters), "Not найден текст запроса." + Chars.LF + "Create новый запрос?",
			QuestionDialogMode.YesNo);
	Else
		QueryText = ПодготовитьТекстЗапросаДляКонструктора(ПараметрыСобытия.text);

		ПараметрыОповещения = AdditionalParameters;

		Позиция = New Structure;
		Позиция.Insert("startLineNumber", ПараметрыСобытия.range.startLineNumber);
		Позиция.Insert("startColumn", ПараметрыСобытия.range.startColumn);
		Позиция.Insert("endLineNumber", ПараметрыСобытия.range.endLineNumber);
		Позиция.Insert("endColumn", ПараметрыСобытия.range.endColumn);

		ПараметрыОповещения.Insert("Позиция", Позиция);

		ОткрытьКонструкторЗапроса(QueryText, New NotifyDescription("ПриЗавершенииРедактированияЗапросаMonaco",
			ThisObject, ПараметрыОповещения));
	EndIf;
EndProcedure

Procedure ПолеРедактораHTMLПриНажатииMonaco(Form, Item, ДанныеСобытия, СтандартнаяОбработка)
	Event = ДанныеСобытия.Event.eventData1C;

	If Event = Undefined Then
		Return;
	EndIf;

	If Event.event = "EVENT_QUERY_CONSTRUCT" Then
		AdditionalParameters = New Structure;
		AdditionalParameters.Insert("Form", Form);
		AdditionalParameters.Insert("Item", Item);

		ОткрытьКонструкторЗапросаMonaco(Event.params, AdditionalParameters);
	ElsIf Event.event = "EVENT_FORMAT_CONSTRUCT" Then
		AdditionalParameters = New Structure;
		AdditionalParameters.Insert("Form", Form);
		AdditionalParameters.Insert("Item", Item);

		ОткрытьКонструкторФорматнойСтрокиMonaco(Event.params, AdditionalParameters);
	ElsIf Event.event = "EVENT_GET_METADATA" Then
		AdditionalParameters = New Structure;
		AdditionalParameters.Insert("Form", Form);
		AdditionalParameters.Insert("Item", Item);

		МассивИменМетаданного = StrSplit(Event.params, ".");

		If МассивИменМетаданного[0] = "module" Then

			УстановитьОписаниеМодуляДляРедактораMonaco(Event.params, AdditionalParameters);

		Else

			УстановитьОписаниеМетаданныхДляРедактораMonaco(Event.params, AdditionalParameters);

		EndIf;
	EndIf;
EndProcedure

Function ИмяКаталогаВидаМетаданных(ВидОбъектаМетаданных)
	If ВидОбъектаМетаданных = "справочники" Then
		Return "Catalogs";
	ElsIf ВидОбъектаМетаданных = "документы" Then
		Return "Documents";
	ElsIf ВидОбъектаМетаданных = "константы" Then
		Return "Constants";
	ElsIf ВидОбъектаМетаданных = "перечисления" Then
		Return "Enums";
	ElsIf ВидОбъектаМетаданных = "отчеты" Then
		Return "Reports";
	ElsIf ВидОбъектаМетаданных = "обработки" Then
		Return "DataProcessors";
	ElsIf ВидОбъектаМетаданных = "планывидовхарактеристик" Then
		Return "ChartsOfCharacteristicTypes";
	ElsIf ВидОбъектаМетаданных = "планысчетов" Then
		Return "ChartsOfAccounts";
	ElsIf ВидОбъектаМетаданных = "планывидоврасчета" Then
		Return "ChartsOfCalculationTypes";
	ElsIf ВидОбъектаМетаданных = "регистрысведений" Then
		Return "InformationRegisters";
	ElsIf ВидОбъектаМетаданных = "регистрынакопления" Then
		Return "AccumulationRegisters";
	ElsIf ВидОбъектаМетаданных = "регистрыбухгалтерии" Then
		Return "AccountingRegisters";
	ElsIf ВидОбъектаМетаданных = "регистрырасчета" Then
		Return "CalculationRegisters";
	ElsIf ВидОбъектаМетаданных = "бизнеспроцессы" Then
		Return "BusinessProcesses";
	ElsIf ВидОбъектаМетаданных = "задачи" Then
		Return "Tasks";
	ElsIf ВидОбъектаМетаданных = "планыобмена" Then
		Return "ExchangePlans";
	EndIf;

EndFunction

Procedure НачатьПоискФайлаМодуляВКаталогеИсходныхФайлов(AdditionalParameters)
	If AdditionalParameters.КаталогиИсходников.Count() <= AdditionalParameters.ИндексКаталогаИсходников Then
		Return;
	EndIf;
	КаталогИсходныхФайлов = AdditionalParameters.КаталогиИсходников[AdditionalParameters.ИндексКаталогаИсходников].Directory;

	If Not ValueIsFilled(КаталогИсходныхФайлов) Then
		AdditionalParameters.ИндексКаталогаИсходников = AdditionalParameters.ИндексКаталогаИсходников + 1;
		НачатьПоискФайлаМодуляВКаталогеИсходныхФайлов(AdditionalParameters);
		Return;
	EndIf;

	ИмяКаталогаПоискаФайла = КаталогИсходныхФайлов + GetPathSeparator() + AdditionalParameters.КаталогМодуля
		+ GetPathSeparator() + AdditionalParameters.ОписаниеОбъектаМетаданных.Name;
	AdditionalParameters.Insert("ИмяКаталогаПоискаФайла", ИмяКаталогаПоискаФайла);

	BeginFindingFiles(New NotifyDescription("УстановитьОписаниеМодуляДляРедактораMonacoЗавершениеПоискаФайловМодуля",
		ThisObject, AdditionalParameters), ИмяКаталогаПоискаФайла, AdditionalParameters.ИмяФайлаМодуля, True);

EndProcedure

Procedure УстановитьОписаниеМодуляДляРедактораMonaco(ОбновляемыйОбъектМетаданных, AdditionalParameters)
	МассивИменМетаданного = StrSplit(ОбновляемыйОбъектМетаданных, ".");

	If МассивИменМетаданного.Count() < 2 Then
		Return;
	EndIf;

	РедакторыФормы = AdditionalParameters.Form[UT_CodeEditorClientServer.AttributeNameCodeEditorFormCodeEditors()];
	ИдентификаторРедактора = UT_CodeEditorClientServer.ИдентификаторРедактораПоЭлементуФормы(
		AdditionalParameters.Form, AdditionalParameters.Item);
	EditorSettings = РедакторыФормы[ИдентификаторРедактора];
	AdditionalParameters.Insert("КаталогиИсходников", EditorSettings.EditorSettings.SourceFilesDirectories);

	If AdditionalParameters.КаталогиИсходников.Count() = 0 Then
		Return;
	EndIf;

	AdditionalParameters.Insert("ИндексКаталогаИсходников", 0);

	ВидМодуля = МассивИменМетаданного[1];

	AdditionalParameters.Insert("ОбновляемыйОбъектМетаданных", ОбновляемыйОбъектМетаданных);
	AdditionalParameters.Insert("МассивИменМетаданного", МассивИменМетаданного);

	If ВидМодуля = "manager" Then
		ОписаниеОбъектаМетаданных = UT_CodeEditorServerCall.ОписаниеОбъектаМетаданныхКонфигурацииПоИмени(
			МассивИменМетаданного[2], МассивИменМетаданного[3]);

		КаталогМодуля = ИмяКаталогаВидаМетаданных(МассивИменМетаданного[2]);
		FileName = "ManagerModule.bsl";

		AdditionalParameters.Insert("ЭтоОбщийМодуль", False);

	ElsIf ВидМодуля = "object" Then
		ОписаниеОбъектаМетаданных = UT_CodeEditorServerCall.ОписаниеОбъектаМетаданныхКонфигурацииПоИмени(
			МассивИменМетаданного[2], МассивИменМетаданного[3]);

		КаталогМодуля = ИмяКаталогаВидаМетаданных(МассивИменМетаданного[2]);
		FileName = "ObjectModule.bsl";

		AdditionalParameters.Insert("ЭтоОбщийМодуль", False);
	Else
		ОписаниеОбъектаМетаданных = UT_CodeEditorServerCall.ОписаниеОбъектаМетаданныхКонфигурацииПоИмени(
			"CommonModules", МассивИменМетаданного[1]);

		КаталогМодуля = "CommonModules";
		FileName = "Module.bsl";

		AdditionalParameters.Insert("ЭтоОбщийМодуль", True);
	EndIf;

	AdditionalParameters.Insert("ОписаниеОбъектаМетаданных", ОписаниеОбъектаМетаданных);
	AdditionalParameters.Insert("КаталогМодуля", КаталогМодуля);
	AdditionalParameters.Insert("ИмяФайлаМодуля", FileName);

	НачатьПоискФайлаМодуляВКаталогеИсходныхФайлов(AdditionalParameters);
EndProcedure
Procedure УстановитьОписаниеМодуляДляРедактораMonacoЗавершениеПоискаФайловМодуля(НайденныеФайлы,
	AdditionalParameters) Export
	If НайденныеФайлы = Undefined Then
		AdditionalParameters.ИндексКаталогаИсходников = AdditionalParameters.ИндексКаталогаИсходников + 1;
		НачатьПоискФайлаМодуляВКаталогеИсходныхФайлов(AdditionalParameters);
		Return;
	EndIf;

	If НайденныеФайлы.Count() = 0 Then
		AdditionalParameters.ИндексКаталогаИсходников = AdditionalParameters.ИндексКаталогаИсходников + 1;
		НачатьПоискФайлаМодуляВКаталогеИсходныхФайлов(AdditionalParameters);
		Return;
	EndIf;

	FileName = НайденныеФайлы[0].FullName;
	AdditionalParameters.Insert("FileName", FileName);

	TextDocument = New TextDocument;

	AdditionalParameters.Insert("TextDocument", TextDocument);
	TextDocument.BeginReading(
		New NotifyDescription("УстановитьОписаниеМодуляДляРедактораMonacoЗавершениеЧтенияФайла", ThisObject,
		AdditionalParameters), AdditionalParameters.FileName);

EndProcedure

Procedure УстановитьОписаниеМодуляДляРедактораMonacoЗавершениеЧтенияФайла(AdditionalParameters) Export
	ТекстМодуля = AdditionalParameters.ТекстовыйДОкумент.GetText();

	ДокументView = AdditionalParameters.Item.Document.defaultView;

	If AdditionalParameters.ЭтоОбщийМодуль Then
		ДокументView.parseCommonModule(AdditionalParameters.ОписаниеОбъектаМетаданных.Name, ТекстМодуля, False);
	Else
		СоответствиеОбновляемыхОбъектовМетаданных = СоответствиеОбновляемыхОбъектовМетаданныхРедактораMonacoИПараметровСобытияОблновленияМетаданных();
		ОбновляемаяКоллекцияРедактора = СоответствиеОбновляемыхОбъектовМетаданных[AdditionalParameters.ОписаниеОбъектаМетаданных.ВидОбъекта];
		ОбновляемаяКоллекцияРедактора = ОбновляемаяКоллекцияРедактора + "."
			+ AdditionalParameters.ОписаниеОбъектаМетаданных.Name + "."
			+ AdditionalParameters.МассивИменМетаданного[1];

		ДокументView.parseMetadataModule(ТекстМодуля, ОбновляемаяКоллекцияРедактора);
	EndIf;
	ДокументView.triggerSuggestions();

EndProcedure

Procedure УстановитьОписаниеМетаданныхДляРедактораMonaco(ОбновляемыйОбъектМетаданных, AdditionalParameters)

	МассивИменМетаданного = StrSplit(ОбновляемыйОбъектМетаданных, ".");

	ВидОбъекта = МассивИменМетаданного[0];

	СоответствиеОбновляемыхОбъектовМетаданных = СоответствиеОбновляемыхОбъектовМетаданныхРедактораMonacoИПараметровСобытияОблновленияМетаданных();
	ОбновляемаяКоллекцияРедактора = СоответствиеОбновляемыхОбъектовМетаданных[ВидОбъекта];

	If МассивИменМетаданного.Count() = 1 Then
		ОбновляемыеДанные = New Structure;

		МассивИмен = UT_CodeEditorServerCall.СписокМетаданныхПоВиду(ВидОбъекта);
		For Each ТекИмя In МассивИмен Do
			ОбновляемыеДанные.Insert(ТекИмя, New Structure);
		EndDo;
	Else
		ОписаниеОбъектаМетаданных = UT_CodeEditorServerCall.ОписаниеОбъектаМетаданныхКонфигурацииПоИмени(
			ВидОбъекта, МассивИменМетаданного[1]);
		Description = ОписаниеОбъектаМетаданныхДляРедактораMonaco(ОписаниеОбъектаМетаданных);

		ОбновляемыеДанные = Description;

		ОбновляемаяКоллекцияРедактора = ОбновляемаяКоллекцияРедактора + "." + ОписаниеОбъектаМетаданных.Name;
	EndIf;

	ДокументView = AdditionalParameters.Item.Document.defaultView;
	ДокументView.updateMetadata(UT_CommonClientServer.mWriteJSON(
			ОбновляемыеДанные), ОбновляемаяКоллекцияРедактора);

	ДокументView.triggerSuggestions();
EndProcedure

Function ВидОбъектаРедактораMonacoПоВидуОбъекта1С(ВидОбъекта)

EndFunction

Function ТипРедактораМонакоПоСтрокеТипа1С(Тип1СИлиСтрока, ReferenceTypesMap)
	If ReferenceTypesMap = Undefined Then
		Return "";
	EndIf;

	Тип1С = Тип1СИлиСтрока;
	If TypeOf(Тип1С) = Type("String") Then
		If StrFind(Тип1СИлиСтрока, ".") > 0 Then
			Return Тип1СИлиСтрока;
		EndIf;
		
		Try
			Тип1С = Type(Тип1С);
		Except
			Return "types." + Тип1СИлиСтрока;
		EndTry;
	EndIf;

	МетаданныеТипа=ReferenceTypesMap[Тип1С];

	If МетаданныеТипа = Undefined Then
		If TypeOf(Тип1СИлиСтрока) = Type("String") Then
			Try
				Стр = New(Тип1СИлиСтрока);
				Return "classes." + Тип1СИлиСтрока;
			Except
				Return "types." + Тип1СИлиСтрока;
			EndTry;
		Else
			Return "";
		EndIf;
	EndIf;

	If МетаданныеТипа.ВидОбъекта = "Catalog" Then
		Return "catalogs." + МетаданныеТипа.Name;
	ElsIf МетаданныеТипа.ВидОбъекта = "Document" Then
		Return "documents." + МетаданныеТипа.Name;
	ElsIf МетаданныеТипа.ВидОбъекта = "Task" Then
		Return "tasks." + МетаданныеТипа.Name;
	ElsIf МетаданныеТипа.ВидОбъекта = "ChartOfCalculationTypes" Then
		Return "chartsOfCalculationTypes." + МетаданныеТипа.Name;
	ElsIf МетаданныеТипа.ВидОбъекта = "ChartOfCharacteristicTypes" Then
		Return "chartsOfCharacteristicTypes." + МетаданныеТипа.Name;
	ElsIf МетаданныеТипа.ВидОбъекта = "ExchangePlan" Then
		Return "exchangePlans." + МетаданныеТипа.Name;
	ElsIf МетаданныеТипа.ВидОбъекта = "ChartOfAccounts" Then
		Return "сhartsOfAccounts." + МетаданныеТипа.Name;
	EndIf;

	Return "";
EndFunction

Function ПолучитьСвязьСОбъектомМетаданныхДляРедактораMonaco(Attribute, СоответствиеТипов)

	Link = "";

	Types = Attribute.Type.Types();

	IndexOf = 0;

	For Each ТекТип In Types Do
		Link = ТипРедактораМонакоПоСтрокеТипа1С(ТекТип, СоответствиеТипов);

		If ValueIsFilled(Link) Then
			Break;
		EndIf;
	EndDo;
	Return Link;

EndFunction

Procedure ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеРеквизитов, Attribute, ПолучатьСвязиРеквизита,
	СоответствиеТипов)

	Link = "";
	If ПолучатьСвязиРеквизита Then
		Link= ПолучитьСвязьСОбъектомМетаданныхДляРедактораMonaco(Attribute, СоответствиеТипов);
	EndIf;

	ОписаниеРеквизита = New Structure("name", Attribute.Name);

	If ValueIsFilled(Link) Then
		ОписаниеРеквизита.Insert("ref", Link);
	EndIf;

	ОписаниеРеквизитов.Insert(Attribute.Name, ОписаниеРеквизита);

EndProcedure

Function ОписаниеОбъектаМетаданныхДляРедактораMonaco(ОписаниеОбъектаМетаданных)
	СоответствиеТипов = СоответствиеСсылочныхТиповКонфигурации();
	ОписаниеРеквизитов = New Structure;
	ОписаниеРесурсов = New Structure;
	ОписаниеПредопределенных = New Structure;
	ОписаниеТабличныхЧастей = New Structure;
	AdditionalProperties = New Structure;

	If ОписаниеОбъектаМетаданных.ВидОбъекта = "Enum" Or ОписаниеОбъектаМетаданных.ВидОбъекта
		= "перечисления" Then

		For Each КлючЗначениеЗначенияПеречисления In ОписаниеОбъектаМетаданных.EnumValues Do
			ОписаниеРеквизитов.Insert(КлючЗначениеЗначенияПеречисления.Key, New Structure("name",
				КлючЗначениеЗначенияПеречисления.Value));
		EndDo;

	Else

		If ОписаниеОбъектаМетаданных.Property("Attributes") Then
			For Each КлючЗначениеРеквизит In ОписаниеОбъектаМетаданных.Attributes Do
				ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеРеквизитов, КлючЗначениеРеквизит.Value, True,
					СоответствиеТипов);
			EndDo;
		EndIf;
		If ОписаниеОбъектаМетаданных.Property("StandardAttributes") Then
			For Each КлючЗначениеРеквизит In ОписаниеОбъектаМетаданных.StandardAttributes Do
				ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеРеквизитов, КлючЗначениеРеквизит.Value, False,
					СоответствиеТипов);
			EndDo;
		EndIf;
		If ОписаниеОбъектаМетаданных.Property("Predefined") Then
				
				//If ИмяМетаданных(FullName) = "ChartOfAccounts" Then
				//	
				//	Query = New Query(
				//	"ВЫБРАТЬ
				//	|	ChartOfAccounts.Code КАК Code,
				//	|	ChartOfAccounts.PredefinedDataName КАК Name
				//	|ИЗ
				//	|	&Table КАК ChartOfAccounts
				//	|ГДЕ
				//	|	ChartOfAccounts.Predefined");				
				//						
				//	Query.Text = StrReplace(Query.Text, "&Table", FullName);
				//	
				//	Выборка = Query.Execute().StartChoosing();
				//	
				//	While Выборка.Next() Do 
				//		ОписаниеПредопределенных.Insert(Выборка.Name, StrTemplate("%1 (%2)", Выборка.Name, Выборка.Code));
				//	EndDo;
				//	
				//Else				
			For Each КлючЗначениеИмя In ОписаниеОбъектаМетаданных.Predefined Do
				ОписаниеПредопределенных.Insert(КлючЗначениеИмя.Key, "");
			EndDo;
				
				//EndIf;

		EndIf;

		If ОписаниеОбъектаМетаданных.Property("Dimensions") Then

			For Each КлючЗначениеРеквизит In ОписаниеОбъектаМетаданных.Dimensions Do
				ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеРеквизитов, КлючЗначениеРеквизит.Value, True,
					СоответствиеТипов);
			EndDo;
			For Each КлючЗначениеРеквизит In ОписаниеОбъектаМетаданных.Resources Do
				ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеРеквизитов, КлючЗначениеРеквизит.Value, True,
					СоответствиеТипов);
			EndDo;
				
				//ЗаполнитьТипРегистра(AdditionalProperties, ОбъектМетаданных, FullName);				

		EndIf;

		If ОписаниеОбъектаМетаданных.Property("TabularSections") Then

			For Each КлючЗначениеТабличнаяЧасть In ОписаниеОбъектаМетаданных.TabularSections Do

				ТабличнаяЧасть = КлючЗначениеТабличнаяЧасть.Value;
				ОписаниеРеквизитов.Insert(ТабличнаяЧасть.Name, New Structure("name", "ТЧ: "
					+ ТабличнаяЧасть.Synonym));

				ОписаниеТабличнойЧасти = New Structure;

				If ТабличнаяЧасть.Property("StandardAttributes") Then
					For Each РеквизитТЧ In ТабличнаяЧасть.StandardAttributes Do
						ОписаниеТабличнойЧасти.Insert(РеквизитТЧ.Value.Name, РеквизитТЧ.Value.Synonym);
					EndDo;
				EndIf;

				If ТабличнаяЧасть.Property("Attributes") Then
					For Each РеквизитТЧ In ТабличнаяЧасть.Attributes Do
						ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеТабличнойЧасти, РеквизитТЧ.Value,
							True, СоответствиеТипов);
					EndDo;
				EndIf;

				ОписаниеТабличныхЧастей.Insert(ТабличнаяЧасть.Name, ОписаниеТабличнойЧасти);

			EndDo;

		EndIf;
		If ОписаниеОбъектаМетаданных.Property("StandardTabularSections") Then

			For Each КлючЗначениеТабличнаяЧасть In ОписаниеОбъектаМетаданных.StandardTabularSections Do

				ТабличнаяЧасть = КлючЗначениеТабличнаяЧасть.Value;
				ОписаниеРеквизитов.Insert(ТабличнаяЧасть.Name, New Structure("name", "ТЧ: "
					+ ТабличнаяЧасть.Synonym));

				ОписаниеТабличнойЧасти = New Structure;

				If ТабличнаяЧасть.Property("StandardAttributes") Then
					For Each РеквизитТЧ In ТабличнаяЧасть.StandardAttributes Do
						ОписаниеТабличнойЧасти.Insert(РеквизитТЧ.Value.Name, РеквизитТЧ.Value.Synonym);
					EndDo;
				EndIf;

				If ТабличнаяЧасть.Property("Attributes") Then
					For Each РеквизитТЧ In ТабличнаяЧасть.Attributes Do
						ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеТабличнойЧасти, РеквизитТЧ.Value,
							True, СоответствиеТипов);
					EndDo;
				EndIf;

				ОписаниеТабличныхЧастей.Insert(ТабличнаяЧасть.Name, ОписаниеТабличнойЧасти);

			EndDo;

		EndIf;

	EndIf;

	СтруктураОбъекта = New Structure;
	СтруктураОбъекта.Insert("properties", ОписаниеРеквизитов);

	For Each Обход In AdditionalProperties Do
		СтруктураОбъекта.Insert(Обход.Key, Обход.Value);
	EndDo;

	If ОписаниеРесурсов.Count() > 0 Then
		СтруктураОбъекта.Insert("resources", ОписаниеРесурсов);
	EndIf;

	If ОписаниеПредопределенных.Count() > 0 Then
		СтруктураОбъекта.Insert("predefined", ОписаниеПредопределенных);
	EndIf;

	If ОписаниеТабличныхЧастей.Count() > 0 Then
		СтруктураОбъекта.Insert("tabulars", ОписаниеТабличныхЧастей);
	EndIf;

	Return СтруктураОбъекта;
EndFunction

Function ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(Коллекция, СоответствиеТипов)

	ОписаниеКоллекции = New Structure;

	For Each КлючЗначениеЭлементКоллекции In Коллекция Do

		ОписаниеРеквизитов = New Structure;
		ОписаниеРесурсов = New Structure;
		ОписаниеПредопределенных = New Structure;
		ОписаниеТабличныхЧастей = New Structure;
		AdditionalProperties = New Structure;

		ОбъектМетаданных = КлючЗначениеЭлементКоллекции.Value;

		If ОбъектМетаданных.ВидОбъекта = "Enum" Then

			For Each КлючЗначениеЗначенияПеречисления In ОбъектМетаданных.EnumValues Do
				ОписаниеРеквизитов.Insert(КлючЗначениеЗначенияПеречисления.Key, New Structure("name",
					КлючЗначениеЗначенияПеречисления.Value));
			EndDo;

		Else

			If ОбъектМетаданных.Property("Attributes") Then
				For Each КлючЗначениеРеквизит In ОбъектМетаданных.Attributes Do
					ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеРеквизитов, КлючЗначениеРеквизит.Value,
						True, СоответствиеТипов);
				EndDo;
			EndIf;
			If ОбъектМетаданных.Property("StandardAttributes") Then
				For Each КлючЗначениеРеквизит In ОбъектМетаданных.StandardAttributes Do
					ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеРеквизитов, КлючЗначениеРеквизит.Value, False,
						СоответствиеТипов);
				EndDo;
			EndIf;
			If ОбъектМетаданных.Property("Predefined") Then
				
				//If ИмяМетаданных(FullName) = "ChartOfAccounts" Then
				//	
				//	Query = New Query(
				//	"ВЫБРАТЬ
				//	|	ChartOfAccounts.Code КАК Code,
				//	|	ChartOfAccounts.PredefinedDataName КАК Name
				//	|ИЗ
				//	|	&Table КАК ChartOfAccounts
				//	|ГДЕ
				//	|	ChartOfAccounts.Predefined");				
				//						
				//	Query.Text = StrReplace(Query.Text, "&Table", FullName);
				//	
				//	Выборка = Query.Execute().StartChoosing();
				//	
				//	While Выборка.Next() Do 
				//		ОписаниеПредопределенных.Insert(Выборка.Name, StrTemplate("%1 (%2)", Выборка.Name, Выборка.Code));
				//	EndDo;
				//	
				//Else				
				For Each КлючЗначениеИмя In ОбъектМетаданных.Predefined Do
					ОписаниеПредопределенных.Insert(КлючЗначениеИмя.Key, New Structure("name, ref",
						КлючЗначениеИмя.Key, ""));
				EndDo;
				
				//EndIf;

			EndIf;

			If ОбъектМетаданных.Property("Dimensions") Then

				For Each КлючЗначениеРеквизит In ОбъектМетаданных.Dimensions Do
					ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеРеквизитов, КлючЗначениеРеквизит.Value,
						True, СоответствиеТипов);
				EndDo;
				For Each КлючЗначениеРеквизит In ОбъектМетаданных.Resources Do
					ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеРеквизитов, КлючЗначениеРеквизит.Value,
						True, СоответствиеТипов);
				EndDo;
				
				//ЗаполнитьТипРегистра(AdditionalProperties, ОбъектМетаданных, FullName);				

			EndIf;

			If ОбъектМетаданных.Property("TabularSections") Then

				For Each КлючЗначениеТабличнаяЧасть In ОбъектМетаданных.TabularSections Do

					ТабличнаяЧасть = КлючЗначениеТабличнаяЧасть.Value;
					ОписаниеРеквизитов.Insert(ТабличнаяЧасть.Name, New Structure("name", "ТЧ: "
						+ ТабличнаяЧасть.Synonym));

					ОписаниеТабличнойЧасти = New Structure;

					If ТабличнаяЧасть.Property("StandardAttributes") Then
						For Each РеквизитТЧ In ТабличнаяЧасть.StandardAttributes Do
							ОписаниеТабличнойЧасти.Insert(РеквизитТЧ.Value.Name, РеквизитТЧ.Value.Synonym);
						EndDo;
					EndIf;

					If ТабличнаяЧасть.Property("Attributes") Then
						For Each РеквизитТЧ In ТабличнаяЧасть.Attributes Do
							ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеТабличнойЧасти, РеквизитТЧ.Value,
								True, СоответствиеТипов);
						EndDo;
					EndIf;

					ОписаниеТабличныхЧастей.Insert(ТабличнаяЧасть.Name, ОписаниеТабличнойЧасти);

				EndDo;

			EndIf;
			If ОбъектМетаданных.Property("StandardTabularSections") Then

				For Each КлючЗначениеТабличнаяЧасть In ОбъектМетаданных.StandardTabularSections Do

					ТабличнаяЧасть = КлючЗначениеТабличнаяЧасть.Value;
					ОписаниеРеквизитов.Insert(ТабличнаяЧасть.Name, New Structure("name", "ТЧ: "
						+ ТабличнаяЧасть.Synonym));

					ОписаниеТабличнойЧасти = New Structure;

					If ТабличнаяЧасть.Property("StandardAttributes") Then
						For Each РеквизитТЧ In ТабличнаяЧасть.StandardAttributes Do
							ОписаниеТабличнойЧасти.Insert(РеквизитТЧ.Value.Name, РеквизитТЧ.Value.Synonym);
						EndDo;
					EndIf;

					If ТабличнаяЧасть.Property("Attributes") Then
						For Each РеквизитТЧ In ТабличнаяЧасть.Attributes Do
							ДобавитьОписаниеРеквизитаДляРедактораMonaco(ОписаниеТабличнойЧасти, РеквизитТЧ.Value,
								True, СоответствиеТипов);
						EndDo;
					EndIf;

					ОписаниеТабличныхЧастей.Insert(ТабличнаяЧасть.Name, ОписаниеТабличнойЧасти);

				EndDo;

			EndIf;

		EndIf;

		СтруктураОбъекта = New Structure;
		СтруктураОбъекта.Insert("properties", ОписаниеРеквизитов);

		For Each Обход In AdditionalProperties Do
			СтруктураОбъекта.Insert(Обход.Key, Обход.Value);
		EndDo;

		If 0 < ОписаниеРесурсов.Count() Then
			СтруктураОбъекта.Insert("resources", ОписаниеРесурсов);
		EndIf;

		If 0 < ОписаниеПредопределенных.Count() Then
			СтруктураОбъекта.Insert("predefined", ОписаниеПредопределенных);
		EndIf;

		If 0 < ОписаниеТабличныхЧастей.Count() Then
			СтруктураОбъекта.Insert("tabulars", ОписаниеТабличныхЧастей);
		EndIf;

		ОписаниеКоллекции.Insert(ОбъектМетаданных.Name, СтруктураОбъекта);

	EndDo;

	Return ОписаниеКоллекции;

EndFunction

Function ПолучитьСписокОбъектовМетаданныхИзКоллекцииДляРедактораMonaco(Коллекция)

	ОписаниеКоллекции = New Structure;

	For Each КлючЗначение In Коллекция Do
		ОписаниеКоллекции.Insert(КлючЗначение.Key, New Structure);
	EndDo;

	Return ОписаниеКоллекции;

EndFunction

Function СоответствиеСсылочныхТиповКонфигурации()
	Map = UT_ApplicationParameters["СоответствиеСсылочныхТиповКонфигурации"];
	If Map <> Undefined Then
		Return Map;
	EndIf;

	СоответствиеТипов = UT_CodeEditorServerCall.ReferenceTypesMap();
	UT_ApplicationParameters.Insert("СоответствиеСсылочныхТиповКонфигурации", СоответствиеТипов);

	Return СоответствиеТипов;
EndFunction

Function ОписаниеМетаданныхКонфигурацииДляРедактораMonaco()
	ОписаниеМетаданных = UT_ApplicationParameters["ОписаниеМетаданныхДляРедактораMonaco"];
	If ОписаниеМетаданных <> Undefined Then
		Return ОписаниеМетаданных;
	EndIf;

	АдресОписанияМетаданных = UT_ApplicationParameters["АдресОписанияМетаданныхКонфигурации"];
	If Not IsTempStorageURL(АдресОписанияМетаданных) Then
		АдресОписанияМетаданных = UT_CommonServerCall.ConfigurationMetadataDescriptionAdress();
		UT_ApplicationParameters.Insert("АдресОписанияМетаданныхКонфигурации", АдресОписанияМетаданных);
	EndIf;
	МетаданныеКонфигурации = GetFromTempStorage(АдресОписанияМетаданных);

	СоответствиеТипов = МетаданныеКонфигурации.ReferenceTypesMap;

	КоллекцияМетаданных = New Structure;
	КоллекцияМетаданных.Insert("catalogs", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.Catalogs, СоответствиеТипов));
	КоллекцияМетаданных.Insert("documents", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.Documents, СоответствиеТипов));
	КоллекцияМетаданных.Insert("infoRegs", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.InformationRegisters, СоответствиеТипов));
	КоллекцияМетаданных.Insert("accumRegs", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.AccumulationRegisters, СоответствиеТипов));
	КоллекцияМетаданных.Insert("accountRegs", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.AccountingRegisters, СоответствиеТипов));
	КоллекцияМетаданных.Insert("calcRegs", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.CalculationRegisters, СоответствиеТипов));
	КоллекцияМетаданных.Insert("dataProc", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.DataProcessors, СоответствиеТипов));
	КоллекцияМетаданных.Insert("reports", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.Reports, СоответствиеТипов));
	КоллекцияМетаданных.Insert("enums", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.Enums, СоответствиеТипов));
	КоллекцияМетаданных.Insert("commonModules", ПолучитьСписокОбъектовМетаданныхИзКоллекцииДляРедактораMonaco(
		МетаданныеКонфигурации.CommonModules));
	КоллекцияМетаданных.Insert("сhartsOfAccounts", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.ChartsOfAccounts, СоответствиеТипов));
	КоллекцияМетаданных.Insert("businessProcesses", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.BusinessProcesses, СоответствиеТипов));
	КоллекцияМетаданных.Insert("tasks", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.Tasks, СоответствиеТипов));
	КоллекцияМетаданных.Insert("exchangePlans", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.ExchangePlans, СоответствиеТипов));
	КоллекцияМетаданных.Insert("chartsOfCharacteristicTypes", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.ChartsOfCharacteristicTypes, СоответствиеТипов));
	КоллекцияМетаданных.Insert("chartsOfCalculationTypes", ОписатьКоллекциюОбъектовМетаданыхДляРедактораMonaco(
		МетаданныеКонфигурации.ChartsOfCalculationTypes, СоответствиеТипов));
	КоллекцияМетаданных.Insert("constants", ПолучитьСписокОбъектовМетаданныхИзКоллекцииДляРедактораMonaco(
		МетаданныеКонфигурации.Constants));

	UT_ApplicationParameters.Insert("ОписаниеМетаданныхДляРедактораMonaco",
		UT_CommonClientServer.CopyStructure(КоллекцияМетаданных));
	UT_ApplicationParameters.Insert("СоответствиеСсылочныхТиповКонфигурации", СоответствиеТипов);

	Return КоллекцияМетаданных;
EndFunction

Function СоответствиеОбновляемыхОбъектовМетаданныхРедактораMonacoИПараметровСобытияОблновленияМетаданных()
	Map = New Structure;
	Map.Insert("справочники", "catalogs.items");
	Map.Insert("catalogs", "catalogs.items");
	Map.Insert("документы", "documents.items");
	Map.Insert("documents", "documents.items");
	Map.Insert("регистрысведений", "infoRegs.items");
	Map.Insert("informationregisters", "infoRegs.items");
	Map.Insert("регистрынакопления", "accumRegs.items");
	Map.Insert("accumulationregisters", "accumRegs.items");
	Map.Insert("регистрыбухгалтерии", "accountRegs.items");
	Map.Insert("accountingregisters", "accountRegs.items");
	Map.Insert("регистрырасчета", "calcRegs.items");
	Map.Insert("calculationregisters", "calcRegs.items");
	Map.Insert("обработки", "dataProc.items");
	Map.Insert("dataprocessors", "dataProc.items");
	Map.Insert("отчеты", "reports.items");
	Map.Insert("reports", "reports.items");
	Map.Insert("перечисления", "enums.items");
	Map.Insert("enums", "enums.items");
	Map.Insert("планысчетов", "сhartsOfAccounts.items");
	Map.Insert("chartsofaccounts", "сhartsOfAccounts.items");
	Map.Insert("бизнеспроцессы", "businessProcesses.items");
	Map.Insert("businessprocesses", "businessProcesses.items");
	Map.Insert("задачи", "tasks.items");
	Map.Insert("tasks", "tasks.items");
	Map.Insert("планыобмена", "exchangePlans.items");
	Map.Insert("exchangeplans", "exchangePlans.items");
	Map.Insert("планывидовхарактеристик", "chartsOfCharacteristicTypes.items");
	Map.Insert("chartsofcharacteristictypes", "chartsOfCharacteristicTypes.items");
	Map.Insert("планывидоврасчета", "chartsOfCalculationTypes.items");
	Map.Insert("chartsofcalculationtypes", "chartsOfCalculationTypes.items");
	Map.Insert("константы", "constants.items");
	Map.Insert("constants", "chartsOfCalculationTypes.items");
	Map.Insert("module", "commonModules.items");

	Return Map;
EndFunction

#EndRegion
Procedure СохранитьБиблиотекуРедактораНаДиск(АдресБиблиотеки, ВидРедактора, CompletionNotifyDescription)
	КаталогСохраненияБибилиотеки=КаталогСохраненияРедактора(ВидРедактора);
	ФайлРедактора=New File(КаталогСохраненияБибилиотеки);

	AdditionalParameters= New Structure;
	AdditionalParameters.Insert("АдресБиблиотеки", АдресБиблиотеки);
	AdditionalParameters.Insert("КаталогСохраненияБибилиотеки", КаталогСохраненияБибилиотеки);
	AdditionalParameters.Insert("ВидРедактора", ВидРедактора);
	AdditionalParameters.Insert("CompletionNotifyDescription", CompletionNotifyDescription);
	ФайлРедактора.BeginCheckingExistence(
		New NotifyDescription("СохранитьБиблиотекуРедактораНаДискЗавершениеПроверкиСуществованияБиблиотекиНаДиске",
		ThisObject, AdditionalParameters));
EndProcedure

Procedure СохранитьБиблиотекуРедактораЗаписатьНачатьЗаписьОчередногоФайла(AdditionalParameters)
	МассивСохраненныхФайлов = AdditionalParameters.МассивСохраненныхФайлов;
	КаталогСохраненияБибилиотеки = AdditionalParameters.КаталогСохраненияБибилиотеки;
	СоответствиеФайловБиблиотеки = AdditionalParameters.СоответствиеФайловБиблиотеки;
	ЕстьНеСохраненное = False;
	For Each КлючЗначение In СоответствиеФайловБиблиотеки Do
		If МассивСохраненныхФайлов.Find(КлючЗначение.Key) <> Undefined Then
			Continue;
		EndIf;
		ЕстьНеСохраненное = True;

		FileName=КаталогСохраненияБибилиотеки + GetPathSeparator() + КлючЗначение.Key;
		AdditionalParameters.Insert("ТекКлючФайла", КлючЗначение.Key);

		If TypeOf(КлючЗначение.Value) = Type("TextDocument") Then
			ОповещениеОЗаверешении = New NotifyDescription("СохранитьБиблиотекуРедактораЗаписатьНачатьЗаписьОчередногоФайлаТекстовогоДокументаЗавершение",
				ThisObject, AdditionalParameters);
		Else
			ОповещениеОЗаверешении = New NotifyDescription("СохранитьБиблиотекуРедактораЗаписатьНачатьЗаписьОчередногоФайлаЗавершение",
				ThisObject, AdditionalParameters);
		EndIf;

		КлючЗначение.Value.BeginWriting(ОповещениеОЗаверешении, FileName);
		Break;
	EndDo;

	If Not ЕстьНеСохраненное Then
		ExecuteNotifyProcessing(AdditionalParameters.CompletionNotifyDescription, True);
	EndIf;
EndProcedure

Function КаталогСохраненияРедактора(ВидРедактора)
	СтруктураФайловыхПеременных=UT_CommonClient.SessionFileVariablesStructure();
	If Not СтруктураФайловыхПеременных.Property("TempFilesDirectory") Then
		Return "";
	EndIf;

	Return СтруктураФайловыхПеременных.TempFilesDirectory + "tools_ui_1c" + GetPathSeparator() + Format(
		UT_CommonClientServer.Version(), "ЧГ=0;") + GetPathSeparator() + ВидРедактора;
EndFunction

Function ИмяФайлаРедактораAceДляЯзыка(Lang = "bsl") Export
	Return КаталогСохраненияРедактора(UT_CodeEditorClientServer.CodeEditorVariants().Ace)
		+ GetPathSeparator() + Lang + ".html";
EndFunction

Function ТекстHTMLРедактораКодаAce(КаталогСохраненияБибилиотеки, Lang)

	ТекстAce=КаталогСохраненияБибилиотеки + GetPathSeparator() + "ace" + GetPathSeparator() + "ace.js";
	ТекстLT=КаталогСохраненияБибилиотеки + GetPathSeparator() + "ace" + GetPathSeparator()
		+ "ext-language_tools.js";

	ТекЯзык=Lower(Lang);
	If ТекЯзык = "bsl" Then
		ТекЯзык="_1c";
	EndIf;
	HTMLText= "<!DOCTYPE html>
			   |<html lang=""ru"">
			   |<head>
			   |<title>ACE in Action</title>
			   |<style type=""text/css"" media=""screen"">
			   |    #editor { 
			   |        position: absolute;
			   |        top: 0;
			   |        right: 0;
			   |        bottom: 0;
			   |        left: 0;
			   |    }
			   |</style>
			   |</head>
			   |<body>
			   |
			   |<div id=""editor""></div>
			   |    
			   |<script src=""file://" + ТекстAce + """ type=""text/javascript"" charset=""utf-8""></script>
													|<script src=""file://" + ТекстLT + """ type=""text/javascript"" charset=""utf-8""></script>
																						|<script>
																						|    // trigger extension
																						|    ace.require(""ace/ext/language_tools"");
																						|    var editor = ace.edit(""editor"");
																						|    editor.session.setMode(""ace/mode/"
		+ ТекЯзык + """);
					|    editor.setTheme(""ace/theme/ones"");
					|    // enable autocompletion and snippets
					|    editor.setOptions({
					|        selectionStyle: 'line',
					|        highlightSelectedWord: true,
					|        showLineNumbers: true,
					|        enableBasicAutocompletion: true,
					|        enableSnippets: true,
					|        enableLiveAutocompletion: true
					|    });
					|
					|	editor.setHighlightSelectedWord(true);
					|
					|	function setSelection(startRow, startColumn, endRow, endColumn) {
					|		editor.clearSelection();
					|		var rangeEditor = new ace.Range(startRow, startColumn, endRow, endColumn);
					|       var selection = editor.getSelection();
					|       selection.setSelectionRange(rangeEditor, false);
					|		editor.centerSelection();
					|
					|	}
					|
					|</script>
					|
					|</body>
					|</html>";

	Return HTMLText;
EndFunction

Procedure ДобавитьКСохранениюТекстовыйДокументДляЯзыкаРедактораКодаAce(СоответствиеФайловБиблиотеки,
	КаталогСохраненияБибилиотеки, Lang)
	Text= New TextDocument;
	Text.SetText(ТекстHTMLРедактораКодаAce(КаталогСохраненияБибилиотеки, Lang));

	СоответствиеФайловБиблиотеки.Insert(Lang + ".html", Text);

EndProcedure
#EndRegion