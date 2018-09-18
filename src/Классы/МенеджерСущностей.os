#Использовать asserts
#Использовать reflector

// Хранит данные о сущностях, типах реквизитов
Перем МодельДанных;

// Хранит коннектор к БД, транслирующий команды менеджера сущностей в запросы к БД
Перем Коннектор;

Процедура ПриСозданииОбъекта(ТипКоннектора)
	ПроверитьПоддержкуИнтерфейсаКоннектора(ТипКоннектора);

	МодельДанных = Новый Соответствие;

	Коннектор = Новый(ТипКоннектора);
	Коннектор.Открыть();
КонецПроцедуры

Процедура ДобавитьСущностьВМодель(ТипСущности) Экспорт
	ПроверитьЧтоКлассЯвляетсяСущностью(ТипСущности);
	
	ОбъектМодели = Новый ОбъектМодели(ТипСущности);
	МодельДанных.Вставить(ТипСущности, ОбъектМодели);
	
	Коннектор.ИнициализироватьТаблицу(ОбъектМодели);

КонецПроцедуры

Процедура Сохранить(Сущность) Экспорт
	ТипСущности = ТипЗнч(Сущность);

	ПроверитьЧтоКлассЯвляетсяСущностью(ТипСущности);
	ПроверитьЧтоТипСущностиЗарегистрированВМодели(ТипСущности);
	ПроверитьНеобходимостьЗаполненияИдентификатора(Сущность);

	ОбъектМодели = МодельДанных.Получить(ТипСущности);
	
	Коннектор.Сохранить(ОбъектМодели, Сущность);
КонецПроцедуры

Процедура Закрыть() Экспорт
	Коннектор.Закрыть();
КонецПроцедуры

Процедура НачатьТранзакцию() Экспорт
	Коннектор.НачатьТранзакцию();
КонецПроцедуры

Процедура ЗафиксироватьТранзакцию() Экспорт
	Коннектор.ЗафиксироватьТранзакцию();
КонецПроцедуры

Функция ПолучитьКоннектор() Экспорт
	Возврат Коннектор;
КонецФункции

// <Описание процедуры>
//
// Параметры:
//   ТипКоннектора - Тип - Тип, проверяемый на реализацию интерфейса
//
Процедура ПроверитьПоддержкуИнтерфейсаКоннектора(ТипКоннектора)
	
	// TODO: Пока не поддерживается работа рефлектора для типов-сценариев, инициализируем класс
	ЭкземплярКоннектора = Новый(ТипКоннектора);
	
	ИнтерфейсКоннектор = Новый ИнтерфейсОбъекта;
	ИнтерфейсКоннектор
		.ПроцедураИнтерфейса("Открыть")
		.ПроцедураИнтерфейса("НачатьТранзакцию")
		.ПроцедураИнтерфейса("ЗафиксироватьТранзакцию")
		.ПроцедураИнтерфейса("ИнициализироватьТаблицу", 1)
		.ПроцедураИнтерфейса("Сохранить", 2)
		.ПроцедураИнтерфейса("Закрыть");

	РефлекторОбъекта = Новый РефлекторОбъекта(ЭкземплярКоннектора);
	ПоддерживаетсяИнтерфейсКоннектора = РефлекторОбъекта.РеализуетИнтерфейс(ИнтерфейсКоннектор);
	
	Ожидаем.Что(
		ПоддерживаетсяИнтерфейсКоннектора, 
		СтрШаблон("Тип <%1> не реализует интерфейс коннектора", ТипКоннектора)
	).ЭтоИстина();

КонецПроцедуры

// <Описание процедуры>
//
// Параметры:
//   ТипКласса - Тип - Тип, в котором проверяется наличие необходимых аннотаций.
//
Процедура ПроверитьЧтоКлассЯвляетсяСущностью(ТипКласса)
	
	// TODO: Пока не поддерживается работа рефлектора для типов-сценариев, инициализируем класс
	ЭкземплярКласса = Новый(ТипКласса);

	РефлекторОбъекта = Новый РефлекторОбъекта(ЭкземплярКласса);
	ТаблицаМетодов = РефлекторОбъекта.ПолучитьТаблицуМетодов("Сущность");
	Ожидаем.Что(ТаблицаМетодов, СтрШаблон("Класс %1 не имеет аннотации &Сущность", ТипКласса)).ИмеетДлину(1);
	
	// TODO: Работа с аннотациями через свойства
	//ТаблицаСвойств = РефлекторОбъекта.ПолучитьТаблицуСвойств("Идентификатор");
	
	МетодСущность = ТаблицаМетодов[0];
	Аннотации = МетодСущность.Аннотации;
	
	АннотацияИдентификатор = Аннотации.Найти("идентификатор", "Имя");

	Ожидаем.Что(АннотацияИдентификатор, СтрШаблон("Класс %1 не имеет поля с аннотацией &Идентификатор", ТипКласса)).Не_().Равно(Неопределено);

КонецПроцедуры

Процедура ПроверитьЧтоТипСущностиЗарегистрированВМодели(ТипСущности)
	ОбъектМодели = МодельДанных.Получить(ТипСущности);
	Ожидаем.Что(ОбъектМодели, "Тип сущности не зарегистрирован в модели данных").Не_().Равно(Неопределено);
КонецПроцедуры

Процедура ПроверитьНеобходимостьЗаполненияИдентификатора(Сущность) Экспорт
	ОбъектМодели = МодельДанных.Получить(Тип(Сущность));
	Если ОбъектМодели.Идентификатор().ГенерируемоеЗначение Тогда
		Возврат;
	КонецЕсли;
	
	ЗначениеИдентификатора = ОбъектМодели.ПолучитьЗначениеИдентификатора(Сущность);
	Ожидаем.Что(
		ЗначениеИдентификатора, СтрШаблон("Сущность с типом %1 должна иметь заполненный идентификатор", Тип(Сущность))
	).Заполнено();

КонецПроцедуры
