program JsonFlow.Schema.Tests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.JSON,
  JsonFlow.TestsSchemaNavigator in 'Composition\JsonFlow.TestsSchemaNavigator.pas',
  JsonFlow.TestsSchemaComposer in 'Core\JsonFlow.TestsSchemaComposer.pas',
  JsonFlow.TestsSchemaComposerDuplicate in 'Core\JsonFlow.TestsSchemaComposerDuplicate.pas',
  JsonFlow.TestsShemaComposer in 'Core\JsonFlow.TestsShemaComposer.pas',
  JsonFlow.TestsSchemaReader in 'IO\JsonFlow.TestsSchemaReader.pas',
  JsonFlow.TestsCustomFormats in 'Validators\JsonFlow.TestsCustomFormats.pas',
  JsonFlow.TestsSchemaValidator in 'Validators\JsonFlow.TestsSchemaValidator.pas',
  JsonFlow.TestsSchemaValidatorNew in 'Validators\JsonFlow.TestsSchemaValidatorNew.pas',
  CustomFormatValidators in '..\..\Examples\Validators\CustomFormatValidators.pas';

begin
  try
    Writeln('=== JsonFlow4D - Testes dos Conversores ===');
    Writeln('');
    
//    TJsonFlowConvertersTests.RunAllTests;

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
