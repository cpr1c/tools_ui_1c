&AtClient
Var ВидыНаборовДанных;

&AtClient
Var ВидыПолейНаборовДанных;

#Region СобытияФормы
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ИнициализироватьФорму();

	If Parameters.Property("СКД") Then
		ChoiceMode=True;
		If IsTempStorageURL(Parameters.СКД) Then
			СКД=GetFromTempStorage(Parameters.СКД);
		Else
			Try
				XMLReader = New XMLReader;
				XMLReader.SetString(Parameters.СКД);
				СКД= XDTOSerializer.ReadXML(XMLReader, Type("DataCompositionSchema"));
			Except
				СКД=Undefined;
			EndTry;
		EndIf;

		If СКД <> Undefined Then
			ПрочитатьСКДВДанныеФормы(СКД);
		EndIf;
	EndIf;

	If Not ChoiceMode Then
		ThisForm.CommandBarLocation=FormCommandBarLabelLocation.None;
	EndIf;
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing,
		Items.ГруппаКомандыЧтенияСохраненияСКД);

EndProcedure
&AtClient
Procedure OnOpen(Cancel)
	If IsTempStorageURL(АдресПервоначальнойСхемыКомпоновкиДанных) Then
		ЗаполнитьВспомогательныеДанныеРесурсов();
	EndIf;
EndProcedure
#EndRegion

#Region СобытияЭлементовФормы

&AtClient
Procedure ГруппаЗакладкиРедактораПриСменеСтраницы(Item, CurrentPage)
	If CurrentPage = Items.ГруппаСтраницаСвязиНаборовДанных Then
		ЗаполнитьВспомогательныеДанныеСвязейНаборовДанных();
	ElsIf CurrentPage = Items.ГруппаСтраницаРесурсы Then
		ЗаполнитьВспомогательныеДанныеРесурсов();
	ElsIf CurrentPage = Items.ГруппаСтраницаНастройки Then
		СобратьСКДПоДаннымФормы();
	EndIf;
EndProcedure

#Region DataSets
&AtClient
Procedure НаборыДанныхВыбор(Item, SelectedRow, Field, StandardProcessing)
	If SelectedRow <> ИдентификаторНулевогоНабораДанных Then
		Return;
	EndIf;

	StandardProcessing=False;

	If Items.DataSets.Expanded(SelectedRow) Then
		Items.DataSets.Collapse(SelectedRow);
	Else
		Items.DataSets.Expand(SelectedRow, True);
	EndIf;
EndProcedure

&AtClient
Procedure НаборыДанныхПередУдалением(Item, Cancel)
	If Items.DataSets.CurrentLine = ИдентификаторНулевогоНабораДанных Then
		Cancel=True;
	EndIf;
EndProcedure

&AtClient
Procedure НаборыДанныхПередНачаломИзменения(Item, Cancel)
	If Items.DataSets.CurrentLine = ИдентификаторНулевогоНабораДанных Then
		Cancel=True;
	EndIf;
EndProcedure

&AtClient
Procedure НаборыДанныхПередНачаломДобавления(Item, Cancel, Copy, Parent, IsFolder, Parameter)
	Cancel=True;
EndProcedure

&AtClient
Procedure ПереместитьСтрокуДереваНаборов(ПеремещаемаяСтрока, НовыйРодитель, Level = 0)

	If Level = 0 Then

		NewLine = НовыйРодитель.GetItems().Add();
		FillPropertyValues(NewLine, ПеремещаемаяСтрока, , "Fields");
		For Each СтрокаПоля In ПеремещаемаяСтрока.Fields Do
			НС=NewLine.Fields.Add();
			FillPropertyValues(НС, СтрокаПоля, , "DataCompositionOrderExpressions");

			For Each СтрокаПорядка In СтрокаПоля.DataCompositionOrderExpressions Do
				НП=НС.DataCompositionOrderExpressions.Add();
				FillPropertyValues(НП, СтрокаПорядка);
			EndDo;
		EndDo;

		ПереместитьСтрокуДереваНаборов(ПеремещаемаяСтрока, NewLine, Level + 1);

		If ПеремещаемаяСтрока.GetParent() = Undefined Then
			DataSets.GetItems().Delete(ПеремещаемаяСтрока);
		Else
			ПеремещаемаяСтрока.GetParent().GetItems().Delete(ПеремещаемаяСтрока);
		EndIf;

		Items.DataSets.CurrentLine=NewLine.GetID();
	Else

		For Each Стр In ПеремещаемаяСтрока.GetItems() Do
			NewLine = НовыйРодитель.GetItems().Add();
			FillPropertyValues(NewLine, ПеремещаемаяСтрока, , "Fields");
			For Each СтрокаПоля In ПеремещаемаяСтрока.Fields Do
				НС=NewLine.Fields.Add();
				FillPropertyValues(НС, СтрокаПоля, , "DataCompositionOrderExpressions");

				For Each СтрокаПорядка In СтрокаПоля.DataCompositionOrderExpressions Do
					НП=НС.DataCompositionOrderExpressions.Add();
					FillPropertyValues(НП, СтрокаПорядка);
				EndDo;
			EndDo;

			ПереместитьСтрокуДереваНаборов(Стр, NewLine, Level + 1);
		EndDo;

	EndIf;

EndProcedure

&AtClient
Procedure НаборыДанныхПеретаскивание(Item, DragParameters, StandardProcessing, String, Field)
	StandardProcessing=False;

	If DragParameters.Action <> DragAction.Move Then
		Return;
	EndIf;

	СтрокаНабораКуда=DataSets.FindByID(String);
	СтрокаПеремещения=DataSets.FindByID(DragParameters.Value);
	РодительскийНабор=СтрокаПеремещения.GetParent();
	ПереместитьСтрокуДереваНаборов(СтрокаПеремещения, СтрокаНабораКуда);
	
	If РодительскийНабор.Type = ВидыНаборовДанных.Union Then
		ЗаполнитьПоляНабораДанныхОбъединениеПоПодчиненнымЗапросам(РодительскийНабор.GetID());
	EndIf;
	If СтрокаНабораКуда.Type = ВидыНаборовДанных.Union Then
		ЗаполнитьПоляНабораДанныхОбъединениеПоПодчиненнымЗапросам(СтрокаНабораКуда.GetID());
	EndIf;
	
	
	//Теперь нужно перезаполнить Fields в наборах данных объединение
EndProcedure

&AtClient
Procedure НаборыДанныхПроверкаПеретаскивания(Item, DragParameters, StandardProcessing, String, Field)
	StandardProcessing=False;

	If DragParameters.Value = ИдентификаторНулевогоНабораДанных Then
		DragParameters.Action=DragAction.Cancel;
		Return;
	EndIf;

	СтрокаПеремещения=DataSets.FindByID(DragParameters.Value);
	СтрокаОткуда=СтрокаПеремещения.GetParent();
	If СтрокаОткуда.GetID() = String Then
		DragParameters.Action=DragAction.Cancel;
	EndIf;

	СтрокаКуда=DataSets.FindByID(String);
	If СтрокаКуда.Type <> ВидыНаборовДанных.Root And СтрокаКуда.Type <> ВидыНаборовДанных.Union Then
		DragParameters.Action=DragAction.Cancel;
	EndIf;
EndProcedure
&AtClient
Procedure НаборыДанныхПриАктивизацииСтроки(Item)
	ТекДанныеНабора=Items.DataSets.CurrentData;
	If ТекДанныеНабора = Undefined Then
		Return;
	EndIf;
	If ТекДанныеНабора.Type = ВидыНаборовДанных.Root Then
		Items.ГруппаНаборыДанныхПраваяПанель.CurrentPage=Items.ГруппаНаборыДанныхПраваяПанельИсточникиДанных;
		Return;
	EndIf;

	Items.ГруппаНаборыДанныхПраваяПанель.CurrentPage=Items.ГруппаНаборыДанныхПраваяПанельДанныеНабора;

	ТекДанныеНабора=Items.DataSets.CurrentData;
	Items.ГруппаПанельРедактированияНастроекНабора.Visible=ТекДанныеНабора.Type <> ВидыНаборовДанных.Union;
	If ТекДанныеНабора.Type = ВидыНаборовДанных.Query Then
		Items.ГруппаПанельРедактированияНастроекНабора.CurrentPage=Items.ГруппаСтраницаРедактированияНастроекНабораЗапрос;
	ElsIf ТекДанныеНабора.Type = ВидыНаборовДанных.Object Then
		Items.ГруппаПанельРедактированияНастроекНабора.CurrentPage=Items.ГруппаСтраницаРедактированияНастроекНабораОбъект;
	EndIf;

	Items.ПоляНаборДанныхПроверкиИерархии.ChoiceList.Clear();
	Items.ПоляНаборДанныхПроверкиИерархии.ChoiceList.Add("");

	For Each Set In НаборыДанныхВерхнегоУровня() Do
		If Set.Name = ТекДанныеНабора.Name Then
			Continue;
		EndIf;

		Items.ПоляНаборДанныхПроверкиИерархии.ChoiceList.Add(Set.Name);
	EndDo;

	ЗаполнитьСписокВыбораИсточникаДанныхНабора();
	УстановитьДоступностьКнопокДобавленияПолейНабора();
EndProcedure

&AtClient
Procedure НаборыДанныхПоляПриАктивизацииСтроки(Item)
	УстановитьДоступностьКнопокДобавленияПолейНабора();
EndProcedure

&AtClient
Procedure НаборыДанныхЗапросПриИзменении(Item)
	ЗаполнитьПоляНабораДанныхПриИзмененииЗапроса(Items.DataSets.CurrentLine);
