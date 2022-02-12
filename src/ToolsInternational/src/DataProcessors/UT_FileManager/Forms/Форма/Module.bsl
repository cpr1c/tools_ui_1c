#Region FormEventHandlers

&AtClient
Procedure OnOpen(Cancel)
	WindowsClient=UT_CommonClientServer.IsWindows();

	UpdateAtClient();
	UpdateAtServer();

	Items.CurrentDirectoryOnServer.ChoiceList.LoadValues(HistoryOfChooseServer.UnloadValues());
	Items.CurrentDirectoryOnClient.ChoiceList.LoadValues(HistoryOfChooseClient.UnloadValues());
	
	УстановитьРамкуТекущейПанели();
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	WindowsServer=UT_CommonClientServer.IsWindows();
	PathParentOnClient=GetClientPathSeparator();
	PathParentOnServer=GetServerPathSeparator();
	CurrentFilesTable="FilesOnLeftPanel";

	ЗаполнитьПодменюСортировок();

	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing,
		Items.BottomPanel);

EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовШапкиФормы

&AtClient
Procedure ТекущийКаталогСерверПриИзменении(Item)
	If Not IsBlankString(CurrentDirectoryOnServer) And Not Right(CurrentDirectoryOnServer, 1) = PathParentOnServer Then
		CurrentDirectoryOnServer = CurrentDirectoryOnServer + PathParentOnServer;
	EndIf;
	UpdateAtServer();
	ОбновитьИсториюСервер();
EndProcedure

&AtClient
Procedure ТекущийКаталогКлиентПриИзменении(Item)
	If Not IsBlankString(CurrentDirectoryOnClient) And Not Right(CurrentDirectoryOnClient, 1) = PathParentOnClient Then
		CurrentDirectoryOnClient = CurrentDirectoryOnClient + PathParentOnClient;
	EndIf;
	UpdateAtClient();
	ОбновитьИсториюКлиент();
EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовТаблицыЛевойПанели

&AtClient
Procedure ФайлыЛеваяПанельВыбор(Item, ВыбраннаяСтрока, Field, StandardProcessing)
	ТаблицаФайловВыбор(True, Item, ВыбраннаяСтрока, Field, StandardProcessing);
EndProcedure

&AtClient
Procedure ФайлыЛеваяПанельПриАктивизацииЯчейки(Item)
	CurrentFilesTable=Item.Name;
	УстановитьРамкуТекущейПанели();
EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовТаблицыПравойПанели
&AtClient
Procedure ФайлыПраваяПанельВыбор(Item, ВыбраннаяСтрока, Field, StandardProcessing)
	ТаблицаФайловВыбор(False, Item, ВыбраннаяСтрока, Field, StandardProcessing);
EndProcedure
&AtClient
Procedure ФайлыПраваяПанельПриАктивизацииЯчейки(Item)
	CurrentFilesTable=Item.Name;
	УстановитьРамкуТекущейПанели();
EndProcedure

#EndRegion

#Region ОбработчикиКомандФормы

&AtClient
Procedure ТаблицаФайловВыбор(ЭтоЛеваяТаблица, Item, ВыбраннаяСтрока, Field, StandardProcessing)
	StandardProcessing = False;

	If ЭтоЛеваяТаблица Then
		GetCurrentDirectory=CurrentDirectoryOnClient;
		ТаблицаФайлов=FilesOnLeftPanel;
	Else
		GetCurrentDirectory=CurrentDirectoryOnServer;
		ТаблицаФайлов=FilesOnRightPanel;
	EndIf;

	CurrentData=ТаблицаФайлов.FindByID(ВыбраннаяСтрока);
	If CurrentData = Undefined Then
		Return;
	EndIf;
	If CurrentData.IsDirectory Then
		ПерейтиВКаталог(FilesOnLeftPanel, CurrentData.FullName, ЭтоЛеваяТаблица);
	Else
		BeginRunningApplication(UT_CommonClient.ApplicationRunEmptyNotifyDescription(),
			CurrentData.FullName, GetCurrentDirectory);
	EndIf;
