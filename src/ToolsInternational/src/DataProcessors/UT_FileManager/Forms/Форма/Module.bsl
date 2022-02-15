#Region FormEventHandlers

&AtClient
Procedure OnOpen(Cancel)
	WindowsClient=UT_CommonClientServer.IsWindows();

	UpdateAtClient();
	UpdateAtServer();

	Items.CurrentDirectoryOnServer.ChoiceList.LoadValues(HistoryOfChooseServer.UnloadValues());
	Items.CurrentDirectoryOnClient.ChoiceList.LoadValues(HistoryOfChooseClient.UnloadValues());
	
	SetCurrentPanelBorder();
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	WindowsServer=UT_CommonClientServer.IsWindows();
	PathParentOnClient=GetClientPathSeparator();
	PathParentOnServer=GetServerPathSeparator();
	CurrentFilesTable="FilesOnLeftPanel";

	FillSortSubMenu();

	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing,
		Items.BottomPanel);

EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure CurrentDirectoryOnServerOnChange(Item)
	If Not IsBlankString(CurrentDirectoryOnServer) And Not Right(CurrentDirectoryOnServer, 1) = PathParentOnServer Then
		CurrentDirectoryOnServer = CurrentDirectoryOnServer + PathParentOnServer;
	EndIf;
	UpdateAtServer();
	UpdateHistoryAtServer();
EndProcedure

&AtClient
Procedure CurrentDirectoryOnClientOnChange(Item)
	If Not IsBlankString(CurrentDirectoryOnClient) And Not Right(CurrentDirectoryOnClient, 1) = PathParentOnClient Then
		CurrentDirectoryOnClient = CurrentDirectoryOnClient + PathParentOnClient;
	EndIf;
	UpdateAtClient();
	UpdateHistoryAtClient();
EndProcedure

#EndRegion

#Region LeftPanelItemsEventHandlers

&AtClient
Procedure FilesOnLeftPanelSelection(Item, SelectedRow, Field, StandardProcessing)
	TableFilesSelection(True, Item, SelectedRow, Field, StandardProcessing);
EndProcedure

&AtClient
Procedure FilesOnLeftPanelOnActivateCell(Item)
	CurrentFilesTable=Item.Name;
	SetCurrentPanelBorder();
EndProcedure


#EndRegion

#Region RightPanelItemsEventHandlers
&AtClient
Procedure FilesOnRightPanelSelection(Item, SelectedRow, Field, StandardProcessing)
	TableFilesSelection(False, Item, SelectedRow, Field, StandardProcessing);
EndProcedure

&AtClient
Procedure FilesOnRightPanelOnActivateCell(Item)
	CurrentFilesTable=Item.Name;
	SetCurrentPanelBorder();
EndProcedure

#EndRegion

#Region CommandFormEventHandlers

&AtClient
Procedure TableFilesSelection(IsLeftTable, Item, SelectedRow, Field, StandardProcessing)
	StandardProcessing = False;

	If IsLeftTable Then
		GetCurrentDirectory=CurrentDirectoryOnClient;
		FileTable=FilesOnLeftPanel;
	Else
		GetCurrentDirectory=CurrentDirectoryOnServer;
		FileTable=FilesOnRightPanel;
	EndIf;

	CurrentData=FileTable.FindByID(SelectedRow);
	If CurrentData = Undefined Then
		Return;
	EndIf;
	If CurrentData.IsDirectory Then
		GotoDirectory(FilesOnLeftPanel, CurrentData.FullName, IsLeftTable);
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

	UpdateFilesTree(False);
EndProcedure

&AtClient
Procedure UpdateAtClient(Command = Undefined)
	If Not WindowsClient And Not ValueIsFilled(CurrentDirectoryOnClient) Then
		CurrentDirectoryOnClient="/";
	EndIf;

	UpdateFilesTree(True);
EndProcedure

&AtClient
Procedure GotoAtServer(Command)
	DirectoryName = StrGetLine(StrReplace(Command.Name, "_", Chars.LF), 2);
	CurrentDirectoryOnServer = DirectoryNameOnServer(DirectoryName);
	UpdateAtServer();
	UpdateHistoryAtServer();
EndProcedure

&AtClient
Procedure GotoAtClient(Command)
	DirectoryName = StrGetLine(StrReplace(Command.Name, "_", Chars.LF), 2);
	CurrentDirectoryOnClient = Eval(DirectoryName + "()");
	UpdateAtClient();
	UpdateHistoryAtClient();
EndProcedure

