#Использовать ".."
#Использовать "utils"

Перем МенеджерСущностей;

Процедура ПередЗапускомТеста() Экспорт

	ЗапускатьТестыPostgres = ТестовыеУтилиты.ПолучитьПеременнуюСредыИлиЗначение("TESTRUNNER_RUN_POSTGRES_TESTS", "true");
	ЗапускатьТестыSQLite = ТестовыеУтилиты.ПолучитьПеременнуюСредыИлиЗначение("TESTRUNNER_RUN_SQLITE_TESTS", "true");

	ВыполнятьСбросТаблиц = Ложь;
	Если ЗапускатьТестыSQLite = "true" Тогда
		СтрокаСоединения = "FullUri=file::memory:?cache=shared";
		//СтрокаСоединения = "Data Source=test.db";
		ТипКоннектора = Тип("КоннекторSQLite");
	ИначеЕсли ЗапускатьТестыPostgres = "true" Тогда
		Хост = ТестовыеУтилиты.ПолучитьПеременнуюСредыИлиЗначение("POSTGRES_HOST", "localhost");
		Порт = ТестовыеУтилиты.ПолучитьПеременнуюСредыИлиЗначение("POSTGRES_PORT", "5432");
		Пользователь = ТестовыеУтилиты.ПолучитьПеременнуюСредыИлиЗначение("POSTGRES_USERNAME", "postgres");
		Пароль = ТестовыеУтилиты.ПолучитьПеременнуюСредыИлиЗначение("POSTGRES_PASSWORD", "postgres");
		ИмяБД = ТестовыеУтилиты.ПолучитьПеременнуюСредыИлиЗначение("POSTGRES_DATABASE", "postgres");
		СтрокаСоединения = СтрШаблон(
			"Host=%1;Username=%2;Password=%3;Database=%4;port=%5;",
			Хост,
			Пользователь,
			Пароль,
			ИмяБД,
			Порт
		);
		ТипКоннектора = Тип("КоннекторPostgreSQL");
		ВыполнятьСбросТаблиц = Истина;
	Иначе
		ВызватьИсключение "Нет доступного коннектора для тестирования менеджера сущностей";
	КонецЕсли;
	
	МенеджерСущностей = Новый МенеджерСущностей(ТипКоннектора, СтрокаСоединения);
	
	Если ВыполнятьСбросТаблиц Тогда
		Коннектор = МенеджерСущностей.ПолучитьКоннектор();
		Коннектор.Открыть(СтрокаСоединения, Новый Массив);
		ТестовыеУтилиты.УдалитьТаблицыВБазеДанных(Коннектор);
		Коннектор.Закрыть();
	КонецЕсли;

	ПодключитьСценарий(
		ОбъединитьПути(
			ТекущийКаталог(), 
			"tests", 
			"fixtures", 
			"Автор.os"
		), 
		"Автор"
	);
	ПодключитьСценарий(
		ОбъединитьПути(
			ТекущийКаталог(), 
			"tests", 
			"fixtures", 
			"СущностьБезГенерируемогоИдентификатора.os"
		), 
		"СущностьБезГенерируемогоИдентификатора"
	);
	ПодключитьСценарий(
		ОбъединитьПути(
			ТекущийКаталог(), 
			"tests", 
			"fixtures", 
			"СущностьСоВсемиТипамиКолонок.os"
		), 
		"СущностьСоВсемиТипамиКолонок"
	);
	
	МенеджерСущностей.ДобавитьКлассВМодель(Тип("СущностьБезГенерируемогоИдентификатора"));
	МенеджерСущностей.ДобавитьКлассВМодель(Тип("Автор"));
	МенеджерСущностей.ДобавитьКлассВМодель(Тип("СущностьСоВсемиТипамиКолонок"));
	
	МенеджерСущностей.Инициализировать();

КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	МенеджерСущностей.Закрыть();
	МенеджерСущностей = Неопределено;
КонецПроцедуры

&Тест
Процедура МетодНачатьТранзакциюРаботаетБезОшибок() Экспорт
	МенеджерСущностей.НачатьТранзакцию();
КонецПроцедуры