EndProcedure
&AtClient
Procedure НаборыДанныхПоляРольПредставлениеНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	StandardProcessing=False;

	ТекДанные=Items.НаборыДанныхПоля.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	МассивПолейНабора=New Array;
	СтрокаНабора=DataSets.FindByID(Items.DataSets.CurrentLine);
	For Each СтрокаПоля In СтрокаНабора.Fields Do
		If СтрокаПоля.DataPath = ТекДанные.DataPath Then
			Continue;
		EndIf;

		МассивПолейНабора.Add(СтрокаПоля.DataPath);
	EndDo;

	ПараметрыФормы=New Structure;
	ПараметрыФормы.Insert("Role", ТекДанные.Role);
	ПараметрыФормы.Insert("МассивПолейНабора", МассивПолейНабора);
	ПараметрыФормы.Insert("DataPath", ТекДанные.DataPath);

	ПараметрыОповещения=New Structure;
	ПараметрыОповещения.Insert("RowID", Items.НаборыДанныхПоля.CurrentLine);
	ПараметрыОповещения.Insert("ИдентификаторСтрокиНабора", Items.DataSets.CurrentLine);

	OpenForm("DataProcessor.UT_DCSEditor.Form.FormEditDataSetFieldRole", ПараметрыФормы, ThisObject, ,
		, , New NotifyDescription("НаборыДанныхПоляРольПредставлениеНачалоВыбораЗавершение", ThisObject,
		ПараметрыОповещения), FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure ПоляДоступныеЗначенияНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	ТекДанные=Items.НаборыДанныхПоля.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	StandardProcessing=False;

	ДопПараметры=New Structure;
	ДопПараметры.Insert("RowID", ТекДанные.GetID());
	ДопПараметры.Insert("ИдентификаторСтрокиНабора", Items.DataSets.CurrentLine);

	UT_CommonClient.OpenValueListChoiceItemsForm(ТекДанные.AvailableValues,
		New NotifyDescription("ПоляДоступныеЗначенияНачалоВыбораЗавершение", ThisObject, ДопПараметры),
		"Edit списка значений", ТекДанные.ValueType, False, True, True, False,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure НаборыДанныхПоляПриНачалеРедактирования(Item, NewLine, Copy)
	If Not Copy Then
		Return;
	EndIf;

	ТекСтрока=Items.НаборыДанныхПоля.CurrentData;
	If ТекСтрока = Undefined Then
		Return;
	EndIf;

	ТекСтрокаНабора=Items.DataSets.CurrentData;

	ЧислоВКонце=UT_StringFunctionsClientServer.NumberAtStringEnd(ТекСтрока.DataPath);

	If ЧислоВКонце = Undefined Then
		ТекСтрока.DataPath=ТекСтрока.DataPath + ТекСтрока.GetID();
	Else
		Suffix=Format(ЧислоВКонце, "ЧГ=0;");
		НовыйПутьКДанным=ТекСтрока.DataPath;
		UT_StringFunctionsClientServer.DeleteLastCharInString(НовыйПутьКДанным, StrLen(Suffix));

		DataPath=НовыйПутьКДанным + Format(ЧислоВКонце + 1, "ЧГ=0;");
		СтруктураПоиска=New Structure;
		СтруктураПоиска.Insert("DataPath", DataPath);

		НайденныеСтроки=ТекСтрокаНабора.Fields.FindRows(СтруктураПоиска);
		While НайденныеСтроки.Count() > 0 Do
			ЧислоВКонце=ЧислоВКонце + 1;
			DataPath=НовыйПутьКДанным + Format(ЧислоВКонце + 1, "ЧГ=0;");

			СтруктураПоиска=New Structure;
			СтруктураПоиска.Insert("DataPath", DataPath);
			НайденныеСтроки=ТекСтрокаНабора.Fields.FindRows(СтруктураПоиска);

		EndDo;

		ТекСтрока.DataPath=DataPath;
	EndIf;

	ТекСтрока.Title=UT_StringFunctionsClientServer.IdentifierPresentation(ТекСтрока.DataPath);
	If ТекСтрока.Type <> ВидыПолейНаборовДанных.Folder Then
		ТекСтрока.Field=ТекСтрока.DataPath;
	EndIf;

	УстановитьДоступностьКнопокДобавленияПолейНабора();
EndProcedure

&AtClient
Procedure НаборыДанныхАвтоЗаполнениеДоступныхПолейПриИзменении(Item)
	УстановитьДоступностьКнопокДобавленияПолейНабора();
	ЗаполнитьПоляНабораДанныхПриИзмененииЗапросаНаСервере(Items.DataSets.CurrentLine);
EndProcedure
&AtClient
Procedure НаборыДанныхПоляПередНачаломДобавления(Item, Cancel, Copy, Parent, IsFolder, Parameter)
	If Not Copy Then
		Cancel=True;
	Else
		Cancel=Not ДоступноКопированиеУдаленияПоляНабора(Items.DataSets.CurrentData,
			Items.НаборыДанныхПоля.CurrentData);
	EndIf;
EndProcedure

&AtClient
Procedure НаборыДанныхПоляПередУдалением(Item, Cancel)
	Cancel=Not ДоступноКопированиеУдаленияПоляНабора(Items.DataSets.CurrentData,
		Items.НаборыДанныхПоля.CurrentData);
EndProcedure

&AtClient
Procedure ПоляПутьКДаннымПриИзменении(Item)
	ТекДанные=Items.НаборыДанныхПоля.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;
	ТекДанные.Title=UT_StringFunctionsClientServer.IdentifierPresentation(ТекДанные.DataPath);
EndProcedure

&AtClient
Procedure НаборыДанныхПоляПриОкончанииРедактирования(Item, NewLine, ОтменаРедактирования)
	If ОтменаРедактирования Then
		Return;
	EndIf;
	
	СтрокаНабора=Items.DataSets.CurrentLine;
	ДанныеСтрокиНабора=DataSets.FindByID(СтрокаНабора);
	РодительСтрокиНабора=ДанныеСтрокиНабора.GetParent();
	If РодительСтрокиНабора.Type=ВидыНаборовДанных.Union Then
		ЗаполнитьПоляНабораДанныхОбъединениеПоПодчиненнымЗапросам(РодительСтрокиНабора.GetID());
	EndIf;
EndProcedure

&AtClient
Procedure ПоляТипЗначенияНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	ТекДанные=Items.НаборыДанныхПоля.CurrentData;
	If ТекДанные=Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditType(ТекДанные.ValueType, 2,StandardProcessing,ThisObject, New NotifyDescription("ПоляТипЗначенияНачалоВыбораЗавершение",ThisObject, New Structure("ТекСтрока",Items.НаборыДанныхПоля.CurrentLine)));
EndProcedure


#EndRegion

#Region DataSetLinks

&AtClient
Procedure СвязиНаборовДанныхНаборДанныхИсточникПриИзменении(Item)
	ТекДанные=Items.DataSetLinks.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ЗаполнитьСписокВыбораПоляСвязиНаборов(ТекДанные.SourceDataSet, Items.СвязиНаборовДанныхВыражениеИсточник);
EndProcedure

&AtClient
Procedure СвязиНаборовДанныхНаборДанныхПриемникПриИзменении(Item)
	ТекДанные=Items.DataSetLinks.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ЗаполнитьСписокВыбораПоляСвязиНаборов(ТекДанные.DestinationDataSet, Items.СвязиНаборовДанныхВыражениеПриемник);
EndProcedure

&AtClient
Procedure СвязиНаборовДанныхПередНачаломИзменения(Item, Cancel)
	ТекДанные=Items.DataSetLinks.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ЗаполнитьСписокВыбораПоляСвязиНаборов(ТекДанные.SourceDataSet, Items.СвязиНаборовДанныхВыражениеИсточник);
	ЗаполнитьСписокВыбораПоляСвязиНаборов(ТекДанные.DestinationDataSet, Items.СвязиНаборовДанныхВыражениеПриемник);

EndProcedure
#EndRegion

#Region Resources
&AtClient
Procedure ДоступныеПоляРесурсовВыбор(Item, SelectedRow, Field, StandardProcessing)
	StandardProcessing=False;

	ДобавитьРесурс(SelectedRow);
EndProcedure

&AtClient
Procedure РесурсыПередНачаломИзменения(Item, Cancel)
	ЗаполнитьСписокВыбораВыраженияРесурса(Item.CurrentLine);
EndProcedure

&AtClient
Procedure РесурсыВыражениеОткрытие(Item, StandardProcessing)
	StandardProcessing=False;
	ТекДанные=Items.Resources.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ДопПараметры=New Structure;
	ДопПараметры.Insert("RowID", Items.Resources.CurrentLine);

	UT_CommonClient.OpenTextEditingForm(ТекДанные.Expression,
		New NotifyDescription("РесурсыВыражениеОткрытиеЗавершение", ThisObject, ДопПараметры),
		"Edit выражения ресурса для " + ТекДанные.DataPath);
EndProcedure

&AtClient
Procedure РесурсыГруппировкиНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	StandardProcessing=False;
	ТекДанные=Items.Resources.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	СписокДоступныхГруппировок=New ValueList;
	For Each Стр In ResourceAvailableField Do
		Check= ТекДанные.Groups.FindByValue(Стр.DataPath) <> Undefined;
		СписокДоступныхГруппировок.Add(Стр.DataPath, , Check);
	EndDo;

	Check= ТекДанные.Groups.FindByValue("Overall") <> Undefined;

	СписокДоступныхГруппировок.Add("Overall", "Общий итог", Check);

	ДопПараметры=New Structure;
	ДопПараметры.Insert("RowID", Items.Resources.CurrentLine);

	UT_CommonClient.OpenValueListChoiceItemsForm(СписокДоступныхГруппировок,
		New NotifyDescription("РесурсыГруппировкиНачалоВыбораЗавершение", ThisObject, ДопПараметры),
		"Fields Groups", , True, False, False, , FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

#EndRegion

#Region CalculatedFields
&AtClient
Procedure ВычисляемыеПоляПриОкончанииРедактирования(Item, NewLine, ОтменаРедактирования)
	ЗаполнитьВспомогательныеДанныеРесурсов();
EndProcedure

&AtClient
Procedure ВычисляемыеПоляПослеУдаления(Item)
	ЗаполнитьВспомогательныеДанныеРесурсов();
EndProcedure
&AtClient
Procedure ВычисляемыеПоляПриНачалеРедактирования(Item, NewLine, Copy)
	ТекДанные=Items.CalculatedFields.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	If NewLine Then
		ТекДанные.DataPath="Field" + ТекДанные.GetID();
		ТекДанные.Title=ТекДанные.DataPath;
	EndIf;
EndProcedure
&AtClient
Procedure ВычисляемыеПоляВыражениеОткрытие(Item, StandardProcessing)
	StandardProcessing=False;
	ТекДанные=Items.CalculatedFields.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ДопПараметры=New Structure;
	ДопПараметры.Insert("RowID", Items.CalculatedFields.CurrentLine);

	UT_CommonClient.OpenTextEditingForm(ТекДанные.Expression,
		New NotifyDescription("ВычисляемыеПоляВыражениеЗавершение", ThisObject, ДопПараметры),
		"Edit выражения ресурса для " + ТекДанные.DataPath);
EndProcedure
&AtClient
Procedure ВычисляемыеПоляДоступныеЗначенияНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	ТекДанные=Items.CalculatedFields.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	StandardProcessing=False;

	ДопПараметры=New Structure;
	ДопПараметры.Insert("RowID", ТекДанные.GetID());

	UT_CommonClient.OpenValueListChoiceItemsForm(ТекДанные.AvailableValues,
		New NotifyDescription("ВычисляемыеПоляДоступныеЗначенияНачалоВыбораЗавершение", ThisObject, ДопПараметры),
		"Edit списка значений", ТекДанные.ValueType, False, True, True, False,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure ВычисляемыеПоляПутьКДаннымПриИзменении(Item)
	ТекДанные=Items.CalculatedFields.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ТекДанные.Title=UT_StringFunctionsClientServer.IdentifierPresentation(ТекДанные.DataPath);
EndProcedure

&AtClient
Procedure ВычисляемыеПоляТипЗначенияНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	ТекДанные=Items.CalculatedFields.CurrentData;
	If ТекДанные=Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditType(ТекДанные.ValueType, 2,StandardProcessing,ThisObject, New NotifyDescription("ВычисляемыеПоляТипЗначенияНачалоВыбораЗавершение",ThisObject, New Structure("ТекСтрока",Items.CalculatedFields.CurrentLine)));
EndProcedure


#EndRegion

#Region Parameters

&AtClient
Procedure ПараметрыСКДПриНачалеРедактирования(Item, NewLine, Copy)
	ТекДанные=Items.DCSParameters.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	If NewLine Then
		ТекДанные.Name="Parameter" + ТекДанные.GetID();
		ТекДанные.Title=ТекДанные.Name;
		ТекДанные.IncludeInAvailableFields=True;
		ТекДанные.ДобавленАвтоматически=False;
	EndIf;

	УстановитьСписокВыбораПоляЗначенияПараметра(ТекДанные);
	УстановитьОграничениеТипаПоляЗначенияПараметра(ТекДанные);
EndProcedure

&AtClient
Procedure ПараметрыСКДТипЗначенияПриИзменении(Item)
	ТекДанные=Items.DCSParameters.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	If ТекДанные.ValueListAllowed Then
		НовоеЗначение=New ValueList;

		For Each ЭлементСписка In ТекДанные.Value Do
			If ТекДанные.ValueType.ContainsType(TypeOf(ЭлементСписка.Value)) Then
				НовоеЗначение.Add(ЭлементСписка.Value);
			EndIf;
		EndDo;
		ТекДанные.Value=НовоеЗначение;
	Else
		ТекДанные.Value=ТекДанные.ValueType.AdjustValue(ТекДанные.Value);
	EndIf;

	УстановитьОграничениеТипаПоляЗначенияПараметра(ТекДанные);
EndProcedure

&AtClient
Procedure ПараметрыСКДДоступныеЗначенияНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	StandardProcessing=False;

	ТекДанные=Items.DCSParameters.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	If ТекДанные.ValueType = New TypeDescription Then
		Return;
	EndIf;

	ДопПараметры=New Structure;
	ДопПараметры.Insert("RowID", ТекДанные.GetID());

	UT_CommonClient.OpenValueListChoiceItemsForm(ТекДанные.AvailableValues,
		New NotifyDescription("ПараметрыСКДДоступныеЗначенияНачалоВыбораЗавершение", ThisObject, ДопПараметры),
		"Edit списка значений", ТекДанные.ValueType, False, True, True, False,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

&AtClient
Procedure ПараметрыСКДЗначениеНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	ТекДанные=Items.DCSParameters.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	If ТекДанные.ValueType = New TypeDescription Then
		Return;
	EndIf;

	If Not ТекДанные.ValueListAllowed Then
		Return;
	EndIf;

	StandardProcessing=False;

	ДопПараметры=New Structure;
	ДопПараметры.Insert("RowID", ТекДанные.GetID());

	AvailableValues=Undefined;
	If ТекДанные.AvailableValues.Count() > 0 Then
		AvailableValues=ТекДанные.AvailableValues;
	EndIf;

	UT_CommonClient.OpenValueListChoiceItemsForm(ТекДанные.Value,
		New NotifyDescription("ПараметрыСКДЗначениеНачалоВыбораЗавершение", ThisObject, ДопПараметры),
		"Edit списка значений", ТекДанные.ValueType, False, False, True, False,
		FormWindowOpeningMode.LockOwnerWindow, AvailableValues);

EndProcedure
&AtClient
Procedure ПараметрыСКДДоступенСписокЗначенийПриИзменении(Item)
	ТекДанные=Items.DCSParameters.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	If ТекДанные.ValueListAllowed Then
		НовоеЗначение=New ValueList;
		НовоеЗначение.Add(ТекДанные.Value);
	Else
		If ТекДанные.Value.Count() = 0 Then
			НовоеЗначение=Undefined;
		Else
			НовоеЗначение=ТекДанные.Value[0].Value;
		EndIf;
	EndIf;

	ТекДанные.Value=НовоеЗначение;

	УстановитьОграничениеТипаПоляЗначенияПараметра(ТекДанные);
EndProcedure
&AtClient
Procedure ПараметрыСКДВыражениеОткрытие(Item, StandardProcessing)
	StandardProcessing=False;
	ТекДанные=Items.DCSParameters.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ДопПараметры=New Structure;
	ДопПараметры.Insert("RowID", Items.DCSParameters.CurrentLine);

	UT_CommonClient.OpenTextEditingForm(ТекДанные.Expression,
		New NotifyDescription("ПараметрыСКДВыражениеОткрытиеЗавершение", ThisObject, ДопПараметры),
		"Edit выражения для " + ТекДанные.Name);
EndProcedure

&AtClient
Procedure ПараметрыСКДИмяПриИзменении(Item)
	ТекДанные=Items.DCSParameters.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ТекДанные.Title=UT_StringFunctionsClientServer.IdentifierPresentation(ТекДанные.Name);
EndProcedure

&AtClient
Procedure ПараметрыСКДПередУдалением(Item, Cancel)
	ТекДанные=Items.DCSParameters.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	Cancel=ТекДанные.ДобавленАвтоматически;
EndProcedure

&AtClient
Procedure ПараметрыСКДТипЗначенияНачалоВыбора(Item, ДанныеВыбора, StandardProcessing)
	ТекДанные=Items.DCSParameters.CurrentData;
	If ТекДанные=Undefined Then
		Return;
	EndIf;
	
	UT_CommonClient.EditType(ТекДанные.ValueType, 3,StandardProcessing,ThisObject, New NotifyDescription("ПараметрыСКДТипЗначенияНачалоВыбораЗавершение",ThisObject, New Structure("ТекСтрока",Items.DCSParameters.CurrentLine)));
EndProcedure
#EndRegion

#Region ТекущиеНастройкиВарианта

&AtClient
Procedure КомпоновщикНастроекНастройкиПриАктивизацииПоля(Item)

	Var ВыбраннаяСтраница;

	If Items.КомпоновщикНастроекНастройки.CurrentItem.Name = "КомпоновщикНастроекНастройкиНаличиеВыбора" Then

		ВыбраннаяСтраница = Items.СтраницаПолейВыбора;

	ElsIf Items.КомпоновщикНастроекНастройки.CurrentItem.Name = "КомпоновщикНастроекНастройкиНаличиеОтбора" Then

		ВыбраннаяСтраница = Items.СтраницаОтбора;

	ElsIf Items.КомпоновщикНастроекНастройки.CurrentItem.Name = "КомпоновщикНастроекНастройкиНаличиеПорядка" Then

		ВыбраннаяСтраница = Items.СтраницаПорядка;

	ElsIf Items.КомпоновщикНастроекНастройки.CurrentItem.Name
		= "КомпоновщикНастроекНастройкиНаличиеУсловногоОформления" Then

		ВыбраннаяСтраница = Items.СтраницаУсловногоОформления;

	ElsIf Items.КомпоновщикНастроекНастройки.CurrentItem.Name
		= "КомпоновщикНастроекНастройкиНаличиеПараметровВывода" Then

		ВыбраннаяСтраница = Items.СтраницаПараметровВывода;

	EndIf;

	If ВыбраннаяСтраница <> Undefined Then

		Items.СтраницыНастроек.CurrentPage = ВыбраннаяСтраница;

	EndIf;

EndProcedure

&AtClient
Procedure КомпоновщикНастроекНастройкиПриАктивизацииСтроки(Item)

	ЭлементСтруктуры = CurrentSettingsComposer.Settings.GetObjectByID(
		Items.КомпоновщикНастроекНастройки.CurrentLine);
	ItemType = TypeOf(ЭлементСтруктуры);

	If ItemType = Undefined Or ItemType = Type("DataCompositionChartStructureItemCollection")
		Or ItemType = Type("DataCompositionTableStructureItemCollection") Then

		GroupFieldsNotAvailable();
		SelectedFieldsUnavailable();
		FilterUnavailable();
		OrderUnavailable();
		ConditionalAppearanceUnavailable();
		OutputParametersUnavailable();

	ElsIf ItemType = Type("DataCompositionSettings") Or ItemType = Type(
		"DataCompositionNestedObjectSettings") Then

		GroupFieldsNotAvailable();

		LocalSelectedFields = True;
		Items.LocalSelectedFields.ReadOnly = True;
		Items.СтраницыПолейВыбора.CurrentPage = Items.НастройкиВыбранныхПолей;

		LocalFilter = True;
		Items.LocalFilter.ReadOnly = True;
		Items.СтраницыОтбора.CurrentPage = Items.НастройкиОтбора;

		LocalOrder = True;
		Items.LocalOrder.ReadOnly = True;
		Items.СтраницыПорядка.CurrentPage = Items.НастройкиПорядка;

		LocalConditionalAppearance = True;
		Items.LocalConditionalAppearance.ReadOnly = True;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.НастройкиУсловногоОформления;

		LocalOutputParameters = True;
		Items.LocalOutputParameters.ReadOnly = True;
		Items.СтраницыПараметровВывода.CurrentPage = Items.НастройкиПараметровВывода;

	ElsIf ItemType = Type("DataCompositionGroup") Or ItemType = Type(
		"DataCompositionTableGroup") Or ItemType = Type("DataCompositionChartGroup") Then

		Items.СтраницыПолейГруппировки.CurrentPage = Items.НастройкиПолейГруппировки;

		SelectedFieldsAvailable(ЭлементСтруктуры);
		FilterAvailable(ЭлементСтруктуры);
		OrderAvailable(ЭлементСтруктуры);
		ConditionalAppearanceAvailable(ЭлементСтруктуры);
		OutputParametersAvailable(ЭлементСтруктуры);

	ElsIf ItemType = Type("DataCompositionTable") Or ItemType = Type("DataCompositionChart") Then

		GroupFieldsNotAvailable();
		SelectedFieldsAvailable(ЭлементСтруктуры);
		FilterUnavailable();
		OrderUnavailable();
		ConditionalAppearanceAvailable(ЭлементСтруктуры);
		OutputParametersAvailable(ЭлементСтруктуры);

	EndIf;

EndProcedure

&AtClient
Procedure GoToReport(Item)

	ЭлементСтруктуры = CurrentSettingsComposer.Settings.GetObjectByID(
		Items.КомпоновщикНастроекНастройки.CurrentLine);
	ItemSettings =  CurrentSettingsComposer.Settings.ItemSettings(ЭлементСтруктуры);
	Items.КомпоновщикНастроекНастройки.CurrentLine = CurrentSettingsComposer.Settings.GetIDByObject(
		ItemSettings);

EndProcedure

&AtClient
Procedure ЛокальныеВыбранныеПоляПриИзменении(Item)

	If LocalSelectedFields Then

		Items.СтраницыПолейВыбора.CurrentPage = Items.НастройкиВыбранныхПолей;

	Else

		Items.СтраницыПолейВыбора.CurrentPage = Items.ОтключенныеНастройкиВыбранныхПолей;

		ЭлементСтруктуры = CurrentSettingsComposer.Settings.GetObjectByID(
			Items.КомпоновщикНастроекНастройки.CurrentLine);
		CurrentSettingsComposer.Settings.ClearItemSelection(ЭлементСтруктуры);

	EndIf;

EndProcedure

&AtClient
Procedure ЛокальныйОтборПриИзменении(Item)

	If LocalFilter Then

		Items.СтраницыОтбора.CurrentPage = Items.НастройкиОтбора;

	Else

		Items.СтраницыОтбора.CurrentPage = Items.ОтключенныеНастройкиОтбора;

		ЭлементСтруктуры = CurrentSettingsComposer.Settings.GetObjectByID(
			Items.КомпоновщикНастроекНастройки.CurrentLine);
		CurrentSettingsComposer.Settings.ClearItemFilter(ЭлементСтруктуры);

	EndIf;

EndProcedure

&AtClient
Procedure ЛокальныйПорядокПриИзменении(Item)

	If LocalOrder Then

		Items.СтраницыПорядка.CurrentPage = Items.НастройкиПорядка;

	Else

		Items.СтраницыПорядка.CurrentPage = Items.ОтключенныеНастройкиПорядка;

		ЭлементСтруктуры = CurrentSettingsComposer.Settings.GetObjectByID(
			Items.КомпоновщикНастроекНастройки.CurrentLine);
		CurrentSettingsComposer.Settings.ClearItemOrder(ЭлементСтруктуры);

	EndIf;

EndProcedure

&AtClient
Procedure ЛокальноеУсловноеОформлениеПриИзменении(Item)

	If LocalConditionalAppearance Then

		Items.СтраницыУсловногоОформления.CurrentPage = Items.НастройкиУсловногоОформления;

	Else

		Items.СтраницыУсловногоОформления.CurrentPage = Items.ОтключенныеНастройкиУсловногоОформления;

		ЭлементСтруктуры = CurrentSettingsComposer.Settings.GetObjectByID(
			Items.КомпоновщикНастроекНастройки.CurrentLine);
		CurrentSettingsComposer.Settings.ClearItemConditionalAppearance(ЭлементСтруктуры);

	EndIf;

EndProcedure

&AtClient
Procedure ЛокальныеПараметрыВыводаПриИзменении(Item)

	If LocalOutputParameters Then

		Items.СтраницыПараметровВывода.CurrentPage = Items.НастройкиПараметровВывода;

	Else

		Items.СтраницыПараметровВывода.CurrentPage = Items.ОтключенныеНастройкиПараметровВывода;

		ЭлементСтруктуры = CurrentSettingsComposer.Settings.GetObjectByID(
			Items.КомпоновщикНастроекНастройки.CurrentLine);
		CurrentSettingsComposer.Settings.ClearItemOutputParameters(ЭлементСтруктуры);
	EndIf;

EndProcedure
#EndRegion

#Region SettingVariants

&AtClient
Procedure ВариантыНастроекПриАктивизацииСтроки(Item)
	ВариантыНастроекПриАктивизацииСтрокиНаСервере(Items.SettingVariants.CurrentLine);
EndProcedure

&AtClient
Procedure ВариантыНастроекПередУдалением(Item, Cancel)
	If SettingVariants.Count() = 1 Then
		Cancel=True;
	EndIf;
EndProcedure

&AtClient
Procedure ВариантыНастроекПриНачалеРедактирования(Item, NewLine, Copy)

	If Not NewLine Then
		Return;
	EndIf;
	ТекДанные=Items.SettingVariants.CurrentData;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ТекДанные.Name="Variant" + ТекДанные.GetID();
	ТекДанные.Presentation=ТекДанные.Name;
EndProcedure

#EndRegion

#EndRegion

#Region CommandFormEventHandlers

&AtClient
Procedure AddDataSetQuery(Command)
	ДобавитьНаборДанных(ВидыНаборовДанных.Query);
EndProcedure

&AtClient
Procedure ДобавитьНаборДанныхОбъект(Command)
	ДобавитьНаборДанных(ВидыНаборовДанных.Object);
EndProcedure

&AtClient
Procedure ДобавитьНаборДанныхОбъединение(Command)
	ДобавитьНаборДанных(ВидыНаборовДанных.Union);
EndProcedure

&AtClient
Procedure УдалитьНаборДанных(Command)
	ИдентификаторТекущейСтроки=Items.DataSets.CurrentLine;
	If ИдентификаторТекущейСтроки = ИдентификаторНулевогоНабораДанных Then
		Return;
	EndIf;

	СтрокаНабораДанных=DataSets.FindByID(ИдентификаторТекущейСтроки);

	ИмяНабораДанных=СтрокаНабораДанных.Name;

	СтрокаРодитель=СтрокаНабораДанных.GetParent();
	СтрокаРодитель.GetItems().Delete(СтрокаНабораДанных);
	
	//Удалим связи этого набора
	МассивКУдалению=New Array;
	For Each Стр In DataSetLinks Do
		If Lower(Стр.SourceDataSet) = Lower(ИмяНабораДанных) Or Lower(Стр.DestinationDataSet) = Lower(
			ИмяНабораДанных) Then

			МассивКУдалению.Add(Стр);
		EndIf;

	EndDo;

	For Each Стр In МассивКУдалению Do
		DataSetLinks.Delete(Стр);
	EndDo;

EndProcedure

&AtClient
Procedure OpenQueryWizard(Command)
	ТекНабор=Items.DataSets.CurrentData;
	If ТекНабор = Undefined Then
		Return;
	EndIf;

	Конструктор=New QueryWizard;
	If UT_CommonClientServer.PlatformVersionNotLess_8_3_14() Then
		Конструктор.DataCompositionMode=True;
	EndIf;

	If ValueIsFilled(TrimAll(ТекНабор.Query)) Then
		Конструктор.Text=ТекНабор.Query;
	EndIf;

	ДопПараметрыОповещения=New Structure;
	ДопПараметрыОповещения.Insert("ТекСтрока", Items.DataSets.CurrentLine);

	Конструктор.Show(New NotifyDescription("ОткрытьКонструкторЗапросаЗавершение", ThisObject,
		ДопПараметрыОповещения));
EndProcedure

&AtClient
Procedure ДобавитьРесурсИзДоступных(Command)
	ТекДанные=Items.ResourceAvailableField.CurrentLine;
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	ДобавитьРесурс(ТекДанные);
EndProcedure

&AtClient
Procedure ДобавитьЧисловыеРесурсыИзДоступных(Command)
	For Each Стр In ResourceAvailableField Do
		If Not Стр.ВычисляемоеПоле And Not Стр.Числовое Then
			Continue;
		EndIf;

		ДобавитьРесурс(Стр);
	EndDo;
EndProcedure

&AtClient
Procedure УдалитьРесурс(Command)
	ТекСтрокаРесурсов=Items.Resources.CurrentLine;
	If ТекСтрокаРесурсов = Undefined Then
		Return;
	EndIf;

	Resources.Delete(Resources.FindByID(ТекСтрокаРесурсов));
EndProcedure

&AtClient
Procedure УдалитьВсеРесурсы(Command)
	Resources.Clear();
EndProcedure

&AtClient
Procedure СохранитьСхемуВФайл(Command)
	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("СохранитьСхемуВФайлЗавершение", ThisObject));
EndProcedure
&AtClient
Procedure ПрочитатьСхемуИзФайла(Command)
	UT_CommonClient.AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("ПрочитатьСхемуИзФайлаЗавершение", ThisObject));
EndProcedure

&AtClient
Procedure ЗавершитьРедактирование(Command)
	СобратьСКДПоДаннымФормы(True);

	Close(АдресСхемыКомпоновкиДанных);
EndProcedure

&AtClient
Procedure ДобавитьПолеНабораПапка(Command)
	ВручнуюДобавитьПолеНабораДанных(ВидыПолейНаборовДанных.Folder);
EndProcedure

&AtClient
Procedure ДобавитьПолеНабораПоле(Command)
	ВручнуюДобавитьПолеНабораДанных(ВидыПолейНаборовДанных.Field);
EndProcedure

&AtClient
Procedure ДобавитьПолеНабораНабор(Command)
	ВручнуюДобавитьПолеНабораДанных(ВидыПолейНаборовДанных.Set);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure



#EndRegion

#Region Private

#Region ЧтениеСохранениеВФайл
&AtClient
Procedure СохранитьСхемуВФайлЗавершение(Result, AdditionalParameters) Export
	ДВФ=New FileDialog(FileDialogMode.Save);
	ДВФ.Extension="xml";
	ДВФ.Filter="File XML(*.xml)|*.xml";
	ДВФ.Multiselect=False;
	ДВФ.Show(New NotifyDescription("СохранитьСхемуВФайлЗавершениеВыбораИмениФайла", ThisObject));
EndProcedure

&AtClient
Procedure СохранитьСхемуВФайлЗавершениеВыбораИмениФайла(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles = Undefined Then
		Return;
	EndIf;

	If SelectedFiles.Count() = 0 Then
		Return;
	EndIf;

	АдресТекста=ПодготовитьСКДДляСохраненияВФайл();

	Text=New TextDocument;
	Text.SetText(GetFromTempStorage(АдресТекста));
	Text.BeginWriting( , SelectedFiles[0], "utf-8");
EndProcedure

&AtServer
Function ПодготовитьСКДДляСохраненияВФайл()
	СохранитьВТаблицуФормыНастройкуТекущегоВариантаНастроек();
	СобратьСКДПоДаннымФормы(True);

	DCSText=UT_Common.ValueToXMLString(GetFromTempStorage(АдресСхемыКомпоновкиДанных));

	Return PutToTempStorage(DCSText, UUID);
EndFunction

&AtClient
Procedure ПрочитатьСхемуИзФайлаЗавершение(Result, AdditionalParameters) Export
	ДВФ=New FileDialog(FileDialogMode.Opening);
	ДВФ.Extension="xml";
	ДВФ.Filter="File XML(*.xml)|*.xml";
	ДВФ.Multiselect=False;

	BeginPutFile(New NotifyDescription("ПрочитатьСхемуИзФайлаЗавершениеПомещенияФайла", ThisObject), , ДВФ,
		True, UUID);
EndProcedure

&AtClient
Procedure ПрочитатьСхемуИзФайлаЗавершениеПомещенияФайла(Result, Address, ВыбранноеИмяФайла, AdditionalParameters) Export
	If Not Result Then
		Return;
	EndIf;

	ПрочитатьСхемуИзФайлаНаСервере(Address);
	ЗаполнитьВспомогательныеДанныеРесурсов();
EndProcedure

&AtServer
Procedure ПрочитатьСхемуИзФайлаНаСервере(АдресФайла)

	ДД=GetFromTempStorage(АдресФайла);

	Text=New TextDocument;
	Text.Read(ДД.OpenStreamForRead());

	Try
		СКД=UT_Common.ValueFromXMLString(Text.GetText());
	Except
		Message(StrTemplate("Not удалось прочитать СКД из файла: %1", ErrorDescription()));
		Return;
	EndTry;

	ПрочитатьСКДВДанныеФормы(СКД);
EndProcedure

#EndRegion

#Region DataSets
&AtClient
Function НаборДанныхПоИмени(ИмяНабора, СтрокаНаборов = Undefined)
	If СтрокаНаборов = Undefined Then
		СтрокаПоискаНаборов=DataSets.FindByID(ИдентификаторНулевогоНабораДанных);
	Else
		СтрокаПоискаНаборов=СтрокаНаборов;
	EndIf;

	НайденныйНабор=Undefined;
	For Each Стр In СтрокаПоискаНаборов.GetItems() Do
		If Lower(Стр.Name) = Lower(ИмяНабора) Then
			НайденныйНабор=Стр;
			Break;
		EndIf;
	EndDo;

	Return НайденныйНабор;
EndFunction

&AtClient
Procedure ЗаполнитьПоляНабораДанныхПриИзмененииЗапроса(ИдентификаторСтрокиНабора)
	ЗаполнитьПоляНабораДанныхПриИзмененииЗапросаНаСервере(ИдентификаторСтрокиНабора);
	ЗаполнитьПараметрыСКДПриИзмененииЗапросаНабора(ИдентификаторСтрокиНабора);
	ЗаполнитьВспомогательныеДанныеРесурсов();
EndProcedure

&AtServer
Procedure ЗаполнитьПараметрыСКДПриИзмененииЗапросаНабора(ИдентификаторСтрокиНабора)
	СтрокаНабора=DataSets.FindByID(ИдентификаторСтрокиНабора);

	If Not ValueIsFilled(СтрокаНабора.Query) Then
		Return;
	EndIf;

	Query=New Query;
	Query.Text=СтрокаНабора.Query;
	QueryOptions=Query.FindParameters();

	For Each ОписаниеПараметра In QueryOptions Do
		СтруктураПоиска=New Structure;
		СтруктураПоиска.Insert("Name", ОписаниеПараметра.Name);

		НайденныеСтрокиПараметров=DCSParameters.FindRows(СтруктураПоиска);
		If НайденныеСтрокиПараметров.Count() = 0 Then
			СтрокаПараметра=DCSParameters.Add();
			СтрокаПараметра.Name=ОписаниеПараметра.Name;
			СтрокаПараметра.Title=ОписаниеПараметра.Name;
			СтрокаПараметра.ValueType=ОписаниеПараметра.ValueType;
			СтрокаПараметра.IncludeInAvailableFields=True;
		Else
			СтрокаПараметра=НайденныеСтрокиПараметров[0];
		EndIf;
		СтрокаПараметра.ДобавленАвтоматически=True;
	EndDo;
EndProcedure
&AtServer
Procedure ДобавитьПолеНабора(СтрокаНабора, Column, ВидыПолейНаборовДанных, МассивПолей, КолонкаРодитель = Undefined)
	ОграничениеПоле=False;
	ОграничениеУсловие=False;
	ОграничениеГруппа=False;
	ОграничениеПорядок=False;
	ЗаполнятьОграничение=False;
	If TypeOf(Column) = Type("QuerySchemaNestedTableColumn") Then
		Type=ВидыПолейНаборовДанных.Set;
		ColumnName=Column.Alias;
	ElsIf TypeOf(Column) = Type("QuerySchemaColumn") Then
		Type=ВидыПолейНаборовДанных.Field;
		ColumnName=Column.Alias;
	ElsIf TypeOf(Column) = Type("CustomField") Then
		If Column.ValueType = New TypeDescription("ValueTable") Then
			Type=ВидыПолейНаборовДанных.Set;
			ColumnName=Column.Name;
		Else
			Type=ВидыПолейНаборовДанных.Field;
			ColumnName=Column.Name;
		EndIf;
		ЗаполнятьОграничение=True;

		ОграничениеПоле=Not Column.Field;
		ОграничениеУсловие=Not Column.Filter;
		ОграничениеГруппа=Not Column.Dimension;
		ОграничениеПорядок=Not Column.Order;
	EndIf;

	If КолонкаРодитель = Undefined Then
		Field=ColumnName;
	Else
		Field=КолонкаРодитель.Alias + "." + ColumnName;
	EndIf;

	СтруктураПоиска=New Structure;
	СтруктураПоиска.Insert("Field", Field);

	МассивСтрок=СтрокаНабора.Fields.FindRows(СтруктураПоиска);
	If МассивСтрок.Count() = 0 Then
		НовоеПоле=СтрокаНабора.Fields.Add();
		НовоеПоле.Field=Field;
		НовоеПоле.DataPath=Field;
	Else
		НовоеПоле=МассивСтрок[0];
	EndIf;
	НовоеПоле.Type=Type;
	НовоеПоле.Picture=КартинкаВидаПоляНабораДанных(НовоеПоле.Type, ВидыПолейНаборовДанных);

	If TypeOf(Column) = Type("QuerySchemaNestedTableColumn") Then
		For Each ТекКолонка In Column.Cols Do
			ДобавитьПолеНабора(СтрокаНабора, ТекКолонка, ВидыПолейНаборовДанных, МассивПолей, Column);
		EndDo;
	ElsIf Type = ВидыПолейНаборовДанных.Field Then
		НовоеПоле.ТипЗначенияЗапроса=Column.ValueType;
	EndIf;

	If ЗаполнятьОграничение Then
		НовоеПоле.ОграничениеИспользованияГруппировка=ОграничениеГруппа;
		НовоеПоле.ОграничениеИспользованияПоле=ОграничениеПоле;
		НовоеПоле.ОграничениеИспользованияПорядок=ОграничениеПорядок;
		НовоеПоле.ОграничениеИспользованияУсловие=ОграничениеУсловие;

		НовоеПоле.ОграничениеИспользованияРеквизитовГруппировка=ОграничениеГруппа;
		НовоеПоле.ОграничениеИспользованияРеквизитовПоле=ОграничениеПоле;
		НовоеПоле.ОграничениеИспользованияРеквизитовПорядок=ОграничениеПорядок;
		НовоеПоле.ОграничениеИспользованияРеквизитовУсловие=ОграничениеУсловие;
	EndIf;

	МассивПолей.Add(Field);
EndProcedure
&AtServer
Procedure ЗаполнитьПоляНабораДанныхПриИзмененииЗапросаНаСервере(ИдентификаторСтрокиНабора)
	СтрокаНабора=DataSets.FindByID(ИдентификаторСтрокиНабора);

	МассивПолей=New Array;
	ВидыПолейНаборовДанных=ВидыПолейНаборовДанных();
	ВидыНаборовДанных=ВидыНаборовДанных();

	If Not СтрокаНабора.AutoFillAvailableFields Then
		QueryBuilder=New QueryBuilder(СтрокаНабора.Query);

		For Each ДоступноеПоле In QueryBuilder.AvailableFields Do
			ДобавитьПолеНабора(СтрокаНабора, ДоступноеПоле, ВидыПолейНаборовДанных, МассивПолей);
		EndDo;

	Else

		QuerySchema=New QuerySchema;
		If UT_CommonClientServer.PlatformVersionNotLess_8_3_14() Then
			QuerySchema.DataCompositionMode=True;
		EndIf;
		QuerySchema.SetQueryText(СтрокаНабора.Query);

		ИндексПакета=QuerySchema.QueryBatch.Count() - 1;
		НужныйПакет=QuerySchema.QueryBatch[ИндексПакета];
		While TypeOf(НужныйПакет) <> Type("QuerySchemaSelectQuery") Do
			If ИндексПакета < 0 Then
				Break;
			EndIf;
			ИндексПакета=ИндексПакета - 1;
			НужныйПакет=QuerySchema.QueryBatch[ИндексПакета];
		EndDo;

		If TypeOf(НужныйПакет) <> Type("QuerySchemaSelectQuery") Then
			Return;
		EndIf;
		If СтрокаНабора.AutoFillAvailableFields Then
			For Each Column In НужныйПакет.Cols Do
				ДобавитьПолеНабора(СтрокаНабора, Column, ВидыПолейНаборовДанных, МассивПолей);
			EndDo;
		EndIf;
	EndIf;

	УдалитьЛишниеПоляНабораПослеЗаполнения(СтрокаНабора, МассивПолей);

	РодительскийНабор=СтрокаНабора.GetParent();
	If РодительскийНабор.Type = ВидыНаборовДанных.Union Then
		ЗаполнитьПоляНабораДанныхОбъединениеПоПодчиненнымЗапросам(РодительскийНабор.GetID());
	EndIf;
EndProcedure

&AtServer
Procedure УдалитьЛишниеПоляНабораПослеЗаполнения(СтрокаНабора, МассивДобавленныхПолей)
	ВидыПолейНаборовДанных=ВидыПолейНаборовДанных();

	МассивПолейКУдалению=New Array;
	For Each СтрокаПоля In СтрокаНабора.Fields Do
		If МассивДобавленныхПолей.Find(СтрокаПоля.Field) = Undefined And СтрокаПоля.Type
			<> ВидыПолейНаборовДанных.Folder Then
			МассивПолейКУдалению.Add(СтрокаПоля);
		EndIf;
	EndDo;

	For Each Стр In МассивПолейКУдалению Do
		СтрокаНабора.Fields.Delete(Стр);
	EndDo;
EndProcedure

&AtServer
Procedure ЗаполнитьПоляНабораДанныхОбъединениеПоПодчиненнымЗапросам(ИдентификаторСтрокиНабора)
	СтрокаНабора=DataSets.FindByID(ИдентификаторСтрокиНабора);

	ВидыПолейНаборов=ВидыПолейНаборовДанных();

	ПоляНаборы=New Array;
	МассивПолей=New Array;
	For Each ТекНабор In СтрокаНабора.GetItems() Do
		For Each ТекПоле In ТекНабор.Fields Do
			If ТекПоле.Type = ВидыПолейНаборов.Set Then
				ПоляНаборы.Add(ТекПоле.DataPath);
			EndIf;

			СтруктураПоиска=New Structure;
			СтруктураПоиска.Insert("DataPath", ТекПоле.DataPath);

			НайденныеСтроки=СтрокаНабора.Fields.FindRows(СтруктураПоиска);
			If НайденныеСтроки.Count() = 0 Then
				НовоеПоле=СтрокаНабора.Fields.Add();
				НовоеПоле.Type=ТекПоле.Type;
				НовоеПоле.DataPath=ТекПоле.DataPath;
				НовоеПоле.Title=UT_StringFunctionsClientServer.IdentifierPresentation(НовоеПоле.DataPath);
				НовоеПоле.Field=НовоеПоле.DataPath;
			Else
				НовоеПоле=НайденныеСтроки[0];
			EndIf;

			МассивПолей.Add(НовоеПоле.DataPath);

		EndDo;
	EndDo;

	НовыйМассивПолей=New Array;
	For Each Field In МассивПолей Do
		If ПоляНаборы.Find(Field) = Undefined Then
			НовыйМассивПолей.Add(Field);
		EndIf;
	EndDo;

	УдалитьЛишниеПоляНабораПослеЗаполнения(СтрокаНабора, НовыйМассивПолей);

	ВидыНаборовДанных=ВидыНаборовДанных();
	РодительскийНабор=СтрокаНабора.GetParent();
	If РодительскийНабор.Type = ВидыНаборовДанных.Union Then
		ЗаполнитьПоляНабораДанныхОбъединениеПоПодчиненнымЗапросам(РодительскийНабор.GetID());
	EndIf;
EndProcedure

&AtClient
Procedure ОткрытьКонструкторЗапросаЗавершение(Text, AdditionalParameters) Export
	If Text = Undefined Then
		Return;
	EndIf;

	RowID=AdditionalParameters.ТекСтрока;
	СтрокаНабора=DataSets.FindByID(RowID);

	СтрокаНабора.Query=Text;

	ЗаполнитьПоляНабораДанныхПриИзмененииЗапроса(RowID);
EndProcedure
&AtClient
Procedure ДобавитьНаборДанных(Type)
	ТекДанные=Items.DataSets.CurrentData;
	If ТекДанные.Type = ВидыНаборовДанных.Union Then
		СтрокаДереваДляДобавления=DataSets.FindByID(Items.DataSets.CurrentLine);
	Else
		СтрокаДереваДляДобавления=DataSets.FindByID(ИдентификаторНулевогоНабораДанных);
	EndIf;

	НаборДанных=СтрокаДереваДляДобавления.GetItems().Add();
	НаборДанных.Name="НаборДанных" + НаборДанных.GetID();
	НаборДанных.Type=Type;

	If Type = ВидыНаборовДанных.Query Then
		НаборДанных.Picture=PictureLib.УИ_DataSetСКДЗапрос;
		НаборДанных.AutoFillAvailableFields=True;
		НаборДанных.UseQueryGroupIfPossible=True;
	ElsIf Type = ВидыНаборовДанных.Object Then
		НаборДанных.Picture=PictureLib.UT_DataSetDCSObject;
	ElsIf Type = ВидыНаборовДанных.Union Then
		НаборДанных.Picture=PictureLib.UT_DataSetDCSUnion;
	EndIf;

	Items.DataSets.CurrentLine=НаборДанных.GetID();

	If DataSources.Count() > 0 Then
		НаборДанных.DataSource=DataSources[0].Name;
	EndIf;
EndProcedure
&AtClientAtServerNoContext
Function ВидыНаборовДанных()
	Structure=New Structure;
	Structure.Insert("Root", "Root");
	Structure.Insert("Query", "DataCompositionSchemaDataSetQuery");
	Structure.Insert("Object", "DataCompositionSchemaDataSetObject");
	Structure.Insert("Union", "DataCompositionSchemaDataSetUnion");

	Return Structure;
EndFunction

&AtClientAtServerNoContext
Function ВидыПолейНаборовДанных()
	Structure=New Structure;
	Structure.Insert("Field", "DataCompositionSchemaDataSetField");
	Structure.Insert("Folder", "DataCompositionSchemaDataSetFieldFolder");
	Structure.Insert("Set", "DataCompositionSchemaNestedDataSet");

	Return Structure;

EndFunction

&AtClient
Function НаборыДанныхВерхнегоУровня()
	МассивНаборов=New Array;

	НулевойНаборДанных=DataSets.FindByID(ИдентификаторНулевогоНабораДанных);
	For Each Set In НулевойНаборДанных.GetItems() Do
		МассивНаборов.Add(Set);
	EndDo;

	Return МассивНаборов;
EndFunction

&AtClient
Procedure ЗаполнитьСписокВыбораИсточникаДанныхНабора()
	Items.НаборыДанныхИсточникДанных.ChoiceList.Clear();

	For Each Стр In DataSources Do
		Items.НаборыДанныхИсточникДанных.ChoiceList.Add(Стр.Name);
	EndDo;
EndProcedure

&AtClient
Procedure ГруппаНаборыДанныхПраваяПанельПриСменеСтраницы(Item, CurrentPage)
	ЗаполнитьСписокВыбораИсточникаДанныхНабора();
EndProcedure

&AtClientAtServerNoContext
Function ПредставлениеРолиПоляНабораДанных(Role)
	If Role = Undefined Then
		Return "";
	EndIf;

	МассивПредставления=New Array;

	If Role.Period Then
		МассивПредставления.Add("Period");
		МассивПредставления.Add(Role.PeriodNumber);
		If Role.ПериодДополнительный Then
			МассивПредставления.Add("Доп");
		EndIf;
	EndIf;

	If Role.Dimension Then
		МассивПредставления.Add("Dimension");
		If ValueIsFilled(Role.ParentDimension) Then
			МассивПредставления.Add(Role.ParentDimension);
		EndIf;
	EndIf;

	If Role.Account Then
		МассивПредставления.Add("Account");
		МассивПредставления.Add(Role.AccountTypeExpression);
	EndIf;

	If Role.Balance Then
		If Lower(Role.BalanceType) = "начальныйостаток" Then
			МассивПредставления.Add("НачОст");
		ElsIf Lower(Role.BalanceType) = "конечныйостаток" Then
			МассивПредставления.Add("КонОст");
		EndIf;
		If Lower(Role.AccountingBalanceType) = "дебет" Then
			МассивПредставления.Add("Дт");
		ElsIf Lower(Role.AccountingBalanceType) = "кредит" Then
			МассивПредставления.Add("Кт");
		EndIf;

		If ValueIsFilled(Role.BalanceGroup) Then
			МассивПредставления.Add(Role.BalanceGroup);
		EndIf;
		If ValueIsFilled(Role.AccountField) Then
			МассивПредставления.Add(Role.AccountField);
		EndIf;
	EndIf;

	If Role.IgnoreNULLValues Then
		МассивПредставления.Add("NULL");
	EndIf;

	If Role.Required Then
		МассивПредставления.Add("Required");
	EndIf;

	Return StrConcat(МассивПредставления, ", ");
EndFunction

&AtClient
Procedure НаборыДанныхПоляРольПредставлениеНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	СтрокаНабора=DataSets.FindByID(AdditionalParameters.ИдентификаторСтрокиНабора);

	СтрокаПоля=СтрокаНабора.Fields.FindByID(AdditionalParameters.RowID);
	СтрокаПоля.Role=Result;

	СтрокаПоля.РольПредставление=ПредставлениеРолиПоляНабораДанных(СтрокаПоля.Role);
EndProcedure

&AtClient
Procedure ПоляДоступныеЗначенияНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	СтрокаНабора=DataSets.FindByID(AdditionalParameters.ИдентификаторСтрокиНабора);

	СтрокаПоля=СтрокаНабора.Fields.FindByID(AdditionalParameters.RowID);
	СтрокаПоля.AvailableValues=Result;
EndProcedure

&AtClient
Procedure ВручнуюДобавитьПолеНабораДанных(ВидПоля)
	СтрокаНабора=Items.DataSets.CurrentData;
	If СтрокаНабора = Undefined Then
		Return;
	EndIf;

	НовоеПоле=СтрокаНабора.Fields.Add();
	НовоеПоле.Type=ВидПоля;
	НовоеПоле.Picture=КартинкаВидаПоляНабораДанных(ВидПоля, ВидыПолейНаборовДанных);
	НовоеПоле.DataPath="Field" + НовоеПоле.GetID();
	НовоеПоле.Title=UT_StringFunctionsClientServer.IdentifierPresentation(НовоеПоле.DataPath);
	If ВидПоля <> ВидыПолейНаборовДанных.Folder Then
		НовоеПоле.Field=НовоеПоле.DataPath;
	EndIf;

	Items.НаборыДанныхПоля.CurrentLine=НовоеПоле.GetID();
	
	РодительскийНабор=СтрокаНабора.GetParent();
	If РодительскийНабор.Type=ВидыНаборовДанных.Union Then
		ЗаполнитьПоляНабораДанныхОбъединениеПоПодчиненнымЗапросам(РодительскийНабор.GetID());
	EndIf;
EndProcedure

&AtClientAtServerNoContext
Function КартинкаВидаПоляНабораДанных(Type, ВидыПолейНабора)
	If Type = ВидыПолейНабора.Field Then
		Picture=PictureLib.Attribute;
	ElsIf Type = ВидыПолейНабора.Set Then
		Picture=PictureLib.NestedTable;
	Else
		Picture=PictureLib.Folder;
	EndIf;

	Return Picture;
EndFunction

&AtClient
Function ДоступноДобавлениеПоляНабораПоле(ТекСтрокаНабора)
	Return ТекСтрокаНабора.Type = ВидыНаборовДанных.Object;
EndFunction

&AtClient
Function ДоступноДобавлениеПоляНабораНабор(ТекСтрокаНабора)
	Return ТекСтрокаНабора.Type = ВидыНаборовДанных.Object;
EndFunction

&AtClient
Function ДоступноКопированиеУдаленияПоляНабора(ТекСтрокаНабора, ТекСтрокаПоля)
	If ТекСтрокаПоля = Undefined Then
		Return False;
	EndIf;

	Return ТекСтрокаПоля.Type = ВидыПолейНаборовДанных.Folder Or (ДоступноДобавлениеПоляНабораПоле(ТекСтрокаНабора)
		And ТекСтрокаПоля.Type = ВидыПолейНаборовДанных.Field) Or (ДоступноДобавлениеПоляНабораНабор(ТекСтрокаНабора)
		And ТекСтрокаПоля.Type = ВидыПолейНаборовДанных.Set);
EndFunction

&AtClient
Procedure УстановитьДоступностьКнопокДобавленияПолейНабора()
	ТекНабор=Items.DataSets.CurrentData;
	If ТекНабор = Undefined Then
		Return;
	EndIf;
	If ТекНабор.GetID() = ИдентификаторНулевогоНабораДанных Then
		Return;
	EndIf;

	ДоступноДобавлениеПоля=ДоступноДобавлениеПоляНабораПоле(ТекНабор);
	ДоступноДобавлениеНабора=ДоступноДобавлениеПоляНабораНабор(ТекНабор);
	ДоступноКопирование=ДоступноКопированиеУдаленияПоляНабора(ТекНабор, Items.НаборыДанныхПоля.CurrentData);
	ДоступноУдаление=ДоступноКопирование;

	Items.НаборыДанныхПоляДобавитьПолеНабораПоле.Enabled=ДоступноДобавлениеПоля;
	Items.НаборыДанныхПоляДобавитьПолеНабораПоле1.Visible=ДоступноДобавлениеПоля;

	Items.НаборыДанныхПоляДобавитьПолеНабораНабор.Enabled=ДоступноДобавлениеНабора;
	Items.НаборыДанныхПоляДобавитьПолеНабораНабор1.Visible=ДоступноДобавлениеНабора;

	Items.НаборыДанныхПоляСкопировать.Enabled=ДоступноКопирование;
	Items.НаборыДанныхПоляСкопировать1.Visible=ДоступноКопирование;

	Items.НаборыДанныхПоляУдалить.Enabled=ДоступноКопирование;
	Items.НаборыДанныхПоляУдалить1.Visible=ДоступноУдаление;

EndProcedure

&AtClient
Procedure ПоляТипЗначенияНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result=Undefined Then
		Return;
	EndIf;
	СтрокаНабора=Items.DataSets.CurrentData;
	If СтрокаНабора = Undefined Then
		Return;
	EndIf;
	
	ТекДанныеСтроки=СтрокаНабора.Fields.FindByID(AdditionalParameters.ТекСтрока);
	ТекДанныеСтроки.ValueType=Result;
EndProcedure
#EndRegion

#Region DataSetLinks
&AtClient
Procedure ЗаполнитьСписокВыбораПоляСвязиНаборов(ИмяНабораДанных, ЭлементПоля)
	ЭлементПоля.ChoiceList.Clear();

	НаборДанных=НаборДанныхПоИмени(ИмяНабораДанных);
	If НаборДанных = Undefined Then
		Return;
	EndIf;

	For Each Field In НаборДанных.Fields Do
		ЭлементПоля.ChoiceList.Add(Field.DataPath);
	EndDo;

EndProcedure

&AtClient
Procedure ЗаполнитьВспомогательныеДанныеСвязейНаборовДанных()
	Наборы=НаборыДанныхВерхнегоУровня();

	Items.СвязиНаборовДанныхНаборДанныхИсточник.ChoiceList.Clear();
	Items.СвязиНаборовДанныхНаборДанныхПриемник.ChoiceList.Clear();

	For Each Set In Наборы Do
		Items.СвязиНаборовДанныхНаборДанныхИсточник.ChoiceList.Add(Set.Name);
		Items.СвязиНаборовДанныхНаборДанныхПриемник.ChoiceList.Add(Set.Name);
	EndDo;
EndProcedure
#EndRegion

#Region CalculatedFields
&AtClient
Procedure ВычисляемыеПоляВыражениеЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	СтрокаРесурса=CalculatedFields.FindByID(AdditionalParameters.RowID);
	СтрокаРесурса.Expression=Result;
EndProcedure

&AtClient
Procedure ВычисляемыеПоляДоступныеЗначенияНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	СтрокаПоля=CalculatedFields.FindByID(AdditionalParameters.RowID);
	СтрокаПоля.AvailableValues=Result;
EndProcedure

&AtClient
Procedure ВычисляемыеПоляТипЗначенияНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result=Undefined Then
		Return;
	EndIf;
	
	ТекДанныеСтроки=CalculatedFields.FindByID(AdditionalParameters.ТекСтрока);
	ТекДанныеСтроки.ValueType=Result;
EndProcedure

#EndRegion

#Region Resources
&AtClient
Procedure РесурсыГруппировкиНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	СтрокаРесурса=Resources.FindByID(AdditionalParameters.RowID);
	СтрокаРесурса.Groups=Result;
EndProcedure

&AtClient
Procedure РесурсыВыражениеОткрытиеЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	СтрокаРесурса=Resources.FindByID(AdditionalParameters.RowID);
	СтрокаРесурса.Expression=Result;
EndProcedure

&AtClient
Procedure ДобавитьРесурс(СтрокаДоступногоПоля)
	If TypeOf(СтрокаДоступногоПоля) = Type("Number") Then
		ДоступноеПоле=ResourceAvailableField.FindByID(СтрокаДоступногоПоля);
	Else
		ДоступноеПоле=СтрокаДоступногоПоля;
	EndIf;

	НС=Resources.Add();
	НС.DataPath=ДоступноеПоле.DataPath;

	If ДоступноеПоле.ВычисляемоеПоле Or ДоступноеПоле.Числовое Then
		НС.Expression=StrTemplate("Сумма(%1)", НС.DataPath);
	Else
		НС.Expression=StrTemplate("Count(%1)", НС.DataPath);
	EndIf;
EndProcedure

&AtClient
Procedure ЗаполнитьДоступныеПоляРесурсов()
	ResourceAvailableField.Clear();

	НаборыДанныхВерхнегоУровня=НаборыДанныхВерхнегоУровня();

	КартинкаРеквизит=PictureLib.Attribute;
	КартинкаПроизвольноеВыражение=PictureLib.CustomExpression;

	МассивПутей=New Array;

	For Each Set In НаборыДанныхВерхнегоУровня Do
		For Each Field In Set.Fields Do
			If МассивПутей.Find(Field.DataPath) <> Undefined Then
				Continue;
			EndIf;

			If Field.Type <> ВидыПолейНаборовДанных.Field Then
				Continue;
			EndIf;

			НС=ResourceAvailableField.Add();
			НС.DataPath=Field.DataPath;
			НС.Picture=КартинкаРеквизит;

			НС.Числовое= Field.ТипЗначенияЗапроса.ContainsType(тип("Number"));

			МассивПутей.Add(Field.DataPath);
		EndDo;
	EndDo;

	For Each Field In CalculatedFields Do
		If МассивПутей.Find(Field.DataPath) <> Undefined Then
			Continue;
		EndIf;
		НС=ResourceAvailableField.Add();
		НС.DataPath=Field.DataPath;
		НС.ВычисляемоеПоле=True;
		НС.Picture=КартинкаПроизвольноеВыражение;

		МассивПутей.Add(Field.DataPath);

	EndDo;

	ResourceAvailableField.Sort("DataPath Asc");
EndProcedure

&AtClient
Procedure УдалитьРесурсыНеПодходящиеПоДоступнымПолям()
	МассивУдаляемыхСтрок=New Array;
	For Each Стр In Resources Do
		СтруктураПоиска=New Structure;
		СтруктураПоиска.Insert("DataPath", Стр.DataPath);

		НайденныеСтроки=ResourceAvailableField.FindRows(СтруктураПоиска);
		If НайденныеСтроки.Count() = 0 Then
			МассивУдаляемыхСтрок.Add(стр);
		EndIf;
	EndDo;

	For Each Стр In МассивУдаляемыхСтрок Do
		Resources.Delete(Стр);
	EndDo;
EndProcedure

&AtClient
Procedure ЗаполнитьВспомогательныеДанныеРесурсов()
	ЗаполнитьДоступныеПоляРесурсов();
	УдалитьРесурсыНеПодходящиеПоДоступнымПолям();
EndProcedure

&AtClient
Procedure ЗаполнитьСписокВыбораВыраженияРесурса(ИдентификаторСтрокиРесурса)
	Items.РесурсыВыражение.ChoiceList.Clear();

	СтрокаРесурса=Resources.FindByID(ИдентификаторСтрокиРесурса);

	СтруктураПоиска=New Structure;
	СтруктураПоиска.Insert("DataPath", СтрокаРесурса.DataPath);

	СтрокиДоступныхПолей=ResourceAvailableField.FindRows(СтруктураПоиска);
	If СтрокиДоступныхПолей.Count() = 0 Then
		Return;
	EndIf;

	СтрокаДоступногоПоля=СтрокиДоступныхПолей[0];

	If СтрокаДоступногоПоля.ВычисляемоеПоле Or СтрокаДоступногоПоля.Числовое Then
		Items.РесурсыВыражение.ChoiceList.Add(StrTemplate("Сумма(%1)", СтрокаРесурса.DataPath));
		Items.РесурсыВыражение.ChoiceList.Add(StrTemplate("Mean(%1)", СтрокаРесурса.DataPath));
	EndIf;
	Items.РесурсыВыражение.ChoiceList.Add(StrTemplate("Maximum(%1)", СтрокаРесурса.DataPath));
	Items.РесурсыВыражение.ChoiceList.Add(StrTemplate("Minimum(%1)", СтрокаРесурса.DataPath));
	Items.РесурсыВыражение.ChoiceList.Add(StrTemplate("Count(%1)", СтрокаРесурса.DataPath));
	Items.РесурсыВыражение.ChoiceList.Add(StrTemplate("Count(Различные %1)", СтрокаРесурса.DataPath));

EndProcedure
#EndRegion

#Region Parameters

&AtClient
Procedure ПараметрыСКДЗначениеНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	СтрокаРесурса=DCSParameters.FindByID(AdditionalParameters.RowID);
	СтрокаРесурса.Value=Result;
EndProcedure

&AtClient
Procedure ПараметрыСКДДоступныеЗначенияНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	СтрокаРесурса=DCSParameters.FindByID(AdditionalParameters.RowID);
	СтрокаРесурса.AvailableValues=Result;

	УстановитьСписокВыбораПоляЗначенияПараметра(СтрокаРесурса);
EndProcedure

&AtClient
Procedure УстановитьСписокВыбораПоляЗначенияПараметра(СтрокаПараметров)
	Items.ПараметрыСКДЗначение.ListChoiceMode=СтрокаПараметров.AvailableValues.Count() > 0
		And Not СтрокаПараметров.ValueListAllowed;

	Items.ПараметрыСКДЗначение.ChoiceList.Clear();

	For Each ЭлементСписка In СтрокаПараметров.AvailableValues Do
		Items.ПараметрыСКДЗначение.ChoiceList.Add(ЭлементСписка.Value, ЭлементСписка.Presentation);
	EndDo;
EndProcedure

&AtClient
Procedure УстановитьОграничениеТипаПоляЗначенияПараметра(СтрокаПараметров)
	If СтрокаПараметров.ValueType = New TypeDescription Then
		Return;
	EndIf;

	If СтрокаПараметров.ValueListAllowed Then
		Items.ПараметрыСКДЗначение.TypeRestriction=New TypeDescription("ValueList");
	Else
		Items.ПараметрыСКДЗначение.TypeRestriction=СтрокаПараметров.ValueType;
	EndIf;
EndProcedure
&AtClient
Procedure ПараметрыСКДВыражениеОткрытиеЗавершение(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	СтрокаРесурса=DCSParameters.FindByID(AdditionalParameters.RowID);
	СтрокаРесурса.Expression=Result;
EndProcedure

&AtClient
Procedure ПараметрыСКДТипЗначенияНачалоВыбораЗавершение(Result, AdditionalParameters) Export
	If Result=Undefined Then
		Return;
	EndIf;
	
	ТекДанныеСтроки=DCSParameters.FindByID(AdditionalParameters.ТекСтрока);
	ТекДанныеСтроки.ValueType=Result;
	
	If ТекДанныеСтроки.ValueListAllowed Then
		НовоеЗначение=New ValueList;

		For Each ЭлементСписка In ТекДанныеСтроки.Value Do
			If ТекДанныеСтроки.ValueType.ContainsType(TypeOf(ЭлементСписка.Value)) Then
				НовоеЗначение.Add(ЭлементСписка.Value);
			EndIf;
		EndDo;
		ТекДанныеСтроки.Value=НовоеЗначение;
	Else
		ТекДанныеСтроки.Value=ТекДанныеСтроки.ValueType.AdjustValue(ТекДанныеСтроки.Value);
	EndIf;

	УстановитьОграничениеТипаПоляЗначенияПараметра(ТекДанныеСтроки);

EndProcedure

#EndRegion

#Region НастройкиКомпоновки
&AtClient
Procedure GroupFieldsNotAvailable()

	Items.СтраницыПолейГруппировки.CurrentPage = Items.НедоступныеНастройкиПолейГруппировки;

EndProcedure

&AtClient
Procedure SelectedFieldsAvailable(ЭлементСтруктуры)

	If CurrentSettingsComposer.Settings.HasItemSelection(ЭлементСтруктуры) Then

		LocalSelectedFields = True;
		Items.СтраницыПолейВыбора.CurrentPage = Items.НастройкиВыбранныхПолей;

	Else

		LocalSelectedFields = False;
		Items.СтраницыПолейВыбора.CurrentPage = Items.ОтключенныеНастройкиВыбранныхПолей;

	EndIf;

	Items.LocalSelectedFields.ReadOnly = False;

EndProcedure

&AtClient
Procedure SelectedFieldsUnavailable()

	LocalSelectedFields = False;
	Items.LocalSelectedFields.ReadOnly = True;
	Items.СтраницыПолейВыбора.CurrentPage = Items.НедоступныеНастройкиВыбранныхПолей;

EndProcedure

&AtClient
Procedure FilterAvailable(ЭлементСтруктуры)

	If CurrentSettingsComposer.Settings.HasItemFilter(ЭлементСтруктуры) Then

		LocalFilter = True;
		Items.СтраницыОтбора.CurrentPage = Items.НастройкиОтбора;

	Else

		LocalFilter = False;
		Items.СтраницыОтбора.CurrentPage = Items.ОтключенныеНастройкиОтбора;

	EndIf;

	Items.LocalFilter.ReadOnly = False;

EndProcedure

&AtClient
Procedure FilterUnavailable()

	LocalFilter = False;
	Items.LocalFilter.ReadOnly = True;
	Items.СтраницыОтбора.CurrentPage = Items.НедоступныеНастройкиОтбора;

EndProcedure

&AtClient
Procedure OrderAvailable(ЭлементСтруктуры)

	If CurrentSettingsComposer.Settings.HasItemOrder(ЭлементСтруктуры) Then

		LocalOrder = True;
		Items.СтраницыПорядка.CurrentPage = Items.НастройкиПорядка;

	Else

		LocalOrder = False;
		Items.СтраницыПорядка.CurrentPage = Items.ОтключенныеНастройкиПорядка;

	EndIf;

	Items.LocalOrder.ReadOnly = False;

EndProcedure

&AtClient
Procedure OrderUnavailable()

	LocalOrder = False;
	Items.LocalOrder.ReadOnly = True;
	Items.СтраницыПорядка.CurrentPage = Items.НедоступныеНастройкиПорядка;

EndProcedure

&AtClient
Procedure ConditionalAppearanceAvailable(ЭлементСтруктуры)

	If CurrentSettingsComposer.Settings.HasItemConditionalAppearance(ЭлементСтруктуры) Then

		LocalConditionalAppearance = True;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.НастройкиУсловногоОформления;

	Else

		LocalConditionalAppearance = False;
		Items.СтраницыУсловногоОформления.CurrentPage = Items.ОтключенныеНастройкиУсловногоОформления;

	EndIf;

	Items.LocalConditionalAppearance.ReadOnly = False;

EndProcedure

&AtClient
Procedure ConditionalAppearanceUnavailable()

	LocalConditionalAppearance = False;
	Items.LocalConditionalAppearance.ReadOnly = True;
	Items.СтраницыУсловногоОформления.CurrentPage = Items.НедоступныеНастройкиУсловногоОформления;

EndProcedure

&AtClient
Procedure OutputParametersAvailable(ЭлементСтруктуры)

	If CurrentSettingsComposer.Settings.HasItemOutputParameters(ЭлементСтруктуры) Then

		LocalOutputParameters = True;
		Items.СтраницыПараметровВывода.CurrentPage = Items.НастройкиПараметровВывода;

	Else

		LocalOutputParameters = False;
		Items.СтраницыПараметровВывода.CurrentPage = Items.ОтключенныеНастройкиПараметровВывода;

	EndIf;

	Items.LocalOutputParameters.ReadOnly = False;

EndProcedure

&AtClient
Procedure OutputParametersUnavailable()

	LocalOutputParameters = False;
	Items.LocalOutputParameters.ReadOnly = True;
	Items.СтраницыПараметровВывода.CurrentPage = Items.НедоступныеНастройкиПараметровВывода;

EndProcedure
#EndRegion

#Region SettingVariants

&AtServer
Procedure ИнициализироватьКомпоновщикНастроекПоСобраннойСКД()

	CurrentSettingsComposer.Initialize(
			New DataCompositionAvailableSettingsSource(АдресСхемыКомпоновкиДанных));
	CurrentSettingsComposer.Recall();
EndProcedure

&AtServer
Procedure СохранитьВТаблицуФормыНастройкуТекущегоВариантаНастроек()
	СтрокаПредыдущегоВарианта=SettingVariants.FindByID(ИдентификаторСтрокиТекущегоВариантаНастроек);
	СтрокаПредыдущегоВарианта.Settings=UT_Common.ValueToXMLString(
		CurrentSettingsComposer.GetSettings());
EndProcedure

&AtServer
Procedure ВариантыНастроекПриАктивизацииСтрокиНаСервере(RowID)
	If RowID = ИдентификаторСтрокиТекущегоВариантаНастроек Then
		Return;
	EndIf;

	ТекДанные=SettingVariants.FindByID(RowID);
	If ТекДанные = Undefined Then
		Return;
	EndIf;

	СохранитьВТаблицуФормыНастройкуТекущегоВариантаНастроек();

	ИдентификаторСтрокиТекущегоВариантаНастроек=RowID;

	If ValueIsFilled(ТекДанные.Settings) Then
		Settings=UT_Common.ValueFromXMLString(ТекДанные.Settings);
	Else
		Settings=New DataCompositionSettings;
	EndIf;

	CurrentSettingsComposer.LoadSettings(Settings);
	CurrentSettingsComposer.Recall();
EndProcedure

#EndRegion

&AtServer
Procedure ИнициализироватьФорму()
	ВидыНаборов=ВидыНаборовДанных();

	ЛокальныйИсточникДанных=DataSources.Add();
	ЛокальныйИсточникДанных.Name="ИсточникДанных1";
	ЛокальныйИсточникДанных.DataSourceType="Local";

	НулевойНаборДанных=DataSets.GetItems().Add();
	НулевойНаборДанных.Name="Наборы данных";
	НулевойНаборДанных.Type=ВидыНаборов.Root;

	ВариантНастроекПоУмолчанию=SettingVariants.Add();
	ВариантНастроекПоУмолчанию.Name="Main";
	ВариантНастроекПоУмолчанию.Presentation="Main";

	ИдентификаторНулевогоНабораДанных=НулевойНаборДанных.GetID();
	ИдентификаторСтрокиТекущегоВариантаНастроек=ВариантНастроекПоУмолчанию.GetID();

	УстановитьУсловноеОформлениеФормы();
EndProcedure

&AtServer
Procedure УстановитьУсловноеОформлениеФормы()
	ВидыПолейНаборов=ВидыПолейНаборовДанных();
	ВидыНаборов=ВидыНаборовДанных();
	
	//1. For Fields набора папка запретить редактировать колонку "Field"
	НовоеУО=ConditionalAppearance.Items.Add();
	НовоеУО.Use=True;
	UT_CommonClientServer.SetFilterItem(НовоеУО.Filter,
		"Items.DataSets.CurrentData.Fields.Type", ВидыПолейНаборов.Folder);
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("НаборыДанныхПоляПоле");

	Appearance=НовоеУО.Appearance.FindParameterValue(New DataCompositionParameter("ReadOnly"));
	Appearance.Use=True;
	Appearance.Value=True;
	
	//1.1 For Fields набора Set запретить редактировать колонку "органичение использования"
	НовоеУО=ConditionalAppearance.Items.Add();
	НовоеУО.Use=True;
	UT_CommonClientServer.SetFilterItem(НовоеУО.Filter,
		"Items.DataSets.CurrentData.Fields.Type", ВидыПолейНаборов.Set);
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляОграничениеИспользованияПоле");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляОграничениеИспользованияУсловие");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляОграничениеИспользованияГруппировка");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляОграничениеИспользованияПорядок");

	Appearance=НовоеУО.Appearance.FindParameterValue(New DataCompositionParameter("ReadOnly"));
	Appearance.Use=True;
	Appearance.Value=True;
	
	//2. For полей набора не Fields блочим колонки для редактирования
	НовоеУО=ConditionalAppearance.Items.Add();
	НовоеУО.Use=True;
	UT_CommonClientServer.SetFilterItem(НовоеУО.Filter,
		"Items.DataSets.CurrentData.Fields.Type", ВидыПолейНаборов.Field, DataCompositionComparisonType.NotEqual);
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляОграничениеИспользованияРеквизитовПоле");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляОграничениеИспользованияРеквизитовУсловие");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляОграничениеИспользованияРеквизитовГруппировка");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляОграничениеИспользованияРеквизитовПорядок");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("НаборыДанныхПоляРольПредставление");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляВыражениеПредставления");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляНаборДанныхПроверкиИерархии");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляПараметрНабораДанныхПроверкиИерархии");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляТипЗначения");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляДоступныеЗначения");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляОформление");
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПоляПараметрыРедактирования");

	Appearance=НовоеУО.Appearance.FindParameterValue(New DataCompositionParameter("ReadOnly"));
	Appearance.Use=True;
	Appearance.Value=True;
	
	//3. имя параметра добавленного авторматически нельзя править
	НовоеУО=ConditionalAppearance.Items.Add();
	НовоеУО.Use=True;
	UT_CommonClientServer.SetFilterItem(НовоеУО.Filter,
		"Items.DCSParameters.CurrentData.ДобавленАвтоматически", True);
	Field=НовоеУО.Fields.Items.Add();
	Field.Use=True;
	Field.Field=New DataCompositionField("ПараметрыСКДИмя");

	Appearance=НовоеУО.Appearance.FindParameterValue(New DataCompositionParameter("ReadOnly"));
	Appearance.Use=True;
	Appearance.Value=True;

