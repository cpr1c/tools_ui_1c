#Region Public

Function ПрефиксЭлементовРедактораКода() Export
	Return "РедакторКода1С";
EndFunction

Function ИмяРеквизитаРедактораКода(ИдентификаторРедактора) Export
	Return ПрефиксЭлементовРедактораКода()+"_"+ИдентификаторРедактора;
EndFunction

Function ИмяРеквизитаРедактораКодаВидРедактора() Export
	Return ПрефиксЭлементовРедактораКода()+"_ВидРедактора";
EndFunction

Function ИмяРеквизитаРедактораКодаАдресБиблиотеки() Export
	Return ПрефиксЭлементовРедактораКода()+"_АдресБиблиотекиВоВременномХранилище";
EndFunction

Function ИмяРеквизитаРедактораКодаСписокРедакторовФормы() Export
	Return ПрефиксЭлементовРедактораКода()+"_СписокРедакторовФормы";
EndFunction

Function ИмяРеквизитаРедактораКодаРедакторыФормы(ИдентификаторРедактора) Export
	Return ПрефиксЭлементовРедактораКода()+"_РедакторыФормы";
EndFunction

Function ВариантыРедактораКода() Export
	Variants = New Structure;
	Variants.Insert("Text", "Text");
	Variants.Insert("Ace", "Ace");
	Variants.Insert("Monaco", "Monaco");

	Return Variants;
EndFunction

Function ВариантРедактораПоУмолчанию() Export
	Return ВариантыРедактораКода().Monaco;
EndFunction

Function РедакторКодаИспользуетПолеHTML(ВидРедактора) Export
	Variants=ВариантыРедактораКода();
	Return ВидРедактора = Variants.Ace
		Or ВидРедактора = Variants.Monaco;
EndFunction

Function ИдентификаторРедактораПоЭлементуФормы(Form, Item) Export
	РедакторыФормы = Form[UT_CodeEditorClientServer.ИмяРеквизитаРедактораКодаСписокРедакторовФормы()];

	For Each КлючЗначение In РедакторыФормы Do
		If КлючЗначение.Value.ПолеРедактора = Item.Name Then
			Return КлючЗначение.Key;
		EndIf;
	EndDo;

	Return Undefined;
EndFunction

Function ВыполнитьАлгоритм(__ТекстАлготима__, __Контекст__) Export
	Успешно = True;
	ErrorDescription = "";
	
	ВыполняемыйТекстАлгоритма = ДополненныйКонтекстомКодАлгоритма(__ТекстАлготима__, __Контекст__);

	НачалоВыполнения = CurrentUniversalDateInMilliseconds();
	Try
		Execute (ВыполняемыйТекстАлгоритма);
	Except
		Успешно = False;
		ErrorDescription = ErrorDescription();
		Message(ErrorDescription);
	EndTry;
	ОкончаниеВыполнения = CurrentUniversalDateInMilliseconds();

	РезультатВыполнения = New Structure;
	РезультатВыполнения.Insert("Успешно", Успешно);
	РезультатВыполнения.Insert("ВремяВыполнения", ОкончаниеВыполнения - НачалоВыполнения);
	РезультатВыполнения.Insert("ErrorDescription", ErrorDescription);

	Return РезультатВыполнения;
EndFunction

#EndRegion

#Region Internal

Function ВариантыЯзыкаСинтаксисаРедактораMonaco() Export
	ЯзыкиСинтаксиса = New Structure;
	ЯзыкиСинтаксиса.Insert("Auto", "Auto");
	ЯзыкиСинтаксиса.Insert("Russian", "Russian");
	ЯзыкиСинтаксиса.Insert("English", "English");
	
	Return ЯзыкиСинтаксиса;
EndFunction

Function ВариантыТемыРедактораMonaco() Export
	Variants = New Structure;
	
	Variants.Insert("Светлая", "Светлая");
	Variants.Insert("Темная", "Темная");
	
	Return Variants;
EndFunction

Function ТемаРедактораMonacoПоУмолчанию() Export
	ТемыРедактора = ВариантыТемыРедактораMonaco();
	
	Return ТемыРедактора.Светлая;
EndFunction
Function ЯзыкСинтаксисаРедактораMonacoПоУмолчанию() Export
	Variants = ВариантыЯзыкаСинтаксисаРедактораMonaco();
	
	Return Variants.Auto;
EndFunction

Function ПараметрыРедактораMonacoПоУмолчанию() Export
	ПараметрыРедактора = New Structure;
	ПараметрыРедактора.Insert("ВысотаСтрок", 0);
	ПараметрыРедактора.Insert("Subject", ТемаРедактораMonacoПоУмолчанию());
	ПараметрыРедактора.Insert("ЯзыкСинтаксиса", ЯзыкСинтаксисаРедактораMonacoПоУмолчанию());
	ПараметрыРедактора.Insert("ИспользоватьКартуКода", False);
	ПараметрыРедактора.Insert("СкрытьНомераСтрок", False);
	ПараметрыРедактора.Insert("КаталогиИсходныхФайлов", New Array);
	
	Return ПараметрыРедактора;
EndFunction

Function ПараметрыРедактораКодаПоУмолчанию() Export
	ПараметрыРедактора = New Structure;
	ПараметрыРедактора.Insert("Variant",  ВариантРедактораПоУмолчанию());
	ПараметрыРедактора.Insert("РазмерШрифта", 0);
	ПараметрыРедактора.Insert("Monaco", ПараметрыРедактораMonacoПоУмолчанию());
	
	Return ПараметрыРедактора;
EndFunction

Function НовыйОписаниеКаталогаИсходныхФайловКонфигурации() Export
	LongDesc = New Structure;
	LongDesc.Insert("Directory", "");
	LongDesc.Insert("Src", "");
	
	Return LongDesc;
EndFunction

#EndRegion

#Region Private

Function ДополненныйКонтекстомКодАлгоритма(ТекстАлготима, Контекст)
	ПодготовленныйКод="";

	For Each КлючЗначение In Контекст Do
		ПодготовленныйКод = ПодготовленныйКод +"
		|"+КлючЗначение.Key+"=__Контекст__."+КлючЗначение.Key+";";
	EndDo;

	ПодготовленныйКод=ПодготовленныйКод + Chars.LF + ТекстАлготима;

	Return ПодготовленныйКод;
EndFunction

#EndRegion