#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, СтандартнаяОбработка)

	ЗаполнитьТаблицуПараметров();

	If Not Parameters.Key.IsEmpty() Then

		НастройкиТекстАлгоритма = CommonSettingsStorage.GetList(String(Parameters.Key) + "-n1");

		For Each ЭлементСписка In НастройкиТекстАлгоритма Do

			НастройкаТекстАлгоритма = CommonSettingsStorage.Load(String(Parameters.Key) + "-n1",
				ЭлементСписка.Value);
			Items.AlgorithmText[ЭлементСписка.Value] = НастройкаТекстАлгоритма;
		EndDo;

	EndIf;

	ЗаполнитьСпискиВыбораПолейФормы();

	УстановитьВидимостьИДоступность();

EndProcedure

&AtServer
Procedure BeforeWriteAtServer(Cancel, ТекущийОбъект, ПараметрыЗаписи)
EndProcedure

&AtServer
Procedure AfterWriteAtServer(ТекущийОбъект, ПараметрыЗаписи)
	УстановитьВидимостьИДоступность();
EndProcedure

&AtClient
Procedure NotificationProcessing(ИмяСобытия, Parameter, Src)
	If ИмяСобытия = "ParameterChanged" Then
		Read();
		ЗаполнитьТаблицуПараметров();
	ElsIf ИмяСобытия = "Update" Then
		Read();
	ElsIf ИмяСобытия = "ОбновитьКод" Then
		Read();
		Write();
	EndIf;
EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовШапкиФормы

&AtClient
Procedure ГруппаПанельСтраницПриСменеСтраницы(Item, CurrentPage)
	If Modified And CurrentPage.Name <> "GroupCode" Then
		Write();
	EndIf;
EndProcedure

&AtClient
Procedure НаКлиентеПриИзменении(Item)
	УстановитьВидимостьИДоступность();
EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовТаблицыФормы_Параметры

&AtClient
Procedure ТаблицаПараметровПередУдалением(Item, Cancel)
	ShowQueryBox(New NotifyDescription("ТаблицаПараметровПередУдалениемЗавершение", ThisObject,
		New Structure("String,Parameter", Item.CurrentLine, Item.CurrentData.Parameter)), "Item структуры настроек будет удален без возможности  восстановления !"
		+ Chars.LF + "Continue выполнение ? ", QuestionDialogMode.YesNoCancel);
	Cancel = True;
EndProcedure

&AtClient
Procedure ТаблицаПараметровПередУдалениемЗавершение(Result, AdditionalParameters) Export
	If Result = DialogReturnCode.Yes Then
		If УдалитьПараметрНаСервере(AdditionalParameters.Parameter) Then
			Read();
			ЗаполнитьТаблицуПараметров();
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure ТаблицаПараметровПараметрОткрытие(Item, СтандартнаяОбработка)
	СтандартнаяОбработка = False;
	If Item.Parent.CurrentData.TypeDescription = "Table значений"
		Or Item.Parent.CurrentData.TypeDescription = "Двоичные данные" Then
		Return;
	EndIf;
	Try
		Value = ПолучитьПараметрНаСервере(Items.ParametersTable.CurrentData.Parameter);
		ShowValue( , Value);
	Except
		Message(ErrorDescription());
	EndTry;
EndProcedure

#EndRegion

#Region ОбработчикиКомандФормы
///
&AtClient
Procedure AddParameter(Command)
	П = New Structure("Key", Object.Reference);
	OpenForm("Catalog.UT_Algorithms.Form.ParameterForm", П, ThisObject);
EndProcedure

&AtClient
Procedure ИзменитьИмя(Command)
	If Items.ParametersTable.CurrentData = Undefined Then
		Return;
	EndIf
	;
	П = New Structure("Key,ИмяПараметра,Rename", Parameters.Key,
		Items.ParametersTable.CurrentData.Parameter, True);
	OpenForm("Catalog.UT_Algorithms.Form.ParameterForm", П, ThisObject);
