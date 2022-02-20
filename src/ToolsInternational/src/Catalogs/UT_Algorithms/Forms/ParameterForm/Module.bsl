&AtClient
Procedure WriteAndClose(Command)
	If Not Parameters.Rename Then
		ChangeParameter();
		Notify("ParameterChanged");
	EndIf;
	Close();
EndProcedure

&AtClient
Procedure SetParameterName(Command)
	ParameterName=TrimAll(ParameterName);
	If ЕстьОшибкиВНаименованииПараметра(ParameterName) Then
		Message = New UserMessage;
		Message.Text = "Введите наименование параметра";
		Message.Field = "ParameterName";
		Message.Message();
	Else
		If Parameters.Rename Then
			ПереименоватьПараметр(Parameters.ИмяПараметра, ParameterName);
			Notify("ParameterChanged");
			Close();
		Else
			ThisForm.Title= "New параметр : " + ParameterName;
			УправлениеВидимостьюЭлементовФормы("SelectedType", False);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Function ЕстьОшибкиВНаименованииПараметра(Name)
	If IsBlankString(Name) Then
		Return True;
	Else
		 //TODO  проверка на допустимые символы
		Return False;
	EndIf;
EndFunction

&AtClient
Procedure ExternalFileStartChoice(Item, ChoiceData, StandardProcessing)
	StandardProcessing=False;
	Dialog = New FileDialog(FileDialogMode.Opening);
	Dialog.Title = "Выберите файл";
	Dialog.FullFileName = "";
	Filter = "All файлы  (*.*)|*.*";
	Dialog.Filter = Filter;
	Dialog.Multiselect = False;
	Dialog.Show(New NotifyDescription("ВнешнийФайлНачалоВыбораЗавершение", ThisForm));
EndProcedure


&AtClient
Procedure ВнешнийФайлНачалоВыбораЗавершение(SelectedFiles, AdditionalParameters) Export
	If (TypeOf(SelectedFiles) = Type("Array") And SelectedFiles.Count() > 0) Then
		ExternalFile = SelectedFiles[0];
		NotifyDescription = New NotifyDescription("ЗакончитьПомещениеФайла", ThisObject);
		BeginPutFile(NotifyDescription, , ExternalFile, False, ThisForm.UUID);
	Else
		_37583_АлгоритмыКлиент.PopUp(" нет файла ");
	EndIf;
EndProcedure

&AtClient
Procedure ЗакончитьПомещениеФайла(Result, Address, ВыбранноеИмяФайла, AdditionalParameters) Export
	АдресХранилища = Address;
EndProcedure

&AtServer
Procedure УправлениеВидимостьюЭлементовФормы(П = "", ВидимостьКнопок = True)
	For Each Item In Items Do
		If TypeOf(Item) = Type("FormDecoration") Then
			Continue;
		EndIf;
		If Not IsBlankString(П) Then
			Item.Visible=?(Find(Item.Name, П) > 0, True, False);
		EndIf;
		If Find(Item.Name, "Close") > 0 Then
			Item.Visible=ВидимостьКнопок;
			Item.Parent.Visible=True;
		EndIf;
	EndDo;
EndProcedure

&AtServer
Procedure УправлениеВидимостьюКоллекции(П = "Array")
	If Not IsBlankString(Parameters.ИмяПараметра) Then
		Items.TypeCollection.Visible=False;
	EndIf;
	If П = "Array" Then
		ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
	ElsIf П = "Structure" Then
		Items.TypeDescription.Visible=False;
		Items.AddColumn.Visible=False;
		ОТ= New TypeDescription("String", , New StringQualifiers(20, AllowedLength.Variable));
		ДобавитьКолонкуНС("Key", ОТ, "CollectionParameter");
		ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
	ElsIf П = "Map" Then
		Items.TypeDescription.Visible=False;
		Items.AddColumn.Visible=False;
		ДобавитьКолонкуНС("Key", TypeDescription, "CollectionParameter");
		ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
	Else
		Items.TypeDescription.Visible=True;
		Items.AddColumn.Visible=True;
		Items.DeleteColumn.Visible=True;
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If IsBlankString(Parameters.ИмяПараметра) Then
		ThisForm.Title="New параметр";
		УправлениеВидимостьюЭлементовФормы("Title", False);
	ElsIf Parameters.Rename Then
		ThisForm.Title=Parameters.ИмяПараметра + ":New имя параметра";
		ParameterName=Parameters.ИмяПараметра;
		УправлениеВидимостьюЭлементовФормы("Title");
	Else
		ParameterName=Parameters.ИмяПараметра;
		ThisForm.Title=Parameters.ИмяПараметра + ":Update параметра";
		ДействияПриИзменениеПараметра();
	EndIf;
EndProcedure

