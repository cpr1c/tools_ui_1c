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
				CreateDirectoryOnServer(FinalFileName);
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

	ShowInputString(New NotifyDescription("CreateDirectoryAfterEnterNameCompletion", ThisObject,
		New Structure("FilesTableName,IsLeftPanel", CurrentFilesTable, IsLeftPanel)), ,
		NStr("en='Enter a name for the new directory' ; ru='Введите наименование нового каталога'"));
EndProcedure

&AtClient
Procedure Delete(Command)
	CurrentData=Items[CurrentFilesTable].CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	IsLeftPanel=CurrentFilesTable = Items.FilesOnLeftPanel.Name;

	UT_CommonClient.ShowQuestionToUser(
		New NotifyDescription("DeleteAfterConfirmingCompletion", ThisObject,
		New Structure("IsLeftPanel,FullName", IsLeftPanel, CurrentData.FullName)), 
		NStr("ru='Delete выбранный файл?'; en='Delete the selected file?'"),
		QuestionDialogMode.YesNo);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_SetSortOrder(Command)
	SortOrder=Right(Command.Name, 4);

	If SortOrder <> "Desc" Then
		SortOrder = "Asc";
	EndIf;
	
	LeftPanelPrefix="SortGroupOfLeftPanel";
	RightPanelPrefix="SortGroupOfRightPanel";

	TableForSort=Undefined;
	NamePrefix=Undefined;

	If StrFind(Command.Name, LeftPanelPrefix) > 0 Then
		TableForSort=FilesOnLeftPanel;
		NamePrefix=LeftPanelPrefix;
	ElsIf StrFind(Command.Name, RightPanelPrefix) > 0 Then
		TableForSort=FilesOnRightPanel;
		NamePrefix=RightPanelPrefix;
	EndIf;

	If TableForSort = Undefined Then
		Return;
	EndIf;

	SortFieldName=StrReplace(Command.Name, NamePrefix, "");
	SortFieldName=StrReplace(SortFieldName, SortOrder, "");

	TableForSort.Sort("IsDirectory Desc, " + SortFieldName + " " + SortOrder);

	For Each Item In Items[Command.Name].Parent.ChildItems Do
		Item.Check=False;
	EndDo;

	Items[Command.Name].Check=True;
//	TreeItems=FilesOnClient.GetItems().	
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
		ActivePanel=Items.FilesOnLeftPanel;
		InactivePanel=Items.FilesOnRightPanel;
	Else
		ActivePanel=Items.FilesOnRightPanel;
		InactivePanel=Items.FilesOnLeftPanel;
	EndIf;
	
	ActivePanel.BorderColor=WebColors.Red;
	InactivePanel.BorderColor=New Color;
EndProcedure

&AtClient
Procedure DeleteAfterConfirmingCompletion(QueryResult, AdditionalParameters) Export
	If QueryResult <> DialogReturnCode.Yes Then
		Return;
	EndIf;

	If AdditionalParameters.IsLeftPanel Then

		BeginDeletingFiles(New NotifyDescription("DeleteFileCompletion", ThisObject, AdditionalParameters),
			AdditionalParameters.FullName);
	Else
		DeleteFilesOnServer(AdditionalParameters.FullName);
		DeleteFileCompletion(AdditionalParameters);
	EndIf;
EndProcedure

&AtClient
Procedure DeleteFileCompletion(AdditionalParameters) Export
	If AdditionalParameters.IsLeftPanel Then
		UpdateAtClient();
	Else
		UpdateAtServer();
	EndIf;

EndProcedure
&AtServerNoContext
Function CreateDirectoryOnServer(FullName)
	File=New File(FullName);
	If File.Exists() Then
		UT_CommonClientServer.MessageToUser(Nstr("ru='Такой каталог уже существует'; en='Such directory already exists'"));

		Return Undefined;
	EndIf;

	CreateDirectory(File.FullName);

	Return File.FullName;
EndFunction

