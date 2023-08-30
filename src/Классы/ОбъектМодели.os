#Использовать reflector
#Использовать strings

Перем ТипСущности;
Перем ИмяТаблицы;
Перем Колонки;
Перем ПодчиненныеТаблицы;
// TODO: Первичный ключ из нескольких полей?
Перем Идентификатор;

Перем МодельДанных;

Перем Рефлектор;

Процедура ПриСозданииОбъекта(ПТипСущности, ПМодельДанных)
	
	МодельДанных = ПМодельДанных;
	ТипСущности = ПТипСущности;
	ЗаполнитьКолонки();
	ЗаполнитьПодчиненныеТаблицы();
	Рефлектор = Новый Рефлектор;
	
КонецПроцедуры

Функция ИмяТаблицы() Экспорт
	Возврат ИмяТаблицы;
КонецФункции

Функция Колонки() Экспорт
	Возврат Колонки.Скопировать();
КонецФункции

Функция ПодчиненныеТаблицы() Экспорт
	Возврат ПодчиненныеТаблицы.Скопировать();
КонецФункции

// @internal
// TODO: вынести отсюда. Возможно стоит разработать отдельный служебный билдер Объекта модели,
// вытащив заполнение из конструктора в этот билдер, а в конструктор передавать уже готовые для сохранения
// в объект данные.
//
Функция Служебный_Колонки() Экспорт
	Возврат Колонки;
КонецФункции

// @internal
Процедура Служебный_ИмяТаблицы(ПИмяТаблицы) Экспорт
	ИмяТаблицы = ПИмяТаблицы;
КонецПроцедуры

Функция Идентификатор() Экспорт
	Возврат Новый ФиксированнаяСтруктура(Идентификатор);
КонецФункции

Функция МодельДанных() Экспорт
	Возврат МодельДанных;
КонецФункции

Функция ТипСущности() Экспорт
	Возврат ТипСущности;
КонецФункции

Функция ПолучитьЗначениеИдентификатора(Сущность) Экспорт
	ЗначениеИдентификатора = ПолучитьЗначениеПоля(Сущность, Идентификатор().ИмяПоля);
	Возврат ЗначениеИдентификатора;
КонецФункции

Функция ПолучитьПриведенноеЗначениеПоля(Сущность, ИмяПоля) Экспорт
	ЗначениеПоля = ПолучитьЗначениеПоля(Сущность, ИмяПоля);
	
	Колонка = Колонки().Найти(ИмяПоля, "ИмяПоля");
	
	Если Колонка.ТипКолонки = ТипыКолонок.Ссылка Тогда
		ОбъектМоделиСсылки = МодельДанных.Получить(Колонка.ТипСсылки);
		Если ЗначениеПоля = Неопределено Тогда
			ЗначениеПоля = ОбъектМоделиСсылки.ПривестиЗначениеПоля(ЗначениеПоля, ОбъектМоделиСсылки.Идентификатор().ИмяПоля);
		Иначе
			ЗначениеПоля = ОбъектМоделиСсылки.ПолучитьЗначениеИдентификатора(ЗначениеПоля);
		КонецЕсли;
	ИначеЕсли Колонка.ТипКолонки = ТипыКолонок.ДвоичныеДанные Тогда
		// Просто ничего не делаем, все работает само
	Иначе
		ЗначениеПоля = ПривестиЗначениеПоля(ЗначениеПоля, ИмяПоля);
	КонецЕсли;
	
	Возврат ЗначениеПоля;
КонецФункции

Процедура УстановитьЗначениеКолонкиВПоле(Сущность, ИмяКолонки, ЗначениеПоля) Экспорт
	
	Колонка = Колонки().Найти(ИмяКолонки, "ИмяКолонки");
	
	Если Колонка.ТипКолонки = ТипыКолонок.Ссылка Тогда
		УстанавливаемоеЗначениеПоля = ЗначениеПоля;
	Иначе
		УстанавливаемоеЗначениеПоля = ВыполнитьПриведениеЗначения(Колонка, ЗначениеПоля);
	КонецЕсли;
	
	Рефлектор.УстановитьСвойство(Сущность, Колонка.ИмяПоля, УстанавливаемоеЗначениеПоля);
	
КонецПроцедуры

