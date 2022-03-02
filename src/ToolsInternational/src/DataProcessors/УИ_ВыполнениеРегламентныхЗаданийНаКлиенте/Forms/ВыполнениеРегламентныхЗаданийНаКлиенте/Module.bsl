#Region FormEventHandlers

&AtServer	
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	SetConditionalAppearance();

	If Parameters.Property("AutoTest") Then // Return upon receipt of the form for analysis.
		Return;
	EndIf;

	UpdateScheduledJobsTable();
	ExecutionCheckTimeInterval = 5; // 5 seconds.

	ПараметрыОтбора = New Structure;
	ПараметрыОтбора.Insert("ToPerform", True);
	Included = TableOfScheduledJobs.FindRows(ПараметрыОтбора).Count();

	If Included <> 0 Then
		Items.StatusBar.Title = SubstituteParametersIntoTheString(
			NStr("ru = 'Отмеченные регламентные задания выполняются на этом клиентском компьютере (%1)...';en = 'Marked scheduled jobs are running on this client computer (%1)...'"), Included);
	EndIf;

	UT_Common.ToolFormOnCreateAtServer(ThisObject, Cancel, StandardProcessing);

EndProcedure

&AtClient
Procedure OnOpen(Cancel)

#If Not ThickClientOrdinaryApplication Then

#EndIf

	RemainingBeforeExecutionStarts = ExecutionCheckTimeInterval + 1;
	CompleteScheduledJobs();

EndProcedure

#EndRegion

#Region FormElementEventHandlers

&AtClient
Procedure TableOfScheduledJobsToPerformOnChange(Item)
	CurrentData = Items.ScheduledJobs.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	EditUseScheduledJob(CurrentData.ID, CurrentData.ToPerform);

	ПараметрыОтбора = New Structure;
	ПараметрыОтбора.Insert("ToPerform", True);
	Included = TableOfScheduledJobs.FindRows(ПараметрыОтбора).Count();

	If Included = 0 Then
		Items.StatusBar.Title = NStr(
			"ru = 'Отметьте регламентные задания для выполнения на клиентском компьютере...';en = 'Mark scheduled tasks to run on the client computer...'");
	Else
		Items.StatusBar.Title = SubstituteParametersIntoTheString(
			NStr("ru = 'Отмеченные регламентные задания выполняются на этом клиентском компьютере (%1)...';en = 'Marked scheduled jobs run on this client computer (%1)...'"), Included);
	EndIf;

EndProcedure

&AtServer
Procedure EditUseScheduledJob(ID, ToPerform)

	Properties = CommonSettingsStorage.Load("СостояниеРегламентногоЗадания_" + String(ID), , , "");

	Properties = ?(TypeOf(Properties) = Type("ValueStorage"), Properties.Get(), Undefined);
	If Properties = Undefined Then
		Properties = EmptyPropertyTableBackgroundJobs().Add();
		Properties.ScheduledJobUUID = ID;
		Properties = RowTableValuesInStructure(Properties);
	EndIf;
	Properties.ToPerform = ToPerform;
	StoredValue = New ValueStorage(Properties);
	CommonSettingsStorage.Save("СостояниеРегламентногоЗадания_" + String(ID), , StoredValue, ,
		"");

EndProcedure

#EndRegion

#Region CommandFormEventHandlers

&AtClient
Procedure StopExecution(Command)

	Close();

EndProcedure

&AtClient
Procedure ClearNumberOfRuns(Command)

	CurrentData = Items.ScheduledJobs.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	ClearQuantityOfRunsAtServer(CurrentData.ID);

EndProcedure

