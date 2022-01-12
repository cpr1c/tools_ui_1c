
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	CopyFormData(Parameters.Object, Object);
	FormData = Parameters.FormData;
	Pictures = GetFromTempStorage(Object.Pictures);
	
	ValueType = Undefined;
	If ValueIsFilled(Parameters.QueryText) Then
		
		DummyParameterName = "Tmp31415926";
		
		Query = New Query(Parameters.QueryText);
		
		QueryText = New TextDocument;
		QueryText.SetText(Query.Text);
		
		BeginLine = QueryText.GetLine(Parameters.BeginLine);
		EndLine = QueryText.GetLine(Parameters.BeginLine);
		DummyParameterLine = Left(BeginLine, Parameters.BeginColumn - 1) + "&" + DummyParameterName + Right(EndLine, StrLen(EndLine) - Parameters.EndColumn);
		
		QueryText.ReplaceLine(Parameters.BeginLine, DummyParameterLine);
		For j = Parameters.BeginLine + 1 To Parameters.EndLine Do
			QueryText.DeleteLine(Parameters.BeginLine + 1);
		EndDo;
		
		Query.Текст = QueryText.GetText();
		
		Try
			ParameterCollection = Query.FindParameters();
			ValueType = ParameterCollection[DummyParameterName].ValueType;
		Except
			//Message("Debug: " + ErrorDescription());
		EndTry;
		
	EndIf;
	
	vlTypeList = Items.ObjectType.ChoiceList;
	vlTypeList.Add("AccumulationRecordType", "AccumulationRecordType", , Pictures.AccumulationRecordType);      
	vlTypeList.Add("AccountingRecordType", "AccountingRecordType", , Pictures.AccountingRecordType);      
	vlTypeList.Add("AccountType", "AccountType", , Pictures.AccountType);
	vlTypeList.Add("Catalogs", "Catalog", , Pictures.Type_CatalogRef);
	vlTypeList.Add("Documents", "Document", , Pictures.Type_DocumentRef);
	vlTypeList.Add("Enums", "Enum", , Pictures.Type_EnumRef);
	vlTypeList.Add("ChartsOfCharacteristicTypes", "Chart of characteristic types", , Pictures.Type_ChartOfCharacteristicTypesRef);
	vlTypeList.Add("ChartsOfAccounts", "Chart of accounts", , Pictures.Type_ChartOfAccountsRef);
	vlTypeList.Add("ChartsOfCalculationTypes", "Chart of calculation types", , Pictures.Type_ChartOfCalculationTypesRef);
	vlTypeList.Add("ExchangePlans", "Exchange plan", , Pictures.Type_ExchangePlanRef);
	vlTypeList.Add("BusinessProcesses", "Business process", , Pictures.Type_BusinessProcessRef);
	vlTypeList.Add("Tasks", "Task", , Pictures.Type_TaskRef);
	
	If ValueType <> Undefined Then
		
		arTypes = ValueType.Types();
		
		If arTypes.Count() <> 1 Then
			ValueType = Undefined;
		Else
			
			Type = arTypes[0];
			
			For Each vli In vlTypeList Do
				
				If ObjectTypeSystemEnumeration(vli.Value) Then
					If Type = Type(vli.Value) Then
						ObjectType = vli.Value;
						ObjectTypeOnChangeAtServer();
						Break;
					EndIf;
					Continue;
				EndIf;
					
				If Eval(vli.Value).AllRefsType().ContainsType(Type) Then
					ObjectType = vli.Value;
					ObjectTypeOnChangeAtServer();
					ObjectName = ValueType.AdjustValue().Metadata().Name;                         
					ObjectNameOnChangeAtServer();
					Break;
				EndIf;
				
			EndDo;
		
		EndIf;
		
	EndIf;
		
	If ValueType = Undefined And ValueIsFilled(FormData) Then
		stFormData = GetFromTempStorage(FormData);
		ObjectType = stFormData.ObjectType;
		ObjectTypeOnChangeAtServer();
		ObjectName = stFormData.ObjectName;
		ObjectNameOnChangeAtServer();
		Item = stFormData.Item;
	EndIf;
	
	SetButtonsAvailability();	
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	If Not ValueIsFilled(FormData) Then
		FormData = ThisForm.FormOwner.UUID;
	EndIf;
EndProcedure