EndProcedure

&AtClient
Procedure ИзменитьЗначение(Command)
	If Items.ParametersTable.CurrentData <> Undefined Then
		П = New Structure;
		П.Insert("Key", Parameters.Key);
		П.Insert("ИмяПараметра", Items.ParametersTable.CurrentData.Parameter);
		П.Insert("ParameterType", Items.ParametersTable.CurrentData.ОписаниеТипа);
		OpenForm("Catalog.UT_Algorithms.Form.ParameterForm", П, ThisObject);
	EndIf;
EndProcedure

///
&AtClient
Procedure ВыполнитьПроцедуру(Command)

	If Modified Then
		Write();
	EndIf;

	ВремяСтарт = CurrentUniversalDateInMilliseconds();

	Error = False;
	СообщениеОбОшибке = "";

	If Object.AtClient Then
		UT_CommonClient.ExecuteAlgorithm(Object.Reference, , Error, СообщениеОбОшибке);
	Else
		UT_CommonServerCall.ExecuteAlgorithm(Object.Reference, , Error, СообщениеОбОшибке);
	EndIf;
	If Error Then
		UT_CommonClientServer.MessageToUser(СообщениеОбОшибке);

		Items.EventLog.Title = "ПОСМОТРЕТЬ ОШИБКИ";
		ВыделитьОшибку(СообщениеОбОшибке);
	Else
		Items.EventLog.Title = " ";
	EndIf;
	Items.ExecuteProcedure.Title = "Execute процедуру (" + String(CurrentUniversalDateInMilliseconds()
		- ВремяСтарт) + " мс.)";
EndProcedure

///
&AtClient
Procedure КонструкторЗапросаПоказать(Command)
	Конструктор = New QueryWizard;
	SelectedText = Items.AlgorithmText.SelectedText;
	ВесьТекст = Items.AlgorithmText.EditText;
	НайтиВесьТекстВКовычках(SelectedText, ВесьТекст);
	Конструктор.Text = StrReplace(SelectedText, "|", "");
	AdditionalParameters = New Structure("ПервыйВызовКонструктора,ВесьТекст,SelectedText", StrFind(
		SelectedText, "ВЫБРАТЬ") = 0, ВесьТекст, SelectedText);
	Оповещение = New NotifyDescription("GetQueryText", ThisObject, AdditionalParameters);
	Конструктор.Show(Оповещение);
EndProcedure

&AtClient
Procedure ФорматироватьТекст(Command)
	Text = Object.AlgorithmText;
	Text = StrReplace(Text, Chars.LF, " \\ ");
	Text = StrReplace(Text, Chars.Tab, " ");
	Text = StrReplace(Text, "=", " = ");
	Text = StrReplace(Text, "< =", " <=");
	Text = StrReplace(Text, "> =", " >=");
	For А = 0 To Round(Sqrt(StrOccurrenceCount(Text, "  ")), 0) Do
		Text = StrReplace(Text, "  ", " ");
	EndDo;
	Text = StrReplace(Text, " ;", ";");
	МассивСлов = StrSplit(Text, Char(32));
	ФормТекст = "";
	СтрокаТаб = "";
	ТипыСлов = New Array;
	ТипыСлов.Add(StrSplit("ТОГДА,ЦИКЛ,\\", ",")); // перенос справа
	ТипыСлов.Add(StrSplit("ЕСЛИ,ПОКА,ДЛЯ", ",")); // опер скобки открываются
	ТипыСлов.Add(StrSplit("КОНЕЦЦИКЛА;,КОНЕЦЕСЛИ;", ",")); // опер скобки закрываются
	ТипыСлов.Add(StrSplit("ИНАЧЕ,ИНАЧЕЕСЛИ", ",")); // опер скобки внутри
	БылТип = New Map;
	For Ё = 0 To МассивСлов.Count() - 1 Do
		ФорматДо = "";
		ФорматПосле = "";

		ТипСлова = ТипСлова(МассивСлов[Ё], ТипыСлов);

		If ТипСлова["СкобкаОткрылась"] Then
			СтрокаТаб = СтрокаТаб + Chars.Tab;
		EndIf;

		If ТипСлова["СкобкаВнутри"] Then
			ФормТекст = Left(ФормТекст, StrLen(ФормТекст) - 1);
		EndIf;

		If ТипСлова["СкобкаЗакрылась"] Then
			СтрокаТаб = Left(СтрокаТаб, StrLen(СтрокаТаб) - 1);
			ФормТекст = Left(ФормТекст, StrLen(ФормТекст) - 1);
		EndIf;

		If ТипСлова["ПереносСправа"] And Not БылТип["ПереносСправа"] Then
			ФорматПосле = Chars.LF + СтрокаТаб;
		EndIf;

		//If ТипСлова["ПереносСлева"] And Not БылТип["ПереносСправа"]  Then 
		//	ФорматДо =  Chars.LF + СтрокаТаб ;
		//EndIf;
		ФормТекст = ФормТекст + ФорматДо + МассивСлов[Ё] + Char(32) + ФорматПосле;

		БылТип = ТипСлова;
	EndDo;

	ФормТекст = StrReplace(ФормТекст, "\\ ", "");
	ФормТекст = StrReplace(ФормТекст, "\\", "");
	Object.AlgorithmText = ФормТекст;

