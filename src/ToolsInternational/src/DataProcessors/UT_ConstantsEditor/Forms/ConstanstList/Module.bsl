&AtServer
Procedure FillConstantsTable()

	SetPrivilegedMode(True);

	ConstantsTable.Clear();
	
	For Each Constant In Metadata.Constants Do
		NewRow = ConstantsTable.Add();
		NewRow.ConstantName = Constant.Name;
		NewRow.ConstantSynonym = Constant.Synonym;
		NewRow.TypeDescription = Constant.Type;
		NewRow.ConstantValue = Constants[Constant.Name].Get();
		NewRow.HasValueStorage = Constant.Type.ContainsType(Type("ValueStorage"));

		ConstantValueType = New TypeDescription(Constant.Type, , "ValueStorage");
		if ConstantValueType.Types().Count() = 0 Then
			NewRow.ValueStorageOnly = True;
		EndIf;
	EndDo;
	
	
	// Fill constants functional options
	For Each FunctionalOption In Metadata.FunctionalOptions do
		If Not Metadata.Constants.Contains(FunctionalOption.Location) Then
			Continue;
		EndIf;

		SearchStructure = New Structure;
		SearchStructure.Insert("ConstantName",FunctionalOption.Location.Name);

		FoundRows = ConstantsTable.FindRows(SearchStructure);
		If FoundRows.Количество() = 0 Then
			Continue;
		EndIf;

		FoundRows[0].FunctionalOption = FunctionalOption.Name;
		FoundRows[0].PrivilegedGetMode = FunctionalOption.PrivilegedGetMode;
	EndDo;

EndProcedure
&AtServer
Procedure PutConstantItemsКонстантOnForm()
	AddedAtrubutesArray = New Array;

	For each CurrentConstant in ConstantsTable Do
		ConstantValueType = CurrentConstant.TypeDescription;
		If CurrentConstant.HasValueStorage И CurrentConstant.ValueStorageOnly Then
			ConstantValueType = New TypeDescription("String");
		EndIf;

		NewAttribute = New FormAttribute(CurrentConstant.ConstantName, ConstantValueType, "",
			CurrentConstant.ConstantSynonym, True);
		AddedAtrubutesArray.Add(NewAttribute);
	EndDo;

	ChangeAttributes(AddedAtrubutesArray, );

	// Put on form Constant with description
	ConstantsFormGroup = Items.GroupConstantsList;

	For each CurrentConstant In ConstantsTable Do
		// Create form group for each Constant , for set up UI attributes
		GroupDescription = UT_Forms.NewFormGroupDescription();
		GroupDescription.Name = "Group_" + CurrentConstant.ConstantName;
		GroupDescription.Title = CurrentConstant.ConstantSynonym;
		GroupDescription.GroupType = ChildFormItemsGroup.Horizontal;
		GroupDescription.ShowTitle = False;
		GroupDescription.Parent = ConstantsFormGroup;

		CurrentConstantGroup = UT_Forms.CreateGroupByDescription(ThisObject, GroupDescription);
		CurrentConstantGroup.ThroughAlign=ThroughAlign.Use;
		CurrentConstantGroup.HorizontalStretch	=True;
				
		// Декорация заголовка ConstanstList
		ОписаниеЭлемента = UT_Forms.НовыйОписаниеРеквизитаЭлемента();
		ОписаниеЭлемента.СоздаватьРеквизит = False;
		ОписаниеЭлемента.СоздаватьЭлемент = True;
		ОписаниеЭлемента.Имя = "Title_" + CurrentConstant.ConstantName;
		ОписаниеЭлемента.Заголовок=ConstantItemTitle(CurrentConstant.ConstantName, CurrentConstant.ConstantSynonym,
			ShowSynonym);
		ОписаниеЭлемента.РодительЭлемента = CurrentConstantGroup;
		ОписаниеЭлемента.Параметры.Тип=Тип("ДекорацияФормы");
		ОписаниеЭлемента.Параметры.Вставить("Вид", ВидДекорацииФормы.Надпись);
		ОписаниеЭлемента.Параметры.Вставить("РастягиватьПоГоризонтали", True);

		UT_Forms.СоздатьЭлементПоОписанию(ThisObject, ОписаниеЭлемента);
		
		
		// поле редактирования ConstanstList
		ОписаниеЭлемента = UT_Forms.НовыйОписаниеРеквизитаЭлемента();
		ОписаниеЭлемента.СоздаватьРеквизит = False;
		ОписаниеЭлемента.СоздаватьЭлемент = True;
		ОписаниеЭлемента.Имя = CurrentConstant.ConstantName;
		ОписаниеЭлемента.ПутьКДанным = CurrentConstant.ConstantName;
		ОписаниеЭлемента.Вставить("ПутьКРеквизиту", CurrentConstant.ConstantName);
		ОписаниеЭлемента.РодительЭлемента = CurrentConstantGroup;

		If (CurrentConstant.TypeDescription.Типы().Количество() = 1 И CurrentConstant.TypeDescription.СодержитТип(Тип(
			"Булево"))) Then
			ОписаниеЭлемента.Параметры.Вставить("Вид", ВидПоляФормы.ПолеФлажка);
		EndIf;
		If CurrentConstant.HasValueStorage Then
			ОписаниеЭлемента.Параметры.Вставить("Вид", ВидПоляФормы.ПолеНадписи);
			ОписаниеЭлемента.Параметры.Вставить("Гиперссылка", True);
			ОписаниеЭлемента.Действия.Вставить("Нажатие", "КонстантаНажатие");

		EndIf;
		ОписаниеЭлемента.Параметры.Вставить("ПоложениеЗаголовка", ПоложениеЗаголовкаЭлементаФормы.Нет);
		ОписаниеЭлемента.Параметры.Вставить("РастягиватьПоГоризонтали", True);

		ОписаниеЭлемента.Действия.Вставить("ПриИзменении", "КонстантаПриИзменении");

		UT_Forms.СоздатьЭлементПоОписанию(ThisObject, ОписаниеЭлемента);
	EndDo;

EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ShowSynonym=True;

	FillConstantsTable();
	PutConstantItemsКонстантOnForm();
	SetConstantValuesToFormAttribute();

	UT_Forms.ФормаПриСозданииНаСервереСоздатьРеквизитыПараметровЗаписи(ThisObject,
		Items.GroupWriteParametrs);
	UT_Common.ToolFormOnCreateAtServer(ThisObject,Cancel,StandardProcessing);

EndProcedure

&AtServer
Procedure SetConstantValuesToFormAttribute ()
	For each CurrentConstant In ConstantsTable Do
		ThisObject[CurrentConstant.ConstantName] = CurrentConstant.ConstantValue;
		Items["Group_" + CurrentConstant.ConstantName].BackColor = New Color;
	EndDo;
EndProcedure

&AtServer
Procedure WriteAtServer()
	Issuccessfully = True;
	For each ConstantRow In ConstantsTable Do
		If Не ConstantRow.Изменено Then
			Continue;
		EndIf;
		If ConstantRow.HasValueStorage Then
			Continue;
		EndIf;

		МенеджерКонстанты = Константы[ConstantRow.ConstantName].СоздатьМенеджерЗначения();
		МенеджерКонстанты.Прочитать();
		МенеджерКонстанты.Значение = ThisObject[ConstantRow.ConstantName];

		If UT_Common.ЗаписатьОбъектВБазу(МенеджерКонстанты,
			UT_CommonClientServer.ПараметрыЗаписиФормы(ThisObject)) Then
			ConstantRow.Изменено = False;

			// Установим цвет измененной ConstanstList на группу
			ЭлементГруппа = Items["Группа_" + ConstantRow.ConstantName];
			ЭлементГруппа.ЦветФона = New Цвет;
		Иначе
			Issuccessfully = False;

		EndIf;

	EndDo;

	If Issuccessfully Then
		ThisObject.Modified = False;
	EndIf;
EndProcedure

&AtServer
Procedure ReadConstants()
	FillConstantsTable();
	SetConstantValuesToFormAttribute();
	Modified = False;
EndProcedure

&AtClient
Function IsChangedConstants()
	IsChanged = False;
	For each ConstantRow In ConstantsTable Do
		If ConstantRow.IsChanged Then
			IsChanged = True;
			Break;
		EndIf;
	EndDo;

	Возврат IsChanged;
EndFunction

&AtClient
Procedure Reread(Command)
	If IsChangedConstants() Then
		ShowQueryBox(New NotifyDescription("RereadEnd", ThisObject),
		NStr("en = 'Some constants has changed. Write changed before rereading?'; ru = 'Есть измененные константы. Произвести запись перед чтением?'"), QuestionDialogMode.YesNoCancel);
	Иначе
		ReadConstants();
	EndIf;
EndProcedure

&AtClient
Procedure RereadEnd(Result, AdditionalParameters) Export
	If Result = DialogReturnCode.Cancel Then
		Return;
	ElsIF Result = DialogReturnCode.Yes Then
		WriteAtServer();
	EndIf;

	ReadConstants();
EndProcedure

&AtClient
Procedure WriteConstants(Command)
	WriteAtServer();
EndProcedure