EndProcedure

#Region СКД

&AtServer
Procedure ПрочитатьИсточникиДанныхСКДВДанныеФормы(СКД)
	DataSources.Clear();

	For Each ТекИсточник In СКД.DataSources Do
		НовыйИсточник=DataSources.Add();
		FillPropertyValues(НовыйИсточник, ТекИсточник);
	EndDo;
EndProcedure

&AtServer
Procedure ПрочитатьРольПоляНабораДанныхВДанныеФормы(РольРедактора, РольНабора)
	РольРедактора=НоваяСтруктураРедактированияРолиПоляНабораДанных();

	FillPropertyValues(РольРедактора, РольНабора, , "AccountingBalanceType,BalanceType");

	РольРедактора.AccountingBalanceType=String(РольНабора.AccountingBalanceType);
	РольРедактора.AccountingBalanceType=String(РольНабора.BalanceType);

	РольРедактора.ПериодДополнительный=РольНабора.PeriodType = DataCompositionPeriodType.Additional;

	РольРедактора.Period=РольНабора.PeriodNumber <> 0;
EndProcedure

&AtServer
Procedure ПрочитатьПоляНабораСКДВДанныеФормы(НовыйНабор, СтрокаНабора)
	НовыйНабор.Fields.Clear();

	ВидыПолейНабораДанныхСКД=ВидыПолейНаборовДанных();

	For Each СтрокаПоля In СтрокаНабора.Fields Do
		НовоеПоле=НовыйНабор.Fields.Add();
		If TypeOf(СтрокаПоля) = Type(ВидыПолейНабораДанныхСКД.Field) Then
			НовоеПоле.Type=ВидыПолейНабораДанныхСКД.Field;

			FillPropertyValues(НовоеПоле, СтрокаПоля, , "Appearance,EditParameters,Role");

			ПрочитатьОграничениеИспользованияПоляСхемыКомпоновкиДанныхВДанныеФормы(
			СтрокаПоля.AttributeUseRestriction, НовоеПоле.ОграничениеИспользованияРеквизитовПоле,
				НовоеПоле.ОграничениеИспользованияРеквизитовУсловие,
				НовоеПоле.ОграничениеИспользованияРеквизитовГруппировка,
				НовоеПоле.ОграничениеИспользованияРеквизитовПорядок);

			ПрочитатьОграничениеИспользованияПоляСхемыКомпоновкиДанныхВДанныеФормы(СтрокаПоля.UseRestriction,
				НовоеПоле.ОграничениеИспользованияПоле, НовоеПоле.ОграничениеИспользованияУсловие,
				НовоеПоле.ОграничениеИспользованияГруппировка, НовоеПоле.ОграничениеИспользованияПорядок);
				
			
		//Appearance
			СкопироватьОфорление(НовоеПоле.Appearance, СтрокаПоля.Appearance);

			ПрочитатьРольПоляНабораДанныхВДанныеФормы(НовоеПоле.Role, СтрокаПоля.Role);
			НовоеПоле.РольПредставление=ПредставлениеРолиПоляНабораДанных(НовоеПоле.Role);

			НовоеПоле.AvailableValues=СтрокаПоля.GetAvailableValues();
		ElsIf TypeOf(СтрокаПоля) = Type(ВидыПолейНабораДанныхСКД.Folder) Then
			НовоеПоле.Type=ВидыПолейНабораДанныхСКД.Folder;

			FillPropertyValues(НовоеПоле, СтрокаПоля);

			ПрочитатьОграничениеИспользованияПоляСхемыКомпоновкиДанныхВДанныеФормы(СтрокаПоля.UseRestriction,
				НовоеПоле.ОграничениеИспользованияПоле, НовоеПоле.ОграничениеИспользованияУсловие,
				НовоеПоле.ОграничениеИспользованияГруппировка, НовоеПоле.ОграничениеИспользованияПорядок);

		Else
			НовоеПоле.Type=ВидыПолейНабораДанныхСКД.Set;

			FillPropertyValues(НовоеПоле, СтрокаПоля);
		EndIf;
		НовоеПоле.Picture=КартинкаВидаПоляНабораДанных(НовоеПоле.Type, ВидыПолейНабораДанныхСКД);
	EndDo;
