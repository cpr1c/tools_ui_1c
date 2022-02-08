#Region ОбработчикиСобытийФормы

&AtClient
Procedure OnOpen(Cancel)
	WindowsClient=UT_CommonClientServer.IsWindows();

	ОбновитьКлиент();
	ОбновитьСервер();

	Items.CurrentDirectoryOnServer.ChoiceList.LoadValues(HistoryOfChooseServer.UnloadValues());
	Items.CurrentDirectoryOnClient.ChoiceList.LoadValues(HistoryOfChooseClient.UnloadValues());
	
	УстановитьРамкуТекущейПанели();
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, СтандартнаяОбработка)
	WindowsServer=UT_CommonClientServer.IsWindows();
	PathParentOnClient=GetClientPathSeparator();
	PathParentOnServer=GetServerPathSeparator();
	CurrentFilesTable="FilesOnLeftPanel";

	ЗаполнитьПодменюСортировок();

	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, СтандартнаяОбработка,
		Items.ГруппаНижняяПанель);

EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовШапкиФормы

&AtClient
Procedure ТекущийКаталогСерверПриИзменении(Item)
	If Not IsBlankString(CurrentDirectoryOnServer) And Not Right(CurrentDirectoryOnServer, 1) = PathParentOnServer Then
		CurrentDirectoryOnServer = CurrentDirectoryOnServer + PathParentOnServer;
	EndIf;
	ОбновитьСервер();
	ОбновитьИсториюСервер();
EndProcedure

&AtClient
Procedure ТекущийКаталогКлиентПриИзменении(Item)
	If Not IsBlankString(CurrentDirectoryOnClient) And Not Right(CurrentDirectoryOnClient, 1) = PathParentOnClient Then
		CurrentDirectoryOnClient = CurrentDirectoryOnClient + PathParentOnClient;
	EndIf;
	ОбновитьКлиент();
	ОбновитьИсториюКлиент();
EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовТаблицыЛевойПанели

&AtClient
Procedure ФайлыЛеваяПанельВыбор(Item, ВыбраннаяСтрока, Field, СтандартнаяОбработка)
	ТаблицаФайловВыбор(True, Item, ВыбраннаяСтрока, Field, СтандартнаяОбработка);
EndProcedure

&AtClient
Procedure ФайлыЛеваяПанельПриАктивизацииЯчейки(Item)
	CurrentFilesTable=Item.Name;
	УстановитьРамкуТекущейПанели();
EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовТаблицыПравойПанели
&AtClient
Procedure ФайлыПраваяПанельВыбор(Item, ВыбраннаяСтрока, Field, СтандартнаяОбработка)
	ТаблицаФайловВыбор(False, Item, ВыбраннаяСтрока, Field, СтандартнаяОбработка);
EndProcedure
&AtClient
Procedure ФайлыПраваяПанельПриАктивизацииЯчейки(Item)
	CurrentFilesTable=Item.Name;
	УстановитьРамкуТекущейПанели();
EndProcedure

#EndRegion

#Region ОбработчикиКомандФормы

&AtClient
Procedure ТаблицаФайловВыбор(ЭтоЛеваяТаблица, Item, ВыбраннаяСтрока, Field, СтандартнаяОбработка)
	СтандартнаяОбработка = False;

	If ЭтоЛеваяТаблица Then
		GetCurrentDirectory=CurrentDirectoryOnClient;
		ТаблицаФайлов=FilesOnLeftPanel;
	Иначе
		GetCurrentDirectory=CurrentDirectoryOnServer;
		ТаблицаФайлов=FilesOnRightPanel;
	EndIf;

	CurrentData=ТаблицаФайлов.FindByID(ВыбраннаяСтрока);
	If CurrentData = Undefined Then
		Return;
	EndIf;
	If CurrentData.IsDirectory Then
		ПерейтиВКаталог(FilesOnLeftPanel, CurrentData.FullName, ЭтоЛеваяТаблица);
	Иначе
		BeginRunningApplication(UT_CommonClient.ApplicationRunEmptyNotifyDescription(),
			CurrentData.FullName, GetCurrentDirectory);
	EndIf;
EndProcedure

&AtClient
Procedure ОбновитьСервер(Command = Undefined)
	If Not WindowsServer And Not ValueIsFilled(CurrentDirectoryOnServer) Then
		CurrentDirectoryOnServer="/";
	EndIf;

	ОбновитьДеревоФайлов(False);
EndProcedure

&AtClient
Procedure ОбновитьКлиент(Command = Undefined)
	If Not WindowsClient And Not ValueIsFilled(CurrentDirectoryOnClient) Then
		CurrentDirectoryOnClient="/";
	EndIf;

	ОбновитьДеревоФайлов(True);
EndProcedure

&AtClient
Procedure ПерейтиСервер(Command)
	ИмяКаталога = StrGetLine(StrReplace(Command.Name, "_", Chars.LF), 2);
	CurrentDirectoryOnServer = ИмяКаталонаНаСервере(ИмяКаталога);
	ОбновитьСервер();
	ОбновитьИсториюСервер();
EndProcedure

&AtClient
Procedure ПерейтиКлиент(Command)
	ИмяКаталога = StrGetLine(StrReplace(Command.Name, "_", Chars.LF), 2);
	CurrentDirectoryOnClient = Eval(ИмяКаталога + "()");
	ОбновитьКлиент();
	ОбновитьИсториюКлиент();
EndProcedure

