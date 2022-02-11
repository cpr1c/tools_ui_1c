Function MetaDataDescriptionForMonacoEditorInitialize() Export
	Return UT_CodeEditorServer.MetaDataDescriptionForMonacoEditorInitialize();
EndFunction

Function ConfigurationMetadataObjectDescriptionByName(ObjectType, ObjectName) Export
	Return UT_CodeEditorServer.ConfigurationMetadataObjectDescriptionByName(ObjectType, ObjectName);	
EndFunction

Function ConfigurationMetadataDescription(IncludeAttributesDescription = True) Export
	Return UT_CodeEditorServer.ConfigurationMetadataDescription(IncludeAttributesDescription);
EndFunction

Function MetadataListByType(MetadataType) Export
	Return UT_CodeEditorServer.MetadataListByType(MetadataType);
EndFunction

Function ReferenceTypesMap() Export
	Return UT_CodeEditorServer.ReferenceTypesMap();
EndFunction