EndProcedure
&AtServer
Procedure ПрочитатьНаборыДанныхСКДВДанныеФормы(СКДНаборыДанных, СтрокаРодительскогоНабора = Undefined)
	If СтрокаРодительскогоНабора = Undefined Then

		СтрокаНабораДляЗаполнения=DataSets.FindByID(ИдентификаторНулевогоНабораДанных);
	Else
		СтрокаНабораДляЗаполнения=СтрокаРодительскогоНабора;
	EndIf;

	СтрокаНабораДляЗаполнения.GetItems().Clear();

	ВидыНаборов=ВидыНаборовДанных();

	For Each СтрокаНабора In СКДНаборыДанных Do
		НовыйНабор=СтрокаНабораДляЗаполнения.GetItems().Add();
		If TypeOf(СтрокаНабора) = Type("DataCompositionSchemaDataSetQuery") Then
			НовыйНабор.Type=ВидыНаборов.Query;
			НовыйНабор.Picture=PictureLib.УИ_DataSetСКДЗапрос;
		ElsIf TypeOf(СтрокаНабора) = Type("DataCompositionSchemaDataSetObject") Then
			НовыйНабор.Type=ВидыНаборов.Object;
			НовыйНабор.Picture=PictureLib.UT_DataSetDCSObject;
		Else
			НовыйНабор.Type=ВидыНаборов.Union;
			НовыйНабор.Picture=PictureLib.UT_DataSetDCSUnion;
		EndIf;
		FillPropertyValues(НовыйНабор, СтрокаНабора, , "Fields");

		ПрочитатьПоляНабораСКДВДанныеФормы(НовыйНабор, СтрокаНабора);

		If НовыйНабор.Type = ВидыНаборов.Union Then
			ПрочитатьНаборыДанныхСКДВДанныеФормы(СтрокаНабора.Items, НовыйНабор);
		ElsIf НовыйНабор.Type = ВидыНаборов.Query Then
			ЗаполнитьПоляНабораДанныхПриИзмененииЗапросаНаСервере(НовыйНабор.GetID());
			ЗаполнитьПараметрыСКДПриИзмененииЗапросаНабора(НовыйНабор.GetID());
		ElsIf НовыйНабор.Type = ВидыНаборов.Object Then
			РодительскийНабор=НовыйНабор.GetParent();
			If РодительскийНабор.Type = ВидыНаборов.Union Then
				ЗаполнитьПоляНабораДанныхОбъединениеПоПодчиненнымЗапросам(РодительскийНабор.GetID());
			EndIf;
		EndIf;
	EndDo;
