program BrazilianValidatorsExample;

{$APPTYPE CONSOLE}

{*******************************************************************************
  Exemplo de uso dos validadores de formato brasileiros
  
  Este exemplo demonstra como usar os validadores brasileiros:
  - CPF (Cadastro de Pessoas Físicas)
  - CNPJ (Cadastro Nacional da Pessoa Jurídica)
  - CEP (Código de Endereçamento Postal)
  - Telefone brasileiro
  - Placa de veículo brasileira
  
  Autor: JsonFlow4D
  Data: 2024
*******************************************************************************}

uses
  System.SysUtils,
  System.JSON,
  JsonFlow4D.Schema in '..\Source\Schema\JsonFlow4D.Schema.pas',
  JsonFlow4D.SchemaValidator in '..\Source\Schema\JsonFlow4D.SchemaValidator.pas',
  JsonFlow4D.FormatRegistry in '..\Source\Schema\JsonFlow4D.FormatRegistry.pas',
  JsonFlow4D.FormatValidators.Base in '..\Source\Schema\Rules\Format\JsonFlow4D.FormatValidators.Base.pas',
  JsonFlow4D.FormatValidators.Brazil in '..\Source\Schema\Rules\Format\Brazil\JsonFlow4D.FormatValidators.Brazil.pas';

var
  LSchema: TJSONObject;
  LData: TJSONObject;
  LValidator: TJsonSchemaValidator;
  LResult: TValidationResult;
  I: Integer;
begin
  WriteLn('=== Exemplo de Validadores Brasileiros ===');
  WriteLn;
  
  try
    // Registra todos os validadores brasileiros
    RegisterAllBrazilianFormatValidators;
    
    // Define um schema JSON que usa os formatos brasileiros
    LSchema := TJSONObject.ParseJSONValue('{
' +
      '  "type": "object",
' +
      '  "properties": {
' +
      '    "cpf": {
' +
      '      "type": "string",
' +
      '      "format": "cpf"
' +
      '    },
' +
      '    "cnpj": {
' +
      '      "type": "string",
' +
      '      "format": "cnpj"
' +
      '    },
' +
      '    "cep": {
' +
      '      "type": "string",
' +
      '      "format": "cep"
' +
      '    },
' +
      '    "telefone": {
' +
      '      "type": "string",
' +
      '      "format": "brazilian-phone"
' +
      '    },
' +
      '    "placa": {
' +
      '      "type": "string",
' +
      '      "format": "brazilian-license-plate"
' +
      '    }
' +
      '  },
' +
      '  "required": ["cpf", "cnpj", "cep", "telefone", "placa"]
' +
      '}') as TJSONObject;
    
    // Cria o validador
    LValidator := TJsonSchemaValidator.Create;
    try
      // Teste com dados válidos
      WriteLn('=== Testando dados válidos ===');
      LData := TJSONObject.ParseJSONValue('{
' +
        '  "cpf": "123.456.789-09",
' +
        '  "cnpj": "11.222.333/0001-81",
' +
        '  "cep": "01234-567",
' +
        '  "telefone": "(11) 99999-9999",
' +
        '  "placa": "ABC-1234"
' +
        '}') as TJSONObject;
      
      LResult := LValidator.Validate(LData, LSchema);
      WriteLn('Resultado: ', BoolToStr(LResult.IsValid, True));
      if not LResult.IsValid then
      begin
        WriteLn('Erros encontrados:');
        for I := 0 to High(LResult.Errors) do
          WriteLn('  - ', LResult.Errors[I].Message);
      end;
      WriteLn;
      
      LData.Free;
      
      // Teste com dados inválidos
      WriteLn('=== Testando dados inválidos ===');
      LData := TJSONObject.ParseJSONValue('{
' +
        '  "cpf": "123.456.789-00",
' +
        '  "cnpj": "11.222.333/0001-00",
' +
        '  "cep": "1234-567",
' +
        '  "telefone": "11 1234-5678",
' +
        '  "placa": "AB-1234"
' +
        '}') as TJSONObject;
      
      LResult := LValidator.Validate(LData, LSchema);
      WriteLn('Resultado: ', BoolToStr(LResult.IsValid, True));
      if not LResult.IsValid then
      begin
        WriteLn('Erros encontrados:');
        for I := 0 to High(LResult.Errors) do
          WriteLn('  - ', LResult.Errors[I].Message);
      end;
      WriteLn;
      
      LData.Free;
      
      // Teste com formatos alternativos válidos
      WriteLn('=== Testando formatos alternativos válidos ===');
      LData := TJSONObject.ParseJSONValue('{
' +
        '  "cpf": "12345678909",
' +
        '  "cnpj": "11222333000181",
' +
        '  "cep": "01234567",
' +
        '  "telefone": "+55 11 99999-9999",
' +
        '  "placa": "ABC1D23"
' +
        '}') as TJSONObject;
      
      LResult := LValidator.Validate(LData, LSchema);
      WriteLn('Resultado: ', BoolToStr(LResult.IsValid, True));
      if not LResult.IsValid then
      begin
        WriteLn('Erros encontrados:');
        for I := 0 to High(LResult.Errors) do
          WriteLn('  - ', LResult.Errors[I].Message);
      end;
      WriteLn;
      
      LData.Free;
      
    finally
      LValidator.Free;
    end;
    
    LSchema.Free;
    
  except
    on E: Exception do
      WriteLn('Erro: ', E.Message);
  end;
  
  WriteLn('=== Exemplo concluído ===');
  WriteLn('Pressione Enter para sair...');
  ReadLn;
end.