&AtClient
Procedure Attachable_ExecuteToolsCommonCommand(Command) Export
	UT_CommonClient.Attachable_ExecuteToolsCommonCommand(ThisObject, Command);
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure SetConditionalAppearance()

	ConditionalAppearance.Items.Clear();
	
	//
	Item = ConditionalAppearance.Items.Add();

	ПолеЭлемента = Item.Fields.Items.Add();
	ПолеЭлемента.Field = New DataCompositionField(Items.TableOfScheduledJobsDone.Name);

	ОтборЭлемента = Item.Filter.Items.Add(Type("DataCompositionFilterItem"));
	ОтборЭлемента.LeftValue  = New DataCompositionField("TableOfScheduledJobs.Changed");
	ОтборЭлемента.ComparisonType   = DataCompositionComparisonType.Equal;
	ОтборЭлемента.RightValue = True;

	Item.Appearance.SetParameterValue("Text", New Color(128, 122, 89));

EndProcedure

&AtServer
Procedure ClearQuantityOfRunsAtServer(ID)

	Properties = CommonSettingsStorage.Load("СостояниеРегламентногоЗадания_" + String(ID), , , "");

	Properties = ?(TypeOf(Properties) = Type("ValueStorage"), Properties.Get(), Undefined);
	If Properties = Undefined Then
		Return;
	EndIf;
	Properties.ПопыткаЗапуска = 0;
	CommonSettingsStorage.Save("СостояниеРегламентногоЗадания_" + String(ID), ,
		New ValueStorage(Properties), , "");

EndProcedure

&AtClient
Procedure CompleteScheduledJobs()

	RemainingBeforeExecutionStarts = RemainingBeforeExecutionStarts - 1;
	If RemainingBeforeExecutionStarts <= 0 Then

		RemainingBeforeExecutionStarts = ExecutionCheckTimeInterval;
		RefreshDataRepresentation();

		CompleteScheduledJobsAtServer(LaunchParameter);
	EndIf;

	AttachIdleHandler("CompleteScheduledJobs", 1, True);

EndProcedure

&AtServer
Procedure UpdateScheduledJobsTable()

	SetPrivilegedMode(True);
	CurrentJobs = ScheduledJobs.GetScheduledJobs();

	NewTableJobs = FormAttributeToValue("TableOfScheduledJobs");
	NewTableJobs.Clear();

	For Each Job In CurrentJobs Do
		СтрокаЗадания = NewTableJobs.Add();

		СтрокаЗадания.ScheduledJob = RepresentationScheduledJob(Job);
		СтрокаЗадания.Done     = Date(1, 1, 1);
		СтрокаЗадания.ID = Job.UUID;

		PropertiesLastBackgroundJob = PropertiesLastBackgroundJobRunningRegularJob(Job);

		If PropertiesLastBackgroundJob <> Undefined Then
			If ValueIsFilled(PropertiesLastBackgroundJob.End) Then
				СтрокаЗадания.Done = PropertiesLastBackgroundJob.End;
				СтрокаЗадания.Status = String(PropertiesLastBackgroundJob.Status);
			EndIf;

			СтрокаЗадания.ToPerform = PropertiesLastBackgroundJob.ToPerform;
		EndIf;

		СвойстваЗадания = TableOfScheduledJobs.FindRows(
			New Structure("ID", СтрокаЗадания.ID));

		СтрокаЗадания.Changed = (СвойстваЗадания = Undefined) Or (СвойстваЗадания.Count() = 0)
			Or (СвойстваЗадания[0].Done <> СтрокаЗадания.Done);
	EndDo;

	NewTableJobs.Sort("ScheduledJob");

	НомерЗадания = 1;
	For Each СтрокаЗадания In NewTableJobs Do
		СтрокаЗадания.Number = НомерЗадания;
		НомерЗадания = НомерЗадания + 1;
	EndDo;

	ValueToFormAttribute(NewTableJobs, "TableOfScheduledJobs");

EndProcedure

&AtClient
Procedure CompleteScheduledJobsAtServer(LaunchParameter)
#If ThickClientOrdinaryApplication Then 
	RunTheExectutionSheduledJobs(ThisObject.TableOfScheduledJobs);
	UpdateScheduledJobsTable();
#EndIf
EndProcedure