&AtClient
Procedure GotoDesktopClient(Command)
	ArrayOfFolders = StrSplit(DocumentsDir(), PathParentOnClient);
	If IsBlankString(ArrayOfFolders[ArrayOfFolders.UBound()]) Then
		ArrayOfFolders.Delete(ArrayOfFolders.UBound());
	EndIf;
	ArrayOfFolders[ArrayOfFolders.UBound()] = "Desktop";
	Path = "";
	For Each DirectoryName In ArrayOfFolders Do
		Path = Path + DirectoryName + PathParentOnClient;
	EndDo;
	CurrentDirectoryOnClient = Path;
	UpdateAtClient();
	UpdateHistoryAtClient();
EndProcedure

&AtClient
Procedure CopyToServer(Command)

	SourceDirectory = CurrentDirectoryOnClient;
	TargetDirectory = CurrentDirectoryOnServer;
	If IsBlankString(TargetDirectory) Then
		Return;
	EndIf;

	TableItem= Items.FilesOnLeftPanel;
	PanelTable = FilesOnLeftPanel;
	CurrentData = TableItem.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	FilesArray = New Array;
	For Each RowID In TableItem.SelectedRows Do
		TreeRow = PanelTable.FindByID(RowID);
		If StrLen(TreeRow.FullName) <= StrLen(SourceDirectory) Then
			Return;
		EndIf;

		StructureLine = New Structure("FullName,IsDirectory", TreeRow.FullName, TreeRow.IsDirectory);
		StructureLine.Insert("StorageAddress", PutToTempStorage(
			New BinaryData(StructureLine.FullName), UUID));

		FilesArray.Add(StructureLine);
		If Not StructureLine.IsDirectory Then
			Continue;
		EndIf;

		Result = FindAllFilesOnClient(TreeRow.FullName, PathParentOnClient, UUID);
		For Each StructureLine In Result Do
			FilesArray.Add(StructureLine);
		EndDo;
	EndDo;

	For Ind = 0 To FilesArray.UBound() Do
		StructureLine = FilesArray[Ind];
		Status("Copy " + (Ind + 1) + " from " + FilesArray.Count() + " : " + StructureLine.FullName);

		FinalFileName = TargetDirectory + Mid(StructureLine.FullName, StrLen(SourceDirectory) + 1);

		If StructureLine.IsDirectory Then
			File = New File(FinalFileName);
			If Not File.Exists() Then
				СоздатьКаталогНаСервере(FinalFileName);
			EndIf;
		Else
//			BinaryData = New BinaryData(StructureLine.FullName);
//			StorageAddress = PutToTempStorage(BinaryData, ThisForm.UUID);
			UnpackFileAtServer(StructureLine.StorageAddress, FinalFileName);
		EndIf;

	EndDo;

	UpdateAtServer();

EndProcedure

&AtClient
Procedure CopyToClient(Command)

	SourceDirectory = CurrentDirectoryOnServer;
	TargetDirectory = CurrentDirectoryOnClient;
	If IsBlankString(TargetDirectory) Then
		Return;
	EndIf;

	TableItem = Items.FilesOnRightPanel;
	PanelTable = FilesOnRightPanel;
	CurrentData = TableItem.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	FilesArray = New Array;
	For Each RowID In TableItem.SelectedRows Do
		TreeRow = PanelTable.FindByID(RowID);
		If StrLen(TreeRow.FullName) <= StrLen(SourceDirectory) Then
			Return;
		EndIf;

		StructureLine = New Structure("FullName,IsDirectory", TreeRow.FullName, TreeRow.IsDirectory);
		StructureLine.Insert("StorageAddress", PutToTempStorageAtServer(StructureLine.FullName,
			UUID));

		FilesArray.Add(StructureLine);
		If Not StructureLine.IsDirectory Then
			Continue;
		EndIf;

		Result = FindAllFilesOnServer(TreeRow.FullName, PathParentOnServer, UUID);

		For Each StructureLine In Result Do
			FilesArray.Add(StructureLine);
		EndDo;
	EndDo;

	For Ind = 0 To FilesArray.UBound() Do
		StructureLine = FilesArray[Ind];
		Status("Copy " + (Ind + 1) + " from " + FilesArray.Count() + " : " + StructureLine.FullName);

		FinalFileName = TargetDirectory + Mid(StructureLine.FullName, StrLen(SourceDirectory) + 1);

		If StructureLine.IsDirectory Then
			File = New File(FinalFileName);
			If Not File.Exists() Then
				CreateDirectory(FinalFileName);
			EndIf;
		Else
