//Признак использования настроек
&AtClient
Var мИспользоватьНастройки Export;

//Types объектов, для которых может использоваться обработка.
//To умолчанию для всех.
&AtClient
Var мТипыОбрабатываемыхОбъектов Export;

&AtClient
Var мНастройка;

////////////////////////////////////////////////////////////////////////////////
// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ And ФУНКЦИИ

// Определяет и устанавливает Type и Длинну номера объекта
//
// Parameters:
//  None.
//
&AtServer
Procedure ОпределитьТипИДлиннуНомера()
	ИмяТипаОбъектов = ОбъектПоиска.Type;
	ОбъектМетаданных = Metadata.FindByFullName(ОбъектПоиска.Type + "." + ОбъектПоиска.Name);
	If ИмяТипаОбъектов = "Document" Then
		NumberType   = String(ОбъектМетаданных.NumberType);
		NumberLength = ОбъектМетаданных.NumberLength;
	ElsIf ИмяТипаОбъектов = "Catalog" Then
		NumberType   = String(ОбъектМетаданных.CodeType);
		NumberLength = ОбъектМетаданных.CodeLength;
	EndIf;
EndProcedure // ()

// Выполняет обработку объектов.
//
// Parameters:
//  Object                 - обрабатываемый объект.
//  ПорядковыйНомерОбъекта - порядковый номер обрабатываемого объекта.
//
&AtServer
Procedure ОбработатьОбъект(Reference, ind, НеУникальныеНомера, МаксимальныйНомер, ЧисловаяЧастьНомера,
	ПараметрыЗаписиОбъектов)

	Object = Reference.GetObject();

	If NumberType = "Number" Then
		If Not НеИзменятьЧисловуюНумерацию Then
			If ИмяТипаОбъектов = "Document" Then
				Object.Number = ЧисловаяЧастьНомера;
			Else
				Object.Code = ЧисловаяЧастьНомера;
			EndIf;
			If Not UT_Common.WriteObjectToDB(Object, ПараметрыЗаписиОбъектов) Then
				If ИмяТипаОбъектов = "Document" Then
					Object.Number = МаксимальныйНомер - Сч;
				Else
					Object.Code = МаксимальныйНомер - Сч;
				EndIf;
				//				Object.Write();

				If Not UT_Common.WriteObjectToDB(Object, ПараметрыЗаписиОбъектов) Then
					Raise "Error обработки номеров объектов";
				EndIf;
				НеУникальныеНомера.Insert(ЧисловаяЧастьНомера, Object.Reference);
			EndIf;
//			Try
//				Object.Write();
//			Except
//				If ИмяТипаОбъектов = "Document" Then
//					Object.Number = МаксимальныйНомер - Сч;
//				Else
//					Object.Code = МаксимальныйНомер - Сч;
//				EndIf; 
//				Object.Write();
//				НеУникальныеНомера.Insert(ЧисловаяЧастьНомера, Object.Reference);
//			EndTry;		
			ЧисловаяЧастьНомера = ЧисловаяЧастьНомера + 1;
		EndIf;
		Return;
	EndIf;
	If ИмяТипаОбъектов = "Document" Then
		ТекНомер = TrimAll(Object.Number);
	Else
		ТекНомер = TrimAll(Object.Code);
	EndIf;

	If НеИзменятьЧисловуюНумерацию Then
		СтроковаяЧастьНомера = ПолучитьПрефиксЧислоНомера(ТекНомер, ЧисловаяЧастьНомера);
	Else
		СтроковаяЧастьНомера = ПолучитьПрефиксЧислоНомера(ТекНомер);
	EndIf;
	If СпособОбработкиПрефиксов = 1 Then
		НовыйНомер = СтроковаяЧастьНомера;
	ElsIf СпособОбработкиПрефиксов = 2 Then
		НовыйНомер = TrimAll(СтрокаПрефикса);
	ElsIf СпособОбработкиПрефиксов = 3 Then
		НовыйНомер = TrimAll(СтрокаПрефикса) + СтроковаяЧастьНомера;
	ElsIf СпособОбработкиПрефиксов = 4 Then
		НовыйНомер = СтроковаяЧастьНомера + TrimAll(СтрокаПрефикса);
	ElsIf СпособОбработкиПрефиксов = 5 Then
		НовыйНомер = StrReplace(СтроковаяЧастьНомера, TrimAll(ЗаменяемаяПодстрока), TrimAll(СтрокаПрефикса));
	EndIf;

	While NumberLength - StrLen(НовыйНомер) - StrLen(Format(ЧисловаяЧастьНомера, "ЧГ=0")) > 0 Do
		НовыйНомер = НовыйНомер + "0";
	EndDo;

	НовыйНомер 	 = НовыйНомер + Format(ЧисловаяЧастьНомера, "ЧГ=0");

	If ИмяТипаОбъектов = "Document" Then
		Object.Number = НовыйНомер;
	Else
		Object.Code = НовыйНомер;
	EndIf;

	If Not UT_Common.WriteObjectToDB(Object, ПараметрыЗаписиОбъектов) Then
		If ИмяТипаОбъектов = "Document" Then
			Object.Number = Format(МаксимальныйНомер - Сч, "ЧГ=0");
		Else
			Object.Code = Format(МаксимальныйНомер - Сч, "ЧГ=0");
		EndIf; 
