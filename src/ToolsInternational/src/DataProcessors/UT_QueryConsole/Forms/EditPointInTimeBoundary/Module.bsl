
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	CopyFormData(Parameters.Object, Object);
	
	Value = Parameters.Value;
	If Value.Type = "Boundary" Then
		
		Items.BoundaryGroup.Visible = True;
		Items.PointInTimeGroup.Visible = False;
		Title = NStr("ru = 'Граница времени'; en = 'Time boundary'");
		
		BoundaryValue = Value.Value;
		BoundaryType = Value.BoundaryType;
		
	ElsIf Value.Type = "PointInTime" Then
		
		Items.BoundaryGroup.Visible = False;
		Items.PointInTimeGroup.Visible = True;
		Title = NStr("ru = 'Момент времени'; en = 'Point in time'");
		
		PointInTimeDate = Value.Date;
		PointInTimeRef = Value.Ref;
		
	EndIf;
	
EndProcedure

&AtClient
//Code duplication for avoid serevr call. In the object module the Container_GetPresentation function does the same.
Function GetBoundaryPresentation()
	Return String(Value.Value) + " " + Value.BoundaryType;
EndFunction
	
&AtClient
//Code duplication for avoid serevr call. In the object module the Container_GetPresentation function does the same.
Function GetPointInTimePresentation()
	Return Строка(Value.Date) + ";" + Value.Ref;
EndFunction

&AtClient
Procedure OKCommand(Command)
	
	If Value.Type = "Boundary" Then
		
		Value.Value = BoundaryValue;
		Value.BoundaryType = BoundaryType;
		Value.Presentation = GetBoundaryPresentation();
		
	ElsIf Value.Type = "PointInTime" Then
		
		Value.Date = PointInTimeDate;
		Value.Ref = PointInTimeRef;
		Value.Presentation = GetPointInTimePresentation();
		
	EndIf;
	
	ReturnValue = New Структура("Value", Value);
	Close(ReturnValue);
		
EndProcedure

&AtServerNoContext
Function GetRefDate(Ref)
	Var IBTable;
	
	If Documents.AllRefsType().ContainsType(TypeOf(Ref)) Then
		//@skip-warning
		IBTable = "Document." + Ref.Metadata().Name;
	ElsIf Tasks.AllRefsType().ContainsType(TypeOf(Ref)) Then
		//@skip-warning
		IBTable = "Task." + Ref.Metadata().Name;
	EndIf;
	
	If ValueIsFilled(IBTable) Then
		Query = New Query("SELECT Date FROM " + IBTable + " WHERE Ref = &Ref");
		Query.SetParameter("Ref", Ref);
		Selection = Query.Execute().Select();
		If Selection.Next() Then
			Return Selection.Date;
		EndIf;
	EndIf;
	
	Return Undefined;
	
EndFunction

&AtClient
Procedure PointInTimeRefOnChange(Item)
	RefDate = GetRefDate(PointInTimeRef);
	If ValueIsFilled(RefDate) Then
		PointInTimeDate = RefDate;
	EndIf;
EndProcedure