&AtServer
Procedure ДействияПриИзменениеПараметра()
	Parameter=GetParameter(Parameters.ИмяПараметра);
	C = New Map;
	C.Insert("Array", "Коллекция");
	C.Insert("Structure", "Коллекция");
	C.Insert("Map", "Коллекция");
	C.Insert("Table значений", "Коллекция");
	C.Insert("Двоичные данные", "ExternalFile");
	C.Insert(Undefined, "AvailableTypes");
	ParameterType=C.Get(Parameters.ParameterType);
	If ParameterType = Undefined Then
		УправлениеВидимостьюЭлементовФормы("AvailableTypes");
		AvailableTypes=Parameter;
		Items.AvailableTypes.Title=Parameters.ParameterType;
		Items.AvailableTypes.ChooseType=False;
		Parameters.ParameterType="AvailableTypes";
	ElsIf ParameterType = "Коллекция" Then
		УправлениеВидимостьюЭлементовФормы("Коллекция");
		Items.TypeCollection.Visible=False;
		For Each ЭлементКоллекции In Items.CollectionParameter.ChildItems Do
			ЭлементКоллекции.Visible=True;
		EndDo;
		If Parameters.ParameterType = "Array" Then
			ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
			Т=КоллекцияВТЗ(Parameter);
			CollectionParameter.Load(Т);
			TypeCollection="Array";
		ElsIf Parameters.ParameterType = "Structure" Then
			Items.TypeDescription.Visible=False;
			Items.AddColumn.Visible=False;
			ОТ= New TypeDescription("String", , New StringQualifiers(20, AllowedLength.Variable));
			ДобавитьКолонкуНС("Key", ОТ, "CollectionParameter");
			ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
			Т=КоллекцияВТЗ(Parameter);
			CollectionParameter.Load(Т);
			TypeCollection="Structure";
		ElsIf Parameters.ParameterType = "Map" Then
			Items.TypeDescription.Visible=False;
			Items.AddColumn.Visible=False;
			ДобавитьКолонкуНС("Key", TypeDescription, "CollectionParameter");
			ДобавитьКолонкуНС("Value", TypeDescription, "CollectionParameter");
			Т=КоллекцияВТЗ(Parameter);
			CollectionParameter.Load(Т);
			TypeCollection="Map";
		Else
			Items.TypeDescription.Visible=True;
			Items.AddColumn.Visible=True;
			Items.DeleteColumn.Visible=True;
			For Each Column In Parameter.Cols Do
				ДобавитьКолонкуНС(Column.Name, Column.ValueType, "CollectionParameter");
			EndDo;
			CollectionParameter.Load(Parameter);
		EndIf;
	Else
		Parameters.ParameterType="ExternalFile";
		УправлениеВидимостьюЭлементовФормы("ExternalFile");
	EndIf;
EndProcedure

&AtServer
Function КоллекцияВТЗ(Коллекция)
	ТЗ = New ValueTable;
	ТЗ.Cols.Add("Value");
	If Not TypeOf(Коллекция) = Type("Array") Then
		ТЗ.Cols.Add("Key");
		For Each ТекЭлем In Коллекция Do
			НС=ТЗ.Add();
			FillPropertyValues(НС, ТекЭлем);
		EndDo;
	Else
		For I = 0 To Коллекция.UBound() Do
			ТЗ.Add();
		EndDo;
		ТЗ.LoadColumn(Коллекция, 0);
	EndIf;
	Return ТЗ;
EndFunction

&AtServer
Procedure ПереименоватьПараметр(Key, НовоеИмя)
	ВыбОбъект=FormAttributeToValue("Object");
	ВыбОбъект.ПереименоватьПараметр(Key, НовоеИмя);
EndProcedure

/// Интерф

&AtClient
Procedure AddColumn(Command)
	КолонкаИмя="";
	ShowInputValue(New NotifyDescription("ДобавитьКолонкуЗавершение", ThisForm, New Structure("КолонкаИмя",
		КолонкаИмя)), КолонкаИмя, "Введите имя новой колонки", "String");
EndProcedure

&AtClient
Procedure ДобавитьКолонкуЗавершение(Value, AdditionalParameters) Export

	КолонкаИмя = ?(Value = Undefined, AdditionalParameters.КолонкаИмя, Value);
	If Not IsBlankString(КолонкаИмя) Then
		ДобавитьКолонкуНС(TrimAll(КолонкаИмя), TypeDescription, "CollectionParameter");
		TypeDescription="";
	Else
		Return;
	EndIf;

EndProcedure

