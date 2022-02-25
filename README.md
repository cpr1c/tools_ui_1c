# Universal Tools  1С for managed forms

[![Quality Gate Status](https://sonar.openbsl.ru/api/project_badges/measure?project=tools_ui_1c&metric=alert_status)](https://sonar.openbsl.ru/dashboard?id=tools_ui_1c) 
[![Join telegram chat](https://img.shields.io/badge/chat-telegram-blue?style=flat&logo=telegram)](https://t.me/tools_ui_1c) 
[![Last release](https://img.shields.io/github/v/release/i-neti/tools_ui_1c_international?include_prereleases&label=last%20release&style=badge)](https://github.com/i-neti/tools_ui_1c_international/releases/latest)
[![download](https://img.shields.io/github/downloads/i-neti/tools_ui_1c_international/total)](https://github.com/i-neti/tools_ui_1c_international/releases/latest/download/UniversalTools.cfe)
[![GitHub issues](https://img.shields.io/github/issues-raw/i-neti/tools_ui_1c_international?style=badge)](https://github.com/i-neti/tools_ui_1c_international/issues)
[![License](https://img.shields.io/github/license/i-neti/tools_ui_1c_international?style=badge)](https://github.com/i-neti/tools_ui_1c_international/blob/master/LICENSE)

[RUSSIAN VERSION OF THIS DOCUMENT](https://github.com/i-neti/tools_ui_1c_international/blob/develop/README_RU.md)

### Для разработчика 
План разработки : https://github.com/i-neti/tools_ui_1c_international/blob/develop/docs/DEVELOPMENTPLAN.md
Детальное соотвествие русских имен метаданных и имени функций и их англоязычного перевода https://github.com/i-neti/tools_ui_1c_international/blob/develop/docs/DETAILS.md
Данный документ в работе и постоянно обновляется 

### Supported Operation Systems
* Windows x86
* Windows x64
* Linux x64
* Linux x86

It should work on Mac OS, but has not been tested

### Supported type of client applications

* Thick client managed application
* Thin client
* Web client (partially)

### Supported configuration modes
The module is  developed with  disabled support for modality and synchronous calls. 
It should work in all modern and not so configurations

### Supported platforms
8.3.12 and later

###  Distribution method and license
The subsystem is developed and distributed under the GNU General Public License v3.0. 
The code is open, you can copy and distribute to anyone, but also with open source sharing.

### Currently content of tools:

- **Group processing  of catalogs and documents**- allows you to massively change the attributes and tabular parts in selected catalogs and documents.
- **Constant Editor** - allows you to edit the values of constants in table mode
- **Database Storage Structure**- View table names and their relationships with metadata objects.
- **Removal of marked objects**-  a copy of the standard Data processor from the SSL (Standart Subsystems Library), adapted for use outside the SSL.
- **Query Console**- Data processor for developing and executing queries in user mode. Fork of https://github.com/hal9000cc/RequestConsole9000. [GPL3 License](https://github.com/hal9000cc/RequestConsole9000/blob/master/LICENSE)
- **Jobs console**- view and set parametrs of scheduled  and background jobs. Fork of https://github.com/kuzyara/JobsConsole2019.epf [Author's permission](https://github.com/kuzyara/JobsConsole2019.epf/issues/6)
- **Registration of changes for exchange**- Data processor allows you to edit the registration of changes to data exchange objects at the Exchange Plan Node. Is intended for data exchange developers, data administrators and advanced users.
- **Search and removal of duplicates**- A fork of the standard data processor from the SSL (Standart Subsystems Library), to which several parameters for performing the replacement have been added
- **Code Console**- Allows you to execute code from the enterprise without creating external Data Processor. There is syntax highlighting and a minimal contextual hint
- **Search for object references**- an analogue of the standard data processor from the "All functions" menu.
- **Object attibutes editor**- allows low-level editing of attributes of reference objects. Supports  document records editing. Fork of https://infostart.ru/public/983887/. Cutted from https://infostart.ru/public/938606/. [Author's permission](http://forum.infostart.ru/forum24/topic203301/message2375899/#message2375899)
- **Reports console**- it is based on a Data Composition System and uses most of its features. With its help, you can create and execute reports of almost any complexity without resorting to programming.
- **Dynamic list**- convenient viewing of lists of database tables from a single data processor
- **HTTP Request Console**-  allows you to make HTTP requests from 1C. 
- **Loading/Uploading XML with filters** - Transferring information between two similar databases. Fork of https://infostart.ru/public/1149722/ [Author's permission](http://forum.infostart.ru/forum15/topic229143/message2372663/#message2372663)
- **Configuration Navigator**- This data processor replases  standart command "All Functions" and contains additional administrative functions. Fork of https://infostart.ru/public/931586/. [Author's permission](http://forum.infostart.ru/forum9/topic202659/message2375904/#message2375904)
- **File manager** - Data processor for convenient work with files between the client and the server.Support file Transfer, View, delete of files. Currently contains synchronous calls. Fork of  https://infostart.ru/public/1027326/. [Author's permission](https://github.com/cpr1c/tools_ui_1c/issues/108)
- **Regular Expressions Constructor**-  allows you to build complex structured expressions based on a parametric description, test them, and as a result get the 1C program code. Currently it only works on Windows. Fork of https://infostart.ru/public/592108/. [Author's permission](http://forum.infostart.ru/forum9/topic167495/message2389269/#message2389269)
- **Web Services Console** -data processor for reading and executing web services on the 1C: Enterprise 8.3 platform. Analog of SoapUI. Allows you to perform a web service operation and display the result as xml or a tree. Fork of  https://github.com/ghostaz/WSReader2.git. [GPL3 License](https://github.com/ghostaz/WSReader2/blob/master/LICENSE)
- **Data comparsion console**- it is used to compare data obtained from different data sources: 1C 8, 1C 7.7 information databases, SQL databases, CSV/TXT/DBF/XLS/DOC/XML format files, JSON strings, manually filled tabular document. Fork of https://infostart.ru/public/581794. [Author's permission](http://forum.infostart.ru/forum9/topic165873/message2373325/#message2373325)
- **Information about 1C licenses**-this is GUI for  1C licensing utilities  (RING). Fork of  https://infostart.ru/public/1124442/. [Author's permission](http://forum.infostart.ru/forum9/topic226186/message2389245/#message2389245).  Должна быть установлена утилита ring и ее модули license
- **Data loader from Tabular document**-Data processor for load data to catalogs and tabular sections of different objects from из Tabular document. Fork of https://infostart.ru/public/269425/. [Author's permission](http://forum.infostart.ru/forum15/topic107643/message2397121/#message2397121) 
- **JSON Editor**- Allows you to edit JSON strings in a convenient form. It contains JSON syntax highlighting, tree editing, and some auto-substitutions. The editor is based on the library https://github.com/josdejong/jsoneditor . It works on Windows starting from platform version 8.3.14
- **HTML Editor**- Fast debugging of HTML pages display in 1C. It is a screen divided into 4 parts, on the left side there are three editors-HTML, CSS and JavaScript bodies, and on the right - the result field. There is a contextual hint and code completion. The library is used for code editors https://ace.c9.io/. It is indispensable when testing HTML output in 1C, because even from the 8.3.14 platform, the display in the browser and 1C, as well as in different operating systems, can be very different. It works on Windows since platform version 8.3.14. [Publication on infostart](https://infostart.ru/public/1273525/) 
- **Universal data exchange in XML format (with filters and direct download via HTTP service** - Unloading and loading according to the exchange rules. Fork of the standard data processor from 1С и https://infostart.ru/public/1176839/. [Author's permission](https://github.com/cpr1c/tools_ui_1c/issues/139). Added the ability to apply filters to unloaded objects, and direct uploading to the database via the http service of Universal Tools.  
- **Data Composition System Editor**- Analogue Data Composition Schema wizard for thin client. Currently, it does not support editing layouts and nested schemas.
- **Object comparison** - Comparison attribute to attribute of  reference objects with output to tabular document. Fork of https://infostart.ru/public/1240803/. [Author's permission](https://github.com/cpr1c/tools_ui_1c/issues/246)
- **1C Serialization Library**- A set of procedures and functions for serialization/deserialization of 1C data and DCS (Data Composition System) objects into simple data structures (Structure, Map, array). Fork of https://github.com/arkuznetsov/SerLib1C. [MPL-2.0 License](https://github.com/arkuznetsov/SerLib1C/blob/master/LICENSE)
- **Connector: handy HTTP-client for 1C:Enterprise 8 platform** - Python world has a very popular library working with HTTP requests  - [Requests](http://docs.python-requests.org/en/master) (author: Kenneth Reitz). The library allows you to send HTTP requests extremely easily. Literally a single line of your code can receive or send data, not caring about making URL, encoding data etc. **Connector** is "Requests" for 1C world. Fork of https://github.com/vbondarevsky/Connector/blob/master/README-EN.md. [Apache-2.0 License](https://github.com/vbondarevsky/Connector/blob/master/LICENSE)

# Integration with Standart Sybsystems Liblary (SSL)

1. There is a possibility of convenient debugging of additional reports and data processors. More detailed at [wiki](https://github.com/cpr1c/tools_ui_1c/wiki/Отладка-внешних-обработок-БСП)
2. The "Tools" submenu is added to the lists and forms of objects, which contains items (The forms must be connected to the "Attachable Commands" subsystem):
	* **Add to Comparison** - adds selected objects to comparison for further use in the "Object Comparison" tool
	* **Edit Object** - Allows you to open the current object in the Attributes editor
	* **Compare Objects** - Opens the "Compare Objects" tool with selected links as comparison objects. Available only for lists.
    * **Find Object References** - Opens the "Find Object References" tool for the current object.
    * **Upload objects to XML** -Performs unloading of selected objects with subordinate links using the "Loading/Uploading XML" tool.


# Programming interface

## Connector: handy HTTP-client for 1C:Enterprise 8 platform

Accessible from the API via the common module **UT_HTTPConnector**. For a detailed description, see the library page https://github.com/vbondarevsky/Connector/blob/master/README-EN.md

Example:

`Result = HTTPConnector.GetJson("https://api.github.com/events");`

## 1C Serialization Library

Available from API of data processor **UT_JSONDataConversion**. For a detailed description of the methods, see the library page https://github.com/arkuznetsov/SerLib1C

Initialization:

`Сериализатор1С = Обработки.УИ_ПреобразованиеДанныхJSON.Создать()` 
 
Example: 
 
```bsl
СериализаторJSON=Обработки.УИ_ПреобразованиеДанныхJSON.Создать();

СтруктураИстории=СериализаторJSON.ЗначениеВСтруктуру(ДанныеСохранения);
СериализуемаяСтрокаJSON=СериализаторJSON.ЗаписатьОписаниеОбъектаВJSON(СтруктураИстории);
``` 
## Working with the OS clipboard

Available from API of module **UT_ClipboardClient**. Description of methods in the code. Synchronous and asynchronous operation modes are supported. https://github.com/cpr1c/clipboard_1c


Example of use: 
```bsl
УИ_БуферОбменаКлиент.КопироватьСтрокуВБуфер("Моя строка для копирования в буфер обмена");
``` 

## Working with regular expressions

Доступна программно через модуль **УИ_РегулярныеВыраженияКлиентСервер**. Описание методов в коде. Поддерживается синхронный и асинхронный режим работы. https://github.com/cpr1c/RegEx1C_cfe


Example of use: 
```bsl
УИ_РегулярныеВыраженияКлиентСервер.Совпадает("Hello world", "([A-Za-z]+)\s+([a-z]+)"); //Истина
``` 

 
## Retrieving the virtual table structure of a query or temporary table manager

It is necessary to call the function in the form of evaluating an expression **УИ_._ВТ(ЗапросИЛИМенеджерВременныхТаблиц)**. 

Example of use: 

`УИ_._ВТ(Запрос)`

`УИ_._ВТ(Запрос.МенеджерВременныхТаблиц)`

## Comparison of two value tables

It is necessary to call the function in the form of evaluating an expression **_ТЗСр(ТаблицаБазовая, ТаблицаСравнения, СписокКолонок)**. 

Example of use: 

`УИ_._ТЗСр(ТаблицаБазовая, ТаблицаСравнения)` - will perform comparison across all columns of the TableBase parameter

`УИ_._ТЗСр(ТаблицаБазовая, ТаблицаСравнения, "Номенклатура,Количество")`

## Serialization of XML into simple data structures (array, structure, map)

It is necessary to call the function in the form of evaluating an expression **_XMLОбъект(ПутьЧтения, УпроститьЭлементы)**. 

Example of use: 

`УИ_._XMLОбъект(ЧтениеXML)` - will crawl an existing XMLReader

`УИ_._XMLОбъект("C:\1.xml")` - will read into file structures

`УИ_._XMLОбъект(Поток)` - will read into stream structures

`УИ_._XMLОбъект("C:\1.xml", Ложь)` - will read into file structures without simplifying the resulting structures

# Debug
[Особенности использования отладки в портативной поставке](https://github.com/cpr1c/tools_ui_1c/wiki/Особенности-использования-отладки-в-портативном-варианте)
### Call

It is necessary to call the function **УИ_._От(ВашаПеременнаяОбъектаОтладки,НастройкиСКД)** in the form of evaluating an expression. Where instead ВашаПеременнаяОбъектаОтладки you need to pass a variable containing one of the objects available for debugging

### How it works

If the debug launch context is a thick client, the console form opens immediately after the end of the code call.

If debugging is called in the context of a server or a thin or web client, the necessary information is saved in the **Данные для отладки** reference. In this case, debugging is called later from the list of the "Данные для отладки" reference book. 


### Debugging of objects is supported:

* **Запрос**- queries without temporary table managers are currently being debugged.
Debug call  

`УИ_._От(Запрос)`

* **Data Composition Schema**- Debugging without external data sources is supported. 

Debug call:

`УИ_._От(СхемаКомпоновкиДанных,НастройкиСКД)` - debugging with the transferred settings will be called

`УИ_._От(СхемаКомпоновкиДанных)` - debugging with default settings for DCS will be called

`УИ_._От(СхемаКомпоновкиДанных,НастройкиСКД, ВнешниеНаборыДанных)` - debugging will be called with the transferred settings and external datasets

* **Reference object of the database**- viewing and editing the reference of the database

Debug call

`УИ_._от(СсылкаНаОбъектБД)`

* **HTTP Запрос**- debugging of string and file content of requests, as well as proxy is supported

Debug call

`УИ_._От(HTTPЗапрос,СоединениеHTTP)`

# Building into binaries

The build dependencies are now in the file : packagedef, in the build folder to install the dependencies, you must run the command `opm install`  from the root of the project.

Call the script file at the root of the repository

* **build.sh** - for Linux
* **build.bat** - for Windows

Available build options:
  * **--platformSource**  - Platform installation directory for building execution
  * **--versionEDT** - EDT version to perform conversion. To run through the RING utility. Must be specified if the system has more than one version of 1C: EDT
  * **--cfe** - Generate assembly in Extension format
  * **--cf** - Form the assembly as a configuration
   
Example 
`./build.sh ----platformSource=/opt/1cv8/x86_64/8.3.12.1924 --versionEDT=edt@2020.6.0`

# Project development

The project is being developed in 1C: EDT.

Leave your comments and suggestions in the **issues** section. 

If you want to participate, you are welcome. The more ideas, the better the final solution. Before start please read [easy start instructions](https://github.com/cpr1c/tools_ui_1c/tree/develop/docs/contributing) 

# Donation and project support

You can support the project with money by following the link https://donate.stream/ya410011848843350

**All collected funds will go EXCLUSIVELY for the development of the project and nowhere else**

# Links to tools used in project (in some way)
* https://github.com/khorevaa/xml-parser- was basic for the function of reading XML into simple data structures.
* https://github.com/pm74/_37583.git- On its basis, a mechanism of algorithms is implemented (although it has not yet been completed)
* https://github.com/partizand/debug_external_dataprocessor - Basis for developing support for debugging external data processors in SSL
* https://github.com/salexdv/bsl_console - Code Editor 1С - Monaco
