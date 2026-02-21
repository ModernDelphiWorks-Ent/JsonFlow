@echo off
echo ========================================
echo  JsonFlow4D - Compilacao Demo Centralizado
echo ========================================
echo.

REM Definir caminhos
set PROJECT_DIR=%~dp0
set SOURCE_DIR=%PROJECT_DIR%..\Source
set DEMO_PROJECT=%PROJECT_DIR%CentralizedJsonFlowDemo.dpr

REM Verificar se o dcc32.exe existe
set DCC32_PATH="C:\Program Files (x86)\Embarcadero\Studio\22.0\bin\dcc32.exe"
if not exist %DCC32_PATH% (
    echo ERRO: dcc32.exe nao encontrado em %DCC32_PATH%
    echo Por favor, ajuste o caminho do Delphi no script.
    pause
    exit /b 1
)

REM Verificar se o projeto existe
if not exist "%DEMO_PROJECT%" (
    echo ERRO: Projeto %DEMO_PROJECT% nao encontrado!
    pause
    exit /b 1
)

echo Compilando projeto: %DEMO_PROJECT%
echo Diretorio de origem: %SOURCE_DIR%
echo.

REM Compilar o projeto
%DCC32_PATH% "%DEMO_PROJECT%" -U"%SOURCE_DIR%;%SOURCE_DIR%\JSON\Core;%SOURCE_DIR%\JSON\Composition;%SOURCE_DIR%\JSON\IO;%SOURCE_DIR%\JSON\Middleware;%SOURCE_DIR%\Schema\Core;%SOURCE_DIR%\Schema\Composition;%SOURCE_DIR%\Schema\IO;%SOURCE_DIR%\Schema\Validators" -NS"System;System.Win;WinApi;Vcl;Data;Xml" -B

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================
    echo  COMPILACAO CONCLUIDA COM SUCESSO!
    echo ========================================
    echo.
    echo Executavel gerado: %PROJECT_DIR%CentralizedJsonFlowDemo.exe
    echo.
    
    REM Perguntar se deseja executar
    set /p EXECUTE="Deseja executar o exemplo agora? (S/N): "
    if /i "%EXECUTE%"=="S" (
        echo.
        echo Executando demonstracao...
        echo ========================================
        "%PROJECT_DIR%CentralizedJsonFlowDemo.exe"
    )
) else (
    echo.
    echo ========================================
    echo  ERRO NA COMPILACAO!
    echo ========================================
    echo Codigo de erro: %ERRORLEVEL%
)

echo.
pause