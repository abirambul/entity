#Использовать ".."

Перем МенеджерСущностей;

Процедура ПередЗапускомТеста() Экспорт
	МенеджерСущностей = Новый МенеджерСущностей(Тип("КоннекторSQLite"), "Data Source=:memory:");
	
	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "tests", "fixtures", "Автор.os"), "Автор");
	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "tests", "fixtures", "СущностьБезГенерируемогоИдентификатора.os"), "СущностьБезГенерируемогоИдентификатора");
	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "tests", "fixtures", "СущностьСоВсемиТипамиКолонок.os"), "СущностьСоВсемиТипамиКолонок");
	
	МенеджерСущностей.ДобавитьКлассВМодель(Тип("Автор"));
	МенеджерСущностей.ДобавитьКлассВМодель(Тип("СущностьБезГенерируемогоИдентификатора"));
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
Процедура ПолучитьСущности() Экспорт

	ЗависимаяСущность = Новый СущностьСоВсемиТипамиКолонок;
	ЗависимаяСущность.Целое = 2;
	
	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 1;
	Сущность.Строка = "Строка";
	Сущность.Дата = Дата(2018, 1, 1);
	Сущность.Время = Дата(1, 1, 1, 10, 53, 20);
	Сущность.ДатаВремя = Дата(2018, 1, 1, 10, 53, 20);
	Сущность.Ссылка = ЗависимаяСущность;
	
	МенеджерСущностей.Сохранить(ЗависимаяСущность);
	МенеджерСущностей.Сохранить(Сущность);
	
	ПолученныеСущности = МенеджерСущностей.Получить(Тип("СущностьСоВсемиТипамиКолонок"));
	Ожидаем.Что(ПолученныеСущности, "Функция возвращает массив").ИмеетТип("Массив");
	Ожидаем.Что(ПолученныеСущности, "Функция нашла все сущности").ИмеетДлину(2);

	ПолученнаяСущность = ПолученныеСущности[0];

	Ожидаем.Что(ПолученнаяСущность.Целое, "ПолученнаяСущность.Целое получено корректно").Равно(Сущность.Целое);
	Ожидаем.Что(ПолученнаяСущность.Строка, "ПолученнаяСущность.Строка получено корректно").Равно(Сущность.Строка);
	Ожидаем.Что(ПолученнаяСущность.Дата, "ПолученнаяСущность.Дата получено корректно").Равно(Сущность.Дата);
	Ожидаем.Что(ПолученнаяСущность.Время, "ПолученнаяСущность.Время получено корректно").Равно(Сущность.Время);
	Ожидаем.Что(ПолученнаяСущность.ДатаВремя, "ПолученнаяСущность.ДатаВремя получено корректно").Равно(Сущность.ДатаВремя);
	Ожидаем.Что(ПолученнаяСущность.Ссылка.Целое, "ПолученнаяСущность.Ссылка получено корректно").Равно(ЗависимаяСущность.Целое);
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

// TODO: Переписать тесты с проверки на записи в таблице БД на вызов методов поиска, когда они будут реализованы
