Function _37583_ALG_GET(Request)
	WebID = Request.URLParameters["AlgWebID"];

	IncomingParametersStructure = New Structure;
	For Each Parameter In Request.QueryOptions Do
		IncomingParametersStructure.Insert(Parameter.Key, Parameter.Value);
	EndDo;
	ResponseStructure = New Structure("StatusCode,ResponseBody", 200, " GET  method processing");

	ProcessRequest(WebID, IncomingParametersStructure, ResponseStructure);

	Response = New HTTPServiceResponse(ResponseStructure.StatusCode);
	Response.SetBodyFromString(ResponseStructure.ResponseBody, TextEncoding.UTF8);
	Response.Headers.Insert("Content-Type", "text/html; charset=utf-8");
	Return Response;
EndFunction

Procedure ProcessRequest(WebID, IncomingParameters, Response)
//	Query = New Query;
//	Query.Text =
//	"Select first 1
//	|   _37583_ALG.Ref AS Algorithm
//	|ИЗ
//	|   Catalog.UT_Algorithms AS _37583_ALG
//	|ГДЕ
//	|   _37583_ALG.HttpID= &WebID";
//
//	Query.SetParameter("WebID", WebID);
//
//	QueryResult = Query.Выполнить();
//	If Не QueryResult.Пустой() Then
//		SelectionDetailRecords = QueryResult.Select();
//		SelectionDetailRecords.Next();
//		sResponse = _37583_AlgorithmsServer.ExecuteFunction(SelectionDetailRecords.Algorithm, IncomingParameters);
//		If IncomingParameters["Cancel"] Then
//			Response.StatusCode = 500;
//			Response.ResponseBody = IncomingParameters.ErrorMessage;
//		Else
//			If sResponse["Result"] = Неопределено Then
//				Response.StatusCode = 500;
//				Response.ResponseBody = "Error:  the result of the function execution is not defined";
//
//			Else
//				Response.ResponseBody =sResponse["Result"];
//			EndIf;
//		EndIf;
//	Else
//		Response.StatusCode = 404;
//		Response.ResponseBody = "Error algorithm not found";
//	EndIf;
EndProcedure
Function _37583_ALG_POST(Request)

	WebID = Request.URLParameters["AlgWebID"];
	SetParameter = Request.URLParameters["SetParameter"];  // true or false

	IncomingParametersStructure = New Structure;
	For Each Parameter In Request.QueryOptions Do
		IncomingParametersStructure.Insert(Parameter.Key, Parameter.Value);
	EndDo;
	ResponseStructure = New Structure("StatusCode,ResponseBody", 200, "POST method processing ");

	ProcessRequest(WebID, IncomingParametersStructure, ResponseStructure);

	Response = New HTTPServiceResponse(ResponseStructure.StatusCode);
	Response.SetBodyFromString(ResponseStructure.ResponseBody, TextEncoding.UTF8);
	Response.Headers.Insert("Content-Type", "text/html; charset=utf-8");
	Return Response;
EndFunction



#Region DataTransfer

Function DataTransferPing(Request)
	Response = New HTTPServiceResponse(200);
	Response.SetBodyFromString("OK");
	Return Response;
EndFunction

Function DataTransferSendFileAndUpload(Request)

	UploadError=False;
	ServiceError="";
	UploadLog="";

	Try

		FileName = GetTempFileName("zip");
		TransferBinaryData=Request.GetBodyAsBinaryData();
		TransferBinaryData.Write(FileName);

		UploadLogFileName=GetTempFileName("txt");

		Processing = DataProcessors.UT_UniversalXMLDataExchange.Create();
		Processing.ExchangeMode = "Load";
		Processing.ExchangeFileName = FileName;
		Processing.ExchangeProtocolFileName=UploadLogFileName;
		Processing.ExchangeProtocolFileEncoding="UTF-8";
		Processing.ExecuteUploading();

		UploadError=Processing.ErrorFlag;
		DeleteFiles(FileName);

		LogFile=New File(UploadLogFileName);
		If LogFile.Exists() Then
			LogText=New TextDocument;
			LogText.Read(UploadLogFileName);

			UploadLog=LogText.GetText();
			LogText=Undefined;

			DeleteFiles(UploadLogFileName);

		EndIf;
	Except
		ServiceError = ErrorDescription();
	EndTry;

	ResponseStructure=New Structure;
	ResponseStructure.Insert("ServiceError", ServiceError);
	ResponseStructure.Insert("UploadError", UploadError);
	ResponseStructure.Insert("UploadLog", UploadLog);

	JSONWriter=New JSONWriter;
	JSONWriter.SetString();

	WriteJSON(JSONWriter, ResponseStructure);

	Response = New HTTPServiceResponse(200);
	Response.Headers.Insert("Content-Type", "application/json; charset=utf-8");
	Response.SetBodyFromString(JSONWriter.Close());
	Return Response;

EndFunction

#EndRegion