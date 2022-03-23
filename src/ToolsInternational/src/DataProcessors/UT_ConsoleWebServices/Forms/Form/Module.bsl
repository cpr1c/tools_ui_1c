Var WSDefinition;

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);
EndProcedure


&AtServer
Procedure ConnectToServer(LocationWSDL, UserName, Password)
	// Connect to the server knowing the WSDL
	ssl = New OpenSSLSecureConnection;
	WSDefinition = New WSDefinitions(LocationWSDL, UserName, Password, , , ssl);
	//update the list of web services
	ListServices.Clear();
	ListPointsConnections.Clear();
	ListOperations.Clear();
	ListParameters.Clear();
	// Reading web services
	For Each Service In WSDefinition.Services Do
		NewService = ListServices.Add();
		NewService.LocationWSDL = LocationWSDL;
		NewService.WSService = Service.Name;
		NewService.NamespaceURI = Service.NamespaceURI;
		// Read connection points to create a proxy
		For Each Endpoint In Service.Endpoins Do
			UniqueConnectionPointIdentifier = New UUID;
			NewPointConnection = ListPointsConnections.Add();
			NewPointConnection.WSService = Service.Name;
			NewPointConnection.NamePointConnections = Endpoint.Name;
			NewPointConnection.UniqueConnectionPointIdentifier = UniqueConnectionPointIdentifier;
			// Reading web service operations
			For Each Operation In Endpoint.Interface.Operations Do
				NewOperation = ListOperations.Add();
				NewOperation.NamePointConnections = Endpoint.Name;
				NewOperation.OperationName = Operation.Name;
				NewOperation.ReturnableValueType = Operation.ReturnValue.Type;
				NewOperation.UniqueConnectionPointIdentifier = UniqueConnectionPointIdentifier;
				// Reading operation parameters
				For Each Parameter In Operation.Parameters Do
					NewParameter = ListParameters.Add();
					NewParameter.OperationName = Operation.Name;
					NewParameter.NamePointConnections = Endpoint.Name;
					NewParameter.ParameterName = Parameter.Name;
					NewParameter.ParameterType = Parameter.Type;
				EndDo;
			EndDo;
		EndDo;
	EndDo;
EndProcedure

&AtClient
Procedure GetWSDL(Command)
	If ValueIsFilled(LocationWSDL) Then
		ConnectToServer(LocationWSDL, UserName, Password);
		ThisForm.Items.ListServices.SelectedRows.Add(0);
		ThisForm.Items.ListServices.Update();
		ThisForm.Items.ListPointsConnections.SelectedRows.Add(0);
		ThisForm.Items.ListPointsConnections.Update();
		ThisForm.Items.ListOperations.SelectedRows.Add(0);
		ThisForm.Items.ListOperations.Update();
	EndIf;
EndProcedure

&AtClient
Procedure ListServicesOnActivateRow(Item)
	If Items.ListServices.CurrentData <> Undefined Then
		WebServiceName =  Items.ListServices.CurrentData.WSService;
		WebServiceNamespaceURI = Items.ListServices.CurrentData.NamespaceURI;
	Else
		WebServiceName =  "";
		WebServiceNamespaceURI = "";
	EndIf;
	Filter = New FixedStructure("WSService", WebServiceName);
	Items.ListPointsConnections.RowFilter	= Filter;
EndProcedure

&AtClient
Procedure ListPointsConnectionsOnActivateRow(Item)
	If Items.ListPointsConnections.CurrentData <> Undefined Then
		NamePointConnections = Items.ListPointsConnections.CurrentData.NamePointConnections;
		UniqueConnectionPointIdentifier = Items.ListPointsConnections.CurrentData.UniqueConnectionPointIdentifier;
	Else
		NamePointConnections = "";
		UniqueConnectionPointIdentifier = "";
	EndIf;
	Filter = New FixedStructure("UniqueConnectionPointIdentifier",
		UniqueConnectionPointIdentifier);
	Items.ListOperations.RowFilter	= Filter;
EndProcedure

&AtClient
Procedure ListOperationsOnActivateRow(Item)
	If NamePointConnections <> "" And Items.ListOperations.CurrentData <> Undefined Then
		OperationName =  Items.ListOperations.CurrentData.OperationName;
		UpdateParametersOperations(NamePointConnections, OperationName);
	Else
		OperationName = "";
	EndIf;