&AtClient
Procedure Goto_Desktop_Клиент(Command)
	МассивКаталогов = StrSplit(DocumentsDir(), PathParentOnClient);
	If IsBlankString(МассивКаталогов[МассивКаталогов.UBound()]) Then
		МассивКаталогов.Delete(МассивКаталогов.UBound());
	EndIf;
	МассивКаталогов[МассивКаталогов.UBound()] = "Desktop";
	Path = "";
	For Each ИмяКаталога In МассивКаталогов Do
		Path = Path + ИмяКаталога + PathParentOnClient;
	EndDo;
	CurrentDirectoryOnClient = Path;
	ОбновитьКлиент();
	ОбновитьИсториюКлиент();
EndProcedure

&AtClient
Procedure СкопироватьНаСервер(Command)

	КаталогИсточник = CurrentDirectoryOnClient;
	КаталогПриемник = CurrentDirectoryOnServer;
	If IsBlankString(КаталогПриемник) Then
		Return;
	EndIf;

	ЭлементТаблицы= Items.FilesOnLeftPanel;
	ТаблицаПанели = FilesOnLeftPanel;
	CurrentData = ЭлементТаблицы.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	МассивФайлов = New Array;
	For Each ИдентификаторСтроки In ЭлементТаблицы.SelectedRows Do
		СтрокаДерева = ТаблицаПанели.FindByID(ИдентификаторСтроки);
		If StrLen(СтрокаДерева.FullName) <= StrLen(КаталогИсточник) Then
			Return;
		EndIf;

		СтрокаСтруктура = New Structure("FullName,IsDirectory", СтрокаДерева.FullName, СтрокаДерева.IsDirectory);
		СтрокаСтруктура.Insert("АдресВХранилище", PutToTempStorage(
			New BinaryData(СтрокаСтруктура.FullName), UUID));

		МассивФайлов.Add(СтрокаСтруктура);
		If Not СтрокаСтруктура.IsDirectory Then
			Continue;
		EndIf;

		Result = НайтиВсеФайлыНаКлиенте(СтрокаДерева.FullName, PathParentOnClient, UUID);
		For Each СтрокаСтруктура In Result Do
			МассивФайлов.Add(СтрокаСтруктура);
		EndDo;
	EndDo;

	For сч = 0 To МассивФайлов.UBound() Do
		СтрокаСтруктура = МассивФайлов[сч];
		Status("Copy " + (сч + 1) + " из " + МассивФайлов.Count() + " : " + СтрокаСтруктура.FullName);

		КонечноеИмяФайла = КаталогПриемник + Mid(СтрокаСтруктура.FullName, StrLen(КаталогИсточник) + 1);

		If СтрокаСтруктура.IsDirectory Then
			File = New File(КонечноеИмяФайла);
			If Not File.Exists() Then
				СоздатьКаталогНаСервере(КонечноеИмяФайла);
			EndIf;
		Иначе
//			ДвоичныеДанные = Новый ДвоичныеДанные(СтрокаСтруктура.FullName);
//			АдресВХранилище = ПоместитьВоВременноеХранилище(ДвоичныеДанные, ЭтаФорма.УникальныйИдентификатор);
			РазвернутьФайлНаСервере(СтрокаСтруктура.АдресВХранилище, КонечноеИмяФайла);
		EndIf;

	EndDo;

	ОбновитьСервер();

EndProcedure

&AtClient
Procedure СкопироватьНаКлиент(Command)

	КаталогИсточник = CurrentDirectoryOnServer;
	КаталогПриемник = CurrentDirectoryOnClient;
	If IsBlankString(КаталогПриемник) Then
		Return;
	EndIf;

	ЭлементТаблицы = Items.FilesOnRightPanel;
	ТаблицаПанели = FilesOnRightPanel;
	CurrentData = ЭлементТаблицы.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	МассивФайлов = New Array;
	For Each ИдентификаторСтроки In ЭлементТаблицы.SelectedRows Do
		СтрокаДерева = ТаблицаПанели.FindByID(ИдентификаторСтроки);
		If StrLen(СтрокаДерева.FullName) <= StrLen(КаталогИсточник) Then
			Return;
		EndIf;

		СтрокаСтруктура = New Structure("FullName,IsDirectory", СтрокаДерева.FullName, СтрокаДерева.IsDirectory);
		СтрокаСтруктура.Insert("АдресВХранилище", ПоместитьВоВременноеХранилищеНаСервере(СтрокаСтруктура.FullName,
			UUID));

		МассивФайлов.Add(СтрокаСтруктура);
		If Not СтрокаСтруктура.IsDirectory Then
			Continue;
		EndIf;

		Result = НайтиВсеФайлыНаСервере(СтрокаДерева.FullName, PathParentOnServer, UUID);

		For Each СтрокаСтруктура In Result Do
			МассивФайлов.Add(СтрокаСтруктура);
		EndDo;
	EndDo;

	For сч = 0 To МассивФайлов.UBound() Do
		СтрокаСтруктура = МассивФайлов[сч];
		Status("Copy " + (сч + 1) + " из " + МассивФайлов.Count() + " : " + СтрокаСтруктура.FullName);

		КонечноеИмяФайла = КаталогПриемник + Mid(СтрокаСтруктура.FullName, StrLen(КаталогИсточник) + 1);

		If СтрокаСтруктура.IsDirectory Then
			File = New File(КонечноеИмяФайла);
			If Not File.Exists() Then
				CreateDirectory(КонечноеИмяФайла);
			EndIf;
		Иначе
//			АдресВХранилище = ПоместитьВоВременноеХранилищеНаСервере(СтрокаСтруктура.FullName,
//				ЭтаФорма.УникальныйИдентификатор);
			BinaryData = GetFromTempStorage(СтрокаСтруктура.АдресВХранилище);
			BinaryData.Write(КонечноеИмяФайла);
		EndIf;

	EndDo;

	ОбновитьКлиент();

