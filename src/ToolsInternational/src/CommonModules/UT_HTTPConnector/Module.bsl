// Connector: handy HTTP-client for 1C:Enterprise 8 platform
//
// Copyright 2017-2021 Vladimir Bondarevskiy
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
//
// URL:    https://github.com/vbondarevsky/Connector
// e-mail: vbondarevsky@gmail.com
// Version: 2.3.1
//
// Requirements: 1C:Enterprise platform version **8.3.10** and higher.

#Region Public

#Region HTTPMethods

#Region CommonUseMethods

// Sends a GET request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   RequestParameters - Structure, Map - URL parameters to append to the URL (a part after ?):
//     * Key - String - URL parameter key.
//     * Value - String - URL parameter value
//                  - Array - makes a string from several parameters: key=value1&key=value2 и т.д.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   see CallMethod
//
Function Get(URL, RequestParameters = Undefined, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, RequestParameters, Undefined, Undefined);
	Return CallHTTPMethod(CurrentSession, "GET", URL, AdditionalParameters);

EndFunction

// Sends an OPTION request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   see CallMethod
//
Function Options(URL, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, Undefined, Undefined, Undefined);
	Return CallHTTPMethod(CurrentSession, "OPTIONS", URL, AdditionalParameters);

EndFunction

// Sends a HEAD request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   see CallMethod
//
Function Head(URL, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, Undefined, Undefined, Undefined);
	Return CallHTTPMethod(CurrentSession, "HEAD", URL, AdditionalParameters);

EndFunction

// Sends a POST request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   Data - Structure, Map, String, BinaryData - see details in AdditionalParameters.Data.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   see CallMethod
//
Function Post(URL, Data = Undefined, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, Undefined, Data, Undefined);
	Return CallHTTPMethod(CurrentSession, "POST", URL, AdditionalParameters);

EndFunction

// Sends a PUT request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   Data - Structure, Map, String, BinaryData - see details in AdditionalParameters.Data.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   see CallMethod
//
Function Put(URL, Data = Undefined, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, Undefined, Data, Undefined);
	Return CallHTTPMethod(CurrentSession, "PUT", URL, AdditionalParameters);

EndFunction

// Sends a PATCH request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   Data - Structure, Map, String, BinaryData - see details in AdditionalParameters.Data.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   see CallMethod
//
Function Patch(URL, Data = Undefined, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, Undefined, Data, Undefined);
	Return CallHTTPMethod(CurrentSession, "PATCH", URL, AdditionalParameters);

EndFunction

// Sends a DELETE request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   Data - Structure, Map, String, BinaryData - see details in AdditionalParameters.Data.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   see CallMethod
//
Function Delete(URL, Data = Undefined, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, Undefined, Data, Undefined);
	Return CallHTTPMethod(CurrentSession, "DELETE", URL, AdditionalParameters);

EndFunction

#EndRegion

#Region SimplifiedMethodsForJSONRequests

// Sends a GET request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   RequestParameters - Structure, Map - URL parameters to append to the URL (a part after ?).
//     see details in Session.RequestParameters.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   Map, Structure - deserialized response from JSON.
//     Conversion parameters see in AdditionalParameters.JSONConversionParameters.
//
Function GetJson(URL,
				RequestParameters = Undefined,
				AdditionalParameters = Undefined,
				Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, RequestParameters, Undefined, Undefined);
	JSONConversionParameters =
		SelectValue(Undefined, AdditionalParameters, "JSONConversionParameters", Undefined);
	Return AsJson(CallHTTPMethod(CurrentSession, "GET", URL, AdditionalParameters), JSONConversionParameters);

EndFunction

// Sends a POST request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   Json - Structure, Map - data to serialize into JSON.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   Map, Structure - deserialized response from JSON.
//     Conversion parameters see in AdditionalParameters.JSONConversionParameters
//
Function PostJson(URL, Json, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, Undefined, Undefined, Json);
	JSONConversionParameters =
		SelectValue(Undefined, AdditionalParameters, "JSONConversionParameters", Undefined);
	Return AsJson(CallHTTPMethod(CurrentSession, "POST", URL, AdditionalParameters), JSONConversionParameters);

EndFunction

// Sends a PUT request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   Json - Structure, Map - data to serialize into JSON.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   Map, Structure - deserialized response from JSON.
//     Conversion parameters see in AdditionalParameters.JSONConversionParameters
//
Function PutJson(URL, Json, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, Undefined, Undefined, Json);
	JSONConversionParameters =
		SelectValue(Undefined, AdditionalParameters, "JSONConversionParameters", Undefined);
	Return AsJson(CallHTTPMethod(CurrentSession, "PUT", URL, AdditionalParameters), JSONConversionParameters);

EndFunction

// Sends a DELETE request
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//   Json - Structure, Map - data to serialize into JSON.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   Map, Structure - deserialized response from JSON.
//     Conversion parameters see in AdditionalParameters.JSONConversionParameters
//
Function DeleteJson(URL, Json, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, Undefined, Undefined, Json);
	JSONConversionParameters =
		SelectValue(Undefined, AdditionalParameters, "JSONConversionParameters", Undefined);
	Return AsJson(CallHTTPMethod(CurrentSession, "DELETE", URL, AdditionalParameters), JSONConversionParameters);

EndFunction

#EndRegion

// Additional parameters constructor
//
// Returns:
//  Structure - Allows you to set additional parameters.:
//    * Headers - Map - see details in Session.Headers.
//    * Authentication - Structure - see details in Session.Authentication
//    * Proxy - InternetProxy - see details in Session.Proxy.
//    * RequestParameters - Structure, Map - see details in Session.RequestParameters.
//    * VerifySSL - Boolean - see details in Session.VerifySSL.
//    * ClientSSLCertificate - FileClientCertificate, WindowsClientCertificate - Default value: Undefined.
//    * Cookies - Array - see details in Session.Cookies.
//    * Timeout - Number - connections and operations timeout, in seconds.
//        Default value - 30 sec.
//    * AllowRedirect - Boolean - True - redirects are allowed automatically.
//                                          False - a single request will be sent to the host.
//    * Json - Structure, Map - data to serialize into JSON.
//    * JSONConversionParameters - Structure - sets JSON conversion parameters:
//        ** ReadToMap - Boolean - If True, JSON object will be read in Map, otherwise in Structure.
//        ** JSONDateFormat - JSONDateFormat - Sets the date serialization format.
//        ** PropertiesNamesWithDateValues -  String, Array of Strings - JSON properties names,
//             For the specified properties date restoration from string will be called.
//    * JSONWriterSettings - JSONWriterSettings - Defines a set of parameters used for JSON writing..
//    * Data - String, BinaryData - arnitrary data to send in a request. 
//             - Structure, Map - form fields to send in a request:
//                 ** Key - String - field name.
//                 ** Value - String - field value.
//    * Files - see NewFileToSend, Array from NewFileToSend - files to send
//    * MaximumNumberOfRetries - Number - Number of connection/request sending retries.
//        Delay duration between attempts grows exponentially.
//        But, if the status code is one of 413, 429, 503
//        and response has the Retry-After header,
//        delay duration value is taken from this header value
//        Default value: 0 - no retries.
//    * MaximumTimeOfRetries - Number - max. total time (in seconds) of sending request and retries.
//        Default value: 600.
//    * ExponentialDelayRatio - Number - exponential delay factor.
//        1 forms the delays sequence: 1, 2, 4, 8 и т.д.
//        2 forms the delays sequence: 2, 4, 8, 16 и т.д.
//        ...
//        Default value: 1.
//    * ToRetryForStatusesCodes - Undefined - retries will run for status codes >= 500.
//                                 - Array - retries will run for specific status codes.
//        Default value: Undefined.
//
Function NewParameters() Export

	Parameters = New Structure;
	Parameters.Insert("Headers", New Map);
	Parameters.Insert("Authentication", Undefined);
	Parameters.Insert("Proxy", Undefined);
	Parameters.Insert("RequestParameters", Undefined);
	Parameters.Insert("VerifySSL", True);
	Parameters.Insert("ClientSSLCertificate", Undefined);
	Parameters.Insert("Cookies", New Map);
	Parameters.Insert("Timeout", TimeoutByDefault());
	Parameters.Insert("AllowRedirect", True);
	Parameters.Insert("Json", Undefined);
	Parameters.Insert("JSONConversionParameters", New Structure);
	Parameters.Insert("Data", Undefined);
	Parameters.Insert("Files", New Array);
	Parameters.Insert("MaximumNumberOfRetries", 0);
	Parameters.Insert("MaximumTimeOfRetries", 600);
	Parameters.Insert("ExponentialDelayRatio", 1);
	Parameters.Insert("ToRetryForStatusesCodes", Undefined);
	
	Return Parameters;

EndFunction

// A constructor of a submitting file description
//
// Parameters:
//   Name - String - form field name.
//   FileName - String - file name.
//   Data - BinaryData - file binary data.
//   Type - String - file MIME-type
//
// Returns:
//  Structure:
//    * Name - String - form field name.
//    * FileName - String - file name.
//    * Data - BinaryData - file binary data.
//    * Type - String - file MIME-type.
//    * Headers - Map - HTTP request headers.
//
Function NewFileToSend(Name, FileName, Data = Undefined, Type = Undefined) Export
	
	File = New Structure;
	File.Insert("Name", Name);
	File.Insert("FileName", FileName);
	File.Insert("Data", ?(Data = Undefined, Base64Value(""), Data));
	File.Insert("Type", Type);
	File.Insert("Headers", New Map);
	
	Return File;
	
EndFunction

// Sends data to a specific URL with a specific HTTP verb.
//
// Parameters:
//   Method - String - HTTP request verb name.
//   URL - String - HTTP URL to send the request to.
//   AdditionalParameters - see NewParameters
//   Session - see NewSession
//
// Returns:
//   Structure - a response for the executed request:
//     * ExecutionTime - Number - execution response duration in milliseconds.
//     * Cookies - Map - cookies received from host.
//     * Headers - Map - HTTP response headers.
//     * IsPermanentRedirect - Boolean - permanent redirect flag.
//     * IsRedirect - Boolean - redirect flag.
//     * Encoding - String - response text encoding.
//     * Body - BinaryData - response body.
//     * StatusCode - Number - response status code.
//     * URL - String - final request URL.
//
Function CallMethod(Method, URL, AdditionalParameters = Undefined, Session = Undefined) Export

	CurrentSession = CurrentSession(Session);
	FillAdditionalData(AdditionalParameters, Undefined, Undefined, Undefined);
	Return CallHTTPMethod(CurrentSession, Method, URL, AdditionalParameters);

EndFunction

// Session constructor.
//
// Returns:
//  Structure - session parameters:
//    * Headers - Map - HTTP request headers.
//    * Authentication - Structure - request authentication parameters.
//          ** UseOSAuthentication - Boolean - Contains the current value of NTLM or Negotiate authentication use.
//                                                   Default value: False.
//          ** Type - String - authentication type. The Basic type can be omitted.
//       If Type = Digest or Basic:
//          ** User - String - user name.
//          ** Password - String - user password.
//       If Type = AWS4-HMAC-SHA256:
//          ** AccessKeyID - String - Access key ID.
//          ** SecretKey - String - secret key.
//          ** Service - String - service to be connected.
//          ** Region - String - region to be connected.
//    * Proxy - InternetProxy - proxy parameters to send request.
//        Default value: Undefined. If your configuration based on `SSL`,
//        proxy settings will be taken from `SSL` by default.
//    * RequestParameters - Structure, Map - URL parameters to append to the URL (a part after ?):
//        * Key - String - URL parameter key.
//        * Value - String - URL parameter value
//                     - Array - makes a string from several parameters: key=value1&key=value2 etc.
//    * VerifySSL - Boolean - False - If it is not specified, the server certificate is not verified.
//                            - True - the value OSCertificationAuthorityCertificates is used.
//                   - FileCertificationAuthorityCertificates - see FileCertificationAuthorityCertificates.
//        Default value: True.
//    * ClientSSLCertificate - FileClientCertificate, WindowsClientCertificate - Default value: Undefined.
//    * MaximumNumberOfRedirects - Number - max. number of redirections. Looping protection.
//        Default value: 30
//    * Cookies - Map - cookies set.
//
Function NewSession() Export

	Session = New Structure;
	Session.Insert("Headers", DefaultHeaders());
	Session.Insert("Authentication", Undefined);
	Session.Insert("Proxy", Undefined);
	Session.Insert("RequestParameters", New Structure);
	Session.Insert("VerifySSL", True);
	Session.Insert("ClientSSLCertificate", Undefined);
	Session.Insert("MaximumNumberOfRedirects", MaximumNumberOfRedirects());
	Session.Insert("Cookies", New Map);
	Session.Insert("ServiceData", New Structure("DigestParameters"));

	Return Session;

EndFunction

#EndRegion

#Region ResponsesFormats

// Returns host response as deserialized JSON value.
//
// Parameters:
//   Response - see CallMethod
//   JSONConversionParameters - Structure - sets JSON conversion parameters.
//     * ReadToMap - Boolean - If True, JSON object will be read in Map, otherwise in Structure.
//     * JSONDateFormat - JSONDateFormat - Specifies a deserialization format of dates of the JSON objects.
//     * PropertiesNamesWithDateValues -  Array, String - JSON properties names,
//          For the specified properties date restoration from string will be called.
//
// Returns:
//   Map - host response as JSON deserialized value.
//     If ConversionParameters.ReadToMap = True (by default).
//   Structure - If ConversionParameters.ReadToMap = False.
//
Function AsJson(Response, JSONConversionParameters = Undefined) Export

	Try
		Return JsonToObject(UnpackResponse(Response), Response.Encoding, JSONConversionParameters);
	Except
		ResponseAsText = AsText(Response);
		ExceptionTextMaxLength = 1000;
		If StrLen(ResponseAsText) <= ExceptionTextMaxLength Then
			ExceptionText = ResponseAsText;
		Else
			HalfOfExceptionTextMaxLength = ExceptionTextMaxLength / 2;
			ExceptionText = Left(ResponseAsText, HalfOfExceptionTextMaxLength);
			ExceptionText = ExceptionText + Chars.LF + "..." + Chars.LF;
			ExceptionText = ExceptionText + Прав(ResponseAsText, HalfOfExceptionTextMaxLength);
		EndIf;
		Raise ExceptionText;
	EndTry;

