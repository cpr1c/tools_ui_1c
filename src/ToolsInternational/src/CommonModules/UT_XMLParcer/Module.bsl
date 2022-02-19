//    Copyright 2018 khorevaa
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
//The module is a reworking of the publication https://github.com/khorevaa/xml-parser . Thanks to the author
// Translated to  english variant of 1C script by Neti  company ( i-neti.ru)

// Reads xml data into
//
// Параметры:
//   FilePath - String - path to the xml data file
//   SimplifyElements - Boolean - do I need to simplify the resulting object
//
// Return value:
// Map, Structure - result of reading xml data
//

Function mRead(Val ReaderPath, SimplifyElements = True) Export
#If WebClient Then
	Return Undefined;
#Else
		If TypeOf(ReaderPath) = Type("XMLReader") Then
			Read = ReaderPath;
		ElsIf TypeOf(ReaderPath) = Type("Stream") Or TypeOf(ReaderPath) = Type("MemoryStream") Or TypeOf(ReaderPath)
			= Type("FileStream") Then
			Read=New XMLReader;
			Read.OpenStream(ReaderPath);
		Else
			Read=New XMLReader;
			Read.OpenFile(ReaderPath);
		EndIf;

		Result = ReadXMLSection(Read, SimplifyElements);

		Read.Close();

		Return Result;
#EndIf

EndFunction


// Perform data serialization in the file
//
// Parameters:
//   XMLWriterData - Map, Array, Structure, Number, String. Date - data to be serialized in XML
//   FilePath - Строка - String - path to the xml data
//   WriteXMLDeclaration - Boolean - a sign of adding an XML declaration record
//
Procedure ЗаписатьВФайл(XMLWriterData, Val FilePath, Val WriteXMLDeclaration = False) Export
#If ThinClient Or WebClient Then

#Else

		XMLWriter = New XMLWriter;
		XMLWriter.OpenFile(FilePath);

		If WriteXMLDeclaration Then
			XMLWriter.WriteXMLDeclaration();
		EndIf;

		WriteXMLSection(XMLWriter, XMLWriterData);

		XMLWriter.Close();
#EndIf

EndProcedure

#If Not ThinClient And Not WebClient Then
#Region Write_Data_XML

//  Performs data serialization in XML
//
// Parameters:
//   XMLWriter - XMLWriter - prepared recird of XMLWriter
//   XMLWriterData - Map, Array, Structure, Number, String. Date - data for serialization in XML
//
Procedure WriteXMLSection(Val XMLWriter, Val XMLWriterData)

	WriteXMLValue(XMLWriter, XMLWriterData);

EndProcedure
Procedure WriteXMLValue(Val XMLWriter, Val XMLWriterData, Val RootNodeName = "")

	BeginElementWriting = Not IsBlankString(RootNodeName);

	If BeginElementWriting Then
		XMLWriter.WriteStartElement(XMLString(RootNodeName));
	EndIf;

	TypeOfXMLWriterData = TypeOf(XMLWriterData);

	If TypeOfXMLWriterData = Type("Array") Then
		WriteArrayToXML(XMLWriter, XMLWriterData);
	ElsIf TypeOfXMLWriterData = Type("Map") Or TypeOfXMLWriterData = Type("Structure") Then
		WriteMapToXML(XMLWriter, XMLWriterData);
	ElsIf IsSimpleType(TypeOfXMLWriterData) Then

		WriteText(XMLWriter, XMLWriterData);

	EndIf;

	If BeginElementWriting Then
		XMLWriter.WriteEndElement();
	EndIf;

EndProcedure

Function IsSimpleType(Val DataType)

	Return DataType = Type("Number") Or DataType = Type("String") Or DataType = Type("Boolean");

EndFunction

Procedure WriteAttributes(XMLWriter, AttributesData)

	If AttributesData.Count() = 0 Then
		Return;
	EndIf;

	For Each KeyValue In AttributesData Do

		XMLWriter.WriteAttribute(XMLString(KeyValue.Key), XMLString(KeyValue.Value));

	EndDo;