Процедура УстановитьЗначениеПодчиненнойТаблицыВПоле(Сущность, ИмяПоля, ЗначениеПоля) Экспорт
	Рефлектор.УстановитьСвойство(Сущность, ИмяПоля, ЗначениеПоля);
КонецПроцедуры

Функция ПривестиЗначениеПоля(ЗначениеПоля, ИмяПоля) Экспорт

	Колонка = Колонки().Найти(ИмяПоля, "ИмяПоля");
	Возврат ВыполнитьПриведениеЗначения(Колонка, ЗначениеПоля);

КонецФункции

Функция ПолучитьЗначениеПоля(Сущность, ИмяПоля) Экспорт
	ЗначениеПоля = Рефлектор.ПолучитьСвойство(Сущность, ИмяПоля);
	Возврат ЗначениеПоля;
КонецФункции

Процедура ЗаполнитьКолонки()
	
	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка");
	ОписаниеТиповБулево = Новый ОписаниеТипов("Булево");
	
	ИмяТаблицы = "";
	Колонки = Новый ТаблицаЗначений;
	Колонки.Колонки.Добавить("ИмяПоля", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ИмяКолонки", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ТипКолонки", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ГенерируемоеЗначение", ОписаниеТиповБулево);
	Колонки.Колонки.Добавить("Идентификатор", ОписаниеТиповБулево);
	Колонки.Колонки.Добавить("ТипСсылки");
	
	РефлекторОбъекта = Новый РефлекторОбъекта(ТипСущности);
	МетодСущность = РефлекторОбъекта.ПолучитьТаблицуМетодов("Сущность", Ложь)[0];
	
	АннотацияСущность = МетодСущность.Аннотации.Найти("сущность", "Имя");
	ПараметрИмяТаблицы = АннотацияСущность.Параметры.Найти("ИмяТаблицы", "Имя");
	ИмяТаблицы = ?(ПараметрИмяТаблицы = Неопределено, Строка(ТипСущности), ПараметрИмяТаблицы.Значение);
	
	ТаблицаСвойств = РефлекторОбъекта.ПолучитьТаблицуСвойств();
	Для Каждого Свойство Из ТаблицаСвойств Цикл
		Аннотации = Свойство.Аннотации;
		АннотацияПодчиненнаяТаблица = Аннотации.Найти("ПодчиненнаяТаблица", "Имя");
		Если АннотацияПодчиненнаяТаблица <> Неопределено Тогда
			Продолжить;
		КонецЕсли;

		ДанныеОКолонке = НовыйДанныеОКолонке();
		ДанныеОКолонке.ИмяПоля = Свойство.Имя;
		
		АннотацияКолонка = Аннотации.Найти("Колонка", "Имя");
		ЗаполнитьИмяКолонки(ДанныеОКолонке, АннотацияКолонка);
		ЗаполнитьТипКолонки(ДанныеОКолонке, АннотацияКолонка);
		ЗаполнитьТипСсылки(ДанныеОКолонке, АннотацияКолонка);
		
		Если Аннотации.Найти("Идентификатор", "Имя") <> Неопределено Тогда
			ДанныеОКолонке.Идентификатор = Истина;
			Идентификатор = ДанныеОКолонке;
		КонецЕсли;
		
		Если Аннотации.Найти("ГенерируемоеЗначение", "Имя") <> Неопределено Тогда
			ДанныеОКолонке.ГенерируемоеЗначение = Истина;
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(Колонки.Добавить(), ДанныеОКолонке);
	КонецЦикла;

КонецПроцедуры

Процедура ЗаполнитьПодчиненныеТаблицы()
	
	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка");
	ОписаниеТиповБулево = Новый ОписаниеТипов("Булево");
	
	ПодчиненныеТаблицы = Новый ТаблицаЗначений;
	ПодчиненныеТаблицы.Колонки.Добавить("ИмяПоля", ОписаниеТиповСтрока);
	ПодчиненныеТаблицы.Колонки.Добавить("ИмяТаблицы", ОписаниеТиповСтрока);
	ПодчиненныеТаблицы.Колонки.Добавить("ТипТаблицы", ОписаниеТиповСтрока);
	ПодчиненныеТаблицы.Колонки.Добавить("ТипЭлемента");
	ПодчиненныеТаблицы.Колонки.Добавить("КаскадноеЧтение", ОписаниеТиповБулево);
	
	РефлекторОбъекта = Новый РефлекторОбъекта(ТипСущности);
	ТаблицаСвойств = РефлекторОбъекта.ПолучитьТаблицуСвойств("ПодчиненнаяТаблица");

	Для Каждого Свойство Из ТаблицаСвойств Цикл
		ДанныеОПодчиненнойТаблице = НовыйДанныеОПодчиненнойТаблице();
		ДанныеОПодчиненнойТаблице.ИмяПоля = Свойство.Имя;
		
		Аннотации = Свойство.Аннотации;
		АннотацияПодчиненнаяТаблица = Аннотации.Найти("ПодчиненнаяТаблица", "Имя");

		ЗаполнитьИмяПодчиненнойТаблицы(ДанныеОПодчиненнойТаблице, АннотацияПодчиненнаяТаблица);
		ЗаполнитьТипТаблицы(ДанныеОПодчиненнойТаблице, АннотацияПодчиненнаяТаблица);
		ЗаполнитьТипЭлемента(ДанныеОПодчиненнойТаблице, АннотацияПодчиненнаяТаблица);
		ЗаполнитьКаскадноеЧтение(ДанныеОПодчиненнойТаблице, АннотацияПодчиненнаяТаблица);
				
		ЗаполнитьЗначенияСвойств(ПодчиненныеТаблицы.Добавить(), ДанныеОПодчиненнойТаблице);
	КонецЦикла;

КонецПроцедуры

Функция НовыйДанныеОКолонке()
	ДанныеОКолонке = Новый Структура;
	ДанныеОКолонке.Вставить("ИмяПоля", "");
	ДанныеОКолонке.Вставить("ИмяКолонки", "");
	ДанныеОКолонке.Вставить("ТипКолонки", "");
	ДанныеОКолонке.Вставить("ГенерируемоеЗначение", Ложь);
	ДанныеОКолонке.Вставить("Идентификатор", Ложь);
	ДанныеОКолонке.Вставить("ТипСсылки");
	Возврат ДанныеОКолонке;
КонецФункции

Функция НовыйДанныеОПодчиненнойТаблице()
	ДанныеОПодчиненнойТаблице = Новый Структура;
	ДанныеОПодчиненнойТаблице.Вставить("ИмяПоля", "");
	ДанныеОПодчиненнойТаблице.Вставить("ИмяТаблицы", "");
	ДанныеОПодчиненнойТаблице.Вставить("ТипТаблицы");
	ДанныеОПодчиненнойТаблице.Вставить("ТипЭлемента");
	ДанныеОПодчиненнойТаблице.Вставить("КаскадноеЧтение", Ложь);
	
	Возврат ДанныеОПодчиненнойТаблице;
КонецФункции

Процедура ЗаполнитьИмяКолонки(ДанныеОКолонке, АннотацияКолонка)
	
	ЗначениеПоУмолчанию = ДанныеОКолонке.ИмяПоля;
	
	Если АннотацияКолонка = Неопределено ИЛИ АннотацияКолонка.Параметры = Неопределено Тогда
		ИмяКолонки = ЗначениеПоУмолчанию;
	Иначе
		ПараметрИмяКолонки = АннотацияКолонка.Параметры.Найти("Имя", "Имя");
		Если ПараметрИмяКолонки = Неопределено ИЛИ ПараметрИмяКолонки.Значение = Неопределено Тогда
			ИмяКолонки = ЗначениеПоУмолчанию;
		Иначе
			ИмяКолонки = ПараметрИмяКолонки.Значение;
		КонецЕсли;
	КонецЕсли;
	
	ДанныеОКолонке.ИмяКолонки = ИмяКолонки;
КонецПроцедуры

Процедура ЗаполнитьИмяПодчиненнойТаблицы(ДанныеОПодчиненнойТаблице, АннотацияПодчиненнаяТаблица)
	
	ПараметрИмяТаблицы = АннотацияПодчиненнаяТаблица.Параметры.Найти("ИмяТаблицы", "Имя");
	Если ПараметрИмяТаблицы = Неопределено Тогда
		ДанныеОПодчиненнойТаблице.ИмяТаблицы = СтрШаблон(
			"%1_%2",
			Строка(ТипСущности),
			ДанныеОПодчиненнойТаблице.ИмяПоля
		);
	Иначе
		ДанныеОПодчиненнойТаблице.ИмяТаблицы = ПараметрИмяТаблицы.Значение;
	КонецЕсли;

КонецПроцедуры

Процедура ЗаполнитьТипКолонки(ДанныеОКолонке, АннотацияКолонка)
	
	ЗначениеПоУмолчанию = ТипыКолонок.Строка;
	
	Если АннотацияКолонка = Неопределено ИЛИ АннотацияКолонка.Параметры = Неопределено Тогда
		ТипКолонки = ЗначениеПоУмолчанию;
	Иначе
		ПараметрТипКолонки = АннотацияКолонка.Параметры.Найти("Тип", "Имя");
		Если ПараметрТипКолонки = Неопределено ИЛИ ПараметрТипКолонки.Значение = Неопределено Тогда
			ТипКолонки = ЗначениеПоУмолчанию;
		Иначе
			ТипКолонки = ПараметрТипКолонки.Значение;
		КонецЕсли;
	КонецЕсли;
	
	ДанныеОКолонке.ТипКолонки = ТипКолонки;

КонецПроцедуры

Процедура ЗаполнитьТипТаблицы(ДанныеОПодчиненнойТаблице, АннотацияПодчиненнаяТаблица)
	
	ЗначениеПоУмолчанию = Неопределено;
	
	Если АннотацияПодчиненнаяТаблица = Неопределено ИЛИ АннотацияПодчиненнаяТаблица.Параметры = Неопределено Тогда
		ТипКолонки = ЗначениеПоУмолчанию;
	Иначе
		ПараметрТипКолонки = АннотацияПодчиненнаяТаблица.Параметры.Найти("Тип", "Имя");
		Если ПараметрТипКолонки = Неопределено ИЛИ ПараметрТипКолонки.Значение = Неопределено Тогда
			ТипКолонки = ЗначениеПоУмолчанию;
		Иначе
			ТипКолонки = ПараметрТипКолонки.Значение;
		КонецЕсли;
	КонецЕсли;
	
	ДанныеОПодчиненнойТаблице.ТипТаблицы = ТипКолонки;

КонецПроцедуры

Процедура ЗаполнитьТипСсылки(ДанныеОКолонке, АннотацияКолонка)
	
	ЗначениеПоУмолчанию = Неопределено;
	
	Если АннотацияКолонка = Неопределено ИЛИ АннотацияКолонка.Параметры = Неопределено Тогда
		ТипСсылки = ЗначениеПоУмолчанию;
	ИначеЕсли ДанныеОКолонке.ТипКолонки <> ТипыКолонок.Ссылка Тогда
		ТипСсылки = ЗначениеПоУмолчанию;
	Иначе
		ПараметрТипСсылки = АннотацияКолонка.Параметры.Найти("ТипСсылки", "Имя");
		Если ПараметрТипСсылки = Неопределено Тогда
			ТипСсылки = ЗначениеПоУмолчанию;
		Иначе
			ТипСсылки = Тип(ПараметрТипСсылки.Значение);
		КонецЕсли;
	КонецЕсли;
	
	ДанныеОКолонке.ТипСсылки = ТипСсылки;
КонецПроцедуры

Процедура ЗаполнитьТипЭлемента(ДанныеОКолонке, АннотацияКолонка)
	
	ЗначениеПоУмолчанию = Неопределено;
	// TODO:
	// ТипыКолонокСЭлементами.Добавить(ТипыКолонок.Таблица);
	
	Если АннотацияКолонка = Неопределено ИЛИ АннотацияКолонка.Параметры = Неопределено Тогда
		ТипЭлемента = ЗначениеПоУмолчанию;
	Иначе
		ПараметрТипЭлемента = АннотацияКолонка.Параметры.Найти("ТипЭлемента", "Имя");
		Если ПараметрТипЭлемента = Неопределено Тогда
			ТипЭлемента = ЗначениеПоУмолчанию;
		Иначе
			ТипЭлемента = Тип(ПараметрТипЭлемента.Значение);
		КонецЕсли;
	КонецЕсли;
	
	ДанныеОКолонке.ТипЭлемента = ТипЭлемента;
КонецПроцедуры

Процедура ЗаполнитьКаскадноеЧтение(ДанныеОКолонке, АннотацияКолонка)

	ЗначениеПоУмолчанию = Ложь;
	
	Если АннотацияКолонка = Неопределено ИЛИ АннотацияКолонка.Параметры = Неопределено Тогда
		КаскадноеЧтение = ЗначениеПоУмолчанию;
	ИначеЕсли НЕ ТипыКолонок.ЭтоСсылочныйТип(ДанныеОКолонке.ТипЭлемента) Тогда
		КаскадноеЧтение = ЗначениеПоУмолчанию;
	Иначе
		ПараметрКаскадноеЧтение = АннотацияКолонка.Параметры.Найти("КаскадноеЧтение", "Имя");
		Если ПараметрКаскадноеЧтение = Неопределено Тогда
			КаскадноеЧтение = ЗначениеПоУмолчанию;
		Иначе
			КаскадноеЧтение = ПараметрКаскадноеЧтение.Значение;
		КонецЕсли;
	КонецЕсли;
	
	ДанныеОКолонке.КаскадноеЧтение = КаскадноеЧтение;
КонецПроцедуры

Функция СоответствиеТиповМоделиОписанийТипов()
	
	Карта = Новый Соответствие;
	Карта.Вставить(ТипыКолонок.Целое, Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла( , 0)));
	Карта.Вставить(ТипыКолонок.Дробное, Новый ОписаниеТипов("Число"));
	Карта.Вставить(ТипыКолонок.Булево, Новый ОписаниеТипов("Булево"));
	Карта.Вставить(ТипыКолонок.Строка, Новый ОписаниеТипов("Строка"));
	Карта.Вставить(ТипыКолонок.Дата, Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты.Дата)));
	Карта.Вставить(ТипыКолонок.Время, Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты.Время)));
	Карта.Вставить(ТипыКолонок.ДатаВремя, Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты.ДатаВремя)));
	Карта.Вставить(ТипыКолонок.ДвоичныеДанные, Новый ОписаниеТипов("ДвоичныеДанные"));
	
	Возврат Карта;
	
