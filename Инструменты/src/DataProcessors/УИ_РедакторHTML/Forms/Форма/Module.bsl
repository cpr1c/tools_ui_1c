&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	РедакторJS=ТекстРедактораПоляРедактора("javascript");
	РедакторCSS=ТекстРедактораПоляРедактора("css");
	РедакторHTML=ТекстРедактораПоляРедактора("html");
	РедакторРезультирующегоHTML=ТекстРедактораПоляРедактора("html");

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьРезультирующийHTML(Команда)
	Если Элементы.ГруппаСтраницыРедактированияHTML.ТекущаяСтраница
		= Элементы.ГруппаСтраницаРежимаРедактированияВсеСразу Тогда

		HTML=
		"<!DOCTYPE html>
		|<html lang=""ru"">
		|<head>
		|<title>Результирующий HTML</title>";

		Для Каждого СтрокаБиблиотеки Из ПодключаемыеБиблиотеки Цикл
			Файл=Новый Файл(СтрокаБиблиотеки.Путь);
			Если НРег(Файл.Расширение) = ".css" Тогда
				HTML=HTML + "
							|<link rel=""stylesheet"" href=""" + СтрокаБиблиотеки.Путь + """"
					+ СтрокаБиблиотеки.ДополнительныеПараметры + " >";
			Иначе
				HTML=HTML + "
							|<script src=""" + СтрокаБиблиотеки.Путь + """ type=""text/javascript"" charset=""utf-8"""
					+ СтрокаБиблиотеки.ДополнительныеПараметры + "></script>";
			КонецЕсли;
		КонецЦикла;

		ТекстCSS=ТекстРедактораЭлемента(Элементы.РедакторCSS);
		Если ЗначениеЗаполнено(ТекстCSS) Тогда
			HTML=HTML + "
						|<style type=""text/css"">
						|" + ТекстCSS + "
										|</style>";
		КонецЕсли;
		HTML=HTML + "
					|</head>
					|<body>";
		ТекстHTML=ТекстРедактораЭлемента(Элементы.РедакторHTML);
		Если ЗначениеЗаполнено(ТекстHTML) Тогда
			HTML=HTML + "
						| " + ТекстHTML;
		КонецЕсли;

		ТекстJS=ТекстРедактораЭлемента(Элементы.РедакторJS);
		Если ЗначениеЗаполнено(ТекстJS) Тогда
			HTML=HTML + "
						|<script>
						| " + ТекстJS + "
										|</script>";
		КонецЕсли;
		HTML=HTML + "
					|</body>
					|</html>";

		РезультирущийHTML=HTML;
		УстановитьТекстРедактораЭлемента(Элементы.РедакторРезультирующегоHTML, РезультирущийHTML);
	Иначе
		РезультирущийHTML=ТекстРедактораЭлемента(Элементы.РедакторРезультирующегоHTML);	
	КонецЕсли;

КонецПроцедуры
&НаСервере
Функция ТекстРедактораПоляРедактора(Язык)
	Текст=
	"<!DOCTYPE html>
	|<html lang=""ru"">
	|<head>
	|<title>ACE in Action</title>
	|<style type=""text/css"" media=""screen"">
	|    #editor { 
	|        position: absolute;
	|        top: 0;
	|        right: 0;
	|        bottom: 0;
	|        left: 0;
	|    }
	|</style>
	|</head>
	|<body>
	|
	|<div id=""editor""></div>
	|    
	|<script src=""https://cdnjs.cloudflare.com/ajax/libs/ace/1.4.11/ace.js"" type=""text/javascript"" charset=""utf-8""></script>
	|<script src=""https://cdnjs.cloudflare.com/ajax/libs/ace/1.4.11/ext-language_tools.js"" type=""text/javascript"" charset=""utf-8""></script>
	|<script>
	|
	|    // trigger extension
	|    ace.require(""ace/ext/language_tools"");
	|    var editor = ace.edit(""editor"");
	|    editor.session.setMode(""ace/mode/###ЯЗЫК###"");
	|    editor.setTheme(""ace/theme/eclipse"");
	|    // enable autocompletion and snippets
	|    editor.setOptions({
	|        selectionStyle: 'line',
	|        highlightSelectedWord: true,
	|        showLineNumbers: true,
	|        enableBasicAutocompletion: true,
	|        enableSnippets: true,
	|        enableLiveAutocompletion: true
	|    });
	|</script>
	|
	|</body>
	|</html>";
	Возврат СтрЗаменить(Текст, "###ЯЗЫК###", Язык);
КонецФункции

&НаКлиенте
Функция ТекстРедактораЭлемента(ЭлементПоляРедактора)
	ДокументHTML=ЭлементПоляРедактора.Документ;
	Если ДокументHTML.parentWindow = Неопределено Тогда
		СтруктураДокументаДОМ = ДокументHTML.defaultView;
	Иначе
		СтруктураДокументаДОМ = ДокументHTML.parentWindow;
	КонецЕсли;
	Возврат СокрЛП(СтруктураДокументаДОМ.editor.getValue());

КонецФункции

&НаКлиенте
Процедура УстановитьТекстРедактораЭлемента(ЭлементПоляРедактора, ТекстУстановки)
	ДокументHTML=ЭлементПоляРедактора.Документ;
	Если ДокументHTML.parentWindow = Неопределено Тогда
		СтруктураДокументаДОМ = ДокументHTML.defaultView;
	Иначе
		СтруктураДокументаДОМ = ДокументHTML.parentWindow;
	КонецЕсли;
	СтруктураДокументаДОМ.editor.setValue(ТекстУстановки, -1);

КонецПроцедуры