&AtClient
Procedure ProcessConstantsSearch(SearchStringTransfered)
	SearchString =TrimAll(Lower(SearchStringTransfered));
	For each ConstantsTableCurrentRow In ConstantsTable Do
		ConstantIsVisible=True;
		If ValueIsFilled(SearchString) Then
			ConstantIsVisible=StrFind(Lower(ConstantsTableCurrentRow.ConstantName), SearchString) > 0 Или StrFind(
				Lower(ConstantsTableCurrentRow.ConstantSynonym), SearchString) > 0;
		EndIf;

		Items["Group" + ConstantsTableCurrentRow.ConstantName].Visible=ConstantIsVisible;
		Items["Title_" + ConstantsTableCurrentRow.ConstantName].Title=ConstantItemTitle(
			ConstantsTableCurrentRow.ConstantName, ConstantsTableCurrentRow.ConstantSynonym, ShowSynonym, SearchString);
	EndDo;

EndProcedure

&AtClient
Procedure SearchBarEditTextChange(Item, Text, StandardProcessing)
	SearchBar=Text;
	ProcessConstantsSearch(Text);
EndProcedure

&AtClientAtServerNoContext
Function ConstantItemTitle(ConstantName, ConstantSynonym, ShowSynonym, SearchString = "")
	Title = ConstantName;
	If ShowSynonym Then
		Title = Title + ": (" + ConstantSynonym + ")";
	EndIf;

	If ValueIsFilled(SearchString) Then
		OriginalTitle=Title;
		SearchTitle=Lower(OriginalTitle);
		NewTitle="";
		SearchStrLen=StrLen(SearchString);

		CharPosition=StrFind(SearchTitle, SearchString);
		While CharPosition > 0 Do
			FixedSearchString=New FormattedString(Mid(OriginalTitle, CharPosition,
				SearchStrLen), New Font(, , , True), WebColors.Red);
			NewTitle=New FormattedString(NewTitle, Left(OriginalTitle, CharPosition - 1),
				FixedSearchString);

			OriginalTitle=Mid(OriginalTitle, CharPosition + SearchStrLen);
			SearchTitle=Lower(OriginalTitle);

			CharPosition=StrFind(SearchTitle, SearchString);

		EndDo;

		If ValueIsFilled(NewTitle) Then
			NewTitle=New FormattedString (NewTitle, OriginalTitle);
			Title=NewTitle;
		EndIf;
	EndIf;
	Возврат Title;
EndFunction

&AtClient
Procedure ShowSynonymOnChange(Item)
	For each CurrentConstant In ConstantsTable Do
		Items["Title_" + CurrentConstant.ConstantName].Title=ConstantItemTitle(
			CurrentConstant.ConstantName, CurrentConstant.ConstantSynonym, ShowSynonym, Lower(TrimAll(SearchBar)));
	EndDo;
EndProcedure

&AtClient
Procedure SearchBarClearing(Item, StandardProcessing)
	ProcessConstantsSearch("");
EndProcedure



//@skip-warning 
&AtClient
Procedure Подключаемый_НастроитьПараметрыЗаписи(Command)
	UT_CommonClient.РедактироватьПараметрыЗаписи(ThisObject);
EndProcedure

//@skip-warning
&AtClient
Procedure КонстантаНажатие(Элемент, StandardProcessing)
	StandardProcessing=False;

	ConstantName = Элемент.Имя;

	SearchStructure = New Structure;
	SearchStructure.Вставить("ConstantName", ConstantName);

	НайденныеСтроки = ConstantsTable.НайтиСтроки(SearchStructure);
	If НайденныеСтроки.Количество() = 0 Then
		Возврат;
	EndIf;

	UT_CommonClient.РедактироватьХранилищеЗначения(ThisObject, НайденныеСтроки[0].ЗначениеКонстанты);
EndProcedure

&AtClient
Procedure Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Command) Экспорт
	UT_CommonClient.Подключаемый_ВыполнитьОбщуюКомандуИнструментов(ThisObject, Command);
EndProcedure

//@skip-warning
&AtClient
Procedure КонстантаПриИзменении(Элемент)
	ConstantName = Элемент.Имя;

	// Установим цвет измененной ConstanstList на группу
	ЭлементГруппа = Items["Группа_" + ConstantName];
	ЭлементГруппа.ЦветФона = WebЦвета.БледноБирюзовый;

	SearchStructure = New Structure;
	SearchStructure.Вставить("ConstantName", ConstantName);

	НайденныеСтроки = ConstantsTable.НайтиСтроки(SearchStructure);
	For each Константа In НайденныеСтроки Do
		Константа.Изменено = True;
	EndDo;
EndProcedure