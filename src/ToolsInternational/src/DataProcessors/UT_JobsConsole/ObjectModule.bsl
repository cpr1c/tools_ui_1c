#Region ExternalDataProcessorInfo
// -------------------------------------------------------
//
// SSL
// 

// Data processor information for registration as external.
//
// Returning value:
//   Structure   - typical parameters of SSL external data processor.
//
Function ExternalDataProcessorInfo() Export
	
	// Declaring variable for saving and returning data.
	RegistrationParameters = New Structure;
	// Declaring another variable.
	PurposesArray = New Array;
	
	// Kind of data processor to register. 
	// Available kinds: AdditionalDataProcessor, AdditionalReport, ObjectFilling, Report, PrintForm, RelatedObjectsCreation.
	RegistrationParameters.Insert("Kind", "AdditionalDataProcessor");
	
	// Metadata types array, data processor to be connected to.
	// Mask Document.* is available - in this case data processor will be connected to all document types 
	// supporting the External print forms functionality.
	RegistrationParameters.Insert("Purpose", PurposesArray);
	
	// Data processor description to be register in external data processors catalog.
	RegistrationParameters.Insert("Description", DataProcessorDescription());
	
	// Safe mode right. For more information see SetSafeMode() method.
	RegistrationParameters.Insert("SafeMode", False);
	
	// Version and info to display as data processor information.
	RegistrationParameters.Insert("Version", DataProcessorVersion());
	RegistrationParameters.Insert("Information", DataProcessorInfo());
	
	// Creating command table (see below).
	CommandTable = InitializeCommandTable();
	
	TableRow = CommandTable.Add();
	TableRow.ID = "OpenJobsConsole";
	TableRow.Presentation = "Open Jobs console";
	TableRow.ShowNotification = False;
	TableRow.StartupOption = "OpeningForm";
	
	// Saving command table into registration parameters.
	RegistrationParameters.Insert("Commands", CommandTable);
	
	// Returning parameters.
	Return RegistrationParameters;
	
EndFunction

// Executes command in background.
Procedure ExecuteCommand(CommandID) Export
	
	If CommandID = Undefined Then
		
		CommandID = "";
		
	EndIf;
	
EndProcedure

Function DataProcessorDescription()
	
	Return Metadata().Synonym;
	
EndFunction

Function DataProcessorInfo()
	
	Return Metadata().Comment;
	
EndFunction

Function DataProcessorVersion() Export
	
	Return "1.10";
	
EndFunction

Function InitializeCommandTable()
	
	// Creating new command table.
	Commands = New ValueTable;
	
	// Data processor user presentation.
	Commands.Columns.Add("Presentation", New TypeDescription("String")); 
	
	// Template name for print data processor.
	Commands.Columns.Add("ID", New TypeDescription("String"));
	
	// Command startup option.
	// Options available:
	// - OpeningForm - the ID column must contain form name,
	// - ClientMethodCall - calls the client export procedure from data processor main form module,
	// - ServerMethodCall - calls the server export procedure from data processor object module.
	Commands.Columns.Add("StartupOption", New TypeDescription("String"));
	
	// If True, the notification will be displayed on execution start and finish. Not used in OpeningForm mode.
	Commands.Columns.Add("ShowNotification", New TypeDescription("Boolean"));
	
	// If Kind = "PrintForm", must contain "MXLPrinting". 
	Commands.Columns.Add("Modificator", New TypeDescription("String"));
	Return Commands;
EndFunction

#EndRegion