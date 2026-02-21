program CentralizedDemo;

{$APPTYPE CONSOLE}

{$I ../Source/jsonflow4d.inc}

uses
  System.SysUtils,
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  CentralizedJsonFlowDemo in 'CentralizedJsonFlowDemo.pas';

begin
  try
    // Configurar codepage para suporte a caracteres especiais
    {$IFDEF MSWINDOWS}
    SetConsoleOutputCP(CP_UTF8);
    {$ENDIF}
    
    // Executar demonstração
    TCentralizedJsonFlowDemo.RunAllExamples;
    
  except
    on E: Exception do
    begin
      Writeln('ERRO FATAL: ' + E.ClassName + ': ' + E.Message);
      Writeln('Pressione ENTER para sair...');
      Readln;
    end;
  end;
end.