EndProcedure
&AtServer
Procedure ПрочитатьСвязиНаборовДанныхСКДВДанныеФормы(СКД)
	DataSetLinks.Clear();

	For Each ТекДанные In СКД.DataSetLinks Do
		НовыеДанные=DataSetLinks.Add();
		FillPropertyValues(НовыеДанные, ТекДанные);
	EndDo;
EndProcedure

&AtServer
Procedure ПрочитатьОграничениеИспользованияПоляСхемыКомпоновкиДанныхВДанныеФормы(UseRestriction, Field,
	Condition, Group, Order)

	Field=UseRestriction.Field;
	Condition=UseRestriction.Condition;
	Group=UseRestriction.Group;
	Order=UseRestriction.Order;
EndProcedure

&AtServer
Procedure ПрочитатьВычисляемыеПоляСКДВДанныеФормы(СКД)
	CalculatedFields.Clear();

	For Each ТекДанные In СКД.CalculatedFields Do
		НовыеДанные=CalculatedFields.Add();
		FillPropertyValues(НовыеДанные, ТекДанные, , "OrderExpressions,Appearance,EditParameters");

		ПрочитатьОграничениеИспользованияПоляСхемыКомпоновкиДанныхВДанныеФормы(ТекДанные.UseRestriction,
			НовыеДанные.ОграничениеИспользованияПоле, НовыеДанные.ОграничениеИспользованияУсловие,
			НовыеДанные.ОграничениеИспользованияГруппировка, НовыеДанные.ОграничениеИспользованияПорядок);
			
		//Appearance
		СкопироватьОфорление(НовыеДанные.Appearance, ТекДанные.Appearance);

		НовыеДанные.AvailableValues=ТекДанные.GetAvailableValues();
	EndDo;
