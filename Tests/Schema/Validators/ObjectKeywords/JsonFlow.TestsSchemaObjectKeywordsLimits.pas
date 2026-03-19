unit JsonFlow.TestsSchemaObjectKeywordsLimits;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

type
  [TestFixture]
  TObjectKeywordsLimitsTests = class
  private
    FReader: TJSONSchemaReader;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestAdditionalProperties_False_AllowsPatternProperties;
    [Test]
    procedure TestMinProperties_Deep_ShouldFail;
    [Test]
    procedure TestMaxProperties_Deep_ShouldFail;
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

procedure TObjectKeywordsLimitsTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TObjectKeywordsLimitsTests.TearDown;
begin
  FReader.Free;
end;

procedure TObjectKeywordsLimitsTests.TestAdditionalProperties_False_AllowsPatternProperties;
var
  LSchema: string;
  LJson: string;
  LErrors: TArray<TValidationError>;
begin
  LSchema :=
    '{' +
    '  "type": "object",' +
    '  "patternProperties": {"^S_": {"type": "string"}},' +
    '  "additionalProperties": false' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  LJson := '{"S_name":"ok","X":1}';
  Assert.IsFalse(FReader.Validate(LJson));
  LErrors := FReader.GetErrors;
  Assert.IsTrue(Length(LErrors) > 0);
  Assert.Contains(LErrors[0].Message, 'Additional property', 'Deveria bloquear propriedade fora de properties/patternProperties');
end;

procedure TObjectKeywordsLimitsTests.TestMinProperties_Deep_ShouldFail;
var
  LSchema: string;
  LJson: string;
begin
  LSchema :=
    '{' +
    '  "type": "object",' +
    '  "properties": {' +
    '    "customer": {' +
    '      "type": "object",' +
    '      "minProperties": 2' +
    '    }' +
    '  }' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  LJson := '{"customer": {"a": 1}}';
  Assert.IsFalse(FReader.Validate(LJson));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TObjectKeywordsLimitsTests.TestMaxProperties_Deep_ShouldFail;
var
  LSchema: string;
  LJson: string;
begin
  LSchema :=
    '{' +
    '  "type": "object",' +
    '  "properties": {' +
    '    "customer": {' +
    '      "type": "object",' +
    '      "maxProperties": 1' +
    '    }' +
    '  }' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  LJson := '{"customer": {"a": 1, "b": 2}}';
  Assert.IsFalse(FReader.Validate(LJson));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

initialization
  TDUnitX.RegisterTestFixture(TObjectKeywordsLimitsTests);

end.