&AtClientAtServerNoContext
Function ObjectTypeSystemEnumeration(ObjectType)
	Return ObjectType = "AccumulationRecordType"
		Or ObjectType = "AccountingRecordType"
		Or ObjectType = "AccountType";
EndFunction

&AtServer
Procedure SetButtonsAvailability()
	
	If ObjectTypeSystemEnumeration(ObjectType) Then
		Items.InsertRefCommand.Enabled = False;
		Items.InsertNameCommand.Enabled = True;
		Items.InsertValueCommand.Enabled = True;
		Items.InsertEmptyRefCommand.Enabled = False;
	Else
		Items.InsertRefCommand.Enabled = ValueIsFilled(ObjectName);
		Items.InsertNameCommand.Enabled = ValueIsFilled(Item);
		Items.InsertValueCommand.Enabled = Items.InsertNameCommand.Enabled;
		Items.InsertEmptyRefCommand.Enabled = Items.InsertRefCommand.Enabled;
	EndIf;
	
EndProcedure

&AtServer
Procedure ObjectTypeOnChangeAtServer()

	vlObjectList = Items.ObjectName.ChoiceList;
	vlObjectList.Clear();
	
	If ObjectType = "AccumulationRecordType" Then
		vlObjectList.Add(AccumulationRecordType.Receipt, "Receipt");
		vlObjectList.Add(AccumulationRecordType.Expense, "Expense");
		Items.ObjectName.TypeRestriction = New TypeDescription("AccumulationRecordType");
		ObjectName = AccumulationRecordType.Receipt;
	ElsIf ObjectType = "AccountingRecordType" Then
		vlObjectList.Add(AccountingRecordType.Debit, "Debit");
		vlObjectList.Add(AccountingRecordType.Credit, "Credit");
		Items.ObjectName.TypeRestriction = New TypeDescription("AccountingRecordType");
		ObjectName = AccountingRecordType.Debit;
	ElsIf ObjectType = "AccountType" Then
		vlObjectList.Add(AccountType.ActivePassive, "Active");
		vlObjectList.Add(AccountType.Active, "Active");
		vlObjectList.Add(AccountType.Passive, "Passive");
		Items.ObjectName.TypeRestriction = New TypeDescription("AccountType");
		ObjectName = AccountType.ActivePassive;
	Else
		
		TypeMetadata = Metadata[ObjectType];
		For Each mdObject In TypeMetadata Do
			vlObjectList.Add(mdObject.Name);
		EndDo;
		
		Items.ObjectName.TypeRestriction = New TypeDescription("String");
		ObjectName = "";
		
	EndIf;
	
	Items.ObjectName.Enabled = True;
	ObjectNameOnChangeAtServer();
	SetButtonsAvailability();	
		
EndProcedure

&AtClient
Procedure ObjectTypeOnChange(Item)
	ObjectTypeOnChangeAtServer();
EndProcedure

&AtServer
Procedure ObjectNameOnChangeAtServer()

	If TypeOf(ObjectName) <> Type("String") Then
		Item = Undefined;
		Items.Item.Enabled = False;
		Return;
	EndIf;
	
	vlObjectList = Items.Item.ChoiceList;
	vlObjectList.Clear();
	
	If ValueIsFilled(ObjectName) Then
		
		If ObjectType = "Catalogs" Then
			qQuery = New Query(StrTemplate("SELECT Ref FROM Catalog.%1 WHERE Predefined", ObjectName));
			arElements = qQuery.Execute().Unload().UnloadColumn(0);
			vlObjectList.LoadValues(arElements);
		ElsIf ObjectType = "ChartsOfCharacteristicTypes" Then
			qQuery = New Query(StrTemplate("SELECT Ref FROM ChartOfCharacteristicTypes.%1 WHERE Predefined", ObjectName));
			arElements = qQuery.Execute().Unload().UnloadColumn(0);
			vlObjectList.LoadValues(arElements);
		ElsIf ObjectType = "Enums" Then
			qQuery = New Query(StrTemplate("SELECT Ref FROM Enum.%1", ObjectName));
			arElements = qQuery.Execute().Unload().UnloadColumn(0);
			vlObjectList.LoadValues(arElements);
		ElsIf ObjectType = "ChartsOfAccounts" Then
			qQuery = New Query(StrTemplate("SELECT Ref FROM ChartOfAccounts.%1 WHERE Predefined", ObjectName));
			arElements = qQuery.Execute().Unload().UnloadColumn(0);
			vlObjectList.LoadValues(arElements);
		ElsIf ObjectType = "ChartsOfCalculationTypes" Then
			qQuery = New Query(StrTemplate("SELECT Ref FROM ChartOfCalculationTypes.%1 WHERE Predefined", ObjectName));
			arElements = qQuery.Execute().Unload().UnloadColumn(0);
			vlObjectList.LoadValues(arElements);
		EndIf;
		
	EndIf;
	
	Item = Undefined;
	
	Items.Item.Enabled = Not (
		ObjectTypeSystemEnumeration(ObjectType)
		Or ObjectType = "ExchangePlans"
		Or ObjectType = "BusinessProcesses"
		Or ObjectType = "Tasks");

	SetButtonsAvailability();	
		
