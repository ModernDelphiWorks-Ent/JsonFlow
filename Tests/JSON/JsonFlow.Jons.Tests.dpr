program JsonFlow.Jons.Tests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.JSON,
  JsonFlow.TestsArrays in 'Composition\JsonFlow.TestsArrays.pas',
  JsonFlow.TestsComposer in 'Composition\JsonFlow.TestsComposer.pas',
  JsonFlow.TestsObjects in 'Composition\JsonFlow.TestsObjects.pas',
  JsonFlow.TestsPair in 'Composition\JsonFlow.TestsPair.pas',
  JsonFlow.Tests.Converters in 'Core\JsonFlow.Tests.Converters.pas',
  JsonFlow.Tests in 'Core\JsonFlow.Tests.pas',
  JsonFlow.TestsPerformanceOptimizations in 'Core\JsonFlow.TestsPerformanceOptimizations.pas',
  JsonFlow.TestsRecursivityFix in 'Core\JsonFlow.TestsRecursivityFix.pas',
  JsonFlow.TestsValue in 'Core\JsonFlow.TestsValue.pas',
  JsonFlow.TestsNavigator in 'IO\JsonFlow.TestsNavigator.pas',
  JsonFlow.TestsReader in 'IO\JsonFlow.TestsReader.pas',
  JsonFlow.TestsSerializer in 'IO\JsonFlow.TestsSerializer.pas';

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