EndProcedure

&AtServer
Procedure ПрочитатьПоляИтоговСКДВДанныеФормы(СКД)
	Resources.Clear();

	For Each ТекДанные In СКД.TotalFields Do
		НовыеДанные=Resources.Add();
		FillPropertyValues(НовыеДанные, ТекДанные, , "Groups");

		For Each Item In ТекДанные.Groups Do
			НовыеДанные.Groups.Add(Item);
		EndDo;
	EndDo;
EndProcedure
&AtServer
Procedure ПрочитатьПараметрыСКДВДанныеФормы(СКД)
	DCSParameters.Clear();

	For Each ТекДанные In СКД.Parameters Do
		НовыеДанные=DCSParameters.Add();
		FillPropertyValues(НовыеДанные, ТекДанные, , "EditParameters");

		НовыеДанные.UseAlways=ТекДанные.Use = DataCompositionParameterUse.Always;

		НовыеДанные.AvailableValues=ТекДанные.GetAvailableValues();
	EndDo;
EndProcedure

&AtServer
Procedure ПрочитатьВариантыНастроекСКДВДанныеФормы(СКД)
	SettingVariants.Clear();

	For Each СтрокаВарианта In СКД.SettingVariants Do
		НовыеДанные=SettingVariants.Add();
		НовыеДанные.Name=СтрокаВарианта.Name;
		НовыеДанные.Presentation=СтрокаВарианта.Presentation;
		НовыеДанные.Settings=UT_Common.ValueToXMLString(СтрокаВарианта.Settings);
	EndDo;

	ИдентификаторСтрокиТекущегоВариантаНастроек=SettingVariants[0].GetID();

	CurrentSettingsComposer.LoadSettings(СтрокаВарианта.Settings);