EndProcedure

&AtServer
Procedure UpdateParametersOperations(NamePointConnections, OperationName)
	If NamePointConnections = ConnectionPointNameCurrent And OperationName = OperationNameCurrent Then
		Return;
	EndIf;
	Filter = New Structure("NamePointConnections,OperationName", NamePointConnections, OperationName);
	ArrayParametersOperations = ListParameters.FindRows(Filter);
	// Clear the operation parameter table
	OperationParameters.Clear();
	
	// Let's create WSdefinitions in order to get the XDTO factory of the web service so that we can try to cast the web service types. to simple types
	ssl = New OpenSSLSecureConnection;
	WSDefinition = New WSDefinitions(LocationWSDL, UserName, Password, , , ssl);
	Serializer = New XDTOSerializer(WSDefinition.XDTOFactory);

	For Each Parameter In ArrayParametersOperations Do
		NewParameter = OperationParameters.Add();
		NewParameter.ParameterName = Parameter.ParameterName;
		NewParameter.ParameterType = Parameter.ParameterType;
		PositionSecondParentheses = Find(Parameter.ParameterType, "}");
	EndDo;
	OperationNameCurrent = OperationName;
	ConnectionPointNameCurrent = NamePointConnections;
EndProcedure

&AtClient
Procedure ExecuteOperation(Command)
	If ValueIsFilled(LocationWSDL) And ValueIsFilled(WebServiceName) And ValueIsFilled(
		WebServiceNamespaceURI) And ValueIsFilled(NamePointConnections) And ValueIsFilled(OperationName) Then
		ResultOperations = ExecuteOperationAtServer(LocationWSDL, UserName, Password, WebServiceName,
			WebServiceNamespaceURI, NamePointConnections, OperationName, OperationParameters);
		If Not ThisForm.Items.TreeResult.RowData(1) = Undefined Then
			ThisForm.Items.TreeResult.Expand(1, True);
		EndIf;
	Else
		Message(NStr("ru = 'Не все параметры выбраны!';en = 'Not all options are selected!'"));
	EndIf;
EndProcedure