EndProcedure

&AtClient
Procedure ObjectNameOnChange(Item)
	ObjectNameOnChangeAtServer();
EndProcedure

&AtServer
Procedure SaveFormData()
	stFormData = New Structure("ObjectType, ObjectName, Item", ObjectType, ObjectName, Item);
	FormData = PutToTempStorage(stFormData, FormData);
EndProcedure

&AtClient
Procedure ItemOnChange(Item)
	SetButtonsAvailability();	
EndProcedure

&AtServer
Function TypeForQuery(MetadataTypeName)
	If MetadataTypeName = "Catalogs" Then Return "Catalog";
	ElsIf MetadataTypeName = "Enums" Then Return "Enum";
	ElsIf MetadataTypeName = "ChartsOfCharacteristicTypes" Then Return "ChartOfCharacteristicTypes";
	ElsIf MetadataTypeName = "ChartsOfAccounts" Then Return "ChartOfAccounts";
	ElsIf MetadataTypeName = "ChartsOfCalculationTypes" Then Return "ChartOfCalculationTypes";
	ElsIf MetadataTypeName = "ExchangePlans" Then Return "ExchangePlan";
	ElsIf MetadataTypeName = "BusinessProcesses" Then Return "BusinessProcess";
	ElsIf MetadataTypeName = "Tasks" Then Return "Task";
	ElsIf MetadataTypeName = "Documents" Then Return "Document";
	Else
		Return MetadataTypeName;
	EndIf;
EndFunction

&AtServer
Function GetObjectLiteralForQuery()
	Return TypeForQuery(ObjectType) + "." + ObjectName;
EndFunction

&AtServer
Function GetItemLiteralForQuery()
	If ObjectTypeSystemEnumeration(ObjectType) Then
		Return GetObjectLiteralForQuery();
	Else
		If ObjectType = "Enums" Then
			EnumMetadata = Item.Metadata();
			Manager = Enums[EnumMetadata.Имя];
			Return GetObjectLiteralForQuery() + "." + EnumMetadata.EnumValues.Get(Manager.IndexOf(Item)).Name;
		Else			
			Return GetObjectLiteralForQuery() + "." + Item.PredefinedDataName;
		EndIf;
	EndIf;
EndFunction

&AtClient
Procedure InsertNameCommand(Command)
	Close(InsertNameCommandAtServer());
EndProcedure

&AtClient
Function InsertNameCommandAtServer()
	SaveFormData();
	Return New Structure("FormData, Result", FormData, GetItemLiteralForQuery());
EndFunction

&AtClient
Procedure InsertValueCommand(Command)
	Close(InsertValueCommandAtServer());
EndProcedure

&AtServer
Function InsertValueCommandAtServer()
	SaveFormData();                                
	Return New Structure("FormData, Result", FormData, "VALUE(" + GetItemLiteralForQuery() + ")");
EndFunction

&AtClient
Procedure InsertRefCommand(Command)
	Close(InsertRefCommandAtServer());
EndProcedure

&AtServer
Function InsertRefCommandAtServer()
	SaveFormData();
	Return New Structure("FormData, Result", FormData, "REFS " + GetObjectLiteralForQuery());
EndFunction

&AtClient
Procedure InsertEmptyRefCommand(Command)
	Close(InsertEmptyRefCommandAtServer());
EndProcedure

&AtServer
Function InsertEmptyRefCommandAtServer()
	SaveFormData();                                
	Return New Structure("FormData, Result", FormData, "VALUE(" + GetObjectLiteralForQuery() + ".EmptyRef)");
EndFunction
