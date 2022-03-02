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
	ПараметрыОтбора.Insert("Выполнять", True);
	Включено = TableOfScheduledJobs.FindRows(ПараметрыОтбора).Count();

	If Включено <> 0 Then
		Items.СтрокаСостояния.Title = ПодставитьПараметрыВСтроку(
			NStr("ru = 'Отмеченные регламентные задания выполняются на этом клиентском компьютере (%1)...'"), Включено);
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

#Region ОбработчикиСобытийЭлементовФормы

&AtClient
Procedure РегламентныеЗаданияВыполнятьПриИзменении(Item)
	CurrentData = Items.ScheduledJobs.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;

	ИзменитьИспользованиеРегламентногоЗадания(CurrentData.ID, CurrentData.Выполнять);

	ПараметрыОтбора = New Structure;
	ПараметрыОтбора.Insert("Выполнять", True);
	Включено = TableOfScheduledJobs.FindRows(ПараметрыОтбора).Count();

	If Включено = 0 Then
		Items.СтрокаСостояния.Title = NStr(
			"ru = 'Отметьте регламентные задания для выполнения на клиентском компьютере...'");
	Else
		Items.СтрокаСостояния.Title = ПодставитьПараметрыВСтроку(
			NStr("ru = 'Отмеченные регламентные задания выполняются на этом клиентском компьютере (%1)...'"), Включено);
	EndIf;

EndProcedure

