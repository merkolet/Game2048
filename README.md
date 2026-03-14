# 2048 Pro Game

Классическая игра 2048 на Flutter с авторизацией, лидербордом и облачной синхронизацией.

## Возможности

- **Режимы игры**: 3×3, 4×4, 5×5
- **Авторизация**: регистрация и вход через Firebase Auth (email/пароль)
- **Локальное сохранение**: лучший счёт, задания, статистика — по каждому пользователю (SharedPreferences)
- **Лидерборд**: Firestore, топ-игроки по каждому режиму
- **Задания**: достигни 64, набери 1000+, победа на 5×5 (в будущем можно добавить больше)
- **Подсказка**: рекомендуемый ход
- **Анимации**: движение плиток, слияние

## Стек

- **Flutter** (Dart, 3.11.1)
- **Firebase**: Auth, Firestore
- **shared_preferences** — локальное хранилище

## Архитектура

```
lib/
├── core/           # DI, AppScope, сервисы
├── data/           # SharedPrefs, реализация репозиториев
├── domain/         # Модели, GameService, репозитории (интерфейсы)
└── presentation/   # Экраны, виджеты
```

Clean Architecture: UI → Domain ← Data; зависимости через абстракции, DI через `AppScope`.

## Запуск

```bash
flutter pub get
flutter run
```

## Тесты

```bash
flutter test
```

Покрытие: domain (модели, GameService), data (SharedPrefs), presentation (TileGrid).

## CI

GitHub Actions: при push/PR в `main` или `master` запускаются `flutter analyze` и `flutter test`.