EndProcedure

&AtClient
Procedure УдалитьНаКлиенте(Command)
	If IsBlankString(CurrentDirectoryOnClient) Then
		Return;
	EndIf;

	ЭлементТаблица = Items.FilesOnLeftPanel;
	ТаблицаПанели = FilesOnLeftPanel;

	CurrentData = ЭлементТаблица.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	For Each String In ЭлементТаблица.SelectedRows Do
		CurrentData = ТаблицаПанели.FindByID(String);
		DeleteFiles(CurrentData.FullName);
	EndDo;

	ОбновитьКлиент();
EndProcedure

&AtClient
Procedure УдалитьНаСервере(Command)
	If IsBlankString(CurrentDirectoryOnServer) Then
		Return;
	EndIf;

	ЭлементТаблица = Items.FilesOnRightPanel;
	ТаблицаПанели = FilesOnRightPanel;

	CurrentData = ЭлементТаблица.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	For Each String In ЭлементТаблица.SelectedRows Do
		CurrentData = ТаблицаПанели.FindByID(String);
		УдалитьФайлыНаСервере(CurrentData.FullName);
	EndDo;

	ОбновитьСервер();

EndProcedure

&AtClient
Procedure ПереместитьССервераНаКлиент(Command)
	СкопироватьНаКлиент(Undefined);
	УдалитьНаСервере(Undefined);
EndProcedure

&AtClient
Procedure ПереместитьСКлиентаНаСервер(Command)
	СкопироватьНаСервер(Undefined);
	УдалитьНаКлиенте(Undefined);
EndProcedure

&AtClient
Procedure ПереименоватьНаСервере(Command)
	If IsBlankString(CurrentDirectoryOnServer) Then
		Return;
	EndIf;

	ЭлементДерево = Items.FilesOnServer;

	CurrentData = ЭлементДерево.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	If CurrentData.GetParent() = Undefined Then
		Return;
	EndIf;

	НовоеИмя = CurrentData.Name + CurrentData.FileExtension;
	НовоеИмя = StrReplace(НовоеИмя, PathParentOnServer, "");
	If Not InputString(НовоеИмя) Then
		Return;
	EndIf;

	ПереименоватьФайлНаСервере(CurrentData.FullName, CurrentDirectoryOnServer + НовоеИмя, PathParentOnServer);

	ОбновитьСервер();
EndProcedure

&AtClient
Procedure ПереименоватьНаКлиенте(Command)
	If IsBlankString(CurrentDirectoryOnClient) Then
		Return;
	EndIf;

	ЭлементДерево = Items.FilesOnLeftPanel;

	CurrentData = ЭлементДерево.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	//If CurrentData.GetParent() = Undefined Then
	//	Return;
	//EndIf;

	НовоеИмя = CurrentData.Name + CurrentData.FileExtension;
	НовоеИмя = StrReplace(НовоеИмя, PathParentOnClient, "");
	If Not InputString(НовоеИмя) Then
		Return;
	EndIf;

	ПереименоватьФайлНаКлиенте(CurrentData.FullName, CurrentDirectoryOnServer + НовоеИмя, PathParentOnClient);

	ОбновитьКлиент();
EndProcedure

&AtClient
Procedure ШагНазадКлиент(Command)
	ШагНазад(True);
EndProcedure

&AtClient
Procedure ШагВпередКлиент(Command)
	ШагВперед(True);
EndProcedure

&AtClient
Procedure ШагВверхКлиент(Command)
	ПерейтиНаУровеньВыше(FilesOnLeftPanel, True);
EndProcedure
&AtClient
Procedure ШагНазадСервер(Command)
	ШагНазад(False);
EndProcedure

&AtClient
Procedure ШагВпередСервер(Command)
	ШагВперед(False);
EndProcedure

&AtClient
Procedure ШагВверхСервер(Command)
	ПерейтиНаУровеньВыше(FilesOnRightPanel, False);
EndProcedure

&AtClient
Procedure Копировать(Command)
	ЭтоЛеваяПанель=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	If ЭтоЛеваяПанель Then
		СкопироватьНаСервер(Commands.СкопироватьНаСервер);
	Иначе
		СкопироватьНаКлиент(Commands.СкопироватьНаКлиент);
	EndIf;
EndProcedure

&AtClient
Procedure Move(Command)
	ЭтоЛеваяПанель=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	If ЭтоЛеваяПанель Then
		ПереместитьСКлиентаНаСервер(Commands.ПереместитьСКлиентаНаСервер);
	Иначе
		ПереместитьССервераНаКлиент(Commands.ПереместитьССервераНаКлиент);
	EndIf;
EndProcedure

&AtClient
Procedure СоздатьКаталогКоманда(Command)
	ЭтоЛеваяПанель=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	ShowInputString(New NotifyDescription("СоздатьКаталогЗавершениеВводаНаименования", ThisObject,
		New Structure("ИмяТаблицыФайлов,ЭтоЛеваяПанель", CurrentFilesTable, ЭтоЛеваяПанель)), ,
		"Введите наименование нового каталога");
EndProcedure