//		Object.Write();			
		If Not UT_Common.WriteObjectToDB(Object, ПараметрыЗаписиОбъектов) Then
			Raise "Error обработки номеров объектов";
		EndIf;
		НеУникальныеНомера.Insert(НовыйНомер, Object.Reference);

	EndIf;
//	Try
//		Object.Write();
//	Except
//		If ИмяТипаОбъектов = "Document" Then
//			Object.Number = Format(МаксимальныйНомер - Сч, "ЧГ=0");
//		Else
//			Object.Code = Format(МаксимальныйНомер - Сч, "ЧГ=0");
//		EndIf;
//		Object.Write();
//		НеУникальныеНомера.Insert(НовыйНомер, Object.Reference);
//	EndTry;

	If Not НеИзменятьЧисловуюНумерацию Then
		ЧисловаяЧастьНомера = ЧисловаяЧастьНомера + 1;
	EndIf;

EndProcedure // ОбработатьОбъект()

&AtServer
Procedure ПроверитьНеУникальныеНомера(НеУникальныеНомера, ПараметрыЗаписиОбъектов)
	For Each Зн In НеУникальныеНомера Do
		НовыйНомер   = Зн.Key;
		Object       = Зн.Value.GetObject();
		If ИмяТипаОбъектов = "Document" Then
			Object.Number = НовыйНомер;
		Else
			Object.Code = НовыйНомер;
		EndIf;
		If Not UT_Common.WriteObjectToDB(Object, ПараметрыЗаписиОбъектов) Then
			UT_CommonClientServer.MessageToUser(StrTemplate(
				"Повтор номера: %1 за пределами данной выборки!", НовыйНомер));
		EndIf;
//		Try
//			Object.Write();
//		Except
//			Message("Повтор номера: " + НовыйНомер + " за пределами данной выборки!");
//		EndTry;
	EndDo;
EndProcedure