&Тест
Процедура МетодЗафиксироватьТранзакциюРаботаетБезОшибок() Экспорт
	МенеджерСущностей.НачатьТранзакцию();
	МенеджерСущностей.ЗафиксироватьТранзакцию();
КонецПроцедуры

&Тест
Процедура МетодОтменитьТранзакциюРаботаетБезОшибок() Экспорт
	МенеджерСущностей.НачатьТранзакцию();
	МенеджерСущностей.ОтменитьТранзакцию();
КонецПроцедуры

&Тест
Процедура СозданиеТаблицыПоКлассуМодели() Экспорт
	Результат = МенеджерСущностей.ПолучитьКоннектор().ВыполнитьЗапрос("SELECT * FROM Авторы");
	КолонкиТаблицы = Результат.Колонки;
	Ожидаем.Что(КолонкиТаблицы[0].Имя, "Имена созданных колонок в таблице корректны").Равно("Идентификатор");
	Ожидаем.Что(КолонкиТаблицы[1].Имя, "Имена созданных колонок в таблице корректны").Равно("Имя");
	Ожидаем.Что(КолонкиТаблицы[2].Имя, "Имена созданных колонок в таблице корректны").Равно("Фамилия");
КонецПроцедуры

&Тест
Процедура СохранениеСущности() Экспорт
	
	Результат = МенеджерСущностей.ПолучитьКоннектор().ВыполнитьЗапрос("SELECT * FROM Авторы");
	Ожидаем.Что(Результат, "В таблице не должно быть записей").ИмеетДлину(0);
	
	СохраняемыйАвтор = Новый Автор;
	СохраняемыйАвтор.Имя = "Иван";
	СохраняемыйАвтор.ВтороеИмя = "Иванов";
	
	МенеджерСущностей.Сохранить(СохраняемыйАвтор);
	
	Результат = МенеджерСущностей.ПолучитьКоннектор().ВыполнитьЗапрос("SELECT * FROM Авторы");
	Ожидаем.Что(Результат, "В таблице должен был сохраниться новый автор").ИмеетДлину(1);
	
	Ожидаем
		.Что(СохраняемыйАвтор.ВнутреннийИдентификатор, "Заполнился и сохранился новый идентификатор сохраняемого автора")
		.Равно(1);
	
КонецПроцедуры

&Тест
Процедура ОбновлениеСущности() Экспорт
	
	СохраняемыйАвтор = Новый Автор;
	СохраняемыйАвтор.Имя = "Иван";
	СохраняемыйАвтор.ВтороеИмя = "Иванов";
	
	МенеджерСущностей.Сохранить(СохраняемыйАвтор);
	
	ПереопределенныйАвтор = Новый Автор;
	ПереопределенныйАвтор.ВнутреннийИдентификатор = СохраняемыйАвтор.ВнутреннийИдентификатор;
	ПереопределенныйАвтор.Имя = "Петр";
	ПереопределенныйАвтор.ВтороеИмя = "Иванов";

	МенеджерСущностей.Сохранить(ПереопределенныйАвтор);
	
	Результат = МенеджерСущностей.ПолучитьКоннектор().ВыполнитьЗапрос("SELECT * FROM Авторы");
	Ожидаем.Что(Результат, "В таблице должен был сохраниться новый автор").ИмеетДлину(1);
	Ожидаем.Что(Результат[0].Имя, "Имя в БД обновлено").Равно("Петр");
	Ожидаем.Что(Результат[0].Идентификатор, "ИД в БД не изменился").Равно(СохраняемыйАвтор.ВнутреннийИдентификатор);

КонецПроцедуры

&Тест
Процедура СущностьСПустымНеАвтоинкрементнымИдентификаторомНеСохраняется() Экспорт

	Сущность = Новый СущностьБезГенерируемогоИдентификатора;
	
	ПараметрыМетодаСохранить = Новый Массив;
	ПараметрыМетодаСохранить.Добавить(Сущность);
	Ожидаем
		.Что(МенеджерСущностей)
		.Метод("Сохранить", ПараметрыМетодаСохранить)
		.ВыбрасываетИсключение("Сущность с типом СущностьБезГенерируемогоИдентификатора должна иметь заполненный идентификатор");
		
	Сущность.ВнутреннийИдентификатор = 1;
	МенеджерСущностей.Сохранить(Сущность);