EndProcedure

&AtClient
Procedure ДобавитьРегламентноеЗадание(Command)
	If Object.AtClient Then
		Message(" это клиентская процедура");
		Return;
	EndIf;
	CreateScheduledJob();
EndProcedure

&AtClient
Procedure УдалитьРегламентноеЗадание(Command)
	УдалитьРегламентноеЗаданиеНаСервере();
EndProcedure

&AtClient
Procedure ОткрытьЖурналРегистрации(Command)
	ПодключитьВнешнююОбработкуНаСервере();
	ПараметрыОткрытия = New Structure;
	ПараметрыОткрытия.Insert("Data", Object.Reference);
	ПараметрыОткрытия.Insert("ValidFrom", BegOfDay(CurrentDate()));
	OpenForm("ExternalDataProcessor.StandardEventLog.Form", ПараметрыОткрытия);
EndProcedure

#EndRegion

#Region Private

#Region РаботаСПараметрами

&AtServer
Procedure ЗаполнитьТаблицуПараметров()
	ВыбОбъект = FormAttributeToValue("Object");
	тПараметров = FormAttributeToValue("ParametersTable");
	тПараметров.Clear();
	СтруктураПараметров = ВыбОбъект.Storage.Get();
	If Not СтруктураПараметров = Undefined Then
		For Each ЭлементСтруктуры In СтруктураПараметров Do
			НС = тПараметров.Add();
			НС.Parameter = ЭлементСтруктуры.Key;
			НС.TypeDescription = ПолучитьСтрокуОписаниеТипа(ЭлементСтруктуры.Value);
		EndDo;
		ValueToFormAttribute(тПараметров, "ParametersTable");
	EndIf;
EndProcedure

&AtServer
Function ПолучитьСтрокуОписаниеТипа(Value)
	If XMLTypeOf(Value) <> Undefined Then
		Return XMLType(TypeOf(Value)).TypeName;
	Else
		Return String(TypeOf(Value));
	EndIf;
EndFunction

&AtServer
Procedure ДобавитьНовыйПараметрНаСервере(СтруктураПараметра)
	ИзменитьПараметр(СтруктураПараметра);
EndProcedure

&AtServer
Function УдалитьПараметрНаСервере(Key)
	ВыбОбъект = FormAttributeToValue("Object");
	Return ВыбОбъект.RemoveParameter(Key);
EndFunction

&AtServer
Function ПолучитьПараметрНаСервере(НаименованиеПараметра)
	ВыбОбъект = FormAttributeToValue("Object");
	Return ВыбОбъект.GetParameter(НаименованиеПараметра);
