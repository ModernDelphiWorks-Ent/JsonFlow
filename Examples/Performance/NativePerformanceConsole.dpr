program NativePerformanceConsole;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  NativePerformanceDemo in 'NativePerformanceDemo.pas',
  JsonFlow4D.Composer in '..\Source\Core\JsonFlow4D.Composer.pas',
  JsonFlow4D.Core in '..\Source\Core\JsonFlow4D.Core.pas',
  JsonFlow4D.Navigator in '..\Source\Core\JsonFlow4D.Navigator.pas';

begin
  try
    WriteLn('JsonFlow4D - Native Performance Features Demo');
    WriteLn('==============================================');
    WriteLn;
    WriteLn('This demo shows how performance enhancements are now');
    WriteLn('natively integrated into TJSONComposer for transparency.');
    WriteLn;
    WriteLn('Press ENTER to start...');
    ReadLn;
    WriteLn;
    
    TNativePerformanceDemo.RunDemo;
    
    WriteLn;
    WriteLn('Press ENTER to exit...');
    ReadLn;
    
  except
    on E: Exception do
    begin
      WriteLn('Error: ' + E.Message);
      WriteLn('Press ENTER to exit...');
      ReadLn;
    end;
  end;
end.