EndFunction

// Returns host response as text.
//
// Parameters:
//   Response - see CallMethod
//   Encoding - String, TextEncoding - contains text encoding.
//     If value is empty, the encoding is taken from Response.Encoding.
//
// Returns:
//   String - host response as text.
//
Function AsText(Response, Encoding = Undefined) Export

	If Not ValueIsFilled(Encoding) Then
		Encoding = Response.Encoding;
	EndIf;

	TextReader = New TextReader(UnpackResponse(Response).OpenStreamForRead(), Encoding);
	Text = TextReader.Read();
	TextReader.Close();

	If Text = Undefined Then
		Text = "";
	EndIf;

	Return Text;

EndFunction

// Returns host response as binary data.
//
// Parameters:
//   Response - see CallMethod
//
// Returns:
//   String - host response as binary data.
//
Function AsBinaryData(Response) Export

	Return UnpackResponse(Response);

EndFunction

// Returns host response as XDTO.
//
// Parameters:
//   Response - see CallMethod
//   XMLReaderSettings - XMLReaderSettings - Parameters for reading XML data
//     See details of the method XMLReader.OpenStream in the Syntax Assistant
//   XMLSchemaSet - XMLSchemaSet - An XML schema set used for validation of the document being read.
//     If a schema set is speficied but not validated and XML document validation is enabled, the schema set is validated.
//     See details of the method XMLReader.OpenStream in the Syntax Assistant
//   Encoding - String, TextEncoding - Contains the input stream encoding.
//     See details of the method XMLReader.OpenStream in the Syntax Assistant
//
// Returns:
//   XDTOObject, XDTOList - Return value can have any type that supports serialization to XDTO.
//
Function AsXDTO(Response,
				XMLReaderSettings = Undefined,
				XMLSchemaSet = Undefined,
				Encoding = Undefined) Export

	BinaryData = UnpackResponse(Response);
	StreamForRead = BinaryData.OpenStreamForRead();

	If Not ValueIsFilled(Encoding) Then
		Encoding = Response.Encoding;
	EndIf;

	XMLReader = New XMLReader;
	XMLReader.OpenStream(StreamForRead, XMLReaderSettings, XMLSchemaSet, Encoding);

	XDTOObject = XDTOFactory.ReadXML(XMLReader);

	Return XDTOObject;

EndFunction

#EndRegion

#Region SupportingMethods

// Returns a structured URL presentation.
//
// Parameters:
//   URL - String - HTTP URL to send the request to.
//
// Returns:
//   Structure - Structure URL:
//     * Scheme - String - access server scheme (http, https).
//     * Authentification - Structure - authentification parameters:
//         ** User - String - user name.
//         ** Password - String - user password.
//     * Host - String - host address.
//     * Port - Number - host port.
//     * Path - String - адрес ресурса на сервере.
//     * RequestParameters - Map - URL parameters to append to the URL (a part after ?):
//         ** Key - String - URL parameter key.
//         ** Value - String - URL parameter value;
//                       - Array - parameter's values (key=value1&key=value2).
//     * Fragment - String - a part of URL after #.
//
Function ParseURL(Val URL) Export

	Scheme = "";
	Path = "";
	Authentication = New Structure("User, Password", "", "");
	Host = "";
	Port = "";
	Fragment = "";

	ValidSchemes = StrSplit("http,https", ",");

	URLWithoutScheme = URL;
	SplitStringByDelimiter(Scheme, URLWithoutScheme, "://");
	If ValidSchemes.Find(Lower(Scheme)) <> Undefined Then
		URL = URLWithoutScheme;
	Else
		Scheme = "";
	EndIf;

	Result = SplitByFirstFoundDelimiter(URL, StrSplit("/,?,#", ","));
	URL = Result[0];
	If ValueIsFilled(Result[2]) Then
		Path = Result[2] + Result[1];
	EndIf;

	AuthString = "";
	SplitStringByDelimiter(AuthString, URL, "@");
	If ValueIsFilled(AuthString) Then
		AuthParts = StrSplit(AuthString, ":");
		Authentication.User = AuthParts[0];
		If AuthParts.Count() > 1 Then
			Authentication.Password = AuthParts[1];
		EndIf;
	EndIf;

	// IPv6
	SplitStringByDelimiter(Host, URL, "]");
	If ValueIsFilled(Host) Then
		Host = Host + "]";
	EndIf;

	URL = StrReplace(URL, "/", "");

	SplitStringByDelimiter(Port, URL, ":", True);

	If Not ValueIsFilled(Host) Then
		Host = URL;
	EndIf;

	If ValueIsFilled(Port) Then
		Port = Number(Port);
	Else
		Port = 0;
	EndIf;

	SplitStringByDelimiter(Fragment, Path, "#", True);

	RequestParameters = FillRequestParameters(Path);

	If Not ValueIsFilled(Scheme) Then
		Scheme = "http";
	EndIf;

	If Not ValueIsFilled(Path) Then
		Path = "/";
	EndIf;

	Result = New Structure;
	Result.Insert("Scheme", Scheme);
	Result.Insert("Authentication", Authentication);
	Result.Insert("Host", Host);
	Result.Insert("Port", Port);
	Result.Insert("Path", Path);
	Result.Insert("RequestParameters", RequestParameters);
	Result.Insert("Fragment", Fragment);

	Return Result;

EndFunction

// Converts Object into JSON.
//
// Parameters:
//   Object - Arbitrary - data to convert into JSON.
//   ConversionParameters - Structure.
//     * JSONDateFormat - JSONDateFormat - Specifies a deserialization format of dates of the JSON objects.
//     * JSONDateWritingVariant - JSONDateWritingVariant - Specifies JSON date writing options.
//     * ConvertionFunctionName - String - This function is called for all properties if their types
//         do not support direct conversion to JSON format.
//         Function should be exported and must have the following parameters:
//           ** Property - String - Name of property is transferred into the parameter if the structure
//                or mapping is written.
//           ** Value - String - The source value is transferred into the parameter.
//           ** AdditionalParameters - Arbitrary - Additional parameters specified in the call to the
//                WriteJSON method.
//           ** Cancel - Boolean - Cancels the property write operation.
//         Function return value:
//           Arbitrary - conversion result.
//     * ConvertionFunctionModule - Arbitrary - Specifies the module, in which the JSON conversion function is implemented.
//     * ConvertionFunctionAdditionalParameters - Arbitrary - Additional parameters to be transferred to the conversion function.
//   WriterSettings - Structure - JSON conversion parameters:
//     * NewLines - JSONLineBreak - Manages the setting of the start and the end of the objects and arrays,
//         keys and values in a new string.
//     * PaddingSymbols - String - Specifies the indent characters used when writing a JSON document.
//     * UseDoubleQuotes - Boolean - Specifies to use double quotes when writing the JSON properties and values.
//     * EscapeCharacters - JSONCharactersEscapeMode - Specifies the character screening method when writing
//         a JSON document.
//     * EscapeAngleBrackets - Boolean - Specifies if the angle brackets characters will be screened when
//         writing a JSON document.
//     * EscapeLineTerminators - Boolean - Specifies screening of the characters "U+2028" (string separator)
//         and "U+2029" (paragraph separator) for JavaScript compatibility.
//     * EscapeAmpersand - Boolean - Specifies if the ampersand character will be screened when writing a JSON document.
//     * EscapeSingleQuotes - Boolean - Specifies if the single quotes character will be screened when writing a JSON document.
//     * EscapeSlash - Boolean - Defines whether slash is screened while writing a value.
//
// Returns:
//   String - object in JSON format.
//
Function ObjectToJson(Object, Val ConversionParameters = Undefined, Val WriterSettings = Undefined) Export

	JSONConversionParameters = SupplementJSONConversionParameters(ConversionParameters);

	SerializerSettings = New JSONSerializerSettings;
	SerializerSettings.DateSerializationFormat = JSONConversionParameters.JSONDateFormat;
	SerializerSettings.DateWritingVariant = JSONConversionParameters.JSONDateWritingVariant;

	WriterSettings = SupplementJSONWriterSettings(WriterSettings);

	JSONWriterSettings = New JSONWriterSettings(
		WriterSettings.NewLines,
		WriterSettings.PaddingSymbols,
		WriterSettings.UseDoubleQuotes,
		WriterSettings.EscapeCharacters,
		WriterSettings.EscapeAngleBrackets,
		WriterSettings.EscapeLineTerminators,
		WriterSettings.EscapeAmpersand,
		WriterSettings.EscapeSingleQuotes,
		WriterSettings.EscapeSlash);

	JSONWriter = New JSONWriter;
	JSONWriter.SetString(JSONWriterSettings);

	If JSONConversionParameters.ConvertionFunctionName <> Undefined
		And JSONConversionParameters.ConvertionFunctionModule <> Undefined Then
		WriteJSON(JSONWriter, Object, SerializerSettings,
			JSONConversionParameters.ConvertionFunctionName,
			JSONConversionParameters.ConvertionFunctionModule,
			JSONConversionParameters.ConvertionFunctionAdditionalParameters);
	Else
		WriteJSON(JSONWriter, Object, SerializerSettings);
	EndIf;

	Return JSONWriter.Close();

EndFunction

// Converts JSON into Object.
//
// Parameters:
//   Json - Stream, BinaryData, String - JSON data.
//   Encoding - String - JSON text encoding. Default value - utf-8.
//   ConversionParameters - Structure - JSON conversion parameters:
//     * ReadToMap - Boolean - If True, JSON object will be read in Map,
//                                         otherwise in Structure.
//     * PropertiesNamesWithDateValues - Array, String, FixedArray - JSON properties names,
//             For the specified properties date restoration from string will be called.
//     * JSONDateFormat - JSONDateFormat - Specifies a deserialization format of dates of the JSON objects.
//
// Returns:
//   Arbitrary - deserialized value from JSON.
//
Function JsonToObject(Json, Encoding = "utf-8", ConversionParameters = Undefined) Export

	JSONConversionParameters = SupplementJSONConversionParameters(ConversionParameters);

	JSONReader = New JSONReader;
	If TypeOf(Json) = Type("BinaryData") Then
		JSONReader.OpenStream(Json.OpenStreamForRead(), Encoding);
	ElsIf TypeOf(Json) = Type("String") Then
		JSONReader.SetString(Json);
	Else
		JSONReader.OpenStream(Json, Encoding);
	EndIf;
	Object = ReadJSON(
		JSONReader,
		JSONConversionParameters.ReadToMap,
		JSONConversionParameters.PropertiesNamesWithDateValues,
		JSONConversionParameters.JSONDateFormat);
	JSONReader.Close();

	Return Object;

EndFunction

// Calculates HMAC (hash-based message authentication code).
//
// Parameters:
//   Key - BinaryData - secret key.
//   Data - BinaryData - data to calculate HMAC.
//   Algorithm - HashFunction - Defines method for calculating the hash-sum.
//
// Returns:
//   BinaryData - calculated HMAC value.
//
Function HMAC(Key_, Data, Algorithm) Export

	BlockSize = 64;

	If Key_.Size() > BlockSize Then
		Hashing = New DataHashing(Algorithm);
		Hashing.Append(Key_);

		BufferKey = GetBinaryDataBufferFromBinaryData(Hashing.HashSum);
	Else
		BufferKey = GetBinaryDataBufferFromBinaryData(Key_);
	EndIf;

	ModifiedKey = New BinaryDataBuffer(BlockSize);
	ModifiedKey.Write(0, BufferKey);

	InternalKey = ModifiedKey.Copy();
	ExternalKey = ModifiedKey;

	InternalAlignment = New BinaryDataBuffer(BlockSize);
	ExternalAlignment = New BinaryDataBuffer(BlockSize);
	For Index = 0 To BlockSize - 1 Do
		InternalAlignment.Set(Index, 54);
		ExternalAlignment.Set(Index, 92);
	EndDo;

	InternalHashing = New DataHashing(Algorithm);
	ExternalHashing = New DataHashing(Algorithm);

	InternalKey.WriteBitwiseXor(0, InternalAlignment);
	ExternalKey.WriteBitwiseXor(0, ExternalAlignment);

	ExternalHashing.Append(GetBinaryDataFromBinaryDataBuffer(ExternalKey));
	InternalHashing.Append(GetBinaryDataFromBinaryDataBuffer(InternalKey));

	If ValueIsFilled(Data) Then
		InternalHashing.Append(Data);
	EndIf;

	ExternalHashing.Append(InternalHashing.HashSum);

	Return ExternalHashing.HashSum;

EndFunction

// Returns the structure of the named HTTP status codes.
//
// Returns:
//   Structure - named HTTP status codes.
//
Function HTTPStatusCodes() Export

	StatusCodes = New Structure;
	For Each Description In HTTPStatusesCodesDescriptions() Do
		StatusCodes.Insert(Description.Key, Description.Code);
	EndDo;

	Return StatusCodes;

EndFunction

// Returns a text presentation of HTTP status code.
//
// Parameters:
//   StatusCode - Number - HTTP status code to get a text presentation.
//
// Returns:
//   String - HTTP status code as text presentation.
//
Function HTTPStatusCodePresentation(StatusCode) Export

	StatusCodeDescription = Undefined;
	For Each Description In HTTPStatusesCodesDescriptions() Do
		If Description.Code = StatusCode Then
			StatusCodeDescription = Description;
			Break;
		EndIf;
	EndDo;

	If StatusCodeDescription = Undefined Then
		Raise(StrTemplate(НСтр("ru = 'Неизвестный код состояния HTTP: %1'; en = 'Неизвестный код состояния HTTP: %1'"), StatusCode));
	Else
		Return StrTemplate("%1: %2", StatusCodeDescription.Code, StatusCodeDescription.Description);
	EndIf;