&AtClientAtServerNoContext
Procedure RunTheExectutionSheduledJobs(ТаблицаРегламентныхЗаданий)
#If Server Or ThickClientOrdinaryApplication Then
	CallExceptionIfNoAdministrativeRights();
	SetPrivilegedMode(True);

	Status = StateOfCompletionScheduledJobs();

	ВремяВыполнения = ?(TypeOf(ВремяВыполнения) = Type("Number"), ВремяВыполнения, 0);

	Jobs                        = ScheduledJobs.GetScheduledJobs();
	ExecutionCompleted            = False; // Определяет, что ВремяВыполнения закончилось, или
	                                       // все возможные регламентные задания выполнены.
	НачалоВыполнения               = CurrentSessionDate();
	КоличествоВыполненныхЗаданий   = 0;
	BackgroundJobRunning      = False;
	ИдентификаторПоследнегоЗадания = Status.ИдентификаторОчередногоЗадания;

	// Count заданий проверяется каждый раз при начале выполнения,
	// т.к. задания могут быть удалены в другом сеансе, а тогда будет зацикливание.
	While Not ExecutionCompleted And Jobs.Count() > 0 Do
		ПервоеЗаданиеНайдено           = (ИдентификаторПоследнегоЗадания = Undefined);
//		ОчередноеЗаданиеНайдено        = False;
		For Each Job In Jobs Do
			ПараметрыОтбора = New Structure;
			ПараметрыОтбора.Insert("ID", Job.UUID);
			Result = TableOfScheduledJobs.FindRows(ПараметрыОтбора);
			ЗаданиеВключено = Result[0].ToPerform;
			
			// End выполнения, если:
			// а) время задано и вышло;
			// б) время не задано и хоть одно фоновое задание выполнено;
			// в) время не задано и все регламентные задания выполнены по количеству.
			If (ВремяВыполнения = 0 And (BackgroundJobRunning Or КоличествоВыполненныхЗаданий
				>= Jobs.Count())) Or (ВремяВыполнения <> 0 And НачалоВыполнения + ВремяВыполнения
				<= CurrentSessionDate()) Then
				ExecutionCompleted = True;
				Break;
			EndIf;
			If Not ПервоеЗаданиеНайдено Then
				If String(Job.UUID) = ИдентификаторПоследнегоЗадания Then
				   // Найдено последнее выполненное регламентное задание, значит следующее
				   // регламентное задание нужно проверять на необходимость выполнения фонового задания.
					ПервоеЗаданиеНайдено = True;
				EndIf;
				// If первое регламентное задание, которое нужно проверить на необходимость
				// выполнения фонового задания еще не найдено, тогда текущее задание пропускается.
				Continue;
			EndIf;
