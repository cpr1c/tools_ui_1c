

&AtServer
Procedure OnCreateAtServer(Cancel, СтандартнаяОбработка)
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, СтандартнаяОбработка);
EndProcedure


&AtServer
Function СтрокуВДату(СтрокаДата)
	Try
		СтрокаДата = Right(СтрокаДата, 10);
		МассивДата = New Array;
		МассивДата =  РазложитьСтрокуВМассивПодстрок(СтрокаДата, ".");
		Return Date(String(МассивДата[2]) + String(МассивДата[1]) + String(МассивДата[0]));
	Except
		Return Date(1899, 12, 30);
	EndTry;
EndFunction

// Разбивает строку на несколько строк по разделителю. Разделитель может иметь любую длину.
//
// Параметры:
//  Строка                 - Строка - текст с разделителями;
//  Разделитель            - Строка - разделитель строк текста, минимум 1 символ;
//  ПропускатьПустыеСтроки - Булево - признак необходимости включения в результат пустых строк.
//    Если параметр не задан, то функция работает в режиме совместимости со своей предыдущей версией:
//     - для разделителя-пробела пустые строки не включаются в результат, для остальных разделителей пустые строки
//       включаются в результат.
//     Е если параметр Строка не содержит значащих символов или не содержит ни одного символа (пустая строка), то в
//       случае разделителя-пробела результатом функции будет массив, содержащий одно значение "" (пустая строка), а
//       при других разделителях результатом функции будет пустой массив.
//  СокращатьНепечатаемыеСимволы - Булево - сокращать непечатаемые символы по краям каждой из найденных подстрок.
//
// Возвращаемое значение:
//  Массив - массив строк.
//
// Примеры:
//  РазложитьСтрокуВМассивПодстрок(",один,,два,", ",") - возвратит массив из 5 элементов, три из которых  - пустые
//  строки;
//  РазложитьСтрокуВМассивПодстрок(",один,,два,", ",", Истина) - возвратит массив из двух элементов;
//  РазложитьСтрокуВМассивПодстрок(" один   два  ", " ") - возвратит массив из двух элементов;
//  РазложитьСтрокуВМассивПодстрок("") - возвратит пустой массив;
//  РазложитьСтрокуВМассивПодстрок("",,Ложь) - возвратит массив с одним элементом "" (пустой строкой);
//  РазложитьСтрокуВМассивПодстрок("", " ") - возвратит массив с одним элементом "" (пустой строкой);
//
&AtServer
Function РазложитьСтрокуВМассивПодстрок(Знач String, Знач Splitter = ",", Знач ПропускатьПустыеСтроки = Undefined,
	СокращатьНепечатаемыеСимволы = False) Export

	Result = New Array;
	
	// For обеспечения обратной совместимости.
	If ПропускатьПустыеСтроки = Undefined Then
		ПропускатьПустыеСтроки = ?(Splitter = " ", True, False);
		If IsBlankString(String) Then
			If Splitter = " " Then
				Result.Add("");
			EndIf;
			Return Result;
		EndIf;
	EndIf;
	//

	Позиция = Find(String, Splitter);
	While Позиция > 0 Do
		Подстрока = Left(String, Позиция - 1);
		If Not ПропускатьПустыеСтроки Or Not IsBlankString(Подстрока) Then
			If СокращатьНепечатаемыеСимволы Then
				Result.Add(TrimAll(Подстрока));
			Else
				Result.Add(Подстрока);
			EndIf;
		EndIf;
		String = Mid(String, Позиция + StrLen(Splitter));
		Позиция = Find(String, Splitter);
	EndDo;

	If Not ПропускатьПустыеСтроки Or Not IsBlankString(String) Then
		If СокращатьНепечатаемыеСимволы Then
			Result.Add(TrimAll(String));
		Else
			Result.Add(String);
		EndIf;
	EndIf;

	Return Result;

EndFunction

&AtServer
Procedure ПолучитьСписокЛицензийНаСервере()
	Object.LicensesList.Clear();
	ИмяВременногоФайла = GetTempFileName("txt");
	If UT_CommonClientServer.IsWindows() Then
		ИмяВременногоФайлаCMD = GetTempFileName("cmd");
	Else
		ИмяВременногоФайлаCMD=GetTempFileName("sh");
	EndIf;
	ТекстCMD = New TextWriter;
	ТекстCMD.Open(ИмяВременногоФайлаCMD, TextEncoding.ANSI);
	ТекстCMD.WriteLine("ring license list > " + ИмяВременногоФайла);
	ТекстCMD.Close();
	RunApp(ИмяВременногоФайлаCMD, TempFilesDir(), True);
	
