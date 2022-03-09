&AtServer
Function ActivateAtServer()

	TempFileName = GetTempFileName("txt");
	TempFileNameCMD = GetTempFileName("cmd");

	TextCMD = New TextWriter;
	TextCMD.Open(TempFileNameCMD, TextEncoding.ANSI);
	TextCMD.WriteLine("call ring > " + TempFileName + " license activate" + ?(ValueIsFilled(Name),
		" --first-name " + Name, "") + ?(ValueIsFilled(MiddleName), " --middle-name " + MiddleName, "") + ?(
		ValueIsFilled(LastName), " --last-name " + LastName, "") + " --email " + EMail + ?(ValueIsFilled(
		Organization), " --company " + Char(34) + StrReplace(Organization, Char(34), "") + Char(34), "") + " --country "
		+ Char(34) + Country + Char(34) + " --zip-code " + ZIP + " --town " + Char(34) + Town + Char(34) + ?(
		ValueIsFilled(State), " --region " + Char(34) + State + Char(34), "") + ?(ValueIsFilled(District),
		" --district " + Char(34) + District + Char(34), "") + ?(ValueIsFilled(Street), " --street " + Char(34)
		+ Street + Char(34), "") + ?(ValueIsFilled(House), " --house " + Char(34) + House + Char(34), "") + ?(
		ValueIsFilled(Building), " --building " + Char(34) + Building + Char(34), "") + ?(ValueIsFilled(
		Appartment), " --apartment " + Char(34) + Appartment + Char(34), "") + " --serial " + LicenseNumber + " --pin "
		+ PinCode + ?(ValueIsFilled(PreviousPinCode), " --previous-pin " + PreviousPinCode, "") + " --validate");
	TextCMD.Close();
	RunApp(TempFileNameCMD, TempFilesDir(), True);
	Text = New TextReader;
	Text.Open(TempFileName);
	line = Text.Read();
	Message(line);
	Text.Close();
	DeleteFiles(TempFileName);
	DeleteFiles(TempFileNameCMD);
	Return line;
EndFunction

&AtClient
Procedure CommandActivate(Command)
	ActivateAtServer();
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	LastName = Parameters.LastName;
	Name = Parameters.Name;
	MiddleName = Parameters.MiddleName;
	Organization = Parameters.Organization;
	email = Parameters.email;
	Country = Parameters.Country;
	ZIP = Parameters.ZIP;
	State = Parameters.Region;
	District = Parameters.District;
	Town = Parameters.Town;
	Street = Parameters.Street;
	House = Parameters.House;
	Building = Parameters.Building;
	Appartment = Parameters.Apartment;
EndProcedure