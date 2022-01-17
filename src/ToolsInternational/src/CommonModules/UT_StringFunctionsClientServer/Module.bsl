#Region Public

// Splits the string into several strings by the specified separator. The separator can be any length.
// If the separator is a single-character string and the TrimNonprintableChars parameter is not used, 
// we recommend that you use the StrSplit platform function.
//
// Parameters:
//  Value - String - a delimited text;
//  String            - String - a text separator, at least 1 character;
//  SkipEmptyStrings - Boolean - indicates whether empty strings must be included in the result.
//    If this parameter is not set, the function executes in compatibility with its earlier version.
//     - if space is used as a separator, blank strings are not included in the result, for other 
//       separators blank strings are included in the result.
//     - if String parameter does not contain significant characters (or it is an empty string) and 
//       space is used as a separator, the function returns an array with a single empty string 
//       value (""). - if the String parameter does not contain significant characters (or it is an empty string) and any character except space is used as a separator, the function returns an empty array.
//  TrimNonprintableChars - Boolean - a flag that shows whether nonprintable characters in the beginning and in the end of the found substrings are trimmed.
//
// Returns:
//  Array - an array of strings.
//
// Example:
//  StringFunctionsClientServer.SplitStringIntoSubstringsArray(",one,,two", ",")
//  - returns an array of 5 items, three of which are empty: "", "one", "", "two", "";
//  StringFunctionsClientServer.SplitStringIntoSubstringsArray(",one,,two,", ",", True)
//  - returns an array of two items: "one", "two";
//  StringFunctionsClientServer.SplitStringIntoSubstringsArray(" one   two  ", " ")
//  - returns an array of two items: "one", "two";
//  StringFunctionsClientServer.SplitStringIntoSubstringsArray("")
//  - Returns an empty array.
//  StringFunctionsClientServer.SplitStringIntoSubstringsArrayy("",,False)
//  - returns an array with one item ""(empty string);
//  StringFunctionsClientServer.SplitStringIntoSubstringsArray("", " ")
//  - returns an array with one item "" (empty string).
//
Function SplitStringIntoSubstringsArray(Val Value, Val Separator = ",", Val SkipEmptyStrings = Undefined, 
	TrimNonprintableChars = False) Export

	Result = New Array;
	
	// This procedure ensures backward compatibility.
	If SkipEmptyStrings = Undefined Then
		SkipEmptyStrings = ?(Separator = " ", True, False);
		If IsBlankString(Value) Then 
			If Separator = " " Then
				Result.Add("");
			EndIf;
			Return Result;
		EndIf;
	EndIf;
	//

		Position = StrFind(Value, Separator);
	While Position > 0 Do
		Substring = Left(Value, Position - 1);
		If Not SkipEmptyStrings Or Not IsBlankString(Substring) Then
			If TrimNonprintableChars Then
				Result.Add(TrimAll(Substring));
			Else
				Result.Add(Substring);
			EndIf;
		EndIf;
		Value = Mid(Value, Position + StrLen(Separator));
		Position = StrFind(Value, Separator);
	EndDo;

	If Not SkipEmptyStrings Or Not IsBlankString(Value) Then
		If TrimNonprintableChars Then
			Result.Add(TrimAll(Value));
		Else
			Result.Add(Value);
		EndIf;
	EndIf;
	
	Return Result;

EndFunction 

// Determines whether the character is a separator.
//
// Parameters:
//  CharCode      - Number  - code of the char to check;
//  WordSeparators - String - string consisting of chars treated as separators. If the parameter is 
//                             not specified, all characters that are not digits, Latin and Cyrillic 
//                             letters, and an underscore, are considered as separators.
//
// Returns:
//  Boolean - True if a character with the CharCode code is a separator.
//
Function IsWordSeparator(CharCode, WordSeparators = Undefined) Export
	
	If WordSeparators <> Undefined Then
		Return StrFind(WordSeparators, Char(CharCode)) > 0;
	EndIf;
		
	Ranges = New Array;
	Ranges.Add(New Structure("Min,Max", 48, 57)); 		// numbers
	Ranges.Add(New Structure("Min,Max", 65, 90)); 		// Uppercase Latin characters
	Ranges.Add(New Structure("Min,Max", 97, 122)); 		// Lowercase Latin characters
	Ranges.Add(New Structure("Min,Max", 1040, 1103)); 	// Cyrillic characters
	Ranges.Add(New Structure("Min,Max", 1025, 1025)); 	// Сyrillic character "ё" 
	Ranges.Add(New Structure("Min,Max", 1105, 1105)); 	// Сyrillic character "ё" 
	Ranges.Add(New Structure("Min,Max", 95, 95)); 		// "_" character
	
	For Each Range In Ranges Do
		If CharCode >= Range.Min AND CharCode <= Range.Max Then
			Return False;
		EndIf;
	EndDo;
	
	Return True;
	
EndFunction

// Splits the string into several strings using a specified separator set.
// If the WordSeparators parameter is not specified, any of the characters that are not Latin 
// characters, numeric characters, or the underscore character (_) are considered separators.
//
// Parameters:
//  Value - String - an sourcw string to be split into words.
//  WordSeparators - String - a list of separator characters. For example, ".,;".
//
// Returns:
//  Array - a words list.
//
// Example:
//  StringFunctionsClientServer.SplitStringIntoWordsArray("one-@#two2_!three") will return an array of values: "one",
//  "two2_", "three"; StringFunctionsClientServer.SplitStringIntoWordsArray("one-@#two2_!three", 
//  "#@!_") wil return an array of values: "one-", "two2", "three".
Function SplitStringIntoWordArray(Val Value, WordSeparators = Undefined) Export
	
	Words = New Array;
	
	TextSize = StrLen(Value);
	WordBeginning = 1;
	For Position = 1 To TextSize Do
		CharCode = CharCode(Value, Position);
		If IsWordSeparator(CharCode, WordSeparators) Then
			If Position <> WordBeginning Then
				Words.Add(Mid(Value, WordBeginning, Position - WordBeginning));
			EndIf;
			WordBeginning = Position + 1;
		EndIf;
	EndDo;
	
	If Position <> WordBeginning Then
		Words.Add(Mid(Value, WordBeginning, Position - WordBeginning));
	EndIf;
	
	Return Words;
	