//	КомандаСистемы("ring license list > " + ИмяВременногоФайла, КаталогВременныхФайлов());
	Text = New TextReader;
	Text.Open(ИмяВременногоФайла);
	стр = "";
	While стр <> Undefined Do
		стр = Text.ReadLine();
		ПозицияИмениФайла = StrFind(стр, "(file name:");
		If ПозицияИмениФайла > 0 Then
			ПинЛицензия = Left(стр, ПозицияИмениФайла - 1);
		Else
			ПинЛицензия = стр;
		EndIf;

		мПинЛицензия = РазложитьСтрокуВМассивПодстрок(ПинЛицензия, "-");
		If мПинЛицензия.Count() < 2 Then
			Continue;
		EndIf;
		LicenseFileName = Mid(стр, ПозицияИмениФайла + 13, 99);
		LicenseFileName = StrReplace(LicenseFileName, """)", "");
		нСтр = Object.LicensesList.Add();
		нСтр.PinCode = мПинЛицензия[0];
		нСтр.LicenseNumber = мПинЛицензия[1];
		нСтр.LicenseFileName = LicenseFileName;
		нСтр.ManualInput = False;
		
				//Message(стр);
	EndDo;
	Text.Close();
	DeleteFiles(ИмяВременногоФайла);
	DeleteFiles(ИмяВременногоФайлаCMD);

EndProcedure

&AtClient
Procedure ПолучитьСписокЛицензий()
	ПолучитьСписокЛицензийНаСервере();
EndProcedure

&AtServer
Function ЗапросИнформацииОЛицезнии(ИмяЛицензии)
	СтруктураОтвета = New Structure("LongDesc, LastName, Name, MiddleName, EMail, Organization, Country, ZIP, Town, Region, District, Street, House, Building, Apartment, ActivationDate, RegistrationNumber, ProductCode, TextInformation, LicenseCount");
	ИмяВременногоФайла = GetTempFileName("txt");
	ИмяВременногоФайлаCMD = GetTempFileName("cmd");

	ТекстCMD = New TextWriter;
	ТекстCMD.Open(ИмяВременногоФайлаCMD, TextEncoding.ANSI);
	ТекстCMD.WriteLine("call ring > " + ИмяВременногоФайла + " license info --name " + ИмяЛицензии);
	ТекстCMD.Close();
	RunApp(ИмяВременногоФайлаCMD, TempFilesDir(), True);
	Text = New TextReader;
	Text.Open(ИмяВременногоФайла);
	стр = "";
	While стр <> Undefined Do
		стр = Text.ReadLine();
		If StrFind(стр, "First name:") > 0 Then
			СтруктураОтвета.Name = Right(стр, StrLen(стр) - StrFind(стр, "First name:") - StrLen("First name:"));
		ElsIf StrFind(стр, "Middle name:") > 0 Then
			СтруктураОтвета.MiddleName = Right(стр, StrLen(стр) - StrFind(стр, "Middle name:") - StrLen(
				"Middle name:"));
		ElsIf StrFind(стр, "Last name:") > 0 Then
			СтруктураОтвета.LastName = Right(стр, StrLen(стр) - StrFind(стр, "Last name:") - StrLen("Last name:"));
		ElsIf StrFind(стр, "Email:") > 0 Then
			СтруктураОтвета.Email = Right(стр, StrLen(стр) - StrFind(стр, "Email:") - StrLen("Email:"));
		ElsIf StrFind(стр, "Company:") > 0 Then
			СтруктураОтвета.Organization = Right(стр, StrLen(стр) - StrFind(стр, "Company:") - StrLen("Company:"));
		ElsIf StrFind(стр, "Country:") > 0 Then
			СтруктураОтвета.Country = Right(стр, StrLen(стр) - StrFind(стр, "Country:") - StrLen("Country:"));
		ElsIf StrFind(стр, "ZIP code:") > 0 Then
			СтруктураОтвета.ZIP = Right(стр, StrLen(стр) - StrFind(стр, "ZIP code:") - StrLen("ZIP code:"));
		ElsIf StrFind(стр, "Town:") > 0 Then
			СтруктураОтвета.Town = Right(стр, StrLen(стр) - StrFind(стр, "Town:") - StrLen("Town:"));
		ElsIf StrFind(стр, "Region:") > 0 Then
			СтруктураОтвета.Region = Right(стр, StrLen(стр) - StrFind(стр, "Region:") - StrLen("Region:"));
		ElsIf StrFind(стр, "District:") > 0 Then
			СтруктураОтвета.District = Right(стр, StrLen(стр) - StrFind(стр, "District:") - StrLen("District:"));
		ElsIf StrFind(стр, "Building:") > 0 Then
			СтруктураОтвета.Building = Right(стр, StrLen(стр) - StrFind(стр, "Building:") - StrLen("Building:"));
		ElsIf StrFind(стр, "Apartment:") > 0 Then
			СтруктураОтвета.Apartment = Right(стр, StrLen(стр) - StrFind(стр, "Apartment:") - StrLen("Apartment:"));
		ElsIf StrFind(стр, "Street:") > 0 Then
			СтруктураОтвета.Street = Right(стр, StrLen(стр) - StrFind(стр, "Street:") - StrLen("Street:"));
		ElsIf StrFind(стр, "House:") > 0 Then
			СтруктураОтвета.House = Right(стр, StrLen(стр) - StrFind(стр, "House:") - StrLen("House:"));
		ElsIf StrFind(стр, "Description:") > 0 Then
			СтруктураОтвета.LongDesc = Right(стр, StrLen(стр) - StrFind(стр, "Description:") - StrLen(
				"Description:"));
			If StrFind(стр, " рабочих мест") Then
				тСтр = Left(стр, StrFind(стр, " рабочих мест"));
				мСтр = РазложитьСтрокуВМассивПодстрок(тСтр, " ");
				СтруктураОтвета.LicenseCount = Number(мСтр[мСтр.Count() - 1]);
			EndIf;
		ElsIf StrFind(стр, "License generation date:") > 0 Then
			СтруктураОтвета.ActivationDate = СтрокуВДату(Right(стр, StrLen(стр) - StrFind(стр,
				"License generation date:") - StrLen("License generation date:")));
		ElsIf StrFind(стр, "Distribution kit registration number:") > 0 Then
			СтруктураОтвета.RegistrationNumber = Right(стр, StrLen(стр) - StrFind(стр,
				"Distribution kit registration number:") - StrLen("Distribution kit registration number:"));
		ElsIf StrFind(стр, "Product code:") > 0 Then
			СтруктураОтвета.ProductCode = Right(стр, StrLen(стр) - StrFind(стр, "Product code:") - StrLen(
				"Product code:"));
		EndIf;
	EndDo;
	Text.Close();
	DeleteFiles(ИмяВременногоФайла);
	DeleteFiles(ИмяВременногоФайлаCMD);
	Return СтруктураОтвета;

EndFunction

&AtServer
Function ЗапросВалидностиЛицезнии(ИмяЛицензии)
	ИмяВременногоФайла = GetTempFileName("txt");
	ИмяВременногоФайлаCMD = GetTempFileName("cmd");

	ТекстCMD = New TextWriter;
	ТекстCMD.Open(ИмяВременногоФайлаCMD, TextEncoding.ANSI);
	ТекстCMD.WriteLine("call ring > " + ИмяВременногоФайла + " license validate --name " + ИмяЛицензии);
	ТекстCMD.Close();
	RunApp(ИмяВременногоФайлаCMD, TempFilesDir(), True);
	Text = New TextReader;
	Text.Open(ИмяВременногоФайла);
	стр = Text.Read();
	СтруктураОтвета = New Structure("Active, TextInformation");
	If StrFind(стр, "License check passed for the following license:") Then
		СтруктураОтвета.Active = True;
	Else
		СтруктураОтвета.Active = False;
	EndIf;
	СтруктураОтвета.TextInformation = стр;
	Text.Close();
	DeleteFiles(ИмяВременногоФайла);
	DeleteFiles(ИмяВременногоФайлаCMD);
	Return СтруктураОтвета;

EndFunction
&AtClient
Procedure ПолучитьПолнуюИнформациюОЛицензии()
	КоличествоЛицензий = Object.LicensesList.Count();
	значениеИндикатора = 0;
	Счетчик = 1;
	For Each стр In Object.LicensesList Do
		MessageText = "Receive информации о лицензиях (" + String(КоличествоЛицензий) + " шт.)";
		Explanation = "Query информации о лицензии " + стр.LicenseNumber + ". Всего: " + КоличествоЛицензий;
		Picture = PictureLib.Post;
		значениеИндикатора = 100 / (КоличествоЛицензий / Счетчик);
		Status(MessageText, значениеИндикатора, Explanation, Picture);
		СтруктураЗн = ЗапросИнформацииОЛицезнии(стр.PinCode + "-" + стр.LicenseNumber);
		FillPropertyValues(стр, СтруктураЗн);
		Счетчик = Счетчик + 1;

	EndDo;

EndProcedure

&AtClient
Procedure ПроверкаВалидностиЛицензий()
	КоличествоЛицензий = Object.LicensesList.Count();
	значениеИндикатора = 0;
	Счетчик = 1;
	For Each стр In Object.LicensesList Do
		MessageText = "Receive информации о лицензиях (" + String(КоличествоЛицензий) + " шт.)";
		Explanation = "Query информации о лицензии " + стр.LicenseNumber + ". Всего: " + КоличествоЛицензий;
		Picture = PictureLib.Post;
		значениеИндикатора = 100 / (КоличествоЛицензий / Счетчик);
		Status(MessageText, значениеИндикатора, Explanation, Picture);
		СтруктураЗн = ЗапросВалидностиЛицезнии(стр.PinCode + "-" + стр.LicenseNumber);
		FillPropertyValues(стр, СтруктураЗн);
		Счетчик = Счетчик + 1;
	EndDo;

EndProcedure

&AtServer
Procedure ПовторнаяАктивацияЛицензииНаСервере(ПереданныеПараметры)
	СтруктураПараметров = New Structure(" НовыйПинКод,PinCode, LongDesc, LastName, Name, MiddleName, EMail, Organization, Country, ZIP, Town, Street, House, ActivationDate, RegistrationNumber, ProductCode, TextInformation, LicenseCount");

	ИмяВременногоФайла = GetTempFileName("txt");
	ИмяВременногоФайлаCMD = GetTempFileName("cmd");

	ТекстCMD = New TextWriter;
	ТекстCMD.Open(ИмяВременногоФайлаCMD, TextEncoding.ANSI);
	ТекстCMD.WriteLine("call ring > " + ИмяВременногоФайла + " license activate" + ?(ValueIsFilled(
		ПереданныеПараметры.Name), " --first-name " + ПереданныеПараметры.Name, "") + ?(ValueIsFilled(
		ПереданныеПараметры.MiddleName), " --middle-name " + ПереданныеПараметры.MiddleName, "") + ?(ValueIsFilled(
		ПереданныеПараметры.LastName), " --last-name " + ПереданныеПараметры.LastName, "") + ?(ValueIsFilled(
		ПереданныеПараметры.EMail), " --email " + ПереданныеПараметры.EMail, "") + ?(ValueIsFilled(
		ПереданныеПараметры.Компания), " --company " + Char(34) + StrReplace(ПереданныеПараметры.Компания, Char(
		34), "") + Char(34), "") + ?(ValueIsFilled(ПереданныеПараметры.Country), " --country " + Char(34)
		+ ПереданныеПараметры.Country + Char(34), "") + ?(ValueIsFilled(ПереданныеПараметры.IndexOf),
		" --zip-code " + ПереданныеПараметры.ZIP, "") + ?(ValueIsFilled(ПереданныеПараметры.City), " --town "
		+ Char(34) + ПереданныеПараметры.Town + Char(34), "") + ?(ValueIsFilled(ПереданныеПараметры.State),
		" --region " + Char(34) + ПереданныеПараметры.Region + Char(34), "") + ?(ValueIsFilled(
		ПереданныеПараметры.District), " --district " + Char(34) + ПереданныеПараметры.District + Char(34), "") + ?(
		ValueIsFilled(ПереданныеПараметры.Street), " --street " + Char(34) + ПереданныеПараметры.Street + Char(
		34), "") + ?(ValueIsFilled(ПереданныеПараметры.House), " --house " + Char(34) + ПереданныеПараметры.House
		+ Char(34), "") + ?(ValueIsFilled(ПереданныеПараметры.Строение), " --building " + Char(34)
		+ ПереданныеПараметры.Building + Char(34), "") + ?(ValueIsFilled(ПереданныеПараметры.Appartment),
		" --apartment " + Char(34) + ПереданныеПараметры.Apartment + Char(34), "") + " --serial "
		+ ПереданныеПараметры.LicenseNumber + " --pin " + ПереданныеПараметры.НовыйПинКод + " --previous-pin "
		+ ПереданныеПараметры.PinCode + " --validate");
	ТекстCMD.Close();
	RunApp(ИмяВременногоФайлаCMD, TempFilesDir(), True);
	Text = New TextReader;
	Text.Open(ИмяВременногоФайла);
	стр = Text.Read();
	Message(стр);
	Text.Close();
	DeleteFiles(ИмяВременногоФайла);
	DeleteFiles(ИмяВременногоФайлаCMD);
EndProcedure

&AtServer
Procedure ПослеВводаСтрокиПинкода(ПолученноеЗначение, ПереданныеПараметры) Export
	ВведенныйКод = ПолученноеЗначение;
	If IsBlankString(ВведенныйКод) Then
		Cancel = True;
	Else
		ПереданныеПараметры.НовыйПинКод = ВведенныйКод;
		ПовторнаяАктивацияЛицензииНаСервере(ПереданныеПараметры);
	EndIf;
EndProcedure

&AtClient
Procedure ПовторнаяАктивацияЛицензии(Command)
	CurrentLine = Items.LicensesList.CurrentData;
	СтруктураПараметров = New Structure(" LicenseNumber,НовыйПинКод,PinCode, LongDesc, LastName, Name, MiddleName, EMail, Organization, Country, ZIP, Region, District,Town, Street, House, Building, Apartment, Building, ActivationDate, RegistrationNumber, ProductCode, TextInformation, LicenseCount");
	FillPropertyValues(СтруктураПараметров, CurrentLine);
	Оповещение = New NotifyDescription("ПослеВводаСтрокиПинкода", ThisObject, СтруктураПараметров);

	ShowInputString(
        Оповещение, , // пропускаем начальное значение

		"Введите пин-код для лицензии " + CurrentLine["LicenseNumber"], 0, // (необ.) длина

		False // (необ.) многострочность
	);
EndProcedure

&AtServer
Procedure УдалитьЛицензиюНаСервере(ИмяЛицензии)
	ИмяВременногоФайла = GetTempFileName("txt");
	ИмяВременногоФайлаCMD = GetTempFileName("cmd");

	ТекстCMD = New TextWriter;
	ТекстCMD.Open(ИмяВременногоФайлаCMD, TextEncoding.ANSI);
	ТекстCMD.WriteLine("call ring > " + ИмяВременногоФайла + " license remove --name " + ИмяЛицензии);
	ТекстCMD.Close();
	RunApp(ИмяВременногоФайлаCMD, TempFilesDir(), True);
	Text = New TextReader;
	Text.Open(ИмяВременногоФайла);
	стр = Text.Read();
	Message(стр);
	Text.Close();
	DeleteFiles(ИмяВременногоФайла);
	DeleteFiles(ИмяВременногоФайлаCMD);

EndProcedure

&AtClient
Procedure УдалитьЛицензию(Command)
	CurrentLine = Items.LicensesList.CurrentData;
	УдалитьЛицензиюНаСервере(CurrentLine["PinCode"] + "-" + CurrentLine["LicenseNumber"]);
	Object.LicensesList.Delete(Items.LicensesList.CurrentLine);
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	AttachIdleHandler("ЗагрузитьДанные", 1, True);
EndProcedure

&AtClient
Procedure ЗагрузитьДанные()
	ПолучитьСписокЛицензий();
	ПолучитьПолнуюИнформациюОЛицензии();
	ПроверкаВалидностиЛицензий();
EndProcedure

&AtClient
Procedure СписокЛицензийПриАктивизацииСтроки(Item)
	Try
		Items.GroupActivationData.ReadOnly = Items.LicensesList.CurrentData["Active"];
		Items.СписокЛицензийАктивироватьЛицензию.Enabled = Not Items.LicensesList.CurrentData["Active"];
	Except
	EndTry;
EndProcedure

&AtClient
Procedure СписокЛицензийПередНачаломДобавления(Item, Cancel, Copy, Parent, Group, Parameter)
	// Insert содержимое обработчика.
EndProcedure

&AtClient
Procedure АктивироватьЛицензию(Command)
	ПараметрыОткрытия = New Structure("LastName, Name, MiddleName, EMail, Organization, Country, ZIP, Region, District,Town, Street, House, Building, Apartment, Building");
	CurrentLine = Items.LicensesList.CurrentData;
	FillPropertyValues(ПараметрыОткрытия, CurrentLine);
	OpenForm("Processing.UT_LicenseInformation1C.Form.ФормаАктивацииЛицензии", ПараметрыОткрытия);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

