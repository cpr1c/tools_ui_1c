&After("OnDefineAttachableCommandsKinds")
Процедура UT_OnDefineAttachableCommandsKinds(AttachableCommandsKinds)
	If Not UT_Common.CanUseUniversalTools() Then
		Return;
	EndIf;
	Kind = AttachableCommandsKinds.Add();
	Kind.Name         = "UT_UniversalTools";
	Kind.SubmenuName  = "UT_UniversalTools";
	Kind.Title   = НСтр("ru = 'Инструменты';en = 'Universal tools'");
	Kind.Picture    = PictureLib.UT_UniversalToolsSybsystem;
	Kind.Representation = ButtonRepresentation.Picture;
	Kind.Order = 1;
	Kind.FormGroupType=FormGroupType.Popup;
КонецПроцедуры

&После("OnDefineCommandsAttachedToObject")
Процедура UT_OnDefineCommandsAttachedToObject(FormSettings, Sources, AttachedReportsAndDataProcessors, Commands)
	If Not UT_Common.CanUseUniversalTools() Then
		Return;
	EndIf;
	Command = Commands.Add();
	Command.Kind="UT_UniversalTools";
	Command.ID="УИ_СравнениеОбъектов";
	Command.Presentation="Сравнить объекты";
	Command.ParameterType=UT_CommonCached.AllRefsTypeDescription();
	Command.Purpose="ДляСписка";
	Command.ChangesSelectedObjects=Ложь;
	Command.MultipleChoice=Истина;
	//		Command.Менеджер = "Обработка.УИ_СравнениеОбъектов";
	Command.FormName = "Обработка.УИ_СравнениеОбъектов.Форма";
	Command.FormParameterName = "СравниваемыеОбъекты";
	Command.Order=0;

	Command = Commands.Add();
	Command.Kind="UT_UniversalTools";
	Command.ID="УИ_ДобавитьКСравнению";
	Command.Presentation="Добавить к сравнению";
	Command.ParameterType=UT_CommonCached.AllRefsTypeDescription();
	Command.ChangesSelectedObjects=Ложь;
	Command.MultipleChoice=Истина;
	Command.Handler = "UT_CommonClient.ДобавитьОбъектыКСравнению";
	Command.Order=1;

	Command = Commands.Add();
	Command.Kind="UT_UniversalTools";
	Command.ID="УИ_ВыгрузитьОбъектыВXML";
	Command.Presentation="Выгрузить объекты в XML";
	Command.ParameterType=UT_CommonCached.AllRefsTypeDescription();
	Command.ChangesSelectedObjects=Ложь;
	Command.MultipleChoice=Истина;
	Command.Picture=БиблиотекаКартинок.UT_UploadingResult;
	Command.Handler = "UT_CommonClient.ВыгрузитьОбъектыВXML";
	Command.Order=1;

	Command = Commands.Add();
	Command.Kind="UT_UniversalTools";
	Command.ID="УИ_РедактироватьОбъект";
	Command.Presentation="Редактировать объект";
	Command.ParameterType=UT_CommonCached.AllRefsTypeDescription();
	Command.ChangesSelectedObjects=Ложь;
	Command.MultipleChoice=Ложь;
	Command.Картинка=БиблиотекаКартинок.UT_DatabaseObjectEditor;
	Command.Handler = "UT_CommonClient.ОбработчикКомандыРедактироватьОбъект";
	Command.Order=2;
	
	Command = Commands.Add();
	Command.Kind="UT_UniversalTools";
	Command.ID="УИ_ПоискСсылокНаОбъект";
	Command.Presentation="Найти ссылки объект";
	Command.ParameterType=UT_CommonCached.AllRefsTypeDescription();
	Command.ChangesSelectedObjects=Ложь;
	Command.MultipleChoice=Ложь;
	Command.Picture=БиблиотекаКартинок.НайтиВСодержании;
	Command.Handler = "UT_CommonClient.FindObjectRefsCommandHandler";
	Command.Order=3;
	
КонецПроцедуры