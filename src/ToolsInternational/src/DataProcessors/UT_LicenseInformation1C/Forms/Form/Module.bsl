&AtServer
Procedure OnCreateAtServer(Cancel, СтандартнаяОбработка)
	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, СтандартнаяОбработка);
EndProcedure

&AtServer
Function StringToDate(DateString)
	Try
		DateString = Right(DateString, 10);
		DatesArray = New Array;
		DatesArray =  SplitStringToSubStringsArray(DateString, ".");
		Return Date(String(DatesArray[2]) + String(DatesArray[1]) + String(DatesArray[0]));
	Except
		Return Date(1899, 12, 30);
	EndTry;
EndFunction

// Splits a string into several lines by separator. The separator can have any length.
//
// Parameters:
// String - String - Delimited text;
//  Separator-String- Line separator lines of text, at least 1 character;
//  SkipEmptyStrings - Boolean - whether or not included in the result of the empty string.
//     If not specified, the function is running in compatibility mode with its previous version:
//     -  for separator blank empty strings are not included in the result, for the rest of the dividers blank lines
//   if the String parameter does not contain significant characters or does not contain a single character (an empty string), then in
//    the case of a space separator, the result of the function will be an array containing a single value "" (an empty string), and
// with other separators, the result of the function will be an empty array.
//  ShortNonPrintableChars - Boolean - shorten non-printable characters at the edges of each of the found substrings.
//
// Returned Value:
//  Array - strings array .
//
// Examples:
//  SplitStringToSubStringsArray(",один,,два,", ",") - return array of 5 items, 3 of which  - empty
//  SplitStringToSubStringsArray(",один,,два,", ",", Истина) - return array of 2 items;
//  SplitStringToSubStringsArray(" один   два  ", " ") - return array of 2 items;
//  SplitStringToSubStringsArray("") - return empty array;
//  SplitStringToSubStringsArray("",,Ложь) - return array of 1 item "" (empty string );
//  SplitStringToSubStringsArray("", " ") - return array of 1 item "" (empty string);
//
&AtServer
Function SplitStringToSubStringsArray(Val String, Val Splitter = ",", Val SkipEmptyStrings = Undefined,
	ShortNonPrintableChars = False) Export

	Result = New Array;
	
	// For ensuring backward compatibility
	If SkipEmptyStrings = Undefined Then
		SkipEmptyStrings = ?(Splitter = " ", True, False);
		If IsBlankString(String) Then
			If Splitter = " " Then
				Result.Add("");
			EndIf;
			Return Result;
		EndIf;
	EndIf;
	//

	Position = Find(String, Splitter);
	While Position > 0 Do
		Substring = Left(String, Position - 1);
		If Not SkipEmptyStrings Or Not IsBlankString(Substring) Then
			If ShortNonPrintableChars Then
				Result.Add(TrimAll(Substring));
			Else
				Result.Add(Substring);
			EndIf;
		EndIf;
		String = Mid(String, Position + StrLen(Splitter));
		Position = Find(String, Splitter);
	EndDo;

	If Not SkipEmptyStrings Or Not IsBlankString(String) Then
		If ShortNonPrintableChars Then
			Result.Add(TrimAll(String));
		Else
			Result.Add(String);
		EndIf;
	EndIf;

	Return Result;

EndFunction

&AtServer
Procedure GetLicensesListAtServer()
	Object.LicensesList.Clear();
	TempFileName = GetTempFileName("txt");
	If UT_CommonClientServer.IsWindows() Then
		TempFileNameCMD = GetTempFileName("cmd");
	Else
		TempFileNameCMD=GetTempFileName("sh");
	EndIf;
	TextCMD = New TextWriter;
	TextCMD.Open(TempFileNameCMD, TextEncoding.ANSI);
	TextCMD.WriteLine("ring license list > " + TempFileName);
	TextCMD.Close();
	RunApp(TempFileNameCMD, TempFilesDir(), True);
	
