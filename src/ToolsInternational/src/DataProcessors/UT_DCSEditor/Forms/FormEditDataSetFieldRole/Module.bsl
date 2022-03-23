&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	RoleString=Parameters.Role;
	If RoleString<>Undefined Then
		FillPropertyValues(ThisObject, RoleString);
	Else
		WithoutRole=True;
		BalanceType="None";
		AccountingBalanceType="None";
		PeriodNumber=1;
	EndIf;
	
	Items.ParentDimension.ChoiceList.Clear();
	For Each Field ИЗ Parameters.DataSetFieldsArray Do
		Items.ParentDimension.ChoiceList.Add(Field);
	EndDo;
	
	Title="Role - "+Parameters.DataPath;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	SetEnabled();
EndProcedure
&AtClient
Procedure SetEnabled()
	Items.GroupPeriodParameters.Enabled=Period;
	Items.ParentDimension.Enabled=Dimension;
	Items.AccountTypeExpression.Enabled=Account;
	Items.GroupBalanceParameters.Enabled=Balance;
EndProcedure

&AtClient
Procedure WithoutRoleOnChange(Item)
	
	If Not WithoutRole Then
		WithoutRole=True;
		Return;
	EndIf;
	Period=False;
	Dimension=False;
	Account=False;
	Balance=False;

	SetEnabled();
	
EndProcedure

&AtClient
Procedure PeriodOnChange(Item)
	If Not Period Then
		Period=True;
		Return;
	EndIf;
	WithoutRole=False;
	Dimension=False;
	Account=False;
	Balance=False;

	SetEnabled();
EndProcedure

&AtClient
Procedure DimensionOnChange(Item)
	If Not Dimension Then
		Dimension=True;
		Return;
	EndIf;
	WithoutRole=False;
	Period=False;
	Account=False;
	Balance=False;

	SetEnabled();
EndProcedure

&AtClient
Procedure AccountOnChange(Item)
	If Not Account Then
		Account=True;
		Return;
	EndIf;
	WithoutRole=False;
	Period=False;
	Dimension=False;
	Balance=False;

	SetEnabled();
EndProcedure

&AtClient
Procedure BalanceOnChange(Item)
	If Not Balance Then
		Balance=True;
		Return;
	EndIf;
	WithoutRole=False;
	Period=False;
	Dimension=False;
	Account=False;

	SetEnabled();
	
EndProcedure

&AtClient
Procedure Apply(Command)
	Role=New Structure;
	Role.Insert("AccountTypeExpression", AccountTypeExpression);
	Role.Insert("BalanceGroup", BalanceGroup);
	Role.Insert("IgnoreNULLValues", IgnoreNULLValues);
	Role.Insert("Dimension", Dimension);
	Role.Insert("Period", Period);
	Role.Insert("PeriodNumber", PeriodNumber);
	Role.Insert("Required", Required);
	Role.Insert("Balance", Balance);
	Role.Insert("AccountField", AccountField);
	Role.Insert("ParentDimension", ParentDimension);
	Role.Insert("Account", Account);
	Role.Insert("AccountingBalanceType", AccountingBalanceType);
	Role.Insert("BalanceType", BalanceType);
	Role.Insert("PeriodAdditional", PeriodAdditional);
	
	Close(Role);
EndProcedure