&AtClient
Procedure CreateDirectoryAfterEnterNameCompletion(Row, AdditionalParameters) Export
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

	
	//Check the directory exists

	NotifyAdditionalParameters=AdditionalParameters;
	NotifyAdditionalParameters.Insert("GetCurrentDirectory", GetCurrentDirectory);

	FileFullName=GetCurrentDirectory + Row;

	If IsLeftPanel Then
		File=New File(FileFullName);
		NotifyAdditionalParameters.Insert("File", File);

		File.BeginCheckingExistence(
		New NotifyDescription("CreateDirectoryCheckExistenceNewDirectoryCompletion", ThisObject,
			NotifyAdditionalParameters));
	Else
		Result=CreateDirectoryOnServer(FileFullName);
		If Result = Undefined Then
			Return;
		EndIf;

		CreateDirectoryCompletion(Result, NotifyAdditionalParameters);
	EndIf;

EndProcedure

&AtClient
Procedure CreateDirectoryCheckExistenceNewDirectoryCompletion(Exists, AdditionalParameters) Export
	If Exists Then
		UT_CommonClientServer.MessageToUser(Nstr("ru='Такой каталог уже существует'; en='Such directory already exists'"));
		Return;
	EndIf;

	BeginCreatingDirectory(New NotifyDescription("CreateDirectoryCompletion", ThisObject,
		AdditionalParameters), AdditionalParameters.File.FullName);
EndProcedure

&AtClient
Procedure CreateDirectoryCompletion(DirectoryName, AdditionalParameters) Export

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
		CurrentDirectoryFieldName="CurrentDirectoryOnClient";
	Else
		CurrentDirectoryFieldName="CurrentDirectoryOnServer";
	EndIf;

	ItemOfList = Items[CurrentDirectoryFieldName].ChoiceList;
	CurrentValue = ThisObject[CurrentDirectoryFieldName];

	FoundItem = ItemOfList.FindByValue(CurrentValue);
	If FoundItem = Undefined Then
		Return;
	EndIf;
	IndexOf = ItemOfList.IndexOf(FoundItem);
	If IndexOf + 1 < ItemOfList.Count() - 1 Then
		ThisObject[CurrentDirectoryFieldName] = ItemOfList[IndexOf + 1].Value;
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
		CurrentDirectoryFieldName="CurrentDirectoryOnClient";
	Else
		CurrentDirectoryFieldName="CurrentDirectoryOnServer";
	EndIf;

	ItemOfList = Items[CurrentDirectoryFieldName].ChoiceList;
	CurrentValue = ThisObject[CurrentDirectoryFieldName];

	FoundItem = ItemOfList.FindByValue(CurrentValue);
	If FoundItem = Undefined Then
		Return;
	EndIf;
	IndexOf = ItemOfList.IndexOf(FoundItem);
	If IndexOf > 0 Then
		ThisObject[CurrentDirectoryFieldName] = ItemOfList[IndexOf - 1].Value;
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
Procedure GotoDirectory(FileTable, NewDirectoryFullName, IsLeftTable)
	If IsLeftTable Then
		DirectoryFieldName="CurrentDirectoryOnClient";
		PathSplitter=PathParentOnClient;
	Else
		DirectoryFieldName="CurrentDirectoryOnServer";
		PathSplitter=PathParentOnServer;
	EndIf;

	GetCurrentDirectory=ThisObject[DirectoryFieldName];
	NewDirectory="";

	If NewDirectoryFullName = ".." Then
		DirectoryLineArray=StrSplit(GetCurrentDirectory, PathSplitter, True);
		If Not ValueIsFilled(DirectoryLineArray[DirectoryLineArray.Count()-1]) Then
			DirectoryLineArray.Delete(DirectoryLineArray.Count() - 1);
		EndIf;
		
		If DirectoryLineArray.Count() = 0 Then
			NewDirectory="";
		Else
			
			DirectoryLineArray.Delete(DirectoryLineArray.Count() - 1);

			//DirectoryLineArray.Insert(0, "");
			DirectoryLineArray.Add("");

			NewDirectory=StrConcat(DirectoryLineArray, PathSplitter);
		EndIf;
	Else
		NewDirectory = NewDirectoryFullName;
	EndIf;

	ThisObject[DirectoryFieldName] = NewDirectory;

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
	OrderFields=New Structure;
	OrderFields.Insert("Name", "Name");
	OrderFields.Insert("FileExtension", "File extension");
	OrderFields.Insert("ModifiedDate", "Modified date");
	OrderFields.Insert("Size", "Size");

	SortingDirection = New Structure;
	SortingDirection.Insert("Asc", " +");
	SortingDirection.Insert("Desc", " -");

	SubMenuArray=New Array;
	SubMenuArray.Add(Items.SortGroupOfLeftPanel);
	SubMenuArray.Add(Items.SortGroupOfRightPanel);

	For Each CurrentSubMenu In SubMenuArray Do
		For Each OrderField In OrderFields Do
			For Each Heading In SortingDirection Do
				//First we add the command, and then the button
				CommandDescription=UT_Forms.ButtonCommandNewDescription();
				CommandDescription.Name=CurrentSubMenu.Name + OrderField.Key + Heading.Key;
				CommandDescription.Title=OrderField.Value + Heading.Value;
				CommandDescription.Action="Attachable_SetSortOrder";
				CommandDescription.ItemParent=CurrentSubMenu;
				CommandDescription.Picture=New Picture;
				CommandDescription.CommandName=CommandDescription.Name;

				UT_Forms.CreateCommandByDescription(ThisObject, CommandDescription);
				UT_Forms.CreateButtonByDescription(ThisObject, CommandDescription);
			EndDo;
		EndDo;

		Items[CurrentSubMenu.Name + "NameDESC"].Check=True;
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
		DirectoryFilesTable = FilesOnRightPanel;
		GetCurrentDirectory = CurrentDirectoryOnServer;
		CurrentDirectoryFiles = GetDirectoryContentsOnServer(GetCurrentDirectory, PathParentOnServer,
			WindowsServer);
		CurrentPathSplitter=PathParentOnServer;
		IsWindows=WindowsServer;
	Else
		TreeItem = Items.FilesOnLeftPanel;
		DirectoryFilesTable = FilesOnLeftPanel;
		GetCurrentDirectory = CurrentDirectoryOnClient;
		CurrentDirectoryFiles = GetDirectoryContentsOnClient(GetCurrentDirectory);
		CurrentPathSplitter=PathParentOnClient;
		IsWindows=WindowsClient;

	EndIf;

	DirectoryFilesTable.Clear();

