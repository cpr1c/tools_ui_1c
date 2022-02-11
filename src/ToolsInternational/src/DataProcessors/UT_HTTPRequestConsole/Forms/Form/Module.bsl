#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	StartHeader = Title;

	InitializeForm();

	Items.RequestBodyEncoding.ChoiceList.Add("System");
	Items.RequestBodyEncoding.ChoiceList.Add("ANSI");
	Items.RequestBodyEncoding.ChoiceList.Add("OEM");
	Items.RequestBodyEncoding.ChoiceList.Add("UTF8");
	Items.RequestBodyEncoding.ChoiceList.Add("UTF16");

	If Parameters.Property("DebugData") Then
		FillByDebugData(Parameters.DebugData);
	EndIf;

	EnableOrDisableRequestBody(ThisObject);
	
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing, Items.FormCommandPanelGroup);
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	BuildProxyOptionsHeader();
EndProcedure

#EndRegion

#Region FormItemsEvents

&AtClient
Procedure RequestHistorySelection(Item, SelectedRow, Field, StandardProcessing)
	FillCurentRequestByHistory(SelectedRow);
EndProcedure

&AtClient
Procedure RequestHistoryOnActivateRow(Item)
	
	CurrentRow = Items.RequestHistory.CurrentData;
	If CurrentRow = Undefined Then
		Return;
	EndIf;

	If CurrentRow.RequestBodyFormat = "String" Then
		NewPage = Items.RequestHistoryRequestBodyStringPageGroup;
	ElsIf CurrentRow.RequestBodyFormat = "BinaryData" Then
		NewPage = Items.RequestHistoryRequestBodyBinaryDataPageGroup;
	Else
		NewPage = Items.RequestHistoryRequestBodyFilePageGroup;
	EndIf;

	Items.RequestHistoryRequestBodyPagesGroup.CurrentPage = NewPage;

	If IsTempStorageURL(CurrentRow.ResponseBodyAddressString) Then
		ResponseBodyString = GetFromTempStorage(CurrentRow.ResponseBodyAddressString);
	Else
		ResponseBodyString = "";
	EndIf;

	ProxyInspectionOptionsHeader = ProxyOptionsHeaderByParams(CurrentRow.UseProxy,
		CurrentRow.ProxyServer, CurrentRow.ProxyPort, CurrentRow.ProxyUser, CurrentRow.ProxyPassword,
		CurrentRow.OSAuthentificationProxy);
		
EndProcedure

&AtClient
Procedure RequestHistoryRequestBodyFileNameOpen(Item, StandardProcessing)
	
	StandardProcessing = False;

	CurrentData = Items.RequestHistory.CurrentData;
	If CurrentData = Undefined Then
		Return;
	Endif;

	BeginRunningApplication(UT_CommonClient.ApplicationRunEmptyNotifyDescription(),
		CurrentData.RequestBodyFileName);
		
EndProcedure

&AtClient
Procedure TableHeadersEditorOnChange(Item)
	
	SetupRequestHeadersEditorPage();
	
EndProcedure

&AtClient
Procedure RequestHeadersTableKeyAutoComplete(Item, Text, ChoiceData, DataGetParameters, Waiting, StandardProcessing)

	StandardProcessing = False;

	If Not ValueIsFilled(Text) Then
		Return;
	EndIf;

	ChoiceData = New ValueList;

	For Each ListElement In UsedHeadersList Do
	 	If StrFind(Lower(ListElement.Value), Lower(Text)) > 0 Then
			ChoiceData.Add(ListElement.Value);
		EndIf;
	EndDo;

EndProcedure

&AtClient
Procedure RequestBodyFormatOnChange(Item)
	
	StringBodyGroupParamsReadOnly = True;

	If RequestBodyFormat = "String" Then
		NewPage = Items.RequestBodyStringPageGroup;
		StringBodyGroupParamsReadOnly = False;
	ElsIf RequestBodyFormat = "BinaryData" Then
		NewPage = Items.RequestBodyBinaryDataPageGroup;
	Else
		NewPage = Items.RequestBodyFilePageGroup;
	EndIf;

	Items.RequestBodyPagesGroup.CurrentPage = NewPage;
	Items.RequestBodyStringPropertiesGroup.ReadOnly = StringBodyGroupParamsReadOnly;
	
