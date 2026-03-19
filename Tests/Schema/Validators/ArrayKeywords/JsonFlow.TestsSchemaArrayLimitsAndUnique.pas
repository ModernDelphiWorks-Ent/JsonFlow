unit JsonFlow.TestsSchemaArrayLimitsAndUnique;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

type
  [TestFixture]
  TSchemaArrayLimitsAndUniqueTests = class
  private
    FReader: TJSONSchemaReader;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestMinItems_Deep_ObjectProperty_ShouldFail;
    [Test]
    procedure TestMaxItems_Deep_ObjectProperty_ShouldFail;

    [Test]
    procedure TestUniqueItems_Primitives_ShouldPass;
    [Test]
    procedure TestUniqueItems_Primitives_ShouldFail;
    [Test]
    procedure TestUniqueItems_Deep_ObjectProperty_ShouldFail;
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

procedure TSchemaArrayLimitsAndUniqueTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TSchemaArrayLimitsAndUniqueTests.TearDown;
begin
  FReader.Free;
end;

procedure TSchemaArrayLimitsAndUniqueTests.TestMinItems_Deep_ObjectProperty_ShouldFail;
var
  LSchema: string;
begin
  LSchema :=
    '{' +
    '  "type":"object",' +
    '  "properties": {' +
    '    "arr": {"type":"array","minItems":2}' +
    '  },' +
    '  "required": ["arr"]' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('{"arr":[1]}'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaArrayLimitsAndUniqueTests.TestMaxItems_Deep_ObjectProperty_ShouldFail;
var
  LSchema: string;
begin
  LSchema :=
    '{' +
    '  "type":"object",' +
    '  "properties": {' +
    '    "arr": {"type":"array","maxItems":1}' +
    '  },' +
    '  "required": ["arr"]' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('{"arr":[1,2]}'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaArrayLimitsAndUniqueTests.TestUniqueItems_Primitives_ShouldPass;
var
  LSchema: string;
begin
  LSchema := '{"type":"array","uniqueItems":true}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsTrue(FReader.Validate('[1,2,3]'));
end;

procedure TSchemaArrayLimitsAndUniqueTests.TestUniqueItems_Primitives_ShouldFail;
var
  LSchema: string;
begin
  LSchema := '{"type":"array","uniqueItems":true}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('[1,1]'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaArrayLimitsAndUniqueTests.TestUniqueItems_Deep_ObjectProperty_ShouldFail;
var
  LSchema: string;
begin
  LSchema :=
    '{' +
    '  "type":"object",' +
    '  "properties": {' +
    '    "arr": {"type":"array","uniqueItems":true}' +
    '  },' +
    '  "required": ["arr"]' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('{"arr":["a","a"]}'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

initialization
  TDUnitX.RegisterTestFixture(TSchemaArrayLimitsAndUniqueTests);

end.