//	CurrentParent = Tree;
	FullName = "";
	PathForSplit = StrReplace(GetCurrentDirectory, CurrentPathSplitter + CurrentPathSplitter, ":::");
	PictureIndex = 6;
	If IsBlankString(GetCurrentDirectory) And IsWindows Then
		If IsWindows Then
			If AtClient Then
				Disks = GetDisksListWindowsAtClient(CurrentPathSplitter);
			Else
				Disks = GetDisksListWindowsAtServer(CurrentPathSplitter);
			EndIf;
			For Each DiskName In Disks Do
				NewLine = DirectoryFilesTable.Add();
				NewLine.PictureIndex = 2;
				NewLine.Name = DiskName;
				NewLine.IsDirectory = True;
				NewLine.FullName = NewLine.Name;
			EndDo;

			Return;

		EndIf;
//	ElsIf Not IsWindows Then
//		CurrentParent = CurrentParent.GetItems().Add();
//		CurrentParent.PictureIndex = PictureIndex;
//		CurrentParent.Name = CurrentPathSplitter;
//		CurrentParent.IsDirectory = True;
//		CurrentParent.FullName = CurrentPathSplitter;
//		PictureIndex = 1;
//
//		If StrStartsWith(PathForSplit, CurrentPathSplitter) Then
//			PathForSplit=Mid(PathForSplit, 2);
//		EndIf;
	EndIf;

//	CurrentPathArray = StrSplit(PathForSplit, CurrentPathSplitter);//SplitStringToArrayStrings(PathForSplit, CurrentPathSplitter);
//	For Each DirectoryName In CurrentPathArray Do
//		If IsBlankString(DirectoryName) Then
//			Break;
//		EndIf;
//
//		DirectoryName = StrReplace(DirectoryName, ":::", CurrentPathSplitter + CurrentPathSplitter);
//
//		FullName = FullName + DirectoryName + CurrentPathSplitter;
//		CurrentParent = CurrentParent.GetItems().Add();
//		CurrentParent.PictureIndex = PictureIndex;
//		CurrentParent.Name = DirectoryName + CurrentPathSplitter;
//		CurrentParent.IsDirectory = True;
//		CurrentParent.FullName = CurrentPathSplitter + FullName;
//		PictureIndex = 1;
//	EndDo;

	For Each StructureLine In CurrentDirectoryFiles Do
		FillPropertyValues(DirectoryFilesTable.Add(), StructureLine);
	EndDo;

	DirectoryFilesTable.Sort("IsDirectory DESC, Name");