&AtServer
Procedure ИзменитьИспользованиеРегламентногоЗадания(ID, Выполнять)

	Properties = CommonSettingsStorage.Load("СостояниеРегламентногоЗадания_" + String(ID), , , "");

	Properties = ?(TypeOf(Properties) = Type("ValueStorage"), Properties.Get(), Undefined);
	If Properties = Undefined Then
		Properties = ПустаяТаблицаСвойствФоновыхЗаданий().Add();
		Properties.ScheduledJobUUID = ID;
		Properties = СтрокаТаблицыЗначенийВСтруктуру(Properties);
	EndIf;
	Properties.Выполнять = Выполнять;
	СохраняемоеЗначение = New ValueStorage(Properties);
	CommonSettingsStorage.Save("СостояниеРегламентногоЗадания_" + String(ID), , СохраняемоеЗначение, ,
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
	ПолеЭлемента.Field = New DataCompositionField(Items.РегламентныеЗаданияВыполнено.Name);

	ОтборЭлемента = Item.Filter.Items.Add(Type("DataCompositionFilterItem"));
	ОтборЭлемента.LeftValue  = New DataCompositionField("ТаблицаРегламентныхЗаданий.Изменено");
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
	ТекущиеЗадания = ScheduledJobs.GetScheduledJobs();

	НоваяТаблицаЗаданий = FormAttributeToValue("TableOfScheduledJobs");
	НоваяТаблицаЗаданий.Clear();

	For Each Задание In ТекущиеЗадания Do
		СтрокаЗадания = НоваяТаблицаЗаданий.Add();

		СтрокаЗадания.ScheduledJob = ПредставлениеРегламентногоЗадания(Задание);
		СтрокаЗадания.Выполнено     = Date(1, 1, 1);
		СтрокаЗадания.ID = Задание.UUID;

		СвойстваПоследнегоФоновогоЗадания = СвойстваПоследнегоФоновогоЗаданияВыполненияРегламентногоЗадания(Задание);

		If СвойстваПоследнегоФоновогоЗадания <> Undefined Then
			If ValueIsFilled(СвойстваПоследнегоФоновогоЗадания.End) Then
				СтрокаЗадания.Выполнено = СвойстваПоследнегоФоновогоЗадания.End;
				СтрокаЗадания.Статус = String(СвойстваПоследнегоФоновогоЗадания.Status);
			EndIf;

			СтрокаЗадания.Выполнять = СвойстваПоследнегоФоновогоЗадания.Выполнять;
		EndIf;

		СвойстваЗадания = TableOfScheduledJobs.FindRows(
			New Structure("ID", СтрокаЗадания.ID));

		СтрокаЗадания.Изменено = (СвойстваЗадания = Undefined) Or (СвойстваЗадания.Count() = 0)
			Or (СвойстваЗадания[0].Выполнено <> СтрокаЗадания.Выполнено);
	EndDo;

	НоваяТаблицаЗаданий.Sort("ScheduledJob");

	НомерЗадания = 1;
	For Each СтрокаЗадания In НоваяТаблицаЗаданий Do
		СтрокаЗадания.Number = НомерЗадания;
		НомерЗадания = НомерЗадания + 1;
	EndDo;

	ValueToFormAttribute(НоваяТаблицаЗаданий, "TableOfScheduledJobs");

EndProcedure

&AtClient
Procedure CompleteScheduledJobsAtServer(LaunchParameter)
#If ThickClientOrdinaryApplication Then 
	ЗапуститьВыполнениеРегламентныхЗаданий(ThisObject.TableOfScheduledJobs);
	UpdateScheduledJobsTable();
#EndIf
EndProcedure

&AtClientAtServerNoContext
Procedure ЗапуститьВыполнениеРегламентныхЗаданий(ТаблицаРегламентныхЗаданий)
#If Server Or ThickClientOrdinaryApplication Then
	ВызватьИсключениеЕслиНетПраваАдминистрирования();
	SetPrivilegedMode(True);

	Status = СостояниеВыполненияРегламентныхЗаданий();

	ВремяВыполнения = ?(TypeOf(ВремяВыполнения) = Type("Number"), ВремяВыполнения, 0);

	Задания                        = ScheduledJobs.GetScheduledJobs();
	ВыполнениеЗавершено            = False; // Определяет, что ВремяВыполнения закончилось, или
	                                       // все возможные регламентные задания выполнены.
	НачалоВыполнения               = CurrentSessionDate();
	КоличествоВыполненныхЗаданий   = 0;
	ФоновоеЗаданиеВыполнялось      = False;
	ИдентификаторПоследнегоЗадания = Status.ИдентификаторОчередногоЗадания;

	// Count заданий проверяется каждый раз при начале выполнения,
	// т.к. задания могут быть удалены в другом сеансе, а тогда будет зацикливание.
	While Not ВыполнениеЗавершено And Задания.Count() > 0 Do
		ПервоеЗаданиеНайдено           = (ИдентификаторПоследнегоЗадания = Undefined);
//		ОчередноеЗаданиеНайдено        = False;
		For Each Задание In Задания Do
			ПараметрыОтбора = New Structure;
			ПараметрыОтбора.Insert("ID", Задание.UUID);
			Result = ТаблицаРегламентныхЗаданий.FindRows(ПараметрыОтбора);
			ЗаданиеВключено = Result[0].Выполнять;
			
			// End выполнения, если:
			// а) время задано и вышло;
			// б) время не задано и хоть одно фоновое задание выполнено;
			// в) время не задано и все регламентные задания выполнены по количеству.
			If (ВремяВыполнения = 0 And (ФоновоеЗаданиеВыполнялось Or КоличествоВыполненныхЗаданий
				>= Задания.Count())) Or (ВремяВыполнения <> 0 And НачалоВыполнения + ВремяВыполнения
				<= CurrentSessionDate()) Then
				ВыполнениеЗавершено = True;
				Break;
			EndIf;
			If Not ПервоеЗаданиеНайдено Then
				If String(Задание.UUID) = ИдентификаторПоследнегоЗадания Then
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
			Status.ИдентификаторОчередногоЗадания       = String(Задание.UUID);
			Status.НачалоВыполненияОчередногоЗадания    = CurrentSessionDate();
			Status.ОкончаниеВыполненияОчередногоЗадания = '00010101';
			СохранитьСостояниеВыполненияРегламентныхЗаданий(Status, "ИдентификаторОчередногоЗадания,
																	   |НачалоВыполненияОчередногоЗадания,
																	   |ОкончаниеВыполненияОчередногоЗадания");
			If ЗаданиеВключено Then
				ВыполнитьРегламентноеЗадание = False;
				СвойстваПоследнегоФоновогоЗадания = СвойстваПоследнегоФоновогоЗаданияВыполненияРегламентногоЗадания(
					Задание);

				If СвойстваПоследнегоФоновогоЗадания <> Undefined And СвойстваПоследнегоФоновогоЗадания.Status
					= BackgroundJobState.Failed Then
					// Проверка аварийного расписания.
					If СвойстваПоследнегоФоновогоЗадания.ПопыткаЗапуска
						<= Задание.RestartCountOnFailure Then
						If СвойстваПоследнегоФоновогоЗадания.End + Задание.RestartIntervalOnFailure
							<= CurrentSessionDate() Then
						    // Повторный запуск фонового задания по регламентному заданию.
							ВыполнитьРегламентноеЗадание = True;
						EndIf;
					EndIf;
				Else
					// Проверяем стандартное расписание.
					ВыполнитьРегламентноеЗадание = Задание.Schedule.ExecutionRequired(
						CurrentSessionDate(), ?(СвойстваПоследнегоФоновогоЗадания = Undefined, '00010101',
						СвойстваПоследнегоФоновогоЗадания.Begin), ?(СвойстваПоследнегоФоновогоЗадания = Undefined,
						'00010101', СвойстваПоследнегоФоновогоЗадания.End));
				EndIf;
				If ВыполнитьРегламентноеЗадание Then
					ФоновоеЗаданиеВыполнялось = ВыполнитьРегламентноеЗадание(Задание);
				EndIf;
			EndIf;
			Status.ОкончаниеВыполненияОчередногоЗадания = CurrentSessionDate();
			СохранитьСостояниеВыполненияРегламентныхЗаданий(Status, "ОкончаниеВыполненияОчередногоЗадания");
		EndDo;
		// If последнее выполненное задание найти не удалось, тогда
		// его ID сбрасывается,
		// чтобы начать проверку регламентных заданий, начиная с первого.
		ИдентификаторПоследнегоЗадания = Undefined;
	EndDo;

#EndIf
EndProcedure

&AtServerNoContext
Function ВыполнитьРегламентноеЗадание(Val Задание)
	ЗапускВручную = False;
	МоментЗапуска = Undefined;
	МоментОкончания = Undefined;
	//@skip-warning
	SessionNumber = Undefined;
	//@skip-warning
	SessionStarted = Undefined;
//	
	СвойстваПоследнегоФоновогоЗадания = СвойстваПоследнегоФоновогоЗаданияВыполненияРегламентногоЗадания(Задание);

	If СвойстваПоследнегоФоновогоЗадания <> Undefined And СвойстваПоследнегоФоновогоЗадания.Status
		= BackgroundJobState.Active Then

		SessionNumber  = СвойстваПоследнегоФоновогоЗадания.SessionNumber;
		SessionStarted = СвойстваПоследнегоФоновогоЗадания.SessionStarted;
		Return False;
	EndIf;

	MethodName = Задание.Metadata.MethodName;
	НаименованиеФоновогоЗадания = ПодставитьПараметрыВСтроку(
		?(ЗапускВручную, NStr("ru = 'Run вручную: %1'"), NStr("ru = 'Автозапуск: %1'")),
		ПредставлениеРегламентногоЗадания(Задание));

	МоментЗапуска = ?(TypeOf(МоментЗапуска) <> Type("Date") Or Not ValueIsFilled(МоментЗапуска),
		CurrentSessionDate(), МоментЗапуска);
	
	// Creating свойств нового фонового псевдо-задания.
	СвойстваФоновогоЗадания = ПустаяТаблицаСвойствФоновыхЗаданий().Add();
	СвойстваФоновогоЗадания.Выполнять = СвойстваПоследнегоФоновогоЗадания.Выполнять;
	СвойстваФоновогоЗадания.ID  = String(New UUID);
	СвойстваФоновогоЗадания.ПопыткаЗапуска = ?(
		СвойстваПоследнегоФоновогоЗадания <> Undefined And СвойстваПоследнегоФоновогоЗадания.Status
		= BackgroundJobState.Failed, СвойстваПоследнегоФоновогоЗадания.ПопыткаЗапуска + 1, 1);
	СвойстваФоновогоЗадания.Title                      = НаименованиеФоновогоЗадания;
	СвойстваФоновогоЗадания.ScheduledJobUUID = String(Задание.UUID);
	СвойстваФоновогоЗадания.Placement                      = "\\" + ComputerName();
	СвойстваФоновогоЗадания.MethodName                         = MethodName;
	СвойстваФоновогоЗадания.Status                         = BackgroundJobState.Active;
	СвойстваФоновогоЗадания.Begin                            = МоментЗапуска;
	СвойстваФоновогоЗадания.SessionNumber                       = InfoBaseSessionNumber();

	For Each Сеанс In GetInfoBaseSessions() Do
		If Сеанс.SessionNumber = СвойстваФоновогоЗадания.SessionNumber Then
			СвойстваФоновогоЗадания.SessionStarted = Сеанс.SessionStarted;
			Break;
		EndIf;
	EndDo;
	
	// Save информации о запуске.
	СохраняемоеЗначение = New ValueStorage(СтрокаТаблицыЗначенийВСтруктуру(СвойстваФоновогоЗадания));
	CommonSettingsStorage.Save("СостояниеРегламентногоЗадания_" + String(Задание.UUID), ,
		СохраняемоеЗначение, , "");

	GetUserMessages(True);
	Try
		// Здесь нет возможности выполнения произвольного кода, т.к. метод берется из метаданных регламентного задания.
		ВыполнитьМетодКонфигурации(MethodName, Задание.Parameters);
		СвойстваФоновогоЗадания.Status = BackgroundJobState.Finished;
	Except
		СвойстваФоновогоЗадания.Status = BackgroundJobState.Failed;
		СвойстваФоновогоЗадания.ОписаниеИнформацииОбОшибке = DetailErrorDescription(ErrorInfo());
	EndTry;
	
	// Фиксация окончания выполнения метода.
	МоментОкончания = CurrentSessionDate();
	СвойстваФоновогоЗадания.End = МоментОкончания;
	СвойстваФоновогоЗадания.СообщенияПользователю = New Array;
	For Each Message In GetUserMessages() Do
		СвойстваФоновогоЗадания.СообщенияПользователю.Add(Message);
	EndDo;
	GetUserMessages(True);

	Properties = CommonSettingsStorage.Load("СостояниеРегламентногоЗадания_" + String(
		Задание.UUID), , , "");
	Properties = ?(TypeOf(Properties) = Type("ValueStorage"), Properties.Get(), Undefined);

	If TypeOf(Properties) <> Type("Structure") Or Not Properties.Property("SessionNumber") Or Not Properties.Property(
		"SessionStarted") Or (Properties.SessionNumber = СвойстваФоновогоЗадания.SessionNumber And Properties.SessionStarted
		= СвойстваФоновогоЗадания.SessionStarted) Then
		// Маловероятной перезаписи из-за отсутствия блокировки не произошло, поэтому можно записать свойства.
		СохраняемоеЗначение = New ValueStorage(СтрокаТаблицыЗначенийВСтруктуру(СвойстваФоновогоЗадания));
		CommonSettingsStorage.Save("СостояниеРегламентногоЗадания_" + String(Задание.UUID), ,
			СохраняемоеЗначение, , "");
	EndIf;

	Return True;
EndFunction

&AtServerNoContext
Function СостояниеВыполненияРегламентныхЗаданий()
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

	Status = CommonSettingsStorage.Load("СостояниеВыполненияРегламентныхЗаданий", , , "");
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
Procedure СохранитьСостояниеВыполненияРегламентныхЗаданий(Status, Val ИзмененныеСвойства = Undefined)
#If Server Or ThickClientOrdinaryApplication Then
	If ИзмененныеСвойства <> Undefined Then
		ТекущееСостояние = СостояниеВыполненияРегламентныхЗаданий();
		FillPropertyValues(ТекущееСостояние, Status, ИзмененныеСвойства);
		Status = ТекущееСостояние;
	EndIf;

	CommonSettingsStorage.Save("СостояниеВыполненияРегламентныхЗаданий", , New ValueStorage(Status), ,
		"");
#EndIf
EndProcedure

&AtServerNoContext
Function СвойстваПоследнегоФоновогоЗаданияВыполненияРегламентногоЗадания(ScheduledJob)
	ВызватьИсключениеЕслиНетПраваАдминистрирования();
	SetPrivilegedMode(True);

	ИдентификаторРегламентногоЗадания = ?(TypeOf(ScheduledJob) = Type("ScheduledJob"), String(
		ScheduledJob.UUID), ScheduledJob);
	Filter = New Structure;
	Filter.Insert("ScheduledJobUUID", ИдентификаторРегламентногоЗадания);
	Filter.Insert("ПолучитьПоследнееФоновоеЗаданиеРегламентногоЗадания");
	ТаблицаСвойствФоновыхЗаданий = СвойствФоновыхЗаданий(Filter);
	ТаблицаСвойствФоновыхЗаданий.Sort("End Asc");

	If ТаблицаСвойствФоновыхЗаданий.Count() = 0 Then
		СвойстваФоновогоЗадания = Undefined;
	ElsIf Not ValueIsFilled(ТаблицаСвойствФоновыхЗаданий[0].End) Then
		СвойстваФоновогоЗадания = ТаблицаСвойствФоновыхЗаданий[0];
	Else
		СвойстваФоновогоЗадания = ТаблицаСвойствФоновыхЗаданий[ТаблицаСвойствФоновыхЗаданий.Count() - 1];
	EndIf;

	СохраняемоеЗначение = New ValueStorage(?(СвойстваФоновогоЗадания = Undefined, Undefined,
		СтрокаТаблицыЗначенийВСтруктуру(СвойстваФоновогоЗадания)));
	CommonSettingsStorage.Save("СостояниеРегламентногоЗадания_" + ИдентификаторРегламентногоЗадания, ,
		СохраняемоеЗначение, , "");

	Return СвойстваФоновогоЗадания;
EndFunction

&AtServerNoContext
Function СвойствФоновыхЗаданий(Filter = Undefined)
	ВызватьИсключениеЕслиНетПраваАдминистрирования();
	SetPrivilegedMode(True);

	Table = ПустаяТаблицаСвойствФоновыхЗаданий();

	If Filter <> Undefined And Filter.Property("ПолучитьПоследнееФоновоеЗаданиеРегламентногоЗадания") Then
		Filter.Delete("ПолучитьПоследнееФоновоеЗаданиеРегламентногоЗадания");
		//@skip-warning
		GetLast = True;
	Else
		GetLast = False;
	EndIf;

	ScheduledJob = Undefined;

	If Filter <> Undefined And Filter.Property("ScheduledJobUUID") Then
		РегламентныеЗаданияДляОбработки = New Array;
		If Filter.ScheduledJobUUID <> "" Then
			If ScheduledJob = Undefined Then
				ScheduledJob = ScheduledJobs.FindByUUID(
					New UUID(Filter.ScheduledJobUUID));
			EndIf;
			If ScheduledJob <> Undefined Then
				РегламентныеЗаданияДляОбработки.Add(ScheduledJob);
			EndIf;
		EndIf;
	Else
		РегламентныеЗаданияДляОбработки = ScheduledJobs.GetScheduledJobs();
	EndIf;
	
	// Create и сохранение состояний регламентных заданий
	For Each ScheduledJob In РегламентныеЗаданияДляОбработки Do
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
						Properties.ОписаниеИнформацииОбОшибке = NStr(
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
Function ПустаяТаблицаСвойствФоновыхЗаданий()
	НоваяТаблица = New ValueTable;
	НоваяТаблица.Cols.Add("AtServer", New TypeDescription("Boolean"));
	НоваяТаблица.Cols.Add("ID", New TypeDescription("String"));
	НоваяТаблица.Cols.Add("Title", New TypeDescription("String"));
	НоваяТаблица.Cols.Add("Key", New TypeDescription("String"));
	НоваяТаблица.Cols.Add("Begin", New TypeDescription("Date"));
	НоваяТаблица.Cols.Add("End", New TypeDescription("Date"));
	НоваяТаблица.Cols.Add("ScheduledJobUUID", New TypeDescription("String"));
	НоваяТаблица.Cols.Add("Status", New TypeDescription("BackgroundJobState"));
	НоваяТаблица.Cols.Add("MethodName", New TypeDescription("String"));
	НоваяТаблица.Cols.Add("Placement", New TypeDescription("String"));
	НоваяТаблица.Cols.Add("ОписаниеИнформацииОбОшибке", New TypeDescription("String"));
	НоваяТаблица.Cols.Add("ПопыткаЗапуска", New TypeDescription("Number"));
	НоваяТаблица.Cols.Add("СообщенияПользователю", New TypeDescription("Array"));
	НоваяТаблица.Cols.Add("SessionNumber", New TypeDescription("Number"));
	НоваяТаблица.Cols.Add("SessionStarted", New TypeDescription("Date"));
	НоваяТаблица.Cols.Add("Выполнять", New TypeDescription("Boolean"));
	НоваяТаблица.Indexes.Add("ID, Begin");

	Return НоваяТаблица;
EndFunction

&AtServerNoContext
Function ПредставлениеРегламентногоЗадания(Val Задание) Export
	ВызватьИсключениеЕслиНетПраваАдминистрирования();

	If TypeOf(Задание) = Type("ScheduledJob") Then
		ScheduledJob = Задание;
	Else
		ScheduledJob = ScheduledJobs.FindByUUID(
			New UUID(Задание));
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
		Presentation = NStr("ru = '<не определено>'");
	EndIf;

	Return Presentation;
EndFunction

&AtServerNoContext
Procedure ВызватьИсключениеЕслиНетПраваАдминистрирования() Export

	If Not PrivilegedMode() Then
		VerifyAccessRights("Администрирование", Metadata);
	EndIf;

EndProcedure

&AtClientAtServerNoContext
Function ПодставитьПараметрыВСтроку(Val СтрокаПодстановки, Val Параметр1, Val Параметр2 = Undefined,
	Val Параметр3 = Undefined, Val Параметр4 = Undefined, Val Параметр5 = Undefined,
	Val Параметр6 = Undefined, Val Параметр7 = Undefined, Val Параметр8 = Undefined,
	Val Параметр9 = Undefined) Export

	СтрокаПодстановки = StrReplace(СтрокаПодстановки, "%1", Параметр1);
	СтрокаПодстановки = StrReplace(СтрокаПодстановки, "%2", Параметр2);
	СтрокаПодстановки = StrReplace(СтрокаПодстановки, "%3", Параметр3);
	СтрокаПодстановки = StrReplace(СтрокаПодстановки, "%4", Параметр4);
	СтрокаПодстановки = StrReplace(СтрокаПодстановки, "%5", Параметр5);
	СтрокаПодстановки = StrReplace(СтрокаПодстановки, "%6", Параметр6);
	СтрокаПодстановки = StrReplace(СтрокаПодстановки, "%7", Параметр7);
	СтрокаПодстановки = StrReplace(СтрокаПодстановки, "%8", Параметр8);
	СтрокаПодстановки = StrReplace(СтрокаПодстановки, "%9", Параметр9);

	Return СтрокаПодстановки;
EndFunction

&AtClientAtServerNoContext
Procedure ВыполнитьМетодКонфигурации(Val MethodName, Val Parameters = Undefined)

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
Function СтрокаТаблицыЗначенийВСтруктуру(ValueTableRow)

	Structure = New Structure;
	For Each Column In ValueTableRow.Owner().Cols Do
		Structure.Insert(Column.Name, ValueTableRow[Column.Name]);
	EndDo;

	Return Structure;

EndFunction

#EndRegion