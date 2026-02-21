program UnifiedConvertersDemo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UnifiedConvertersDemo in 'UnifiedConvertersDemo.pas',
  JsonFlow4D.Converters in '..\Source\JSON\Core\JsonFlow4D.Converters.pas';

var
  LDemo: TUnifiedConvertersDemo;

begin
  try
    WriteLn('Iniciando demonstração dos Conversores Unificados JsonFlow4D...');
    WriteLn('');
    
    LDemo := TUnifiedConvertersDemo.Create;
    try
      LDemo.RunAllDemos;
    finally
      LDemo.Free;
    end;
    
    WriteLn('');
    WriteLn('Pressione ENTER para sair...');
    ReadLn;
    
  except
    on E: Exception do
    begin
      WriteLn('Erro na aplicação: ' + E.ClassName + ': ' + E.Message);
      WriteLn('');
      WriteLn('Pressione ENTER para sair...');
      ReadLn;
    end;
  end;
end.