//	If TypeOf(CurrentParent) = Type("FormDataTreeItem") Then
//		TreeItem.CurrentLine = CurrentParent.GetID();
//		TreeItem.Expand(TreeItem.CurrentLine);
//	EndIf;

	If ValueIsFilled(GetCurrentDirectory) And GetCurrentDirectory <> CurrentPathSplitter Then
		NewLine = DirectoryFilesTable.Insert(0);
		NewLine.PictureIndex = 2;
		NewLine.Name = "[..]";
		NewLine.IsDirectory = True;
		NewLine.FullName = "..";
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
		CurrentDirectoryItem = Items.CurrentDirectoryOnServer;
		HistoryList = HistoryOfChooseServer;
	Else
		GetCurrentDirectory = CurrentDirectoryOnClient;
		CurrentDirectoryItem = Items.CurrentDirectoryOnClient;
		HistoryList = HistoryOfChooseClient;
	EndIf;

	FoundItem = HistoryList.FindByValue(GetCurrentDirectory);
	If Not FoundItem = Undefined Then
		HistoryList.Delete(FoundItem);
	EndIf;
	HistoryList.Insert(0, GetCurrentDirectory);

	ZizeOfHistoryList = 25;
	While ZizeOfHistoryList < HistoryList.Count() Do
		HistoryList.Delete(HistoryList.Count() - 1);
	EndDo;

	CurrentDirectoryItem.ChoiceList.LoadValues(HistoryList.UnloadValues());
EndProcedure

&AtServerNoContext
Function GetDirectoryContentsOnServer(Directory, PathSplitter, IsWindows)
	Return GetDirectoryContent(Directory, PathSplitter, IsWindows);
EndFunction

&AtClient
Function GetDirectoryContentsOnClient(Directory)
	Return GetDirectoryContent(Directory, PathParentOnClient, WindowsClient);
EndFunction

&AtClientAtServerNoContext
Function GetDirectoryContent(Directory, PathSplitter, IsWindows)
	Result = New Array;

	Files = FindFiles(Directory, "*", False);
	For Each File In Files Do
		If False Then
			File = New File;
		EndIf;

//		If Not IsWindows And Left(File.FullName, 2) = "//" Then
//			File=New File(Mid(File.FullName, 2));
//		Else
//			File
//		EndIf;

//		If Not File.Exists() Then
//			Continue
//		EndIf;

		If Not File.Exists() Then
			IsDirectory=False;
		Else
			IsDirectory=File.IsDirectory();
		EndIf;

		FullFileName=File.FullName + ?(IsDirectory, PathSplitter, "");
		If Not IsWindows And Left(File.FullName, 2) = "//" Then
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
				FileName=StrReplace(File.Path, PathSplitter, "");
			EndIf;

			FileName=FileName + PathSplitter;
		Else
			FileName=File.BaseName;
		EndIf;

		If Not ValueIsFilled(FileName) Then
			FileName=FullFileName;

			If Not StructureLine.IsDirectory And StrStartsWith(FileName, PathSplitter) Then
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
		StructureLine.Insert("Presentation", Format(StructureLine.ModifiedDate, "DF='yyyy-MM-dd HH:MM:ss'"));

		Result.Add(StructureLine);
	EndDo;

//	Result.SortByPresentation(SortingDirection.Desc);
//	Return Result.UnloadValues();

	Return Result;
EndFunction

&AtClientAtServerNoContext
Function PictureIndex(Val FileExtension, IsDirectory)
	If IsDirectory Then
		Return 2;
	Else
		Return UT_CommonClientServer.GetFileIconIndex(FileExtension);
	EndIf;