EndProcedure

Procedure WriteCDATASection(XMLWriter, CDATASectionData)

	If Not ValueIsFilled(CDATASectionData) Then
		Return;
	EndIf;

	XMLWriter.WriteCDATASection(CDATASectionData);

EndProcedure

Procedure WriteComment(XMLWriter, Comment)

	If Not ValueIsFilled(Comment) Then
		Return;
	EndIf;

	XMLWriter.WriteComment(XMLString(Comment));

EndProcedure

Procedure WriteText(XMLWriter, Text)

	If Not ValueIsFilled(Text) Then
		Return;
	EndIf;

	XMLWriter.WriteText(XMLString(Text));

EndProcedure

Procedure WriteArrayToXML(XMLWriter, Val ArrayData)

	For Each ArrayItem In ArrayData Do
		WriteXMLValue(XMLWriter, ArrayItem);
	EndDo;

EndProcedure

Procedure WriteMapToXML(XMLWriter, MapData)

	For Each KeyValue In MapData Do

		If KeyValue.Key = "_Attributes" Then
			WriteAttributes(XMLWriter, KeyValue.Value);
			Continue;
		EndIf;

		If KeyValue.Key = "_Comment" Then
			WriteComment(XMLWriter, KeyValue.Value);
			Continue;
		EndIf;

		If KeyValue.Key = "_CDATA" Then
			WriteCDATASection(XMLWriter, KeyValue.Value);
			Continue;
		EndIf;

		If KeyValue.Key = "_Value" Then
			WriteText(XMLWriter, KeyValue.Value);
			Continue;
		EndIf;

		If KeyValue.Key = "_Elements" Then
			WriteXMLValue(XMLWriter, KeyValue.Value);
			Continue;
		EndIf;

		WriteXMLValue(XMLWriter, KeyValue.Value, KeyValue.Key);

	EndDo;

EndProcedure

#EndRegion
#EndIf

#If Not WebClient Then
#Region read_Data_XML


// Reads and deserializes data from XML
//
// Параметры:
//   XMLReader - XMLReader - <parameter description>
//   RootNodeName -String - name of the current node, to call recursion
//
// Return value:
// Map, Structure - result of reading xml data
//
Function ReadXMLSection(Val XMLReader, Val SimplifyElements, Val RootNodeName = "")

	ReaderResult = New Structure;
	Attributes = New Map;
	Items = New Map;

	ReaderResult.Insert("_Attributes", Attributes);
	ReaderResult.Insert("_Elements", Items);

//	Log.Debug("Start reading the node <%1> из XML.", XMLReader.LocalName);

	ReadAttributes(XMLReader, Attributes);

	If Not XMLReader.NodeType = XMLNodeType.EndEntity Then
		ReadNodes(XMLReader, ReaderResult, SimplifyElements, RootNodeName);
	EndIf;

	 SimplifyReaderResult(ReaderResult, SimplifyElements);

//	Log.Debug("Reading  node <%1> finished.", XMLReader.LocalName);

	Return ReaderResult;

EndFunction
Procedure SimplifyReaderResult(ReaderResult, SimplifyElements)

	If Not SimplifyElements Then
		Return;
	EndIf;

	If ReaderResult["_Attributes"].Count() = 0 Then
		ReaderResult.Delete("_Attributes");
	EndIf;

	If ReaderResult["_Elements"].Count() = 0 Then
		ReaderResult.Delete("_Elements");
	EndIf;

	CanSimplified = ReaderResult.Count() = 1;

	If CanSimplified Then
		If ReaderResult.Property("_Value") Then
			ReaderResult = ReaderResult._Value;
		ElsIf ReaderResult.Property("_Elements") Then
			ReaderResult = ReaderResult._Elements;
		EndIf;
	ElsIf ReaderResult.Count() = 0 Then
		ReaderResult = Undefined;
	EndIf;