EndFunction

// Reads data from a GZip archive.
//
// Parameters:
//   CompressedData - BinaryData - data packed into GZip.
//
// Returns:
//   BinaryData - unpacked data.
//
Function ReadGZip(CompressedData) Export

	GZipPrefixSize = 10;
	GZipPostfixSize = 8;

	DataReader = New DataReader(CompressedData);
	DataReader.Skip(GZipPrefixSize);
	CompressedDataSize = DataReader.SourceStream().Size() - GZipPrefixSize - GZipPostfixSize;

	ZipStream = New MemoryStream(ZipLFHSize() + CompressedDataSize + ZipDDSize() + ZipCDHSize() + ZipEOCDSize());
	DataWriter = New DataWriter(ZipStream);
	DataWriter.WriteBinaryDataBuffer(ZipLFH());
	DataReader.CopyTo(DataWriter, CompressedDataSize);

	DataWriter.Close();
	DataWriter = New DataWriter(ZipStream);

	CRC32 = DataReader.ReadInt32();
	UncompressedDataSize = DataReader.ReadInt32();
	DataReader.Close();

	DataWriter.WriteBinaryDataBuffer(ZipDD(CRC32, CompressedDataSize, UncompressedDataSize));
	DataWriter.WriteBinaryDataBuffer(ZipCDH(CRC32, CompressedDataSize, UncompressedDataSize));
	DataWriter.WriteBinaryDataBuffer(ZipEOCD(CompressedDataSize));
	DataWriter.Close();

	Return ReadZip(ZipStream);

EndFunction

// Writes data to GZip archive.
//
// Parameters:
//   Data - BinaryData - initial data.
//
// Returns:
//   BinaryData - data packed into GZip.
//
Function WriteGZip(Data) Export

	DataReader = New DataReader(WriteZip(Data));

	InitialOffset = 14;
	DataReader.Skip(InitialOffset);
	CRC32 = DataReader.ReadInt32();

	CompressedDataSize = DataReader.ReadInt32();
	SourceDataSize = DataReader.ReadInt32();

	FileNameSize = DataReader.ReadInt16();
	AdditionalFieldSize = DataReader.ReadInt16();
	DataReader.Skip(FileNameSize + AdditionalFieldSize);

	GZipStream = New MemoryStream;
	DataWriter = New DataWriter(GZipStream);
	DataWriter.WriteBinaryDataBuffer(GZipHeader());
	DataReader.CopyTo(DataWriter, CompressedDataSize);
	DataWriter.Close();
	DataWriter = New DataWriter(GZipStream);

	DataWriter.WriteBinaryDataBuffer(GZipFooter(CRC32, SourceDataSize));

	Return GZipStream.CloseAndGetBinaryData();

EndFunction

#EndRegion

#EndRegion

#Region Protected

Function PrepareRequest(Session, Method, URL, AdditionalParameters) Export

	Cookies = SelectValue(Undefined, AdditionalParameters, "Cookies", New Array);
	Cookies = MergeCookies(RefillCookie(Session.Cookies, URL), RefillCookie(Cookies, URL));

	AuthenticationFromAdditionalParameters =
		SelectValue(Undefined, AdditionalParameters, "Authentication", New Structure);
	RequestParametersFromAdditionalParameters =
		SelectValue(Undefined, AdditionalParameters, "RequestParameters", New Structure);
	HeadersFromAdditionalParameters =
		SelectValue(Undefined, AdditionalParameters, "Headers", New Map);

	Authentication = MergeAuthenticationParameters(AuthenticationFromAdditionalParameters, Session.Authentication);
	RequestParameters = MergeRequestParameters(RequestParametersFromAdditionalParameters, Session.RequestParameters);
	Headers = MergeHeaders(HeadersFromAdditionalParameters, Session.Headers);
	JSONConversionParameters =
		SelectValue(Undefined, AdditionalParameters, "JSONConversionParameters", Undefined);

	PreparedRequest = New Structure;
	PreparedRequest.Insert("Cookies", Cookies);
	PreparedRequest.Insert("Authentication", Authentication);
	PreparedRequest.Insert("Method", Method);
	PreparedRequest.Insert("Headers", Headers);
	PreparedRequest.Insert("RequestParameters", RequestParameters);
	PreparedRequest.Insert("URL", PrepareURL(URL, RequestParameters));
	PreparedRequest.Insert("JSONConversionParameters", JSONConversionParameters);

	PrepareCookies(PreparedRequest);

	Data = SelectValue(Undefined, AdditionalParameters, "Data", New Structure);
	Files = SelectValue(Undefined, AdditionalParameters, "Files", New Array);
	Json = SelectValue(Undefined, AdditionalParameters, "Json", Undefined);
	JSONWriterSettings = SelectValue(Undefined, AdditionalParameters, "JSONWriterSettings", Undefined);

	PrepareRequestBody(PreparedRequest, Data, Files, Json, JSONWriterSettings);
	PrepareAuthentication(PreparedRequest);

	Return PreparedRequest;

EndFunction

#EndRegion

#Region Private

Function IsStatusCodeForWhichRetryAfterHeaderMustBeConsidered(StatusCode)

	Codes = HTTPStatusCodes();
	Return StatusCode = Codes.PayloadTooLarge_413
		Or StatusCode = Codes.TooManyRequests_429
		Or StatusCode = Codes.ServiceUnavailable_503;

EndFunction

Function NumberFromString(Val String) Export

	ATypeDescription = New TypeDescription("Number");
	Return ATypeDescription.AdjustValue(String);

EndFunction

Function DateFromString(Val String) Export

	DateQualifier = New DateQualifiers(DateFractions.DateTime);
	ATypeDescription = New TypeDescription("Date", Undefined, Undefined, DateQualifier);
	Return ATypeDescription.AdjustValue(String);

EndFunction

Function DateFromStringRFC7231(Val String) Export

	Delimiters = ",-:/\.";
	For Index = 1 To StrLen(Delimiters) Do
		Delimiter = Mid(Delimiters, Index, 1);
		String = StrReplace(String, Delimiter, " ");
	EndDo;
	String = StrReplace(String, "  ", " ");
	DateComponents = StrSplit(String, " ");
	MonthString = DateComponents[2];

	Months = StrSplit("Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec", ",");
	Month = Months.Find(MonthString);
	If Month = Undefined Then
		Return '00010101';
	EndIf;

	Date = DateComponents[3] + Format(Month + 1, "ЧЦ=2; ЧВН=;") + DateComponents[1];
	Time = DateComponents[4] + DateComponents[5] + DateComponents[6];

	Return DateFromString(Date + Time);

EndFunction

Function CallHTTPMethod(Session, Method, URL, AdditionalParameters)

	HTTPStatusCodes = HTTPStatusCodes();

	PreparedRequest = PrepareRequest(Session, Method, URL, AdditionalParameters);

	ConnectionSettings = ConnectionSettings(Method, URL, AdditionalParameters);

	Response = SendRequest(Session, PreparedRequest, ConnectionSettings);

	NumberOfRedirects = 0;
	While NumberOfRedirects < Session.MaximumNumberOfRedirects Do
		If Not ConnectionSettings.AllowRedirect Or Not Response.IsRedirect Then
			Return Response;
		EndIf;

		NewURL = NewURLOnRedirect(Response);

		PreparedRequest.URL = EncodeString(NewURL, StringEncodingMethod.URLInURLEncoding);
		NewHTTPRequest = New HTTPRequest(AssembleResourceAddress(ParseURL(NewURL), Undefined));
		OverrideMethod(PreparedRequest, Response);

		If Response.StatusCode <> HTTPStatusCodes.TemporaryRedirect_307
			And Response.StatusCode <> HTTPStatusCodes.PermanentRedirect_308 Then
			RemoveHeaders(PreparedRequest.Headers, "content-length,content-type,transfer-encoding");
			NewHTTPRequest.Headers = PreparedRequest.Headers;
		Else
			SourceStream = PreparedRequest.HTTPRequest.GetBodyAsStream();
			SourceStream.CopyTo(NewHTTPRequest.GetBodyAsStream());
		EndIf;
		PreparedRequest.HTTPRequest = NewHTTPRequest;
		RemoveHeaders(PreparedRequest.Headers, "cookies");

		PreparedRequest.Cookies = MergeCookies(Session.Cookies, PreparedRequest.Cookies);
		PrepareCookies(PreparedRequest);

		// INFO: по хорошему аутентификацию нужно привести к новых параметрам, но пока будем игнорировать.

		Response = SendRequest(Session, PreparedRequest, ConnectionSettings);

		NumberOfRedirects = NumberOfRedirects + 1;
	EndDo;

	Raise("TooManyRedirects");

EndFunction

Function NewURLOnRedirect(Response)

	NewURL = HeaderValue("location", Response.Headers);
	NewURL = DecodeString(NewURL, StringEncodingMethod.URLInURLEncoding);

	// Редирект без схемы
	If StrStartsWith_ThisModule(NewURL, "//") Then
		URLComposition = ParseURL(Response.URL);
		NewURL = URLComposition.Scheme + ":" + NewURL;
	EndIf;

	URLComposition = ParseURL(NewURL);
	If Not ValueIsFilled(URLComposition.Host) Then
		URLResponseComposition = ParseURL(Response.URL);
		BaseURL = StrTemplate("%1://%2", URLResponseComposition.Scheme, URLResponseComposition.Host);
		If ValueIsFilled(URLResponseComposition.Port) Then
			BaseURL = BaseURL + ":" + Format(URLResponseComposition.Port, "ЧРГ=; ЧГ=");
		EndIf;
		NewURL = BaseURL + NewURL;
	EndIf;

	Return NewURL;

EndFunction

Procedure RemoveHeaders(Headers, HeadersListAsString)

	HeadersToRemove = New Array;
	HeadersList = StrSplit(HeadersListAsString, ",", False);
	For Each Header In Headers Do
		If HeadersList.Find(Lower(Header.Key)) <> Undefined Then
			HeadersToRemove.Add(Header.Key);
		EndIf;
	EndDo;
	For Each HeaderToRemove In HeadersToRemove Do
		Headers.Delete(HeaderToRemove);
	EndDo;

EndProcedure

Function ConnectionSettings(Method, URL, AdditionalParameters)

	AllowRedirect =
		ValueByKey(AdditionalParameters, "AllowRedirect", Upper(Method) <> "HEAD");
	VerifySSL = ValueByKey(AdditionalParameters, "VerifySSL", True);
	ClientSSLCertificate = ValueByKey(AdditionalParameters, "ClientSSLCertificate");
	Proxy = ValueByKey(AdditionalParameters, "Proxy", ProxyByDefault(URL));
	MaximumNumberOfRetries = ValueByKey(AdditionalParameters, "MaximumNumberOfRetries", 0);
	ToRetryForStatusesCodes =
		ValueByKey(AdditionalParameters, "ToRetryForStatusesCodes", Undefined);
	ExponentialDelayRatio =
		ValueByKey(AdditionalParameters, "ExponentialDelayRatio", 1);
	MaximumTimeOfRetries = ValueByKey(AdditionalParameters, "MaximumTimeOfRetries", 600);

	Settings = New Structure;
	Settings.Insert("Timeout", Timeout(AdditionalParameters));
	Settings.Insert("AllowRedirect", AllowRedirect);
	Settings.Insert("VerifySSL", VerifySSL);
	Settings.Insert("ClientSSLCertificate", ClientSSLCertificate);
	Settings.Insert("Proxy", Proxy);
	Settings.Insert("MaximumNumberOfRetries", MaximumNumberOfRetries);
	Settings.Insert("ToRetryForStatusesCodes", ToRetryForStatusesCodes);
	Settings.Insert("ExponentialDelayRatio", ExponentialDelayRatio);
	Settings.Insert("MaximumTimeOfRetries", MaximumTimeOfRetries);

	Return Settings;

EndFunction

Function Timeout(AdditionalParameters)

	If AdditionalParameters.Property("Timeout") And ValueIsFilled(AdditionalParameters.Timeout) Then
		Timeout = AdditionalParameters.Timeout;
	Else
		Timeout = TimeoutByDefault();
	EndIf;

	Return Timeout;

EndFunction

Function ProxyByDefault(URL)

	ProxyByDefault = New InternetProxy;
	// BSLLS:ExecuteExternalCodeInCommonModule-off
	CMNameGetFilesSSL = "GetFilesFromInternet";
	If Metadata.CommonModules.Find(CMNameGetFilesSSL) <> Undefined Then
		URLComposition = ParseURL(URL);
		Модуль = Eval(CMNameGetFilesSSL);
		ProxyByDefault = Модуль.GetProxy(URLComposition.Scheme);
	EndIf;
	// BSLLS:ExecuteExternalCodeInCommonModule-on

	Return ProxyByDefault;

EndFunction

Function RefillCookie(Cookies, URL)

	URLComposition = ParseURL(URL);
	NewCookies = New Array;
	If TypeOf(Cookies) = Type("Array") Then
		For Each Cookie In Cookies Do
			NewCookie = CookieConstructor(Cookie.Description, Cookie.Value);
			FillPropertyValues(NewCookie, Cookie);

			If Not ValueIsFilled(NewCookie.Domain) Then
				NewCookie.Domain = URLComposition.Host;
			EndIf;
			If Not ValueIsFilled(NewCookie.Path) Then
				NewCookie.Path = "/";
			EndIf;

			NewCookies.Add(NewCookie);
		EndDo;

		Return NewCookies;
	EndIf;

	Return Cookies;

EndFunction

Procedure DeleteCookieFromRepository(CookiesRepository, Cookie)

	If CookiesRepository.Get(Cookie.Domain) <> Undefined
		And CookiesRepository[Cookie.Domain].Get(Cookie.Path) <> Undefined
		And CookiesRepository[Cookie.Domain][Cookie.Path].Get(Cookie.Description) <> Undefined Then
		CookiesRepository[Cookie.Domain][Cookie.Path].Delete(Cookie.Description);
	EndIf;

