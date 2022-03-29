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
//     MasterFormID      - UUID - form UUID. Exchange is performed through temporary storage of this form.
//     CompositionSchemaAddress            - String - an address of the temporary storage of the 
//                                                composition schema with the settings being edited.
//     FilterComposerSettingsAddress - String - an address of the temporary storage with editable composer settings.
//     FilterAreaPresentation      - String - a presentation for title generation.
//
// Return value:
//
//     Undefined - edit was cancelled.
//     String       - an address of the temporary storage of new composer settings.
//
#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	MasterFormID = Parameters.MasterFormID;
	
	PrefilterComposer = New DataCompositionSettingsComposer;
	PrefilterComposer.Initialize( 
		New DataCompositionAvailableSettingsSource(Parameters.CompositionSchemaAddress) );
		
	FilterComposerSettingsAddress = Parameters.FilterComposerSettingsAddress;
	PrefilterComposer.LoadSettings(GetFromTempStorage(FilterComposerSettingsAddress));
	DeleteFromTempStorage(FilterComposerSettingsAddress);
	
	Title = StrTemplate(NStr("ru = 'Правила отбора ""%1""'; en = 'Filter rule: %1'"), Parameters.FilterAreaPresentation);
EndProcedure

#EndRegion

#Region FormCommandHandlers

&AtClient
Procedure Select(Command)
	
	If Modified Then
		NotifyChoice(FilterComposerSettingsAddress());
	Else
		Close();
	EndIf;
	
EndProcedure

#EndRegion

#Region Private

&AtServer
Function FilterComposerSettingsAddress()
	Return PutToTempStorage(PrefilterComposer.Settings, MasterFormID)
EndFunction

#EndRegion