&AtServer
Function ExecuteOperationAtServer(LocationWSDL, UserName, Password, WebServiceName,
	WebServiceNamespaceURI, NamePointConnections, OperationName, Val OperationParameters)
	Result = Undefined;
	ssl = New OpenSSLSecureConnection;
	WSDefinition = New WSDefinitions(LocationWSDL, UserName, Password, , , ssl);
	WSProxy = New WSProxy(WSDefinition, WebServiceNamespaceURI, WebServiceName, NamePointConnections, , , ssl);
	WSProxy.User = UserName;
	WSProxy.Password = Password;
	CallCodeOperation = "Result = WSProxy." + OperationName + "(";
	AddComma = False;
	ParameterNumber = 0;
	For Each Parameter In OperationParameters Do
		If AddComma Then
			CallCodeOperation = CallCodeOperation + ", ";
		EndIf;
		// Let's handle the case when the Undefined checkbox is set. In this case, 1C sends null
		If Parameter.Undefined Then
			CallCodeOperation = CallCodeOperation + "Undefined";
		ElsIf Parameter.ParameterType = "{http://v8.1c.ru/8.1/data/core}Structure" Then
			If TypeOf(Parameter.Structure) = Type("Structure") Then
				CallCodeOperation = CallCodeOperation + "XDTOSerializer.WriteXDTO(OperationParameters[" + String(
					ParameterNumber) + "].Structure)";
			Else
				CallCodeOperation = CallCodeOperation + "XDTOSerializer.WriteXDTO(New Structure)";
			EndIf;
		ElsIf TypeOf(Parameter.Value) = Type("String") Then
			CallCodeOperation = CallCodeOperation + """" + Parameter.Value + """";
		ElsIf TypeOf(Parameter.Value) = Type("Number") Then
			CallCodeOperation = CallCodeOperation + Parameter.Value;
		ElsIf TypeOf(Parameter.Value) = Type("Boolean") Then
			If Parameter.Value = True Then
				CallCodeOperation = CallCodeOperation + "True";
			Else
				CallCodeOperation = CallCodeOperation + "False";
			EndIf;
		ElsIf TypeOf(Parameter.Value) = Type("Date") Then
			If ValueIsFilled(Parameter.Value) Then
				CallCodeOperation = CallCodeOperation + "'" + Format(Parameter.Value, "ДФ=""ггггММддЧЧммсс""") + "'";
			Else
				CallCodeOperation = CallCodeOperation + "'00010101000000'";
			EndIf;
		Else
			CallCodeOperation = CallCodeOperation + """" + Parameter.Value + """";
		EndIf;
		AddComma = True;
		ParameterNumber = ParameterNumber + 1;
	EndDo;
	CallCodeOperation = CallCodeOperation + ");";
	Execute (CallCodeOperation);

	If TypeOf(Result) = Type("XDTODataObject") Or TypeOf(Result) = Type("XDTODataValue") Then
		XMLWriter = New XMLWriter;
		XMLWriter.SetString();
		WSDefinition.XDTOFactory.WriteXML(XMLWriter, Result);
		ValueTree = FormAttributeToValue("TreeResult");
		ValueTree.Rows.Clear();
		ConvertXDTOTree(Result, ValueTree);
		ValueToFormAttribute(ValueTree, "TreeResult");
		СтрXML = XMLWriter.Close();
		WSDefinition = Undefined;
		WSProxy = Undefined;
		Return СтрXML;

	ElsIf TypeOf(Result) = Type("String") Or TypeOf(Result) = Type("Number") Or TypeOf(Result) = Type(
		"Boolean") Or TypeOf(Result) = Type("Date") Then

		ValueTree = FormAttributeToValue("TreeResult");
		ValueTree.Rows.Clear();
		NewLine = ValueTree.Rows.Add();
		NewLine.Property 	= Nstr("ru = 'Результат операции';en = 'Operation result'");
		NewLine.Value 	= Result;
		NewLine.Type 		= TypeOf(Result);
		ValueToFormAttribute(ValueTree, "TreeResult");

		Return Result;
	Else
		Return Nstr("ru = 'Неопределенный тип результата операции';en = 'Undefined operation result type'");
	EndIf
	;

EndFunction

&AtServer
Function ConvertXDTOTree(XDTODataObject, ValueTree, PropertyName = "")

	If 1 = 0 Then
		XDTODataObject = XDTOFactory.Create(XDTOFactory.Type("http://v8.1c.ru/8.1/xdto", "Model"));
	EndIf;

	If TypeOf(XDTODataObject) = Type("XDTODataObject") Then
		NewLine = ValueTree.Rows.Add();
		NewLine.Property 	= ?(ValueIsFilled(PropertyName), PropertyName, XDTODataObject.Type().Name);
		NewLine.Type 		= XDTODataObject.Type();
		For Each XDTOProperty In XDTODataObject.Properties() Do
			PropertyValue = XDTODataObject[XDTOProperty.Name];
			If TypeOf(PropertyValue) = Type("String") Or TypeOf(PropertyValue) = Type("Number") Or TypeOf(
				PropertyValue) = Type("Boolean") Or TypeOf(PropertyValue) = Type("Date") Then
				НоваяСтрока2 = NewLine.Rows.Add();
				НоваяСтрока2.Property 	= XDTOProperty.Name;
				НоваяСтрока2.Value 	= PropertyValue;
				НоваяСтрока2.Type 		= XDTOProperty.Type;
			Else
				ConvertXDTOTree(PropertyValue, NewLine, XDTOProperty.Name);
			EndIf;
		EndDo;
	ElsIf TypeOf(XDTODataObject) = Type("XDTOList") Then
		NewLine = ValueTree.Rows.Add();
		NewLine.Property = PropertyName;
		For Each RowListXDTO In XDTODataObject Do
			ConvertXDTOTree(RowListXDTO, NewLine);
		EndDo;
	ElsIf TypeOf(XDTODataObject) = Type("XDTODataValue") Then
		NewLine = ValueTree.Rows.Add();
		NewLine.Property = "XDTODataValue";
	EndIf;

	Return ValueTree;

EndFunction