// Выполняет обработку объектов.
//
// Parameters:
//  None.
//
&AtClient
Function ExecuteProcessing(ПараметрыЗаписиОбъектов) Export
	ОпределитьТипИДлиннуНомера();
	If (СпособОбработкиПрефиксов = 1) And (НеИзменятьЧисловуюНумерацию) Then
		Return 0;
	EndIf;

	If (НачальныйНомер = 0) And (Not НеИзменятьЧисловуюНумерацию) Then
		ShowMessageBox( , "Измените начальный номер!");
		Return 0;
	EndIf;

	If Not НеИзменятьЧисловуюНумерацию Then
		ЧисловаяЧастьНомера = НачальныйНомер;
	EndIf;

	НеУникальныеНомера = New Map;
	МаксимальныйНомер  = Number(ДополнитьСтрокуСимволами("", NumberLength, "9"));

	Indicator = ПолучитьИндикаторПроцесса(НайденныеОбъекты.Count());
	For ind = 0 To НайденныеОбъекты.Count() - 1 Do
		ОбработатьИндикатор(Indicator, ind + 1);

		Object = НайденныеОбъекты.Get(ind).Value;
		ОбработатьОбъект(Object, ind, НеУникальныеНомера, МаксимальныйНомер, ЧисловаяЧастьНомера,
			ПараметрыЗаписиОбъектов);
	EndDo;

	ПроверитьНеУникальныеНомера(НеУникальныеНомера, ПараметрыЗаписиОбъектов);

	If ind > 0 Then
		NotifyChanged(Type(ОбъектПоиска.Type + "Reference." + ОбъектПоиска.Name));
	EndIf;

	Return ind;
EndFunction // вВыполнитьОбработку()

// Сохраняет значения реквизитов формы.
//
// Parameters:
//  None.
//
&AtClient
Procedure СохранитьНастройку() Export

	If IsBlankString(ТекущаяНастройкаПредставление) Then
		ShowMessageBox( ,
			"Задайте имя новой настройки для сохранения или выберите существующую настройку для перезаписи.");
	EndIf;

	НоваяНастройка = New Structure;
	НоваяНастройка.Insert("Processing", ТекущаяНастройкаПредставление);
	НоваяНастройка.Insert("Прочее", New Structure);

	For Each РеквизитНастройки In мНастройка Do
		Execute ("НоваяНастройка.Прочее.Insert(String(РеквизитНастройки.Key), " + String(РеквизитНастройки.Key)
			+ ");");
	EndDo;

	ДоступныеОбработки = ThisForm.FormOwner.ДоступныеОбработки;
	ТекущаяДоступнаяНастройка = Undefined;
	For Each ТекущаяДоступнаяНастройка In ДоступныеОбработки.GetItems() Do
		If ТекущаяДоступнаяНастройка.GetID() = Parent Then
			Break;
		EndIf;
	EndDo;

	If ТекущаяНастройка = Undefined Or Not ТекущаяНастройка.Processing = ТекущаяНастройкаПредставление Then
		If ТекущаяДоступнаяНастройка <> Undefined Then
			NewLine = ТекущаяДоступнаяНастройка.GetItems().Add();
			NewLine.Processing = ТекущаяНастройкаПредставление;
			NewLine.Setting.Add(НоваяНастройка);

			ThisForm.FormOwner.Items.ДоступныеОбработки.CurrentLine = NewLine.GetID();
		EndIf;
	EndIf;

	If ТекущаяДоступнаяНастройка <> Undefined And CurrentLine > -1 Then
		For Each ТекНастройка In ТекущаяДоступнаяНастройка.GetItems() Do
			If ТекНастройка.GetID() = CurrentLine Then
				Break;
			EndIf;
		EndDo;

		If ТекНастройка.Setting.Count() = 0 Then
			ТекНастройка.Setting.Add(НоваяНастройка);
		Else
			ТекНастройка.Setting[0].Value = НоваяНастройка;
		EndIf;
	EndIf;

	ТекущаяНастройка = НоваяНастройка;
	ThisForm.Modified = False;
EndProcedure // вСохранитьНастройку()

// Восстанавливает сохраненные значения реквизитов формы.
//
// Parameters:
//  None.
//
&AtClient
Procedure ЗагрузитьНастройку() Export

	If Items.ТекущаяНастройка.ChoiceList.Count() = 0 Then
		УстановитьИмяНастройки("Новая настройка");
	Else
		If Not ТекущаяНастройка.Прочее = Undefined Then
			мНастройка = ТекущаяНастройка.Прочее;
		EndIf;
	EndIf;

	For Each РеквизитНастройки In мНастройка Do
		//@skip-warning
		Value = мНастройка[РеквизитНастройки.Key];
		Execute (String(РеквизитНастройки.Key) + " = Value;");
	EndDo;

	СпособОбработкиПрефиксовПриИзменении("");
	НеИзменятьЧисловуюНумерациюПриИзменении("");