EndFunction

&AtServer
Procedure ИзменитьПараметр(НовыеДанные) Export
	НаименованиеПараметра = НовыеДанные.НаименованиеПараметра;
	If TypeOf(НовыеДанные.ЗначениеПараметра) = Type("String") Then
		If Left(НовыеДанные.ЗначениеПараметра, 1) = "{" Then
			Поз = StrFind(НовыеДанные.ЗначениеПараметра, "}");
			If Поз > 0 Then
				АдресХранилища = Mid(НовыеДанные.ЗначениеПараметра, Поз + 1);
				ЗначениеПараметра = ПолучитьИЗВременногоХранилища(АдресХранилища);
				FileExtention = StrReplace(Mid(НовыеДанные.ЗначениеПараметра, 2, Поз - 2), Char(32), "");
				НаименованиеПараметра = "File" + Upper(FileExtention) + "_" + НаименованиеПараметра;
			Else
				If Object.ThrowException Then
					Raise "Error при чтении Файла из хранилища ";
				EndIf;
			EndIf;
		Else
			ЗначениеПараметра = НовыеДанные.ЗначениеПараметра;
		EndIf;
	Else
		ЗначениеПараметра = НовыеДанные.ЗначениеПараметра;
	EndIf;
//	Parameters = Storage.Получить();
//	Если Parameters = Неопределено ИЛИ ТипЗнч(Parameters) <> Тип("Структура") Тогда
//		Parameters = Новый Структура;
//	КонецЕсли;
//	Parameters.Вставить(НаименованиеПараметра, ЗначениеПараметра);
//	Storage = Новый ХранилищеЗначения(Parameters);
//	Write();
EndProcedure

#EndRegion

#Region РАБОТАСКОДОМ

&AtClient
Procedure ВыделитьОшибку(ТекстОшибки)
	ПозОшибки = StrFind(ТекстОшибки, "{(");
	If ПозОшибки > 0 Then
		ПозСкобкаЗакрылась = StrFind(ТекстОшибки, ")}", , ПозОшибки);
		If ПозСкобкаЗакрылась > 0 Then
			ПозЗапятая = StrFind(Left(ТекстОшибки, ПозСкобкаЗакрылась), ",", , ПозОшибки);
			If ПозЗапятая > 0 Then
				ТекстНомерСтроки = Mid(ТекстОшибки, ПозОшибки + 2, StrLen(Left(ТекстОшибки, ПозЗапятая)) - StrLen(
					Left(ТекстОшибки, ПозОшибки)) - 2);
			Else
				ТекстНомерСтроки = Mid(ТекстОшибки, ПозОшибки + 2, StrLen(Left(ТекстОшибки, ПозСкобкаЗакрылась))
					- StrLen(Left(ТекстОшибки, ПозОшибки)) - 2);
			EndIf;
			// вложенная   ошибка   напр.  запрос
			ПозОшибки2 = StrFind(ТекстОшибки, "{(", , , 2);
			If ПозОшибки2 > 0 Then
				ПозСкобкаЗакрылась2 = StrFind(ТекстОшибки, ")}", , ПозОшибки2);
				If ПозСкобкаЗакрылась2 > 0 Then
					ПозЗапятая2 = StrFind(Left(ТекстОшибки, ПозСкобкаЗакрылась2), ",", , ПозОшибки2);
					If ПозЗапятая2 > 0 Then
						ТекстНомерСтроки2 = Mid(ТекстОшибки, ПозОшибки2 + 2, StrLen(Left(ТекстОшибки, ПозЗапятая2))
							- StrLen(Left(ТекстОшибки, ПозОшибки2)) - 2);
					Else
						ТекстНомерСтроки2 = Mid(ТекстОшибки, ПозОшибки2 + 2, StrLen(Left(ТекстОшибки,
							ПозСкобкаЗакрылась2)) - StrLen(Left(ТекстОшибки, ПозОшибки2)) - 2);
					EndIf;
				EndIf;
			EndIf;
			Try
				LineNumber = Number(ТекстНомерСтроки);
				мСтрок = StrSplit(Object.Text, Chars.LF, True);
				мСтрок[LineNumber - 1] = мСтрок[LineNumber - 1] + " <<<<<";
				If ПозОшибки2 > 0 Then
					НомерСтроки2 = Number(ТекстНомерСтроки2);
					Ъ = LineNumber - 1;
					While Ъ >= 0 Do
						If StrFind(мСтрок[Ъ], "ВЫБРАТЬ") > 0 Or StrFind(мСтрок[Ъ], "StartChoosing") > 0 Or StrFind(
							мСтрок[Ъ], "выбрать") > 0 Then
							мСтрок[Ъ + НомерСтроки2 - 1] = мСтрок[Ъ + НомерСтроки2 - 1] + " <<<<<";
						EndIf;
						Ъ = Ъ - 1;
					EndDo;
				EndIf;
				Object.Text = StrConcat(мСтрок, Chars.LF);
			Except
				Return;
			EndTry;
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure ВыделитьИзменившийсяКод()
//Элементы.AlgorithmText.ЦветРамки=Новый Цвет(255,99,71);
	//Items.Write.BgColor=New Color(255,99,71);
	Modified = True;