EndProcedure

&AtClient
Procedure RequestBodyFileNameStartChoice(Item, ChoiceData, StandardProcessing)
	
	FileDialog = New FileDialog(FileDialogMode.Open);
	FileDialog.Multiselect = False;
	FileDialog.FullFileName = RequestBodyFileName;

	FileDialog.Show(New NotifyDescription("RequestBodyFileNameChoiceComplete", ThisObject));
	
EndProcedure

&AtClient
Procedure HTTPRequestOnChange(Item)
	EnableOrDisableRequestBody(ThisObject);
EndProcedure

&AtClient
Procedure UseProxyOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

&AtClient
Procedure ProxyServerOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

&AtClient
Procedure ProxyPortOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

&AtClient
Procedure ProxyUserOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

&AtClient
Procedure ProxyPasswordOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

&AtClient
Procedure ProxyOSAuthOnChange(Item)
	BuildProxyOptionsHeader();
EndProcedure

#EndRegion

#Region FormCommandEvents

&AtClient
Procedure ExecuteRequest(Command)
	
	If RequestBodyFormat = "File" Then
		RequestBodyFileAddress = PutToTempStorage(New BinaryData(RequestBodyFileName),
			RequestBodyFileAddress);
	EndIf;
	ExecuteRequestServer();
	
	//place request history to current row
	If RequestHistory.Count() > 0 Then
		Items.RequestHistory.CurrentRow = RequestHistory[RequestHistory.Count() - 1].GetID();
	EndIf;
	
EndProcedure


&AtClient
Procedure FillRequestBinaryDataFromFile(Command)
	
	BeginPutFile(New NotifyDescription("FillRequestBinaryDataFromFileComplete", ThisObject),
		RequestBodyBinaryDataAddress, "", True, UUID);
		
EndProcedure

&AtClient
Procedure SaveRequestBodyBinaryDataFromHistory(Command)
	
	RequestHistoryCurrentData = Items.RequestHistory.CurrentData;
	If RequestHistoryCurrentData = Undefined Then
		Return;
	EndIf;

	If Not IsTempStorageURL(RequestHistoryCurrentData.RequestBodyBinaryDataAddress) Then
		Return;
	EndIf;

	FileDialog = New FileDialog(FileDialogMode.Save);
	FileDialog.Multiselect = False;

	ResponseFiles = New Array;
	ResponseFiles.Add(New TransferableFileDescription(, RequestHistoryCurrentData.RequestBodyBinaryDataAddress));

	BeginGettingFiles(New NotifyDescription("SaveRequestBodyBinaryDataFromHistoryComplete",
		ThisObject), ResponseFiles, FileDialog, True);
		
EndProcedure

&AtClient
Procedure SaveResponseBodyBinaryDataToFile(Command)
	
	RequestHistoryCurrentData = Items.RequestHistory.CurrentData;
	If RequestHistoryCurrentData = Undefined Then
		Return;
	EndIf;

	If Not IsTempStorageURL(RequestHistoryCurrentData.ResponseBodyBinaryDataAddress) Then
		Return;
	EndIf;

	FileDialog = New FileDialog(FileDialogMode.Save);
	FileDialog.Multiselect = False;

	ResponseFiles = New Array;
	ResponseFiles.Add(New TransferableFileDescription(, RequestHistoryCurrentData.ResponseBodyBinaryDataAddress));

	BeginGettingFiles(New NotifyDescription("SaveRequestBodyBinaryDataFromHistoryComplete",
		ThisObject), ResponseFiles, FileDialog, True);
		
EndProcedure

&AtClient
Procedure NewRequestsFile(Command)
	
	If RequestHistory.Count() = 0 Then
		InitializeConsole();
	Else
		ShowQueryBox(New NotifyDescription("NewRequestsFileComplete", ThisObject),
			NStr("en = 'Request history is not empty. Continue?'"), QuestionDialogMode.YesNo, 15, DialogReturnCode.No);
	EndIf;
	
EndProcedure

&AtClient
Procedure OpenRequestsFile(Command)	
	
	If RequestHistory.Count() = 0 Then
		LoadConsoleFile();
	Else
		ShowQueryBox(New NotifyDescription("OpenRequestsFileComplete", ThisObject),
			NStr("en = 'Request history is not empty. Continue?"), QuestionDialogMode.YesNo, 15, DialogReturnCode.No);
	EndIf;
	