EndFunction

// Substitutes parameters in a string. The maximum number of parameters is 9.
// Parameters in the string have the following format: %<parameter number>. The parameter numbering starts from 1.
//
// Parameters:
//  StringPattern  - String - string pattern with parameters formatted as "%<parameter number>", for 
//                           example, "%1 went to %2".
//  Parameter<n>   - String - parameter value to insert.
//
// Returns:
//  String   - text string with parameters inserted.
//
// Example:
//  UT_StringFunctionsClientServer.SubstituteParametersToString(NStr("en='%1 went to %2.'"), "Jane", 
//  "the zoo") = "Jane went to the zoo."
//
Function SubstituteParametersToString(Val StringPattern,
	Val Parameter1, Val Parameter2 = Undefined, Val Parameter3 = Undefined,
	Val Parameter4 = Undefined, Val Parameter5 = Undefined, Val Parameter6 = Undefined,
	Val Parameter7 = Undefined, Val Parameter8 = Undefined, Val Parameter9 = Undefined) Export
	
	HasParametersWithPercentageChar = StrFind(Parameter1, "%")
		Or StrFind(Parameter2, "%")
		Or StrFind(Parameter3, "%")
		Or StrFind(Parameter4, "%")
		Or StrFind(Parameter5, "%")
		Or StrFind(Parameter6, "%")
		Or StrFind(Parameter7, "%")
		Or StrFind(Parameter8, "%")
		Or StrFind(Parameter9, "%");
		
	If HasParametersWithPercentageChar Then
		Return SubstituteParametersWithPercentageChar(StringPattern, Parameter1,
			Parameter2, Parameter3, Parameter4, Parameter5, Parameter6, Parameter7, Parameter8, Parameter9);
	EndIf;
	
	StringPattern = StrReplace(StringPattern, "%1", Parameter1);
	StringPattern = StrReplace(StringPattern, "%2", Parameter2);
	StringPattern = StrReplace(StringPattern, "%3", Parameter3);
	StringPattern = StrReplace(StringPattern, "%4", Parameter4);
	StringPattern = StrReplace(StringPattern, "%5", Parameter5);
	StringPattern = StrReplace(StringPattern, "%6", Parameter6);
	StringPattern = StrReplace(StringPattern, "%7", Parameter7);
	StringPattern = StrReplace(StringPattern, "%8", Parameter8);
	StringPattern = StrReplace(StringPattern, "%9", Parameter9);
	Return StringPattern;
	
EndFunction

// Substitutes parameters in a string. The number of the parameters in the string is unlimited.
// Parameters in the string have the following format: %<parameter number>. The parameter numbering 
// starts from 1.
//
// Parameters:
//  StringPattern  - String - string pattern with parameters formatted as "%<parameter number>", for 
//                           example, "%1 went to %2".
//  Parameters - Array - parameters values in the StringPattern string.
//
// Returns:
//   String - a string with inserted values of parameters.
//
// Example:
//  ParametersValues = New Array;
//  ParametersValues.Add("John");
//  ParametersValues.Add("Zoo");
//  Result = UT_StringFunctionsClientServer.SubstituteParametersToStringFromArray(НСтр("en ='%1 went to %2'"), ParametersValues);
//  - returns the "John went to the Zoo" string.
//
Function SubstituteParametersToStringFromArray(Val StringPattern, Val Parameters) Export
	
	ResultString = StringPattern;
	
	Index = Parameters.Count();
	While Index > 0 Do
		Value = Parameters[Index-1];
		If Not IsBlankString(Value) Then
			ResultString = StrReplace(ResultString, "%" + Format(Index, "NG="), Value);
		EndIf;
		Index = Index - 1;
	EndDo;
	
	Return ResultString;
	
EndFunction

// Substitutes parameter values for their names in the string pattern. Parameters in the string are 
// enclosed in square brackets.
//
// Parameters:
//  StringPattern - String - a string to insert values into.
//  Parameters - Structure - inserted values of parameters, where the key is the name of the 
//                             parameter without special characters, the value is the inserted value.
//
// Returns:
//  String - a string with inserted values.
//
// Example:
//  Values = New Structure("LastName,Name", "Smith", "John");
//  Result = UT_StringFunctionsClientServer.InsertParametersIntoString("Hello, [Name] [LastName].", Values);
//  - Returns: "Hello, John Doe".
//
Function InsertParametersIntoString(Val StringPattern, Val Parameters) Export
	Result = StringPattern;
	For Each Parameter In Parameters Do
		Result = StrReplace(Result, "[" + Parameter.Key + "]", Parameter.Value);
	EndDo;
	Return Result;
EndFunction

