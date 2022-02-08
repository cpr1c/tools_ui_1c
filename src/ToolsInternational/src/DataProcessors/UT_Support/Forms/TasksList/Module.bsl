#Region EventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, СтандартнаяОбработка)
	ОбновитьСписокЗадачНаСервере();
EndProcedure

#EndRegion

#Region ОбработчикиСобытийЭлементовФормы

&AtClient
Procedure СписокЗадачВыбор(Item, ВыбраннаяСтрока, Field, СтандартнаяОбработка)
	СтандартнаяОбработка = False;

	RowData = СписокЗадач.FindByID(ВыбраннаяСтрока);

	BeginRunningApplication(UT_CommonClient.ApplicationRunEmptyNotifyDescription(), RowData.URL);
EndProcedure

#EndRegion

#Region ОбработчикиКомандФормы

&AtClient
Procedure ОбновитьСписокЗадач(Command)
	ОбновитьСписокЗадачНаСервере();
EndProcedure

&AtClient
Procedure СтраницаРазработки(Command)
	UT_CommonClient.OpenAboutPage();
EndProcedure
#EndRegion

#Region Private

&AtServer
Procedure ОбновитьСписокЗадачНаСервере()
	СписокЗадач.Clear();

	БазовыйАдрес = "https://api.github.com/repos/cpr1c/tools_ui_1c/issues";

	PageNumber=1;
	СписокЗадачРепозитория = UT_HTTPConnector.GetJson(БазовыйАдрес+"?per_page=100&page="+Format(PageNumber,"ЧГ=0;"));
	While СписокЗадачРепозитория.Count() > 0 Do

		For Each ЗадачаРепозитория In СписокЗадачРепозитория Do
			НоваяЗадача = СписокЗадач.Add();
			НоваяЗадача.Number = ЗадачаРепозитория["number"];
			НоваяЗадача.URL = ЗадачаРепозитория["html_url"];
			НоваяЗадача.Subject = ЗадачаРепозитория["title"];
			НоваяЗадача.Статус = ЗадачаРепозитория["state"];
			ОтветственныйЗадача = ЗадачаРепозитория["assignee"];
			If TypeOf(ОтветственныйЗадача) = Type("Map") Then
				НоваяЗадача.Ответственный = ОтветственныйЗадача["login"];
			EndIf;

			ТегиЗадачи = ЗадачаРепозитория["labels"];
			If TypeOf(ТегиЗадачи) = Type("Array") Then
				For Each ТекущийТег In ТегиЗадачи Do
					НоваяЗадача.Теги.Add(ТекущийТег["name"]);
				EndDo;
			EndIf;

		EndDo;

		PageNumber=PageNumber+1;
		СписокЗадачРепозитория = UT_HTTPConnector.GetJson(БазовыйАдрес+"?per_page=100&page="+Format(PageNumber,"ЧГ=0;"));
	
	EndDo;

EndProcedure

&AtServer
Function СоздатьНовуюЗадачуНаСервере()
	ТокенАвторизации = "d1af40528d2ceec322be578bc935a1b46b9af8cc";

	Headers = New Map;
	Headers.Insert("Authorization", "token " + ТокенАвторизации);

	СтруктураТела = New Structure;
	СтруктураТела.Insert("title", НоваяЗадачаТема);
	СтруктураТела.Insert("body", НоваяЗадачаОписание);

	БазовыйАдрес = "https://api.github.com/repos/cpr1c/tools_ui_1c/issues";

	Аутентификация = New Structure("User, Password", "tools-ui", ТокенАвторизации);

	Ответ = UT_HTTPConnector.PostJson(БазовыйАдрес, СтруктураТела, New Structure("Headers, Аутентификация",
		Headers, Аутентификация));

	ОбновитьСписокЗадачНаСервере();

	Return Ответ["html_url"];

EndFunction

&AtClient
Procedure СоздатьНовуюЗадачу(Command)
	If Not CheckFilling() Then
		Return;
	EndIf;

	АдресЗадачи=СоздатьНовуюЗадачуНаСервере();
	If АдресЗадачи <> Undefined Then
		UT_CommonClientServer.MessageToUser("Task успешно создана");
		BeginRunningApplication(UT_CommonClient.ApplicationRunEmptyNotifyDescription(), АдресЗадачи);
	Else
		UT_CommonClientServer.MessageToUser("Creating задачи не удалось");
	EndIf;

EndProcedure

&AtClient
Procedure СоздатьНовуюЗадачуНаГитхабе(Command)
	BeginRunningApplication(UT_CommonClient.ApplicationRunEmptyNotifyDescription(),
		"https://github.com/cpr1c/tools_ui_1c/issues/new");
EndProcedure

#EndRegion