EndProcedure

&AtClient
Function SavedFileDescriptionStructure()
	
	Struct = UT_CommonClient.EmptyDescriptionStructureOfSelectedFile();
	Struct.FileName = RequestsFileName;

	UT_CommonClient.AddFormatToSavingFileDescription(Struct,
		"Console request file HTTP with JSON (*.jhttp)", "jhttp");
	UT_CommonClient.AddFormatToSavingFileDescription(Struct, "Console request file HTTP (*.xhttp)",
		"xhttp");

	Return Struct;
	
EndFunction

&AtClient
Procedure SaveRequestsToFile(Command)
	
	UT_CommonClient.SaveConsoleDataToFile("HTTPRequestConsole", False,
		SavedFileDescriptionStructure(), PutHistoryDataToTempStorage(),
		New NotifyDescription("SaveToFileComplete", ThisObject));
		
EndProcedure

&AtClient
Procedure SaveAsRequestsToFile(Command)
	
	UT_CommonClient.SaveConsoleDataToFile("HTTPRequestConsole", True,
		SavedFileDescriptionStructure(), PutHistoryDataToTempStorage(),
		New NotifyDescription("SaveToFileComplete", ThisObject));
		
EndProcedure

&AtClient
Procedure EditRequestBodyInJSONEditor(Command)
	
	UT_CommonClient.EditJSON(RequestBody, False,
		New NotifyDescription("EditRequestBodyInJSONEditorComplete", ThisObject));
		
EndProcedure

&AtClient
Procedure EditRequestBodyInJSONEditorAnalyzedRequest(Command)
	
	UT_CommonClient.EditJSON(Items.RequestHistory.CurrentData.RequestBodyString, True);
	
EndProcedure

&AtClient
Procedure EditResponseBodyInJSONEditorAnalyzedRequest(Command)
	
	UT_CommonClient.EditJSON(ResponseBodyString, True);
	
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
	
EndProcedure

#EndRegion

#Region RequestFiles

&AtClient
Procedure DoLoadByAddress(Address)
	
	Try
		LoadConsoleFileAtServer(Address);
		InitializeRequest();
	Except
		RequestsFileName = "";
		Return;
	EndTry;
	
	UpdateTitle();
	
EndProcedure

// Load console file at server.
//
// Params:
//  Address - temporary storage url for loading file.
&AtServer
Procedure LoadConsoleFileAtServer(Address)

	HistoryTable = DataProcessors.UT_HTTPRequestConsole.SavedDataFromSerializedString(Address, RequestsFileName);

	RequestHistory.Clear();

	For Each TableRow In HistoryTable Do
		
		NewRow = RequestHistory.Add();
		FillPropertyValues(NewRow, TableRow);

		NewRow.RequestBodyBinaryDataAddress = PutToTempStorage(TableRow.RequestBodyBinaryData,
			UUID);
		NewRow.ResponseBodyBinaryDataAddress = PutToTempStorage(TableRow.RequestBodyBinaryData,
			UUID);
		NewRow.ResponseBodyAddressString = PutToTempStorage(TableRow.ResponseBody, UUID);
		
	EndDo;
	
EndProcedure

&AtClient
Procedure LoadConsoleFileComplete(Result, AdditionalParameters) Export
	
	If Result = Undefined Then
		Return;
	Endif;

	RequestsFileName = Result.FileName;
	DoLoadByAddress(Result.Address);

EndProcedure

// Load file.
&AtClient
Procedure LoadConsoleFile()

	UT_CommonClient.ReadConsoleFromFile("HTTPRequestConsole",
		SavedFileDescriptionStructure(), New NotifyDescription("LoadConsoleFileComplete",
		ThisObject));

EndProcedure

// Open requests file complete.
&AtClient
Procedure OpenRequestsFileComplete(Result, AdditionalParameters) Export

	If Result = DialogReturnCode.No Then
		Return;
	EndIf;
	LoadConsoleFile();

EndProcedure

&AtClient
Procedure InitializeConsole()
	
	RequestHistory.Clear();
	InitializeRequest();
	
EndProcedure

