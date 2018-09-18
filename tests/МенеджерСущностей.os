#Использовать ".."

Перем МенеджерСущностей;

Процедура ПередЗапускомТеста() Экспорт
	МенеджерСущностей = Новый МенеджерСущностей(Тип("КоннекторSQLite"));
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
	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "tests", "fixtures", "Автор.os"), "Автор");
	МенеджерСущностей.ДобавитьСущностьВМодель(Тип("Автор"));
	Результат = МенеджерСущностей.ПолучитьКоннектор().ВыполнитьЗапрос("SELECT * FROM Авторы");
	КолонкиТаблицы = Результат.Колонки;
	Ожидаем.Что(КолонкиТаблицы[0].Имя, "Имена созданных колонок в таблице корректны").Равно("Идентификатор");
	Ожидаем.Что(КолонкиТаблицы[1].Имя, "Имена созданных колонок в таблице корректны").Равно("Имя");
	Ожидаем.Что(КолонкиТаблицы[2].Имя, "Имена созданных колонок в таблице корректны").Равно("Фамилия");
КонецПроцедуры

&Тест
Процедура СохранениеСущности() Экспорт
	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "tests", "fixtures", "Автор.os"), "Автор");
	МенеджерСущностей.ДобавитьСущностьВМодель(Тип("Автор"));
	
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
	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "tests", "fixtures", "Автор.os"), "Автор");
	МенеджерСущностей.ДобавитьСущностьВМодель(Тип("Автор"));
	
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

	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "tests", "fixtures", "СущностьБезГенерируемогоИдентификатора.os"), "СущностьБезГенерируемогоИдентификатора");
	МенеджерСущностей.ДобавитьСущностьВМодель(Тип("СущностьБезГенерируемогоИдентификатора"));
	
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
