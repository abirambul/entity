#Использовать proxy

Функция ТипСущности(Сущность) Экспорт
	ТипСущности = ТипЗнч(Сущность);
	Если ТипСущности = Тип("Сценарий") Тогда
		ТипСущности = ОбработкаПроксиОбъекта.ИсходныйТип(Сущность);
	КонецЕсли;

	Возврат ТипСущности;
КонецФункции

Функция Создать(ОбъектМодели, ХранилищеСущностей) Экспорт
	Сущность = Новый(ОбъектМодели.ТипСущности());
	
	Прокси = Новый КонструкторПрокси(Сущность)
		.ДобавитьПриватноеПоле("_ХранилищеСущностей", ХранилищеСущностей)
		.ДобавитьПриватноеПоле("_ОбъектМодели", ОбъектМодели)
		.ДобавитьМетод(
			"Прочитать", 
			"_ДанныеСущности = _ХранилищеСущностей.ПолучитьОдно(_ОбъектМодели.ПолучитьЗначениеИдентификатора(ЭтотОбъект));
			|ОбработкаПроксиОбъекта.СинхронизироватьПоля(_ДанныеСущности, ЭтотОбъект);"
		)
		.ДобавитьМетод(
			"Сохранить",
			"_ХранилищеСущностей.Сохранить(ЭтотОбъект);"
		)
		.ДобавитьМетод(
			"Удалить", 
			"_ХранилищеСущностей.Удалить(ЭтотОбъект);"
		)
		.Построить();
	
	Возврат Прокси;
КонецФункции