EndProcedure

&AtServer
Procedure ПрочитатьСКДВДанныеФормы(СКД)
	If IsTempStorageURL(АдресПервоначальнойСхемыКомпоновкиДанных) Then
		АдресПервоначальнойСхемыКомпоновкиДанных=PutToTempStorage(СКД,
			АдресПервоначальнойСхемыКомпоновкиДанных);
	Else
		АдресПервоначальнойСхемыКомпоновкиДанных=PutToTempStorage(СКД, UUID);
	EndIf;

	ПрочитатьПараметрыСКДВДанныеФормы(СКД);
	ПрочитатьИсточникиДанныхСКДВДанныеФормы(СКД);
	ПрочитатьНаборыДанныхСКДВДанныеФормы(СКД.DataSets);
	ПрочитатьСвязиНаборовДанныхСКДВДанныеФормы(СКД);

	ПрочитатьВычисляемыеПоляСКДВДанныеФормы(СКД);
	ПрочитатьПоляИтоговСКДВДанныеФормы(СКД);

	ПрочитатьВариантыНастроекСКДВДанныеФормы(СКД);

EndProcedure

&AtServer
Procedure ЗаполнитьИсточникиДанныхСКДПоДаннымФормы(СКД)
	СКД.DataSources.Clear();

	For Each ТекИсточник In DataSources Do
		НовыйИсточник=СКД.DataSources.Add();
		FillPropertyValues(НовыйИсточник, ТекИсточник);
	EndDo;