//			StorageAddress = PutToTempStorageAtServer(StructureLine.FullName,
//				ThisForm.UUID);
			BinaryData = GetFromTempStorage(StructureLine.StorageAddress);
			BinaryData.Write(FinalFileName);
		EndIf;

	EndDo;

	UpdateAtClient();

EndProcedure

&AtClient
Procedure DeleteAtClient(Command)
	If IsBlankString(CurrentDirectoryOnClient) Then
		Return;
	EndIf;

	TableItem = Items.FilesOnLeftPanel;
	PanelTable = FilesOnLeftPanel;

	CurrentData = TableItem.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	For Each Row In TableItem.SelectedRows Do
		CurrentData = PanelTable.FindByID(Row);
		DeleteFiles(CurrentData.FullName);
	EndDo;

	UpdateAtClient();
EndProcedure

&AtClient
Procedure DeleteAtServer(Command)
	If IsBlankString(CurrentDirectoryOnServer) Then
		Return;
	EndIf;

	TableItem = Items.FilesOnRightPanel;
	PanelTable = FilesOnRightPanel;

	CurrentData = TableItem.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	For Each Row In TableItem.SelectedRows Do
		CurrentData = PanelTable.FindByID(Row);
		DeleteFilesOnServer(CurrentData.FullName);
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

	TreeItem = Items.FilesOnServer;

	CurrentData = TreeItem.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	If CurrentData.GetParent() = Undefined Then
		Return;
	EndIf;

	NewName = CurrentData.Name + CurrentData.FileExtension;
	NewName = StrReplace(NewName, PathParentOnServer, "");
	If Not InputString(NewName) Then
		Return;
	EndIf;

	RenameFilesOnServer(CurrentData.FullName, CurrentDirectoryOnServer + NewName, PathParentOnServer);

	UpdateAtServer();
EndProcedure

&AtClient
Procedure RenameAtClient(Command)
	If IsBlankString(CurrentDirectoryOnClient) Then
		Return;
	EndIf;

	TreeItem = Items.FilesOnLeftPanel;

	CurrentData = TreeItem.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	//If CurrentData.GetParent() = Undefined Then
	//	Return;
	//EndIf;

	NewName = CurrentData.Name + CurrentData.FileExtension;
	NewName = StrReplace(NewName, PathParentOnClient, "");
	If Not InputString(NewName) Then
		Return;
	EndIf;

	RenameFilesOnClient(CurrentData.FullName, CurrentDirectoryOnServer + NewName, PathParentOnClient);

	UpdateAtClient();
EndProcedure

&AtClient
Procedure StepBackAtClient(Command)
	StepBack(True);
EndProcedure

&AtClient
Procedure StepForwardAtClient(Command)
	StepForward(True);
EndProcedure

&AtClient
Procedure StepUpAtClient(Command)
	GoLevelUp(FilesOnLeftPanel, True);
EndProcedure
&AtClient
Procedure StepBackAtServer(Command)
	StepBack(False);
EndProcedure

&AtClient
Procedure StepForwardAtServer(Command)
	StepForward(False);
EndProcedure

&AtClient
Procedure StepUpAtServer(Command)
	GoLevelUp(FilesOnRightPanel, False);
EndProcedure

&AtClient
Procedure Copy(Command)
	IsLeftPanel=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	If IsLeftPanel Then
		CopyToServer(Commands.CopyToServer);
	Else
		CopyToClient(Commands.CopyToClient);
	EndIf;
EndProcedure

&AtClient
Procedure Move(Command)
	IsLeftPanel=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	If IsLeftPanel Then
		MoveFromClientToServer(Commands.MoveFromClientToServer);
	Else
		MoveFromServerToClient(Commands.MoveFromServerToClient);
	EndIf;
EndProcedure

&AtClient
Procedure CreateDirectory_Command(Command)
	IsLeftPanel=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	ShowInputString(New NotifyDescription("СоздатьКаталогЗавершениеВводаНаименования", ThisObject,
		New Structure("ИмяТаблицыФайлов,IsLeftPanel", CurrentFilesTable, IsLeftPanel)), ,
		"Введите наименование нового каталога");
EndProcedure

