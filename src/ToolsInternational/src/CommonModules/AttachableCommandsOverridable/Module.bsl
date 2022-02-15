&After("OnDefineAttachableCommandsKinds")
Procedure UT_OnDefineAttachableCommandsKinds(AttachableCommandsKinds)
	If Not UT_Common.HasRightToUseUniversalTools() Then
		Return;
	EndIf;
	Kind = AttachableCommandsKinds.Add();
	Kind.Name         = "UT_UniversalTools";
	Kind.SubmenuName  = "UT_UniversalTools";
	Kind.Title   = NStr("ru = 'Инструменты';en = 'Universal tools'");
	Kind.Picture    = PictureLib.UT_UniversalToolsSybsystem;
	Kind.Representation = ButtonRepresentation.Picture;
	Kind.Order = 1;
	Kind.FormGroupType=FormGroupType.Popup;
EndProcedure

&After("OnDefineCommandsAttachedToObject")
Procedure UT_OnDefineCommandsAttachedToObject(FormSettings, Sources, AttachedReportsAndDataProcessors, Commands)
	If Not UT_Common.HasRightToUseUniversalTools() Then
		Return;
	EndIf;
	Command = Commands.Add();
	Command.Kind="UT_UniversalTools";
	Command.ID="UT_ObjectsComparison";
	Command.Presentation=NStr("ru = 'Сравнить объекты';en = 'Compare objects'");
	Command.ParameterType=UT_CommonCached.AllRefsTypeDescription();
	Command.Purpose="ForList";
	Command.ChangesSelectedObjects=False;
	Command.MultipleChoice=True;
	//	Command.Manager = "DataProcessor.UT_ObjectsComparison";
	Command.FormName = "DataProcessor.UT_ObjectsComparison.Form";
	Command.FormParameterName = "ComparedObjects";
	Command.Order=0;

	Command = Commands.Add();
	Command.Kind="UT_UniversalTools";
	Command.ID="UT_AddToComparison";
	Command.Presentation=NStr("ru = 'Добавить к сравнению';en = 'Add to Comparison'");
	Command.ParameterType=UT_CommonCached.AllRefsTypeDescription();
	Command.ChangesSelectedObjects=False;
	Command.MultipleChoice=True;
	Command.Handler = "UT_CommonClient.AddObjectsToComparison";
	Command.Order=1;

	Command = Commands.Add();
	Command.Kind="UT_UniversalTools";
	Command.ID="UT_UploadObjectsToXML";
	Command.Presentation=NStr("ru = 'Выгрузить объекты в XML';en = 'Upload objects to XML'");
	Command.ParameterType=UT_CommonCached.AllRefsTypeDescription();
	Command.ChangesSelectedObjects=False;
	Command.MultipleChoice=True;
	Command.Picture=PictureLib.UT_UploadingResult;
	Command.Handler = "UT_CommonClient.UploadObjectsToXML";
	Command.Order=1;

	Command = Commands.Add();
	Command.Kind="UT_UniversalTools";
	Command.ID="UT_EditObject";
	Command.Presentation=NStr("ru = 'Редактировать объект';en = 'Edit object'");
	Command.ParameterType=UT_CommonCached.AllRefsTypeDescription();
	Command.ChangesSelectedObjects=False;
	Command.MultipleChoice=False;
	Command.Picture=PictureLib.UT_DatabaseObjectEditor;
	Command.Handler = "UT_CommonClient.EditObjectCommandHandler";
	Command.Order=2;
	
	Command = Commands.Add();
	Command.Kind="UT_UniversalTools";
	Command.ID="UT_FindObjectRefs";
	Command.Presentation=NStr("ru = 'Найти ссылки объект';en = 'Find references to object'");
	Command.ParameterType=UT_CommonCached.AllRefsTypeDescription();
	Command.ChangesSelectedObjects=False;
	Command.MultipleChoice=False;
	Command.Picture=PictureLib.SyncContents;
	Command.Handler = "UT_CommonClient.FindObjectRefsCommandHandler";
	Command.Order=3;
	
EndProcedure