Var WSDefinition;

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);
EndProcedure


&AtServer
Procedure ПодключитьсяКСерверу(LocationWSDL, UserName, Password)
	// Подключимся к серверу зная WSDL
	ssl = New OpenSSLSecureConnection;
	WSDefinition = New WSDefinitions(LocationWSDL, UserName, Password, , , ssl);
	//обновим список веб сервисов
	СписокСервисов.Clear();
	СписокТочекПодключения.Clear();
	СписокОпераций.Clear();
	СписокПараметров.Clear();
	// Читаем веб сервисы
	For Each Service In WSDefinition.Services Do
		НовыйСервис = СписокСервисов.Add();
		НовыйСервис.LocationWSDL = LocationWSDL;
		НовыйСервис.WSService = Service.Name;
		НовыйСервис.NamespaceURI = Service.NamespaceURI;
		// Читаем точки подклбючения что бы создать прокси
		For Each Endpoint In Service.Endpoins Do
			УникальныйИдентификаторТочкиПодключения = New UUID;
			НоваяТочкаПодключения = СписокТочекПодключения.Add();
			НоваяТочкаПодключения.WSService = Service.Name;
			НоваяТочкаПодключения.NamePointConnections = Endpoint.Name;
			НоваяТочкаПодключения.УникальныйИдентификаторТочкиПодключения = УникальныйИдентификаторТочкиПодключения;
			// Читаем операции веб сервисов
			For Each Операция In Endpoint.Interface.Operations Do
				НоваяОперация = СписокОпераций.Add();
				НоваяОперация.NamePointConnections = Endpoint.Name;
				НоваяОперация.OperationName = Операция.Name;
				НоваяОперация.ТипВозвращаемогоЗначения = Операция.ReturnValue.Type;
				НоваяОперация.УникальныйИдентификаторТочкиПодключения = УникальныйИдентификаторТочкиПодключения;
				// Читаем параметры операций
				For Each Parameter In Операция.Parameters Do
					НовыйПараметр = СписокПараметров.Add();
					НовыйПараметр.OperationName = Операция.Name;
					НовыйПараметр.NamePointConnections = Endpoint.Name;
					НовыйПараметр.ИмяПараметра = Parameter.Name;
					НовыйПараметр.ParameterType = Parameter.Type;
				EndDo;
			EndDo;
		EndDo;
	EndDo;
EndProcedure

&AtClient
Procedure ПолучитьWSDL(Command)
	If ValueIsFilled(LocationWSDL) Then
		ПодключитьсяКСерверу(LocationWSDL, UserName, Password);
		ThisForm.Items.СписокСервисов.SelectedRows.Add(0);
		ThisForm.Items.СписокСервисов.Update();
		ThisForm.Items.СписокТочекПодключения.SelectedRows.Add(0);
		ThisForm.Items.СписокТочекПодключения.Update();
		ThisForm.Items.СписокОпераций.SelectedRows.Add(0);
		ThisForm.Items.СписокОпераций.Update();
	EndIf;
EndProcedure

&AtClient
Procedure СписокСервисовПриАктивизацииСтроки(Item)
	If Items.СписокСервисов.CurrentData <> Undefined Then
		WebServiceName =  Items.СписокСервисов.CurrentData.WSService;
		WebServiceNamespaceURI = Items.СписокСервисов.CurrentData.NamespaceURI;
	Else
		WebServiceName =  "";
		WebServiceNamespaceURI = "";
	EndIf;
	Filter = New FixedStructure("WSService", WebServiceName);
	Items.СписокТочекПодключения.RowFilter	= Filter;
EndProcedure

&AtClient
Procedure СписокТочекПодключенияПриАктивизацииСтроки(Item)
	If Items.СписокТочекПодключения.CurrentData <> Undefined Then
		NamePointConnections = Items.СписокТочекПодключения.CurrentData.NamePointConnections;
		УникальныйИдентификаторТочкиПодключения = Items.СписокТочекПодключения.CurrentData.УникальныйИдентификаторТочкиПодключения;
	Else
		NamePointConnections = "";
		УникальныйИдентификаторТочкиПодключения = "";
	EndIf;
	Filter = New FixedStructure("УникальныйИдентификаторТочкиПодключения",
		УникальныйИдентификаторТочкиПодключения);
	Items.СписокОпераций.RowFilter	= Filter;
EndProcedure