&AtClient
Procedure Delete(Command)
	ТекДанные=Items[CurrentFilesTable].CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ЭтоЛеваяПанель=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	UT_CommonClient.ShowQuestionToUser(
		New NotifyDescription("УдалитьПослеПодтвержденияНеобходимости", ThisObject,
		New Structure("ЭтоЛеваяПанель,FullName", ЭтоЛеваяПанель, ТекДанные.FullName)), "Delete выбранный файл?",
		QuestionDialogMode.YesNo);
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_УстановитьПорядокСортировки(Command)
	ПорядокСортировки=Right(Command.Name, 4);

	ПрефиксЛевойПанели="ЛеваяПанельГруппаСортировка";
	ПрефиксПравойПанели="ПраваяПанельГруппаСортировка";

	ТаблицаДляСортировки=Undefined;
	ПрефиксИмени=Undefined;

	If StrFind(Command.Name, ПрефиксЛевойПанели) > 0 Then
		ТаблицаДляСортировки=FilesOnLeftPanel;
		ПрефиксИмени=ПрефиксЛевойПанели;
	ElsIf StrFind(Command.Name, ПрефиксПравойПанели) > 0 Then
		ТаблицаДляСортировки=FilesOnRightPanel;
		ПрефиксИмени=ПрефиксПравойПанели;
	EndIf;

	If ТаблицаДляСортировки = Undefined Then
		Return;
	EndIf;

	ИмяПоляСортировки=StrReplace(Command.Name, ПрефиксИмени, "");
	ИмяПоляСортировки=StrReplace(ИмяПоляСортировки, ПорядокСортировки, "");

	ТаблицаДляСортировки.Sort("IsDirectory УБЫВ, " + ИмяПоляСортировки + " " + ПорядокСортировки);

	For Each Эл In Items[Command.Name].Parent.ChildItems Do
		Эл.Check=False;
	EndDo;

	Items[Command.Name].Check=True;
//	ЭлементыДерева=FilesOnClient.ПолучитьЭлементы().	
EndProcedure