EndFunction

&AtClientAtServerNoContext
Function GetDisksListWindows(PathSplitter)
	Result = New Array;

	For Ind = 0 To 25 Do
		DiscLetter = Char(CharCode("A") + Ind) + ":" + PathSplitter;
		If FindFiles(DiscLetter).Count() > 0 Then
			Result.Add(DiscLetter);
		EndIf;
	EndDo;

	Return Result;
EndFunction

&AtServerNoContext
Function GetDisksListWindowsAtServer(PathSplitter)
	Return GetDisksListWindows(PathSplitter);
EndFunction

&AtClient
Function GetDisksListWindowsAtClient(PathSplitter)
	Return GetDisksListWindows(PathSplitter);
EndFunction


&AtServerNoContext
Function DirectoryNameOnServer(DirectoryName)
	Return Eval(DirectoryName + "()");
EndFunction

&AtClientAtServerNoContext
Function FileSize(FileSizeInBytes, Unit)
	Unit = "KB";
	Return FileSizeInBytes / 1000;
EndFunction

&AtServerNoContext
Procedure DeleteFilesOnServer(FileName)
	DeleteFiles(FileName);
EndProcedure

&AtServerNoContext
Function PutToTempStorageAtServer(SourceFile, UUID)
	BinaryData = New BinaryData(SourceFile);
	StorageAddress = PutToTempStorage(BinaryData, UUID);
	Return StorageAddress;
EndFunction

&AtServerNoContext
Function FindAllFilesOnServer(GetCurrentDirectory, PathSplitter, UUID)
	Result = New Array;

	FoundFiles = FindFiles(GetCurrentDirectory, "*", True);
	For Each File In FoundFiles Do
		StructureLine = New Structure;
		Result.Add(StructureLine);

		StructureLine.Insert("IsDirectory", File.IsDirectory());
		StructureLine.Insert("FullName", File.FullName + ?(StructureLine.IsDirectory, PathSplitter, ""));
		StructureLine.Insert("StorageAddress", PutToTempStorage(
			New BinaryData(StructureLine.FullName), UUID));
	EndDo;

	Return Result;
EndFunction

&AtClient
Function FindAllFilesOnClient(GetCurrentDirectory, PathSplitter, UUID)
	Result = New Array;

	FoundFiles = FindFiles(GetCurrentDirectory, "*", True);
	For Each File In FoundFiles Do
		StructureLine = New Structure;
		Result.Add(StructureLine);

		StructureLine.Insert("IsDirectory", File.IsDirectory());
		StructureLine.Insert("FullName", File.FullName + ?(StructureLine.IsDirectory, PathSplitter, ""));
		StructureLine.Insert("StorageAddress", PutToTempStorage(
			New BinaryData(StructureLine.FullName), UUID));

	EndDo;

	Return Result;
EndFunction

&AtServerNoContext
Procedure RenameFilesOnServer(SourceFileName, TargetFileName, PathSplitter)
	File = New File(SourceFileName);
	If File.IsFile() Then
		MoveFile(SourceFileName, TargetFileName);
	Else
		WordArray = StrSplit(TargetFileName, PathSplitter);
		If IsBlankString(WordArray[WordArray.UBound()]) Then
			WordArray.Delete(WordArray.UBound());
		EndIf;
		//FSO = New COMObject("Scripting.FileSystemObject");

		//FSO.GetFolder(SourceFileName).Name = WordArray[WordArray.UBound()];
	EndIf;

EndProcedure

&AtClient
Procedure RenameFilesOnClient(SourceFileName, TargetFileName, PathSplitter)
	File = New File(SourceFileName);
	//If File.IsFile() Then
		MoveFile(SourceFileName, TargetFileName);
	//Else
	//	WordArray = StrSplit(TargetFileName, PathSplitter);
	//	If IsBlankString(WordArray[WordArray.UBound()]) Then
	//		WordArray.Delete(WordArray.UBound());
	//	EndIf;
	//	//FSO = New COMObject("Scripting.FileSystemObject");

	//	//FSO.GetFolder(SourceFileName).Name = WordArray[WordArray.UBound()];
	//EndIf;

EndProcedure


#EndRegion