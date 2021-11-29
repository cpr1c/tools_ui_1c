// Storage of global variables.
//
// ApplicationParameters - Map - value storage, where:
//   * Key - String - a variable name in the format of  "LibraryName.VariableName";
//   * Value - Arbitrary - a variable value.
//
// Initialization (see the example of MessagesForEventLog):
//   ParameterName = "StandardSubsystems.MessagesForEventLog";
//   If ApplicationParameters[ParameterName] = Undefined Then
//     ApplicationParameters.Insert(ParameterName, New ValueList);
//   EndIf.
//  
// Usage (as illustrated by MessagesForEventLog):
//   ApplicationParameters["StandardSubsystems.MessagesForEventLog"].Add(...);
//   ApplicationParameters["StandardSubsystems.MessagesForEventLog"] = ...;

Var UT_ApplicationParameters Export;

//@skip-warning
&After("OnStart")
Procedure UT_OnStart()
	#If Not MobileClient Then
	UT_CommonClient.OnStart();	
	#EndIf
EndProcedure

//@skip-warning
&After("OnExit")
Procedure UT_OnExit()
	#If Not MobileClient Then
	UT_CommonClient.OnExit();	
	#EndIf
EndProcedure


UT_ApplicationParameters = New Map;
 