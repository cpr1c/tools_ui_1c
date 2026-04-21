chcp 65001
SET TOOLS_UI_1C_BUILDER_EDT_PATH=C:\Users\zhuravlev_a\AppData\Local\1C\1cedtstart\installations\1C_EDT 2025.2\1cedt
SET TOOLS_UI_1C_BUILDER_PLATFORM_PATH=C:\Program Files\1cv8\8.3.27.1989\bin

oscript.exe -encoding=utf-8 .\src\builder\build.os xml
oscript.exe -encoding=utf-8 .\src\builder\build.os epf
oscript.exe -encoding=utf-8 .\src\builder\build.os cfe
