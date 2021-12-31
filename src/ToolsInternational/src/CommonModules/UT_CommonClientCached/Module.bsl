
// See SSL  StandartSybsystemsCached.RefsByPredefinedItemsNames
Function RefsByPredefinedItemsNames(FullMetadataObjectName) Export

	Return UT_CommonServerCall.RefsByPredefinedItemsNames(FullMetadataObjectName);

EndFunction

Function DataBaseObjectEditorAvalibleObjectsTypes() Export
	Return UT_CommonCached.DataBaseObjectEditorAvalibleObjectsTypes();
EndFunction

Function HTMLFieldBasedOnWebkit() Export
	UT_CommonClientServer.HTMLFieldBasedOnWebkit();
EndFunction