EndProcedure //вЗагрузитьНастройку()

// Устанавливает значение реквизита "ТекущаяНастройка" по имени настройки или произвольно.
//
// Parameters:
//  ИмяНастройки   - произвольное имя настройки, которое необходимо установить.
//
&AtClient
Procedure УстановитьИмяНастройки(ИмяНастройки = "") Export

	If IsBlankString(ИмяНастройки) Then
		If ТекущаяНастройка = Undefined Then
			ТекущаяНастройкаПредставление = "";
		Else
			ТекущаяНастройкаПредставление = ТекущаяНастройка.Processing;
		EndIf;
	Else
		ТекущаяНастройкаПредставление = ИмяНастройки;
	EndIf;

EndProcedure // вУстановитьИмяНастройки()

// Получает структуру для индикации прогресса цикла.
//
// Parameters:
//  КоличествоПроходов - Number - максимальное значение счетчика;
//  ПредставлениеПроцесса - String, "Выполнено" - отображаемое название процесса;
//  ВнутреннийСчетчик - Boolean, *True - использовать внутренний счетчик с начальным значением 1,
//                    иначе нужно будет передавать значение счетчика при каждом вызове обновления индикатора;
//  КоличествоОбновлений - Number, *100 - всего количество обновлений индикатора;
//  ЛиВыводитьВремя - Boolean, *True - выводить приблизительное время до окончания процесса;
//  РазрешитьПрерывание - Boolean, *True - разрешает пользователю прерывать процесс.
//
// Возвращаемое значение:
//  Structure - которую потом нужно будет передавать в метод ЛксОбработатьИндикатор.
//
&AtClient
Function ПолучитьИндикаторПроцесса(КоличествоПроходов, ПредставлениеПроцесса = "Выполнено", ВнутреннийСчетчик = True,
	КоличествоОбновлений = 100, ЛиВыводитьВремя = True, РазрешитьПрерывание = True) Export

	Indicator = New Structure;
	Indicator.Insert("КоличествоПроходов", КоличествоПроходов);
	Indicator.Insert("ДатаНачалаПроцесса", CurrentDate());
	Indicator.Insert("ПредставлениеПроцесса", ПредставлениеПроцесса);
	Indicator.Insert("ЛиВыводитьВремя", ЛиВыводитьВремя);
	Indicator.Insert("РазрешитьПрерывание", РазрешитьПрерывание);
	Indicator.Insert("ВнутреннийСчетчик", ВнутреннийСчетчик);
	Indicator.Insert("Step", КоличествоПроходов / КоличествоОбновлений);
	Indicator.Insert("СледующийСчетчик", 0);
	Indicator.Insert("Счетчик", 0);
	Return Indicator;

EndFunction // ЛксПолучитьИндикаторПроцесса()

