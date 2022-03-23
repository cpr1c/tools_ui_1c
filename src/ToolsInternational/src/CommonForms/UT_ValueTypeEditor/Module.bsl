#Region FormEvents

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	WorkMode=Parameters.StartMode;
	
	DataType=Parameters.DataType;
	If TypeOf(DataType)=Type("TypeDescription") Then
		InitialDataType=DataType;
	Else
		InitialDataType=New TypeDescription;
	EndIf;
	
	FillQualifiersDataByOriginalDataType();
	
	FillTypesTree(True);
	
	SetConditionalAppearance();
EndProcedure

#EndRegion

#Region FormItemsEvents


&AtClient
Procedure TypesTreeOnActivateRow(Item)
	CurrentData=Items.TypesTree.CurrentData;
	If CurrentData=Undefined Then
		Return;
	EndIf;
	
	Items.GroupNumberQualifier.Visible=CurrentData.Name="Number";
	Items.GroupStringQualifier.Visible=CurrentData.Name="String";
	Items.GroupDateQualifier.Visible=CurrentData.Name="Date";
EndProcedure


&AtClient
Procedure UnlimitedStringLengthOnChange(Item)
	If UnlimitedStringLength Then
		StringLength=0;
		AcceptableFixedStringLength=False;
	EndIf;
	Items.AcceptableFixedStringLength.Enabled=Not UnlimitedStringLength;
EndProcedure

&AtClient
Procedure StringLengthOnChange(Item)
	If Not ValueIsFilled(StringLength) Then
		UnlimitedStringLength=True;
		AcceptableFixedStringLength=False;
	Иначе
		UnlimitedStringLength=False;
	EndIf;
	Items.AcceptableFixedStringLength.Enabled=Not UnlimitedStringLength;
EndProcedure

&AtClient
Procedure SearchStringOnChange(Item)
	FillTypesTree();
	ExpandTreeItems();
EndProcedure