КонецПроцедуры

&Тест
Процедура СсылкаНаСущность() Экспорт
	ВнешняяСущность = Новый СущностьБезГенерируемогоИдентификатора;
	ВнешняяСущность.ВнутреннийИдентификатор = 123;
	
	МенеджерСущностей.Сохранить(ВнешняяСущность);
	
	СохраняемыйАвтор = Новый Автор;
	СохраняемыйАвтор.Имя = "Иван";
	СохраняемыйАвтор.ВтороеИмя = "Иванов";
	СохраняемыйАвтор.ВнешняяСущность = ВнешняяСущность;
	
	МенеджерСущностей.Сохранить(СохраняемыйАвтор);
	
	Результат = МенеджерСущностей.ПолучитьКоннектор().ВыполнитьЗапрос("SELECT * FROM Авторы");
	Ожидаем.Что(Результат[0].ВнешняяСущность, "В колонку сохранился идентификатор внешней сущности").Равно(ВнешняяСущность.ВнутреннийИдентификатор);
КонецПроцедуры

&Тест
Процедура СохранениеКоллекций() Экспорт
	ЗависимаяСущность = Новый СущностьСоВсемиТипамиКолонок;
	ЗависимаяСущность.Целое = 123;
	
	ЗависимыйМассив = Новый Массив;
	ЗависимыйМассив.Добавить("Строка1");
	ЗависимыйМассив.Добавить("Строка2");

	ЗависимаяСтруктура = Новый Структура();
	ЗависимаяСтруктура.Вставить("Ключ1", "Значение1");
	ЗависимаяСтруктура.Вставить("Ключ2", "Значение2");

	МассивСсылок = Новый Массив;
	МассивСсылок.Добавить(ЗависимаяСущность);
	
	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 1;
	Сущность.Массив = ЗависимыйМассив;
	Сущность.Структура = ЗависимаяСтруктура;
	Сущность.МассивСсылок = МассивСсылок;

	МенеджерСущностей.Сохранить(ЗависимаяСущность);
	МенеджерСущностей.Сохранить(Сущность);
	
	ТекстЗапроса = СтрШаблон(
		"SELECT * FROM %1 WHERE ref = %2",
		"ВсеТипыКолонок_Массив",
		Сущность.Целое
	);
	РезультатЗапроса = МенеджерСущностей.ПолучитьКоннектор().ВыполнитьЗапрос(ТекстЗапроса);
	Ожидаем.Что(РезультатЗапроса, "Сохранилось две строки зависимого массива").ИмеетДлину(2);
	ДанныеИзБазы1 = РезультатЗапроса[0];
	Ожидаем.Что(РезультатЗапроса[0].key, "Сохранился ключ первого элемента массива").Равно(0);
	Ожидаем.Что(РезультатЗапроса[0].value, "Сохранилось значение первого элемента массива").Равно(ЗависимыйМассив[0]);
	
	Ожидаем.Что(РезультатЗапроса[1].key, "Сохранился ключ второго элемента массива").Равно(1);
	Ожидаем.Что(РезультатЗапроса[1].value, "Сохранилось значение второго элемента массива").Равно(ЗависимыйМассив[1]);
	
	ТекстЗапроса = СтрШаблон(
		"SELECT * FROM %1 WHERE ref = %2",
		"ВсеТипыКолонок_Структура",
		Сущность.Целое
	);
	РезультатЗапроса = МенеджерСущностей.ПолучитьКоннектор().ВыполнитьЗапрос(ТекстЗапроса);
	Ожидаем.Что(РезультатЗапроса, "Сохранилось две строки зависимой структуры").ИмеетДлину(2);
	ДанныеИзБазы1 = РезультатЗапроса[0];
	Ожидаем.Что(РезультатЗапроса[0].key, "Сохранился ключ первого элемента структуры").Равно("Ключ1");
	Ожидаем.Что(РезультатЗапроса[0].value, "Сохранилось значение первого элемента структуры").Равно(ЗависимаяСтруктура.Ключ1);
	
	Ожидаем.Что(РезультатЗапроса[1].key, "Сохранился ключ второго элемента структуры").Равно("Ключ2");
	Ожидаем.Что(РезультатЗапроса[1].value, "Сохранилось значение второго элемента структуры").Равно(ЗависимаяСтруктура.Ключ2);
	
	ТекстЗапроса = СтрШаблон(
		"SELECT * FROM %1 WHERE ref = %2",
		"ВсеТипыКолонок_МассивСсылок",
		Сущность.Целое
	);
	РезультатЗапроса = МенеджерСущностей.ПолучитьКоннектор().ВыполнитьЗапрос(ТекстЗапроса);
	Ожидаем.Что(РезультатЗапроса, "Сохранилось одна строка зависимого массива ссылок").ИмеетДлину(1);
	ДанныеИзБазы1 = РезультатЗапроса[0];
	Ожидаем.Что(РезультатЗапроса[0].key, "Сохранился ключ первого элемента массива ссылок").Равно(0);
	Ожидаем.Что(РезультатЗапроса[0].value, "Сохранилось значение первого элемента массива ссылок").Равно(МассивСсылок[0].Целое);
	
