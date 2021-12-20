# Universal Tools  1С for managed forms

[![Quality Gate Status](https://sonar.openbsl.ru/api/project_badges/measure?project=tools_ui_1c&metric=alert_status)](https://sonar.openbsl.ru/dashboard?id=tools_ui_1c) 
[![Join telegram chat](https://img.shields.io/badge/chat-telegram-blue?style=flat&logo=telegram)](https://t.me/tools_ui_1c) 
[![Last release](https://img.shields.io/github/v/release/cpr1c/tools_ui_1c?include_prereleases&label=last%20release&style=badge)](https://github.com/i-neti/tools_ui_1c_international/releases/latest)
[![download](https://img.shields.io/github/downloads/cpr1c/tools_ui_1c/total)](https://github.com/cpr1c/tools_ui_1c/releases/latest/download/UI.cfe)
[![GitHub issues](https://img.shields.io/github/issues-raw/i-neti/tools_ui_1c_international?style=badge)](https://github.com/i-neti/tools_ui_1c_international/issues)
[![License](https://img.shields.io/github/license/cpr1c/tools_ui_1c?style=badge)](https://github.com/i-neti/tools_ui_1c_international/blob/master/LICENSE)

[RUSSIAN VERSION OF THIS DOCUMENT](https://github.com/i-neti/tools_ui_1c_international/blob/develop/README_RU.md)

[Подержать проект](#донаты-и-поддержка-проекта)
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

1. Есть возможность удобной отладки дополнительных отчетов и обраток. Подробнее в [wiki](https://github.com/cpr1c/tools_ui_1c/wiki/Отладка-внешних-обработок-БСП)
1. В списки и формы объектов добавляется подменю "Инструменты", которое содержит пункты(Формы должны быть подключены к подсистеме "Подключаемые команды"):
	* **Добавить к сравнению** - добавляет выледенные объекты к сравнению для дальнейшего использования в инструменте "Сравнение объектов"
	* **Редактировать объект** - Позволяет текущий объект открыть в редакторе реквизитов
	* **Сравнить объекты** - Открывает инструмент "Сравнение объектов" с выделенными ссылками в качестве объектов сравнения. Доступно только для списков
    * **Найти ссылки на объект** - Открывает инструмент "Поиск ссылок на объект" для текущего объекта
    * **Выгрузить объекты в XML** - Выполняет выгрузку выбранных объектов с подчиненными ссылками с использованием инструмента "Выгрузка загрузка XML"


# Programming interface

## Connector: handy HTTP-client for 1C:Enterprise 8 platform

Доступна программно через общий модуль **UT_HTTPConnector**. Подробное описание смотрите на странице библиотеки https://github.com/vbondarevsky/Connector/blob/master/README-EN.md

Пример использования:

`Result = HTTPConnector.GetJson("https://api.github.com/events");`

## 1C Serialization Library

Доступна программно через обработку **УИ_ПреобразованиеДанныхJSON**. Подробное описание методов смотрите на странице библиотеки https://github.com/arkuznetsov/SerLib1C

Инициализация:

`Сериализатор1С = Обработки.УИ_ПреобразованиеДанныхJSON.Создать()` 
 
Example: 
 
```bsl
СериализаторJSON=Обработки.УИ_ПреобразованиеДанныхJSON.Создать();

СтруктураИстории=СериализаторJSON.ЗначениеВСтруктуру(ДанныеСохранения);
СериализуемаяСтрокаJSON=СериализаторJSON.ЗаписатьОписаниеОбъектаВJSON(СтруктураИстории);
``` 
## Working with the OS clipboard

Доступна программно через модуль **УИ_БуферОбменаКлиент**. Описание методов в коде. Поддерживается синхронный и асинхронный режим работы. https://github.com/cpr1c/clipboard_1c


Пример использования: 
```bsl
УИ_БуферОбменаКлиент.КопироватьСтрокуВБуфер("Моя строка для копирования в буфер обмена");
``` 

## Working with regular expressions

Доступна программно через модуль **УИ_РегулярныеВыраженияКлиентСервер**. Описание методов в коде. Поддерживается синхронный и асинхронный режим работы. https://github.com/cpr1c/RegEx1C_cfe


Пример использования: 
```bsl
УИ_РегулярныеВыраженияКлиентСервер.Совпадает("Hello world", "([A-Za-z]+)\s+([a-z]+)"); //Истина
``` 

 
## Получение структуры виртуальных таблиц запроса или менеджера временных таблиц

Необходимо в форме вычисления выражения вызвать функцию **УИ_._ВТ(ЗапросИЛИМенеджерВременныхТаблиц)**. 

Примеры использования: 

`УИ_._ВТ(Запрос)`

`УИ_._ВТ(Запрос.МенеджерВременныхТаблиц)`

## Comparison of two value tables

Необходимо в форме вычисления выражения вызвать функцию **_ТЗСр(ТаблицаБазовая, ТаблицаСравнения, СписокКолонок)**. 

Примеры использования: 

`УИ_._ТЗСр(ТаблицаБазовая, ТаблицаСравнения)` - выполнит сравнение по всем колонкам параметра ТаблицаБазовая

`УИ_._ТЗСр(ТаблицаБазовая, ТаблицаСравнения, "Номенклатура,Количество")`

## Serialization of XML into simple data structures (array, structure, map)

Необходимо в форме вычисления выражения вызвать функцию **_XMLОбъект(ПутьЧтения, УпроститьЭлементы)**. 

Примеры использования: 

`УИ_._XMLОбъект(ЧтениеXML)` - выполнит обход сущществующего объекта ЧтениеXML

`УИ_._XMLОбъект("C:\1.xml")` - выполнит чтение в структуры файла

`УИ_._XMLОбъект(Поток)` - выполнит чтение в структуры потока

`УИ_._XMLОбъект("C:\1.xml", Ложь)` - выполнит чтение в структуры файла без упрощения полученных структур

# Debug
[Особенности использования отладки в портативной поставке](https://github.com/cpr1c/tools_ui_1c/wiki/Особенности-использования-отладки-в-портативном-варианте)
### Вызов

Необходимо в форме вычисления выражения вызвать функцию **УИ_._От(ВашаПеременнаяОбъектаОтладки,НастройкиСКД)**. Где вместо ВашаПеременнаяОбъектаОтладки нужно передать переменную, содержащую один из доступных к отладке объектов

### Логика работы

Если контекст запуска отладки является толстым клиентом открытие формы консоли происходит сразу по окончании выполнения вызова кода

Если отладка вызывается в контексте сервера или тонкого или веб клиента, необходимая информация сохраняется в справочник **Данные для отладки**. В таком случае вызов отладки проиходит потом из списка справочника "Данные для отладки". 


### Поддерживается отладка объектов:

* **Запрос**- на текущий момент отлаживаются запросы без менеджеров временных таблиц. 
Вызов отладки 

`УИ_._От(Запрос)`

* **Схема компоновки данных**- поддерживается отладка без внешних источников данных. 

Вызов отладки

`УИ_._От(СхемаКомпоновкиДанных,НастройкиСКД)` - будет вызвана отладка с переданными настройками

`УИ_._От(СхемаКомпоновкиДанных)` - будет вызвана отладка с настройками по умолчанию для СКД

`УИ_._От(СхемаКомпоновкиДанных,НастройкиСКД, ВнешниеНаборыДанных)` - будет вызвана отладка с переданными настройками и внешними наборами данных

* **Ссылочный объект базы**- просмотр и редактирование ссылки БД

Вызов отладки

`УИ_._от(СсылкаНаОбъектБД)`

* **HTTP Запрос**- поддерживается отладка строкового и файлового содержимого запросов, а также прокси

Выззов отладки

`УИ_._От(HTTPЗапрос,СоединениеHTTP)`

# Сборка в бинарные файлы

Зависимости сборки теперь находятся в файле packagedef, в папке build для установки зависимостей необходимо выполнить команду
`opm install`  находясь в корне проекта

В корне репозитория вызвать файл сценария 

* **build.sh** - для Linux
* **build.bat** - для Windows

Доступные параметры сборки:
  * **--platformSource**  - Каталог установки платформы для выполнения сборки
  * **--versionEDT** - Версия EDT для выполнения конвертации. Для запуска через утилиту ring. Необходимо указывать, если в системе установлено более одной версии 1C:EDT
  * **--cfe** - Формировать сборку в формате Расширения
  * **--cf** - Формировать сборку в виде конфигурации
   
Пример 
`./build.sh ----platformSource=/opt/1cv8/x86_64/8.3.12.1924 --versionEDT=edt@2020.6.0`

# Развитие инструментов

Разработка ведется в 1С:EDT

Замечания и предложения оставляйте в разделе **issues**. 

Если кто хочет поучаствовать - добро пожаловать. Больше идей- лучше конечное решение. Перед началом прочитайте [инструкцию для легкого старта](https://github.com/cpr1c/tools_ui_1c/tree/develop/docs/contributing) 

# Donation and project support

Поддержать проект деньгой можно по ссылке https://donate.stream/ya410011848843350

**Все собранные средства пойдут ИСКЛЮЧИТЕЛЬНО на развитие проекта и никуда более**

# Ссылки на инструмены так или иначе участвовавшие в проекте
* https://github.com/khorevaa/xml-parser- была основной для фукнции чтения XML в простые структуры данных
* https://github.com/pm74/_37583.git- На ее основе реализовывается механизм алгоритмов(хотя пока и не доделан)
* https://github.com/partizand/debug_external_dataprocessor - Основа для разработки поддержки отладки внешних обработок БСП
* https://github.com/salexdv/bsl_console - Редактор кода 1С - Monaco