EndProcedure

&AtClient
Procedure НайтиВесьТекстВКовычках(SelectedText, ВесьТекст)
	If StrLen(SelectedText) > 10 Then // нужен уникальный текст , по хорошему нужно проверить количество включений
		ИщемЗдесь = StrFind(ВесьТекст, SelectedText);
		НашлиКавычкуДо = 0;
		For А = 1 To StrOccurrenceCount(ВесьТекст, """") Do
			НашлиКавычкуПосле = StrFind(ВесьТекст, """", , , А);
			If НашлиКавычкуПосле > ИщемЗдесь Then
				SelectedText = Mid(ВесьТекст, НашлиКавычкуДо + 1, StrLen(Left(Весьтекст, НашлиКавычкуПосле))
					- StrLen(Left(Весьтекст, НашлиКавычкуДо)) - 1);
				Break;
			EndIf;
			НашлиКавычкуДо = НашлиКавычкуПосле;
		EndDo;
	EndIf;
EndProcedure

&AtClient
Procedure GetQueryText(Text, AdditionalParameters) Export
	If Text = Undefined Then
		Return;
	EndIf;
	МассивСтрок = StrSplit(Text, Chars.LF);
	QueryText = МассивСтрок[0];
	For Ё = 1 To МассивСтрок.Count() - 1 Do
		QueryText = QueryText + Chars.LF + "|" + TrimAll(МассивСтрок[Ё]);
	EndDo;
	ТекстВставки = "";
	If AdditionalParameters.ПервыйВызовКонструктора Then
		ТекстВставки = "
					   |Query = New Query;
					   |QueryText = """ + QueryText + """;
															|Query.Text = QueryText;";
		While Find(QueryText, "&") > 0 Do
			ПарметрЗапроса = UT_AlgorithmsClientServer.ПолучитьПервоеВхождениеСловоБезПрефикса(QueryText, "&");
			ТекстВставки = ТекстВставки + "
										  |Query.SetParameter(""" + ПарметрЗапроса + """,@" + ПарметрЗапроса
				+ " );";
			QueryText = StrReplace(QueryText, "&" + ПарметрЗапроса, "~" + ПарметрЗапроса);
		EndDo;
		Text = Text + "
						|Result = Query.Execute();
						|If Not Result.IsEmpty() Then
						|	Выборка = Result.StartChoosing();
						|	While Выборка.Next() Do
						|	 	// Message("");
						|	EndDo;
						|EndIf;";
	Else
		ТекстВставки = QueryText;
	EndIf;
	If IsBlankString(AdditionalParameters.SelectedText) Then
		Object.Text = Object.Text + ТекстВставки;
		Items.AlgorithmText.UpdateEditText();
	Else
		Object.Text = StrReplace(AdditionalParameters.ВесьТекст, AdditionalParameters.SelectedText,
			ТекстВставки);
		Items.AlgorithmText.UpdateEditText();
	EndIf;
	ВыделитьИзменившийсяКод();

EndProcedure

&AtClient
Function ТипСлова(Слово, ТипыСлов)
	ТипСлова = New Map;

	ТипСлова["ПереносСправа"] = ?(ТипыСлов[0].Find(Upper(TrimAll(Слово))) = Undefined, False, True);
	ТипСлова["СкобкаОткрылась"] = ?(ТипыСлов[1].Find(Upper(TrimAll(Слово))) = Undefined, False, True);
	ТипСлова["СкобкаЗакрылась"] = ?(ТипыСлов[2].Find(Upper(TrimAll(Слово))) = Undefined, False, True);
	ТипСлова["СкобкаВнутри"] = ?(ТипыСлов[3].Find(Upper(TrimAll(Слово))) = Undefined, False, True);
	Return ТипСлова;

EndFunction

&AtServer
Procedure ВыполнитьПроцедуруНаСервере(ОшибкаВыполнения = False, СообщениеОбОшибке = "")
	ВыбОбъект = FormAttributeToValue("Object");
	AdditionalParameters = New Structure;
	ВыбОбъект.ВыполнитьПроцедуру(AdditionalParameters);
	ОшибкаВыполнения = AdditionalParameters.Cancel;
	СообщениеОбОшибке = AdditionalParameters.СообщениеОбОшибке;
EndProcedure

#EndRegion //------------------------------------- РАБОТАСКОДОМ

&AtServer
Procedure ЗаполнитьСпискиВыбораПолейФормы()

//СписокВыбора ОбъектМетаданных КомандныйИнтерфейс

	// СпискиВыбора  Parameters
	Query = New Query;
	Query.Text = "ВЫБРАТЬ РАЗЛИЧНЫЕ
				   |   УИ_АлгоритмыПараметры.ParameterType КАК ParameterType
				   |ИЗ
				   |   Catalog.UT_Algorithms.Parameters КАК УИ_АлгоритмыПараметры";

	Выборка = Query.Execute().StartChoosing();

	While Выборка.Next() Do

		If Not IsBlankString(Выборка.ParameterType) Then

			Items.ApiParameterType.ChoiceList.Add(TrimAll(Выборка.ParameterType));
		EndIf;

	EndDo;

EndProcedure
&AtServer
Procedure УстановитьВидимостьИДоступность()
	Items.GroupPagesPanel.Enabled = Not Parameters.Key.IsEmpty();

	Items.EventLog.Title = " ";

	Items.GroupServer.Visible=Not Object.AtClient;
EndProcedure
#Region ИмпортЭкспорт
//Импорт
&AtClient
Procedure ВнешнийФайлНачалоВыбораЗавершение(SelectedFiles, AdditionalParameters) Export
	If (TypeOf(SelectedFiles) = Type("Array") And SelectedFiles.Count() > 0) Then
		ВнешнийФайл = SelectedFiles[0];
		Directory = Left(ВнешнийФайл, StrFind(ВнешнийФайл, GetPathSeparator(), SearchDirection.FromEnd));
		NotifyDescription = New NotifyDescription("ЗакончитьПомещениеФайла", ThisObject, New Structure("Directory",
			Directory));
		BeginPutFile(NotifyDescription, , ВнешнийФайл, False, ThisObject.UUID);
	Else
		UT_CommonClientServer.MessageToUser("None файла");
	EndIf;
EndProcedure

&AtClient
Procedure ЗакончитьПомещениеФайла(Result, АдресХранилища, ВыбранноеИмяФайла, AdditionalParameters) Export
	If Result Then
		ПрочитатьНаСервере(АдресХранилища, ВыбранноеИмяФайла, AdditionalParameters);
	Else
		UT_CommonClientServer.MessageToUser("Error помещения файла в хранилище");
	EndIf;
EndProcedure

&AtServer
Procedure ПрочитатьНаСервере(АдресХранилища, ВыбранноеИмяФайла, AdditionalParameters)
	НаименованиеПараметра = StrReplace(StrReplace(StrReplace(StrReplace(Врег(ВыбранноеИмяФайла), Врег(
		AdditionalParameters.Directory), ""), ".", ""), "XML", ""), Char(32), "");
	Try
		BinaryData = GetFromTempStorage(АдресХранилища);
		Stream = BinaryData.OpenStreamForRead();
		XMLReader = New XMLReader;
		XMLReader.OpenStream(Stream);
		ЗначениеПараметра = XDTOSerializer.ReadXML(XMLReader);
		ДобавитьНовыйПараметрНаСервере(New Structure("НаименованиеПараметра,ЗначениеПараметра",
			НаименованиеПараметра, ЗначениеПараметра));
	Except
		Raise "Error записи файла XLM : " + ErrorDescription();
	EndTry;
EndProcedure

// ПрочитатьНаСервере()

//Экспорт
&AtClient
Procedure ВыборКаталогаЗавершение(SelectedFiles, AdditionalParameters) Export
	If (TypeOf(SelectedFiles) = Type("Array") And SelectedFiles.Count() > 0) Then
		Directory = SelectedFiles[0];
		Parameter = Items.ParametersTable.CurrentData.Parameter;
		FileExtention = "";
		FileName = TrimAll(Parameter);
		If TypeOf(AdditionalParameters) = Type("Structure") And AdditionalParameters.Property("ВыгрузитьXML") Then
			FileExtention = ".xml";
			АдресХранилища = ПолучитьФайлНаСервере(Parameter, True);
		Else
			If StrFind(Parameter, "File") > 0 Then
				Поз = StrFind(FileName, "_");
				FileExtention = "." + Lower(Mid(FileName, 5, Поз - 5));
				FileName = Mid(FileName, Поз + 1);
			EndIf;
			АдресХранилища = ПолучитьФайлНаСервере(Parameter, False);
		EndIf;
		Оповещение = New NotifyDescription("ПослеПолученияФайла", ThisObject);
		ОписаниеФайла = New TransferableFileDescription;
		ОписаниеФайла.Location = АдресХранилища;
		ОписаниеФайла.Name = Directory + GetPathSeparator() + FileName + FileExtention;
		ПолучаемыеФайлы = New Array;
		ПолучаемыеФайлы.Add(ОписаниеФайла);
		BeginGettingFiles(Оповещение, ПолучаемыеФайлы, , False);
	EndIf;
EndProcedure

&AtServer
Function ПолучитьФайлНаСервере(Parameter, ВыгрузитьXML)
	ВыбПараметр = ПолучитьПараметрНаСервере(Parameter);
	If ВыгрузитьXML Then
		XMLWriter = New XMLWriter;
		Stream = New MemoryStream;
		XMLWriter.OpenStream(Stream);
		XDTOSerializer.WriteXML(XMLWriter, ВыбПараметр);
		XMLWriter.Close();
		BinaryData = Stream.CloseAndGetBinaryData();
		АдресХранилища = PutToTempStorage(BinaryData, ThisObject.UUID);
	Else
		АдресХранилища = PutToTempStorage(ВыбПараметр, ThisObject.UUID);
	EndIf;
	Return АдресХранилища;
EndFunction

&AtClient
Procedure ПослеполученияФайла(ПолученныеФайлы, ДопПараметры) Export
	If TypeOf(ПолученныеФайлы) = Type("Array") Then
		UT_CommonClientServer.MessageToUser("File " + ПолученныеФайлы[0].Name + " записан");
	EndIf;
EndProcedure

&AtClient
Procedure ПроверкаПараметровПрограммныйИнтерфейс(Command)
	Object.Parameters.Clear();
	КодАлгоритма = Object.КодАлгоритма;
	мИсключая = UT_AlgorithmsClientServer.МассивИсключаемыхСимволов();
	Prefix = "Parameters.";
	FillType = New Structure;
	While Find(КодАлгоритма, Prefix) > 0 Do
		Слово = UT_AlgorithmsClientServer.ПолучитьПервоеВхождениеСловоБезПрефикса(КодАлгоритма, Prefix, мИсключая);
		КодАлгоритма = StrReplace(КодАлгоритма, Prefix + Слово, Слово);
		Try
			FillType.Insert(Слово, True);
		Except
		EndTry;
	EndDo;
	Text = Object.Text;
	Prefix = "$";
	While Find(КодАлгоритма, Prefix) > 0 Do
		Слово = UT_AlgorithmsClientServer.ПолучитьПервоеВхождениеСловоБезПрефикса(Text, Prefix, мИсключая);
		Text = StrReplace(Text, Prefix + Слово, Слово);
		Try
			FillType.Insert(Слово, False);
		Except
		EndTry;
	EndDo;

	АдресХранилища = UT_AlgorithmsClientServer.ПолучитьПараметры(Object.Reference, True);

	ХранимыеПараметры = GetFromTempStorage(АдресХранилища);

	For Each ЭлементСоответствия In FillType Do
		НоваяСтрока = Object.Parameters.Add();
		НоваяСтрока.Entry = ЭлементСоответствия.Value;
		НоваяСтрока.Name = ЭлементСоответствия.Key;
		If НоваяСтрока.Entry And ХранимыеПараметры.Property(ЭлементСоответствия.Key) Then
			НоваяСтрока.ParameterType = ПолучитьСтрокуОписаниеТипа(ХранимыеПараметры[ЭлементСоответствия.Key]);
			НоваяСтрока.ByDefault = String(ХранимыеПараметры[ЭлементСоответствия.Key]);
		EndIf;
	EndDo;
EndProcedure

#EndRegion

&AtServer
Procedure ПодключитьВнешнююОбработкуНаСервере()
	ExternalDataProcessors.Connect("v8res://mngbase/StandardEventLog.epf", "StandardEventLog", False);
EndProcedure

&AtServer
Procedure CreateScheduledJob()
	If Parameters.Key.IsEmpty() Then
		Return;
	EndIf;
	МассивПараметров = New Array;
	МассивПараметров.Add(Object.Reference);
	Filter = New Structure;
	Filter.Insert("Key", Object.Reference.UUID());
	МассивЗаданий = ScheduledJobs.GetScheduledJobs(Filter);
	If МассивЗаданий.Count() >= 1 Then
		Message("Задание с  ключом " + Filter.Key + " уже существует");
	Else
		Задание = ScheduledJobs.CreateScheduledJob("alg_УниверсальноеРегламентноеЗадание");
		Задание.Title = Object.Title;
		Задание.Key = Filter.Key;
		Задание.Use = False;
		Задание.Parameters = МассивПараметров;
		Задание.Write();
		Message("Создано регламентное задание " + Object.Title + " с  ключом " + Filter.Key);
	EndIf;
EndProcedure

// СоздатьРегламентноеЗадание()
&AtServer
Procedure УдалитьРегламентноеЗаданиеНаСервере()
	If Parameters.Key.IsEmpty() Then
		Return;
	EndIf;
	МассивПараметров = New Array;
	МассивПараметров.Add(Object.Reference);
	Filter = New Structure;
	Filter.Insert("Key", Object.Reference.UUID());
	МассивЗаданий = ScheduledJobs.GetScheduledJobs(Filter);
	If МассивЗаданий.Count() >= 1 Then
		МассивЗаданий[0].Delete();
		Message("Удалено регламентное задание  " + Object.Title);
	EndIf;
	// Insert содержимое обработчика.
EndProcedure

#EndRegion