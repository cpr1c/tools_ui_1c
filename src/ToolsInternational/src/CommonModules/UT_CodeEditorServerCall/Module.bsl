Function ОписнаиеМетаданныйДляИнициализацииРедактораMonaco() Export
	Return UT_CodeEditorServer.ОписнаиеМетаданныйДляИнициализацииРедактораMonaco();
EndFunction

Function ОписаниеОбъектаМетаданныхКонфигурацииПоИмени(ВидОбъекта, ObjectName) Export
	Return UT_CodeEditorServer.ОписаниеОбъектаМетаданныхКонфигурацииПоИмени(ВидОбъекта, ObjectName);	
EndFunction

Function ОписаниеМетаданныхКонфигурации(ВключатьОписаниеРеквизитов = True) Export
	Return UT_CodeEditorServer.ОписаниеМетаданныхКонфигурации(ВключатьОписаниеРеквизитов);
EndFunction

Function СписокМетаданныхПоВиду(ВидМетаданных) Export
	Return UT_CodeEditorServer.СписокМетаданныхПоВиду(ВидМетаданных);
EndFunction

Function ReferenceTypesMap() Export
	Return UT_CodeEditorServer.ReferenceTypesMap();
EndFunction