EndProcedure

&AtClient
Procedure UpdateAtServer(Command = Undefined)
	If Not WindowsServer And Not ValueIsFilled(CurrentDirectoryOnServer) Then
		CurrentDirectoryOnServer="/";
	EndIf;

	ОбновитьДеревоФайлов(False);
EndProcedure

&AtClient
Procedure UpdateAtClient(Command = Undefined)
	If Not WindowsClient And Not ValueIsFilled(CurrentDirectoryOnClient) Then
		CurrentDirectoryOnClient="/";
	EndIf;

	ОбновитьДеревоФайлов(True);
EndProcedure

&AtClient
Procedure GotoAtServer(Command)
	ИмяКаталога = StrGetLine(StrReplace(Command.Name, "_", Chars.LF), 2);
	CurrentDirectoryOnServer = ИмяКаталонаНаСервере(ИмяКаталога);
	UpdateAtServer();
	ОбновитьИсториюСервер();
EndProcedure

&AtClient
Procedure GotoAtClient(Command)
	ИмяКаталога = StrGetLine(StrReplace(Command.Name, "_", Chars.LF), 2);
	CurrentDirectoryOnClient = Eval(ИмяКаталога + "()");
	UpdateAtClient();
	ОбновитьИсториюКлиент();
EndProcedure

&AtClient
Procedure GotoDesktopClient(Command)
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
	UpdateAtClient();
	ОбновитьИсториюКлиент();
EndProcedure

&AtClient
Procedure CopyToServer(Command)

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
		Else
//			ДвоичныеДанные = Новый ДвоичныеДанные(СтрокаСтруктура.FullName);
//			АдресВХранилище = ПоместитьВоВременноеХранилище(ДвоичныеДанные, ЭтаФорма.УникальныйИдентификатор);
			РазвернутьФайлНаСервере(СтрокаСтруктура.АдресВХранилище, КонечноеИмяФайла);
		EndIf;

	EndDo;

	UpdateAtServer();

EndProcedure

&AtClient
Procedure CopyToClient(Command)

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
		Else
//			АдресВХранилище = ПоместитьВоВременноеХранилищеНаСервере(СтрокаСтруктура.FullName,
//				ЭтаФорма.УникальныйИдентификатор);
			BinaryData = GetFromTempStorage(СтрокаСтруктура.АдресВХранилище);
			BinaryData.Write(КонечноеИмяФайла);
		EndIf;

	EndDo;

	UpdateAtClient();

EndProcedure

&AtClient
Procedure DeleteAtClient(Command)
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

	UpdateAtClient();
EndProcedure

&AtClient
Procedure DeleteAtServer(Command)
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

	UpdateAtServer();

EndProcedure

&AtClient
Procedure MoveFromServerToClient(Command)
	CopyToClient(Undefined);
	DeleteAtServer(Undefined);
EndProcedure

&AtClient
Procedure MoveFromClientToServer(Command)
	CopyToServer(Undefined);
	DeleteAtClient(Undefined);
EndProcedure

&AtClient
Procedure RenameAtServer(Command)
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

	UpdateAtServer();
EndProcedure

&AtClient
Procedure RenameAtClient(Command)
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

	UpdateAtClient();
EndProcedure

&AtClient
Procedure StepBackAtClient(Command)
	ШагНазад(True);
EndProcedure

&AtClient
Procedure StepForwardAtClient(Command)
	ШагВперед(True);
EndProcedure

&AtClient
Procedure StepUpAtClient(Command)
	ПерейтиНаУровеньВыше(FilesOnLeftPanel, True);
EndProcedure
&AtClient
Procedure StepBackAtServer(Command)
	ШагНазад(False);
EndProcedure

&AtClient
Procedure StepForwardAtServer(Command)
	ШагВперед(False);
EndProcedure

&AtClient
Procedure StepUpAtServer(Command)
	ПерейтиНаУровеньВыше(FilesOnRightPanel, False);
EndProcedure

