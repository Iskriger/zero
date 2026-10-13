# Goal Tracker - Курсовой проект

## 📱 О приложении
Goal Tracker - это минималистичное приложение для трекинга целей с поддержкой категорий, тегов, приоритетов и статистики. Разработано в рамках курсовой работы по дисциплине "Разработка мобильных приложений".

## 👨‍💻 Разработчик
**Студент 2 курса**
Факультет информационных технологий
Технический университет

## 🚀 Используемые технологии
- **Flutter** - кроссплатформенный UI фреймворк
- **Dart** - язык программирования
- **SQLite** - локальная база данных
- **Provider** - state management
- **Material Design** - дизайн система

## 📊 Основные функции
- ✅ Создание целей с категориями и тегами
- ✅ Установка приоритетов (низкий, средний, высокий)
- ✅ Добавление подзадач и описаний
- ✅ Архивация выполненных целей
- ✅ Статистика выполнения
- ✅ Темная и светлая темы
- ✅ Минималистичный дизайн

## 📁 Структура проекта
lib/
├── main.dart
├── models/ # Модели данных
├── screens/ # Экраны приложения
├── widgets/ # Переиспользуемые виджеты
└── utils/ # Вспомогательные функции



# Схема версионирования

## Формат

- **Официальная версия** (для `pubspec.yaml`, зависимостей, релизов): `major.minor.patch` → `1.4.2`
- **Полная версия** (для UI «О приложении», логов, баг-репортов): `major.minor.patch.build` → `1.4.2.100`

---

## Что значат части

| Часть | Когда увеличивать | Примеры |
|-------|-------------------|---------|
| `major` | Если ломаем совместимость или меняем фундамент | Переписали ядро, сменили структуру БД |
| `minor` | Если добавили новую функциональность | Новый тип модуля, новый профиль |
| `patch` | Если исправили баги/подкрутили UI | Починили иконку, поправили выравнивание |
| `build` | При каждой сборке в CI/CD или итерации дизайна | Каждый билд, каждое изменение макета |

---

## Где хранить

**В `pubspec.yaml` — только три числа:**
```yaml
version: 1.4.2
```

**В коде — отдельно `build`:**
```dart
class AppVersion {
  static const int major = 1;
  static const int minor = 4;
  static const int patch = 2;
  static const int build = 100;

  static String get semver => '$major.$minor.$patch';      // для внешних систем
  static String get full   => '$major.$minor.$patch.$build'; // для UI и логов
}
```

---

## Главное правило

- `major/minor/patch` меняем осознанно — по типу изменений.  
- `build` растёт сам (в CI) или вручную при каждой сборке.  
- Никогда не указывай `build` в зависимостях и `pubspec`.

---

## Пример для changelog

> Версия: `1.4.2` (build `100`)  
> - Добавлен модуль отчётов (minor)  
> - Исправлен баг с иконкой (patch)  

---

## Перевод на английский (если нужно для README)


# Versioning Scheme

- Base version (for pubspec, dependencies, releases): `major.minor.patch` (e.g. `1.4.2`)
- Full version (for UI “About”, logs, bug reports): `major.minor.patch.build` (e.g. `1.4.2.100`)

| Component | When to increment | Examples |
|-----------|-------------------|----------|
| `major`   | Breaking changes, core rewrite | DB structure change, framework upgrade |
| `minor`   | New features | New module type, new profile |
| `patch`   | Bug fixes, UI tweaks | Fixed icon, alignment fix |
| `build`   | Every CI build or design iteration | Each build, layout change |

Store `major.minor.patch` in `pubspec.yaml`. Keep `build` separately in code. Never use `build` in dependencies.