EndProcedure

Procedure AddCookieToRepository(CookiesRepository, Cookie, ToReplace = False)

	If CookiesRepository.Get(Cookie.Domain) = Undefined Then
		CookiesRepository[Cookie.Domain] = New Map;
	EndIf;
	If CookiesRepository[Cookie.Domain].Get(Cookie.Path) = Undefined Then
		CookiesRepository[Cookie.Domain][Cookie.Path] = New Map;
	EndIf;
	If CookiesRepository[Cookie.Domain][Cookie.Path].Get(Cookie.Description) = Undefined Or ToReplace Then
		CookiesRepository[Cookie.Domain][Cookie.Path][Cookie.Description] = Cookie;
	EndIf;

EndProcedure

Function AddLeadingDot(Val Domain)

	If Not StrStartsWith(Domain, ".") Then
		Domain = "." + Domain;
	EndIf;

	Return Domain;

EndFunction

Procedure FillListWithFilteredCookies(Cookies, URLComposition, List)

	For Each Cookie In Cookies Do
		If Cookie.Value.OnlySecureConnection = True And URLComposition.Scheme <> "https" Then
			Continue;
		EndIf;
		// INFO: проверка срока действия игнорируется (Cookie.Value.ExpiresOn)
		// INFO: проверка порта игнорируется

		List.Add(Cookie.Value);
	EndDo;

EndProcedure

Function SelectCookiesForRequest(URLComposition, Cookies)

	IsHostInRequest = AddLeadingDot(URLComposition.Host);

	Result = New Array;
	For Each Domain In Cookies Do
		If Not StrEndsWith(IsHostInRequest, Domain.Key) Then
			Continue;
		EndIf;
		For Each Path In Domain.Value Do
			If Not StrStartsWith(URLComposition.Path, Path.Key) Then
				Continue;
			EndIf;
			FillListWithFilteredCookies(Path.Value, URLComposition, Result);
		EndDo;
	EndDo;

	Return Result;

EndFunction

Function PrepareCookieHeader(PreparedRequest)

	URLComposition = ParseURL(PreparedRequest.URL);

	Cookies = New Array;
	For Each Cookie In SelectCookiesForRequest(URLComposition, PreparedRequest.Cookies) Do
		Cookies.Add(StrTemplate("%1=%2", Cookie.Description, Cookie.Value));
	EndDo;

	Return StrConcat(Cookies, "; ");

EndFunction

Procedure PrepareCookies(PreparedRequest)

	CookieHeader = PrepareCookieHeader(PreparedRequest);
	If ValueIsFilled(CookieHeader) Then
		PreparedRequest.Headers["Cookie"] = CookieHeader;
	EndIf;

EndProcedure

Function EncodeRequestParameters(RequestParameters)

	RequestParametersParts = New Array;
	For Each Parameter In RequestParameters Do
		If TypeOf(Parameter.Value) = Type("Array") Then
			Values = Parameter.Value;
		Else
			Values = New Array;
			Values.Add(Parameter.Value);
		EndIf;

		If Parameter.Value = Undefined Then
			RequestParametersParts.Add(Parameter.Key);
		Else
			For Each Value In Values Do
				ParameterValue = EncodeString(Value, StringEncodingMethod.URLEncoding);
				RequestParametersParts.Add(StrTemplate("%1=%2", Parameter.Key, ParameterValue));
			EndDo;
		EndIf;
	EndDo;

	Return StrConcat(RequestParametersParts, "&");

EndFunction

Function PrepareURL(Val URL, RequestParameters = Undefined)

	URL = TrimL(URL);

	URLComposition = ParseURL(URL);

	PreparedURL = URLComposition.Scheme + "://";
	If ValueIsFilled(URLComposition.Authentication.User) Then
		PreparedURL = PreparedURL
			+ URLComposition.Authentication.User + ":"
			+ URLComposition.Authentication.Password + "@";
	EndIf;
	PreparedURL = PreparedURL + URLComposition.Host;
	If ValueIsFilled(URLComposition.Port) Then
		PreparedURL = PreparedURL + ":" + Format(URLComposition.Port, "ЧРГ=; ЧГ=");
	EndIf;

	PreparedURL = PreparedURL + AssembleResourceAddress(URLComposition, RequestParameters);

	Return PreparedURL;

EndFunction

Function HeadersToString(Headers)

	StringDelimiter = Chars.CR + Chars.LF;
	Strings = New Array;

	SortedHeaders = "Content-Disposition,Content-Type,Content-Location";
	For Each Key_ In StrSplit(SortedHeaders, ",") Do
		Value = HeaderValue(Key_, Headers);
		If Value <> False And ValueIsFilled(Value) Then
			Strings.Add(StrTemplate("%1: %2", Key_, Value));
		EndIf;
	EndDo;

	Keys = StrSplit(Upper(SortedHeaders), ",");
	For Each Header In Headers Do
		If Keys.Find(Upper(Header.Key)) = Undefined Then
			Strings.Add(StrTemplate("%1: %2", Header.Key, Header.Value));
		EndIf;
	EndDo;
	Strings.Add(StringDelimiter);

	Return StrConcat(Strings, StringDelimiter);

EndFunction

Function ValueByKey(Structure, Key_, ValueByDefault = Undefined)

	If TypeOf(Structure) = Type("Structure") And Structure.Property(Key_) Then
		Value = Structure[Key_];
	ElsIf TypeOf(Structure) = Type("Map") And Structure.Get(Key_) <> Undefined Then
		Value = Structure.Get(Key_);
	Else
		Value = ValueByDefault;
	EndIf;

	Return Value;

EndFunction

Function NewFormField(SourceParameters)

	Field = New Structure("Name,FileName,Data,Type,Headers");
	Field.Name = SourceParameters.Name;
	Field.Data = SourceParameters.Data;

	Field.Type = ValueByKey(SourceParameters, "Type");
	Field.Headers = ValueByKey(SourceParameters, "Headers", New Map);
	Field.FileName = ValueByKey(SourceParameters, "FileName");

	Key_ = "Content-Disposition";
	If HeaderValue("content-disposition", Field.Headers, Key_) = False Then
		Field.Headers.Insert("Content-Disposition", "form-data");
	EndIf;

	Parts = New Array;
	Parts.Add(Field.Headers[Key_]);
	Parts.Add(StrTemplate("name=""%1""", Field.Name));
	If ValueIsFilled(Field.FileName) Then
		Parts.Add(StrTemplate("filename=""%1""", Field.FileName));
	EndIf;

	Field.Headers[Key_] = StrConcat(Parts, "; ");
	Field.Headers["Content-Type"] = Field.Type;

	Return Field;

EndFunction

Function EnocodeFiles(HTTPRequest, Files, Data)

	Parts = New Array;
	If ValueIsFilled(Data) Then
		For Each Field In Data Do
			Parts.Add(NewFormField(New Structure("Name,Data", Field.Key, Field.Value)));
		EndDo;
	EndIf;
	If TypeOf(Files) = Type("Array") Then
		For Each File In Files Do
			Parts.Add(NewFormField(File));
		EndDo;
	Else
		Parts.Add(NewFormField(Files));
	EndIf;

	Delimiter = StrReplace(New UUID, "-", "");
	StringDelimiter = Chars.CR + Chars.LF;

	RequestBody = HTTPRequest.GetBodyAsStream();
	DataWriter = New DataWriter(RequestBody, TextEncoding.UTF8, ByteOrder.LittleEndian, "", "", False);
	For Each Part In Parts Do
		DataWriter.WriteLine("--" + Delimiter + StringDelimiter);
		DataWriter.WriteLine(HeadersToString(Part.Headers));
		If TypeOf(Part.Data) = Type("BinaryData") Then
			DataWriter.Write(Part.Data);
		Else
			DataWriter.WriteLine(Part.Data);
		EndIf;
		DataWriter.WriteLine(StringDelimiter);
	EndDo;
	DataWriter.WriteLine("--" + Delimiter + "--" + StringDelimiter);
	DataWriter.Close();

	Return StrTemplate("multipart/form-data; boundary=%1", Delimiter);

EndFunction

Procedure PrepareRequestBody(PreparedRequest, Data, Files, Json, JSONWriterSettings)

	URLComposition = ParseURL(PreparedRequest.URL);

	HTTPRequest = New HTTPRequest;
	HTTPRequest.ResourceAddress = AssembleResourceAddress(URLComposition, PreparedRequest.RequestParameters);
	If ValueIsFilled(Files) Then
		ContentType = EnocodeFiles(HTTPRequest, Files, Data);
	ElsIf ValueIsFilled(Data) Then
		ContentType = "application/x-www-form-urlencoded";
		If TypeOf(Data) = Type("BinaryData") Then
			HTTPRequest.SetBodyFromBinaryData(Data);
		Else
			If TypeOf(Data) = Type("String") Then
				Body = Data;
			Else
				Body = EncodeRequestParameters(Data);
			EndIf;
			HTTPRequest.SetBodyFromString(Body, TextEncoding.UTF8, ByteOrderMarkUse.DontUse);
		EndIf;
	ElsIf Json <> Undefined Then
		ContentType = "application/json";
		JsonString = ObjectToJson(Json, PreparedRequest.JSONConversionParameters, JSONWriterSettings);
		HTTPRequest.SetBodyFromString(JsonString, TextEncoding.UTF8, ByteOrderMarkUse.DontUse);
	Else
		ContentType = Undefined;
	EndIf;
	HeaderValue = HeaderValue("content-type", PreparedRequest.Headers);
	If HeaderValue = False And ValueIsFilled(ContentType) Then
		PreparedRequest.Headers.Insert("Content-Type", ContentType);
	EndIf;

	HTTPRequest.Headers = PreparedRequest.Headers;

	PackRequest(HTTPRequest);

	PreparedRequest.Insert("HTTPRequest", HTTPRequest);

EndProcedure

Procedure PrepareAuthentication(PreparedRequest)

	PreparedRequest.Insert("ResponseEvents", New Array);
	If Not ValueIsFilled(PreparedRequest.Authentication) Then
		URLComposition = ParseURL(PreparedRequest.URL);
		If ValueIsFilled(URLComposition.Authentication) Then
			PreparedRequest.Authentication = URLComposition.Authentication;
		EndIf;
	EndIf;

	If ValueIsFilled(PreparedRequest.Authentication) Then
		If PreparedRequest.Authentication.Property("Type") Then
			AuthenticationType = Lower(PreparedRequest.Authentication.Type);
			If AuthenticationType = "digest" Then
				PreparedRequest.ResponseEvents.Add("Code401_ResponseHandler");
			EndIf;
			If AuthenticationType = "aws4-hmac-sha256" Then
				PrepareAuthenticationAWS4(PreparedRequest);
			EndIf;
		EndIf;
	EndIf;

EndProcedure

Function MergeCookies(MainSource, AdditionalSource)

	Cookies = New Map;
	For Each Cookie In TransformCookiesRepositoryToArray(MainSource) Do
		AddCookieToRepository(Cookies, Cookie, False);
	EndDo;
	For Each Cookie In TransformCookiesRepositoryToArray(AdditionalSource) Do
		AddCookieToRepository(Cookies, Cookie, False);
	EndDo;

	Return Cookies;

EndFunction

Function TransformCookiesRepositoryToArray(CookiesRepository)

	Cookies = New Array;
	If TypeOf(CookiesRepository) = Type("Array") Then
		For Each Cookie In CookiesRepository Do
			NewCookie = CookieConstructor();
			FillPropertyValues(NewCookie, Cookie);
			Cookies.Add(NewCookie);
		EndDo;

		Return Cookies;
	EndIf;

	For Each Domain In CookiesRepository Do
		For Each Path In Domain.Value Do
			For Each Description In Path.Value Do
				Cookies.Add(Description.Value);
			EndDo;
		EndDo;
	EndDo;

	Return Cookies;

EndFunction

Function MergeAuthenticationParameters(MainSource, AdditionalSource)

	AuthenticationParameters = New Structure;
	If TypeOf(MainSource) = Type("Structure") Then
		For Each Parameter In MainSource Do
			AuthenticationParameters.Insert(Parameter.Key, Parameter.Value);
		EndDo;
	EndIf;
	If TypeOf(AdditionalSource) = Type("Structure") Then
		For Each Parameter In AdditionalSource Do
			If Not AuthenticationParameters.Property(Parameter) Then
				AuthenticationParameters.Insert(Parameter.Key, Parameter.Value);
			EndIf;
		EndDo;
	EndIf;

	Return AuthenticationParameters;

EndFunction

Function MergeHeaders(MainSource, AdditionalSource)

	Headers = New Map;
	For Each Header In MainSource Do
		Headers.Insert(Header.Key, Header.Value);
	EndDo;
	For Each Header In AdditionalSource Do
		If Headers.Get(Header.Key) = Undefined Then
			Headers.Insert(Header.Key, Header.Value);
		EndIf;
	EndDo;

	Return Headers;

EndFunction

Function MergeRequestParameters(MainSource, AdditionalSource)

	RequestParameters = New Map;
	If TypeOf(MainSource) = Type("Structure") Or TypeOf(MainSource) = Type("Map") Then
		For Each Parameter In MainSource Do
			RequestParameters.Insert(Parameter.Key, Parameter.Value);
		EndDo;
	EndIf;
	If TypeOf(AdditionalSource) = Type("Structure") Or TypeOf(AdditionalSource) = Type("Map") Then
		For Each Parameter In AdditionalSource Do
			If RequestParameters.Get(Parameter) = Undefined Then
				RequestParameters.Insert(Parameter.Key, Parameter.Value);
			EndIf;
		EndDo;
	EndIf;

	Return RequestParameters;

EndFunction

