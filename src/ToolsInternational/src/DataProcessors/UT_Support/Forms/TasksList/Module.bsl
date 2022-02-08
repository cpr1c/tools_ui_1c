#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	UpdateIssuesListAtServer();
EndProcedure

#EndRegion

#Region FormItemsEventsHandlers

&AtClient
Procedure IssuesListSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;

	RowData = IssuesList.FindByID(RowSelected);

	BeginRunningApplication(UT_CommonClient.ApplicationRunEmptyNotifyDescription(), RowData.URL);
	
EndProcedure

#EndRegion

#Region FormCommandHandlers

&AtClient
Procedure UpdateIssuesList(Command)
	UpdateIssuesListAtServer();
EndProcedure

&AtClient
Procedure AboutPage(Command)
	UT_CommonClient.OpenAboutPage();
EndProcedure
#EndRegion

#Region Private

&AtServer
Procedure UpdateIssuesListAtServer()
	IssuesList.Clear();

	BaseUrl = "https://api.github.com/repos/cpr1c/tools_ui_1c/issues";

	PageNumber=1;
	RepositoryIssuesList = UT_HTTPConnector.GetJson(BaseUrl+"?per_page=100&page="+Format(PageNumber,"NG=0;"));
	While RepositoryIssuesList.Count() > 0 Do

		For Each RepositoryIssue In RepositoryIssuesList Do
			NewIssue = IssuesList.Add();
			NewIssue.Number = RepositoryIssue["number"];
			NewIssue.URL = RepositoryIssue["html_url"];
			NewIssue.Subject = RepositoryIssue["title"];
			NewIssue.State = RepositoryIssue["state"];
			ResponsibleIssue = RepositoryIssue["assignee"];
			If TypeOf(ResponsibleIssue) = Type("Map") Then
				NewIssue.Responsible = ResponsibleIssue["login"];
			EndIf;

			IssueLabels = RepositoryIssue["labels"];
			If TypeOf(IssueLabels) = Type("Array") Then
				For Each CurrentLabel In IssueLabels Do
					NewIssue.Labels.Add(CurrentLabel["name"]);
				EndDo;
			EndIf;

		EndDo;

		PageNumber=PageNumber+1;
		RepositoryIssuesList = UT_HTTPConnector.GetJson(BaseUrl+"?per_page=100&page="+Format(PageNumber,"NG=0;"));
	
	EndDo;

EndProcedure

&AtServer
Function CreateNewIssueAtServer()
	AuthorizationToken = "d1af40528d2ceec322be578bc935a1b46b9af8cc";

	Headers = New Map;
	Headers.Insert("Authorization", "token " + AuthorizationToken);

	BodyStructure = New Structure;
	BodyStructure.Insert("title", NewIssueSubject);
	BodyStructure.Insert("body", NewIssueDescription);

	BaseUrl = "https://api.github.com/repos/cpr1c/tools_ui_1c/issues";

	Authentication = New Structure("User, Password", "tools-ui", AuthorizationToken);

	Response = UT_HTTPConnector.PostJson(BaseUrl, BodyStructure, New Structure("Headers, Authentication",
		Headers, Authentication));

	UpdateIssuesListAtServer();

	Return Response["html_url"];

EndFunction

&AtClient
Procedure CreateNewIssue(Command)
	If Not CheckFilling() Then
		Return;
	EndIf;

	АдресЗадачи=CreateNewIssueAtServer();
	If АдресЗадачи <> Undefined Then
		UT_CommonClientServer.MessageToUser(NSTR("ru = 'Задача успешно создана';en = 'Ussue created successfully'"));
		BeginRunningApplication(UT_CommonClient.ApplicationRunEmptyNotifyDescription(), АдресЗадачи);
	Else
		UT_CommonClientServer.MessageToUser(NSTR("ru = 'Создание задачи не удалось';en = 'Issue creation failed'"));
	EndIf;

EndProcedure

&AtClient
Procedure CreateNewIssueAtGitHub(Command)
	BeginRunningApplication(UT_CommonClient.ApplicationRunEmptyNotifyDescription(),
		"https://github.com/i-neti/tools_ui_1c_international/issues/new");
EndProcedure

#EndRegion