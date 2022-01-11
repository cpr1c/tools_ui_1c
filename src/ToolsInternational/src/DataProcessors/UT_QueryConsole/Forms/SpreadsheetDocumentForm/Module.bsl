
&AtServer
Function GetColumnSizes(vtDataSizes)
	
	nMinimumColumnSize = 8;
	nDiscard = 1.0;//%
	arColumnSizes = New Array;
	For Each Column In vtDataSizes.Columns Do
		
		vt1c = vtDataSizes.Copy(, Column.Name);
		vt1c.Sort(Column.Name + " Desc");
		
		If vt1c.Count() > 0 Then
			arColumnSizes.Add(Max(vt1c[Int(vt1c.Count() * nDiscard / 100)][0], nMinimumColumnSize));
		Else
			arColumnSizes.Add(nMinimumColumnSize);
		EndIf;
		
	EndDo;
	
	Return arColumnSizes;
	
EndFunction

&AtServer
Procedure OutputBranch(Document, OutputRow, OutputRowGroup1, OutputRowGroup2, Selection, vtFieldSizes, DataProcessor, fMacrocolumnsExists, stMacrocolumns)
	
	While Selection.Next() Do
		
		ChildSelection = Selection.Select();
		fGroup = ChildSelection.Count() > 0;
		
		If fGroup Then
			
			If Selection.Level() = 0 Then
				
				OutputRowGroup1.Parameters.Fill(Selection);
				If fMacrocolumnsExists Then
					DataProcessor.ProcessMacrocolumns(OutputRowGroup1.Parameters, Selection, stMacrocolumns);
				EndIf;
				
			    Document.Put(OutputRowGroup1, Selection.Level());
				
			Else
				
				OutputRowGroup2.Parameters.Fill(Selection);
				If fMacrocolumnsExists Then
					DataProcessor.ProcessMacrocolumns(OutputRowGroup2.Parameters, Selection, stMacrocolumns);
				EndIf;
				
			    Document.Put(OutputRowGroup2, Selection.Level());
				
			EndIf;
			
		Else
			
			OutputRow.Parameters.Fill(Selection);
			If fMacrocolumnsExists Then
				DataProcessor.ProcessMacrocolumns(OutputRow.Parameters, Selection, stMacrocolumns);
			EndIf;
			
		    Document.Put(OutputRow, Selection.Level());
			
		EndIf;
		
		SizesRow = vtFieldSizes.Add();
		For Each Column In vtFieldSizes.Columns Do
			SizesRow[Column.Name] = StrLen(OutputRow.Parameters[Column.Name]);
		EndDo;
		
		If fGroup Then
			OutputBranch(Document, OutputRow, OutputRowGroup1, OutputRowGroup2, ChildSelection, vtFieldSizes, DataProcessor, fMacrocolumnsExists, stMacrocolumns);
		EndIf;
		
	EndDo;	
	
EndProcedure