&AtClient
Procedure Copy(Command)
	ЭтоЛеваяПанель=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	If ЭтоЛеваяПанель Then
		CopyToServer(Commands.CopyToServer);
	Else
		CopyToClient(Commands.CopyToClient);
	EndIf;
EndProcedure

&AtClient
Procedure Move(Command)
	ЭтоЛеваяПанель=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	If ЭтоЛеваяПанель Then
		MoveFromClientToServer(Commands.MoveFromClientToServer);
	Else
		MoveFromServerToClient(Commands.MoveFromServerToClient);
	EndIf;
EndProcedure

&AtClient
Procedure CreateDirectory_Command(Command)
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
Procedure Attachable_SetSortOrder(Command)
	ПорядокСортировки=Right(Command.Name, 4);

	ПрефиксЛевойПанели="SortGroupOfLeftPanel";
	ПрефиксПравойПанели="SortGroupOfRightPanel";

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
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure


#EndRegion

#Region Private

&AtClient
Procedure УстановитьРамкуТекущейПанели()
	ЭтоЛеваяПанель=CurrentFilesTable = Items.FilesOnLeftPanel.Name;
	
	If ЭтоЛеваяПанель Then
		АктивнаяПанель=Items.FilesOnLeftPanel;
		НеАктивнаяПанель=Items.FilesOnRightPanel;
	Else
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
	Else
		УдалитьФайлыНаСервере(AdditionalParameters.FullName);
		УдалитьФайлЗавершение(AdditionalParameters);
	EndIf;
EndProcedure

&AtClient
Procedure УдалитьФайлЗавершение(AdditionalParameters) Export
	If AdditionalParameters.ЭтоЛеваяПанель Then
		UpdateAtClient();
	Else
		UpdateAtServer();
	EndIf;

EndProcedure
&AtServerNoContext
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
	Else
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
	Else
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
		UpdateAtClient();
	Else
		CurrentDirectoryOnServer=ИмяКаталога;
		UpdateAtServer();
	EndIf;
EndProcedure

&AtClient
Procedure ШагНазад(ЭтоЛеваяТаблица)
	If ЭтоЛеваяТаблица Then
		ИмяПоляТекущегоКаталога="CurrentDirectoryOnClient";
	Else
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
			UpdateAtClient();
		Else
			UpdateAtServer();
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure ШагВперед(ЭтоЛеваяТаблица)
	If ЭтоЛеваяТаблица Then
		ИмяПоляТекущегоКаталога="CurrentDirectoryOnClient";
	Else
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
			UpdateAtClient();
		Else
			UpdateAtServer();
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
	Else
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
		Else
			
			МассивСтрокКаталога.Delete(МассивСтрокКаталога.Count() - 1);

			//МассивСтрокКаталога.Insert(0, "");
			МассивСтрокКаталога.Add("");

			НовыйКаталог=StrConcat(МассивСтрокКаталога, РазделительПути);
		EndIf;
	Else
		НовыйКаталог = ПолноеИмяНовогоКаталога;
	EndIf;

	ThisObject[ИмяПоляКаталога] = НовыйКаталог;

	If ЭтоЛеваяТаблица Then
		UpdateAtClient();
		ОбновитьИсториюКлиент();
	Else
		UpdateAtServer();

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
	МассивПодменю.Add(Items.SortGroupOfLeftPanel);
	МассивПодменю.Add(Items.SortGroupOfRightPanel);

	For Each ТекПодменю In МассивПодменю Do
		For Each ПолеУпорядочивания In ПоляУпорядочивания Do
			For Each Heading In НаправленияСортировки Do
				//Сначала добавляем команду, а потом кнопку
				ОписаниеКоманды=UT_Forms.ButtonCommandNewDescription();
				ОписаниеКоманды.Name=ТекПодменю.Name + ПолеУпорядочивания.Key + Heading.Key;
				ОписаниеКоманды.Title=ПолеУпорядочивания.Value + Heading.Value;
				ОписаниеКоманды.Action="Attachable_SetSortOrder";
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