Function SendHTTPRequest(Session, PreparedRequest, Settings)

	URLComposition = ParseURL(PreparedRequest.URL);
	Connection = Connection(URLComposition, PreparedRequest.Authentication, Settings, Session);
	Response = Connection.CallHTTPMethod(PreparedRequest.Method, PreparedRequest.HTTPRequest);

	For Each Handler In PreparedRequest.ResponseEvents Do
		If Handler = "Code401_ResponseHandler" Then
			Code401_ResponseHandler(Session, PreparedRequest, Settings, Response);
		EndIf;
	EndDo;

	Return Response;

EndFunction

Function CalculatePauseDuration(RetriesNumber, ExponentialDelayRatio, RetryAfterHeader, Remainder)

	If RetryAfterHeader <> False Then
		Duration = NumberFromString(RetryAfterHeader);

		If Duration = 0 Then
			Date = DateFromStringRFC7231(RetryAfterHeader);
			If ValueIsFilled(Date) Then
				Duration = Date - CurrentUniversalDate();
			EndIf;
		EndIf;
	Else
		Duration = ExponentialDelayRatio * Pow(2, RetriesNumber - 1);
	EndIf;

	Duration = Min(Duration, Remainder);

	If Duration < 0 Then
		Duration = 0;
	EndIf;

	Return Duration;

EndFunction

Function RequestMustBeRepeated(Response, Settings, RequestExecutionError)

	If Settings.MaximumNumberOfRetries < 1 Then
		RetryRequest = False;
	ElsIf RequestExecutionError <> Undefined Or RetryOnStatusCode(Response.StatusCode, Settings) Then
		RetryRequest = True;
	Else
		RetryAfterHeader = HeaderValue("retry-after", Response.Headers);
		RetryRequest = RetryAfterHeader <> False
			And IsStatusCodeForWhichRetryAfterHeaderMustBeConsidered(Response.StatusCode);
	EndIf;

	Return RetryRequest;

EndFunction

Function RetryOnStatusCode(StatusCode, Settings)

	RetryOnAnyStatusCodeMoreOrEqual500 = Settings.ToRetryForStatusesCodes = Undefined
		And StatusCode >= HTTPStatusCodes().InternalServerError_500;
	StatusCodeMatchesRetryStatusCode = TypeOf(Settings.ToRetryForStatusesCodes) = Type("Array")
		And Settings.ToRetryForStatusesCodes.Find(StatusCode) <> Undefined;
	Return RetryOnAnyStatusCodeMoreOrEqual500 Or StatusCodeMatchesRetryStatusCode;

EndFunction

Function SendRequest(Session, PreparedRequest, Settings)

	Start = CurrentUniversalDateInMilliseconds();
	MillisecondsInSecond = 1000;

	RetriesNumber = 0;
	Duration = 0;
	While True Do
		Try
			Response = SendHTTPRequest(Session, PreparedRequest, Settings);
		Except
			RequestExecutionError = ErrorInfo();
		EndTry;

		RetriesNumber = RetriesNumber + 1;
		Duration = (CurrentUniversalDateInMilliseconds() - Start) / MillisecondsInSecond;

		If Not RequestMustBeRepeated(Response, Settings, RequestExecutionError) Then
			Break;
		EndIf;

		If RetriesNumber > Settings.MaximumNumberOfRetries
			Or Duration > Settings.MaximumTimeOfRetries Then
			Break;
		EndIf;

		If RequestExecutionError <> Undefined
			Or НЕ IsStatusCodeForWhichRetryAfterHeaderMustBeConsidered(Response.StatusCode) Then
			RetryAfterHeader = False;
		Else
			RetryAfterHeader = HeaderValue("retry-after", Response.Headers);
		EndIf;
		PauseDuration = CalculatePauseDuration(
			RetriesNumber,
			Settings.ExponentialDelayRatio,
			RetryAfterHeader,
			Settings.MaximumTimeOfRetries - Duration);
		Pause(PauseDuration);
	EndDo;

	If RequestExecutionError <> Undefined Then
		Raise(DetailErrorDescription(RequestExecutionError));
	EndIf;

	ContentTypeHeader = HeaderValue("content-type", Response.Headers);
	If ContentTypeHeader = False Then
		ContentTypeHeader = "";
	EndIf;

	PreparedResponse = New Structure;
	PreparedResponse.Insert("ExecutionTime", CurrentUniversalDateInMilliseconds() - Start);
	PreparedResponse.Insert("Cookies", ExtractCookies(Response.Headers, PreparedRequest.URL));
	PreparedResponse.Insert("Headers", Response.Headers);
	PreparedResponse.Insert("IsPermanentRedirect", IsPermanentRedirect(Response.StatusCode, Response.Headers));
	PreparedResponse.Insert("IsRedirect", IsRedirect(Response.StatusCode, Response.Headers));
	PreparedResponse.Insert("Encoding", EncodingFromHeader(ContentTypeHeader));
	PreparedResponse.Insert("Body", Response.GetBodyAsBinaryData());
	PreparedResponse.Insert("StatusCode", Response.StatusCode);
	PreparedResponse.Insert("URL", PreparedRequest.URL);

	Session.Cookies = MergeCookies(Session.Cookies, PreparedResponse.Cookies);

	Return PreparedResponse;

EndFunction

Procedure OverrideMethod(PreparedRequest, Response)

	HTTPStatusCodes = HTTPStatusCodes();

	Method = PreparedRequest.Method;

	// http://tools.ietf.org/html/rfc7231#section-6.4.4
	If Response.StatusCode = HTTPStatusCodes.SeeOther_303 And Method <> "HEAD" Then
		Method = "GET";
	EndIf;

	// Поведение браузеров
	If Response.StatusCode = HTTPStatusCodes.MovedTemporarily_302 And Method <> "HEAD" Then
		Method = "GET";
	EndIf;

	PreparedRequest.Method = Method;

EndProcedure

Function ExtractCookies(Headers, URL)

	CurrentTime = CurrentUniversalDate();
	Cookies = New Map;
	For Each NextHeader In Headers Do
		If Lower(NextHeader.Key) = "set-cookie" Then
			For Each CookieHeader In SplitIntoSeparateCookiesHeaders(NextHeader.Value) Do
				Cookie = ParseCookie(CookieHeader, URL, CurrentTime);
				If Cookie = Undefined Then
					Continue;
				EndIf;
				If Cookie.ExpiresOn <= CurrentTime Then
					DeleteCookieFromRepository(Cookies, Cookie);
				Else
					AddCookieToRepository(Cookies, Cookie);
				EndIf;
			EndDo;
		EndIf;
	EndDo;

	Return Cookies;

EndFunction

Function SplitIntoSeparateCookiesHeaders(Val Header)

	Headers = New Array;

	If Not ValueIsFilled(Header) Then
		Return Headers;
	EndIf;

	HeadersParts = StrSplit(Header, ",", False);

	SeparateHeader = HeadersParts[0];
	For Index = 1 To HeadersParts.ВГраница() Do
		Semicolon = StrFind(HeadersParts[Index], ";");
		EqualSign = StrFind(HeadersParts[Index], "=");
		If Semicolon And EqualSign And EqualSign < Semicolon Then
			Headers.Add(SeparateHeader);
			SeparateHeader = HeadersParts[Index];
		Else
			SeparateHeader = SeparateHeader + HeadersParts[Index];
		EndIf;
	EndDo;
	Headers.Add(SeparateHeader);

	Return Headers;

EndFunction

Function CookieConstructor(Description = "", Value = Undefined)

	NewCookie = New Structure;
	NewCookie.Insert("Description", Description);
	NewCookie.Insert("Value", Value);
	NewCookie.Insert("Domain", "");
	NewCookie.Insert("Path", "");
	NewCookie.Insert("Port");
	NewCookie.Insert("ExpiresOn", '39990101');
	NewCookie.Insert("OnlySecureConnection");

	Return NewCookie;

EndFunction

Function CreateCookieAndFillBasicParameters(Parameter)

	Parts = StrSplit(Parameter, "=", False);
	Description = Parts[0];
	If Parts.Count() > 1 Then
		Value = Parts[1];
	EndIf;

	Return CookieConstructor(Description, Value);

EndFunction

Function ParseCookie(Header, URL, CurrentTime)

	Cookie = Undefined;
	Index = 0;

	For Each Parameter In StrSplit(Header, ";", False) Do
		Index = Index + 1;
		Parameter = TrimAll(Parameter);

		If Index = 1 Then
			Cookie = CreateCookieAndFillBasicParameters(Parameter);
			Continue;
		EndIf;

		Parts = StrSplit(Parameter, "=", False);
		Key_ = Lower(Parts[0]);
		If Parts.Count() > 1 Then
			Value = Parts[1];
		EndIf;

		If Key_ = "domain" Then
			Cookie.Domain = Value;
		ElsIf Key_ = "path" Then
			Cookie.Path = Value;
		ElsIf Key_ = "secure" Then
			Cookie.OnlySecureConnection = True;
		ElsIf Key_ = "max-age" Then
			ExpiresOnMaxAge = CurrentTime + NumberFromString(Value);
		ElsIf Key_ = "expires" Then
			Cookie.ExpiresOn = DateFromStringRFC7231(Value);
		Else
			Continue;
		EndIf;
	EndDo;
	If ValueIsFilled(Cookie) And ValueIsFilled(ExpiresOnMaxAge) Then
		Cookie.ExpiresOn = ExpiresOnMaxAge;
	EndIf;

	SipplementCookieWithImplicitValues(Cookie, URL);

	Return Cookie;

EndFunction

Procedure SipplementCookieWithImplicitValues(Cookie, URL)

	If Cookie = Undefined Then
		Return;
	EndIf;

	URLComposition = ParseURL(URL);
	If Not ValueIsFilled(Cookie.Domain) Then
		Cookie.Domain = URLComposition.Host;
	EndIf;
	If Not ValueIsFilled(Cookie.Port) And ValueIsFilled(URLComposition.Port) Then
		Cookie.Port = URLComposition.Port;
	EndIf;
	If Not ValueIsFilled(Cookie.Path) Then
		LastSlashPosition = StrFind(URLComposition.Path, "/", SearchDirection.FromEnd);
		If LastSlashPosition <= 1 Then
			Cookie.Path = "/";
		Else
			Cookie.Path = Left(URLComposition.Path, LastSlashPosition - 1);
		EndIf;
	EndIf;

EndProcedure

Function HeaderValue(Header, AllHeaders, Key_ = Undefined)

	For Each NextHeader In AllHeaders Do
		If Lower(NextHeader.Key) = Lower(Header) Then
			Key_ = NextHeader.Key;
			Return NextHeader.Value;
		EndIf;
	EndDo;

	Return False;

EndFunction

Function IsPermanentRedirect(StatusCode, Headers)

	HTTPStatusCodes = HTTPStatusCodes();

	Return ExistsLocationHeader(Headers)
		And (StatusCode = HTTPStatusCodes.MovedPermanently_301
		Or StatusCode = HTTPStatusCodes.PermanentRedirect_308);

EndFunction

Function IsRedirect(StatusCode, Headers)

	HTTPStatusCodes = HTTPStatusCodes();

	RedirectState = New Array;
	RedirectState.Add(HTTPStatusCodes.MovedPermanently_301);
	RedirectState.Add(HTTPStatusCodes.MovedTemporarily_302);
	RedirectState.Add(HTTPStatusCodes.SeeOther_303);
	RedirectState.Add(HTTPStatusCodes.TemporaryRedirect_307);
	RedirectState.Add(HTTPStatusCodes.PermanentRedirect_308);

	Return ExistsLocationHeader(Headers) And RedirectState.Find(StatusCode) <> Undefined;

EndFunction

Function ExistsLocationHeader(Headers)

	Return HeaderValue("location", Headers) <> False;

EndFunction

