
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
		
		If PlanAsText.RoowCount() > 0 Then
			PlanAsText.AddRow(PlanSplitter);
			Plan1CText.AddRow(PlanSplitter);
		EndIf;
		
		If Event.DBMS = "DBMSSQL" Then
			AddQueryPlan_DBMSSQL(TermsData);
		ElsIf Event.DBMS = "DBPOSTGRS" Then
			AddQueryPlan_DBPOSTGRS(TermsData);
		Else
			ErrorString = StrTemplate(NStr("ru = 'Получение плана запроса для СУБД ""%1"" не поддерживается.'; en = 'Getting query plan for ""%1"" DBMS is not available.'"), Event.DBMS);
			PlanAsText.SetText(ErrorString);
			Plan1CText.SetText(ErrorString);
		EndIf;
		
	EndDo;
	
	CalculateCostsAndExpensiveStrings ();

	Return True;

EndFunction

&AtClientAtServerNoContext
Function RemoveQuotes(Row, QuoteChar = Undefined)
	
	If QuoteChar = Undefined Then
		Return RemoveQuotes(RemoveQuotes(Row, "'"), """");
	EndIf;
	
	If Left(Row, 1) = QuoteChar Then
		Result = Right(Row, StrLen(Row) - 1);
	Else
		Result = Row;
	EndIf;
	
	If Right(Result, 1) = QuoteChar Then
		Return Left(Result, StrLen(Result) - 1);
	EndIf;
	
	Return Result;
	
EndFunction


&AtServerNoContext
Function AddQuerySplitterIfNotEmpty(Text)
	
	If IsBlankString(Text) Then
		Return Text;
	EndIf;
	
	Return Text + ";
	|////////////////////////////////////////////////////////////////////////////////
	|";
	
EndFunction

&AtServer
Procedure AddQueryText(TermsData)
	Var PropertyText, ParametersText;
	
	DataProcessor = FormAttributeToValue("Object");
	
	If Event.Property("Sql", PropertyText) Then
		PropertyText = RemoveQuotes(PropertyText);
		QueryText = AddQuerySplitterIfNotEmpty(QueryText) + PropertyText;
		QueryTextIn1CTerms = AddQuerySplitterIfNotEmpty(QueryTextIn1CTerms) + DataProcessor.SQLQueryTo1CTerms(PropertyText, TermsData);
	EndIf;
	
	If Event.Property("Prm", ParametersText) Then
		QueryParameters = AddQuerySplitterIfNotEmpty(QueryParameters) + RemoveQuotes(ParametersText);
		Items.QueryParametersPage.Visible = True;
	Else
		Items.QueryParametersPage.Visible = False;
	EndIf;
	
EndProcedure

&AtClientAtServerNoContext
Function GetNumber(Val Value)
	
	If TypeOf(Value) = Type("String") Then
		
		Value = TrimAll(Value);
		j = StrFind(Value, "E");
		If j > 0 Then
			Significand = Number(Left(Value, j - 1));
			Exponent = Number(Right(Value, StrLen(Value) - j));
			N = Significand * Pow(10, Exponent);
		Else
			N = Number(Value);
		EndIf;
		
	Else
		
		N  = Value;
		
	EndIf;
	
	Return N;
	
EndFunction

&AtClientAtServerNoContext
Function FormatNumber(N, Precision, DecimalSeparator = ",")
	
	ResultLength = ?(Precision.Precision > 0, Precision.Length + 1, Precision.Length);
	
	If N = 0 Then
		IntegerPartLength = 1;
	ElsIf N > 0 Then
		IntegerPartLength = Int(Log10(N)) + 1;
	Else
		IntegerPartLength = Int(Log10(-N)) + 1;
	EndIf;
	
	If IntegerPartLength > Precision.Length - Precision.PrecisionPrecision Then
		Return Left("##############################", ResultLength);
	EndIf;
	
	NumberPresentation = Format(N, StrTemplate("ND=%1; NFD=%2; NZ=; NG=; NDS=%3", Precision.Length, Precision.Precision, DecimalSeparator));
			
	Return Left("                              ", ResultLength - StrLen(NumberPresentation)) + NumberPresentation;
	
EndFunction

&AtClientAtServerNoContext
Function Precision_Initialize(Length = 1, Precision = 0)
	Return New Structure("Length, Precision", Length, Precision);
EndFunction

&AtClientAtServerNoContext
Procedure Precision_AddValue(Precision, Val N)
	
	If N < 0 Then
		N = -N;
	EndIf;
	
	If N < 1 Then
		IntegerPartLength = 1;
	Else
		IntegerPartLength = Int(Log10(N)) + 1;
	EndIf;
	
	NN = N;
	FractionalPartLength = 15;
	For j = 0 To FractionalPartLength Do
		If NN = Int(NN) Then
			FractionalPartLength = j;
			Break;
		EndIf;
		NN = NN * 10;
	EndDo;
	
	IntegerPartLength = Max(IntegerPartLength, Precision.Length - Precision.Precision);
	FractionalPartLength = Max(FractionalPartLength, Precision.Precision);
	
	Precision.Length = IntegerPartLength + FractionalPartLength;
	Precision.Precision = FractionalPartLength;
	
EndProcedure

&AtServer
Procedure AddQueryPlan_DBMSSQL(TermsData)
	
	DataProcessor = FormAttributeToValue("Object");
	
	PlanText = RemoveQuotes(Event.planSQLText);
	
	PlanTextDoc = New TextDocument;
	PlanTextDoc.SetText(PlanText);
	
	If ShowIn1CTerms Then
		PlanTextDocIn1CTerms = New TextDocument;
		PlanTextDocIn1CTerms.SetText(DataProcessor.SQLPlanTo1CTerms(PlanAsText, TermsData));
	EndIf;
	
	j = 1;
	While j <= PlanTextDoc.LineCount() Do
		
		If ValueIsFilled(PlanTextDoc.GetLine(j)) Then
			j = j + 1;
		Else
			
			PlanTextDoc.DeleteLine(j);
			
			If ShowIn1CTerms Then
				PlanTextDocIn1CTerms.DeleteLine(j);
			EndIf;
			
		EndIf;
		
	EndDo;
	
	If PlanTextDoc.LineCount() < 1 Then
		Return;
	EndIf;
	
	Line = PlanTextDoc.GetLine(1);
	j = StrFind(Line, "|");
	IndicatorsString = Left(Line, j - 1);
	nIndicatorCount = StrOccurrenceCount(IndicatorsString, ",");
	
	NodeString = "|--";
	nNodeLength = StrLen(NodeString);
	
	PlanAsText.AddLine("(rows, executes, estimate rows, estimate i/o, estimate cpu, avg. row size, totat subtree cost, estimate executions, |-- operators...)'");
	PlanAsText.AddLine("");

	mapParents = New Map;
	PreviousNode = Plan;
	
	Precision_Rows = Precision_Initialize();
	Precision_Executes = Precision_Initialize();
	Precision_Estimate_rows = Precision_Initialize();
	Precision_Estimate_IO = Precision_Initialize(4, 3);
	Precision_Estimate_CPU = Precision_Initialize(4, 3);
	Precision_Avg_row_size = Precision_Initialize();
	Precision_Totat_subtree_cost = Precision_Initialize(4, 3);
	Precision_Estimate_executions = Precision_Initialize();
	
	arPlanText = New Array;
	
	nPreviousLevel = 0;
	For j = 1 To PlanTextDoc.LineCount() Do
		
		Line = PlanTextDoc.GetLine(j);
		X = StrFind(Line, ",", , , nIndicatorCount);
		IndicatorsString = Left(Line, X - 1);
		OperatorsString = Right(Line, StrLen(Line) - X);
		
		arIndicators = StrSplit(IndicatorsString, ",");
		
		X = StrFind(OperatorsString, NodeString);
		GapsString = Left(OperatorsString, X - 1);
		strOperators = Right(OperatorsString, StrLen(OperatorsString) - X + 1 - nNodeLength);
		
		nLevel = StrLen(GapsString);
		
		If nLevel > nPreviousLevel Then
			Parent = PreviousNode;
			mapParents[nLevel] = Parent;
		ElsIf nLevel < nPreviousLevel Then
			Parent = mapParents[nLevel];
		EndIf;
		
		NewNode = Parent.GetItems().Add();
		NewNode.SourceOperator = strOperators;
		If ShowIn1CTerms Then
			LineIn1CTerms = PlanTextDocIn1CTerms.GetLine(j);
			X = StrFind(LineIn1CTerms, NodeString);
			NewNode.Operator = Right(LineIn1CTerms, StrLen(LineIn1CTerms) - X + 1 - nNodeLength);
		Else
			NewNode.Operator = strOperators;
		EndIf;
		
		Rows = GetNumber(arIndicators[0]);                                    	
		Executes = GetNumber(arIndicators[1]);
		Estimate_rows = GetNumber(arIndicators[2]);
		Estimate_IO = GetNumber(arIndicators[3]);
		Estimate_CPU = GetNumber(arIndicators[4]);
		Avg_row_size = GetNumber(arIndicators[5]);
		Totat_subtree_cost = GetNumber(arIndicators[6]);
		Estimate_executions = GetNumber(arIndicators[7]);
		
		Precision_AddValue(Precision_Rows, Rows);
		Precision_AddValue(Precision_Executes, Executes);
		Precision_AddValue(Precision_Estimate_rows, Estimate_rows);
		Precision_AddValue(Precision_Estimate_IO, Estimate_IO);
		Precision_AddValue(Precision_Estimate_CPU, Estimate_CPU);
		Precision_AddValue(Precision_Avg_row_size, Avg_row_size);
		Precision_AddValue(Precision_Totat_subtree_cost, Totat_subtree_cost);
		Precision_AddValue(Precision_Estimate_executions, Estimate_executions);
		
		OperatorData = New Structure(
			"Rows, Executes, Estimate_rows, Estimate_IO, Estimate_CPU, Avg_row_size, Totat_subtree_cost, Estimate_executions, OperatorsString",
			Rows,
			Executes,
			Estimate_rows,
			Estimate_IO,
			Estimate_CPU,
			Avg_row_size,
			Totat_subtree_cost,
			Estimate_executions,
			OperatorsString);
					
					
		arPlanText.Add(OperatorData);
		
		NewNode.NodeCost = Totat_subtree_cost; 
		NewNode.RowCountPlan = Estimate_rows;
		NewNode.RowCountFact = Rows; 
		NewNode.CallsPlan = Estimate_executions;
		NewNode.CallsFact = Executes;
		NewNode.IOExpenses = Estimate_IO;
		NewNode.CPUExpenses = Estimate_CPU;
		NewNode.AverageRowSize = Avg_row_size;
		
		PreviousNode = NewNode;
		nPreviousLevel = nLevel;
		
	EndDo;
	
	For Each stOperatorData In arPlanText Do       
		
		TextPlanString = StrTemplate("%1, %2, %3, %4, %5, %6, %7, %8, %9",
			FormatNumber(stOperatorData.Rows, Precision_Rows, "."),
			FormatNumber(stOperatorData.Executes, Precision_Executes, "."),
			FormatNumber(stOperatorData.Estimate_rows, Precision_Estimate_rows, "."),
			FormatNumber(stOperatorData.Estimate_IO, Precision_Estimate_IO, "."),
			FormatNumber(stOperatorData.Estimate_CPU, Precision_Estimate_CPU, "."),
			FormatNumber(stOperatorData.Avg_row_size, Precision_Avg_row_size, "."),
			FormatNumber(stOperatorData.Totat_subtree_cost, Precision_Totat_subtree_cost, "."),
			FormatNumber(stOperatorData.Estimate_executions, Precision_Estimate_executions, "."),
			stOperatorData.OperatorsString);
			
		PlanAsText.AddLine(TextPlanString);
		
	EndDo;
		
	Plan1CText.SetText(DataProcessor.SQLPlanTo1CTerms(PlanAsText.GetText(), TermsData));
	
	//CalculateCostsAndExpensiveStrings ();
	
EndProcedure

&AtServer
Procedure AddQueryPlan_DBPOSTGRS(TermsData)
	
	DataProcessor = FormAttributeToValue("Object");
	
	PlanText = RemoveQuotes(Event.planSQLText);
	
	PlanText.SetText(PlanText);
	Plan1CText.SetText(DataProcessor.SQLPlanTo1CTerms(PlanText, TermsData, 1));
	
EndProcedure

&AtServer
Procedure CalculateCostsAndExpensiveStrings (Node = Undefined, vtCosts = Undefined)
	
	If Node = Undefined Then
		Node = Plan;
		vtCosts = New ValueTable;
		vtCosts.Columns.Add("OperatorCost", New TypeDescription("Number"));
		vtCosts.Columns.Add("NodeCost", New TypeDescription("Number"));
		vtCosts.Columns.Add("Node");
	EndIf;
	
	TotalCost = 0;
	For Each ChildNode In Node.GetItems() Do
		
		CalculateCostsAndExpensiveStrings (ChildNode, vtCosts);
		
		TotalCost = TotalCost + ChildNode.NodeCost;
		
	EndDo;
	
	If TypeOf(Node) = Type("FormDataTreeItem") Then
		
		OperatorCost = Node.NodeCost - TotalCost;
		Node.OperatorCost = ?(OperatorCost < 0, 0, OperatorCost);
		
		CostRow = vtCosts.Add();
		CostRow.Node = Node;
		CostRow.OperatorCost = Node.OperatorCost;
		CostRow.NodeCost = Node.NodeCost;
		
	Else
		
		If vtCosts.Count() > 0 Then
			
			vtTotals = vtCosts.Copy();
			vtTotals.GroupBy(, "OperatorCost, NodeCost");
			nCountTotal = vtTotals[0].OperatorCost;
			
			For Each Row Из vtCosts Do
				Row.Node.OperatorCostPercent = StrTemplate("%1%%", Format(Row.OperatorCost * 100 / nCountTotal, "ND=5; NFD=2; NZ="));
				Row.Node.NodeCostPercent = StrTemplate("%1%%", Format(Row.NodeCost * 100 / nCountTotal, "ND=5; NFD=2; NZ="));
			EndDo;
			
			CalculateExpensiveRows(Plan);
			
		EndIf;
	
	EndIf;
	
EndProcedure

&AtServer
Procedure CalculateExpensiveRows(Node)
	
	vtCosts = New ValueTable;
	vtCosts.Columns.Add("Cost", New TypeDescription("Number"));
	vtCosts.Columns.Add("Node");
	
	If TypeOf(Node) = Type("FormDataTreeItem") Then
		RootCost = Node.OperatorCost;
	Else
		RootCost = 0;
	EndIf;
	
	CostSum = RootCost;
	For Each ChildNode In Node.GetItems() Do
		CostRow = vtCosts.Add();
		CostRow.Node = ChildNode;
		CostRow.Cost = ChildNode.NodeCost;
		CostSum = CostSum + CostRow.Cost;
	EndDo;
	
	vtCosts.Sort("Cost Desc");
	CostToDisplay = CostSum * HeavyQueriesProportion / 100 - RootCost;
	
	For Each Row In vtCosts Do
		If CostToDisplay <= 0 Then
			Break;
		EndIf;
		Row.Node.Selected = True;
		CalculateExpensiveRows(Row.Node);
		CostToDisplay = CostToDisplay - Row.Cost;                          	
	EndDo;
	
EndProcedure

&AtServer
Function TechnologicalLog_FindEventByRows(LogEvent, nSearchBeginLine = 1)
	
	DataProcessor = FormAttributeToValue("Object");
	
	EventBeginLineTemplate = DataProcessor.RegTemplate_GetTemplateObject("\d\d:\d\d.\d+-\d+,.*");
	
	nBeginLine = Undefined;
	For j = nSearchBeginLine To LogEvent.LineCount() Do
		Line = LogEvent.GetLine(j);
		If DataProcessor.RegTemplate_Match(Line, EventBeginLineTemplate) Then
			If ValueIsFilled(nBeginLine) Then
				nEndLine = j - 1;
				Break;
			Else
				nBeginRow = j;
				nEndLine = LogEvent.LineCount();
			EndIf;
		EndIf;
	EndDo;
	
	If nBeginRow = Undefined Then
		Return Undefined;
	EndIf;
	
	//arProperties = StrSplit(Line, ",");
	
	Return New Structure("BeginLine, EndLine", nBeginLine, nEndLine);
	
EndFunction

&AtServer
Function TechnologicalLog_ParseEvent(Val TechLogString)
	
	stEvent = New Structure;
	
	stEventsComplexValue = New Structure("Sql, Prm, planSQLText, Context", "Prm, Rows, Context, planSQLText", "RowsAffected, planSQLText", "Context, RowsAffected");
	For Each kv In stEventsComplexValue Do
		
		SearchString = "," + kv.Key + "=";
		nStartIndex = StrFind(TechLogString, SearchString);
		
		If nStartIndex = 0 Then
			Continue;
		EndIf;
		
		nValueStartIndex = nStartIndex + StrLen(SearchString);
		
		If kv.Value <> Undefined Then
			
			nEndIndex = 0;
			arNextNames = StrSplit(kv.Value, ",");
			For Each NextName In arNextNames Do
				n = StrFind(TechLogString, "," + TrimAll(NextName) + "=", , nValueStartIndex);
				If n > 0 And (nEndIndex = 0 Or nEndIndex > n) Then
					nEndIndex = n;
				EndIf;
			EndDo;
			
		Else
			nEndIndex = 0;
		EndIf;
		
		If nEndIndex = 0 Then
			nEndIndex = StrLen(TechLogString);
		EndIf;
		
		stEvent.Insert(kv.Key, Mid(TechLogString, nValueStartIndex, nEndIndex - nValueStartIndex));
		
		TechLogString = Left(TechLogString, nStartIndex) + Right(TechLogString, StrLen(TechLogString) - nEndIndex);
		
	EndDo;
	
	arProperties = StrSplit(TechLogString, ",");
	
	DurationString = arProperties[0];
	
	nMinusIndex = StrFind(DurationString, "-");
	stEvent.Insert("Duration", Right(DurationString, StrLen(DurationString) - nMinusIndex));
	
	TimeString = Left(DurationString, nMinusIndex - 1);
	stEvent.Insert("Time", TimeString);
	
	stEvent.Insert("Event", arProperties[1]);
	stEvent.Insert("EventLevel", Number(arProperties[2]));
	
	For j = 3 To arProperties.UBound() Do
		
		PropertyString = arProperties[j];
		nEqualIndex = StrFind(PropertyString, "=");
		
		If nEqualIndex = 0 Then
			Continue;
		EndIf;
		
		PropertyName = StrReplace(Left(PropertyString, nEqualIndex - 1), ":", "_");
		stEvent.Insert(PropertyName, Right(PropertyString, StrLen(PropertyString) - nEqualIndex));
		
	EndDo;
	
	Return stEvent;
	
EndFunction

&AtClient
Procedure PlanOnActivateRow(Item)
	If Items.Plan.CurrentData <> Undefined Then
		CurrentOperator = Items.Plan.CurrentData.Operator;
	EndIf;
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	If Not PlanRead Then
		//Trying again in 1 second. Event might not have been recorded to log yet.
		AttachIdleHandler("DeferredLogRead", 1, True);
	EndIf;
EndProcedure

&AtClient
Procedure DeferredLogRead()
	
	RefreshPlan();
	
	If Not PlanRead Then
		Notification = New NotifyDescription("CloseAfterMessage", ThisForm);
		ShowMessageBox(Notification, NStr("ru = 'Не удалось получить информацию о запросе'; en = 'Cannot get query information'"), , Object.Title);
	EndIf;
	
EndProcedure

&AtClient
Procedure CloseAfterMessage(AdditionalParameters) Export
	Close();
EndProcedure

&AtClient
Procedure OnClose(Exit)
	FormOwner.SavedStates_Save("HeavyQueriesProportion", HeavyQueriesProportion);
	FormOwner.SavedStates_Save("ShowIn1CTerms", ShowIn1CTerms);
EndProcedure

&AtClient
Procedure RefreshPlan()
	
	PlanAsText.Clear();
	Plan.GetItems().Clear();
	
	PlanRead = GetQueryPlanFromLog();
	
EndProcedure

&AtClient
Procedure Refresh_Command(Command)
	
	mapState = GetTreeState();
	
	RefreshPlan();
	
	If Not PlanRead Then
		ShowMessageBox(, NStr("ru = 'Не удалось получить информацию о запросе'; en = 'Cannot get query information'"), , Object.Title);
	Else
		ExpandTreeByState(mapState);
	EndIf;
	                     
EndProcedure

&AtClient
Procedure ExpandAll_Command(Command)
	For Each TreeItem In Plan.GetItems() Do
		Items.Plan.Expand(TreeItem.GetID(), True);
	EndDo;
EndProcedure

&AtClient
Procedure CollapseAll_Command(Command)
	For Each TreeItem In Plan.GetItems() Do
		Items.Plan.Collapse(TreeItem.GetID());
	EndDo;
EndProcedure

&AtClient
Procedure ExpandTreeByState(mapState, Path = "", Node = Undefined)
	
	If Node = Undefined Then
		Node = Plan;
	EndIf;
	
	For Each TreeItem In Node.GetItems() Do
		
		NodePath = Path + "/" + TreeItem.SourceOperator;
		ExpandTreeByState(mapState, NodePath, TreeItem);		
		
		Expanded = mapState[NodePath];
		
		If Expanded <> Undefined Then
			If Expanded Then
				Items.Plan.Expand(TreeItem.GetID(), False);
			Else
				Items.Plan.Collapse(TreeItem.GetID());
			EndIf;
		EndIf;
		
	EndDo;
	
EndProcedure

&AtClient
Function GetTreeState(Path = "", Node = Undefined, mapState = Undefined)
	
	If Node = Undefined Then
		Node = Plan;
	EndIf;
	
	If mapState = Undefined Then
		mapState = New Map;
	EndIf;
	
	For Each TreeItem In Node.GetItems() Do
		NodePath = Path + "/" + TreeItem.SourceOperator;
		mapState[NodePath] = Items.Plan.Expanded(TreeItem.GetID());
		mapState = GetTreeState(NodePath, TreeItem, mapState);
	EndDo;
	
	Return mapState;
	
EndFunction