// Проверяет и обновляет индикатор. Нужно вызывать на каждом проходе индицируемого цикла.
//
// Parameters:
//  Indicator    - Structure - индикатора, полученная методом ЛксПолучитьИндикаторПроцесса;
//  Счетчик      - Number - внешний счетчик цикла, используется при ВнутреннийСчетчик = False.
//
&AtClient
Procedure ОбработатьИндикатор(Indicator, Счетчик = 0) Export

	If Indicator.ВнутреннийСчетчик Then
		Indicator.Счетчик = Indicator.Счетчик + 1;
		Счетчик = Indicator.Счетчик;
	EndIf;
	If Indicator.РазрешитьПрерывание Then
		UserInterruptProcessing();
	EndIf;

	If Счетчик > Indicator.СледующийСчетчик Then
		Indicator.СледующийСчетчик = Int(Счетчик + Indicator.Step);
		If Indicator.ЛиВыводитьВремя Then
			ПрошлоВремени = CurrentDate() - Indicator.ДатаНачалаПроцесса;
			Осталось = ПрошлоВремени * (Indicator.КоличествоПроходов / Счетчик - 1);
			Часов = Int(Осталось / 3600);
			Осталось = Осталось - (Часов * 3600);
			Минут = Int(Осталось / 60);
			Секунд = Int(Int(Осталось - (Минут * 60)));
			ОсталосьВремени = Format(Часов, "ЧЦ=2; ЧН=00; ЧВН=") + ":" + Format(Минут, "ЧЦ=2; ЧН=00; ЧВН=") + ":"
				+ Format(Секунд, "ЧЦ=2; ЧН=00; ЧВН=");
			ТекстОсталось = "Осталось: ~" + ОсталосьВремени;
		Else
			ТекстОсталось = "";
		EndIf;

		If Indicator.КоличествоПроходов > 0 Then
			ТекстСостояния = ТекстОсталось;
		Else
			ТекстСостояния = "";
		EndIf;

		Status(Indicator.ПредставлениеПроцесса, Счетчик / Indicator.КоличествоПроходов * 100, ТекстСостояния);
	EndIf;

	If Счетчик = Indicator.КоличествоПроходов Then
		Status(Indicator.ПредставлениеПроцесса, 100, ТекстСостояния);
	EndIf;

EndProcedure // ЛксОбработатьИндикатор()

// Разбирает строку выделяя из нее префикс и числовую часть
//
// Parameters:
//  Стр            - String. Разбираемая строка
//  ЧисловаяЧасть  - Number. Variable в которую возвратится числовая часть строки
//  Mode          - String. If "Number", то возвратит числовую часть иначе - префикс
//
// Возвращаемое значение:
//  Prefix строки
//              
&AtServer
Function ПолучитьПрефиксЧислоНомера(Val Стр, ЧисловаяЧасть = "", Mode = "") Export

	Стр		=	TrimAll(Стр);
	Prefix	=	Стр;
	Length	=	StrLen(Стр);

	For Сч = 1 To Length Do
		Try
			ЧисловаяЧасть = Number(Стр);
		Except
			Стр = Right(Стр, Length - Сч);
			Continue;
		EndTry;

		If (ЧисловаяЧасть > 0) And (StrLen(Format(ЧисловаяЧасть, "ЧГ=0")) = Length - Сч + 1) Then
			Prefix	=	Left(Prefix, Сч - 1);

			While Right(Prefix, 1) = "0" Do
				Prefix = Left(Prefix, StrLen(Prefix) - 1);
			EndDo;

			Break;
		Else
			Стр = Right(Стр, Length - Сч);
		EndIf;

		If ЧисловаяЧасть < 0 Then
			ЧисловаяЧасть = -ЧисловаяЧасть;
		EndIf;

	EndDo;

	If Mode = "Number" Then
		Return (ЧисловаяЧасть);
	Else
		Return (Prefix);
	EndIf;

EndFunction // вПолучитьПрефиксЧислоНомера()

// Приводит номер (код) к требуемой длине. При этом выделяется префикс
// и числовая часть номера, остальное пространство между префиксом и
// номером заполняется нулями
//
// Parameters:
//  Стр            - Преобразовываемая строка
//  Length          - Требуемая длина строки
//
// Возвращаемое значение:
//  String - код или номер, приведенная к требуемой длине
// 
&AtServer
Function ПривестиНомерКДлине(Val Стр, Length) Export

	Стр			    =	TrimAll(Стр);

	ЧисловаяЧасть	=	"";
	Result		=	ПолучитьПрефиксЧислоНомера(Стр, ЧисловаяЧасть);
	While Length - StrLen(Result) - StrLen(Format(ЧисловаяЧасть, "ЧГ=0")) > 0 Do
		Result	=	Result + "0";
	EndDo;
	Result	=	Result + Format(ЧисловаяЧасть, "ЧГ=0");

	Return (Result);

