program JsonFlow4D.Schema.Tests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.JSON,
  JsonFlow4D.TestsSchemaNavigator in 'Composition\JsonFlow4D.TestsSchemaNavigator.pas',
  JsonFlow4D.TestsSchemaComposer in 'Core\JsonFlow4D.TestsSchemaComposer.pas',
  JsonFlow4D.TestsSchemaComposerDuplicate in 'Core\JsonFlow4D.TestsSchemaComposerDuplicate.pas',
  JsonFlow4D.TestsShemaComposer in 'Core\JsonFlow4D.TestsShemaComposer.pas',
  JsonFlow4D.TestsSchemaReader in 'IO\JsonFlow4D.TestsSchemaReader.pas',
  JsonFlow4D.TestsCustomFormats in 'Validators\JsonFlow4D.TestsCustomFormats.pas',
  JsonFlow4D.TestsSchemaValidator in 'Validators\JsonFlow4D.TestsSchemaValidator.pas',
  JsonFlow4D.TestsSchemaValidatorNew in 'Validators\JsonFlow4D.TestsSchemaValidatorNew.pas';

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
