unit JsonFlow.TestsSchemaObjectKeywordsDeep;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

type
  [TestFixture]
  TSchemaObjectKeywordsDeepTests = class
  private
    FReader: TJSONSchemaReader;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestAdditionalProperties_Schema_MinLength_ShouldFail;
    [Test]
    procedure TestPatternProperties_Schema_MinLength_ShouldFail;
    [Test]
    procedure TestPropertyNames_Schema_MinLength_ShouldFail;
  end;

implementation

uses
  System.SysUtils;

function JoinErrors(const AErrors: TArray<TValidationError>): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(AErrors) - 1 do
  begin
    if Result <> '' then
      Result := Result + ' | ';
    Result := Result + AErrors[I].Message;
  end;
end;

procedure TSchemaObjectKeywordsDeepTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TSchemaObjectKeywordsDeepTests.TearDown;
begin
  FReader.Free;
end;

procedure TSchemaObjectKeywordsDeepTests.TestAdditionalProperties_Schema_MinLength_ShouldFail;
var
  LSchema: string;
  LJson: string;
begin
  LSchema :=
    '{' +
    '  "type": "object",' +
    '  "properties": {"known": {"type": "string"}},' +
    '  "additionalProperties": {"type": "string", "minLength": 3}' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  LJson := '{"known":"ok","extra":"hi"}';
  Assert.IsFalse(FReader.Validate(LJson), 'additionalProperties schema deveria validar em profundidade');
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaObjectKeywordsDeepTests.TestPatternProperties_Schema_MinLength_ShouldFail;
var
  LSchema: string;
  LJson: string;
begin
  LSchema :=
    '{' +
    '  "type": "object",' +
    '  "patternProperties": {"^S_": {"type": "string", "minLength": 3}}' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  LJson := '{"S_name":"hi"}';
  Assert.IsFalse(FReader.Validate(LJson), 'patternProperties schema deveria validar em profundidade');
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaObjectKeywordsDeepTests.TestPropertyNames_Schema_MinLength_ShouldFail;
var
  LSchema: string;
  LJson: string;
begin
  LSchema :=
    '{' +
    '  "type": "object",' +
    '  "propertyNames": {"type": "string", "minLength": 3}' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  LJson := '{"ab": "x"}';
  Assert.IsFalse(FReader.Validate(LJson), 'propertyNames schema deveria validar o nome da propriedade');
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

initialization
  TDUnitX.RegisterTestFixture(TSchemaObjectKeywordsDeepTests);

end.

