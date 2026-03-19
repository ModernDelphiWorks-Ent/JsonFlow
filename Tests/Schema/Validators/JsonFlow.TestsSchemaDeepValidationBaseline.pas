unit JsonFlow.TestsSchemaDeepValidationBaseline;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

type
  [TestFixture]
  TSchemaDeepValidationBaselineTests = class
  private
    FReader: TJSONSchemaReader;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestValidate_Deep_MinLength_ShouldFail;
    [Test]
    procedure TestValidate_Deep_Required_ShouldFail;
    [Test]
    procedure TestValidate_SameKey_In_Different_Branches_ShouldFail;
  end;

implementation

uses
  System.SysUtils;

procedure TSchemaDeepValidationBaselineTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TSchemaDeepValidationBaselineTests.TearDown;
begin
  FReader.Free;
end;

procedure TSchemaDeepValidationBaselineTests.TestValidate_Deep_MinLength_ShouldFail;
var
  LSchema: String;
  LJson: String;
  LErrors: TArray<TValidationError>;
begin
  LSchema :=
    '{' +
    '  "type": "object",' +
    '  "properties": {' +
    '    "customer": {' +
    '      "type": "object",' +
    '      "properties": {' +
    '        "name": { "type": "string", "minLength": 5 }' +
    '      },' +
    '      "required": ["name"]' +
    '    }' +
    '  },' +
    '  "required": ["customer"]' +
    '}';

  FReader.LoadFromString(LSchema);

  LJson := '{"customer":{"name":"abc"}}';
  Assert.IsFalse(FReader.Validate(LJson), 'Deep minLength deveria invalidar o JSON');

  LErrors := FReader.GetErrors;
  Assert.IsTrue(Length(LErrors) > 0, 'Deveria retornar ao menos 1 erro');
end;

procedure TSchemaDeepValidationBaselineTests.TestValidate_Deep_Required_ShouldFail;
var
  LSchema: String;
  LJson: String;
  LErrors: TArray<TValidationError>;
begin
  LSchema :=
    '{' +
    '  "type": "object",' +
    '  "properties": {' +
    '    "customer": {' +
    '      "type": "object",' +
    '      "properties": {' +
    '        "id": { "type": "integer" }' +
    '      },' +
    '      "required": ["id"]' +
    '    }' +
    '  },' +
    '  "required": ["customer"]' +
    '}';

  FReader.LoadFromString(LSchema);

  LJson := '{"customer":{}}';
  Assert.IsFalse(FReader.Validate(LJson), 'Deep required deveria invalidar o JSON');

  LErrors := FReader.GetErrors;
  Assert.IsTrue(Length(LErrors) > 0, 'Deveria retornar ao menos 1 erro');
end;

procedure TSchemaDeepValidationBaselineTests.TestValidate_SameKey_In_Different_Branches_ShouldFail;
var
  LSchema: String;
  LJson: String;
  LErrors: TArray<TValidationError>;
begin
  LSchema :=
    '{' +
    '  "type": "object",' +
    '  "properties": {' +
    '    "cliente": {' +
    '      "type": "object",' +
    '      "properties": {' +
    '        "endereco": {' +
    '          "type": "object",' +
    '          "properties": {' +
    '            "cep": { "type": "string", "pattern": "^[0-9]{8}$" }' +
    '          },' +
    '          "required": ["cep"]' +
    '        }' +
    '      },' +
    '      "required": ["endereco"]' +
    '    },' +
    '    "fornecedor": {' +
    '      "type": "object",' +
    '      "properties": {' +
    '        "endereco": {' +
    '          "type": "object",' +
    '          "properties": {' +
    '            "cep": { "type": "string", "pattern": "^[0-9]{5}-[0-9]{3}$" }' +
    '          },' +
    '          "required": ["cep"]' +
    '        }' +
    '      },' +
    '      "required": ["endereco"]' +
    '    }' +
    '  },' +
    '  "required": ["cliente", "fornecedor"]' +
    '}';

  FReader.LoadFromString(LSchema);

  LJson := '{' +
    '"cliente":{"endereco":{"cep":"12345678"}},' +
    '"fornecedor":{"endereco":{"cep":"12345678"}}' +
    '}';

  Assert.IsFalse(FReader.Validate(LJson), 'Branches com mesma chave (cep) e regras diferentes deveriam invalidar');
  LErrors := FReader.GetErrors;
  Assert.IsTrue(Length(LErrors) > 0, 'Deveria retornar ao menos 1 erro');
end;

initialization
  TDUnitX.RegisterTestFixture(TSchemaDeepValidationBaselineTests);

end.