КонецПроцедуры

&Тест
Процедура ПолучитьСущности() Экспорт

	ЗависимаяСущность = Новый СущностьСоВсемиТипамиКолонок;
	ЗависимаяСущность.Целое = 2;

	ЗависимыйМассив = Новый Массив;
	ЗависимыйМассив.Добавить("Строка1");
	ЗависимыйМассив.Добавить("Строка2");
	
	ЗависимаяСтруктура = Новый Структура();
	ЗависимаяСтруктура.Вставить("Ключ1", "Значение1");
	ЗависимаяСтруктура.Вставить("Ключ2", "Значение2");
	
	МассивСсылок = Новый Массив;
	МассивСсылок.Добавить(ЗависимаяСущность);
		
	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 1;
	Сущность.Строка = "Строка";
	Сущность.Дата = Дата(2018, 1, 1);
	Сущность.Время = Дата(1, 1, 1, 10, 53, 20);
	Сущность.ДатаВремя = Дата(2018, 1, 1, 10, 53, 20);
	Сущность.Ссылка = ЗависимаяСущность;
	Сущность.Массив = ЗависимыйМассив;
	Сущность.Структура = ЗависимаяСтруктура;
	Сущность.МассивСсылок = МассивСсылок;
	
	МенеджерСущностей.Сохранить(ЗависимаяСущность);
	МенеджерСущностей.Сохранить(Сущность);
	
	ПолученныеСущности = МенеджерСущностей.Получить(Тип("СущностьСоВсемиТипамиКолонок"));
	Ожидаем.Что(ПолученныеСущности, "Функция возвращает массив").ИмеетТип("Массив");
	Ожидаем.Что(ПолученныеСущности, "Функция нашла все сущности").ИмеетДлину(2);

	ПолученнаяСущность = МенеджерСущностей.ПолучитьОдно(Тип("СущностьСоВсемиТипамиКолонок"), Сущность.Целое);

	Ожидаем.Что(ПолученнаяСущность.Целое, "ПолученнаяСущность.Целое получено корректно").Равно(Сущность.Целое);
	Ожидаем.Что(ПолученнаяСущность.Строка, "ПолученнаяСущность.Строка получено корректно").Равно(Сущность.Строка);
	Ожидаем.Что(ПолученнаяСущность.Дата, "ПолученнаяСущность.Дата получено корректно").Равно(Сущность.Дата);
	Ожидаем.Что(ПолученнаяСущность.Время, "ПолученнаяСущность.Время получено корректно").Равно(Сущность.Время);
	Ожидаем.Что(ПолученнаяСущность.ДатаВремя, "ПолученнаяСущность.ДатаВремя получено корректно").Равно(Сущность.ДатаВремя);
	Ожидаем.Что(ПолученнаяСущность.Ссылка.Целое, "ПолученнаяСущность.Ссылка получено корректно").Равно(ЗависимаяСущность.Целое);
	Ожидаем.Что(ПолученнаяСущность.Массив, "ПолученнаяСущность.Массив проинициализировано массивом").ИмеетТип("Массив");
	Ожидаем.Что(ПолученнаяСущность.Структура, "ПолученнаяСущность.Структура проинициализировано структурой").ИмеетТип("Структура");
	Ожидаем.Что(ПолученнаяСущность.Массив, "ПолученнаяСущность.Массив имеет корректное количество элементов").ИмеетДлину(ЗависимыйМассив.Количество());
	Ожидаем.Что(ПолученнаяСущность.Структура, "ПолученнаяСущность.Структура имеет корректное количество элементов").ИмеетДлину(ЗависимаяСтруктура.Количество());
	Ожидаем.Что(ПолученнаяСущность.МассивСсылок, "ПолученнаяСущность.МассивСсылок проинициализированно массивом").ИмеетТип("Массив");
	Ожидаем.Что(ПолученнаяСущность.МассивСсылок, "ПолученнаяСущность.МассивСсылок имеет корректное количество элементов").ИмеетДлину(МассивСсылок.Количество());
	Ожидаем.Что(ПолученнаяСущность.МассивСсылок[0], "ПолученнаяСущность.МассивСсылок содержит идентификатор зависимой сущности").Равно(ЗависимаяСущность.Целое);
