@echo off
echo ===============================================
echo  JsonFlow4D - Compilando Exemplo Unificado
echo ===============================================
echo.

REM Definir caminhos
set DELPHI_PATH="C:\Program Files (x86)\Embarcadero\Studio\22.0\bin"
set PROJECT_PATH=%~dp0
set SOURCE_PATH=%PROJECT_PATH%..\Source

echo Projeto: %PROJECT_PATH%UnifiedConvertersDemo.dpr
echo Fontes:  %SOURCE_PATH%
echo.

REM Verificar se o DCC32 existe
if not exist %DELPHI_PATH%\dcc32.exe (
    echo ERRO: DCC32.exe nao encontrado em %DELPHI_PATH%
    echo.
    echo Ajuste o caminho do Delphi na variavel DELPHI_PATH
    echo Caminhos comuns:
    echo   - Delphi 11: "C:\Program Files (x86)\Embarcadero\Studio\22.0\bin"
    echo   - Delphi 10.4: "C:\Program Files (x86)\Embarcadero\Studio\21.0\bin"
    echo   - Delphi 10.3: "C:\Program Files (x86)\Embarcadero\Studio\20.0\bin"
    echo.
    pause
    exit /b 1
)

echo Compilando...
echo.

REM Compilar o projeto
%DELPHI_PATH%\dcc32.exe ^-U"%SOURCE_PATH%\JSON\Core;%SOURCE_PATH%\JSON\Converters;%SOURCE_PATH%\JSON\Serializers;%SOURCE_PATH%\JSON\Validators;%SOURCE_PATH%\JSON\Utils;%SOURCE_PATH%\JSON\Readers;%SOURCE_PATH%\JSON\Writers;%SOURCE_PATH%\JSON\Navigators;%SOURCE_PATH%\JSON\Composers;%SOURCE_PATH%\Schema" ^-NS"JsonFlow;JsonFlow4D.Core;JsonFlow4D.Converters;JsonFlow4D.Serializers;JsonFlow4D.Validators;JsonFlow4D.Utils;JsonFlow4D.Readers;JsonFlow4D.Writers;JsonFlow4D.Navigators;JsonFlow4D.Composers;JsonFlow4D.Schema" UnifiedConvertersDemo.dpr

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===============================================
    echo  COMPILACAO BEM-SUCEDIDA!
    echo ===============================================
    echo.
    echo Executavel gerado: UnifiedConvertersDemo.exe
    echo.
    echo Deseja executar o exemplo agora? (S/N)
    set /p choice="Opcao: "
    if /i "%choice%"=="S" (
        echo.
        echo Executando exemplo...
        echo.
        UnifiedConvertersDemo.exe
    )
) else (
    echo.
    echo ===============================================
    echo  ERRO NA COMPILACAO!
    echo ===============================================
    echo.
    echo Verifique:
    echo 1. Se todos os arquivos fonte estao presentes
    echo 2. Se os caminhos das units estao corretos
    echo 3. Se nao ha erros de sintaxe no codigo
    echo.
)

echo.
echo Pressione qualquer tecla para sair...
pause >nul
