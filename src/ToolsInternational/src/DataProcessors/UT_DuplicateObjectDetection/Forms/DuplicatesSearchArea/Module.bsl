///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, 1C-Soft LLC
// All Rights reserved. This application and supporting materials are provided under the terms of 
// Attribution 4.0 International license (CC BY 4.0)
// The license text is available at:
// https://creativecommons.org/licenses/by/4.0/legalcode
// Translated by Neti Company
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Parameters:
//
//     DuplicatesSearchArea - String - a full name of the table metadata of the area selected for search.
//
// Return value:
//
//     Undefined - edit was cancelled.
//     String       - an address of the temporary storage of new composer settings.
//
#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	Parameters.Property("DuplicatesSearchArea", DefaultArea);
	Parameters.Property("SettingsAddress", SettingsAddress);
	
	InitializeSearchForDuplicatesAreasList();
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure DuplicatesSearchAreasSelection(Item, RowSelected, Field, StandardProcessing)

	MakeChoice(RowSelected);
	
EndProcedure

#EndRegion

#Region FormCommandHandlers

&AtClient
Procedure Select(Command)
	
	MakeChoice(Items.DuplicatesSearchAreas.CurrentRow);
	
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure MakeChoice(Val RowID)
	
	Item = DuplicatesSearchAreas.FindByID(RowID);
	If Item = Undefined Then
		Return;
		
	ElsIf Item.Value = DefaultArea Then
		// No changes were made
		Close();
		Return;
		
	EndIf;
	
	NotifyChoice(Item.Value);
EndProcedure

&AtServer
Procedure InitializeSearchForDuplicatesAreasList()
	If ValueIsFilled(SettingsAddress)
		AND IsTempStorageURL(SettingsAddress) Then
		SettingsTable = GetFromTempStorage(SettingsAddress);
	Else
		SettingsTable = DataProcessors.UT_DuplicateObjectDetection.MetadataObjectsSettings();
		SettingsAddress = PutToTempStorage(SettingsTable, UUID);
	EndIf;
	
	For Each TableRow In SettingsTable Do
		Item = DuplicatesSearchAreas.Add(TableRow.FullName, TableRow.ListPresentation, , PictureLib[TableRow.Kind]);
		If TableRow.FullName = DefaultArea Then
			Items.DuplicatesSearchAreas.CurrentRow = Item.GetID();
		EndIf;
	EndDo;
EndProcedure

#EndRegion