КонецПроцедуры

&Тест
Процедура ПоискСущностей() Экспорт
	
	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 1;
	Сущность.Строка = "Строка";
	Сущность.Дата = Дата(2018, 1, 1);

	МенеджерСущностей.Сохранить(Сущность);
	
	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 2;
	Сущность.Строка = "Строка";
	Сущность.Дата = Дата(2018, 2, 2);
	
	МенеджерСущностей.Сохранить(Сущность);
	
	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 3;
	Сущность.Строка = "Строка";
	Сущность.Дата = Дата(2018, 2, 2);
	
	МенеджерСущностей.Сохранить(Сущность);
	
	Отбор = Новый Соответствие;
	Отбор.Вставить("Строка", "Строка");
	Отбор.Вставить("Дата", Дата(2018, 2, 2));

	НайденныеСущности = МенеджерСущностей.Получить(Тип("СущностьСоВсемиТипамиКолонок"), Отбор);
	Ожидаем.Что(НайденныеСущности, "Получены две сущности").ИмеетДлину(2);
	Ожидаем.Что(НайденныеСущности[0].Целое, "Нашлись корректные сущности").Равно(2);
	Ожидаем.Что(НайденныеСущности[1].Целое, "Нашлись корректные сущности").Равно(3);

	Отбор = Новый Соответствие;
	Отбор.Вставить("Строка", "Строка");

	НайденныеСущности = МенеджерСущностей.Получить(Тип("СущностьСоВсемиТипамиКолонок"), Отбор);
	Ожидаем.Что(НайденныеСущности, "Получены все сущности").ИмеетДлину(3);

КонецПроцедуры