&AtClient
Procedure Delete(Command)
	ТекДанные=Items[CurrentFilesTable].CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	IsLeftPanel=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	UT_CommonClient.ShowQuestionToUser(
		New NotifyDescription("УдалитьПослеПодтвержденияНеобходимости", ThisObject,
		New Structure("IsLeftPanel,FullName", IsLeftPanel, ТекДанные.FullName)), "Delete выбранный файл?",
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
Procedure SetCurrentPanelBorder()
	IsLeftPanel=CurrentFilesTable = Items.FilesOnLeftPanel.Name;
	
	If IsLeftPanel Then
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

	If AdditionalParameters.IsLeftPanel Then

		BeginDeletingFiles(New NotifyDescription("УдалитьФайлЗавершение", ThisObject, AdditionalParameters),
			AdditionalParameters.FullName);
	Else
		DeleteFilesOnServer(AdditionalParameters.FullName);
		УдалитьФайлЗавершение(AdditionalParameters);
	EndIf;
EndProcedure

&AtClient
Procedure УдалитьФайлЗавершение(AdditionalParameters) Export
	If AdditionalParameters.IsLeftPanel Then
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
Procedure СоздатьКаталогЗавершениеВводаНаименования(Row, AdditionalParameters) Export
	If Row = Undefined Then
		Return;
	EndIf;

	If Not ValueIsFilled(Row) Then
		Return;
	EndIf;

	IsLeftPanel=AdditionalParameters.IsLeftPanel;
	If IsLeftPanel Then
		GetCurrentDirectory=CurrentDirectoryOnClient;
	Else
		GetCurrentDirectory=CurrentDirectoryOnServer;
	EndIf;

	
	//Проверяем существование каталога

	ДопПараметрыОповещения=AdditionalParameters;
	ДопПараметрыОповещения.Insert("GetCurrentDirectory", GetCurrentDirectory);

	ФайлПолноеИмя=GetCurrentDirectory + Row;

	If IsLeftPanel Then
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
Procedure СоздатьКаталогЗавершениеСозданияКаталога(DirectoryName, AdditionalParameters) Export

	If AdditionalParameters.IsLeftPanel Then
		CurrentDirectoryOnClient=DirectoryName;
		UpdateAtClient();
	Else
		CurrentDirectoryOnServer=DirectoryName;
		UpdateAtServer();
	EndIf;
EndProcedure

&AtClient
Procedure StepBack(IsLeftTable)
	If IsLeftTable Then
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
		If IsLeftTable Then
			UpdateAtClient();
		Else
			UpdateAtServer();
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure StepForward(IsLeftTable)
	If IsLeftTable Then
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
		If IsLeftTable Then
			UpdateAtClient();
		Else
			UpdateAtServer();
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure GoLevelUp(FileTable, IsLeftTable)
	GotoDirectory(FileTable, "..", IsLeftTable);
EndProcedure

&AtClient
Procedure GotoDirectory(FileTable, ПолноеИмяНовогоКаталога, IsLeftTable)
	If IsLeftTable Then
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

	If IsLeftTable Then
		UpdateAtClient();
		UpdateHistoryAtClient();
	Else
		UpdateAtServer();

		UpdateHistoryAtServer();
	EndIf;

EndProcedure
&AtServer
Procedure FillSortSubMenu()
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
Procedure UnpackFileAtServer(StorageAddress, FinalFileName)
	BinaryData = GetFromTempStorage(StorageAddress);
	BinaryData.Write(FinalFileName);
EndProcedure

&AtClient
Procedure UpdateFilesTree(AtClient = True)
	If AtClient = False Then
		TreeItem = Items.FilesOnLeftPanel;
		ТаблицаФайловКаталога = FilesOnRightPanel;
		GetCurrentDirectory = CurrentDirectoryOnServer;
		ФайлыТекущегоКаталога = ПолучитьСодержимоеКаталогаНаСервере(GetCurrentDirectory, PathParentOnServer,
			WindowsServer);
		ТекущийРазделительПути=PathParentOnServer;
		ЭтоWindows=WindowsServer;
	Else
		TreeItem = Items.FilesOnLeftPanel;
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
//	Для Каждого DirectoryName Из МассивТекущийПуть Цикл
//		Если ПустаяСтрока(DirectoryName) Тогда
//			Прервать;
//		КонецЕсли;
//
//		DirectoryName = СтрЗаменить(DirectoryName, ":::", ТекущийРазделительПути + ТекущийРазделительПути);
//
//		FullName = FullName + DirectoryName + ТекущийРазделительПути;
//		ТекущийРодитель = ТекущийРодитель.ПолучитьЭлементы().Добавить();
//		ТекущийРодитель.PictureIndex = PictureIndex;
//		ТекущийРодитель.Name = DirectoryName + ТекущийРазделительПути;
//		ТекущийРодитель.IsDirectory = Истина;
//		ТекущийРодитель.FullName = ТекущийРазделительПути + FullName;
//		PictureIndex = 1;
//	КонецЦикла;

	For Each StructureLine In ФайлыТекущегоКаталога Do
		FillPropertyValues(ТаблицаФайловКаталога.Add(), StructureLine);
	EndDo;

	ТаблицаФайловКаталога.Sort("IsDirectory УБЫВ, Name");
//	Если ТипЗнч(ТекущийРодитель) = Тип("ДанныеФормыЭлементДерева") Тогда
//		TreeItem.ТекущаяСтрока = ТекущийРодитель.ПолучитьИдентификатор();
//		TreeItem.Развернуть(TreeItem.ТекущаяСтрока);
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
Procedure UpdateHistoryAtClient()
	UpdateHistory(True);
EndProcedure

&AtClient
Procedure UpdateHistoryAtServer()
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

		StructureLine = New Structure;

		StructureLine.Insert("IsDirectory", IsDirectory);
		StructureLine.Insert("FullName", FullFileName);

		If StructureLine.IsDirectory Then
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

			If Not StructureLine.IsDirectory And StrStartsWith(FileName, РазделительПути) Then
				FileName=Mid(FileName, 2);
			EndIf;
		EndIf;
		StructureLine.Insert("Name", FileName);
		StructureLine.Insert("FileExtension", ?(StructureLine.IsDirectory, "", File.Extension));
		StructureLine.Insert("PictureIndex", PictureIndex(StructureLine.FileExtension,
			StructureLine.IsDirectory));

		Try
			StructureLine.Insert("ModifiedDate", File.GetModificationTime());
		Except
			StructureLine.Insert("ModifiedDate", '00010101');
		EndTry;

		If Not StructureLine.IsDirectory Then
			Try
				StructureLine.Insert("Size", File.Size() / 1000);
			Except
				StructureLine.Insert("Size", 0);
			EndTry;
		EndIf;
		StructureLine.Insert("Presentation", Format(StructureLine.ModifiedDate, "ДФ='yyyy-MM-dd HH:MM:ss'"));

		Result.Add(StructureLine);
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

	For Ind = 0 To 25 Do
		БукваДиска = Char(CharCode("A") + Ind) + ":" + РазделительПути;
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
Function DirectoryNameOnServer(DirectoryName)
	Return Eval(DirectoryName + "()");
EndFunction

&AtClientAtServerNoContext
Function FileSize(РазмерФайлаВБайтах, ЕдиницаИзмерения)
	ЕдиницаИзмерения = "КБ";
	Return РазмерФайлаВБайтах / 1000;
EndFunction

&AtServerNoContext
Procedure DeleteFilesOnServer(FileName)
	DeleteFiles(FileName);
EndProcedure

&AtServerNoContext
Function PutToTempStorageAtServer(ИсходныйФайл, ИдентификаторФормы)
	BinaryData = New BinaryData(ИсходныйФайл);
	StorageAddress = PutToTempStorage(BinaryData, ИдентификаторФормы);
	Return StorageAddress;
EndFunction

&AtServerNoContext
Function FindAllFilesOnServer(GetCurrentDirectory, РазделительПути, УникальныйИдентификаторФормы)
	Result = New Array;

	НайденныеФайлы = FindFiles(GetCurrentDirectory, "*", True);
	For Each File In НайденныеФайлы Do
		StructureLine = New Structure;
		Result.Add(StructureLine);

		StructureLine.Insert("IsDirectory", File.IsDirectory());
		StructureLine.Insert("FullName", File.FullName + ?(StructureLine.IsDirectory, РазделительПути, ""));
		StructureLine.Insert("StorageAddress", PutToTempStorage(
			New BinaryData(StructureLine.FullName), УникальныйИдентификаторФормы));
	EndDo;

	Return Result;
EndFunction

&AtClient
Function FindAllFilesOnClient(GetCurrentDirectory, РазделительПути, УникальныйИдентификаторФормы)
	Result = New Array;

	НайденныеФайлы = FindFiles(GetCurrentDirectory, "*", True);
	For Each File In НайденныеФайлы Do
		StructureLine = New Structure;
		Result.Add(StructureLine);

		StructureLine.Insert("IsDirectory", File.IsDirectory());
		StructureLine.Insert("FullName", File.FullName + ?(StructureLine.IsDirectory, РазделительПути, ""));
		StructureLine.Insert("StorageAddress", PutToTempStorage(
			New BinaryData(StructureLine.FullName), УникальныйИдентификаторФормы));

	EndDo;

	Return Result;
EndFunction

&AtServerNoContext
Procedure RenameFilesOnServer(ИмяФайлаИсточника, ИмяФайлаПриемника, РазделительПути)
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
Procedure RenameFilesOnClient(ИмяФайлаИсточника, ИмяФайлаПриемника, РазделительПути)
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