//			ОчередноеЗаданиеНайдено = True;
			КоличествоВыполненныхЗаданий = КоличествоВыполненныхЗаданий + 1;
			Status.ИдентификаторОчередногоЗадания       = String(Job.UUID);
			Status.НачалоВыполненияОчередногоЗадания    = CurrentSessionDate();
			Status.ОкончаниеВыполненияОчередногоЗадания = '00010101';
			SaveStateOfCompletionScheduledJobs(Status, "ИдентификаторОчередногоЗадания,
																	   |НачалоВыполненияОчередногоЗадания,
																	   |ОкончаниеВыполненияОчередногоЗадания");
			If ЗаданиеВключено Then
				ExecuteScheduledJob = False;
				PropertiesLastBackgroundJob = PropertiesLastBackgroundJobRunningRegularJob(
					Job);

				If PropertiesLastBackgroundJob <> Undefined And PropertiesLastBackgroundJob.Status
					= BackgroundJobState.Failed Then
					// Проверка аварийного расписания.
					If PropertiesLastBackgroundJob.ПопыткаЗапуска
						<= Job.RestartCountOnFailure Then
						If PropertiesLastBackgroundJob.End + Job.RestartIntervalOnFailure
							<= CurrentSessionDate() Then
						    // Повторный запуск фонового задания по регламентному заданию.
							ExecuteScheduledJob = True;
						EndIf;
					EndIf;
				Else
					// Проверяем стандартное расписание.
					ExecuteScheduledJob = Job.Schedule.ExecutionRequired(
						CurrentSessionDate(), ?(PropertiesLastBackgroundJob = Undefined, '00010101',
						PropertiesLastBackgroundJob.Begin), ?(PropertiesLastBackgroundJob = Undefined,
						'00010101', PropertiesLastBackgroundJob.End));
				EndIf;
				If ExecuteScheduledJob Then
					BackgroundJobRunning = ExecuteScheduledJob(Job);
				EndIf;
			EndIf;
			Status.ОкончаниеВыполненияОчередногоЗадания = CurrentSessionDate();
			SaveStateOfCompletionScheduledJobs(Status, "ОкончаниеВыполненияОчередногоЗадания");
		EndDo;
		// If the last executed task could not be found, then
		// its ID is reset,
		// to start checking scheduled tasks starting from the first.
		ИдентификаторПоследнегоЗадания = Undefined;
	EndDo;

#EndIf
EndProcedure

&AtServerNoContext
Function ExecuteScheduledJob(Val Job)
	ЗапускВручную = False;
	МоментЗапуска = Undefined;
	МоментОкончания = Undefined;
	//@skip-warning
	SessionNumber = Undefined;
	//@skip-warning
	SessionStarted = Undefined;
//	
	PropertiesLastBackgroundJob = PropertiesLastBackgroundJobRunningRegularJob(Job);

	If PropertiesLastBackgroundJob <> Undefined And PropertiesLastBackgroundJob.Status
		= BackgroundJobState.Active Then

		SessionNumber  = PropertiesLastBackgroundJob.SessionNumber;
		SessionStarted = PropertiesLastBackgroundJob.SessionStarted;
		Return False;
	EndIf;

	MethodName = Job.Metadata.MethodName;
	НаименованиеФоновогоЗадания = SubstituteParametersIntoTheString(
		?(ЗапускВручную, NStr("ru = 'Run вручную: %1'"), NStr("ru = 'Автозапуск: %1'")),
		RepresentationScheduledJob(Job));

	МоментЗапуска = ?(TypeOf(МоментЗапуска) <> Type("Date") Or Not ValueIsFilled(МоментЗапуска),
		CurrentSessionDate(), МоментЗапуска);
	
	// Creating свойств нового фонового псевдо-задания.
	BackgroundJobProperties = EmptyPropertyTableBackgroundJobs().Add();
	BackgroundJobProperties.ToPerform = PropertiesLastBackgroundJob.ToPerform;
	BackgroundJobProperties.ID  = String(New UUID);
	BackgroundJobProperties.ПопыткаЗапуска = ?(
		PropertiesLastBackgroundJob <> Undefined And PropertiesLastBackgroundJob.Status
		= BackgroundJobState.Failed, PropertiesLastBackgroundJob.ПопыткаЗапуска + 1, 1);
	BackgroundJobProperties.Title                      = НаименованиеФоновогоЗадания;
	BackgroundJobProperties.ScheduledJobUUID = String(Job.UUID);
	BackgroundJobProperties.Placement                      = "\\" + ComputerName();
	BackgroundJobProperties.MethodName                         = MethodName;
	BackgroundJobProperties.Status                         = BackgroundJobState.Active;
	BackgroundJobProperties.Begin                            = МоментЗапуска;
	BackgroundJobProperties.SessionNumber                       = InfoBaseSessionNumber();

	For Each Сеанс In GetInfoBaseSessions() Do
		If Сеанс.SessionNumber = BackgroundJobProperties.SessionNumber Then
			BackgroundJobProperties.SessionStarted = Сеанс.SessionStarted;
			Break;
		EndIf;
	EndDo;
	
	// Save информации о запуске.
	StoredValue = New ValueStorage(RowTableValuesInStructure(BackgroundJobProperties));
	CommonSettingsStorage.Save("СостояниеРегламентногоЗадания_" + String(Job.UUID), ,
		StoredValue, , "");

	GetUserMessages(True);
	Try
		// Здесь нет возможности выполнения произвольного кода, т.к. метод берется из метаданных регламентного задания.
		ExecuteMethodConfiguration(MethodName, Job.Parameters);
		BackgroundJobProperties.Status = BackgroundJobState.Finished;
	Except
		BackgroundJobProperties.Status = BackgroundJobState.Failed;
		BackgroundJobProperties.DescriptionErrorInformation = DetailErrorDescription(ErrorInfo());
	EndTry;
	
	// Фиксация окончания выполнения метода.
	МоментОкончания = CurrentSessionDate();
	BackgroundJobProperties.End = МоментОкончания;
	BackgroundJobProperties.MessagesToUser = New Array;
	For Each Message In GetUserMessages() Do
		BackgroundJobProperties.MessagesToUser.Add(Message);
	EndDo;
	GetUserMessages(True);

	Properties = CommonSettingsStorage.Load("СостояниеРегламентногоЗадания_" + String(
		Job.UUID), , , "");
	Properties = ?(TypeOf(Properties) = Type("ValueStorage"), Properties.Get(), Undefined);

	If TypeOf(Properties) <> Type("Structure") Or Not Properties.Property("SessionNumber") Or Not Properties.Property(
		"SessionStarted") Or (Properties.SessionNumber = BackgroundJobProperties.SessionNumber And Properties.SessionStarted
		= BackgroundJobProperties.SessionStarted) Then
		// Маловероятной перезаписи из-за отсутствия блокировки не произошло, поэтому можно записать свойства.
		StoredValue = New ValueStorage(RowTableValuesInStructure(BackgroundJobProperties));
		CommonSettingsStorage.Save("СостояниеРегламентногоЗадания_" + String(Job.UUID), ,
			StoredValue, , "");
	EndIf;

	Return True;
EndFunction

&AtServerNoContext
Function StateOfCompletionScheduledJobs()
	// Подготовка данных для проверки или начальной установки свойств прочитанного состояния.
	НоваяСтруктура = New Structure;
	// Location истории выполнения фоновых заданий.
	НоваяСтруктура.Insert("SessionNumber", 0);
	НоваяСтруктура.Insert("SessionStarted", '00010101');
	НоваяСтруктура.Insert("ComputerName", "");
	НоваяСтруктура.Insert("ApplicationName", "");
	НоваяСтруктура.Insert("UserName", "");
	НоваяСтруктура.Insert("ИдентификаторОчередногоЗадания", "");
	НоваяСтруктура.Insert("НачалоВыполненияОчередногоЗадания", '00010101');
	НоваяСтруктура.Insert("ОкончаниеВыполненияОчередногоЗадания", '00010101');

	Status = CommonSettingsStorage.Load("StateOfCompletionScheduledJobs", , , "");
	Status = ?(TypeOf(Status) = Type("ValueStorage"), Status.Get(), Undefined);
	
	// Copy существующих свойств.
	If TypeOf(Status) = Type(НоваяСтруктура) Then
		For Each KeyAndValue In НоваяСтруктура Do
			If Status.Property(KeyAndValue.Key) Then
				If TypeOf(НоваяСтруктура[KeyAndValue.Key]) = TypeOf(Status[KeyAndValue.Key]) Then
					НоваяСтруктура[KeyAndValue.Key] = Status[KeyAndValue.Key];
				EndIf;
			EndIf;
		EndDo;
	EndIf;

	Return НоваяСтруктура;
EndFunction

&AtClientAtServerNoContext
Procedure SaveStateOfCompletionScheduledJobs(Status, Val ChangedProperties = Undefined)
#If Server Or ThickClientOrdinaryApplication Then
	If ChangedProperties <> Undefined Then
		CurrentState = StateOfCompletionScheduledJobs();
		FillPropertyValues(CurrentState, Status, ChangedProperties);
		Status = CurrentState;
	EndIf;

	CommonSettingsStorage.Save("StateOfCompletionScheduledJobs", , New ValueStorage(Status), ,
		"");
#EndIf
EndProcedure

&AtServerNoContext
Function PropertiesLastBackgroundJobRunningRegularJob(ScheduledJob)
	CallExceptionIfNoAdministrativeRights();
	SetPrivilegedMode(True);

	ИдентификаторРегламентногоЗадания = ?(TypeOf(ScheduledJob) = Type("ScheduledJob"), String(
		ScheduledJob.UUID), ScheduledJob);
	Filter = New Structure;
	Filter.Insert("ScheduledJobUUID", ИдентификаторРегламентногоЗадания);
	Filter.Insert("ПолучитьПоследнееФоновоеЗаданиеРегламентногоЗадания");
	ТаблицаСвойствФоновыхЗаданий = СвойствФоновыхЗаданий(Filter);
	ТаблицаСвойствФоновыхЗаданий.Sort("End Asc");

	If ТаблицаСвойствФоновыхЗаданий.Count() = 0 Then
		BackgroundJobProperties = Undefined;
	ElsIf Not ValueIsFilled(ТаблицаСвойствФоновыхЗаданий[0].End) Then
		BackgroundJobProperties = ТаблицаСвойствФоновыхЗаданий[0];
	Else
		BackgroundJobProperties = ТаблицаСвойствФоновыхЗаданий[ТаблицаСвойствФоновыхЗаданий.Count() - 1];
	EndIf;

	StoredValue = New ValueStorage(?(BackgroundJobProperties = Undefined, Undefined,
		RowTableValuesInStructure(BackgroundJobProperties)));
	CommonSettingsStorage.Save("СостояниеРегламентногоЗадания_" + ИдентификаторРегламентногоЗадания, ,
		StoredValue, , "");

	Return BackgroundJobProperties;
EndFunction

&AtServerNoContext
Function СвойствФоновыхЗаданий(Filter = Undefined)
	CallExceptionIfNoAdministrativeRights();
	SetPrivilegedMode(True);

	Table = EmptyPropertyTableBackgroundJobs();

	If Filter <> Undefined And Filter.Property("ПолучитьПоследнееФоновоеЗаданиеРегламентногоЗадания") Then
		Filter.Delete("ПолучитьПоследнееФоновоеЗаданиеРегламентногоЗадания");
		//@skip-warning
		GetLast = True;
	Else
		GetLast = False;
	EndIf;

	ScheduledJob = Undefined;

	If Filter <> Undefined And Filter.Property("ScheduledJobUUID") Then
		ScheduledJobsForProcessingArray = New Array;
		If Filter.ScheduledJobUUID <> "" Then
			If ScheduledJob = Undefined Then
				ScheduledJob = ScheduledJobs.FindByUUID(
					New UUID(Filter.ScheduledJobUUID));
			EndIf;
			If ScheduledJob <> Undefined Then
				ScheduledJobsForProcessingArray.Add(ScheduledJob);
			EndIf;
		EndIf;
	Else
		ScheduledJobsForProcessingArray = ScheduledJobs.GetScheduledJobs();
	EndIf;
	
	// Create и сохранение состояний регламентных заданий
	For Each ScheduledJob In ScheduledJobsForProcessingArray Do
		ИдентификаторРегламентногоЗадания = String(ScheduledJob.UUID);
		Properties = CommonSettingsStorage.Load("СостояниеРегламентногоЗадания_"
			+ ИдентификаторРегламентногоЗадания, , , "");
		Properties = ?(TypeOf(Properties) = Type("ValueStorage"), Properties.Get(), Undefined);

		If TypeOf(Properties) = Type("Structure") And Properties.ScheduledJobUUID = ИдентификаторРегламентногоЗадания
			And Table.FindRows(New Structure("ID, AtServer", Properties.ID,
			Properties.AtServer)).Count() = 0 Then

			If Properties.AtServer Then
				CommonSettingsStorage.Save("СостояниеРегламентногоЗадания_" + ИдентификаторРегламентногоЗадания,
					, Undefined, , "");
			Else
				If Properties.Status = BackgroundJobState.Active Then
					НайденСеансВыполняющийЗадания = False;
					For Each Сеанс In GetInfoBaseSessions() Do
						If Сеанс.SessionNumber = Properties.SessionNumber And Сеанс.SessionStarted = Properties.SessionStarted Then
							НайденСеансВыполняющийЗадания = InfoBaseSessionNumber() <> Сеанс.SessionNumber;
							Break;
						EndIf;
					EndDo;
					If Not НайденСеансВыполняющийЗадания Then
						Properties.End = CurrentSessionDate();
						Properties.Status = BackgroundJobState.Failed;
						Properties.DescriptionErrorInformation = NStr(
							"ru = 'Not найден сеанс, выполняющий процедуру регламентного задания.'");
					EndIf;
				EndIf;
				FillPropertyValues(Table.Add(), Properties);
			EndIf;
		EndIf;
	EndDo;
	Table.Sort("Begin Desc, End Desc");
	
	// Filter фоновых заданий.
	If Filter <> Undefined Then
		Begin    = Undefined;
		End     = Undefined;
		Status = Undefined;
		If Filter.Property("Begin") Then
			Begin = ?(ValueIsFilled(Filter.Begin), Filter.Begin, Undefined);
			Filter.Delete("Begin");
		EndIf;
		If Filter.Property("End") Then
			End = ?(ValueIsFilled(Filter.End), Filter.End, Undefined);
			Filter.Delete("End");
		EndIf;
		If Filter.Property("Status") Then
			If TypeOf(Filter.Status) = Type("Array") Then
				Status = Filter.Status;
				Filter.Delete("Status");
			EndIf;
		EndIf;

		If Filter.Count() <> 0 Then
			Rows = Table.FindRows(Filter);
		Else
			Rows = Table;
		EndIf;
		// Выполнение дополнительной фильтрации по периоду и состоянию (если отбор определен).
		НомерЭлемента = Rows.Count() - 1;
		While НомерЭлемента >= 0 Do
			If Begin <> Undefined And Begin > Rows[НомерЭлемента].Begin Or End <> Undefined And End < ?(
				ValueIsFilled(Rows[НомерЭлемента].End), Rows[НомерЭлемента].End, CurrentSessionDate())
				Or Status <> Undefined And Status.Find(Rows[НомерЭлемента].Status) = Undefined Then
				Rows.Delete(НомерЭлемента);
			EndIf;
			НомерЭлемента = НомерЭлемента - 1;
		EndDo;
		// Delete лишних строк из таблицы.
		If TypeOf(Rows) = Type("Array") Then
			LineNumber = Table.Count() - 1;
			While LineNumber >= 0 Do
				If Rows.Find(Table[LineNumber]) = Undefined Then
					Table.Delete(Table[LineNumber]);
				EndIf;
				LineNumber = LineNumber - 1;
			EndDo;
		EndIf;
	EndIf;

	Return Table;
EndFunction

&AtServerNoContext
Function EmptyPropertyTableBackgroundJobs()
	NewTable = New ValueTable;
	NewTable.Cols.Add("AtServer", New TypeDescription("Boolean"));
	NewTable.Cols.Add("ID", New TypeDescription("String"));
	NewTable.Cols.Add("Title", New TypeDescription("String"));
	NewTable.Cols.Add("Key", New TypeDescription("String"));
	NewTable.Cols.Add("Begin", New TypeDescription("Date"));
	NewTable.Cols.Add("End", New TypeDescription("Date"));
	NewTable.Cols.Add("ScheduledJobUUID", New TypeDescription("String"));
	NewTable.Cols.Add("Status", New TypeDescription("BackgroundJobState"));
	NewTable.Cols.Add("MethodName", New TypeDescription("String"));
	NewTable.Cols.Add("Placement", New TypeDescription("String"));
	NewTable.Cols.Add("DescriptionErrorInformation", New TypeDescription("String"));
	NewTable.Cols.Add("ПопыткаЗапуска", New TypeDescription("Number"));
	NewTable.Cols.Add("MessagesToUser", New TypeDescription("Array"));
	NewTable.Cols.Add("SessionNumber", New TypeDescription("Number"));
	NewTable.Cols.Add("SessionStarted", New TypeDescription("Date"));
	NewTable.Cols.Add("ToPerform", New TypeDescription("Boolean"));
	NewTable.Indexes.Add("ID, Begin");

	Return NewTable;
EndFunction

&AtServerNoContext
Function RepresentationScheduledJob(Val Job) Export
	CallExceptionIfNoAdministrativeRights();

	If TypeOf(Job) = Type("ScheduledJob") Then
		ScheduledJob = Job;
	Else
		ScheduledJob = ScheduledJobs.FindByUUID(
			New UUID(Job));
	EndIf;

	If ScheduledJob <> Undefined Then
		Presentation = ScheduledJob.Title;

		If IsBlankString(ScheduledJob.Title) Then
			Presentation = ScheduledJob.Metadata.Synonym;

			If IsBlankString(Presentation) Then
				Presentation = ScheduledJob.Metadata.Name;
			EndIf;
		EndIf
		;
	Else
		Presentation = NStr("ru = '<не определено>';en = '<undefined>'");
	EndIf;

	Return Presentation;
EndFunction

&AtServerNoContext
Procedure CallExceptionIfNoAdministrativeRights() Export

	If Not PrivilegedMode() Then
		VerifyAccessRights("Administration", Metadata);
	EndIf;

EndProcedure

&AtClientAtServerNoContext
Function SubstituteParametersIntoTheString(Val SubstitutionString, Val Parameter1, Val Parameter2 = Undefined,
	Val Parameter3 = Undefined, Val Parameter4 = Undefined, Val Parameter5 = Undefined,
	Val Parameter6 = Undefined, Val Parameter7 = Undefined, Val Parameter8 = Undefined,
	Val Parameter9 = Undefined) Export

	SubstitutionString = StrReplace(SubstitutionString, "%1", Parameter1);
	SubstitutionString = StrReplace(SubstitutionString, "%2", Parameter2);
	SubstitutionString = StrReplace(SubstitutionString, "%3", Parameter3);
	SubstitutionString = StrReplace(SubstitutionString, "%4", Parameter4);
	SubstitutionString = StrReplace(SubstitutionString, "%5", Parameter5);
	SubstitutionString = StrReplace(SubstitutionString, "%6", Parameter6);
	SubstitutionString = StrReplace(SubstitutionString, "%7", Parameter7);
	SubstitutionString = StrReplace(SubstitutionString, "%8", Parameter8);
	SubstitutionString = StrReplace(SubstitutionString, "%9", Parameter9);

	Return SubstitutionString;
EndFunction

&AtClientAtServerNoContext
Procedure ExecuteMethodConfiguration(Val MethodName, Val Parameters = Undefined)

	ParametersString = "";
	If Parameters <> Undefined And Parameters.Count() > 0 Then
		For IndexOf = 0 To Parameters.UBound() Do
			ParametersString = ParametersString + "Parameters[" + IndexOf + "],";
		EndDo;
		ParametersString = Mid(ParametersString, 1, StrLen(ParametersString) - 1);
	EndIf;

	Execute MethodName + "(" + ParametersString + ")";

EndProcedure

&AtClientAtServerNoContext
Function RowTableValuesInStructure(ValueTableRow)

	Structure = New Structure;
	For Each Column In ValueTableRow.Owner().Cols Do
		Structure.Insert(Column.Name, ValueTableRow[Column.Name]);
	EndDo;

	Return Structure;

EndFunction

#EndRegion