EndProcedure

Procedure ReadAttributes(Val XMLReader, Attributes)

	If XMLReader.AttributeCount() = 0 Then
//		LastAttributeName = Undefuned;
		Return;
	EndIf;

	For AttributeIndex = 0 To XMLReader.AttributeCount() - 1 Do

		AttributeName = XMLReader.AttributeName(AttributeIndex);
		AttributeValue = XMLReader.AttributeValue(AttributeName);

//		Лог.Отладка("Прочитано значение <%1> атрибута <%2>", ЗначениеАтрибута, ИмяАтрибута);
		Attributes.Insert(TrimAll(AttributeName), TrimAll(AttributeValue));
//		LastAttributeName = ЧтениеXML.Имя;
	EndDo;

EndProcedure

Procedure ReadNodes(Val XMLReader, RootNode, SimplifyElements, Val RootNodeName)

	While XMLReader.Read() Do

//		Лог.Отладка("Тип узла <%1>", ЧтениеXML.NodeType);
//		Лог.Отладка("Имя узла <%1>", ЧтениеXML.LocalName);

		If XMLReader.NodeType = XMLNodeType.EndElement And XMLReader.Name = RootNodeName Then
			Break;
		EndIf;

		If XMLReader.NodeType = XMLNodeType.StartElement Then

			NewNodeName = XMLReader.Name;
//			Лог.Отладка("Новый узел <%1>", NewNodeName);
			NodeMap = ReadXMLSection(XMLReader, SimplifyElements, NewNodeName);
			ВставитьЭлементУзла(RootNode, NewNodeName, NodeMap);

		ElsIf XMLReader.NodeType = XMLNodeType.Text Then

			ЗначениеСвойства = XMLReader.Value;
//			Лог.Отладка("Прочитано значение " + ЗначениеСвойства);
			RootNode.Insert("_Value", ЗначениеСвойства);

		ElsIf XMLReader.NodeType = XMLNodeType.Comment Then
			ЗначениеСвойства = XMLReader.Value;
//			Лог.Отладка("Прочитан комментарий " + ЗначениеСвойства);
			RootNode.Insert("_Comment", ЗначениеСвойства);

		ElsIf XMLReader.NodeType = XMLNodeType.CDATASection Then
			ЗначениеСвойства = XMLReader.Value;
//			Лог.Отладка("Прочитана СекцияCDATA " + ЗначениеСвойства);
			RootNode.Insert("_CDATA", ЗначениеСвойства);

		EndIf;

	EndDo;

EndProcedure

Procedure ВставитьЭлементУзла(RootNode, Val NewNodeName, NodeMap)

	NodeElementsType = TypeOf(RootNode._Elements);
	CurrentElementMap = New Map;
	CurrentElementMap.Insert(NewNodeName, NodeMap);

	If NodeElementsType = Type("Array") Then
		RootNode._Elements.Add(CurrentElementMap);
	ElsIf NodeElementsType = Type("Map") Then

		УжеЕстьЗначение = Not RootNode._Elements[NewNodeName] = Undefined;

		If УжеЕстьЗначение Then
			ElementsArray = New Array;

			For Each KeyValue In RootNode._Elements Do
				CurrentItem = New Map;
				CurrentItem.Insert(KeyValue.Key, KeyValue.Value);
				ElementsArray.Add(CurrentItem);
			EndDo;
			ElementsArray.Add(CurrentElementMap);

			//@skip-warning
			RootNode._Elements  = ElementsArray;

		Else

			CurrentElementMap = New Map;
			RootNode._Elements.Insert(NewNodeName, NodeMap);

		EndIf;
	Else

		Raise StrTemplate("Пришел не корректный тип значения <%1>", NodeElementsType);

	EndIf;

EndProcedure

#EndRegion
#EndIf