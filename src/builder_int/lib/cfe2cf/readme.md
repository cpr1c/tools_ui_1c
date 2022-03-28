[![Stars](https://img.shields.io/github/stars/best-tech/cfe2cf.svg?label=Github%20%E2%98%85&a)](https://github.com/best-tech/cfe2cf/stargazers)
[![Release](https://img.shields.io/github/tag/best-tech/cfe2cf.svg?label=Last%20release&a)](https://github.com/best-tech/cfe2cf/releases)

# Приложение - Конвертор расширения .cfe в конфигурацию .cf

#### Поддерживаются режимы работы:

- Конвертация из файла расширения (.cfe)
- Конвертация из исходных файлов расширения

```
Приложение: cfe2cf
 Конвертор расширения .cfe в конфигурацию .cf

Строка запуска: cfe2cf [ОПЦИИ]  КОМАНДА [аргументы...]

Опции:
  -v, --version         показать версию и выйти

Доступные команды:
  f, file       Конвертация из файла расширения (.cfe) в файл конфигурации (.cf)
  s, source     Конвертация из исходных файлов расширения (.cfe) в файл конфигурации (.cf)

Для вывода справки по доступным командам наберите: cfe2cf КОМАНДА --help
```

## Конвертация файла расширения 
Пример:

`cfe2cf file -t c:/temp path/to/ext.cfe ИмяРасширения path/to/conf.cf`

```
Команда: f, file
 Конвертация из файла расширения (.cfe) в файл конфигурации (.cf)

Строка запуска: cfe2cf f [ОПЦИИ] SRC NAME OUTPUT

Аргументы:
  SRC           Путь к входному файлу расширения (.cfe)
  NAME          Имя расширения (-Extension)
  OUTPUT        Путь к выходному файлу конфигурации (.cf)

Опции:
  -t, --tempdir         Путь к каталогу временных файлов
```

## Конвертация из исходных файлов

Пример:

`cfe2cf file -t c:/temp path/to/ext.src ИмяРасширения path/to/conf.cf`

```
Команда: s, source
 Конвертация из исходных файлов расширения (.cfe) в файл конфигурации (.cf)

Строка запуска: cfe2cf s [ОПЦИИ] SRC NAME OUTPUT

Аргументы:
  SRC           Путь папке исходных файлов
  NAME          Имя расширения (-Extension)
  OUTPUT        Путь к выходному файлу конфигурации (.cf)

Опции:
  -t, --tempdir         Путь к каталогу временных файлов
```

### Собрать cfe2cf.exe

`oscript -make src/cfe2cf.os cfe2cf.exe`