&AtClient
Procedure СписокОперацийПриАктивизацииСтроки(Item)
	If NamePointConnections <> "" And Items.СписокОпераций.CurrentData <> Undefined Then
		OperationName =  Items.СписокОпераций.CurrentData.OperationName;
		ОбновитьПараметрыОперации(NamePointConnections, OperationName);
	Else
		OperationName = "";
	EndIf;
EndProcedure

&AtServer
Procedure ОбновитьПараметрыОперации(NamePointConnections, OperationName)
	If NamePointConnections = ConnectionPointNameCurrent And OperationName = OperationNameCurrent Then
		Return;
	EndIf;
	Filter = New Structure("NamePointConnections,OperationName", NamePointConnections, OperationName);
	МассивПараметровОперации = СписокПараметров.FindRows(Filter);
	// Очистим таблицу параметров операции
	ПараметрыОперации.Clear();
	
	// Создадим WSОпределния для того что бы получить фабрикуXDTO веб сервиса, что бы можно было попытаться привести типы веб сервиса. к простим типам
	ssl = New OpenSSLSecureConnection;
	WSDefinition = New WSDefinitions(LocationWSDL, UserName, Password, , , ssl);
	Сериализатор = New XDTOSerializer(WSDefinition.XDTOFactory);

	For Each Parameter In МассивПараметровОперации Do
		НовыйПараметр = ПараметрыОперации.Add();
		НовыйПараметр.ИмяПараметра = Parameter.ИмяПараметра;
		НовыйПараметр.ParameterType = Parameter.ParameterType;
		ПоложениеВторойСкобки = Find(Parameter.ParameterType, "}");
	EndDo;
	OperationNameCurrent = OperationName;
	ConnectionPointNameCurrent = NamePointConnections;
EndProcedure

&AtClient
Procedure ВыполнитьОперацию(Command)
	If ValueIsFilled(LocationWSDL) And ValueIsFilled(WebServiceName) And ValueIsFilled(
		WebServiceNamespaceURI) And ValueIsFilled(NamePointConnections) And ValueIsFilled(OperationName) Then
		РезультатОперации = ВыполнитьОперациюСервер(LocationWSDL, UserName, Password, WebServiceName,
			WebServiceNamespaceURI, NamePointConnections, OperationName, ПараметрыОперации);
		If Not ThisForm.Items.TreeResult.RowData(1) = Undefined Then
			ThisForm.Items.TreeResult.Expand(1, True);
		EndIf;
	Else
		Message("Not все параметры выбраны!");
	EndIf;
EndProcedure

&AtServer
Function ВыполнитьОперациюСервер(LocationWSDL, UserName, Password, ИмяВебСервиса,
	URIПространстваИменВебСервиса, NamePointConnections, OperationName, Val ПараметрыОперации)
	Result = Undefined;
	ssl = New OpenSSLSecureConnection;
	WSDefinition = New WSDefinitions(LocationWSDL, UserName, Password, , , ssl);
	WSProxy = New WSProxy(WSDefinition, URIПространстваИменВебСервиса, ИмяВебСервиса, NamePointConnections, , , ssl);
	WSProxy.User = UserName;
	WSProxy.Password = Password;
	КодВызоваОперации = "Result = WSProxy." + OperationName + "(";
	ДобавитьЗапятую = False;
	НомерПараметра = 0;
	For Each Parameter In ПараметрыОперации Do
		If ДобавитьЗапятую Then
			КодВызоваОперации = КодВызоваОперации + ", ";
		EndIf;
		// Обработаем случай когда установлена галочка Undefined. В этом случае 1С отсылает null
		If Parameter.Undefined Then
			КодВызоваОперации = КодВызоваОперации + "Undefined";
		ElsIf Parameter.ParameterType = "{http://v8.1c.ru/8.1/data/core}Structure" Then
			If TypeOf(Parameter.Structure) = Type("Structure") Then
				КодВызоваОперации = КодВызоваОперации + "XDTOSerializer.WriteXDTO(ПараметрыОперации[" + String(
					НомерПараметра) + "].Structure)";
			Else
				КодВызоваОперации = КодВызоваОперации + "XDTOSerializer.WriteXDTO(New Structure)";
			EndIf;
		ElsIf TypeOf(Parameter.Value) = Type("String") Then
			КодВызоваОперации = КодВызоваОперации + """" + Parameter.Value + """";
		ElsIf TypeOf(Parameter.Value) = Type("Number") Then
			КодВызоваОперации = КодВызоваОперации + Parameter.Value;
		ElsIf TypeOf(Parameter.Value) = Type("Boolean") Then
			If Parameter.Value = True Then
				КодВызоваОперации = КодВызоваОперации + "True";
			Else
				КодВызоваОперации = КодВызоваОперации + "False";
			EndIf;
		ElsIf TypeOf(Parameter.Value) = Type("Date") Then
			If ValueIsFilled(Parameter.Value) Then
				КодВызоваОперации = КодВызоваОперации + "'" + Format(Parameter.Value, "ДФ=""ггггММддЧЧммсс""") + "'";
			Else
				КодВызоваОперации = КодВызоваОперации + "'00010101000000'";
			EndIf;
		Else
			КодВызоваОперации = КодВызоваОперации + """" + Parameter.Value + """";
		EndIf;
		ДобавитьЗапятую = True;
		НомерПараметра = НомерПараметра + 1;
	EndDo;
	КодВызоваОперации = КодВызоваОперации + ");";
	Execute (КодВызоваОперации);

	If TypeOf(Result) = Type("XDTODataObject") Or TypeOf(Result) = Type("XDTODataValue") Then
		XMLWriter = New XMLWriter;
		XMLWriter.SetString();
		WSDefinition.XDTOFactory.WriteXML(XMLWriter, Result);
		ValueTree = FormAttributeToValue("TreeResult");
		ValueTree.Rows.Clear();
		ПреобразоватьXDTOВДерево(Result, ValueTree);
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
		NewLine.Property 	= "Result операции";
		NewLine.Value 	= Result;
		NewLine.Type 		= TypeOf(Result);
		ValueToFormAttribute(ValueTree, "TreeResult");

		Return Result;
	Else
		Return "Неопределенный тип результата операции"
	EndIf
	;