EndFunction // вПривестиНомерКДлине()

// Добавляет к префиксу номера или кода подстроку
//
// Parameters:
//  Стр            - String. Number или код
//  Добавок        - Добаляемая к префиксу подстрока
//  Length          - Требуемая результрирубщая длина строки
//  Mode          - "Left" - подстрока добавляется слева к префиксу, иначе - справа
//
// Возвращаемое значение:
//  String - номер или код, к префиксу которого добавлена указанная подстрока
//                                                                                                     
&AtServer
Function ДобавитьКПрефиксу(Val Стр, Добавок = "", Length = "", Mode = "Left") Export

	Стр = TrimAll(Стр);

	If IsBlankString(Length) Then
		Length = StrLen(Стр);
	EndIf;

	ЧисловаяЧасть	=	"";
	Prefix			=	ПолучитьПрефиксЧислоНомера(Стр, ЧисловаяЧасть);
	If Mode = "Left" Then
		Result	=	TrimAll(Добавок) + Prefix;
	Else
		Result	=	Prefix + TrimAll(Добавок);
	EndIf;

	While Length - StrLen(Result) - StrLen(Format(ЧисловаяЧасть, "ЧГ=0")) > 0 Do
		Result	=	Result + "0";
	EndDo;
	Result	=	Result + Format(ЧисловаяЧасть, "ЧГ=0");

	Return (Result);

EndFunction // вДобавитьКПрефиксу()

// Дополняет строку указанным символом до указанной длины
//
// Parameters: 
//  Стр            - Дополняемая строка
//  Length          - Требуемая длина результирующей строки
//  Чем            - Char, которым дополняется строка
//
// Возвращаемое значение:
//  String дополненная указанным символом до указанной длины
//
&AtServer
Function ДополнитьСтрокуСимволами(Стр = "", Length, Чем = " ") Export
	Result = TrimAll(Стр);
	While Length - StrLen(Result) > 0 Do
		Result	=	Result + Чем;
	EndDo;
	Return (Result);
EndFunction // вДополнитьСтрокуСимволами() 

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&AtClient
Procedure OnOpen(Cancel)
	ОпределитьТипИДлиннуНомера();
	If NumberType <> "String" Then
		Items.ПрефиксыНомеров.Visible = False;
	EndIf;

	If мИспользоватьНастройки Then
		УстановитьИмяНастройки();
		ЗагрузитьНастройку();
	Else
		Items.ТекущаяНастройка.Enabled = False;
		Items.СохранитьНастройки.Enabled = False;
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Property("Setting") Then
		ТекущаяНастройка = Parameters.Setting;
	EndIf;
	If Parameters.Property("НайденныеОбъекты") Then
		НайденныеОбъекты.LoadValues(Parameters.НайденныеОбъекты);
	EndIf;
	CurrentLine = -1;
	If Parameters.Property("CurrentLine") Then
		If Parameters.CurrentLine <> Undefined Then
			CurrentLine = Parameters.CurrentLine;
		EndIf;
	EndIf;
	If Parameters.Property("Parent") Then
		Parent = Parameters.Parent;
	EndIf;

	If Parameters.Property("ТабличноеПолеВидыОбъектов") Then

		Стр=Parameters.ТабличноеПолеВидыОбъектов[0];

		ОбъектПоиска = New Structure;
		ОбъектПоиска.Insert("Type", ?(Parameters.ObjectType = 0, "Catalog", "Document"));
		ОбъектПоиска.Insert("Name", Стр.TableName);
		ОбъектПоиска.Insert("Presentation", Стр.ПредставлениеТаблицы);

	EndIf;

	Items.ТекущаяНастройка.ChoiceList.Clear();
	If Parameters.Property("Settings") Then
		For Each String In Parameters.Settings Do
			Items.ТекущаяНастройка.ChoiceList.Add(String, String.Processing);
		EndDo;
	EndIf;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ, ВЫЗЫВАЕМЫЕ ИЗ ЭЛЕМЕНТОВ ФОРМЫ

