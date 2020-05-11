
#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение ИЛИ ТолстыйКлиентУправляемоеПриложение Тогда

Функция ТекстAceMode1C() Экспорт
	Возврат ПолучитьОбщийМакет("УИ_AceMode1c").ПолучитьТекст();
КонецФункции

Функция ТекстHTMLРедактораКода(Язык="bsl") Экспорт
	ТекЯзык=НРег(Язык);
	Если ТекЯзык="bsl" Тогда
		ТекстМода1С=ТекстAceMode1C();
		ТекЯзык="_1c";
	Иначе
		ТекстМода1С=Неопределено;
	КонецЕсли;
	ТекстHTML=
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
	|<script src=""http://ajaxorg.github.io/ace-builds/src-noconflict/ace.js"" type=""text/javascript"" charset=""utf-8""></script>
	|<script src=""http://ajaxorg.github.io/ace-builds/src-noconflict/ext-language_tools.js"" type=""text/javascript"" charset=""utf-8""></script>";
//	|<script src=""http://ajaxorg.github.io/ace-builds/src/ext-language_tools.js"" type=""text/javascript"" charset=""utf-8""></script>";
	Если ТекстМода1С<>Неопределено Тогда
		ТекстHTML=ТекстHTML+"
		|<script>
		| "+ТекстМода1С+"
		|</script>
		|<script>
		| "+ПолучитьОбщийМакет("УИ_AceThemeOnes").ПолучитьТекст()+"
		|</script>";
	КонецЕсли;
	ТекстHTML=ТекстHTML+"
	|<script>
	|    // trigger extension
	|    ace.require(""ace/ext/language_tools"");
	|    var editor = ace.edit(""editor"");
	|    editor.session.setMode(""ace/mode/"+ТекЯзык+""");
	|    editor.setTheme(""ace/theme/ones"");
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
	
	Возврат ТекстHTML;
КонецФункции

#КонецЕсли

#Если Клиент Тогда

Функция ТекстРедактораИзПоляРедактора(ЭлементПоляHTML) Экспорт
	ДокументHTML=ЭлементПоляHTML.Документ;
	Если ДокументHTML.parentWindow = Неопределено Тогда
		СтруктураДокументаДОМ = ДокументHTML.defaultView;
	Иначе
		СтруктураДокументаДОМ = ДокументHTML.parentWindow;
	КонецЕсли;
	Возврат СокрЛП(СтруктураДокументаДОМ.editor.getValue());

	
КонецФункции
	
Процедура УстановитьТекстРедактораЭлемента(ЭлементПоляРедактора, ТекстУстановки) Экспорт
	ДокументHTML=ЭлементПоляРедактора.Документ;
	Если ДокументHTML.parentWindow = Неопределено Тогда
		СтруктураДокументаДОМ = ДокументHTML.defaultView;
	Иначе
		СтруктураДокументаДОМ = ДокументHTML.parentWindow;
	КонецЕсли;
	СтруктураДокументаДОМ.editor.setValue(ТекстУстановки, -1);

КонецПроцедуры

	

#КонецЕсли