# AGENTS.md — Универсальные инструменты 1С

## Язык и стек

- Код продукта — **1С:Предприятие (BSL)**, префикс всех объектов: `УИ_`
- Сборщик — **OneScript (oscript)**, зависимости в `packagedef`, установка: `opm install`
- Сайт документации — **Docusaurus 3** (TypeScript, npm) в `website/`
- Линтер — **bsl-language-server** (`.bsl-language-server.json`), maxLineLength=150

## Сборка (из корня)

```bash
oscript -encoding=utf-8 ./src/builder/build.os <команда>
```

**Порядок важен**: сначала `xml`, затем одна из `cfe`/`cf`/`epf`.
Команды: `xml` (конвертация EDT→формат конфигуратора), `cfe` (расширение), `cf` (конфигурация), `epf` (портативная), `ci` (CI-сборка).

Пути к инструментам — через опции `--platformSource`, `--edtSource` или переменные окружения `TOOLS_UI_1C_BUILDER_PLATFORM_PATH`, `TOOLS_UI_1C_BUILDER_EDT_PATH`.

## Ключевые каталоги

- `src/Инструменты/src/` — исходники подсистемы в формате EDT (XML-представление 1С)
- `src/Портативный/src/` — портативная версия (внешние обработки)
- `src/builder/` — скрипты сборки на OneScript; entrypoint: `build.os`
- `website/` — сайт документации, команды: `npm start` / `npm run build`

## CI и контроль качества

- GitHub Actions: сборка по push в `develop`, релизы — по созданию тега
- SonarQube на sonar.openbsl.ru (`sonar-project.properties`); анализ по push и PR
- bsl-language-server проверяет стиль; служебные теги: `todo|fixme|отладка|debug|КОНСТРУКТОР_`
- Сайт деплоится на GitHub Pages из ветки `develop` при изменении `website/`

## Разработка

- Основная ветка — `develop`, релизная — `master`
- Код разрабатывается в **1C:EDT**; для конфигуратора есть инструкция в `website/docs/contributing/setup-configurator.mdx`
- Тестов в репозитории нет; формат правок — issue → PR