//@skip-warning
&AtClient
Procedure Подключаемый_ВыполнитьОбщуюКомандуИнструментов(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure


#EndRegion

#Region СлужебныеПроцедурыИФункции

&AtClient
Procedure УстановитьРамкуТекущейПанели()
	ЭтоЛеваяПанель=CurrentFilesTable = Items.FilesOnLeftPanel.Name;
	
	If ЭтоЛеваяПанель Then
		АктивнаяПанель=Items.FilesOnLeftPanel;
		НеАктивнаяПанель=Items.FilesOnRightPanel;
	Иначе
		АктивнаяПанель=Items.FilesOnRightPanel;
		НеАктивнаяПанель=Items.FilesOnLeftPanel;
	EndIf;
	
	АктивнаяПанель.BorderColor=WebColors.Red;
	НеАктивнаяПанель.BorderColor=New Color;
EndProcedure

&AtClient
Procedure УдалитьПослеПодтвержденияНеобходимости(РезультатВопроса, AdditionalParameters) Export
	If РезультатВопроса <> DialogReturnCode.Yes Then
		Return;
	EndIf;

	If AdditionalParameters.ЭтоЛеваяПанель Then

		BeginDeletingFiles(New NotifyDescription("УдалитьФайлЗавершение", ThisObject, AdditionalParameters),
			AdditionalParameters.FullName);
	Иначе
		УдалитьФайлыНаСервере(AdditionalParameters.FullName);
		УдалитьФайлЗавершение(AdditionalParameters);
	EndIf;
EndProcedure

&AtClient
Procedure УдалитьФайлЗавершение(AdditionalParameters) Export
	If AdditionalParameters.ЭтоЛеваяПанель Then
		ОбновитьКлиент();
	Иначе
		ОбновитьСервер();
	EndIf;

EndProcedure
&НаСервереБезКонтекста
Function СоздатьКаталогНаСервере(FullName)
	File=New File(FullName);
	If File.Exists() Then
		UT_CommonClientServer.MessageToUser("Такой каталог уже существует");

		Return Undefined;
	EndIf;

	CreateDirectory(File.FullName);

	Return File.FullName;
EndFunction

&AtClient
Procedure СоздатьКаталогЗавершениеВводаНаименования(String, AdditionalParameters) Export
	If String = Undefined Then
		Return;
	EndIf;

	If Not ValueIsFilled(String) Then
		Return;
	EndIf;

	ЭтоЛеваяПанель=AdditionalParameters.ЭтоЛеваяПанель;
	If ЭтоЛеваяПанель Then
		GetCurrentDirectory=CurrentDirectoryOnClient;
	Иначе
		GetCurrentDirectory=CurrentDirectoryOnServer;
	EndIf;

	
	//Проверяем существование каталога

	ДопПараметрыОповещения=AdditionalParameters;
	ДопПараметрыОповещения.Insert("GetCurrentDirectory", GetCurrentDirectory);

	ФайлПолноеИмя=GetCurrentDirectory + String;

	If ЭтоЛеваяПанель Then
		File=New File(ФайлПолноеИмя);
		ДопПараметрыОповещения.Insert("File", File);

		File.BeginCheckingExistence(
		New NotifyDescription("СоздатьКаталогЗавершениеПроверкиСуществованияНовогоКаталога", ThisObject,
			ДопПараметрыОповещения));
	Иначе
		Result=СоздатьКаталогНаСервере(ФайлПолноеИмя);
		If Result = Undefined Then
			Return;
		EndIf;

		СоздатьКаталогЗавершениеСозданияКаталога(Result, ДопПараметрыОповещения);
	EndIf;

EndProcedure

&AtClient
Procedure СоздатьКаталогЗавершениеПроверкиСуществованияНовогоКаталога(Exists, AdditionalParameters) Export
	If Exists Then
		UT_CommonClientServer.MessageToUser("Такой каталог уже существует");
		Return;
	EndIf;

	BeginCreatingDirectory(New NotifyDescription("СоздатьКаталогЗавершениеСозданияКаталога", ThisObject,
		AdditionalParameters), AdditionalParameters.File.FullName);
EndProcedure

&AtClient
Procedure СоздатьКаталогЗавершениеСозданияКаталога(ИмяКаталога, AdditionalParameters) Export

	If AdditionalParameters.ЭтоЛеваяПанель Then
		CurrentDirectoryOnClient=ИмяКаталога;
		ОбновитьКлиент();
	Иначе
		CurrentDirectoryOnServer=ИмяКаталога;
		ОбновитьСервер();
	EndIf;
EndProcedure

&AtClient
Procedure ШагНазад(ЭтоЛеваяТаблица)
	If ЭтоЛеваяТаблица Then
		ИмяПоляТекущегоКаталога="CurrentDirectoryOnClient";
	Иначе
		ИмяПоляТекущегоКаталога="CurrentDirectoryOnServer";
	EndIf;

	ЭлементСписок = Items[ИмяПоляТекущегоКаталога].ChoiceList;
	CurrentValue = ThisObject[ИмяПоляТекущегоКаталога];

	НайденныйЭлемент = ЭлементСписок.FindByValue(CurrentValue);
	If НайденныйЭлемент = Undefined Then
		Return;
	EndIf;
	IndexOf = ЭлементСписок.IndexOf(НайденныйЭлемент);
	If IndexOf + 1 < ЭлементСписок.Count() - 1 Then
		ThisObject[ИмяПоляТекущегоКаталога] = ЭлементСписок[IndexOf + 1].Value;
		If ЭтоЛеваяТаблица Then
			ОбновитьКлиент();
		Иначе
			ОбновитьСервер();
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure ШагВперед(ЭтоЛеваяТаблица)
	If ЭтоЛеваяТаблица Then
		ИмяПоляТекущегоКаталога="CurrentDirectoryOnClient";
	Иначе
		ИмяПоляТекущегоКаталога="CurrentDirectoryOnServer";
	EndIf;

	ЭлементСписок = Items[ИмяПоляТекущегоКаталога].ChoiceList;
	CurrentValue = ThisObject[ИмяПоляТекущегоКаталога];

	НайденныйЭлемент = ЭлементСписок.FindByValue(CurrentValue);
	If НайденныйЭлемент = Undefined Then
		Return;
	EndIf;
	IndexOf = ЭлементСписок.IndexOf(НайденныйЭлемент);
	If IndexOf > 0 Then
		ThisObject[ИмяПоляТекущегоКаталога] = ЭлементСписок[IndexOf - 1].Value;
		If ЭтоЛеваяТаблица Then
			ОбновитьКлиент();
		Иначе
			ОбновитьСервер();
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure ПерейтиНаУровеньВыше(ТаблицаФайлов, ЭтоЛеваяТаблица)
	ПерейтиВКаталог(ТаблицаФайлов, "..", ЭтоЛеваяТаблица);
EndProcedure

&AtClient
Procedure ПерейтиВКаталог(ТаблицаФайлов, ПолноеИмяНовогоКаталога, ЭтоЛеваяТаблица)
	If ЭтоЛеваяТаблица Then
		ИмяПоляКаталога="CurrentDirectoryOnClient";
		РазделительПути=PathParentOnClient;
	Иначе
		ИмяПоляКаталога="CurrentDirectoryOnServer";
		РазделительПути=PathParentOnServer;
	EndIf;

	GetCurrentDirectory=ThisObject[ИмяПоляКаталога];
	НовыйКаталог="";

	If ПолноеИмяНовогоКаталога = ".." Then
		МассивСтрокКаталога=StrSplit(GetCurrentDirectory, РазделительПути, True);
		If Not ValueIsFilled(МассивСтрокКаталога[МассивСтрокКаталога.Count()-1]) Then
			МассивСтрокКаталога.Delete(МассивСтрокКаталога.Count() - 1);
		EndIf;
		
		If МассивСтрокКаталога.Count() = 0 Then
			НовыйКаталог="";
		Иначе
			
			МассивСтрокКаталога.Delete(МассивСтрокКаталога.Count() - 1);

			//МассивСтрокКаталога.Insert(0, "");
			МассивСтрокКаталога.Add("");

			НовыйКаталог=StrConcat(МассивСтрокКаталога, РазделительПути);
		EndIf;
	Иначе
		НовыйКаталог = ПолноеИмяНовогоКаталога;
	EndIf;

	ThisObject[ИмяПоляКаталога] = НовыйКаталог;

	If ЭтоЛеваяТаблица Then
		ОбновитьКлиент();
		ОбновитьИсториюКлиент();
	Иначе
		ОбновитьСервер();

		ОбновитьИсториюСервер();
	EndIf;

EndProcedure
&AtServer
Procedure ЗаполнитьПодменюСортировок()
	ПоляУпорядочивания=New Structure;
	ПоляУпорядочивания.Insert("Name", "Name");
	ПоляУпорядочивания.Insert("FileExtension", "FileExtension");
	ПоляУпорядочивания.Insert("ModifiedDate", "Date изменения");
	ПоляУпорядочивания.Insert("Size", "Size");

	НаправленияСортировки=New Structure;
	НаправленияСортировки.Insert("ВОЗР", " +");
	НаправленияСортировки.Insert("УБЫВ", " -");

	МассивПодменю=New Array;
	МассивПодменю.Add(Items.ЛеваяПанельГруппаСортировка);
	МассивПодменю.Add(Items.ПраваяПанельГруппаСортировка);

	For Each ТекПодменю In МассивПодменю Do
		For Each ПолеУпорядочивания In ПоляУпорядочивания Do
			For Each Heading In НаправленияСортировки Do
				//Сначала добавляем команду, а потом кнопку
				ОписаниеКоманды=UT_Forms.ButtonCommandNewDescription();
				ОписаниеКоманды.Name=ТекПодменю.Name + ПолеУпорядочивания.Key + Heading.Key;
				ОписаниеКоманды.Title=ПолеУпорядочивания.Value + Heading.Value;
				ОписаниеКоманды.Action="Подключаемый_УстановитьПорядокСортировки";
				ОписаниеКоманды.ItemParent=ТекПодменю;
				ОписаниеКоманды.Picture=New Picture;
				ОписаниеКоманды.CommandName=ОписаниеКоманды.Name;

				UT_Forms.CreateCommandByDescription(ThisObject, ОписаниеКоманды);
				UT_Forms.CreateButtonByDescription(ThisObject, ОписаниеКоманды);
			EndDo;
		EndDo;

		Items[ТекПодменю.Name + "NameВОЗР"].Check=True;
	EndDo;
EndProcedure

&НаСервереБезКонтекста
Procedure РазвернутьФайлНаСервере(АдресВХранилище, КонечноеИмяФайла)
	BinaryData = GetFromTempStorage(АдресВХранилище);
	BinaryData.Write(КонечноеИмяФайла);
EndProcedure

&AtClient
Procedure ОбновитьДеревоФайлов(AtClient = True)
	If AtClient = False Then
		ЭлементДерево = Items.FilesOnLeftPanel;
		ТаблицаФайловКаталога = FilesOnRightPanel;
		GetCurrentDirectory = CurrentDirectoryOnServer;
		ФайлыТекущегоКаталога = ПолучитьСодержимоеКаталогаНаСервере(GetCurrentDirectory, PathParentOnServer,
			WindowsServer);
		ТекущийРазделительПути=PathParentOnServer;
		ЭтоWindows=WindowsServer;
	Иначе
		ЭлементДерево = Items.FilesOnLeftPanel;
		ТаблицаФайловКаталога = FilesOnLeftPanel;
		GetCurrentDirectory = CurrentDirectoryOnClient;
		ФайлыТекущегоКаталога = ПолучитьСодержимоеКаталогаНаКлиенте(GetCurrentDirectory);
		ТекущийРазделительПути=PathParentOnClient;
		ЭтоWindows=WindowsClient;

	EndIf;

	ТаблицаФайловКаталога.Clear();

//	ТекущийРодитель = Дерево;
	FullName = "";
	ПутьДляРазбора = StrReplace(GetCurrentDirectory, ТекущийРазделительПути + ТекущийРазделительПути, ":::");
	PictureIndex = 6;
	If IsBlankString(GetCurrentDirectory) And ЭтоWindows Then
		If ЭтоWindows Then
			If AtClient Then
				Диски = ПолучитьСписокДисковWindowsAtClient(ТекущийРазделительПути);
			Иначе
				Диски = ПолучитьСписокДисковWindowsAtServer(ТекущийРазделительПути);
			EndIf;
			For Each ИмяДиска In Диски Do
				НоваяСтрока = ТаблицаФайловКаталога.Add();
				НоваяСтрока.PictureIndex = 2;
				НоваяСтрока.Name = ИмяДиска;
				НоваяСтрока.IsDirectory = True;
				НоваяСтрока.FullName = НоваяСтрока.Name;
			EndDo;

			Return;

		EndIf;
//	ИначеЕсли Не ЭтоWindows Тогда
//		ТекущийРодитель = ТекущийРодитель.ПолучитьЭлементы().Добавить();
//		ТекущийРодитель.PictureIndex = PictureIndex;
//		ТекущийРодитель.Name = ТекущийРазделительПути;
//		ТекущийРодитель.IsDirectory = Истина;
//		ТекущийРодитель.FullName = ТекущийРазделительПути;
//		PictureIndex = 1;
//
//		Если СтрНачинаетсяС(ПутьДляРазбора, ТекущийРазделительПути) Тогда
//			ПутьДляРазбора=Сред(ПутьДляРазбора, 2);
//		КонецЕсли;
	EndIf;

//	МассивТекущийПуть = СтрРазделить(ПутьДляРазбора, ТекущийРазделительПути);//РазложитьСтрокуВМассивПодстрок(ПутьДляРазбора, ТекущийРазделительПути);
//	Для Каждого ИмяКаталога Из МассивТекущийПуть Цикл
//		Если ПустаяСтрока(ИмяКаталога) Тогда
//			Прервать;
//		КонецЕсли;
//
//		ИмяКаталога = СтрЗаменить(ИмяКаталога, ":::", ТекущийРазделительПути + ТекущийРазделительПути);
//
//		FullName = FullName + ИмяКаталога + ТекущийРазделительПути;
//		ТекущийРодитель = ТекущийРодитель.ПолучитьЭлементы().Добавить();
//		ТекущийРодитель.PictureIndex = PictureIndex;
//		ТекущийРодитель.Name = ИмяКаталога + ТекущийРазделительПути;
//		ТекущийРодитель.IsDirectory = Истина;
//		ТекущийРодитель.FullName = ТекущийРазделительПути + FullName;
//		PictureIndex = 1;
//	КонецЦикла;

	For Each СтрокаСтруктура In ФайлыТекущегоКаталога Do
		FillPropertyValues(ТаблицаФайловКаталога.Add(), СтрокаСтруктура);
	EndDo;

	ТаблицаФайловКаталога.Sort("IsDirectory УБЫВ, Name");
//	Если ТипЗнч(ТекущийРодитель) = Тип("ДанныеФормыЭлементДерева") Тогда
//		ЭлементДерево.ТекущаяСтрока = ТекущийРодитель.ПолучитьИдентификатор();
//		ЭлементДерево.Развернуть(ЭлементДерево.ТекущаяСтрока);
//	КонецЕсли;

	If ValueIsFilled(GetCurrentDirectory) And GetCurrentDirectory <> ТекущийРазделительПути Then
		НоваяСтрока = ТаблицаФайловКаталога.Insert(0);
		НоваяСтрока.PictureIndex = 2;
		НоваяСтрока.Name = "[..]";
		НоваяСтрока.IsDirectory = True;
		НоваяСтрока.FullName = "..";
	EndIf;
EndProcedure

&AtClient
Procedure ОбновитьИсториюКлиент()
	UpdateHistory(True);
EndProcedure

&AtClient
Procedure ОбновитьИсториюСервер()
	UpdateHistory(False);
EndProcedure
&AtClient
Procedure UpdateHistory(AtClient = True)
	If AtClient = False Then
		GetCurrentDirectory = CurrentDirectoryOnServer;
		ЭлементТекущийКаталог = Items.CurrentDirectoryOnServer;
		СписокИстория = HistoryOfChooseServer;
	Иначе
		GetCurrentDirectory = CurrentDirectoryOnClient;
		ЭлементТекущийКаталог = Items.CurrentDirectoryOnClient;
		СписокИстория = HistoryOfChooseClient;
	EndIf;

	НайденныйЭлемент = СписокИстория.FindByValue(GetCurrentDirectory);
	If Not НайденныйЭлемент = Undefined Then
		СписокИстория.Delete(НайденныйЭлемент);
	EndIf;
	СписокИстория.Insert(0, GetCurrentDirectory);

	РазмерСпискаИстории = 25;
	While РазмерСпискаИстории < СписокИстория.Count() Do
		СписокИстория.Delete(СписокИстория.Count() - 1);
	EndDo;

	ЭлементТекущийКаталог.ChoiceList.LoadValues(СписокИстория.UnloadValues());
EndProcedure

&НаСервереБезКонтекста
Function ПолучитьСодержимоеКаталогаНаСервере(Directory, РазделительПути, ЭтоWindows)
	Return ПолучитьСодержимоеКаталога(Directory, РазделительПути, ЭтоWindows);
EndFunction

&AtClient
Function ПолучитьСодержимоеКаталогаНаКлиенте(Directory)
	Return ПолучитьСодержимоеКаталога(Directory, PathParentOnClient, WindowsClient);
EndFunction

&НаКлиентеНаСервереБезКонтекста
Function ПолучитьСодержимоеКаталога(Directory, РазделительПути, ЭтоWindows)
	Result = New Array;

	Files = FindFiles(Directory, "*", False);
	For Each File In Files Do
		If False Then
			File = New File;
		EndIf;

//		Если Не ЭтоWindows И Лев(Файл.FullName, 2) = "//" Тогда
//			Файл=Новый Файл(Сред(Файл.FullName, 2));
//		Иначе
//			Файл
//		КонецЕсли;

//		Если Не Файл.Существует() Тогда
//			Продолжить
//		КонецЕсли;

		If Not File.Exists() Then
			IsDirectory=False;
		Иначе
			IsDirectory=File.IsDirectory();
		EndIf;

		FullFileName=File.FullName + ?(IsDirectory, РазделительПути, "");
		If Not ЭтоWindows And Left(File.FullName, 2) = "//" Then
			FullFileName=Mid(File.FullName, 2);
		EndIf;

		If FullFileName = "/./" Или FullFileName = "/../" 
			Или FullFileName="/." Или FullFileName= "/.." Then
			Continue;
		EndIf;

		СтрокаСтруктура = New Structure;

		СтрокаСтруктура.Insert("IsDirectory", IsDirectory);
		СтрокаСтруктура.Insert("FullName", FullFileName);

		If СтрокаСтруктура.IsDirectory Then
			If ValueIsFilled(File.Name) Then
				FileName=File.Name;
			Иначе
				FileName=StrReplace(File.Path, РазделительПути, "");
			EndIf;

			FileName=FileName + РазделительПути;
		Иначе
			FileName=File.BaseName;
		EndIf;

		If Not ValueIsFilled(FileName) Then
			FileName=FullFileName;

			If Not СтрокаСтруктура.IsDirectory And StrStartsWith(FileName, РазделительПути) Then
				FileName=Mid(FileName, 2);
			EndIf;
		EndIf;
		СтрокаСтруктура.Insert("Name", FileName);
		СтрокаСтруктура.Insert("FileExtension", ?(СтрокаСтруктура.IsDirectory, "", File.Extension));
		СтрокаСтруктура.Insert("PictureIndex", PictureIndex(СтрокаСтруктура.FileExtension,
			СтрокаСтруктура.IsDirectory));

		Try
			СтрокаСтруктура.Insert("ModifiedDate", File.GetModificationTime());
		Except
			СтрокаСтруктура.Insert("ModifiedDate", '00010101');
		EndTry;

		If Not СтрокаСтруктура.IsDirectory Then
			Try
				СтрокаСтруктура.Insert("Size", File.Size() / 1000);
			Except
				СтрокаСтруктура.Insert("Size", 0);
			EndTry;
		EndIf;
		СтрокаСтруктура.Insert("Presentation", Format(СтрокаСтруктура.ModifiedDate, "ДФ='yyyy-MM-dd HH:MM:ss'"));

		Result.Add(СтрокаСтруктура);
	EndDo;

//	Результат.СортироватьПоПредставлению(НаправлениеСортировки.Убыв);
//	Возврат Результат.ВыгрузитьЗначения();

	Return Result;
EndFunction

&НаКлиентеНаСервереБезКонтекста
Function PictureIndex(Знач FileExtension, IsDirectory)
	If IsDirectory Then
		Return 2;
	Иначе
		Return UT_CommonClientServer.GetFileIconIndex(FileExtension);
	EndIf;
EndFunction

&НаКлиентеНаСервереБезКонтекста
Function ПолучитьСписокДисковWindows(РазделительПути)
	Result = New Array;

	For сч = 0 To 25 Do
		БукваДиска = Char(CharCode("A") + сч) + ":" + РазделительПути;
		If FindFiles(БукваДиска).Count() > 0 Then
			Result.Add(БукваДиска);
		EndIf;
	EndDo;

	Return Result;
EndFunction

&НаСервереБезКонтекста
Function ПолучитьСписокДисковWindowsAtServer(РазделительПути)
	Return ПолучитьСписокДисковWindows(РазделительПути);
EndFunction

&AtClient
Function ПолучитьСписокДисковWindowsAtClient(РазделительПути)
	Return ПолучитьСписокДисковWindows(РазделительПути);
EndFunction


&НаСервереБезКонтекста
Function ИмяКаталонаНаСервере(ИмяКаталога)
	Return Eval(ИмяКаталога + "()");
EndFunction

&НаКлиентеНаСервереБезКонтекста
Function FileSize(РазмерФайлаВБайтах, ЕдиницаИзмерения)
	ЕдиницаИзмерения = "КБ";
	Return РазмерФайлаВБайтах / 1000;
EndFunction

&НаСервереБезКонтекста
Procedure УдалитьФайлыНаСервере(FileName)
	DeleteFiles(FileName);
EndProcedure

&НаСервереБезКонтекста
Function ПоместитьВоВременноеХранилищеНаСервере(ИсходныйФайл, ИдентификаторФормы)
	BinaryData = New BinaryData(ИсходныйФайл);
	АдресВХранилище = PutToTempStorage(BinaryData, ИдентификаторФормы);
	Return АдресВХранилище;
EndFunction

&НаСервереБезКонтекста
Function НайтиВсеФайлыНаСервере(GetCurrentDirectory, РазделительПути, УникальныйИдентификаторФормы)
	Result = New Array;

	НайденныеФайлы = FindFiles(GetCurrentDirectory, "*", True);
	For Each File In НайденныеФайлы Do
		СтрокаСтруктура = New Structure;
		Result.Add(СтрокаСтруктура);

		СтрокаСтруктура.Insert("IsDirectory", File.IsDirectory());
		СтрокаСтруктура.Insert("FullName", File.FullName + ?(СтрокаСтруктура.IsDirectory, РазделительПути, ""));
		СтрокаСтруктура.Insert("АдресВХранилище", PutToTempStorage(
			New BinaryData(СтрокаСтруктура.FullName), УникальныйИдентификаторФормы));
	EndDo;

	Return Result;
EndFunction

&AtClient
Function НайтиВсеФайлыНаКлиенте(GetCurrentDirectory, РазделительПути, УникальныйИдентификаторФормы)
	Result = New Array;

	НайденныеФайлы = FindFiles(GetCurrentDirectory, "*", True);
	For Each File In НайденныеФайлы Do
		СтрокаСтруктура = New Structure;
		Result.Add(СтрокаСтруктура);

		СтрокаСтруктура.Insert("IsDirectory", File.IsDirectory());
		СтрокаСтруктура.Insert("FullName", File.FullName + ?(СтрокаСтруктура.IsDirectory, РазделительПути, ""));
		СтрокаСтруктура.Insert("АдресВХранилище", PutToTempStorage(
			New BinaryData(СтрокаСтруктура.FullName), УникальныйИдентификаторФормы));

	EndDo;

	Return Result;
EndFunction

&НаСервереБезКонтекста
Procedure ПереименоватьФайлНаСервере(ИмяФайлаИсточника, ИмяФайлаПриемника, РазделительПути)
	File = New File(ИмяФайлаИсточника);
	If File.IsFile() Then
		MoveFile(ИмяФайлаИсточника, ИмяФайлаПриемника);
	Иначе
		МассивСлов = StrSplit(ИмяФайлаПриемника, РазделительПути);
		If IsBlankString(МассивСлов[МассивСлов.UBound()]) Then
			МассивСлов.Delete(МассивСлов.UBound());
		EndIf;
		//ФСО = New COMObject("Scripting.FileSystemObject");

		//ФСО.GetFolder(ИмяФайлаИсточника).Name = МассивСлов[МассивСлов.UBound()];
	EndIf;

EndProcedure

&AtClient
Procedure ПереименоватьФайлНаКлиенте(ИмяФайлаИсточника, ИмяФайлаПриемника, РазделительПути)
	File = New File(ИмяФайлаИсточника);
	//If File.IsFile() Then
		MoveFile(ИмяФайлаИсточника, ИмяФайлаПриемника);
	//Иначе
	//	МассивСлов = StrSplit(ИмяФайлаПриемника, РазделительПути);
	//	If IsBlankString(МассивСлов[МассивСлов.UBound()]) Then
	//		МассивСлов.Delete(МассивСлов.UBound());
	//	EndIf;
	//	//ФСО = New COMObject("Scripting.FileSystemObject");

	//	//ФСО.GetFolder(ИмяФайлаИсточника).Name = МассивСлов[МассивСлов.UBound()];
	//EndIf;

EndProcedure


#EndRegion