// new requests file complete.
&AtClient
Procedure NewRequestsFileComplete(QuestionResult, AdditionalParameters) Export

	If QuestionResult = DialogReturnCode.No Then
		Return;
	EndIf;

	InitializeConsole();

EndProcedure


&AtClient
Procedure SaveToFileComplete(Result, AdditionalParameters) Export
	
	If Result = Undefined Then
		Return;
	EndIf;

	RequestsFileName = Result;
	Modified = False;
	UpdateTitle();

EndProcedure

// Put file to temporary storage
&AtServer
Function PutHistoryDataToTempStorage()

	HistoryTable = FormAttributeToValue("RequestHistory");

	HistoryTable.Columns.Add("RequestBodyBinaryData");
	HistoryTable.Columns.Add("ResponseBodyBinaryData");
	HistoryTable.Columns.Add("ResponseBody");
	
	For Each TableRow In HistoryTable Do
		If IsTempStorageURL(TableRow.RequestBodyBinaryDataAddress) Then
			TableRow.RequestBodyBinaryData = GetFromTempStorage(TableRow.RequestBodyBinaryDataAddress);
		EndIf;
		If IsTempStorageURL(TableRow.ResponseBodyBinaryDataAddress) Then
			TableRow.ResponseBodyBinaryData = GetFromTempStorage(TableRow.ResponseBodyBinaryDataAddress);
		EndIf;
		If IsTempStorageURL(TableRow.ResponseBodyAddressString) Then
			TableRow.ResponseBody = GetFromTempStorage(TableRow.ResponseBodyAddressString);
		EndIf;
	EndDo;

	HistoryTable.Columns.Delete("RequestBodyBinaryDataAddress");
	HistoryTable.Columns.Delete("ResponseBodyBinaryDataAddress");
	HistoryTable.Columns.Delete("ResponseBodyAddressString");

	Result = PutToTempStorage(HistoryTable, UUID);
	Return Result;

	JSONSerializer = DataProcessors.УИ_ПреобразованиеДанныхJSON.Create();

	HistoryStruct = JSONSerializer.ЗначениеВСтруктуру(HistoryTable);
	HistoryRowJSON = JSONSerializer.ЗаписатьОписаниеОбъектаВJSON(HistoryStruct);
	TempFileName = GetTempFileName();

	ValueToFile(TempFileName, HistoryTable);
	Result = PutToTempStorage(New BinaryData(TempFileName));

	Try
		DeleteFiles(TempFileName);
	Except
	EndTry;

	Return Result;

EndFunction

#EndRegion

#Region RequestExecute

&AtServer
Function PreparedConnection(URLStructure)
	
	Port = Undefined;
	If ValueIsFilled(URLStructure.Port) Then
		Port = URLStructure.Port;
	EndIf;
	
	If UseProxy Then
		ProxyOptions = New InternetProxy(True);
		ProxyOptions.Set(URLStructure.Scheme, ProxyServer, ProxyPort, ProxyUser, ProxyPassword,
			OSAuthentificationProxy);
	Else
		ProxyOptions = Undefined;
	EndIf;

	If Lower(URLStructure.Scheme) = "https" Then
		HTTPConnection = New HTTPConnection(URLStructure.Host, Port, , , ProxyOptions, Timeout,
			New OpenSSLSecureConnection);
	Else
		HTTPConnection = New HTTPConnection(URLStructure.Host, Port, , , ProxyOptions, Timeout);
	EndIf;

	Return HTTPConnection;
	
EndFunction

