chcp 65001
SET TOOLS_UI_1C_BUILDER_EDT_PATH=C:\Program Files\1C\1CE\components\1c-edt-2025.1.5+34-x86_64
SET TOOLS_UI_1C_BUILDER_PLATFORM_PATH=C:\Program Files\1cv8\8.3.27.1964\bin

oscript.exe -encoding=utf-8 .\src\builder\build.os xml
oscript.exe -encoding=utf-8 .\src\builder\build.os epf

