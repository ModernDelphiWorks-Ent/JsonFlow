program JsonFlow4D.Jons.Tests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.JSON,
  JsonFlow4D.TestsArrays in 'Composition\JsonFlow4D.TestsArrays.pas',
  JsonFlow4D.TestsComposer in 'Composition\JsonFlow4D.TestsComposer.pas',
  JsonFlow4D.TestsObjects in 'Composition\JsonFlow4D.TestsObjects.pas',
  JsonFlow4D.TestsPair in 'Composition\JsonFlow4D.TestsPair.pas',
  JsonFlow4D.Tests.Converters in 'Core\JsonFlow4D.Tests.Converters.pas',
  JsonFlow4D.Tests in 'Core\JsonFlow4D.Tests.pas',
  JsonFlow4D.TestsPerformanceOptimizations in 'Core\JsonFlow4D.TestsPerformanceOptimizations.pas',
  JsonFlow4D.TestsRecursivityFix in 'Core\JsonFlow4D.TestsRecursivityFix.pas',
  JsonFlow4D.TestsValue in 'Core\JsonFlow4D.TestsValue.pas',
  JsonFlow4D.TestsNavigator in 'IO\JsonFlow4D.TestsNavigator.pas',
  JsonFlow4D.TestsReader in 'IO\JsonFlow4D.TestsReader.pas',
  JsonFlow4D.TestsSerializer in 'IO\JsonFlow4D.TestsSerializer.pas';

begin
  try
    Writeln('=== JsonFlow4D - Testes dos Conversores ===');
    Writeln('');
    
    TJsonFlowConvertersTests.RunAllTests;
    
    Writeln('');
    Writeln('Todos os testes foram executados com sucesso!');
    Writeln('Pressione ENTER para sair...');
    Readln;
  except
    on E: Exception do
    begin
      Writeln('Erro: ' + E.Message);
      Writeln('Pressione ENTER para sair...');
      Readln;
    end;
  end;
end.