&AtClient
Procedure DeleteColumn(Command)
	ColumnName=Items.CollectionParameter.CurrentItem.Name;
	If Items.CollectionParameter.CurrentItem <> Undefined Then
		ShowQueryBox(New NotifyDescription("УдалитьКолонкуЗавершение", ThisForm, New Structure("ColumnName",
			ColumnName)), "Вы уверены что хотите изменить удалить колонку  """ + ColumnName + """ ?",
			QuestionDialogMode.YesNo);
	Else
		ShowMessageBox(Undefined, "Нужно выбрать колонку таблицы !");
	EndIf;
EndProcedure

&AtClient
Procedure УдалитьКолонкуЗавершение(РезультатВопроса, AdditionalParameters) Export

	ColumnName = AdditionalParameters.ColumnName;

	If РезультатВопроса = DialogReturnCode.Yes Then
		УдалитьКолонкуНС(ColumnName, "CollectionParameter");
	EndIf
	;

EndProcedure

&AtServer
Procedure ДобавитьКолонкуНС(Знач КолонкаИмя, ОписаниеТипаКолонки, FormTable)
	МассивДобавляемыхРеквизитов = New Array;
	МассивДобавляемыхРеквизитов.Add(
	New FormAttribute(КолонкаИмя, ОписаниеТипаКолонки, FormTable, КолонкаИмя));
	ChangeAttributes(МассивДобавляемыхРеквизитов);
	НовыйЭлемент = Items.Add(КолонкаИмя, Type("FormField"), Items[FormTable]);
	НовыйЭлемент.Title=КолонкаИмя;
	НовыйЭлемент.Type = FormFieldType.TextBox;
	НовыйЭлемент.DataPath = FormTable + "." + КолонкаИмя;
EndProcedure

&AtServer
Procedure УдалитьКолонкуНС(КолонкаИмя, FormTable)
	Items.Delete(Items.Find(КолонкаИмя));
	МассивУдаляемыхРеквизитов = New Array;
	МассивУдаляемыхРеквизитов.Add(FormTable + "." + КолонкаИмя);
	ChangeAttributes( , МассивУдаляемыхРеквизитов);
EndProcedure

&AtClient
Procedure TypeCollectionOnChange(Item)
		УправлениеВидимостьюКоллекции(TypeCollection);
	Item.Visible=False;
EndProcedure

&AtServer
Procedure ChangeParameter()
	НовоеЗначение=ПолучитьНовоеЗначение();
	If Not НовоеЗначение = Undefined Then
		ВыбОбъект=FormAttributeToValue("Object");
		ВыбОбъект.ChangeParameter(New Structure("ParameterName,ЗначениеПараметра", ParameterName,
			НовоеЗначение));
	EndIf;
EndProcedure

&AtServer
Function ПолучитьНовоеЗначение()
	If Parameters.ParameterType = "AvailableTypes" Then
		Return AvailableTypes;
	ElsIf Parameters.ParameterType = "ExternalFile" Then
		Поз = StrFind(ExternalFile, ".", SearchDirection.FromEnd);
		Return "{" + ?(Поз > 0, Mid(ExternalFile, Поз + 1) + "}", "}") + АдресХранилища;
	ElsIf Parameters.ParameterType = "DefinedType" Then
		Try
			Result=Undefined;
			Execute (DefinedType);
			Return Result;
		Except
			Message(ErrorDescription());
			Return Undefined;
		EndTry;
	Else
		Т=FormAttributeToValue("CollectionParameter");
		If TypeCollection = "Array" Then
			Return Т.UnloadColumn(0);
		ElsIf TypeCollection = "Structure" Then
			С=New Structure;
			For Each Стр In Т Do
				С.Insert(Стр.Key, Стр.Value);EndDo
			;
			Return С;
		ElsIf TypeCollection = "Map" Then
			С=New Map;
			For Each Стр In Т Do
				С.Insert(Стр.Key, Стр.Value);EndDo
			;
			Return С;
		Else
			Return Т;
		EndIf;
	EndIf;
EndFunction

&AtServer
Function GetParameter(НаименованиеПараметра)
	ВыбОбъект=FormAttributeToValue("Object");
	Return ВыбОбъект.GetParameter(НаименованиеПараметра);
EndFunction // GetParameter()

&AtClient
Procedure SelectedTypeOnChange(Item)
	Parameters.ParameterType=SelectedType;
	УправлениеВидимостьюЭлементовФормы(SelectedType);
EndProcedure

&AtClient
Procedure ParameterNameOnChange(Item)
	If Not Parameters.Rename Then
		Parameters.ИмяПараметра=TrimAll(ParameterName);
	EndIf;
EndProcedure

&AtClient
Procedure AvailableTypesOnChange(Item)
	Item.Title=TypeOf(AvailableTypes);
EndProcedure


&AtClient
Procedure DefinedTypeTextEditEnd(Item, Text, ChoiceData, DataGetParameters, StandardProcessing)
	Parameters.ParameterType="DefinedType";
EndProcedure