&AtClient
Procedure ВыполнитьОбработкуКоманда(Command)
	ОбработаноОбъектов = ExecuteProcessing(UT_CommonClientServer.FormWriteSettings(
		ThisObject.FormOwner));

	ShowMessageBox( , "Processing <" + TrimAll(ThisForm.Title) + "> завершена!
																		   |Обработано объектов: " + ОбработаноОбъектов
		+ ".");
EndProcedure

&AtClient
Procedure СохранитьНастройкиКоманда(Command)
	СохранитьНастройку();
EndProcedure

&AtClient
Procedure ТекущаяНастройкаОбработкаВыбора(Item, ВыбранноеЗначение, StandardProcessing)
	StandardProcessing = False;

	If Not ТекущаяНастройка = ВыбранноеЗначение Then

		If ThisForm.Modified Then
			ShowQueryBox(New NotifyDescription("ТекущаяНастройкаОбработкаВыбораЗавершение", ThisForm,
				New Structure("ВыбранноеЗначение", ВыбранноеЗначение)), "Save текущую настройку?",
				QuestionDialogMode.YesNo, , DialogReturnCode.Yes);
			Return;
		EndIf;

		ТекущаяНастройкаОбработкаВыбораФрагмент(ВыбранноеЗначение);

	EndIf;
EndProcedure

&AtClient
Procedure ТекущаяНастройкаОбработкаВыбораЗавершение(РезультатВопроса, AdditionalParameters) Export

	ВыбранноеЗначение = AdditionalParameters.ВыбранноеЗначение;
	If РезультатВопроса = DialogReturnCode.Yes Then
		СохранитьНастройку();
	EndIf;

	ТекущаяНастройкаОбработкаВыбораФрагмент(ВыбранноеЗначение);

EndProcedure

&AtClient
Procedure ТекущаяНастройкаОбработкаВыбораФрагмент(Val ВыбранноеЗначение)

	ТекущаяНастройка = ВыбранноеЗначение;
	УстановитьИмяНастройки();

	ЗагрузитьНастройку();

EndProcedure

&AtClient
Procedure ТекущаяНастройкаПриИзменении(Item)
	ThisForm.Modified = True;
EndProcedure

&AtClient
Procedure НеИзменятьЧисловуюНумерациюПриИзменении(Item)
	Items.НачальныйНомер.Enabled = Not НеИзменятьЧисловуюНумерацию;
EndProcedure

&AtClient
Procedure СпособОбработкиПрефиксовПриИзменении(Item)
	If СпособОбработкиПрефиксов = 1 Then
		Items.СтрокаПрефикса.Enabled      = False;
		Items.ЗаменяемаяПодстрока.Enabled = False;
	ElsIf СпособОбработкиПрефиксов = 5 Then
		Items.СтрокаПрефикса.Enabled      = True;
		Items.ЗаменяемаяПодстрока.Enabled = True;
	Else
		Items.СтрокаПрефикса.Enabled      = True;
		Items.ЗаменяемаяПодстрока.Enabled = False;
	EndIf;
EndProcedure

////////////////////////////////////////////////////////////////////////////////
// ИНИЦИАЛИЗАЦИЯ МОДУЛЬНЫХ ПЕРЕМЕННЫХ

мИспользоватьНастройки = True;

//Attributes настройки и значения по умолчанию.
мНастройка = New Structure("НачальныйНомер,НеИзменятьЧисловуюНумерацию,СтрокаПрефикса,ЗаменяемаяПодстрока,СпособОбработкиПрефиксов");

мНастройка.НачальныйНомер              = 1;
мНастройка.НеИзменятьЧисловуюНумерацию = False;
мНастройка.СпособОбработкиПрефиксов    = 1;

мТипыОбрабатываемыхОбъектов = "Catalog,Document";