EndFunction

&AtServer
Function ПреобразоватьXDTOВДерево(XDTODataObject, ValueTree, PropertyName = "")

	If 1 = 0 Then
		XDTODataObject = XDTOFactory.Create(XDTOFactory.Type("http://v8.1c.ru/8.1/xdto", "Model"));
	EndIf;

	If TypeOf(XDTODataObject) = Type("XDTODataObject") Then
		NewLine = ValueTree.Rows.Add();
		NewLine.Property 	= ?(ValueIsFilled(PropertyName), PropertyName, XDTODataObject.Type().Name);
		NewLine.Type 		= XDTODataObject.Type();
		For Each XDTOProperty In XDTODataObject.Properties() Do
			ЗначениеСвойства = XDTODataObject[XDTOProperty.Name];
			If TypeOf(ЗначениеСвойства) = Type("String") Or TypeOf(ЗначениеСвойства) = Type("Number") Or TypeOf(
				ЗначениеСвойства) = Type("Boolean") Or TypeOf(ЗначениеСвойства) = Type("Date") Then
				НоваяСтрока2 = NewLine.Rows.Add();
				НоваяСтрока2.Property 	= XDTOProperty.Name;
				НоваяСтрока2.Value 	= ЗначениеСвойства;
				НоваяСтрока2.Type 		= XDTOProperty.Type;
			Else
				ПреобразоватьXDTOВДерево(ЗначениеСвойства, NewLine, XDTOProperty.Name);
			EndIf;
		EndDo;
	ElsIf TypeOf(XDTODataObject) = Type("XDTOList") Then
		NewLine = ValueTree.Rows.Add();
		NewLine.Property = PropertyName;
		For Each СтрокаСпискаXDTO In XDTODataObject Do
			ПреобразоватьXDTOВДерево(СтрокаСпискаXDTO, NewLine);
		EndDo;
	ElsIf TypeOf(XDTODataObject) = Type("XDTODataValue") Then
		NewLine = ValueTree.Rows.Add();
		NewLine.Property = "XDTODataValue";
	EndIf;

	Return ValueTree;

EndFunction

&AtClient
Procedure СписокWSОпределенийПриАктивизацииСтроки(Item)
	If Items.СписокWSОпределений.CurrentData <> Undefined Then
		LocationWSDL = Items.СписокWSОпределений.CurrentData.LocationWSDL;
		UserName = Items.СписокWSОпределений.CurrentData.UserName;
		Password = Items.СписокWSОпределений.CurrentData.Password;
	Else
		LocationWSDL = "";
		UserName = "";
		Password = "";
	EndIf;
EndProcedure

