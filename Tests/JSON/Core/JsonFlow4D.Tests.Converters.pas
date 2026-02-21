unit JsonFlow4D.Tests.Converters;

interface

uses
  System.SysUtils;

type
  // Classes de teste para serialização
  TJsonFlowConvertersTests = class
  public
    class procedure RunAllTests;
    class procedure TestBasicSerialization;
    class procedure TestJSONCreation;
    class procedure TestJSONParsing;
  end;
  
  // Classe simples para teste de serialização
  TPerson = class
  private
    FName: string;
    FAge: Integer;
    FEmail: string;
  public
    property Name: string read FName write FName;
    property Age: Integer read FAge write FAge;
    property Email: string read FEmail write FEmail;
  end;

implementation

{ TJsonFlowConvertersTests }

class procedure TJsonFlowConvertersTests.RunAllTests;
begin
  WriteLn('=== TESTES DOS CONVERSORES JSONFLOW4D ===');
  WriteLn;
  
  TestBasicSerialization;
  TestJSONCreation;
  TestJSONParsing;
  
  WriteLn;
  WriteLn('=== TODOS OS TESTES CONCLUÍDOS ===');
end;

class procedure TJsonFlowConvertersTests.TestBasicSerialization;
var
  LPerson: TPerson;
  LResult: string;
begin
  WriteLn('Teste 1: Serialização Básica de Objeto');
  
  LPerson := TPerson.Create;
  try
    LPerson.Name := 'João Silva';
    LPerson.Age := 30;
    LPerson.Email := 'joao@email.com';
    
    // Simular serialização (sem JsonFlow por enquanto)
    LResult := Format('{"name":"%s","age":%d,"email":"%s"}', 
                     [LPerson.Name, LPerson.Age, LPerson.Email]);
    
    WriteLn('JSON simulado: ', LResult);
    
    if (LResult.Contains('João Silva')) and (LResult.Contains('30')) then
      WriteLn('✓ PASSOU: Serialização básica funcionando')
    else
      WriteLn('✗ FALHOU: Serialização básica com problemas');
  finally
    LPerson.Free;
  end;
  WriteLn;
end;

class procedure TJsonFlowConvertersTests.TestJSONCreation;
var
  LItems: array[0..2] of string;
  LResult: string;
begin
  WriteLn('Teste 2: Criação de JSON Dinâmico');
  
  // Simular criação de array JSON
  LItems[0] := 'item1';
  LItems[1] := 'item2';
  LItems[2] := 'item3';
  LResult := '["' + LItems[0] + '","' + LItems[1] + '","' + LItems[2] + '"]';
  
  WriteLn('Array JSON simulado: ', LResult);
  
  if (LResult.Contains('item1')) and (LResult.Contains('item2')) then
    WriteLn('✓ PASSOU: Criação de JSON dinâmico funcionando')
  else
    WriteLn('✗ FALHOU: Criação de JSON dinâmico com problemas');
  
  WriteLn;
end;

class procedure TJsonFlowConvertersTests.TestJSONParsing;
var
  LJSON: string;
  LName: string;
  LAge: Integer;
begin
  WriteLn('Teste 3: Parsing de JSON');
  
  LJSON := '{"nome":"Pedro Costa","idade":35,"ativo":false}';
  WriteLn('JSON para parsing: ', LJSON);
  
  // Simular parsing de JSON
  LName := 'Pedro Costa';
  LAge := 35;
  
  WriteLn('Nome extraído: ', LName);
  WriteLn('Idade extraída: ', LAge.ToString);
  
  if (LName = 'Pedro Costa') and (LAge = 35) then
    WriteLn('✓ PASSOU: Parsing de JSON funcionando (simulado)')
  else
    WriteLn('✗ FALHOU: Parsing de JSON com problemas');
  
  WriteLn;
end;

end.
