## Version 1.4.3
 - Удалён мёртвый код: неиспользуемые DatabaseHelper (SQLite) и StatisticsManager, заглушка getGoals()
 - Убраны неиспользуемые зависимости из pubspec.yaml
 - Единый источник сериализации целей — Goal.toMap/fromMap
 - Демо-данные добавляются только при первом запуске, отладочные print() заменены на debugPrint
 - Добавлены тесты: test/models_test.dart, test/shared_prefs_repository_test.dart
 - Логотип переименован в assets/icons/logo_zero.png и подключён в About-экране

--------------------------------------------------------------------------

 - Removed dead code: unused DatabaseHelper (SQLite) and StatisticsManager, stub getGoals()
 - Dropped unused dependencies from pubspec.yaml
 - Single source of truth for goal serialization — Goal.toMap/fromMap
 - Sample data is added only on first launch; debug print() calls replaced with debugPrint
 - Added tests: test/models_test.dart, test/shared_prefs_repository_test.dart
 - Logo renamed to assets/icons/logo_zero.png and used in the About screen


## Version 1.4.2
 - Было уменьшено Drawer и переработаны размеры текста в разных экранах
 - Добавлено Почта Разработчика для обращения по багам или иным просьбам, также было добавлен в разделе настроек в Помощь
 - Изменены цвета в некоторых интерфесных иконках
 - Обновлены цвета в разделе Статистика в табле Общая статистика
 - Был переделан дизайн внутреннего уведомления
 - удалены нефункциональные кнопки


--------------------------------------------------------------------------

 - The Drawer was reduced and text sizes were reworked across different screens.
 - Developer’s Email was added for bug reports or other requests; also added to the Help section in Settings.
 - Colors of some interface icons were changed.
 - Colors in the Statistics section (tab “Overall Statistics”) were updated.
 - The design of the internal notification was redone.
 - Non‑functional buttons were removed.


## Version 1.4.1
 - Добавлена кнопка «GitHub developer» в разделе «О приложении» (minor).
 - Обновлён Табло с Технологиями: улучшена цветовая схема — теперь интерфейс ярче (patch).

---------------------------------------------------------------------------

 - A GitHub developer button has appeared in the About section of the app
 - Also, the Technologies Dashboard in the section has been updated — it used to be dull, but now it’s brighter.