&Тест
Процедура ПоискСоСложнымОтбором() Экспорт
	
	Сущность = Новый СущностьБезГенерируемогоИдентификатора;
	Сущность.ВнутреннийИдентификатор = 1;
	МенеджерСущностей.Сохранить(Сущность);
	
	Сущность = Новый СущностьБезГенерируемогоИдентификатора;
	Сущность.ВнутреннийИдентификатор = 2;
	МенеджерСущностей.Сохранить(Сущность);
	
	Сущность = Новый СущностьБезГенерируемогоИдентификатора;
	Сущность.ВнутреннийИдентификатор = 3;
	МенеджерСущностей.Сохранить(Сущность);
	
	ЭлементОтбора = Новый ЭлементОтбора("ВнутреннийИдентификатор", ВидСравнения.Больше, 1);
	НайденныеСтроки = МенеджерСущностей.Получить(Тип("СущностьБезГенерируемогоИдентификатора"), ЭлементОтбора);
	Ожидаем.Что(НайденныеСтроки, "Сущности нашлись с одним отбором").ИмеетДлину(2);
	
	ОднаСущность = МенеджерСущностей.ПолучитьОдно(Тип("СущностьБезГенерируемогоИдентификатора"), ЭлементОтбора);
	Ожидаем.Что(ОднаСущность, "Сущность нашлась по сложному отбору").Не_().Равно(Неопределено);
	
	МассивОтборов = Новый Массив;
	МассивОтборов.Добавить(Новый ЭлементОтбора("ВнутреннийИдентификатор", ВидСравнения.Больше, 1));
	МассивОтборов.Добавить(Новый ЭлементОтбора("ВнутреннийИдентификатор", ВидСравнения.Меньше, 3));
	
	НайденныеСтроки = МенеджерСущностей.Получить(Тип("СущностьБезГенерируемогоИдентификатора"), МассивОтборов);
	Ожидаем.Что(НайденныеСтроки, "Сущность нашлась с массивов отборов").ИмеетДлину(1);
	
	ОднаСущность = МенеджерСущностей.ПолучитьОдно(Тип("СущностьБезГенерируемогоИдентификатора"), МассивОтборов);
	Ожидаем.Что(ОднаСущность, "Сущность нашлась по сложному отбору").Не_().Равно(Неопределено);
	
	МассивОтборов = Новый Массив;
	МассивОтборов.Добавить(Новый ЭлементОтбора("ВнутреннийИдентификатор", ВидСравнения.Меньше, 1));
	МассивОтборов.Добавить(Новый ЭлементОтбора("ВнутреннийИдентификатор", ВидСравнения.Больше, 3));
	
	ОднаСущность = МенеджерСущностей.ПолучитьОдно(Тип("СущностьБезГенерируемогоИдентификатора"), МассивОтборов);
	Ожидаем.Что(ОднаСущность, "Сущность не нашлась по противоречащему отбору").Равно(Неопределено);
	
КонецПроцедуры

&Тест
Процедура ПолучитьСущность() Экспорт
		
	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 1;
	
	МенеджерСущностей.Сохранить(Сущность);
	
	ПолученнаяСущность = МенеджерСущностей.ПолучитьОдно(Тип("СущностьСоВсемиТипамиКолонок"), 1);
	Ожидаем.Что(ПолученнаяСущность, "Функция нашла сущность").Не_().Равно(Неопределено);
	Ожидаем.Что(ПолученнаяСущность, "Функция нашла сущность нужного типа").ИмеетТип("СущностьСоВсемиТипамиКолонок");
	
	Ожидаем.Что(ПолученнаяСущность.Целое, "ПолученнаяСущность.Целое получено корректно").Равно(Сущность.Целое);

КонецПроцедуры

&Тест
Процедура УдалитьСущность() Экспорт
	
	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 1;
	МенеджерСущностей.Сохранить(Сущность);

	МенеджерСущностей.Удалить(Сущность);
	
	ПолученнаяСущность = МенеджерСущностей.ПолучитьОдно(Тип("СущностьСоВсемиТипамиКолонок"), 1);
	Ожидаем.Что(ПолученнаяСущность, "Сущность удалилась").Равно(Неопределено);

КонецПроцедуры

&Тест
Процедура СинхронизацияЭкземпляровСущностей() Экспорт

	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 1;
	Сущность.Ссылка = Сущность;
	МенеджерСущностей.Сохранить(Сущность);
	
	Сущность1 = МенеджерСущностей.ПолучитьОдно(Тип("СущностьСоВсемиТипамиКолонок"), 1);
	Сущность2 = МенеджерСущностей.ПолучитьОдно(Тип("СущностьСоВсемиТипамиКолонок"), 1);
	
	Ожидаем.Что(Сущность1, "Ссылки на сущности совпадают").Равно(Сущность2);
	
	Сущность1.Целое = 2;
	Ожидаем.Что(Сущность2.Целое, "Поля сущностей синхронизированы").Равно(Сущность1.Целое);

	Ожидаем.Что(Сущность1.Ссылка, "Сущность ссылается сама на себя").Равно(Сущность1);

КонецПроцедуры

// TODO: Переписать тесты с проверки на записи в таблице БД на вызов методов поиска, когда они будут реализованы
