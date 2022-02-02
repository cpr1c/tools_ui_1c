&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Try
		Value = ValueFromStringInternal(Parameters.InterValue);
	Except
		Message(BriefErrorDescription(ErrorInfo()));
		Cancel = True;
		Return;
	EndTry;

	If TypeOf(Value) = Type("Boundary") Then
		_ValueType = "Boundary";
		_BoundaryValue = Value.Value;
		_BoundaryBoundaryType = Value.BoundaryType;

		Items.GroupPointInTime.Visible = False;

	ElsIf TypeOf(Value) = Type("PointInTime") Then
		_ValueType = "PointInTime";
		_PointInTimeDate = Value.Date;
		_PointInTimeRef = Value.Ref;

		Items.GroupBoundary.Visible = False;

	Else
		Cancel = True;
		Return;
	EndIf;

	If Not IsBlankString(Parameters.Title) Then
		ThisForm.Title = Parameters.Title;
	EndIf;
EndProcedure

&AtClient
Procedure CommandClose(Command)
	Close();
EndProcedure

&AtServerNoContext
Function GenerateSpecialValue(Val varType, Val varValue1, Val varValue2)
	varStruct = New Structure("Cancel, Value, Presentation", False);

	Try
		If varType = "Boundary" Then
			If varValue2 = "Excluding" Then
				varValue2 = BoundaryType.Excluding;
			Else
				varValue2 = BoundaryType.Including;
			EndIf;

			varStruct.Value = New Boundary(varValue1, varValue2);
			varStruct.Presentation = String(varStruct.Value.Value) + ";" + String(varStruct.Value.BoundaryType);

		ElsIf varType = "PointInTime" Then
			varStruct.Value = New PointInTime(varValue1, varValue2);
			varStruct.Presentation = String(varStruct.Value);

		Else
			varStruct.Cancel = True;
			Message(Nstr("ru = 'Неизвестный тип данных!';en = 'Unknown data type!'"));
		EndIf;

	Except
		varStruct.Cancel = True;
		Message(BriefErrorDescription(ErrorInfo()));
	EndTry;

	If Not varStruct.Cancel Then
		varStruct.Value = ValueToStringInternal(varStruct.Value);
	EndIf;

	Return varStruct;
EndFunction

&AtClient
Procedure CommandOK(Command)
	Result = New Structure;
	Result.Insert("ValueType", _ValueType);

	If _ValueType = "Boundary" Then
		varStruct = GenerateSpecialValue(_ValueType, _BoundaryValue, _BoundaryBoundaryType);
	ElsIf _ValueType = "PointInTime" Then
		varStruct = GenerateSpecialValue(_ValueType, _PointInTimeDate, _PointInTimeRef);
	Else
		Return;
	EndIf;

	If varStruct.Cancel Then
		Return;
	EndIf;

	Result.Insert("StringInternal", varStruct.Value);
	Result.Insert("Presentation", varStruct.Presentation);

	Close(Result);
EndProcedure