&AtClient
Procedure Save(Command)

	ДиалогОткрытияФайла = New FileDialog(FileDialogMode.Save);
	ДиалогОткрытияФайла.Multiselect = False;
	ДиалогОткрытияФайла.Title = "Выберите файл";
	ДиалогОткрытияФайла.Show(New NotifyDescription("СохранитьЗавершение", ThisForm,
		New Structure("ДиалогОткрытияФайла", ДиалогОткрытияФайла)));

EndProcedure

&AtClient
Procedure СохранитьЗавершение(SelectedFiles, AdditionalParameters) Export

	ДиалогОткрытияФайла = AdditionalParameters.ДиалогОткрытияФайла;
	If (SelectedFiles <> Undefined) Then
		FullFileName = ДиалогОткрытияФайла.FullFileName;
		ТекстXML = СохранитьСервер();
		ТекстДок = New TextDocument;
		ТекстДок.SetText(ТекстXML);
		ТекстДок.BeginWriting( , FullFileName);
	EndIf;

EndProcedure

&AtServer
Function СохранитьСервер()
	Сериализатор = New XDTOSerializer(XDTOFactory);
	Record = New XMLWriter;
	Record.SetString();
//	ОбработкаОбъект = FormAttributeToValue("Object");
	Сериализатор.WriteXML(Record, СписокWSОпределений.Unload());
	Return Record.Close();
EndFunction

&AtClient
Procedure Read(Command)

	ДиалогОткрытияФайла = New FileDialog(FileDialogMode.Opening);
	ДиалогОткрытияФайла.Multiselect = False;
	ДиалогОткрытияФайла.Title = "Выберите файл";
	ДиалогОткрытияФайла.Show(New NotifyDescription("ПрочитатьЗавершение", ThisForm,
		New Structure("ДиалогОткрытияФайла", ДиалогОткрытияФайла)));

EndProcedure

&AtClient
Procedure ПрочитатьЗавершение(SelectedFiles, AdditionalParameters) Export

	ДиалогОткрытияФайла = AdditionalParameters.ДиалогОткрытияФайла;
	If (SelectedFiles <> Undefined) Then
		FullFileName = ДиалогОткрытияФайла.FullFileName;
		ТекстДок = New TextDocument;
		ТекстДок.BeginReading(New NotifyDescription("ПрочитатьЗавершениеЗавершение", ThisForm,
			New Structure("ТекстДок", ТекстДок)), FullFileName);
	EndIf;

EndProcedure

&AtClient
Procedure ПрочитатьЗавершениеЗавершение(ДополнительныеПараметры1) Export

	ТекстДок = ДополнительныеПараметры1.ТекстДок;
	ТекстXML = ТекстДок.GetText();
	ПрочитатьСервер(ТекстXML);

EndProcedure
&AtServer
Procedure ПрочитатьСервер(ТекстXML)
	Сериализатор = New XDTOSerializer(XDTOFactory);
	Read = New XMLReader;
	Read.SetString(ТекстXML);
//	ОбработкаОбъект = FormAttributeToValue("Object");
	СписокWSОпределений.Load(Сериализатор.ReadXML(Read));
//	ValueToFormAttribute(ОбработкаОбъект, "Object");
	Read.Close();
EndProcedure

&AtClient
Procedure ПараметрыОперацийЗначениеНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	
	// If тип параметра структура то откром отдельную форму для ее заполнения
	If Items.ПараметрыОпераций.CurrentData.ParameterType = "{http://v8.1c.ru/8.1/data/core}Structure" Then
		StandardProcessing = False;
		NotifyDescription = New NotifyDescription("СохранениеСтруктуры", ThisObject);
		ПрошлоеЗначение = New Structure;
		ПрошлоеЗначение.Insert("ПрошлоеЗначение", Items.ПараметрыОпераций.CurrentData.Structure);
		OpenForm("Processing.УИ_КонсольВебСервисов.Form.ФормаВводаСтруктуры", ПрошлоеЗначение, ThisObject, , , ,
			NotifyDescription, FormWindowOpeningMode.LockOwnerWindow);
	EndIf;

EndProcedure

&AtClient
Procedure СохранениеСтруктуры(ВыбранноеЗначение, ИсточникВыбора) Export
	If TypeOf(ВыбранноеЗначение) = Type("Structure") Then
		Items.ПараметрыОпераций.CurrentData.Value = "Structure";
		Items.ПараметрыОпераций.CurrentData.Structure = ВыбранноеЗначение;
	EndIf;
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