//	System("ring license list > " + TempFileName, TempFilesDir());
	Text = New TextReader;
	Text.Open(TempFileName);
	line = "";
	While line <> Undefined Do
		line = Text.ReadLine();
		FileNamePosition = StrFind(line, "(file name:");
		If FileNamePosition > 0 Then
			LicensePin = Left(line, FileNamePosition - 1);
		Else
			LicensePin = line;
		EndIf;

		ArrayLicensePin = SplitStringToSubStringsArray(LicensePin, "-");
		If ArrayLicensePin.Count() < 2 Then
			Continue;
		EndIf;
		LicenseFileName = Mid(line, FileNamePosition + 13, 99);
		LicenseFileName = StrReplace(LicenseFileName, """)", "");
		NewRow = Object.LicensesList.Add();
		NewRow.PinCode = ArrayLicensePin[0];
		NewRow.LicenseNumber =ArrayLicensePin[1];
		NewRow.LicenseFileName = LicenseFileName;
		NewRow.ManualInput = False;
		
				//Message(line);
	EndDo;
	Text.Close();
	DeleteFiles(TempFileName);
	DeleteFiles(TempFileNameCMD);

EndProcedure

&AtClient
Procedure GetLicensesList()
	GetLicensesListAtServer();
EndProcedure

&AtServer
Function LicenseInformationRequest(LicenseName)
	ResponceStructure = New Structure("Description, LastName, Name, MiddleName, EMail, Organization, Country, ZIP, Town, Region, District, Street, House, Building, Apartment, ActivationDate, RegistrationNumber, ProductCode, TextInformation, LicenseCount");
	TempFileName = GetTempFileName("txt");
	TempFileNameCMD = GetTempFileName("cmd");

	TextCMD = New TextWriter;
	TextCMD.Open(TempFileNameCMD, TextEncoding.ANSI);
	TextCMD.WriteLine("call ring > " + TempFileName + " license info --name " + LicenseName);
	TextCMD.Close();
	RunApp(TempFileNameCMD, TempFilesDir(), True);
	Text = New TextReader;
	Text.Open(TempFileName);
	line = "";
	While line <> Undefined Do
		line = Text.ReadLine();
		If StrFind(line, "First name:") > 0 Then
			ResponceStructure.Name = Right(line, StrLen(line) - StrFind(line, "First name:") - StrLen("First name:"));
		ElsIf StrFind(line, "Middle name:") > 0 Then
			ResponceStructure.MiddleName = Right(line, StrLen(line) - StrFind(line, "Middle name:") - StrLen(
				"Middle name:"));
		ElsIf StrFind(line, "Last name:") > 0 Then
			ResponceStructure.LastName = Right(line, StrLen(line) - StrFind(line, "Last name:") - StrLen("Last name:"));
		ElsIf StrFind(line, "Email:") > 0 Then
			ResponceStructure.Email = Right(line, StrLen(line) - StrFind(line, "Email:") - StrLen("Email:"));
		ElsIf StrFind(line, "Company:") > 0 Then
			ResponceStructure.Organization = Right(line, StrLen(line) - StrFind(line, "Company:") - StrLen("Company:"));
		ElsIf StrFind(line, "Country:") > 0 Then
			ResponceStructure.Country = Right(line, StrLen(line) - StrFind(line, "Country:") - StrLen("Country:"));
		ElsIf StrFind(line, "ZIP code:") > 0 Then
			ResponceStructure.ZIP = Right(line, StrLen(line) - StrFind(line, "ZIP code:") - StrLen("ZIP code:"));
		ElsIf StrFind(line, "Town:") > 0 Then
			ResponceStructure.Town = Right(line, StrLen(line) - StrFind(line, "Town:") - StrLen("Town:"));
		ElsIf StrFind(line, "Region:") > 0 Then
			ResponceStructure.Region = Right(line, StrLen(line) - StrFind(line, "Region:") - StrLen("Region:"));
		ElsIf StrFind(line, "District:") > 0 Then
			ResponceStructure.District = Right(line, StrLen(line) - StrFind(line, "District:") - StrLen("District:"));
		ElsIf StrFind(line, "Building:") > 0 Then
			ResponceStructure.Building = Right(line, StrLen(line) - StrFind(line, "Building:") - StrLen("Building:"));
		ElsIf StrFind(line, "Apartment:") > 0 Then
			ResponceStructure.Apartment = Right(line, StrLen(line) - StrFind(line, "Apartment:") - StrLen("Apartment:"));
		ElsIf StrFind(line, "Street:") > 0 Then
			ResponceStructure.Street = Right(line, StrLen(line) - StrFind(line, "Street:") - StrLen("Street:"));
		ElsIf StrFind(line, "House:") > 0 Then
			ResponceStructure.House = Right(line, StrLen(line) - StrFind(line, "House:") - StrLen("House:"));
		ElsIf StrFind(line, "Description:") > 0 Then
			ResponceStructure.Description = Right(line, StrLen(line) - StrFind(line, "Description:") - StrLen(
				"Description:"));
			If StrFind(line, " workplaces") Then
				tline = Left(line, StrFind(Line, " workplaces"));
				arrLine = SplitStringToSubStringsArray(tline, " ");
				ResponceStructure.LicenseCount = Number(arrLine[arrLine.Count() - 1]);
			EndIf;
		ElsIf StrFind(Line, "License generation date:") > 0 Then
			ResponceStructure.ActivationDate = StringToDate(Right(Line, StrLen(Line) - StrFind(Line,
				"License generation date:") - StrLen("License generation date:")));
		ElsIf StrFind(Line, "Distribution kit registration number:") > 0 Then
			ResponceStructure.RegistrationNumber = Right(Line, StrLen(Line) - StrFind(Line,
				"Distribution kit registration number:") - StrLen("Distribution kit registration number:"));
		ElsIf StrFind(Line, "Product code:") > 0 Then
			ResponceStructure.ProductCode = Right(Line, StrLen(Line) - StrFind(Line, "Product code:") - StrLen(
				"Product code:"));
		EndIf;
	EndDo;
	Text.Close();
	DeleteFiles(TempFileName);
	DeleteFiles(TempFileNameCMD);
	Return ResponceStructure;

EndFunction

&AtServer
Function LicenseValidityRequest(LicenseName)
	TempFileName = GetTempFileName("txt");
	TempFileNameCMD = GetTempFileName("cmd");

	TextCMD = New TextWriter;
	TextCMD.Open(TempFileNameCMD, TextEncoding.ANSI);
	TextCMD.WriteLine("call ring > " + TempFileName + " license validate --name " + LicenseName);
	TextCMD.Close();
	RunApp(TempFileNameCMD, TempFilesDir(), True);
	Text = New TextReader;
	Text.Open(TempFileName);
	Line = Text.Read();
	ResponceStructure = New Structure("Active, TextInformation");
	If StrFind(Line, "License check passed for the following license:") Then
		ResponceStructure.Active = True;
	Else
		ResponceStructure.Active = False;
	EndIf;
	ResponceStructure.TextInformation = Line;
	Text.Close();
	DeleteFiles(TempFileName);
	DeleteFiles(TempFileNameCMD);
	Return ResponceStructure;
EndFunction

&AtClient
Procedure GetLicenseFullInformation()
	LicensesCount = Object.LicensesList.Count();
	IndicatorValue = 0;
	Counter = 1;
	For Each Line In Object.LicensesList Do
		
		MessageText = StrTemplate("ru = 'Получение информации о лицензиях (%1) шт.)';en = 'Getting information about licenses ( %1) pcs'",String(LicensesCount));
		Explanation = StrTemplate(NSTR("ru = 'Запрос информации о лицензии %1 .Всего: %2';en = 'Request for license information %1 .Total: %2'"),Line.LicenseNumber,LicensesCount);
		Picture = PictureLib.Post;
		IndicatorValue = 100 / (LicensesCount / Counter);
		Status(MessageText, IndicatorValue, Explanation, Picture);
		ValueStructure = LicenseInformationRequest(Line.PinCode + "-" + Line.LicenseNumber);
		FillPropertyValues(Line, ValueStructure);
		Counter = Counter + 1;

	EndDo;

EndProcedure

&AtClient
Procedure LicenseValidationCheck()
	LicensesCount = Object.LicensesList.Count();
	IndicatorValue = 0;
	Counter = 1;
	For Each Line In Object.LicensesList Do
		MessageText = StrTemplate("ru = 'Получение информации о лицензиях (%1) шт.)';en = 'Getting information about licenses ( %1) pcs'",String(LicensesCount));
		Explanation = StrTemplate(NSTR("ru = 'Запрос информации о лицензии %1 .Всего: %2';en = 'Request for license information %1 .Total: %2'"),Line.LicenseNumber,LicensesCount);
		Picture = PictureLib.Post;
		IndicatorValue = 100 / (LicensesCount / Counter);
		Status(MessageText, IndicatorValue, Explanation, Picture);
		ValueStructure = LicenseValidityRequest(Line.PinCode + "-" + Line.LicenseNumber);
		FillPropertyValues(Line, ValueStructure);
		Counter = Counter + 1;
	EndDo;

EndProcedure

&AtServer
Procedure LicenseReactivationAtServer(IncomeParameters)
	ParametersStructure = New Structure(" NewPinCode,PinCode, Description, LastName, Name, MiddleName, EMail, Organization, Country, ZIP, Town, Street, House, ActivationDate, RegistrationNumber, ProductCode, TextInformation, LicenseCount");

	TempFileName = GetTempFileName("txt");
	TempFileNameCMD = GetTempFileName("cmd");

	TextCMD = New TextWriter;
	TextCMD.Open(TempFileNameCMD, TextEncoding.ANSI);
	TextCMD.WriteLine("call ring > " + TempFileName + " license activate" + ?(ValueIsFilled(
		IncomeParameters.Name), " --first-name " + IncomeParameters.Name, "") + ?(ValueIsFilled(
		IncomeParameters.MiddleName), " --middle-name " + IncomeParameters.MiddleName, "") + ?(ValueIsFilled(
		IncomeParameters.LastName), " --last-name " + IncomeParameters.LastName, "") + ?(ValueIsFilled(
		IncomeParameters.EMail), " --email " + IncomeParameters.EMail, "") + ?(ValueIsFilled(
		IncomeParameters.Organization), " --company " + Char(34) + StrReplace(IncomeParameters.Organization, Char(
		34), "") + Char(34), "") + ?(ValueIsFilled(IncomeParameters.Country), " --country " + Char(34)
		+ IncomeParameters.Country + Char(34), "") + ?(ValueIsFilled(IncomeParameters.ZIP),
		" --zip-code " + IncomeParameters.ZIP, "") + ?(ValueIsFilled(IncomeParameters.Town), " --town "
		+ Char(34) + IncomeParameters.Town + Char(34), "") + ?(ValueIsFilled(IncomeParameters.region),
		" --region " + Char(34) + IncomeParameters.Region + Char(34), "") + ?(ValueIsFilled(
		IncomeParameters.District), " --district " + Char(34) + IncomeParameters.District + Char(34), "") + ?(
		ValueIsFilled(IncomeParameters.Street), " --street " + Char(34) + IncomeParameters.Street + Char(
		34), "") + ?(ValueIsFilled(IncomeParameters.House), " --house " + Char(34) + IncomeParameters.House
		+ Char(34), "") + ?(ValueIsFilled(IncomeParameters.building), " --building " + Char(34)
		+ IncomeParameters.Building + Char(34), "") + ?(ValueIsFilled(IncomeParameters.Appartment),
		" --apartment " + Char(34) + IncomeParameters.Apartment + Char(34), "") + " --serial "
		+ IncomeParameters.LicenseNumber + " --pin " + IncomeParameters.NewPinCode + " --previous-pin "
		+ IncomeParameters.PinCode + " --validate");
	TextCMD.Close();
	RunApp(TempFileNameCMD, TempFilesDir(), True);
	Text = New TextReader;
	Text.Open(TempFileName);
	Line = Text.Read();
	Message(Line);
	Text.Close();
	DeleteFiles(TempFileName);
	DeleteFiles(TempFileNameCMD);
EndProcedure

&AtServer
Procedure AfterPinCodeStringInput(ReceivedValue, IncomeParameters) Export
	EnteredCode = ReceivedValue;
	If IsBlankString(EnteredCode) Then
		Cancel = True;
	Else
		IncomeParameters.NewPinCode = EnteredCode;
		LicenseReactivationAtServer(IncomeParameters);
	EndIf;
EndProcedure

&AtClient
Procedure LicenseReactivation(Command)
	CurrentLine = Items.LicensesList.CurrentData;
	ParametersStructure = New Structure(" LicenseNumber,NewPinCode,PinCode, Description, LastName, Name, MiddleName, EMail, Organization, Country, ZIP, Region, District,Town, Street, House, Building, Apartment, Building, ActivationDate, RegistrationNumber, ProductCode, TextInformation, LicenseCount");
	FillPropertyValues(ParametersStructure, CurrentLine);
	Notify = New NotifyDescription("AfterPinCodeStringInput", ThisObject, ParametersStructure);

	ShowInputString(
        Notify, , // skip the initial value

		NSTR("ru = 'Введите пин-код для лицензии ';en = 'Enter PIN code license'") + CurrentLine["LicenseNumber"], 0, //  length

		False // Multiline
	);
EndProcedure

&AtServer
Procedure DeleteLicenseAtServer(LicenseName)
	TempFileName = GetTempFileName("txt");
	TempFileNameCMD = GetTempFileName("cmd");

	TextCMD = New TextWriter;
	TextCMD.Open(TempFileNameCMD, TextEncoding.ANSI);
	TextCMD.WriteLine("call ring > " + TempFileName + " license remove --name " + LicenseName);
	TextCMD.Close();
	RunApp(TempFileNameCMD, TempFilesDir(), True);
	Text = New TextReader;
	Text.Open(TempFileName);
	Line = Text.Read();
	Message(Line);
	Text.Close();
	DeleteFiles(TempFileName);
	DeleteFiles(TempFileNameCMD);

EndProcedure

&AtClient
Procedure DeleteLicense(Command)
	CurrentLine = Items.LicensesList.CurrentData;
	DeleteLicenseAtServer(CurrentLine["PinCode"] + "-" + CurrentLine["LicenseNumber"]);
	Object.LicensesList.Delete(Items.LicensesList.CurrentLine);
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	AttachIdleHandler("LoadData", 1, True);
EndProcedure

&AtClient
Procedure LoadData()
	GetLicensesList();
	GetLicenseFullInformation();
	LicenseValidationCheck();
EndProcedure


&AtClient
Procedure LicensesListOnActivateRow(Item)
	Try
		Items.GroupActivationData.ReadOnly = Items.LicensesList.CurrentData["Active"];
		Items.LicensesListActivateLicense.Enabled = Not Items.LicensesList.CurrentData["Active"];
	Except
	EndTry;
EndProcedure


&AtClient
Procedure LicensesListBeforeAddRow(Item, Cancel, Clone, Parent, IsFolder, Parameter)
	//TODO: Insert the handler content
EndProcedure


&AtClient
Procedure ActivateLicense(Command)
	OpenParameters = New Structure("LastName, Name, MiddleName, EMail, Organization, Country, ZIP, Region, District,Town, Street, House, Building, Apartment, Building");
	CurrentLine = Items.LicensesList.CurrentData;
	FillPropertyValues(OpenParameters, CurrentLine);
	OpenForm("DataProcessor.UT_LicenseInformation1C.Form.FormLicenseActivation", OpenParameters);
EndProcedure

//@skip-warning
&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) 
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