EndProcedure

&AtServer
Procedure ЗаполнитьОграничениеИспользованияПоляСхемыКомпоновкиДанных(UseRestriction, Field, Condition, Group,
	Order)

	UseRestriction.Field=Field;
	UseRestriction.Condition=Condition;
	UseRestriction.Group=Group;
	UseRestriction.Order=Order;
EndProcedure

&AtServer
Procedure СкопироватьОфорление(ОформлениеПриемник, ОформлениеИсточник)
	For Each ТекПараметрОформления In ОформлениеИсточник.Items Do
		ЗначениеПараметра=ОформлениеПриемник.FindParameterValue(ТекПараметрОформления.Parameter);
		If ЗначениеПараметра = Undefined Then
			Continue;
		EndIf;

		FillPropertyValues(ЗначениеПараметра, ТекПараметрОформления);
	EndDo;

EndProcedure

&AtServer
Function НоваяСтруктураРедактированияРолиПоляНабораДанных()
	Role=New Structure;
	Role.Insert("AccountTypeExpression", "");
	Role.Insert("BalanceGroup", "");
	Role.Insert("IgnoreNULLValues", False);
	Role.Insert("Dimension", False);
	Role.Insert("Period", False);
	Role.Insert("PeriodNumber", 0);
	Role.Insert("Required", False);
	Role.Insert("Balance", False);
	Role.Insert("AccountField", "");
	Role.Insert("ParentDimension", "");
	Role.Insert("Account", False);
	Role.Insert("AccountingBalanceType", "None");
	Role.Insert("BalanceType", "None");
	Role.Insert("ПериодДополнительный", False);

	Return Role;
EndFunction

&AtServer
Procedure ЗаполнитьРольПоляНабораДанныхПоДаннымФормы(РольНабора, РольРедактора)
	If РольРедактора = Undefined Then
		РольРедактора=НоваяСтруктураРедактированияРолиПоляНабораДанных();
	EndIf;

	FillPropertyValues(РольНабора, РольРедактора, , "AccountingBalanceType,BalanceType");
	РольНабора.AccountingBalanceType=DataCompositionAccountingBalanceType[РольРедактора.AccountingBalanceType];
	РольНабора.BalanceType=DataCompositionBalanceType[РольРедактора.BalanceType];

	If РольРедактора.ПериодДополнительный Then
		РольНабора.PeriodType=DataCompositionPeriodType.Additional;
	Else
		РольНабора.PeriodType=DataCompositionPeriodType.Main;
	EndIf;

	If Not РольРедактора.Period Then
		РольНабора.PeriodNumber=0;
	EndIf;
EndProcedure

&AtServer
Procedure ЗаполнитьПоляНабораСКДПоДаннымФормы(НовыйНабор, СтрокаНабора)
	НовыйНабор.Fields.Clear();
	ВидыПолей=ВидыПолейНаборовДанных();

	For Each СтрокаПоля In СтрокаНабора.Fields Do
		НовоеПоле=НовыйНабор.Fields.Add(Type(СтрокаПоля.Type));
		If СтрокаПоля.Type = ВидыПолей.Field Then
			FillPropertyValues(НовоеПоле, СтрокаПоля, , "Appearance,EditParameters,Role");
			
			//Appearance
			СкопироватьОфорление(НовоеПоле.Appearance, СтрокаПоля.Appearance);

			ЗаполнитьРольПоляНабораДанныхПоДаннымФормы(НовоеПоле.Role, СтрокаПоля.Role);
			УстановитьДоступныеЗначенияУЭлементаСКД(НовоеПоле, СтрокаПоля.AvailableValues);

			ЗаполнитьОграничениеИспользованияПоляСхемыКомпоновкиДанных(НовоеПоле.AttributeUseRestriction,
				СтрокаПоля.ОграничениеИспользованияРеквизитовПоле, СтрокаПоля.ОграничениеИспользованияРеквизитовУсловие,
				СтрокаПоля.ОграничениеИспользованияРеквизитовГруппировка,
				СтрокаПоля.ОграничениеИспользованияРеквизитовПорядок);

		Else
			FillPropertyValues(НовоеПоле, СтрокаПоля);
		EndIf;

		If СтрокаПоля.Type <> ВидыПолей.Set Then
			ЗаполнитьОграничениеИспользованияПоляСхемыКомпоновкиДанных(НовоеПоле.UseRestriction,
				СтрокаПоля.ОграничениеИспользованияПоле, СтрокаПоля.ОграничениеИспользованияУсловие,
				СтрокаПоля.ОграничениеИспользованияГруппировка, СтрокаПоля.ОграничениеИспользованияПорядок);
		EndIf;
	EndDo;
EndProcedure
&AtServer
Procedure ЗаполнитьНаборыДанныхСКДПоДаннымФормы(СКДНаборыДанных, СтрокаРодительскогоНабора = Undefined)
//	СКД=Новый СхемаКомпоновкиДанных;
	If СтрокаРодительскогоНабора = Undefined Then

		СтрокаНабораДляКопирования=DataSets.FindByID(ИдентификаторНулевогоНабораДанных);
	Else
		СтрокаНабораДляКопирования=СтрокаРодительскогоНабора;
	EndIf;

	СКДНаборыДанных.Clear();

	For Each СтрокаНабора In СтрокаНабораДляКопирования.GetItems() Do
		НовыйНабор=СКДНаборыДанных.Add(Type(СтрокаНабора.Type));
		FillPropertyValues(НовыйНабор, СтрокаНабора, , "Fields");

		ЗаполнитьПоляНабораСКДПоДаннымФормы(НовыйНабор, СтрокаНабора);

		If TypeOf(НовыйНабор) = Type("DataCompositionSchemaDataSetUnion") Then
			ЗаполнитьНаборыДанныхСКДПоДаннымФормы(НовыйНабор.Items, СтрокаНабора);
		EndIf;

	EndDo;
EndProcedure

&AtServer
Procedure ЗаполнитьСвязиНаборовДанныхСКДПоДаннымФормы(СКД)
	СКД.DataSetLinks.Clear();

	For Each ТекДанные In DataSetLinks Do
		НовыеДанные=СКД.DataSetLinks.Add();
		FillPropertyValues(НовыеДанные, ТекДанные);
	EndDo;
EndProcedure

&AtServer
Procedure ЗаполнитьВычисляемыеПоляСКДПоДаннымФормы(СКД)
	СКД.CalculatedFields.Clear();

	For Each ТекДанные In CalculatedFields Do
		НовыеДанные=СКД.CalculatedFields.Add();
		FillPropertyValues(НовыеДанные, ТекДанные, , "OrderExpressions,Appearance,EditParameters");

		ЗаполнитьОграничениеИспользованияПоляСхемыКомпоновкиДанных(НовыеДанные.UseRestriction,
			ТекДанные.UseRestrictionField, ТекДанные.UseRestrictionCondition,
			ТекДанные.UseRestrictionGroup, ТекДанные.ОграничениеИспользованияПорядок);
			
		//Appearance
		СкопироватьОфорление(НовыеДанные.Appearance, ТекДанные.Appearance);

		УстановитьДоступныеЗначенияУЭлементаСКД(НовыеДанные, ТекДанные.AvailableValues);
	EndDo;
EndProcedure
&AtServer
Procedure ЗаполнитьПоляИтоговСКДПоДаннымФормы(СКД)
	СКД.TotalFields.Clear();

	For Each ТекДанные In Resources Do
		НовыеДанные=СКД.TotalFields.Add();
		FillPropertyValues(НовыеДанные, ТекДанные, , "Groups");

		For Each Item In ТекДанные.Groups Do
			НовыеДанные.Groups.Add(Item.Value);
		EndDo;
	EndDo;
EndProcedure
&AtServer
Procedure ЗаполнитьПараметрыСКДПоДаннымФормы(СКД)
	СКД.Parameters.Clear();

	For Each ТекДанные In DCSParameters Do
		НовыеДанные=СКД.Parameters.Add();
		FillPropertyValues(НовыеДанные, ТекДанные, , "EditParameters");

		If ТекДанные.UseAlways Then
			НовыеДанные.Use=DataCompositionParameterUse.Always;
		Else
			НовыеДанные.Use=DataCompositionParameterUse.Auto;
		EndIf;

		УстановитьДоступныеЗначенияУЭлементаСКД(НовыеДанные, ТекДанные.AvailableValues);
	EndDo;
EndProcedure

&AtServer
Procedure УстановитьДоступныеЗначенияУЭлементаСКД(Item, AvailableValues)
	If AvailableValues.Count() = 0 Then
//		Элемент.УстановитьДоступныеЗначения(AvailableValues);
//	Иначе
		Item.SetAvailableValues(AvailableValues);
	EndIf;

EndProcedure

&AtServer
Procedure ЗаполнитьВариантыНастроекСКДПоДаннымФормы(СКД)
	СКД.SettingVariants.Clear();

	For Each СтрокаВарианта In SettingVariants Do
		НовыеДанные=СКД.SettingVariants.Add();
		НовыеДанные.Name=СтрокаВарианта.Name;
		НовыеДанные.Presentation=СтрокаВарианта.Presentation;
		If ValueIsFilled(СтрокаВарианта.Settings) Then
			UT_CommonClientServer.CopyDataCompositionSettings(НовыеДанные.Settings,
				UT_Common.ValueFromXMLString(СтрокаВарианта.Settings));
		EndIf;
	EndDo;
EndProcedure
&AtServer
Procedure СобратьСКДПоДаннымФормы(ВключитьВариантыНастроек = False)
	If IsTempStorageURL(АдресПервоначальнойСхемыКомпоновкиДанных) Then
		СКД=GetFromTempStorage(АдресПервоначальнойСхемыКомпоновкиДанных);
		If TypeOf(СКД) <> Type("DataCompositionSchema") Then
			СКД=New DataCompositionSchema;
		EndIf;
	Else
		СКД=New DataCompositionSchema;
	EndIf;
	ЗаполнитьИсточникиДанныхСКДПоДаннымФормы(СКД);
	ЗаполнитьНаборыДанныхСКДПоДаннымФормы(СКД.DataSets);
	ЗаполнитьСвязиНаборовДанныхСКДПоДаннымФормы(СКД);
	ЗаполнитьВычисляемыеПоляСКДПоДаннымФормы(СКД);
	ЗаполнитьПоляИтоговСКДПоДаннымФормы(СКД);
	ЗаполнитьПараметрыСКДПоДаннымФормы(СКД);

	If ВключитьВариантыНастроек Then
		СохранитьВТаблицуФормыНастройкуТекущегоВариантаНастроек();
		ЗаполнитьВариантыНастроекСКДПоДаннымФормы(СКД);
	EndIf;

	If IsTempStorageURL(АдресСхемыКомпоновкиДанных) Then
		АдресСхемыКомпоновкиДанных=PutToTempStorage(СКД, АдресСхемыКомпоновкиДанных);
	Else
		АдресСхемыКомпоновкиДанных=PutToTempStorage(СКД, UUID);
	EndIf;

	ИнициализироватьКомпоновщикНастроекПоСобраннойСКД();
EndProcedure



#EndRegion

#EndRegion
ВидыНаборовДанных=ВидыНаборовДанных();
ВидыПолейНаборовДанных=ВидыПолейНаборовДанных();