&AtServerNoContext
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
	Else
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
			Else
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
	Else
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

&AtServerNoContext
Function ПолучитьСодержимоеКаталогаНаСервере(Directory, РазделительПути, ЭтоWindows)
	Return ПолучитьСодержимоеКаталога(Directory, РазделительПути, ЭтоWindows);
EndFunction

&AtClient
Function ПолучитьСодержимоеКаталогаНаКлиенте(Directory)
	Return ПолучитьСодержимоеКаталога(Directory, PathParentOnClient, WindowsClient);
EndFunction

&AtClientAtServerNoContext
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
		Else
			IsDirectory=File.IsDirectory();
		EndIf;

		FullFileName=File.FullName + ?(IsDirectory, РазделительПути, "");
		If Not ЭтоWindows And Left(File.FullName, 2) = "//" Then
			FullFileName=Mid(File.FullName, 2);
		EndIf;

		If FullFileName = "/./" Or FullFileName = "/../" 
			Or FullFileName="/." Or FullFileName= "/.." Then
			Continue;
		EndIf;

		СтрокаСтруктура = New Structure;

		СтрокаСтруктура.Insert("IsDirectory", IsDirectory);
		СтрокаСтруктура.Insert("FullName", FullFileName);

		If СтрокаСтруктура.IsDirectory Then
			If ValueIsFilled(File.Name) Then
				FileName=File.Name;
			Else
				FileName=StrReplace(File.Path, РазделительПути, "");
			EndIf;

			FileName=FileName + РазделительПути;
		Else
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

&AtClientAtServerNoContext
Function PictureIndex(Знач FileExtension, IsDirectory)
	If IsDirectory Then
		Return 2;
	Else
		Return UT_CommonClientServer.GetFileIconIndex(FileExtension);
	EndIf;
EndFunction

&AtClientAtServerNoContext
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

&AtServerNoContext
Function ПолучитьСписокДисковWindowsAtServer(РазделительПути)
	Return ПолучитьСписокДисковWindows(РазделительПути);
EndFunction

&AtClient
Function ПолучитьСписокДисковWindowsAtClient(РазделительПути)
	Return ПолучитьСписокДисковWindows(РазделительПути);
EndFunction


&AtServerNoContext
Function ИмяКаталонаНаСервере(ИмяКаталога)
	Return Eval(ИмяКаталога + "()");
EndFunction

&AtClientAtServerNoContext
Function FileSize(РазмерФайлаВБайтах, ЕдиницаИзмерения)
	ЕдиницаИзмерения = "КБ";
	Return РазмерФайлаВБайтах / 1000;
EndFunction

&AtServerNoContext
Procedure УдалитьФайлыНаСервере(FileName)
	DeleteFiles(FileName);
EndProcedure

&AtServerNoContext
Function ПоместитьВоВременноеХранилищеНаСервере(ИсходныйФайл, ИдентификаторФормы)
	BinaryData = New BinaryData(ИсходныйФайл);
	АдресВХранилище = PutToTempStorage(BinaryData, ИдентификаторФормы);
	Return АдресВХранилище;
EndFunction

&AtServerNoContext
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

&AtServerNoContext
Procedure ПереименоватьФайлНаСервере(ИмяФайлаИсточника, ИмяФайлаПриемника, РазделительПути)
	File = New File(ИмяФайлаИсточника);
	If File.IsFile() Then
		MoveFile(ИмяФайлаИсточника, ИмяФайлаПриемника);
	Else
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
	//Else
	//	МассивСлов = StrSplit(ИмяФайлаПриемника, РазделительПути);
	//	If IsBlankString(МассивСлов[МассивСлов.UBound()]) Then
	//		МассивСлов.Delete(МассивСлов.UBound());
	//	EndIf;
	//	//ФСО = New COMObject("Scripting.FileSystemObject");

	//	//ФСО.GetFolder(ИмяФайлаИсточника).Name = МассивСлов[МассивСлов.UBound()];
	//EndIf;

EndProcedure


#EndRegion