&AtServer
Function PreparedHTTPRequest(URLStructure)
	
	NewRequest = New HTTPRequest;

	RequestString = URLStructure.Path;

	ParamsString = "";
	For Each KeyAndValue In URLStructure.RequestParameters Do
		ParamsString = ParamsString + ?(ValueIsFilled(ParamsString), "?", "&") + KeyAndValue.Key + "="
			+ KeyAndValue.Value;
	EndDo;

	NewRequest.ResourceAddress = RequestString + ParamsString;
	If Not RequestWithoutBody(HTTPMethod) Then
		If RequestBodyFormat = "String" Then
			If ValueIsFilled(RequestBody) Then
				If (UseBOM = 0) Then
					BOM = ByteOrderMarkUsage.Auto;
				ElsIf (UseBOM = 1) Then
					BOM = ByteOrderMarkUsage.Use;
				Else
					BOM = ByteOrderMarkUsage.DontUse;
				EndIf;

				If RequestBodyEncoding = "Auto" Then
					NewRequest.SetBodyFromString(RequestBody, , BOM);
				Else
					NewRequest.SetBodyFromString(RequestBody, RequestBodyEncoding, BOM);
				EndIf;
			EndIf;
		ElsIf RequestBodyFormat = "BinaryData" Then
			BodyBinaryData = GetFromTempStorage(RequestBodyBinaryDataAddress);
			If TypeOf(BodyBinaryData) = Type("BinaryData") Then
				NewRequest.SetBodyFromBinaryData(BodyBinaryData);
			EndIf;
		Else
			BodyBinaryData = GetFromTempStorage(RequestBodyFileAddress);
			If TypeOf(BodyBinaryData) = Type("BinaryData") Then
				File = New File(RequestBodyFileName);
				TempFile = GetTempFileName(File.Extension);
				BodyBinaryData.Write(TempFile);

				NewRequest.SetBodyFileName(TempFile);
			EndIf;
		EndIf;
	EndIf;

	//Now we should set request headers
	If TableHeadersEditor Then
		Headers = New Map();

		For Each HeaderString In RequestHeadersTable Do
			Headers.Insert(HeaderString.Key, HeaderString.Value);
		EndDo;
	Else
		Headers = UT_CommonClientServer.HTTPRequestHeadersFromString(HeadersString);
	EndIf;

	NewRequest.Headers = Headers;

	Return NewRequest;
	
EndFunction

&AtServer
Procedure ExecuteRequestServer()
	
	URLStructure = UT_HTTPConnector.ParseURL(RequestURL);

	HTTPConnection = PreparedConnection(URLStructure);

	ExecutionStart = CurrentUniversalDateInMilliseconds();
	Request = PreparedHTTPRequest(URLStructure);
	DateStart = CurrentDate();
	Try
		If HTTPMethod = "GET" Then
			Response = HTTPConnection.Get(Request);
		ElsIf HTTPMethod = "POST" Then
			Response = HTTPConnection.Post(Request);
		ElsIf HTTPMethod = "DELETE" Then
			Response = HTTPConnection.Delete(Request);
		ElsIf HTTPMethod = "PUT" Then
			Response = HTTPConnection.Put(Request);
		ElsIf HTTPMethod = "PATCH" Then
			Response = HTTPConnection.Patch(Request);
		Else
			Return;
		EndIf;
	Except

	EndTry;
	ExecutionEnd = CurrentUniversalDateInMilliseconds();

	MillisecondsDuration = ExecutionEnd - ExecutionStart;

	WriteRequestLog(URLStructure.Host, URLStructure.Scheme, Request, Response, DateStart,
		MillisecondsDuration);

	AppendUsedHeadersList(Request.Headers);
	
EndProcedure

&AtServer
Procedure AppendUsedHeadersList(Headers)
	
	For Each KeyAndValue In Headers Do
		If UsedHeadersList.FindByValue(KeyAndValue.Key) = Undefined Then
			UsedHeadersList.Add(KeyAndValue.Key);
		EndIf;
	EndDo;
	
EndProcedure