// Gets parameter values from the string.
//
// Parameters:
//  ParametersString - a string containing parameters. Each of the parameters is the fragment of the 
//                              <Parameter name>=<Value> kind, where:
//                                Parameter name - the parameter name.
//                                Value - the parameter value.
//                              Substrings are separated from each other by the semicolon character (;).
//                              If the value contains the space character, it must be enclosed in 
//                              double quotation marks (").
//                              Example:
//                               "File=""c:\InfoBases\Trade""; Usr=""Director"";"
//  Separator - String - a character to separate parts.
//
// Returns:
//  Structure - parameters values, where the key is the name of the parameter, the value is the parameter value.
//
// Example:
//  Result = StringFunctionsClientServer.ParametersFromString("File=""c:\InfoBases\Trade""; Usr=""Director"";""", ";");
//  - returns the structure:
//     the File key and the c:\InfoBases\Trade value
//     the Usr key and the Director value.
//
Function ParametersFromString(Val ParametersString, Val Separator = ";") Export
	Result = New Structure;
	
	ParameterDetails = "";
	StringBeginningFound = False;
	LastCharNumber = StrLen(ParametersString);
	For CharNumber = 1 To LastCharNumber Do
		Char =Mid(ParametersString, CharNumber, 1);
		If Char = """" Then
			StringBeginningFound = Not StringBeginningFound;
		EndIf;
		If Char <> Separator Or StringBeginningFound Then
			ParameterDetails = ParameterDetails + Char;
		EndIf;
		If Char = Separator AND Not StringBeginningFound Or CharNumber = LastCharNumber Then
			Position = StrFind(ParameterDetails, "=");
			If Position > 0 Then
				ParameterName = TrimAll(Left(ParameterDetails, Position - 1));
				ParameterValue = TrimAll(Mid(ParameterDetails, Position + 1));
				ParameterValue = RemoveDoubleQuotationMarks(ParameterValue);
				Result.Insert(ParameterName, ParameterValue);
			EndIf;
			ParameterDetails = "";
		EndIf;
	EndDo;
	
	Return Result;
EndFunction

// Checks whether the string contains numeric characters only.
//
// Parameters:
//  Value - String - a checked string.
//  Obsolete - Boolean - the flag that indicates whether the parameter is obsolete.
//  SpacesProhibited - Boolean - if False spaces are allowed in the string.
//
// Returns:
//   Boolean - True - the string contains only numbers or is empty, False - the string contains other characters.
//
// Example:
//  Result = StringFunctionsClientServer.OnlyDigitsInString("0123"); // True
//  Result = StringFunctionsClientServer.OnlyDigitsInString("0123abc"); // False
//  Result = StringFunctionsClientServer.OnlyDigitsInString("01 2 3",, False); // True
//
Function OnlyNumbersInString(Val Value, Val Obsolete = True, Val SpacesProhibited = True) Export
	
	If TypeOf(Value) <> Type("String") Then
		Return False;
	EndIf;
	
	If Not SpacesProhibited Then
		Value = StrReplace(Value, " ", "");
	EndIf;
		
	If StrLen(Value) = 0 Then
		Return True;
	EndIf;
	
	// If the source string contains digits only, the result string after the replacement is empty.
	// The string cannot be checked with IsBlankString because it can contain space characters.
	Return StrLen(
		StrReplace( StrReplace( StrReplace( StrReplace( StrReplace(
		StrReplace( StrReplace( StrReplace( StrReplace( StrReplace( 
			Value, "0", ""), "1", ""), "2", ""), "3", ""), "4", ""), "5", ""), "6", ""), "7", ""), "8", ""), "9", "")) = 0;
	
EndFunction

// Checks whether the string contains Cyrillic characters only.
//
// Parameters:
//  CheckString - String - a checked string.
//  IncludeWordSeparators - Boolean - if True, treat word separators as legit characters.
//  AllowedChars - String - additional allowed characters except Cyrillic.
//
// Returns:
//  Boolean - True if the string contains Cyrillic or allowed chars only or is empty;
//           False otherwise.
//
Function OnlyCyrillicInString(Val CheckString, Val WithWordSeparators = True, AllowedChars = "") Export

	If TypeOf(CheckString) <> Type("String") Then
		Return False;
	EndIf;
	
	If NOT ValueIsFilled(CheckString) Then
		Return True;
	EndIf;

	ValidCharCodes = New Array;
	ValidCharCodes.Add(1105); // "ё"
	ValidCharCodes.Add(1025); // "Ё"

	For Index = 1 To StrLen(AllowedChars) Do
		ValidCharCodes.Add(CharCode(Mid(AllowedChars, Index, 1)));
	EndDo;

	For Index = 1 To StrLen(CheckString) Do
		CharCode = CharCode(Mid(CheckString, Index, 1));
		If ((CharCode < 1040) Or (CharCode > 1103)) 
			AND (ValidCharCodes.Find(CharCode) = Undefined) 
			AND Not (Not WithWordSeparators AND IsWordSeparator(CharCode)) Then
			Return False;
		EndIf;
	EndDo;
	
	Return True;
	
EndFunction

// Checks whether the string contains Latin characters only.
//
// Parameters:
//  CheckString - String - a checked string.
//  IncludeWordSeparators - Boolean - if True, treat word separators as legit characters.
//  AllowedChars - String - additional allowed characters except Latin.
//
// Returns:
//  Boolean - True if the string contains Latin or allowed chars only or is empty;
//         - False otherwise.
//
Function OnlyRomanInString(Val CheckString, Val WithWordSeparators = True, AllowedChars = "") Export
	
	If TypeOf(CheckString) <> Type("String") Then
		Return False;
	EndIf;
	
	If NOT ValueIsFilled(CheckString) Then
		Return True;
	EndIf;
	
	ValidCharCodes = New Array;
	
	For Index = 1 To StrLen(AllowedChars) Do
		ValidCharCodes.Add(CharCode(Mid(AllowedChars, Index, 1)));
	EndDo;
	
	For Index = 1 To StrLen(CheckString) Do
		CharCode = CharCode(Mid(CheckString, Index, 1));
		If ((CharCode < 65) Or (CharCode > 90 AND CharCode < 97) Or (CharCode > 122))
			AND (ValidCharCodes.Find(CharCode) = Undefined) 
			AND Not (Not WithWordSeparators AND IsWordSeparator(CharCode)) Then
			Return False;
		EndIf;
	EndDo;
	
	Return True;
	
EndFunction

// Deletes double quotation marks from the beginning and the end of the string, if any.
//
// Parameters:
//  Value - String - a source string.
//
// Returns:
//  String - a string without double quotation marks.
// 
Function RemoveDoubleQuotationMarks(Val Value) Export
	
	While StrStartsWith(Value, """") Do
		Value = Mid(Value, 2); 
	EndDo; 
	
	While StrEndsWith(Value, """") Do
		Value = Left(Value, StrLen(Value) - 1);
	EndDo;
	
	Return Value;
	
EndFunction 

// Deletes the specified number of characters from the end of the string.
//
// Parameters:
//  Text - String - a string where last characters need to be deleted.
//  CountOfCharacters - Number - a number of characters to be deleted.
//
Procedure DeleteLastCharInString(Text, CountOfChars = 1) Export
	
	Text = Left(Text, StrLen(Text) - CountOfChars);
	
EndProcedure 

// Checks whether a string is a UUID.
// UUID is a string of the following kind
// "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", where X = [0..9,a..f].
//
// Parameters:
//  Value - String - a checked string.
//
// Returns:
//  Boolean - True if the passed string is a UUID.
//
Function IsUUID(Val Value) Export
	
	Template = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
	
	If StrLen(Template) <> StrLen(Value) Then
		Return False;
	EndIf;
	For Position = 1 To StrLen(Value) Do
		If CharCode(Template, Position) = 88 // X
			AND ((CharCode(Value, Position) < 48 Or CharCode(Value, Position) > 57) // 0..9
			AND (CharCode(Value, Position) < 97 Or CharCode(Value, Position) > 102) // a..f
			AND (CharCode(Value, Position) < 65 Or CharCode(Value, Position) > 70)) // A..F
			Or CharCode(Template, Position) = 45 AND CharCode(Value, Position) <> 45 Then // -
				Return False;
		EndIf;
	EndDo;
	
	Return True;

EndFunction

// Generates a string of the specified length filled with the specified character.
//
// Parameters:
//  Char - String - a character used to generated a string.
//  StringLength - Number - a required length of a resulting string.
//
// Returns:
//  String - a string filled with the repeating character.
//
Function GenerateCharacterString(Val Char, Val StringLength) Export
	
	Result = "";
	For Counter = 1 To StringLength Do
		Result = Result + Char;
	EndDo;
	
	Return Result;
	
EndFunction

// Supplements the string to a specified length with characters on the left or on the right and returns it.
// At the same time the insignificant characters are removed from the left and the right (for more 
// information on insignificant characters, see the syntax assistant for the TrimAll platform method).
// By default, the function supplements a string with 0 (zero) characters on the left.
//
// Parameters:
//  Value - String - a source string to be supplemented with characters.
//  StringLength - Number - a required resulting length of a string.
//  Char - String - a character used for supplementing the string.
//  Mode - String - "Left" or "Right" - an option to add characters to the source string.
// 
// Returns:
//  String - a string supplemented with characters.
//
// Example:
//  1. Result = StringFunctionsClientServer.SupplementString("1234", 10, "0", "Left");
//  Returns: "0000001234".
//
//  2. Result = StringFunctionsClientServer.SupplementString(" 1234  ", 10, "#", "Right");
//  String = " 1234  "; StringLength = 10; Char = "#"; Mode = "Right"
//  Returns: "1234######".
//
Function SupplementString(Val Value, Val StringLength, Val Char = "0", Val Mode = "Left") Export
	
	// The parameter must be a single character.
	Char = Left(Char, 1);
	
	// Deleting spaces on the left and on the right of the string.
	Value = TrimAll(Value);
	CharsToAddCount = StringLength - StrLen(Value);
	
	If CharsToAddCount > 0 Then
		
		StringToAdd = GenerateCharacterString(Char, CharsToAddCount);
		If Upper(Mode) = "LEFT" Then
			Value = StringToAdd + Value;
		ElsIf Upper(Mode) = "RIGHT" Then
			Value = Value + StringToAdd;
		EndIf;
		
	EndIf;
	
	Return Value;
	
EndFunction

// Deletes repeating characters on the left or on the right of the string.
//
// Parameters:
//  Value - String - a source string where repeating characters on the left or on the right should be deleted.
//  CharToDelete - String - a required character to be deleted.
//  Mode - String - "Left" or "Right" - a mode of character deletion in the source string.
//
// Returns:
//  String - a cut string.
//
Function DeleteDuplicateChars(Val Value, Val CharToDelete, Val Mode = "Left") Export
	
	If Upper(Mode) = "LEFT" Then
		While Left(Value, 1) = CharToDelete Do
			Value = Mid(Value, 2);
		EndDo;
	ElsIf Upper(Mode) = "RIGHT" Then
		While Right(Value, 1) = CharToDelete Do
			Value = Left(Value, StrLen(Value) - 1);
		EndDo;
	EndIf;
	
	Return Value;
	
EndFunction

// Replaces characters in the string.
// The function is designed for simple replacement scenarios, for example, for replacing the Ä character with the A character.
//
// Parameters:
//  CharsToReplace - String - a string of characters to be replaced.
//  Value - String - a source string in which character replacement is required.
//  ReplacementChars - String - a string of characters to be replaced by the characters of the
//                               CharsToReplace parameter.
// 
// Returns:
//  String - a string after characters replacement.
//
Function ReplaceCharsWithOther(CharsToReplace, Value, ReplacementChars) Export
	
	Result = Value;
	
	For CharNumber = 1 To StrLen(CharsToReplace) Do
		Result = StrReplace(Result, Mid(CharsToReplace, CharNumber, 1), Mid(ReplacementChars, CharNumber, 1));
	EndDo;
	
	Return Result;
	
EndFunction

// Converts the Arabic number into a Roman one.
//
// Parameters:
//  ArabicNumber - Number - a number, integer from 0 to 999.
//  UseLatinChars - Boolean - use Cyrillic or Latin alphabet as a Roman digits.
//
// Returns:
//  String - a number in Latin notation.
//
// Example:
//  StringFunctionsClientServer.ConvertNumberIntoRomanNotation(17) = "ХVII".
//
Function ConvertNumberIntoRomanNotation(ArabicNumber, UseLatinChars = True) Export
	
	RomanNumber = "";
	ArabicNumber = SupplementString(ArabicNumber, 3);

	If NOT UseLatinChars Then
		c1 = "1";
		c5 = "У";
		c10 = "Х";
		c50 = "Л";
		c100 ="С";
		c500 = "Д";
		c1000 = "М";

	Else
		c1 = "I";
		c5 = "V";
		c10 = "X";
		c50 = "L";
		c100 ="C";
		c500 = "D";
		c1000 = "M";

	EndIf;

	Units	= Number(Mid(ArabicNumber, 3, 1));
	Tens	= Number(Mid(ArabicNumber, 2, 1));
	Hundreds	= Number(Mid(ArabicNumber, 1, 1));
	
	RomanNumber = RomanNumber + ConvertFigureIntoRomanNotation(Hundreds, c100, c500, c1000);
	RomanNumber = RomanNumber + ConvertFigureIntoRomanNotation(Tens, c10, c50, c100);
	RomanNumber = RomanNumber + ConvertFigureIntoRomanNotation(Units, c1, c5, c10);
	
	Return RomanNumber;
	
EndFunction 

// Converts the Roman number into an Arabic one.
//
// Parameters:
//  RomanNumber - String - a number written in roman numerals.
//  UseLatinChars - Boolean - use Cyrillic or Latin alphabet as a Roman digits.
//
// Returns:
//  Number - a converted number.
//
// Example:
//  StringFunctionsClientServer.ConvertNumberIntoArabicNotation("ХVII") = 17.
//
Function ConvertNumberIntoArabicNotation(RomanNumber, UseLatinChars = True) Export
	
	ArabicNumber = 0;

	IF NOT UseLatinChars Then
		c1 = "1";
		c5 = "У";
		c10 = "Х";
		c50 = "Л";
		c100 ="С";
		c500 = "Д";
		c1000 = "М";
	Else
		c1 = "I";
		c5 = "V";
		c10 = "X";
		c50 = "L";
		c100 ="C";
		c500 = "D";
		c1000 = "M";
	EndIf;

	RomanNumber = TrimAll(RomanNumber);
	CountOfChars = StrLen(RomanNumber);
	
	For Cnt = 1 To CountOfChars Do
		If Mid(RomanNumber,Cnt,1) = c1000 Then
			ArabicNumber = ArabicNumber+1000;
		ElsIf Mid(RomanNumber,Cnt,1) = c500 Then
			ArabicNumber = ArabicNumber+500;
		ElsIf Mid(RomanNumber,Cnt,1) = c100 Then
			If (Cnt < CountOfChars) AND ((Mid(RomanNumber,Cnt+1,1) = c500) Or (Mid(RomanNumber,Cnt+1,1) = c1000)) Then
				ArabicNumber = ArabicNumber-100;
			Else
				ArabicNumber = ArabicNumber+100;
			EndIf;
		ElsIf Mid(RomanNumber,Cnt,1) = c50 Then
			ArabicNumber = ArabicNumber+50;
		ElsIf Mid(RomanNumber,Cnt,1) = c10 Then
			If (Cnt < CountOfChars) AND ((Mid(RomanNumber,Cnt+1,1) = c50) Or (Mid(RomanNumber,Cnt+1,1) = c100)) Then
				ArabicNumber = ArabicNumber-10;
			Else
				ArabicNumber = ArabicNumber+10;
			EndIf;
		ElsIf Mid(RomanNumber,Cnt,1) = c5 Then
			ArabicNumber = ArabicNumber+5;
		ElsIf Mid(RomanNumber,Cnt,1) = c1 Then
			If (Cnt < CountOfChars) AND ((Mid(RomanNumber,Cnt+1,1) = c5) Or (Mid(RomanNumber,Cnt+1,1) = c10)) Then
				ArabicNumber = ArabicNumber-1;
			Else
				ArabicNumber = ArabicNumber+1;
			EndIf;
		EndIf;
	EndDo;
	
	Return ArabicNumber;
	
EndFunction  

// Deletes HTML tags from the text and returns an unformatted text.
//
// Parameters:
//  SourceText - String - a text of the HTML format.
//
// Returns:
//  String - free of tags, scripts, and headers text.
//
Function ExtractTextFromHTML(Val SourceText) Export
	Result = "";
	
	Text = Lower(SourceText);
	
	// Removing everything except body
	Position = StrFind(Text, "<body");
	If Position > 0 Then
		Text = Mid(Text, Position + 5);
		SourceText = Mid(SourceText, Position + 5);
		Position = StrFind(Text, ">");
		If Position > 0 Then
			Text = Mid(Text, Position + 1);
			SourceText = Mid(SourceText, Position + 1);
		EndIf;
	EndIf;
	
	Position = StrFind(Text, "</body>");
	If Position > 0 Then
		Text = Left(Text, Position - 1);
		SourceText = Left(SourceText, Position - 1);
	EndIf;
	
	// Removing scripts
	Position = StrFind(Text, "<script");
	While Position > 0 Do
		ClosingTagPosition = StrFind(Text, "</script>");
		If ClosingTagPosition = 0 Then
			// The closing tag is not found, cut out the remaining text.
			ClosingTagPosition = StrLen(Text);
		EndIf;
		Text = Left(Text, Position - 1) + Mid(Text, ClosingTagPosition + 9);
		SourceText = Left(SourceText, Position - 1) + Mid(SourceText, ClosingTagPosition + 9);
		Position = StrFind(Text, "<script");
	EndDo;
	
	// Removing styles
	Position = StrFind(Text, "<style");
	While Position > 0 Do
		ClosingTagPosition = StrFind(Text, "</style>");
		If ClosingTagPosition = 0 Then
			// The closing tag is not found, cut out the remaining text.
			ClosingTagPosition = StrLen(Text);
		EndIf;
		Text = Left(Text, Position - 1) + Mid(Text, ClosingTagPosition + 8);
		SourceText = Left(SourceText, Position - 1) + Mid(SourceText, ClosingTagPosition + 8);
		Position = StrFind(Text, "<style");
	EndDo;
	
	// removing all tags	
	Position = StrFind(Text, "<");
	While Position > 0 Do
		Result = Result + Left(SourceText, Position-1);
		Text = Mid(Text, Position + 1);
		SourceText = Mid(SourceText, Position + 1);
		Position = StrFind(Text, ">");
		If Position > 0 Then
			Text = Mid(Text, Position + 1);
			SourceText = Mid(SourceText, Position + 1);
		EndIf;
		Position = StrFind(Text, "<");
	EndDo;
	Result = Result + SourceText;
	RowsArray = SplitStringIntoSubstringsArray(Result, Chars.LF, True, True);
	Return TrimAll(StrConcat(RowsArray, Chars.LF));
EndFunction

// Transliterates the source string.
// It can be used to send text messages in Latin characters or to save files and folders to ensure 
// that they can be transferred between different operating systems.
// Reverse conversion from the Latin character is not available.
//
// Parameters:
//  Value - String - an arbitrary string.
//
// Returns:
//  String - a string where Cyrillic is replaced by transliteration.
//
Function LatinString(Val Value) Export
	
	Result = "";

	Map = MapOfCyrillicAndLatinAlphabets();

	For Position = 1 To StrLen(Value) Do
		Char = Mid(Value, Position, 1);
		LatinChar = Map[Lower(Char)]; // Searching ignoring the case.
		If LatinChar = Undefined Then
			// Other characters remain "as is".
			LatinChar = Char;
		Else
			If Char = Upper(Char) Then
				LatinChar = Title(LatinChar); // restoring the case
			EndIf;
		EndIf;
		Result = Result + LatinChar;
	EndDo;

	Return Result;
EndFunction

// Generates a string according to the specified pattern.
// The possible tag values in the template:
// - <b> String </b> - formats the string as bold.
// - <a href = "Ref"> String </a> - adds a hyperlink.
// For example, "The lowest supported version is <b>1.1</b>. <a href = "Update"> Update</a> the application."
//
// Parameters:
//  StringWithTags - String - a string containing formatting tags.
//
// Returns:
//  FormattedString - a converted string.
//
Function FormattedString(Val StringWithTags) Export

	BoldStrings = New ValueList;
	While StrFind(StringWithTags, "<b>") <> 0 Do
		BoldBeginning = StrFind(StringWithTags, "<b>");
		StringBeforeOpeningTag = Left(StringWithTags, BoldBeginning - 1);
		BoldStrings.Add(StringBeforeOpeningTag);
		StringAfterOpeningTag = Mid(StringWithTags, BoldBeginning + 3);
		BoldEnd = StrFind(StringAfterOpeningTag, "</b>");
		BoldFragment = Left(StringAfterOpeningTag, BoldEnd - 1);
		BoldStrings.Add(BoldFragment,, True);
		StringAfterBold = Mid(StringAfterOpeningTag, BoldEnd + 4);
		StringWithTags = StringAfterBold;
	EndDo;
	BoldStrings.Add(StringWithTags);

	StringsWithLinks = New ValueList;
	For Each StringPart In BoldStrings Do
		
		StringWithTags = StringPart.Value;
		
		If StringPart.Check Then
			StringsWithLinks.Add(StringWithTags,, True);
			Continue;
		EndIf;

			BoldBeginning = StrFind(StringWithTags, "<a href = ");
		While BoldBeginning <> 0 Do
			StringBeforeOpeningTag = Left(StringWithTags, BoldBeginning - 1);
			StringsWithLinks.Add(StringBeforeOpeningTag, );
			
			StringAfterOpeningTag = Mid(StringWithTags, BoldBeginning + 9);
			EndTag = StrFind(StringAfterOpeningTag, ">");
			
			Ref = TrimAll(Left(StringAfterOpeningTag, EndTag - 2));
			If StrStartsWith(Ref, """") Then
				Ref = Mid(Ref, 2, StrLen(Ref) - 1);
			EndIf;
			If StrEndsWith(Ref, """") Then
				Ref = Mid(Ref, 1, StrLen(Ref) - 1);
			EndIf;

			StringAfterLink = Mid(StringAfterOpeningTag, EndTag + 1);
			BoldEnd = StrFind(StringAfterLink, "</a>");
			HyperlinkAnchorText = Left(StringAfterLink, BoldEnd - 1);
			StringsWithLinks.Add(HyperlinkAnchorText, Ref);
			
			StringAfterBold = Mid(StringAfterLink, BoldEnd + 4);
			StringWithTags = StringAfterBold;
			
			BoldBeginning = StrFind(StringWithTags, "<a href = ");
		EndDo;
		StringsWithLinks.Add(StringWithTags);
		
	EndDo;

	RowArray = New Array;
	For Each StringPart In StringsWithLinks Do
		
		If StringPart.Check Then
			RowArray.Add(New FormattedString(StringPart.Value, New Font(,,True)));
		ElsIf Not IsBlankString(StringPart.Presentation) Then
			RowArray.Add(New FormattedString(StringPart.Value,,,, StringPart.Presentation));
		Else
			RowArray.Add(StringPart.Value);
		EndIf;

	EndDo;
	
	Return New FormattedString(RowArray);
	
EndFunction

// Converts the source string into a number without calling exceptions.
//
// Parameters:
//   Value - String - a string to be transformed into a number.
//                       For example, "10", "+10", "010", will return 10.
//                                 "(10)", "-10", will return -10.
//                                 "10,2", "10.2", will return 10.2.
//                                 "000", " ", "",will return 0.
//                                 "10text", will return Undefined.
//
// Returns:
//   Number, Undefined - received number or Undefined if the string is not a number.
//
Function StringToNumber(Val Value) Export
	
	Value  = StrReplace(Value, " ", "");
	If StrStartsWith(Value, "(") Then
		Value = StrReplace(Value, "(", "-");
		Value = StrReplace(Value, ")", "");
	EndIf;
	
	StringWithoutZeroes = StrReplace(Value, "0", "");
	If IsBlankString(StringWithoutZeroes) Or StringWithoutZeroes = "-" Then
		Return 0;
	EndIf;
	
	NumberType  = New TypeDescription("Number");
	Result = NumberType.AdjustValue(Value);
	
	Return ?(Result <> 0 AND Not IsBlankString(StringWithoutZeroes), Result, Undefined);
	
EndFunction

// Converts a source string into a date.
//
// Parameters:
//  Value - String - a string to be transformed into a date.
//                      Date format needs to look like DD.MM.YYYY, DD/MM/YY, or DD-MM-YY,
//                      For example, "23.02.1980" or "23/02/80".
// 
// Returns:
//  Date - the received date.
//
Function StringToDate(Val Value) Export

	SpacePosition = StrFind(Value, " ", SearchDirection.FromBegin);
	If SpacePosition > 0 Then
		Value = Left(Value, SpacePosition - 1);
	EndIf;
	Value = StrReplace(Value, " ", "");
	Value = TrimAll(StrReplace(Value, ".", ""));
	Value = TrimAll(StrReplace(Value, "/", ""));
	Value = TrimAll(StrReplace(Value, "-", ""));
	Value = Mid(Value, 5) + Mid(Value, 3, 2) + Left(Value, 2);
	If StrLen(Value) = 6 Then
		Year = StringToNumber(Left(Value, 2));
		Value = ?(Year > 29, "19", "20") + Value;
	EndIf;

	TypeDetails = New TypeDescription("Date");
	Result    = TypeDetails.AdjustValue(Value);
	
	Return Result;

EndFunction 

// Generates the presentation of a number for a certain language and number parameters.
//
// Parameters:
//  Template          - String - contains semicolon-separated 6 string forms for each numeral 
//                             category: 
//                             - %1 denotes the number position;
//  Number           - Number - a number to be inserted instead of the "%1" parameter.
//  Kind             - NumericValueType - defines a kind of the numeric value for which a presentation is formed.
//                             - Cardinal (default) or Ordinal.
//  FormatString - String - a string of formatting parameters. See similar example for StringWithNumber. 
//
// Returns:
//  String - presentation of the number string in the requested format.
//
// Example:
//
//  // Parameter presentation:
//  //
//  // Lang | Zero | One             | Two            | Few               | Many                  | Other
//  // ============================================================================================================
//  // en   |      | XX1 / X11       |                | XX2-XX4 / X12-X14 | XX0, XX5-XX9, X11-X14 | fractional
//  // Card.|      | %1 day left |                | %1 days left   | %1 days left      | %1 days left
//  //      |      | see %1 fish    |                | see %1 fish     | see %5 fish        | see %1 fish
//  // ------------------------------------------------------------------------------------------------------------
//  // ru  |      |                 |                |                   |                       | there is no other ones
//  // Ord. |      |                 |                |                   |                       | %1th day 
//  // ------------------------------------------------------------------------------------------------------------
//  // en   |      | for 1           |                |                   |                       | the rest of it
//  // Card.|      | left %1 day     |                |                   |                       | left %1 days
//  // ------------------------------------------------------------------------------------------------------------
//  // en   |      | XX1 / X11       | XX2 / X12      | XX3 / X13         |                       | the rest of it
//  // Ord. |      | %1st day        | %1nd day       | %1rd day          |                       | %1th day.
//
//  // Card. - Cardinal - cardinal.
//  // Ord.  - Ordinal  - ordinal.
//  // X - any number.
//  // / - except for.
//  
//  String = StringFunctionsClientServer.StringWithNumberForAnyLanguage(
//		NStr("ru=';остался %1 день;;осталось %1 дня;осталось %1 дней;осталось %1 дня';
//		     |en=';left %1 day;;;;left %1 days'"), 
//		0.05,, "NFD=1");
// 
Function StringWithNumberForAnyLanguage(Template, Number, Kind = Undefined, FormatString = Undefined) Export

	If IsBlankString(Template) Then
		Return Format(Number, FormatString); 
	EndIf;

	If Kind = Undefined Then
		Kind = NumericValueType.Cardinal;
	EndIf;

	Return StringWithNumber(Template, Number, Kind, FormatString);

EndFunction


// Returns the name corresponding to the identifier
// (as automatic synonym filling when specifying the name of the metadata object)
//
// Parameters:
// Identifier - String -
//
Function IdentifierPresentation(Identifier) Export
	
	Length = StrLen(Identifier);
	Name  = Left(Identifier, 1);
	For Counter = 2 TO Length Do
		Char = Mid(Identifier, Counter, 1);
		If Upper(Char) = Char And Lower(Char) <> Char Then
			Name  = Name  + " " + Lower(Char);
		ElsIf Char = "_" Then
			Name  = Name  + " ";
		Else
			Name  = Name  + Char;
		EndIf;
	EndDo;
	Return Name ;
	
EndFunction


// Returns the number that is specified at the end of the strings
//
// Parameters:
// Value - the string from which to get the number
// Return value:
// Number - The number specified at the end of the string. Undefined- if there is no number at the end of the string
//
Function NumberAtStringEnd(Val Value) Export
	
	CurrentValue=Value;
	CharsAmountOnRight=0;
	
	While OnlyNumbersInString(Right(CurrentValue, 1)) Do
		CharsAmountOnRight=CharsAmountOnRight + 1;
		DeleteLastCharInString(CurrentValue, 1);
	EndDo;
	
	If ValueIsFilled(CharsAmountOnRight) Then
		Return StringToNumber(Прав(Value, CharsAmountOnRight));
	Else 
		Return Undefined;
	EndIf;
EndFunction

// Wrap strings in Quotation Marks, if not wrapped yet
Function WrapInOuotationMarks(Val String) Export
	
	If Left(String, 1) = """" And Right(String, 1) = """" Then
		Return String;
	Else
		Return """" + String + """";
	EndIf;
	
EndFunction

//Removes the leading and ending quotes from the passed string
Function PathWithoutQuotes(Val String) Export
	
	If Left(String, 1) = """" And Right(String, 1) = """" Then
		Return Mid(String, 2 , StrLen(String) - 2);
	Else
		Return String;
	EndIf;
	
КонецФункции 

// Analog of the platform function StrStartsWith
Function StringStartsWithSubString(AnalyzedString, SubString) Export
	Return Left(AnalyzedString, StrLen(SubString))= SubString;
EndFunction

// Analog of the platform function StrEndsWith
Function StringsEndsWithSubString(AnalyzedString, SubString) Export
	Return Right(AnalyzedString, StrLen(SubString))=SubString
EndFunction

// Obsolete. Use StrFind instead.
//
// Search for the character starting from the end of the string.
//
// Parameters:
//  String - String - a string where search is performed.
//  Char - String - a character to search. You can search for string of more than a single character.
//
// Returns:
//  Number - position of a character in the string.
//          If the string does not contains the specified character, 0 is returned.
//
Function FindCharFromEnd(Val Row, Val Char) Export
	
	For Position = -StrLen(Row) To -1 Do
		If Mid(Row, -Position, StrLen(Char)) = Char Then
			Return -Position;
		EndIf;
	EndDo;
	
	Return 0;
		
EndFunction

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Converts the Arabic numerals into Roman numerals.
//
// Parameters:
//	Figure - Number - a figure from 0 to 9.
//  RomanOne, RomanFive, RomanTen - String - characters matching Latin figures.
//
// Returns
//	String - a figure in Latin notation.
//
// Example: 
//	StringFunctionsClientServer.ConvertDigitIntoRomanNotation(7,"I","V","X") = "VII".
//
Function ConvertFigureIntoRomanNotation(Figure, RomanOne, RomanFive, RomanTen)
	
	RomanFigure="";
	If Figure = 1 Then
		RomanFigure = RomanOne
	ElsIf Figure = 2 Then
		RomanFigure = RomanOne + RomanOne;
	ElsIf Figure = 3 Then
		RomanFigure = RomanOne + RomanOne + RomanOne;
	ElsIf Figure = 4 Then
		RomanFigure = RomanOne + RomanFive;
	ElsIf Figure = 5 Then
		RomanFigure = RomanFive;
	ElsIf Figure = 6 Then
		RomanFigure = RomanFive + RomanOne;
	ElsIf Figure = 7 Then
		RomanFigure = RomanFive + RomanOne + RomanOne;
	ElsIf Figure = 8 Then
		RomanFigure = RomanFive + RomanOne + RomanOne + RomanOne;
	ElsIf Figure = 9 Then
		RomanFigure = RomanOne + RomanTen;
	EndIf;
	Return RomanFigure;
	
EndFunction

// Substitutes parameters in the string for %1, %2, and so on.
Function SubstituteParametersWithPercentageChar(Val SubstitutionString,
	Val Parameter1, Val Parameter2 = Undefined, Val Parameter3 = Undefined,
	Val Parameter4 = Undefined, Val Parameter5 = Undefined, Val Parameter6 = Undefined,
	Val Parameter7 = Undefined, Val Parameter8 = Undefined, Val Parameter9 = Undefined)

	Result = "";
	Position = StrFind(SubstitutionString, "%");
	While Position > 0 Do 
		Result = Result + Left(SubstitutionString, Position - 1);
		CharAfterPercentage = Mid(SubstitutionString, Position + 1, 1);
		ParameterToSubstitute = Undefined;
		If CharAfterPercentage = "1" Then
			ParameterToSubstitute = Parameter1;
		ElsIf CharAfterPercentage = "2" Then
			ParameterToSubstitute = Parameter2;
		ElsIf CharAfterPercentage = "3" Then
			ParameterToSubstitute = Parameter3;
		ElsIf CharAfterPercentage = "4" Then
			ParameterToSubstitute = Parameter4;
		ElsIf CharAfterPercentage = "5" Then
			ParameterToSubstitute = Parameter5;
		ElsIf CharAfterPercentage = "6" Then
			ParameterToSubstitute = Parameter6;
		ElsIf CharAfterPercentage = "7" Then
			ParameterToSubstitute = Parameter7
		ElsIf CharAfterPercentage = "8" Then
			ParameterToSubstitute = Parameter8;
		ElsIf CharAfterPercentage = "9" Then
			ParameterToSubstitute = Parameter9;
		EndIf;
		If ParameterToSubstitute = Undefined Then
			Result = Result + "%";
			SubstitutionString = Mid(SubstitutionString, Position + 1);
		Else
			Result = Result + ParameterToSubstitute;
			SubstitutionString = Mid(SubstitutionString, Position + 2);
		EndIf;
		Position = StrFind(SubstitutionString, "%");
	EndDo;
	Result = Result + SubstitutionString;
	
	Return Result;
EndFunction

Function MapOfCyrillicAndLatinAlphabets()
	// Transliteration used in Russian international passports 1997-2010.
	Map = New Map;
	Map.Insert("а", "a");
	Map.Insert("б", "b");
	Map.Insert("в", "v");
	Map.Insert("г", "g");
	Map.Insert("д", "d");
	Map.Insert("е", "e");
	Map.Insert("ё", "e");
	Map.Insert("ж", "zh");
	Map.Insert("з", "z");
	Map.Insert("и", "i");
	Map.Insert("й", "y");
	Map.Insert("к", "k");
	Map.Insert("л", "l");
	Map.Insert("м", "m");
	Map.Insert("н", "n");
	Map.Insert("о", "o");
	Map.Insert("п", "p");
	Map.Insert("р", "r");
	Map.Insert("с", "s");
	Map.Insert("т", "t");
	Map.Insert("у", "u");
	Map.Insert("ф", "f");
	Map.Insert("х", "kh");
	Map.Insert("ц", "ts");
	Map.Insert("ч", "ch");
	Map.Insert("ш", "sh");
	Map.Insert("щ", "shch");
	Map.Insert("ъ", ""); // skip
	Map.Insert("ы", "y");
	Map.Insert("ь", ""); // skip
	Map.Insert("э", "e");
	Map.Insert("ю", "yu");
	Map.Insert("я", "ya");

	Return Map;
EndFunction

#КонецОбласти