&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("Title") Then
		Title  = Parameters.Title;
	EndIf;

	If Parameters.Property("ReturnOnlySelectedValues") Then
		ReturnOnlySelectedValues=Parameters.ReturnOnlySelectedValues;
	EndIf;

	ValueList=Parameters.List;
	If Parameters.Property("ItemsType") Then
		If Parameters.ItemsType <> Undefined И Parameters.ItemsType <> New TypeDescription Then
			ValueList.ValueType=Parameters.ItemsType;
		EndIf;
	EndIf;

	If Parameters.Property("CheckVisible") Then
		Items.ValueListCheck.Visible=Parameters.CheckVisible;
	EndIf;
	If Parameters.Property("PresentationVisible") Then
		Items.ValueListPresentation.Visible=Parameters.PresentationVisible;
	EndIf;

	If Parameters.Property("PickMode") Then
		PickMode=Parameters.PickMode;
	Else
		PickMode=False;
	EndIf;

	Items.ValueList.ChangeRowOrder=PickMode;
	Items.ValueList.ChangeRowSet=PickMode;
	Items.ValueListValue.ReadOnly=Not PickMode;
	If Not PickMode Then
		Items.ValueList.CommandBarLocation=FormItemCommandBarLabelLocation.None;
	EndIf;

	If Parameters.Property("AvailableValues") Then
		Items.ValueListValue.ListChoiceMode=True;
		Items.ValueListValue.ChoiceList.Clear();

		For Each ListItem In Parameters.AvailableValues Do
			Items.ValueListValue.ChoiceList.Add(ListItem.Value, ListItem.Presentation,
				ListItem.Check, ListItem.Picture);
		EndDo;
	EndIf;
	
EndProcedure

&AtClient
Procedure Apply(Command)
	If Not ReturnOnlySelectedValues Then
		ReturnList=ValueList;
	Else
		ReturnList=New ValueList;

		For Each Item In ValueList Do
			If Not Item.Check Then
				Continue;
			EndIf;
			ReturnList.Add(Item.Value, Item.Presentation, Item.Check, Item.Picture);
		EndDo;
	EndIf;
	Close(ReturnList);
EndProcedure