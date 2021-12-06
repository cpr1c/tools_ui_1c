#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Predefined = False;
	Use = False;
	
	For Each MetadataItem In Metadata.ScheduledJobs Do
		Items.MetadataChoice.ChoiceList.Add(MetadataItem.Имя, MetadataItem.Presentation());
	EndDo;
	
	If Parameters.Filter <> Undefined Then
		For Each Property In Parameters.Filter Do
			If Property.Key = "Key" Then
				Key = Property.Value;
			ElsIf Property.Ключ = "Description" Then
				Description = Property.Value;	
			ElsIf Property.Ключ = "Use" Then
				Use = Property.Value;	
			ElsIf Property.Ключ = "Predefined" Then
				Predefined = Property.Value;	
			ElsIf Property.Ключ = "Metadata" Then
				MetadataChoice = Property.Value;
			Else
				Continue;
			EndIf;		
		EndDo;
	EndIf;
EndProcedure

#EndRegion

#Region ItemsEventHandlers

&AtClient
Procedure OK(Command)
	Filter = New Structure;
	
	If Not IsBlankString(Key) Then
		Filter.Add("Key", Key);
	EndIf;
	
	If Not IsBlankString(Description) Then
		Filter.Add("Description", Description);
	EndIf;
	
	If MetadataChoice <> "" Then
		Filter.Add("Metadata", MetadataChoice);
	EndIf;
	
	If Predefined Then
		Filter.Add("Predefined", Predefined);
	EndIf;
	
	If Use Then
		Filter.Add("Use", Use);
	EndIf;
	
	Close(Filter);
EndProcedure

#EndRegiion