&AtServer
Procedure WriteRequestLog(Host, Scheme, HTTPRequest, HTTPResponse, DateStart, Duration)

	//	If HTTPResponse = Undefined Then 
	//		Error = True;
	//	Else 
	//		Error = Not RequestExecuteSuccessful(HTTPResponse);//.HTTPStatusCode<>SuccessCode;
	//	EndIf;
	LogRec = RequestHistory.Add();
	LogRec.URL = RequestURL;

	LogRec.HTTPMethod = HTTPMethod;
	LogRec.Host = Host;
	LogRec.Date = DateStart;
	LogRec.RequestTiming = Duration;
	LogRec.Request = HTTPRequest.ResourceAddress;
	LogRec.RequestHeaders = UT_CommonClientServer.GetHTTPHeadersString(HTTPRequest.Headers);
	LogRec.BOM = UseBOM;
	LogRec.RequestBodyEncoding = RequestBodyEncoding;
	LogRec.RequestBodyFormat = RequestBodyFormat;
	LogRec.Timeout = Timeout;

	LogRec.RequestBodyString = HTTPRequest.GetBodyAsString();

	BodyBinaryData = HTTPRequest.GetBodyAsBinaryData();
	LogRec.RequestBodyBinaryDataAddress = PutToTempStorage(BodyBinaryData, UUID);
	LogRec.RequestBodyBinaryDataString = String(BodyBinaryData);
	LogRec.RequestBodyFileName = RequestBodyFileName;
	LogRec.Scheme = Scheme;

	// Proxy
	LogRec.UseProxy = UseProxy;
	LogRec.ProxyServer = ProxyServer;
	LogRec.ProxyPort = ProxyPort;
	LogRec.ProxyUser = ProxyUser;
	LogRec.ProxyPassword = ProxyPassword;
	LogRec.OSAuthentificationProxy = OSAuthentificationProxy;

	LogRec.HTTPStatusCode = ?(HTTPResponse = Undefined, 500, HTTPResponse.StatusCode);

	If HTTPResponse = Undefined Then
		Return;
	EndIf;

	LogRec.ResponseHeaders = UT_CommonClientServer.GetHTTPHeadersString(HTTPResponse.Headers);

	ResponseBodyStringLog = HTTPResponse.GetBodyAsString();
	If ValueIsFilled(ResponseBodyStringLog) Then
		If FindDisallowedXMLCharacters(ResponseBodyStringLog) = 0 Then
			LogRec.ResponseBodyAddressString = PutToTempStorage(ResponseBodyStringLog, UUID);
		Else
			LogRec.ResponseBodyAddressString = PutToTempStorage("Contains disallowed XML characters", UUID);
		EndIf;
	EndIf;
	ResposeBinaryData = HTTPResponse.GetBodyAsBinaryData();
	If ResposeBinaryData <> Undefined Then
		LogRec.ResponseBodyBinaryDataAddress = PutToTempStorage(ResposeBinaryData, UUID);
		LogRec.ResponseBodyBinaryDataString = String(ResposeBinaryData);
	EndIf;

	ResponseFileName = HTTPResponse.GetBodyFileName();
	If ResponseFileName <> Undefined Then
		File = New File(ResponseFileName);
		If File.Exist() Then
			ResponseBinaryData = New BinaryData(ResponseFileName);
			LogRec.ResponseBodyBinaryDataAddress = PutToTempStorage(ResponseBinaryData, UUID);
			LogRec.ResponseBodyBinaryDataString = String(ResponseBinaryData);

		EndIf;
	EndIf;
	
EndProcedure

#EndRegion

#Region UtilizationProceduresAndFunctions

// update form title
&AtClient
Procedure UpdateTitle()

	Title = StartHeader + ?(RequestsFileName <> "", ": " + RequestsFileName, "");

EndProcedure

&AtClientAtServerNoContext
Function ProxyOptionsHeaderByParams(ParamUseProxy, ParamServer, ParamPort, ParamUser, ParamPassword, ParamOSAuth)

	HeaderPrefix = "";

	If ParamUseProxy Then
		
		HeaderGroupProxy = HeaderPrefix + ParamServer;
		If ValueIsFilled(ParamPort) Then
			HeaderGroupProxy = HeaderGroupProxy + ":" + Format(ParamPort, "NG=0;");
		EndIf;

		If ParamOSAuth Then
			HeaderGroupProxy = HeaderGroupProxy + "; OS authentification";
		ElsIf ValueIsFilled(ParamUser) Then
			HeaderGroupProxy = HeaderGroupProxy + ";" + ParamUser;
		EndIf;

	Else
		HeaderGroupProxy = HeaderPrefix + " Not selected";
	EndIf;

	Return HeaderGroupProxy;
	
EndFunction

&AtClient
Procedure BuildProxyOptionsHeader()
	
	ProxyOptionsHeader = ProxyOptionsHeaderByParams(UseProxy, ProxyServer, ProxyPort,
		ProxyUser, ProxyPassword, OSAuthentificationProxy);
		
EndProcedure

&AtClient
Procedure SaveRequestBodyBinaryDataFromHistoryComplete(ReceiveFiles, AdditionalParameters) Export
	
	If ReceiveFiles = Undefined Then
		Return;
	EndIf;

EndProcedure