&AtClient
Procedure TypesTreeSelectedOnChange(Item)
		CurrentRow=Items.TypesTree.CurrentData;
	If CurrentRow=Undefined Then
		Return;
	EndIf;
	
	If CurrentRow.Selected Then
		If Not CompositeDataType Then
			SelectedTypes.Clear();
		 ElsIf CurrentRow.UnavailableForCompositeType Then
			If SelectedTypes.Count()>0 Then
				ShowQueryBox(New NotifyDescription("TypesTreeSelectedOnChangeEnd", ThisForm, New Structure("CurrentRow",CurrentRow)),NSTR("ru = 'Выбран тип, который не может быть включен в составной тип данных.Будут исключены остальные типы данных.
				|Продолжить?';
				|en = 'A type is selected that cannot be included in a composite data type.Other data types will be excluded.
				|Continue?'"),QuestionDialogMode.YesNo);
	        	Return;
			EndIf;
		Else
			HaveUnavailableForCompositeType=False;
			For Each SelectedTypesItem In SelectedTypes Do
				If SelectedTypesItem.Check Then
					HaveUnavailableForCompositeType=True;
					Break;
				EndIf;
			EndDo;
			
			If HaveUnavailableForCompositeType Then
				ShowQueryBox(New NotifyDescription("TypesTreeSelectedOnChangeEndWasNotAllowedForCompositeType", ThisForm, New Structure("CurrentRow",CurrentRow)),NSTR("ru = 'Ранее был выбран тип, который не может быть включен в составной тип данных и будет исключен. Продолжить?';
				|en = 'Previously, a type was selected that cannot be is included in the composite data type and will be excluded.
				|Continue?'") ,QuestionDialogMode.YesNo);
				Return;
			EndIf;
		EndIf;
	Else
		Item=SelectedTypes.FindByValue(CurrentRow.Name);
		If Item<>Undefined Then
			SelectedTypes.Delete(Item);
		EndIf;
		
	EndIf;
	TypesTreeSelectedOnChangeFragment(CurrentRow);

EndProcedure


&AtClient
Procedure CompositeDataTypeOnChange(Item)
	If Not CompositeDataType Then
		If SelectedTypes.Count()=0 Then
			AddSelectedType("String");
		EndIf;
		Type=SelectedTypes[SelectedTypes.Count()-1];
		SelectedTypes.Clear();
		AddSelectedType(Type);
		
		SetSelectedTypesInTree(TypesTree,SelectedTypes);
	EndIf;
EndProcedure


#EndRegion

#Region FormCommandsHandlers

&AtClient
Procedure Apply(Command)
	TypesArray=SelectedTypesArray();
	
	TypesByString=New Array;
	TypesByType=New Array;
	
	For Each Type ИЗ TypesArray Do
		If TypeOf(Type) = Type("Type") Then
			TypesByType.Add(Type);
		Иначе
			TypesByString.Add(Type);
		EndIf;
	EndDo;
	
	If NonnegativeNumber Then
		Sign=AllowedSign.Nonnegative;
	Иначе
		Sign=AllowedSign.Any;
	EndIf;
		
	NumberQualifier=New NumberQualifiers(NumberLength,NumberPrecision,Sign);
	StringQualifier=New StringQualifiers(StringLength, ?(AcceptableFixedStringLength,AllowedLength.Fixed, AllowedLength.Variable));
	
	If DateFormat=1 Then
		DateFraction=DateFractions.Time;
	 ElsIf DateFormat=2 Then
		DateFraction=DateFractions.DateTime;
	Иначе
		DateFraction=DateFractions.Date;
	EndIf;
	
	DateQualifier=New DateQualifiers(DateFraction);
	
	Description=New TypeDescription;
	If TypesByType.Count()>0 Then 
		Description=New TypeDescription(Description, TypesByType,,NumberQualifier,StringQualifier,DateQualifier);
	EndIf;
	If TypesByString.Count()>0 Then 
		Description=New TypeDescription(Description, StrConcat(TypesByString,","),,NumberQualifier,StringQualifier,DateQualifier);
	EndIf;
	
	Close(Description);
EndProcedure

#EndRegion

#Region Internal

&AtServer
Function StorageValueIsAvailable()
	Return True;	
EndFunction
&AtServer
Function AvailableNull()
	Return WorkMode<>0;	
EndFunction
&AtServer
Function TypesForQuery()
	Return WorkMode=1;	
EndFunction

&AtServer
Function AddTypeToTypesTree(FillSelectedTypes,TypeName, Picture, Presentation = "", TreeRow = Undefined, IsGroup = False, Group=False, UnavailableForCompositeType=False)
	
	If ValueIsFilled(Presentation) Then
		TypePresentation=Presentation;
	Иначе
		TypePresentation=TypeName;
	EndIf;

	If ValueIsFilled(SearchString) и Not Group Then
		If StrFind(Lower(TypePresentation), Lower(SearchString))=0 Then
			Return Undefined;
		EndIf;
	EndIf;
	
	If TreeRow = Undefined Then
		AdditionElement=TypesTree;
	Else
		AdditionElement=TreeRow;
	EndIf;

	NewRow=AdditionElement.GetItems().Add();
	NewRow.Name=TypeName;
	NewRow.Presentation=TypePresentation;
	NewRow.Picture=Picture;
	NewRow.IsGroup=IsGroup;
	NewRow.UnavailableForCompositeType=UnavailableForCompositeType;
	
	If FillSelectedTypes Then
		Try
			CurrentType=Type(TypeName);
		Except
			CurrentType=Undefined;
		EndTry;
		If CurrentType<>Undefined Then
			If InitialDataType.ContainsType(CurrentType) Then
				SelectedTypes.Add(NewRow.Name,,NewRow.UnavailableForCompositeType);
			EndIf;
		EndIf;
	EndIf;

	Return NewRow;
EndFunction

&AtServer
Procedure FillTypesByObjectType(MetadataObjectsType, TypePrefix, Picture,FillSelectedTypes)
	ObjectsCollection=Metadata[MetadataObjectsType];
	
	CollectionRow=AddTypeToTypesTree(FillSelectedTypes,TypePrefix,Picture,TypePrefix,,,True);
	
	For Each MetadataObject In ObjectsCollection Do
		AddTypeToTypesTree(FillSelectedTypes,TypePrefix+"."+MetadataObject.Name, Picture,MetadataObject.Name,CollectionRow);
	EndDo;
	
	DeleteTreeRowIfNotSubordinatesOnSearch(CollectionRow);
EndProcedure

&AtServer
Procedure FillPrimitiveTypes(FillSelectedTypes)
	//AddTypeToTypesTree("Arbitrary", PictureLib.UT_ArbitraryType);
	AddTypeToTypesTree(FillSelectedTypes,"Number", PictureLib.UT_Number);
	AddTypeToTypesTree(FillSelectedTypes,"String", PictureLib.UT_String);
	AddTypeToTypesTree(FillSelectedTypes,"Date", PictureLib.UT_Date);
	AddTypeToTypesTree(FillSelectedTypes,"Boolean", PictureLib.UT_Boolean);
	If StorageValueIsAvailable() Then      
		AddTypeToTypesTree(FillSelectedTypes,"ValueStorage", New Picture);
	EndIf;
	If TypesForQuery() Then
		AddTypeToTypesTree(FillSelectedTypes,"ValueTable", PictureLib.UT_ValueTable);
		AddTypeToTypesTree(FillSelectedTypes,"ValueList", PictureLib.UT_ValueList);
		AddTypeToTypesTree(FillSelectedTypes,"Array", PictureLib.UT_Array);
		AddTypeToTypesTree(FillSelectedTypes,"Type", PictureLib.ChooseType);
		AddTypeToTypesTree(FillSelectedTypes,"PointInTime", PictureLib.UT_PointInTime);
		AddTypeToTypesTree(FillSelectedTypes,"Boundary", PictureLib.UT_Boundary);
	EndIf;
	
	AddTypeToTypesTree(FillSelectedTypes,"UUID", PictureLib.UT_UUID);
	If AvailableNull() Then
		AddTypeToTypesTree(FillSelectedTypes,"Null", PictureLib.UT_Null);
	EndIf;
EndProcedure

&AtServer
Procedure FillCharacteristicsTypes(FillSelectedTypes)
	//Characteristics
	Charts=Metadata.ChartsOfCharacteristicTypes;
	If Charts.Count()=0 Then
		Return;
	EndIf;
	
	CharacteristicsRow=AddTypeToTypesTree(FillSelectedTypes,"Characteristics", PictureLib.Folder,,,True,True);
	
	For Each Chart In Charts Do
		AddTypeToTypesTree(FillSelectedTypes,"Characteristic."+Chart.Name,New Picture,Chart.Name,CharacteristicsRow,,,True);
	EndDo;
	
	DeleteTreeRowIfNotSubordinatesOnSearch(CharacteristicsRow);

EndProcedure

&AtServer
Procedure FillDefinedTypes(FillSelectedTypes)
	//Characteristics
	Types=Metadata.DefinedTypes;
	If Types.Count()=0 Then
		Return;
	EndIf;
	
	TypeAsString=AddTypeToTypesTree(FillSelectedTypes,"DefinedType", PictureLib.Folder,,,True, True);
	
	For Each DefinedType In Types Do
		AddTypeToTypesTree(FillSelectedTypes,"DefinedType."+DefinedType.Name,New Picture,DefinedType.Name,TypeAsString,,,True);
	EndDo;
	DeleteTreeRowIfNotSubordinatesOnSearch(TypeAsString);
EndProcedure

&AtServer
Procedure FillTypesOfSystemEnumerations(FillSelectedTypes)
	TypeAsString=AddTypeToTypesTree(FillSelectedTypes,"SystemEnumerations", PictureLib.Folder,"System Enumerations",,True, True);

	AddTypeToTypesTree(FillSelectedTypes,"AccumulationRecordType",PictureLib.UT_AccumulationRecordType,,TypeAsString);
	AddTypeToTypesTree(FillSelectedTypes,"AccountType",PictureLib.ChartOfAccountsObject,,TypeAsString);
	AddTypeToTypesTree(FillSelectedTypes,"AccountingRecordType",PictureLib.ChartOfAccounts,,TypeAsString);
	AddTypeToTypesTree(FillSelectedTypes,"AccumulationRegisterAggregateUse",New Picture,,TypeAsString);
	AddTypeToTypesTree(FillSelectedTypes,"AccumulationRegisterAggregatePeriodicity",New Picture,,TypeAsString);
	
	DeleteTreeRowIfNotSubordinatesOnSearch(TypeAsString);
EndProcedure

&AtServer
Procedure FillTypesTree(FillSelectedTypes=False)
	TypesTree.GetItems().Clear();
	FillPrimitiveTypes(FillSelectedTypes);
	FillTypesByObjectType("Catalogs", "CatalogRef",PictureLib.Catalog,FillSelectedTypes);
	FillTypesByObjectType("Documents", "DocumentRef",PictureLib.Document,FillSelectedTypes);
	FillTypesByObjectType("ChartsOfCharacteristicTypes", "ChartOfCharacteristicTypesRef", PictureLib.ChartOfCharacteristicTypes,FillSelectedTypes);
	FillTypesByObjectType("ChartsOfAccounts", "ChartOfAccountsRef", PictureLib.ChartOfAccounts,FillSelectedTypes);
	FillTypesByObjectType("ChartsOfCalculationTypes", "ChartOfCalculationTypesRef", PictureLib.ChartOfCalculationTypes,FillSelectedTypes);
	FillTypesByObjectType("ExchangePlans", "ExchangePlanRef", PictureLib.ExchangePlan,FillSelectedTypes);
	FillTypesByObjectType("Enums", "EnumRef", PictureLib.Enum,FillSelectedTypes);
	FillTypesByObjectType("BusinessProcesses", "BusinessProcessRef", PictureLib.BusinessProcess,FillSelectedTypes);
	FillTypesByObjectType("Tasks", "TaskRef", PictureLib.Task,FillSelectedTypes);
	//FillTypesByObjectType("BusinessProcessRoutePointsRef", "BusinessProcessRoutePointRef");
	
	FillCharacteristicsTypes(FillSelectedTypes);
	Try
		FillDefinedTypes(FillSelectedTypes);
	Except
	EndTry;
	AddTypeToTypesTree(FillSelectedTypes,"AnyRef", New Picture, "Any reference");

	
	If WorkMode=3 Then
		AddTypeToTypesTree(FillSelectedTypes,"StandardBeginningDate", New Picture, "Standard beginning date");
		AddTypeToTypesTree(FillSelectedTypes,"StandardPeriod", New Picture, "Standard period");
		FillTypesOfSystemEnumerations(FillSelectedTypes);
	EndIf;
	
	SetSelectedTypesInTree(TypesTree,SelectedTypes);
EndProcedure

&AtServer
Procedure SetConditionalAppearance()
	// Groups cannot be selected
	NewCa=ConditionalAppearance.Items.Add();
	NewCa.Use=True;
	UT_CommonClientServer.SetFilterItem(NewCa.Filter,
		"Items.TypesTree.CurrentData.IsGroup", True);
	Field=NewCa.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("TypesTreeSelected");

	Appearance=NewCa.Appearance.FindParameterValue(New DataCompositionParameter("Show"));
	Appearance.Use=True;
	Appearance.Value=False;
	
	// If the string is unlimited, then you cannot change the allowed length of the string
	NewCa=ConditionalAppearance.Items.Add();
	NewCa.Use=True;
	UT_CommonClientServer.SetFilterItem(NewCa.Filter,
		"StringLength", 0);
	Field=NewCa.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("AcceptableFixedStringLength");

	Appearance=NewCa.Appearance.FindParameterValue(New DataCompositionParameter("ReadOnly"));
	Appearance.Use=True;
	Appearance.Value=True;
	
EndProcedure

&AtServer
Procedure DeleteTreeRowIfNotSubordinatesOnSearch(TreeRow)
	If Not ValueIsFilled(SearchString) Then
		Return;
	EndIf;
	If TreeRow.GetItems().Count()=0 Then
		TypesTree.GetItems().Delete(TreeRow);
	EndIf;
EndProcedure

&AtClient
Procedure ExpandTreeItems()
	For each TreeRow In TypesTree.GetItems() Do 
		Items.TypesTree.Expand(TreeRow.GetID());
	EndDo;
EndProcedure

&AtClientAtServerNoContext
Procedure SetSelectedTypesInTree(TreeRow,SelectedTypes)
	For Each Item In TreeRow.GetItems() Do
		Item.Selected=SelectedTypes.FindByValue(Item.Name)<>Undefined;
		
		SetSelectedTypesInTree(Item, SelectedTypes);
	EndDo;
EndProcedure

&AtClient
Procedure AddSelectedType(TreeRowOrType)
	If TypeOf(TreeRowOrType)=Type("String") Then
		TypeName=TreeRowOrType;
		UnavailableForCompositeType=False;
	 ElsIf TypeOf(TreeRowOrType)=Type("ValueListItem") Then
		TypeName=TreeRowOrType.Value;
		UnavailableForCompositeType=TreeRowOrType.Check;
	Else
		TypeName=TreeRowOrType.Name;
		UnavailableForCompositeType=TreeRowOrType.UnavailableForCompositeType;
	EndIf;
	
	If SelectedTypes.FindByValue(TypeName)=Undefined Then
		SelectedTypes.Add(TypeName,,UnavailableForCompositeType);
	EndIf;
EndProcedure
&AtClient
Procedure TypesTreeSelectedOnChangeEnd(QuestionResult, AdditionalParameters) Export
	
	Answer=QuestionResult;
	
	If Answer=DialogReturnCode.No Then
		AdditionalParameters.CurrentRow.Selected=False;
		Return;
	EndIf;

	SelectedTypes.Clear();
	TypesTreeSelectedOnChangeFragment(AdditionalParameters.CurrentRow);
EndProcedure
&AtClient
Procedure TypesTreeSelectedOnChangeEndWasNotAllowedForCompositeType(QuestionResult, AdditionalParameters) Экспорт
	
	Answer=QuestionResult;
	
	If Answer=DialogReturnCode.No Then
		AdditionalParameters.CurrentRow.Selected=False;
		Return;
	EndIf;

	DeletedItemsArray=New Array;
	For Each Item In SelectedTypes Do 
		If Item.Check Then
			DeletedItemsArray.Add(Item);
		EndIf;
	EndDo;
	
	For Each Item In  DeletedItemsArray Do
		SelectedTypes.Delete(Item);
	EndDo;
	
	TypesTreeSelectedOnChangeFragment(AdditionalParameters.CurrentRow);
EndProcedure

&AtClient
Procedure TypesTreeSelectedOnChangeFragment(CurrentRow) Export
		
	If CurrentRow.Selected Then
		AddSelectedType(CurrentRow);
	EndIf;

	If SelectedTypes.Count()=0 Then
		AddSelectedType("String");
	EndIf;
	
	SetSelectedTypesInTree(TypesTree,SelectedTypes);
EndProcedure

&AtServer
Procedure AddTypesToArrayByMetadataCollection(TypesArray, Collection, TypePrefix)
	For each MetadataObject in Collection do
		TypesArray.Add(Type(TypePrefix+MetadataObject.Name));
	Enddo;
EndProcedure

&AtServer
Function SelectedTypesArray()
	TypesArray=New Array;
	
	For Each ItemOfType In SelectedTypes Do
		TypeAsString=ItemOfType.Value;
		
		If Lower(TypeAsString)="AnyRef" Then
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Catalogs,"CatalogRef.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Documents,"DocumentRef.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ChartsOfCharacteristicTypes,"ChartOfCharacteristicTypesRef.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ChartsOfAccounts,"ChartOfAccountsRef.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ChartsOfCalculationTypes,"ChartOfCalculationTypesRef.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ExchangePlans,"ExchangePlanRef.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Enums,"EnumRef.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.BusinessProcesses,"BusinessProcessRef.");
			AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Tasks,"TaskRef.");
		 ElsIf StrFind(Lower(TypeAsString),"ref")>0 And StrFind(TypeAsString,".")=0 Then
			If Lower(TypeAsString)="catalogref" Then
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Catalogs,"CatalogRef.");
			 ElsIf Lower(TypeAsString)="documentref" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Documents,"DocumentRef.");
			 ElsIf Lower(TypeAsString)="chartofcharacteristictypesref" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ChartsOfCharacteristicTypes,"ChartOfCharacteristicTypesRef.");
			 ElsIf Lower(TypeAsString)="chartofaccountsref" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ChartsOfAccounts,"ChartOfAccountsRef.");
			 ElsIf Lower(TypeAsString)="chartofcalculationtypesref" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ChartsOfCalculationTypes,"ChartOfCalculationTypesRef.");
			 ElsIf Lower(TypeAsString)="exchangeplanref" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.ExchangePlans,"ExchangePlanRef.");
			 ElsIf Lower(TypeAsString)="enumref" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Enums,"EnumRef.");
			 ElsIf Lower(TypeAsString)="businessprocessref" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.BusinessProcesses,"BusinessProcessRef.");
			 ElsIf Lower(TypeAsString)="taskref" Then	
				AddTypesToArrayByMetadataCollection(TypesArray, Metadata.Tasks,"TaskRef.");
			EndIf;
		 ElsIf ItemOfType.Check Then
			ArrayOfName=StrSplit(TypeAsString,".");
			If ArrayOfName.Count()<>2 Then
				Continue;
			EndIf;
			ObjectName=ArrayOfName[1];
			If StrFind(Lower(TypeAsString),"characteristic")>0 Then
				MetadataObject=Metadata.ChartsOfCharacteristicTypes[ObjectName];
			 ElsIf StrFind(Lower(TypeAsString),"definedtype")>0 Then
				MetadataObject=Metadata.DefinedTypes[ObjectName];
			Иначе
				Continue;
			EndIf;
			TypeDescription=MetadataObject.Тип;
			
			For Each CurrentType ИЗ TypeDescription.Types() Do
				TypesArray.Add(CurrentType);
			EndDo;
			
		Else
			TypesArray.Add(ItemOfType.Value);
		EndIf;
	EndDo;
	
	Return TypesArray;
	
EndFunction

&AtServer
Procedure FillQualifiersDataByOriginalDataType()
	NumberLength=InitialDataType.NumberQualifiers.Digits;
	NumberPrecision=InitialDataType.NumberQualifiers.FractionDigits;
	NonnegativeNumber= InitialDataType.NumberQualifiers.AllowedSign=AllowedSign.Nonnegative;
	
	StringLength=InitialDataType.StringQualifiers.Length;
	UnlimitedStringLength=Not ValueIsFilled(StringLength);
	AcceptableFixedStringLength=InitialDataType.StringQualifiers.AllowedLength=AllowedLength.Fixed;

	If InitialDataType.DateQualifiers.DateFractions=DateFractions.Time Then
		DateFormat= 1;
	 ElsIf InitialDataType.DateQualifiers.DateFractions=DateFractions.DateTime Then
		DateFormat=2;
	EndIf;
EndProcedure

#EndRegion