&AtClient
Procedure ListWSDefinitionsOnActivateRow(Item)
	If Items.ListWSDefinitions.CurrentData <> Undefined Then
		LocationWSDL = Items.ListWSDefinitions.CurrentData.LocationWSDL;
		UserName = Items.ListWSDefinitions.CurrentData.UserName;
		Password = Items.ListWSDefinitions.CurrentData.Password;
	Else
		LocationWSDL = "";
		UserName = "";
		Password = "";
	EndIf;
EndProcedure

&AtClient
Procedure Save(Command)

	OpenFileDialog = New FileDialog(FileDialogMode.Save);
	OpenFileDialog.Multiselect = False;
	OpenFileDialog.Title = Nstr("ru = 'Выберите файл';en = 'Select a file'");
	OpenFileDialog.Show(New NotifyDescription("SaveEnd", ThisForm,
		New Structure("OpenFileDialog", OpenFileDialog)));

EndProcedure

&AtClient
Procedure SaveEnd(SelectedFiles, AdditionalParameters) Export

	OpenFileDialog = AdditionalParameters.OpenFileDialog;
	If (SelectedFiles <> Undefined) Then
		FullFileName = OpenFileDialog.FullFileName;
		TextXML = SaveServer();
		TextDoc = New TextDocument;
		TextDoc.SetText(TextXML);
		TextDoc.BeginWriting( , FullFileName);
	EndIf;

EndProcedure

&AtServer
Function SaveServer()
	Serializer = New XDTOSerializer(XDTOFactory);
	Record = New XMLWriter;
	Record.SetString();
//	ОбработкаОбъект = FormAttributeToValue("Object");
	Serializer.WriteXML(Record, ListWSDefinitions.Unload());
	Return Record.Close();
EndFunction

&AtClient
Procedure Read(Command)

	OpenFileDialog = New FileDialog(FileDialogMode.Opening);
	OpenFileDialog.Multiselect = False;
	OpenFileDialog.Title = Nstr("ru = 'Выберите файл';en = 'Select a file'");
	OpenFileDialog.Show(New NotifyDescription("ReadEnd", ThisForm,
		New Structure("OpenFileDialog", OpenFileDialog)));

EndProcedure

&AtClient
Procedure ReadEnd(SelectedFiles, AdditionalParameters) Export

	OpenFileDialog = AdditionalParameters.OpenFileDialog;
	If (SelectedFiles <> Undefined) Then
		FullFileName = OpenFileDialog.FullFileName;
		TextDoc = New TextDocument;
		TextDoc.BeginReading(New NotifyDescription("ReadCompletionEnd", ThisForm,
			New Structure("TextDoc", TextDoc)), FullFileName);
	EndIf;

EndProcedure

&AtClient
Procedure ReadCompletionEnd(AdditionalParameters1) Export

	TextDoc = AdditionalParameters1.TextDoc;
	TextXML = TextDoc.GetText();
	ReadServer(TextXML);

EndProcedure
&AtServer
Procedure ReadServer(TextXML)
	Serializer = New XDTOSerializer(XDTOFactory);
	Read = New XMLReader;
	Read.SetString(TextXML);
//	ОбработкаОбъект = FormAttributeToValue("Object");
	ListWSDefinitions.Load(Serializer.ReadXML(Read));
//	ValueToFormAttribute(ОбработкаОбъект, "Object");
	Read.Close();
EndProcedure

&AtClient
Procedure OperationParametersValueStartChoice(Item, ChoiceData, StandardProcessing)
	
	// If the parameter type is structure, then open a separate form to fill it out
	If Items.OperationParameters.CurrentData.ParameterType = "{http://v8.1c.ru/8.1/data/core}Structure" Then
		StandardProcessing = False;
		NotifyDescription = New NotifyDescription("ConservationStructure", ThisObject);
		PastValue = New Structure;
		PastValue.Insert("PastValue", Items.OperationParameters.CurrentData.Structure);
		OpenForm("DataProcessor.UT_ConsoleWebServices.Form.FormInputStructures", PastValue, ThisObject, , , ,
			NotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
	EndIf;

EndProcedure

&AtClient
Procedure ConservationStructure(SelectedValue, SourceChoice) Export
	If TypeOf(SelectedValue) = Type("Structure") Then
		Items.OperationParameters.CurrentData.Value = "Structure";
		Items.OperationParameters.CurrentData.Structure = SelectedValue;
	EndIf;
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