&AtClientAtServerNoContext
Function RequestWithoutBody(HTTPMethodType)
	
	MethodList = New Array;
	MethodList.Add("GET");
	MethodList.Add("DELETE");

	Return MethodList.Find(Upper(HTTPMethodType)) <> Undefined;

EndFunction

&AtClientAtServerNoContext
Procedure EnableOrDisableRequestBody(Form)
	
	Form.Items.RequestBodyGroup.ReadOnly = RequestWithoutBody(Form.HTTPMethod);
	
EndProcedure

&AtClient
Procedure FillRequestBinaryDataFromFileComplete(Result, Address, SelectedFileName, AdditionalParameters) Export
	
	If Not Result Then
		Return;
	EndIf;

	RequestBodyBinaryDataAddress = Address;

	RequestBodyBinaryDataString = String(GetFromTempStorage(Address));
	
EndProcedure

&AtClient
Procedure RequestBodyFileNameChoiceComplete(SelectedFiles, AdditionalParameters) Export

	If SelectedFiles = Undefined Then
		Return;
	EndIf;

	If SelectedFiles.Count() = 0 Then
		Return;
	EndIf;

	RequestBodyFileName = SelectedFiles[0];
	
EndProcedure

&AtServer
Procedure FillHeaderTableByRow(HeadersRow)
	
	HeadersByRow = UT_CommonClientServer.HTTPRequestHeadersFromString(HeadersRow);

	RequestHeadersTable.Clear();

	For Each KeyAndValue In HeadersByRow Do
		NewRec = RequestHeadersTable.Add();
		NewRec.Key = KeyAndValue.Key;
		NewRec.Value = KeyAndValue.Value;
	EndDo;

EndProcedure

&AtClient
Procedure SetupRequestHeadersEditorPage()
	
	If TableHeadersEditor Then
		NewPage = Items.RequestHeadersTableEditPageGroup;
	Else
		NewPage = Items.RequestHeadersTextEditPageGroup;
	EndIf;

	Items.RequestHeadersEditPagesGroup.CurrentPage = NewPage;

	//now we will copy headers from old page to new one
	If TableHeadersEditor Then
		FillHeaderTableByRow(HeadersString);
	Else
		HeadersString = UT_CommonClientServer.GetHTTPHeadersString(RequestHeadersTable);
	EndIf;
	
EndProcedure

&AtClient
Procedure FillCurentRequestByHistory(SelectedRow)

	//copy data from current row
	CurrentData = RequestHistory.FindByID(SelectedRow);

	If CurrentData = Undefined Then
		Return;
	EndIf;

	HTTPMethod = CurrentData.HTTPMethod;
	RequestURL = CurrentData.URL;
	HeadersString = CurrentData.RequestHeaders;
	RequestBody = CurrentData.RequestBodyString;
	RequestBodyEncoding = CurrentData.RequestBodyEncoding;
	UseBOM = CurrentData.BOM;
	RequestBodyFormat = CurrentData.RequestBodyFormat;
	RequestBodyFormatOnChange(Items.RequestBodyFormat);
	RequestBodyFileName = CurrentData.RequestBodyFileName;
	Timeout = CurrentData.Timeout;

	UseProxy = CurrentData.UseProxy;
	ProxyServer = CurrentData.ProxyServer;
	ProxyPort = CurrentData.ProxyPort;
	ProxyUser = CurrentData.ProxyUser;
	ProxyPassword = CurrentData.ProxyPassword;
	OSAuthentificationProxy = CurrentData.OSAuthentificationProxy;

	If IsTempStorageURL(CurrentData.RequestBodyBinaryDataAddress) Then
		RequestBodyBinaryData = GetFromTempStorage(CurrentData.RequestBodyBinaryDataAddress);
		RequestBodyBinaryDataString = String(RequestBodyBinaryData);
		If TypeOf(RequestBodyBinaryData) = Type("BinaryData") Then
			RequestBodyBinaryDataAddress = PutToTempStorage(RequestBodyBinaryData,
				RequestBodyBinaryDataAddress);
		EndIf;
	EndIf;

	RequestHeadersTable.Clear();
	If TableHeadersEditor Then
		FillHeaderTableByRow(HeadersString);
	EndIf;

	Items.RequestPagesGroup.CurrentPage = Items.RequestGroup;
	
EndProcedure

