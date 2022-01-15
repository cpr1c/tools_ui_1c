
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	CopyFormData(Parameters.Object, Object);
	
	QueryResultAddress = Parameters.QueryResultAddress;
	ResultIndex = Parameters.ResultInBatch - 1;
	
	DataProcessor = FormAttributeToValue("Object");
	
	HeavyQueriesProportion = DataProcessor.SavedStates_Get("HeavyQueriesProportion", 30);
	ShowIn1CTerms = DataProcessor.SavedStates_Get("ShowIn1CTerms", True);
	
	PlanRead = GetQueryPlanFromLog();
																	 
EndProcedure

&AtServer
Function GetQueryPlanFromLog()
	
	DataProcessor = FormAttributeToValue("Object");
	
	stQueryResult = GetFromTempStorage(QueryResultAddress);
	arQueryResult = stQueryResult.Result;
	stResult = arQueryResult[ResultIndex];
	
	TLEventRow = DataProcessor.TechnologicalLog_GetInfoByQuery(stResult.QueryID, 
	                                                                 stResult.QueryStartTime, stResult.DurationInMilliseconds);
	LogEventText.SetText(TLEventRow);
	
	arEventTexts = New Array;
	arEvents = New Array;
	nRow = 1;
	While True Do
		
		stEvent = TechnologicalLog_FindEventByRows(LogEventText, nRow);
		
		If stEvent = Undefined Then
			Break;
		EndIf;
		
		nRow = stEvent.EndRow + 1;
	
		arEventText = New Array;
		For j = stEvent.BeginRow To stEvent.EndRow Do
			arEventText.Add(LogEventText.GetString(j));
		EndDo;
		
		EventText = StrConcat(arEventText, "
		                                              |");
		
		stEvent = TechnologicalLog_ParseEvent(EventText);
		
		DBMSQueryText = Undefined;
		If Not stEvent.Property("Sql", DBMSQueryText) Then
			Continue;
		EndIf;
		
		If DBMSQueryText = "COMMIT TRANSACTION" Then
			Continue;
		EndIf;
		
		If Not stEvent.Property("planSQLText") Then
			Continue;
		EndIf;
		
		arEventTexts.Add(EventText);
		arEvents.Add(stEvent);
		
	EndDo;
	
	If arEvents.Count() < 1 Then
		Return False;
	EndIf;
	
	PlanSplitter = "
		|=====================================================================================================================================
		|";
	
	For Each Event In arEvents Do
		
		TermsData = Undefined;
		AddQueryText(TermsData);
		
		If PlanText.RoowCount() > 0 Then
			PlanText.AddRow(PlanSplitter);
			Plan1CText.AddRow(PlanSplitter);
		EndIf;
		
		If Event.DBMS = "DBMSSQL" Then
			AddQueryPlan_DBMSSQL(TermsData);
		ElsIf Event.DBMS = "DBPOSTGRS" Then
			AddQueryPlan_DBPOSTGRS(TermsData);
		Else
			ErrorString = StrTemplate(NStr("ru = 'Получение плана запроса для СУБД ""%1"" не поддерживается.'; en = 'Getting query plan for ""%1"" DBMS is not available.'"), Event.DBMS);
			PlanText.SetText(ErrorString);
			Plan1CText.SetText(ErrorString);
		EndIf;
		
	EndDo;
	
	CalculateCostsAndExpensiveStrings ();

	Return True;

EndFunction

&НаКлиентеНаСервереБезКонтекста
Function УбратьКавычки(Строка, СимволКавычек = Undefined)
	
	If СимволКавычек = Undefined Then
		Return УбратьКавычки(УбратьКавычки(Строка, "'"), """");
	EndIf;
	
	If Лев(Строка, 1) = СимволКавычек Then
		Результат = Прав(Строка, СтрДлина(Строка) - 1);
	Else
		Результат = Строка;
	EndIf;
	
	If Прав(Результат, 1) = СимволКавычек Then
		Return Лев(Результат, СтрДлина(Результат) - 1);
	EndIf;
	
	Return Результат;
	
EndFunction


&НаСервереБезКонтекста
Function ДобавитьРазделительЗапросовIfНеПустой(Текст)
	
	If ПустаяСтрока(Текст) Then
		Return Текст;
	EndIf;
	
	Return Текст + ";
	|////////////////////////////////////////////////////////////////////////////////
	|";
	
EndFunction

&НаСервере
Procedure AddQueryText(ДанныеТерминов)
	Перем ТекстСвойства, ТекстПараметров;
	
	Обработка = FormAttributeToValue("Объект");
	
	If Событие.Свойство("Sql", ТекстСвойства) Then
		ТекстСвойства = УбратьКавычки(ТекстСвойства);
		QueryText = ДобавитьРазделительЗапросовIfНеПустой(QueryText) + ТекстСвойства;
		QueryTextIn1CTerms = ДобавитьРазделительЗапросовIfНеПустой(QueryTextIn1CTerms) + Обработка.SQLQueryTo1CTerms(ТекстСвойства, ДанныеТерминов);
	EndIf;
	
	If Событие.Свойство("Prm", ТекстПараметров) Then
		QueryParameters = ДобавитьРазделительЗапросовIfНеПустой(QueryParameters) + УбратьКавычки(ТекстПараметров);
		Элементы.QueryParametersPage.Видимость = True;
	Else
		Элементы.QueryParametersPage.Видимость = False;
	EndIf;
	
EndProcedure

&НаКлиентеНаСервереБезКонтекста
Function ПолучитьЧисло(Знач Значение)
	
	If ТипЗнч(Значение) = Тип("Строка") Then
		
		Значение = СокрЛП(Значение);
		ъ = СтрНайти(Значение, "E");
		If ъ > 0 Then
			Мантисса = Число(Лев(Значение, ъ - 1));
			Порядок = Число(Прав(Значение, СтрДлина(Значение) - ъ));
			Ч = Мантисса * Pow(10, Порядок);
		Else
			Ч = Число(Значение);
		EndIf;
		
	Else
		
		Ч  = Значение;
		
	EndIf;
	
	Return Ч;
	
EndFunction

&НаКлиентеНаСервереБезКонтекста
Function ФорматироватьЧисло(Ч, Точность, ДесятичныйРазделитель = ",")
	
	ДлинаРезультата = ?(Точность.Точность > 0, Точность.Длина + 1, Точность.Длина);
	
	If Ч = 0 Then
		ДлинаЦелойЧасти = 1;
	ElsIf Ч > 0 Then
		ДлинаЦелойЧасти = Цел(Log10(Ч)) + 1;
	Else
		ДлинаЦелойЧасти = Цел(Log10(-Ч)) + 1;
	EndIf;
	
	If ДлинаЦелойЧасти > Точность.Длина - Точность.Точность Then
		Return Лев("##############################", ДлинаРезультата);
	EndIf;
	
	ПредставлениеЧисла = Формат(Ч, СтрШаблон("ЧЦ=%1; ЧДЦ=%2; ЧН=; ЧГ=; ЧРД=%3", Точность.Длина, Точность.Точность, ДесятичныйРазделитель));
			
	Return Лев("                              ", ДлинаРезультата - СтрДлина(ПредставлениеЧисла)) + ПредставлениеЧисла;
	
EndFunction

&НаКлиентеНаСервереБезКонтекста
Function Точность_Инициализировать(Длина = 1, Точность = 0)
	Return New Структура("Длина, Точность", Длина, Точность);
EndFunction

&НаКлиентеНаСервереБезКонтекста
Procedure Точность_ДобавитьЗначение(Точность, Знач Ч)
	
	If Ч < 0 Then
		Ч = -Ч;
	EndIf;
	
	If Ч < 1 Then
		ДлинаЦелойЧасти = 1;
	Else
		ДлинаЦелойЧасти = Цел(Log10(Ч)) + 1;
	EndIf;
	
	Н = Ч;
	ДлинаДробнойЧасти = 15;
	Для й = 0 По ДлинаДробнойЧасти Do
		If Н = Цел(Н) Then
			ДлинаДробнойЧасти = й;
			Break;
		EndIf;
		Н = Н * 10;
	EndDo;
	
	ДлинаЦелойЧасти = Макс(ДлинаЦелойЧасти, Точность.Длина - Точность.Точность);
	ДлинаДробнойЧасти = Макс(ДлинаДробнойЧасти, Точность.Точность);
	
	Точность.Длина = ДлинаЦелойЧасти + ДлинаДробнойЧасти;
	Точность.Точность = ДлинаДробнойЧасти;
	
EndProcedure

&НаСервере
Procedure AddQueryPlan_DBMSSQL(ДанныеТерминов)
	
	Обработка = FormAttributeToValue("Объект");
	
	ТекстПлана = УбратьКавычки(Событие.planSQLText);
	
	ТекстПлан = New ТекстовыйДокумент;
	ТекстПлан.УстановитьТекст(ТекстПлана);
	
	If ShowIn1CTerms Then
		ТекстПланВТерминах1С = New ТекстовыйДокумент;
		ТекстПланВТерминах1С.УстановитьТекст(Обработка.SQLPlanTo1CTerms(ТекстПлана, ДанныеТерминов));
	EndIf;
	
	й = 1;
	Пока й <= ТекстПлан.КоличествоСтрок() Do
		
		If ЗначениеЗаполнено(ТекстПлан.ПолучитьСтроку(й)) Then
			й = й + 1;
		Else
			
			ТекстПлан.УдалитьСтроку(й);
			
			If ShowIn1CTerms Then
				ТекстПланВТерминах1С.УдалитьСтроку(й);
			EndIf;
			
		EndIf;
		
	EndDo;
	
	If ТекстПлан.КоличествоСтрок() < 1 Then
		Return;
	EndIf;
	
	Строка = ТекстПлан.ПолучитьСтроку(1);
	Ъ = СтрНайти(Строка, "|");
	СтрокаПоказателей = Лев(Строка, Ъ - 1);
	чКоличествоПоказателей = СтрЧислоВхождений(СтрокаПоказателей, ",");
	
	СтрокаУзла = "|--";
	чДлинаУзла = СтрДлина(СтрокаУзла);
	
	PlanText.ДобавитьСтроку("(rows, executes, estimate rows, estimate i/o, estimate cpu, avg. row size, totat subtree cost, estimate executions, |-- operators...)");
	PlanText.ДобавитьСтроку("");

	соРодители = New Соответствие;
	ПредыдущийУзел = Plan;
	
	Точность_Rows = Точность_Инициализировать();
	Точность_Executes = Точность_Инициализировать();
	Точность_Estimate_rows = Точность_Инициализировать();
	Точность_Estimate_IO = Точность_Инициализировать(4, 3);
	Точность_Estimate_CPU = Точность_Инициализировать(4, 3);
	Точность_Avg_row_size = Точность_Инициализировать();
	Точность_Totat_subtree_cost = Точность_Инициализировать(4, 3);
	Точность_Estimate_executions = Точность_Инициализировать();
	
	маПданТекст = New Array;
	
	чПредыдущийУровень = 0;
	Для й = 1 По ТекстПлан.КоличествоСтрок() Do
		
		Строка = ТекстПлан.ПолучитьСтроку(й);
		Ъ = СтрНайти(Строка, ",", , , чКоличествоПоказателей);
		СтрокаПоказателей = Лев(Строка, Ъ - 1);
		СтрокаОператоров = Прав(Строка, СтрДлина(Строка) - Ъ);
		
		маПоказатели = СтрРазделить(СтрокаПоказателей, ",");
		
		Ъ = СтрНайти(СтрокаОператоров, СтрокаУзла);
		СтрокаПропусков = Лев(СтрокаОператоров, Ъ - 1);
		стрОператоры = Прав(СтрокаОператоров, СтрДлина(СтрокаОператоров) - Ъ + 1 - чДлинаУзла);
		
		чУровень = СтрДлина(СтрокаПропусков);
		
		If чУровень > чПредыдущийУровень Then
			Родитель = ПредыдущийУзел;
			соРодители[чУровень] = Родитель;
		ElsIf чУровень < чПредыдущийУровень Then
			Родитель = соРодители[чУровень];
		EndIf;
		
		NewУзел = Родитель.ПолучитьЭлементы().Добавить();
		NewУзел.SourceOperator = стрОператоры;
		If ShowIn1CTerms Then
			СтрокаВТерминах1С = ТекстПланВТерминах1С.ПолучитьСтроку(й);
			Ъ = СтрНайти(СтрокаВТерминах1С, СтрокаУзла);
			NewУзел.Оператор = Прав(СтрокаВТерминах1С, СтрДлина(СтрокаВТерминах1С) - Ъ + 1 - чДлинаУзла);
		Else
			NewУзел.Оператор = стрОператоры;
		EndIf;
		
		Rows = ПолучитьЧисло(маПоказатели[0]);                                    	
		Executes = ПолучитьЧисло(маПоказатели[1]);
		Estimate_rows = ПолучитьЧисло(маПоказатели[2]);
		Estimate_IO = ПолучитьЧисло(маПоказатели[3]);
		Estimate_CPU = ПолучитьЧисло(маПоказатели[4]);
		Avg_row_size = ПолучитьЧисло(маПоказатели[5]);
		Totat_subtree_cost = ПолучитьЧисло(маПоказатели[6]);
		Estimate_executions = ПолучитьЧисло(маПоказатели[7]);
		
		Точность_ДобавитьЗначение(Точность_Rows, Rows);
		Точность_ДобавитьЗначение(Точность_Executes, Executes);
		Точность_ДобавитьЗначение(Точность_Estimate_rows, Estimate_rows);
		Точность_ДобавитьЗначение(Точность_Estimate_IO, Estimate_IO);
		Точность_ДобавитьЗначение(Точность_Estimate_CPU, Estimate_CPU);
		Точность_ДобавитьЗначение(Точность_Avg_row_size, Avg_row_size);
		Точность_ДобавитьЗначение(Точность_Totat_subtree_cost, Totat_subtree_cost);
		Точность_ДобавитьЗначение(Точность_Estimate_executions, Estimate_executions);
		
		ДанныеОператора = New Структура(
			"Rows, Executes, Estimate_rows, Estimate_IO, Estimate_CPU, Avg_row_size, Totat_subtree_cost, Estimate_executions, СтрокаОператоров",
			Rows,
			Executes,
			Estimate_rows,
			Estimate_IO,
			Estimate_CPU,
			Avg_row_size,
			Totat_subtree_cost,
			Estimate_executions,
			СтрокаОператоров);
					
					
		маПданТекст.Добавить(ДанныеОператора);
		
		NewУзел.NodeCost = Totat_subtree_cost; 
		NewУзел.RowCountPlan = Estimate_rows;
		NewУзел.RowCountFact = Rows; 
		NewУзел.CallsPlan = Estimate_executions;
		NewУзел.CallsFact = Executes;
		NewУзел.IOExpenses = Estimate_IO;
		NewУзел.CPUExpenses = Estimate_CPU;
		NewУзел.AverageRowSize = Avg_row_size;
		
		ПредыдущийУзел = NewУзел;
		чПредыдущийУровень = чУровень;
		
	EndDo;
	
	For Each стДанныеОператора Из маПданТекст Do       
		
		СтрокаТекстовогоПлана = СтрШаблон("%1, %2, %3, %4, %5, %6, %7, %8, %9",
			ФорматироватьЧисло(стДанныеОператора.Rows, Точность_Rows, "."),
			ФорматироватьЧисло(стДанныеОператора.Executes, Точность_Executes, "."),
			ФорматироватьЧисло(стДанныеОператора.Estimate_rows, Точность_Estimate_rows, "."),
			ФорматироватьЧисло(стДанныеОператора.Estimate_IO, Точность_Estimate_IO, "."),
			ФорматироватьЧисло(стДанныеОператора.Estimate_CPU, Точность_Estimate_CPU, "."),
			ФорматироватьЧисло(стДанныеОператора.Avg_row_size, Точность_Avg_row_size, "."),
			ФорматироватьЧисло(стДанныеОператора.Totat_subtree_cost, Точность_Totat_subtree_cost, "."),
			ФорматироватьЧисло(стДанныеОператора.Estimate_executions, Точность_Estimate_executions, "."),
			стДанныеОператора.СтрокаОператоров);
			
		PlanText.ДобавитьСтроку(СтрокаТекстовогоПлана);
		
	EndDo;
		
	Plan1CText.УстановитьТекст(Обработка.SQLPlanTo1CTerms(PlanText.ПолучитьТекст(), ДанныеТерминов));
	
	//CalculateCostsAndExpensiveStrings ();
	
EndProcedure

&НаСервере
Procedure AddQueryPlan_DBPOSTGRS(ДанныеТерминов)
	
	Обработка = FormAttributeToValue("Объект");
	
	ТекстПлана = УбратьКавычки(Событие.planSQLText);
	
	PlanText.УстановитьТекст(ТекстПлана);
	Plan1CText.УстановитьТекст(Обработка.SQLPlanTo1CTerms(ТекстПлана, ДанныеТерминов, 1));
	
EndProcedure

&НаСервере
Procedure CalculateCostsAndExpensiveStrings (Узел = Undefined, тзСтоимости = Undefined)
	
	If Узел = Undefined Then
		Узел = Plan;
		тзСтоимости = New ТаблицаЗначений;
		тзСтоимости.Колонки.Добавить("OperatorCost", New ОписаниеТипов("Число"));
		тзСтоимости.Колонки.Добавить("СтоимостьУзла", New ОписаниеТипов("Число"));
		тзСтоимости.Колонки.Добавить("Узел");
	EndIf;
	
	ОбщаяСтоимость = 0;
	For Each ПодчиненныйУзел Из Узел.ПолучитьЭлементы() Do
		
		CalculateCostsAndExpensiveStrings (ПодчиненныйУзел, тзСтоимости);
		
		ОбщаяСтоимость = ОбщаяСтоимость + ПодчиненныйУзел.NodeCost;
		
	EndDo;
	
	If ТипЗнч(Узел) = Тип("ДанныеФормыЭлементДерева") Then
		
		СтоимостьОператора = Узел.NodeCost - ОбщаяСтоимость;
		Узел.OperatorCost = ?(СтоимостьОператора < 0, 0, СтоимостьОператора);
		
		СтрокаСтоимости = тзСтоимости.Добавить();
		СтрокаСтоимости.Узел = Узел;
		СтрокаСтоимости.OperatorCost = Узел.OperatorCost;
		СтрокаСтоимости.СтоимостьУзла = Узел.NodeCost;
		
	Else
		
		If тзСтоимости.Количество() > 0 Then
			
			тзИтоги = тзСтоимости.Скопировать();
			тзИтоги.Свернуть(, "OperatorCost, СтоимостьУзла");
			чСтоимостьВсего = тзИтоги[0].OperatorCost;
			
			For Each Строка Из тзСтоимости Do
				Строка.Узел.OperatorCostPercent = СтрШаблон("%1%%", Формат(Строка.OperatorCost * 100 / чСтоимостьВсего, "ЧЦ=5; ЧДЦ=2; ЧН="));
				Строка.Узел.NodeCostPercent = СтрШаблон("%1%%", Формат(Строка.СтоимостьУзла * 100 / чСтоимостьВсего, "ЧЦ=5; ЧДЦ=2; ЧН="));
			EndDo;
			
			РасчитатьДорогиеСтроки(Plan);
			
		EndIf;
	
	EndIf;
	
EndProcedure

&НаСервере
Procedure РасчитатьДорогиеСтроки(Узел)
	
	тзСтоимости = New ТаблицаЗначений;
	тзСтоимости.Колонки.Добавить("Стоимость", New ОписаниеТипов("Число"));
	тзСтоимости.Колонки.Добавить("Узел");
	
	If ТипЗнч(Узел) = Тип("ДанныеФормыЭлементДерева") Then
		СтоимостьКорня = Узел.OperatorCost;
	Else
		СтоимостьКорня = 0;
	EndIf;
	
	СтоимостьСумма = СтоимостьКорня;
	For Each ПодчиненныйУзел Из Узел.ПолучитьЭлементы() Do
		СтрокаСтоимости = тзСтоимости.Добавить();
		СтрокаСтоимости.Узел = ПодчиненныйУзел;
		СтрокаСтоимости.Стоимость = ПодчиненныйУзел.СтоимостьУзла;
		СтоимостьСумма = СтоимостьСумма + СтрокаСтоимости.Стоимость;
	EndDo;
	
	тзСтоимости.Сортировать("Стоимость Убыв");
	Отобразить = СтоимостьСумма * HeavyQueriesProportion / 100 - СтоимостьКорня;
	
	For Each Строка Из тзСтоимости Do
		If Отобразить <= 0 Then
			Break;
		EndIf;
		Строка.Узел.Selected = True;
		РасчитатьДорогиеСтроки(Строка.Узел);
		Отобразить = Отобразить - Строка.Стоимость;                          	
	EndDo;
	
EndProcedure

&НаСервере
Function TechnologicalLog_FindEventByRows(СобытиеЖурнала, чНачальнаяСтрокаПоиска = 1)
	
	Обработка = FormAttributeToValue("Объект");
	
	ШаблонСтрокиНачалаСобытия = Обработка.RegTemplate_GetTemplateObject("\d\d:\d\d.\d+-\d+,.*");
	
	чНачальнаяСтрока = Undefined;
	Для й = чНачальнаяСтрокаПоиска По СобытиеЖурнала.КоличествоСтрок() Do
		Строка = СобытиеЖурнала.ПолучитьСтроку(й);
		If Обработка.RegTemplate_Match(Строка, ШаблонСтрокиНачалаСобытия) Then
			If ЗначениеЗаполнено(чНачальнаяСтрока) Then
				чКонечнаяСтрока = й - 1;
				Break;
			Else
				чНачальнаяСтрока = й;
				чКонечнаяСтрока = СобытиеЖурнала.КОличествоСтрок();
			EndIf;
		EndIf;
	EndDo;
	
	If чНачальнаяСтрока = Undefined Then
		Return Undefined;
	EndIf;
	
	//маСвойства = СтрРазделить(Строка, ",");
	
	Return New Структура("НачальнаяСтрока, КонечнаяСтрока", чНачальнаяСтрока, чКонечнаяСтрока);
	
EndFunction

&НаСервере
Function TechnologicalLog_ParseEvent(Знач СтрокаТехнологическогоЖурнала)
	
	стСобытие = New Структура;
	
	стСобытияСложноеЗначение = New Структура("Sql, Prm, planSQLText, Context", "Prm, Rows, Context, planSQLText", "RowsAffected, planSQLText", "Context, RowsAffected");
	For Each кз Из стСобытияСложноеЗначение Do
		
		СтрокаПоиска = "," + кз.Ключ + "=";
		чНачальнаяПозиция = СтрНайти(СтрокаТехнологическогоЖурнала, СтрокаПоиска);
		
		If чНачальнаяПозиция = 0 Then
			Continue;
		EndIf;
		
		чНачальнаяПозицияЗначения = чНачальнаяПозиция + СтрДлина(СтрокаПоиска);
		
		If кз.Значение <> Undefined Then
			
			чКонечнаяПозиция = 0;
			маСледИмена = СтрРазделить(кз.Значение, ",");
			For Each СледующееИмя Из маСледИмена Do
				ч = СтрНайти(СтрокаТехнологическогоЖурнала, "," + СокрЛП(СледующееИмя) + "=", , чНачальнаяПозицияЗначения);
				If ч > 0 И (чКонечнаяПозиция = 0 ИЛИ чКонечнаяПозиция > ч) Then
					чКонечнаяПозиция = ч;
				EndIf;
			EndDo;
			
		Else
			чКонечнаяПозиция = 0;
		EndIf;
		
		If чКонечнаяПозиция = 0 Then
			чКонечнаяПозиция = СтрДлина(СтрокаТехнологическогоЖурнала);
		EndIf;
		
		стСобытие.Вставить(кз.Ключ, Сред(СтрокаТехнологическогоЖурнала, чНачальнаяПозицияЗначения, чКонечнаяПозиция - чНачальнаяПозицияЗначения));
		
		СтрокаТехнологическогоЖурнала = Лев(СтрокаТехнологическогоЖурнала, чНачальнаяПозиция) + Прав(СтрокаТехнологическогоЖурнала, СтрДлина(СтрокаТехнологическогоЖурнала) - чКонечнаяПозиция);
		
	EndDo;
	
	маСвойства = СтрРазделить(СтрокаТехнологическогоЖурнала, ",");
	
	СтрокаВремяДлительность = маСвойства[0];
	
	чПозицияМинус = СтрНайти(СтрокаВремяДлительность, "-");
	стСобытие.Вставить("Длительность", Прав(СтрокаВремяДлительность, СтрДлина(СтрокаВремяДлительность) - чПозицияМинус));
	
	СтрокаВремя = Лев(СтрокаВремяДлительность, чПозицияМинус - 1);
	стСобытие.Вставить("Время", СтрокаВремя);
	
	стСобытие.Вставить("Событие", маСвойства[1]);
	стСобытие.Вставить("УровеньСобытия", Число(маСвойства[2]));
	
	Для й = 3 По маСвойства.ВГраница() Do
		
		СтрокаСвойства = маСвойства[й];
		чПозицияРавно = СтрНайти(СтрокаСвойства, "=");
		
		If чПозицияРавно = 0 Then
			Continue;
		EndIf;
		
		ИмяСвойства = СтрЗаменить(Лев(СтрокаСвойства, чПозицияРавно - 1), ":", "_");
		стСобытие.Вставить(ИмяСвойства, Прав(СтрокаСвойства, СтрДлина(СтрокаСвойства) - чПозицияРавно));
		
	EndDo;
	
	Return стСобытие;
	
EndFunction

&НаКлиенте
Procedure PlanOnActivateRow(Элемент)
	If Элементы.Plan.ТекущиеДанные <> Undefined Then
		CurrentOperator = Элементы.Plan.ТекущиеДанные.Оператор;
	EndIf;
EndProcedure

&НаКлиенте
Procedure OnOpen(Отказ)
	If НЕ PlanRead Then
		//Попробуем еще раз через секунду. If пользователь очень шустрый, событие могло не успеть попасть в журнал.
		ПодключитьОбработчикОжидания("ОтложенноеЧтениеЖурнала", 1, True);
	EndIf;
EndProcedure

&НаКлиенте
Procedure ОтложенноеЧтениеЖурнала()
	
	ОбновитьПлан();
	
	If НЕ PlanRead Then
		Оповещение = New ОписаниеОповещения("ЗакрытиеПослеПредупреждения", ЭтаФорма);
		ПоказатьПредупреждение(Оповещение, "Не удалось получить информацию о запросе", , Объект.Title);
	EndIf;
	
EndProcedure

&НаКлиенте
Procedure ЗакрытиеПослеПредупреждения(ДополнительныеПараметры) Экспорт
	Закрыть();
EndProcedure

&НаКлиенте
Procedure OnClose(ЗавершениеРаботы)
	ВладелецФормы.SavedStates_Save("HeavyQueriesProportion", HeavyQueriesProportion);
	ВладелецФормы.SavedStates_Save("ShowIn1CTerms", ShowIn1CTerms);
EndProcedure

&НаКлиенте
Procedure ОбновитьПлан()
	
	PlanText.Очистить();
	Plan.ПолучитьЭлементы().Очистить();
	
	PlanRead = GetQueryPlanFromLog();
	
EndProcedure

&НаКлиенте
Procedure Refresh_Command(Команда)
	
	соСостояние = ПолучитьСостояниеДерева();
	
	ОбновитьПлан();
	
	If НЕ PlanRead Then
		ПоказатьПредупреждение(, "Не удалось получить информацию о запросе", , Объект.Title);
	Else
		РазвернутьПоСостояниюДерево(соСостояние);
	EndIf;
	                     
EndProcedure

&НаКлиенте
Procedure ExpandAll_Command(Команда)
	For Each ЭлементДерева Из Plan.ПолучитьЭлементы() Do
		Элементы.Plan.Развернуть(ЭлементДерева.ПолучитьИдентификатор(), True);
	EndDo;
EndProcedure

&НаКлиенте
Procedure CollapseAll_Command(Команда)
	For Each ЭлементДерева Из Plan.ПолучитьЭлементы() Do
		Элементы.Plan.Свернуть(ЭлементДерева.ПолучитьИдентификатор());
	EndDo;
EndProcedure

&НаКлиенте
Procedure РазвернутьПоСостояниюДерево(соСостояние, Путь = "", Узел = Undefined)
	
	If Узел = Undefined Then
		Узел = Plan;
	EndIf;
	
	For Each ЭлементДерева Из Узел.ПолучитьЭлементы() Do
		
		ПутьУзла = Путь + "/" + ЭлементДерева.SourceOperator;
		РазвернутьПоСостояниюДерево(соСостояние, ПутьУзла, ЭлементДерева);		
		
		Развернут = соСостояние[ПутьУзла];
		
		If Развернут <> Undefined Then
			If Развернут Then
				Элементы.Plan.Развернуть(ЭлементДерева.ПолучитьИдентификатор(), False);
			Else
				Элементы.Plan.Свернуть(ЭлементДерева.ПолучитьИдентификатор());
			EndIf;
		EndIf;
		
	EndDo;
	
EndProcedure

&НаКлиенте
Function ПолучитьСостояниеДерева(Путь = "", Узел = Undefined, соСостояние = Undefined)
	
	If Узел = Undefined Then
		Узел = Plan;
	EndIf;
	
	If соСостояние = Undefined Then
		соСостояние = New Соответствие;
	EndIf;
	
	For Each ЭлементДерева Из Узел.ПолучитьЭлементы() Do
		ПутьУзла = Путь + "/" + ЭлементДерева.SourceOperator;
		соСостояние[ПутьУзла] = Элементы.Plan.Развернут(ЭлементДерева.ПолучитьИдентификатор());
		соСостояние = ПолучитьСостояниеДерева(ПутьУзла, ЭлементДерева, соСостояние);
	EndDo;
	
	Return соСостояние;
	
EndFunction