&AtServer
Procedure GenerateDocument(Parameters)
	
	DataProcessor = FormAttributeToValue("Object");
	
	stQueryResult = GetFromTempStorage(Parameters.QueryResultAddress);
	arQueryResult = stQueryResult.Result;
	stBatchResult = arQueryResult[Number(Parameters.ResultInBatch) - 1];
	qrSelection = stBatchResult.Result;
	ResultName = stBatchResult.ResultName;
	stMacrocolumns = stBatchResult.Macrocolumns;
	MacrocolumnsExists = stMacrocolumns.Count() > 0;
	
	Document.Clear();
	
	ReportRow = New Line(SpreadsheetDocumentCellLineType.Solid, 1);
	//HeaderRowColor = StyleColors.ReportRowColor;
	TitleFont = New Font("Arial", 12, True);
	SmallTitleFont = New Font("Arial", 8, True);
	//HeaderFont = StyleFonts.fontfNew Font(, 8, False);
	HeaderColor = StyleColors.TableHeaderBackColor;
	
    nColumnTitles = New Structure;
    OutputRow = Document.GetArea(1, 1, 1, qrSelection.Columns.Count());
    OutputRowGroup1 = Document.GetArea(1, 1, 1, qrSelection.Columns.Count());
    OutputRowGroup2 = Document.GetArea(1, 1, 1, qrSelection.Columns.Count());
    HeaderRow = Document.GetArea(1, 1, 1, qrSelection.Columns.Count());
    BlankRow = Document.GetArea(1, 1, 1, qrSelection.Columns.Count());
	For j = 1 To qrSelection.Columns.Count() Do
		
		Column = qrSelection.Columns[j - 1];
        ColumnName = Column.Name;
		
		//data row
        FillingArea = OutputRow.Area(1, j, 1, j);
        FillingArea.Parameter = ColumnName;
        FillingArea.FillType = SpreadsheetDocumentAreaFillType.Parameter;
		FillingArea.TopBorder = ReportRow;
		FillingArea.BottomBorder = ReportRow;
		FillingArea.LeftBorder = ReportRow;
		FillingArea.RightBorder = ReportRow;
		//FillingArea.AutoIndent = 4;
		
		//group 1 title
        FillingArea = OutputRowGroup1.Area(1, j, 1, j);
		FillingArea.BackColor = StyleColors.ReportGroup1BackColor;
        FillingArea.Parameter = ColumnName;
        FillingArea.FillType = SpreadsheetDocumentAreaFillType.Parameter;
		FillingArea.TopBorder = ReportRow;
		FillingArea.BottomBorder = ReportRow;
		FillingArea.LeftBorder = ReportRow;
		FillingArea.RightBorder = ReportRow;
		//FillingArea.AutoIndent = 4;
		
		//group 2 title
        FillingArea = OutputRowGroup2.Area(1, j, 1, j);
		FillingArea.BackColor = StyleColors.ReportGroup2BackColor;
        FillingArea.Parameter = ColumnName;
        FillingArea.FillType = SpreadsheetDocumentAreaFillType.Parameter;
		FillingArea.TopBorder = ReportRow;
		FillingArea.BottomBorder = ReportRow;
		FillingArea.LeftBorder = ReportRow;
		FillingArea.RightBorder = ReportRow;
		//FillingArea.AutoIndent = 4;
		
		//шапка
        FillingArea = HeaderRow.Area(1, j, 1, j);
		//FillingArea.Font = HeaderFont;
		FillingArea.TopBorder = ReportRow;
		FillingArea.BottomBorder = ReportRow;
		FillingArea.LeftBorder = ReportRow;
		FillingArea.RightBorder = ReportRow;
		FillingArea.BackColor = HeaderColor;
        FillingArea.Parameter = ColumnName;
		FillingArea.HorizontalAlign = HorizontalAlign.Justify;
		//FillingArea.HorizontalAlign = HorizontalAlign.Center;
		FillingArea.VerticalAlign = VerticalAlign.Center;
        FillingArea.FillType = SpreadsheetDocumentAreaFillType.Parameter;
		FillingArea.Comment.Text = Column.ValueType;
		
        nColumnTitles.Insert(ColumnName, ColumnName);
		
	EndDo;
	
    TitleRow = Document.GetArea(1, 1);
	TitleArea = TitleRow.Area(1, 1, 1, 1);
	TitleArea.Text = Parameters.QueryName;
	TitleArea.Font = TitleFont;
    Document.Put(TitleRow);
	TitleArea.Text = ResultName;
	TitleArea.Font = SmallTitleFont;
	TitleArea.Indent = 4;
    Document.Put(TitleRow);
	Document.Put(BlankRow);
    HeaderRow.Parameters.Fill(nColumnTitles);
    Document.Put(HeaderRow);
	
	vtDataSizes = New ValueTable;
	For Each kv In nColumnTitles Do
		ColumnName = kv.Key;
		vtDataSizes.Columns.Add(ColumnName, New TypeDescription("Number", New NumberQualifiers(5, 0)));
	EndDo;
	
	If Parameters.ResultKind = "table" Then
		
		selSelection = qrSelection.Выбрать();
		While selSelection.Next() Do
			
	        OutputRow.Parameters.Fill(selSelection);
			If MacrocolumnsExists Then
				DataProcessor.ProcessMacrocolumns(OutputRow.Parameters, selSelection, stMacrocolumns);
			EndIf;
			
	        Document.Put(OutputRow);
			
			SizesRow = vtDataSizes.Add();
			If MacrocolumnsExists Then
				For Each Column In vtDataSizes.Columns Do
					SizesRow[Column.Name] = StrLen(OutputRow.Parameters[Column.Name]);
				EndDo;
			Else
				For j = 0 To vtDataSizes.Columns.Count() - 1 Do
					SizesRow[j] = StrLen(selSelection[j]);
				EndDo;
			EndIf;
		
		EndDo;	
		
		arColumnSizes = GetColumnSizes(vtDataSizes);
		
		For j = 0 To arColumnSizes.Count() - 1 Do
			Document.Area(1, j + 1, Document.TableHeight, j + 1).ColumnWidth = arColumnSizes[j];
		EndDo;
		
	ElsIf Parameters.ResultKind = "tree" Then
		
		Document.StartRowAutoGrouping();
		
		//nCounter = 0;
		selSelection = qrSelection.Select(QueryResultIteration.ByGroups);
		OutputBranch(Document, OutputRow, OutputRowGroup1, OutputRowGroup1, selSelection, vtDataSizes, DataProcessor, MacrocolumnsExists, stMacrocolumns);
		
		Document.EndRowAutoGrouping();
		
		arColumnSizes = GetColumnSizes(vtDataSizes);
		
		For j = 0 To arColumnSizes.Count() - 1 Do
			Document.Area(1, j + 1, Document.TableHeight, j + 1).ColumnWidth = arColumnSizes[j];
		EndDo;
		
	EndIf;

EndProcedure
	
&AtServer
Procedure RefreshDocumentAtServer(Parameters)
	
	CopyFormData(Parameters.Object, Object);
	
	Title = StrTemplate(NStr("ru = '%1 / Результат%2'; en = '%1 / Result%2'"), Parameters.QueryName, Parameters.ResultInBatch - 1);
	
	Items.TreeGroup.Visible = Parameters.ResultKind = "tree";
	
	GenerateDocument(Parameters);
	
	Initialized = True;
	
EndProcedure

&AtClient
Procedure OnReopen()
	Initialized = False;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	RefreshDocumentAtServer(Parameters);
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source)
	If EventName = "Refresh" Then
		RefreshDocumentAtServer(Parameter);
	EndIf;
EndProcedure