&AtServer
Procedure FillByDebugData(DebugDataAddress)
	
	DebugData = GetFromTempStorage(DebugDataAddress);

	RequestURL = "";
	If Not ValueIsFilled(DebugData.Scheme) Then
		RequestURL = "http";
	Else
		RequestURL = DebugData.Scheme;
	EndIf;

	RequestURL = RequestURL + "://" + DebugData.Host;

	If ValueIsFilled(DebugData.Port) Then
		RequestURL = RequestURL + ":" + Format(DebugData.Port, "ЧГ=0;");
	EndIf;

	If Not StrStartsWith(DebugData.Request, "/") Then
		RequestURL = RequestURL + "/";
	EndIf;

	RequestURL = RequestURL + DebugData.Request;
	TableHeadersEditor = True;

	Items.RequestHeadersEditPagesGroup.CurrentPage = Items.RequestHeadersTableEditPageGroup;

	RequestHeaders = DebugData.RequestHeaders;

	//Delete disallowed chars from headers
	SymPos = FindDisallowedXMLCharacters(RequestHeaders);
	While (SymPos > 0) do
		If SymPos = 1 Then
			RequestHeaders = Mid(RequestHeaders, 2);
		ElsIf SymPos = StrLen(RequestHeaders) Then
			RequestHeaders = Left(RequestHeaders, StrLen(RequestHeaders) - 1);
		Else
			NewHeaders = Left(RequestHeaders, SymPos - 1) + Mid(RequestHeaders, SymPos + 1);
			RequestHeaders = NewHeaders;
		EndIf;


		SymPos = FindDisallowedXMLCharacters(RequestHeaders);
	EndDo;

	FillHeaderTableByRow(RequestHeaders);

	If DebugData.RequestBody = Undefined Then
		RequestBody = "";
	Else
		RequestBody = DebugData.RequestBody;
	EndIf;

	If DebugData.Property("RequestBodyBinaryData") Then
		If TypeOf(DebugData.RequestBodyBinaryData) = Type("BinaryData") Then
			RequestBodyBinaryDataAddress = PutToTempStorage(DebugData.RequestBodyBinaryData,
				RequestBodyBinaryDataAddress);
			RequestBodyBinaryDataString = DebugData.RequestBodyBinaryDataString;
		EndIf;
	EndIf;
	
	If DebugData.Property("RequestBodyFileName") Then
		RequestBodyFileName = DebugData.RequestBodyFileName;
	EndIf;

	If ValueIsFilled(DebugData.ProxyServer) Then
		UseProxy = True;

		ProxyServer = DebugData.ProxyServer;
		ProxyPort = DebugData.ProxyPort;
		ProxyUser = DebugData.ProxyUser;
		ProxyPassword = DebugData.ProxyPassword;
		OSAuthentificationProxy = DebugData.OSAuthentificationProxy;
	Else
		UseProxy = False;
	EndIf;
	
EndProcedure

&AtServer
Procedure InitializeForm()
	
	HTTPMethod = "GET";
	RequestBodyEncoding = "Auto";
	RequestBodyFormat = "String";
	Timeout=30;
	RequestBodyFileAddress = PutToTempStorage(New Structure, UUID);
	RequestBodyBinaryDataAddress = PutToTempStorage(Undefined, UUID);
	
EndProcedure

&AtClient
Procedure InitializeRequest()
	
	HTTPMethod = "GET";
	RequestBodyEncoding = "Auto";
	RequestBodyFormat = "String";
	RequestBodyFileAddress = PutToTempStorage(New Structure, UUID);
	RequestBodyBinaryDataAddress = PutToTempStorage(Undefined, UUID);
	RequestURL = "";
	UseBOM = 0;

	//proxy
	UseProxy = False;
	ProxyServer = "";
	ProxyPort = 0;
	ProxyUser = "";
	ProxyPassword = "";
	OSAuthentificationProxy = False;

	HeadersString = "";
	RequestHeadersTable.Clear();

	RequestBody = "";
	RequestBodyBinaryDataString = "";
	RequestBodyFileName = "";
	
EndProcedure

&AtClient
Procedure EditRequestBodyInJSONEditorComplete(Result, AdditionalParameters) Export
	
	If Result = Undefined Then
		Return;
	EndIf;

	RequestBody = Result;
	
EndProcedure

#EndRegion