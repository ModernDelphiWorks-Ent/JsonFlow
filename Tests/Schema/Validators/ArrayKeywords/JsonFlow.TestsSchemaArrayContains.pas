unit JsonFlow.TestsSchemaArrayContains;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

type
  [TestFixture]
  TSchemaArrayContainsTests = class
  private
    FReader: TJSONSchemaReader;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestContains_SimpleArray_ShouldPass;
    [Test]
    procedure TestContains_SimpleArray_ShouldFail;
    [Test]
    procedure TestContains_Deep_ShouldFail;
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

procedure TSchemaArrayContainsTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TSchemaArrayContainsTests.TearDown;
begin
  FReader.Free;
end;

procedure TSchemaArrayContainsTests.TestContains_SimpleArray_ShouldPass;
var
  LSchema: string;
begin
  LSchema := '{"type":"array","contains":{"type":"integer"}}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsTrue(FReader.Validate('["a", 1]'));
end;

procedure TSchemaArrayContainsTests.TestContains_SimpleArray_ShouldFail;
var
  LSchema: string;
begin
  LSchema := '{"type":"array","contains":{"type":"integer"}}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('["a", "b"]'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaArrayContainsTests.TestContains_Deep_ShouldFail;
var
  LSchema: string;
begin
  LSchema :=
    '{' +
    '  "type":"object",' +
    '  "properties": {' +
    '    "arr": {"type":"array","contains":{"type":"integer"}}' +
    '  },' +
    '  "required": ["arr"]' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('{"arr":["x","y"]}'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

initialization
  TDUnitX.RegisterTestFixture(TSchemaArrayContainsTests);

end.