КонецФункции

Функция ВыполнитьПриведениеЗначения(Колонка, Значение)
	// Если тип колонки и значение - двоичные данные, то приводить не нужно.
	// по крайней мере пока oscript не научится приводить тип двоичных данных
	// https://github.com/EvilBeaver/OneScript/issues/1327
	Если Колонка.ТипКолонки = ТипыКолонок.ДвоичныеДанные
		И ТипЗнч(Значение) = Тип("ДвоичныеДанные") Тогда
		Возврат Значение;
	КонецЕсли;

	ОбработанноеЗначение = Значение;
	
	КартаОписанийТипов = СоответствиеТиповМоделиОписанийТипов();
	
	ОписаниеТипов = КартаОписанийТипов.Получить(Колонка.ТипКолонки);
	Если ОписаниеТипов = Неопределено Тогда
		ВызватьИсключение "Неизвестный тип колонки " + Колонка.ИмяКолонки;
	КонецЕсли;

	// Некоторые коннекторы возвращают дату/время в виде строки в формате ISO.
	Если ТипЗнч(ОбработанноеЗначение) = Тип("Строка") Тогда
		Если Колонка.ТипКолонки = ТипыКолонок.Дата Тогда
			ОбработанноеЗначение = СтроковыеФункции.СтрокаВДату(ОбработанноеЗначение, ЧастиДаты.Дата);
		ИначеЕсли Колонка.ТипКолонки = ТипыКолонок.ДатаВремя Тогда
			ОбработанноеЗначение = СтроковыеФункции.СтрокаВДату(ОбработанноеЗначение, ЧастиДаты.ДатаВремя);
		ИначеЕсли Колонка.ТипКолонки = ТипыКолонок.Время Тогда
			ОбработанноеЗначение = СтроковыеФункции.СтрокаВДату(ОбработанноеЗначение, ЧастиДаты.Время);
		Иначе
			// no-op
		КонецЕсли;
	КонецЕсли;
	
	Возврат ОписаниеТипов.ПривестиЗначение(ОбработанноеЗначение);
КонецФункции