Function EncodingFromHeader(Val Header)

	Encoding = Undefined;

	Header = Lower(TrimAll(Header));
	DelimiterIndex = StrFind(Header, ";");
	If DelimiterIndex Then
		ContentType = TrimAll(Left(Header, DelimiterIndex - 1));
		EncodingKey = "charset=";
		EncodingIndex = StrFind(Header, EncodingKey);
		If EncodingIndex Then
			DelimiterIndex = StrFind(Header, ";", SearchDirection.FromBegin, EncodingIndex);
			InitialPosition = EncodingIndex + StrLen(EncodingKey);
			If DelimiterIndex Then
				EncodingLength = DelimiterIndex - InitialPosition;
			Else
				EncodingLength = StrLen(Header);
			EndIf;
			Encoding = Mid(Header, InitialPosition, EncodingLength);
			Encoding = StrReplace(Encoding, """", "");
			Encoding = StrReplace(Encoding, "'", "");
		EndIf;
	Else
		ContentType = Header;
	EndIf;

	If Encoding = Undefined And StrFind(ContentType, "text") Then
		Encoding = "iso-8859-1";
	EndIf;

	Return Encoding;

EndFunction

Function AssembleResourceAddress(URLComposition, RequestParameters)

	ResourceAddress = URLComposition.Path;

	MergedRequestParameters = MergeRequestParameters(RequestParameters, URLComposition.RequestParameters);
	If ValueIsFilled(MergedRequestParameters) Then
		ResourceAddress = ResourceAddress + "?" + EncodeRequestParameters(MergedRequestParameters);
	EndIf;
	If ValueIsFilled(URLComposition.Fragment) Then
		ResourceAddress = ResourceAddress + "#" + URLComposition.Fragment;
	EndIf;

	Return ResourceAddress;

EndFunction

Function SecureConnectionObject(AdditionalParameters)

	If AdditionalParameters.VerifySSL = False Then
		CertificatesCA = Undefined;
	ElsIf TypeOf(AdditionalParameters.VerifySSL) = Type("FileCertificationAuthorityCertificates") Then
		CertificatesCA = AdditionalParameters.VerifySSL;
	Else
		CertificatesCA = New OSCertificationAuthorityCertificates;
	EndIf;
	ClientCertificate = Undefined;
	If TypeOf(AdditionalParameters.ClientSSLCertificate) = Type("FileClientCertificate")
		Or TypeOf(AdditionalParameters.ClientSSLCertificate) = Type("WindowsClientCertificate") Then
		ClientCertificate = AdditionalParameters.ClientSSLCertificate;
	EndIf;

	Return New OpenSSLSecureConnection(ClientCertificate, CertificatesCA);

EndFunction

Function Connection(ConnectionParameters, Authentication, AdditionalParameters, Session)

	If Not ValueIsFilled(ConnectionParameters.Port) Then
		If ConnectionParameters.Scheme = "https" Then
			ConnectionParameters.Port = 443;
		Else
			ConnectionParameters.Port = 80;
		EndIf;
	EndIf;

	SecureConnection = Undefined;
	If ConnectionParameters.Scheme = "https" Then
		SecureConnection = SecureConnectionObject(AdditionalParameters);
	EndIf;

	User = "";
	Password = "";
	If ValueIsFilled(Authentication) Then
		If Authentication.Property("User") And Authentication.Property("Password") Then
			User = Authentication.User;
			Password = Authentication.Password;
		EndIf;
	EndIf;

	UseOSAuthentication = Authentication.Property("UseOSAuthentication")
		And Authentication.UseOSAuthentication = True;

	CalculateIDParameters = New Array;
	CalculateIDParameters.Add(ConnectionParameters.Host);
	CalculateIDParameters.Add(ConnectionParameters.Port);
	CalculateIDParameters.Add(User);
	CalculateIDParameters.Add(Password);
	CalculateIDParameters.Add(AdditionalParameters.Timeout);
	CalculateIDParameters.Add(UseOSAuthentication);
	CalculateIDParameters.Add(SecureConnection);
	CalculateIDParameters.Add(AdditionalParameters.Proxy);

	If Not Session.Property("ServiceData") Or TypeOf(Session.ServiceData) <> Type("Structure") Then
		Session.Insert("ServiceData", New Structure);
	EndIf;
	If Not Session.ServiceData.Property("ConnectionsPool") Then
		Session.ServiceData.Insert("ConnectionsPool", New Map);
	EndIf;
	ConnectionsPool = Session.ServiceData.ConnectionsPool;

	ConnectionID = ConnectionID(CalculateIDParameters);

	If ConnectionsPool.Get(ConnectionID) = Undefined Then
		NewConnection = New HTTPConnection(
			ConnectionParameters.Host,
			ConnectionParameters.Port,
			User, Password,
			AdditionalParameters.Proxy,
			AdditionalParameters.Timeout,
			SecureConnection,
			UseOSAuthentication);
		ConnectionsPool.Insert(ConnectionID, NewConnection);
	EndIf;

	Return ConnectionsPool[ConnectionID];

EndFunction

Function ConnectionID(ConnectionParameters)

	CalculateIDParameters = New Array;

	For Each Item In ConnectionParameters Do
		ItemType = TypeOf(Item);
		If ItemType = Type("InternetProxy") Then
			CalculateIDParameters.Add(StrConcat(Item.BypassProxyOnAddresses, ""));
			CalculateIDParameters.Add(XMLString(Item.BypassProxyOnLocal));
			CalculateIDParameters.Add(Item.User);
			CalculateIDParameters.Add(Item.Password);
		ElsIf ItemType = Type("OpenSSLSecureConnection") Then
			// For упрощения будет считать, что сертификаты в рамках сессии не меняются
			If Item.ClientCertificate = Undefined Then
				CalculateIDParameters.Add("");
			Else
				CalculateIDParameters.Add(String(TypeOf(Item.ClientCertificate)));
			EndIf;
			If Item.CertificationAuthorityCertificates = Undefined Then
				CalculateIDParameters.Add("");
			Else
				CalculateIDParameters.Add(String(TypeOf(Item.CertificationAuthorityCertificates)));
			EndIf;
		Else
			CalculateIDParameters.Add(XMLString(Item));
		EndIf;
	EndDo;

	Return DataHashing(HashFunction.MD5, StrConcat(CalculateIDParameters, ""));

EndFunction

Function SelectValue(MainValue, AdditionalValues, Key_, ValueByDefault)

	If MainValue <> Undefined Then
		Return MainValue;
	EndIf;

	Value = ValueByKey(AdditionalValues, Key_);
	If Value <> Undefined Then
		Return Value;
	EndIf;

	Return ValueByDefault;

EndFunction

Function FillRequestParameters(Path)

	RequestParameters = New Map;

	Query = "";
	SplitStringByDelimiter(Query, Path, "?", True);
	For Each KeyEqualParameterString In StrSplit(Query, "&", False) Do
		KeyEqualParameterString = DecodeString(
			KeyEqualParameterString, StringEncodingMethod.URLInURLEncoding);

		EqualSignPosition = StrFind(KeyEqualParameterString, "=");
		If EqualSignPosition = 0 Then
			Key_ = KeyEqualParameterString;
			Value = Undefined;
		Else
			Key_ = Left(KeyEqualParameterString, EqualSignPosition - 1);
			Value = Mid(KeyEqualParameterString, EqualSignPosition + 1);
		EndIf;

		If RequestParameters.Get(Key_) <> Undefined Then
			If TypeOf(RequestParameters[Key_]) = Type("Array") Then
				RequestParameters[Key_].Add(Value);
			Else
				Values = New Array;
				Values.Add(RequestParameters[Key_]);
				Values.Add(Value);
				RequestParameters[Key_] = Values;
			EndIf;
		Else
			RequestParameters.Insert(Key_, Value);
		EndIf;

	EndDo;

	Return RequestParameters;

EndFunction

Procedure SplitStringByDelimiter(ExtractedPart, RemainingPart, Delimiter, Inversion = False)

	Index = StrFind(RemainingPart, Delimiter);
	If Index Then
		ExtractedPart = Left(RemainingPart, Index - 1);
		RemainingPart = Mid(RemainingPart, Index + StrLen(Delimiter));
		If Inversion Then
			ForValuesSwap = ExtractedPart;
			ExtractedPart = RemainingPart;
			RemainingPart = ForValuesSwap;
		EndIf;
	EndIf;

EndProcedure

Function SplitByFirstFoundDelimiter(String, Delimiters)

	MinimalIndex = StrLen(String);
	FirstDelimiter = "";

	For Each Delimiter In Delimiters Do
		Index = StrFind(String, Delimiter);
		If Index = 0 Then
			Continue;
		EndIf;
		If Index < MinimalIndex Then
			MinimalIndex = Index;
			FirstDelimiter = Delimiter;
		EndIf;
	EndDo;

	Result = New Array;
	If ValueIsFilled(FirstDelimiter) Then
		Result.Add(Left(String, MinimalIndex - 1));
		Result.Add(Mid(String, MinimalIndex + StrLen(FirstDelimiter)));
		Result.Add(FirstDelimiter);
	Else
		Result.Add(String);
		Result.Add("");
		Result.Add(Undefined);
	EndIf;

	Return Result;

EndFunction

Function SupplementJSONConversionParameters(ConversionParameters)

	JSONConversionParameters = JSONConversionParametersByDefault();
	If ValueIsFilled(ConversionParameters) Then
		For Each Parameter In ConversionParameters Do
			If JSONConversionParameters.Property(Parameter.Key) Then
				JSONConversionParameters.Insert(Parameter.Key, Parameter.Value);
			EndIf;
		EndDo;
	EndIf;

	Return JSONConversionParameters;

EndFunction

Function SupplementJSONWriterSettings(WriterSettings)

	JSONWriterSettings = JSONWriterSettingsByDeafult();
	If ValueIsFilled(WriterSettings) Then
		For Each Parameter In WriterSettings Do
			If JSONWriterSettings.Property(Parameter.Key) Then
				JSONWriterSettings.Insert(Parameter.Key, Parameter.Value);
			EndIf;
		EndDo;
	EndIf;

	Return JSONWriterSettings;

EndFunction

// Converts a type value into a type, that can be serialized.
//
// Parameters:
//   Property - String - property name, if the structure or map is writing.
//   Value - Arbitrary - initial value.
//   AdditionalParameters - Arbitrary - additional parameters of the WriteJSON method.
//   Cancel - Boolean - cancel to write a property.
//
// Returns:
//   Arbitrary - see WriteJSON types.
//
Function JsonConversion(Property, Value, AdditionalParameters, Cancel) Export

	If TypeOf(Value) = Type("UUID") Then
		Return String(Value);
	ElsIf TypeOf(Value) = Type("BinaryData") Then
		Return GetBase64StringFromBinaryData(Value);
	Else
		// If the value doesn't support JSON serialization, an exception will be thrown
		Return Value;
	EndIf;

EndFunction

#Region AWS4Authentication

Function SignatureKeyAWS4(SecretKey, Date, Region, Service)

	DateKey = SignMessageHMAC("AWS4" + SecretKey, Date);
	RegionKey = SignMessageHMAC(DateKey, Region);
	ServiceKey = SignMessageHMAC(RegionKey, Service);

	Return SignMessageHMAC(ServiceKey, "aws4_request");

EndFunction

Function SignMessageHMAC(Val Key_, Val Message, Val Algorithm = Undefined)

	If Algorithm = Undefined Then
		Algorithm = HashFunction.SHA256;
	EndIf;

	If TypeOf(Key_) = Type("String") Then
		Key_ = GetBinaryDataFromString(Key_, TextEncoding.UTF8, False);
	EndIf;
	If TypeOf(Message) = Type("String") Then
		Message = GetBinaryDataFromString(Message, TextEncoding.UTF8, False);
	EndIf;

	Return HMAC(Key_, Message, Algorithm);

EndFunction

Procedure PrepareAuthenticationAWS4(PreparedRequest)

	HeaderValue = HeaderValue("x-amz-date", PreparedRequest.Headers);
	If HeaderValue <> False Then
		CurrentTime = Date(StrReplace(StrReplace(HeaderValue, "T", ""), "Z", ""));
	Else
		CurrentTime = CurrentUniversalDate();
	EndIf;
	PreparedRequest.Headers["x-amz-date"] = Format(CurrentTime, "ДФ=yyyyMMddTHHmmssZ");
	ScopeDate = Format(CurrentTime, "ДФ=yyyyMMdd");

	PreparedRequest.Headers["x-amz-content-sha256"] =
		DataHashing(HashFunction.SHA256, PreparedRequest.HTTPRequest.GetBodyAsStream());

	URLComposition = ParseURL(PreparedRequest.URL);

	CanonicalHeaders = CanonicalHeadersAWS4(PreparedRequest.Headers, URLComposition);

	CanonicalPath = URLComposition.Path;
	CanonicalRequestParameters = CanonicalRequestParametersAWS4(URLComposition.RequestParameters);

	RequestParts = New Array;
	RequestParts.Add(PreparedRequest.Method);
	RequestParts.Add(CanonicalPath);
	RequestParts.Add(CanonicalRequestParameters);
	RequestParts.Add(CanonicalHeaders.CanonicalHeaders);
	RequestParts.Add(CanonicalHeaders.SignedHeaders);
	RequestParts.Add(PreparedRequest.Headers["x-amz-content-sha256"]);
	CanonicalRequest = StrConcat(RequestParts, Chars.LF);

	ScopeParts = New Array;
	ScopeParts.Add(ScopeDate);
	ScopeParts.Add(PreparedRequest.Authentication.Region);
	ScopeParts.Add(PreparedRequest.Authentication.Service);
	ScopeParts.Add("aws4_request");
	Scope = StrConcat(ScopeParts, "/");

	StringForSignatureParts = New Array;
	StringForSignatureParts.Add(PreparedRequest.Authentication.Type);
	StringForSignatureParts.Add(PreparedRequest.Headers["x-amz-date"]);
	StringForSignatureParts.Add(Scope);
	StringForSignatureParts.Add(DataHashing(HashFunction.SHA256, CanonicalRequest));
	StringForSignature = StrConcat(StringForSignatureParts, Chars.LF);

	Key_ = SignatureKeyAWS4(
		PreparedRequest.Authentication.SecretKey,
		ScopeDate,
		PreparedRequest.Authentication.Region,
		PreparedRequest.Authentication.Service);
	Signature = Lower(GetHexStringFromBinaryData(SignMessageHMAC(Key_, StringForSignature)));

	PreparedRequest.Headers["Authorization"] = StrTemplate(
		"%1 Credential=%2/%3, SignedHeaders=%4, Signature=%5",
		PreparedRequest.Authentication.Type,
		PreparedRequest.Authentication.AccessKeyID,
		Scope,
		CanonicalHeaders.SignedHeaders,
		Signature);

	PreparedRequest.HTTPRequest.Headers = PreparedRequest.Headers;

EndProcedure

Function IsHTTPStandardPort(URLComposition)

	HTTPStandardPort = 80;
	HTTPSStandardPort = 443;

	Return (URLComposition.Scheme = "http" And URLComposition.Port = HTTPStandardPort)
		Or (URLComposition.Scheme = "https" And URLComposition.Port = HTTPSStandardPort);

EndFunction

Function CreateHostHeaderValue(URLComposition)

	Host = URLComposition.Host;
	If ValueIsFilled(URLComposition.Port) And НЕ IsHTTPStandardPort(URLComposition) Then
		Host = Host + ":" + Format(URLComposition.Port, "ЧРГ=; ЧГ=");
	EndIf;

	Return Host;

EndFunction

Function CanonicalHeadersAWS4(Headers, URLComposition)

	List = New ValueList;

	HostHeadersIsInRequest = False;
	DefaultHeaders = HeadersByDefaultAWS4();
	For Each NextHeader In Headers Do
		Header = Lower(NextHeader.Key);
		If DefaultHeaders.Exceptions.Find(Header) <> Undefined Then
			Continue;
		EndIf;
		HostHeadersIsInRequest = Макс(HostHeadersIsInRequest, Header = "host");

		If DefaultHeaders.EqualSign.Find(Header) <> Undefined Then
			List.Add(Header, TrimAll(NextHeader.Value));
		Else
			For Each Prefix In DefaultHeaders.BeginsWith Do
				If StrStartsWith(Header, Prefix) Then
					List.Add(Header, TrimAll(NextHeader.Value));
					Break;
				EndIf;
			EndDo;
		EndIf;
	EndDo;

	If Not HostHeadersIsInRequest Then
		List.Add("host", CreateHostHeaderValue(URLComposition));
	EndIf;

	List.SortByValue(SortDirection.Asc);

	CanonicalHeaders = New Array;
	SignedHeaders = New Array;
	For Each ListItem In List Do
		CanonicalHeaders.Add(ListItem.Value + ":" + ListItem.Presentation);
		SignedHeaders.Add(ListItem.Value);
	EndDo;
	CanonicalHeaders.Add("");

	CanonicalHeaders = StrConcat(CanonicalHeaders, Chars.LF);
	SignedHeaders = StrConcat(SignedHeaders, ";");
	Return New Structure(
		"CanonicalHeaders, SignedHeaders",
		CanonicalHeaders, SignedHeaders);

EndFunction

Function CanonicalRequestParametersAWS4(RequestParameters)

	List = New ValueList;
	For Each NextRequestParameter In RequestParameters Do
		List.Add(NextRequestParameter.Key, TrimAll(NextRequestParameter.Value));
	EndDo;
	List.SortByValue(SortDirection.Asc);

	CanonicalParameters = New Array;
	For Each ListItem In List Do
		ParameterValue = EncodeString(ListItem.Presentation, StringEncodingMethod.URLEncoding);
		CanonicalParameters.Add(ListItem.Value + "=" + ParameterValue);
	EndDo;

	Return StrConcat(CanonicalParameters, "&");

EndFunction

Function HeadersByDefaultAWS4()

	Headers = New Structure;
	Headers.Insert("EqualSign", StrSplit("host,content-type,date", ","));
	Headers.Insert("BeginsWith", StrSplit("x-amz-", ","));
	Headers.Insert("Exceptions", StrSplit("x-amz-client-context", ","));

	Return Headers;

EndFunction

#EndRegion

#Region EncodingDecodingData

#Region ServiceStructuresZip

// Structures description see here https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT

Function ZipLFHSize()

	Return 34;

EndFunction

Function ZipDDSize()

	Return 16;

EndFunction

Function ZipCDHSize()

	Return 50;

EndFunction

Function ZipEOCDSize()

	Return 22;

EndFunction

Function ZipLFH()

	// Local file header
	Buffer = New BinaryDataBuffer(ZipLFHSize());
	Buffer.WriteInt32(0, 67324752); // signature 0x04034b50
	Buffer.WriteInt16(4, 20);       // version
	Buffer.WriteInt16(6, 10);       // bit flags
	Buffer.WriteInt16(8, 8);        // compression method
	Buffer.WriteInt16(10, 0);       // time
	Buffer.WriteInt16(12, 0);       // date
	Buffer.WriteInt32(14, 0);       // crc-32
	Buffer.WriteInt32(18, 0);       // compressed size
	Buffer.WriteInt32(22, 0);       // uncompressed size
	Buffer.WriteInt16(26, 4);       // filename legth - "data"
	Buffer.WriteInt16(28, 0);       // extra field length
	Buffer.Write(30, GetBinaryDataBufferFromString("data", "ascii", False));

	Return Buffer;

EndFunction

Function ZipDD(CRC32, CompressedDataSize, UncompressedDataSize)

	// Data descriptor
	Buffer = New BinaryDataBuffer(ZipDDSize());
	Buffer.WriteInt32(0, 134695760);
	Buffer.WriteInt32(4, CRC32);
	Buffer.WriteInt32(8, CompressedDataSize);
	Buffer.WriteInt32(12, UncompressedDataSize);

	Return Buffer;

EndFunction

Function ZipCDH(CRC32, CompressedDataSize, UncompressedDataSize)

	// Central directory header
	Buffer = New BinaryDataBuffer(ZipCDHSize());
	Buffer.WriteInt32(0, 33639248);              // signature 0x02014b50
	Buffer.WriteInt16(4, 798);                   // version made by
	Buffer.WriteInt16(6, 20);                    // version needed to extract
	Buffer.WriteInt16(8, 10);                    // bit flags
	Buffer.WriteInt16(10, 8);                    // compression method
	Buffer.WriteInt16(12, 0);                    // time
	Buffer.WriteInt16(14, 0);                    // date
	Buffer.WriteInt32(16, CRC32);                // crc-32
	Buffer.WriteInt32(20, CompressedDataSize);   // compressed size
	Buffer.WriteInt32(24, UncompressedDataSize); // uncompressed size
	Buffer.WriteInt16(28, 4);                    // file name length
	Buffer.WriteInt16(30, 0);                    // extra field length
	Buffer.WriteInt16(32, 0);                    // file comment length
	Buffer.WriteInt16(34, 0);                    // disk number start
	Buffer.WriteInt16(36, 0);                    // internal file attributes
	Buffer.WriteInt32(38, 2176057344);           // external file attributes
	Buffer.WriteInt32(42, 0);                    // relative offset of local header
	Buffer.Write(46, GetBinaryDataBufferFromString("data", "ascii", False));

	Return Buffer;

EndFunction

Function ZipEOCD(CompressedDataSize)

	// End of central directory
	CDHSize = 50;
	Buffer = New BinaryDataBuffer(ZipEOCDSize());
	Buffer.WriteInt32(0, 101010256); // signature 0x06054b50
	Buffer.WriteInt16(4, 0); // number of this disk
	Buffer.WriteInt16(6, 0); // number of the disk with the start of the central directory
	Buffer.WriteInt16(8, 1); // total number of entries in the central directory on this disk
	Buffer.WriteInt16(10, 1); // total number of entries in the central directory
	Buffer.WriteInt32(12, CDHSize); // size of the central directory
	// offset of start of central directory with respect to the starting disk number
	Buffer.WriteInt32(16, ZipLFHSize() + CompressedDataSize + ZipDDSize());
	Buffer.WriteInt16(20, 0); // the starting disk number

	Return Buffer;

EndFunction

#EndRegion

#Region ServiceStructuresGZip

// Structures description see here https://www.ietf.org/rfc/rfc1952.txt

Function GZipHeaderSize()

	Return 10;

EndFunction

Function GZipFooterSize()

	Return 8;

EndFunction

Function GZipHeader()

	Buffer = New BinaryDataBuffer(GZipHeaderSize());
	Buffer[0] = 31;               // ID1 0x1f
	Buffer[1] = 139;              // ID2 0x8b
	Buffer[2] = 8;                // compression method (08 for DEFLATE)
	Buffer[3] = 0;                // header flags
	Buffer.WriteInt32(4, 0); // timestamp
	Buffer[8] = 0;                // compression flags
	Buffer[9] = 255;              // operating system ID

	Return Buffer;

EndFunction

Function GZipFooter(CRC32, SourceDataSize)

	Buffer = New BinaryDataBuffer(GZipFooterSize());
	Buffer.WriteInt32(0, CRC32);
	Buffer.WriteInt32(4, SourceDataSize);

	Return Buffer;

EndFunction

#EndRegion

Function ReadZip(CompressedData, ErrorText = Undefined)

#If MobileAppServer Then
	Raise(НСтр("ru = 'Работа с Zip-файлами в мобильной платформе не поддерживается'; en = 'Работа с Zip-файлами в мобильной платформе не поддерживается'"));
#Else
	FolderName = GetTempFileName();
	ZipReader = New ZipFileReader(CompressedData);
	FileName = ZipReader.Items[0].Name;
	Try
		ZipReader.Extract(ZipReader.Items[0], FolderName, ZIPRestoreFilePathsMode.DontRestore);
	Except
		// Игнорируем проверку целостности архива, просто читаем результат
		ErrorText = DetailErrorDescription(ErrorInfo());
	EndTry;
	ZipReader.Close();

	Result = New BinaryData(FolderName + GetPathSeparator() + FileName);
	DeleteFiles(FolderName);

	Return Result;
#EndIf

EndFunction

Function WriteZip(Data)

#If MobileAppServer Then
	Raise(НСтр("ru = 'Работа с Zip-файлами в мобильной платформе не поддерживается'; en = 'Работа с Zip-файлами в мобильной платформе не поддерживается'"));
#Else
	TemporaryFile = GetTempFileName(".bin");
	Data.Write(TemporaryFile);
	ZipStream = New MemoryStream;
	ЗаписьZip = New ZipFileWriter(ZipStream);
	ЗаписьZip.Add(TemporaryFile);
	ЗаписьZip.Write();
	DeleteFiles(TemporaryFile);

	Return ZipStream.CloseAndGetBinaryData();
#EndIf

EndFunction

#EndRegion

#Region EventsHandlers

Procedure Code401_ResponseHandler(Session, PreparedRequest, Settings, Response)

	If IsRedirect(Response.StatusCode, Response.Headers) Then
		Return;
	EndIf;

	HTTPStatusCodes = HTTPStatusCodes();
	If Response.StatusCode < HTTPStatusCodes.BadRequest_400
		Or Response.StatusCode >= HTTPStatusCodes.InternalServerError_500 Then
		Return;
	EndIf;

	Value = HeaderValue("www-authenticate", Response.Headers);
	If Value <> False And StrFind(Lower(Value), "digest") Then
		Position = StrFind(Lower(Value), "digest");
		Value = Mid(Value, Position + StrLen("digest") + 1);
		Value = StrReplace(Value, """", "");
		Value = StrReplace(Value, Chars.LF, "");

		DigestParameters = New Structure("algorithm,realm,nonce,qop,opaque");
		For Each Part In SplitStringByString(Value, ", ") Do
			KeyValue = StrSplit(Part, "=");
			DigestParameters.Insert(KeyValue[0], KeyValue[1]);
		EndDo;

		Session.ServiceData.DigestParameters = DigestParameters;

		PreparedRequest.Headers.Insert("Authorization", PrepareHeaderDigest(Session, PreparedRequest));
		PreparedRequest.HTTPRequest.Headers = PreparedRequest.Headers;

		Response = SendHTTPRequest(Session, PreparedRequest, Settings);
	EndIf;

EndProcedure

Function DetermineHashFunction(Val Algorithm)

	Algorithm = Upper(Algorithm);
	If Not ValueIsFilled(Algorithm) Or Algorithm = "MD5" Or Algorithm = "MD5-SESS" Then
		HashingAlgorithm = HashFunction.MD5;
	ElsIf Algorithm = "SHA" Then
		HashingAlgorithm = HashFunction.SHA1;
	ElsIf Algorithm = "SHA-256" Then
		HashingAlgorithm = HashFunction.SHA256;
	Else
		HashingAlgorithm = Undefined;
	EndIf;

	Return HashingAlgorithm;

EndFunction

Function PrepareHeaderDigest(Session, PreparedRequest)

	DigestParameters = Session.ServiceData.DigestParameters;

	Algorithm = DetermineHashFunction(DigestParameters.algorithm);
	AlgorithmString = Upper(DigestParameters.algorithm);
	If Algorithm = Undefined Then
		Return Undefined;
	EndIf;

	URLComposition = ParseURL(PreparedRequest.URL);
	Path = URLComposition.Path;
	If ValueIsFilled(URLComposition.RequestParameters) Then
		Path = Path + "?" + EncodeRequestParameters(URLComposition.RequestParameters);
	EndIf;

	A1 = StrTemplate("%1:%2:%3",
		PreparedRequest.Authentication.User,
		DigestParameters.realm,
		PreparedRequest.Authentication.Password);
	A2 = StrTemplate("%1:%2", PreparedRequest.Method, Path);

	HA1 = DataHashing(Algorithm, A1);
	HA2 = DataHashing(Algorithm, A2);

	If Not DigestParameters.Property("last_nonce") Then
		DigestParameters.Insert("last_nonce");
	EndIf;

	If DigestParameters.nonce = DigestParameters.last_nonce Then
		DigestParameters.nonce_count = DigestParameters.nonce_count + 1;
	Else
		DigestParameters.Insert("nonce_count", 1);
	EndIf;

	NCValue = Format(DigestParameters.nonce_count, "ЧЦ=8; ЧВН=; ЧГ=");
	NonceValue = Left(StrReplace(Lower(New UUID), "-", ""), 16);

	If AlgorithmString = "MD5-SESS" Then
		HA1 = DataHashing(Algorithm, StrTemplate("%1:%2:%3", HA1, DigestParameters.nonce, NonceValue));
	EndIf;

	If Not ValueIsFilled(DigestParameters.qop) Then
		ResponseValue = DataHashing(Algorithm, StrTemplate("%1:%2:%3", HA1, DigestParameters.nonce, HA2));
	ElsIf DigestParameters.qop = "auth"
		Or StrSplit(DigestParameters.qop, ",", False).Find("auth") <> Undefined Then
		NonceBitValue = StrTemplate("%1:%2:%3:%4:%5", DigestParameters.nonce, NCValue, NonceValue, "auth", HA2);
		ResponseValue = DataHashing(Algorithm, StrTemplate("%1:%2", HA1, NonceBitValue));
	Else
		// INFO: auth-int не реализовано
		Return Undefined;
	EndIf;

	DigestParameters.last_nonce = DigestParameters.nonce;

	Basis = StrTemplate("username=""%1"", realm=""%2"", nonce=""%3"", uri=""%4"", response=""%5""",
		PreparedRequest.Authentication.User,
		DigestParameters.realm,
		DigestParameters.nonce,
		Path,
		ResponseValue);
	Strings = New Array;
	Strings.Add(Basis);

	If ValueIsFilled(DigestParameters.opaque) Then
		Strings.Add(StrTemplate(", opaque=""%1""", DigestParameters.opaque));
	EndIf;
	If ValueIsFilled(DigestParameters.algorithm) Then
		Strings.Add(StrTemplate(", algorithm=""%1""", DigestParameters.algorithm));
	EndIf;
	If ValueIsFilled(DigestParameters.qop) Then
		Strings.Add(StrTemplate(", qop=""auth"", nc=%1, cnonce=""%2""", NCValue, NonceValue));
	EndIf;

	Return StrTemplate("Digest %1", StrConcat(Strings, ""));

EndFunction

Function DataHashing(Val Algorithm, Val Data)

	If TypeOf(Data) = Type("String") Then
		Data = GetBinaryDataFromString(Data, TextEncoding.UTF8, False);
	EndIf;

	Hashing = New DataHashing(Algorithm);
	Hashing.Append(Data);

	Return Lower(GetHexStringFromBinaryData(Hashing.HashSum));

EndFunction

Function SplitStringByString(Val String, Delimiter)

	Result = New Array;
	While True Do
		Position = StrFind(String, Delimiter);
		If Position = 0 And ValueIsFilled(String) Then
			Result.Add(String);
			Break;
		EndIf;

		FirstPart = Left(String, Position - StrLen(Delimiter) + 1);
		Result.Add(FirstPart);
		String = Mid(String, Position + StrLen(Delimiter));
	EndDo;

	Return Result;

EndFunction

#EndRegion

Function UnpackResponse(Response)

	Header = HeaderValue("content-encoding", Response.Headers);
	If Header <> False Then
		If Lower(Header) = "gzip" Then
			Return ReadGZip(Response.Body);
		EndIf;
	EndIf;

	Return Response.Body;

EndFunction

Procedure PackRequest(Query)

	Header = HeaderValue("content-encoding", Query.Headers);
	If Header <> False Then
		If Lower(Header) = "gzip" Then
			Query.SetBodyFromBinaryData(WriteGZip(Query.GetBodyAsBinaryData()));
		EndIf;
	EndIf;

EndProcedure

#Region ParametersByDefault

Function DefaultHeaders()

	Headers = New Map;
#If MobileAppServer Then
	Headers.Insert("Accept-Encoding", "identity");
#Else
	Headers.Insert("Accept-Encoding", "gzip");
#EndIf
	Headers.Insert("Accept", "*/*");
	Headers.Insert("Connection", "keep-alive");

	Return Headers;

EndFunction

Function MaximumNumberOfRedirects()

	Return 30;

EndFunction

Function TimeoutByDefault()

	Return 30;

EndFunction

Function JSONConversionParametersByDefault()

	ConversionParametersByDefault = New Structure;
	ConversionParametersByDefault.Insert("ReadToMap", True);
	ConversionParametersByDefault.Insert("JSONDateFormat", JSONDateFormat.ISO);
	ConversionParametersByDefault.Insert("PropertiesNamesWithDateValues", Undefined);
	ConversionParametersByDefault.Insert("JSONDateWritingVariant", JSONDateWritingVariant.LocalDate);
	ConversionParametersByDefault.Insert("ConvertionFunctionName", Undefined);
	ConversionParametersByDefault.Insert("ConvertionFunctionModule", Undefined);
	ConversionParametersByDefault.Insert("ConvertionFunctionAdditionalParameters", Undefined);

	Return ConversionParametersByDefault;

EndFunction

Function JSONWriterSettingsByDeafult()

	JSONWriterSettingsByDeafult = New Structure;
	JSONWriterSettingsByDeafult.Insert("NewLines", ПереносСтрокJSON.Авто);
	JSONWriterSettingsByDeafult.Insert("PaddingSymbols", " ");
	JSONWriterSettingsByDeafult.Insert("UseDoubleQuotes", True);
	JSONWriterSettingsByDeafult.Insert("EscapeCharacters", JSONCharactersEscapeMode.None);
	JSONWriterSettingsByDeafult.Insert("EscapeAngleBrackets", False);
	JSONWriterSettingsByDeafult.Insert("EscapeLineTerminators", True);
	JSONWriterSettingsByDeafult.Insert("EscapeAmpersand", False);
	JSONWriterSettingsByDeafult.Insert("EscapeSingleQuotes", False);
	JSONWriterSettingsByDeafult.Insert("EscapeSlash", False);

	Return JSONWriterSettingsByDeafult;

EndFunction

#EndRegion

Procedure FillAdditionalData(AdditionalParameters, RequestParameters, Data, Json)

	If AdditionalParameters = Undefined Then
		AdditionalParameters = New Structure();
	EndIf;
	If Not AdditionalParameters.Property("RequestParameters") Then
		AdditionalParameters.Insert("RequestParameters", RequestParameters);
	EndIf;
	If Not AdditionalParameters.Property("Data") Then
		AdditionalParameters.Insert("Data", Data);
	EndIf;
	If Not AdditionalParameters.Property("Json") Then
		AdditionalParameters.Insert("Json", Json);
	EndIf;

EndProcedure

Procedure Pause(StopDurationInSeconds)
	
	// Когда-нибудь в платформе сделают паузу и это можно будет выкинуть
	
	If StopDurationInSeconds < 1 Then
		Return;
	EndIf;

	CurrentDate = CurrentUniversalDate();
	WaitUntill = CurrentDate + StopDurationInSeconds;

	// BSLLS:UsingHardcodeNetworkAddress-off
	LocalHost = "127.0.0.0";
	RandomFreePort = 56476;
	// BSLLS:UsingHardcodeNetworkAddress-on
	While CurrentDate < WaitUntill Do
		Timeout = WaitUntill - CurrentDate;
		Start = CurrentUniversalDateInMilliseconds();
		Try
			Connection = New HTTPConnection(
				LocalHost, RandomFreePort, Undefined, Undefined, Undefined, Timeout);
			Connection.Get(New HTTPRequest("/does_not_matter"));
		Except
			RealTimeout = CurrentUniversalDateInMilliseconds() - Start;
		EndTry;
		MinimalTimeoutInMilliseconds = 1000;
		If RealTimeout < MinimalTimeoutInMilliseconds Then
			Raise(НСтр("ru = 'Процедура Pause не работает должным образом'; en = 'Процедура Pause не работает должным образом'"));
		EndIf;
		CurrentDate = CurrentUniversalDate();
	EndDo;

EndProcedure

Function CurrentSession(Session)

	If Session = Undefined Then
		Session = NewSession();
	EndIf;

	Return Session;

EndFunction

Function HTTPStatusesCodesDescriptions()

	Codes = New Array;
	Codes.Add(NewHTTPCode(100, "Continue_100", "Continue"));
	Codes.Add(NewHTTPCode(101, "SwitchingProtocols_101", "Switching Protocols"));
	Codes.Add(NewHTTPCode(102, "Processing_102", "Processing"));
	Codes.Add(NewHTTPCode(103, "EarlyHints_103", "Early Hints"));

	Codes.Add(NewHTTPCode(200, "OK_200", "OK"));
	Codes.Add(NewHTTPCode(201, "Created_201", "Created"));
	Codes.Add(NewHTTPCode(202, "Accepted_202", "Accepted"));
	Codes.Add(NewHTTPCode(203, "NonAuthoritativeInformation_203", "Non-Authoritative Information"));
	Codes.Add(NewHTTPCode(204, "NoContent_204", "No Content"));
	Codes.Add(NewHTTPCode(205, "ResetContent_205", "Reset Content"));
	Codes.Add(NewHTTPCode(206, "PartialContent_206", "Partial Content"));
	Codes.Add(NewHTTPCode(207, "MultiStatus_207", "Multi-Status"));
	Codes.Add(NewHTTPCode(208, "AlreadyReported_208", "Already Reported"));
	Codes.Add(NewHTTPCode(226, "IMUsed_226", "IM Used"));

	Codes.Add(NewHTTPCode(300, "MultipleChoices_300", "Multiple Choices"));
	Codes.Add(NewHTTPCode(301, "MovedPermanently_301", "Moved Permanently"));
	Codes.Add(NewHTTPCode(302, "MovedTemporarily_302", "Moved Temporarily"));
	Codes.Add(NewHTTPCode(303, "SeeOther_303", "See Other"));
	Codes.Add(NewHTTPCode(304, "NotModified_304", "Not Modified"));
	Codes.Add(NewHTTPCode(305, "UseProxy_305", "Use Proxy"));
	Codes.Add(NewHTTPCode(307, "TemporaryRedirect_307", "Temporary Redirect"));
	Codes.Add(NewHTTPCode(308, "PermanentRedirect_308", "Permanent Redirect"));

	Codes.Add(NewHTTPCode(400, "BadRequest_400", "Bad Request"));
	Codes.Add(NewHTTPCode(401, "Unauthorized_401", "Unauthorized"));
	Codes.Add(NewHTTPCode(402, "PaymentRequired_402", "Payment Required"));
	Codes.Add(NewHTTPCode(403, "Forbidden_403", "Forbidden"));
	Codes.Add(NewHTTPCode(404, "NotFound_404", "Not Found"));
	Codes.Add(NewHTTPCode(405, "MethodNotAllowed_405", "Method Not Allowed"));
	Codes.Add(NewHTTPCode(406, "NotAcceptable_406", "Not Acceptable"));
	Codes.Add(NewHTTPCode(407, "ProxyAuthenticationRequired_407", "Proxy Authentication Required"));
	Codes.Add(NewHTTPCode(408, "RequestTimeout_408", "Request Timeout"));
	Codes.Add(NewHTTPCode(409, "Conflict_409", "Conflict"));
	Codes.Add(NewHTTPCode(410, "Gone_410", "Gone"));
	Codes.Add(NewHTTPCode(411, "LengthRequired_411", "Length Required"));
	Codes.Add(NewHTTPCode(412, "PreconditionFailed_412", "Precondition Failed"));
	Codes.Add(NewHTTPCode(413, "PayloadTooLarge_413", "Payload Too Large"));
	Codes.Add(NewHTTPCode(414, "URITooLong_414", "URI Too Long"));
	Codes.Add(NewHTTPCode(415, "UnsupportedMediaType_415", "Unsupported Media Type"));
	Codes.Add(NewHTTPCode(416, "RangeNotSatisfiable_416", "Range Not Satisfiable"));
	Codes.Add(NewHTTPCode(417, "ExpectationFailed_417", "Expectation Failed"));
	Codes.Add(NewHTTPCode(419, "AuthenticationTimeout_419", "Authentication Timeout"));
	Codes.Add(NewHTTPCode(421, "MisdirectedRequest_421", "Misdirected Request"));
	Codes.Add(NewHTTPCode(422, "UnprocessableEntity_422", "Unprocessable Entity"));
	Codes.Add(NewHTTPCode(423, "Locked_423", "Locked"));
	Codes.Add(NewHTTPCode(424, "FailedDependency_424", "Failed Dependency"));
	Codes.Add(NewHTTPCode(425, "TooEarly_425", "Too Early"));
	Codes.Add(NewHTTPCode(426, "UpgradeRequired_426", "Upgrade Required"));
	Codes.Add(NewHTTPCode(428, "PreconditionRequired_428", "Precondition Required"));
	Codes.Add(NewHTTPCode(429, "TooManyRequests_429", "Too Many Requests"));
	Codes.Add(NewHTTPCode(431, "RequestHeaderFieldsTooLarge_431", "Request Header Fields Too Large"));
	Codes.Add(NewHTTPCode(449, "RetryWith_449", "Retry With"));
	Codes.Add(NewHTTPCode(451, "UnavailableForLegalReasons_451", "Unavailable For Legal Reasons"));
	Codes.Add(NewHTTPCode(499, "ClientClosedRequest_499", "Client Closed Request"));

	Codes.Add(NewHTTPCode(500, "InternalServerError_500", "Internal Server Error"));
	Codes.Add(NewHTTPCode(501, "NotImplemented_501", "Not Implemented"));
	Codes.Add(NewHTTPCode(502, "BadGateway_502", "Bad Gateway"));
	Codes.Add(NewHTTPCode(503, "ServiceUnavailable_503", "Service Unavailable"));
	Codes.Add(NewHTTPCode(504, "GatewayTimeout_504", "Gateway Timeout"));
	Codes.Add(NewHTTPCode(505, "HTTPVersionNotSupported_505", "HTTP Version Not Supported"));
	Codes.Add(NewHTTPCode(506, "VariantAlsoNegotiates_506", "Variant Also Negotiates"));
	Codes.Add(NewHTTPCode(507, "InsufficientStorage_507", "Insufficient Storage"));
	Codes.Add(NewHTTPCode(508, "LoopDetected_508", "Loop Detected"));
	Codes.Add(NewHTTPCode(509, "BandwidthLimitExceeded_509", "Bandwidth Limit Exceeded"));
	Codes.Add(NewHTTPCode(510, "NotExtended_510", "Not Extended"));
	Codes.Add(NewHTTPCode(511, "NetworkAuthenticationRequired_511", "Network Authentication Required"));
	Codes.Add(NewHTTPCode(520, "UnknownError_520", "Unknown Error"));
	Codes.Add(NewHTTPCode(521, "WebServerIsDown_521", "Web Server Is Down"));
	Codes.Add(NewHTTPCode(522, "ConnectionTimedOut_522", "Connection Timed Out"));
	Codes.Add(NewHTTPCode(523, "OriginIsUnreachable_523", "Origin Is Unreachable"));
	Codes.Add(NewHTTPCode(524, "ATimeoutOccurred_524", "A Timeout Occurred"));
	Codes.Add(NewHTTPCode(525, "SSLHandshakeFailed_525", "SSL Handshake Failed"));
	Codes.Add(NewHTTPCode(526, "InvalidSSLCertificate_526", "Invalid SSL Certificate"));

	Return Codes;

EndFunction

Function NewHTTPCode(Code, Key_, Description)

	Return New Structure("Code, Key, Description", Code, Key_, Description);

EndFunction

Function StrStartsWith_ThisModule( String, SearchString ) Export
	
	Return(Left( String, StrLen( SearchString ) ) = SearchString );
	
EndFunction // StrStartsWith

#EndRegion